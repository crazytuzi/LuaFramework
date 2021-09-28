function GetHuobanEqptShape(itemIns, roleIns)
  local tempShape = itemIns:getProperty(ITEM_PRO_SHAPE)
  if tempShape ~= nil and tempShape ~= 0 then
    return tempShape
  end
  local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
  local eqptPos = EPQT_TYPE_2_EQPT_POS[eqptType]
  local largeType = itemIns:getType()
  local race = roleIns:getProperty(PROPERTY_RACE)
  local gender = roleIns:getProperty(PROPERTY_GENDER)
  if eqptPos == ITEM_DEF_EQPT_POS_WUQI then
    if race == RACE_REN and gender == HERO_MALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_JIAN_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_JIAN_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_JIAN_3
      end
    elseif race == RACE_REN and gender == HERO_FEMALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_DAO_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_DAO_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_DAO_3
      end
    elseif race == RACE_MO and gender == HERO_MALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_FU_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_FU_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_FU_3
      end
    elseif race == RACE_MO and gender == HERO_FEMALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_ZHUA_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_ZHUA_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_ZHUA_3
      end
    elseif race == RACE_XIAN and gender == HERO_MALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_QIANG_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_QIANG_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_QIANG_3
      end
    elseif race == RACE_XIAN and gender == HERO_FEMALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_SIDAI_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_SIDAI_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_SIDAI_3
      end
    elseif race == RACE_GUI and gender == HERO_MALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NANGUI_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NANGUI_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NANGUI_3
      end
    elseif race == RACE_GUI and gender == HERO_FEMALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NVGUI_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NVGUI_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NVGUI_3
      end
    end
  elseif eqptPos == ITEM_DEF_EQPT_POS_TOUKUI then
    if gender == HERO_MALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NAN_MAOZI_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NAN_MAOZI_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NAN_MAOZI_3
      end
    elseif gender == HERO_FEMALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NV_MAOZI_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NV_MAOZI_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NV_MAOZI_3
      end
    end
  elseif eqptPos == ITEM_DEF_EQPT_POS_YIFU then
    if gender == HERO_MALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NAN_YIFU_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NAN_YIFU_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NAN_YIFU_3
      end
    elseif gender == HERO_FEMALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NV_YIFU_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NV_YIFU_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NV_YIFU_3
      end
    end
  elseif eqptPos == ITEM_DEF_EQPT_POS_XIEZI then
    if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      return ITEM_HBZH_XIEZI_1
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      return ITEM_HBZH_XIEZI_2
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      return ITEM_HBZH_XIEZI_3
    end
  elseif eqptPos == ITEM_DEF_EQPT_POS_XIANGLIAN then
    if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      return ITEM_HBZH_XIANGLIAN_1
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      return ITEM_HBZH_XIANGLIAN_2
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      return ITEM_HBZH_XIANGLIAN_3
    end
  elseif eqptPos == ITEM_DEF_EQPT_POS_YAODAI then
    if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      return ITEM_HBZH_YAODAI_1
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      return ITEM_HBZH_YAODAI_2
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      return ITEM_HBZH_YAODAI_3
    end
  elseif eqptPos == ITEM_DEF_EQPT_POS_GUANJIAN then
    if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      return ITEM_HBZH_GUAJIAN_1
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      return ITEM_HBZH_GUAJIAN_2
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      return ITEM_HBZH_GUAJIAN_3
    end
  elseif eqptPos == ITEM_DEF_EQPT_POS_MIANJU then
    if gender == HERO_MALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NAN_MIANJU_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NAN_MIANJU_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NAN_MIANJU_3
      end
    elseif gender == HERO_FEMALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NV_MIANJU_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NV_MIANJU_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NV_MIANJU_3
      end
    end
  elseif eqptPos == ITEM_DEF_EQPT_POS_PIFENG then
    if gender == HERO_MALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NAN_PIFENG_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NAN_PIFENG_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NAN_PIFENG_3
      end
    elseif gender == HERO_FEMALE then
      if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
        return ITEM_HBZH_NV_PIFENG_1
      elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
        return ITEM_HBZH_NV_PIFENG_2
      elseif largeType == ITEM_LARGE_TYPE_XIANQI then
        return ITEM_HBZH_NV_PIFENG_3
      end
    end
  end
  return data_getItemShapeID(itemIns:getTypeId())
end
function GetHuobanEqptName(itemIns)
  local tempName = itemIns:getProperty(ITEM_PRO_NAME)
  if tempName ~= nil and tempName ~= 0 and tempName ~= "" then
    return tempName
  end
  local eqptType = itemIns:getProperty(ITEM_PRO_EQPT_TYPE)
  local lv = itemIns:getProperty(ITEM_PRO_LV)
  local largeType = itemIns:getType()
  local eqptPos = EPQT_TYPE_2_EQPT_POS[eqptType]
  local posName = EPQT_POS_2_EQPT_POSNAME[eqptPos]
  if posName ~= "" then
    if largeType == ITEM_LARGE_TYPE_EQPT or largeType == ITEM_LARGE_TYPE_HUOBANEQPT then
      local needLv = data_getItemLvLimit(2100130 + lv - 1)
      if needLv == 0 then
        if lv == 1 then
          needLv = 1
        elseif lv == 2 then
          needLv = 25
        elseif lv == 3 then
          needLv = 50
        end
      end
      return string.format("%d级%s之魂", needLv, posName)
    elseif largeType == ITEM_LARGE_TYPE_SENIOREQPT then
      return string.format("%d级高级%s之魂", lv, posName)
    elseif largeType == ITEM_LARGE_TYPE_XIANQI then
      return string.format("%d级仙器%s之魂", lv, posName)
    end
  end
  return itemIns:getProperty(ITEM_PRO_NAME)
end
function _huobanSortFunc(id_a, id_b)
  if id_a == nil or id_b == nil then
    return false
  end
  local hero_a = g_LocalPlayer:getObjById(id_a)
  local hero_b = g_LocalPlayer:getObjById(id_b)
  if hero_a == nil then
    return false
  elseif hero_b == nil then
    return true
  end
  if g_LocalPlayer ~= nil then
    if hero_a == g_LocalPlayer:getMainHero() then
      return true
    elseif hero_b == g_LocalPlayer:getMainHero() then
      return false
    end
  end
  local inWarFlag_a = false
  local inWarFlag_b = false
  local warsetting = g_LocalPlayer:getWarSetting()
  for index, pos in ipairs({
    3,
    2,
    4,
    1,
    5
  }) do
    if warsetting[pos] == id_a then
      inWarFlag_a = true
    end
    if warsetting[pos] == id_b then
      inWarFlag_b = true
    end
  end
  if inWarFlag_a == true and inWarFlag_b == false then
    return true
  elseif inWarFlag_b == true and inWarFlag_a == false then
    return false
  end
  local openindex_a = -1
  local openindex_b = -1
  local mainHero = g_LocalPlayer:getMainHero()
  local zsList = mainHero:getProperty(PROPERTY_ZSTYPELIST)
  if type(zsList) ~= "table" then
    zsList = {}
  end
  local mainHeroType = zsList[1] or 0
  if mainHeroType == 0 then
    mainHeroType = mainHero:getTypeId()
  end
  local shapeList = data_getAllJiuguanRole(mainHeroType)
  for index, shape in ipairs(shapeList) do
    if shape == hero_a:getTypeId() then
      openindex_a = index
    end
    if shape == hero_b:getTypeId() then
      openindex_b = index
    end
  end
  if openindex_a ~= openindex_b then
    return openindex_a > openindex_b
  end
  return id_a < id_b
end
CHuobanList = class("CHuobanList", CcsSubView)
function CHuobanList:ctor(para)
  CHuobanList.super.ctor(self, "views/huoban_list.json")
  clickArea_check.extend(self)
  self.m_ViewPara = para or {}
  self.m_InitHuobanId = para.huobanID
  self.m_InitSubViewNum = para.subViewNum or HuobanShow_InitShow_SkillView
  self.m_CurChoosedHeroIns = nil
  self.m_CurChooseRightViewNum = nil
  self:SetBtns()
  self:SetList()
  self:SetRightViews()
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_WarSetting)
  self:ListenMessage(MsgID_MoveScene)
  self:ListenMessage(MsgID_WarScene)
  self:ListenMessage(MsgID_Scene)
end
function CHuobanList:SetAttrTips()
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
end
function CHuobanList:getRoleRace()
  if self.m_CurChoosedHeroIns == nil then
    return RACE_REN
  else
    return self.m_CurChoosedHeroIns:getProperty(PROPERTY_RACE)
  end
end
function CHuobanList:SetBtns()
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_kangxingview = {
      listener = handler(self, self.OnBtn_KangxingView),
      variName = "btn_kangxingview"
    },
    btn_war = {
      listener = handler(self, self.OnBtn_War),
      variName = "btn_war"
    },
    btn_setpoint = {
      listener = handler(self, self.OnBtn_SetPoint),
      variName = "btn_setpoint"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
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
function CHuobanList:SetList()
  self.list_role = self:getNode("list_role")
  self.pic_arrow_down = self:getNode("pic_arrow_down")
  self:ReloadAllRoles()
  self.list_role:addTouchItemListenerListView(function(item, index, listObj)
    local heroId = item:getRoleId()
    self:ChooseItemByHeroId(heroId)
  end)
  self:ChooseItemByHeroId(self.m_InitHuobanId)
end
function CHuobanList:SetRightViews()
  self:getNode("subviewPos"):setVisible(false)
  self.m_HuobanPackageView = nil
  self.m_HuobanSkillView = nil
  self:SelectRightView(self.m_InitSubViewNum)
end
function CHuobanList:ReflushBaseInfo()
  self:ReflushRoleShape()
  self:ReflushProData()
  self:ReflushCurrEquipInfo()
  if self.m_HuobanSkillView then
    self.m_HuobanSkillView:ReSetHeroData(self.m_CurChoosedHeroIns:getObjId())
  end
  self:SelectRightView(self.m_CurChooseRightViewNum)
  self:UpdateWarBtnText()
end
function CHuobanList:ReflushRoleShape()
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
    do
      local tempRoleAni
      if self.m_RoleAni ~= nil then
        tempRoleAni = self.m_RoleAni
      end
      local offx, offy = 0, 0
      self.m_RoleAni, offx, offy = createBodyByShapeForDlg(shape)
      parent:addNode(self.m_RoleAni, z + 10)
      self.m_RoleAni:setPosition(x + offx, y + offy)
      self:addclickAniForHeroAni(self.m_RoleAni, self.role_aureole)
      if tempRoleAni ~= nil then
        self.m_RoleAni:setVisible(false)
        local act1 = CCDelayTime:create(0.01)
        local act2 = CCCallFunc:create(function()
          if tempRoleAni._addClickWidget then
            tempRoleAni._addClickWidget:removeFromParentAndCleanup(true)
            tempRoleAni._addClickWidget = nil
          end
          tempRoleAni:removeFromParentAndCleanup(true)
          self.m_RoleAni:setVisible(true)
          if self.m_RoleAni_War then
            self.m_RoleAni_War:setVisible(false)
          end
        end)
        self.m_RoleAni:runAction(transition.sequence({act1, act2}))
      end
    end
  elseif self.m_RoleAni ~= nil and self.m_RoleAni._shape == shape then
    self.m_RoleAni:playAniFromStart(-1)
    if self.m_RoleAni_War then
      self.m_RoleAni_War:setVisible(false)
    end
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
function CHuobanList:ReflushProData()
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
    local addNum = self.m_CurChoosedHeroIns:GetZhuangBeiAddNum(proType)
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
  local freeP = self.m_CurChoosedHeroIns:getProperty(PROPERTY_FREEPOINT)
  self.btn_setpoint:stopAllActions()
  self.btn_setpoint:setScale(1)
  if freeP > 0 then
    local dt = 0.5
    local act1 = CCScaleTo:create(dt, 1.1)
    local act2 = CCScaleTo:create(dt, 0.9)
    self.btn_setpoint:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
  end
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:ReSetHeroData(self.m_CurChoosedHeroIns:getObjId())
  end
end
function CHuobanList:CreateRightView(viewNum)
  local tempViewNameDict = {
    [HuobanShow_InitShow_PackageView] = "m_HuobanPackageView",
    [HuobanShow_InitShow_SkillView] = "m_HuobanSkillView"
  }
  local viewObj = self[tempViewNameDict[i]]
  if viewObj == nil then
    local tempView
    if viewNum == HuobanShow_InitShow_PackageView then
      tempView = CHuobanPackageView.new(self.m_ViewPara, self)
      self.m_HuobanPackageView = tempView
    elseif viewNum == HuobanShow_InitShow_SkillView then
      tempView = CHuobanSkillView.new(self.m_ViewPara)
      self.m_HuobanSkillView = tempView
      self.m_HuobanSkillView:ReSetHeroData(self.m_CurChoosedHeroIns:getObjId())
    end
    if tempView ~= nil then
      self:addChild(tempView.m_UINode)
      local x, y = self:getNode("subviewPos"):getPosition()
      tempView:setPosition(ccp(x, y))
    end
  end
end
function CHuobanList:SelectRightView(viewNum)
  if viewNum == nil then
    return
  end
  viewNum = HuobanShow_InitShow_SkillView
  local viewNumList = {HuobanShow_InitShow_PackageView, HuobanShow_InitShow_SkillView}
  local tempViewNameDict = {
    [HuobanShow_InitShow_PackageView] = "m_HuobanPackageView",
    [HuobanShow_InitShow_SkillView] = "m_HuobanSkillView"
  }
  local viewObj = self[tempViewNameDict[viewNum]]
  if viewObj == nil then
    self:CreateRightView(viewNum)
  end
  for _, i in pairs(viewNumList) do
    local viewObj = self[tempViewNameDict[i]]
    if viewObj ~= nil then
      viewObj:setVisible(i == viewNum)
      viewObj:setEnabled(i == viewNum)
    end
  end
  self.m_CurChooseRightViewNum = viewNum
end
function CHuobanList:ReloadAllRoles()
  self.list_role:removeAllItems()
  local lSize = self.list_role:getContentSize()
  local itemW = lSize.width
  local heroAmount = 0
  local heroIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
  table.sort(heroIds, _huobanSortFunc)
  for i, hid in ipairs(heroIds) do
    if hid ~= g_LocalPlayer:getMainHeroId() then
      local item = CHeroListHeadItem.new(hid, itemW)
      item:setChoosed(false)
      self.list_role:pushBackCustomItem(item)
      heroAmount = heroAmount + 1
    end
  end
  self:InitRoleListTouchEventListener(heroAmount)
  self:SetWarFlags()
end
function CHuobanList:SetWarFlags()
  local warsetting = g_LocalPlayer:getWarSetting()
  local cnt = self.list_role:getCount()
  for i = 0, cnt - 1 do
    local item = self.list_role:getItem(i)
    item:setShowIconFlag(false)
  end
  local tempInWarIdList = {}
  for _, warPos in ipairs({
    2,
    4,
    1,
    5
  }) do
    local warRoleId = warsetting[warPos]
    if warRoleId ~= nil and warRoleId ~= g_LocalPlayer:getMainHeroId() then
      tempInWarIdList[#tempInWarIdList + 1] = warRoleId
    end
  end
  table.sort(tempInWarIdList, _huobanSortFunc)
  for index, roleID in ipairs(tempInWarIdList) do
    self:SetWarRolePosInList(roleID, index)
  end
end
function CHuobanList:SetWarRolePosInList(roleId, index)
  local cnt = self.list_role:getCount()
  for i = 0, cnt - 1 do
    local item = self.list_role:getItem(i)
    if item:getRoleId() == roleId then
      if index ~= i then
        item._execNodeEvent = false
        item:retain()
        self.list_role:removeItem(i)
        if i < index then
          self.list_role:insertCustomItem(item, index - 1)
        else
          self.list_role:insertCustomItem(item, index)
        end
        item:release()
        item._execNodeEvent = true
      end
      item:setShowIconFlag(true)
      break
    end
  end
end
function CHuobanList:InitRoleListTouchEventListener(roleListLen)
  if roleListLen <= 5 then
    self.pic_arrow_down:setVisible(false)
    self.list_role:addTouchEventListenerScrollView(function()
    end)
  else
    self.pic_arrow_down:setVisible(true)
    self.list_role:addTouchEventListenerScrollView(function(item, event)
      self:OnRoleListScrollEvent(event)
    end)
  end
end
function CHuobanList:OnRoleListScrollEvent(event)
  if event == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM or event == SCROLLVIEW_EVENT_BOUNCE_BOTTOM then
    self.pic_arrow_down:setVisible(false)
  else
    self.pic_arrow_down:setVisible(true)
  end
end
function CHuobanList:ChooseItemByHeroId(heroId)
  local hasFlag = false
  for i = 1, self.list_role:getCount() do
    local item = self.list_role:getItem(i - 1)
    if item and item:getRoleId() == heroId then
      hasFlag = true
    end
  end
  if hasFlag == false then
    local heroIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
    table.sort(heroIds, _huobanSortFunc)
    heroId = heroIds[2] or 0
  end
  for i = 1, self.list_role:getCount() do
    local item = self.list_role:getItem(i - 1)
    if item then
      item:setChoosed(item:getRoleId() == heroId)
    end
  end
  if self.m_CurChoosedHeroIns and self.m_CurChoosedHeroIns:getObjId() == heroId then
    self:ScrollToRole(heroId)
    return
  end
  self.m_CurChoosedHeroIns = g_LocalPlayer:getObjById(heroId)
  if self.m_CurChoosedHeroIns ~= nil then
    self:ScrollToRole(heroId)
    self:ReflushBaseInfo()
  end
  if self.m_AddPointDlg then
    self.m_AddPointDlg:LoadProperties(self.m_CurChoosedHeroIns)
  end
end
function CHuobanList:ScrollToRole(roleId)
  if roleId == nil then
    roleId = self.m_CurChoosedHeroIns:getObjId()
  end
  local cnt = self.list_role:getCount()
  for i = 0, cnt - 1 do
    local item = self.list_role:getItem(i)
    if item:getRoleId() == roleId then
      self.list_role:refreshView()
      local h = self.list_role:getContentSize().height
      local ih = self.list_role:getInnerContainerSize().height
      if h < ih then
        local y = (1 - (i + 0.5) / cnt) * ih - h / 2
        local percent = (1 - y / (ih - h)) * 100
        percent = math.max(percent, 0)
        percent = math.min(percent, 100)
        self.list_role:scrollToPercentVertical(percent, 0.3, false)
      end
      break
    end
  end
end
function CHuobanList:ReflushCurrEquipInfo()
  for pos, btnName in pairs(self.m_EqptBtnNameDict) do
    self:ReflushOneEquip(pos)
  end
end
function CHuobanList:ReloadCurrEquipInfo(roleId, itemObjId)
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
function CHuobanList:ReflushOneEquip(equipPosType)
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
  if itemIns ~= nil then
    local itemShapeId = GetHuobanEqptShape(itemIns, self.m_CurChoosedHeroIns)
    local canUseFlag = true
    local canUpgradeFlag = self.m_CurChoosedHeroIns:CanUpgradeItem(itemIns:getObjId())
    local equipIcon = createItemIcon(itemShapeId, nil, canUseFlag, canUpgradeFlag)
    btn_quipe:addNode(equipIcon)
    self.m_EquipIcon[equipPosType] = equipIcon
  end
end
function CHuobanList:SelectRoleViewItem(pos)
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
function CHuobanList:OnBtn_WeaponClick(pos, btnName)
  local itemIns = self.m_CurChoosedHeroIns:GetEqptByPos(pos)
  if itemIns ~= nil then
    self:SelectRoleViewItem(pos)
  else
    self:SelectRoleViewItem(nil)
    local attrName = string.format("zbpos_%d_hb", pos)
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
  if itemIns ~= nil then
    local itemObjId = itemIns:getObjId()
    self:ShowPackageDetail(itemObjId, pos)
  end
end
function CHuobanList:ShowPackageDetail(itemObjId, equipPos)
  if equipPos ~= nil then
    local ItemIns = g_LocalPlayer:GetOneItem(itemObjId)
    if ItemIns == nil then
      return
    end
    local rightBtn = {
      btnText = "打造装备",
      listener = handler(self, self.OnUpgradeEquip)
    }
    local leftBtn
    self.m_EquipDetail = CEquipDetail.new(itemObjId, {
      leftBtn = leftBtn,
      leftBtnFontSize = 20,
      rightBtn = rightBtn,
      closeListener = handler(self, self.OnEquipDetailClosed),
      eqptRoleId = self.m_CurChoosedHeroIns:getObjId(),
      isHuobanFlag = true
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
  else
    local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
    if packageItemIns == nil then
      return
    end
    local itemType = packageItemIns:getTypeId()
    if itemType == ITEM_DEF_OTHER_XMS then
      self.m_EquipDetail = CEquipDetail.new(itemObjId, {
        leftBtn = {
          btnText = "出售",
          listener = handler(self, self.OnSellItem)
        },
        rightBtn = {
          btnText = "使用",
          listener = handler(self, self.OnUseItemForRole)
        },
        closeListener = handler(self, self.OnEquipDetailClosed),
        eqptRoleId = self.m_CurChoosedHeroIns:getObjId()
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
      return
    end
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
        self:OnTakeUpEquipWarning(itemId, true)
      end,
      closeListener = handler(self, self.OnEquipDetailClosed)
    })
    getCurSceneView():addSubView({
      subView = self.m_EquipDetail,
      zOrder = MainUISceneZOrder.menuView
    })
    self.m_EquipDetail:ShowCloseBtn()
  end
end
function CHuobanList:CloseEquipDetail()
  if self.m_EquipDetail then
    self.m_EquipDetail:CloseSelf()
    self:SelectRoleViewItem(nil)
  end
end
function CHuobanList:OnClickEquipItem(obj, check)
  if check then
    obj:setScale(1.05)
  else
    obj:setScale(1)
  end
end
function CHuobanList:OnEquipDetailClosed(obj)
  if self.m_EquipDetail ~= nil and self.m_EquipDetail == obj then
    self.m_EquipDetail = nil
    self:SelectRoleViewItem(nil)
    if self.m_HuobanPackageView then
      self.m_HuobanPackageView.m_PackageFrame:ClearSelectItem()
    end
  end
end
function CHuobanList:OnUpgradeEquip(itemId)
  getCurSceneView():addSubView({
    subView = CZhuangbeiShow.new({
      InitItemId = itemId,
      InitRoleId = self.m_CurChoosedHeroIns:getObjId()
    }),
    zOrder = MainUISceneZOrder.menuView
  })
  self:CloseEquipDetail()
end
function CHuobanList:OnTakeUpEquipWarning(itemId, isReplace)
  local msg = self.m_CurChoosedHeroIns:CanAddItemForHuoban(itemId)
  if msg == true then
    local tempPop = CPopWarning.new({
      title = "提示",
      text = "你确定将这件装备提炼成装备之魂装备到伙伴身上吗？（装备之魂会继承装备原来的属性和强化值）",
      confirmFunc = function()
        self:OnTakeUpEquip(itemId, isReplace)
      end,
      cancelFunc = nil,
      closeFunc = nil,
      confirmText = "确定",
      cancelText = "取消"
    })
    tempPop:ShowCloseBtn(false)
    self:CloseEquipDetail()
  else
    ShowNotifyTips(msg)
  end
end
function CHuobanList:OnTakeUpEquip(itemId, isReplace)
  local msg = self.m_CurChoosedHeroIns:CanAddItemForHuoban(itemId)
  if msg == true then
    self.m_TakeDownEquip_Sound = not isReplace
    local roleId = self.m_CurChoosedHeroIns:getObjId()
    RequestToAddItemToRole(itemId, roleId)
    self:CloseEquipDetail()
    ShowWarningInWar()
  else
    ShowNotifyTips(msg)
  end
end
function CHuobanList:OnUseItemForRole(itemId)
  local player = g_DataMgr:getPlayer()
  local itemIns = player:GetOneItem(itemId)
  if itemIns ~= nil then
    local itemTypeId = itemIns:getTypeId()
    if itemTypeId == ITEM_DEF_OTHER_XMS then
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
          ShowNotifyTips("你的伙伴目前不需要使用该物品")
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
      end
    end
  end
end
function CHuobanList:OnSellItem(itemId)
  SellItemPopView(itemId, handler(self, self.OnConfirmSell))
  self:CloseEquipDetail()
end
function CHuobanList:OnConfirmSell(itemId, itemNum)
  netsend.netitem.requestSellItem(itemId, itemNum)
  self:CloseEquipDetail()
end
function CHuobanList:OnBtn_War()
  local inWarFlag = false
  local curRoleId = self.m_CurChoosedHeroIns:getObjId()
  local warsetting = g_LocalPlayer:getWarSetting()
  local warNum = 0
  for index, pos in ipairs({
    3,
    2,
    4,
    1,
    5
  }) do
    if warsetting[pos] == curRoleId then
      inWarFlag = true
    end
    if warsetting[pos] ~= nil then
      warNum = warNum + 1
    end
  end
  if inWarFlag then
    local tempWarRoleIdList = {}
    for index, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      if warsetting[pos] ~= nil and warsetting[pos] ~= curRoleId then
        tempWarRoleIdList[#tempWarRoleIdList + 1] = warsetting[pos]
      end
    end
    local newSetting = {}
    for index, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      if tempWarRoleIdList[index] ~= nil then
        newSetting[pos] = tempWarRoleIdList[index]
      end
    end
    netsend.netwar.submitWarSetting(newSetting)
    ShowWarningInWar()
  else
    local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
    local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
    if warNum >= data_getWarNumLimit(zs, lv) + 1 then
      if zs > 0 or lv >= 60 then
        ShowNotifyTips("上场伙伴已满")
      else
        local nextLv
        if lv >= 40 then
          nextLv = 60
        elseif lv >= 20 then
          nextLv = 40
        else
          nextLv = 20
        end
        ShowNotifyTips(string.format("上场伙伴已满，%d级伙伴出战人数+1", nextLv))
      end
    else
      local newSetting = DeepCopyTable(warsetting)
      for index, pos in ipairs({
        3,
        2,
        4,
        1,
        5
      }) do
        if warsetting[pos] == nil then
          newSetting[pos] = curRoleId
          break
        end
      end
      netsend.netwar.submitWarSetting(newSetting)
      ShowWarningInWar()
    end
  end
end
function CHuobanList:UpdateWarBtnText()
  local inWarFlag = false
  local warsetting = g_LocalPlayer:getWarSetting()
  for index, pos in ipairs({
    3,
    2,
    4,
    1,
    5
  }) do
    if warsetting[pos] == self.m_CurChoosedHeroIns:getObjId() then
      inWarFlag = true
    end
  end
  if inWarFlag then
    self.btn_war:setTitleText("休息")
  else
    self.btn_war:setTitleText("出战")
  end
end
function CHuobanList:OnBtn_KangxingView()
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
  local bSize = tempView:getBoxSize()
  self:addSubView({subView = tempView, zOrder = 9999})
  local x, y = self:getNode("bg1"):getPosition()
  local iSize = self:getNode("bg1"):getContentSize()
  local bSize = tempView:getBoxSize()
  tempView:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
  tempView:ReSetHeroData(self.m_CurChoosedHeroIns:getObjId())
  self.m_KangXingViewObj = tempView
end
function CHuobanList:OnAddPointClose()
  self.m_AddPointDlg = nil
end
function CHuobanList:OnBtn_Close(btnObj, touchType)
  g_HuobanView:OnBtn_Close()
end
function CHuobanList:OnBtn_SetPoint(id)
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:CloseSelf()
    self.m_KangXingViewObj = nil
  end
  if self.m_CurChoosedHeroIns == nil then
    return
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_RolePoint)
  if not openFlag then
    ShowNotifyTips(tips)
    return
  end
  if self.m_AddPointDlg then
    self.m_AddPointDlg:CloseSelf()
    self.m_AddPointDlg = nil
    return
  end
  self.m_AddPointDlg = CAddPoint.new(handler(self, self.OnAddPointClose))
  self:addSubView({
    subView = self.m_AddPointDlg,
    zOrder = 200
  })
  local x, y = self:getNode("bg1"):getPosition()
  local iSize = self:getNode("bg1"):getContentSize()
  local bSize = self.m_AddPointDlg:getContentSize()
  self.m_AddPointDlg:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
  self.m_AddPointDlg:LoadProperties(self.m_CurChoosedHeroIns)
end
function CHuobanList:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  local hid = self.m_CurChoosedHeroIns:getObjId()
  if msgSID == MsgID_HeroUpdate then
    local d = arg[1]
    if d.heroId == hid then
      self:ReflushBaseInfo()
    end
  elseif msgSID == MsgID_ItemInfo_TakeEquip then
    local roleId, itemId = arg[1], arg[2]
    self:ReloadCurrEquipInfo(roleId, itemId)
    self:ReflushProData()
    local itemIns = g_LocalPlayer:GetOneItem(itemId)
    if itemIns ~= nil and itemIns:getType() ~= ITEM_LARGE_TYPE_HUOBANEQPT then
      if g_PackageZBView == nil and g_ZhuangbeiView == nil then
        soundManager.playSound("xiyou/sound/takeup_equip.wav")
      end
      ShowWarningInWar()
    end
    if self.m_EquipDetail ~= nil and self.m_EquipDetail:getItemObjId() == itemId then
      self:CloseEquipDetail()
    end
  elseif msgSID == MsgID_ItemInfo_TakeDownEquip then
    local roleId, itemId = arg[1], arg[2]
    self:ReloadCurrEquipInfo(roleId, itemId)
    if self.m_EquipDetail ~= nil then
      if self.m_EquipDetail:getItemObjId() == itemId then
        self:CloseEquipDetail()
      end
      ShowWarningInWar()
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
    self:ReloadCurrEquipInfo(tempRoleId, tempItemId)
  elseif msgSID == MsgID_ItemSource_Jump then
    if self.m_EquipDetail and self.m_EquipDetail.__cname == "CPacakgeZBShow" then
    else
      self:CloseEquipDetail()
    end
  elseif msgSID == MsgID_AddHero then
    self:ReloadAllRoles()
    local curHeroId = self.m_CurChoosedHeroIns:getObjId()
    self:ChooseItemByHeroId(curHeroId)
  elseif msgSID == MsgID_DeleteHero then
    self:ReloadAllRoles()
    local curHeroId = self.m_CurChoosedHeroIns:getObjId()
    self:ChooseItemByHeroId(curHeroId)
  elseif msgSID == MsgID_DeletePet then
    self:ReflushBaseInfo()
  elseif msgSID == MsgID_WarSetting_Change then
    local curHeroId = self.m_CurChoosedHeroIns:getObjId()
    self:ReloadAllRoles()
    self:ChooseItemByHeroId(curHeroId)
    self:UpdateWarBtnText()
    self:ReflushProData()
  elseif msgSID == MsgID_WarScene_ViewHpMpChanged then
    local curHeroId = self.m_CurChoosedHeroIns:getObjId()
    if arg[1] == g_LocalPlayer:getPlayerId() and arg[2] == curHeroId then
      self:ReflushProData()
    end
  elseif msgSID == MsgID_Scene_War_Exit then
    self:ReflushProData()
  end
end
function CHuobanList:Clear()
  self:CloseEquipDetail()
end
CHuobanPackageView = class("CHuobanPackageView", CcsSubView)
function CHuobanPackageView:ctor(para, huobanListObj)
  CHuobanPackageView.super.ctor(self, "views/huoban_package.json")
  local jumpToItemId = para.jumpToItemId or nil
  self.m_HuobanListObj = huobanListObj
  self.layer_itemlist = self:getNode("layer_itemlist")
  self.layer_itemlist:setVisible(false)
  local x, y = self.layer_itemlist:getPosition()
  local z = self.layer_itemlist:getZOrder()
  local param = {
    xySpace = ccp(0, 0),
    itemSize = CCSize(90, 94),
    pageLines = 4,
    oneLineNum = 3
  }
  local tempSelectFunc = function(itemObj)
    local itemId = itemObj:getObjId()
    local itemType = itemObj:getTypeId()
    local itemLargeType = itemObj:getType()
    if itemLargeType == ITEM_LARGE_TYPE_OTHERITEM and itemType ~= ITEM_DEF_OTHER_XMS then
      return false
    end
    return true
  end
  self.m_PackageFrame = CPackageFrame.new(ITEM_PACKAGE_TYPE_HERO, function(itemObjId)
    if self.m_HuobanListObj then
      self.m_HuobanListObj:ShowPackageDetail(itemObjId, nil)
    end
  end, nil, param, tempSelectFunc)
  self.m_PackageFrame:setPosition(ccp(x, y))
  self:addChild(self.m_PackageFrame, z + 100)
  self.m_PackageFrame:JumpToItemPage(jumpToItemId)
end
function CHuobanPackageView:Clear()
  self.m_HuobanListObj = nil
end
CHuobanKangView = class("CHuobanKangView", CcsSubView)
function CHuobanKangView:ctor(para)
  CHuobanKangView.super.ctor(self, "views/huoban_kang.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.scroller_kang = self:getNode("scroller_kang")
  local size = self.scroller_kang:getInnerContainerSize()
  self.m_ScrollerInnerContentsizeW = size.width
  self.m_ScrollerInnerContentsizeH = size.height
  self.m_KangProperLabels = {}
  self.m_Bg = self:getNode("bg")
  clickArea_check.extend(self)
  self.m_CloseFunc = para.closeFunc
  self:enableCloseWhenTouchOutside(self.m_Bg, true)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CHuobanKangView:OnMessage(msgSID, ...)
  if msgSID == MsgID_HeroUpdate then
    local arg = {
      ...
    }
    local d = arg[1]
    if d.heroId == self.m_HuoBanId then
      self:ReSetHeroData(self.m_HuoBanId)
    end
  elseif msgSID == MsgID_PetUpdate then
    local arg = {
      ...
    }
    local d = arg[1]
    if d.petId == self.m_HuoBanId then
      self:ReSetHeroData(self.m_HuoBanId)
    end
  end
end
function CHuobanKangView:ReSetHeroData(huobanID)
  local heroIns = g_LocalPlayer:getObjById(huobanID)
  if heroIns == nil then
    return
  end
  self.m_HuoBanId = huobanID
  local nameTxtFontSize = 27
  local proTxtFontSize = 20
  local fontName = KANG_TTF_FONT
  local w = self.m_ScrollerInnerContentsizeW
  local pos_y = 0
  local tempList = {}
  for index, proShowTable in ipairs(Def_KangViewShowSeq) do
    pos_y = pos_y - 5
    local nameTxt = self:getKangNameTxtIns_(proShowTable.name, fontName, nameTxtFontSize)
    local h = nameTxt:getContentSize().height
    nameTxt:setPosition(w / 2, pos_y - h / 2)
    pos_y = pos_y - h / 2
    local curLineShowIndex = 0
    local lineNO = proShowTable.lineNum
    local proSpaceW = 10
    local proW = (w - (lineNO + 1) * proSpaceW) / lineNO
    local lineH = 0
    for idx, proName in ipairs(proShowTable.pro) do
      local value = heroIns:getProperty(proName)
      if proName == PROPERTY_PACC then
        value = value - Def_Show_PROPERTY_PACC_DelValue
      elseif proName == PROPERTY_MAGICKUANGBAO_AIHAO then
        if value ~= 0 then
          value = value - Def_Show_PROPERTY_AiHaoKuangBaoChengDu_DelValue
        end
      elseif proName == PROPERTY_MAGICKUANGBAO_XIXUE then
        if value ~= 0 then
          value = value - Def_Show_PROPERTY_XiXueKuangBaoChengDu_DelValue
        end
      elseif proName == PROPERTY_KE_WXJIN then
        value = value + heroIns:getProperty(PROPERTY_WINE_KE_WXJIN)
      elseif proName == PROPERTY_KE_WXMU then
        value = value + heroIns:getProperty(PROPERTY_WINE_KE_WXMU)
      elseif proName == PROPERTY_KE_WXTU then
        value = value + heroIns:getProperty(PROPERTY_WINE_KE_WXTU)
      elseif proName == PROPERTY_KE_WXSHUI then
        value = value + heroIns:getProperty(PROPERTY_WINE_KE_WXSHUI)
      elseif proName == PROPERTY_KE_WXHUO then
        value = value + heroIns:getProperty(PROPERTY_WINE_KE_WXHUO)
      end
      local desTxtIns, valueTxtIns = self:getKangProTxtIns_(proName, value, fontName, proTxtFontSize)
      if desTxtIns and valueTxtIns then
        if curLineShowIndex == 0 then
          lineH = 30
          pos_y = pos_y - lineH
        end
        desTxtIns:setVisible(true)
        desTxtIns:setPosition(curLineShowIndex * proW + (1 + curLineShowIndex) * proSpaceW, pos_y - lineH / 2)
        valueTxtIns:setVisible(true)
        valueTxtIns:setPosition((1 + curLineShowIndex) * proW + (1 + curLineShowIndex) * proSpaceW, pos_y - lineH / 2)
        tempList[#tempList + 1] = {
          desTxtIns,
          valueTxtIns,
          proName
        }
        curLineShowIndex = curLineShowIndex + 1
        if lineNO <= curLineShowIndex then
          curLineShowIndex = 0
        end
      end
    end
    pos_y = pos_y - 45
  end
  if self.m_HuoBanId == g_LocalPlayer:getMainHeroId() then
    local allTxt = ""
    local curId, endTime, isHide = g_LocalPlayer:getCurChengwei()
    if curId ~= nil then
      local d = data_Title[curId]
      if d ~= nil then
        local hasTextFlag = false
        for _, _ in pairs(d.AddKX or {}) do
          hasTextFlag = true
          break
        end
        for _, _ in pairs(d.AddFS or {}) do
          hasTextFlag = true
          break
        end
        if hasTextFlag then
          local title = d.Title or "称谓标题"
          local tips = d.Tips or "称谓描述"
          allTxt = string.format("称谓#<G>%s#%s", title, tips)
        end
      end
    end
    if allTxt ~= nil then
      if self.m_RichText == nil then
        local titleTxt = CRichText.new({
          width = 300,
          verticalSpace = 1,
          font = KANG_TTF_FONT,
          fontSize = 20,
          color = ccc3(255, 255, 255)
        })
        self.m_RichText = titleTxt
        self.scroller_kang:addChild(titleTxt, 10)
      else
        self.m_RichText:clearAll()
      end
      self.m_RichText:addRichText(allTxt)
      local rSize = self.m_RichText:getContentSize()
      self.m_RichText:setPosition(ccp(10, 0))
      pos_y = pos_y - rSize.height
    end
  end
  local realH = -pos_y
  if realH < self.m_ScrollerInnerContentsizeH then
    realH = self.m_ScrollerInnerContentsizeH
  end
  self.scroller_kang:setInnerContainerSize(CCSize(w, realH))
  for k, v in pairs(self.m_KangProperLabels) do
    for k1, v1 in pairs(v) do
      if v1 then
        local x, y = v1:getPosition()
        v1:setPosition(CCPoint(x, y + realH))
      end
    end
  end
  for _, temp in pairs(tempList) do
    local obj = self:attrclick_check_withObj(temp[1], temp[3])
    self:attrclick_check_withObj(temp[2], temp[3], obj)
  end
end
function CHuobanKangView:getKangNameTxtIns_(name, fontName, nameTxtFontSize)
  local nameTxtFontSize = nameTxtFontSize or 26
  local fontName = fontName or KANG_TTF_FONT
  local key = "kang_name_" .. name
  local nameTxt = self.m_KangProperLabels[key]
  nameTxt = nameTxt and nameTxt.des
  if nameTxt == nil then
    nameTxt = CCLabelTTF:create(name, fontName, nameTxtFontSize)
    nameTxt:setColor(ccc3(255, 196, 98))
    self.scroller_kang:addNode(nameTxt)
    self.m_KangProperLabels[key] = {des = nameTxt}
    local txtBg = display.newSprite("views/rolelist/pic_kx_titlebg.png")
    nameTxt:addChild(txtBg, -1)
    local size = nameTxt:getContentSize()
    txtBg:setPosition(size.width / 2 - 10, 10)
  end
  return nameTxt
end
function CHuobanKangView:getKangProTxtIns_(proType, value, fontName, proTxtFontSize)
  local proTxtFontSize = proTxtFontSize or 20
  local fontName = fontName or KANG_TTF_FONT
  local desTxtIns, valueTxtIns
  local txtInsTable = self.m_KangProperLabels[proType]
  if txtInsTable then
    desTxtIns = txtInsTable.des
    valueTxtIns = txtInsTable.value
  else
    txtInsTable = {}
    self.m_KangProperLabels[proType] = txtInsTable
  end
  if value == 0 then
    if desTxtIns then
      desTxtIns:setVisible(false)
    end
    if valueTxtIns then
      valueTxtIns:setVisible(false)
    end
    return nil, nil
  end
  if desTxtIns == nil then
    desTxtIns = CCLabelTTF:create((Def_Pro_Name[proType] or proType) .. ":", fontName, proTxtFontSize)
    desTxtIns:setHorizontalAlignment(kCCTextAlignmentLeft)
    desTxtIns:setAnchorPoint(ccp(0, 0.5))
    desTxtIns:setColor(ccc3(188, 125, 41))
    self.scroller_kang:addNode(desTxtIns)
    txtInsTable.des = desTxtIns
  end
  local tempText = ""
  local addFlag = ""
  if value < 0 then
    addFlag = "-"
  end
  if Def_Pro_ValueType[proType] == Pro_Value_PERCENT_TYPE then
    tempText = string.format("%s%s%%", addFlag, Value2Str(math.abs(value) * 100, 1))
  else
    tempText = string.format("%s%d", addFlag, math.floor(math.abs(value)))
  end
  if valueTxtIns == nil then
    valueTxtIns = CCLabelTTF:create(tempText, fontName, proTxtFontSize)
    valueTxtIns:setHorizontalAlignment(kCCTextAlignmentRight)
    valueTxtIns:setAnchorPoint(ccp(1, 0.5))
    valueTxtIns:setColor(ccc3(255, 255, 255))
    self.scroller_kang:addNode(valueTxtIns)
    txtInsTable.value = valueTxtIns
  else
    valueTxtIns:setString(tempText)
  end
  return desTxtIns, valueTxtIns
end
function CHuobanKangView:getBoxSize()
  return self.m_Bg:getSize()
end
function CHuobanKangView:OnBtn_Close()
  self:CloseSelf()
end
function CHuobanKangView:Clear()
  if self.m_CloseFunc then
    self.m_CloseFunc()
  end
end
CHuobanSkillView = class("CHuobanSkillView", CcsSubView)
function CHuobanSkillView:ctor(para)
  CHuobanSkillView.super.ctor(self, "views/huoban_skill.json")
  for i = 1, 6 do
    self:getNode(string.format("skillPos_%d", i)):setVisible(false)
  end
  self.m_SkillIconList = {}
end
function CHuobanSkillView:ReSetHeroData(huobanID)
  local heroIns = g_LocalPlayer:getObjById(huobanID)
  if heroIns == nil then
    return
  end
  for _, icon in pairs(self.m_SkillIconList) do
    icon:removeFromParent()
  end
  self.m_SkillIconList = {}
  local skillAttrList = heroIns:getSkillTypeList()
  local index = 1
  for _, skillAttr in pairs(skillAttrList) do
    local skillList = data_getSkillListByAttr(skillAttr)
    for step = 3, 5 do
      local tempSkillId = skillList[step]
      self:AddOneSkill(huobanID, tempSkillId, self:getNode(string.format("skillPos_%d", index)))
      index = math.min(index + 1, 6)
    end
  end
end
function CHuobanSkillView:AddOneSkill(huobanID, skillId, pos)
  local heroIns = g_LocalPlayer:getObjById(huobanID)
  if heroIns == nil then
    return
  end
  local x, y = pos:getPosition()
  local imgSize = pos:getContentSize()
  local w = imgSize.width
  local h = imgSize.height
  local openFlag = heroIns:getSkillIsOpen(skillId)
  local path = data_getSkillShapePath(skillId)
  local size = CCSize(w, h)
  local clickImg = createClickSkill({
    roleID = huobanID,
    skillID = skillId,
    autoSize = size,
    LongPressTime = 0.2,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    grayFlag = openFlag == false
  })
  local icon = clickImg
  icon:setPosition(ccp(x, y))
  self:addChild(icon)
  icon:setEnabled(false)
  self.m_SkillIconList[#self.m_SkillIconList + 1] = icon
end
function CHuobanSkillView:Clear()
end
