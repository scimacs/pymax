'''Setup for the scimax python installation.

'''

from distutils.core import setup


setup(name='scimax',
      version='3.0',
      description='Scimax for greater good.',
      author='John Kitchin',
      author_email='jkitchin@andrew.cmu.edu',
      url='https://github.com/jkitchin/scimax',
      packages=['scimax'],
      scripts=['scimax/scripts/scimax',
               'scimax/scripts/install-scimax-win.sh'])
