--[[
灵兽魂魄 Model
2016年1月14日15:22:35
haohu
]]

_G.ShouHunModel = Module:new()

ShouHunModel.shouHunList = {}

function ShouHunModel:Init()
	for tid, _ in pairs( ShouHunConsts.config ) do
		local shouHun = ShouHun:new(tid)
		self:AddShouHun( shouHun )
	end
end

function ShouHunModel:AddShouHun(shouHun)
	self.shouHunList[ shouHun:GetTid() ] = shouHun
end

function ShouHunModel:GetAllShouHun()
	return self.shouHunList
end

function ShouHunModel:GetShouHun(tid)
	return self.shouHunList[ tid ]
end

function ShouHunModel:GetShouHunLevel(tid)
	local shouHun = self:GetShouHun(tid)
	return shouHun and shouHun:GetLevel()
end

function ShouHunModel:SetShouHunLevel(tid, level)
	local shouHun = self:GetShouHun(tid)
	if shouHun and shouHun:SetLevel(level) then
		self:sendNotification(NotifyConsts.ShouHunLevel)
	end
end

function ShouHunModel:GetShouHunStar(tid)
	local shouHun = self:GetShouHun(tid)
	return shouHun and shouHun:GetStar()
end

function ShouHunModel:SetShouHunStar(tid, star)
	local shouHun = self:GetShouHun(tid)
	if shouHun and shouHun:SetStar(star) then
		self:sendNotification(NotifyConsts.ShouHunStar)
	end
end

ShouHunModel.autoLevelUpFunc = nil
function ShouHunModel:GetAutoLevelUpFunc()
	return self.autoLevelUpFunc
end

function ShouHunModel:SetAutoLevelUpFunc(func)
	self.autoLevelUpFunc = func
	self:sendNotification( NotifyConsts.ShouHunAutoLevelUp )
	print("SetAutoLevelUpFunc")
end

function ShouHunModel:GetFight()
	local fight = 0
	for _, shouHun in pairs(self.shouHunList) do
		fight = fight + shouHun:GetFight()
	end
	return toint(fight, 0.5)
end

function ShouHunModel:GetShouHunLinkLevel()
	local level = ShouHunConsts:GetMaxLevel()
	for _, shouHun in pairs(self.shouHunList) do
		level = math.min( level, shouHun:GetLevel() )
	end
	return level
end

function ShouHunModel:GetShouHunLinkNum(level)
	local num = 0
	for _, shouHun in pairs(self.shouHunList) do
		if shouHun:GetLevel() >= level then
			num = num + 1
		end
	end
	return num
end