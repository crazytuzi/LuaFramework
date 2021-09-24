popDialog={}
function popDialog:new()
    local nc={
            container,
     touchDialogBg,
            isUseAmi,
            require4={}, --4个需求
            updateOnline=nil,
            isShow = false, -- 在线礼包奖励面板是否打开
            id,

          }
    setmetatable(nc,self)
    self.__index=self
    base.allShowedSmallDialog=base.allShowedSmallDialog+1
    return nc
end

--有评价奖励的评价面板, 有两个按钮, 与后台有交互
function popDialog:createEvaluate(container,layerNum,title,desc,award)
    local td=self:new()
    td:initEvaluate(container,layerNum,title,desc,award)
    self.isUseAmi=true
end

function popDialog:createNewGuid(container,layerNum,title,desc,award)
    local td=self:new()
    td:initNewGuid(container,layerNum,title,desc,award)
    self.isUseAmi=true
end
function popDialog:createPowerSurge(container,layerNum,title,desc,award)
    local td=self:new()
    td:initPowerSurge(container,layerNum,title,desc,award)
    self.isUseAmi=true
end

--简单的评价面板, 只有三个按钮和一句话, 没有奖励
function popDialog:createSimpleEvaluate(container,layerNum)
    local td=self:new()
    td:initSimpleEvaluate(container,layerNum,title,desc)
    self.isUseAmi=true
end

--军团活跃福利领奖面板
function popDialog:createAllianceAcReward(container,layerNum,title,award)
    local td=self:new()
    td:initAllianceAcReward(container,layerNum,title,award)
    self.isUseAmi=true
end
function popDialog:initAllianceAcReward(parent,layerNum,title,award)
    local function touchDialog()
          
    end

    -- local rect = CCRect(0, 0, 400, 600)
    local capInSet = CCRect(130, 50, 1, 1)
    local capInSet1 = CCRect(10, 10, 1, 1)


    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    dialogBg:setContentSize(CCSizeMake(500,600))
    self.container=dialogBg
    
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,layerNum);

    local function closeHandler()
    	if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local rightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",closeHandler,2,getlocal("randomMoveIslandOK"),25)
    local rightMenu=CCMenu:createWithItem(rightItem);
    rightMenu:setPosition(ccp(dialogBg:getContentSize().width/2,70))
    rightMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(rightMenu)
  
 --  	local spriteIcon
 --  	if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
 --  		spriteIcon = CCSprite:create("public/woman.png");
	-- 	local spScaleX=0.6
	--     spriteIcon:setScaleX(spScaleX)
	--     spriteIcon:setScaleY(0.7)
	-- 	spriteIcon:setFlipX(true)
	--     spriteIcon:setPosition(-20+spriteIcon:getContentSize().width/2*spScaleX,dialogBg:getContentSize().height/2)
	-- else
	-- 	spriteIcon = CCSprite:createWithSpriteFrameName("ShapeCharacter.png");
	-- 	spriteIcon:setAnchorPoint(ccp(0,0));
	-- 	spriteIcon:setPosition(-30,10)
	-- end
	-- self.container:addChild(spriteIcon,8)

	local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle,2)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle1,2)

	local spriteShapeAperture = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeAperture:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteShapeAperture,1)

	-- local spriteShapeEagle = CCSprite:createWithSpriteFrameName("ShapeEagle.png");
	-- spriteShapeEagle:setAnchorPoint(ccp(0.5,0.5));
	-- spriteShapeEagle:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-spriteShapeEagle:getContentSize().height/2-60)
	-- self.container:addChild(spriteShapeEagle,2)


	if title then
		local tLable=GetTTFLabel(title,30)
		tLable:setAnchorPoint(ccp(0.5,0.5))
		tLable:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-80))
		dialogBg:addChild(tLable,2)
		tLable:setColor(G_ColorYellowPro)
	end

	local function touchLuaSpr( ... )
	end
	local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),touchLuaSpr)
    bgSp:setAnchorPoint(ccp(0.5,1))
    bgSp:setContentSize(CCSizeMake(dialogBg:getContentSize().width-40,dialogBg:getContentSize().height-250))
    bgSp:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-120))
    dialogBg:addChild(bgSp)


    if award and SizeOfTable(award)>0 then
    	local rewardTb=FormatItem(award)
    	for k,v in pairs(rewardTb) do
    		local px,py=70+((k-1)%2)*225,dialogBg:getContentSize().height-185-math.floor((k-1)/2)*110
    		local icon
    		-- local iconSize=100
    		if v.type=="u" then
    			if v.key=="r1" then
    				icon=CCSprite:createWithSpriteFrameName("IconCopper.png")
    			elseif v.key=="r2" then
    				icon=CCSprite:createWithSpriteFrameName("IconOil.png")
    			elseif v.key=="r3" then
    				icon=CCSprite:createWithSpriteFrameName("IconIron.png")
    			elseif v.key=="r4" then
    				icon=CCSprite:createWithSpriteFrameName("IconOre.png")
				elseif v.key=="gold" then
					icon=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
				-- else
				-- 	icon=G_getItemIcon(v,100)
				end
    		-- else
    		-- 	icon=G_getItemIcon(v,100)
    		end
    		if icon then
	    		icon:setPosition(ccp(px,py))
	    		icon:setScale(2)
	    		dialogBg:addChild(icon,2)
	    		local nameStr=v.name
	    		-- nameStr="啊啊啊啊啊啊啊啊啊啊啊"
	    		local nameLb=GetTTFLabelWrap(nameStr,22,CCSize(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				nameLb:setAnchorPoint(ccp(0,0.5))
				nameLb:setPosition(ccp(px+40,py+20))
				dialogBg:addChild(nameLb,2)
				local numLb=GetTTFLabel("x"..FormatNumber(v.num),22)
				numLb:setAnchorPoint(ccp(0,0.5))
				numLb:setPosition(ccp(px+40,py-20))
				dialogBg:addChild(numLb,2)
			end
    	end
    end


    self.container:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.container,layerNum+1)
    self:show()


end

function popDialog:initEvaluate(parent,layerNum,title,desc,award)
    local function touchDialog()
          
    end

    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 50, 1, 1)
    local capInSet1 = CCRect(10, 10, 1, 1)


    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    dialogBg:setContentSize(CCSizeMake(600,500))
    self.container=dialogBg
    
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,layerNum);
    
    local function rightHandler()
        local function callback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data.userevaluate~=nil and sData.data.userevaluate.reward~=nil then
                    local award=FormatItem(sData.data.userevaluate.reward) or {}
                    for k,v in pairs(award) do
                        G_addPlayerAward(v.type,v.key,v.id,v.num)
                    end
                    G_showRewardTip(award, true)
                end

            end
            self:close()
        end

        socketHelper:userEvaluate(callback)
        self:goEvaluate()
    end
    
    local rightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rightHandler,2,getlocal("randomMoveIslandOK"),25)
    local rightMenu=CCMenu:createWithItem(rightItem);
    rightMenu:setPosition(ccp(dialogBg:getContentSize().width/2-100,10))
    rightMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(rightMenu)
    
     local function cancleHandler()

        local function callback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
              if sData.data.userevaluate~=nil and sData.data.userevaluate.reward~=nil then
                  local award=FormatItem(sData.data.userevaluate.reward) or {}
                  for k,v in pairs(award) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num)
                  end
                  G_showRewardTip(award, true)
              end
            end
            self:close()
        end

        socketHelper:userEvaluate(callback)
        
     end
    
    local  cItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",cancleHandler,2,getlocal("cancel"),25)
    local cMenu=CCMenu:createWithItem(cItem);
    cMenu:setPosition(ccp(dialogBg:getContentSize().width/2+100,10))
    cMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(cMenu)

  	local spriteIcon
  	if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
  		spriteIcon = CCSprite:create("public/woman.png");
		local spScaleX=0.6
	    spriteIcon:setScaleX(spScaleX)
	    spriteIcon:setScaleY(0.7)
		spriteIcon:setFlipX(true)
	    spriteIcon:setPosition(-20+spriteIcon:getContentSize().width/2*spScaleX,dialogBg:getContentSize().height/2)
	else
		spriteIcon = CCSprite:createWithSpriteFrameName("ShapeCharacter.png");
		spriteIcon:setAnchorPoint(ccp(0,0));
		spriteIcon:setPosition(-30,10)
	end
	self.container:addChild(spriteIcon,8)

	local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle,2)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle1,2)

	local spriteShapeAperture = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeAperture:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteShapeAperture,1)

	local spriteShapeEagle = CCSprite:createWithSpriteFrameName("ShapeEagle.png");
	spriteShapeEagle:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeEagle:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-spriteShapeEagle:getContentSize().height/2-60)
	self.container:addChild(spriteShapeEagle,2)


    local function shapeDiaTouch()
    
    end
    local capInSet = CCRect(130, 70, 1, 1)
    local spriteShapeDialog =LuaCCScale9Sprite:createWithSpriteFrameName("ShapeDialog.png",capInSet,shapeDiaTouch);
	--local spriteShapeDialog = CCSprite:createWithSpriteFrameName("ShapeDialog.png");
	spriteShapeDialog:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeDialog:setContentSize(CCSizeMake(430,160));
	spriteShapeDialog:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-90)
	self.container:addChild(spriteShapeDialog,2)

	--[[local spriteShapeDialog = CCSprite:createWithSpriteFrameName("ShapeDialog.png");
	spriteShapeDialog:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeDialog:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-spriteShapeDialog:getContentSize().height/2-90)
	self.container:addChild(spriteShapeDialog,2)]]

	local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeInfor.png");
	spriteShapeInfor:setAnchorPoint(ccp(0.5,0));
	spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2+60,30)
	self.container:addChild(spriteShapeInfor,2)

	local titleLb=GetTTFLabel(getlocal("award"),30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(spriteShapeInfor:getContentSize().width/2,spriteShapeInfor:getContentSize().height+17))
	spriteShapeInfor:addChild(titleLb,2)
	titleLb:setColor(G_ColorYellowPro)
  
	-- local titleDesLb=GetTTFLabel(getlocal("getLotItems"),26)
	local titleDesLb=GetTTFLabelWrap(getlocal("evaluateGiftDesc"),22,CCSizeMake(340, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	if desc then
		titleDesLb=GetTTFLabelWrap(desc,22,CCSizeMake(310, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	else
		--titleDesLb:setColor(G_ColorYellowPro)
	end
	titleDesLb:setAnchorPoint(ccp(0.5,0.5))
	titleDesLb:setPosition(ccp(spriteShapeDialog:getContentSize().width/2+titleDesLb:getContentSize().width/2-290/2,spriteShapeDialog:getContentSize().height/2))
	spriteShapeDialog:addChild(titleDesLb,2)
  
	--if award then
	if title then
		local tLable=GetTTFLabel(title,30)
		tLable:setAnchorPoint(ccp(0.5,0.5))
		tLable:setPosition(ccp(dialogBg:getContentSize().width/2-60,dialogBg:getContentSize().height-108))
		spriteShapeInfor:addChild(tLable,2)
		tLable:setColor(G_ColorYellowPro)
	end
	if titleLb then
		titleLb:setPosition(ccp(dialogBg:getContentSize().width/2-60,spriteShapeInfor:getContentSize().height+17))	
	end
	if spriteShapeAperture then
		spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	end
	if spriteShapeEagle then
		spriteShapeEagle:setPosition(dialogBg:getContentSize().width/2+20,dialogBg:getContentSize().height-spriteShapeEagle:getContentSize().height/2-60)
	end
	if spriteShapeDialog then
		spriteShapeDialog:setPosition(dialogBg:getContentSize().width/2+20,dialogBg:getContentSize().height-spriteShapeDialog:getContentSize().height/2-93)
	end
	if spriteShapeInfor then
		spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2+0,30)
	end
	if award then
		local awardNum=SizeOfTable(award)
		local function showInfoHandler(hd,fn,idx)
			local item=award[idx]
			if item and item.name and item.pic and item.num and item.desc then
				propInfoDialog:create(sceneGame,item,layerNum+1)
			end
		end
		for k,v in pairs(award) do
			if v and v.pic and v.num then
				local icon
				local pic=v.pic
				--local startIndex,endIndex=string.find(pic,"^rank(%d+).png$")
				local iconScaleX=1
				local iconScaleY=1
				--[[
				if startIndex~=nil and endIndex~=nil then
					icon=GetBgIcon(pic)
				else
				icon = CCSprite:createWithSpriteFrameName(pic)
				]]
				icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
				if icon:getContentSize().width>100 then
					iconScaleX=iconScaleX*100/150
					iconScaleY=iconScaleX*100/150
				end
				icon:setScaleX(iconScaleX)
				icon:setScaleY(iconScaleY)
					--end
				icon:ignoreAnchorPointForPosition(false)
		        icon:setAnchorPoint(ccp(0.5,0.5))
				if awardNum==1 then
					icon:setPosition(ccp(130+icon:getContentSize().width,spriteShapeInfor:getContentSize().height/2+6))
				elseif awardNum==2 then
					icon:setPosition(ccp(170+(icon:getContentSize().width+45)*(k-1),spriteShapeInfor:getContentSize().height/2+6))
				elseif awardNum==3 then
					icon:setPosition(ccp(130+(icon:getContentSize().width+20)*(k-1),spriteShapeInfor:getContentSize().height/2+6))
				end
				icon:setIsSallow(false)
				icon:setTouchPriority(-(layerNum-1)*20-2)
		        spriteShapeInfor:addChild(icon,1)
				icon:setTag(k)
		
				local numLabel=GetTTFLabel("x"..v.num,25)
		        --numLabel:setColor(G_ColorGreen)
				numLabel:setAnchorPoint(ccp(1,0))
				numLabel:setPosition(icon:getContentSize().width-5,0)
				icon:addChild(numLabel,1)
				numLabel:setScaleX(1/iconScaleX)
				numLabel:setScaleY(1/iconScaleY)
			end
		end
	else
		for i=1,1,1 do
			local nameStr=nil
			local numLbStr=nil
			if i==1 then
				nameStr="item_baoxiang_04.png"
				numLbStr="×1"
			elseif i==2 then
				nameStr="RocketLv3.png"
				numLbStr="×1"
			elseif i==3 then
				nameStr="Icon_novicePacks.png"
				numLbStr="×1"
			end

			local spriteIcon = CCSprite:createWithSpriteFrameName("Icon_buff1.png");
			spriteIcon:setAnchorPoint(ccp(0.5,0.5));
			spriteIcon:setPosition(130+(spriteIcon:getContentSize().width+15)*(i-1),spriteShapeInfor:getContentSize().height/2+6);
			spriteShapeInfor:addChild(spriteIcon,2);
			local numLb=GetTTFLabel(numLbStr,20)
			numLb:setAnchorPoint(ccp(1,0));
			numLb:setPosition(ccp(spriteIcon:getContentSize().width-8,4));
			spriteIcon:addChild(numLb,2);
    
 		   	local sp=CCSprite:createWithSpriteFrameName(nameStr);
  		  	if i==1 or i==2 then
				local scale=100/sp:getContentSize().width
				sp:setScale(scale)
  		  	end
  		  	sp:setPosition(ccp(spriteIcon:getContentSize().width/2,spriteIcon:getContentSize().height/2))
  		  	spriteIcon:addChild(sp)
		end
	end


    self.container:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.container,layerNum+1)
    self:show()


end

function popDialog:initSimpleEvaluate(parent,layerNum)
	local function touchHandler()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
	self.container=dialogBg
	self.dialogLayer=CCLayer:create()
	
	local size=CCSizeMake(550,400)
	self.bgLayer=dialogBg
	self.bgSize=size
	self.bgLayer:setContentSize(size)

	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	
	local titleLb=GetTTFLabel(getlocal("dialog_title_prompt"),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)
	local contentLb=GetTTFLabelWrap(getlocal("evaluate_content"),25,CCSize(size.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	contentLb:setAnchorPoint(ccp(0.5,0.5))
	contentLb:setPosition(ccp(size.width/2,size.height/2))
	dialogBg:addChild(contentLb)
	
	--never
	local function neverHandler()
		PlayEffect(audioCfg.mouseClick)
		CCUserDefault:sharedUserDefault():setIntegerForKey("evaluate_version"..G_Version,-1)
		CCUserDefault:sharedUserDefault():flush()
		self:close()
	end
	local neverItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",neverHandler,2,getlocal("evaluate_never"),25)
	local neverMenu=CCMenu:createWithItem(neverItem)
	neverMenu:setPosition(ccp(size.width*5/6,60))
	neverMenu:setTouchPriority(-(layerNum-1)*20-2)
	dialogBg:addChild(neverMenu)

	--later
	local function laterHandler()
		PlayEffect(audioCfg.mouseClick)
		CCUserDefault:sharedUserDefault():setIntegerForKey("evaluate_version"..G_Version,playerVoApi:getPlayerLevel()+platCfg.platEvaluate[G_curPlatName()])
		CCUserDefault:sharedUserDefault():flush()
		self:close()
	end
	local laterItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",laterHandler,2,getlocal("evaluate_later"),25)
	local laterMenu=CCMenu:createWithItem(laterItem)
	laterMenu:setPosition(ccp(size.width/2,60))
	laterMenu:setTouchPriority(-(layerNum-1)*20-2)
	dialogBg:addChild(laterMenu)

	--now
	local function nowHandler()
		PlayEffect(audioCfg.mouseClick)
		self:goEvaluate()
		CCUserDefault:sharedUserDefault():setIntegerForKey("evaluate_version"..G_Version,-1)
		self:close()
	end
	local nowItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",nowHandler,2,getlocal("evaluate_now"),25)
	local nowMenu=CCMenu:createWithItem(nowItem)
	nowMenu:setPosition(ccp(size.width/6,60))
	nowMenu:setTouchPriority(-(layerNum-1)*20-2)
	dialogBg:addChild(nowMenu)

	self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandler)
	self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	self.touchDialogBg:setContentSize(rect)
	self.touchDialogBg:setOpacity(180)
	self.touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.touchDialogBg,1)
	
	parent:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function popDialog:goEvaluate()
	if G_isIOS() then
          if platCfg["platEvaluateUrl"][G_curPlatName()]~=nil then
              local upUrl=platCfg["platEvaluateUrl"][G_curPlatName()]
              local updateUrl=G_sendHttpRequest(upUrl,"")
              if updateUrl~=nil and updateUrl~="" then
                  local tmpTb={}
                  tmpTb["action"]="openUrl"
                  tmpTb["parms"]={}
                  tmpTb["parms"]["url"]=updateUrl
                  local cjson=G_Json.encode(tmpTb)
                  G_accessCPlusFunction(cjson)
              end
          end
	  else
	      local updateCfgUrl=platCfg["platEvaluateUrl"][G_curPlatName()]
	      
	      local updateUrl=nil
	      if updateCfgUrl~=nil then
            updateUrl=G_sendHttpRequest(updateCfgUrl,"")
	      end
	      if(updateUrl and updateUrl~="")then
			  local tmpTb={}
			  tmpTb["action"]="openUrl"
			  tmpTb["parms"]={}
			  tmpTb["parms"]["url"]=updateUrl
			  local cjson=G_Json.encode(tmpTb)
			  G_accessCPlusFunction(cjson)
		  end
	end
end


function popDialog:checkIfBoxOpen()
	return self.isShow
end
function popDialog:setIsShow(value)
	self.isShow = value
end
-- 在线礼包奖励面板
function popDialog:createOnlinePackage(container,layerNum,award)
	if playerVoApi:checkIfGetAllOnlinePackage() == true then
		return
	end

	local td = self:new()
	td:initOnlinePackage(container,layerNum,award)
	self.isUseAmi = true -- self 此处的self代表的是popDialog自身的self,而不是td这个对象的，只有通过td的调用，方法内的self才是td的。
	td:setIsShow(true)
	return td
end

function popDialog:initNewGuid(parent,layerNum,title,desc,award)
    local function touchDialog()
          
    end

    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 50, 1, 1)
    local capInSet1 = CCRect(10, 10, 1, 1)


    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    dialogBg:setContentSize(CCSizeMake(600,450))
    self.container=dialogBg
    
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,layerNum);
    
    local function rightHandler2()
        PlayEffect(audioCfg.mouseClick)
        self:close()
        if base.isNd==1 and G_getWeeTs(base.serverTime) ~= G_getWeeTs(playerVoApi:getRegdate()) and award==nil then
            popDialog:createPowerSurge(sceneGame,30,getlocal("powerSurgeTitle2"),getlocal("powerSurgeDesc2"),2)
            base.nextDay=1
        else
            if base.isNd==1 and award==nil then
                popDialog:createPowerSurge(sceneGame,30,getlocal("powerSurgeTitle"),getlocal("powerSurgeDesc"))
            end
        end

    end

    local function rightHandler()
    	if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
    		local jsonParams=base.efunLoginParms
    		if(jsonParams and jsonParams~="")then
    			local loginParams=G_Json.decode(jsonParams)
    			if(loginParams.ext1 and loginParams.ext1~="")then
                    CCUserDefault:sharedUserDefault():setStringForKey("hasShowFacebookLoginReward","1")
                    CCUserDefault:sharedUserDefault():flush()
    				local function onRequestEnd(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if(ret==true)then
    					   require "luascript/script/config/gameconfig/friendCfg"
    					   local rewardCfg=friendCfg.loginReward.reward
    					   local reward=FormatItem(rewardCfg)
    					   for k,v in pairs(reward) do
    					       G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
    					   end
                        end
    				end
    				socketHelper:getFacebookReward("user",nil,nil,onRequestEnd)
    				self:close()
    				local function showRightHandler2()
        				if base.isNd==1 and G_getWeeTs(base.serverTime) ~= G_getWeeTs(playerVoApi:getRegdate()) and award==nil then
        				    popDialog:createPowerSurge(sceneGame,30,getlocal("powerSurgeTitle2"),getlocal("powerSurgeDesc2"),2)
        				    base.nextDay=1
        				else
        				    if base.isNd==1 and award==nil then
        				        popDialog:createPowerSurge(sceneGame,30,getlocal("powerSurgeTitle"),getlocal("powerSurgeDesc"))
        				    end
        				end
    				end
    				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("friend_facebook_loginReward"),nil,2,nil,showRightHandler2)
    			else
    				rightHandler2()
    			end
    		else
    			rightHandler2()
    		end
    	else
    		rightHandler2()
    	end
    end
    
    local rightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rightHandler,2,getlocal("randomMoveIslandOK"),25)
    local rightMenu=CCMenu:createWithItem(rightItem);
    rightMenu:setPosition(ccp(dialogBg:getContentSize().width/2,10))
    rightMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(rightMenu)
  
  	local spriteIcon
  	if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
  		spriteIcon = CCSprite:create("public/woman.png");
		local spScaleX=0.6
	    spriteIcon:setScaleX(spScaleX)
	    spriteIcon:setScaleY(0.7)
		spriteIcon:setFlipX(true)
	    spriteIcon:setPosition(-20+spriteIcon:getContentSize().width/2*spScaleX,dialogBg:getContentSize().height/2)
	else
		spriteIcon = CCSprite:createWithSpriteFrameName("ShapeCharacter.png");
		spriteIcon:setAnchorPoint(ccp(0,0));
		spriteIcon:setPosition(-30,10)
	end
	self.container:addChild(spriteIcon,8)

	local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle,2)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle1,2)

	local spriteShapeAperture = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeAperture:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteShapeAperture,1)

	local spriteShapeEagle = CCSprite:createWithSpriteFrameName("ShapeEagle.png");
	spriteShapeEagle:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeEagle:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-spriteShapeEagle:getContentSize().height/2-60)
	self.container:addChild(spriteShapeEagle,2)


    local function shapeDiaTouch()
    
    end
    local capInSet = CCRect(130, 70, 1, 1)
    local spriteShapeDialog =LuaCCScale9Sprite:createWithSpriteFrameName("ShapeDialog.png",capInSet,shapeDiaTouch);
	--local spriteShapeDialog = CCSprite:createWithSpriteFrameName("ShapeDialog.png");
	spriteShapeDialog:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeDialog:setContentSize(CCSizeMake(430,130));
	spriteShapeDialog:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-90)
	self.container:addChild(spriteShapeDialog,2)

	--[[local spriteShapeDialog = CCSprite:createWithSpriteFrameName("ShapeDialog.png");
	spriteShapeDialog:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeDialog:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-spriteShapeDialog:getContentSize().height/2-90)
	self.container:addChild(spriteShapeDialog,2)]]

	local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeInfor.png");
	spriteShapeInfor:setAnchorPoint(ccp(0.5,0));
	spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2+60,30)
	self.container:addChild(spriteShapeInfor,2)

	local titleLb=GetTTFLabel(getlocal("award"),30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(spriteShapeInfor:getContentSize().width/2,spriteShapeInfor:getContentSize().height+17))
	spriteShapeInfor:addChild(titleLb,2)
	titleLb:setColor(G_ColorYellowPro)
  
	-- local titleDesLb=GetTTFLabel(getlocal("getLotItems"),26)
	local titleDesLb=GetTTFLabelWrap(getlocal("getLotItems"),22,CCSizeMake(310, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	if desc then
		titleDesLb=GetTTFLabelWrap(desc,22,CCSizeMake(310, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	else
		--titleDesLb:setColor(G_ColorYellowPro)
	end
	titleDesLb:setAnchorPoint(ccp(0.5,0.5))
	titleDesLb:setPosition(ccp(spriteShapeDialog:getContentSize().width/2+titleDesLb:getContentSize().width/2-240/2,spriteShapeDialog:getContentSize().height/2))
	spriteShapeDialog:addChild(titleDesLb,2)
  
	--if award then
	if title then
		local tLable=GetTTFLabel(title,30)
		tLable:setAnchorPoint(ccp(0.5,0.5))
		tLable:setPosition(ccp(dialogBg:getContentSize().width/2-60,dialogBg:getContentSize().height-108))
		spriteShapeInfor:addChild(tLable,2)
		tLable:setColor(G_ColorYellowPro)
	end
	if titleLb then
		titleLb:setPosition(ccp(dialogBg:getContentSize().width/2-60,spriteShapeInfor:getContentSize().height+17))	
	end
	if spriteShapeAperture then
		spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	end
	if spriteShapeEagle then
		spriteShapeEagle:setPosition(dialogBg:getContentSize().width/2+20,dialogBg:getContentSize().height-spriteShapeEagle:getContentSize().height/2-60)
	end
	if spriteShapeDialog then
		spriteShapeDialog:setPosition(dialogBg:getContentSize().width/2+20,dialogBg:getContentSize().height-spriteShapeDialog:getContentSize().height/2-93)
	end
	if spriteShapeInfor then
		spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2+0,30)
	end
	if award then
		local awardNum=SizeOfTable(award)
		local function showInfoHandler(hd,fn,idx)
			local item=award[idx]
			if item and item.name and item.pic and item.num and item.desc then
				propInfoDialog:create(sceneGame,item,layerNum+1)
			end
		end
		for k,v in pairs(award) do
			if v and v.pic and v.num then
				local icon
				local pic=v.pic
				--local startIndex,endIndex=string.find(pic,"^rank(%d+).png$")
				local iconScaleX=1
				local iconScaleY=1
				--[[
				if startIndex~=nil and endIndex~=nil then
					icon=GetBgIcon(pic)
				else
				icon = CCSprite:createWithSpriteFrameName(pic)
				]]
				icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
				if icon:getContentSize().width>100 then
					iconScaleX=iconScaleX*100/150
					iconScaleY=iconScaleX*100/150
				end
				icon:setScaleX(iconScaleX)
				icon:setScaleY(iconScaleY)
					--end
				icon:ignoreAnchorPointForPosition(false)
		        icon:setAnchorPoint(ccp(0.5,0.5))
				if awardNum==1 then
					icon:setPosition(ccp(130+icon:getContentSize().width,spriteShapeInfor:getContentSize().height/2+6))
				elseif awardNum==2 then
					icon:setPosition(ccp(170+(icon:getContentSize().width+45)*(k-1),spriteShapeInfor:getContentSize().height/2+6))
				elseif awardNum==3 then
					icon:setPosition(ccp(130+(icon:getContentSize().width+20)*(k-1),spriteShapeInfor:getContentSize().height/2+6))
				end
				icon:setIsSallow(false)
				icon:setTouchPriority(-(layerNum-1)*20-2)
		        spriteShapeInfor:addChild(icon,1)
				icon:setTag(k)
		
				local numLabel=GetTTFLabel("x"..v.num,25)
		        --numLabel:setColor(G_ColorGreen)
				numLabel:setAnchorPoint(ccp(1,0))
				numLabel:setPosition(icon:getContentSize().width-5,0)
				icon:addChild(numLabel,1)
				numLabel:setScaleX(1/iconScaleX)
				numLabel:setScaleY(1/iconScaleY)
			end
		end
	else
		for i=1,3,1 do
			local nameStr=nil
			local numLbStr=nil
			if i==1 then
				nameStr="TankLv3.png"
				numLbStr="×1"
			elseif i==2 then
				nameStr="RocketLv3.png"
				numLbStr="×1"
			elseif i==3 then
				nameStr="Icon_novicePacks.png"
				numLbStr="×1"
			end

			local spriteIcon = CCSprite:createWithSpriteFrameName("Icon_buff1.png");
			spriteIcon:setAnchorPoint(ccp(0.5,0.5));
			spriteIcon:setPosition(130+(spriteIcon:getContentSize().width+15)*(i-1),spriteShapeInfor:getContentSize().height/2+6);
			spriteShapeInfor:addChild(spriteIcon,2);
			local numLb=GetTTFLabel(numLbStr,20)
			numLb:setAnchorPoint(ccp(1,0));
			numLb:setPosition(ccp(spriteIcon:getContentSize().width-8,4));
			spriteIcon:addChild(numLb,2);
    
 		   	local sp=CCSprite:createWithSpriteFrameName(nameStr);
  		  	if i==1 or i==2 then
				local scale=100/sp:getContentSize().width
				sp:setScale(scale)
  		  	end
  		  	sp:setPosition(ccp(spriteIcon:getContentSize().width/2,spriteIcon:getContentSize().height/2))
  		  	spriteIcon:addChild(sp)
		end
	end


    self.container:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.container,layerNum+1)
    self:show()


end

function popDialog:initPowerSurge(parent,layerNum,title,desc,award)
    local function touchDialog()
          
    end

    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 50, 1, 1)
    local capInSet1 = CCRect(10, 10, 1, 1)


    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    dialogBg:setContentSize(CCSizeMake(600,500))
    self.container=dialogBg
    
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,layerNum);
    
    local function rightHandler()
        PlayEffect(audioCfg.mouseClick)
        self:close()
        if award==2 then
            local function callback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then

                    mainUI:showAct()
                    if platCfg.platBeimeiNewGuide[G_curPlatName()]==nil then
                        if dailyVoApi:isFreeByType(1) and newGuidMgr:isNewGuiding()==false then
                            if G_isIOS()==true then
								  if G_getBHVersion() ==1 then
                                      require "luascript/script/game/scene/gamedialog/dailyDialog"
								      local dd = dailyDialog:new()
								  	  local tbArr={getlocal("lotteryCommon"),getlocal("lotterySenior")}
								      local vd = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("daily_scene_title"),true,3);
								      sceneGame:addChild(vd,3);
								  elseif G_getBHVersion() ==2 then
                                    require "luascript/script/game/scene/gamedialog/dailyTwoDialog"
								    local dd = dailyTwoDialog:new()
								    local dailyTwo = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("dailyUseIt"),true,3);
								    sceneGame:addChild(dailyTwo,3);
								  end                          
                                -- local dd = dailyDialog:new()
                                -- local tbArr={getlocal("lotteryCommon"),getlocal("lotterySenior")}
                                -- local vd = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("daily_scene_title"),true,3);
                                -- sceneGame:addChild(vd,3);
                                mainUI.m_isShowDaily=true

                            end
                        end
                    end

                    smallDialog:showPowerChangeEffect(sData.data.oldfc,sData.data.newfc)

                        local name1=getlocal(tankCfg[10002].name).."*30"
                        local name2=getlocal(tankCfg[10012].name).."*20"
                        local name3=getlocal(tankCfg[10022].name).."*10"
                        local name4=getlocal(tankCfg[10032].name).."*10"
                        local award=name1..name2..name3..name4
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),award,30)
                end

            end
            socketHelper:userNextdayReward(callback)
        else
        	newGuidMgr:showNewStageEndGuid()
            local menuItem=mainUI.m_functionBtnTb["b1"]
            if(menuItem~=nil)then
                G_addFlicker(menuItem,2,2)
            end
        end
    end
    local buttonStr
    if award==2 then
        buttonStr=getlocal("daily_scene_get")
    else
        buttonStr=getlocal("randomMoveIslandOK")
    end

    local rightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rightHandler,2,buttonStr,25)
    local rightMenu=CCMenu:createWithItem(rightItem);
    rightMenu:setPosition(ccp(dialogBg:getContentSize().width/2,10))
    rightMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(rightMenu)
  
	local spriteIcon = CCSprite:create("public/woman.png");
	spriteIcon:setAnchorPoint(ccp(0,0));
	spriteIcon:setPosition(20,170)
    spriteIcon:setScale(0.56)
    spriteIcon:setFlipX(true)
	self.container:addChild(spriteIcon,8)

	local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
	spriteTitle:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle,2)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteTitle1,2)

	local spriteShapeAperture = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeAperture:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	self.container:addChild(spriteShapeAperture,1)

	local spriteShapeEagle = CCSprite:createWithSpriteFrameName("ShapeEagle.png");
	spriteShapeEagle:setAnchorPoint(ccp(0.5,0.5));
	spriteShapeEagle:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-spriteShapeEagle:getContentSize().height/2-60)
	self.container:addChild(spriteShapeEagle,2)
    
    local function shapeDiaTouch()
    
    end
    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 70, 1, 1)
    local capInSet1 = CCRect(10, 10, 1, 1)
    local spriteShapeDialog =LuaCCScale9Sprite:createWithSpriteFrameName("ShapeDialog.png",capInSet,shapeDiaTouch);
	--local spriteShapeDialog = CCSprite:createWithSpriteFrameName("ShapeDialog.png");
	spriteShapeDialog:setAnchorPoint(ccp(0.5,0.5));
    spriteShapeDialog:setContentSize(CCSizeMake(430,180));
	spriteShapeDialog:setPosition(dialogBg:getContentSize().width/2+60,dialogBg:getContentSize().height-200)
	self.container:addChild(spriteShapeDialog,2)

	local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeInfor.png");
	spriteShapeInfor:setAnchorPoint(ccp(0.5,0));
	spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2+60,30)
	self.container:addChild(spriteShapeInfor,2)

	local titleLb=GetTTFLabel(getlocal("powerSurgeHelp"),30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(spriteShapeInfor:getContentSize().width/2,spriteShapeInfor:getContentSize().height+17))
	spriteShapeInfor:addChild(titleLb,2)
	titleLb:setColor(G_ColorYellowPro)
  
	-- local titleDesLb=GetTTFLabel(getlocal("getLotItems"),26)
	local titleDesLb=GetTTFLabelWrap(getlocal("powerSurgeDesc"),22,CCSizeMake(310, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	if desc then
		titleDesLb=GetTTFLabelWrap(desc,22,CCSizeMake(310, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	else
		--titleDesLb:setColor(G_ColorYellowPro)
	end
	titleDesLb:setAnchorPoint(ccp(0.5,0.5))
	titleDesLb:setPosition(ccp(spriteShapeDialog:getContentSize().width/2+titleDesLb:getContentSize().width/2-240/2,spriteShapeDialog:getContentSize().height/2))
	spriteShapeDialog:addChild(titleDesLb,2)
  
	--if award then
	if title then
		local tLable=GetTTFLabel(title,30)
		tLable:setAnchorPoint(ccp(0.5,0.5))
		tLable:setPosition(ccp(dialogBg:getContentSize().width/2-60,dialogBg:getContentSize().height-108))
		spriteShapeInfor:addChild(tLable,2)
		tLable:setColor(G_ColorYellowPro)
	end
	if titleLb then
		titleLb:setPosition(ccp(dialogBg:getContentSize().width/2-60,spriteShapeInfor:getContentSize().height+17))	
	end
	if spriteShapeAperture then
		spriteShapeAperture:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
	end
	if spriteShapeEagle then
		spriteShapeEagle:setPosition(dialogBg:getContentSize().width/2+20,dialogBg:getContentSize().height-spriteShapeEagle:getContentSize().height/2-60)
	end
    --[[
	if spriteShapeDialog then
		spriteShapeDialog:setPosition(dialogBg:getContentSize().width/2+20,dialogBg:getContentSize().height-spriteShapeDialog:getContentSize().height/2-93)
	end
    ]]
	if spriteShapeInfor then
		spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2+0,30)
	end
    for i=1,4,1 do
        local nameStr=nil
        local numLbStr=nil
        if i==1 then
            nameStr="TankLv2.png"
            numLbStr="×30"
        elseif i==2 then
            nameStr="WeaponLv2.png"
            numLbStr="×20"
        elseif i==3 then
            nameStr="ArtilleryLv2.png"
            numLbStr="×10"
        elseif i==4 then
            nameStr="RocketLv2.png"
            numLbStr="×10"
        end

        local spriteIcon = CCSprite:createWithSpriteFrameName("Icon_buff1.png");
        spriteIcon:setAnchorPoint(ccp(0.5,0.5));
        spriteIcon:setPosition(70+(spriteIcon:getContentSize().width+15)*(i-1),spriteShapeInfor:getContentSize().height/2+6);
        spriteShapeInfor:addChild(spriteIcon,2);
        local numLb=GetTTFLabel(numLbStr,20)
        numLb:setAnchorPoint(ccp(1,0));
        numLb:setPosition(ccp(spriteIcon:getContentSize().width-8,4));
        spriteIcon:addChild(numLb,2);

        local sp=CCSprite:createWithSpriteFrameName(nameStr);
        --if i==1 or i==2 then
            local scale=100/sp:getContentSize().width
            sp:setScale(scale)
        --end
        sp:setPosition(ccp(spriteIcon:getContentSize().width/2,spriteIcon:getContentSize().height/2))
        spriteIcon:addChild(sp)
    end


    self.container:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.container,layerNum+1)
    self:show()

end

-- 在线礼包奖励面板
function popDialog:initOnlinePackage(parent, layerNum, award)
	local function touchDialog()
          
    end

    local capInSet = CCRect(168, 86, 10, 10)
    local capInSet1 = CCRect(10, 10, 1, 1)


    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("yh_PanelHeaderPopup.png",capInSet,touchDialog);
    dialogBg:setContentSize(CCSizeMake(600,500))
    self.container=dialogBg
    
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,layerNum)


	local tLable=GetTTFLabel(getlocal("onlinePackage_title"),32,true)
	tLable:setAnchorPoint(ccp(0.5,0.5))
	tLable:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-45))
	dialogBg:addChild(tLable,2)

	local function close()
        PlayEffect(audioCfg.mouseClick)    
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0,0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    closeBtn:setPosition(ccp(dialogBg:getContentSize().width-closeBtnItem:getContentSize().width,dialogBg:getContentSize().height-closeBtnItem:getContentSize().height))
    dialogBg:addChild(closeBtn)


	local dLable=GetTTFLabelWrap(getlocal("onlinePackage_next_title"),24,CCSizeMake(dialogBg:getContentSize().width-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	dLable:setAnchorPoint(ccp(0.5,0.5))
	dLable:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-115))
	dialogBg:addChild(dLable,3)
	dLable:setColor(G_ColorYellowPro)
    
    -- 时间
    local function cellClick( ... )
    end

    local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(141, 15, 146, 17),cellClick)
    timeBg:setContentSize(CCSizeMake(300, 60))
    timeBg:setAnchorPoint(ccp(0.5,0.5))
    timeBg:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height/2 + 70))
    dialogBg:addChild(timeBg,4)
    
    local showTime = GetTimeForItemStrState(playerVoApi:getLastNeedOnlineTime())
    local timeLable=GetTTFLabel(tostring(showTime),24)
	timeLable:setAnchorPoint(ccp(0.5,0.5))
	timeLable:setPosition(ccp(timeBg:getContentSize().width/2,timeBg:getContentSize().height/2))
	timeBg:addChild(timeLable)
	timeLable:setColor(G_ColorYellowPro)

    -- 奖励背景条

    local spriteShapeInfor = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),cellClick)
    spriteShapeInfor:setContentSize(CCSizeMake(dialogBg:getContentSize().width-60,150))
    spriteShapeInfor:setTouchPriority(-(layerNum-1)*20-2)
	spriteShapeInfor:setAnchorPoint(ccp(0.5,0));
	spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2,110)
	self.container:addChild(spriteShapeInfor,2)
    
	-- 显示奖励图标
	local infoCenter = spriteShapeInfor:getContentSize().height/2
    local award = FormatItem(playerVoApi:getOnlineAward(), true) -- 需要根据阶段动态获取
    local iconX = 0
    if award ~= nil then
    	-- local oneLen = spriteShapeInfor:getContentSize().width/SizeOfTable(award)
    	local oneLen = 120
    	local firstX = (spriteShapeInfor:getContentSize().width - oneLen * SizeOfTable(award))/2
       for k,v in pairs(award) do
	        local icon, iconScale = G_getItemIcon(v, 100, true, layerNum)
	        iconX = (k-1) * oneLen + oneLen/2 + firstX
	        icon:ignoreAnchorPointForPosition(false)
	        icon:setAnchorPoint(ccp(0.5,0.5))
	        icon:setIsSallow(false)
	        icon:setTouchPriority(-(layerNum-1)*20-3)
	        icon:setPosition(ccp(iconX, infoCenter+10))
		    spriteShapeInfor:addChild(icon,1)
	        icon:setTag(k)

	        if tostring(v.name)~=getlocal("honor") then
	          local numLabel=GetTTFLabel("x"..v.num,25)
	          numLabel:setAnchorPoint(ccp(0.5,0))
	          numLabel:setPosition(iconX,10)
	          spriteShapeInfor:addChild(numLabel,1)
	        end
        end
    end

    self.updateOnline = {timeLable = timeLable, layerNum =layerNum} -- 要更新的东西
    self:updateOnlineBtn()

	self.container:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.container,layerNum+1)
    self:show()
end

function popDialog:updateOnlineBtn()
	if self.updateOnline == nil or self.updateOnline.layerNum == nil or self.container == nil then
		return
	end

	local function rightHandler()
        PlayEffect(audioCfg.mouseClick)
        self:close()
        if playerVoApi:getLastNeedOnlineTime() == 0 then
            local function callback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                	  local reward = FormatItem(playerVoApi:getOnlineAward(), true)
			          for k,v in pairs(reward) do
			            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
			          end
			          G_showRewardTip(reward,true)

                	  playerVoApi:afterGetOnlinePackageAward()
                end

            end
            local needTime = playerVoApi:getOnLinePackageNeedTime()
            if needTime ~= -1 then
            	socketHelper:getOnlinePackage(needTime, callback)
            end 
        end
    end
    local buttonStr
    local rightItem
    local btnFlag
    if playerVoApi:getLastNeedOnlineTime() == 0 then
        buttonStr=getlocal("daily_scene_get")
        rightItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rightHandler,2,buttonStr,24,100)
        btnFlag = 0
    else
        buttonStr=getlocal("randomMoveIslandOK")
        rightItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rightHandler,2,buttonStr,24,100)
        btnFlag = 1
    end
    local lb = rightItem:getChildByTag(100)
    if lb then
    	lb = tolua.cast(lb,"CCLabelTTF")
    	lb:setFontName("Helvetica-bold")
    end
    self.updateOnline.btnFlag = btnFlag
    local layerNum = self.updateOnline.layerNum
    local rightMenu=CCMenu:createWithItem(rightItem);
    rightMenu:setPosition(ccp(self.container:getContentSize().width/2,50))
    rightMenu:setTouchPriority(-(layerNum-1)*20-3);
    self.container:addChild(rightMenu,5)
end

function popDialog:updateOnlinePackage()
	if playerVoApi:checkIfGetAllOnlinePackage() == false and self.updateOnline ~= nil then
		local timeLable = self.updateOnline.timeLable
		local btnFlag = self.updateOnline.btnFlag
		if playerVoApi:getLastNeedOnlineTime() == 0 and btnFlag ~= 0 then
           self:updateOnlineBtn()
        end
        -- local showTime = G_getTimeStr(playerVoApi:getLastNeedOnlineTime())
        local showTime = GetTimeForItemStrState(playerVoApi:getLastNeedOnlineTime())
        timeLable:setString(tostring(showTime))
    end
end

--显示面板,加效果
function popDialog:show()

    --if self.isUseAmi~=nil then
       local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
       local function callBack()
           base:cancleWait()
       end
       local callFunc=CCCallFunc:create(callBack)
       
       local scaleTo1=CCScaleTo:create(0.1, 1.1);
       local scaleTo2=CCScaleTo:create(0.07, 1);

       local acArr=CCArray:create()
       acArr:addObject(scaleTo1)
       acArr:addObject(scaleTo2)
       acArr:addObject(callFunc)
        
       local seq=CCSequence:create(acArr)
       self.container:runAction(seq)
   --end
   
   table.insert(G_SmallDialogDialogTb,self)
end

function popDialog:close()
	self.updateOnline = nil
	self:setIsShow(false)
    if self.isUseAmi~=nil and self.container then
    	local function realClose()
    		self.touchDialogBg:removeFromParentAndCleanup(true)
    		return self:realClose()
    	end
    	local fc= CCCallFunc:create(realClose)
    	local scaleTo1=CCScaleTo:create(0.1, 1.1);
    	local scaleTo2=CCScaleTo:create(0.07, 0.8);
    	local acArr=CCArray:create()
    	acArr:addObject(scaleTo1)
    	acArr:addObject(scaleTo2)
    	acArr:addObject(fc)
    	local seq=CCSequence:create(acArr)
    	self.container:runAction(seq)
    else
    	self:realClose()
    end
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
end
function popDialog:realClose()
    base.allShowedSmallDialog=base.allShowedSmallDialog-1
    if self.container and tolua.cast(self.container,"LuaCCScale9Sprite") then
    	self.container:removeFromParentAndCleanup(true)
    end
    self.container=nil
end
function popDialog:tick()

    
end

function popDialog:dispose() --释放方法

 self.touchDialogBg=nil
    self.container=nil
    for k,v in pairs(self.pp4) do
         k=nil
         v=nil
    end

    self.have4=nil
end
