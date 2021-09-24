acJiejingkaicaiDialog=commonDialog:new()

function acJiejingkaicaiDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.waiSp={}
	self.neiSp={}
	self.allSp={}
	self.waiLine={}
	self.neiLine={}
	self.rewardLayer1=nil
	self.rewardLayer2=nil
	self.layerPos=nil
	self.xingSp=nil
	self.rewardList1=nil
	self.rewardList2=nil
	self.isToday=true
	self.iconSp=nil
	self.state=0
	self.layerVisible=1
	self.loster=false
	self.crystalMergeBottomBg=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/energyCrystal.plist")
    spriteController:addPlist("public/acJiejingkaicai.plist")
    spriteController:addTexture("public/acJiejingkaicai.png")
	return nc
end

function acJiejingkaicaiDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
end	

function acJiejingkaicaiDialog:doUserHandler()

	-- 数据
	self.rewardList1,self.rewardList2=acJiejingkaicaiVoApi:getRewardList()

	local function touchDialog()
		if self.state == 1 then
			PlayEffect(audioCfg.mouseClick)
			self.state = 2
		end
	end
	self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	self.touchDialogBg:setContentSize(rect)
	self.touchDialogBg:setOpacity(0)
	self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
	self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
	self.bgLayer:addChild(self.touchDialogBg,1)

	local bsSize=CCSizeMake(self.bgLayer:getContentSize().width-40, 160)
	if(G_isIphone5())then
		bsSize=CCSizeMake(self.bgLayer:getContentSize().width-40, 200)
	end
	local function nilFunc()
    end
    local backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
    backSprie1:ignoreAnchorPointForPosition(false);
    backSprie1:setAnchorPoint(ccp(0.5,1));
    backSprie1:setIsSallow(false)
    backSprie1:setTouchPriority(-(self.layerNum-1)*20-2)
	backSprie1:setContentSize(bsSize)
	backSprie1:setPosition(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-100)
    self.bgLayer:addChild(backSprie1)

    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
    acLabel:setColor(G_ColorYellowPro)
    backSprie1:addChild(acLabel,1)
    acLabel:setPosition(backSprie1:getContentSize().width/2, backSprie1:getContentSize().height-20)

    local acVo = acJiejingkaicaiVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,25)
    messageLabel:setPosition(ccp(backSprie1:getContentSize().width/2, backSprie1:getContentSize().height-50))
    backSprie1:addChild(messageLabel,3)

    local upLb = getlocal("activity_jiejingkaicai_des")
    local desSize = CCSizeMake(540, 80)
    if(G_isIphone5())then
    	desSize = CCSizeMake(540, 100)
    end
    local desTv, desLabel= G_LabelTableView(desSize,upLb,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(30,10))
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(130)
    backSprie1:addChild(desTv)

    local function touchInfo()
    	if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local strSize2 = 28
        if G_getCurChoseLanguage() ~="cn" or G_getCurChoseLanguage() ~="tw" or G_getCurChoseLanguage() ~="ja" or G_getCurChoseLanguage() ~="ko" then
        	if G_isIOS() ==false then
		    	strSize2 =24
		    end
		 end
        local td=smallDialog:new()
        local tabStr = {"\n",getlocal("activity_jiejingkaicai_tip6"),getlocal("activity_jiejingkaicai_tip5"),getlocal("activity_jiejingkaicai_tip4"),getlocal("activity_jiejingkaicai_tip3"),getlocal("activity_jiejingkaicai_tip2"), getlocal("activity_jiejingkaicai_tip1"),"\n"}
        local tabColor={nil,nil,nil,nil,nil}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize2,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
	local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,1,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,1))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(backSprie1:getContentSize().width-15, backSprie1:getContentSize().height-10))
	backSprie1:addChild(menuDesc,2)

	local descBgSp= CCSprite:create("public/superWeapon/weaponBg.jpg")
    descBgSp:setAnchorPoint(ccp(0.5,1))
    descBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,(self.bgLayer:getContentSize().height-100-backSprie1:getContentSize().height)-5))
    self.bgLayer:addChild(descBgSp)
 

    -- -- self.rewardLayer1
	local function tempFunc()
	end
	local mask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tempFunc)
	mask:setOpacity(0)
	local size=CCSizeMake(600,self.bgLayer:getContentSize().height-100-backSprie1:getContentSize().height-30)
	mask:setContentSize(size)
	mask:setAnchorPoint(ccp(0.5,1))
	mask:setPosition(ccp(self.bgLayer:getContentSize().width/2,(self.bgLayer:getContentSize().height-100-backSprie1:getContentSize().height)-5))
	self.bgLayer:addChild(mask,2)

	descBgSp:setScaleY((mask:getContentSize().height-100)/descBgSp:getContentSize().height)
	if (G_isIphone5()) then
		descBgSp:setScaleY((mask:getContentSize().height-150)/descBgSp:getContentSize().height)
	end
	
	self.rewardLayer1=mask
	self.layerPos=ccp(self.bgLayer:getContentSize().width/2,(self.bgLayer:getContentSize().height-100-backSprie1:getContentSize().height)-5)

	-- 五角星背景
	local fragmentBg=CCSprite:create("public/superWeapon/fragmentBg1.png")
	fragmentBg:setPosition(ccp(mask:getContentSize().width/2, mask:getContentSize().height/2+65))
	if(G_isIphone5())then
		fragmentBg:setPosition(ccp(mask:getContentSize().width/2, mask:getContentSize().height/2+85))
	end
	
	fragmentBg:setScale(1.5)
	mask:addChild(fragmentBg)
	self.posX=mask:getContentSize().width/2
	self.posY=mask:getContentSize().height/2+85

	local lineBatchNode=CCSpriteBatchNode:create("public/acJiejingkaicai.png")
	fragmentBg:addChild(lineBatchNode)
	for i=1,5 do
		local sp = CCSprite:createWithSpriteFrameName("blue_line.png")
		lineBatchNode:addChild(sp)
		if i==1 then
			sp:setPosition(fragmentBg:getContentSize().width/4+6, fragmentBg:getContentSize().height/2+103)
			sp:setRotation(-36)
		elseif i==2 then
			sp:setPosition(fragmentBg:getContentSize().width/4*3-6, fragmentBg:getContentSize().height/2+103)
			sp:setRotation(36)
		elseif i==3 then
			sp:setPosition(fragmentBg:getContentSize().width/4*3+49, fragmentBg:getContentSize().height/2-63)
			sp:setRotation(-72)
		elseif i==4 then
			sp:setPosition(fragmentBg:getContentSize().width/2, 11)
			-- sp:setRotation(36)
		elseif i==5 then
			sp:setPosition(fragmentBg:getContentSize().width/4-49, fragmentBg:getContentSize().height/2-63)
			sp:setRotation(72)
		end
		sp:setScaleX(4.3)
		sp:setScaleY(3)
		-- sp:setVisible(false)
		self.waiLine[i]=sp
	end

	for i=1,10 do
		local sp = CCSprite:createWithSpriteFrameName("blue_line.png")
		lineBatchNode:addChild(sp)
		if i==1 then
			sp:setPosition(fragmentBg:getContentSize().width/4+66, fragmentBg:getContentSize().height/2+110)
			sp:setRotation(-64)
		elseif i==2 then
			sp:setPosition(fragmentBg:getContentSize().width/4*3-66, fragmentBg:getContentSize().height/2+110)
			sp:setRotation(63)
		elseif i==3 then
			sp:setPosition(fragmentBg:getContentSize().width/4*3+18, fragmentBg:getContentSize().height/2+48)
			sp:setRotation(8)
		elseif i==4 then
			sp:setPosition(fragmentBg:getContentSize().width/4-18, fragmentBg:getContentSize().height/2+48)
			sp:setRotation(-8)
		elseif i==5 then
			sp:setPosition(fragmentBg:getContentSize().width/4*3+35, fragmentBg:getContentSize().height/2-1)
			sp:setRotation(-43)
		elseif i==6 then
			sp:setPosition(fragmentBg:getContentSize().width/4*1-35, fragmentBg:getContentSize().height/2-1)
			sp:setRotation(43)
		elseif i==7 then
			sp:setPosition(fragmentBg:getContentSize().width/4*3, fragmentBg:getContentSize().height/2-103)
			sp:setRotation(80)
		elseif i==8 then
			sp:setPosition(fragmentBg:getContentSize().width/4*1, fragmentBg:getContentSize().height/2-103)
			sp:setRotation(-80)
		elseif i==9 then
			sp:setPosition(fragmentBg:getContentSize().width/2+52, 47)
			sp:setRotation(28)
		elseif i==10 then
			sp:setPosition(fragmentBg:getContentSize().width/2-52, 47)
			sp:setRotation(-28)
		end
		sp:setScaleX(2.3)
		sp:setScaleY(2)
		sp:setVisible(false)
		self.neiLine[i]=sp
	end

	-- 卡片
	for i=1,11 do
		local picStr = "PurpleBoxRandom.png"
		if i>6 then
			picStr = "BlueBoxRandom.png"
		elseif i==6 then
			picStr = "PurpleBoxRandom.png"
		else
			picStr = "GreenBox.png"
		end 
		local sp = CCSprite:createWithSpriteFrameName(picStr)
		fragmentBg:addChild(sp)
		sp:setScale(60/sp:getContentSize().width)
		if i==1 then
			sp:setPosition(fragmentBg:getContentSize().width/2, fragmentBg:getContentSize().height-30)
		elseif i==2 then
			sp:setPosition(fragmentBg:getContentSize().width-30, fragmentBg:getContentSize().height/2+40)
		elseif i==3 then
			sp:setPosition(fragmentBg:getContentSize().width/2+100, 15)
		elseif i==4 then
			sp:setPosition(fragmentBg:getContentSize().width/2-100, 15)
		elseif i==5 then
			sp:setPosition(30, fragmentBg:getContentSize().height/2+40)
		elseif i==7 then
			sp:setPosition(fragmentBg:getContentSize().width/2-50, fragmentBg:getContentSize().height/2+60)
		elseif i==8 then
			sp:setPosition(fragmentBg:getContentSize().width/2+50, fragmentBg:getContentSize().height/2+60)
		elseif i==9 then
			sp:setPosition(fragmentBg:getContentSize().width/2+90, fragmentBg:getContentSize().height/2-60)
		elseif i==10 then
			sp:setPosition(fragmentBg:getContentSize().width/2, 75)
		elseif i==11 then
			sp:setPosition(fragmentBg:getContentSize().width/2-90, fragmentBg:getContentSize().height/2-60)
		elseif i==6 then
			sp:setPosition(fragmentBg:getContentSize().width/2, fragmentBg:getContentSize().height/2-15)
		end
		if i<6 then
			self.waiSp[i]=sp
		elseif i==6 then
			self.xingSp=sp
		else
			self.neiSp[i-6]=sp
		end
		self.allSp[i]=sp

	end

	local function nilFunc()
	end
	local kuangSp = LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),nilFunc)
	kuangSp:setContentSize(CCSizeMake(80,80))
	fragmentBg:addChild(kuangSp,1)
	kuangSp:setVisible(false)
	kuangSp:setScale(70/80)
	self.kuangSp=kuangSp

	local function tmpFunc()
    end
	self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
	self.maskSp:setOpacity(255)
	local size=CCSizeMake(600,self.bgLayer:getContentSize().height-100-backSprie1:getContentSize().height-30+10)
	self.maskSp:setContentSize(size)
	self.maskSp:setAnchorPoint(ccp(0.5,1))
	self.maskSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,(self.bgLayer:getContentSize().height-100-backSprie1:getContentSize().height)-5))
	self.maskSp:setIsSallow(true)
	self.maskSp:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(self.maskSp,2)
	self.maskSp:setVisible(false)
	self.maskSp:setPosition(ccp(999999,999999))

	local function touchConfirm()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		self.maskSp:setPosition(ccp(999999,999999))
		self.maskSp:setVisible(false)
		self.kuangSp:setVisible(false)
		self.costDescLabel:setVisible(false)
		self.confirmBtn:setVisible(false)

		-- self.item
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_jiejingkaicai_reward",{self.item.name,self.item.num}),25)

		for k,v in pairs(self.addSpTb) do
			v:removeFromParentAndCleanup(true)
		end
	end
	local confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",touchConfirm,4,getlocal("confirm"),25)
	confirmBtn:setAnchorPoint(ccp(0.5,0.5))
	local boxSpMenu3=CCMenu:createWithItem(confirmBtn)
	boxSpMenu3:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-200))
	boxSpMenu3:setTouchPriority(-(self.layerNum-1)*20-6)
	self.maskSp:addChild(boxSpMenu3,2)
	confirmBtn:setVisible(false)
	self.confirmBtn=confirmBtn

	local desTR=""
	self.costDescLabel=GetTTFLabelWrap(desTR,25,CCSizeMake(self.maskSp:getContentSize().width-110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	self.costDescLabel:setAnchorPoint(ccp(0.5,0.5))
	self.costDescLabel:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-100))
	self.maskSp:addChild(self.costDescLabel,2)
	self.costDescLabel:setVisible(false)

	local fragmentBg1=CCSprite:create("public/superWeapon/fragmentBg1.png")
	fragmentBg1:setPosition(ccp(mask:getContentSize().width/2, mask:getContentSize().height/2+85))
	fragmentBg1:setScale(1.5)
	self.maskSp:addChild(fragmentBg1)
	fragmentBg1:setOpacity(0)

	local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
	lightSp:setAnchorPoint(ccp(0.5,0.5))
	fragmentBg1:addChild(lightSp,1)
	-- lightSp:setVisible(false)
	self.lightSp=lightSp

	-- 按钮
	local function touchBtn(tag)
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)

		local flag = tag
		if acJiejingkaicaiVoApi:isToday()==false then
			flag=0
		end
		local cost = 0
		if flag == 0 then
		elseif flag==1 then
			cost=acJiejingkaicaiVoApi:getCost()
		else
			cost=acJiejingkaicaiVoApi:getMulCost()
		end
		if playerVoApi:getGems()<cost then
			local function closeSelf()
				activityAndNoteDialog:closeAllDialog()
			end
            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost,closeSelf)
            return
        end

		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
			if ret==true then
				playerVoApi:setValue("gems",playerVoApi:getGems()-cost)
				self:setLableColor()
				acJiejingkaicaiVoApi:updataData(sData.data.jiejingkaicai)
				self.tag=tag

				if(sData.data.weapon)then
                    superWeaponVoApi:formatData(sData.data.weapon)
                end

				if sData and sData.data and sData.data.reward then
					local item = FormatItem(sData.data.reward)
					self.item=item[1]
					self:startPalyAnimation(1,tag,item[1])
				end
				if sData and sData.data and sData.data.jiejingkaicai and sData.data.jiejingkaicai.r then
					self:setLayerPosAndVisible(2)
					self:addDajiangDes()
				end
				
				if flag==0 then
					self:refresh()
					self.isToday=true
				end
			end
		end
		socketHelper:acJinjingkaicaiChoujiang(flag,callback)
		
	end


	local btnH=0
	if(G_isIphone5())then
		btnH=40
	end
	local strSize2 = 18
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
     	strSize2= 25
	end
	local oneItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchBtn,1,getlocal("activity_jiejingkaicai_btn1"),strSize2)
	oneItem:setAnchorPoint(ccp(0.5,0))
	local oneBtn=CCMenu:createWithItem(oneItem);
	oneBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	oneBtn:setPosition(ccp(G_VisibleSizeWidth/2-150,btnH))
	mask:addChild(oneBtn)

	local tenItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchBtn,2,getlocal("activity_jiejingkaicai_btn2"),strSize2)
	tenItem:setAnchorPoint(ccp(0.5,0))
	local tenBtn=CCMenu:createWithItem(tenItem);
	tenBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	tenBtn:setPosition(ccp(G_VisibleSizeWidth/2+150,btnH))
	mask:addChild(tenBtn)
	self.tenItem=tenItem


	local oneLb = GetTTFLabel(acJiejingkaicaiVoApi:getCost(),25)
	oneItem:addChild(oneLb)
	oneLb:setPosition(oneItem:getContentSize().width/2-10, oneItem:getContentSize().height+15)
	self.oneLb=oneLb

	local oneSp = CCSprite:createWithSpriteFrameName("IconGold.png")
	oneSp:setAnchorPoint(ccp(0,0.5))
	oneLb:addChild(oneSp)
	oneSp:setPosition(oneLb:getContentSize().width, oneLb:getContentSize().height/2)

	local tenLb = GetTTFLabel(acJiejingkaicaiVoApi:getMulCost(),25)
	tenItem:addChild(tenLb)
	tenLb:setPosition(tenItem:getContentSize().width/2-10, tenItem:getContentSize().height+15)
	self.tenLb=tenLb

	local tenSp = CCSprite:createWithSpriteFrameName("IconGold.png")
	tenSp:setAnchorPoint(ccp(0,0.5))
	tenLb:addChild(tenSp)
	tenSp:setPosition(tenLb:getContentSize().width, tenLb:getContentSize().height/2)

	local mianFeiLb = GetTTFLabel(getlocal("daily_lotto_tip_2"),25)
	oneItem:addChild(mianFeiLb)
	mianFeiLb:setPosition(oneItem:getContentSize().width/2, oneItem:getContentSize().height+15)
	self.mianFeiLb=mianFeiLb

	self:setLableColor()


	self:refresh()


	-- self.rewardLayer2
	local function tempFunc()
	end
	local mask2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tempFunc)
	mask2:setOpacity(0)
	local size=CCSizeMake(600,self.bgLayer:getContentSize().height-100-backSprie1:getContentSize().height-30)
	mask2:setContentSize(size)
	mask2:setAnchorPoint(ccp(0.5,1))
	mask2:setPosition(ccp(self.bgLayer:getContentSize().width/2,(self.bgLayer:getContentSize().height-100-backSprie1:getContentSize().height)-5))
	self.bgLayer:addChild(mask2,2)
	-- descBgSp:setScaleY((mask2:getContentSize().height-150)/descBgSp:getContentSize().height)
	self.rewardLayer2=mask2

	 -- 初始化融合背景
    self.crystalMergeBg=CCSprite:create()
    self.crystalMergeBg:setContentSize(CCSizeMake(334,384))
    self.crystalMergeBg:setPosition(ccp(mask2:getContentSize().width/2,mask2:getContentSize().height/2+80))
    mask2:addChild(self.crystalMergeBg)

    self.selectedCrystalIconPos1=ccp(150,280)
    self.selectedCrystalIconPos2=ccp(180,180)
    self.centerPos=ccp(165,220)
    self.crystalMergeBg1 = CCSprite:createWithSpriteFrameName("crystalMergeBg1.png")
    self.crystalMergeFireBg = CCSprite:createWithSpriteFrameName("crystalMergeFire1.png")
    local crystalMergeBottomBg = CCSprite:createWithSpriteFrameName("crystalMergeBottomBg.png")
    self.crystalMergeBg1:setScale(2)
    self.crystalMergeFireBg:setScale(2)
    
    self.crystalMergeBg1:setAnchorPoint(ccp(0.5,0))
    self.crystalMergeBg1:setPosition(ccp(self.crystalMergeBg:getContentSize().width/2,crystalMergeBottomBg:getContentSize().height-200))

    self.crystalMergeFireBg:setAnchorPoint(ccp(0.5,0))
    self.crystalMergeFireBg:setPosition(ccp(self.crystalMergeBg:getContentSize().width/2,0))
    
    crystalMergeBottomBg:setAnchorPoint(ccp(0.5,0))
    crystalMergeBottomBg:setPosition(ccp(self.crystalMergeBg:getContentSize().width/2,0))
    
    self.crystalMergeBg:addChild(self.crystalMergeBg1,1)
    self.crystalMergeBg:addChild(self.crystalMergeFireBg,3)
    self.crystalMergeBg:addChild(crystalMergeBottomBg,3)
    self.crystalMergeBottomBg=crystalMergeBottomBg

    -- 描述lable
    local upgradeDesLb=GetTTFLabelWrap(getlocal("activity_jiejingkaicai_upgradeDes"),25,CCSizeMake(mask2:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	upgradeDesLb:setAnchorPoint(ccp(0,0.5))
	upgradeDesLb:setPosition(ccp(30,self.maskSp:getContentSize().height-40))
	mask2:addChild(upgradeDesLb,2)
	upgradeDesLb:setColor(G_ColorYellowPro)

	local btnH=20
	if(G_isIphone5())then
		btnH=40
	end
	local function touchBtn2(tag)
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)

		if tag==2 then
			if self.loster==true then
				self.loster=false
				self:setLayerPosAndVisible(1)
				return
			end
			
			local function callback(fn,data)
				local ret,sData = base:checkServerData(data)
				if ret==true then
					self.loster=false
					if(sData.data.weapon)then
	                    superWeaponVoApi:formatData(sData.data.weapon)
	                end
	                if(sData.data.reward)then
						local item = FormatItem(sData.data.reward)
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_jiejingkaicai_reward",{item[1].name,item[1].num}),25)
						local level = superWeaponCfg.crystalCfg[item[1].key].lvl

						if level>=4 then
							local message={key="activity_diancitanke_reward",param={playerVoApi:getPlayerName(),getlocal("activity_jiejingkaicai_title"),item[1].name,item[1].num}}
							chatVoApi:sendSystemMessage(message)
						end
						
	                end
	                acJiejingkaicaiVoApi:setDajiang()

	               
					self:setLayerPosAndVisible(1)
				end
			end

			if self.upgradeItem:isVisible()==false then
				socketHelper:acJinjingkaicaiLingjiang(callback)
			else
				local function lingjiang()
					socketHelper:acJinjingkaicaiLingjiang(callback)
				end
				acJiejingkaicaiVoApi:showSmallDialogL(self.layerNum+1,lingjiang)
			end
			
			
		else
			local function callback(fn,data)
				local ret,sData = base:checkServerData(data)
				if ret==true then
					acJiejingkaicaiVoApi:updataData(sData.data.jiejingkaicai)
					if(sData.data.weapon)then
	                    superWeaponVoApi:formatData(sData.data.weapon)
	                end
					self.flag=sData.data.flag
					if sData and sData.data and sData.data.flag then
						local flag = sData.data.flag
						if flag==0 then
							self.loster=true
							
						else
							self.loster=false
						end
						self:startPalyAnimation(2,flag)
					end
				end
			end
			socketHelper:acJinjingkaicaiUpgrade(callback)
		end
	end
	local upgradeItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchBtn2,1,getlocal("upgradeBuild"),25)
	upgradeItem:setAnchorPoint(ccp(0.5,0))
	local upgradeBtn=CCMenu:createWithItem(upgradeItem);
	upgradeBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	upgradeBtn:setPosition(ccp(G_VisibleSizeWidth/2-150,btnH))
	mask2:addChild(upgradeBtn)
	self.upgradeItem=upgradeItem

	local backItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchBtn2,2,getlocal("coverFleetBack"),25)
	backItem:setAnchorPoint(ccp(0.5,0))
	local backBtn=CCMenu:createWithItem(backItem);
	backBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	backBtn:setPosition(ccp(G_VisibleSizeWidth/2+150,btnH))
	mask2:addChild(backBtn)
	self.backItem=backBtn

    if acJiejingkaicaiVoApi:getDajiang() then
    	self:setLayerPosAndVisible(2)
    	self:addDajiangDes()
	else
		self:setLayerPosAndVisible(1)
    end

end

function acJiejingkaicaiDialog:addDajiangDes(isLoser)
	if isLoser then
		self.nameLb1:setVisible(false)
		self.nameLb2:setVisible(false)
		self.jinengLb1:setVisible(false)
		self.jinengLb2:setVisible(false)
		self.upgradeItem:setVisible(false)
		self.upgradeItem:setEnabled(false)
		self.arrowSp2:setVisible(false)
		self.arrowSp1:setVisible(false)
		self.backItem:setPositionX(G_VisibleSizeWidth/2)
		return
	end
	local item =  acJiejingkaicaiVoApi:getDajiang()
	local function callback()
		if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil)
	end
	if self.iconSp then
		self.iconSp:removeFromParentAndCleanup(true)
		self.iconSp=nil
	end
	local iconSp = LuaCCSprite:createWithSpriteFrameName(item.pic,callback)
	self.crystalMergeBottomBg:addChild(iconSp,10)
	iconSp:setTouchPriority(-(self.layerNum-1)*20-4)
	iconSp:setPosition(self.crystalMergeBottomBg:getContentSize().width/2, self.crystalMergeBottomBg:getContentSize().height/2+135)
	self.iconSp=iconSp	

	local level = superWeaponCfg.crystalCfg[item.key].lvl

    local name1,name2,des1,des2 = self:getNameAndJineng(item)

    if self.nameLb1==nil then
    	self.nameLb1 = GetTTFLabelWrap(name1,25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.rewardLayer2:addChild(self.nameLb1)
	else
		self.nameLb1:setString(name1)
    end
	self.nameLb1:setPosition(self.rewardLayer2:getContentSize().width/4,self.rewardLayer2:getContentSize().height/2-self.crystalMergeBottomBg:getContentSize().height/2-30 )

	if self.nameLb2==nil then
		self.nameLb2 = GetTTFLabelWrap(name2,25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.rewardLayer2:addChild(self.nameLb2)
	else
		self.nameLb2:setString(name2)
	end
	self.nameLb2:setPosition(self.rewardLayer2:getContentSize().width/4*3,self.rewardLayer2:getContentSize().height/2-self.crystalMergeBottomBg:getContentSize().height/2-30 )
	self.nameLb2:setColor(G_ColorYellowPro)

	if self.arrowSp1==nil then
		self.arrowSp1 = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
		self.rewardLayer2:addChild(self.arrowSp1)
		self.arrowSp1:setPosition(self.rewardLayer2:getContentSize().width/2,self.rewardLayer2:getContentSize().height/2-self.crystalMergeBottomBg:getContentSize().height/2-30)
	end
	

	if self.jinengLb1==nil then
		self.jinengLb1 = GetTTFLabelWrap(des1,25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.rewardLayer2:addChild(self.jinengLb1)
	else
		self.jinengLb1:setString(des1)
	end
	self.jinengLb1:setPosition(self.rewardLayer2:getContentSize().width/4,self.rewardLayer2:getContentSize().height/2-self.crystalMergeBottomBg:getContentSize().height/2-80 )

	if self.jinengLb2==nil then
		self.jinengLb2 = GetTTFLabelWrap(des2,25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.rewardLayer2:addChild(self.jinengLb2)
	else
		self.jinengLb2:setString(des2)
	end
	self.jinengLb2:setPosition(self.rewardLayer2:getContentSize().width/4*3,self.rewardLayer2:getContentSize().height/2-self.crystalMergeBottomBg:getContentSize().height/2-80 )
	self.jinengLb2:setColor(G_ColorYellowPro)

	if self.arrowSp2==nil then
		self.arrowSp2 = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
		self.rewardLayer2:addChild(self.arrowSp2)
		self.arrowSp2:setPosition(self.rewardLayer2:getContentSize().width/2,self.rewardLayer2:getContentSize().height/2-self.crystalMergeBottomBg:getContentSize().height/2-74)
	end
	

	self.nameLb1:setVisible(true)
	self.nameLb2:setVisible(true)
	self.jinengLb1:setVisible(true)
	self.jinengLb2:setVisible(true)
	self.upgradeItem:setVisible(true)
	self.upgradeItem:setEnabled(true)
	self.arrowSp2:setVisible(true)
	self.arrowSp1:setVisible(true)

	if level>=5 then
		self.arrowSp2:setVisible(false)
		self.arrowSp1:setVisible(false)


		self.jinengLb1:setPosition(self.rewardLayer2:getContentSize().width/4*3,self.rewardLayer2:getContentSize().height/2-self.crystalMergeBottomBg:getContentSize().height/2-37)
		self.nameLb2:setVisible(false)
		self.jinengLb2:setVisible(false)

		if self.bestLv==nil then
			self.bestLv = GetTTFLabelWrap(getlocal("activity_jiejingkaicai_bestLv"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			self.rewardLayer2:addChild(self.bestLv)
		else
			self.bestLv:setString(getlocal("activity_jiejingkaicai_bestLv"))
		end
		self.bestLv:setVisible(true)
		
		self.bestLv:setPosition(self.rewardLayer2:getContentSize().width/2,self.rewardLayer2:getContentSize().height/2-self.crystalMergeBottomBg:getContentSize().height/2-80 )
		self.bestLv:setColor(G_ColorYellowPro)
		self.upgradeItem:setVisible(false)
		self.upgradeItem:setEnabled(false)
		self.backItem:setPositionX(G_VisibleSizeWidth/2)
	else
		if self.bestLv then
			self.bestLv:setVisible(false)
		end
		self.backItem:setPositionX(G_VisibleSizeWidth/2+150)
	end
end

function acJiejingkaicaiDialog:getNameAndJineng(item)
	local name1=""
	local name2=""
	local des1=""
	local des2=""

	name1=item.name

	local att = superWeaponCfg.crystalCfg[item.key].att
    local i = 1
    local msg=""
    for k,v in pairs(att) do
        msg = getlocal(buffEffectCfg[k].name)
        if tonumber(k)>200 then
            msg=msg..""..v
        else
            msg=msg..""..(tonumber(v)*100).."%"
        end
        msg=msg.."\n"
        i=i+1
    end
    local des1=msg

    local keyNum =  tonumber(key) or tonumber(RemoveFirstChar(item.key))
    local UpKey = "c" .. keyNum+1
    local name2 = getItem(UpKey,"w")

    local i = 1
    local msg=""
    local att = superWeaponCfg.crystalCfg[UpKey].att
    for k,v in pairs(att) do
        msg = getlocal(buffEffectCfg[k].name)
        if tonumber(k)>200 then
            msg=msg..""..v
        else
            msg=msg..""..(tonumber(v)*100).."%"
        end
        msg=msg.."\n"
        i=i+1
    end
    local des2=msg

	return name1,name2,des1,des2
end


function acJiejingkaicaiDialog:setLableColor()
	local playerCost = playerVoApi:getGems()
	local cost1 = acJiejingkaicaiVoApi:getCost()
	local cost2 = acJiejingkaicaiVoApi:getMulCost()

	if playerCost>=cost2 then
		self.oneLb:setColor(G_ColorWhite)
		self.tenLb:setColor(G_ColorWhite)
	elseif playerCost>=cost1 then
		self.oneLb:setColor(G_ColorWhite)
		self.tenLb:setColor(G_ColorRed)
	else
		self.oneLb:setColor(G_ColorRed)
		self.tenLb:setColor(G_ColorRed)
	end

	
end

function acJiejingkaicaiDialog:refresh()
	if acJiejingkaicaiVoApi:isToday()==false then
		self.mianFeiLb:setVisible(true)
		self.oneLb:setVisible(false)
		self.tenItem:setEnabled(false)
	else
		self.mianFeiLb:setVisible(false)
		self.oneLb:setVisible(true)
		self.tenItem:setEnabled(true)
	end
end

function acJiejingkaicaiDialog:setLayerPosAndVisible(flag)
	if flag==1 then
		self.rewardLayer1:setVisible(true)
		self.rewardLayer1:setPosition(self.layerPos)
		self.layerVisible=1

		self.rewardLayer2:setVisible(false)
		self.rewardLayer2:setPosition(999999, 999999)
	else
		self.rewardLayer1:setVisible(false)
		self.rewardLayer1:setPosition(999999, 999999)

		self.rewardLayer2:setVisible(true)
		self.rewardLayer2:setPosition(self.layerPos)
		self.layerVisible=2
	end
end

function acJiejingkaicaiDialog:playAction()
    if self.crystalMergeBg1 and self.crystalMergeFireBg then
        self.isPlaying=true
        local pzArr1=CCArray:create()
        for kk=1,10 do
            local nameStr1="crystalMergeBg"..kk..".png"
            local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr1)
            -- frame1:setScale(2)
            pzArr1:addObject(frame1)
        end
        local animation1=CCAnimation:createWithSpriteFrames(pzArr1)
        animation1:setDelayPerUnit(0.07)
        local animate1=CCAnimate:create(animation1)
        local repeatForever1=CCRepeatForever:create(animate1)
        self.crystalMergeBg1:runAction(repeatForever1)

        local pzArr2=CCArray:create()
        for kk=1,10 do
            local nameStr2="crystalMergeFire"..kk..".png"
            local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr2)
            -- frame2:setScale(2)
            pzArr2:addObject(frame2)
        end
        local animation2=CCAnimation:createWithSpriteFrames(pzArr2)
        animation2:setDelayPerUnit(0.07)
        local animate2=CCAnimate:create(animation2)
        local repeatForever2=CCRepeatForever:create(animate2)
        self.crystalMergeFireBg:runAction(repeatForever2)
    end

end

-- 外圈1，内圈2，中心3
function acJiejingkaicaiDialog:getQuan(item)
	for k,v in pairs(self.rewardList1) do
		if v.key==item.key and v.num==item.num then
			return 1,k
		end
	end
	for k,v in pairs(self.rewardList2) do
		if v.key==item.key and v.num==item.num then
			return 2,k
		end
	end
end

function acJiejingkaicaiDialog:getRandNumTb(tag)
	local jishu=5
	if tag==1 then
		jishu=5
	else
		jishu=11
	end
	local randNumTb={}
	local count=1
	while true do
		if count>30 then
			break
		end
		local num = math.random(jishu)
		if i==1 then
			randNumTb[count]=num
			count=count+1
		else
			if randNumTb[count-1]~=num then
				randNumTb[count]=num
				count=count+1
			end
		end
	end

	while true do
		local randNum = math.random(5)
		if randNumTb[count-1]~=randNum then
			randNumTb[count]=randNum
			break
		end
	end

	return randNumTb
end

--flag 1 layer1的动画   2 layer2的动画
function acJiejingkaicaiDialog:startPalyAnimation(flag,tag,item)
	 self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
	 self.state=1
	 if flag==1 then
	 	self:startAction1(tag,item)
	 else
	 	self:startAction2(tag)
	 end
	 
end

function acJiejingkaicaiDialog:startAction1(tag,item)

	local randNumTb=self:getRandNumTb(tag)
	self.randNumTb=randNumTb

	local acArr=CCArray:create()
	for i=1,#randNumTb-1 do
		if i==1 then
			self.kuangSp:setPosition(self.allSp[randNumTb[i]]:getPosition())
			self.kuangSp:setVisible(true)
		else
			local delay=CCDelayTime:create(0.2)
			local function callback()
				self.kuangSp:setPosition(self.allSp[randNumTb[i]]:getPosition())
			end
			local callFunc=CCCallFuncN:create(callback)
			acArr:addObject(delay)
			acArr:addObject(callFunc)
		end
	end

	local delay=CCDelayTime:create(0.1)
	local function callbackAc()
	 	self:endAction1(tag,item)
	end
	local callFunc=CCCallFuncN:create(callbackAc)

	acArr:addObject(delay)
	acArr:addObject(callFunc)

	local seq=CCSequence:create(acArr)
    self.kuangSp:runAction(seq)

    self:runLineAction(tag)
end

function acJiejingkaicaiDialog:endAction1(tag,item)
	self.touchDialogBg:setIsSallow(false)
	self.state = 0
	self:stopLineAction(tag)
	self.kuangSp:stopAllActions()
	
	local randNumTb=self.randNumTb

	local quan,rNum = self:getQuan(item)

	-- 翻牌
	self:addFanpai(tag,quan,rNum)

	if quan==1 then
		self.kuangSp:setPosition(self.waiSp[randNumTb[#randNumTb]]:getPosition())
		self.lightSp:setPosition(self.waiSp[randNumTb[#randNumTb]]:getPosition())
	else
		self.kuangSp:setPosition(self.neiSp[randNumTb[#randNumTb]]:getPosition())
		self.lightSp:setPosition(self.neiSp[randNumTb[#randNumTb]]:getPosition())
	end

	self.maskSp:setPosition(self.layerPos.x,self.layerPos.y+5)
	self.maskSp:setVisible(true)

	self.lightSp:setVisible(true)

	if self.rewardSp then
		self.rewardSp:removeFromParentAndCleanup(true)
	end
	local function nilFunc()
	end
	local rewardSp = GetBgIcon(item.pic,nilFunc,nil,80,80)
	self.lightSp:addChild(rewardSp)
	rewardSp:setPosition(self.lightSp:getContentSize().width/2,self.lightSp:getContentSize().height/2)
	self.rewardSp=rewardSp

	local numLb=GetTTFLabel("X" .. tostring(item.num),17)
	numLb:setPosition(ccp(rewardSp:getContentSize().width-5,5))
	numLb:setAnchorPoint(ccp(1,0));
	rewardSp:addChild(numLb)


	-- 移动动画
	local function playEndCallback()
		local desTR=item.name .. "\n"
		if item.eType=="c" and item.type=="w" then
			desTR=desTR .. item.desc
		else
			desTR=desTR .. getlocal(item.desc)
		end
		
		self.costDescLabel:setString(desTR)
		self.costDescLabel:setVisible(true)
		self.confirmBtn:setVisible(true)
	end
	local delay=CCDelayTime:create(0.5)
	local posX,posY=self.xingSp:getPosition()
	local mvTo0=CCMoveTo:create(0.3,ccp(posX,posY))
	
	local ms=2
    local scaleTo=CCScaleTo:create(0.1,ms)
    ms=1
	local scaleTo1=CCScaleTo:create(0.2,ms)
	local callFunc=CCCallFuncN:create(playEndCallback)
	
    local acArr=CCArray:create()
    acArr:addObject(delay)
	acArr:addObject(mvTo0)
    acArr:addObject(scaleTo)
	acArr:addObject(scaleTo1)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.lightSp:runAction(seq)
end

-- 翻牌
function acJiejingkaicaiDialog:addFanpai(tag,quan,rNum)
	local rewardNum = self.randNumTb[#self.randNumTb]

	self.addSpTb={}
	if tag==1 then
		local num1=SizeOfTable(self.rewardList1)
		local numTb1 = {0,0,0,0,0}

		numTb1[rewardNum]=rNum

		for i=1,5 do
			if numTb1[i]==0 then
				while true do
					local lingshiNum = math.random(num1)
					for j=1,5 do
						if numTb1[j]==lingshiNum then
							break
						end
						if numTb1[j]~=lingshiNum and j==5  then
							numTb1[i]=lingshiNum
						end
					end
					if lingshiNum==numTb1[i] then
						break
					end
				end
			end
		end

		local count=1
		for k,v in pairs(numTb1) do
			local iconSp = GetBgIcon(self.rewardList1[v].pic,nilFunc,nil,80,100)
			self.waiSp[k]:addChild(iconSp)
			iconSp:setPosition(self.waiSp[k]:getContentSize().width/2, self.waiSp[k]:getContentSize().height/2)
			self.addSpTb[count]=iconSp
			count=count+1

			-- 等级
			if self.rewardList1[v].key~="p1" then
				local level = superWeaponCfg.crystalCfg[self.rewardList1[v].key].lvl
	            local levelLb=GetTTFLabel(tostring(getlocal("fightLevel",{level})),17)
	            levelLb:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height-5))
	            levelLb:setAnchorPoint(ccp(0.5,1));
	            iconSp:addChild(levelLb)
			end
			
            -- 数量
            local numLb=GetTTFLabel("X" .. tostring(self.rewardList1[v].num),17)
            numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
            numLb:setAnchorPoint(ccp(1,0));
            iconSp:addChild(numLb)
		end
		
	else
		local num1=SizeOfTable(self.rewardList1)
		local num2=SizeOfTable(self.rewardList2)

		local numTb1 = {0,0,0,0,0}
		local numTb2 = {0,0,0,0,0,0}
		if quan==2 then
			numTb2[rewardNum]=rNum
		else
			numTb1[rewardNum]=rNum
		end

		for i=1,5 do
			if numTb1[i]==0 then
				while true do
					local lingshiNum = math.random(num1)
					for j=1,5 do
						if numTb1[j]==lingshiNum then
							break
						end
						if numTb1[j]~=lingshiNum and j==5  then
							numTb1[i]=lingshiNum
						end
					end
					if lingshiNum==numTb1[i] then
						break
					end
				end
			end
		end

		for i=1,6 do
			if numTb2[i]==0 then
				while true do
					local lingshiNum = math.random(num2)
					for j=1,6 do
						if numTb2[j]==lingshiNum then
							break
						end
						if numTb2[j]~=lingshiNum and j==5  then
							numTb2[i]=lingshiNum
						end
					end
					if lingshiNum==numTb2[i] then
						break
					end
				end
			end
		end

		local count=1
		for k,v in pairs(numTb1) do

			local iconSp = GetBgIcon(self.rewardList1[v].pic,nilFunc,nil,80,100)
			self.waiSp[k]:addChild(iconSp)
			iconSp:setPosition(self.waiSp[k]:getContentSize().width/2, self.waiSp[k]:getContentSize().height/2)
			self.addSpTb[count]=iconSp
			count=count+1

			 -- 等级
           if self.rewardList1[v].key~="p1" then
				local level = superWeaponCfg.crystalCfg[self.rewardList1[v].key].lvl
	            local levelLb=GetTTFLabel(tostring(getlocal("fightLevel",{level})),17)
	            levelLb:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height-5))
	            levelLb:setAnchorPoint(ccp(0.5,1));
	            iconSp:addChild(levelLb)
			end
            -- 数量
            local numLb=GetTTFLabel("X" .. tostring(self.rewardList1[v].num),17)
            numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
            numLb:setAnchorPoint(ccp(1,0));
            iconSp:addChild(numLb)
		end

		for k,v in pairs(numTb2) do
			if k<6 then
				local iconSp = GetBgIcon(self.rewardList2[v].pic,nilFunc,nil,80,100)
				self.neiSp[k]:addChild(iconSp)
				iconSp:setPosition(self.neiSp[k]:getContentSize().width/2, self.neiSp[k]:getContentSize().height/2)
				self.addSpTb[count]=iconSp

				count=count+1

				 -- 等级
               if self.rewardList2[v].key~="p1" then
					local level = superWeaponCfg.crystalCfg[self.rewardList2[v].key].lvl
		            local levelLb=GetTTFLabel(tostring(getlocal("fightLevel",{level})),17)
		            levelLb:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height-5))
		            levelLb:setAnchorPoint(ccp(0.5,1));
		            iconSp:addChild(levelLb)
				end
                -- 数量
                local numLb=GetTTFLabel("X" .. tostring(self.rewardList2[v].num),17)
                numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
                numLb:setAnchorPoint(ccp(1,0));
                iconSp:addChild(numLb)
			else
				local iconSp = GetBgIcon(self.rewardList2[v].pic,nilFunc,nil,80,100)
				self.xingSp:addChild(iconSp)
				iconSp:setPosition(self.xingSp:getContentSize().width/2, self.xingSp:getContentSize().height/2)
				self.addSpTb[count]=iconSp
				count=count+1

				 -- 等级
                if self.rewardList2[v].key~="p1" then
					local level = superWeaponCfg.crystalCfg[self.rewardList2[v].key].lvl
		            local levelLb=GetTTFLabel(tostring(getlocal("fightLevel",{level})),17)
		            levelLb:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height-5))
		            levelLb:setAnchorPoint(ccp(0.5,1));
		            iconSp:addChild(levelLb)
				end
                -- 数量
                local numLb=GetTTFLabel("X" .. tostring(self.rewardList2[v].num),17)
                numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
                numLb:setAnchorPoint(ccp(1,0));
                iconSp:addChild(numLb)
			end
			
			
		end
	

	end
end

function acJiejingkaicaiDialog:startAction2(flag)
	self:playAction()
	self:moveUpAndDown(flag)
end

function acJiejingkaicaiDialog:moveUpAndDown(flag)

	local acArr=CCArray:create()
	for i=1,5 do
		local moveDown = CCMoveTo:create(0.3,ccp(self.iconSp:getPositionX(),self.iconSp:getPositionY()-20))
		local moveUp = CCMoveTo:create(0.3,ccp(self.iconSp:getPositionX(),self.iconSp:getPositionY()))
		acArr:addObject(moveDown)
		acArr:addObject(moveUp)
	end


	local function playEndCallback()
		self:endAction2(flag)
	end
	local callFunc=CCCallFuncN:create(playEndCallback)

	acArr:addObject(callFunc)
	local seq=CCSequence:create(acArr)
	self.iconSp:runAction(seq)


end

function acJiejingkaicaiDialog:endAction2(flag)
	self.touchDialogBg:setIsSallow(false)
	self.state = 0

	self.crystalMergeBg1:stopAllActions()
    self.crystalMergeFireBg:stopAllActions()

    if flag==0 then
    	if self.iconSp then
			self.iconSp:removeFromParentAndCleanup(true)
			self.iconSp=nil
		end
		local item = acJiejingkaicaiVoApi:getDajiang()
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_jiejingkaicai_failure",{item.name}),30)
		acJiejingkaicaiVoApi:setDajiang()
		self:addDajiangDes(true)

    else
    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_upgrade_success"),30)
    	self:addDajiangDes()
    end
end

function acJiejingkaicaiDialog:tick()
	local vo=acJiejingkaicaiVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    
	if acJiejingkaicaiVoApi:isToday()==false and self.isToday==true then
	    self.isToday=false
	    self:refresh()
	end
end

function acJiejingkaicaiDialog:fastTick()
	if self.state == 2 then
		if self.layerVisible==1 then
			self:endAction1(self.tag,self.item)
		else
			self:endAction2(self.flag)
		end
	end
end

function acJiejingkaicaiDialog:runLineAction(tag)
	if tag==1 then
		for k,v in pairs(self.waiLine) do
			local blink = CCBlink:create(2,10)
			v:runAction(CCRepeatForever:create(blink))
		end
	else
		for k,v in pairs(self.neiLine) do
			local blink = CCBlink:create(2,10)
			v:runAction(CCRepeatForever:create(blink))
		end
	end
end

function acJiejingkaicaiDialog:stopLineAction(tag)
	if tag==1 then
		for k,v in pairs(self.waiLine) do
			v:stopAllActions()
			v:setVisible(false)
		end
	else
		for k,v in pairs(self.neiLine) do
			local blink = CCBlink:create(2,10)
			v:stopAllActions()
			v:setVisible(false)
		end
	end
end

function acJiejingkaicaiDialog:dispose()
	self.maskSp=nil
	self.waiSp=nil
	self.neiSp=nil
	self.allSp=nil
	self.xingSp=nil
	self.confirmBtn=nil
	self.crystalMergeBg=nil
	self.upgradeItem=nil
	self.backItem=nil
	self.crystalMergeBg1=nil
	self.crystalMergeFireBg=nil
	self.waiLine=nil
	self.neiLine=nil
	self.iconSp=nil
	self.crystalMergeBottomBg=nil
	self.rewardSp=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/superWeapon/energyCrystal.plist")
    spriteController:removePlist("public/acJiejingkaicai.plist")
    spriteController:removeTexture("public/acJiejingkaicai.png")
end