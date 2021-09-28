--[[author: lvxiaolong
date: 2013/8/6
function: quick team cell
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.team.bianjie.cbjinvitation"

QuickTeamCell = {

m_roleid = 0,

}

setmetatable(QuickTeamCell, Dialog)
QuickTeamCell.__index = QuickTeamCell

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function QuickTeamCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter QuickTeamCell.CreateNewDlg")
	local newDlg = QuickTeamCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function QuickTeamCell.GetLayoutFileName()
    return "quickteamcell.layout"
end

function QuickTeamCell:OnCreate(pParentDlg, id)
	LogInfo("enter QuickTeamCell oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()
    
    -- get windows
    self.m_txtName = winMgr:getWindow(tostring(id) .. "quickteamcell/back/name")
	self.m_txtSchool = winMgr:getWindow(tostring(id) .. "quickteamcell/back/school")
	self.m_txtLevel = winMgr:getWindow(tostring(id) .. "quickteamcell/back/level")
    self.m_txtLevelTitle = winMgr:getWindow(tostring(id) .. "quickteamcell/back/text")
    self.m_picCamp = winMgr:getWindow(tostring(id) .. "quickteamcell/back/camp")

    self.m_btnInvite = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "quickteamcell/back/btn"))
    self.m_btnInvite:subscribeEvent("Clicked", QuickTeamCell.HandleClickeInvite, self)

	self.m_pWnd = self:GetWindow()
    
    self:ClearContent()
	LogInfo("exit QuickTeamCell OnCreate")
end

------------------- public: -----------------------------------

function QuickTeamCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, QuickTeamCell)

    return self
end

function QuickTeamCell:HandleClickeInvite(args)
    LogInfo("____QuickTeamCell:HandleClickeInvite")
    
    LogInfo("____g_curQTeamServiceID: " .. g_curQTeamServiceID .. "self.m_roleid: " .. self.m_roleid)

    if g_curQTeamServiceID < 0 or self.m_roleid <= 0 then
        LogInfo("___error in QuickTeamCell:HandleClickeInvite")
        return true
    end
    
    local bNeedSendInvite = true
    if GetTeamManager() then
        if GetTeamManager():IsMyselfLeader() or not GetTeamManager():IsOnTeam() then
            if GetTeamManager():IsTeamFull() then
                GetGameUIManager():AddMessageTipById(141197)
                bNeedSendInvite = false
            elseif GetTeamManager():IsAlreadyInviteCharacter(self.m_roleid) then
                GetGameUIManager():AddMessageTipById(141204)
                bNeedSendInvite = false
            end
        else
            GetGameUIManager():AddMessageTipById(141206)
            bNeedSendInvite = false
        end
    end
    
    if bNeedSendInvite then
        local inviteAction = CBJInvitation.Create()
        inviteAction.serviceid = g_curQTeamServiceID
        inviteAction.roleid = self.m_roleid
        LuaProtocolManager.getInstance():send(inviteAction)
    end

    return true
end

function QuickTeamCell:ClearContent()
    LogInfo("____QuickTeamCell:ClearContent")
    
    self.m_txtName:setVisible(false)
	self.m_txtSchool:setVisible(false)
	self.m_txtLevel:setVisible(false)
    self.m_txtLevelTitle:setVisible(false)
    self.m_picCamp:setVisible(false)
    self.m_btnInvite:setVisible(false)
end

function QuickTeamCell:SetContent(nRoleID, strName, nLevel, nSchool, nCamp)
    
    LogInfo("____QuickTeamCell:SetContent")

    self:ClearContent()
    
    if nRoleID == nil or strName == nil or nLevel == nil or nSchool == nil or nCamp == nil then
        return
    end
    
    LogInfo("____nRoleID: " .. nRoleID .. " strName: " .. strName .. " nLevel: " .. nLevel .. " nSchool: " .. nSchool .. " nCamp: " .. nCamp)

    self.m_roleid = nRoleID

    self.m_txtName:setVisible(true)
	self.m_txtLevel:setVisible(true)
    self.m_txtLevelTitle:setVisible(true)
    
    if GetDataManager() and self.m_roleid == GetDataManager():GetMainCharacterID() then
        self.m_btnInvite:setVisible(false)
    else
        self.m_btnInvite:setVisible(true)
    end
    
    self.m_txtName:setText(strName)
    self.m_txtLevel:setText(tostring(nLevel))

	local record = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(nSchool)
    if record and record.id ~= -1 and record.name then
        self.m_txtSchool:setVisible(true)
        self.m_txtSchool:setText(record.name)
    end
    
    if nCamp == 1 then
        self.m_picCamp:setVisible(true)
        self.m_picCamp:setProperty("Image", "set:MainControl image:campred")
    elseif nCamp == 2 then
        self.m_picCamp:setVisible(true)
        self.m_picCamp:setProperty("Image", "set:MainControl image:campblue")
    end
end

return QuickTeamCell






