local QSBAction = import(".QSBAction")
local QSBPlayMonsterString = class("QSBPlayMonsterString", QSBAction)

function QSBPlayMonsterString:_execute(dt)
	if IsServerSide then
		self:finished()
        return
    end
	local actor = self._attacker
	local monsters = app.battle._monsters
	local monster
	for k,v in pairs(monsters) do
		if v.npc == actor then
			monster = v
		elseif v.npc_summoned then
			for id,npc in pairs(v.npc_summoned) do
				if npc == actor then
					monster = v
					v.bullshit_id = id
					break
				end
			end
		end

		if monster then
			break
		end
	end
	if nil == monster then
		self:finished()
		return
	end
	local id = tostring(self._options.monster_string_id)
	local monster_string = db:getMonsterStringByID(id)
	if monster_string then
		local bullshitobjs = monster.bullshitobjs or {}
		table.insert(bullshitobjs,{cat = "behavior", value = nil, bullshit = monster_string.string, duration = monster_string.duration, type = monster_string.type})
		monster.bullshitobjs = bullshitobjs
	end
	self:finished()
end

return QSBPlayMonsterString