CChatDetail_Pet = class("CChatDetail_Pet", CcsSubView)
function CChatDetail_Pet:ctor(playerId, petId, data, extrParam)
  CChatDetail_Pet.super.ctor(self, "views/chatdetail_pet.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_petattr = {
      listener = handler(self, self.OnBtn_ShowPetVBaseAttr),
      variName = "btn_petattr"
    },
    btn_petzizhi = {
      listener = handler(self, self.OnBtn_ShowPetZiZhi),
      variName = "btn_petzizhi"
    },
    btn_petkangxing = {
      listener = handler(self, self.OnBtn_ShowPetKangXing),
      variName = "btn_petkangxing"
    },
    btn_petskill = {
      listener = handler(self, self.OnBtn_ShowPetSkill),
      variName = "btn_petskill"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_petattr,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petzizhi,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petkangxing,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petskill,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_petattr:setTitleText("基\n础\n属\n性")
  self.btn_petzizhi:setTitleText("属\n性\n资\n质")
  self.btn_petkangxing:setTitleText("抗\n性")
  self.btn_petskill:setTitleText("技\n能")
  self.m_needLv = self:getNode("need_lv")
  self.m_PlayerId = playerId
  self.m_PetId_JC = petId
  local localPlayerId = g_LocalPlayer:getPlayerId()
  local isLocal = false
  if self.m_PlayerId == localPlayerId then
    isLocal = true
  end
  self.m_Player = g_DataMgr:getPlayer(self.m_PlayerId)
  if self.m_Player == nil then
    self.m_Player = g_DataMgr:CreatePlayer(self.m_PlayerId, isLocal)
  end
  extrParam = extrParam or {}
  print("===========================:基础面板：", tostring(self.m_PetId_JC))
  if extrParam == nil or extrParam.extClose ~= false then
    self:enableCloseWhenTouchOutside(self:getNode("touch_layer"), true)
  end
  self.m_closeListener = extrParam.closeListener
  self.list_detail = self:getNode("list_detail")
  self:ShowPetPanel(nil)
  if g_CheckDetailDlg ~= nil then
    g_CheckDetailDlg:CloseSelf()
    g_CheckDetailDlg = nil
  end
  g_CheckDetailDlg = self
  if data ~= nil then
    self:SetPetDetailData(data)
  else
    self:OnBtn_ShowPetVBaseAttr()
  end
end
function CChatDetail_Pet:getPlayerId()
  return self.m_PlayerId
end
function CChatDetail_Pet:getPetId()
  return self.m_PetId_JC
end
function CChatDetail_Pet:ShowPetPanel(btnObj)
  if btnObj ~= nil then
    if self.petBaseAttrPanel then
      self.petBaseAttrPanel:setEnabled(btnObj == "BaseAttr")
      self.petBaseAttrPanel:setVisible(btnObj == "BaseAttr")
    end
    if self.petZiZhiPanel then
      self.petZiZhiPanel:setEnabled(btnObj == "ZiZhi")
      self.petZiZhiPanel:setVisible(btnObj == "ZiZhi")
    end
    if self.petKangXingPanel then
      self.petKangXingPanel:setEnabled(btnObj == "KangXing")
      self.petKangXingPanel:setVisible(btnObj == "KangXing")
    end
    if self.petSkillPanel then
      self.petSkillPanel:setEnabled(btnObj == "Skill")
      self.petSkillPanel:setVisible(btnObj == "Skill")
    end
  end
end
function CChatDetail_Pet:addChildObjByControl(obj, ctrObj)
  local parent = ctrObj:getParent()
  local x, y = ctrObj:getPosition()
  local zOrder = ctrObj:getZOrder()
  parent:addChild(obj.m_UINode, zOrder)
  obj:setPosition(ccp(x, y))
end
function CChatDetail_Pet:OnBtn_Close(obj, t)
  if self.m_PlayerId ~= g_LocalPlayer:getPlayerId() then
    self.m_Player:DeleteRole(self.m_PetId_JC)
  end
  if self.m_closeListener then
    self.m_closeListener()
  end
  self:CloseSelf()
end
function CChatDetail_Pet:OnBtn_ShowPetVBaseAttr(obj, t)
  if self.petBaseAttrPanel == nil then
    self.petBaseAttrPanel = CChatDetail_BaseAttr.new(self.m_PlayerId, self.m_PetId_JC, self.neidanList)
    self:addChildObjByControl(self.petBaseAttrPanel, self.list_detail)
  end
  self.m_needLv:setVisible(true)
  self:CleanUpPanel("BaseAttr")
  self:ShowPetPanel("BaseAttr")
end
function CChatDetail_Pet:OnBtn_ShowPetZiZhi(obj, t)
  self.m_needLv:setVisible(false)
  if self.petZiZhiPanel == nil then
    self.petZiZhiPanel = CChatDetail_ZiZhiAndAttr.new(self.m_PlayerId, self.m_PetId_JC)
    self:addChildObjByControl(self.petZiZhiPanel, self.list_detail)
  end
  self:CleanUpPanel("ZiZhi")
  self:ShowPetPanel("ZiZhi")
end
function CChatDetail_Pet:OnBtn_ShowPetKangXing(obj, t)
  self.m_needLv:setVisible(false)
  if self.petKangXingPanel == nil then
    self.petKangXingPanel = CChatDetail_KangXing.new(self.m_PlayerId, self.m_PetId_JC)
    self:addChildObjByControl(self.petKangXingPanel, self.list_detail)
  end
  self:CleanUpPanel("KangXing")
  self:ShowPetPanel("KangXing")
end
function CChatDetail_Pet:OnBtn_ShowPetSkill(obj, t)
  self.m_needLv:setVisible(false)
  if self.petSkillPanel == nil then
    self.petSkillPanel = CChatDetail_Skill.new(self.m_PlayerId, self.m_PetId_JC)
    self:addChildObjByControl(self.petSkillPanel, self.list_detail)
  end
  self:CleanUpPanel("Skill")
  self:ShowPetPanel("Skill")
end
function CChatDetail_Pet:Clear()
  if self.m_ScheduleHandle then
    scheduler.unscheduleGlobal(self.m_ScheduleHandle)
    self.m_ScheduleHandle = nil
  end
  if g_CheckDetailDlg == self then
    g_CheckDetailDlg = nil
  end
  self.m_closeListener = nil
end
function CChatDetail_Pet:CleanUpPanel(btnObj)
  if btnObj ~= "BaseAttr" and self.petBaseAttrPanel ~= nil then
    self.petBaseAttrPanel:removeFromParentAndCleanup(true)
    self.petBaseAttrPanel = nil
  end
  if btnObj ~= "ZiZhi" and self.petZiZhiPanel ~= nil then
    self.petZiZhiPanel:removeFromParentAndCleanup(true)
    self.petZiZhiPanel = nil
  end
  if btnObj ~= "KangXing" and self.petKangXingPanel ~= nil then
    self.petKangXingPanel:removeFromParentAndCleanup(true)
    self.petKangXingPanel = nil
  end
  if btnObj ~= "Skill" and self.petSkillPanel ~= nil then
    self.petSkillPanel:removeFromParentAndCleanup(true)
    self.petSkillPanel = nil
  end
end
function CChatDetail_Pet:SetPetDetailData(petInfo)
  local petTypeId = petInfo.i_type
  self.neidanList = petInfo.t_items or {}
  self.m_PetIns = self.m_Player:getObjById(self.m_PetId_JC)
  if self.m_PetIns ~= nil then
    self.m_Player:setSvrproToPet(self.m_PetIns, petInfo)
  else
    self.m_PetIns = self.m_Player:newPetWithServerPro(self.m_PetId_JC, petTypeId, petInfo, false)
  end
  if self.m_Player ~= g_LocalPlayer and self.m_PetId_JC ~= nil then
    self.m_PetIns:setPetNeidanDataForOtherPlayer(self.neidanList)
  end
  local petData = data_Pet[petTypeId]
  local openlv = petData.OPENLV
  self.m_needLv:setText(string.format("等级要求:%d", openlv))
  self.m_PetIns = self.m_Player:getObjById(self.m_PetId_JC)
  self.m_petTypeId = petTypeId
  self.m_petInfo = petInfo
  if self.petBaseAttrPanel ~= nil then
    self.petBaseAttrPanel:removeFromParentAndCleanup(true)
    self.petBaseAttrPanel = nil
  end
  self.petBaseAttrPanel = CChatDetail_BaseAttr.new(self.m_PlayerId, self.m_PetId_JC, self.neidanList)
  self:addChildObjByControl(self.petBaseAttrPanel, self.list_detail)
  self.petBaseAttrPanel:setVisible(true)
end
CChatDetail_BaseAttr = class("CChatDetail_BaseAttr", CcsSubView)
function CChatDetail_BaseAttr:ctor(playerId, petId, neidanlist)
  CChatDetail_BaseAttr.super.ctor(self, "views/chatinsertdetail_pet.csb")
  self.m_PlayerId = playerId
  self.m_Player = g_DataMgr:getPlayer(self.m_PlayerId)
  self.BaseAttrPanel = self:getNode("BaseAttrPanel")
  self.m_petObj = self.m_Player:getObjById(petId)
  local petTypeId = self.m_petObj:getTypeId()
  if self.m_petObj == nil then
    self:CloseSelf()
    return
  end
  self.ndLists_BA = neidanlist
  self:LoadPetIcon(petTypeId)
end
function CChatDetail_BaseAttr:LoadPetIcon(petTypeId)
  if petTypeId == nil then
    return
  end
  clickArea_check.extend(self)
  if self.m_petObj then
    self.imagepos = self:getNode("imagepos")
    self.imagepos:setVisible(false)
    local p = self.imagepos:getParent()
    local x, y = self.imagepos:getPosition()
    local z = self.imagepos:getZOrder()
    local shapeId = self.m_petObj:getProperty(PROPERTY_SHAPE)
    local roleAni, offx, offy = createWarBodyByShape(shapeId)
    roleAni:playAniWithName("guard_4", -1)
    p:addNode(roleAni, z + 2)
    roleAni:setPosition(ccp(x + offx, y + offy))
    self:addclickAniForPetAni(roleAni, self.imagepos)
    if self.m_RoleAureole == nil then
      self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
      p:addNode(self.m_RoleAureole, z + 1)
      self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
    end
    if self.m_RoleShadow == nil then
      local roleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
      p:addNode(roleShadow, z + 1)
      roleShadow:setPosition(x, y)
      self.m_RoleShadow = roleShadow
    end
    local iconPath = data_getPetIconPath(self.m_petObj:getTypeId())
    local iconImg = display.newSprite(iconPath)
    local pet_quality = self:getNode("pet_quality")
    pet_quality:setVisible(false)
    local p = pet_quality:getParent()
    local x, y = pet_quality:getPosition()
    local z = pet_quality:getZOrder()
    local size = pet_quality:getContentSize()
    p:addNode(iconImg, z + 10)
    iconImg:setAnchorPoint(ccp(0, 1))
    iconImg:setPosition(ccp(x, y + size.height))
    self:LoadPetAttr(petTypeId)
  end
end
function CChatDetail_BaseAttr:LoadPetAttr(petTypeId)
  local petname = self.m_petObj:getProperty(PROPERTY_NAME)
  local zs = self.m_petObj:getProperty(PROPERTY_ZHUANSHENG)
  local lv = self.m_petObj:getProperty(PROPERTY_ROLELEVEL)
  local color = ccc3(248, 193, 100)
  local cur_level = string.format("%d转%d级", zs, lv)
  self.pet_name = self:getNode("txt_name")
  self.pet_level = self:getNode("txt_level")
  if self.m_petObj then
    self.pet_name:setText(petname)
    self.pet_level:setText(cur_level)
  else
    self.pet_name:setText(" ")
    self.pet_level:setText(" ")
  end
  self.pet_name:setColor(color)
  self.neidan_1 = self:getNode("neidan_1")
  self.neidan_1_level = self:getNode("neidan_1_level")
  self.neidan_2 = self:getNode("neidan_2")
  self.neidan_2_level = self:getNode("neidan_2_level")
  self.neidan_3 = self:getNode("neidan_3")
  self.neidan_3_level = self:getNode("neidan_3_level")
  local count_ND = 1
  local itemName, neidan_LV
  local lv = 0
  local zs = 0
  local zbList = self.m_petObj:getZhuangBei()
  if self.m_PlayerId == g_LocalPlayer:getPlayerId() then
    for itemId, _ in pairs(zbList) do
      local itemIns = self.m_Player:GetOneItem(itemId)
      if itemIns and itemIns:getType() == ITEM_LARGE_TYPE_NEIDAN then
        itemName = itemIns:getProperty(ITEM_PRO_NAME)
        lv = itemIns:getProperty(ITEM_PRO_LV)
        zs = itemIns:getProperty(ITEM_PRO_NEIDAN_ZS)
        neidan_LV = string.format("%d转%d级", zs, lv)
        if count_ND == 1 then
          self.neidan_1:setText(itemName)
          self.neidan_1_level:setText(neidan_LV)
        end
        if count_ND == 2 then
          self.neidan_2:setText(itemName)
          self.neidan_2_level:setText(neidan_LV)
        end
        if count_ND == 3 then
          self.neidan_3:setText(itemName)
          self.neidan_3_level:setText(neidan_LV)
        end
        count_ND = count_ND + 1
      end
    end
  else
    for k, nditem in pairs(self.ndLists_BA) do
      for key, v in pairs(nditem) do
        if key == "i_sid" then
          itemName = data_Neidan[v].name
        end
        if key == "i_nlv" then
          lv = v
        end
        if key == "i_nzs" then
          zs = v
        end
        neidan_LV = string.format("%d转%d级", zs, lv)
      end
      if k == 1 then
        self.neidan_1:setText(itemName)
        self.neidan_1_level:setText(neidan_LV)
      end
      if k == 2 then
        self.neidan_2:setText(itemName)
        self.neidan_2_level:setText(neidan_LV)
      end
      if k == 3 then
        self.neidan_3:setText(itemName)
        self.neidan_3_level:setText(neidan_LV)
      end
    end
  end
end
CChatDetail_ZiZhiAndAttr = class("CChatDetail_ZiZhiAndAttr", CcsSubView)
function CChatDetail_ZiZhiAndAttr:ctor(playerId, petId)
  CChatDetail_ZiZhiAndAttr.super.ctor(self, "views/chatdetail_shuxinzizhi_pet.csb")
  self.m_PlayerId = playerId
  self.m_Player = g_DataMgr:getPlayer(self.m_PlayerId)
  self.m_PetObj = self.m_Player:getObjById(petId)
  if self.m_PetObj == nil then
    self:CloseSelf()
    return
  end
  print("===========================:资质和属性界面", tostring(self.m_Player:getPlayerId()), tostring(petId))
  self.txt_grow_speed = self:getNode("txt_grow_speed")
  self.txt_longgu_num = self:getNode("txt_longgu_num")
  self.txt_qixue = self:getNode("txt_qixue")
  self.txt_fali = self:getNode("txt_fali")
  self.txt_gongji = self:getNode("txt_gongji")
  self.txt_sudu = self:getNode("txt_sudu")
  self.txt_qinmi = self:getNode("txt_qinmi")
  self.txt_gengu = self:getNode("txt_gengu")
  self.txt_lingxing = self:getNode("txt_lingxing")
  self.txt_liliang = self:getNode("txt_liliang")
  self.txt_minjie = self:getNode("txt_minjie")
  self.txt_huajing_num = self:getNode("txt_huajing_num")
  self.txt_qx_chuzhi = self:getNode("txt_qx_chuzhi")
  self.txt_fali_chuzhi = self:getNode("txt_fali_chuzhi")
  self.txt_gongji_chuzhi = self:getNode("txt_gongji_chuzhi")
  self.txt_sudu_chuzhi = self:getNode("txt_sudu_chuzhi")
  self.txt_qinmi_chuzhi = self:getNode("txt_qinmi_chuzhi")
  if data_getPetTypeIsCanHuaLing(self.m_PetObj:getTypeId()) then
    self:getNode("huajing"):setText("化灵:")
    self:getNode("huajing"):setVisible(true)
    self:getNode("txt_huajing_num"):setVisible(true)
  elseif data_getPetTypeIsCanHuaJing(self.m_PetObj:getTypeId()) then
    self:getNode("huajing"):setText("化境:")
    self:getNode("huajing"):setVisible(true)
    self:getNode("txt_huajing_num"):setVisible(true)
  else
    self:getNode("huajing"):setVisible(false)
    self:getNode("txt_huajing_num"):setVisible(false)
  end
  self:SetBaseAttr()
  self:SetAttrTips_ZiZhi()
end
function CChatDetail_ZiZhiAndAttr:SetAttrTips_ZiZhi()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("growspeed"), PROPERTY_GROWUP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_grow_speed"), PROPERTY_GROWUP, self:getNode("growspeed"))
  self:attrclick_check_withWidgetObj(self:getNode("qixue_lable_1"), PROPERTY_HP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_qixue"), PROPERTY_HP, self:getNode("qixue_lable_1"))
  self:attrclick_check_withWidgetObj(self:getNode("fali_lable_2"), PROPERTY_MP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_fali"), PROPERTY_MP, self:getNode("fali_lable_2"))
  self:attrclick_check_withWidgetObj(self:getNode("gongji_lable_3"), PROPERTY_AP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_gongji"), PROPERTY_AP, self:getNode("gongji_lable_3"))
  self:attrclick_check_withWidgetObj(self:getNode("sudu_lable_4"), PROPERTY_SP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_sudu"), PROPERTY_SP, self:getNode("sudu_lable_4"))
  self:attrclick_check_withWidgetObj(self:getNode("qinmi_lable_5"), PROPERTY_CLOSEVALUE)
  self:attrclick_check_withWidgetObj(self:getNode("txt_qinmi"), PROPERTY_CLOSEVALUE, self:getNode("qinmi_lable_5"))
  self:attrclick_check_withWidgetObj(self:getNode("gengu_lable_6"), PROPERTY_GenGu)
  self:attrclick_check_withWidgetObj(self:getNode("gengu_lable_6"), PROPERTY_GenGu, self:getNode("gengu_lable_6"))
  self:attrclick_check_withWidgetObj(self:getNode("lingxing_lable_7"), PROPERTY_Lingxing)
  self:attrclick_check_withWidgetObj(self:getNode("lingxing_lable_7"), PROPERTY_Lingxing, self:getNode("lingxing_lable_7"))
  self:attrclick_check_withWidgetObj(self:getNode("liliang_lable_8"), PROPERTY_LiLiang)
  self:attrclick_check_withWidgetObj(self:getNode("liliang_lable_8"), PROPERTY_LiLiang, self:getNode("liliang_lable_8"))
  self:attrclick_check_withWidgetObj(self:getNode("minjie_lable_9"), PROPERTY_MinJie)
  self:attrclick_check_withWidgetObj(self:getNode("minjie_lable_9"), PROPERTY_MinJie, self:getNode("minjie_lable_9"))
end
function CChatDetail_ZiZhiAndAttr:SetBaseAttr()
  local petTypeId = self.m_PetObj:getTypeId()
  local petData = data_Pet[petTypeId] or {}
  if petData == nil then
    return
  end
  local czl = self.m_PetObj:getProperty(PROPERTY_GROWUP)
  local addCzl = self.m_PetObj:getProperty(PROPERTY_ZHUANSHENG) * 0.1 + self.m_PetObj:getProperty(PROPERTY_LONGGU_NUM) * 0.01
  local hjNum = self.m_PetObj:getProperty(PROPERTY_HUAJING_NUM)
  if hjNum == 1 then
    addCzl = addCzl + data_Variables.SS_HuaJing1_AddCZL or 0.05
  elseif hjNum == 2 then
    addCzl = addCzl + (data_Variables.SS_HuaJing1_AddCZL or 0.05) + (data_Variables.SS_HuaJing2_AddCZL or 0.1)
  elseif hjNum == 3 then
    addCzl = addCzl + (data_Variables.SS_HuaJing1_AddCZL or 0.05) + (data_Variables.SS_HuaJing2_AddCZL or 0.1)
  end
  local hlNum = self.m_PetObj:getProperty(PROPERTY_HUALING_NUM)
  for huaLingIndex = 1, LINGSHOU_HUALING_MAX_NUM do
    if huaLingIndex <= hlNum then
      addCzl = addCzl + data_LingShouHuaLing[huaLingIndex].addCZL
    end
  end
  local czl_max = petData.GROWUP * 1.02 + addCzl
  self.txt_grow_speed:setText(string.format("%s/%s", Value2Str(czl, 3), Value2Str(czl_max, 3)))
  local longgu_num = self.m_PetObj:getProperty(PROPERTY_LONGGU_NUM)
  self.txt_longgu_num:setText(string.format("x%d", longgu_num))
  if data_getPetTypeIsCanHuaLing(self.m_PetObj:getTypeId()) then
    local hualing_num = self.m_PetObj:getProperty(PROPERTY_HUALING_NUM)
    self.txt_huajing_num:setText(string.format("x%d", hualing_num))
  elseif data_getPetTypeIsCanHuaJing(self.m_PetObj:getTypeId()) then
    local huajing_num = self.m_PetObj:getProperty(PROPERTY_HUAJING_NUM)
    self.txt_huajing_num:setText(string.format("x%d", huajing_num))
  end
  local max_hp = self.m_PetObj:getMaxProperty(PROPERTY_HP)
  local cur_hp = self.m_PetObj:getProperty(PROPERTY_HP)
  self.txt_qixue:setText(max_hp)
  self.txt_qx_chuzhi:setText(tostring(cur_hp))
  local max_mp = self.m_PetObj:getMaxProperty(PROPERTY_MP)
  local cur_mp = self.m_PetObj:getProperty(PROPERTY_MP)
  self.txt_fali:setText(cur_mp)
  self.txt_fali_chuzhi:setText(tostring(cur_mp))
  local cur_ap = self.m_PetObj:getProperty(PROPERTY_AP)
  self.txt_gongji:setText(tostring(cur_ap))
  self.txt_gongji_chuzhi:setText(tostring(cur_ap))
  local cur_sp = self.m_PetObj:getProperty(PROPERTY_SP)
  self.txt_sudu:setText(tostring(cur_sp))
  local closeness = self.m_PetObj:getProperty(PROPERTY_CLOSEVALUE)
  local maxclosess = self.m_PetObj:getMaxProperty(PROPERTY_CLOSEVALUE)
  self.txt_qinmi:setText(tostring(closeness))
  local gg = self.m_PetObj:getProperty(PROPERTY_GenGu)
  self.txt_gengu:setText(tostring(gg))
  local lx = self.m_PetObj:getProperty(PROPERTY_Lingxing)
  self.txt_lingxing:setText(tostring(lx))
  local ll = self.m_PetObj:getProperty(PROPERTY_LiLiang)
  self.txt_liliang:setText(tostring(ll))
  local mj = self.m_PetObj:getProperty(PROPERTY_MinJie)
  self.txt_minjie:setText(tostring(mj))
  local addqx = self.m_PetObj:getProperty(PROPERTY_LONGGU_ADDHP) + self.m_PetObj:getProperty(PROPERTY_HUAJING_ADDHP)
  local qx_max = math.floor(petData.HP * 1.2 + 1.0E-8 + addqx)
  local qx = self.m_PetObj:getProperty(PROPERTY_RANDOM_HPBASE) + addqx
  local m_qx = string.format("(初值%d/%d)", qx, qx_max)
  self.txt_qx_chuzhi:setText(tostring(m_qx))
  local addfl = self.m_PetObj:getProperty(PROPERTY_LONGGU_ADDMP) + self.m_PetObj:getProperty(PROPERTY_HUAJING_ADDMP)
  local fl_max = math.floor(petData.MP * 1.2 + 1.0E-8 + addfl)
  local fl = self.m_PetObj:getProperty(PROPERTY_RANDOM_MPBASE) + addfl
  local m_fl = string.format("(初值%d/%d)", fl, fl_max)
  self.txt_fali_chuzhi:setText(tostring(m_fl))
  local addgj = self.m_PetObj:getProperty(PROPERTY_LONGGU_ADDAP) + self.m_PetObj:getProperty(PROPERTY_HUAJING_ADDAP)
  local gj_max = math.floor(petData.AP * 1.2 + 1.0E-8 + addgj)
  local gj = self.m_PetObj:getProperty(PROPERTY_RANDOM_APBASE) + addgj
  local m_gj = string.format("(初值%d/%d)", gj, gj_max)
  self.txt_gongji_chuzhi:setText(tostring(m_gj))
  local addsd = self.m_PetObj:getProperty(PROPERTY_LONGGU_ADDSP) + self.m_PetObj:getProperty(PROPERTY_HUAJING_ADDSP)
  local sd_max = math.floor(petData.SP * 1.2 + 1.0E-8 + addsd)
  local sd = self.m_PetObj:getProperty(PROPERTY_RANDOM_SPBASE) + addsd
  local m_sd = string.format("(初值%d/%d)", sd, sd_max)
  self.txt_sudu_chuzhi:setText(tostring(m_sd))
  self.txt_qinmi_chuzhi:setText(nil)
end
local CChatKangXing_item = class("CChatKangXing_item", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CChatKangXing_item:ctor(params)
  local w = params.w
  local h = params.h
  local kx_name = params.name
  local kx_value = params.value
  kx_value = Value2Str(kx_value)
  self:setSize(CCSize(w, h))
  local lable_name = CCLabelTTF:create(kx_name, ITEM_NUM_FONT, 22)
  local lable_value = CCLabelTTF:create(kx_value, ITEM_NUM_FONT, 22)
  lable_name:setAnchorPoint(ccp(0, 0))
  lable_value:setAnchorPoint(ccp(0, 0))
  lable_name:setColor(ccc3(211, 139, 29))
  self:addNode(lable_name)
  self:addNode(lable_value)
  local size = lable_name:getContentSize()
  lable_name:setPosition(ccp(25, 0))
  lable_value:setPosition(ccp(w - 35, 0))
end
CChatDetail_KangXing = class("CChatDetail_KangXing", CcsSubView)
function CChatDetail_KangXing:ctor(playerId, petId)
  CChatDetail_KangXing.super.ctor(self, "views/chatdetail_kangxing_pet.csb")
  if playerId == nil then
    self.m_Player = g_LocalPlayer
  else
    self.m_Player = g_DataMgr:getPlayer(playerId)
  end
  self.m_petObj = self.m_Player:getObjById(petId)
  if self.m_petObj == nil then
    self:CloseSelf()
    return
  end
  self.m_listView = self:getNode("ListView")
  print("===========================:抗性界面", tostring(self.m_Player:getPlayerId()), tostring(petId))
  self:setKXAttr()
  self:SetWuxing()
end
function CChatDetail_KangXing:setKXAttr()
  local size = self:getContentSize()
  local size_list = self.m_listView:getContentSize()
  if self.m_petObj == nil then
    return
  end
  local count = 1
  for key, proName in pairs({
    [PROPERTY_LIANYAO_NUM] = "炼妖次数：",
    [PROPERTY_PDEFEND] = "物理吸收：",
    [PROPERTY_KHUO] = "抗火：",
    [PROPERTY_KSHUI] = "抗水：",
    [PROPERTY_KLEI] = "抗雷：",
    [PROPERTY_KFENG] = "抗风：",
    [PROPERTY_KHUNLUAN] = "抗混乱：",
    [PROPERTY_KHUNSHUI] = "抗昏睡：",
    [PROPERTY_KZHONGDU] = "抗中毒：",
    [PROPERTY_KFENGYIN] = "抗封印：",
    [PROPERTY_KZHENSHE] = "抗虹吸：",
    [PROPERTY_KAIHAO] = "抗哀嚎：",
    [PROPERTY_KYIWANG] = "抗遗忘：",
    [PROPERTY_KXIXUE] = "抗吸血："
  }) do
    local value = self.m_petObj:getProperty(key)
    if key == PROPERTY_LIANYAO_NUM then
      local params = {
        name = proName,
        value = value,
        w = size.width - 50,
        h = 30,
        prokey = key
      }
      local item = CChatKangXing_item.new(params)
      self.m_listView:insertCustomItem(item, 0)
      count = count + 1
    elseif value ~= 0 then
      local params = {
        name = proName,
        value = value * 100,
        w = size.width - 50,
        h = 30
      }
      local item = CChatKangXing_item.new(params)
      self.m_listView:pushBackCustomItem(item)
      count = count + 1
    end
  end
  self.m_KXShowCount = count
end
function CChatDetail_KangXing:SetWuxing()
  if self.m_petObj == nil then
    return
  end
  local delY = 310 - 30 * self.m_KXShowCount
  local list_x, list_y = self.m_listView:getPosition()
  local txt_x, txt_y = self:getNode("pet_attr_1_3"):getPosition()
  local size = self:getNode("pet_attr_1_3"):getContentSize()
  for _, name in pairs({
    "bg2",
    "pet_attr_1_3",
    "txt_jin",
    "txt_mu",
    "txt_shui",
    "txt_huo",
    "txt_tu",
    "v_jin",
    "v_mu",
    "v_shui",
    "v_huo",
    "v_tu"
  }) do
    local x, y = self:getNode(name):getPosition()
    if y < y + delY then
      self:getNode(name):setPosition(ccp(x, y + delY))
    end
  end
  local petTypeId = self.m_petObj:getTypeId()
  local petData = data_Pet[petTypeId] or {}
  self:getNode("v_jin"):setText(string.format("%d%%", petData.WXJIN * 100))
  self:getNode("v_mu"):setText(string.format("%d%%", petData.WXMU * 100))
  self:getNode("v_shui"):setText(string.format("%d%%", petData.WXSHUI * 100))
  self:getNode("v_huo"):setText(string.format("%d%%", petData.WXHUO * 100))
  self:getNode("v_tu"):setText(string.format("%d%%", petData.WXTU * 100))
end
CChatDetail_Skill = class("CChatDetail_Skill", CcsSubView)
function CChatDetail_Skill:ctor(playerId, petId, isBaitanPlayer)
  CChatDetail_Skill.super.ctor(self, "views/chatdetail_skill_pet.csb")
  self.m_PetId = petId
  self.m_SkillIcon = {}
  self.m_PlayerId = playerId
  self.isBaitanPlayer = isBaitanPlayer
  if self.isBaitanPlayer then
    self.m_Player = g_BaitanDataMgr:getPlayer(self.m_PlayerId)
    self.m_PetObj = self.m_Player:getObjById(self.m_PetId)
  else
    self.m_Player = g_DataMgr:getPlayer(self.m_PlayerId)
    self.m_PetObj = self.m_Player:getObjById(self.m_PetId)
  end
  if self.m_PetObj == nil then
    self:CloseSelf()
    return
  end
  print("===========================:法术技能界面", tostring(self.m_Player:getPlayerId()), tostring(self.m_PetId))
  self:LoadPet(self.m_PetId)
  self:ListenMessage(MsgID_ItemInfo)
end
function CChatDetail_Skill:LoadPet(petId)
  if self.m_PetObj == nil then
    return
  end
  self:SetBaseSkill()
end
function CChatDetail_Skill:SetBaseSkill()
  if self.m_PetObj == nil then
    return
  end
  local skillTypeList = self.m_PetObj:getSkillTypeList()
  local skillList = {}
  local ndSkillList = {}
  for _, skillAttr in pairs(skillTypeList) do
    if skillAttr == NDATTR_MOJIE then
    else
      local data_table = data_Pet[self.m_PetObj:getTypeId()]
      if data_table ~= nil and data_table.skills ~= nil then
        skills = data_table.skills
        for i = #skills, 1, -1 do
          local skillId = skills[i]
          if skillId ~= 0 then
            table.insert(skillList, 1, skillId)
          end
        end
      end
    end
  end
  for _, skillIcon in pairs(self.m_SkillIcon) do
    skillIcon:removeFromParentAndCleanup(true)
  end
  self.m_SkillIcon = {}
  local lwSkillList = {}
  local normalPetSkills = self.m_PetObj:getProperty(PROPERTY_PETSKILLS)
  for i, skillId in ipairs(normalPetSkills) do
    lwSkillList[#lwSkillList + 1] = {skillId, false}
  end
  local ssPetSkills = self.m_PetObj:getProperty(PROPERTY_SSSKILLS)
  if type(ssPetSkills) ~= "table" then
    ssPetSkills = {}
  end
  for i, skillId in ipairs(ssPetSkills) do
    lwSkillList[#lwSkillList + 1] = {skillId, true}
  end
  self:SetSkillAtRow(skillList, 1)
  self:SetSkillAtRow(lwSkillList, 2)
end
function CChatDetail_Skill:SetSkillAtRow(skillList, row)
  if self.m_PetObj == nil then
    return
  end
  local xlSkills = self.m_PetObj:getProperty(PROPERTY_ZJSKILLSEXP)
  if type(xlSkills) ~= "table" then
    xlSkills = {}
  end
  for i, d in ipairs(skillList) do
    local posObj = self:getNode(string.format("box_%d%d", row, i))
    if posObj == nil then
      return
    end
    local px, py = posObj:getPosition()
    local parent = posObj:getParent()
    local zOrder = posObj:getZOrder()
    skillIcon = nil
    if row == 1 then
      local skillId = d
      local openFlag = self.m_PetObj:getSkillIsOpen(skillId) or self.m_PetObj:getBDSkillIsOpen(skillId)
      skillIcon = createClickSkill({
        roleID = self.m_PetId,
        skillID = skillId,
        LongPressTime = 0.2,
        imgFlag = true,
        grayFlag = not openFlag,
        playerId = self.m_PlayerId,
        isBaitanPlayer = self.isBaitanPlayer
      })
    else
      local skillId = d[1]
      local ssFlag = d[2]
      if skillId > 0 then
        local coverSkill = self.m_PetObj:skillIsCoverByOtherSkill(skillId)
        skillIcon = createClickSkill({
          roleID = self.m_PetId,
          skillID = skillId,
          LongPressTime = 0.2,
          imgFlag = true,
          grayFlag = coverSkill ~= nil,
          playerId = self.m_PlayerId,
          delBtnFlag = false,
          isBaitanPlayer = self.isBaitanPlayer,
          xlFlag = xlSkills[skillId] ~= nil
        })
      elseif skillId == PETSKILL_NONESKILL then
        skillIcon = createClickButton("views/rolelist/pic_skill_open.png", nil, nil, nil, nil, true)
      elseif skillId == PETSKILL_CLOSED then
        skillIcon = createClickButton("views/rolelist/pic_skill_closed.png", nil, nil, nil, nil, true)
      elseif skillId == PETSKILL_LOCKED then
        skillIcon = createClickButton("views/rolelist/pic_skill_locked.png", nil, nil, nil, nil, true)
      end
      if ssFlag then
        local size = skillIcon:getSize()
        local leftPart = display.newSprite("views/rolelist/pic_ssicon.png")
        leftPart:setAnchorPoint(ccp(1, 0))
        skillIcon:addNode(leftPart, 99)
        leftPart:setPosition(ccp(size.width / 2 - 1, 0))
        local size = skillIcon:getSize()
        local rightPart = display.newSprite("views/rolelist/pic_ssicon.png")
        rightPart:setAnchorPoint(ccp(1, 0))
        rightPart:setScaleX(-1)
        skillIcon:addNode(rightPart, 99)
        rightPart:setPosition(ccp(size.width / 2 + 1, 0))
      end
    end
    parent:addChild(skillIcon, zOrder)
    skillIcon:setPosition(ccp(px, py))
    self.m_SkillIcon[#self.m_SkillIcon + 1] = skillIcon
  end
end
function CChatDetail_Skill:OnNeiDanChanged(ndItemId)
  local ndItemIns = self.m_Player:GetOneItem(ndItemId)
  if ndItemIns then
    local ndTypeId = ndItemIns:getTypeId()
    local ndSkillId = NEIDAN_ITEM_TO_SKILL_TABLE[ndTypeId]
    if ndSkillId ~= nil then
      local skillAttr = data_getSkillAttrStyle(ndSkillId)
      if skillAttr == NDATTR_MOJIE then
        self:SetBaseSkill()
      end
    end
  end
end
function CChatDetail_Skill:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if d.petId == self.m_PetId then
      local proTable = d.pro
      if proTable[PROPERTY_ROLELEVEL] ~= nil then
        self:SetBaseSkill()
      end
    end
  elseif msgSID == MsgID_ItemInfo_TakeEquip then
    local roleId, ndItemId = arg[1], arg[2]
    if roleId == self.m_PetId then
      self:OnNeiDanChanged(ndItemId)
    end
  elseif msgSID == MsgID_ItemInfo_TakeDownEquip then
    local roleId, ndItemId = arg[1], arg[2]
    if roleId == self.m_PetId then
      self:OnNeiDanChanged(ndItemId)
    end
  end
end
