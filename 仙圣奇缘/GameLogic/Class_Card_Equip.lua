--------------------------------------------------------------------------------------
-- 文件名:	Class_Card.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-21 11:24
-- 版  本:	1.0
-- 描  述:	
-- 应  用:
---------------------------------------------------------------------------------------

--获取伙伴镶嵌装备ID
function Class_Card:getEquipIdList()
	return self.tbEquipIdList
end

--通过位置获取伙伴镶嵌装备ID
function Class_Card:getEquipIDByPos(nPos)
	return self.tbEquipIdList[nPos]
end

function Class_Card:getEquipSubTypeByPos(nPos)
	local tbEquip = g_Hero:getEquipObjByServID(self.tbEquipIdList[nPos])
	return tbEquip:getSubType()
end

function Class_Card:getEquipTypeByPos(nPos)
	local tbEquip = g_Hero:getEquipObjByServID(self.tbEquipIdList[nPos])
	return tbEquip:getType()
end

--通过位置获取伙伴镶嵌装备Tb
function Class_Card:getEquipTbByPos(nPos)
	return g_Hero:getEquipObjByServID(self.tbEquipIdList[nPos])
end

--设置某个装备部位装备的装备ID
function Class_Card:changeEquipIDByPos(nPos, nServerID, strOperationType, GameObj_EquipOld, GameObj_EquipNew)
	if (nPos and nServerID) then
		self.tbEquipIdList[nPos] = nServerID
		self:reCalculateCardEquipAllProps(strOperationType, GameObj_EquipOld, GameObj_EquipNew)
	end
end
