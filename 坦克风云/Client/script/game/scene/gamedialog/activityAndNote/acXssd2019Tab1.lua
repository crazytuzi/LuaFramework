acXssd2019Tab1={
}

function acXssd2019Tab1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.state = 0 

    return nc;
end

function acXssd2019Tab1:init( parent )
	self.bgLayer=CCLayer:create()
    self.parent=parent

    self.overDayEventListener = function()
        self:initUp()
    end
    if eventDispatcher:hasEventHandler("overADay", self.overDayEventListener) == false then
		eventDispatcher:addEventListener("overADay", self.overDayEventListener)
 	end

 	local titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function () end)
 	titleBg1:setContentSize(CCSizeMake(G_VisibleSizeWidth,50))
 	titleBg1:setAnchorPoint(ccp(0,1))
 	titleBg1:setPosition(ccp(0,G_VisibleSizeHeight-160))
 	self.bgLayer:addChild(titleBg1)
 	local titleLb1 = GetTTFLabel(getlocal("activity_xssd2019_title1"),25,true)
 	titleLb1:setAnchorPoint(ccp(0.5,0.5))
 	titleLb1:setPosition(ccp(G_VisibleSizeWidth/2,titleBg1:getContentSize().height/2))
 	titleLb1:setColor(G_ColorYellowPro)
 	titleBg1:addChild(titleLb1)

 	--I里的信息
    local function touchTip()
		local tabStr={getlocal("activity_xssd2019_tab1_info1"),getlocal("activity_xssd2019_tab1_info2"),getlocal("activity_xssd2019_tab1_info3")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+5,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum+1,ccp(G_VisibleSizeWidth - 30,G_VisibleSizeHeight-185),{},nil,0.7,28,touchTip,true)

	--活动时间
 	local acTimeLb1=GetTTFLabel(acXssd2019VoApi:getTimeStr2(),21,true)
	acTimeLb1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-225))
	-- acTimeLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(acTimeLb1)
	self.acTimeLb1=acTimeLb1

	--本服悬赏奖励刷新
	self:initUp()

	local downSpire = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	downSpire:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,acTimeLb1:getPositionY()-215-30))
	downSpire:setAnchorPoint(ccp(0.5,0))
	downSpire:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.bgLayer:addChild(downSpire)

	--个人悬赏刷新
	self:initMiddle()

	--悬赏任务刷新
	self:initDown()

	local task2PReward=acXssd2019VoApi:recieveReward()

	return self.bgLayer
end

function acXssd2019Tab1:refresh(isByCrossDays)
	if isByCrossDays then
		self:showLastDayRewardGetTipShow()
	end
	self:initUp()
	self:initMiddle()
end

function acXssd2019Tab1:showLastDayRewardGetTipShow( )
	if not acXssd2019VoApi:ifPreAllReward( ) then--activity_xssd2019_tab1_lastDayRewardStr
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_xssd2019_tab1_lastDayRewardStr"),nil,self.layerNum + 10)
		do return end
	end
end

function acXssd2019Tab1:initUp( ... )
	if self.node1 then
		self.node1:removeFromParentAndCleanup(true)
		self.node1=nil
	end
	self.node1 = CCNode:create()
	self.bgLayer:addChild(self.node1,2)

	--任务描述
	local itemBg = CCSprite:createWithSpriteFrameName("xssd2019_titleBg.png")
    itemBg:setAnchorPoint(ccp(0,1))
    itemBg:setPosition(ccp(0,self.acTimeLb1:getPositionY()-self.acTimeLb1:getContentSize().height+5))
    self.node1:addChild(itemBg)

    local itemFontSize = 16
    if G_isAsia() then
    	itemFontSize = 21
    end
    local itemStr,isLastDayUse = acXssd2019VoApi:allRewardDes()
    local itemLb=GetTTFLabel(itemStr,itemFontSize)
	itemLb:setPosition(ccp(15+itemLb:getContentSize().width/2,itemBg:getContentSize().height/2))	
	itemLb:setColor(isLastDayUse and G_ColorGray or G_ColorYellowPro)
	itemBg:addChild(itemLb)

	--宝箱底
	local boxBg = CCSprite:createWithSpriteFrameName("boxBg_xssd2019.png")
	boxBg:setAnchorPoint(ccp(0,1))
	boxBg:setPosition(ccp(0 , itemBg:getPositionY()-itemBg:getContentSize().height-40))
	self.node1:addChild(boxBg)

	local boxPicNameTb = {
		{"ironBox_xssd2019.png","ironBoxBg_xssd2019.png"},
		{"silverBox_xssd2019.png","silverBoxBg_xssd2019.png"},
		{"goldBox_xssd2019.png","goldBoxBg_xssd2019.png"},
	}

	local boxIcon
	for i=1,3 do
		--本服悬赏任务状态   1：不可领取   2：可领取   3：已领取  4:过期
		local state = acXssd2019VoApi:allRewardState( i )
		local nameStr1 = boxPicNameTb[i][1]
		local nameStr2 = boxPicNameTb[i][2]
		local allRewardTb = FormatItem(acXssd2019VoApi:allRewardShow( i ),nil,true)
		if state==3 or state==4 then
			boxIcon = GraySprite:createWithSpriteFrameName(boxPicNameTb[i][1])
			boxIcon:setAnchorPoint(ccp(0,0))
			boxIcon:setPosition(ccp( 15 + 230*(i-1) , boxBg:getContentSize().height/2))
			boxBg:addChild(boxIcon,3)

			local boxIconNumBg = GraySprite:createWithSpriteFrameName(nameStr2)
			boxIconNumBg:setAnchorPoint(ccp(0,1))
			boxIconNumBg:setPosition(ccp( 12 , boxBg:getContentSize().height/2-45))
			boxIcon:addChild(boxIconNumBg)

			local haveRecive = GetTTFLabel(getlocal("activity_hadReward"),itemFontSize)
			haveRecive:setAnchorPoint(ccp(0.5,1))
			haveRecive:setPosition(ccp(boxIconNumBg:getContentSize().width/2 , boxIconNumBg:getContentSize().height-1))
			boxIconNumBg:addChild(haveRecive)
		else
			--不可领取回调
			local function canNotReward( ... )
				PlayEffect(audioCfg.mouseClick)
		        if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        -- acXssd2019VoApi:redBagSceneGame()
		        local titleStr = getlocal("activity_xssd2019_boxName")
				require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
                local sd=acChunjiepanshengSmallDialog:new()
                sd:init(true,true,self.layerNum+1,titleStr,nil,CCSizeMake(500,350),CCRect(130, 50, 1, 1),allRewardTb,nil,nil,nil,true,"xssd2019")
	            do return end
			end

			--可领取回调
			local function canReward( ... )
				PlayEffect(audioCfg.mouseClick)
		        if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end

				local act = 1
				local tid = acXssd2019VoApi:taskDay()
				local dw = i

				local function refreshFunc( reward )
					if not self.parent:isClosed() then
						self:initUp()
						self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab1Reward(),1)
						self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab2Reward(),2)
						self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab3Reward(),3)
						if self.parent.acTab2 then
							self.parent.acTab2:initUp()
							self.parent.acTab2:initMiddle()
							if self.parent.acTab2.tv then
								local recordPoint = self.parent.acTab2.tv:getRecordPoint()
				                self.parent.acTab2.tv:reloadData()
				                self.parent.acTab2.tv:recoverToRecordPoint(recordPoint)
				            end
						end
						if self.parent.acTab3 then
							self.parent.acTab3:initMiddle()
							self.parent.acTab3:initDown()
						end
					end
					if reward then
		                G_showRewardTip(reward, true)
		            end
				end
				acXssd2019VoApi:socketXssd2019Task(act,tid,dw,refreshFunc)
	            do return end
			end

			local functionName
			if state==1 then
				functionName = canNotReward
			else
				functionName = canReward
			end
			boxIcon = CCSprite:createWithSpriteFrameName(boxPicNameTb[i][1])
			boxImage = GetButtonItem(nameStr1, nameStr1, nameStr1, functionName, nil, nil,1, 101)
            boxBtn = CCMenu:createWithItem(boxImage)
            boxBtn:setAnchorPoint(ccp(0,0))
            boxBtn:setPosition(ccp( 90 + 230*(i-1) , boxBg:getContentSize().height/2+40))
            boxBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            boxBg:addChild(boxBtn,3)
			--可领取加闪光特效
			if state==2 then
				local node = CCSprite:createWithSpriteFrameName(boxPicNameTb[i][1])
				node:setAnchorPoint(ccp(0,0))
				node:setPosition(ccp( 15 + 230*(i-1) , boxBg:getContentSize().height/2))
				node:setOpacity(0)
				boxBg:addChild(node,2)
				acXssd2019VoApi:rewardFlicker(node,boxImage,i)
			end

			local boxIconNumBg = CCSprite:createWithSpriteFrameName(nameStr2)
			boxIconNumBg:setAnchorPoint(ccp(0,1))
			boxIconNumBg:setPosition(ccp( 12 , boxBg:getContentSize().height/2-45))
			boxImage:addChild(boxIconNumBg)

			local boxIconNum = GetTTFLabel(acXssd2019VoApi:allRewardNum( i ),24)
			boxIconNum:setAnchorPoint(ccp(0.5,1))
			boxIconNum:setPosition(ccp(boxIconNumBg:getContentSize().width/2 , boxIconNumBg:getContentSize().height-1))
			boxIconNumBg:addChild(boxIconNum)
		end

	end
	
end

function acXssd2019Tab1:initMiddle( ... )
	if self.node2 then
		self.node2:removeFromParentAndCleanup(true)
		self.node2=nil
	end
	self.node2 = CCNode:create()
	self.bgLayer:addChild(self.node2,2)

	local fontSize2 = 20
	if G_isAsia() then
		fontSize2 = 24
	end

	local titleBg = G_createNewTitle({getlocal("activity_xssd2019_title2"), fontSize2, G_ColorYellowPro}, CCSizeMake(400, 0), nil, nil, "Helvetica-bold")
    titleBg:setPosition(ccp(G_VisibleSizeWidth/2,self.acTimeLb1:getPositionY()-260))
    self.node2:addChild(titleBg,1)

    local middleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesDesBg.png",CCRect(50,20,1,1),function () end)
	middleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30-6,150))
	-- middleBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.node2:addChild(middleBg)
	middleBg:setAnchorPoint(ccp(0.5,1))
	middleBg:setPosition(G_VisibleSizeWidth/2,titleBg:getPositionY()-10)

	local acTimeLb2 = GetTTFLabel(acXssd2019VoApi:getTimeStr1( ),21)
	acTimeLb2:setAnchorPoint(ccp(0.5,1))
	acTimeLb2:setPosition(ccp(middleBg:getContentSize().width/2,middleBg:getContentSize().height-10))
	middleBg:addChild(acTimeLb2)
	self.acTimeLb2=acTimeLb2

	local fontSize3 = 11
	if G_isAsia() then
		fontSize3 = 20
	end

	local integral = GetTTFLabel(getlocal("activity_xssd2019_recentLabelNum"),fontSize3,true)
	integral:setAnchorPoint(ccp(0,0))
	integral:setPosition(ccp(15,middleBg:getContentSize().height/2+4))
	middleBg:addChild(integral)

	local integralNum = GetTTFLabel(acXssd2019VoApi:integralPoint( ),fontSize3,true)
	integralNum:setAnchorPoint(ccp(0.5,1))
	integralNum:setPosition(ccp(integral:getContentSize().width/2,-5))
	integral:addChild(integralNum)

	self:initSlider()
end

function acXssd2019Tab1:initDown( ... )
	-- if self.node3 then
	-- 	self.node3:removeFromParentAndCleanup(true)
	-- 	self.node3=nil
	-- end
	-- self.node3 = CCNode:create()
	-- self.bgLayer:addChild(self.node3,2)

	local fontSize4 = 20
	if G_isAsia() then
		fontSize4 = 24
	end

	local titleBg = G_createNewTitle({getlocal("activity_xssd2019_title3"), fontSize4, G_ColorYellowPro}, CCSizeMake(400, 0), nil, nil, "Helvetica-bold")
    titleBg:setPosition(ccp(G_VisibleSizeWidth/2,self.acTimeLb1:getPositionY()-260-210))
    self.bgLayer:addChild(titleBg,1)


    self.cellNum = acXssd2019VoApi:selfRewardNum(  )
    self.cellHeight = 180
    self.tvWidth = G_VisibleSizeWidth-40
    self.tvHeight = titleBg:getPositionY()-50

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    
    local pos = ccp(15,30)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(pos)
    self.bgLayer:addChild(self.tv)

    --以下代码处理上下遮挡层
    local function forbidClick()
   
    end
    local capInSet = CCRect(20, 20, 10, 10);
    self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.topforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
    self.topforbidSp:setAnchorPoint(ccp(0,0))
    local topY
    local topHeight
    if(self.tv~=nil)then
        local tvX,tvY=self.tv:getPosition()
        topY=tvY+self.tv:getViewSize().height
        topHeight=G_VisibleSizeHeight-topY
    else
        topHeight=0
        topY=0
    end
    self.topforbidSp:setContentSize(CCSize(G_VisibleSizeWidth,topHeight))
    self.topforbidSp:setPosition(0,topY)
    self.bgLayer:addChild(self.topforbidSp)

    self:resetForbidLayer()
    self.topforbidSp:setVisible(false)

end

function acXssd2019Tab1:resetForbidLayer()
   if(self.tv~=nil)then
     local tvX,tvY=self.tv:getPosition()
   else
     -- 如果没有self.tv 将遮罩移出屏幕外防止干扰
     if self.topforbidSp then
        self.topforbidSp:setPosition(ccp(9999,0))
     end
   end
end

function acXssd2019Tab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
	    return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
			
		local tbTitleImage = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
        tbTitleImage:setContentSize(CCSizeMake(self.tvWidth-20, tbTitleImage:getContentSize().height))
        tbTitleImage:setAnchorPoint(ccp(0,1))
        tbTitleImage:setPosition(ccp(10,self.cellHeight-8))
        cell:addChild(tbTitleImage)

        local fontSize4 = 13
		if G_isAsia() then
			fontSize4 = 23
		end

        local titleLb3 = GetTTFLabel(acXssd2019VoApi:selfRewardDes( idx+1 ),fontSize4)
        titleLb3:setColor(G_ColorGreen)
        titleLb3:setAnchorPoint(ccp(0,0.5))
        titleLb3:setPosition(ccp(15,tbTitleImage:getContentSize().height/2))
        tbTitleImage:addChild(titleLb3)

        local titleLb3_num = GetTTFLabel(getlocal("serverwar_reward_desc2",{acXssd2019VoApi:selfRewardPoint( idx+1 )}),fontSize4)
        titleLb3_num:setColor(ccc3(84,255,26))
        titleLb3_num:setAnchorPoint(ccp(0,1))
        titleLb3_num:setPosition(ccp(15,-5))
        tbTitleImage:addChild(titleLb3_num)

        local selfRewardTb = FormatItem(acXssd2019VoApi:selfRewardShow( idx+1 ),nil,true)
        local today,dayFlag = acXssd2019VoApi:getToday()
        local selfState = acXssd2019VoApi:selfRewardState( idx + 1 )  --个人悬赏任务状态   1：不可领取   2：可领取   3：已领取
        for k,v in pairs(selfRewardTb) do
            if v then 
                local function showTip()
                    G_showNewPropInfo(self.layerNum+1,true,true,nil,v) 
                end

                local iconSp = G_getItemIcon(v,nil,false,100,showTip,nil,nil,nil,nil,nil,true)
                local scale = 80/iconSp:getContentSize().width
                iconSp:setAnchorPoint(ccp(0,1))
                iconSp:setScale(scale)
                local iconSize=iconSp:getContentSize().width*scale
                iconSp:setPosition(ccp(50+(iconSize+40)*(k-1),tbTitleImage:getPositionY()-tbTitleImage:getContentSize().height-45))
                iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(iconSp,6)

                local numLb=GetTTFLabel("x"..FormatNumber(v.num),20/scale)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
                iconSp:addChild(numLb,4)
                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(1,0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-2))
                numBg:setPosition(ccp(iconSp:getContentSize().width-5,5))
                numBg:setOpacity(150)
                iconSp:addChild(numBg,3) 

                if selfState == 1 then
                	if dayFlag ==0 then
		                local function gotoHandle( )
							G_goToDialog2NeedSecondTurn(acXssd2019VoApi:selfRewardTaskKey( idx ))
						end 
						local gotoMenu = G_createBotton(cell, ccp(G_VisibleSizeWidth - 90, self.cellHeight/2-35), nil, "gotoBtn.png","gotoBtn_down.png","gotoBtn_down.png", gotoHandle, 1, -(self.layerNum - 1) * 20 - 3, 3,nil,ccp(0.5,0.5))
					else
				    	local over = GetTTFLabel(getlocal("activity_heartOfIron_over"),24,true)
				        over:setAnchorPoint(ccp(1,0.5))
				        over:setColor(ccc3(168,168,168))
				        over:setPosition(ccp(G_VisibleSizeWidth - 90,self.cellHeight/2-35))
				        cell:addChild(over)
				    end

				elseif selfState == 2 then
					--可领取回调
					local function canReward( ... )
						PlayEffect(audioCfg.mouseClick)
				        if G_checkClickEnable()==false then
				            do
				                return
				            end
				        else
				            base.setWaitTime=G_getCurDeviceMillTime()
				        end
						local act = 2
						local tid = idx+1
						local dw = acXssd2019VoApi:selfHaveReward( idx+1 )

						local function refreshFunc( reward )
							if not self.parent:isClosed() then
								self:initMiddle()
								-- self:initDown()
								local recordPoint = self.tv:getRecordPoint()
		                        self.tv:reloadData()
		                        self.tv:recoverToRecordPoint(recordPoint)
								self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab1Reward( ),1)
								if self.parent.acTab3 then
									self.parent.acTab3:initMiddle()
									self.parent.acTab3:initDown()
								end
							end
							if reward then
				                G_showRewardTip(reward, true)
				            end
						end
						acXssd2019VoApi:socketXssd2019Task(act,tid,dw,refreshFunc)
			            do return end
					end

					rewardImage = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png", canReward,nil,getlocal("daily_scene_get"),30,11)
					rewardImage:setScale(0.6)
		            rewardBtn = CCMenu:createWithItem(rewardImage)
		            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		            rewardBtn:setAnchorPoint(ccp(0.5,1))
		            rewardBtn:setPosition(ccp( self.tvWidth - 90 , self.cellHeight/2-35))
		            rewardBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
		            cell:addChild(rewardBtn,3)
		        elseif selfState == 3 then
		        	local hasReward = GetTTFLabel(getlocal("activity_wanshengjiedazuozhan_complete"),24,true)
			        hasReward:setAnchorPoint(ccp(1,0.5))
			        hasReward:setColor(ccc3(168,168,168))
			        hasReward:setPosition(ccp(G_VisibleSizeWidth - 90,self.cellHeight/2-35))
			        cell:addChild(hasReward)
			    else
			    	local over = GetTTFLabel(getlocal("activity_heartOfIron_over"),24,true)
			        over:setAnchorPoint(ccp(1,0.5))
			        over:setColor(ccc3(168,168,168))
			        over:setPosition(ccp(G_VisibleSizeWidth - 90,self.cellHeight/2-35))
			        cell:addChild(over)
			    end

	            local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
	            bottomLine:setContentSize(CCSizeMake(self.tvWidth - 20,bottomLine:getContentSize().height + 1))
	            bottomLine:setRotation(180)
	            bottomLine:setPosition(ccp(self.tvWidth * 0.5, 0))
	            cell:addChild(bottomLine,1)
            end
        end
		
     	return cell
    end
end

function acXssd2019Tab1:initSlider()
	if self.node3 then
		self.node3:removeFromParentAndCleanup(true)
		self.node3=nil
	end
	self.node3 = CCNode:create()
	self.bgLayer:addChild(self.node3,2)

	local sliderBg = LuaCCScale9Sprite:createWithSpriteFrameName("xssd2019_tab1_sliderBg.png", CCRect(13,8,2,2), function()end)
	sliderBg:setContentSize(CCSize(445, 20))
    local sliderProgressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("barYellow1912.png"))
    sliderProgressBar:setType(kCCProgressTimerTypeBar)
    sliderProgressBar:setMidpoint(ccp(0, 1))
    sliderProgressBar:setBarChangeRate(ccp(1, 0))
    local sliderSp = CCSprite:createWithSpriteFrameName("goldBox_xssd2019.png")
    local sliderArrow = CCSprite:createWithSpriteFrameName("arrow_xssd2019.png")
    sliderArrow:setAnchorPoint(ccp(0.5,1))
    sliderArrow:setPositionY(0)
    sliderBg:addChild(sliderArrow)

    sliderBg:setPosition(G_VisibleSizeWidth/2+43,G_VisibleSizeHeight-560)
    self.node3:addChild(sliderBg, 10)
    sliderProgressBar:setPosition(sliderBg:getContentSize().width / 2, sliderBg:getContentSize().height / 2)
    sliderBg:addChild(sliderProgressBar)
    self.node3:addChild(sliderSp, 11)
    sliderSp:setPositionY(sliderBg:getPositionY())

    sliderProgressBar:setScaleX(0.87)
    sliderSp:setScale(0.4)

    local minValue = 0
    local maxValue = acXssd2019VoApi:slidermax()
    
    local sliderAnchorPoint = sliderSp:getAnchorPoint()

    local curValue = acXssd2019VoApi:integralPoint()
    sliderProgressBar:setPercentage(curValue / maxValue * 100)
    sliderSp:setPositionX(sliderBg:getPositionX() - sliderBg:getContentSize().width / 2 + sliderProgressBar:getPercentage() / 100 * sliderBg:getContentSize().width +6)
    sliderArrow:setPositionX(sliderProgressBar:getPercentage() / 100 * sliderBg:getContentSize().width+6)

    local sliderLayer = CCLayer:create()
    local beganPos
    local isTouchSlider
    local function touchHandler1(fn, x, y, touch)
        if fn == "began" then
            beganPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            -- local sliderPos = sliderBg:convertToWorldSpace(ccp(sliderSp:getPosition()))
            local sliderPos = ccp(sliderSp:getPosition())
            if beganPos.x >= sliderPos.x - sliderSp:getContentSize().width * sliderSp:getScale() * sliderAnchorPoint.x and beganPos.x <= sliderPos.x + sliderSp:getContentSize().width * sliderSp:getScale() * (1 - sliderAnchorPoint.x) and
                beganPos.y >= sliderPos.y - sliderSp:getContentSize().height * sliderSp:getScale() * sliderAnchorPoint.y and beganPos.y <= sliderPos.y + sliderSp:getContentSize().height * sliderSp:getScale() * (1 - sliderAnchorPoint.y) then
                isTouchSlider = true
                local flag,point,prePoint = acXssd2019VoApi:integralPointShow( acXssd2019VoApi:integralPoint() )

                local integralPoint,prePointShow,flag1,flag2 = acXssd2019VoApi:integralPointShow2( acXssd2019VoApi:integralPoint() )
				local titleStr1 = getlocal("activity_xssd2019_recentLabelBox")
				local rewardTb = acXssd2019VoApi:integralRewardShow(point)
                self:showIntegralReward(integralPoint, rewardTb, sliderBg:getPositionY() + sliderBg:getContentSize().height / 2,prePointShow,flag1,flag2)
                return true
            end
            return false
        elseif fn == "moved" then
            if isTouchSlider then
                local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                if curPos.x < sliderBg:getPositionX() - sliderBg:getContentSize().width / 2 then
                	curPos.x = sliderBg:getPositionX() - sliderBg:getContentSize().width / 2
                end
                if curPos.x > sliderBg:getPositionX() + sliderBg:getContentSize().width / 2 then
                	curPos.x = sliderBg:getPositionX() - sliderBg:getContentSize().width / 2 + sliderBg:getContentSize().width
                end
                sliderSp:setPositionX(curPos.x+6)
                sliderProgressBar:setPercentage((sliderSp:getPositionX() - (sliderBg:getPositionX() - sliderBg:getContentSize().width / 2)) / sliderBg:getContentSize().width * 100)
                curValue = math.floor(sliderProgressBar:getPercentage() / 100 * maxValue)

                local flag,point,prePoint = acXssd2019VoApi:integralPointShow( curValue )

                local integralPoint,prePointShow,flag1,flag2 = acXssd2019VoApi:integralPointShow2( curValue )
                local rewardTb = acXssd2019VoApi:integralRewardShow(point)
                self:refreshIntegralReward(integralPoint, rewardTb,prePointShow,flag1,flag2)
            end
        elseif fn == "ended" then
            endPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            isTouchSlider = nil
            beganPos = nil
            sliderProgressBar:setPercentage(acXssd2019VoApi:integralPoint() / maxValue * 100)
    		sliderSp:setPositionX(sliderBg:getPositionX() - sliderBg:getContentSize().width / 2 + sliderProgressBar:getPercentage() / 100 * sliderBg:getContentSize().width+6)
            self:hideIntegralReward()
        else
            isTouchSlider = nil
            beganPos = nil
            sliderProgressBar:setPercentage(acXssd2019VoApi:integralPoint() / maxValue * 100)
    		sliderSp:setPositionX(sliderBg:getPositionX() - sliderBg:getContentSize().width / 2 + sliderProgressBar:getPercentage() / 100 * sliderBg:getContentSize().width+6)
            self:hideIntegralReward()
        end
    end

    local function touchHandler2()
    	PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        local flag,point,prePoint = acXssd2019VoApi:integralPointShow( curValue )
		local act = 3
		local tid = 2019
		

		local function refreshFunc( reward )
			if not self.parent:isClosed() then
				self:initMiddle()
				self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab3Reward(),3)
				if self.parent.acTab3 then
                    self.parent.acTab3:initMiddle()
					self.parent.acTab3:initDown()
				end
			end
			if reward then
                G_showRewardTip(reward, true)
            end
		end
		acXssd2019VoApi:socketXssd2019Task(act,tid,curValue,refreshFunc)
        do return end
    end

    local day , flagDay  = acXssd2019VoApi:getToday(  )
    -- local flag,point,prePoint = acXssd2019VoApi:integralPointShow( curValue )
    local integralPoint,prePoint,flag1,flag2 = acXssd2019VoApi:integralPointShow2( curValue )
    sliderLayer:setTouchEnabled(true)
    sliderLayer:setBSwallowsTouches(true)
    if flagDay == 1 then
    	if flag2 and acXssd2019VoApi:ifCanIntegralReward( ) then
    		sliderLayer:setTouchEnabled(false)
    		sliderLayer:setBSwallowsTouches(false)
	    	
	    	local sliderItem=GetButtonItem("goldBox_xssd2019.png","goldBox_xssd2019.png","goldBox_xssd2019.png",touchHandler2,nil,nil,nil,nil)
	        acXssd2019VoApi:rewardFlicker(sliderSp,sliderItem,3)
	        local sliderMenu=CCMenu:createWithItem(sliderItem)
	        sliderMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	        sliderMenu:setAnchorPoint(ccp(0.5,0.5))
	        sliderMenu:setPosition(getCenterPoint(sliderSp))
	        sliderSp:addChild(sliderMenu)

	    elseif flag1==1 then
	    	local function touchHandler3(  )
	    		G_showTipsDialog(getlocal("activity_xssd2019_tab1_tip1",{prePoint}))
	    	end
	    	local sliderItem=GetButtonItem("goldBox_xssd2019.png","goldBox_xssd2019.png","goldBox_xssd2019.png",touchHandler3,nil,nil,nil,nil)
	        local sliderMenu=CCMenu:createWithItem(sliderItem)
	        sliderMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	        sliderMenu:setAnchorPoint(ccp(0.5,0.5))
	        sliderMenu:setPosition(getCenterPoint(sliderSp))
	        sliderSp:addChild(sliderMenu)

	    else
	    	local function touchHandler4(  )
	    		G_showTipsDialog(getlocal("activity_hadReward"))
	    	end
	    	local sliderItem=GetButtonItem("goldBox_xssd2019.png","goldBox_xssd2019.png","goldBox_xssd2019.png",touchHandler4,nil,nil,nil,nil)
	        local sliderMenu=CCMenu:createWithItem(sliderItem)
	        sliderMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	        sliderMenu:setAnchorPoint(ccp(0.5,0.5))
	        sliderMenu:setPosition(getCenterPoint(sliderSp))
	        sliderSp:addChild(sliderMenu)
	  --   	sliderLayer:setTouchEnabled(false)
	  --   	sliderLayer:setBSwallowsTouches(false)
	  --   	sliderSp:setOpacity(0)
	  --   	local sliderSpGray = GraySprite:createWithSpriteFrameName("goldBox_xssd2019.png")
			-- sliderSpGray:setAnchorPoint(ccp(0.5,0.5))
			-- sliderSpGray:setPosition(getCenterPoint(sliderSp))
			-- sliderSp:addChild(sliderSpGray,3)
	    end
    elseif flagDay == 0 then
    	sliderLayer:registerScriptTouchHandler(touchHandler1, false, -(self.layerNum - 1) * 20 - 4, true)
    else
    	sliderLayer:setTouchEnabled(false)
    	sliderLayer:setBSwallowsTouches(false)
    	sliderSp:setOpacity(0)
    	local sliderSpGray = GraySprite:createWithSpriteFrameName("goldBox_xssd2019.png")
		sliderSpGray:setAnchorPoint(ccp(0.5,0.5))
		sliderSpGray:setPosition(getCenterPoint(sliderSp))
		sliderSp:addChild(sliderSpGray,3)
    end
    
    
    self.node3:addChild(sliderLayer)


end


function acXssd2019Tab1:showIntegralReward(integral, rewardData, posY,prePoint,flag1,flag2)
	if self.rewardBg == nil then
		local rewardBg = G_getNewDialogBg2(CCSizeMake(480, 300),self.layerNum)
		rewardBg:setAnchorPoint(ccp(0.5, 0))
		rewardBg:setPosition(G_VisibleSizeWidth / 2, posY + 30)
		self.bgLayer:addChild(rewardBg,6)

		self.rewardBg = rewardBg

		local titleLb=GetTTFLabelWrap(getlocal("activity_xssd2019_recentLabelBox"),30,CCSizeMake(rewardBg:getContentSize().width-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    titleLb:setAnchorPoint(ccp(0.5,1))
		titleLb:setColor(G_ColorYellowPro)
		titleLb:setPosition(ccp(rewardBg:getContentSize().width/2,rewardBg:getContentSize().height-20))
		rewardBg:addChild(titleLb,1)

		local kuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function()end)
		kuangSp:setContentSize(CCSizeMake(rewardBg:getContentSize().width - 30, rewardBg:getContentSize().height - 100))
		local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
		pointSp1:setPosition(ccp(2,kuangSp:getContentSize().height/2))
		kuangSp:addChild(pointSp1)
		local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
		pointSp2:setPosition(ccp(kuangSp:getContentSize().width-2,kuangSp:getContentSize().height/2))
		kuangSp:addChild(pointSp2)
		local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
	    lightSp:setAnchorPoint(ccp(0.5,0))
	    lightSp:setScaleX(2)
	    lightSp:setPosition(kuangSp:getContentSize().width/2,kuangSp:getContentSize().height-2)
	    kuangSp:addChild(lightSp)
	    kuangSp:setAnchorPoint(ccp(0.5, 0))
	    kuangSp:setPosition(ccp(rewardBg:getContentSize().width / 2, 40))
	    rewardBg:addChild(kuangSp)

	    local fontSize4 = 15
	    if G_isAsia() then
	    	fontSize4 = 24
	    end

	    local curValue = acXssd2019VoApi:integralPoint()
	    if flag1==1 or flag1==2 then
	    	if flag2 then
	    		self.descLb=G_getRichTextLabel(getlocal("activity_xssd2019_recentLabel1",{prePoint,integral}),{G_ColorWhite,G_ColorGreen,G_ColorWhite},fontSize4,rewardBg:getContentSize().width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    	else
	    		self.descLb=G_getRichTextLabel(getlocal("activity_xssd2019_recentLabel1",{prePoint,integral}),{G_ColorWhite,G_ColorRed,G_ColorWhite},fontSize4,rewardBg:getContentSize().width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    	end
	    else
	    	if flag2 then
	    		self.descLb=G_getRichTextLabel(getlocal("activity_xssd2019_recentLabel2",{integral}),{G_ColorWhite,G_ColorGreen,G_ColorWhite},fontSize4,rewardBg:getContentSize().width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    	else
	    		self.descLb=G_getRichTextLabel(getlocal("activity_xssd2019_recentLabel2",{integral}),{G_ColorWhite,G_ColorRed,G_ColorWhite},fontSize4,rewardBg:getContentSize().width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    	end
	    end

	    self.descLb:setAnchorPoint(ccp(0.5, 1))
	    self.descLb:setPosition(rewardBg:getContentSize().width / 2, kuangSp:getPositionY() - 3)
	    self.descLb:setTag(-100)
	    rewardBg:addChild(self.descLb)

	    local rewardNode = CCNode:create()
	    rewardNode:setContentSize(kuangSp:getContentSize())
	    rewardNode:setAnchorPoint(kuangSp:getAnchorPoint())
	    rewardNode:setPosition(kuangSp:getPosition())
	    rewardBg:addChild(rewardNode)
	    rewardNode:setTag(-101)

	    self:refreshIntegralReward(integral, rewardData,prePoint,flag1,flag2)
	end
end

function acXssd2019Tab1:hideIntegralReward()
	if self.rewardBg then
		self.rewardBg:removeFromParentAndCleanup(true)
		self.rewardBg = nil
	end
end

function acXssd2019Tab1:refreshIntegralReward(integral, rewardData,prePoint,flag1,flag2)
	if self.rewardBg then
		local curValue = acXssd2019VoApi:integralPoint()
		if self.descLb then
			self.descLb:removeFromParentAndCleanup(true)
			self.descLb = nil
		end

		local fontSize5 = 15
	    if G_isAsia() then
	    	fontSize5 = 24
	    end

		if flag1==1 or flag1==2 then
	    	if flag2 then
	    		self.descLb=G_getRichTextLabel(getlocal("activity_xssd2019_recentLabel1",{prePoint,integral}),{G_ColorWhite,G_ColorGreen,G_ColorWhite},fontSize5,self.rewardBg:getContentSize().width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    	else
	    		self.descLb=G_getRichTextLabel(getlocal("activity_xssd2019_recentLabel1",{prePoint,integral}),{G_ColorWhite,G_ColorRed,G_ColorWhite},fontSize5,self.rewardBg:getContentSize().width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    	end
	    else
	    	if flag2 then
	    		self.descLb=G_getRichTextLabel(getlocal("activity_xssd2019_recentLabel2",{integral}),{G_ColorWhite,G_ColorGreen,G_ColorWhite},fontSize5,self.rewardBg:getContentSize().width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    	else
	    		self.descLb=G_getRichTextLabel(getlocal("activity_xssd2019_recentLabel2",{integral}),{G_ColorWhite,G_ColorRed,G_ColorWhite},fontSize5,self.rewardBg:getContentSize().width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	    	end
	    end

	    self.descLb:setAnchorPoint(ccp(0.5, 1))
	    self.descLb:setPosition(self.rewardBg:getContentSize().width / 2, 40 - 3)
	    self.descLb:setTag(-100)
	    self.rewardBg:addChild(self.descLb)
 
		local rewardNode = tolua.cast(self.rewardBg:getChildByTag(-101), "CCNode")
		if rewardNode then
			rewardNode:removeAllChildrenWithCleanup(true)
			if rewardData and rewardData[1] then
				local v = rewardData[1]
				local iconSize = 100
				local icon, scale = G_getItemIcon(v, 100, false, self.layerNum)
	            icon:setScale(iconSize / icon:getContentSize().height)
	            scale = icon:getScale()
	            icon:setPosition(ccp(80, rewardNode:getContentSize().height / 2))
	            rewardNode:addChild(icon, 1)
	        	local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 18)
	            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
	            numBg:setAnchorPoint(ccp(0, 1))
	            numBg:setRotation(180)
	            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
	            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
	            numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
	            rewardNode:addChild(numBg, 1)
	            numLb:setAnchorPoint(ccp(1, 0))
	            numLb:setPosition(numBg:getPosition())
	            rewardNode:addChild(numLb, 1)

	            local nameStr=v.name
				local nameLb = GetTTFLabelWrap(nameStr,25,CCSizeMake(270,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				nameLb:setAnchorPoint(ccp(0,0))
				nameLb:setPosition(ccp(icon:getPositionX()+icon:getContentSize().width-10,rewardNode:getContentSize().height / 2+10))
				rewardNode:addChild(nameLb,1)

				local desFontSize = 16
				if G_isAsia() then
					desFontSize = 22
				end

				local descStr=v.desc
				local desc = GetTTFLabelWrap(getlocal(descStr),desFontSize,CCSizeMake(270,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				desc:setAnchorPoint(ccp(0,1))
				desc:setPosition(ccp(icon:getPositionX()+icon:getContentSize().width-10,rewardNode:getContentSize().height / 2-10))
				rewardNode:addChild(desc,1)
			end
		end
	end
end


function acXssd2019Tab1:tick( ... )
	if tolua.cast(self.acTimeLb1,"CCLabelTTF") then
    	self.acTimeLb1:setString(acXssd2019VoApi:getTimeStr2())
    end
    if tolua.cast(self.acTimeLb2,"CCLabelTTF") then
    	self.acTimeLb2:setString(acXssd2019VoApi:getTimeStr1())
    end
    -- if G_isToday(acXssd2019VoApi:getTime( )) then
    -- 	self:initUp()
    -- end
end


function acXssd2019Tab1:dispose( )
	if self.overDayEventListener then
        eventDispatcher:removeEventListener("overADay", self.overDayEventListener)
    end
    self.overDayEventListener=nil
    -- base:removeFromNeedRefresh(self) --停止刷新
    -- self.layerNum = nil
    self.bgLayer = nil
    self.node1 = nil
    self.node2 = nil
    self.node3 = nil
    -- self.tv = nil
end