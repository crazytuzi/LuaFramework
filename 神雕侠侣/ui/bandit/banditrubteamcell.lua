--[[author: lvxiaolong
date: 2013/9/5
function: bandit rub team cell
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.faction.cjoinjbiaoteam"

BanditRubTeamCell = {

m_nRubLeaderRoleID = -1,

}

setmetatable(BanditRubTeamCell, Dialog)
BanditRubTeamCell.__index = BanditRubTeamCell

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function BanditRubTeamCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter BanditRubTeamCell.CreateNewDlg")
	local newDlg = BanditRubTeamCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function BanditRubTeamCell.GetLayoutFileName()
    return "banditallsmallitem2.layout"
end

function BanditRubTeamCell:OnCreate(pParentDlg, id)
	LogInfo("enter BanditRubTeamCell oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()
    
    -- get windows
    self.m_picRubLeader = winMgr:getWindow(tostring(id) .. "banditallsmallitem2/main/tubiao")
	self.m_txtRubLeaderName = winMgr:getWindow(tostring(id) .. "banditallsmallitem2/name2")
	self.m_txtCtRubTeam = winMgr:getWindow(tostring(id) .. "banditallsmallitem2/main/TXT1")

    self.m_btnJoin = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "banditallsmallitem2/main/go1"))
    self.m_btnJoin:subscribeEvent("Clicked", BanditRubTeamCell.HandleClickeJoin, self)

	self.m_pWnd = self:GetWindow()

    self:ClearContent()
	LogInfo("exit BanditRubTeamCell OnCreate")
end

------------------- public: -----------------------------------

function BanditRubTeamCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BanditRubTeamCell)

    return self
end

function BanditRubTeamCell:HandleClickeJoin(args)
    LogInfo("____BanditRubTeamCell:HandleClickeJoin")

    local joinAction = CJoinJBiaoTeam.Create()
    joinAction.leaderid = self.m_nRubLeaderRoleID
    LuaProtocolManager.getInstance():send(joinAction)

    return true
end

function BanditRubTeamCell:ClearContent()
    LogInfo("____BanditRubTeamCell:ClearContent")
    
    self.m_nRubLeaderRoleID = -1
    self.m_picRubLeader:setVisible(false)
	self.m_txtRubLeaderName:setVisible(false)
	self.m_txtCtRubTeam:setVisible(false)
    self.m_btnJoin:setVisible(false)
end

function BanditRubTeamCell:SetContent(nRubLeaderRoleID, nShape, strRubLeaderName, nCtRubTeam)
    
    LogInfo("____BanditRubTeamCell:SetContent")

    self:ClearContent()
    
    if nRubLeaderRoleID == nil or nShape == nil or strRubLeaderName == nil or nCtRubTeam == nil then
        return
    end
    
    LogInfo("____nRubLeaderRoleID: " .. nRubLeaderRoleID .. " nShape: " .. nShape)
    LogInfo("____strRubLeaderName: " .. strRubLeaderName .. " nCtRubTeam: " .. nCtRubTeam)

    self.m_nRubLeaderRoleID = nRubLeaderRoleID
    
    local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(nShape)
    if shapeTmp.id~=-1 then
        local strHead = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
        self.m_picRubLeader:setVisible(true)
        self.m_picRubLeader:setProperty("Image",strHead)
    end
    
    self.m_txtRubLeaderName:setVisible(true)
    self.m_txtRubLeaderName:setText(strRubLeaderName)
    
    if nCtRubTeam >= 0 then
        self.m_txtCtRubTeam:setVisible(true)
        self.m_txtCtRubTeam:setText(tostring(nCtRubTeam) .. "/3")
    end

    self.m_btnJoin:setVisible(true)
end

return BanditRubTeamCell






