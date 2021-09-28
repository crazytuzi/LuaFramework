g_PetListDlg = nil
CPetList = class(".CPetList", CcsSubView)
function CPetList:ctor(initShowView, initShowPet, closeCallBack, tujianPet)
  CPetList.super.ctor(self, "views/pet_list.json", {isAutoCenter = true, opacityBg = 100})
  clickArea_check.extend(self)
  self.m_CloseCallBackFunc = closeCallBack
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_changename = {
      listener = handler(self, self.OnBtn_ChangeName),
      variName = "btn_changename"
    },
    btn_fire = {
      listener = handler(self, self.OnBtn_Fire),
      variName = "btn_fire"
    },
    btn_war = {
      listener = handler(self, self.OnBtn_War),
      variName = "btn_war"
    },
    btn_kangxingview = {
      listener = handler(self, self.OnBtn_KangxingView),
      variName = "btn_kangxingview"
    },
    btn_neidan_1 = {
      listener = handler(self, self.OnBtn_NeiDan_1),
      variName = "btn_neidan_1"
    },
    btn_neidan_2 = {
      listener = handler(self, self.OnBtn_NeiDan_2),
      variName = "btn_neidan_2"
    },
    btn_neidan_3 = {
      listener = handler(self, self.OnBtn_NeiDan_3),
      variName = "btn_neidan_3"
    },
    btn_attr = {
      listener = handler(self, self.OnBtn_Attr),
      variName = "btn_attr"
    },
    btn_potential = {
      listener = handler(self, self.OnBtn_Potential),
      variName = "btn_potential"
    },
    btn_skill = {
      listener = handler(self, self.OnBtn_Skill),
      variName = "btn_skill"
    },
    btn_skilllearn = {
      listener = handler(self, self.OnBtn_SkillLearn),
      variName = "btn_skilllearn"
    },
    btn_page_attr = {
      listener = handler(self, self.OnBtn_Page_ItemList),
      variName = "btn_page_attr"
    },
    btn_page_xichong = {
      listener = handler(self, self.OnBtn_Page_XiChong),
      variName = "btn_page_xichong"
    },
    btn_page_lianyao = {
      listener = handler(self, self.OnBtn_Page_LianYao),
      variName = "btn_page_lianyao"
    },
    btn_page_tujian = {
      listener = handler(self, self.OnBtn_Page_TuJian),
      variName = "btn_page_tujian"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_page_attr:setTitleText("宠\n物\n属\n性")
  self.btn_page_xichong:setTitleText("洗\n宠")
  self.btn_page_lianyao:setTitleText("炼\n妖")
  self.btn_page_tujian:setTitleText("图\n鉴")
  local size = self.btn_page_attr:getContentSize()
  self:adjustClickSize(self.btn_page_attr, size.width + 30, size.height, true)
  local size = self.btn_page_xichong:getContentSize()
  self:adjustClickSize(self.btn_page_xichong, size.width + 30, size.height, true)
  local size = self.btn_page_lianyao:getContentSize()
  self:adjustClickSize(self.btn_page_lianyao, size.width + 30, size.height, true)
  local size = self.btn_page_tujian:getContentSize()
  self:adjustClickSize(self.btn_page_tujian, size.width + 30, size.height, true)
  self:addBtnSigleSelectGroup({
    {
      self.btn_attr,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -1)
    },
    {
      self.btn_potential,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -1)
    },
    {
      self.btn_skill,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -1)
    },
    {
      self.btn_skilllearn,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -1)
    }
  })
  self:addBtnSigleSelectGroup({
    {
      self.btn_page_attr,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_page_xichong,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_page_lianyao,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_page_tujian,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    }
  })
  self.title_p1 = self:getNode("title_p1")
  self.title_p2 = self:getNode("title_p2")
  local upx, upy = self.title_p1:getPosition()
  local dpx, dpy = self.title_p2:getPosition()
  self.titleUpPos = ccp(upx, upy)
  self.titleMidPos = ccp((upx + dpx) / 2, (upy + dpy) / 2)
  self.pic_leftbg = self:getNode("pic_leftbg")
  self.pic_probg = self:getNode("pic_probg")
  self.list_role = self:getNode("list_role")
  self.txt_rolename = self:getNode("txt_rolename")
  self.txt_zhuan = self:getNode("txt_zhuan")
  self.txt_zhuan_title = self:getNode("txt_zhuan_title")
  self.txt_level = self:getNode("txt_level")
  self.txt_level_title = self:getNode("txt_level_title")
  self.pro_exp = self:getNode("pro_exp")
  self.txt_expvalue = self:getNode("txt_expvalue")
  self.role_aureole = self:getNode("role_aureole")
  self.role_aureole:setVisible(false)
  self.pet_quality_box = self:getNode("pet_quality_box")
  self.pet_quality_box:setVisible(false)
  self.poslayer_base = self:getNode("poslayer_base")
  self.poslayer_base:setVisible(false)
  self.poslayer_right = self:getNode("poslayer_right")
  self.poslayer_right:setVisible(false)
  self.m_CurChoosedIndex = -1
  self.m_CurChoosedPetIns = nil
  self.m_CurSelectBasePage = nil
  self.m_CurSelectRightPage = nil
  self.m_InitShowViews = initShowView
  self.m_InitTujianPet = tujianPet
  self.m_MaxExtraPetLimitNum = 20
  local existPets = self:ReloadAllRoles()
  self.list_role:addTouchItemListenerListView(function(item, index, listObj)
    self:ClickItemAtRoleList(index)
  end)
  if existPets then
    if not self:ChooseAndScrollToRoleWithID(initShowPet) then
      self:ChooseAndScrollToRoleWithIndex(0)
    end
  else
    self.m_InitShowViews = PetShow_InitShow_TuJianView
  end
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_MoveScene)
  if g_PetListDlg ~= nil then
    g_PetListDlg:CloseSelf()
  end
  g_PetListDlg = self
end
function CPetList:onEnterEvent()
  if CPetList.super.onEnterEvent then
    CPetList.super.onEnterEvent(self)
  end
  if self.m_InitShowViews == PetShow_InitShow_TuJianView then
    do
      local ox1, oy1 = self:getPosition()
      local ox2, oy2 = self._auto_create_opacity_bg_ins:getPosition()
      self:setPosition(ccp(99999, 99999))
      self._auto_create_opacity_bg_ins:setPosition(ccp(99999, 99999))
      local act1 = CCDelayTime:create(0.01)
      local act2 = CCCallFunc:create(function()
        self:setPosition(ccp(ox1, oy1))
        self._auto_create_opacity_bg_ins:setPosition(ccp(ox2, oy2))
        self:InitViews(self.m_InitShowViews)
      end)
      self:runAction(transition.sequence({act1, act2}))
    end
  else
    self:InitViews(self.m_InitShowViews)
  end
end
function CPetList:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_AddPet then
    self:ReloadAllRoles()
    if self.m_CurChoosedPetIns then
      local petId = self.m_CurChoosedPetIns:getObjId()
      self:ChooseAndScrollToRoleWithID(petId)
    else
      self:ChooseAndScrollToRoleWithIndex(0)
    end
  elseif msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if self.m_CurChoosedPetIns and d.petId == self.m_CurChoosedPetIns:getObjId() then
      local proTable = d.pro
      if proTable[PROPERTY_NAME] ~= nil then
        self:SetPetName()
      end
      if proTable[PROPERTY_ZHUANSHENG] ~= nil or proTable[PROPERTY_ROLELEVEL] ~= nil then
        self:SetZsAndLevel()
        self:SetPetExp()
      end
      if proTable[PROPERTY_EXP] ~= nil then
        self:SetPetExp()
      end
      if proTable[PROPERTY_PETSKILLS] ~= nil or proTable[PROPERTY_SSSKILLS] ~= nil or proTable[PROPERTY_ZJSKILLSEXP] ~= nil then
        self:OnBtn_SkillLearn()
      end
    end
  elseif msgSID == MsgID_HeroUpdate then
    local d = arg[1]
    if d.heroId == g_LocalPlayer:getMainHeroId() then
      local proTable = d.pro
      if proTable[PROPERTY_PETID] ~= nil then
        self:ReloadAllRoles()
        if self.m_CurChoosedPetIns then
          local petId = self.m_CurChoosedPetIns:getObjId()
          self:ChooseAndScrollToRoleWithID(petId)
        end
      end
    end
  elseif msgSID == MsgID_ItemInfo_TakeEquip then
    local roleId, itemId = arg[1], arg[2]
    self:ReloadCurrNeiDanInfo(roleId)
    soundManager.playSound("xiyou/sound/takeup_equip.wav")
  elseif msgSID == MsgID_ItemInfo_TakeDownEquip then
    local roleId, itemId = arg[1], arg[2]
    self:ReloadCurrNeiDanInfo(roleId)
    soundManager.playSound("xiyou/sound/takedown_equip.wav")
  elseif msgSID == MsgID_DeletePet then
    local petIdList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
    if #petIdList > 0 then
      self:ReloadAllRoles()
      self:ChooseAndScrollToRoleWithIndex(0)
    else
      self:OnBtn_Close()
    end
  elseif msgSID == MsgID_ItemSource_Jump then
    local d = arg[1][1]
    for _, t in pairs(Item_Source_MoveMapList) do
      if d == t then
        self:OnBtn_Close()
        break
      end
    end
  elseif msgSID == MsgID_ExtraPetLimitNum then
    self:checkExtraPetLimit()
  end
end
function CPetList:InitViews(initShowView)
  if initShowView == nil or initShowView == PetShow_InitShow_PropertyView or initShowView == PetShow_InitShow_NeidanView then
    self:OnBtn_Attr()
    self:OnBtn_Page_ItemList()
  elseif initShowView == PetShow_InitShow_Potential then
    self:OnBtn_Potential()
    self:OnBtn_Page_ItemList()
  elseif initShowView == PetShow_InitShow_SkillView then
    self:OnBtn_Skill()
    self:OnBtn_Page_ItemList()
  elseif initShowView == PetShow_InitShow_SkillLearnView then
    self:OnBtn_SkillLearn()
    self:OnBtn_Page_ItemList(nil, nil, false)
  elseif initShowView == PetShow_InitShow_ItemView then
    self:OnBtn_Attr()
    self:OnBtn_Page_ItemList()
  elseif initShowView == PetShow_InitShow_XiChongView then
    self:OnBtn_Attr()
    self:OnBtn_Page_XiChong()
  elseif initShowView == PetShow_InitShow_LianYaoView then
    self:OnBtn_Attr()
    self:OnBtn_Page_LianYao()
  elseif initShowView == PetShow_InitShow_TuJianView then
    self:OnBtn_Attr()
    self:OnBtn_Page_TuJian()
  else
    self:OnBtn_Attr()
    self:OnBtn_Page_ItemList()
  end
end
function CPetList:ReloadAllRoles()
  self.list_role:removeAllItems()
  local petIdList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  local mainHeroIns = g_LocalPlayer:getMainHero()
  local mainHeroPetId = -1
  local curZs = 0
  if mainHeroIns then
    mainHeroPetId = mainHeroIns:getProperty(PROPERTY_PETID)
    curZs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
  end
  table.sort(petIdList, function(id_a, id_b)
    if id_a == nil or id_b == nil then
      return false
    end
    if id_a == mainHeroPetId then
      return true
    elseif id_b == mainHeroPetId then
      return false
    end
    local petObj_a = g_LocalPlayer:getObjById(id_a)
    local petObj_b = g_LocalPlayer:getObjById(id_b)
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
  end)
  local lSize = self.list_role:getContentSize()
  local extraNum = g_LocalPlayer:GetPetLimitNum()
  local maxPetNum = data_getMaxPetNum(curZs) + extraNum
  for i, petId in ipairs(petIdList) do
    local item = CPetListHeadItem.new(petId, lSize.width)
    item:setChoosed(false)
    item:setShowIconFlag(petId == mainHeroPetId)
    self.list_role:pushBackCustomItem(item)
  end
  for i = #petIdList + 1, maxPetNum do
    local item = CPetEmptyItem.new(lSize.width)
    self.list_role:pushBackCustomItem(item)
  end
  self:checkExtraPetLimit()
  return #petIdList > 0
end
function CPetList:checkExtraPetLimit()
  local mainHeroIns = g_LocalPlayer:getMainHero()
  local curZs = 0
  if mainHeroIns then
    curZs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
  end
  local extraNum = g_LocalPlayer:GetPetLimitNum()
  local maxPetNum = data_getMaxPetNum(curZs) + extraNum
  local cnt = self.list_role:getCount()
  local petNum = cnt
  if cnt > 0 then
    for i = cnt - 1, 0, -1 do
      if iskindof(self.list_role:getItem(i), "CPetListHeadItem") or iskindof(self.list_role:getItem(i), "CPetEmptyItem") then
        break
      else
        petNum = petNum - 1
      end
    end
  end
  local lSize = self.list_role:getContentSize()
  for i = petNum + 1, maxPetNum do
    local item = CPetEmptyItem.new(lSize.width)
    if cnt <= petNum then
      self.list_role:pushBackCustomItem(item)
    else
      self.list_role:insertCustomItem(item, petNum)
    end
  end
  local cnt = self.list_role:getCount()
  if extraNum < self.m_MaxExtraPetLimitNum then
    if cnt <= 0 or not iskindof(self.list_role:getItem(cnt - 1), "CPetMoreItem") then
      local item = CPetMoreItem.new(lSize.width)
      self.list_role:pushBackCustomItem(item)
    end
  elseif cnt > 0 and iskindof(self.list_role:getItem(cnt - 1), "CPetMoreItem") then
    self.list_role:removeItem(cnt - 1)
  end
end
function CPetList:ChooseItem(index)
  local tempItem = self.list_role:getItem(index)
  if not iskindof(tempItem, "CPetListHeadItem") then
    return
  end
  if self.m_CurChoosedIndex >= 0 then
    local item = self.list_role:getItem(self.m_CurChoosedIndex)
    if item and iskindof(item, "CPetListHeadItem") then
      item:setChoosed(false)
    end
  end
  self.m_CurChoosedIndex = index
  local item = self.list_role:getItem(self.m_CurChoosedIndex)
  if item then
    item:setChoosed(true)
    local petId = item:getRoleId()
    if self.m_CurChoosedPetIns == nil or self.m_CurChoosedPetIns:getObjId() ~= petId then
      self.m_CurChoosedPetIns = g_LocalPlayer:getObjById(petId)
      self:ReflushBaseInfo(petId)
    end
    local mainHeroIns = g_LocalPlayer:getMainHero()
    local mainHeroPetId = -1
    if mainHeroIns then
      mainHeroPetId = mainHeroIns:getProperty(PROPERTY_PETID)
    end
    self:setWarButton(petId == mainHeroPetId)
  end
  if self.m_AddPointDlg then
    self.m_AddPointDlg:LoadProperties(self.m_CurChoosedPetIns)
  end
  if self.m_AddCloseViewObj then
    self.m_AddCloseViewObj:LoadProperties(self.m_CurChoosedPetIns)
  end
end
function CPetList:ScrollToRole(index)
  self.list_role:refreshView()
  local cnt = self.list_role:getCount()
  local h = self.list_role:getContentSize().height
  local ih = self.list_role:getInnerContainerSize().height
  if h < ih then
    local y = (1 - (index + 0.5) / cnt) * ih - h / 2
    local percent = (1 - y / (ih - h)) * 100
    percent = math.max(percent, 0)
    percent = math.min(percent, 100)
    self.list_role:scrollToPercentVertical(percent, 0.3, false)
  end
end
function CPetList:ChooseAndScrollToRoleWithIndex(index)
  self:ChooseItem(index)
  self:ScrollToRole(index)
end
function CPetList:ClickItemAtRoleList(index)
  local cnt = self.list_role:getCount()
  if index >= cnt then
    return
  end
  local item = self.list_role:getItem(index)
  if iskindof(item, "CPetMoreItem") then
    do
      local extraNum = g_LocalPlayer:GetPetLimitNum()
      if extraNum >= self.m_MaxExtraPetLimitNum then
        return
      end
      local mainHeroIns = g_LocalPlayer:getMainHero()
      local curZs = 0
      if mainHeroIns then
        curZs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
      end
      local goldNum = 0
      if extraNum <= 0 then
        goldNum = data_Variables.AddPetLimitCost_1
      else
        goldNum = data_Variables.AddPetLimitCost_2
      end
      local text = string.format("是否以%d#<IR%d>#增加召唤兽的携带数量?", goldNum, RESTYPE_GOLD)
      if curZs < 1 then
        text = string.format([[
%s
%s]], text, "(提示:人物1转后默认上限增加至8个)")
      end
      local dlg = CPopWarning.new({
        title = "提示",
        text = text,
        confirmFunc = function()
          self:confirmExtraPetLimitNum(goldNum)
        end,
        cancelText = "取消",
        confirmText = "确定",
        align = CRichText_AlignType_Left
      })
      dlg:ShowCloseBtn(false)
    end
  elseif iskindof(item, "CPetListHeadItem") then
    self:ChooseAndScrollToRoleWithIndex(index)
  end
end
function CPetList:confirmExtraPetLimitNum(goldNum)
  if goldNum <= g_LocalPlayer:getGold() then
    netsend.netbaseptc.setExtraPetLimitNum()
    ShowWarningInWar()
  else
    ShowNotifyTips(string.format("元宝不足%d", goldNum))
    ShowRechargeView({resType = RESTYPE_GOLD})
  end
end
function CPetList:ChooseAndScrollToRoleWithID(petId)
  if petId == nil then
    return false
  end
  local cnt = self.list_role:getCount()
  for i = 0, cnt - 1 do
    local obj = self.list_role:getItem(i)
    if iskindof(obj, "CPetListHeadItem") and obj:getRoleId() == petId then
      self:ChooseItem(i)
      self:ScrollToRole(i)
      return true
    end
  end
  return false
end
function CPetList:ReflushBaseInfo(petId)
  self:SetPetName()
  self:SetZsAndLevel()
  self:SetPetExp()
  self:SetPetShape()
  self:SetPetQuality()
  self:ReflushCurrNeiDanInfo()
  if self.m_CurSelectBasePage then
    self.m_CurSelectBasePage:LoadPet(petId)
  end
  if self.m_CurSelectRightPage then
    self.m_CurSelectRightPage:LoadPet(petId)
  end
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:ReSetHeroData(self.m_CurChoosedPetIns:getObjId())
  end
end
function CPetList:SetPetName()
  local name = self.m_CurChoosedPetIns:getProperty(PROPERTY_NAME)
  local petID = self.m_CurChoosedPetIns:getObjId()
  if channel.showGM == false then
    self.txt_rolename:setText(name)
  else
    self.txt_rolename:setText(name .. " " .. tostring(petID))
  end
  color = ccc3(255, 255, 255)
  self.txt_rolename:setColor(color)
end
function CPetList:SetZsAndLevel()
  local zs = self.m_CurChoosedPetIns:getProperty(PROPERTY_ZHUANSHENG)
  local lv = self.m_CurChoosedPetIns:getProperty(PROPERTY_ROLELEVEL)
  self.txt_zhuan:setText(tostring(zs))
  local tx, ty = self.txt_zhuan:getPosition()
  local zSize = self.txt_zhuan:getContentSize()
  tx = tx + zSize.width
  self.txt_zhuan_title:setPosition(ccp(tx, ty))
  local ztSize = self.txt_zhuan_title:getContentSize()
  tx = tx + ztSize.width
  self.txt_level:setText(tostring(lv))
  self.txt_level:setPosition(ccp(tx, ty))
  local lSize = self.txt_level:getContentSize()
  tx = tx + lSize.width
  self.txt_level_title:setPosition(ccp(tx, ty))
end
function CPetList:SetPetShape()
  local shape = self.m_CurChoosedPetIns:getProperty(PROPERTY_SHAPE)
  local x, y = self.role_aureole:getPosition()
  local roleParent = self.role_aureole:getParent()
  local z = self.role_aureole:getZOrder()
  if self.m_DynamicLoadShape ~= shape then
    if self.m_RoleAni ~= nil then
      if self.m_RoleAni._addClickWidget then
        self.m_RoleAni._addClickWidget:removeFromParentAndCleanup(true)
        self.m_RoleAni._addClickWidget = nil
      end
      self.m_RoleAni:removeFromParentAndCleanup(true)
      self.m_RoleAni = nil
    end
    self.m_DynamicLoadShape = shape
    local path = data_getWarBodyPngPathByShape(shape, DIRECTIOIN_RIGHTDOWN)
    addDynamicLoadTexture(path, function(handlerName, texture)
      if self.__isExist and self.m_DynamicLoadShape == shape then
        if self.m_RoleAni ~= nil then
          if self.m_RoleAni._addClickWidget then
            self.m_RoleAni._addClickWidget:removeFromParentAndCleanup(true)
            self.m_RoleAni._addClickWidget = nil
          end
          self.m_RoleAni:removeFromParentAndCleanup(true)
          self.m_RoleAni = nil
        end
        local offx, offy = 0, 0
        self.m_RoleAni, offx, offy = createWarBodyByShape(shape, DIRECTIOIN_RIGHTDOWN)
        self.m_RoleAni:playAniWithName("guard_4", -1)
        roleParent:addNode(self.m_RoleAni, z + 1)
        self.m_RoleAni:setPosition(x + offx, y + offy)
        self.m_RoleAni:setOpacity(0)
        self.m_RoleAni:runAction(CCFadeIn:create(0.3))
        self:addclickAniForPetAni(self.m_RoleAni, self.role_aureole)
      end
    end)
  elseif self.m_RoleAni then
    self.m_RoleAni:playAniWithName("guard_4", -1)
    self.m_RoleAni._aniState = "guard"
    self.m_RoleAni:setOpacity(0)
    self.m_RoleAni:runAction(CCFadeIn:create(0.3))
  end
  if self.m_RoleAureole == nil then
    self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
    roleParent:addNode(self.m_RoleAureole, z)
    self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  end
  if self.m_RoleShadow == nil then
    self.m_RoleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    roleParent:addNode(self.m_RoleShadow, z)
    self.m_RoleShadow:setPosition(x, y)
  end
end
function CPetList:SetPetQuality()
  if self.m_QualityIcon ~= nil then
    self.m_QualityIcon:removeFromParent()
  end
  local iconPath = data_getPetIconPath(self.m_CurChoosedPetIns:getTypeId())
  local iconImg = display.newSprite(iconPath)
  local x, y = self.pet_quality_box:getPosition()
  local z = self.pet_quality_box:getZOrder()
  local size = self.pet_quality_box:getSize()
  local roleParent = self.pet_quality_box:getParent()
  iconImg:setAnchorPoint(ccp(0, 1))
  iconImg:setPosition(ccp(x, y + size.height))
  roleParent:addNode(iconImg, z + 10)
  self.m_QualityIcon = iconImg
end
function CPetList:SetPetExp()
  local zs = self.m_CurChoosedPetIns:getProperty(PROPERTY_ZHUANSHENG)
  local lv = self.m_CurChoosedPetIns:getProperty(PROPERTY_ROLELEVEL)
  local exp = self.m_CurChoosedPetIns:getProperty(PROPERTY_EXP)
  local maxExp = CalculatePetLevelupExp(lv, zs)
  if maxExp == nil or maxExp == 0 then
    if exp == 0 then
      maxExp = 1
    else
      maxExp = exp
    end
  end
  local p = math.round(exp / maxExp * 100)
  if p < 0 then
    p = 0
  elseif p > 100 then
    p = 100
  end
  self.pro_exp:setPercent(p)
  self.txt_expvalue:setText(string.format("%d/%d", checkint(exp), checkint(maxExp)))
  if lv >= data_getMaxPetLevel(zs) then
    self.txt_expvalue:setText("(满)")
    self.pro_exp:setPercent(100)
  end
  local size = self.pro_exp:getContentSize()
  AutoLimitObjSize(self.txt_expvalue, size.width - 20)
end
function CPetList:ReflushCurrNeiDanInfo()
  local ndList = {}
  local zbList = self.m_CurChoosedPetIns:getZhuangBei()
  for itemId, _ in pairs(zbList) do
    local itemIns = g_LocalPlayer:GetOneItem(itemId)
    if itemIns and itemIns:getType() == ITEM_LARGE_TYPE_NEIDAN then
      ndList[#ndList + 1] = itemIns
    end
  end
  table.sort(ndList, function(a, b)
    if a == nil or b == nil then
      return false
    end
    local zs_a = a:getProperty(ITEM_PRO_EQPT_ZSLIMIT)
    local zs_b = b:getProperty(ITEM_PRO_EQPT_ZSLIMIT)
    if zs_a ~= zs_b then
      return zs_a < zs_b
    else
      local lv_a = a:getProperty(ITEM_PRO_EQPT_LVLIMIT)
      local lv_b = b:getProperty(ITEM_PRO_EQPT_LVLIMIT)
      if lv_a ~= lv_b then
        return lv_a < lv_b
      else
        return a:getObjId() < b:getObjId()
      end
    end
  end)
  local zs = self.m_CurChoosedPetIns:getProperty(PROPERTY_ZHUANSHENG)
  local ndLimit = CalculatePetNeidanLimit(zs)
  for index = 1, 3 do
    local ndObj = ndList[index]
    local ndBtn = self[string.format("btn_neidan_%d", index)]
    if ndBtn._ndImage ~= nil then
      ndBtn:removeNode(ndBtn._ndImage)
      ndBtn._ndImage = nil
    end
    if ndObj then
      ndBtn:loadTextureNormal("views/rolelist/pic_neidan_show.png")
      ndBtn._ndState = ndObj:getObjId()
      local shape = ndObj:getProperty(ITEM_PRO_SHAPE)
      local imgPath = data_getItemPathByShape(shape)
      ndBtn._ndImage = display.newSprite(imgPath)
      ndBtn:addNode(ndBtn._ndImage)
      ndBtn._ndImage:setScale(0.8)
    elseif index <= ndLimit then
      ndBtn:loadTextureNormal("views/rolelist/pic_neidan_add.png")
      ndBtn._ndState = 0
    else
      ndBtn:loadTextureNormal("views/rolelist/pic_neidan_lock.png")
      ndBtn._ndState = -1
    end
  end
end
function CPetList:ReloadCurrNeiDanInfo(roleId)
  if self.m_CurChoosedPetIns == nil or self.m_CurChoosedPetIns:getObjId() ~= roleId then
    return
  end
  self:ReflushCurrNeiDanInfo()
end
function CPetList:OnBtn_NeiDan(ndState, btnIdx)
  if ndState > 0 then
    self:OnBtn_Page_ItemList()
    if self.m_PageItemList then
      self.m_PageItemList:ShowPackageDetail(ndState, true)
    end
  elseif ndState == 0 then
    self:OnBtn_Page_ItemList()
    local ndBtn = self[string.format("btn_neidan_%d", btnIdx)]
    local size = ndBtn:getContentSize()
    local ap = ndBtn:getAnchorPoint()
    local wPos = ndBtn:convertToWorldSpace(ccp(size.width * -ap.x, size.height * -ap.y))
    CAttrDetailView.new("neidan_tips", {
      x = wPos.x,
      y = wPos.y,
      w = size.width,
      h = size.height
    }, paramListener)
  else
    self:OnBtn_Page_ItemList()
    ShowNotifyTips(string.format("需要%d转开启", btnIdx - 1))
  end
end
function CPetList:OnBtn_NeiDan_1(btnObj, touchType)
  self:OnBtn_NeiDan(btnObj._ndState, 1)
end
function CPetList:OnBtn_NeiDan_2(btnObj, touchType)
  self:OnBtn_NeiDan(btnObj._ndState, 2)
end
function CPetList:OnBtn_NeiDan_3(btnObj, touchType)
  self:OnBtn_NeiDan(btnObj._ndState, 3)
end
function CPetList:OnBtn_ChangeName(btnObj, touchType)
  ShowNameBox({
    title = "为你的召唤兽取个名字:",
    minLimit = 1,
    maxLimit = 5,
    listener = handler(self, self.ChangeRoleName),
    randomFunc = nil
  })
end
function CPetList:ChangeRoleName(name)
  local petId = self.m_CurChoosedPetIns:getObjId()
  netsend.netbaseptc.setpetname(petId, name)
  ShowWarningInWar()
end
function CPetList:OnBtn_Fire(btnObj, touchType)
  local petId = g_LocalPlayer:getMainHero():getProperty(PROPERTY_PETID)
  if petId == self.m_CurChoosedPetIns:getObjId() then
    ShowNotifyTips("不能放生参战中的召唤兽")
    return
  end
  local petId = self.m_CurChoosedPetIns:getObjId()
  local name = self.m_CurChoosedPetIns:getProperty(PROPERTY_NAME)
  local petType = self.m_CurChoosedPetIns:getTypeId()
  local levelType = data_getPetLevelType(petType)
  local zs = self.m_CurChoosedPetIns:getProperty(PROPERTY_ZHUANSHENG)
  local color = NameColor_Pet[zs]
  if color == nil then
    color = ccc3(255, 255, 255)
  end
  local petTypeDict = {
    [Pet_LevelType_TSSS] = {
      "特殊神兽",
      ccc3(255, 0, 255)
    },
    [Pet_LevelType_SS] = {
      "神兽",
      ccc3(255, 0, 255)
    },
    [Pet_LevelType_Senior] = {
      "灵兽",
      ccc3(68, 187, 255)
    },
    [Pet_LevelType_Normal] = {
      "普通召唤兽",
      ccc3(255, 255, 255)
    },
    [Pet_LevelType_GJSH] = {
      "高级守护",
      ccc3(255, 255, 255)
    }
  }
  if not petTypeDict[levelType] then
    local levelTypeData = {
      "普通召唤兽",
      ccc3(255, 255, 255)
    }
  end
  local levelTypeStr = levelTypeData[1]
  local levelTypeColor = levelTypeData[2]
  local randNum = math.random(100, 999)
  local des = string.format("你确定要放生#<r:%d,g:%d,b:%d>%s#吗？\n为了防止您因误操作放生，请输入以下数字:#<R,>%d#", color.r, color.g, color.b, name, randNum)
  local petId = self.m_CurChoosedPetIns:getObjId()
  getCurSceneView():addSubView({
    subView = CFreePetConfirmView.new({
      objId = petId,
      randNum = randNum,
      des = des
    }),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CPetList:OnBtn_War(btnObj, touchType)
  local mainHeroId = g_LocalPlayer:getMainHeroId()
  if mainHeroId ~= nil then
    if JudgeIsInWar() then
      ShowNotifyTips("战斗中不能执行此操作")
      return
    end
    local petId = self.m_CurChoosedPetIns:getObjId()
    if self.btn_war._isWar then
      netsend.netbaseptc.setEquipPet(mainHeroId, 0)
    else
      netsend.netbaseptc.setEquipPet(mainHeroId, petId)
    end
  end
end
function CPetList:setWarButton(isWar)
  if isWar then
    self.btn_war:setTitleText("休息")
  else
    self.btn_war:setTitleText("参战")
  end
  self.btn_war._isWar = isWar
end
function CPetList:OnBtn_KangxingView()
  if self.m_AddPointDlg then
    self.m_AddPointDlg:CloseSelf()
    self.m_AddPointDlg = nil
  end
  if self.m_AddCloseViewObj then
    self.m_AddCloseViewObj:CloseSelf()
    self.m_AddCloseViewObj = nil
  end
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:CloseSelf()
    self.m_KangXingViewObj = nil
    return
  end
  local midPos = self:getUINode():convertToNodeSpace(ccp(display.width / 2, display.height / 2))
  local function closeFunc()
    self.m_KangXingViewObj = nil
  end
  local tempView = CHuobanKangView.new({closeFunc = closeFunc})
  local bSize = tempView:getBoxSize()
  self:addSubView({subView = tempView, zOrder = 200})
  local x, y = self:getNode("pic_leftbg"):getPosition()
  local iSize = self:getNode("pic_leftbg"):getContentSize()
  local bSize = tempView:getBoxSize()
  tempView:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
  tempView:ReSetHeroData(self.m_CurChoosedPetIns:getObjId())
  self.m_KangXingViewObj = tempView
end
function CPetList:ShowAddPoint()
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:CloseSelf()
    self.m_KangXingViewObj = nil
  end
  if self.m_AddCloseViewObj then
    self.m_AddCloseViewObj:CloseSelf()
    self.m_AddCloseViewObj = nil
  end
  if self.m_AddPointDlg or self.m_CurChoosedPetIns == nil then
    self.m_AddPointDlg:CloseSelf()
    self.m_AddPointDlg = nil
    return
  end
  self.m_AddPointDlg = CAddPoint.new(handler(self, self.OnAddPointClose))
  self:addSubView({
    subView = self.m_AddPointDlg,
    zOrder = 200
  })
  local x, y = self:getNode("pic_leftbg"):getPosition()
  local iSize = self:getNode("pic_leftbg"):getContentSize()
  local bSize = self.m_AddPointDlg:getContentSize()
  self.m_AddPointDlg:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
  self.m_AddPointDlg:LoadProperties(self.m_CurChoosedPetIns)
end
function CPetList:OnAddPointClose()
  self.m_AddPointDlg = nil
end
function CPetList:ShowAddClose()
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:CloseSelf()
    self.m_KangXingViewObj = nil
  end
  if self.m_AddPointDlg then
    self.m_AddPointDlg:CloseSelf()
    self.m_AddPointDlg = nil
  end
  if self.m_AddCloseViewObj or self.m_CurChoosedPetIns == nil then
    self.m_AddCloseViewObj:CloseSelf()
    self.m_AddCloseViewObj = nil
    return
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_XunYang)
  if openFlag == false then
    ShowNotifyTips(tips)
    return
  end
  self.m_AddCloseViewObj = CAddClose.new(handler(self, self.OnAddCloseViewClose))
  self:addSubView({
    subView = self.m_AddCloseViewObj,
    zOrder = 200
  })
  local x, y = self:getNode("pic_leftbg"):getPosition()
  local iSize = self:getNode("pic_leftbg"):getContentSize()
  local bSize = self.m_AddCloseViewObj:getContentSize()
  self.m_AddCloseViewObj:setPosition(ccp(x + iSize.width / 2 - bSize.width, y - bSize.height / 2))
  self.m_AddCloseViewObj:LoadProperties(self.m_CurChoosedPetIns)
end
function CPetList:OnAddCloseViewClose()
  self.m_AddCloseViewObj = nil
end
function CPetList:OnBtn_Attr(btnObj, touchType)
  if self.m_CurChoosedPetIns == nil then
    return
  end
  local petId = self.m_CurChoosedPetIns:getObjId()
  if self.m_BasePageAttr == nil then
    self.m_BasePageAttr = CPetList_BaseAttr.new(petId, self)
    self:addChildObjByControl(self.m_BasePageAttr, self.poslayer_base)
  else
    self.m_BasePageAttr:LoadPet(petId)
  end
  self:ShowBasePage(self.m_BasePageAttr)
  self:setGroupBtnSelected(self.btn_attr)
end
function CPetList:OnBtn_Potential(btnObj, touchType)
  if self.m_CurChoosedPetIns == nil then
    return
  end
  local petId = self.m_CurChoosedPetIns:getObjId()
  if self.m_BasePagePotential == nil then
    self.m_BasePagePotential = CPetList_BasePotential.new(petId)
    self:addChildObjByControl(self.m_BasePagePotential, self.poslayer_base)
  else
    self.m_BasePagePotential:LoadPet(petId)
  end
  self:ShowBasePage(self.m_BasePagePotential)
  self:setGroupBtnSelected(self.btn_potential)
end
function CPetList:OnBtn_Skill(btnObj, touchType)
  if self.m_CurChoosedPetIns == nil then
    return
  end
  local petId = self.m_CurChoosedPetIns:getObjId()
  if self.m_BasePageSkill == nil then
    self.m_BasePageSkill = CPetList_BaseSkill.new(petId)
    self:addChildObjByControl(self.m_BasePageSkill, self.poslayer_base)
  else
    self.m_BasePageSkill:LoadPet(petId)
  end
  self:ShowBasePage(self.m_BasePageSkill)
  self:setGroupBtnSelected(self.btn_skill)
end
function CPetList:OnBtn_SkillLearn(btnObj, touchType)
  if self.m_CurChoosedPetIns == nil then
    return
  end
  local petId = self.m_CurChoosedPetIns:getObjId()
  if self.m_BasePageSkillLearn == nil then
    self.m_BasePageSkillLearn = CPetList_BaseSkillLearn.new(petId)
    self:addChildObjByControl(self.m_BasePageSkillLearn, self.poslayer_base)
  else
    self.m_BasePageSkillLearn:LoadPet(petId)
  end
  self:ShowBasePage(self.m_BasePageSkillLearn)
  self:setGroupBtnSelected(self.btn_skilllearn)
end
function CPetList:ShowBasePage(basePage)
  if self.m_BasePageAttr then
    self.m_BasePageAttr:setEnabled(self.m_BasePageAttr == basePage)
  end
  if self.m_BasePagePotential then
    self.m_BasePagePotential:setEnabled(self.m_BasePagePotential == basePage)
  end
  if self.m_BasePageSkill then
    self.m_BasePageSkill:setEnabled(self.m_BasePageSkill == basePage)
  end
  if self.m_BasePageSkillLearn then
    self.m_BasePageSkillLearn:setEnabled(self.m_BasePageSkillLearn == basePage)
  end
  self.m_CurSelectBasePage = basePage
end
function CPetList:getPageSkillLearn()
  return self.m_BasePageSkillLearn
end
function CPetList:OnBtn_Page_ItemList(btnObj, touchType, showAttr)
  if self.m_CurChoosedPetIns == nil then
    ShowNotifyTips("你还没有召唤兽")
    return
  end
  self.title_p1:setPosition(self.titleUpPos)
  self.title_p1:setText("宠物")
  self.title_p2:setText("属性")
  if showAttr ~= false then
    self:OnBtn_Attr()
  end
  local petId = self.m_CurChoosedPetIns:getObjId()
  if self.m_PageItemList == nil then
    self.m_PageItemList = CPetList_PageItemList.new(petId, self)
    self:addChildObjByControl(self.m_PageItemList, self.poslayer_right)
  else
    self.m_PageItemList:LoadPet(petId)
  end
  self:ShowRightPage(self.m_PageItemList)
  self:setGroupBtnSelected(self.btn_page_attr)
end
function CPetList:OnBtn_Page_XiChong(btnObj, touchType)
  if self.m_CurChoosedPetIns == nil then
    ShowNotifyTips("你还没有召唤兽")
    return
  end
  self.title_p1:setPosition(self.titleMidPos)
  self.title_p1:setText("洗宠")
  self.title_p2:setText(" ")
  self:OnBtn_Potential()
  local petId = self.m_CurChoosedPetIns:getObjId()
  if self.m_PageXiChong == nil then
    self.m_PageXiChong = CPetList_PageXiChong.new(petId, self, self.m_BasePagePotential)
    self:addChildObjByControl(self.m_PageXiChong, self.poslayer_right)
  else
    self.m_PageXiChong:LoadPet(petId)
  end
  self:ShowRightPage(self.m_PageXiChong)
  self:setGroupBtnSelected(self.btn_page_xichong)
end
function CPetList:OnBtn_Page_LianYao(btnObj, touchType)
  if self.m_CurChoosedPetIns == nil then
    ShowNotifyTips("你还没有召唤兽")
    return
  end
  self.title_p1:setPosition(self.titleMidPos)
  self.title_p1:setText("炼妖")
  self.title_p2:setText(" ")
  if self.m_BasePageAttr == nil then
    self:OnBtn_Attr()
  end
  local petId = self.m_CurChoosedPetIns:getObjId()
  if self.m_PageLianYaoList == nil then
    self.m_PageLianYaoList = CPetList_PageLianYao.new(petId, self)
    self:addChildObjByControl(self.m_PageLianYaoList, self.poslayer_right)
  else
    self.m_PageLianYaoList:LoadPet(petId)
  end
  self:ShowRightPage(self.m_PageLianYaoList)
  self:setGroupBtnSelected(self.btn_page_lianyao)
end
function CPetList:OnBtn_Page_TuJian(btnObj, touchType)
  self:SetShow(false)
  if g_PetListDisplayDlg == nil then
    getCurSceneView():addSubView({
      subView = CPetListDisplay.new(self.m_InitTujianPet),
      zOrder = MainUISceneZOrder.menuView
    })
  end
  self.title_p1:setPosition(self.titleMidPos)
  self.title_p1:setText("图鉴")
  self.title_p2:setText(" ")
  g_PetListDisplayDlg:SetShow(true)
end
function CPetList:ShowRightPage(rightPage)
  if self.m_PageItemList then
    self.m_PageItemList:setEnabled(self.m_PageItemList == rightPage)
  end
  if self.m_PageXiChong then
    self.m_PageXiChong:setEnabled(self.m_PageXiChong == rightPage)
  end
  if self.m_PageLianYaoList then
    self.m_PageLianYaoList:setEnabled(self.m_PageLianYaoList == rightPage)
  end
  self.m_CurSelectRightPage = rightPage
  self:setGroupBtnSelected(self.btn_page_tujian)
end
function CPetList:addChildObjByControl(obj, ctrObj)
  local parent = ctrObj:getParent()
  local x, y = ctrObj:getPosition()
  local zOrder = ctrObj:getZOrder()
  parent:addChild(obj.m_UINode, zOrder)
  obj:setPosition(ccp(x, y))
end
function CPetList:SetShow(iShow)
  if self.m_UINode ~= nil then
    self:setVisible(iShow)
    self._auto_create_opacity_bg_ins:setVisible(iShow)
  end
end
function CPetList:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CPetList:Clear()
  print("CPetList Clear")
  if g_PetListDisplayDlg then
    g_PetListDisplayDlg:CloseSelf()
  end
  if self.m_CloseCallBackFunc then
    self.m_CloseCallBackFunc()
  end
  if g_PetListDlg == self then
    g_PetListDlg = nil
  end
  if g_PetListZhiYuanDlg then
    g_PetListZhiYuanDlg:CloseSelf()
  end
end
