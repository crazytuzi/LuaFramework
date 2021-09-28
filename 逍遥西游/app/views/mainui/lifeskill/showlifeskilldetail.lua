SHOWLIFESKILL_FUWEN_QIANGFA = 1
SHOWLIFESKILL_FUWEN_QITA = 5
SHOWLIFESKILL_COOKING_FOOD = 1
SHOWLIFESKILL_COOKING_WINE = 2
SHOWLIFESKILL_DRUG_QIXUE = 1
SHOWLIFESKILL_DRUG_FALI = 2
SHOWLIFESKILL_DRUG_SHUANGHUI = 3
CShowLifeSkillDetail_pet = class("CShowLifeSkillDetail_pet", CcsSubView)
function CShowLifeSkillDetail_pet:ctor(callback)
  CShowLifeSkillDetail_pet.super.ctor(self, "views/skill_pet.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self.m_CallBackFunc = callback
  self:addBatchBtnListener(btnBatchListener)
  self:setShenShouPanel()
end
function CShowLifeSkillDetail_pet:setShenShouPanel()
  self.m_subPetPos = self:getNode("subPos")
  local lTypeList = {}
  for petTypeId, data in pairs(data_Pet) do
    if data_getPetTypeIsGaoJiShouHu(petTypeId) then
      lTypeList[#lTypeList + 1] = petTypeId
    end
  end
  self.m_PetListBoard_Special = CShowlifeskillpetFrame.new({
    petTypeList = lTypeList,
    clickListener = handler(self, self.OnSelectPet),
    xySpace = ccp(40, 40),
    initType = nil,
    pageLines = 3,
    oneLineNum = 4
  })
  local size = self.m_subPetPos:getContentSize()
  self:addChildObjByControl(self.m_PetListBoard_Special, self.m_subPetPos, 0, -size.height / 2)
end
function CShowLifeSkillDetail_pet:addChildObjByControl(obj, ctrObj, width, height)
  local parent = ctrObj:getParent()
  local x, y = ctrObj:getPosition()
  local zOrder = ctrObj:getZOrder()
  parent:addChild(obj, zOrder)
  obj:setPosition(ccp(x + width, y + height))
end
function CShowLifeSkillDetail_pet:OnBtn_Close(...)
  self:CloseSelf()
end
function CShowLifeSkillDetail_pet:OnSelectPet(petTypeId)
  if petTypeId ~= nil then
    local petDetail = CShowLifeSkillPetDetail.new(petTypeId)
    local x, y = self:getUINode():getPosition()
    local petViewSize = petDetail:getContentSize()
    local mSize = self:getContentSize()
    self:addSubView({
      subView = petDetail,
      zOrder = MainUISceneZOrder.menuView
    })
    local nodePos = self:getUINode():convertToNodeSpace(ccp(x, y))
    petDetail:setPosition(ccp(nodePos.x + mSize.width / 2 - petViewSize.width / 4 + 35, nodePos.y))
  end
end
function CShowLifeSkillDetail_pet:Clear()
  self.m_PetListBoard_Special = nil
  if self.m_CallBackFunc then
    self.m_CallBackFunc()
    self.m_CallBackFunc = nil
  end
end
CShowLifeSkillDetail_fuwen = class("CShowLifeSkillDetail_fuwen", CcsSubView)
function CShowLifeSkillDetail_fuwen:ctor(callback)
  CShowLifeSkillDetail_fuwen.super.ctor(self, "views/skill_fuwen.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self.m_CallBackFunc = callback
  self:addBatchBtnListener(btnBatchListener)
  self:setFuWenPanel()
end
function CShowLifeSkillDetail_fuwen:setFuWenPanel()
  local itemTypeIdList_QFItemId = {}
  local itemTypeIdList_QTItemId = {}
  for itemTypeId, data in pairs(data_LifeSkill_Rune) do
    if data.MainCategoryId ~= SHOWLIFESKILL_FUWEN_QITA then
      if data.NeedQuality == 0 then
        itemTypeIdList_QFItemId[#itemTypeIdList_QFItemId + 1] = itemTypeId
      end
    elseif data.MainCategoryId == SHOWLIFESKILL_FUWEN_QITA and data.NeedQuality == 0 then
      itemTypeIdList_QTItemId[#itemTypeIdList_QTItemId + 1] = itemTypeId
    end
  end
  local sortFunc = function(itemId_1, itemId_2)
    if itemId_1 == nil or itemId_2 == nil then
      return
    end
    local data_1 = data_LifeSkill_Rune[itemId_1]
    local data_2 = data_LifeSkill_Rune[itemId_2]
    if data_1.NeedLv ~= data_2.NeedLv then
      return data_1.NeedLv < data_2.NeedLv
    else
      return data_1.price < data_2.price
    end
  end
  table.sort(itemTypeIdList_QFItemId, sortFunc)
  table.sort(itemTypeIdList_QTItemId, sortFunc)
  local onelineNum_qiangfa = 5
  local linenNum_qiangfa = math.ceil(#itemTypeIdList_QFItemId / onelineNum_qiangfa)
  local FuWenListView_qiangfa = CShowLifeSkillItemFrame.new({
    clickListener = handler(self, self.OnSelectFuWen),
    itmeTypeIdTalbe = itemTypeIdList_QFItemId,
    pageLines = linenNum_qiangfa
  })
  local onelineNum_qita = 5
  local linenNum_qita = math.ceil(#itemTypeIdList_QTItemId / onelineNum_qita)
  local FuWenListView_qita = CShowLifeSkillItemFrame.new({
    clickListener = handler(self, self.OnSelectFuWen),
    itmeTypeIdTalbe = itemTypeIdList_QTItemId,
    pageLines = linenNum_qita
  })
  self:getNode("fuwen_list_1"):pushBackCustomItem(FuWenListView_qiangfa)
  self:getNode("fuwen_list_2"):pushBackCustomItem(FuWenListView_qita)
  self:getNode("fuwen_list_1"):sizeChangedForShowMoreTips()
  self:getNode("fuwen_list_2"):sizeChangedForShowMoreTips()
end
function CShowLifeSkillDetail_fuwen:OnSelectFuWen(itemTypeId, obj)
  if self.m_oldSelectItem then
    self.m_oldSelectItem:setSelected(false)
  end
  local data_table = GetItemDataByItemTypeId(itemTypeId)
  local PopItemDetailView = CEquipDetail.new(nil, {
    closeListener = nil,
    itemType = itemTypeId,
    fromPackageFlag = true,
    showName = data_table[itemTypeId].MinorCategoryName
  })
  self:addSubView({
    subView = PopItemDetailView,
    zOrder = MainUISceneZOrder.menuView
  })
  self.m_sItem = obj:getTouchBeganItem()
  local bSize = PopItemDetailView:getBoxSize()
  local bx, by = PopItemDetailView:getPosition()
  local sx, sy = self.m_sItem:getPosition()
  local sSize = self.m_sItem:getBoxSize()
  local swPos = self.m_sItem:getParent():convertToWorldSpace(ccp(sx, sy + sSize.height / 2))
  local wPosY = swPos.y - bSize.height / 2
  local wPosX = swPos.x - bSize.width / 2
  if wPosX < 0 then
    wPosY = 0
  end
  if wPosY < 0 then
    wPosY = 0
  end
  if wPosY + bSize.height > display.height then
    wPosY = display.height - bSize.height
  end
  if wPosX > display.width then
    wPosX = wPosX - bSize.width / 2 - sSize.width
  elseif wPosX < display.width then
    wPosX = wPosX + bSize.width / 2 + sSize.width
  end
  newPos = self:getUINode():convertToNodeSpace(ccp(wPosX, wPosY))
  worldPos = self:getUINode():convertToWorldSpace(ccp(bx, by))
  if wPosX > worldPos.x + bSize.width then
    newPos.x = newPos.x - bSize.width - sSize.width
  end
  PopItemDetailView:setPosition(ccp(newPos.x, newPos.y))
  self.m_oldSelectItem = self.m_sItem
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
end
function CShowLifeSkillDetail_fuwen:OnBtn_Close(...)
  self:CloseSelf()
end
function CShowLifeSkillDetail_fuwen:Clear()
  if self.m_CallBackFunc then
    self.m_CallBackFunc()
    self.m_CallBackFunc = nil
  end
end
CShowLifeSkillDetail_cook = class("CShowLifeSkillDetail_cook", CcsSubView)
function CShowLifeSkillDetail_cook:ctor(callback)
  CShowLifeSkillDetail_cook.super.ctor(self, "views/skill_food.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self.m_CallBackFunc = callback
  self:addBatchBtnListener(btnBatchListener)
  self:setCookingPanel()
end
function CShowLifeSkillDetail_cook:setCookingPanel()
  local itemTypeIdList_food = {}
  local itemTypeIdList_wine = {}
  for itemTypeId, data in pairs(data_LifeSkill_Food) do
    if data.MainCategoryId == SHOWLIFESKILL_COOKING_FOOD then
      if data.NeedQuality == 0 then
        itemTypeIdList_food[#itemTypeIdList_food + 1] = itemTypeId
      end
    elseif data.MainCategoryId ~= SHOWLIFESKILL_COOKING_FOOD and data.NeedQuality == 0 then
      itemTypeIdList_wine[#itemTypeIdList_wine + 1] = itemTypeId
    end
  end
  local sortFunc = function(itemId_1, itemId_2)
    if itemId_1 == nil or itemId_2 == nil then
      return
    end
    local data_1 = data_LifeSkill_Food[itemId_1]
    local data_2 = data_LifeSkill_Food[itemId_2]
    if data_1.NeedLv ~= data_2.NeedLv then
      return data_1.NeedLv < data_2.NeedLv
    else
      return data_1.price < data_2.price
    end
  end
  table.sort(itemTypeIdList_wine, sortFunc)
  table.sort(itemTypeIdList_food, sortFunc)
  local onelineNum_food = 5
  local linenNum_food = math.ceil(#itemTypeIdList_food / onelineNum_food)
  local CookingListView_food = CShowLifeSkillItemFrame.new({
    clickListener = handler(self, self.OnSelectCook),
    itmeTypeIdTalbe = itemTypeIdList_food,
    pageLines = linenNum_food
  })
  local onelineNum_wine = 5
  local linenNum_wine = math.ceil(#itemTypeIdList_wine / onelineNum_wine)
  local CookingListView_wine = CShowLifeSkillItemFrame.new({
    clickListener = handler(self, self.OnSelectCook),
    itmeTypeIdTalbe = itemTypeIdList_wine,
    pageLines = linenNum_wine
  })
  self:getNode("food_list_1"):pushBackCustomItem(CookingListView_food)
  self:getNode("food_list_2"):pushBackCustomItem(CookingListView_wine)
  self:getNode("food_list_1"):sizeChangedForShowMoreTips()
  self:getNode("food_list_2"):sizeChangedForShowMoreTips()
end
function CShowLifeSkillDetail_cook:OnSelectCook(itemTypeId, obj)
  if self.m_oldSelectItem then
    self.m_oldSelectItem:setSelected(false)
  end
  local data_table = GetItemDataByItemTypeId(itemTypeId)
  local PopItemDetailView = CEquipDetail.new(nil, {
    closeListener = nil,
    itemType = itemTypeId,
    fromPackageFlag = true,
    showName = data_table[itemTypeId].MinorCategoryName
  })
  self:addSubView({
    subView = PopItemDetailView,
    zOrder = MainUISceneZOrder.menuView
  })
  self.m_sItem = obj:getTouchBeganItem()
  local bSize = PopItemDetailView:getBoxSize()
  local bx, by = PopItemDetailView:getPosition()
  local sx, sy = self.m_sItem:getPosition()
  local sSize = self.m_sItem:getBoxSize()
  local swPos = self.m_sItem:getParent():convertToWorldSpace(ccp(sx, sy + sSize.height / 2))
  local wPosY = swPos.y - bSize.height / 2
  local wPosX = swPos.x - bSize.width / 2
  if wPosX < 0 then
    wPosY = 0
  end
  if wPosY < 0 then
    wPosY = 0
  end
  if wPosY + bSize.height > display.height then
    wPosY = display.height - bSize.height
  end
  if wPosX > display.width then
    wPosX = wPosX - bSize.width / 2 - sSize.width
  elseif wPosX < display.width then
    wPosX = wPosX + bSize.width / 2 + sSize.width
  end
  newPos = self:getUINode():convertToNodeSpace(ccp(wPosX, wPosY))
  worldPos = self:getUINode():convertToWorldSpace(ccp(bx, by))
  if wPosX > worldPos.x + bSize.width then
    newPos.x = newPos.x - bSize.width - sSize.width
  end
  PopItemDetailView:setPosition(ccp(newPos.x, newPos.y))
  self.m_oldSelectItem = self.m_sItem
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
end
function CShowLifeSkillDetail_cook:OnBtn_Close(...)
  self:CloseSelf()
end
function CShowLifeSkillDetail_cook:Clear()
  if self.m_CallBackFunc then
    self.m_CallBackFunc()
    self.m_CallBackFunc = nil
  end
end
CShowLifeSkillDetail_drug = class("CShowLifeSkillDetail_drug", CcsSubView)
function CShowLifeSkillDetail_drug:ctor(callback)
  CShowLifeSkillDetail_drug.super.ctor(self, "views/skill_drug.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self.m_CallBackFunc = callback
  self:addBatchBtnListener(btnBatchListener)
  self:setDrugPanel()
end
function CShowLifeSkillDetail_drug:setDrugPanel()
  local itemTypeIdList_qixue = {}
  local itemTypeIdList_fali = {}
  local itemTypeIdList_shuanghui = {}
  for itemTypeId, data in pairs(data_LifeSkill_Drug) do
    if data.MainCategoryId == SHOWLIFESKILL_DRUG_QIXUE then
      if data.NeedQuality == 0 then
        itemTypeIdList_qixue[#itemTypeIdList_qixue + 1] = itemTypeId
      end
    elseif data.MainCategoryId == SHOWLIFESKILL_DRUG_FALI then
      if data.NeedQuality == 0 then
        itemTypeIdList_fali[#itemTypeIdList_fali + 1] = itemTypeId
      end
    elseif data.MainCategoryId == SHOWLIFESKILL_DRUG_SHUANGHUI and data.NeedQuality == 0 then
      itemTypeIdList_shuanghui[#itemTypeIdList_shuanghui + 1] = itemTypeId
    end
  end
  local sortFunc = function(itemId_1, itemId_2)
    if itemId_1 == nil or itemId_2 == nil then
      return
    end
    local data_1 = data_LifeSkill_Drug[itemId_1]
    local data_2 = data_LifeSkill_Drug[itemId_2]
    if data_1.NeedLv ~= data_2.NeedLv then
      return data_1.NeedLv < data_2.NeedLv
    else
      return data_1.price < data_2.price
    end
  end
  table.sort(itemTypeIdList_qixue, sortFunc)
  table.sort(itemTypeIdList_fali, sortFunc)
  table.sort(itemTypeIdList_shuanghui, sortFunc)
  local onelineNum_qixue = 5
  local linenNum_qixue = math.ceil(#itemTypeIdList_qixue / onelineNum_qixue)
  local DrugListView_qixue = CShowLifeSkillItemFrame.new({
    clickListener = handler(self, self.OnSelectDrug),
    itmeTypeIdTalbe = itemTypeIdList_qixue,
    pageLines = linenNum_qixue
  })
  local onelineNum_fali = 5
  local linenNum_fali = math.ceil(#itemTypeIdList_fali / onelineNum_fali)
  local DrugListView_fali = CShowLifeSkillItemFrame.new({
    clickListener = handler(self, self.OnSelectDrug),
    itmeTypeIdTalbe = itemTypeIdList_fali,
    pageLines = linenNum_fali
  })
  local onelineNum_shuanghui = 5
  local linenNum_shuanghui = math.ceil(#itemTypeIdList_shuanghui / onelineNum_shuanghui)
  local DrugListView_shuanghui = CShowLifeSkillItemFrame.new({
    clickListener = handler(self, self.OnSelectDrug),
    itmeTypeIdTalbe = itemTypeIdList_shuanghui,
    pageLines = linenNum_shuanghui
  })
  self:getNode("drug_list_1"):pushBackCustomItem(DrugListView_qixue)
  self:getNode("drug_list_2"):pushBackCustomItem(DrugListView_fali)
  self:getNode("drug_list_3"):pushBackCustomItem(DrugListView_shuanghui)
  self:getNode("drug_list_1"):sizeChangedForShowMoreTips()
  self:getNode("drug_list_2"):sizeChangedForShowMoreTips()
  self:getNode("drug_list_3"):sizeChangedForShowMoreTips()
end
function CShowLifeSkillDetail_drug:OnSelectDrug(itemTypeId, obj)
  if self.m_oldSelectItem then
    self.m_oldSelectItem:setSelected(false)
  end
  local data_table = GetItemDataByItemTypeId(itemTypeId)
  local PopItemDetailView = CEquipDetail.new(nil, {
    closeListener = nil,
    itemType = itemTypeId,
    fromPackageFlag = true,
    showName = data_table[itemTypeId].MinorCategoryName
  })
  self:addSubView({
    subView = PopItemDetailView,
    zOrder = MainUISceneZOrder.menuView
  })
  self.m_sItem = obj:getTouchBeganItem()
  local bSize = PopItemDetailView:getBoxSize()
  local bx, by = PopItemDetailView:getPosition()
  local sx, sy = self.m_sItem:getPosition()
  local sSize = self.m_sItem:getBoxSize()
  local swPos = self.m_sItem:getParent():convertToWorldSpace(ccp(sx, sy + sSize.height / 2))
  local wPosY = swPos.y - bSize.height / 2
  local wPosX = swPos.x - bSize.width / 2
  if wPosX < 0 then
    wPosY = 0
  end
  if wPosY < 0 then
    wPosY = 0
  end
  if wPosY + bSize.height > display.height then
    wPosY = display.height - bSize.height
  end
  if wPosX > display.width then
    wPosX = wPosX - bSize.width / 2 - sSize.width
  elseif wPosX < display.width then
    wPosX = wPosX + bSize.width / 2 + sSize.width
  end
  newPos = self:getUINode():convertToNodeSpace(ccp(wPosX, wPosY))
  worldPos = self:getUINode():convertToWorldSpace(ccp(bx, by))
  if wPosX > worldPos.x + bSize.width then
    newPos.x = newPos.x - bSize.width - sSize.width
  end
  PopItemDetailView:setPosition(ccp(newPos.x, newPos.y))
  self.m_oldSelectItem = self.m_sItem
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
end
function CShowLifeSkillDetail_drug:OnBtn_Close(...)
  self:CloseSelf()
end
function CShowLifeSkillDetail_drug:Clear()
  if self.m_CallBackFunc then
    self.m_CallBackFunc()
    self.m_CallBackFunc = nil
  end
end
