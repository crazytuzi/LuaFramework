
local TreasureHero = class("TreasureHero", BaseLayer)

function TreasureHero:ctor(data)
	--print(data)
    self.roleId = data[1]
    self.roleIndex = data[2]
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.shop.GetRoleResultLayer")
	self:PlayStartEffect()
	play_zhaomu_chouquxiake()
end

function TreasureHero:initUI(ui)
	self.super.initUI(self,ui)
	self.rolebgImg = TFDirector:getChildByPath(ui, "rolebgImg")
	self.rolebgImg:setVisible(false)
	self.ui = ui

	self.returnBtn = TFDirector:getChildByPath(ui, 'returnBtn')
    self.returnBtn:setClickAreaLength(100)
    self.returnBtn:setVisible(false)

    self.zhiyePanel = TFDirector:getChildByPath(ui, 'zyImg')
    self.zhiyePanel:setVisible(false)

    self.jieshaoPanel = TFDirector:getChildByPath(ui, 'jsImg')
    self.jieshaoPanel:setVisible(false)

    local getCardBtn = TFDirector:getChildByPath(ui, "getCardBtn")
	getCardBtn:setVisible(false)


	local yuanbaoLabel = TFDirector:getChildByPath(self.ui, "yuanbaoLabel")
	yuanbaoLabel:setVisible(false)

	self.ui:setTouchEnabled(true)
end

function TreasureHero:registerEvents(ui)
	self.super.registerEvents(self)
	-- if self.returnFun then
	-- 	self.returnBtn:addMEListener(TFWIDGET_CLICK,self.returnFun)
	-- else
	--ADD_ALERT_CLOSE_LISTENER(self, self.returnBtn)
	-- end
	--[[
	self.returnBtn = TFDirector:getChildByPath(ui, 'returnBtn')
    ADD_ALERT_CLOSE_LISTENER(self, self.returnBtn)
    self.returnBtn:setClickAreaLength(100)
    self.returnBtn:setVisible(false)
]]

	if self.roleIndex then
		print("TreasureHero:registerEvents---------")
		self.ui:addMEListener(TFWIDGET_CLICK, 
		audioClickfun(function(sender)
			local self = sender.logic
			local roleIndex = self.roleIndex			
			local parent = self.parent 
            AlertManager:close()
			if parent ~= nil then
				print("tenLayer---------"..roleIndex)
				parent:ShowRoleIcon(roleIndex)
			end
		end))
	end
	self.ui.logic = self	
end


function TreasureHero:setParent(parent)
	self.parent = parent
end

function TreasureHero:PlayStartEffect()
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/zm1.xml")
	local effect = TFArmature:create("zm1_anim")
	if effect == nil then
		return
	end

	effect:setZOrder(-100)
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 0)
	effect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))

	self.ui:addChild(effect)

	local timerID = TFDirector:addTimer(200, 1, nil, 
	function() 
		-- self.ui:setTouchEnabled(false)
		--self.ui:removeMEListener(TFWIDGET_CLICK)
		TFDirector:removeTimer(timerID)
		timerID = nil
		self:PlayShowRoleEffect()
	end)

	-- self.ui:setTouchEnabled(true)
	-- self.ui:addMEListener(TFWIDGET_CLICK, 
	-- audioClickfun(function()
	-- 	if timerID == nil then
	-- 		return
	-- 	end
	-- 	self.ui:setTouchEnabled(false)
	-- 	effect:setAnimationScale(100)
	-- 	TFDirector:removeTimer(timerID)
	-- 	timerID = nil
	-- 	self:PlayShowRoleEffect()
	-- end),1)
end

function TreasureHero:PlayShowRoleEffect()
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/zm3.xml")
	local effect = TFArmature:create("zm3_anim")
	if effect == nil then
		return
	end

	effect:setZOrder(-99)
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 1)
	effect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2 + 130))
	self.ui:addChild(effect)

	TFResourceHelper:instance():addArmatureFromJsonFile("effect/zm4.xml")
	local roleBgEffect = TFArmature:create("zm4_anim")
	if roleBgEffect == nil then
		return
	end
	roleBgEffect:setZOrder(10)
	roleBgEffect:setAnimationFps(GameConfig.ANIM_FPS)
	roleBgEffect:playByIndex(0, -1, -1, 0)
	roleBgEffect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))
	self.ui:addChild(roleBgEffect)

	self:ShowRole()
end

function TreasureHero:ShowRole()
	local newCardRoleData = RoleData:objectByID(self.roleId)
	if newCardRoleData == nil then
		print(self.roleId.."role not find")
		assert(false)
		return
	end
	RoleSoundData:playSoundByIndex(self.roleId)
	
	self.rolebgImg:setVisible(true)
	local nameLabel = TFDirector:getChildByPath(self.rolebgImg, "nameLabel")
	local tipLabel = TFDirector:getChildByPath(self.rolebgImg, "tipLabel")
	local gxhdImg = TFDirector:getChildByPath(self.rolebgImg, "gxhdImg")
	local qualityIcon = TFDirector:getChildByPath(self.rolebgImg, "qualityIcon")
	local footImg = TFDirector:getChildByPath(self.rolebgImg, "footImg")
	footImg:setVisible(false)
	nameLabel:setVisible(false)
	tipLabel:setVisible(false)
	gxhdImg:setVisible(false)
	qualityIcon:setVisible(false)

	local roleImg = TFDirector:getChildByPath(self.rolebgImg, "roleImg")
	roleImg:setTexture(newCardRoleData:getBigImagePath())
	roleImg:setScale(2)
	roleImg:setOpacity(80)
	local roleTween = 
	{
		target = roleImg,
		{
			duration = 0.3,
			alpha = 255,
			scale = 0.2,
		},
		{ 
   			duration = 0.2,
   			scale = 0.43,

   			onComplete = function ()
				self:OnRoleShowEnd(newCardRoleData)
				self:ShowRoleDetail(newCardRoleData)
			end	
		},
	}
	TFDirector:toTween(roleTween)
end

function TreasureHero:DrawAttrPolygon(attribute_level)
 	local attrPolygon = TFDrawNode:create()
    self.zhiyePanel:addChild(attrPolygon)
    attrPolygon:setColor(ccc4(0x5b,0xc4,0xff, 80))
    attrPolygon:setBorderWidth(0)

    local attrLevel = string.split(attribute_level, ",")
    for i=1,#attrLevel do
    	attrLevel[i] = 0.4 + 0.6*attrLevel[i]/10
    	attrLevel[i] = math.min(1, attrLevel[i])
    end

    local tb = 
    {
        ccp(0, 68*attrLevel[1]), 
        ccp(70*attrLevel[4],  15*attrLevel[4]),
        ccp(43*attrLevel[5], -68*attrLevel[5]), 
        ccp(-43*attrLevel[3],-68*attrLevel[3]), 
        ccp(-70*attrLevel[2], 15*attrLevel[2])
    }

    attrPolygon:drawPolygon(tb)
    attrPolygon:setPosition(ccp(0, 26))
end

function TreasureHero:ShowRoleDetail(newCardRoleData)
	self.zhiyePanel:setVisible(true)

	local zhiyeIcon = TFDirector:getChildByPath(self.zhiyePanel, "zhiyeIcon")
	zhiyeIcon:setTexture("ui_new/common/img_zy"..newCardRoleData.outline..".png")

	local zhiyeLabel = TFDirector:getChildByPath(self.zhiyePanel, "zhiyeLabel")
	zhiyeLabel:setText(newCardRoleData.attr_description)

	local trainItem = RoleTrainData:getRoleTrainByQuality(newCardRoleData.quality, 0)
	local attribute = GetAttrByString(newCardRoleData.attribute)
	local attrLevel = string.split(newCardRoleData.attribute_level, ",")

	local temp = attrLevel[4]
	attrLevel[4] = attrLevel[3]
	attrLevel[3] = temp
	local maxAttrIndex = 1
	local maxAttrNum = 0
	for i=1,5 do
		local attrImg = TFDirector:getChildByPath(self.zhiyePanel, "attrImg"..i)
		local numberLabel = TFDirector:getChildByPath(attrImg, "numberLabel")
		local attrNum = math.floor(attribute[i]*trainItem.streng_then)
		numberLabel:setText(attrNum)
		if tonumber(attrLevel[i]) > maxAttrNum then
			maxAttrIndex = i
			maxAttrNum = tonumber(attrLevel[i])
		end
	end

	self:DrawAttrPolygon(newCardRoleData.attribute_level)

	local imgName = {"zm_qixue2", "zm_wuli2", "zm_fangyu2", "zm_neili2", "zm_shenfa2"}
	local maxAttrImg = TFDirector:getChildByPath(self.zhiyePanel, "attrImg"..maxAttrIndex)
	maxAttrImg:setTexture("ui_new/shop/"..imgName[maxAttrIndex]..".png")

	local panelPos = self.zhiyePanel:getPosition()
	self.zhiyePanel:setPosition(ccp(0, panelPos.y))
	local zhiyeMoveTween = 
	{
		target = self.zhiyePanel,
		{
			duration = 0.2,
			x = panelPos.x,
			y = panelPos.y,

			onComplete = function ()
				self.ui:setTouchEnabled(true)
			end
		},
	}
	TFDirector:toTween(zhiyeMoveTween)

	self.jieshaoPanel:setVisible(true)
	local tipLabel = TFDirector:getChildByPath(self.jieshaoPanel, "tipLabel")
	tipLabel:setText(newCardRoleData.description)

	panelPos = self.jieshaoPanel:getPosition()
	self.jieshaoPanel:setPosition(ccp(GameConfig.WS.width, panelPos.y))
	local jieshaoMoveTween = 
	{
		target = self.jieshaoPanel,
		{
			duration = 0.3,
			x = panelPos.x,
			y = panelPos.y,
		},
	}
	TFDirector:toTween(jieshaoMoveTween)
end

function TreasureHero:OnRoleShowEnd(newCardRoleData)
	local rolebgImg = self.rolebgImg

	local nameLabel = TFDirector:getChildByPath(rolebgImg, "nameLabel")
	nameLabel:setVisible(true)
	nameLabel:setText(newCardRoleData.name)

	local footImg = TFDirector:getChildByPath(rolebgImg, "footImg")
	footImg:setVisible(true)
	footImg:setTexture("ui_new/shop/zm_role"..newCardRoleData.quality..".png")

	local tipLabel = TFDirector:getChildByPath(rolebgImg, "tipLabel")
	local gxhdImg = TFDirector:getChildByPath(rolebgImg, "gxhdImg")
	tipLabel:setVisible(false)
	gxhdImg:setVisible(false)


	local qualityIcon = TFDirector:getChildByPath(rolebgImg, "qualityIcon")
	qualityIcon:setTexture(GetFontByQuality(newCardRoleData.quality))
	qualityIcon:setVisible(true)

	--self.returnBtn:setVisible(true)
end


function TreasureHero:setReturnFun( fun )
	-- self.returnFun = fun
	self.returnBtn:addMEListener(TFWIDGET_CLICK,fun)
end
return TreasureHero
