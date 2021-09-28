require "ui.dialog"
require "utils.mhsdutils"

JieyiPersonTipsDialog = {}

setmetatable(JieyiPersonTipsDialog, Dialog)
JieyiPersonTipsDialog.__index = JieyiPersonTipsDialog

local _instance;
function JieyiPersonTipsDialog.getInstance()
    if not _instance then
        _instance = JieyiPersonTipsDialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function JieyiPersonTipsDialog.getInstanceAndShow()
    if not _instance then
        _instance = JieyiPersonTipsDialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
        _instance.m_pMainFrame:setAlpha(1)
    end

    return _instance
end

function JieyiPersonTipsDialog.getInstanceNotCreate()
    return _instance
end

function JieyiPersonTipsDialog.DestroyDialog()
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function JieyiPersonTipsDialog.ToggleOpenClose()
    if not _instance then 
        _instance = JieyiPersonTipsDialog:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JieyiPersonTipsDialog.GetLayoutFileName()
    return "jiebaigerentip.layout"
end

function JieyiPersonTipsDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JieyiPersonTipsDialog)

    return self
end

function JieyiPersonTipsDialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_txtLevel = winMgr:getWindow("jiebaigerentip/back/level")
    self.m_txtEffect1 = winMgr:getWindow("jiebaigerentip/back/effect1")
    self.m_txtEffectNone1 = winMgr:getWindow("jiebaigerentip/back/none")
    self.m_txtEffectNone1:setVisible(false)
    
    self.m_txtEffect2 = winMgr:getWindow("jiebaigerentip/back/effect2")
    self.m_txtEffectNone2 = winMgr:getWindow("jiebaigerentip/back/limit")
    self.m_txtEffectNone2:setVisible(false)
end

function JieyiPersonTipsDialog:SetLevel(level)
  if level == nil or level <= 0 or level > 7 then
    level = 0
  end
  
  if level == 0 then
     self.m_txtLevel:setText(MHSD_UTILS.get_resstring(3148))
     self.m_txtEffectNone1:setVisible(true)
     self.m_txtEffect1:setVisible(false)
     
     local rec = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cpersenaltip"):getRecorder(1)
     self.m_txtEffect2:setText(rec.effecttip)
     return
  end
  
  if level == 7 then
     self.m_txtEffectNone2:setVisible(true)
     self.m_txtEffect2:setVisible(false)
     
     local rec = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cpersenaltip"):getRecorder(level)
     self.m_txtLevel:setText(rec.title)
     self.m_txtEffect1:setText(rec.effecttip)
     return
  end
  
  local rec = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cpersenaltip"):getRecorder(level)
  local rec2 = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cpersenaltip"):getRecorder(level + 1)
  self.m_txtLevel:setText(rec.title)
  self.m_txtEffect1:setText(rec.effecttip)
  self.m_txtEffect2:setText(rec2.effecttip)
end

return JieyiPersonTipsDialog
