local DisplayPerLevelTime = 1
local DisplayIconZ = 10
local CExpHeadBase = class("CExpHeadBase", CcsSubView)
function CExpHeadBase:ctor(roleID, expadd, data, viewPath, expPath, expBgPath)
  CExpHeadBase.super.ctor(self, viewPath)
  local shapeID = g_LocalPlayer:getObjProperty(roleID, PROPERTY_SHAPE)
  local headPos = self:getNode("head")
  local headParent = headPos:getParent()
  local hx, hy = headPos:getPosition()
  local zOrder = headPos:getZOrder()
  local headIcon = createHeadIconByShape(shapeID)
  headParent:addNode(headIcon, zOrder)
  headIcon:setPosition(hx, hy + 7)
  local prelevel = data.prelevel
  local newlevel = data.level
  self.m_ShowUpgradeIconTimes = newlevel - prelevel
  local act1 = CCDelayTime:create(DisplayPerLevelTime)
  local act2 = CCCallFunc:create(function()
    self:ShowOneUpgradeIcon()
  end)
  self:runAction(transition.sequence({act1, act2}))
  local barpos = self:getNode("barpos")
  barpos:setVisible(false)
  local barParent = barpos:getParent()
  local bx, by = barpos:getPosition()
  local zOrder_2 = barpos:getZOrder()
  local zs = g_LocalPlayer:getObjProperty(roleID, PROPERTY_ZHUANSHENG)
  local preexp = data.preexp
  local newexp = data.exp
  local maxexp = self:GetMaxExp(prelevel, zs)
  local maxLv = data_getMaxHeroLevel(zs)
  self.m_ExpBar = ProgressClip.new(expPath, expBgPath, preexp, maxexp, true)
  barParent:addChild(self.m_ExpBar, zOrder_2)
  self.m_ExpBar:setPosition(ccp(bx, by))
  local temp8Text = CCLabelTTF:create("(>8)", KANG_TTF_FONT, 20, CCSize(500, 0), ui.TEXT_ALIGN_LEFT, ui.TEXT_VALIGN_CENTER)
  temp8Text:setVisible(false)
  self:addNode(temp8Text)
  self.m_Show8Txt = temp8Text
  local dt = DisplayPerLevelTime
  local totaldt = 0
  if prelevel < maxLv then
    local actList = {}
    local lv = prelevel
    while newlevel >= lv do
      do
        local tempLv = lv
        if newlevel > lv then
          actList[#actList + 1] = CCCallFunc:create(function()
            self.m_ExpBar:progressFull(dt)
          end)
        else
          actList[#actList + 1] = CCCallFunc:create(function()
            if tempLv >= maxLv then
              self.m_ExpBar:progressFull()
            else
              self.m_ExpBar:progressTo(newexp, dt)
              totaldt = totaldt + dt
            end
          end)
        end
        actList[#actList + 1] = CCDelayTime:create(dt)
        totaldt = totaldt + dt
        lv = lv + 1
        if newlevel >= lv then
          do
            local tempLv = lv
            actList[#actList + 1] = CCCallFunc:create(function()
              maxexp = self:GetMaxExp(tempLv, zs)
              if maxexp == nil then
                maxexp = newexp
              end
              self.m_ExpBar:value(0, maxexp)
              local mainHeroIns = g_LocalPlayer:getMainHero()
              if mainHeroIns then
                local heroLv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
                local heroZs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
                if heroZs < zs or zs == heroZs and tempLv >= heroLv + PETLV_HEROLV_MAXDEL then
                  self.m_Show8Txt:setVisible(true)
                end
              end
            end)
          end
        else
          local mainHeroIns = g_LocalPlayer:getMainHero()
          if mainHeroIns then
            local heroLv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
            local heroZs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
            if zs > heroZs or zs == heroZs and newlevel >= heroLv + PETLV_HEROLV_MAXDEL then
              self.m_Show8Txt:setVisible(true)
            end
          end
        end
      end
    end
    local seq = transition.sequence(actList)
    self:runAction(seq)
  else
    self.m_ExpBar:progressFull()
  end
  if prelevel == newlevel and preexp == newexp then
    expadd = 0
  end
  local exptxt = self:getNode("exptxt")
  RollingNumberEffect(exptxt, 0, expadd, totaldt, "+")
  local lvtxt = self:getNode("lvtxt")
  RollingNumberEffect(lvtxt, prelevel, newlevel, totaldt, string.format("%d转", zs))
  local x, y = self:getNode("lvtxt"):getPosition()
  local size = self:getNode("lvtxt"):getContentSize()
  temp8Text:setAnchorPoint(ccp(0, 0))
  temp8Text:setColor(VIEW_DEF_WARNING_COLOR)
  temp8Text:setPosition(ccp(x + size.width / 2 + 3, y - size.height / 2))
end
function CExpHeadBase:ShowOneUpgradeIcon()
  if self.m_ShowUpgradeIconTimes <= 0 then
    return
  end
  self.m_ShowUpgradeIconTimes = self.m_ShowUpgradeIconTimes - 1
  local icon = display.newSprite("xiyou/pic/pic_upgradeicon.png")
  icon:setAnchorPoint(ccp(0.5, 0.5))
  local x, y = self:getNode("head"):getPosition()
  local size = self:getNode("head"):getContentSize()
  icon:setPosition(x, y - size.height / 2)
  self:addNode(icon, DisplayIconZ)
  local act0 = CCCallFunc:create(function()
    soundManager.playSound("xiyou/sound/war_levelup.wav")
  end)
  local act11 = CCMoveTo:create(DisplayPerLevelTime, ccp(x, y + size.height / 2))
  local act121 = CCFadeIn:create(DisplayPerLevelTime / 3)
  local act122 = CCDelayTime:create(DisplayPerLevelTime / 3)
  local act123 = CCFadeOut:create(DisplayPerLevelTime / 3)
  local act12 = transition.sequence({
    act121,
    act122,
    act123
  })
  local act1 = CCSpawn:createWithTwoActions(act11, act12)
  local act2 = CCCallFunc:create(function()
    icon:removeFromParent()
  end)
  icon:runAction(transition.sequence({
    act0,
    act1,
    act2
  }))
  local act1 = CCDelayTime:create(DisplayPerLevelTime)
  local act2 = CCCallFunc:create(function()
    self:ShowOneUpgradeIcon()
  end)
  self:runAction(transition.sequence({act1, act2}))
end
CMainExpHead = class("CMainExpHead", CExpHeadBase)
function CMainExpHead:ctor(roleID, expadd, data)
  CMainExpHead.super.ctor(self, roleID, expadd, data, "views/warresult_head_main.json", "views/warui/expbar.png", "views/warui/expbarbg.png")
end
function CMainExpHead:GetMaxExp(lv, zs)
  return CalculateHeroLevelupExp(lv, zs)
end
local CExpHead = class("CExpHead", CExpHeadBase)
function CExpHead:ctor(roleID, expadd, data)
  CExpHead.super.ctor(self, roleID, expadd, data, "views/warresult_head.json", "views/warui/expbar.png", "views/warui/expbarbg.png")
end
function CExpHead:GetMaxExp(lv, zs)
  return CalculatePetLevelupExp(lv, zs)
end
g_WarWinResultIns = nil
local warresult_win = class("warresult_win", CcsSubView)
function warresult_win:ctor(stars, itemData, heroaddexp, heroinfo, petaddexp, petinfo, moneyaward, warType, warTypeData)
  warresult_win.super.ctor(self, "views/warresult_win.json", {isAutoCenter = true, opacityBg = 100})
  self.m_WarType = warType
  self.m_WarTypeData = warTypeData
  self.m_RewardItemData = itemData
  self.m_RewardMoney = moneyaward
  self.m_Heroaddexp = heroaddexp
  self.m_Petaddexp = petaddexp
  local btnBatchListener = {
    btn_continue = {
      listener = handler(self, self.Btn_Continue),
      variName = "btn_continue"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local doubleFlag = false
  local mapID = self.m_WarTypeData.mapID
  local catchID = self.m_WarTypeData.catchID
  local isSuper = self.m_WarTypeData.isSuper
  if isSuper ~= 0 then
    doubleFlag = true
  else
    doubleFlag = data_getCatchIsDouble(mapID, catchID)
  end
  if doubleFlag then
    local dt = 0.3
    for index = 1, 3 do
      local starImg = self:getNode(string.format("star_%d", index))
      starImg:setVisible(false)
      if index <= stars then
        local scale = starImg:getScale()
        starImg:setScale(0)
        local act1 = CCDelayTime:create(dt)
        local act2 = CCShow:create()
        local act3 = CCScaleTo:create(0.2, scale * 1.8)
        local act4 = CCScaleTo:create(0.2, scale)
        starImg:runAction(transition.sequence({
          act1,
          act2,
          act3,
          act4
        }))
        dt = dt + 0.3
      end
    end
  else
    for index = 1, 3 do
      local starImg = self:getNode(string.format("star_%d", index))
      starImg:setVisible(false)
    end
  end
  self.m_RoleList = self:getNode("rolelist")
  self.m_RoleList:setBackGroundColorOpacity(0)
  local mainHeroID = g_LocalPlayer:getMainHeroId()
  for heroID, info in pairs(heroinfo) do
    if heroID == mainHeroID then
      local mainExpHead = CMainExpHead.new(heroID, heroaddexp, info)
      self.m_RoleList:pushBackCustomItem(mainExpHead:getUINode())
    end
  end
  for petID, info in pairs(petinfo) do
    local expHead = CExpHead.new(petID, petaddexp, info)
    self.m_RoleList:pushBackCustomItem(expHead:getUINode())
  end
  self.m_ItemList = self:getNode("rewardlist")
  self.m_ItemList:setBackGroundColorOpacity(0)
  for itemID, itemNum in pairs(itemData) do
    local itemIcon = createClickItem({
      itemID = itemID,
      autoSize = nil,
      num = itemNum,
      LongPressTime = 0.3,
      clickListener = nil,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = nil
    })
    local size = itemIcon:getContentSize()
    local x, y = itemIcon._BgIcon:getPosition()
    itemIcon._BgIcon:setPosition(x + 5, y + 5)
    local x2, y2 = itemIcon._Icon:getPosition()
    itemIcon._Icon:setPosition(x2 + 5, y2 + 5)
    itemIcon:setSize(CCSize(size.width + 10, size.height + 10))
    self.m_ItemList:pushBackCustomItem(itemIcon)
  end
  local goldtxt = self:getNode("goldtxt")
  goldtxt:setText(tostring(moneyaward))
  soundManager.playSound("xiyou/sound/war_win_fb.wav")
  if g_WarWinResultIns ~= nil then
    g_WarWinResultIns:CloseSelf()
    g_WarWinResultIns = nil
  end
  g_WarWinResultIns = self
end
function warresult_win:Btn_Continue(obj, t)
  self:CloseSelf()
end
function warresult_win:CloseSelf(obj, t)
  print("--->>Btn_Continue_win")
  warresult_win.super.CloseSelf(self)
  if self.m_WarType == WARTYPE_FUBEN then
    local param = self.m_WarTypeData.paramTable
    if param and param.closeFbWhenEnterWar then
    elseif self.m_WarTypeData.jumpToNextIfWin == true then
      g_FbInterface.ShowMaxFuBenCatch(self.m_WarTypeData.isSuper)
    else
      g_FbInterface.PointToFuBenCatch(self.m_WarTypeData.mapID, self.m_WarTypeData.catchID, self.m_WarTypeData.isSuper)
    end
  end
end
function warresult_win:onEnterEvent()
  SendMessage(MsgID_Scene_WarResult_Enter)
end
function warresult_win:Clear()
  if g_WarScene then
    g_WarScene:ClearWarResult(self)
  end
  if g_WarWinResultIns == self then
    g_WarWinResultIns = nil
  end
  SendMessage(MsgID_Scene_WarResult_Exit)
end
function DisplayGetItemFromWar(itemData, moneyaward, heroaddexp, petaddexp)
  local award = {}
  if moneyaward ~= nil and moneyaward > 0 then
    award[#award + 1] = {RESTYPE_COIN, moneyaward}
  end
  if heroaddexp ~= nil and heroaddexp > 0 then
    award[#award + 1] = {RESTYPE_EXP, heroaddexp}
  end
  if petaddexp ~= nil and petaddexp > 0 then
    award[#award + 1] = {
      RESTYPE_EXP,
      petaddexp,
      true
    }
  end
  if itemData ~= nil then
    for itemID, itemNum in pairs(itemData) do
      if itemNum > 0 then
        award[#award + 1] = {
          [itemID] = itemNum
        }
      end
    end
  end
  AwardPrompt.addPrompt(award)
end
function ShowWarResult_Win(warID, itemData, heroaddexp, heroinfo, petaddexp, petinfo, moneyaward, warType, warTypeData)
  local stars = g_WarScene:getResultStars()
  QuitWarSceneAndBackToPreScene()
  if warType == WARTYPE_BpWAR then
  elseif warType == WARTYPE_FUBEN then
  elseif warType == WARTYPE_LEITAI then
    ShowLeiWangZhengBaDlg()
  else
    DisplayGetItemFromWar(itemData, moneyaward, heroaddexp, petaddexp)
  end
end
