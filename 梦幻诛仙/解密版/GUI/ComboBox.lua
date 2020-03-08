local Lplus = require("Lplus")
local ComboBox = Lplus.Class("ComboBox")
local GUIUtils = require("GUI.GUIUtils")
local def = ComboBox.define
def.field("userdata").toggleBtn = nil
def.field("userdata").dropBox = nil
def.field("userdata").labelOption = nil
def.field("userdata").showImg = nil
def.field("userdata").hideImg = nil
def.field("userdata").optionList = nil
def.field("table").dataSource = nil
def.field("function").clickOptionCallback = nil
def.field("number").unique = 0
local uniqueId = 1
def.static("userdata", "userdata", "userdata", "userdata", "userdata", "userdata", "=>", "table").Create = function(toggleBtn, dropBox, labelOption, showImg, hideImg, optionList)
  local comboBox = ComboBox()
  comboBox.toggleBtn = toggleBtn
  comboBox.dropBox = dropBox
  comboBox.labelOption = labelOption
  comboBox.showImg = showImg
  comboBox.hideImg = hideImg
  comboBox.optionList = optionList
  comboBox.unique = uniqueId
  uniqueId = uniqueId % 1000 + 1
  comboBox:Init()
  return comboBox
end
def.method().Init = function(self)
  self:Hide()
end
def.method("table", "string").SetDataSource = function(self, ds, bindLabelName)
  self.dataSource = ds
  if bindLabelName == "" then
    bindLabelName = "Label_Name"
  end
  if self.optionList ~= nil and self.dataSource ~= nil then
    local uiList = self.optionList:GetComponent("UIList")
    uiList.itemCount = #self.dataSource
    uiList:Resize()
    local uiItems = uiList.children
    for i = 1, #uiItems do
      local uiItem = uiItems[i]
      local Label = uiItem:FindDirect(bindLabelName)
      GUIUtils.SetText(Label, self.dataSource[i].name)
      uiItem.name = string.format("ComboBoxOption_%d_%d", self.unique, i)
    end
  end
  if self.dataSource ~= nil and self.dataSource[1] ~= nil then
    GUIUtils.SetText(self.labelOption, self.dataSource[1].name)
  end
end
def.method("number").SetSelectedIndex = function(self, idx)
  if self.dataSource ~= nil and self.dataSource[idx] ~= nil then
    GUIUtils.SetText(self.labelOption, self.dataSource[idx].name)
  end
end
def.method("function").SetClickOptionCallback = function(self, callback)
  self.clickOptionCallback = callback
end
def.method().ShowComboBox = function(self)
  GUIUtils.SetActive(self.dropBox, true)
  GUIUtils.SetActive(self.hideImg, true)
  GUIUtils.SetActive(self.showImg, false)
end
def.method().Hide = function(self)
  GUIUtils.SetActive(self.dropBox, false)
  GUIUtils.SetActive(self.hideImg, false)
  GUIUtils.SetActive(self.showImg, true)
end
def.method().ToggleComboBox = function(self)
  if self.dropBox then
    if self.dropBox.activeSelf then
      self:Hide()
    else
      self:ShowComboBox()
    end
  end
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  local optionTag = string.format("ComboBoxOption_%d_", self.unique)
  if self.toggleBtn and self.toggleBtn.name == id then
    self:ToggleComboBox()
    return true
  elseif string.find(id, optionTag) then
    local idx = tonumber(string.sub(id, #optionTag + 1))
    self:OnClickOption(idx)
    return true
  end
  self:Hide()
  return false
end
def.method("number").OnClickOption = function(self, idx)
  self:SetSelectedIndex(idx)
  self:Hide()
  if self.clickOptionCallback and self.dataSource and self.dataSource[idx] then
    local ret = self.dataSource[idx]
    self.clickOptionCallback(ret)
  end
end
return ComboBox.Commit()
