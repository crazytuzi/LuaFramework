--
-- Author: Stephen
-- Date: 2015-5-13
--

local TFLengthArray = require('lua.public.TFLengthArray')
local GameResourceManager = class("GameResourceManager")

function GameResourceManager:ctor()
	self.m_ourRolelist = {}
	self.m_enemyList = TFLengthArray:new(6)
	self.m_nowLevel = 0

	self.m_npclist = {}
	self.m_removeNpclist = TFLengthArray:new(4)
end

function GameResourceManager:addRole( role_id , armature )
	if self.m_ourRolelist[role_id] ~= nil then
		return
	end
	self.m_ourRolelist[role_id] = {}
	self.m_ourRolelist[role_id].m_armature = armature
	armature:retain()
end

function GameResourceManager:addRoleEffect( role_id , effect_id , armature )
	if self.m_ourRolelist[role_id] == nil then
		return
	end
	if self.m_nowLevel > 1 then
		self.m_nowLevel = 1
	end
	local role = self.m_ourRolelist[role_id]
	if role.effect == nil then 
		role.effect = {}
	end
	if role.effect[effect_id] == nil then
		role.effect[effect_id] = armature
		armature:retain()
	end
end

function GameResourceManager:removeRole( role_id )
	local role = self.m_ourRolelist[role_id]
	if role == nil then
		return
	end
	role.m_armature:release()
	if role.effect then
		for k,v in pairs(role.effect) do
			v:release()
		end
	end
	self.m_ourRolelist[role_id] = nil
end



function GameResourceManager:addEnemy( role_id , armature )
	self.m_nowLevel = 0
	local enemy = {}
	enemy.m_id = role_id
	enemy.m_armature = {}
	enemy.m_armature.armature = armature
	if self.m_enemyList:indexByKey("m_id" , enemy) == -1 then
		armature:retain()
	end
	self.m_enemyList:push("m_id" , enemy)
	if self.m_enemyList:length() > self.m_enemyList.m_maxLength then
		local temp = self.m_enemyList:pop()
		print("addEnemy  remove id == ",temp.m_id)
		if temp and temp.m_armature then
			for k,v in pairs(temp.m_armature) do
				v:release();
				v = nil
			end
		end
		temp.m_armature = nil
	end

end

function GameResourceManager:addEnemyEffect( role_id , effect_id , armature )
	for v in self.m_enemyList:iterator() do
		if v.m_id == role_id then
			if v.m_armature[effect_id] == nil then
				v.m_armature[effect_id] = armature
				armature:retain()
			end
			return
		end
	end
end

function GameResourceManager:clearRoleEffect( )
	for _,role in pairs(self.m_ourRolelist) do
		if role and role.effect then
			for __,k in pairs(role.effect) do
				k:release()
			end
			role.effect = nil
		end
	end
end

function GameResourceManager:clearRole( )
	for _,v in pairs(self.m_ourRolelist) do
		if v and v.m_armature then
			v.m_armature:release()
		end
		if v and v.effect then
			for __,k in pairs(v.effect) do
				k:release()
			end
			v.effect = nil
		end
	end
	-- self.m_ourRolelist = nil
	self.m_ourRolelist = {}
end

function GameResourceManager:clearEnemyList()
	while self.m_enemyList:length() > 0  do
		local temp = self.m_enemyList:pop()
		if temp then
			for k,v in pairs(temp.m_armature) do
				v:release();
			end
		end
	end
end

function GameResourceManager:useTime( role_id )
	local num = 0
	for k,v in pairs(self.m_ourRolelist) do
		if k == role_id then
			num = num + 1
		end
	end
	for v in self.m_enemyList:iterator() do
		if v.m_id == role_id then
			num = num + 1
		end
	end
	return num
end

function GameResourceManager:clearAll()
	self:clearEnemyList()
	self:clearRoleEffect()
	me.ArmatureDataManager:removeUnusedArmatureInfo()
	CCDirector:sharedDirector():purgeCachedData()
end

function GameResourceManager:MemoryWarning()
	if self.m_nowLevel == 0 then
		self:clearEnemyList()
		self.m_nowLevel = 1
		return true
	elseif self.m_nowLevel == 1 then
		self:clearRoleEffect()
		self.m_nowLevel = 2
		return true
	else
		return false
		-- self:clearRole()
	end
	return true
end

function GameResourceManager:getRoleAniById( id )
	-- print("GameResourceManager:getRoleAniById( id )",id)
	local roleTableData = RoleData:objectByID(id)
	local armatureID = roleTableData.image
	local resPath = "armature/"..armatureID..".xml"
	if TFFileUtil:existFile(resPath) then
		TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	else
		armatureID = 10006
		TFResourceHelper:instance():addArmatureFromJsonFile("armature/"..armatureID..".xml")
	end
	local armature = TFArmature:create(armatureID.."_anim")
	if armature == nil then
		assert(false, "armature"..armatureID.."create error")
		return
	end
	if self.m_npclist[id] == nil then
		if self:fromRemoveToNpc(id) then
			self.m_npclist[id] = {}
			self.m_npclist[id].num = 1
			self.m_npclist[id].armature = armature
			self.m_npclist[id].armature:retain()
		end
	end
	self.m_npclist[id].num = self.m_npclist[id].num + 1

	return armature
end

function GameResourceManager:fromRemoveToNpc( id )
	for v in self.m_removeNpclist:iterator() do
		if v.id == id then
			self.m_npclist[id] = {}
			self.m_npclist[id].num = 1
			self.m_npclist[id].armature = v.armature
			self.m_removeNpclist:removeObject(v)
			return false
		end
	end
	return true
end

function GameResourceManager:deleRoleAniById( id )
	-- print("GameResourceManager:deleRoleAniById( id )",id)
	if self.m_npclist[id] == nil then
		return
	end
	self.m_npclist[id].num = self.m_npclist[id].num - 1
	-- print("self.m_npclist[id].num ",self.m_npclist[id].num )
	if self.m_npclist[id].num == 1 then
		if self.m_removeNpclist:length() == 4 then
			local temp = self.m_removeNpclist:pop()
			temp.armature:release()
			temp = nil
		end
		local temp = {}
		temp.id = id
		temp.armature = self.m_npclist[id].armature
		self.m_removeNpclist:pushBack(temp)
		self.m_npclist[id] = nil
	end
end

function GameResourceManager:UIMemoryWarning()
	for k,v in pairs(self.m_npclist) do
		self:deleRoleAniById(k)
	end
	for v in self.m_removeNpclist:iterator() do
		v.armature:release()
		v = nil
	end
	self.m_removeNpclist:clear()

end

return GameResourceManager:new()
