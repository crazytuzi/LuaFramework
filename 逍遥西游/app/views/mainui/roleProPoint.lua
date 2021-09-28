autoaddpoint = class("autoaddpoint", CcsSubView)
function autoaddpoint:ctor(roleId)
  autoaddpoint.super.ctor(self, "views/autoaddpoint.json", {isAutoCenter = true, opacityBg = 100})
  self.m_RoleId = roleId
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_ok = {
      listener = handler(self, self.OnBtn_Ok),
      variName = "btn_ok"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    },
    btn_subpro = {
      listener = handler(self, self.OnBtn_SubPro_GG),
      variName = "btn_subpro"
    },
    btn_subpro2 = {
      listener = handler(self, self.OnBtn_SubPro_LX),
      variName = "btn_subpro2"
    },
    btn_subpro3 = {
      listener = handler(self, self.OnBtn_SubPro_LL),
      variName = "btn_subpro3"
    },
    btn_subpro4 = {
      listener = handler(self, self.OnBtn_SubPro_MJ),
      variName = "btn_subpro4"
    },
    btn_addpro = {
      listener = handler(self, self.OnBtn_AddPro_GG),
      variName = "btn_addpro"
    },
    btn_addpro2 = {
      listener = handler(self, self.OnBtn_AddPro_LX),
      variName = "btn_addpro2"
    },
    btn_addpro3 = {
      listener = handler(self, self.OnBtn_AddPro_LL),
      variName = "btn_addpro3"
    },
    btn_addpro4 = {
      listener = handler(self, self.OnBtn_AddPro_MJ),
      variName = "btn_addpro4"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.num1 = self:getNode("num1")
  self.num2 = self:getNode("num2")
  self.num3 = self:getNode("num3")
  self.num4 = self:getNode("num4")
  self.title_state = self:getNode("title_state")
  self.m_SetNum_Max = 4
  self:InitButton()
  self:ListenMessage(MsgID_PlayerInfo)
end
function autoaddpoint:InitButton()
  local role = g_LocalPlayer:getObjById(self.m_RoleId)
  if role == nil then
    self.m_SetNum1 = 0
    self.m_SetNum2 = 0
    self.m_SetNum3 = 0
    self.m_SetNum4 = 0
    self.num1:setText(tostring(self.m_SetNum1))
    self.num2:setText(tostring(self.m_SetNum2))
    self.num3:setText(tostring(self.m_SetNum3))
    self.num4:setText(tostring(self.m_SetNum4))
    return
  end
  local info = role:getProperty(PROPERTY_AUTOADDPOINT)
  if type(info) == "table" then
    self.m_SetNum1 = info.gg or 0
    self.m_SetNum2 = info.lx or 0
    self.m_SetNum3 = info.ll or 0
    self.m_SetNum4 = info.mj or 0
    if self.m_SetNum1 == 0 and self.m_SetNum2 == 0 and self.m_SetNum3 == 0 and self.m_SetNum4 == 0 then
      self.title_state:setText("(未设置)")
    else
      self.title_state:setText("(已设置)")
    end
    self.num1:setText(tostring(self.m_SetNum1))
    self.num2:setText(tostring(self.m_SetNum2))
    self.num3:setText(tostring(self.m_SetNum3))
    self.num4:setText(tostring(self.m_SetNum4))
  else
    self.m_SetNum1 = 0
    self.m_SetNum2 = 0
    self.m_SetNum3 = 0
    self.m_SetNum4 = 0
    self.num1:setText(tostring(self.m_SetNum1))
    self.num2:setText(tostring(self.m_SetNum2))
    self.num3:setText(tostring(self.m_SetNum3))
    self.num4:setText(tostring(self.m_SetNum4))
    netsend.netbaseptc.requestAutoAddRolePointInfo(self.m_RoleId)
  end
  self:FreshBtn()
end
function autoaddpoint:FreshBtn()
  local total = self.m_SetNum1 + self.m_SetNum2 + self.m_SetNum3 + self.m_SetNum4
  self.btn_subpro:setBright(self.m_SetNum1 > 0)
  self.btn_subpro2:setBright(self.m_SetNum2 > 0)
  self.btn_subpro3:setBright(self.m_SetNum3 > 0)
  self.btn_subpro4:setBright(self.m_SetNum4 > 0)
  self.btn_subpro:setTouchEnabled(self.m_SetNum1 > 0)
  self.btn_subpro2:setTouchEnabled(self.m_SetNum2 > 0)
  self.btn_subpro3:setTouchEnabled(self.m_SetNum3 > 0)
  self.btn_subpro4:setTouchEnabled(self.m_SetNum4 > 0)
  self.btn_addpro:setBright(total < self.m_SetNum_Max)
  self.btn_addpro2:setBright(total < self.m_SetNum_Max)
  self.btn_addpro3:setBright(total < self.m_SetNum_Max)
  self.btn_addpro4:setBright(total < self.m_SetNum_Max)
  self.btn_addpro:setTouchEnabled(total < self.m_SetNum_Max)
  self.btn_addpro2:setTouchEnabled(total < self.m_SetNum_Max)
  self.btn_addpro3:setTouchEnabled(total < self.m_SetNum_Max)
  self.btn_addpro4:setTouchEnabled(total < self.m_SetNum_Max)
end
function autoaddpoint:OnBtn_SubPro_GG(obj, t)
  if self.m_SetNum1 <= 0 then
    return
  end
  self.m_SetNum1 = self.m_SetNum1 - 1
  self.num1:setText(tostring(self.m_SetNum1))
  self:FreshBtn()
end
function autoaddpoint:OnBtn_SubPro_LX(obj, t)
  if self.m_SetNum2 <= 0 then
    return
  end
  self.m_SetNum2 = self.m_SetNum2 - 1
  self.num2:setText(tostring(self.m_SetNum2))
  self:FreshBtn()
end
function autoaddpoint:OnBtn_SubPro_LL(obj, t)
  if self.m_SetNum3 <= 0 then
    return
  end
  self.m_SetNum3 = self.m_SetNum3 - 1
  self.num3:setText(tostring(self.m_SetNum3))
  self:FreshBtn()
end
function autoaddpoint:OnBtn_SubPro_MJ(obj, t)
  if self.m_SetNum4 <= 0 then
    return
  end
  self.m_SetNum4 = self.m_SetNum4 - 1
  self.num4:setText(tostring(self.m_SetNum4))
  self:FreshBtn()
end
function autoaddpoint:OnBtn_AddPro_GG(obj, t)
  if self.m_SetNum1 + self.m_SetNum2 + self.m_SetNum3 + self.m_SetNum4 >= self.m_SetNum_Max then
    return
  end
  self.m_SetNum1 = self.m_SetNum1 + 1
  self.num1:setText(tostring(self.m_SetNum1))
  self:FreshBtn()
end
function autoaddpoint:OnBtn_AddPro_LX(obj, t)
  if self.m_SetNum1 + self.m_SetNum2 + self.m_SetNum3 + self.m_SetNum4 >= self.m_SetNum_Max then
    return
  end
  self.m_SetNum2 = self.m_SetNum2 + 1
  self.num2:setText(tostring(self.m_SetNum2))
  self:FreshBtn()
end
function autoaddpoint:OnBtn_AddPro_LL(obj, t)
  if self.m_SetNum1 + self.m_SetNum2 + self.m_SetNum3 + self.m_SetNum4 >= self.m_SetNum_Max then
    return
  end
  self.m_SetNum3 = self.m_SetNum3 + 1
  self.num3:setText(tostring(self.m_SetNum3))
  self:FreshBtn()
end
function autoaddpoint:OnBtn_AddPro_MJ(obj, t)
  if self.m_SetNum1 + self.m_SetNum2 + self.m_SetNum3 + self.m_SetNum4 >= self.m_SetNum_Max then
    return
  end
  self.m_SetNum4 = self.m_SetNum4 + 1
  self.num4:setText(tostring(self.m_SetNum4))
  self:FreshBtn()
end
function autoaddpoint:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function autoaddpoint:OnBtn_Cancel(obj, t)
  self:CloseSelf()
  netsend.netbaseptc.cancelAutoAddRolePoint(self.m_RoleId)
end
function autoaddpoint:OnBtn_Ok(obj, t)
  local total = self.m_SetNum1 + self.m_SetNum2 + self.m_SetNum3 + self.m_SetNum4
  if total == self.m_SetNum_Max then
    self:CloseSelf()
    netsend.netbaseptc.requestAutoAddRolePoint(self.m_RoleId, self.m_SetNum1, self.m_SetNum2, self.m_SetNum3, self.m_SetNum4)
  else
    ShowNotifyTips("自动加点必须设置和为4点")
  end
end
function autoaddpoint:OnMessage(msgSID, ...)
  if msgSID == MsgID_RoleAutoAddPointInfo then
    self:InitButton()
  end
end
