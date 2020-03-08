local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local BubbleNode = Lplus.Extend(TabNode, "BubbleNode")
local def = BubbleNode.define
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ChatBubbleUtils = require("Main.Chat.ChatBubble.ChatBubbleUtils")
local ChatBubbleMgr = require("Main.Chat.ChatBubble.ChatBubbleMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.Chat.ChatBubble
local const = constant.ChatBubbleConsts
local Cls = BubbleNode
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._myClsBubbles = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self.m_base:setCurAvatarInfo()
  self._uiStatus = {}
  self._uiStatus.selIdx = 0
  self._uiStatus.bWearDefault = true
  self._uiStatus.iBubbleCfgId = const.defaultChatBubbleCfgId
  self._uiGOs = {}
  local uiGOs = self._uiGOs
  uiGOs.timer = 0
  local heroProp = _G.GetHeroProp()
  self._myClsBubbles = ChatBubbleUtils.GetBubbleCfgsByOccupAndSex(heroProp.occupation, heroProp.gender) or {}
  local groupOpera = self.m_node:FindDirect("Group_Operatipn")
  uiGOs.itemGet = groupOpera:FindDirect("Item_Get")
  uiGOs.itemAttr = groupOpera:FindDirect("Item_Attribute")
  uiGOs.bubbleInfo = groupOpera:FindDirect("Item_Time")
  uiGOs.groupItem = groupOpera:FindDirect("Group_Item")
  uiGOs.btnDelay = groupOpera:FindDirect("Group_Btn1")
  uiGOs.btnDressOn = groupOpera:FindDirect("Group_Btn2")
  uiGOs.btnUnlock = groupOpera:FindDirect("Group_Item/Btn_Change")
  uiGOs.imgBubble = self.m_base.m_panel:FindDirect("Img_Bg0/Img_BgCharacter/Img_PaoPao")
  self:_registerEvents()
  self:_updateUI()
end
def.method()._sort = function(self)
  local bubblesMap = ChatBubbleMgr.GetMyBubbleMap()
  table.sort(self._myClsBubbles, function(a, b)
    if a.cfgId == const.defaultChatBubbleCfgId then
      return true
    elseif b.cfgId == const.defaultChatBubbleCfgId then
      return false
    end
    local aInfo = bubblesMap[a.cfgId]
    local bInfo = bubblesMap[b.cfgId]
    if aInfo ~= nil then
      if bInfo ~= nil then
        return a.index < b.index
      else
        return true
      end
    elseif bInfo ~= nil then
      return false
    else
      return a.index < b.index
    end
  end)
end
def.method()._registerEvents = function(self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.BubbleInfoChg, Cls.OnBubbleInfoChg, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.BubbleTimeOut, Cls.OnBubbleTimeOut, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, Cls.OnItemChange, self)
  Event.RegisterEventWithContext(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, Cls.OnHeroLvUp, self)
end
def.method()._unregisterEvents = function(self)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BubbleInfoChg, Cls.OnBubbleInfoChg)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BubbleTimeOut, Cls.OnBubbleTimeOut)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, Cls.OnItemChange)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, Cls.OnHeroLvUp)
end
def.override().OnHide = function(self)
  if self._uiGOs.timer ~= 0 then
    _G.GameUtil.RemoveGlobalTimer(self._uiGOs.timer)
    self._uiGOs.timer = 0
  end
  self:_unregisterEvents()
  self._uiGOs = nil
  self._uiStatus = nil
  self._myClsBubbles = nil
end
def.method()._updateUI = function(self)
  self:_sort()
  self._uiStatus.bWearDefault = true
  self:_updateUIBubbleList()
  self:_updateUIRight()
  local selBubbleCfg = self._myClsBubbles[self._uiStatus.selIdx]
  if self._uiStatus.bWearDefault then
    local ctrl = self._uiStatus.ctrlBubbleDefault
    if ctrl then
      local lblUsing = ctrl:FindDirect("Label_Chuan_" .. self._uiStatus.idx)
      lblUsing:SetActive(true)
    end
  end
  if selBubbleCfg.cfgId == const.defaultChatBubbleCfgId then
    self._uiGOs.btnDressOn:SetActive(true)
  end
end
def.method()._updateUIBubbleList = function(self)
  local ctrlScrollView = self.m_node:FindDirect("Group_PaoPao/List_PaoPao/ScrollView_PaoPao")
  local ctrlUIList = ctrlScrollView:FindDirect("PaoPaoList")
  local bubbleCfgs = self._myClsBubbles
  local numBubble = #bubbleCfgs
  if numBubble % 3 ~= 0 then
    numBubble = math.floor(numBubble / 3) * 3 + 3
  end
  if numBubble < const.minDisplayCount then
    numBubble = const.minDisplayCount
  end
  local ctrlBubbleList = GUIUtils.InitUIList(ctrlUIList, numBubble)
  self._uiGOs.ctrlBubbleList = ctrlBubbleList
  for i = 1, numBubble do
    self:_fillBubbleInfo(ctrlBubbleList[i], bubbleCfgs[i], i)
  end
  self._uiStatus.iBubbleCfgId = const.defaultChatBubbleCfgId
  if self._uiStatus.selIdx == 0 then
    self._uiStatus.selIdx = 1
  end
  self._uiGOs.ctrlBubbleList[self._uiStatus.selIdx]:GetComponent("UIToggle").value = true
  local comScrollView = ctrlScrollView:GetComponent("UIScrollView")
  local ctrl = ctrlBubbleList[self._uiStatus.selIdx]
  GameUtil.AddGlobalTimer(0.1, true, function()
    comScrollView:DragToMakeVisible(ctrl.transform, 1280)
  end)
end
local ChatBubbleInfo = require("netio.protocol.mzm.gsp.chatbubble.ChatBubbleInfo")
def.method("userdata", "table", "number")._fillBubbleInfo = function(self, ctrl, cfg, idx)
  local lblUsing = ctrl:FindDirect("Label_Chuan_" .. idx)
  local imgLock = ctrl:FindDirect("Img_Lock_" .. idx)
  local imgNew = ctrl:FindDirect("Img_New_" .. idx)
  local imgBubble = ctrl:FindDirect("Img_PaoPao_" .. idx)
  local lblTryUse = ctrl:FindDirect("Img_Select_" .. idx .. "/Label_Try_" .. idx)
  if cfg == nil then
    ctrl:GetComponent("UIToggle").enabled = false
    ctrl:GetComponent("BoxCollider").enabled = false
    imgLock:SetActive(false)
    lblUsing:SetActive(false)
    imgNew:SetActive(false)
    lblTryUse:SetActive(false)
    ctrl:FindDirect("Img_Select_" .. idx):SetActive(false)
    imgBubble:SetActive(false)
    return
  end
  local bDefaultBubble = cfg.cfgId == const.defaultChatBubbleCfgId
  if bDefaultBubble then
    self._uiStatus.ctrlBubbleDefault = ctrl
    self._uiStatus.idx = idx
  end
  local bubblesMap = ChatBubbleMgr.GetMyBubbleMap()
  local bubbleInfo = bubblesMap[cfg.cfgId]
  if self.m_base.selectBubbleId ~= 0 and self.m_base.selectBubbleId == cfg.cfgId then
    self._uiStatus.selIdx = idx
    self._uiStatus.iBubbleCfgId = cfg.cfgId
    self.m_base.selectBubbleId = 0
  elseif self._uiStatus.iBubbleCfgId ~= const.defaultChatBubbleCfgId and cfg.cfgId == self._uiStatus.iBubbleCfgId then
    self._uiStatus.selIdx = idx
  elseif self._uiStatus.iBubbleCfgId == const.defaultChatBubbleCfgId and bubbleInfo ~= nil and bubbleInfo.isOn == ChatBubbleInfo.ON then
    self._uiStatus.selIdx = idx
  end
  local uiGOs = self._uiGOs
  lblUsing:SetActive(false)
  imgLock:SetActive(bubbleInfo == nil and not bDefaultBubble)
  lblTryUse:SetActive(bubbleInfo == nil and not bDefaultBubble)
  imgNew:SetActive(false)
  ChatBubbleUtils.SetSprite(imgBubble, cfg.uiResource)
  if bubbleInfo == nil then
  else
    local bOn = bubbleInfo.isOn == ChatBubbleInfo.ON
    lblUsing:SetActive(bOn)
    if bOn then
      self._uiStatus.bWearDefault = false
    end
    imgNew:SetActive(bubbleInfo.tagNew ~= nil and bubbleInfo.tagNew)
  end
end
def.method()._updateUIRight = function(self)
  local selBubbleCfg = self._myClsBubbles[self._uiStatus.selIdx]
  local bubblesMap = ChatBubbleMgr.GetMyBubbleMap()
  local bubbleInfo = bubblesMap[selBubbleCfg.cfgId]
  local leftTime = selBubbleCfg.duration * 3600
  local uiGOs = self._uiGOs
  uiGOs.btnUnlock:SetActive(bubbleInfo == nil)
  uiGOs.btnDelay:SetActive(bubbleInfo ~= nil)
  uiGOs.btnDressOn:SetActive(bubbleInfo ~= nil)
  local lblName = uiGOs.bubbleInfo:FindDirect("Label_2")
  GUIUtils.SetText(lblName, selBubbleCfg.name)
  self._uiGOs.groupItem:SetActive(bubbleInfo == nil)
  local lblBtnDress = uiGOs.btnDelay:FindDirect("Btn_Dress/Label_Dress")
  local lblBtnDress1 = uiGOs.btnDressOn:FindDirect("Btn_Dress/Label_Dress")
  if bubbleInfo ~= nil then
    uiGOs.btnDelay:SetActive(leftTime > 0)
    uiGOs.btnDressOn:SetActive(leftTime <= 0)
    if bubbleInfo.isOn == ChatBubbleInfo.ON then
    else
      GUIUtils.SetText(lblBtnDress, txtConst[11])
      GUIUtils.SetText(lblBtnDress1, txtConst[11])
    end
  end
  self:_updateUIGet(selBubbleCfg.desc)
  local itemids = ChatBubbleUtils.GetItemIdsByCfgId(selBubbleCfg.cfgId)
  if bubbleInfo == nil then
    self:_updateUIBubbleItem(itemids and itemids[1] or 0)
  end
  self:_updateUIBubble(selBubbleCfg.uiResource)
  local bCountDown = false
  if bubbleInfo ~= nil then
    local now = _G.GetServerTime()
    if bubbleInfo.expireTimeStamp == 0 then
      leftTime = -1
    else
      leftTime = Int64.ToNumber(bubbleInfo.expireTimeStamp) - now
      bCountDown = true
    end
  end
  self:_updateUITime(leftTime, bCountDown)
end
def.method("string")._updateUIHead = function(self, spriteName)
end
def.method("string")._updateUIGet = function(self, how)
  local lblGet = self._uiGOs.itemGet:FindDirect("Label_1")
  GUIUtils.SetText(lblGet, how)
end
def.method("number")._updateUIBubbleItem = function(self, itemid)
  local lblName = self._uiGOs.groupItem:FindDirect("Label_Name")
  local lblNum = self._uiGOs.groupItem:FindDirect("Label_Num")
  local imgIcon = self._uiGOs.groupItem:FindDirect("Bg_Item/Img_Icon")
  if itemid == 0 then
    self._uiGOs.groupItem:SetActive(false)
    return
  else
    self._uiGOs.groupItem:SetActive(true)
  end
  local owndNum = ItemModule.Instance():GetItemCountById(itemid)
  local itemBase = ItemUtils.GetItemBase(itemid)
  GUIUtils.SetText(lblName, itemBase.name)
  GUIUtils.SetText(lblNum, txtConst[1]:format(owndNum, 1))
  GUIUtils.SetTexture(imgIcon, itemBase.icon)
end
def.method("string")._updateUIBubble = function(self, spriteName)
  ChatBubbleUtils.SetSprite(self._uiGOs.imgBubble, spriteName)
end
def.method("number", "boolean")._updateUITime = function(self, leftTime, bCountDown)
  local lblTime = self._uiGOs.itemAttr:FindDirect("Label_1")
  if self._uiGOs.timer ~= 0 then
    _G.GameUtil.RemoveGlobalTimer(self._uiGOs.timer)
    self._uiGOs.timer = 0
  end
  if leftTime <= -1 then
    GUIUtils.SetText(lblTime, txtConst[9]:format(txtConst[10]))
    return
  end
  if leftTime == 0 then
    GUIUtils.SetText(lblTime, txtConst[9]:format(txtConst[10]))
    return
  end
  local time = leftTime
  GUIUtils.SetText(lblTime, txtConst[9]:format(self:_formatLeftTime(time)))
  if bCountDown then
    self._uiGOs.timer = _G.GameUtil.AddGlobalTimer(1, false, function()
      if _G.IsNil(self.m_base.m_panel) then
        _G.GameUtil.RemoveGlobalTimer(self._uiGOs.timer)
        return
      end
      time = time - 1
      if time <= 0 then
        return
      end
      local strTime = self:_formatLeftTime(time)
      GUIUtils.SetText(lblTime, txtConst[9]:format(strTime))
    end)
  end
end
def.method("number", "=>", "string")._formatLeftTime = function(self, sec)
  if sec > 86400 then
    local day = math.floor(sec / 86400)
    local hour = math.floor(sec % 86400 / 3600)
    return txtConst[3]:format(day, txtConst[4], hour, txtConst[5])
  elseif sec >= 3600 then
    local hour = math.floor(sec / 3600)
    local min = math.floor(sec % 3600 / 60)
    return txtConst[3]:format(hour, txtConst[5], min, txtConst[6])
  elseif sec >= 60 then
    local min = math.floor(sec / 60)
    local sec = math.floor(sec % 60)
    return txtConst[3]:format(min, txtConst[6], sec, txtConst[7])
  else
    return txtConst[8]:format(sec)
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  if not ChatBubbleMgr.IsFeatureOpen() or _G.GetHeroProp().level < const.minRoleLevel then
    return false
  end
  return true
end
def.method("=>", "boolean").IsHaveNotifyMessage = function(self)
  return ChatBubbleMgr.IsShowRedDot()
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("id", id)
  if id == "Btn_Change" then
    self:_onClickUnlock()
  elseif id == "Btn_Rollover" then
    self:_onClickDelay()
  elseif id == "Btn_Dress" then
    self:_onClickPutOn()
  elseif string.find(id, "Img_BgPaoPao_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self._uiStatus.selIdx = idx
    local selBubbleCfg = self._myClsBubbles[self._uiStatus.selIdx]
    self:_updateUIRight()
    local bubbleInfo = ChatBubbleMgr.GetMyBubbleMap()[selBubbleCfg.cfgId]
    if bubbleInfo and bubbleInfo.tagNew ~= nil and bubbleInfo.tagNew then
      ChatBubbleMgr.SetTagNew(selBubbleCfg.cfgId, false)
      local imgNew = self._uiGOs.ctrlBubbleList[idx]:FindDirect("Img_New_" .. idx)
      imgNew:SetActive(false)
    end
    if not self._uiStatus.bWearDefault and selBubbleCfg.cfgId == const.defaultChatBubbleCfgId then
      local lblBtnDress1 = self._uiGOs.btnDressOn:FindDirect("Btn_Dress/Label_Dress")
      GUIUtils.SetText(lblBtnDress1, txtConst[11])
      self._uiGOs.btnDressOn:SetActive(true)
    end
  elseif id == "Btn_Preview" then
    local selBubbleCfg = self._myClsBubbles[self._uiStatus.selIdx]
    require("Main.Chat.ChatBubble.ui.UIChatBubblePreview").Instance():ShowPanel(selBubbleCfg)
  elseif id == "Bg_Item" then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    local selBubbleCfg = self._myClsBubbles[self._uiStatus.selIdx]
    local itemId = ChatBubbleUtils.GetItemIdsByCfgId(selBubbleCfg.cfgId)[1]
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, clickObj, -1, true)
  end
end
def.method()._onClickUnlock = function(self)
  local selBubbleCfg = self._myClsBubbles[self._uiStatus.selIdx]
  local itemId = ChatBubbleUtils.GetItemIdsByCfgId(selBubbleCfg.cfgId)[1]
  local itemBase = ItemUtils.GetItemBase(itemId)
  local bagId = ItemUtils.GetBagIdByItemType(itemBase.itemType)
  if bagId == 0 then
    bagId = ItemModule.BAG
  end
  local items = ItemModule.Instance():GetItemsByItemID(bagId, itemId)
  local bubbleInfo = ChatBubbleMgr.GetMyBubbleMap()[selBubbleCfg.cfgId]
  for itemKey, item in pairs(items) do
    if bubbleInfo == nil then
      local content = txtConst[19]:format(itemBase.name, selBubbleCfg.name)
      CommonConfirmDlg.ShowConfirm(txtConst[18], content, function(select)
        if select == 1 then
          self._uiStatus.iBubbleCfgId = selBubbleCfg.cfgId
          ChatBubbleMgr.CSendUseItemReq(bagId, itemKey)
        end
      end, nil)
    else
      local strTime = self:_formatLeftTime(selBubbleCfg.duration * 3600)
      local content = txtConst[20]:format(itemBase.name, selBubbleCfg.name, strTime)
      CommonConfirmDlg.ShowConfirm(txtConst[18], content, function(select)
        if select == 1 then
          ChatBubbleMgr.CSendUseItemReq(bagId, itemKey)
        end
      end, nil)
    end
    return
  end
  Toast(txtConst[16])
end
def.method()._onClickDelay = function(self)
  self:_onClickUnlock()
end
def.method()._onClickPutOn = function(self)
  local selBubbleCfg = self._myClsBubbles[self._uiStatus.selIdx]
  local bubbleInfo = ChatBubbleMgr.GetMyBubbleMap()[selBubbleCfg.cfgId]
  if bubbleInfo ~= nil then
    if bubbleInfo.isOn == ChatBubbleInfo.ON then
      Toast(txtConst[17]:format(selBubbleCfg.name))
    else
      ChatBubbleMgr.CPutOnBubbleReq(selBubbleCfg.cfgId)
    end
  elseif selBubbleCfg.cfgId == const.defaultChatBubbleCfgId then
    if ChatBubbleMgr.GetWearBubbleId() == selBubbleCfg.cfgId then
      Toast(txtConst[17]:format(txtConst[15]))
      return
    end
    ChatBubbleMgr.CPutOnBubbleReq(selBubbleCfg.cfgId)
  end
end
def.method("table").OnBubbleInfoChg = function(self, p)
  if self.m_base:IsShow() then
    self:_updateUI()
  end
end
def.method("table").OnBubbleTimeOut = function(self, p)
  if self.m_base:IsShow() then
    self:_updateUI()
  end
end
def.method("table").OnItemChange = function(self, p)
  if self.m_base:IsShow() then
    self:_updateUIRight()
  end
end
def.method("table").OnHeroLvUp = function(self, p)
end
return BubbleNode.Commit()
