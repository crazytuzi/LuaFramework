_G.classlist['ObjectPool'] = 'ObjectPool'
_G.ObjectPool = CSingle:new()
CSingleManager:AddSingle(ObjectPool)
_G.ObjectPool.objName = 'ObjectPool'
ObjectPool.pool = {}
ObjectPool.TypeMapElementVO = 1
ObjectPool.TypeBuff = 2
ObjectPool.TypeParticlePlayer = 3
ObjectPool.TypeMonsterAvatar = 4
ObjectPool.TypeDropItemAvatar = 5
ObjectPool.TypeMonster = 6
ObjectPool.TypeDropItem = 7

-- 已借出对象数目 
ObjectPool.typeDic = {}

-- 已借出对象数目 
ObjectPool.activeNum = {
	[ObjectPool.TypeMapElementVO] = 0,
	[ObjectPool.TypeBuff] = 0,
	[ObjectPool.TypeParticlePlayer] = 0,
	[ObjectPool.TypeMonsterAvatar] = 0,
	[ObjectPool.TypeDropItemAvatar] = 0,
	[ObjectPool.TypeMonster] = 0,
	[ObjectPool.TypeDropItem] = 0,
}

--对象池中所能申请的对象数目上限
ObjectPool.maxNum = 100 

ObjectPool.addNum = 0
ObjectPool.delNum = 0

function ObjectPool:Create()
	ObjectPool.typeDic = {
		[ObjectPool.TypeMapElementVO] = MapElementVO,
		[ObjectPool.TypeBuff] = Buff,
		[ObjectPool.TypeParticlePlayer] = ParticlePlayer,
		[ObjectPool.TypeMonsterAvatar] = MonsterAvatar,
		[ObjectPool.TypeDropItemAvatar] = DropItemAvatar,
		[ObjectPool.TypeMonster] = Monster,
		[ObjectPool.TypeDropItem] = DropItem,
	}

	return true
end

-- 借出对象
-- 已借出对象数目 
ObjectPool.totalNewNum = {
	[ObjectPool.TypeMapElementVO] = 0,
	[ObjectPool.TypeBuff] = 0,
	[ObjectPool.TypeParticlePlayer] = 0,
	[ObjectPool.TypeMonsterAvatar] = 0,
	[ObjectPool.TypeDropItemAvatar] = 0,
	[ObjectPool.TypeMonster] = 0,
	[ObjectPool.TypeDropItem] = 0
}
function ObjectPool:GetObject(poolType)
	local curObj = nil
	if not ObjectPool:IsEmpty(poolType) then
		curObj = table.remove(ObjectPool.pool[poolType])
	else
		self.totalNewNum[poolType] = self.totalNewNum[poolType] + 1
		-- FPrint('NewObject:'..poolType..':'..self.totalNewNum[poolType])
		local typeClass = self.typeDic[poolType]
		if not typeClass then FPrint('没有对象类型'..poolType) return end
		curObj = typeClass:new()
	end
	
	-- 增加已借出对象数目  
	ObjectPool.activeNum[poolType] = ObjectPool.activeNum[poolType] + 1
	ObjectPool.addNum = ObjectPool.addNum + 1
	--FPrint('add'..ObjectPool.addNum)
	-- FPrint('空闲活跃 poolType: ' .. poolType .. "空闲活跃 number" ..ObjectPool:GetIdleNum(poolType)..':'..ObjectPool:GetActiveNum(poolType))
	return curObj
end


-- 返回对象
function ObjectPool:RetuenObject(poolType, poolObject)
	if not ObjectPool.pool[poolType] then
		ObjectPool.pool[poolType] = {}
	end
	if poolObject.Clear then
		poolObject:Clear()
	end
	--FPrint(type(poolObject))
	table.insert(ObjectPool.pool[poolType], poolObject)
	-- 减少已借出对象数目  
	ObjectPool.delNum = ObjectPool.delNum + 1
	--FPrint('del'..ObjectPool.delNum)
	ObjectPool.activeNum[poolType] = ObjectPool.activeNum[poolType] - 1
	
	-- FPrint('空闲活跃 poolType: ' .. poolType .. "空闲活跃 number" ..ObjectPool:GetIdleNum(poolType)..':'..ObjectPool:GetActiveNum(poolType))
end

-- 最大数量
function ObjectPool:GetMaxNum()
	return ObjectPool.maxNum
end

-- 已借出数量
function ObjectPool:GetActiveNum(poolType)
	return ObjectPool.activeNum[poolType]
end

-- 空闲数量
function ObjectPool:GetIdleNum(poolType)
	if ObjectPool.pool[poolType] then
		return #ObjectPool.pool[poolType]
	end
	
	return 0
end

-- 清空
function ObjectPool:Clear(poolType)
	ObjectPool.pool[poolType] = nil
end

-- 关闭
function ObjectPool:Close()

end

-- 是否为空
function ObjectPool:IsEmpty(poolType)
	if ObjectPool.pool[poolType] and #ObjectPool.pool[poolType] > 0 then
		return false
	end
	
	return true
end