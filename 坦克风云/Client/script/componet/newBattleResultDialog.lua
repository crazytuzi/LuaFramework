function smallDialog:showBattleResultDialog_2(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,award,resultStar,isFuben,acData,winCondition,swId,robData,upgradeTanks,levelData,challenge,parent)
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            spriteController:addPlist("public/newDisplayImage.plist")
            spriteController:addTexture("public/newDisplayImage.png")--winR_newImage170612
            
            spriteController:addPlist("public/powerGuideImages.plist")
            spriteController:addTexture("public/powerGuideImages.png")
            spriteController:addPlist("public/resource_youhua.plist")
            spriteController:addTexture("public/resource_youhua.png")
            --battleResultAddPic
            spriteController:addPlist("public/battleResultAddPic.plist")
            spriteController:addTexture("public/battleResultAddPic.png")
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

            spriteController:addPlist("public/vipFinal.plist")--newTipImage
            -- spriteController:addPlist("public/newTipImage.plist")
            -- spriteController:addTexture("public/newTipImage.png")
            -- spriteController:addPlist("public/acChunjiepansheng.plist")

            require "luascript/script/game/gamemodel/player/powerGuideVoApi"

      local sd=smallDialog:new()
      sd:initBattleResultDialog_2(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,award,resultStar,isFuben,acData,winCondition,swId,robData,upgradeTanks,levelData,challenge,parent)
      return sd
end

function smallDialog:initBattleResultDialog_2(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,award,resultStar,isFuben,acData,winCondition,swId,robData,upgradeTanks,levelData,challenge,parent)
    self.battleType = parent.firstData.battleType
    self.parent = parent
    self.layerNum = layerNum
    self.losePercent,self.damage = self:computeTotalHurtHandler(parent.firstData.data.report,playerVoApi:getPlayerName())
    local addWinPosY2,subWinPosY2,addWinPosY3 = 40,-10,30  --胜利板子
    local addLosPosY4,subLosPosY3,subLosPosY4 = 40,25,15
    if isVictory ==false and resultStar and resultStar > 0  then
        addLosPosY4,subLosPosY3,subLosPosY4 = 0,0,0
    end
    if self.battleType == 37 then--狂热集结
        self.queue = parent.firstData.believer.queue
        self.grade = parent.firstData.believer.grade
        self.dmgRate = parent.firstData.believer.dmgRate / 10-- 平均战损率(整数部分)
        self.dmgRate2 = parent.firstData.believer.curDmgRate / 10
        self.addPoint = parent.firstData.believer.addPoint
        self.kcoin = parent.firstData.believer.kcoin

        self.believerSegStr = believerVoApi:getSegmentName(tonumber(self.grade),tonumber(self.queue))
        -- print("self.battleType====>>>>",self.battleType,self.queue,self.grade,self.dmgRate,self.addPoint,self.kcoin)
    end
    local initPosWidthScale = 0.5

	local strSize2,strSize3 = 15,25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2,strSize3= 22,32
        
    end
    local titleBg,titleBgPL,lbBg = "semicircleGreen.png","greenPointAndLine.png","lightGreenBg.png"
    if isVictory ==false then
        titleBg,titleBgPL,lbBg = "semicircleRed.png","redPointAndLine.png","lightRedBg.png"
    end

    local actionTb = {} --每个KEY 内容{ 1：使用动画效果 2：动画效果的对象 3：父类 4：动画前坐标 5：动画后坐标 6：延时时间 7：动画时间 }

    self.itemTb = {}
    self.isTouch=nil
    self.isUseAmi=false     --isuseami
    if newGuidMgr:isNewGuiding() then
        layerNum=layerNum-1
    end
    self.isVictory = isVictory
    self:addPic(isVictory)
    local bgSrc2 = "loserBgSp.jpg"
    if isVictory == true then
		bgSrc2 = "WinnerBgSp.jpg"--dwEndBg1
	end
    local function touchHandler() end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    dialogBg:setOpacity(0)
    self.dialogLayer=CCLayer:create()

    local needBlackBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,CCRect(0,0,40,40),touchHandler)
    needBlackBg:setOpacity(250)
    needBlackBg:setContentSize(CCSizeMake(G_VisibleSizeWidth+100,G_VisibleSizeHeight+100))
    needBlackBg:setPosition(ccp(-20,-20))
    self.dialogLayer:addChild(needBlackBg)
    local needBlackBg2 = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,CCRect(0,0,40,40),touchHandler)
    needBlackBg2:setOpacity(150)
    needBlackBg2:setContentSize(CCSizeMake(G_VisibleSizeWidth+100,G_VisibleSizeHeight+100))
    needBlackBg2:setPosition(ccp(-20,-20))
    self.dialogLayer:addChild(needBlackBg2)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local dialogBg2 = CCSprite:create("public/"..bgSrc2)

    if G_getIphoneType() == G_iphoneX then
        dialogBg2:setScaleY(G_VisibleSizeHeight/dialogBg2:getContentSize().height)
    end
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    dialogBg2:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))

    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self.dialogLayer:addChild(self.bgLayer,1);
    self.bgLayer:addChild(dialogBg2,1)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    self.shakeLayer = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.shakeLayer:setOpacity(0)
    self.shakeLayer:setContentSize(size)
    self.dialogLayer:addChild(self.shakeLayer,1)

    local levelAgainMenu,levelAgainItem = nil,nil    --“再次进攻”按钮
    if levelData and SizeOfTable(levelData)~=0 and isVictory and playerVoApi:getPlayerLevel()>=20 and challenge and challenge==1 then
        local function touchLevelAgain()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if playerVoApi:getEnergy()==0 then
                local function buyEnergy()
                      G_buyEnergy(layerNum+1)
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyEnergy,getlocal("dialog_title_prompt"),getlocal("energyis0"),nil,layerNum+1)
                do return end
            end

            if callBack then
                callBack(tag,object)
            end

            local function serverResponse(fn,data)
                local cresult,retTb=base:checkServerData(data)
                if cresult==true then
                      retTb.levelTb=levelData
                      battleScene:initData(retTb)
                end
            end
            socketHelper:startBattleForNPC(levelData,serverResponse)
            
            self:closeNewBattleResult()
        end
        levelAgainItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",touchLevelAgain,19,getlocal("another_battle"),strSize3)
        levelAgainItem:setAnchorPoint(ccp(0.5,0))
        levelAgainMenu = CCMenu:createWithItem(levelAgainItem)
        levelAgainMenu:setTouchPriority(-(layerNum-1)*20-4)
        levelAgainMenu:setPosition(ccp(size.width*initPosWidthScale+120,-200))---按钮 扔出去 动画时候飞进来
        actionTb["levelAgainMenu"] ={{1,103},levelAgainMenu,nil,nil,ccp(size.width*initPosWidthScale+120,20),0.5,0.5,nil }
        self.bgLayer:addChild(levelAgainMenu,2)
    end

    if self.battleType and self.battleType == 37 then
        local function closeHandler(tag,object)
            PlayEffect(audioCfg.mouseClick)

            self.bgLayer:setVisible(false)
            local flag=checkPointVoApi:getRefreshFlag()
            if flag==0 and G_WeakTb.checkPoint then
                G_WeakTb.checkPoint:refresh()
            end
            if award then
                local tipReward=playerVoApi:getTrueReward(award)
                G_showRewardTip(tipReward,true,nil)
            end
            if callBack then
                  callBack(tag,object)
            end
            self:closeNewBattleResult()
        end
        local closeBtnItem  =nil
        
        closeBtnItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",closeHandler,6,getlocal("fight_close"),32)
        closeBtnItem:setPosition(0,0)
        closeBtnItem:setAnchorPoint(CCPointMake(0.5,0))
        self.closeBtn = CCMenu:createWithItem(closeBtnItem)
        self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
        self.closeBtn:setPosition(ccp(size.width*0.3,-200))
        actionTb["closeBtn"] ={{1,103},self.closeBtn,nil,nil,ccp(size.width*0.3,50),0.5,0.5,nil }
        self.bgLayer:addChild(self.closeBtn,2)

        local function playBackCall(tag,object)
            PlayEffect(audioCfg.mouseClick)
            if self.parent then
                local parent,firstData,closeResultPanelHandler,zOrder =self.parent,self.parent.firstData,self.parent.closeResultPanelHandler,self.parent.zOrder
                self:closeNewBattleResult()
                parent:close()
                battleScene:initData(firstData,closeResultPanelHandler,zOrder)
            end
        end 
        playBackBtnItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",playBackCall,6,getlocal("playBackStr"),32)
        -- playBackBtnItem:setPosition(0,0)
        playBackBtnItem:setAnchorPoint(CCPointMake(0.5,0))
        self.playBackBtn = CCMenu:createWithItem(playBackBtnItem)
        self.playBackBtn:setTouchPriority(-(layerNum-1)*20-200)
        self.playBackBtn:setPosition(ccp(size.width*0.7,-200))
        actionTb["playBackBtn"] ={{1,103},self.playBackBtn,nil,nil,ccp(size.width*0.7,50),0.5,0.5,nil }
        self.bgLayer:addChild(self.playBackBtn,2)
--------------------------------------------------------------------------------
        local strSize3,bgHeight = 16,0
        local height=120
        bgHeight=bgHeight+height+60
        local addPosH2,addPosH3 = 10,12
        local bgAddPosH = 250
        local upPosY = 0
        -- bgHeight=bgHeight
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
            strSize3 =19
        end
        local strMovPosX = 60
        local isVictoryLabel
        local needScale1,needScale2,needScale3,needScale4 = 0.8,0.8,0.8,2.5
        local diaWidth = self.bgLayer:getContentSize().width

        if self.kcoin > 0 then
            local victoryBg = CCSprite:createWithSpriteFrameName(titleBg)--TeamHeaderBg
            victoryBg:setAnchorPoint(ccp(0.5,1))
            victoryBg:setScaleX(diaWidth/victoryBg:getContentSize().width)
            local reverseScaleX = victoryBg:getContentSize().width/diaWidth
            local reverseScaleY = 1/needScale4
            self.bgLayer:addChild(victoryBg,2)

            isVictoryLabel=GetTTFLabel(getlocal("EarnRewardStr"),28)
            isVictoryLabel:setColor(G_ColorYellowPro)

            local lbPosY = G_VisibleSizeHeight*0.54-bgAddPosH+addWinPosY2+subWinPosY2*2 + 70
            isVictoryLabel:setAnchorPoint(ccp(0.5,1))
            isVictoryLabel:setPosition(ccp(G_VisibleSizeWidth*1.5,lbPosY))
            actionTb["isVictoryLabel"] ={{1,103},isVictoryLabel,nil,nil,ccp(G_VisibleSizeWidth*0.5,lbPosY),0.7,0.5,nil }
            self.bgLayer:addChild(isVictoryLabel,2)
            local isVictoryLbWidth = isVictoryLabel:getContentSize().width

            victoryBg:setPosition(ccp(G_VisibleSizeWidth*1.5,isVictoryLabel:getPositionY() - isVictoryLabel:getContentSize().height*0.6))                
            actionTb["victoryBg"] ={{1,103},victoryBg,nil,nil,ccp(G_VisibleSizeWidth*0.5+addPosH3,isVictoryLabel:getPositionY() - isVictoryLabel:getContentSize().height*0.6),0.7,0.5,nil }

            local pointLineAncP = {ccp(1,0.5),ccp(0,0.5)}
            local pointLinePosWscal = {G_VisibleSizeWidth*0.5-isVictoryLbWidth*0.5 - 10,G_VisibleSizeWidth*0.5+isVictoryLbWidth*0.5 + 10}
            for i=1,2 do
                local pointLine = CCSprite:createWithSpriteFrameName(titleBgPL)
                pointLine:setAnchorPoint(pointLineAncP[i])
                pointLine:setPosition(ccp(pointLinePosWscal[i]+G_VisibleSizeWidth,isVictoryLabel:getPositionY() - isVictoryLabel:getContentSize().height*0.6))
                self.bgLayer:addChild(pointLine,2)
                actionTb["pointLine"..i] ={{1,103},pointLine,nil,nil,ccp(pointLinePosWscal[i],isVictoryLabel:getPositionY() - isVictoryLabel:getContentSize().height*0.6),0.7,0.5,nil}
                if i ==1 then
                  pointLine:setFlipX(true)
                end
            end
            
            local function clickBack( )
                
            end 
            local icon = LuaCCSprite:createWithSpriteFrameName("believerKcoin.png",clickBack)
            icon:setScale(0.8)
            icon:setPosition(ccp(120+G_VisibleSizeWidth,lbPosY - 100))
            actionTb["iconKCoin"] ={{1,105},icon,nil,nil,ccp(120,lbPosY - 100),0.75,0.5,nil }
            self.bgLayer:addChild(icon,2)

            local kCoinNums = GetTTFLabel(self.kcoin,20)
            local groupSelf = CCSprite:createWithSpriteFrameName("newTipDi.png")
            groupSelf:setPosition(ccp(icon:getContentSize().width-4,3))
            groupSelf:ignoreAnchorPointForPosition(false)
            groupSelf:setAnchorPoint(ccp(1,0))
            groupSelf:setFlipX(true)
            icon:addChild(groupSelf,1)
            groupSelf:setScaleX((kCoinNums:getContentSize().width+20)/groupSelf:getContentSize().width)
            groupSelf:setScaleY(0.6)
            kCoinNums:setTag(333)
            kCoinNums:setAnchorPoint(ccp(1,0))
            kCoinNums:setPosition(ccp(icon:getContentSize().width-6,4))
            icon:addChild(kCoinNums,1)
            kCoinNums:setScale(1/0.8)

            local kCoinStr = GetTTFLabel(getlocal("believer_kcoin"),23)
            kCoinStr:setAnchorPoint(ccp(0.5,1))
            kCoinStr:setPosition(ccp(icon:getContentSize().width*0.5,-5))
            icon:addChild(kCoinStr)
        end

------
          local helperBg = CCSprite:createWithSpriteFrameName(titleBg)
          helperBg:setAnchorPoint(ccp(0.5,1))
          helperBg:setScaleX(diaWidth/helperBg:getContentSize().width)
          local reverseScaleX = helperBg:getContentSize().width/diaWidth
          local reverseScaleY = 1/needScale4
          self.bgLayer:addChild(helperBg,2)

          helperLb = GetTTFLabel(getlocal("battleDataStr"),28)
          helperLb:setColor(G_ColorYellowPro)
          helperLb:setAnchorPoint(ccp(0.5,1))
          helperLb:setPosition(ccp(G_VisibleSizeWidth*1.5,G_VisibleSizeHeight*0.55+addPosH2+addWinPosY2))
          actionTb["helperLb"] ={{1,103},helperLb,nil,nil,ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.55+addPosH2-5+addWinPosY2),0.2,0.5,nil }
          self.bgLayer:addChild(helperLb,2)
          local helperLbWidth = helperLb:getContentSize().width


          helperBg:setPosition(ccp(G_VisibleSizeWidth*1.5,helperLb:getPositionY() - helperLb:getContentSize().height*0.6))
          actionTb["helperBg"] ={{1,103},helperBg,nil,nil,ccp(G_VisibleSizeWidth*0.5+addPosH3,helperLb:getPositionY() - helperLb:getContentSize().height*0.6),0.3,0.5,nil }

          local pointLineAncP2 = {ccp(1,0.5),ccp(0,0.5)}
          local pointLinePosWscal2 = {G_VisibleSizeWidth*0.5-helperLbWidth*0.5 - 10,G_VisibleSizeWidth*0.5+helperLbWidth*0.5 + 10}
          for i=1,2 do
              local pointLine2 = CCSprite:createWithSpriteFrameName(titleBgPL)
              pointLine2:setAnchorPoint(pointLineAncP2[i])
              pointLine2:setPosition(ccp(pointLinePosWscal2[i]+G_VisibleSizeWidth,helperLb:getPositionY() - helperLb:getContentSize().height*0.6))
              self.bgLayer:addChild(pointLine2,2)
              actionTb["pointLine2"..i] ={{1,103},pointLine2,nil,nil,ccp(pointLinePosWscal2[i],helperLb:getPositionY() - helperLb:getContentSize().height*0.6),0.2,0.5,nil }
              if i ==1 then
                pointLine2:setFlipX(true)
              end
          end
------
        local damageBg = LuaCCScale9Sprite:createWithSpriteFrameName(lbBg,CCRect(32,16,1,1),function() end)
        damageBg:setAnchorPoint(ccp(0,0.5))
        self.bgLayer:addChild(damageBg,2)
        --..":"..self.believerSegStr
        local damageLb = GetTTFLabelWrap(getlocal("believer_curSeg")..":",22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        damageLb:setAnchorPoint(ccp(0,0.5))
        local damageLbWidth = GetTTFLabel(getlocal("believer_curSeg")..":",22):getContentSize().width
        local segSp,segSpScale = believerVoApi:getSegmentIcon(self.grade,self.queue,damageLb:getContentSize().height + 18)
        segSp:setAnchorPoint(ccp(0,0.5))
        segSp:setPosition(ccp(damageLb:getPositionX() + damageLbWidth + 10,damageLb:getContentSize().height * 0.5))
        damageLb:addChild(segSp)
        local damageLbPos = G_VisibleSizeHeight*0.55+addPosH2-65+addWinPosY3
        damageLb:setPosition(ccp(strMovPosX+G_VisibleSizeWidth,damageLbPos))
        actionTb["damageLb"] ={{1,103},damageLb,nil,nil,ccp(strMovPosX,damageLbPos),0.4,0.5,nil }
        self.bgLayer:addChild(damageLb,2)

        damageBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,damageLb:getContentSize().height+10))
        damageBg:setPosition(ccp(strMovPosX+G_VisibleSizeWidth-50,damageLb:getPositionY()))
        actionTb["damageBg"] ={{1,103},damageBg,nil,nil,ccp(strMovPosX-50,damageLb:getPositionY()),0.4,0.5,nil }

        local repairBg = LuaCCScale9Sprite:createWithSpriteFrameName(lbBg,CCRect(32,16,1,1),function() end)
        repairBg:setAnchorPoint(ccp(0,0.5))
        self.bgLayer:addChild(repairBg,2)

        local repairPosH = G_VisibleSizeHeight*0.55+addPosH2-115+addWinPosY3--dmgRate2
        local repairLb=GetTTFLabelWrap(getlocal("believer_dmgRate2",{self.dmgRate2}).."%",22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        repairLb:setAnchorPoint(ccp(0,0.5))
        repairLb:setPosition(ccp(strMovPosX+G_VisibleSizeWidth,repairPosH))
        actionTb["repairLb"] ={{1,103},repairLb,nil,nil,ccp(strMovPosX,repairPosH),0.5,0.5,nil }
        self.bgLayer:addChild(repairLb,2)

        repairBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,repairLb:getContentSize().height+10))
        repairBg:setPosition(ccp(strMovPosX+G_VisibleSizeWidth-50,repairLb:getPositionY()))
        actionTb["repairBg"] ={{1,103},repairBg,nil,nil,ccp(strMovPosX-50,repairLb:getPositionY()),0.5,0.5,nil }

        local dmgRate2Sp = LuaCCScale9Sprite:createWithSpriteFrameName(lbBg,CCRect(32,16,1,1),function() end)
        dmgRate2Sp:setAnchorPoint(ccp(0,0.5))
        self.bgLayer:addChild(dmgRate2Sp,2)

        local repairPosH2 =G_VisibleSizeHeight*0.55+addPosH2-165+addWinPosY3--dmgRate2
        local dmgRate2Lb=GetTTFLabelWrap(getlocal("serverwar_get_point")..self.addPoint,22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        dmgRate2Lb:setAnchorPoint(ccp(0,0.5))
        dmgRate2Lb:setPosition(ccp(strMovPosX+G_VisibleSizeWidth,repairPosH2))
        actionTb["dmgRate2Lb"] ={{1,103},dmgRate2Lb,nil,nil,ccp(strMovPosX,repairPosH2),0.6,0.5,nil }
        self.bgLayer:addChild(dmgRate2Lb,2)

        dmgRate2Sp:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,dmgRate2Lb:getContentSize().height+10))
        dmgRate2Sp:setPosition(ccp(strMovPosX+G_VisibleSizeWidth-50,dmgRate2Lb:getPositionY()))
        actionTb["dmgRate2Sp"] ={{1,103},dmgRate2Sp,nil,nil,ccp(strMovPosX-50,dmgRate2Lb:getPositionY()),0.6,0.5,nil }


        -- local chakanPosH = G_VisibleSizeHeight*0.55+addPosH2-215+addWinPosY3
        -- local chakanBg = LuaCCScale9Sprite:createWithSpriteFrameName(lbBg,CCRect(32,16,1,1),function() end)
        -- chakanBg:setAnchorPoint(ccp(0,0.5))
        -- self.bgLayer:addChild(chakanBg,2)

        -- local chakanLb=GetTTFLabelWrap(getlocal("serverwar_get_point")..self.addPoint,22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        -- chakanLb:setAnchorPoint(ccp(0,0.5))
        -- chakanLb:setPosition(ccp(strMovPosX+G_VisibleSizeWidth,chakanPosH))
        -- actionTb["chakanLb"] ={{1,103},chakanLb,nil,nil,ccp(strMovPosX,chakanPosH),0.7,0.5,nil }
        -- self.bgLayer:addChild(chakanLb,2)

        -- chakanBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,chakanLb:getContentSize().height+10))
        -- chakanBg:setPosition(ccp(strMovPosX+G_VisibleSizeWidth-50,chakanLb:getPositionY()))
        -- actionTb["chakanBg"] ={{1,103},chakanBg,nil,nil,ccp(strMovPosX-50,chakanLb:getPositionY()),0.7,0.5,nil }

        if isVictory then
            self:runWinAniTank(resultStar)
        else
            self:runLoseAniTank()
        end
    elseif isVictory and robData and robData.flopReward and SizeOfTable(robData.flopReward)>0 then --超级武器 抢夺
        local flopReward=FormatItem(robData.flopReward)
        local getRewardItem
        if flopReward and flopReward[1] then
            getRewardItem=flopReward[1]
        end
        self.isFlop=false
        local bgHeight=size.height
        local needScale1 = 0.8
        local needScale4 = 2.5

        self:runWinAniTank()

        local addPosH2 = 5
        local addPosH3 = 12
        local diaWidth = self.bgLayer:getContentSize().width
        local victoryBg = CCSprite:createWithSpriteFrameName(titleBg)--TeamHeaderBg
        victoryBg:setAnchorPoint(ccp(0.5,1))
        victoryBg:setScaleX(diaWidth/victoryBg:getContentSize().width)
        local reverseScaleX = victoryBg:getContentSize().width/diaWidth
        local reverseScaleY = 1/needScale4
        self.bgLayer:addChild(victoryBg,1)


        local lotteryStr=getlocal("super_weapon_rob_lottery")
        local lotteryLb=GetTTFLabelWrap(lotteryStr,25,CCSizeMake(0,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        lotteryLb:setColor(G_ColorYellowPro)
        lotteryLb:setAnchorPoint(ccp(0.5,1))--
        lotteryLb:setPosition(ccp(G_VisibleSizeWidth*1.5,G_VisibleSizeHeight*0.55))
        actionTb["lotteryLb"] ={{1,103},lotteryLb,nil,nil,ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.55),nil,0.5,nil }
        self.bgLayer:addChild(lotteryLb,1)
        local lotteryLbWidth = lotteryLb:getContentSize().width

        victoryBg:setPosition(ccp(G_VisibleSizeWidth*1.5,lotteryLb:getPositionY()-lotteryLb:getContentSize().height*0.6))
        actionTb["victoryBg"] ={{1,103},victoryBg,nil,nil,ccp(G_VisibleSizeWidth*0.5+addPosH3,lotteryLb:getPositionY()-lotteryLb:getContentSize().height*0.6),nil,0.5,nil }

        local pointLineAncP = {ccp(1,0.5),ccp(0,0.5)}
        local pointLinePosWscal = {G_VisibleSizeWidth*0.5-lotteryLbWidth*0.5-10,G_VisibleSizeWidth*0.5+lotteryLbWidth*0.5+10}
        for i=1,2 do
            local pointLine = CCSprite:createWithSpriteFrameName(titleBgPL)
            pointLine:setAnchorPoint(pointLineAncP[i])
            pointLine:setPosition(ccp(pointLinePosWscal[i]+G_VisibleSizeWidth,lotteryLb:getPositionY()-lotteryLb:getContentSize().height*0.6))
            self.bgLayer:addChild(pointLine,2)
            actionTb["pointLine"..i] ={{1,103},pointLine,nil,nil,ccp(pointLinePosWscal[i],lotteryLb:getPositionY()-lotteryLb:getContentSize().height*0.6),nil,0.5,nil }
            if i ==1 then
              pointLine:setFlipX(true)
            end
        end

        local signData = robData.signData
        local signCurrentLv = 0
        local signFid = robData.callBackParams.fid
        if signFid and superWeaponCfg.fragmentCfg[signFid] then
            local swId = superWeaponCfg.fragmentCfg[signFid].output
            local weaponVo = superWeaponVoApi:getWeaponByID(swId)
            if weaponVo and weaponVo.lv then
                signCurrentLv = weaponVo.lv
                if weaponVo.lv >= superWeaponCfg.maxLv then
                    signCurrentLv = superWeaponCfg.maxLv
                end
            end
        end

        local posY=G_VisibleSizeHeight*0.22
        local robFid=robData.swFid

        if (signData and signData.addount and signData.addount > 0) then
            local descStr=getlocal("super_weapon_rob_max_tips", {signData.addount})
            local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0,0.5))
            descLb:setPosition(ccp(100+G_VisibleSizeWidth,posY))
            actionTb["descLb"] ={{1,105},descLb,nil,nil,ccp(100,posY),0.6,0.5,nil }
            self.bgLayer:addChild(descLb,2)
            descLb:setColor(G_ColorYellowPro)
        elseif robFid and superWeaponCfg.fragmentCfg[robFid] then
            local fCfg=superWeaponCfg.fragmentCfg[robFid]
            local nameStr=""
            if superWeaponCfg.weaponCfg[fCfg.output] then
                local wid=fCfg.output
                local cfg=superWeaponCfg.weaponCfg[wid]
                local weaponVo=superWeaponVoApi:getWeaponByID(wid)
                local level=0
                if weaponVo and weaponVo.lv and tonumber(weaponVo.lv) then
                    level=tonumber(weaponVo.lv) or 0
                end
                nameStr=getlocal(cfg.name)..getlocal("fightLevel",{level})
            end
            local descStr=getlocal("super_weapon_rob_success_reward",{nameStr})
            -- descStr=str
            local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0,0.5))
            descLb:setPosition(ccp(100+G_VisibleSizeWidth,posY))
            actionTb["descLb"] ={{1,105},descLb,nil,nil,ccp(100,posY),0.6,0.5,nil }
            self.bgLayer:addChild(descLb,2)
            descLb:setColor(G_ColorYellowPro)
        else
            local descStr
            descStr=getlocal("super_weapon_rob_not_fragment")
            local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0,0.5))
            descLb:setPosition(ccp(10+G_VisibleSizeWidth,posY))
            actionTb["descLb"] ={{1,105},descLb,nil,nil,ccp(10,posY),0.6,0.5,nil }
            self.bgLayer:addChild(descLb,2)
            descLb:setColor(G_ColorYellowPro)

            if challenge and challenge==1 then

                local function robAgainHandler(tag,object)
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    if self.isFlop~=true then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_get_reward"),30)
                        do return end
                    end

                    local energy=superWeaponVoApi:getEnergy()
                    if energy and energy<=0 then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage17041"),30)
                        do return end
                    end

                    local callBackParams=robData.callBackParams
                    local function weaponBattleCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData.data.weapon then
                                superWeaponVoApi:formatData(sData.data.weapon)
                                superWeaponVoApi:setFragmentFlag(0)
                            end
                            if sData.data and sData.data.flop then
                                local award=FormatItem(sData.data.flop) or {}
                                for k,v in pairs(award) do
                                    G_addPlayerAward(v.type,v.key,v.id,v.num)
                                end
                            end
                            if sData.data and sData.data.accessory then
                                accessoryVoApi:onRefreshData(sData.data.accessory)
                            end
                            if sData.data and sData.data.report then
                                sData.battleType=3
                                sData.callBackParams=callBackParams
                                sData.robData={targetData=robData.targetData}
                                battleScene:initData(sData)
                            end
                            self:close(false)
                        end
                    end
                    socketHelper:weaponBattle(callBackParams,weaponBattleCallback)
                    if callBack then
                        callBack(tag,object)
                    end
                    self:closeNewBattleResult()
                end
                local robAgainItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",robAgainHandler,19,getlocal("super_weapon_rob_again"),strSize2+4)
                robAgainItem:setAnchorPoint(ccp(1,0.5))
                local robAgainMenu = CCMenu:createWithItem(robAgainItem)
                robAgainMenu:setTouchPriority(-(layerNum-1)*20-4)
                robAgainMenu:setPosition(ccp(G_VisibleSizeWidth-50+G_VisibleSizeWidth,posY))
                actionTb["robAgainMenu"] ={{1,105},robAgainMenu,nil,nil,ccp(G_VisibleSizeWidth-50,posY),0.6,0.5,nil }
                self.bgLayer:addChild(robAgainMenu,2)
            end
        end

        local xSpace=20
        -- local pool=G_clone(FormatItem(weaponrobCfg.flopReward))
        local flopRewardId = 1
        for i,v in ipairs(weaponrobCfg.flopGroup) do
            local lv1 = v[1]
            local lv2 = v[2]
            if signCurrentLv >= lv1 and signCurrentLv <= lv2 then
                flopRewardId = i
                break
            end
        end
        local pool=G_clone(FormatItem(weaponrobCfg["flopReward" .. flopRewardId]))
        for k,v in pairs(pool) do
            if getRewardItem and getRewardItem.type==v.type and getRewardItem.key==v.key then
                table.remove(pool,k)
            end
        end
        for i=1,3 do
            local function flopHandler(object,name,tag)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                self.isFlop=true
                for k=1,3 do
                    local cardSp1=tolua.cast(self.bgLayer:getChildByTag(100+k),"LuaCCSprite")
                    local function onFlipHandler()
                        if cardSp1 then
                            cardSp1:removeFromParentAndCleanup(true)
                        end
                        local poolTb=G_clone(pool)
                        for j=1,3 do
                            local cardSp2=CCSprite:createWithSpriteFrameName("rewardCard2.png")
                            local px=size.width/2-cardSp2:getContentSize().width-xSpace+(cardSp2:getContentSize().width+xSpace)*(j-1)
                            cardSp2:setPosition(ccp(px,G_VisibleSizeHeight*0.38))
                            self.bgLayer:addChild(cardSp2,2)
                            cardSp2:setFlipX(true)
                            local icon,name,num
                            if tag==100+j then
                                if getRewardItem then
                                    icon=G_getItemIcon(getRewardItem,100)
                                    name=getRewardItem.name
                                    num=getRewardItem.num
                                    G_addRectFlicker(cardSp2,2,2.4)
                                end
                            else
                                if poolTb and SizeOfTable(poolTb)>0 then
                                    local index=math.random(1,SizeOfTable(poolTb))
                                    local item=poolTb[index]
                                    if item then
                                        -- print("item.id,item.type",item.id,item.type,item.name)
                                        icon=G_getItemIcon(item,100)
                                        name=item.name
                                        num=item.num
                                        table.remove(poolTb,index)
                                    end
                                end
                            end
                            icon:setPosition(ccp(cardSp2:getContentSize().width/2,110))
                            cardSp2:addChild(icon,2)
                            local nameLb=GetTTFLabelWrap(name,strSize2,CCSizeMake(cardSp2:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                            nameLb:setPosition(ccp(cardSp2:getContentSize().width/2,35))
                            cardSp2:addChild(nameLb,2)
                            local numLb=GetTTFLabel("x"..num,25)
                            numLb:setAnchorPoint(ccp(0,0))
                            numLb:setPosition(ccp(5,5))
                            icon:addChild(numLb,2)
                            numLb:setFlipX(true)
                            icon:setFlipX(true)
                            nameLb:setFlipX(true)

                            local function onFlipHandler2()
                                if flopReward and SizeOfTable(flopReward)>0 then
                                    G_showRewardTip(flopReward)
                                end
                            end
                            local callFunc=CCCallFunc:create(onFlipHandler2)
                            local orbitCamera=CCOrbitCamera:create(0.5,1,0,90,90,0,0)
                            local acArr=CCArray:create()
                            acArr:addObject(orbitCamera)
                            acArr:addObject(callFunc)
                            local seq=CCSequence:create(acArr)
                            cardSp2:runAction(seq)
                        end
                    end
                    if cardSp1 then
                        local callFunc=CCCallFunc:create(onFlipHandler)
                        local delay=CCDelayTime:create(2)
                        --旋转的时间，起始半径，半径差，起始z角，旋转z角差，起始x角，旋转x角差
                        local angleDiff=12
                        local angleDiffZ=90
                        if k==1 then
                            angleDiffZ=angleDiffZ-angleDiff
                        elseif k==2 then
                        elseif k==3 then
                            angleDiffZ=angleDiffZ+angleDiff
                        end
                        local orbitCamera=CCOrbitCamera:create(0.5,1,0,0,angleDiffZ,0,0)
                        local acArr=CCArray:create()
                        acArr:addObject(orbitCamera)
                        acArr:addObject(callFunc)
                        local seq=CCSequence:create(acArr)
                        cardSp1:runAction(seq)
                    end
                end
            end
            local cardSp=LuaCCSprite:createWithSpriteFrameName("rewardCard1.png",flopHandler)
            local px=size.width/2-cardSp:getContentSize().width-xSpace+(cardSp:getContentSize().width+xSpace)*(i-1)
            cardSp:setAnchorPoint(ccp(0.5,0.5))
            cardSp:setPosition(ccp(px+G_VisibleSizeWidth,G_VisibleSizeHeight*0.38))
            actionTb["cardSp"..i] ={{1,105},cardSp,nil,nil,ccp(px,G_VisibleSizeHeight*0.38),0.2,0.4,nil }
            cardSp:setTouchPriority(-(layerNum-1)*20-4)
            self.bgLayer:addChild(cardSp,2)
            cardSp:setTag(100+i)
        end

        local function sureHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if self.isFlop~=true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_get_reward"),30)
                do return end
            end
            if callBack then
                callBack(tag,object)
            end
            self:closeNewBattleResult()
        end
        local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",sureHandler,2,getlocal("ok"),strSize2+4)
        local sureMenu=CCMenu:createWithItem(sureItem)
        sureMenu:setPosition(ccp(size.width-160,80))
        actionTb["sureMenu"] ={{1,105},sureMenu,nil,nil,ccp(G_VisibleSizeWidth-160,80),0.2,0.4,nil }
        sureMenu:setTouchPriority(-(layerNum-1)*20-2)
        dialogBg:addChild(sureMenu,2)

        local function sendHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if self.isFlop~=true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_get_reward"),strSize2+4)
                do return end
            end
            local targetName=""
            if robData and robData.targetData and SizeOfTable(robData.targetData)>0 then
                targetName=robData.targetData.name
            end
            local content=getlocal("super_weapon_rob_chat_report",{playerVoApi:getPlayerName(),targetName})
            local report=robData.report
            G_sendReportChat(layerNum,content,report,9)
            if callBack then
                callBack(tag,object)
            end
            self:closeNewBattleResult()
        end
        local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",sendHandler,2,getlocal("super_weapon_rob_send_report"),strSize2+4)
        local sureMenu=CCMenu:createWithItem(sureItem);
        sureMenu:setPosition(ccp(160,80))
        sureMenu:setTouchPriority(-(layerNum-1)*20-2);
        dialogBg:addChild(sureMenu,2)

        if self.isUseAmi then
            self:show()
        end
    else----------=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=------------=-=-=-=-=-=-=-=-=-=-=-=-=-=--------------------------------------------
        local isAcBanzhangshilian=false
        if acData and acData.type and acData.type=="banzhangshilian" then
            isAcBanzhangshilian=true
            if isVictory==true then
                award=acData.award
            end
        end

        local function operateHandler(tag,object)
            if G_checkClickEnable()==false then
                    do return end
            end
            --PlayEffect(audioCfg.mouseClick)
            if callBack then
                  callBack(tag,object)
            end

            if isFuben~=true then
                storyScene.checkPointDialog[1]=nil
                for i=#base.commonDialogOpened_WeakTb,1,-1 do
                    if(base.commonDialogOpened_WeakTb[i] and base.commonDialogOpened_WeakTb[i].bgLayer and base.commonDialogOpened_WeakTb[i].setDisplay)then
                        base.commonDialogOpened_WeakTb[i]:setDisplay(true)
                    end
                    if(base.commonDialogOpened_WeakTb[i]~=storyScene)then
                        base.commonDialogOpened_WeakTb[i]:close(false)
                    end
                end
            end

            local dlayerNum=6
            if tag==1 then
                  --"研发科技"
                  local bid=3
                  local type=8
                  local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
                  if buildVo and buildVo.status>0 then
                        require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
                        local td=techCenterDialog:new(bid,dlayerNum,true)
                        local bName=getlocal(buildingCfg[type].buildName)
                        local tbArr={getlocal("building"),getlocal("startResearch")}
                        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,dlayerNum)
                        td:tabClick(1)
                        sceneGame:addChild(dialog,dlayerNum)
                  end
            elseif tag==2 then
                  --“建造舰船”
                  local bid=11
                  local type=6
                  local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
                  if buildVo and buildVo.status>0 then
                        require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
                        local td=tankFactoryDialog:new(bid,dlayerNum,true)
                        local bName=getlocal(buildingCfg[type].buildName)
                        local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
                        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,dlayerNum)
                        td:tabClick(1)
                        sceneGame:addChild(dialog,dlayerNum)
                  end
            elseif tag==3 then
                local td=playerVoApi:showPlayerDialog(1,dlayerNum,true)
                td:tabClick(0)
            elseif tag==4 then
                local td=playerVoApi:showPlayerDialog(2,dlayerNum,true)
                td:tabClick(1)
            elseif tag==5 then
                  --"修理舰船"
                  require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
                  local td=tankDefenseDialog:new(dlayerNum,true)
                  local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
                  local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("defenceSetting"),true,dlayerNum)
                  td:tabClick(2)
                  sceneGame:addChild(dialog,dlayerNum)
                  if award then
                    local tipReward=playerVoApi:getTrueReward(award)
                    G_showRewardTip(tipReward,true,nil)
                  end
            end
            self:closeNewBattleResult()
        end
        local function closeHandler(tag,object)
            PlayEffect(audioCfg.mouseClick)
            if newGuidMgr:isNewGuiding()==true then
                activityAndNoteDialog:closeAllDialog()
                storyScene:close()
                newGuidMgr:toNextStep()
            end
            self.bgLayer:setVisible(false)
            local flag=checkPointVoApi:getRefreshFlag()
            if flag==0 and G_WeakTb.checkPoint then
                G_WeakTb.checkPoint:refresh()
            end
            if award then
                local tipReward=playerVoApi:getTrueReward(award)
                G_showRewardTip(tipReward,true,nil)
            end
            if self.parent.battleType==11 then --远征军关闭
                if expeditionVoApi:isCanRevive(true) == 1 and isVictory == false then --如果可以复活将领并战斗失败则弹出提醒玩家复活将领的页面
                    expeditionVoApi:showReviveHeroDialog(layerNum)
                end
            end
            if callBack then
                  callBack(tag,object)
            end
            spriteController:removePlist("public/vipFinal.plist")
            self:closeNewBattleResult()
        end
        local closeBtnItem  =nil
        
        closeBtnItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",closeHandler,6,getlocal("fight_close"),32)
        closeBtnItem:setPosition(0,0)
        closeBtnItem:setAnchorPoint(CCPointMake(0.5,0))
        self.closeBtn = CCMenu:createWithItem(closeBtnItem)
        self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
        self.closeBtn:setPosition(ccp(size.width*initPosWidthScale+150,-200))
        actionTb["closeBtn"] ={{1,103},self.closeBtn,nil,nil,ccp(size.width*initPosWidthScale+150,20),0.5,0.5,nil }
        self.bgLayer:addChild(self.closeBtn,2)

        local function playBackCall(tag,object)
            PlayEffect(audioCfg.mouseClick)
            if self.parent then
                local parent,firstData,closeResultPanelHandler,zOrder =self.parent,self.parent.firstData,self.parent.closeResultPanelHandler,self.parent.zOrder
                self:closeNewBattleResult()
                parent:close()
                battleScene:initData(firstData,closeResultPanelHandler,zOrder)
            end
        end 
        playBackBtnItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",playBackCall,6,getlocal("playBackStr"),32)
        -- playBackBtnItem:setPosition(0,0)
        playBackBtnItem:setAnchorPoint(CCPointMake(0.5,0))
        self.playBackBtn = CCMenu:createWithItem(playBackBtnItem)
        self.playBackBtn:setTouchPriority(-(layerNum-1)*20-200)
        self.playBackBtn:setPosition(ccp(size.width*initPosWidthScale-150,-200))
        actionTb["playBackBtn"] ={{1,103},self.playBackBtn,nil,nil,ccp(size.width*initPosWidthScale-150,20),0.5,0.5,nil }
        self.bgLayer:addChild(self.playBackBtn,2)

        playBackBtnItem:setScale(0.8)
        closeBtnItem:setScale(0.8)
        if newGuidMgr:isNewGuiding() then
            playBackBtnItem:setVisible(false)
            self.closeBtn:setPosition(ccp(size.width*0.5,-200))
            actionTb["closeBtn"] ={{1,103},self.closeBtn,nil,nil,ccp(size.width*0.5,20),0.5,0.5,nil }

            local width,height=closeBtnItem:getContentSize().width*closeBtnItem:getScale(),closeBtnItem:getContentSize().height*closeBtnItem:getScale()
            local x,y=size.width*0.5-width/2,20+height/2
            newGuidMgr:setGuideStepField(16,nil,nil,nil,{clickRect=CCRectMake(x,y,width,height)})
        end

        if levelAgainMenu then
            self.playBackBtn:setPositionX(size.width*initPosWidthScale)
            actionTb["playBackBtn"][5] =ccp(size.width*initPosWidthScale,20)
            self.closeBtn:setPositionX(size.width*initPosWidthScale + 185)
            actionTb["closeBtn"][5] =ccp(size.width*initPosWidthScale + 185,20)
            levelAgainMenu:setPosition(ccp(size.width*initPosWidthScale - 185,-200))
            actionTb["levelAgainMenu"][5] =ccp(size.width*initPosWidthScale - 185,20)
            
            levelAgainItem:setScale(0.8)
        end
          
          --判断是否有需要修理的坦克
        local repairTanks=tankVoApi:getRepairTanks()
        local isShowRepair=false
        if repairTanks~=nil then
            local RepairNum=SizeOfTable(repairTanks)
            if RepairNum>0 then
                  isShowRepair=true
            end
        end
        if isAcBanzhangshilian==true then
            isShowRepair=false
        end

        local bgHeight=0
        if isVictory and resultStar==3 and newGuidMgr:isNewGuiding()==false then
            if G_isShowShareBtn() then --只有facebook显示分享
                local function sendFeedHandler()
                    local function sendFeedCallback()
                        local function feedsawardHandler(fn,data)
                            if base:checkServerData(data)==true then
                                if G_curPlatName()=="12" or G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="0" or G_curPlatName()=="andgamesdealru" then
                                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shareSuccess"),28)
                                end
                                closeHandler()
                            end
                        end
                        if(G_isKakao()==false)then
                              socketHelper:feedsaward(1,feedsawardHandler)
                        else
                              closeHandler()
                        end
                    end
                    G_sendFeed(1,sendFeedCallback)
                end
                local btnTextSize = 32
                if G_getCurChoseLanguage()=="ru" then
                    btnTextSize = 25
                end
                local feedBtn,feedBtnItem
                if(G_isKakao())then
                    feedBtn=LuaCCSprite:createWithFileName("zsyImage/kakaoFeedBtn.png",sendFeedHandler)
                    feedBtn:setScaleY(0.95)
                    feedBtn:setScaleX(0.7)
                    feedBtn:setPosition(ccp(size.width/2 -185 ,-200))
                    actionTb["feedBtn"] ={{1,103},feedBtn,nil,nil,ccp(size.width/2 -185,25),0.5,0.5,nil }
                    -- closeBtnItem:setScaleX(1.2)
                else
                    
                    feedBtnItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",sendFeedHandler,7,getlocal("feedBtn"),btnTextSize)
                    feedBtnItem:setScale(0.8)
                    feedBtnItem:setPosition(0,0)
                    feedBtnItem:setAnchorPoint(CCPointMake(0.5,0))
                    
                    feedBtn = CCMenu:createWithItem(feedBtnItem)
                    feedBtn:setPosition(ccp(size.width/2 -185,-200))
                    actionTb["feedBtn"] ={{1,103},feedBtn,nil,nil,ccp(size.width/2 -185,20),0.5,0.5,nil }
                end
                feedBtn:setAnchorPoint(ccp(0.5,0))
                feedBtn:setTouchPriority(-(layerNum-1)*20-4)
                self.bgLayer:addChild(feedBtn,2)
                
                self.playBackBtn:setPositionX(size.width*initPosWidthScale)
                actionTb["playBackBtn"][5] =ccp(size.width*initPosWidthScale,20)
                self.closeBtn:setPositionX(size.width*initPosWidthScale + 185)
                actionTb["closeBtn"][5] =ccp(size.width*initPosWidthScale + 185,20)
                if levelAgainMenu then

                  self.playBackBtn:setPositionX(size.width*0.14)
                  actionTb["playBackBtn"][5] =ccp(size.width*0.14,20)

                  feedBtn:setPositionX(size.width*0.38)
                  actionTb["feedBtn"][5] =ccp(size.width*0.38,20)

                  levelAgainMenu:setPosition(ccp(size.width*0.62,-200))
                  actionTb["levelAgainMenu"][5] =ccp(size.width*0.62,20)
                  
                  self.closeBtn:setPositionX(size.width*0.86)
                  actionTb["closeBtn"][5] =ccp(size.width*0.86,20)

                  closeBtnItem:setScale(0.7)
                  playBackBtnItem:setScale(0.7)
                  levelAgainItem:setScale(0.7)
                  if feedBtnItem then
                      feedBtnItem:setScale(0.7)
                  end
                end
                local textS_ize
                if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
                    textS_ize=18
                else
                    textS_ize=25
                end
                if(G_isKakao()==false)then
                    local feedDescLable = GetTTFLabelWrap(getlocal("feedDesc"),textS_ize,CCSizeMake(25*20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                    feedDescLable:setAnchorPoint(ccp(0.5,0))
                    feedDescLable:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,-120))
                    -- print("feedDescLable.y-->>>",feedDescLable:getPositionY())
                    actionTb["feedDescLable"] ={{1,103},feedDescLable,nil,nil,ccp(self.bgLayer:getContentSize().width*0.5,100),0.5,0.5,nil }
                    self.bgLayer:addChild(feedDescLable,1)
                    bgHeight=bgHeight+20
                end
            end
        end
        local strSize3 = 16
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
            strSize3 =19
        end
        local strMovPosX = 60
        local isVictoryLabel
        local needScale1 = 0.8
        local needScale2 = 0.8
        local needScale3 = 0.8
        local needScale4 = 2.5
        local diaWidth = self.bgLayer:getContentSize().width
        if isVictory or (award and SizeOfTable(award)>0) then--胜利 或是 有奖励显示（有奖励未必胜利）
                
                local height=120
                bgHeight=bgHeight+height
                if upgradeTanks and SizeOfTable(upgradeTanks)>0 then
                  bgHeight=bgHeight+height
                end
                

                local awardNum = 0
                if award then--奖励
                    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
                    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
                    local honTb =Split(playerCfg.honors,",")
                    local maxHonors =honTb[maxLevel] --当前服 最大声望值
                    local expTb =Split(playerCfg.level_exps,",")
                    local maxExp = expTb[maxLevel] --当前服 最大经验值
                    local playerExp = playerVoApi:getPlayerExp() --用户当前的经验值
                    local AllGems = 0 --用于满级后的水晶数量
                    
                    awardNum=SizeOfTable(award)
                    local subWidthS = 0
                    local subWidthNum = 0
                    -- if awardNum <3 then --测试使用
                    --   awardNum =3
                    --    local xx = G_clone(award[1])
                    --    table.insert(award,xx)
                    --    -- local xx = G_clone(award[2])
                    --    -- table.insert(award,xx)
                    --    -- local xx = G_clone(award[1])
                    --    -- table.insert(award,xx)
                    -- end
                    if awardNum == 2 then
                      subWidthS =  25
                    elseif awardNum ==3 then
                      subWidthS = 20
                    elseif awardNum ==4 then
                      subWidthS = 10
                    end
                    if awardNum < 4 then
                      subWidthNum = awardNum
                    else
                      subWidthNum = 4
                    end
                    local initPosX = self.bgLayer:getContentSize().width*0.5-75*(subWidthNum-1)-subWidthS
                    -- local awardHeight=(math.ceil(awardNum/2)+1)*120+40
                    -- if subWidthNum == 1 then
                    --   initPosX =initPosX - 75
                    -- end
                    local bzslNeedPosH,bzslNeedPosW =nil --用于班长试炼
                    local bgAddPosH111 = 180
                    local awardHeight = G_VisibleSizeHeight*0.49-70-bgAddPosH111

                    if  awardNum <5 then
                        awardHeight = G_VisibleSizeHeight*0.49-85-bgAddPosH111 
                    end
                    for k,v in pairs(award) do   --奖励排列
                        if v and v.name and v.num then
                            local nameTag,iconTag,numTag = k*100+1,k*100+2,k*100+3
                            local awidth = initPosX+((k-1)%4)*130
                            local aheight = awardHeight-(math.floor((k-1)/4))*110+addWinPosY2+subWinPosY2*2
                            local iconSize=80
                            local iiScale=1
                            local icon
                            if v.key==nil and v.pic and v.pic~="" then
                                icon = CCSprite:createWithSpriteFrameName(v.pic)
                                iiScale=0.8
                            else
                                icon,iiScale = G_getItemIcon(v,iconSize,true,layerNum)
                                if(icon.setIsSallow)then
                                    icon:setIsSallow(false)
                                end
                                if(icon.setTouchPriority)then
                                    icon:setTouchPriority(-(layerNum-1)*20-4)
                                end
                            end
                            if v.name ==getlocal("honor") and base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
                                local nameLb =tolua.cast(self.bgLayer:getChildByTag(nameTag),"CCLabelTTF")
                                  if nameLb ==nil then
                                    icon = CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
                                    icon:setAnchorPoint(ccp(0,0))
                                    if awardNum == 1 then
                                      awidth = awidth -icon:getContentSize().width*scale*0.4
                                    end
                                    icon:setPosition(ccp(awidth+G_VisibleSizeWidth,aheight))
                                    icon:setTag(iconTag)
                                    actionTb["icon"..k]={{1,105},icon,nil,nil,ccp(awidth,aheight),k*0.7,0.5,nil }
                                    self.bgLayer:addChild(icon,2)
                                    local scale=iconSize/icon:getContentSize().width
                                    icon:setScale(scale)    
                                    local needIconPosH = icon:getPositionY()

                                    local nameLable = GetTTFLabelWrap(getlocal("money"),strSize3,CCSize(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    nameLable:setAnchorPoint(ccp(0.5,1))
                                    nameLable:setPosition(ccp(awidth+icon:getContentSize().width*0.5+G_VisibleSizeWidth,needIconPosH-5))
                                    if G_getCurChoseLanguage() =="ru" then
                                        nameLable:setVisible(false)
                                    end
                                    actionTb["nameLable"..k] ={{1,105},nameLable,nil,nil,ccp(awidth+icon:getContentSize().width*0.5*scale,needIconPosH-5),0.7+(k*0.05),0.5,nil }

                                    self.bgLayer:addChild(nameLable,1)
                                    nameLable:setTag(nameTag)
                                    local gems = playerVoApi:convertGems(2,v.num)
                                    AllGems =gems
                                    local numLable = GetTTFLabel(FormatNumber(gems),18)

                                    local groupSelf = CCSprite:createWithSpriteFrameName("newTipDi.png")
                                    groupSelf:setPosition(ccp(icon:getContentSize().width-4,3))
                                    groupSelf:ignoreAnchorPointForPosition(false)
                                    groupSelf:setAnchorPoint(ccp(1,0))
                                    groupSelf:setFlipX(true)
                                    icon:addChild(groupSelf,1)
                                    groupSelf:setScaleX((numLable:getContentSize().width+20)/groupSelf:getContentSize().width)
                                    groupSelf:setScaleY(0.6)

                                    numLable:setTag(numTag)

                                    numLable:setAnchorPoint(ccp(1,0))
                                    numLable:setPosition(ccp(icon:getContentSize().width-6,4))
                                    icon:addChild(numLable,1)
                                    numLable:setScale(1/iiScale)

                                  else
                                    local gems = playerVoApi:convertGems(2,v.num)
                                    local icon = tolua.cast(self.bgLayer:getChildByTag(iconTag),"CCSprite")
                                    local numLb =tolua.cast(icon:getChildByTag(numTag),"CCLabelTTF")
                                    numLb:setString(AllGems+gems)
                                    if awardNum ==2 then
                                        icon:setPosition(ccp(G_VisibleSizeWidth*1.5,aheight))
                                        local scale = iconSize/icon:getContentSize().width
                                        actionTb["icon1"][5].x = G_VisibleSizeWidth*0.5-icon:getContentSize().width*scale*0.5
                                        actionTb["nameLable1"][5].x =G_VisibleSizeWidth*0.5
                                    end
                                    
                                  end
                            elseif v.name ==getlocal("sample_general_exp") and base.isConvertGems==1 and tonumber(playerExp) >=tonumber(maxExp) then
                                  local nameLb =tolua.cast(self.bgLayer:getChildByTag(nameTag),"CCLabelTTF")
                                  if nameLb ==nil then
                                    icon = CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
                                    icon:setAnchorPoint(ccp(0,0))
                                    if awardNum == 1 then
                                      -- icon:setAnchorPoint(ccp(0.5,0))
                                      awidth = awidth -icon:getContentSize().width*scale*0.4
                                    end
                                    icon:setTag(iconTag)
                                    icon:setPosition(ccp(awidth+G_VisibleSizeWidth,aheight))
                                    actionTb["icon"..k] ={{1,105},icon,nil,nil,ccp(awidth,aheight),0.7+(k*0.05),0.5,nil }
                                    self.bgLayer:addChild(icon,2)
                                    local scale=iconSize/icon:getContentSize().width
                                    icon:setScale(scale)    
                                    local needIconPosH2 = icon:getPositionY()

                                    local nameLable = GetTTFLabelWrap(getlocal("money"),strSize3,CCSize(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    nameLable:setAnchorPoint(ccp(0.5,1))
                                    nameLable:setPosition(ccp(awidth+icon:getContentSize().width*0.5+G_VisibleSizeWidth,needIconPosH2-5))
                                    actionTb["nameLable"..k] ={{1,105},nameLable,nil,nil,ccp(awidth+icon:getContentSize().width*0.5*scale,needIconPosH2-5),0.7+(k*0.05),0.5,nil }
                                    if G_getCurChoseLanguage() =="ru" then
                                        nameLable:setVisible(false)
                                    end

                                    self.bgLayer:addChild(nameLable,1)
                                    nameLable:setTag(nameTag)

                                    local gems = playerVoApi:convertGems(1,v.num)
                                    AllGems =gems
                                    local numLable = GetTTFLabel(FormatNumber(gems),18)

                                    local groupSelf = CCSprite:createWithSpriteFrameName("newTipDi.png")
                                    groupSelf:setPosition(ccp(icon:getContentSize().width-4,3))
                                    groupSelf:ignoreAnchorPointForPosition(false)
                                    groupSelf:setAnchorPoint(ccp(1,0))
                                    groupSelf:setFlipX(true)
                                    icon:addChild(groupSelf,1)
                                    groupSelf:setScaleX((numLable:getContentSize().width+20)/groupSelf:getContentSize().width)
                                    groupSelf:setScaleY(0.6)

                                    numLable:setTag(numTag)

                                    numLable:setAnchorPoint(ccp(1,0))
                                    numLable:setPosition(ccp(icon:getContentSize().width-6,4))
                                    icon:addChild(numLable,1)
                                    numLable:setScale(1/iiScale)
                                  else
                                    local gems = playerVoApi:convertGems(1,v.num)
                                    local icon = tolua.cast(self.bgLayer:getChildByTag(iconTag),"CCSprite")
                                    local numLb =tolua.cast(icon:getChildByTag(numTag),"CCLabelTTF")
                                    numLb:setString(AllGems+gems)  
                                  end                        
                            else
                                local needIconPosH2= aheight
                                local scale = 1
                                if icon then
                                    icon:setAnchorPoint(ccp(0,0))
                                    if awardNum == 1 then
                                      awidth = awidth -icon:getContentSize().width*scale*0.4
                                    end
                                    icon:setPosition(ccp(awidth+G_VisibleSizeWidth,aheight))
                                    actionTb["icon"..k] ={{1,105},icon,nil,nil,ccp(awidth,aheight),0.7+(k*0.05),0.5,nil }
                                    self.bgLayer:addChild(icon,2)
                                    scale=iconSize/icon:getContentSize().width
                                    if icon:getContentSize().width<icon:getContentSize().height then
                                        scale = iconSize/icon:getContentSize().height
                                        iiScale = scale
                                    end
                                    icon:setScale(scale)
                                    needIconPosH2 = icon:getPositionY()
                                end

                                local nameLable = GetTTFLabelWrap(v.name,strSize3,CCSize(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                nameLable:setAnchorPoint(ccp(0.5,1))
                                if G_getCurChoseLanguage() =="ru" then
                                        nameLable:setVisible(false)
                                    end
                                if icon ~=nil then
                                  nameLable:setPosition(ccp(awidth+icon:getContentSize().width*0.5+G_VisibleSizeWidth,needIconPosH2-5))
                                  actionTb["nameLable"..k] ={{1,105},nameLable,nil,nil,ccp(awidth+icon:getContentSize().width*0.5*scale,needIconPosH2-5),0.7+(k*0.05),0.5,nil }
                                else
                                  nameLable:setPosition(ccp(awidth+iconSize+5+G_VisibleSizeWidth,needIconPosH))
                                  actionTb["nameLable"..k] ={{1,105},nameLable,nil,nil,ccp(awidth+iconSize+5,needIconPosH),0.7+(k*0.05),0.5,nil }
                                end

                                self.bgLayer:addChild(nameLable,1)
                                local numLable = GetTTFLabel(FormatNumber(v.num),18)
                                if icon ==nil then
                                  numLable:setAnchorPoint(ccp(0.5,1))
                                  numLable:setPosition(ccp(awidth+iconSize+5+G_VisibleSizeWidth,needIconPosH2))
                                  actionTb["numLable"..k] ={{1,105},numLable,nil,nil,ccp(awidth+iconSize+5,needIconPosH2),0.7+(k*0.05),0.5,nil }
                                  self.bgLayer:addChild(numLable,1)
                                else
                                  numLable:setScale(1/iiScale)

                                  local groupSelf = CCSprite:createWithSpriteFrameName("newTipDi.png")
                                  groupSelf:setPosition(ccp(icon:getContentSize().width-4,3))
                                  groupSelf:ignoreAnchorPointForPosition(false)
                                  groupSelf:setAnchorPoint(ccp(1,0))
                                  groupSelf:setFlipX(true)
                                  icon:addChild(groupSelf,1)
                                  groupSelf:setScaleX((numLable:getContentSize().width*numLable:getScale()+20)/groupSelf:getContentSize().width)
                                  groupSelf:setScaleY(1/icon:getScale()*0.5)

                                  numLable:setTag(numTag)
                                  numLable:setAnchorPoint(ccp(1,0))
                                  numLable:setPosition(ccp(icon:getContentSize().width-6,4))
                                  icon:addChild(numLable,1)
                                  
                                end
                            end
                        
                            if awardNum==1 and isAcBanzhangshilian==true then
                                local hei1=bzslNeedPosH
                                local hei2=bzslNeedPosH-55
                                if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
                                    hei2=bzslNeedPosH-45
                                end
                                -- local hei2=aheight+5+bgHeight-height+15
                                local star=acData.star or 0
                                local firstStar=acData.firstStar or 0
                                local firstRate=acData.firstRate or 0
                                local totalStar=star+firstStar
                                local cStar=getlocal("activity_banzhangshilian_complete_reward")
                                local starLb=GetTTFLabel(totalStar,25)
                                starLb:setAnchorPoint(ccp(0,1))
                                starLb:setPosition(ccp(bzslNeedPosW+200+G_VisibleSizeWidth,hei1))
                                actionTb["starLb"] ={{1,105},starLb,nil,nil,ccp(bzslNeedPosW+200,hei1),k*0.7,0.5,nil }
                                self.bgLayer:addChild(starLb,1)
                                local starSp1=CCSprite:createWithSpriteFrameName("StarIcon.png")
                                starSp1:setAnchorPoint(ccp(0,1))
                                starSp1:setPosition(ccp(bzslNeedPosW+240+G_VisibleSizeWidth,hei1+5))
                                actionTb["starSp1"] ={{1,105},starSp1,nil,nil,ccp(bzslNeedPosW+240,hei1+5),k*0.7,0.5,nil }
                                self.bgLayer:addChild(starSp1,1)
                                local completeLb=GetTTFLabelWrap(getlocal("activity_banzhangshilian_complete_reward"),25,CCSize(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                completeLb:setAnchorPoint(ccp(0,1))
                                completeLb:setPosition(ccp(bzslNeedPosW+250+starSp1:getContentSize().width+G_VisibleSizeWidth,hei1))
                                actionTb["completeLb"] ={{1,105},completeLb,nil,nil,ccp(bzslNeedPosW+250+starSp1:getContentSize().width,hei1),k*0.7,0.5,nil }
                                self.bgLayer:addChild(completeLb,1)

                                if firstStar and firstStar>0 then
                                    local firstCompleteLb=GetTTFLabelWrap(getlocal("activity_banzhangshilian_first_complete_reward",{firstRate}),25,CCSize(self.bgLayer:getContentSize().width/2-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    firstCompleteLb:setAnchorPoint(ccp(0,0))
                                    firstCompleteLb:setPosition(ccp(bzslNeedPosW+200+G_VisibleSizeWidth,hei2))
                                    actionTb["firstCompleteLb"] ={{1,105},firstCompleteLb,nil,nil,ccp(bzslNeedPosW+200,hei2),k*0.7,0.5,nil }
                                    self.bgLayer:addChild(firstCompleteLb,1)
                                    firstCompleteLb:setColor(G_ColorYellowPro)
                                end
                            end
                        end--奖励排列
                    end
                    bgHeight=bgHeight+awardHeight
                end
                bgHeight=bgHeight+60
                --lineAndPoint.png
                local addPosH2 = 10
                local bgAddPosH = 260
                if awardNum < 5 then
                  addPosH2 = 0
                    bgAddPosH =bgAddPosH - 80
                end
                local addPosH3 = 12

                local upPosY = -15
                if upgradeTanks and SizeOfTable(upgradeTanks)>0 then--精英坦克
                    upPosY  = 0
                end

                local victoryBg = CCSprite:createWithSpriteFrameName(titleBg)--TeamHeaderBg
                victoryBg:setAnchorPoint(ccp(0.5,1))
                victoryBg:setScaleX(diaWidth/victoryBg:getContentSize().width)
                local reverseScaleX = victoryBg:getContentSize().width/diaWidth
                local reverseScaleY = 1/needScale4
                self.bgLayer:addChild(victoryBg,2)

                if award then
                      isVictoryLabel=GetTTFLabel(getlocal("EarnRewardStr"),28)
                      isVictoryLabel:setColor(G_ColorYellowPro)
                else
                      isVictoryLabel=GetTTFLabel(getlocal("EarnRewardStr")..getlocal("fight_content_null"),27)
                end
                local lbPosY = G_VisibleSizeHeight*0.54-bgAddPosH+addWinPosY2+subWinPosY2*2
                isVictoryLabel:setAnchorPoint(ccp(0.5,1))
                isVictoryLabel:setPosition(ccp(G_VisibleSizeWidth*1.5,lbPosY))
                actionTb["isVictoryLabel"] ={{1,103},isVictoryLabel,nil,nil,ccp(G_VisibleSizeWidth*0.5,lbPosY),0.7,0.5,nil }
                self.bgLayer:addChild(isVictoryLabel,2)
                local isVictoryLbWidth = isVictoryLabel:getContentSize().width

                victoryBg:setPosition(ccp(G_VisibleSizeWidth*1.5,isVictoryLabel:getPositionY() - isVictoryLabel:getContentSize().height*0.6))                
                actionTb["victoryBg"] ={{1,103},victoryBg,nil,nil,ccp(G_VisibleSizeWidth*0.5+addPosH3,isVictoryLabel:getPositionY() - isVictoryLabel:getContentSize().height*0.6),0.7,0.5,nil }

                local pointLineAncP = {ccp(1,0.5),ccp(0,0.5)}
                local pointLinePosWscal = {G_VisibleSizeWidth*0.5-isVictoryLbWidth*0.5 - 10,G_VisibleSizeWidth*0.5+isVictoryLbWidth*0.5 + 10}
                for i=1,2 do
                    local pointLine = CCSprite:createWithSpriteFrameName(titleBgPL)
                    pointLine:setAnchorPoint(pointLineAncP[i])
                    pointLine:setPosition(ccp(pointLinePosWscal[i]+G_VisibleSizeWidth,isVictoryLabel:getPositionY() - isVictoryLabel:getContentSize().height*0.6))
                    self.bgLayer:addChild(pointLine,2)
                    actionTb["pointLine"..i] ={{1,103},pointLine,nil,nil,ccp(pointLinePosWscal[i],isVictoryLabel:getPositionY() - isVictoryLabel:getContentSize().height*0.6),0.7,0.5,nil}
                    if i ==1 then
                      pointLine:setFlipX(true)
                    end
                end
                
                -- print("isVictory---->>>>",isVictory,bgAddPosH)
                if newGuidMgr:isNewGuiding() == false then
                      local helperBg = CCSprite:createWithSpriteFrameName(titleBg)
                      helperBg:setAnchorPoint(ccp(0.5,1))
                      helperBg:setScaleX(diaWidth/helperBg:getContentSize().width)
                      local reverseScaleX = helperBg:getContentSize().width/diaWidth
                      local reverseScaleY = 1/needScale4
                      self.bgLayer:addChild(helperBg,2)

                      helperLb = GetTTFLabel(getlocal("battleDataStr"),28)
                      helperLb:setColor(G_ColorYellowPro)
                      helperLb:setAnchorPoint(ccp(0.5,1))
                      helperLb:setPosition(ccp(G_VisibleSizeWidth*1.5,G_VisibleSizeHeight*0.55+addPosH2+addWinPosY2))
                      actionTb["helperLb"] ={{1,103},helperLb,nil,nil,ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.55+addPosH2-5+addWinPosY2),0.2,0.5,nil }
                      self.bgLayer:addChild(helperLb,2)
                      local helperLbWidth = helperLb:getContentSize().width


                      helperBg:setPosition(ccp(G_VisibleSizeWidth*1.5,helperLb:getPositionY() - helperLb:getContentSize().height*0.6))
                      actionTb["helperBg"] ={{1,103},helperBg,nil,nil,ccp(G_VisibleSizeWidth*0.5+addPosH3,helperLb:getPositionY() - helperLb:getContentSize().height*0.6),0.3,0.5,nil }

                      local pointLineAncP2 = {ccp(1,0.5),ccp(0,0.5)}
                      local pointLinePosWscal2 = {G_VisibleSizeWidth*0.5-helperLbWidth*0.5 - 10,G_VisibleSizeWidth*0.5+helperLbWidth*0.5 + 10}
                      for i=1,2 do
                          local pointLine2 = CCSprite:createWithSpriteFrameName(titleBgPL)
                          pointLine2:setAnchorPoint(pointLineAncP2[i])
                          pointLine2:setPosition(ccp(pointLinePosWscal2[i]+G_VisibleSizeWidth,helperLb:getPositionY() - helperLb:getContentSize().height*0.6))
                          self.bgLayer:addChild(pointLine2,2)
                          actionTb["pointLine2"..i] ={{1,103},pointLine2,nil,nil,ccp(pointLinePosWscal2[i],helperLb:getPositionY() - helperLb:getContentSize().height*0.6),0.2,0.5,nil }
                          if i ==1 then
                            pointLine2:setFlipX(true)
                          end
                      end

                    local function noData( )  end
                    local damageBg = LuaCCScale9Sprite:createWithSpriteFrameName(lbBg,CCRect(32,16,1,1),noData)
                    damageBg:setAnchorPoint(ccp(0,0.5))
                    self.bgLayer:addChild(damageBg,2)

                    local damageLb = GetTTFLabelWrap(getlocal("damageStr",{self.damage}),22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    damageLb:setAnchorPoint(ccp(0,0.5))
                    local damageLbPos = upPosY + G_VisibleSizeHeight*0.55+addPosH2-65+addWinPosY3
                    damageLb:setPosition(ccp(strMovPosX+G_VisibleSizeWidth,damageLbPos))
                    actionTb["damageLb"] ={{1,103},damageLb,nil,nil,ccp(strMovPosX,damageLbPos),0.4,0.5,nil }
                    self.bgLayer:addChild(damageLb,2)

                    damageBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,damageLb:getContentSize().height+10))
                    damageBg:setPosition(ccp(strMovPosX+G_VisibleSizeWidth-50,damageLb:getPositionY()))
                    actionTb["damageBg"] ={{1,103},damageBg,nil,nil,ccp(strMovPosX-50,damageLb:getPositionY()),0.4,0.5,nil }

                    if newGuidMgr:isNewGuiding() then

                    end

                    if self.parent.battleType == 5 or self.parent.isFuben == false then

                              local repairBg = LuaCCScale9Sprite:createWithSpriteFrameName(lbBg,CCRect(32,16,1,1),noData)
                              repairBg:setAnchorPoint(ccp(0,0.5))
                              self.bgLayer:addChild(repairBg,2)

                              local isArena = (self.parent and self.parent.battleType == 5) and true or false
                              local rankingUpNum = 0
                              if isArena and arenaVoApi then
                                  rankingUpNum = arenaVoApi:getArenaVo().oldRanking - arenaVoApi:getArenaVo().ranking
                                  arenaVoApi:setOldRanking(arenaVoApi:getArenaVo().ranking)
                                  -- print("rankingUpNum11111------>",rankingUpNum)
                              end

                              local repairPosH =upPosY*2.5 + G_VisibleSizeHeight*0.55+addPosH2-115+addWinPosY3
                              local loseRate = getlocal("damageRateStr")..self.losePercent

                              if tonumber(self.losePercent) == nil then
                                    if self.parent.battleType == 7 or self.parent.battleType == 2 or self.parent.battleType == 3 or self.parent.battleType == 8 then
                                        loseRate = loseRate..getlocal("damageRateStr3")
                                    else
                                        loseRate = loseRate..getlocal("damageRateStr2")
                                    end
                              else
                                    loseRate = loseRate.."%"
                              end
                              local repairStr = isArena and getlocal("ascendingRankStr",{rankingUpNum}) or loseRate
                              local repairLb=GetTTFLabelWrap(repairStr,22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                              repairLb:setAnchorPoint(ccp(0,0.5))
                              repairLb:setPosition(ccp(strMovPosX+G_VisibleSizeWidth,repairPosH))
                              actionTb["repairLb"] ={{1,103},repairLb,nil,nil,ccp(strMovPosX,repairPosH),0.5,0.5,nil }
                              self.bgLayer:addChild(repairLb,2)
                              
                              repairBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,repairLb:getContentSize().height+10))
                              repairBg:setPosition(ccp(strMovPosX+G_VisibleSizeWidth-50,repairLb:getPositionY()))
                              actionTb["repairBg"] ={{1,103},repairBg,nil,nil,ccp(strMovPosX-50,repairLb:getPositionY()),0.5,0.5,nil }

                              if isArena == false and tonumber(self.losePercent) == nil and (self.parent.battleType ~= 7 and self.parent.battleType ~= 2 and self.parent.battleType ~= 3 and self.parent.battleType ~= 8) then
                                  local repairItem = GetButtonItem("vipArrow.png","vipArrow.png","vipArrow.png",operateHandler,5,nil)
                                  repairItem:setScale(needScale3)
                                  repairItem:setAnchorPoint(ccp(1,0.5))
                                  local repairItemMenu = CCMenu:createWithItem(repairItem)
                                  repairItemMenu:setTouchPriority(-(layerNum-1)*20-4)
                                  repairItemMenu:setPosition(ccp(size.width-20+G_VisibleSizeWidth,repairPosH))
                                  actionTb["repairItemMenu"] ={{1,103},repairItemMenu,nil,nil,ccp(size.width-20,repairPosH),0.5,0.5,nil }
                                  self.bgLayer:addChild(repairItemMenu,2)
                              end
                        -- end

                        if upgradeTanks and SizeOfTable(upgradeTanks)>0 then--精英坦克
                            local upgradeNum = 0
                            for k,v in pairs(upgradeTanks) do
                              upgradeNum=upgradeNum+v
                            end

                            local chakanPosH = G_VisibleSizeHeight*0.55+addPosH2-165

                            local function noData( )  end
                            local chakanBg = LuaCCScale9Sprite:createWithSpriteFrameName(lbBg,CCRect(32,16,1,1),noData)
                            chakanBg:setAnchorPoint(ccp(0,0.5))
                            self.bgLayer:addChild(chakanBg,2)

                            local chakanLb=GetTTFLabelWrap(getlocal("battleResultTankUpgrade",{upgradeNum}),22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                            chakanLb:setAnchorPoint(ccp(0,0.5))
                            chakanLb:setPosition(ccp(strMovPosX+G_VisibleSizeWidth,chakanPosH+addWinPosY3))
                            actionTb["chakanLb"] ={{1,103},chakanLb,nil,nil,ccp(strMovPosX,chakanPosH+addWinPosY3),0.6,0.5,nil }
                            self.bgLayer:addChild(chakanLb,2)

                            chakanBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,chakanLb:getContentSize().height+10))
                            chakanBg:setPosition(ccp(strMovPosX+G_VisibleSizeWidth-50,chakanLb:getPositionY()))
                            actionTb["chakanBg"] ={{1,103},chakanBg,nil,nil,ccp(strMovPosX-50,chakanLb:getPositionY()),0.6,0.5,nil }

                            local function checkUpgrade()
                                tankVoApi:showTankUpgrade(layerNum,upgradeTanks,callBack)
                                if award then
                                    local tipReward=playerVoApi:getTrueReward(award)
                                    G_showRewardTip(tipReward,true,nil)
                                end
                                self:closeNewBattleResult()
                            end

                            local chakanItem = GetButtonItem("vipArrow.png","vipArrow.png","vipArrow.png",checkUpgrade,nil,nil)
                            chakanItem:setAnchorPoint(ccp(1,0.5))
                            chakanItem:setScale(needScale3)
                            local chakanItemMenu = CCMenu:createWithItem(chakanItem)
                            chakanItemMenu:setTouchPriority(-(layerNum-1)*20-4)
                            chakanItemMenu:setPosition(ccp(size.width-20+G_VisibleSizeWidth,chakanPosH+addWinPosY3))
                            actionTb["chakanItemMenu"] ={{1,103},chakanItemMenu,nil,nil,ccp(size.width-20,chakanPosH+addWinPosY3),0.6,0.5,nil }
                            self.bgLayer:addChild(chakanItemMenu,2)

                        end
                    end
                end
                if isVictory then    --胜利显示的图片（上部分的）
                    local victorySp =nil
                    if PlatformManage~=nil then
                        if G_getCurChoseLanguage()~="cn" and platCfg.platCfgShowWinOrLose[G_curPlatName()]~=nil then
                            victorySp = CCSprite:createWithSpriteFrameName("SuccessShape.png")
                            victorySp:setAnchorPoint(ccp(0.5,0))
                            victorySp:setScale(1.5)
                            self.bgLayer:addChild(victorySp,5)
                            victorySp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*1.05))
                            actionTb["victorySp"] ={{1,101},victorySp,nil,nil,ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.91),nil,0.5,nil }
                        end
                    end

                    local starsNum = isAcBanzhangshilian ==true and 3 or resultStar
                    self:runWinAniTank(starsNum)
                else             --失败显示的图片（上部分的）
                    if PlatformManage~=nil then
                        if G_getCurChoseLanguage()~="cn" and platCfg.platCfgShowWinOrLose[G_curPlatName()]~=nil then
                            local loseSp = CCSprite:createWithSpriteFrameName("LoseShape.png")
                            loseSp:setAnchorPoint(ccp(0.5,0))
                            loseSp:setScale(1.5)
                            self.bgLayer:addChild(loseSp)
                            loseSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*1.05))
                            actionTb["loseSp"] ={{1,101},loseSp,nil,nil,ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.91),nil,0.5,nil }
                        end
                    end
                    local starsNum2 = resultStar and resultStar or nil
                    self:runLoseAniTank(starsNum)
                end

                local addPosH = 0
                if awardNum <5 then
                    addPosH =25
                end
                if isShowRepair ~=true then
                  addPosH = addPosH + 10
                end
                if upgradeTanks == nil or SizeOfTable(upgradeTanks)==0 then
                  addPosH = addPosH + 10
                end
                if addPosH ==0 and isShowRepair ~=true and (upgradeTanks == nil or SizeOfTable(upgradeTanks)==0)then
                    addPosH =30
                end
                if actionTb["closeBtn"] then
                    actionTb["closeBtn"][5].y =addPosH
                end
                if actionTb["playBackBtn"] then
                    actionTb["playBackBtn"][5].y = addPosH
                end
                if actionTb["levelAgainMenu"] then
                    actionTb["levelAgainMenu"][5].y =addPosH
                end
                if actionTb["feedBtn"] then
                    actionTb["feedBtn"][5].y =addPosH
                    -- actionTb["feedDescLable"][2]:setPositionY(addPosH +90)
                    if actionTb["feedDescLable"] then
                        actionTb["feedDescLable"][5].y = addPosH +90
                    end
                end
        else--失败显示

              local capInSetNew   = CCRect(20, 20, 10, 10)
              local function noData( )  end

              local showCondition=false
              if winCondition and SizeOfTable(winCondition)>0 then
                  for k,v in pairs(winCondition) do
                      if v and v==0 then
                          showCondition=true
                      end
                  end
              end
              if showCondition==true and swId then
                  bgHeight=bgHeight+350
                  local conditionStr=superWeaponVoApi:getClearConditionStr(swId)..getlocal("super_weapon_challenge_not_reach")
                  local promotionStr=getlocal("super_weapon_challenge_promotion_condition",{conditionStr})
                  local promotionLb=GetTTFLabelWrap(promotionStr,25,CCSize(size.width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                  promotionLb:setPosition(ccp(size.width/2,200))
                  self.bgLayer:addChild(promotionLb,2)
              elseif isAcBanzhangshilian==true then

              else
                  -------------------上-----------------------------------------------------------------------------------------------------------------------------------
                  local addPosH2, addPosH3,loseScalePosY,loseScalePosY2 = 50 ,10 ,0.62 ,0.5
                  local helperBg = CCSprite:createWithSpriteFrameName("semicircleRed.png")
                  helperBg:setAnchorPoint(ccp(0.5,1))
                  helperBg:setScaleX(diaWidth/helperBg:getContentSize().width)
                  self.bgLayer:addChild(helperBg,2)

                  helperLb = GetTTFLabel(getlocal("battleDataStr"),28)
                  helperLb:setColor(G_ColorYellowPro)
                  helperLb:setAnchorPoint(ccp(0.5,1))
                  local helperLbPosY = addLosPosY4 + G_VisibleSizeHeight*loseScalePosY+addPosH2
                  helperLb:setPosition(ccp(G_VisibleSizeWidth*1.5,helperLbPosY))
                  actionTb["helperLb"] ={{1,103},helperLb,nil,nil,ccp(G_VisibleSizeWidth*0.5,helperLbPosY - 5),0.2,0.5,nil }
                  self.bgLayer:addChild(helperLb,2)
                  local helperLbWidth = helperLb:getContentSize().width

                  helperBg:setPosition(ccp(G_VisibleSizeWidth*1.5,helperLb:getPositionY() - helperLb:getContentSize().height*0.6))
                  actionTb["helperBg"] ={{1,103},helperBg,nil,nil,ccp(G_VisibleSizeWidth*0.5+addPosH3,helperLb:getPositionY() - helperLb:getContentSize().height*0.6),0.3,0.5,nil }

                  local pointLineAncP2 = {ccp(1,0.5),ccp(0,0.5)}
                  local pointLinePosWscal2 = {G_VisibleSizeWidth*0.5-helperLbWidth*0.5 - 10,G_VisibleSizeWidth*0.5+helperLbWidth*0.5 + 10}
                  for i=1,2 do
                      local pointLine2 = CCSprite:createWithSpriteFrameName("redPointAndLine.png")
                      pointLine2:setAnchorPoint(pointLineAncP2[i])
                      pointLine2:setPosition(ccp(pointLinePosWscal2[i]+G_VisibleSizeWidth,helperLb:getPositionY() - helperLb:getContentSize().height*0.6))
                      self.bgLayer:addChild(pointLine2,2)
                      actionTb["pointLine2"..i] ={{1,103},pointLine2,nil,nil,ccp(pointLinePosWscal2[i],helperLb:getPositionY() - helperLb:getContentSize().height*0.6),0.2,0.5,nil }
                      if i ==1 then
                        pointLine2:setFlipX(true)
                      end
                  end

                  local function noData( )  end
                  local damageBg = LuaCCScale9Sprite:createWithSpriteFrameName("lightRedBg.png",CCRect(32,16,1,1),noData)
                  damageBg:setAnchorPoint(ccp(0,0.5))
                  self.bgLayer:addChild(damageBg,2)

                  local damageLb = GetTTFLabelWrap(getlocal("damageStr",{self.damage}),22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                  damageLb:setAnchorPoint(ccp(0,0.5))
                  local damageLbPosY = G_VisibleSizeHeight*loseScalePosY+addPosH2-70 + subLosPosY3
                  damageLb:setPosition(ccp(strMovPosX+G_VisibleSizeWidth,damageLbPosY))
                  actionTb["damageLb"] ={{1,103},damageLb,nil,nil,ccp(strMovPosX,damageLbPosY),0.4,0.5,nil }
                  self.bgLayer:addChild(damageLb,2)

                  damageBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,damageLb:getContentSize().height+10))
                  damageBg:setPosition(ccp(strMovPosX+G_VisibleSizeWidth-50,damageLb:getPositionY()))
                  actionTb["damageBg"] ={{1,103},damageBg,nil,nil,ccp(strMovPosX-50,damageLb:getPositionY()),0.4,0.5,nil }

                  if self.parent.battleType == 5 or self.parent.isFuben == false then

                          local repairBg = LuaCCScale9Sprite:createWithSpriteFrameName("lightRedBg.png",CCRect(32,16,1,1),noData)
                          repairBg:setAnchorPoint(ccp(0,0.5))
                          self.bgLayer:addChild(repairBg,2)

                          local isArena = (self.parent and self.parent.battleType == 5) and true or false
                          local rankingUpNum = 0
                          if isArena and arenaVoApi then
                              rankingUpNum = arenaVoApi:getArenaVo().oldRanking - arenaVoApi:getArenaVo().ranking
                              arenaVoApi:setOldRanking(arenaVoApi:getArenaVo().ranking)
                              -- print("rankingUpNum11111------>",rankingUpNum)
                          end

                          local repairPosH = G_VisibleSizeHeight*loseScalePosY+addPosH2-120 + subLosPosY4
                          local loseRate = getlocal("damageRateStr")..self.losePercent
                          if tonumber(self.losePercent) == nil  then
                                if self.parent.battleType == 7 or self.parent.battleType == 2 or self.parent.battleType == 3 or self.parent.battleType == 8 then
                                    loseRate = loseRate..getlocal("damageRateStr3")
                                else
                                    loseRate = loseRate..getlocal("damageRateStr2")
                                end
                          else
                                    loseRate = loseRate.."%"
                          end
                          local repairStr = isArena and getlocal("ascendingRankStr",{rankingUpNum}) or loseRate
                          local repairLb=GetTTFLabelWrap(repairStr,22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                          repairLb:setAnchorPoint(ccp(0,0.5))
                          repairLb:setPosition(ccp(strMovPosX+G_VisibleSizeWidth,repairPosH))
                          actionTb["repairLb"] ={{1,103},repairLb,nil,nil,ccp(strMovPosX,repairPosH),0.5,0.5,nil }
                          self.bgLayer:addChild(repairLb,2)
                          
                          repairBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,repairLb:getContentSize().height+10))
                          repairBg:setPosition(ccp(strMovPosX+G_VisibleSizeWidth-50,repairLb:getPositionY()))
                          actionTb["repairBg"] ={{1,103},repairBg,nil,nil,ccp(strMovPosX-50,repairLb:getPositionY()),0.5,0.5,nil }

                          if isArena == false and tonumber(self.losePercent) == nil and (self.parent.battleType ~= 7 and self.parent.battleType ~= 2 and self.parent.battleType ~= 3 and self.parent.battleType ~= 8) then
                              local repairItem = GetButtonItem("redArrow.png","redArrow.png","redArrow.png",operateHandler,5,nil)
                              repairItem:setScale(needScale3)
                              repairItem:setAnchorPoint(ccp(1,0.5))
                              local repairItemMenu = CCMenu:createWithItem(repairItem)
                              repairItemMenu:setTouchPriority(-(layerNum-1)*20-4)
                              repairItemMenu:setPosition(ccp(size.width-20+G_VisibleSizeWidth,repairPosH))
                              actionTb["repairItemMenu"] ={{1,103},repairItemMenu,nil,nil,ccp(size.width-20,repairPosH),0.5,0.5,nil }
                              self.bgLayer:addChild(repairItemMenu,2)
                          end
                  end
                  ------------------------------------------------------------------------------------------------------------------------------------------------------
                  local youCanBgPosH = G_VisibleSizeHeight*loseScalePosY2 --losePicBg:getPositionY() - losePicBg:getContentSize().height -20
                  local youCanBg = CCSprite:createWithSpriteFrameName("semicircleRed.png")--yellowDarkSmallStrip
                  youCanBg:setAnchorPoint(ccp(0.5,1))
                  youCanBg:setScaleX(diaWidth/youCanBg:getContentSize().width)
                  local reverseScaleX = youCanBg:getContentSize().width/diaWidth
                  youCanBg:setPosition(ccp(G_VisibleSizeWidth*1.5,youCanBgPosH))
                  self.bgLayer:addChild(youCanBg,2)
                  actionTb["youCanBg"] ={{1,103},youCanBg,nil,nil,ccp(G_VisibleSizeWidth*0.5,youCanBgPosH),0.6,0.5,nil }

                  local youCanLb = GetTTFLabel(getlocal("youCan"),28)
                  youCanLb:setColor(G_ColorYellowPro)
                  youCanLb:setScaleX(reverseScaleX)
                  youCanLb:setPosition(youCanBg:getContentSize().width*0.5,youCanBg:getContentSize().height*0.9)
                  youCanBg:addChild(youCanLb)

                  local pointLineAncP3 = {ccp(1,0.5),ccp(0,0.5)}
                  local pointLinePosWscal3 = {0.34,0.66}
                  for i=1,2 do
                      local pointLine = CCSprite:createWithSpriteFrameName("redPointAndLine.png")--PointLineYellow
                      pointLine:setAnchorPoint(pointLineAncP3[i])
                      pointLine:setPosition(ccp(G_VisibleSizeWidth*(1+pointLinePosWscal3[i]),youCanBgPosH-youCanBg:getContentSize().height*0.5+10))
                      self.bgLayer:addChild(pointLine,2)
                      actionTb["pointLine"..i] ={{1,103},pointLine,nil,nil,ccp(G_VisibleSizeWidth*pointLinePosWscal3[i],youCanBgPosH-youCanBg:getContentSize().height*0.5+10),0.6,0.5,nil }
                      if i ==1 then
                        pointLine:setFlipX(true)
                      end
                  end

                  local upgradePathStr = GetTTFLabelWrap(getlocal("upgradePathStr"),22,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                  upgradePathStr:setColor(G_ColorOrange2)
                  upgradePathStr:setAnchorPoint(ccp(0.5,1))
                  upgradePathStr:setPosition(G_VisibleSizeWidth*1.5,youCanBg:getPositionY() - youCanBg:getContentSize().height-15)
                  self.bgLayer:addChild(upgradePathStr,2)
                  actionTb["upgradePathStr"] ={{1,103},upgradePathStr,nil,nil,ccp(G_VisibleSizeWidth*0.5,youCanBg:getPositionY() - youCanBg:getContentSize().height-15),0.6,0.5,nil }

                    local function showDetailPanel(tag,object)
                        print("here???/ in showDetailPanel~~~~~~~~~~~")
                        if G_checkClickEnable()==false then
                            do return end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
                        end
                        self.playBackBtn:setEnabled(false)
                        local function battleEndCall( )
                            self:showSmallDialog(self.guidTb[tag])    
                        end 
                        playerVoApi:showPowerGuideDialog(nil,nil,nil,true,battleEndCall)
                    end
                    self.guidTb = powerGuideVoApi:getClassTb()
                    self.cellNum = SizeOfTable(self.guidTb)
                    local classIndex = 0
                    -- local singW = (G_VisibleSizeWidth-50)/3
                    local cellH = upgradePathStr:getPositionY()-120
                    local theX
                    for idx =0,1 do
                        for i=1,4 do
                            classIndex = idx * 4 + i
                            local cellH2 = cellH - idx*140
                            if classIndex <= self.cellNum then
                                local classData = powerGuideVoApi:getClassContentData(self.guidTb[classIndex],false)
                                if classData then
                                    theX = G_VisibleSizeWidth*0.22*i-30--singW * i - singW * 0.5
                                    local selectN = CCSprite:createWithSpriteFrameName("diamondBtnBorder.png")
                                    local selectS = CCSprite:createWithSpriteFrameName("diamondBtnBorder.png")
                                    local selectD = GraySprite:createWithSpriteFrameName("diamondBtnBorder.png")

                                    local classIconN = CCSprite:createWithSpriteFrameName("powerGuide_icon"..classIndex.."_0.png")--classData[2]
                                    classIconN:setAnchorPoint(ccp(0.5,0.5))
                                    classIconN:setPosition(ccp(selectN:getContentSize().width/2,selectN:getContentSize().height/2))
                                    selectN:addChild(classIconN,2)

                                    local classIconS = CCSprite:createWithSpriteFrameName("powerGuide_icon"..classIndex.."_1.png")--classData[2]
                                    classIconS:setAnchorPoint(ccp(0.5,0.5))
                                    classIconS:setPosition(ccp(selectS:getContentSize().width/2,selectS:getContentSize().height/2))
                                    selectS:addChild(classIconS,2)

                                    classIconN:setScale(0.8)
                                    classIconS:setScale(0.8)

                                    local itemBg = CCMenuItemSprite:create(selectN,selectS,selectD)
                                    itemBg:setAnchorPoint(ccp(0.5,0.5))
                                    itemBg:registerScriptTapHandler(showDetailPanel)
                                    itemBg:setTag(classIndex)
                                    
                                    itemBg:setScale(0.6)
                                    itemBg:setVisible(false)
                                    self.itemTb[classIndex] = itemBg

                                    local itemMenu=CCMenu:createWithItem(itemBg)
                                    
                                    itemMenu:setTouchPriority(-(layerNum-1)*20-2)
                                    itemMenu:setPosition(ccp(theX,cellH2))
                                    self.bgLayer:addChild(itemMenu,1)

                                    local testLb,strWidth2,lbPos = GetTTFLabel(classData[1],24),24,18
                                    if testLb:getContentSize().width > 140 then
                                        strWidth2 = 21
                                        lbPos = 24
                                    end

                                    local titleLb=GetTTFLabelWrap(classData[1],strWidth2,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                                    titleLb:setAnchorPoint(ccp(0.5,0.5))
                                    titleLb:setPosition(ccp(itemBg:getContentSize().width/2,0 - lbPos))
                                    itemBg:addChild(titleLb)

                                    local sbIndex=self.guidTb[classIndex]
                                    local playerLv=playerVoApi:getPlayerLevel()
                                    local function sbFunc(sblevel)
                                        itemBg:setEnabled(false)
                                        itemBg:setVisible(false)
                                        titleLb:setVisible(false)
                                        self.itemTb[classIndex] = nil
                                    end
                                    local flag=false
                                    local lockLevel=0
                                    if sbIndex==powerGuideVoApi.CLASS_armor then
                                        local limitLv = armorMatrixVoApi:getPermitLevel()
                                        if playerLv<limitLv then
                                            flag=true
                                            lockLevel=limitLv
                                        end
                                    elseif sbIndex==powerGuideVoApi.CLASS_accessory then
                                        if playerLv<8 then
                                            flag=true
                                            lockLevel=8
                                        end
                                    elseif sbIndex==powerGuideVoApi.CLASS_hero then
                                        if playerLv<20 then
                                            flag=true
                                            lockLevel=20
                                        end
                                    elseif sbIndex==powerGuideVoApi.CLASS_alienweapon then
                                        local superWeaponOpenLv=base.superWeaponOpenLv or 25
                                        if playerLv<superWeaponOpenLv then
                                            flag=true
                                            lockLevel=superWeaponOpenLv
                                        end
                                    elseif sbIndex==powerGuideVoApi.CLASS_alientech then
                                        if playerLv<alienTechCfg.openlevel then
                                            flag=true
                                            lockLevel=alienTechCfg.openlevel
                                        end
                                    elseif sbIndex==powerGuideVoApi.CLASS_superequip then
                                        local permitLevel = emblemVoApi:getPermitLevel()
                                        if playerLv<permitLevel then
                                            flag=true
                                            lockLevel=permitLevel
                                        end
                                    elseif sbIndex==powerGuideVoApi.CLASS_plane then
                                        local permitLevel = planeVoApi:getOpenLevel()
                                        if playerLv<permitLevel then
                                            flag=true
                                            lockLevel=permitLevel
                                        end
                                    end
                                    if flag then
                                        sbFunc(lockLevel)
                                    end
                                end
                            end
                        end
                    end
              end
                                
              if PlatformManage~=nil then
                  if G_getCurChoseLanguage()~="cn" and platCfg.platCfgShowWinOrLose[G_curPlatName()]~=nil then
                      local loseSp = CCSprite:createWithSpriteFrameName("LoseShape.png")
                      loseSp:setAnchorPoint(ccp(0.5,0))
                      loseSp:setScale(1.5)
                      self.bgLayer:addChild(loseSp)
                      loseSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*1.05))
                      actionTb["loseSp"] ={{1,101},loseSp,nil,nil,ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.91),nil,0.5,nil }
                  end
              end
              local function ShareStars( ) end

              self:runLoseAniTank()
        end          

        if self.isUseAmi then
              self:show()
        end
    end

    G_RunActionCombo(actionTb)
    self:runLoseAniInDown()
    local function touchLuaSpr() end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(touchDialogBg,1);
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    return self.dialogLayer
end
function smallDialog:showSmallDialog(classIndex)
    
    if powerGuideVoApi then
        local function gotoFun(class,index)
            self:redirect(class,index)
        end
        -- print("self.layerNum+1 ========>",self.layerNum+1)
        local function closeFun(  )
            self.playBackBtn:setEnabled(true)
        end 
        powerGuideVoApi:showDetailPanel(classIndex,gotoFun,self.layerNum+1,closeFun)
    end
end
function smallDialog:redirect(classIndex,idx)
    if self.parent then
        self.parent:close()
    end
    local layerNum = self.layerNum
    if classIndex == powerGuideVoApi.CLASS_player then--角色
        self:closeNewBattleResult()
        activityAndNoteDialog:closeAllDialog()
        if(idx==1)then--统率等级
           local td=playerVoApi:showPlayerDialog(1,layerNum)
        elseif(idx==2)then--技能等级
            local td=playerVoApi:showPlayerDialog(2,layerNum)
            td:tabClick(1)
        elseif(idx==3)then--科技等级
            local buildVo=buildingVoApi:getBuildiingVoByBId(3)
            require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
            local td=techCenterDialog:new(3,layerNum,true)
            local bName=getlocal(buildingCfg[8].buildName)
            local tbArr={getlocal("building"),getlocal("startResearch")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,layerNum)
            sceneGame:addChild(dialog,layerNum)
            td:tabClick(1)
        elseif(idx==4)then--军团科技等级
            require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSkillDialog"
            local td=allianceSkillDialog:new(layerNum)
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_technology"),true,layerNum)
            sceneGame:addChild(dialog,layerNum)
        elseif(idx==5)then--兵种强度
            local buildVo=buildingVoApi:getBuildiingVoByBId(11)
            require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
            local td=tankFactoryDialog:new(11,layerNum)
            local bName=getlocal(buildingCfg[6].buildName)
            local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,layerNum)
            td:tabClick(1)
            sceneGame:addChild(dialog,layerNum)
        elseif(idx==6)then--出战部队满编
            local buildVo=buildingVoApi:getBuildiingVoByBId(11)
            require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
            local td=tankFactoryDialog:new(11,layerNum)
            local bName=getlocal(buildingCfg[6].buildName)
            local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,layerNum)
            td:tabClick(1)
            sceneGame:addChild(dialog,layerNum)
        elseif(idx==7)then--个人繁荣度
            local td=playerVoApi:showPlayerDialog(3,layerNum)
            td:tabClick(2)
        end
    elseif classIndex == powerGuideVoApi.CLASS_armor then--海兵方阵(海兵方阵品质/海兵方阵强化等级)
        self:closeNewBattleResult()
        G_goToDialog2("armor",4,true)
    elseif classIndex == powerGuideVoApi.CLASS_accessory then--配件
        self:closeNewBattleResult()
        activityAndNoteDialog:closeAllDialog()
        if(idx==1 or idx==3 or idx==4 or idx==5 )then--已装配件品质
            accessoryVoApi:showAccessoryDialog(sceneGame,layerNum)
        elseif(idx==2)then--配件强化等级
            local canUpgrade=powerGuideVoApi:checkCanUpgrade()
            if(canUpgrade==2)then
                local td=shopVoApi:showPropDialog(layerNum,true,1)
                --td:tabClick(1,false)
            elseif(canUpgrade==0)then
                accessoryVoApi:showAccessoryDialog(sceneGame,layerNum)
            end
        end
    elseif classIndex == powerGuideVoApi.CLASS_hero then--将领
        

        if(idx==4)then--将领装备强度
            self:closeNewBattleResult()
            G_goToDialog("hu",4,true)
        else--将领品质/将领等级/将领技能等级
            self:closeNewBattleResult()
            G_goToDialog2("heroM",4,true)
        end
    elseif classIndex == powerGuideVoApi.CLASS_alienweapon then-- 超级武器
        self:closeNewBattleResult()
        -- activityAndNoteDialog:closeAllDialog()
        -- print("- 超级武器- 超级武器- 超级武器- 超级武器- 超级武器- 超级武器",idx)
        if idx==1 or idx==2 then
            G_goToDialog2("superWeapon",4,true)
        else
            G_goToDialog2("crystal",4,true)
        end
    elseif classIndex == powerGuideVoApi.CLASS_alientech then--异星科技
        self:closeNewBattleResult()
        activityAndNoteDialog:closeAllDialog()
        G_goToDialog2("alien",4,true)
    elseif classIndex == powerGuideVoApi.CLASS_superequip then--超级装备
        self:closeNewBattleResult()
        activityAndNoteDialog:closeAllDialog()
        emblemVoApi:showMainDialog(4)
    elseif classIndex == powerGuideVoApi.CLASS_plane then--超级装备
        self:closeNewBattleResult()
        activityAndNoteDialog:closeAllDialog()
        if idx==1 then
            planeVoApi:showMainDialog(4,1)
        else
            PlayEffect(audioCfg.mouseClick)
            planeVoApi:showMainDialog(4)
        end
    end
end

function smallDialog:runWinAniTank( starsNum,isVictory )
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    local sunSp = {}
    local tankPic = CCSprite:createWithSpriteFrameName("win_r_tank.png")
    tankPic:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.83))
    tankPic:setOpacity(0)
    tankPic:setScale(3)
    self.shakeLayer:addChild(tankPic,4)

    local delayAc =CCDelayTime:create(0.3)
    local delayAc5 =CCDelayTime:create(0.4)
    local fadeIn1 = CCFadeIn:create(0)
    local ScaleAction4 = CCScaleTo:create(0.1,0.8)
    local ScaleAction5 = CCScaleTo:create(0.08,1.1)
    local ScaleAction6 = CCScaleTo:create(0.08,1)

    local function roteCall( )
        if sunSp[1] then
            sunSp[1]:setVisible(true)
        end
        if sunSp[2] then
            sunSp[2]:setVisible(true)
        end
        if starsNum then
            self:showStarAni(starsNum,tankPic)
        end
    end
    -- local function readyShake( )
    --     self:shakingNow()
    -- end 
    -- local shakeCall = CCCallFunc:create(readyShake)
    local ccCall = CCCallFunc:create(roteCall)
    local acArr2=CCArray:create()
    acArr2:addObject(delayAc)
    acArr2:addObject(fadeIn1)
    acArr2:addObject(ScaleAction4)
    acArr2:addObject(ScaleAction5)
    acArr2:addObject(ScaleAction6)
    -- acArr2:addObject(shakeCall)
    acArr2:addObject(delayAc5)
    
    acArr2:addObject(ccCall)
    local seq1=CCSequence:create(acArr2)
    tankPic:runAction(seq1)

    for i=1,2 do
      local realLight = CCSprite:createWithSpriteFrameName("win_r_sun"..i..".png")
      realLight:setPosition(ccp(tankPic:getPositionX(),tankPic:getPositionY()))
      self.shakeLayer:addChild(realLight,2)  
      realLight:setVisible(false)
      sunSp[i] = realLight
      
      local roteSize = i ==1 and 360 or -360
      local rotate1=CCRotateBy:create(10, roteSize)
      local repeatForever = CCRepeatForever:create(rotate1)
      realLight:runAction(repeatForever)
    end

              local tankBg = CCSprite:createWithSpriteFrameName("win_r_1.png")
              tankBg:setPosition(ccp(tankPic:getPositionX(),tankPic:getPositionY()-50))
              tankBg:setOpacity(0)
              tankBg:setScale(2)
              self.shakeLayer:addChild(tankBg,3)

              local delayAc2 =CCDelayTime:create(0.8)
              local fadeIn2 = CCFadeIn:create(0)
              local pzArr=CCArray:create()
              for kk=1,22 do
                  local nameStr="win_r_"..kk..".png"
                  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                  -- frame:setScale(1.5)
                  pzArr:addObject(frame)
              end
              local animation=CCAnimation:createWithSpriteFrames(pzArr)
              animation:setDelayPerUnit(0.06)
              local animate=CCAnimate:create(animation)  

              local acArr3=CCArray:create() 
              acArr3:addObject(delayAc2)
              acArr3:addObject(fadeIn2)
              acArr3:addObject(animate)
              local seq2=CCSequence:create(acArr3)
              tankBg:runAction(seq2)


    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function smallDialog:runLoseAniTank( starsNum)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local addposY = starsNum and 50 or 0
    local tankBg = CCSprite:createWithSpriteFrameName("loseR_3.png")
    local lastPosY = G_VisibleSizeHeight*0.86+addposY
    tankBg:setPosition(ccp(G_VisibleSizeWidth*0.5,lastPosY))
    tankBg:setVisible(false)
    self.bgLayer:addChild(tankBg,5)

    local loseAniPic2 = CCSprite:createWithSpriteFrameName("loseR_1.png")--翅膀
    loseAniPic2:setPosition(ccp(G_VisibleSizeWidth*0.5,lastPosY+300))
    loseAniPic2:setScale(5)
    loseAniPic2:setOpacity(0)
    self.bgLayer:addChild(loseAniPic2,4)

    local loseAniPic1 = CCSprite:createWithSpriteFrameName("loseR_2.png")--坦克
    loseAniPic1:setPosition(ccp(G_VisibleSizeWidth*0.5,lastPosY+300))
    self.bgLayer:addChild(loseAniPic1,4)

    local delayAc1 = CCDelayTime:create(0.3)
    local fadeIn1 = CCFadeIn:create(0.25)
    local movTo1 = CCMoveTo:create(0.25,ccp(G_VisibleSizeWidth*0.5,lastPosY))
    local scal1 = CCScaleTo:create(0.25,1)
    local arr1 = CCArray:create()
    arr1:addObject(fadeIn1)
    arr1:addObject(movTo1)
    arr1:addObject(scal1)
    local spawn1 = CCSpawn:create(arr1)
    local seq1 = CCSequence:createWithTwoActions(delayAc1,spawn1)
    loseAniPic2:runAction(seq1)

    local delayAc2 = CCDelayTime:create(0.5)
    local movTo2 = CCMoveTo:create(0.25,ccp(G_VisibleSizeWidth*0.5,lastPosY))
    local rotate1 = CCRotateTo:create(0.1, 10)
    local rotate2 = CCRotateTo:create(0.1, -10)
    local rotate3 = CCRotateTo:create(0.05, 5)
    local rotate4 = CCRotateTo:create(0.05, -5)
    local rotate5 = CCRotateTo:create(0.05, 0)
    local function roteCall( )
        tankBg:setVisible(true)
        loseAniPic1:setVisible(false)
        loseAniPic2:setVisible(false)
        if starsNum then
            self:showStarAni(starsNum,tankBg)
        end
    end
    local ccCall = CCCallFunc:create(roteCall)
    local arr2 = CCArray:create()
    arr2:addObject(delayAc2)
    arr2:addObject(movTo2)
    arr2:addObject(rotate1)
    arr2:addObject(rotate2)
    arr2:addObject(rotate3)
    arr2:addObject(rotate4)
    arr2:addObject(rotate5)
    arr2:addObject(ccCall)
    local seq2 = CCSequence:create(arr2)
    loseAniPic1:runAction(seq2)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

-----星星动画（胜利和失败都会使用）
function smallDialog:showStarAni( starsNum,tankPic )
    local addPosXTb = {-110,0,110}
    local addPosYTb = {30,0,30}
    -- print("starsNum----->",starsNum)
    if starsNum and starsNum > 0 then
        for i=1,3 do
            local starsSp = CCSprite:createWithSpriteFrameName("stars_n2.png")
            starsSp:setOpacity(0)
            starsSp:setPosition(ccp(tankPic:getPositionX()+addPosXTb[i],tankPic:getPositionY()-140+addPosYTb[i]))
            self.shakeLayer:addChild(starsSp,4)

            local delayAc = CCDelayTime:create(0.2)
            local fadeIn = CCFadeIn:create(0.2)
            local arr2 = CCArray:create()
            arr2:addObject(delayAc)
            arr2:addObject(fadeIn)

            local seq=CCSequence:create(arr2)
            starsSp:runAction(seq)
        end
    
        for i=1,starsNum do

            local starsSp = CCSprite:createWithSpriteFrameName("stars_n1.png")
            starsSp:setScale(5)
            starsSp:setOpacity(0)
            starsSp:setPosition(ccp(tankPic:getPositionX()+addPosXTb[i],tankPic:getPositionY()-140+addPosYTb[i]))
            self.shakeLayer:addChild(starsSp,4)

            local function readyShake( )
                -- print("in readyShake~~~~~")
                PlayEffect(audioCfg.battle_star)
                self:shakingNow()
            end 
            local shakeCall = CCCallFunc:create(readyShake)
            local delayAc = CCDelayTime:create(0.4+i*0.3)
            local fadeIn = CCFadeIn:create(0.2)
            local scaleIn = CCScaleTo:create(0.1,1)
            local arr2 = CCArray:create()
            local arr3 = CCArray:create()
            arr2:addObject(fadeIn)
            arr2:addObject(scaleIn)
            
            local spawn=CCSpawn:create(arr2)
            arr3:addObject(delayAc)
            arr3:addObject(spawn)
            -- arr3:addObject(delayAc2)
            arr3:addObject(shakeCall)
            local seq = CCSequence:create(arr3)
            -- local seq=CCSequence:createWithTwoActions(delayAc,spawn)
            starsSp:runAction(seq)
        end
    end
end


-------失败动画
function smallDialog:runLoseAniInDown( )--跳转按钮逐个弹出
    for idx=1,SizeOfTable(self.itemTb) do
        local delayT = CCDelayTime:create(0.5+idx*0.15)
        local scale1 = CCScaleTo:create(0.2,1.2)
        -- local scale2 = CCScaleTo:create(0.05,0.8)
        local scale3 = CCScaleTo:create(0.05,1)
        local function showCall(  )
            if self.itemTb[idx] then
                self.itemTb[idx]:setVisible(true)
            end
        end 
        local func1 = CCCallFunc:create(showCall)
        local arr = CCArray:create()
        arr:addObject(delayT)
        arr:addObject(func1)
        arr:addObject(scale1)
        -- arr:addObject(scale2)
        arr:addObject(scale3)
        local seq=CCSequence:create(arr)
        self.itemTb[idx]:runAction(seq)
    end
end


function smallDialog:closeNewBattleResult()
    if self.isVictory then
        spriteController:removePlist("public/winR_newImage170612.plist")
        spriteController:removeTexture("public/winR_newImage170612.png")
    else
        spriteController:removePlist("public/loseR_newImage170612.plist")
        spriteController:removeTexture("public/loseR_newImage170612.png")
    end
    self.parent = nil
    -- self.layerNum = nil
    self:realClose()
    -- print("~~~~~~~~~~~~!!!!!!!!@@@@@@@########!!!!!~~~~~~~~~~~")
    spriteController:removePlist("public/newDisplayImage.plist")
    spriteController:removeTexture("public/newDisplayImage.png")
    spriteController:removePlist("public/powerGuideImages.plist")
    spriteController:removeTexture("public/powerGuideImages.png")
    
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
    spriteController:removePlist("public/battleResultAddPic.plist")
    spriteController:removeTexture("public/battleResultAddPic.png")
end

function smallDialog:addPic(isVictory )
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    if isVictory then
        spriteController:addPlist("public/winR_newImage170612.plist")
        spriteController:addTexture("public/winR_newImage170612.png")
    else
        spriteController:addPlist("public/loseR_newImage170612.plist")
        spriteController:addTexture("public/loseR_newImage170612.png")
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

-- 计算此次战斗的总伤害值
-- battleData:战斗数据
-- userName:需要计算谁的总伤害
function smallDialog:computeTotalHurtHandler(battleData,userName)
    if battleData==nil or userName==nil then
        return 0,0
    end
    -- 两个对战玩家数据
    local plyaerData = battleData.p
    -- 两个人总伤害数据
    local damageData = battleData.d.stats~=nil and battleData.d.stats.dmg or {}
    -- 两个人总伤亡数据
    local loseData = battleData.d.stats~=nil and battleData.d.stats.loss or {}
    if SizeOfTable(damageData)<1 or SizeOfTable(loseData)<1 then
        return 0,0
    end
    -- 后端传的舰队数数组内，玩家数据的idx
    local userIdx = 1
    -- 后端传的总伤害与总伤亡数组内，玩家数据的index
    local numIdx = 1
    if plyaerData and type(plyaerData)=="table" then
        for k,v in pairs(plyaerData) do
            if type(v)=="table" and v[1]==userName then
                userIdx = k
                if v[3]==1 then
                    numIdx = 1
                else
                    numIdx = 2
                end
            end
        end
    end
    -- 伤害返回值
    local hurtNum = tonumber(damageData[numIdx]) or 0
    -- 战损率
    local losePer = tonumber(loseData[numIdx]) or 0
    -- 玩家上阵舰船数量
    local totalShipNum = 0
    -- 遍历对阵舰队
    for k,v in pairs(battleData.t) do
        -- 找到玩家的舰队
        if k==userIdx then
            for kk,vv in pairs(v) do
                if vv[2] then
                    totalShipNum = totalShipNum + tonumber(vv[2])
                end
            end
        end
    end
    if totalShipNum>0 and losePer>0 then
        losePer = string.format("%0.2f",losePer/totalShipNum*100).."%"
    elseif losePer<0 then
        losePer = 0
    end
    return losePer,hurtNum
end

--震动
function smallDialog:shakingNow()
    
    local shakeArr2=CCArray:create()
    -- local delay = CCDelayTime:create(0.35)
    -- shakeArr2:addObject(delay)
    for i=1,5 do
      -- local dd=deviceHelper:getRandom()
      local rndx=15-(math.random(1,100)/100)*20+0
      local rndy=15-(math.random(1,100)/100)*20+0
      -- print("rndx--randy-->",rndx,rndy)
      -- local rndx=15-(deviceHelper:getRandom()/100)*30+G_VisibleSizeWidth/2
      -- local rndy=15-(deviceHelper:getRandom()/100)*30+G_VisibleSizeHeight/2
      -- local moveTo=CCMoveTo:create(0.02,ccp(rndx,rndy))
      -- shakeArr:addObject(moveTo)
      local moveTo2=CCMoveTo:create(0.02,ccp(rndx,rndy))
      shakeArr2:addObject(moveTo2)
    end
    -- local function resetPos()
    --    loadingSp:setPosition(getCenterPoint(self.effectLayer))
    -- end
    -- local funcall=CCCallFunc:create(resetPos)
    -- shakeArr:addObject(funcall)
    -- local shakeSeq=CCSequence:create(shakeArr)
    -- loadingSp:runAction(shakeSeq)
    local function resetPos2()
       self.shakeLayer:setPosition(ccp(0,0))
    end
    local funcall2=CCCallFunc:create(resetPos2)

    shakeArr2:addObject(funcall2)
    local shakeSeq2=CCSequence:create(shakeArr2)
    self.shakeLayer:runAction(shakeSeq2)
end