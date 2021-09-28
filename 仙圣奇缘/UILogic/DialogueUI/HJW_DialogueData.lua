--------------------------------------------------------------------------------------
-- 文件名:	HJW_DialogueData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	对话  数据
-- 应  用:  
---------------------------------------------------------------------------------------


DialogueData = class("DialogueData")
DialogueData.__index = DialogueData


DialogueData.statusType = {
	begin=1,
	comeOnTheStage=2,
	ended = 3,
	helperDialogue = 4,
}

function DialogueData:getDlogueCvs(dialogueID)
	if not dialogueID or dialogueID == 0 then dialogueID = 1 end 
	local cvsDialogue = g_DataMgr:getCsvConfigByOneKey("Dialogue",dialogueID)
	return cvsDialogue
end

--对话列表 最大数
function DialogueData:dialogueContextSequence(dialogueID)
	local cvsData = self:getDlogueCvs(dialogueID)
	local nNum = 0
	for key,value in pairs(cvsData) do
		nNum = nNum + 1
	end
	return nNum
end

function DialogueData:showDialogueSequence(nDialogueID, nDialogueEvent, funDialogueEndCall, nAlpha)
	local tbParam = {
		dialogueID = nDialogueID,
		dialogueEvent = nDialogueEvent,
		speakEndFunc = funDialogueEndCall,
		alpha = nAlpha or 0
	}
	g_WndMgr:showWnd("Game_Dialogue", tbParam)
end


--[[
	获取表数据的有错误或者断层的时候读取下一个数据
]]
function DialogueData:continueOnTo(cvsDialogue,ContextSequence)
	local t = {}
	for key,value in pairs(cvsDialogue) do
		table.insert(t,key)
	end
	
	table.sort(t)  
	
	for key,value in ipairs(t) do
		if key == ContextSequence then 
			return value
		end
	end
end

function DialogueData:oneValueKeyEvent(cvsDialogue,dialogueEvent)
	local key_ = 1
	if not cvsDialogue then return key_ end 
	
	for key,value in ipairs(cvsDialogue) do
		if dialogueEvent == value.DialogueEvent then 
			key_ = key
			break
		end
	end
	return key_
end
---------------------------------------------------------------------------------
g_DialogueData = DialogueData.new()






