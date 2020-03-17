--[[
V计划按钮
lizhuangzhuang
2015年5月14日18:17:30
]]

_G.VPlanBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_VPlan,VPlanBtn);

function VPlanBtn:GetStageBtnName()
	return "VPlan";
end

function VPlanBtn:IsShow()
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	local cfg = t_consts[126]
	if not cfg then return false end
	if curRoleLvl >= toint(split(cfg.param,'#')[1]) then
		return Version:IsOpenVPlan()
	end
	return false
end


function VPlanBtn:OnBtnClick()
	if UIVplanMain:IsShow() then
		UIVplanMain:Hide();
	else
		if self.button then
			UIVplanMain.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UIVplanMain:Show();
		VplanController:ReqVplan();
	end
end

