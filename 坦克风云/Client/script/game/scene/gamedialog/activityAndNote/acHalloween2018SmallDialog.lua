acHalloween2018SmallDialog=smallDialog:new()

function acHalloween2018SmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.reward={}
	self.dialogHeight=470
	self.dialogWidth=550
	-- self.pageCellNum=10
	self.cellHeight=120
	return nc
end

function acHalloween2018SmallDialog:init(index,layerNum,callback)
	self.index=index
	self.layerNum=layerNum
	local function nilFunc()
	end
	-- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()

	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgSize=size
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
	lineSp1:setAnchorPoint(ccp(0.5,1))
	lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
	self.bgLayer:addChild(lineSp1)
	local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
	lineSp2:setAnchorPoint(ccp(0.5,0))
	lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
	self.bgLayer:addChild(lineSp2)
	lineSp2:setRotation(180)

	-- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
 --    pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
 --    self.bgLayer:addChild(pointSp1)
 --    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
 --    pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
 --    self.bgLayer:addChild(pointSp2)
	
	local rCfg = acHalloween2018VoApi:getboxAwardTb(index)

	local lbSize2 = 30
	if G_getCurChoseLanguage() =="ko" then
		lbSize2 =25
	end
	local curNum,canNum = acHalloween2018VoApi:getUseNum(index)
	local titleLb=GetTTFLabelWrap(getlocal("otherAward",{canNum}),lbSize2,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-30))
	dialogBg:addChild(titleLb,1)
	titleLb:setColor(G_ColorYellowPro2)
	local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0))
    lightSp:setOpacity(150)
    lightSp:setPosition(self.bgLayer:getContentSize().width/2,size.height-titleLb:getContentSize().height-50)
    lightSp:setScaleX(3.5)
    lightSp:setScaleY(2)
    self.bgLayer:addChild(lightSp)

	-- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	-- lineSp:setScale((size.width-100)/lineSp:getContentSize().width)
	-- lineSp:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-50))
	-- self.bgLayer:addChild(lineSp)

	local cellWidth=self.bgLayer:getContentSize().width
	local rewardTb=FormatItem(rCfg,false,true)

	local function tvCallBack(handler,fn,idx,cel)
	    if fn=="numberOfCellsInTableView" then
	        return SizeOfTable(rewardTb)
	    elseif fn=="tableCellSizeForIndex" then
	        local tmpSize=CCSizeMake(cellWidth,self.cellHeight)
	        return tmpSize
	    elseif fn=="tableCellAtIndex" then
	        local cell=CCTableViewCell:new()
	        cell:autorelease()

	        local cellHeight=self.cellHeight
	        local item=rewardTb[idx+1]
	        if item then
	            local sp,scale=G_getItemIcon(item,100)
	            sp:setPosition(ccp(105,cellHeight/2))
	            cell:addChild(sp,1)
	            local nameLb=GetTTFLabel(item.name,25)
	            nameLb:setAnchorPoint(ccp(0,0.5))
	            nameLb:setPosition(ccp(180,cellHeight/2+35))
	            cell:addChild(nameLb,1)
	            local num=item.num
	            if item and item.type=="h" and item.eType=="h" then
	            	num=1
	            end
	            local numLb=GetTTFLabel(getlocal("propInfoNum",{num}),25)
	            numLb:setAnchorPoint(ccp(0,0.5))
	            numLb:setPosition(ccp(180,cellHeight/2-35))
	            cell:addChild(numLb,1)
	        end
	        if idx + 1 ~= SizeOfTable(rewardTb) then
	        	local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
			    bottomLine:setContentSize(CCSizeMake(cellWidth - 100, bottomLine:getContentSize().height))
			    bottomLine:setPosition(ccp(cellWidth * 0.5,0))
			    cell:addChild(bottomLine)
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
	local hd= LuaEventHandler:createHandler(tvCallBack)
	local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,size.height-titleLb:getContentSize().height-180),nil)
	tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
	tv:setPosition(ccp(0,120))
	self.bgLayer:addChild(tv,2)
	tv:setMaxDisToBottomOrTop(120)

	local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(cellWidth - 80,size.height-titleLb:getContentSize().height-160))
    dialogBg2:setAnchorPoint(ccp(0.5,0))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width * 0.5,110)
    self.bgLayer:addChild(dialogBg2,3)

    local noData,noData,canGet = acHalloween2018VoApi:getUseNum(self.index)
    if acHalloween2018VoApi:getedAwardBoxTb(self.index) then
    	canGet = false
    end

    local function rewardHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		if canGet then
				local function rewardCallback(fn,data)
					local ret,sData=base:checkServerData(data)
	        		if ret==true then
	        			if sData.data then
	        				if sData.data.wsj2018 then
								acHalloween2018VoApi:updateData(sData.data.wsj2018)
							end
	        			end
						for k,v in pairs(rewardTb) do
							print("k--v-->>",k,v.key,v.type,v.id,v.num)
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
						G_showRewardTip(rewardTb,true)
						self:close()
						if callback then
							callback()
						end
	        		end
	        	end
				
				socketHelper:acHalloween2018Request("active.wsj2018.reward",{tid=self.index},rewardCallback)
		else
			self:close()
		end
		
    end
	local acPoint=taskVoApi:getAcPoint()
	local isReward=taskVoApi:acPointIsReward(self.index)
	local itemStr=getlocal("ok")
	if canGet then
		itemStr=getlocal("daily_scene_get")
	end
    local rewardItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",rewardHandler,11,itemStr,30)
    rewardItem:setScale(0.85)
    local rewardMenu=CCMenu:createWithItem(rewardItem)
    rewardMenu:setPosition(ccp(size.width/2,50))
    rewardMenu:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(rewardMenu)


	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end
