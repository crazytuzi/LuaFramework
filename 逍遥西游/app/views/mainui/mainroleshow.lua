g_MainRoleView = nil
ClickFromRole = 1
ClickFromBeibao = 2
ClickFromCangku = 3
local DoubleClickTime = 1
function ExPackageGetCanNotUseFunc(itemIns)
  if itemIns == nil then
    return false
  end
  local mainRole = g_LocalPlayer:getMainHero()
  if mainRole == nil then
    return false
  end
  local largeType = itemIns:getType()
  local itemTypeId = itemIns:getTypeId()
  if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_SENIOREQPT or largeType == ITEM_LARGE_TYPE_XIANQI then
    local hkind = itemIns:getProperty(ITEM_PRO_EQPT_HKIND)
    local heroGender = mainRole:getProperty(PROPERTY_GENDER)
    local heroRace = mainRole:getProperty(PROPERTY_RACE)
    if hkind == 0 or hkind == nil then
      hkind = {0}
    end
    local sex = itemIns:getProperty(ITEM_PRO_EQPT_SEX)
    if #hkind == 1 and (hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN) then
      if (sex == ITEM_DEF_EQPT_SEX_MALE or sex == ITEM_DEF_EQPT_SEX_FEMALE) and heroGender ~= sex then
        return true
      end
      if hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET then
      elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO and heroRace ~= RACE_MO then
        return true
      elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN and heroRace ~= RACE_XIAN then
        return true
      elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN and heroRace ~= RACE_REN then
        return true
      elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI and heroRace ~= RACE_GUI then
        return true
      end
    elseif #hkind > 0 then
      local canUse = false
      local roleType = mainRole:getTypeId()
      for _, tempTypeid in pairs(hkind) do
        if tempTypeid == roleType then
          canUse = true
          break
        end
      end
      if canUse == false then
        return true
      end
    end
  elseif data_getIsGaoJiZBJZ(itemTypeId) or data_getIsXianQiJZ(itemTypeId) or data_getIsQHF(itemTypeId) then
    local sex = mainRole:getProperty(PROPERTY_GENDER)
    local race = mainRole:getProperty(PROPERTY_RACE)
    local sexraceLimit = sex * 10 + race
    local itemData = data_Market[itemTypeId]
    if itemData ~= nil and itemData.Limit ~= 0 and sexraceLimit ~= itemData.Limit then
      return true
    end
  end
  return false
end
function SellItemPopView(itemId, sellFunc)
  local player = g_DataMgr:getPlayer()
  local itemIns = player:GetOneItem(itemId)
  if itemIns == nil then
    return
  end
  local itemName = itemIns:getProperty(ITEM_PRO_NAME)
  local itemTypeId = itemIns:getTypeId()
  local itemNum = 1
  local priceType = RESTYPE_COIN
  local text
  if JudgeIsInWar() then
    if itemIns:getType() == ITEM_LARGE_TYPE_DRUG then
      ShowNotifyTips("处于战斗中，不能出售药品")
      return
    elseif itemIns:getType() == ITEM_LARGE_TYPE_LIFEITEM and data_getLifeSkillType(itemTypeId) == IETM_DEF_LIFESKILL_DRUG then
      ShowNotifyTips("处于战斗中，不能出售药品")
      return
    end
  end
  if itemIns:getProperty(ITME_PRO_BUNDLE_FLAG) ~= 1 and data_Market[itemTypeId] ~= nil then
    if sellFunc then
      sellFunc(itemId, 1)
    end
  else
    itemNum = itemIns:getProperty(ITEM_PRO_NUM) or 1
    priceType = RESTYPE_COIN
    local coin = (itemIns:getProperty(ITEM_PRO_REPRICE) or 0) * itemNum
    local canMerge = itemIns:getProperty(ITEM_PRO_CANMERGE)
    if canMerge ~= 0 and canMerge ~= 1 then
      text = string.format("是否以%d#<IR%d>#,出售#<CI:%d>%sx%d#?", coin, priceType, itemIns:getTypeId(), itemName, itemNum)
    else
      text = string.format("是否以%d#<IR%d>#,出售#<CI:%d>%s#?", coin, priceType, itemIns:getTypeId(), itemName)
    end
    local tempPop = CPopWarning.new({
      title = "提示",
      text = text,
      confirmFunc = function()
        if sellFunc then
          sellFunc(itemId, 0)
        end
      end,
      align = CRichText_AlignType_Left,
      cancelFunc = nil,
      closeFunc = nil,
      confirmText = nil,
      cancelText = nil
    })
    tempPop:ShowCloseBtn(false)
  end
end
CMainRoleView = class("CMainRoleView", CcsSubView)
function CMainRoleView:ctor(para)
  CMainRoleView.super.ctor(self, "views/mainhero_list.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  clickArea_check.extend(self)
  self.m_EquipAddIcon_ZsLevel = {
    [ITEM_DEF_EQPT_POS_WUQI] = {0, 45},
    [ITEM_DEF_EQPT_POS_TOUKUI] = {0, 49},
    [ITEM_DEF_EQPT_POS_YIFU] = {0, 48},
    [ITEM_DEF_EQPT_POS_XIEZI] = {0, 46},
    [ITEM_DEF_EQPT_POS_XIANGLIAN] = {0, 47},
    [ITEM_DEF_EQPT_POS_YAODAI] = {0, 51},
    [ITEM_DEF_EQPT_POS_GUANJIAN] = {0, 51},
    [ITEM_DEF_EQPT_POS_CHIBANG] = {0, 45},
    [ITEM_DEF_EQPT_POS_MIANJU] = {0, 50},
    [ITEM_DEF_EQPT_POS_PIFENG] = {0, 50}
  }
  self.m_ShowingPageNum = nil
  self.m_Page_Beibao = self:getNode("layer_role")
  self.m_Page_Cangku = self:getNode("layer_ck")
  self.m_ViewPara = para or {}
  self.m_CurChoosedHeroIns = g_LocalPlayer:getMainHero()
  self:SetBtns()
  self:InitCangkuTips()
  self:InitCangkuView()
  self:ShowTableView(MainRole_Beibao_Page)
  self:SetItemList()
  self:SetMoney()
  self:ReflushBaseInfo()
  self:SetAttrTips()
  self:ShowWingTips()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_MoveScene)
  self:ListenMessage(MsgID_WarScene)
  self:ListenMessage(MsgID_Scene)
  g_MainRoleView = self
end
function CMainRoleView:SetAttrTips()
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_HP"), PROPERTY_HP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_hp"), PROPERTY_HP, self:getNode("txt_des_HP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_MP"), PROPERTY_MP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_mp"), PROPERTY_MP, self:getNode("txt_des_MP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_AP"), PROPERTY_AP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_ap"), PROPERTY_AP, self:getNode("txt_des_AP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_SP"), PROPERTY_SP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_sp"), PROPERTY_SP, self:getNode("txt_des_SP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_gg_name"), PROPERTY_GenGu, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_gg"), PROPERTY_GenGu, self:getNode("txt_gg_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lx_name"), PROPERTY_Lingxing, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_lx"), PROPERTY_Lingxing, self:getNode("txt_lx_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_ll_name"), PROPERTY_LiLiang, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_ll"), PROPERTY_LiLiang, self:getNode("txt_ll_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_mj_name"), PROPERTY_MinJie, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_mj"), PROPERTY_MinJie, self:getNode("txt_mj_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("coinbg"), "ressilver")
  self:attrclick_check_withWidgetObj(self:getNode("goldbg"), "rescoin")
end
function CMainRoleView:getEquipNeedAddIcon(pos)
  if self.m_CurChoosedHeroIns == nil then
    return false
  end
  local data = self.m_EquipAddIcon_ZsLevel[pos]
  if data == nil then
    return false
  end
  local lv = self.m_CurChoosedHeroIns:getProperty(PROPERTY_ROLELEVEL)
  local zs = self.m_CurChoosedHeroIns:getProperty(PROPERTY_ZHUANSHENG)
  return zs > data[1] or zs == data[1] and lv >= data[2]
end
function CMainRoleView:getRoleRace()
  if self.m_CurChoosedHeroIns == nil then
    return RACE_REN
  else
    return self.m_CurChoosedHeroIns:getProperty(PROPERTY_RACE)
  end
end
function CMainRoleView:getRoleSex()
  if self.m_CurChoosedHeroIns == nil then
    return HERO_MALE
  else
    return self.m_CurChoosedHeroIns:getProperty(PROPERTY_GENDER)
  end
end
function CMainRoleView:SetBtns()
  local btnBatchListener = {
    btn_kangxingview = {
      listener = handler(self, self.OnBtn_KangxingView),
      variName = "btn_kangxingview"
    },
    btn_addmoney = {
      listener = handler(self, self.OnBtn_AddMoney),
      variName = "btn_addmoney"
    },
    btn_addgold = {
      listener = handler(self, self.OnBtn_AddSilver),
      variName = "btn_addgold"
    },
    btn_zhengli = {
      listener = handler(self, self.OnBtn_Zhengli),
      variName = "btn_zhengli"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_zhenglick = {
      listener = handler(self, self.OnBtn_ZhengliCk),
      variName = "btn_zhenglick"
    },
    btn_gonglue = {
      listener = handler(self, self.OnBtn_GongLue),
      variName = "btn_zhengli"
    },
    btn_table1 = {
      listener = handler(self, self.OnBtn_Table_Beibao),
      variName = "btn_table1"
    },
    btn_table2 = {
      listener = handler(self, self.OnBtn_Table_Cangku),
      variName = "btn_table2"
    },
    btn_table3 = {
      listener = handler(self, self.OnBtn_Table_FaBao),
      variName = "btn_table3"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  if g_FabaoRelease == true then
    local x2, y2 = self.btn_table2:getPosition()
    local x3, y3 = self.btn_table3:getPosition()
    self.btn_table3:setPosition(ccp(x2, y2))
    self.btn_table2:setPosition(ccp(x3, y3))
  end
  self:addBtnSigleSelectGroup({
    {
      self.btn_table1,
      nil,
      ccc3(119, 54, 48),
      ccp(-2, 0),
      ccc3(255, 250, 243)
    },
    {
      self.btn_table2,
      nil,
      ccc3(119, 54, 48),
      ccp(-2, 0),
      ccc3(255, 250, 243)
    },
    {
      self.btn_table3,
      nil,
      ccc3(119, 54, 48),
      ccp(-2, 0),
      ccc3(255, 250, 243)
    }
  })
  self:setGroupAllNotSelected(self.btn_table1)
  self.btn_table1:setTitleText("背包")
  self.btn_table2:setTitleText("仓库")
  self.btn_table3:setTitleText("法宝")
  clickArea_check.extend(self)
  self.m_EqptBtnNameDict = {
    [ITEM_DEF_EQPT_POS_WUQI] = "pic_quipe_weapon",
    [ITEM_DEF_EQPT_POS_TOUKUI] = "pic_quipe_armet",
    [ITEM_DEF_EQPT_POS_YIFU] = "pic_quipe_cloth",
    [ITEM_DEF_EQPT_POS_XIEZI] = "pic_quipe_shoes",
    [ITEM_DEF_EQPT_POS_XIANGLIAN] = "pic_quipe_necklace",
    [ITEM_DEF_EQPT_POS_YAODAI] = "pic_quipe_yaodai",
    [ITEM_DEF_EQPT_POS_GUANJIAN] = "pic_quipe_guajian",
    [ITEM_DEF_EQPT_POS_CHIBANG] = "pic_quipe_chibang",
    [ITEM_DEF_EQPT_POS_MIANJU] = "pic_quipe_mianju",
    [ITEM_DEF_EQPT_POS_PIFENG] = "pic_quipe_pifeng"
  }
  self.m_EquipIcon = {}
  for pos, btnName in pairs(self.m_EqptBtnNameDict) do
    self[btnName] = self:getNode(btnName)
    self:click_check_withObj(self[btnName], function()
      self:OnBtn_WeaponClick(pos, btnName)
    end, function(check)
      self:OnClickEquipItem(self[btnName], check)
    end)
  end
end
function CMainRoleView:SetItemList()
  self:getNode("subviewPos"):setVisible(false)
  tempView = CPackageView.new(self.m_ViewPara, self)
  self.m_PackageView = tempView
  self:addChild(tempView.m_UINode)
  local x, y = self:getNode("subviewPos"):getPosition()
  tempView:setPosition(ccp(x, y))
end
function CMainRoleView:ReflushBaseInfo()
  self:ReflushRoleShape()
  self:ReflushProData()
  self:ReflushCurrEquipInfo()
end
function CMainRoleView:ReflushRoleShape()
  local race = self.m_CurChoosedHeroIns:getProperty(PROPERTY_RACE)
  local shape = self.m_CurChoosedHeroIns:getProperty(PROPERTY_SHAPE)
  self.role_aureole = self:getNode("role_aureole")
  self.poslayer_race = self:getNode("poslayer_race")
  self.role_aureole:setVisible(false)
  self.poslayer_race:setVisible(false)
  local x, y = self.role_aureole:getPosition()
  local parent = self.role_aureole:getParent()
  local z = self.role_aureole:getZOrder()
  if self.m_RoleAni == nil or self.m_RoleAni._shape ~= shape then
    if self.m_RoleAni then
      if self.m_RoleAni._addClickWidget then
        self.m_RoleAni._addClickWidget:removeFromParentAndCleanup(true)
        self.m_RoleAni._addClickWidget = nil
      end
      self.m_RoleAni:removeFromParentAndCleanup(true)
      self.m_RoleAni = nil
    end
    local offx, offy = 0, 0
    local colorList = self.m_CurChoosedHeroIns:getProperty(PROPERTY_RANCOLOR)
    if colorList == nil or colorList == 0 or type(colorList) == "table" and #colorList == 0 then
      colorList = {
        0,
        0,
        0
      }
    end
    self.m_RoleAni, offx, offy = createBodyByShapeForDlg(shape, colorList)
    parent:addNode(self.m_RoleAni, z + 10)
    self.m_RoleAni:setPosition(x + offx, y + offy)
    self:addclickAniForHeroAni(self.m_RoleAni, self.role_aureole, nil, nil, nil, handler(self, self.onRoleAniSetVisible))
    self.m_RoleAni:setVisible(false)
    if self.m_ChibangAni then
      self.m_ChibangAni:SetActAndDir("stand", 4)
      self.m_ChibangAni:setVisible(false)
    end
    local act1 = CCDelayTime:create(0.01)
    local act2 = CCCallFunc:create(function()
      self.m_RoleAni:setVisible(true)
      if self.m_ChibangAni then
        self.m_ChibangAni:setVisible(true)
      end
    end)
    self.m_RoleAni:runAction(transition.sequence({act1, act2}))
  end
  if self.m_RoleAureole == nil then
    self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
    parent:addNode(self.m_RoleAureole, z + 9)
    self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  end
  if self.m_RoleShadow == nil then
    self.m_RoleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    parent:addNode(self.m_RoleShadow, z + 9)
    self.m_RoleShadow:setPosition(x, y)
  end
  if race ~= self.m_LastRaceShow then
    if self.m_RaceImage ~= nil then
      self.m_RaceImage:removeFromParentAndCleanup(true)
      self.m_RaceImage = nil
    end
    if self.m_RaceBg ~= nil then
      self.m_RaceBg:removeFromParentAndCleanup(true)
      self.m_RaceBg = nil
    end
    self.m_LastRaceShow = race
    local raceTxt = Def_Race_Res_Para_Dict[race] or Def_Race_Res_Para_Dict[RACE_REN]
    self.m_RaceBg = display.newSprite(string.format("views/rolelist/pic_rolebg_%s.png", raceTxt))
    local offx, offy = 0, 0
    local x, y = self.role_aureole:getPosition()
    parent:addNode(self.m_RaceBg, z)
    self.m_RaceBg:setPosition(x, y + 65)
    self.m_RaceImage = display.newSprite(string.format("views/rolelist/pic_roleicon_%s_unselect.png", raceTxt))
    self.m_RaceImage:setAnchorPoint(ccp(1, 0.5))
    self.m_RaceImage:setScale(0.7)
    local x, y = self.poslayer_race:getPosition()
    local size = self.poslayer_race:getContentSize()
    parent:addNode(self.m_RaceImage)
    self.m_RaceImage:setPosition(x + size.width + 5, y + size.height / 2 - 5)
  end
end
function CMainRoleView:ReflushProData()
  local name = self.m_CurChoosedHeroIns:getProperty(PROPERTY_NAME)
  self:getNode("txt_rolename"):setText(name)
  local zs = self.m_CurChoosedHeroIns:getProperty(PROPERTY_ZHUANSHENG)
  local color = ccc3(78, 47, 20)
  self:getNode("txt_rolename"):setColor(color)
  local lv = self.m_CurChoosedHeroIns:getProperty(PROPERTY_ROLELEVEL)
  self:getNode("txt_level"):setText(string.format("%d转%d级", zs, lv))
  local max_hp = self.m_CurChoosedHeroIns:getMaxProperty(PROPERTY_HP)
  local cur_hp = self.m_CurChoosedHeroIns:getProperty(PROPERTY_HP)
  local max_mp = self.m_CurChoosedHeroIns:getMaxProperty(PROPERTY_MP)
  local cur_mp = self.m_CurChoosedHeroIns:getProperty(PROPERTY_MP)
  if g_WarScene then
    local tempHp, tempMaxHp, tempMp, tempMaxMp = g_WarScene:getMyRoleHpMpData(self.m_CurChoosedHeroIns:getObjId())
    if tempHp ~= nil then
      max_hp = tempMaxHp
      cur_hp = tempHp
      max_mp = tempMaxMp
      cur_mp = tempMp
    end
  end
  self:getNode("txt_value_HP"):setText(string.format("%d/%d", cur_hp, max_hp))
  local tempHpLimit = self:getNode("pro_bg_hp"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_HP"), tempHpLimit - 10)
  self:getNode("txt_value_MP"):setText(string.format("%d/%d", cur_mp, max_mp))
  local tempMpLimit = self:getNode("pro_bg_mp"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_MP"), tempMpLimit - 10)
  local cur_ap = self.m_CurChoosedHeroIns:getProperty(PROPERTY_AP)
  self:getNode("txt_value_AP"):setText(string.format("%d", cur_ap))
  local tempApLimit = self:getNode("pro_bg_ap"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_AP"), tempApLimit - 10)
  local cur_sp = self.m_CurChoosedHeroIns:getProperty(PROPERTY_SP)
  self:getNode("txt_value_SP"):setText(string.format("%d", cur_sp))
  local tempSpLimit = self:getNode("pro_bg_sp"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_SP"), tempSpLimit - 10)
  local tempPointTextObj = {
    [PROPERTY_GenGu] = self:getNode("txt_gg_point"),
    [PROPERTY_LiLiang] = self:getNode("txt_ll_point"),
    [PROPERTY_MinJie] = self:getNode("txt_mj_point"),
    [PROPERTY_Lingxing] = self:getNode("txt_lx_point")
  }
  local tempAddTextObj = {
    [PROPERTY_GenGu] = self:getNode("txt_gg_point_add"),
    [PROPERTY_LiLiang] = self:getNode("txt_ll_point_add"),
    [PROPERTY_MinJie] = self:getNode("txt_mj_point_add"),
    [PROPERTY_Lingxing] = self:getNode("txt_lx_point_add")
  }
  local tempOProName = {
    [PROPERTY_GenGu] = PROPERTY_OGenGu,
    [PROPERTY_LiLiang] = PROPERTY_OLiLiang,
    [PROPERTY_MinJie] = PROPERTY_OMinJie,
    [PROPERTY_Lingxing] = PROPERTY_OLingxing
  }
  for i, proType in ipairs({
    PROPERTY_GenGu,
    PROPERTY_Lingxing,
    PROPERTY_LiLiang,
    PROPERTY_MinJie
  }) do
    local points = self.m_CurChoosedHeroIns:getProperty(tempOProName[proType])
    local addNum = self.m_CurChoosedHeroIns:getProperty(proType) - points
    local txtIns = tempPointTextObj[proType]
    local addObj = tempAddTextObj[proType]
    txtIns:setText(string.format("%d", points))
    local tempX, _ = self:getNode("addpro_bg_gg"):getPosition()
    local _, tempY = txtIns:getPosition()
    if addNum == 0 then
      txtIns:setPosition(ccp(tempX, tempY))
      addObj:setVisible(false)
      txtIns:setScale(1)
      addObj:setScale(1)
    else
      if addNum > 0 then
        addNum = math.floor(math.abs(addNum))
        addObj:setText(string.format("+%d", addNum))
        addObj:setColor(VIEW_DEF_PGREEN_COLOR)
      else
        addNum = math.floor(math.abs(addNum))
        addObj:setText(string.format("-%d", addNum))
        addObj:setColor(VIEW_DEF_WARNING_COLOR)
      end
      addObj:setVisible(true)
      local vSize = txtIns:getContentSize()
      local aSize = addObj:getContentSize()
      local vW = vSize.width
      local aW = aSize.width
      local sumW = vW + aW
      local scale = 1
      if sumW > 80 then
        scale = 80 / sumW
      end
      txtIns:setScale(scale)
      addObj:setScale(scale)
      txtIns:setPosition(ccp(tempX + (-sumW / 2 + vW / 2) * scale, tempY))
      addObj:setPosition(ccp(tempX + (sumW / 2 - aW / 2) * scale, tempY))
    end
  end
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:ReSetHeroData(self.m_CurChoosedHeroIns:getObjId())
  end
end
function CMainRoleView:ReflushCurrEquipInfo()
  for pos, btnName in pairs(self.m_EqptBtnNameDict) do
    self:ReflushOneEquip(pos)
  end
end
function CMainRoleView:ReloadCurrEquipInfo(roleId, itemObjId)
  if self.m_CurChoosedHeroIns == nil or self.m_CurChoosedHeroIns:getObjId() ~= roleId then
    return
  end
  local itemIns = g_LocalPlayer:GetOneItem(itemObjId)
  if itemIns == nil then
    return
  end
  local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
  local eqptPosType = EPQT_TYPE_2_EQPT_POS[eqptType]
  if eqptPosType ~= nil then
    self:ReflushOneEquip(eqptPosType)
  end
end
function CMainRoleView:ReflushOneEquip(equipPosType)
  if self.m_CurChoosedHeroIns == nil then
    return
  end
  if self.m_EquipIcon[equipPosType] ~= nil then
    self.m_EquipIcon[equipPosType]:removeFromParentAndCleanup(true)
    self.m_EquipIcon[equipPosType] = nil
  end
  local btn_quipe = self[self.m_EqptBtnNameDict[equipPosType]]
  if btn_quipe == nil then
    return
  end
  local itemIns = self.m_CurChoosedHeroIns:GetEqptByPos(equipPosType)
  if itemIns == nil then
    if equipPosType == ITEM_DEF_EQPT_POS_CHIBANG then
      local itemShape = data_getItemShapeID(ITEM_FIRST_LV_CHIBANG)
      local equipIcon = createItemIcon(itemShape, nil, false, false)
      btn_quipe:addNode(equipIcon)
      self.m_EquipIcon[equipPosType] = equipIcon
      self:removeChibangAni()
    elseif self:getEquipNeedAddIcon(equipPosType) then
      local equipAddIcon = display.newSprite("views/rolelist/equipcanadd.png")
      btn_quipe:addNode(equipAddIcon)
      equipAddIcon:setPosition(ccp(20, 20))
      self.m_EquipIcon[equipPosType] = equipAddIcon
    end
  else
    local itemTypeId = itemIns:getTypeId()
    local itemShape = data_getItemShapeID(itemTypeId)
    local canUseFlag = self.m_CurChoosedHeroIns:CanAddItem(itemIns:getObjId()) == true
    local canUpgradeFlag = self.m_CurChoosedHeroIns:CanUpgradeItem(itemIns:getObjId())
    local canAddPoint = false
    if equipPosType == ITEM_DEF_EQPT_POS_CHIBANG then
      canAddPoint = self.m_CurChoosedHeroIns:CanChiBangAddPoint()
      self:addChibangAni(itemTypeId)
    end
    local equipIcon = createItemIcon(itemShape, nil, canUseFlag, canUpgradeFlag, canAddPoint)
    btn_quipe:addNode(equipIcon)
    self.m_EquipIcon[equipPosType] = equipIcon
  end
  self:ReflushEquipShowValue()
end
function CMainRoleView:ReflushEquipShowValue()
  local value = 0
  if self.m_CurChoosedHeroIns ~= nil then
    for _, pos in pairs({
      ITEM_DEF_EQPT_POS_WUQI,
      ITEM_DEF_EQPT_POS_TOUKUI,
      ITEM_DEF_EQPT_POS_YIFU,
      ITEM_DEF_EQPT_POS_XIEZI,
      ITEM_DEF_EQPT_POS_XIANGLIAN,
      ITEM_DEF_EQPT_POS_YAODAI,
      ITEM_DEF_EQPT_POS_GUANJIAN,
      ITEM_DEF_EQPT_POS_MIANJU,
      ITEM_DEF_EQPT_POS_PIFENG,
      ITEM_DEF_EQPT_POS_CHIBANG
    }) do
      local itemIns = self.m_CurChoosedHeroIns:GetEqptByPos(pos)
      if itemIns ~= nil then
        local canUseFlag = self.m_CurChoosedHeroIns:CanAddItem(itemIns:getObjId()) == true
        if canUseFlag then
          value = value + GetEquipShowValue(itemIns)
        end
      end
    end
  end
  self:getNode("txt_zbnum"):setText(string.format("装备评分\n%d", value))
end
function CMainRoleView:addChibangAni(typeId)
  if self.m_ChibangAni ~= nil and self.m_ChibangAni.__typeId == typeId then
    return
  end
  self:removeChibangAni()
  if self.m_RoleAni then
    local p = self.m_RoleAni:getParent()
    local z = self.m_RoleAni:getZOrder()
    local x, y = self.role_aureole:getPosition()
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.m_ChibangAni = CChiBang.new(self.m_RoleAni._shape, typeId, self.m_RoleAni)
    resetDefaultAlphaPixelFormat()
    self.m_ChibangAni.__typeId = typeId
    local v = self.m_RoleAni:isVisible()
    self.m_ChibangAni:setVisible(v)
    self.m_ChibangAni:SetActAndDir("stand", 4)
    local off = data_getChiBangOffInfo(self.m_RoleAni._shape, "stand_4")
    self.m_ChibangAni:setPosition(ccp(x + off[1], y + off[2]))
    self.m_RoleAni:playAniFromStart(-1)
    local color = data_getWingColor(typeId)
    self.m_ChibangAni:setColor(color)
  end
end
function CMainRoleView:removeChibangAni()
  if self.m_ChibangAni ~= nil then
    self.m_ChibangAni:Clear()
    self.m_ChibangAni = nil
  end
end
function CMainRoleView:onRoleAniSetVisible(v)
  if self.m_ChibangAni then
    self.m_ChibangAni:setVisible(v)
  end
end
function CMainRoleView:SelectRoleViewItem(pos)
  local PET_POS = 6
  local selectImgTag = 9999
  for tempPos, btnName in pairs(self.m_EqptBtnNameDict) do
    local btn = self[btnName]
    local oldImg = btn:getVirtualRenderer():getChildByTag(selectImgTag)
    if pos == tempPos then
      if oldImg == nil then
        local img = display.newSprite("xiyou/item/selecteditem.png")
        btn:getVirtualRenderer():addChild(img, 10, selectImgTag)
        local size = btn:getContentSize()
        img:setPosition(ccp(size.width / 2, size.height / 2))
      end
    elseif oldImg ~= nil then
      btn:getVirtualRenderer():removeChild(oldImg)
    end
  end
end
function CMainRoleView:JumpTohZhuangBeiDlg(pos)
  local param = {
    InitRace = self.m_CurChoosedHeroIns:getProperty(PROPERTY_RACE),
    InitGender = self.m_CurChoosedHeroIns:getProperty(PROPERTY_GENDER),
    InitMidType = pos,
    forRoleId = self.m_CurChoosedHeroIns:getObjId(),
    closeCallBack = function()
      self:ShowSelf()
    end
  }
  self:HideSelf()
  getCurSceneView():addSubView({
    subView = CCreateZhuangbei.new(param),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainRoleView:OnBtn_WeaponClick(pos, btnName)
  local itemIns = self.m_CurChoosedHeroIns:GetEqptByPos(pos)
  if itemIns ~= nil then
    self:SelectRoleViewItem(pos)
  elseif pos == ITEM_DEF_EQPT_POS_CHIBANG then
    self:SelectRoleViewItem(pos)
  else
    self:SelectRoleViewItem(nil)
    if self:getEquipNeedAddIcon(pos) then
      self:JumpTohZhuangBeiDlg(pos)
    else
      local attrName = string.format("zbpos_%d", pos)
      if data_AttrTip[attrName] ~= nil then
        local tempObj = self[btnName]
        if tempObj then
          local size = tempObj:getContentSize()
          local ap = tempObj:getAnchorPoint()
          local wPos = tempObj:convertToWorldSpace(ccp(size.width * -ap.x, size.height * -ap.y))
          CAttrDetailView.new(attrName, {
            x = wPos.x,
            y = wPos.y,
            w = size.width,
            h = size.height
          }, paramListener)
        end
      end
    end
  end
  if itemIns ~= nil then
    local itemObjId = itemIns:getObjId()
    self:ShowPackageDetail(itemObjId, ClickFromRole)
  elseif pos == ITEM_DEF_EQPT_POS_CHIBANG then
    self:ShowHowToGetChibang()
  end
end
function CMainRoleView:ShowHowToGetChibang()
  self.m_EquipDetail = CEquipDetail.new(itemObjId, {
    closeListener = handler(self, self.OnEquipDetailClosed),
    eqptRoleId = self.m_CurChoosedHeroIns:getObjId(),
    itemType = ITEM_FIRST_LV_CHIBANG
  })
  self:addSubView({
    subView = self.m_EquipDetail,
    zOrder = 9999
  })
  local x, y = self:getNode("bg1"):getPosition()
  local iSize = self:getNode("bg1"):getContentSize()
  local bSize = self.m_EquipDetail:getBoxSize()
  self.m_EquipDetail:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
  self.m_EquipDetail:ShowCloseBtn()
end
function CMainRoleView:ShowPackageDetail(itemObjId, fromWhere)
  local curClickTime = cc.net.SocketTCP.getTime()
  if self.m_DoubleClickData ~= nil then
    self.m_DoubleClickData_Old = DeepCopyTable(self.m_DoubleClickData)
  end
  self.m_DoubleClickData = {
    itemObjId,
    fromWhere,
    curClickTime
  }
  if fromWhere == ClickFromRole then
    local itemIns = g_LocalPlayer:GetOneItem(itemObjId)
    local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
    if eqptType == ITEM_DEF_EQPT_WEAPON_CHIBANG then
      self.m_EquipDetail = CEquipDetail.new(itemObjId, {
        leftBtn = {
          btnText = "分配点数",
          listener = handler(self, self.OnSetChiBang)
        },
        rightBtn = {
          btnText = "炼化",
          listener = handler(self, self.OnUpgradeEquip)
        },
        closeListener = handler(self, self.OnEquipDetailClosed),
        eqptRoleId = self.m_CurChoosedHeroIns:getObjId()
      })
      if self.m_CurChoosedHeroIns:CanChiBangAddPoint() then
        local btn = self.m_EquipDetail.btn_left
        if btn and btn.redIcon == nil then
          local redIcon = display.newSprite("views/pic/pic_tipnew.png")
          btn:addNode(redIcon, 0)
          redIcon:setPosition(ccp(60, 20))
          btn.redIcon = redIcon
        end
      end
    else
      self.m_EquipDetail = CEquipDetail.new(itemObjId, {
        leftBtn = {
          btnText = "卸下",
          listener = handler(self, self.OnTakeDownEquip)
        },
        rightBtn = {
          btnText = "打造装备",
          listener = handler(self, self.OnUpgradeEquip)
        },
        closeListener = handler(self, self.OnEquipDetailClosed),
        eqptRoleId = self.m_CurChoosedHeroIns:getObjId()
      })
    end
    self:addSubView({
      subView = self.m_EquipDetail,
      zOrder = 9999
    })
    local x, y = self:getNode("bg1"):getPosition()
    local iSize = self:getNode("bg1"):getContentSize()
    local bSize = self.m_EquipDetail:getBoxSize()
    self.m_EquipDetail:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
    self.m_EquipDetail:ShowCloseBtn()
  elseif fromWhere == ClickFromBeibao then
    local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
    if packageItemIns == nil then
      return
    end
    if self.m_PackageView == nil then
      return
    end
    local itemType = packageItemIns:getType()
    local itemTypeId = packageItemIns:getTypeId()
    if self.m_ShowingPageNum == MainRole_Beibao_Page then
      if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_SHENBING or itemType == ITEM_LARGE_TYPE_XIANQI then
        local eqptType = packageItemIns:getProperty(ITEM_PRO_EQPT_TYPE)
        local eqptPosType = EPQT_TYPE_2_EQPT_POS[eqptType]
        local itemIns = self.m_CurChoosedHeroIns:GetEqptByPos(eqptPosType)
        local curItemId
        if itemIns then
          curItemId = itemIns:getObjId()
        end
        self.m_EquipDetail = CPacakgeZBShow.new({
          InitRoleItem = curItemId,
          InitItemId = itemObjId,
          InitRoleId = self.m_CurChoosedHeroIns:getObjId(),
          sellItemListener = handler(self, self.OnSellItem),
          takeonItemListener = function(itemId)
            self:OnTakeUpEquip(itemId, true)
          end,
          closeListener = handler(self, self.OnEquipDetailClosed)
        })
        getCurSceneView():addSubView({
          subView = self.m_EquipDetail,
          zOrder = MainUISceneZOrder.menuView
        })
      else
        self.m_EquipDetail = nil
        if itemType == ITEM_LARGE_TYPE_TASK then
          self.m_EquipDetail = CEquipDetail.new(itemObjId, {
            closeListener = handler(self, self.OnEquipDetailClosed),
            eqptRoleId = self.m_CurChoosedHeroIns:getObjId(),
            fromPackageFlag = true
          })
        elseif itemType == ITEM_LARGE_TYPE_GIFT and data_FriendGifts[itemTypeId] ~= nil and packageItemIns:getProperty(ITME_PRO_BUNDLE_FLAG) ~= 1 then
          self.m_EquipDetail = CEquipDetail.new(itemObjId, {
            leftBtn = {
              btnText = "赠送",
              listener = handler(self, self.OnSendItem)
            },
            rightBtn = {
              btnText = "使用",
              listener = handler(self, self.OnUseItem)
            },
            closeListener = handler(self, self.OnEquipDetailClosed),
            eqptRoleId = self.m_CurChoosedHeroIns:getObjId(),
            fromPackageFlag = true
          })
        elseif itemType == ITEM_LARGE_TYPE_STUFF then
          local noUseBtn = false
          if data_getIsQHF(itemTypeId) or data_getStuffItemShowCanUseBtn(itemTypeId) == 0 then
            noUseBtn = true
          elseif data_getStuffItemShowCanUseBtn(itemTypeId) == 2 then
            local lsID, lsLV = g_LocalPlayer:getBaseLifeSkill()
            if lsID ~= LIFESKILL_MAKEDRUG then
              noUseBtn = true
            end
          elseif data_getStuffItemShowCanUseBtn(itemTypeId) == 3 then
            local lsID, lsLV = g_LocalPlayer:getBaseLifeSkill()
            if lsID ~= LIFESKILL_MAKEFU then
              noUseBtn = true
            end
          elseif data_getStuffItemShowCanUseBtn(itemTypeId) == 4 then
            local lsID, lsLV = g_LocalPlayer:getBaseLifeSkill()
            if lsID ~= LIFESKILL_MAKEFOOD then
              noUseBtn = true
            end
          end
          if noUseBtn then
            self.m_EquipDetail = CEquipDetail.new(itemObjId, {
              leftBtn = {
                btnText = "出售",
                listener = handler(self, self.OnSellItem)
              },
              closeListener = handler(self, self.OnEquipDetailClosed),
              eqptRoleId = self.m_CurChoosedHeroIns:getObjId(),
              fromPackageFlag = true
            })
          end
        elseif itemType == ITEM_LARGE_TYPE_OTHERITEM then
          local noUseBtn = false
          if itemTypeId == ITEM_DEF_OTHER_AIQINGGUOZHONGZI then
            noUseBtn = true
          elseif itemTypeId == ITEM_DEF_OTHER_JIEQILING then
            noUseBtn = true
          elseif itemTypeId == ITEM_DEF_JB_SSJP then
            noUseBtn = true
          elseif itemTypeId == ITEM_DEF_OTHER_NianHuo then
            noUseBtn = true
          elseif itemTypeId == ITEM_DEF_OTHER_TYBG then
            noUseBtn = false
          end
          if noUseBtn then
            self.m_EquipDetail = CEquipDetail.new(itemObjId, {
              leftBtn = {
                btnText = "出售",
                listener = handler(self, self.OnSellItem)
              },
              closeListener = handler(self, self.OnEquipDetailClosed),
              eqptRoleId = self.m_CurChoosedHeroIns:getObjId(),
              fromPackageFlag = true
            })
          end
          if itemTypeId == ITEM_DEF_OTHER_TYBG then
            local tybgView = CTianYuanBaoGuanView.new()
            if tybgView then
              getCurSceneView():addSubView({
                subView = tybgView,
                zOrder = MainUISceneZOrder.menuView
              })
              local sItem = self.m_PackageView.m_PackageFrame:getTouchBeganItem()
              if sItem == nil then
                sItem = self.m_PackageView.m_PackageFrame:getItemById(itemObjId)
              end
              if sItem == nil then
                local x, y = self:getNode("bg1"):getPosition()
                local iSize = self:getNode("bg1"):getContentSize()
                local bSize = tybgView:getBoxSize()
                tybgView:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
              else
                local bSize = tybgView:getBoxSize()
                local sx, sy = sItem:getPosition()
                local sSize = sItem:getBoxSize()
                local swPos = sItem:getParent():convertToWorldSpace(ccp(sx, sy + sSize.height / 2))
                local wPosY = swPos.y - bSize.height / 2
                if wPosY < 0 then
                  wPosY = 0
                end
                if wPosY + bSize.height > display.height then
                  wPosY = display.height - bSize.height
                end
                newPos = self:getUINode():convertToNodeSpace(ccp(swPos.x - bSize.width - 5, wPosY))
                tybgView:setPosition(ccp(newPos.x, newPos.y))
              end
              return
            end
          end
        end
        if self.m_EquipDetail == nil and itemTypeId ~= ITEM_DEF_OTHER_TYBG then
          local rightBtnTxt = "使用"
          if itemType == ITEM_LARGE_TYPE_NEIDAN then
            rightBtnTxt = "装备"
          end
          self.m_EquipDetail = CEquipDetail.new(itemObjId, {
            leftBtn = {
              btnText = "出售",
              listener = handler(self, self.OnSellItem)
            },
            rightBtn = {
              btnText = rightBtnTxt,
              listener = handler(self, self.OnUseItem)
            },
            closeListener = handler(self, self.OnEquipDetailClosed),
            eqptRoleId = self.m_CurChoosedHeroIns:getObjId(),
            fromPackageFlag = true
          })
        end
        if self.m_EquipDetail ~= nil then
          self:addSubView({
            subView = self.m_EquipDetail,
            zOrder = 9999
          })
          local sItem = self.m_PackageView.m_PackageFrame:getTouchBeganItem()
          if sItem == nil then
            sItem = self.m_PackageView.m_PackageFrame:getItemById(itemObjId)
          end
          if sItem == nil then
            local x, y = self:getNode("bg1"):getPosition()
            local iSize = self:getNode("bg1"):getContentSize()
            local bSize = self.m_EquipDetail:getBoxSize()
            self.m_EquipDetail:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
          else
            local bSize = self.m_EquipDetail:getBoxSize()
            local sx, sy = sItem:getPosition()
            local sSize = sItem:getBoxSize()
            local swPos = sItem:getParent():convertToWorldSpace(ccp(sx, sy + sSize.height / 2))
            local wPosY = swPos.y - bSize.height / 2
            if wPosY < 0 then
              wPosY = 0
            end
            if wPosY + bSize.height > display.height then
              wPosY = display.height - bSize.height
            end
            newPos = self:getUINode():convertToNodeSpace(ccp(swPos.x - bSize.width - 5, wPosY))
            self.m_EquipDetail:setPosition(ccp(newPos.x, newPos.y))
          end
          return
        end
      end
    elseif self.m_ShowingPageNum == MainRole_Cangku_Page then
      local longViewFlag
      if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_SHENBING or itemType == ITEM_LARGE_TYPE_XIANQI then
        longViewFlag = true
      end
      if self.m_DoubleClickData ~= nil and self.m_DoubleClickData_Old ~= nil and self.m_DoubleClickData[1] == self.m_DoubleClickData_Old[1] and self.m_DoubleClickData[2] == self.m_DoubleClickData_Old[2] and self.m_DoubleClickData[3] - self.m_DoubleClickData_Old[3] <= DoubleClickTime then
        self:OnPutIntoCangku(itemObjId)
        return
      end
      self.m_EquipDetail = CEquipDetail.new(itemObjId, {
        leftBtn = {
          btnText = "存入仓库",
          listener = handler(self, self.OnPutIntoCangku)
        },
        closeListener = handler(self, self.OnEquipDetailClosed),
        eqptRoleId = self.m_CurChoosedHeroIns:getObjId(),
        fromPackageFlag = true,
        longViewFlag = longViewFlag
      })
      if self.m_EquipDetail ~= nil then
        self:addSubView({
          subView = self.m_EquipDetail,
          zOrder = 9999
        })
        local sItem = self.m_PackageView.m_PackageFrame:getTouchBeganItem()
        if sItem == nil then
          sItem = self.m_PackageView.m_PackageFrame:getItemById(itemObjId)
        end
        if sItem == nil then
          local x, y = self:getNode("bg1"):getPosition()
          local iSize = self:getNode("bg1"):getContentSize()
          local bSize = self.m_EquipDetail:getBoxSize()
          self.m_EquipDetail:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
        else
          local bSize = self.m_EquipDetail:getBoxSize()
          local sx, sy = sItem:getPosition()
          local sSize = sItem:getBoxSize()
          local swPos = sItem:getParent():convertToWorldSpace(ccp(sx, sy + sSize.height / 2))
          local wPosY = swPos.y - bSize.height / 2
          if wPosY < 0 then
            wPosY = 0
          end
          if wPosY + bSize.height > display.height then
            wPosY = display.height - bSize.height
          end
          newPos = self:getUINode():convertToNodeSpace(ccp(swPos.x - bSize.width - 5, wPosY))
          self.m_EquipDetail:setPosition(ccp(newPos.x, newPos.y))
        end
        return
      end
    end
  elseif fromWhere == ClickFromCangku then
    local packageItemIns = g_LocalPlayer:GetOneCangkuItem(itemObjId)
    if packageItemIns == nil then
      return
    end
    if self.m_CangkuView == nil then
      return
    end
    local itemType = packageItemIns:getType()
    local itemTypeId = packageItemIns:getTypeId()
    local longViewFlag
    if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_SHENBING or itemType == ITEM_LARGE_TYPE_XIANQI then
      longViewFlag = true
    end
    if self.m_DoubleClickData ~= nil and self.m_DoubleClickData_Old ~= nil and self.m_DoubleClickData[1] == self.m_DoubleClickData_Old[1] and self.m_DoubleClickData[2] == self.m_DoubleClickData_Old[2] and self.m_DoubleClickData[3] - self.m_DoubleClickData_Old[3] <= DoubleClickTime then
      self:OnGetFromCangku(itemObjId)
      return
    end
    self.m_EquipDetail = CEquipDetail.new(itemObjId, {
      leftBtn = {
        btnText = "取回背包",
        listener = handler(self, self.OnGetFromCangku)
      },
      closeListener = handler(self, self.OnEquipDetailClosed),
      eqptRoleId = self.m_CurChoosedHeroIns:getObjId(),
      fromPackageFlag = true,
      longViewFlag = longViewFlag,
      isCangku = true
    })
    if self.m_EquipDetail ~= nil then
      self:addSubView({
        subView = self.m_EquipDetail,
        zOrder = 9999
      })
      local sItem = self.m_CangkuView.m_CangkuView:getTouchBeganItem()
      if sItem == nil then
        sItem = self.m_CangkuView.m_CangkuView:getItemById(itemObjId)
      end
      if sItem == nil then
        local x, y = self:getNode("bg1"):getPosition()
        local iSize = self:getNode("bg1"):getContentSize()
        local bSize = self.m_EquipDetail:getBoxSize()
        self.m_EquipDetail:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
      else
        local bSize = self.m_EquipDetail:getBoxSize()
        local sx, sy = sItem:getPosition()
        local sSize = sItem:getBoxSize()
        local swPos = sItem:getParent():convertToWorldSpace(ccp(sx, sy + sSize.height / 2))
        local wPosY = swPos.y - bSize.height / 2
        if wPosY < 0 then
          wPosY = 0
        end
        if wPosY + bSize.height > display.height then
          wPosY = display.height - bSize.height
        end
        newPos = self:getUINode():convertToNodeSpace(ccp(swPos.x + sSize.width + 5, wPosY))
        self.m_EquipDetail:setPosition(ccp(newPos.x, newPos.y))
      end
      return
    end
  end
end
function CMainRoleView:CloseEquipDetail()
  if self.m_EquipDetail then
    self.m_EquipDetail:CloseSelf()
    self:SelectRoleViewItem(nil)
  end
end
function CMainRoleView:OnClickEquipItem(obj, check)
  if check then
    obj:setScale(1.05)
  else
    obj:setScale(1)
  end
end
function CMainRoleView:OnEquipDetailClosed(obj)
  if self.m_EquipDetail ~= nil and self.m_EquipDetail == obj then
    self.m_EquipDetail = nil
    self:SelectRoleViewItem(nil)
    if self.m_PackageView then
      self.m_PackageView.m_PackageFrame:ClearSelectItem()
    end
    if self.m_CangkuView then
      self.m_CangkuView.m_CangkuView:ClearSelectItem()
    end
  end
end
function CMainRoleView:OnTakeUpEquip(itemId, isReplace)
  local msg = self.m_CurChoosedHeroIns:CanAddItem(itemId)
  if msg == true then
    self.m_TakeDownEquip_Sound = not isReplace
    local roleId = self.m_CurChoosedHeroIns:getObjId()
    RequestToAddItemToRole(itemId, roleId)
    self:CloseEquipDetail()
  else
    ShowNotifyTips(msg)
  end
end
function CMainRoleView:OnTakeDownEquip(itemId)
  self.m_TakeDownEquip_Sound = true
  local roleId = self.m_CurChoosedHeroIns:getObjId()
  netsend.netitem.requestDelItemFromRole(itemId, roleId)
  self:CloseEquipDetail()
end
function CMainRoleView:OnUpgradeEquip(itemId)
  getCurSceneView():addSubView({
    subView = CZhuangbeiShow.new({
      InitItemId = itemId,
      InitRoleId = self.m_CurChoosedHeroIns:getObjId()
    }),
    zOrder = MainUISceneZOrder.menuView
  })
  self:CloseEquipDetail()
end
function CMainRoleView:OnPutIntoCangku(itemId)
  netsend.netcangku.setItemIntoCangku(itemId)
  self:CloseEquipDetail()
end
function CMainRoleView:OnGetFromCangku(itemId)
  netsend.netcangku.getItemFromCangku(itemId)
  self:CloseEquipDetail()
end
function CMainRoleView:OnSetChiBang(itemId)
  getCurSceneView():addSubView({
    subView = CSetWingView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
  self:CloseEquipDetail()
end
function CMainRoleView:OnSellItem(itemId)
  SellItemPopView(itemId, handler(self, self.OnConfirmSell))
  self:CloseEquipDetail()
end
function CMainRoleView:OnConfirmSell(itemId, itemNum)
  netsend.netitem.requestSellItem(itemId, itemNum)
  self:CloseEquipDetail()
end
function CMainRoleView:OnUseItem(itemId)
  local player = g_DataMgr:getPlayer()
  local itemObj = player:GetOneItem(itemId)
  if itemObj ~= nil then
    do
      local itemType = itemObj:getType()
      local itemShapeTypeId = itemObj:getTypeId()
      local itemName = itemObj:getProperty(ITEM_PRO_NAME)
      if itemType == ITEM_LARGE_TYPE_TASK then
        local canUse, missionId = g_MissionMgr:canMissionObjUse(itemShapeTypeId)
        if canUse then
          local function func()
            if itemShapeTypeId == ITEM_DEF_TASK_MENGPOTANG then
              getCurSceneView():addSubView({
                subView = CRebirthShow.new(),
                zOrder = MainUISceneZOrder.menuView
              })
            else
              netsend.netitem.requestUseItem(itemId)
            end
          end
          CShowProgressBar.new(string.format("正在使用#<II%d>##<CI:%d>%s#", itemShapeTypeId, itemShapeTypeId, itemName), func)
          self:CloseSelf()
        elseif missionId ~= nil then
          g_MissionMgr:TraceMission(missionId)
          self:CloseSelf()
        else
          ShowNotifyTips("无效任务物品")
        end
        return
      elseif itemShapeTypeId == ITEM_DEF_STUFF_RANLIAO then
        g_MapMgr:AutoRouteToNpc(NPC_RanSeShi_ID, function(isSucceed)
          if isSucceed then
            getCurSceneView():addSubView({
              subView = ChangeColorView.new(),
              zOrder = MainUISceneZOrder.menuView
            })
          end
        end)
        self:CloseSelf()
        return
      elseif itemShapeTypeId == ITEM_DEF_OTHER_JSZ then
        g_MapMgr:AutoRouteToNpc(NPC_ShenKuiGongZi_ID, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(NPC_ShenKuiGongZi_ID)
          end
        end)
        self:CloseSelf()
        return
      elseif itemShapeTypeId == ITEM_DEF_OTHER_JUHUA then
        g_MapMgr:AutoRouteToNpc(NPC_SUNSIMIAO_ID, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(NPC_SUNSIMIAO_ID)
          end
        end)
        self:CloseSelf()
        return
      elseif itemShapeTypeId == ITEM_DEF_OTHER_4ZHUANLUNHUIJIU then
        netsend.netitem.requestUseItem(itemId)
        self:CloseSelf()
        return
      elseif itemShapeTypeId == ITEM_DEF_OTHER_ZBT then
        local mapId = itemObj:getProperty(ITME_PRO_ZBT_SCENE)
        local pos = itemObj:getProperty(ITME_PRO_ZBT_POS)
        local rIndex = itemObj:getProperty(ITEM_PRO_ZBT_RESULTINDEX)
        if mapId ~= 0 and mapId ~= nil and pos ~= nil and #pos >= 2 and rIndex ~= nil and rIndex ~= 0 then
          g_MapMgr:UseZBT(itemId, mapId, pos, rIndex)
          self:CloseSelf()
          return
        else
          netsend.netitem.requestUseItem(itemId)
          self:CloseSelf()
          return
        end
      elseif itemShapeTypeId == ITEM_DEF_OTHER_JIANGJUAN then
        ShowJiangJuanViewDlg(itemId)
      elseif itemShapeTypeId == ITEM_DEF_OTHER_GJZBT then
        local mapId = itemObj:getProperty(ITME_PRO_ZBT_SCENE)
        local pos = itemObj:getProperty(ITME_PRO_ZBT_POS)
        local rIndex = itemObj:getProperty(ITEM_PRO_ZBT_RESULTINDEX)
        if mapId ~= 0 and mapId ~= nil and pos ~= nil and #pos >= 2 and rIndex ~= nil and rIndex ~= 0 then
          g_MapMgr:UseZBT(itemId, mapId, pos, rIndex)
          self:CloseSelf()
          return
        else
          netsend.netitem.requestUseItem(itemId)
          self:CloseSelf()
          return
        end
      elseif itemShapeTypeId == ITEM_DEF_OTHER_BTCJ then
        g_MapMgr:AutoRouteToNpc(NPC_LONGWANG_ID, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(NPC_LONGWANG_ID)
          end
        end)
        self:CloseSelf()
        return
      elseif itemShapeTypeId == ITEM_DEF_OTHER_JSCY then
        if activity.guoqingMgr and activity.guoqingMgr:getStatus() ~= 1 then
          ShowNotifyTips("活动已结束")
          return
        end
        do
          local npcId = NPC_DuECanShi_ID
          g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
            if isSucceed and CMainUIScene.Ins then
              CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
            end
          end)
          self:CloseSelf()
          return
        end
      elseif itemShapeTypeId == ITEM_DEF_OTHER_BXSP then
        g_MapMgr:AutoRouteToNpc(NPC_CHENXIAOJIN_ID, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(NPC_CHENXIAOJIN_ID)
          end
        end)
        self:CloseSelf()
        return
      elseif itemShapeTypeId == ITEM_DEF_OTHER_LABA then
        if g_LBMgr then
          self:CloseSelf()
          g_LBMgr:showInputView()
          return
        end
        print("喇叭管理器异常....")
      elseif itemShapeTypeId == ITEM_DEF_OTHER_PUTONGMEIGUI or itemShapeTypeId == ITEM_DEF_OTHER_LANGMANMEIGUI or itemShapeTypeId == ITEM_DEF_OTHER_SHEHUAMEIGUI or itemShapeTypeId == ITEM_DEF_OTHER_TONGXINSUO then
        if 0 < g_FriendsMgr:getFriendNum() then
          ShowYouHaoDuView()
        else
          ShowNotifyTips("你当前没有好友，无法使用")
          return
        end
      elseif itemShapeTypeId == ITEM_DEF_STUFF_CYJZ then
        self:CloseSelf()
        activity.dayanta:GotoNpc()
        return
      elseif itemShapeTypeId == ITEM_DEF_STUFF_SSSP or itemShapeTypeId == ITEM_DEF_STUFF_LSSP then
        local initPetType
        if itemShapeTypeId == ITEM_DEF_STUFF_SSSP then
          initPetType = 20020
        else
          initPetType = 20009
        end
        local tempView = CPetList.new(PetShow_InitShow_TuJianView, nil, function()
          self:ShowSelf()
        end, initPetType)
        getCurSceneView():addSubView({
          subView = tempView,
          zOrder = MainUISceneZOrder.menuView
        })
        self:HideSelf()
        return
      elseif itemShapeTypeId == ITEM_DEF_STUFF_XT or itemShapeTypeId == ITEM_DEF_STUFF_XY or itemShapeTypeId == ITEM_DEF_STUFF_XQSP or data_getIsGaoJiZBJZ(itemShapeTypeId) or data_getIsXianQiJZ(itemShapeTypeId) then
        local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_EqptUpgrade)
        if openFlag == false then
          ShowNotifyTips(tips)
          self:CloseEquipDetail()
          return
        end
        if data_getIsGaoJiZBJZ(itemShapeTypeId) or data_getIsXianQiJZ(itemShapeTypeId) then
          local itemdata = data_Market[itemShapeTypeId]
          local needrace = itemdata.Limit % 10
          local needsex = math.floor(itemdata.Limit / 10)
          if needsex ~= self:getRoleSex() then
            ShowNotifyTips("性别不适用")
            return
          end
          if needrace ~= self:getRoleRace() then
            ShowNotifyTips("种族不适用")
            return
          end
        end
        local mainHero = g_LocalPlayer:getMainHero()
        local mainHeroType = mainHero:getTypeId()
        if data_getIsGaoJiZBJZ(itemShapeTypeId) then
          if itemShapeTypeId == data_getUpgradeEquipNeedJZ(mainHeroType, 2) then
            for _, tempPos in ipairs({
              ITEM_DEF_EQPT_POS_WUQI,
              ITEM_DEF_EQPT_POS_TOUKUI,
              ITEM_DEF_EQPT_POS_YIFU,
              ITEM_DEF_EQPT_POS_XIEZI,
              ITEM_DEF_EQPT_POS_XIANGLIAN,
              ITEM_DEF_EQPT_POS_YAODAI,
              ITEM_DEF_EQPT_POS_GUANJIAN,
              ITEM_DEF_EQPT_POS_MIANJU,
              ITEM_DEF_EQPT_POS_PIFENG
            }) do
              local itemObj = mainHero:GetEqptByPos(tempPos)
              if itemObj then
                local lv = itemObj:getProperty(ITEM_PRO_LV)
                local largeType = itemObj:getType()
                if largeType == ITEM_LARGE_TYPE_SENIOREQPT and lv == 1 then
                  getCurSceneView():addSubView({
                    subView = CZhuangbeiShow.new({
                      InitItemId = itemObj:getObjId(),
                      InitRoleId = self.m_CurChoosedHeroIns:getObjId(),
                      InitUpgradeType = Eqpt_Upgrade_CreateType
                    }),
                    zOrder = MainUISceneZOrder.menuView
                  })
                  self:CloseEquipDetail()
                  return
                end
              end
            end
            ShowNotifyTips("无可升级装备")
            self:CloseEquipDetail()
            return
          end
        elseif data_getIsXianQiJZ(itemShapeTypeId) and itemShapeTypeId == data_getUpgradeXqNeedJZ(mainHeroType, 2) then
          for _, tempPos in ipairs({
            ITEM_DEF_EQPT_POS_WUQI,
            ITEM_DEF_EQPT_POS_TOUKUI,
            ITEM_DEF_EQPT_POS_YIFU,
            ITEM_DEF_EQPT_POS_XIEZI,
            ITEM_DEF_EQPT_POS_XIANGLIAN,
            ITEM_DEF_EQPT_POS_YAODAI,
            ITEM_DEF_EQPT_POS_GUANJIAN,
            ITEM_DEF_EQPT_POS_MIANJU,
            ITEM_DEF_EQPT_POS_PIFENG
          }) do
            local itemObj = mainHero:GetEqptByPos(tempPos)
            if itemObj then
              local lv = itemObj:getProperty(ITEM_PRO_LV)
              local largeType = itemObj:getType()
              if largeType == ITEM_LARGE_TYPE_XIANQI and lv == 1 then
                getCurSceneView():addSubView({
                  subView = CZhuangbeiShow.new({
                    InitItemId = itemObj:getObjId(),
                    InitRoleId = self.m_CurChoosedHeroIns:getObjId(),
                    InitUpgradeType = Eqpt_Upgrade_CreateType
                  }),
                  zOrder = MainUISceneZOrder.menuView
                })
                self:CloseEquipDetail()
                return
              end
            end
          end
          ShowNotifyTips("无可升级仙器")
          self:CloseEquipDetail()
          return
        end
        local initLargeType = ITEM_LARGE_TYPE_SENIOREQPT
        if data_getIsXianQiJZ(itemShapeTypeId) or itemShapeTypeId == ITEM_DEF_STUFF_XQSP or itemShapeTypeId == ITEM_DEF_STUFF_XY then
          initLargeType = ITEM_LARGE_TYPE_XIANQI
        end
        local tempView = CCreateZhuangbei.new({
          InitLargeType = initLargeType,
          closeCallBack = function()
            self:ShowSelf()
          end,
          forRoleId = self.m_CurChoosedHeroIns:getObjId()
        })
        getCurSceneView():addSubView({
          subView = tempView,
          zOrder = MainUISceneZOrder.menuView
        })
        self:HideSelf()
        return
      elseif itemType == ITEM_LARGE_TYPE_DRUG then
        if JudgeIsInWar() then
          ShowNotifyTips("自动战斗不能使用药品。")
          self:CloseEquipDetail()
          return
        end
        local mainHero = g_LocalPlayer:getMainHero()
        local drugData = data_Drug[itemShapeTypeId]
        local addHPValue = drugData.drugAddHPValue
        local addMPValue = drugData.drugAddMPValue
        if addHPValue == 0 then
          addHPValue = math.floor(mainHero:getMaxProperty(PROPERTY_HP) * drugData.drugAddHPPercent / 100)
        end
        if addMPValue == 0 then
          addMPValue = math.floor(mainHero:getMaxProperty(PROPERTY_MP) * drugData.drugAddMPPercent / 100)
        end
        local needAddHP = math.max(mainHero:getMaxProperty(PROPERTY_HP) - mainHero:getProperty(PROPERTY_HP), 0)
        local needAddMp = math.max(mainHero:getMaxProperty(PROPERTY_MP) - mainHero:getProperty(PROPERTY_MP), 0)
        if addHPValue > 0 and addMPValue > 0 then
          if needAddHP <= 0 and needAddMp <= 0 then
            ShowNotifyTips("血气值已满")
            self:CloseEquipDetail()
            return
          end
        elseif addHPValue > 0 then
          if needAddHP <= 0 then
            ShowNotifyTips("血气值已满")
            self:CloseEquipDetail()
            return
          end
        elseif needAddMp <= 0 then
          ShowNotifyTips("法力值已满")
          self:CloseEquipDetail()
          return
        end
        netsend.netitem.requestUseDrugOutOfWar(g_LocalPlayer:getMainHeroId(), itemId, math.min(addHPValue, needAddHP), math.min(addMPValue, needAddMp))
        return
      elseif itemShapeTypeId == ITEM_DEF_OTHER_XMS then
        do
          local roleId = self.m_CurChoosedHeroIns:getObjId()
          local xiFlag = false
          local lv = self.m_CurChoosedHeroIns:getProperty(PROPERTY_ROLELEVEL)
          for _, k in pairs({
            PROPERTY_OGenGu,
            PROPERTY_OLiLiang,
            PROPERTY_OMinJie,
            PROPERTY_OLingxing
          }) do
            local pts = self.m_CurChoosedHeroIns:getProperty(k)
            if lv < pts then
              xiFlag = true
              break
            end
          end
          if not xiFlag then
            ShowNotifyTips("你的主角目前不需要使用该物品")
            return
          end
          local function func2()
            netsend.netitem.requestUseItem(itemId, roleId)
            ShowWarningInWar()
          end
          local tempPop = CPopWarning.new({
            title = "提示",
            text = string.format("你确定要使用#<G>%s#重置角色的加点吗？", data_getItemName(ITEM_DEF_OTHER_XMS)),
            confirmFunc = func2,
            align = CRichText_AlignType_Left,
            cancelFunc = nil,
            closeFunc = nil,
            confirmText = "确定",
            cancelText = "取消"
          })
          tempPop:ShowCloseBtn(false)
          self:CloseEquipDetail()
          return
        end
      elseif itemType == ITEM_LARGE_TYPE_NEIDAN then
        local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
        if #petIds > 0 then
          local tempView = CPetList.new(PetShow_InitShow_NeidanView, nil, function()
            self:ShowSelf()
          end)
          getCurSceneView():addSubView({
            subView = tempView,
            zOrder = MainUISceneZOrder.menuView
          })
          tempView.m_PageItemList.m_PackageFrame:JumpToItemPage(itemId, false)
          self:HideSelf()
        else
          ShowNotifyTips("没有召唤兽,无法使用")
        end
        return
      elseif itemShapeTypeId == ITEM_DEF_OTHER_GJJLL or itemShapeTypeId == ITEM_DEF_OTHER_CJJLL then
        local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
        if #petIds > 0 then
          local tempView = CPetList.new(PetShow_InitShow_XiChongView, nil, function()
            self:ShowSelf()
          end)
          getCurSceneView():addSubView({
            subView = tempView,
            zOrder = MainUISceneZOrder.menuView
          })
          self:HideSelf()
        else
          ShowNotifyTips("没有召唤兽,无法使用")
        end
        return
      elseif itemType == ITEM_LARGE_TYPE_LIANYAOSHI then
        local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
        if #petIds > 0 then
          local tempView = CPetList.new(PetShow_InitShow_LianYaoView, nil, function()
            self:ShowSelf()
          end)
          getCurSceneView():addSubView({
            subView = tempView,
            zOrder = MainUISceneZOrder.menuView
          })
          if tempView.m_PageLianYaoList then
            tempView.m_PageLianYaoList:OnBtn_SelectLYS()
          end
          self:HideSelf()
        else
          ShowNotifyTips("没有召唤兽,无法使用")
        end
        return
      elseif itemType == ITEM_LARGE_TYPE_GIFT then
        netsend.netitem.requestUseItem(itemId)
        return
      elseif itemShapeTypeId == ITEM_DEF_OTHER_SBD then
        UseDoubleExpItem(itemId)
        return
      elseif itemType == ITEM_LARGE_TYPE_LIFEITEM then
        if data_getLifeSkillType(itemShapeTypeId) == IETM_DEF_LIFESKILL_DRUG then
          if JudgeIsInWar() then
            ShowNotifyTips("自动战斗不能使用药品。")
            self:CloseEquipDetail()
            return
          end
          local mainHero = g_LocalPlayer:getMainHero()
          local drugData = data_LifeSkill_Drug[itemShapeTypeId]
          local addHPValue = drugData.AddHp
          local addMPValue = drugData.AddMp
          local needAddHP = math.max(mainHero:getMaxProperty(PROPERTY_HP) - mainHero:getProperty(PROPERTY_HP), 0)
          local needAddMp = math.max(mainHero:getMaxProperty(PROPERTY_MP) - mainHero:getProperty(PROPERTY_MP), 0)
          if addHPValue > 0 and addMPValue > 0 then
            if needAddHP <= 0 and needAddMp <= 0 then
              ShowNotifyTips("血气值已满")
              self:CloseEquipDetail()
              return
            end
          elseif addHPValue > 0 then
            if needAddHP <= 0 then
              ShowNotifyTips("血气值已满")
              self:CloseEquipDetail()
              return
            end
          elseif needAddMp <= 0 then
            ShowNotifyTips("法力值已满")
            self:CloseEquipDetail()
            return
          end
          netsend.netitem.requestUseDrugOutOfWar(g_LocalPlayer:getMainHeroId(), itemId, math.min(addHPValue, needAddHP), math.min(addMPValue, needAddMp))
          return
        elseif data_getLifeSkillType(itemShapeTypeId) == IETM_DEF_LIFESKILL_FOOD then
          netsend.netitem.requestUseItem(itemId)
          return
        else
          netsend.netitem.requestUseItem(itemId)
          self:CloseEquipDetail()
          return
        end
      elseif itemType == ITEM_LARGE_TYPE_STUFF then
        local useItemFlag = data_getStuffItemShowCanUseBtn(itemShapeTypeId)
        if useItemFlag == 2 then
          local lsID, lsLV = g_LocalPlayer:getBaseLifeSkill()
          if lsID == LIFESKILL_MAKEDRUG then
            ShowMakeLifeItem(lsID, function()
              self:ShowSelf()
            end)
            self:HideSelf()
            return
          end
        elseif useItemFlag == 3 then
          local lsID, lsLV = g_LocalPlayer:getBaseLifeSkill()
          if lsID == LIFESKILL_MAKEFU then
            ShowMakeLifeItem(lsID, function()
              self:ShowSelf()
            end)
            self:HideSelf()
            return
          end
        elseif useItemFlag == 4 then
          local lsID, lsLV = g_LocalPlayer:getBaseLifeSkill()
          if lsID == LIFESKILL_MAKEFOOD then
            ShowMakeLifeItem(lsID, function()
              self:ShowSelf()
            end)
            self:HideSelf()
            return
          end
        end
      else
        for _, tempItemShapeType in pairs(PackageUseItemList) do
          if tempItemShapeType == itemShapeTypeId then
            if tempItemShapeType == ITEM_DEF_OTHER_BPGP then
              if g_BpMgr:localPlayerHasBangPai() ~= true then
                ShowNotifyTips("加入帮派才能使用贡品")
              else
                netsend.netitem.requestUseItem(itemId)
                ShowWarningInWar()
              end
            elseif tempItemShapeType == ITEM_DEF_OTHER_GMC then
              self:CloseSelf()
              local tempView = settingDlg.new()
              getCurSceneView():addSubView({
                subView = tempView,
                zOrder = MainUISceneZOrder.menuView
              })
              if tempView.PanelPlayerInfo then
                tempView.PanelPlayerInfo:OnBtn_ReName()
              end
              return
            elseif tempItemShapeType == ITEM_DEF_OTHER_XPT or tempItemShapeType == ITEM_DEF_OTHER_PT or tempItemShapeType == ITEM_DEF_OTHER_PTW then
              local mainRole = g_LocalPlayer:getMainHero()
              local zs = mainRole:getProperty(PROPERTY_ZHUANSHENG)
              local lv = mainRole:getProperty(PROPERTY_ROLELEVEL)
              local canUseFlag = false
              for _, skillType in pairs(mainRole:getSkillTypeList()) do
                local skillList = data_getSkillListByAttr(skillType)
                for j = 1, 5 do
                  local skillID = skillList[j]
                  if j >= 3 then
                    local skillExp = mainRole:getProficiency(skillID)
                    local pLimit = data_getSkillExpLimitByZsAndLv(zs, lv)
                    if pLimit == nil then
                      pLimit = CalculateSkillProficiency(zs)
                    end
                    if skillExp < pLimit then
                      canUseFlag = true
                    end
                  end
                end
              end
              if canUseFlag == false then
                ShowNotifyTips("技能熟练度都已达上限,无需使用")
              else
                netsend.netitem.requestUseItem(itemId)
                ShowWarningInWar()
              end
            else
              netsend.netitem.requestUseItem(itemId)
            end
            return
          end
        end
        for _, tempItemShapeType in pairs(ZuoQiViewUseItemList) do
          if tempItemShapeType == itemShapeTypeId then
            local zqIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI) or {}
            if #zqIds > 0 then
              local tempView = CZuoqiShow.new(ZuoqiShow_ItemView, function()
                self:ShowSelf()
              end)
              self:HideSelf()
              getCurSceneView():addSubView({
                subView = tempView,
                zOrder = MainUISceneZOrder.menuView
              })
              self:HideSelf()
            else
              ShowNotifyTips("没有坐骑,无法使用")
            end
            return
          end
        end
        for _, tempItemShapeType in pairs(PetViewUseItemList) do
          if tempItemShapeType == itemShapeTypeId then
            local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
            if #petIds > 0 then
              local tempView = CPetList.new(PetShow_InitShow_ItemView, nil, function()
                self:ShowSelf()
              end)
              getCurSceneView():addSubView({
                subView = tempView,
                zOrder = MainUISceneZOrder.menuView
              })
              if itemShapeTypeId == ITEM_DEF_OTHER_HJD then
                tempView:OnBtn_Potential()
                tempView.m_PageItemList.m_PackageFrame:JumpToItemPage(itemId)
                self:HideSelf()
              else
                tempView.m_PageItemList.m_PackageFrame:JumpToItemPage(itemId, false)
                self:HideSelf()
              end
            else
              ShowNotifyTips("没有召唤兽,无法使用")
            end
            return
          end
        end
        if itemType == ITEM_LARGE_TYPE_OTHERITEM then
          local subType = GetItemSubTypeByItemTypeId(itemShapeTypeId)
          if subType == ITEM_DEF_TYPE_SKILLBOOK or itemShapeTypeId == ITEM_DEF_OTHER_LYF or itemShapeTypeId == ITEM_DEF_OTHER_JFS then
            local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
            if #petIds > 0 then
              local tempView = CPetList.new(PetShow_InitShow_SkillLearnView, nil, function()
                self:ShowSelf()
              end)
              getCurSceneView():addSubView({
                subView = tempView,
                zOrder = MainUISceneZOrder.menuView
              })
              tempView.m_PageItemList.m_PackageFrame:JumpToItemPage(itemId, false)
              self:HideSelf()
            else
              ShowNotifyTips("没有召唤兽,无法使用")
            end
            return
          elseif itemShapeTypeId == ITEM_DEF_OTHER_LSZY_CE or itemShapeTypeId == ITEM_DEF_OTHER_LSZY_JH or itemShapeTypeId == ITEM_DEF_OTHER_LSZY_YM or itemShapeTypeId == ITEM_DEF_OTHER_LSZY_GZ or itemShapeTypeId == ITEM_DEF_OTHER_LSZY_TW then
            self:CloseSelf()
            do
              local npcId = 90026
              local function route_cb(isSucceed)
                if isSucceed and CMainUIScene.Ins then
                  CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
                end
              end
              g_MapMgr:AutoRouteToNpc(npcId, route_cb)
            end
          end
        end
      end
    end
  end
  print("该物品的使用功能还没开发")
end
function CMainRoleView:OnSendItem(itemId)
  if g_FriendsMgr and g_FriendsMgr:getFriendNum() > 0 then
    ShowYouHaoDuView()
  else
    ShowNotifyTips("你当前没有好友，无法使用")
  end
  if self.m_EquipDetail then
    self.m_EquipDetail:CloseSelf()
  end
end
function CMainRoleView:SetMoney()
  local player = g_DataMgr:getPlayer()
  local x, y = self:getNode("box_gold"):getPosition()
  local z = self:getNode("box_gold"):getZOrder()
  local size = self:getNode("box_gold"):getSize()
  self:getNode("box_gold"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_SILVER))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  local x, y = self:getNode("box_coin"):getPosition()
  local z = self:getNode("box_coin"):getZOrder()
  local size = self:getNode("box_coin"):getSize()
  self:getNode("box_coin"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self:updateGoldNum()
end
function CMainRoleView:updateGoldNum()
  local player = g_DataMgr:getPlayer()
  self:getNode("text_gold"):setText(string.format("%d", player:getSilver()))
  AutoLimitObjSize(self:getNode("text_gold"), 92)
  self:getNode("text_coin"):setText(string.format("%d", player:getCoin()))
  AutoLimitObjSize(self:getNode("text_coin"), 92)
end
function CMainRoleView:OnBtn_KangxingView()
  if self.m_AddPointDlg then
    self.m_AddPointDlg:CloseSelf()
    self.m_AddPointDlg = nil
  end
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:CloseSelf()
    self.m_KangXingViewObj = nil
    return
  end
  local function closeFunc()
    self.m_KangXingViewObj = nil
  end
  local tempView = CHuobanKangView.new({closeFunc = closeFunc})
  self:addSubView({subView = tempView, zOrder = 9999})
  local x, y = self:getNode("bg1"):getPosition()
  local iSize = self:getNode("bg1"):getContentSize()
  local bSize = tempView:getContentSize()
  tempView:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
  tempView:ReSetHeroData(self.m_CurChoosedHeroIns:getObjId())
  self.m_KangXingViewObj = tempView
end
function CMainRoleView:OnAddPointClose()
  self.m_AddPointDlg = nil
end
function CMainRoleView:OnBtn_AddMoney()
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CMainRoleView:OnBtn_AddSilver()
  ShowRechargeView({resType = RESTYPE_SILVER})
end
function CMainRoleView:OnBtn_Zhengli()
  local curTime = cc.net.SocketTCP.getTime()
  local temp = 6
  if self.m_LastZhengliTime ~= nil then
    temp = curTime - self.m_LastZhengliTime
  end
  local temp = math.floor(temp)
  if temp < 5 then
    local tips = string.format("你刚刚已经进行过整理，请隔%d秒再试", 5 - temp)
    ShowNotifyTips(tips)
    return
  else
    self.m_LastZhengliTime = curTime
    netsend.netitem.requestZhengliPackage()
  end
end
function CMainRoleView:OnBtn_GongLue()
  local popView = CRechargeNotice.new()
  getCurSceneView():addSubView({
    subView = popView,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMainRoleView:OnBtn_ZhengliCk()
  local curTime = cc.net.SocketTCP.getTime()
  local temp = 6
  if self.m_LastZhengliCangkuTime ~= nil then
    temp = curTime - self.m_LastZhengliCangkuTime
  end
  local temp = math.floor(temp)
  if temp < 5 then
    local tips = string.format("你刚刚已经进行过整理，请隔%d秒再试", 5 - temp)
    ShowNotifyTips(tips)
    return
  else
    self.m_LastZhengliCangkuTime = curTime
    netsend.netcangku.reqZhengliCangku()
  end
end
function CMainRoleView:OnBtn_Table_Beibao()
  self:ShowTableView(MainRole_Beibao_Page)
end
function CMainRoleView:OnBtn_Table_Cangku()
  self:ShowTableView(MainRole_Cangku_Page)
end
function CMainRoleView:OnBtn_Table_FaBao()
  self:ShowTableView(self.m_ShowingPageNum)
  if g_FabaoRelease ~= true then
    ShowNotifyTips("法宝功能即将开启")
    return
  end
  if g_LocalPlayer == nil then
    return
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_FaBao)
  if openFlag == false then
    if noOpenType == OPEN_FUNC_Type_Gray then
      ShowNotifyTips(tips)
    end
    return
  end
  self:CloseSelf()
end
function CMainRoleView:ShowTableView(pageNum)
  if pageNum == MainRole_Beibao_Page then
    self.m_Page_Beibao:setEnabled(true)
    self.m_Page_Cangku:setEnabled(false)
    self:setGroupBtnSelected(self.btn_table1)
    self:getNode("title"):setVisible(true)
    self:getNode("title_0"):setVisible(true)
    self:getNode("title_1"):setVisible(false)
    if self.m_CangkuView then
      self.m_CangkuView:setVisible(false)
      self.m_CangkuView:setEnabled(false)
    end
  elseif pageNum == MainRole_Cangku_Page then
    self.m_Page_Beibao:setEnabled(false)
    self.m_Page_Cangku:setEnabled(true)
    self:setGroupBtnSelected(self.btn_table2)
    self:getNode("title"):setVisible(false)
    self:getNode("title_0"):setVisible(false)
    self:getNode("title_1"):setVisible(true)
    if self.m_CangkuView then
      self.m_CangkuView:setVisible(true)
      self.m_CangkuView:setEnabled(true)
    end
  end
  self.m_ShowingPageNum = pageNum
end
function CMainRoleView:InitCangkuView()
  self:getNode("pos_ck"):setVisible(false)
  tempView = CCangkuView.new({}, self)
  self.m_CangkuView = tempView
  self:addChild(tempView.m_UINode)
  local x, y = self:getNode("pos_ck"):getPosition()
  local xb, yb = self:getNode("layer_ck"):getPosition()
  tempView:setPosition(ccp(x + xb, y + yb))
end
function CMainRoleView:InitCangkuTips()
  self:getNode("pos_ck_tips"):setVisible(false)
  local x, y = self:getNode("pos_ck_tips"):getPosition()
  local size = self:getNode("pos_ck_tips"):getContentSize()
  local tipTxt = CRichText.new({
    width = size.width,
    fontSize = 16
  })
  tipTxt:addRichText("#<IRP,CTP>移动物品直接双击操作#")
  tipTxt:setPosition(ccp(x, y + size.height / 2))
  self.m_Page_Cangku:addChild(tipTxt)
end
function CMainRoleView:ShowWingTips()
  local wgg = self.m_CurChoosedHeroIns:getProperty(PROPERTY_Wing_GenGu)
  local wlx = self.m_CurChoosedHeroIns:getProperty(PROPERTY_Wing_Lingxing)
  local wll = self.m_CurChoosedHeroIns:getProperty(PROPERTY_Wing_LiLiang)
  local wmj = self.m_CurChoosedHeroIns:getProperty(PROPERTY_Wing_MinJie)
  if self.m_Old_Wing_GenGu and wgg > self.m_Old_Wing_GenGu then
    ShowNotifyTips(string.format("翅膀加成,根骨+%d", wgg))
  end
  if self.m_Old_Wing_Lingxing and wlx > self.m_Old_Wing_Lingxing then
    ShowNotifyTips(string.format("翅膀加成,灵性+%d", wlx))
  end
  if self.m_Old_Wing_LiLiang and wll > self.m_Old_Wing_LiLiang then
    ShowNotifyTips(string.format("翅膀加成,力量+%d", wll))
  end
  if self.m_Old_Wing_MinJie and wmj > self.m_Old_Wing_MinJie then
    ShowNotifyTips(string.format("翅膀加成,敏捷+%d", wmj))
  end
  self.m_Old_Wing_GenGu = wgg
  self.m_Old_Wing_Lingxing = wlx
  self.m_Old_Wing_LiLiang = wll
  self.m_Old_Wing_MinJie = wmj
end
function CMainRoleView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CMainRoleView:OnMessage(msgSID, ...)
  if self.m_UINode == nil then
    return
  end
  local arg = {
    ...
  }
  local hid = self.m_CurChoosedHeroIns:getObjId()
  if msgSID == MsgID_HeroUpdate then
    local d = arg[1]
    if d.heroId == hid then
      self:ReflushBaseInfo()
    end
    self:ShowWingTips()
  elseif msgSID == MsgID_ItemInfo_TakeEquip then
    local roleId, itemId = arg[1], arg[2]
    if roleId ~= hid then
      return
    end
    self:ReflushCurrEquipInfo()
    self:ReflushProData()
    if g_PackageZBView == nil and g_ZhuangbeiView == nil then
      soundManager.playSound("xiyou/sound/takeup_equip.wav")
      ShowWarningInWar()
    end
    if self.m_EquipDetail ~= nil and self.m_EquipDetail:getItemObjId() == itemId then
      self:CloseEquipDetail()
    end
  elseif msgSID == MsgID_ItemInfo_TakeDownEquip then
    local roleId, itemId = arg[1], arg[2]
    if roleId ~= hid then
      return
    end
    self:ReflushCurrEquipInfo()
    self:ReflushProData()
    if self.m_TakeDownEquip_Sound ~= false and g_PackageZBView == nil and g_ZhuangbeiView == nil then
      soundManager.playSound("xiyou/sound/takedown_equip.wav")
      ShowWarningInWar()
    end
    if self.m_EquipDetail ~= nil and self.m_EquipDetail:getItemObjId() == itemId then
      self:CloseEquipDetail()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local tempId = arg[1]
    if self.m_EquipDetail ~= nil and self.m_EquipDetail.getItemObjId and self.m_EquipDetail:getItemObjId() == tempId then
      self:CloseEquipDetail()
    end
  elseif msgSID == MsgID_ItemInfo_ItemUpdate then
    local tempPara = arg[1]
    local tempItemId = tempPara.itemId
    if tempItemId == nil then
      return
    end
    local tempItemIns = g_LocalPlayer:GetOneItem(tempItemId)
    if tempItemIns == nil then
      return
    end
    local tempRoleId = g_LocalPlayer:GetRoleIdFromItem(tempItemId)
    if tempRoleId ~= hid then
      return
    end
    self:ReflushProData()
    self:ReflushCurrEquipInfo()
  elseif msgSID == MsgID_DeletePet then
    self:ReflushBaseInfo()
  elseif msgSID == MsgID_MoneyUpdate then
    self:updateGoldNum()
  elseif msgSID == MsgID_ItemSource_Jump then
    if self.m_EquipDetail and self.m_EquipDetail.__cname == "m_EquipDetail" then
    else
      self:CloseEquipDetail()
    end
    local arg = {
      ...
    }
    local d = arg[1][1]
    for _, t in pairs(Item_Source_MoveMapList) do
      if d == t then
        self:CloseSelf()
        break
      end
    end
  elseif msgSID == MsgID_WarScene_ViewHpMpChanged then
    local curHeroId = self.m_CurChoosedHeroIns:getObjId()
    if arg[1] == g_LocalPlayer:getPlayerId() and arg[2] == curHeroId then
      self:ReflushProData()
    end
  elseif msgSID == MsgID_Scene_War_Exit then
    self:ReflushProData()
  end
end
function CMainRoleView:HideSelf()
  if self.m_UINode == nil then
    return
  end
  self:setVisible(false)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
  end
end
function CMainRoleView:ShowSelf()
  if self.m_UINode == nil then
    return
  end
  self:setVisible(true)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(true)
  end
end
function CMainRoleView:Clear()
  print("CMainRoleView  clear")
  self:CloseEquipDetail()
  if g_MainRoleView == self then
    g_MainRoleView = nil
  end
end
CCangkuView = class("CCangkuView", CcsSubView)
function CCangkuView:ctor(para, MainRoleViewObj)
  CCangkuView.super.ctor(self, "views/huoban_package.json")
  local jumpToItemId = para.jumpToItemId or nil
  self.m_MainRoleViewObj = MainRoleViewObj
  self.layer_itemlist = self:getNode("layer_itemlist")
  self.layer_itemlist:setVisible(false)
  local x, y = self.layer_itemlist:getPosition()
  local z = self.layer_itemlist:getZOrder()
  local isNeedToAddGrid = true
  local needToLockPage = PackageLockPage
  local param = {
    xySpace = ccp(0, 0),
    itemSize = CCSize(84, 84),
    pageLines = 4,
    oneLineNum = 5,
    xySpace = ccp(0, 0),
    pageIconOffY = -25
  }
  self.m_CangkuView = CCangkuFrame.new(nil, function(itemObjId)
    if self.m_MainRoleViewObj then
      self.m_MainRoleViewObj:ShowPackageDetail(itemObjId, ClickFromCangku)
    end
  end, nil, param, nil, nil, nil, nil, ExPackageGetCanNotUseFunc, nil, nil, nil)
  self.m_CangkuView:setPosition(ccp(x, y))
  self:addChild(self.m_CangkuView, z + 100)
  self.m_CangkuView:JumpToItemPage(jumpToItemId)
end
function CCangkuView:Clear()
  self.m_MainRoleViewObj = nil
end
CPackageView = class("CPackageView", CcsSubView)
function CPackageView:ctor(para, MainRoleViewObj)
  CPackageView.super.ctor(self, "views/huoban_package.json")
  local jumpToItemId = para.jumpToItemId or nil
  self.m_MainRoleViewObj = MainRoleViewObj
  self.layer_itemlist = self:getNode("layer_itemlist")
  self.layer_itemlist:setVisible(false)
  local x, y = self.layer_itemlist:getPosition()
  local z = self.layer_itemlist:getZOrder()
  local isNeedToAddGrid = true
  local needToLockPage = PackageLockPage
  local param = {
    xySpace = ccp(0, 0),
    itemSize = CCSize(84, 84),
    pageLines = 4,
    oneLineNum = 4,
    xySpace = ccp(0, 0),
    pageIconOffY = -25
  }
  self.m_PackageFrame = CPackageFrame.new(nil, function(itemObjId)
    if self.m_MainRoleViewObj then
      self.m_MainRoleViewObj:ShowPackageDetail(itemObjId, ClickFromBeibao)
    end
  end, nil, param, nil, nil, nil, nil, ExPackageGetCanNotUseFunc, isNeedToAddGrid, needToLockPage)
  self.m_PackageFrame:setPosition(ccp(x, y))
  self:addChild(self.m_PackageFrame, z + 100)
  self.m_PackageFrame:JumpToItemPage(jumpToItemId)
end
function CPackageView:Clear()
  self.m_MainRoleViewObj = nil
end
CSetWingView = class("CSetWingView", CcsSubView)
function CSetWingView:ctor(para, MainRoleViewObj)
  CSetWingView.super.ctor(self, "views/setwing.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_save = {
      listener = handler(self, self.OnBtn_Save),
      variName = "btn_save"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_gg = {
      listener = handler(self, self.OnBtn_SetGG),
      variName = "btn_gg"
    },
    btn_lx = {
      listener = handler(self, self.OnBtn_SetLX),
      variName = "btn_lx"
    },
    btn_ll = {
      listener = handler(self, self.OnBtn_SetLL),
      variName = "btn_ll"
    },
    btn_mj = {
      listener = handler(self, self.OnBtn_SetMJ),
      variName = "btn_mj"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("txt_title"):setText("选择翅膀属性")
  self.m_CurWingPro = nil
  self.m_SelectProName = nil
  self:SetCurPro()
end
function CSetWingView:SetCurPro()
  if g_LocalPlayer then
    local mainHero = g_LocalPlayer:getMainHero()
    if mainHero then
      local gg = mainHero:getProperty(PROPERTY_Wing_GenGu)
      local lx = mainHero:getProperty(PROPERTY_Wing_Lingxing)
      local ll = mainHero:getProperty(PROPERTY_Wing_LiLiang)
      local mj = mainHero:getProperty(PROPERTY_Wing_MinJie)
      if gg ~= 0 then
        self.m_CurWingPro = "gg"
      elseif lx ~= 0 then
        self.m_CurWingPro = "lx"
      elseif ll ~= 0 then
        self.m_CurWingPro = "ll"
      elseif mj ~= 0 then
        self.m_CurWingPro = "mj"
      end
    end
  end
  if self.m_CurWingPro ~= nil then
    local tag = 99999
    local btn = self[string.format("btn_%s", self.m_CurWingPro)]
    local tempSprite = display.newSprite("views/common/btn/selected.png")
    tempSprite:setAnchorPoint(ccp(-0.2, -0.3))
    btn:getVirtualRenderer():addChild(tempSprite, 1, tag)
  end
  self.m_SelectProName = self.m_CurWingPro
end
function CSetWingView:SelectPro(proName)
  local tag = 99999
  for _, tempPro in pairs({
    "gg",
    "lx",
    "ll",
    "mj"
  }) do
    local btn = self[string.format("btn_%s", tempPro)]
    if tempPro == proName then
      local oldChild = btn:getVirtualRenderer():getChildByTag(tag)
      if oldChild == nil then
        local tempSprite = display.newSprite("views/common/btn/selected.png")
        tempSprite:setAnchorPoint(ccp(-0.2, -0.3))
        btn:getVirtualRenderer():addChild(tempSprite, 1, tag)
      end
    else
      local oldChild = btn:getVirtualRenderer():getChildByTag(tag)
      if oldChild ~= nil then
        btn:getVirtualRenderer():removeChild(oldChild)
      end
    end
  end
  self.m_SelectProName = proName
end
function CSetWingView:OnBtn_SetGG(btnObj, touchType)
  self:SelectPro("gg")
end
function CSetWingView:OnBtn_SetLX(btnObj, touchType)
  self:SelectPro("lx")
end
function CSetWingView:OnBtn_SetLL(btnObj, touchType)
  self:SelectPro("ll")
end
function CSetWingView:OnBtn_SetMJ(btnObj, touchType)
  self:SelectPro("mj")
end
function CSetWingView:OnBtn_Save(btnObj, touchType)
  if self.m_SelectProName == nil then
    ShowNotifyTips("请先选择翅膀的属性类型")
    return
  end
  if self.m_CurWingPro == self.m_SelectProName then
    self:CloseSelf()
    return
  end
  local i_t = 0
  if self.m_SelectProName == "lx" then
    i_t = 1
  elseif self.m_SelectProName == "ll" then
    i_t = 2
  elseif self.m_SelectProName == "mj" then
    i_t = 3
  elseif self.m_SelectProName == "gg" then
    i_t = 4
  end
  if i_t ~= 0 then
    netsend.netbaseptc.requestSetWingPro(i_t)
    ShowWarningInWar()
    self:CloseSelf()
  end
end
function CSetWingView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CSetWingView:Clear()
end
CRechargeNotice = class("CRechargeNotice", CcsSubView)
function CRechargeNotice:ctor()
  CRechargeNotice.super.ctor(self, "views/recharge_notice.json", {isAutoCenter = true, opacityBg = 0})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
end
function CRechargeNotice:Btn_Close(obj, t)
  self:CloseSelf()
end
function CRechargeNotice:Clear()
end
