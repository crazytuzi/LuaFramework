CCreateZhuangbei = class("CCreateZhuangbei", CcsSubView)
g_CreateZhuangbeiView = nil
function ResetCreateZhuangbei(playActionFlag)
  if g_CreateZhuangbeiView then
    g_CreateZhuangbeiView.btn_upgrade:setTouchEnabled(true)
    if playActionFlag == true then
      g_CreateZhuangbeiView:SetUpgradeAction()
    end
  end
end
function CCreateZhuangbei:ctor(para)
  CCreateZhuangbei.super.ctor(self, "views/createzhuangbei.json", {isAutoCenter = true, opacityBg = 100})
  para = para or {}
  self.m_CloseCallBackFunc = para.closeCallBack
  self.m_ForRoleId = para.forRoleId or g_LocalPlayer:getMainHeroId()
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Closed),
      variName = "btn_close"
    },
    btn_upgrade = {
      listener = handler(self, self.Btn_Upgrade),
      variName = "btn_upgrade"
    },
    btn_help = {
      listener = handler(self, self.Btn_Help),
      variName = "btn_help"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("btn_gaoji"):setEnabled(false)
  self:getNode("btn_xianqi"):setEnabled(false)
  self:InitTypeList()
  self:InitZBItemList()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_MoveScene)
  self:SetPara(para)
  self:SetEqptLargeType(self.m_LargeType)
  self:SetAttrTips()
  local index = self:GetTypeListSelectedIndex()
  self:TypeListScrollToIndex(index)
  g_CreateZhuangbeiView = self
end
function CCreateZhuangbei:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("coinBg"), "rescoin")
end
function CCreateZhuangbei:SetPara(para)
  local oldLargeType = self.m_LargeType
  local oldRace = self.m_Race
  local oldGender = self.m_Gender
  local oldMidType = self.m_MidType
  local oldProType = self.m_ProType
  para = para or {}
  local initLargeType = para.InitLargeType
  local initRace = para.InitRace
  local initGender = para.InitGender
  local initMidType = para.InitMidType
  local initProType = para.InitProType
  local initItemType = para.InitItemType
  if initItemType ~= nil then
    local tempItemIns = CEqptData.new(nil, nil, initItemType)
    initLargeType = tempItemIns:getType()
    local hkind = tempItemIns:getProperty(ITEM_PRO_EQPT_HKIND)
    initGender = tempItemIns:getProperty(ITEM_PRO_EQPT_SEX)
    if hkind == 0 or hkind == nil then
      hkind = {0}
    end
    if #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO then
      initRace = RACE_REN
    elseif #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI then
      initRace = RACE_GUI
    elseif #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN then
      initRace = RACE_REN
    elseif #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO then
      initRace = RACE_MO
    elseif #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN then
      initRace = RACE_XIAN
    else
      local tempHeroType = hkind[1]
      local roleData = data_getRoleData(tempHeroType)
      initRace = roleData.RACE or RACE_REN
      initGender = roleData.GENDER or HERO_MALE
    end
    if initRace == nil or initRace == 0 then
      initRace = RACE_REN
    end
    if initGender == nil or initGender == 0 then
      initGender = HERO_MALE
    end
    initMidType = EPQT_TYPE_2_EQPT_POS[tempItemIns:getProperty(ITEM_PRO_EQPT_TYPE)]
    initProType = tempItemIns:getProperty(ITEM_PRO_EQPT_PROTYPE)
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local mainHeroType = mainHero:getTypeId()
  local mySex = data_getRoleData(mainHeroType).GENDER or HERO_MALE
  local myRace = data_getRoleData(mainHeroType).RACE or RACE_REN
  self.m_LargeType = initLargeType or ITEM_LARGE_TYPE_SENIOREQPT
  self.m_Race = initRace or myRace
  self.m_Gender = initGender or mySex
  self.m_MidType = initMidType or ITEM_DEF_EQPT_POS_WUQI
  if self.m_LargeType == ITEM_LARGE_TYPE_XIANQI and self.m_MidType > ITEM_DEF_EQPT_POS_XIANGLIAN then
    self.m_MidType = ITEM_DEF_EQPT_POS_WUQI
  end
  self.m_ProType = initProType or ITEM_DEF_EQPT_PROTYPE_LingXing
  if self.m_LargeType ~= oldLargeType then
    self:SetLargeItem()
  end
  if self.m_LargeType ~= oldLargeType or self.m_Race ~= oldRace or self.m_Gender ~= oldGender or self.m_MidType ~= oldMidType or self.m_ShowSmallItemFlag == false then
    self:ShowSmallItem()
    self:SelectSmallItem()
  end
  if self.m_LargeType ~= oldLargeType or self.m_Race ~= oldRace or self.m_Gender ~= oldGender or self.m_MidType ~= oldMidType then
    self:SetZBItemList()
  end
  if self.m_LargeType ~= oldLargeType or self.m_Race ~= oldRace or self.m_Gender ~= oldGender or self.m_MidType ~= oldMidType or self.m_ProType ~= oldProType then
    self:SelectZBItem()
    self:SetCreateBoard()
  end
end
function CCreateZhuangbei:TypeListScrollToIndex(index)
  self.list_type:refreshView()
  local cnt = self.list_type:getCount()
  local h = self.list_type:getContentSize().height
  local ih = self.list_type:getInnerContainerSize().height
  if h < ih then
    local y = (1 - (index + 0.5) / cnt) * ih - h / 2
    local percent = (0.5 - y / (ih - h)) * 100
    percent = math.max(percent, 0)
    percent = math.min(percent, 100)
    self.list_type:scrollToPercentVertical(percent, 0.3, false)
  end
end
function CCreateZhuangbei:InitTypeList()
  self.list_type = self:getNode("list_type")
  self.list_type:addTouchItemListenerListView(handler(self, self.ChooseTypeItem), handler(self, self.ListEventListener))
  self.m_LargeItemList = {}
  for _, index in ipairs({ITEM_LARGE_TYPE_XIANQI, ITEM_LARGE_TYPE_SENIOREQPT}) do
    local tempItem = CMainTypeListItem.new(index, "")
    tempItem:retain()
    self.m_LargeItemList[#self.m_LargeItemList + 1] = tempItem
  end
  self.m_SmallItemList = {}
  for _, data in ipairs({
    {ITEM_DEF_EQPT_POS_WUQI, "武器"},
    {ITEM_DEF_EQPT_POS_TOUKUI, "头盔"},
    {ITEM_DEF_EQPT_POS_YIFU, "衣服"},
    {ITEM_DEF_EQPT_POS_XIEZI, "鞋子"},
    {ITEM_DEF_EQPT_POS_XIANGLIAN, "项链"},
    {ITEM_DEF_EQPT_POS_YAODAI, "腰带"},
    {ITEM_DEF_EQPT_POS_GUANJIAN, "挂件"},
    {ITEM_DEF_EQPT_POS_MIANJU, "面具"},
    {ITEM_DEF_EQPT_POS_PIFENG, "披风"}
  }) do
    local tempItem = CSubTypeListItem.new(nil, data[1], data[2])
    tempItem:retain()
    self.m_SmallItemList[#self.m_SmallItemList + 1] = tempItem
  end
  self.m_ShowSmallItemFlag = false
end
function CCreateZhuangbei:SetLargeItem()
  self.list_type:removeAllItems()
  for _, item in ipairs(self.m_LargeItemList) do
    local mType = item:getMainType()
    if mType == ITEM_LARGE_TYPE_SENIOREQPT then
      item:resetItemTxt("高级装备")
    elseif mType == ITEM_LARGE_TYPE_XIANQI then
      item:resetItemTxt("仙器")
    end
    self.list_type:pushBackCustomItem(item)
  end
  self.m_ShowSmallItemFlag = false
end
function CCreateZhuangbei:ClearSmallItem()
  if not self.m_ShowSmallItemFlag then
    return
  end
  for index = self.list_type:getCount() - 1, 0, -1 do
    local item = self.list_type:getItem(index)
    if iskindof(item, "CSubTypeListItem") then
      self.list_type:removeItem(index)
    end
  end
  self.m_ShowSmallItemFlag = false
end
function CCreateZhuangbei:ShowSmallItem()
  self:ClearSmallItem()
  local num
  local index = 0
  if self.m_LargeType == ITEM_LARGE_TYPE_SENIOREQPT then
    index = 2
    num = 9
  elseif self.m_LargeType == ITEM_LARGE_TYPE_XIANQI then
    index = 1
    num = 5
  end
  for i = num, 1, -1 do
    local item = self.m_SmallItemList[i]
    self.list_type:insertCustomItem(item, index)
    item:setItemChoosed(false)
    if item.m_BgChoosed then
      item.m_BgChoosed:setScale(1)
    end
    if item.m_BgNormal then
      item.m_BgNormal:setScale(1)
    end
  end
  self:TypeListScrollToIndex(index + num)
  self.m_ShowSmallItemFlag = true
end
function CCreateZhuangbei:GetTypeListSelectedIndex()
  local index = 0
  if self.m_LargeType == ITEM_LARGE_TYPE_SENIOREQPT then
    index = 2
  elseif self.m_LargeType == ITEM_LARGE_TYPE_XIANQI then
    index = 1
  end
  for _, item in pairs(self.m_SmallItemList) do
    local subType = item:getSubType()
    if subType == self.m_MidType then
      return index
    else
      index = index + 1
    end
  end
  return 0
end
function CCreateZhuangbei:SelectSmallItem()
  for _, item in pairs(self.m_SmallItemList) do
    local subType = item:getSubType()
    item:setItemChoosed(subType == self.m_MidType)
  end
end
function CCreateZhuangbei:ChooseTypeItem(item, index)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  if iskindof(item, "CMainTypeListItem") then
    local mainType = item:getMainType()
    if self.m_LargeType == mainType then
      if self.m_ShowSmallItemFlag == false then
        self:SetEqptLargeType(mainType)
      else
        self:ClearSmallItem()
      end
    else
      self:SetEqptLargeType(mainType)
    end
  elseif iskindof(item, "CSubTypeListItem") then
    local subType = item:getSubType()
    self:SetPara({
      InitLargeType = self.m_LargeType,
      InitRace = self.m_Race,
      InitGender = self.m_Gender,
      InitMidType = subType,
      InitProType = self.m_ProType
    })
  end
end
function CCreateZhuangbei:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if item then
      item:setTouchStatus(true)
      self.m_TouchStartItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartItem then
      self.m_TouchStartItem:setTouchStatus(false)
      self.m_TouchStartItem = nil
    end
    if item then
      item:setTouchStatus(false)
    end
  end
end
function CCreateZhuangbei:InitZBItemList()
  self.list_item = self:getNode("list_item")
  self.list_item:addTouchItemListenerListView(handler(self, self.ChooseZBItem))
end
function CCreateZhuangbei:SetZBItemList()
  local itemTypeList = self:CetZBItemTypeIdList()
  self.list_item:removeAllItems()
  for _, itemTypeId in ipairs(itemTypeList) do
    local tempZB = COneZhuangbei.new(itemTypeId, self.m_ForRoleId)
    self.list_item:pushBackCustomItem(tempZB:getUINode())
  end
end
function CCreateZhuangbei:SelectZBItem()
  local selectedFlag = false
  for index = self.list_item:getCount() - 1, 0, -1 do
    local item = self.list_item:getItem(index)
    local tempProType = item.m_UIViewParent:GetZBItemProType()
    if tempProType == self.m_ProType then
      item.m_UIViewParent:SetZBItemChoosed(true)
      selectedFlag = true
    else
      item.m_UIViewParent:SetZBItemChoosed(false)
    end
  end
  if selectedFlag ~= true then
    local item = self.list_item:getItem(0)
    if item ~= nil then
      local tempProType = item.m_UIViewParent:GetZBItemProType()
      item.m_UIViewParent:SetZBItemChoosed(true)
      self.m_ProType = tempProType
    end
  end
end
function CCreateZhuangbei:ChooseZBItem(item, index)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  local tempProType = item.m_UIViewParent:GetZBItemProType()
  self:SetPara({
    InitLargeType = self.m_LargeType,
    InitRace = self.m_Race,
    InitGender = self.m_Gender,
    InitMidType = self.m_MidType,
    InitProType = tempProType
  })
end
function CCreateZhuangbei:CetZBItemTypeIdList()
  local itemData = {}
  local itemTypeList = {}
  if self.m_LargeType == ITEM_LARGE_TYPE_SENIOREQPT then
    if self.m_MidType == ITEM_DEF_EQPT_POS_WUQI then
      itemData = data_SeniorWeapon
    elseif self.m_MidType == ITEM_DEF_EQPT_POS_TOUKUI then
      itemData = data_SeniorHat
    elseif self.m_MidType == ITEM_DEF_EQPT_POS_YIFU then
      itemData = data_SeniorCloth
    elseif self.m_MidType == ITEM_DEF_EQPT_POS_XIEZI then
      itemData = data_SeniorShoes
    elseif self.m_MidType == ITEM_DEF_EQPT_POS_XIANGLIAN then
      itemData = data_SeniorNecklace
    elseif self.m_MidType == ITEM_DEF_EQPT_POS_YAODAI or self.m_MidType == ITEM_DEF_EQPT_POS_GUANJIAN or self.m_MidType == ITEM_DEF_EQPT_POS_MIANJU or self.m_MidType == ITEM_DEF_EQPT_POS_PIFENG then
      itemData = data_SeniorDecoration
    end
  elseif self.m_LargeType == ITEM_LARGE_TYPE_XIANQI then
    if self.m_MidType == ITEM_DEF_EQPT_POS_WUQI then
      itemData = data_XqWeapon
    elseif self.m_MidType == ITEM_DEF_EQPT_POS_TOUKUI then
      itemData = data_XqHat
    elseif self.m_MidType == ITEM_DEF_EQPT_POS_YIFU then
      itemData = data_XqCloth
    elseif self.m_MidType == ITEM_DEF_EQPT_POS_XIEZI then
      itemData = data_XqShoes
    elseif self.m_MidType == ITEM_DEF_EQPT_POS_XIANGLIAN then
      itemData = data_XqNecklace
    end
  end
  for tempTypeId, tempData in pairs(itemData) do
    local weaponType = tempData.weaponType or 0
    if EPQT_TYPE_2_EQPT_POS[weaponType] == self.m_MidType then
      local sex = tempData.sex or 0
      local race = 0
      if not tempData.hkind then
        local hkind = {0}
      end
      if hkind == 0 then
        hkind = {0}
      end
      if #hkind == 1 then
        if hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO then
          race = 0
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI then
          race = RACE_GUI
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN then
          race = RACE_REN
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN then
          race = RACE_XIAN
        elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO then
          race = RACE_MO
        end
      else
        sex = data_getRoleData(hkind[1]).GENDER
        race = data_getRoleData(hkind[1]).RACE
      end
      local lv = tempData.lv
      if (sex == HERO_ANY or sex == self.m_Gender) and lv == 1 and (race == ITEM_DEF_EQPT_HKIND_ALLHERO or race == self.m_Race) then
        local tempDict = {
          [ITEM_DEF_EQPT_WEAPON_YAODAI] = true,
          [ITEM_DEF_EQPT_WEAPON_GUANJIAN] = true,
          [ITEM_DEF_EQPT_WEAPON_MIANJU] = true,
          [ITEM_DEF_EQPT_WEAPON_PIFENG] = true
        }
        local tempData = data_SeniorDecoration[tempTypeId] or {}
        local weaponType = tempData.weaponType or 0
        local proType = not tempData.proType and 0
        local notAddFlag = false
        if tempDict[weaponType] == true then
          if self.m_Race == RACE_REN then
            if proType == ITEM_DEF_EQPT_PROTYPE_LingXing then
              notAddFlag = true
            end
          elseif self.m_Race == RACE_MO then
            if proType == ITEM_DEF_EQPT_PROTYPE_LingXing then
              notAddFlag = true
            end
          elseif self.m_Race == RACE_XIAN then
            if proType == ITEM_DEF_EQPT_PROTYPE_Gengu then
              notAddFlag = true
            end
          elseif self.m_Race == RACE_GUI and proType == ITEM_DEF_EQPT_PROTYPE_LingXing then
            notAddFlag = true
          end
        end
        if notAddFlag then
        else
          itemTypeList[#itemTypeList + 1] = tempTypeId
        end
      end
    end
  end
  function _sortFunc(itemTypeId_A, itemTypeId_B)
    if itemTypeId_A == nil or itemTypeId_B == nil then
      return false
    end
    local proType_A = math.floor(itemTypeId_A / 10) % 10
    local proType_B = math.floor(itemTypeId_B / 10) % 10
    local index_A, index_B
    local Pos_Type = math.floor(itemTypeId_A / 100000) % 10
    if Pos_Type == ITEM_DEF_EQPT_POS_YAODAI % 10 or Pos_Type == ITEM_DEF_EQPT_POS_GUANJIAN % 10 or Pos_Type == ITEM_DEF_EQPT_POS_CHIBANG % 10 or Pos_Type == ITEM_DEF_EQPT_POS_MIANJU % 10 or Pos_Type == ITEM_DEF_EQPT_POS_PIFENG % 10 then
      local addPointDict = {
        [ITEM_DEF_EQPT_PROTYPE_Gengu] = 51,
        [ITEM_DEF_EQPT_PROTYPE_LingXing] = 52,
        [ITEM_DEF_EQPT_PROTYPE_LiLiang] = 53,
        [ITEM_DEF_EQPT_PROTYPE_MinJie] = 54
      }
      index_A = addPointDict[proType_A]
      index_B = addPointDict[proType_B]
    else
      local index_Dict = {
        [ITEM_DEF_EQPT_PROTYPE_Qixue_N] = 31,
        [ITEM_DEF_EQPT_PROTYPE_Speed_N] = 32,
        [ITEM_DEF_EQPT_PROTYPE_Wuli_N] = 33,
        [ITEM_DEF_EQPT_PROTYPE_AddSpeed_S] = 41,
        [ITEM_DEF_EQPT_PROTYPE_SubSpeed_S] = 42,
        [ITEM_DEF_EQPT_PROTYPE_NO] = 999
      }
      index_A = index_Dict[proType_A]
      index_B = index_Dict[proType_B]
      local race_Index_Dict = {
        [RACE_REN] = {
          [ITEM_DEF_EQPT_PROTYPE_Gengu] = 31,
          [ITEM_DEF_EQPT_PROTYPE_MinJie] = 32,
          [ITEM_DEF_EQPT_PROTYPE_LiLiang] = 33,
          [ITEM_DEF_EQPT_PROTYPE_LingXing] = 34
        },
        [RACE_XIAN] = {
          [ITEM_DEF_EQPT_PROTYPE_LingXing] = 31,
          [ITEM_DEF_EQPT_PROTYPE_MinJie] = 32,
          [ITEM_DEF_EQPT_PROTYPE_LiLiang] = 33,
          [ITEM_DEF_EQPT_PROTYPE_Gengu] = 34
        },
        [RACE_MO] = {
          [ITEM_DEF_EQPT_PROTYPE_Gengu] = 31,
          [ITEM_DEF_EQPT_PROTYPE_MinJie] = 32,
          [ITEM_DEF_EQPT_PROTYPE_LiLiang] = 33,
          [ITEM_DEF_EQPT_PROTYPE_LingXing] = 34
        },
        [RACE_GUI] = {
          [ITEM_DEF_EQPT_PROTYPE_Gengu] = 31,
          [ITEM_DEF_EQPT_PROTYPE_MinJie] = 32,
          [ITEM_DEF_EQPT_PROTYPE_LiLiang] = 33,
          [ITEM_DEF_EQPT_PROTYPE_LingXing] = 34
        }
      }
      if race_Index_Dict[self.m_Race] ~= nil then
        if index_A == nil then
          index_A = race_Index_Dict[self.m_Race][proType_A]
        end
        if index_B == nil then
          index_B = race_Index_Dict[self.m_Race][proType_B]
        end
      end
    end
    if index_A == nil then
      index_A = 9999
    end
    if index_B == nil then
      index_B = 9999
    end
    return index_A < index_B
  end
  table.sort(itemTypeList, _sortFunc)
  return itemTypeList
end
function CCreateZhuangbei:SetCreateBoard()
  local itemTypeList = self:CetZBItemTypeIdList()
  local curItem
  for _, tempType in ipairs(itemTypeList) do
    local tempProType = math.floor(tempType / 10) % 10
    if self.m_ProType == tempProType then
      curItem = tempType
      break
    end
  end
  if curItem == nil then
    return
  end
  self.m_ShowingItemType = curItem
  self:SetCreateStuffs()
  self:SetCreateMoney()
  self.btn_upgrade:setTouchEnabled(true)
  self.m_LastClickTime = nil
  print("self.m_LastClickTime重置时间")
end
function CCreateZhuangbei:SetCreateStuffs()
  if self.m_IconList == nil then
    self.m_IconList = {}
  end
  if self.m_ShowingItemType == nil then
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local mainHeroType = mainHero:getTypeId()
  local largeType = self.m_LargeType
  local largeType = self.m_LargeType
  for i = 1, 6 do
    local tempPos = self:getNode(string.format("itempos%d", i))
    if tempPos then
      tempPos:setVisible(false)
      if tempPos._posNum ~= nil then
        tempPos._posNum:removeFromParent()
        tempPos._posNum = nil
      end
    end
  end
  for _, icon in pairs(self.m_IconList) do
    icon:removeFromParent()
  end
  self.m_IconList = {}
  local tempDict = {
    {
      self.m_ShowingItemType,
      1
    }
  }
  local jz
  if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
    jz = data_getUpgradeEquipNeedJZ(mainHeroType, 1)
  elseif largeType == ITEM_LARGE_TYPE_XIANQI then
    jz = data_getUpgradeXqNeedJZ(mainHeroType, 1)
  end
  if jz ~= nil then
    tempDict[#tempDict + 1] = {jz, 1}
  end
  local tList = data_getUpgradeItemList(self.m_ShowingItemType, 1, Eqpt_Upgrade_CreateType)
  for tType, tNum in pairs(tList) do
    tempDict[#tempDict + 1] = {tType, tNum}
  end
  for index, data in ipairs(tempDict) do
    local itemTypeId = data[1]
    local itemNeedNum = data[2]
    local pos = self:getNode(string.format("itempos%d", index))
    local icon = self:AddOneStuffIcon(index, pos, itemTypeId, itemNeedNum)
    self.m_IconList[#self.m_IconList + 1] = icon
  end
end
function CCreateZhuangbei:SetCreateMoney()
  if self.m_ShowingItemType == nil then
    return
  end
  if self.m_MoneyIcon == nil then
    local x, y = self:getNode("box_coin"):getPosition()
    local z = self:getNode("box_coin"):getZOrder()
    local size = self:getNode("box_coin"):getSize()
    self:getNode("box_coin"):setTouchEnabled(false)
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_MoneyIcon = tempImg
  end
  local needMoney = data_getUpgradeItemMoney(self.m_ShowingItemType, 1, Eqpt_Upgrade_CreateType)
  self:getNode("txt_coin"):setText(string.format("%d", needMoney))
  if needMoney > g_LocalPlayer:getCoin() then
    self:getNode("txt_coin"):setColor(VIEW_DEF_WARNING_COLOR)
  else
    self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  end
end
function CCreateZhuangbei:AddOneStuffIcon(index, pos, itemTypeId, itemNeedNum)
  local s = pos:getContentSize()
  local clickListener = handler(self, self.ShowStuffDetail)
  icon = createClickItem({
    itemID = itemTypeId,
    autoSize = nil,
    num = 0,
    LongPressTime = 0,
    clickListener = clickListener,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = true
  })
  local size = icon:getContentSize()
  icon:setPosition(ccp(-size.width / 2, -size.height / 2))
  pos:addChild(icon)
  icon.eqptupgradeItemTypePara = itemTypeId
  icon.eqptupgradeItemNeedNumPara = itemNeedNum or 1
  icon.eqptupgradeItemPosPara = index
  pos:setVisible(true)
  if index ~= 1 then
    local curNum = g_LocalPlayer:GetItemNum(itemTypeId)
    local numLabel = CCLabelTTF:create(string.format("%s/%s", curNum, itemNeedNum), ITEM_NUM_FONT, 22)
    numLabel:setAnchorPoint(ccp(1, 0))
    numLabel:setPosition(ccp(s.width / 2 - 5, -s.height / 2 + 5))
    if itemNeedNum <= curNum then
      numLabel:setColor(VIEW_DEF_PGREEN_COLOR)
    else
      numLabel:setColor(VIEW_DEF_WARNING_COLOR)
    end
    pos:addNode(numLabel)
    AutoLimitObjSize(numLabel, 70)
    pos._posNum = numLabel
  elseif self.m_ForRoleId then
    local roleIns = g_LocalPlayer:getObjById(self.m_ForRoleId)
    if roleIns then
      local tempItemIns = CEqptData.new(nil, nil, itemTypeId)
      local canUseFlag = true
      if self.m_ForRoleId == g_LocalPlayer:getMainHeroId() then
        canUseFlag = roleIns:CanAddItemWithItemIns(tempItemIns)
      else
        canUseFlag = roleIns:CanAddItemForHuobanWithItemIns(tempItemIns)
      end
      if canUseFlag ~= true then
        local topRightIcon = display.newSprite("xiyou/pic/pic_item_cannotuse.png")
        if topRightIcon then
          icon:addNode(topRightIcon)
          local size = icon:getContentSize()
          topRightIcon:setPosition(size.width - 10, size.height - 10)
        end
      end
    end
  end
  return icon
end
function CCreateZhuangbei:ShowStuffDetail(obj, t)
  self.m_PopStuffDetail = CEquipDetail.new(nil, {
    closeListener = handler(self, self.CloseStuffDetail),
    itemType = obj.eqptupgradeItemTypePara,
    eqptRoleId = self.m_ForRoleId
  })
  self:addSubView({
    subView = self.m_PopStuffDetail,
    zOrder = 9999
  })
  self:SelectStuffItem(obj.eqptupgradeItemPosPara)
  local x, y = self:getNode("box_showdetail"):getPosition()
  self.m_PopStuffDetail:setPosition(ccp(x, y))
  self.m_PopStuffDetail:ShowCloseBtn()
end
function CCreateZhuangbei:SelectStuffItem(index)
  local selectImgTag = 9999
  for i = 1, 6 do
    local obj = self:getNode(string.format("itempos%d", i))
    if obj ~= nil then
      local oldImg = obj:getVirtualRenderer():getChildByTag(selectImgTag)
      if i == index then
        if oldImg == nil then
          local img = display.newSprite("xiyou/item/selecteditem.png")
          obj:getVirtualRenderer():addChild(img, 10, selectImgTag)
          local size = obj:getContentSize()
          img:setPosition(ccp(size.width / 2, size.height / 2))
        end
      elseif oldImg ~= nil then
        obj:getVirtualRenderer():removeChild(oldImg)
      end
    end
  end
end
function CCreateZhuangbei:CloseStuffDetail()
  if self.m_PopStuffDetail then
    self:SelectStuffItem()
    local tempObj = self.m_PopStuffDetail
    self.m_PopStuffDetail = nil
    tempObj:CloseSelf()
  end
end
function CCreateZhuangbei:SetEqptLargeType(itemLargeType)
  self:SetPara({
    InitLargeType = itemLargeType,
    InitRace = self.m_Race,
    InitGender = self.m_Gender,
    InitMidType = self.m_MidType,
    InitProType = self.m_ProType
  })
end
function CCreateZhuangbei:Btn_Closed(obj, objType)
  self:CloseSelf()
end
function CCreateZhuangbei:Btn_Upgrade(obj, objType)
  if self.m_ShowingItemType == nil then
    return
  end
  local warningText
  if self.m_ForRoleId then
    local roleIns = g_LocalPlayer:getObjById(self.m_ForRoleId)
    if roleIns then
      local tempItemIns = CEqptData.new(nil, nil, self.m_ShowingItemType)
      local canUseFlag = true
      if self.m_ForRoleId == g_LocalPlayer:getMainHeroId() then
        canUseFlag = roleIns:CanAddItemWithItemIns(tempItemIns)
      else
        canUseFlag = roleIns:CanAddItemForHuobanWithItemIns(tempItemIns)
      end
      if canUseFlag ~= true then
        warningText = "当前角色的属性不足以使用此装备，是否继续合成？\n"
        if self.m_ForRoleId == g_LocalPlayer:getMainHeroId() then
          local hkind = tempItemIns:getProperty(ITEM_PRO_EQPT_HKIND)
          if hkind == 0 or hkind == nil then
            hkind = {0}
          end
          local sex = tempItemIns:getProperty(ITEM_PRO_EQPT_SEX)
          if #hkind == 1 and (hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN) then
            if hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO or hkind[1] == ITEM_DEF_EQPT_HKIND_ALLPET then
              if sex == ITEM_DEF_EQPT_SEX_MALE then
                if roleIns:getProperty(PROPERTY_GENDER) ~= sex then
                  warningText = warningText .. "#<CWA>装备角色 男性角色(条件不足)#\n"
                end
              elseif sex == ITEM_DEF_EQPT_SEX_FEMALE and roleIns:getProperty(PROPERTY_GENDER) ~= sex then
                warningText = warningText .. "#<CWA>装备角色 女性角色(条件不足)#\n"
              end
            elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI then
              if sex == ITEM_DEF_EQPT_SEX_MALE then
                if roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_GUI then
                  warningText = warningText .. "#<CWA>装备角色 男性鬼族(条件不足)#\n"
                end
              elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
                if roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_GUI then
                  warningText = warningText .. "#<CWA>装备角色 女性鬼族(条件不足)#\n"
                end
              elseif roleIns:getProperty(PROPERTY_RACE) ~= RACE_GUI then
                warningText = warningText .. "#<CWA>装备角色 鬼族(条件不足)#\n"
              end
            elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO then
              if sex == ITEM_DEF_EQPT_SEX_MALE then
                if roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_MO then
                  warningText = warningText .. "#<CWA>装备角色 男性魔族(条件不足)#\n"
                end
              elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
                if roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_MO then
                  warningText = warningText .. "#<CWA>装备角色 女性魔族(条件不足)#\n"
                end
              elseif roleIns:getProperty(PROPERTY_RACE) ~= RACE_MO then
                warningText = warningText .. "#<CWA>装备角色 魔族(条件不足)#\n"
              end
            elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN then
              if sex == ITEM_DEF_EQPT_SEX_MALE then
                if roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_XIAN then
                  warningText = warningText .. "#<CWA>装备角色 男性仙族(条件不足)#\n"
                end
              elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
                if roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_XIAN then
                  warningText = warningText .. "#<CWA>装备角色 女性仙族(条件不足)#\n"
                end
              elseif roleIns:getProperty(PROPERTY_RACE) ~= RACE_XIAN then
                warningText = warningText .. "#<CWA>装备角色 仙族(条件不足)#\n"
              end
            elseif hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN then
              if sex == ITEM_DEF_EQPT_SEX_MALE then
                if roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_REN then
                  warningText = warningText .. "#<CWA>装备角色 男性人族(条件不足)#\n"
                end
              elseif sex == ITEM_DEF_EQPT_SEX_FEMALE then
                if roleIns:getProperty(PROPERTY_GENDER) ~= sex or roleIns:getProperty(PROPERTY_RACE) ~= RACE_REN then
                  warningText = warningText .. "#<CWA>装备角色 女性人族(条件不足)#\n"
                end
              elseif roleIns:getProperty(PROPERTY_RACE) ~= RACE_REN then
                warningText = warningText .. "#<CWA>装备角色 人族(条件不足)#\n"
              end
            end
          end
        end
        local nZs = tempItemIns:getProperty(ITEM_PRO_EQPT_ZSLIMIT)
        local nLv = tempItemIns:getProperty(ITEM_PRO_EQPT_LVLIMIT)
        local lvCanUseFlag = true
        if nZs > roleIns:getProperty(PROPERTY_ZHUANSHENG) then
          lvCanUseFlag = false
        elseif roleIns:getProperty(PROPERTY_ZHUANSHENG) == nZs and nLv > roleIns:getProperty(PROPERTY_ROLELEVEL) then
          lvCanUseFlag = false
        end
        if lvCanUseFlag == false then
          if nZs == 0 then
            warningText = warningText .. string.format("#<CWA>等级需求 %d级(条件不足)#\n", nLv)
          elseif nLv == 0 then
            warningText = warningText .. string.format("#<CWA>等级需求 %d转(条件不足)#\n", nZs)
          else
            warningText = warningText .. string.format("#<CWA>等级需求 %d转%d级(条件不足)#\n", nZs, nLv)
          end
        end
        local tempRoleProNameList = {
          [ITEM_PRO_EQPT_NEEDLL] = PROPERTY_OLiLiang,
          [ITEM_PRO_EQPT_NEEDMJ] = PROPERTY_OMinJie,
          [ITEM_PRO_EQPT_NEEDLX] = PROPERTY_OLingxing,
          [ITEM_PRO_EQPT_NEEDGG] = PROPERTY_OGenGu
        }
        for proName, str in pairs({
          [ITEM_PRO_EQPT_NEEDLL] = "力量要求",
          [ITEM_PRO_EQPT_NEEDMJ] = "敏捷要求",
          [ITEM_PRO_EQPT_NEEDLX] = "灵性要求",
          [ITEM_PRO_EQPT_NEEDGG] = "根骨要求"
        }) do
          local tempNum = tempItemIns:getProperty(proName)
          if tempNum > 0 and tempNum > roleIns:getProperty(tempRoleProNameList[proName]) then
            warningText = warningText .. string.format("#<CWA>%s %d(条件不足)#\n", str, tempNum)
          end
        end
      end
    end
  end
  if warningText ~= nil then
    local tempView = CPopWarning.new({
      text = warningText,
      cancelFunc = cancelFunc,
      confirmFunc = function()
        self:SendForUpgrade()
      end,
      align = CRichText_AlignType_Left
    })
    tempView:ShowCloseBtn(false)
  else
    self:SendForUpgrade()
  end
end
function CCreateZhuangbei:SendForUpgrade()
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastClickTime ~= nil then
    local delTime = 3
    if delTime > curTime - self.m_LastClickTime then
      return
    end
  end
  self.m_LastClickTime = curTime
  if self.m_ShowingItemType ~= nil then
    netsend.netitem.requestUpgradeItem(nil, nil, self.m_ShowingItemType)
    self.btn_upgrade:setTouchEnabled(false)
  end
end
function CCreateZhuangbei:Btn_Help(obj, objType)
  local title = "装备合成的说明"
  local text = ""
  if self.m_LargeType == ITEM_LARGE_TYPE_SENIOREQPT then
    text = "主角的种族和性别决定了需要的对应制造符(如人族男性主角,无论合成任何一件高级装备都需要#<G,>1级装备卷轴(男人)#)；高级装备还可炼化、强化、升级至2级高级装备。"
  elseif self.m_LargeType == ITEM_LARGE_TYPE_XIANQI then
    text = "主角的种族和性别决定了需要的对应制造符(如人族男性主角,无论合成任何一件仙器装备都需要#<G,>1级仙器卷轴(男人)#)；仙器装备还可炼化、强化、升级至2级高级装备。"
  end
  if text ~= nil then
    local temp = CPopWarning.new({
      title = title,
      text = text,
      confirmText = "确定",
      align = CRichText_AlignType_Left
    })
    temp:ShowCloseBtn(false)
    temp:OnlyShowConfirmBtn()
  end
end
function CCreateZhuangbei:Btn_Gaoji(obj, objType)
  self:SetEqptLargeType(ITEM_LARGE_TYPE_SENIOREQPT)
end
function CCreateZhuangbei:Btn_Xianqi(obj, objType)
  self:SetEqptLargeType(ITEM_LARGE_TYPE_XIANQI)
end
function CCreateZhuangbei:SetUpgradeAction()
  local plistpath = "xiyou/ani/zhuangbeiupgrade.plist"
  local times = 1
  local eff = CreateSeqAnimation(plistpath, times, nil, nil, false)
  if eff then
    local x, y = self:getNode("itempos1"):getPosition()
    eff:setPosition(ccp(x, y))
    self:addNode(eff, 999)
  end
end
function CCreateZhuangbei:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:SetCreateMoney()
  elseif msgSID == MsgID_ItemInfo_AddItem then
    self:SetCreateStuffs()
  elseif msgSID == MsgID_ItemInfo_DelItem then
    self:SetCreateStuffs()
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum then
    self:SetCreateStuffs()
  elseif msgSID == MsgID_ItemSource_Jump then
    self:CloseStuffDetail()
    local d = arg[1][1]
    for _, t in pairs(Item_Source_MoveMapList) do
      if d == t then
        self:CloseSelf()
        break
      end
    end
  end
end
function CCreateZhuangbei:Clear()
  self:CloseStuffDetail()
  if g_CreateZhuangbeiView == self then
    g_CreateZhuangbeiView = nil
  end
  for _, obj in pairs(self.m_LargeItemList) do
    obj:release()
  end
  self.m_LargeItemList = {}
  for _, obj in pairs(self.m_SmallItemList) do
    obj:release()
  end
  self.m_SmallItemList = {}
  if self.m_CloseCallBackFunc then
    self.m_CloseCallBackFunc()
  end
end
COneZhuangbei = class("COneZhuangbei", CcsSubView)
function COneZhuangbei:ctor(itemTypeId, forRoleId)
  COneZhuangbei.super.ctor(self, "views/createonezb.json")
  self.m_ItemTypeId = itemTypeId
  self.m_OneZBForRoleId = forRoleId
  self.m_ItemProType = math.floor(itemTypeId / 10) % 10
  self:SetZBItemData(itemTypeId)
end
function COneZhuangbei:SetZBItemData()
  local title1Dict = {
    [ITEM_DEF_EQPT_PROTYPE_NO] = "",
    [ITEM_DEF_EQPT_PROTYPE_LingXing] = "灵性要求",
    [ITEM_DEF_EQPT_PROTYPE_LiLiang] = "力量要求",
    [ITEM_DEF_EQPT_PROTYPE_Gengu] = "根骨要求",
    [ITEM_DEF_EQPT_PROTYPE_MinJie] = "敏捷要求",
    [ITEM_DEF_EQPT_PROTYPE_Qixue_N] = "加强气血",
    [ITEM_DEF_EQPT_PROTYPE_Speed_N] = "加倍道兼行度",
    [ITEM_DEF_EQPT_PROTYPE_Wuli_N] = "加强物理",
    [ITEM_DEF_EQPT_PROTYPE_AddSpeed_S] = "加倍道兼行度",
    [ITEM_DEF_EQPT_PROTYPE_SubSpeed_S] = "加强负速度"
  }
  self:getNode("title1"):setText(title1Dict[self.m_ItemProType] or "")
  self:getNode("title2"):setText(self:GetDes())
  local pos = self:getNode("itembg")
  local s = pos:getContentSize()
  icon = createClickItem({
    itemID = self.m_ItemTypeId,
    autoSize = nil,
    num = 0,
    LongPressTime = 0,
    clickListener = function()
    end,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = true
  })
  local size = icon:getContentSize()
  icon:setPosition(ccp(-size.width / 2, -size.height / 2))
  pos:addChild(icon)
  pos:setVisible(true)
  if self.m_OneZBForRoleId then
    local roleIns = g_LocalPlayer:getObjById(self.m_OneZBForRoleId)
    if roleIns then
      local tempItemIns = CEqptData.new(nil, nil, self.m_ItemTypeId)
      local canUseFlag = true
      if self.m_OneZBForRoleId == g_LocalPlayer:getMainHeroId() then
        canUseFlag = roleIns:CanAddItemWithItemIns(tempItemIns)
      else
        canUseFlag = roleIns:CanAddItemForHuobanWithItemIns(tempItemIns)
      end
      if canUseFlag ~= true then
        local topRightIcon = display.newSprite("xiyou/pic/pic_item_cannotuse.png")
        if topRightIcon then
          icon:addNode(topRightIcon)
          local size = icon:getContentSize()
          topRightIcon:setPosition(size.width - 10, size.height - 10)
        end
      end
    end
  end
end
function COneZhuangbei:GetDes()
  local tempItemIns = CEqptData.new(nil, nil, self.m_ItemTypeId)
  local weaponType = tempItemIns:getProperty(ITEM_PRO_EQPT_TYPE)
  if weaponType == ITEM_DEF_EQPT_WEAPON_YAODAI or weaponType == ITEM_DEF_EQPT_WEAPON_GUANJIAN or weaponType == ITEM_DEF_EQPT_WEAPON_MIANJU or weaponType == ITEM_DEF_EQPT_WEAPON_PIFENG then
    return ""
  end
  local hkind = tempItemIns:getProperty(ITEM_PRO_EQPT_HKIND)
  if hkind == 0 or hkind == nil then
    hkind = {0}
  end
  local race
  if #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLHERO then
    race = RACE_REN
  elseif #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLGUI then
    race = RACE_GUI
  elseif #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLREN then
    race = RACE_REN
  elseif #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLMO then
    race = RACE_MO
  elseif #hkind == 1 and hkind[1] == ITEM_DEF_EQPT_HKIND_ALLXIAN then
    race = RACE_XIAN
  else
    race = data_getRoleData(hkind[1]).RACE or RACE_REN
  end
  if race == 0 or race == nil then
    race = RACE_REN
  end
  local title2Dict = {
    [ITEM_DEF_EQPT_PROTYPE_NO] = "",
    [ITEM_DEF_EQPT_PROTYPE_LiLiang] = "强物理",
    [ITEM_DEF_EQPT_PROTYPE_Qixue_N] = "加强气血属性",
    [ITEM_DEF_EQPT_PROTYPE_Speed_N] = "加倍道兼行度属性",
    [ITEM_DEF_EQPT_PROTYPE_Wuli_N] = "加强物理属性",
    [ITEM_DEF_EQPT_PROTYPE_AddSpeed_S] = "加倍道兼行度属性",
    [ITEM_DEF_EQPT_PROTYPE_SubSpeed_S] = "加强负速度属性"
  }
  if title2Dict[self.m_ItemProType] then
    return title2Dict[self.m_ItemProType]
  end
  if self.m_ItemProType == ITEM_DEF_EQPT_PROTYPE_LingXing then
    if race == RACE_XIAN then
      return "强仙法(高)"
    end
  elseif self.m_ItemProType == ITEM_DEF_EQPT_PROTYPE_Gengu then
    if race == RACE_REN then
      return "强人法(高)"
    elseif race == RACE_GUI then
      return "强鬼法(高)"
    elseif race == RACE_MO then
      return "强魔法(高)"
    end
  elseif self.m_ItemProType == ITEM_DEF_EQPT_PROTYPE_MinJie then
    if race == RACE_XIAN then
      return "强仙法(中)"
    elseif race == RACE_REN then
      return "强人法(中)"
    elseif race == RACE_GUI then
      return "强鬼法(中)"
    elseif race == RACE_MO then
      return "强魔法(中)"
    end
  end
  return ""
end
function COneZhuangbei:SetZBItemChoosed(flag)
  local bg = self:getNode("bg")
  if flag then
    if bg._SelectObjList then
      return
    else
      local bgSize = bg:getSize()
      local temp1 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp2 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp3 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp4 = display.newSprite("views/pic/pic_selectcorner.png")
      local del = 5
      bg:addNode(temp1)
      temp1:setPosition(ccp(0 - del, 0 - del))
      temp1:setAnchorPoint(ccp(0, 1))
      temp1:setScaleY(-1)
      bg:addNode(temp2)
      temp2:setPosition(ccp(0 - del, bgSize.height + del))
      temp2:setAnchorPoint(ccp(0, 1))
      bg:addNode(temp3)
      temp3:setPosition(ccp(bgSize.width + del, 0 - del))
      temp3:setAnchorPoint(ccp(0, 1))
      temp3:setScaleX(-1)
      temp3:setScaleY(-1)
      bg:addNode(temp4)
      temp4:setPosition(ccp(bgSize.width + del, bgSize.height + del))
      temp4:setAnchorPoint(ccp(0, 1))
      temp4:setScaleX(-1)
      bg._SelectObjList = {
        temp1,
        temp2,
        temp3,
        temp4
      }
    end
  elseif bg._SelectObjList then
    for _, obj in pairs(bg._SelectObjList) do
      obj:removeFromParent()
    end
    bg._SelectObjList = nil
  end
end
function COneZhuangbei:GetZBItemProType()
  return self.m_ItemProType
end
function COneZhuangbei:Clear()
end
