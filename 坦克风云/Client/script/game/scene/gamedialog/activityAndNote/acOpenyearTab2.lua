acOpenyearTab2 ={}
function acOpenyearTab2:new(layerNum)
        local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        self.adaH = 1250 - 1136
    end
    return nc
end

function acOpenyearTab2:init()
	self.bgLayer=CCLayer:create()

	local lbH=self.bgLayer:getContentSize().height-210
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
    	local desLb=GetTTFLabelWrap(getlocal("activity_openyear_des2"),25,CCSize(460,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        desLb:setPosition(50,lbH)
        self.bgLayer:addChild(desLb)
    else
        if G_isIphone5() then
            desTv, desLabel = G_LabelTableView(CCSizeMake(460, 100),getlocal("activity_openyear_des2"),25,kCCTextAlignmentLeft)
        else
            desTv, desLabel=G_LabelTableView(CCSizeMake(460, 100),getlocal("activity_openyear_des2"),25,kCCTextAlignmentLeft)
        end
        desTv:setAnchorPoint(ccp(0,1))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
        desTv:setPosition(ccp(50,lbH-50))
        desTv:setMaxDisToBottomOrTop(80)
        self.bgLayer:addChild(desTv)
    end
    lbH=lbH-50-30
    local function nilFunc()
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),nilFunc)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width
    	-80,lbH))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2,30))
    self.bgLayer:addChild(backSprie)

    -- 今日充值

    -- activity_openyear_recharge_des
    local rechargeLb=GetTTFLabel(getlocal("activity_openyear_recharge_des",{acOpenyearVoApi:getV()}),25)
    rechargeLb:setAnchorPoint(ccp(0,1))
    rechargeLb:setPosition(20,backSprie:getContentSize().height-20)
    backSprie:addChild(rechargeLb)
    self.rechargeLb=rechargeLb

    local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
    iconGold:setPosition(rechargeLb:getContentSize().width,rechargeLb:getContentSize().height/2)
    iconGold:setAnchorPoint(ccp(0,0.5))
    rechargeLb:addChild(iconGold)
    self.iconGold=iconGold


    -- 充值按钮
    local function rewardTiantang()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end

        vipVoApi:showRechargeDialog(self.layerNum+1)
		-- 跳转充值

	end
    -- local rechargeScale=1
    -- local rechargeImage1,rechargeImage2,rechargeImage3="BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png"
    -- if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
        local rechargeScale=0.8
        local rechargeImage1,rechargeImage2,rechargeImage3="creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
    -- end
	local rechargeItem=GetButtonItem(rechargeImage1,rechargeImage2,rechargeImage3,rewardTiantang,nil,getlocal("recharge"),24/rechargeScale)
    rechargeItem:setScale(rechargeScale)
	local rechargeBtn=CCMenu:createWithItem(rechargeItem);
	rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	rechargeBtn:setPosition(ccp(G_VisibleSizeWidth/2,80))
	self.bgLayer:addChild(rechargeBtn)



    self.tvH=lbH-10-40-rechargeLb:getContentSize().height-90
    self:addTV()

	return self.bgLayer
end

function acOpenyearTab2:addTV()
	self.cellHeight=128
	self.needMoneyTb,self.rechargeReward=acOpenyearVoApi:getNeedMoneyAndReward()
	self.tvHeight=SizeOfTable(self.needMoneyTb)*self.cellHeight+40
	local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-80,self.tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(40,40+90-self.adaH/2))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local function onRechargeChange(event,data)
        self:refresh()
    end
    self.openyearChargeListener=onRechargeChange
    eventDispatcher:addEventListener("acOpenyear.recharge",onRechargeChange)
end

function acOpenyearTab2:eventHandler(handler,fn,idx,cel)
    local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
	if fn=="numberOfCellsInTableView" then	 	
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-80,self.tvHeight)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local function click()
        end
        local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("acRadar_progressBg.png", CCRect(15,50,50,80),click)
        barSprie:setContentSize(CCSizeMake(86,self.tvHeight))
        barSprie:setPosition(ccp(60,self.tvHeight/2))
        cell:addChild(barSprie,1)

        local barWidth=self.tvHeight-40
        local spaceH=30

        AddProgramTimer(cell,ccp(60,barWidth/2+spaceH),11,12,nil,"acChunjiepansheng_progress2.png","acChunjiepansheng_progress1.png",13,1,1,nil,ccp(0,1))
        local per=G_getPercentage(acOpenyearVoApi:getV(),self.needMoneyTb)
        local timerSpriteLv=cell:getChildByTag(11)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        timerSpriteLv:setScaleY((barWidth)/timerSpriteLv:getContentSize().height)
        timerSpriteLv:setRotation(180)
        local bg = cell:getChildByTag(13)
        bg:setScaleY((barWidth)/bg:getContentSize().height)

        
        for k,v in pairs(self.needMoneyTb) do
        	local posY=k*self.cellHeight+spaceH

        	local keduSp = CCSprite:createWithSpriteFrameName("acRadar_splitline.png")
            keduSp:setPosition(60,posY)
            cell:addChild(keduSp,3)

            --充值等级
            local numBgSp = CCSprite:createWithSpriteFrameName("acRadar_numlabel.png")
            numBgSp:setAnchorPoint(ccp(0,1))
            numBgSp:setPosition(70,posY+8)
            cell:addChild(numBgSp,3)

            local numLb=GetTTFLabel(v,22)
            numLb:setPosition(numBgSp:getContentSize().width/2+5,numBgSp:getContentSize().height/2)
            numBgSp:addChild(numLb)

            local greenLineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
		    cell:addChild(greenLineSp)
		    greenLineSp:setPosition(330,posY)

		    local rewards=self.rechargeReward[k]
            if rewards then
                rewards=FormatItem(rewards)
                for kk,vv in pairs(rewards) do
                    local function showNewPropInfo()
                        G_showNewPropInfo(self.layerNum+1,true,true,nil,vv,nil,nil,nil,nil,true)
                        return false
                    end
                    local icon,scale=G_getItemIcon(vv,100,true,self.layerNum,showNewPropInfo,self.tv)
                    scale=80/icon:getContentSize().width
                    icon:setScale(scale)
                    if icon and scale then
                        icon:setTouchPriority(-(self.layerNum-1)*20-2)
                        cell:addChild(icon,2)
                        icon:setPosition(200+(kk-1)*90, posY-self.cellHeight/2)

                        local numLabel=GetTTFLabel("x"..vv.num,21)
                        numLabel:setAnchorPoint(ccp(1,0))
                        numLabel:setPosition(icon:getContentSize().width-5, 5)
                        numLabel:setScale(1/scale)
                        icon:addChild(numLabel,1)
                        -- if acBenfuqianxianVoApi:isFlick(v.key)==true then
                        --     G_addRectFlicker(icon,1.1/icon:getScaleX(),1.1/icon:getScaleY(),ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
                        -- end
                    end        
                end
            end

            local flag=acOpenyearVoApi:getRechargeState(k)
            local posX=485
            if flag==1 then -- 未完成
            	local hasRewardLb = GetTTFLabelWrap(getlocal("noReached"),strSize2,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                hasRewardLb:setPosition(ccp(posX,posY-self.cellHeight/2))
                cell:addChild(hasRewardLb)
            elseif flag==2 then -- 可领取
            	local function receiveHandler(tag,object)
                    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
                        end
                        PlayEffect(audioCfg.mouseClick)
                        local action="rechargereward"
                        local tid=k

                        local function refreshFunc(rewardlist)
                            local recordPoint=self.tv:getRecordPoint()
                            self.tv:reloadData()
                            self.tv:recoverToRecordPoint(recordPoint)

                            -- 此处加弹板
                            if rewardlist then
                                acOpenyearVoApi:showRewardDialog(rewardlist,self.layerNum)
                            end
                        end
                        acOpenyearVoApi:socketOpenyear(action,refreshFunc,tid)
                    end               
                end
                -- local getItemScale=0.7
                -- local getImage1,getImage2,getImage3="BtnOkSmall.png","BtnOkSmall_Down.png","BtnGraySmall_Down.png"
                -- if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
                    local getItemScale=0.5
                    local getImage1,getImage2,getImage3="newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"
                -- end
                local strSize3 = G_getCurChoseLanguage() == "ar" and 21 or 24
                local getBtn = GetButtonItem(getImage1,getImage2,getImage3,receiveHandler,i,getlocal("daily_scene_get"),strSize3/getItemScale)
                getBtn:setScale(getItemScale)
                local btnMenu=CCMenu:createWithItem(getBtn)
                btnMenu:setPosition(ccp(posX,posY-self.cellHeight/2))
                btnMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(btnMenu,1)
            else -- 已领取
            	local rightIcon=CCSprite:createWithSpriteFrameName("monthlysignFreeGetIcon.png")
                rightIcon:setAnchorPoint(ccp(0.5,0.5))
                rightIcon:setPosition(ccp(posX,posY-self.cellHeight/2))
                cell:addChild(rightIcon,1)
                rightIcon:setScale(0.6)
            end
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

function acOpenyearTab2:refresh()
    
    if self.tv then
        self.rechargeLb:setString(getlocal("activity_openyear_recharge_des",{acOpenyearVoApi:getV()}))
        self.iconGold:setPositionX(self.rechargeLb:getContentSize().width)
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    
end

function acOpenyearTab2:tick()
end


function acOpenyearTab2:dispose( )
    self.layerNum=nil
    self.tv=nil
    self.iconGold=nil
    self.rechargeLb=nil

    eventDispatcher:removeEventListener("activity.recharge",self.openyearChargeListener)
end