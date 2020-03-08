local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NewDailySignInConfirmPanel = Lplus.Extend(ECPanelBase, "NewDailySignInConfirmPanel")
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
local def = NewDailySignInConfirmPanel.define
def.field("number").targetCell = 0
def.field("number").needYuanBao = 0
def.field("table").uiObjs = nil
def.field(AwardItemTipHelper).itemTipHelper = nil
local instance
def.static("=>", NewDailySignInConfirmPanel).Instance = function()
  if instance == nil then
    instance = NewDailySignInConfirmPanel()
  end
  return instance
end
def.method("number").ShowConfirmPanel = function(self, cell)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.targetCell = cell
  self:CreatePanel(RESPATH.PREFAB_PRIZE_NEW_QIANDAO_CONFIRM, 2)
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
  self.uiObjs.Label_Title = self.m_panel:FindDirect("Img_Title/Label_Title")
  self.uiObjs.Label_Tips1 = self.m_panel:FindDirect("Label_Tips1")
  self.uiObjs.Label_Tips2 = self.m_panel:FindDirect("Label_Tips2")
  self.uiObjs.Btn_Get = self.m_panel:FindDirect("Btn_Get")
  self.uiObjs.Group_Item = self.m_panel:FindDirect("Img_Bg/Group_Item")
  local gridTransform = self.uiObjs.Group_Item.transform
  local ctrlCount = gridTransform.childCount
  for i = 1, ctrlCount do
    local child = gridTransform:GetChild(i - 1).gameObject
    child.name = "Item_" .. i
  end
  self.itemTipHelper = AwardItemTipHelper()
  GUIUtils.SetActive(self.uiObjs.Label_Tips2, false)
end
def.method().SetBoxInfo = function(self)
  local boxCfg = NewDailySignInMgr.Instance():GetChessBoxAward(self.targetCell)
  if boxCfg == nil then
    warn("no box award at daily sign grid cell:" .. self.targetCell)
    return
  end
  self.needYuanBao = boxCfg.arrive_cost_yuan_bao
  local titleMap = {
    [1] = 3,
    [2] = 2,
    [3] = 1
  }
  for i = 1, 3 do
    local title = self.m_panel:FindDirect("Img_Title/Img_Lable" .. i)
    if titleMap[i] ~= boxCfg.cell_award_type then
      GUIUtils.SetActive(title, false)
    else
      GUIUtils.SetActive(title, true)
    end
  end
  GUIUtils.SetText(self.uiObjs.Label_Tips1, string.format(textRes.Award[151], textRes.Award.DailySignInBoxName[boxCfg.cell_award_type], self.needYuanBao))
  GUIUtils.SetText(self.uiObjs.Btn_Get:FindDirect("Label_Get"), string.format(textRes.Award[152], self.needYuanBao))
  local lotteryCfg = ItemUtils.GetLotteryViewRandomCfg(boxCfg.gold_precious_cfg_id)
  for i, v in pairs(lotteryCfg.itemIds) do
    local item = self.uiObjs.Group_Item:FindDirect(string.format("Item_%d", i))
    if item ~= nil then
      local itemBase = ItemUtils.GetItemBase(v)
      local Img_Icon = item:FindDirect("Img_Icon"):GetComponent("UITexture")
      GUIUtils.FillIcon(Img_Icon, itemBase.icon)
      GUIUtils.SetActive(item:FindDirect("Label_Num"), false)
      self.itemTipHelper:RegisterItem2ShowTip(v, item)
    end
  end
  GameUtil.AddGlobalTimer(0, true, function()
    self.uiObjs.Group_Item:GetComponent("UIGrid"):Reposition()
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Lucky" then
    self:OnBtnLuckyClick()
  elseif id == "Btn_Get" then
    self:OnBtnGetClick()
  else
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.method().OnBtnLuckyClick = function(self)
  local dailySignMgr = DailySignInMgr.Instance()
  local signInStates = dailySignMgr:GetSignInStates()
  local index = signInStates.signedDays + 1
  local result = DailySignInMgr.Instance():SignInOrRedress(index)
  if result == DailySignInMgr.CResult.SUCCESS then
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.DAILYSIGN, {index})
  elseif result == DailySignInMgr.CResult.NOT_SIGN_IN or result == DailySignInMgr.CResult.NOT_FIRST_REDRESS_DAY then
    Toast(textRes.Award[61])
  end
  self:DestroyPanel()
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
  NewDailySignInMgr.Instance():PayToArriveBoxAward()
  self:DestroyPanel()
end
return NewDailySignInConfirmPanel.Commit()
