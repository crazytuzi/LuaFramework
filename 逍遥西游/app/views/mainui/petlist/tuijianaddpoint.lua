CTuijianAddPoint = class("CTuijianAddPoint", CcsSubView)
function CTuijianAddPoint:ctor(isAutoFlag)
  CTuijianAddPoint.super.ctor(self, "views/tuijianaddpoint.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_comfirm = {
      listener = handler(self, self.OnBtn_Set),
      variName = "btn_comfirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_IsAutoFlag = isAutoFlag
  self:getNode("txt_title"):setText("推荐加点")
  self.m_Items = {}
  self.m_TjData = self:GetTuijianData()
  self:SetListData()
  self:enableCloseWhenTouchOutside(self:getNode("pic_cw"), true)
end
function CTuijianAddPoint:GetTuijianData()
  local index
  local mainHero = g_LocalPlayer:getMainHero()
  local lTypeId = mainHero:getTypeId()
  local roleData = data_getRoleData(lTypeId)
  local race = roleData.RACE or RACE_REN
  local gender = roleData.GENDER or HERO_MALE
  if gender == HERO_MALE then
    if race == RACE_REN then
      index = MALE_REN_ZS_INDEX
    elseif race == RACE_MO then
      index = MALE_MO_ZS_INDEX
    elseif race == RACE_XIAN then
      index = MALE_XIAN_ZS_INDEX
    elseif race == RACE_GUI then
      index = MALE_GUI_ZS_INDEX
    end
  elseif gender == HERO_FEMALE then
    if race == RACE_REN then
      index = FEMALE_REN_ZS_INDEX
    elseif race == RACE_MO then
      index = FEMALE_MO_ZS_INDEX
    elseif race == RACE_XIAN then
      index = FEMALE_XIAN_ZS_INDEX
    elseif race == RACE_GUI then
      index = FEMALE_GUI_ZS_INDEX
    end
  end
  local tjData = data_getTuijianAddPointData(index)
  return tjData
end
function CTuijianAddPoint:itemSelected(item)
  if self.m_LastSelectedItem then
    self.m_LastSelectedItem:setSelected(false)
  end
  self.m_LastSelectedItem = item
  if self.m_LastSelectedItem then
    self.m_LastSelectedItem:setSelected(true)
  end
end
function CTuijianAddPoint:SetListData()
  self.m_TjList = self:getNode("tjlist")
  local tempList = {}
  for typeId, data in pairs(self.m_TjData) do
    tempList[#tempList + 1] = typeId
  end
  table.sort(tempList)
  for _, typeId in ipairs(tempList) do
    local data = self.m_TjData[typeId]
    local item = CTuijian_Item.new(typeId, data, handler(self, self.itemSelected))
    self.m_TjList:pushBackCustomItem(item:getUINode())
    self.m_Items[#self.m_Items + 1] = item
  end
  self.m_TjList:sizeChangedForShowMoreTips()
end
function CTuijianAddPoint:OnBtn_Set()
  if g_LocalPlayer == nil then
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  if self.m_IsAutoFlag == false then
    local freePoints = mainHero:getProperty(PROPERTY_FREEPOINT)
    if freePoints < 4 then
      ShowNotifyTips("当前可分配点数低于4点，无法分配属性点")
      return
    end
  end
  if self.m_LastSelectedItem == nil then
    ShowNotifyTips("请选择加点类型")
    return
  end
  local selectId = self.m_LastSelectedItem:getIndexId()
  local selectData = self.m_TjData[selectId]
  local title = selectData.title
  local titleDetail = selectData.titleDetail
  local gg = selectData.gg
  local lx = selectData.lx
  local ll = selectData.ll
  local mj = selectData.mj
  local tempView = CPopWarning.new({
    title = "提示",
    text = string.format("你确定要将当前配点换成#<G>%s:%s#吗？", title, titleDetail),
    cancelFunc = nil,
    confirmFunc = function()
      self:SetPro(gg, lx, ll, mj)
    end,
    align = CRichText_AlignType_Left
  })
  tempView:ShowCloseBtn(false)
end
function CTuijianAddPoint:SetPro(gg, lx, ll, mj)
  if g_LocalPlayer == nil then
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local i_gg = gg or 0
  local i_lx = lx or 0
  local i_ll = ll or 0
  local i_mj = mj or 0
  local rid = g_LocalPlayer:getMainHeroId()
  if self.m_IsAutoFlag then
    netsend.netbaseptc.requestAutoAddRolePoint(rid, i_gg, i_lx, i_ll, i_mj)
    ShowWarningInWar()
  else
    local freePoints = mainHero:getProperty(PROPERTY_FREEPOINT)
    if freePoints < 4 then
      ShowNotifyTips("当前可分配点数低于4点，无法分配属性点")
      return
    else
      local oldGG = mainHero:getProperty(PROPERTY_GenGu)
      local oldLX = mainHero:getProperty(PROPERTY_Lingxing)
      local oldLL = mainHero:getProperty(PROPERTY_LiLiang)
      local oldMJ = mainHero:getProperty(PROPERTY_MinJie)
      local num = math.floor(freePoints / 4)
      netsend.netbaseptc.setheropro(rid, num * i_gg, num * i_lx, num * i_ll, num * i_mj)
      ShowWarningInWar()
    end
  end
  self:CloseSelf()
  if g_SettingDlg and g_SettingDlg.PanelPlayerInfo then
    g_SettingDlg.PanelPlayerInfo:OnBtn_SetPoint()
  end
end
function CTuijianAddPoint:OnBtn_Close()
  self:CloseSelf()
  if g_SettingDlg and g_SettingDlg.PanelPlayerInfo then
    g_SettingDlg.PanelPlayerInfo:OnBtn_SetPoint()
    if g_SettingDlg.PanelPlayerInfo.m_AddPointDlg then
      if self.m_IsAutoFlag and g_SettingDlg.PanelPlayerInfo.m_AddPointDlg.OnBtn_Auto then
        g_SettingDlg.PanelPlayerInfo.m_AddPointDlg:OnBtn_Auto()
      elseif self.m_IsAutoFlag and g_SettingDlg.PanelPlayerInfo.m_AddPointDlg.OnBtn_Manual then
        g_SettingDlg.PanelPlayerInfo.m_AddPointDlg:OnBtn_Manual()
      end
    end
  end
end
function CTuijianAddPoint:Clear()
end
CTuijian_Item = class("CTuijian_Item", CcsSubView)
function CTuijian_Item:ctor(id, data, func)
  CTuijian_Item.super.ctor(self, "views/tuijianaddpoint_item.json")
  local btnBatchListener = {
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_TypeID = id
  self.m_TypeData = data
  self.m_SelectedListener = func
  self.panel_sel = self:getNode("panel_sel")
  self.pic_bg = self:getNode("pic_bg")
  self:getNode("txt"):setText(data.title or "")
  self:getNode("txt_detail"):setText(data.titleDetail or "")
  self.pic_bg:setTouchEnabled(true)
  self.pic_bg:addTouchEventListener(handler(self, self.TouchBg))
  self:setSelected(false)
end
function CTuijian_Item:TouchBg(touchObj, t)
  if t == TOUCH_EVENT_BEGAN then
    self:setTouchStatus(true)
  elseif t == TOUCH_EVENT_ENDED then
    self:setTouchStatus(false)
    if self.m_SelectedListener then
      self.m_SelectedListener(self)
    end
  elseif t == TOUCH_EVENT_CANCELED then
    self:setTouchStatus(false)
  end
end
function CTuijian_Item:OnBtn_Help(obj, t)
  getCurSceneView():addSubView({
    subView = CTuijian_Detail.new(self.m_TypeData),
    zOrder = MainUISceneZOrder.popDetailView
  })
end
function CTuijian_Item:setSelected(isSel)
  self.panel_sel:setVisible(isSel)
end
function CTuijian_Item:getIndexId()
  return self.m_TypeID
end
function CTuijian_Item:setTouchStatus(isTouch)
  if self.pic_bg then
    self.pic_bg:stopAllActions()
    if isTouch then
      self.pic_bg:setScaleX(0.95)
      self.pic_bg:setScaleY(0.95)
    else
      self.pic_bg:setScaleX(1)
      self.pic_bg:setScaleY(1)
      self.pic_bg:runAction(transition.sequence({
        CCScaleTo:create(0.1, 1.05, 1.05),
        CCScaleTo:create(0.1, 1, 1)
      }))
    end
  end
end
function CTuijian_Item:Clear()
  self.m_SelectedListener = nil
end
CTuijian_Detail = class("CTuijian_Detail", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  widget:setSize(CCSize(display.width, display.height))
  return widget
end)
function CTuijian_Detail:ctor(typeData)
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self, self.Touch))
  local tips = typeData.tips
  local des = typeData.des
  self.m_TxtX = 255
  local blackH = 130
  local layerC = display.newColorLayer(ccc4(0, 0, 0, 200))
  layerC:setContentSize(CCSize(display.width, blackH))
  self:addNode(layerC, 5)
  layerC:setPosition(ccp(0, 0))
  local sharedFileUtils = CCFileUtils:sharedFileUtils()
  self.m_HeadImg = display.newSprite("xiyou/head/head20034_big.png")
  self:addNode(self.m_HeadImg, 10)
  local size = self.m_HeadImg:getContentSize()
  self.m_HeadImg:setPosition(ccp(self.m_TxtX / 2, size.height / 2))
  local titleW = display.width - self.m_TxtX - 30
  local desColor = ccc3(255, 255, 255)
  local desTxt = CRichText.new({
    width = titleW,
    verticalSpace = 1,
    font = KANG_TTF_FONT,
    fontSize = 22,
    color = desColor
  })
  self:addChild(desTxt, 10)
  desTxt:addRichText(string.format("#<r:255,g:196,b:98>加点方式:##<G>%s#\n#<r:255,g:196,b:98>加点说明:#%s", tips, des))
  local desTxtSize = desTxt:getRichTextSize()
  local s = desTxt:getRichTextSize()
  titleY = blackH - 30 - desTxtSize.height
  desTxt:setPosition(ccp(self.m_TxtX, titleY))
end
function CTuijian_Detail:Touch(touchObj, t)
  if t == TOUCH_EVENT_ENDED then
    self:removeSelf()
  end
end
