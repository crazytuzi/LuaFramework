-- @Author hj
-- @Date 2018-11-14
-- @Description 新的军团界面改版

newAllianceDialog = commonDialog:new()

function newAllianceDialog:new( ... )
	-- body
	local nc = {
		functionTb = {},
		functionBg = {},
		btnTb = {},
		allianceInfoLabelTb = {}
	}
	setmetatable(nc,self)
	self.__index = self

    self.bannerOld = ""

	return nc
end


function newAllianceDialog:doUserHandler( ... )

	require "luascript/script/game/gamemodel/alliance/allianceShopVoApi"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFuDialog"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceGiftDialog"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSkillDialog"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceEventDialog"
	require "luascript/script/game/scene/gamedialog/allianceDialog/setGarrisonDialog"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceHelpDialog"
	require "luascript/script/game/scene/gamedialog/allianceDialog/rebelDialog"

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/slotMachine.plist")


    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
	spriteController:addPlist("public/juntuanCityBtns.plist")
    spriteController:addTexture("public/juntuanCityBtns.png")

    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    spriteController:addPlist("public/newAlliance.plist")
	spriteController:addPlist("public/believer/believerMain.plist")
	spriteController:addTexture("public/believer/believerMain.png")
	spriteController:addTexture("public/newAlliance.png")
	
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)


    if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end

	if self.panelTopLine then
		self.panelTopLine:setVisible(false)
	end

	local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82)
    self.bgLayer:addChild(tabLine,5)

    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)

    self:initUpAttr()
    self:initFunctionTb()

    for i=1,4 do
    	local function infoCallback()
    		self:infoCallback(i)
    	end
    	local str = self:getBtnImg(i)
    	local infoButton,infoButtonMenu =  G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/8+G_VisibleSizeWidth/4*(i-1),135/2),nil,str..".png",str.."_down.png",str..".png",infoCallback,1,-(self.layerNum-1)*20-4,10)
    	if i == 3 then
    		self.welfareBtn = infoButton
    	end
    	if i == 4 then
    		-- 红点提示
	    	local numHeight=25
	  		local iconWidth=36
	  		local iconHeight=36
	    	local newsNumLabel = GetTTFLabel("0",numHeight)
	    	newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
	    	newsNumLabel:setTag(11)
	      	local capInSet1 = CCRect(17, 17, 1, 1)
	      	local function touchClick()
	      	end
	      	local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
	  		if newsNumLabel:getContentSize().width+10>iconWidth then
	    		iconWidth=newsNumLabel:getContentSize().width+10
	  		end
	      	newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
	    	newsIcon:ignoreAnchorPointForPosition(false)
	    	newsIcon:setAnchorPoint(CCPointMake(1,0.5))
	      	newsIcon:setPosition(ccp(infoButton:getContentSize().width+5,infoButton:getContentSize().height-15))
	      	newsIcon:addChild(newsNumLabel,1)
	  		newsIcon:setTag(10)
	    	newsIcon:setVisible(false)
	    	infoButton:addChild(newsIcon)
    		self.btnItem = infoButton	    	
    	end
    	self.btnTb[i] = infoButtonMenu
    end
    self:relocalteBtn()
    self:refreshTips()
    self:refreshGift()
end

function newAllianceDialog:getBtnImg(i)
	local str
	if i == 1 then
		str = "newAllianceExit"
	elseif i == 2 then
		str = "newAllianceEdit"
	elseif i == 3 then
		str = "newAllianceActive"
	else
		str = "newAllianceMember"
	end
	return str
end


function newAllianceDialog:relocalteBtn( ... )
	local alliance = allianceVoApi:getSelfAlliance()
	if tostring(alliance.role)=="1" or tostring(alliance.role)=="2" then
		local pos = ccp(0,0)
		for i=1,4 do
			if FuncSwitchApi:isEnabled("alliance_active") == false then --怀旧服不开军团活跃
				local px = {G_VisibleSizeWidth/2-180,G_VisibleSizeWidth/2,9999,G_VisibleSizeWidth/2+180}
				pos = ccp(px[i],135/2)
			else
				pos = ccp(G_VisibleSizeWidth/8+G_VisibleSizeWidth/4*(i-1),135/2)
			end
			if self.btnTb[i] and tolua.cast(self.btnTb[i],"CCMenu") then
				tolua.cast(self.btnTb[i],"CCMenu"):setPosition(pos)
			end
		end
    else
    	local px={G_VisibleSizeWidth/6+G_VisibleSizeWidth/3*(1-1),9999,G_VisibleSizeWidth/6+G_VisibleSizeWidth/3*(2-1),G_VisibleSizeWidth/6+G_VisibleSizeWidth/3*(3-1)}
    	if FuncSwitchApi:isEnabled("alliance_active") == false then
    		px={G_VisibleSizeWidth/2-120,9999,9999,G_VisibleSizeWidth/2+120}
    	end
    	for i=1,4 do
    		if self.btnTb[i] and tolua.cast(self.btnTb[i],"CCMenu") then
				tolua.cast(self.btnTb[i],"CCMenu"):setPosition(ccp(px[i],135/2))
			end 	
    	end
	end
end

-- 初始化军团功能表
function newAllianceDialog:initFunctionTb()

	-- 军团商店
	local function callBack1()
	    if base.ifAllianceShopOpen==0 then
	        do
	          return
	     	end
	    end
	    allianceShopVoApi:showShopDialog(self.layerNum+1)
	end 

	-- 军团科技
	local function callBack2()
	  	local td=allianceSkillDialog:new(self.layerNum+1)
	  	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_technology"),true,self.layerNum+1)
	  	sceneGame:addChild(dialog,self.layerNum+1)
	end 

	-- 军团副本
	local function callBack3()
	  	local td=allianceFuDialog:new(self.layerNum+1)
	  	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_duplicate"),true,self.layerNum+1)
	  	sceneGame:addChild(dialog,self.layerNum+1)
	end 

	-- 军团事件
	local function callBack4()
	  	local td=allianceEventDialog:new(self.layerNum+1)
	  	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_scene_event_title"),true,self.layerNum+1)
	  	sceneGame:addChild(dialog,self.layerNum+1)
	end 

	-- 驻防接收
	local function callBack5()
	  	local td = setGarrsionDialog:new(self.layerNum+1)
	  	local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("alliance_setGarrsion"),true,self.layerNum+1)
	  	sceneGame:addChild(dialog,self.layerNum+1)
	end 

	-- 军团协助
	local function callBack6()
	  	local td = allianceHelpDialog:new(self.layerNum+1)
	  	local tbArr={getlocal("alliance_help_tab1"),getlocal("alliance_help_tab2"),getlocal("alliance_help_tab3")}
	  	local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("alliance_help"),true,self.layerNum+1)
	  	sceneGame:addChild(dialog,self.layerNum+1)
	end 

	-- 叛军详情
	local function callBack7()
	  	local td = rebelDialog:new(self.layerNum+1)
	  	local tbArr={}
	  	local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("alliance_rebel_info"),true,self.layerNum+1)
	  	sceneGame:addChild(dialog,self.layerNum+1)
	end 

	-- 军团城市
	local function callBack8()
		allianceCityVoApi:showAllianceCityDialog(self.layerNum+1)
	end 

	--军团礼包
	local function callBack9( )
		local td = allianceGiftDialog:new(self.layerNum+1)
	  	local tbArr={}
	  	local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("alliance_gift"),true,self.layerNum+1)
	  	sceneGame:addChild(dialog,self.layerNum+1)
	end 

	self.functionTb={
	  {icon="newAlliance_shop.png",nameKey="allianceShop",descKey="alliance_function_desc1",callBack=callBack1,index=4},
	  {icon="newAlliance_technology.png",nameKey="alliance_technology",descKey="alliance_function_desc2",callBack=callBack2,index=2},
	  {icon="newAlliance_battle.png",nameKey="alliance_duplicate",descKey="alliance_function_desc3",callBack=callBack3,index=1},
	  {icon="newAlliance_accident.png",nameKey="alliance_scene_event_title",descKey="alliance_function_desc4",callBack=callBack4,index=7},
	}

	if base.allianceHelpSwitch==1 then
	    local hData={icon="newAlliance_help.png",nameKey="alliance_help",descKey="alliance_function_desc6",callBack=callBack6,index=6}
	    table.insert(self.functionTb,hData)
	end

	if base.isRebelOpen==1 then
		local rebData={icon="newAlliance_rebel.png",nameKey="alliance_rebel_detail",descKey="alliance_function_desc7",callBack=callBack7,index=3}
		table.insert(self.functionTb,rebData)
	end

	if base.allianceCitySwitch==1 then
		local cityData={icon="newAlliance_city.png",nameKey="alliance_city",descKey="alliance_function_desc8",callBack=callBack8,index=5}
		table.insert(self.functionTb,cityData)
	end

	if base.allianceGiftSwitch == 1 then
		local giftData = {icon="newAlliance_gift.png",nameKey="alliance_gift",descKey="alliance_function_desc9",callBack=callBack9,index = 8}
		table.insert(self.functionTb,giftData)
	end

	if base.isAllianceSkillSwitch==0 then
		for k,v in pairs(self.functionTb) do
		  	if v.nameKey=="alliance_technology" then
		    	table.remove(self.functionTb,k)
		  	end
		end
	end

	if base.ifAllianceShopOpen==0 then
		for k,v in pairs(self.functionTb) do
		  	if v.nameKey=="allianceShop" then
		    	table.remove(self.functionTb,k)
			end
		end
	end

	if base.isAllianceFubenSwitch==0 then
		for k,v in pairs(self.functionTb) do
		  	if v.nameKey=="alliance_duplicate" then
		      	table.remove(self.functionTb,k)
		  	end
		end
	end

	if base.isGarrsionOpen==0 then
		for k,v in pairs(self.functionTb) do
		  	if v.nameKey=="alliance_setGarrsion" then
		      	table.remove(self.functionTb,k)
		  	end
		end
	end  

	local function sortList(a,b)
		if a.index<b.index then
		  	return true
		else
			return false
		end
	end
	table.sort(self.functionTb,sortList)
  
end

function newAllianceDialog:initUpAttr( ... )

	local alliance=allianceVoApi:getSelfAlliance()

	local function nilFunc( ... )
    end
	local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
    upBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,370))
    upBg:setAnchorPoint(ccp(0.5,1))
    upBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82))    
    upBg:setOpacity(0)
	self.bgLayer:addChild(upBg)

	if alliance then
        local textWidth = 280
        local textBgWidth = upBg:getContentSize().width-220

        if base.isAf == 1 then
            -- 军团旗帜
            self.bannerOld = alliance.banner or "" -- 记录军团旗帜
            local defaultSelect = allianceVoApi:getFlagIconTab(self.bannerOld)
            self.flagShow = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.7, -(self.layerNum-1)*20-5, function ()
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFlagDialog"
                local td = allianceFlagDialog:new()
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("allianceFlagTitle"), true, self.layerNum + 2)
                sceneGame:addChild(dialog, self.layerNum + 1)
            end)
            self.flagShow:setPosition(110, upBg:getContentSize().height / 2 + 60)
            upBg:addChild(self.flagShow)

            local function jumpToAttrLook()
                -- 跳转属性查看
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFlagAttrAllDialog"
                allianceFlagAttrAllDialog:showFlagAttrAllDialog(self.layerNum + 1)
            end
            local attrLookLb = GetTTFLabel(getlocal("battlebuff_overview"), 22, true)
            attrLookLb:setAnchorPoint(ccp(0.5, 0))
            local line = CCLayerColor:create(ccc4(255, 255, 255, 255))
            line:setContentSize(CCSizeMake(attrLookLb:getContentSize().width + 4, 2))
            line:setPosition(-2, -2)
            attrLookLb:addChild(line)
            local menuItem = CCMenuItemLabel:create(attrLookLb)
            menuItem:registerScriptTapHandler(jumpToAttrLook)
            local menu = CCMenu:createWithItem(menuItem)
            menu:setAnchorPoint(ccp(0.5, 0.5))
            menu:setTouchPriority(-(self.layerNum - 1) * 20 - 6)
            menu:setPosition(self.flagShow:getPositionX(), self.flagShow:getPositionY() - 90)
            upBg:addChild(menu)

            -- 红点
            self.flagPoint = CCSprite:createWithSpriteFrameName("NumBg.png")
            self.flagPoint:setPosition(self.flagShow:getPositionX() + 80, self.flagShow:getPositionY() + 90)
            self.flagPoint:setVisible(false)
            self.flagPoint:setScale(0.7)
            upBg:addChild(self.flagPoint)
        else
            local allianceIcon = CCSprite:createWithSpriteFrameName("helpAlliance.png")
            allianceIcon:setPosition(110, upBg:getContentSize().height / 2 + 60)
            allianceIcon:setScale(2)
            upBg:addChild(allianceIcon)
        end

		-- 军团名称和等级
		local function nilFunc( ... )
		end
	    local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("newAllianceTitle.png",CCRect(80,25,1,1),nilFunc)
	    titleSpire:setContentSize(CCSizeMake(textBgWidth,titleSpire:getContentSize().height))
	    titleSpire:setAnchorPoint(ccp(0,1))
	    upBg:addChild(titleSpire)
	    titleSpire:setPosition(ccp(220,upBg:getContentSize().height-20))

	    -- 军团名称
	    local myAllianceName = GetTTFLabelWrap(alliance.name,28,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
  		myAllianceName:setAnchorPoint(ccp(0,0.5))
		myAllianceName:setPosition(ccp(60,titleSpire:getContentSize().height/2))
		myAllianceName:setColor(G_ColorYellowPro2)
		self.myAllianceName = myAllianceName
  		titleSpire:addChild(myAllianceName)

	    local function changeName( ... )
	    	local function changeCallBack()
	    		if self.bgLayer and self.changeNameItem then
	    			self.changeNameItem:setEnabled(false)
	    			self.changeNameItem:setVisible(false)
	    		end
	    	end
	        mergerServersChangeNameDialog:create(self.layerNum + 1,getlocal("alliance_changeName"),getlocal("alliance_changeContent",{getlocal("alliance_list_scene_name"),getlocal("alliance_list_scene_name"),getlocal("alliance_list_scene_name")}),2,changeCallBack)
	    end
	    if string.find(alliance.name,"@")~=nil then
			self.changeNameItem=G_createBotton(titleSpire,ccp(myAllianceName:getPositionX()+myAllianceName:getContentSize().width+10,myAllianceName:getPositionY()),nil,"changeNameBtn.png","changeNameBtn_Down.png","changeNameBtn.png",changeName,0.8,-(self.layerNum-1)*20-4,2,nil,ccp(0,0.5))	
	        if tostring(alliance.role)~="2"then
	          self.changeNameItem:setEnabled(false)
	          self.changeNameItem:setVisible(false)
	        end
	    end

	    -- 军团等级
		local myAllianceLv = GetTTFLabel(alliance.level,25,true)
	 	myAllianceLv:setAnchorPoint(ccp(0.5,0.5))
	  	myAllianceLv:setPosition(ccp(25,titleSpire:getContentSize().height/2))
	  	self.myAllianceLv = myAllianceLv
	  	titleSpire:addChild(myAllianceLv)

	  	-- 团长
	  	local myAllianceLeader = GetTTFLabelWrap(getlocal("alliance_info_leader",{alliance.leaderName}),25,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
		myAllianceLeader:setAnchorPoint(ccp(0,1))
		myAllianceLeader:setPosition(280,upBg:getContentSize().height-20-titleSpire:getContentSize().height-10)
		self.myAllianceLeader = myAllianceLeader
		upBg:addChild(self.myAllianceLeader)

		local attrH = upBg:getContentSize().height-20-titleSpire:getContentSize().height-10-myAllianceLeader:getContentSize().height-10
		
    	local topLineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function()end)
    	topLineSp:setContentSize(CCSizeMake(textBgWidth-50,2))
    	topLineSp:setAnchorPoint(ccp(0,1))
    	upBg:addChild(topLineSp)
    	topLineSp:setPosition(ccp(220,attrH))

    	attrH = attrH-10

    	local memberNum=0
		local memberTab=allianceMemberVoApi:getMemberTab()
	  	if memberTab then
	    	memberNum=SizeOfTable(memberTab)
	  	end
	  	local amaxnum
	  	if(allianceVoApi:getSelfAlliance() and allianceVoApi:getSelfAlliance().maxnum)then
	      	amaxnum=allianceVoApi:getSelfAlliance().maxnum
	  	else
	      	amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
	  	end
		
		-- 军团信息 1.总战力 2.成员 3.军团资金 4.军团活跃等级
		allianceInfoCfg = {
			{pic="allianceAttackIcon.png",numStr=FormatNumber(alliance.fight),flag="force"},
			{pic="allianceMemberIcon.png",numStr=getlocal("scheduleChapter",{memberNum,amaxnum}),flag="member"},
			{pic="helpRecharge.png",numStr=FormatNumber(alliance.point),flag="recharge"},
			{pic="allianceActiveRank.png",numStr=alliance.rank,flag="activeLevel"},
		}

    	for i=1,4 do

    		local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
		 	grayBgSp:setContentSize(CCSizeMake((textBgWidth-50)/2,50))
		 	grayBgSp:setAnchorPoint(ccp(0,1))
		 	grayBgSp:setPosition(ccp(220+(textBgWidth-50)/2*(1-i%2),attrH-math.floor(i/3)*50))
		 	upBg:addChild(grayBgSp)

		 	if i == 2 or i == 3 then
		 		grayBgSp:setOpacity(0)
		 	end

		 	local tipSp = CCSprite:createWithSpriteFrameName(allianceInfoCfg[i].pic)
		 	tipSp:setAnchorPoint(ccp(0.5,0.5))
		 	tipSp:setPosition(ccp(grayBgSp:getContentSize().width/4,grayBgSp:getContentSize().height/2))
		 	grayBgSp:addChild(tipSp)
		 	tipSp:setScale(0.5)

		 	local pointLabel = GetTTFLabel(allianceInfoCfg[i].numStr,22)
		 	pointLabel:setAnchorPoint(ccp(0.5,0.5))
		 	pointLabel:setPosition(ccp(grayBgSp:getContentSize().width*3/4,grayBgSp:getContentSize().height/2))
		 	grayBgSp:addChild(pointLabel)

		 	self.allianceInfoLabelTb[allianceInfoCfg[i].flag] = pointLabel

    	end

    	attrH = attrH-110

    	local midLineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function()end)
    	midLineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,2))
    	midLineSp:setAnchorPoint(ccp(0.5,1))
    	upBg:addChild(midLineSp)
    	midLineSp:setPosition(ccp(upBg:getContentSize().width/2,attrH))

    	local declarationBg =LuaCCScale9Sprite:createWithSpriteFrameName("newAlliance_desc1.png",CCRect(198,24, 2, 2),function()end)
		declarationBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,135))
		declarationBg:setAnchorPoint(ccp(0.5,1))
		declarationBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,attrH-20))
		declarationBg:setIsSallow(false)

		local noticeLable = GetTTFLabel(getlocal("newAllianceNotice"),25,true)
		noticeLable:setColor(G_ColorYellowPro2)
    	noticeLable:setAnchorPoint(ccp(0.5,0))
    	noticeLable:setPosition(ccp(declarationBg:getContentSize().width/2,declarationBg:getContentSize().height-18))
  		declarationBg:addChild(noticeLable)

  		local noticeValueLable=GetTTFLabelWrap(alliance.notice,25,CCSize(declarationBg:getContentSize().width-30,declarationBg:getContentSize().height-30),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    noticeValueLable:setAnchorPoint(ccp(0,1))
	    noticeValueLable:setPosition(ccp(15,declarationBg:getContentSize().height-20))
	    declarationBg:addChild(noticeValueLable)
	    self.allianceInfoLabelTb["alinceNotice"] = noticeValueLable

	    local haveNoNoticeLabel = GetTTFLabel(getlocal("newAllianceNoNotice"),25,true)
  		haveNoNoticeLabel:setAnchorPoint(ccp(0.5,0.5))
  		haveNoNoticeLabel:setPosition(ccp(declarationBg:getContentSize().width/2,declarationBg:getContentSize().height/2))
  		haveNoNoticeLabel:setColor(G_ColorGray)
  		declarationBg:addChild(haveNoNoticeLabel)
  		self.allianceInfoLabelTb["haveNoNoticeLabel"] = haveNoNoticeLabel
  		if string.len(alliance.notice) == 0 then
  			haveNoNoticeLabel:setVisible(true)
  		else
  			haveNoNoticeLabel:setVisible(false)
  		end

		upBg:addChild(declarationBg)

    	attrH = attrH-150
    	-- local bottomLineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function()end)
    	-- bottomLineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,2))
    	-- bottomLineSp:setAnchorPoint(ccp(0.5,1))
    	-- upBg:addChild(bottomLineSp)
    	-- bottomLineSp:setPosition(ccp(upBg:getContentSize().width/2,attrH))

    	attrH = attrH - 10
  	end
end

function newAllianceDialog:infoCallback(i)

	if i == 1 then
		-- 退出军团
		local function leaveAlliance()   
            local uid=playerVoApi:getUid()
            
            if allianceVoApi:checkCanQuitAlliance(uid,self.layerNum+1)==false then
            	do return end
            end
            
            local params={}

            if(tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())==1)then
            	params["isDismiss"]=1
              	params["name"]=allianceVoApi:getSelfAlliance().name
            else
                params["name"]=allianceVoApi:getSelfAlliance().name
                params["list"]={}
                for k,v in pairs(allianceMemberVoApi:getMemberTab()) do
                  	if(v.uid~=playerVoApi:getUid())then
                   		table.insert(params["list"],{v.uid,v.name})
                  	end
                end
            end

            local function leaveAllianceCallBack(fn,data)
                if base:checkServerData(data)==true then
                    -- allianceVoApi:clearSelfAlliance()--清空自己军团信息
                    allianceVoApi:clear()
                    allianceMemberVoApi:clear()--清空成员列表
                    allianceApplicantVoApi:clear()--清空
                    playerVoApi:clearAllianceData()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_tuichuTip"),30)

                    self:close()--关闭板子
                    -- parentDlg:close(true)
                    chatVoApi:sendUpdateMessage(5,params)
                    --socketHelper:chatServerLogout()
                    -- allianceVoApi:clearRankAndGoodList()--清空军团列表
                    worldScene:updateAllianceName()
                    --helpDefendVoApi:clear()--清空协防
                    --工会活动刷新数据
                    activityVoApi:updateAc("fbReward")
                    activityVoApi:updateAc("allianceLevel")
                    activityVoApi:updateAc("allianceFight")
                end
            end
            socketHelper:allianceQuit(allianceVoApi:getSelfAlliance().aid,nil,leaveAllianceCallBack)
        end

        if base.localWarSwitch==1 then
            if localWarVoApi:canQuitAlliance(1)==false then
                do return end
            end
        end

        if base.serverWarLocalSwitch==1 then
            if serverWarLocalVoApi:canQuitAlliance(1)==false then
                do return end
            end
        end

        if tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())>1 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_wufatuichuTip"),30)
            do
                return
            end
        elseif tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())==1 then
            allianceSmallDialog:showOKDialog(leaveAlliance,getlocal("alliance_tuanzhangtuichuSureOK"),self.layerNum+1)
        else
            allianceSmallDialog:showOKDialog(leaveAlliance,getlocal("alliance_tuichuok"),self.layerNum+1)
        end

	elseif i == 2 then
  		local alliance=allianceVoApi:getSelfAlliance()
		-- 编辑军团
	    local function saveCallback(aid,internalNotice,foreignNotice,joinNeedLv,joinNeedFc,joinType)
	    	local valueTab={aid=aid,type=joinType,level_limit=joinNeedLv,fight_limit=joinNeedFc,notice=internalNotice,desc=foreignNotice}
	    	allianceVoApi:setSelfAlliance(valueTab)
	    end
    	allianceSmallDialog:allianceSettingsDialog("PanelHeaderPopup.png",CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,saveCallback,alliance,self.allianceInfoLabelTb["alinceNotice"])
	elseif i == 3 then
		-- 军团活跃
		require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceActiveDialog"
		require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceActiveInfoDialog"
		require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceActiveWelfareDialog"
    	local titleStr = getlocal("alliance_activie")
	    local sd = newAllianceActiveDialog:new()
		local tabTb = {getlocal("world_scene_info"), getlocal("alliance_activie_reward")}
	    local dialog = sd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,titleStr,true,self.layerNum+1);
	    sceneGame:addChild(dialog,self.layerNum+1)
	elseif i == 4 then
		-- 成员
		require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceMemberDialog"
		require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceMemberInfoDialog"
		require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceMemberRankDialog"
		self:getDataByType(i)
		local titleStr = getlocal("newAllianceBtn4")
	    local sd = newAllianceMemberDialog:new()
		local tabTb = {getlocal("newAllianceInfo"), getlocal("alliance_list_scene_list")}
	    local dialog = sd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,titleStr,true,self.layerNum+1);
	    sceneGame:addChild(dialog,self.layerNum+1)
	else
	
	end

end

function newAllianceDialog:initTableView( ... )

	local function nilFunc( ... )
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
    self.bgLayer:addChild(tvBg)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-82-370-150))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82-370-15))
    tvBg:setOpacity(0)

	local function callBack( ... )
    	return self:eventHandler(...)
	end
	local hd = LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-82-370-20-150),nil)
    self.tv:setPosition(ccp(10,145))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

end

function newAllianceDialog:eventHandler(handler,fn,idx,cel)

	if fn=="numberOfCellsInTableView" then
        return self:getCellNum()
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth-20,130)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        self:initCell(idx,cell)
        cell:autorelease()
        return cell
    elseif fn=="ccTouchBegan" then
    	return true
    elseif fn=="ccTouchMoved" then
    elseif fn=="ccScrollEnable" then
    end

end

function newAllianceDialog:getCellNum( ... )

	return math.ceil((#self.functionTb)/2)
end


function newAllianceDialog:initCell(idx,cell)

	cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,130))	
	local count = 0
	for i=(idx*2)+1,(idx*2)+2 do
		if i <= #self.functionTb then

			-- local function callBack( ... )
			-- 	self:runClickAction(i)
			-- end
			-- local funcBg = LuaCCSprite:createWithSpriteFrameName(self.functionTb[i].icon,callBack)
   --     		funcBg:setTouchPriority(-(self.layerNum-1)*20-1)
			-- funcBg:setAnchorPoint(ccp(0.5,0.5))
			-- funcBg:setPosition(ccp(cell:getContentSize().width/4+(i-idx*2-1)*cell:getContentSize().width/2,cell:getContentSize().height/2))
			-- self.functionBg[i] = funcBg
			local titleStrSize = 30
			if G_isAsia() == false then
				titleStrSize = 25
			end
			local funcBg = G_createBotton(cell,ccp(cell:getContentSize().width/4+(i-idx*2-1)*cell:getContentSize().width/2,cell:getContentSize().height/2),{"",titleStrSize},self.functionTb[i].icon,self.functionTb[i].icon,self.functionTb[i].icon,self.functionTb[i].callBack,1,-(self.layerNum-1)*20-1,10,nil,nil,nil,getlocal(self.functionTb[i].nameKey),ccp(280,100),0.9)
			-- cell:addChild(funcBg)

			-- local qualityLb=GetTTFLabelWrap(getlocal(self.functionTb[i].nameKey),titleStrSize,CCSizeMake(280,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	  --      	qualityLb:setAnchorPoint(ccp(1,1))
	  --      	qualityLb:setPosition(ccp(funcBg:getContentSize().width-30,funcBg:getContentSize().height-20))
	  --      	funcBg:addChild(qualityLb)
		end
	end

end

function newAllianceDialog:tick( ... )


	local alliance=allianceVoApi:getSelfAlliance()
    if alliance then
		if self.myAllianceLv and  tolua.cast(self.myAllianceLv,"CCLabelTTF") then
			tolua.cast(self.myAllianceLv,"CCLabelTTF"):setString(alliance.level)
		end

		if self.myAllianceName and tolua.cast(self.myAllianceName,"CCLabelTTF") then
            tolua.cast(self.myAllianceName,"CCLabelTTF"):setString(alliance.name)
        end

        if self.myAllianceLeader and tolua.cast(self.myAllianceLeader,"CCLabelTTF") then
            tolua.cast(self.myAllianceLeader,"CCLabelTTF"):setString(getlocal("alliance_info_leader",{alliance.leaderName}))
        end

        if self.allianceInfoLabelTb["force"] and tolua.cast(self.allianceInfoLabelTb["force"],"CCLabelTTF") then
        	tolua.cast(self.allianceInfoLabelTb["force"],"CCLabelTTF"):setString(FormatNumber(alliance.fight))
        end

        if self.allianceInfoLabelTb["member"] and tolua.cast(self.allianceInfoLabelTb["member"],"CCLabelTTF") then

        	local memberNum=0
            local memberTab=allianceMemberVoApi:getMemberTab()
            if memberTab then
            	memberNum=SizeOfTable(memberTab)
            end
            local amaxnum
            if(allianceVoApi:getSelfAlliance() and allianceVoApi:getSelfAlliance().maxnum)then
                amaxnum=allianceVoApi:getSelfAlliance().maxnum
            else
                amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
            end
            tolua.cast(self.allianceInfoLabelTb["member"],"CCLabelTTF"):setString(getlocal("scheduleChapter",{memberNum,amaxnum}))

        end

        if self.allianceInfoLabelTb["recharge"] and tolua.cast(self.allianceInfoLabelTb["recharge"],"CCLabelTTF") then
        	tolua.cast(self.allianceInfoLabelTb["recharge"],"CCLabelTTF"):setString(FormatNumber(alliance.point))
        end

        if self.allianceInfoLabelTb["activeLevel"] and tolua.cast(self.allianceInfoLabelTb["activeLevel"],"CCLabelTTF") then
        	tolua.cast(self.allianceInfoLabelTb["activeLevel"],"CCLabelTTF"):setString(alliance.rank)
        end

        if self.allianceInfoLabelTb["alinceNotice"] and tolua.cast(self.allianceInfoLabelTb["alinceNotice"],"CCLabelTTF") then
        	tolua.cast(self.allianceInfoLabelTb["alinceNotice"],"CCLabelTTF"):setString(alliance.notice)
        end
        if self.allianceInfoLabelTb["haveNoNoticeLabel"] and tolua.cast(self.allianceInfoLabelTb["haveNoNoticeLabel"],"CCLabelTTF") then        	
        	if string.len(alliance.notice) == 0 then
  				tolua.cast(self.allianceInfoLabelTb["haveNoNoticeLabel"],"CCLabelTTF"):setVisible(true)
	  		else
	  			tolua.cast(self.allianceInfoLabelTb["haveNoNoticeLabel"],"CCLabelTTF"):setVisible(false)
  			end
        end
        self:relocalteBtn()
        self:refreshTips()
        self:refreshGift()

        if base.isAf == 1 then
            if self.flagShow and alliance.banner and alliance.banner ~= "" and alliance.banner ~= self.bannerOld then
                -- 军团旗帜更新
                self.bannerOld = alliance.banner or "" -- 记录军团旗帜
                local defaultSelect = allianceVoApi:getFlagIconTab(self.bannerOld)
                allianceVoApi:setShowFlag(self.flagShow, defaultSelect[1], defaultSelect[2], defaultSelect[3])
            end

            local allianceFlagUnlock = allianceVoApi:getFlagNewTips()

            local unlockNum = SizeOfTable(allianceFlagUnlock[1]) + SizeOfTable(allianceFlagUnlock[2]) + SizeOfTable(allianceFlagUnlock[3])

            if allianceFlagUnlock and unlockNum > 0 then
                self.flagPoint:setVisible(true)
            else
                self.flagPoint:setVisible(false)
            end
        end
	end
end


function newAllianceDialog:getDataByType(type)
    if type==nil then
        type=0
    end
    if type==4 then
        local function getListHandler(fn,data)
            if base:checkServerData(data)==true then
                allianceVoApi:setLastListTime(base.serverTime)
            end
        end
        if allianceVoApi:getNeedGetList() or allianceVoApi:getRankOrGoodNum()==0 then
            socketHelper:allianceList(getListHandler,1)
        end
    end
end

function newAllianceDialog:runClickAction(index)

	if self.functionBg[index] and tolua.cast(self.functionBg[index],"LuaCCSprite") then
		local scaleSmall = CCScaleTo:create(0.1,0.9)
		local delay = CCDelayTime:create(0.1)
		local scaleBig = CCScaleTo:create(0.1,1)
		local acArr = CCArray:create()
		acArr:addObject(scaleSmall)
		acArr:addObject(delay)
		acArr:addObject(scaleBig)
		local seque=CCSequence:create(acArr)
		local function callBack( ... )
			if self.functionTb[index].callBack and type(self.functionTb[index].callBack) == "function" then
				self.functionTb[index].callBack()
			end
		end 

		local callFunc = CCCallFunc:create(callBack)
		local seq = CCSequence:createWithTwoActions(seque,callFunc)
		tolua.cast(self.functionBg[index],"LuaCCSprite"):runAction(seq)
	end
end

function newAllianceDialog:refreshTips( ... )
	local count=0
	local applylist=allianceApplicantVoApi:getApplicantTab()
	if applylist then
		count=SizeOfTable(applylist)
	end
	if count>0 then
		self:setTipsVisibleByIdx(true,count)
	else
		self:setTipsVisibleByIdx(false)
	end
end

function newAllianceDialog:setTipsVisibleByIdx(isVisible,num)
	if self==nil then
        do
            return 
        end
    end

    local temTabBtnItem=tolua.cast(self.btnItem,"CCNode")
    local tipSp
    if temTabBtnItem then
    	tipSp=temTabBtnItem:getChildByTag(10)
    end
    if tipSp~=nil then
      if tipSp:isVisible()~=isVisible then
        tipSp:setVisible(isVisible)
      end
      if tipSp:isVisible()==true then
        local numLb=tolua.cast(tipSp:getChildByTag(11),"CCLabelTTF")
        if numLb~=nil then
          if num and numLb:getString()~=tostring(num) then
            numLb:setString(num)
            local width=36
            if numLb:getContentSize().width+10>width then
              width=numLb:getContentSize().width+10
            end
            tipSp:setContentSize(CCSizeMake(width,36))
            numLb:setPosition(getCenterPoint(tipSp))
          end
        end
      end
    end
end

function newAllianceDialog:refreshGift( ... )
	if FuncSwitchApi:isEnabled("alliance_active") == false then
		do return end
	end
	local tip=buildingCueMgr:getBuildingTip(15,nil,"welfare")
	if tip and not self.tipNode then

		local function tipHandler()
		    if tip.handler then
			      local function callback()
			        if tip.doFlag and tip.doFlag==true then 
			        	self.tipNode:removeFromParentAndCleanup(true)
			        end
			      end
			      tip.handler(callback)
		    end
		end
		
		local tipNode = CCNode:create()
		tipNode:setContentSize(CCSizeMake(100,100))
		tipNode:setAnchorPoint(ccp(0.5,0.5))
		tipNode:setPosition(self.welfareBtn:getContentSize().width-10,self.welfareBtn:getContentSize().height-10)
		self.welfareBtn:addChild(tipNode)
		tipNode:setScale(0.7)

		local lightBg1 = CCSprite:createWithSpriteFrameName("equipShine.png")
		lightBg1:setPosition(ccp(tipNode:getContentSize().width/2,tipNode:getContentSize().height/2))
        local rotateBy = CCRotateBy:create(4,360)
        local reverseBy = rotateBy:reverse()
		lightBg1:runAction(CCRepeatForever:create(reverseBy))
		tipNode:addChild(lightBg1)

        local lightBg = CCSprite:createWithSpriteFrameName("equipShine.png")
        lightBg:setPosition(ccp(tipNode:getContentSize().width/2,tipNode:getContentSize().height/2))
        local rotateBy = CCRotateBy:create(4,360)
        lightBg:runAction(CCRepeatForever:create(rotateBy))
        tipNode:addChild(lightBg)

		local tipSp=LuaCCSprite:createWithSpriteFrameName("friendBtn.png",tipHandler)
		tipSp:setAnchorPoint(ccp(0.5,0.5))
		tipSp:setPosition(50,50)
		tipSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
		tipNode:addChild(tipSp)
        tipSp:runAction(G_giftAction())

		self.tipNode = tipNode
	end

end


function newAllianceDialog:dispose( ... )
	self.bgLayer=nil
	self.changeNameItem=nil
	self.functionTb = {}
	self.allianceInfoLabelTb = {}
    self.bannerOld = nil
	
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/allianceActiveImage.plist")
  	CCTextureCache:sharedTextureCache():removeTextureForKey("public/allianceActiveImage.pvr.ccz")
  	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/slotMachine.plist")
  	CCTextureCache:sharedTextureCache():removeTextureForKey("public/slotMachine.pvr.ccz")
  	spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
  	spriteController:removePlist("public/newAlliance.plist")
  	spriteController:removePlist("public/juntuanCityBtns.plist")
 	spriteController:removeTexture("public/newAlliance.png")
 	spriteController:removeTexture("public/juntuanCityBtns.png")
	spriteController:removePlist("public/believer/believerMain.plist")
	spriteController:removeTexture("public/believer/believerMain.png")
end