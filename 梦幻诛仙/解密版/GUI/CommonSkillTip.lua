local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local CommonSkillTip = Lplus.Extend(ECPanelBase, "CommonSkillTip")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = CommonSkillTip.define
def.const("table").Type = {
  RoleSkill = 1,
  PetSkill = 2,
  SimpleSkill = 3
}
def.field("number").skillType = 0
def.field("number").iconId = 0
def.field("string").name = ""
def.field("number").level = 0
def.field("string").description = ""
def.field("string").type = ""
def.field("string").consume = ""
def.field("boolean").isUnlock = true
def.field("string").unlockTip = ""
def.field("table").operations = nil
def.field("number").sourceX = 0
def.field("number").sourceY = 0
def.field("number").sourceW = 0
def.field("number").sourceH = 0
def.field("number").prefer = 0
def.field("table").pos = nil
local instance
def.static("=>", CommonSkillTip).Instance = function()
  if instance == nil then
    instance = CommonSkillTip()
  end
  return instance
end
def.method("number", "string", "number", "string", "string", "string", "boolean", "string", "number", "number", "number", "number", "number").ShowPanel = function(self, iconId, name, level, description, type, consume, isUnlock, unlockTip, sourceX, sourceY, sourceW, sourceH, prefer)
  self.skillType = CommonSkillTip.Type.RoleSkill
  self.iconId = iconId
  self.name = name
  self.level = level
  self.description = description
  self.type = type
  self.consume = consume
  self.isUnlock = isUnlock
  self.unlockTip = unlockTip
  self.sourceX = sourceX
  self.sourceY = sourceY
  self.sourceW = sourceW
  self.sourceH = sourceH
  self.prefer = prefer
  if self:IsShow() then
    self:UpdatePanel()
    self:UpdatePos()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_COMMON_SKILL_TIP_RES, 2)
  self:SetOutTouchDisappear()
end
def.method("number", "string", "string", "string", "string", "boolean", "string", "table", "table").ShowSimplePanel = function(self, iconId, name, description, type, consume, isUnlock, unlockTip, pos, operations)
  local sourceX, sourceY, sourceW, sourceH, prefer = pos.sourceX, pos.sourceY, pos.sourceW, pos.sourceH, pos.prefer
  self.skillType = CommonSkillTip.Type.SimpleSkill
  self.iconId = iconId
  self.name = name
  self.description = description
  self.type = type
  self.consume = consume
  self.isUnlock = isUnlock
  self.unlockTip = unlockTip
  self.sourceX = sourceX
  self.sourceY = sourceY
  self.sourceW = sourceW
  self.sourceH = sourceH
  self.prefer = prefer
  self.operations = operations
  if self:IsShow() then
    self:UpdatePanel()
    self:UpdatePos()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_COMMON_SKILL_TIP_RES, 2)
  self:SetOutTouchDisappear()
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  local uiSprite = self.m_panel:FindDirect("Img_Bg0"):GetComponent("UISprite")
  uiSprite:set_alpha(0)
end
def.override("boolean").OnShow = function(self, s)
  if not s then
    return
  end
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not self.m_panel then
      return
    end
    local uiSprite = self.m_panel:FindDirect("Img_Bg0"):GetComponent("UISprite")
    uiSprite:set_alpha(1)
    self:UpdatePanel()
    self:UpdatePos()
  end)
end
def.override().OnDestroy = function(self)
  self.operations = nil
end
def.method("string").onClick = function(self, id)
  if string.sub(id, 1, #"Btn_") == "Btn_" then
    local index = tonumber(string.sub(id, #"Btn_" + 1, -1))
    self:OnButtonClicked(index)
  end
end
def.method("number", "number").SetPos = function(self, x, y)
  if not self:IsShow() then
    self.pos = self.pos or {}
    self.pos.x = x
    self.pos.y = y
    return
  end
  self.m_panel.transform.localPosition = Vector.Vector3.new(x, y, 0)
end
def.method().UpdatePos = function(self)
  local tipFrame = self.m_panel:FindDirect("Img_Bg0")
  if self.pos ~= nil then
    tipFrame.transform:set_localPosition(Vector.Vector3.new(self.pos.x, self.pos.y, 0))
  else
    print()
    local tipWidth = tipFrame:GetComponent("UISprite"):get_width()
    local tipHeight = tipFrame:GetComponent("UISprite"):get_height()
    local targetX, targetY = require("Common.MathHelper").ComputeTipsAutoPosition(self.sourceX, self.sourceY, self.sourceW, self.sourceH, tipWidth, tipHeight, self.prefer)
    targetY = targetY + tipHeight / 2
    tipFrame:set_localPosition(Vector.Vector3.new(targetX, targetY, 0))
  end
end
def.method().UpdatePanel = function(self)
  local ui_Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local ui_Container = ui_Img_Bg0:FindDirect("Container")
  local Group_Btn = ui_Img_Bg0:FindDirect("Group_Btn")
  local uiTexture = ui_Container:FindDirect("Img_BgIcon/Img_Icon"):GetComponent("UITexture")
  if uiTexture then
    require("GUI.GUIUtils").FillIcon(uiTexture, self.iconId)
    if self.isUnlock then
      uiTexture:set_color(Color.Color(1, 1, 1, 1))
    else
      uiTexture:set_color(Color.Color(0.3, 0.3, 0.3, 1))
    end
  end
  if self.skillType == CommonSkillTip.Type.RoleSkill then
    if self.level >= 0 then
      ui_Container:FindDirect("Label_Lv"):GetComponent("UILabel"):set_text(string.format(textRes.Common[3], self.level))
    else
      ui_Container:FindDirect("Label_Lv"):GetComponent("UILabel"):set_text("")
    end
    ui_Container:FindDirect("Label_Type"):GetComponent("UILabel"):set_text(self.type)
  else
    ui_Container:FindDirect("Label_Lv"):GetComponent("UILabel"):set_text("")
    ui_Container:FindDirect("Label_Type"):GetComponent("UILabel"):set_text(self.type)
  end
  ui_Container:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(self.name)
  ui_Container:FindDirect("Label_Use"):GetComponent("UILabel"):set_text(self.consume)
  local ui_Img_Lock = ui_Container:FindDirect("Img_Lock")
  local ui_Label_DescribeLock = ui_Img_Bg0:FindDirect("Label_DescribeLock")
  GUIUtils.SetActive(ui_Label_DescribeLock, false)
  local description = self.description
  if self.isUnlock then
    ui_Img_Lock:SetActive(false)
  else
    ui_Img_Lock:SetActive(true)
    description = string.format([[
%s

%s]], description, self.unlockTip)
  end
  GUIUtils.SetText(ui_Img_Bg0:FindDirect("Label_Describe"), description)
  if self.operations == nil or #self.operations == 0 then
    GUIUtils.SetActive(Group_Btn, false)
  else
    GUIUtils.SetActive(Group_Btn, true)
    self:SetOperateBtns(Group_Btn, self.operations)
  end
  ui_Img_Bg0:GetComponent("UITableResizeBackground"):Reposition()
end
def.method("userdata", "table").SetOperateBtns = function(self, group, operations)
  local btn = group:FindDirect("Btn_1")
  local operation = operations[1]
  if btn and operation then
    local label = btn:FindDirect("Label")
    local operationName = operation:GetOperationName()
    GUIUtils.SetText(label, operationName)
  end
end
def.method("number").OnButtonClicked = function(self, index)
  if self.operations == nil then
    return
  end
  local operation = self.operations[index]
  local isCloseTip = operation:OP()
  if isCloseTip then
    self:DestroyPanel()
  end
end
return CommonSkillTip.Commit()
