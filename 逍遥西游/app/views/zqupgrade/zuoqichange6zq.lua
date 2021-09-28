function ShowChange6ZuoqiView()
  local my6Zuoqi = Get6ZuoqiObj()
  if my6Zuoqi == nil then
    ShowNotifyTips("你还没有获得自身第六个坐骑，无法使用该功能")
    return
  else
    getCurSceneView():addSubView({
      subView = CZuoqiChangeSixZqView.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
CZuoqiChangeSixZqView = class("CZuoqiChangeSixZqView", CcsSubView)
function CZuoqiChangeSixZqView:ctor(para)
  para = para or {}
  CZuoqiChangeSixZqView.super.ctor(self, "views/zuoqi_changezuoqi.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_dh = {
      listener = handler(self, self.OnBtn_Change),
      variName = "btn_dh"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_SelectNewZqType = nil
  self:setZuoqiList()
  self:setTips()
  self:setSilver()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CZuoqiChangeSixZqView:setZuoqiList()
  self.m_Select6ZuoqiHeadList = {}
  for _, index in pairs({
    1,
    2,
    3
  }) do
    local zqpos = self:getNode(string.format("zqpos_%d", index))
    zqpos:setVisible(false)
  end
  local my6Zuoqi = Get6ZuoqiObj()
  local oldZQType
  if my6Zuoqi ~= nil then
    oldZQType = my6Zuoqi:getTypeId()
  end
  local index = 1
  local initZuoqiType
  for _, tempType in pairs(All_6_ZUOQI_List) do
    if tempType ~= oldZQType then
      local zqpos = self:getNode(string.format("zqpos_%d", index))
      local parent = zqpos:getParent()
      local zOrder = zqpos:getZOrder()
      local x, y = zqpos:getPosition()
      local size = zqpos:getSize()
      local zqItem = CZuoqiSkillHeadItem.new(tempType, tempType, handler(self, self.selectNewZuoqiType), size)
      zqItem:setPosition(ccp(x + size.width / 2, y + size.height / 2 + 10))
      parent:addChild(zqItem)
      self.m_Select6ZuoqiHeadList[tempType] = zqItem
      if initZuoqiType == nil then
        initZuoqiType = tempType
      end
      if index == 3 then
        break
      end
      index = index + 1
    end
  end
  self:selectNewZuoqiType(initZuoqiType)
end
function CZuoqiChangeSixZqView:selectNewZuoqiType(zqType)
  self.m_SelectNewZqType = zqType
  for tempType, zqItem in pairs(self.m_Select6ZuoqiHeadList) do
    zqItem:SetSelected(tempType == zqType, scaleAction)
  end
  local my6Zuoqi = Get6ZuoqiObj()
  local tqItemNum = 0
  local isDianHua = 0
  local zqLV = 0
  if my6Zuoqi ~= nil then
    isDianHua = my6Zuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
    oldZQType = my6Zuoqi:getTypeId()
    local lxbase, llbase, ggbase = data_getZuoqiBasePros(oldZQType)
    local initGG = my6Zuoqi:getProperty(PROPERTY_ZUOQI_INIT_GenGu)
    local initLX = my6Zuoqi:getProperty(PROPERTY_ZUOQI_INIT_Lingxing)
    local initLL = my6Zuoqi:getProperty(PROPERTY_ZUOQI_INIT_LiLiang)
    if tqItemNum < initGG - ggbase then
      tqItemNum = initGG - ggbase
    end
    if tqItemNum < initLX - lxbase then
      tqItemNum = initLX - lxbase
    end
    if tqItemNum < initLL - llbase then
      tqItemNum = initLL - llbase
    end
    zqLV = my6Zuoqi:getProperty(PROPERTY_ROLELEVEL)
  end
  local name = data_getZuoqiName(self.m_SelectNewZqType)
  local lxbase, llbase, ggbase = data_getZuoqiBasePros(self.m_SelectNewZqType)
  local lxbaseMax = CalculateZuoqiBaseLXLimit(self.m_SelectNewZqType, isDianHua)
  local llbaseMax = CalculateZuoqiBaseLLLimit(self.m_SelectNewZqType, isDianHua)
  local ggbaseMax = CalculateZuoqiBaseGGLimit(self.m_SelectNewZqType, isDianHua)
  self:getNode("text_name"):setText(name)
  lxbase = math.min(lxbaseMax, lxbase + tqItemNum)
  llbase = math.min(llbaseMax, llbase + tqItemNum)
  ggbase = math.min(ggbaseMax, ggbase + tqItemNum)
  self:getNode("text_lingxing"):setText(tostring(math.floor((lxbase * 2 + lxbase / 2 * (zqLV / 5)) / 2)))
  self:getNode("text_liliang"):setText(tostring(math.floor((llbase * 2 + llbase / 2 * (zqLV / 5)) / 2)))
  self:getNode("text_gengu"):setText(tostring(math.floor((ggbase * 2 + ggbase / 2 * (zqLV / 5)) / 2)))
  self:getNode("text_lingxing_curr"):setText(string.format("%d/%d", lxbase, lxbaseMax))
  self:getNode("valuebar_lx"):setPercent(checkint(lxbase / lxbaseMax * 100))
  self:getNode("text_liliang_curr"):setText(string.format("%d/%d", llbase, llbaseMax))
  self:getNode("valuebar_ll"):setPercent(checkint(llbase / llbaseMax * 100))
  self:getNode("text_gengu_curr"):setText(string.format("%d/%d", ggbase, ggbaseMax))
  self:getNode("valuebar_gg"):setPercent(checkint(ggbase / ggbaseMax * 100))
end
function CZuoqiChangeSixZqView:setTips()
  local x, y = self:getNode("box_tips"):getPosition()
  local size = self:getNode("box_tips"):getContentSize()
  local parent = self:getNode("box_tips"):getParent()
  if self.m_Tips == nil then
    self.m_Tips = CRichText.new({
      width = size.width,
      fontSize = 18,
      color = ccc3(94, 211, 207),
      align = CRichText_AlignType_Left
    })
    parent:addChild(self.m_Tips)
  else
    self.m_Tips:clearAll()
  end
  local txtStr = "#<IRP>#坐骑更换后，会保留前坐骑的能力、技能和技能熟练度。"
  self.m_Tips:addRichText(txtStr)
  local h = self.m_Tips:getContentSize().height
  self.m_Tips:setPosition(ccp(x, y + size.height - h))
end
function CZuoqiChangeSixZqView:setSilver()
  if self.m_SilverIcon == nil then
    local x, y = self:getNode("box_silver"):getPosition()
    local z = self:getNode("box_silver"):getZOrder()
    local size = self:getNode("box_silver"):getSize()
    self:getNode("box_silver"):setTouchEnabled(false)
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_SILVER))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_SilverIcon = tempImg
  end
  local needSilver = data_Variables.Change6ZuoqiCostSilver or 100000
  local curSilver = g_LocalPlayer:getSilver()
  self:getNode("txt_silver"):setText(string.format("%d", needSilver))
  local color = ccc3(255, 255, 255)
  if needSilver > curSilver then
    color = ccc3(255, 0, 0)
  end
  self:getNode("txt_silver"):setColor(color)
end
function CZuoqiChangeSixZqView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CZuoqiChangeSixZqView:OnBtn_Change(btnObj, touchType)
  local my6Zuoqi = Get6ZuoqiObj()
  if my6Zuoqi == nil then
    ShowNotifyTips("你还没有获得自身第六个坐骑，无法使用该功能")
    return
  end
  if self.m_SelectNewZqType == nil then
    ShowNotifyTips("请选择新坐骑的类型")
    return
  end
  local oldZQType = my6Zuoqi:getTypeId()
  local oldName = data_getZuoqiName(oldZQType)
  local newZQType = self.m_SelectNewZqType
  local newName = data_getZuoqiName(newZQType)
  local race = data_Zuoqi[newZQType].zqNeedRace
  local newRaceName = RACENAME_DICT[race] or "人族"
  local tempPop = CPopWarning.new({
    title = "提示",
    text = string.format("你确定要将自身的六坐#<Y>%s#更换为#<Y>%s#六坐#<Y>%s#吗？(坐骑更换后等级、技能及技能熟练度保持不变)", oldName, newRaceName, newName),
    confirmFunc = function()
      self:Change6Zuoqi()
    end,
    confirmText = "确定",
    cancelText = "取消",
    align = CRichText_AlignType_Left
  })
  tempPop:ShowCloseBtn(false)
end
function CZuoqiChangeSixZqView:Change6Zuoqi()
  local my6Zuoqi = Get6ZuoqiObj()
  if my6Zuoqi == nil then
    ShowNotifyTips("你还没有获得自身第六个坐骑，无法使用该功能")
    return
  end
  if self.m_SelectNewZqType == nil then
    ShowNotifyTips("请选择新坐骑的类型")
    return
  end
  local oldZQId = my6Zuoqi:getObjId()
  local oldZQType = my6Zuoqi:getTypeId()
  local newZQType = self.m_SelectNewZqType
  netsend.netbaseptc.requestChange6Zuoqi(oldZQId, oldZQType, newZQType)
end
function CZuoqiChangeSixZqView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:setSilver()
  elseif msgSID == MsgID_DeleteZuoqi then
    self:CloseSelf()
  end
end
function CZuoqiChangeSixZqView:Clear()
end
