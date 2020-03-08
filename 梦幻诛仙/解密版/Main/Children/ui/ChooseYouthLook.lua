local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChooseYouthLook = Lplus.Extend(ECPanelBase, "ChooseYouthLook")
local Child = require("Main.Children.Child")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local def = ChooseYouthLook.define
def.field("number").look1 = 0
def.field("number").look2 = 0
def.field("function").callback = nil
def.field(Child).child1 = nil
def.field(Child).child2 = nil
def.field("number").select = 0
def.field(Child).dragChild = nil
def.static("number", "number", "function").ShowChooseYouthLook = function(id1, id2, cb)
  local dlg = ChooseYouthLook()
  dlg.look1 = id1
  dlg.look2 = id2
  dlg.callback = cb
  dlg:CreatePanel(RESPATH.PREFAB_TEEN_TO_YOUTH, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  if self.child1 ~= nil then
    self.child1:DestroyModel()
  end
  if self.child2 ~= nil then
    self.child2:DestroyModel()
  end
end
def.method().UpdateUI = function(self)
  self:CreateModel()
end
def.method().CreateModel = function(self)
  local weaponId1 = ChildrenUtils.GetChildrenInitWeapon(self.look1)
  self.child1 = Child.CreateWithWeapon(self.look1, weaponId1)
  local uiModel1 = self.m_panel:FindDirect("Img_Bg0/Group_Child/Img_BgChild01/Model01"):GetComponent("UIModel")
  self.child1:LoadUIModel(nil, function()
    uiModel1.modelGameObject = self.child1.model.m_model
    if uiModel1.mCanOverflow ~= nil then
      uiModel1.mCanOverflow = true
      local camera = uiModel1:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
  local weaponId2 = ChildrenUtils.GetChildrenInitWeapon(self.look2)
  self.child2 = Child.CreateWithWeapon(self.look2, weaponId2)
  local uiModel2 = self.m_panel:FindDirect("Img_Bg0/Group_Child/Img_BgChild02/Model02"):GetComponent("UIModel")
  self.child2:LoadUIModel(nil, function()
    uiModel2.modelGameObject = self.child2.model.m_model
    if uiModel2.mCanOverflow ~= nil then
      uiModel2.mCanOverflow = true
      local camera = uiModel2:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    if self.select > 0 then
      self:DestroyPanel()
      warn(self.callback, self.select)
      if self.callback then
        self.callback(self.select)
      end
    else
      Toast(textRes.Children[2038])
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if id == "Img_BgChild01" then
    if active then
      self.select = self.look1
    end
  elseif id == "Img_BgChild02" and active then
    self.select = self.look2
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model01" then
    self.dragChild = self.child1
  elseif id == "Model02" then
    self.dragChild = self.child2
  end
end
def.method("string").onDragEnd = function(self, id)
  self.dragChild = nil
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.dragChild then
    self.dragChild:SetDir(self.dragChild:GetDir() - dx / 2)
  end
end
return ChooseYouthLook.Commit()
