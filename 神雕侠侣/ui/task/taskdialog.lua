require "ui.dialog"
local TASK_FIRST_COLOR = "[border='FFE79A21'][colrect='tl:FFFFFEF1 tr:FFFFFEF1 bl:FFF4D751 br:FFF4D751']"
local TASK_SECOND_COLOR = "[colrect='tl:FFF8EFF0 tr:FFF8EFF0 bl:FF1A2E4F br:FF1A2E4F']"
local SPECIAL_TASK_DONE_COLOR = "[colrect='tl:FF03EE0E tr:FF03EE0E bl:FF03EE0E br:FF03EE0E']"
local SPECIAL_TASK_FAIL_COLOR = "[colrect='tl:FFFF0000 tr:FFFF0000 bl:FFFF0000 br:FFFF0000']"

local  DailyTaskID = 1
local  ActivityTaskID = 2
local  GutTaskID = 3
local  GutBranchTaskID = 4
local  EctypTaskID = 5
local  OtherTaskID = 6

CTaskDialog = {}
setmetatable(CTaskDialog, Dialog)
CTaskDialog.__index = CTaskDialog
local _instance

function CTaskDialog.getSingleton()
	return _instance
end

function CTaskDialog.new()
	local t = {}
	setmetatable(t, CTaskDialog)
	t.__index = CTaskDialog
	t.m_iSelectedCurTaskId = 0
	t.m_iSelectedAcpTaskId = 0
	t:OnCreate()
	if GetTaskManager() then
		LogInsane("TaskManager not init")
		GetTaskManager():RegisterLuaTaskDlgFunction(CTaskDialog.RemoveAcceptableQuest, 
			CEGUI.String("CTaskDialog.RemoveAcceptableQuest"))
	end
	return t
end

function CTaskDialog.RemoveAcceptableQuest(questid)
	LogInsane("CTaskDialog.RemoveAcceptableQuest")
	if _instance == nil then
		return
	end
	if questid == nil then
		return
	end
	local item = _instance.AcceptableQuestTab.questTree:findFirstItemWithID(questid)
	local pParentItem = _instance:GetParentItemByTaskID(questid, false)
	if pParentItem then
		_instance:RemoveAcceptableQuestItem(pParentItem, item)
	end
end

function CTaskDialog:RemoveAcceptableQuestItem(pParentItem, pChildItem)
	if not self.AcceptableQuestTab.questTree:isTreeItemInList(pParentItem) then
		return
	end
	if pChildItem and self.m_iSelectedAcpTaskId == pChildItem:getID() then
		self.m_iSelectedAcpTaskId = 0;
		self.AcceptableQuestTab.infoBox:Clear()
		self.AcceptableQuestTab.infoBox:Refresh()
	end
	pParentItem:removeItem(pChildItem)
	pChildItem:delete()
	pChildItem = nil
	if pParentItem:getItemCount() == 0 then
		self:RemoveAcpFirstLevelItem()
	end
end

function CTaskDialog:RemoveAcpFirstLevelItem()
	if  self.m_pAcpActivityItem and 0 == self.m_pAcpActivityItem:getItemCount() then
         self.AcceptableQuestTab.questTree:removeItem(self.m_pAcpActivityItem);
     --    self.m_pAcpActivityItem:delete()
         self.m_pAcpActivityItem = nil
    end
    if (self.m_pAcpOtherItem and 0 == self.m_pAcpOtherItem:getItemCount()) then
         self.AcceptableQuestTab.questTree:removeItem(self.m_pAcpOtherItem)
     --    self.m_pAcpOtherItem:delete()
         self.m_pAcpOtherItem = nil
    end
    if (self.m_pAcpBranchItem and 0 == self.m_pAcpBranchItem:getItemCount()) then
         self.AcceptableQuestTab.questTree:removeItem(self.m_pAcpBranchItem)
    --     self.m_pAcpBranchItem:delete()
         self.m_pAcpBranchItem = nil
    end
end

function CTaskDialog.getSingletonDialog()
	if _instance == nil then
		_instance = CTaskDialog.new()
	end
	return _instance
end

function CTaskDialog.ToggleOpenHide()
	LogInsane("CTaskDialog.ToggleOpenHide")
	if _instance == nil then
		_instance = CTaskDialog.new()
	else
		local bVisible = _instance:IsVisible()
		if bVisible then
			_instance:OnClose();
		else
			_instance:SetVisible(true);
		end
	end
end

function CTaskDialog:OnCreate()
	Dialog.OnCreate(self)
	self.m_hUpdateLastQuest = GetTaskManager().EventUpdateLastQuest:InsertScriptFunctor(CTaskDialog.RefreshLastTask)
	self.StateNotify = LuaTaskTraceStateChangeNotify(CTaskDialog.OnTaskTraceStateChangeNotify)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pTabControl = CEGUI.toTabControl(winMgr:getWindow("TaskDialog/tabcontrol"))
	self.m_pLeftTime = winMgr:getWindow("TaskDialog/Tab 1/lefttime")
	self.m_pLeftTime:setVisible(false)
	self.CurrentQuestTab = {}
	self.CurrentQuestTab.questTree = CEGUI.toGroupBtnTree(winMgr:getWindow("TaskDialog/ctree"))
    self.CurrentQuestTab.gotoBtn = CEGUI.toPushButton(winMgr:getWindow("TaskDialog/tracebtn"))
	self.CurrentQuestTab.lefttimeTxt = winMgr:getWindow("TaskDialog/Tab 1/lefttime")
	self.CurrentQuestTab.finishTag = winMgr:getWindow("TaskDialog/Tab 1/TaskFinish")
	self.CurrentQuestTab.abandonBtn = CEGUI.toPushButton(winMgr:getWindow("TaskDialog/abandonBtn"))
	self.CurrentQuestTab.infoBox = CEGUI.toRichEditbox(winMgr:getWindow("TaskDialog/ctaskinfo"))
	
	self.AcceptableQuestTab = {}
	self.AcceptableQuestTab.EmptyDes = winMgr:getWindow("TaskDialog/Tab 2/TaskBackLeft/txt")
	self.AcceptableQuestTab.goacceptBtn = CEGUI.toPushButton(winMgr:getWindow("TaskDialog/Tab 2/go"))
	self.AcceptableQuestTab.questTree = CEGUI.toGroupBtnTree(winMgr:getWindow("TaskDialog/tree"))
	self.AcceptableQuestTab.infoBox = CEGUI.toRichEditbox(winMgr:getWindow("TaskDialog/taskinfo"))

	self.m_pTabControl:subscribeEvent("TabSelectionChanged", CTaskDialog.HandleSelectTab, self)
	
	self.CurrentQuestTab.abandonBtn:subscribeEvent("Clicked", CTaskDialog.HandleAbandonTask, self)
    self.CurrentQuestTab.gotoBtn:subscribeEvent("Clicked", CTaskDialog.HandleGoto, self)
	self.CurrentQuestTab.questTree:subscribeEvent("ItemSelectionChanged", CTaskDialog.HandleSelectedCurrentTask, self)
	
	self.AcceptableQuestTab.questTree:subscribeEvent("ItemSelectionChanged", CTaskDialog.HandleSelectedAcpTask, self)
    self.AcceptableQuestTab.goacceptBtn:subscribeEvent("Clicked", CTaskDialog.HandleAcceptBtnClicked, self)
    
	self.CurrentQuestTab.infoBox:setReadOnly(true)
	self.CurrentQuestTab.infoBox:SetBackGroundEnable(false)
	self.CurrentQuestTab.infoBox:SetLineSpace(4.0)
	
	self.AcceptableQuestTab.infoBox:setReadOnly(true)
	self.AcceptableQuestTab.infoBox:SetBackGroundEnable(false)
	self.AcceptableQuestTab.infoBox:SetLineSpace(4.0)
	self.m_pMainFrame:subscribeEvent("WindowUpdate", CTaskDialog.HandleWindowUpdate, self)
	
	self.m_pTabControl:setSelectedTabAtIndex(0)
	self:UpdateCurrentTaskList()
	self:UpdateAcceptableTaskList()
end

function CTaskDialog.RefreshLastTask(taskid)
	local self = _instance
	if self == nil then
		return
	end
	if self.m_pTabControl:getSelectedTabIndex() ~= 0 then
		self.m_pTabControl:setSelectedTabAtIndex(0)
	end
	self:RefreshQuestItem(taskid)
end

function CTaskDialog:RefreshQuestItem(questid)
	local pParentItem = self:GetParentItemByTaskID(questid, true)
	if pParentItem == nil then
		return
	end
	local item = self.CurrentQuestTab.questTree:findFirstItemWithID(questid)
	local queststate = 0
	local name = ""
	local pSpecialquest
	local pActivequest
	local pScenarioQuest
	pSpecialquest = GetTaskManager():GetSpecialQuest(questid)
	if pSpecialquest then
		queststate = pSpecialquest.queststate
		name = pSpecialquest.name
	end
	
	if queststate == 0 then
		pActivequest = GetTaskManager():GetReceiveQuest(questid)
		if pActivequest then
			local config = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(questid)
			if config.id == -1 then
				return
			end
			queststate = pActivequest.queststate
			name = config.questname
		end
	end
	LogInsane("Refresh pActivequest Quest status="..queststate)
	if queststate == 0 then
		pScenarioQuest = GetTaskManager():GetScenarioQuest(questid)
		if pScenarioQuest then
			local questinfo = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(questid)
			if questinfo.id == -1 then
				return
			end
			queststate = pScenarioQuest.queststatus
			LogInsane("Refresh Scenario Quest status="..queststate)
			local firstpos = string.find(questinfo.MissionName, "%$", 0)
			if firstpos then
				name = string.sub(questinfo.MissionName, 0, firstpos - 1)
			else
				name = questinfo.MissionName
			end
		end
	end
	LogInsane("Refresh Scenario2 Quest status="..queststate)
	if queststate == 0 then
		self:RemoveQuestItem(pParentItem, item)
		return
	end
	
	if item == nil then
		item = pParentItem:addItem(CEGUI.String(name), questid)
		self:SetSecondItemIcon(item)
	else
		item:setText(CEGUI.String(name))
	end
	
	local m_pCurrentTree = self.CurrentQuestTab.questTree
	m_pCurrentTree:SetLastOpenItem(pParentItem)
	m_pCurrentTree:SetLastSelectItem(item)
	self:RefreshItemNameAndColour(item, queststate)
	self.m_iSelectedCurTaskId = questid
	m_pCurrentTree:invalidate()
end

function CTaskDialog:RemoveQuestItem(pParentItem, pChildItem)
	LogInsane("CTaskDialog:RemoveQuestItem")
	local m_pCurrentTree = self.CurrentQuestTab.questTree
	local m_pCurrentTaskIntro = self.CurrentQuestTab.infoBox
	if not m_pCurrentTree:isTreeItemInList(pParentItem) then
		return
	end
	
	local taskid = pChildItem and pChildItem:getID() or 0
	LogInsane(string.format("plz remove task id=%d, curtaskid=%d", taskid, self.m_iSelectedCurTaskId))
	local pChildItem = self.CurrentQuestTab.questTree:findFirstItemWithID(taskid)
	if pChildItem and self.m_iSelectedCurTaskId == taskid then
		self.m_iSelectedCurTaskId = 0
		m_pCurrentTaskIntro:Clear()
		m_pCurrentTaskIntro:Refresh()
		self.CurrentQuestTab.finishTag:setVisible(false)
		self.CurrentQuestTab.gotoBtn:setVisible(false)
		self.CurrentQuestTab.abandonBtn:setVisible(false)
	end
	
	pParentItem:removeItem(pChildItem)
	if pChildItem then
		pChildItem:delete()
	end
	pChildItem = nil
	if pParentItem:getItemCount() == 0 then
		self:RemoveCurFirstLevelItem()
	end
	
	if taskid == knight.gsp.specialquest.SpecialQuestID.schoolquestid or
		taskid == knight.gsp.specialquest.SpecialQuestID.huaxiaziquestid or
		taskid == knight.gsp.specialquest.SpecialQuestID.qihuaquestid or
		taskid == knight.gsp.specialquest.SpecialQuestID.wujuelingtask or
		taskid == knight.gsp.specialquest.SpecialQuestID.demonslayerquestid or
		taskid == knight.gsp.specialquest.SpecialQuestID.techanquestid then
		local item = self.AcceptableQuestTab.questTree:findFirstItemWithID(taskid)
		if item then
			GetTaskManager():AppendAcceptQuestName(taskid, item)
			self.AcceptableQuestTab.questTree:invalidate()
		end
	elseif taskid == knight.gsp.specialquest.SpecialQuestID.wujuelingtask21 then
		local item = self.AcceptableQuestTab.questTree:findFirstItemWithID(
			knight.gsp.specialquest.SpecialQuestID.wujuelingtask)
		if item then
			GetTaskManager():AppendAcceptQuestName(knight.gsp.specialquest.SpecialQuestID.wujuelingtask, item)
			self.AcceptableQuestTab.questTree:invalidate()
		end
	end
end

function CTaskDialog:RemoveCurFirstLevelItem()
	LogInsane("CTaskDialog:RemoveCurFirstLevelItem")
	local pParentItem = self.CurrentQuestTab.questTree
	if self.m_pDailyItem and self.m_pDailyItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pDailyItem)
		self.m_pDailyItem = nil
	end
	if self.m_pActivityItem and self.m_pActivityItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pActivityItem)
		self.m_pActivityItem = nil
	end
	if self.m_pOtherItem and self.m_pOtherItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pOtherItem)
		self.m_pOtherItem = nil
	end
	if self.m_pScenarioItem and self.m_pScenarioItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pScenarioItem)
		self.m_pScenarioItem = nil
	end
	if self.m_pBranchItem and self.m_pBranchItem:getItemCount() == 0 then
		LogInsane("Remove self.m_pBranchItem")
		pParentItem:removeItem(self.m_pBranchItem)
		self.m_pBranchItem = nil
	end
	if self.m_pEctypItem and self.m_pEctypItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pEctypItem)
		self.m_pEctypItem = nil
	end
end

function CTaskDialog.OnTaskTraceStateChangeNotify(questid)
	local self = _instance
	if self == nil then
		return
	end
end

function CTaskDialog:SetFirstItemIcon(pItem)
    pItem:seNormalImage(CEGUI.String("MainControl3"), CEGUI.String("TrackNormal"))
    pItem:setSelectionImage(CEGUI.String("MainControl3"),CEGUI.String("TrackPushed"))
    pItem:setOpenImage(CEGUI.String("MainControl3"),CEGUI.String("TrackPushed"))
end
 
function CTaskDialog:SetSecondItemIcon(pItem)
    pItem:seNormalImage(CEGUI.String("MainControl3"), CEGUI.String("TrackLittleNormal"))
     pItem:setSelectionImage(CEGUI.String("MainControl3"), CEGUI.String("TrackLittlePushed"))
     pItem:setOpenImage(CEGUI.String("MainControl3"), CEGUI.String("TrackLittleNormal"))
     pItem:setHoverImage(CEGUI.String("MainControl3"), CEGUI.String("TrackLittleNormal"))
end

function CTaskDialog:RefreshItemNameAndColour(pItem, queststate)
	if queststate == knight.gsp.specialquest.SpecialQuestState.DONE then
        pItem:setTextColours(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF03EE0E")))
        pItem:setBoardColor(CEGUI.PropertyHelper:stringToColour("FF0F3F0F"))
	elseif queststate == knight.gsp.specialquest.SpecialQuestState.FAIL then
        pItem:setTextColours(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFF0000")))
        pItem:setBoardColor(CEGUI.PropertyHelper:stringToColour("FF3E3E3E"))
	else
        pItem:setTextColours(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFF8EFF0"), 
        	CEGUI.PropertyHelper:stringToColour("FFF8EFF0"), 
        	CEGUI.PropertyHelper:stringToColour("FF1A2E4F"), 
       		CEGUI.PropertyHelper:stringToColour("FF1A2E4F")))
        pItem:setBoardColor(CEGUI.PropertyHelper:stringToColour("FF3E3E3E"))
	end
end

function CTaskDialog:AddQuestItem(pParentItem, text, item_id, boardcol)
	if pParentItem == nil then
		LogInsane("nil parent item")
		return
	end

	if not self.CurrentQuestTab.questTree:isTreeItemInList(pParentItem) then
		LogInsane("add quest item")
		self.CurrentQuestTab.questTree:addItem(pParentItem)
	end
	item_id = item_id or 0
	boardcol = boardcol or CEGUI.PropertyHelper:stringToColour("FF5F4100")
	pParentItem:addItem(text)
    self.CurrentQuestTab.questTree:invalidate()
end

function CTaskDialog:GetParentItemByTaskID(taskid, bCurrentTree)
	local parentitemid = GetTaskManager():GetTaskType(taskid)
	LogInsane("parentitemid="..parentitemid)
	local tree
	if bCurrentTree then
		tree = self.CurrentQuestTab.questTree
	else
		tree = self.AcceptableQuestTab.questTree
	end
	if parentitemid == DailyTaskID then
        if bCurrentTree then
            if not self.m_pDailyItem then
                local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(240)
                self.m_pDailyItem = tree:addItem(CEGUI.String(title), DailyTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pDailyItem);
            end
            return self.m_pDailyItem;
        end
        return nil;
	elseif parentitemid == ActivityTaskID then
        if bCurrentTree then
            if not self.m_pActivityItem then
                local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(241)
                self.m_pActivityItem = tree:addItem(CEGUI.String(title), ActivityTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pActivityItem)
            end
            return self.m_pActivityItem;
        else
        	if not self.m_pAcpActivityItem then
                local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(241)
                self.m_pAcpActivityItem = tree:addItem(CEGUI.String(title), ActivityTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pAcpActivityItem)
            end
            return self.m_pAcpActivityItem;
        end
	elseif parentitemid == GutTaskID then
        if bCurrentTree then
        	LogInsane("add scenrio task")
            if not self.m_pScenarioItem then
            	local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(243)
            	self.m_pScenarioItem = tree:addItem(CEGUI.String(title), GutTaskID, 
            		CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pScenarioItem);
            end
            return self.m_pScenarioItem;
        else
            if not self.m_pAcpBranchItem then
                local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(244)
                self.m_pAcpBranchItem = tree:addItem(CEGUI.String(title), GutBranchTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pAcpBranchItem);
            end
            return self.m_pAcpBranchItem;
        end
	elseif parentitemid == GutBranchTaskID then
        if bCurrentTree then
            if not self.m_pBranchItem then
            	local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(244)
                self.m_pBranchItem = tree:addItem(CEGUI.String(title), GutBranchTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pBranchItem);
            end
            return self.m_pBranchItem;
        else
            if not self.m_pAcpBranchItem then
                local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(244);
                self.m_pAcpBranchItem = tree:addItem(CEGUI.String(title), GutBranchTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pAcpBranchItem)
            end
            return self.m_pAcpBranchItem;
        end
	elseif parentitemid == EctypTaskID then
        if bCurrentTree then
            if not self.m_pEctypItem then
                local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(245);
                self.m_pEctypItem = tree:addItem(CEGUI.String(title), EctypTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pEctypItem);
            end
            return self.m_pEctypItem;
        else
            if not self.m_pAcpOtherItem then
            	local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(242);
                self.m_pAcpOtherItem = tree:addItem(CEGUI.String(title), OtherTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pAcpOtherItem);
            end
            return self.m_pAcpOtherItem;
        end
	elseif parentitemid == OtherTaskID then
        if bCurrentTree then
            if not self.m_pOtherItem then
            	local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(242);
                self.m_pOtherItem = tree:addItem(CEGUI.String(title), OtherTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pOtherItem);
            end
            return self.m_pOtherItem;
        else
            if not self.m_pAcpOtherItem then
                local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(242);
                self.m_pAcpOtherItem = tree:addItem(CEGUI.String(title), OtherTaskID, 
            			CEGUI.PropertyHelper:stringToColour("0"))
                self:SetFirstItemIcon(self.m_pAcpOtherItem);
            end
            return self.m_pAcpOtherItem;
        end
	else
		return nil
	end
end


function CTaskDialog:UpdateCurrentTaskList()
	--先添加师门、天尊等特殊任务

	local specialquests = std.vector_stSpecialQuest_()
	GetTaskManager():GetSpecailQuestForLua(specialquests)
	local specialquestnum = specialquests:size()
	for i = 0, specialquestnum - 1 do
		local specialquest = specialquests[i]
		if specialquest.questtype ~= 0 then
	        if self.m_pDailyItem == nil then
	            local title = TASK_FIRST_COLOR..MHSD_UTILS.get_resstring(240)
	            self.m_pDailyItem = self.CurrentQuestTab.questTree:addItem(CEGUI.String(title),DailyTaskID,
	            	CEGUI.PropertyHelper:stringToColour("0"))
	            self:SetFirstItemIcon(self.m_pDailyItem);
	        end
	        local dailyChild = self.m_pDailyItem:addItem(CEGUI.String(specialquest.name), specialquest.questid)
	        self:SetSecondItemIcon(dailyChild)
			self:RefreshItemNameAndColour(dailyChild, specialquest.queststate)
        end
	end
	--添加剧情任务
	local scenarioquests = std.vector_knight__gsp__task__ScenarioQuestInfo_()
	GetTaskManager():GetScenarioQuestListForLua(scenarioquests)
	local scenarioquestnum = scenarioquests:size()
	for i = 0, scenarioquestnum - 1 do
		local scenarioquest = scenarioquests[i]
		LogInsane("add scenarioquest id ="..scenarioquest.questid)
		local questinfo = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(scenarioquest.questid)
		if questinfo.id ~= -1 then
		--	local dailyChild = CEGUI.GroupBtnItem(CEGUI.String(questinfo.MissionName),questinfo.id)
	       
			local pParentItem = self:GetParentItemByTaskID(questinfo.id, true)
			local dailyChild = pParentItem:addItem(CEGUI.String(questinfo.MissionName), questinfo.id)
	 		self:SetSecondItemIcon(dailyChild)
			self:RefreshItemNameAndColour(dailyChild, scenarioquest.queststatus)
		--	self:AddQuestItem(pParentItem,dailyChild,questinfo.id)
		end	
	end

	local quests = std.vector_knight__gsp__specialquest__ActiveQuestData_()
	GetTaskManager():GetReceiveQuestListForLua(quests)
	local questnum = quests:size()
	for i = 0, questnum - 1 do
		local quest = quests[i]
		local questid = quest.questid
		local config = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(questid)
		if config.id ~= -1 then
			local pParentItem = self:GetParentItemByTaskID(questid, true)
			local child = pParentItem:addItem(CEGUI.String(config.questname),questid)
	        self:SetSecondItemIcon(child)
			self:RefreshItemNameAndColour(child, quest.queststate)
		end
	end
	
	local lastselectid = GetTaskManager():GetLastSelectedTask()
	LogInsane("last selectid"..lastselectid)
	local item = self.CurrentQuestTab.questTree:findFirstItemWithID(lastselectid)
	if item == nil then
		LogInsane("try select daily item")
		if not self:DefaultSelectItem(self.m_pDailyItem) then
			LogInsane("try select activity item")
			if not self:DefaultSelectItem(self.m_pActivityItem) then
				LogInsane("try select ectyp item")
				if not self:DefaultSelectItem(self.m_pEctypItem) then
					LogInsane("try select other item")
					if not self:DefaultSelectItem(self.m_pOtherItem) then
						LogInsane("try select scenario item")
						if not self:DefaultSelectItem(self.m_pScenarioItem) then
							LogInsane("try select branch item")
							self:DefaultSelectItem(self.m_pBranchItem)
						end
					end
				end
			end
		end
	else
		self.m_iSelectedCurTaskId = lastselectid
		self:DefaultSelectItem(nil, item)
	end
end

function CTaskDialog:DefaultSelectItem(pParentItem, pChildItem)
	LogInsane("CTaskDialog:DefaultSelectItem")
	if self.m_iSelectedCurTaskId ~= 0 and pParentItem then
		return false
	end
	LogInsane("Enter CTaskDialog:DefaultSelectItem")
	if pParentItem and pParentItem:getItemCount() > 0 then
		LogInsane("Get First Tree Item")
		local pItem = pParentItem:getTreeItemFromIndex(0);
		if pItem then
			self.m_iSelectedCurTaskId = pItem:getID()
			LogInsane("First questid"..pItem:getID())
            self.CurrentQuestTab.questTree:SetLastOpenItem(pParentItem);
            self.CurrentQuestTab.questTree:SetLastSelectItem(pItem);
            self.CurrentQuestTab.questTree:invalidate();
			self:RefreshQuestIntro(self.m_iSelectedCurTaskId);
			return true;
		end
	else 
		if pChildItem and self.m_iSelectedCurTaskId then
	 		local pParentItem = self:GetParentItemByTaskID(self.m_iSelectedCurTaskId, true)
	 		if not pParentItem then
	 			LogInsane("Not find questid "..self.m_iSelectedCurTaskId.."parent item")
	 			return true
	 		end
	 		LogInsane("Selected questid"..self.m_iSelectedCurTaskId)
	        self.CurrentQuestTab.questTree:SetLastOpenItem(pParentItem);
	        self.CurrentQuestTab.questTree:SetLastSelectItem(pChildItem);
	        self.CurrentQuestTab.questTree:invalidate();
			self:RefreshQuestIntro(self.m_iSelectedCurTaskId);
		end
	end

	return false;
end

function CTaskDialog:RefreshCommonQuestIntro(taskid, activequest)
	LogInsane("CTaskDialog:RefreshCommonQuestIntro")
	if activequest == nil then
		return
	end
	--任务失败特殊处理
	if activequest.queststate== knight.gsp.specialquest.SpecialQuestState.FAIL then
	end

	local sb = StringBuilder:new()
	local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(activequest.dstnpcid)
	local mapcongig
	if activequest.dstmapid == 0 and npcConfig.id ~= -1 then
		 mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(npcConfig.mapid)
		 sb:SetNum("xPos",npcConfig.xPos);
		 sb:SetNum("yPos",npcConfig.yPos);
		 sb:SetNum("mapid",npcConfig.mapid);
	else if activequest.dstmapid > 0 then
			mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(activequest.dstmapid)
			sb:SetNum("mapid",activequest.dstmapid)
			sb:SetNum("xPos",activequest.dstx)
			sb:SetNum("yPos",activequest.dsty)	
		else
			sb:SetNum("mapid",0)
			sb:SetNum("xPos",0)
			sb:SetNum("yPos",0)
		end
	end
	sb:Set("MapName",mapcongig and mapcongig.mapName or "")
	sb:SetNum("xjPos",mapcongig and mapcongig.xjPos or 0)
	sb:SetNum("yjPos",mapcongig and mapcongig.yjPos or 0)
	sb:SetNum("npcid",activequest.dstnpcid)
	
	sb:SetNum("Number",activequest.sumnum)
	sb:SetNum("Number1",activequest.dstitemid)
	sb:SetNum("Number2",activequest.sumnum)
	sb:SetNum("Number3",activequest.rewardsmoney)--环任务当前轮数
    sb:SetNum("NpcKey",activequest.dstnpckey);
    sb:SetNum("DstX",activequest.dstx);
    sb:SetNum("DstY",activequest.dsty);


	local npcAll = knight.gsp.npc.GetCNpcInAllTableInstance():getRecorder(activequest.dstnpcid)
	if not CEGUI.String(activequest.npcname):empty() then
		sb:Set("NPCName",activequest.npcname)
	else
		sb:Set("NPCName",npcAll.name)
	end

	local config = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(taskid);
	local items = std.vector_knight__gsp__specialquest__RewardItemUnit_()
	self:ShowQuestIntro(config.name,sb:GetString(config.aim),sb:GetString(config.discribe),0,0,0,items)
	self:SetFinishImageVisibleState(activequest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE)
    
    sb:delete()
end

function CTaskDialog:RefreshScenarioQuestIntro(taskid, quest)
	LogInsane("CTaskDialog:RefreshScenarioQuestIntro")
	if quest == nil then
		return
	end
	local m_pCurrentTaskIntro = self.CurrentQuestTab.infoBox
	local questinfo = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(taskid)
	if questinfo.id == -1 then
		m_pCurrentTaskIntro:Clear()
		m_pCurrentTaskIntro:Refresh()
		return;
	end
	local items = std.vector_knight__gsp__specialquest__RewardItemUnit_()
	for i = 0, questinfo.RewardItemIDList:size() - 1 do
		--奖励的道具与主角造型匹配时，才显示道具
		local bShowItem = true;
		if i < questinfo.RewardItemShapeIDList:size() then
			if questinfo.RewardItemShapeIDList[i] > 0 and questinfo.RewardItemShapeIDList[i] <=10 then
				if questinfo.RewardItemShapeIDList[i] ~= GetDataManager():GetMainCharacterCreateShape() then
					bShowItem = false
				end
			end
		end
		
		if bShowItem then
			local unit = knight.gsp.specialquest.RewardItemUnit()
			unit.baseid = questinfo.RewardItemIDList[i]
			LogInsane("unit baseid="..unit.baseid)
			unit.num = questinfo.RewardItemNumList[i]
		--	LogInsane("unit num="..unit.num)
			items:push_back(unit)
		--	LogInsane("unit pushed")
		end
	end

	local sb = StringBuilder:new()
	sb:SetNum("number", quest.questvalue)
	sb:Set("NAME",GetDataManager():GetMainCharacterName())
	self:ShowQuestIntro(questinfo.MissionName,sb:GetString(questinfo.TaskInfoPurposeListA),sb:GetString(questinfo.TaskInfoDescriptionListA),
			questinfo.ExpReward,questinfo.MoneyReward,questinfo.SMoney,items);
	self:SetFinishImageVisibleState(quest.queststatus == knight.gsp.specialquest.SpecialQuestState.DONE)
    sb:delete()
end

function CTaskDialog:SetFinishImageVisibleState(bVisible)
	self.CurrentQuestTab.finishTag:setVisible(bVisible)
end

function CTaskDialog:RefreshQuestIntro(taskid)
	local pSpecialQuest = GetTaskManager():GetSpecialQuest(taskid)
	if pSpecialQuest then
		self:RefreshSpecialQuestIntro(taskid, pSpecialQuest)
		self.CurrentQuestTab.gotoBtn:setVisible(true)
		self.CurrentQuestTab.abandonBtn:setVisible(true)
		return
	end
	
	local activequest = GetTaskManager():GetReceiveQuest(taskid)
	if activequest then
		self:RefreshCommonQuestIntro(taskid, activequest)
		self.CurrentQuestTab.gotoBtn:setVisible(true)
		self.CurrentQuestTab.abandonBtn:setVisible(true)
		return
	end
	
	local pScenarioQuest = GetTaskManager():GetScenarioQuest(taskid)
	if pScenarioQuest then
		self:RefreshScenarioQuestIntro(taskid, pScenarioQuest)
		self.CurrentQuestTab.gotoBtn:setVisible(true)
		self.CurrentQuestTab.abandonBtn:setVisible(true)
	end
end

function CTaskDialog:ShowQuestIntro(name, aim, discribe, exp, money, smoney, items)
	LogInsane("CTaskDialog:ShowQuestIntro"..name)
	local m_pCurrentTaskIntro = self.CurrentQuestTab.infoBox
	m_pCurrentTaskIntro:Clear()
	m_pCurrentTaskIntro:AppendImage(CEGUI.String("MainControl"),CEGUI.String("TaskName"))
	m_pCurrentTaskIntro:AppendBreak()
	m_pCurrentTaskIntro:AppendText(CEGUI.String("　"..name))
	--任务目的
	m_pCurrentTaskIntro:AppendText(CEGUI.String(" "))
	m_pCurrentTaskIntro:AppendBreak()

	m_pCurrentTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("TaskGoal"))
	m_pCurrentTaskIntro:AppendBreak()

	m_pCurrentTaskIntro:AppendText(CEGUI.String("　"))
	m_pCurrentTaskIntro:AppendParseText(CEGUI.String(aim))


	m_pCurrentTaskIntro:AppendText(CEGUI.String(" "))
	m_pCurrentTaskIntro:AppendBreak()

	--任务描述	
	m_pCurrentTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("TaskDescription"))
	m_pCurrentTaskIntro:AppendBreak()

	m_pCurrentTaskIntro:AppendText(CEGUI.String("　"))
	m_pCurrentTaskIntro:AppendParseText(CEGUI.String(discribe))


	--判断是否有任务奖励pFS
	
	if exp > 0 or money >0 or smoney > 0 or items:size() ~= 0 then
		m_pCurrentTaskIntro:AppendText(CEGUI.String(" "))
		m_pCurrentTaskIntro:AppendBreak()

		m_pCurrentTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("TaskAward"))
		m_pCurrentTaskIntro:AppendBreak()
		
		if exp > 0 then
			m_pCurrentTaskIntro:AppendText(CEGUI.String("　"))
			m_pCurrentTaskIntro:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(250)..exp),
				CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFEF42")))
			m_pCurrentTaskIntro:AppendImage(CEGUI.String("MainControl"),CEGUI.String("Exp"))
			m_pCurrentTaskIntro:AppendBreak()
		end
		
		if money > 0 then
			m_pCurrentTaskIntro:AppendText(CEGUI.String("　"))
			m_pCurrentTaskIntro:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(251)..money), 
				CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFEF42")))
			m_pCurrentTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("Xianjin"))
			m_pCurrentTaskIntro:AppendBreak();
		end
		
		if smoney > 0 then
			m_pCurrentTaskIntro:AppendText(CEGUI.String("　"));
			m_pCurrentTaskIntro:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(252)..smoney),
				CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFEF42")))
			m_pCurrentTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("Chubeijin"))
			m_pCurrentTaskIntro:AppendBreak()
		end
		
		if items:size() ~= 0 then
			m_pCurrentTaskIntro:AppendText(CEGUI.String("　"))
			m_pCurrentTaskIntro:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(253)),
				CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFEF42")))
			for i = 0, items:size() - 1 do
				local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(items[i].baseid)
				local pIcon = GetIconManager():GetItemIconByID(itemattr.icon)
				if pIcon then
					m_pCurrentTaskIntro:AppendImage(pIcon,items[i].baseid,items[i].num)
					m_pCurrentTaskIntro:AppendText(CEGUI.String("    "))
				end
			end
		end
		
		m_pCurrentTaskIntro:AppendText(CEGUI.String(" "))
		m_pCurrentTaskIntro:AppendBreak()
	end
	
	m_pCurrentTaskIntro:Refresh()
	m_pCurrentTaskIntro:getVertScrollbar():setScrollPosition(0)
	--self:RefreshTaskLeftTime();
end

function CTaskDialog:ShowFailQuestIntro(taskid)
    local config = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(taskid)
    local failconfig = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(1000)
    if config.id == -1 or failconfig.id == -1 then
        return
    end
    
    local items = std.vector_knight__gsp__specialquest__RewardItemUnit_()
    self:ShowQuestIntro(config.name, failconfig.aim, failconfig.discribe, 0, 0, 0, items)
    self.CurrentQuestTab.finishTag:setVisible(false);
end

function CTaskDialog:RefreshSpecialQuestIntro(taskid, quest)
	LogInsane("CTaskDialog:RefreshSpecialQuestIntro")
 	if quest == nil then
 		LogInsane("the Special quest is nil")
 		return
 	end
	--任务失败特殊处理
	if quest.queststate == knight.gsp.specialquest.SpecialQuestState.FAIL then
		self:ShowFailQuestIntro(quest.questtype)	
		return
	end
 	
	local sb = StringBuilder.new()
	if taskid == knight.gsp.specialquest.SpecialQuestID.factiondailyquestid then
		--帮派日常任务，round代表轮数，sumnum代表次数
		sb:SetNum("Number", quest.sumnum)
		sb:SetNum("round", quest.round)
	else
		sb:SetNum("Number", quest.round)
	end
	local temptype = quest.questtype
	
	if taskid == knight.gsp.specialquest.SpecialQuestID.schoolquestid and 
	   quest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then --师门任务完成后，任务目的需要更换
		temptype = temptype + 20
		local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
		sb:Set("NPCName",npcConfig.name)
		sb:SetNum("npcid", quest.dstnpcid)
	end
	if quest.questtype == knight.gsp.specialquest.SpecialQuestType.BuyItem then -- 买道具
		local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(quest.dstitemid)
		sb:Set("ItemName", itemattr.name)
		sb:SetNum("ItemLevel", itemattr.level)
		local strType = knight.gsp.item.GetCItemTypeTableInstance():getRecorder(itemattr.itemtypeid).name
		sb:Set("ItemType",strType)
	else
		if taskid == knight.gsp.specialquest.SpecialQuestID.factiondailyquestid and
			quest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then--帮派日常任务完成
			temptype = temptype + 10
			local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
			sb:Set("NPCName",npcConfig.name)
			sb:SetNum("mapid",npcConfig.mapid)	
			sb:SetNum("xPos",npcConfig.xPos)
			sb:SetNum("yPos",npcConfig.yPos)
			sb:SetNum("npcid",quest.dstnpcid)
		else
			if temptype == knight.gsp.specialquest.SpecialQuestType.Mail then -- 送信
				local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
				sb:Set("NPCName", npcConfig.name)
				
				local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(npcConfig.mapid)
				sb:Set("MapName",mapcongig.mapName)
				sb:SetNum("xjPos",mapcongig.xjPos)
				sb:SetNum("yjPos",mapcongig.yjPos)
		
				sb:SetNum("mapid",npcConfig.mapid)
				sb:SetNum("xPos",npcConfig.xPos)
				sb:SetNum("yPos",npcConfig.yPos)
				sb:SetNum("npcid",quest.dstnpcid)
			elseif temptype == knight.gsp.specialquest.SpecialQuestType.Rescue -- 援救
			or temptype == knight.gsp.specialquest.SpecialQuestType.Tame -- 降服
			or temptype == knight.gsp.specialquest.SpecialQuestType.ChuanDiXiaoXi then --传递消息
				local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(quest.dstmapid)
				sb:Set("MapName",mapcongig.mapName)
				sb:SetNum("xjPos",mapcongig.xjPos)
				sb:SetNum("yjPos",mapcongig.yjPos)
	
				sb:SetNum("mapid",quest.dstmapid)	
				sb:SetNum("xPos",quest.dstx)
				sb:SetNum("yPos",quest.dsty)
			elseif temptype == knight.gsp.specialquest.SpecialQuestType.TZFindNpc -- 天尊寻人
			or temptype == knight.gsp.specialquest.SpecialQuestType.TZFight --天尊战斗
			or temptype == 802009 --天尊答题
			or temptype == knight.gsp.specialquest.SpecialQuestType.TZWaBao-- 天尊挖宝
			or temptype == knight.gsp.specialquest.SpecialQuestType.FactionFinghtDouDou-- 帮派日常任务-厉兵秣马一（打败豆豆）
			or temptype == knight.gsp.specialquest.SpecialQuestType.FactionMaze-- 帮派日常任务-帮派迷宫
			then
				if temptype == knight.gsp.specialquest.SpecialQuestType.TZFight
					and quest.round == 30 then --行侠仗义第30环任务
					temptype = temptype + 10
				end

				local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid);
				sb:Set("NPCName",npcConfig.name);
				sb:SetNum("xPos",npcConfig.xPos);
				sb:SetNum("yPos",npcConfig.yPos);
				sb:SetNum("mapid",npcConfig.mapid);	
				sb:SetNum("npcid",quest.dstnpcid);
			elseif temptype == knight.gsp.specialquest.SpecialQuestType.TZBuyItem then --行侠仗义 寻物
				if quest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then --完成任务后，任务目的需要更换
					temptype = temptype + 10			
					local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(quest.dstitemid)
					sb:Set("ItemName", itemattr.name)
					local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
					sb:Set("NPCName",npcConfig.name)
					sb:SetNum("npcid",quest.dstnpcid)
				else
					--find map according to level
					local level = GetDataManager():GetMainCharacterLevel();
					local id = 0;
			    	if level < 100 then
			    		id = level - level % 5; 
			    	elseif level < 120 then
			    		id = level - level % 2;
			    	else
			    		id = 120;
			    	end
					local maps = BeanConfigManager.getInstance():
								GetTableByName("knight.gsp.specialquest.ctianzunchuanshuo"):getRecorder(id);	
					local mapid1 = maps.mapids[0]
					local mapid2 = maps.mapids[1]
	
					local mapcongig1 = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(mapid1);
					sb:Set("MapName1", mapcongig1.mapName)
					sb:SetNum("mapid1", mapid1)
					sb:SetNum("xjPos1", mapcongig1.xjPos)
					sb:SetNum("yjPos1", mapcongig1.yjPos)
					local mapcongig2 = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(mapid2);
					sb:Set("MapName2", mapcongig2.mapName)
					sb:SetNum("mapid2", mapid2)
					sb:SetNum("xjPos2", mapcongig2.xjPos)
					sb:SetNum("yjPos2", mapcongig2.yjPos)
	
					local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(quest.dstitemid);
					sb:Set("ItemName", itemattr.name);
					local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid);
					sb:Set("NPCName",npcConfig.name);
	
					sb:SetNum("npcid2",quest.dstnpcid);	
					sb:SetNum("npcid",quest.dstnpcid);
				end
			elseif temptype == 802008 then --行侠仗义 传递消息
				if quest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then
					temptype = temptype + 10
					local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid);
					sb:Set("NPCName", npcConfig.name)
					sb:SetNum("npcid", quest.dstnpcid)
				else
					local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(quest.dstmapid)
					local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
					sb:Set("MapName", mapcongig.mapName)
					sb:Set("NPCName", npcConfig.name)
					sb:SetNum("mapid", quest.dstmapid)
					sb:SetNum("xPos", quest.dstx)
					sb:SetNum("yPos", quest.dsty)
				end

			elseif temptype == 802007 then --行侠仗义 巡逻
				if quest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then --完成任务后，任务目的需要更换
					temptype = temptype + 10
					local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
					sb:Set("NPCName",npcConfig.name)
					sb:SetNum("npcid", quest.dstnpcid)
				else
					local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
					sb:Set("NPCName", npcConfig.name)
					sb:SetNum("npcid", quest.dstnpcid)
					sb:Set("Number2", quest.dstitemid)
				end
			elseif temptype == knight.gsp.specialquest.SpecialQuestType.BuyItem then--师门-买道具
				local npcConfig1 = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
				sb:Set("NPCName",npcConfig1.name)
				local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(quest.dstitemid)
				sb:Set("ItemName",itemattr.name)
				if itemattr.blinkopenwordbook == 1 or itemattr.blinkopenwordbook == 2 then
					sb:SetNum("npcid2",itemattr.linkusemethod)
					sb:SetNum("mapid3",1)
				else
					sb:SetNum("npcid2",itemattr.npcid2)
					sb:SetNum("mapid3",0)
				end
				sb:SetNum("ItemLevel", itemattr.level)
				local strType = knight.gsp.item.GetCItemTypeTableInstance():getRecorder(itemattr.itemtypeid).name;
				sb:Set("ItemType", strType)
			elseif temptype == knight.gsp.specialquest.SpecialQuestType.FactionBuyItem -- 帮派日常任务-厉兵秣马三（寻物
			or temptype == knight.gsp.specialquest.SpecialQuestType.FactionBuildBuyItem -- 帮派建设任务-寻物
			then
				local npcConfig1 = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
				sb:Set("NPCName", npcConfig1.name)
		
				local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(quest.dstitemid)
				local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(itemattr.npcid2)
				local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(npcConfig.mapid)
		
				sb:Set("ItemName",itemattr.name)
				sb:SetNum("ItemLevel", itemattr.level)
				if itemattr.blinkopenwordbook == 1 or itemattr.blinkopenwordbook == 2 then
					sb:SetNum("npcid2",itemattr.linkusemethod)
					sb:SetNum("mapid3",1)
				else
					sb:SetNum("npcid2",itemattr.npcid2)
					sb:SetNum("mapid3",0)
				end
				sb:Set("MapName1", mapcongig.mapName)
				sb:Set("NpcName1", npcConfig.name)
				sb:SetNum("xjPos",mapcongig.xjPos)
				sb:SetNum("yjPos",mapcongig.yjPos)
				sb:SetNum("mapid",quest.dstmapid)
				
				local strType = knight.gsp.item.GetCItemTypeTableInstance():getRecorder(itemattr.itemtypeid).name
				sb:Set("ItemType",strType)
			elseif temptype == knight.gsp.specialquest.SpecialQuestType.Demonstrate-- 示威,服务器发过来npckey
			or temptype == knight.gsp.specialquest.SpecialQuestType.DemonstrateEye-- 示威,使用天眼后
			or temptype == knight.gsp.specialquest.SpecialQuestType.ZhenShou-- 三届珍兽
			or temptype == knight.gsp.specialquest.SpecialQuestType.ZhenShouByEye --使用天眼-三届珍兽
			then
				local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(quest.dstmapid)
				sb:Set("MapName",mapcongig.mapName)
				sb:SetNum("xjPos",mapcongig.xjPos)
				sb:SetNum("yjPos",mapcongig.yjPos)
				sb:SetNum("mapid",quest.dstmapid)
				sb:SetNum("xPos",quest.dstx)
				sb:SetNum("yPos",quest.dsty)
				sb:Set("NPCName",quest.dstnpcname)
			elseif temptype == knight.gsp.specialquest.SpecialQuestType.QingLiMenPai then--师门-清理门派
				local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(quest.dstmapid)
				sb:Set("MapName",mapcongig.mapName)
				sb:SetNum("mapid", quest.dstmapid)
				sb:SetNum("xPos",quest.dstx)
				sb:SetNum("yPos",quest.dsty)
				sb:SetNum("npcid",quest.dstnpcid)
				
			elseif temptype ==  knight.gsp.specialquest.SpecialQuestType.FactionPublicize then-- 帮派日常任务-帮派宣传	
				local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(quest.dstmapid)
				sb:Set("MapName",mapcongig.mapName)
				sb:SetNum("mapid",quest.dstmapid)	
				sb:SetNum("xPos",quest.dstx)
				sb:SetNum("yPos",quest.dsty)
			elseif temptype == knight.gsp.specialquest.SpecialQuestType.FactionFinghtEZei then -- 帮派日常任务-江湖恶贼
				local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(quest.dstmapid)
				sb:Set("MapName",mapcongig.mapName)
				sb:SetNum("mapid",quest.dstmapid)	
				sb:SetNum("xPos",quest.dstx)
				sb:SetNum("yPos",quest.dsty)
				sb:Set("NPCName",quest.dstnpcname)
			elseif temptype == knight.gsp.specialquest.SpecialQuestType.CaiJi then-- 师门-采集
				local npcConfig  = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstitemid)
				sb:Set("ItemName",npcConfig.name)
				sb:SetNum("Number2",quest.dstitemnum)
				sb:SetNum("Number3",quest.dstitemidnum2)
				sb:SetNum("mapid",quest.dstmapid)
				sb:SetNum("xPos",quest.dstx)
				sb:SetNum("yPos",quest.dsty)
		    elseif temptype == knight.gsp.specialquest.SpecialQuestType.KillMonster then --打怪任务
		        local monster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(quest.dstnpcid)
		        sb:Set("PetName",monster.name)
		        local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(quest.dstmapid)
		        sb:Set("MapName",mapcongig.mapName)
				sb:SetNum("Number2",quest.dstitemid)
				sb:SetNum("mapid",quest.dstmapid)
		        
		        local mapRecord=knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(quest.dstmapid)
		        if mapRecord.id~=-1 then
					math.randomseed(os.time())
		            local randX=mapRecord.bottomx-mapRecord.topx
		            randX=mapRecord.bottomx+math.random(randX)-1
		            local randY=mapRecord.bottomy-mapRecord.topy
		            randY=mapRecord.bottomy+math.random(randY)-1
		            sb:SetNum("xPos",randX)
		            sb:SetNum("yPos",randY)
		        end
		    elseif temptype == knight.gsp.specialquest.SpecialQuestType.FindItem then --打怪掉落物品任务
		        local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(quest.dstmapid)
		        sb:Set("MapName",mapcongig.mapName)
		        sb:Set("petname",mapcongig.mapName)
		        
		        local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(quest.dstitemid)
		        sb:Set("ItemName", itemattr.name)
		        sb:SetNum("Number2", quest.dstitemnum)
		        sb:SetNum("mapid", quest.dstmapid)
		        local mapRecord=knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(quest.dstmapid)
		        if mapRecord.id~=-1 then
					math.randomseed(os.time())
		            local randX=mapRecord.bottomx-mapRecord.topx;
		            randX=mapRecord.bottomx+math.random(randX)-1
		            
		            local randY=mapRecord.bottomy-mapRecord.topy
		            randY=mapRecord.bottomy+math.random(randY)-1
		            sb:SetNum("xPos",randX)
		            sb:SetNum("yPos",randY)
		        end
		    elseif temptype == knight.gsp.specialquest.SpecialQuestType.Answer then  --师门答题
		        local npc = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
		        sb:Set("NPCName",npc.name)
		        sb:SetNum("npcid", quest.dstnpcid)
		        sb:SetNum("mapid", quest.dstmapid)
		        sb:SetNum("xPos",quest.dstx)
		        sb:SetNum("yPos",quest.dsty)
			end
			
		end
	end

	local shimen = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(temptype);
	if shimen.id == -1 then
		return
	end
	local items = std.vector_knight__gsp__specialquest__RewardItemUnit_()
	self:ShowQuestIntro(shimen.name,sb:GetString(shimen.aim),sb:GetString(shimen.discribe),0,0,0,items)
	self:SetFinishImageVisibleState(quest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE)
end


function CTaskDialog:HandleSelectTab(e)
end

function CTaskDialog:HandleAbandonTask(e)
	if self.m_iSelectedCurTaskId == 0 then
		return true
	end

	local pParentItem = self:GetParentItemByTaskID(self.m_iSelectedCurTaskId, true);
	--如果是副本任务，主线任务,给出提示 --pParentItem == self.m_pEctypItem or 
	if pParentItem == self.m_pScenarioItem
        or self.m_iSelectedCurTaskId == 904001 then
		--此任务不可放弃
		GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(141484).msg)
		return true;
	end

    --你确定要放弃任务吗?
	local tip = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(141086)
	
	if tip.id ~= -1 then
		GetMessageManager():AddConfirmBox(eConfirmAbandonTask, tip.msg, CTaskDialog.HandleConfirmAbandonTask,0,
	     CMessageManager.HandleDefaultCancelEvent,CMessageManager,0,0,nil,"","")
	end
	return true;
end

function CTaskDialog.HandleConfirmAbandonTask()
	if _instance == nil then
		return
	end
	if _instance.m_iSelectedCurTaskId > 0 then
		LogInsane("send abandonquest protocol")
		require "protocoldef.knight.gsp.specialquest.cabandonquest"
        local abandonquest = CAbandonQuest.Create()
        abandonquest.questid = _instance.m_iSelectedCurTaskId
        
        LuaProtocolManager.getInstance():send(abandonquest)
    end
    LogInsane("Close confirm message")
    GetMessageManager():CloseConfirmBox(eConfirmAbandonTask,false)
end

function CTaskDialog:HandleGoto(e)
	if self.m_iSelectedCurTaskId == 0 then
		return true;
	end
	if self.m_iSelectedCurTaskId then
	    local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.task.cfamoustask", self.m_iSelectedCurTaskId)
		if cfg and cfg.id ~= -1 then
            if GetChatManager() then
                GetChatManager():AddTipsMsg(140656)
            end
			return true
		end
	end
	local gotolink = tolua.cast(self.CurrentQuestTab.infoBox:GetFirstLinkTextCpn(), "CEGUI::RichEditboxGoToComponent")
    if gotolink then
        gotolink:onParentClicked();
    end
    
	return true;
end

function CTaskDialog:HandleSelectedCurrentTask(e)
	LogInsane("CTaskDialog:HandleSelectedCurrentTask")
	local sitem = self.CurrentQuestTab.questTree:getSelectedItem()
	if sitem == nil then
		return true
	end
	local taskid = sitem:getID()
	if self.m_iSelectedCurTaskId == taskid then
		return true
	end
	self.m_iSelectedCurTaskId = taskid;
	self:RefreshQuestIntro(self.m_iSelectedCurTaskId)
end

function CTaskDialog:UpdateAcceptableTaskList()
	LogInsane("CTaskDialog:UpdateAcceptableTaskList")
	if self == nil then
		self = _instance
	end
	if self == nil then
		return
	end
	self.AcceptableQuestTab.questTree:resetList()
    self.m_pAcpBranchItem = nil
    self.m_pAcpActivityItem = nil
    self.m_pAcpOtherItem = nil

	local acceptablequests = std.vector_int_()
	GetTaskManager():GetAcceptableQuestListForLua(acceptablequests)

	local find = false
    for i = 0, acceptablequests:size() - 1 do
    	if acceptablequests[i] == self.m_iSelectedAcpTaskId then
    		find = true
    		break
    	end
    end
    if not find then
    	self.m_iSelectedAcpTaskId = 0
    end

    self.AcceptableQuestTab.EmptyDes:setVisible(true)
    self.AcceptableQuestTab.goacceptBtn:setVisible(false)
    
	for i = 0, acceptablequests:size() - 1 do
		local questid = acceptablequests[i]
		local pParentItem = self:GetParentItemByTaskID(questid,false)
		if pParentItem then
			local child = pParentItem:addItem(CEGUI.String(""), questid)
	        self:SetSecondItemIcon(child)
	        if GetTaskManager():AppendAcceptQuestName(questid, child) then
	        	self:SetSecondItemIcon(child)
			end
	--		self:AddAcceptableQuestItem(pParentItem,child)
			self.AcceptableQuestTab.EmptyDes:setVisible(false)
			self.AcceptableQuestTab.goacceptBtn:setVisible(true)
			     
			if self.m_iSelectedAcpTaskId == 0 then
				self.m_iSelectedAcpTaskId = questid
	            self.AcceptableQuestTab.questTree:SetLastOpenItem(pParentItem)
	            self.AcceptableQuestTab.questTree:invalidate()
				self:RefreshAcceptableQuestIntro(questid)
			end
	    end
	end
end

function CTaskDialog:RefreshAcceptableQuestIntro(questid)

	local questinfo = knight.gsp.task.GetCAcceptableTaskTableInstance():getRecorder(questid);
	local m_pAcceptableTaskIntro = self.AcceptableQuestTab.infoBox
	m_pAcceptableTaskIntro:Clear()
	m_pAcceptableTaskIntro:AppendImage(CEGUI.String("MainControl"),CEGUI.String("TaskName"))
	m_pAcceptableTaskIntro:AppendBreak()
	m_pAcceptableTaskIntro:AppendText(CEGUI.String("　"..questinfo.name))
	m_pAcceptableTaskIntro:AppendBreak();

	--任务目的
	m_pAcceptableTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("TaskGoal"))
	m_pAcceptableTaskIntro:AppendBreak()
	m_pAcceptableTaskIntro:AppendText(CEGUI.String("　"))
	m_pAcceptableTaskIntro:AppendParseText(CEGUI.String(questinfo.aim))
	m_pAcceptableTaskIntro:AppendBreak()
	--任务描述	
	m_pAcceptableTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("TaskDescription"))
	m_pAcceptableTaskIntro:AppendBreak()

	m_pAcceptableTaskIntro:AppendText(CEGUI.String("　"))
	m_pAcceptableTaskIntro:AppendParseText(CEGUI.String(questinfo.discribe))
	m_pAcceptableTaskIntro:AppendBreak()

	m_pAcceptableTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("TaskAward"))
	m_pAcceptableTaskIntro:AppendBreak()

	if questid ~= knight.gsp.specialquest.SpecialQuestID.tianzunquestid then
		if questinfo.expreward ~= 0 then
			m_pAcceptableTaskIntro:AppendText(
				CEGUI.String(MHSD_UTILS.get_resstring(254)..questinfo.expreward),
				CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFEF42")))
			m_pAcceptableTaskIntro:AppendImage(CEGUI.String("MainControl"),CEGUI.String("Exp"))
			m_pAcceptableTaskIntro:AppendBreak() 		
		end
	end
	
	if questinfo.moneyreward ~= 0 then
		m_pAcceptableTaskIntro:AppendText(
			CEGUI.String(MHSD_UTILS.get_resstring(255)..questinfo.moneyreward),
			CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFEF42")))
		m_pAcceptableTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("Xianjin"))
		m_pAcceptableTaskIntro:AppendBreak() 
	end
	
	if questinfo.rmoneyreward ~= 0 then
		m_pAcceptableTaskIntro:AppendText(
			CEGUI.String(MHSD_UTILS.get_resstring(256)..questinfo.rmoneyreward),
			CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFEF42")))
		m_pAcceptableTaskIntro:AppendImage(CEGUI.String("MainControl"), CEGUI.String("Chubeijin"))
		m_pAcceptableTaskIntro:AppendBreak()
	end
	local bHaveItems = false
	--物品奖励

	for i = 0, questinfo.itemsreward:size() - 1 do
		if questinfo.itemsreward[i] ~= 0 then
			if not bHaveItems then
				bHaveItems = true
				m_pAcceptableTaskIntro:AppendText(
					CEGUI.String(MHSD_UTILS.get_resstring(257)),
					CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFEF42")))
			end
		
			local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(questinfo.itemsreward[i])
			if itemattr.id ~= -1 then
				local pIcon = GetIconManager():GetItemIconByID(itemattr.icon)
				if pIcon then
					m_pAcceptableTaskIntro:AppendImage(pIcon, questinfo.itemsreward[i],1);
					m_pAcceptableTaskIntro:AppendText(CEGUI.String("    "))
				end
			end
		end
	end
	if not CEGUI.String(questinfo.rewardtext):empty() then
		m_pAcceptableTaskIntro:AppendText(CEGUI.String(questinfo.rewardtext),
			CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFEF42")))
	end

	m_pAcceptableTaskIntro:Refresh()
	m_pAcceptableTaskIntro:getVertScrollbar():setScrollPosition(0)
end

--添加可接任务节点
function CTaskDialog:AddAcceptableQuestItem(pParentItem, pChildItem)
	if not self.AcceptableQuestTab.questTree:isTreeItemInList(pParentItem) then
		self.AcceptableQuestTab.questTree:addItem(pParentItem)
	end
	pParentItem:addItem(pChildItem)
end

function CTaskDialog:HandleSelectedAcpTask(e)
	local sitem = self.AcceptableQuestTab.questTree:getSelectedItem();
	if sitem == nil then
		return true
	end

	local taskid = sitem:getID();
	if self.m_iSelectedAcpTaskId == taskid then
		return true
	end
	self.m_iSelectedAcpTaskId = taskid;
	self:RefreshAcceptableQuestIntro(taskid)
	return true;
end

function CTaskDialog:HandleAcceptBtnClicked(e)
	if self.m_iSelectedAcpTaskId == 0 then
		return true;
	end
	local gotolink = tolua.cast(
		self.AcceptableQuestTab.infoBox:GetFirstLinkTextCpn(), 
		"CEGUI::RichEditboxGoToComponent")
    if gotolink then
        gotolink:onParentClicked()
    end
    return true;
end

function CTaskDialog.OpenAcceptQuest(selectid)
	if _instance == nil then
		CTaskDialog.getSingletonDialog()
	end
	local self = _instance
	local selectid = selectid or 0
	LogInsane("CTaskDialog.OpenAcceptQuest"..selectid)
	self.m_pTabControl:setSelectedTabAtIndex(1)
	if selectid > 0 and self.m_iSelectedAcpTaskId ~= selectid then
		local pItem = self.AcceptableQuestTab.questTree:findFirstItemWithID(selectid)
		if pItem then
			self.m_iSelectedAcpTaskId = selectid
			local pParentItem = self:GetParentItemByTaskID(self.m_iSelectedAcpTaskId,false)
			if pParentItem then
	            self.AcceptableQuestTab.questTree:SetLastOpenItem(pParentItem)
	           	self.AcceptableQuestTab.questTree:SetLastSelectItem(pItem);
	            self.AcceptableQuestTab.questTree:invalidate()
				self:RefreshAcceptableQuestIntro(self.m_iSelectedAcpTaskId)
			end
		end
	end
	return 1
end

function CTaskDialog.HandleWindowUpdate(e)
end

function CTaskDialog.GetLayoutFileName()
	return "TaskDialog.layout"
end

function CTaskDialog:RemoveChildrenItemsWrap(item)
	local num = item:getItemCount()
	for i = 0, num - 1 do
		local childitem = item:getTreeItemFromIndex(i)
		LogInsane("release childitem @ "..childitem:getID())
	--	tolua.releaseownership(childitem)
	end
	item:RemoveChildrenItems()
end

function CTaskDialog:OnClose()
	LogInsane("CTaskDialog:RemoveWindowEvent")
	--[[
	if self.m_pDailyItem then
		LogInsane("m_pDailyItem:RemoveWindowEvent")
		self:RemoveChildrenItemsWrap(self.m_pDailyItem)
		LogInsane("m_pDailyItem:tryReleaseownership")
	--	tolua.releaseownership(self.m_pDailyItem)
	--	self.m_pDailyItem:delete()
	end
	if self.m_pActivityItem then
		LogInsane("m_pActivityItem:RemoveWindowEvent")
		self:RemoveChildrenItemsWrap(self.m_pActivityItem)
	--	tolua.releaseownership(self.m_pActivityItem)
	--	self.m_pActivityItem:delete()
	end
	if self.m_pOtherItem then
		LogInsane("m_pOtherItem:RemoveWindowEvent")
		self:RemoveChildrenItemsWrap(self.m_pOtherItem)
	--	tolua.releaseownership(self.m_pOtherItem)
	--	self.m_pOtherItem:delete()
	end
	if self.m_pScenarioItem then
		LogInsane("m_pScenarioItem:RemoveWindowEvent")
	--	self:RemoveChildrenItemsWrap(self.m_pScenarioItem)
	--	tolua.releaseownership(self.m_pScenarioItem)
	--	self.m_pScenarioItem:delete()
	end
	if self.m_pBranchItem then
		LogInsane("m_pBranchItem:RemoveWindowEvent")
		self:RemoveChildrenItemsWrap(self.m_pBranchItem)
	--	tolua.releaseownership(self.m_pBranchItem)
	--	self.m_pBranchItem:delete()
	end
	if self.m_pEctypItem then
		LogInsane("m_pEctypItem:RemoveWindowEvent")
		self:RemoveChildrenItemsWrap(self.m_pEctypItem)
	--	tolua.releaseownership(self.m_pEctypItem)
	--	self.m_pEctypItem:delete()
	end
	
	if self.m_pAcpBranchItem then
		LogInsane("m_pAcpBranchItem:RemoveWindowEvent")
		self:RemoveChildrenItemsWrap(self.m_pAcpBranchItem)
	--	self.m_pAcpBranchItem:delete()
	end
	if self.m_pAcpActivityItem then
		LogInsane("m_pAcpActivityItem:RemoveWindowEvent")
		self:RemoveChildrenItemsWrap(self.m_pAcpActivityItem)
	--	self.m_pAcpActivityItem:delete()
	end
	if self.m_pAcpOtherItem then
		LogInsane("m_pAcpOtherItem:RemoveWindowEvent")
		self:RemoveChildrenItemsWrap(self.m_pAcpOtherItem)
	--	self.m_pAcpOtherItem:delete()
	end
	LogInsane("enter release owner ship")
	LogInsane("begin free at c++")
	--]]
	self.CurrentQuestTab.questTree:resetList()
	self.AcceptableQuestTab.questTree:resetList()
	self.m_pDailyItem = nil
	self.m_pActivityItem = nil
	self.m_pOtherItem = nil
	self.m_pScenarioItem = nil
	self.m_pBranchItem = nil
	self.m_pEctypItem = nil
	self.m_pAcpBranchItem = nil
	self.m_pAcpActivityItem = nil
	self.m_pAcpOtherItem = nil
	Dialog.OnClose(self)
end

function CTaskDialog.DestroyDialog()
	if _instance == nil then
		return
	end
	GetTaskManager().EventUpdateLastQuest:RemoveScriptFunctor(_instance.m_hUpdateLastQuest)
	if _instance.StateNotify then
		_instance.StateNotify = nil
	end
	_instance:OnClose()
	_instance = nil
end

return CTaskDialog
