local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIAwardPreview = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = UIAwardPreview
local def = Cls.define
local instance
local txtConst = textRes.Pet.PetsArena
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
def.field("table")._uiGOs = nil
def.field("table")._awardsCfg = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().initUI = function(self)
  self:initAwardList()
end
def.method("userdata", "number", "number", "number").showSingleAward = function(self, ctrl, idx, rank, awardId)
  local lblRank = ctrl:FindDirect("Label_Ranking_" .. idx)
  local imgRank = ctrl:FindDirect("Img_MingCi_" .. idx)
  imgRank:SetActive(false)
  local listItems = ctrl:FindDirect("List_" .. idx)
  GUIUtils.SetText(lblRank, txtConst[12]:format(rank))
  local awardCfg = self:getAwardCfgByAwardId(awardId)
  if awardCfg == nil then
    listItems:SetActive(false)
  else
    listItems:SetActive(true)
    self:fillAward(listItems, awardCfg, idx)
  end
end
def.method("userdata", "number", "number", "number", "number").showRangeAward = function(self, ctrl, idx, min, max, awardId)
  local lblRank = ctrl:FindDirect("Label_Ranking_" .. idx)
  local imgRank = ctrl:FindDirect("Img_MingCi_" .. idx)
  imgRank:SetActive(false)
  local listItems = ctrl:FindDirect("List_" .. idx)
  GUIUtils.SetText(lblRank, txtConst[13]:format(min, max))
  local awardCfg = self:getAwardCfgByAwardId(awardId)
  if awardCfg == nil then
    listItems:SetActive(false)
  else
    listItems:SetActive(true)
    self:fillAward(listItems, awardCfg, idx)
  end
end
def.method("userdata", "table", "number").fillAward = function(self, uiList, awardsCfg, idx)
  local listCount = #awardsCfg.itemList or {}
  local ctrlAwardList = GUIUtils.InitUIList(uiList, listCount)
  for i = 1, listCount do
    local ctrl = ctrlAwardList[i]
    local itemInfo = awardsCfg.itemList[i]
    if itemInfo then
      local lblNum = ctrl:FindDirect(("Label_Num_%d_%d"):format(idx, i))
      local texIcon = ctrl:FindDirect(("Img_Icon_%d_%d"):format(idx, i)):GetComponent("UITexture")
      local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
      ctrl.name = "Item_" .. itemInfo.itemId
      GUIUtils.FillIcon(texIcon, itemBase.icon)
      GUIUtils.SetText(lblNum, itemInfo.num)
    else
      ctrl.name = "Item_0"
      ctrl:SetActive(false)
    end
  end
end
def.method().initAwardList = function(self)
  local countList = #self._awardsCfg
  local ctrlAwardList = GUIUtils.InitUIList(self._uiGOs.uiList, countList)
  for i = 1, countList do
    local awardCfg = self._awardsCfg[i]
    local ctrl = ctrlAwardList[i]
    if awardCfg.minRank == awardCfg.maxRank then
      self:showSingleAward(ctrl, i, awardCfg.minRank, awardCfg.award)
    else
      self:showRangeAward(ctrl, i, awardCfg.minRank, awardCfg.maxRank, awardCfg.award)
    end
  end
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  local uiGOs = self._uiGOs
  uiGOs.uiList = self.m_panel:FindDirect("Img_Bg0/Group_RankList/Group_List/Scrolllist/List")
end
def.override().OnDestroy = function(self)
  self._uiGOs = nil
  self._awardsCfg = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow and self._awardsCfg == nil then
    self._awardsCfg = require("Main.Pet.PetsArena.PetsArenaUtils").LoadAllAwardCfg() or {}
    self:initUI()
  end
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PETS_ARENA_AWARD, 2)
  self:SetModal(true)
end
def.method("number", "=>", "table").getAwardCfgByAwardId = function(self, awardId)
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local key = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
  return ItemUtils.GetGiftAwardCfg(key)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif string.find(id, "Item_") then
    local strs = string.split(id, "_")
    local itemId = tonumber(strs[2])
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, clickObj, 0, false)
  end
end
return Cls.Commit()
