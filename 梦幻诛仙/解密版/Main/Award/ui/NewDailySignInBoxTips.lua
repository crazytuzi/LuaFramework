local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NewDailySignInBoxTips = Lplus.Extend(ECPanelBase, "NewDailySignInBoxTips")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local DailySignInMgr = require("Main.Award.mgr.DailySignInMgr")
local NewDailySignInMgr = require("Main.Award.mgr.NewDailySignInMgr")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local ChessCellAwardType = require("consts.mzm.gsp.signprecious.confbean.ChessCellAwardType")
local def = NewDailySignInBoxTips.define
def.field("number").boxType = 0
def.field("number").boxCfgId = 0
def.field("table").uiObjs = nil
def.field(AwardItemTipHelper).itemTipHelper = nil
local instance
def.static("=>", NewDailySignInBoxTips).Instance = function()
  if instance == nil then
    instance = NewDailySignInBoxTips()
  end
  return instance
end
def.method("number", "number").ShowPanel = function(self, cfgId, boxType)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.boxCfgId = cfgId
  self.boxType = boxType
  self:CreatePanel(RESPATH.PREFAB_PRIZE_NEW_QIANDAO_BOX_TIPS, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:SetBoxInfo()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.itemTipHelper = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Grid = self.m_panel:FindDirect("Img_Bg0/Label_Prize/Grid")
  local gridTransform = self.uiObjs.Grid.transform
  local ctrlCount = gridTransform.childCount
  for i = 1, ctrlCount do
    local child = gridTransform:GetChild(i - 1).gameObject
    child.name = "Item_" .. i
  end
  self.itemTipHelper = AwardItemTipHelper()
end
def.method().SetBoxInfo = function(self)
  local titleMap = {
    [1] = 3,
    [2] = 2,
    [3] = 1
  }
  for i = 1, 3 do
    local title = self.m_panel:FindDirect("Img_Bg0/Img_Title/Img_Lable" .. i)
    if titleMap[i] ~= self.boxType then
      GUIUtils.SetActive(title, false)
    else
      GUIUtils.SetActive(title, true)
    end
  end
  local Img_Icon = self.m_panel:FindDirect("Img_Bg0/Group_Title/Img_Title")
  if self.boxType == ChessCellAwardType.DIAMOND_BOX then
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), constant.CSignPreciousConsts.diamond_big_box_icon_id)
  elseif self.boxType == ChessCellAwardType.GOLD_BOX then
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), constant.CSignPreciousConsts.gold_big_box_icon_id)
  elseif self.boxType == ChessCellAwardType.SILVER_BOX then
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), constant.CSignPreciousConsts.silver_big_box_icon_id)
  else
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), 0)
  end
  local lotteryCfg = ItemUtils.GetLotteryViewRandomCfg(self.boxCfgId)
  for i, v in pairs(lotteryCfg.itemIds) do
    local item = self.uiObjs.Grid:FindDirect(string.format("Item_%d", i))
    if item ~= nil then
      local itemBase = ItemUtils.GetItemBase(v)
      local Img_Icon = item:FindDirect("Texture_Icon"):GetComponent("UITexture")
      GUIUtils.FillIcon(Img_Icon, itemBase.icon)
      self.itemTipHelper:RegisterItem2ShowTip(v, item)
    end
  end
  GameUtil.AddGlobalTimer(0, true, function()
    self.uiObjs.Grid:GetComponent("UIGrid"):Reposition()
  end)
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Item_") then
    self.itemTipHelper:CheckItem2ShowTip(id)
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  end
end
return NewDailySignInBoxTips.Commit()
