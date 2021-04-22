local QBattleDialog = import(".QBattleDialog")
local QBattleDialogNewEnemyTips = class("QBattleDialogNewEnemyTips", QBattleDialog)

function QBattleDialogNewEnemyTips:ctor(owner, options)
	local ccbFile = "Dialog_new_enemies.ccbi"
	if owner == nil then
		owner = {}
	end

	local callBacks = {
		{ccbCallbackName = "onTriggerClose",  callback = handler(self, QBattleDialogNewEnemyTips._onTriggerClose)},
	}
	self:setNodeEventEnabled(true)
	QBattleDialogNewEnemyTips.super.ctor(self, ccbFile, owner, callBacks)

	if nil ~= options then
		self._ccbOwner.name:setString(options.enemy_name)
		self._ccbOwner.description:setString(options.description)

		local move_clip = options.move_clip
		if move_clip and type(move_clip) == "string" then
			local sprite = self._ccbOwner.sp_hero
			local texture = CCTextureCache:sharedTextureCache():addImage(move_clip)
			if texture then
				local size = texture:getContentSize()
		        local rect = CCRectMake(0, 0, size.width, size.height)
		        sprite:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
			end
		end
	end

	-- self:setOverlayOpacity(0)
	app.battle:pause()
end

function QBattleDialogNewEnemyTips:onEnter()
end

function QBattleDialogNewEnemyTips:onExit()
	app.scene:removeNewEnemyTips()
end

function QBattleDialogNewEnemyTips:_onFrame(dt)
end

function QBattleDialogNewEnemyTips:close()
	self.super.close(self)
end

function QBattleDialogNewEnemyTips:_backClickHandler()
	-- self:close()
end

function QBattleDialogNewEnemyTips:_onTriggerClose()
	self:close()
end

return QBattleDialogNewEnemyTips