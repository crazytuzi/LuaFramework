--[[
    Class name QSBPlaySceneEffect
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBPlaySceneEffect = class("QSBPlaySceneEffect", QSBAction)

function QSBPlaySceneEffect:_execute(dt)
	local actor = self._attacker
	local effectID = self._options.effect_id
	local pos = self._options.pos

	if IsServerSide then
		self:finished()
		return
	end

	-- client side effect play
	if app.battle:isInUnionDragonWar() or app.battle:isInGlory() or app.battle:isInGloryArena() or app.battle:isInTotemChallenge() then
	    QSkeletonDataCache:sharedSkeletonDataCache():removeUnusedData()
	    CCTextureCache:sharedTextureCache():removeUnusedTextures()
	end

	local options = {}
	options.attacker = self._attacker
	options.attackee = self._attackee
	options.targetPosition = clone(pos)
	options.scale_actor_face = self._options.scale_actor_face
	options.ground_layer = self._options.ground_layer
	options.front_layer = self._options.front_layer

	if effectID and pos then
		actor:playSkillEffect(effectID, nil, options)
	end

	self:finished()
end

return QSBPlaySceneEffect