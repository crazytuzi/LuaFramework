acFyssSmallDialog=smallDialog:new()

function acFyssSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.layerNum = nil
	nc.bgSize = nil
	return nc
end

function acFyssSmallDialog:showGiving(layerNum,titleStr,acTab1)
	local sd = acFyssSmallDialog:new()
	sd:initGivingUI(layerNum,titleStr,acTab1)
	return sd
end

function acFyssSmallDialog:initGivingUI(layerNum,titleStr,acTab1)
	self.layerNum = layerNum

	self.bgSize=CCSizeMake(560,750)

	local fontSize = 32
    local function close()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(self.bgSize,titleStr,fontSize,nil,layerNum,true,close,nil)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(self.bgLayer,2)

    -- 点击阴影区域关闭面板
    local function touchBackSpFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- return self:close()
    end
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchBackSpFunc)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(touchDialogBg,1)




    local bgLayerL=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
    local bgLayerR=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
    bgLayerL:setOpacity(0)
    bgLayerR:setOpacity(0)
    bgLayerL:setContentSize(self.bgSize)
    bgLayerR:setContentSize(self.bgSize)
    bgLayerL:setAnchorPoint(ccp(0.5,0.5))
    bgLayerR:setAnchorPoint(ccp(0.5,0.5))
    bgLayerL:setIsSallow(true)
    bgLayerR:setIsSallow(true)
    bgLayerL:setPosition(self.bgSize.width/2,self.bgSize.height/2)
    bgLayerR:setPosition(self.bgSize.width/2,self.bgSize.height/2)
    self.bgLayer:addChild(bgLayerL)
    self.bgLayer:addChild(bgLayerR)

    local detailsData={}
    local noDetailsLb
    local detailsTv

    local allTabs={}
    local function touchTabBtn(_idx)
    	if _idx==1 then
    		if playerVoApi:getPlayerLevel() < acFyssVoApi:getGiveUpLevel() then
	            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_fyss_givingLimitTip",{acFyssVoApi:getGiveUpLevel()}),30)
	            do return end
	        end
    	end
    	for k,v in pairs(allTabs) do
	        if v:getTag()==_idx then
	           v:setEnabled(false)
	        else
	           v:setEnabled(true)
	        end
	    end
	    if _idx==1 then
	    	bgLayerR:setVisible(false)
	    	bgLayerR:setPosition(99999,99999)
	    	bgLayerL:setVisible(true)
	    	bgLayerL:setPosition(self.bgSize.width/2,self.bgSize.height/2)
	    else
	    	socketHelper:acFyssRequest({3},function(fn,data)
	            local ret,sData=base:checkServerData(data)
	            if ret==true then
	            	if sData and sData.data and sData.data.record then
	            		detailsData=sData.data.record

	            		--只显示接受的记录
	            		local _tempTab={}
	            		for k, v in pairs(detailsData) do
	            			if v[1]==2 then
	            				table.insert(_tempTab,v)
	            			end
	            		end
	            		detailsData=_tempTab

	            	end
	            	acFyssVoApi:updateFlag()
	            	if SizeOfTable(detailsData)==0 then
	            		noDetailsLb:setVisible(true)
	            	else
	            		noDetailsLb:setVisible(false)
	            	end
	            	detailsTv:reloadData()
	            end
	        end)
	    	bgLayerL:setVisible(false)
	    	bgLayerL:setPosition(99999,99999)
	    	bgLayerR:setVisible(true)
	    	bgLayerR:setPosition(self.bgSize.width/2,self.bgSize.height/2)
	    end
    end
    local tabBtnL = CCMenuItemImage:create("page_dark.png", "page_light.png","page_light.png")
    local tabBtnR = CCMenuItemImage:create("page_dark.png", "page_light.png","page_light.png")
    tabBtnL:setTag(1)
    tabBtnR:setTag(2)
    tabBtnL:registerScriptTapHandler(touchTabBtn)
    tabBtnR:registerScriptTapHandler(touchTabBtn)
    allTabs[1]=tabBtnL
    allTabs[2]=tabBtnR
    local menuL = CCMenu:createWithItem(tabBtnL)
    local menuR = CCMenu:createWithItem(tabBtnR)
    menuL:setTouchPriority(-(self.layerNum-1)*20-5)
    menuR:setTouchPriority(-(self.layerNum-1)*20-5)
    menuL:setPosition(self.bgSize.width/2-tabBtnL:getContentSize().width/2-2,self.bgSize.height-107)
    menuR:setPosition(self.bgSize.width/2+tabBtnR:getContentSize().width/2+2,self.bgSize.height-107)
    self.bgLayer:addChild(menuL)
    self.bgLayer:addChild(menuR)
    local tabBtnLbL = GetTTFLabel(getlocal("rechargeGifts_giveLabel"),24,true)
    local tabBtnLbR = GetTTFLabel(getlocal("serverwar_point_record"),24,true)
    tabBtnLbL:setPosition(menuL:getPosition())
    tabBtnLbR:setPosition(menuR:getPosition())
    self.bgLayer:addChild(tabBtnLbL)
    self.bgLayer:addChild(tabBtnLbR)

    if playerVoApi:getPlayerLevel() < acFyssVoApi:getGiveUpLevel() then
        touchTabBtn(2)
    else
    	touchTabBtn(1)
    end



    local detailsBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    detailsBg:setContentSize(CCSizeMake(self.bgSize.width-30,self.bgSize.height-160))
    detailsBg:setAnchorPoint(ccp(0.5,1))
    detailsBg:setPosition(self.bgSize.width/2,self.bgSize.height-140)
    bgLayerR:addChild(detailsBg)

    noDetailsLb=GetTTFLabel(getlocal("activity_fyss_noGiveDetails"),24)
	noDetailsLb:setPosition(detailsBg:getContentSize().width/2,detailsBg:getContentSize().height/2)
	noDetailsLb:setColor(G_ColorGray)
	detailsBg:addChild(noDetailsLb)

	local timeLb=GetTTFLabel(getlocal("alliance_event_time"),20)
    timeLb:setPosition(80,detailsBg:getContentSize().height-20)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    detailsBg:addChild(timeLb,2)
    timeLb:setColor(G_ColorYellowPro)

    local eventLb=GetTTFLabel(getlocal("alliance_event_event"),20)
    eventLb:setPosition(340,detailsBg:getContentSize().height-20)
    eventLb:setAnchorPoint(ccp(0.5,0.5))
    detailsBg:addChild(eventLb,2)
    eventLb:setColor(G_ColorYellowPro)

    local detailsTvSize=CCSizeMake(detailsBg:getContentSize().width,eventLb:getPositionY()-20)
    local function tvCallBack(handler,fn,index,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(detailsData)
        elseif fn=="tableCellSizeForIndex" then
        	local _data = detailsData[index+1]
        	local _name = _data[2] --接收/送出的好友名称
	        local _item = _data[3] --道具的key值(props_p5001)
	        local _propName = getlocal(propCfg[Split(_item,"_")[2]].name)
	        local _msgStr = getlocal("activity_fyss_detailsText",{_name,_propName})
        	local msgLb = GetTTFLabelWrap(_msgStr,20,CCSizeMake(detailsTvSize.width-10*2-100-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            return  CCSizeMake(detailsTvSize.width,msgLb:getContentSize().height+10)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local _data = detailsData[index+1]
            local _type = _data[1] --1:赠送,2:收到
	        local _name = _data[2] --接收/送出的好友名称
	        local _item = _data[3] --道具的key值(props_p5001)
	        local _time = _data[4] --时间戳

	        local _propName = getlocal(propCfg[Split(_item,"_")[2]].name)
	        local _msgStr = getlocal("activity_fyss_detailsText",{_name,_propName})
        	local msgLb = GetTTFLabelWrap(_msgStr,20,CCSizeMake(detailsTvSize.width-10*2-100-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)

            local cellW,cellH=detailsTvSize.width,msgLb:getContentSize().height+10

            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
	        lineSp:setContentSize(CCSizeMake(cellW-18, 2))
	        lineSp:ignoreAnchorPointForPosition(false)
	        lineSp:setAnchorPoint(ccp(0.5,1))
	        lineSp:setPosition(cellW/2,cellH)
	        cell:addChild(lineSp)

	        if index+1==SizeOfTable(detailsData) then
	        	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
		        lineSp:setContentSize(CCSizeMake(cellW-18, 2))
		        lineSp:ignoreAnchorPointForPosition(false)
		        lineSp:setAnchorPoint(ccp(0.5,0))
		        lineSp:setPosition(cellW/2,0)
		        cell:addChild(lineSp)
	    	end

	        local timeLabel=GetTTFLabel(G_getDataTimeStr(_time),20)
	        timeLabel:setAnchorPoint(ccp(0,0.5))
	        timeLabel:setPosition(ccp(10,cellH/2))
	        cell:addChild(timeLabel,1)

	        -- local _propName = getlocal(propCfg[Split(_item,"_")[2]].name)
	        -- local _msgStr = getlocal("activity_fyss_detailsText",{_name,_propName})
	        -- local msgLb = GetTTFLabelWrap(_msgStr,20,CCSizeMake(cellW-timeLabel:getPositionX()*2-timeLabel:getContentSize().width-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	        msgLb:setAnchorPoint(ccp(0,0.5))
	        msgLb:setPosition(timeLabel:getPositionX()+timeLabel:getContentSize().width+30,cellH/2)
	        cell:addChild(msgLb)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then
        end
    end
    local detailsHd=LuaEventHandler:createHandler(tvCallBack)
    detailsTv=LuaCCTableView:createWithEventHandler(detailsHd,detailsTvSize,nil)
    detailsTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    detailsTv:setMaxDisToBottomOrTop(100)
    detailsBg:addChild(detailsTv)


    ------------------------------------ 赠送 -----------------------------

    --[[
    -- 标题
    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0.5))
    lightSp:setScaleX(3)
    lightSp:setPosition(self.bgLayer:getContentSize().width/2,self.bgSize.height-100)
    self.bgLayer:addChild(lightSp)

    local nameLb=GetTTFLabel(getlocal("activity_chrisEve_chooseGift"),22,true)
    nameLb:setAnchorPoint(ccp(0.5,0.5))
    nameLb:setPosition(self.bgSize.width/2,self.bgSize.height-95)
    self.bgLayer:addChild(nameLb)
    local realNameW=nameLb:getContentSize().width
    for i=1,2 do
        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
        local anchorX=1
        local posX=self.bgSize.width/2-(realNameW/2+20)
        local pointX=-7
        if i==2 then
            anchorX=0
            posX=self.bgSize.width/2+(realNameW/2+20)
            pointX=15
        end
        pointSp:setAnchorPoint(ccp(anchorX,0.5))
        pointSp:setPosition(posX,nameLb:getPositionY())
        self.bgLayer:addChild(pointSp)

        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0,0.5))
        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
        pointSp:addChild(pointLineSp)
        if i==1 then
            pointLineSp:setRotation(180)
        end
    end
    --]]

    local topBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    topBg:setContentSize(CCSizeMake(self.bgSize.width-30,120))
    topBg:setAnchorPoint(ccp(0.5,1))
    -- topBg:setPosition(self.bgSize.width/2,lightSp:getPositionY()-lightSp:getContentSize().height*lightSp:getScaleY()/2)
    topBg:setPosition(self.bgSize.width/2,self.bgSize.height-140)
    -- self.bgLayer:addChild(topBg)
    bgLayerL:addChild(topBg)

    local friendsTb
    local itemData = acFyssVoApi:getItemData()
    local curSelectedPropIndex
    local propBgTab={}
    local tv
    local function propCallback(object,fn,tag)
    	if object and fn then
			if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
    	end
        PlayEffect(audioCfg.mouseClick)

        -- local num = acFyssVoApi:getItemByNum(itemData[tag].key)
        -- if num <=0 then
        -- 	do return end
        -- end
		for k,v in pairs(propBgTab) do
			if tag==v:getTag() then
				v:getChildByTag(1001):setVisible(true)
			else
				v:getChildByTag(1001):setVisible(false)
			end
		end
		curSelectedPropIndex=tag
		friendsTb = acFyssVoApi:getFriendTb(itemData[curSelectedPropIndex].key)
		tv:reloadData()
	end
	for i, v in pairs(itemData) do
		local num = acFyssVoApi:getItemByNum(v.key)
		local propBg=LuaCCSprite:createWithSpriteFrameName("acFyss_propBg.png",propCallback)
		propBg:setPosition(topBg:getContentSize().width/6*i+(i-3)*12,topBg:getContentSize().height/2)
		propBg:setTouchPriority(-(self.layerNum-1)*20-5)
		propBg:setScale(90/propBg:getContentSize().width)
		propBg:setTag(i)
		topBg:addChild(propBg)
		local propSp=CCSprite:createWithSpriteFrameName(propCfg[v.key].icon)
		propSp:setPosition(propBg:getContentSize().width/2,propBg:getContentSize().height/2)
		propBg:addChild(propSp)
		local shadeSp=CCSprite:createWithSpriteFrameName("acFyss_propShade.png")
		shadeSp:setPosition(propBg:getContentSize().width/2,propBg:getContentSize().height/2)
		shadeSp:setTag(1003)
		shadeSp:setVisible(true)
		propBg:addChild(shadeSp)
		local selectedSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
		selectedSp:setContentSize(CCSizeMake(propBg:getContentSize().width+5,propBg:getContentSize().height+10))
		selectedSp:setPosition(propBg:getContentSize().width/2,propBg:getContentSize().height/2)
		selectedSp:setVisible(false)
		selectedSp:setTag(1001)
		propBg:addChild(selectedSp,2)
		local numLb=GetTTFLabel("x"..num,20)
		numLb:setAnchorPoint(ccp(1,0))
		numLb:setPosition(propBg:getContentSize().width-10,5)
		numLb:setTag(1002)
		propBg:addChild(numLb,3)
		propBgTab[i]=propBg
		if num>0 then
			shadeSp:setVisible(false)
			if curSelectedPropIndex==nil then
				curSelectedPropIndex=i
				selectedSp:setVisible(true)
			end
		end
	end

	local numStr=getlocal("activity_fyss_giveUpNum",{acFyssVoApi:getGiveUpCount(),acFyssVoApi:getMaxGiveUpCount()})
	local giveUpNumLb=GetTTFLabel(numStr,20)
	giveUpNumLb:setAnchorPoint(ccp(1,1))
	giveUpNumLb:setPosition(topBg:getPositionX()+topBg:getContentSize().width/2,topBg:getPositionY()-topBg:getContentSize().height-5)
	-- self.bgLayer:addChild(giveUpNumLb)
	bgLayerL:addChild(giveUpNumLb)

	-- 标题
    local lightSp1=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp1:setAnchorPoint(ccp(0.5,0.5))
    lightSp1:setScaleX(3)
    lightSp1:setPosition(self.bgSize.width/2,giveUpNumLb:getPositionY()-50)
    -- self.bgLayer:addChild(lightSp1)
    bgLayerL:addChild(lightSp1)

    local nameLb1=GetTTFLabel(getlocal("activity_peijianhuzeng_selectFriend"),22,true)
    nameLb1:setAnchorPoint(ccp(0.5,0.5))
    nameLb1:setPosition(self.bgSize.width/2,lightSp1:getPositionY()+5)
    -- self.bgLayer:addChild(nameLb1)
    bgLayerL:addChild(nameLb1)
    local realNameW1=nameLb1:getContentSize().width
    for i=1,2 do
        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
        local anchorX=1
        local posX=self.bgSize.width/2-(realNameW1/2+20)
        local pointX=-7
        if i==2 then
            anchorX=0
            posX=self.bgSize.width/2+(realNameW1/2+20)
            pointX=15
        end
        pointSp:setAnchorPoint(ccp(anchorX,0.5))
        pointSp:setPosition(posX,nameLb1:getPositionY())
        -- self.bgLayer:addChild(pointSp)
        bgLayerL:addChild(pointSp)

        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0,0.5))
        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
        pointSp:addChild(pointLineSp)
        if i==1 then
            pointLineSp:setRotation(180)
        end
    end

    local bomBgPosY = lightSp1:getPositionY()-lightSp1:getContentSize().height*lightSp1:getScaleY()/2-5
    local bomBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    bomBg:setContentSize(CCSizeMake(self.bgSize.width-30,bomBgPosY-20))
    bomBg:setAnchorPoint(ccp(0.5,1))
    bomBg:setPosition(self.bgSize.width/2,bomBgPosY)
    -- self.bgLayer:addChild(bomBg)
    bgLayerL:addChild(bomBg)

    local nameLb=GetTTFLabel(getlocal("alliance_scene_button_info_name"),20)
    local lvLb=GetTTFLabel(getlocal("RankScene_level"),20)
    local stateLb=GetTTFLabel(getlocal("state"),20)
    nameLb:setColor(G_ColorYellowPro)
    lvLb:setColor(G_ColorYellowPro)
    stateLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(bomBg:getContentSize().width/4-30,bomBg:getContentSize().height-20)
    lvLb:setPosition(bomBg:getContentSize().width/2,bomBg:getContentSize().height-20)
    stateLb:setPosition(bomBg:getContentSize().width/4*3+30,bomBg:getContentSize().height-20)
    bomBg:addChild(nameLb)
    bomBg:addChild(lvLb)
    bomBg:addChild(stateLb)

    if curSelectedPropIndex==nil then
    	curSelectedPropIndex=1
    end
    friendsTb = acFyssVoApi:getFriendTb(itemData[curSelectedPropIndex].key)

    local function refreshUI()
    	local _selectedItem = propBgTab[curSelectedPropIndex]
    	local selectedSp = _selectedItem:getChildByTag(1001)
    	local numLb = _selectedItem:getChildByTag(1002)
    	local shadeSp = _selectedItem:getChildByTag(1003)
    	numLb = tolua.cast(numLb,"CCLabelTTF")
    	shadeSp = tolua.cast(shadeSp,"CCSprite")
		local num = acFyssVoApi:getItemByNum(itemData[curSelectedPropIndex].key)
		numLb:setString("x"..num)
		giveUpNumLb:setString(getlocal("activity_fyss_giveUpNum",{acFyssVoApi:getGiveUpCount(),acFyssVoApi:getMaxGiveUpCount()}))
		if num<=0 then
			acFyssVoApi:updateShow()
			shadeSp:setVisible(true)
			selectedSp:setVisible(false)
			for k,v in pairs(propBgTab) do
				if k~=curSelectedPropIndex then
					if acFyssVoApi:getItemByNum(itemData[k].key)>0 then
						propCallback(nil,nil,k)
						break
					end
				end
			end
		else
			friendsTb = acFyssVoApi:getFriendTb(itemData[curSelectedPropIndex].key)
			tv:reloadData()
		end
		if acFyssVoApi:getItemTotalNum() == 0 then
			self:close()
		else
			acFyssVoApi:addSub1Effect(_selectedItem,ccp(_selectedItem:getContentSize().width-10,35))
		end
    end

    if SizeOfTable(friendsTb)==0 then
    	local noLabel=GetTTFLabel(getlocal("noFriends"),24)
    	noLabel:setPosition(bomBg:getContentSize().width/2,bomBg:getContentSize().height/2)
    	noLabel:setColor(G_ColorGray)
    	bomBg:addChild(noLabel)
	end

    local tvSize=CCSizeMake(bomBg:getContentSize().width,lvLb:getPositionY()-20)
    local function tvCallBack(handler,fn,index,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(friendsTb)
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvSize.width,65)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local cellW,cellH=tvSize.width,65

        	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
	        lineSp:setContentSize(CCSizeMake(cellW-18, 2))
	        lineSp:ignoreAnchorPointForPosition(false)
	        lineSp:setAnchorPoint(ccp(0.5,1))
	        lineSp:setPosition(cellW/2,cellH)
	        cell:addChild(lineSp)

	        if index+1==SizeOfTable(friendsTb) then
	        	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
		        lineSp:setContentSize(CCSizeMake(cellW-18, 2))
		        lineSp:ignoreAnchorPointForPosition(false)
		        lineSp:setAnchorPoint(ccp(0.5,0))
		        lineSp:setPosition(cellW/2,0)
		        cell:addChild(lineSp)
	    	end

	        local _data = friendsTb[index+1]
	        local nameStr=_data.nickname
	        local levelStr=_data.level
	        local uid=_data.uid
	        local curSelectedPropKey=itemData[curSelectedPropIndex].key

	        local nameLabel = GetTTFLabel(nameStr,20)
	        nameLabel:setPosition(nameLb:getPositionX(),cellH/2)
	        cell:addChild(nameLabel)

	        local levelLabel = GetTTFLabel(tostring(levelStr),20)
	        levelLabel:setPosition(lvLb:getPositionX(),cellH/2)
	        cell:addChild(levelLabel)

	        if acFyssVoApi:isGiving(uid,curSelectedPropKey) then
	        	local lb = GetTTFLabel(getlocal("alien_tech_alreadySend"),20)
	        	lb:setPosition(stateLb:getPositionX(),cellH/2)
	        	lb:setColor(G_ColorGray)
	        	cell:addChild(lb)
	        else
		        local function giveUpHandler()
			        if G_checkClickEnable()==false then
			            do return end
			        else
			            base.setWaitTime=G_getCurDeviceMillTime()
			        end
			        PlayEffect(audioCfg.mouseClick)

			        if acFyssVoApi:getGiveUpCount() >= acFyssVoApi:getMaxGiveUpCount() then
	                	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_fyss_noGivingNum"),30)
	                	do return end
	                end

	                if acFyssVoApi:getItemByNum(curSelectedPropKey) <= 0 then
	                	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_fyss_noItem"),30)
	                	do return end
	                end
			        
			        local function onRequestCallback(fn,data)
	                    local ret,sData=base:checkServerData(data)
	                    if ret==true then
	                    	acFyssVoApi:updateGivingTab(uid,curSelectedPropKey)
	                        if sData and sData.data and sData.data.fuyunshuangshou and sData.data.fuyunshuangshou.words then
	                            acFyssVoApi:setItem(sData.data.fuyunshuangshou.words)
	                        end
	                        acFyssVoApi:setGiveUpCount(acFyssVoApi:getGiveUpCount()+1)
	                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_send_success"),30)
                        	refreshUI()
	                        if acTab1 then
	                        	acTab1:refreshUI()
	                        end
	                    end
	                end
			        socketHelper:acFyssRequest({2,uid,"props_"..curSelectedPropKey},onRequestCallback)
			    end
			    local giveUpBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",giveUpHandler,11)
			    giveUpBtn:setScale(0.6)
			    giveUpBtn:setAnchorPoint(ccp(0.5,0.5))
			    local menu=CCMenu:createWithItem(giveUpBtn)
			    menu:setTouchPriority(-(self.layerNum-1)*20-4)
			    menu:setPosition(ccp(stateLb:getPositionX(),cellH/2))
			    cell:addChild(menu)
			    local btnLb=GetTTFLabel(getlocal("rechargeGifts_giveLabel"),24,true)
			    btnLb:setPosition(menu:getPosition())
			    cell:addChild(btnLb)
			end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    tv=LuaCCTableView:createWithEventHandler(hd,tvSize,nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    tv:setMaxDisToBottomOrTop(100)
    bomBg:addChild(tv)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
end