banSmallDialog=smallDialog:new()

function banSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function banSmallDialog:showBanInfo(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler,type)
	local sd=banSmallDialog:new()
	sd:initBanInfo(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler,type)
end

function banSmallDialog:initBanInfo(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler,type)
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
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    
    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 = 28
    end
    if content then
    	local startTimeStr=getlocal("ban_startTime",{G_getDataTimeStr(content[1])})
    	local endTimeStr=getlocal("ban_endTime",{G_getDataTimeStr(content[2])})
    	local reasonStr
        if(tonumber(content[3])==0)then
            if(content[4])then
                reasonStr=content[4]
            else
                reasonStr=getlocal("ban_reason1")
            end
        else
            reasonStr=getlocal("ban_reason" .. (content[3] or 1))
        end
    	print(startTimeStr)
    	local tb={
    				{str=reasonStr,y=size.height-70-60,align=kCCTextAlignmentLeft},
    				{str=startTimeStr,y=size.height-70-140,align=kCCTextAlignmentCenter},
    				{str=endTimeStr,y=size.height-70-180,align=kCCTextAlignmentCenter}
    				
  				  }
  			for k,v in pairs(tb) do
				local contentLb=GetTTFLabelWrap(v.str,strSize2,CCSize(size.width-100,0),v.align,kCCVerticalTextAlignmentCenter)
				contentLb:setAnchorPoint(ccp(0.5,0.5))
				contentLb:setPosition(ccp(size.width/2,v.y))
				dialogBg:addChild(contentLb)
				if lbColor[k]~=nil then
					contentLb:setColor(lbColor[k])
				end
  			end
    end
                    
    -- local contentLb=GetTTFLabelWrap(content,28,CCSize(size.width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- contentLb:setAnchorPoint(ccp(0.5,0.5))
    -- contentLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-contentLb:getContentSize().height/2-70))
    -- dialogBg:addChild(contentLb)
    -- if lbColor~=nil then
    --     contentLb:setColor(lbColor)
    -- end
    
    --确定
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler()
         end
         self:close()
    end

    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancleHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,70))
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