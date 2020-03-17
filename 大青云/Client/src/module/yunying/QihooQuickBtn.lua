--[[
	2015年9月21日, PM 12:16:53
	360加速球按钮
	wangyanwei
]]

_G.QihoooQuickBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_QiHooQuick,QihoooQuickBtn);

function QihoooQuickBtn:GetStageBtnName()
	return "QihooQuick";
end

function QihoooQuickBtn:IsShow()
	if not Version:IsOpenWanSpeed() then
		return false;
	end
	if not QihooQuickModel:IsGetReward() then
		return false;
	end
	return true
end

function QihoooQuickBtn:OnBtnClick()
	QihooQuickController:SendQihooQuickReward()
end