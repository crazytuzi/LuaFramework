local Lplus = require("Lplus")
local ECPanelFlashTip = require("GUI.ECPanelFlashTip")
local EC = require("Types.Vector3")
local FlashTipMan = Lplus.Class("FlashTipMan")
local def = FlashTipMan.define
def.const("number").TOPDEPTH = 65000
def.field("table").m_FlashTipCache = nil
def.field("string").m_Category = ""
def.field("userdata").m_FlashTipParent = nil
local maxFlashTipNum = 4
local s_man
def.static("userdata", "=>", FlashTipMan).new = function(parentNode)
  s_man = FlashTipMan()
  s_man.m_FlashTipCache = {}
  s_man.m_FlashTipParent = parentNode
  return s_man
end
def.static("=>", FlashTipMan).Instance = function()
  return s_man
end
def.static("number", "string", "string").FlashTip = function(duration, content, category)
  if s_man then
    s_man:AddFalshTip(duration, content, category)
  end
end
def.static().ResetFlashTipCache = function()
  local self = FlashTipMan.Instance()
  for _, v in pairs(self.m_FlashTipCache) do
    if v.instance then
      v.instance:DestroyPanel()
    end
  end
  self.m_FlashTipCache = {}
end
def.method("number", "string", "string").AddFalshTip = function(self, duration, content, category)
  self.m_Category = category
  local instance = ECPanelFlashTip.new()
  instance:UpdateContent(duration, content, category)
  instance:CreateFlashTip()
end
def.method("table").RemoveFlashTip = function(self, instance)
  local index = 0
  for k, v in pairs(self.m_FlashTipCache) do
    if v.instance == instance then
      index = k
      break
    end
  end
  if index ~= 0 then
    local flashTip = table.remove(self.m_FlashTipCache)
    flashTip.instance:DestroyPanel()
  end
end
def.method("string").RemoveFlashTipByCategory = function(self, category)
  if category ~= "" then
    local index = 0
    for k, v in pairs(self.m_FlashTipCache) do
      if v.instance.m_category == category then
        index = k
        break
      end
    end
    if index ~= 0 then
      local flashTip = table.remove(self.m_FlashTipCache)
      flashTip.instance:DestroyPanel()
    end
  else
  end
end
def.method("table").InsertFlashTipList = function(self, instance)
  if not instance then
    return
  end
  local flashTip = instance.panel
  if not flashTip then
    return
  end
  if #self.m_FlashTipCache >= maxFlashTipNum then
    local flashTip = table.remove(self.m_FlashTipCache)
    flashTip.instance:DestroyPanel()
  end
  self:RemoveFlashTipByCategory(self.m_Category)
  flashTip.parent = self.m_FlashTipParent
  table.insert(self.m_FlashTipCache, 1, instance)
  local basicPosition = EC.Vector3.new(0, 0, 0)
  for i = 1, #self.m_FlashTipCache do
    local panel = self.m_FlashTipCache[i].panel
    if panel then
      panel.localPosition = basicPosition + EC.Vector3.new(0, 40, 0) * (i - 1)
      panel:GetComponent("UIPanel").depth = FlashTipMan.TOPDEPTH
    end
  end
end
FlashTipMan.Commit()
return FlashTipMan
