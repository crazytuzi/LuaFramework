--[[
VIP Model
2015年7月22日15:26:10
haohu
]]
------------------------------------------------------------

_G.VipModel = Module:new()

VipModel.vipExp                 = nil -- vip经验
VipModel.periodMap              = nil -- 剩余期限表, DS: [vip类型] = 剩余时间( 剩余时间0:已到期, -1:未激活 )
VipModel.levelRewardAcceptedMap = nil -- 等级奖励是否已领取, DS: [vip等级] = 是/否领取
VipModel.weekRewardAccepted     = nil -- 周奖励是否已领取
--坐骑VIP返还
VipModel.isShowBackInfo			= false;
VipModel.backInfoList			= {};

----------------------------初始化--------------------------------

function VipModel:Init()
	self.vipExp = 0
	self.periodMap = {}
	for vipType, _ in pairs(t_viptype) do
		self.periodMap[vipType] = 0
	end
	self.levelRewardAcceptedMap = {}
	for vipLevel, _ in pairs(t_vip) do
		self.levelRewardAcceptedMap[vipLevel] = true
		
	end
	self.weekRewardAccepted = false
end

----------------------------VIP经验--------------------------------

function VipModel:GetVipExp()
	return self.vipExp
end

function VipModel:SetVipExp( value )
	if self.vipExp == value then return end
	self.vipExp = value
	self:sendNotification( NotifyConsts.VipExp )
end

----------------------------VIP剩余时间--------------------------------

function VipModel:GetVipPeriod( vipType )
	-- FPrint('有效期'..self.periodMap[vipType])
	return self.periodMap[vipType]
end

-- function VipModel:GetVipPeriod( vipType )
	-- if self.periodMap[vipType] == 0 or self.periodMap[vipType] == -1 then
		-- return false
	-- end
	
	-- return true
-- end

function VipModel:SetVipPeriod( vipType, time )
	if self.periodMap[vipType] == time then return end
	self.periodMap[vipType] = time
	self:sendNotification( NotifyConsts.VipPeriod )
end

----------------------------VIP等级奖励领取状态--------------------------------

function VipModel:GetLevelRewardState( vipLevel )--是否已领取
	return self.levelRewardAcceptedMap[vipLevel]
end

function VipModel:SetLevelRewardState( vipLevel, accepted )
	if self.levelRewardAcceptedMap[vipLevel] == accepted then return end
	self.levelRewardAcceptedMap[vipLevel] = accepted
	self:sendNotification( NotifyConsts.VipLevelRewardState )
end

function VipModel:GetMinLevelReward()
	local maxLv = VipConsts:GetMaxVipLevel()
	for i = 1, maxLv do
		if not VipModel:GetLevelRewardState( i ) then
			
			return i
		end
	end
	
	return -1
end
----------------------------VIP每周奖励领取状态--------------------------------

function VipModel:GetWeekRewardState()
	if VipController:GetWeekReward() < 1 then
		return -1
	end		
	
	return self.weekRewardAccepted
end

function VipModel:SetWeekRewardState( accepted )
	if self.weekRewardAccepted == accepted then return end
	self.weekRewardAccepted = accepted
	self:sendNotification( NotifyConsts.VipWeekRewardState )
end

----------------------------VIP坐骑返回--------------------------------
function VipModel:GetBackItemInfo(type)
	return self.backInfoList[type];
end

function VipModel:SetBackItemInfo( type, vo )
	self.backInfoList[type] = vo;
	self:sendNotification( NotifyConsts.VipBackInfo )
end

function VipModel:SetIsChange( type, ischange )
	if self.backInfoList[type] then
		self.backInfoList[type].ischange = ischange;
		if ischange then
			self:sendNotification( NotifyConsts.VipBackInfoChange )
		end
	end
end
--------------------福利领取个数------------------
function VipModel:GetWelfareNum()
	local t = 0;
	for level = 1, VipConsts:GetMaxVipLevel() do
		if VipModel:GetLevelRewardState( level ) then
			t =t + 1;
		end
	end
	local vipLevel = VipController:GetVipLevel();
	local num = vipLevel - t;
	if num > 0 then
		return true,num;
	else
		return false,0;
	end
end


















