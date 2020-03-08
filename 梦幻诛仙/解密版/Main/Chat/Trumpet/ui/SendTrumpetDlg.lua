local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local MathHelper = require("Common.MathHelper")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ChatUtils = require("Main.Chat.ChatUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
local TrumpetInputCtrl = require("Main.Chat.Trumpet.ui.TrumpetInputCtrl")
local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
local ItemAccessMgr = require("Main.Item.ItemAccessMgr")
local ChannelType = require("consts.mzm.gsp.chat.confbean.ChannelType")
local HeroInterface = require("Main.Hero.Interface")
local TrumpetMgr = require("Main.Chat.Trumpet.TrumpetMgr")
local trumpetMgr = TrumpetMgr.Instance()
local SendTrumpetDlg = Lplus.Extend(ECPanelBase, "SendTrumpetDlg")
local def = SendTrumpetDlg.define
local instance
def.static("=>", SendTrumpetDlg).Instance = function()
  if instance == nil then
    instance = SendTrumpetDlg()
  end
  return instance
end
def.const("number").TICK_INTERVAL = 0.033
def.field("table").m_uiObjs = nil
def.field("table").m_trumpetInputCtrl = nil
def.field("number").m_preSelectIndex = 0
def.field("number").m_selectedIndex = 0
def.field("userdata").m_input = nil
def.field("number").m_timerID = 0
def.field("string").m_preInputContent = ""
def.field("userdata").m_htmlContent = nil
def.static("table").ShowDlg = function(params)
  if not TrumpetMgr.Instance():IsOpen(true) then
    if SendTrumpetDlg.Instance():IsShow() then
      SendTrumpetDlg.Instance():DestroyPanel()
    end
    return
  end
  if SendTrumpetDlg.Instance():IsShow() then
    return
  end
  if params then
    do
      local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(params.bagId, params.itemKey)
      if itemInfo then
        SendTrumpetDlg.Instance().m_preSelectIndex = trumpetMgr:GetTrumpetIndexByItemId(itemInfo.id)
      end
    end
  else
  end
  SendTrumpetDlg.Instance():CreatePanel(RESPATH.PREFAB_SEND_TRUMPET, 0)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  local inputNode = self.m_panel:FindDirect("Img_Bg0/Group_ChatInput")
  self.m_trumpetInputCtrl = TrumpetInputCtrl()
  self.m_trumpetInputCtrl:Init(self, inputNode, SendTrumpetDlg.SendTrumpet)
  if self.m_timerID == 0 then
    self.m_timerID = GameUtil.AddGlobalTimer(SendTrumpetDlg.TICK_INTERVAL, false, function()
      self:Tick()
    end)
  end
end
def.override().OnDestroy = function(self)
  if self.m_trumpetInputCtrl then
    self.m_trumpetInputCtrl:OnDestroy()
  end
  if self.m_timerID > 0 then
    GameUtil.RemoveGlobalTimer(self.m_timerID)
    self.m_timerID = 0
  end
  self.m_selectedIndex = 0
  self.m_preInputContent = ""
end
def.override("boolean").OnShow = function(self, show)
  if self.m_trumpetInputCtrl then
    self.m_trumpetInputCtrl:OnShow(show)
  end
  if show then
    self:InitUI()
    self:ShowTrumpetItems()
    local selectindex = math.max(self.m_preSelectIndex, 1)
    self:SetTrumpetToggle(selectindex)
  end
  self:HandleEventListeners(show)
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, SendTrumpetDlg.OnItemChange)
  end
end
def.static("table", "table").OnItemChange = function(p1, p2)
  SendTrumpetDlg.Instance():UpdateTrumpetList()
  SendTrumpetDlg.Instance():UpdateCosts()
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  self.m_uiObjs.ScrollView = self.m_panel:FindDirect("Img_Bg0/Group_Item/Scrollview_Item")
  self.m_uiObjs.List = self.m_uiObjs.ScrollView:FindDirect("List_Item")
  self.m_uiObjs.uiList = self.m_uiObjs.List:GetComponent("UIList")
  self.m_input = self.m_panel:FindDirect("Img_Bg0/Group_ChatInput"):FindDirect("Img_BgInput"):GetComponent("UIInput")
  self.m_htmlContent = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Label_Content"):GetComponent("NGUIHTML")
  self.m_htmlContent:ForceHtmlText("")
  self.m_uiObjs._Img_Money = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Img_Money")
  self.m_uiObjs._Img_MoneyBg = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Img_MoneyBg")
  self.m_uiObjs._Label_Cost = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Label_Cost")
  self.m_uiObjs._Label_CostNum = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Label_CostNum")
  self.m_uiObjs._Label_Content = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Label_Content")
  self.m_uiObjs._Img_BgInput = self.m_panel:FindDirect("Img_Bg0/Group_ChatInput/Img_BgInput")
  self.m_uiObjs._Img_BgInput:GetComponent("UIInput"):set_characterLimit(constant.CTrumpetConsts.MAX_WORD_NUM)
end
def.method().ShowTrumpetItems = function(self)
  local trumpetList = trumpetMgr:GetTrumpetCfgs()
  if trumpetList == nil then
    warn("[SendTrumpetDlg:ShowTrumpetItems] DynamicData.GetTable(CFG_PATH.DATA_CHAT_TRUMPET) nil!")
    return
  end
  self.m_uiObjs.ScrollView:GetComponent("UIScrollView"):ResetPosition()
  self.m_uiObjs.uiList.itemCount = #trumpetList
  self.m_uiObjs.uiList:Resize()
  for i, v in ipairs(trumpetList) do
    self:SetListItem(i, v)
  end
end
def.method("number", "table").SetListItem = function(self, index, trumpetCfg)
  if index == 0 then
    return
  end
  local itemCfg = ItemUtils.GetItemBase(trumpetCfg.itemid)
  local listItem = self.m_uiObjs.List:FindDirect("Item_" .. index)
  local Icon_EquipMakeItem = listItem:FindDirect("Icon_EquipMakeItem_" .. index)
  GUIUtils.SetTexture(Icon_EquipMakeItem, itemCfg.icon)
  local Label_EquipMakeItem = listItem:FindDirect("Label_EquipMakeItem_" .. index)
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, trumpetCfg.itemid)
  GUIUtils.SetText(Label_EquipMakeItem, num)
end
def.method().UpdateTrumpetList = function(self)
  for index, trumpetCfg in ipairs(trumpetMgr:GetTrumpetCfgs()) do
    local listItem = self.m_uiObjs.List:FindDirect("Item_" .. index)
    local Label_EquipMakeItem = listItem:FindDirect("Label_EquipMakeItem_" .. index)
    local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, trumpetCfg.itemid)
    GUIUtils.SetText(Label_EquipMakeItem, num)
  end
end
def.method("number").SetTrumpetToggle = function(self, selectedIndex)
  local listItem = self.m_uiObjs.ScrollView:FindDirect("List_Item/Item_" .. selectedIndex)
  listItem:GetComponent("UIToggle"):set_value(true)
end
def.method("=>", "number").GetSelectedTrumpetId = function(self)
  local trumpetCfg = trumpetMgr:GetTrumpetCfgByIndex(self.m_selectedIndex)
  return trumpetCfg and trumpetCfg.id or 0
end
def.method("=>", "number").GetSelectedTrumpetItemId = function(self)
  local trumpetCfg = trumpetMgr:GetTrumpetCfgByIndex(self.m_selectedIndex)
  return trumpetCfg and trumpetCfg.itemid or 0
end
def.method("=>", "table").GetSelectedTrumpetCfg = function(self)
  local trumpetCfg = trumpetMgr:GetTrumpetCfgByIndex(self.m_selectedIndex)
  return trumpetCfg
end
def.method().ClearInput = function(self)
  if not _G.IsNil(self.m_panel) then
    self.m_panel:FindDirect("Img_Bg0/Group_ChatInput/Img_BgInput"):GetComponent("UIInput"):set_value("")
  end
end
def.static("string", "=>", "boolean").SendTrumpet = function(content)
  warn("[SendTrumpetDlg:SendTrumpet] SendTrumpet:", content)
  local trumpetCfg = SendTrumpetDlg.Instance():GetSelectedTrumpetCfg()
  if trumpetCfg == nil then
    Toast(textRes.Chat.Trumpet.TRUMPET_INVALID)
    return false
  end
  return trumpetMgr:SendCChatInTrumpetReq(trumpetCfg.id, content)
end
def.method("number").OnTrumpetSelected = function(self, index)
  if self.m_selectedIndex == index then
    return
  end
  local oldindex = self.m_selectedIndex
  self.m_selectedIndex = index
  local trumpetCfg = trumpetMgr:GetTrumpetCfgByIndex(self.m_selectedIndex)
  if nil == trumpetCfg then
    warn("[SendTrumpetDlg:OnTrumpetSelected] trumpetcfg nil for id:", self:GetSelectedTrumpetItemId())
    return
  end
  local itemCfg = ItemUtils.GetItemBase(trumpetCfg.itemid)
  local imgBG = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Img_Item")
  GUIUtils.SetSprite(imgBG, trumpetCfg.spriteName)
  local Label_Name = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Label_Name")
  GUIUtils.SetText(Label_Name, itemCfg.name)
  local Label_TimeNum = self.m_panel:FindDirect("Img_Bg0/Group_EffectPreview/Label_TimeNum")
  GUIUtils.SetText(Label_TimeNum, string.format(textRes.Chat.Trumpet.DURATION, trumpetCfg.durationNormal))
  self:UpdateCosts()
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, trumpetCfg.itemid)
  if 0 ~= oldindex and num <= 0 then
    local itemId = self:GetSelectedTrumpetItemId()
    local btnGo = self.m_uiObjs.ScrollView:FindDirect("List_Item/Item_" .. self.m_selectedIndex)
    local position = btnGo.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = btnGo:GetComponent("UIWidget")
    ItemAccessMgr.Instance():ShowSource(itemId, screenPos.x, screenPos.y, widget.width, widget.height, 0)
  end
  self:onContentChange(self.m_trumpetInputCtrl:GetContent(self.m_input:get_value()))
end
def.method().UpdateCosts = function(self)
  local trumpetCfg = trumpetMgr:GetTrumpetCfgByIndex(self.m_selectedIndex)
  if nil == trumpetCfg then
    warn("[SendTrumpetDlg:UpdateCosts] trumpetcfg nil for id:", self:GetSelectedTrumpetItemId())
    return
  end
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, trumpetCfg.itemid)
  self.m_uiObjs._Img_Money:SetActive(num <= 0)
  self.m_uiObjs._Img_MoneyBg:SetActive(num <= 0)
  self.m_uiObjs._Label_Cost:SetActive(num <= 0)
  self.m_uiObjs._Label_CostNum:SetActive(num <= 0)
  if num <= 0 then
    GUIUtils.SetText(self.m_uiObjs._Label_CostNum, trumpetCfg.costYB)
  end
end
def.method().Tick = function(self)
  if not _G.IsNil(self.m_input) and self.m_preInputContent ~= self.m_input:get_value() then
    self.m_preInputContent = self.m_input:get_value()
    self:onContentChange(self.m_trumpetInputCtrl:GetContent(self.m_input:get_value()))
  end
end
def.method("string").onContentChange = function(self, content)
  local msg = {}
  msg.id = ChannelType.CHANNEL_TRUMPRT
  msg.roleId = HeroInterface.GetHeroProp().id
  msg.roleName = HeroInterface.GetHeroProp().name
  msg.trumpetId = self:GetSelectedTrumpetId()
  msg.badge = {}
  msg.content = content
  msg.content = ChatMsgBuilder.CustomFilter(msg.content)
  msg.content = _G.TrimIllegalChar(msg.content)
  msg.content = HtmlHelper.ConvertInfoPack(msg.content)
  msg.previewHtml = HtmlHelper.ConvertTrumpetPreviewChat(msg)
  self.m_htmlContent:ForceHtmlText(msg.previewHtml)
end
def.method("string").onClick = function(self, id)
  if self.m_trumpetInputCtrl:onClick(id) then
  elseif id == "Btn_Close" then
    self:DestroyPanel()
    ChannelChatPanel.ShowChannelChatPanel(-1, -1)
  elseif id == "Btn_Send" then
    self:OnSendClicked()
  end
end
def.method().OnSendClicked = function(self)
  self.m_trumpetInputCtrl:SubmitContent()
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if active then
    self:OnTrumpetSelected(tonumber(string.sub(id, string.find(id, "_") + 1)))
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  if self.m_trumpetInputCtrl:onSubmit(id, ctrl) then
  end
end
def.method("string").onLongPress = function(self, id)
  if self.m_trumpetInputCtrl:onLongPress(id) then
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  if self.m_trumpetInputCtrl:onPress(id, state) then
  end
end
def.method("string", "userdata").onDragOut = function(self, id, go)
  if self.m_trumpetInputCtrl:onDragOut(id, go) then
  end
end
def.method("string", "userdata").onDragOver = function(self, id, go)
  if self.m_trumpetInputCtrl:onDragOver(id, go) then
  end
end
SendTrumpetDlg.Commit()
return SendTrumpetDlg
