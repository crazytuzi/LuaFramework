acTacticalDiscussSmallDialog=smallDialog:new()

function acTacticalDiscussSmallDialog:new(layerNum,id)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.id = id 
	self.layerNum=layerNum
	return nc
end

-- 默认 消费送礼   1.充值送礼 2.单日消费 3.单日充值
function acTacticalDiscussSmallDialog:init(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,textTab,textSize,textColorTab,title,isUseSize, isRichLabel)
	local strSize2 = 22
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
		strSize2 =textSize
	end
    self.isTouch=istouch
    self.isUseAmi=isuseami
      local function tmpFunc()
      
      end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    
-- 计算lable     
    local sizeLb=0;
    -- activity_zhanshuyantao_tip1
    local textWrapNum = (size.width-textSize)/textSize

    
    for k,v in pairs(textTab) do
        local textWidth = 450
        if isUseSize~=nil and isUseSize == true then
            textWidth = size.width - 40
        end
        local lable=nil
        local purStr = nil
        local sizeLable = nil
        if isRichLabel~=nil then
          -- 返回label和纯字符串（计算label的height）
          lable ,purStr = getRichLabel(v,strSize2,CCSize(textWidth,0))
          sizeLable = GetTTFLabelWrap(purStr,strSize2,CCSize(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        else        
          lable = GetTTFLabelWrap(v,strSize2,CCSize(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
          sizeLable = lable
        end
        if textColorTab~=nil then
            if textColorTab[k]~= nil then
                lable:setColor(textColorTab[k])
            else
                lable:setColor(G_ColorWhite)   
            end
        end
        lable:setAnchorPoint(ccp(0,0));
        if isRichLabel~=nil then
          lable:setPosition(ccp(30,sizeLb+490+sizeLable:getContentSize().height));
        else
          lable:setPosition(ccp(30,sizeLb+490));
        end
        self.bgLayer:addChild(lable,2);
        sizeLb = sizeLb+sizeLable:getContentSize().height;
        print(sizeLb)

    end    

    if title~=nil and title ~= "" then

        local titleLb = GetTTFLabel(title, 30)
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(250, sizeLb+510))
        self.bgLayer:addChild(titleLb)

        local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSprite:setPosition(ccp(250,sizeLb+490))
        self.bgLayer:addChild(lineSprite,2)
        lineSprite:setScaleX(500/lineSprite:getContentSize().width)
        sizeLb=sizeLb
    end
    print(sizeLb)
    local bgLayerSize =CCSizeMake(500,sizeLb+50+500)
    if isUseSize~=nil and isUseSize == true then
        bgLayerSize =CCSizeMake(size.width,sizeLb+50)
    end
    self.bgLayer:setContentSize(bgLayerSize)

    -- local fiveStr = GetTTFLabel("5.",25)
    -- fiveStr:setAnchorPoint(ccp(0,0))
    -- fiveStr:setPosition(ccp(30,self.bgLayer:getContentSize().width-30))
    -- self.bgLayer:addChild(fiveStr,1) 

    local needRewardTb = acTacticalDiscussVoApi:formatNeedReward(self.layerNum)
    for k,v in pairs(needRewardTb) do

    	local heightPos = self.bgLayer:getContentSize().width-30-(k-1)*70
    	local bigAwardPic = CCSprite:createWithSpriteFrameName("serverWarTopMedal1.png")
        bigAwardPic:setPosition(ccp(80,heightPos))
        self.bgLayer:addChild(bigAwardPic,1)
        local idx = k-1
        local idxStr = GetTTFLabel("x"..idx,25)
        idxStr:setAnchorPoint(ccp(1,0))
        idxStr:setPosition(ccp(145,heightPos-15))
        self.bgLayer:addChild(idxStr,1)

		local dengyuStr = GetTTFLabel("=",25)
        dengyuStr:setAnchorPoint(ccp(1,0))
        dengyuStr:setPosition(ccp(175,heightPos-10))
        self.bgLayer:addChild(dengyuStr,1)        

    	for i,j in pairs(v) do
            -- G_getItemIcon(j,65,true,layerNum)
    		local awardPic = G_getItemIcon(j,65,true,self.layerNum)

	        awardPic:setPosition(ccp(210+(i-1)*80,heightPos))
	        self.bgLayer:addChild(awardPic,1)

	        local iconNum = j.num
	        local iconLabel = GetTTFLabel("x"..iconNum,25)
            iconLabel:setAnchorPoint(ccp(1,0))
            iconLabel:setPosition(ccp(awardPic:getContentSize().width-4,4))
            awardPic:addChild(iconLabel,1)
    	end
    end



     self:show()
        local function touchDialog()
            if self.isTouch~=nil then
                PlayEffect(audioCfg.mouseClick)
                self:close()
            end
          
        end
        local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(180)
        touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
        self.dialogLayer:addChild(touchDialogBg,1);
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    return self.dialogLayer
end

function acTacticalDiscussSmallDialog:dispose()
	self.id = nil
	self.checkSp = nil
	self.item = nil
	self.lotsAward=nil
end