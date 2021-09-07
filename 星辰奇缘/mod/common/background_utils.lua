-- 后台工具
-- LJH
BackgroundUtils = BackgroundUtils or {}

-- 首次开启游戏
function BackgroundUtils.FirstOpen()
	local isFirstOpen = PlayerPrefs.GetInt("isFirstOpen")
	if isFirstOpen == 1 then

		local device_id = ctx.GeTuiClient

	    if device_id == nil or device_id == "" then
	        device_id = PlayerPrefs.GetString("virtual_device_id")
	        if device_id == nil or device_id == "" then
	            device_id = string.format("%s_%s_%s", "virtual", os.time(), Random.Range(1000, 9999))
	            PlayerPrefs.SetString("virtual_device_id", device_id)
	        end
	    end

		local url = string.format("http://192.168.1.110/index.php/​device/activation​​?device_id=%s&product_name=%s&platform_name=%s&channel_name=%s&date_time=%s"
			, device_id, "product_name", "platform_name", "channel_name", os.time())
		local callback = function(www, str) print("BackgroundUtils.FirstOpen()") print(www) print(str) end
		ctx:GetRemoteTxt(url, callback, 3)


		PlayerPrefs.SetInt("isFirstOpen", 1)
	end
end

-- 首次开启游戏
function BackgroundUtils.Entry(step)
	local device_id = ctx.GeTuiClient

	if device_id == nil or device_id == "" then
	    device_id = PlayerPrefs.GetString("virtual_device_id")
	    if device_id == nil or device_id == "" then
	        device_id = string.format("%s_%s_%s", "virtual", os.time(), Random.Range(1000, 9999))
	        PlayerPrefs.SetString("virtual_device_id", device_id)
	    end
	end

	local url = string.format("http://192.168.1.110/index.php/​device/activation​​?device_id=%s&product_name=%s&platform_name=%s&channel_name=%s&date_time=%s&step=%s"
		, device_id, "product_name", "platform_name", "channel_name", os.time(), step)
	local callback = function(www, str) print("BackgroundUtils.Entry()") print(www) print(str) end
	ctx:GetRemoteTxt(url, callback, 3)
end