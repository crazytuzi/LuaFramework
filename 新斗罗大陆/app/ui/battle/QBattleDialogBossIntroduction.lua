
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogBossIntroduction = class("QBattleDialogBossIntroduction", QBattleDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBattleDialogBossIntroduction:ctor(owner, options)
	local ccbFile = "Dialog_hunshijieshao.ccbi"
	if owner == nil then
		owner = {}
	end
	self:setNodeEventEnabled(true)

	QBattleDialogBossIntroduction.super.ctor(self, ccbFile, owner)

	if options and options.actor then
		self:setActor(options.actor)
	end

	if app.battle:isInBlackRock() then
		owner.node_ditu:setVisible(false)
		owner.node_h:setVisible(true)
	else
		owner.node_ditu:setVisible(true)
		owner.node_h:setVisible(false)
	end

	local ccclippingNode = CCClippingNode:create()
	local spriteStencil = CCSprite:create("ui/hunshijieshao/heisezhezhao.png")
	local spriteBackground = CCSprite:create("ui/hunshijieshao/sp_jieshaodi.png")
	local width = spriteBackground:getContentSize().width/2 + spriteStencil:getContentSize().width/2
	spriteStencil:setPositionX(-width)
	ccclippingNode:setStencil(spriteStencil)
	ccclippingNode:addChild(spriteBackground)
	ccclippingNode:setPositionY(-15)
	ccclippingNode:setAlphaThreshold(0.1)

	self._stencil_end_animation = function()
		scheduler.performWithDelayGlobal(function()
			if spriteStencil and not tolua.isnull(spriteStencil) then
				spriteStencil:setScale(1)
				spriteStencil:setScaleX(-1)
				spriteStencil:runAction(CCMoveTo:create(0.15, ccp(width, 0)))
			end
		end, 0.4)
	end
	self._stencil_start_animation = function()
		local arr = CCArray:create()
		arr:addObject(CCMoveTo:create(0.25, ccp(spriteStencil:getContentSize().width/2 - spriteBackground:getContentSize().width/2, 0)))
		arr:addObject(CCScaleTo:create(0.25, 2.5))
		spriteStencil:runAction(CCSpawn:create(arr))
	end

	owner.node_ditu:setScale(2.1)
	owner.node_ditu:setRotation(12)
	owner.node_ditu:addChild(ccclippingNode)

	self:setOverlayOpacity(0)
	self._isEnd = false

	scheduler.performWithDelayGlobal(function ()
		self._stencil_start_animation()
		local animationManager = tolua.cast(self._ccbNode:getUserObject(), "CCBAnimationManager")
		animationManager:stopAnimation()
		animationManager:runAnimationsForSequenceNamed("begin")
		animationManager:connectScriptHandler(function()
				self._isEnd = true
				local skip_time = QStaticDatabase:sharedDatabase():getConfigurationValue("enemy_information_auto")
				if skip_time then
					scheduler.performWithDelayGlobal(handler(self, QBattleDialogBossIntroduction._backClickHandler), skip_time)
				end
			end)
	end, 0.01)
end

function QBattleDialogBossIntroduction:setActor(actor)
	local owner = self._ccbOwner
	local db = QStaticDatabase:sharedDatabase()
	local info = db:getCharacterByID(actor:getActorID())
	local dialogDisplay = db:getDialogDisplay()[tostring(actor:getActorID())]

	owner.tf_boss_type:setString(info.title or "")
	owner.tf_soul_name:setVisible(false)

	-- 半身像
	if dialogDisplay then
		local aid_bust = dialogDisplay.bust
		if aid_bust then
			local function setSprite(sprite)
				sprite:setScaleX(sprite:getScaleX() * -1)
				local texture = CCTextureCache:sharedTextureCache():addImage(aid_bust)
				if texture then
					sprite:setTexture(texture)
				end
				local scale = tonumber(dialogDisplay.boss_scale) or 1
				sprite:setScaleX(scale * (dialogDisplay.boss_flip_x and -1 or 1))
				sprite:setScaleY(scale)
				local rotation = tonumber(dialogDisplay.boss_rotation) or 0
				sprite:setRotation(rotation)
				
			end
			setSprite(owner.sp_hero)
			setSprite(owner.sp_hero1)
			setSprite(owner.sp_hero2)
			setSprite(owner.sp_hero3)
			local nodeHero = owner.node_hero
			local offset_x = tonumber(dialogDisplay.boss_x) or 0
			nodeHero:setPositionX(nodeHero:getPositionX() + offset_x)
			local offset_y = tonumber(dialogDisplay.boss_y) or 0
			nodeHero:setPositionY(nodeHero:getPositionY() + offset_y)
		end

	    if dialogDisplay.startBuriedPoint then
	        app:triggerBuriedPoint(dialogDisplay.startBuriedPoint)
	    end
	end

	-- 品质
	local aptitudeInfo = db:getActorSABC(actor:getActorID())
	q.setAptitudeShow(owner, aptitudeInfo.lower)
	
	-- if aptitudeInfo.lower == "a+" then
	-- 	owner.tf_boss_name:setPositionX(owner.tf_boss_name:getPositionX()+40)
	-- 	owner.tf_boss_name1:setPositionX(owner.tf_boss_name1:getPositionX()+40)
	-- end

	if app.battle:isInBlackRock() then
		local lower = aptitudeInfo.lower
		if lower == "s" then
			owner.sp_s:setVisible(true)
			owner.sp_a:setVisible(false)
		else
			owner.sp_s:setVisible(false)
			owner.sp_a:setVisible(true)
		end
	end
	
	--魂师名字
	if info.show_name then
		local spriteFrame = QSpriteFrameByPath(info.show_name)
		if spriteFrame then
			owner.tf_boss_name:setDisplayFrame(spriteFrame)
			owner.tf_boss_name1:setDisplayFrame(spriteFrame)
		end
	end

	if info.show_title then
		local spriteFrame = QSpriteFrameByPath(info.show_title)
		if spriteFrame then
			owner.tf_boss_title:setDisplayFrame(spriteFrame)
		end
	end

	-- 攻略技巧
	if info.desc_1 then
		local tbl = string.split(info.desc_1, ";")
		local index = 1
		while true do
			local tf = self._ccbOwner["tf_boss_desc_"..index]
			if tf then
				if tbl[index] then
					tf:setString(tbl[index])
				else
					tf:setString("")
				end
				index = index + 1
			else
				break
			end
		end
		self._ccbOwner.node_boss_desc:setVisible(true)
	else
		self._ccbOwner.node_boss_desc:setVisible(false)
	end
end

function QBattleDialogBossIntroduction:onExit()

end

function QBattleDialogBossIntroduction:_backClickHandler()
	if self._isEnd then
		self._isEnd = false
		local animationManager = tolua.cast(self._ccbNode:getUserObject(), "CCBAnimationManager")
		animationManager:stopAnimation()
		animationManager:runAnimationsForSequenceNamed("end")
		self._stencil_end_animation()
		animationManager:connectScriptHandler(function()
			self:close()
		end)
	end
end

return QBattleDialogBossIntroduction