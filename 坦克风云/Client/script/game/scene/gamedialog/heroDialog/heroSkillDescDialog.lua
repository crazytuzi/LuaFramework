--将领技能描述的小面板
heroSkillDescDialog=smallDialog:new()

--param hid: 将领ID
--param sid: 技能ID
--param productOrder: 将领星级
--param skillLv：技能等级
--param isHonorSkill: 是否是授勋技能
function heroSkillDescDialog:new(hid,sid,productOrder,skillLv,isHonorSkill)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.hid=hid
	nc.sid=sid
	nc.productOrder=productOrder
	nc.skillLv=skillLv
	nc.isHonorSkill=isHonorSkill
	nc.dialogWidth=500
	nc.dialogHeight=400
	return nc
end

function heroSkillDescDialog:init(layerNum)
	self.layerNum=layerNum
	self.isTouch=nil
	self.isUseAmi=false
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	local descLb,icon,nameLb
	local descWidth=self.dialogWidth-100
	if(self.sid==heroFeatCfg.tianming.id)then
		descLb=GetTTFLabelWrap(getlocal(heroFeatCfg.tianming.des),25,CCSizeMake(descWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		icon = CCSprite:createWithSpriteFrameName(heroFeatCfg.tianming.icon)
		nameLb=GetTTFLabelWrap(getlocal(heroFeatCfg.tianming.name),27,CCSizeMake(self.dialogWidth -  180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	else
		local lvStr,value,isMax,skillLevel,sv
		if(self.isHonorSkill)then
			lvStr,value,isMax,skillLevel,sv=heroVoApi:getHeroHonorSkillLvAndValue(self.hid,self.sid,self.productOrder,self.skillLv)
			icon = CCSprite:create(heroVoApi:getSkillIconBySid(self.sid))
			local skdesc = heroVoApi:getSkillDesc(self.sid,sv)
			descLb=GetTTFLabelWrap(skdesc,25,CCSizeMake(descWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			nameLb=GetTTFLabelWrap(getlocal(heroSkillCfg[self.sid].name),27,CCSizeMake(self.dialogWidth -  180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		else
			local isAwaken=false
			local originalSid=nil
			if(equipCfg[self.hid] and equipCfg[self.hid]["e1"] and equipCfg[self.hid]["e1"].awaken and equipCfg[self.hid]["e1"].awaken.skill)then
				for k,v in pairs(equipCfg[self.hid]["e1"].awaken.skill) do
					if(v==self.sid)then
						isAwaken=true
						originalSid=k
						break
					end
				end
			end
            if(isAwaken)then
            	lvStr,value,isMax,skillLevel,sv=heroVoApi:getHeroSkillLvAndValue(self.hid,self.sid,self.productOrder,true,nil,self.skillLv)
            else
				lvStr,value,isMax,skillLevel,sv=heroVoApi:getHeroSkillLvAndValue(self.hid,self.sid,self.productOrder,nil,nil,self.skillLv)
			end
			local skdesc = heroVoApi:getSkillDesc(self.sid,sv)
			descLb=GetTTFLabelWrap(skdesc,25,CCSizeMake(descWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			nameLb=GetTTFLabelWrap(getlocal(heroSkillCfg[self.sid].name),27,CCSizeMake(self.dialogWidth -  180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			icon = CCSprite:create(heroVoApi:getSkillIconBySid(self.sid))
		end
	end
	if(descLb:getContentSize().height >= self.dialogHeight - 200 - 20)then
		self.dialogHeight=self.dialogHeight + descLb:getContentSize().height - (self.dialogHeight - 200 - 20)
	end

	self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(CCSizeMake(self.dialogWidth,self.dialogHeight))
	self.bgLayer:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	icon:setPosition(80,self.dialogHeight - 100)
	self.bgLayer:addChild(icon)

	local color
	if(self.skillLv)then
		color=heroVoApi:getSkillColorByLv(self.skillLv)
	else
		color=G_ColorWhite
	end
	nameLb:setColor(color)
	nameLb:setAnchorPoint(ccp(0,0.5))
	nameLb:setPosition(150,self.dialogHeight - 80)
	self.bgLayer:addChild(nameLb)
	local lvStr
	if(self.skillLv)then
		lvStr=getlocal("fightLevel",{self.skillLv})
	else
		lvStr=getlocal("fightLevel",{1})
	end
	local lvLb=GetTTFLabel(lvStr,25)
	lvLb:setAnchorPoint(ccp(0,0.5))
	lvLb:setPosition(150,self.dialogHeight - 120)
	self.bgLayer:addChild(lvLb)

	local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),nilFunc)
	descBg:setContentSize(CCSizeMake(self.dialogWidth - 60,self.dialogHeight - 200))
	descBg:setAnchorPoint(ccp(0.5,0))
	descBg:setPosition(self.dialogWidth/2,40)
	self.bgLayer:addChild(descBg)
	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(50,descBg:getPositionY() + descBg:getContentSize().height/2)
	self.bgLayer:addChild(descLb)
	self:show()	
	local function closeHandler()
		self:close()
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(0,0,10,10),closeHandler)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
	touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
	self.dialogLayer:addChild(touchDialogBg)
	
	sceneGame:addChild(self.dialogLayer,layerNum)
	return self.dialogLayer
end