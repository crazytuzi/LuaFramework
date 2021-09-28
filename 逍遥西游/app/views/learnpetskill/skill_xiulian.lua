function ShowXiuLianSkillView(petId, skillId)
  if GetXiuLianSkillList(petId) == nil then
    ShowNotifyTips("召唤兽没有修炼中的终极技能，无法使用此物品")
    return
  else
    getCurSceneView():addSubView({
      subView = CXiuLianSkillView.new(petId, skillId),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function GetXiuLianSkillList(petId)
  local tmpList
  if g_LocalPlayer == nil then
    return nil
  end
  local petObj = g_LocalPlayer:getObjById(petId)
  if petObj == nil then
    return nil
  end
  local normalPetSkills = petObj:getProperty(PROPERTY_PETSKILLS)
  if type(normalPetSkills) ~= "table" then
    normalPetSkills = {}
  end
  local xlSkills = petObj:getProperty(PROPERTY_ZJSKILLSEXP)
  if type(xlSkills) ~= "table" then
    xlSkills = {}
  end
  for index = 1, #normalPetSkills do
    local skillId = normalPetSkills[index]
    if skillId > 0 then
      local xlFlag = xlSkills[skillId] ~= nil
      if xlFlag then
        if tmpList == nil then
          tmpList = {}
        end
        tmpList[#tmpList + 1] = skillId
      end
    end
  end
  return tmpList
end
CXiuLianSkillView = class("CXiuLianSkillView", CcsSubView)
function CXiuLianSkillView:ctor(petId, skillId)
  CXiuLianSkillView.super.ctor(self, "views/addskillxld.json", {isAutoCenter = true, opacityBg = 100})
  self.m_PetId = petId
  self.m_InitSkillId = skillId
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_YJXL),
      variName = "btn_confirm"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  local x, y = self:getNode("btn_pos"):getPosition()
  self.btn_addP = createClickButton("views/rolelist/btn_addpro.png", nil, handler(self, self.OnBtn_Confirm), 0.2)
  self:addChild(self.btn_addP)
  self.btn_addP:setPosition(ccp(x, y))
  self:addBatchBtnListener(btnBatchListener)
  self:loadAllSkills()
  self:SetTaiXuDanImg()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_MoveScene)
  self:ListenMessage(MsgID_ItemInfo)
end
function CXiuLianSkillView:loadAllSkills()
  local tempSkillIdList = GetXiuLianSkillList(self.m_PetId)
  self.m_SkillItems = {}
  self.m_LastSelectedItem = nil
  self.m_RollList = self:getNode("list_type")
  local initSkillObj, initIndex
  for i, skillId in ipairs(tempSkillIdList) do
    local item = CXiuLianSkill_Item.new(self.m_PetId, skillId, handler(self, self.itemSelected))
    self.m_RollList:pushBackCustomItem(item:getUINode())
    item:setSelected(false)
    self.m_SkillItems[i] = item
    if initSkillObj == nil then
      initSkillObj = item
      initIndex = i
    end
    if skillId == self.m_InitSkillId then
      initSkillObj = item
      initIndex = i
    end
  end
  self:itemSelected(initSkillObj)
  if initIndex ~= nil then
    self:ScrollToIndexSkill(initIndex)
  end
end
function CXiuLianSkillView:ScrollToIndexSkill(index)
  self.m_RollList:refreshView()
  local cnt = self.m_RollList:getCount()
  local h = self.m_RollList:getContentSize().height
  local ih = self.m_RollList:getInnerContainerSize().height
  if h < ih then
    local y = (1 - (index + 0.5) / cnt) * ih - h / 2
    local percent = (0.5 - y / (ih - h)) * 100
    percent = math.max(percent, 0)
    percent = math.min(percent, 100)
    self.m_RollList:scrollToPercentVertical(percent, 0.3, false)
  end
end
function CXiuLianSkillView:itemSelected(item)
  if self.m_LastSelectedItem then
    self.m_LastSelectedItem:setSelected(false)
  end
  self.m_LastSelectedItem = item
  if self.m_LastSelectedItem then
    self.m_LastSelectedItem:setSelected(true)
  end
  self:ShowSkillDetail(item:getId())
end
function CXiuLianSkillView:ShowSkillDetail(skillId)
  local curXLD = 0
  local maxXLD = data_getSkillNeedXiuLianDu(skillId)
  local petObj
  if g_LocalPlayer and g_LocalPlayer:getObjById(self.m_PetId) then
    petObj = g_LocalPlayer:getObjById(self.m_PetId)
    local xlSkills = petObj:getProperty(PROPERTY_ZJSKILLSEXP)
    if type(xlSkills) ~= "table" then
      xlSkills = {}
    end
    if xlSkills[skillId] ~= nil then
      curXLD = xlSkills[skillId][1]
      maxXLD = xlSkills[skillId][2]
    end
  end
  self:getNode("skill_xld"):setText(string.format("%d/%d", curXLD, maxXLD))
  self:getNode("bar"):setPercent(curXLD / maxXLD * 100)
  local x, y = self:getNode("tips_pos"):getPosition()
  local size = self:getNode("tips_pos"):getContentSize()
  local parent = self:getNode("tips_pos"):getParent()
  if self.m_SkillTips == nil then
    self.m_SkillTips = CRichText.new({
      width = size.width,
      fontSize = 22,
      color = ccc3(255, 255, 255),
      align = CRichText_AlignType_Left
    })
    parent:addChild(self.m_SkillTips)
  else
    self.m_SkillTips:clearAll()
  end
  local skillType = _getSkillStyle(skillId)
  if skillType == SKILLSTYLE_INITIATIVE then
    self.m_SkillTips:addRichText("【类型】主动\n")
  else
    self.m_SkillTips:addRichText("【类型】被动\n")
  end
  local txtStr = data_getPetSkillWbDesc(skillId)
  self.m_SkillTips:addRichText(txtStr)
  local h = self.m_SkillTips:getContentSize().height
  self.m_SkillTips:setPosition(ccp(x, y + size.height - h))
end
function CXiuLianSkillView:SetTaiXuDanImg()
  local pos = self:getNode("item_pos")
  local s = pos:getContentSize()
  local clickListener = handler(self, self.ShowStuffDetail)
  icon = createClickItem({
    itemID = ITEM_DEF_OTHER_TaiXuDan,
    autoSize = nil,
    num = 0,
    LongPressTime = 0,
    clickListener = clickListener,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = false
  })
  pos:addChild(icon)
  self:SetTaiXuDanNum()
end
function CXiuLianSkillView:ShowStuffDetail(obj, t)
  self.m_PopStuffDetail = CEquipDetail.new(nil, {
    closeListener = handler(self, self.CloseStuffDetail),
    itemType = ITEM_DEF_OTHER_TaiXuDan
  })
  self:addSubView({
    subView = self.m_PopStuffDetail,
    zOrder = 9999
  })
  local selfSize = self:getNode("boxbg"):getSize()
  local viewSize = self.m_PopStuffDetail:getBoxSize()
  self.m_PopStuffDetail:setPosition(ccp(selfSize.width / 2 - viewSize.width / 2, selfSize.height / 2 - viewSize.height / 2))
  self.m_PopStuffDetail:ShowCloseBtn()
end
function CXiuLianSkillView:CloseStuffDetail()
  if self.m_PopStuffDetail then
    local tempObj = self.m_PopStuffDetail
    self.m_PopStuffDetail = nil
    tempObj:CloseSelf()
  end
end
function CXiuLianSkillView:SetTaiXuDanNum()
  local itemNeedNum = 1
  local curNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_TaiXuDan)
  local pos = self:getNode("item_pos")
  local s = pos:getContentSize()
  local numLabel = pos._posNum
  if numLabel == nil then
    numLabel = CCLabelTTF:create(string.format("%s/%s", curNum, itemNeedNum), ITEM_NUM_FONT, 22)
    numLabel:setAnchorPoint(ccp(1, 0))
    numLabel:setPosition(ccp(s.width - 5, 5))
    pos:addNode(numLabel)
    pos._posNum = numLabel
  else
    numLabel:setString(string.format("%s/%s", curNum, itemNeedNum))
  end
  if itemNeedNum <= curNum then
    numLabel:setColor(VIEW_DEF_PGREEN_COLOR)
  else
    numLabel:setColor(VIEW_DEF_WARNING_COLOR)
  end
  AutoLimitObjSize(numLabel, 70)
end
function CXiuLianSkillView:OnBtn_Confirm()
  if self.m_LastSelectedItem == nil then
    ShowNotifyTips("请选择需要修炼的技能")
    self.btn_addP:stopLongPressClick()
    return
  end
  local itemNeedNum = 1
  local curNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_TaiXuDan)
  if itemNeedNum > curNum then
    self.btn_addP:stopLongPressClick()
  end
  local skillId = self.m_LastSelectedItem:getId()
  netsend.netbaseptc.UseTaiXuDanForPet(self.m_PetId, skillId)
end
function CXiuLianSkillView:OnBtn_YJXL()
  if self.m_LastSelectedItem == nil then
    ShowNotifyTips("请选择需要修炼的技能")
    return
  end
  local skillId = self.m_LastSelectedItem:getId()
  netsend.netbaseptc.UseTaiXuDan_YJXLForPet(self.m_PetId, skillId)
end
function CXiuLianSkillView:OnBtn_Close()
  self:CloseSelf()
end
function CXiuLianSkillView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if d.petId == self.m_PetId then
      local proTable = d.pro
      if proTable[PROPERTY_ZJSKILLSEXP] ~= nil then
        local mySkillId
        if self.m_LastSelectedItem ~= nil then
          mySkillId = self.m_LastSelectedItem:getId()
        end
        if mySkillId and proTable[PROPERTY_ZJSKILLSEXP][mySkillId] == nil then
          self:CloseSelf()
        else
          self:ShowSkillDetail(mySkillId)
        end
      end
    end
  elseif msgSID == MsgID_ItemInfo_AddItem then
    self:SetTaiXuDanNum()
  elseif msgSID == MsgID_ItemInfo_DelItem then
    self:SetTaiXuDanNum()
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum then
    self:SetTaiXuDanNum()
  elseif msgSID == MsgID_ItemSource_Jump then
    self:CloseStuffDetail()
    self:CloseSelf()
  end
end
function CXiuLianSkillView:Clear()
  self:CloseStuffDetail()
end
CXiuLianSkill_Item = class("CXiuLianSkill_Item", CcsSubView)
function CXiuLianSkill_Item:ctor(petId, skillId, selectListener)
  CXiuLianSkill_Item.super.ctor(self, "views/addskillxld_item.csb")
  self.m_SkillId = skillId
  self.panel_sel = self:getNode("panel_sel")
  self.pic_bg = self:getNode("pic_bg")
  self.pic_bg:setTouchEnabled(true)
  self.pic_bg:addTouchEventListener(handler(self, self.TouchBg))
  local skillName = data_getSkillName(skillId)
  self:getNode("txt"):setText(skillName)
  local path = "xiyou/skill/skill_unknown.png"
  local tempImg = display.newSprite(path)
  local x, y = self:getNode("skill_pos"):getPosition()
  local z = self:getNode("skill_pos"):getZOrder()
  local size = self:getNode("skill_pos"):getSize()
  local mSize = tempImg:getContentSize()
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  tempImg:setScale(size.width / mSize.width)
  self:addNode(tempImg, z)
  self.m_SelectedListener = selectListener
end
function CXiuLianSkill_Item:TouchBg(touchObj, t)
  if t == TOUCH_EVENT_BEGAN then
    self:setTouchStatus(true)
  elseif t == TOUCH_EVENT_ENDED then
    self:setTouchStatus(false)
    if self.m_SelectedListener then
      self.m_SelectedListener(self)
    end
  elseif t == TOUCH_EVENT_CANCELED then
    self:setTouchStatus(false)
  end
end
function CXiuLianSkill_Item:setSelected(isSel)
  self.panel_sel:setVisible(isSel)
end
function CXiuLianSkill_Item:getId()
  return self.m_SkillId
end
function CXiuLianSkill_Item:setTouchStatus(isTouch)
  if self.pic_bg then
    self.pic_bg:stopAllActions()
    if isTouch then
      self.pic_bg:setScaleX(0.95)
      self.pic_bg:setScaleY(0.95)
    else
      self.pic_bg:setScaleX(1)
      self.pic_bg:setScaleY(1)
      self.pic_bg:runAction(transition.sequence({
        CCScaleTo:create(0.1, 1.05, 1.05),
        CCScaleTo:create(0.1, 1, 1)
      }))
    end
  end
end
function CXiuLianSkill_Item:Clear()
  self.m_SelectedListener = nil
end
