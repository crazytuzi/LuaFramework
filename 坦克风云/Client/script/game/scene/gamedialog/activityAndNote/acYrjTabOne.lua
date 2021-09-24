acYrjTabOne={}
function acYrjTabOne:new(parent)
	local nc={
        detailCfg = {-17,14,-58,55,21},
        specialProp = acYrjVoApi:getSpecialProp()
    }
	setmetatable(nc,self)
	self.__index=self
	nc.parent=parent

	nc.isIphone4 = G_getIphoneType() == G_iphone4 and true or false --G_iphone4
    nc.url       = G_downloadUrl("active/acYrjBg.jpg") or nil
	nc.lotteryBtn = nil
	nc.freeBtn    = nil
	nc.multiLotteryBtn = nil
	nc.isTodayFlag     = acYrjVoApi:isToday()
	return nc
end
function acYrjTabOne:dispose( )
	self.lotteryBtn = nil
	self.freeBtn    = nil
	self.multiLotteryBtn = nil
	if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
end
function acYrjTabOne:init(layerNum)
	if G_isIphone5() then
		self.isIphone5 = true
	end
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	
	self:initTouchDia()
	self:initUp()
	self:initDown()
	return self.bgLayer
end

function acYrjTabOne:initUp( )
	self.upPosY,self.upHeight = G_VisibleSizeHeight-160,G_VisibleSizeHeight * 0.2
	self.bgWidth = self.bgLayer:getContentSize().width-40
    local adaH = 0
	local strSize2 = G_isAsia() and 23 or 20
    if G_getCurChoseLanguage() == "ko" then
        strSize2 = 18
        if  G_isIOS() == false then
            adaH = -5
            strSize2 = 14       
        end
    elseif G_isAsia() == false then
        if G_isIOS() then
            adaH = 10
        else
            adaH = -10
        end
    end
	local upBG = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    upBG:setContentSize(CCSizeMake(self.bgWidth,self.upHeight))
    upBG:setAnchorPoint(ccp(0.5,1))
    upBG:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
    self.bgLayer:addChild(upBG)

    local realBg=CCSprite:createWithSpriteFrameName("goldAndTankBg_2.jpg")
	realBg:setPosition(getCenterPoint(upBG))
	upBG:addChild(realBg)
	realBg:setScaleX(upBG:getContentSize().width/realBg:getContentSize().width)
	realBg:setScaleY(upBG:getContentSize().height/realBg:getContentSize().height)

    local timeStrSize = G_isAsia() and 24 or 21
    local acLabel = GetTTFLabel(acYrjVoApi:getTimer(),24,"Helvetica-bold")
    acLabel:setPosition(ccp(self.bgWidth *0.5, self.upHeight - 30))
    upBG:addChild(acLabel,1)
    acLabel:setColor(G_ColorYellowPro)
    self.timeLb=acLabel
    self:addStrBg(upBG,acLabel)

    local giveShownNum = acYrjVoApi:getRechargeSendShown()
    local addPosy = self.isIphone4 == true and 25 or 0
    
    local upTipStr = GetTTFLabel(getlocal("activity_yrj_tab1_rechargeTip1",{acYrjVoApi:getRechargeNum(),giveShownNum,self.specialProp}),strSize2-1,"Helvetica-bold")
    local tipWidth,tipHeight = upTipStr:getContentSize().width,upTipStr:getContentSize().height
    for i=1,4 do
        local colorTab={nowColor,G_ColorYellowPro,nowColor,G_ColorYellowPro,nowColor}
        local upTipStr = G_getRichTextLabel(getlocal("activity_yrj_tab1_rechargeTip1",{acYrjVoApi:getRechargeNum(),giveShownNum,self.specialProp}),colorTab,strSize2-1,self.bgWidth-40,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,0,true)    
            -- local upTipStr = GetTTFLabel(getlocal("activity_yrj_tab1_rechargeTip1",{acYrjVoApi:getRechargeNum()}),strSize2-1,"Helvetica-bold")
        upTipStr:setPosition(ccp(self.bgWidth *0.5, self.upHeight - 75 + addPosy + adaH))
        upBG:addChild(upTipStr,1)
        if i == 1 and G_isAsia() then
            self:addStrBg(upBG,upTipStr,nil,tipWidth,tipHeight)
        end
    end

    local downTipStr = GetTTFLabel(getlocal("activity_yrj_tab1_rechargeTip2",{acYrjVoApi:needRechargeNum(),giveShownNum,self.specialProp}),strSize2-2,"Helvetica-bold")
    downTipStr:setPosition(ccp(self.bgWidth *0.5, 20))
    upBG:addChild(downTipStr,1)
    self.downTipStr = downTipStr
    self:addStrBg(upBG,downTipStr,true)    

    local function rechargeHandler(tag,object)
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		--跳转至充值页面
        vipVoApi:showRechargeDialog(self.layerNum+1)
	end

	local rechargeBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rechargeHandler,0,getlocal("new_recharge_recharge_now"),28)
	local menuRecharge=CCMenu:createWithItem(rechargeBtn)
	menuRecharge:setPosition(ccp(self.bgWidth *0.5,self.upHeight * 0.35))
	menuRecharge:setTouchPriority(-(self.layerNum-1)*20-3)
	upBG:addChild(menuRecharge,1)
    local ip4Scale = self.isIphone4 == true and 0.4 or 0
	rechargeBtn:setScale((self.upHeight - 160)/rechargeBtn:getContentSize().height + ip4Scale)
    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={}
        table.insert(tabStr,getlocal("activity_yrj_tab1_tip1",{acYrjVoApi:getRechargeNum(),acYrjVoApi:getRechargeSendShown( ),acYrjVoApi:getSpecialProp()}))
        for i=2,4 do
            if i == 2 then
            table.insert(tabStr,getlocal("activity_yrj_tab1_tip"..i,{self.specialProp}))
            elseif i == 3 then
            table.insert(tabStr,getlocal("activity_yrj_tab1_tip"..i)) 
            elseif i == 4 then
            table.insert(tabStr,getlocal("activity_yrj_tab1_tip"..i,{self.specialProp})) 
            end
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(self.bgWidth-10, self.upHeight - 10))
    upBG:addChild(menuDesc,2)
end

function acYrjTabOne:initDown( )
	self.downPosY,self.downHeight = G_VisibleSizeHeight-160 - self.upHeight,G_VisibleSizeHeight - G_VisibleSizeHeight * 0.2 - 170
	local strSize2 = G_isAsia() and 23 or 20
	local downTipPosY,btnPosY = 125,60
	if self.isIphone4 then
		downTipPosY,btnPosY = 95,40
	end
	local downBG = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    downBG:setContentSize(CCSizeMake(self.bgWidth,self.downHeight))
    downBG:setAnchorPoint(ccp(0.5,1))
    downBG:setPosition(G_VisibleSizeWidth * 0.5,self.downPosY)
    self.bgLayer:addChild(downBG)

    self:initCurtain(downBG)    
    self:initAwardAndRecord(downBG)
    self:initHxTip(downBG,downTipPosY,strSize2)

	local cost1,cost2=acYrjVoApi:getLotteryCost()
    local function lotteryHandler()
        self:lotteryHandler()
    end
    self.freeBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth * 0.5 - 140,btnPosY),lotteryHandler)
    self.lotteryBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth * 0.5 - 140,btnPosY),lotteryHandler,cost1)

    local function multiLotteryHandler()
        self:lotteryHandler(true)
    end
    local num=acYrjVoApi:getMultiNum()
    self.multiLotteryBtn=self:getLotteryBtn(num,ccp(G_VisibleSizeWidth * 0.5 + 140,btnPosY),multiLotteryHandler,cost2,true)
    self:refreshLotteryBtn()
    self:tick()
end
function acYrjTabOne:initCurtain(downBG)
    --self.bgWidth,self.downHeight

    local downSp = CCSprite:createWithSpriteFrameName("acYrjBottomBg.png")
    downSp:setAnchorPoint(ccp(0.5,0))
    downSp:setPosition(ccp(self.bgWidth * 0.5,0))
    downSp:setScaleX(self.bgWidth/downSp:getContentSize().width)
    downSp:setScaleY(self.downHeight * 0.3/downSp:getContentSize().height)
    downBG:addChild(downSp,2)

    local function onLoadIcon(fn,icon)
        icon:setAnchorPoint(ccp(0.5,1))
        downBG:addChild(icon)
        icon:setPosition(ccp(self.bgWidth * 0.5,self.downHeight-3))
        icon:setScaleY(self.downHeight * 0.9/icon:getContentSize().height)
        icon:setScaleX((self.bgWidth-4)/icon:getContentSize().width)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

--darkOval
    local gBox1 = CCSprite:createWithSpriteFrameName("greenBoxBorder2.png")
    gBox1:setPosition(ccp(self.bgWidth * 0.5,self.downHeight * 0.45))
    downBG:addChild(gBox1,2)
    self.gBox = gBox1

    local darkOval = CCSprite:createWithSpriteFrameName("darkOval.png")
    darkOval:setPosition(ccp(self.bgWidth * 0.5,self.downHeight * 0.45 - gBox1:getContentSize().height * 0.35))
    downBG:addChild(darkOval,1)

    local gBox2 = CCSprite:createWithSpriteFrameName("greenBoxBorder1.png")
    gBox2:setPosition(getCenterPoint(gBox1))
    gBox1:addChild(gBox2,2)

    local picSrc = "clown.png"
    local sAward = CCSprite:createWithSpriteFrameName(picSrc)
    self.sOldPos = ccp(gBox1:getContentSize().width * 0.5,gBox1:getContentSize().height * 0.7)
    self.sOldScale = (gBox1:getContentSize().width -40)/sAward:getContentSize().height
    sAward:setPosition(self.sOldPos)
    sAward:setScale(self.sOldScale)
    self.sAward = sAward
    gBox1:addChild(sAward,1)

    local gCover1 = CCSprite:createWithSpriteFrameName("greenCover1.png")
    gCover1:setPosition(ccp(gBox1:getContentSize().width * 0.5 + 10,gBox1:getContentSize().height - 10))
    gBox1:addChild(gCover1,2)
    self.gCover1 = gCover1

    local gCover2 = CCSprite:createWithSpriteFrameName("greenCover2.png")
    gCover2:setAnchorPoint(ccp(0,.5))
    gCover2:setPosition(ccp(gBox1:getContentSize().width - 25,gBox1:getContentSize().height - 40))
    gBox1:addChild(gCover2,5)
    self.gCover2 = gCover2

    self.sAward:setVisible(false)
    self.gCover2:setVisible(false)
end


function acYrjTabOne:getLotteryBtn(num,pos,callback,cost,isMul)
    local btnZorder,btnFontSize=2,25
    local function lotteryHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback()
        end
    end
    local lotteryBtn
    local btnScale=0.8
    if cost and tonumber(cost)>0 then
        local btnStr=getlocal("activity_qxtw_buy",{num})
        lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler,nil,btnStr,btnFontSize/btnScale,11)
        local costLb=GetTTFLabel(tostring(cost),25)
        costLb:setAnchorPoint(ccp(0,0.5))
        costLb:setColor(G_ColorYellowPro)
        costLb:setScale(1/btnScale)
        lotteryBtn:addChild(costLb)
        local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(0,0.5))
        costSp:setScale(1/btnScale)
        lotteryBtn:addChild(costSp)
        local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
        costLb:setPosition(lotteryBtn:getContentSize().width/2-lbWidth/2,lotteryBtn:getContentSize().height+costLb:getContentSize().height/2+10)
        costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())
    else
        lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",lotteryHandler,nil,getlocal("daily_lotto_tip_2"),btnFontSize/btnScale,11)
    end
    lotteryBtn:setScale(btnScale)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    lotteryMenu:setPosition(pos)
    self.bgLayer:addChild(lotteryMenu,btnZorder)

    return lotteryBtn
end

function acYrjTabOne:lotteryHandler(multiFlag,fromParent)
    local multiFlag=multiFlag or false
    local function realLottery(num,cost)
        local function callback(curAddScore,rewardlist,hxReward)
        	-- self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
            if rewardlist and type(rewardlist)=="table" then
                if hxReward then
                    table.insert(rewardlist,1,hxReward)
                end
                print("运行 动画~~~~~~~~")
                if not multiFlag then
                    self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
                    local function showAddCall()
                        G_showRewardTip(rewardlist,true)
                    end
                    self:showSingleAnimate(rewardlist[2],showAddCall)
                elseif self.parent and self.parent.runAwardAction then
                    self.parent.rewardList = rewardlist
                    self.parent.touchDia:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight * 0.5))
                    self.parent:runAwardAction(rewardlist)
                end
            end
            self.isTodayFlag = acYrjVoApi:isToday()
            self:refreshLotteryBtn()
        end
        local freeNeed = acYrjVoApi:getFirstFree()
        -- print("num----free----->",num,freeFlag)
        acYrjVoApi:acYrjRequest("draw",{num=num,free=freeNeed},callback)
    end

    local cost1,cost2=acYrjVoApi:getLotteryCost()
    local cost,num=0,1
    local freeNeed = acYrjVoApi:getFirstFree()
    if cost1 and cost2 then
        if multiFlag==false and freeNeed==1 then
            cost=cost1
        elseif multiFlag==true then
            cost=cost2
            num=acYrjVoApi:getMultiNum()
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+2,cost)
        do return end
    else
        local function sureClick()
            realLottery(num,cost)
        end
        local function secondTipFunc(sbFlag)
            local keyName=acYrjVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        if cost and cost>0 then
            local keyName=acYrjVoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
        else
            sureClick()
        end
    end
end

function acYrjTabOne:refreshLotteryBtn()
    if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn then
    	local isNotEnd=activityVoApi:isStart(acYrjVoApi:getAcVo())
        if isNotEnd then--acYrjVoApi:isEnd() ==false and acYrjVoApi:acIsStop() ==false then
            local freeNeed = acYrjVoApi:getFirstFree()
            if freeNeed == 0 or self.isTodayFlag == false then--免费 0
                self.lotteryBtn:setVisible(false)
                self.freeBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(false)
                if freeNeed == 1 then
                    acYrjVoApi:setFirstFree(0)
                end
            else
                self.freeBtn:setVisible(false)
                self.lotteryBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(true)
            end
        else
            self.lotteryBtn:setEnabled(false)
            self.freeBtn:setEnabled(false)
            self.lotteryBtn:setVisible(true)
            self.freeBtn:setVisible(false)
            self.multiLotteryBtn:setEnabled(false)
        end
    end
end
function acYrjTabOne:tick( )
	local isNotEnd=activityVoApi:isStart(acYrjVoApi:getAcVo())
	if isNotEnd then
		if self and self.timeLb then
          self.timeLb:setString(acYrjVoApi:getTimer( ))
        end
        if self.tipIcon then
            -- print("acYrjVoApi:getRechargeTip()=====>>>>",acYrjVoApi:getRechargeTip())
            self.tipIcon:setVisible(acYrjVoApi:getRechargeTip())
        end
        local todayFlag=acYrjVoApi:isToday()
        -- print("here????????",todayFlag)
        if self.isTodayFlag==true and todayFlag==false and acYrjVoApi:getFirstFree() ~= 0  then
            self.isTodayFlag=false
            acYrjVoApi:setFirstFree(0)
            --重置免费次数
            self:refreshLotteryBtn()
        end
    else
        self.lotteryBtn:setEnabled(false)
        self.freeBtn:setEnabled(false)
        self.lotteryBtn:setVisible(true)
        self.freeBtn:setVisible(false)
        self.multiLotteryBtn:setEnabled(false)
	end
end
function acYrjTabOne:initHxTip( pSp,posy,strSize2)
	local hxReward=acYrjVoApi:getHexieReward()
    if hxReward then
        local adaH = 0
        if G_getCurChoseLanguage() == "ko" then
            strSize2 = 18
            adaH = -10
        elseif G_isAsia() == false then
            adaH = G_isIOS () and -5 or -8
        end
        if G_getCurChoseLanguage() == "fr" then
            strSize2 = strSize2 - 3
        end
	    local promptLb=GetTTFLabelWrap(getlocal("activity_yrj_tab1_hxTip",{hxReward.name}),strSize2,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom,"Helvetica-bold")
	    promptLb:setAnchorPoint(ccp(0.5,0))
	    promptLb:setPosition(ccp(self.bgWidth * 0.5,posy + adaH))
	    promptLb:setColor(G_ColorYellowPro)
	    pSp:addChild(promptLb,2)
	end
end
function acYrjTabOne:addStrBg(parentSp,Str,isSpical,parentWidth,parentHeight )
	if isSpical then
		if not self.tipBg then
			local strBg=CCSprite:createWithSpriteFrameName("blackGradualChange.png")
			strBg:setScaleX((Str:getContentSize().width+6)/strBg:getContentSize().width)
			strBg:setScaleY((Str:getContentSize().height+6)/strBg:getContentSize().height)
			strBg:setPosition(ccp(Str:getPositionX(),Str:getPositionY()))
			parentSp:addChild(strBg)
			strBg:setOpacity(150)
			self.tipBg = strBg
		else
			self.tipBg:setScaleX((Str:getContentSize().width+6)/self.tipBg:getContentSize().width)
			self.tipBg:setScaleY((Str:getContentSize().height+6)/self.tipBg:getContentSize().height)
		end
	else
		local strBg=CCSprite:createWithSpriteFrameName("blackGradualChange.png")
        if parentWidth then
            strBg:setScaleX((parentWidth+6)/strBg:getContentSize().width)
            strBg:setScaleY((parentHeight+6)/strBg:getContentSize().height)
            strBg:setPosition(ccp(Str:getPositionX(),Str:getPositionY() - 15))
        else
    		strBg:setScaleX((Str:getContentSize().width+6)/strBg:getContentSize().width)
    		strBg:setScaleY((Str:getContentSize().height+6)/strBg:getContentSize().height)
            strBg:setPosition(ccp(Str:getPositionX(),Str:getPositionY()))
        end
		
		strBg:setOpacity(150)
		parentSp:addChild(strBg)
	end
end
function acYrjTabOne:initTouchDia( )
	local function touchDialog()
		print("touchDialog show~~~~~~~~~~~~~~~")
	end
	self.tDialogHeight = 80
	self.touchDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	self.touchDialog:setTouchPriority(-(self.layerNum-1)*20-99)
	self.touchDialog:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-self.tDialogHeight))
	self.touchDialog:setOpacity(0)
	self.touchDialog:setIsSallow(true) -- 点击事件透下去
	self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
	self.bgLayer:addChild(self.touchDialog,99)
end

function acYrjTabOne:initAwardAndRecord(pSp)
    --奖励库
    local function rewardPoolHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        --显示奖池
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local rewardTb = acYrjVoApi:getRewardPool()
        local function stopAcation( )
            self:bigAwardAction(tag,true)
        end 
        local titleStr,descStr = getlocal("award"),getlocal("activity_yrj_awardShowTip",{self.specialProp})
        local needTb = {"yrj",titleStr,descStr,rewardTb,SizeOfTable(rewardTb)}
        local bigAwardDia = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        bigAwardDia:init()
    end
    local poolBtn=GetButtonItem("taskBox5.png","taskBox5.png","taskBox5.png",rewardPoolHandler,11)
    poolBtn:setScale(0.8)
    poolBtn:setAnchorPoint(ccp(0,1))
    local poolMenu=CCMenu:createWithItem(poolBtn)
    poolMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    poolMenu:setPosition(ccp(20,self.downHeight - 10))
    pSp:addChild(poolMenu,2)
    local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    poolBg:setAnchorPoint(ccp(0.5,1))
    poolBg:setContentSize(CCSizeMake(80,40))
    poolBg:setPosition(ccp(poolBtn:getContentSize().width/2,5))
    poolBg:setScale(1/poolBtn:getScale())
    poolBtn:addChild(poolBg)
    local strSize3 = G_isAsia() and 22 or 20
    local poolLb=GetTTFLabelWrap(getlocal("award"),strSize3,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    poolLb:setPosition(poolBg:getContentSize().width/2,poolBg:getContentSize().height/2)
    poolBg:addChild(poolLb)

    local function logHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:logHandler()
    end
   
    local logBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",logHandler,11)
    logBtn:setAnchorPoint(ccp(1,1))
    logBtn:setScale(0.8)
    local logMenu=CCMenu:createWithItem(logBtn)
    logMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    logMenu:setPosition(ccp(pSp:getContentSize().width - 20,self.downHeight - 10))
    pSp:addChild(logMenu,2)
    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,0))
    logBg:setScale(1/logBtn:getScale())
    logBtn:addChild(logBg)
    local strSize4 = G_isAsia() and 22 or 20
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),strSize4,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logBg:addChild(logLb)


    if not self.tipIcon then
        self.tipIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17, 17, 1, 1),function( ) end)
        self.tipIcon:setPosition(ccp(logBtn:getContentSize().width - 10,logBtn:getContentSize().height - 10))
        logBtn:addChild(self.tipIcon,6)
        self.tipIcon:setScale(0.7)
    end

end
function acYrjTabOne:logHandler()
    print("show record~~~~~")
    local function showLog()
        local rewardLog=acYrjVoApi:getRewardLog() or {}
        local reLog = acYrjVoApi:getReLog()
        
        if ( rewardLog and SizeOfTable(rewardLog)>0 )or reLog then
            local logList={}
            for k,v in pairs(rewardLog) do
                local num,reward,time=v.num,v.reward,v.time
                local title = {getlocal("activity_yrj_tab1_logTab1_Tip",{num})}

                local content={{reward}}
                local log={title=title,content=content,ts=time}
                table.insert(logList,log)
            end
            local logNum=SizeOfTable(logList)
            local reLog = acYrjVoApi:getReLog()
            local acTb = {"yrj",reLog}
            require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
            acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_gangtieronglu_record_title"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true,acTb)
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
        end
    end
    local rewardLog=acYrjVoApi:getRewardLog()
    local reLog = acYrjVoApi:getReLog()
    
    if rewardLog and reLog then
        showLog()
    else
        acYrjVoApi:acYrjRequest("getlog",{},showLog)
    end
end

--version2 星星动画 
function acYrjTabOne:awardMove(i)

    -- 星星出现的时候要有层次感，既不要一次性全出，也不要相继而出
    local star = CCSprite:createWithSpriteFrameName(i.."_star.png")
    star:setAnchorPoint(ccp(0.5,0))
    star:setPosition(ccp(self.sAward:getPositionX(),self.sAward:getPositionY()-80))
    star:setOpacity(0)
    self.gBox:addChild(star)
    star:setTag(i)
    local acArr = CCArray:create()
    local fadeIn = CCFadeIn:create(0.025)  
    acArr:addObject(fadeIn)
    local acArr1 = CCArray:create()
    local acArr2 = CCArray:create()
    local rotate1 = CCRotateTo:create(0.025,self.detailCfg[i]/4)
    local moveTo1 = CCMoveBy:create(0.025,ccp(0,80/4))
    local rotate2 = CCRotateTo:create(0.025,self.detailCfg[i])
    local moveTo2 = CCMoveBy:create(0.025,ccp(0,80/4*3))
    acArr1:addObject(rotate1)
    acArr1:addObject(moveTo1)
    acArr2:addObject(rotate2)
    acArr2:addObject(moveTo2)
    local spawn1 = CCSpawn:create(acArr1)
    local spawn2 = CCSpawn:create(acArr2)
    acArr:addObject(spawn1)

    if i < 5 then
        local function midMoveCallBack()
            -- 迭代调用
            self:awardMove(i+1)
        end
        local midMoveCall = CCCallFuncN:create(midMoveCallBack)
        acArr:addObject(midMoveCall)
    end
    acArr:addObject(spawn2)

    if i == 5 then
        local function endMoveCallBack()
            local starBg = CCSprite:createWithSpriteFrameName("color_bar.png")
            starBg:setAnchorPoint(ccp(0.5,0.5))
            starBg:setPosition(ccp(self.sAward:getPositionX(),self.sAward:getPositionY()+90))
            self.gBox:addChild(starBg)
            starBg:setTag(6)
            starBg:setOpacity(0)
            local tempArr = CCArray:create()
            local fadeIn = CCFadeIn:create(0.25)
            local delay = CCDelayTime:create(0.8)
            local function endCallBack( ... )
                self:endAction()
            end
            local endCall = CCCallFuncN:create(endCallBack)
            tempArr:addObject(fadeIn)
            tempArr:addObject(delay)
            tempArr:addObject(endCall)
            local seq = CCSequence:create(tempArr)
            starBg:runAction(seq)
        end
        local endMoveCall = CCCallFuncN:create(endMoveCallBack)
        acArr:addObject(endMoveCall)
    end
    local seq = CCSequence:create(acArr)
    star:runAction(seq)
end

function acYrjTabOne:showSingleAnimate(outAward,showAddCall)

    self.showAddCall = showAddCall
    local deT = CCDelayTime:create(0.1)
    local function cCall( )
        self.gCover1:setVisible(false)
        self.gCover2:setVisible(true)
        local roTo = CCRotateTo:create(0.1, 30)
        self.gCover2:runAction(roTo)
    end 
    local coverCall = CCCallFuncN:create(cCall)
    local coverArr=CCArray:create()
    coverArr:addObject(deT)
    coverArr:addObject(coverCall)
    local Seq=CCSequence:create(coverArr)
    self.gCover1:runAction(Seq)   
    if outAward.type == "ac" then
        if acYrjVoApi:getVersion() == 1 then
            local deT2 = CCDelayTime:create(0.1)
            local function sAwardCall( )
                self.sAward:setVisible(true)
            end 
            local sAwardCall = CCCallFuncN:create(sAwardCall)
            local movUp = CCMoveTo:create(0.1,ccp(self.sAward:getPositionX(),self.sAward:getPositionY() + 75))
            local scalb = CCScaleTo:create(0.1,1)
            local awardArr=CCArray:create()
            local spaArr = CCArray:create()
            awardArr:addObject(deT2)
            awardArr:addObject(sAwardCall)

            spaArr:addObject(movUp)
            spaArr:addObject(scalb)
            local spawn1=CCSpawn:create(spaArr)
            awardArr:addObject(spawn1)

            local function endCall( )
                self:endAction()
            end 
            local endCCF = CCCallFuncN:create(endCall)
            local endT = CCDelayTime:create(0.8)
            awardArr:addObject(endT)
            awardArr:addObject(endCCF)
            local Seq=CCSequence:create(awardArr)
            self.sAward:runAction(Seq)
        else
            self:awardMove(1)    
        end
    else
        local icon,scale=G_getItemIcon(outAward,100,true,self.layerNum+1,function() end)
        -- icon:setAnchorPoint(ccp(0,0.5))
        -- icon:setTouchPriority(-(self.layerNum-1)*20-3)
        icon:setPosition(self.sOldPos)
        self.gBox:addChild(icon,1)
        icon:setVisible(false)
        icon:setScale(80/icon:getContentSize().width)

        local itemW=icon:getContentSize().width*scale
        local numLb=GetTTFLabel("x"..outAward.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(itemW-5,5))
        numLb:setScale(1/icon:getScale())
        icon:addChild(numLb,1)

        self.sIcon = icon

        local deT2 = CCDelayTime:create(0.1)
        local function sAwardCall( )
            self.sIcon:setVisible(true)
        end 
        local sAwardCall = CCCallFuncN:create(sAwardCall)
        local movUp = CCMoveTo:create(0.1,ccp(self.sIcon:getPositionX(),self.sIcon:getPositionY() + 75))
        local scalb = CCScaleTo:create(0.1,1.2)
        local awardArr=CCArray:create()
        local spaArr = CCArray:create()
        awardArr:addObject(deT2)
        awardArr:addObject(sAwardCall)

        spaArr:addObject(movUp)
        spaArr:addObject(scalb)
        local spawn1=CCSpawn:create(spaArr)
        awardArr:addObject(spawn1)

        local function endCall( )
            self:endAction()
        end 
        local endCCF = CCCallFuncN:create(endCall)
        local endT = CCDelayTime:create(1.2)
        awardArr:addObject(endT)
        awardArr:addObject(endCCF)

        local Seq=CCSequence:create(awardArr)
        self.sIcon:runAction(Seq)
    end

end
function acYrjTabOne:removeStar( ... )
    -- 移除创建的精灵
    for i=1,6,1 do
        local tempSpirte = tolua.cast(self.gBox:getChildByTag(i),"CCSprite")
        if tempSpirte then
            tempSpirte:removeFromParentAndCleanup(true)
            tempSpirte = nil
        end
    end
end
function acYrjTabOne:endAction( )
    if self.showAddCall then
        self.showAddCall()
        self.showAddCall = nil
    end
    if self.sIcon then
        self.sIcon:stopAllActions()    
        self.sIcon:removeFromParentAndCleanup(true)
        self.sIcon = nil
    end
    self.gCover1:stopAllActions()
    self.sAward:stopAllActions()
    self.gCover1:setVisible(true)
    self.gCover2:setVisible(false)
    self.gCover2:setRotation(0)
    self.sAward:setVisible(false)
    self:removeStar()
    self.sAward:setScale(self.sOldScale)
    self.sAward:setPosition(self.sOldPos)
    self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
end


