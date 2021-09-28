function CanGetZuoQi()
  local mainHero = g_LocalPlayer:getMainHero()
  if g_LocalPlayer == nil then
    return false
  end
  if mainHero == nil then
    return false
  end
  local race = mainHero:getProperty(PROPERTY_RACE)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  for _, zqId in ipairs({
    ZUOQITYPE_BAIMA,
    ZUOQITYPE_LUOTUO,
    ZUOQITYPE_BAILANG,
    ZUOQITYPE_TUONIAO,
    ZUOQITYPE_DAXIANG
  }) do
    local zqData = data_Zuoqi[zqId]
    if zqData then
      local zqNeedRace = zqData.zqNeedRace
      if zqNeedRace == ZUOQIRACE_ALL or zqNeedRace == race then
        local needZS, needLv = data_getZuoqiUnlockZsAndLevel(zqId)
        if zs > needZS or zs == needZS and lv >= needLv then
          local noGetFlag = true
          local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
          for _, id in pairs(myZuoqiList) do
            local zqIns = g_LocalPlayer:getObjById(id)
            if zqIns and zqIns:getTypeId() == zqId then
              noGetFlag = false
            end
          end
          if noGetFlag then
            return true
          end
        end
      end
    end
  end
  if Get6ZuoqiObj() == nil then
    local needZS, needLv = data_getZuoqiUnlockZsAndLevel(All_6_ZUOQI_List[1])
    if zs > needZS or zs == needZS and lv >= needLv then
      return true
    end
  end
  return false
end
function Get6ZuoqiObj()
  local mainHero = g_LocalPlayer:getMainHero()
  if g_LocalPlayer == nil then
    return nil
  end
  if mainHero == nil then
    return nil
  end
  local race = mainHero:getProperty(PROPERTY_RACE)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  for _, zqId in ipairs(All_6_ZUOQI_List) do
    local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
    for _, id in pairs(myZuoqiList) do
      local zqIns = g_LocalPlayer:getObjById(id)
      if zqIns and zqIns:getTypeId() == zqId then
        return zqIns
      end
    end
  end
  return nil
end
local CZuoqiItem = class("CZuoqiItem", CZuoqiSkillHeadItem)
function CZuoqiItem:ctor(zqId, clickHandler, size)
  CZuoqiItem.super.ctor(self, nil, zqId, clickHandler, size)
  self:SetRedIcon()
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CZuoqiItem:getId()
  return self.m_ZqTypeId
end
function CZuoqiItem:setZuoqiItemRideState(zuoqiTypeId)
  if g_LocalPlayer == nil then
    return
  end
  local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
  for _, id in pairs(myZuoqiList) do
    local zqIns = g_LocalPlayer:getObjById(id)
    if zqIns:getTypeId() == zuoqiTypeId then
      local num = zqIns:getProperty(PROPERTY_ZuoqiRideState)
      local ishow = false
      if num == 1 then
        ishow = true
      end
      if ishow then
        if self.m_RideIcon == nil then
          local rideIcon = display.newSprite("views/pic/pic_qizuoqi.png")
          self:addNode(rideIcon, 20)
          rideIcon:setPosition(ccp(-25, 25))
          self.m_RideIcon = rideIcon
        end
      elseif self.m_RideIcon then
        self.m_RideIcon:removeFromParent()
        self.m_RideIcon = nil
      end
    end
  end
end
function CZuoqiItem:SetRedIcon()
  local addFlag = false
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local zqTypeId = self.m_ZqTypeId
  if zqTypeId == ZUOQITYPE_EMPTY6ZUOQI then
    zqTypeId = All_6_ZUOQI_List[1]
  end
  local noGetFlag = true
  local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
  for _, id in pairs(myZuoqiList) do
    local zqIns = g_LocalPlayer:getObjById(id)
    if zqIns and zqIns:getTypeId() == zqTypeId then
      noGetFlag = false
    end
  end
  if noGetFlag then
    local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
    local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
    local needZS, needLv = data_getZuoqiUnlockZsAndLevel(zqTypeId)
    if zs > needZS or zs == needZS and lv >= needLv then
      addFlag = true
    end
  end
  self:ShowRedTipIcon(addFlag)
  return addFlag
end
function CZuoqiItem:ShowRedTipIcon(ishow)
  if ishow then
    if self.m_RedIcon == nil then
      local redIcon = display.newSprite("views/pic/pic_tipnew.png")
      self:addNode(redIcon, 20)
      redIcon:setPosition(ccp(30, 30))
      self.m_RedIcon = redIcon
    end
  elseif self.m_RedIcon then
    self.m_RedIcon:removeFromParent()
    self.m_RedIcon = nil
  end
end
function CZuoqiItem:onCleanup()
  CZuoqiItem.super.onCleanup(self)
  self:RemoveAllMessageListener()
end
function CZuoqiItem:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_HeroUpdate then
    self:SetRedIcon()
  elseif msgSID == MsgID_NewZuoqi then
    self:SetRedIcon()
  elseif msgSID == MsgID_ZuoqiUpdate then
    local param = arg[1]
    local proTable = param.pro
    if g_LocalPlayer ~= nil then
      local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
      for _, id in pairs(myZuoqiList) do
        local zqIns = g_LocalPlayer:getObjById(id)
        if zqIns then
          local zqId = zqIns:getTypeId()
          if id == param.zuoqiId and zqId == self.m_ZqTypeId then
            if proTable[PROPERTY_ZuoqiRideState] ~= nil or proTable[PROPERTY_ZuoqiRideState] ~= nil then
              self:setZuoqiItemRideState(self.m_ZqTypeId)
              break
            end
            if proTable[PROPERTY_ROLELEVEL] ~= nil or proTable[PROPERTY_ZHUANSHENG] ~= nil then
              self:setLevelText()
            end
            break
          end
        end
      end
    end
  end
end
local CZuoqiManageItem = class("CZuoqiManageItem")
function CZuoqiManageItem:ctor(petId, warFlag, clickHandler)
  self.m_PetId = petId
  local itemObj = g_LocalPlayer:getObjById(petId)
  local itemView = createClickHead({
    roleTypeId = itemObj:getTypeId(),
    autoSize = nil,
    clickListener = function(...)
      clickHandler(petId)
    end,
    noBgFlag = false,
    offx = nil,
    offy = nil,
    clickDel = nil,
    LongPressTime = nil,
    LongPressListener = nil,
    LongPressEndListner = nil
  })
  self.m_ItemView = itemView
  if warFlag then
    local size = self.m_ItemView:getContentSize()
    local warIcon = display.newSprite("views/mainviews/pic_mission_wartips.png")
    warIcon:setAnchorPoint(ccp(1, 0))
    self.m_ItemView:addNode(warIcon, 1)
    warIcon:setPosition(size.width - 5, 5)
  end
  self.m_ItemView:setScale(0.8)
end
function CZuoqiManageItem:getItemView()
  return self.m_ItemView
end
g_ZuoqiDlg = nil
CZuoqiShow = class(".CZuoqiShow", CcsSubView)
function CZuoqiShow:ctor(initViewNum, closeCallBack)
  CZuoqiShow.super.ctor(self, "views/zuoqi.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_skill = {
      listener = handler(self, self.OnBtn_SkillView),
      variName = "btn_skill"
    },
    btn_uplv = {
      listener = handler(self, self.OnBtn_UpgradeLv),
      variName = "btn_uplv"
    },
    btn_manage = {
      listener = handler(self, self.OnBtn_ManageView),
      variName = "btn_manage"
    },
    btn_getzuoqi = {
      listener = handler(self, self.OnBtn_GetZuoqi),
      variName = "btn_getzuoqi"
    },
    btn_itemlist = {
      listener = handler(self, self.OnBtn_ItemView),
      variName = "btn_itemlist"
    },
    btn_skill_1 = {
      listener = handler(self, self.OnBtn_CheckSkill_1),
      variName = "btn_skill_1"
    },
    btn_skill_2 = {
      listener = handler(self, self.OnBtn_CheckSkill_2),
      variName = "btn_skill_2"
    },
    btn_upgrade = {
      listener = handler(self, self.OnBtn_UpgradeSkill),
      variName = "btn_upgrade"
    },
    btn_ride = {
      listener = handler(self, self.OnBtn_RideZuoQi),
      variName = "btn_ride"
    },
    pos_managepet_3 = {
      listener = handler(self, self.OnBtn_ManagePet3),
      variName = "pos_managepet_3"
    },
    btn_uplv1 = {
      listener = handler(self, self.OnBtn_UpgradeLv1),
      variName = "btn_uplv1"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CloseCallBackFunc = closeCallBack
  self:addBtnSigleSelectGroup({
    {
      self.btn_skill_1,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -3)
    },
    {
      self.btn_skill_2,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -3)
    }
  })
  self:addBtnSigleSelectGroup({
    {
      self.btn_skill,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_uplv,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_manage,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_itemlist,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    }
  })
  self.btn_skill:setTitleText("技\n能")
  self.btn_uplv:setTitleText("升\n级")
  self.btn_manage:setTitleText("管\n制")
  self.btn_itemlist:setTitleText("物\n品")
  self.title_txt = self:getNode("title_txt")
  self.title_txt:setText("技能")
  local size = self.btn_skill:getContentSize()
  self:adjustClickSize(self.btn_skill, size.width + 30, size.height, true)
  local size = self.btn_manage:getContentSize()
  self:adjustClickSize(self.btn_manage, size.width + 30, size.height, true)
  local size = self.btn_itemlist:getContentSize()
  self:adjustClickSize(self.btn_itemlist, size.width + 30, size.height, true)
  self.pagebase = self:getNode("pagebase")
  self.pageskill = self:getNode("pageskill")
  self.pageupgradeLv = self:getNode("pageupgradeLv")
  self.pagemanage = self:getNode("pagemanage")
  self.pageitemlist = self:getNode("pageitemlist")
  self.locklayer = self:getNode("locklayer")
  self.unlocklayer = self:getNode("unlocklayer")
  self.pagebase:setVisible(true)
  self.pageskill:setVisible(true)
  self.pageupgradeLv:setVisible(true)
  self.pagemanage:setVisible(true)
  self.pageitemlist:setVisible(true)
  self.locklayer:setVisible(true)
  self.unlocklayer:setVisible(true)
  self.pos_managepet_1 = self:getNode("pos_managepet_1")
  self.pos_managepet_2 = self:getNode("pos_managepet_2")
  self.pic_lock = self:getNode("pic_lock")
  self.text_bpcj = self:getNode("text_bpcj")
  self:setUpgradeLvBtn()
  self:InitSkillView()
  self:InitManageView()
  self:InitItemListView()
  self.m_CurChoosedZuoqiTypeId = -1
  self.m_UpgradeRestTime = 0
  self.m_CurrShowRight = "skill"
  self:LoadAllZuoqi()
  self:setArch()
  self.m_ScheduleHandler = scheduler.scheduleGlobal(handler(self, self.UpdateTime), 1)
  self:SetClickTips()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  if g_ZuoqiDlg ~= nil then
    g_ZuoqiDlg:CloseSelf()
  end
  g_ZuoqiDlg = self
  if initViewNum then
    if initViewNum == ZuoqiShow_SkillView then
      self:setGroupBtnSelected(self.btn_skill)
      self:OnBtn_SkillView()
    elseif initViewNum == ZuoqiShow_UpgradeView then
      self:setGroupBtnSelected(self.btn_uplv)
      self:OnBtn_UpgradeLv()
    elseif initViewNum == ZuoqiShow_GuanzhiView then
      self:setGroupBtnSelected(self.btn_manage)
      self:OnBtn_ManageView()
    elseif initViewNum == ZuoqiShow_ItemView then
      self:setGroupBtnSelected(self.btn_itemlist)
      self:OnBtn_ItemView()
    end
  end
end
function CZuoqiShow:SetClickTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("title_lingxing"), "zuoqi_pro", self:getNode("title_lingxing"))
  self:attrclick_check_withWidgetObj(self:getNode("text_lingxing"), "zuoqi_pro", self:getNode("title_lingxing"))
  self:attrclick_check_withWidgetObj(self:getNode("title_liliang"), "zuoqi_pro", self:getNode("title_lingxing"))
  self:attrclick_check_withWidgetObj(self:getNode("text_liliang"), "zuoqi_pro", self:getNode("title_lingxing"))
  self:attrclick_check_withWidgetObj(self:getNode("title_gengu"), "zuoqi_pro", self:getNode("title_lingxing"))
  self:attrclick_check_withWidgetObj(self:getNode("text_gengu"), "zuoqi_pro", self:getNode("title_lingxing"))
  self:attrclick_check_withWidgetObj(self:getNode("title_lingxing_init"), "zuoqi_lx")
  self:attrclick_check_withWidgetObj(self:getNode("title_liliang_init"), "zuoqi_ll")
  self:attrclick_check_withWidgetObj(self:getNode("title_gengu_init"), "zuoqi_gg")
  self:attrclick_check_withWidgetObj(self:getNode("valuebar_lxbg"), "zuoqi_lx", self:getNode("title_lingxing_init"))
  self:attrclick_check_withWidgetObj(self:getNode("valuebar_llbg"), "zuoqi_ll", self:getNode("title_liliang_init"))
  self:attrclick_check_withWidgetObj(self:getNode("valuebar_ggbg"), "zuoqi_gg", self:getNode("title_gengu_init"))
end
function CZuoqiShow:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ZuoqiUpdate then
    local param = arg[1]
    local proTable = param.pro
    if proTable[PROPERTY_ZUOQI_PETLIST] ~= nil then
      self:SetZuoInsList()
    end
    local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
    if myZuoqi and myZuoqi:getObjId() == param.zuoqiId then
      self:ReflushBaseInfo()
      if proTable[PROPERTY_ZUOQI_SKILLPVALUE] ~= nil then
        self:UpdateZuoqiSkillPValue()
      end
      if proTable[PROPERTY_ZUOQI_PETLIST] ~= nil then
        self:ReloadManageView()
      end
      if proTable[PROPERTY_ZUOQI_CDTIME] ~= nil then
        self:SetUpgradeTime()
      end
      if proTable[PROPERTY_ZUOQI_Lingxing] ~= nil or proTable[PROPERTY_ZUOQI_INIT_Lingxing] ~= nil then
        self:SetLingXing()
      end
      if proTable[PROPERTY_ZUOQI_LiLiang] or proTable[PROPERTY_ZUOQI_INIT_LiLiang] ~= nil then
        self:SetLiLiang()
      end
      if proTable[PROPERTY_ZUOQI_GenGu] ~= nil or proTable[PROPERTY_ZUOQI_INIT_GenGu] ~= nil then
        self:SetGenGu()
      end
      if proTable[PROPERTY_ZuoqiRideState] ~= nil or proTable[PROPERTY_ZuoqiRideState] ~= nil then
        self:SetRideState()
      end
    end
  elseif msgSID == MsgID_NewZuoqi then
    local param = arg[1]
    if self.m_ZuoQiItem[ZUOQITYPE_EMPTY6ZUOQI] ~= nil then
      local load6Zuoqi
      for _, tempType in pairs(All_6_ZUOQI_List) do
        if tempType == param.zuoqiType then
          load6Zuoqi = tempType
          break
        end
      end
      if load6Zuoqi ~= nil then
        self:Load6Zuoqi(load6Zuoqi)
      end
    end
    self:SetZuoInsList()
    if self.m_CurChoosedZuoqiTypeId == param.zuoqiType then
      self:ReflushBaseInfo()
    end
    if param.zuoqiType then
      self:SelectZuoqi(param.zuoqiType)
    end
  elseif msgSID == MsgID_ArchUpdate then
    self:setArch()
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local tempId = arg[1]
    if self.m_EquipDetail ~= nil then
      print("!!!!!!", self.m_EquipDetail:getItemObjId())
      if self.m_EquipDetail:getItemObjId() == tempId then
        self:CloseEquipDetail()
      end
    end
  end
end
function CZuoqiShow:setArch()
  local arch = g_LocalPlayer:getArch()
  self.text_bpcj:setText(string.format("%d", arch))
  self.text_bpcj:setColor(VIEW_DEF_DarkText_COLOR)
  self:getNode("uplv_cj"):setText(string.format("%d", arch))
  local needCJForUpgradeLv = 0
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  if myZuoqi ~= nil then
    local level = myZuoqi:getProperty(PROPERTY_ROLELEVEL)
    local exp = myZuoqi:getProperty(PROPERTY_EXP)
    local maxExp = CalculateZuoqiLevelupExp(level + 1)
    if maxExp - exp > 0 then
      local needArch = math.floor((maxExp - exp) * 3.5)
      if needArch ~= (maxExp - exp) * 3.5 then
        needArch = needArch + 1
      end
      needCJForUpgradeLv = math.floor(needArch)
    end
  end
  self:getNode("uplv_needcj"):setText(tostring(needCJForUpgradeLv))
  if arch >= needCJForUpgradeLv then
    self:getNode("uplv_needcj"):setColor(ccc3(255, 255, 255))
  else
    self:getNode("uplv_needcj"):setColor(ccc3(255, 0, 0))
  end
  if self.m_CJIcon == nil then
    local x, y = self:getNode("uplv_cjicon"):getPosition()
    local z = self:getNode("uplv_cjicon"):getZOrder()
    local size = self:getNode("uplv_cjicon"):getSize()
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_CHENGJIU))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self.pageupgradeLv:addNode(tempImg, z)
    self.m_CJIcon = tempImg
  end
  if self.m_CJIcon_2 == nil then
    local x, y = self:getNode("uplv_cjicon_2"):getPosition()
    local z = self:getNode("uplv_cjicon_2"):getZOrder()
    local size = self:getNode("uplv_cjicon_2"):getSize()
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_CHENGJIU))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self.pageupgradeLv:addNode(tempImg, z)
    self.m_CJIcon_2 = tempImg
  end
  if self.m_CJIcon_1 == nil then
    local x, y = self:getNode("uplv_cjicon_1"):getPosition()
    local z = self:getNode("uplv_cjicon_1"):getZOrder()
    local size = self:getNode("uplv_cjicon_1"):getSize()
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_CHENGJIU))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:getNode("layer_skill"):addNode(tempImg, z)
    self.m_CJIcon_1 = tempImg
  end
end
function CZuoqiShow:setUpgradeLvBtn()
  local x, y = self:getNode("uplv_pos_btn2"):getPosition()
  local size = self:getNode("uplv_pos_btn2"):getSize()
  self.btn_uplv2 = createClickButton("views/common/btn/btn_4words.png", "views/common/btn/btn_4words.png", handler(self, self.OnBtn_UpgradeLv2), 0.5)
  self.pageupgradeLv:addChild(self.btn_uplv2)
  self.btn_uplv2:setPosition(ccp(x, y))
  self.btn_uplv2:setTouchEnabled(true)
  self.m_BtnText = ui.newTTFLabel({
    text = "升级",
    font = KANG_TTF_FONT,
    size = 22,
    color = ccc3(0, 0, 0)
  })
  self.m_BtnText:setAnchorPoint(ccp(0.5, 0.5))
  self.m_BtnText:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self.pageupgradeLv:addNode(self.m_BtnText, 1)
end
function CZuoqiShow:LoadAllZuoqi()
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  for i = 1, 6 do
    local iconPos = self:getNode(string.format("zqpos_%d", i))
    iconPos:setVisible(false)
  end
  self.m_ZuoQiItem = {}
  local race = mainHero:getProperty(PROPERTY_RACE)
  local index = 1
  local initSelectd
  for _, zqId in ipairs({
    ZUOQITYPE_BAIMA,
    ZUOQITYPE_LUOTUO,
    ZUOQITYPE_BAILANG,
    ZUOQITYPE_TUONIAO,
    ZUOQITYPE_DAXIANG
  }) do
    local zqData = data_Zuoqi[zqId]
    local iconPos = self:getNode(string.format("zqpos_%d", index))
    if zqData and iconPos then
      local zqNeedRace = zqData.zqNeedRace
      if zqNeedRace == ZUOQIRACE_ALL or zqNeedRace == race then
        local size = iconPos:getContentSize()
        local parent = iconPos:getParent()
        local z = iconPos:getZOrder()
        local x, y = iconPos:getPosition()
        local zqItem = CZuoqiItem.new(zqId, handler(self, self.SelectZuoqi), size)
        parent:addChild(zqItem, z)
        zqItem:setPosition(ccp(x + size.width / 2, y + size.height / 2))
        self.m_ZuoQiItem[zqId] = zqItem
        index = index + 1
        if initSelectd == nil then
          initSelectd = zqId
        end
      end
    end
  end
  local the6Zuoqi = Get6ZuoqiObj()
  local load6ZuoqiType
  if the6Zuoqi == nil then
    load6ZuoqiType = ZUOQITYPE_EMPTY6ZUOQI
  else
    load6ZuoqiType = the6Zuoqi:getTypeId()
  end
  self:Load6Zuoqi(load6ZuoqiType)
  self:SetZuoInsList()
  if initSelectd ~= nil then
    self:SelectZuoqi(initSelectd, false)
  end
end
function CZuoqiShow:Load6Zuoqi(load6ZuoqiType)
  for _, zqType in pairs(All_6_ZUOQI_List) do
    local tempItem = self.m_ZuoQiItem[zqType]
    if tempItem then
      tempItem:removeFromParent()
    end
    self.m_ZuoQiItem[zqType] = nil
  end
  local tempItem = self.m_ZuoQiItem[ZUOQITYPE_EMPTY6ZUOQI]
  if tempItem then
    tempItem:removeFromParent()
  end
  self.m_ZuoQiItem[ZUOQITYPE_EMPTY6ZUOQI] = nil
  local iconPos = self:getNode("zqpos_6")
  local size = iconPos:getContentSize()
  local parent = iconPos:getParent()
  local z = iconPos:getZOrder()
  local x, y = iconPos:getPosition()
  local zqItem = CZuoqiItem.new(load6ZuoqiType, handler(self, self.SelectZuoqi), size)
  parent:addChild(zqItem, z)
  zqItem:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self.m_ZuoQiItem[load6ZuoqiType] = zqItem
end
function CZuoqiShow:SetZuoInsList()
  self.m_ZuoqiInsList = {}
  local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
  for _, id in pairs(myZuoqiList) do
    local zqIns = g_LocalPlayer:getObjById(id)
    if zqIns then
      local zqId = zqIns:getTypeId()
      self.m_ZuoqiInsList[zqId] = zqIns
    end
  end
end
function CZuoqiShow:SelectZuoqi(zqId, scaleAction)
  if self.m_CurChoosedZuoqiTypeId == zqId then
    return
  end
  self.m_CurChoosedZuoqiTypeId = zqId
  for zid, zqItem in pairs(self.m_ZuoQiItem) do
    zqItem:SetSelected(zqId == zid, scaleAction)
  end
  self.m_LastSkillViewIdx = 1
  self:ReflushBaseInfo()
end
function CZuoqiShow:ReflushBaseInfo()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  if myZuoqi == nil then
    self:ReloadZuoqiLockInfo()
  else
    self:ReloadZuoQiBaseInfo()
    self:ReloadSkillView()
    self:ReloadManageView()
    self:ReloadUpgradeLvView()
  end
end
function CZuoqiShow:ReloadUpgradeLvView()
  print("ReloadUpgradeLvView", self.m_CurChoosedZuoqiTypeId)
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  self:getNode("uplvtext1"):setColor(VIEW_DEF_DarkText_COLOR)
  self:getNode("uplvtext2"):setColor(VIEW_DEF_DarkText_COLOR)
  local level = myZuoqi:getProperty(PROPERTY_ROLELEVEL)
  if level >= CalculateZuoqiLevelLimit() then
    self.btn_uplv1:setVisible(false)
    self.btn_uplv1:setTouchEnabled(false)
    self.btn_uplv2:setVisible(false)
    self.btn_uplv2:setTouchEnabled(false)
    self:getNode("uplv_needcj"):setVisible(false)
    self:getNode("uplv_cj"):setVisible(false)
    self:getNode("uplvtext1"):setVisible(false)
    self:getNode("uplvtext2"):setText("坐骑等级已满，无需升级")
    if self.m_CJIcon then
      self.m_CJIcon:setVisible(false)
    end
    if self.m_CJIcon_2 then
      self.m_CJIcon_2:setVisible(false)
    end
    if self.m_BtnText then
      self.m_BtnText:setVisible(false)
    end
  else
    self.btn_uplv1:setVisible(true)
    self.btn_uplv1:setTouchEnabled(true)
    self.btn_uplv2:setVisible(true)
    self.btn_uplv2:setTouchEnabled(true)
    self:getNode("uplv_needcj"):setVisible(true)
    self:getNode("uplv_cj"):setVisible(true)
    self:getNode("uplvtext1"):setVisible(true)
    self:getNode("uplvtext2"):setText("升级所需帮派成就:")
    if self.m_CJIcon then
      self.m_CJIcon:setVisible(true)
    end
    if self.m_CJIcon_2 then
      self.m_CJIcon_2:setVisible(true)
    end
    if self.m_BtnText then
      self.m_BtnText:setVisible(true)
    end
  end
end
function CZuoqiShow:ReloadZuoqiLockInfo()
  self.unlocklayer:setEnabled(false)
  self.locklayer:setEnabled(true)
  self.pageitemlist:setEnabled(false)
  self.pageskill:setEnabled(false)
  self.pagemanage:setEnabled(false)
  self.pageupgradeLv:setEnabled(false)
  local tempZQType = self.m_CurChoosedZuoqiTypeId
  if self.m_CurChoosedZuoqiTypeId == ZUOQITYPE_EMPTY6ZUOQI then
    tempZQType = All_6_ZUOQI_List[1]
  end
  local locktip = self:getNode("locklayer_locktip")
  local name = data_getZuoqiName(tempZQType)
  local needZS, needLv = data_getZuoqiUnlockZsAndLevel(tempZQType)
  locktip:setText(string.format("%d转%d级后可以获得坐骑%s", needZS, needLv, name))
  if self.m_CurChoosedZuoqiTypeId == ZUOQITYPE_EMPTY6ZUOQI then
    locktip:setText(string.format("%d转%d级后可以选择第6个坐骑", needZS, needLv))
  end
  local addFlag = false
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero ~= nil then
    local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
    local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
    if needZS < zs or zs == needZS and needLv <= lv then
      addFlag = true
    end
  end
  self:getNode("img_btn_getzuoqi_tips"):setVisible(addFlag)
  self:getNode("locklayer_tippoint"):setVisible(true)
  self:getNode("locklayer_tiptitle"):setVisible(true)
  self:getNode("locklayer_locktip"):setVisible(true)
  if self.m_CurChoosedZuoqiTypeId ~= ZUOQITYPE_EMPTY6ZUOQI then
    self:getNode("select6layer"):setEnabled(false)
  elseif addFlag == false then
    self:getNode("select6layer"):setEnabled(false)
  else
    self:getNode("select6layer"):setEnabled(true)
    self:getNode("locklayer_tippoint"):setVisible(false)
    self:getNode("locklayer_tiptitle"):setVisible(false)
    self:getNode("locklayer_locktip"):setVisible(false)
    self:SetSelect6ZuoqiLayer()
  end
end
function CZuoqiShow:SetSelect6ZuoqiLayer(selectType, scaleAction)
  selectType = selectType or All_6_ZUOQI_List[1]
  if self.m_Select6ZuoqiHeadList == nil then
    self.m_Select6ZuoqiHeadList = {}
    local index = 1
    for _, tempType in ipairs(All_6_ZUOQI_List) do
      local zqpos = self:getNode(string.format("select6zq_pos%d", index))
      local parent = zqpos:getParent()
      local zOrder = zqpos:getZOrder()
      local x, y = zqpos:getPosition()
      local size = zqpos:getSize()
      local zqItem = CZuoqiSkillHeadItem.new(tempType, tempType, handler(self, self.SetSelect6ZuoqiLayer), size)
      zqItem:setPosition(ccp(x + size.width / 2, y + size.height / 2 + 10))
      parent:addChild(zqItem)
      local race = data_Zuoqi[tempType].zqNeedRace
      local txtStr = RACENAME_DICT[race] or RACENAME_DICT[RACE_REN]
      local txtObj = ui.newTTFLabel({
        text = txtStr,
        font = KANG_TTF_FONT,
        size = 20,
        color = ccc3(188, 125, 41)
      })
      parent:addNode(txtObj)
      txtObj:setPosition(ccp(x + size.width / 2, y + 5))
      self.m_Select6ZuoqiHeadList[tempType] = zqItem
      index = index + 1
    end
  end
  for tempType, zqItem in pairs(self.m_Select6ZuoqiHeadList) do
    zqItem:SetSelected(tempType == selectType, scaleAction)
  end
  self.m_Select6ZuoqiType = selectType
  local name = data_getZuoqiName(self.m_Select6ZuoqiType)
  local lxbase, llbase, ggbase = data_getZuoqiBasePros(self.m_Select6ZuoqiType)
  self:getNode("select6_text_name"):setText(name)
  self:getNode("select6_text_lingxing"):setText(tostring(lxbase))
  self:getNode("select6_text_liliang"):setText(tostring(llbase))
  self:getNode("select6_text_gengu"):setText(tostring(ggbase))
  self:getNode("select6_text_name"):setColor(VIEW_DEF_DarkText_COLOR)
  self:getNode("select6_text_lingxing"):setColor(VIEW_DEF_DarkText_COLOR)
  self:getNode("select6_text_liliang"):setColor(VIEW_DEF_DarkText_COLOR)
  self:getNode("select6_text_gengu"):setColor(VIEW_DEF_DarkText_COLOR)
  local lxbaseMax = CalculateZuoqiBaseLXLimit(self.m_Select6ZuoqiType, 0)
  local llbaseMax = CalculateZuoqiBaseLLLimit(self.m_Select6ZuoqiType, 0)
  local ggbaseMax = CalculateZuoqiBaseGGLimit(self.m_Select6ZuoqiType, 0)
  self:getNode("select6_text_lingxing_curr"):setText(string.format("%d/%d", lxbase, lxbaseMax))
  self:getNode("select6_valuebar_lx"):setPercent(checkint(lxbase / lxbaseMax * 100))
  self:getNode("select6_text_liliang_curr"):setText(string.format("%d/%d", llbase, llbaseMax))
  self:getNode("select6_valuebar_ll"):setPercent(checkint(llbase / llbaseMax * 100))
  self:getNode("select6_text_gengu_curr"):setText(string.format("%d/%d", ggbase, ggbaseMax))
  self:getNode("select6_valuebar_gg"):setPercent(checkint(ggbase / ggbaseMax * 100))
  local x, y = self:getNode("select6zqTxtTips"):getPosition()
  local size = self:getNode("select6zqTxtTips"):getContentSize()
  local parent = self:getNode("select6zqTxtTips"):getParent()
  if self.m_Select6ZuoqiTips == nil then
    self.m_Select6ZuoqiTips = CRichText.new({
      width = size.width,
      fontSize = 18,
      color = ccc3(94, 211, 207),
      align = CRichText_AlignType_Left
    })
    parent:addChild(self.m_Select6ZuoqiTips)
  else
    self.m_Select6ZuoqiTips:clearAll()
  end
  local race = data_Zuoqi[self.m_Select6ZuoqiType].zqNeedRace
  local txtStr = ""
  if race == RACE_REN then
    txtStr = "#<IRP>#人族坐骑综合能力强，适合学习增加召唤兽抗性的坐骑技能。"
  elseif race == RACE_MO then
    txtStr = "#<IRP>#魔族坐骑力量高，适合学习物理系技能，提升召唤兽物理输出。"
  elseif race == RACE_XIAN then
    txtStr = "#<IRP>#仙族坐骑偏向仙法攻击，能提升召唤兽仙法输出。"
  elseif race == RACE_GUI then
    txtStr = "#<IRP>#鬼族坐骑力量、根骨高，能帮助召唤兽提高抗虹吸能力。"
  end
  self.m_Select6ZuoqiTips:addRichText(txtStr)
  local h = self.m_Select6ZuoqiTips:getContentSize().height
  self.m_Select6ZuoqiTips:setPosition(ccp(x, y + size.height - h))
end
function CZuoqiShow:ReloadZuoQiBaseInfo()
  self.locklayer:setEnabled(false)
  self.unlocklayer:setEnabled(true)
  self.pageitemlist:setEnabled(self.m_CurrShowRight == "item")
  self.pageskill:setEnabled(self.m_CurrShowRight == "skill")
  self.pagemanage:setEnabled(self.m_CurrShowRight == "manage")
  self.pageupgradeLv:setEnabled(self.m_CurrShowRight == "upgradeLv")
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  local name = data_getZuoqiName(self.m_CurChoosedZuoqiTypeId)
  if channel.showGM == false then
    self:getNode("text_name"):setText(name)
  else
    local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
    local zqId = myZuoqi:getObjId()
    self:getNode("text_name"):setText(name .. " " .. tostring(zqId))
  end
  self:getNode("text_name"):setColor(VIEW_DEF_DarkText_COLOR)
  local level = myZuoqi:getProperty(PROPERTY_ROLELEVEL)
  self:getNode("text_level"):setText(string.format("%d级", level))
  self:getNode("text_level"):setColor(VIEW_DEF_DarkText_COLOR)
  local exp = myZuoqi:getProperty(PROPERTY_EXP)
  local maxExp = CalculateZuoqiLevelupExp(level + 1)
  self:getNode("text_exp"):setText(string.format("%d/%d", exp, maxExp))
  self:getNode("expbar"):setPercent(checkint(exp / maxExp * 100))
  if level >= CalculateZuoqiLevelLimit() then
    self:getNode("text_exp"):setText("(满)")
    self:getNode("expbar"):setPercent(100)
  end
  self:SetLingXing()
  self:SetLiLiang()
  self:SetGenGu()
  self:SetZuoqiSkillPValue()
  self:SetUpgradeTime()
  self:setArch()
  self:SetRideState()
end
function CZuoqiShow:SetLingXing()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  local isDh = myZuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
  local lx = myZuoqi:getProperty(PROPERTY_ZUOQI_Lingxing)
  self:getNode("text_lingxing"):setText(tostring(lx))
  local lxbase = myZuoqi:getProperty(PROPERTY_ZUOQI_INIT_Lingxing)
  local lxbaseMax = CalculateZuoqiBaseLXLimit(self.m_CurChoosedZuoqiTypeId, isDh)
  self:getNode("text_lingxing_curr"):setText(string.format("%d/%d", lxbase, lxbaseMax))
  self:getNode("valuebar_lx"):setPercent(checkint(lxbase / lxbaseMax * 100))
  self:getNode("text_lingxing"):setColor(VIEW_DEF_DarkText_COLOR)
end
function CZuoqiShow:SetLiLiang()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  local isDh = myZuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
  local ll = myZuoqi:getProperty(PROPERTY_ZUOQI_LiLiang)
  self:getNode("text_liliang"):setText(tostring(ll))
  local llbase = myZuoqi:getProperty(PROPERTY_ZUOQI_INIT_LiLiang)
  local llbaseMax = CalculateZuoqiBaseLLLimit(self.m_CurChoosedZuoqiTypeId, isDh)
  self:getNode("text_liliang_curr"):setText(string.format("%d/%d", llbase, llbaseMax))
  self:getNode("valuebar_ll"):setPercent(checkint(llbase / llbaseMax * 100))
  self:getNode("text_liliang"):setColor(VIEW_DEF_DarkText_COLOR)
end
function CZuoqiShow:SetGenGu()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  local isDh = myZuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
  local gg = myZuoqi:getProperty(PROPERTY_ZUOQI_GenGu)
  self:getNode("text_gengu"):setText(tostring(gg))
  local ggbase = myZuoqi:getProperty(PROPERTY_ZUOQI_INIT_GenGu)
  local ggbaseMax = CalculateZuoqiBaseGGLimit(self.m_CurChoosedZuoqiTypeId, isDh)
  self:getNode("text_gengu_curr"):setText(string.format("%d/%d", ggbase, ggbaseMax))
  self:getNode("valuebar_gg"):setPercent(checkint(ggbase / ggbaseMax * 100))
  self:getNode("text_gengu"):setColor(VIEW_DEF_DarkText_COLOR)
end
function CZuoqiShow:SetZuoqiSkillPValue()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  local pValue = myZuoqi:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
  local isDh = myZuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
  local pValueLimit = CalculateUpgradeZuoqiSkillPValueLimit(isDh)
  self:getNode("text_sld"):setText(tostring(pValue))
  if pValue >= pValueLimit then
    self.m_UpgradeRestTime = 0
    self.btn_upgrade:setTouchEnabled(false)
    self.btn_upgrade:setVisible(false)
  end
  return pValue
end
function CZuoqiShow:UpdateZuoqiSkillPValue()
  local oldValue = tonumber(self:getNode("text_sld"):getStringValue())
  local newValue = self:SetZuoqiSkillPValue()
  local deltaValue = newValue - oldValue
  if deltaValue > 0 then
    ShowNotifyTips(string.format("熟练度#<R>+%d#", deltaValue))
  end
end
function CZuoqiShow:SetUpgradeTime()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  local lastUpgradeTime = myZuoqi:getProperty(PROPERTY_ZUOQI_CDTIME)
  local pValue = myZuoqi:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
  local isDh = myZuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
  local pValueLimit = CalculateUpgradeZuoqiSkillPValueLimit(isDh)
  if pValue >= pValueLimit then
    self.m_UpgradeRestTime = 0
    self.btn_upgrade:setTouchEnabled(false)
    self.btn_upgrade:setVisible(false)
  else
    local svrTime = g_DataMgr:getServerTime()
    if lastUpgradeTime > svrTime then
      print("--->> 时间异常,", svrTime, lastUpgradeTime)
      svrTime = lastUpgradeTime
    end
    self.m_UpgradeRestTime = CalculateZuoqiUpgradeCDTime() - (svrTime - lastUpgradeTime)
    if self.m_UpgradeRestTime < 0 then
      self.m_UpgradeRestTime = 0
    end
    self:SetUpgradeBtnText()
  end
  self:CheckAllZuoQiCdTime()
end
function CZuoqiShow:InitSkillView()
end
function CZuoqiShow:ReloadSkillView()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  local zqId = myZuoqi:getObjId()
  local skillList = myZuoqi:getProperty(PROPERTY_ZUOQI_SKILLLIST)
  if skillList == 0 then
    skillList = {}
  end
  self.m_DescText = {}
  for index = 1, 2 do
    local skillBtn = self[string.format("btn_skill_%d", index)]
    local skillId = skillList[index]
    if skillId ~= nil then
      skillBtn:setTouchEnabled(true)
      skillBtn:setVisible(true)
      local skillData = data_ZuoqiSkill[skillId]
      if skillData ~= nil then
        skillBtn:setTitleText(skillData.name)
        temp = {}
        temp[1] = skillData.desc
        temp[2] = skillData.tip
        local desc = ""
        local info = g_LocalPlayer:getZQSkillData(zqId, skillId)
        for _, proName in ipairs(ZQSKILL_ADDPRO_DESC_ORDERDICT) do
          local value = info[proName]
          local tableKey = ZQ_ROLEPRO_2_SKILL[proName]
          local skillTable = data_ZuoqiSkill[skillId]
          if value ~= nil and skillTable and tableKey and skillTable[tableKey] and skillTable[tableKey] > 0 then
            local d = ZQSKILL_ADDPRO_DESC_DICT[proName] or ""
            if proName == PROPERTY_KXIXUE then
              desc = string.format("%s%s%d\n", desc, d, math.abs(value))
            else
              desc = string.format("%s%s%s%%\n", desc, d, Value2Str(math.abs(value) * 100, 1))
            end
          end
        end
        temp[3] = desc
        self.m_DescText[index] = temp
      end
    else
      skillBtn:setTouchEnabled(false)
      skillBtn:setVisible(false)
    end
  end
  if self.btn_skill_1:isTouchEnabled() or self.btn_skill_2:isTouchEnabled() then
    self:getNode("layer_noskill"):setVisible(false)
    self:getNode("layer_skill"):setVisible(true)
    self:ShowSkillView(self.m_LastSkillViewIdx)
  else
    self:getNode("layer_noskill"):setVisible(true)
    self:getNode("layer_skill"):setVisible(false)
  end
end
function CZuoqiShow:ShowSkillView(index)
  if index == nil then
    index = 1
  end
  self.m_LastSkillViewIdx = index
  for i = 1, 2 do
    local btn = self[string.format("btn_skill_%d", i)]
    if btn and btn:isVisible() then
      if i == index then
        btn:setTouchEnabled(false)
        if index == 1 then
          self:setGroupBtnSelected(self.btn_skill_1)
        else
          self:setGroupBtnSelected(self.btn_skill_2)
        end
      else
        btn:setTouchEnabled(true)
      end
    end
  end
  local descList = self.m_DescText[index]
  if descList == nil then
    self:getNode("skilldesc"):setVisible(false)
    self:getNode("skilltip"):setVisible(false)
    self:getNode("skillfunc"):setVisible(false)
  else
    self:getNode("skilldesc"):setVisible(true)
    self:getNode("skilltip"):setVisible(true)
    self:getNode("skillfunc"):setVisible(true)
    self:getNode("skilldesc"):setText(descList[1])
    self:getNode("skilltip"):setText(descList[2])
    self:getNode("skillfunc"):setText(descList[3])
  end
end
function CZuoqiShow:InitManageView()
  self.m_Petlist = self:getNode("petlist")
  local myPetList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  local ownerWarPos = {}
  local warsetting = g_LocalPlayer:getWarSetting()
  for pos, hid in pairs(warsetting) do
    ownerWarPos[hid] = pos
  end
  local ownerInfo = {}
  local petWarPos = {}
  local roleList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
  for _, roleId in pairs(roleList) do
    local petd = g_LocalPlayer:getObjProperty(roleId, PROPERTY_PETID)
    if petd ~= nil and petd ~= 0 then
      ownerInfo[petd] = roleId
      petWarPos[petd] = ownerWarPos[roleId]
    end
  end
  self.m_PetWarPos = petWarPos
  table.sort(myPetList, function(id_a, id_b)
    if id_a == nil or id_b == nil then
      return false
    end
    local owner_a = ownerInfo[id_a]
    local owner_b = ownerInfo[id_b]
    local warPos_a, warPos_b
    if owner_a ~= nil then
      warPos_a = ownerWarPos[owner_a]
    end
    if owner_b ~= nil then
      warPos_b = ownerWarPos[owner_b]
    end
    if warPos_a == nil and warPos_b ~= nil then
      return false
    elseif warPos_a ~= nil and warPos_b == nil then
      return true
    else
      local petObj_a = g_LocalPlayer:getObjById(id_a)
      local petObj_b = g_LocalPlayer:getObjById(id_b)
      local ltype_a = data_getPetLevelType(petObj_a:getTypeId())
      local ltype_b = data_getPetLevelType(petObj_b:getTypeId())
      if ltype_a ~= ltype_b then
        return ltype_a > ltype_b
      elseif owner_a == nil and owner_b ~= nil then
        return false
      elseif owner_a ~= nil and owner_b == nil then
        return true
      else
        local zs_a = petObj_a:getProperty(PROPERTY_ZHUANSHENG)
        local zs_b = petObj_b:getProperty(PROPERTY_ZHUANSHENG)
        local lv_a = petObj_a:getProperty(PROPERTY_ROLELEVEL)
        local lv_b = petObj_b:getProperty(PROPERTY_ROLELEVEL)
        if zs_a ~= zs_b then
          return zs_a > zs_b
        elseif lv_a ~= lv_b then
          return lv_a > lv_b
        else
          return id_a < id_b
        end
      end
    end
  end)
  local size = self.m_Petlist:getContentSize()
  self.m_ZuoqiManageList = CZuoqiManageList.new(myPetList, petWarPos, handler(self, self.OnPetObjClick), {
    width = size.width
  })
  self.m_Petlist:pushBackCustomItem(self.m_ZuoqiManageList)
  self.m_Petlist:sizeChangedForShowMoreTips()
  self.m_ManagePet = {}
end
function CZuoqiShow:ReloadManageView()
  local mList = {}
  local manageList = {}
  local manageListByOther = {}
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  for zqId, zqIns in pairs(self.m_ZuoqiInsList) do
    local petList = zqIns:getProperty(PROPERTY_ZUOQI_PETLIST)
    if petList == 0 then
      petList = {}
    end
    for _, petId in pairs(petList) do
      if zqId == self.m_CurChoosedZuoqiTypeId then
        manageList[petId] = true
        mList[#mList + 1] = petId
      else
        manageListByOther[petId] = true
      end
    end
  end
  self.m_ZuoqiManageList:ReloadManageInfo(manageList, manageListByOther)
  for _, objView in pairs(self.m_ManagePet) do
    objView._valid = false
  end
  for index = 1, 3 do
    local petId = mList[index]
    if petId ~= nil then
      local managePet = self[string.format("pos_managepet_%d", index)]
      local x, y = managePet:getPosition()
      local size = managePet:getContentSize()
      x = x - size.width / 2
      y = y - size.height / 2
      local objView = self.m_ManagePet[petId]
      if objView ~= nil then
        objView._valid = true
        if objView._index ~= index then
          objView._index = index
          objView:setPosition(ccp(x, y))
        end
      else
        local warFlag = self.m_PetWarPos[petId] ~= nil
        local obj = CZuoqiManageItem.new(petId, warFlag, handler(self, self.OnManagePetObjClick))
        objView = obj:getItemView()
        self.pagemanage:addChild(objView)
        objView:setPosition(ccp(x, y))
        objView._valid = true
        objView._index = index
        self.m_ManagePet[petId] = objView
      end
    end
  end
  local temp = {}
  for petId, objView in pairs(self.m_ManagePet) do
    if not objView._valid then
      temp[#temp + 1] = petId
      objView:removeFromParentAndCleanup(true)
    end
  end
  for _, petId in pairs(temp) do
    self.m_ManagePet[petId] = nil
  end
  if mList[3] == nil and myZuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA) == 0 then
    self.pic_lock:setVisible(true)
    self.pos_managepet_3:setTouchEnabled(true)
  else
    self.pic_lock:setVisible(false)
    self.pos_managepet_3:setTouchEnabled(false)
  end
end
function CZuoqiShow:OnManagePetObjClick(petId)
  self:OnPetObjClick(petId, false)
end
function CZuoqiShow:OnPetObjClick(petId, toManage)
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  local petList = myZuoqi:getProperty(PROPERTY_ZUOQI_PETLIST)
  if petList == 0 then
    petList = {}
  end
  if toManage then
    for _, pid in pairs(petList) do
      if pid == petId then
        print("数据异常？！ 重新加载-1")
        self:ReloadManageView()
        return
      end
    end
    local petList = myZuoqi:getProperty(PROPERTY_ZUOQI_PETLIST)
    local isDh = myZuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
    local manageLimit = CalculateZuoqiManageLimit(isDh)
    if manageLimit > #petList then
      local zqId = myZuoqi:getObjId()
      netsend.netbaseptc.requestZuoqiManagePet(zqId, petId)
      ShowWarningInWar()
    else
      ShowNotifyTips(string.format("当前最多管制%d个召唤兽", manageLimit))
    end
  else
    for _, pid in pairs(petList) do
      if pid == petId then
        local zqId = myZuoqi:getObjId()
        netsend.netbaseptc.requestZuoqiRemovePet(zqId, petId)
        ShowWarningInWar()
        return
      end
    end
    print("数据异常？！ 重新加载-2")
    self:ReloadManageView()
  end
end
function CZuoqiShow:InitItemListView(fadeoutAction)
  self.layer_itemlist = self:getNode("layer_itemlist")
  self.layer_itemlist:setVisible(false)
  local p = self.layer_itemlist:getParent()
  local x, y = self.layer_itemlist:getPosition()
  local z = self.layer_itemlist:getZOrder()
  local param = {
    xySpace = ccp(2, 2),
    itemSize = CCSize(100, 94),
    pageLines = 4,
    oneLineNum = 3,
    fadeoutAction = fadeoutAction
  }
  local tempSelectFunc = function(itemObj)
    local itype = itemObj:getTypeId()
    if itype == ITEM_DEF_ZUOQI_JGTQW then
      return true
    else
      return false
    end
  end
  self.m_PackageFrame = CPackageFrame.new(ITEM_PACKAGE_TYPE_ZUOQI, handler(self, self.ShowPackageDetail), nil, param, tempSelectFunc)
  self.m_PackageFrame:setPosition(ccp(x, y))
  p:addChild(self.m_PackageFrame, z + 100)
end
function CZuoqiShow:ShowPackageDetail(itemObjId)
  local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  if packageItemIns == nil then
    return
  end
  self.m_EquipDetail = CEquipDetail.new(itemObjId, {
    leftBtn = {
      btnText = "出售",
      listener = handler(self, self.OnSellItem)
    },
    rightBtn = {
      btnText = "使用",
      listener = handler(self, self.OnUseItem)
    },
    closeListener = handler(self, self.OnEquipDetailClosed)
  })
  self:addSubView({
    subView = self.m_EquipDetail,
    zOrder = 9999
  })
  local x, y = self.pageitemlist:getPosition()
  local iSize = self.pageitemlist:getContentSize()
  local bSize = self.m_EquipDetail:getBoxSize()
  self.m_EquipDetail:setPosition(ccp(x - iSize.width / 2 - bSize.width, y - bSize.height / 2))
end
function CZuoqiShow:OnSellItem(itemId)
  SellItemPopView(itemId, handler(self, self.OnConfirmSell))
end
function CZuoqiShow:OnConfirmSell(itemId, itemNum)
  self:CloseEquipDetail()
  netsend.netitem.requestSellItem(itemId, itemNum)
end
function CZuoqiShow:OnUseItem(itemId)
  local itemIns = g_LocalPlayer:GetOneItem(itemId)
  local itemTypeId = itemIns:getTypeId()
  if itemTypeId == ITEM_DEF_ZUOQI_JGTQW then
    local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
    local isDh = myZuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
    local lxbase = myZuoqi:getProperty(PROPERTY_ZUOQI_INIT_Lingxing)
    local lxbaseMax = CalculateZuoqiBaseLXLimit(self.m_CurChoosedZuoqiTypeId, isDh)
    local llbase = myZuoqi:getProperty(PROPERTY_ZUOQI_INIT_LiLiang)
    local llbaseMax = CalculateZuoqiBaseLLLimit(self.m_CurChoosedZuoqiTypeId, isDh)
    local ggbase = myZuoqi:getProperty(PROPERTY_ZUOQI_INIT_GenGu)
    local ggbaseMax = CalculateZuoqiBaseGGLimit(self.m_CurChoosedZuoqiTypeId, isDh)
    if lxbase >= lxbaseMax and llbase >= llbaseMax and ggbase >= ggbaseMax then
      ShowNotifyTips("全部属性初值已达上限")
    else
      self:CloseEquipDetail()
      netsend.netitem.requestUseItem(itemId, myZuoqi:getObjId())
      ShowWarningInWar()
    end
  elseif itemTypeId == ITEM_DEF_ZUOQI_SILIAO then
    local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
    netsend.netitem.requestUseItem(itemId, myZuoqi:getObjId())
  end
end
function CZuoqiShow:OnSelectPage(pIdx)
  self.m_PackageFrame:ShowPackagePage(pIdx, true)
end
function CZuoqiShow:CloseEquipDetail()
  if self.m_EquipDetail then
    self.m_EquipDetail:CloseSelf()
  end
end
function CZuoqiShow:OnEquipDetailClosed()
  self.m_EquipDetail = nil
end
function CZuoqiShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CZuoqiShow:OnBtn_ItemView(btnObj, touchType)
  self.title_txt:setText("物品")
  self.m_CurrShowRight = "item"
  self.pageitemlist:setEnabled(true)
  self.pagemanage:setEnabled(false)
  self.pageskill:setEnabled(false)
  self.pageupgradeLv:setEnabled(false)
end
function CZuoqiShow:OnBtn_SkillView(btnObj, touchType)
  self.title_txt:setText("技能")
  self.m_CurrShowRight = "skill"
  self.pageskill:setEnabled(true)
  self.pagemanage:setEnabled(false)
  self.pageitemlist:setEnabled(false)
  self.pageupgradeLv:setEnabled(false)
end
function CZuoqiShow:OnBtn_ManageView(btnObj, touchType)
  self.title_txt:setText("管制")
  self.m_CurrShowRight = "manage"
  self.pagemanage:setEnabled(true)
  self.pageskill:setEnabled(false)
  self.pageitemlist:setEnabled(false)
  self.pageupgradeLv:setEnabled(false)
end
function CZuoqiShow:OnBtn_UpgradeLv(btnObj, touchType)
  self.title_txt:setText("升级")
  self.m_CurrShowRight = "upgradeLv"
  self.pagemanage:setEnabled(false)
  self.pageskill:setEnabled(false)
  self.pageitemlist:setEnabled(false)
  self.pageupgradeLv:setEnabled(true)
end
function CZuoqiShow:OnBtn_GetZuoqi(btnObj, touchType)
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  if self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId] then
    self:ReloadZuoQiBaseInfo()
    return
  end
  if self.m_CurChoosedZuoqiTypeId ~= ZUOQITYPE_EMPTY6ZUOQI then
    local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
    local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
    local needZS, needLv = data_getZuoqiUnlockZsAndLevel(self.m_CurChoosedZuoqiTypeId)
    if zs > needZS or zs == needZS and lv >= needLv then
      netsend.netbaseptc.requestZuoqi(self.m_CurChoosedZuoqiTypeId)
    else
      ShowNotifyTips(string.format("需要%d转%d级", needZS, needLv))
    end
  else
    local tempZQType = All_6_ZUOQI_List[1]
    local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
    local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
    local needZS, needLv = data_getZuoqiUnlockZsAndLevel(tempZQType)
    if zs > needZS or zs == needZS and lv >= needLv then
      if self.m_Select6ZuoqiType ~= nil then
        netsend.netbaseptc.requestZuoqi(self.m_Select6ZuoqiType)
      else
        ShowNotifyTips("请选择第6个坐骑")
      end
    else
      ShowNotifyTips(string.format("需要%d转%d级", needZS, needLv))
    end
  end
end
function CZuoqiShow:OnBtn_CheckSkill_1(btnObj, touchType)
  self:ShowSkillView(1)
end
function CZuoqiShow:OnBtn_CheckSkill_2(btnObj, touchType)
  self:ShowSkillView(2)
end
function CZuoqiShow:OnBtn_ManagePet3(btnObj, touchType)
  ShowNotifyTips("坐骑点化后开启")
end
function CZuoqiShow:OnBtn_UpgradeLv1(btnObj, touchType)
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  if myZuoqi == nil then
    return
  end
  local zqId = myZuoqi:getObjId()
  if zqId == nil then
    return
  end
  local arch = g_LocalPlayer:getArch()
  local level = myZuoqi:getProperty(PROPERTY_ROLELEVEL)
  local heroLv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  if level >= CalculateZuoqiLevelLimit() then
    ShowNotifyTips("坐骑已经为最高等级")
    return
  end
  if level >= heroLv then
    ShowNotifyTips("坐骑等级不能高于角色等级")
    return
  end
  local exp = myZuoqi:getProperty(PROPERTY_EXP)
  local needExp = 0
  for tempLv = 1, math.min(heroLv, CalculateZuoqiLevelLimit()) do
    if level < tempLv then
      needExp = needExp + CalculateZuoqiLevelupExp(tempLv)
    end
  end
  needExp = needExp - exp
  if needExp <= 0 then
    return
  end
  local needArch = math.floor(needExp * 3.5)
  if needArch ~= needExp * 3.5 then
    needArch = needArch + 1
  end
  if arch >= needArch then
    netsend.netbaseptc.requestAddZuoqiLvAllAch(zqId)
    ShowWarningInWar()
  else
    local warningText = string.format("帮派成就不足\n是否使用#<IR1>#%d换取？", (needArch - arch) * data_Variables.Exchange_Arch2Money)
    local tempPop = CPopWarning.new({
      title = "提示",
      text = warningText,
      confirmFunc = function()
        netsend.netbaseptc.requestAddZuoqiLvAllAch(zqId)
      end,
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Left
    })
    tempPop:ShowCloseBtn(false)
  end
end
function CZuoqiShow:OnBtn_UpgradeLv2(btnObj, touchType)
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastClickTime ~= nil and curTime - self.m_LastClickTime < 0.3 then
    return
  end
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  if myZuoqi == nil then
    self.btn_uplv2:stopLongPressClick()
    return
  end
  local zqId = myZuoqi:getObjId()
  if zqId == nil then
    self.btn_uplv2:stopLongPressClick()
    return
  end
  local arch = g_LocalPlayer:getArch()
  local level = myZuoqi:getProperty(PROPERTY_ROLELEVEL)
  local heroLv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  if level >= CalculateZuoqiLevelLimit() then
    ShowNotifyTips("坐骑已经为最高等级")
    return
  end
  if level >= heroLv then
    ShowNotifyTips("坐骑等级不能高于角色等级")
    return
  end
  local exp = myZuoqi:getProperty(PROPERTY_EXP)
  local maxExp = CalculateZuoqiLevelupExp(level + 1)
  if maxExp - exp <= 0 then
    return
  end
  local needArch = math.floor((maxExp - exp) * 3.5)
  if needArch ~= (maxExp - exp) * 3.5 then
    needArch = needArch + 1
  end
  if arch >= needArch then
    netsend.netbaseptc.requestAddZuoqiLvOnce(zqId)
    ShowWarningInWar()
  else
    local warningText = string.format("帮派成就不足\n是否使用#<IR1>#%d换取？", (needArch - arch) * data_Variables.Exchange_Arch2Money)
    local tempPop = CPopWarning.new({
      title = "提示",
      text = warningText,
      confirmFunc = handler(self, self.ConfirmUseMoneyAddZuoqiLv),
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Left
    })
    tempPop:ShowCloseBtn(false)
    self.btn_uplv2:stopLongPressClick()
  end
end
function CZuoqiShow:ConfirmUseMoneyAddZuoqiLv()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  if myZuoqi == nil then
    return
  end
  local zqId = myZuoqi:getObjId()
  if zqId == nil then
    return
  end
  netsend.netbaseptc.requestAddZuoqiLvOnce(zqId)
end
function CZuoqiShow:OnBtn_UpgradeSkill(btnObj, touchType)
  if self.m_UpgradeRestTime <= 0 then
    do
      local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
      local zqId = myZuoqi:getObjId()
      local pValue = myZuoqi:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
      local isDh = myZuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
      local pValueLimit = CalculateUpgradeZuoqiSkillPValueLimit(isDh)
      if pValue >= pValueLimit then
        ShowNotifyTips("手动提升已达上限")
        return
      end
      local myArch = g_LocalPlayer:getArch()
      local costArch = CalculateZuoqiSkillPValueCostArch()
      if myArch < costArch then
        local costCoin = (costArch - myArch) * data_Variables.Exchange_Arch2Money
        local tempPop = CPopWarning.new({
          title = "提示",
          text = string.format("帮派成就不足\n是否使用#<IR1>#%d换取？", math.ceil(costCoin)),
          confirmFunc = function()
            self:OnBuyArch(zqId)
          end,
          confirmText = "确定",
          cancelText = "取消",
          align = CRichText_AlignType_Left
        })
        tempPop:ShowCloseBtn(false)
      else
        netsend.netbaseptc.requestUpgradeZuoqiSkillPValue(zqId)
        ShowWarningInWar()
      end
    end
  else
    local costGold = CalculateResetZqUpgradeCDTimeCostGold()
    local tempPop = CPopWarning.new({
      title = "提示",
      text = string.format("#<G>%d分钟#后才可以继续提升熟练度。解除CD时间需要花费%d#<IR2>#。\n\n现在就马上解除CD吗？", math.ceil(self.m_UpgradeRestTime / 60), costGold),
      confirmFunc = function()
        self:RestUpgradeCDTime()
      end,
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Left
    })
    tempPop:ShowCloseBtn(false)
  end
end
function CZuoqiShow:OnBuyArch(zqId)
  netsend.netbaseptc.requestUpgradeZuoqiSkillPValue(zqId)
  ShowWarningInWar()
end
function CZuoqiShow:RestUpgradeCDTime()
  if self.m_UpgradeRestTime > 0 then
    local costGold = CalculateResetZqUpgradeCDTimeCostGold()
    local myGold = g_LocalPlayer:getGold()
    if costGold > myGold then
      ShowNotifyTips(string.format("元宝数量不足%d", costGold))
    else
      local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
      netsend.netbaseptc.resetUpgradeZuoqiSkillPValueCDTime(myZuoqi:getObjId())
    end
  end
end
function CZuoqiShow:SetUpgradeBtnText()
  self.btn_upgrade:setTouchEnabled(true)
  self.btn_upgrade:setVisible(true)
  if self.m_UpgradeRestTime > 0 then
    if self.m_UpgradeRestTime >= 3600 then
      self.btn_upgrade:setTitleText("--:--")
    else
      local m = math.floor(self.m_UpgradeRestTime / 60)
      local s = self.m_UpgradeRestTime % 60
      self.btn_upgrade:setTitleText(string.format("%.2d:%.2d", m, s))
    end
    if self.m_UpgradeIcon ~= nil then
      self.m_UpgradeIcon:setVisible(false)
    end
  else
    self.btn_upgrade:setTitleText("提升")
    local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
    if myZuoqi then
      local petList = myZuoqi:getProperty(PROPERTY_ZUOQI_PETLIST) or {}
      if #petList > 0 then
        if self.m_UpgradeIcon == nil then
          self.m_UpgradeIcon = display.newSprite("views/pic/pic_tipnew.png")
          self.btn_upgrade:addNode(self.m_UpgradeIcon, 1)
          local size = self.btn_upgrade:getContentSize()
          self.m_UpgradeIcon:setPosition(ccp(size.width / 2 - 6, size.height / 2 - 6))
        end
        self.m_UpgradeIcon:setVisible(true)
      elseif self.m_UpgradeIcon ~= nil then
        self.m_UpgradeIcon:setVisible(false)
      end
    elseif self.m_UpgradeIcon ~= nil then
      self.m_UpgradeIcon:setVisible(false)
    end
  end
end
function CZuoqiShow:UpdateTime(dt)
  self:CheckAllZuoQiCdTime()
  if self.m_UpgradeRestTime <= 0 then
    return
  end
  self.m_UpgradeRestTime = self.m_UpgradeRestTime - 1
  self:SetUpgradeBtnText()
end
function CZuoqiShow:CheckAllZuoQiCdTime()
  local svrTime = g_DataMgr:getServerTime()
  local cdTime = CalculateZuoqiUpgradeCDTime()
  for zqId, zqIns in pairs(self.m_ZuoqiInsList) do
    local zqHead = self.m_ZuoQiItem[zqId]
    if zqHead then
      local petList = zqIns:getProperty(PROPERTY_ZUOQI_PETLIST) or {}
      local lastUpgradeTime = zqIns:getProperty(PROPERTY_ZUOQI_CDTIME)
      local pValue = zqIns:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
      local isDh = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA)
      local pValueLimit = CalculateUpgradeZuoqiSkillPValueLimit(isDh)
      if pValue >= pValueLimit or #petList <= 0 then
        zqHead:ShowRedTipIcon(false)
      else
        if svrTime < lastUpgradeTime then
          svrTime = lastUpgradeTime
        end
        local restTime = cdTime - (svrTime - lastUpgradeTime)
        if restTime < 0 then
          zqHead:ShowRedTipIcon(true)
        else
          zqHead:ShowRedTipIcon(false)
        end
      end
    end
  end
end
function CZuoqiShow:OnBtn_RideZuoQi()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  if myZuoqi == nil then
    return
  end
  local zqId = myZuoqi:getObjId()
  if zqId == nil then
    return
  end
  netsend.netbaseptc.rideZuoqi(zqId)
end
function CZuoqiShow:SetRideState()
  local myZuoqi = self.m_ZuoqiInsList[self.m_CurChoosedZuoqiTypeId]
  local num = myZuoqi:getProperty(PROPERTY_ZuoqiRideState)
  if num == 1 then
    self.btn_ride:setTitleText("步行")
  else
    self.btn_ride:setTitleText("乘骑")
  end
end
function CZuoqiShow:Clear()
  if self.m_ScheduleHandler then
    scheduler.unscheduleGlobal(self.m_ScheduleHandler)
    self.m_ScheduleHandler = nil
  end
  if self.m_CloseCallBackFunc then
    self.m_CloseCallBackFunc()
  end
  if g_ZuoqiDlg == self then
    g_ZuoqiDlg = nil
  end
end
