--[[
日环任务：暴击(多倍)奖励面板
郝户
2014年12月11日14:38:14
]]

_G.UIQuestDayMultipleReward = UIQuestDayReward:new("UIQuestDayMultipleReward");

function UIQuestDayMultipleReward:Create()
	self:AddSWF("taskDayMultipleRewardPanel.swf", true, "center");
end

function UIQuestDayMultipleReward:OnLoaded( objSwf )
	self:InitRewardBtns( objSwf )
	RewardManager:RegisterListTips( objSwf.list )
end

function UIQuestDayMultipleReward:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local questVO = self.questDailyVO
	-- 特效
	objSwf.effBg:stopEffect()
	objSwf.effBg:playEffect(1)
	local mc = objSwf.numLoader
	mc._xscale, mc._yscale = 0, 0
	Tween:To( mc, 0.3, { delay = 0.2, _xscale = 100, _yscale = 100, ease = Elastic.easeOut } )
	-- 奖励
	local rewardExp, rewardMoney, rewardZhenqi = questVO:GetRewards()
	local multiple     = questVO:GetMultiple() -- 倍数
	local rewardExp    = multiple * rewardExp
	local rewardMoney  = multiple * rewardMoney
	local rewardZhenqi = multiple * rewardZhenqi
	-- 倍数显示
	objSwf.numLoader.num = multiple
	-- 文本
	objSwf.txtExp.text    = _G.getNumShow( rewardExp )
	objSwf.txtMoney.text  = _G.getNumShow( rewardMoney )
	objSwf.txtZhenqi.text = _G.getNumShow( rewardZhenqi )
	-- 图标
	local rewardList = RewardManager:Parse( enAttrType.eaExp .. "," .. rewardExp,
		enAttrType.eaUnBindGold .. "," .. rewardMoney,
		enAttrType.eaZhenQi .. "," .. rewardZhenqi )
	local uiList = objSwf.list
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack(rewardList) )
	uiList:invalidateData()
	self:HideTxt();
end

function UIQuestDayMultipleReward:ShowEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.effBg:stopEffect()
	objSwf.effBg:playEffect(1)
	local mc = objSwf.eff
	mc._xscale, mc._yscale = 180, 180
	Tween:To( mc, 0.4, { delay = 1.2, _xscale = 100, _yscale = 100, ease = Elastic.easeOut } )
end

function UIQuestDayMultipleReward:ShowAddTxt(_type)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if _type == 1 then 
		return 
	end
	local cfg = t_consts[74];
	if not cfg then return end
	local questVO = self.questDailyVO
	if not questVO then return end
	local rewardValCfg = split(cfg.param,'#');
	local rewardVal = 1;
	if _type == 2 then
		rewardVal = split(rewardValCfg[2],',')[1];
	elseif _type == 3 then
		rewardVal = split(rewardValCfg[3],',')[1];
	end
	local rewardExp, rewardMoney, rewardZhenqi = questVO:GetRewards();
	local multiple     = questVO:GetMultiple() -- 倍数
	rewardExp    = multiple * rewardExp
	rewardMoney  = multiple * rewardMoney
	rewardZhenqi = multiple * rewardZhenqi
	rewardExp, rewardMoney, rewardZhenqi = rewardExp * (rewardVal - 1), rewardMoney * (rewardVal - 1), rewardZhenqi  * (rewardVal - 1);
	objSwf.txt_addExp._visible = true;
	objSwf.txt_addMoney._visible = true;
	objSwf.txt_addZhenqi._visible = true;
	objSwf.txt_addExp.text = '+' .. _G.getNumShow( rewardExp );
	objSwf.txt_addMoney.text = '+' .. _G.getNumShow( rewardMoney );
	objSwf.txt_addZhenqi.text = '+' .. _G.getNumShow( rewardZhenqi );
end

function UIQuestDayMultipleReward:HideTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.txt_addExp._visible = false;
	objSwf.txt_addMoney._visible = false;
	objSwf.txt_addZhenqi._visible = false;
end

-- function UIQuestDayMultipleReward:GetWidth()
-- 	return 678
-- end

-- function UIQuestDayMultipleReward:GetHeight()
-- 	return 339
-- end