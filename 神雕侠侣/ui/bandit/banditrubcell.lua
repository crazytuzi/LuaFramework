--[[author: lvxiaolong
date: 2013/9/5
function: bandit rub cell
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"

BanditRubCell = {
    m_nCarKey = -1,
    m_nCarType = -1,
}

setmetatable(BanditRubCell, Dialog)
BanditRubCell.__index = BanditRubCell

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function BanditRubCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter BanditRubCell.CreateNewDlg")
	local newDlg = BanditRubCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function BanditRubCell.GetLayoutFileName()
    return "banditallitem.layout"
end

function BanditRubCell:OnCreate(pParentDlg, id)
	LogInfo("enter BanditRubCell oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()
    
    -- get windows
    self.m_picCarType = winMgr:getWindow(tostring(id) .. "banditallitem/main/tubiao")
	self.m_txtCarName = winMgr:getWindow(tostring(id) .. "banditallitem/name1")
	self.m_txtReward = winMgr:getWindow(tostring(id) .. "banditallitem/main/TXT1")
    
    self.m_txtLeaderName = winMgr:getWindow(tostring(id) .. "banditallitem/name2")
    self.m_picCamp = winMgr:getWindow(tostring(id) .. "banditallitem/main/zhenying")
    self.m_txtFaction = winMgr:getWindow(tostring(id) .. "banditallitem/name21")
    self.m_txtAverageLv = winMgr:getWindow(tostring(id) .. "banditallitem/name211")

    self.m_btnRub = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "banditallitem/main/go"))
    self.m_btnRub:subscribeEvent("Clicked", BanditRubCell.HandleClickeRub, self)

	self.m_pWnd = self:GetWindow()
    
    self:ClearContent()
	LogInfo("exit BanditRubCell OnCreate")
end

------------------- public: -----------------------------------

function BanditRubCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BanditRubCell)

    return self
end

function BanditRubCell:HandleClickeRub(args)
    LogInfo("____BanditRubCell:HandleClickeRub")
    
    local startJBAction = CJBiaoStart.Create()
    startJBAction.biaochekey = self.m_nCarKey
    LuaProtocolManager.getInstance():send(startJBAction)

    return true
end

function BanditRubCell:ClearContent()
    LogInfo("____BanditRubCell:ClearContent")
    
    self.m_nCarKey = -1
    self.m_nCarType = -1
    self.m_picCarType:setVisible(false)
	self.m_txtCarName:setVisible(false)
	self.m_txtReward:setVisible(false)
    self.m_txtLeaderName:setVisible(false)
    self.m_picCamp:setVisible(false)
    self.m_txtFaction:setVisible(false)
    self.m_txtAverageLv:setVisible(false)
    self.m_btnRub:setVisible(false)
end

function BanditRubCell:SetContent(nCarKey, nCarType, strLeaderName, nCamp, strFaction, nAverageLv)

    LogInfo("____BanditRubCell:SetContent")

    self:ClearContent()
    
    if nCarType == nil or strLeaderName == nil or nCamp == nil or strFaction == nil or nAverageLv == nil then
        return
    end

    LogInfo("____nCarType: " .. nCarType .. " strLeaderName: " .. strLeaderName)
    LogInfo("____nCamp: " .. nCamp .. " strFaction: " .. strFaction .. " nAverageLv: " .. nAverageLv)

    self.m_nCarKey = nCarKey
    self.m_nCarType = nCarType

    if nCarType == 0 then
        self.m_picCarType:setVisible(true)
        self.m_picCarType:setProperty("Image", "set:MainControl16 image:yibanbiaoche")
        self.m_txtCarName:setVisible(true)
        self.m_txtCarName:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2908).msg)
        self.m_txtReward:setVisible(true)
        self.m_txtReward:setText(MHSD_UTILS.get_resstring(2964))
    elseif nCarType == 1 then
        self.m_picCarType:setVisible(true)
        self.m_picCarType:setProperty("Image", "set:MainControl16 image:zhenbaobiaoche")
        self.m_txtCarName:setVisible(true)
        self.m_txtCarName:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2909).msg)
        self.m_txtReward:setVisible(true)
        self.m_txtReward:setText(MHSD_UTILS.get_resstring(2965))
    end
    
    self.m_txtLeaderName:setVisible(true)
    self.m_txtLeaderName:setText(strLeaderName)

    if nCamp == 1 then
        self.m_picCamp:setVisible(true)
        self.m_picCamp:setProperty("Image", "set:MainControl image:campred")
    elseif nCamp == 2 then
        self.m_picCamp:setVisible(true)
        self.m_picCamp:setProperty("Image", "set:MainControl image:campblue")
    end
    
    self.m_txtFaction:setVisible(true)
    self.m_txtFaction:setText(strFaction)
    
    self.m_txtAverageLv:setVisible(true)
    self.m_txtAverageLv:setText(tostring(nAverageLv))
    
    self.m_btnRub:setVisible(true)
end

return BanditRubCell






