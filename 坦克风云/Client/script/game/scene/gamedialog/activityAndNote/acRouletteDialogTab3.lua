acRouletteDialogTab3={}

function acRouletteDialogTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.acRouletteDialog=nil

    self.pointProgress=nil
    self.rewardBtn=nil
	
    return nc
end

function acRouletteDialogTab3:init(layerNum,selectedTabIndex,acRouletteDialog)
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.acRouletteDialog=acRouletteDialog
    self.bgLayer=CCLayer:create()

    self:doUserHandler()

    return self.bgLayer
end

function acRouletteDialogTab3:doUserHandler()

    local vo=acRouletteVoApi:getAcVo()
    local point=vo.point or 0
    local pointRewardNum=vo.pointRewardNum or 0

 	self.tvHeight=self.bgLayer:getContentSize().height-340

    local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, 100))
    titleBg:setAnchorPoint(ccp(0,0));
    titleBg:setPosition(ccp(30,G_VisibleSize.height-85-80-100))
    self.bgLayer:addChild(titleBg,1)

    local backBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    backBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, self.tvHeight+40))
    backBg:setAnchorPoint(ccp(0,0))
    backBg:setPosition(ccp(30,30))
    self.bgLayer:addChild(backBg)



    local descLb=GetTTFLabel(getlocal("activity_wheelFortune_day_has"),25)
    descLb:setAnchorPoint(ccp(0.5,1))
    descLb:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height-20))
    titleBg:addChild(descLb,1)
 	descLb:setColor(G_ColorGreen)


 	local rouletteCfg=acRouletteVoApi:getRouletteCfg()
	local pointReward=rouletteCfg.pointReward or {}
	local rPoint=tonumber(pointReward[1])
	
	local percentStr=point.."/"..rPoint
	local percent=math.floor((point/rPoint)*100)
    if percent>100 then
        percent=100
    end
	AddProgramTimer(titleBg,ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2-20),102,202,percentStr,"skillBg.png","skillBar.png",302)
	self.pointProgress=titleBg:getChildByTag(102)
	self.pointProgress=tolua.cast(self.pointProgress,"CCProgressTimer")
	self.pointProgress:setPercentage(percent)
	tolua.cast(self.pointProgress:getChildByTag(202),"CCLabelTTF"):setString(percentStr)


	local reward=FormatItem(pointReward[2]) or {}
	for k,v in pairs(reward) do
		if v and v.name and v.pic and v.num then
			local item=v
			local iSize=100
			local iconWidth=50+((k+1)%2)*275
			local iconHeight=self.bgLayer:getContentSize().height-290-math.floor((k-1)/2)*150

			local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
		    itemBg:setContentSize(CCSizeMake(265,140))
		    itemBg:setAnchorPoint(ccp(0,1))
		    itemBg:setPosition(ccp(iconWidth,iconHeight))
		    self.bgLayer:addChild(itemBg,1)

		    local icon = CCSprite:createWithSpriteFrameName(item.pic)
		    local scale=iSize/icon:getContentSize().width
		    icon:setAnchorPoint(ccp(0.5,0.5))
		    icon:setPosition(ccp(10+icon:getContentSize().width/2*scale,itemBg:getContentSize().height/2))
		    icon:setScale(scale)
		    itemBg:addChild(icon)

		    -- local nameLb=GetTTFLabelWrap(item.name,22)
		    local nameLb=GetTTFLabelWrap(item.name,22,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		    nameLb:setAnchorPoint(ccp(0,1))
		    nameLb:setPosition(ccp(icon:getContentSize().width*scale+20,itemBg:getContentSize().height-25))
		    itemBg:addChild(nameLb)
		    nameLb:setColor(G_ColorGreen)

		    local numLb=GetTTFLabel(getlocal("alliance_challenge_prop_num",{item.num}),22)
		    numLb:setAnchorPoint(ccp(0,0))
		    numLb:setPosition(ccp(icon:getContentSize().width*scale+20,25))
		    itemBg:addChild(numLb)

		end
	end


	local descPosY=G_VisibleSizeHeight-640
	local rewardDesc1=GetTTFLabelWrap(getlocal("activity_wheelFortune_reward_desc_1",{rPoint}),25,CCSizeMake(backBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    rewardDesc1:setAnchorPoint(ccp(0,1))
    rewardDesc1:setPosition(ccp(20,descPosY))
    backBg:addChild(rewardDesc1)

    local rewardDesc2=GetTTFLabelWrap(getlocal("activity_wheelFortune_reward_desc_2"),25,CCSizeMake(backBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    rewardDesc2:setAnchorPoint(ccp(0,1))
    rewardDesc2:setPosition(ccp(20,descPosY-rewardDesc1:getContentSize().height-10))
    backBg:addChild(rewardDesc2)
    rewardDesc2:setColor(G_ColorRed)


 	local function rewardHandler()
        local function wheelfortuneCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local vo=acRouletteVoApi:getAcVo()
                local point=vo.point or 0
                local pointRewardNum=vo.pointRewardNum or 0

                local rouletteCfg=acRouletteVoApi:getRouletteCfg()
                local pointReward=rouletteCfg.pointReward or {}
                local rPoint=tonumber(pointReward[1])
                local rewardCfg=pointReward[2] or {}

                if rPoint and point>=rPoint and pointRewardNum==0 then
                    if self and self.bgLayer then
                        local reward=FormatItem(rewardCfg) or {}
                        for k,v in pairs(reward) do
                            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
                        end
                        G_showRewardTip(reward)

                        local newNum=pointRewardNum+1
                        acRouletteVoApi:pointRewardUpdate(newNum)

                        self:refresh()  

                    end
                end

            end
        end
        socketHelper:activeWheelfortune(3,wheelfortuneCallback)
    end
    self.rewardBtn = GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rewardHandler,nil,getlocal("newGiftsReward"),25,11)
    self.rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(backBg:getContentSize().width/2,15))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    backBg:addChild(rewardMenu,2)
    self.rewardBtn:setEnabled(false)

    if acRouletteVoApi:acIsStop()==false then
        if pointRewardNum==0 then
            if rPoint and point>=rPoint then
                self.rewardBtn:setEnabled(true)
            end
            tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
        elseif pointRewardNum>0 then
            tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
        end
    end
	
end

function acRouletteDialogTab3:tick()
end

function acRouletteDialogTab3:subtick()
end

function acRouletteDialogTab3:refresh()
    if self and self.bgLayer then
        local vo=acRouletteVoApi:getAcVo()
        local point=vo.point or 0
        local pointRewardNum=vo.pointRewardNum or 0

        local rouletteCfg=acRouletteVoApi:getRouletteCfg()
        local pointReward=rouletteCfg.pointReward or {}
        local rPoint=tonumber(pointReward[1])

        if self.pointProgress then
            local percentStr=point.."/"..rPoint
            local percent=math.floor((point/rPoint)*100)
            if percent>100 then
                percent=100
            end
            self.pointProgress:setPercentage(percent)
            tolua.cast(self.pointProgress:getChildByTag(202),"CCLabelTTF"):setString(percentStr)
        end

        
        if self.rewardBtn then
            
            self.rewardBtn:setEnabled(false)
            tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))

            if acRouletteVoApi:acIsStop()==false then
                if pointRewardNum==0 then
                    if rPoint and point>=rPoint then
                        self.rewardBtn:setEnabled(true)
                    end
                    tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
                elseif pointRewardNum>0 then
                    tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
                end
            end
        end

    end

end

function acRouletteDialogTab3:dispose()
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.acRouletteDialog=nil

    self.pointProgress=nil
    self.rewardBtn=nil

    self=nil
end






