
--[[本地服务器]]
ANDROID_NO_SDK = false

if (device.platform == "android") then
	if (GAME_DEBUG == true) then
		ANDROID_NO_SDK = false
	end
end

