enemyInfoSmallDialog=smallDialog:new()

function enemyInfoSmallDialog:new(layerNum,attacklist,data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=layerNum
	self.attacklist=attacklist
	self.data=data
	self.sid=sid
	self.cellHeight=72
	self.selectedTabIndex=0  --当前选中的tab
	self.oldSelectedTabIndex=0--上一次选中的tab
	self.allTabs={}
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/superWeapon.plist")
	return nc
end

function enemyInfoSmallDialog:init(callback)
	self.dialogWidth=G_VisibleSizeWidth-60
	self.dialogHeight=740
	self:initData()

	self.isTouch=nil
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local function close()
		PlayEffect(audioCfg.mouseClick)    
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0, 0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))

	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.bgLayer:getContentSize().width-closeBtnItem:getContentSize().width,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height))
	self.bgLayer:addChild(self.closeBtn)


	local personPhotoName=playerVoApi:getPersonPhotoName(self.pic)
	local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName);
	photoSp:setScale(100/photoSp:getContentSize().width)
	photoSp:setAnchorPoint(ccp(0,0.5))
	photoSp:setPosition(ccp(15,self.bgLayer:getContentSize().height-110))
	self.bgLayer:addChild(photoSp,2)


	local playerNameLb = GetTTFLabelWrap(self.nameStr,28,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.bgLayer:addChild(playerNameLb)
	playerNameLb:setAnchorPoint(ccp(0,0.5))
	playerNameLb:setColor(G_ColorYellowPro)
	playerNameLb:setPosition(140, self.bgLayer:getContentSize().height-70)

	-- 等级
	local levelLb = GetTTFLabelWrap(getlocal("world_war_level",{self.lvStr}),25,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.bgLayer:addChild(levelLb)
	levelLb:setAnchorPoint(ccp(0,0.5))
	levelLb:setPosition(140, self.bgLayer:getContentSize().height-110)

	local rankStr = getlocal("shanBattle_rank",{self.rankStr})
	local rankLb = GetTTFLabelWrap(rankStr,25,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.bgLayer:addChild(rankLb)
	rankLb:setAnchorPoint(ccp(0,0.5))
	rankLb:setPosition(140, self.bgLayer:getContentSize().height-150)

	local powerLb = GetTTFLabelWrap(getlocal("world_war_power",{self.powerStr}),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.bgLayer:addChild(powerLb)
	powerLb:setAnchorPoint(ccp(0,0.5))
	powerLb:setPosition(330, self.bgLayer:getContentSize().height-110)

	local straighTimeLb = GetTTFLabelWrap(getlocal("arena_straightTimes",{self.straitTimeStr}),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.bgLayer:addChild(straighTimeLb)
	straighTimeLb:setAnchorPoint(ccp(0,0.5))
	straighTimeLb:setPosition(330, self.bgLayer:getContentSize().height-150)

	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-180));
    self.bgLayer:addChild(lineSp,1)


    local tabSpaceX=12--30
    local function touchItem(idx)
     
	    self.oldSelectedTabIndex=self.selectedTabIndex
	    self:tabClickColor(idx)
	    return self:tabClick(idx)
       
    end
    local tabItem1 = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
    tabItem1:setTag(1)
    tabItem1:registerScriptTapHandler(touchItem)
    tabItem1:setEnabled(false)
    self.allTabs[1]=tabItem1
    local tabMenu1=CCMenu:createWithItem(tabItem1)
    tabMenu1:setPosition(ccp(tabSpaceX+tabItem1:getContentSize().width/2,self.bgLayer:getContentSize().height-210))
    tabMenu1:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tabMenu1,2)

    local fleetLb = GetTTFLabelWrap(getlocal("fleetInfoTitle2"),20,CCSizeMake(tabItem1:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	fleetLb:setPosition(CCPointMake(tabItem1:getContentSize().width/2,tabItem1:getContentSize().height/2))
	tabItem1:addChild(fleetLb)

    local tabItem2 = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
    tabItem2:setTag(2)
    tabItem2:registerScriptTapHandler(touchItem)
    self.allTabs[2]=tabItem2
    local tabMenu2=CCMenu:createWithItem(tabItem2)
    tabMenu2:setPosition(ccp(tabSpaceX+tabItem1:getContentSize().width/2*3,self.bgLayer:getContentSize().height-210))
    tabMenu2:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tabMenu2,2)

    local heroLb = GetTTFLabelWrap(getlocal("heroTitle"),20,CCSizeMake(tabItem2:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	heroLb:setPosition(CCPointMake(tabItem2:getContentSize().width/2,tabItem2:getContentSize().height/2))
	tabItem2:addChild(heroLb)

    local tabItem3 = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
    tabItem3:setTag(3)
    tabItem3:registerScriptTapHandler(touchItem)
    self.allTabs[3]=tabItem3
    local tabMenu3=CCMenu:createWithItem(tabItem3)
    tabMenu3:setPosition(ccp(tabSpaceX+tabItem1:getContentSize().width/2*5,self.bgLayer:getContentSize().height-210))
    tabMenu3:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tabMenu3,2)

    local superLb = GetTTFLabelWrap(getlocal("super_weapon_title_1"),20,CCSizeMake(tabItem3:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	superLb:setPosition(CCPointMake(tabItem3:getContentSize().width/2,tabItem3:getContentSize().height/2))
	tabItem3:addChild(superLb)

	if base.emblemSwitch==1 and self.emblemId and self.emblemId~=0 then
	    local tabItem4 = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
	    tabItem4:setTag(4)
	    tabItem4:registerScriptTapHandler(touchItem)
	    self.allTabs[4]=tabItem4
	    local tabMenu4=CCMenu:createWithItem(tabItem4)
	    tabMenu4:setPosition(ccp(tabSpaceX+tabItem1:getContentSize().width/2*7,self.bgLayer:getContentSize().height-210))
	    tabMenu4:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.bgLayer:addChild(tabMenu4,2)

	    local emblemLb=GetTTFLabelWrap(getlocal("emblem_title"),20,CCSizeMake(tabItem4:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		emblemLb:setPosition(CCPointMake(tabItem4:getContentSize().width/2,tabItem4:getContentSize().height/2))
		tabItem4:addChild(emblemLb)
	end

    self:initTab1()

   

	local function nilFunc()
	end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function enemyInfoSmallDialog:initTab1()
	if self.backSprie1==nil then
		local capInSet = CCRect(20, 20, 10, 10)
	    local function nilFunc()
	    end
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
		backSprie:setContentSize(CCSizeMake(self.dialogWidth, self.dialogHeight-250))
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(0, 10)
		self.bgLayer:addChild(backSprie)
		self.backSprie1=backSprie
		backSprie:setOpacity(0)

		for i=1,6 do
			local bgSp = CCSprite:createWithSpriteFrameName("emptyTank.png")
			backSprie:addChild(bgSp)
			bgSp:setAnchorPoint(ccp(0,0))
			if i==1 then
				bgSp:setPosition(289, backSprie:getContentSize().height-140)
			elseif i==2 then
				bgSp:setPosition(289, backSprie:getContentSize().height-290)
			elseif i==3 then
				bgSp:setPosition(289, backSprie:getContentSize().height-440)
			elseif i==4 then
				bgSp:setPosition(7, backSprie:getContentSize().height-140)
			elseif i==5 then
				bgSp:setPosition(7, backSprie:getContentSize().height-290)
			elseif i==6 then
				bgSp:setPosition(7, backSprie:getContentSize().height-440)
			end
			
			if self.tankTb[i] and self.tankTb[i][1] then

				local capInSet = CCRect(20, 20, 10, 10);
				local function nilFunc()
				end
				local touchSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
				touchSp:setContentSize(CCSizeMake(bgSp:getContentSize().width, bgSp:getContentSize().height))
				touchSp:setPosition(getCenterPoint(bgSp))
				bgSp:addChild(touchSp)

				local id = (tonumber(self.tankTb[i][1]) or tonumber(RemoveFirstChar(self.tankTb[i][1])))
				local skinId = self.tskinTb[tankSkinVoApi:convertTankId(self.tankTb[i][1])]
				local tankSp=tankVoApi:getTankIconSp(id,skinId,nil,false) --CCSprite:createWithSpriteFrameName(tankCfg[id].icon)
				tankSp:setScale(0.6)
				tankSp:setAnchorPoint(ccp(0,0.5));
				tankSp:setPosition(ccp(5,bgSp:getContentSize().height/2))
				bgSp:addChild(tankSp)

				if id~=G_pickedList(id) then
			        local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
			        tankSp:addChild(pickedIcon)
			        pickedIcon:setPosition(tankSp:getContentSize().width-30,30)
			        pickedIcon:setScale(1.5)
			    end

				local cnOrDeTNumheiPos = nil
				local cnOrDeTheightPos=nil
		        cnOrDeTheightPos=40
		        cnOrDeTNumheiPos=30


				local tankNameLb = GetTTFLabelWrap(getlocal(tankCfg[id].name),22,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop);
				tankNameLb:setAnchorPoint(ccp(0,1));
				tankNameLb:setPosition(ccp(tankSp:getContentSize().width*0.6+5,bgSp:getContentSize().height/2+cnOrDeTheightPos));
				bgSp:addChild(tankNameLb,2)

				local tankNum = GetTTFLabel(self.tankTb[i][2],22);
				tankNum:setAnchorPoint(ccp(0,0.5));
				tankNum:setPosition(ccp(tankSp:getContentSize().width*0.6+10,bgSp:getContentSize().height/2-cnOrDeTNumheiPos));
				bgSp:addChild(tankNum,2);
			end
		end

	else
		
	end

end

function enemyInfoSmallDialog:initTab2()
	if self.backSprie2==nil then
		local capInSet = CCRect(20, 20, 10, 10)
	    local function nilFunc()
	    end
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
		backSprie:setContentSize(CCSizeMake(self.dialogWidth, self.dialogHeight-250))
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(0, 10)
		self.bgLayer:addChild(backSprie)
		self.backSprie2=backSprie
		backSprie:setOpacity(0)

		for i=1,6 do
			local bgSp = CCSprite:createWithSpriteFrameName("emptyHero.png")
			backSprie:addChild(bgSp)
			bgSp:setAnchorPoint(ccp(0,0))
			if i==1 then
				bgSp:setPosition(289, backSprie:getContentSize().height-140)
			elseif i==2 then
				bgSp:setPosition(289, backSprie:getContentSize().height-290)
			elseif i==3 then
				bgSp:setPosition(289, backSprie:getContentSize().height-440)
			elseif i==4 then
				bgSp:setPosition(7, backSprie:getContentSize().height-140)
			elseif i==5 then
				bgSp:setPosition(7, backSprie:getContentSize().height-290)
			elseif i==6 then
				bgSp:setPosition(7, backSprie:getContentSize().height-440)
			end

			if self.heroTb[i] and self.heroTb[i]~="" and tostring(self.heroTb[i])~="0" then

				local capInSet = CCRect(20, 20, 10, 10);
				local function nilFunc()
				end
				local touchSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
				touchSp:setContentSize(CCSizeMake(bgSp:getContentSize().width, bgSp:getContentSize().height))
				touchSp:setPosition(getCenterPoint(bgSp))
				bgSp:addChild(touchSp)

				local arr=Split(self.heroTb[i],"-")
				local adjutants = heroAdjutantVoApi:decodeAdjutant(self.heroTb[i])
				local heroSp=heroVoApi:getHeroIcon(arr[1],arr[2],nil,nil,nil,nil,nil,{adjutants=adjutants})
				heroSp:setScale(0.45)
				heroSp:setAnchorPoint(ccp(0,0.5));
				heroSp:setPosition(ccp(15,bgSp:getContentSize().height/2))
				bgSp:addChild(heroSp)

				local heroLbName = GetTTFLabelWrap(heroVoApi:getHeroName(arr[1]),22,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop);
				heroLbName:setAnchorPoint(ccp(0,1));
				heroLbName:setPosition(ccp(heroSp:getContentSize().width*0.6+5,bgSp:getContentSize().height/2+40));
				bgSp:addChild(heroLbName,2)

				local lvLb = GetTTFLabel("LV."..arr[3],22)
				lvLb:setAnchorPoint(ccp(0,1));
				lvLb:setPosition(ccp(heroSp:getContentSize().width*0.6+5,bgSp:getContentSize().height/2+40-heroLbName:getContentSize().height));
				bgSp:addChild(lvLb,2)

			end
			
		end

	else
		
	end

end

function enemyInfoSmallDialog:initTab3()
	if self.backSprie3==nil then
		local capInSet = CCRect(20, 20, 10, 10)
	    local function nilFunc()
	    end
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
		backSprie:setContentSize(CCSizeMake(self.dialogWidth, self.dialogHeight-250))
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(0, 10)
		self.bgLayer:addChild(backSprie)
		self.backSprie3=backSprie
		backSprie:setOpacity(0)

		for i=1,6 do
			local bgSp = CCSprite:createWithSpriteFrameName("superWeapon_equipBg.png")
			backSprie:addChild(bgSp)
			bgSp:setAnchorPoint(ccp(0,0))
			if i==1 then
				bgSp:setPosition(299, backSprie:getContentSize().height-150)
			elseif i==2 then
				bgSp:setPosition(299, backSprie:getContentSize().height-300)
			elseif i==3 then
				bgSp:setPosition(299, backSprie:getContentSize().height-450)
			elseif i==4 then
				bgSp:setPosition(22, backSprie:getContentSize().height-150)
			elseif i==5 then
				bgSp:setPosition(22, backSprie:getContentSize().height-300)
			elseif i==6 then
				bgSp:setPosition(22, backSprie:getContentSize().height-450)
			end


			if self.superWeaponTb[i] and self.superWeaponTb[i]~=0 then

				local capInSet = CCRect(20, 20, 10, 10);
				local function nilFunc()
				end
				local touchSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
				touchSp:setContentSize(CCSizeMake(bgSp:getContentSize().width, bgSp:getContentSize().height))
				touchSp:setPosition(getCenterPoint(bgSp))
				bgSp:addChild(touchSp)

				local weaponCfg=superWeaponCfg.weaponCfg
				local arr=Split(self.superWeaponTb[i],"-")

				local weaponSp=CCSprite:createWithSpriteFrameName(weaponCfg[arr[1]].icon)
				weaponSp:setScale(80/weaponSp:getContentSize().width)
				weaponSp:setAnchorPoint(ccp(0,0.5));
				weaponSp:setPosition(ccp(5,bgSp:getContentSize().height/2))
				bgSp:addChild(weaponSp)

				local weaponLbName = GetTTFLabelWrap(getlocal(weaponCfg[arr[1]].name),22,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop);
				weaponLbName:setAnchorPoint(ccp(0,1));
				weaponLbName:setPosition(ccp(80+5,bgSp:getContentSize().height/2+40));
				bgSp:addChild(weaponLbName,2)

				local lvLb = GetTTFLabel("LV."..arr[2],22)
				lvLb:setAnchorPoint(ccp(0,1));
				lvLb:setPosition(ccp(80+5,bgSp:getContentSize().height/2+40-weaponLbName:getContentSize().height));
				bgSp:addChild(lvLb,2)


			end


			
		end

	else
		
	end

end

function enemyInfoSmallDialog:initTab4()
	if self.backSprie4==nil then
		local capInSet = CCRect(20, 20, 10, 10)
	    local function nilFunc()
	    end
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
		backSprie:setContentSize(CCSizeMake(self.dialogWidth, self.dialogHeight-250))
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(0, 10)
		self.bgLayer:addChild(backSprie)
		self.backSprie4=backSprie
		backSprie:setOpacity(0)
        
		if self.emblemId==nil or self.emblemId==0 then
			do return end
		end

		local posy=backSprie:getContentSize().height-10
		local emblemCfg = emblemVoApi:getEquipCfgById(self.emblemId)
		local emblemIcon = emblemVoApi:getEquipIcon(self.emblemId,nil,nil,nil,emblemCfg.qiangdu,emblemCfg.color)
		backSprie:addChild(emblemIcon)
		emblemIcon:setAnchorPoint(ccp(0.5,1))
		emblemIcon:setPosition(ccp(backSprie:getContentSize().width/2,posy))

		posy=posy-emblemIcon:getContentSize().height-15
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScale(backSprie:getContentSize().width/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(backSprie:getContentSize().width/2,posy))
		backSprie:addChild(lineSp)

		local skillLb=GetTTFLabelWrap(getlocal("emblem_infoSkill"),28,CCSizeMake(backSprie:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		posy=posy-15-skillLb:getContentSize().height/2
		skillLb:setAnchorPoint(ccp(0.5,0.5))
		skillLb:setPosition(ccp(backSprie:getContentSize().width/2,posy))
		skillLb:setColor(G_ColorYellowPro)
		backSprie:addChild(skillLb)

		posy=posy-skillLb:getContentSize().height/2
		posy=posy/2+35
		if emblemCfg.skill == nil then
            local skillDescLb = GetTTFLabelWrap(getlocal("emblem_noSkill"),25,CCSizeMake(backSprie:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		    skillDescLb:setAnchorPoint(ccp(0.5,0.5))
		    skillDescLb:setPosition(ccp(backSprie:getContentSize().width/2,posy))
		    skillDescLb:setColor(G_ColorGray)
		    backSprie:addChild(skillDescLb)
		else
	        local skillId = emblemCfg.skill[1] --  显示装备的技能信息
	        local skillLv = emblemCfg.skill[2]
	        local skillNameLb=GetTTFLabelWrap(emblemVoApi:getEquipSkillNameById(skillId,skillLv)..":",25,CCSizeMake(backSprie:getContentSize().width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
			skillNameLb:setAnchorPoint(ccp(0,0))
			skillNameLb:setPosition(ccp(30,posy+5))
			backSprie:addChild(skillNameLb)
			skillNameLb:setColor(G_ColorGreen)
			local colorTab={nil,G_ColorGreen,nil}
			local desc=emblemVoApi:getEquipSkillDesById(skillId,skillLv,true)
            local descLb,lbHeight=G_getRichTextLabel(desc,colorTab,25,backSprie:getContentSize().width-60,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
            descLb:setAnchorPoint(ccp(0,1))
            backSprie:addChild(descLb)
            descLb:setPosition(ccp(30,posy-5))
		end
	else
		
	end
end

function enemyInfoSmallDialog:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
end

function enemyInfoSmallDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx           
         else            
            v:setEnabled(true)
         end
    end

    if(idx==1)then
        if self.backSprie1==nil then
           self:initTab1()
        end
        if self.backSprie1 then
           self.backSprie1:setPosition(ccp(0,10))
           self.backSprie1:setVisible(true)
        end
        if self.backSprie2 then
           self.backSprie2:setPosition(ccp(999333,0))
           self.backSprie2:setVisible(false)
        end
        if self.backSprie3 then
           self.backSprie3:setPosition(ccp(999333,0))
           self.backSprie3:setVisible(false)
        end
        if self.backSprie4 then
           self.backSprie4:setPosition(ccp(999333,0))
           self.backSprie4:setVisible(false)
        end
    elseif(idx==2)then
    	if self.backSprie2==nil then
           self:initTab2()
        end
        if self.backSprie2 then
           self.backSprie2:setPosition(ccp(0,10))
           self.backSprie2:setVisible(true)
        end
        if self.backSprie1 then
           self.backSprie1:setPosition(ccp(999333,0))
           self.backSprie1:setVisible(false)
        end
        if self.backSprie3 then
           self.backSprie3:setPosition(ccp(999333,0))
           self.backSprie3:setVisible(false)
        end
        if self.backSprie4 then
           self.backSprie4:setPosition(ccp(999333,0))
           self.backSprie4:setVisible(false)
        end
	elseif(idx==3)then
        if self.backSprie3==nil then
           self:initTab3()
        end
        if self.backSprie3 then
           self.backSprie3:setPosition(ccp(0,10))
           self.backSprie3:setVisible(true)
        end
        if self.backSprie2 then
           self.backSprie2:setPosition(ccp(999333,0))
           self.backSprie2:setVisible(false)
        end
        if self.backSprie1 then
           self.backSprie1:setPosition(ccp(999333,0))
           self.backSprie1:setVisible(false)
        end
        if self.backSprie4 then
           self.backSprie4:setPosition(ccp(999333,0))
           self.backSprie4:setVisible(false)
        end
    elseif(idx==4)then
        if self.backSprie4==nil then
           self:initTab4()
        end
        if self.backSprie4 then
           self.backSprie4:setPosition(ccp(0,10))
           self.backSprie4:setVisible(true)
        end
        if self.backSprie3 then
           self.backSprie3:setPosition(ccp(999333,0))
           self.backSprie3:setVisible(true)
        end
        if self.backSprie2 then
           self.backSprie2:setPosition(ccp(999333,0))
           self.backSprie2:setVisible(false)
        end
        if self.backSprie1 then
           self.backSprie1:setPosition(ccp(999333,0))
           self.backSprie1:setVisible(false)
        end
    end


end

function enemyInfoSmallDialog:initData()
	if self.attacklist[2]<1000000 then
		local sid = "s" .. self.attacklist[2]
		self.lvStr = arenanpcCfg[sid].level
		self.nameStr = arenaVoApi:getNpcNameById(self.attacklist[2])
		self.rankStr = self.attacklist[1]
		self.straitTimeStr = 0
		self.powerStr = FormatNumber(arenanpcCfg[sid].Fighting)
		self.tankTb=arenanpcCfg[sid].tank
		self.tskinTb={} --坦克皮肤数据
		self.heroTb={}
		self.superWeaponTb={}
		self.emblemId=nil
		self.pic=1
	else
		self.lvStr = self.attacklist[4]
		self.nameStr = self.attacklist[3]
		self.rankStr = self.attacklist[1]
		self.straitTimeStr = self.data.victory
		self.powerStr = FormatNumber(self.attacklist[5])
		self.tankTb=self.data.troops or {}
		self.tskinTb=self.data.skin or {} --坦克皮肤数据
		self.heroTb=self.data.hero or {}
		self.superWeaponTb=self.data.weapon or {}
		self.emblemId=self.data.emblem or nil
		self.pic=self.attacklist[6] or 1
	end
end



function enemyInfoSmallDialog:dispose()
	self.allTabs=nil
	self.backSprie1=nil
	self.backSprie2=nil
	self.backSprie3=nil
	self.backSprie4=nil
	self.selectedTabIndex=nil  --当前选中的tab
	self.oldSelectedTabIndex=nil --上一次选中的tab
	self.lvStr = nil
	self.nameStr = nil
	self.rankStr = nil
	self.straitTimeStr = nil
	self.powerStr = nil
	self.tankTb= nil
	self.heroTb= nil
	self.superWeaponTb= nil
	self.emblemId=nil
end


