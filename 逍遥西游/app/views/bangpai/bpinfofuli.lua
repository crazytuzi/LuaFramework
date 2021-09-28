local DefineFuli_Achive = 1
CBpInfoPageFuli = class("CBpInfoPageFuli", CcsSubView)
function CBpInfoPageFuli:ctor()
  CBpInfoPageFuli.super.ctor(self, "views/bangpai_fuli.json")
  local btnBatchListener = {
    btn_get = {
      listener = handler(self, self.OnBtn_Get),
      variName = "btn_get"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.fuli_select = self:getNode("fuli_select")
  self.fulidesc = self:getNode("fulidesc")
  self.txt_construct = self:getNode("txt_construct")
  self.txt_content = self:getNode("txt_content")
  self.title_content = self:getNode("title_content")
  self.bg_content = self:getNode("bg_content")
  self.txt_content:setText("0")
  self.fuli_select:setVisible(false)
  self:ShowContent(false)
  self:SetBpConstruct()
  self.m_FuliItem = {}
  for fuliId = 1, 1 do
    local temp = self:getNode(string.format("fuli_%d", fuliId))
    self[string.format("fuli_%d", fuliId)] = temp
    temp:setVisible(false)
    if data_Org_Fuli[fuliId] ~= nil then
      local x, y = temp:getPosition()
      local tSize = temp:getContentSize()
      local z = temp:getZOrder()
      local fuliItem = CBpInfoPageFuliIcon.new(fuliId, handler(self, self.OnSelectFuli))
      self:addChild(fuliItem, z + 1)
      fuliItem:setPosition(ccp(x + tSize.width / 2, y + tSize.height / 2))
      self.m_FuliItem[fuliId] = fuliItem
    end
  end
  self:OnSelectFuli(1)
  self:ListenMessage(MsgID_BP)
  self:SetAttrTips()
end
function CBpInfoPageFuli:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("title_construct"), "local_contribute")
  self:attrclick_check_withWidgetObj(self:getNode("bg_construct"), "local_contribute", self:getNode("title_construct"))
  self:attrclick_check_withWidgetObj(self:getNode("title_content"), "achpoint")
  self:attrclick_check_withWidgetObj(self:getNode("bg_content"), "achpoint", self:getNode("title_content"))
end
function CBpInfoPageFuli:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_LocalInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    if info.c ~= nil then
      self:SetBpConstruct()
    end
    if info.c ~= nil or info.i_achflag ~= nil then
      self:SetContent()
    end
  end
end
function CBpInfoPageFuli:SetBpConstruct()
  self.txt_construct:setText(tostring(g_BpMgr:getLocalBpConstruct()))
end
function CBpInfoPageFuli:OnSelectFuli(fuliId)
  if self.m_LastSelectFuli and self.m_LastSelectFuli:getFuliId() == fuliId then
    return
  end
  if self.m_LastSelectFuli then
    local oldFuliId = self.m_LastSelectFuli:getFuliId()
    local oldFuliItem = self.m_FuliItem[oldFuliId]
    if oldFuliItem then
      oldFuliItem:setSelected(false)
    end
    self.m_LastSelectFuli:removeFromParent()
    self.m_LastSelectFuli = nil
  end
  local x, y = self.fuli_select:getPosition()
  local tSize = self.fuli_select:getContentSize()
  local z = self.fuli_select:getZOrder()
  local fuliItem = CBpInfoPageFuliIcon.new(fuliId, nil)
  self:addChild(fuliItem, z + 1)
  fuliItem:setPosition(ccp(x + tSize.width / 2, y + tSize.height / 2))
  self.m_LastSelectFuli = fuliItem
  local desc = data_getFuliDesc(fuliId)
  self.fulidesc:setText("     " .. desc)
  local currFuliItem = self.m_FuliItem[fuliId]
  if currFuliItem then
    currFuliItem:setSelected(true)
  end
  self:SetContent()
end
function CBpInfoPageFuli:SetContent()
  if self.m_LastSelectFuli == nil then
    self:ShowContent(false)
  elseif self.m_LastSelectFuli:getFuliId() == DefineFuli_Achive then
    if g_BpMgr:getAchFlag() == 1 then
      local construct = g_BpMgr:getLocalBpConstruct()
      local param = data_Variables.AchievePointBonusRadix
      local achPoint = math.floor(construct / param[1] * param[2])
      self.txt_content:setText(string.format("%d", achPoint))
    else
      self.txt_content:setText("0")
    end
    self:ShowContent(true)
  else
    self:ShowContent(false)
  end
end
function CBpInfoPageFuli:ShowContent(flag)
  self.txt_content:setVisible(flag)
  self.title_content:setVisible(flag)
  self.bg_content:setVisible(flag)
end
function CBpInfoPageFuli:OnBtn_Get()
  if self.m_LastSelectFuli == nil then
    return
  end
  if self.m_LastSelectFuli:getFuliId() == DefineFuli_Achive then
    if g_BpMgr:getAchFlag() == 1 then
      local num = tonumber(self.txt_content:getStringValue())
      if num > 0 then
        g_BpMgr:send_getBpAchievePoint()
      else
        ShowNotifyTips("没有可领取的成就点")
      end
    else
      ShowNotifyTips("今天已经领取过了")
    end
  else
    ShowNotifyTips("功能暂未开放")
  end
end
function CBpInfoPageFuli:Clear()
end
CBpInfoPageFuliIcon = class("CBpInfoPageFuliIcon", function()
  return Widget:create()
end)
function CBpInfoPageFuliIcon:ctor(fuliId, clickListener)
  self.m_FuliId = fuliId
  self.m_ClickListener = clickListener
  local iconPath = string.format("views/bpflicon/bpflicon_%d.png", fuliId)
  local icon = display.newSprite(iconPath)
  self:addNode(icon, 0)
  icon:setAnchorPoint(ccp(0.5, 0.5))
  local iconSize = icon:getContentSize()
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iconSize.width, iconSize.height))
  self:setNodeEventEnabled(true)
  if self.m_ClickListener ~= nil then
    clickArea_check.extend(self)
    self:click_check_withObj(self, handler(self, self.OnClick), handler(self, self.OnTouchIcon))
  end
end
function CBpInfoPageFuliIcon:getFuliId()
  return self.m_FuliId
end
function CBpInfoPageFuliIcon:setSelected(isel)
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
      self:addNode(temp1)
      temp1:setPosition(ccp(-w - del, -h - del - 16))
      temp1:setAnchorPoint(ccp(0, 1))
      temp1:setScaleY(-1)
      self:addNode(temp2)
      temp2:setPosition(ccp(-w - del, h + del))
      temp2:setAnchorPoint(ccp(0, 1))
      self:addNode(temp3)
      temp3:setPosition(ccp(w + del, -h - del - 16))
      temp3:setAnchorPoint(ccp(0, 1))
      temp3:setScaleX(-1)
      temp3:setScaleY(-1)
      self:addNode(temp4)
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
function CBpInfoPageFuliIcon:OnClick()
  if self.m_ClickListener then
    self.m_ClickListener(self.m_FuliId)
  end
end
function CBpInfoPageFuliIcon:OnTouchIcon(touchInside)
  if touchInside then
    self:setScale(1.05)
  else
    self:setScale(1)
  end
end
function CBpInfoPageFuliIcon:onCleanup()
  self.m_ClickListener = nil
end
