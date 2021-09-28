local role = import(".role")
local npc = class("npc", role)
npc.ctor = function (self, params)
	npc.super.ctor(self, params)
	self.initEnd(self)

	return 
end
npc.getParts = function (self, feature)
	local parts = {}
	local race = feature.race
	local appr = feature.dress
	local npcId = def.role.getRoleId(race, appr)
	local dressFrame = def.role.getDressFrame(npcId)

	if appr < 256 then
		local dargon = 70 <= appr and appr <= 75

		if dargon then
			parts.hair = {
				cannotMove = true,
				blend = true,
				id = appr,
				imgid = def.role.getNpc(npcId).img,
				offset = def.role.getNpcOffset(npcId) + 4,
				frame = dressFrame,
				direction = def.role.getNpc(npcId).direction
			}
		end

		parts.dress = {
			id = appr,
			imgid = def.role.getNpc(npcId).img,
			offset = def.role.getNpcOffset(npcId),
			frame = dressFrame,
			cannotMove = dargon,
			direction = def.role.getNpc(npcId).direction
		}
	else
		print("暂不支持的npc类型:", appr)
	end

	return parts
end
npc.addAct = function (self, params)
	local npcId = def.role.getRoleId(self.getRace(self), self.getAppr(self))
	local frame = def.role.getFrame(npcId)

	if frame[params.type] and frame[params.type].otherEffect then
		params.otherEffect = frame[params.type].otherEffect
	end

	npc.super.addAct(self, params)

	return 
end
npc.updateSpriteForState = function (self, type, sprite)
	local function update(t, spr)
		local state = self.last.state
		local npcId = def.role.getRoleId(self:getRace(), self:getAppr())

		if def.role.stateHas(state, "stCeleb") then
			def.role.changeStandFrame(npcId, "dress", "stCeleb")

			self.parts.dress.frame = def.role.getDressFrame(npcId)
		else
			def.role.resetRoleFrame(npcId)

			self.parts.dress.frame = def.role.getDressFrame(npcId)
		end

		return 
	end

	if type and sprite then
		return slot3(type, sprite)
	end

	for k, v in pairs(self.sprites) do
		update(k, v)
	end

	return 
end

return npc
