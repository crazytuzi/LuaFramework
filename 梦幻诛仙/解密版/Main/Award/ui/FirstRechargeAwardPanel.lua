local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FirstRechargeAwardPanel = Lplus.Extend(ECPanelBase, "FirstRechargeAwardPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local FirstRechargeMgr = require("Main.Award.mgr.FirstRechargeMgr")
local def = FirstRechargeAwardPanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
def.field("table").uiObjs = nil
def.field("table").items = nil
local instance
def.static("=>", FirstRechargeAwardPanel).Instance = function()
  if instance == nil then
    instance = FirstRechargeAwardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_SyncLoad = true
  self:CreatePanel(RESPATH.PREFAB_FIRST_RECHARGE_AWARD_PANEL, 0)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  FirstRechargeMgr.Instance():MarkAsKnowAboutThisAward()
  self.items = FirstRechargeMgr.Instance():GetAwardItems()
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.FIRST_RECHARGE_STATUS_UPDATE, FirstRechargeAwardPanel.OnStatusUpdate)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.FIRST_RECHARGE_STATUS_UPDATE, FirstRechargeAwardPanel.OnStatusUpdate)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Recharge" then
    self:OnRechargeBtnClicked()
  elseif id == "Btn_LingQu" then
    self:OnDrawAwardBtnClicked()
  elseif string.find(id, "Img_BgIcon") then
    self:OnItemObjClicked(obj)
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Btn_Recharge = self.m_panel:FindDirect("Btn_Recharge")
  self.uiObjs.Btn_LingQu = self.m_panel:FindDirect("Btn_LingQu")
  self.uiObjs.Img_HaveChong = self.m_panel:FindDirect("Img_HaveChong")
  self.uiObjs.Grid_Items = self.m_panel:FindDirect("Grid_Items")
  self.uiObjs.Img_BgIcon = self.m_panel:FindDirect("Img_BgIcon2")
  self.uiObjs.Img_BgIcon2 = self.m_panel:FindDirect("Img_BgIcon")
  if self.uiObjs.Img_BgIcon then
    self.uiObjs.Img_BgIcon.name = "Img_BgIcon" .. 1
  end
  if self.uiObjs.Img_BgIcon2 then
    self.uiObjs.Img_BgIcon2.name = "Img_BgIcon" .. 2
  end
  local items = {}
  table.insert(items, self.uiObjs.Img_BgIcon)
  table.insert(items, self.uiObjs.Img_BgIcon2)
  for i = 1, 4 do
    local itemObj = self.uiObjs.Grid_Items:GetChild(i - 1)
    itemObj.name = "Img_BgIcon" .. i + 2
    table.insert(items, itemObj)
  end
  self.uiObjs.itemObjs = items
end
def.method("userdata", "table").SetItemInfo = function(self, itemObj, itemInfo)
  if itemObj == nil then
    return
  end
  if itemInfo == nil then
    itemObj:SetActive(false)
  end
  local Texture_Icon = itemObj:FindDirect("Texture_Icon")
  local Label_Num = itemObj:FindDirect("Label_Num")
  local Label_Name = itemObj:FindDirect("Label_Name")
  local num = itemInfo and itemInfo.num or ""
  local name = ""
  local icon = 0
  local quality = 0
  if itemInfo and itemInfo.itemId then
    local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
    if itemBase then
      name = itemBase.name
      icon = itemBase.icon
      quality = itemBase.namecolor
    end
  end
  GUIUtils.SetText(Label_Name, name)
  GUIUtils.SetText(Label_Num, num)
  GUIUtils.SetTexture(Texture_Icon, icon)
  GUIUtils.SetSprite(itemObj, string.format("Cell_%02d", quality))
end
def.method("userdata").OnItemObjClicked = function(self, obj)
  local index = tonumber(string.sub(obj.name, #"Img_BgIcon" + 1, -1))
  if index == nil then
    return
  end
  local itemInfo = self.items[index]
  if itemInfo == nil then
    return
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local itemId = itemInfo.itemId
  local needSource = false
  local prefer = 0
  local source = obj
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UIWidget")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), prefer, needSource)
end
def.method().OnRechargeBtnClicked = function(self)
  self:GoToRecharge()
  local PayModule = require("Main.Pay.PayModule")
  PayModule.Instance():SetPayTLogData(_G.TLOGTYPE.FIRSTCHARGE, {})
end
def.method().OnDrawAwardBtnClicked = function(self)
  if FirstRechargeMgr.Instance():HasDrawAward() then
    Toast(textRes.Award[18])
  elseif FirstRechargeMgr.Instance():HasRecharge() then
    FirstRechargeMgr.Instance():DrawAward()
  else
    self:GoToRecharge()
  end
end
def.method().UpdateUI = function(self)
  for i, v in ipairs(self.uiObjs.itemObjs) do
    self:SetItemInfo(v, self.items[i])
  end
  self:UpdateBtnState()
end
def.method().UpdateBtnState = function(self)
  local text = textRes.Award[17]
  local hasRecharge = FirstRechargeMgr.Instance():HasRecharge()
  local HasDrawAward = FirstRechargeMgr.Instance():HasDrawAward()
  GUIUtils.SetActive(self.uiObjs.Btn_Recharge, not hasRecharge)
  GUIUtils.SetActive(self.uiObjs.Btn_LingQu, hasRecharge and not HasDrawAward)
  GUIUtils.SetActive(self.uiObjs.Img_HaveChong, hasRecharge and HasDrawAward)
end
def.method().GoToRecharge = function(self)
  self:DestroyPanel()
  local MallPanel = require("Main.Mall.ui.MallPanel")
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
end
def.static("table", "table").OnStatusUpdate = function(params, context)
  instance:UpdateBtnState()
end
return FirstRechargeAwardPanel.Commit()
