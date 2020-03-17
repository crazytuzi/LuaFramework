--[[
	2015年10月31日, AM 11:00:42
	野外boss活动
	zhangshuhui
]]

_G.ActivityBossBaoDong = setmetatable({},{__index=BaseActivity});
ActivityModel:RegisterActivityClass(ActivityConsts.T_BossBaoDong,ActivityBossBaoDong);

function ActivityBossBaoDong:GetNoticeOpenTimeStr()
	return StrConfig["activity005"];
end