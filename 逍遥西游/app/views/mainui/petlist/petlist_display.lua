g_CanGetNewPetFlag = true
g_PetListDisplayDlg = nil
CPetListDisplay = class(".CPetListDisplay", CcsSubView)
function CPetListDisplay:ctor(tujianPet)
  CPetListDisplay.super.ctor(self, "views/pet_list_display.json", {isAutoCenter = true, opacityBg = 100})
  clickArea_check.extend(self)
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_normal = {
      listener = handler(self, self.OnBtn_Normal),
      variName = "btn_normal"
    },
    btn_special = {
      listener = handler(self, self.OnBtn_Special),
      variName = "btn_special"
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
    },
    btn_get = {
      listener = handler(self, self.OnBtn_GetPet),
      variName = "btn_get"
    },
    btn_catch = {
      listener = handler(self, self.OnBtn_CatchPet),
      variName = "btn_catch"
    },
    btn_market = {
      listener = handler(self, self.OnBtn_Market),
      variName = "btn_market"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_page_attr:setTitleText("宠\n物\n属\n性")
  self.btn_page_xichong:setTitleText("洗\n宠")
  self.btn_page_lianyao:setTitleText("炼\n妖")
  self.btn_page_tujian:setTitleText("图\n鉴")
  self.btn_special:setTitleText("神兽")
  self:addBtnSigleSelectGroup({
    {
      self.btn_normal,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -2)
    },
    {
      self.btn_special,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -2)
    }
  })
  self:addBtnSigleSelectGroup({
    {
      self.btn_page_attr,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_page_xichong,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_page_lianyao,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_page_tujian,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.poslayer_list = self:getNode("poslayer_list")
  self.role_aureole = self:getNode("role_aureole")
  self.pet_quality_box = self:getNode("pet_quality_box")
  self.skillpos = self:getNode("skillpos")
  self.txt_name = self:getNode("txt_name")
  self.txt_czl = self:getNode("txt_czl")
  self.txt_qx = self:getNode("txt_qx")
  self.txt_fl = self:getNode("txt_fl")
  self.txt_gj = self:getNode("txt_gj")
  self.txt_sd = self:getNode("txt_sd")
  self.title_openlevel = self:getNode("title_openlevel")
  self.text_price_title = self:getNode("text_price_title")
  self.text_price_bg = self:getNode("text_price_bg")
  self.text_price_icon = self:getNode("text_price_icon")
  self.text_price = self:getNode("text_price")
  self.item_icon = self:getNode("item_icon")
  self.item_num = self:getNode("item_num")
  self.text_catchtip = self:getNode("text_catchtip")
  self.item_icon:setVisible(false)
  self.text_price_icon:setVisible(false)
  self.text_price_icon:setTouchEnabled(false)
  local x, y = self.text_price_icon:getPosition()
  local z = self.text_price_icon:getZOrder()
  local size = self.text_price_icon:getSize()
  self.m_CoinIcon = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  self.m_CoinIcon:setAnchorPoint(ccp(0.5, 0.5))
  self.m_CoinIcon:setScale(size.width / self.m_CoinIcon:getContentSize().width)
  self.m_CoinIcon:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(self.m_CoinIcon, z)
  self.poslayer_list:setVisible(false)
  self.role_aureole:setVisible(false)
  self.pet_quality_box:setVisible(false)
  self.skillpos:setVisible(false)
  self.m_ChoosePet = nil
  self.m_PetSkill = {}
  local initPet = false
  self.m_InitTujianPet = tujianPet
  for petTypeId, data in pairs(data_Pet) do
    if self.m_InitTujianPet == petTypeId then
      initPet = true
      if data_getPetTypeIsShenShou(petTypeId) or data_getPetTypeIsTeShuShenShou(petTypeId) then
        self:OnBtn_Special()
        break
      end
      self:OnBtn_Normal()
      break
    end
  end
  if not initPet then
    self:OnBtn_Normal()
  end
  self.m_InitTujianPet = nil
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_MoveScene)
  self:ListenMessage(MsgID_ChongZhi)
  if g_PetListDisplayDlg ~= nil then
    g_PetListDisplayDlg:CloseSelf()
  end
  g_PetListDisplayDlg = self
end
function CPetListDisplay:SetAttrTips()
  self:attrclick_check_withWidgetObj(self:getNode("title_czl"), PROPERTY_GROWUP)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_czl"), PROPERTY_GROWUP, self:getNode("title_czl"))
  self:attrclick_check_withWidgetObj(self:getNode("title_qx"), PROPERTY_RANDOM_HPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_qx"), PROPERTY_RANDOM_HPBASE, self:getNode("title_qx"))
  self:attrclick_check_withWidgetObj(self:getNode("title_fl"), PROPERTY_RANDOM_MPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_fl"), PROPERTY_RANDOM_MPBASE, self:getNode("title_fl"))
  self:attrclick_check_withWidgetObj(self:getNode("title_gj"), PROPERTY_RANDOM_APBASE)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_gj"), PROPERTY_RANDOM_APBASE, self:getNode("title_gj"))
  self:attrclick_check_withWidgetObj(self:getNode("title_sd"), PROPERTY_RANDOM_SPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_sd"), PROPERTY_RANDOM_SPBASE, self:getNode("title_sd"))
  self:attrclick_check_withWidgetObj(self:getNode("text_price_bg"), "rescoin")
end
function CPetListDisplay:OnMessage(msgSID, ...)
  if msgSID == MsgID_ItemSource_Jump then
    local arg = {
      ...
    }
    local d = arg[1][1]
    for _, t in pairs(Item_Source_MoveMapList) do
      if d == t then
        self:OnBtn_Close()
        break
      end
    end
  elseif msgSID == MsgID_MoneyUpdate then
    local arg = {
      ...
    }
    local d = arg[1]
    if self.m_GetWay == 1 and d.newCoin ~= nil then
      self:FreshGetWay()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local arg = {
      ...
    }
    local itemTypeId = arg[2]
    if self.m_GetWay == 2 and self.m_ItemIcon and self.m_ItemIcon._itemTypeId == itemTypeId then
      self:FreshGetWay()
    end
  elseif msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    local arg = {
      ...
    }
    local itemTypeId = arg[3]
    if self.m_GetWay == 2 and self.m_ItemIcon and self.m_ItemIcon._itemTypeId == itemTypeId then
      self:FreshGetWay()
    end
  elseif msgSID == MsgID_AddPet then
    self.m_UINode:getParent():reorderChild(self.m_UINode, MainUISceneZOrder.menuView)
  elseif msgSID == MsgID_ChongZhiFanli_Update and self.m_ChoosePet == 20030 then
    self:SetShowOpenMapInfo(-1)
  end
end
function CPetListDisplay:LoadPet(lTypeId, force)
  if lTypeId == nil then
    return
  end
  if force ~= true and self.m_ChoosePet == lTypeId then
    return
  end
  self.m_ChoosePet = lTypeId
  local petData = data_Pet[self.m_ChoosePet]
  if petData == nil then
    ShowNotifyTips("此召唤兽不存在")
    return
  end
  self:SetPetName(petData)
  self:SetPetShape()
  self:SetPetQuality()
  self:SetPotential(petData)
  self:SetSkill(petData)
  self:SetGetWay(petData)
  self:SetWuxing(petData)
end
function CPetListDisplay:FreshGetWay()
  local petData = data_Pet[self.m_ChoosePet]
  if petData == nil then
    return
  end
  self:SetGetWay(petData)
end
function CPetListDisplay:SetPetName(petData)
  self.txt_name:setText(petData.NAME or "")
end
function CPetListDisplay:SetPetShape()
  local x, y = self.role_aureole:getPosition()
  local roleParent = self.role_aureole:getParent()
  local z = self.role_aureole:getZOrder()
  if self.m_RoleAni ~= nil then
    if self.m_RoleAni._addClickWidget then
      self.m_RoleAni._addClickWidget:removeFromParentAndCleanup(true)
      self.m_RoleAni._addClickWidget = nil
    end
    self.m_RoleAni:removeFromParentAndCleanup(true)
    self.m_RoleAni = nil
  end
  local shape = data_getRoleShape(self.m_ChoosePet)
  self.m_DynamicLoadShape = shape
  local path = data_getWarBodyPngPathByShape(shape, DIRECTIOIN_RIGHTDOWN)
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.__isExist and self.m_DynamicLoadShape == shape then
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
function CPetListDisplay:SetPetQuality()
  if self.m_QualityIcon ~= nil then
    self.m_QualityIcon:removeFromParent()
  end
  local iconPath = data_getPetIconPath(self.m_ChoosePet)
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
function CPetListDisplay:SetPotential(petData)
  if data_getPetTypeIsShenShou(self.m_ChoosePet) or data_getPetTypeIsTeShuShenShou(self.m_ChoosePet) then
    self.txt_czl:setText(string.format("%s", Value2Str(petData.GROWUP * 1.02, 3)))
    local qx_max = math.floor(petData.HP * 1.2 + 1.0E-8)
    self.txt_qx:setText(string.format("%d", qx_max))
    local fl_max = math.floor(petData.MP * 1.2 + 1.0E-8)
    self.txt_fl:setText(string.format("%d", fl_max))
    local gj_max = math.floor(petData.AP * 1.2 + 1.0E-8)
    self.txt_gj:setText(string.format("%d", gj_max))
    local sd_max = math.floor(petData.SP * 1.2 + 1.0E-8)
    self.txt_sd:setText(string.format("%d", sd_max))
  else
    self.txt_czl:setText(string.format("%s - %s", Value2Str(petData.GROWUP * 0.98, 3), Value2Str(petData.GROWUP * 1.02, 3)))
    local qx_min = math.floor(petData.HP * 0.8 + 1.0E-8)
    local qx_max = math.floor(petData.HP * 1.2 + 1.0E-8)
    self.txt_qx:setText(string.format("%d - %d", qx_min, qx_max))
    local fl_min = math.floor(petData.MP * 0.8 + 1.0E-8)
    local fl_max = math.floor(petData.MP * 1.2 + 1.0E-8)
    self.txt_fl:setText(string.format("%d - %d", fl_min, fl_max))
    local gj_min = math.floor(petData.AP * 0.8 + 1.0E-8)
    local gj_max = math.floor(petData.AP * 1.2 + 1.0E-8)
    self.txt_gj:setText(string.format("%d - %d", gj_min, gj_max))
    local sd_min = math.floor(petData.SP * 0.8 + 1.0E-8)
    local sd_max = math.floor(petData.SP * 1.2 + 1.0E-8)
    self.txt_sd:setText(string.format("%d - %d", sd_min, sd_max))
  end
end
function CPetListDisplay:SetSkill(petData)
  for _, skillObj in pairs(self.m_PetSkill) do
    skillObj:removeFromParentAndCleanup(true)
  end
  self.m_PetSkill = {}
  local skills = petData.skills
  if skills ~= nil then
    local parent = self.skillpos:getParent()
    local ox, oy = self.skillpos:getPosition()
    local zOrder = self.skillpos:getZOrder()
    local x, y = ox, oy
    for i, skillId in ipairs(skills) do
      if skillId ~= 0 then
        local skillIcon = createClickSkill({
          skillID = skillId,
          LongPressTime = 0.2,
          roleTypeId = self.m_ChoosePet
        })
        parent:addChild(skillIcon, zOrder)
        skillIcon:setPosition(ccp(x, y))
        local size = skillIcon:getContentSize()
        self.m_PetSkill[#self.m_PetSkill + 1] = skillIcon
        if i % 2 == 0 then
          x = ox
          y = y - size.height - 20
        else
          x = x + size.width + 20
        end
      end
    end
  end
end
function CPetListDisplay:SetGetWay(petData)
  local openlv = petData.OPENLV
  self.title_openlevel:setText(string.format("等级要求:%d", openlv))
  if self.m_ChoosePet == 20030 then
    self:SetShowOpenCoinInfo(nil)
    self:SetShowOpenItemInfo(nil)
    self:SetShowOpenMapInfo(-1)
    self.btn_get:setVisible(false)
    self.btn_get:setTouchEnabled(false)
    self.m_GetWay = 4
  elseif data_getPetTypeIsTeShuShenShou(self.m_ChoosePet) then
    self:SetShowOpenCoinInfo(nil)
    self:SetShowOpenItemInfo(nil)
    self:SetShowOpenMapInfo(-1)
    self.btn_get:setVisible(false)
    self.btn_get:setTouchEnabled(false)
    self.m_GetWay = 5
  elseif petData.CATCHMAP ~= 0 and petData.CATCHMAP ~= nil then
    self:SetShowOpenCoinInfo(nil)
    self:SetShowOpenItemInfo(nil)
    self:SetShowOpenMapInfo(petData.CATCHMAP)
    self.btn_get:setVisible(false)
    self.btn_get:setTouchEnabled(false)
    self.m_GetWay = 3
  elseif 0 < petData.OPENCOIN then
    self:SetShowOpenCoinInfo(petData.OPENCOIN)
    self:SetShowOpenItemInfo(nil)
    self:SetShowOpenMapInfo(nil)
    self.btn_get:setTitleText("购买")
    self.btn_get:setVisible(true)
    self.btn_get:setTouchEnabled(true)
    self.m_GetWay = 1
  elseif 0 < petData.OPENLSP then
    self:SetShowOpenCoinInfo(nil)
    self:SetShowOpenItemInfo(ITEM_DEF_STUFF_LSSP, petData.OPENLSP)
    self:SetShowOpenMapInfo(nil)
    self.btn_get:setTitleText("获得")
    self.btn_get:setVisible(true)
    self.btn_get:setTouchEnabled(true)
    self.m_GetWay = 2
  elseif 0 < petData.OPENSSP then
    self:SetShowOpenCoinInfo(nil)
    self:SetShowOpenItemInfo(ITEM_DEF_STUFF_SSSP, petData.OPENSSP)
    self:SetShowOpenMapInfo(nil)
    self.btn_get:setTitleText("获得")
    self.btn_get:setVisible(true)
    self.btn_get:setTouchEnabled(true)
    self.m_GetWay = 2
  else
    self:SetShowOpenCoinInfo(nil)
    self:SetShowOpenItemInfo(nil)
    self:SetShowOpenMapInfo(nil)
    self.btn_get:setVisible(false)
    self.btn_get:setTouchEnabled(false)
    self.m_GetWay = 0
  end
end
function CPetListDisplay:SetWuxing(petData)
  local x, y = self:getNode("wxpos"):getPosition()
  local size = self:getNode("wxpos"):getContentSize()
  local titleColor = ccc3(78, 47, 20)
  local et1 = "      "
  if petData.WXJIN == 0 then
    et1 = "        "
  elseif petData.WXJIN == 1 then
    et1 = "    "
  end
  local et2 = "      "
  if petData.WXSHUI == 0 then
    et2 = "        "
  elseif petData.WXSHUI == 1 then
    et2 = "    "
  end
  local txt = string.format("金:%d%%%s木:%d%%\n水:%d%%%s火:%d%%\n土:%d%%", petData.WXJIN * 100, et1, petData.WXMU * 100, petData.WXSHUI * 100, et2, petData.WXHUO * 100, petData.WXTU * 100)
  if self.m_WuXingText == nil then
    self.m_WuXingText = CRichText.new({
      width = size.width,
      font = KANG_TTF_FONT,
      fontSize = 22,
      color = titleColor
    })
    self.m_WuXingText:addRichText(txt)
    self:addChild(self.m_WuXingText, 10)
    self.m_WuXingText:setPosition(ccp(x, y - 5))
    self:getNode("wxpos"):setVisible(false)
  else
    self.m_WuXingText:clearAll()
    self.m_WuXingText:addRichText(txt)
  end
end
function CPetListDisplay:SetShowOpenMapInfo(mapId)
  if mapId == 0 or mapId == nil then
    self.text_catchtip:setVisible(false)
    self.btn_catch:setVisible(false)
    self.btn_catch:setTouchEnabled(false)
    self.btn_market:setVisible(false)
    self.btn_market:setTouchEnabled(false)
  elseif mapId == -1 then
    if data_getPetTypeIsTeShuShenShou(self.m_ChoosePet) then
      self.text_catchtip:setVisible(true)
      self.btn_catch:setVisible(false)
      self.btn_catch:setTouchEnabled(false)
      self.text_catchtip:setText("来源:特殊活动")
      self.btn_market:setVisible(true)
      self.btn_market:setTouchEnabled(true)
      self.btn_market:setTitleText("特殊活动")
    else
      self.text_catchtip:setVisible(true)
      self.btn_catch:setVisible(false)
      self.btn_catch:setTouchEnabled(false)
      self.text_catchtip:setText("来源:首次充值奖励")
      local fanliData = g_LocalPlayer:getFanliData()
      local qxxzState = fanliData[1]
      self.m_QxxzState = qxxzState
      if qxxzState == 1 then
        self.btn_market:setVisible(true)
        self.btn_market:setTouchEnabled(true)
        self.btn_market:setTitleText("前往充值")
      elseif qxxzState == 2 then
        self.btn_market:setVisible(true)
        self.btn_market:setTouchEnabled(true)
        self.btn_market:setTitleText("领取")
      elseif qxxzState == 3 then
        self.btn_market:setVisible(false)
        self.btn_market:setTouchEnabled(false)
      end
    end
  else
    self.text_catchtip:setVisible(true)
    self.btn_catch:setVisible(true)
    self.btn_catch:setTouchEnabled(true)
    self.btn_market:setVisible(true)
    self.btn_market:setTouchEnabled(true)
    self.btn_market:setTitleText("市场购买")
    local mapName = ""
    if data_CustomMapPos[mapId] ~= nil then
      mapName = data_CustomMapPos[mapId].SceneName or ""
    end
    self.text_catchtip:setText(string.format("栖息地:%s", mapName))
  end
end
function CPetListDisplay:SetShowOpenCoinInfo(coinNum)
  if coinNum == nil then
    self.text_price_title:setVisible(false)
    self.text_price_bg:setVisible(false)
    self.text_price_icon:setVisible(false)
    self.text_price:setVisible(false)
    self.m_CoinIcon:setVisible(false)
  else
    self.text_price:setText(tostring(coinNum))
    local myNum = g_LocalPlayer:getCoin()
    if coinNum > myNum then
      self.text_price:setColor(VIEW_DEF_WARNING_COLOR)
    else
      self.text_price:setColor(ccc3(255, 255, 255))
    end
    self.text_price_title:setVisible(true)
    self.text_price_bg:setVisible(true)
    self.text_price_icon:setVisible(true)
    self.text_price:setVisible(true)
    self.m_CoinIcon:setVisible(true)
  end
end
function CPetListDisplay:SetShowOpenItemInfo(itemTypeId, itemNum)
  if itemTypeId == nil then
    self.item_num:setVisible(false)
    if self.m_ItemIcon then
      self.m_ItemIcon:setVisible(false)
      self.m_ItemIcon:setTouchEnabled(false)
    end
  else
    local myNum = g_LocalPlayer:GetItemNum(itemTypeId)
    self.item_num:setVisible(true)
    self.item_num:setText(string.format("%d/%d", myNum, itemNum))
    if itemNum > myNum then
      self.item_num:setColor(VIEW_DEF_WARNING_COLOR)
    else
      self.item_num:setColor(ccc3(255, 255, 255))
    end
    if self.m_ItemIcon and self.m_ItemIcon._itemTypeId == itemTypeId then
      self.m_ItemIcon:setVisible(true)
      self.m_ItemIcon:setTouchEnabled(true)
      return
    end
    if self.m_ItemIcon then
      self.m_ItemIcon:removeFromParentAndCleanup(true)
    end
    local x, y = self.item_icon:getPosition()
    local parent = self.item_icon:getParent()
    local zOrder = self.item_icon:getZOrder()
    self.m_ItemIcon = createClickItem({
      itemID = itemTypeId,
      autoSize = nil,
      num = 0,
      LongPressTime = nil,
      clickListener = function()
        self:OnClickItem(itemTypeId)
      end,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = false
    })
    parent:addChild(self.m_ItemIcon, zOrder)
    self.m_ItemIcon:setPosition(ccp(x, y))
    self.m_ItemIcon._itemTypeId = itemTypeId
  end
end
function CPetListDisplay:OnClickItem(itemTypeId)
  if self.m_ItemDetail ~= nil then
    self.m_ItemDetail:removeFromParentAndCleanup(true)
    self.m_ItemDetail = nil
  end
  self.m_ItemDetail = CEquipDetail.new(nil, {
    itemType = itemTypeId,
    leftBtn = nil,
    rightBtn = nil,
    closeListener = handler(self, self.OnItemDetailClosed)
  })
  self:addSubView({
    subView = self.m_ItemDetail,
    zOrder = 9999
  })
  local size = self.m_ItemDetail:getBoxSize()
  self.m_ItemDetail:setPosition(ccp(display.width / 2 - size.width / 2, display.height / 2 - size.height / 2))
end
function CPetListDisplay:OnItemDetailClosed(obj)
  if self.m_ItemDetail == obj then
    self.m_ItemDetail = nil
  end
end
function CPetListDisplay:OnSelectPet(petTypeId)
  self:LoadPet(petTypeId)
  if self.m_PetListBoard_Normal then
    self.m_PetListBoard_Normal:ClearSelectItem()
  end
  if self.m_PetListBoard_Special then
    self.m_PetListBoard_Special:ClearSelectItem()
  end
end
function CPetListDisplay:OnBtn_Normal(btnObj, touchType)
  if self.m_PetListBoard_Normal == nil then
    local lTypeList = {}
    for petTypeId, data in pairs(data_Pet) do
      if data_getPetTypeIsShenShou(petTypeId) or data_getPetTypeIsTeShuShenShou(petTypeId) then
      else
        lTypeList[#lTypeList + 1] = petTypeId
      end
    end
    self.m_PetListBoard_Normal = CDisplayPetBoard.new({
      petTypeList = lTypeList,
      clickListener = handler(self, self.OnSelectPet),
      xySpace = ccp(22, 22),
      initType = self.m_InitTujianPet
    })
    self:addChildObjByControl(self.m_PetListBoard_Normal, self.poslayer_list)
  end
  self.m_PetListBoard_Normal:setVisible(true)
  self.m_PetListBoard_Normal:setTouchEnabled(true)
  if self.m_PetListBoard_Special then
    self.m_PetListBoard_Special:setVisible(false)
    self.m_PetListBoard_Special:setTouchEnabled(false)
  end
  self:setGroupBtnSelected(self.btn_normal)
end
function CPetListDisplay:OnBtn_Special(btnObj, touchType)
  if self.m_PetListBoard_Special == nil then
    local lTypeList = {}
    for petTypeId, data in pairs(data_Pet) do
      if data_getPetTypeIsShenShou(petTypeId) or data_getPetTypeIsTeShuShenShou(petTypeId) then
        lTypeList[#lTypeList + 1] = petTypeId
      end
    end
    self.m_PetListBoard_Special = CDisplayPetBoard.new({
      petTypeList = lTypeList,
      clickListener = handler(self, self.OnSelectPet),
      xySpace = ccp(22, 22),
      initType = self.m_InitTujianPet
    })
    self:addChildObjByControl(self.m_PetListBoard_Special, self.poslayer_list)
  end
  self.m_PetListBoard_Special:setVisible(true)
  self.m_PetListBoard_Special:setTouchEnabled(true)
  if self.m_PetListBoard_Normal then
    self.m_PetListBoard_Normal:setVisible(false)
    self.m_PetListBoard_Normal:setTouchEnabled(false)
  end
  self:setGroupBtnSelected(self.btn_special)
end
function CPetListDisplay:OnBtn_Page_ItemList(btnObj, touchType)
  local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  if #petIds <= 0 then
    ShowNotifyTips("你还有没有召唤兽")
    self:setGroupBtnSelected(self.btn_page_tujian)
    return
  end
  self:setGroupBtnSelected(self.btn_page_attr)
  self:SetShow(false)
  if g_PetListDlg then
    g_PetListDlg:SetShow(true)
    g_PetListDlg:OnBtn_Page_ItemList()
  end
end
function CPetListDisplay:OnBtn_Page_XiChong(btnObj, touchType)
  local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  if #petIds <= 0 then
    ShowNotifyTips("你还有没有召唤兽")
    self:setGroupBtnSelected(self.btn_page_tujian)
    return
  end
  self:setGroupBtnSelected(self.btn_page_xichong)
  self:SetShow(false)
  if g_PetListDlg then
    g_PetListDlg:SetShow(true)
    g_PetListDlg:OnBtn_Page_XiChong()
  end
end
function CPetListDisplay:OnBtn_Page_LianYao(btnObj, touchType)
  local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  if #petIds <= 0 then
    ShowNotifyTips("你还有没有召唤兽")
    self:setGroupBtnSelected(self.btn_page_tujian)
    return
  end
  self:SetShow(false)
  if g_PetListDlg then
    g_PetListDlg:SetShow(true)
    g_PetListDlg:OnBtn_Page_LianYao()
  end
end
function CPetListDisplay:OnBtn_Page_TuJian(btnObj, touchType)
  self:setGroupBtnSelected(self.btn_page_tujian)
end
function CPetListDisplay:OnBtn_GetPet(btnObj, touchType)
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  local petNumLimit = data_getMaxPetNum(zs) + g_LocalPlayer:GetPetLimitNum()
  if petNumLimit <= #petIds then
    if zs <= 0 then
      ShowNotifyTips(string.format("召唤兽超过上限%d个,1转后上限增加至%d个", petNumLimit, data_getMaxPetNum(1) + g_LocalPlayer:GetPetLimitNum()))
    else
      ShowNotifyTips(string.format("召唤兽超过上限%d个,无法获得", petNumLimit))
    end
    return
  end
  local petData = data_Pet[self.m_ChoosePet]
  if petData == nil then
    ShowNotifyTips("此召唤兽不存在")
    return
  end
  local openlv = petData.OPENLV
  if zs <= 0 and mainHero:getProperty(PROPERTY_ROLELEVEL) < petData.OPENLV then
    ShowNotifyTips(string.format("需要等级%d", petData.OPENLV))
    return
  end
  if g_CanGetNewPetFlag == false then
    return
  end
  g_CanGetNewPetFlag = false
  netsend.netbaseptc.requestNewPet(self.m_ChoosePet)
end
function CPetListDisplay:OnBtn_CatchPet(btnObj, touchType)
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local petData = data_Pet[self.m_ChoosePet]
  if petData == nil then
    ShowNotifyTips("此召唤兽不存在")
    return
  end
  local openlv = petData.OPENLV
  if zs <= 0 and mainHero:getProperty(PROPERTY_ROLELEVEL) < petData.OPENLV then
    ShowNotifyTips(string.format("需要等级%d", petData.OPENLV))
    return
  end
  if data_getPetTypeIsGaoJiShouHu(self.m_ChoosePet) then
    local lifeSkill, _ = g_LocalPlayer:getBaseLifeSkill()
    if lifeSkill ~= LIFESKILL_CATCH then
      ShowNotifyTips("习得捉宠技能后才能捕捉")
      return
    end
  end
  if petData.CATCHMAP ~= 0 then
    self:CloseSelf()
    local sID = data_CustomMapPos[petData.CATCHMAP].SceneID
    if g_MapMgr then
      g_MapMgr:AskToEnterGuaji(sID, nil, nil, nil, true)
    end
  end
end
function CPetListDisplay:OnBtn_Market(btnObj, touchType)
  if self.m_GetWay == 5 then
    if data_getPetTypeIsTeShuShenShou(self.m_ChoosePet) and g_LocalPlayer then
      local hasTSSSFlag = false
      local ssData = g_LocalPlayer:getPaiMaiShenShouData()
      for i, petData in pairs(ssData) do
        if self.m_ChoosePet == petData.i_pet and self.m_ChoosePet ~= nil then
          hasTSSSFlag = true
          break
        end
      end
      if g_LocalPlayer:JudgeCanGetPaiMaiShenShou() and hasTSSSFlag then
        ShowPopBuyGiftPopView(POP_Show_PAIMAITSSS)
      else
        ShowNotifyTips("不在活动时间")
      end
    end
    return
  end
  if self.m_GetWay == 4 then
    if self.m_QxxzState == 1 then
      ShowRechargeView({resType = RESTYPE_GOLD})
    elseif self.m_QxxzState == 2 then
      netsend.netbaseptc.GetChongZhiFanliAward(1)
    else
      self:SetShowOpenMapInfo(-1)
    end
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local petData = data_Pet[self.m_ChoosePet]
  if petData == nil then
    ShowNotifyTips("此召唤兽不存在")
    return
  end
  local openlv = petData.OPENLV
  if zs <= 0 and mainHero:getProperty(PROPERTY_ROLELEVEL) < petData.OPENLV then
    ShowNotifyTips(string.format("需要等级%d", petData.OPENLV))
    return
  end
  local subType = 1
  if openlv <= 25 then
    subType = 1
  elseif openlv <= 65 then
    subType = 2
  else
    subType = 3
  end
  print("==================,购买召唤兽")
  enterMarket({
    initViewType = MarketShow_InitShow_CoinView,
    initBaitanType = BaitanShow_InitShow_ShoppingView,
    initBaitanMainType = 1,
    initBaitanSubType = subType,
    closeFunc = function()
      self:SetShow(true)
    end
  })
  self:SetShow(false)
  self:CloseSelf()
end
function CPetListDisplay:addChildObjByControl(obj, ctrObj)
  local parent = ctrObj:getParent()
  local x, y = ctrObj:getPosition()
  local zOrder = ctrObj:getZOrder()
  parent:addChild(obj, zOrder)
  obj:setPosition(ccp(x, y))
end
function CPetListDisplay:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CPetListDisplay:CloseSelf(btnObj, touchType)
  if g_PetListDlg then
    g_PetListDlg:OnBtn_Close()
  end
  CPetListDisplay.super.CloseSelf(self)
end
function CPetListDisplay:SetShow(iShow)
  if self.m_UINode ~= nil then
    self:setEnabled(iShow)
    if self._auto_create_opacity_bg_ins then
      self._auto_create_opacity_bg_ins:setEnabled(iShow)
    end
    if iShow then
      self:OnBtn_Page_TuJian()
    end
  end
end
function CPetListDisplay:Clear()
  print("CPetListDisplay Clear")
  if self.m_ItemDetail ~= nil then
    self.m_ItemDetail:CloseSelf()
    self.m_ItemDetail = nil
  end
  if g_PetListDisplayDlg == self then
    g_PetListDisplayDlg = nil
  end
end
