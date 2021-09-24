acLmqrjTabOne={}

function acLmqrjTabOne:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.curShowBoxIndex=1 --当前显示在前中的礼盒的索引(1:绿，2:紫，3:红)
    self.rewardBoxIsRunning=nil

    spriteController:addPlist("public/acZnqd2017.plist")
	spriteController:addTexture("public/acZnqd2017.png")
	spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/packsImage.plist")
    spriteController:addTexture("public/packsImage.png")
    spriteController:addPlist("public/acCflmImage.plist")
    spriteController:addTexture("public/acCflmImage.png")

    return nc
end

function acLmqrjTabOne:init()
	self.bgLayer=CCLayer:create()
	self:initUI()
	self.refreshUIListener=function()
		self:refreshUI()
	end
	eventDispatcher:addEventListener("acLmqrjTabOne.refreshUI",self.refreshUIListener)
	return self.bgLayer
end

function acLmqrjTabOne:initUI()
	local _bgFileName="acLmqrj_bg.jpg"
	local bgNoteSize=CCSizeMake(610,940)
	if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
		_bgFileName="acLmqrj_bg_v2.jpg"
		-- bgNoteSize=CCSizeMake(616,785)
	end
	if G_getIphoneType()==G_iphoneX then
		if (acLmqrjVoApi and acLmqrjVoApi:getVersion()==2)==false then
			_bgFileName="acLmqrj_bg_x.jpg"
		end
		bgNoteSize=CCSizeMake(610,1060)
	end
	local bgNote=CCNode:create()
	bgNote:setContentSize(bgNoteSize)
	bgNote:setAnchorPoint(ccp(0.5,1))
	bgNote:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-158)
	self.bgLayer:addChild(bgNote)
	local function onLoadImage(fn,sprite)
		if self and bgNote and tolua.cast(bgNote,"CCNode") then
			sprite:setAnchorPoint(ccp(0.5,1))
            sprite:setPosition(bgNoteSize.width/2,bgNoteSize.height)
            bgNote:addChild(sprite)
            if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
            	if G_getIphoneType()==G_iphone4 then
            		sprite:setScaleY(1.1)
            	elseif G_getIphoneType()==G_iphone5 then
	            	sprite:setScaleY(1.23)
	            elseif G_getIphoneType()==G_iphoneX then
	            	sprite:setScaleY(1.37)
	            end
            else
	            if G_getIphoneType()==G_iphone5 then
	            	sprite:setScaleY(1.03)
	            elseif G_getIphoneType()==G_iphoneX then
	            	sprite:setScaleY(1.02)
	            end
        	end
		end
	end
	-- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
	LuaCCWebImage:createWithURL(G_downloadUrl("active/".._bgFileName),onLoadImage)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	-- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	-- CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	local itemName=""
	local hxReward=acLmqrjVoApi:getHxReward()
    if hxReward then
    	itemName=hxReward.name
    end
	local function showInfo()
		if G_checkClickEnable()==false then
			do return end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local tabStr = {
			getlocal("activity_lmqrj_tabOne_info1",{itemName}),
			(acLmqrjVoApi and acLmqrjVoApi:getVersion()==2) and getlocal("activity_lmqrj_tabOne_info2_v2") or getlocal("activity_lmqrj_tabOne_info2"),
			(acLmqrjVoApi and acLmqrjVoApi:getVersion()==2) and getlocal("activity_lmqrj_tabOne_info3_v2") or getlocal("activity_lmqrj_tabOne_info3"),
			getlocal("activity_lmqrj_tabOne_info4",{acLmqrjVoApi:getGiveLevelLimit()}),
			getlocal("activity_lmqrj_tabOne_info5"),
			getlocal("activity_lmqrj_tabOne_info6"),
		}
		local titleStr=getlocal("activity_baseLeveling_ruleTitle")
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	-- infoItem:setScale(0.8)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(bgNote:getContentSize().width-25,bgNote:getContentSize().height-15))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	bgNote:addChild(infoBtn,1)

	local acTimeLb=GetTTFLabel(acLmqrjVoApi:getTimeStr(),22)
	acTimeLb:setPosition((bgNoteSize.width-infoItem:getContentSize().width*infoItem:getScale())/2,bgNote:getContentSize().height-45)
	acTimeLb:setColor(G_ColorYellowPro)
	bgNote:addChild(acTimeLb,1)
	self.acTimeLb=acTimeLb

	local _progressBarPosY=110
	if G_getIphoneType()==G_iphone5 or G_getIphoneType()==G_iphoneX then
		_progressBarPosY=130
	end
	local function clickHeartHandler()
		if G_checkClickEnable()==false then
			do return end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		local charmRewardTb=acLmqrjVoApi:getCharmReward()
		if charmRewardTb==nil then
			do return end
		end
		local _charmStr=getlocal("activity_lmqrj_charm")
		local _subTitleKey="activity_lmqrj_charmValueReward_desc"
		local _descStr=getlocal("activity_lmqrj_charmDesc")
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			_charmStr=getlocal("activity_lmqrj_charm_v2")
			_subTitleKey="activity_lmqrj_charmValueReward_desc_v2"
			_descStr=getlocal("activity_lmqrj_charmDesc_v2")
		end
		local content={}
		for k, v in pairs(charmRewardTb) do
			local item={}
			item.rewardlist=FormatItem(v[2],nil,true)
			item.title={tostring(v[1]).._charmStr,G_ColorYellowPro,23}
			item.subTitle={getlocal(_subTitleKey,{v[1]})}
			table.insert(content,item)
		end
        local title={_charmStr,nil,30}
        local desc={_descStr,G_ColorYellowPro,24}
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
        acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),title,content,self.layerNum+1,nil,nil,nil,true,desc)
	end
	local heartSp
	if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
		heartSp=LuaCCSprite:createWithSpriteFrameName("acLmqrj_heart_v2.png",clickHeartHandler)
		heartSp:setScale(55/heartSp:getContentSize().width)
	else
		heartSp=LuaCCSprite:createWithSpriteFrameName("acLmqrj_heart.png",clickHeartHandler)
	end
	heartSp:setTouchPriority(-(self.layerNum-1)*20-4)
	heartSp:setAnchorPoint(ccp(0,0.5))
	if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
		heartSp:setPosition(20,bgNoteSize.height-_progressBarPosY)
	else
		heartSp:setPosition(10,bgNoteSize.height-_progressBarPosY)
	end
	bgNote:addChild(heartSp,1)
	local progressBg=CCSprite:createWithSpriteFrameName("acZnqd2017Bg3.png")
	progressBg:setPosition(bgNoteSize.width/2,bgNoteSize.height-_progressBarPosY)
	progressBg:setScaleX(420/progressBg:getContentSize().width)
	bgNote:addChild(progressBg,2)
	local progressBar=CCSprite:createWithSpriteFrameName("acZnqd2017Pro.png")
	progressBar:setAnchorPoint(ccp(0,0.5))
	progressBar:setPosition(progressBg:getPositionX() - progressBg:getContentSize().width*progressBg:getScaleX()/2 + 4,progressBg:getPositionY())
	local maxWidth=(progressBg:getContentSize().width*progressBg:getScaleX() - 8)/progressBar:getContentSize().width
	local _curProgress=acLmqrjVoApi:getCharmNum()
	local _maxProgress=acLmqrjVoApi:getCurMaxScore()
	local _percent=_curProgress/_maxProgress
	_percent=((_percent>1) and 1 or _percent)
	progressBar:setScaleX(maxWidth*_percent)
	bgNote:addChild(progressBar,2)
	local progressLb=GetTTFLabel(getlocal("curProgressStr",{_curProgress,_maxProgress}),22,true)
	progressLb:setPosition(progressBg:getPosition())
	bgNote:addChild(progressLb,2)
	self.progressMaxWidth=maxWidth
	self.progressBar=progressBar
	self.progressLb=progressLb
	local function clickBoxHandler()
		if G_checkClickEnable()==false then
			do return end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		local sd
		local _isCanGet,_totalValue,_curValue,_cruReward = acLmqrjVoApi:isCanGetCharmReward()
		if _isCanGet==false then
			_totalValue,_curValue,_cruReward=acLmqrjVoApi:getCurScoreReward()
		end
		local rewardList = FormatItem(_cruReward,nil,true)
		local function btnCallback()
			socketHelper:activeLmqrjMlzReward({_curValue},function(fn,data) 
	        	local ret,sData=base:checkServerData(data)
	            if ret==true then
	            	if sData and sData.data and sData.data.lmqrj then
	            		acLmqrjVoApi:updateData(sData.data.lmqrj)
	            	end
	            	if sd then
						sd:close()
					end
					for k,v in pairs(rewardList) do
                        G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                    end
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
                    acLmqrjVoApi:setSystemMsg(rewardList)
                    G_showRewardTip(rewardList,true)
                    self.rewardBoxSp:stopAllActions()
                    local boxImage=acLmqrjVoApi:getCharmRewardBoxImage()
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(boxImage)
                    if frame then
	                    self.rewardBoxSp:setDisplayFrame(frame)
	                end
                    if acLmqrjVoApi:isCanGetCharmReward() then
						self:rewardBoxAction(self.rewardBoxSp)
					else
						self.rewardBoxIsRunning=nil
					end
	            end
	        end)
		end
		local btnText = acLmqrjVoApi:isGetCharmReward(_curValue) and getlocal("activity_hadReward") or getlocal("daily_scene_get")
		local btnEnabled = false
		if _isCanGet then
			btnEnabled = true
		end
		local titleStr2
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			titleStr2=getlocal("activity_lmqrj_charmValueReward_desc_v2",{_totalValue})
		else
			titleStr2=getlocal("activity_lmqrj_charmValueReward_desc",{_totalValue})
		end
		local desc=""
		local descColor=G_ColorYellowPro
		sd=smallDialog:showRewardPanel(self.layerNum+1,getlocal("award"),28,titleStr2,desc,descColor,rewardList,btnCallback,btnText,btnEnabled)
	end
	local rewardBoxImage=acLmqrjVoApi:getCharmRewardBoxImage()
	local rewardBoxSp=LuaCCSprite:createWithSpriteFrameName(rewardBoxImage,clickBoxHandler)
	rewardBoxSp:setTouchPriority(-(self.layerNum-1)*20-4)
	rewardBoxSp:setAnchorPoint(ccp(0.5,0.5))
	if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
		rewardBoxSp:setScale(74/rewardBoxSp:getContentSize().width)
	else
		rewardBoxSp:setScale((heartSp:getContentSize().width*heartSp:getScale())/rewardBoxSp:getContentSize().width)
	end
	rewardBoxSp:setPosition(bgNoteSize.width-rewardBoxSp:getContentSize().width*rewardBoxSp:getScale()/2-10,bgNoteSize.height-_progressBarPosY)
	bgNote:addChild(rewardBoxSp,1)
	if acLmqrjVoApi:isCanGetCharmReward() then
		self:rewardBoxAction(rewardBoxSp)
	end
	self.rewardBoxSp=rewardBoxSp

	--记录按钮
	local function recordHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        socketHelper:activeLmqrjLog(function(fn,data) 
        	local ret,sData=base:checkServerData(data)
            if ret==true then
            	if sData and sData.data and sData.data.lmqrj then
            		acLmqrjVoApi:updateData(sData.data.lmqrj)
            	end
            	if sData and sData.data and sData.data.log then
            		local logData=acLmqrjVoApi:formatLog(sData.data.log.log)
            		local zslogData=acLmqrjVoApi:formatZslog(sData.data.log.zslog)
            		if SizeOfTable(logData)==0 and SizeOfTable(zslogData)==0 then --暂无记录
            			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
            		else
            			acLmqrjSmallDialog:showLogDialog(self.layerNum+1,getlocal("serverwar_point_record"),true,logData,zslogData)
            		end
            	end
            end
        end)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",recordHandler,12)
    recordBtn:setScale(0.7)
    recordBtn:setAnchorPoint(ccp(1,1))
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(bgNoteSize.width-15,rewardBoxSp:getPositionY()-80))
    bgNote:addChild(recordMenu,1)
    local recordBtnLb=GetTTFLabel(getlocal("serverwar_point_record"),20)
    recordBtnLb:setAnchorPoint(ccp(0.5,1))
    recordBtnLb:setPosition(recordMenu:getPositionX()-recordBtn:getContentSize().width*recordBtn:getScale()/2-5,recordMenu:getPositionY()-recordBtn:getContentSize().height*recordBtn:getScale())
    bgNote:addChild(recordBtnLb,1)

    if (acLmqrjVoApi and acLmqrjVoApi:getVersion()==2)==false then
	    --花瓣
	    for i=1,3 do
	    	local flowerSp=CCSprite:createWithSpriteFrameName("acLmqrj_flower"..i..".png")
	    	if i==1 then
	    		flowerSp:setPosition(bgNoteSize.width-flowerSp:getContentSize().width/2-30,bgNoteSize.height/2)
	    	elseif i==2 then
	    		flowerSp:setPosition(flowerSp:getContentSize().width/2+10,bgNoteSize.height/2+40)
	    	else
	    		flowerSp:setPosition(bgNoteSize.width/2+30,bgNoteSize.height/2-100)
	    	end
	    	bgNote:addChild(flowerSp,1)
	    end
	end

    --箭头
    local arrowL=CCSprite:createWithSpriteFrameName("acLmqrj_arrow.png")
    local arrowR=CCSprite:createWithSpriteFrameName("acLmqrj_arrow.png")
    arrowR:setRotation(-90)
    arrowL:setPosition(bgNoteSize.width/2-140,bgNoteSize.height/2+80)
    arrowR:setPosition(bgNoteSize.width/2+130,bgNoteSize.height/2+80)
    bgNote:addChild(arrowL,1)
    bgNote:addChild(arrowR,1)

    self.boxSpTb={}
    --绿、紫、红(低->高)
    local boxTb=acLmqrjVoApi:getBoxTb()
	--后右、后左、前中
	local boxPos={
		ccp(bgNoteSize.width/2+120,bgNoteSize.height/2+200),
		ccp(bgNoteSize.width/2-130,bgNoteSize.height/2+200),
		ccp(bgNoteSize.width/2,bgNoteSize.height/2),
	}
	if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
		if G_getIphoneType()==G_iphone5 then
			for k, v in pairs(boxPos) do
				boxPos[k].y=boxPos[k].y-80
			end
		elseif G_getIphoneType()==G_iphoneX then
			for k, v in pairs(boxPos) do
				boxPos[k].y=boxPos[k].y-50
			end
		end
	end

	local _isRunning=false
	local onRotateAction

	for k, v in pairs(boxTb) do
		local function onClickBoxHandler()
			if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
	        if _isRunning then
	        	do return end
	        end
	        local function onClickEvent()
		        local content={}
	            local item={}
	            item.rewardlist=FormatItem(acLmqrjVoApi:getBoxReward(k),nil,true)
	            item.title={getlocal("activity_lmqrj_boxReward_title",{v[4]}),G_ColorYellowPro,24}
	            item.subTitle={getlocal("activity_lmqrj_boxReward_desc",{v[4]})}
	            table.insert(content,item)
		        local title={getlocal("award"),nil,32}
		        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
		        acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),title,content,self.layerNum+1,nil,nil,nil,true)
	    	end
	    	if self.curShowBoxIndex==k then
	    		onClickEvent()
	    	else
	    		onRotateAction(nil,k,onClickEvent)
	    	end
		end
		local boxSp=LuaCCSprite:createWithSpriteFrameName(v[1],onClickBoxHandler)
		boxSp:setPosition(boxPos[k])
		boxSp:setTouchPriority(-(self.layerNum-1)*20-4)
		bgNote:addChild(boxSp,1)
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			local bottomSp=CCSprite:createWithSpriteFrameName("acLmqrj_boxBg_v2.png")
			bottomSp:setPosition(boxSp:getContentSize().width/2,20)
			bottomSp:setTag(4)
			boxSp:addChild(bottomSp,-1)
			local bottomFocusSp=CCSprite:createWithSpriteFrameName("acLmqrj_boxFocus_v2.png")
			bottomFocusSp:setPosition(boxSp:getContentSize().width/2,20)
			bottomFocusSp:setTag(5)
			boxSp:addChild(bottomFocusSp,-1)
			local lightSp=CCSprite:createWithSpriteFrameName("acChunjieLight.png")
			lightSp:setAnchorPoint(ccp(0.5,0))
			lightSp:setPosition(boxSp:getContentSize().width/2,10)
			lightSp:setScale(1.4)
			lightSp:setTag(6)
			boxSp:addChild(lightSp,-1)
			if k<3 then
				bottomFocusSp:setVisible(false)
				lightSp:setVisible(false)
			end
		end
		local boxLidSp=CCSprite:createWithSpriteFrameName(v[2])
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			boxLidSp:setPosition(boxSp:getContentSize().width/2+7,boxSp:getContentSize().height-7)
		else
			boxLidSp:setPosition(boxSp:getContentSize().width/2,boxSp:getContentSize().height/2+30)
		end
		boxLidSp:setTag(1)
		boxSp:addChild(boxLidSp,1)
		local boxNameLb=GetTTFLabel(v[4],24)
		boxNameLb:setAnchorPoint(ccp(0.5,0))
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			boxNameLb:setPosition(boxSp:getContentSize().width/2,boxSp:getContentSize().height+33)
		else
			boxNameLb:setPosition(boxSp:getContentSize().width/2,boxSp:getContentSize().height+20)
		end
		boxNameLb:setTag(2)
		boxSp:addChild(boxNameLb)
		local ownedLb=GetTTFLabel(getlocal("propOwned")..999,20)
		local ownedBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg_black.png",CCRect(59,17,2,2),function()end)
		ownedBg:setContentSize(CCSizeMake(ownedLb:getContentSize().width+20,ownedLb:getContentSize().height+10))
		ownedBg:setAnchorPoint(ccp(0.5,1))
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			ownedBg:setPosition(boxSp:getContentSize().width/2,-10)
		else
			ownedBg:setPosition(boxSp:getContentSize().width/2,0)
		end
		ownedBg:setTag(3)
		boxSp:addChild(ownedBg)
		ownedLb:setPosition(ownedBg:getContentSize().width/2,ownedBg:getContentSize().height/2)
		ownedLb:setTag(1)
		ownedBg:addChild(ownedLb)
		ownedLb:setString(getlocal("propOwned")..acLmqrjVoApi:getBoxNum(k))
		if k<3 then
			boxSp:setScale(0.9)
			boxSp:setColor(ccc3(100, 100, 100))
			boxLidSp:setColor(ccc3(100, 100, 100))
		end
		table.insert(self.boxSpTb,boxSp)
	end

	self.curShowBoxIndex=1 --默认为1
	for i=1,3 do
		if acLmqrjVoApi:getBoxNum(i)>0 then
			self.curShowBoxIndex=i
			break
		end
	end
	if self.curShowBoxIndex~=3 then
		local _indexTb
		if self.curShowBoxIndex==1 then
			_indexTb={2,3,1}
		elseif self.curShowBoxIndex==2 then
			_indexTb={3,1,2}
		else
			_indexTb={1,2,3}
		end
		-- 2,3,1      3,1,2     1,2,3
		for k,v in pairs(boxPos) do
			local boxSp=self.boxSpTb[_indexTb[k]]
			local boxLidSp=tolua.cast(boxSp:getChildByTag(1),"CCSprite")
			local _scale=1
			local _color=ccc3(255,255,255)
			if k<3 then
				_scale=0.9
				_color=ccc3(100,100,100)
			end
			boxSp:setPosition(v)
			boxSp:setScale(_scale)
			boxSp:setColor(_color)
			boxLidSp:setColor(_color)
			if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
				local bottomFocusSp=tolua.cast(boxSp:getChildByTag(5),"CCSprite")
				local lightSp=tolua.cast(boxSp:getChildByTag(6),"CCSprite")
				if k<3 then
					bottomFocusSp:setVisible(false)
					lightSp:setVisible(false)
				else
					bottomFocusSp:setVisible(true)
					lightSp:setVisible(true)
				end
			end
		end
	end

	local _descLbPosY=280
	if G_getIphoneType()==G_iphone5 then
		_descLbPosY=220
	end
	local curBoxData=acLmqrjVoApi:getBoxTb(self.curShowBoxIndex)
	local descStr=getlocal("activity_lmqrj_desc",{curBoxData[4],itemName})
	local descLb=GetTTFLabelWrap(descStr,22,CCSizeMake(bgNoteSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	descLb:setPosition(bgNoteSize.width/2,_descLbPosY)
	bgNote:addChild(descLb,1)

	local _onePrice=acLmqrjVoApi:getOneCost(self.curShowBoxIndex)
	local _fivePrice=acLmqrjVoApi:getFiveCost(self.curShowBoxIndex)
	local ownedBoxNum=acLmqrjVoApi:getBoxNum(self.curShowBoxIndex)
	-- local _num=(ownedBoxNum>5) and 5 or ownedBoxNum
	-- local _isFree=(_num>0) and true or false
	-- _num=(_num>0) and _num or 1
	local _isFree=(ownedBoxNum>0) and true or false
	if ownedBoxNum>0 and ownedBoxNum<5 then
		_fivePrice=(5-ownedBoxNum)*_onePrice
	end

	local oneBtn,oneMenu
	local fiveBtn,fiveMenu
	local function lotteryLogic(tag,obj)
        local p_num,p_type,_price
        --[[
        if obj==oneBtn then
        	local ownedBoxNum=acLmqrjVoApi:getBoxNum(self.curShowBoxIndex)
			local _num=(ownedBoxNum>5) and 5 or ownedBoxNum
			local _isFree=(_num>0) and true or false
			_num=(_num>0) and _num or 1
			_price=_isFree and 0 or acLmqrjVoApi:getOneCost(self.curShowBoxIndex)
        	print(string.format("cjl -------->>> 拆%d个...",_num))
        	p_num=_num
        	p_type=(_isFree and "n" or "g")
        elseif obj==fiveBtn then
        	_price=acLmqrjVoApi:getFiveCost(self.curShowBoxIndex)
        	print("cjl -------->>> 拆5个...")
        	p_num=5
        	p_type="g"
        end
        --]]
        local ownedBoxNum=acLmqrjVoApi:getBoxNum(self.curShowBoxIndex)
        if obj==oneBtn then
        	_price=(ownedBoxNum>0) and 0 or acLmqrjVoApi:getOneCost(self.curShowBoxIndex)
        	p_num=1
        	p_type=((ownedBoxNum>0) and "n" or "g")
        elseif obj==fiveBtn then
        	if ownedBoxNum>=5 then
        		_price=0
        	else
        		if ownedBoxNum==0 then
        			_price=acLmqrjVoApi:getFiveCost(self.curShowBoxIndex)
        		else
        			_price=(5-ownedBoxNum)*acLmqrjVoApi:getOneCost(self.curShowBoxIndex)
        		end
        	end
        	p_num=5
        	p_type="g"
        end
        if p_num and p_type then
        	local function onLottery()
	        	if playerVoApi:getGems()<_price then
		            GemsNotEnoughDialog(nil,nil,_price-playerVoApi:getGems(),self.layerNum+1,_price)
		            do return end
		        end

		        local function onSureLogic()
		        	socketHelper:activeLmqrjLottery({p_num,self.curShowBoxIndex,p_type},function(fn,data)
						local ret,sData=base:checkServerData(data)
			            if ret==true then
			            	playerVoApi:setGems(playerVoApi:getGems()-_price)
			            	if sData and sData.data and sData.data.lmqrj then
			            		acLmqrjVoApi:updateData(sData.data.lmqrj)
			            	end
			            	if sData and sData.data and sData.data.reward then
			            		local rewardList = {}
			            		for k, v in pairs(sData.data.reward) do
			            			table.insert(rewardList,FormatItem(v)[1])
			            		end
			            		for k,v in pairs(rewardList) do
		                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
		                        end

		                        local hxReward=acLmqrjVoApi:getHxReward()
								if hxReward then
									hxReward.num = hxReward.num * p_num
									G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
									table.insert(rewardList,1,hxReward)
								end

								self:openBoxAction(rewardList,function() 
									local arry=CCArray:create()
									arry:addObject(CCDelayTime:create(0.3))
									arry:addObject(CCCallFunc:create(function() self:refreshUI() end))
									self.bgLayer:runAction(CCSequence:create(arry))
								end)
			            	end
			            end
					end)
	        	end
	        	local function secondTipFunc(sbFlag)
		            local sValue=base.serverTime .. "_" .. sbFlag
		            G_changePopFlag("acLmqrjLottery",sValue)
		        end
		        if _price>0 and G_isPopBoard("acLmqrjLottery") then
		            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{_price}),true,onSureLogic,secondTipFunc)
		        else
		            onSureLogic()
		        end
	    	end
	    	if obj==fiveBtn and (ownedBoxNum>0 and ownedBoxNum<5) then
	    		local _curBoxData=acLmqrjVoApi:getBoxTb(self.curShowBoxIndex)
	    		local _tips=getlocal("activity_lmqrj_fiveLotteryTips",{ownedBoxNum,_curBoxData[4],_price})
	    		G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),_tips,false,onLottery)
	    	else
	    		onLottery()
	    	end
        end
	end

	local _btnPosY=175
	if G_getIphoneType()==G_iphone5 then
		_btnPosY=100
	elseif G_getIphoneType()==G_iphoneX then
		_btnPosY=100
	end
	oneBtn,oneMenu=self:createButton(getlocal("activity_lmqrj_buttonText",{1}),lotteryLogic,(_isFree==false) and 1 or nil)
	-- oneBtn,oneMenu=self:createButton(getlocal("activity_lmqrj_buttonText",{_num}),lotteryLogic,_isFree and nil or 1)
	oneMenu:setPosition(bgNoteSize.width/2,_btnPosY)
	bgNote:addChild(oneMenu,1)
	self.oneBtn=oneBtn
	fiveBtn,fiveMenu=self:createButton(getlocal("activity_lmqrj_buttonText",{5}),lotteryLogic,((ownedBoxNum>=5)==false) and 1 or nil)
	-- fiveBtn,fiveMenu=self:createButton(getlocal("activity_lmqrj_buttonText",{5}),lotteryLogic,1)
	fiveMenu:setPosition(oneMenu:getPositionX()+oneBtn:getContentSize().width*oneBtn:getScale()+20,oneMenu:getPositionY())
	bgNote:addChild(fiveMenu,1)
	self.fiveBtn=fiveBtn

	self.freeLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),22)
	self.freeLb:setAnchorPoint(ccp(0.5,0))
	self.freeLb:setPosition(oneMenu:getPositionX(),oneMenu:getPositionY()+oneBtn:getContentSize().height*oneBtn:getScale()/2+5)
	bgNote:addChild(self.freeLb,1)

	self.fiveFreeLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),22)
	self.fiveFreeLb:setAnchorPoint(ccp(0.5,0))
	self.fiveFreeLb:setPosition(fiveMenu:getPositionX(),fiveMenu:getPositionY()+fiveBtn:getContentSize().height*fiveBtn:getScale()/2+5)
	bgNote:addChild(self.fiveFreeLb,1)

	--单拆
	self.oneGoldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.oneGoldLb=GetTTFLabel(tostring(_onePrice),22)
	self.oneGoldLb:setColor(G_ColorYellowPro)
	self.oneGoldSp:setAnchorPoint(ccp(0,0.5))
	self.oneGoldLb:setAnchorPoint(ccp(1,0.5))
	self.oneGoldSp:setPosition(oneMenu:getPositionX(),oneMenu:getPositionY()+oneBtn:getContentSize().height*oneBtn:getScale()/2+self.oneGoldSp:getContentSize().height/2+5)
	self.oneGoldLb:setPosition(self.oneGoldSp:getPosition())
	bgNote:addChild(self.oneGoldSp,1)
	bgNote:addChild(self.oneGoldLb,1)

	self.oneGoldSp:setVisible(false)
	self.oneGoldLb:setVisible(false)
	self.freeLb:setVisible(false)

	if _isFree then
		self.freeLb:setVisible(true)
	else
		self.oneGoldSp:setVisible(true)
		self.oneGoldLb:setVisible(true)
	end

	--5拆
	local fiveGoldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
	local fiveGoldLb=GetTTFLabel(tostring(_fivePrice),22)
	fiveGoldLb:setColor(G_ColorYellowPro)
	fiveGoldSp:setAnchorPoint(ccp(0,0.5))
	fiveGoldLb:setAnchorPoint(ccp(1,0.5))
	fiveGoldSp:setPosition(fiveMenu:getPositionX(),fiveMenu:getPositionY()+fiveBtn:getContentSize().height*fiveBtn:getScale()/2+fiveGoldSp:getContentSize().height/2+5)
	fiveGoldLb:setPosition(fiveGoldSp:getPosition())
	bgNote:addChild(fiveGoldSp,1)
	bgNote:addChild(fiveGoldLb,1)
	self.fiveGoldSp=fiveGoldSp
	self.fiveGoldLb=fiveGoldLb

	self.fiveFreeLb:setVisible(false)
	self.fiveGoldSp:setVisible(false)
	self.fiveGoldLb:setVisible(false)

	if ownedBoxNum>=5 then
		self.fiveFreeLb:setVisible(true)
	else
		self.fiveGoldSp:setVisible(true)
		self.fiveGoldLb:setVisible(true)
	end

	--赠送按钮
	local giveBtn,giveMenu=self:createButton(getlocal("rechargeGifts_giveLabel"),function(tag,obj)
		local function showGivingDialog()
			acLmqrjSmallDialog:showGiving(self.layerNum+1,getlocal("rechargeGifts_giveLabel"),self.curShowBoxIndex,function()
				self:refreshUI()
				eventDispatcher:dispatchEvent("acLmqrjTabTwo.refreshUI",{})
			end)
		end
		local flag=acLmqrjVoApi:getInitFriendsListFlag()
        if flag==-1 then
            local function callbackList(fn,data)
            local ret,sData=base:checkServerData(data)
                if ret==true then
                	acLmqrjVoApi:setInitFriendsListFlag(true)
                	if sData and sData.data and sData.data.aclist and sData.data.aclist.lmqrj then
	                	if sData.data.aclist.lmqrj.friend then
	                    	acLmqrjVoApi:setGivingTab(sData.data.aclist.lmqrj.friend)
	                    end
	                end
                    showGivingDialog()
                end
            end
            socketHelper:friendsList(callbackList,"lmqrj")
        else
			showGivingDialog()
		end
	end)
	giveMenu:setPosition(oneMenu:getPositionX()-oneBtn:getContentSize().width*oneBtn:getScale()-25,oneMenu:getPositionY())
	bgNote:addChild(giveMenu,1)

	onRotateAction=function(_flag,_showBoxIndex,_callback)
		_isRunning=true
		if _showBoxIndex then
			self.curShowBoxIndex=_showBoxIndex
		else
			self.curShowBoxIndex=self.curShowBoxIndex-_flag
		end
		if self.curShowBoxIndex<1 then
			self.curShowBoxIndex=3
		end
		if self.curShowBoxIndex>3 then
			self.curShowBoxIndex=1
		end
		local _indexTb
		if self.curShowBoxIndex==1 then
			_indexTb={2,3,1}
		elseif self.curShowBoxIndex==2 then
			_indexTb={3,1,2}
		else
			_indexTb={1,2,3}
		end
		-- 2,3,1      3,1,2     1,2,3
		for k,v in pairs(boxPos) do
			local boxSp=self.boxSpTb[_indexTb[k]]
			local boxLidSp=tolua.cast(boxSp:getChildByTag(1),"CCSprite")
			local boxNameLb=tolua.cast(boxSp:getChildByTag(2),"CCLabelTTF")
			local ownedBg=tolua.cast(boxSp:getChildByTag(3),"CCSprite")
			boxNameLb:setVisible(false)
			ownedBg:setVisible(false)
			if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
				local bottomFocusSp=tolua.cast(boxSp:getChildByTag(5),"CCSprite")
				bottomFocusSp:setVisible(false)
				local lightSp=tolua.cast(boxSp:getChildByTag(6),"CCSprite")
				lightSp:setVisible(false)
			end

			local _scale=1
			local _color=ccc3(255,255,255)
			if k<3 then
				_scale=0.9
				_color=ccc3(100,100,100)
			end
			-- boxSp:setScale(_scale)
			-- boxSp:setColor(_color)
			-- boxLidSp:setColor(_color)
			-- boxSp:setPosition(v)

			local arr=CCArray:create()
			arr:addObject(CCScaleTo:create(0.5,_scale))
			arr:addObject(CCTintTo:create(0.5,_color.r,_color.g,_color.b))
			if boxSp:getPositionY()==v.y then
				arr:addObject(CCMoveTo:create(0.5,v))
			else
				local bezier=ccBezierConfig()
				if k==1 then
			        bezier.controlPoint_1=ccp(boxSp:getPositionX()+100,boxSp:getPositionY())
			        bezier.controlPoint_2=ccp(v.x+70,v.y-35)
			    elseif k==2 then
			    	bezier.controlPoint_1=ccp(boxSp:getPositionX()-70,boxSp:getPositionY())
			        bezier.controlPoint_2=ccp(v.x-70,v.y-35)
			    elseif k==3 then
			    	if boxSp:getPositionX()<v.x then
			    		bezier.controlPoint_1=ccp(boxSp:getPositionX()-70,boxSp:getPositionY()-35)
			    		bezier.controlPoint_2=ccp(v.x-100,v.y)
			    	else
			    		bezier.controlPoint_1=ccp(boxSp:getPositionX()+70,boxSp:getPositionY()-35)
			    		bezier.controlPoint_2=ccp(v.x+100,v.y)
			    	end
		    	end
		        bezier.endPosition=v
		        arr:addObject(CCBezierTo:create(0.5,bezier))
		    end
			
			local seq=CCSequence:createWithTwoActions(CCSpawn:create(arr),CCCallFunc:create(function()
				if k==3 then
					for m,n in pairs(self.boxSpTb) do
						local boxNameLb=tolua.cast(n:getChildByTag(2),"CCLabelTTF")
						local ownedBg=tolua.cast(n:getChildByTag(3),"CCSprite")
						boxNameLb:setVisible(true)
						ownedBg:setVisible(true)
					end
					if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
						local boxSp=self.boxSpTb[self.curShowBoxIndex]
						local bottomFocusSp=tolua.cast(boxSp:getChildByTag(5),"CCSprite")
						bottomFocusSp:setVisible(true)
						local lightSp=tolua.cast(boxSp:getChildByTag(6),"CCSprite")
						lightSp:setVisible(true)
					end

					-- local onBtnLb=tolua.cast(oneBtn:getChildByTag(15),"CCLabelTTF")

					local curBoxData=acLmqrjVoApi:getBoxTb(self.curShowBoxIndex)
					local _onePrice=acLmqrjVoApi:getOneCost(self.curShowBoxIndex)
					local _fivePrice=acLmqrjVoApi:getFiveCost(self.curShowBoxIndex)
					local ownedBoxNum=acLmqrjVoApi:getBoxNum(self.curShowBoxIndex)
					-- local _num=(ownedBoxNum>5) and 5 or ownedBoxNum
					-- _isFree=(_num>0) and true or false
					-- _num=(_num>0) and _num or 1
					_isFree=(ownedBoxNum>0) and true or false
					if ownedBoxNum>0 and ownedBoxNum<5 then
						_fivePrice=(5-ownedBoxNum)*_onePrice
					end

					descLb:setString(getlocal("activity_lmqrj_desc",{curBoxData[4],itemName}))

					-- onBtnLb:setString(getlocal("activity_lmqrj_buttonText",{_num}))
					self.oneGoldLb:setString(tostring(_onePrice))
					fiveGoldLb:setString(tostring(_fivePrice))

					self.oneGoldSp:setVisible(false)
					self.oneGoldLb:setVisible(false)
					self.freeLb:setVisible(false)

					if _isFree then
						self.freeLb:setVisible(true)
						oneBtn:setNormalImage(CCSprite:createWithSpriteFrameName("newGreenBtn.png"))
						oneBtn:setSelectedImage(CCSprite:createWithSpriteFrameName("newGreenBtn_down.png"))
						oneBtn:setDisabledImage(CCSprite:createWithSpriteFrameName("newGreenBtn.png"))
					else
						self.oneGoldSp:setVisible(true)
						self.oneGoldLb:setVisible(true)
						oneBtn:setNormalImage(CCSprite:createWithSpriteFrameName("creatRoleBtn.png"))
						oneBtn:setSelectedImage(CCSprite:createWithSpriteFrameName("creatRoleBtn_Down.png"))
						oneBtn:setDisabledImage(CCSprite:createWithSpriteFrameName("creatRoleBtn.png"))
					end

					self.fiveFreeLb:setVisible(false)
					self.fiveGoldSp:setVisible(false)
					self.fiveGoldLb:setVisible(false)

					if ownedBoxNum>=5 then
						self.fiveFreeLb:setVisible(true)
						fiveBtn:setNormalImage(CCSprite:createWithSpriteFrameName("newGreenBtn.png"))
						fiveBtn:setSelectedImage(CCSprite:createWithSpriteFrameName("newGreenBtn_down.png"))
						fiveBtn:setDisabledImage(CCSprite:createWithSpriteFrameName("newGreenBtn.png"))
					else
						self.fiveGoldSp:setVisible(true)
						self.fiveGoldLb:setVisible(true)
						fiveBtn:setNormalImage(CCSprite:createWithSpriteFrameName("creatRoleBtn.png"))
						fiveBtn:setSelectedImage(CCSprite:createWithSpriteFrameName("creatRoleBtn_Down.png"))
						fiveBtn:setDisabledImage(CCSprite:createWithSpriteFrameName("creatRoleBtn.png"))
					end
					_isRunning=false
					if _callback then
						_callback()
					end
				end
			end))

			boxSp:runAction(seq)
			boxLidSp:runAction(CCTintTo:create(0.5,_color.r,_color.g,_color.b))
		end
	end

	local moveMinDis=50
	local beganPos
	local function touchHandler(fn,x,y,touch)
    	if fn=="began" then
    		if _isRunning then
    			do return 0 end
    		end
    		beganPos=ccp(x,y)
            return 1
       	elseif fn=="moved" then
        elseif fn=="ended" then
        	if beganPos then
	            local moveDis=ccpSub(ccp(x,y),beganPos)
	            if moveDis.x>moveMinDis then --右
	                onRotateAction(1)
	            elseif moveDis.x<-moveMinDis then --左
	                onRotateAction(-1)
	            end
        	end
            beganPos=nil
        end
    end
    self.bgLayer:setTouchEnabled(true)
	self.bgLayer:registerScriptTouchHandler(touchHandler,false,-(self.layerNum-1)*20-3,false)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-3)
end

function acLmqrjTabOne:createButton(btnStr,btnCallback,btnType)
	local function onClickButton(...)
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		if btnCallback then
			btnCallback(...)
		end
	end
	local buttonScale=0.8
	local image1,image2,image3="newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"
	if btnType==1 then
		image1,image2,image3="creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
	end
	local button=GetButtonItem(image1,image2,image3,onClickButton,12,btnStr,24/buttonScale,15)
	button:setScale(buttonScale)
	button:setAnchorPoint(ccp(0.5,0.5))
    local menu=CCMenu:createWithItem(button)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    return button, menu
end

function acLmqrjTabOne:setTouchEnabled(_enabled,_callbackFunc,_touchPriority)
	local sp = self.bgLayer:getChildByTag(-99999)
	if _enabled then
		if sp then
			sp:removeFromParentAndCleanup(true)
			sp=nil
		end
	else
		if sp==nil then
			sp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() if _callbackFunc then _callbackFunc() end end)
		    if _touchPriority then
		    	sp:setTouchPriority(_touchPriority)
		    else
		    	sp:setTouchPriority(-self.layerNum*20-10)
		    end
		    sp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
		    sp:setOpacity(0)
		    sp:setTag(-99999)
		    self.bgLayer:addChild(sp,99999)
		end
	    sp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	    return sp
	end
end

function acLmqrjTabOne:rewardBoxAction(sprite)
	if sprite==nil then
		do return end
	end
	sprite:stopAllActions()
	self.rewardBoxIsRunning=true
	local arr=CCArray:create()
	arr:addObject(CCRotateTo:create(0.1,30))
	arr:addObject(CCRotateTo:create(0.1,-30))
	arr:addObject(CCRotateTo:create(0.1,20))
	arr:addObject(CCRotateTo:create(0.1,-20))
	arr:addObject(CCRotateTo:create(0.1,0))
	arr:addObject(CCDelayTime:create(1))
	sprite:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

function acLmqrjTabOne:openBoxAction(_rewardList,_sureBtnCallback)

	--------------------------- TODO TEST --------------------------
	-- local _rewardList={}
	-- for i=1,6 do
	-- 	table.insert(_rewardList,FormatItem({p={p878=1}})[1])
	-- end
	--------------------------- TODO TEST --------------------------

	local hxReward=G_clone(_rewardList[1])
	table.remove(_rewardList,1)

	local quickShowReslut=nil
	local _touchPriority=-(self.layerNum-1)*20-4
	local bgSprite=self:setTouchEnabled(false,function()
		if type(quickShowReslut)=="function" then
			quickShowReslut()
		end
	end,_touchPriority)
	local colorBg=CCLayerColor:create(ccc4(0,0,0,200))
	bgSprite:addChild(colorBg)
	local sureBtn,sureMenu=self:createButton(getlocal("confirm"),function(tag,obj)
		table.insert(_rewardList,1,hxReward)
		G_showRewardTip(_rewardList,true)
		self:setTouchEnabled(true)
		if _sureBtnCallback then
			_sureBtnCallback()
		end
	end)
	sureBtn:setVisible(false)
	sureBtn:setEnabled(false)
	local _topDescPosY=230
	if G_getIphoneType()==G_iphone4 then
		_topDescPosY=200
	end
	local topDescLb=GetTTFLabelWrap("",24,CCSizeMake(bgSprite:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	topDescLb:setAnchorPoint(ccp(0.5,1))
	topDescLb:setPosition(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height-_topDescPosY)
	topDescLb:setColor(G_ColorYellowPro)
	-- topDescLb:setVisible(false)
	bgSprite:addChild(topDescLb)

	local hxItemStr=hxReward.name.."x"..hxReward.num
	local hxRewardLb=GetTTFLabel(getlocal("activity_xuyuanlu_getGolds",{hxItemStr}),22)
	hxRewardLb:setAnchorPoint(ccp(0.5,1))
	hxRewardLb:setColor(G_ColorYellowPro)
	-- hxRewardLb:setVisible(false)
	bgSprite:addChild(hxRewardLb)

	local _posTb={
		{
			ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2)
		},
		{
			ccp(bgSprite:getContentSize().width/2-150,bgSprite:getContentSize().height/2),
			ccp(bgSprite:getContentSize().width/2+150,bgSprite:getContentSize().height/2),
		},
		{
			ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2+70),
			ccp(bgSprite:getContentSize().width/2-150,bgSprite:getContentSize().height/2-180),
			ccp(bgSprite:getContentSize().width/2+150,bgSprite:getContentSize().height/2-180),
		},
		{
			ccp(bgSprite:getContentSize().width/2-150,bgSprite:getContentSize().height/2+70),
			ccp(bgSprite:getContentSize().width/2+150,bgSprite:getContentSize().height/2+70),
			ccp(bgSprite:getContentSize().width/2-150,bgSprite:getContentSize().height/2-180),
			ccp(bgSprite:getContentSize().width/2+150,bgSprite:getContentSize().height/2-180),
		},
		{
			ccp(bgSprite:getContentSize().width/4*1-30,bgSprite:getContentSize().height/2+70),
			ccp(bgSprite:getContentSize().width/4*2-10,bgSprite:getContentSize().height/2+70),
			ccp(bgSprite:getContentSize().width/4*3+10,bgSprite:getContentSize().height/2+70),
			ccp(bgSprite:getContentSize().width/2-150,bgSprite:getContentSize().height/2-180),
			ccp(bgSprite:getContentSize().width/2+150,bgSprite:getContentSize().height/2-180),
		},
		{
			ccp(bgSprite:getContentSize().width/4*1-30,bgSprite:getContentSize().height/2+70),
			ccp(bgSprite:getContentSize().width/4*2-10,bgSprite:getContentSize().height/2+70),
			ccp(bgSprite:getContentSize().width/4*3+10,bgSprite:getContentSize().height/2+70),
			ccp(bgSprite:getContentSize().width/4*1-30,bgSprite:getContentSize().height/2-180),
			ccp(bgSprite:getContentSize().width/4*2-10,bgSprite:getContentSize().height/2-180),
			ccp(bgSprite:getContentSize().width/4*3+10,bgSprite:getContentSize().height/2-180),
		},
	}

	local _boxSpTb={}
	local _iconScale={}
	local _listSize=SizeOfTable(_rewardList)
	local boxData=acLmqrjVoApi:getBoxTb(self.curShowBoxIndex)
	local _totalScore=0
	for k,v in pairs(_rewardList) do
		local boxSp=CCSprite:createWithSpriteFrameName(boxData[1])
		boxSp:setPosition(_posTb[_listSize][k])
		bgSprite:addChild(boxSp)
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
		else
			boxSp:setScale(0.9)
		end
		boxSp:setVisible(false)
		local lightSp
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			lightSp=CCSprite:createWithSpriteFrameName("acLmqrj_light1_v2.png")
		else
			lightSp=CCSprite:createWithSpriteFrameName("acLmqrj_light1.png")
		end
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			lightSp:setPosition(boxSp:getContentSize().width/2,boxSp:getContentSize().height/2+75)
		else
			lightSp:setPosition(boxSp:getContentSize().width/2,boxSp:getContentSize().height/2+65)
		end
		local blendFunc=ccBlendFunc:new()
		blendFunc.src=GL_ONE
		blendFunc.dst=GL_ONE_MINUS_SRC_COLOR
		lightSp:setBlendFunc(blendFunc)
		local pzArr=CCArray:create()
		for kk=1,12 do
			local nameStr
			if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
				nameStr="acLmqrj_light"..kk.."_v2.png"
			else
				nameStr="acLmqrj_light"..kk..".png"
			end
			local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
			pzArr:addObject(frame)
		end
		local animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(0.05)
		local animate=CCAnimate:create(animation)
		local repeatForever=CCRepeatForever:create(animate)
		lightSp:setVisible(false)
		lightSp:runAction(repeatForever)
		boxSp:addChild(lightSp)
		local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
        end
        local icon,scale=G_getItemIcon(v,100,false,self.layerNum,showNewPropInfo)
        icon:setAnchorPoint(ccp(0.5,1))
		icon:setPosition(boxSp:getContentSize().width/2,boxSp:getContentSize().height/2+60)
		icon:setTouchPriority(_touchPriority)
		icon:setScale(0)
		boxSp:addChild(icon)
		local numLb=GetTTFLabel("x"..FormatNumber(v.num),23)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setScale(1/scale)
        numLb:setPosition(ccp(icon:getContentSize().width-5,0))
        icon:addChild(numLb,2)
        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        numBg:setAnchorPoint(ccp(1,0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
        numBg:setOpacity(150)
        icon:addChild(numBg,1)
		local boxLidSp=CCSprite:createWithSpriteFrameName(boxData[2])
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			boxLidSp:setPosition(boxSp:getContentSize().width/2+7,boxSp:getContentSize().height-7)
		else
			boxLidSp:setPosition(boxSp:getContentSize().width/2,boxSp:getContentSize().height/2+30)
		end
		boxSp:addChild(boxLidSp)
		local boxOpenLidSp=CCSprite:createWithSpriteFrameName(boxData[3])
		boxOpenLidSp:setPosition(boxSp:getContentSize().width/2+20,boxSp:getContentSize().height/2+55)
		boxOpenLidSp:setVisible(false)
		boxSp:addChild(boxOpenLidSp)

		local _score=acLmqrjVoApi:getItemScore(self.curShowBoxIndex,v.key)*v.num
		_totalScore=_totalScore+_score
		local _lbKey="activity_lmqrj_charmAdd"
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			_lbKey="activity_lmqrj_charmAdd_v2"
		end
		local charmLb=GetTTFLabel(getlocal(_lbKey,{_score}),22)
		charmLb:setPosition(boxSp:getContentSize().width/2,-charmLb:getContentSize().height/2)
		charmLb:setColor(G_ColorYellowPro)
		charmLb:setVisible(false)
		boxSp:addChild(charmLb)

		lightSp:setTag(1)
		icon:setTag(2)
		boxLidSp:setTag(3)
		boxOpenLidSp:setTag(4)
		charmLb:setTag(5)
		table.insert(_boxSpTb,boxSp)
		table.insert(_iconScale,scale)
	end

	local _descStr
	if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
		_descStr=getlocal("activity_lmqrj_openBoxSuccessTip_v2",{boxData[4],_listSize,_totalScore})
	else
		_descStr=getlocal("activity_lmqrj_openBoxSuccessTip",{boxData[4],_listSize,_totalScore})
	end
	topDescLb:setString(_descStr)
	sureMenu:setPosition(bgSprite:getContentSize().width/2,100)
	bgSprite:addChild(sureMenu)
	hxRewardLb:setPosition(topDescLb:getPositionX(),topDescLb:getPositionY()-topDescLb:getContentSize().height-20)

	local runBoxAction=nil
	local _isBreak
	local _curRunActionIndex
	runBoxAction=function(_index)
		_curRunActionIndex=_index
		if _index>_listSize then
			do return end
		end
		local boxSp=tolua.cast(_boxSpTb[_index],"CCSprite")
		local lightSp=tolua.cast(boxSp:getChildByTag(1),"CCSprite")
		local icon=tolua.cast(boxSp:getChildByTag(2),"CCSprite")
		local boxLidSp=tolua.cast(boxSp:getChildByTag(3),"CCSprite")
		local boxOpenLidSp=tolua.cast(boxSp:getChildByTag(4),"CCSprite")
		local charmLb=tolua.cast(boxSp:getChildByTag(5),"CCSprite")
		local scale=_iconScale[_index]
		boxSp:setVisible(true)

		local function callback3()
			lightSp:setVisible(true)

			local arr3=CCArray:create()
			local array=CCArray:create()
			array:addObject(CCMoveTo:create(0.3,ccp(boxSp:getContentSize().width/2,boxSp:getContentSize().height/2+50)))
			-- array:addObject(CCScaleTo:create(0.5,scale))
			local array1=CCArray:create()
			array1:addObject(CCScaleTo:create(0.3,scale+0.15))
			-- array1:addObject(CCScaleTo:create(0.1,scale+0.05))
			-- array1:addObject(CCScaleTo:create(0.1,scale+0.15))
			array1:addObject(CCScaleTo:create(0.1,scale))
			array:addObject(CCSequence:create(array1))
			arr3:addObject(CCSpawn:create(array))
			arr3:addObject(CCCallFunc:create(function()
				charmLb:setVisible(true)
				if _index==_listSize then
					_curRunActionIndex=nil
					-- topDescLb:setVisible(true)
					-- hxRewardLb:setVisible(true)
					sureBtn:setEnabled(true)
					sureBtn:setVisible(true)
				-- elseif not _isBreak then
				-- 	runBoxAction(_index+1)
				end
			end))
			icon:runAction(CCSequence:create(arr3))
		end

		local function callback2()
			boxLidSp:setVisible(false)
			boxOpenLidSp:setVisible(true)
			local arr2=CCArray:create()
			arr2:addObject(CCMoveTo:create(0.1,ccp(boxSp:getContentSize().width/2+45,boxSp:getContentSize().height/2+70)))
			arr2:addObject(CCCallFunc:create(function()
				if _index==_listSize then
				elseif not _isBreak then
					runBoxAction(_index+1)
				end
			end))
			boxOpenLidSp:runAction(CCSequence:create(arr2))
			callback3()
		end

		local arr1=CCArray:create()
		if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
			arr1:addObject(CCMoveTo:create(0.2,ccp(boxSp:getContentSize().width/2+7,boxSp:getContentSize().height+8)))
		else
			arr1:addObject(CCMoveTo:create(0.2,ccp(boxSp:getContentSize().width/2,boxSp:getContentSize().height/2+45)))
		end
		arr1:addObject(CCCallFunc:create(callback2))
		boxLidSp:runAction(CCSequence:create(arr1))
	end
	runBoxAction(1)
	quickShowReslut=function()
		if _isBreak or _curRunActionIndex==nil or _curRunActionIndex>_listSize then
			do return end
		end
		_isBreak=true
		for i=_curRunActionIndex,_listSize do
			local boxSp=tolua.cast(_boxSpTb[i],"CCSprite")
			local lightSp=tolua.cast(boxSp:getChildByTag(1),"CCSprite")
			local icon=tolua.cast(boxSp:getChildByTag(2),"CCSprite")
			local boxLidSp=tolua.cast(boxSp:getChildByTag(3),"CCSprite")
			local boxOpenLidSp=tolua.cast(boxSp:getChildByTag(4),"CCSprite")
			local charmLb=tolua.cast(boxSp:getChildByTag(5),"CCSprite")
			local scale=_iconScale[i]
			boxLidSp:stopAllActions()
			boxOpenLidSp:stopAllActions()
			icon:stopAllActions()
			boxLidSp:setVisible(false)
			boxOpenLidSp:setVisible(true)
			boxOpenLidSp:setPosition(boxSp:getContentSize().width/2+45,boxSp:getContentSize().height/2+70)
			lightSp:setVisible(true)
			icon:setScale(scale)
			icon:setPosition(boxSp:getContentSize().width/2,boxSp:getContentSize().height/2+50)
			charmLb:setVisible(true)
			boxSp:setVisible(true)
		end
		-- topDescLb:setVisible(true)
		-- hxRewardLb:setVisible(true)
		sureBtn:setEnabled(true)
		sureBtn:setVisible(true)
		_curRunActionIndex=nil
	end
end

function acLmqrjTabOne:refreshUI()
	if self then
		if (not self.rewardBoxIsRunning) and self.rewardBoxSp and tolua.cast(self.rewardBoxSp,"CCSprite") then
			if acLmqrjVoApi:isCanGetCharmReward() then
				acLmqrjTabOne:rewardBoxAction(self.rewardBoxSp)
			end
		end

		if self.progressBar and self.progressLb and tolua.cast(self.progressBar,"CCSprite") and tolua.cast(self.progressLb,"CCLabelTTF") then
			local _curProgress=acLmqrjVoApi:getCharmNum()
			local _maxProgress=acLmqrjVoApi:getCurMaxScore()
			local _percent=_curProgress/_maxProgress
			_percent=((_percent>1) and 1 or _percent)
			self.progressBar:setScaleX(self.progressMaxWidth*_percent)
			self.progressLb:setString(getlocal("curProgressStr",{_curProgress,_maxProgress}))
		end
		if self.boxSpTb then
			for k, v in pairs(self.boxSpTb) do
				local ownedBg=tolua.cast(v:getChildByTag(3),"CCSprite")
				local ownedLb=tolua.cast(ownedBg:getChildByTag(1),"CCLabelTTF")
				ownedLb:setString(getlocal("propOwned")..acLmqrjVoApi:getBoxNum(k))
			end
		end

		if self.oneBtn and self.fiveBtn then
			-- local onBtnLb=tolua.cast(self.oneBtn:getChildByTag(15),"CCLabelTTF")

			local _fivePrice=acLmqrjVoApi:getFiveCost(self.curShowBoxIndex)
			local _onePrice=acLmqrjVoApi:getOneCost(self.curShowBoxIndex)
			local ownedBoxNum=acLmqrjVoApi:getBoxNum(self.curShowBoxIndex)
			-- local _num=(ownedBoxNum>5) and 5 or ownedBoxNum
			-- local _isFree=(_num>0) and true or false
			-- _num=(_num>0) and _num or 1
			local _isFree=(ownedBoxNum>0) and true or false
			if ownedBoxNum>0 and ownedBoxNum<5 then
				_fivePrice=(5-ownedBoxNum)*_onePrice
			end

			-- onBtnLb:setString(getlocal("activity_lmqrj_buttonText",{_num}))
			self.oneGoldLb:setString(tostring(_onePrice))
			self.fiveGoldLb:setString(tostring(_fivePrice))

			self.oneGoldSp:setVisible(false)
			self.oneGoldLb:setVisible(false)
			self.freeLb:setVisible(false)

			if _isFree then
				self.freeLb:setVisible(true)
				self.oneBtn:setNormalImage(CCSprite:createWithSpriteFrameName("newGreenBtn.png"))
				self.oneBtn:setSelectedImage(CCSprite:createWithSpriteFrameName("newGreenBtn_down.png"))
				self.oneBtn:setDisabledImage(CCSprite:createWithSpriteFrameName("newGreenBtn.png"))
			else
				self.oneGoldSp:setVisible(true)
				self.oneGoldLb:setVisible(true)
				self.oneBtn:setNormalImage(CCSprite:createWithSpriteFrameName("creatRoleBtn.png"))
				self.oneBtn:setSelectedImage(CCSprite:createWithSpriteFrameName("creatRoleBtn_Down.png"))
				self.oneBtn:setDisabledImage(CCSprite:createWithSpriteFrameName("creatRoleBtn.png"))
			end

			self.fiveFreeLb:setVisible(false)
			self.fiveGoldSp:setVisible(false)
			self.fiveGoldLb:setVisible(false)

			if ownedBoxNum>=5 then
				self.fiveFreeLb:setVisible(true)
				self.fiveBtn:setNormalImage(CCSprite:createWithSpriteFrameName("newGreenBtn.png"))
				self.fiveBtn:setSelectedImage(CCSprite:createWithSpriteFrameName("newGreenBtn_down.png"))
				self.fiveBtn:setDisabledImage(CCSprite:createWithSpriteFrameName("newGreenBtn.png"))
			else
				self.fiveGoldSp:setVisible(true)
				self.fiveGoldLb:setVisible(true)
				self.fiveBtn:setNormalImage(CCSprite:createWithSpriteFrameName("creatRoleBtn.png"))
				self.fiveBtn:setSelectedImage(CCSprite:createWithSpriteFrameName("creatRoleBtn_Down.png"))
				self.fiveBtn:setDisabledImage(CCSprite:createWithSpriteFrameName("creatRoleBtn.png"))
			end
		end
	end
end

function acLmqrjTabOne:tick()
	if self then
		if self.acTimeLb and tolua.cast(self.acTimeLb,"CCLabelTTF") then
    		self.acTimeLb:setString(acLmqrjVoApi:getTimeStr())
        end
        acLmqrjVoApi:checkIsToday(function() self:refreshUI() end)
	end
end

function acLmqrjTabOne:dispose()
	eventDispatcher:removeEventListener("acLmqrjTabOne.refreshUI",self.refreshUIListener)
	self.rewardBoxIsRunning=nil
	self.acTimeLb=nil
	self=nil
	spriteController:removePlist("public/acZnqd2017.plist")
	spriteController:removeTexture("public/acZnqd2017.png")
	spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/packsImage.plist")
    spriteController:removeTexture("public/packsImage.png")
    spriteController:removePlist("public/acCflmImage.plist")
    spriteController:removeTexture("public/acCflmImage.png")
end