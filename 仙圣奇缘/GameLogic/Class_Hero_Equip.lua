--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	装备数据
-- 应  用:
---------------------------------------------------------------------------------------

--初始化角色伙伴列表
function Class_Hero:initEquipList(tbData)
	self.tbEquipList = {}
	local tbEquipList = tbData.equip_info
	if(tbEquipList ) then
		for i = 1, #tbEquipList do
			local tbEquip = tbEquipList[i]
			local obj_Equip = Class_Equip.new()
			local nServerID = obj_Equip:initEquipData(tbEquip)
			self.tbEquipList[nServerID] = obj_Equip
		end
	end
end

--玩家增加装备
function Class_Hero:addEquip(tbData)
	local obj_Equip = Class_Equip.new()
	local nServerID, nDropOwnerId  = obj_Equip:initEquipDropData(tbData)
	self.tbEquipList[nServerID] = obj_Equip
	if nDropOwnerId ~= 0 then
		local obj_Card = self:getCardObjByServID(nDropOwnerId)
		if obj_Card then
			obj_Card.tbEquipIdList[tbData.drop_owner_pos] = nServerID
		end
		return
	end
end

function Class_Hero:getEquipSellPrice(nCsvID, nStarLevel, nStrengthenLevel)
	local CSV_Equip = g_DataMgr:getEquipCsv(nCsvID, nStarLevel)
	local CSV_EquipStrengthenCost = g_DataMgr:getEquipStrengthenCostCsv(nStrengthenLevel)
	return math.floor(CSV_Equip.BasePrice + (CSV_EquipStrengthenCost.StrengthenCostSum*nStrengthenLevel*0.8))
end

--通过ID获取装备信息
function Class_Hero:getEquipObjByServID(nServerID)
	if(not nServerID or nServerID <= 0)then
		return nil
	end
	return self.tbEquipList[nServerID]
end

--删除某个装备
function Class_Hero:delEquopByServID(nServerID)
	if(not nServerID or nServerID <= 0)then
		return nil
	end
	self.tbEquipList[nServerID] = nil
end

function unEquipSort(one, two)
	local strengThenLev_A = one:getStrengthenLev()--强化等级
	local strengThenLev_B = two:getStrengthenLev()

	local reLevel_A = one:getCsvBase().StarLevel --星级 装备档次
	local reLevel_B = two:getCsvBase().StarLevel
	
	local equipType_A = one:getCsvBase().Type
	local equipType_B = two:getCsvBase().Type
	if reLevel_A ~= reLevel_B  then 
		return reLevel_A > reLevel_B
	elseif strengThenLev_A ~= strengThenLev_B then 
		return strengThenLev_A > strengThenLev_B
	else
		return equipType_A < equipType_B
	end
end

function Class_Hero:calculateUndressEquipNum()
	self.tbUndressEquipList = {}
    local tbEquipList = self:getEquipList()
    for _, tbChild in pairs(tbEquipList) do
	    if(tbChild:getOwnerID() <= 0)then
		    table.insert(self.tbUndressEquipList, tbChild)
	    end
    end
	table.sort(self.tbUndressEquipList, unEquipSort)
end

function Class_Hero:getUndressEquipList()
    self:calculateUndressEquipNum()
    return self.tbUndressEquipList
end

function Class_Hero:getUndressEquipListCount()
    self:calculateUndressEquipNum()
    return  #self.tbUndressEquipList
end

function Class_Hero:checkReportEquipNumFull()
	if self:getUndressEquipListCount()>=self:getMaxEquipNum() then
		local szText = g_DataMgr:getMsgContentCsv(2039)
		local curScene = CCDirector:sharedDirector():getRunningScene()
		g_ShowServerSysTips({text = szText.Description_ZH,layout = curScene})
		return true
	end
	return false
end

--获取装备列表
function Class_Hero:getEquipList()
	return self.tbEquipList
end