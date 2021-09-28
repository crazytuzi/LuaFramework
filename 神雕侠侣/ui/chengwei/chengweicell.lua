--[[author: lvxiaolong
date: 2013/7/12
function: cheng wei cell
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.title.contitle"
require "protocoldef.knight.gsp.title.cofftitle"

ChengWeiCell = {

m_bLighted = false,
m_titleid = -1,
m_index = -1,

}

setmetatable(ChengWeiCell, Dialog)
ChengWeiCell.__index = ChengWeiCell

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function ChengWeiCell.CreateNewDlg(pParentDlg, id)
	LogInfo("____enter ChengWeiCell.CreateNewDlg")
	local newDlg = ChengWeiCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function ChengWeiCell.GetLayoutFileName()
    return "chengweicell.layout"
end

function ChengWeiCell:OnCreate(pParentDlg, id)
	LogInfo("enter ChengWeiCell oncreate" .. tostring(id))
	print("enter ChengWeiCell oncreate" .. tostring(id))
    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()
    
    -- get windows
	self.m_name = winMgr:getWindow(tostring(id) .. "chengweicell/btn/name")
	self.m_info = winMgr:getWindow(tostring(id) .. "chengweicell/btn/info")
	self.m_light = winMgr:getWindow(tostring(id) .. "chengweicell/btn/light")
    
    self.m_btn = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "chengweicell/btn"))
    self.m_btn:subscribeEvent("Clicked", ChengWeiCell.HandleClickeBtn, self)

	self.m_pWnd = self:GetWindow()
    
    self:ClearContent()
	LogInfo("exit ChengWeiCell OnCreate")
end

------------------- public: -----------------------------------

function ChengWeiCell.SendOnTitle(titleid)
    local onTitleAction = COnTitle.Create()
    onTitleAction.titleid = titleid
    LuaProtocolManager.getInstance():send(onTitleAction)
end

function ChengWeiCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChengWeiCell)

    return self
end

function ChengWeiCell:HandleClickeBtn()
    LogInfo("____ChengWeiCell:HandleClickeBtn")
    
    if self.m_bLighted then
        return true
    end
    
    if GetBattleManager() then
        if GetBattleManager():IsInBattle() or GetBattleManager():isOnBattleWatch() then
            GetGameUIManager():AddMessageTipById(145085)
            return true
        end
    end
    
    if self.m_titleid < 0 then
        local offTitleAction = COffTitle.Create()
        LuaProtocolManager.getInstance():send(offTitleAction)
    else
        local onTitleAction = COnTitle.Create()
        onTitleAction.titleid = self.m_titleid
        LuaProtocolManager.getInstance():send(onTitleAction)
    end

    --[[local dlgChengwei = ChengWeiDlg.getInstanceNotCreate()
    if dlgChengwei then
        dlgChengwei:RecordCurScrollBarPos()
        dlgChengwei:RefreshIndexToBeLighted(self.m_index)
    end]]

    return true
end

function ChengWeiCell:ClearContent()
    LogInfo("____ChengWeiCell:ClearContent")

    self.m_name:setVisible(false)
    self.m_info:setVisible(false)
    self.m_light:setVisible(false)
    
    self.m_bLighted = false
    self.m_titleid = -1
    self.m_index = -1
end

function ChengWeiCell:SetContent(titleid, isCurTitleID, index)

    LogInfo("____ChengWeiCell:SetContent")
    
    print("____titleid: " .. titleid .. "isCurTitleID: " .. tostring(isCurTitleID) .. "index: " .. index)

    self:ClearContent()
    
    self.m_titleid = titleid
    self.m_bLighted = isCurTitleID
    self.m_index = index
    
    if self.m_titleid < 0 then
        self.m_light:setVisible(self.m_bLighted)
        self.m_name:setVisible(true)
        self.m_info:setVisible(true)
        self.m_name:setText(MHSD_UTILS.get_resstring(2887))
        self.m_info:setText(MHSD_UTILS.get_resstring(2888))
    else
        local titleRecord = knight.gsp.title.GetCTitleConfigTableInstance():getRecorder(self.m_titleid)
        if titleRecord.id ~= -1 then
            self.m_light:setVisible(self.m_bLighted)
            
            self.m_name:setVisible(true)
            self.m_info:setVisible(true)
            
            self.m_name:setText(titleRecord.titlename)
            self.m_info:setText(titleRecord.description)
        end
    end
end

function ChengWeiCell:GetTitleID()
    LogInfo("____ChengWeiCell:GetTitleID")
    
    return self.m_titleid
end

function ChengWeiCell:SetLightProperty(bLighted)
    LogInfo("____ChengWeiCell:SetLightProperty")

    self.m_bLighted = bLighted
    self.m_light:setVisible(self.m_bLighted)
end

return ChengWeiCell






