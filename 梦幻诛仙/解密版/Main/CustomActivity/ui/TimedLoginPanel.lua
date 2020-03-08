local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local TimedLoginMgr = require("Main.CustomActivity.TimedLoginMgr")
local TimedLoginMgrInst = TimedLoginMgr.Instance()
local ItemUtils = require("Main.Item.ItemUtils")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local instance
local TimedLoginPanel = Lplus.Extend(ECPanelBase, "TimedLoginPanel")
local def = TimedLoginPanel.define
def.field("string").curTabName = ""
def.field("number").state = 0
def.field("table").uiObjs = nil
def.field(EasyBasicItemTip).itemTipHelper = nil
def.static("=>", TimedLoginPanel).Instance = function()
  if instance == nil then
    instance = TimedLoginPanel()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.state = 0
  self.itemTipHelper = nil
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.override("boolean").OnShow = function(self, show)
  if show then
    Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.TIMED_LOGIN_INFO_CHANGE, TimedLoginPanel.OnTimedLoginInfoChange)
    Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TimedLoginPanel.OnFunctionOpenChange)
    Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, TimedLoginPanel.OnActiveOpenChange)
    self:UpdateButton()
    self:SetBanner(TimedLoginMgrInst:GetBannerIconId())
    self:SetActTime(TimedLoginMgrInst:GetActTimeStr())
    self:SwitchTo(TimedLoginMgrInst:GetDefaultActType())
    self:UpdateRedPoint()
  else
    Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.TIMED_LOGIN_INFO_CHANGE, TimedLoginPanel.OnTimedLoginInfoChange)
    Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TimedLoginPanel.OnFunctionOpenChange)
    Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, TimedLoginPanel.OnActiveOpenChange)
  end
end
def.method().Init = function(self)
end
def.method().InitUI = function(self)
  self.itemTipHelper = EasyBasicItemTip()
  self.uiObjs = {}
  self.uiObjs.Img_BgTitle = self.m_panel:FindDirect("Group_Carnival/Img_BgTitle")
  self.uiObjs.Label_Time = self.uiObjs.Img_BgTitle:FindDirect("Label_Time")
  self.uiObjs.Group_Toggle = self.m_panel:FindDirect("Group_Carnival/Group_Toggle")
  self.uiObjs.Btn_Daily = self.uiObjs.Group_Toggle:FindDirect("Btn_Daily")
  self.uiObjs.Btn_Total = self.uiObjs.Group_Toggle:FindDirect("Btn_Total")
  self.uiObjs.Scroll_View = self.m_panel:FindDirect("Group_Carnival/Group_List/Scroll View")
  self.uiObjs.List_Prize = self.uiObjs.Scroll_View:FindDirect("List_Prize")
end
def.method("number").SetBanner = function(self, iconId)
  local uiTexture = self.uiObjs.Img_BgTitle:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
end
def.method("string").SetActTime = function(self, timeStr)
  self.uiObjs.Label_Time:GetComponent("UILabel"):set_text(timeStr)
end
def.method("number").SwitchTo = function(self, state)
  if self.state == state then
    return
  end
  self.state = state
  self:UpdateAwardList()
  self:UpdateToggleState()
end
def.method().UpdateToggleState = function(self)
  if TimedLoginMgr.ACT_TYPE.DAILY == self.state then
    self.uiObjs.Btn_Daily:GetComponent("UIToggle"):set_value(true)
  elseif TimedLoginMgr.ACT_TYPE.ACCUMULATIVE == self.state then
    self.uiObjs.Btn_Total:GetComponent("UIToggle"):set_value(true)
  end
end
def.method().UpdateAwardList = function(self)
  local cfgs = TimedLoginMgrInst:GetAllCfgs(self.state)
  if not cfgs then
    warn("----TimedLoginPanel UpdateAwardList error: cfgs is nil : state", self.state)
    return
  end
  local cellCount = #cfgs
  local uiList = self.uiObjs.List_Prize:GetComponent("UIList")
  uiList.itemCount = cellCount
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, uiList.itemCount do
    local uiItem = uiItems[i]
    self:UpdateCellFunc(uiItem, i)
  end
  uiList:GetComponent("UIList").repositionNow = true
  self.uiObjs.Scroll_View:GetComponent("UIScrollView"):ResetPosition()
  local focusIdx = TimedLoginMgrInst:GetFocusIndex(self.state)
  if focusIdx > 0 then
    GameUtil.AddGlobalTimer(0, true, function()
      if self.m_panel and not self.m_panel.isnil and uiList then
        uiList:GetComponent("UIList"):DragToMakeVisible(focusIdx - 1, 100)
      end
    end)
  end
end
def.method("userdata", "number").UpdateCellFunc = function(self, cell, idx)
  local desc, status, items, prgs = TimedLoginMgrInst:GetInfoByIdx(self.state, idx)
  self:SetCellItem(cell, idx, desc, status, items, prgs)
end
def.method("userdata", "number", "string", "number", "table", "string").SetCellItem = function(self, cell, idx, desc, status, items, prgs)
  local Img_Bg = cell
  Img_Bg:FindDirect("Label_1"):GetComponent("UILabel"):set_text(desc)
  local Btn_Get = Img_Bg:FindDirect("Btn_Get")
  local bShow = status == TimedLoginMgr.AWARD_STATUS.CAN or self.state == TimedLoginMgr.ACT_TYPE.DAILY and status == TimedLoginMgr.AWARD_STATUS.UNFINISHED
  Btn_Get:SetActive(bShow)
  GUIUtils.EnableButton(Btn_Get, status ~= TimedLoginMgr.AWARD_STATUS.UNFINISHED)
  local Img_Red = Btn_Get:FindDirect("Img_Red")
  Img_Red:SetActive(status == TimedLoginMgr.AWARD_STATUS.CAN)
  local Img_Get = Img_Bg:FindDirect("Img_Get")
  Img_Get:SetActive(status == TimedLoginMgr.AWARD_STATUS.ALREADY)
  local Img_Over = Img_Bg:FindDirect("Img_Over")
  if Img_Over then
    Img_Over:SetActive(status == TimedLoginMgr.AWARD_STATUS.EXPIRE)
  end
  local labPrgs = Img_Bg:FindDirect("Label_2")
  labPrgs:GetComponent("UILabel"):set_text(prgs)
  local Group_Icon = cell:FindDirect("Group_Icon")
  local MAX_ITEM_PER_ROW = 3
  for i = 1, MAX_ITEM_PER_ROW do
    local Img_BgIcon = Group_Icon:GetChild(i - 1)
    if Img_BgIcon == nil then
      break
    end
    local item = items[i]
    if item then
      Img_BgIcon:SetActive(true)
      local itemId = item.itemId
      local itemBase = ItemUtils.GetItemBase(itemId)
      local iconId = itemBase.icon
      local uiTexture = Img_BgIcon:FindDirect("Texture_Icon"):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, iconId)
      local count = 1 < item.num and item.num or ""
      Img_BgIcon:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(count)
      local quality = itemBase.namecolor
      local uiSprite = Img_BgIcon:GetComponent("UISprite")
      uiSprite:set_spriteName(string.format("Cell_%02d", quality))
      Img_BgIcon.name = "Img_BgIcon_" .. idx .. "_" .. i
      self.itemTipHelper:RegisterItem2ShowTip(itemId, Img_BgIcon)
    else
      Img_BgIcon:SetActive(false)
    end
  end
end
def.method().UpdateButton = function(self)
  self.uiObjs.Btn_Daily:SetActive(TimedLoginMgrInst:IsOpen(TimedLoginMgr.ACT_TYPE.DAILY) and TimedLoginMgrInst:IsFeatureOpen(TimedLoginMgr.ACT_TYPE.DAILY))
  self.uiObjs.Btn_Total:SetActive(TimedLoginMgrInst:IsOpen(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE) and TimedLoginMgrInst:IsFeatureOpen(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE))
  self.uiObjs.Group_Toggle:GetComponent("UITable"):Reposition()
end
def.method().UpdateRedPoint = function(self)
  self.uiObjs.Btn_Daily:FindDirect("Img_Red"):SetActive(TimedLoginMgrInst:IsCanGetAward(TimedLoginMgr.ACT_TYPE.DAILY))
  self.uiObjs.Btn_Total:FindDirect("Img_Red"):SetActive(TimedLoginMgrInst:IsCanGetAward(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE))
end
def.method("number").DoGetAward = function(self, idx)
  if TimedLoginMgr.ACT_TYPE.DAILY == self.state then
    TimedLoginMgrInst:CGetLoginAward(idx)
  elseif TimedLoginMgr.ACT_TYPE.ACCUMULATIVE == self.state then
    TimedLoginMgrInst:CGetLoginSumSignAward(idx)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Daily" then
    self:SwitchTo(TimedLoginMgr.ACT_TYPE.DAILY)
  elseif id == "Btn_Total" then
    self:SwitchTo(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE)
  elseif string.find(id, "Img_BgIcon") == 1 then
    self.itemTipHelper:CheckItem2ShowTip(id, -1, false)
  elseif id == "Btn_Get" then
    local idx = tonumber(string.sub(clickObj.parent.name, #"item_" + 1, -1))
    self:DoGetAward(idx)
  end
end
def.static("table", "table").OnTimedLoginInfoChange = function(params)
  local inst = TimedLoginPanel.Instance()
  inst:UpdateRedPoint()
  inst:UpdateAwardList()
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1 and (p1.feature == Feature.TYPE_LOGIN_ACTIVITY or p1.feature == Feature.TYPE_LOGIN_SUM_ACTIVITY) then
    local inst = TimedLoginPanel.Instance()
    inst:UpdateButton()
    inst:SwitchTo(TimedLoginMgrInst:GetDefaultActType())
  end
end
def.static("table", "table").OnActiveOpenChange = function(p1, p2)
  local inst = TimedLoginPanel.Instance()
  inst:UpdateButton()
  inst:SwitchTo(TimedLoginMgrInst:GetDefaultActType())
end
def.method("string").ShowPanel = function(self, tabName)
  if self:IsShow() then
    return
  end
  self.curTabName = tabName
  self:CreatePanel(RESPATH.PREFAB_PRIZE_CARNIVAL, 0)
end
return TimedLoginPanel.Commit()
