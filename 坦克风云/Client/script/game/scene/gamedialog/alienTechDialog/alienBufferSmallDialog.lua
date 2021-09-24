alienBufferSmallDialog=smallDialog:new()

function alienBufferSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- category 坦克类别 四大类
-- tid 坦克id
function alienBufferSmallDialog:showalienBuffer(layerNum,istouch,isuseami,titleStr,category,tid)
	local sd=alienBufferSmallDialog:new()
    sd:initalienBuffer(layerNum,istouch,isuseami,titleStr,category,tid)
    return sd
end

function alienBufferSmallDialog:initalienBuffer(layerNum,istouch,isuseami,titleStr,category,tid)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum

    local nameFontSize=30
    local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
    -- 数据处理
    local bufftree=alienTechCfg.bufftree
    local bufferValue=bufftree[tid]
    local treeCfg=alienTechVoApi:getTreeCfg()
    local cfg=treeCfg[category]
    local point=alienTechVoApi:getPointByType(category)
    local maxLv=SizeOfTable(bufferValue)
    -- local str=getlocal("alien_tech_class_point",{point,cfg.totalPoint})

    local level,subTime=alienTechVoApi:getBufferLv(tid,category)
    print("level,subTime",level,subTime)

    titleStr=getlocal("alien_tech_buffer_name_"..tid)

    -- flag 1:未开启 2：已开启，不是最高等级 3：最大等级
    local flag=1
    if level==0 then
        flag=1
    else
        if level>=maxLv then
            flag=3
        else
            flag=2
        end
    end


    -- base:removeFromNeedRefresh(self) --停止刷新
    base:addNeedRefresh(self)

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dialogHeight2=500
    if flag==1 then
        dialogHeight2=380
    elseif flag==2 then
        dialogHeight2=420
    else
        dialogHeight2=260
    end

    -- 多语言直接改dialogHeight2的高度就能完成自适应
    local strSize2 = 21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 = 25
    end
    local dialogBg=G_getNewDialogBg2(CCSizeMake(580,60+dialogHeight2),self.layerNum,callback,titleStr,strSize2,titleColor)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer=dialogBg

    self:show()

    local function closeFunc()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    G_addForbidForSmallDialog(self.dialogLayer,dialogBg,-(layerNum-1)*20-3,closeFunc)

    local dialogSize=dialogBg:getContentSize()

    local dialogWidth2=dialogSize.width-40

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(dialogWidth2,dialogHeight2))
    dialogBg2:setAnchorPoint(ccp(0.5,0))
    dialogBg2:setPosition(dialogSize.width/2,30)
    self.bgLayer:addChild(dialogBg2)

    

    -- -- 图标
    local startW=20
    local spSize=100
    local iconPosY=dialogHeight2-spSize/2-20
    local iconSp = tankVoApi:getTankIconSp(id)
    local scale=spSize/iconSp:getContentSize().width
    iconSp:setAnchorPoint(ccp(0.5,0.5))
    iconSp:setPosition(ccp(spSize/2+startW,iconPosY))
    dialogBg2:addChild(iconSp,1)
    iconSp:setScale(scale)

    local lineposY=iconPosY-spSize/2-20
    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
    lineSp:setContentSize(CCSizeMake((dialogWidth2-40),2))
    lineSp:setRotation(180)
    lineSp:setPosition(dialogWidth2/2,lineposY)
    dialogBg2:addChild(lineSp)

    local titleFontSize=24

    -- -- print("level,maxTechLv",level,maxTechLv)
    if flag==1 then -- 未开启
        local desLb1PosX=spSize+startW+10
        local lowTime=bufferValue[1][1]
        local highTime=bufferValue[maxLv][1]
        local techId=bufferValue[1][3]
        local needPoint=bufferValue[1][2]
        local desStr=getlocal("alien_tech_buffer_des1",{getlocal(tankCfg[id].name),lowTime*100,1,highTime*100,maxLv})
        local colorTb={G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
        local desLb1,lbHeight=G_getRichTextLabel(desStr,colorTb,24,dialogWidth2-desLb1PosX-10,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        desLb1:setAnchorPoint(ccp(0,1))
        desLb1:setPosition(ccp(desLb1PosX,iconPosY+lbHeight/2-4))
        dialogBg2:addChild(desLb1,2)

        
        local stateLb=GetTTFLabelWrap(getlocal("not_open"),titleFontSize,CCSize(dialogWidth2-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)

        local titlePosY=lineposY-20-stateLb:getContentSize().height/2

        stateLb:setAnchorPoint(ccp(0,0.5))
        stateLb:setPosition(ccp(startW,titlePosY))
        dialogBg2:addChild(stateLb,1)
        -- stateLb:setColor(G_ColorGreen)

        local desFontSize=22
        local conditionW=startW+20
        local conditionH=titlePosY-stateLb:getContentSize().height/2-10
        -- 开启条件
        local conditionLb=GetTTFLabelWrap(getlocal("open_conditions"),desFontSize,CCSizeMake(dialogWidth2-40-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        conditionLb:setAnchorPoint(ccp(0,0.5))
        conditionLb:setPosition(ccp(conditionW,conditionH-conditionLb:getContentSize().height/2))
        dialogBg2:addChild(conditionLb)


        local conditionStr1=getlocal("alien_tech_open_condition1",{point,needPoint})
        local colorTb1={G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
        local conditionLb1,lbHeight1=G_getRichTextLabel(conditionStr1,colorTb1,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local des1PosY=conditionH-conditionLb:getContentSize().height-10-lbHeight1/2
        conditionLb1:setAnchorPoint(ccp(0,1))
        conditionLb1:setPosition(ccp(conditionW+25,des1PosY+lbHeight1/2-4))
        dialogBg2:addChild(conditionLb1,2)

        local checkIcon1
        if point>=needPoint then
            checkIcon1="IconCheck.png"
        else
            checkIcon1="IconFault.png"
        end
        local checkSp1=CCSprite:createWithSpriteFrameName(checkIcon1)
        dialogBg2:addChild(checkSp1)
        checkSp1:setPosition(conditionW+10,des1PosY-4)
        checkSp1:setScale(0.5)

        local conditionStr2=getlocal("alien_tech_open_condition2",{alienTechVoApi:getTechName(techId)})
        local colorTb2={G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
        local conditionLb2,lbHeight2=G_getRichTextLabel(conditionStr2,colorTb2,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local des2PosY=des1PosY-lbHeight1-10
        conditionLb2:setAnchorPoint(ccp(0,1))
        conditionLb2:setPosition(ccp(conditionW+25,des2PosY+lbHeight2/2-4))
        dialogBg2:addChild(conditionLb2,2)

        local checkIcon2
        local isUnlock=alienTechVoApi:getTechIsUnlock(techId,category,true)
        if isUnlock then
            checkIcon2="IconCheck.png"
        else
            checkIcon2="IconFault.png"
        end
        local checkSp2=CCSprite:createWithSpriteFrameName(checkIcon2)
        dialogBg2:addChild(checkSp2)
        checkSp2:setPosition(conditionW+10,des2PosY-4)
        checkSp2:setScale(0.5)



    elseif flag==2 then -- 开启但不是最大等级
        local lvLbPosX=spSize+startW+10
        local desStr=getlocal("current_level",{level})
        local colorTb={G_ColorYellowPro}
        local lvLb,lvHeight=G_getRichTextLabel(desStr,colorTb,24,dialogWidth2-lvLbPosX-10,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lvLb:setAnchorPoint(ccp(0,1))
        lvLb:setPosition(ccp(lvLbPosX,iconPosY+lvHeight/2+25))
        dialogBg2:addChild(lvLb,2)

        local colorTb={G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro,G_ColorGreen}
        local descStr=getlocal("alien_tech_buffer_des2",{getlocal(tankCfg[id].name),subTime*100})
        local desCriLb,desCriHeight=G_getRichTextLabel(descStr,colorTb,24,dialogWidth2-lvLbPosX-10,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        desCriLb:setAnchorPoint(ccp(0,1))
        desCriLb:setPosition(ccp(lvLbPosX,iconPosY+desCriHeight/2-25))
        dialogBg2:addChild(desCriLb,2)

        local stateLb=GetTTFLabelWrap(getlocal("nextLevelStr"),titleFontSize,CCSize(dialogWidth2-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)

        local titlePosY=lineposY-20-stateLb:getContentSize().height/2

        stateLb:setAnchorPoint(ccp(0,0.5))
        stateLb:setPosition(ccp(startW,titlePosY))
        dialogBg2:addChild(stateLb,1)
        -- stateLb:setColor(G_ColorGreen)

        local nextSubTime=bufferValue[level+1][1]
        local techId=bufferValue[level+1][3]
        local needPoint=bufferValue[level+1][2]

        local desFontSize=22

        -- 效果
        local effectStr=getlocal("effect") .. "<rayimg>" .. getlocal("alien_tech_buffer_des2",{getlocal(tankCfg[id].name),nextSubTime*100})
        local colorTbE={G_ColorWhite,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro,G_ColorGreen}
        local effectLb,effectHeight1=G_getRichTextLabel(effectStr,colorTbE,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        local effectPosY=titlePosY-stateLb:getContentSize().height/2-20-effectHeight1/2

        effectLb:setAnchorPoint(ccp(0,1))
        effectLb:setPosition(ccp(40,effectPosY+effectHeight1/2-4))
        dialogBg2:addChild(effectLb,2)


        -- -- 开启条件
        -- local conditionStr1=getlocal("alien_tech_open_condition",{point,needPoint,alienTechVoApi:getTechName(techId)})
        -- local desStr1=getlocal("open_conditions") .. conditionStr1
        -- local colorTb1={G_ColorWhite,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
        -- local desLb1,lbHeight1=G_getRichTextLabel(desStr1,colorTb1,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        -- local des1PosY=effectPosY-effectHeight1/2-10-lbHeight1/2

        -- desLb1:setAnchorPoint(ccp(0,1))
        -- desLb1:setPosition(ccp(40,des1PosY+lbHeight1/2-4))
        -- dialogBg2:addChild(desLb1,2)

        local conditionW=startW+20
        local conditionH=effectPosY-effectHeight1/2-10
        -- 开启条件
        local conditionLb=GetTTFLabelWrap(getlocal("open_conditions"),desFontSize,CCSizeMake(dialogWidth2-40-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        conditionLb:setAnchorPoint(ccp(0,0.5))
        conditionLb:setPosition(ccp(conditionW,conditionH-conditionLb:getContentSize().height/2))
        dialogBg2:addChild(conditionLb)


        local conditionStr1=getlocal("alien_tech_open_condition1",{point,needPoint})
        local colorTb1={G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
        local conditionLb1,lbHeight1=G_getRichTextLabel(conditionStr1,colorTb1,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local des1PosY=conditionH-conditionLb:getContentSize().height-10-lbHeight1/2
        conditionLb1:setAnchorPoint(ccp(0,1))
        conditionLb1:setPosition(ccp(conditionW+25,des1PosY+lbHeight1/2-4))
        dialogBg2:addChild(conditionLb1,2)

        local checkIcon1
        if point>=needPoint then
            checkIcon1="IconCheck.png"
        else
            checkIcon1="IconFault.png"
        end
        local checkSp1=CCSprite:createWithSpriteFrameName(checkIcon1)
        dialogBg2:addChild(checkSp1)
        checkSp1:setPosition(conditionW+10,des1PosY-4)
        checkSp1:setScale(0.5)

        local conditionStr2=getlocal("alien_tech_open_condition2",{alienTechVoApi:getTechName(techId)})
        local colorTb2={G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
        local conditionLb2,lbHeight2=G_getRichTextLabel(conditionStr2,colorTb2,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local des2PosY=des1PosY-lbHeight1-10
        conditionLb2:setAnchorPoint(ccp(0,1))
        conditionLb2:setPosition(ccp(conditionW+25,des2PosY+lbHeight2/2-4))
        dialogBg2:addChild(conditionLb2,2)

        local checkIcon2
        local isUnlock=alienTechVoApi:getTechIsUnlock(techId,category,true)
        if isUnlock then
            checkIcon2="IconCheck.png"
        else
            checkIcon2="IconFault.png"
        end
        local checkSp2=CCSprite:createWithSpriteFrameName(checkIcon2)
        dialogBg2:addChild(checkSp2)
        checkSp2:setPosition(conditionW+10,des2PosY-4)
        checkSp2:setScale(0.5)

    
    else -- 最大等级
        local lvLbPosX=spSize+startW+10
        local desStr=getlocal("current_level",{level .. "(MAX)"})
        local colorTb={G_ColorYellowPro}
        local lvLb,lvHeight=G_getRichTextLabel(desStr,colorTb,24,dialogWidth2-lvLbPosX-10,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lvLb:setAnchorPoint(ccp(0,1))
        lvLb:setPosition(ccp(lvLbPosX,iconPosY+lvHeight/2+25))
        dialogBg2:addChild(lvLb,2)

        local colorTb={G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro,G_ColorGreen}
        local descStr=getlocal("alien_tech_buffer_des2",{getlocal(tankCfg[id].name),subTime*100})
        local desCriLb,desCriHeight=G_getRichTextLabel(descStr,colorTb,24,dialogWidth2-lvLbPosX-10,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        desCriLb:setAnchorPoint(ccp(0,1))
        desCriLb:setPosition(ccp(lvLbPosX,iconPosY+desCriHeight/2-25))
        dialogBg2:addChild(desCriLb,2)

        local maxLb=GetTTFLabelWrap(getlocal("chapter_single_tech_max"),25,CCSizeMake(dialogBg2:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        maxLb:setAnchorPoint(ccp(0.5,0.5))
        maxLb:setPosition(dialogBg2:getContentSize().width/2,lineposY-20-40)
        dialogBg2:addChild(maxLb)

    end


    G_clickSreenContinue(self.bgLayer)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end



function alienBufferSmallDialog:goFunction(flag2,sidO)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
    if flag2==1 or flag2==3 then -- 跳转到能到的章节
        local sid=checkPointVoApi:getUnlockNum()
        require "luascript/script/game/scene/gamedialog/checkPointDialog"
        local cpd = checkPointDialog:new(sid)
        storyScene.checkPointDialog[1]=cpd
        local cd = cpd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("checkPoint"),true,self.layerNum)
        sceneGame:addChild(cd,self.layerNum)
    else -- 引导领取
        local sid=sidO
        require "luascript/script/game/scene/gamedialog/checkPointDialog"
        local cpd = checkPointDialog:new(sid)
        storyScene.checkPointDialog[1]=cpd
        local cd = cpd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("checkPoint"),true,self.layerNum)
        sceneGame:addChild(cd,self.layerNum)
         otherGuideMgr:toNextStep(40)
    end
    self:close()
end


function alienBufferSmallDialog:tick()
  
end


function alienBufferSmallDialog:dispose()

end

