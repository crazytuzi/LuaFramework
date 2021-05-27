require("scripts/platform/platform_adapter")

function PlatformAdapter:GetAssetsInfo()
	return {
		version = 58,
		file_list = { path = "list.zip", size=27812 }
	}
end

function PlatformAdapter:GetLocalConfig()
	-- local pkg_info = self:GetPackageInfo()
	
	--new
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	if spid ~= "dev" then -- 微端平台,使用windows版本
		local local_cfg = cjson.decode(UtilEx:readText(UtilEx:getDataPath() .. "config.txt")) or {}
		if nil == local_cfg.init_url then
			local pkg_info = self:GetPackageInfo()
			local_cfg.init_url = pkg_info.config.init_url
		end
		if nil == local_cfg.report_url then
			local pkg_info = self:GetPackageInfo()
			local_cfg.report_url = pkg_info.config.countly_report_url
		end
		return local_cfg
	end	

	IS_DEBUG = true
	
	return {
		init_url = "http://47.117.138.81/args.php"
	}
end

function PlatformAdapter:SaveLocalConfig(local_cfg)
end

function PlatformAdapter:GetNetState()
	return 2
end
--
function PlatformAdapter.GetListZipPath()
	return "../../version/list.zip"
end
