--[[
	播放陷阱特效 与QSBPlayScene类似 
	trap_id:播放特效的陷阱ID
	find_by_status:根据status来选择陷阱
	status:跟上面一起用的
--]]
local QSBAction = import(".QSBAction")
local QSBPlayTrapEffect = class("QSBPlayTrapEffect", QSBAction)

function QSBPlayTrapEffect:_execute(dt)
	local actor = self._attacker
	local effectID = self._options.effect_id
	local filter = function(trap)
					if self._options.find_by_status then
						return trap:getStatus() == self._options.status
					else
						return trap:getId() == self._options.trap_id
					end
		       	end 

	if IsServerSide then
		self:finished()
		return
	end

	-- client side effect play
	if app.battle:isInUnionDragonWar() or app.battle:isInGlory() or app.battle:isInGloryArena() or app.battle:isInTotemChallenge() then
	    QSkeletonDataCache:sharedSkeletonDataCache():removeUnusedData()
	    CCTextureCache:sharedTextureCache():removeUnusedTextures()
	end

	local positions = {}
	local trap_directors = app.battle:getTrapDirectors()
	for i, trap_director in ipairs(trap_directors) do
		local trap = trap_director:getTrap()
		if filter(trap) then
			table.insert(positions, {x = trap:getPosition().x, y = trap:getPosition().y})
		end
	end

	for i,pos in ipairs(positions) do	
		local options = {}
		options.attacker = self._attacker
		options.attackee = self._attackee
		options.targetPosition = pos
		options.scale_actor_face = self._options.scale_actor_face
		options.ground_layer = self._options.ground_layer
		options.front_layer = self._options.front_layer

		if effectID and pos then
			actor:playSkillEffect(effectID, nil, options)
		end
	end

	self:finished()
end

return QSBPlayTrapEffect