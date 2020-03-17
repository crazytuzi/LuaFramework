--[[
世界boss奖励查询面板
2014年12月5日14:33:32
郝户
]]

_G.UIWorldBossReward = BaseUI:new("UIWorldBossReward");

function UIWorldBossReward:Create()
	self:AddSWF("worldBossRewardPanel.swf", true, nil);
end

function UIWorldBossReward:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	RewardManager:RegisterListTips( objSwf.rewardListKill );
	RewardManager:RegisterListTips( objSwf.rewardListMaxDamage );
	RewardManager:RegisterListTips( objSwf.rewardListDamage );
	RewardManager:RegisterListTips( objSwf.rewardListJoin );
end

function UIWorldBossReward:OnShow()
	self:UpdateShow();
end

function UIWorldBossReward:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bossId = self.parent.currId;
	local bossCfg = t_worldboss[bossId];
	if not bossCfg then return; end

	self:ShowReward( objSwf.rewardListKill, bossCfg.kill_reward );
	self:ShowReward( objSwf.rewardListMaxDamage, bossCfg.max_damage_reward );
	self:ShowReward( objSwf.rewardListDamage, bossCfg.damage_reward );
	self:ShowReward( objSwf.rewardListJoin, bossCfg.join_reward );
end

-- 奖励
function UIWorldBossReward:ShowReward( list, rewardStr )
	local rewardItemList = RewardManager:Parse( rewardStr );
	list.dataProvider:cleanUp();
	list.dataProvider:push( unpack(rewardItemList) );
	list:invalidateData();
end

function UIWorldBossReward:OnBtnCloseClick()
	self:Hide();
end
