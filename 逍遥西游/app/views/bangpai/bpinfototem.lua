CBpInfoPageTotem = class("CBpInfoPageTotem", CcsSubView)
function CBpInfoPageTotem:ctor()
  CBpInfoPageTotem.super.ctor(self, "views/bangpai_totem_new.json")
  local btnBatchListener = {
    btn_contribute = {
      listener = handler(self, self.OnBtn_Contribute),
      variName = "btn_contribute"
    },
    btn_main = {
      listener = handler(self, self.OnBtn_Main),
      variName = "btn_main"
    },
    btn_sub = {
      listener = handler(self, self.OnBtn_Sub),
      variName = "btn_sub"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.totem_select = self:getNode("totem_select")
  self.totemdesc = self:getNode("totemdesc")
  self.txt_contribute = self:getNode("txt_contribute")
  self.txt_kang = self:getNode("txt_kang")
  self.totem_select:setVisible(false)
  self.txt_kang:setVisible(false)
  self.m_TotemAmount = 12
  self:SetTotalContribute()
  self.m_TotemItem = {}
  local initTotemId = 1
  local mainTotem = g_BpMgr:getMainTotem()
  local fuTotem = g_BpMgr:getFuTotem()
  for totemId = 1, self.m_TotemAmount do
    local temp = self:getNode(string.format("totem_%d", totemId))
    self[string.format("totem_%d", totemId)] = temp
    temp:setVisible(false)
    local x, y = temp:getPosition()
    local tSize = temp:getContentSize()
    local z = temp:getZOrder()
    local totemItem = CBpInfoPageTotemIcon.new(totemId, handler(self, self.OnSelectTotem))
    self:addChild(totemItem, z + 1)
    totemItem:setPosition(ccp(x + tSize.width / 2, y + tSize.height / 2))
    self.m_TotemItem[totemId] = totemItem
    if totemId == mainTotem then
      initTotemId = totemId
    elseif totemId == fuTotem and initTotemId == nil then
      initTotemId = totemId
    end
  end
  self:OnSelectTotem(initTotemId)
  local totemInfo = g_BpMgr:getToTemInfo()
  self:InitUnlockInfo(totemInfo)
  self:SetAttrTips()
  self:ListenMessage(MsgID_BP)
end
function CBpInfoPageTotem:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("title_contribute"), "bp_contribute")
  self:attrclick_check_withWidgetObj(self:getNode("bg_contribute"), "bp_contribute", self:getNode("title_contribute"))
  self:attrclick_check_withWidgetObj(self:getNode("title_kang"), "bp_kangxing")
  self:attrclick_check_withWidgetObj(self:getNode("bg_kang"), "bp_kangxing", self:getNode("title_kang"))
end
function CBpInfoPageTotem:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_LocalInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    if info.i_offer ~= nil then
      self:SetTotalContribute()
    end
    if info.i_maintotem ~= nil or info.i_futotem ~= nil or info.i_offer then
      self:setTotemKang()
    end
  elseif msgSID == MsgID_BP_TotemInfo then
    local arg = {
      ...
    }
    local totemInfo = arg[1]
    self:InitUnlockInfo(totemInfo)
  elseif msgSID == MsgID_BP_UnlockTotemTimes then
    local arg = {
      ...
    }
    local times = arg[1]
    self:onGetUnlockTimes(times)
  end
end
function CBpInfoPageTotem:InitUnlockInfo(totemInfo)
  if totemInfo == nil then
    for _, totemItem in pairs(self.m_TotemItem) do
      totemItem:setVisible(false)
      totemItem:setTouchEnabled(false)
    end
    if self.m_LastSelectTotem then
      self.m_LastSelectTotem:setVisible(false)
    end
    self.totemdesc:setVisible(false)
    self.txt_kang:setVisible(false)
    self:setTotemKang()
  else
    for totemId = 1, self.m_TotemAmount do
      local unlock = totemInfo[totemId] or 0
      local totemItem = self.m_TotemItem[totemId]
      if totemItem then
        totemItem:setUnlock(unlock == 1)
        totemItem:setVisible(true)
        totemItem:setTouchEnabled(true)
        if self.m_LastSelectTotem and self.m_LastSelectTotem:getTotemId() == totemId then
          self.m_LastSelectTotem:setUnlock(unlock == 1)
        end
      end
    end
    if self.m_LastSelectTotem then
      self.m_LastSelectTotem:setVisible(true)
      self.totemdesc:setVisible(true)
      self.txt_kang:setVisible(true)
    end
    self:setTotemKang()
  end
end
function CBpInfoPageTotem:SetTotalContribute()
  self.txt_contribute:setText(tostring(g_BpMgr:getLocalPlayerOffer()))
end
function CBpInfoPageTotem:OnSelectTotem(totemId)
  if self.m_LastSelectTotem and self.m_LastSelectTotem:getTotemId() == totemId then
    return
  end
  if self.m_LastSelectTotem then
    local oldTotemId = self.m_LastSelectTotem:getTotemId()
    local oldTotemItem = self.m_TotemItem[oldTotemId]
    if oldTotemItem then
      oldTotemItem:setSelected(false)
    end
    self.m_LastSelectTotem:removeFromParent()
    self.m_LastSelectTotem = nil
  end
  local x, y = self.totem_select:getPosition()
  local tSize = self.totem_select:getContentSize()
  local z = self.totem_select:getZOrder()
  local totemItem = CBpInfoPageTotemIcon.new(totemId, nil, handler(self, self.OnBtn_Unlock))
  self:addChild(totemItem, z + 1)
  totemItem:setPosition(ccp(x + tSize.width / 2, y + tSize.height / 2))
  self.m_LastSelectTotem = totemItem
  local desc = self:getTotemDesc(totemId)
  self.totemdesc:setText("     " .. desc)
  self.totemdesc:setVisible(true)
  local currTotemItem = self.m_TotemItem[totemId]
  if currTotemItem then
    currTotemItem:setSelected(true)
    local lock = currTotemItem:getIsUnlock()
    self.m_LastSelectTotem:setUnlock(lock)
  end
  self:setTotemKang()
end
function CBpInfoPageTotem:setTotemKang()
  if self.m_LastSelectTotem == nil or not self.m_LastSelectTotem:isVisible() then
    self.txt_kang:setVisible(false)
  else
    local totemId = self.m_LastSelectTotem:getTotemId()
    local pro, value = g_BpMgr:getTotemKang(totemId)
    if pro == PROPERTY_DEL_DU or pro == PROPERTY_KXIXUE then
      self.txt_kang:setText(string.format("%d", value))
    else
      self.txt_kang:setText(string.format("%s%%", Value2Str(value * 100, 1)))
    end
    self.txt_kang:setVisible(true)
  end
end
function CBpInfoPageTotem:getCurrTotemIsUnlock()
  if self.m_LastSelectTotem == nil or not self.m_LastSelectTotem:isVisible() then
    return false
  end
  local totemId = self.m_LastSelectTotem:getTotemId()
  local currTotemItem = self.m_TotemItem[totemId]
  if currTotemItem then
    return currTotemItem:getIsUnlock()
  else
    return false
  end
end
function CBpInfoPageTotem:getTotemDesc(totemId)
  local desc = ""
  local pro = BangPaiTotem_2_Kang_New[totemId]
  if pro == nil then
    return desc
  end
  local data = data_OrgTotem[totemId] or {}
  local mLimit = data.MainKLimit or 0
  local fLimit = data.FuKLimit or 0
  local proName = Def_Pro_Name[pro]
  if pro == PROPERTY_DEL_DU or pro == PROPERTY_KXIXUE then
    desc = string.format("设为你的主图腾，最高可以为你的主角增加%s%d；设为你的辅图腾，最高可以为你的主角增加%s%d", proName, mLimit, proName, fLimit)
  else
    desc = string.format("设为你的主图腾，最高可以为你的主角增加%s%d%%；设为你的辅图腾，最高可以为你的主角增加%s%d%%", proName, mLimit * 100, proName, fLimit * 100)
  end
  return desc
end
function CBpInfoPageTotem:OnBtn_Contribute()
  CBpContribute.new()
end
function CBpInfoPageTotem:OnBtn_Main()
  self:SetMyTotem(1)
end
function CBpInfoPageTotem:OnBtn_Sub()
  self:SetMyTotem(0)
end
function CBpInfoPageTotem:SetMyTotem(flag)
  if self.m_LastSelectTotem == nil or not self.m_LastSelectTotem:isVisible() then
    ShowNotifyTips("请先选择需要设置的图腾")
    return
  end
  if not self:getCurrTotemIsUnlock() then
    ShowNotifyTips("该图腾还没有解开")
    return
  end
  local mainTotem = g_BpMgr:getMainTotem()
  local fuTotem = g_BpMgr:getFuTotem()
  local totemId = self.m_LastSelectTotem:getTotemId()
  self:_doSetMyTotem(flag)
end
function CBpInfoPageTotem:_doSetMyTotem(flag)
  local totemId = self.m_LastSelectTotem:getTotemId()
  g_BpMgr:send_setMyMainOrFuTotem(flag, totemId)
end
function CBpInfoPageTotem:OnBtn_Unlock()
  if not g_BpMgr:getLocalPlayerIsLeader() then
    ShowNotifyTips("只有帮主才能解开守护图腾")
    return
  end
  if g_LocalPlayer._bptotem_taskId ~= 0 then
    ShowNotifyTips("你已有解开图腾的任务，不能重复接受")
    return false
  end
  if self.m_LastSelectTotem then
    self.m_ReadyToUnlockTotem = self.m_LastSelectTotem:getTotemId()
    g_BpMgr:send_getTodayBpUnlockTotemTimes()
  end
end
function CBpInfoPageTotem:onGetUnlockTimes(times)
  if times > 0 then
    ShowNotifyTips("今天已解开过一个图腾了，每天最多只能解封1个")
  elseif self.m_UnlockWarning == nil then
    self.m_UnlockWarning = CPopWarning.new({
      title = "提示",
      text = "唤醒战神需要帮主组满五人队伍(限本帮派成员)。",
      confirmFunc = handler(self, self._doUnlockTotem),
      clearFunc = function()
        self.m_UnlockWarning = nil
      end,
      cancelText = "取消",
      confirmText = "确定"
    })
  end
end
function CBpInfoPageTotem:_doUnlockTotem()
  if self.m_ReadyToUnlockTotem then
    BangPaiTotem.reqAcceptTotem(self.m_ReadyToUnlockTotem)
  end
end
function CBpInfoPageTotem:Clear()
  if self.m_UnlockWarning then
    self.m_UnlockWarning:removeFromParent()
    self.m_UnlockWarning = nil
  end
end
CBpInfoPageTotemIcon = class("CBpInfoPageTotemIcon", function()
  return Widget:create()
end)
function CBpInfoPageTotemIcon:ctor(totemId, clickListener, unlockListener)
  self.m_TotemId = totemId
  self.m_ClickListener = clickListener
  self.m_UnlockListener = unlockListener
  self.m_IsUnlock = false
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(164, 123))
  self:setTotemState()
  self:setNodeEventEnabled(true)
  if self.m_ClickListener ~= nil then
    clickArea_check.extend(self)
    self:click_check_withObj(self, handler(self, self.OnClick), handler(self, self.OnTouchIcon))
  end
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_BP)
end
function CBpInfoPageTotemIcon:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_LocalInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    if info.i_maintotem ~= nil or info.i_futotem ~= nil then
      self:setTotemState()
    end
  end
end
function CBpInfoPageTotemIcon:getTotemId()
  return self.m_TotemId
end
function CBpInfoPageTotemIcon:getIsUnlock()
  return self.m_IsUnlock
end
function CBpInfoPageTotemIcon:setTotemState()
  if self.m_TotemState ~= nil then
    self.m_TotemState:removeFromParent()
    self.m_TotemState = nil
  end
  local path
  local mainTotem = g_BpMgr:getMainTotem()
  local fuTotem = g_BpMgr:getFuTotem()
  if self.m_TotemId == mainTotem then
    path = "views/totemicon/totem_main.png"
  elseif self.m_TotemId == fuTotem then
    path = "views/totemicon/totem_fu.png"
  end
  if path then
    self.m_TotemState = display.newSprite(path)
    self:addNode(self.m_TotemState, 5)
    self.m_TotemState:setAnchorPoint(ccp(0, 1))
    local size = self:getContentSize()
    self.m_TotemState:setPosition(ccp(-size.width / 2, size.height / 2))
  end
end
function CBpInfoPageTotemIcon:setSelected(isel)
  if isel then
    if self._SelectObjList then
      for _, obj in pairs(self._SelectObjList) do
        obj:setVisible(true)
      end
    else
      local bgSize = self:getSize()
      local temp1 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp2 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp3 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp4 = display.newSprite("views/pic/pic_selectcorner.png")
      local del = 5
      local w = bgSize.width / 2
      local h = bgSize.height / 2
      self:addNode(temp1, 20)
      temp1:setPosition(ccp(-w - del, -h - del))
      temp1:setAnchorPoint(ccp(0, 1))
      temp1:setScaleY(-1)
      self:addNode(temp2, 20)
      temp2:setPosition(ccp(-w - del, h + del))
      temp2:setAnchorPoint(ccp(0, 1))
      self:addNode(temp3, 20)
      temp3:setPosition(ccp(w + del, -h - del))
      temp3:setAnchorPoint(ccp(0, 1))
      temp3:setScaleX(-1)
      temp3:setScaleY(-1)
      self:addNode(temp4, 20)
      temp4:setPosition(ccp(w + del, h + del))
      temp4:setAnchorPoint(ccp(0, 1))
      temp4:setScaleX(-1)
      self._SelectObjList = {
        temp1,
        temp2,
        temp3,
        temp4
      }
    end
  elseif self._SelectObjList then
    for _, obj in pairs(self._SelectObjList) do
      obj:setVisible(false)
    end
  end
end
function CBpInfoPageTotemIcon:setUnlock(unlock)
  self.m_IsUnlock = unlock
  if unlock then
    if self.m_LockIcon ~= nil then
      self.m_LockIcon:removeFromParent()
      self.m_LockIcon = nil
    end
    if self.m_UnlockBtn ~= nil then
      self.m_UnlockBtn:removeFromParent()
      self.m_UnlockBtn = nil
    end
    if self.m_Icon == nil then
      local iconPath = string.format("views/totemicon/newtotem_%d.png", self.m_TotemId)
      self.m_Icon = display.newSprite(iconPath)
      self:addNode(self.m_Icon, 0)
      self.m_Icon:setAnchorPoint(ccp(0.5, 0.5))
    end
  else
    if self.m_LockIcon == nil then
      self.m_LockIcon = display.newSprite("views/totemicon/newtotem_lock.png")
      self:addNode(self.m_LockIcon, 10)
      self.m_LockIcon:setAnchorPoint(ccp(0.5, 0.5))
      self.m_LockIcon:setPosition(ccp(0, 0))
      local totemNamePath = string.format("views/totemicon/newtotemname_%d.png", self.m_TotemId)
      local totemName = display.newSprite(totemNamePath)
      self.m_LockIcon:addChild(totemName)
      local size = self.m_LockIcon:getContentSize()
      totemName:setAnchorPoint(ccp(0.5, 0.5))
      totemName:setPosition(ccp(22, size.height / 2))
    end
    if self.m_UnlockBtn == nil and self.m_ClickListener == nil then
      self.m_UnlockBtn = createClickButton("views/totemicon/totem_unlock.png", nil, handler(self, self.clickUnlock))
      self:addChild(self.m_UnlockBtn, 11)
      local size = self.m_UnlockBtn:getContentSize()
      self.m_UnlockBtn:setPosition(ccp(-size.width / 2 + 21, -size.height / 2))
    end
    if self.m_Icon ~= nil then
      self.m_Icon:removeFromParent()
      self.m_Icon = nil
    end
  end
end
function CBpInfoPageTotemIcon:clickUnlock()
  if self.m_UnlockListener then
    self.m_UnlockListener()
  end
end
function CBpInfoPageTotemIcon:OnClick()
  if self.m_ClickListener then
    self.m_ClickListener(self.m_TotemId)
  end
end
function CBpInfoPageTotemIcon:OnTouchIcon(touchInside)
  if touchInside then
    self:setScale(1.05)
  else
    self:setScale(1)
  end
end
function CBpInfoPageTotemIcon:onCleanup()
  self.m_ClickListener = nil
  self.m_UnlockListener = nil
  self:RemoveAllMessageListener()
end
