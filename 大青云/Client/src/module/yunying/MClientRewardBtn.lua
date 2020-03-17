--[[
微端奖励按钮
lizhuangzhuang
2015年5月14日17:21:58
]]

_G.MClientReawrdBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_MClient,MClientReawrdBtn);

function MClientReawrdBtn:GetStageBtnName()
	return "MClientReward";
end

function MClientReawrdBtn:IsShow()

	if t_consts[345] then
		local constCfgNeedLevel = t_consts[345].val1
		if constCfgNeedLevel then
			local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel -- 当前人物等级
			if curRoleLvl < constCfgNeedLevel then return false end
		end
    end
	if Version:IsHideMClient() then
		return false;
	end
	return not MClientModel.hasGetReward;
end	
function MClientReawrdBtn:OnBtnClick()
	self:DoShowUI("UIMClientReward");
end
function MClientReawrdBtn:OnRefresh()
	if not self.button then return; end
	if _G.ismclient and not MClientModel.hasGetReward then
		self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect();
	end
end
