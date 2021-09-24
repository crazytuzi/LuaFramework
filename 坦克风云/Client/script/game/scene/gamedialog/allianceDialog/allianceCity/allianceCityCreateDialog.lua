allianceCityCreateDialog=commonDialog:new()

function allianceCityCreateDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function allianceCityCreateDialog:initTableView()
	self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-80)
	spriteController:addPlist("scene/allianceCityImages.plist")
	spriteController:addTexture("scene/allianceCityImages.png")
    spriteController:addPlist("public/resource_youhua.plist")
    spriteController:addTexture("public/resource_youhua.png")
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addTexture("public/datebaseShow.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")

	local myAlliance=allianceVoApi:getSelfAlliance()

	local function touchTip()
        local tabStr={}
        for i=1,5 do
            local str=getlocal("allinacecity_build_rule"..i)
            table.insert(tabStr,str)
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
	end
    G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight-130),nil,nil,1,nil,touchTip,true)

    local kuangWidth,kuangHeight=400,280
	local kuangSp=G_getThreePointBg(CCSizeMake(kuangWidth,kuangHeight),function () end,ccp(0.5,1),ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-100),self.bgLayer)

	local cityNameLb=GetTTFLabelWrap(myAlliance.name,24,CCSizeMake(kuangWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	cityNameLb:setPosition(kuangWidth/2,kuangHeight-cityNameLb:getContentSize().height/2-5)
	cityNameLb:setColor(G_ColorYellowPro)
	kuangSp:addChild(cityNameLb)
    local citySp=allianceCityVoApi:getAllianceCityIcon()
    citySp:setPosition(kuangWidth/2,kuangHeight/2-20)
    kuangSp:addChild(citySp)

    local function lookCityDetail()
        require "luascript/script/game/scene/gamedialog/allianceDialog/allianceCity/allianceCityPreviewDialog"
    	allianceCityPreviewDialog:showPreviewDialog(self.layerNum+1,true,true,nil,getlocal("createacityPreviewStr"),self.bgLayer)
    end
    local lookSp=LuaCCSprite:createWithSpriteFrameName("datebaseShow2.png",lookCityDetail)
    lookSp:setPosition(kuangWidth-lookSp:getContentSize().width/2-10,lookSp:getContentSize().height/2+5)
    lookSp:setTouchPriority(-(self.layerNum-1)*20-4)
    kuangSp:addChild(lookSp)

    local spaceY=-40
    if G_isIphone5()==true then
    	spaceY=-60
    end
	local lc,lcheight=3,120
	local unlockBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    unlockBg:setContentSize(CCSizeMake(616,60+lc*lcheight))
    unlockBg:setAnchorPoint(ccp(0.5,1))
    unlockBg:setPosition(G_VisibleSizeWidth/2,kuangSp:getPositionY()-kuangHeight+spaceY)
    self.bgLayer:addChild(unlockBg)

	local conditionLb=GetTTFLabelWrap(getlocal("buildCondition"),24,CCSizeMake(unlockBg:getContentSize().width-120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	conditionLb:setPosition(unlockBg:getContentSize().width/2,unlockBg:getContentSize().height-30)
	unlockBg:addChild(conditionLb)

	--创建城市限制条件
	local alv,memberc,activelv=(myAlliance.level or 0),(myAlliance.num or 9999),(myAlliance.alevel or 0)
	local bcCfg=allianceCityCfg.buildCondition
	local limitData={
		{pic="helpAlliance.png",cur=alv,limit=bcCfg[1],str=getlocal("allianceLvReach",{bcCfg[1]})},
		{pic="allianceMemberIcon.png",cur=memberc,limit=bcCfg[2],str=getlocal("allianceMemberReach",{bcCfg[2]})},
		{pic="allianceActiveIcon.png",cur=activelv,limit=bcCfg[3],str=getlocal("allianceActiveLvReach",{bcCfg[3]})},
	}
    for i=1,3 do
    	local data=limitData[i]
    	local posX,posY=unlockBg:getContentSize().width/2,unlockBg:getContentSize().height-60-i*lcheight
    	if i~=3 then
	    	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
	        lineSp:setContentSize(CCSizeMake(unlockBg:getContentSize().width-10,2))
	        lineSp:setRotation(180)
	        lineSp:setPosition(posX,posY)
	        unlockBg:addChild(lineSp)
    	end
    	local iconSp=CCSprite:createWithSpriteFrameName(data.pic)
    	iconSp:setPosition(60,posY+lcheight*0.5)
    	unlockBg:addChild(iconSp)

    	local barTag,barBgTag=i*10,i*12
    	local percent=(data.cur/data.limit)*100
	    AddProgramTimer(unlockBg,ccp(0,0),barTag,nil,nil,"res_progressbg.png","resyellow_progress.png",barBgTag)
	    local barSp=tolua.cast(unlockBg:getChildByTag(barTag),"CCProgressTimer")
	    local setScaleX=300/barSp:getContentSize().width
	    local setScaleY=30/barSp:getContentSize().height
	    barSp:setScaleX(setScaleX)
	    barSp:setScaleY(setScaleY)
	    barSp:setAnchorPoint(ccp(0,0.5))
	    barSp:setPosition(ccp(140,posY+lcheight*0.5-10))
	    barSp:setPercentage(percent)

	    local barBg=tolua.cast(unlockBg:getChildByTag(barBgTag),"CCSprite")
	    barBg:setScaleX(setScaleX)
	    barBg:setScaleY(setScaleY)
	    barBg:setAnchorPoint(ccp(0,0.5))
	    barBg:setPosition(140,posY+lcheight*0.5-10)

	    local percentLb=GetTTFLabel(data.cur.."/"..data.limit,18)
	    percentLb:setAnchorPoint(ccp(0.5,0.5))
	    percentLb:setPosition(barSp:getContentSize().width/2,barSp:getContentSize().height/2)
	    barSp:addChild(percentLb,4)
	    percentLb:setScaleX(1/setScaleX)
	    percentLb:setScaleY(1/setScaleY)

	    if i==3 then
	    	iconSp:setScale(0.8)
	    	local activelvLb=GetTTFLabel(data.cur,25)
	    	activelvLb:setPosition(getCenterPoint(iconSp))
	    	activelvLb:setColor(G_ColorYellow)
	    	iconSp:addChild(activelvLb)
	    end

		local limitLb=GetTTFLabelWrap(data.str,20,CCSizeMake(unlockBg:getContentSize().width-140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
		limitLb:setAnchorPoint(ccp(0.5,0))
		limitLb:setPosition(unlockBg:getContentSize().width/2,posY+lcheight*0.5+10)
		unlockBg:addChild(limitLb)
    end

    local priority=-(self.layerNum-1)*20-4
    local function buildHandler()
        local lefttime=allianceCityVoApi:getRebuildCoolingTime()--判断是否到了维护时间限制
        if lefttime>0 then --还没有到可以重新放置军团城市的时间
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("rebuildcityLimitStr",{math.ceil(allianceCityCfg.restartCity/60)}),28)
            do return end
        end
    	local flag=allianceCityVoApi:isCanBuildCity()
    	if flag~=0 then
    		local promptStr=""
    		if flag==1 then --权限不够
    			promptStr=getlocal("backstage8008")
			elseif flag==2 then --条件不满足
    			promptStr=getlocal("get_prop_error1")
    		end
         	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),promptStr,28)
    		do return end
    	end
    	--跳转世界地图进行建造
        activityAndNoteDialog:closeAllDialog()
    	local coords={x=playerVoApi:getMapX(),y=playerVoApi:getMapY()}
    	mainUI:changeToWorld(coords)
    	worldScene:createBuildLayer(playerVoApi:getMapX(),playerVoApi:getMapY(),1)
    end
	local buildItem,buildBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2,60),{getlocal("build")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",buildHandler,1,priority)

    local lefttime=allianceCityVoApi:getRebuildCoolingTime()
    local limitTimeLb=GetTTFLabelWrap(getlocal("rebuildcityLeftTimeStr",{GetTimeStr(lefttime)}),22,CCSizeMake(G_VisibleSizeWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    limitTimeLb:setPosition(G_VisibleSizeWidth/2,110+limitTimeLb:getContentSize().height/2)
    self.bgLayer:addChild(limitTimeLb)
    self.limitTimeLb=limitTimeLb
    if lefttime<=0 then
        self.limitTimeLb:setVisible(false)
    end
end

function allianceCityCreateDialog:tick()
    if self.limitTimeLb then
        local lefttime=allianceCityVoApi:getRebuildCoolingTime()
        if lefttime>0 then
            self.limitTimeLb:setVisible(true)
            self.limitTimeLb:setString(getlocal("rebuildcityLeftTimeStr",{GetTimeStr(lefttime)}))
        else
            self.limitTimeLb:setVisible(false)
        end
    end
end

function allianceCityCreateDialog:dispose()
	spriteController:removePlist("scene/allianceCityImages.plist")
	spriteController:removeTexture("scene/allianceCityImages.png")
    spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
end