require "ui.dialog"
require "utils.mhsdutils"

JieyiAllTipsDialog = {}

setmetatable(JieyiAllTipsDialog, Dialog)
JieyiAllTipsDialog.__index = JieyiAllTipsDialog

local _instance;
function JieyiAllTipsDialog.getInstance()
    if not _instance then
        _instance = JieyiAllTipsDialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function JieyiAllTipsDialog.getInstanceAndShow()
    if not _instance then
        _instance = JieyiAllTipsDialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
        _instance.m_pMainFrame:setAlpha(1)
    end

    return _instance
end

function JieyiAllTipsDialog.getInstanceNotCreate()
    return _instance
end

function JieyiAllTipsDialog.DestroyDialog()
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function JieyiAllTipsDialog.ToggleOpenClose()
    if not _instance then 
        _instance = JieyiAllTipsDialog:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JieyiAllTipsDialog.GetLayoutFileName()
    return "jiebaizongtip.layout"
end

function JieyiAllTipsDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JieyiAllTipsDialog)

    return self
end

function JieyiAllTipsDialog:OnCreate()
  Dialog.OnCreate(self)
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  self.m_txt = {}
  for i=1, 7 do
    self.m_txt[i] = winMgr:getWindow("jiebaizongtip/back/text" .. tostring(i))
  end
end

function JieyiAllTipsDialog:SetLevel(level)
  if level and level >= 1 and level <= 7 then
    self.m_txt[level]:setProperty("TextColours", "tl:FFFFFEF1 tr:FFFFFEF1 bl:FFF4D751 br:FFF4D751")
  end
end

return JieyiAllTipsDialog
