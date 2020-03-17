--[[
点击任务
2015年5月27日22:31:44
haohu
]]

_G.ClickGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function ClickGoalVO:GetType()
	return QuestConsts.GoalType_Click
end

function ClickGoalVO:DoGoal(auto)
	--如果是任务引导,不弹出UI
	if auto then return; end
	local funcId = self:GetId()
	local questId = self.questVO:GetId()
	if questId == QuestConsts.WuhunCoalesceClick then -- 兽魄附体任务不是打开功能主面板，特殊处理
		UIMainSkill:OnBtnWuhunClick()
		return
	end
	if questId == QuestConsts.GetLingliClick then
		FuncManager:OpenFunc( FuncConsts.Homestead, true);
		return;
	end
	FuncManager:OpenFunc( funcId )
end

function ClickGoalVO:GetGoalLabel(size, color)
	local format = "<font size='%s' color='%s'>%s</font>"
	if not size then size = 14 end
	if not color then color = "#ffffff" end
	local strSize = tostring( size )
	local name = self:GetLabelContent()
	return string.format( format, strSize, color, name )
end

function ClickGoalVO:GetLabelContent()
	local questCfg = self.questVO:GetCfg()
	return questCfg.unFinishLink
end