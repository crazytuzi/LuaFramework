acYdczDialog=commonDialog:new()

function acYdczDialog:new()
	local nc={}

	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acYdczDialog:doUserHandler()
	self.url=G_downloadUrl("active/ydczBg.jpg")
	self.cellHeightTb={}
	self.rewardList={}
	local rewardLv=acYdczVoApi:getRewardLv()
	local rlist=acYdczVoApi:getRewardList()
	for k,v in pairs(rlist) do
		local rewardTb=FormatItem(v,nil,true)
		table.insert(self.rewardList,rewardTb)
	end
	local maxLv=SizeOfTable(self.rewardList)
	self.cellNum=rewardLv+1 --奖励显示到当前解锁档位的下一档
	if self.cellNum>maxLv then
		self.cellNum=maxLv
	end
	self.unlockTb=acYdczVoApi:getRewardUnlockCfg()
end

function acYdczDialog:initTableView()
	self.panelLineBg:setVisible(false)
   	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/avt_images.plist")
    spriteController:addTexture("public/avt_images.png")
    spriteController:addPlist("public/avt_images1.plist")
    spriteController:addTexture("public/avt_images1.png")
	spriteController:addPlist("public/youhuaUI4.plist")
   	spriteController:addTexture("public/youhuaUI4.png")
	spriteController:addPlist("public/acydcz_images.plist")
   	spriteController:addTexture("public/acydcz_images.png")
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setOpacity(255*0.6)
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-85))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)
    
    local function onLoadIcon(fn,ydczBg)
        if self and self.bgLayer then
            ydczBg:setAnchorPoint(ccp(0.5,1))
            ydczBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-85)
            self.bgLayer:addChild(ydczBg)
        end
    end
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	--活动时间
	local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    timeBg:setOpacity(255*0.6)
    timeBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-85)
    self.bgLayer:addChild(timeBg,2)
	local date=G_getDate(base.serverTime)
	local timeStr=getlocal("activity_ydcz_countdown",{getlocal("month_name"..date.month),GetTimeStr(G_getIntervalTimeEOM(),true)})
	local acTimeLb=GetTTFLabelWrap(timeStr,22,CCSizeMake(G_VisibleSizeWidth-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	acTimeLb:setPosition(timeBg:getContentSize().width/2,timeBg:getContentSize().height-25)
	acTimeLb:setColor(G_ColorYellowPro)
	timeBg:addChild(acTimeLb)
	self.acTimeLb=acTimeLb

	--充值进度
	local rechargeLb,lbheight=self:createRechargeLb()

	--叛军特有buff介绍
	local descMaxHeight=100
	local recharge,need=acYdczVoApi:getRecharge()
    local descTb={
        {getlocal("activity_ydcz_rebelbuff",{need}),{nil,G_ColorYellowPro,nil,G_ColorYellowPro},nil,true},
    }
    local desTv,descHeight,tvHeight=G_LabelTableViewNew(CCSizeMake(G_VisibleSizeWidth-230,descMaxHeight),descTb,20,kCCTextAlignmentLeft,nil,nil,nil,true)
    desTv:setAnchorPoint(ccp(0,0))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(desTv,2)
	local offset=0
	if descHeight>descMaxHeight then
		offset=80
	end
    desTv:setMaxDisToBottomOrTop(offset)
    desTv:setPosition(210,G_VisibleSizeHeight-255-tvHeight/2)

	--叛军特有buff显示
	local function showBuffInfo()
	    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    	tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("rebelbuff_namestr"),{getlocal("rebelbuff_descstr")},nil,nil,nil,"ydcz")
	end
	local rebelBuffSp,activeLb=rebelVoApi:getRebelBuffSp(self.bgLayer,ccp(108,G_VisibleSizeHeight-250),2,self.layerNum,showBuffInfo)
	self.activeLb=activeLb

	local tvPosY=120
	self.tvWidth,self.tvHeight=616,G_VisibleSizeHeight-85-270-tvPosY
	local function callBack(...)
		return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
	self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,tvPosY)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(self.tv,2)

	local btnScale,priority=0.8,-(self.layerNum-1)*20-4
	--跳转充值
	local function goRecharge()
		vipVoApi:showRechargeDialog(self.layerNum+1)
		activityAndNoteDialog:closeAllDialog()
	end
	--升级奖励
	local function upgradeHandler()
		local function realUpgrade()
			local function refresh()
				self:refresh()
			end
			acYdczVoApi:ydczRewardUpgrade(refresh)
		end
     	local desInfo={25,G_ColorYellowPro,kCCTextAlignmentCenter}    
        local addStrTb={
            {getlocal("activity_ydcz_upgradeTip"),G_ColorRed,25,kCCTextAlignmentCenter,20}
        }
		G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("activity_ydcz_upgrade"),false,realUpgrade,nil,nil,desInfo,addStrTb)
	end
	local rechargeBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2+140,60),{getlocal("new_recharge_recharge_now")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",goRecharge,btnScale,priority)
	self.upgradeBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2-140,60),{getlocal("activity_ydcz_upgradeReward")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeHandler,btnScale,priority)
	local flag=acYdczVoApi:isCanUpgrade()
	self.upgradeBtn:setEnabled(flag)
end

function acYdczDialog:createRechargeLb()
	if self.rechargeLb then
		self.rechargeLb:removeFromParentAndCleanup(true)
		self.rechargeLb=nil
	end
	local recharge,need=acYdczVoApi:getRecharge()
	local str,colorTb="",{}
	if recharge<need then
		colorTb={nil,G_ColorRed,G_ColorYellowPro}
		str=getlocal("activity_ydcz_recharge",{recharge,need})
	else
		colorTb={G_ColorYellowPro}
		str=getlocal("activity_ydcz_rechargefull")
	end
	local rechargeLb,lbheight=G_getRichTextLabel(str,colorTb,22,G_VisibleSizeWidth-60,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  	rechargeLb:setAnchorPoint(ccp(0.5,1))
	rechargeLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-145)
	self.bgLayer:addChild(rechargeLb,2)
	self.rechargeLb=rechargeLb
	return rechargeLb,lbheight
end

function acYdczDialog:getCellHeight(idx)
	if self.cellHeightTb[idx]==nil then
		local rewardTb=self.rewardList[idx]
		local num=SizeOfTable(rewardTb)
		local stateLb,lbheight=self:getRewardStateLb(idx)
		self.cellHeightTb[idx]=32+6+10
		local statelbh=lbheight+20
		local rh=math.ceil(num/5)*80+(math.ceil(num/5)-1)*10+20 --奖励所占的高度
		local cuph=200 --奖杯的高度
		if (rh+statelbh)>cuph then
			self.cellHeightTb[idx]=self.cellHeightTb[idx]+rh+statelbh
		else
			self.cellHeightTb[idx]=self.cellHeightTb[idx]+cuph
		end
	end
	return self.cellHeightTb[idx]
end

function acYdczDialog:getRewardStateLb(rid)
    local avtId,subId
    if self.unlockTb[rid] then
    	avtId,subId=self.unlockTb[rid][1],self.unlockTb[rid][2]
    end
	local state=acYdczVoApi:getRewardState(rid)
	local stateStr,colorTb="",{}
	if state==5 or state==6 then
		if state==5 then
			colorTb={G_ColorGray2}
		elseif state==6 then
			colorTb={G_ColorYellowPro}
		end
		stateStr=getlocal("activity_ydcz_reward_state"..state)
	else
		local nameStr,nameColor=achievementVoApi:getAvtNameStrAndColor(1,avtId,subId)
		if state==1 then
			colorTb={nameColor,G_ColorGray2}
		elseif state==2 then
			colorTb={nameColor,G_ColorYellowPro}
		elseif state==3 then
			colorTb={nameColor,G_ColorGreen}
		elseif state==4 then
			colorTb={G_ColorRed,nameColor,G_ColorRed}
		end
		stateStr=getlocal("activity_ydcz_reward_state"..state,{nameStr})
	end
	local stateLb,lbheight=G_getRichTextLabel(stateStr,colorTb,18,self.tvWidth-200,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	return stateLb,lbheight,state
end

function acYdczDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.tvWidth,self:getCellHeight(idx+1))
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local rid=idx+1
        local cellHeight=self:getCellHeight(rid)
        local itemHeight=cellHeight-10
    	local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () end)
    	itemBg:setAnchorPoint(ccp(0.5,1))
		itemBg:setContentSize(CCSizeMake(self.tvWidth,itemHeight))
		itemBg:setPosition(self.tvWidth/2,cellHeight)
		cell:addChild(itemBg)

		--奖励标题
		local  titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
		titleBg:setAnchorPoint(ccp(0,1))
		titleBg:setPosition(0,itemHeight-2)
		titleBg:setContentSize(CCSizeMake(self.tvWidth-200,32))
		itemBg:addChild(titleBg)
		local titleLb=GetTTFLabelWrap(getlocal("activity_ydcz_rewardTitle",{rid}),22,CCSizeMake(titleBg:getContentSize().width-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(15,titleBg:getContentSize().height/2)
		titleBg:addChild(titleLb)
		
        local avtId,subId
        if self.unlockTb[rid] then
        	avtId,subId=self.unlockTb[rid][1],self.unlockTb[rid][2]
        end
		local stateLb,lbheight,state=self:getRewardStateLb(rid)
	  	stateLb:setAnchorPoint(ccp(0,1))
		itemBg:addChild(stateLb)
		local rewardTb=self.rewardList[rid]
		local num=SizeOfTable(rewardTb)

		local iconWidth,offx,offy=80,10,10
		local statelbh=lbheight+20
		local rh=math.ceil(num/5)*iconWidth+(math.ceil(num/5)-1)*offy+20 --奖励所占的高度
		local cuph=200 --奖杯的高度
        local avtSp
        --跳转成就系统页面
        local function goAvtDialog()
        	if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
	        	if avtId==nil or subId==nil then
	        		do return end
	        	end
				-- if state==1 or state==5 then --奖励过期的话不触发点击事件
				-- 	do return end
				-- end
	        	G_goToDialog2("personAvt",self.layerNum,true,avtId,subId)
        	end
        end
        local avtState
        if avtId and subId then --默认解锁
        	avtState=achievementVoApi:getAvtState(1,avtId,subId)
        end
    	avtSp=achievementVoApi:getAvtSimpleIcon(avtId,subId,nil,goAvtDialog,avtState)    
        avtSp:setTouchPriority(-(self.layerNum-1)*20-2)
        avtSp:setAnchorPoint(ccp(0.5,0.5))
        itemBg:addChild(avtSp)
        if acYdczVoApi:getRewardLv()<rid then --未解锁的做动作
        	local cuplightSp=tolua.cast(avtSp:getChildByTag(102),"CCSprite")
  			if cuplightSp then
  				for i=1,2 do
  					local acArr=CCArray:create()
		         	local fadeOut=CCFadeOut:create(0.5)
		            local fadeIn=CCFadeIn:create(0.5)
		            acArr:addObject(fadeOut)
		            acArr:addObject(fadeIn)
		            acArr:addObject(CCDelayTime:create(0.5))
		            local seq=CCSequence:create(acArr)
		            if i==1 then
		            	avtSp:runAction(CCRepeatForever:create(seq))
		            else
		            	cuplightSp:runAction(CCRepeatForever:create(seq))
		            end
  				end
  			end
        end

        local centerY=(itemHeight-32-6)/2
    	avtSp:setPosition(5+avtSp:getContentSize().width/2,centerY)

        local bgWidth,bgHeight=20+5*iconWidth+4*offx,rh
    	local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () end)
		rewardBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
		rewardBg:setAnchorPoint(ccp(0,0.5))
		rewardBg:setOpacity(0)
		itemBg:addChild(rewardBg)
		
		local leftPosX=156
		if (rh/2+statelbh)>centerY then
			stateLb:setPosition(leftPosX+10,10+lbheight)
			rewardBg:setPosition(leftPosX,stateLb:getPositionY()+10+bgHeight/2)
		else
			rewardBg:setPosition(leftPosX,centerY)
			stateLb:setPosition(leftPosX+10,centerY-bgHeight/2-10)
		end

		for k,v in pairs(rewardTb) do
			local posx,posy=10+((k-1)%5)*(iconWidth+offx),bgHeight-10-math.floor((k-1)/5)*(iconWidth+offy)
			local function showInfoDialog()
				-- if state==1 or state==5 then --奖励过期的话不触发点击事件
				-- 	do return end
				-- end
        		if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
				end
			end
			local iconSp=G_getItemIcon(v,100,false,self.layerNum+1,showInfoDialog)
			iconSp:setAnchorPoint(ccp(0,1))
			iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
			iconSp:setScale(iconWidth/iconSp:getContentSize().width)
			iconSp:setPosition(posx,posy)
			rewardBg:addChild(iconSp)

            local numLb=GetTTFLabel(FormatNumber(v.num),20)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(iconSp:getContentSize().width-5,0))
            iconSp:addChild(numLb,2)
            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function () end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width+5,numLb:getContentSize().height-5))
            numBg:setPosition(ccp(iconSp:getContentSize().width-5,5))
            numBg:setOpacity(150)
            iconSp:addChild(numBg,1)
		end
        local tipBg,tipStr,color
		local flag=acYdczVoApi:isRewardReceived(rid)
        if flag==true then
        	tipStr=getlocal("activity_ydcz_rewarded")
        	tipBg=CCSprite:createWithSpriteFrameName("ydczStateBg.png")
        	color=G_ColorRed
        elseif state>=1 then --已过期
        	tipBg=GraySprite:createWithSpriteFrameName("ydczStateBg.png")
        	color=G_ColorGray2
			if state==1 or state==5 then
	        	tipStr=getlocal("expireDesc")
	     	elseif state==2 then
	     		local acVo=acYdczVoApi:getAcVo()
	     		if (acVo.rid or 0)<=0 then
	        		tipStr=getlocal("activity_ydcz_noGive")
	        	else
		        	tipStr=getlocal("activity_ydcz_nextReward")
	     		end
			elseif state==3 or state==4 then
	        	tipStr=getlocal("activity_ydcz_noReward")
			end
        end
        if tipBg and tipStr and color then
            tipBg:setPosition(self.tvWidth-tipBg:getContentSize().width/2-10,itemHeight-50)
            tipBg:setRotation(22)
            itemBg:addChild(tipBg,3)
            local tipLb=GetTTFLabelWrap(tipStr,20,CCSizeMake(tipBg:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            tipLb:setColor(color)
            tipLb:setPosition(getCenterPoint(tipBg))
            tipBg:addChild(tipLb)
        end
		-- if state==1 or state==5 then --奖励如果过期的话加黑色遮罩
  --           local itemShadeBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function () end)
  --  			itemShadeBg:setAnchorPoint(ccp(0.5,1))
		-- 	itemShadeBg:setContentSize(itemBg:getContentSize())
		-- 	itemShadeBg:setPosition(itemBg:getPosition())
  --           itemShadeBg:setOpacity(255*0.4)
  --           cell:addChild(itemShadeBg,3)
		-- end

        return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function acYdczDialog:refresh()
	if self.tv then
		local maxLv=SizeOfTable(self.rewardList)
		local rewardLv=acYdczVoApi:getRewardLv()
		self.cellNum=rewardLv+1 --奖励显示到当前解锁档位的下一档
		if self.cellNum>maxLv then
			self.cellNum=maxLv
		end
		self.cellHeightTb={}
       	local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
	end
	if self.upgradeBtn then
		local flag=acYdczVoApi:isCanUpgrade()
		self.upgradeBtn:setEnabled(flag)
	end
	if self.activeLb and tolua.cast(self.activeLb,"CCLabelTTF") then
		local flag=playerVoApi:isRebelBuffActive()
		if flag==false then
			local activeStr,color=getlocal("serverwarteam_notActivated"),G_ColorWhite
			self.activeLb:setString(activeStr)
			self.activeLb:setColor(color)
		end
	end
end

function acYdczDialog:tick()
	if self.acTimeLb then
		local date=G_getDate(base.serverTime)
		local timeStr=getlocal("activity_ydcz_countdown",{getlocal("month_name"..date.month),GetTimeStr(G_getIntervalTimeEOM(),true)})
		self.acTimeLb:setString(timeStr)
	end
	local flag=acYdczVoApi:isCurrentMonth()
	if flag==false then --跨月清空数据
		acYdczVoApi:reset()
		self:refresh()
		self:createRechargeLb() --跨月的话刷新一下充值进度
	end
end

function acYdczDialog:dispose()
	self.cellNum=nil
	self.cellHeightTb=nil
	self.rewardList=nil
	self.unlockTb=nil
	self.tvWidth=nil
	self.tvHeight=nil
	self.cellHeight=nil
	self.tv=nil
	self.activeLb=nil
    spriteController:removePlist("public/avt_images.plist")
    spriteController:removeTexture("public/avt_images.png")
    spriteController:removePlist("public/avt_images1.plist")
    spriteController:removeTexture("public/avt_images1.png")
	spriteController:removePlist("public/youhuaUI4.plist")
   	spriteController:removeTexture("public/youhuaUI4.png")
	spriteController:removePlist("public/acydcz_images.plist")
   	spriteController:removeTexture("public/acydcz_images.png")
end