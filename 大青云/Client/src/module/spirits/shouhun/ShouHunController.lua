--[[
灵兽魂魄 controller
2016年1月14日15:22:35
haohu
]]

_G.ShouHunController = setmetatable( {}, {__index = IController} )
ShouHunController.name = "ShouHunController"

function ShouHunController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_ShouHunInfo, self, self.OnShouHunInfoRcv )
	MsgManager:RegisterCallBack( MsgType.SC_ShouHunLevelUp, self, self.OnShouHunLevelUp )
	ShouHunModel:Init()
end

function ShouHunController:OnShouHunInfoRcv(msg)
	---[[
	QuestController:TestTrace("兽魂信息")
	QuestController:TestTrace(msg)
	--]]
	for _, vo in pairs( msg.list ) do
		ShouHunModel:SetShouHunStar(vo.tid, vo.star)
		ShouHunModel:SetShouHunLevel(vo.tid, vo.level)
	end
end

function ShouHunController:OnShouHunLevelUp(msg)
	---[[
	QuestController:TestTrace("返回兽魂升级")
	QuestController:TestTrace(msg)
	--]]
	if msg.result == 0 then
		ShouHunModel:SetShouHunStar(msg.tid, msg.star)
		ShouHunModel:SetShouHunLevel(msg.tid, msg.level)
		local autoLevelUp = ShouHunModel:GetAutoLevelUpFunc()
	else
		ShouHunController:StopAutoLevelUp()
	end
end

function ShouHunController:ReqShouHunLevelUp(tid)
	local shouHun = ShouHunModel:GetShouHun(tid)
	if not shouHun then return end
	if not shouHun:IsItemEnough() then
		FloatManager:AddNormal(StrConfig['shouhun13'])
		ShouHunController:StopAutoLevelUp()
		return -1
	end
	if shouHun:IsFull() then
		FloatManager:AddNormal(StrConfig['shouhun14'])
		ShouHunController:StopAutoLevelUp()
		return -2
	end
	if not self:CheckLevelDvalue(tid) then
		FloatManager:AddNormal(StrConfig['shouhun20'])
		ShouHunController:StopAutoLevelUp()
		return -3
	end
	local msg = ReqShouHunLevelUpMsg:new()
	msg.tid = tid
	MsgManager:Send(msg)
	---[[
	QuestController:TestTrace("请求兽魂升级")
	QuestController:TestTrace(msg)
	--]]
	return 0
end

function ShouHunController:CheckLevelDvalue(tid)
	local shouhun1 = ShouHunModel:GetShouHun(tid)
	local lvl = shouhun1:GetLevel()
	local minLvl = ShouHunConsts:GetMaxLevel()
	for _, sh in pairs(ShouHunModel:GetAllShouHun()) do
		minLvl = math.min( sh:GetLevel(), minLvl )
	end
	return lvl - minLvl < 3
end

function ShouHunController:StartAutoLevelUp(tid)
	local autoLvlUpFunc = function()
		local shouHun = ShouHunModel:GetShouHun(tid)
		return shouHun:LevelUp()
	end
	ShouHunModel:SetAutoLevelUpFunc( autoLvlUpFunc )
	self:ReqShouHunLevelUp(tid)
end

function ShouHunController:StopAutoLevelUp()
	ShouHunModel:SetAutoLevelUpFunc( nil )
end