--赠送好友福字的弹窗
function smallDialog:showSendBlessWordDialog(isMyFriend,callback,bgSrc,size,fullRect,inRect,title,vo,layerNum)
  local sd=smallDialog:new()
  sd:initSendBlessWordDialog(isMyFriend,callback,bgSrc,size,fullRect,inRect,title,vo,layerNum)
end

function smallDialog:initSendBlessWordDialog(isMyFriend,callback,bgSrc,size,fullRect,inRect,title,vo,layerNum)
  local myChenghaoH=0
  if playerVoApi:getSwichOfGXH() and vo.title and tostring(vo.title)~="" and tostring(vo.title)~="0" then
    myChenghaoH=65
    size.height=size.height+myChenghaoH
  end
  self.isTouch=nil
  self.isUseAmi=isuseami
  local function touchHandler()
  end
  local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
  self.dialogLayer=CCLayer:create()
  
  self.bgLayer=dialogBg
  self.bgSize=size
  self.bgLayer:setContentSize(size)
  if self.isUseAmi then
    self:show()
  end

  local function touchDialog()
    
  end

  self.dialogLayer:addChild(self.bgLayer,1);
  self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
  self.dialogLayer:setBSwallowsTouches(true);
  self:userHandler()
  
  local capInSet = CCRect(20, 20, 10, 10)
  local function cellClick(hd,fn,idx)
  end
  local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",inRect,cellClick)
  
  backSprie:setContentSize(CCSizeMake(size.width-20, size.height-100))
  backSprie:ignoreAnchorPointForPosition(false)
  backSprie:setAnchorPoint(ccp(0,0))
  backSprie:setPosition(ccp(10,10))
  dialogBg:addChild(backSprie,1)

  local function close()
    PlayEffect(audioCfg.mouseClick)
    if closeCallBack then
      closeCallBack()
    end
    acAnniversaryBlessVoApi:clearDonateWordKey()
    return self:close()
  end
  local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
  closeBtnItem:setPosition(0,0)
  closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
  self.closeBtn = CCMenu:createWithItem(closeBtnItem)
  self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
  self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
  dialogBg:addChild(self.closeBtn)
  
  local titleLb=GetTTFLabel(title,30)
  titleLb:setAnchorPoint(ccp(0.5,0.5))
  titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-5))
  dialogBg:addChild(titleLb,1)

  if true then
    -- local personPhotoName="photo"..vo.pic..".png"
    -- local playerPic = GetBgIcon(personPhotoName)
    local personPhotoName=playerVoApi:getPersonPhotoName(vo.pic)
    local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName)
    playerPic:setAnchorPoint(ccp(0,1))
    playerPic:setPosition(ccp(10,size.height-5))
    dialogBg:addChild(playerPic,1)
  end

  local hSpace=65
  local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
  lineSprite:setAnchorPoint(ccp(0.5,0.5))
  lineSprite:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-2-(hSpace)-myChenghaoH))
  backSprie:addChild(lineSprite,2)
  lineSprite:setScaleX(0.8)

  local userInfoStr=getlocal("player_message_info_name",{vo.nickname,vo.level,playerVoApi:getRankName(vo.rank)})
  local userInfoLb = GetTTFLabelWrap(userInfoStr,30,CCSizeMake(backSprie:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  userInfoLb:setAnchorPoint(ccp(0,1))
  local height = backSprie:getContentSize().height-20-myChenghaoH
  userInfoLb:setPosition(ccp(20,height))
  backSprie:addChild(userInfoLb,2)

  local promptLb = GetTTFLabelWrap(getlocal("activity_anniversaryBless_prompt6"),25,CCSizeMake(backSprie:getContentSize().width-100,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
  promptLb:setAnchorPoint(ccp(0.5,1))
  local height = backSprie:getContentSize().height-20-((2-1)*hSpace)-myChenghaoH
  promptLb:setPosition(ccp(backSprie:getContentSize().width/2,height))
  promptLb:setColor(G_ColorYellowPro)
  backSprie:addChild(promptLb,2)

  local function onDonateGift()
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
    if callback then
      callback()
    end
    self:close()
  end

  local donateBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onDonateGift,nil,getlocal("confirm"),25)
  local donateMenu=CCMenu:createWithItem(donateBtn)
  donateMenu:setPosition(ccp(backSprie:getContentSize().width/2,50))
  donateMenu:setTouchPriority((-(layerNum-1)*20-4))
  donateBtn:setEnabled(false)
  backSprie:addChild(donateMenu)

  local function addSelectSp(parentBg)
      if parentBg then
        local selectSp=CCSprite:createWithSpriteFrameName("equipSelectedRect.png")
        selectSp:setPosition(ccp(parentBg:getContentSize().width/2,parentBg:getContentSize().height/2))
        selectSp:setScale(0.9)
        selectSp:setTag(10101)
        parentBg:addChild(selectSp)
      end
  end
  local function removeSelectSp(parentBg)
    if parentBg~=nil then
          local temSp=tolua.cast(parentBg,"CCNode")
          local metalSp=nil
          if temSp~=nil then
              metalSp=tolua.cast(temSp:getChildByTag(10101),"CCSprite")
          end
          if metalSp~=nil then
              metalSp:removeFromParentAndCleanup(true)
              metalSp=nil
          end
    end
  end

  local words = acAnniversaryBlessVoApi:getWordsData()
  local wordCount = SizeOfTable(words)
  local wordSpTab = {}
  local posX = 60
  local posY = height-50

  for k,word in pairs(words) do
    local iconName=acAnniversaryBlessVoApi:getWordIconName(word.key)
    -- print("word.count ================================ ",word.count)
    local wordIcon
    if word.count<=0 then
      wordIcon=GraySprite:createWithSpriteFrameName(iconName)
    else
      local function onTouch()
        local wordkey=acAnniversaryBlessVoApi:getDonateWordKey()
        if wordkey and wordSpTab[wordkey] then
          removeSelectSp(wordSpTab[wordkey])
        end
        if wordkey==nil or wordkey~=word.key then
          acAnniversaryBlessVoApi:setDonateWordKey(word.key)
          local wordName=acAnniversaryBlessVoApi:getWordName(word.key)
          promptLb:setString(getlocal("activity_anniversaryBless_prompt7",{vo.nickname,wordName}))
          donateBtn:setEnabled(true)
          addSelectSp(wordIcon,1.4,1.4)
        elseif wordkey==word.key then
          acAnniversaryBlessVoApi:clearDonateWordKey()
          promptLb:setString(getlocal("activity_anniversaryBless_prompt6"))
          donateBtn:setEnabled(false)
        end
      end
      wordIcon=LuaCCSprite:createWithSpriteFrameName(iconName,onTouch)
      wordSpTab[word.key]=wordIcon
      wordIcon:setTouchPriority(-(layerNum-1)*20-4)
      local countLb = GetTTFLabel(word.count,25)
      countLb:setAnchorPoint(ccp(1,0))
      countLb:setColor(G_ColorGreen)
      countLb:setPosition(ccp(wordIcon:getContentSize().width-8,2))
      wordIcon:addChild(countLb)
      countLb:setTag(101)  
    end
    if wordIcon then
      if k==4 then
          posX=138
          posY=posY-wordIcon:getContentSize().height-20
      elseif k==5 then
          posX=293
      end
      wordIcon:setAnchorPoint(ccp(0,1))
      wordIcon:setPosition(ccp(posX,posY))
      posX=posX+wordIcon:getContentSize().width+55
      backSprie:addChild(wordIcon)
    end
  end

  local function touchLuaSpr()
  end
  local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
  touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
  local rect=CCSizeMake(640,G_VisibleSizeHeight)
  touchDialogBg:setContentSize(rect)
  touchDialogBg:setOpacity(180)
  touchDialogBg:setPosition(ccp(0,0))
  self.dialogLayer:addChild(touchDialogBg)

  sceneGame:addChild(self.dialogLayer,layerNum)
  self.dialogLayer:setPosition(getCenterPoint(sceneGame))
  return self.dialogLayer
end

--领取邀请好友奖励的弹窗
function smallDialog:showPropListAndSureDialog(bgSrc,size,fullRect,inRect,title,content,propSpriteNameTb,firstPosX,isuseami,layerNum,lbColor,callBackHandler)
  local sd=smallDialog:new()
  sd:initPropListAndSureDialog(bgSrc,size,fullRect,inRect,title,content,propSpriteNameTb,firstPosX,isuseami,layerNum,lbColor,callBackHandler)
end

function smallDialog:initPropListAndSureDialog(bgSrc,size,fullRect,inRect,title,content,propSpriteNameTb,firstPosX,isuseami,layerNum,lbColor,callBackHandler)
  self.isTouch=istouch
  self.isUseAmi=isuseami
  local function touchHander() 
  end

  local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
  self.dialogLayer=CCLayer:create()
  self.dialogLayer:setBSwallowsTouches(true);
  self.bgLayer=dialogBg
  self.bgSize=size
  self.bgLayer:setContentSize(size)
  self:show()

  local function touchDialog()
  end

  self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
  self.dialogLayer:addChild(self.bgLayer,2)
  self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
  self:userHandler()
  
  local titleLb=GetTTFLabel(title,40)
  titleLb:setAnchorPoint(ccp(0.5,0.5))
  titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
  dialogBg:addChild(titleLb)
  
  local contentLb=GetTTFLabelWrap(content,28,CCSize(size.width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  contentLb:setAnchorPoint(ccp(0.5,0.5))
  contentLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-contentLb:getContentSize().height/2-60))
  dialogBg:addChild(contentLb)
  if lbColor~=nil then
      contentLb:setColor(lbColor)
  end
  --显示物品列表
  if propSpriteNameTb and type(propSpriteNameTb)=="table" then
    local posX=20
    if firstPosX then
      posX=firstPosX
    end
    local posY=contentLb:getPositionY()-contentLb:getContentSize().height/2-30
    local propCount=SizeOfTable(propSpriteNameTb)
    local space
    local propSize
    local anchor=ccp(0,1)
    if propCount-1==0 then
      anchor=ccp(0.5,1)
      posX=size.width/2
      space=0
    end
    for k,v in pairs(propSpriteNameTb) do
      local propSp=CCSprite:createWithSpriteFrameName(v)
      if propSp then
        propSize=propSp:getContentSize()
        if space==nil then
          space=(size.width-2*firstPosX-propCount*propSize.width)/(propCount-1)
        end
        propSp:setAnchorPoint(ccp(0,1))
        propSp:setPosition(ccp(posX,posY))
        posX=posX+propSp:getContentSize().width+space
        dialogBg:addChild(propSp)
      end
    end
  end
  --确定
  local function okHandler()
    PlayEffect(audioCfg.mouseClick)
    if callBackHandler~=nil then
      callBackHandler()
    end
    self:close()
  end

  local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",okHandler,2,getlocal("ok"),25)
  local sureMenu=CCMenu:createWithItem(sureItem);
  sureMenu:setPosition(ccp(size.width/2,50))
  sureMenu:setTouchPriority(-(layerNum-1)*20-3);
  dialogBg:addChild(sureMenu)
  
  local function touchLuaSpr()     
  end
  local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
  touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
  local rect=CCSizeMake(640,G_VisibleSizeHeight)
  touchDialogBg:setContentSize(rect)
  touchDialogBg:setOpacity(180)
  touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
  self.dialogLayer:addChild(touchDialogBg,1);
  sceneGame:addChild(self.dialogLayer,layerNum)
  self.dialogLayer:setPosition(ccp(0,0))
end