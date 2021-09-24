dailyNewsSmallDialog=smallDialog:new()

function dailyNewsSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.openHeadlines=0
	self.cellTab={}

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

function dailyNewsSmallDialog:init(layerNum,headlinesData)
	layerNum=80
	self.layerNum=layerNum
	-- self.isDelay=isDelay
	local isShowNewsList=false
	local newsList=dailyNewsVoApi:getNewsList()
	if newsList and SizeOfTable(newsList)>0 then
		isShowNewsList=true
	end
	local comment
	local headlinesNews--=dailyNewsVoApi:getHeadlinesNews()
	local journalsNum,time=0,0
	if headlinesData and SizeOfTable(headlinesData)>0 then
		journalsNum=headlinesData.journalsNum or 0
		time=headlinesData.journalsDate or 0
		headlinesNews=headlinesData
		isShowNewsList=false
	else
		journalsNum=dailyNewsVoApi:getJournalsNum() or 0
		time=dailyNewsVoApi:getLastGetDataTime() or 0
		headlinesNews=dailyNewsVoApi:getHeadlinesNews()
	end
	if headlinesNews and headlinesNews.comment and headlinesNews.comment>0 then
		comment=getlocal("dailyNews_comment_"..headlinesNews.comment)
	end
	

	local posx=38
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	-- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
 --    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	-- local dnDialogBg = CCSprite:create("public/dailyNewsDialogBg.png")
	-- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
 --    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local dnDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("dailyNewsDialogBg.png",CCRect(154, 110, 1, 1),function ()end)
    dialogBg:setOpacity(0)

    require "luascript/script/game/scene/gamedialog/dailyNews/dailyNewsHeadlines"
	-- local headlinesBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
	local dhDialog=dailyNewsHeadlines:new()
	local isChat
	if headlinesData and SizeOfTable(headlinesData)>0 then
		isChat=true
	end
    local headlinesBg=dhDialog:init(layerNum,self,nil,headlinesNews,isChat)
	local headBgHeight=headlinesBg:getContentSize().height
	-- print("headBgHeight",headBgHeight)

	local isCanEdit=dailyNewsVoApi:isCanEdit()
	local bottomBgH
	if isCanEdit==true then
		bottomBgH=167
	else
		bottomBgH=167+60-20
	end
    local bgWidth,bgHeight=308*2,headBgHeight+480-60--(411-35)*2
    if isShowNewsList==false then
    	bgHeight=bgHeight-bottomBgH
    end
	dnDialogBg:setContentSize(CCSizeMake(bgWidth/2,bgHeight/2))
	self.dhDialog=dhDialog
	self.dnDialogBg=dnDialogBg
	self.headlinesBg=headlinesBg
	

	self.dialogLayer=CCLayer:create()
	local size=CCSizeMake(bgWidth,bgHeight)
	self.bgSize=size
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	-- self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true)

	dnDialogBg:setScale(2)
	dnDialogBg:setPosition(getCenterPoint(dialogBg))
	dialogBg:addChild(dnDialogBg)

	local posy=bgHeight-130
	local titleBgWidth,titleBgHeight=bgWidth,170
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
	titleBg:setContentSize(CCSizeMake(titleBgWidth,titleBgHeight))
	titleBg:setAnchorPoint(ccp(0.5,1))
	titleBg:setPosition(ccp(titleBgWidth/2,bgHeight))
	dialogBg:addChild(titleBg)
	titleBg:setOpacity(0)
	self.titleBg=titleBg
	
	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("newsCloseBtn.png","newsCloseBtn_Down.png","newsCloseBtn_Down.png",close,nil,nil,nil)
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(titleBgWidth-closeBtnItem:getContentSize().width-30,titleBgHeight-closeBtnItem:getContentSize().height-15))
	titleBg:addChild(self.closeBtn,1)

	local ttPy=titleBgHeight-130
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" then
		local titlePx=180
		for i=1,4 do
			local titlePic
			if i==1 then
				titlePic="mei_cn.png"
			elseif i==2 then
				titlePic="ri_cn.png"
			elseif i==3 then
				titlePic="jie_cn.png"
			else
				titlePic="bao_cn.png"
			end
			if titlePic then
				local titleSp=CCSprite:createWithSpriteFrameName(titlePic)
				if titleSp then
					titleSp:setScale(2)
					titleSp:setAnchorPoint(ccp(0,0.5))
					titleSp:setPosition(ccp(titlePx,ttPy))
					titleBg:addChild(titleSp,1)
					titlePx=titlePx+titleSp:getContentSize().width*2+5
				end
			end
		end
	elseif G_getCurChoseLanguage()=="fr" then
		local titleSp=CCSprite:createWithSpriteFrameName("newsTitle_fr.png")
		titleSp:setScale(1.6)
		titleSp:setAnchorPoint(ccp(0.5,0.5))
		titleSp:setPosition(ccp(titleBg:getContentSize().width/2,ttPy))
		titleBg:addChild(titleSp,1)
	else
		local titleSp=CCSprite:createWithSpriteFrameName("newsTitle_en.png")
		titleSp:setScale(1.6)
		titleSp:setAnchorPoint(ccp(0.5,0.5))
		titleSp:setPosition(ccp(titleBg:getContentSize().width/2,ttPy))
		titleBg:addChild(titleSp,1)
	end	

	posy=posy-35
	ttPy=ttPy-35
	local numLb=GetTTFLabelWrap(getlocal("dailyNews_journals_num",{journalsNum}),16,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
	numLb:setAnchorPoint(ccp(0,0))
	numLb:setPosition(ccp(posx,ttPy))
	titleBg:addChild(numLb,1)
	numLb:setColor(G_ColorBlack)
	local dateLb=GetTTFLabel(G_getDateStr(time,true,true),16)
	dateLb:setAnchorPoint(ccp(1,0))
	dateLb:setPosition(ccp(titleBgWidth-posx,ttPy))
	titleBg:addChild(dateLb,1)
	dateLb:setColor(G_ColorBlack)

	-- require "luascript/script/game/scene/gamedialog/dailyNews/dailyNewsHeadlines"
	-- -- local headlinesBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
	-- local dhDialog=dailyNewsHeadlines:new()
 --    local headlinesBg=dhDialog:init(layerNum)
	-- -- headlinesBg:setContentSize(CCSizeMake(bgWidth,bgHeight-480))
	headlinesBg:setAnchorPoint(ccp(0.5,1))
	headlinesBg:setPosition(ccp(bgWidth/2,posy))
	dialogBg:addChild(headlinesBg)
	-- headlinesBg:setOpacity(0)
	-- headlinesBg:setVisible(false)


	if isShowNewsList==true then
		local bottomBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
		-- bottomBg:setContentSize(CCSizeMake(bgWidth,bgHeight-595))
		bottomBg:setContentSize(CCSizeMake(bgWidth,bottomBgH))
		bottomBg:setAnchorPoint(ccp(0.5,0))
		dialogBg:addChild(bottomBg)
		bottomBg:setOpacity(0)
		if isCanEdit==true then
			bottomBg:setPosition(ccp(bgWidth/2,90))
		else
			bottomBg:setPosition(ccp(bgWidth/2,90-60+20))
		end
		self.bottomBg=bottomBg

		-- posy=posy-60
		local bottomBgWidth,bottomBgHeight=bottomBg:getContentSize().width,bottomBg:getContentSize().height
		local tvHeight=bottomBgHeight-40
		local tmpBg=CCSprite:createWithSpriteFrameName("newsTitleBg.png")
		local cellWidth,cellHeight=tmpBg:getContentSize().width*2,120
		local function clickHandler( ... )
			if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)

	        if self.openHeadlines==0 then
	        	local addHeight=self.headlinesBg:getContentSize().height-20
	        	local resetAdd=0
	        	if self.addH then
	        		resetAdd=self.addH
	        	end
		  		dhDialog:updateHeadlines(false)
				if bottomBg then
					bottomBg:setPosition(ccp(bgWidth/2,bottomBg:getPositionY()+addHeight+resetAdd*2))
				end
				if self.tvBg then
					self.tvBg:setContentSize(CCSizeMake(cellWidth,tvHeight+addHeight+resetAdd*2))
					self.tvBg:setPosition(ccp(bottomBgWidth/2,0-addHeight-resetAdd*2))
				end
				if self.tv then
					self.tv:setViewSize(CCSizeMake(self.subTitle2Bg:getContentSize().width*2,tvHeight+addHeight+resetAdd*2))
					self.tv:setPosition(ccp((bottomBgWidth-cellWidth)/2,0-addHeight-resetAdd*2))
					local recordPoint = self.tv:getRecordPoint()
					self.tv:reloadData()
					recordPoint.y=recordPoint.y+addHeight+resetAdd*2
					self.tv:recoverToRecordPoint(recordPoint)
				end
	        	self.openHeadlines=1
	        	self:refreshForbidSp()
	        else
	        	local addHeight=self.headlinesBg:getContentSize().height-20
	        	local resetAdd=0
	        	if self.addH then
	        		resetAdd=self.addH
	        	end
		  		dhDialog:updateHeadlines(true)
				if bottomBg then
					bottomBg:setPosition(ccp(bgWidth/2,bottomBg:getPositionY()-addHeight-resetAdd*2))
				end
				if self.tvBg then
					self.tvBg:setContentSize(CCSizeMake(cellWidth,tvHeight))
					self.tvBg:setPosition(ccp(bottomBgWidth/2,0))
				end
				if self.tv then
					self.tv:setViewSize(CCSizeMake(self.subTitle2Bg:getContentSize().width*2,tvHeight))
					self.tv:setPosition(ccp((bottomBgWidth-cellWidth)/2,0))
					local recordPoint = self.tv:getRecordPoint()
					self.tv:reloadData()
					recordPoint.y=recordPoint.y-addHeight-resetAdd*2
					self.tv:recoverToRecordPoint(recordPoint)
				end
	        	self.openHeadlines=0
	        	self:refreshForbidSp()
	        end
		end
		local subTitle2Bg=CCSprite:createWithSpriteFrameName("newsTitleBg.png")
		-- subTitle2Bg:setTouchPriority(-(layerNum-1)*20-4)
		local titlePy=bottomBgHeight-subTitle2Bg:getContentSize().height
		subTitle2Bg:setScale(2)
		subTitle2Bg:setPosition(ccp(bottomBgWidth/2,titlePy))
		bottomBg:addChild(subTitle2Bg)
		self.subTitle2Bg=subTitle2Bg
		local subTitleMaskBg=LuaCCSprite:createWithSpriteFrameName("newsTitleBg.png",clickHandler)
		subTitleMaskBg:setScaleX(2)
		subTitleMaskBg:setScaleY(3)
		subTitleMaskBg:setTouchPriority(-(layerNum-1)*20-4)
		subTitleMaskBg:setPosition(ccp(bottomBgWidth/2,titlePy))
		bottomBg:addChild(subTitleMaskBg)
		subTitleMaskBg:setOpacity(0)
		local subTitle2Lb=GetTTFLabel(getlocal("dailyNews_daily_news"),25)
		subTitle2Lb:setPosition(ccp(bottomBgWidth/2,titlePy))
		bottomBg:addChild(subTitle2Lb,1)
		
		local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("newsContentBg.png",CCRect(4, 4, 1, 1),function ()end)
		tvBg:setContentSize(CCSizeMake(cellWidth,tvHeight))
		tvBg:setAnchorPoint(ccp(0.5,0))
		tvBg:setPosition(ccp(bottomBgWidth/2,0))
		bottomBg:addChild(tvBg,1)
		self.tvBg=tvBg
		
		local messageIcon=CCSprite:createWithSpriteFrameName("newsMessageBtn.png")
		-- messageIcon:setTouchPriority(-(layerNum-1)*20-4)
		messageIcon:setPosition(ccp(bottomBgWidth-70,titlePy))
		bottomBg:addChild(messageIcon,1)
		local moveTime=0.5
		local scaleTo1=CCScaleTo:create(moveTime,1.2)
		local scaleTo2=CCScaleTo:create(moveTime,1)
		local scaleTo1=CCScaleTo:create(moveTime,1.2)
		local scaleTo2=CCScaleTo:create(moveTime,1)
		local delay=CCDelayTime:create(moveTime*2)
		local acArr=CCArray:create()
		acArr:addObject(scaleTo1)
		acArr:addObject(scaleTo2)
		acArr:addObject(scaleTo1)
		acArr:addObject(scaleTo2)
		acArr:addObject(delay)
		local seq=CCSequence:create(acArr)
		local repeatForever=CCRepeatForever:create(seq)
		messageIcon:runAction(repeatForever)

		-- local tvHeight=bottomBgHeight-40
		-- local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("newsContentBg.png",CCRect(4, 4, 1, 1),function ()end)
		-- tvBg:setContentSize(CCSizeMake(cellWidth,tvHeight))
		-- tvBg:setAnchorPoint(ccp(0.5,0))
		-- tvBg:setPosition(ccp(bottomBgWidth/2,0))
		-- bottomBg:addChild(tvBg,1)

		local cellNum=SizeOfTable(newsList)
		for k,v in pairs(newsList) do
			if v and v.type then
				local cType
				local dCfg=dailyNewsVoApi:getCfgByType(v.type)
				if dCfg and dCfg.type then
					cType=dCfg.type
				end
				local content=v.content or ""
				-- print("content",content)
				local contentLb=GetTTFLabelWrap(content,20,CCSizeMake(cellWidth-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				-- print("contentLb:getContentSize().height",contentLb:getContentSize().height)
				local cellHeight=contentLb:getContentSize().height+24
				if cellHeight<70 then
					cellHeight=70
				end
				self.cellTab[k]={content=content,cellHeight=cellHeight,cType=cType,dVo=v}
			end
		end
		local function tvCallBack(handler,fn,idx,cel)
		    if fn=="numberOfCellsInTableView" then
		        return cellNum
		    elseif fn=="tableCellSizeForIndex" then
		        local cellHeight=0
		        if self.cellTab and self.cellTab[idx+1] and self.cellTab[idx+1].cellHeight then
		        	cellHeight=self.cellTab[idx+1].cellHeight
		        end
		        local tmpSize=CCSizeMake(cellWidth,cellHeight)
		        return tmpSize
		    elseif fn=="tableCellAtIndex" then
		        local cell=CCTableViewCell:new()
		        cell:autorelease()

		        local newsData=self.cellTab[idx+1] or {}
		        local cellHeight=0
		        if newsData and newsData.cellHeight then
		        	cellHeight=newsData.cellHeight
		        end

		  --       local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("newsContentBg.png",CCRect(4, 4, 1, 1),function ()end)
				-- cellBg:setTouchPriority(-(layerNum-1)*20-1)
				-- cellBg:setContentSize(CCSizeMake(cellWidth,cellHeight+2))
				-- -- cellBg:setOpacity(180)
				-- cellBg:setPosition(ccp(cellWidth/2,cellHeight/2))
				-- cell:addChild(cellBg,1)

				local line=CCSprite:createWithSpriteFrameName("lineWhite.png")
				line:setScaleX((cellWidth-40)/line:getContentSize().width)
				line:setPosition(ccp(cellWidth/2,0))
				cell:addChild(line,1)
				line:setColor(G_ColorBlack)

				local function showInfo( ... )
					if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
						if G_checkClickEnable()==false then
				            do
				                return
				            end
				        else
				            base.setWaitTime=G_getCurDeviceMillTime()
				        end
				        PlayEffect(audioCfg.mouseClick)
						dailyNewsVoApi:showDailyNewsInfoDialog(newsData.cType,layerNum+1,newsData.dVo)
					end
				end
				local photoSp=dailyNewsVoApi:getNewsIcon(newsData.dVo,showInfo,60)
				if photoSp then
					photoSp:setPosition(ccp(50,cellHeight/2))
					photoSp:setTouchPriority(-(layerNum-1)*20-2)
					cell:addChild(photoSp,2)
				end

				local contentLb=GetTTFLabelWrap(newsData.content or "",20,CCSizeMake(cellWidth-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				contentLb:setAnchorPoint(ccp(0,0.5))
				contentLb:setPosition(ccp(90,cellHeight/2))
				cell:addChild(contentLb,2)
				contentLb:setColor(G_ColorBlack)
		        
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
		local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(subTitle2Bg:getContentSize().width*2,tvHeight),nil)
		tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
		tv:setPosition(ccp((bottomBgWidth-cellWidth)/2,0))
		bottomBg:addChild(tv,2)
		tv:setMaxDisToBottomOrTop(120)
		self.tv=tv

		self:addForbidSp()

		if isCanEdit==true then
			local function operateHandler(tag,object)
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
		        
		        if tag==11 then --邮件，给别人发邮件（头条的内容）
			        self:close()
			        activityAndNoteDialog:closeAllDialog()
			        require "luascript/script/game/scene/gamedialog/emailDetailDialog"
					local lyNum=layerNum-1
					local headlinesNewsData=G_clone(dailyNewsVoApi:getHeadlinesNews())
					if headlinesNewsData then
						local journalsNum=dailyNewsVoApi:getJournalsNum() or 0
						local journalsDate=dailyNewsVoApi:getLastGetDataTime()
						headlinesNewsData.journalsNum=journalsNum
						headlinesNewsData.journalsDate=journalsDate
					end
					emailVoApi:showWriteEmailDialog(lyNum,getlocal("email_write"),nil,nil,nil,nil,headlinesNewsData)
				elseif tag==12 then --收藏，给自己发邮件（头条的内容）
					local lastCollectTime=dailyNewsVoApi:getLastCollectTime()
					local diffTime,timeInterval=0,300
					if lastCollectTime then
						diffTime=base.serverTime-lastCollectTime
					end
					if diffTime<timeInterval then
						smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("dailyNews_limit_collect",{timeInterval-diffTime}),true,self.layerNum+1)
						do return end
					end
					local headlinesNewsData=G_clone(dailyNewsVoApi:getHeadlinesNews())
					if headlinesNewsData and SizeOfTable(headlinesNewsData)>0 then
						local journalsNum=dailyNewsVoApi:getJournalsNum() or 0
						local journalsDate=dailyNewsVoApi:getLastGetDataTime()
						headlinesNewsData.journalsNum=journalsNum
						headlinesNewsData.journalsDate=journalsDate
						local content={headlinesData=headlinesNewsData,content=""}
						local function sendEmailCallback(fn,data)
							local ret,sData=base:checkServerData(data)
					        if ret==true then
								base:tick()
								smallDialog:showTipsDialog("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_news_collect_success"),30)
								if sData.ts then
									dailyNewsVoApi:setLastCollectTime(tonumber(sData.ts))
								end
							end
						end
						local data={name=playerVoApi:getPlayerName(),title=56,content=content,type=1}
						socketHelper:mailSendnews(data,sendEmailCallback)
					end
				elseif tag==13 then --分享，发送头条到聊天和facebook
					local function shareHandler(tag,object)
						local headlinesNews=G_clone(dailyNewsVoApi:getHeadlinesNews())
						if tag==nil then
							tag=1
						end
						if tag==1 or tag==2 then
							if chatVoApi:canChat(layerNum+2)==false then
								do return end
							end
							local canSand=false
				            -- local playerLv=playerVoApi:getPlayerLevel()
				            local timeInterval=300--playerCfg.chatLimitCfg[playerLv] or 0
				            local lastShareTime=dailyNewsVoApi:getLastShareTime(tag)
							local diffTime=0
							if lastShareTime then
								diffTime=base.serverTime-lastShareTime--base.lastSendTime
							end
							if diffTime>=timeInterval then
								canSand=true
							end
							if canSand==false then
								smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
								do return end
							end
							local subType,channelType=1,1
							if tag==2 then
								subType=3
								local selfAlliance=allianceVoApi:getSelfAlliance()
								local aid
								if selfAlliance and selfAlliance.aid then
									channelType=selfAlliance.aid+1
								end
							end
							if headlinesNews then
								local newsContent=headlinesNews.content or {}
								local chatContent=getlocal("dailyNews_chat_message",{newsContent})
								local sender=playerVoApi:getUid()
								local senderName=playerVoApi:getPlayerName()
								local level=playerVoApi:getPlayerLevel()
								local rank=playerVoApi:getRank()
								local language=G_getCurChoseLanguage()
								local paramTab={}
								paramTab.functionStr="dnews"
								paramTab.addStr="dailyNews_chat_goTo"
								paramTab.noRich=1
				                local params={subType=subType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=sender,name=senderName,pic=playerVoApi:getPic(),ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle(),paramTab=paramTab,brType=18}
				                chatVoApi:sendChatMessage(channelType,sender,senderName,0,"",params)
				                dailyNewsVoApi:setLastShareTime(tag,base.serverTime)
				                if channelType==1 then
				                	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_news_send_success",{getlocal("dailyNews_today_headlines"),getlocal("report_to_world")}),28)
			                	else
			                		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_news_send_success",{getlocal("dailyNews_today_headlines"),getlocal("alliance_list_scene_name")}),28)
			                	end
							end
						elseif tag==3 then
							local function sendFeedCallback()
								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shareSuccess"),30)
				            end
				            if headlinesNews then
								local message=headlinesNews.content or ""
					            G_sendFeed(1,sendFeedCallback,message)
					        end
					    end
					end
					local worldChatData={btn="BtnRecharge.png",btnDown="BtnRecharge_Down.png",lbStr=getlocal("alliance_send_channel_1"),lbSize=25,callback=shareHandler,tag=1}
					local selectTb={worldChatData}
					local selfAlliance=allianceVoApi:getSelfAlliance()
					if selfAlliance and selfAlliance.aid then
						local allianceData={btn="BtnRecharge.png",btnDown="BtnRecharge_Down.png",lbStr=getlocal("alliance_send_channel_2"),lbSize=25,callback=shareHandler,tag=2}
						table.insert(selectTb,allianceData)
					end
					if G_isShowShareBtn()==true then
						local facebookData={btn="BtnFacebook.png",btnDown="BtnFacebookDown.png",lbStr=getlocal("facebookBtn"),lbSize=25,callback=shareHandler,tag=3}
						table.insert(selectTb,facebookData)
					end
					if selectTb and SizeOfTable(selectTb)>1 then
						smallDialog:shareSelectDialog("PanelHeaderPopup.png",CCSizeMake(450,350),CCRect(168, 86, 10, 10),true,layerNum+1,selectTb)
					else
						shareHandler(1)
					end
				end
			end
			local btnPy=50
			local btnPosTb=G_getIconSequencePosx(2,180,bgWidth/2,3)
			local scale=1
			local emailBtn=GetButtonItem("newsBtnBg.png","newsBtnBg_Down.png","newsBtnBg_Down.png",operateHandler,11,nil,nil,nil,nil,nil,nil,nil,downColor)
			emailBtn:setScale(scale)
			local emailSp=CCSprite:createWithSpriteFrameName("newsBtnEmail.png")
			emailSp:setPosition(getCenterPoint(emailBtn))
			emailBtn:addChild(emailSp,2)
			local emailMenu=CCMenu:createWithItem(emailBtn)
			emailMenu:setTouchPriority(-(layerNum-1)*20-4)
			self.bgLayer:addChild(emailMenu,2)
			emailMenu:setPosition(ccp(btnPosTb[1],btnPy))
			self.emailBtn=emailBtn
			
			local collectionBtn=GetButtonItem("newsBtnBg.png","newsBtnBg_Down.png","newsBtnBg_Down.png",operateHandler,12,nil,nil)
			collectionBtn:setScale(scale)
			local collectionSp=CCSprite:createWithSpriteFrameName("newsBtnCollection.png")
			collectionSp:setPosition(getCenterPoint(collectionBtn))
			collectionBtn:addChild(collectionSp,2)
			local collectionMenu=CCMenu:createWithItem(collectionBtn)
			collectionMenu:setTouchPriority(-(layerNum-1)*20-4)
			self.bgLayer:addChild(collectionMenu,2)
			collectionMenu:setPosition(ccp(btnPosTb[2],btnPy))
			self.collectionBtn=collectionBtn
			
			local shareBtn=GetButtonItem("newsBtnBg.png","newsBtnBg_Down.png","newsBtnBg_Down.png",operateHandler,13,nil,nil)
			shareBtn:setScale(scale)
			local shareSp=CCSprite:createWithSpriteFrameName("newsBtnShare.png")
			shareSp:setPosition(getCenterPoint(shareBtn))
			shareBtn:addChild(shareSp,2)
			local shareMenu=CCMenu:createWithItem(shareBtn)
			shareMenu:setTouchPriority(-(self.layerNum-1)*20-4)
			self.bgLayer:addChild(shareMenu,2)
			shareMenu:setPosition(ccp(btnPosTb[3],btnPy))
			self.shareBtn=shareBtn
		end
	end

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))

	self:show()

	local function dialogListener(event,data)
		if self and self.bgLayer then
			self:close()
		end
	end
	self.dialogListener=dialogListener
    eventDispatcher:addEventListener("dailyNewsSmallDialog.close",self.dialogListener)
end

--显示面板,加效果
function dailyNewsSmallDialog:show()
	-- if self.isSizeAmi==true then
	-- 	self.bgLayer:setScaleY(100/self.bgSize.height)
	-- 	local function callBack()
	-- 		base:cancleWait()
	-- 	end
	-- 	local callFunc=CCCallFunc:create(callBack)

	-- 	local scaleTo1=CCScaleTo:create(0.5,1,1)

	-- 	local acArr=CCArray:create()
	-- 	acArr:addObject(scaleTo1)
	-- 	acArr:addObject(callFunc)

	-- 	local seq=CCSequence:create(acArr)
	-- 	self.bgLayer:runAction(seq)

	-- elseif self.isUseAmi~=nil then
	-- 	local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
	-- 	local function callBack()
	-- 		base:cancleWait()
	-- 	end
	-- 	local callFunc=CCCallFunc:create(callBack)

	-- 	local scaleTo1=CCScaleTo:create(0.1, 1.1);
	-- 	local scaleTo2=CCScaleTo:create(0.07, 1);

	-- 	local spwanArr=CCArray:create()
	-- 	spwanArr:addObject(moveTo)
	-- 	spwanArr:addObject(scaleTo)
	-- 	local swpanAc=CCSpawn:create(spwanArr)
	-- 	acArr:addObject(swpanAc)

	-- 	local acArr=CCArray:create()
	-- 	acArr:addObject(scaleTo1)
	-- 	acArr:addObject(scaleTo2)
	-- 	acArr:addObject(callFunc)

	-- 	local seq=CCSequence:create(acArr)
	-- 	self.bgLayer:runAction(seq)
	-- end
   
   	local beginScale=0.5
   	local finalScale=1.3
   	self.bgLayer:setScale(beginScale)
   	self.bgLayer:setRotation(180)
   	-- if self.isDelay==true then
   	-- 	self.bgLayer:setVisible(false)
   	-- end
   	-- self:setContentVisible(false)
	local function callBack()
		base:cancleWait()
	end
	local callFunc=CCCallFunc:create(callBack)
	-- local actionTime=0.5
	-- local rotateBy=CCRotateBy:create(actionTime,720)
	-- local scaleTo=CCScaleTo:create(actionTime,finalScale)
	-- local spwanArr=CCArray:create()
	-- spwanArr:addObject(rotateBy)
	-- spwanArr:addObject(scaleTo)
	-- local swpanAc=CCSpawn:create(spwanArr)

	local actionTime1=0.3
	local actionTime2=0.2
	local totalTime=actionTime1+actionTime2
	local rotateBy1=CCRotateBy:create(actionTime1,540-(180/4*3))
	local rotateBy2=CCRotateBy:create(actionTime2,180-(180/4*1))
	local scaleValue1=(finalScale-beginScale)*(actionTime1/totalTime)+beginScale
	local scaleValue2=finalScale
	local scaleTo1=CCScaleTo:create(actionTime1,scaleValue1)
	local scaleTo2=CCScaleTo:create(actionTime2,finalScale)
	local spwanArr1=CCArray:create()
	spwanArr1:addObject(rotateBy1)
	spwanArr1:addObject(scaleTo1)
	local swpanAc1=CCSpawn:create(spwanArr1)
	local spwanArr2=CCArray:create()
	spwanArr2:addObject(rotateBy2)
	spwanArr2:addObject(scaleTo2)
	local swpanAc2=CCSpawn:create(spwanArr2)

	local scaleTo3=CCScaleTo:create(0.05,1)
	local acArr=CCArray:create()
	-- if self.isDelay==true then
	-- 	local delay=CCDelayTime:create(0.3)
	-- 	acArr:addObject(delay)
	-- 	local function callBack1()
	-- 		if self and self.bgLayer then
	-- 			self.bgLayer:setVisible(true)
	-- 		end
	-- 	end
	-- 	local callFunc1=CCCallFunc:create(callBack1)
	-- 	acArr:addObject(callFunc1)
	-- end
	-- local function callBack2()
	-- 	self:setContentVisible(true)
	-- end
	-- local callFunc2=CCCallFunc:create(callBack2)
	-- acArr:addObject(swpanAc)
	acArr:addObject(swpanAc1)
	acArr:addObject(swpanAc2)
	-- acArr:addObject(callFunc2)
	acArr:addObject(scaleTo3)
	acArr:addObject(callFunc)
	local seq=CCSequence:create(acArr)
	self.bgLayer:runAction(seq)

	table.insert(G_SmallDialogDialogTb,self)
end

function dailyNewsSmallDialog:setContentVisible(visible)
	if self and visible~=nil then
		if self.titleBg then
			self.titleBg:setVisible(visible)
		end
		if self.headlinesBg then
			self.headlinesBg:setVisible(visible)
		end
		if self.bottomBg then
			self.bottomBg:setVisible(visible)
		end
		if self.emailBtn then
			self.emailBtn:setVisible(visible)
		end
		if self.collectionBtn then
			self.collectionBtn:setVisible(visible)
		end
		if self.shareBtn then
			self.shareBtn:setVisible(visible)
		end
	end
end

function dailyNewsSmallDialog:showSelectComment()
	if self.openHeadlines==1 then
		do return end
	end
	-- if isShow==true then
		-- if self.maskBg==nil then
			if self.emailBtn then
				self.emailBtn:setVisible(false)
			end
			if self.collectionBtn then
				self.collectionBtn:setVisible(false)
			end
			if self.shareBtn then
				self.shareBtn:setVisible(false)
			end

			local selectIndex=1
	    	local maskBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
			maskBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
			maskBg:setPosition(getCenterPoint(self.bgLayer))
			maskBg:setTouchPriority(-(self.layerNum-1)*20-5)
			maskBg:setIsSallow(true)
			-- maskBg:setBSwallowsTouches(true)
			self.bgLayer:addChild(maskBg,6)
			maskBg:setOpacity(0)


			local function onCancel()
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)

				if self.selectBg then
					self.selectBg:removeFromParentAndCleanup(true)
					self.selectBg=nil
				end
				if maskBg then
					maskBg:removeFromParentAndCleanup(true)
					maskBg=nil
				end
				if self.emailBtn then
					self.emailBtn:setVisible(true)
				end
				if self.collectionBtn then
					self.collectionBtn:setVisible(true)
				end
				if self.shareBtn then
					self.shareBtn:setVisible(true)
				end
			end
			local subTitle2Bg=LuaCCSprite:createWithSpriteFrameName("newsTitleBg.png",onCancel)
			subTitle2Bg:setTouchPriority(-(self.layerNum-1)*20-6)
			local selectBgWidth=subTitle2Bg:getContentSize().width*2
			local selectBgHeight=180
			local lbTab={}
			for i=1,4 do
				local comment=getlocal("dailyNews_comment_"..i)
				local commentLb=GetTTFLabelWrap(comment,25,CCSizeMake(selectBgWidth-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				commentLb:setAnchorPoint(ccp(0,1))
				commentLb:setColor(G_ColorBlack)
				lbTab[i]=commentLb
				selectBgHeight=selectBgHeight+commentLb:getContentSize().height+30
			end
			local selectBg=LuaCCScale9Sprite:createWithSpriteFrameName("newsSelectListBg.png",CCRect(5, 5, 1, 1),function ()end)
			selectBg:setContentSize(CCSizeMake(selectBgWidth,selectBgHeight))
			selectBg:setAnchorPoint(ccp(0.5,0))
			selectBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,90))
			self.bgLayer:addChild(selectBg,7)
			self.selectBg=selectBg

			local posy=selectBg:getContentSize().height-subTitle2Bg:getContentSize().height
			subTitle2Bg:setScale(2)
			subTitle2Bg:setPosition(ccp(selectBg:getContentSize().width/2,posy))
			selectBg:addChild(subTitle2Bg)
			local subTitle2Lb=GetTTFLabel(">>"..getlocal("dailyNews_say_something"),25)
			subTitle2Lb:setAnchorPoint(ccp(0,0.5))
			subTitle2Lb:setPosition(ccp(10,posy))
			selectBg:addChild(subTitle2Lb,1)

			posy=posy-20
			local selectedBgTb={}
			for k,v in pairs(lbTab) do
				if v then
					local lb=tolua.cast(v,"CCLabelTTF")
					if lb then
						posy=posy-10
						local selectedBg=LuaCCScale9Sprite:createWithSpriteFrameName("newsSelectBg.png",CCRect(5, 5, 1, 1),function ()end)
						selectedBg:setContentSize(CCSizeMake(selectBg:getContentSize().width-10,lb:getContentSize().height+20))
						selectedBg:setAnchorPoint(ccp(0.5,1))
						selectedBg:setPosition(ccp(selectBg:getContentSize().width/2,posy))
						selectBg:addChild(selectedBg,8)
						if k==selectIndex then
						else
							selectedBg:setVisible(false)
						end
						selectedBgTb[k]=selectedBg
						local function clickHandler(object,fn,tag)
							if G_checkClickEnable()==false then
					            do
					                return
					            end
					        else
					            base.setWaitTime=G_getCurDeviceMillTime()
					        end
					        PlayEffect(audioCfg.mouseClick)

					        selectIndex=tag
							for m,n in pairs(selectedBgTb) do
								if m==selectIndex then
									selectedBgTb[m]:setVisible(true)
								else
									selectedBgTb[m]:setVisible(false)
								end
							end
						end
						local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("newsContentBg.png",CCRect(5, 5, 1, 1),clickHandler)
						lbBg:setTouchPriority(-(self.layerNum-1)*20-6)
						lbBg:setContentSize(CCSizeMake(selectBg:getContentSize().width-10,lb:getContentSize().height+20))
						lbBg:setAnchorPoint(ccp(0.5,1))
						lbBg:setPosition(ccp(selectBg:getContentSize().width/2,posy))
						lbBg:setTag(k)
						selectBg:addChild(lbBg,7)
						local flagSp=CCSprite:createWithSpriteFrameName("newsFlag.png")
						flagSp:setPosition(ccp(23,posy-24))
						selectBg:addChild(flagSp,8)
						flagSp:setScale(1.2)
						posy=posy-10
						lb:setPosition(ccp(40,posy))
						selectBg:addChild(lb,9)
						posy=posy-lb:getContentSize().height-10
					end
				end
			end

			local function onConfim()
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
  
  				local function commentCallback( ... )
			        -- print("selectIndex--->",getlocal("dailyNews_comment_"..selectIndex))
					if self.dhDialog and self.dhDialog.updateComment then
						local comment=getlocal("dailyNews_comment_"..selectIndex)
						local addH=self.dhDialog:updateComment(comment)/2
						if self.dnDialogBg then
							self.dnDialogBg:setScale(1)
							local tmpWidth,tmpHeight=self.dnDialogBg:getContentSize().width,self.dnDialogBg:getContentSize().height
							self.dnDialogBg:setContentSize(CCSizeMake(tmpWidth,tmpHeight+addH))
							self.dnDialogBg:setScale(2)
						end
						local function resetPosy(object,addHeight)
							if object and object.setPosition then
								object:setPosition(ccp(object:getPositionX(),object:getPositionY()+addHeight))
							end
						end
						resetPosy(self.titleBg,addH)
						resetPosy(self.headlinesBg,addH)
						resetPosy(self.bottomBg,0-addH)
						resetPosy(self.emailBtn,0-addH)
						resetPosy(self.collectionBtn,0-addH)
						resetPosy(self.shareBtn,0-addH)
						self.addH=addH
					end

					if selectBg then
						selectBg:removeFromParentAndCleanup(true)
						selectBg=nil
					end
					if maskBg then
						maskBg:removeFromParentAndCleanup(true)
						maskBg=nil
					end
					if self.emailBtn then
						self.emailBtn:setVisible(true)
					end
					if self.collectionBtn then
						self.collectionBtn:setVisible(true)
					end
					if self.shareBtn then
						self.shareBtn:setVisible(true)
					end
					
					self:refreshForbidSp()

					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_news_comment"),30)

					local journalsNum=dailyNewsVoApi:getJournalsNum() or 0
			        chatVoApi:sendUpdateMessage(45,{selectIndex=selectIndex,commentPlayer=playerVoApi:getPlayerName(),journalsNum=journalsNum})
				end
				dailyNewsVoApi:dailynewsNewsComment(selectIndex,commentCallback)
			end
			local confimItem = GetButtonItem("newsBtnBg.png","newsBtnBg.png","newsBtnBg.png",onConfim,nil,getlocal("confirm"),25)
			local confimMenu = CCMenu:createWithItem(confimItem)
			confimMenu:setTouchPriority(-(self.layerNum-1)*20-6)
			confimMenu:setPosition(ccp(150,40))
			selectBg:addChild(confimMenu,1)

			-- local function onCancel()
			-- 	if G_checkClickEnable()==false then
		 --            do
		 --                return
		 --            end
		 --        else
		 --            base.setWaitTime=G_getCurDeviceMillTime()
		 --        end
		 --        PlayEffect(audioCfg.mouseClick)

			-- 	if selectBg then
			-- 		selectBg:removeFromParentAndCleanup(true)
			-- 		selectBg=nil
			-- 	end
			-- 	if maskBg then
			-- 		maskBg:removeFromParentAndCleanup(true)
			-- 		maskBg=nil
			-- 	end
			-- 	if self.emailBtn then
			-- 		self.emailBtn:setVisible(true)
			-- 	end
			-- 	if self.collectionBtn then
			-- 		self.collectionBtn:setVisible(true)
			-- 	end
			-- 	if self.shareBtn then
			-- 		self.shareBtn:setVisible(true)
			-- 	end
			-- end
			local cancelItem = GetButtonItem("newsBtnBg.png","newsBtnBg.png","newsBtnBg.png",onCancel,nil,getlocal("cancel"),25)
			local cancelMenu = CCMenu:createWithItem(cancelItem)
			cancelMenu:setTouchPriority(-(self.layerNum-1)*20-6)
			cancelMenu:setPosition(ccp(selectBg:getContentSize().width-150,40))
			selectBg:addChild(cancelMenu,1)

			posy=(posy+70)/2
			local descLb=GetTTFLabelWrap(getlocal("dailyNews_comment_desc"),25,CCSizeMake(selectBg:getContentSize().width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			descLb:setPosition(ccp(selectBg:getContentSize().width/2,posy))
			descLb:setColor(G_ColorRed)
			selectBg:addChild(descLb,1)

	    -- end
	-- else
	-- 	if self.maskBg then
	-- 		self.maskBg:setPosition(ccp(10000,0))
	-- 	end
	-- end
	return true
end

function dailyNewsSmallDialog:addForbidSp()
	local function forbidClick()
    end
	local rect2 = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
	topforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
	topforbidSp:setAnchorPoint(ccp(0,0))
	self.dialogLayer:addChild(topforbidSp)
	topforbidSp:setVisible(false)

	local bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
	bottomforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
	bottomforbidSp:setAnchorPoint(ccp(0,0))
	bottomforbidSp:setPosition(0,0)
	self.dialogLayer:addChild(bottomforbidSp)
	bottomforbidSp:setVisible(false)

	local tvX,tvY=self.tv:getPosition()
	local tvHeight=self.tv:getViewSize().height
	local worldPsos=self.bottomBg:convertToWorldSpaceAR(ccp(tvX,tvY))

	bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,worldPsos.y))
	topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-worldPsos.y-tvHeight))
	topforbidSp:setPosition(0,worldPsos.y+tvHeight)
	self.topforbidSp=topforbidSp
	self.bottomforbidSp=bottomforbidSp
end

function dailyNewsSmallDialog:refreshForbidSp()
	if self.tv then
		local tvX,tvY=self.tv:getPosition()
		local tvHeight=self.tv:getViewSize().height
		local worldPsos=self.bottomBg:convertToWorldSpaceAR(ccp(tvX,tvY))

		self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,worldPsos.y))
		self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-worldPsos.y-tvHeight))
		self.topforbidSp:setPosition(0,worldPsos.y+tvHeight)
	end
end

function dailyNewsSmallDialog:dispose()
	self.openHeadlines=nil
	self.cellTab=nil
	if self.dhDialog and self.dhDialog.dispose then
		self.dhDialog:dispose()
	end
	self.headlinesBg=nil
	-- self.isDelay=nil
	spriteController:removePlist("public/dailyNews.plist")
    spriteController:removeTexture("public/dailyNews.png")
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
    eventDispatcher:removeEventListener("dailyNewsSmallDialog.close",self.dialogListener)
end


