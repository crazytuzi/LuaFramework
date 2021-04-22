local QSBAction = import(".QSBAction")
local QSBPlayLinkEffect = class("QSBPlayLinkEffect", QSBAction)

local QBaseEffectView
if not IsServerSide then
    QBaseEffectView = import("...views.QBaseEffectView")
end

function QSBPlayLinkEffect:getActorViewByCache(actor)
	self._actor_view_cache = self._actor_view_cache or {}
	if self._actor_view_cache[actor] then
		return self._actor_view_cache[actor]
	end
	local view = app.scene:getActorViewFromModel(actor)
	self._actor_view_cache[actor] = view
	return view
end

function QSBPlayLinkEffect:createEffect(target_1, target_2)
	if IsServerSide then return end
	self._link_effects = self._link_effects or {}
	local effect_id = self._options.effect_id
	local frontEffect, backEffect = QBaseEffectView.createEffectByID(effect_id, nil, nil, self._options)
	local view = frontEffect or backEffect
	view:playAnimation(view:getPlayAnimationName(), true)
	local node = CCNode:create()
	function node:pauseSoundEffect() end
    function node:resumeSoundEffect() end
	node:addChild(view)
	node:setVisible(false)
	node._dummy_as_position = view._dummy_as_position	--为了在QBattleScene:removeAllDummyAsPositionViews()中删除
	app.scene:addEffectViews(node, {isFrontEffect = true})
	table.insert(self._link_effects, {view = node, target_1 = target_1, target_2 = target_2})
end

local function get_dummy_pos(actor, actor_view, dummy)
	dummy = dummy or "dummy_center"
	local pos = clone(actor:getPosition())
	local bone_pos = {x = 0, y = 0}
	if actor_view and actor_view.getBonePosition then
		bone_pos = actor_view:getBonePosition(dummy)
	end
	pos.x, pos.y = pos.x + bone_pos.x, pos.y + bone_pos.y
	return pos
end

function QSBPlayLinkEffect:updateLinkEffect()
	if IsServerSide or self._link_effects == nil then return end
	for i, effect in ipairs(self._link_effects) do
		local view = effect.view
		local target_1 = effect.target_1
		local target_2 = effect.target_2
		local pos = target_1:getPosition()
		local pos2 = target_2:getPosition()
		if target_1:isDead() or target_2:isDead() or app.grid:_toGridPos(pos.x, pos.y) or app.grid:_toGridPos(pos2.x, pos2.y) then
			self:removeAllLinkEffects()
			self:finished()
			return
		end
		local width = self._options.effect_width
		local start_pos = get_dummy_pos(target_1, self:getActorViewByCache(target_1), self._options.dummy)
		local end_pos = get_dummy_pos(target_2, self:getActorViewByCache(target_2), self._options.dummy)
		local dx, dy = end_pos.x - start_pos.x, end_pos.y - start_pos.y
		view:setPosition(start_pos.x, start_pos.y)
		view:setRotation(180 - math.deg(math.atan2(dy, dx)))
		local len = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))
		view:setScaleX(len/width)
		view:setVisible(true)
	end
end

function QSBPlayLinkEffect:_execute(dt)
	if self._current_time then
		self._current_time = self._current_time + dt
		if self._current_time >= self._options.duration then
			self:removeAllLinkEffects()
			self:finished()
		else
			self:updateLinkEffect()
		end
		return
	end

	local effect_id = self._options.effect_id
	local effect_width = self._options.effect_width
	local targets = {}
	table.mergeForArray(targets, self._options.selectTargets, function(v) 
											local pos = v:getPosition()
											return not v:isDead() and not app.grid:_toGridPos(pos.x, pos.y)
										end)
	if effect_id == nil or effect_width == nil or targets == nil or #targets < 2 then
		self:finished()
		return
	end
	local len = #targets
	for i = 2, len, 1 do
		self:createEffect(targets[i-1], targets[i])
	end
	self:updateLinkEffect()
	self._current_time = 0
end

function QSBPlayLinkEffect:removeAllLinkEffects()
	if IsServerSide then return end
	for i, effect in ipairs(self._link_effects) do
		app.scene:removeEffectViews(effect.view)
	end
	self._link_effects = nil
	self._actor_view_cache = nil
end

function QSBPlayLinkEffect:_onCancel()
	self:_onRevert()
end

function QSBPlayLinkEffect:_onRevert()
	self:removeAllLinkEffects()
end

return QSBPlayLinkEffect