local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatRedGiftSendPanel = Lplus.Extend(ECPanelBase, "ChatRedGiftSendPanel")
local def = ChatRedGiftSendPanel.define
local ChatRedGiftUtility = require("Main.ChatRedGift.ChatRedGiftUtility")
local ChatRedGiftData = require("Main.ChatRedGift.ChatRedGiftData")
local ChatRedGiftMessageValidator = require("Main.ChatRedGift.ChatRedGiftMessageValidator")
local NameValidator = require("Main.Common.NameValidator")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local GangModule = require("Main.Gang.GangModule")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GroupModule = require("Main.Group.GroupModule")
local GroupUtils = require("Main.Group.GroupUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local instance
def.field("number").channelType = -1
def.field("number").channelSubType = -1
def.field("userdata").groupId = nil
def.field("table").chatRedGiftConfigs = nil
def.field("number").redgiftSendNum = 1
def.field("string").messageNote = ""
def.field("number").selectedRedGiftIndex = -1
def.field("number").maxSendLimitNum = -1
def.field("number").minSnedLimitNum = 1
def.field("number").pressedTime = 0
def.field("number").incPropTime = 0
def.field("number").decPropTime = 0
def.static("=>", ChatRedGiftSendPanel).Instance = function()
  if not instance then
    instance = ChatRedGiftSendPanel()
    instance:Init()
    instance.m_TrigGC = true
  end
  return instance
end
def.method().Init = function(self)
  self.chatRedGiftConfigs = ChatRedGiftData.GetChatRedGiftConfigs()
end
def.method("number", "number", "userdata").ShowPanel = function(self, _channeltype, _channelSubType, _groupId)
  if self:IsShow() then
    return
  end
  self.channelType = _channeltype
  self.channelSubType = _channelSubType
  self.groupId = _groupId
  warn("Send GroupRedGift :" .. tostring(self.groupId))
  self:CreatePanel(RESPATH.PREFAB_CHATREDGIFT_SEND_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  Event.RegisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Refresh_LeftRedGiftNumChange, ChatRedGiftSendPanel.OnNumberChange)
  if not self.chatRedGiftConfigs then
    self.chatRedGiftConfigs = ChatRedGiftData.GetChatRedGiftConfigs()
  end
  self.minSnedLimitNum = ChatRedGiftData.GetSenRedGiftMinNum()
  self.redgiftSendNum = self.minSnedLimitNum
  self:UpdateUI()
  self:UpdateMemberNum()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Refresh_LeftRedGiftNumChange, ChatRedGiftSendPanel.OnNumberChange)
  self.channelType = -1
  self.channelSubType = -1
  self.groupId = nil
  self.redgiftSendNum = 1
  self.selectedRedGiftIndex = -1
  self.maxSendLimitNum = -1
  self.minSnedLimitNum = 1
  self.incPropTime = 0
  self.decPropTime = 0
  if self.pressedTime ~= 0 then
    Timer:RemoveIrregularTimeListener(self.OnIncPropTimer)
    self.pressedTime = 0
  end
end
def.static("table", "table").OnNumberChange = function(params, tbl)
  instance:UpdateUI()
end
def.method().UpdateUI = function(self)
  if self:IsShow() then
    if self.selectedRedGiftIndex <= 0 then
      self.selectedRedGiftIndex = 1
    end
    local container = self.m_panel:FindDirect("Img_Bg/Group_Choice/Container")
    if container then
      for i = 1, 8 do
        local curgroup = container:FindDirect(string.format("Group_%d", i))
        if not curgroup then
          break
        end
        local tmpconfig = self.chatRedGiftConfigs[i]
        if tmpconfig then
          curgroup:SetActive(true)
          local yuanbao_Num = curgroup:FindDirect("Label_YuanBaoNum"):GetComponent("UILabel")
          local gold_Num = curgroup:FindDirect("Label_GoldNum"):GetComponent("UILabel")
          yuanbao_Num:set_text(tostring(tmpconfig.yuanbao))
          gold_Num:set_text(tostring(tmpconfig.gold))
        else
          curgroup:SetActive(false)
        end
      end
    end
    local canSend_Num = self.m_panel:FindDirect("Img_Bg/Label_CanSend/Label_Num"):GetComponent("UILabel")
    local leftSendTimes = ChatRedGiftData.GetTodayLeftRedGiftTimes()
    canSend_Num:set_text(tostring(leftSendTimes))
    self:UpdateSelectRedGift()
    self:SetEnteredValue(false)
  end
end
def.method().UpdateSelectRedGift = function(self)
  if self.selectedRedGiftIndex <= 0 then
    return
  end
  local toggle = self.m_panel:FindDirect(string.format("Img_Bg/Group_Choice/Container/Group_%d/Img_Toggle%d", self.selectedRedGiftIndex, self.selectedRedGiftIndex)):GetComponent("UIToggle")
  toggle:set_value(true)
end
def.method().UpdateMemberNum = function(self)
  if self:IsShow() then
    local memberTypeTip = ""
    local realNum = 0
    if self.channelType == ChatMsgData.MsgType.CHANNEL and self.channelSubType == ChatMsgData.Channel.FACTION then
      if GangModule.Instance():HasGang() then
        local gangInfo = GangData.Instance():GetGangBasicInfo()
        local bangzhongId = GangUtility.GetGangConsts("BANGZHONG_ID")
        local bangzhongMax = GangUtility.GetDutyMaxNum(bangzhongId, gangInfo.wingLevel)
        local _maxnum = bangzhongMax < ChatRedGiftData.GetSenRedGiftMaxNum() and bangzhongMax or ChatRedGiftData.GetSenRedGiftMaxNum()
        local onlineBangzhong, allBangzhong = GangData.Instance():GetOnlineAndAllBangzhongNum()
        self.maxSendLimitNum = allBangzhong
        realNum = allBangzhong
      else
        self.maxSendLimitNum = -1
      end
      memberTypeTip = textRes.ChatRedGift[50]
    elseif self.channelType == ChatMsgData.MsgType.GROUP and self.channelSubType == ChatMsgData.Channel.GROUP then
      if GroupModule.Instance():IsGroupExist(self.groupId) then
        self.maxSendLimitNum = GroupUtils.GetGroupMaxMemberNum()
        realNum = GroupModule.Instance():GetGroupMemberNum(self.groupId)
        if realNum < self.maxSendLimitNum then
          self.maxSendLimitNum = realNum
        end
      else
        self.maxSendLimitNum = -1
      end
      memberTypeTip = textRes.ChatRedGift[51]
    end
    if self.maxSendLimitNum > constant.ChatGiftConsts.maxNum then
      self.maxSendLimitNum = constant.ChatGiftConsts.maxNum
    end
    if self.maxSendLimitNum == -1 then
      Toast(textRes.ChatRedGift[4])
      self:DestroyPanel()
    else
      if self.maxSendLimitNum < self.minSnedLimitNum then
        self.maxSendLimitNum = self.minSnedLimitNum
      end
      local group_tip = self.m_panel:FindDirect("Img_Bg/Label_GroupNum")
      group_tip:GetComponent("UILabel"):set_text(memberTypeTip)
      local label_groupnum = self.m_panel:FindDirect("Img_Bg/Label_GroupNum/Label_Num")
      label_groupnum:GetComponent("UILabel"):set_text(tostring(realNum))
      self:SetEnteredValue(false)
    end
  end
end
def.method("boolean").SetEnteredValue = function(self, isShowLog)
  if self.redgiftSendNum < self.minSnedLimitNum then
    if isShowLog then
      Toast(string.format(textRes.ChatRedGift[2], self.minSnedLimitNum))
    end
    self.redgiftSendNum = self.minSnedLimitNum
  elseif self.redgiftSendNum > self.maxSendLimitNum then
    if isShowLog then
      Toast(string.format(textRes.ChatRedGift[3], self.maxSendLimitNum))
    end
    self.redgiftSendNum = self.maxSendLimitNum
  end
  local Label_Num = self.m_panel:FindDirect("Img_Bg/Group_SendNun/Btn_Num/Label_Num"):GetComponent("UILabel")
  Label_Num:set_text(self.redgiftSendNum)
end
def.method("string", "boolean").onPress = function(self, id, state)
  if id == "Btn_Add" then
    if state == true then
      self.pressedTime = 0
      Timer:RegisterIrregularTimeListener(self.OnIncPropTimer, self)
    else
      Timer:RemoveIrregularTimeListener(self.OnIncPropTimer)
      self.pressedTime = 0
    end
  elseif id == "Btn_Minus" then
    if state == true then
      self.pressedTime = 0
      Timer:RegisterIrregularTimeListener(self.OnDecPropTimer, self)
    else
      Timer:RemoveIrregularTimeListener(self.OnDecPropTimer)
      self.pressedTime = 0
    end
  end
end
def.method("number").OnIncPropTimer = function(self, dt)
  self.pressedTime = self.pressedTime + dt
  if self.pressedTime < 0.5 then
    return
  end
  local interval = 0.1
  self.incPropTime = self.incPropTime + dt
  if interval <= self.incPropTime then
    self:OnAddNumClick()
    self.incPropTime = self.incPropTime - interval
  end
end
def.method("number").OnDecPropTimer = function(self, dt)
  self.pressedTime = self.pressedTime + dt
  if self.pressedTime < 0.5 then
    return
  end
  local interval = 0.1
  self.decPropTime = self.decPropTime + dt
  if interval <= self.decPropTime then
    self:OnMinusNumClick()
    self.decPropTime = self.decPropTime - interval
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  warn("onClickObj" .. id)
  if id:find("Img_Toggle") then
    local index = string.sub(id, #"Img_Toggle" + 1, -1)
    index = tonumber(index)
    if self.selectedRedGiftIndex ~= index then
      self.selectedRedGiftIndex = index
      self:UpdateSelectRedGift()
    end
  elseif "Btn_Close" == id then
    self:DestroyPanel()
  elseif id == "Btn_Send" then
    self:SnedRedGift()
  elseif id == "Label_Num" then
    self:OnSetNumBtnClick()
  elseif id == "Btn_Minus" then
    self:OnMinusNumClick()
  elseif id == "Btn_Add" then
    self:OnAddNumClick()
  elseif id == "Btn_Tips" then
    self:OnTipsClick()
  end
end
def.method("string", "=>", "boolean").ValidEnteredName = function(self, enteredName)
  local isValid, reason, wordNum = ChatRedGiftMessageValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooLong then
      warn("ChatRedGift Message:" .. wordNum .. ":" .. enteredName)
      Toast(textRes.ChatRedGift[9])
    end
    return false
  end
end
def.method().SnedRedGift = function(self)
  if self.selectedRedGiftIndex <= 0 then
    Toast(textRes.ChatRedGift[5])
    return
  end
  local leftSendTimes = ChatRedGiftData.GetTodayLeftRedGiftTimes()
  if leftSendTimes <= 0 then
    Toast(textRes.ChatRedGift[6])
    return
  end
  local input = self.m_panel:FindDirect("Img_Bg/Group_Info/Group_NameContent/Label_NameContent"):GetComponent("UIInput")
  local content = input:get_value()
  if content == "" then
    content = textRes.ChatRedGift[8]
  end
  content = _G.TrimIllegalChar(content)
  local contentValid = self:ValidEnteredName(content)
  if contentValid then
    local yuanbao = ItemModule.Instance():getCashYuanBao()
    local cost = self.chatRedGiftConfigs[self.selectedRedGiftIndex].yuanbao
    self.messageNote = content
    if yuanbao:lt(cost) then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local tag = {id = self}
      CommonConfirmDlg.ShowConfirm("", textRes.Gang[59], ChatRedGiftSendPanel.BuyYuanbaoCallback, tag)
      return
    end
    local tag = {id = self}
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.ChatRedGift[10], cost), ChatRedGiftSendPanel.SendRedGiftCallback, tag)
  end
end
def.static("number", "table").BuyYuanbaoCallback = function(i, tag)
  if i == 1 then
    local self = tag.id
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  end
end
def.static("number", "table").SendRedGiftCallback = function(i, tag)
  if i == 1 then
    local self = tag.id
    local yuanbao = ItemModule.Instance():getCashYuanBao()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CChatGiftReq").new(self.channelSubType, self.groupId or Int64.new(-1), self.chatRedGiftConfigs[self.selectedRedGiftIndex].id, self.redgiftSendNum, self.messageNote, Int64.new(yuanbao)))
    if self:IsShow() then
      self:DestroyPanel()
    end
  end
end
def.method().OnMinusNumClick = function(self)
  if self.selectedRedGiftIndex <= 0 then
    Toast(textRes.ChatRedGift[5])
    return
  end
  if self.redgiftSendNum - 1 < self.minSnedLimitNum then
    Toast(string.format(textRes.ChatRedGift[2], self.minSnedLimitNum))
    self.redgiftSendNum = self.minSnedLimitNum
  else
    self.redgiftSendNum = self.redgiftSendNum - 1
  end
  self:SetEnteredValue(false)
end
def.method().OnAddNumClick = function(self)
  if self.selectedRedGiftIndex <= 0 then
    Toast(textRes.ChatRedGift[5])
    return
  end
  if self.redgiftSendNum + 1 > self.maxSendLimitNum then
    Toast(string.format(textRes.ChatRedGift[3], self.maxSendLimitNum))
    self.redgiftSendNum = self.maxSendLimitNum
  else
    self.redgiftSendNum = self.redgiftSendNum + 1
  end
  self:SetEnteredValue(false)
end
def.method().OnSetNumBtnClick = function(self)
  if self.selectedRedGiftIndex <= 0 then
    Toast(textRes.ChatRedGift[5])
    return
  end
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():ShowPanelEx(-1, ChatRedGiftSendPanel.OnDigitalKeyboardCallback, {_self = self})
  CommonDigitalKeyboard.Instance():SetPos(10, -1)
end
def.static("number", "table").OnDigitalKeyboardCallback = function(value, tag)
  local self = tag._self
  self.redgiftSendNum = value
  self:SetEnteredValue(true)
end
def.method().OnTipsClick = function(self)
  local tipsId = constant.ChatGiftConsts.gangChatGiftTips
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 50, -90)
end
ChatRedGiftSendPanel.Commit()
return ChatRedGiftSendPanel
