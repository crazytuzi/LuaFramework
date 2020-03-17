--[[
更新公告管理
zhangshuhui
]]
_G.UpdateNoticeController = setmetatable({},{__index=IController})
UpdateNoticeController.name = "UpdateNoticeController";

function UpdateNoticeController:Create()
end

function UpdateNoticeController:OnEnterGame()
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local tVersion = updateContentcfg.version;
	
	local roleCfg = ConfigManager:GetRoleCfg();
	if level < 1000 then --TODO 暂时屏蔽
		roleCfg.updateVersion = tVersion;
		ConfigManager:Save();
	else
		if not roleCfg.updateVersion or roleCfg.updateVersion<tVersion then
			--todo ui
			UIUpdateNoticeView:Show();
			roleCfg.updateVersion = tVersion;
			ConfigManager:Save();
		end
	end
end