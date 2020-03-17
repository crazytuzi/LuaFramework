--[[
主界面任务追踪树节点：任务描述
2015年5月11日18:16:57
haohu
]]

_G.QuestNodeDes = QuestNode:new( QuestNodeConst.Node_Des )

-- content = questVO

function QuestNodeDes:GetLabel()
	local quest = self:GetContent();
	local questCfg = quest:GetCfg()
	local shortDes = string.sub( questCfg.des, 1, 27 )
	return string.format( "%s...", shortDes )
end

-- 获取任务类型
function QuestNodeDes:GetQuestType()
	local quest = self:GetContent();
	return quest:GetType()
end
