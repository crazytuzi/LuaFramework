--[[
	给ghost上buff
    Class name QSBGhostApplyBuff
    Create by wanghai
    @common
--]]
local QSBAction = import(".QSBAction")
local QSBGhostApplyBuff = class("QSBGhostApplyBuff", QSBAction)

function QSBGhostApplyBuff:_execute(dt)
	local ghosts = self:getGhosts(self._attacker)
	if #ghosts == 0 then
		self:finished()
		return
	end

	local id, level = q.parseIDAndLevel(self._options.buff_id, 1, self._skill)
	local buffInfo = db:getBuffByID(id)
    if buffInfo == nil then
        self:finished()
        return
    end

    for _, actor in ipairs(ghosts) do
    	actor:applyBuff(self._options.buff_id, self._attacker, self._skill)
    	if not self._options.no_cancel then
    		self._director:addBuffId(self._options.buff_id, actor) 
    	end
    end

    self:finished()
end

function QSBGhostApplyBuff:getGhosts(actor)
	local actorGhosts = {}
	local totoalGhosts = actor:getType() == ACTOR_TYPES.NPC and app.battle:getEnemyGhosts() or app.battle:getHeroGhosts()

	for _, ghostObj in ipairs(totoalGhosts) do
		if not ghostObj.actor:isDead() then
			if ghostObj.summoner == actor then
				table.insert(actorGhosts, ghostObj.actor)
			end
		end
	end

	return actorGhosts
end	

return QSBGhostApplyBuff