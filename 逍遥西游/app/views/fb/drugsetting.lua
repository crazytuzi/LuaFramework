CDrugSetting = class("CDrugSetting", CcsSubView)
local BTN_SKILLIMG_TAG = 9999
function CDrugSetting:ctor(waruiObj)
  CDrugSetting.super.ctor(self, "views/drugsetting.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "m_Btn_Close",
      param = {3}
    },
    btn_11 = {
      listener = handler(self, self.Btn_11),
      variName = "m_Btn_11"
    },
    btn_12 = {
      listener = handler(self, self.Btn_12),
      variName = "m_Btn_12"
    },
    btn_13 = {
      listener = handler(self, self.Btn_13),
      variName = "m_Btn_13"
    },
    btn_14 = {
      listener = handler(self, self.Btn_14),
      variName = "m_Btn_14"
    },
    btn_21 = {
      listener = handler(self, self.Btn_21),
      variName = "m_Btn_21"
    },
    btn_22 = {
      listener = handler(self, self.Btn_22),
      variName = "m_Btn_22"
    },
    btn_23 = {
      listener = handler(self, self.Btn_23),
      variName = "m_Btn_23"
    },
    btn_24 = {
      listener = handler(self, self.Btn_24),
      variName = "m_Btn_24"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local tempData = g_LocalPlayer:getAIUseDrugSetting()
  self.m_SelectHPType = tempData.SelectHPType or 1
  self.m_SelectMPType = tempData.SelectMPType or 1
  self:SelectNum(10 + self.m_SelectHPType)
  self:SelectNum(20 + self.m_SelectMPType)
end
function CDrugSetting:SelectNum(num)
  local tag = BTN_SKILLIMG_TAG
  local j = math.floor(num / 10)
  if num > 20 then
    self.m_SelectMPType = num % 10
  else
    self.m_SelectHPType = num % 10
  end
  for i = 1, 4 do
    local btnName = string.format("m_Btn_%d%d", j, i)
    local btn = self[btnName]
    if j * 10 + i == num then
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
end
function CDrugSetting:Btn_11(obj, t)
  self:SelectNum(11)
end
function CDrugSetting:Btn_12(obj, t)
  self:SelectNum(12)
end
function CDrugSetting:Btn_13(obj, t)
  self:SelectNum(13)
end
function CDrugSetting:Btn_14(obj, t)
  self:SelectNum(14)
end
function CDrugSetting:Btn_21(obj, t)
  self:SelectNum(21)
end
function CDrugSetting:Btn_22(obj, t)
  self:SelectNum(22)
end
function CDrugSetting:Btn_23(obj, t)
  self:SelectNum(23)
end
function CDrugSetting:Btn_24(obj, t)
  self:SelectNum(24)
end
function CDrugSetting:Btn_Close(obj, t)
  local drugSetting = {
    SelectHPType = self.m_SelectHPType,
    SelectMPType = self.m_SelectMPType
  }
  local tempData = g_LocalPlayer:getAIUseDrugSetting()
  if tempData.SelectHPType ~= self.m_SelectHPType or tempData.SelectMPType ~= self.m_SelectMPType then
    netsend.netwar.submitWarDrugSetting(self.m_SelectHPType, self.m_SelectMPType)
  end
  g_LocalPlayer:setAIUseDrugSetting(drugSetting)
  self:removeFromParent()
end
return CDrugSetting
