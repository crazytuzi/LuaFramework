--[[
	任务提示
	yujia
]]

local s_timeCD = 4 --显示时间暂定4秒

--这里显示的四种任务类型
local s_questType = {
	[QuestConsts.Type_Trunk]  	= 1,
	[QuestConsts.Type_Day]		= 1,
	[QuestConsts.Type_Random]	= 1,
	[QuestConsts.Type_FengYao]	= 1,
}

--这里显示的条件类型
local s_questGoals = {
	[QuestConsts.GoalType_KillMonster] = 1,
	[QuestConsts.GoalType_CollectItem] = 1,
	[QuestConsts.GoalType_RandomKillMonster] = 1,
}

_G.UIQuestNotice = BaseUI:new("UIQuestNotice")
UIQuestNotice.showList = {}
UIQuestNotice.needRefresh = false

function UIQuestNotice:Create()
	self:AddSWF("taskNotice.swf", true, "bottomFloat" )
end

function UIQuestNotice:OnShow()
	self:refresh()
	self:SetUIPos()
end

function UIQuestNotice:OnResize(wWidth,wHeight)
	self:SetUIPos()
end

function UIQuestNotice:SetUIPos()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf._x = wWidth/2
	objSwf._y = wHeight/5
end

function UIQuestNotice:ShowTaskNotice(str)
	local vo = {}
	vo.str = str
	vo.startTime = GetCurTime(1)
	table.insert(self.showList, vo)
	if #self.showList > 3 then
		-- 直接只保留三条
		table.remove(self.showList, 1)
	end
	if self:IsShow() then
		self.needRefresh = true --刷新放到update 防止卡顿
	else
		self:Show()
	end
end

function UIQuestNotice:refresh()
	local objSwf = self.objSwf
	if not objSwf then return end
	local count = #self.showList
	for i = 1, 3 do
		local vo = self.showList[count + 1 - i]
		if vo then
			objSwf['list' .. i]._visible = true
			objSwf['list' .. i].txt.htmlText = vo.str
		else
			objSwf['list' ..i]._visible = false
		end
	end
end

local s_str = "[%s]%s"
function UIQuestNotice:CheckQuestNotice(quest, state)
	local label = quest:GetGoal().GetNoticeLable and quest:GetGoal():GetNoticeLable() or nil
	if not label then
		return
	end
	if s_questType[quest:GetType()] and s_questGoals[quest:GetGoalType()] then
		local cfg = quest:GetCfg()
		local name= QuestConsts:GetTypeLabel(quest:GetType())
		local str 
		if state then
			str = string.format(s_str, name, StrConfig['quest1001'])
		elseif quest:GetGoal():GetCurrCount() ~= 0 then
			str = string.format(s_str, name, label)
		end
		if str then
			self:ShowTaskNotice(str)
		end
		if quest:GetState() == QuestConsts.State_CanFinish then
			self:ShowTaskNotice(string.format(s_str, name, StrConfig['quest1002']))
		end
	end
end

function UIQuestNotice:Update()
	if not self:IsShow() then return end
	local time = GetCurTime(1)
	local bNeedRef = false
	for k, v in pairs(self.showList) do
		if time - v.startTime >= s_timeCD then
			table.remove(self.showList, k)
			bNeedRef = true
		end
	end
	if #self.showList == 0 then
		self:Hide()
		return
	end
	if bNeedRef or self.needRefresh then
		self:refresh()
	end
	return true
end