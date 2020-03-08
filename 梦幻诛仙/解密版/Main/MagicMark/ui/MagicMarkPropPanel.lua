local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MagicMarkPropPanel = Lplus.Extend(ECPanelBase, "MagicMarkPropPanel")
local TabNode = require("GUI.TabNode")
local def = MagicMarkPropPanel.define
local instance
def.field("table")._uiObjs = nil
def.field("table")._allProps = nil
def.field("table")._propList = nil
def.field("table")._allEffectSkills = nil
def.static("=>", MagicMarkPropPanel).Instance = function()
  if instance == nil then
    instance = MagicMarkPropPanel()
  end
  return instance
end
def.method().ShowDlg = function(self)
  self:CreatePanel(RESPATH.PREFAB_FASHION_EFFECT_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_0 = self.m_panel:FindDirect("Img_0")
  self._uiObjs.Tab_Effect = self._uiObjs.Img_0:FindDirect("Tab_Effect")
  self._uiObjs.Tab_Attribute = self._uiObjs.Img_0:FindDirect("Tab_Attribute")
  self._uiObjs.ScrollView = self._uiObjs.Img_0:FindDirect("Group_Content/Scroll View")
  self._uiObjs.List_Effect = self._uiObjs.ScrollView:FindDirect("List_Effect")
  self._uiObjs.List_Attribute = self._uiObjs.ScrollView:FindDirect("List_Attribute")
  self._uiObjs.List_Effect:SetActive(false)
  self._uiObjs.List_Attribute:SetActive(true)
  self._uiObjs.Tab_Attribute:GetComponent("UIToggle").value = true
  self:ClearNotify()
  self:LoadMagicMarkData()
  self:ShowPropertyList()
  Event.RegisterEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_EXPIRED, MagicMarkPropPanel.OnMagicMarkExpired)
end
def.method().ClearNotify = function(self)
  self._uiObjs.Tab_Attribute:FindDirect("Img_Red"):SetActive(false)
end
def.method().LoadMagicMarkData = function(self)
  local ownedMarks = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK).owned
  self._allProps = {}
  self._allEffectSkills = {}
  if ownedMarks == nil then
    return
  end
  local IDIPInterface = require("Main.IDIP.IDIPInterface")
  local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
  for id, left_time in pairs(ownedMarks) do
    local bOpen = IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.MAGIC_MARK, id)
    if bOpen then
      local markCfg = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):GetMagicMarkTypeCfg(id)
      if markCfg then
        if markCfg.properties and #markCfg.properties > 0 then
          self._allProps[id] = markCfg
        end
        if markCfg.effectSkills and 0 < #markCfg.effectSkills then
          self._allEffectSkills[id] = markCfg
        end
      end
    end
  end
end
def.method().ShowPropertyList = function(self)
  if self._allProps == nil then
    return
  end
  self._propList = {}
  for id, markCfg in pairs(self._allProps) do
    local skillProperties = markCfg.properties
    local propertyDesc = {}
    for i = 1, #skillProperties do
      local skillId = skillProperties[i]
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      if skillCfg ~= nil then
        table.insert(propertyDesc, skillCfg.description)
      end
    end
    if #propertyDesc > 0 then
      local showInfo = {}
      showInfo.id = id
      showInfo.name = markCfg.name
      showInfo.propertyDesc = table.concat(propertyDesc, "\n")
      table.insert(self._propList, showInfo)
    end
  end
  local showCount = #self._propList
  local uiList = self._uiObjs.List_Attribute:GetComponent("UIList")
  uiList.itemCount = showCount
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, showCount do
    local uiItem = uiItems[i]
    local showInfo = self._propList[i]
    local labelName = uiItem:FindDirect("Label_Name_" .. i):GetComponent("UILabel")
    local labelInfo = uiItem:FindDirect("Label_Info_" .. i):GetComponent("UILabel")
    labelName:set_text(showInfo.name)
    labelInfo:set_text(showInfo.propertyDesc)
    local toggleObj = uiItem:FindDirect("Img_Toggle_" .. i)
    local toggle = toggleObj:GetComponent("UIToggle")
    uiItem.name = "Img_Effect_" .. i
    if showInfo.id == gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK).enabledMagicMarkId then
      toggle.value = true
    else
      toggle.value = false
    end
  end
end
def.method("number", "boolean").SetPropertyState = function(self, idx, state)
  local markInfo = self._propList[idx]
  if markInfo then
    if state then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.magicmark.CMagicMarkSelectPropReq").new(markInfo.id))
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.magicmark.CMagicMarkUnSelectPropReq").new(markInfo.id))
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Img_Toggle_") == 1 then
    if IsCrossingServer() then
      ToastCrossingServerForbiden()
      return
    end
    local idx = tonumber(string.sub(clickObj.parent.name, #"Img_Effect_" + 1))
    local toggle = clickObj:GetComponent("UIToggle")
    self:SetPropertyState(idx, toggle.value)
  elseif id == "Tab_Attribute" then
    self:ClearNotify()
  elseif id == "Tab_Effect" then
    self:ShowEffectSkillList()
  end
end
def.static("table", "table").OnMagicMarkExpired = function(params, context)
  local self = instance
  if self ~= nil then
    self:LoadMagicMarkData()
    self:ShowPropertyList()
  end
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  self._allProps = nil
  self._propList = nil
  Event.UnregisterEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_EXPIRED, MagicMarkPropPanel.OnMagicMarkExpired)
end
def.method().ShowEffectSkillList = function(self)
  if self._allEffectSkills == nil then
    return
  end
  local skillList = {}
  for id, markCfg in pairs(self._allEffectSkills) do
    local skillDesc = {}
    for i = 1, #markCfg.effectSkills do
      local skillId = markCfg.effectSkills[i]
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      if skillCfg ~= nil then
        table.insert(skillDesc, skillCfg.description)
      end
    end
    if #skillDesc > 0 then
      local showInfo = {}
      showInfo.id = id
      showInfo.name = markCfg.name
      showInfo.skillDesc = table.concat(skillDesc, "\n")
      table.insert(skillList, showInfo)
    end
  end
  local showCount = #skillList
  local uiList = self._uiObjs.List_Effect:GetComponent("UIList")
  uiList.itemCount = showCount
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, showCount do
    local uiItem = uiItems[i]
    local showInfo = skillList[i]
    local labelName = uiItem:FindDirect("Label_Name_" .. i):GetComponent("UILabel")
    local labelInfo = uiItem:FindDirect("Label_Info_" .. i):GetComponent("UILabel")
    labelName:set_text(showInfo.name)
    labelInfo:set_text(showInfo.skillDesc)
    uiItem.name = "Img_Effect_" .. i
  end
  GameUtil.AddGlobalTimer(0.01, true, function()
    if self._uiObjs == nil then
      return
    end
    uiList:Reposition()
    if showCount > 0 then
      local uiScrollView = self._uiObjs.List_Effect.parent:GetComponent("UIScrollView")
      uiScrollView:DragToMakeVisible(uiItems[1].transform, 40)
    end
  end)
end
MagicMarkPropPanel.Commit()
return MagicMarkPropPanel
