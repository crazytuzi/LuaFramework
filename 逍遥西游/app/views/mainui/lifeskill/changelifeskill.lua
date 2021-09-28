function ShowChangeLifeSkill()
  local lifeSkillID = LIFESKILL_NO
  if g_LocalPlayer then
    lifeSkillID, _ = g_LocalPlayer:getBaseLifeSkill()
  end
  if lifeSkillID == LIFESKILL_NO then
    ShowNotifyTips("你还没学会生活技能")
    return
  end
  getCurSceneView():addSubView({
    subView = CChangeLifeSkill.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
CChangeLifeSkill = class("CChangeLifeSkill", CcsSubView)
function CChangeLifeSkill:ctor(para)
  self.m_LifeSkillID = LIFESKILL_NO
  self.m_LifeSkillLV = 0
  if g_LocalPlayer then
    self.m_LifeSkillID, self.m_LifeSkillLV = g_LocalPlayer:getBaseLifeSkill()
  end
  CChangeLifeSkill.super.ctor(self, "views/changelifeskill.json", {isAutoCenter = true, opacityBg = 100})
  self:SetCreateView()
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CChangeLifeSkill:SetCreateView()
  local btnBatchListener = {
    btn_learn = {
      listener = handler(self, self.OnBtn_Learn),
      variName = "btn_learn"
    },
    btn_detail = {
      listener = handler(self, self.OnBtn_Detail),
      variName = "btn_detail"
    },
    btn_addcoin = {
      listener = handler(self, self.OnBtn_AddCoin),
      variName = "btn_addcoin"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_SelectIDList = {
    LIFESKILL_MAKEDRUG,
    LIFESKILL_MAKEFU,
    LIFESKILL_MAKEFOOD,
    LIFESKILL_CATCH
  }
  for index, skId in pairs(self.m_SelectIDList) do
    if skId == self.m_LifeSkillID then
      table.remove(self.m_SelectIDList, index)
      break
    end
  end
  self:SetSkillList(self.m_SelectIDList)
  self.m_SelectLifeSkillID = nil
  self.m_SelectObjList = nil
  local Random = math.random(1, 3)
  self:SelectSkill(self.m_SelectIDList[Random], Random)
  self:getNode("txt_cost"):setText("花费")
  self:UpdateResData()
  local x, y = self:getNode("box_coin"):getPosition()
  local z = self:getNode("box_coin"):getZOrder()
  local size = self:getNode("box_coin"):getSize()
  self:getNode("box_coin"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
end
function CChangeLifeSkill:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("coinBg"), "rescoin")
end
function CChangeLifeSkill:SetSkillList(list)
  for index, skID in ipairs(list) do
    do
      local x, y = self:getNode(string.format("box_item_%d", index)):getPosition()
      local tempBtn = createClickButton(data_getLifeSkillIconPath(skID), nil, function()
        self:SelectSkill(skID, index)
      end, nil, nil, true)
      tempBtn:setPosition(ccp(x, y))
      self:addChild(tempBtn)
    end
  end
end
function CChangeLifeSkill:SelectSkill(skID, index)
  print("selectSkill", skID)
  local skillName = data_getLifeSkillName(skID)
  self:getNode("txt_name"):setText(skillName)
  if self.m_SkillDesc ~= nil then
    self.m_SkillDesc:removeFromParent()
  end
  local x, y = self:getNode("box_des"):getPosition()
  local descSize = self:getNode("box_des"):getSize()
  local tempDesc = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255)
  })
  self:addChild(tempDesc)
  tempDesc:addRichText(data_getLifeSkillDesc(skID))
  local richSize = tempDesc:getContentSize()
  tempDesc:setPosition(ccp(x, y + descSize.height - richSize.height))
  self.m_SkillDesc = tempDesc
  local temp1, temp2, temp3, temp4
  local x, y = self:getNode(string.format("box_item_%d", index)):getPosition()
  local del = 15
  local temp = display.newSprite(data_getLifeSkillIconPath(1))
  local bgSize = temp:getContentSize()
  if self.m_SelectObjList then
    temp1 = self.m_SelectObjList[1]
    temp2 = self.m_SelectObjList[2]
    temp3 = self.m_SelectObjList[3]
    temp4 = self.m_SelectObjList[4]
  else
    temp1 = display.newSprite("views/pic/pic_selectcorner.png")
    temp2 = display.newSprite("views/pic/pic_selectcorner.png")
    temp3 = display.newSprite("views/pic/pic_selectcorner.png")
    temp4 = display.newSprite("views/pic/pic_selectcorner.png")
    self.m_SelectObjList = {
      temp1,
      temp2,
      temp3,
      temp4
    }
    self:addNode(temp1)
    self:addNode(temp2)
    self:addNode(temp3)
    self:addNode(temp4)
  end
  temp1:setPosition(ccp(x - del, y - del))
  temp1:setAnchorPoint(ccp(0, 1))
  temp1:setScaleY(-1)
  temp2:setPosition(ccp(x - del, y + bgSize.height + del))
  temp2:setAnchorPoint(ccp(0, 1))
  temp3:setPosition(ccp(x + bgSize.width + del, y - del))
  temp3:setAnchorPoint(ccp(0, 1))
  temp3:setScaleX(-1)
  temp3:setScaleY(-1)
  temp4:setPosition(ccp(x + bgSize.width + del, y + bgSize.height + del))
  temp4:setAnchorPoint(ccp(0, 1))
  temp4:setScaleX(-1)
  self.m_SelectLifeSkillID = skID
end
function CChangeLifeSkill:OnBtn_Learn(obj, t)
  if self.m_SelectLifeSkillID == nil then
    ShowNotifyTips("请先选择技能")
    return
  end
  if self.m_SelectLifeSkillID == self.m_LifeSkillID then
    ShowNotifyTips("无需重修")
    return
  end
  self:confirmToRelearnSKill()
end
function CChangeLifeSkill:confirmToRelearnSKill()
  local confirmView = CPopWarning.new({
    title = "重修技能",
    text = "确定要花费500000#<IR1>#重修生活技能吗？重修后新的技能等级将变为#<R,>0#级",
    confirmFunc = function()
      netsend.netlifeskill.reLearnedLifeSkill(self.m_SelectLifeSkillID)
      g_MissionMgr:GuideIdComplete(GuideId_ShengHuoJiNeng)
    end,
    cancelText = "取消",
    confirmText = "确定",
    hideInWar = true,
    align = CRichText_AlignType_Left
  })
  confirmView:ShowCloseBtn(false)
end
function CChangeLifeSkill:OnBtn_Detail(obj, t)
  self:HideSelf()
  local function callback()
    if self then
      self:ShowSelf()
    end
  end
  if self.m_SelectLifeSkillID == LIFESKILL_CATCH then
    getCurSceneView():addSubView({
      subView = CShowLifeSkillDetail_pet.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_SelectLifeSkillID == LIFESKILL_MAKEFOOD then
    getCurSceneView():addSubView({
      subView = CShowLifeSkillDetail_cook.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_SelectLifeSkillID == LIFESKILL_MAKEFU then
    getCurSceneView():addSubView({
      subView = CShowLifeSkillDetail_fuwen.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_SelectLifeSkillID == LIFESKILL_MAKEDRUG then
    getCurSceneView():addSubView({
      subView = CShowLifeSkillDetail_drug.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    self:ShowSelf()
  end
end
function CChangeLifeSkill:UpdateResData()
  self:getNode("txt_coin"):setText(string.format("%d", data_Variables.ReStudyLifeSkill_CostCoin))
  if data_Variables.ReStudyLifeSkill_CostCoin <= g_LocalPlayer:getCoin() then
    self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  else
    self:getNode("txt_coin"):setColor(ccc3(255, 0, 0))
  end
end
function CChangeLifeSkill:OnBtn_AddCoin(obj, t)
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CChangeLifeSkill:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CChangeLifeSkill:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:UpdateResData()
  elseif msgSID == MsgID_LifeSkillUpdate then
    self:CloseSelf()
  end
end
function CChangeLifeSkill:HideSelf()
  self:setVisible(false)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
  end
end
function CChangeLifeSkill:ShowSelf()
  self:setVisible(true)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(true)
  end
end
function CChangeLifeSkill:Clear()
end
