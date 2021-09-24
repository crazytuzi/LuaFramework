ltzdzSmallMapDialog=smallDialog:new()

function ltzdzSmallMapDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function ltzdzSmallMapDialog:showPropInfo(layerNum,istouch,isuseami,callBack,parent)
	local sd=ltzdzSmallMapDialog:new()
    sd:initSmallMap(layerNum,istouch,isuseami,callBack,parent)
    return sd
end

function ltzdzSmallMapDialog:initSmallMap(layerNum,istouch,isuseami,pCallBack,parent)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.parent=parent
    local nameFontSize=30


    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
        PlayEffect(audioCfg.mouseClick)
        if pCallBack then
        	pCallBack()
        end
        return self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local scale=G_VisibleSizeWidth/self.parent.mapSize.x

    local bgSize=CCSizeMake(G_VisibleSizeWidth,scale*self.parent.mapSize.y)
    -- rewardItem
    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(self.dialogLayer:getContentSize().width/2,self.dialogLayer:getContentSize().height/2+50)
    self.dialogLayer:addChild(self.bgLayer,2)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local bg1=CCSprite:create("public/ltzdz/ltzdzMapBg1.jpg")
    dialogBg:addChild(bg1)
    bg1:setAnchorPoint(ccp(0,0))
    bg1:setPosition(0,0)
    local sbScale=bgSize.height/bg1:getContentSize().height
    bg1:setScale(sbScale)

    local bg2=CCSprite:create("public/ltzdz/ltzdzMapBg2.jpg")
    dialogBg:addChild(bg2)
    bg2:setAnchorPoint(ccp(0,0))
    bg2:setPosition(bg1:getContentSize().width*sbScale,0)
    bg2:setScale(sbScale)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)



    local mapKuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_minimap_kuang.png",CCRect(32,32,1,1),function ()end)
    dialogBg:addChild(mapKuangSp,4)
    mapKuangSp:setContentSize(bgSize)
    mapKuangSp:setPosition(getCenterPoint(dialogBg))

    local diInfoBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4, 4, 1, 1),function ()end)
    diInfoBg:setAnchorPoint(ccp(0.5,0))
    diInfoBg:setContentSize(CCSizeMake(bgSize.width,40))
    dialogBg:addChild(diInfoBg,2)
    diInfoBg:setPosition(bgSize.width/2,0)
    diInfoBg:setOpacity(120)

    local infoH=diInfoBg:getContentSize().height

    local currentLb=GetTTFLabelWrap(getlocal("ltzdz_current_select"),18,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    currentLb:setAnchorPoint(ccp(0,0.5))
    diInfoBg:addChild(currentLb)
    currentLb:setPosition(10,infoH/2)

    local currentBigS=self:getSp(1,0)
    diInfoBg:addChild(currentBigS)
    currentBigS:setAnchorPoint(ccp(0,0.5))
    currentBigS:setPosition(10+currentLb:getContentSize().width,infoH/2)

    local currentSmallS=self:getSp(2,0)
    diInfoBg:addChild(currentSmallS)
    currentSmallS:setAnchorPoint(ccp(0,0.5))
    currentSmallS:setPosition(10+currentLb:getContentSize().width+currentBigS:getContentSize().width+5,infoH/2)

    local selfLb=GetTTFLabel(getlocal("ltzdz_own_self"),18)
    -- GetTTFLabelWrap(getlocal("ltzdz_current_select"),18,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    selfLb:setAnchorPoint(ccp(0,0.5))
    diInfoBg:addChild(selfLb)
    selfLb:setPosition(190,infoH/2)

    local selfBigL=self:getSp(1,1)

    diInfoBg:addChild(selfBigL)
    selfBigL:setAnchorPoint(ccp(0,0.5))
    selfBigL:setPosition(190+selfLb:getContentSize().width,infoH/2)

    local selfSmallL=self:getSp(2,1)
    diInfoBg:addChild(selfSmallL)
    selfSmallL:setAnchorPoint(ccp(0,0.5))
    selfSmallL:setPosition(190+selfLb:getContentSize().width+selfSmallL:getContentSize().width+5,infoH/2)

    local allyLb=GetTTFLabel(getlocal("ltzdz_ally_1"),18)
    -- GetTTFLabelWrap(getlocal("ltzdz_current_select"),18,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    allyLb:setAnchorPoint(ccp(0,0.5))
    diInfoBg:addChild(allyLb)
    allyLb:setPosition(330,infoH/2)

    local allyBigS=self:getSp(1,2)
    diInfoBg:addChild(allyBigS)
    allyBigS:setAnchorPoint(ccp(0,0.5))
    allyBigS:setPosition(330+allyLb:getContentSize().width,infoH/2)

    local allySmallS=self:getSp(2,2)
    diInfoBg:addChild(allySmallS)
    allySmallS:setAnchorPoint(ccp(0,0.5))
    allySmallS:setPosition(330+allyLb:getContentSize().width+allyBigS:getContentSize().width+5,infoH/2)

    local enemyLb=GetTTFLabel(getlocal("acHongchangyuebingEnemy"),18)
    -- GetTTFLabelWrap(getlocal("ltzdz_current_select"),18,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    enemyLb:setAnchorPoint(ccp(0,0.5))
    diInfoBg:addChild(enemyLb)
    enemyLb:setPosition(480,infoH/2)

    local enemyBigS=self:getSp(1,3)
    diInfoBg:addChild(enemyBigS)
    enemyBigS:setAnchorPoint(ccp(0,0.5))
    enemyBigS:setPosition(480+enemyLb:getContentSize().width,infoH/2)

    local enemySmallS=self:getSp(2,3)
    diInfoBg:addChild(enemySmallS)
    enemySmallS:setAnchorPoint(ccp(0,0.5))
    enemySmallS:setPosition(480+enemyLb:getContentSize().width+enemyBigS:getContentSize().width+5,infoH/2)



    local function addFadeLight()
        local lightSp=LuaCCSprite:createWithSpriteFrameName("newGreenFadeLight.png",function() end)
        lightSp:setTouchPriority(-(layerNum-1)*20-2)
        lightSp:setAnchorPoint(ccp(0.5,0))
        lightSp:setScale((bgSize.width-80)/lightSp:getContentSize().width)
        lightSp:setPosition(bgSize.width/2,bgSize.height+50)
        dialogBg:addChild(lightSp)
        lightSp:setRotation(180)
    end

    G_addResource8888(addFadeLight)

    local titleBg=CCSprite:createWithSpriteFrameName("newTitleBg2.png")
    titleBg:setPosition(bgSize.width/2,bgSize.height+50)
    dialogBg:addChild(titleBg)


    local titleLb=GetTTFLabelWrap(getlocal("ltzdz_map"),24,CCSizeMake(titleBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(getCenterPoint(titleBg))
    -- titleLb:setColor(G_ColorYellowPro)
    titleBg:addChild(titleLb)

    -- local myPoint=CCSprite:createWithSpriteFrameName("miniMapLocation.png")
    local mapCfg=ltzdzVoApi:getMapCfg()
    local citycfg=mapCfg.citycfg
    local mapVo=ltzdzFightApi.mapVo or {}
    local cityVo
    if mapVo then
        cityVo=mapVo.city
    end
    local mapUser=mapVo.user

    local selfUserInfo=ltzdzFightApi:getUserInfo()
    local ally=selfUserInfo.ally or 0


    local cityTb={}
    local uid=playerVoApi:getUid()
    for k,v in pairs(citycfg) do
        local cType=v.type
        local pos=v.pos
        local allyFlag
        local color
        if cityVo and cityVo[k] and mapUser then
            local oid=cityVo[k].oid
            if oid then
                local colorId=mapUser[oid].c or 1
                color=ltzdzFightApi:getUserColor(colorId)
                if tonumber(oid)==tonumber(uid) then
                    allyFlag=1
                elseif tonumber(oid)==tonumber(ally) then
                    allyFlag=2
                else
                    allyFlag=3
                end
            end
        else
            allyFlag=0
        end

        local sp1,sp2=self:getCitySp(cType,allyFlag)
        if sp2 and color then
            sp2:setColor(color)
        end

        dialogBg:addChild(sp1)
        sp1:setPosition(pos[1]*scale,pos[2]*scale)
        cityTb[k]=sp1
    end

    local myView=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_selectRange.png",CCRect(4, 4, 1, 1),function()end)
    -- myView:setColor(G_ColorGreen)
    -- CCSprite:createWithSpriteFrameName("miniMapBtn_select.png")
    dialogBg:addChild(myView,1)
    myView:setAnchorPoint(ccp(0.5,0.5))
    self:miniMapMove(scale,bgSize,myView)

    -- 点击层
    local clayer=CCLayerColor:create(ccc4(0,0,0,0))
    clayer:setTouchEnabled(true)
    clayer:setTouchPriority(-(self.layerNum-1)*20-4)
    local function tmpHandler(fn,x,y,touch)
        if fn=="began" then
            return 1
        elseif fn=="ended" then
            local point=dialogBg:convertToNodeSpace(ccp(x,y))
            if point.x>0 and point.x<bgSize.width and point.y>0 and point.y<bgSize.height then
                local posX=math.floor(point.x/bgSize.width*self.parent.mapSize.x)
                local posY=math.floor(point.y/bgSize.height*self.parent.mapSize.y)
                if posX==0 then
                    posX=1
                end
                if posY==0 then
                    posY=1
                end
                if posX>self.parent.mapSize.x then
                    posX=self.parent.mapSize.x
                end
                if posY>self.parent.mapSize.y then
                    posY=self.parent.mapSize.y
                end
                self.parent:focus(posX,posY)
                self:miniMapMove(scale,bgSize,myView)
            end
        end
       
    end
    clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,false)
    clayer:setPosition(0,0)
    dialogBg:addChild(clayer)
    clayer:setContentSize(bgSize)

    local chatList=G_clone(ltzdzChatVoApi:getChatList(true))
    local chatNum=SizeOfTable(chatList)
    local hangNum=math.ceil(chatNum/2)

    -- 玩家信息
    local everyH=44
    local function touchDown()
    end
    local downSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_minimap_di.png",CCRect(50, 22, 1, 1),touchDown)
    dialogBg:addChild(downSp)
    downSp:setAnchorPoint(ccp(0.5,1))
    downSp:setContentSize(CCSizeMake(444,everyH*hangNum+13))
    downSp:setPosition(bgSize.width/2,0)
    downSp:setTouchPriority(-(layerNum-1)*20-2)

    local downSize=downSp:getContentSize()
    
    self.selectId=0
    local infoBgTb={}
    for k,v in pairs(chatList) do
        local userValue=v.value
        local userUid=v.uid

        local remainder=k%2
        local busniess=math.ceil(k/2)
        local posX
        local posY=downSize.height-(busniess-1)*everyH-everyH/2
        if remainder==1 then
            posX=downSize.width/4
        else
            posX=downSize.width/4*3
        end

        
        local function touchInfo()
            print("++++++",self.selectId,k)
            if self.selectId==k then
                return
            else
                if self.selectId~=0 then
                    infoBgTb[self.selectId]:setOpacity(0)
                end
                infoBgTb[k]:setOpacity(255)
                local flag=true
                for k,v in pairs(cityTb) do
                    if cityVo and cityVo[k] and mapUser then
                        local oid=cityVo[k].oid
                        if oid and tonumber(userUid)==tonumber(oid) then
                            if v then
                                if flag then
                                    local cityInfo=citycfg[k]
                                    local posX,posY=cityInfo.pos[1],cityInfo.pos[2]
                                    self.parent:focus(posX,posY)
                                    self:miniMapMove(scale,bgSize,myView)
                                    flag=false
                                end
                                v:setScale(1.3)
                                local strokeSp=tolua.cast(v:getChildByTag(101),"CCSprite")
                                if strokeSp then
                                    strokeSp:setColor(G_ColorWhite)
                                end


                            end
                        else
                            if v then
                                v:setScale(1)

                                if oid then
                                    local strokeSp=tolua.cast(v:getChildByTag(101),"CCSprite")
                                    if strokeSp then
                                        strokeSp:setColor(G_ColorBlack)
                                    end
                                end
                            end
                        end
                    end
                end
                self.selectId=k
            end
        end
        local infoBg=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),touchInfo)
        downSp:addChild(infoBg)
        infoBg:setAnchorPoint(ccp(0.5,0.5))
        infoBg:setContentSize(CCSizeMake((downSize.width/2)-40,everyH-4-10))
        infoBg:setTouchPriority(-(layerNum-1)*20-5)
        infoBg:setPosition(posX,posY-5)
        infoBg:setOpacity(0)

        infoBgTb[k]=infoBg

        local colorSp=CCSprite:createWithSpriteFrameName("ltzdzMiniBidCity.png")
        infoBg:addChild(colorSp)
        colorSp:setAnchorPoint(ccp(0,0.5))
        colorSp:setPosition(10,infoBg:getContentSize().height/2)

        if mapUser then
            local colorId=mapUser[tostring(userUid)].c or 1
            color=ltzdzFightApi:getUserColor(colorId)
            colorSp:setColor(color)
        end


        local nickNameLb=GetTTFLabel(userValue.nickname,22)
        infoBg:addChild(nickNameLb)
        nickNameLb:setAnchorPoint(ccp(0,0.5))
        nickNameLb:setPosition(45,infoBg:getContentSize().height/2)
    end




    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function ltzdzSmallMapDialog:miniMapMove(scale,bgSize,myView)
    local posX,posY=self.parent.clayer:getPosition()

    local scaleX=scale
    local scaleY=scaleX
    
    local backgroundScale=self.parent.background:getScale()

    local nowViewSize=CCSizeMake(scaleX*G_VisibleSizeWidth/backgroundScale,scaleY*G_VisibleSizeHeight/backgroundScale)
    myView:setContentSize(nowViewSize)
    local myViewSize=myView:getContentSize()

    local centerX=-posX+G_VisibleSizeWidth/2
    local centerY=-posY+G_VisibleSizeHeight/2

    
    
    local trueX=(centerX)*scaleX/backgroundScale
    local trueY=(centerY)*scaleY/backgroundScale

    if trueX>bgSize.width-myViewSize.width/2 then
        trueX=bgSize.width-myViewSize.width/2
    elseif trueX<myViewSize.width/2 then
        trueX=myViewSize.width/2
    end
    if trueY>bgSize.height-myViewSize.height/2 then
        trueY=bgSize.height-myViewSize.height/2
    elseif trueY<myViewSize.height/2 then
        trueY=myViewSize.height/2
    end
    myView:setPosition(trueX,trueY)
end

-- 1 大 2 小
function ltzdzSmallMapDialog:getNeedPic(flag)
    local cityPic1
    local cityPic2
    local light3
    if flag==1 then
        cityPic1="ltzdzMiniBidCity.png"
        cityPic2="ltzdzMiniBigCityStroke.png"
        light3="ltzdzMiniBigCityLight.png"
    else
        cityPic1="ltzdzMiniSmallCity.png"
        cityPic2="ltzdzMiniSmallCityStroke.png"
        light3="ltzdzMiniSmallCityLight.png"
    end
    return cityPic1,cityPic2,light3
end

function ltzdzSmallMapDialog:getSp(picFlag,spFlag)
    local cityPic1,cityPic2,light3=self:getNeedPic(picFlag)
    if spFlag==0 then -- 当前选中
        local strokeSp=CCSprite:createWithSpriteFrameName(cityPic2)
        return strokeSp
    else
        -- local strokeSp=CCSprite:createWithSpriteFrameName(cityPic2)
        local lightSp=CCSprite:createWithSpriteFrameName(light3)
        -- lightSp:addChild(strokeSp)
        -- strokeSp:setPosition(getCenterPoint(lightSp))
        local color=self:getSpColor(spFlag)
        lightSp:setColor(color)
        return lightSp
    end
end

function ltzdzSmallMapDialog:getCitySp(picFlag,spFlag)
    local cityPic1,cityPic2,light3=self:getNeedPic(picFlag)
    if spFlag==0 then -- 野城
        local citySp=CCSprite:createWithSpriteFrameName(cityPic1)
        local strokeSp=CCSprite:createWithSpriteFrameName(cityPic2)
        citySp:addChild(strokeSp)
        strokeSp:setColor(G_ColorBlack)
        strokeSp:setPosition(getCenterPoint(citySp))
        return citySp
    else
        local lightSp=CCSprite:createWithSpriteFrameName(light3)

        local citySp=CCSprite:createWithSpriteFrameName(cityPic1)
        citySp:setPosition(getCenterPoint(lightSp))
        lightSp:addChild(citySp,1)

        local strokeSp=CCSprite:createWithSpriteFrameName(cityPic2)
        lightSp:addChild(strokeSp,2)
        strokeSp:setColor(G_ColorBlack)
        strokeSp:setPosition(getCenterPoint(lightSp))
        strokeSp:setTag(101)

        local color=self:getSpColor(spFlag)
        lightSp:setColor(color)
        return lightSp,citySp
    end
end



-- flag 1:自己 2：同盟 3:敌人
function ltzdzSmallMapDialog:getSpColor(flag)
    if flag==1 then
        return ccc3(0,255,50)
    elseif flag==2 then
        return ccc3(5,220,240)
    else
        return ccc3(255,0,0)
    end
end



