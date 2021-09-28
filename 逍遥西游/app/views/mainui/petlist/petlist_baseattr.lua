CPetList_BaseAttr = class(".CPetList_BaseAttr", CcsSubView)
function CPetList_BaseAttr:ctor(petId, petlistObj)
  CPetList_BaseAttr.super.ctor(self, "views/pet_list_attr.json")
  local btnBatchListener = {
    btn_point = {
      listener = handler(self, self.OnBtn_Point),
      variName = "btn_point"
    },
    btn_addClose = {
      listener = handler(self, self.OnBtn_AddClose),
      variName = "btn_addClose"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_PetId = nil
  self.m_PetlistObj = petlistObj
  self.txt_value_qx = self:getNode("txt_value_qx")
  self.txt_value_fl = self:getNode("txt_value_fl")
  self.txt_value_gj = self:getNode("txt_value_gj")
  self.txt_value_sd = self:getNode("txt_value_sd")
  self.txt_value_qm = self:getNode("txt_value_qm")
  self.txt_value_gg = self:getNode("txt_value_gg")
  self.txt_value_lx = self:getNode("txt_value_lx")
  self.txt_value_ll = self:getNode("txt_value_ll")
  self.txt_value_mj = self:getNode("txt_value_mj")
  self:LoadPet(petId)
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_WarScene)
  self:ListenMessage(MsgID_Scene)
end
function CPetList_BaseAttr:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("txt_qx"), PROPERTY_HP)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_1"), PROPERTY_HP, self:getNode("txt_qx"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_fl"), PROPERTY_MP)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_2"), PROPERTY_MP, self:getNode("txt_fl"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_gj"), PROPERTY_AP)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_3"), PROPERTY_AP, self:getNode("txt_gj"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_sd"), PROPERTY_SP)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_4"), PROPERTY_SP, self:getNode("txt_sd"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_qm"), PROPERTY_CLOSEVALUE)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_5"), PROPERTY_CLOSEVALUE, self:getNode("txt_qm"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_gg"), PROPERTY_GenGu)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_6"), PROPERTY_GenGu, self:getNode("txt_gg"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lx"), PROPERTY_Lingxing)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_7"), PROPERTY_Lingxing, self:getNode("txt_lx"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_ll"), PROPERTY_LiLiang)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_8"), PROPERTY_LiLiang, self:getNode("txt_ll"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_mj"), PROPERTY_MinJie)
  self:attrclick_check_withWidgetObj(self:getNode("infobg_9"), PROPERTY_MinJie, self:getNode("txt_mj"))
end
function CPetList_BaseAttr:LoadPet(petId)
  if self.m_PetId == petId then
    return
  end
  self.m_PetId = petId
  self.m_PetIns = g_LocalPlayer:getObjById(self.m_PetId)
  self:SetBaseAttr()
  self:_checkFreePoint()
end
function CPetList_BaseAttr:SetBaseAttr()
  local max_hp = self.m_PetIns:getMaxProperty(PROPERTY_HP)
  local cur_hp = self.m_PetIns:getProperty(PROPERTY_HP)
  local max_mp = self.m_PetIns:getMaxProperty(PROPERTY_MP)
  local cur_mp = self.m_PetIns:getProperty(PROPERTY_MP)
  if g_WarScene then
    local tempHp, tempMaxHp, tempMp, tempMaxMp = g_WarScene:getMyRoleHpMpData(self.m_PetIns:getObjId())
    if tempHp ~= nil then
      max_hp = tempMaxHp
      cur_hp = tempHp
      max_mp = tempMaxMp
      cur_mp = tempMp
    end
  end
  self.txt_value_qx:setText(string.format("%d/%d", cur_hp, max_hp))
  AutoLimitObjSize(self.txt_value_qx, 135)
  self.txt_value_fl:setText(string.format("%d/%d", cur_mp, max_mp))
  AutoLimitObjSize(self.txt_value_fl, 135)
  local cur_ap = self.m_PetIns:getProperty(PROPERTY_AP)
  self.txt_value_gj:setText(tostring(cur_ap))
  AutoLimitObjSize(self.txt_value_gj, 135)
  local cur_sp = self.m_PetIns:getProperty(PROPERTY_SP)
  self.txt_value_sd:setText(tostring(cur_sp))
  AutoLimitObjSize(self.txt_value_sd, 135)
  local closeness = self.m_PetIns:getProperty(PROPERTY_CLOSEVALUE)
  self.txt_value_qm:setText(tostring(closeness))
  AutoLimitObjSize(self.txt_value_qm, 105)
  local gg = self.m_PetIns:getProperty(PROPERTY_GenGu)
  self.txt_value_gg:setText(tostring(gg))
  local lx = self.m_PetIns:getProperty(PROPERTY_Lingxing)
  self.txt_value_lx:setText(tostring(lx))
  local ll = self.m_PetIns:getProperty(PROPERTY_LiLiang)
  self.txt_value_ll:setText(tostring(ll))
  local mj = self.m_PetIns:getProperty(PROPERTY_MinJie)
  self.txt_value_mj:setText(tostring(mj))
end
function CPetList_BaseAttr:_checkFreePoint()
  local freeP = self.m_PetIns:getProperty(PROPERTY_FREEPOINT)
  local addFlag = false
  if freeP > 0 then
    local tempHero = g_LocalPlayer:getMainHero()
    if tempHero then
      local tempPet = tempHero:getProperty(PROPERTY_PETID)
      if self.m_PetId == tempPet then
        addFlag = true
      end
    end
  end
  self.btn_point:stopAllActions()
  self.btn_point:setScale(1)
  self.btn_point:setColor(ccc3(255, 255, 255))
  if addFlag then
    local dt = 0.5
    local act1 = CCScaleTo:create(dt, 1.1)
    local act2 = CCScaleTo:create(dt, 0.9)
    self.btn_point:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
  end
end
function CPetList_BaseAttr:OnBtn_Point(obj, t)
  self.m_PetlistObj:ShowAddPoint()
end
function CPetList_BaseAttr:OnBtn_AddClose(obj, t)
  self.m_PetlistObj:ShowAddClose()
end
function CPetList_BaseAttr:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if d.petId == self.m_PetId then
      local proTable = d.pro
      if proTable[PROPERTY_FREEPOINT] ~= nil then
        self:_checkFreePoint()
      end
      self:SetBaseAttr()
    end
  elseif msgSID == MsgID_WarScene_ViewHpMpChanged then
    local curHeroId = self.m_PetIns:getObjId()
    if arg[1] == g_LocalPlayer:getPlayerId() and arg[2] == curHeroId then
      self:SetBaseAttr()
    end
  elseif msgSID == MsgID_Scene_War_Exit then
    self:SetBaseAttr()
  end
end
function CPetList_BaseAttr:Clear()
  self.m_PetlistObj = nil
end
