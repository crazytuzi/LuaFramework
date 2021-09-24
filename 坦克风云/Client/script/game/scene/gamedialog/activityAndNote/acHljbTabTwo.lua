acHljbTabTwo={}
function acHljbTabTwo:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent    = parent
	nc.bgLayer   = nil
	nc.isIphone5 = G_isIphone5()
	nc.showExAwardTb = acHljbVoApi:getShowExChangeAward()
	return nc
end
function acHljbTabTwo:dispose( )
	self.point         = nil
	self.showExAwardTb = nil
	self.bgLayer       = nil
	self.parent        = nil
	self.isIphone5     = nil
end
function acHljbTabTwo:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	
	self.cellNum = SizeOfTable(self.showExAwardTb)
	self.point = acHljbVoApi:getCurPoint()
	self:initUpPanel()
	self:initDownPanel()

	return self.bgLayer
end

function acHljbTabTwo:initUpPanel( )
	-- 去渐变线
	local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,1))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-160))
    panelBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160)
    self.bgLayer:addChild(panelBg)

	local topBorder = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function() end)
	self.bgLayer:addChild(topBorder,1)
	topBorder:setAnchorPoint(ccp(0.5,1))
	topBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth,85))
	topBorder:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight-160))


	local descStr1=acHljbVoApi:getAcTime( )
    local descStr2=acHljbVoApi:getExTime()
    local addposy = G_isIOS() and 0 or 3
    local moveBgStarStr,timeLb1,timeLb2=G_LabelRollView(CCSizeMake(self.bgLayer:getContentSize().width,46 + addposy),descStr1,25,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil,true)
    self.timeLb1=timeLb1
    self.timeLb2=timeLb2
    moveBgStarStr:setPosition(ccp(0,self.bgLayer:getContentSize().height-moveBgStarStr:getContentSize().height-180))
    self.bgLayer:addChild(moveBgStarStr,999)

    local function showInfo()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acHljbVoApi:showInfoTipTb(self.layerNum + 1,acHljbVoApi:getTabTwoTipTb())
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(topBorder:getContentSize().width - 10,topBorder:getContentSize().height - 10))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	topBorder:addChild(infoBtn,3)

	local strSize2 = G_isAsia() and 22 or 19
	local subHeight = 35
	local usePosY22 = topBorder:getContentSize().height * 0.5 - subHeight

	local pointLb = GetTTFLabel(getlocal("serverwar_my_point"),strSize2,true)
	pointLb:setAnchorPoint(ccp(1,0.5))
	pointLb:setPosition(topBorder:getContentSize().width * 0.5, usePosY22)
	topBorder:addChild(pointLb)

	local tipIcon = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
    tipIcon:setAnchorPoint(ccp(0,0.5))
    tipIcon:setPosition(topBorder:getContentSize().width * 0.5 ,usePosY22)
    topBorder:addChild(tipIcon)

    local pointStr = GetTTFLabel(acHljbVoApi:getCurPoint(),strSize2,true)
    pointStr:setAnchorPoint(ccp(0,0.5))
    pointStr:setPosition(topBorder:getContentSize().width * 0.5 + tipIcon:getContentSize().width + 2,usePosY22)
    topBorder:addChild(pointStr)
    self.pointStr = pointStr
end

function acHljbTabTwo:initDownPanel()
	self.tvWidth,self.tvHeight = G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 260 - 25
	self.cellHeight = 120
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(10,25))
    self.bgLayer:addChild(tvBg)


    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth - 8,self.tvHeight - 6),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(14,28))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end
function acHljbTabTwo:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight) 
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local strSize2 = G_isAsia() and 20 or 18
        local awardData = self.showExAwardTb[idx + 1]
        local awardTb = awardData.reward

        local icon,scale = G_getItemIcon(awardTb,90,false,self.layerNum)
        cell:addChild(icon)
        icon:setAnchorPoint(ccp(0,1))
        icon:setPosition(15,self.cellHeight - 15)

        local numLb = GetTTFLabel("x" .. FormatNumber(awardTb.num),20)
        numLb:setAnchorPoint(ccp(1,0))
        icon:addChild(numLb,4)
        numLb:setPosition(icon:getContentSize().width-5, 5)
        numLb:setScale(1/scale)

        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        numBg:setAnchorPoint(ccp(1,0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
        numBg:setOpacity(150)
        icon:addChild(numBg,3)

        local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
        nameBg:setContentSize(CCSizeMake(350,28))
        nameBg:setAnchorPoint(ccp(0,1))
        nameBg:setPosition(110,self.cellHeight - 15)
        cell:addChild(nameBg)

        local titleLb = GetTTFLabel(awardTb.name,strSize2,true)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setColor(G_ColorYellowPro2)
        titleLb:setPosition(15,nameBg:getContentSize().height * 0.5)
        nameBg:addChild(titleLb)

        local exNumLb = GetTTFLabel(getlocal("super_weapon_challenge_troops_schedule",{awardData.hadExNum or 0,awardData.limit}),strSize2,true)
        if awardData.endEx then
	        exNumLb:setColor(G_ColorRed)
	    end
        exNumLb:setAnchorPoint(ccp(0,0.5))
        exNumLb:setPosition(titleLb:getContentSize().width + 18,titleLb:getPositionY())
        nameBg:addChild(exNumLb)

        local descStr2 = G_formatStr(awardTb)
        local descLb = GetTTFLabelWrap(descStr2,strSize2 - 3,CCSizeMake(360,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLb:setAnchorPoint(ccp(0,1))
        descLb:setPosition(110,self.cellHeight - 55)
        cell:addChild(descLb)

        -----------------------------------e x c h a n g e ---- b t n------------------------------------------
        -- print("endEx--->>>",awardData.endEx)
        if not awardData.endEx then-- 还可以兑换
		        local function exCallBack()
		        	if G_checkClickEnable()==false then
			            do return end
			        else
			            base.setWaitTime=G_getCurDeviceMillTime()
			        end
			        PlayEffect(audioCfg.mouseClick)

			        if acHljbVoApi:getCurPoint( ) < awardData.price then
			            acHljbVoApi:showbtnTip(getlocal"activity_smbd_prompt")
			            do return end
			        end

			        local function exEndCall(getAwardTb)
			        	G_addPlayerAward(getAwardTb.type,getAwardTb.key,getAwardTb.id,getAwardTb.num,nil,true)
			        	G_showRewardTip({getAwardTb},true)
			        	self:refreshData()
			        end
			    	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
			        local titleStr = getlocal("code_gift")
			        local curT = acHljbVoApi:getCurDay( )
			        local needTb = {"hljbEx",titleStr,awardData,exEndCall,curT}
			        local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
			        sd:init()
		        end
		        local exItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",exCallBack,nil,getlocal("code_gift"),34)
		        exItem:setAnchorPoint(ccp(0.5,1))
		        exItem:setScale(0.6)
		        local exBtn=CCMenu:createWithItem(exItem)
		        exBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		        exBtn:setPosition(self.tvWidth - exItem:getContentSize().width * 0.4,self.cellHeight * 0.5 - 5)
		        cell:addChild(exBtn)

		        if not acHljbVoApi:isExTime() then
		        	exItem:setEnabled(false)
		        end

		        local useBtnPosx = exBtn:getPositionX() + 10

		        local tipIcon = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
			    tipIcon:setAnchorPoint(ccp(1,0.5))
			    tipIcon:setPosition(useBtnPosx,self.cellHeight * 0.5 + 25)
			    cell:addChild(tipIcon)
			    tipIcon:setScale(0.7)
			    local curNeedPrice = GetTTFLabel(awardData.price,20,true)
			    if self.point < awardData.price then
			    	curNeedPrice:setColor(G_ColorRed)
			    end
			    curNeedPrice:setAnchorPoint(ccp(0,0.5))
			    curNeedPrice:setPosition(useBtnPosx + 2,self.cellHeight * 0.5 + 25)
			    cell:addChild(curNeedPrice)

		else
			local exNumOverLb = GetTTFLabel(getlocal("activity_hljb_exNumOver"),22,true)
			exNumOverLb:setAnchorPoint(ccp(0.5,1))
			exNumOverLb:setColor(G_ColorGray)
			exNumOverLb:setPosition(self.tvWidth - 70,self.cellHeight * 0.5 - 5)
			cell:addChild(exNumOverLb)
		end
        ------------------------------------------------------------------------------------------
        local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
        bottomLine:setContentSize(CCSizeMake(self.tvWidth - 10,bottomLine:getContentSize().height))
        bottomLine:setRotation(180)
        bottomLine:setPosition(ccp(self.tvWidth * 0.5, 0))
        cell:addChild(bottomLine,1)
        return cell
    end
end
function acHljbTabTwo:refreshData( )
	self.point = acHljbVoApi:getCurPoint()
	self.showExAwardTb = acHljbVoApi:getShowExChangeAward()
	if self.pointStr then
		self.pointStr:setString(self.point)
	end
	if self.tv then
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end
function acHljbTabTwo:tick( )

	local acVo=acHljbVoApi:getAcVo()
    if(acVo and self.timeLb1 and tolua.cast(self.timeLb1,"CCLabelTTF"))then
        self.timeLb1:setString(acHljbVoApi:getAcTime())
        self.timeLb2:setString(acHljbVoApi:getExTime())
    end
end