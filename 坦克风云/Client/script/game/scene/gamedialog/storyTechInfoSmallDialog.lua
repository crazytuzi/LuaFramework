storyTechInfoSmallDialog=smallDialog:new()

function storyTechInfoSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function storyTechInfoSmallDialog:showStoryTechInfo(layerNum,istouch,isuseami,titleStr,cid)
	local sd=storyTechInfoSmallDialog:new()
    sd:initStoryTechInfo(layerNum,istouch,isuseami,titleStr,cid)
    return sd
end

function storyTechInfoSmallDialog:initStoryTechInfo(layerNum,istouch,isuseami,titleStr,cid)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum

    local nameFontSize=30

    -- 数据处理
    local challengeTechCfg=checkPointVoApi:getChallengeTechCfg()
    local cfg=challengeTechCfg[cid]
    local valueTab=cfg.value
    local pic=cfg.icon
    local id=(tonumber(cid) or tonumber(RemoveFirstChar(cid)))
    local isEffect,level=checkPointVoApi:getTechIsEffect(id)
    local maxTechLv=checkPointVoApi:getTechMaxLv(valueTab,id)

    titleStr=getlocal("sample_challenge_tech_name_"..id)

    -- flag 1:未开启 2：已开启，不是最高等级 3：最大等级
    local flag=1
    if isEffect==true then
        if level>=maxTechLv then
            flag=3
        else
            flag=2
        end
    else
        flag=1
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

    local dialogBg=G_getNewDialogBg2(CCSizeMake(580,60+dialogHeight2),self.layerNum,callback,titleStr,25,titleColor)
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

    

    -- 图标
    local startW=20
    local spSize=100
    local iconPosY=dialogHeight2-spSize/2-20
    local iconSp = CCSprite:createWithSpriteFrameName(pic)
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

    -- print("level,maxTechLv",level,maxTechLv)
    if flag==1 then -- 未开启
        local desLb1PosX=spSize+startW+10
        local desStr=getlocal(cfg.description2,{valueTab[1]*100,valueTab[maxTechLv]*100,maxTechLv})
        local colorTb={G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
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
        -- 开启条件
        local cRewardCfg,star=checkPointVoApi:getCRewardCfgByTech(id,1)
        local getConditionsStr=""
        if cRewardCfg and cRewardCfg.sid then
            getConditionsStr=getlocal("challenge_tech_get_conditions",{"<rayimg>" .. cRewardCfg.sid .. "<rayimg>","<rayimg>" .. star .. "<rayimg>"})
        end
        local desStr1=getlocal("open_conditions") .. "<rayimg>" .. getConditionsStr .. "<rayimg>"
        local colorTb1={G_ColorWhite,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
        local desLb1,lbHeight1=G_getRichTextLabel(desStr1,colorTb1,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        local des1PosY=titlePosY-stateLb:getContentSize().height/2-20-lbHeight1/2

        desLb1:setAnchorPoint(ccp(0,1))
        desLb1:setPosition(ccp(40,des1PosY+lbHeight1/2-4))
        dialogBg2:addChild(desLb1,2)

        -- 开启进度
        local checkPointVo = checkPointVoApi:getCheckPointVoBySid(cRewardCfg.sid)

        local progressStr=""
        local desStr2=""
        local btnStr=""
        local colorTb2={}

        local flag2=0
        -- print("checkPointVo.isUnlock",checkPointVo.isUnlock)
        if not (checkPointVo and checkPointVo.isUnlock) then -- 未解锁
            progressStr=getlocal("chapter_lock")
            desStr2=getlocal("open_progress") .. progressStr
            colorTb2={G_ColorWhite}
            btnStr=getlocal("go_open_chapter")
            flag2=1 -- 章节未解锁
        else -- 解锁
            local starNum=0
            if checkPointVo and checkPointVo.starNum then
                starNum=checkPointVo.starNum
            end
            local totalStarNum=checkPointVoApi:getCheckPointStarNum()
            if starNum>=totalStarNum then
                progressStr=getlocal("scheduleChapter",{"<rayimg>" .. starNum .. "<rayimg>",checkPointVoApi:getCheckPointStarNum()})
                desStr2=getlocal("open_progress") .. progressStr
                colorTb2={G_ColorWhite,G_ColorGreen,G_ColorYellowPro}
                btnStr=getlocal("go_open_get")
                flag2=2 -- 可领取
            else
                progressStr=getlocal("chapter_unlock_get")
                desStr2=getlocal("open_progress") .. "<rayimg>" .. progressStr .. "<rayimg>"
                colorTb2={G_ColorWhite,G_ColorYellowPro}
                btnStr=getlocal("go_open_chapter")
                flag2=3 -- 不可领取
            end
        end

        local desLb2,lbHeight2=G_getRichTextLabel(desStr2,colorTb2,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        local des2PosY=des1PosY-lbHeight1/2-10-lbHeight2/2

        desLb2:setAnchorPoint(ccp(0,1))
        desLb2:setPosition(ccp(40,des2PosY+lbHeight2/2-4))
        dialogBg2:addChild(desLb2,2)

        local btnPosY=des2PosY-lbHeight2/2-10-50

        local btnScale=140/207
        local function goFunction()
            self:goFunction(flag2,cRewardCfg.sid)
        end
        local goItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",goFunction,3,btnStr,24/btnScale)
        goItem:setScale(btnScale)
        local goBtn = CCMenu:createWithItem(goItem)
        dialogBg2:addChild(goBtn,1)
        goBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        goBtn:setBSwallowsTouches(true)
        goBtn:setPosition(dialogBg2:getContentSize().width/2,btnPosY)
    elseif flag==2 then -- 开启但不是最大等级
        local lvLbPosX=spSize+startW+10
        local desStr=getlocal("current_level",{level})
        local colorTb={G_ColorYellowPro}
        local lvLb,lvHeight=G_getRichTextLabel(desStr,colorTb,24,dialogWidth2-lvLbPosX-10,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lvLb:setAnchorPoint(ccp(0,1))
        lvLb:setPosition(ccp(lvLbPosX,iconPosY+lvHeight/2+25))
        dialogBg2:addChild(lvLb,2)

        local percent=(tonumber(cfg.value[level])*100).."%%"
        local descStr=getlocal(cfg.description,{percent})
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

        local desFontSize=22

        -- 效果
        local percent2=(tonumber(cfg.value[level+1])*100).."%%"
        local effectStr=getlocal("effect") .. "<rayimg>" .. getlocal(cfg.description,{"<rayimg>" .. percent2 .. "<rayimg>"}) .. "<rayimg>"
        local colorTbE={G_ColorWhite,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
        local effectLb,effectHeight1=G_getRichTextLabel(effectStr,colorTbE,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        local effectPosY=titlePosY-stateLb:getContentSize().height/2-20-effectHeight1/2

        effectLb:setAnchorPoint(ccp(0,1))
        effectLb:setPosition(ccp(40,effectPosY+effectHeight1/2-4))
        dialogBg2:addChild(effectLb,2)


        -- 开启条件
        local cRewardCfg,star=checkPointVoApi:getCRewardCfgByTech(id,level+1)
        local getConditionsStr=""
        if cRewardCfg and cRewardCfg.sid then
            getConditionsStr=getlocal("challenge_tech_get_conditions",{"<rayimg>" .. cRewardCfg.sid .. "<rayimg>","<rayimg>" .. star .. "<rayimg>"})
        end
        local desStr1=getlocal("open_conditions") .. "<rayimg>" .. getConditionsStr .. "<rayimg>"
        local colorTb1={G_ColorWhite,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro,G_ColorGreen,G_ColorYellowPro}
        local desLb1,lbHeight1=G_getRichTextLabel(desStr1,colorTb1,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        local des1PosY=effectPosY-effectHeight1/2-10-lbHeight1/2

        desLb1:setAnchorPoint(ccp(0,1))
        desLb1:setPosition(ccp(40,des1PosY+lbHeight1/2-4))
        dialogBg2:addChild(desLb1,2)

        -- 开启进度
        local checkPointVo = checkPointVoApi:getCheckPointVoBySid(cRewardCfg.sid)

        local progressStr=""
        local desStr2=""
        local btnStr=""
        local colorTb2={}

        local flag2=0
        -- print("checkPointVo.isUnlock",checkPointVo.isUnlock)
        if not (checkPointVo and checkPointVo.isUnlock) then -- 未解锁
            progressStr=getlocal("chapter_lock")
            desStr2=getlocal("open_progress") .. progressStr
            colorTb2={G_ColorWhite}
            btnStr=getlocal("go_open_chapter")
            flag2=1
        else -- 解锁
            local starNum=0
            if checkPointVo and checkPointVo.starNum then
                starNum=checkPointVo.starNum
            end
            local totalStarNum=checkPointVoApi:getCheckPointStarNum()
            if starNum>=totalStarNum then
                progressStr=getlocal("scheduleChapter",{"<rayimg>" .. starNum .. "<rayimg>",checkPointVoApi:getCheckPointStarNum()})
                desStr2=getlocal("open_progress") .. progressStr
                colorTb2={G_ColorWhite,G_ColorGreen,G_ColorYellowPro}
                btnStr=getlocal("go_open_get")
                flag2=2
            else
                progressStr=getlocal("chapter_unlock_get")
                desStr2=getlocal("open_progress") .. "<rayimg>" .. progressStr .. "<rayimg>"
                colorTb2={G_ColorWhite,G_ColorYellowPro}
                btnStr=getlocal("go_open_chapter")
                flag3=3
            end
        end

        local desLb2,lbHeight2=G_getRichTextLabel(desStr2,colorTb2,desFontSize,dialogWidth2-40-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        local des2PosY=des1PosY-lbHeight1/2-10-lbHeight2/2

        desLb2:setAnchorPoint(ccp(0,1))
        desLb2:setPosition(ccp(40,des2PosY+lbHeight2/2-4))
        dialogBg2:addChild(desLb2,2)

        local btnPosY=des2PosY-lbHeight2/2-10-50

        local btnScale=140/207
        local function goFunction()
            self:goFunction(flag2,cRewardCfg.sid)
        end
        local goItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",goFunction,3,btnStr,24/btnScale)
        goItem:setScale(btnScale)
        local goBtn = CCMenu:createWithItem(goItem)
        dialogBg2:addChild(goBtn,1)
        goBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        goBtn:setBSwallowsTouches(true)
        goBtn:setPosition(dialogBg2:getContentSize().width/2,btnPosY)
    else -- 最大等级
        local lvLbPosX=spSize+startW+10
        local desStr=getlocal("current_level",{level .. "(MAX)"})
        local colorTb={G_ColorYellowPro}
        local lvLb,lvHeight=G_getRichTextLabel(desStr,colorTb,24,dialogWidth2-lvLbPosX-10,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lvLb:setAnchorPoint(ccp(0,1))
        lvLb:setPosition(ccp(lvLbPosX,iconPosY+lvHeight/2+25))
        dialogBg2:addChild(lvLb,2)

        local percent=(tonumber(cfg.value[level])*100).."%%"
        local descStr=getlocal(cfg.description,{percent})
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



function storyTechInfoSmallDialog:goFunction(flag2,sidO)
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


function storyTechInfoSmallDialog:tick()
  
end


function storyTechInfoSmallDialog:dispose()

end

