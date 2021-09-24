newTipSmallDialog=smallDialog:new()

function newTipSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- 新奖励提示（不再是简单的飘字）
function newTipSmallDialog:showNewTipsDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,bgPoint,flag,reward,contentColor)
	local sd=newTipSmallDialog:new()
    sd:initTipsDialog(bgSrc,size,fullRect,CCRect(268, 35, 1, 1),textContnt,textSize,bgPoint,flag,reward,contentColor)
end

function newTipSmallDialog:showUpgradeDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,lastLevel)
	local sd=newTipSmallDialog:new()
    sd:initUpgradeDialog(bgSrc,size,fullRect,CCRect(268, 35, 1, 1),textContnt,textSize,lastLevel)
end

-- bgSrc:9宫格背景图片 size:对话框大小 callBack:确定回调函数 textContnt:文字内容 textSize:字体大小 contentColor:字体颜色，可放在table里使用，但目前发现使用该函数的情况很少，故只加了个参数，防传参出错
function newTipSmallDialog:initTipsDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,bgPoint,flag,reward,contentColor)
	if G_newTipSmallDialog then
		G_newTipSmallDialog:realClose()
		G_newTipSmallDialog=nil
	else
		G_newTipSmallDialog=self
	end
    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()

    local startH=G_VisibleSizeHeight/2
    local count=0

    self.propTb={}
    self.teshuPropTb={} -- 声望 经验 能量

    if reward and SizeOfTable(reward) then
    	for k,v in pairs(reward) do
    		if v.type and v.key and (
                    (v.type=="u" and (v.key=="exp" or v.key=="honors" or v.key=="energy"))
                    or (v.type=="tAllPoint" and (v.key=="pww"))
                ) then
    
	    		local height=G_VisibleSize.height
	    		if v.key=="energy" then
	    			height=G_VisibleSize.height/2+100
	    		elseif v.key=="honors" then
	    			height=G_VisibleSize.height/2
                elseif v.key=="pww" then
                    height=G_VisibleSize.height/2+50
	    		else
	    			height=G_VisibleSize.height/2+200
	    		end

	    		local purpleDi = CCSprite:createWithSpriteFrameName("purple_bottom.png")
	    		self.dialogLayer:addChild(purpleDi)
	    		purpleDi:setPosition(ccp(G_VisibleSize.width/2+150,height))
	    		purpleDi:setOpacity(200)

				local nameLb=GetTTFLabel(v.name,30)
				-- nameLb:setPosition(ccp(G_VisibleSize.width/2+150,height))
				-- self.dialogLayer:addChild(nameLb,1)
				nameLb:setColor(ccc3(255, 233, 48))
				nameLb:setAnchorPoint(ccp(0,0.5))
				purpleDi:addChild(nameLb,1)


				local numLb=GetBMLabel("+" .. v.num,G_GoldFontSrc,25)
				numLb:setAnchorPoint(ccp(0,0.5))
				numLb:setPosition(nameLb:getContentSize().width,nameLb:getContentSize().height/2)
				nameLb:addChild(numLb,1)
				numLb:setScale(0.5)

				local widthN=nameLb:getContentSize().width+numLb:getContentSize().width+70
				local scaleD=widthN/purpleDi:getContentSize().width
				purpleDi:setScaleX(scaleD)
				nameLb:setScaleX(1/scaleD)
				
				nameLb:setPosition(30+70/2,purpleDi:getContentSize().height/2)

				for i=1,2 do
					local particleSystem=CCParticleSystemQuad:create("public/textShine" ..  i .. ".plist")
					-- particleSystem:setPositionType(kCCPositionTypeRelative)
					particleSystem:setScale(2)
					particleSystem:setPosition(ccp(nameLb:getContentSize().width/2+35,nameLb:getContentSize().height/2+15))
					nameLb:addChild(particleSystem,2)
				end

	    		table.insert(self.teshuPropTb,{purpleDi,v.key})

    		else
    			local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("newTipDi.png",rrect,tmpFunc)
	    		dialogBg:setContentSize(CCSize(300,50))
	    		dialogBg:setIsSallow(false)
	    		self.dialogLayer:addChild(dialogBg,1)
	    		dialogBg:setAnchorPoint(ccp(0,0.5))


	    		table.insert(self.propTb,{dialogBg,startH})

	    		local icon
	    		if v.key  then
	    			icon = G_getItemIcon(v,100,nil,nil,nil,nil,nil,nil,nil,nil,true)
	    		else
	    			icon = CCSprite:createWithSpriteFrameName(v.pic)
	    		end
	    		local scNum = v.key =="p3390" and 50 or 60
	    		icon:setScale(scNum/icon:getContentSize().width)
	    		if v.type == "ac" and v.eType == "o" then --周年狂欢活动数字
	    			icon:setScale(scNum/icon:getContentSize().height)
	    		end
	    		icon:setPosition(20,dialogBg:getContentSize().height/2)
	    		dialogBg:addChild(icon,1)

	    		
	    		
	    		local nameLb = GetTTFLabelWrap(v.name .. "x" .. v.num,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    		nameLb:setAnchorPoint(ccp(0,0.5))
	    		nameLb:setPosition(60,dialogBg:getContentSize().height/2)
	    		dialogBg:addChild(nameLb,1)

	    		dialogBg:setPosition(G_VisibleSizeWidth+10,startH)
	    		

				startH=startH-70
    			
    		end

    	end
    end

    sceneGame:addChild(self.dialogLayer,99)


    self:showTipRunAction(reward)
    base:removeFromNeedRefresh(self) --停止刷新

end

function newTipSmallDialog:showTipRunAction(reward)
	for k,v in pairs(self.propTb) do
		local moveTo1=CCMoveTo:create(0.4,CCPointMake(G_VisibleSize.width/2-200,v[2]))
		local EaseBounce = CCEaseBackOut:create(moveTo1)
		local delayTime1 = CCDelayTime:create(1.2)
		local delayTime2 = CCDelayTime:create(k*0.2)

		local moveUp=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2-200,v[2]+200))
		local fade=CCFadeTo:create(0.3,0)

		local carray1=CCArray:create()
		carray1:addObject(moveUp)
		carray1:addObject(fade)
		local spa2=CCSpawn:create(carray1)


		local acArr=CCArray:create()
		acArr:addObject(delayTime2)
		acArr:addObject(EaseBounce)
		acArr:addObject(delayTime1)
		acArr:addObject(spa2)

		if k==SizeOfTable(reward) then
			local function realClose()
				if self then
					self:realClose()
					G_newTipSmallDialog=nil
				end
			end
			local fc= CCCallFunc:create(realClose)

			acArr:addObject(fc)
		else
			local function removeFromParent()
				if v[1] then
					v[1]:removeFromParentAndCleanup(true)
				end
			end
			local callFunc=CCCallFunc:create(removeFromParent)
			acArr:addObject(callFunc)
		end
		
		local seq=CCSequence:create(acArr)
		v[1]:runAction(seq)
	end

	for k,v in pairs(self.teshuPropTb) do
		local posX,posY=v[1]:getPosition()

		local moveTo1=CCMoveTo:create(2.5,CCPointMake(posX,posY+100))
		local EaseExponentialOut = CCEaseExponentialOut:create(moveTo1)
		local acArr=CCArray:create()
		acArr:addObject(EaseExponentialOut)
		if k==SizeOfTable(self.teshuPropTb) then
			local function realClose()
				self:realClose()
				G_newTipSmallDialog=nil
			end
			local fc= CCCallFunc:create(realClose)

			acArr:addObject(fc)
		else
			local function removeFromParent()
				if v[1] then
					v[1]:removeFromParentAndCleanup(true)
				end
			end
			local callFunc=CCCallFunc:create(removeFromParent)
			acArr:addObject(callFunc)
		end
		local seq=CCSequence:create(acArr)
		v[1]:runAction(seq)
	end
	
end

function newTipSmallDialog:addtouchDialogBg()
	local function nilFunc()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
			if self.endFlag then
				base.setWaitTime=G_getCurDeviceMillTime()
				if self then
					self:realClose()
				end
			end
		    
		end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    touchDialogBg:setTouchPriority(-1000)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setAnchorPoint(ccp(0,0))
    touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg)
    self.touchDialogBg=touchDialogBg
end

function newTipSmallDialog:initUpgradeDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,lastLevel)
	-- self.dialogLayer=CCLayer:create()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/t99999Image.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
	spriteController:addPlist("public/nbSkill.plist")
	if base.hs==1 and playerVoApi:getPlayerLevel()==20 then
		spriteController:addPlist("public/heroSmeltImage.plist")
	    spriteController:addTexture("public/heroSmeltImage.png")
	end

	self.addPlist=true
	self.dialogLayer=CCLayerColor:create(ccc4(0,0,0,200))

	
    local function tmpFunc()
    end

    local startH=G_VisibleSizeHeight/2+100

    local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp:setPosition(G_VisibleSizeWidth/2,startH+160)
    self.dialogLayer:addChild(guangSp,1)
    guangSp:setScale(0.001)

    local guangSp1 = CCSprite:createWithSpriteFrameName("equipShine.png")
    guangSp1:setPosition(G_VisibleSizeWidth/2,startH+160)
    self.dialogLayer:addChild(guangSp1,1)
    guangSp1:setScale(0.001)

    local upGradeSp=CCSprite:createWithSpriteFrameName("playerUpgradeDi.png")
    upGradeSp:setPosition(G_VisibleSizeWidth/2,startH+250)
    self.dialogLayer:addChild(upGradeSp,1)
    upGradeSp:setScale(3)
    upGradeSp:setOpacity(0)



    local upGradeZi=CCSprite:createWithSpriteFrameName("playerUpgradeZi.png")
    upGradeZi:setPosition(G_VisibleSizeWidth/2,startH+50)
    self.dialogLayer:addChild(upGradeZi,1)
    upGradeZi:setScale(0.001)

    local continueBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg_black.png",CCRect(20, 20, 10, 10),function ()end)
	continueBg:setContentSize(CCSizeMake(continueBg:getContentSize().width,50))
	local Scale=300/continueBg:getContentSize().width
	continueBg:setScaleX(Scale)
	continueBg:setPosition(G_VisibleSizeWidth+160,110)
	self.dialogLayer:addChild(continueBg,2)

	local continueLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(300-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- continueLb:setAnchorPoint(ccp(0,0))
	continueLb:setPosition(continueBg:getContentSize().width/2,continueBg:getContentSize().height/2)
	continueLb:setScaleX(1/Scale)
	continueBg:addChild(continueLb,1)
	continueLb:setColor(G_ColorYellowPro)
	continueBg:setVisible(false)

    

	-- local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
	-- titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,50))
	-- local Scale=300/titleBg:getContentSize().width
	-- titleBg:setScaleX(Scale)
	-- titleBg:setPosition(-160,startH+50)
	-- self.dialogLayer:addChild(titleBg,2)

	-- local arrowSp = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
 --    arrowSp:setAnchorPoint(ccp(0.5,0.5))
 --    titleBg:addChild(arrowSp)
 --    arrowSp:setScaleX(1/Scale)
 --    arrowSp:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2)

    local playerLv = playerVoApi:getPlayerLevel()

 --    local nowLevelLb=GetTTFLabel(G_LV() .. playerLv,25)
 --    nowLevelLb:setAnchorPoint(ccp(0,0.5))
	-- nowLevelLb:setPosition(arrowSp:getContentSize().width+10,arrowSp:getContentSize().height-10)
	-- arrowSp:addChild(nowLevelLb,1)

	-- local lastLevelLb=GetTTFLabel(G_LV() .. lastLevel,25)
 --    lastLevelLb:setAnchorPoint(ccp(1,0.5))
	-- lastLevelLb:setPosition(-10,arrowSp:getContentSize().height-10)
	-- arrowSp:addChild(lastLevelLb,1)

	-- self:showUpgradeRunAction2(titleBg,5)






	----------------- 新改版 ----------------------- 新改版 ------------------------ 新改版 --------------------- 新改版 -----------------------------
	self:addtouchDialogBg()
	local cfgDataTb = {}
	if levelShowCfg and levelShowCfg[playerLv] then
		for k, v in pairs(levelShowCfg[playerLv]) do
			local isShow = true
			if v.switch and SizeOfTable(v.switch) ~= 0 then
				for kk, vv in pairs(v.switch) do
					if base[vv] == 0 then
						isShow = false
						break
					end
				end
			end
			if isShow == true then
				table.insert(cfgDataTb, v)
			end
		end
	end
	if fuctionOpenCfg then
		for k, v in pairs(fuctionOpenCfg) do
			local limitLv = base[v.limitLvSet] or v.limitLv
			if v.des == "alienMines" then
				if limitLv < v.limitLv then
					limitLv = v.limitLv
				end
			end
			if playerLv == limitLv then
				local isShow = true
				if v.switch and SizeOfTable(v.switch) ~= 0 then
					for kk, vv in pairs(v.switch) do
						if base[vv] == 0 then
							isShow = false
							break
						end
					end
				end
				if isShow == true then
					table.insert(cfgDataTb, v)
				end
			end
		end
	end
	table.sort( cfgDataTb, function(a,b) return a.type>b.type end )
	local cellNum = SizeOfTable(cfgDataTb)
	local cellHeight = 70
	local tvSize = CCSizeMake(355,startH+45-continueBg:getPositionY())
	local cellNodeTb = {}
	local function tvCallBack(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return cellNum
		elseif fn=="tableCellSizeForIndex" then
			return CCSizeMake(tvSize.width,cellHeight)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local cellW,cellH = tvSize.width,cellHeight
			local v = cfgDataTb[idx+1]

			local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("newTipDi.png",CCRect(0, 50, 1, 1),function()end)
    		dialogBg:setContentSize(CCSize(cellW-5,50))
    		dialogBg:setAnchorPoint(ccp(1,0.5))
    		dialogBg:setPosition(cellW*2,cellH/2)
    		cell:addChild(dialogBg)
    		local icon
    		local iconStr=v.icon
    		if platCfg.platCfgNewTypeAddTank==true and v.icon and v.icon=="bossIcon.png" then
    			iconStr="bossIcon2.png"
    		end
    		if v.iconbg=="true" then
    			icon=GetBgIcon(iconStr,nil,"Icon_BG.png",60)
    		else
    			icon = CCSprite:createWithSpriteFrameName(iconStr)
    		end
    		icon:setScale(60/icon:getContentSize().width)
    		icon:setAnchorPoint(ccp(0,0.5))
    		dialogBg:addChild(icon,1)
    		icon:setPosition(-5,dialogBg:getContentSize().height/2)
    		-- 1新玩法 2新建筑 3新活动 4
    		local des=""
    		if v.type==1 then
    			des=getlocal("new_function",{getlocal(v.des)})
    		elseif v.type==2 then
    			des=getlocal("new_building",{getlocal(v.des)})
    		elseif v.type==3 then
    			des=getlocal("new_activity",{getlocal(v.des)})
    		elseif v.num then
    			des=getlocal(v.des) .. "+" .. v.num
    		else
    			des=getlocal(v.des)
    		end
			local desLb = GetTTFLabelWrap(des,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			desLb:setAnchorPoint(ccp(0,0.5))
			desLb:setPosition(75,dialogBg:getContentSize().height/2)
			dialogBg:addChild(desLb,1)

			cellNodeTb[idx+1]=dialogBg

			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded" then
		end
	end
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function()end)
	tvBg:setContentSize(tvSize)
	tvBg:setAnchorPoint(ccp(0.5,0))
	tvBg:setPosition(G_VisibleSizeWidth/2,continueBg:getPositionY()+continueBg:getContentSize().height/2)
	tvBg:setOpacity(0)
	tvBg:setIsSallow(true)
	tvBg:setTouchPriority(-1001)
	self.dialogLayer:addChild(tvBg,1)
	local hd=LuaEventHandler:createHandler(tvCallBack)
    local tv=LuaCCTableView:createWithEventHandler(hd,tvSize,nil)
    -- tv:setTableViewTouchPriority(-1001)
    tv:setPosition(ccp((G_VisibleSizeWidth-tvSize.width)/2,continueBg:getPositionY()+continueBg:getContentSize().height/2))
    self.dialogLayer:addChild(tv,1)
    tv:setMaxDisToBottomOrTop(0)
    local cellAction
	local _cellPosY
	cellAction = function(index)
		if cellNodeTb and cellNodeTb[index] then
			local tvPoint = tv:getRecordPoint()
			if tvPoint.y < 0 then
				if _cellPosY==nil then
					_cellPosY=tvPoint.y
				end
				local _cellH = index*cellHeight
			    if _cellH>tvSize.height then
			    	tvPoint.y = _cellPosY + math.abs(tvSize.height-_cellH)
			    	tv:recoverToRecordPoint(tvPoint)
			    end
			end

			local arry=CCArray:create()
			if index==1 then
				arry:addObject(CCDelayTime:create(1))
			end
			arry:addObject(CCMoveTo:create(0.2,ccp(tvSize.width,cellHeight/2)))
			arry:addObject(CCCallFunc:create(function() cellAction(index+1) end))
			cellNodeTb[index]:runAction(CCSequence:create(arry))

			cellNodeTb[index]:setVisible(true)
		else
			tv:setTableViewTouchPriority(-1001)
			continueBg:setPositionX(G_VisibleSizeWidth/2)
			continueBg:setVisible(true)
			self.endFlag=true
		end
	end
	cellAction(1)
	----------------- 新改版 ----------------------- 新改版 ------------------------ 新改版 --------------------- 新改版 -----------------------------

--[[ 旧版逻辑
    self.flag=false
    local count=0
    if fuctionOpenCfg then
    	for k,v in pairs(fuctionOpenCfg) do
    		local limitLv=base[v.limitLvSet] or v.limitLv
    		if v.des=="alienMines" then
    			if limitLv<v.limitLv then
    				limitLv=v.limitLv
    			end
    		end
    		if playerLv==limitLv then
    			local isShow=true
    			if v.switch and SizeOfTable(v.switch)~=0 then
	    			for kk,vv in pairs(v.switch) do
	    				if base[vv]==0 then
	    					isShow=false
	    					break
	    				end
	    			end
	    		end
	    		if isShow==true then
		    		count=count+1

		    		local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("newTipDi.png",CCRect(0, 50, 1, 1),tmpFunc)
		    		dialogBg:setContentSize(CCSize(350,50))
		    		dialogBg:setIsSallow(false)
		    		self.dialogLayer:addChild(dialogBg,1)
		    		dialogBg:setPosition(G_VisibleSizeWidth+dialogBg:getContentSize().width/2+10,startH)

		    		local icon
		    		local iconStr=v.icon
		    		if platCfg.platCfgNewTypeAddTank==true and v.icon and v.icon=="bossIcon.png" then
		    			iconStr="bossIcon2.png"
		    		end
		    		if v.iconbg=="true" then
		    			icon=GetBgIcon(iconStr,nil,"Icon_BG.png",60)
		    		else
		    			icon = CCSprite:createWithSpriteFrameName(iconStr)
		    		end
		    		-- local icon = CCSprite:createWithSpriteFrameName(v.icon)
		    		icon:setScale(60/icon:getContentSize().width)
		    		icon:setAnchorPoint(ccp(0,0.5))
		    		dialogBg:addChild(icon,1)
		    		icon:setPosition(-5,dialogBg:getContentSize().height/2)

		    		local des=""
		    		if v.type==1 then
		    			des=getlocal("new_function",{getlocal(v.des)})
		    		elseif v.type==2 then
		    			des=getlocal("new_building",{getlocal(v.des)})
		    		elseif v.type==3 then
		    			des=getlocal("new_activity",{getlocal(v.des)})
		    		elseif v.num then
		    			des=getlocal(v.des) .. "+" .. v.num
		    		else
		    			des=getlocal(v.des)
		    		end
					local desLb = GetTTFLabelWrap(des,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					desLb:setAnchorPoint(ccp(0,0.5))
					desLb:setPosition(75,dialogBg:getContentSize().height/2)
					dialogBg:addChild(desLb,1)

					startH=startH-70
					self:showUpgradeRunAction2(dialogBg,count+4)
				end
    		end
    	end
    end
    if levelShowCfg and levelShowCfg[playerLv] then
    	
    	self:addtouchDialogBg()
    	for k,v in pairs(levelShowCfg[playerLv]) do
    		local isShow=true
    		if v.switch and SizeOfTable(v.switch)~=0 then
    			for kk,vv in pairs(v.switch) do
    				if base[vv]==0 then
    					isShow=false
    					break
    				end
    			end
    		end
    		if isShow==true then
	    		count=count+1

	    		local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("newTipDi.png",CCRect(0, 50, 1, 1),tmpFunc)
	    		dialogBg:setContentSize(CCSize(350,50))
	    		dialogBg:setIsSallow(false)
	    		self.dialogLayer:addChild(dialogBg,1)
	    		dialogBg:setPosition(G_VisibleSizeWidth+dialogBg:getContentSize().width/2+10,startH)

	    		local icon
	    		local iconStr=v.icon
	    		if platCfg.platCfgNewTypeAddTank==true and v.icon and v.icon=="bossIcon.png" then
	    			iconStr="bossIcon2.png"
	    		end
	    		if v.iconbg=="true" then
	    			icon=GetBgIcon(iconStr,nil,"Icon_BG.png",60)
	    		else
	    			icon = CCSprite:createWithSpriteFrameName(iconStr)
	    		end
	    		-- local icon = CCSprite:createWithSpriteFrameName(v.icon)
	    		icon:setScale(60/icon:getContentSize().width)
	    		icon:setAnchorPoint(ccp(0,0.5))
	    		dialogBg:addChild(icon,1)
	    		icon:setPosition(-5,dialogBg:getContentSize().height/2)

	    		local des=""
	    		if v.type==1 then
	    			des=getlocal("new_function",{getlocal(v.des)})
	    		elseif v.type==2 then
	    			des=getlocal("new_building",{getlocal(v.des)})
	    		elseif v.type==3 then
	    			des=getlocal("new_activity",{getlocal(v.des)})
	    		elseif v.num then
	    			des=getlocal(v.des) .. "+" .. v.num
	    		else
	    			des=getlocal(v.des)
	    		end
				local desLb = GetTTFLabelWrap(des,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				desLb:setAnchorPoint(ccp(0,0.5))
				desLb:setPosition(75,dialogBg:getContentSize().height/2)
				dialogBg:addChild(desLb,1)

				startH=startH-70
				self:showUpgradeRunAction2(dialogBg,count+4)
			end
    	end
    	self:showUpgradeRunAction2(continueBg,count+1,true)
    else
    	self.flag=true
    	-- self.touchDialogBg:setOpacity(0)
    end
--]]
    self:showUpgradeRunAction1(upGradeSp,upGradeZi,guangSp,guangSp1)

	sceneGame:addChild(self.dialogLayer,30)
	base:removeFromNeedRefresh(self) --停止刷新

end

function newTipSmallDialog:showUpgradeRunAction2(dialogBg,num,flag)
	local posY =dialogBg:getPositionY()
	local moveTo1=CCMoveTo:create(0.6,CCPointMake(G_VisibleSizeWidth/2,posY))
	local EaseExponentialOut = CCEaseExponentialOut:create(moveTo1)

	local delayTime1 = CCDelayTime:create(num*0.2)

	local acArr=CCArray:create()
	acArr:addObject(delayTime1)
	acArr:addObject(EaseExponentialOut)
	if flag then
		local function setEndFlag()
			dialogBg:setVisible(true)
	        self.endFlag=true
	    end
	    local callFuncEnd=CCCallFunc:create(setEndFlag)
	    acArr:addObject(callFuncEnd)

	end
	local seq=CCSequence:create(acArr)
	dialogBg:runAction(seq)

end

function newTipSmallDialog:showUpgradeRunAction1(upGradeSp,upGradeZi,guangSp,guangSp1)
	-- upGradeSp 动画
	upGradeSp:runAction(self:getAction1(0.96,1,upGradeSp))

	-- upGradeZi 动画
	upGradeZi:runAction(self:getAction2(1.3,1,upGradeZi,true))

	-- guangSp
	local seq2 = self:getAction2(2,2,upGradeZi)
	local rotate1=CCRotateBy:create(4,360)
	local forAc = CCRepeatForever:create(rotate1)
	guangSp:runAction(forAc)
	guangSp:runAction(seq2)

	-- guangSp1
	local reverseBy = rotate1:reverse()
	local forAc1 = CCRepeatForever:create(reverseBy)
	local seq3 = self:getAction2(2,2,upGradeZi)
	guangSp1:runAction(forAc1)
	guangSp1:runAction(seq3)

	-- 位移加速，延迟
end

function newTipSmallDialog:getAction1(scale1,scale2,upGradeSp)
	local posX,posY=upGradeSp:getPosition()
	local moveTo1=CCMoveTo:create(0.2,CCPointMake(posX,posY-100))
	local easeExponentialIn= CCEaseElasticOut:create(moveTo1)
	local  fadeTo = CCFadeTo:create(0.2,255)
	local function playMusic()
        PlayEffect(audioCfg.palyerUpgrade)
    end
    local function addParticle()
         local upP=CCParticleSystemQuad:create("public/playerUpgradeP.plist")
		upP:setPositionType(kCCPositionTypeRelative)
		upP:setPosition(upGradeSp:getPosition())
		upP:setScale(1.2)
		self.dialogLayer:addChild(upP)
    end
  
    -- playerUpgradeP
    local callFuncmusic=CCCallFunc:create(playMusic)
    local callFuncaddp=CCCallFunc:create(addParticle)

	local scaleTo2=CCScaleTo:create(0.1,scale1)
	local scaleTo3=CCScaleTo:create(0.005,scale2)
	local carray2=CCArray:create()
	carray2:addObject(scaleTo2)
	carray2:addObject(fadeTo)
	carray2:addObject(easeExponentialIn)
	carray2:addObject(callFuncmusic)
	local spa2=CCSpawn:create(carray2)

	local carray3=CCArray:create()
	carray3:addObject(spa2)
	carray3:addObject(callFuncaddp)
	carray3:addObject(scaleTo3)
	local seq1=CCSequence:create(carray3)
	return seq1
end

-- flag 是不是字  是字并且没有其他提示，飘字直接关闭
function newTipSmallDialog:getAction2(scale1,scale2,upGradeZi,flag)
	local delayAc = CCDelayTime:create(0.2)
-- self.flag
	local posX,posY=upGradeZi:getPosition()
	local moveTo1=CCMoveTo:create(0.3,CCPointMake(posX,posY+100))
	local easeExponentialIn= CCEaseSineIn:create(moveTo1)

	local fade2=CCFadeIn:create(0.4)
	local scaleTo2=CCScaleTo:create(0.4,scale1)
	local scaleTo3=CCScaleTo:create(0.1,scale2)
	local carray2=CCArray:create()
	carray2:addObject(fade2)
	carray2:addObject(scaleTo2)
	carray2:addObject(easeExponentialIn)
	local spa2=CCSpawn:create(carray2)



	local carray3=CCArray:create()
	carray3:addObject(delayAc)
	carray3:addObject(spa2)
	carray3:addObject(scaleTo3)

	if flag and self.flag then
		local function closeFunc()
			if self then
				self:realClose()
			end
	        
	    end
    -- playerUpgradeP
	    local callFuncClose=CCCallFunc:create(closeFunc)
	    local delayAc = CCDelayTime:create(1)
	    carray3:addObject(delayAc)
	    carray3:addObject(callFuncClose)
	end

	local seq1=CCSequence:create(carray3)
	return seq1
end

function newTipSmallDialog:dispose()
	if self.addPlist then
		if base.hs==1 and playerVoApi:getPlayerLevel()==20 then
			spriteController:removePlist("public/heroSmeltImage.plist")
		    spriteController:removeTexture("public/heroSmeltImage.png")
		end
		spriteController:removePlist("public/nbSkill.plist")
		self.addPlist=nil
	end
end




