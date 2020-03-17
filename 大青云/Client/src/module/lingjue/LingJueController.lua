--[[
灵诀 controller
haohu
2016年1月22日11:33:33
]]

_G.LingJueController = setmetatable( {}, {__index = IController} );
LingJueController.name = "LingJueController"

function LingJueController:Create()
	-- MsgManager:RegisterCallBack( MsgType.SC_LingJueInfo, self, self.OnLingJueInfoRcv )
	-- MsgManager:RegisterCallBack( MsgType.SC_LingJueLevelUp, self, self.OnLingJueLevelUp )
	LingJueModel:Init()
end

-- 灵诀阁信息
function LingJueController:OnLingJueInfoRcv(msg)
	---[[
	QuestController:TestTrace("灵诀阁信息")
	QuestController:TestTrace(msg)
	for _, vo in pairs(msg.list) do
		LingJueModel:SetLingJuePro( vo.tid, vo.level, vo.pro )
	end
	--]]
end

-- 返回灵诀阁升级(激活/参悟)
function LingJueController:OnLingJueLevelUp(msg)
	---[[
	QuestController:TestTrace("返回灵诀阁升级(激活/参悟)")
	QuestController:TestTrace(msg)
	--]]
	if msg.result == 0 then
		LingJueModel:SetLingJuePro( msg.tid, msg.level, msg.pro )
	end
end

-- 请求灵诀阁升级(激活/参悟)
function LingJueController:ReqLingJueLevelUp(tid)
	if not self:CheckLevelUpCondition(tid) then
		return
	end
	local msg = ReqLingJueLevelUpMsg:new()
	msg.tid = tid
	MsgManager:Send(msg)
	---[[
	QuestController:TestTrace("请求灵诀阁升级(激活/参悟)")
	QuestController:TestTrace(msg)
	--]]
end

function LingJueController:CheckLevelUpCondition( tid )
	local lingJue = LingJueModel:GetLingJue(tid)
	if not lingJue then
		return false
	end
	if lingJue:IsFull() then
		FloatManager:AddNormal(StrConfig['lingjue5'])
		return false
	end
	if not lingJue:IsItemEnough() then
		FloatManager:AddNormal(StrConfig['lingjue6'])
		return false
	end
	return true
end
