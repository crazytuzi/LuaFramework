--[[
等级奖励Util
zhangshuhui
2014年12月17日14:20:20
]]

_G.RegisterAwardUtil = {};

--该等级是否已领奖

function RegisterAwardUtil:GetIsRewarded(lvl)
	if RegisterAwardModel.levelawardlist then
		for i,vo in pairs(RegisterAwardModel.levelawardlist) do
			if vo then
				if vo.lvl == lvl then
					return true;
				end
			end
		end
	end
	
	return false;
end




--是否有未领取的奖励
function RegisterAwardUtil:GetisHaveReward()
	if self:GetIsHaveLevelReward() == true then
		return true;
	end
	
	if self:GetIsHaveOutlineReward() == true then
		return true;
	end
	
	if self:GetIsHaveSige() == true then
		return true;
	end
	if self:GetIsHaveOnTimeAward() == true then
		return true;
	end
	
	return false;
end

--是否有未领取等级奖励
function RegisterAwardUtil:GetIsHaveLevelReward()
	local playerinfo = MainPlayerModel.humanDetailInfo;
	for i,vo in pairs(t_lvreward) do
		if vo then
			if vo.lvl <= playerinfo.eaLevel then
				if self:GetIsRewarded(vo.lvl) == false then
				return true;
				end
			end
		end
	end
	
	return false;
end

--是否有离线奖励
function RegisterAwardUtil:GetIsHaveOutlineReward()
	if RegisterAwardModel.outlinetime > 0 then
		return true;
	else
		return false;
	end
end

--是否有可签到的操作
function RegisterAwardUtil:GetIsHaveSige()
	if RegisterAwardModel:GetRewardIsDraw() then
		return true;
	end
	return not RegisterAwardModel:GetIndexSign(RegisterAwardModel.nowDayNum);
end

--是否在线奖励可领取
function RegisterAwardUtil:GetIsHaveOnTimeAward()
	return RegisterAwardModel:GetIsOperation();
end

--是否有可用激活码
function RegisterAwardUtil:GetIsHaveJiHuoMa()
	return false;
end

--是否弹出等级礼包提示框
function RegisterAwardUtil:GetIsOpenLevelRewardGift(oldLvl)
	if oldLvl <= 0 then
		return 0;
	end
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local giftlevel = math.modf(playerinfo.eaLevel / 10);
	if giftlevel > math.modf(oldLvl / 10) then
		if self:GetIsRewarded(giftlevel * 10) == false then
			if t_lvreward[giftlevel * 10] then
				return giftlevel * 10;
			end
		end
	end
	
	return 0;
end

--红点提示
function RegisterAwardUtil:CanRewardDetail ()
	local num = 0;
	local canShow = false;
	if self:GetIsHaveSige() then                                          --签到和阶段领取奖励
		num = num +1;
		canShow = true
	end
	if self:GetIsHaveLevelReward() then                                   --等级礼包
		num = num + self:GetlvRewardNum ();
		-- print("-----等级礼包未领取数量:",self.notGetRewardNum)
		canShow = true
	end
	if self:GetIsHaveOnTimeAward() then                                   --在线奖励  
		local CanGetNum = RegisterAwardModel:GetIsOperationNum() 
		-- print("-----在线礼包未领取数量:",CanGetNum)
		num = num + CanGetNum;
		canShow = true
	end
	if self:GetIsHaveOutlineReward() then                                 --离线奖励   
		-- print("-----离线礼包未领取数量:",self:GetoutilneRewardNum())
		num = num + self:GetoutilneRewardNum();
		canShow = true
	end
	if self:GetIsHaveJiHuoMa() then                                       --礼包兑换码
		num = num +1;
		canShow = true
	end
	return canShow,num;
end

--等级礼包
--贰 用来计算等级礼包有多少个可以领取的礼包数量
RegisterAwardUtil.notGetRewardNum = 0;   --等级未礼包领取数量
function RegisterAwardUtil:GetlvRewardNum ()
	self.notGetRewardNum = 0;
	local playerinfo = MainPlayerModel.humanDetailInfo;
	for i,vo in pairs(t_lvreward) do
		if vo then
			if vo.lvl <= playerinfo.eaLevel then
				if self:GetIsRewarded(vo.lvl) == false then
					self.notGetRewardNum = self.notGetRewardNum +1;
				end
			end
		end
	end
	return self.notGetRewardNum;
end

--在线奖励
--叁 用来计算在线礼包有多少个可以领取的礼包数量
RegisterAwardUtil.notGetOnLineRewardNum = 0;   --在线奖励未领取礼包数量
function RegisterAwardUtil:GetOnilneRewardNum ()
	self.notGetOnLineRewardNum = 0;
	if self:GetIsHaveOnTimeAward() then
		self.notGetOnLineRewardNum = RegisterAwardModel:GetIsOperationNum() 
	end
	return self.notGetOnLineRewardNum
end

--离线奖励
--肆 用来计算离线礼包有多少个可以领取的礼包数量
RegisterAwardUtil.notGetOutLineRewardNum = 0;   --在线奖励未领取礼包数量
function RegisterAwardUtil:GetoutilneRewardNum ()
	self.notGetOutLineRewardNum = 0;
	if self:GetIsHaveOutlineReward() then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		local GoldTime = VipModel:GetVipPeriod( VipConsts.TYPE_GOLD )--黄金
		local DiamondTime = VipModel:GetVipPeriod( VipConsts.TYPE_DIAMOND )--钻石
		if RegisterAwardModel.outlinetime > 0 then   --普通奖励
			self.notGetOutLineRewardNum = self.notGetOutLineRewardNum +1;
		end
		if GoldTime > 0 then    --vip等级大于1
			self.notGetOutLineRewardNum = self.notGetOutLineRewardNum +1;
		end
		if DiamondTime > 0 then    --vip等级大于5
			self.notGetOutLineRewardNum = self.notGetOutLineRewardNum +1;
		end
	end
	return self.notGetOutLineRewardNum
end

