acPreparingPeakDialog=commonDialog:new()

function acPreparingPeakDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.normalHeight=220
    self.props=nil
    self.isToday = true

    return nc
end


--设置对话框里的tableView
function acPreparingPeakDialog:initTableView()


    self.panelLineBg:setVisible(false)
    self.props = acPreparingPeakVoApi:getDiscountProp()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-460),nil)

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(10,20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)


    local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    end
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(10,self.bgLayer:getContentSize().height - 430))
    self.bgLayer:addChild(characterSp,5)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 428))
    self.bgLayer:addChild(lineSprite,6)
    
    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(410,200))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(180,self.bgLayer:getContentSize().height - 410))
    self.bgLayer:addChild(girlDescBg,4)

    local descTv=G_LabelTableView(CCSize(300,180),getlocal("activity_preparingPeak_content"),25,kCCTextAlignmentCenter)
    descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv:setAnchorPoint(ccp(0,0))
    descTv:setPosition(ccp(70,10))
    girlDescBg:addChild(descTv,2)
    descTv:setMaxDisToBottomOrTop(50)
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-105))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acPreparingPeakVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-140))
        self.bgLayer:addChild(timeLabel)
        self.timeLb=timeLabel
        G_updateActiveTime(acVo,self.timeLb)
    end

    local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_preparingPeak_Tip3"),"\n",getlocal("activity_preparingPeak_Tip2"),"\n",getlocal("activity_preparingPeak_Tip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil,nil,nil,nil,nil})
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    --infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,self.bgLayer:getContentSize().height-105))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,3);
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acPreparingPeakDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.props)

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.normalHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight))

        local propDiscount = self.props[idx + 1]
		local prop=propCfg[propDiscount.id]
		local maxCount = acPreparingPeakVoApi:getDiscountMaxCountById(propDiscount.id)
		local count = acPreparingPeakVoApi:getDiscountCountById(propDiscount.id)

		if count > maxCount then
		  count = maxCount
		end
		if prop == nil then 
		  do
		    return cell
		  end
		end

        
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        
        end
        local txtSize = 25

        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
        headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.normalHeight))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(10,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)

        local function touch()
		end
		local capInSet = CCRect(20, 20, 10, 10)
		local titleBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",capInSet,touch)
		titleBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,50))
		titleBg:setAnchorPoint(ccp(0,1))
		titleBg:setPosition(ccp(-10,headerSprie:getContentSize().height))
		headerSprie:addChild(titleBg,1)


        -- local pic = nil
        -- local title = ""
        -- local des = nil
        -- if idx == 0 then
        --     title = getlocal("activity_preparingPeak_roleTitle",{count,maxCount})
        --     des = getlocal("activity_luckUp_des1",{acLuckUpVoApi:getAddTroops()})
        -- elseif idx == 1 then
        --     title = getlocal("activity_preparingPeak_accessoryTitle",{count,maxCount})
        --     des = getlocal("activity_luckUp_des1",{acLuckUpVoApi:getAddTroops()})
        -- else
        --     title = getlocal("activity_preparingPeak_tankTitle",{count,maxCount})
        --    	des = getlocal("activity_luckUp_des1",{acLuckUpVoApi:getAddTroops()})
        -- end

         -- 点击奖励图标，弹出奖励具体信息框
		local function showInfoHandler(hd,fn,idx)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end

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

       local mIcon
       if (G_curPlatName()=="11" or G_curPlatName()=="androidsevenga") and pid=="p87" then
       -- if pid=="p87" then
            mIcon = LuaCCSprite:createWithFileName("public/caidan.png",showInfoHandler)
       elseif prop.Aid then
            local equipId=prop.Aid
            local eType=string.sub(equipId,1,1)
            if eType=="a" then
                mIcon=accessoryVoApi:getAccessoryIcon(equipId,80,100,showInfoHandler)
            elseif eType=="f" then
                mIcon=accessoryVoApi:getFragmentIcon(equipId,80,100,showInfoHandler)
            elseif eType=="p" then
                local pic=accessoryCfg.propCfg[equipId].icon
                mIcon=LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
            end
       elseif pid=="p56" then
            mIcon = GetBgIcon(prop.icon,showInfoHandler,nil,70,100)
       elseif pid=="p57" then
            mIcon = GetBgIcon(prop.icon,showInfoHandler,nil,80,100)
       else
            mIcon = LuaCCSprite:createWithSpriteFrameName(prop.icon,showInfoHandler)
       end

        --local mIcon=LuaCCSprite:createWithSpriteFrameName(prop.icon,showInfoHandler)
        mIcon:setAnchorPoint(ccp(0,0.5))
        mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2-25))
        headerSprie:addChild(mIcon)
        mIcon:setTouchPriority(-(self.layerNum-1)*20-3);
        G_addRectFlicker(mIcon,1.4,1.4)

        local titleLb=GetTTFLabelWrap(getlocal(prop.name).."("..getlocal("scheduleChapter",{count,maxCount})..")",25,CCSizeMake(titleBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setPosition(ccp(20,titleBg:getContentSize().height/2))
        titleBg:addChild(titleLb,5)
        titleLb:setColor(G_ColorGreen)

        local descLabel=GetTTFLabelWrap(getlocal(prop.description),txtSize,CCSizeMake(280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLabel:setAnchorPoint(ccp(0,0.5))
        descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2-25))
        headerSprie:addChild(descLabel,5)
        
        local propCurrentPrice = math.ceil(prop.gemCost * propDiscount.dis)

	    local function onClick(tag,object)
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
	            acPreparingPeakVoApi:addBuyNum(propDiscount.id, 1)
	            self.tv:reloadData()
	          end              

	        end
	        socketHelper:buyProc(tag,callbackBuyprop,1, "preparingPeak")
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

        local confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClick,tonumber(prop.sid),getlocal("buy"),25)
        confirmBtn=CCMenu:createWithItem(confirmItem)
        confirmBtn:setAnchorPoint(ccp(0.5,0))
        confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2-10,50))
        confirmBtn:setTouchPriority(-(self.layerNum-1)*20-3)
        headerSprie:addChild(confirmBtn)

	    -- 金币图标
	    local originalIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
	    originalIcon:setAnchorPoint(ccp(0,0))
	    originalIcon:setPosition(ccp(headerSprie:getContentSize().width-60,headerSprie:getContentSize().height/2+15));
	    headerSprie:addChild(originalIcon,5)

	    -- 原价
	    local originalPriceLabel = GetTTFLabel(tostring(prop.gemCost),25)
	    originalPriceLabel:setAnchorPoint(ccp(1,0))
	    originalPriceLabel:setPosition(ccp(headerSprie:getContentSize().width-70, headerSprie:getContentSize().height/2+15))
	    headerSprie:addChild(originalPriceLabel,6)


	    local line = CCSprite:createWithSpriteFrameName("redline.jpg")
	    line:setScaleX((originalPriceLabel:getContentSize().width  + 50) / line:getContentSize().width)
	    line:setAnchorPoint(ccp(1, 0))
	    line:setPosition(ccp(headerSprie:getContentSize().width-35,headerSprie:getContentSize().height/2+25))
	    headerSprie:addChild(line,7)

	    local priceIconX = 170 + originalPriceLabel:getContentSize().width
	    -- 金币图标
	    local pricelIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
        pricelIcon:setAnchorPoint(ccp(0,0))
	    pricelIcon:setPosition(ccp(headerSprie:getContentSize().width-60,headerSprie:getContentSize().height/2-15));
	    headerSprie:addChild(pricelIcon,8)

	    -- 现价
	    local priceLabel = GetTTFLabel(tostring(propCurrentPrice),25)
	    priceLabel:setAnchorPoint(ccp(1,0))
	    priceLabel:setPosition(ccp(headerSprie:getContentSize().width-70, headerSprie:getContentSize().height/2-15))
	    headerSprie:addChild(priceLabel,9)

	    if playerVo.gems<tonumber(propCurrentPrice) then
	    	priceLabel:setColor(G_ColorRed)
	    else
	    	priceLabel:setColor(G_ColorYellow)
	    	
	    end
	    if count >= maxCount then
    		confirmItem:setEnabled(false)
    	else
    		confirmItem:setEnabled(true)
    	end
        return cell

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acPreparingPeakDialog:tick()
    if self.isToday ~= acPreparingPeakVoApi:isToday() then
        acPreparingPeakVoApi:updateBuyData()
        if self and self.tv then
            self.tv:reloadData()
        end
    end
    if self.timeLb then
        local acVo = acPreparingPeakVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acPreparingPeakDialog:update()
    local acVo = acPreparingPeakVoApi:getAcVo()
    if acVo ~= nil then
        if activityVoApi:isStart(acVo) == false and self ~= nil then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        end
    end
end

function acPreparingPeakDialog:dispose()
	 self.isToday=nil
    self.normalHeight=nil
    self.props=nil
    self=nil
end
