local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DouDouTagDlg = Lplus.Extend(ECPanelBase, "DouDouTagDlg")
local PlayerPref = require("Main.Common.LuaPlayerPrefs")
local def = DouDouTagDlg.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = DouDouTagDlg()
  end
  return _instance
end
def.field("function").callback = nil
def.field("table").data = nil
def.static("function").ShowDouDouTagDlg = function(cb)
  local dlg = DouDouTagDlg.Instance()
  dlg.callback = cb
  if dlg:IsShow() then
    return
  else
    dlg:CreatePanel(RESPATH.PREFAB_DOUDOU_CLEAR_TAG, 0)
  end
end
def.method().LoadData = function(self)
  if PlayerPref.HasGlobalKey("DouDouTag") then
    self.data = PlayerPref.GetGlobalTable("DouDouTag")
  else
    self.data = clone(textRes.Hula.Preset)
  end
end
def.method().SaveData = function(self)
  if self.data ~= nil then
    PlayerPref.SetGlobalTable("DouDouTag", self.data)
  end
  PlayerPref.Save()
end
def.override().OnCreate = function(self)
  self:LoadData()
  self:FillUI()
end
def.override().OnDestroy = function(self)
  local grid = self.m_panel:FindDirect("Img_Bg0/Group_Btn")
  for i = 1, 8 do
    local oneUI = grid:FindDirect("Btn_ZhiHui" .. i)
    local data = self.data[i]
    local lblText = oneUI:FindDirect("Label"):GetComponent("UILabel"):get_text()
    if data ~= lblText then
      self.data[i] = lblText
    end
  end
  self:SaveData()
end
def.method().FillUI = function(self)
  local grid = self.m_panel:FindDirect("Img_Bg0/Group_Btn")
  for i = 1, 8 do
    local oneUI = grid:FindDirect("Btn_ZhiHui" .. i)
    local data = self.data[i]
    if data then
      self:FillOne(oneUI, data)
    else
      self:FillOne(oneUI, "")
    end
  end
end
def.method("userdata", "string").FillOne = function(self, ui, tag)
  ui:FindDirect("Label"):GetComponent("UILabel"):set_text(tag)
end
def.method("number", "string").Edit = function(self, index, str)
  warn("Edit", index, str)
  self.data[index] = str
  self:SaveData()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 10) == "Btn_ZhiHui" then
    local index = tonumber(string.sub(id, 11))
    local tag = self.data[index]
    if tag then
      if self.callback then
        self.callback(tag)
      end
    else
      local inputLabel = self.m_panel:FindDirect("Img_Bg0/Group_Btn/" .. id .. "/Label")
      tag = inputLabel:GetComponent("UILabel"):get_text()
      tag = string.gsub(tag, " ", "")
      if tag ~= "" then
        self:Edit(index, tag)
        if self.callback then
          self.callback(tag)
        end
      end
    end
    self:DestroyPanel()
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  local cnt = ctrl:get_value()
  cnt = string.gsub(cnt, " ", "")
  cnt = StrSub(cnt, 1, 6)
  cnt = SensitiveWordsFilter.FilterContent(cnt, "*")
  ctrl:set_value(cnt)
  if cnt ~= "" then
    local goName = ctrl.gameObject.parent.name
    warn("goName", goName)
    local index = tonumber(string.sub(goName, 11))
    self:Edit(index, cnt)
  else
    Toast(textRes.Hula[7])
  end
  self:FillUI()
end
DouDouTagDlg.Commit()
return DouDouTagDlg
