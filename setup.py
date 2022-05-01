# Copyright 2017 Yui AI Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
from setuptools import setup, find_packages
import os
import os.path

BASEDIR = os.path.abspath(os.path.dirname(__file__))


def get_version():
    """ Find the version of yui-core"""
    version = None
    version_file = os.path.join(BASEDIR, 'yui', 'version', '__init__.py')
    major, minor, build = (None, None, None)
    with open(version_file) as f:
        for line in f:
            if 'CORE_VERSION_MAJOR' in line:
                major = line.split('=')[1].strip()
            elif 'CORE_VERSION_MINOR' in line:
                minor = line.split('=')[1].strip()
            elif 'CORE_VERSION_BUILD' in line:
                build = line.split('=')[1].strip()

            if ((major and minor and build) or
                    '# END_VERSION_BLOCK' in line):
                break
    version = '.'.join([major, minor, build])

    return version


def required(requirements_file):
    """ Read requirements file and remove comments and empty lines. """
    with open(os.path.join(BASEDIR, requirements_file), 'r') as f:
        requirements = f.read().splitlines()
        if 'MYCROFT_LOOSE_REQUIREMENTS' in os.environ:
            print('USING LOOSE REQUIREMENTS!')
            requirements = [r.replace('==', '>=') for r in requirements]
        return [pkg for pkg in requirements
                if pkg.strip() and not pkg.startswith("#")]


setup(
    name='yui-core',
    version=get_version(),
    license='Apache-2.0',
    author='Yui A.I.',
    author_email='devs@yui.ai',
    url='https://github.com/MycroftAI/yui-core',
    description='Yui Core',
    install_requires=required('requirements/requirements.txt'),
    extras_require={
        'audio-backend': required('requirements/extra-audiobackend.txt'),
        'mark1': required('requirements/extra-mark1.txt'),
        'stt': required('requirements/extra-stt.txt')
    },
    packages=find_packages(include=['yui*']),
    include_package_data=True,

    entry_points={
        'console_scripts': [
            'yui-speech-client=yui.client.speech.__main__:main',
            'yui-messagebus=yui.messagebus.service.__main__:main',
            'yui-skills=yui.skills.__main__:main',
            'yui-audio=yui.audio.__main__:main',
            'yui-echo-observer=yui.messagebus.client.ws:echo',
            'yui-audio-test=yui.util.audio_test:main',
            'yui-enclosure-client=yui.client.enclosure.__main__:main',
            'yui-cli-client=yui.client.text.__main__:main'
        ]
    }
)
