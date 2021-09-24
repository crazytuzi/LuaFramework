acTenxunhuodongDialog=commonDialog:new()

function acTenxunhuodongDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.expandIdx={}
    self.layerNum=layerNum    
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")
    return nc
end

--设置或修改每个Tab页签
function acTenxunhuodongDialog:resetTab()

    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

function acTenxunhuodongDialog:initTableView()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    self:initBgLayer()

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-640),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,40))
    self.bgLayer:addChild(self.tv)

    self.tv:setMaxDisToBottomOrTop(120)
end

function acTenxunhuodongDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(620,160)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease() 
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10)

        local function cellClick()
        end

        local function touch()
        end
        local tabStr=""
        local titleStr=""
        local desStr=""
        if idx==0 then
            tabStr="第一步"
            titleStr="下载QQ空间"
            desStr="下载并安装QQ空间客户端！"
        elseif idx==1 then
            tabStr="第二步"
            titleStr="登录QQ空间"
            desStr="启动QQ空间，并使用当前游戏QQ登录，并保持在线状态。"
        else
            tabStr="第三步"
            titleStr="登录QQ空间"
            desStr="回到游戏，领取奖励（每个QQ号限领一次）。"
        end

        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(600, 110))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)  
		cell:addChild(backSprie) 



        local titleItem=GetButtonItem("RankBtnTab_Down.png", "RankBtnTab_Down.png","RankBtnTab_Down.png",touch,1,tabStr,20)
        local recruitMenu=CCMenu:createWithItem(titleItem)
        recruitMenu:setPosition(ccp(titleItem:getContentSize().width/2,backSprie:getContentSize().height+titleItem:getContentSize().height/2))
        recruitMenu:setTouchPriority(-(self.layerNum-1)*20-1)
        cell:addChild(recruitMenu,3)

        local titleLabel = GetTTFLabelWrap(titleStr,25,CCSizeMake(580,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        titleLabel:setAnchorPoint(ccp(0,1))
        backSprie:addChild(titleLabel)
        titleLabel:setPosition(ccp(10,backSprie:getContentSize().height-15))
        titleLabel:setColor(G_ColorYellowPro)

        local desLabel = GetTTFLabelWrap(desStr,25,CCSizeMake(580,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLabel:setAnchorPoint(ccp(0,1))
        backSprie:addChild(desLabel)
        desLabel:setPosition(ccp(10,backSprie:getContentSize().height-50))

        local lineSp =CCSprite:createWithSpriteFrameName("heroRecruitLine.png") 
		lineSp:setRotation(180)
		lineSp:setAnchorPoint(ccp(1,1))
		backSprie:addChild(lineSp)
		lineSp:setPosition(0,backSprie:getContentSize().height-50) 
		lineSp:setScaleX(backSprie:getContentSize().width/lineSp:getContentSize().width)		

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function acTenxunhuodongDialog:initBgLayer()
	local background=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function ( ... )end)
	background:setAnchorPoint(ccp(0,1))
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,210))
	background:setPosition(ccp(20,G_VisibleSizeHeight - 100))
	self.bgLayer:addChild(background)

	local backgroundSize = background:getContentSize()
	local timeTitle = GetTTFLabel("活动时间",25)
	-- background:addChild(timeTitle)
	timeTitle:setAnchorPoint(ccp(0.5,1))
	timeTitle:setPosition(ccp(backgroundSize.width/2,backgroundSize.height-10))
	timeTitle:setColor(G_ColorGreen)

	local timeLabel = GetTTFLabel("2014/03/20-2014/03/22",25)
	-- background:addChild(timeLabel)
	timeLabel:setPosition(ccp(backgroundSize.width/2,backgroundSize.height-55))
	timeTitle:setAnchorPoint(ccp(0.5,1))

	local kongjianSp = CCSprite:create("public/kongjian.png")
	kongjianSp:setAnchorPoint(ccp(0,0.5))
	background:addChild(kongjianSp)
	kongjianSp:setPosition(ccp(15,backgroundSize.height/2))
	kongjianSp:setScale(1.5)

	local kongjianBg = CCSprite:createWithSpriteFrameName("heroHead1.png")
	kongjianBg:setAnchorPoint(ccp(0,0.5))
	background:addChild(kongjianBg)
	kongjianBg:setPosition(ccp(15,backgroundSize.height/2))

	local shareLabel = GetTTFLabel("分享生活",40)
	background:addChild(shareLabel)
	shareLabel:setAnchorPoint(ccp(0.5,1))
	shareLabel:setPosition(ccp(backgroundSize.width/2+50,backgroundSize.height-50))

	local affectLabel = GetTTFLabel("留住感动",40)
	affectLabel:setAnchorPoint(ccp(0.5,1))
	background:addChild(affectLabel)
	affectLabel:setPosition(ccp(backgroundSize.width/2+130,backgroundSize.height-110))

    local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    descBg:setContentSize(CCSizeMake(460,190))
    descBg:setAnchorPoint(ccp(0,0))
    descBg:setPosition(ccp(160,G_VisibleSizeHeight-540))
    self.bgLayer:addChild(descBg)


    local womanSp=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
    womanSp:setAnchorPoint(ccp(0,0))
    womanSp:setPosition(ccp(10,G_VisibleSizeHeight-540))
    womanSp:setScale(0.8)
    self.bgLayer:addChild(womanSp)

    -- 添加光亮线
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
  	lineSp:setAnchorPoint(ccp(0,0));
  	lineSp:setPosition(ccp(10,G_VisibleSizeHeight-548));
  	self.bgLayer:addChild(lineSp,1)

    local desBgSize = descBg:getContentSize()
    local desLabel = GetTTFLabel("参与活动即可获得：",25)
    descBg:addChild(desLabel)
    desLabel:setPosition(ccp(desBgSize.width/2,desBgSize.height-20))
    desLabel:setAnchorPoint(ccp(0.5,1))

    local wd = 90
    local hd = 20
    local item1={}
    item1.type = "p"
	item1.key = "p20"
    item1.name,item1.pic,item1.desc,item1.id = getItem(item1.key,item1.type)
    item1.num = 6
    local function touchDaoju1()
    	propInfoDialog:create(sceneGame,item1,self.layerNum+1)
    end
	local daoju1 = LuaCCSprite:createWithSpriteFrameName(item1.pic,touchDaoju1)
	daoju1:setTouchPriority(-(self.layerNum-1)*20-4)
	daoju1:setAnchorPoint(ccp(0,0))
	daoju1:setPosition(ccp(wd,hd))
	daoju1:setScale(0.8)
	descBg:addChild(daoju1)
	G_addRectFlicker(daoju1,1.3,1.3)

	-- G_getItemIcon(getItem("p20","p"),)

	local daojuSize = daoju1:getContentSize()

	local daojuLa1 = GetTTFLabel("X6",25)
	daoju1:addChild(daojuLa1)
	daojuLa1:setAnchorPoint(ccp(1,0))
	daojuLa1:setPosition(ccp(daojuSize.width-10,5))

	local item2={}
	item2.type = "p"
	item2.key = "p292"
    item2.name,item2.pic,item2.desc,item2.id = getItem(item2.key,item2.type)
    item2.num = 5
    local function touchDaoju2()
    	propInfoDialog:create(sceneGame,item2,self.layerNum+1)
    end
	local daoju2 = LuaCCSprite:createWithSpriteFrameName(item2.pic,touchDaoju2)
	daoju2:setTouchPriority(-(self.layerNum-1)*20-4)
	daoju2:setAnchorPoint(ccp(0,0))
	daoju2:setScale(0.8)
	daoju2:setPosition(ccp(wd+daojuSize.width-10,hd))
	descBg:addChild(daoju2)
	G_addRectFlicker(daoju2,1.3,1.3)

	local daojuLa2 = GetTTFLabel("X5",25)
	daoju2:addChild(daojuLa2)
	daojuLa2:setAnchorPoint(ccp(1,0))
	daojuLa2:setPosition(ccp(daojuSize.width-10,5))


	local item3={}
	item3.type = "p"
	item3.key = "p17"
    item3.name,item3.pic,item3.desc,item3.id = getItem(item3.key,item3.type )
    item3.num = 2
    local function touchDaoju3()
    	propInfoDialog:create(sceneGame,item3,self.layerNum+1)
    end
	local daoju3 = LuaCCSprite:createWithSpriteFrameName(item3.pic,touchDaoju3)
	daoju3:setTouchPriority(-(self.layerNum-1)*20-4)
	daoju3:setAnchorPoint(ccp(0,0))
	daoju3:setScale(0.8)
	daoju3:setPosition(ccp(wd+(daojuSize.width-10)*2,hd))
	descBg:addChild(daoju3)
	G_addRectFlicker(daoju3,1.3,1.3)

	local daojuLa3 = GetTTFLabel("X2",25)
	daoju3:addChild(daojuLa3)
	daojuLa3:setAnchorPoint(ccp(1,0))
	daojuLa3:setPosition(ccp(daojuSize.width-10,5))

	local item4={}
	item4.type = "p"
	item4.key = "p12"
    item4.name,item4.pic,item4.desc,item4.id = getItem(item4.key,item4.type)
    item4.num = 1
    local function touchDaoju4()
    	propInfoDialog:create(sceneGame,item4,self.layerNum+1)
    end
	local daoju4 = LuaCCSprite:createWithSpriteFrameName(item4.pic,touchDaoju4)
	daoju4:setTouchPriority(-(self.layerNum-1)*20-4)
	daoju4:setAnchorPoint(ccp(0,0))
	daoju4:setScale(0.8)
	daoju4:setPosition(ccp(wd+(daojuSize.width-10)*3,hd))
	descBg:addChild(daoju4)
	G_addRectFlicker(daoju4,1.3,1.3)

	local daojuLa4 = GetTTFLabel("X1",25)
	daoju4:addChild(daojuLa4)
	daojuLa4:setAnchorPoint(ccp(1,0))
	daojuLa4:setPosition(ccp(daojuSize.width-10,5))


    local widthButton = 200
    local rect = CCRect(44,33,1,1)
    local function nilFunc()
    end
	local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
	local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue2.png",rect,nilFunc)
	local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
	sNormal:setContentSize(CCSizeMake(widthButton,60))
	sSelected:setContentSize(CCSizeMake(widthButton,60))
	sDisabled:setContentSize(CCSizeMake(widthButton,60))

	local function settingHandler()
		PlayEffect(audioCfg.mouseClick)
		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
			 if ret==true then 
                if sData.data==nil then 
                  return
                end
				local tmpTb={}
		        tmpTb["action"]="openUrl"
		        tmpTb["parms"]={}
		        tmpTb["parms"]["url"]="http://fusion.qq.com/cgi-bin/qzapps/unified_jump?appid=9959&from=mqq&actionFlag=0&params=pname%3Dcom.qzone%26versioncode%3D80%26channelid%3D%26actionflag%3D0"
		        local cjson=G_Json.encode(tmpTb)
		        G_accessCPlusFunction(cjson)
		        self:close()
		        require "luascript/script/game/scene/gamedialog/acTenxunhuodongPopDialog"
		        acTenxunhuodongPopDialog:createPowerSurge(sceneGame,30,"下载注册送豪礼","恭喜您成功安装QQ空间客户端，并获得了以下奖励！",2)
		        playerVoApi:setQQ(1)
		        G_addPlayerAward(item1.type,item1.key,item1.id,item1.num,nil,true)
		        G_addPlayerAward(item2.type,item2.key,item2.id,item2.num,nil,true)
		        G_addPlayerAward(item3.type,item3.key,item3.id,item3.num,nil,true)
		        G_addPlayerAward(item4.type,item4.key,item4.id,item4.num,nil,true)
		    end
	    end
	    socketHelper:activityGetqqreward(callback)

	end
	local item = CCMenuItemSprite:create(sNormal, sSelected, sDisabled)  
	item:registerScriptTapHandler(settingHandler)
	-- item:setEnabled(false)

	local titleLb=GetTTFLabel("立即下载",28)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(getCenterPoint(item))
	item:addChild(titleLb)

	local settingsBtn = CCMenu:createWithItem(item)
	settingsBtn:setPosition(ccp(510,G_VisibleSizeHeight-568))
	settingsBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(settingsBtn)   
end

function acTenxunhuodongDialog:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/heroRecruitImage.plist")
end