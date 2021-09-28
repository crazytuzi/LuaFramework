--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleMgr.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-17 11:11
-- 版  本:	1.0
-- 描  述:	protobuf中的数据处理
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--battleturn 中添加 be_damage
function CBattleMgr:addBe_damage()
	if not self.tbBattleTurn.be_damage then
		self.tbBattleTurn.be_damage = {}
	end
	
	local nLen = #self.tbBattleTurn.be_damage
	nLen = nLen + 1
	self.tbBattleTurn.be_damage[nLen] = {}
	return self.tbBattleTurn.be_damage[nLen]
end

--battleturn 中添加 actioncardlist
function CBattleMgr:addActioncardlist()
	if not self.tbBattleTurn.actioncardlist then
		self.tbBattleTurn.actioncardlist = {}
	end
	
	local nLen = #self.tbBattleTurn.actioncardlist
	nLen = nLen + 1
	self.tbBattleTurn.actioncardlist[nLen] = {}
	return self.tbBattleTurn.actioncardlist[nLen]
end

function CBattleMgr:getCurrentActioncardList()
	local nLen = #self.tbBattleTurn.actioncardlist
	return self.tbBattleTurn.actioncardlist[nLen]
end

--battleturn 中添加 die_drop_info
function CBattleMgr:addDie_drop_info(bEffect)
	if bEffect then
		if not self.tbBattleTurn.die_drop_info then
			self.tbBattleTurn.die_drop_info = {}
		end
		
		local nLen = #self.tbBattleTurn.die_drop_info
		nLen = nLen + 1
		self.tbBattleTurn.die_drop_info[nLen] = {}
		return self.tbBattleTurn.die_drop_info[nLen]
	else
		local tbActioncardList = self:getCurrentActioncardList()
		if not tbActioncardList.die_drop_info then
			tbActioncardList.die_drop_info = {}
		end
		
		local nLen = #tbActioncardList.die_drop_info
		nLen = nLen + 1
		tbActioncardList.die_drop_info[nLen] = {}
		return tbActioncardList.die_drop_info[nLen]
	end
end

--添加 damagetype
function CBattleMgr:addDamagetype(nDamageType, bEffect)
	if bEffect then
		if not self.tbBattleTurn.damagetype then
			self.tbBattleTurn.damagetype = {}
		end
		
		local nLen = #self.tbBattleTurn.damagetype
		nLen = nLen + 1
		self.tbBattleTurn.damagetype[nLen] = nDamageType
	else
		local tbActioncardList = self:getCurrentActioncardList()
		if not tbActioncardList.damagetype then
			tbActioncardList.damagetype = {}
		end
		
		local nLen = #tbActioncardList.damagetype
		nLen = nLen + 1
		tbActioncardList.damagetype[nLen] = nDamageType
	end
end

--合击类型
function CBattleMgr:addFitDamage(nPosInBattleMgr, nDamage)
	if not self.tbBattleTurn.tbFitDamage then
		self.tbBattleTurn.tbFitDamage = {}
	end
	
	local tbFit = {}
	
	local tbFighterSequence = self.tbFighterSequenceList[self.nCurrentSequence]
	tbFit.apos = 500 + (tbFighterSequence.atkno*10) + nPosInBattleMgr
	tbFit.damage = nDamage
	
	table.insert(self.tbBattleTurn.tbFitDamage, tbFit)
end

--n连击
function CBattleMgr:addRepeatedDamage(nDamage)
	local tbActioncardList = self:getCurrentActioncardList()
	if not tbActioncardList.tbRepeatedDamage then
		tbActioncardList.tbRepeatedDamage = {}
	end
	table.insert(tbActioncardList.tbRepeatedDamage, nDamage)
end








