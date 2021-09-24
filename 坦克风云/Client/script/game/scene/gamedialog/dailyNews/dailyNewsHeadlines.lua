dailyNewsHeadlines=smallDialog:new()

function dailyNewsHeadlines:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/dailyNews.plist")
    spriteController:addTexture("public/dailyNews.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	return nc
end

function dailyNewsHeadlines:init(layerNum,parent,isEmail,headlinesData,isChat)
	self.layerNum=layerNum
	self.parent=parent
	local comment
	local headlinesNews
	if headlinesData and SizeOfTable(headlinesData)>0 then
		headlinesNews=headlinesData
	else
		headlinesNews=dailyNewsVoApi:getHeadlinesNews()
	end
	self.headlinesNews=headlinesNews
	if headlinesNews and headlinesNews.comment and headlinesNews.comment>0 then
		comment=getlocal("dailyNews_comment_"..headlinesNews.comment)
	end
	local isCanEdit=dailyNewsVoApi:isCanEdit()
	if isEmail==true or isChat==true then
		isCanEdit=false
	end
	local dType=headlinesNews.type
	local subTitleStr=dailyNewsVoApi:getNewsTitle(dType)
	local content=headlinesNews.content or ""
	local praiseNum=tonumber(headlinesNews.praiseNum or 0)
	local isPraise=dailyNewsVoApi:getIsPraise() or 0
	local dCfg=dailyNewsVoApi:getCfgByType(dType)

	local posx=38
    local bgWidth,bgHeight=308*2,(411-35)*2
	local subTitleLb=GetTTFLabelWrap(subTitleStr,35,CCSizeMake(bgWidth-(posx*2),0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	local addH=subTitleLb:getContentSize().height+10
	local commentLb,commenNameLb
	if comment and comment~="" then
		commentLb=GetTTFLabelWrap(comment,25,CCSizeMake(bgWidth-(posx*2),0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		local commentPlayer=""
		if headlinesNews and headlinesNews.commentPlayer then
			commentPlayer=headlinesNews.commentPlayer or ""
		end
		commenNameLb=GetTTFLabel("----"..commentPlayer,25)
		addH=addH+commentLb:getContentSize().height+30+commenNameLb:getContentSize().height+10-5
	elseif isCanEdit==true then
		addH=addH+35--+10
	end
	bgHeight=bgHeight+addH

	-- local posy=bgHeight-130
	-- posy=posy-35
	local headlinesBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
	headlinesBg:setContentSize(CCSizeMake(bgWidth,bgHeight-480))
	headlinesBg:setAnchorPoint(ccp(0.5,1))
	-- headlinesBg:setPosition(ccp(bgWidth/2,posy))
	-- parent:addChild(headlinesBg)
	headlinesBg:setOpacity(0)
	local headBgHeight=headlinesBg:getContentSize().height
	-- headlinesBg:setVisible(false)
	self.headlinesBg=headlinesBg

	-- posy=posy-20
	local picWidth,picHeight=300,240
	local hpy=headBgHeight-20
	-- local picSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
	-- picSp:setContentSize(CCSizeMake(300,240))
	-- picSp:setAnchorPoint(ccp(0,1))
	-- picSp:setPosition(ccp(posx,hpy))
	-- headlinesBg:addChild(picSp,1)
	local iconPy=hpy
	local function onLoadIcon(fn,icon)
	    if self and self.headlinesBg and icon and tolua.cast(self.headlinesBg,"LuaCCScale9Sprite") then
			icon:setAnchorPoint(ccp(0,1))
			icon:setPosition(ccp(posx,iconPy))
			icon:setScaleX(300/icon:getContentSize().width)
			icon:setScaleY(240/icon:getContentSize().height)
			self.headlinesBg:addChild(icon,1)
	    end
	end
	local url=G_downloadUrl("dailyNews/" .. dCfg.pic)
	local webImage = LuaCCWebImage:createWithURL(url,onLoadIcon)

	local function showInfo( ... )
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if self.parent and self.parent.openHeadlines==1 then
        else
        	PlayEffect(audioCfg.mouseClick)
			dailyNewsVoApi:showDailyNewsInfoDialog(dCfg.type,layerNum+1,headlinesNews)
		end
	end
	local photoSp=dailyNewsVoApi:getNewsIcon(headlinesNews,showInfo)
	if photoSp then
		photoSp:setTouchPriority(-(layerNum-1)*20-4)
		photoSp:setPosition(ccp(posx+picWidth+10+photoSp:getContentSize().width/2,hpy-photoSp:getContentSize().height/2))
		headlinesBg:addChild(photoSp,1)
		local nameStr,callStr="",""
		if headlinesNews then
			if dCfg.type==1 and headlinesNews and headlinesNews.allianceinfo then
				nameStr=headlinesNews.allianceinfo[1] or ""
				callStr=getlocal("alliance_list_scene_name")
			elseif dCfg.type==2 and headlinesNews and headlinesNews.userinfo then
				nameStr=headlinesNews.userinfo[2] or ""
				callStr=getlocal("zhihuiguan")
			elseif dCfg.type==3 and headlinesNews and headlinesNews.skyladderAlliance then
				nameStr=headlinesNews.skyladderAlliance[1] or ""
				callStr=getlocal("alliance_list_scene_name")
			elseif dCfg.type==4 and headlinesNews and headlinesNews.skyladderUser then
				nameStr=headlinesNews.skyladderUser[1] or ""
				callStr=getlocal("zhihuiguan")
			end
		end
		local callLb=GetTTFLabel(callStr,22)
		callLb:setAnchorPoint(ccp(0,1))
		callLb:setPosition(ccp(photoSp:getPositionX()+photoSp:getContentSize().width/2+5,hpy))
		headlinesBg:addChild(callLb,1)
		callLb:setColor(G_ColorBlack)
		local nameLb=GetTTFLabelWrap(nameStr,22,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(photoSp:getPositionX()+photoSp:getContentSize().width/2+5,hpy-50))
		headlinesBg:addChild(nameLb,1)
		nameLb:setColor(G_ColorBlack)
	end

	hpy=hpy-picHeight
	local descLb = getlocal("activity_battleplane_desc")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(230,120),content,20,kCCTextAlignmentLeft,G_ColorBlack)
	headlinesBg:addChild(desTv)
	desTv:setAnchorPoint(ccp(0,0))
	desTv:setPosition(ccp(posx+picWidth+10,hpy+38))
	if isEmail==true then
		desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-8)

		local maskBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
		maskBg:setContentSize(CCSizeMake(230,120))
		maskBg:setAnchorPoint(ccp(0,0))
		maskBg:setPosition(ccp(posx+picWidth+10,hpy+38))
		maskBg:setTouchPriority(-(self.layerNum-1)*20-7)
		maskBg:setIsSallow(true)
		maskBg:setOpacity(0)
		headlinesBg:addChild(maskBg)
	else
		desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	end
	desTv:setMaxDisToBottomOrTop(100)
	-- local contentLb=GetTTFLabelWrap(content,22,CCSizeMake(230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	-- contentLb:setAnchorPoint(ccp(0,1))
	-- contentLb:setPosition(ccp(posx+picWidth+10,hpy-photoSp:getContentSize().height-0))
	-- headlinesBg:addChild(contentLb,1)
	-- contentLb:setColor(G_ColorBlack)


	-- posy=posy-picHeight
	-- hpy=hpy-picHeight
	local function praiseHandler( ... )
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if isEmail==true or isChat==true then
        elseif dailyNewsVoApi:getIsPraise()==0 then
	        if headlinesNews and headlinesNews.id then
	        	local function praiseCallback( ... )
		        	local praiseNum1=dailyNewsVoApi:getPraiseNum() or 0
		        	if self.praiseBg and self.praiseLb then
			        	if self.praiseIcon then
			        		self.praiseIcon:removeFromParentAndCleanup(true)
			        		self.praiseIcon=nil
			        		self.praiseIcon=CCSprite:createWithSpriteFrameName("newsPraiseIcon.png")
							self.praiseIcon:setAnchorPoint(ccp(1,0))
							self.praiseIcon:setPosition(ccp(self.praiseBg:getContentSize().width-posx-self.praiseLb:getContentSize().width-10,0))
							self.praiseBg:addChild(self.praiseIcon,1)
			        	end
		        		self.praiseLb:setString(praiseNum1)
		        		self.praiseLb:setColor(G_ColorGreen2)
			        end
			        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_news_praise_success"),30)

			        local journalsNum=dailyNewsVoApi:getJournalsNum() or 0
			        chatVoApi:sendUpdateMessage(44,{praiseNum=praiseNum1,journalsNum=journalsNum})
			    end
		        dailyNewsVoApi:dailynewsNewsVote(headlinesNews.id,praiseCallback)
		    end
        else
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_news_has_praise"),30)
        end
	end
	local praiseIcon
	local praiseLb
	if isPraise==1 or isEmail==true or isChat==true then
		praiseIcon=CCSprite:createWithSpriteFrameName("newsPraiseIcon.png")
		praiseLb=GetTTFLabel(praiseNum,28)
		praiseLb:setColor(G_ColorGreen2)
	else
		praiseIcon=GraySprite:createWithSpriteFrameName("newsPraiseIcon.png")
		praiseIcon:setColor(G_ColorGray)
		praiseLb=GetTTFLabel(getlocal("dailyNews_praise"),28)
		praiseLb:setColor(G_ColorGray)
	end
	local praiseBg=LuaCCScale9Sprite:createWithSpriteFrameName("newsContentBg.png",CCRect(5, 5, 1, 1),praiseHandler)
	praiseBg:setTouchPriority(-(layerNum-1)*20-4)
	praiseBg:setContentSize(CCSizeMake(praiseLb:getContentSize().width+100,40))
	praiseBg:setAnchorPoint(ccp(1,0))
	praiseBg:setPosition(ccp(bgWidth-10,hpy))
	headlinesBg:addChild(praiseBg,1)
	praiseBg:setOpacity(0)
	self.praiseBg=praiseBg
	praiseLb:setAnchorPoint(ccp(1,0))
	praiseLb:setPosition(ccp(praiseBg:getContentSize().width-posx,0-5))
	praiseBg:addChild(praiseLb,1)
	self.praiseLb=praiseLb
	praiseIcon:setAnchorPoint(ccp(1,0))
	praiseIcon:setPosition(ccp(praiseBg:getContentSize().width-posx-praiseLb:getContentSize().width-10,0))
	praiseBg:addChild(praiseIcon,1)
	self.praiseIcon=praiseIcon

	if subTitleLb then
		-- posy=posy-40
		hpy=hpy-10
		-- local subTitleStr="subTitleStrsubTitleStrsubTitleStrsubTitleStr"
		-- local subTitleLb=GetTTFLabelWrap(subTitleStr,35,CCSizeMake(bgWidth-(posx*2),0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		subTitleLb:setAnchorPoint(ccp(0,1))
		subTitleLb:setPosition(ccp(posx,hpy))
		headlinesBg:addChild(subTitleLb,1)
		subTitleLb:setColor(G_ColorBlack)
		hpy=hpy-subTitleLb:getContentSize().height
	end

	if commentLb and commenNameLb then
		self:addComment(commentLb,commenNameLb,hpy-5)
	elseif isCanEdit==true then
		local function selectCommentDialog( ... )
			if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end

	        if parent and parent.showSelectComment then
		        local isShow=parent:showSelectComment()
		        if isShow==true then
		        	PlayEffect(audioCfg.mouseClick)
		        end
		    end
		end
		hpy=hpy-25+5---30-5
		local spScale=0.5
		local saySomethingLb=GetTTFLabel(getlocal("dailyNews_say_something"),25)
		local bookSp=CCSprite:createWithSpriteFrameName("newsBook.png")
		local ssBg=LuaCCScale9Sprite:createWithSpriteFrameName("newsContentBg.png",CCRect(5, 5, 1, 1),selectCommentDialog)
		ssBg:setContentSize(CCSizeMake(saySomethingLb:getContentSize().width+60,bookSp:getContentSize().height*spScale+20))
		ssBg:setTouchPriority(-(layerNum-1)*20-4)
		ssBg:setAnchorPoint(ccp(1,0.5))
		ssBg:setPosition(ccp(bgWidth-posx,hpy))
		headlinesBg:addChild(ssBg,1)
		ssBg:setOpacity(0)
		self.ssBg=ssBg

		local ssWidth,ssHeight=ssBg:getContentSize().width,ssBg:getContentSize().height/2
		saySomethingLb:setAnchorPoint(ccp(1,0.5))
		saySomethingLb:setPosition(ccp(ssWidth,ssHeight))
		ssBg:addChild(saySomethingLb,2)
		saySomethingLb:setColor(G_ColorBlack)

		bookSp:setPosition(ccp(ssWidth-saySomethingLb:getContentSize().width-25,ssHeight))
		ssBg:addChild(bookSp,2)
		bookSp:setScale(spScale)
		local penSp=CCSprite:createWithSpriteFrameName("newsPen.png")
		penSp:setPosition(ccp(ssWidth-saySomethingLb:getContentSize().width-25,ssHeight))
		ssBg:addChild(penSp,3)
		penSp:setScale(spScale)

		local moveTime,moveDis=0.2,3
		local moveBy1=CCMoveBy:create(moveTime,ccp(0,moveDis))
		local moveBy2=CCMoveBy:create(moveTime,ccp(0,-moveDis))
		local moveBy3=CCMoveBy:create(moveTime*2,ccp(0,moveDis*2))
		local moveBy4=CCMoveBy:create(moveTime*2,ccp(0,-moveDis*2))
		local delay=CCDelayTime:create(0.5)
		local acArr=CCArray:create()
		acArr:addObject(moveBy1)
		acArr:addObject(moveBy4)
		acArr:addObject(moveBy3)
		acArr:addObject(moveBy4)
		acArr:addObject(moveBy3)
		acArr:addObject(moveBy2)
		acArr:addObject(delay)
		local seq=CCSequence:create(acArr)
		local repeatForever=CCRepeatForever:create(seq)
		penSp:runAction(repeatForever)

		-- if self.line1 then
		-- 	self.line1:setPosition(ccp(bgWidth/2,hpy+10+ssHeight/2+5))
		-- else
		-- 	local line1=CCSprite:createWithSpriteFrameName("lineWhite.png")
		-- 	line1:setScaleX((bgWidth-posx*2)/line1:getContentSize().width)
		-- 	line1:setPosition(ccp(bgWidth/2,hpy+10+ssHeight/2+5))
		-- 	headlinesBg:addChild(line1,1)
		-- 	line1:setColor(G_ColorBlack)
		-- 	self.line1=line1
		-- end
		-- if self.line2 then
		-- 	self.line2:setPosition(ccp(bgWidth/2,hpy+5+ssHeight/2+5))
		-- else
		-- 	local line2=CCSprite:createWithSpriteFrameName("lineWhite.png")
		-- 	line2:setScaleX((bgWidth-posx*2)/line2:getContentSize().width)
		-- 	line2:setScaleY(2)
		-- 	line2:setPosition(ccp(bgWidth/2,hpy+5+ssHeight/2+5))
		-- 	headlinesBg:addChild(line2,1)
		-- 	line2:setColor(G_ColorBlack)
		-- 	self.line2=line2
		-- end
		-- if self.line3 then
		-- 	self.line3:setPosition(ccp(bgWidth/2,hpy-5-ssHeight/2-5))
		-- else
		-- 	local line3=CCSprite:createWithSpriteFrameName("lineWhite.png")
		-- 	line3:setScaleX((bgWidth-posx*2)/line3:getContentSize().width)
		-- 	line3:setScaleY(2)
		-- 	line3:setPosition(ccp(bgWidth/2,hpy-5-ssHeight/2-5))
		-- 	headlinesBg:addChild(line3,1)
		-- 	line3:setColor(G_ColorBlack)
		-- 	self.line3=line3
		-- end
		-- if self.line4 then
		-- 	self.line4:setPosition(ccp(bgWidth/2,hpy-10-ssHeight/2-5))
		-- else
		-- 	local line4=CCSprite:createWithSpriteFrameName("lineWhite.png")
		-- 	line4:setScaleX((bgWidth-posx*2)/line4:getContentSize().width)
		-- 	line4:setPosition(ccp(bgWidth/2,hpy-10-ssHeight/2-5))
		-- 	headlinesBg:addChild(line4,1)
		-- 	line4:setColor(G_ColorBlack)
		-- 	self.line4=line4
		-- end
	end

	local function dialogListener(event,data)
		local isPraise=dailyNewsVoApi:getIsPraise()
		if isPraise==1 and isEmail~=true and isChat~=true and self.praiseLb then
			local praiseNum2=dailyNewsVoApi:getPraiseNum() or 0
			self.praiseLb:setString(praiseNum2)
		end
	end
	self.dialogListener=dialogListener
    eventDispatcher:addEventListener("dailyNewsHeadlines.praiseNum",self.dialogListener)

	return headlinesBg
end

function dailyNewsHeadlines:updateHeadlines(isShow)
	if isShow==true then
    	if self.headlinesBg then
        	self.headlinesBg:setVisible(true)
        end
    else
    	if self.headlinesBg then
        	self.headlinesBg:setVisible(false)
        end
    end
end

function dailyNewsHeadlines:addComment(commentLb,commenNameLb,hpy)
	if commentLb and commenNameLb and self.headlinesBg then
		local posx=38
	    local bgWidth=308*2

		hpy=hpy-15
		if self.line1 then
			self.line1:setPosition(ccp(bgWidth/2,hpy+10))
		else
			local line1=CCSprite:createWithSpriteFrameName("lineWhite.png")
			line1:setScaleX((bgWidth-posx*2)/line1:getContentSize().width)
			line1:setPosition(ccp(bgWidth/2,hpy+10))
			self.headlinesBg:addChild(line1,1)
			line1:setColor(G_ColorBlack)
			self.line1=line1
		end
		if self.line2 then
			self.line2:setPosition(ccp(bgWidth/2,hpy+5))
		else
			local line2=CCSprite:createWithSpriteFrameName("lineWhite.png")
			line2:setScaleX((bgWidth-posx*2)/line2:getContentSize().width)
			line2:setScaleY(2)
			line2:setPosition(ccp(bgWidth/2,hpy+5))
			self.headlinesBg:addChild(line2,1)
			line2:setColor(G_ColorBlack)
			self.line2=line2
		end
		commentLb:setAnchorPoint(ccp(0,1))
		commentLb:setPosition(ccp(posx,hpy))
		self.headlinesBg:addChild(commentLb,1)
		commentLb:setColor(G_ColorBlack)
		hpy=hpy-commentLb:getContentSize().height--5
		commenNameLb:setAnchorPoint(ccp(1,1))
		commenNameLb:setPosition(ccp(bgWidth-posx,hpy))
		self.headlinesBg:addChild(commenNameLb,1)
		commenNameLb:setColor(G_ColorBlack)
		hpy=hpy-commenNameLb:getContentSize().height-5
		if self.line3 then
			self.line3:setPosition(ccp(bgWidth/2,hpy-5))
		else
			local line3=CCSprite:createWithSpriteFrameName("lineWhite.png")
			line3:setScaleX((bgWidth-posx*2)/line3:getContentSize().width)
			line3:setScaleY(2)
			line3:setPosition(ccp(bgWidth/2,hpy-5))
			self.headlinesBg:addChild(line3,1)
			line3:setColor(G_ColorBlack)
			self.line3=line3
		end
		if self.line4 then
			self.line4:setPosition(ccp(bgWidth/2,hpy-10))
		else
			local line4=CCSprite:createWithSpriteFrameName("lineWhite.png")
			line4:setScaleX((bgWidth-posx*2)/line4:getContentSize().width)
			line4:setPosition(ccp(bgWidth/2,hpy-10))
			self.headlinesBg:addChild(line4,1)
			line4:setColor(G_ColorBlack)
			self.line4=line4
		end
	end
end

function dailyNewsHeadlines:updateComment(comment)
	local addH=0
	if self.headlinesBg and comment and comment~="" then
		local posx=38
		local bgWidth,bgHeight=self.headlinesBg:getContentSize().width,self.headlinesBg:getContentSize().height
		local isCanEdit=dailyNewsVoApi:isCanEdit()
		if isCanEdit==true then
			addH=addH-35
		end
		local commentLb=GetTTFLabelWrap(comment,25,CCSizeMake(bgWidth-(posx*2),0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		local commentPlayer=""
		if self.headlinesNews and self.headlinesNews.commentPlayer then
			commentPlayer=self.headlinesNews.commentPlayer or ""
		end
		local commenNameLb=GetTTFLabel("----"..commentPlayer,25)
		addH=addH+commentLb:getContentSize().height+30+commenNameLb:getContentSize().height+10-5
		self:addComment(commentLb,commenNameLb,62-20)
		-- self.headlinesBg:setContentSize(CCSizeMake(bgWidth,bgHeight+addH))
		-- self.headlinesBg:setPosition(ccp(self.headlinesBg:getPositionX(),self.headlinesBg:getPositionY()+addH))
		if self.ssBg then
			self.ssBg:removeFromParentAndCleanup(true)
			self.ssBg=nil
		end
	end
	return addH
end

function dailyNewsHeadlines:dispose()
	self.praiseBg=nil
    self.praiseIcon=nil
	self.headlinesBg=nil
	spriteController:removePlist("public/dailyNews.plist")
    spriteController:removeTexture("public/dailyNews.png")
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
    eventDispatcher:removeEventListener("dailyNewsHeadlines.praiseNum",self.dialogListener)
end