local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIPostGuide = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = UIPostGuide
local def = Cls.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local PostGuideMgr = require("Main.MultiOccupation.PostGuide.PostGuideMgr")
def.field("table")._uiGos = nil
def.field("table")._uiCache = nil
def.field("table")._guidesList = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().eventsRegist = function(self)
  Event.RegisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.POSTGUIDE_LIST_CHG, Cls.OnGuideListChg)
end
def.method().eventsUnregist = function(self)
  Event.UnregisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.POSTGUIDE_LIST_CHG, Cls.OnGuideListChg)
end
def.method().initUI = function(self)
end
def.override().OnCreate = function(self)
  self:eventsRegist()
  self._uiCache = {}
  local uiCache = self._uiCache
  uiCache.bGuideListDirty = true
  self._uiGos = {}
  local uiGos = self._uiGos
  uiGos.uiList = self.m_panel:FindDirect("Img_BgEquip/Group_List/ScrollView/Table")
end
def.override().OnDestroy = function(self)
  self:eventsUnregist()
  self._uiGos = nil
  self._uiCache = nil
  self._guidesList = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:setGuideList()
  end
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_POST_GUIDE, 1)
  self:SetModal(true)
end
def.method().setGuideList = function(self)
  local guideList = self:GetSortedGuidesList()
  local ctrlGuideList = GUIUtils.InitUIList(self._uiGos.uiList, #guideList)
  local guideCfgs = require("Main.MultiOccupation.PostGuide.Utils").ReadAllGuideCfg()
  for i = 1, #guideList do
    local ctrl = ctrlGuideList[i]
    local guideInfo = guideList[i]
    local guideCfg = guideCfgs[guideInfo.guideType]
    self:setGuideInfo(ctrl, guideCfg, i)
  end
end
def.method("userdata", "table", "number").setGuideInfo = function(self, ctrl, guideCfg, idx)
  local tex = ctrl:FindDirect(string.format("Img_BgIcon_%d/Texture_Item_%d", idx, idx))
  local lblName = ctrl:FindDirect("Label_Name_" .. idx)
  local lblDesc = ctrl:FindDirect("Label_Tips_" .. idx)
  local imgRed = ctrl:FindDirect(string.format("Btn_Go_%d/Img_Red_%d", idx, idx))
  GUIUtils.SetTexture(tex, guideCfg.iconid)
  GUIUtils.SetText(lblName, guideCfg.name)
  GUIUtils.SetText(lblDesc, guideCfg.desc)
  local bShow = not PostGuideMgr.Instance():IsGuideDone(guideCfg.guideType)
  imgRed:SetActive(bShow)
end
def.static("table").SortGuides = function(guidesInfo)
  if guidesInfo == nil then
    return
  end
  table.sort(guidesInfo, function(a, b)
    if a.isDone then
      if b.isDone then
        return a.guideType < b.guideType
      else
        return false
      end
    elseif b.isDone then
      return true
    else
      return a.guideType < b.guideType
    end
  end)
end
def.method("=>", "table").GetSortedGuidesList = function(self)
  if self._guidesList == nil then
    local guideReaders = PostGuideMgr.Instance():GetGuideCfgReaders()
    self._guidesList = {}
    for guideType, reader in pairs(guideReaders) do
      local bRun = PostGuideMgr.Instance():IsGuideDone(guideType)
      table.insert(self._guidesList, {
        guideType = guideType,
        cfgReader = reader,
        isDone = bRun
      })
    end
  end
  if self._uiCache.bGuideListDirty then
    Cls.SortGuides(self._guidesList)
    self._uiCache.bGuideListDirty = false
  end
  return self._guidesList
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if string.find(id, "Btn_Go_") then
    local strs = string.split(id, "_")
    local index = tonumber(strs[3])
    self:onBtnGoClick(index)
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Close1" then
    self:onBtnCloseGuideClick()
  elseif id == "Btn_Tips" then
    GUIUtils.ShowHoverTip(constant.CMultiOccupConsts.GuideTips)
  end
end
def.method("number").onBtnGoClick = function(self, index)
  local guideList = self:GetSortedGuidesList()
  local guideInfo = guideList[index]
  guideInfo.isDone = true
  self:DestroyPanel()
  PostGuideMgr.StartGuide(guideInfo.guideType)
end
def.method().onBtnCloseGuideClick = function(self)
  local CommonConfirm = require("GUI.CommonConfirmDlg")
  CommonConfirm.ShowConfirm(textRes.MultiOccupation[26], textRes.MultiOccupation[25], function(select)
    if select == 1 then
      PostGuideMgr.Instance():SetCloseGuideSys(true)
      Event.DispatchEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.GuideOpenChange, nil)
      self:DestroyPanel()
    end
  end, nil)
end
def.static("table", "table").OnGuideListChg = function(p, c)
  local self = instance
  self._guidesList = nil
  self._uiCache.bGuideListDirty = true
  instance:setGuideList()
end
return Cls.Commit()
