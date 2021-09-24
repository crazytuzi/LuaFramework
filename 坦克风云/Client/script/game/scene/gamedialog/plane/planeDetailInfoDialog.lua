planeDetailInfoDialog=smallDialog:new()

function planeDetailInfoDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

-- 领土争夺战新增 dtype
function planeDetailInfoDialog:init(planeVo,layerNum,callback,dtype)
	self.layerNum=layerNum
	self.planeVo=planeVo
	self.dtype=dtype

	self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)
    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))

    local bgWidth,bgHeight=550,780
    self.bgSize=CCSizeMake(bgWidth,bgHeight)
    local function nilFunc( ... )
    end
	local function close()
		return self:close()
	end
	local dialogBg=G_getNewDialogBg(self.bgSize,getlocal("plane_skill_info"),30,nilFunc,layerNum,true,close)
	dialogBg:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);

    self:initSkillLayer()

    if self.dtype and (self.dtype==35 or self.dtype==36) then
    else
    	
    	local function gotoHandler()
	        PlayEffect(audioCfg.mouseClick)
	        self:close()
	      	planeVoApi:showMainDialog(self.layerNum+1,0,self.planeVo.pid)
	    end
	    local scale=0.8
	    local goItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",gotoHandler,nil,getlocal("plane_skill_changed"),25/scale)
	    goItem:setScale(scale)
	    goBtn=CCMenu:createWithItem(goItem)
	    goBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	    goBtn:setPosition(ccp(self.bgSize.width/2,80))
	    self.bgLayer:addChild(goBtn,2)
    end

	return self.dialogLayer
end

function planeDetailInfoDialog:initSkillLayer()
	if self.planeVo==nil then
		do return end
	end
	local iconSize=100

	local function initSkill(idx,px,py,activeFlag)
		local equipFlag,sid=self.planeVo:isSkillSlotEquiped(idx,activeFlag)
		local skillIcon
		if equipFlag==true then
			local function showInfo()
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        -- PlayEffect(audioCfg.mouseClick)
		        --显示技能信息
		        local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
		        local skillVo=planeSkillVo:new(scfg,gcfg)
		        skillVo:initWithData(sid,1,2)
				planeVoApi:showInfoDialog(skillVo,self.layerNum+1)
	        end
			skillIcon=planeVoApi:getSkillIcon(sid,iconSize,showInfo)
			skillIcon:setTouchPriority(-(self.layerNum-1)*20-3)

			local nameStr=planeVoApi:getSkillInfoById(sid,true)
			if nameStr then
				local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
				local color=planeVoApi:getColorByQuality(gcfg.color)
				local nameLb=GetTTFLabelWrap(nameStr,20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				nameLb:setAnchorPoint(ccp(0.5,1))
	    		nameLb:setPosition(skillIcon:getContentSize().width/2,-5)
	    		nameLb:setColor(color)
	    		skillIcon:addChild(nameLb)
			end
        else
        	local function nilFunc()
        	end
        	local pic="passiveSelect.png"
		    if activeFlag and activeFlag==true then
		    	pic="activeSelect.png"
		    end
    		skillIcon=LuaCCSprite:createWithSpriteFrameName(pic,nilFunc)
    		skillIcon:setScale(iconSize/skillIcon:getContentSize().width)
    		local noEquipLb=GetTTFLabelWrap(getlocal("skill_equip_empty2"),20,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    		noEquipLb:setPosition(getCenterPoint(skillIcon))
    		noEquipLb:setColor(G_ColorRed)
    		skillIcon:addChild(noEquipLb)
		end
		if skillIcon then
			skillIcon:setAnchorPoint(ccp(0.5,1))
            skillIcon:setPosition(px,py)
            self.bgLayer:addChild(skillIcon,2)
		end
	end
	--初始化主动技能槽
	local activeLb=GetTTFLabelWrap(getlocal("plane_skill_active"),25,CCSizeMake(self.bgSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	activeLb:setPosition(self.bgSize.width/2,self.bgSize.height-130)
	-- activeLb:setColor(G_ColorRed)
	self.bgLayer:addChild(activeLb)
	local posY=activeLb:getPositionY()-activeLb:getContentSize().height/2-20

	initSkill(1,self.bgSize.width/2,posY,true)

	posY=posY-180
	--初始化被动技能槽
	local passiveLb=GetTTFLabelWrap(getlocal("plane_skill_passive"),25,CCSizeMake(self.bgSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	passiveLb:setPosition(self.bgSize.width/2,posY)
	-- passiveLb:setColor(G_ColorRed)
	self.bgLayer:addChild(passiveLb)
	local posY=posY-passiveLb:getContentSize().height/2-20
	for i=1,4 do
    	local posX=0
    	if i%2==0 then
    		posX=self.bgSize.width/2+100
    	else
    		posX=self.bgSize.width/2-100
    	end
		if i>1 and i%2==1 then
    		posY=posY-140
    	end
		initSkill(i,posX,posY,false)
	end
end

function planeDetailInfoDialog:dispose()
end