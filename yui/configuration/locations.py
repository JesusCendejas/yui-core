# Copyright 2018 Yui AI Inc.
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
import os
from os.path import join, dirname, expanduser

import xdg.BaseDirectory

DEFAULT_CONFIG = join(dirname(__file__), 'yui.conf')
SYSTEM_CONFIG = os.environ.get('YUI_SYSTEM_CONFIG',
                               '/etc/yui/yui.conf')
# TODO: remove in 22.02
# Make sure we support the old location still
# Deprecated and will be removed eventually
OLD_USER_CONFIG = join(expanduser('~'), '.yui/yui.conf')
USER_CONFIG = join(xdg.BaseDirectory.xdg_config_home,
                   'yui',
                   'yui.conf'
                   )

REMOTE_CONFIG = "yui.ai"
WEB_CONFIG_CACHE = os.environ.get('YUI_WEB_CACHE',
                                  '/var/tmp/mycroft_web_cache.json')
