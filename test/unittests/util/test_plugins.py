# Copyright 2020 Yui AI Inc.
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
from unittest import TestCase, mock

import yui.util.plugins as mycroft_plugins


def get_plug_mock(name):
    load_mock = mock.Mock(name=name)
    load_mock.name = name
    plug_mock = mock.Mock(name=name)
    plug_mock.name = name
    plug_mock.load.return_value = load_mock
    return plug_mock


def mock_iter_entry_points(plug_type):
    """Function to return mocked plugins."""
    plugs = {
        'yui.plugins.tts': [get_plug_mock('dummy'),
                                get_plug_mock('remote')],
        'yui.plugins.stt': [get_plug_mock('dummy'),
                                get_plug_mock('deepspeech')]
    }
    return plugs.get(plug_type, [])


@mock.patch('yui.util.plugins.pkg_resources')
class TestPlugins(TestCase):
    def test_load_existing(self, mock_pkg_res):
        """Ensure that plugin objects are returned if found."""
        mock_pkg_res.iter_entry_points.side_effect = mock_iter_entry_points

        # Load a couple of existing modules and verify that they're Ok
        plug = mycroft_plugins.load_plugin('yui.plugins.tts', 'dummy')
        self.assertEqual(plug.name, 'dummy')
        plug = mycroft_plugins.load_plugin('yui.plugins.stt', 'deepspeech')
        self.assertEqual(plug.name, 'deepspeech')

    def test_load_nonexisting(self, mock_pkg_res):
        """Ensure that the return value is None when no plugin is found."""
        mock_pkg_res.iter_entry_points.side_effect = mock_iter_entry_points
        plug = mycroft_plugins.load_plugin('yui.plugins.tts', 'blah')
        self.assertEqual(plug, None)
