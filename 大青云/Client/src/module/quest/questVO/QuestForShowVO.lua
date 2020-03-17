--[[
xxx任务 ***今日已完成*** 为了造任务树节点，纯客户端使用
2015年8月17日16:19:13
haohu
]]
------------------------------------------------------------------------

_G.QuestForShowVO = setmetatable( {}, {__index = QuestVO} )

QuestForShowVO.questType = nil
QuestForShowVO.label = ""

function QuestForShowVO:new(questType, label)
	local obj = setmetatable( {}, {__index = self} )
	obj.questType = questType
	obj.label = label
	return obj
end

--任务类型
function QuestForShowVO:GetType()
	return self.questType
end

--获取快捷任务任务标题文本
function QuestForShowVO:GetTitleLabel()
	local titleFormat = "<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>" -- 中间的空格是留给任务图标的
	return string.format( titleFormat, self.label )
end

function QuestForShowVO:GetPlayRefresh()
	return false
end