warStatueDialog=commonDialog:new()

function warStatueDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function warStatueDialog:initTableView()
	self.panelLineBg:setVisible(false)
	local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)
	spriteController:addTexture("public/acKafkaGift.pvr.ccz")
	spriteController:addPlist("public/acKafkaGift.plist")
    spriteController:addPlist("public/warStatue/warStatue_images.plist")
    spriteController:addTexture("public/warStatue/warStatue_images.png")
  	spriteController:addPlist("public/warStatue/warStatue_images3.plist")
    spriteController:addTexture("public/warStatue/warStatue_images3.png")
   	spriteController:addPlist("public/youhuaUI3.plist")
	spriteController:addTexture("public/youhuaUI3.png")

    self.selectSid=warStatueVoApi:getSelectSid()
    self.curSid,self.sc=self.selectSid,5
    self.maxShowPageNum,self.curShowPage=math.ceil(SizeOfTable(statueCfg.room)/self.sc),math.ceil(self.curSid/self.sc)
    self.pageSelectIdxTb,self.showPageTb={},{}
    local selectIdx=1
    for i=1,self.maxShowPageNum do
    	if self.curShowPage==i then
    		self.pageSelectIdxTb[i]=self.curSid-(i-1)*self.sc
    	else
    		self.pageSelectIdxTb[i]=1
    	end
    end
	self.touchArr={}
    self.minTouchx,self.maxTouchx=0,G_VisibleSizeWidth
    self.minTouchy,self.maxTouchy=G_VisibleSizeHeight-560,G_VisibleSizeHeight-80
    self.moveDisX=100
    self.moveFlag,self.movePageFlag=false,false
    
    local touchLayer=CCLayer:create()
    self.bgLayer:addChild(touchLayer,2)
    touchLayer:setBSwallowsTouches(false)
    touchLayer:setTouchEnabled(true)
    local function tmpHandler(...)
       return self:touchEvent(...)
    end
    touchLayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-5,false)
    touchLayer:setTouchPriority(-(self.layerNum-1)*20-5)

    self.url=G_downloadUrl("function/".."warstatue_bg.jpg")
    local function onLoadIcon(fn,warStatueBg)
        if self and self.bgLayer then
            if self.bgLayer then
                warStatueBg:setAnchorPoint(ccp(0.5,1))
                self.bgLayer:addChild(warStatueBg)
                warStatueBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-80)
            end
        end
    end
   
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
 	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local function onSelect(object,fn,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
    	if self:canMove()==false or (self.selectSid==self.curSid) then
    		do return end
    	end
		self.checkBox:setVisible(true)
		self.uncheckBox:setVisible(false)
		self.selectSid=self.curSid
		warStatueVoApi:saveSelectSid(self.selectSid)
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("selectWarStatuePromptStr"),28)
	    local data={btype=107}
        eventDispatcher:dispatchEvent("baseBuilding.build.refresh",data) --通知主页面更换显示雕像
    end
    local checkBoxSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),onSelect)
    checkBoxSp:setTouchPriority(-(self.layerNum-1)*20-5)
    checkBoxSp:setContentSize(CCSizeMake(80,80))
    checkBoxSp:setAnchorPoint(ccp(0,0.5))
    checkBoxSp:setVisible(false)
    checkBoxSp:setOpacity(0)
    self.bgLayer:addChild(checkBoxSp,12)
    self.checkBoxSp=checkBoxSp
    local function nilFunc()
    end
    local checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",nilFunc)
    checkBox:setPosition(getCenterPoint(checkBoxSp))
    checkBoxSp:addChild(checkBox)
    self.checkBox=checkBox
    local uncheckBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",nilFunc)
    uncheckBox:setPosition(getCenterPoint(checkBoxSp))
    checkBoxSp:addChild(uncheckBox)
    self.uncheckBox=uncheckBox

  	self.statueSpTb,self.activeEffectTb={},{}
	--iphonex 适配 调整适配
	local displayAddH=0
	if G_getIphoneType() == G_iphoneX then
		displayAddH=295
	elseif G_isIphone5()==true then
		displayAddH=176
	end
    self.displayCfg={{322,605+displayAddH,1,0,10},{521,671+displayAddH,0.75,0.3,8},{407,750+displayAddH,0.55,0.5,6},{235,750+displayAddH,0.55,0.5,6},{123,671+displayAddH,0.75,0.3,8}}

   	local clipper=CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    clipper:setAnchorPoint(ccp(0,0))
    clipper:setPosition(0,0)
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(616,480),1,1)
    stencil:setPosition(12,G_VisibleSizeHeight-560)
    clipper:setStencil(stencil)
    self.bgLayer:addChild(clipper,2)
    self.clipper=clipper

    self:initShowPage(self.curShowPage) --初始化当前选中的塑像页
	self:initBuffDetail()

    local function refreshBuff(event,data)
    	if data and data.sid then
    		self:refreshWarStatueInfo(data.sid)
    	end
    	if data.rf==nil or data.rf==true then
        	self:refreshBuffDetail(true)
    	end
    	self:refreshTip()
    end
    self.refreshBuffListener=refreshBuff
    eventDispatcher:addEventListener("warstatue.refresh",refreshBuff)

    local function touchTip()
        local tabStr={}
        for i=1,4 do
            local str=getlocal("warStatue_rule"..i)
            table.insert(tabStr,str)
        end
        local titleStr=getlocal("shuoming")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
    end
    G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight-130),nil,nil,1,nil,touchTip,true)

    local btnPos,priority=ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight-480),-(self.layerNum-1)*20-4
    local function goHandler()
    	if self:canMove()==false then
    		do return end
    	end
    	if self.curShowPage==1 then
    		self:rightShowPage()
    	end
    end
   	self.goBtn=G_createBotton(self.bgLayer,btnPos,nil,"newGoBtn.png","newGoBtn_Down.png","newGoBtn_Down.png",goHandler,1,priority,5)

    local function backHandler()
    	if self:canMove()==false then
    		do return end
    	end
    	if self.curShowPage==2 then
    		self:leftShowPage()
    	end
    end
   	self.backBtn=G_createBotton(self.bgLayer,btnPos,nil,"repatriateBtn.png","repatriateBtnDown.png","repatriateBtnDown.png",backHandler,1,priority,5)

   	local tipSp=CCSprite:createWithSpriteFrameName("NumBg.png")
    tipSp:setPosition(btnPos.x+28,btnPos.y+28)
    tipSp:setScale(0.6)
    tipSp:setVisible(false)
    self.bgLayer:addChild(tipSp,5)
    self.tipSp=tipSp

   	self:refreshSwitchBtn()
   	self:refreshTip()
end

function warStatueDialog:initShowPage(page)
	if self.showPageTb[page] then
		do return self.showPageTb[page] end
	end
	local pageLayer=CCLayer:create()
	pageLayer:setAnchorPoint(ccp(0,0))
	pageLayer:setPosition(0,0)
	self.clipper:addChild(pageLayer,2)

	for i=1,self.sc do
		local idx=self.pageSelectIdxTb[page]+i-1
		if idx>self.sc then
			idx=idx-self.sc
		end
		local sid=self:getSidByPageAndIdx(page,idx)
		local statuePic,statueNameStr="warstatue_"..sid..".png",getlocal("warStatue_name_"..sid)
		if warStatueVoApi:isWarStatueExist(sid)==false then --没有该塑像显示默认的塑像
			statuePic,statueNameStr="warstatue_null.png",getlocal("achievement_willOpen")
		end
		local zorder,baseTag=self.displayCfg[i][5],100

		local function showWarStatueDetail()
			if self:canMove()==false then
				do return end
			end
	        if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        local function realShow(dt)
		        if warStatueVoApi:isWarStatueExist(sid)==false then --雕像不存在的时候提示“敬请期待”
	     			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("achievement_willOpen"),28)
		        	do return end
		        end
				local unlockFlag,openLv=warStatueVoApi:isWarStatueUnlock(sid)
				if unlockFlag==false then
	     			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("alliance_unlock_str2",{openLv}),28)
					do return end
				end
				warStatueVoApi:showWarStatueDetailDialog(sid,self.layerNum+1)
	        end
			local statueSp=tolua.cast(self.statueSpTb[sid][1],"LuaCCScale9Sprite")
			if statueSp then
				local idx=statueSp:getTag()-baseTag
				if idx~=1 then
					local function callhandler( ... )
						realShow()
					end
					self:resetWarStatueShow(sid,idx,callhandler)
				else
					realShow()
				end
			end
		end
		local sposx,sposy,scale,opacityRatio=self.displayCfg[i][1],self.displayCfg[i][2],self.displayCfg[i][3],self.displayCfg[i][4]

		local iconSp=CCSprite:createWithSpriteFrameName(statuePic)
	    local statueSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),showWarStatueDetail)
	    statueSp:setTouchPriority(-(self.layerNum-1)*20-4)
	    statueSp:setContentSize(iconSp:getContentSize())
	    statueSp:setPosition(sposx,sposy)
		statueSp:setScale(scale)
	    statueSp:setTag(baseTag+i)
	    statueSp:setOpacity(0)
	    pageLayer:addChild(statueSp,zorder)

		iconSp:setPosition(getCenterPoint(statueSp))
		statueSp:addChild(iconSp,2)

		local statueInfoBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg_black.png",CCRect(20, 20, 10, 10),function () end)
		statueInfoBg:setContentSize(CCSizeMake(200,80))
		statueInfoBg:setOpacity(150)
		statueInfoBg:setVisible(false)
		statueInfoBg:setPosition(statueSp:getContentSize().width/2,40)
		statueSp:addChild(statueInfoBg,3)

        local nameLb=GetTTFLabelWrap(statueNameStr,20,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        statueInfoBg:addChild(nameLb)

        if warStatueVoApi:isWarStatueExist(sid)==false then
	        nameLb:setPosition(getCenterPoint(statueInfoBg))
	        nameLb:setColor(G_ColorRed)
        else
	        nameLb:setPosition(statueInfoBg:getContentSize().width/2,statueInfoBg:getContentSize().height-nameLb:getContentSize().height/2-10)
        end

		local shadeSp=CCSprite:createWithSpriteFrameName(statuePic)
		shadeSp:setColor(G_ColorBlack)
		shadeSp:setOpacity(255*opacityRatio)
		shadeSp:setPosition(getCenterPoint(iconSp))
		iconSp:addChild(shadeSp)

       	local tipSp=CCSprite:createWithSpriteFrameName("NumBg.png")
        tipSp:setPosition(statueSp:getContentSize().width-60,statueSp:getContentSize().height-40)
        tipSp:setVisible(false)
        statueSp:addChild(tipSp,5)

        local activeHeroSpTb,unlockLb=nil,nil
		self.statueSpTb[sid]={statueSp,shadeSp,statueInfoBg,activeHeroSpTb,unlockLb,tipSp,nameLb}
		self.activeEffectTb[sid]={}

		self:refreshWarStatueInfo(sid)
	end

	self.showPageTb[page]=pageLayer

	return pageLayer
end

function warStatueDialog:leftShowPage()
	if self.curShowPage<=1 then
		do return end
	end
	if self:canMove()==false then
		do return end
	end
	self.movePageFlag=true
	self:refreshCheckBox()
	local curPage=self.showPageTb[self.curShowPage]
	self.curShowPage=self.curShowPage-1
	local nextPage=self.showPageTb[self.curShowPage]
	if nextPage==nil then
		nextPage=self:initShowPage(self.curShowPage)
	end
	local leftPosX,centerPosX,rightPosX=-G_VisibleSizeWidth,0,G_VisibleSizeWidth
	nextPage:setPosition(leftPosX,0)
	local mt=0.5
	local moveTo1=CCMoveTo:create(mt,ccp(rightPosX,0))
	local moveTo2=CCMoveTo:create(mt,ccp(centerPosX,0))
	local function moveEnd()
		self:onMoveShowPageEnd()
	end
	curPage:runAction(moveTo1)
	nextPage:runAction(CCSequence:createWithTwoActions(moveTo2,CCCallFunc:create(moveEnd)))
end

function warStatueDialog:rightShowPage()
	if self.curShowPage>=self.maxShowPageNum then
		do return end
	end
	if self:canMove()==false then
		do return end
	end
	self.movePageFlag=true
	self:refreshCheckBox()
	local curPage=self.showPageTb[self.curShowPage]
	self.curShowPage=self.curShowPage+1
	local nextPage=self.showPageTb[self.curShowPage]
	if nextPage==nil then
		nextPage=self:initShowPage(self.curShowPage)
	end
	local leftPosX,centerPosX,rightPosX=-G_VisibleSizeWidth,0,G_VisibleSizeWidth
	nextPage:setPosition(rightPosX,0)
	local mt=0.5
	local moveTo1=CCMoveTo:create(mt,ccp(leftPosX,0))
	local moveTo2=CCMoveTo:create(mt,ccp(centerPosX,0))
	local function moveEnd()
		self:onMoveShowPageEnd()
	end
	curPage:runAction(moveTo1)
	nextPage:runAction(CCSequence:createWithTwoActions(moveTo2,CCCallFunc:create(moveEnd)))
end

function warStatueDialog:onMoveShowPageEnd()
	self.movePageFlag=false
	self:refreshSwitchBtn()
	self:setCurSid()
	self:refreshCheckBox("s"..self.curSid)
end

function warStatueDialog:setCurSid()
	self.curSid=(self.curShowPage-1)*self.sc+self.pageSelectIdxTb[self.curShowPage]
end

function warStatueDialog:canMove()
	if self.moveFlag==true or self.movePageFlag==true then
		return false
	end
	return true
end

function warStatueDialog:refreshWarStatueInfo(sid)
	local baseTag=100
	local statueSp,statueInfoBg=self.statueSpTb[sid][1],self.statueSpTb[sid][3]
	if statueInfoBg then
		local idx=statueSp:getTag()-baseTag
		if idx==3 or idx==4 then
			statueInfoBg:setVisible(false)
		else
			statueInfoBg:setVisible(true)
		end
	end
	if warStatueVoApi:isWarStatueExist(sid)==false then --如果该雕像不存在，没有下面的刷新逻辑
		do return end
	end
	local shadeSp,activeHeroSpTb,unlockLb,tipSp,nameLb=self.statueSpTb[sid][2],self.statueSpTb[sid][4],self.statueSpTb[sid][5],self.statueSpTb[sid][6],self.statueSpTb[sid][7]
	local statueList=warStatueVoApi:getStatueList()
	local herolist=statueCfg.room[sid][2]
	local unlockFlag,openLv=warStatueVoApi:isWarStatueUnlock(sid)
	if unlockFlag==true then
		local ahcount=SizeOfTable(statueList[sid].hero) --激活的将领数量
		if activeHeroSpTb==nil then
			activeHeroSpTb={}
		end
		local iconWidth=26
		local ahero=SizeOfTable(herolist)
		local firstPosX=(statueInfoBg:getContentSize().width-(ahero*iconWidth+(ahero-1)*5))/2
		for i=1,ahero do
			local heroSp=activeHeroSpTb[i]
			local iconStr,tag="heroCap1.png",1000+i
			if i>ahcount then
				iconStr,tag="heroCap2.png",100+i
			end
			if heroSp then
				local curTag=heroSp:getTag()
				if curTag<tag then
			        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(iconStr)
			        if frame then
		            	heroSp:setDisplayFrame(frame)
		            	heroSp:setTag(tag)
		            end
				end
			else
				heroSp=CCSprite:createWithSpriteFrameName(iconStr)
				heroSp:setTag(tag)
				heroSp:setPosition(firstPosX+(2*i-1)*iconWidth*0.5+(i-1)*5,10+heroSp:getContentSize().height*0.5)
				statueInfoBg:addChild(heroSp)
				activeHeroSpTb[i]=heroSp
			end
		end
		self.statueSpTb[sid][4]=activeHeroSpTb
		if unlockLb then
			unlockLb:removeFromParentAndCleanup(true)
			unlockLb=nil
			self.statueSpTb[sid][5]=nil
		end

		if nameLb then
			local buffLv=warStatueVoApi:getWarStatueBuffLv(sid)
			local color=heroVoApi:getHeroColor(buffLv)
			nameLb:setColor(color)
		end

		local activeFlag=false
		for k,hid in pairs(herolist) do
			local flag=warStatueVoApi:getHeroActiveState(sid,hid)
			if flag==1 then
				activeFlag=true
				do break end
			end
		end
		if activeFlag==true then
			tipSp:setVisible(true)
			self:addCanActiveEffect(sid)
		else
			tipSp:setVisible(false)
			self:removeCanActiveEffect(sid)
		end
	else
		if unlockLb==nil then
	        unlockLb=GetTTFLabelWrap(getlocal("functionUnlockStr",{openLv}),20,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	        unlockLb:setPosition(statueInfoBg:getContentSize().width/2,unlockLb:getContentSize().height/2+10)
	        unlockLb:setColor(G_ColorRed)
	        statueInfoBg:addChild(unlockLb)
			self.statueSpTb[sid][5]=unlockLb
		end
	end
	--刷新单选框
	self:refreshCheckBox(sid)
end

function warStatueDialog:refreshCheckBox(sid)
	if sid==nil or warStatueVoApi:isWarStatueExist(sid)==false then
		self.checkBoxSp:setVisible(false)
		self.checkBoxSp:setPosition(999,0)
	end
	if self.statueSpTb==nil or self.statueSpTb[sid]==nil then
		do return end
	end
	local statueSp,statueInfoBg=self.statueSpTb[sid][1],self.statueSpTb[sid][3]
	local curSid="s"..self.curSid
	if sid==curSid then
    	local unlockFlag=warStatueVoApi:isWarStatueUnlock(curSid)
    	if unlockFlag==true then
			self.checkBoxSp:setVisible(true)
			self.checkBoxSp:setPosition(statueSp:getPositionX()+statueInfoBg:getContentSize().width/2-10,statueSp:getPositionY()-70)
		    if self.selectSid~=self.curSid then
		    	self.checkBox:setVisible(false)
		    	self.uncheckBox:setVisible(true)
		    else
		    	self.checkBox:setVisible(true)
		    	self.uncheckBox:setVisible(false)
		    end
    	else --塑像未解锁，不显示选择框
    		self.checkBoxSp:setVisible(false)
    		self.checkBoxSp:setPosition(999,0)
    	end
	end
end

function warStatueDialog:refreshSwitchBtn()
	if self.goBtn and self.backBtn then
		if self.curShowPage==1 then
			self.goBtn:setVisible(true)
			self.goBtn:setEnabled(true)
			self.backBtn:setVisible(false)
			self.backBtn:setEnabled(false)
		else
			self.goBtn:setVisible(false)
			self.goBtn:setEnabled(false)
			self.backBtn:setVisible(true)
			self.backBtn:setEnabled(true)
		end
	end
end

function warStatueDialog:refreshTip()
	if self.tipSp then
		local tipFlag=warStatueVoApi:hasHeroCanActivate()
		self.tipSp:setVisible(tipFlag)
	end
end

function warStatueDialog:addCanActiveEffect(sid)
	local statueSp=self.statueSpTb[sid][1]
	local lightSp,inlightSp=self.activeEffectTb[sid][1],self.activeEffectTb[sid][2]
	if lightSp==nil and statueSp then
		local idx=statueSp:getTag()-100
		local scale=1.2
		local ex,ey=statueSp:getContentSize().width/2,50
		lightSp=CCSprite:createWithSpriteFrameName("warStatueLight.png")
		lightSp:setPosition(ex,ey)
		lightSp:setScale(scale)
		statueSp:addChild(lightSp)

		inlightSp=CCSprite:createWithSpriteFrameName("warStatueLight.png")
		inlightSp:setPosition(ex,ey)
		inlightSp:setScale(0.8*scale)
		statueSp:addChild(inlightSp)

		self.activeEffectTb[sid]={lightSp,inlightSp}

		local tlscale,lscale=1.2*scale,scale
		local acArr=CCArray:create()
		local scaleTo1=CCScaleTo:create(0.5,tlscale)
		local scaleTo2=CCScaleTo:create(0.5,lscale)
		acArr:addObject(scaleTo1)
		acArr:addObject(scaleTo2)
		local seq=CCSequence:create(acArr)
		local repeatAc=CCRepeatForever:create(seq)
		lightSp:runAction(repeatAc)

		local intscale,inscale=1.2*inlightSp:getScale(),inlightSp:getScale()
		local inAcArr=CCArray:create()
		local delay=CCDelayTime:create(0.1)
		inAcArr:addObject(delay)
		local function scaleFunc()
			local scaleTo1=CCScaleTo:create(0.5,intscale)
			local scaleTo2=CCScaleTo:create(0.5,inscale)
			local seq=CCSequence:createWithTwoActions(scaleTo1,scaleTo2)
			local repeatAc=CCRepeatForever:create(seq)
			inlightSp:runAction(repeatAc)
		end
		local scaleFunc=CCCallFunc:create(scaleFunc)
		inAcArr:addObject(scaleFunc)
		local seq2=CCSequence:create(inAcArr)
		inlightSp:runAction(seq2)
	end
end

function warStatueDialog:removeCanActiveEffect(sid)
	local lightSp,inlightSp=self.activeEffectTb[sid][1],self.activeEffectTb[sid][2]
	if lightSp and inlightSp then
		lightSp:removeFromParentAndCleanup(true)
		inlightSp:removeFromParentAndCleanup(true)
		self.activeEffectTb[sid]={}
	end
end

function warStatueDialog:showActiveEffect(sid)
	local lightSp,inlightSp=self.activeEffectTb[sid][1],self.activeEffectTb[sid][2]
	if lightSp and inlightSp then
		local statueSp=tolua.cast(self.statueSpTb[sid][1],"LuaCCScale9Sprite")
		if statueSp then
			lightSp:setVisible(true)
			inlightSp:setVisible(true)
		end
	end
end

function warStatueDialog:hideActiveEffect(sid)
	local lightSp,inlightSp=self.activeEffectTb[sid][1],self.activeEffectTb[sid][2]
	if lightSp and inlightSp then
		lightSp:setVisible(false)
		inlightSp:setVisible(false)
	end
end

function warStatueDialog:isTouchInArea(x,y)
	if (y>=self.minTouchy and y<=self.maxTouchy) then
		return true
	end
	return false
end

function warStatueDialog:touchEvent(fn,x,y,touch)
	if self:canMove()==false then
		do return end
	end
	if fn=="began" then
		if self.touchEnable==false then
			return false
		end
		table.insert(self.touchArr,touch)
		if SizeOfTable(self.touchArr)>1 then
			self.touchArr={}
			return false
		end
		self.startPos=ccp(x,y)
		return true
	elseif fn=="moved" then

	elseif fn=="ended" then
		self.touchArr={}
        if self:isTouchInArea(self.startPos.x,self.startPos.y)==true and self:isTouchInArea(x,y)==true then
			local moveX=self.startPos.x-x
			if moveX<-self.moveDisX then
	            self:leftStatue(1)
			elseif moveX>self.moveDisX then
	            self:rightStatue(1)
			end
        end
	else
		self.touchArr={}
	end
end

function warStatueDialog:leftStatue(movePageNum,callback,mt)
	if self:canMove()==false then
		do return end
	end
	self.checkBoxSp:setVisible(false)
	self.moveFlag=true
	local nextSelectIdx=self.pageSelectIdxTb[self.curShowPage]-1
	if nextSelectIdx<1 then
		nextSelectIdx=self.sc
	end
	self.pageSelectIdxTb[self.curShowPage]=nextSelectIdx
	self:setCurSid()

	local wsc=0
	local orderTb={}
	for i=1,self.sc do
		local sid=self:getSidByPageAndIdx(self.curShowPage,i)
		local v=self.statueSpTb[sid]
		local statueSp,shadeSp,statueInfoBg=tolua.cast(v[1],"LuaCCScale9Sprite"),tolua.cast(v[2],"CCSprite"),tolua.cast(v[3],"LuaCCScale9Sprite")
		if statueSp and shadeSp then
			statueInfoBg:setVisible(false)
			self:hideActiveEffect(sid)

			local baseTag=100
			local id=statueSp:getTag()-baseTag
			local targetid=id+1
			if targetid>self.sc then
				targetid=1
			end
			orderTb[sid]=targetid
			wsc=wsc+1
			local moveTime=mt or 0.3
			local targetPos,scale,opacityRatio=ccp(self.displayCfg[targetid][1],self.displayCfg[targetid][2]),self.displayCfg[targetid][3],self.displayCfg[targetid][4]
			local zorder=self.displayCfg[targetid][5]
			local acArr=CCArray:create()
			local moveTo=CCMoveTo:create(moveTime,targetPos)
			local scaleTo=CCScaleTo:create(moveTime,scale)
			acArr:addObject(moveTo)
			acArr:addObject(scaleTo)
            local spawn=CCSpawn:create(acArr)
            statueSp:runAction(spawn)

            local acArr2=CCArray:create()
			local fadeTo=CCFadeTo:create(moveTime,255*opacityRatio)
			acArr2:addObject(fadeTo)

			if wsc==self.sc then
				local function moveEnd()
					if wsc==self.sc then
						movePageNum=movePageNum-1
						for i=1,self.sc do
							local sid=self:getSidByPageAndIdx(self.curShowPage,i)
							local v=self.statueSpTb[sid]
							local statueSp=tolua.cast(v[1],"LuaCCScale9Sprite")
							statueSp:setTag(baseTag+orderTb[sid])
							if movePageNum<=0 then
								self:refreshWarStatueInfo(sid)
								self:showActiveEffect(sid)
							end
						end
						self.moveFlag=false
						if movePageNum<=0 then
							if callback then
								callback()
							end
						else
						self:leftStatue(movePageNum,callback,moveTime)
						end
					end
				end
				local moveEndCallBack=CCCallFunc:create(moveEnd)
				acArr2:addObject(moveEndCallBack)
			end
            local seq2=CCSequence:create(acArr2)
            shadeSp:runAction(seq2)

            local pageLayer=self.showPageTb[self.curShowPage]
            if pageLayer then
	            pageLayer:reorderChild(statueSp,zorder)
            end
		end
	end
end

function warStatueDialog:rightStatue(movePageNum,callback,mt)
	if self:canMove()==false then
		do return end
	end
	self.checkBoxSp:setVisible(false)
	self.moveFlag=true
	local nextSelectIdx=self.pageSelectIdxTb[self.curShowPage]+1
	if nextSelectIdx>self.sc then
		nextSelectIdx=1
	end
	self.pageSelectIdxTb[self.curShowPage]=nextSelectIdx
	self:setCurSid()
	
	local wsc=0
	local orderTb={}
	for i=1,self.sc do
		local sid=self:getSidByPageAndIdx(self.curShowPage,i)
		local v=self.statueSpTb[sid]
		local statueSp,shadeSp,statueInfoBg=tolua.cast(v[1],"LuaCCScale9Sprite"),tolua.cast(v[2],"CCSprite"),tolua.cast(v[3],"LuaCCScale9Sprite")
		if statueSp and shadeSp then
			statueInfoBg:setVisible(false)
			self:hideActiveEffect(sid)

			local baseTag=100
			local id=statueSp:getTag()-baseTag
			local targetid=id-1
			if targetid<1 then
				targetid=self.sc
			end
			orderTb[sid]=targetid
			wsc=wsc+1
			local moveTime=mt or 0.3
			local targetPos,scale,opacityRatio=ccp(self.displayCfg[targetid][1],self.displayCfg[targetid][2]),self.displayCfg[targetid][3],self.displayCfg[targetid][4]
			local zorder=self.displayCfg[targetid][5]

			local acArr=CCArray:create()
			local moveTo=CCMoveTo:create(moveTime,targetPos)
			local scaleTo=CCScaleTo:create(moveTime,scale)
			acArr:addObject(moveTo)
			acArr:addObject(scaleTo)
            local spawn=CCSpawn:create(acArr)
            statueSp:runAction(spawn)

            local acArr2=CCArray:create()
			local fadeTo=CCFadeTo:create(moveTime,255*opacityRatio)
			acArr2:addObject(fadeTo)
			if wsc==self.sc then
				local function moveEnd()
					if wsc==self.sc then
						movePageNum=movePageNum-1
						for i=1,self.sc do
							local sid=self:getSidByPageAndIdx(self.curShowPage,i)
							local v=self.statueSpTb[sid]
							local statueSp=tolua.cast(v[1],"LuaCCScale9Sprite")
							statueSp:setTag(baseTag+orderTb[sid])
							if movePageNum<=0 then
								self:refreshWarStatueInfo(sid)
								self:showActiveEffect(sid)
							end
						end
						self.moveFlag=false
						if movePageNum<=0 then
							if callback then
								callback()
							end
						else
							self:rightStatue(movePageNum,callback,moveTime)
						end
					end
				end
				local moveEndCallBack=CCCallFunc:create(moveEnd)
				acArr2:addObject(moveEndCallBack)
			end
            local seq=CCSequence:create(acArr2)
            shadeSp:runAction(seq)

            local pageLayer=self.showPageTb[self.curShowPage]
            if pageLayer then
	            pageLayer:reorderChild(statueSp,zorder)
            end
		end
	end
end

function warStatueDialog:getSidByPageAndIdx(page,idx)
	return "s"..(page-1)*self.sc+idx
end

function warStatueDialog:resetWarStatueShow(sid,idx,callback)
	if idx==1 then
		do return end
	end
	local jumpIdx=0
	if idx<=3 then
		jumpIdx=1-idx
	else
		jumpIdx=1-idx+5
	end
	if jumpIdx<0 then
		self:rightStatue(math.abs(jumpIdx),callback,0.2)
	else
		self:leftStatue(math.abs(jumpIdx),callback,0.2)
	end
end

function warStatueDialog:initBuffDetail()
	self.detailType=1
	self:initBuffList(true)

	local kuangWidth,kuangHeight=616,380
	if G_isIphone5()==true then
		kuangHeight=500
	end
	local detailPanel=G_getThreePointBg(CCSizeMake(kuangWidth,kuangHeight),function () end,ccp(0.5,1),ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-560),self.bgLayer)
	self.titleBg,self.titleLb=G_createNewTitle({getlocal("battlebuff_overview"),24},CCSizeMake(kuangWidth-140,0))
	self.titleBg:setPosition(kuangWidth/2,kuangHeight-40)
	detailPanel:addChild(self.titleBg)

	local isMoved,cellWidth,cellHeight=false,kuangWidth,50
	if G_isIphone5()==true then
		cellHeight=60
	end
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.cellNum
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local labelWidth,labelSize=150,20
            if self.detailType==1 then
            	for i=1,2 do
		        	local buffId=self.buffShowOrderCfg[idx*2+i]
		        	if buffId==nil or buffEffectCfg[buffId]==nil then
	        			do return cell end
		        	end
		        	local buffShowCfg=buffEffectCfg[buffId]
	            	local nameStr,buffKey,valueStr,nameColor,valueColor=getlocal(buffShowCfg.name or ""),buffShowCfg.key,"",G_ColorWhite,G_ColorGreen
	            	if buffKey=="first" or buffKey=="add" or buffKey == "antifirst" then --先手值和带兵量不是百分比
						valueStr="+"..(self.battleBuff[buffKey] or 0)
					else
						valueStr="+"..((self.battleBuff[buffKey] or 0)*100).."%"
	            	end
	            	if tonumber(self.battleBuff[buffKey])<=0 then
	            		nameColor,valueColor=G_ColorGray,G_ColorGray
	            	end
	            	if G_getCurChoseLanguage() == "ar" then
	            		labelWidth = 300
	            	end
	                local nameLb=GetTTFLabelWrap(nameStr,labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	                nameLb:setAnchorPoint(ccp(0,0.5))
	                nameLb:setPosition(20+(i-1)*250,cellHeight/2)
	                nameLb:setColor(nameColor)
	                cell:addChild(nameLb)
	                local tmpLb=GetTTFLabel(nameStr,labelSize)
	                local realW=tmpLb:getContentSize().width
	                if realW>nameLb:getContentSize().width then
	                	realW=nameLb:getContentSize().width
	                end
	                local valueLb=GetTTFLabel(valueStr,labelSize)
	                valueLb:setAnchorPoint(ccp(0,0.5))
	                valueLb:setColor(valueColor)
	                valueLb:setPosition(nameLb:getPositionX()+realW+10,cellHeight/2)
	                cell:addChild(valueLb)
            	end
            elseif self.detailType==2 then
            	labelWidth=576
	          	local buffId=self.buffShowOrderCfg[idx+1]
	        	if buffId==nil or buffEffectCfg[buffId]==nil then
        			do return cell end
	        	end
        		local buffShowCfg=buffEffectCfg[buffId]
            	local nameStr,buffKey=getlocal(buffShowCfg.name or ""),buffShowCfg.key
				local valueStr="+"..((self.skillBuff[buffKey] or 0)*100).."%"
				local nameColor,valueColor=G_ColorWhite,G_ColorGreen
				if tonumber(self.skillBuff[buffKey])<=0 then
					nameColor,valueColor=G_ColorGray,G_ColorGray
				end
		       	local nameLb=GetTTFLabelWrap(nameStr,labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                nameLb:setAnchorPoint(ccp(0,0.5))
                nameLb:setPosition(20,cellHeight/2)
                nameLb:setColor(nameColor)
                cell:addChild(nameLb)

                local tmpLb=GetTTFLabel(nameStr,labelSize)
                local realW=tmpLb:getContentSize().width
                if realW>nameLb:getContentSize().width then
                	realW=nameLb:getContentSize().width
                end
                local valueLb=GetTTFLabel(valueStr,labelSize)
                valueLb:setAnchorPoint(ccp(0,0.5))
                valueLb:setColor(valueColor)
                valueLb:setPosition(nameLb:getPositionX()+realW+10,cellHeight/2)
                cell:addChild(valueLb)
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
    local hd=LuaEventHandler:createHandler(eventHandler)
    local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,kuangHeight-80),nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    tv:setPosition(0,30)
    tv:setMaxDisToBottomOrTop(120)
    detailPanel:addChild(tv)
    self.detailTv=tv

	local function refresh()
		if self.detailType==1 then
			self.detailType=2
		else
			self.detailType=1
		end
		self:refreshBuffDetail()
	end
	local freshIcon=CCSprite:createWithSpriteFrameName("freshIcon.png")
	freshIcon:setPosition(kuangWidth-freshIcon:getContentSize().width/2-5,kuangHeight-freshIcon:getContentSize().height/2-5)
	detailPanel:addChild(freshIcon)

    local refreshTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),refresh)
    refreshTouchBg:setTouchPriority(-(self.layerNum-1)*20-4)
    refreshTouchBg:setContentSize(CCSizeMake(80,80))
    refreshTouchBg:setPosition(freshIcon:getPosition())
    refreshTouchBg:setOpacity(0)
    detailPanel:addChild(refreshTouchBg)
end

function warStatueDialog:initBuffList(reinitFlag)
	if reinitFlag==true then
		self.battleBuff,self.skillBuff=warStatueVoApi:getTotalWarStatueAddedBuff()
	end
	local bufflist={}
	self.buffShowOrderCfg={}
	if self.detailType==1 then
		local buffNum=SizeOfTable(self.battleBuff)
		if buffNum%2>0 then
			self.cellNum=(buffNum/2)+1
		else
			self.cellNum=buffNum/2
		end
		-- self.buffShowOrderCfg={99,100,108,201,202,102,103,104,105,109,225,226} --buff显示顺序
		for k,v in pairs(self.battleBuff) do
			local id=buffKeyMatchCodeCfg[k]
			table.insert(self.buffShowOrderCfg,id)
		end
		bufflist=self.battleBuff
	else
		self.cellNum=SizeOfTable(self.skillBuff)
		for k,v in pairs(self.skillBuff) do
			local id=buffKeyMatchCodeCfg[k]
			table.insert(self.buffShowOrderCfg,id)
		end
		-- self.buffShowOrderCfg={301,302,303,304,305}
		bufflist=self.skillBuff
	end
	local function sortFunc(a,b)
		local akey,bkey=buffEffectCfg[a].key,buffEffectCfg[b].key
		local aindex,bindex=(buffEffectCfg[a].index or 0),(buffEffectCfg[b].index or 0)
		local aw,bw=0,0
		if bufflist[akey]~=0 then
			aw=10000
		end
		if bufflist[bkey]~=0 then
			bw=10000
		end
		aw=aw+(1000-aindex)
		bw=bw+(1000-bindex)
		if aw>bw then
			return true
		end
		return false
	end
	table.sort(self.buffShowOrderCfg,sortFunc)
end

function warStatueDialog:refreshBuffDetail(reloadBuffData)
	self:initBuffList(reloadBuffData)
	if self.detailTv then
		self.detailTv:reloadData()
	end
	if self.titleLb then
		if self.detailType==1 then
			self.titleLb:setString(getlocal("battlebuff_overview"))
		else
			self.titleLb:setString(getlocal("skillbuff_overview"))
		end
	end
end

function warStatueDialog:doUserHandler()

end

function warStatueDialog:dispose()
    if self.refreshBuffListener then
        eventDispatcher:removeEventListener("warstatue.refresh",self.refreshBuffListener)
        self.refreshBuffListener=nil
    end
	self.battleBuff=nil
	self.skillBuff=nil
	self.buffShowOrderCfg=nil
	self.statueSpTb=nil
	self.activeEffectTb=nil
	self.cellNum=nil
	self.detailTv=nil
	self.checkBoxSp=nil
	self.uncheckBox=nil
	self.moveFlag=nil
	self.selectSid=nil
	self.curSid=nil
	self.pageSelectIdxTb=nil
	self.movePageFlag=nil
	self.showPageTb=nil
	self.displayCfg=nil
	self.touchArr=nil
    self.minTouchx,self.maxTouchx=nil,nil
    self.minTouchy,self.maxTouchy=nil,nil
    self.moveDisX=nil
    self.goBtn=nil
    self.backBtn=nil
    self.tipSp=nil
    self.curShowPage,self.maxShowPageNum=nil,nil

	spriteController:removeTexture("public/acKafkaGift.pvr.ccz")
	spriteController:removePlist("public/acKafkaGift.plist")
    spriteController:removePlist("public/warStatue/warStatue_images.plist")
    spriteController:removeTexture("public/warStatue/warStatue_images.png")
  	spriteController:removePlist("public/warStatue/warStatue_images3.plist")
    spriteController:removeTexture("public/warStatue/warStatue_images3.png")
   	spriteController:removePlist("public/youhuaUI3.plist")
	spriteController:removeTexture("public/youhuaUI3.png")
end