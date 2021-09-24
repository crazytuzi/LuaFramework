function smallDialog:showSureAndCancleAndCheckTip(bgSrc,size,fullRect,inRect,callBack,title,content,isuseami,layerNum,align,valign,cancleCallBack,leftBtnStr,rightBtnStr,isShowClose,isRichLabel,propId,content2,isCheckTip,tipLb,tipLbSize,isShowCheck,checkCallBack)
      local sd=smallDialog:new()
      sd:initSureAndCancleAndCheckTip(bgSrc,size,fullRect,inRect,callBack,title,content,isuseami,layerNum,align,valign,cancleCallBack,leftBtnStr,rightBtnStr,isShowClose,isRichLabel,propId,content2,isCheckTip,tipLb,tipLbSize,isShowCheck,checkCallBack)
      return sd
end

function smallDialog:shareSelectDialog(bgSrc,size,inRect,isuseami,layerNum,selectTb)
      local sd=smallDialog:new()
      local dialog=sd:initShareSelectDialog(bgSrc,size,inRect,isuseami,layerNum,selectTb)
      return sd
end

function smallDialog:showRewardPanel(layerNum,titleStr,titleSize,titleStr2,desc,descColor,rewardList,btnCallback,btnText,btnEnabled)
      local sd=smallDialog:new()
      sd:initRewardPanel(layerNum,titleStr,titleSize,titleStr2,desc,descColor,rewardList,btnCallback,btnText,btnEnabled)
      return sd
end
function smallDialog:showSpAndTipsDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,bgPoint,flag,reward,contentColor,isWait,addSprite)
    if flag==nil then
      flag=false
    end
    if base.fs==0 then
      flag=false
    end
    if reward and SizeOfTable(reward)>0 then
        newTipSmallDialog:showNewTipsDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,bgPoint,flag,reward,contentColor)
        -- local sd=newTipSmallDialog:new()
        -- sd:initTipsDialog(bgSrc,size,fullRect,CCRect(268, 35, 1, 1),textContnt,textSize,bgPoint,flag,reward)
        do return end
    end
    if flag==true then
      if isWait==true then
        table.insert(base.allShowTipStrTb,{textContnt,1})--1是两个tip提示之间间隔1秒
      else
        table.insert(base.allShowTipStrTb,textContnt)
      end
      do return end
    else
        local sd=smallDialog:new()
        sd:initSpAndTipsDialog(bgSrc,size,fullRect,CCRect(268, 35, 1, 1),textContnt,textSize,bgPoint,contentColor,addSprite)
    end

end

-- bgSrc:9宫格背景图片 size:对话框大小 callBack:确定回调函数 textContnt:文字内容 textSize:字体大小
function smallDialog:initSpAndTipsDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,bgPoint,contentColor,addSprite)

    local function tmpFunc()
      
    end
    local rrect=CCRect(0, 50, 1, 1)
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("tipsBg.png",rrect,tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size

  -- 计算lable     
    local textWrapNum = 400/textSize
    local lable = GetTTFLabel(textContnt,textSize);
    
    local heightNum = lable:getContentSize().width/((textWrapNum-2)*textSize)+1
    heightNum=heightNum+1
    if lable:getContentSize().width>400 then
        label=nil
        lable = GetTTFLabelWrap(textContnt,textSize,CCSize(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    end
    lable:setAnchorPoint(ccp(0.5,0.5));
    if contentColor then
      lable:setColor(contentColor)
    end
    local layerHeight=35+math.max(66,lable:getContentSize().height+10)   

    self.bgLayer:setContentSize(CCSize(611,layerHeight))
    lable:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,self.bgLayer:getContentSize().height/2-15));
    self.bgLayer:addChild(lable,1);
    if addSprite then
        local spIcon = CCSprite:createWithSpriteFrameName(addSprite)
        local scaleSp = (lable:getContentSize().height+10)/spIcon:getContentSize().height
        spIcon:setScale(scaleSp)
        lable:setPositionX(lable:getPositionX() + spIcon:getContentSize().width * scaleSp * 0.5)
        spIcon:setAnchorPoint(ccp(1,0.5))
        spIcon:setPosition(ccp(lable:getPositionX() - lable:getContentSize().width * 0.5 - 2 ,lable:getPositionY()))
        self.bgLayer:addChild(spIcon)
    end 
    self.bgLayer:setIsSallow(false);
    self.dialogLayer:addChild(self.bgLayer,1);
    sceneGame:addChild(self.dialogLayer,29)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2-20,G_VisibleSizeHeight/2+180))
  if bgPoint~=nil then
    self.bgLayer:setPosition(bgPoint)
  end
    self.bgLayer:setScale(0)
    self.bgLayer:setOpacity(180)
    --base:addTipsQueue(self)

    self:showTips()

end
function smallDialog:initRewardPanel(layerNum,titleStr,titleSize,titleStr2,desc,descColor,rewardList,btnCallback,btnText,btnEnabled)
    self.isTouch=false
    self.isUseAmi=isuseami

    local size = CCSizeMake(500,400)

    local iconSize = 100
    local listSize = SizeOfTable(rewardList)
    if listSize>3 then
        size.height = size.height + math.floor(listSize/3)*(iconSize + 20)
    end

    local function closeCallBack()
        self:close()
    end
    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,nil)
    -- G_getNewDialogBg(size,titleStr,titleSize,callback,layerNum,isShowClose,closeCallBack,titleColor)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(size.width,size.height)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    local function touchLuaSpr()
        -- self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);

    local title2=GetTTFLabelWrap(titleStr2,22,CCSize(self.bgSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    title2:setAnchorPoint(ccp(0,1))
    title2:setPosition(30,self.bgSize.height-80)
    self.bgLayer:addChild(title2)

    local topLineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
    topLineSp:setContentSize(CCSizeMake(self.bgSize.width-60,2))
    topLineSp:setPosition(self.bgSize.width/2,title2:getPositionY()-title2:getContentSize().height-20)
    self.bgLayer:addChild(topLineSp)

    local iconPosX={
        {self.bgSize.width/2},
        {self.bgSize.width/2-100,self.bgSize.width/2+100},
        {self.bgSize.width/2-150,self.bgSize.width/2,self.bgSize.width/2+150}
    }
    if listSize>3 then
        listSize=3
    end
    local _xIndex=1
    local _posY=self.bgSize.height-200
    for k,v in pairs(rewardList) do
        local function showNewPropDialog()
            G_showNewPropInfo(layerNum+1,true,true,nil,v)
        end
        local icon,scale=G_getItemIcon(v,iconSize,false,layerNum,showNewPropDialog)
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setPosition(iconPosX[listSize][_xIndex],_posY)
        icon:setTouchPriority(-(layerNum-1)*20-4)
        self.bgLayer:addChild(icon)

        local numLb=GetTTFLabel("x"..FormatNumber(v.num),23)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setScale(1/scale)
        numLb:setPosition(ccp(icon:getContentSize().width-5,2))
        icon:addChild(numLb,4)
        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        numBg:setAnchorPoint(ccp(1,0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
        numBg:setOpacity(150)
        icon:addChild(numBg,3)

        _xIndex=_xIndex+1
        if k%3==0 then
            _xIndex=1
            _posY=_posY-iconSize-20
        end
    end

    local bomLineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
    bomLineSp:setContentSize(CCSizeMake(self.bgSize.width-60,2))
    bomLineSp:setPosition(self.bgSize.width/2,125)
    self.bgLayer:addChild(bomLineSp)
    if desc then
        local countLb=GetTTFLabel(desc,22)
        countLb:setPosition(self.bgSize.width/2,90)
        if descColor then
            countLb:setColor(descColor)
        end
        self.bgLayer:addChild(countLb)
    end

    local function awardHandler(...)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if btnCallback then
            btnCallback(...)
        end
    end
    local awardBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",awardHandler,11)
    awardBtn:setScale(0.7)
    awardBtn:setAnchorPoint(ccp(0.5,0.5))
    local awardMenu=CCMenu:createWithItem(awardBtn)
    awardMenu:setTouchPriority(-(layerNum-1)*20-4)
    awardMenu:setPosition(ccp(self.bgSize.width/2,45))
    self.bgLayer:addChild(awardMenu)
    local awardBtnLb=GetTTFLabel(btnText,24,true)
    awardBtnLb:setPosition(awardMenu:getPositionX(),awardMenu:getPositionY())
    self.bgLayer:addChild(awardBtnLb)
    awardBtn:setEnabled(btnEnabled)

    sceneGame:addChild(self.dialogLayer,layerNum)

    return self.dialogLayer
end

function smallDialog:initShareSelectDialog(bgSrc,size,inRect,isuseami,layerNum,selectTb)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()
    
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    
    local space=100
    self.bgLayer=dialogBg
    -- self.bgSize=size
    local selectNum=SizeOfTable(selectTb) or 0
    self.bgSize=CCSizeMake(size.width,200+selectNum*space)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    local function touchDialog()
      
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()
    
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)
    
    local titleLb=GetTTFLabel(getlocal("alliance_send_report"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    local heightTb=G_getIconSequencePosx(2,space,self.bgSize.height/2+45,selectNum)
    for k,v in pairs(selectTb) do
        if v and v.btn and v.btnDown then
            local btnSp,btnDownSp=v.btn,v.btnDown
            local lbStr,lbSize="",0
            if v.lbStr and v.lbSize then
                lbStr,lbSize=v.lbStr or "",v.lbSize or 0
            end
            local tag=1
            if v.tag then
                tag=v.tag
            end
            local function sendHandler(tag,object)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                if v.callback~=nil then
                    v.callback(tag,object)
                end
                self:close()
            end
            local sendItem=GetButtonItem(v.btn,v.btnDown,v.btnDown,sendHandler,tag,lbStr,lbSize)
            local sendMenu=CCMenu:createWithItem(sendItem)
            sendMenu:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-heightTb[k]))
            sendMenu:setTouchPriority(-(layerNum-1)*20-2)
            dialogBg:addChild(sendMenu)
        end
    end

    local function touchLuaSpr()
         
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

-- bgSrc:9宫格背景图片 size:对话框大小 callBack:确定回调函数 title:标题 content:内容 isuseami:是否有动画效果 layerNum:层次 propId道具id(在确定按钮上方显示道具数量),leftStrSize:左边按钮的size
function smallDialog:initSureAndCancleAndCheckTip(bgSrc,size,fullRect,inRect,callBack,title,content,isuseami,layerNum,align,valign,cancleCallBack,leftBtnStr,rightBtnStr,isShowClose,isRichLabel,propId,content2,isCheckTip,tipLb,tipLbSize,isShowCheck,checkCallBack)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    local function touchHandler()
    
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    if isShowClose==true then
        local function close()
            PlayEffect(audioCfg.mouseClick)
            return self:close()
        end
        local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0,0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
         
        self.closeBtn = CCMenu:createWithItem(closeBtnItem)
        self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
        self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
        dialogBg:addChild(self.closeBtn)
    end
    
    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)
    local realalign,realValign=kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter
    if align~=nil then
        realalign=align
    end
    if valign~=nil then
        realValign=valign
    end

    local contentLb
    if isRichLabel~=nil then
       -- 返回label和纯字符串（计算label的height）
      local lable , _ = getRichLabel(content,25,CCSize(size.width-60,0))
      local labelHeight = size.height/2
      if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="de" then
          labelHeight =labelHeight+50
      end
      lable:setPosition(ccp(30,labelHeight))
      dialogBg:addChild(lable)
    else
       contentLb=GetTTFLabelWrap(content,25,CCSize(size.width-60,0),realalign,realValign)
   contentLb:setAnchorPoint(ccp(0.5,0.5))
    contentLb:setPosition(ccp(size.width*0.5,size.height*0.6))
    contentLb:setTag(518)
    dialogBg:addChild(contentLb)
    end

    if content2 then
      local contentLb2=GetTTFLabelWrap(content2,25,CCSize(size.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
     contentLb2:setAnchorPoint(ccp(0,1))
     contentLb:setPosition(size.width/2,size.height/2+20)
      contentLb2:setPosition(ccp(30,contentLb:getPositionY()-contentLb:getContentSize().height/2-10))
      dialogBg:addChild(contentLb2)
      contentLb2:setColor(G_ColorYellowPro)
    end
    
    --取消
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if cancleCallBack~=nil then
            cancleCallBack()
         end
         self:close()
    end
    local cancleItem
    if rightBtnStr and rightBtnStr~="" then
        cancleItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",cancleHandler,2,rightBtnStr,25)
    else
        cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancleHandler,2,getlocal("cancel"),25)
    end
    -- local cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancleHandler,2,rightStr,25)
    local cancleMenu=CCMenu:createWithItem(cancleItem);
    cancleMenu:setPosition(ccp(size.width-120,60))
    cancleMenu:setTouchPriority(-(layerNum-1)*20-5);
    dialogBg:addChild(cancleMenu)
    --确定
    local function sureHandler()
        PlayEffect(audioCfg.mouseClick)
        callBack()
        self:close()
    end
    local leftStr=getlocal("ok")
    local leftSize = 25

    if leftBtnStr and leftBtnStr~="" then
        leftStr=leftBtnStr  
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,leftStr,leftSize)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(120,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-5);
    dialogBg:addChild(sureMenu)
    
    if propId then
        if propCfg["p"..propId] then
            local itemNum=bagVoApi:getItemNumId(propId) or 0
            local itemNumLb=GetTTFLabel(getlocal(propCfg["p"..propId].name)..": "..itemNum,25)
            itemNumLb:setPosition(ccp(120,115))
            dialogBg:addChild(itemNumLb,1)
        end
    end
	local function touchLuaSpr() end

    if isCheckTip then
    	local checkShowSp =nil

    	local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    	tipBg:setAnchorPoint(ccp(0.5,0))
    	tipBg:setOpacity(0)
    	tipBg:setPosition(ccp(dialogBg:getContentSize().width*0.5,sureMenu:getPositionY()+55))
    	dialogBg:addChild(tipBg)

    	local function cCallBack( )
    		if checkShowSp and checkCallBack then
    			if isShowCheck then
	    			checkShowSp:setVisible(false)
	    			isShowCheck =false
	    			checkCallBack(false)
	    		else
	    			checkShowSp:setVisible(true)
	    			isShowCheck =true
	    			checkCallBack(true)
	    		end
	    	end
    	end 
    	local checkTipBg=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",cCallBack)
	    checkTipBg:setAnchorPoint(ccp(0,0.5))
	    checkTipBg:setTouchPriority(-(layerNum-1)*20-5);
	    checkTipBg:setPosition(5,tipBg:getContentSize().height*0.5)
		tipBg:addChild(checkTipBg)

		local tipLbRealSize = 24
		if tipLbSize then
			tipLbRealSize = tipLbSize
		end
		local tipLbDefault = GetTTFLabel(tipLb,tipLbRealSize)
		local largeWidth = dialogBg:getContentSize().width*0.71
	    local tipLbStr = tipLbDefault:getContentSize().width < largeWidth and tipLbDefault or GetTTFLabelWrap(tipLb,tipLbRealSize,CCSizeMake(largeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    tipLbStr:setAnchorPoint(ccp(0,0.5))
	    checkTipBg:addChild(tipLbStr)
	    tipLbStr:setPosition(checkTipBg:getContentSize().width+5,checkTipBg:getContentSize().height/2)

	    checkShowSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
	    checkTipBg:addChild(checkShowSp)
	    checkShowSp:setPosition(checkTipBg:getContentSize().width/2,checkTipBg:getContentSize().height/2)
	    if isShowCheck ==true then
	    	checkShowSp:setVisible(true)
	    else
		    checkShowSp:setVisible(false)
		end
		local tipbgHeight = checkTipBg:getContentSize().height > tipLbStr:getContentSize().height and checkTipBg:getContentSize().height or tipLbStr:getContentSize().height
		tipBg:setContentSize(CCSizeMake(checkTipBg:getContentSize().width+tipLbStr:getContentSize().width,tipbgHeight))
    end
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-4)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(100)
        touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
        self.dialogLayer:addChild(touchDialogBg,1);
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

--新皮肤提示的面板
function smallDialog:showSkinNoticeDialog(skinID,layerNum)
    local sd=smallDialog:new()
    sd.dialogLayer=CCLayer:create()
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ( ... )end)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(sd.dialogLayer))
    sd.dialogLayer:addChild(touchDialogBg)
    local function onClose()
        skinMgr:noticeShowed(skinID,sd.nolongerFlag)
        sd:close()
    end
    local tipStr=getlocal("skin_notice_"..skinID)
    local tipLb=GetTTFLabelWrap(tipStr,23,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local bgSize=CCSizeMake(450,tipLb:getContentSize().height + 250)
    local dialogBg=G_getNewDialogBg(bgSize,getlocal("dialog_title_prompt"),30,nil,layerNum,true,onClose)
    sd.bgLayer=dialogBg
    sd.bgSize=bgSize
    sd:show()
    dialogBg:setPosition(getCenterPoint(sd.dialogLayer))
    sd.dialogLayer:addChild(dialogBg)
    sd.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sd.dialogLayer:setBSwallowsTouches(true)    

    tipLb:setAnchorPoint(ccp(0.5,1))
    tipLb:setPosition(bgSize.width/2,bgSize.height - 100)
    sd.bgLayer:addChild(tipLb)

    local checkSp
    local function onCheck()
        if(checkSp and tolua.cast(checkSp,"CCSprite"))then
            local sp1,sp2=tolua.cast(checkSp:getChildByTag(1),"CCSprite"),tolua.cast(checkSp:getChildByTag(2),"CCSprite")
            if(sp1==nil or sp2==nil)then
                do return end
            end
            if(sd.nolongerFlag==nil or sd.nolongerFlag==false)then
                sd.nolongerFlag=true
                sp1:setVisible(false)
                sp2:setVisible(true)
            else
                sd.nolongerFlag=false
                sp1:setVisible(true)
                sp2:setVisible(false)
            end
        end
    end
    checkSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(0,0,40,40),onCheck)
    checkSp:setContentSize(CCSizeMake(50,50))
    checkSp:setTouchPriority(-(layerNum-1)*20-2)
    checkSp:setOpacity(10)
    checkSp:setAnchorPoint(ccp(0,0))
    checkSp:setPosition(50,90)
    dialogBg:addChild(checkSp)
    local checkSp1=CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
    checkSp1:setTag(1)
    checkSp1:setAnchorPoint(ccp(0,0))
    checkSp1:setPosition(ccp(0,0))
    checkSp:addChild(checkSp1)
    local checkSp2=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    checkSp2:setTag(2)
    checkSp2:setVisible(false)
    checkSp2:setAnchorPoint(ccp(0,0))
    checkSp2:setPosition(ccp(0,0))
    checkSp:addChild(checkSp2)
    local checkLb=GetTTFLabel(getlocal("evaluate_never"),23)
    checkLb:setAnchorPoint(ccp(0,0.5))
    checkLb:setPosition(110,115)
    dialogBg:addChild(checkLb)
    local function onCancel()
        PlayEffect(audioCfg.mouseClick)
        onClose()
    end
    local cancelItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onCancel,2,getlocal("cancel"),25)
    cancelItem:setScale(0.8)
    local cancelMenu=CCMenu:createWithItem(cancelItem)
    cancelMenu:setTouchPriority(-(layerNum-1)*20-2)
    cancelMenu:setPosition(bgSize.width - 100,50)
    dialogBg:addChild(cancelMenu)
    local function onConfirm()
        PlayEffect(audioCfg.mouseClick)
        skinMgr:setSkin(skinID)
        onClose()
    end
    local confirmItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onConfirm,2,getlocal("confirm"),25)
    confirmItem:setScale(0.8)
    local confirmMenu=CCMenu:createWithItem(confirmItem)
    confirmMenu:setTouchPriority(-(layerNum-1)*20-2)
    confirmMenu:setPosition(100,50)
    dialogBg:addChild(confirmMenu)
    sd.dialogLayer:setPosition(ccp(0,0))
    sceneGame:addChild(sd.dialogLayer,layerNum)
    return sd
end

--jumpFlag：军衔，vip跳转标识，jumpFlag为false时不跳转
function smallDialog:showReportPlayerInfoSmallDialog(player,layerNum,isuseami,titleStr,jumpFlag)
    local sd=smallDialog:new()
    sd:initReportPlayerInfoSmallDialog(player,layerNum,isuseami,titleStr,jumpFlag)
    return sd
end

function smallDialog:initReportPlayerInfoSmallDialog(player,layerNum,isuseami,titleStr,jumpFlag)
    self.isTouch=isTouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum

    spriteController:addPlist("public/chatVipNoLevel.plist")
    spriteController:addTexture("public/chatVipNoLevel.png")
    local size=CCSizeMake(550,230)
    if player.uid and tonumber(player.uid)~=tonumber(playerVoApi:getUid()) then
        size.height=size.height+120
    end
    local chenghaoFlag=false --称号
    local chenghao=player.chenghao
    -- chenghao=12
    if playerVoApi:getSwichOfGXH() and chenghao and tostring(chenghao)~="" and tostring(chenghao)~="0"  then
        size.height=size.height+70
        chenghaoFlag=true
    end
    local vipPicStr
    if chatVoApi:isJapanV() then --日本vip显示特殊需求
        vipPicStr="vipNoLevel.png"
    elseif player.vip then
        vipPicStr="Vip"..player.vip..".png"
    end
    if (vipPicStr and G_chatVip==true) or (player.rank and player.rank>0) then
        size.height=size.height+100
    end
    self.dialogLayer=CCLayer:create()
    local function close()
        self:close()
        spriteController:removePlist("public/chatVipNoLevel.plist")
        spriteController:removeTexture("public/chatVipNoLevel.png")
    end
    local titleStr=title or getlocal("player_message_info_title")
    local dialogBg=G_getNewDialogBg(size,titleStr,30,nil,self.layerNum,true,close)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)

    local posY=size.height-70
    local iconWidth,fontSize=100,20

    --显示称号
    if chenghaoFlag==true then
        posY=posY-15
        local nameStr="player_title_name_" .. chenghao
        local nameLb=GetTTFLabel(getlocal(nameStr),25)
      
        local function nilFunc()
            if G_checkClickEnable()==false then
                do return  end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local scaleTo1=CCScaleTo:create(0.1,0.9)
            local scaleTo2=CCScaleTo:create(0.1,1)
            local function callBack()
                local nameStr=getlocal("player_title_name_" .. chenghao)
                local desStr=getlocal("player_title_des_" .. chenghao)
                local td=smallDialog:new()
                local textTab={desStr}
                local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,textTab,25,nil,nameStr)
                sceneGame:addChild(dialog,self.layerNum+1)
            end
            local callFunc=CCCallFunc:create(callBack)
            local acArr=CCArray:create()
            acArr:addObject(scaleTo1)
            acArr:addObject(callFunc)
            acArr:addObject(scaleTo2)
            local seq=CCSequence:create(acArr)
            self.titleBg:runAction(seq)
        end
        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27, 29, 2, 2),nilFunc)
        titleBg:setContentSize(CCSizeMake(nameLb:getContentSize().width+210,60))
        titleBg:ignoreAnchorPointForPosition(false)
        titleBg:setAnchorPoint(ccp(0.5,1))
        self.bgLayer:addChild(titleBg)
        titleBg:setTouchPriority(-(self.layerNum-1)*20-4)
        titleBg:setOpacity(0)
        self.titleBg=titleBg

        local function lightAction()
            local fadeIn=CCFadeIn:create(0.4)
            local fadeOut=CCFadeOut:create(0.4)
            local arr=CCArray:create()
            arr:addObject(fadeIn)
            arr:addObject(fadeOut)
            local seq=CCSequence:create(arr)
            return seq
        end

        local function sbCallback()
        end
        local title1Bg=LuaCCScale9Sprite:createWithSpriteFrameName("playerTitleBg1.png",CCRect(120, 22, 1, 1),sbCallback)
        title1Bg:setContentSize(CCSizeMake(titleBg:getContentSize().width/2,45))
        title1Bg:setAnchorPoint(ccp(0,0.5))
        titleBg:addChild(title1Bg)
        title1Bg:setPosition(0,titleBg:getContentSize().height/2)

        local guang1Sp=CCSprite:createWithSpriteFrameName("playerTitleBg4.png")
        title1Bg:addChild(guang1Sp)
        guang1Sp:setPosition(55,40)
        guang1Sp:setOpacity(0)

        local function sbCallback()
        end
        local title2Bg=LuaCCScale9Sprite:createWithSpriteFrameName("playerTitleBg2.png",CCRect(44, 22, 1, 1),sbCallback)
        title2Bg:setContentSize(CCSizeMake(titleBg:getContentSize().width/2,45))
        title2Bg:setAnchorPoint(ccp(1,0.5))
        titleBg:addChild(title2Bg)
        title2Bg:setPosition(titleBg:getContentSize().width,titleBg:getContentSize().height/2)
        local guang2Sp=CCSprite:createWithSpriteFrameName("playerTitleBg4.png")
        title2Bg:addChild(guang2Sp)
        guang2Sp:setPosition(title2Bg:getContentSize().width-30,30)
        guang2Sp:setOpacity(0)

        local function acCallback()
            local lightNum=math.random(0,9)
            if lightNum<5 then
                guang1Sp:runAction(lightAction())
            else
                guang2Sp:runAction(lightAction())
            end
        end
        local callFunc=CCCallFunc:create(acCallback)
        local delay=CCDelayTime:create(3)
        local seq=CCSequence:createWithTwoActions(callFunc,delay)
        local repeatForever=CCRepeatForever:create(seq)
        self.bgLayer:runAction(repeatForever)

        local title3Bg=CCSprite:createWithSpriteFrameName("playerTitleBg3.png")
        title3Bg:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2-10)
        titleBg:addChild(title3Bg)

        titleBg:setPosition(size.width/2,posY)
        nameLb:setPosition(titleBg:getContentSize().width/2, titleBg:getContentSize().height/2+15)
        nameLb:setColor(G_ColorYellowPro)
        titleBg:addChild(nameLb,3)

        local namePosX,namePosY=nameLb:getPosition()
        local posTb={ccp(namePosX+1,namePosY),ccp(namePosX-1,namePosY),ccp(namePosX,namePosY+1),ccp(namePosX,namePosY-1)}
        for k,v in pairs(posTb) do --给名称文字加描边
            local nameLb=GetTTFLabel(getlocal(nameStr),25)
            nameLb:setPosition(v)
            nameLb:setColor(G_ColorBlack)
            titleBg:addChild(nameLb)
        end
        posY=posY-60
    end

    local pic,fhid=(player.pic or headCfg.default),(player.fhid or headFrameCfg.default)
    local personPhotoName=playerVoApi:getPersonPhotoName(pic)
    local playerSp=playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,iconWidth,fhid)
    playerSp:setPosition(20+iconWidth/2,posY-10-iconWidth/2)
    self.bgLayer:addChild(playerSp)

    local nameLb=GetTTFLabelWrap(player.name,fontSize+2,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    nameLb:setAnchorPoint(ccp(0,1))
    nameLb:setPosition(playerSp:getPositionX()+iconWidth/2+10,playerSp:getPositionY()+iconWidth/2)
    self.bgLayer:addChild(nameLb)

    local levelLb=GetTTFLabelWrap(getlocal("world_war_level",{player.level or 0}),fontSize,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    levelLb:setAnchorPoint(ccp(0,1))
    levelLb:setPosition(nameLb:getPositionX(),nameLb:getPositionY()-nameLb:getContentSize().height-10)
    self.bgLayer:addChild(levelLb)

    local fightLb=GetTTFLabelWrap(getlocal("world_war_power",{player.fight or 0}),fontSize,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    fightLb:setAnchorPoint(ccp(0,1))
    fightLb:setPosition(nameLb:getPositionX(),levelLb:getPositionY()-levelLb:getContentSize().height-10)
    self.bgLayer:addChild(fightLb)

    local allianceStr=""
    if player.alliance and player.alliance~="" then
        allianceStr=getlocal("local_war_history_alliance",{player.alliance})
    else
        allianceStr=getlocal("local_war_history_alliance",{getlocal("alliance_scene_info_null")})
    end
    local allianceLb=GetTTFLabelWrap(allianceStr,fontSize,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    allianceLb:setAnchorPoint(ccp(0,0.5))
    allianceLb:setPosition(20,playerSp:getPositionY()-iconWidth/2-allianceLb:getContentSize().height/2-10)
    self.bgLayer:addChild(allianceLb)

    local vipIcon,rankSp
    local iconWidth=60
    local bgWidth,bgHeight,num=0,20,0    
    if vipPicStr and G_chatVip==true then
        local function showTip()
            if jumpFlag==false then
                do return end
            end
            if G_checkClickEnable()==false then
                do return  end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local function callback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.vipRewardCfg then
                        vipVoApi:setVipReward(sData.data.vipRewardCfg)
                        local vf=vipVoApi:getVf(vf)
                        for k,v in pairs(vf) do
                            vipVoApi:setRealReward(v)
                        end                
                        vipVoApi:setVipFlag(true)
                        vipVoApi:openVipDialog(layerNum+1,true)
                        close()
                    end
                end            
            end
            if vipVoApi:getVipFlag()==false then
                socketHelper:vipgiftreward(callback)
            else
                vipVoApi:openVipDialog(layerNum+1,true)
                close()
            end
        end
        vipIcon=LuaCCSprite:createWithSpriteFrameName(vipPicStr,showTip)
        vipIcon:setTouchPriority(-(self.layerNum-1)*20-4)
        vipIcon:setScale(iconWidth/vipIcon:getContentSize().width)
        vipIcon:setAnchorPoint(ccp(0,0.5))
        bgWidth=bgWidth+vipIcon:getContentSize().width*vipIcon:getScaleX()
        num=num+1
    end
    if player.rank and player.rank>0 then
        local pic=playerVoApi:getRankIconName(player.rank)
        if pic then
           local function showTip()
                if jumpFlag==false then
                    do return end
                end
                if G_checkClickEnable()==false then
                    do return  end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                require "luascript/script/game/scene/gamedialog/playerDialog/playerRankDialog"
                local dialog=playerRankDialog:new()
                local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("help2_t1_t3"),true,layerNum+1)
                sceneGame:addChild(layer,self.layerNum+1)
                close()
            end
            rankSp=LuaCCSprite:createWithSpriteFrameName(pic,showTip)
            rankSp:setScale(iconWidth/rankSp:getContentSize().width)
            rankSp:setTouchPriority(-(self.layerNum-1)*20-4)
            bgWidth=bgWidth+rankSp:getContentSize().width*rankSp:getScaleX()
            num=num+1
        end
    end

    if rankSp or vipIcon then
        local iconsBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        iconsBg:setOpacity(0)
        iconsBg:setAnchorPoint(ccp(0.5,0))
        self.bgLayer:addChild(iconsBg)
        if num>0 then
            bgWidth=bgWidth+(num-1)*10
        end
        iconsBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
        local iconPosX=0
        if rankSp then
            iconsBg:addChild(rankSp)
            rankSp:setPosition(iconPosX,40)
            iconPosX=iconPosX+rankSp:getContentSize().width*rankSp:getScaleX()+10
        end
        if vipIcon then
            iconsBg:addChild(vipIcon)
            vipIcon:setPosition(iconPosX,40)
            iconPosX=iconPosX+vipIcon:getContentSize().width*vipIcon:getScaleX()+10
        end
        if player.uid and tonumber(player.uid)~=tonumber(playerVoApi:getUid()) then
            iconsBg:setPosition(ccp(size.width*0.5,90))
        else
            iconsBg:setPosition(ccp(size.width*0.5,20))
        end
        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
        lineSp:setContentSize(CCSizeMake(size.width-80,2))
        lineSp:setPosition(size.width/2,iconsBg:getPositionY()+80)
        lineSp:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:addChild(lineSp,2)
    end
    
    if player.uid and tonumber(player.uid)~=tonumber(playerVoApi:getUid()) then --如果不是自己的话有一下操作按钮
        local function touchMenu(tag)
            local pid="p"..tag
            local haveNum=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))
            if 1>haveNum then
                local nameStr=getlocal(propCfg[pid].name)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("satellite_des4",{nameStr}),30)
                return
            end
            local function refreshCallback()
                close()
            end
            bagVoApi:showSearchSmallDialog(layerNum+1,pid,refreshCallback,usePlayerNameInType_1)
        end

        local btnScale,priority=0.6,-(self.layerNum-1)*20-2
        local function menuFunc1()
          touchMenu(3305)
        end
        local function menuFunc2()
          touchMenu(3304)
        end
        local function  addMailList()
            local uid=player.uid
            local name=player.name
            if #friendInfoVo.friendTb + 1 > friendInfoVoApi:getfriendCfg(2) then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_err_12003"),28)
                else    
                    local function callback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addMailListSuccess",{name}),28) 
                            local function callbackList(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    
                                end
                            end
                        socketHelper:friendsList(callbackList)
                        end   
                    end
                socketHelper:sendfriendApply(uid,callback)
            end  
        end
        local btnFontSize=20
        local detectMenuItem1=G_createBotton(self.bgLayer,ccp(size.width*0.5-150,50),{getlocal("dailyNews_scout_troop"),btnFontSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",menuFunc1,btnScale,priority)
        local detectMenuItem2=G_createBotton(self.bgLayer,ccp(size.width*0.5,50),{getlocal("dailyNews_scout_base"),btnFontSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",menuFunc2,btnScale,priority)
        local addFriendBtn=G_createBotton(self.bgLayer,ccp(size.width*0.5+150,50),{getlocal("addFriends_title"),btnFontSize},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",addMailList,btnScale,priority)

        --加入黑名单
        local function  addBlackList()
            local uid=player.uid
            local name=player.name
            local blackList=G_getBlackList()
            if blackList and SizeOfTable(blackList)>0 then
                for k,v in pairs(blackList) do
                    if tonumber(uid)==tonumber(v.uid) and tostring(name)==tostring(v.name) then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{name}),28)
                        do return end
                    end
                end
            end
            if SizeOfTable(G_getBlackList())>=G_blackListNum then
                 smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("blackListMax"),28)
                do return end
            end
            local function confirmHandler()
                local function saveBlackCallback()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{name}),28)
                end
                local toBlackTb={uid=uid,name=name}
                local isSuccess=G_saveNameAndUidInBlackList(toBlackTb,saveBlackCallback)
            end
            local mailStr=getlocal("shieldDesc",{name})
            if base.mailBlackList==1 then
                mailStr=getlocal("shieldDesc1",{name})
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmHandler,getlocal("dialog_title_prompt"),mailStr,nil,self.layerNum+1)
        end

        --写信
        local function emailCallBack()
            if tonumber(player.uid)==tonumber(playerVoApi:getUid()) then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("player_message_info_tip1"),true,self.layerNum+2)
                return false
            else
                local lyNum=self.layerNum+2
                emailVoApi:showWriteEmailDialog(lyNum,getlocal("email_write"),player.name,nil,nil,nil,nil,player.uid)
                return true
            end
        end

        --私聊
        local function whisperCallBack()
            if tonumber(player.uid)==tonumber(playerVoApi:getUid()) then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("message_scene_whiper_prompt"),true,self.layerNum+2)
                return false
            else
                chatVoApi:showChatDialog(self.layerNum+1,nil,player.uid,player.name,true)
                return true
            end
        end
        local addH=0
        if chenghaoFlag==true then
            addH=-70
        end
        local forbidBtn=G_createBotton(self.bgLayer,ccp(size.width-60,size.height-100+addH),nil,"shieldPlayerInfo_2.png","shieldPlayerInfo_1.png","shieldPlayerInfo_1.png",addBlackList,1,priority)
        local emailBtn=G_createBotton(self.bgLayer,ccp(size.width-60,size.height-170+addH),nil,"emailToPlayer_2.png","emailToPlayer_1.png","emailToPlayer_1.png",emailCallBack,1,priority)
        local privateChatBtn=G_createBotton(self.bgLayer,ccp(size.width-60,size.height-240+addH),nil,"privateChat_2.png","privateChat_1.png","privateChat_1.png",whisperCallBack,1,priority)
    end

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,3)

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(0,0)
    return self.dialogLayer
end

function smallDialog:showInputCodeDialog(layerNum,callback)
    local sd=smallDialog:new()
    sd:initInputCodeDialog(layerNum,callback)
    return sd
end

function smallDialog:initInputCodeDialog(layerNum,callback)
    self.isTouch=false
    self.isUseAmi=isuseami
    local size=CCSizeMake(550,450)
    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    local titleLb=GetTTFLabel(getlocal("migrationCodeInput"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2-15,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    local inputLable = GetTTFLabelWrap(getlocal("input_code"),25,CCSizeMake(self.bgSize.width-200,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
    inputLable:setAnchorPoint(ccp(0,0.5))
    inputLable:setPosition(ccp(50,self.bgSize.height-155))
    self.bgLayer:addChild(inputLable,1)
    local editTargetBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),touchHandler)
    editTargetBox:setContentSize(CCSizeMake(self.bgSize.width-200,50))
    editTargetBox:setIsSallow(false)
    editTargetBox:setTouchPriority(-(layerNum-1)*20-4)
    editTargetBox:setPosition(ccp(50+editTargetBox:getContentSize().width/2,self.bgSize.height-230))
    local targetBoxLabel=GetTTFLabel("",25)
    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,editTargetBox:getContentSize().height/2))
    local customEditBox=customEditBox:new()
    local length=100
    customEditBox:init(editTargetBox,targetBoxLabel,"mail_input_bg.png",nil,-(layerNum-1)*20-4,length,touchHandler,nil,nil)
    self.bgLayer:addChild(editTargetBox,2)

    local btnScale, priority = 0.5, -(layerNum - 1) * 20 - 4
    local function pasteHandler()
        local zoneid=base.curOldZoneID
        if zoneid==nil or tonumber(zoneid)==0 then
            zoneid=base.curZoneID
        end
        local code=migrationVoApi:getMigrationCopyCode(zoneid)
        targetBoxLabel:setString(code)
    end
    local pasteItem = G_createBotton(self.bgLayer, ccp(editTargetBox:getPositionX()+editTargetBox:getContentSize().width/2+60, editTargetBox:getPositionY()), {getlocal("activity_ryhg_acBtn3"), 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", pasteHandler, btnScale, priority)

    local function onConfirm()
        PlayEffect(audioCfg.mouseClick)
        local targetStr=targetBoxLabel:getString()
        if targetStr==nil or targetStr=="" then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("nullCharacter"),28)
            return
        else
            if(callback)then
                callback(targetStr)
                self:close()
            end
        end
    end
    self.sureItem=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",onConfirm,2,getlocal("code_gift"),25)
    local sureMenu=CCMenu:createWithItem(self.sureItem);
    sureMenu:setPosition(ccp(size.width/2,90))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandler);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:showRewardPreviewDialog(layerNum, titleAndTipsStr, awardTb, callback)
    local sd=smallDialog:new()
    sd:initRewardPreviewDialog(layerNum, titleAndTipsStr, awardTb, callback)
    return sd
end

function smallDialog:initRewardPreviewDialog(layerNum, titleAndTipsStr, awardTb, callback)
    self.layerNum = layerNum
    self.isUseAmi = true

    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    local titleStr = titleAndTipsStr[1] or ""
    local tipsStr = titleAndTipsStr[2] or ""
    local awardSize = SizeOfTable(awardTb)

    self.bgSize = CCSizeMake(550, 250)
    self.bgSize.height = self.bgSize.height + math.ceil(awardSize / 4) * 150
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 28, nil, self.layerNum, false, function()end, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)

    local tipsLb = GetTTFLabelWrap(tipsStr, 20, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    tipsLb:setAnchorPoint(ccp(0, 1))
    tipsLb:setPosition(30, self.bgSize.height - 100)
    self.bgLayer:addChild(tipsLb, 1)

    local awardHeight = tipsLb:getPositionY() - tipsLb:getContentSize().height-35
    local awardBg = LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png", CCRect(42, 26, 10, 10), function()end)
    awardBg:setContentSize(CCSizeMake(self.bgSize.width - 30, 150 * math.ceil(awardSize / 4)))
    awardBg:setAnchorPoint(ccp(0.5, 1))
    awardBg:setPosition(ccp(self.bgSize.width / 2, tipsLb:getPositionY() - tipsLb:getContentSize().height - 15))
    self.bgLayer:addChild(awardBg, 1)

    local colNum = (awardSize > 4) and 4 or awardSize
    local iconSize, iconSpaceX = 80, 35
    local iconStartPosX = (awardBg:getContentSize().width - (iconSize * colNum + (colNum - 1) * iconSpaceX)) / 2
    for k, v in pairs(awardTb) do
        local icon, scale = G_getItemIcon(v, 100, true, self.layerNum)
        icon:setScale(iconSize / icon:getContentSize().height)
        scale = icon:getScale()
        icon:setTouchPriority(-(layerNum - 1) * 20 - 3)
        icon:setAnchorPoint(ccp(0, 1))
        local numLable = GetTTFLabel("x" .. FormatNumber(v.num), 25)
        icon:setPosition(iconStartPosX + ((k - 1) % 4) * (iconSize + iconSpaceX), awardBg:getContentSize().height - 20 - math.floor((k - 1) / 4) * (iconSize + numLable:getContentSize().height + 25))
        awardBg:addChild(icon)
        numLable:setAnchorPoint(ccp(0.5, 1))
        numLable:setPosition(icon:getPositionX() + iconSize / 2, icon:getPositionY() - iconSize - 5)
        awardBg:addChild(numLable)
    end

    local function onClickHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
            self:close()
        elseif tag == 11 then
            if callback then
                callback(self)
            end
        end
    end
    local btnScale = 0.8
    local cancelBtn = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", onClickHandler, 10, getlocal("cancel"), 24 / btnScale)
    local sureBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("confirm"), 24 / btnScale)
    cancelBtn:setScale(btnScale)
    sureBtn:setScale(btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(cancelBtn)
    menuArr:addObject(sureBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(0, 0)
    self.bgLayer:addChild(btnMenu)
    cancelBtn:setPosition(self.bgSize.width / 2 - 80 - cancelBtn:getContentSize().width * cancelBtn:getScale() / 2, 60)
    sureBtn:setPosition(self.bgSize.width / 2 + 80 + sureBtn:getContentSize().width * sureBtn:getScale() / 2, 60)

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function smallDialog:showEnergySupplementDialog(layerNum, callback)
    local sd = smallDialog:new()
    sd:initEnergySupplementDialog(layerNum, callback)
end

function smallDialog:initEnergySupplementDialog(layerNum, callback)
    self.layerNum = layerNum
    self.isUseAmi = true
    self.bgSize = CCSizeMake(550, 370)

    self.dialogLayer = CCLayer:create()
    local function closeFunc()
        if self.overDayEventListener then
            eventDispatcher:removeEventListener("overADay", self.overDayEventListener)
            self.overDayEventListener = nil
        end
        self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgLayer = G_getNewDialogBg(self.bgSize, getlocal("energySupplementText"), 35, nil, layerNum, true, closeFunc)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)

    if G_isToday(base.daily_buy_energy.ts) == false then
        base.daily_buy_energy.num = 0
    end
    local needGems = playerCfg.buyEnergyCost_normal * (base.daily_buy_energy.num + 1)
    local buyEnergyNum = playerCfg.buyAddEnergyNum_normal
    if base.he == 1 then
        needGems = playerCfg.buyEnergyCost_equip[(base.daily_buy_energy.num + 1)]
        buyEnergyNum = playerCfg.buyAddEnergyNum_equip
    end
    local refreshTipsLb, refreshGoldLb
    self.overDayEventListener = function()
    if G_isToday(base.daily_buy_energy.ts) == false then
            base.daily_buy_energy.num = 0
        end
        needGems = playerCfg.buyEnergyCost_normal * (base.daily_buy_energy.num + 1)
        buyEnergyNum = playerCfg.buyAddEnergyNum_normal
        if base.he == 1 then
            needGems = playerCfg.buyEnergyCost_equip[(base.daily_buy_energy.num + 1)]
            buyEnergyNum = playerCfg.buyAddEnergyNum_equip
        end
        if self then
            if tolua.cast(refreshTipsLb, "CCLabelTTF") then
                refreshTipsLb = tolua.cast(refreshTipsLb, "CCLabelTTF")
                refreshTipsLb:setString(getlocal("energySupplementTipsText", {buyEnergyNum}))
            end
            if tolua.cast(refreshGoldLb, "CCLabelTTF") then
                refreshGoldLb = tolua.cast(refreshGoldLb, "CCLabelTTF")
                refreshGoldLb:setString(tostring(needGems))
            end
        end
    end
    if eventDispatcher:hasEventHandler("overADay", self.overDayEventListener) == false then
        eventDispatcher:addEventListener("overADay", self.overDayEventListener)
    end
    local tipsLb = GetTTFLabelWrap(getlocal("energySupplementTipsText", {buyEnergyNum}), 24, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    tipsLb:setAnchorPoint(ccp(0.5, 1))
    tipsLb:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 70))
    self.bgLayer:addChild(tipsLb)
    refreshTipsLb = tipsLb

    local showItem = {p={{p4949=0,index=1}},u={{gem=playerVoApi:getGems(),index=2}}}
    local itemTb = FormatItem(showItem, nil, true)
    for k, v in pairs(itemTb) do
        if k == 1 then
            v.num = bagVoApi:getItemNumId(v.id)
        end
        local function showNewPropDialog()
            G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
        end
        local iconSize = 100
        local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, showNewPropDialog)
        icon:setAnchorPoint(ccp(0.5, 0.5))
        icon:setScale(iconSize / icon:getContentSize().height)
        scale = icon:getScale()
        icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
        icon:setPosition(ccp(self.bgSize.width / 2 + ((k == 1) and -1 or 1) * 120, tipsLb:getPositionY() - tipsLb:getContentSize().height - 10 - iconSize / 2))
        self.bgLayer:addChild(icon)
        local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 20)
        local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
        numBg:setAnchorPoint(ccp(0, 1))
        numBg:setRotation(180)
        numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
        numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
        numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
        icon:getParent():addChild(numBg)
        numLb:setAnchorPoint(ccp(1, 0))
        numLb:setPosition(numBg:getPosition())
        icon:getParent():addChild(numLb)

        local usePropNum = 1
        if k == 1 then
            local editBox, editBoxLb
            local editBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png", CCRect(10, 10, 5, 5), function()
                if editBox then
                    editBox:setText(editBoxLb:getString())
                    editBox:setVisible(true)
                end
            end)
            editBoxBg:setContentSize(CCSizeMake(editBoxBg:getContentSize().width, editBoxBg:getContentSize().height))
            editBoxBg:setAnchorPoint(ccp(0.5, 1))
            editBoxBg:setPosition(ccp(icon:getPositionX(), icon:getPositionY() - iconSize / 2 - 10))
            if v.num > 0 then
                editBoxBg:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
            end
            self.bgLayer:addChild(editBoxBg)
            editBoxLb = GetTTFLabel(tostring(usePropNum), 25)
            editBoxLb:setAnchorPoint(ccp(0.5, 0.5))
            editBoxLb:setPosition(ccp(editBoxBg:getContentSize().width / 2, editBoxBg:getContentSize().height / 2))
            editBoxBg:addChild(editBoxLb)
            if v.num > 0 then
                local function editBoxCallback(fn, eB, str, ebType, tag)
                    editBoxLb:setVisible(false)
                    if ebType == 1 then  --检测文本内容变化
                        if str == "" then
                            editBoxLb:setString(tostring(usePropNum))
                            do return end
                        end
                        local strNum = tonumber(str)
                        if strNum == nil then
                            -- eB:setText(tostring(usePropNum))
                        else
                            if strNum <= 1 then
                                usePropNum = 1
                                eB:setText("1")
                            elseif strNum >= 1 and strNum <= v.num then
                                usePropNum = strNum
                                eB:setText(strNum)
                            elseif strNum > v.num then
                                eB:setText(tostring(v.num))
                                usePropNum = v.num
                            else
                                eB:setText(str)
                            end
                        end
                        editBoxLb:setString(tostring(usePropNum))
                    elseif ebType == 2 then --检测文本输入结束
                        eB:setVisible(false)
                        editBoxLb:setVisible(true)
                    end
                end
                local editBoxSp = LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png", CCRect(10, 10, 5, 5), function()end)
                editBox = CCEditBox:createForLua(editBoxBg:getContentSize(), editBoxSp, nil, nil, editBoxCallback)
                editBox:setAnchorPoint(ccp(0.5, 1))
                editBox:setPosition(ccp(editBoxBg:getPosition()))
                if G_isIOS() == true then
                    editBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
                else
                    editBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
                end
                editBoxSp:setVisible(false)
                editBox:setVisible(false)
                self.bgLayer:addChild(editBox)
            end
            local subBtn, addBtn
            if v.num > 0 then
                local function onClickSubOrAdd(tempValue)
                    usePropNum = usePropNum + tempValue
                    if usePropNum < 1 then
                        usePropNum = 1
                    end
                    if usePropNum > v.num then
                        usePropNum = v.num
                    end
                    editBoxLb:setString(tostring(usePropNum))
                end
                subBtn = LuaCCSprite:createWithSpriteFrameName("sYellowSubBtn.png", function() onClickSubOrAdd(-1) end)
                addBtn = LuaCCSprite:createWithSpriteFrameName("sYellowAddBtn.png", function() onClickSubOrAdd(1) end)
                subBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
                addBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
            else
                subBtn = GraySprite:createWithSpriteFrameName("sYellowSubBtn.png")
                addBtn = GraySprite:createWithSpriteFrameName("sYellowAddBtn.png")
            end
            subBtn:setScale(0.8)
            subBtn:setAnchorPoint(ccp(1, 0.5))
            subBtn:setPosition(ccp(editBoxBg:getPositionX() - editBoxBg:getContentSize().width / 2 - 10, editBoxBg:getPositionY() - editBoxBg:getContentSize().height / 2))
            self.bgLayer:addChild(subBtn)
            addBtn:setScale(0.8)
            addBtn:setAnchorPoint(ccp(0, 0.5))
            addBtn:setPosition(ccp(editBoxBg:getPositionX() + editBoxBg:getContentSize().width / 2 + 10, editBoxBg:getPositionY() - editBoxBg:getContentSize().height / 2))
            self.bgLayer:addChild(addBtn)
        else
            local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
            local goldLb = GetTTFLabel(tostring(needGems), 22)
            local goldWidth = goldSp:getContentSize().width + goldLb:getContentSize().width
            local goldHeight = (goldSp:getContentSize().height > goldLb:getContentSize().height) and goldSp:getContentSize().height or goldLb:getContentSize().height
            goldSp:setAnchorPoint(ccp(0, 0.5))
            goldLb:setAnchorPoint(ccp(0, 0.5))
            goldSp:setPosition(ccp(icon:getPositionX() - goldWidth / 2, icon:getPositionY() - iconSize / 2 - 20 - goldHeight / 2))
            goldLb:setPosition(ccp(goldSp:getPositionX() + goldSp:getContentSize().width, goldSp:getPositionY()))
            self.bgLayer:addChild(goldSp)
            self.bgLayer:addChild(goldLb)
            refreshGoldLb = goldLb
        end

        local function onClickButton(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if tag == 1 then
                if v.num <= 0 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newTech_pNotEnought"),30)
                    do return end
                end
                if usePropNum < 1 then
                    do return end
                end
                local function userPropCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if type(callback) == "function" then
                            callback()
                        end
                        closeFunc()
                    end
                end
                if usePropNum > 1 then
                    socketHelper:useProc(v.id, nil, userPropCallback, nil, nil, usePropNum)
                else
                    socketHelper:useProc(v.id, nil, userPropCallback)
                end
            elseif tag == 2 then
                G_buyEnergy(self.layerNum + 1, nil, function()
                    if type(callback) == "function" then
                        callback()
                    end
                    closeFunc()
                end)
            end
        end
        local btnStr, btnPic1, btnPic2
        if k == 1 then
            btnStr = getlocal("super_weapon_rob_prop_add_energy_btn")
            btnPic1, btnPic2 = "newGreenBtn.png", "newGreenBtn_down.png"
        else
            btnStr = getlocal("super_weapon_rob_gold_add_energy_btn")
            btnPic1, btnPic2 = "creatRoleBtn.png", "creatRoleBtn_Down.png"
        end
        local btnScale = 0.8
        local button = GetButtonItem(btnPic1, btnPic2, btnPic1, onClickButton, k, btnStr, 24 / btnScale)
        local buttonMenu = CCMenu:createWithItem(button)
        buttonMenu:setPosition(ccp(0, 0))
        buttonMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        self.bgLayer:addChild(buttonMenu)
        button:setScale(btnScale)
        button:setAnchorPoint(ccp(0.5, 1))
        button:setPosition(ccp(icon:getPositionX(), icon:getPositionY() - iconSize / 2 - 65))
        if k == 1 and v.num <= 0 then
            button:setEnabled(false)
        end
    end
end