local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PromoteGuide = Lplus.Extend(ECPanelBase, "PromoteGuide")
local Vector = require("Types.Vector")
local GuideModule = Lplus.ForwardDeclare("GuideModule")
local def = PromoteGuide.define
local instance
def.static("=>", PromoteGuide).Instance = function()
  if instance == nil then
    instance = PromoteGuide()
  end
  return instance
end
def.field("number").x = 0
def.field("number").y = 0
def.static("number", "number").ShowPromote = function(x, y)
  local dlg = PromoteGuide.Instance()
  dlg.x = x
  dlg.y = y
  if dlg.m_panel then
    dlg:UpdateButtons()
    dlg:UpdatePosition()
  else
    dlg:CreatePanel(RESPATH.PREFAB_UP_GUIDE, 0)
    dlg:SetOutTouchDisappear()
  end
end
def.override().OnCreate = function(self)
  self:UpdateButtons()
  self:UpdatePosition()
end
def.method().UpdatePosition = function(self)
  local body = self.m_panel:FindDirect("Img_Bg1")
  local height = body:GetComponent("UIWidget"):get_height()
  body:set_localPosition(Vector.Vector3.new(self.x, self.y - height / 2 - 48, 0))
end
def.method().ClearButtons = function(self)
  local grid = self.m_panel:FindDirect("Img_Bg1/Scroll View/Grid")
  while grid:get_childCount() > 1 do
    Object.DestroyImmediate(grid:GetChild(grid:get_childCount() - 1))
  end
end
def.method().UpdateButtons = function(self)
  if not next(GuideModule.Instance().advWays) then
    self:DestroyPanel()
    return
  end
  self:ClearButtons()
  local grid = self.m_panel:FindDirect("Img_Bg1/Scroll View/Grid")
  local template = grid:FindDirect("Group_Btn")
  template:SetActive(false)
  for k, v in pairs(GuideModule.Instance().advWays) do
    if v then
      local itemNew = Object.Instantiate(template)
      itemNew:SetActive(true)
      itemNew.parent = grid
      local index = k
      itemNew:set_name("Group_Btn_" .. index)
      itemNew:set_localScale(Vector.Vector3.one)
      local delete = itemNew:FindDirect("Btn_Close")
      delete:set_name("Btn_Close_" .. index)
      local name = itemNew:FindDirect("Btn_Up/Label")
      name:GetComponent("UILabel"):set_text(textRes.Guide.Up[index])
      local btn = itemNew:FindDirect("Btn_Up")
      btn:set_name("Btn_Up_" .. index)
    end
  end
  grid:GetComponent("UIGrid"):Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Btn_Close_") then
    local index = tonumber(string.sub(id, 11))
    GuideModule.Instance().advWays[index] = nil
    self:UpdateButtons()
    local hasAdv = next(GuideModule.Instance().advWays)
    Event.DispatchEvent(ModuleId.GUIDE, gmodule.notifyId.Guide.New_Promote_Way, {hasAdv})
  elseif string.find(id, "Btn_Up_") then
    local index = tonumber(string.sub(id, 8))
    if index == GuideModule.AdvanceConst.HERO then
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_ROLE_PROP_CLICK, nil)
    elseif index == GuideModule.AdvanceConst.PET then
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_PET_PROP_CLICK, nil)
    elseif index == GuideModule.AdvanceConst.SKILL then
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SKILL_CLICK, nil)
    end
  end
end
PromoteGuide.Commit()
return PromoteGuide
