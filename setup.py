'''Setup for the scimax python installation.

This python package installs scimax if needed, and provides a convenient command
line utility (scimax) for running it.

'''

from distutils.core import setup
from distutils.command.build_py import build_py
import os
import shutil
from git import Repo  # pip install gitpython
import subprocess
import configparser

# adapted from
# http://www.digip.org/blog/2011/01/generating-data-files-in-setup.py.html It
# seems like I could do all this in the script without this fancyness, although
# this currently does support dry-run. The main point of this package is really
# the script and making installation easy.


def check_for_programs():
    '''Runs checks for required programs.
    You need an Emacs 26 or newer and git.
    '''
    if not shutil.which('emacs'):
        raise Exception('''No emacs found. Please install one.
Windows:
Mac: brew tap d12frosted/emacs-plus\nbrew install emacs-plus
Linux:
''')

    emacs_version = subprocess.check_output(['emacs', '-q', '-batch',
                                             '-eval',
                                             "(princ emacs-version)"])
    emacs_version = emacs_version.decode('ascii').strip()
    if not int(emacs_version.split('.')[0]) >= 26:
        raise Exception('You need Emacs 26 or greater for scimax')

    if not shutil.which('git'):
        raise Exception('''No git found. Please install one.
Windows: https://git-scm.com/download/win
Mac: https://git-scm.com/download/mac
Linux:
''')

    if not shutil.which('latex'):
        print('''No latex found. You need this to make pdfs and see equations.
Windows: https://www.tug.org/texlive/
Mac: http://www.tug.org/mactex/
Linux:
''')


class my_build_py(build_py):
    def run(self):
        # honor the --dry-run flag
        if not self.dry_run:
            check_for_programs()

            # Default installation
            scimax_dir = os.expanduser('~/.scimax/scimax')

            config = configparser.ConfigParser()
            cf = os.path.expanduser('~/.scimax/config')
            if os.path.exists(cf):
                config.read(cf)
                scimax_dir = config['DEFAULT'].get('scimax_dir', scimax_dir)

            # This is the scimax code
            if not os.path.isdir(scimax_dir):
                print('I did not find scimax. '
                      f'Cloning scimax in a subprocess at {scimax_dir}.')
                cpe = subprocess.run(['git', 'clone',
                                      'git@github.com:jkitchin/scimax.git',
                                      scimax_dir],
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE,
                                     check=True)
                print(f'stdout:\n{cpe.stdout.decode("ascii")}',
                      f'\nstderr:{cpe.stderr.decode("ascii")}')
            else:
                print(f'Existing build at {scimax_dir}. '
                      'Pulling scimax now.'
                      'If your repo is not clean, this may fail.')
                pwd = os.getcwd()
                os.chdir(scimax_dir)
                cpe = subprocess.run(['git', 'pull'],
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE,
                                     check=True)
                print(f'stdout:\n{cpe.stdout.decode("ascii")}',
                      f'\nstderr:{cpe.stderr.decode("ascii")}')
                os.chdir(pwd)

            print('Fetching elpa')
            # Note: I could download a zip file here which might avoid vc issues
            # when the packages are updated later.
            scimax_elpa = os.path.join(scimax_dir, 'elpa')
            if not os.path.isdir(scimax_elpa):
                Repo.clone_from('https://github.com/scimacs/scimacs-elpa.git',
                                scimax_elpa)

            # We probably do not want to do this as it is likely there will be
            # conflicts.

            # else:
            #     print('Existing elpa. Pulling it now')
            #     repo = Repo(scimax_elpa)
            #     o = repo.remotes.origin
            #     o.pull()


            # Downside is lack of incremental updates, you have to get everything each time?
            # elpa_zip = os.path.join(target_dir, 'master.zip')
            # url.urlretrieve('https://github.com/jkitchin/scimax-win-elpa/archive/master.zip',
            #                 elpa_zip)
            # with zipfile.ZipFile(elpa_zip, 'r') as zip_ref:
            #     zip_ref.extractall(scimax_elpa)


        # distutils uses old-style classes, so no super()
        build_py.run(self)


setup(name='scimax',
      version='3.0',
      description='Scimax for greater good.',
      author='John Kitchin',
      author_email='jkitchin@andrew.cmu.edu',
      url='https://github.com/jkitchin/scimax',
      packages=['scimax'],
      scripts=['scimax/scripts/scimax'],
      cmdclass={'build_py': my_build_py})
