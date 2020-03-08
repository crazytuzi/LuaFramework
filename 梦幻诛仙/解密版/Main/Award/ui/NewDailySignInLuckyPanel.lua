local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NewDailySignInLuckyPanel = Lplus.Extend(ECPanelBase, "NewDailySignInLuckyPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local DailySignInMgr = require("Main.Award.mgr.DailySignInMgr")
local NewDailySignInMgr = require("Main.Award.mgr.NewDailySignInMgr")
local AwardUtils = require("Main.Award.AwardUtils")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local ChessCellAwardType = require("consts.mzm.gsp.signprecious.confbean.ChessCellAwardType")
local def = NewDailySignInLuckyPanel.define
def.field("number").boxCfgId = 0
def.field("number").boxType = 0
def.field("number").needYuanBao = 0
def.field("table").uiObjs = nil
def.field(AwardItemTipHelper).itemTipHelper = nil
local instance
def.static("=>", NewDailySignInLuckyPanel).Instance = function()
  if instance == nil then
    instance = NewDailySignInLuckyPanel()
  end
  return instance
end
def.method("number", "number", "number").ShowPanel = function(self, cfgId, boxType, needYuanBao)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.boxCfgId = cfgId
  self.boxType = boxType
  self.needYuanBao = needYuanBao
  self:CreatePanel(RESPATH.PREFAB_PRIZE_NEW_QIANDAO_LUCKY, 1)
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
  self.uiObjs.Label_Tips = self.m_panel:FindDirect("Label_Tips1")
  self.uiObjs.Label_Tips2 = self.m_panel:FindDirect("Label_Tips2")
  self.uiObjs.Group_Box = self.m_panel:FindDirect("Img_Bg/Group_Box")
  self.uiObjs.Box = self.uiObjs.Group_Box:FindDirect("Box_01")
  self.uiObjs.Label_Get = self.m_panel:FindDirect("Btn_Get/Label_Get")
  self.uiObjs.Group_Box = self.m_panel:FindDirect("Img_Bg/Group_Box")
  local gridTransform = self.uiObjs.Group_Box.transform
  local ctrlCount = gridTransform.childCount
  for i = 1, ctrlCount do
    local child = gridTransform:GetChild(i - 1).gameObject
    child.name = "Box_" .. i
  end
  self.itemTipHelper = AwardItemTipHelper()
  GUIUtils.SetActive(self.uiObjs.Label_Tips2, false)
end
def.method().SetBoxInfo = function(self)
  local titleMap = {
    [1] = 3,
    [2] = 2,
    [3] = 1
  }
  for i = 1, 3 do
    local title = self.m_panel:FindDirect("Img_Title/Img_Lable" .. i)
    if titleMap[i] ~= self.boxType then
      GUIUtils.SetActive(title, false)
    else
      GUIUtils.SetActive(title, true)
    end
  end
  GUIUtils.SetText(self.uiObjs.Label_Tips, string.format(textRes.Award[155], textRes.Award.DailySignInBoxName[self.boxType], self.needYuanBao))
  GUIUtils.SetText(self.uiObjs.Label_Get, string.format(textRes.Award[152], self.needYuanBao))
  local lotteryCfg = ItemUtils.GetLotteryViewRandomCfg(self.boxCfgId)
  for i, v in pairs(lotteryCfg.itemIds) do
    local item = self.uiObjs.Group_Box:FindDirect(string.format("Box_%d", i))
    if item ~= nil then
      local itemBase = ItemUtils.GetItemBase(v)
      local Img_Icon = item:FindDirect("Img_Icon"):GetComponent("UITexture")
      GUIUtils.FillIcon(Img_Icon, itemBase.icon)
      GUIUtils.SetActive(item:FindDirect("Label_Num"), false)
      self.itemTipHelper:RegisterItem2ShowTip(v, item)
    end
  end
  GameUtil.AddGlobalTimer(0, true, function()
    self.uiObjs.Group_Box:GetComponent("UIGrid"):Reposition()
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Lucky" then
    self:DestroyPanel()
  elseif id == "Btn_Get" then
    self:OnBtnGetClick()
  elseif id == "Box_01" then
    self:OnBoxClick()
  else
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.method().OnBtnGetClick = function(self)
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
  local moneyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
  local haveNum = moneyData:GetHaveNum()
  local needNum = Int64.new(self.needYuanBao)
  if haveNum < needNum then
    moneyData:AcquireWithQuery()
    return
  end
  NewDailySignInMgr.Instance():PayToOpenLuckyBoxAward(haveNum)
  self:DestroyPanel()
end
def.method().OnBoxClick = function(self)
  require("Main.Award.ui.NewDailySignInBoxTips").Instance():ShowPanel(self.boxCfgId, self.boxType)
end
return NewDailySignInLuckyPanel.Commit()
