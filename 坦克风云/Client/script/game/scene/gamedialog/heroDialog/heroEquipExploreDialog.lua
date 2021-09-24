heroEquipExploreDialog = commonDialog:new()

function heroEquipExploreDialog:new(chapterId,index)
  local  nc = {}
  setmetatable(nc,self)
  self.__index=self
  self.chapterId=chapterId--默认打开第几章节
  self.index=index--默认打开该章节的第几关
  return nc
end

--初始化对话框面板
function heroEquipExploreDialog:initTableView( )
  self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
  self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))

    local function callBack( ... )
        return self:eventHandler(...)
    end

    local hd = LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-110),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setPosition(ccp(0,20))
    self.bgLayer:addChild(self.tv)

    local function callBack2( ... )
        heroEquipChallengeVoApi:openExplorePointDialog(self.chapterId,self.index,self,self.layerNum+1)
    end
    if self.chapterId then
        local minpid,maxpid=heroEquipChallengeVoApi:getMinAndMaxPid(self.chapterId)
        if heroEquipChallengeVoApi:getIfNeedSendECRequest()==true then
            socketHelper:getEquipExploreList(minpid,maxpid,callBack2)
        else
            callBack2()
        end

    end
end

function heroEquipExploreDialog:eventHandler( handler,fn,idx,cel )
  if fn=="numberOfCellsInTableView" then
    return heroEquipChallengeVoApi:getShowMaxPointNum()
  elseif fn =="tableCellSizeForIndex" then
    local tmpSize
    tmpSize=CCSizeMake(G_VisibleSizeWidth-20,160)
    return tmpSize
  elseif fn =="tableCellAtIndex" then
    local  cell = CCTableViewCell:new()
    cell:autorelease()
    cell:setAnchorPoint(ccp(0,0))

    local flag,msgStr = heroEquipChallengeVoApi:getChapterFlag(idx+1)
    local function clickBgHandler(object,fn,tag)
        if flag>1 then
            return
        end
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            local function callBack2( ... )
                heroEquipChallengeVoApi:openExplorePointDialog(idx+1,nil,self,self.layerNum)
            end
            local function callBack3( ... )
                if heroEquipChallengeVoApi:getIfNeedSendECRequest()==true then
                    local function callbackHandler5(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData and sData.data and sData.data.hchallenge then
                                heroEquipChallengeVoApi:formatData(sData.data.hchallenge)
                            end
                            callBack2()
                        end
                    end
                    local minpid,maxpid=heroEquipChallengeVoApi:getMinAndMaxPid(idx+1)
                    socketHelper:getEquipExploreList(minpid,maxpid,callbackHandler5)
                else
                    callBack2()
                end
            end

            local tembgSp = tolua.cast(cell:getChildByTag(idx+1),"LuaCCScale9Sprite")
            if tembgSp then
                local function callBack4()
                    callBack3()
                end
                local callFunc=CCCallFunc:create(callBack4)

                local scaleTo1=CCScaleTo:create(0.1,0.9,0.9)
                local scaleTo2=CCScaleTo:create(0.1,1,1)

                local acArr=CCArray:create()
                acArr:addObject(scaleTo1)
                acArr:addObject(scaleTo2)
                acArr:addObject(callFunc)

                local seq=CCSequence:create(acArr)
                tembgSp:runAction(seq)
            end
        end
    end
    local pic = "story/heroequip/story_chapter_"..(idx+1)..".jpg"

    local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("story_chapterBg.png",CCRect(20, 20, 10, 10),clickBgHandler)
    bgSp:setContentSize(CCSizeMake(610,155))
    bgSp:setPosition(ccp(G_VisibleSizeWidth/2,75))
    bgSp:setTouchPriority(-(self.layerNum-1)*20-3)
    cell:addChild(bgSp)
    bgSp:setTag(idx+1)

    local chapterSp
    if flag==0 or flag==1 then
        chapterSp=CCSprite:create(pic)
    else
        chapterSp=GraySprite:create(pic)
    end
    bgSp:addChild(chapterSp)
    chapterSp:setPosition(getCenterPoint(bgSp))

    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("subTitleBg.png",CCRect(20, 20, 10, 10),function ()end)
    titleBg:setContentSize(CCSizeMake(280,42))
    titleBg:setPosition(ccp(6,bgSp:getContentSize().height-8))
    bgSp:addChild(titleBg,1)
    titleBg:setAnchorPoint(ccp(0,1))
    if flag==0 or flag==1 then
        titleBg:setOpacity(180)
    end
    local strWidth2 = 150
    if G_getCurChoseLanguage() =="ar" then
        strWidth2 =150
    end

    local nameLb = GetTTFLabelWrap(heroEquipChallengeVoApi:getLocalChaperName(idx+1),23,CCSize(strWidth2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop, "Helvetica-bold")
    nameLb:setAnchorPoint(ccp(0,1))
    nameLb:setPosition(ccp(13,bgSp:getContentSize().height-11))
    bgSp:addChild(nameLb,2)
    nameLb:setColor(G_ColorGreen)

    if flag==0 or flag==1 then
        local completeBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
        completeBg:setContentSize(CCSizeMake(bgSp:getContentSize().width,45))
        completeBg:setPosition(ccp(bgSp:getContentSize().width/2,6))
        bgSp:addChild(completeBg,1)
        completeBg:setAnchorPoint(ccp(0.5,0))

        local starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
        starSp:setAnchorPoint(ccp(0,0))
        starSp:setPosition(ccp(10,10))
        bgSp:addChild(starSp,2)

        local maxNum = heroEquipChallengeVoApi:getMaxStarNum(idx+1)
        local curNum = heroEquipChallengeVoApi:getCurStarNum(idx+1)
        local progressLb = GetTTFLabelWrap(curNum.."/"..maxNum,25,CCSize(150, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        progressLb:setAnchorPoint(ccp(0,0))
        progressLb:setPosition(ccp(starSp:getPositionX()+starSp:getContentSize().width,10))
        bgSp:addChild(progressLb,2)
        progressLb:setColor(G_ColorYellowPro)

        if flag==0 then
            local completeLb = GetTTFLabelWrap(getlocal("equip_explore_complete"),25,CCSize(200, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
            completeLb:setAnchorPoint(ccp(1,0))
            completeLb:setPosition(ccp(bgSp:getContentSize().width-10,10))
            bgSp:addChild(completeLb,2)
            completeLb:setColor(G_ColorGreen)
        end
    elseif flag==2 or flag==3 or flag==4 then
        local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
        lockSp:setAnchorPoint(ccp(0.5,0.5))
        lockSp:setPosition(ccp(bgSp:getContentSize().width/2,bgSp:getContentSize().height/2+20))
        bgSp:addChild(lockSp,3)

        local function touchHandler( ... )

        end
        local maskSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandler)
        maskSp:setContentSize(CCSizeMake(bgSp:getContentSize().width+5,bgSp:getContentSize().height))
        maskSp:setPosition(getCenterPoint(bgSp))
        bgSp:addChild(maskSp,2)

        local unlockStr
        if flag==2 then
            unlockStr=getlocal("equip_explore_unlock",{msgStr})
        elseif flag==3 then
            unlockStr=getlocal("equip_challange_noOpne",{msgStr})
        elseif flag==4 then
            unlockStr=getlocal("alliance_notOpen")
        end
        local unlockLb = GetTTFLabelWrap(unlockStr,25,CCSize(G_VisibleSizeWidth-60, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        unlockLb:setAnchorPoint(ccp(0.5,0.5))
        unlockLb:setPosition(ccp(bgSp:getContentSize().width/2,lockSp:getPositionY()-lockSp:getContentSize().height/2-20))
        bgSp:addChild(unlockLb,3)
        unlockLb:setColor(G_ColorYellowPro)
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

function heroEquipExploreDialog:tick( ... )

end

function heroEquipExploreDialog:refreshData()
    if self and self.tv then
        self.tv:reloadData()
    end
end
function heroEquipExploreDialog:dispose( ... )
  self.tv = nil
  if self and self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
  self = nil
end