acSwchallengeactiveDialog = commonDialog:new()

function acSwchallengeactiveDialog:new()
	local  nc = {}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

--初始化对话框面板
function acSwchallengeactiveDialog:initTableView( )
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
	-- 活动时间
    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height -100))
    self.bgLayer:addChild(acLabel,5)
    acLabel:setColor(G_ColorYellowPro)

    local acVo = acSwchallengeactiveVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,25)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height - 140))
    self.bgLayer:addChild(messageLabel,5)
    self.timeLb=messageLabel
    self:updateAcTime()

    -- 帮助按钮
    local function touch(tag,object)
      	PlayEffect(audioCfg.mouseClick)
	    local tabStr = {}
	    local tabColor = {}
	    tabStr = {"\n",getlocal("activity_swchallengeactive_tip2"),"\n",getlocal("activity_swchallengeactive_tip1"),"\n"}
	    tabColor = {nil, nil, nil,nil, nil}
	    local td=smallDialog:new()
	    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
	    sceneGame:addChild(dialog,self.layerNum+1)
  	end

	local menuItemDesc = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,nil,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,1))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-20, self.bgLayer:getContentSize().height-110))
	self.bgLayer:addChild(menuDesc,5)

	
	local function callBack( ... )
		return self:eventHandler(...)
	end
	local function touch2( ... )
		-- body
	end 
	local rewardBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch2)
    rewardBgSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,180))
    rewardBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,messageLabel:getPositionY()-messageLabel:getContentSize().height-10))
    rewardBgSp:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(rewardBgSp,3)

    local subTileLb = GetTTFLabel(getlocal("activity_swchallengeactive_subtitle"),25)
    subTileLb:setAnchorPoint(ccp(0.5,1))
    subTileLb:setPosition(ccp(rewardBgSp:getContentSize().width/2, rewardBgSp:getContentSize().height -10))
    rewardBgSp:addChild(subTileLb)
    subTileLb:setColor(G_ColorYellowPro)

    local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSP:setAnchorPoint(ccp(0.5,0.5))
	lineSP:setScaleX(rewardBgSp:getContentSize().width/lineSP:getContentSize().width)
	lineSP:setScaleY(1.2)
	lineSP:setPosition(ccp(rewardBgSp:getContentSize().width/2,subTileLb:getPositionY()-subTileLb:getContentSize().height-10))
	rewardBgSp:addChild(lineSP)

	local hd = LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(rewardBgSp:getContentSize().width-20,150),nil)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	self.tv:setPosition(ccp(20,20))
	-- self.tv:setAnchorPoint(ccp(0.5,0))
	rewardBgSp:addChild(self.tv)
	-- self.tv:setMaxDisToBottomOrTop(120)

	local descBgSp= CCSprite:create("public/superWeapon/weaponBg.jpg")
    descBgSp:setAnchorPoint(ccp(0.5,1))
    descBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,rewardBgSp:getPositionY()-rewardBgSp:getContentSize().height))
    self.bgLayer:addChild(descBgSp)
    --descBgSp:setScaleY(0.9)
    local scaleBg = (rewardBgSp:getPositionY()-rewardBgSp:getContentSize().height-110)/descBgSp:getContentSize().height
    descBgSp:setScaleY(scaleBg)

    local descBgSp2= CCSprite:createWithSpriteFrameName("ShapeAperture.png")
    descBgSp2:setAnchorPoint(ccp(0.5,0.5))
    descBgSp2:setPosition(ccp(descBgSp:getContentSize().width/2,descBgSp:getContentSize().height/2))
    descBgSp:addChild(descBgSp2)
    if G_getIphoneType() == G_iphoneX then
        descBgSp2:setScale(0.9)
    else
        descBgSp2:setScale(1.2)
    end

    local guidSp1= CCSprite:createWithSpriteFrameName("GuideCharacter.png")
    guidSp1:setAnchorPoint(ccp(0.5,0.5))
    if G_isIphone5()==true then
    	guidSp1:setPosition(ccp(139.5,572))
    else
        guidSp1:setScale(0.8)
    	guidSp1:setPosition(ccp(126,479))
    end
    self.bgLayer:addChild(guidSp1,5)


    local guidSp2= CCSprite:createWithSpriteFrameName("ShapeCharacter.png")
    guidSp2:setAnchorPoint(ccp(0.5,0))
    guidSp2:setPosition(ccp(541,descBgSp:getPositionY()-descBgSp:getContentSize().height*scaleBg))
    self.bgLayer:addChild(guidSp2,5)
    guidSp2:setFlipX(true)

    local picArr = {"crystal_1_1.png","crystal_10_2.png","crystal_3_1.png","crystal_5_3.png","crystal_7_2.png","crystal_6_3.png","crystal_4_3.png","crystal_9_2.png","crystal_2_1.png","crystal_8_2.png"}
    local posArr = {ccp(233.5,290),ccp(292.5,493),ccp(368,583),ccp(503,475),ccp(322.5,319),ccp(436.5,286.5)}

    if G_isIphone5()==true then
    	posArr = {ccp(233.5,396),ccp(171,159),ccp(292,669),ccp(368,759),ccp(503,651),ccp(322,495),ccp(233,212),ccp(425,373),ccp(325,336),ccp(436,462),ccp(390,191)}
        if G_getIphoneType() == G_iphoneX then
            for k,v in pairs(posArr) do
                posArr[k].y = posArr[k].y + 72
            end
        end
    end
    local index = 1
    for k,v in pairs(posArr) do
        if index>10 then
            index=1
        end
        local pic = picArr[index]
    	local crystalIcon=CCSprite:createWithSpriteFrameName(pic)
        crystalIcon:setPosition(v)
        self.bgLayer:addChild(crystalIcon,2)
        index=index+1
        crystalIcon:setRotation(index%3*10)
    end
    local descLbSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch2)
    descLbSp1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-180,120))
    descLbSp1:setPosition(ccp(160,guidSp1:getPositionY()))
    descLbSp1:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(descLbSp1,4)

    local descLbSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch2)
    descLbSp2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-180,120))
    if G_isIphone5()==true then
    	descLbSp2:setPosition(ccp(20,240))
    else
    	descLbSp2:setPosition(ccp(20,140))
    end


    
    descLbSp2:setAnchorPoint(ccp(0,0))
    self.bgLayer:addChild(descLbSp2,4)


    local descLb1 = GetTTFLabelWrap(getlocal("activity_swchallengeactive_desc1"),22,CCSizeMake(descLbSp1:getContentSize().width-80, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb1:setAnchorPoint(ccp(0,0.5))
    descLb1:setPosition(ccp(75, descLbSp1:getContentSize().height/2))
    descLbSp1:addChild(descLb1)
    

    local descLb2 = GetTTFLabelWrap(getlocal("activity_swchallengeactive_desc2"),22,CCSizeMake(descLbSp1:getContentSize().width-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb2:setAnchorPoint(ccp(0,0.5))
    descLb2:setPosition(ccp(10, descLbSp2:getContentSize().height/2))
    descLbSp2:addChild(descLb2)

    if (descLb1:getContentSize().height+10)>descLbSp1:getContentSize().height then
        descLbSp1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-180,descLb1:getContentSize().height+20))
        descLb1:setPosition(ccp(75, descLbSp1:getContentSize().height/2))
    end
    if (descLb2:getContentSize().height+10)>descLbSp2:getContentSize().height then
        descLbSp2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-180,descLb2:getContentSize().height+20))
        descLb2:setPosition(ccp(10, descLbSp2:getContentSize().height/2))
    end
    local function goBtnHandler( ... )
        local openLv=base.superWeaponOpenLv or 25
    	if playerVoApi:getPlayerLevel()<openLv then
          smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("port_scene_building_tip_102",{openLv}),nil,4)
          return
        end
        activityAndNoteDialog:closeAllDialog()
        if superWeaponVoApi and superWeaponVoApi.showMainDialog then
        	self:close()
            superWeaponVoApi:showMainDialog(3,2)
        end
    end
    local goBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",goBtnHandler,11,getlocal("activity_swchallengeactive_btn"),25,99)
    goBtn:setAnchorPoint(ccp(0.5,0.5))
    local goBtnMenu=CCMenu:createWithItem(goBtn)
    goBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,goBtn:getContentSize().height/2+23))
    goBtnMenu:setTouchPriority(-(99-1)*20-1)
    self.bgLayer:addChild(goBtnMenu,2)
end

function acSwchallengeactiveDialog:eventHandler( handler,fn,idx,cel )
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(acSwchallengeactiveVoApi:getReward())
	elseif fn =="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(110,120)
		return tmpSize
	elseif fn =="tableCellAtIndex" then
		local  cell = CCTableViewCell:new()
		cell:autorelease()
		cell:setAnchorPoint(ccp(0,0))
		local item=acSwchallengeactiveVoApi:getReward()[idx+1]
		if item then
			local iconSp=G_getItemIcon(item,nil,true,self.layerNum+1)
			iconSp:setPosition(ccp(5,20))
			iconSp:setAnchorPoint(ccp(0,0.5))
			cell:addChild(iconSp)
			iconSp:setTouchPriority(-(self.layerNum-1)*20-4)

            local numLb = GetTTFLabel("X"..item.num,25)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(iconSp:getContentSize().width-10, 5))
            iconSp:addChild(numLb)
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

function acSwchallengeactiveDialog:tick( ... )
    self:updateAcTime()
end

function acSwchallengeactiveDialog:particPlay( )

end
function acSwchallengeactiveDialog:removePartic( )
	
end

function acSwchallengeactiveDialog:update()

end

function acSwchallengeactiveDialog:updateAcTime()
    local acVo=acSwchallengeactiveVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acSwchallengeactiveDialog:dispose( ... )
	self.tv = nil
	if self and self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
	self = nil
end