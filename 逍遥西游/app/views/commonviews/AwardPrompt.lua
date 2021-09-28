local showItemDeltaTime = 0.5
local itemFlyUpTime = 0.3
local itemShowTime = 2
local DEF_UpMaxNum = 5
local CAwardPromptItem = class("CAwardPromptItem", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CAwardPromptItem:ctor(keyId, clearListener)
  self:setNodeEventEnabled(true)
  self.m_KeyId = keyId
  self.m_ClearListener = clearListener
  self.m_FlyTimes = 0
  self.m_OrgPos = {}
  self.m_FlyUpAction = nil
  self.m_EndPosIndex = 0
end
function CAwardPromptItem:Init(awardData, x, y)
  self:setPosition(ccp(x, y))
  self.m_OrgPos = {x, y}
  local minWith = 300
  local minHeight = 40
  local txtOffx = 40
  local bg = CCScale9Sprite:create("xiyou/pic/pic_award_prompt_bg.png", CCRect(0, 0, minWith, minHeight), CCRect(50, 0, 200, 40))
  self:addNode(bg, 5)
  local displaySound = false
  local txt = ""
  if type(awardData) == "string" then
    txt = awardData
  elseif type(awardData[1]) == "string" then
    txt = awardData[1]
  else
    displaySound = true
    txt = "获得 "
    if awardData[3] == true then
      txt = "召唤兽 获得 "
      local mainHeroIns = g_LocalPlayer:getObjById(1)
      if mainHeroIns then
        local tempPetId = mainHeroIns:getProperty(PROPERTY_PETID)
        local petObj = g_LocalPlayer:getObjById(tempPetId)
        if petObj then
          local petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
          local petZs = petObj:getProperty(PROPERTY_ZHUANSHENG)
          local name = petObj:getProperty(PROPERTY_NAME)
          if name ~= nil then
            txt = name .. " 获得"
          end
          local heroLv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
          local heroZs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
          if petZs > heroZs or heroZs == petZs and petLv >= heroLv + PETLV_HEROLV_MAXDEL then
            return false, displaySound
          end
        end
      end
    end
    local t = awardData[1]
    if t == RESTYPE_GOLD then
      txt = string.format("%s%d#<IR2>#", txt, awardData[2])
    elseif t == RESTYPE_COIN then
      txt = string.format("%s%d#<IR1>#", txt, awardData[2])
      self:ShowObjFlyToBag(RESTYPE_COIN, awardData[2])
    elseif t == RESTYPE_EXP then
      txt = string.format("%s%d#<IR3>#", txt, awardData[2])
    elseif t == RESTYPE_TILI then
      txt = string.format("%s%d#<IR5>#", txt, awardData[2])
    elseif t == RESTYPE_Honour then
      txt = string.format("%s%d#<IR6>#", txt, awardData[2])
    elseif t == RESTYPE_SILVER then
      txt = string.format("%s%d#<IR7>#", txt, awardData[2])
    elseif t == RESTYPE_BPCONSTRUCT then
      txt = string.format("%s%d#<IR8>#", txt, awardData[2])
    elseif t == RESTYPE_XIAYI then
      txt = string.format("%s%d#<IR11>#", txt, awardData[2])
    else
      local objId, num
      if #awardData == 2 then
        objId, num = unpack(awardData, 1, 2)
      else
        for k, v in pairs(awardData) do
          if k ~= "VType" then
            objId = k
            num = v
            break
          end
        end
      end
      if objId ~= nil and num ~= nil then
        local name = data_getItemName(objId)
        txt = string.format("#<II%d>#%s#<CI:%d>%sx%d#", objId, txt, objId, name, num)
        self:ShowObjFlyToBag(objId, num)
      else
        return false, displaySound
      end
    end
  end
  local text = RichText.new({
    width = display.width,
    verticalSpace = 0,
    color = ccc3(255, 255, 255),
    font = KANG_TTF_FONT,
    fontSize = 22,
    align = CRichText_AlignType_Center
  })
  self:addChild(text, 10)
  text:addRichText(txt)
  print("===>>> txt:", txt)
  local txtSize = text:getRichTextSize()
  text:setPosition(ccp(-txtSize.width / 2, -txtSize.height / 2))
  self.m_bg = bg
  self.m_txt = txt
  local realSize = text:getRealRichTextSize()
  local w = math.max(minWith, realSize.width + txtOffx * 2)
  local h = minHeight
  bg:setContentSize(CCSize(w, h))
  local bgSize = bg:getContentSize()
  self:setSize(CCSize(1, bgSize.height + 2))
  return true, displaySound
end
function CAwardPromptItem:ShowObjFlyToBag(resType, num)
  do return end
  local item
  if resType == RESTYPE_COIN then
    item = createClickResItem({
      resID = RESTYPE_EXP,
      num = num,
      autoSize = nil,
      clickListener = nil,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = nil,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
  else
    item = createClickItem(resType, nil, num)
  end
  if item == nil then
    return
  end
  addNodeToTopLayer(item, TopLayerZ_NotifyAwardMsg + 1)
  local flyToPos
  flyToPos = ccp(display.width - 60, 150)
  flyToPos.x = flyToPos.x - item:getSize().width / 2
  flyToPos.y = flyToPos.y - item:getSize().height / 2
  item:setPosition(ccp(display.width / 2, flyToPos.y - 20))
  item:runAction(transition.sequence({
    CCDelayTime:create(0.4),
    CCMoveTo:create(1, flyToPos),
    CCDelayTime:create(0.1),
    CCCallFunc:create(function()
      item:removeSelf()
    end)
  }))
end
function CAwardPromptItem:setStartShow()
  self:runAction(transition.sequence({
    CCDelayTime:create(itemShowTime),
    CCCallFunc:create(function()
      self:stopAllActions()
      self:removeSelf()
    end)
  }))
end
function CAwardPromptItem:flyUp()
  self.m_FlyTimes = self.m_FlyTimes + 1
  local height = self:getSize().height
  local dh = height * 0.3
  local downTime = itemFlyUpTime * 0.2
  local x, y = self.m_OrgPos[1], self.m_OrgPos[2]
  local dy = y + height * self.m_FlyTimes
  if self.m_FlyUpAction then
    self:stopAction(self.m_FlyUpAction)
  end
  self.m_FlyUpAction = transition.sequence({
    CCMoveTo:create(itemFlyUpTime - downTime, ccp(x, dy + dh)),
    CCMoveTo:create(downTime, ccp(x, dy))
  })
  self:runAction(self.m_FlyUpAction)
end
function CAwardPromptItem:flyToIdx(idx)
  self.m_EndPosIndex = idx
  local height = self:getSize().height
  local x, y = self.m_OrgPos[1], self.m_OrgPos[2]
  local dy = height * idx
  local ny = y + dy
  local timeFly = dy / 500
  if timeFly < 0 then
    timeFly = 0 - timeFly
  end
  timeFly = math.min(timeFly, 0.3)
  if self.m_FlyUpAction then
    self:stopAction(self.m_FlyUpAction)
  end
  self.m_FlyUpAction = transition.sequence({
    CCMoveTo:create(timeFly, ccp(x, ny))
  })
  self:runAction(self.m_FlyUpAction)
end
function CAwardPromptItem:getKeyId()
  return self.m_KeyId
end
function CAwardPromptItem:onCleanup()
  self.m_FlyUpAction = nil
  if self.m_ClearListener then
    self.m_ClearListener(self.m_KeyId, self)
  end
end
AwardPrompt = {}
local award_show_seq = {
  [RESTYPE_EXP] = 1,
  [RESTYPE_COIN] = 2,
  [RESTYPE_GOLD] = 3,
  [RESTYPE_SILVER] = 4
}
function AwardPrompt.addPrompt(award, awardType, sound)
  if award == nil or #award == 0 then
    return
  end
  if isResId == nil then
    isResId = true
  end
  if type(award) ~= "table" then
    award = {
      {award}
    }
  elseif type(award[1]) ~= "table" then
    award = {award}
  end
  local showItemDatas = {}
  local curExpDataInsertIdx = 1
  for i1, awardData in ipairs(award) do
    local t = awardData[1]
    local ordert = award_show_seq[t] or #award_show_seq + 1
    local idx = #showItemDatas + 1
    for i, d in ipairs(showItemDatas) do
      local order_ = award_show_seq[d[1]] or #award_show_seq + 1
      if order_ == ordert then
        if t == RESTYPE_EXP and d[1] == t and awardData[3] ~= d[3] and awardData[3] ~= true then
          idx = i
          break
        end
      elseif ordert < order_ then
        idx = i
        break
      end
    end
    table.insert(showItemDatas, idx, awardData)
  end
  AwardPrompt._curDeltaTime = 0
  local clearFlag = false
  for _, item in pairs(AwardPrompt._curShow_Items) do
    if 0 > item.m_EndPosIndex then
      clearFlag = true
      break
    end
  end
  if clearFlag then
    for i = #AwardPrompt._curShow_Items, 1, -1 do
      local item = AwardPrompt._curShow_Items[i]
      item:stopAllActions()
      item:removeSelf()
    end
    AwardPrompt._curShow_Items = {}
  end
  for i, v in ipairs(showItemDatas) do
    v.VType = awardType
    v.pSound = sound
    AwardPrompt._award_list[#AwardPrompt._award_list + 1] = v
  end
  AwardPrompt._award_list_len = #AwardPrompt._award_list
end
function AwardPrompt.ItemClear(keyId, item)
  for idx, itemTemp in ipairs(AwardPrompt._curShow_Items) do
    if itemTemp == item or itemTemp:getKeyId() == keyId then
      table.remove(AwardPrompt._curShow_Items, idx)
      break
    end
  end
end
function AwardPrompt.init()
  AwardPrompt._award_list = {}
  AwardPrompt._award_list_len = 0
  AwardPrompt._key = 1
  AwardPrompt._curShow_Items = {}
  local x = display.width / 2
  local y = display.height * 4 / 6
  AwardPrompt._orgPos = ccp(x, y)
  AwardPrompt._curDeltaTime = 0
  AwardPrompt._scheduleHandler = scheduler.scheduleUpdateGlobal(AwardPrompt.ShowUpdate)
end
function AwardPrompt.Clear()
  scheduler.unscheduleGlobal(AwardPrompt._scheduleHandler)
end
function AwardPrompt.ShowUpdate(dt)
  if AwardPrompt and AwardPrompt._award_list_len > 0 then
    local displaySound = false
    local deltaShowData = {}
    for idx, awardData in ipairs(AwardPrompt._award_list) do
      if g_WarScene ~= nil and awardData.VType == AwardPromptType_NotShowInWar then
        deltaShowData[#deltaShowData + 1] = awardData
      else
        local item = CAwardPromptItem.new(AwardPrompt._key, AwardPrompt.ItemClear)
        AwardPrompt._key = AwardPrompt._key + 1
        local temp, ds = item:Init(awardData, AwardPrompt._orgPos.x, AwardPrompt._orgPos.y)
        displaySound = displaySound or ds or awardData.pSound == 1
        if temp == true then
          item:setStartShow()
          addNodeToTopLayer(item, TopLayerZ_NotifyAwardMsg)
          AwardPrompt._curShow_Items[#AwardPrompt._curShow_Items + 1] = item
        end
      end
    end
    AwardPrompt._award_list = deltaShowData
    AwardPrompt._award_list_len = #AwardPrompt._award_list
    local len = math.min(DEF_UpMaxNum, #AwardPrompt._curShow_Items)
    for idx, itemTemp in ipairs(AwardPrompt._curShow_Items) do
      itemTemp:flyToIdx(len - idx)
    end
    if displaySound then
      soundManager.playSound("xiyou/sound/sysmsg.wav")
    end
  end
  if AwardPrompt._NeedShowMissionCmp == true and g_WarScene == nil then
    AwardPrompt._NeedShowMissionCmp = false
    AwardPrompt.ShowMissionCmp_()
  end
end
function AwardPrompt.ShowUpdate_old(dt)
  if AwardPrompt._award_list_len > 0 then
    AwardPrompt._curDeltaTime = AwardPrompt._curDeltaTime - dt
    if 0 >= AwardPrompt._curDeltaTime then
      local deltaShowData = {}
      while 0 < #AwardPrompt._award_list do
        AwardPrompt._award_list_len = AwardPrompt._award_list_len - 1
        local awardData = table.remove(AwardPrompt._award_list, 1)
        if g_WarScene ~= nil and awardData.VType == AwardPromptType_NotShowInWar then
          deltaShowData[#deltaShowData + 1] = awardData
        else
          local item = CAwardPromptItem.new(AwardPrompt._key, AwardPrompt.ItemClear)
          AwardPrompt._key = AwardPrompt._key + 1
          local x = display.width / 2
          local y = display.height * 3 / 5
          if item:Init(awardData, x, y) == true then
            item:setStartShow()
            addNodeToTopLayer(item, TopLayerZ_NotifyAwardMsg)
            AwardPrompt._curDeltaTime = showItemDeltaTime
            AwardPrompt._curShow_Items[item.m_KeyId] = item
            for i, itemTemp in pairs(AwardPrompt._curShow_Items) do
              itemTemp:flyUp()
            end
            break
          end
        end
      end
      if #deltaShowData > 0 then
        for i = #deltaShowData, 1, -1 do
          table.insert(AwardPrompt._award_list, 1, deltaShowData[i])
          AwardPrompt._award_list_len = #AwardPrompt._award_list
        end
      end
    end
  end
end
function AwardPrompt.ShowMissionCmp()
  AwardPrompt._NeedShowMissionCmp = true
end
function AwardPrompt.ShowMissionCmp_()
  if AwardPrompt._SpriteForMissionCmp == nil then
    AwardPrompt._SpriteForMissionCmp = display.newSprite("xiyou/ani/eff_mission_cmp_tips.png")
    addNodeToTopLayer(AwardPrompt._SpriteForMissionCmp, TopLayerZ_NotifyMissionCmp)
  end
  local node = AwardPrompt._SpriteForMissionCmp
  node:stopAllActions()
  node:setVisible(true)
  node:setOpacity(255)
  node:setPosition(cc.p(display.width / 2, display.height / 2))
  local act1 = CCSpawn:createWithTwoActions(CCMoveBy:create(0.5, cc.p(0, 70)), CCFadeOut:create(0.5))
  node:runAction(transition.sequence({
    CCDelayTime:create(0.3),
    act1
  }))
end
AwardPrompt.init()
gamereset.registerResetFunc(function()
  AwardPrompt.Clear()
  AwardPrompt.init()
end)
