--[[author: lvxiaolong
date: 2013/12/19
function: wu jue ling exit map dialog
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "ui.task.tasktracingdialog"
require "ui.wujueling.wujuelingcarddlg"
require "ui.battleautodlg"

WujuelingExitMapDlg = {
    m_iLeftTime = 0,

}

setmetatable(WujuelingExitMapDlg, Dialog)
WujuelingExitMapDlg.__index = WujuelingExitMapDlg 


------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function WujuelingExitMapDlg.IsShow()
    --LogInfo("WujuelingExitMapDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function WujuelingExitMapDlg.getInstance()
	LogInfo("WujuelingExitMapDlg.getInstance")
    if not _instance then
        _instance = WujuelingExitMapDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function WujuelingExitMapDlg.getInstanceAndShow()
	LogInfo("____WujuelingExitMapDlg.getInstanceAndShow")
    if not _instance then
        _instance = WujuelingExitMapDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function WujuelingExitMapDlg.getInstanceNotCreate()
    --print("WujuelingExitMapDlg.getInstanceNotCreate")
    return _instance
end

function WujuelingExitMapDlg.DestroyDialog()
	
    CTaskTracingDialog.exitWujue()

    if _instance then
    	GetTaskManager().EventUpdateLastQuest:RemoveScriptFunctor(_instance.m_hUpdateLastQuest)
        _instance:HideOrShowMainBtns(true)
		_instance:OnClose() 
		_instance = nil
	end
end

function WujuelingExitMapDlg.ToggleOpenClose()
	if not _instance then 
		_instance = WujuelingExitMapDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function WujuelingExitMapDlg.GetLayoutFileName()
    return "wujuelingleave.layout"
end

function WujuelingExitMapDlg:OnCreate()
	LogInfo("enter WujuelingExitMapDlg oncreate")

    Dialog.OnCreate(self)
    --self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    --get windows
    
    
    self.m_pExitMapBtn = CEGUI.Window.toPushButton(winMgr:getWindow("wujuelingleave/btn"))
    self.m_pExitMapBtn:subscribeEvent("Clicked", WujuelingExitMapDlg.HandleExitMapBtnClicked, self)
    
    self.m_pLeftTime = winMgr:getWindow("wujuelingleave/time")
    self.m_pLeftTimeImage = winMgr:getWindow("wujuelingleave/image");
    self.m_pTaskTrace = CEGUI.Window.toRichEditbox(winMgr:getWindow("wujuelingleave/main"))
    self.m_pTaskTrace:setMousePassThroughEnabled(true)
    self.m_pTaskTraceName = winMgr:getWindow("wujuelingleave/name")
    self.m_pTaskTraceName:setMousePassThroughEnabled(true)
    self.m_pTaskTraceMark = winMgr:getWindow("wujuelingleave/mark")
    self.m_pTaskTraceMark:setMousePassThroughEnabled(true)
    self.m_pTaskBack = winMgr:getWindow("wujuelingleavecell")
    self.m_pTaskBack:subscribeEvent("MouseButtonDown", WujuelingExitMapDlg.HandleGoToClicked, self)

    self:GetWindow():subscribeEvent("WindowUpdate", WujuelingExitMapDlg.HandleWindowUpate, self)
    
    print("____step1")
    self.m_hUpdateLastQuest = GetTaskManager().EventUpdateLastQuest:InsertScriptFunctor(WujuelingExitMapDlg.RefreshLastTask)
    
    print("____step2")
    self:HideOrShowMainBtns(false)
    
    print("____step3")
    self:ResetWujueLeftTime(GetScene():GetWujueMapCopyDestroyLeftTime())
    
    print("____step4")
    self:RefreshWujueTask()
    
    CTaskTracingDialog.enterWujue()
    
    LogInfo("exit WujuelingExitMapDlg OnCreate")
end

function WujuelingExitMapDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WujuelingExitMapDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeMapChangeClose] = 1

    return self
end

function WujuelingExitMapDlg:RefreshWujueTask()
    local ids = std.vector_int_()

    local hasText = false
    local tt = knight.gsp.task.GetCWujuerenwuConfigTableInstance()
    tt:getAllID(ids)
    
    local num = ids:size()

    for i = 0, num-1, 1 do
        local record = tt:getRecorder(ids[i])
        if self:RefreshATask(record.taskid) then
            hasText = true
            break
        end
    end
    if hasText then
        self.m_pTaskBack:setVisible(true)
    else
        self.m_pTaskBack:setVisible(false)
    end
end

function WujuelingExitMapDlg:RefreshATask(questid)
    local pActiveQuest = GetTaskManager():GetReceiveQuest(questid)
    
    if pActiveQuest then
        --AddQuestItem(pActiveQuest,tracetime);
        
        local tt = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance()
        local shimen = tt:getRecorder(questid)
        if not shimen or shimen.id == -1 then
            return false
        end

        self.m_pTaskTraceMark:setVisible(true)
        if pActiveQuest.queststate == knight.gsp.specialquest.SpecialQuestState.FAIL then
            local failconfig = tt:getRecorder(1000)
            if not failconfig or failconfig.id == -1 or failconfig.tracname == "" then
                return false
            end

            self.m_pTaskTrace:Clear()
            self.m_pTaskTrace:AppendParseText(CEGUI.String(failconfig.tracdiscribe))
            self.m_pTaskTrace:Refresh()
        else
            local sb = StringBuilder:new()
            local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pActiveQuest.dstnpcid)
            local mapcongig = nil
            if pActiveQuest.dstmapid == 0 and npcConfig and npcConfig.id ~= -1 then
                mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(npcConfig.mapid)
                sb:Set("xPos", tostring(npcConfig.xPos))
                sb:Set("yPos", tostring(npcConfig.yPos))
                sb:Set("mapid", tostring(npcConfig.mapid))
            elseif pActiveQuest.dstmapid > 0 then
                mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(pActiveQuest.dstmapid)
                sb:Set("mapid", tostring(pActiveQuest.dstmapid))
                sb:Set("xPos", tostring(pActiveQuest.dstx))
                sb:Set("yPos", tostring(pActiveQuest.dsty))
            else
                sb:Set("mapid", "0")
                sb:Set("xPos", "0")
                sb:Set("yPos", "0")
            end

            sb:Set("npcid", tostring(pActiveQuest.dstnpcid))

            sb:Set("NPCName", npcConfig.name)

            self.m_pTaskTraceName:setText(shimen.tracname)
            self.m_pTaskTrace:Clear()
            self.m_pTaskTrace:AppendParseText(CEGUI.String(sb:GetString(shimen.tracdiscribe)))
            self.m_pTaskTrace:Refresh()

            local ContentSize = self.m_pTaskTrace:GetExtendSize()
            ContentSize.height = ContentSize.height + 8
            self.m_pTaskTrace:setHeight(CEGUI.UDim(0, ContentSize.height))
            
            sb:delete()
        end
        
        return true
    else
        return false
    end
end

function WujuelingExitMapDlg.RefreshLastTask(questid)
    print("____WujuelingExitMapDlg.RefreshLastTask")
    
    if not _instance then
        return
    end

    if questid then
        print("____questid: " .. questid)
    end

    local isWujueTask = false
    local ids = std.vector_int_()
    
    local tt = knight.gsp.task.GetCWujuerenwuConfigTableInstance()
    tt:getAllID(ids)
    local num = ids:size()

    for i = 0, num-1, 1 do
        local record = tt:getRecorder(ids[i])
        if record.taskid == questid then
            isWujueTask = true
        end
    end

    if not isWujueTask then
        return
    end

    if _instance:RefreshATask(questid) then
        print("_____instance:RefreshATask: true")
        _instance.m_pTaskBack:setVisible(true)
    else
        print("_____instance:RefreshATask: false")
        _instance.m_pTaskBack:setVisible(false)
    end
end

function WujuelingExitMapDlg:HandleGoToClicked(e)
    self:OnGoToClicked()
    return true
end
 
function WujuelingExitMapDlg:OnGoToClicked()
    local gotolink = CEGUI.Window.toRichEditboxGoToComponent(self.m_pTaskTrace:GetFirstLinkTextCpn())
    if gotolink then
        gotolink:onParentClicked()
    end
end

function WujuelingExitMapDlg:HandleExitMapBtnClicked(args)
    WujuelingCardDlg.SendExitCopy()
    return true
end

function WujuelingExitMapDlg:ResetWujueLeftTime(lefttime)
    self.m_iLeftTime = lefttime
end

function WujuelingExitMapDlg:HideOrShowMainBtns(flag)
    BattleAutoDlg.CSetVisible(flag)
    
    if flag then
        if GetWelfareManager() then
            local dlgWelfareEntrance = WelfareBtn:getInstanceAndShow()
            
            if dlgWelfareEntrance then
                dlgWelfareEntrance:refresh()
            end
        end
        OnlineGiftBtn.Refresh()
    else
        local dlgWelfareEntrance = WelfareBtn:getInstance()
        if dlgWelfareEntrance then
            dlgWelfareEntrance.DestroyDialog()
        end
        local dlgOnlineWE = OnlineGiftBtn:getInstanceNotCreate()
        if dlgOnlineWE then
            dlgOnlineWE.DestroyDialog()
        end
    end
end

function WujuelingExitMapDlg:HandleWindowUpate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    self.m_iLeftTime = self.m_iLeftTime - ue.d_timeSinceLastFrame * 1000;
    
    if self.m_iLeftTime < 0 then
        self.m_iLeftTime = 0
    end
    
    GetScene():SetWujueMapCopyDestroyLeftTime(self.m_iLeftTime)
    
    local displayString = MHSD_UTILS.GetTimeHMSString(math.floor(self.m_iLeftTime/1000))
    self.m_pLeftTime:setText(displayString)

    return true
end

function WujuelingExitMapDlg.SetTimeLabelVisible(flag)
	print("WujuelingExitMapDlg.SetTimeLabelVisible")
    if _instance ~= nil then
        _instance.m_pLeftTimeImage:setVisible(flag)
    end
end

return WujuelingExitMapDlg








