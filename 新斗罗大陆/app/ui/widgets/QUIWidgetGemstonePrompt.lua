local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstonePrompt = class("QUIWidgetGemstonePrompt", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
function QUIWidgetGemstonePrompt:ctor(options)
    local ccbFile = "ccb/Dialog_Baoshi_tips.ccbi"
    local callBacks = {}
    QUIWidgetGemstonePrompt.super.ctor(self, ccbFile, callBacks, options)

    self._gemstoneSid = options.gemstronSid


    local gemstoneInfo = remote.gemstone:getGemstoneById(self._gemstoneSid)
    local itemId = gemstoneInfo and gemstoneInfo.itemId or self._gemstoneSid
    local itemConfig = db:getItemByID(itemId)
    local goldLevel = 0 
    local mixLevel = 0 
    if gemstoneInfo then
        local icon = QUIWidgetGemstonesBox.new()
        self._ccbOwner.node_icon:addChild(icon)
        icon:setGemstoneInfo(gemstoneInfo)
      goldLevel = gemstoneInfo.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
      mixLevel = gemstoneInfo.mix_level or 0
    else
        local icon = QUIWidgetItemsBox.new()
        self._ccbOwner.node_icon:addChild(icon)
        icon:setGoodsInfo(self._gemstoneSid,ITEM_TYPE.ITEM)
    end

    

    for i=1,4 do
        self._ccbOwner["tf_suit_prop"..i]:setString("")
    self._ccbOwner["tf_name"..i]:setString("")
    end

    self._ccbOwner.tf_type:setString(remote.gemstone:getTypeDesc(itemConfig.gemstone_type))
  local suits = {}
  local bIsSS = false
  local bIsSSP = false
 
  local name = itemConfig.name
  name = remote.gemstone:getGemstoneNameByData(name,goldLevel,mixLevel)

  self._ccbOwner.tf_name:setString(name)
  
  local suit_gemstone_id = itemConfig.id
  local gemstone_set_index = itemConfig.gemstone_set_index


  local gemstoneQuality = itemConfig.gemstone_quality

  if gemstoneQuality == APTITUDE.S then
    if  mixLevel > 0 then
      gemstoneQuality =  APTITUDE.SSR
    elseif goldLevel > GEMSTONE_MAXADVANCED_LEVEL then
      gemstoneQuality =  APTITUDE.SS
    end
  end

  suits = remote.gemstone:getSuitByItemId(suit_gemstone_id)

    for index,suitInfo in ipairs(suits) do
        local icon = QUIWidgetGemstonesBox.new()
        self._ccbOwner["node_suit"..index]:addChild(icon)
    icon:setState(remote.gemstone.GEMSTONE_ICON)
    -- icon:setItemId(suitInfo.id)
    local name = suitInfo.name
    local frontName = q.SubStringUTF8(name,1,2)
    local backName = q.SubStringUTF8(name,3)

 
    if gemstoneQuality <= APTITUDE.S then --普通的a与s级魂骨
      icon:setItemIdByData(suitInfo.id , 0 , 0)
      name = frontName.."\n"..backName
    elseif gemstoneQuality == APTITUDE.SS then  --只化神的SS魂骨
      name = "SS"..frontName.."\n"..backName
      icon:setItemIdByData(suitInfo.id , GEMSTONE_MAXADVANCED_LEVEL , 0)
    elseif gemstoneQuality == APTITUDE.SSR then -- SS+魂骨
      icon:setItemIdByData(suitInfo.id , 0 , 1)
      name = "SS+"..frontName.."\n"..backName
    end
      self._ccbOwner["tf_name"..index]:setString(name)
      self._ccbOwner["tf_ssname"..index]:setString("")
      icon:setNameVisible(false)
      icon:setIconScale(0.6)
    end

  local descTbl = {}
  if gemstoneQuality <= APTITUDE.S then --普通的a与s级魂骨
    local suitInfos = db:getGemstoneSuitEffectBySuitId(itemConfig.gemstone_set_index)
    for index,suitInfo in ipairs(suitInfos) do
      table.insert(descTbl , index , {forceText = "" , normalText = suitInfo.set_desc})
    end
  elseif gemstoneQuality == APTITUDE.SS then  --只化神的SS魂骨
    local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(itemId, GEMSTONE_MAXADVANCED_LEVEL)
    if gemstoneInfo_ss and gemstoneInfo_ss.gem_evolution_new_set then
      local suitInfos = db:getGemstoneSuitEffectBySuitId(gemstoneInfo_ss.gem_evolution_new_set)
      for index,suitInfo in ipairs(suitInfos) do
        table.insert(descTbl , index , {forceText = "【SS】" , normalText = suitInfo.set_desc})
      end
    end
  elseif gemstoneQuality == APTITUDE.SSR then -- SS+魂骨
    local mixConfig = remote.gemstone:getGemstoneMixConfigByIdAndLv(itemId, 1)
    if mixConfig and mixConfig.gem_suit then
      for index=1,3 do
        local suitConfig = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, index + 1,1)
        if suitConfig then
          table.insert(descTbl , index , {forceText = "【SS+" , normalText = suitConfig.set_desc })
        else
          table.insert(descTbl , index , {forceText = "【SS+" , normalText = ""})
        end
      end
    end
  end
  local max_text_width = 368
  for i,v in ipairs(descTbl) do
    self._ccbOwner["tf_suit_prop"..i]:setString(v.forceText..(i + 1).." 件效果】"..v.normalText)
    local text_width = self._ccbOwner["tf_suit_prop"..i]:getContentSize().width
    max_text_width = math.max(max_text_width,text_width)    
  end


    -- local suitInfos = QStaticDatabase:sharedDatabase():getGemstoneSuitEffectBySuitId(gemstone_set_index)
 --  local suitName = suitInfos[1].name
 --  -- if suitsType == 2 then
 --  --   suitName = "SS"..suitName
 --  -- end
    -- self._ccbOwner.tf_suit_name:setString(suitName)
 --  local max_text_width = 368
    -- for index,suitInfo in ipairs(suitInfos) do
    --  self._ccbOwner["tf_suit_prop"..index]:setString("【"..suitInfo.set_number.." 件效果】"..suitInfo.set_desc)
 --    local text_width = self._ccbOwner["tf_suit_prop"..index]:getContentSize().width
 --    max_text_width = math.max(max_text_width,text_width)
    -- end 



  if max_text_width > 368 then
    local size = self._ccbOwner.node_bg_long:getContentSize()

    for i=1,4 do
      self._ccbOwner["tf_suit_prop"..i]:setPositionX(max_text_width * -0.5)
    end
    size.width = max_text_width + 40
    self._ccbOwner.node_bg_long:setContentSize(CCSize(size.width, size.height))
    self._ccbOwner.node_bg_long:setPositionX(size.width * -0.5)
  end

end

return QUIWidgetGemstonePrompt