--[[
boss 勋章 model
haohu
2015-11-19 17:35:00
]]

_G.BossMedalModel = Module:new()

BossMedalModel.bossNumList = {}
BossMedalModel.currentPoints = 0
BossMedalModel.level     = 0
BossMedalModel.star      = 0
BossMedalModel.growValue = 0

BossMedalModel.isAutoLvUp = false

function BossMedalModel:GetBossNum(bossType)
	return self.bossNumList[bossType] or 0
end

function BossMedalModel:SetBossNum( bossType, bossNum )
	if self.bossNumList[bossType] ~= bossNum then
		self.bossNumList[bossType] = bossNum
		self:sendNotification( NotifyConsts.BossMedalBossNum, { bossType = bossType, bossNum = bossNum } )
	end
end

function BossMedalModel:GetTotalBossNum()
	local total = 0
	for _, bossNum in pairs(self.bossNumList) do
		total = total + bossNum
	end
	return total
end

function BossMedalModel:GetCurrentPoints()
	return MainPlayerModel.humanDetailInfo.eaBossPoints
end

function BossMedalModel:GetLevel()
	return self.level
end

function BossMedalModel:SetLevel(level)
	if self.level ~= level then
		self.level = level
		self:sendNotification( NotifyConsts.BossMedalLevel, level )
		return true
	end
	return false
end

function BossMedalModel:GetStar()
	if self.level == BossMedalConsts:GetMaxLevel() then
		return 0
	end
	return self.star
end

function BossMedalModel:SetStar(star)
	if self.star ~= star then
		self.star = star
		self:sendNotification( NotifyConsts.BossMedalStar, star )
	end
end

function BossMedalModel:GetGrowValue()
	return self.growValue
end

function BossMedalModel:SetGrowValue(growValue)
	if self.growValue ~= growValue then
		self.growValue = growValue
		self:sendNotification( NotifyConsts.BossMedalGrowValue, growValue )
	end
end

function BossMedalModel:IsActive()
	return self.level > 0
end

function BossMedalModel:IsFull()
	return self.level == BossMedalConsts:GetMaxLevel()
end

function BossMedalModel:SetAutoLvUp(auto)
	if self.isAutoLvUp ~= auto then
		self.isAutoLvUp = auto
		self:sendNotification( NotifyConsts.BossMedalAutoLvUp )
	end
end

function BossMedalModel:GetAutoLvUp()
	return self.isAutoLvUp
end