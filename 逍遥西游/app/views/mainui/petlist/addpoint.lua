CAddPoint = class("CAddPoint", CcsSubView)
function CAddPoint:ctor(closeListener, spId)
  CAddPoint.super.ctor(self, "views/addpoint.json")
  self.m_SetPointId = spId
  self.m_CloseListener = closeListener
  self.m_SetNum_Max = 4
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_auto = {
      listener = handler(self, self.OnBtn_Auto),
      variName = "btn_auto"
    },
    btn_manual = {
      listener = handler(self, self.OnBtn_Manual),
      variName = "btn_manual"
    },
    btn_save = {
      listener = handler(self, self.OnBtn_Save),
      variName = "btn_save"
    },
    btn_tuijian = {
      listener = handler(self, self.OnBtn_Tuijian),
      variName = "btn_tuijian"
    },
    btn_xi = {
      listener = handler(self, self.OnBtn_Xi),
      variName = "btn_xi"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:adjustClickSize(self.btn_xi, 70, 70, true)
  local addpro_bg_1 = self:getNode("addpro_bg_1")
  local x, y = addpro_bg_1:getPosition()
  local p = addpro_bg_1:getParent()
  self.btn_gg_addpoint = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_AddGG))
  p:addChild(self.btn_gg_addpoint)
  self.btn_gg_addpoint:setPosition(ccp(x + 42, y - 26))
  self.btn_gg_subpoint = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_SubGG))
  p:addChild(self.btn_gg_subpoint)
  self.btn_gg_subpoint:setPosition(ccp(x - 88, y - 26))
  self.box_btnaddten_gg = self:getNode("box_btnaddten_gg")
  local x, y = self.box_btnaddten_gg:getPosition()
  self.btn_gg_addten = createClickButton("views/common/btn/btn_10.png", "views/common/btn/btn_10_gary.png", handler(self, self.OnBtn_AddTenGG))
  self:addChild(self.btn_gg_addten)
  self.btn_gg_addten:setPosition(ccp(x, y))
  local addpro_bg_2 = self:getNode("addpro_bg_2")
  local x, y = addpro_bg_2:getPosition()
  local p = addpro_bg_2:getParent()
  self.btn_lx_addpoint = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_AddLX))
  p:addChild(self.btn_lx_addpoint)
  self.btn_lx_addpoint:setPosition(ccp(x + 42, y - 26))
  self.btn_lx_subpoint = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_SubLX))
  p:addChild(self.btn_lx_subpoint)
  self.btn_lx_subpoint:setPosition(ccp(x - 88, y - 26))
  self.box_btnaddten_lx = self:getNode("box_btnaddten_lx")
  local x, y = self.box_btnaddten_lx:getPosition()
  self.btn_lx_addten = createClickButton("views/common/btn/btn_10.png", "views/common/btn/btn_10_gary.png", handler(self, self.OnBtn_AddTenLX))
  self:addChild(self.btn_lx_addten)
  self.btn_lx_addten:setPosition(ccp(x, y))
  local addpro_bg_3 = self:getNode("addpro_bg_3")
  local x, y = addpro_bg_3:getPosition()
  local p = addpro_bg_3:getParent()
  self.btn_ll_addpoint = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_AddLL))
  p:addChild(self.btn_ll_addpoint)
  self.btn_ll_addpoint:setPosition(ccp(x + 42, y - 26))
  self.btn_ll_subpoint = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_SubLL))
  p:addChild(self.btn_ll_subpoint)
  self.btn_ll_subpoint:setPosition(ccp(x - 88, y - 26))
  self.box_btnaddten_ll = self:getNode("box_btnaddten_ll")
  local x, y = self.box_btnaddten_ll:getPosition()
  self.btn_ll_addten = createClickButton("views/common/btn/btn_10.png", "views/common/btn/btn_10_gary.png", handler(self, self.OnBtn_AddTenLL))
  self:addChild(self.btn_ll_addten)
  self.btn_ll_addten:setPosition(ccp(x, y))
  local addpro_bg_4 = self:getNode("addpro_bg_4")
  local x, y = addpro_bg_4:getPosition()
  local p = addpro_bg_4:getParent()
  self.btn_mj_addpoint = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_AddMJ))
  p:addChild(self.btn_mj_addpoint)
  self.btn_mj_addpoint:setPosition(ccp(x + 42, y - 26))
  self.btn_mj_subpoint = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_SubMJ))
  p:addChild(self.btn_mj_subpoint)
  self.btn_mj_subpoint:setPosition(ccp(x - 88, y - 26))
  self.box_btnaddten_mj = self:getNode("box_btnaddten_mj")
  local x, y = self.box_btnaddten_mj:getPosition()
  self.btn_mj_addten = createClickButton("views/common/btn/btn_10.png", "views/common/btn/btn_10_gary.png", handler(self, self.OnBtn_AddTenMJ))
  self:addChild(self.btn_mj_addten)
  self.btn_mj_addten:setPosition(ccp(x, y))
  self.select_auto = self:getNode("select_auto")
  self.select_manual = self:getNode("select_manual")
  self.tip = self:getNode("tip")
  self.txt_value_point = self:getNode("txt_value_point")
  self.txt_gg_point = self:getNode("txt_gg_point")
  self.txt_lx_point = self:getNode("txt_lx_point")
  self.txt_ll_point = self:getNode("txt_ll_point")
  self.txt_mj_point = self:getNode("txt_mj_point")
  self.lable_1 = self:getNode("Label_1")
  self.lable_2 = self:getNode("Label_2")
  self.lable_3 = self:getNode("Label_3")
  self.lable_4 = self:getNode("Label_4")
  self.m_LeftBtnPosX, self.m_LeftBtnPosY = self.btn_tuijian:getPosition()
  self.m_RightBtnPosX, self.m_RightBtnPosY = self.btn_save:getPosition()
  self.m_TxtLabelForPro = {
    [PROPERTY_GenGu] = self.txt_gg_point,
    [PROPERTY_LiLiang] = self.txt_ll_point,
    [PROPERTY_MinJie] = self.txt_mj_point,
    [PROPERTY_Lingxing] = self.txt_lx_point
  }
  self.m_BtnSubPointsForPro = {
    [PROPERTY_GenGu] = self.btn_gg_subpoint,
    [PROPERTY_Lingxing] = self.btn_lx_subpoint,
    [PROPERTY_LiLiang] = self.btn_ll_subpoint,
    [PROPERTY_MinJie] = self.btn_mj_subpoint
  }
  if self.m_SetPointId ~= nil then
    self:setCZBDPeidian(true)
  else
    self:setCZBDPeidian(false)
  end
  self:SetAttrTips()
  self:enableCloseWhenTouchOutside(self:getNode("pic_probg"), true)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CAddPoint:setCZBDPeidian(flag)
  self.lable_1:setVisible(flag)
  self.lable_2:setVisible(flag)
  self.lable_3:setVisible(flag)
  self.lable_4:setVisible(flag)
end
function CAddPoint:setAppointLable(id)
  local mainHero = g_LocalPlayer:getMainHero()
  local typeID = mainHero:getTypeId()
  local race = data_getRoleRace(typeID)
  local gender = data_getRoleGender(typeID)
  if race == RACE_REN and gender == HERO_MALE then
    if id == CZBD_ITEM_1401 then
      self.lable_1:setText("荐\n+1")
      self.lable_2:setText("")
      self.lable_3:setText("")
      self.lable_4:setText("荐\n+3")
    elseif id == CZBD_ITEM_1402 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("荐\n+4")
      self.lable_4:setText("")
    end
  elseif race == RACE_REN and gender == HERO_FEMALE then
    if id == CZBD_ITEM_1403 then
      self.lable_1:setText("荐\n+4")
      self.lable_2:setText("")
      self.lable_3:setText("")
      self.lable_4:setText("")
    elseif id == CZBD_ITEM_1404 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("荐\n+4")
      self.lable_4:setText("")
    end
  elseif race == RACE_MO and gender == HERO_MALE then
    if id == CZBD_ITEM_1409 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("")
      self.lable_4:setText("荐\n+4")
    elseif id == CZBD_ITEM_1410 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("荐\n+4")
      self.lable_4:setText("")
    end
  elseif race == RACE_MO and gender == HERO_FEMALE then
    if id == CZBD_ITEM_1411 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("")
      self.lable_4:setText("荐\n+4")
    elseif id == CZBD_ITEM_1412 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("荐\n+4")
      self.lable_4:setText("")
    end
  elseif race == RACE_XIAN and gender == HERO_MALE then
    if id == CZBD_ITEM_1405 then
      self.lable_1:setText("")
      self.lable_2:setText("荐\n+1")
      self.lable_3:setText("")
      self.lable_4:setText("荐\n+3")
    elseif id == CZBD_ITEM_1406 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("荐\n+4")
      self.lable_4:setText("")
    end
  elseif race == RACE_XIAN and gender == HERO_FEMALE then
    if id == CZBD_ITEM_1407 then
      self.lable_1:setText("")
      self.lable_2:setText("荐\n+1")
      self.lable_3:setText("")
      self.lable_4:setText("荐\n+3")
    elseif id == CZBD_ITEM_1408 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("荐\n+4")
      self.lable_4:setText("")
    end
  elseif race == RACE_GUI and gender == HERO_MALE then
    if id == CZBD_ITEM_1413 then
      self.lable_1:setText("荐\n+2")
      self.lable_2:setText("荐\n+2")
      self.lable_3:setText("")
      self.lable_4:setText("")
    elseif id == CZBD_ITEM_1414 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("荐\n+4")
      self.lable_4:setText("")
    end
  elseif race == RACE_GUI and gender == HERO_FEMALE then
    if id == CZBD_ITEM_1415 then
      self.lable_1:setText("荐\n+2")
      self.lable_2:setText("荐\n+2")
      self.lable_3:setText("")
      self.lable_4:setText("")
    elseif id == CZBD_ITEM_1416 then
      self.lable_1:setText("")
      self.lable_2:setText("")
      self.lable_3:setText("荐\n+4")
      self.lable_4:setText("")
    end
  end
end
function CAddPoint:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("txt_gg_name"), PROPERTY_GenGu)
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_1"), PROPERTY_GenGu, self:getNode("txt_gg_name"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lx_name"), PROPERTY_Lingxing)
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_2"), PROPERTY_Lingxing, self:getNode("txt_lx_name"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_ll_name"), PROPERTY_LiLiang)
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_3"), PROPERTY_LiLiang, self:getNode("txt_ll_name"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_mj_name"), PROPERTY_MinJie)
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_4"), PROPERTY_MinJie, self:getNode("txt_mj_name"))
end
function CAddPoint:SetBtnShow()
  if self.m_CurRoleIns == nil then
    return
  end
  if g_LocalPlayer == nil then
    return
  end
  if self.m_CurRoleIns:getObjId() == g_LocalPlayer:getMainHeroId() then
    self.btn_tuijian:setPosition(ccp(self.m_LeftBtnPosX, self.m_LeftBtnPosY))
    self.btn_save:setPosition(ccp(self.m_RightBtnPosX, self.m_RightBtnPosY))
    self.btn_tuijian:setEnabled(true)
  else
    self.btn_save:setPosition(ccp((self.m_LeftBtnPosX + self.m_RightBtnPosX) / 2, (self.m_LeftBtnPosY + self.m_RightBtnPosY) / 2))
    self.btn_tuijian:setEnabled(false)
  end
end
function CAddPoint:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_RoleAutoAddPointInfo then
    local d = arg[1]
    if self.m_CurRoleIns and self.m_CurRoleIns:getObjId() == d.roleId then
      if self.cur_tag == true then
        self:LoadProperties(self.m_CurRoleIns, true, true)
      else
        self:LoadProperties(self.m_CurRoleIns, true)
      end
    end
  elseif msgSID == MsgID_HeroUpdate then
    local d = arg[1]
    if self.m_CurRoleIns and self.m_CurRoleIns:getObjId() == d.heroId then
      self:LoadProperties(self.m_CurRoleIns, true)
    end
  elseif msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if self.m_CurRoleIns and self.m_CurRoleIns:getObjId() == d.petId then
      self:LoadProperties(self.m_CurRoleIns, true)
    end
  end
end
function CAddPoint:LoadProperties(roleIns, force, localAuto)
  if force == nil then
    force = false
  end
  if not force and self.m_CurRoleIns and self.m_CurRoleIns:getObjId() == roleIns:getObjId() then
    return
  end
  self.m_CurRoleIns = roleIns
  self.m_FreePoints = 0
  self.m_PropertyPoints = {}
  self.m_AddPropertyPoints = {}
  self.m_IsAutoAddPoint = nil
  self.m_FreePoints = self.m_CurRoleIns:getProperty(PROPERTY_FREEPOINT)
  self:FlushFreePointShow()
  self.txt_gg_point:setColor(ccc3(255, 255, 255))
  self.txt_lx_point:setColor(ccc3(255, 255, 255))
  self.txt_ll_point:setColor(ccc3(255, 255, 255))
  self.txt_mj_point:setColor(ccc3(255, 255, 255))
  local info = self.m_CurRoleIns:getProperty(PROPERTY_AUTOADDPOINT)
  if type(info) == "table" or localAuto == true then
    self.m_SetNum_gg = info.gg or 0
    self.m_SetNum_lx = info.lx or 0
    self.m_SetNum_ll = info.ll or 0
    self.m_SetNum_mj = info.mj or 0
    if self.m_SetNum_gg == 0 and self.m_SetNum_lx == 0 and self.m_SetNum_ll == 0 and self.m_SetNum_mj == 0 and localAuto ~= true then
      self.tip:setVisible(false)
      self.select_auto:setVisible(false)
      self.select_manual:setVisible(true)
      self.m_IsAutoAddPoint = false
      local tempOProName = {
        [PROPERTY_GenGu] = PROPERTY_OGenGu,
        [PROPERTY_LiLiang] = PROPERTY_OLiLiang,
        [PROPERTY_MinJie] = PROPERTY_OMinJie,
        [PROPERTY_Lingxing] = PROPERTY_OLingxing
      }
      for k, v in pairs(self.m_TxtLabelForPro) do
        local pts = self.m_CurRoleIns:getProperty(tempOProName[k])
        self:setPropertyPointOfManual(k, pts, ccc3(255, 255, 255))
        self.m_PropertyPoints[k] = pts
        self.m_AddPropertyPoints[k] = 0
      end
      self:FreshManualBtn()
    else
      self.tip:setVisible(true)
      self.select_auto:setVisible(true)
      self.select_manual:setVisible(false)
      self.m_IsAutoAddPoint = true
      self.txt_gg_point:setText(tostring(self.m_SetNum_gg))
      self.txt_lx_point:setText(tostring(self.m_SetNum_lx))
      self.txt_ll_point:setText(tostring(self.m_SetNum_ll))
      self.txt_mj_point:setText(tostring(self.m_SetNum_mj))
      self:FreshAutoBtn()
    end
    self.btn_save:setEnabled(true)
  else
    self.tip:setVisible(false)
    self.select_auto:setVisible(false)
    self.select_manual:setVisible(false)
    self.btn_save:setEnabled(false)
    self.m_SetNum_gg = 0
    self.m_SetNum_lx = 0
    self.m_SetNum_ll = 0
    self.m_SetNum_mj = 0
    self.txt_gg_point:setText("0")
    self.txt_lx_point:setText("0")
    self.txt_ll_point:setText("0")
    self.txt_mj_point:setText("0")
    self.btn_gg_subpoint:setButtonEnabled(false)
    self.btn_lx_subpoint:setButtonEnabled(false)
    self.btn_ll_subpoint:setButtonEnabled(false)
    self.btn_mj_subpoint:setButtonEnabled(false)
    netsend.netbaseptc.requestAutoAddRolePointInfo(self.m_CurRoleIns:getObjId())
  end
  self:SetBtnShow()
end
function CAddPoint:FlushFreePointShow()
  self.txt_value_point:setText(string.format("%d", self.m_FreePoints))
end
function CAddPoint:checkButtonAddPointOfManual()
  local enable = self.m_FreePoints > 0
  self.btn_gg_addpoint:setButtonEnabled(enable)
  self.btn_lx_addpoint:setButtonEnabled(enable)
  self.btn_ll_addpoint:setButtonEnabled(enable)
  self.btn_mj_addpoint:setButtonEnabled(enable)
  local enableten = self.m_FreePoints > 0
  self.btn_gg_addten:setButtonEnabled(enableten)
  self.btn_lx_addten:setButtonEnabled(enableten)
  self.btn_ll_addten:setButtonEnabled(enableten)
  self.btn_mj_addten:setButtonEnabled(enableten)
  self.btn_gg_addten:setVisible(true)
  self.btn_lx_addten:setVisible(true)
  self.btn_ll_addten:setVisible(true)
  self.btn_mj_addten:setVisible(true)
end
function CAddPoint:FreshManualBtn()
  self:checkButtonAddPointOfManual()
  self.btn_gg_subpoint:setButtonEnabled(false)
  self.btn_lx_subpoint:setButtonEnabled(false)
  self.btn_ll_subpoint:setButtonEnabled(false)
  self.btn_mj_subpoint:setButtonEnabled(false)
end
function CAddPoint:CheckShowButtonAddSubPointOfManual(proType)
  self:checkButtonAddPointOfManual()
  local btn = self.m_BtnSubPointsForPro[proType]
  if btn then
    local temp = self.m_AddPropertyPoints[proType]
    if temp == nil or temp <= 0 then
      btn:setButtonEnabled(false)
    else
      btn:setButtonEnabled(true)
    end
  end
end
function CAddPoint:setPropertyPointOfManual(proType, points, changedColor)
  local txtIns = self.m_TxtLabelForPro[proType]
  if txtIns == nil then
    printLog("ERROR", "找不到属性点[%s]", proType)
    return
  end
  if changedColor then
    txtIns:setColor(changedColor)
  end
  txtIns:setText(string.format("%d", points))
end
function CAddPoint:RequestAddPointOfManual(proType, points)
  points = points or 1
  local oldPts = self.m_PropertyPoints[proType]
  if oldPts == nil then
    printLog("[CAddPoint]", "[%s]获取的属性点为空", proType)
    return
  end
  if self.m_FreePoints <= 0 then
    printLog("[CAddPoint]", "==========没有点加毛线==========")
    return
  end
  if points > 1 and points > self.m_FreePoints then
    return
  end
  self.m_FreePoints = self.m_FreePoints - points
  self:FlushFreePointShow()
  oldPts = oldPts + points
  self.m_PropertyPoints[proType] = oldPts
  self.m_AddPropertyPoints[proType] = self.m_AddPropertyPoints[proType] + points
  self:setPropertyPointOfManual(proType, oldPts, VIEW_DEF_PGREEN_COLOR)
  self:CheckShowButtonAddSubPointOfManual(proType)
end
function CAddPoint:RequestSubPointOfManual(proType, points)
  points = points or 1
  local oldPts = self.m_PropertyPoints[proType]
  if oldPts == nil then
    printLog("[CAddPoint]", "[%s]获取的属性点为空", proType)
    return
  end
  local temp = self.m_AddPropertyPoints[proType]
  if points > temp then
    points = temp
  end
  self.m_FreePoints = self.m_FreePoints + points
  self:FlushFreePointShow()
  oldPts = oldPts - points
  self.m_PropertyPoints[proType] = oldPts
  self.m_AddPropertyPoints[proType] = self.m_AddPropertyPoints[proType] - points
  if self.m_AddPropertyPoints[proType] > 0 then
    self:setPropertyPointOfManual(proType, oldPts, VIEW_DEF_PGREEN_COLOR)
  else
    self:setPropertyPointOfManual(proType, oldPts, ccc3(255, 255, 255))
  end
  self:CheckShowButtonAddSubPointOfManual(proType)
end
function CAddPoint:OnManualBtn_AddGG(num)
  if num == nil then
    num = 1
  end
  self:RequestAddPointOfManual(PROPERTY_GenGu, num)
end
function CAddPoint:OnManualBtn_AddLX(num)
  if num == nil then
    num = 1
  end
  self:RequestAddPointOfManual(PROPERTY_Lingxing, num)
end
function CAddPoint:OnManualBtn_AddLL(num)
  if num == nil then
    num = 1
  end
  self:RequestAddPointOfManual(PROPERTY_LiLiang, num)
end
function CAddPoint:OnManualBtn_AddMJ(num)
  if num == nil then
    num = 1
  end
  self:RequestAddPointOfManual(PROPERTY_MinJie, num)
end
function CAddPoint:OnManualBtn_SubGG()
  self:RequestSubPointOfManual(PROPERTY_GenGu, 1)
end
function CAddPoint:OnManualBtn_SubLX()
  self:RequestSubPointOfManual(PROPERTY_Lingxing, 1)
end
function CAddPoint:OnManualBtn_SubLL()
  self:RequestSubPointOfManual(PROPERTY_LiLiang, 1)
end
function CAddPoint:OnManualBtn_SubMJ()
  self:RequestSubPointOfManual(PROPERTY_MinJie, 1)
end
function CAddPoint:FreshAutoBtn()
  local total = self.m_SetNum_gg + self.m_SetNum_lx + self.m_SetNum_ll + self.m_SetNum_mj
  self.btn_gg_subpoint:setButtonEnabled(self.m_SetNum_gg > 0)
  self.btn_lx_subpoint:setButtonEnabled(self.m_SetNum_lx > 0)
  self.btn_ll_subpoint:setButtonEnabled(self.m_SetNum_ll > 0)
  self.btn_mj_subpoint:setButtonEnabled(self.m_SetNum_mj > 0)
  self.btn_gg_addpoint:setButtonEnabled(total < self.m_SetNum_Max)
  self.btn_lx_addpoint:setButtonEnabled(total < self.m_SetNum_Max)
  self.btn_ll_addpoint:setButtonEnabled(total < self.m_SetNum_Max)
  self.btn_mj_addpoint:setButtonEnabled(total < self.m_SetNum_Max)
  self.btn_gg_addten:setButtonEnabled(false)
  self.btn_lx_addten:setButtonEnabled(false)
  self.btn_ll_addten:setButtonEnabled(false)
  self.btn_mj_addten:setButtonEnabled(false)
  self.btn_gg_addten:setVisible(false)
  self.btn_lx_addten:setVisible(false)
  self.btn_ll_addten:setVisible(false)
  self.btn_mj_addten:setVisible(false)
end
function CAddPoint:OnAutoBtn_AddGG()
  if self.m_SetNum_gg + self.m_SetNum_lx + self.m_SetNum_ll + self.m_SetNum_mj >= self.m_SetNum_Max then
    return
  end
  self.m_SetNum_gg = self.m_SetNum_gg + 1
  self.txt_gg_point:setText(tostring(self.m_SetNum_gg))
  self:FreshAutoBtn()
end
function CAddPoint:OnAutoBtn_AddLX()
  if self.m_SetNum_gg + self.m_SetNum_lx + self.m_SetNum_ll + self.m_SetNum_mj >= self.m_SetNum_Max then
    return
  end
  self.m_SetNum_lx = self.m_SetNum_lx + 1
  self.txt_lx_point:setText(tostring(self.m_SetNum_lx))
  self:FreshAutoBtn()
end
function CAddPoint:OnAutoBtn_AddLL()
  if self.m_SetNum_gg + self.m_SetNum_lx + self.m_SetNum_ll + self.m_SetNum_mj >= self.m_SetNum_Max then
    return
  end
  self.m_SetNum_ll = self.m_SetNum_ll + 1
  self.txt_ll_point:setText(tostring(self.m_SetNum_ll))
  self:FreshAutoBtn()
end
function CAddPoint:OnAutoBtn_AddMJ()
  if self.m_SetNum_gg + self.m_SetNum_lx + self.m_SetNum_ll + self.m_SetNum_mj >= self.m_SetNum_Max then
    return
  end
  self.m_SetNum_mj = self.m_SetNum_mj + 1
  self.txt_mj_point:setText(tostring(self.m_SetNum_mj))
  self:FreshAutoBtn()
end
function CAddPoint:OnAutoBtn_SubGG()
  if self.m_SetNum_gg <= 0 then
    return
  end
  self.m_SetNum_gg = self.m_SetNum_gg - 1
  self.txt_gg_point:setText(tostring(self.m_SetNum_gg))
  self:FreshAutoBtn()
end
function CAddPoint:OnAutoBtn_SubLX()
  if self.m_SetNum_lx <= 0 then
    return
  end
  self.m_SetNum_lx = self.m_SetNum_lx - 1
  self.txt_lx_point:setText(tostring(self.m_SetNum_lx))
  self:FreshAutoBtn()
end
function CAddPoint:OnAutoBtn_SubLL()
  if self.m_SetNum_ll <= 0 then
    return
  end
  self.m_SetNum_ll = self.m_SetNum_ll - 1
  self.txt_ll_point:setText(tostring(self.m_SetNum_ll))
  self:FreshAutoBtn()
end
function CAddPoint:OnAutoBtn_SubMJ()
  if self.m_SetNum_mj <= 0 then
    return
  end
  self.m_SetNum_mj = self.m_SetNum_mj - 1
  self.txt_mj_point:setText(tostring(self.m_SetNum_mj))
  self:FreshAutoBtn()
end
function CAddPoint:OnBtn_AddGG(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
    self:OnAutoBtn_AddGG()
  elseif self.m_IsAutoAddPoint == false then
    self:OnManualBtn_AddGG()
  end
end
function CAddPoint:OnBtn_AddTenGG(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
  elseif self.m_IsAutoAddPoint == false then
    if self.m_FreePoints >= 10 then
      self:OnManualBtn_AddGG(10)
    else
      self:OnManualBtn_AddGG(self.m_FreePoints)
    end
  end
end
function CAddPoint:OnBtn_AddLX(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
    self:OnAutoBtn_AddLX()
  elseif self.m_IsAutoAddPoint == false then
    self:OnManualBtn_AddLX()
  end
end
function CAddPoint:OnBtn_AddTenLX(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
  elseif self.m_IsAutoAddPoint == false then
    if self.m_FreePoints >= 10 then
      self:OnManualBtn_AddLX(10)
    else
      self:OnManualBtn_AddLX(self.m_FreePoints)
    end
  end
end
function CAddPoint:OnBtn_AddLL(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
    self:OnAutoBtn_AddLL()
  elseif self.m_IsAutoAddPoint == false then
    self:OnManualBtn_AddLL()
  end
end
function CAddPoint:OnBtn_AddTenLL(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
  elseif self.m_IsAutoAddPoint == false then
    if self.m_FreePoints >= 10 then
      self:OnManualBtn_AddLL(10)
    else
      self:OnManualBtn_AddLL(self.m_FreePoints)
    end
  end
end
function CAddPoint:OnBtn_AddMJ(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
    self:OnAutoBtn_AddMJ()
  elseif self.m_IsAutoAddPoint == false then
    self:OnManualBtn_AddMJ()
  end
end
function CAddPoint:OnBtn_AddTenMJ(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
  elseif self.m_IsAutoAddPoint == false then
    if self.m_FreePoints >= 10 then
      self:OnManualBtn_AddMJ(10)
    else
      self:OnManualBtn_AddMJ(self.m_FreePoints)
    end
  end
end
function CAddPoint:OnBtn_SubGG(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
    self:OnAutoBtn_SubGG()
  elseif self.m_IsAutoAddPoint == false then
    self:OnManualBtn_SubGG()
  end
end
function CAddPoint:OnBtn_SubLX(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
    self:OnAutoBtn_SubLX()
  elseif self.m_IsAutoAddPoint == false then
    self:OnManualBtn_SubLX()
  end
end
function CAddPoint:OnBtn_SubLL(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
    self:OnAutoBtn_SubLL()
  elseif self.m_IsAutoAddPoint == false then
    self:OnManualBtn_SubLL()
  end
end
function CAddPoint:OnBtn_SubMJ(btnObj, touchType)
  if self.m_IsAutoAddPoint == true then
    self:OnAutoBtn_SubMJ()
  elseif self.m_IsAutoAddPoint == false then
    self:OnManualBtn_SubMJ()
  end
end
function CAddPoint:OnBtn_Tuijian(btnObj, touchType)
  local x, y = self:getPosition()
  local isAutoAddPoint = self.m_IsAutoAddPoint
  self:CloseSelf()
  local tjView = CTuijianAddPoint.new(isAutoAddPoint)
  getCurSceneView():addSubView({
    subView = tjView,
    zOrder = MainUISceneZOrder.popView
  })
  tjView:setPosition(ccp(x, y))
end
function CAddPoint:OnBtn_Save(btnObj, touchType)
  print("==>>> OnBtn_SavePoint")
  if self.m_IsAutoAddPoint == true then
    local total = self.m_SetNum_gg + self.m_SetNum_lx + self.m_SetNum_ll + self.m_SetNum_mj
    if total == self.m_SetNum_Max then
      local info = self.m_CurRoleIns:getProperty(PROPERTY_AUTOADDPOINT)
      if type(info) == "table" and info.gg == self.m_SetNum_gg and info.lx == self.m_SetNum_lx and info.ll == self.m_SetNum_ll and info.mj == self.m_SetNum_mj then
        print("-->>自动加点设置没有变化")
        ShowNotifyTips("已保存为自动配点的方案")
        return
      end
      local i_hid = self.m_CurRoleIns:getObjId()
      netsend.netbaseptc.requestAutoAddRolePoint(i_hid, self.m_SetNum_gg, self.m_SetNum_lx, self.m_SetNum_ll, self.m_SetNum_mj)
      ShowWarningInWar()
    else
      ShowNotifyTips("自动加点必须设置和为4点")
    end
  elseif self.m_IsAutoAddPoint == false then
    local i_hid = self.m_CurRoleIns:getObjId()
    local i_gg = self.m_AddPropertyPoints[PROPERTY_GenGu]
    local i_lx = self.m_AddPropertyPoints[PROPERTY_Lingxing]
    local i_ll = self.m_AddPropertyPoints[PROPERTY_LiLiang]
    local i_mj = self.m_AddPropertyPoints[PROPERTY_MinJie]
    if i_gg > 0 or i_lx > 0 or i_ll > 0 or i_mj > 0 then
      netsend.netbaseptc.setheropro(i_hid, i_gg, i_lx, i_ll, i_mj)
      ShowWarningInWar()
    end
  end
end
function CAddPoint:OnBtn_Close()
  self:CloseSelf()
end
function CAddPoint:OnBtn_Auto()
  self.cur_tag = true
  if self.m_IsAutoAddPoint == nil then
    return
  end
  if self.m_SetPointId ~= nil then
    self:setCZBDPeidian(true)
  else
    self:setCZBDPeidian(false)
  end
  self:LoadProperties(self.m_CurRoleIns, true, true)
end
function CAddPoint:OnBtn_Manual()
  self.cur_tag = false
  if self.m_IsAutoAddPoint == nil then
    return
  end
  self:setCZBDPeidian(false)
  local info = self.m_CurRoleIns:getProperty(PROPERTY_AUTOADDPOINT)
  if type(info) == "table" then
    self.m_SetNum_gg = info.gg or 0
    self.m_SetNum_lx = info.lx or 0
    self.m_SetNum_ll = info.ll or 0
    self.m_SetNum_mj = info.mj or 0
    if self.m_SetNum_gg == 0 and self.m_SetNum_lx == 0 and self.m_SetNum_ll == 0 and self.m_SetNum_mj == 0 then
      self:LoadProperties(self.m_CurRoleIns, true)
      return
    end
  end
  local i_hid = self.m_CurRoleIns:getObjId()
  netsend.netbaseptc.cancelAutoAddRolePoint(i_hid)
end
function CAddPoint:OnBtn_Xi()
  if self.m_CurRoleIns == nil then
    return
  end
  local roleId = self.m_CurRoleIns:getObjId()
  local roleType = self.m_CurRoleIns:getType()
  local xiFlag = false
  local lv = self.m_CurRoleIns:getProperty(PROPERTY_ROLELEVEL)
  for _, k in pairs({
    PROPERTY_OGenGu,
    PROPERTY_OLiLiang,
    PROPERTY_OMinJie,
    PROPERTY_OLingxing
  }) do
    local pts = self.m_CurRoleIns:getProperty(k)
    if lv < pts then
      xiFlag = true
      break
    end
  end
  if not xiFlag then
    if roleType == LOGICTYPE_HERO then
      if roleId == g_LocalPlayer:getMainHeroId() then
        ShowNotifyTips("你的主角目前不需要使用该物品")
      else
        ShowNotifyTips("你的伙伴目前不需要使用该物品")
      end
    elseif roleType == LOGICTYPE_PET then
      ShowNotifyTips("你的召唤兽目前不需要使用该物品")
    end
    return
  end
  local itemType, tip
  if roleType == LOGICTYPE_HERO then
    itemType = ITEM_DEF_OTHER_XMS
    tip = string.format("你确定要使用#<G>%s#重置角色的加点吗？", data_getItemName(itemType))
  elseif roleType == LOGICTYPE_PET then
    itemType = ITEM_DEF_OTHER_HYD
    tip = string.format("你确定要使用#<G>%s#重置召唤兽的加点吗？", data_getItemName(itemType))
  end
  if itemType == nil then
    return
  end
  local function func2()
    netsend.netitem.requestBuyAndUseItem(itemType, roleId)
  end
  local tempPop = CPopWarning.new({
    title = nil,
    text = tip,
    confirmFunc = func2,
    align = CRichText_AlignType_Left,
    cancelFunc = nil,
    closeFunc = nil,
    confirmText = "确定",
    cancelText = "取消"
  })
  tempPop:ShowCloseBtn(false)
end
function CAddPoint:Clear()
  if self.m_CloseListener then
    self.m_CloseListener()
    self.m_CloseListener = nil
  end
end
