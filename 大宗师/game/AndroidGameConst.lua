 --[[--
 --
 -- @authors shan 
 -- @date    2014-12-27 15:26:15
 -- @version 
 --
 --]]

-- 本地服务器
ANDROID_NO_SDK = false

if(device.platform == "android") then
	if(GAME_DEBUG == true) then
		ANDROID_NO_SDK = false
	end
	
end

