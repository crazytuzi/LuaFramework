module ("SupportUtil", package.seeall)

--[[
	@des:检测底包是否要支持https
	@ret:true 支持，false不支持
--]]
function isSupportHttps()
	local https_version = "6.0.0"
	local isSupport = false
	if string.checkScriptVersion(NSBundleInfo:getAppVersion(), https_version) then
		if Platform.getOS() == "ios" then
			isSupport = true
		end
	end
	return isSupport
end

--[[
	@des:检测底包是否要支持https
	@ret:true 支持，false不支持
--]]
function isSupportSpine()
	if table.isEmpty(SkeletonAnimation) then
		return false
	else
		return true
	end
end