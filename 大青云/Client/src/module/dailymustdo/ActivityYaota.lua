--[[
	2016-5-17
	打宝塔
	chenyujia
]]
_G.ActivityYaota = BaseActivity:new(ActivityConsts.XianYuan);
ActivityModel:RegisterActivity(ActivityYaota);

-- 进入活动执行方法
function ActivityYaota:OnEnter()
	MainMenuController:HideRight()
	UIYaota:Hide();
	UIYaotaInfo:Show();
	ActivityController:SendActivityOnLineTime(ActivityConsts.XianYuan);
	UIYaota:StartTime()
end
-- 退出活动执行方法
function ActivityYaota:OnQuit()
	MainMenuController:UnhideRight()
	UIYaotaInfo:Hide()
	ActivityController:SendActivityOnLineTime(ActivityConsts.XianYuan);
	UIYaota:StopTime()
end

function ActivityYaota:OnSceneChange()
	
end