--[[
主界面任务追踪树节点 : 根节点
2015年5月11日15:50:11
haohu
]]

_G.QuestNodeRoot = QuestNode:new( QuestNodeConst.Node_Root )

-- label
function QuestNodeRoot:GetLabel()
	return "root"
end