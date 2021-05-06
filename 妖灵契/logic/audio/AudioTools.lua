module(..., package.seeall)

function GetAudioRoot()
	if not g_AudioRoot then
		local obj = UnityEngine.GameObject.Find("GameRoot/Audio")
		if obj then
			g_AudioRoot = obj.transform
		end
	end
	return g_AudioRoot
end

function CreateAudioPlayer(name)
	local oPlayer = CAudioPlayer.New()
	if name then
		oPlayer:SetName(name)
	end
	oPlayer:SetParent(GetAudioRoot())
	return oPlayer
end