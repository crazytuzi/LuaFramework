-------------------------------------------
--module(..., package.seeall)

local require = require;

require("i3k_global");

------------------------------------------------------------------
i3k_audio_listener = i3k_class("i3k_audio_listener");
function i3k_audio_listener:ctor(name)
	self._name = name;
end

function i3k_audio_listener:Create()
	g_i3k_mmengine:CreateAudioListener(self._name, Engine.SVector3(0.0, 0.0, 0.0));
end

function i3k_audio_listener:UpdatePos(pos)
	g_i3k_mmengine:SetAudioListenerPos(self._name, pos);
end

function i3k_audio_listener:Release()
	g_i3k_mmengine:ReleaseAudioListener(self._name);
end
