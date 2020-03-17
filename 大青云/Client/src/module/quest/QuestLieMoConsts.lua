--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/11/12
    Time: 17:21
   ]]

_G.QuestLieMoConsts = {}

QuestLieMoConsts.QuestLieMoStateNone = 0; --日环任务未开启
QuestLieMoConsts.QuestLieMoStateGoing = 1; --进行中
QuestLieMoConsts.QuestLieMoStateDrawing = 2; --抽奖中
QuestLieMoConsts.QuestLieMoStateFinish = 3; --日环完成

function QuestLieMoConsts:GetLMOpenLevel()
	return t_consts[334].val1
end

function QuestLieMoConsts:GetLieMoDayNum()
	return t_consts[344].val1
end