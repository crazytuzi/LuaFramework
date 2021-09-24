ltzdzBuildingSmallDialog=smallDialog:new()

function ltzdzBuildingSmallDialog:new()
	local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzBuildingSmallDialog:showBuildingSelectDialog(layerNum,isuseami,isSizeAmi,callback)
    local sd=ltzdzBuildingSmallDialog:new()
    sd:initBuildingSelectDialog(layerNum,isuseami,isSizeAmi,callback)
    return sd
end

function ltzdzBuildingSmallDialog:showBuildingUpgradeOrRemoveDialog(build,layerNum,isuseami,isSizeAmi,callback)
	local sd=ltzdzBuildingSmallDialog:new()
    sd:initBuildingUpgradeOrRemoveDialog(build,layerNum,isuseami,isSizeAmi,callback)
    return sd
end

function ltzdzBuildingSmallDialog:initBuildingSelectDialog(layerNum,isuseami,isSizeAmi,callback)
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzBuildingSmallDialog",self)
	self.layerNum=layerNum
	self.isUseAmi=isuseami
	self.isSizeAmi=isSizeAmi
    self.dialogLayer=CCLayer:create()

    local function nilFunc( ... )
    end
    local itemHeight,spaceY=182,40
    local bgSize=CCSizeMake(630,3*itemHeight+2*spaceY+120)
    self.bgSize=bgSize
	local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
    dialogBg:setContentSize(bgSize)
    dialogBg:setOpacity(0)
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,1)

    self:show()

	local buildingCfg=ltzdzVoApi:getBuildingCfg()
    local mapCfg=ltzdzVoApi:getMapCfg()
    for k,btype in pairs(mapCfg.buildingType) do
        local itemBgSize=CCSizeMake(self.bgSize.width,itemHeight)
        local itemBg=G_getNewDialogBg2(itemBgSize,self.layerNum)
        itemBg:setPosition(self.bgSize.width/2,(self.bgSize.height-itemBgSize.height/2-30)-(k-1)*(itemBgSize.height+spaceY))
        self.bgLayer:addChild(itemBg)

        local cfg=buildingCfg[btype]
        local nameStr,descStr,buildPic=ltzdzCityVoApi:getBuildInfoByType(cfg.type)

        local titleBg=CCSprite:createWithSpriteFrameName("newTitleBg2.png")
        titleBg:setPosition(itemBgSize.width/2,itemBgSize.height)
        itemBg:addChild(titleBg)
        local titleLb=GetTTFLabelWrap(nameStr,24,CCSizeMake(titleBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        titleLb:setPosition(getCenterPoint(titleBg))
        titleLb:setColor(G_ColorYellowPro)
        titleBg:addChild(titleLb)

        local buildSp=CCSprite:createWithSpriteFrameName(buildPic)
        buildSp:setAnchorPoint(ccp(0,0.5))
        buildSp:setPosition(0,itemBgSize.height/2)
        itemBg:addChild(buildSp)

        local descLb=GetTTFLabelWrap(descStr,20,CCSizeMake(itemBgSize.width-350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLb:setAnchorPoint(ccp(0,1))
        descLb:setPosition(180,itemBgSize.height-40)
        itemBg:addChild(descLb)

        local newLineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
        newLineSp:setAnchorPoint(ccp(0,0.5))
        newLineSp:setContentSize(CCSizeMake(itemBgSize.width-360,newLineSp:getContentSize().height))
        newLineSp:setPosition(180,80)
        itemBg:addChild(newLineSp)

        local costRes=cfg.mineConsumeArr[1]
        local costTime=cfg.timeConsumeArr[1]

        local tmIcon=CCSprite:createWithSpriteFrameName("IconTime.png")
        tmIcon:setAnchorPoint(ccp(0,0.5))
        tmIcon:setPosition(180,40)
        itemBg:addChild(tmIcon)
        local timeLb=GetTTFLabel(GetTimeStr(costTime),22)
        timeLb:setAnchorPoint(ccp(0,0.5))
        timeLb:setPosition(tmIcon:getPositionX()+tmIcon:getContentSize().width,tmIcon:getPositionY())
        itemBg:addChild(timeLb)

        local resPic=ltzdzVoApi:getResPicByType(3)
        local resIcon=CCSprite:createWithSpriteFrameName(resPic)
        resIcon:setAnchorPoint(ccp(0,0.5))
        resIcon:setPosition(350,40)
        itemBg:addChild(resIcon)
        local costLb=GetTTFLabel(costRes,22)
        costLb:setAnchorPoint(ccp(0,0.5))
        costLb:setPosition(resIcon:getPositionX()+resIcon:getContentSize().width,resIcon:getPositionY())
        itemBg:addChild(costLb)

        local priority=-(self.layerNum-1)*20-4
        local function buildHandler()
            if callback then
                callback(cfg.type)
            end
            self:close()
        end
        local pos=ccp(itemBgSize.width-100,(itemBgSize.height-20)/2+35)
        local btnItm=G_createBotton(itemBg,pos,{getlocal("build"),22},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",buildHandler,0.7,priority)
        if otherGuideMgr.isGuiding==true then
            if k==1 then
                otherGuideMgr:setGuideStepField(58,btnItm)
            elseif k==2 then
                otherGuideMgr:setGuideStepField(60,btnItm)
            else
                otherGuideMgr:setGuideStepField(62,btnItm)
            end
        end
 

        local function batchBuildHandler()
            if callback then
                callback(cfg.type,true)
            end
            self:close()
        end
        local pos=ccp(itemBgSize.width-100,(itemBgSize.height-20)/2-35)
        G_createBotton(itemBg,pos,{getlocal("ltzdz_batch_build"),22},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",batchBuildHandler,0.7,priority)
    end
    local priority=-(self.layerNum-1)*20-4
    local function close()
        return self:close()
    end
    G_createBotton(self.bgLayer,ccp(bgSize.width/2,0),{getlocal("coverFleetBack"),24},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",close,0.8,priority)

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    self.dialogLayer:setPosition(0,0)
 	sceneGame:addChild(self.dialogLayer,self.layerNum)
end

function ltzdzBuildingSmallDialog:initBuildingUpgradeOrRemoveDialog(build,layerNum,isuseami,isSizeAmi,callback)
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzBuildingSmallDialog",self)
	self.layerNum=layerNum
	self.isUseAmi=isuseami
	self.isSizeAmi=isSizeAmi
    self.dialogLayer=CCLayer:create()

    local btype=build.btype
    local lv=build.lv
	local cfg=ltzdzVoApi:getBuildingCfg()[btype]
	if cfg==nil then
		do return nil end
	end

	local nameStr,descStr,buildPic=ltzdzCityVoApi:getBuildInfoByType(cfg.type,lv)

    local function close()
    	return self:close()
    end
    local bgSize=CCSizeMake(550,540)
    self.bgSize=bgSize
	local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(bgSize,nameStr,25,nil,self.layerNum,true,close)
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,1)

    self:show()

    local dialogHeight=100
    local iconWidth=150
	local buildSp=CCSprite:createWithSpriteFrameName(buildPic)
	buildSp:setAnchorPoint(ccp(0,1))
    buildSp:setScale(iconWidth/buildSp:getContentSize().width)
	self.bgLayer:addChild(buildSp)

    local posX=iconWidth+20
	local lvLb=GetTTFLabel(getlocal("fightLevel",{lv}),24)
    lvLb:setAnchorPoint(ccp(0,1))
    lvLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(lvLb)

    local descLb=GetTTFLabelWrap(descStr,18,CCSizeMake(self.bgSize.width-iconWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0,1))
    self.bgLayer:addChild(descLb)

    dialogHeight=dialogHeight+lvLb:getContentSize().height+descLb:getContentSize().height+80
    local priority=-(self.layerNum-1)*20-4
    local pos=ccp(self.bgSize.width-85,self.bgSize.height-220)
    local removeItem,removeBtn
    local scale=0.6
    if tonumber(btype)>2 then --普通资源建筑可以移除
        local function removeHandler() --移除
            local function confirm()
                if callback then
                    callback(false,true)
                end
                self:close()
            end
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("removeBlackList"),getlocal("ltzdz_removeBuilding_promptStr"),false,confirm)
        end
        removeItem,removeBtn=G_createBotton(self.bgLayer,pos,{getlocal("removeBlackList"),25},"newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",removeHandler,scale,priority)
        dialogHeight=dialogHeight+removeItem:getContentSize().height*scale+20
    end

    local kuangSp,tmIcon,timeLb,resIcon,costLb,upgradeBtn,upgradeBtnItem,batchUpgradeBtn,maxLvLb
    -- print("lv,cfg.maxLevel------>>>",lv,cfg.maxLevel)
    if lv<cfg.maxLevel then --如果小于最大等级，则显示升级功能
        local kuangWidth,kuangHeight=self.bgSize.width-40,0
        local function nilFunc()
        end
        kuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),nilFunc)
        kuangSp:setAnchorPoint(ccp(0.5,1))
        self.bgLayer:addChild(kuangSp)

        local nextLb=GetTTFLabelWrap(getlocal("ltzdz_nextLv"),20,CCSizeMake(kuangWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        nextLb:setAnchorPoint(ccp(0,1))
        kuangSp:addChild(nextLb)
        kuangHeight=kuangHeight+nextLb:getContentSize().height+10

        nameStr,descStr,buildPic=ltzdzCityVoApi:getBuildInfoByType(cfg.type,lv+1)
        local nextDescLb=GetTTFLabelWrap(descStr,18,CCSizeMake(kuangWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        nextDescLb:setAnchorPoint(ccp(0,1))
        nextDescLb:setColor(G_ColorGreen)
        kuangSp:addChild(nextDescLb)
        kuangHeight=kuangHeight+nextDescLb:getContentSize().height+30
        dialogHeight=dialogHeight+kuangHeight+20

        kuangSp:setContentSize(CCSizeMake(kuangWidth,kuangHeight))

        nextLb:setPosition(20,kuangSp:getContentSize().height-10)
        nextDescLb:setPosition(20,nextLb:getPositionY()-nextLb:getContentSize().height-20)

        local costRes=cfg.mineConsumeArr[lv+1] or 0
        local costTime=cfg.timeConsumeArr[lv+1] or 0

        tmIcon=CCSprite:createWithSpriteFrameName("IconTime.png")
        tmIcon:setAnchorPoint(ccp(0,0.5))
        self.bgLayer:addChild(tmIcon)
        timeLb=GetTTFLabel(GetTimeStr(costTime),22)
        timeLb:setAnchorPoint(ccp(0,0.5))
        self.bgLayer:addChild(timeLb)

        local resPic=ltzdzVoApi:getResPicByType(3)
        resIcon=CCSprite:createWithSpriteFrameName(resPic)
        resIcon:setAnchorPoint(ccp(0,0.5))
        self.bgLayer:addChild(resIcon)
        costLb=GetTTFLabel(costRes,22)
        costLb:setAnchorPoint(ccp(0,0.5))
        self.bgLayer:addChild(costLb)
        local metal=ltzdzFightApi:getMyRes()
        if tonumber(metal)<tonumber(costRes) then --资源不够
            costLb:setColor(G_ColorRed)
        end

        if tonumber(btype)>2 then --普通资源建筑可以批量升级
            pos=ccp(bgSize.width/2-120,60)
            local function batchUpgradeHandler() --批量升级
                if callback then
                    callback(true)
                end
                self:close()
            end
            local btnItem,btn=G_createBotton(self.bgLayer,pos,{getlocal("ltzdz_batch_upgrade"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",batchUpgradeHandler,0.8,priority)
            batchUpgradeBtn=btn
            pos=ccp(bgSize.width/2+120,60)
        else
            pos=ccp(bgSize.width/2,60)
        end

        local function upgradeHandler() --升级
            if callback then
                callback()
            end
            self:close()
            if otherGuideMgr.isGuiding and otherGuideMgr.curStep==65 then
                otherGuideMgr:toNextStep()
            end
        end
        upgradeBtnItem,upgradeBtn=G_createBotton(self.bgLayer,pos,{getlocal("upgradeBuild"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeHandler,0.8,priority)
        dialogHeight=dialogHeight+120
    else
        maxLvLb=GetTTFLabelWrap(getlocal("maxBuildLevel"),25,CCSizeMake(self.bgSize.width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.bgLayer:addChild(maxLvLb)
        dialogHeight=dialogHeight+120
    end

    self.bgSize=CCSizeMake(self.bgSize.width,dialogHeight)
    dialogBg:setContentSize(self.bgSize)
    titleBg:setPosition(self.bgSize.width/2,self.bgSize.height)
    closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width-4,self.bgSize.height-closeBtnItem:getContentSize().height-4))

    local posY=self.bgSize.height-70
    buildSp:setPosition(10,posY)
    posY=posY-30
    local posX=iconWidth+20
    lvLb:setPosition(posX,posY)
    descLb:setPosition(posX,lvLb:getPositionY()-lvLb:getContentSize().height-10)
    posY=posY-lvLb:getContentSize().height-descLb:getContentSize().height-50
    if removeBtn then
        removeBtn:setPosition(self.bgSize.width-85,posY-removeItem:getContentSize().height*scale/2)
        posY=posY-removeItem:getContentSize().height*scale/2-40
    end
    if kuangSp and tmIcon and timeLb and resIcon and costLb and upgradeBtn then
        kuangSp:setPosition(self.bgSize.width/2,posY)
        posY=posY-kuangSp:getContentSize().height-40

        tmIcon:setPosition(150,posY)
        timeLb:setPosition(tmIcon:getPositionX()+tmIcon:getContentSize().width,tmIcon:getPositionY())
        resIcon:setPosition(320,posY)
        costLb:setPosition(resIcon:getPositionX()+resIcon:getContentSize().width,resIcon:getPositionY())

        local pos=ccp(self.bgSize.width/2-120,60)
        if batchUpgradeBtn then
            batchUpgradeBtn:setPosition(pos)
            pos=ccp(self.bgSize.width/2+120,60)
        else
            pos=ccp(self.bgSize.width/2,60)
        end
        upgradeBtn:setPosition(pos)
    end

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(self.bgSize.width/2,120))
    mLine:setContentSize(CCSizeMake(self.bgSize.width-30,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)

    if maxLvLb then
        maxLvLb:setPosition(self.bgSize.width/2,60)
    end

    local function touchLuaSpr()    
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    self.dialogLayer:setPosition(0,0)
 	sceneGame:addChild(self.dialogLayer,self.layerNum)

    if otherGuideMgr.isGuiding and otherGuideMgr.curStep==64 then
        local x,y,width,height=G_getSpriteWorldPosAndSize(upgradeBtnItem,1)
        otherGuideCfg[65].clickRect=CCRectMake(x,y,width,height)
        otherGuideMgr:toNextStep()
    end
end

function ltzdzBuildingSmallDialog:dispose()
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzBuildingSmallDialog",self)
end