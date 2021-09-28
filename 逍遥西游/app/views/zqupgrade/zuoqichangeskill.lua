function ShowZuoqiChangeSkillDlg(zqId, oldSkillId)
  local viewObj = CZuoqiChangeSkill.new(zqId, oldSkillId)
  getCurSceneView():addSubView({
    subView = viewObj,
    zOrder = MainUISceneZOrder.popView
  })
end
CZuoqiChangeSkill = class("CZuoqiChangeSkill", CcsSubView)
function CZuoqiChangeSkill:ctor(zqId, oldSkillId)
  self.m_ZqId = zqId
  self.m_OldSkillId = oldSkillId
  CZuoqiChangeSkill.super.ctor(self, "views/zuoqi_skill_select.json", {isAutoCenter = true, opacityBg = 100})
  self.title_skill = self:getNode("title_skill")
  self.skilldesc = self:getNode("skilldesc")
  self.skillfunc = self:getNode("skillfunc")
  self.skilltip = self:getNode("skilltip")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_upgrade = {
      listener = handler(self, self.OnBtn_ChangeSkill),
      variName = "btn_upgrade"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CurrMainType = nil
  self.m_CurrShowSkillID = nil
  self.m_SubTypeIsShow = false
  self:InitSkillList()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CZuoqiChangeSkill:InitSkillList()
  self.list_type = self:getNode("list_type")
  self.list_type:addTouchItemListenerListView(handler(self, self.ChooseTypeItem), handler(self, self.ListEventListener))
  local zuoqi = g_LocalPlayer:getObjById(self.m_ZqId)
  if zuoqi == nil then
    return
  end
  local tempDict = {
    ["物理系"] = 1,
    ["法术系"] = 2,
    ["抗性系"] = 3
  }
  local nameList = {
    "物理系",
    "法术系",
    "抗性系"
  }
  self.m_SkillTypeList = {}
  local learnSkill = {}
  local skillList = zuoqi:getProperty(PROPERTY_ZUOQI_SKILLLIST)
  if skillList ~= 0 then
    for _, skillId in pairs(skillList) do
      learnSkill[skillId] = true
    end
  end
  for skillId, skillData in pairs(data_ZuoqiSkill) do
    local attr = skillData.attr
    local mType = tempDict[attr]
    if learnSkill[skillId] ~= true then
      local subList = self.m_SkillTypeList[mType]
      if self.m_SkillTypeList[mType] == nil then
        self.m_SkillTypeList[mType] = {}
      end
      local subType = #self.m_SkillTypeList[mType] + 1
      local name = skillData.name
      self.m_SkillTypeList[mType][subType] = {
        subType,
        name,
        skillId
      }
    end
  end
  for index, _ in pairs(nameList) do
    local name = nameList[index]
    local mainTypeItem = CMainTypeListItem.new(index, name)
    self.list_type:pushBackCustomItem(mainTypeItem)
  end
  self:ShowSkillInfo(1, 1)
  self:ShowSubType(0, 1)
end
function CZuoqiChangeSkill:ShowSkillInfo(mType, subType)
  self.m_CurrShowSkillID = self:GetSkillID(mType, subType)
  self:SetSkillView(self.m_CurrShowSkillID)
end
function CZuoqiChangeSkill:HideAllSubType()
  for index = self.list_type:getCount() - 1, 0, -1 do
    local item = self.list_type:getItem(index)
    if iskindof(item, "CSubTypeListItem") then
      self.list_type:removeItem(index)
    end
  end
  self.m_SubTypeIsShow = false
end
function CZuoqiChangeSkill:ShowSubType(index, mainType)
  print("ShowSubType", index, mainType)
  local subTypes = self.m_SkillTypeList[mainType]
  if subTypes == nil then
    return
  end
  local temp = {}
  for subType, data in pairs(subTypes) do
    temp[#temp + 1] = {
      subType,
      data[2],
      data[3]
    }
  end
  local _sortFunc = function(a, b)
    if a == nil or b == nil then
      return false
    end
    return a[1] > b[1]
  end
  table.sort(temp, _sortFunc)
  print_lua_table(temp)
  local firstSubType, firstSubTypeItem
  for _, d in pairs(temp) do
    local subTypeItem = CSubTypeListItem.new(mainType, d[1], d[2])
    self.list_type:insertCustomItem(subTypeItem, index + 1)
    if self:GetSkillID(mainType, d[1]) == self.m_CurrShowSkillID then
      subTypeItem:setItemChoosed(true)
    end
    firstSubType = d[1]
    firstSubTypeItem = subTypeItem
  end
  self.list_type:ListViewScrollToIndex_Vertical(index + 1, 0.3)
  self.m_SubTypeIsShow = true
  return firstSubType, firstSubTypeItem
end
function CZuoqiChangeSkill:GetSkillID(mainType, subType)
  return self.m_SkillTypeList[mainType][subType][3]
end
function CZuoqiChangeSkill:ChooseTypeItem(item, index)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  if iskindof(item, "CMainTypeListItem") then
    local mainType = item:getMainType()
    if self.m_CurrMainType == mainType then
      if self.m_SubTypeIsShow then
        self:HideAllSubType()
      else
        self:ShowSubType(index, mainType)
      end
    else
      self:HideAllSubType()
      local insertIndex
      for i = 0, self.list_type:getCount() - 1 do
        local tempItem = self.list_type:getItem(i)
        if iskindof(tempItem, "CMainTypeListItem") and tempItem:getMainType() == mainType then
          insertIndex = i
          break
        end
      end
      if insertIndex ~= nil then
        local firstSubType, firstSubTypeItem = self:ShowSubType(insertIndex, mainType)
        self.m_CurrMainType = mainType
        if firstSubType ~= nil then
          firstSubTypeItem:setItemChoosed(true)
          self:ShowSkillInfo(mainType, firstSubType)
        end
      end
    end
  elseif iskindof(item, "CSubTypeListItem") then
    for index = self.list_type:getCount() - 1, 0, -1 do
      local tempItem = self.list_type:getItem(index)
      if iskindof(tempItem, "CSubTypeListItem") then
        if tempItem ~= item then
          tempItem:setItemChoosed(false)
        else
          tempItem:setItemChoosed(true)
        end
      end
    end
    local mainType = item:getMainType()
    local subType = item:getSubType()
    self:ShowSkillInfo(mainType, subType)
  end
end
function CZuoqiChangeSkill:ListEventListener(item, index, listObj, status)
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
function CZuoqiChangeSkill:SetSkillView(newSkillId)
  local zqId = self.m_ZqId
  self.m_CurSelSkill = newSkillId
  local skillData = data_ZuoqiSkill[self.m_CurSelSkill]
  self.title_skill:setText(skillData.name)
  self.skilldesc:setText(skillData.desc)
  self.skilltip:setText(skillData.tip)
  local desc = ""
  local info = g_LocalPlayer:getZQSkillData(zqId, self.m_CurSelSkill)
  for _, proName in ipairs(ZQSKILL_ADDPRO_DESC_ORDERDICT) do
    local value = info[proName]
    local tableKey = ZQ_ROLEPRO_2_SKILL[proName]
    local skillTable = data_ZuoqiSkill[self.m_CurSelSkill]
    if value ~= nil and skillTable and tableKey and skillTable[tableKey] and skillTable[tableKey] > 0 then
      local d = ZQSKILL_ADDPRO_DESC_DICT[proName] or ""
      if proName == PROPERTY_KXIXUE then
        desc = string.format("%s%s%d\n", desc, d, math.abs(value))
      else
        desc = string.format("%s%s%s%%\n", desc, d, Value2Str(math.abs(value) * 100, 1))
      end
    end
  end
  self.skillfunc:setText(desc)
  self:SetSkillPrice()
end
function CZuoqiChangeSkill:SetSkillPrice()
  local zuoqi = g_LocalPlayer:getObjById(self.m_ZqId)
  if zuoqi == nil then
    return
  end
  if self.m_CoinImg == nil then
    local x, y = self:getNode("box_coin"):getPosition()
    local z = self:getNode("box_coin"):getZOrder()
    local size = self:getNode("box_coin"):getSize()
    self:getNode("box_coin"):setTouchEnabled(false)
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_CoinImg = tempImg
  end
  local base = data_Variables.ZuoqiChangeSkillBaseCost or 100000
  local cost = data_Variables.ZuoqiChangeSkillCost or 100
  local skillExp = zuoqi:getProperty(PROPERTY_ZUOQI_SKILLPVALUE)
  local dianhuaFlag = zuoqi:getProperty(PROPERTY_ZUOQI_DIANHUA)
  if dianhuaFlag == 1 then
    skillExp = skillExp + CalculateZuoqiSkillPValueLimit()
  end
  local price = skillExp * cost + base
  self:getNode("txt_coin"):setText(string.format("%d", price))
  if price > g_LocalPlayer:getCoin() then
    self:getNode("txt_coin"):setColor(VIEW_DEF_WARNING_COLOR)
  else
    self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  end
end
function CZuoqiChangeSkill:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CZuoqiChangeSkill:OnBtn_ChangeSkill(btnObj, touchType)
  local zqId = self.m_ZqId
  local oldId = self.m_OldSkillId
  local oldSkillData = data_ZuoqiSkill[oldId]
  local newId = self.m_CurSelSkill
  local newSkillData = data_ZuoqiSkill[newId]
  if oldSkillData == nil or newSkillData == nil then
    return
  end
  local tempPop = CPopWarning.new({
    title = "提示",
    text = string.format("你确定要将#<Y>%s#技能更换为#<Y>%s#吗?(更换技能后，坐骑技能熟练度保持不变)", oldSkillData.name, newSkillData.name),
    confirmFunc = handler(self, self.ConfirmChangeSkill),
    confirmText = "确定",
    cancelText = "取消",
    align = CRichText_AlignType_Left
  })
  tempPop:ShowCloseBtn(false)
end
function CZuoqiChangeSkill:ConfirmChangeSkill()
  local zqId = self.m_ZqId
  local oldId = self.m_OldSkillId
  local oldSkillData = data_ZuoqiSkill[oldId]
  local newId = self.m_CurSelSkill
  local newSkillData = data_ZuoqiSkill[newId]
  if oldSkillData == nil or newSkillData == nil then
    return
  end
  netsend.netbaseptc.requestZuoqiChangeSkill(zqId, oldId, newId)
end
function CZuoqiChangeSkill:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:SetSkillPrice()
  elseif msgSID == MsgID_ZuoqiUpdate then
    local param = arg[1]
    if self.m_ZqId == param.zuoqiId then
      local proTable = param.pro
      if proTable[PROPERTY_ZUOQI_SKILLLIST] ~= nil then
        self:CloseSelf()
      end
    end
  end
end
function CZuoqiChangeSkill:Clear()
end
