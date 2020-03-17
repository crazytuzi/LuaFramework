--[[
主界面任务追踪树节点：空节点，用于空位
2015年7月28日17:28:39
haohu
]]

_G.QuestNodeEmpty = QuestNode:new( QuestNodeConst.Node_Empty )

function QuestNodeEmpty:GetIsDisabled()
	return true
end
