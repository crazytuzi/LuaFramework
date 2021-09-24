require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryBlessSmallDialog"
acAnniversaryBlessTab1={}

function acAnniversaryBlessTab1:new()
    local nc={}
    nc.infoHeight=240
    nc.desLabel=nil
    nc.wordSpTb={}
    nc.bgSp=nil
    nc.promptLabel=nil
    nc.donateBtn=nil
    nc.receiveBtn=nil
    nc.inviteBtn=nil
    nc.isToday=true
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acAnniversaryBlessTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.acIsStoped=acAnniversaryBlessVoApi:acIsStop()
    self.fullCount=acAnniversaryBlessVoApi:getPlayerCountFulled()
    self:initTableView()

    local function requestListener(event,data)
        self:inviteFriendHandler(event,data)
    end
    self.requestListener=requestListener
    eventDispatcher:addEventListener("friend.onInviteFriend",self.requestListener)

    local function fullCollectedChanged(event,data)
        -- print("**********当前已集齐五福人数发生变化**********")
        if self then
            self:refreshPromptLb()
        end
    end
    self.fullCollectedChangedListener = fullCollectedChanged
    eventDispatcher:addEventListener("anniversaryBless.fullCollectedChanged",fullCollectedChanged)

    return self.bgLayer
end

function acAnniversaryBlessTab1:initTableView()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    self:initAcInfo()
    self:initBlessWordsView()

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acAnniversaryBlessTab1:initAcInfo()
    local function nilFunc( ... )
        -- body
    end

    if(G_isIphone5()) then
       self.infoHeight = 280
    end
    local bgWidth = self.bgLayer:getContentSize().width
    local bgHeight = self.bgLayer:getContentSize().height

    local bgSp = CCSprite:create("public/serverWarLocal/sceneBg.jpg")
    bgSp:setAnchorPoint(ccp(0.5,1))
    bgSp:setScale(0.99)
    bgSp:setPosition(ccp(bgWidth/2,bgHeight-self.infoHeight))
    self.bgLayer:addChild(bgSp,2)
    
    local blackBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    blackBg:setTouchPriority(-(self.layerNum-1)*20-1)
    blackBg:setContentSize(CCSizeMake(bgSp:getContentSize().width*bgSp:getScaleX(),bgSp:getContentSize().height*bgSp:getScaleY()))
    blackBg:setOpacity(200)
    blackBg:setAnchorPoint(ccp(0.5,1))
    blackBg:setPosition(bgWidth/2,bgHeight-self.infoHeight)
    self.bgLayer:addChild(blackBg,3)
    self.bgSp=blackBg
    local fontSize = 23
    local spaceX = -7
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        fontSize = 25
        spaceX = 0
    end
    local spaceY=185
    if G_isIphone5()==true then
        spaceY=200
    end
    local descStr1=acAnniversaryBlessVoApi:getTimeStr()
    local descStr2=acAnniversaryBlessVoApi:getRewardTimeStr()
    local moveBgStarStr = G_LabelRollView(CCSizeMake(bgWidth - 100,35),descStr1,fontSize,kCCTextAlignmentLeft,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
    moveBgStarStr:setPosition(ccp(bgWidth-moveBgStarStr:getContentSize().width+spaceX,bgHeight-moveBgStarStr:getContentSize().height-spaceY))
    self.bgLayer:addChild(moveBgStarStr,2)

    local function showAcInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local str1=getlocal("activity_anniversaryBless_rule1")
        local str2=getlocal("activity_anniversaryBless_rule2")
        local str3=getlocal("activity_anniversaryBless_rule3")
        local str4=getlocal("activity_anniversaryBless_rule4")
        tabStr={" ",str4,str3,str2,str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showAcInfo,11,nil,nil)
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(bgWidth-infoItem:getContentSize().width/2-20,bgHeight-160-infoItem:getContentSize().height/2))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoBtn)

    local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite1:setAnchorPoint(ccp(0.5,1))
    goldLineSprite1:setPosition(ccp(blackBg:getContentSize().width/2,blackBg:getContentSize().height))
    blackBg:addChild(goldLineSprite1)
    local goldLineSprite2 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite2:setAnchorPoint(ccp(0.5,0))
    goldLineSprite2:setRotation(180)
    goldLineSprite2:setPosition(ccp(blackBg:getContentSize().width/2,goldLineSprite2:getContentSize().height))
    blackBg:addChild(goldLineSprite2)

    local desStr=""
    if self.acIsStoped==true then
        desStr=getlocal("activity_anniversaryBless_prompt3",{acAnniversaryBlessVoApi:getPlayerCountFulled(),acAnniversaryBlessVoApi:getTotalGem()})
    else
        local num,wordNum=acAnniversaryBlessVoApi:getInviteCfg()
        desStr=getlocal("activity_anniversaryBless_des",{num,wordNum})
    end

    local desLabel=GetTTFLabelWrap(desStr,25,CCSizeMake(bgWidth-80,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    desLabel:setPosition(ccp(blackBg:getContentSize().width/2,blackBg:getContentSize().height-60))
    blackBg:addChild(desLabel,5)

    local promptPosY=blackBg:getPositionY()-blackBg:getContentSize().height-120
    if G_isIphone5()==true then
        promptPosY=blackBg:getPositionY()-blackBg:getContentSize().height-150
    end
    local promptBg = CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    promptBg:setAnchorPoint(ccp(0.5,0))
    promptBg:setScaleY(1.5)
    promptBg:setPosition(ccp(bgWidth/2,promptPosY))
    self.bgLayer:addChild(promptBg,9)

    local promptStr=""
    if acAnniversaryBlessVoApi:isCollectFull()==true then
        promptStr=getlocal("activity_anniversaryBless_prompt2",{acAnniversaryBlessVoApi:getPlayerCountFulled()})
    else
        promptStr=getlocal("activity_anniversaryBless_prompt1",{acAnniversaryBlessVoApi:getTotalGem(),acAnniversaryBlessVoApi:getPlayerCountFulled()})
    end
    local promptLabel = GetTTFLabelWrap(promptStr,25,CCSizeMake(G_VisibleSizeWidth-200,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    promptLabel:setAnchorPoint(ccp(0.5,0.5))
    promptLabel:setPosition(ccp(promptBg:getContentSize().width/2,promptBg:getContentSize().height/2))
    promptLabel:setColor(G_ColorYellow)
    promptLabel:setScaleY(1/1.5)
    promptBg:addChild(promptLabel)
    self.promptLabel=promptLabel

    local posX=80
    local space=(bgWidth-360-2*posX)/3
    local posY=80
    if G_isIphone5()==true then
        posY=150
    end
    local function onInviteFriend()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        --邀请好友只给港台开
        -- print("G_curPlatName()==",G_curPlatName())
        if((G_curPlatName()=="efunandroidtw" and G_Version<10) or (G_curPlatName()=="3" and G_Version<=4))then
            local tmpTb={}
            tmpTb["action"]="showSocialView"
            tmpTb["parms"]={}
            tmpTb["parms"]["uid"]=tostring(G_getTankUserName())
            tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
            tmpTb["parms"]["gameid"]=tostring(playerVoApi:getUid())
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        else
            friendVoApi:showSocialView()
        end
    end
    self.inviteBtn=self:createButtonItem("invite_fbfriend_btn.png",getlocal("friend_invite"),posX,posY,onInviteFriend)
    local function onReceiveGift()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local flag,state=acAnniversaryBlessVoApi:isCanReceiveInviteReward()
        if flag==false and state==1 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_anniversaryBless_prompt12"),30)
        elseif flag==false and state==2 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_anniversaryBless_prompt13"),30)
        elseif flag==true then
            self:receiveGift()
        end
    end
    local lightSp=CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    if G_isIphone5()==true then
        lightSp:setPosition(ccp(posX+1*(space+90)+50,195))
    else
        lightSp:setPosition(ccp(posX+1*(space+90)+50,125))
    end
    lightSp:setScale(0.8)
    self.bgLayer:addChild(lightSp)
    self.lightSp=lightSp
    self.receiveBtn=self:createButtonItem("bless_getword.png",getlocal("invite_friend_reward"),posX+1*(space+90),posY,onReceiveGift)
    if acAnniversaryBlessVoApi:isCanReceiveInviteReward()==false then
        -- self.receiveBtn:setEnabled(false)
        self.lightSp:setVisible(false)
    else
        -- self.receiveBtn:setEnabled(true)
        self.lightSp:setVisible(true)
    end

    local function onDonateGift()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if acAnniversaryBlessVoApi:isReachDonateLv()==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_anniversaryBless_prompt4",{acAnniversaryBlessVoApi:getDonateLv()}),30)
            return
        elseif acAnniversaryBlessVoApi:isCanDonateFriend()==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("acOver"),30)
            return
        end
        acAnniversaryBlessVoApi:openGameFriendsDialog(self.layerNum+1)
    end
    self.donateBtn=self:createButtonItem("send_blessword_btn.png",getlocal("activity_anniversaryBless_donate"),posX+2*(space+90),posY,onDonateGift)

    local function onGetRecord()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:onGetRecord()
    end
    self.recordBtn=self:createButtonItem("bless_record.png",getlocal("activity_anniversaryBless_record"),posX+3*(space+90),posY,onGetRecord)
    if self.acIsStoped==true then
        if self.inviteBtn and self.donateBtn and self.receiveBtn and self.lightSp then
            self.inviteBtn:setEnabled(false)
            self.donateBtn:setEnabled(false)
            self.receiveBtn:setEnabled(false)
            self.lightSp:setVisible(false)
        end
    end
end

function acAnniversaryBlessTab1:createButtonItem(spriteName,nameStr,posX,posY,btnHandler)
    local btn=GetButtonItem(spriteName,spriteName,spriteName,btnHandler,nil,"",25)
    local menu=CCMenu:createWithItem(btn)
    btn:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(posX,posY))
    menu:setTouchPriority((-(self.layerNum-1)*20-4))
    self.bgLayer:addChild(menu)

    local function nilFunc()
    end
    local btnNameBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilFunc)
    btnNameBg:setContentSize(CCSizeMake(120,40))
    btnNameBg:setAnchorPoint(ccp(0.5,1))
    btnNameBg:setPosition(ccp(btn:getContentSize().width/2,-10))
    btn:addChild(btnNameBg)
    local nameLb=GetTTFLabel(nameStr,25)
    nameLb:setPosition(ccp(btnNameBg:getContentSize().width/2,btnNameBg:getContentSize().height/2))
    btnNameBg:addChild(nameLb,1)
    nameLb:setColor(G_ColorYellowPro)
    return btn
end

function acAnniversaryBlessTab1:initBlessWordsView()
    local wordsData=acAnniversaryBlessVoApi:getWordsData()
    if wordsData==nil then
        do return end
    end
    local posX=80
    local posY=self.bgSp:getContentSize().height-200
    for k,word in pairs(wordsData) do
        local wordIcon,countLb = self:createWordItem(word.key,word.count)
        wordIcon:setAnchorPoint(ccp(0,0))
        if k==4 then
            posX=165
            posY=posY-wordIcon:getContentSize().height-20
        elseif k==5 then
            posX=335
        end
        if word.count==0 then
            wordIcon:setEnabled(false)
            countLb:setVisible(false)
        end
        wordIcon:setPosition(ccp(posX,posY))
        posX=posX+wordIcon:getContentSize().width+70
        self.bgSp:addChild(wordIcon)
        self.wordSpTb[word.key]=wordIcon
    end
end

function acAnniversaryBlessTab1:refreshBlessWordsView()
    local wordsData=acAnniversaryBlessVoApi:getWordsData()
    if wordsData==nil then
        do return end
    end

    for k,word in pairs(wordsData) do
        if self.wordSpTb and self.wordSpTb[word.key] then
            local wordSp=self.wordSpTb[word.key]
            local countLb=tolua.cast(wordSp:getChildByTag(101),"CCLabelTTF")
            -- print("word.count=========",word.count)
            if word.count>0 then
                wordSp:setEnabled(true)
                countLb:setVisible(true)
                countLb:setString(tostring(word.count))
            else
                wordSp:setEnabled(false)
                countLb:setVisible(false)
            end
        end
    end
end

function acAnniversaryBlessTab1:createWordItem(wordKey,count)
    if wordKey==nil then
        do return end
    end
    local function nilFunc()
    end
    local iconName=acAnniversaryBlessVoApi:getWordIconName(wordKey)
    local wordIcon=GetButtonItem(iconName,iconName,iconName,nilFunc)
    if count==nil then
        count=0
    end
    local countLb = GetTTFLabel(count,25)
    countLb:setAnchorPoint(ccp(1,0))
    countLb:setColor(G_ColorGreen)
    countLb:setPosition(ccp(wordIcon:getContentSize().width-5,0))
    wordIcon:addChild(countLb)
    countLb:setTag(101)
    return wordIcon,countLb
end

function acAnniversaryBlessTab1:receiveGift()
    local function onReceiveGift(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            self.receiveBtn:setEnabled(false)
            local oldFlag=acAnniversaryBlessVoApi:isCollectFull()
            acAnniversaryBlessVoApi:updateData(sData.data)
            acAnniversaryBlessVoApi:updateData(sData.data.anniversaryBless)
            local report={}
            if sData.data and sData.data.report then
                report=sData.data.report
            end
            local spriteNameTb={}
            if report then
                for k,v in pairs(report) do
                    local name=acAnniversaryBlessVoApi:getWordIconName(v)
                    table.insert(spriteNameTb,name)
                end
            end
            local newFlag=acAnniversaryBlessVoApi:isCollectFull()
            --如果自己当前集齐了五福就聊天推送全服
            if oldFlag~=newFlag and newFlag==true then
                local fullCount=acAnniversaryBlessVoApi:getPlayerCountFulled()
                local params={}
                params.finishNum=fullCount
                chatVoApi:sendUpdateMessage(33,params)
            end
            local function callBackHandler()
                self:refreshBlessWordsView()
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
            end
            smallDialog:showPropListAndSureDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_anniversaryBless_prompt11",{acAnniversaryBlessVoApi:getInviteCount()}),spriteNameTb,120,false,self.layerNum+1,G_ColorYellowPro,callBackHandler)
        end
    end
    socketHelper:receiveInviteGift(onReceiveGift)
end

function acAnniversaryBlessTab1:onGetRecord()
    --打开赠送记录
    acAnniversaryBlessVoApi:openRecordDialog(self.layerNum+1,self.bgLayer)
end

function acAnniversaryBlessTab1:inviteFriendHandler(event,data)
    local function onInviteCallBack(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            acAnniversaryBlessVoApi:updateData(sData.data.anniversaryBless)
            if self.receiveBtn and self.lightSp then
                if acAnniversaryBlessVoApi:isCanReceiveInviteReward()==false then
                    self.lightSp:setVisible(false)
                    -- self.receiveBtn:setEnabled(false)
                else
                    self.lightSp:setVisible(true)
                    -- self.receiveBtn:setEnabled(true)
                end
            end     
        end
    end
    local uidTb=data["uid"]
    local inviteCount=SizeOfTable(uidTb)
    -- print("inviteCount============",inviteCount)
    socketHelper:syncInviteCount(inviteCount,onInviteCallBack)
end

function acAnniversaryBlessTab1:tick()
    local isStop=acAnniversaryBlessVoApi:acIsStop()
    if isStop~=self.acIsStoped and isStop==true then
        if self.desTv and self.desLabel then
            local desStr=getlocal("activity_anniversaryBless_prompt3",{acAnniversaryBlessVoApi:getPlayerCountFulled(),acAnniversaryBlessVoApi:getTotalGem()})
            self.desLabel:setString(desStr)
        end

        -- if self.promptLabel then
        --     local parent=self.promptLabel:getParent()
        --     if parent then
        --         parent:setVisible(false)
        --     end
        -- end
        -- if self.wordSpTb then
        --     for k,v in pairs(self.wordSpTb) do
        --         v:setEnabled(false)
        --         local countLb=tolua.cast(v:getChildByTag(101),"CCLabelTTF")
        --         if countLb then
        --             countLb:setVisible(false)
        --         end
        --     end
        -- end
        if self.inviteBtn and self.donateBtn and self.receiveBtn and self.lightSp then
            self.inviteBtn:setEnabled(false)
            self.donateBtn:setEnabled(false)
            self.receiveBtn:setEnabled(false)
            self.lightSp:setVisible(false)
        end
        self.acIsStoped=true
        return
    end

    -- if acAnniversaryBlessVoApi:isToday()==true and self.isToday==true then
    --     if self.receiveBtn then
    --         self.receiveBtn:setEnabled(false)
    --     end
    --     self.isToday=false
    -- end

    if acAnniversaryBlessVoApi:isRefreshWords()==true then
        self:refreshBlessWordsView()
        self:refreshPromptLb()
    end
end

function acAnniversaryBlessTab1:refreshPromptLb()
    local promptStr=""
    if acAnniversaryBlessVoApi:isCollectFull()==true then
        promptStr=getlocal("activity_anniversaryBless_prompt2",{acAnniversaryBlessVoApi:getPlayerCountFulled()})
    else
        promptStr=getlocal("activity_anniversaryBless_prompt1",{acAnniversaryBlessVoApi:getTotalGem(),acAnniversaryBlessVoApi:getPlayerCountFulled()})
    end
    if self and self.promptLabel then
        self.promptLabel:setString(promptStr)
    end
end

function acAnniversaryBlessTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.inviteBtn=nil
    self.receiveBtn=nil
    self.recordBtn=nil
    self.donateBtn=nil
    self.lightSp=nil
    self.promptLabel=nil
    eventDispatcher:removeEventListener("friend.onInviteFriend",self.requestListener)
    eventDispatcher:removeEventListener("anniversaryBless.fullCollectedChanged",self.fullCollectedChangedListener)
end