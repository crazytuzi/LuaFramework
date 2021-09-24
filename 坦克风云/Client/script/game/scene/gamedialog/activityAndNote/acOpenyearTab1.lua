acOpenyearTab1 ={}
function acOpenyearTab1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    self.adaH = 0
    self.version = acOpenyearVoApi:getVersion()
    if G_getIphoneType() == G_iphoneX then
    	self.adaH = 1250 - 1136
    end
    return nc
end

function acOpenyearTab1:init()
	self.bgLayer=CCLayer:create()

	-- 活动 时间 描述
	local lbH=self.bgLayer:getContentSize().height-185
	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorYellowPro)

    local acVo = acOpenyearVoApi:getAcVo()
    lbH=lbH-35
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220))
    self.bgLayer:addChild(timeLabel)

    local nbReward=self.version == 3 and {p={{p4833=2}}} or {p={{p3335=1}}}
    local iconsize = self.version == 3 and 100 or 120
    local nbItem=FormatItem(nbReward)
    local icon,scale=G_getItemIcon(nbItem[1],iconsize,true,self.layerNum)
    -- icon:setScale(0.9)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(40,lbH-23)
    self.bgLayer:addChild(icon,2)

    lbH=lbH-35
    local _desStr=getlocal("activity_openyear_des1")

    if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
    	_desStr=getlocal("activity_openyear_des1_1")
    elseif acOpenyearVoApi:getAcShowType()== acOpenyearVoApi.acShowType.TYPE_3 then
    	_desStr=getlocal("activity_openyear_des1_3")
    end

    local desLb=GetTTFLabelWrap(_desStr,25,CCSize(440,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desLb:setAnchorPoint(ccp(0,1))
    desLb:setPosition(170,lbH)
    self.bgLayer:addChild(desLb)

    lbH=lbH-desLb:getContentSize().height-10
    -- local greenLineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
    -- self.bgLayer:addChild(greenLineSp)
    -- greenLineSp:setPosition(self.bgLayer:getContentSize().width/2,lbH)

    -- lbH=lbH-5
    local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite1:setAnchorPoint(ccp(0.5,1))
    goldLineSprite1:setPosition(ccp(self.bgLayer:getContentSize().width/2,lbH-self.adaH/2))
    self.bgLayer:addChild(goldLineSprite1)

    lbH=lbH-goldLineSprite1:getContentSize().height


    self.tvH=lbH-40+7
    self:addTV()


	return self.bgLayer
end

function acOpenyearTab1:addTV()
	self.bigCellHeight=570
	if G_getIphoneType() == G_iphoneX then
        self.bigCellHeight=self.bigCellHeight+60
    end
	self.smallCellHeight=185
	self.getFdFlag=acOpenyearVoApi:GetCommonFdState()
	local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.tvH-self.adaH/2),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acOpenyearTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then	 	
        return 2
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local cellHeight
        if self.getFdFlag==0 then
        	if idx==0 then
	        	cellHeight=self.smallCellHeight
	        else
	        	cellHeight=self.bigCellHeight
	        end
	    else
	    	if idx==0 then
	        	cellHeight=self.bigCellHeight
	        else
	        	cellHeight=self.smallCellHeight
	        end
        end
        
		tmpSize=CCSizeMake(G_VisibleSizeWidth-40,cellHeight)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        if self.getFdFlag==0 then
        	if idx==0 then
	        	self:initSmallCell(cell)
	        else
	        	self:initBigCell(cell)
	        end
	    else
	    	if idx==0 then
	        	self:initBigCell(cell)
	        else
	        	self:initSmallCell(cell)
	        end
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

function acOpenyearTab1:initSmallCell(cell)

	local centerWidth=(G_VisibleSizeWidth-40)/2

	-- 标题背景 及 文字

	local blueBgSp=CCSprite:createWithSpriteFrameName("openyear_blueBg.png")
	cell:addChild(blueBgSp)
	blueBgSp:setPosition(centerWidth,self.smallCellHeight-25)

	local greenLineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
    cell:addChild(greenLineSp)
    greenLineSp:setPosition(centerWidth,self.smallCellHeight-2)
    local greenLineSp2=CCSprite:createWithSpriteFrameName("openyear_line.png")
    cell:addChild(greenLineSp2)
    greenLineSp2:setPosition(centerWidth,self.smallCellHeight-48)

	local titleLb=GetTTFLabel(getlocal("activity_openyear_dailySend"),30)
	blueBgSp:addChild(titleLb)
	titleLb:setPosition(getCenterPoint(blueBgSp))

	-- 每日领取福袋展示
	local function nilFunc()
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),nilFunc)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width
    	-40,self.smallCellHeight-53))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(0,5))
    cell:addChild(backSprie)

    local subCenterH=(self.smallCellHeight-50)/2
    -- openyear_common_fd
    local sbRW=self.version == 3 and {p={{p4962=1}}} or {p={{p3334=1}}}
   	local sbItem=FormatItem(sbRW)
   	sbItem[1].bgname=nil
    local commonSpFd,scale=G_getItemIcon(sbItem[1],100,true,self.layerNum,nil,self.tv,nil,nil,true)

    -- local commonSpFd=LuaCCSprite:createWithSpriteFrameName("openyear_common_fd.png",clickCommon)
    backSprie:addChild(commonSpFd)
    commonSpFd:setAnchorPoint(ccp(0,0.5))
    commonSpFd:setScale(130/commonSpFd:getContentSize().width)
    commonSpFd:setPosition(0,subCenterH)
    commonSpFd:setTouchPriority(-(self.layerNum-1)*20-2)

    -- activity_openyear_getFdDes
    local posx = G_getCurChoseLanguage() == "ar" and 100 or 120
    local desLb=GetTTFLabelWrap(getlocal("activity_openyear_getFdDes"),25,CCSizeMake(340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    backSprie:addChild(desLb)
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(posx,subCenterH)
    desLb:setColor(G_ColorYellowPro)

    -- 是否领取 0 未领取  1 领取
    local flag=acOpenyearVoApi:GetCommonFdState()
    local enableFlag
    local menuStr
    if flag==0 then
    	menuStr=getlocal("daily_scene_get")
    	enableFlag=true
    else
    	menuStr=getlocal("activity_hadReward")
    	enableFlag=false
    end

    local function goTiantang()
		if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		    if G_checkClickEnable()==false then
		        do
		            return
		        end
		    else
		        base.setWaitTime=G_getCurDeviceMillTime()
		    end

		    local function refreshFunc(rewardlist)
		    	self.getFdFlag=acOpenyearVoApi:GetCommonFdState()
		    	local recordPoint=self.tv:getRecordPoint()
				self.tv:reloadData()
				self.tv:recoverToRecordPoint(recordPoint)

				-- 此处加弹板
				if rewardlist then
					acOpenyearVoApi:showRewardDialog(rewardlist,self.layerNum)
				end
		    end
		    local action="daybag"
		    acOpenyearVoApi:socketOpenyear(action,refreshFunc)
		    -- 每日登陆领取逻辑
		end

	end
	-- local getItemScale=0.8
	-- local getItemImage1,getItemImage2,getItemImage3="BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
	-- if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
		local getItemScale=0.6
		local getItemImage1,getItemImage2,getItemImage3="newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"
	-- end
	local getItem=GetButtonItem(getItemImage1,getItemImage2,getItemImage3,goTiantang,nil,menuStr,24/getItemScale)
	getItem:setScale(getItemScale)
	getItem:setEnabled(enableFlag)
	local getBtn=CCMenu:createWithItem(getItem);
	getBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	getBtn:setPosition(ccp(515,subCenterH))
	backSprie:addChild(getBtn)


end

function acOpenyearTab1:initBigCell(cell)
	-- self.bigCellHeight=600
	local luckReward,needLuck,bagReward=acOpenyearVoApi:getLuckyAndBagReward()
	local haveFdReward=acOpenyearVoApi:getP()

	local centerWidth=(G_VisibleSizeWidth-40)/2

	-- 标题背景 及 文字
	local adaH = 0
	if G_getIphoneType() == G_iphoneX then
		adaH = 30
	end
	local blueBgSp=CCSprite:createWithSpriteFrameName("openyear_blueBg.png")
	cell:addChild(blueBgSp)
	blueBgSp:setPosition(centerWidth,self.bigCellHeight-25)

	local greenLineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
    cell:addChild(greenLineSp)
    greenLineSp:setPosition(centerWidth,self.bigCellHeight-2)
    local greenLineSp2=CCSprite:createWithSpriteFrameName("openyear_line.png")
    cell:addChild(greenLineSp2)
    greenLineSp2:setPosition(centerWidth,self.bigCellHeight-48)

	local titleLb=GetTTFLabel(getlocal("activity_openyear_godBless"),30)
	blueBgSp:addChild(titleLb)
	titleLb:setPosition(getCenterPoint(blueBgSp))

	-- 记录
	local function rewardRecordsHandler()
		if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		    if G_checkClickEnable()==false then
		        do
		            return
		        end
		    else
		        base.setWaitTime=G_getCurDeviceMillTime()
		    end
            PlayEffect(audioCfg.mouseClick)
	        local function showLog()
	           acOpenyearVoApi:showLogRecord(self.layerNum+1)
	        end
	        acOpenyearVoApi:getLog(showLog)
	    end
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.7)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    recordMenu:setPosition(ccp(70,self.bigCellHeight-43-adaH))
    cell:addChild(recordMenu)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setPosition(recordBtn:getContentSize().width*recordBtn:getScale()/2,8)
    recordLb:setScale(1/recordBtn:getScale())
    recordBtn:addChild(recordLb)


	local posY=self.bigCellHeight-160-adaH
	-- if(G_isIphone5())then
 --        posY=self.bigCellHeight-165
 --    end
	local barWidth=450

	-- 福气值
	local acPoint=acOpenyearVoApi:getF()

	local percentStr=""
	local per=G_getPercentage(acPoint,needLuck)
	AddProgramTimer(cell,ccp(centerWidth-15,posY),11,12,percentStr,"platWarProgressBg.png","taskBlueBar.png",13,1,1)
	local timerSpriteLv=cell:getChildByTag(11)
	timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
	timerSpriteLv:setPercentage(per)
	local timerSpriteBg=cell:getChildByTag(13)
	timerSpriteBg=tolua.cast(timerSpriteBg,"CCSprite")
	local scalex=barWidth/timerSpriteLv:getContentSize().width
	timerSpriteBg:setScaleX(scalex)
	timerSpriteLv:setScaleX(scalex)

	local totalWidth=timerSpriteBg:getContentSize().width
	local totalHeight=timerSpriteBg:getContentSize().height
	local everyWidth=totalWidth/5

	-- 当前值
	local acSp=CCSprite:createWithSpriteFrameName("taskActiveSp.png")
	acSp:setPosition(ccp(0,totalHeight/2))
	timerSpriteLv:addChild(acSp,2)

	
	local acPointLb=GetBMLabel(acPoint,G_GoldFontSrc,10)
	acPointLb:setPosition(ccp(acSp:getContentSize().width/2,acSp:getContentSize().height/2-2))
	acSp:addChild(acPointLb,2)
	acPointLb:setScale(0.4)

	-- 每一段进度值
	for k,v in pairs(needLuck) do
		local acSp1=CCSprite:createWithSpriteFrameName("taskActiveSp1.png")
		acSp1:setPosition(ccp(everyWidth*k,totalHeight/2))
		timerSpriteLv:addChild(acSp1,1)
		acSp1:setScale(1.2)
		local acSp2=CCSprite:createWithSpriteFrameName("taskActiveSp2.png")
		acSp2:setPosition(ccp(everyWidth*k,totalHeight/2))
		timerSpriteLv:addChild(acSp2,1)
		acSp2:setScale(1.2)
		if acPoint>=v then
			acSp2:setVisible(true)
		else
			acSp2:setVisible(false)
		end

		local numLb=GetBMLabel(v,G_GoldFontSrc,10)
		numLb:setPosition(ccp(everyWidth*k,totalHeight/2))
		timerSpriteLv:addChild(numLb,3)
		numLb:setScale(0.3)

		-- flag 1 未达成 2 可领取 3 已领取
		local flag=acOpenyearVoApi:getLuckState(k)

		local function clickBoxHandler( ... )
			
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end
	            PlayEffect(audioCfg.mouseClick)

	            local titleStr=getlocal("activity_openyear_baoxiang" .. k)
	            if flag~=2 then
	            	local reward={luckReward[k]}
	            	-- activity_openyear_baoxiang1
	            	local titleColor
	            	if k==1 then
	            		titleColor=G_ColorWhite
            		elseif k==2 then
	            		titleColor=G_ColorGreen
            		elseif k==3 then
	            		titleColor=G_ColorBlue
            		elseif k==4 then
	            		titleColor=G_ColorPurple
            		elseif k==5 then
	            		titleColor=G_ColorOrange
	            	end
	            	local desStr=getlocal("activity_openyear_allreward_des")
				    acOpenyearVoApi:showRewardKu(titleStr,self.layerNum,reward,desStr,titleColor)
					return
				end

			    local function refreshFunc(rewardlist)
			    	local recordPoint=self.tv:getRecordPoint()
					self.tv:reloadData()
					self.tv:recoverToRecordPoint(recordPoint)

					if k==4 or k==5 then
						local desStr
						if k==4 then
							if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
								desStr="activity_openyear_chatMessage1_1"
							else
								desStr="activity_openyear_chatMessage1"
							end
						elseif k==5 then
							desStr="activity_openyear_chatMessage2"
						end
						local paramTab={}
						paramTab.functionStr="openyear"
						paramTab.addStr="i_also_want"
						local _acTitleStr=getlocal("activity_openyear_title")
						if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
							_acTitleStr=getlocal("activity_openyear_title_1")
						end
						local message={key=desStr,param={playerVoApi:getPlayerName(),_acTitleStr,v,titleStr}}
						chatVoApi:sendSystemMessage(message,paramTab)
					end

					-- 此处加弹板
					if rewardlist then
						acOpenyearVoApi:showRewardDialog(rewardlist,self.layerNum)
					end
			    end
			    local action="luckreward"
			    local tid=k
			    acOpenyearVoApi:socketOpenyear(action,refreshFunc,tid,count)
			end

		end

		local boxScale=0.7
		local boxSp=LuaCCSprite:createWithSpriteFrameName("taskBox"..k..".png",clickBoxHandler)
		boxSp:setTouchPriority(-(self.layerNum-1)*20-2)
		boxSp:setPosition(everyWidth*k,totalHeight+45)
		timerSpriteLv:addChild(boxSp,3)
		boxSp:setScale(boxScale)

		
		if flag==2 then
			local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
		    lightSp:setPosition(everyWidth*k,totalHeight+45)
		    timerSpriteLv:addChild(lightSp)
		    lightSp:setScale(0.5)

            local time = 0.1--0.07
	        local rotate1=CCRotateTo:create(time, 30)
	        local rotate2=CCRotateTo:create(time, -30)
	        local rotate3=CCRotateTo:create(time, 20)
	        local rotate4=CCRotateTo:create(time, -20)
	        local rotate5=CCRotateTo:create(time, 0)
	        local delay=CCDelayTime:create(1)
	        local acArr=CCArray:create()
	        acArr:addObject(rotate1)
	        acArr:addObject(rotate2)
	        acArr:addObject(rotate3)
	        acArr:addObject(rotate4)
	        acArr:addObject(rotate5)
	        acArr:addObject(delay)
	        local seq=CCSequence:create(acArr)
	        local repeatForever=CCRepeatForever:create(seq)
	        boxSp:runAction(repeatForever)
        elseif flag==3 then
        	local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
	        -- lbBg:setContentSize(CCSizeMake(150,40))
	        lbBg:setScaleX(150/lbBg:getContentSize().width)
	        lbBg:setPosition(everyWidth*k,totalHeight+45)
	        timerSpriteLv:addChild(lbBg,4)
	        lbBg:setScale(0.7)
	        local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),22)
			hasRewardLb:setPosition(everyWidth*k,totalHeight+45)
			timerSpriteLv:addChild(hasRewardLb,5)
		end
		
	end

	-- 四种福袋
	-- haveFdReward
	-- if(G_isIphone5())then
	-- 	posY=posY-50
	-- else
        posY=posY-40-adaH
    -- end
	local fdSize=CCSizeMake(285,180)
	local fdWidth1=centerWidth-fdSize.width/2-5
	local fdWidth2=centerWidth+fdSize.width/2+5
	for i=1,4 do
		local subX
		if i%2==0 then
			subX=fdWidth2
		else
			subX=fdWidth1
		end
		
		local function nilFunc()
	    end
	    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),nilFunc)
	    backSprie:setContentSize(fdSize)
	    backSprie:ignoreAnchorPointForPosition(false)
	    backSprie:setAnchorPoint(ccp(0.5,1))
	    backSprie:setPosition(ccp(subX,posY))
	    cell:addChild(backSprie)

		local greenLineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
		backSprie:addChild(greenLineSp)
		greenLineSp:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height-4)
		greenLineSp:setScaleX(0.6)
		local greenLineSp2=CCSprite:createWithSpriteFrameName("openyear_line.png")
		backSprie:addChild(greenLineSp2)
		greenLineSp2:setPosition(backSprie:getContentSize().width/2,4)
		greenLineSp2:setScaleX(0.6)

		local ver = acOpenyearVoApi:getVersion()
		local titleStr= ver ==3 and getlocal("activity_openyear_fd_v2_title"..i) or getlocal("activity_openyear_fd_title"..i)
	    local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(fdSize.width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		titleLb:setAnchorPoint(ccp(0.5,1))
		backSprie:addChild(titleLb)
		titleLb:setPosition(fdSize.width/2,fdSize.height-10)
		titleLb:setColor(G_ColorYellowPro)



		local fdPic=self.version == 3 and "openyear_v2_fd" .. i .. ".png" or "openyear_fd" .. i .. ".png"
		local function clickFd()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end
			    local reward={bagReward[i]}
			    local desStr=getlocal("activity_wanshengjiedazuozhan_reward_desc")
			    acOpenyearVoApi:showRewardKu(titleStr,self.layerNum,reward,desStr)
			end
		end
		local fdSp=LuaCCSprite:createWithSpriteFrameName(fdPic,clickFd)
		backSprie:addChild(fdSp)
		fdSp:setAnchorPoint(ccp(0,0))
		fdSp:setPosition(0,10)
		fdSp:setTouchPriority(-(self.layerNum-1)*20-2);
		fdSp:setScale(130/fdSp:getContentSize().width)

		-- activity_openyear_fd_opened

		-- 开启按钮
		local haveNum=haveFdReward["p" .. i] or 0
		local function goTiantang()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end

			    -- 开启礼包
			    local function refreshFunc(rewardlist,fqNum)
			    	local recordPoint=self.tv:getRecordPoint()
					self.tv:reloadData()
					self.tv:recoverToRecordPoint(recordPoint)

					-- 此处加弹板
					if rewardlist then
						acOpenyearVoApi:showRewardDialog(rewardlist,self.layerNum,fqNum)
					end
			    end
			    local action="openbag"
			    local tid=i
			    local count=1
			    acOpenyearVoApi:socketOpenyear(action,refreshFunc,tid,count)
			end

		end
		local openItemScale=0.6
		local openItemImage1,openItemImage2,openItemImage3="newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"
		local openItem=GetButtonItem(openItemImage1,openItemImage2,openItemImage3,goTiantang,nil,getlocal("activity_openyear_fd_open"),24/openItemScale)
		openItem:setScale(openItemScale)
		local openBtn=CCMenu:createWithItem(openItem);
		openBtn:setTouchPriority(-(self.layerNum-1)*20-2);
		openBtn:setPosition(ccp(fdSize.width-80,50))
		backSprie:addChild(openBtn)
		if tonumber(haveNum)>0 then
			openItem:setEnabled(true)
		else
			openItem:setEnabled(false)
		end

		local desLb=GetTTFLabelWrap(getlocal("activity_openyear_fd_opened",{haveNum}),22,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		desLb:setAnchorPoint(ccp(0.5,0))
		backSprie:addChild(desLb)
		desLb:setPosition(ccp(fdSize.width-80,83))

	    if i%2==0 then
	    	posY=posY-fdSize.height-10
	    end
	end


end

function acOpenyearTab1:refresh()
	if self.tv then
		self.getFdFlag=acOpenyearVoApi:GetCommonFdState()
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acOpenyearTab1:tick()
end

function acOpenyearTab1:dispose( )
    self.layerNum=nil
end