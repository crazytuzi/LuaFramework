satelliteSearchSmallDialog=smallDialog:new()

function satelliteSearchSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.selectIndex=1
	self.subSelectIndex=1
	self.subSelectIndex1=0
	self.subSelectIndex2=0
	self.targetTb={}
	spriteController:addPlist("public/acNewYearsEva.plist")
	spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
	spriteController:addTexture("public/allianceWar2/allianceWar2.png")
	return nc
end

function satelliteSearchSmallDialog:showSearchDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,gpsCallback)
	local sd=satelliteSearchSmallDialog:new()
    sd:initSearchDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,gpsCallback)
end

function satelliteSearchSmallDialog:initSearchDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,gpsCallback)
	local strSize2 = 20
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		strSize2 = 25
	end
	self.isTouch=nil
    self.isUseAmi=isuseami
    self.layerNum=layerNum

    self.dialogLayer=CCLayer:create()
    self.bgSize=size

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local dialogBg=G_getNewDialogBg(size,title,28,function() end,layerNum,true,close)
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority((-(layerNum-1)*20-1))
    self.bgLayer:setIsSallow(true)

    self:show()

    -- 跨天刷新数据，防止tick二次刷新
    local satelliteVo=satelliteSearchVoApi:getSatelliteVo()
	if satelliteVo and satelliteVo.lastTime then
		if not G_isToday(satelliteVo.lastTime) then
			satelliteSearchVoApi:clearVo()
		end
	end

    local lbPosy=self.bgSize.height-100

 --    local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
	-- titleBg:setPosition(ccp(self.bgSize.width/2,lbPosy))
	-- titleBg:setScaleY(60/titleBg:getContentSize().height)
	-- titleBg:setScaleX(self.bgSize.width/titleBg:getContentSize().width)
	-- dialogBg:addChild(titleBg)

 --    local function close()
	-- 	PlayEffect(audioCfg.mouseClick)
	-- 	return self:close()
	-- end
	-- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	-- closeBtnItem:setPosition(0,0)
	-- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	-- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	-- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	-- self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	-- dialogBg:addChild(self.closeBtn,1)

	-- lbPosy=lbPosy-55
	-- local sp=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
 --    sp:setPosition(ccp(self.bgSize.width/2,lbPosy))
 --    self.bgLayer:addChild(sp)

    local function touchItem(idx)
    	if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

        if idx<3 then
        	if idx==1 then
	        	self.menuItem[1]:setEnabled(false)
	        	self.menuItem[2]:setEnabled(true)
	        elseif idx==2 then
	        	self.menuItem[1]:setEnabled(true)
	        	self.menuItem[2]:setEnabled(false)
	        end
        	self:refreshTv(idx)
        else
        	local tabStr = {}
	        local tabColor = {}
	        tabStr = {"\n",getlocal("satellite_tip4"),getlocal("satellite_tip3"),getlocal("satellite_tip2"),getlocal("satellite_tip1"),"\n"}
	        -- tabColor = {nil, nil, nil, nil}
	        local td=smallDialog:new()
	        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,tabStr,25,tabColor)
	        sceneGame:addChild(dialog,layerNum+1)
        end
        
    end

    lbPosy=lbPosy-20
    self.menuItem={}
    local menuItem1 = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
    menuItem1:setTag(1)
    menuItem1:registerScriptTapHandler(touchItem)
    menuItem1:setEnabled(false)
    local MenuBtn1=CCMenu:createWithItem(menuItem1)
    MenuBtn1:setPosition(ccp(17+menuItem1:getContentSize().width/2,lbPosy + 5))
    MenuBtn1:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(MenuBtn1,2)
    self.menuItem[1]=menuItem1

	local lb1=GetTTFLabelWrap(getlocal("common_target"),24,CCSizeMake(menuItem1:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	menuItem1:addChild(lb1,2)
	lb1:setPosition(menuItem1:getContentSize().width/2,menuItem1:getContentSize().height/2)


	-- 特殊目标 等级限制
	local playerLevel=playerVoApi:getPlayerLevel()
	if playerLevel>=mapScoutCfg.scoutLv then
	    local menuItem2 = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
	    menuItem2:setTag(2)
	    menuItem2:registerScriptTapHandler(touchItem)
	    menuItem2:setEnabled(true)
	    local MenuBtn2=CCMenu:createWithItem(menuItem2)
	    MenuBtn2:setPosition(ccp(19+menuItem2:getContentSize().width/2*3,lbPosy + 5))
	    MenuBtn2:setTouchPriority(-(layerNum-1)*20-4)
	    self.bgLayer:addChild(MenuBtn2,2)
	    self.menuItem[2]=menuItem2

	    local lb2=GetTTFLabelWrap(getlocal("special_target"),24,CCSizeMake(menuItem2:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		menuItem2:addChild(lb2,2)
		lb2:setPosition(menuItem2:getContentSize().width/2,menuItem2:getContentSize().height/2)
	end

    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchItem,1,nil,0)
    menuItemDesc:setTag(3)
    menuItemDesc:registerScriptTapHandler(touchItem)
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(layerNum-1)*20-4)
    menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-80, lbPosy+10))
    self.bgLayer:addChild(menuDesc,2)

    lbPosy=lbPosy-20

    local function nilFunc()
	end
	local bidBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
	bidBg:setContentSize(CCSizeMake(self.bgSize.width-30,lbPosy-120))
	bidBg:setPosition(ccp(15,120))
	bidBg:setAnchorPoint(ccp(0,0))
	self.bgLayer:addChild(bidBg)

    self:initTableView(lbPosy)

    lbPosy=lbPosy-330

    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    lineSp:setContentSize(CCSizeMake(self.bgSize.width - 24,lineSp:getContentSize().height))
    lineSp:setPosition(self.bgSize.width * 0.5,lbPosy + 10)
    self.bgLayer:addChild(lineSp)
    -- lineSp:setScaleX(0.9)

    
    -- 添加页签1的滑动条
    self.lbPosy=lbPosy
    self:addOpacityBg1(lbPosy)
    self:addOpacityBg2(lbPosy)

    self:refreshTv(1)




    -- 定位按钮
    local function gpsFunc()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		local function canNotSearch()
			local lastTime=satelliteSearchVoApi:getLastTime(self.selectIndex,self.subSelectIndex)
			local leftTime=math.max(1,lastTime - base.serverTime)
			local leftTimeStr=getlocal("second_num",{leftTime})
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("satellite_des7",{leftTimeStr}),30)
		end

		-- 普通目标  扣除次数
		if self.selectIndex==1 then
			-- 判断两次没找到请求的时间
			local lastTime=satelliteSearchVoApi:getLastTime(self.selectIndex,self.subSelectIndex)
			if base.serverTime<lastTime then
				canNotSearch()
				return

			end


			local vipLevel=playerVoApi:getVipLevel() or 0
			local limitNum=mapScoutCfg.vipScout[vipLevel+1] or mapScoutCfg.vipScout[SizeOfTable(mapScoutCfg)]
			local satelliteVo = satelliteSearchVoApi:getSatelliteVo()
			local searchTimes=satelliteVo.commonNum or 0
			if searchTimes>=limitNum then
                local maxVipLevel=playerVoApi:getMaxLvByKey("maxVip")
                local desStr
                if maxVipLevel==vipLevel then
                	desStr=getlocal("satellite_des3")
                else
                	desStr=getlocal("satellite_des1")
                end
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),desStr,30)
				return
			end

			local value=math.floor(self.slider:getValue())
			if value%2~=0 then
				value=value-1
			end
			local function refreshCallback(pos)
				satelliteSearchVoApi:setSelectInfo(self.selectIndex,self.subSelectIndex,value)
				satelliteSearchVoApi:storageLastPos(pos)
				if gpsCallback then
					gpsCallback(pos)
				end
				self:close()
			end
			local cmdStr="map.worldsearch.mine"
			local mapType=self.subSelectIndex
			local mapLevel=value
			satelliteSearchVoApi:mapWorldSearch(cmdStr,mapType,mapLevel,refreshCallback)
		else
			local function refreshCallback(pos)
				if pos then
					satelliteSearchVoApi:setSelectInfo(self.selectIndex,self.subSelectIndex)
					satelliteSearchVoApi:storageLastPos(pos)
					if gpsCallback then
						gpsCallback(pos)
					end
					self:close()
				else
					self:refreshOpacityBg2()
				end
			end
			
			local specialTb=self.targetTb[self.subSelectIndex]
			if specialTb.need2 then
				local propItem=FormatItem(specialTb.need2)
				local needNum=propItem[1].num
				local haveNum=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(propItem[1].key)))
				if needNum>haveNum then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("satellite_des4",{propItem[1].name}),30)
					return
				end
				bagVoApi:showSearchSmallDialog(self.layerNum+1,propItem[1].key,refreshCallback)
			elseif specialTb.notNeed then
				local function readyToOpenPrivateMineListPanel()
					self:close()
					require "luascript/script/game/gamemodel/privateMine/showPrivateMineListPanel"
					local searchListPanel = showPrivateMineListPanel:new(gpsCallback)
					local dialog=searchListPanel:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("privateMineSearchTitle"),true,3)
		            sceneGame:addChild(dialog,self.layerNum+1)
				end
				privateMineVoApi:setSearchLastTime(base.serverTime)	
				satelliteSearchVoApi:mapWorldSearch("map.worldsearch.privatemine",nil,nil,readyToOpenPrivateMineListPanel)			
			else
				local satelliteVo=satelliteSearchVoApi:getSatelliteVo()
				local times
				if specialTb.type==1 then
					times=satelliteVo.raidNum or 0
				elseif specialTb.type == 6 then --欧米伽小队
					times=satelliteVo.omgn or 0
				else
					times=satelliteVo.goldNum or 0
				end
				if specialTb.type == 6 then
					if airShipVoApi:getOpenLv() > playerLevel then
						G_showTipsDialog(getlocal("activity_tankbattle_levelLimit",{airShipVoApi:getOpenLv()}))
						do return end
					end
				end

				local needGold=specialTb.need1[times+1] or specialTb.need1[SizeOfTable(specialTb.need1)]
				local haveGold
				local lastDonate
				local neiStr
			    local keyName 
			    local targetName
				if specialTb.type==1 then
					neiStr=getlocal("sample_prop_name_974")
					keyName = "map_worldsearch_rebel"
					targetName=getlocal("alliance_rebel_page2_sub_title2")
				elseif specialTb.type == 6 then
					neiStr = getlocal("airship_material")
					keyName="map_worldsearch_airshipboss"
					targetName=getlocal(specialTb.name)
				else
					neiStr=getlocal("rpshop_rpCoin")
					keyName = "map_worldsearch_gold"
					targetName=getlocal("goldmine")
				end
				if specialTb.type==1 then
					haveGold=allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid()) or 0
					lastDonate=allianceMemberVoApi:getUseDonate(playerVoApi:getUid())
				elseif specialTb.type == 6 then
					haveGold = airShipVoApi:formatPartsTb()
				else
					haveGold=playerVoApi:getRpCoin() or 0
				end
				if haveGold<needGold then
					
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("satellite_des4",{neiStr}),30)

	              return
				else
					function confirmHandler( ... )

						local function refreshCallback2(pos)
							if specialTb.type==1 then
								allianceMemberVoApi:setUseDonate(playerVoApi:getUid(),lastDonate+needGold)
							elseif specialTb.type == 6 then
								airShipVoApi:useMaterial(needGold)
							else
								playerVoApi:setRpCoin(haveGold-needGold)
								
							end
							refreshCallback(pos)
						end

						local cmdStr
						if specialTb.type==1 then
							cmdStr="map.worldsearch.rebel"
						elseif specialTb.type == 6 then
							cmdStr="map.worldsearch.shipboss"
						else
							cmdStr="map.worldsearch.gold"
						end

						local lastTime=satelliteSearchVoApi:getLastTime(self.selectIndex,self.subSelectIndex)
						if base.serverTime<lastTime then
							canNotSearch()
							return
						end

						satelliteSearchVoApi:mapWorldSearch(cmdStr,nil,nil,refreshCallback2)
					end
					local function secondTipFunc(sbFlag)
		            	local sValue=base.serverTime .. "_" .. sbFlag
		            	G_changePopFlag(keyName,sValue)
					end
			        if G_isPopBoard(keyName) then
			           G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("world_search_second_prompt",{needGold,neiStr,targetName}),true,confirmHandler,secondTipFunc)
			        else
			            confirmHandler()
			        end
				end
			end
			
		end
    end
    local gpsItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",gpsFunc,nil,getlocal("world_scene_location"),24,100)
    -- gpsItem:registerScriptTapHandler(touchItem)
    self.gpsLb = tolua.cast(gpsItem:getChildByTag(100),"CCLabelTTF")
    local gpsBtn=CCMenu:createWithItem(gpsItem)
    gpsBtn:setPosition(ccp(self.bgSize.width/2,70))
    gpsBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(gpsBtn,2)
    local lb = gpsItem:getChildByTag(100)
    if lb then
    	lb = tolua.cast(lb, "CCLabelTTF")
    	lb:setFontName("Helvetica-bold")
    end

	
    
    local function touchDialog()
      
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))

    base:addNeedRefresh(self)

    return self.dialogLayer
end

function satelliteSearchSmallDialog:addOpacityBg1(lbPosy)
	-- local strSize2 = 22
	-- if G_isAsia() then
	-- 	strSize2 = 25
	-- end
	local strSize2 = 22
	local function nilFunc()
	end
	local opacityBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(50, 50, 1, 1),nilFunc)
	opacityBg1:setContentSize(CCSizeMake(self.bgSize.width-30,lbPosy-120))
	opacityBg1:setPosition(self.bgSize.width/2,121+(lbPosy-120)/2)
	self.bgLayer:addChild(opacityBg1)
	opacityBg1:setOpacity(0)
	self.opacityBg1=opacityBg1

	local sPosx=30
	-- world_war_level
	local bgPosy=opacityBg1:getContentSize().height-35
	local numStr=getlocal("world_war_level",{""})
	local deslb1=GetTTFLabelWrap(numStr,strSize2,CCSizeMake(115,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	deslb1:setAnchorPoint(ccp(0,0.5))
	deslb1:setPosition(ccp(sPosx,bgPosy))
	opacityBg1:addChild(deslb1,1)

	
	sPosx=sPosx+70
	local bgSp = CCSprite:createWithSpriteFrameName("proBar_n2.png")
	local sScale=75/bgSp:getContentSize().width
    bgSp:setAnchorPoint(ccp(0,0.5))
    bgSp:setScaleX(sScale)
    bgSp:setPosition(ccp(sPosx,bgPosy))
    opacityBg1:addChild(bgSp,1)

    sPosx=sPosx+110--65*sScale
    local numPosx = bgSp:getPositionX() + bgSp:getContentSize().width * sScale
	local m_numLb=GetTTFLabel(" ",22,true)
	m_numLb:setPosition(ccp(bgSp:getPositionX() + bgSp:getContentSize().width * sScale * 0.5 ,bgPosy))
	opacityBg1:addChild(m_numLb,1)
	self.m_numLb=m_numLb

	local function sliderTouch(handler,object)
		local count = math.floor(object:getValue())
		if count%2~=0 then
			count=count-1
		end
		m_numLb:setString(count)
	end
	local spBg =CCSprite:createWithSpriteFrameName("proBar_n2.png");
	local spPr =CCSprite:createWithSpriteFrameName("proBar_n1.png");
	local spPr1 =CCSprite:createWithSpriteFrameName("grayBarBtn.png");
	local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
	slider:setTouchPriority(-(self.layerNum-1)*20-4)
	slider:setIsSallow(true);
	slider:setMinimumValue(2.0)
	local maxNum=50
	if base.wl==1 and base.minellvl==1 then
		local playerMaxLv=playerVoApi:getMaxLvByKey("roleMaxLevel")
		maxNum=goldMineCfg.mineLvl[playerMaxLv][50]
	end
	slider:setMaximumValue(maxNum);
	slider:setValue(2);
	slider:setTag(99)
	slider:setScaleX(0.7)
	opacityBg1:addChild(slider,1)
	m_numLb:setString(math.floor(slider:getValue()))

	local function touchAdd()
		local num=math.floor(slider:getValue())+2
		if num%2~=0 then
			num=num-1
		end
		if num<=maxNum then
			slider:setValue(num)
		end
	end
	local function touchMinus()
		local num=math.floor(slider:getValue())-2
		if num%2~=0 then
			num=num-1
		end
		if num>0 then
			slider:setValue(num)
		end
	end

	local minusSp=LuaCCSprite:createWithSpriteFrameName("greenMinus.png",touchMinus)
	minusSp:setPosition(ccp(numPosx + 30,bgPosy))
	opacityBg1:addChild(minusSp,1)
	minusSp:setTouchPriority(-(self.layerNum-1)*20-4);

	slider:setPosition(ccp(minusSp:getPositionX() + 40 + slider:getContentSize().width * 0.35,bgPosy))

	local addSp=LuaCCSprite:createWithSpriteFrameName("greenPlus.png",touchAdd)
	addSp:setPosition(ccp(slider:getPositionX() + slider:getContentSize().width * 0.35 + 20,bgPosy))
	opacityBg1:addChild(addSp,1)
	addSp:setTouchPriority(-(self.layerNum-1)*20-4);
	self.slider=slider

	-- 今日次数剩余
	local sPosx=30
	bgPosy=bgPosy-50

	local vipLevel=playerVoApi:getVipLevel() or 0
	local limitNum=mapScoutCfg.vipScout[vipLevel+1] or mapScoutCfg.vipScout[SizeOfTable(mapScoutCfg)]
	local satelliteVo = satelliteSearchVoApi:getSatelliteVo()
	local searchTimes=satelliteVo.commonNum or 0
	local numStr=getlocal("daily_lotto_tip_3",{searchTimes,limitNum})
	local deslb2=GetTTFLabelWrap(numStr,22,CCSizeMake(opacityBg1:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	deslb2:setAnchorPoint(ccp(0,0.5))
	deslb2:setPosition(ccp(sPosx,bgPosy - 15))
	opacityBg1:addChild(deslb2,1)
	self.deslb2=deslb2


end

function satelliteSearchSmallDialog:refreshOpacityBg1()
	local satelliteVo = satelliteSearchVoApi:getSatelliteVo()
	local searchTimes=satelliteVo.commonNum or 0

	local vipLevel=playerVoApi:getVipLevel() or 0
	local limitNum=mapScoutCfg.vipScout[vipLevel+1] or mapScoutCfg.vipScout[SizeOfTable(mapScoutCfg)]

	local numStr=getlocal("daily_lotto_tip_3",{searchTimes,limitNum})
	self.deslb2:setString(numStr)
end

function satelliteSearchSmallDialog:addOpacityBg2(lbPosy)
	local strSize2 = 22
	if G_isAsia() then
		strSize2 = 25
	end
	strSize2 = 20
	local function nilFunc()
	end
	local opacityBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
	opacityBg2:setContentSize(CCSizeMake(self.bgSize.width-30,lbPosy-120))
	opacityBg2:setPosition(self.bgSize.width/2,121+(lbPosy-120)/2)
	self.bgLayer:addChild(opacityBg2)
	opacityBg2:setOpacity(0)
	self.opacityBg2=opacityBg2
	
	local sPosx=30
	if G_getCurChoseLanguage()=="ar" then
		sPosx = 160
	end
	local bgPosy=opacityBg2:getContentSize().height/2
	self.bgPosy = bgPosy
	local costStr=getlocal("raids_cost")
	local costLb=GetTTFLabelWrap(costStr,strSize2,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	costLb:setAnchorPoint(ccp(0,0.5))
	costLb:setPosition(ccp(sPosx,bgPosy))
	opacityBg2:addChild(costLb,1)
	local tempLb = GetTTFLabel(costStr,strSize2)
	local realWidth = tempLb:getContentSize().width
	if realWidth>costLb:getContentSize().width then
		realWidth=costLb:getContentSize().width
	end
	if G_getCurChoseLanguage()=="ar" then
		sPosx=sPosx-realWidth
	else
		sPosx=sPosx+costLb:getContentSize().width+10
	end
	local costIcon=CCSprite:createWithSpriteFrameName("resourse_normal_gem.png")
	local scale=80/costIcon:getContentSize().width
	costIcon:setScale(scale)
	costIcon:setAnchorPoint(ccp(0,0.5))
	costIcon:setPosition(sPosx,bgPosy)
	opacityBg2:addChild(costIcon)
	self.costIcon=costIcon

	if G_getCurChoseLanguage()=="ar" then
		sPosx=sPosx-costIcon:getContentSize().width*scale-10
	else
		sPosx=sPosx+costIcon:getContentSize().width*scale+10
	end
	self.sPosx=sPosx
	-- 默认值，无实际意义
	local needStr="1000k"
	local haveStr="1000M"

	local needLb=GetTTFLabel(needStr,20)
	opacityBg2:addChild(needLb)
	needLb:setAnchorPoint(ccp(0,0.5))
	needLb:setPosition(sPosx,bgPosy)
	self.needLb=needLb

	if G_getCurChoseLanguage()=="ar" then
		sPosx=sPosx-needLb:getContentSize().width
	else
		sPosx=sPosx+needLb:getContentSize().width
	end
	local haveLb=GetTTFLabel("/" .. haveStr,20)
	opacityBg2:addChild(haveLb)
	haveLb:setAnchorPoint(ccp(0,0.5))
	haveLb:setPosition(sPosx,bgPosy)
	self.haveLb=haveLb


	local notNeedStr = GetTTFLabel(getlocal("alliance_info_content"),24)
	opacityBg2:addChild(notNeedStr)
	notNeedStr:setAnchorPoint(ccp(0,0.5))
	notNeedStr:setPosition(80,bgPosy)
	self.notNeedStr = notNeedStr
	self.notNeedStr:setVisible(false)
	-- sPosx=sPosx+haveLb:getContentSize().width+10
	-- local function gotoCharge()
	-- 	if G_checkClickEnable()==false then
	-- 		do
	-- 			return
	-- 		end
	-- 	else
	-- 		base.setWaitTime=G_getCurDeviceMillTime()
	-- 	end
	-- 	self:close()
	-- 	vipVoApi:showRechargeDialog(self.layerNum+1)
	-- end
	-- local moreBtn=LuaCCSprite:createWithSpriteFrameName("moreBtn.png",gotoCharge)
	-- moreBtn:setAnchorPoint(ccp(0,0.5))
	-- moreBtn:setPosition(sPosx,bgPosy)
	-- opacityBg2:addChild(moreBtn)
	-- moreBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	-- self.moreBtn=moreBtn
	if G_getCurChoseLanguage()=="ar" then
		notNeedStr:setPositionX(costLb:getPositionX()-realWidth)
	end
end

function satelliteSearchSmallDialog:refreshOpacityBg2()
	local pic
	local needNum
	local haveNum
	local sbItem
	local specialTb=self.targetTb[self.subSelectIndex]

	if specialTb.notNeed then
		if self.gpsLb then
			self.gpsLb:setString(getlocal("inquiry"))
		end
		if self.costIcon then
			self.costIcon:setVisible(false)
		end
		if self.needLb then
			self.needLb:setVisible(false)
		end
		if self.haveLb then
			self.haveLb:setVisible(false)
		end

		if not self.notNeedStr then
			local notNeedStr = GetTTFLabel(getlocal("alliance_info_content"),24)
			self.opacityBg2:addChild(notNeedStr)
			notNeedStr:setAnchorPoint(ccp(0,0.5))
			notNeedStr:setPosition(80,self.bgPosy)
			self.notNeedStr = notNeedStr
		else
			self.notNeedStr:setVisible(true)
		end
	else
		if self.gpsLb then
			self.gpsLb:setString(getlocal("world_scene_location"))
		end
		if self.notNeedStr then
			self.notNeedStr:setVisible(false)
		end
		if self.costIcon then
			self.costIcon:setVisible(true)
		end
		if self.needLb then
			self.needLb:setVisible(true)
		end
		if self.haveLb then
			self.haveLb:setVisible(true)
		end

		if specialTb.need1 then
			local desc
			local bgname
			local name
			local satelliteVo=satelliteSearchVoApi:getSatelliteVo()
			local times
			if specialTb.type==1 then
				times=satelliteVo.raidNum or 0
				desc="satellite_des5"
				bgname="equipBg_blue.png"
				pic="awContribution.png"
				name=getlocal("sample_prop_name_974")
			elseif specialTb.type == 6 then
				times = satelliteVo.omgn or 0
				desc = "as_material_getway"
				bgname = "Icon_BG.png"
				pic = "airship_cl.png"
				name=getlocal("airship_material")
			else
				times=satelliteVo.goldNum or 0
				desc="satellite_des6"
				bgname="Icon_BG.png"
				pic="rpCoin.png"
				name=getlocal("rpshop_rpCoin")
			end

			needNum=specialTb.need1[times+1] or specialTb.need1[SizeOfTable(specialTb.need1)]
			if specialTb.type==1 then
				haveNum=allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid()) or 0
			elseif specialTb.type==6 then
				haveNum = airShipVoApi:formatPartsTb()
			else
				haveNum=playerVoApi:getRpCoin() or 0
			end
			
			local sbProp={p={p3305=1}}
			local propItem=FormatItem(sbProp)[1]
			propItem.bgname=bgname
			propItem.pic=pic
			propItem.name=name
			propItem.desc=desc
			sbItem=propItem
			
		else

			local propItem=FormatItem(specialTb.need2)
			pic=propItem[1].pic

			needNum=propItem[1].num
			haveNum=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(propItem[1].key)))

			sbItem=propItem[1]
		end
		local posX,posY=self.costIcon:getPosition()
		self.costIcon:removeFromParentAndCleanup(true)

		local function touchCostIcon()

			propInfoDialog:create(sceneGame,sbItem,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
		end
		self.costIcon=G_getItemIcon(sbItem,80,nil,self.layerNum+1,touchCostIcon)
		-- LuaCCSprite:createWithSpriteFrameName(pic,touchCostIcon)
		self.costIcon:setTouchPriority(-(self.layerNum-1)*20-4)
		self.costIcon:setAnchorPoint(ccp(0,0.5))
		self.costIcon:setScale(80/self.costIcon:getContentSize().width)
		self.costIcon:setPosition(posX,posY)
		self.opacityBg2:addChild(self.costIcon)

		local sPosx=self.sPosx
		self.needLb:setString(FormatNumber(needNum))
		self.needLb:setPositionX(sPosx)
		
		sPosx=sPosx+self.needLb:getContentSize().width
		self.haveLb:setString("/" .. FormatNumber(haveNum))
		self.haveLb:setPositionX(sPosx)

		if needNum<=haveNum then
			self.needLb:setColor(G_ColorWhite)
		else
			self.needLb:setColor(G_ColorRed)
		end
	end
end

function satelliteSearchSmallDialog:initTableView(lbPosy)
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,320),nil)
	self.tv:setTableViewTouchPriority((-(self.layerNum-1)*20-3))
	self.tv:setPosition(ccp(20,lbPosy-320-6))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)
	
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function satelliteSearchSmallDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(600,150*2)
       return tmpSize
   elseif fn=="tableCellAtIndex" then
   		local strSize2 = 19
		if G_isAsia() then
			strSize2 = 25
		end
		strSize2 = 20
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local iconBackPic
        if self.selectIndex==1 then
        	iconBackPic="Icon_BG.png"
        else
        	iconBackPic="equipBg_blue.png"
        end
       
        local startW=100
        local startH=150*2-60
        for k,v in pairs(self.targetTb) do
        	local indexX=k%3
	       	if indexX==0 then
	       		indexX=3
	       	end
	       	local function touchSpIcon(object,fn,idx)
	       		if G_checkClickEnable()==false then
					do
						return
					end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				if self.subSelectIndex==idx then
					return
				else
					self.subSelectIndex=idx
				end
				self.selectSp:setPosition(cell:getChildByTag(idx):getPosition())
				if self.selectIndex==1 then
					self.subSelectIndex1=self.subSelectIndex
					-- self:refreshOpacityBg1()
				else
					self.subSelectIndex2=self.subSelectIndex
					self:refreshOpacityBg2()
				end
	       	end
	       	local iconSp
	       	if self.selectIndex==1 then
	       		iconSp = GetBgIcon(v.icon,touchSpIcon,iconBackPic,70,100)
	       	else
	       		iconSp = LuaCCSprite:createWithSpriteFrameName(v.icon,touchSpIcon)
	       	end
	       	-- local iconSp = GetBgIcon(v.icon,touchSpIcon,iconBackPic,90,100)
	       	cell:addChild(iconSp)
	       	iconSp:setTag(k)
	       	iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
	       	iconSp:setPosition((indexX-1)*168+startW,startH)

	       	local nameLb=GetTTFLabelWrap(getlocal(v.name),strSize2,CCSizeMake(170,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	       	nameLb:setPosition((indexX-1)*168+startW,startH-75)
	       	cell:addChild(nameLb)

	       	if k==self.subSelectIndex then
	       		 local selectSp=CCSprite:createWithSpriteFrameName("equipSelectedRect.png")
	       		 cell:addChild(selectSp,1)
	       		 selectSp:setPosition((indexX-1)*168+startW,startH)
	       		 self.selectSp=selectSp

	       		 self.subSelectIndex=k
	       	end

	       	if k%3==0 then
	       		startH=startH-150
	       	end
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

function satelliteSearchSmallDialog:refreshTv(idx)
    self.selectIndex=idx
    self.targetTb={}

    if self.selectIndex==1 then
    	self.targetTb=mapScoutCfg.common
    	if self.subSelectIndex1==0 then
    		local dateTb=satelliteSearchVoApi:getSelectInfo(self.selectIndex)
    		self.subSelectIndex1=dateTb.index
    		-- 设置value
    		self.slider:setValue(dateTb.level)
    	end
    	self.subSelectIndex=self.subSelectIndex1
	else
		for k,v in pairs(mapScoutCfg.special) do
			if v.switch then
				if base[v.switch] == 1 then
					table.insert(self.targetTb,v)
				end
			else
				table.insert(self.targetTb,v)
			end
		end
		if self.subSelectIndex2==0 then
    		local subSelectIndex2=satelliteSearchVoApi:getSelectInfo(self.selectIndex)
    		self.subSelectIndex2=subSelectIndex2
    		self.subSelectIndex=self.subSelectIndex2
    		self:refreshOpacityBg2()
    	end
    	self.subSelectIndex=self.subSelectIndex2
    end

    self:refreshOpacityBg()
    self.tv:reloadData()
end


function satelliteSearchSmallDialog:refreshOpacityBg()
	if self.selectIndex==1 then
		if self.opacityBg1 then
			self.opacityBg1:setPositionX(self.bgSize.width/2)
		end
		if self.opacityBg2 then
			self.opacityBg2:setPositionX(99993)
		end
		
	else
		if self.opacityBg1 then
			self.opacityBg1:setPositionX(99993)
		end
		if self.opacityBg2 then
			self.opacityBg2:setPositionX(self.bgSize.width/2)
		end
	end
end

function satelliteSearchSmallDialog:tick()
	local satelliteVo=satelliteSearchVoApi:getSatelliteVo()
	if satelliteVo and satelliteVo.lastTime then
		if not G_isToday(satelliteVo.lastTime) then
			satelliteSearchVoApi:clearVo()
			if self.selectIndex==1 then
				self:refreshOpacityBg1()
			else
				self:refreshOpacityBg2()
			end
		end
	end
	
end




function satelliteSearchSmallDialog:dispose()
	self.gpsLb = nil
	spriteController:removePlist("public/acNewYearsEva.plist")
	spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
	spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
end
