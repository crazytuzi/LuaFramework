-- wulintipsdlg.lua
-- It is a tip for wulinmiji jingjie
-- create by wuyao in 2014-4-2
require "ui.dialog"
require "utils.mhsdutils"

WulinTipsDlg = {}

setmetatable(WulinTipsDlg, Dialog)
WulinTipsDlg.__index = WulinTipsDlg

-- For singleton
local _instance;
function WulinTipsDlg.getInstance()
    if not _instance then
        _instance = WulinTipsDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function WulinTipsDlg.getInstanceAndShow()
    if not _instance then
        _instance = WulinTipsDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
        _instance.m_pMainFrame:setAlpha(1)
    end

    return _instance
end

function WulinTipsDlg.getInstanceNotCreate()
    return _instance
end

function WulinTipsDlg.DestroyDialog()
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function WulinTipsDlg.ToggleOpenClose()
    if not _instance then 
        _instance = WulinTipsDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function WulinTipsDlg.GetLayoutFileName()
    return "itemtipsdialognew.layout"
end

function WulinTipsDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WulinTipsDlg)

    return self
end

function WulinTipsDlg:OnCreate()

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.WLMgr = WulinmijiManager.getInstance()

    self.m_txtName = winMgr:getWindow("ItemTipsnew/name")
    self.m_txtNextName = winMgr:getWindow("ItemTipsnew/back/text2")
    self.m_revDesc = CEGUI.toRichEditbox(winMgr:getWindow("ItemTipsnew"))
    self.m_revNextDesc = CEGUI.toRichEditbox(winMgr:getWindow("ItemTipsnew1"))
    self.m_revNeed = CEGUI.toRichEditbox(winMgr:getWindow("ItemTipsnew2"))

    self.m_txtName:setText("")
    self.m_txtNextName:setText("")
    self.m_revDesc:Clear()
    self.m_revNextDesc:Clear()

    local jingjie = self.WLMgr:GetJingjie()
    local jingjieSum = self.WLMgr:GetJingjieSum()

    local curJingjieBean = nil
    local nextJingjieBean = nil

    curJingjieBean = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijijingjie"):getRecorder(jingjie)
    if curJingjieBean.nextskillid ~= 0 then
        nextJingjieBean = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijijingjie"):getRecorder(curJingjieBean.nextskillid)
    else
        nextJingjieBean = curJingjieBean
    end

    if curJingjieBean ~= nil then
        self.m_txtName:setText(curJingjieBean.jingjiename)
        self.m_revDesc:Clear()
        self.m_revDesc:AppendText(CEGUI.String(curJingjieBean.describe))
        self.m_revDesc:Refresh()
    end

    if curJingjieBean.nextskillid ~= 0 then
        self.m_txtNextName:setText(nextJingjieBean.jingjiename)
        self.m_revNextDesc:Clear()
        self.m_revNextDesc:AppendText(CEGUI.String(nextJingjieBean.describe))
        self.m_revNextDesc:Refresh()
        local msg = MHSD_UTILS.get_resstring(3059)
        msg = string.gsub(msg, "%$parameter1%$", tostring(nextJingjieBean.needjjd-jingjieSum))
        self.m_revNeed:Clear()
        self.m_revNeed:AppendText(CEGUI.String(msg))
        self.m_revNeed:Refresh()
    else
        self.m_txtNextName:setText(MHSD_UTILS.get_resstring(3060))
        self.m_revNextDesc:Clear()
        self.m_revNextDesc:AppendText(CEGUI.String(""))
        self.m_revNextDesc:Refresh()
        self.m_revNeed:Clear()
        self.m_revNeed:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(3060)))
        self.m_revNeed:Refresh()
    end
end

return WulintipsDlg