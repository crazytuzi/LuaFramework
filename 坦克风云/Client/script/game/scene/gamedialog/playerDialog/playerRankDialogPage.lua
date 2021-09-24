playerRankDialogPage={}

function playerRankDialogPage:new(rank)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.rank=rank
	self.cfg=rankCfg.rank[rank]
	self.height=0
	return nc
end

function playerRankDialogPage:init()
	self.bgLayer=CCLayer:create()

	local height=20
	local posX1=80
	local posX2=350

	local startHeight=G_VisibleSizeHeight-320
    
    if G_getCurChoseLanguage() == "ru" or G_getCurChoseLanguage() == "en" then
        posX2=450
    end
    local nowCfg=rankCfg.rank[playerVoApi:getRank()]

    local conditionLb=GetTTFLabel(getlocal("military_rank_conditionTitle"),30)
	conditionLb:setColor(G_ColorYellowPro)
	conditionLb:setAnchorPoint(ccp(0,0))
	conditionLb:setPosition(ccp(50,startHeight))
	self.bgLayer:addChild(conditionLb)
	local conditionH=conditionLb:getContentSize().height

	height=height+conditionH
	startHeight=startHeight-conditionH

	local needPointLb1=GetTTFLabel(getlocal("military_rank_needPoint"),25)
	needPointLb1:setAnchorPoint(ccp(0,0))
	needPointLb1:setPosition(ccp(posX1,startHeight))
	self.bgLayer:addChild(needPointLb1)

	local needPointLb2=GetTTFLabel(self.cfg.point,25)
	local needPosX222 = G_getCurChoseLanguage() == "ru" and 10 or 0
	if(playerVoApi:getRankPoint()>=self.cfg.point)then
		needPointLb2:setColor(G_ColorGreen)
	else
		needPointLb2:setColor(G_ColorRed)
	end
	needPointLb2:setAnchorPoint(ccp(0,0))
    -- if G_getCurChoseLanguage() == "ru" then
    --     needPointLb2:setPosition(ccp(posX2+10,startHeight))
    -- else
        needPointLb2:setPosition(ccp(posX2+needPosX222,startHeight))
    -- end
	self.bgLayer:addChild(needPointLb2)
	local needPointLbH=needPointLb1:getContentSize().height

	height=height+needPointLbH+10
	startHeight=startHeight-needPointLbH-10

	local lvLb1=GetTTFLabel(getlocal("military_rank_needLv"),25)
	lvLb1:setAnchorPoint(ccp(0,0))
	lvLb1:setPosition(ccp(posX1,startHeight))
	self.bgLayer:addChild(lvLb1)

	local lvLb2=GetTTFLabel(self.cfg.lv,25)
	if(playerVoApi:getPlayerLevel()>=self.cfg.lv)then
		lvLb2:setColor(G_ColorGreen)
	else
		lvLb2:setColor(G_ColorRed)
	end
	lvLb2:setAnchorPoint(ccp(0,0))
	lvLb2:setPosition(ccp(posX2+needPosX222,startHeight))
	self.bgLayer:addChild(lvLb2)
	local lvLb1H=lvLb1:getContentSize().height

	height=height+lvLb1H+10
	startHeight=startHeight-lvLb1H-10

	local numLb1=GetTTFLabel(getlocal("military_rank_limitNum"),25)
	numLb1:setAnchorPoint(ccp(0,0))
	numLb1:setPosition(ccp(posX1,startHeight))
	self.bgLayer:addChild(numLb1)

	local limitRanking=self.cfg.ranking
	local limitStr
	if(limitRanking[1] and limitRanking[2])then
		limitStr=limitRanking[2]-limitRanking[1]+1
	else
		limitStr=getlocal("alliance_info_content")
	end
	local numLb2=GetTTFLabel(limitStr,25)
	numLb2:setAnchorPoint(ccp(0,0))
    -- if G_getCurChoseLanguage() == "ru" then
        numLb2:setPosition(ccp(posX2+needPosX222*6,startHeight))
    -- else
    --     numLb2:setPosition(ccp(posX2,startHeight))
    -- end
	numLb2:setColor(G_ColorGreen)
	self.bgLayer:addChild(numLb2)
	local numLb1H=numLb1:getContentSize().height

	height=height+numLb1H+10
	startHeight=startHeight-numLb1H-10

	local rewardLb=GetTTFLabel(getlocal("military_rank_rewardTitle"),30)
	rewardLb:setAnchorPoint(ccp(0,0))
	rewardLb:setColor(G_ColorYellowPro)
	rewardLb:setPosition(ccp(50,startHeight))
	self.bgLayer:addChild(rewardLb)
	local rewardLbH=rewardLb:getContentSize().height

	height=height+rewardLbH
	startHeight=startHeight-rewardLbH

	if playerVoApi:getRankTroops(self.rank)>0 then
		local troopsLb1=GetTTFLabel(getlocal("military_rank_troopLeader"),25)
		troopsLb1:setAnchorPoint(ccp(0,0))
		troopsLb1:setPosition(ccp(posX1,startHeight))
		self.bgLayer:addChild(troopsLb1)

		local troopsLb2=GetTTFLabel("+ "..playerVoApi:getRankTroops(self.rank),25)
		troopsLb2:setAnchorPoint(ccp(0,0))
		-- troopsLb2:setColor(G_ColorGreen)
		troopsLb2:setPosition(ccp(posX2,startHeight))
		self.bgLayer:addChild(troopsLb2)

		if playerVoApi:getRankTroops(self.rank)>playerVoApi:getRankTroops(playerVoApi:getRank()) and playerVoApi:getRankTroops(playerVoApi:getRank())~=0 then
			troopsLb2:setColor(G_ColorGreen)
			local upSp=CCSprite:createWithSpriteFrameName("vipUpArrow.png")
			self.bgLayer:addChild(upSp)
			upSp:setPosition(posX2+120,startHeight+13)
		elseif playerVoApi:getRankTroops(self.rank)>playerVoApi:getRankTroops(playerVoApi:getRank()) and playerVoApi:getRankTroops(playerVoApi:getRank())==0 then
			troopsLb2:setColor(G_ColorYellowPro)
			if(G_isHexie()~=true)then
				local newSp=CCSprite:createWithSpriteFrameName("vipNewIcon.png")
				self.bgLayer:addChild(newSp)
				newSp:setPosition(posX2+120,startHeight+13)
			end
		end
		local troopsLbH=troopsLb1:getContentSize().height

		height=height+troopsLbH+10
		startHeight=startHeight-troopsLbH-10
	end

	local attAdd=playerVoApi:getRankAttAdd(self.rank)
	local nowAdd=playerVoApi:getRankAttAdd(playerVoApi:getRank())
	local attNum=#attAdd
	for i=attNum,1,-1 do
		if attAdd[i]>0 then
			local attName
			if(i==1)then
				attName="military_rank_basicAttack"
			else
				attName="military_rank_basicHp"
			end
			local attLb1=GetTTFLabel(getlocal(attName),25)
			attLb1:setAnchorPoint(ccp(0,0))
			attLb1:setPosition(ccp(posX1,startHeight))
			self.bgLayer:addChild(attLb1)

			local value=attAdd[i]*100
			local valueStr=tonumber(string.format("%.2f",value)).."%"
			local attLb2=GetTTFLabel("+ "..valueStr,25)
			attLb2:setAnchorPoint(ccp(0,0))
			-- attLb2:setColor(G_ColorGreen)
			attLb2:setPosition(ccp(posX2,startHeight))
			self.bgLayer:addChild(attLb2)

			if attAdd[i]>nowAdd[i] and nowAdd[i]~=0 then
				attLb2:setColor(G_ColorGreen)
				local upSp=CCSprite:createWithSpriteFrameName("vipUpArrow.png")
				self.bgLayer:addChild(upSp)
				upSp:setPosition(posX2+120,startHeight+13)
			elseif attAdd[i]>nowAdd[i] and nowAdd[i]==0 then
				attLb2:setColor(G_ColorYellowPro)
				local newSp=CCSprite:createWithSpriteFrameName("vipNewIcon.png")
				self.bgLayer:addChild(newSp)
				newSp:setPosition(posX2+120,startHeight+13)
				if(G_isHexie())then
					newSp:setVisible(false)
				end
			end

			local attLbH=attLb1:getContentSize().height

			height=height+attLbH+10
			startHeight=startHeight-attLbH-10
		end
	end

	if self.cfg.honorAdd >0 then
		local honorsLb1=GetTTFLabel(getlocal("military_rank_dailyHonor"),25)
		honorsLb1:setAnchorPoint(ccp(0,0))
		honorsLb1:setPosition(ccp(posX1,startHeight))
		self.bgLayer:addChild(honorsLb1)

		local honorsLb2=GetTTFLabel("+ "..self.cfg.honorAdd,25)
		honorsLb2:setAnchorPoint(ccp(0,0))
		-- honorsLb2:setColor(G_ColorGreen)
		honorsLb2:setPosition(ccp(posX2,startHeight))
		self.bgLayer:addChild(honorsLb2)

		if self.cfg.honorAdd>nowCfg.honorAdd and nowCfg.honorAdd~=0 then
			honorsLb2:setColor(G_ColorGreen)
			local upSp=CCSprite:createWithSpriteFrameName("vipUpArrow.png")
			self.bgLayer:addChild(upSp)
			upSp:setPosition(posX2+120,startHeight+13)
		elseif self.cfg.honorAdd>nowCfg.honorAdd and nowCfg.honorAdd==0 then
			honorsLb2:setColor(G_ColorYellowPro)
			local newSp=CCSprite:createWithSpriteFrameName("vipNewIcon.png")
			self.bgLayer:addChild(newSp)
			newSp:setPosition(posX2+120,startHeight+13)
			if(G_isHexie())then
				newSp:setVisible(false)
			end
		end
		local honorsLbH=honorsLb1:getContentSize().height

		height=height+honorsLbH+10
		startHeight=startHeight-honorsLbH-10
	end

	if base.ubh==1 then
		if self.cfg.helpValue>0 then
			local yuanjianNumLb1=GetTTFLabel(getlocal("sample_tech_name_27"),25)
			yuanjianNumLb1:setAnchorPoint(ccp(0,0))
			yuanjianNumLb1:setPosition(ccp(posX1,startHeight))
			self.bgLayer:addChild(yuanjianNumLb1)

			local yuanjianNumLb2=GetTTFLabel(self:getTimeStr(self.cfg.helpValue),25)
			yuanjianNumLb2:setAnchorPoint(ccp(0,0))
			-- yuanjianNumLb2:setColor(G_ColorGreen)
			yuanjianNumLb2:setPosition(ccp(posX2,startHeight))
			self.bgLayer:addChild(yuanjianNumLb2)
			if self.cfg.helpValue>nowCfg.helpValue and nowCfg.helpValue~=0 then
				yuanjianNumLb2:setColor(G_ColorGreen)
				local upSp=CCSprite:createWithSpriteFrameName("vipUpArrow.png")
				self.bgLayer:addChild(upSp)
				upSp:setPosition(posX2+120,startHeight+13)
			elseif self.cfg.helpValue>nowCfg.helpValue and nowCfg.helpValue==0 then
				yuanjianNumLb2:setColor(G_ColorYellowPro)
				local newSp=CCSprite:createWithSpriteFrameName("vipNewIcon.png")
				self.bgLayer:addChild(newSp)
				newSp:setPosition(posX2+120,startHeight+13)
				if(G_isHexie())then
					newSp:setVisible(false)
				end
			end
			local yuanjianNumLbH=yuanjianNumLb1:getContentSize().height

			height=height+yuanjianNumLbH+10
			startHeight=startHeight-yuanjianNumLbH-10
		end

		if self.cfg.helpNum>0 then
			local yuanjianEffectLb1=GetTTFLabel(getlocal("sample_tech_name_26"),25)
			yuanjianEffectLb1:setAnchorPoint(ccp(0,0))
			yuanjianEffectLb1:setPosition(ccp(posX1,startHeight))
			self.bgLayer:addChild(yuanjianEffectLb1)

			local yuanjianEffectLb2=GetTTFLabel(self.cfg.helpNum,25)
			yuanjianEffectLb2:setAnchorPoint(ccp(0,0))
			-- yuanjianEffectLb2:setColor(G_ColorGreen)
			yuanjianEffectLb2:setPosition(ccp(posX2,startHeight))
			self.bgLayer:addChild(yuanjianEffectLb2)

			if self.cfg.helpNum>nowCfg.helpNum and nowCfg.helpNum~=0 then
				yuanjianEffectLb2:setColor(G_ColorGreen)
				local upSp=CCSprite:createWithSpriteFrameName("vipUpArrow.png")
				self.bgLayer:addChild(upSp)
				upSp:setPosition(posX2+120,startHeight+13)
			elseif self.cfg.helpNum>nowCfg.helpNum and nowCfg.helpNum==0 then
				yuanjianEffectLb2:setColor(G_ColorYellowPro)
				local newSp=CCSprite:createWithSpriteFrameName("vipNewIcon.png")
				self.bgLayer:addChild(newSp)
				newSp:setPosition(posX2+120,startHeight+13)
				if(G_isHexie())then
					newSp:setVisible(false)
				end
			end
			local yuanjianEffectLbH=yuanjianEffectLb1:getContentSize().height

			height=height+yuanjianEffectLbH+10
			startHeight=startHeight-yuanjianEffectLbH-20
		end
	end

	self.height=height
	return self.bgLayer
end
function playerRankDialogPage:getTimeStr(time)
    local timeStr = "0m0s"
    if time<60 then
    	timeStr=time .. "s"
	elseif time%60==0 and time<3600 then
		timeStr = math.floor(time/60).."m"
    elseif time<3600 then
        timeStr = math.floor(time/60).."m"..math.floor(time%60).."s"
    elseif time>=3600 and time<(3600*24) then
        timeStr = math.floor(time/3600).."h"..math.floor((time%3600)/60).."m"
    elseif time>=(3600*24) then
        timeStr = math.floor(time/(3600*24)).."d"..math.floor((time%(3600*24))/3600).."h"
    end
    timeStr=replaceIllegal(timeStr)
    return timeStr
end