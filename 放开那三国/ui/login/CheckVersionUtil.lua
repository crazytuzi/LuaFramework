-- Filename：	CheckVersionUtil.lua
-- Author：		Cheng Liang
-- Date：		2015-12-15
-- Purpose：		检测更新的逻辑

module ("CheckVersionUtil", package.seeall)


-- 是否支持国战
function isSuppurtCountryWar()
	if(g_system_type == kBT_PLATFORM_WP8)then
		return true
	else
		if(string.checkScriptVersion(g_publish_version, "5.0.0") >=0)then
			return true
		else
			showDownloadTip()
			return false
		end
	end
end


function showDownloadTip()

	local downloadUrl = CheckVerionLogic.getPackDownloadUrl()
	local downloadTip = CheckVerionLogic.getTipText() or GetLocalizeStringBy("cl_1021")

	if(downloadUrl == nil)then
		return
	end

	local function tipFunc( is_corform)
		print("downloadUrl == ",downloadUrl)
		if(is_corform == true)then
			Platform.openUrl(downloadUrl)
		end
	end 
	AlertTip.showAlert(downloadTip,tipFunc, true, nil, GetLocalizeStringBy("cl_1019"), GetLocalizeStringBy("cl_1022"))
	return
end
