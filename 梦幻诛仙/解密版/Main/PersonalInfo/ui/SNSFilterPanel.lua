local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SNSFilterPanel = Lplus.Extend(ECPanelBase, "SNSFilterPanel")
local GUIUtils = require("GUI.GUIUtils")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local PersonalInfoModule = require("Main.PersonalInfo.PersonalInfoModule")
local SocialPlatformMgr = require("Main.PersonalInfo.mgr.SocialPlatformMgr")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local FieldType = require("consts.mzm.gsp.personal.confbean.FieldType")
local Vector = require("Types.Vector")
local GenderFilter = {
  Btn_All = -1,
  Btn_Boy = SocialPlatformMgr.SocialGender.MALE,
  Btn_Girl = SocialPlatformMgr.SocialGender.FEMALE
}
local def = SNSFilterPanel.define
local instance
def.field("table").uiObjs = nil
def.field("number").selectGender = -1
def.field("number").selectProvince = -1
def.field("number").selectLevelOp = -1
def.field("number").selectLevel = -1
def.field("number").filterAdvertType = -1
def.static("=>", SNSFilterPanel).Instance = function()
  if instance == nil then
    instance = SNSFilterPanel()
  end
  return instance
end
def.method("number").ShowSNSFilterPanel = function(self, adverType)
  if self.m_panel ~= nil then
    return
  end
  self.filterAdvertType = adverType
  self:CreatePanel(RESPATH.PREFAB_FILTER_CONDITION_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitFilter()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_SmallSelected = self.uiObjs.Img_Bg0:FindDirect("Group_SmallSelected")
  self.uiObjs.Label_LevelCondition = self.uiObjs.Img_Bg0:FindDirect("Label_LevelCondition")
  self.uiObjs.Label_Level = self.uiObjs.Img_Bg0:FindDirect("Label_Level")
  self.uiObjs.Label_Location = self.uiObjs.Img_Bg0:FindDirect("Label_Location")
  self:HidePopupFilter()
end
def.method().InitFilter = function(self)
  local filter = SocialPlatformMgr.Instance():GetSearchFilter(self.filterAdvertType)
  if filter == nil then
    self:Reset()
  else
    self:SetGender(filter.gender)
    self:SetLevelOP(filter.levelOp)
    self:SetLevelLimit(filter.minLevel, filter.maxLevel)
    self:SetProvince(filter.province)
  end
end
def.method("number").SetGender = function(self, genderId)
  for btnName, id in pairs(GenderFilter) do
    if id == genderId then
      self.uiObjs.Img_Bg0:FindDirect(btnName):GetComponent("UIToggle").value = true
      return
    end
  end
end
def.method("=>", "number").GetSelectGender = function(self)
  for btnName, id in pairs(GenderFilter) do
    local toggle = self.uiObjs.Img_Bg0:FindDirect(btnName):GetComponent("UIToggle")
    if toggle.value == true then
      return id
    end
  end
  return -1
end
def.method().HidePopupFilter = function(self)
  if self.uiObjs.Group_SmallSelected ~= nil then
    self.uiObjs.Group_SmallSelected:SetActive(false)
  end
end
def.method().ShowLevelOpFilter = function(self)
  if self.uiObjs.Group_SmallSelected ~= nil then
    self.uiObjs.Group_SmallSelected:SetActive(true)
    do
      local scrollView = self.uiObjs.Group_SmallSelected:FindDirect("Img_Bg2/Scroll View")
      local levelList = scrollView:FindDirect("List_Item2")
      local uiList = levelList:GetComponent("UIList")
      if levelList ~= nil then
        local opList = {
          SocialPlatformMgr.SocialLevelOp.LT,
          SocialPlatformMgr.SocialLevelOp.GT
        }
        local itemCount = #opList
        uiList.itemCount = itemCount
        uiList:Resize()
        local uiItems = uiList.children
        for i = 1, itemCount do
          local item = uiItems[i]
          item.name = "levelop_" .. opList[i]
          local btnName = item:FindDirect("Btn_Item2/Label_Name2")
          GUIUtils.SetText(btnName, textRes.Personal.SearchFilter.LevelOP[opList[i]])
        end
      end
      GameUtil.AddGlobalTimer(0.1, true, function()
        scrollView:GetComponent("UIScrollView"):ResetPosition()
      end)
    end
  end
end
def.method("number").SetLevelOP = function(self, op)
  self.selectLevelOp = op
  GUIUtils.SetText(self.uiObjs.Label_LevelCondition, textRes.Personal.SearchFilter.LevelOP[op])
end
def.method().ShowLevelFilter = function(self)
  if self.uiObjs.Group_SmallSelected ~= nil then
    self.uiObjs.Group_SmallSelected:SetActive(true)
    do
      local scrollView = self.uiObjs.Group_SmallSelected:FindDirect("Img_Bg2/Scroll View")
      local levelList = scrollView:FindDirect("List_Item2")
      local uiList = levelList:GetComponent("UIList")
      if levelList ~= nil then
        local levelList = {}
        local level = SocialPlatformMgr.Instance():GetMinRoleLevel()
        while level <= SocialPlatformMgr.Instance():GetMaxRoleLevel() do
          table.insert(levelList, level)
          level = level + constant.SNSConsts.ROLE_LEVEL_INTERVAL
        end
        if level - constant.SNSConsts.ROLE_LEVEL_INTERVAL ~= SocialPlatformMgr.Instance():GetMaxRoleLevel() then
          table.insert(levelList, SocialPlatformMgr.Instance():GetMaxRoleLevel())
        end
        local itemCount = #levelList
        uiList.itemCount = itemCount
        uiList:Resize()
        local uiItems = uiList.children
        for i = 1, itemCount do
          local item = uiItems[i]
          item.name = "level_" .. levelList[i]
          local btnName = item:FindDirect("Btn_Item2/Label_Name2")
          GUIUtils.SetText(btnName, string.format(textRes.Personal[235], levelList[i]))
        end
      end
      GameUtil.AddGlobalTimer(0.1, true, function()
        scrollView:GetComponent("UIScrollView"):ResetPosition()
      end)
    end
  end
end
def.method("number").ChooseLevel = function(self, level)
  self.selectLevel = level
  if self.selectLevelOp == SocialPlatformMgr.SocialLevelOp.LT then
    GUIUtils.SetText(self.uiObjs.Label_Level, string.format(textRes.Personal[235], level))
  else
    GUIUtils.SetText(self.uiObjs.Label_Level, string.format(textRes.Personal[235], level))
  end
end
def.method("number", "number").SetLevelLimit = function(self, minLevel, maxLevel)
  if self.selectLevelOp == SocialPlatformMgr.SocialLevelOp.LT then
    self:ChooseLevel(maxLevel)
  else
    self:ChooseLevel(minLevel)
  end
end
def.method("=>", "number", "number").GetLevelLimit = function(self)
  local minLevel = SocialPlatformMgr.Instance():GetMinRoleLevel()
  local maxLevel = SocialPlatformMgr.Instance():GetMaxRoleLevel()
  if self.selectLevelOp == SocialPlatformMgr.SocialLevelOp.LT then
    maxLevel = self.selectLevel
  else
    minLevel = self.selectLevel
  end
  return minLevel, maxLevel
end
def.method().ShowProvinceFilter = function(self)
  if self.uiObjs.Group_SmallSelected ~= nil then
    do
      local provinceCfgList = PersonalInfoInterface.GetOperationList(FieldType.PROVINCE)
      self.uiObjs.Group_SmallSelected:SetActive(true)
      local scrollView = self.uiObjs.Group_SmallSelected:FindDirect("Img_Bg2/Scroll View")
      local provinceList = scrollView:FindDirect("List_Item2")
      local uiList = provinceList:GetComponent("UIList")
      if provinceCfgList ~= nil then
        local noLimit = {}
        noLimit.id = SocialPlatformMgr.SocialProvince.NO_LIMIT
        noLimit.content = textRes.Personal[231]
        table.insert(provinceCfgList, 1, noLimit)
        local itemCount = #provinceCfgList
        uiList.itemCount = itemCount
        uiList:Resize()
        local uiItems = uiList.children
        for i = 1, itemCount do
          local item = uiItems[i]
          item.name = "province_" .. provinceCfgList[i].id
          local btnName = item:FindDirect("Btn_Item2/Label_Name2")
          GUIUtils.SetText(btnName, provinceCfgList[i].content)
        end
      end
      GameUtil.AddGlobalTimer(0.1, true, function()
        scrollView:GetComponent("UIScrollView"):ResetPosition()
      end)
    end
  end
end
def.method("number").SetProvince = function(self, provinceId)
  if provinceId < 0 then
    self.selectProvince = -1
    GUIUtils.SetText(self.uiObjs.Label_Location, textRes.Personal.SearchFilter.Province[-1])
  else
    self.selectProvince = provinceId
    local province = PersonalInfoInterface.GetPersonalOptionCfg(provinceId)
    GUIUtils.SetText(self.uiObjs.Label_Location, province.content)
  end
end
def.method().Reset = function(self)
  self:SetGender(SocialPlatformMgr.SocialGender.ALL)
  self:SetLevelOP(SocialPlatformMgr.SocialLevelOp.LT)
  self:SetLevelLimit(SocialPlatformMgr.Instance():GetMinRoleLevel(), SocialPlatformMgr.Instance():GetMaxRoleLevel())
  self:SetProvince(SocialPlatformMgr.SocialProvince.NO_LIMIT)
end
def.method().Filter = function(self)
  local minLevel, maxLevel = self:GetLevelLimit()
  if maxLevel < minLevel then
    Toast(textRes.Personal[216])
    return
  end
  if minLevel < 1 then
    Toast(textRes.Personal[217])
    return
  end
  local maxServerLevel = SocialPlatformMgr.Instance():GetMaxRoleLevel()
  if maxLevel > maxServerLevel then
    Toast(string.format(textRes.Personal[218], maxServerLevel))
    return
  end
  SocialPlatformMgr.Instance():SetSearchFilter(self.filterAdvertType, self:GetSelectGender(), self.selectLevelOp, minLevel, maxLevel, self.selectProvince)
  self:Close()
end
def.method("userdata").onClickObj = function(self, obj)
  self:HidePopupFilter()
  if obj.name == "Btn_Item2" then
    local parent = obj.transform.parent.gameObject
    if parent ~= nil then
      if string.find(parent.name, "level_") then
        local levelId = tonumber(string.sub(parent.name, 7))
        self:ChooseLevel(levelId)
      elseif string.find(parent.name, "province_") then
        local provinceId = tonumber(string.sub(parent.name, 10))
        self:SetProvince(provinceId)
      elseif string.find(parent.name, "levelop_") then
        local opId = tonumber(string.sub(parent.name, 9))
        self:SetLevelOP(opId)
      end
    end
  else
    self:onClick(obj.name)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif id == "Btn_Reset" then
    self:Reset()
  elseif id == "Btn_Confirm" then
    self:Filter()
  elseif id == "Btn_ChoosLevel" then
    self:ShowLevelFilter()
  elseif id == "Btn_ChoosLocation" then
    self:ShowProvinceFilter()
  elseif id == "Btn_ChoosLevelCondition" then
    self:ShowLevelOpFilter()
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.selectGender = -1
  self.selectProvince = -1
  self.selectLevelOp = -1
  self.selectLevel = -1
  self.uiObjs = nil
end
SNSFilterPanel.Commit()
return SNSFilterPanel
