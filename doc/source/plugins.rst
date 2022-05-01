Yui plugins
===============
Yui is extendable by plugins. These plugins can add support for new Speech To Text engines, Text To Speech engines, wake word engines and add new audio playback options.

TTS - Base for TTS plugins
--------------------------
.. autoclass:: yui.tts.TTS
    :members:

|
|

STT - base for STT plugins
--------------------------
.. autoclass:: yui.stt.STT
    :members:

|
|

.. autoclass:: yui.stt.StreamingSTT
    :members:

|
|

.. autoclass:: yui.stt.StreamThread
    :members:

|
|

HotWordEngine - Base for Hotword engine plugins
-----------------------------------------------
.. autoclass:: yui.client.speech.hotword_factory.HotWordEngine
    :members:

|
|

AudioBackend - Base for audioservice backend plugins
----------------------------------------------------
.. autoclass:: yui.audio.services.AudioBackend
    :members:

|
|

.. autoclass:: yui.audio.services.RemoteAudioBackend
    :members:

