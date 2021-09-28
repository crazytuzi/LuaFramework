--[[author: lvxiaolong
date: 2013/9/6
function: bandit rub my team
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"

BanditRubMyTeam = {
    m_isTeamLeader = false,
    m_nTeamLeaderRoleID = -1,
    m_infoTeamMembers = nil,
    m_nCurWillKillOutRoleID = -1,
}

setmetatable(BanditRubMyTeam, Dialog)
BanditRubMyTeam.__index = BanditRubMyTeam

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function BanditRubMyTeam.CreateNewDlg(pParentDlg, id)
	LogInfo("enter BanditRubMyTeam.CreateNewDlg")
	local newDlg = BanditRubMyTeam:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function BanditRubMyTeam.GetLayoutFileName()
    return "banditallitem2.layout"
end

function BanditRubMyTeam:OnCreate(pParentDlg, id)
	LogInfo("enter BanditRubMyTeam oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()
    
    -- get windows
    self.m_wndTeamLeader = winMgr:getWindow(tostring(id) .. "banditallitem2/main")
    self.m_wndSubMember1 = winMgr:getWindow(tostring(id) .. "banditallitem2/back/biaoshi")
    self.m_wndSubMember2 = winMgr:getWindow(tostring(id) .. "banditallitem2/back/biaoshi1")

    self.m_picRubTeamLeader = winMgr:getWindow(tostring(id) .. "banditallitem2/main/tubiao")
	self.m_txtRubTeamLeaderName = winMgr:getWindow(tostring(id) .. "banditallitem2/name2")
	self.m_txtCtRubTeamMember = winMgr:getWindow(tostring(id) .. "banditallitem2/main/TXT1")
    self.m_btnDismiss = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "banditallitem2/main/go"))
    self.m_btnDismiss:subscribeEvent("Clicked", BanditRubMyTeam.HandleClickeDismiss, self)

    self.m_txtSubMember1Name = winMgr:getWindow(tostring(id) .. "banditallitem2/name31")
    self.m_txtSubMember1Lv = winMgr:getWindow(tostring(id) .. "banditallitem2/name321")
    self.m_txtSubMember1School = winMgr:getWindow(tostring(id) .. "banditallitem2/name322")
    self.m_btnSubMember1Remind = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "banditallitem2/main/go11"))
    self.m_btnSubMember1Remind:subscribeEvent("Clicked", BanditRubMyTeam.HandleClickeRemind1, self)
    self.m_btnSubMember1Killout = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "banditallitem2/main/go1112"))
    self.m_btnSubMember1Killout:subscribeEvent("Clicked", BanditRubMyTeam.HandleClickeKillout1, self)
    self.m_btnSubMember1Quit = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "banditallitem2/main/go111"))
    self.m_btnSubMember1Quit:subscribeEvent("Clicked", BanditRubMyTeam.HandleClickeQuit1, self)
    
    self.m_txtSubMember2Name = winMgr:getWindow(tostring(id) .. "banditallitem2/name311")
    self.m_txtSubMember2Lv = winMgr:getWindow(tostring(id) .. "banditallitem2/name3211")
    self.m_txtSubMember2School = winMgr:getWindow(tostring(id) .. "banditallitem2/name3221")
    self.m_btnSubMember2Remind = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "banditallitem2/main/go112"))
    self.m_btnSubMember2Remind:subscribeEvent("Clicked", BanditRubMyTeam.HandleClickeRemind2, self)
    self.m_btnSubMember2Killout = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "banditallitem2/main/go1111"))
    self.m_btnSubMember2Killout:subscribeEvent("Clicked", BanditRubMyTeam.HandleClickeKillout2, self)
    self.m_btnSubMember2Quit = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "banditallitem2/main/go11121"))
    self.m_btnSubMember2Quit:subscribeEvent("Clicked", BanditRubMyTeam.HandleClickeQuit2, self)

	self.m_pWnd = self:GetWindow()
    
    self:ClearContent()
	LogInfo("exit BanditRubMyTeam OnCreate")
end

------------------- public: -----------------------------------

function BanditRubMyTeam:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BanditRubMyTeam)

    return self
end

function BanditRubMyTeam:HandleDismissConfirmClicked(args)
    LogInfo("____BanditRubMyTeam:HandleDismissConfirmClicked")
    
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
        
    local quitAction = CLeaveJBiaoTeam.Create()
    quitAction.roleid = 0
    quitAction.flag = 0
    LuaProtocolManager.getInstance():send(quitAction)

    return true
end

function BanditRubMyTeam:HandleClickeDismiss(args)
    LogInfo("____BanditRubMyTeam:HandleClickeDismiss")
    
    if not self.m_isTeamLeader then
        LogInfo("___error not teamleader")
        return true
    end
    
    GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145179),BanditRubMyTeam.HandleDismissConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)

    return true
end

function BanditRubMyTeam:HandleClickeRemind1(args)
    LogInfo("____BanditRubMyTeam:HandleClickeRemind1")
    
    if self.m_isTeamLeader then
        LogInfo("____error teamleader")
        return true
    end

    local startJBAction = CJBiaoStart.Create()
    startJBAction.biaochekey = 0
    LuaProtocolManager.getInstance():send(startJBAction)

    return true
end

function BanditRubMyTeam:HandleClickeRemind2(args)
    LogInfo("____BanditRubMyTeam:HandleClickeRemind2")
    
    if self.m_isTeamLeader then
        LogInfo("____error teamleader")
        return true
    end

    local startJBAction = CJBiaoStart.Create()
    startJBAction.biaochekey = 0
    LuaProtocolManager.getInstance():send(startJBAction)

    return true
end

function BanditRubMyTeam:HandleKillOutConfirmClicked(args)
    LogInfo("____BanditRubMyTeam:HandleKillOutConfirmClicked")
    
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    
    local quitAction = CLeaveJBiaoTeam.Create()
    quitAction.roleid = self.m_nCurWillKillOutRoleID
    quitAction.flag = 0
    LuaProtocolManager.getInstance():send(quitAction)

    return true
end

function BanditRubMyTeam:HandleClickeKillout1(args)
    LogInfo("____BanditRubMyTeam:HandleClickeKillout1")
    
    if not self.m_isTeamLeader then
        LogInfo("____error not teamleader")
        return true
    end
    
    if self.m_infoTeamMembers[2] and self.m_infoTeamMembers[2].roleid then
        self.m_nCurWillKillOutRoleID = self.m_infoTeamMembers[2].roleid
        GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145204),BanditRubMyTeam.HandleKillOutConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
    end
    
    return true
end

function BanditRubMyTeam:HandleClickeKillout2(args)
    LogInfo("____BanditRubMyTeam:HandleClickeKillout2")
    
    if not self.m_isTeamLeader then
        LogInfo("____error not teamleader")
        return true
    end
    
    if self.m_infoTeamMembers[3] and self.m_infoTeamMembers[3].roleid then
        self.m_nCurWillKillOutRoleID = self.m_infoTeamMembers[3].roleid
        GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145204),BanditRubMyTeam.HandleKillOutConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
    end

    return true
end

function BanditRubMyTeam:HandleQuitConfirmClicked(args)
    LogInfo("____BanditRubMyTeam:HandleQuitConfirmClicked")
    
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    
    local quitAction = CLeaveJBiaoTeam.Create()
    quitAction.roleid = 0
    quitAction.flag = 0
    LuaProtocolManager.getInstance():send(quitAction)

    return true
end

function BanditRubMyTeam:HandleClickeQuit1(args)
    LogInfo("____BanditRubMyTeam:HandleClickeQuit1")
    
    if self.m_isTeamLeader then
        LogInfo("____error teamleader")
        return true
    end
    
    GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145180),BanditRubMyTeam.HandleQuitConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)

    return true
end

function BanditRubMyTeam:HandleClickeQuit2(args)
    LogInfo("____BanditRubMyTeam:HandleClickeQuit2")
    
    if self.m_isTeamLeader then
        LogInfo("____error teamleader")
        return true
    end
    
    GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145180),BanditRubMyTeam.HandleQuitConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)

    return true
end

function BanditRubMyTeam:ClearContent()
    LogInfo("____BanditRubMyTeam:ClearContent")
    
    self.m_isTeamLeader = false
    self.m_nTeamLeaderRoleID = -1
    self.m_infoTeamMembers = nil
    self.m_wndTeamLeader:setVisible(false)
	self.m_wndSubMember1:setVisible(false)
	self.m_wndSubMember2:setVisible(false)
end

function BanditRubMyTeam:SetContent(leaderid, teamroles)
    
    LogInfo("____BanditRubMyTeam:SetContent")

    self:ClearContent()
    
    if leaderid == nil or teamroles == nil then
        return
    end
    
    LogInfo("____leaderid: " .. leaderid)
    
    if leaderid <= 0 then
        return
    end

    self.m_nTeamLeaderRoleID = leaderid
    if GetDataManager() and self.m_nTeamLeaderRoleID == GetDataManager():GetMainCharacterID() then
        self.m_isTeamLeader = true
    end

    self.m_infoTeamMembers = {}

    for k,v in pairs(teamroles) do
        if v.roleid == self.m_nTeamLeaderRoleID then
            self.m_infoTeamMembers[1] = v
        else
            if self.m_infoTeamMembers[2] == nil then
               self.m_infoTeamMembers[2] = v
            else
               self.m_infoTeamMembers[3] = v
            end
        end
    end
    
    local ctTeamMember = #self.m_infoTeamMembers
    if self.m_infoTeamMembers[1] and self.m_infoTeamMembers[1].roleid > 0 then
        self.m_wndTeamLeader:setVisible(true)
        local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(self.m_infoTeamMembers[1].shape)
        if shapeTmp.id ~= -1 then
            local strHead = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
            self.m_picRubTeamLeader:setProperty("Image",strHead)
        end
        
        self.m_txtRubTeamLeaderName:setText(self.m_infoTeamMembers[1].rolename)
        self.m_txtCtRubTeamMember:setText(tostring(ctTeamMember) .. "/3")
        
        self.m_btnDismiss:setEnabled(self.m_isTeamLeader)
    end
    
    if self.m_infoTeamMembers[2] and self.m_infoTeamMembers[2].roleid > 0 then
        self.m_wndSubMember1:setVisible(true)
        self.m_txtSubMember1Name:setText(self.m_infoTeamMembers[2].rolename)
        self.m_txtSubMember1Lv:setText(tostring(self.m_infoTeamMembers[2].level))
        
        local record = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(self.m_infoTeamMembers[2].school)
        if record and record.id ~= -1 and record.name then
            self.m_txtSubMember1School:setText(record.name)
        else
            self.m_txtSubMember1School:setText("")
        end
        
        self.m_btnSubMember1Killout:setVisible(self.m_isTeamLeader)
        self.m_btnSubMember1Quit:setVisible(not self.m_isTeamLeader)
        if GetDataManager() and self.m_infoTeamMembers[2].roleid == GetDataManager():GetMainCharacterID() then
            self.m_btnSubMember1Quit:setEnabled(true)
            self.m_btnSubMember1Remind:setEnabled(true)
        else
            self.m_btnSubMember1Quit:setEnabled(false)
            self.m_btnSubMember1Remind:setEnabled(false)
        end
    end

    if self.m_infoTeamMembers[3] and self.m_infoTeamMembers[3].roleid > 0 then
        self.m_wndSubMember2:setVisible(true)
        self.m_txtSubMember2Name:setText(self.m_infoTeamMembers[3].rolename)
        self.m_txtSubMember2Lv:setText(tostring(self.m_infoTeamMembers[3].level))
        
        local record = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(self.m_infoTeamMembers[3].school)
        if record and record.id ~= -1 and record.name then
            self.m_txtSubMember2School:setText(record.name)
        else
            self.m_txtSubMember2School:setText("")
        end
        
        self.m_btnSubMember2Killout:setVisible(self.m_isTeamLeader)
        self.m_btnSubMember2Quit:setVisible(not self.m_isTeamLeader)
        if GetDataManager() and self.m_infoTeamMembers[3].roleid == GetDataManager():GetMainCharacterID() then
            self.m_btnSubMember2Quit:setEnabled(true)
            self.m_btnSubMember2Remind:setEnabled(true)
        else
            self.m_btnSubMember2Quit:setEnabled(false)
            self.m_btnSubMember2Remind:setEnabled(false)
        end
    end
end

return BanditRubMyTeam






