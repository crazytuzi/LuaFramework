local singledialog = require "ui.singletondialog"
local NpcTipsDialog = {}
setmetatable(NpcTipsDialog, singledialog)
NpcTipsDialog.__index = NpcTipsDialog
local MAX_REWRADS_ITEM_CNT = 3
local MONEY_ITEM_ID = 36984
local EXP_ITEM_ID = 36985
local questmode = 1
local answermode = 2
function NpcTipsDialog.new()
	local self = {}
	setmetatable(self, NpcTipsDialog)
	function self.GetLayoutFileName()
		return "npctipsdialog.layout"
	end
	local name_prefix = "lua"
	require "ui.dialog".OnCreate(self, nil, name_prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pNpcIcon = winMgr:getWindow(name_prefix.."NpcTipsDialog/icon")
	self.m_pNpcName = winMgr:getWindow(name_prefix.."NpcTipsDialog/name")
    
    self.m_pHiddenWndForEffect = winMgr:getWindow(name_prefix.."NpcTipsDialog/back/effect")

	self.m_pBackImage = winMgr:getWindow(name_prefix.."NpcTipsDialog/back")

	self.m_pNpcTalkBox = CEGUI.toRichEditbox(winMgr:getWindow(name_prefix.."NpcTipsDialog/RichEditBox"))
    self.m_pServersBox = CEGUI.toRichEditbox(winMgr:getWindow(name_prefix.."NpcTipsDialog/RichEditBox1"))
    
 --   self.m_pNpcTalkBox:SetTextBottomEdge(0)
 --   self.m_pNpcTalkBox:SetBackGroundEnable(false);
--	self.m_pNpcTalkBox:subscribeEvent("MouseClick", NpcTipsDialog.HandleMouseClicked, self)
    
 --   self.m_pServersBox:SetTextBottomEdge(0)
 --   self.m_pServersBox:SetBackGroundEnable(false)
-- 
  	self.m_pServersBox:EnableClickSelectLine(true)
	self.m_pServersBox:subscribeEvent("MouseClick", NpcTipsDialog.HandleMouseClicked, self)
    
    self.m_pRewardsBox = winMgr:getWindow(name_prefix.."NpcTipsDialog/back/taskinfo")
    self.m_pRewardsBox:subscribeEvent("MouseClick", NpcTipsDialog.HandleMouseClicked,self)
    self.m_pAcceptTask = CEGUI.toPushButton(winMgr:getWindow(name_prefix.."NpcTipsDialog/back/taskinfo/ok"))
    self.m_pAcceptTask:subscribeEvent("Clicked", NpcTipsDialog.HandleMouseClicked,self)
    self.m_pRewardItem = {}
    self.m_pRewardItemName = {}
    for n=1,MAX_REWRADS_ITEM_CNT do
        table.insert(self.m_pRewardItem, 
        	CEGUI.toItemCell(winMgr:getWindow(
        	name_prefix.."NpcTipsDialog/back/taskinfo/item"..n)))
        table.insert(self.m_pRewardItemName, 
        	winMgr:getWindow(
        	name_prefix.."NpcTipsDialog/back/taskinfo/name"..n))
     --   self.m_pRewardItem[n]:subscribeEvent("MouseButtonUp", CGameItemTable::HandleShowTootipsWithItemID));
    end
	self.m_pNpcName:setText("")
	self:setMode(questmode)
 --   self.m_fStandardHeight = self.m_pMainFrame:getHeight().d_scale * self.m_pMainFrame:getParentPixelHeight()
	return self
end

function NpcTipsDialog:setMode(mode)
	self.m_iMode = mode
	self.m_pServersBox:EnableClickSelectLine(mode == answermode)
end

function NpcTipsDialog:AcceptTask()
	local p = require "protocoldef.knight.gsp.task.creqmrystask":new()
    p.flag = 1
    require "manager.luaprotocolmanager":send(p)
--[[
	knight::gsp::task::CCommitScenarioQuest commitquest;
	commitquest.questid = (int)m_iAssociatedID;
	commitquest.npckey = m_npcID;
	commitquest.optionid = serviceid;
	GetNetConnection()->send(commitquest);
	--]]
end

function NpcTipsDialog:HandleMouseClicked(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e)
	if self.m_iMode == answermode then
		local pBox=CEGUI.toRichEditbox(MouseArgs.window)
		local component = pBox:GetComponentByPos(MouseArgs.position)
		if not component and pBox:isClickSelectLine() then
			component = pBox:GetLinkTextOnPos(MouseArgs.position)
		end
		local ansQuestion = require "protocoldef.knight.gsp.npc.ctgbdansquestion":new()
		ansQuestion.npckey = self.m_npcID;
		ansQuestion.questionid = self.m_iQuestID;
		ansQuestion.answer = component:GetUserID()
		require "manager.luaprotocolmanager":send(ansQuestion)
		self:DestroyDialog()
	else
		self:AcceptTask()
		self:DestroyDialog()
	end
	return true
end

function NpcTipsDialog:ParseCommitScenarioQuest(questid, hidebtn)
--	self.m_npcID = npcThisID
	self.m_iAssociatedID = questid
	local iconPath = GetIconManager():GetImagePathByID(
		knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(
		GetDataManager():GetMainCharacterShape()).headID):c_str()
	self.m_pNpcIcon:setProperty("Image",iconPath)
	self:BeginScenarioTalk()
	self.m_pRewardsBox:setVisible(not hidebtn)
end
function NpcTipsDialog:FormatNpcTalk(strMsg)
	self.m_pNpcTalkBox:Clear()
	local idx = string.find(strMsg, "<T")
	if idx then 
		self.m_pNpcTalkBox:AppendParseText(CEGUI.String(strMsg))
	else
		self.m_pNpcTalkBox:AppendText(CEGUI.String(strMsg))
	end

	self.m_pNpcTalkBox:AppendBreak()
	self.m_pNpcTalkBox:Refresh()
    self.m_pNpcTalkBox:HandleTop()
end
function NpcTipsDialog:DisplayScenarioRewards(strMsg)

    local rewardID = 0
    local idx = string.find(strMsg, "<R")
    if idx then
        local eidx = string.find(strMsg, ">")
        local id1, id2 = string.find(strMsg, "id=\"")
        if id2 then
        	rewardID = tonumber(string.sub(strMsg, id2+1, eidx-2))
        end
    end
   if rewardID and rewardID > 0 then
        self.m_pServersBox:setVisible(false)
        self.m_pRewardsBox:setVisible(true)
        
        for r_i = 1, #self.m_pRewardItem do
            self.m_pRewardItem[r_i]:SetImage(nil)
            self.m_pRewardItem[r_i]:setID(0)
            self.m_pRewardItem[r_i]:SetTextUnit("")
            self.m_pRewardItemName[r_i]:setText("")
            
            self.m_pRewardItem[r_i]:setVisible(false);
            self.m_pRewardItemName[r_i]:setVisible(false);
        end
        
        local taskreward = knight.gsp.task.GetCNpcTaskTableInstance():getRecorder(rewardID)
        if taskreward.id ~= -1 then
            for r_i = 1, taskreward.itemid:size() do
                local itemdata = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(taskreward.itemid[r_i-1])
                if itemdata.id ~= -1 then
                    self.m_pRewardItem[r_i]:setVisible(true)
                    self.m_pRewardItemName[r_i]:setVisible(true)
                    
                    if itemdata.id ~= MONEY_ITEM_ID and itemdata.id ~= EXP_ITEM_ID then
                        self.m_pRewardItem[r_i]:SetImage(GetIconManager():GetImageByID(itemdata.icon))
                        self.m_pRewardItem[r_i]:setID(itemdata.id);
                        self.m_pRewardItem[r_i]:SetTextUnit(taskreward.awardnum[r_i-1])
                        self.m_pRewardItemName[r_i]:setText(itemdata.name);
                    else
                        self.m_pRewardItem[r_i]:SetImage(GetIconManager():GetImageByID(itemdata.icon));
                        self.m_pRewardItem[r_i]:setID(itemdata.id);
                        self.m_pRewardItemName[r_i]:setText(taskreward.awardnum[r_i-1])
                    end
                end
            end
        end

    else
        self.m_pServersBox:setVisible(true);
        self.m_pRewardsBox:setVisible(false);
    end
    
    return rewardID > 0
end
function NpcTipsDialog:ToNpcSpeak(strMsg)
	self:DisplayScenarioRewards(strMsg)
end

function NpcTipsDialog:BeginScenarioTalk()
	local questinfo = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(self.m_iAssociatedID)
	if questinfo.id == -1 then
		return
	end
	self:FormatNpcTalk(questinfo.TaskInfoDescriptionListA)
    self:ToNpcSpeak(questinfo.ScenarioInfoNpcConversationList[0])
end

function NpcTipsDialog:SetNpcInfo()
	local pNpc = GetScene():FindNpcByID(self.m_npcID)
	if pNpc then
		self.m_npcBaseID = pNpc:GetNpcBaseID()
	else
		pNpc = GetScene():FindNpcByBaseID(self.m_npcBaseID)
	end

	if not pNpc then
		return false
	end

	self.m_pNpcName:setText(pNpc:GetName());
  --  CCheckDisTimer:getInstance().Schedule(self.m_npcID, eSceneNpc, this);
	local Shape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(pNpc:GetShapeID())
	local iconPath = GetIconManager():GetImagePathByID(Shape.headID);
	if iconPath == CEGUI.PropertyHelper:imageToString(GetIconManager():getDefaultIcon()) then
		 iconPath = GetIconManager():GetImagePathByID(knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(GetDataManager():GetMainCharacterShape()).headID);
	end
	self.m_pNpcIcon:setProperty("Image", iconPath:c_str())
	
	return true;
end

function NpcTipsDialog:HandleCloseDialog(e)
	self:DestroyDialog()
end

function NpcTipsDialog:ParseServerSendQuestion(lastresult, questionid, npckey)
--[[	if(self.m_eAction ~= eQuize) then
		
		--]]
		self:setMode(answermode)
		self.m_npcID = npckey
		self:SetNpcInfo()
		--[[
		self.m_eAction = eQuize
		self.m_pServersBox:subscribeEvent("WindowUpdate", CNpcDialog.HandleWindowUpdate, self)
	end
	--]]
    
    if (lastresult == 1) then           --答对
        GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(144876).msg)
    elseif (lastresult == -1) then     --答错
        GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(144877).msg)
    end
    
	if(questionid == -1) then--题目已答完
		--"今天的题你已经答完了，明天再来吧。"
		self:FormatNpcTalk(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(140710).msg);
--		self.m_eAction = eNormal;
		self.m_pServersBox:removeAllEvents();
		self.m_pServersBox:subscribeEvent("MouseClick", NpcTipsDialog.HandleMouseClicked, self)
		return;
	end
	self.m_iQuestID = questionid;
    
	self.m_pServersBox:Clear();
	--[[
	const knight::gsp::task::CTiku& question = knight::gsp::task::GetCTikuTableInstance().getRecorder(self.m_iQuestID);
	if(question.id == -1)
		return;
		--]]
	local question = knight.gsp.game.GetKeJuTestTableInstance():getRecorder(questionid)
	if not question or question.id == -1 then
		self:DestroyDialog()
		return
	end
    self.m_pNpcTalkBox:Clear();
    local idx = string.find(question.name, "<T")
	if idx then 
		self.m_pNpcTalkBox:AppendParseText(CEGUI.String(question.name));
	else
		self.m_pNpcTalkBox:AppendText(CEGUI.String(question.name));
	end
	self.m_pNpcTalkBox:AppendBreak();
    self.m_pNpcTalkBox:Refresh();
    self.m_pNpcTalkBox:getVertScrollbar():setScrollPosition(0);
    
    for i = 0, question.options:size() - 1 do
    	if (question.options[i] ~= "") then
	       	local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(question.options[i]));
			pTextLink:SetUserID(i + 1);
			self.m_pServersBox:AppendBreak();
	    end
    end
    
	self.m_pServersBox:Refresh();
	self.m_pServersBox:getVertScrollbar():setScrollPosition(0);
end

return NpcTipsDialog