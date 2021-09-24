acChrisEveTab1 ={}
function acChrisEveTab1:new(layerNum)
        local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.bgLayer                = nil
    nc.layerNum               = layerNum
    nc.bgScaleW               = nil
    nc.bgScaleH               = nil
    nc.tv                     =  nil
    nc.tv2                    = nil
    nc.wholeBgSp              = nil
    nc.sendGiftBgTb           = {}
    nc.sendGiftTb             = {}
    nc.sendGiftPosTb          = {}
    nc.sendGiftMaskTb         = {}
    nc.sendGiftDataTb         = {}
    nc.lockTb                 = {}
    nc.sendGiftChooseInDialog = nil
    nc.sendGiftUpMaskDialog   = nil
    nc.downBg                 = nil
    nc.smallBgSpSize          = nil
    nc.awardPicTb             = {}
    nc.selectSp               = nil
    nc.chooseSM               = nil
    nc.returnBtn              = nil
    nc.giftChooseBtn          = nil
    nc.chooseFriendBtnTb      = {}
    nc.chooseFriBtnMenu       = nil
    nc.choosePaygetValueStr   = nil
    nc.choosePayStr           = nil
    nc.sendTimes              = nil
    nc.giftBox                = nil
    nc.giftBoxIdx             = nil
    nc.xPic                   = nil
    nc.titleBg                = nil
    nc.smallBgTitleStr        = nil
    nc.sd                     = nil
    nc.isToday                = nil
    nc.chooseStr1             = nil
    nc.chooseStr2             = nil
    nc.choosedTbStr           = {}
    nc.lastNumsStrddd         = nil
    nc.isError                = false
    nc.version                = acChrisEveVoApi:getVersion()
    nc.grayBorderTb           = {}
    return nc;

end
function acChrisEveTab1:dispose( )
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
    self.url = nil
    self.grayBorderTb           =nil
    self.version                =nil
    self.choosedTbStr           =nil
    self.bgLayer                =nil
    self.layerNum               =nil
    self.bgScaleW               =nil
    self.bgScaleH               =nil
    self.wholeBgSp              =nil
    self.isError                =false
    self.tv                     = nil
    self.tv2                    =nil
    self.lastNumsStrddd         =nil
    self.sendGiftBgTb           =nil
    self.sendGiftTb             =nil
    self.sendGiftPosTb          =nil
    self.sendGiftMaskTb         =nil
    self.sendGiftDataTb         =nil
    self.lockTb                 =nil
    self.sendGiftChooseInDialog =nil
    self.sendGiftUpMaskDialog   =nil
    self.smallBgSpSize          =nil
    self.downBg                 =nil
    self.awardPicTb             =nil
    self.selectSp               =nil
    self.chooseSM               =nil
    self.returnBtn              =nil
    self.giftChooseBtn          =nil
    self.chooseFriendBtnTb      =nil
    self.chooseFriBtnMenu       =nil
    self.choosePaygetValueStr   =nil
    self.choosePayStr           =nil
    self.sendTimes              =nil
    self.giftBox                =nil
    self.giftBoxIdx             =nil
    self.xPic                   =nil
    self.titleBg                =nil
    self.smallBgTitleStr        =nil
    self.sd                     = nil
    self.isToday                =nil
end

function acChrisEveTab1:init()
    -- acChrisEveVoApi:setIidx( ) --拿到最大i 的
    accessoryVoApi:refreshData()--配件需要手动刷新 ，
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =28
    end

    self.isToday =acChrisEveVoApi:isToday()
    self.bgLayer=CCLayer:create()

    if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
        local cloud1 = CCSprite:createWithSpriteFrameName("snowBg_1.png")
        cloud1:setAnchorPoint(ccp(0,0.5))
        cloud1:setPosition(ccp(20,G_VisibleSizeHeight-159))
        self.bgLayer:addChild(cloud1,99999)
    
        local cloud2 = CCSprite:createWithSpriteFrameName("snowBg_2.png")
        cloud2:setAnchorPoint(ccp(1,1))
        cloud2:setPosition(ccp(G_VisibleSizeWidth-20,G_VisibleSizeHeight-154))
        self.bgLayer:addChild(cloud2,99999)
    end

    self:initTableView()

    return self.bgLayer
end

function acChrisEveTab1:initTableView( )
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local tvSize = CCSizeMake(G_VisibleSizeWidth-40 ,G_VisibleSizeHeight-182)
  local tvPos = ccp(20,23)
  if self.version == 5 then
        tvSize = CCSizeMake(G_VisibleSizeWidth ,G_VisibleSizeHeight-157)
        tvPos  = ccp(0,0)
  end
  self.tv=LuaCCTableView:createWithEventHandler(hd,tvSize,nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(tvPos)
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acChrisEveTab1:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then

        if self.version == 5 then
            return  CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-157)
        else
            return  CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-182)-- -100
        end
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()

        local function touch( )
        end     
        -- self.wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("chrisBgImage.jpg",CCRect(20, 20, 1, 1),touch)--拉霸动画背景
        -- self.wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-182))

        self.wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
        if self.version == 5 then
            self.wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-157))
        else
            self.wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-182))
        end
        self.wholeBgSp:setAnchorPoint(ccp(0,0))
        self.wholeBgSp:setOpacity(0)
        self.wholeBgSp:setPosition(ccp(0,0))
        cell:addChild(self.wholeBgSp)

        local adah = 0
        if G_getIphoneType() == G_iphoneX then
            adah = 110
        end

        if self.version == 5 then
            local girl_v5=CCSprite:createWithSpriteFrameName("girl_v5.png")
            girl_v5:setAnchorPoint(ccp(0.5,1))
            girl_v5:setPosition(self.wholeBgSp:getContentSize().width * 0.4,self.wholeBgSp:getContentSize().height * 0.65)
            self.wholeBgSp:addChild(girl_v5,1)
        elseif(acChrisEveVoApi:isNormalVersion())then
            print(" in isNormalVersion~~~~~~~~~")
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            local url=G_downloadUrl("active/" .. "acWmzz_bg.jpg")
            local function onLoadIcon(fn,icon)
                CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                if self and self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") then
                    if(self.wholeBgSp and tolua.cast(self.wholeBgSp,"LuaCCScale9Sprite"))then
                        self.wholeBgSp=tolua.cast(self.wholeBgSp,"LuaCCScale9Sprite")
                        icon:setAnchorPoint(ccp(0.5,0))
                        icon:setScaleX(0.95)
                        if(G_isIphone5())then
                            icon:setScaleY(1.3)
                        else
                            icon:setScaleY(1.07)
                        end
                        icon:setPosition(tolua.cast(self.wholeBgSp,"LuaCCScale9Sprite"):getContentSize().width/2,0+adah)
                        self.wholeBgSp:addChild(icon)
                    end
                end
                CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            end
            local webImage=LuaCCWebImage:createWithURL(url,onLoadIcon)

            local girl=CCSprite:createWithSpriteFrameName("acChrisGirl.png")
            local hand=CCSprite:createWithSpriteFrameName("acChrisGirl_1.png")
            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
            local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setScaleX((G_VisibleSizeWidth - 60)/lineSp:getContentSize().width)
            lineSp:setScaleY(1.2)
            if G_getIphoneType() == G_iphoneX then
                girl:setScale(0.85)
                girl:setAnchorPoint(ccp(0.5,0))
                girl:setPosition(200,0+adah)
                self.wholeBgSp:addChild(girl,1)
                hand:setScale(0.85)
                hand:setPosition(283,290+adah)
                self.wholeBgSp:addChild(hand,3)
                lineSp:setPosition(self.wholeBgSp:getContentSize().width/2,630+adah)
                lineSp1:setPosition(self.wholeBgSp:getContentSize().width/2,630+adah-webImage:getContentSize().height*1.3)
                self.wholeBgSp:addChild(lineSp,1)
                self.wholeBgSp:addChild(lineSp1,1)
            elseif(G_isIphone5())then
                girl:setScale(0.85)
                girl:setAnchorPoint(ccp(0.5,0))
                girl:setPosition(200,0)
                self.wholeBgSp:addChild(girl,1)
                hand:setScale(0.85)
                hand:setPosition(283,290)
                self.wholeBgSp:addChild(hand,3)
                lineSp:setPosition(self.wholeBgSp:getContentSize().width/2,630)
                self.wholeBgSp:addChild(lineSp,1)
            else
                girl:setScale(0.75)
                girl:setAnchorPoint(ccp(0.5,0))
                girl:setPosition(200,0)
                self.wholeBgSp:addChild(girl,1)
                hand:setScale(0.75)
                hand:setPosition(274,256)
                self.wholeBgSp:addChild(hand,3)
                lineSp:setPosition(self.wholeBgSp:getContentSize().width/2,510)
                self.wholeBgSp:addChild(lineSp,1)
            end
        else
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            self.wholeBgSp2 =CCSprite:create("public/chrisBgImage.jpg")
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

            self.bgScaleW=(G_VisibleSizeWidth-40)/self.wholeBgSp2:getContentSize().width
            self.bgScaleH=(G_VisibleSizeHeight-182)/self.wholeBgSp2:getContentSize().height
            self.wholeBgSp2:setScaleX((G_VisibleSizeWidth-40)/self.wholeBgSp2:getContentSize().width)
            self.wholeBgSp2:setScaleY((G_VisibleSizeHeight-182)/self.wholeBgSp2:getContentSize().height)
    
            self.wholeBgSp2:setAnchorPoint(ccp(0,0))
            self.wholeBgSp2:setPosition(ccp(0,0))
            self.wholeBgSp:addChild(self.wholeBgSp2)
            self:actionEye()
        end


        self:initWholeSp(self.wholeBgSp)
       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acChrisEveTab1:initWholeSp(bgDia)
    local strSize2 = 21
    local strSize3 = 19
    local strSize4 =16
    if G_isAsia() then--G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =24
        strSize3 =24
        strSize4 =24
    end
    if G_getCurChoseLanguage() =="ja" then
        strSize3 = 15
    end

    local function touch33(tag,object)
        print("tag---->",tag)
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then

            if tag>14 then
                self.sendGiftChooseInDialogMask:setPosition(ccp(0,0))--小板子遮罩
            end
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
            end

            if playerVoApi:getPlayerLevel()<30 and tag ~=1 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_chrisEve_no30"),30)
                self.sendGiftChooseInDialogMask:setPosition(ccp(0,99999))
                do return end
            end

            if tag < 30 then
                acChrisEveVoApi:setClickTag(tag-20)
            end
            PlayEffect(audioCfg.mouseClick)
            if tag ==21 then
                local selectSpTb = acChrisEveVoApi:getSelectTb()
                local chosIdx = acChrisEveVoApi:getChooseRewardIdx()
                local selecidx = acChrisEveVoApi:getSelectIdx()
                if chosIdx ==nil or chosIdx ==0 or selecidx ==nil or selecidx ==0 then
                    --activity_chrisEve_noChooseGift
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_chrisEve_noChooseGift"),30)
                    self.sendGiftChooseInDialogMask:setPosition(ccp(0,99999))
                    do return end
                end
            elseif tag ==31 then --acChrisEveVoApi:setSureFriend(friendsTb[idx])
                local friendsTb = acChrisEveVoApi:getSureFriend()
                if friendsTb==nil or SizeOfTable(friendsTb)==0 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noChooseFriend"),30)
                    self.sendGiftChooseInDialogMask:setPosition(ccp(0,99999))
                    do return end
                end
            end
            if tag ==1 then
                -- print("tag----->",tag)
                self:openInfo()
            elseif tag >10 and tag <14 then

                acChrisEveVoApi:setChooseRewardIdx(tag-10)
                if self.tv2 then
                    acChrisEveVoApi:setSelectIdx()
                    self.awardPicTb ={}
                    self.tv2:setVisible(true)
                    self.tv2:reloadData()
                end
                self:sendGiftChooseInDialogAction(tag,bgDia)
                for i=1,3 do
                    if i ==tag-10 then
                    else
                        self.sendGiftMaskTb[i]:setVisible(true)
                        self.lockTb[i]:setVisible(true)
                        self.sendGiftMaskTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y))
                        self.lockTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y))
                    end
                end
                -- print("tag---110-->",tag)
            elseif tag >20 and tag <25 then
                -- print("tag----->",tag)
                local function cancelF( )
                    if self.selectSp ~=nil then
                        self.selectSp:setVisible(false)
                        self.selectSp:removeFromParentAndCleanup(true)
                        self.selectSp=nil
                    end
                    -- self.selectSp =nil
                    for i=1,3 do
                        self.sendGiftMaskTb[i]:setVisible(false)
                        self.lockTb[i]:setVisible(false)
                        self.sendGiftMaskTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y+9999))
                        self.lockTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y+9999)) 
                    end

                    self.giftChooseBtn:setTag(21)
                    self.returnBtn:setTag(22)
                    self.chooseFriBtn:setEnabled(false)
                    self.sendGiftUpMaskDialog:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height+9999))
                end

                local function onFlipHandler2()
                    self.sendGiftChooseInDialogMask:setPosition(ccp(0,999999))--小板子遮罩
                    self.sendGiftUpMaskDialog:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height+9999))
                    if tag ==22 then
                        for i=1,3 do
                            self.sendGiftMaskTb[i]:setVisible(false)
                            self.lockTb[i]:setVisible(false)
                            self.sendGiftMaskTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y+9999))
                            self.lockTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y+9999)) 
                        end
                        acChrisEveVoApi:setSelectTb()
                        acChrisEveVoApi:setSelectIdx()
                        if self.selectSp ~=nil then
                            self.selectSp:setVisible(false)
                            self.selectSp:removeFromParentAndCleanup(true)
                            self.selectSp=nil
                        end
                    elseif tag ==21 then
                        local selectSpTb = acChrisEveVoApi:getSelectTb()
                        local chosIdx = acChrisEveVoApi:getChooseRewardIdx()
                        if self.selectSp ~=nil then
                            self.selectSp:removeFromParentAndCleanup(true)
                            self.selectSp =nil
                        end
                        self.selectSp =G_getItemIcon(selectSpTb,65,false,self.layerNum+1,cancelF)
                        -- self.selectSp:setScale(0.8)
                        self.selectSp:setTouchPriority(-(self.layerNum-1)*20-5)
                        self.selectSp:setScale((self.sendGiftMaskTb[chosIdx]:getContentSize().width-20)/self.selectSp:getContentSize().width)
                        self.selectSp:setPosition(ccp(self.sendGiftMaskTb[chosIdx]:getContentSize().width*0.5,self.sendGiftMaskTb[chosIdx]:getContentSize().height*0.5))
                        self.sendGiftMaskTb[chosIdx]:addChild(self.selectSp,99)

                        self.sendGiftMaskTb[chosIdx]:setVisible(true)
                        self.sendGiftMaskTb[chosIdx]:setPosition(ccp(self.sendGiftPosTb[chosIdx].x,self.sendGiftPosTb[chosIdx].y))
                        
                        local IconFault = CCSprite:createWithSpriteFrameName("IconFault.png")
                        IconFault:setAnchorPoint(ccp(0,1))
                        IconFault:setPosition(ccp(4,self.selectSp:getContentSize().height))
                        self.selectSp:addChild(IconFault,1)
                        if selectSpTb.type == "o" then
                            IconFault:setScale(1.2/IconFault:getScale())
                        end
                        self.giftChooseBtn:setTag(31)
                        self.returnBtn:setTag(32)
                        self.chooseFriBtn:setEnabled(true)
                    end

                end
                local callFunc=CCCallFunc:create(onFlipHandler2)
                local moveby=CCMoveTo:create(0.5,ccp(bgDia:getContentSize().width*0.5,1-bgDia:getContentSize().height*0.67))
                local acArr=CCArray:create()
                acArr:addObject(moveby)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                

                if tag ==22 then --返回
                    self.chooseGift:setColor(G_ColorWhite)
                    self.chooseFriend:setColor(G_ColorWhite)
                    self.choosePay:setColor(G_ColorWhite)
                    self.surePay:setColor(G_ColorWhite)
                    acChrisEveVoApi:setSelectIdx(0)
                    acChrisEveVoApi:setSelectTb()
                    
                    self.sendGiftChooseInDialog:runAction(seq)
                elseif tag ==21 then
                    local chosIdx = acChrisEveVoApi:getChooseRewardIdx()
                    local singleRewardTb,tbNums,lostGemsTbTop,inMyGiftTimesTb = acChrisEveVoApi:getWhiRewardTb(chosIdx)
                    local selecidx = acChrisEveVoApi:getSelectIdx()
                    local allSIdx = SizeOfTable(singleRewardTb)+1
                    -- print("selecidx------>",allSIdx,selecidx,allSIdx -selecidx)
                    if lostGemsTbTop[allSIdx-selecidx] <= inMyGiftTimesTb[allSIdx -selecidx] then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("sendTopStr"),30)
                        self.sendGiftChooseInDialogMask:setPosition(ccp(0,99999))
                            do return end
                    end
                    if acChrisEveVoApi:getSelectIdx() ==0 then-------------
                        do return end
                    else
                        self.sendGiftChooseInDialog:runAction(seq)
                    end
                end
            elseif tag ==25 then--好友按钮
                -- print("tag----->",tag)
                local function callbackList(fn,data)
                      local ret,sData=base:checkServerData(data)
                      if ret==true then
                            if sData and sData.data and sData.data.friends then
                                acChrisEveVoApi:setFriendTb(friendMailVoApi:getFriendTb())
                                local chooseFriendStr  = tolua.cast(self.giftChooseBtn:getChildByTag(21),"CCLabelTTF")
                                chooseFriendStr:setString(getlocal("rechargeGifts_giveLabel"))
                                for i=1,3 do
                                    local showTitle = tolua.cast(self.downBg:getChildByTag(10+i),"CCLabelTTF")
                                    showTitle:setVisible(true)
                                end

                                if self.tv2 then
                                    self.tv2:setVisible(true)
                                    self.tv2:reloadData()
                                end
                                -- print("in socket---tag>",tag)
                                self:sendGiftChooseInDialogAction(tag,bgDia)
                            else
                                --noFriends
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noFriends"),30)
                            end
                      end
                 end
                 socketHelper:friendsList(callbackList)
            
            elseif tag >30 and tag <35 then
                -- print("tag----->",tag)
                local function onFlipHandler30( )
                    tolua.cast(self.giftChooseBtn:getChildByTag(21),"CCLabelTTF"):setColor(G_ColorWhite)
                    self.sendGiftChooseInDialogMask:setPosition(ccp(0,999999))--

                    if tag ==32 then                        
                        self.sendGiftUpMaskDialog:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height+9999))
                    elseif tag ==31 then
                        if self.tv2 then
                            self.tv2:setVisible(true)
                            self.tv2:reloadData()
                        end
                        self:sendGiftChooseInDialogAction(31,bgDia)
                    end

                end

                local callFunc=CCCallFunc:create(onFlipHandler30)
                local moveby=CCMoveTo:create(0.5,ccp(bgDia:getContentSize().width*0.5,1-bgDia:getContentSize().height*0.67))
                local acArr=CCArray:create()
                acArr:addObject(moveby)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                self.sendGiftChooseInDialog:runAction(seq)
                self.tv2:setVisible(false)
                if tag ==32 then
                    self.chooseGift:setColor(G_ColorYellowPro)
                    self.chooseFriend:setColor(G_ColorWhite)
                    self.choosePay:setColor(G_ColorWhite)
                    self.surePay:setColor(G_ColorWhite)
                    self.chooseFriendBtnTb ={}
                    self.choosedTbStr ={}
    --是否需要改变按钮文字 应该需要

                    acChrisEveVoApi:setSureFriend()---
                elseif tag ==31 then

                    self.giftChooseBtn:setTag(41)
                    self.returnBtn:setTag(42)
                    acChrisEveVoApi:setClickTag(41)
                end
            elseif tag >40 and tag <45 then
                -- print("tag----->",tag)
                local function onFlipHandler40( )
                    self.sendGiftChooseInDialogMask:setPosition(ccp(0,99999))--小板子遮罩
                    -- self.sendGiftUpMaskDialog:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height+9999))
                    self.chooseGift:setColor(G_ColorWhite)
                    self.chooseFriend:setColor(G_ColorWhite)
                    self.choosePay:setColor(G_ColorYellowPro)
                    self.surePay:setColor(G_ColorWhite)
                    if tag ==42 then
                        self.giftChooseBtn:setTag(31)
                        self.returnBtn:setTag(32)
                        acChrisEveVoApi:setClickTag(5)
                        for i=1,3 do
                            local showTitle = tolua.cast(self.downBg:getChildByTag(10+i),"CCLabelTTF")
                            showTitle:setVisible(true)
                        end
                        if self.chooseFriendBtnTb and SizeOfTable(self.chooseFriendBtnTb)>0 then
                            self.chooseFriendBtnTb ={}
                            self.choosedTbStr ={}
                        end
                        if self.tv2 then
                            self.tv2:setVisible(true)
                            self.tv2:reloadData()
                        end
                        self:sendGiftChooseInDialogAction(25,bgDia)
                    elseif tag ==41 then
                        self.chooseGift:setColor(G_ColorWhite)
                        self.chooseFriend:setColor(G_ColorWhite)
                        self.choosePay:setColor(G_ColorWhite)
                        self.surePay:setColor(G_ColorWhite)
                        self.sendGiftUpMaskDialog:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height+9999))

                        self.chooseFriBtn:setEnabled(false)
                        self.chooseGift:setColor(G_ColorWhite)
                        self.chooseFriend:setColor(G_ColorWhite)
                        self.choosePay:setColor(G_ColorWhite)
                        self.surePay:setColor(G_ColorWhite)

                        for i=1,3 do
                            self.sendGiftMaskTb[i]:setVisible(false)
                            self.lockTb[i]:setVisible(false)
                            self.sendGiftMaskTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y+9999))
                            self.lockTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y+9999)) 
                        end
                        acChrisEveVoApi:setSureFriend()
                        acChrisEveVoApi:setSelectTb()
                        acChrisEveVoApi:setSelectIdx()

                        if self.selectSp ~=nil then
                            self.selectSp:setVisible(false)
                            self.selectSp:removeFromParentAndCleanup(true)
                            self.selectSp =nil
                        end
                    end

                end

                local callFunc=CCCallFunc:create(onFlipHandler40)
                local moveby=CCMoveTo:create(0.5,ccp(bgDia:getContentSize().width*0.5,1-bgDia:getContentSize().height*0.67))
                local acArr=CCArray:create()
                acArr:addObject(moveby)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)

                if tag ==42 then
                    self.chooseGift:setColor(G_ColorWhite)
                    self.chooseFriend:setColor(G_ColorWhite)
                    self.choosePay:setColor(G_ColorYellowPro)
                    self.surePay:setColor(G_ColorWhite)
    --是否需要改变按钮文字 应该需要
                    acChrisEveVoApi:setSureFriend()
                    self.sendGiftChooseInDialog:runAction(seq)
                    acChrisEveVoApi:setChoosePayType(3)
                elseif tag ==41 then
                            self.chooseGift:setColor(G_ColorWhite)
                            self.chooseFriend:setColor(G_ColorWhite)
                            self.choosePay:setColor(G_ColorWhite)
                            self.surePay:setColor(G_ColorYellowPro)


                    local chooseIdx = acChrisEveVoApi:getChooseRewardIdx()
                    local allDataTb = acChrisEveVoApi:getRewardTb( )
                    local singDataTb = allDataTb[chooseIdx]
                    local chooseType = acChrisEveVoApi:getChoosePayType()
                    local payNeedData = nil
                    local nowHas = nil
                    local needCostKey = nil
                    local sureDiaStr = nil
                    local giftData = acChrisEveVoApi:getWhiPayTb( )
                    -- print("giftData.index--->",giftData.index)
                    local tuid = acChrisEveVoApi:getTuid()
                    local friendTb =acChrisEveVoApi:getFriendTb()
                    local friendName =nil
                    for k,v in pairs(friendTb) do
                        if v.uid ==tuid then
                            friendName =v.nickname
                        end
                    end
                    local allGemsGost = giftData.p+giftData.g
                    if chooseType ==0 then --需要资源
                        local deData = giftData["n"]
                        for k,v in pairs(deData) do
                            for i,j in pairs(v) do
                                needCostKey =i
                                payNeedData =j
                            end
                            local costId = tonumber(RemoveFirstChar(needCostKey))
                            -- print("k--->",k,needCostKey,payNeedData,costId)
                            if k =="e" then
                                nowHas = accessoryVoApi:getShopPropNum()[needCostKey]
                                 acChrisEveVoApi:setCostType(k)
                            elseif k =="o" then
                                nowHas = tankVoApi:getTankCountByItemId(costId)
                            elseif k =="p" then
                                nowHas = bagVoApi:getItemNumId(costId)
                            -- elseif k =="h" then
                            elseif k=="w" then
                                nowHas = superWeaponVoApi:getCrystalNumByCid(needCostKey)
                            end
                            
                        end
                        -- print("nowHas~~~~~payNeedData~~~~~",nowHas,payNeedData)
                        local formatPayTb = FormatItem(giftData["n"],false)[1]
                        if nowHas and nowHas< payNeedData then
                            
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noEnoughProperty",{formatPayTb.name}),30)
                            do return end
                        end
                        local awrdTb = FormatItem(giftData["r"],false)[1]
                        sureDiaStr =getlocal("toSendSurebyTypeStr1",{friendName,awrdTb.name,awrdTb.num,giftData.p,formatPayTb.name,formatPayTb.num})
                    elseif chooseType ==1 then
                        if playerVoApi:getGems() < giftData.g then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noEnoughGold"),30)
                                do return end
                        else
                            -- acChrisEveVoApi:setCostType(1)
                            local awrdTb = FormatItem(giftData["r"],false)[1]
                            sureDiaStr=getlocal("toSendSurebyTypeStr2",{friendName,awrdTb.name,awrdTb.num,allGemsGost})
                        end

                    else
                        ---------noChoosePayType
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noChoosePayType"),30)
                        do return end
                    end
                    if playerVoApi:getGems() < giftData.p then
                        if(acChrisEveVoApi:isNormalVersion() or self.version == 5)then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_chrisEve_noGoldInChris_1"),30)
                        else
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_chrisEve_noGoldInChris"),30)
                        end
                        do return end
                    end

                    local sid = nil
                    for k,v in pairs(singDataTb) do
                        if v.index ==giftData.index then--chooseIdx
                            sid =acChrisEveVoApi:getWhiSid(chooseIdx,k)

                        end
                    end

                    local function sureHandler( )
                        local function sendRequestCallBack(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret ==true then
                                if sData and sData.data and sData.data.shengdanqianxi.s then
                                    acChrisEveVoApi:setSendGiftTimesTb(sData.data.shengdanqianxi.s)
                                end
                                if sData and sData.data and sData.data.shengdanqianxi.t then
                                    acChrisEveVoApi:setlastTime(sData.data.shengdanqianxi.t)
                                end
                                if sData and sData.data and sData.data.shengdanqianxi.v then
                                    acChrisEveVoApi:setLoveGems(sData.data.shengdanqianxi.v)
                                end
                                if sData and sData.data and sData.data.shengdanqianxi.ds then
                                    local topTimes = acChrisEveVoApi:getTopSendTime()
                                    acChrisEveVoApi:setSendAllTimes(sData.data.shengdanqianxi.ds)
                                    self.sendTimes:setString(getlocal("activity_chrisEve_sendTimes",{sData.data.shengdanqianxi.ds,topTimes}))
                                end
                                local chooseType = acChrisEveVoApi:getChoosePayType()
                                local curGems = playerVoApi:getGems()
                                -- print("chooseType---->",chooseType)
                                
                                if chooseType ==1 then
                                    -- print("chooseType-----curGems,allGemsGost,curGems-allGemsGost-----",chooseType,curGems,allGemsGost,curGems,allGemsGost)
                                    playerVoApi:setGems(curGems-allGemsGost)
                                elseif chooseType ==0 then
                                    playerVoApi:setGems(curGems-giftData.p)
                                end
                                if acChrisEveVoApi:getCostType() =="e" then--配件需要手动刷新
                                    accessoryVoApi:refreshData()
                                    local giftData = acChrisEveVoApi:getWhiPayTb()
                                end
                                self.giftChooseBtn:setTag(21)
                                self.returnBtn:setTag(22)
                                acChrisEveVoApi:setClickTag(0)
                                acChrisEveVoApi:setSureFriend()
                                local callFunc=CCCallFunc:create(onFlipHandler40)
                                local moveby=CCMoveTo:create(0.5,ccp(bgDia:getContentSize().width*0.5,1-bgDia:getContentSize().height*0.67))
                                local acArr=CCArray:create()
                                acArr:addObject(moveby)
                                acArr:addObject(callFunc)
                                local seq=CCSequence:create(acArr)
                                self.sendGiftChooseInDialog:runAction(seq)

                                --activity_chrisEve_sendGod
                                if(acChrisEveVoApi:isNormalVersion() or self.version == 5)then
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_chrisEve_sendGod_1"),30)
                                else
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_chrisEve_sendGod"),30)
                                end
                            else
                                local payTb = acChrisEveVoApi:getWhiPayTb( )
                                 self.sendGiftChooseInDialogMask:setPosition(ccp(0,99999))
                                 self.checkDownBtn:setVisible(false)
                                 acChrisEveVoApi:setChoosePayType(3)
                                 self.payTotalStr:setString(payTb.p) 
                            end
                            acChrisEveVoApi:setChoosePayType(3)
                        end
                        socketHelper:chrisEveSend(sendRequestCallBack,"send",chooseType,sid,tuid)
                    end 
                    local function cancelCallback( )
                        self.chooseGift:setColor(G_ColorWhite)
                        self.chooseFriend:setColor(G_ColorWhite)
                        self.choosePay:setColor(G_ColorYellowPro)
                        self.surePay:setColor(G_ColorWhite)
                    end 
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureHandler,getlocal("dialog_title_prompt"),sureDiaStr,nil,self.layerNum+1,nil,nil,cancelCallback)
                end
            end

        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
    end
    local function touch34(tag,object)
        print("in touch34----tag",tag)
        local function callbackAllRec( )
            
        end
        self.sd=acChrisEveSmallDialog:new(self.layerNum + 1)
        local dialog= self.sd:initTableView()
        sceneGame:addChild(dialog,self.layerNum)
    end

    -- local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),strSize2)
    -- acLabel:setAnchorPoint(ccp(0.5,1))
    -- acLabel:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height-5))
    -- acLabel:setColor(G_ColorGreen)
    -- bgDia:addChild(acLabel)

    -- local acVo = acChrisEveVoApi:getAcVo()
    -- local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt-86400)
    -- local messageLabel=GetTTFLabel(timeStr,strSize2)
    -- messageLabel:setAnchorPoint(ccp(0.5,1))
    -- messageLabel:setPosition(ccp(bgDia:getContentSize().width*0.5, bgDia:getContentSize().height-40))
    -- bgDia:addChild(messageLabel)
    -- self.timeLb=messageLabel
    local messageLabel=GetTTFLabel(acChrisEveVoApi:getTimeStr(),strSize2)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setPosition(bgDia:getContentSize().width * 0.5,bgDia:getContentSize().height-25)
    bgDia:addChild(messageLabel)
    self.timeLb=messageLabel
    self:updateAcTime()


    

    if self.version == 5 then
        local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
        timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
        timeBg:setAnchorPoint(ccp(0.5,1))
        timeBg:setOpacity(255*0.6)
        timeBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
        self.bgLayer:addChild(timeBg)

        messageLabel:setPositionY(messageLabel:getPositionY() + 15)
        
        local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch33,1,nil,0)
        menuItemDesc:setAnchorPoint(ccp(1,1))
        local menuDesc=CCMenu:createWithItem(menuItemDesc)
        menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
        menuDesc:setPosition(ccp(G_VisibleSizeWidth - 10,G_VisibleSizeHeight-167))
        self.bgLayer:addChild(menuDesc,1)
    else
        local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch33,1,nil,0)
        menuItemDesc:setAnchorPoint(ccp(1,1))
        local menuDesc=CCMenu:createWithItem(menuItemDesc)
        menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
        menuDesc:setPosition(ccp(bgDia:getContentSize().width-5,bgDia:getContentSize().height-5))
        bgDia:addChild(menuDesc,1)
    end

    local chooseFriendPic1,chooseFriendPic2 = "creatRoleBtn.png","creatRoleBtn_Down.png"
    local chooseBtnPosx,chooseBtnPosy = bgDia:getContentSize().width-10,10
    if self.version == 5 then
        chooseFriendPic1,chooseFriendPic2 = "newGreenBtn.png","newGreenBtn_down.png"
        chooseBtnPosy = 25
        chooseBtnPosx = bgDia:getContentSize().width-20
    end
    self.chooseFriBtn =GetButtonItem(chooseFriendPic1,chooseFriendPic2,chooseFriendPic1,touch33,25,getlocal("activity_peijianhuzeng_selectFriend"),25)
    self.chooseFriBtn:setAnchorPoint(ccp(1,0))
    self.chooseFriBtnMenu=CCMenu:createWithItem(self.chooseFriBtn)
    self.chooseFriBtnMenu:setPosition(ccp(chooseBtnPosx,chooseBtnPosy))
    self.chooseFriBtnMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    bgDia:addChild(self.chooseFriBtnMenu,1) 

    local needPosHeight = self.version ~=5 and messageLabel:getPositionY()-50 or messageLabel:getPositionY()-90

    local pointAddWidth = 140
    local kccChos = kCCTextAlignmentLeft
    if G_getCurChoseLanguage() =="ja" then
       kccChos = kCCTextAlignmentRight
    end
    self.chooseGift = GetTTFLabelWrap(getlocal("activity_chrisEve_chooseGift"),strSize3,CCSizeMake(100,0),kccChos,kCCVerticalTextAlignmentCenter)
    self.chooseGift:setAnchorPoint(ccp(0,0.5))
    
    self.chooseGift:setPosition(ccp(60,needPosHeight))
    bgDia:addChild(self.chooseGift,1)

    local rightPoint1 = CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
    rightPoint1:setScaleY(0.3)
    -- rightPoint1:setScaleX(1.2)
    rightPoint1:setRotation(180)
    rightPoint1:setAnchorPoint(ccp(0,0.5))
    rightPoint1:setPosition(ccp(self.chooseGift:getPositionX()+pointAddWidth,needPosHeight))
    bgDia:addChild(rightPoint1,1)

    self.chooseFriend = GetTTFLabelWrap(getlocal("activity_chrisEve_chooseFriend"),strSize3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.chooseFriend:setAnchorPoint(ccp(0,0.5))
    self.chooseFriend:setPosition(ccp(rightPoint1:getPositionX()-10,needPosHeight))
    bgDia:addChild(self.chooseFriend,1)

    local rightPoint2 = CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
    rightPoint2:setScaleY(0.3)
    -- rightPoint2:setScaleX(1.2)
    rightPoint2:setRotation(180)
    rightPoint2:setAnchorPoint(ccp(0,0.5))
    rightPoint2:setPosition(ccp(self.chooseFriend:getPositionX()+pointAddWidth,needPosHeight))
    bgDia:addChild(rightPoint2,1)

    self.choosePay = GetTTFLabelWrap(getlocal("activity_chrisEve_choosePay"),strSize3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.choosePay:setAnchorPoint(ccp(0,0.5))
    self.choosePay:setPosition(ccp(rightPoint2:getPositionX()-10,needPosHeight))
    bgDia:addChild(self.choosePay,1)

    local rightPoint3 = CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
    rightPoint3:setScaleY(0.3)
    -- rightPoint3:setScaleX(1.2)
    rightPoint3:setRotation(180)
    rightPoint3:setAnchorPoint(ccp(0,0.5))
    rightPoint3:setPosition(ccp(self.choosePay:getPositionX()+pointAddWidth,needPosHeight))
    bgDia:addChild(rightPoint3,1)

    self.surePay = GetTTFLabelWrap(getlocal("activity_chrisEve_surePay"),strSize3,CCSizeMake(110,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.surePay:setAnchorPoint(ccp(0,0.5))
    self.surePay:setPosition(ccp(rightPoint3:getPositionX()-10,needPosHeight))
    bgDia:addChild(self.surePay,1)

    local bgIconPosHeight = self.surePay:getPositionY() -80
    local posH =bgDia:getContentSize().height*0.4+10
    if G_isIphone5() then
        bgIconPosHeight = self.surePay:getPositionY() -120
        posH = bgDia:getContentSize().height*0.4 -30
    end

    --friendBtn.png
    if self.version == 5 then
        self.giftBox=GetButtonItem("packs6.png","packs6.png","packs6.png",touch34,1,nil)
    elseif(acChrisEveVoApi:isNormalVersion())then
        self.giftBox=GetButtonItem("acChrisBox.png","acChrisBox.png","acChrisBox.png",touch34,1,nil)
        self.giftBox:setScale(0.8)
    else
        self.giftBox=GetButtonItem("friendBtn.png","friendBtnDOwn.png","friendBtn.png",touch34,1,nil)
    end
    self.giftBox:setAnchorPoint(ccp(0.5,0.5))
    local giftBoxMenu=CCMenu:createWithItem(self.giftBox)
    if self.version == 5 then
        giftBoxMenu:setPosition(ccp(bgDia:getContentSize().width*0.73,bgDia:getContentSize().height * 0.47))
        if not G_isIphone5() then
            giftBoxMenu:setPositionY(giftBoxMenu:getPositionY() - 40)
        end
    elseif(acChrisEveVoApi:isNormalVersion())then
        if(G_isIphone5())then
            giftBoxMenu:setPosition(ccp(300,370))
        else
            giftBoxMenu:setPosition(ccp(300,340))
        end
    else
        giftBoxMenu:setPosition(ccp(bgDia:getContentSize().width*0.7,posH))
    end
    giftBoxMenu:setTouchPriority(-(self.layerNum-1)*20-6)
    bgDia:addChild(giftBoxMenu,2) 

------runAction------
    local time = 0.14
    local rotate1=CCRotateTo:create(time, 30)
    local rotate2=CCRotateTo:create(time, -30)
    local rotate3=CCRotateTo:create(time, 20)
    local rotate4=CCRotateTo:create(time, -20)
    local rotate5=CCRotateTo:create(time, 0)

    local delay=CCDelayTime:create(1)
    local acArr=CCArray:create()
    acArr:addObject(rotate1)
    acArr:addObject(rotate2)
    acArr:addObject(rotate3)
    acArr:addObject(rotate4)
    acArr:addObject(rotate5)
    acArr:addObject(delay)
    local seq=CCSequence:create(acArr)
    local repeatForever=CCRepeatForever:create(seq)
    self.giftBox:runAction(repeatForever)
-------

    self.xPic =CCSprite:createWithSpriteFrameName("xPic.png")
    self.xPic:setScale(0.3)
    self.xPic:setAnchorPoint(ccp(0,0.5))
    self.xPic:setPosition(ccp(self.giftBox:getContentSize().width*0.5+giftBoxMenu:getPositionX(),posH-20))
    bgDia:addChild(self.xPic,1)

    if self.version == 5 then
        self.xPic:setPositionY(giftBoxMenu:getPositionY())
    end

    local firT = acChrisEveVoApi:getFirstRecTime()
    local recList = acChrisEveVoApi:getRecGiftTb()
    local otherDat,maxNum =acChrisEveVoApi:getRecGiftTbNoName()
    local recIdx = 0
    if firT ==0  then
        recIdx =1
    end
    recIdx =maxNum+recIdx

    self.giftBoxIdx =GetBMLabel(recIdx,G_GoldFontSrc,30)
    self.giftBoxIdx:setPosition(ccp(self.xPic:getPositionX()+self.xPic:getContentSize().width*0.25,self.xPic:getPositionY()))
    self.giftBoxIdx:setAnchorPoint(ccp(0,0.5))
    bgDia:addChild(self.giftBoxIdx,1)

    local acVo = acChrisEveVoApi:getAcVo()

    if recIdx ==0 or base.serverTime > acVo.acEt then
        self.giftBox:setVisible(false)
        self.xPic:setVisible(false)
        self.giftBoxIdx:setVisible(false)
    end

    local topTimes = acChrisEveVoApi:getTopSendTime( )
    local curSendTimes = acChrisEveVoApi:getSendAllTimes()
    local adaWidth = 200
    if G_getCurChoseLanguage() == "ko" and self.version == 5 then
        adaWidth = 300
    end
    self.sendTimes =GetTTFLabelWrap(getlocal("activity_chrisEve_sendTimes",{curSendTimes,topTimes}),strSize2,CCSizeMake(adaWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.sendTimes:setColor(G_ColorYellowPro)
    self.sendTimes:setAnchorPoint(ccp(0,0.5))
    self.sendTimes:setPosition(ccp(20,50))
    bgDia:addChild(self.sendTimes,1)

    if self.version == 5 then
        self.sendTimes:setAnchorPoint(ccp(0.5,1))
        self.sendTimes:setPosition(chooseBtnPosx - 80,chooseBtnPosy + 105)
        self.sendTimes:setColor(G_ColorWhite)
    end

    local isToday = acChrisEveVoApi:isToday()
    if istoday ==false then
        acChrisEveVoApi:setSendAllTimes(0)
        local topTimes = acChrisEveVoApi:getTopSendTime( )
        local curSendTimes = acChrisEveVoApi:getSendAllTimes()
        self.sendTimes:setString(getlocal("activity_chrisEve_sendTimes",{curSendTimes,topTimes}))
    end
---------------------------------------------
    local function onHide()
        print("in mask~~~~~")
    end
    local showStr = {"accessory","tanke","heroTitle"}
    if self.version == 5 then
        showStr[1] = "jjStr"
    end
    local bgIcon = "blueBgIcon.png"

    local widthTb = {0.2,0.5,0.8}
    for i=1,3 do
       
        local giftBg = GetButtonItem(bgIcon,bgIcon,bgIcon,touch33,10+i,nil,nil)
        giftBg:setScale(0.9)
        giftBg:setAnchorPoint(ccp(0.5,0.5))
        local giftBg_Menu=CCMenu:createWithItem(giftBg)
        giftBg_Menu:setPosition(ccp(bgDia:getContentSize().width*widthTb[i],bgIconPosHeight))
        giftBg_Menu:setTouchPriority(-(self.layerNum-1)*20-4)
        bgDia:addChild(giftBg_Menu) 
        table.insert(self.sendGiftBgTb,giftBg_Menu)
        table.insert(self.sendGiftPosTb,ccp(bgDia:getContentSize().width*widthTb[i],bgIconPosHeight))

        if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
            local cloud2 = CCSprite:createWithSpriteFrameName("snowBg_2.png")
            cloud2:setAnchorPoint(ccp(0.5,0.5))
            cloud2:setFlipX(true)
            cloud2:setScale(giftBg:getContentSize().width/cloud2:getContentSize().width)
            cloud2:setPosition(ccp(giftBg:getContentSize().width*0.5,giftBg:getContentSize().height-10))
            giftBg:addChild(cloud2,99999)
        end

        if self.version == 5 then
            local graySp = GraySprite:createWithSpriteFrameName(bgIcon);
            graySp:setPosition(getCenterPoint(giftBg))
            giftBg:addChild(graySp)
            self.grayBorderTb[i] = graySp
        end

        local giftStr = GetTTFLabelWrap(getlocal(showStr[i]),strSize2,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        giftStr:setAnchorPoint(ccp(0.5,1))
        giftStr:setPosition(ccp(bgDia:getContentSize().width*widthTb[i],bgIconPosHeight-giftBg:getContentSize().height*0.5-5))
        bgDia:addChild(giftStr)

        local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
        touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-5)
        touchDialogBg:setScale(1)
        touchDialogBg:setContentSize(CCSizeMake(giftBg:getContentSize().width,giftBg:getContentSize().height))
        touchDialogBg:setOpacity(0)
        touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
        touchDialogBg:setPosition(bgDia:getContentSize().width*widthTb[i],bgIconPosHeight)
        bgDia:addChild(touchDialogBg)
        table.insert(self.sendGiftMaskTb,touchDialogBg)
        --LockIconCheckPoint
        touchDialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
        touchDialogBg2:setTouchPriority(-(self.layerNum-1)*20-5)
        touchDialogBg2:setScale(0.8)
        touchDialogBg2:setContentSize(CCSizeMake(giftBg:getContentSize().width,giftBg:getContentSize().height))
        touchDialogBg2:setOpacity(250)
        touchDialogBg2:setAnchorPoint(ccp(0.5,0.5))
        touchDialogBg2:setPosition(getCenterPoint(touchDialogBg))
        touchDialogBg:addChild(touchDialogBg2)

        local lockIcon = CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
        lockIcon:setAnchorPoint(ccp(0.5,0.5))
        lockIcon:setPosition(ccp(bgDia:getContentSize().width*widthTb[i],bgIconPosHeight))
        bgDia:addChild(lockIcon)
        table.insert(self.lockTb,lockIcon)

        if self.sendGiftDataTb  and SizeOfTable(self.sendGiftDataTb) ==0 then
            touchDialogBg:setVisible(false)
            lockIcon:setVisible(false)
            touchDialogBg:setPosition(ccp(bgDia:getContentSize().width*widthTb[i],999999))
            lockIcon:setPosition(ccp(bgDia:getContentSize().width*widthTb[i],999999))
        end

        local acVo = acChrisEveVoApi:getAcVo()
        if base.serverTime > acVo.acEt -86400  then
            touchDialogBg:setVisible(true)
            lockIcon:setVisible(true)
            lockIcon:setPosition(ccp(bgDia:getContentSize().width*widthTb[i],bgIconPosHeight))
            touchDialogBg:setPosition(bgDia:getContentSize().width*widthTb[i],bgIconPosHeight)
        end
    end

    if self.version == 5 then
        local newLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
        newLineSp:setContentSize(CCSizeMake(bgDia:getContentSize().width - 60,newLineSp:getContentSize().height))
        local addPosy = 70
        if not G_isIphone5() then
            addPosy = 35
        end
        newLineSp:setPosition(ccp(bgDia:getContentSize().width * 0.5,bgIconPosHeight + addPosy))
        bgDia:addChild(newLineSp)

        if G_isAsia() then
            newLineSp:setPositionY(newLineSp:getPositionY() + 20)
        end
    end

    local function touchDialog()
        print("big~~touchDialog~")
    end
    local function touchDialogBg3( )
        
    end
    self.sendGiftUpMaskDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.sendGiftUpMaskDialog:setTouchPriority(-(self.layerNum-1)*20-6)
    local rect=CCSizeMake(bgDia:getContentSize().width-4,bgDia:getContentSize().height)
    self.sendGiftUpMaskDialog:setContentSize(rect)
    self.sendGiftUpMaskDialog:setIsSallow(true)
    self.sendGiftUpMaskDialog:setAnchorPoint(ccp(0.5,0))
    self.sendGiftUpMaskDialog:setOpacity(0)
    -- self.touchDialogBg:setPosition(ccp(bgDia:getContentSize().width*0.5,1))
    self.sendGiftUpMaskDialog:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height+9999))
    bgDia:addChild(self.sendGiftUpMaskDialog,4)

    self.sendGiftChooseInDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialogBg3);
    self.sendGiftChooseInDialog:setTouchPriority(-(self.layerNum-1)*20-5)
    local rect=CCSizeMake(bgDia:getContentSize().width-4,bgDia:getContentSize().height*0.65-2)
    self.sendGiftChooseInDialog:setContentSize(rect)
    self.sendGiftChooseInDialog:setAnchorPoint(ccp(0.5,0))
    self.sendGiftChooseInDialog:setOpacity(0)
    -- self.touchDialogBg:setPosition(ccp(bgDia:getContentSize().width*0.5,1))
    self.sendGiftChooseInDialog:setPosition(ccp(bgDia:getContentSize().width*0.5,1-bgDia:getContentSize().height*0.67))
    bgDia:addChild(self.sendGiftChooseInDialog,4)

    if self.version == 5 then
        self.downBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),function() end)
    else
        self.downBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),function() end)
    end
    self.downBg:setContentSize(CCSizeMake(self.sendGiftChooseInDialog:getContentSize().width-2,self.sendGiftChooseInDialog:getContentSize().height))
    self.downBg:setAnchorPoint(ccp(0.5,1))
    -- self.downBg:setOpacity(100)
    self.downBg:setPosition(ccp(self.sendGiftChooseInDialog:getContentSize().width*0.5,self.sendGiftChooseInDialog:getContentSize().height))
    self.sendGiftChooseInDialog:addChild(self.downBg,1)

    --ladder_title_bg.png
    if self.version == 5 then
        self.titleBg = CCSprite:createWithSpriteFrameName("newTitleBg2.png")
    else
        self.titleBg = CCSprite:createWithSpriteFrameName("ladder_title_bg.png")--
        self.titleBg:setScaleX(self.downBg:getContentSize().width*0.7/self.titleBg:getContentSize().width)
    end
    -- self.titleBg:setContentSize(CCSizeMake(self.downBg:getContentSize().width*0.8,40))
    self.titleBg:setAnchorPoint(ccp(0.5,0.5))
    self.titleBg:setPosition(ccp(self.downBg:getContentSize().width*0.5,self.downBg:getContentSize().height-5))
    self.downBg:addChild(self.titleBg,3)

    self.smallBgTitleStr = GetTTFLabelWrap(getlocal(""),strSize2,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    if self.version ~= 5 then
        self.smallBgTitleStr:setColor(G_ColorYellowPro)
    end
    self.smallBgTitleStr:setAnchorPoint(ccp(0.5,0.5))
    self.smallBgTitleStr:setPosition(self.downBg:getContentSize().width*0.5,self.downBg:getContentSize().height-5)
    self.downBg:addChild(self.smallBgTitleStr,3)



    if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
        local cloud1 = CCSprite:createWithSpriteFrameName("snowBg_1.png")
        cloud1:setAnchorPoint(ccp(0,0.5))
        cloud1:setScaleX(0.8)
        cloud1:setScaleY(0.9)
        cloud1:setPosition(ccp(0,self.downBg:getContentSize().height-10))
        self.downBg:addChild(cloud1,3)
    
        local cloud2 = CCSprite:createWithSpriteFrameName("snowBg_2.png")
        cloud2:setAnchorPoint(ccp(1,1))
        cloud2:setScaleX(0.8)
        cloud2:setScaleY(0.9)
        cloud2:setPosition(ccp(self.downBg:getContentSize().width+5,self.downBg:getContentSize().height))
        self.downBg:addChild(cloud2,3)
    end

    if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
        local bellPic = CCSprite:createWithSpriteFrameName("bellPic.png")
        bellPic:setScale(0.8)
        bellPic:setAnchorPoint(ccp(0.5,0.5))
        bellPic:setPosition(ccp(30,self.downBg:getContentSize().height-20))
        self.downBg:addChild(bellPic,3)
    end

----
    local function touchDialog2( )
        print("touchDialog2--------")
    end
    self.sendGiftChooseInDialogMask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog2);
    self.sendGiftChooseInDialogMask:setTouchPriority(-(self.layerNum-1)*20-7)
    local rect=CCSizeMake(bgDia:getContentSize().width-4,bgDia:getContentSize().height*0.65-2)
    self.sendGiftChooseInDialogMask:setContentSize(rect)
    self.sendGiftChooseInDialogMask:setIsSallow(true)
    self.sendGiftChooseInDialogMask:setAnchorPoint(ccp(0,0))
    self.sendGiftChooseInDialogMask:setOpacity(0)
    -- self.touchDialogBg:setPosition(ccp(bgDia:getContentSize().width*0.5,1))
    self.sendGiftChooseInDialogMask:setPosition(ccp(0,0))
    self.sendGiftChooseInDialog:addChild(self.sendGiftChooseInDialogMask,99999)
----
    --21 31 41
    self.giftChooseBtn =GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch33,21,getlocal("dailyAnswer_tab1_btn"),24/0.8,21)
    self.giftChooseBtn:setScale(0.8)
    self.giftChooseBtn:setAnchorPoint(ccp(0.5,0.5))
    local giftChooseBtnMenu=CCMenu:createWithItem(self.giftChooseBtn)
    giftChooseBtnMenu:setPosition(ccp(self.downBg:getContentSize().width*0.25,55))
    giftChooseBtnMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.downBg:addChild(giftChooseBtnMenu,1)  

    self.returnBtn =GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touch33,22,getlocal("coverFleetBack"),24/0.8)
    self.returnBtn:setScale(0.8)
    self.returnBtn:setAnchorPoint(ccp(0.5,0.5))
    local returnBtnMenu=CCMenu:createWithItem(self.returnBtn)
    -- returnBtnMenu:setIsSallow(false)
    returnBtnMenu:setPosition(ccp(self.downBg:getContentSize().width*0.75,55))
    returnBtnMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.downBg:addChild(returnBtnMenu,1) 
    
    self.GiftsBgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchDialog)--拉霸动画背景
    self.GiftsBgLayer:setContentSize(CCSizeMake(self.downBg:getContentSize().width*0.95,self.downBg:getContentSize().height*0.68))
    self.GiftsBgLayer:setAnchorPoint(ccp(0.5,1))
    self.GiftsBgLayer:setOpacity(0)
    self.GiftsBgLayer:setPosition(ccp(self.downBg:getContentSize().width*0.5,self.downBg:getContentSize().height-30))
    self.downBg:addChild(self.GiftsBgLayer,2)
    self.smallBgSpSize=CCSizeMake(self.downBg:getContentSize().width*0.95,self.downBg:getContentSize().height*0.68)

--ladder_title_bg.png --标题背景框

    local subH  = 20
    if G_isIphone5() then
        subH =40
        strSize4 =20
    end
    self.chooseSM = GetTTFLabelWrap(getlocal("activity_chrisEve_GiftChooseSM"),strSize2,CCSizeMake(540,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.chooseSM:setAnchorPoint(ccp(0.5,0.5))
    self.chooseSM:setPosition(ccp(self.downBg:getContentSize().width*0.5,self.GiftsBgLayer:getPositionY()-self.GiftsBgLayer:getContentSize().height-subH))
    self.downBg:addChild(self.chooseSM,1)

    local titleTb = {"help2_t1_t3","RankScene_name","RankScene_level"}
    for i=1,3 do
        local friendsTitle = GetTTFLabelWrap(getlocal(titleTb[i]),strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        friendsTitle:setAnchorPoint(ccp(0.5,0.5))
        friendsTitle:setTag(10+i)
        friendsTitle:setPosition(ccp(-20+ (G_VisibleSizeWidth -40)/5*i,self.downBg:getContentSize().height-45))
        self.downBg:addChild(friendsTitle,1)
        friendsTitle:setVisible(false)
    end

    if(acChrisEveVoApi:isNormalVersion()) or self.version == 5 then
        self.choosePayStr = GetTTFLabelWrap(getlocal("activity_chrisEve_choosePayStr_1"),strSize3,CCSizeMake(self.downBg:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    else
        self.choosePayStr = GetTTFLabelWrap(getlocal("activity_chrisEve_choosePayStr"),strSize3,CCSizeMake(self.downBg:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    end
    self.choosePayStr:setAnchorPoint(ccp(0.5,0.5))
    self.choosePayStr:setPosition(ccp(self.downBg:getContentSize().width*0.5+10,self.downBg:getContentSize().height-50))
    self.downBg:addChild(self.choosePayStr,1)
    self.choosePayStr:setVisible(false)

    self.choosePaygetValueStr = GetTTFLabelWrap(getlocal("activity_chrisEve_choosePayGetValueStr",{0}),strSize4,CCSizeMake(self.downBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.choosePaygetValueStr:setAnchorPoint(ccp(0.5,0.5))
    self.choosePaygetValueStr:setPosition(ccp(self.downBg:getContentSize().width*0.5,self.returnBtn:getContentSize().height+self.returnBtn:getPositionY()+35))
    self.downBg:addChild(self.choosePaygetValueStr,1)
    self.choosePaygetValueStr:setVisible(false)
    
    local smallBgSp = nil
    if self.version == 5 then
        smallBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ( ) end)
    else
        smallBgSp =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ( ) end)--拉霸动画背景
    end
    smallBgSp:setContentSize(CCSizeMake(self.GiftsBgLayer:getContentSize().width ,self.GiftsBgLayer:getContentSize().height))

    smallBgSp:setAnchorPoint(ccp(0,0))
    smallBgSp:setPosition(ccp(0,0))
    self.GiftsBgLayer:addChild(smallBgSp,0)
    local function callBack2(...)
       return self:eventHandler2(...)
    end
    local hd= LuaEventHandler:createHandler(callBack2)
    self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.GiftsBgLayer:getContentSize().width ,self.GiftsBgLayer:getContentSize().height),nil)
    self.GiftsBgLayer:addChild(self.tv2)
    self.tv2:setPosition(ccp(0,1))
    self.tv2:setAnchorPoint(ccp(0,0))
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-7)
    self.GiftsBgLayer:setTouchPriority(-(self.layerNum-1)*20-6)
    self.tv2:setMaxDisToBottomOrTop(150)

    if self.sendGiftDataTb  and SizeOfTable(self.sendGiftDataTb) ==0 then
        self.chooseFriBtn:setEnabled(false)
    end
     
end

function acChrisEveTab1:eventHandler2( handler,fn,idx,cel)
    local needHeight = 10
    if acChrisEveVoApi:getClickTag() ==5 then
        needHeight = 100 
    end
    if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
        local giftIdx = acChrisEveVoApi:getChooseRewardIdx()
        local singleRewardTb,tbNums = acChrisEveVoApi:getWhiRewardTb(giftIdx)
        local lastNums = nil
        local friendsTb =nil
        if acChrisEveVoApi:getClickTag() ==5 then
            friendsTb =acChrisEveVoApi:getFriendTb()
            tbNums = SizeOfTable(friendsTb)
        end
        if tbNums <9 then
            return  CCSizeMake(self.smallBgSpSize.width,self.smallBgSpSize.height + needHeight)
        else
            lastNums = math.ceil((tbNums-8)/4)
            if acChrisEveVoApi:getClickTag() ==5 then
                lastNums =tbNums-8
            end
            return CCSizeMake(self.smallBgSpSize.width,self.smallBgSpSize.height+lastNums*100+needHeight)
        end

   elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        local strSize2 = 22
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
            strSize2 =28
        end
        local function touch( )
        end     
        local giftIdx = acChrisEveVoApi:getChooseRewardIdx()
        local singleRewardTb,tbNums,lostGemsTbTop,inMyGiftTimesTb = acChrisEveVoApi:getWhiRewardTb(giftIdx)
        -- local sid =acChrisEveVoApi:getWhiSid(singleRewardTb,giftIdx)
        local friendsTb =nil
        if acChrisEveVoApi:getClickTag() ==5 then
            friendsTb =acChrisEveVoApi:getFriendTb()
            tbNums = SizeOfTable(friendsTb)
        end
        local msTb = {}
        if tbNums <9 then
            msTb = CCSizeMake(self.smallBgSpSize.width,self.smallBgSpSize.height)
        else
            lastNums = math.ceil((tbNums-8)/4)
            if acChrisEveVoApi:getClickTag() ==5 then
                lastNums =tbNums-8
            end
            msTb = CCSizeMake(self.smallBgSpSize.width,self.smallBgSpSize.height+lastNums*100+10)
        end
        local smallBgSp =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)--拉霸动画背景
        smallBgSp:setContentSize(CCSizeMake(msTb.width,msTb.height))
        smallBgSp:setOpacity(0)
        smallBgSp:setAnchorPoint(ccp(0.5,0.5))
        smallBgSp:setPosition(ccp(msTb.width*0.5,msTb.height*0.5))
        cell:addChild(smallBgSp,3)


        -- print("here???????idx----->",idx)
        
        local clickTag = acChrisEveVoApi:getClickTag()

        if clickTag == 5 then
            smallBgSp:setPositionY(smallBgSp:getPositionY() + needHeight)
        end
        if clickTag <40 then
            self.titleBg:setVisible(true)
            self.smallBgTitleStr:setVisible(true)
        else
            self.titleBg:setVisible(false)
            self.smallBgTitleStr:setVisible(false)
        end

        if clickTag <5 then
            -- print("giftIdx----strSize2",giftIdx,strSize2)   
            local titleTb = {"accessory","tanke","heroTitle"}
            if self.version == 5 then
                titleTb[1] = "jjStr"
            end
            self.smallBgTitleStr:setString(getlocal("activity_chrisEve_smallBgTitle_1",{getlocal(titleTb[giftIdx])}))
            self.GiftsBgLayer:setPosition(ccp(self.downBg:getContentSize().width*0.5,self.downBg:getContentSize().height-30))
            self.GiftsBgLayer:setContentSize(CCSizeMake(self.downBg:getContentSize().width*0.95,self.downBg:getContentSize().height*0.68))

            self.chooseSM:setVisible(true)
            self.choosePayStr:setVisible(false)
            self.choosePaygetValueStr:setVisible(false)
            for i=1,3 do
                local showTitle = tolua.cast(self.downBg:getChildByTag(10+i),"CCLabelTTF")
                showTitle:setVisible(false)
            end
            local posNum = 0
            local reSize = SizeOfTable(singleRewardTb)+1
            for k,v in pairs(singleRewardTb) do
                -- print("kkkk------>",k)
                local function propInfo( )
                    acChrisEveVoApi:setSelectTb(v)
                    if acChrisEveVoApi:getSelectIdx() ==reSize-k then
                        local item = v
                        -- propInfoDialog:create(sceneGame,item,self.layerNum+1)
                        G_showNewPropInfo(self.layerNum+1,true,true,nil,item,nil,nil,nil,nil,true)
                    else
                        acChrisEveVoApi:setSelectIdx(tonumber(reSize-k))
                        for i=1,SizeOfTable(self.awardPicTb) do
                            local awardPic = tolua.cast(self.awardPicTb[i],"CCSprite")
                            local scX = awardPic:getContentSize().width/75
                            if i ==k then
                                G_addRectFlicker(awardPic,scX,scX)
                            else
                                G_removeFlicker(awardPic)
                            end
                        end
                    end
                end 
                
                
                if math.floor(k%5)==0 then
                    posNum =1
                else
                    posNum =posNum+1
                end
                local awardPic = G_getItemIcon(v,100,false,self.layerNum,propInfo)
                awardPic:setTouchPriority(-(self.layerNum-1)*20-8)
                awardPic:setPosition(ccp(-20+ G_VisibleSizeWidth/5*posNum,smallBgSp:getContentSize().height*0.78-170*math.floor(k/5)))
                smallBgSp:addChild(awardPic,1)
                table.insert(self.awardPicTb,awardPic)

                local iconNum = v.num
                local iconLabel = GetTTFLabel("x"..iconNum,25)
                iconLabel:setAnchorPoint(ccp(1,0))
                iconLabel:setPosition(ccp(awardPic:getContentSize().width-4,4))
                awardPic:addChild(iconLabel,1)
                iconLabel:setScale(awardPic:getContentSize().width*0.2/25)


                local lostGemsTimesTop = lostGemsTbTop[k] --送礼最高此时
                local curLostGemsTimes = inMyGiftTimesTb[k] --当前送礼次数
                if curLostGemsTimes >lostGemsTimesTop then
                    curLostGemsTimes =lostGemsTimesTop
                end
                local sendGiftCurTime = GetTTFLabelWrap(getlocal("super_weapon_challenge_troops_schedule",{curLostGemsTimes,lostGemsTimesTop}),strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                sendGiftCurTime:setAnchorPoint(ccp(0.5,1))
                sendGiftCurTime:setPosition(ccp(-20+ G_VisibleSizeWidth/5*posNum,awardPic:getPositionY()-50))
                smallBgSp:addChild(sendGiftCurTime,1)
                if curLostGemsTimes ==lostGemsTimesTop then
                    sendGiftCurTime:setColor(G_ColorRed)
                end

            end
        elseif clickTag ==5 then
            self.smallBgTitleStr:setString(getlocal("mailList"))
            self.GiftsBgLayer:setPosition(ccp(self.downBg:getContentSize().width*0.5,self.downBg:getContentSize().height-70))
            self.GiftsBgLayer:setContentSize(CCSizeMake(self.downBg:getContentSize().width*0.95,self.downBg:getContentSize().height*0.68))
            self.chooseSM:setVisible(false)
            self.choosePayStr:setVisible(false)
            self.choosePaygetValueStr:setVisible(false)
            local friendsTb = acChrisEveVoApi:getFriendTb()
            if friendsTb and SizeOfTable(friendsTb)>0 then
                local function touch9( tag,object )
                    local idx =tag -10
                    acChrisEveVoApi:setSureFriend(friendsTb[idx])
                    for k,v in pairs(self.chooseFriendBtnTb) do
                        if k ==idx then
                            self.choosedTbStr[k]:setVisible(true)
                            self.chooseFriendBtnTb[k]:setVisible(false)
                        else
                             self.choosedTbStr[k]:setVisible(false)
                             self.chooseFriendBtnTb[k]:setVisible(true)
                        end
                    end
                end 
                local posW = 30
                local posH1 = 40
                local posH2 = 65
                if self.chooseFriendBtnTb and SizeOfTable(self.chooseFriendBtnTb)>0 then
                    self.chooseFriendBtnTb ={}
                    self.choosedTbStr ={}
                end
                for k,v in pairs(friendsTb) do
                    local jx = playerVoApi:getRankIconName(tonumber(v.rank))
                    local jxIcon = CCSprite:createWithSpriteFrameName(jx)-------
                    jxIcon:setAnchorPoint(ccp(0.5,0.5))
                    jxIcon:setPosition(ccp(-posW+ (G_VisibleSizeWidth -40)/5,smallBgSp:getContentSize().height-posH1-(k-1)*posH2))
                    smallBgSp:addChild(jxIcon)

                    local friendName = GetTTFLabelWrap(v.nickname,strSize2-2,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    friendName:setAnchorPoint(ccp(0.5,0.5))
                    friendName:setPosition(ccp(-posW+ (G_VisibleSizeWidth -40)/5*2,smallBgSp:getContentSize().height-posH1-(k-1)*posH2))
                    smallBgSp:addChild(friendName,1)

                    local levelStr = GetTTFLabelWrap(getlocal("fightLevel",{v.level}),strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    levelStr:setAnchorPoint(ccp(0.5,0.5))
                    levelStr:setPosition(ccp(-posW+ (G_VisibleSizeWidth -40)/5*3,smallBgSp:getContentSize().height-posH1-(k-1)*posH2))
                    smallBgSp:addChild(levelStr,1)

                    local chooseFriendBtn = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch9,k+10,getlocal("dailyAnswer_tab1_btn"),24/0.6,k+10)
                    chooseFriendBtn:setAnchorPoint(ccp(0.5,0.5))
                    chooseFriendBtn:setScale(0.6)
                    table.insert(self.chooseFriendBtnTb,chooseFriendBtn)
                    local chooseFriendBtnMenu=CCMenu:createWithItem(chooseFriendBtn)
                    chooseFriendBtnMenu:setPosition(ccp(-posW+ (G_VisibleSizeWidth -40)/5*4,smallBgSp:getContentSize().height-posH1-(k-1)*posH2))
                    chooseFriendBtnMenu:setTouchPriority(-(self.layerNum-1)*20-7)
                    smallBgSp:addChild(chooseFriendBtnMenu,1) 

                    local choosed = GetTTFLabelWrap(getlocal("choosed"),strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    choosed:setAnchorPoint(ccp(0.5,0.5))
                    -- choosed:setTag()
                    choosed:setColor(G_ColorGreen)
                    choosed:setVisible(false)
                    choosed:setPosition(ccp(-posW+ (G_VisibleSizeWidth -40)/5*4,smallBgSp:getContentSize().height-posH1-(k-1)*posH2))
                    smallBgSp:addChild(choosed,1)
                    table.insert(self.choosedTbStr,choosed)

                    local lineSp = nil
                    if self.version == 5 then
                        lineSp =LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
                        lineSp:setContentSize(CCSizeMake(smallBgSp:getContentSize().width - 40,lineSp:getContentSize().height))
                        -- line:setPosition(ccp(cellBgSp:getContentSize().width * 0.5,0))
                        -- cellBgSp:addChild(line,99)
                    else
                        lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                        lineSp:setAnchorPoint(ccp(0.5,0.5))
                        lineSp:setScale(0.9)
                    end
                    lineSp:setPosition(ccp(smallBgSp:getContentSize().width*0.5,jxIcon:getPositionY()-jxIcon:getContentSize().height*0.48))
                    smallBgSp:addChild(lineSp)
                end
            end
        elseif clickTag ==41 then
            
            smallBgSp:setContentSize(CCSizeMake(smallBgSp:getContentSize().width,smallBgSp:getContentSize().height*0.9))
            smallBgSp:setPosition(ccp(smallBgSp:getPositionX(),smallBgSp:getPositionY()+10))
            self.chooseSM:setVisible(false)
            self.choosePayStr:setVisible(true)
            self.choosePaygetValueStr:setVisible(true)
            for i=1,3 do
                local showTitle = tolua.cast(self.downBg:getChildByTag(10+i),"CCLabelTTF")
                showTitle:setVisible(false)
            end
            local chooseIdx = acChrisEveVoApi:getChooseRewardIdx()
            local selectIdx = acChrisEveVoApi:getSelectIdx()
            -- print("selectIdx------>",selectIdx)

            acChrisEveVoApi:setWhiPayTb(chooseIdx,selectIdx)
            local payTb = acChrisEveVoApi:getWhiPayTb( )
            -- print("payTb.index---->",payTb.index)
            local function checkUpCallBack(tag,object)
                if tag ==101 then
                     self.checkDownBtn:setPosition(ccp(smallBgSp:getContentSize().width*0.15,smallBgSp:getContentSize().height-100))
                     self.checkDownBtn:setVisible(true)
                     acChrisEveVoApi:setChoosePayType(0)
                     self.payTotalStr:setString(payTb.p)   
                     if playerVoApi:getGems() <payTb.p  then
                        self.lastNumsStrddd:setColor(G_ColorRed)
                        self.payTotalStr:setColor(G_ColorRed)
                     else
                        self.lastNumsStrddd:setColor(G_ColorWhite)
                        self.payTotalStr:setColor(G_ColorWhite)
                     end                 --
                elseif tag ==102 then
                     self.checkDownBtn:setPosition(ccp(smallBgSp:getContentSize().width*0.6,smallBgSp:getContentSize().height-100))
                     self.checkDownBtn:setVisible(true)
                     acChrisEveVoApi:setChoosePayType(1)
                     self.payTotalStr:setString(payTb.p +payTb.g)

                     if playerVoApi:getGems() <payTb.p  then
                        self.lastNumsStrddd:setColor(G_ColorRed)
                     else
                        self.lastNumsStrddd:setColor(G_ColorWhite)
                     end
                     if playerVoApi:getGems() <payTb.p+payTb.g then
                        self.payTotalStr:setColor(G_ColorRed)
                     else
                        self.payTotalStr:setColor(G_ColorWhite)
                     end 
                 end

            end 
---------
            local payNeedData = nil
            local nowHas = nil
            local needCostKey = nil
            local giftData = acChrisEveVoApi:getWhiPayTb( )
            -- print("giftData.index--->",giftData.index)
            local tuid = acChrisEveVoApi:getTuid()
            local allGemsGost = giftData.p+giftData.g
---------   
            self.choosePaygetValueStr:setString(getlocal("activity_chrisEve_choosePayGetValueStr",{giftData.d}))
            for i=1,2 do
                local choosePayStr = GetTTFLabelWrap(getlocal("activity_chrisEve_choosePay_"..i),strSize2,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                choosePayStr:setAnchorPoint(ccp(0.5,0.5))
                choosePayStr:setPosition(ccp(smallBgSp:getContentSize().width*(0.3+(i-1)*0.5),smallBgSp:getContentSize().height-40))
                smallBgSp:addChild(choosePayStr,1)



                local payPic = nil
                local payNums = nil
                local lastNums = nil
                if i ==1 then
                    local formatPayTb = FormatItem(payTb["n"],false)
                    local function propInfo( )
                         G_showNewPropInfo(self.layerNum+1,true,true,nil,formatPayTb[1],nil,nil,nil,nil,true)
                    end
                    payPic = G_getItemIcon(formatPayTb[1],100,false,self.layerNum,propInfo)
                    payNums =formatPayTb[1].num
                    payPic:setTouchPriority(-(self.layerNum-1)*20-8)
                else
                    payPic =GetBgIcon("GoldImage.png",nil,"Icon_BG.png",80,100)
                    payNums =payTb.g
                end
                
                payPic:setAnchorPoint(ccp(0.5,1))
                payPic:setPosition(ccp(smallBgSp:getContentSize().width*(0.3+(i-1)*0.5),choosePayStr:getPositionY()-30))
                smallBgSp:addChild(payPic,1)

                local payNum = GetTTFLabelWrap(getlocal("willLostNums",{payNums}),strSize2,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                payNum:setAnchorPoint(ccp(0.5,0.5))
                payNum:setPosition(ccp(smallBgSp:getContentSize().width*(0.3+(i-1)*0.5),smallBgSp:getContentSize().height*0.35+10))
                smallBgSp:addChild(payNum,1)

                local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
                goldIcon:setScale(0.8)
                smallBgSp:addChild(goldIcon,1)

                
                local checkUpBtn = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",checkUpCallBack,100+i,nil)
                checkUpBtn:setAnchorPoint(ccp(0.5,0.5))
                checkUpBtnMenu=CCMenu:createWithItem(checkUpBtn)
                checkUpBtnMenu:setTouchPriority(-(self.layerNum-1)*20-8)
                checkUpBtnMenu:setPosition(smallBgSp:getContentSize().width*(0.15+(i-1)*0.45),smallBgSp:getContentSize().height-100)
                smallBgSp:addChild(checkUpBtnMenu)


                local lineSp = nil
                if self.version == 5 then
                    lineSp =LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
                    lineSp:setContentSize(CCSizeMake(smallBgSp:getContentSize().width - 40,lineSp:getContentSize().height))
                else
                    lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                    lineSp:setAnchorPoint(ccp(0.5,0.5))
                    lineSp:setScale(0.9)
                end
                smallBgSp:addChild(lineSp)
                

                local posH3 = 30
                if i ==1 then
                    -- 选中状态
                    self.checkDownBtn=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
                    self.checkDownBtn:setAnchorPoint(ccp(0.5,0.5))
                    self.checkDownBtn:setPosition(ccp(smallBgSp:getContentSize().width*0.15,smallBgSp:getContentSize().height-100))
                    smallBgSp:addChild(self.checkDownBtn,1)
                    self.checkDownBtn:setVisible(false)

                    lastNums =payTb.p
                    local XmasOldManPayStr = GetTTFLabelWrap(getlocal("activity_chrisEve_XmasOldMan"),strSize2,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    XmasOldManPayStr:setAnchorPoint(ccp(0,0.5))
                    XmasOldManPayStr:setPosition(ccp(10,posH3*2+5))
                    smallBgSp:addChild(XmasOldManPayStr,1)

                    goldIcon:setPosition(ccp(smallBgSp:getContentSize().width-5,posH3*2+5))
                    goldIcon:setAnchorPoint(ccp(1,0.5))

                    self.lastNumsStrddd = GetTTFLabel(lastNums,strSize2)
                    self.lastNumsStrddd:setAnchorPoint(ccp(1,0.5))
                    self.lastNumsStrddd:setPosition(ccp(smallBgSp:getContentSize().width-goldIcon:getContentSize().width-5,posH3*2+5))
                    smallBgSp:addChild(self.lastNumsStrddd,1)
                    --lastNumsStr


                    local deData = giftData["n"]
                    for k,v in pairs(deData) do
                        for i,j in pairs(v) do
                            needCostKey =i
                            payNeedData =j
                        end
                        local costId = tonumber(RemoveFirstChar(needCostKey))
                        -- print("k--->",k,needCostKey,payNeedData,costId)
                        if k =="e" then
                            nowHas = accessoryVoApi:getShopPropNum()[needCostKey]
                             acChrisEveVoApi:setCostType(k)
                        elseif k =="o" then
                            nowHas = tankVoApi:getTankCountByItemId(costId)
                        elseif k =="p" then
                            nowHas = bagVoApi:getItemNumId(costId)
                        -- elseif k =="h" then
                        elseif k=="w" then
                            nowHas = superWeaponVoApi:getCrystalNumByCid(needCostKey)
                        end
                        
                    end
                    -- print("nowHas--1111--payNeedData--->",nowHas,payNeedData)
                    if nowHas and nowHas<payNeedData then
                        payNum:setColor(G_ColorRed)
                    end
                    lineSp:setPosition(ccp(smallBgSp:getContentSize().width*0.5,posH3*2+10+goldIcon:getContentSize().height*0.5))

                    local function onHide( )
                    end 
                    touchDialogBg3 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
                    touchDialogBg3:setTouchPriority(-(self.layerNum-1)*20-2)
                    -- touchDialogBg3:setScale(0.8)
                    touchDialogBg3:setContentSize(CCSizeMake(lineSp:getContentSize().width-4,66+goldIcon:getContentSize().height*0.5))
                    touchDialogBg3:setOpacity(100)
                    touchDialogBg3:setAnchorPoint(ccp(0.5,1))
                    smallBgSp:addChild(touchDialogBg3)
                    touchDialogBg3:setPosition(ccp(smallBgSp:getContentSize().width*0.5,lineSp:getPositionY()))
                else
                    -- lastNums =payTb.p +payTb.g
                    local allPayStr = GetTTFLabel(getlocal("activity_chrisEve_payTotal"),strSize2)
                    allPayStr:setAnchorPoint(ccp(0,0.5))
                    allPayStr:setPosition(ccp(10,posH3))
                    smallBgSp:addChild(allPayStr,1)

                    goldIcon:setPosition(ccp(smallBgSp:getContentSize().width-5,posH3))
                    goldIcon:setAnchorPoint(ccp(1,0.5))
--activity_chrisEve_payTotal
                    self.payTotalStr = GetTTFLabel(payTb.p,strSize2)
                    self.payTotalStr:setAnchorPoint(ccp(1,0.5))
                    self.payTotalStr:setPosition(ccp(goldIcon:getPositionX()-goldIcon:getContentSize().width,posH3))
                    smallBgSp:addChild(self.payTotalStr,1)

                    lineSp:setPosition(ccp(smallBgSp:getContentSize().width*0.5,posH3+goldIcon:getContentSize().height*0.5))
                    if playerVoApi:getGems() < allGemsGost then
                        payNum:setColor(G_ColorRed)
                    end
                end
                    
            end
        end
        -- self:initWholeSp(self.wholeBgSp)
       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acChrisEveTab1:sendGiftChooseInDialogAction(btnIdx,bgDia)
    -- print("btnIdx----->",btnIdx)
    if btnIdx >10 and btnIdx<15 then
        self.chooseGift:setColor(G_ColorYellowPro)
        self.chooseFriend:setColor(G_ColorWhite)
        self.choosePay:setColor(G_ColorWhite)
        self.surePay:setColor(G_ColorWhite)
    elseif btnIdx==25 or btnIdx ==32 then
        self.chooseGift:setColor(G_ColorWhite)
        self.chooseFriend:setColor(G_ColorYellowPro)
        self.choosePay:setColor(G_ColorWhite)
        self.surePay:setColor(G_ColorWhite)
    elseif btnIdx==31 then
        self.chooseGift:setColor(G_ColorWhite)
        self.chooseFriend:setColor(G_ColorWhite)
        self.choosePay:setColor(G_ColorYellowPro)
        self.surePay:setColor(G_ColorWhite)
    elseif btnIdx ==41 then
        print("btnIdx~~~ 41??")

    end
    self.sendGiftUpMaskDialog:setPosition(ccp(bgDia:getContentSize().width*0.5,3))
    if btnIdx>14 then
        self.sendGiftChooseInDialogMask:setPosition(ccp(0,0))--小板子遮罩
    end

    local function onFlipHandlerToShowppp( )
        self.sendGiftChooseInDialogMask:setPosition(ccp(0,99999))
    end
    local moveby=CCMoveTo:create(0.5,ccp(bgDia:getContentSize().width*0.5,1))
    local callFunc=CCCallFunc:create(onFlipHandlerToShowppp)
    local acArr=CCArray:create()
    acArr:addObject(moveby)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.sendGiftChooseInDialog:runAction(seq)
end

function acChrisEveTab1:tick( )
    self:updateAcTime()
    -- print("acChrisEveVoApi:getIsNewData()=====>>>>",acChrisEveVoApi:getIsNewData())
    if acChrisEveVoApi:getIsNewData() ==1 then
        acChrisEveVoApi:setIsNewData(0)
        self:getNewData()
    elseif acChrisEveVoApi:getIsNewData() ==3 then
        acChrisEveVoApi:setIsNewData(0)
        local recList,allNums = acChrisEveVoApi:getRecGiftTb()
        local recIdx = allNums or 0
        if acChrisEveVoApi:getFirstRecTime() ==0  then
            recIdx = recIdx + 1
        end
        -- if allNums == 0 and recList and SizeOfTable(recList)>0 then
        --     recIdx =recIdx+SizeOfTable(recList)
        -- end
        if recIdx ==0 then
            self.giftBox:setVisible(false)
            self.xPic:setVisible(false)
            self.giftBoxIdx:setVisible(false)
        end
        self.giftBoxIdx:setString(recIdx)
    end

    local istoday = acChrisEveVoApi:isToday()
    -- print("istoday ~= self.isToday----",istoday,self.isToday)
    if istoday ==false then
        acChrisEveVoApi:setSendAllTimes(0)
        local topTimes = acChrisEveVoApi:getTopSendTime( )
        local curSendTimes = acChrisEveVoApi:getSendAllTimes()
        self.sendTimes:setString(getlocal("activity_chrisEve_sendTimes",{curSendTimes,topTimes}))
    end

    local acVo = acChrisEveVoApi:getAcVo()
    if base.serverTime > acVo.acEt then
        self.giftBox:setVisible(false)
        self.xPic:setVisible(false)
        self.giftBoxIdx:setVisible(false)
    end
    if base.serverTime > acVo.acEt -86400 then
        -- self.giftBox:setVisible(false)
        -- self.xPic:setVisible(false)
        -- self.giftBoxIdx:setVisible(false)
        for i=1,3 do
            self.sendGiftMaskTb[i]:setVisible(true)
            self.lockTb[i]:setVisible(true)
            self.sendGiftMaskTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y))
            self.lockTb[i]:setPosition(ccp(self.sendGiftPosTb[i].x,self.sendGiftPosTb[i].y))
        end
        acChrisEveVoApi:setSelectTb()
        acChrisEveVoApi:setSelectIdx()
        if self.selectSp ~=nil then
            self.selectSp:setVisible(false)
            self.selectSp:removeFromParentAndCleanup(true)
            self.selectSp=nil
        end
        self.sendGiftChooseInDialog:setPosition(ccp(self.wholeBgSp:getContentSize().width*0.5,1-self.wholeBgSp:getContentSize().height*0.67))
        self.chooseFriBtn:setEnabled(false)
    end

end
function acChrisEveTab1:getNewData( )
    local function sendRequestCallBack(fn,data)
          local ret,sData=base:checkServerData(data)
          if ret ==true then
            if sData.data and sData.data and sData.data.list then
                acChrisEveVoApi:setRecGiftTb(sData.data.list)
            else
                acChrisEveVoApi:setRecGiftTb()
            end
                local recList,allNums = acChrisEveVoApi:getRecGiftTb()
                local recIdx = allNums or 0
                if acChrisEveVoApi:getFirstRecTime() ==0  then
                    recIdx =recIdx + 1
                end
                -- if recList and SizeOfTable(recList)>0 then
                --     recIdx =recIdx+SizeOfTable(recList)
                -- end
                if recIdx ==0 then
                    self.giftBox:setVisible(false)
                    self.xPic:setVisible(false)
                    self.giftBoxIdx:setVisible(false)
                else
                    self.giftBox:setVisible(true)
                    self.xPic:setVisible(true)
                    self.giftBoxIdx:setVisible(true)
                end
                -- print("recIdx------>",recIdx)
                self.giftBoxIdx:setString(recIdx)
              -- self.layerTab1:setVisible(true)
                if self.sd ~=nil and self.sd.isRefresh ==false then--有问题
                    self.sd.isRefresh =true
                end
          end
      end
      socketHelper:chrisEveSend(sendRequestCallBack,"get")
end

function acChrisEveTab1:actionEye()
    if self.wholeBgSp then
        local eyeFrame=CCSprite:createWithSpriteFrameName("eye_2.png")
        -- local scaleyeH = (G_VisibleSizeHeight-182)/self.wholeBgSp:getContentSize().height
        -- local scaleyeW = (G_VisibleSizeWidth-40)/self.wholeBgSp:getContentSize().width
        eyeFrame:setPosition(self.bgScaleW*207,self.bgScaleH*368)
        -- eyeFrame:setOpacity(0)
        self.wholeBgSp:addChild(eyeFrame)

        local function eyeFunc1( )
            -- print("eye-----1")
            eyeFrame:setVisible(true)
        end
        local function eyeFunc2( )
            eyeFrame:setVisible(false)
        end 
        local callFunc1=CCCallFunc:create(eyeFunc1)
        local eyeStr1="eye_2.png"
        local eyeFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(eyeStr1)
        local eyestr2="eye_1.png"
        local eyeFrame2=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(eyestr2)
        local eyeStr3="eye_2.png"
        local eyeFrame3 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(eyeStr3)
        local callFunc2=CCCallFunc:create(eyeFunc2)

        local eyeTb = {eyeFrame1,eyeFrame2,eyeFrame3}
        local eyeArr=CCArray:create()
        for i=1,3 do
            eyeArr:addObject(eyeTb[i])
        end
        local animation=CCAnimation:createWithSpriteFrames(eyeArr)
        animation:setDelayPerUnit(0.05)
        local animate=CCAnimate:create(animation)
        local delay=CCDelayTime:create(2)
        local actionArr = CCArray:create()
        actionArr:addObject(callFunc1)
        actionArr:addObject(animate)
        actionArr:addObject(callFunc2)
        actionArr:addObject(delay)

        local seq=CCSequence:create(actionArr)
        local repeatForever=CCRepeatForever:create(seq)
        eyeFrame:runAction(repeatForever)
    end
end

function acChrisEveTab1:updateAcTime()
    -- local acVo=acChrisEveVoApi:getAcVo()
    -- if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
    --     G_updateActiveTime(acVo,self.timeLb,true)
    -- end
    if self then
        if self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
            self.timeLb:setString(acChrisEveVoApi:getTimeStr())
        end
    end
end

function acChrisEveTab1:openInfo( )
    -- print("in openInfo~~~~~")
    local td=smallDialog:new()
    local tabStr = nil 
    local tip3
    if(acChrisEveVoApi:isNormalVersion() or self.version == 5 )then
        tip3=getlocal("activity_chrisEve_d1_tip3_1")
    else
        tip3=getlocal("activity_chrisEve_d1_tip3")
    end
    local tip1Str = self.version == 5 and getlocal("activity_chrisEve_d1_tip1_v5") or getlocal("activity_chrisEve_d1_tip1")
    tabStr ={"\n",getlocal("activity_chrisEve_d1_tip7"),"\n",getlocal("activity_chrisEve_d1_tip8"),"\n",getlocal("activity_chrisEve_d1_tip6",{acChrisEveVoApi:getConditiongems()}),"\n",getlocal("activity_chrisEve_d1_tip5"),"\n",getlocal("activity_chrisEve_d1_tip4"),"\n",tip3,"\n",getlocal("activity_chrisEve_d1_tip2"),"\n",tip1Str,"\n"}
    local adaStr = 28
    
    if G_isIOS() == false and G_isAsia() == false then
        adaStr = 20
    elseif G_getCurChoseLanguage() == "de" then
        adaStr = 20
    end
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,adaStr,{nil,G_ColorYellowPro,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil})
    sceneGame:addChild(dialog,self.layerNum+1)
end