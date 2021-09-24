platWarDialogSubTab22={}
function platWarDialogSubTab22:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
    self.moralePointLb=nil
	return nc
end

function platWarDialogSubTab22:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initLayer()
    local function onUpdateListener()
        if self and self.refresh then
            self:refresh()
        end
    end
    self.onUpdateListener=onUpdateListener
    if(eventDispatcher:hasEventHandler("platWar.updateDonateMorale",onUpdateListener)==false)then
        eventDispatcher:addEventListener("platWar.updateDonateMorale",onUpdateListener)
    end
	return self.bgLayer
end

function platWarDialogSubTab22:initLayer()
    local bgWidth=self.bgLayer:getContentSize().width
    local bgHeight=self.bgLayer:getContentSize().height
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    backSprie:setContentSize(CCSizeMake(bgWidth-60,bgHeight-425))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(30,215))
    self.bgLayer:addChild(backSprie)

	
    local lbWidth=bgWidth-120
    local lbPosx1=40
    local lbPosx2=180
    local lbPosy=bgHeight-230
    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local rate=platWarVoApi:getPlatRate()
    local costCfg1=platWarCfg.donateMorale.donateCost1
    local costGems1=costCfg1[1]
    local addMorale1=costCfg1[2]*rate
    local costCfg2=platWarCfg.donateMorale.donateCost2
    local costGems2=costCfg2[1]
    local addMorale2=costCfg2[2]*rate
    local curMorale=platWarVoApi:getCurMorale()
    local addDamage,reduceDamage,accurate,critical,avoid,decritical,penetrate,armor=platWarVoApi:getAddAttrNum(curMorale)

	local moraleLb=GetTTFLabel(getlocal("plat_war_donate_morale"),25)
    moraleLb:setAnchorPoint(ccp(0,0.5))
	moraleLb:setPosition(ccp(lbPosx1,lbPosy))
	self.bgLayer:addChild(moraleLb)
	self.moralePointLb=GetTTFLabel(getlocal("plat_war_point",{curMorale}),25)
    self.moralePointLb:setAnchorPoint(ccp(0,0.5))
	self.moralePointLb:setColor(G_ColorGreen)
	self.moralePointLb:setPosition(ccp(lbPosx1+moraleLb:getContentSize().width+10,lbPosy))
	self.bgLayer:addChild(self.moralePointLb)

	lbPosy=lbPosy-45
	local providedLb1=GetTTFLabelWrap(getlocal("plat_war_donate_provided_1"),25,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	-- local providedLb1=GetTTFLabelWrap(str,25,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    providedLb1:setAnchorPoint(ccp(0,0.5))
	providedLb1:setColor(G_ColorYellowPro)
	providedLb1:setPosition(ccp(lbPosx1,lbPosy))
	self.bgLayer:addChild(providedLb1)

	lbPosy=lbPosy-45
	local addDamageLb=GetTTFLabel(getlocal("plat_war_donate_add_damage"),25)
    addDamageLb:setAnchorPoint(ccp(0,0.5))
	addDamageLb:setPosition(ccp(lbPosx1,lbPosy))
	self.bgLayer:addChild(addDamageLb)
	self.addNumLb=GetTTFLabel("+"..addDamage.."%",25)
    self.addNumLb:setAnchorPoint(ccp(0,0.5))
	self.addNumLb:setColor(G_ColorGreen)
	self.addNumLb:setPosition(ccp(lbPosx1+addDamageLb:getContentSize().width+10,lbPosy))
	self.bgLayer:addChild(self.addNumLb)

	lbPosy=lbPosy-30
	local reduceDamageLb=GetTTFLabel(getlocal("plat_war_donate_reduce_damage"),25)
    reduceDamageLb:setAnchorPoint(ccp(0,0.5))
	reduceDamageLb:setPosition(ccp(lbPosx1,lbPosy))
	self.bgLayer:addChild(reduceDamageLb)
	self.reduceNumLb=GetTTFLabel(reduceDamage.."%",25)
    self.reduceNumLb:setAnchorPoint(ccp(0,0.5))
	self.reduceNumLb:setColor(G_ColorGreen)
	self.reduceNumLb:setPosition(ccp(lbPosx1+reduceDamageLb:getContentSize().width+10,lbPosy))
	self.bgLayer:addChild(self.reduceNumLb)


	lbPosy=lbPosy-45
	local providedLb2=GetTTFLabelWrap(getlocal("plat_war_donate_provided_2"),25,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	-- local providedLb2=GetTTFLabelWrap(str,25,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    providedLb2:setAnchorPoint(ccp(0,0.5))
	providedLb2:setColor(G_ColorYellowPro)
	providedLb2:setPosition(ccp(lbPosx1,lbPosy))
	self.bgLayer:addChild(providedLb2)


	local lbWidth2=bgWidth/2-55
	local lbPosy2=60
    local function oneHandler()
         if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if platWarVoApi:checkStatus()>=30 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_end"),30)
            do return end
        end
        if playerVoApi:getPlayerLevel()<platWarCfg.donateLevel then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_cannot_donate_tip",{platWarCfg.donateLevel}),30)
            do return end
        end
        if(costGems1>playerVoApi:getGems())then
            GemsNotEnoughDialog(nil,nil,costGems1 - playerVoApi:getGems(),self.layerNum+1,costGems1)
            do return end
        end
        local function donateCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                -- local curMorale1=platWarVoApi:getCurMorale()
                -- platWarVoApi:setCurMorale(curMorale1+addMorale1)
                if sData.data then
                    platWarVoApi:updateInfo(sData.data)
                    if sData.data.moraleInfo then
                        local params={moraleInfo=sData.data.moraleInfo}
                        chatVoApi:sendUpdateMessage(25,params)
                    end
                end
                playerVoApi:setGems(playerVoApi:getGems()-costGems1)
                self:refresh()
                self:tick()
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_donate_success"),30)
            end
        end
        socketHelper:platwarDonate(1,1,nil,nil,donateCallback)
    end
    self.oneItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",oneHandler,2,getlocal("plat_war_donate_num",{1}),25)
    local oneMenu=CCMenu:createWithItem(self.oneItem)
    oneMenu:setPosition(ccp(lbPosx2,lbPosy2))
    oneMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(oneMenu)

    local function multipleHandler()
    	if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if platWarVoApi:checkStatus()>=30 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_end"),30)
            do return end
        end
        if playerVoApi:getPlayerLevel()<platWarCfg.donateLevel then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_cannot_donate_tip",{platWarCfg.donateLevel}),30)
            do return end
        end
        if(costGems2>playerVoApi:getGems())then
            GemsNotEnoughDialog(nil,nil,costGems2 - playerVoApi:getGems(),self.layerNum+1,costGems2)
            do return end
        end
        local function donateCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                -- local curMorale2=platWarVoApi:getCurMorale()
                -- platWarVoApi:setCurMorale(curMorale2+addMorale2)
                if sData.data then
                    platWarVoApi:updateInfo(sData.data)
                    if sData.data.moraleInfo then
                        local params={moraleInfo=sData.data.moraleInfo}
                        chatVoApi:sendUpdateMessage(25,params)
                    end
                end
                playerVoApi:setGems(playerVoApi:getGems()-costGems2)
                self:refresh()
                self:tick()
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_donate_success"),30)
            end
        end
        socketHelper:platwarDonate(1,2,nil,nil,donateCallback)
    end
    self.multipleItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",multipleHandler,2,getlocal("plat_war_donate_num",{10}),25)
    local multipleMenu=CCMenu:createWithItem(self.multipleItem)
    multipleMenu:setPosition(ccp(bgWidth-lbPosx2,lbPosy2))
    multipleMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(multipleMenu)

    -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    lbPosy2=lbPosy2+65
    self.descLb2=GetTTFLabelWrap(getlocal("plat_war_donate_desc",{platWarCfg.donateMorale.critRate}),25,CCSizeMake(lbWidth2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- self.descLb2=GetTTFLabelWrap(str,25,CCSizeMake(lbWidth2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.descLb2:setAnchorPoint(ccp(0.5,0.5))
	self.descLb2:setColor(G_ColorYellowPro)
	self.descLb2:setPosition(ccp(lbPosx2,lbPosy2))
	self.bgLayer:addChild(self.descLb2)

	lbPosy2=lbPosy2+55
	local costLb1=GetTTFLabelWrap(getlocal("plat_war_donate_cost",{costGems1,addMorale1}),25,CCSizeMake(lbWidth2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- local costLb1=GetTTFLabelWrap(str,25,CCSizeMake(lbWidth2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    costLb1:setAnchorPoint(ccp(0.5,0.5))
	costLb1:setColor(G_ColorYellowPro)
	costLb1:setPosition(ccp(lbPosx2,lbPosy2))
	self.bgLayer:addChild(costLb1)
	local costLb2=GetTTFLabelWrap(getlocal("plat_war_donate_cost",{costGems2,addMorale2}),25,CCSizeMake(lbWidth2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- local costLb2=GetTTFLabelWrap(str,25,CCSizeMake(lbWidth2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    costLb2:setAnchorPoint(ccp(0.5,0.5))
	costLb2:setColor(G_ColorYellowPro)
	costLb2:setPosition(ccp(bgWidth-lbPosx2,lbPosy2))
	self.bgLayer:addChild(costLb2)

	self:initAttr()
    self:tick()
end

function platWarDialogSubTab22:initAttr()
	local firstSpX = 50
    local firstLbX = 110+30
    
    local secndSpX = 230+30+60
    local secndLbX = 290+30+90

    local labelSize = 25
    local labelWidth = 200

    local iconScale=0.8
    local hSpace=35
    local hGap=8

	local dialogBgHeight=self.bgLayer:getContentSize().height-15
    if G_isIphone5() then
        hSpace=80
        dialogBgHeight=dialogBgHeight-10
    end

    local curMorale=platWarVoApi:getCurMorale()
    local addDamage,reduceDamage,accurate,critical,avoid,decritical,penetrate,armor=platWarVoApi:getAddAttrNum(curMorale)
	--精准
    local accurateSp=CCSprite:createWithSpriteFrameName("skill_01.png");
    accurateSp:setAnchorPoint(ccp(0,0.5));
    accurateSp:setPosition(firstSpX,dialogBgHeight-460)
    self.bgLayer:addChild(accurateSp,2)
    accurateSp:setScale(iconScale)
    
    self.accurateLb=GetTTFLabel(accurate.."%",labelSize)
    self.accurateLb:setAnchorPoint(ccp(0,0.5))
    self.accurateLb:setPosition(ccp(firstLbX,dialogBgHeight-474-hGap))
    self.bgLayer:addChild(self.accurateLb)
    self.accurateLb:setColor(G_ColorGreen)
    
    -- self.accurateLbAdd=GetTTFLabel("+"..accurate.."%",labelSize)
    -- self.accurateLbAdd:setAnchorPoint(ccp(0,0.5))
    -- self.accurateLbAdd:setPosition(ccp(firstLbX+self.accurateLb:getContentSize().width,dialogBgHeight-474-hGap))
    -- self.accurateLbAdd:setColor(G_ColorGreen)
    -- self.bgLayer:addChild(self.accurateLbAdd)

    local accurateNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_101"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    accurateNameLb:setAnchorPoint(ccp(0,0.5))
    accurateNameLb:setPosition(ccp(firstLbX,dialogBgHeight-446+hGap))
    self.bgLayer:addChild(accurateNameLb)

	--暴击    
    local criticalSp = CCSprite:createWithSpriteFrameName("skill_03.png");
    criticalSp:setAnchorPoint(ccp(0,0.5));
    criticalSp:setPosition(firstSpX,dialogBgHeight-530-hSpace)
    self.bgLayer:addChild(criticalSp,2)
    criticalSp:setScale(iconScale)
    
    self.criticalLb=GetTTFLabel(critical.."%",labelSize)
    self.criticalLb:setAnchorPoint(ccp(0,0.5))
    self.criticalLb:setPosition(ccp(firstLbX,dialogBgHeight-530-14-hSpace-hGap))
    self.bgLayer:addChild(self.criticalLb)
    self.criticalLb:setColor(G_ColorGreen)
    
    -- self.criticalLbAdd=GetTTFLabel("+"..critical.."%",labelSize)
    -- self.criticalLbAdd:setAnchorPoint(ccp(0,0.5))
    -- self.criticalLbAdd:setPosition(ccp(firstLbX+self.criticalLb:getContentSize().width,dialogBgHeight-530-14-hSpace-hGap))
    -- self.criticalLbAdd:setColor(G_ColorGreen)
    -- self.bgLayer:addChild(self.criticalLbAdd)
    
    local criticalNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_103"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    criticalNameLb:setAnchorPoint(ccp(0,0.5))
    criticalNameLb:setPosition(ccp(firstLbX,dialogBgHeight-530+14-hSpace+hGap))
    self.bgLayer:addChild(criticalNameLb)
    
	--闪避    
    local avoidSp = CCSprite:createWithSpriteFrameName("skill_02.png");
    avoidSp:setAnchorPoint(ccp(0,0.5));
    avoidSp:setPosition(secndSpX,dialogBgHeight-460)
    self.bgLayer:addChild(avoidSp,2)
    avoidSp:setScale(iconScale)
    
    self.avoidLb=GetTTFLabel(avoid.."%",labelSize)
    self.avoidLb:setAnchorPoint(ccp(0,0.5))
    self.avoidLb:setPosition(ccp(secndLbX,dialogBgHeight-460-14-hGap))
    self.bgLayer:addChild(self.avoidLb)
    self.avoidLb:setColor(G_ColorGreen)
    
    -- self.avoidLbAdd=GetTTFLabel("+"..avoid.."%",labelSize)
    -- self.avoidLbAdd:setAnchorPoint(ccp(0,0.5))
    -- self.avoidLbAdd:setPosition(ccp(secndLbX+self.avoidLb:getContentSize().width,dialogBgHeight-460-14-hGap))
    -- self.avoidLbAdd:setColor(G_ColorGreen)
    -- self.bgLayer:addChild(self.avoidLbAdd)
    
    local avoidNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_102"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    avoidNameLb:setAnchorPoint(ccp(0,0.5))
    avoidNameLb:setPosition(ccp(secndLbX,dialogBgHeight-460+14+hGap))
    self.bgLayer:addChild(avoidNameLb)
    
	--坚韧    
    local decriticalSp = CCSprite:createWithSpriteFrameName("skill_04.png");
    decriticalSp:setAnchorPoint(ccp(0,0.5));
    decriticalSp:setPosition(secndSpX,dialogBgHeight-530-hSpace)
    self.bgLayer:addChild(decriticalSp,2)
    decriticalSp:setScale(iconScale)
    
    self.decriticalLb=GetTTFLabel(decritical.."%",labelSize)
    self.decriticalLb:setAnchorPoint(ccp(0,0.5))
    self.decriticalLb:setPosition(ccp(secndLbX,dialogBgHeight-530-14-hSpace-hGap))
    self.bgLayer:addChild(self.decriticalLb)
    self.decriticalLb:setColor(G_ColorGreen)
    
    -- self.decriticalLbAdd=GetTTFLabel("+"..decritical.."%",labelSize)
    -- self.decriticalLbAdd:setAnchorPoint(ccp(0,0.5))
    -- self.decriticalLbAdd:setPosition(ccp(secndLbX+self.decriticalLb:getContentSize().width,dialogBgHeight-530-14-hSpace-hGap))
    -- self.decriticalLbAdd:setColor(G_ColorGreen)
    -- self.bgLayer:addChild(self.decriticalLbAdd)
    
    local decriticalNameLb=GetTTFLabelWrap(getlocal("sample_skill_name_104"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    decriticalNameLb:setAnchorPoint(ccp(0,0.5))
    decriticalNameLb:setPosition(ccp(secndLbX,dialogBgHeight-530+14-hSpace+hGap))
    self.bgLayer:addChild(decriticalNameLb)


    --击破  
    local penetrateSp = CCSprite:createWithSpriteFrameName("attributeARP.png");
    penetrateSp:setAnchorPoint(ccp(0,0.5));
    penetrateSp:setPosition(firstSpX,dialogBgHeight-600-hSpace*2)
    self.bgLayer:addChild(penetrateSp,2)
    penetrateSp:setScale(iconScale)
    
    self.penetrateLb=GetTTFLabel(penetrate,labelSize)
    self.penetrateLb:setAnchorPoint(ccp(0,0.5))
    self.penetrateLb:setPosition(ccp(firstLbX,dialogBgHeight-600-14-hSpace*2-hGap))
    self.bgLayer:addChild(self.penetrateLb)
    self.penetrateLb:setColor(G_ColorGreen)

    local penetrateNameLb=GetTTFLabelWrap(getlocal("accessory_prop_name_1"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    penetrateNameLb:setAnchorPoint(ccp(0,0.5))
    penetrateNameLb:setPosition(ccp(firstLbX,dialogBgHeight-600+14-hSpace*2+hGap))
    self.bgLayer:addChild(penetrateNameLb)

    --防护
    local armorSp = CCSprite:createWithSpriteFrameName("attributeArmor.png");
    armorSp:setAnchorPoint(ccp(0,0.5));
    armorSp:setPosition(secndSpX,dialogBgHeight-600-hSpace*2)
    self.bgLayer:addChild(armorSp,2)
    armorSp:setScale(iconScale)
    
    self.armorLb=GetTTFLabel(armor,labelSize)
    self.armorLb:setAnchorPoint(ccp(0,0.5))
    self.armorLb:setPosition(ccp(secndLbX,dialogBgHeight-600-14-hSpace*2-hGap))
    self.bgLayer:addChild(self.armorLb)
    self.armorLb:setColor(G_ColorGreen)
    
    local armorNameLb=GetTTFLabelWrap(getlocal("accessory_prop_name_2"),labelSize,CCSizeMake(labelWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    armorNameLb:setAnchorPoint(ccp(0,0.5))
    armorNameLb:setPosition(ccp(secndLbX,dialogBgHeight-600+14-hSpace*2+hGap))
    self.bgLayer:addChild(armorNameLb)

end

function platWarDialogSubTab22:refresh()
    if self then
        local curMorale=platWarVoApi:getCurMorale()
        local addDamage,reduceDamage,accurate,critical,avoid,decritical,penetrate,armor=platWarVoApi:getAddAttrNum(curMorale)
        if self.moralePointLb then
            self.moralePointLb:setString(getlocal("plat_war_point",{curMorale}))
        end
        if self.addNumLb then
            self.addNumLb:setString("+"..addDamage.."%")
        end
        if self.reduceNumLb then
            self.reduceNumLb:setString("-"..reduceDamage.."%")
        end
        if self.accurateLb then
            self.accurateLb:setString(accurate.."%")
        end
        if self.criticalLb then
            self.criticalLb:setString(critical.."%")
        end
        if self.avoidLb then
            self.avoidLb:setString(avoid.."%")
        end
        if self.decriticalLb then
            self.decriticalLb:setString(decritical.."%")
        end
        if self.penetrateLb then
            self.penetrateLb:setString(penetrate)
        end
        if self.armorLb then
            self.armorLb:setString(armor)
        end
    end
end

function platWarDialogSubTab22:tick()
    if self.descLb2 then
        local lastTime=platWarVoApi:getLastDonateTime()
        if base.serverTime-lastTime>(platWarCfg.donateMorale.critCD*3600) then
            -- self.descLb2:setVisible(true)
            self.descLb2:setString(getlocal("plat_war_donate_desc",{platWarCfg.donateMorale.critRate}))
        else
            -- self.descLb2:setVisible(false)
            local time=platWarCfg.donateMorale.critCD*3600-(base.serverTime-lastTime)
            self.descLb2:setString(GetTimeForItemStr(time))
        end
    end
    if self and self.multipleItem then
        if platWarVoApi:checkStatus()>=30 then
            self.multipleItem:setEnabled(false)
        else
            self.multipleItem:setEnabled(true)
        end
    end
    if self and self.oneItem then
        if platWarVoApi:checkStatus()>=30 then
            self.oneItem:setEnabled(false)
        else
            self.oneItem:setEnabled(true)
        end
    end
end

function platWarDialogSubTab22:dispose()
    eventDispatcher:removeEventListener("platWar.updateDonateMorale",self.onUpdateListener)
	self.bgLayer:removeFromParentAndCleanup(true)
	self.layerNum=nil
    self.moralePointLb=nil
	self.bgLayer=nil
end