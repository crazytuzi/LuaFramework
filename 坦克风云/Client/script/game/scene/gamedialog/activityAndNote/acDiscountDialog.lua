

acDiscountDialog=activityDialog:new()

function acDiscountDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.props = nil
    return nc
end

function acDiscountDialog:initVo(acVo)
  self.acVo = acVo
  self.props = acDiscountVoApi:getDiscountProp()
end

function acDiscountDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    if self.props ~= nil then
      return SizeOfTable(self.props)
    else
      return 1
    end
    
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth - 40,150)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, 146))
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(10,4))
    cell:addChild(backSprie,1)

    local backSpriteCenterY = backSprie:getContentSize().height/2
    local propDiscount = self.props[idx + 1]
    local prop=propCfg[propDiscount.id]
    local maxCount = acDiscountVoApi:getDiscountMaxCountById(propDiscount.id)
    local count = acDiscountVoApi:getDiscountCountById(propDiscount.id)

    if count > maxCount then
      count = maxCount
    end
    
    if prop == nil then 
      do
        return cell
      end
    end

    -- 点击奖励图标，弹出奖励具体信息框
    local function showInfoHandler(hd,fn,idx)
      if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        local item={name=getlocal(prop.name), pic=prop.icon, num=1, desc=prop.description}
        if item and item.name and item.pic and item.num and item.desc then
          if (G_curPlatName()=="11" or G_curPlatName()=="androidsevenga") and prop.sid==87 then
          -- if prop.sid==87 then
              item.pic="public/caidan.png"
              propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,true)
          else
              propInfoDialog:create(sceneGame,item,self.layerNum+1)
          end
          
        end
      end
    end

    local acIcon
    -- local acIcon = LuaCCSprite:createWithSpriteFrameName(prop.icon,showInfoHandler)
    if (G_curPlatName()=="11" or G_curPlatName()=="androidsevenga") and prop.sid==87 then
    -- if prop.sid==87 then
        acIcon = LuaCCSprite:createWithFileName("public/caidan.png",showInfoHandler)
    else
        acIcon = LuaCCSprite:createWithSpriteFrameName(prop.icon,showInfoHandler)
    end
    acIcon:setAnchorPoint(ccp(0,0.5))
    acIcon:setScale(0.9)
    acIcon:setPosition(ccp(10, backSpriteCenterY + 10))
    acIcon:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:addChild(acIcon,1)

    local schedule = GetTTFLabel(getlocal("scheduleChapter",{count,maxCount}),26)
    schedule:setAnchorPoint(ccp(0.5,0))
    schedule:setPosition(ccp(10 + acIcon:getContentSize().width/2, 10))
    backSprie:addChild(schedule,4)

    local title = GetTTFLabelWrap(getlocal(prop.name),26,CCSizeMake(backSprie:getContentSize().width - 330, 100),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    title:setAnchorPoint(ccp(0,1))
    title:setPosition(ccp(120, 126))
    title:setColor(G_ColorGreen)
    backSprie:addChild(title,2)
    
    local needHeightPos = -25
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
      needHeightPos = 0
    end
    local bottomY = 40
    -- 金币图标
    local originalIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
    originalIcon:setAnchorPoint(ccp(0,0))
    originalIcon:setPosition(ccp(120,bottomY+needHeightPos));
    backSprie:addChild(originalIcon,5)

    -- 原价
    local originalPriceLabel = GetTTFLabel(tostring(prop.gemCost),26)
    originalPriceLabel:setAnchorPoint(ccp(0,0))
    originalPriceLabel:setPosition(ccp(150, bottomY+needHeightPos))
    backSprie:addChild(originalPriceLabel,6)


    local line = CCSprite:createWithSpriteFrameName("redline.jpg")
    line:setScaleX((originalPriceLabel:getContentSize().width  + 40) / line:getContentSize().width)
    line:setAnchorPoint(ccp(0, 0))
    line:setPosition(ccp(115,bottomY + 12+needHeightPos))
    backSprie:addChild(line,7)

    local priceIconX = 170 + originalPriceLabel:getContentSize().width
    -- 金币图标
    local pricelIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
    pricelIcon:setAnchorPoint(ccp(0,0))
    -- pricelIcon:setPosition(ccp(priceIconX,bottomY));
    pricelIcon:setPosition(ccp(240,bottomY+needHeightPos));
    backSprie:addChild(pricelIcon,8)

   
    local propCurrentPrice = math.ceil(prop.gemCost * propDiscount.dis)
    -- 现价
    local priceLabel = GetTTFLabel(tostring(propCurrentPrice),34)
    priceLabel:setAnchorPoint(ccp(0,0))
    -- priceLabel:setPosition(ccp(priceIconX + 30, bottomY - 4))
    priceLabel:setPosition(ccp(240+pricelIcon:getContentSize().width, bottomY - 4+needHeightPos))
    backSprie:addChild(priceLabel,9)

    local function touch1(tag,object)
      if self.tv:getIsScrolled()==true then
        return
      end
                 
      PlayEffect(audioCfg.mouseClick)
      if count >= maxCount then
        local td=smallDialog:new()
        local tabStr = {" ",getlocal("activity_discount_maxNum")," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
        do return end
      end
      local function touchBuy()
        local function callbackBuyprop(fn,data)
          if base:checkServerData(data)==true then
            --统计购买物品
            statisticsHelper:buyItem(propDiscount.id,propCurrentPrice,1,propCurrentPrice)
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{getlocal(prop.name)}),28)
            acDiscountVoApi:addBuyNum(propDiscount.id, 1)
            self.tv:reloadData()
          end              

        end
        socketHelper:buyProc(tag,callbackBuyprop,1, "discount")
      end
                 
      local function buyGems()
        if G_checkClickEnable()==false then
          do
            return
          end
        end
        vipVoApi:showRechargeDialog(self.layerNum+1)

      end
      if playerVo.gems<tonumber(propCurrentPrice) then
        local num=tonumber(propCurrentPrice)-playerVo.gems
        local smallD=smallDialog:new()
        smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(propCurrentPrice),playerVo.gems,num}),nil,self.layerNum+1)
      else
        local smallD=smallDialog:new()
        smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{propCurrentPrice,getlocal(prop.name)}),nil,self.layerNum+1)
      end      
    end

    local menuItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touch1,tonumber(prop.sid),getlocal("buy"),30)
    menuItem:setEnabled(true)
    menuItem:setAnchorPoint(ccp(1, 0))
    local menu3=CCMenu:createWithItem(menuItem)
    menu3:setPosition(ccp(backSprie:getContentSize().width - 10, 10))
    menu3:setTouchPriority(-(self.layerNum-1)*20-2);
    backSprie:addChild(menu3,10)

    local discountLabel = GetTTFLabel(getlocal("activity_discount_buyGemsDiscount",{math.floor(100 - propDiscount.dis*100)}),28)
    discountLabel:setColor(G_ColorYellowPro)
    discountLabel:setAnchorPoint(ccp(1,1))
    -- discountLabel:setPosition(ccp(backSprie:getContentSize().width - 10 - menuItem:getContentSize().width, 126))
    discountLabel:setPosition(ccp(backSprie:getContentSize().width - 20, 126))
    backSprie:addChild(discountLabel,3)


    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acDiscountDialog:tick()

end

function acDiscountDialog:update()
  local acVo = acDiscountVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end
end

function acDiscountDialog:dispose()
  self.acVo = nil
  self=nil
end





