TaskTrackCell = {}
TaskTrackCell.__index = TaskTrackCell

local EffectCountDown = 10
function TaskTrackCell.new(questid)
	local T = {}
	setmetatable(T, TaskTrackCell)
	T.id = questid
	local winMgr = CEGUI.WindowManager:getSingleton()
	local name_prefix = tostring(questid)
	T.pBtn = CEGUI.toPushButton(winMgr:loadWindowLayout("TaskTrackcell.layout", name_prefix))
	T.pTitle = winMgr:getWindow(name_prefix.."TaskTrackcell/name")
    T.pTitle:setMousePassThroughEnabled(true)
    T.pBattleIcon = winMgr:getWindow(name_prefix.."TaskTrackcell/mark")
    T.pBattleIcon:setMousePassThroughEnabled(true)
	T.pContent = CEGUI.toRichEditbox(winMgr:getWindow(name_prefix.."TaskTrackcell/main"))
    T.pContent:setMousePassThroughEnabled(true)
    T.pContent:setReadOnly(true)
    -- T.pContent:setWidth(CEGUI.UDim(0.0, 252))
        
    T.pBtn:subscribeEvent("Clicked", TaskTrackCell.HandleGoToClicked, T)
    T.iPos = 0;
        
    local missioninfo = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(questid)
    if missioninfo.id ~= -1 and missioninfo.MissionType == 40 then
       T.pBattleIcon:setVisible(true)
    else
       T.pBattleIcon:setVisible(false)
    end


    if (questid >= 100183 and questid <= 100188) or (questid >= 100283 and questid <= 100288) 
    	or (questid >= 100483 and questid <= 100487) or (questid >= 100583 and questid <= 100588) 
    	or (questid >= 100783 and questid <= 100787) or (questid >= 100902 and questid <= 100903) then
        GetNewRoleGuideManager():StartGuide(30018, T.pBtn:getName(), T.pBtn:getName())
    elseif GetDataManager():GetMainCharacterLevel() <= 10 and 
    	questid ~= 101104 and questid ~= 101207 and questid ~= 101407 
    	and questid ~= 101507 and questid ~= 101707 and questid ~= 101905 then

        T.pEffect = GetGameUIManager():AddUIEffect(T.pBtn, MHSD_UTILS.get_effectpath(10230))
        T.pBtn:SetGuideState(true)
        T.pBtn:removeEvent("GuideEnd")
        T.pBtn:subscribeEvent("GuideEnd", TaskTrackCell.HandleGuideEnd, T)
        T.pBtn:setClippedByParent(false)
    end

	return T
end

function TaskTrackCell:HandleGoToClicked(e)
    if self.id == 501004 then
        local dlgNPCTip = require "ui.activity.npctipsdialog":getInstance()
        dlgNPCTip.m_iAssociatedID = self.id
        --get data
        local questInfo = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(self.id)
        local quest = GetTaskManager():GetReceiveQuest(self.id)
        local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(quest.dstnpcid)
        local headNpcID = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.csongnianhuo"):getRecorder(0).npcid
        local xlnModelID = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(headNpcID).modelID
        local mapConfig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(npcConfig.mapid)
        --set icon
        local iconPath = GetIconManager():
            GetImagePathByID(knight.gsp.npc.GetCNpcShapeTableInstance():
                getRecorder(xlnModelID).headID):c_str()
        dlgNPCTip.m_pNpcIcon:setProperty("Image",iconPath)
        --set talktext
        local strMsg = questInfo.discribe
        strMsg = string.gsub(strMsg, "%$MapName%$", mapConfig.mapName)
        strMsg = string.gsub(strMsg, "%$NPCName%$", npcConfig.name)
        dlgNPCTip.m_pNpcTalkBox:Clear()
        dlgNPCTip.m_pNpcTalkBox:AppendParseText(CEGUI.String(strMsg))
        dlgNPCTip.m_pNpcTalkBox:AppendBreak()
        dlgNPCTip.m_pNpcTalkBox:Refresh()
        dlgNPCTip.m_pNpcTalkBox:HandleTop()

        dlgNPCTip.m_pRewardsBox:setVisible(false)        
        return
    end

	self:OnGoToClicked()

	if GetDataManager():GetMainCharacterLevel() <= 10 then
		self.bNeedCountDown = true
		self.fCountDown = 0
	end

	return true
end

function TaskTrackCell:HandleGuideEnd(e)
	local wndE=CEGUI.toWindowEventArgs(e)
    if wndE.window then
        wndE.window:setClippedByParent(true)
        GetGameUIManager():RemoveUIEffect(wndE.window)
    end
    return true;
end

    
function TaskTrackCell:OnGoToClicked()
	if self.bFail then
		CTaskDialog.getSingletonDialog().RefreshLastTask(self.id)
		return
	end
    self.pContent:OnFirstGotoLinkClick()
end

function TaskTrackCell:ResetHeight()        
    local ContentSize = self.pContent:GetExtendSize()
    local TitleSize = self.pTitle:getPixelSize()    
    
    ContentSize.height = ContentSize.height + 8

    local minWidth = self.pBtn:getPixelSize().width
    local minHeight = self.pBtn:getPixelSize().height

    -- 需要根据RichEditbox内容的高度设置控件高度
    local pBtnWidth = minWidth    
    local pBtnHeight = ContentSize.height+ TitleSize.height
    if pBtnHeight < minHeight then
    	pBtnHeight = minHeight
    end

    self.pBtn:setSize(CEGUI.UVector2(CEGUI.UDim(0, pBtnWidth), CEGUI.UDim(0, pBtnHeight)))
    self.pContent:setHeight(CEGUI.UDim(0,ContentSize.height));
end

function TaskTrackCell.GetLayoutFileName()
	return "TaskDialog.layout"
end

function TaskTrackCell:AddEffect()
	LogInsane("TaskTrackCell add effect")

	self.bNeedCountDown = false
end

function TaskTrackCell:Run(elapsed)
	if not self.bNeedCountDown then
		return
	end
	
	self.fCountDown = self.fCountDown + (elapsed / 1000)	
	if self.fCountDown > EffectCountDown then
		self.bNeedCountDown = false
		if GetDataManager():GetMainCharacterLevel() <= 10 then
        	self.pEffect = GetGameUIManager():AddUIEffect(self.pBtn, MHSD_UTILS.get_effectpath(10230))
        	self.pBtn:SetGuideState(true)
        	self.pBtn:removeEvent("GuideEnd")
        	self.pBtn:subscribeEvent("GuideEnd", TaskTrackCell.HandleGuideEnd, self)
        	self.pBtn:setClippedByParent(false)
		end
	end
end

return TaskTrackCell
