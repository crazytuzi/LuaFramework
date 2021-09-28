GodFightRuneModel =BaseClass(LuaModel)

function GodFightRuneModel:__init()
	self:InitData()
	self:InitEvent()
end

function GodFightRuneModel:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GodFightRuneModel.inst = nil
end

function GodFightRuneModel:InitData()
	self.weaponData = {} --已经穿戴的主武器数据（改成铭文槽个数）
	self.godFightRuneData = {} --斗神印材料数据
	self.inscriptionData = {} --铭文信息
end

function GodFightRuneModel:InitEvent()
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE ,function ()
		self:HandleBagChange()
	end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.EQUIPINFO_CHANGE , function()
		self:HandleEquipmentChange()
	end)
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.BAG_INITED , function ()
		self:HandleBagInited()
		self:ShowRedTips()
	end)
end

--是否装备铭文
function GodFightRuneModel:IsPutOn()
	local result = false
	for i = 1, #self.inscriptionData do
		if self.inscriptionData[i].inscriptionId ~= 0 then
			result = true
		end
	end
	return result
end

function GodFightRuneModel:SetData(listPlayerWeaponEffect)
	if listPlayerWeaponEffect then
		self:SetInscriptionData(listPlayerWeaponEffect)
	end
end

function GodFightRuneModel:SetInscriptionData(listPlayerWeaponEffect)
	if listPlayerWeaponEffect then
		self:CleanInscriptionData()
		for index = 1, #listPlayerWeaponEffect do
			local weaponEffect = {}
			weaponEffect.slotPos = listPlayerWeaponEffect[index].holeId
			weaponEffect.inscriptionId = listPlayerWeaponEffect[index].effectId
			weaponEffect.effectId = listPlayerWeaponEffect[index].baseId
			weaponEffect.attrValue = listPlayerWeaponEffect[index].proValue
			weaponEffect.effectType = listPlayerWeaponEffect[index].type
		
			local curInscEffectVo = InscriptionEffectVo.New()
			curInscEffectVo:InitVo(weaponEffect)

			table.insert(self.inscriptionData, curInscEffectVo)
		end

		table.sort(self.inscriptionData, function(a, b)
			self:InscriptionDataSortFun(a, b)
		end)
	end
end

function GodFightRuneModel:InscriptionDataSortFun(a, b)
	if a and  b then
		if a.slotPos ~= nil and b.slotPos ~= nil then
			return a.slotPos < b.slotPos
		end
	end
end

function GodFightRuneModel:GetInscriptionData()
	return self.inscriptionData
end

function GodFightRuneModel:SyncInscriptionData(inscriptionDataHasChanged)
	if inscriptionDataHasChanged then
		for changeIndex = 1, #inscriptionDataHasChanged do
			local curInscriptionData = inscriptionDataHasChanged[changeIndex]
			local isHas, isHasIndex = self:IsHasInscriptionDataByHoldId(curInscriptionData.holeId)
			if isHas == true and isHasIndex ~= -1 then
				--update inscriptionData
				if self.inscriptionData[isHasIndex] ~= nil then
					self.inscriptionData[isHasIndex].inscriptionId = curInscriptionData.effectId
					self.inscriptionData[isHasIndex].effectId = curInscriptionData.baseId
					self.inscriptionData[isHasIndex].attrValue = curInscriptionData.proValue
					self.inscriptionData[isHasIndex].effectType = curInscriptionData.type
				end
			else
				local weaponEffect = {}
				weaponEffect.slotPos = curInscriptionData.holeId
				weaponEffect.inscriptionId = curInscriptionData.effectId
				weaponEffect.effectId = curInscriptionData.baseId
				weaponEffect.attrValue = curInscriptionData.proValue
				weaponEffect.effectType = curInscriptionData.type

				local curInscEffectVo = InscriptionEffectVo.New()
				curInscEffectVo:InitVo(weaponEffect)
				table.insert(self.inscriptionData, curInscEffectVo)
				
			end
		end

		table.sort(self.inscriptionData, function(a, b)
			self:InscriptionDataSortFun(a, b)
		end)
	end
end

function GodFightRuneModel:IsHasInscriptionDataByHoldId(holeId)
	local rtnIsHas = false
	local rtnIndex = -1
	if holeId then
		for index = 1, #self.inscriptionData do
			if self.inscriptionData[index].slotPos == holeId then
				rtnIsHas = true
				rtnIndex = index
				break
			end
		end
	end
	return rtnIsHas, rtnIndex
end

function GodFightRuneModel:CleanInscriptionData()
	for index = 1, #self.inscriptionData do
		self.inscriptionData[index]:Destroy()
	end
	self.inscriptionData = {}
end

function GodFightRuneModel:GetInstance()
	if GodFightRuneModel.inst == nil then
		GodFightRuneModel.inst = GodFightRuneModel.New()
	end
	return GodFightRuneModel.inst
end

function GodFightRuneModel:HandleBagChange()
	self:SetGodFightRuneData()
	GlobalDispatcher:DispatchEvent(EventName.RefershGodFightRune)
	self:ShowRedTips()
end

function GodFightRuneModel:HandleEquipmentChange()
	self:SetWeaponData()
	self:DispatchEvent(GodFightRuneConst.EquipmentChange)
	self:ShowRedTips()
end

function GodFightRuneModel:HandleBagInited()
	self:SetWeaponData()
	self:SetGodFightRuneData()
end

function GodFightRuneModel:SetWeaponData()
	self:CleanWeaponData()
	self.weaponData = PkgModel:GetInstance():GetOnEquipByEquipType(GoodsVo.EquipPos.Weapon01) or {}
end

function GodFightRuneModel:GetHoldIdByIndex(index)
	local rtnHoldId = -1
	if index and index ~= 0 then
		if not TableIsEmpty(self.inscriptionData) then
			for i = 1, #self.inscriptionData do
				if i == index then
					rtnHoldId = self.inscriptionData[i].slotPos or -1
					break
				end
			end
		else
			rtnHoldId = index
		end
	end
	return rtnHoldId
end

function GodFightRuneModel:SetGodFightRuneData()
	self:CleanGodFightRuneData()
	local onGrids = PkgModel:GetInstance():GetOnGrids()
	for index = 1 , #onGrids do
		local curGird = onGrids[index]
		if self:IsGodFightRune(curGird.bid) then
			local runeVo = RuneVo.New()
			runeVo:InitVo(curGird)
			table.insert(self.godFightRuneData , runeVo)
		end
	end
end

--是否是铭文石
--只显示符合本职业的
function GodFightRuneModel:IsGodFightRune(bid)
	local rtnIs = false
	local itemCfg = GetCfgData("item"):Get(bid)
	local playerCareer = LoginModel:GetInstance():GetLoginRole().career
	if not TableIsEmpty(itemCfg) then
		if itemCfg.tinyType == GoodsVo.TinyType.randomInscriptions or itemCfg.tinyType == GoodsVo.TinyType.orientationInscriptions then
			if playerCareer and ((itemCfg.needJob == playerCareer and itemCfg.needJob ~= 0) or (itemCfg.needJob == 0)) then
				rtnIs = true
			end
		end
	end
	return rtnIs
end

function GodFightRuneModel:GodFightRuneDataSortFun(runeVoA , runeVoB)
	if runeVoA and runeVoB then
		return runeVoA:GetItemId() > runeVoB:GetItemId()
	end
end

function GodFightRuneModel:GetGodFightRuneDataByIndex(index)
	local runeVoData = nil
	if index then
		if self.godFightRuneData[index] ~= nil then
			runeVoData = {}
			runeVoData = self.godFightRuneData[index]
		end
	end
	return runeVoData
end

--0为全部（1-3级）
function GodFightRuneModel:GetGodFightRuneDataByLevel(level)
	local rtnRuneList = {}
	if level and self.godFightRuneData then
		for index = 1, #self.godFightRuneData do
			if level == 0 then
				if self.godFightRuneData[index]:GetLevel() <= GodFightRuneConst.GodFIghtRuneMaxLev then
					table.insert(rtnRuneList, self.godFightRuneData[index])
				end
			else
				if self.godFightRuneData[index]:GetLevel() == level then
					table.insert(rtnRuneList, self.godFightRuneData[index])
				end
			end
		end
	end
	return rtnRuneList
end

function GodFightRuneModel:GetGodFightRuneIndexByGroupId(playerBagId)
	local rtnIndex = -1
	if playerBagId then
		for index = 1, #self.godFightRuneData do
			if self.godFightRuneData[index]:GetPlayerBagId() == playerBagId then
				rtnIndex = index
				break
			end
		end
	end
	return rtnIndex
end

function GodFightRuneModel:CleanGodFightRuneData()
	for index = 1, #self.godFightRuneData do
		self.godFightRuneData[index]:Destroy()
	end
	self.godFightRuneData = {}
end

function GodFightRuneModel:CleanWeaponData()
	self.weaponData = {}
end


function GodFightRuneModel:GetWeaponData()
	return self.weaponData
end

function GodFightRuneModel:GetGodFightRuneData()
	return self.godFightRuneData
end

function GodFightRuneModel:IsHasGodFightRune(playerBagId)
	local ishas = false
	local isHasIndex = -1
	if playerBagId then
		for index = 1, #self.godFightRuneData do
			local curRuneData = self.godFightRuneData[index]
			if not TableIsEmpty(curRuneData) then
				if curRuneData.playerBagId == playerBagId then
					isHas = true
					isHasIndex = index
					break
				end
			end
		end
	end
	return isHas, isHasIndex
end

function GodFightRuneModel:GetSkillCfgInfo(skillId)
	local skillInfo = {}
	if skillId ~= nil then
		local skillCfg = GetCfgData("skill_CellNewSkillCfg"):Get(skillId)
		if skillCfg ~= nil then
			skillInfo = skillCfg
		end
	end
	return skillInfo
end

function GodFightRuneModel:GetAttrCfgInfo(attrId)
	local attrInfo = {}
	if attrId ~= nil then
		local attrCfg = GetCfgData("proDefine"):Get(attrId)
		if not TableIsEmpty(attrCfg) then
			attrInfo = attrCfg
		end
	end
	return attrInfo
end

function GodFightRuneModel:GetInscriptionDesc(instanceId)
	local rtnStrDesc = ""
	if instanceId then
		local isHasIndex = self:GetGodFightRuneIndexByGroupId(instanceId)
		if isHasIndex ~= -1 then
			local godFightRuneData = self.godFightRuneData[isHasIndex] or {}
			if not TableIsEmpty(godFightRuneData) then
				local itemCfg = godFightRuneData:GetCfg()
				if not TableIsEmpty(itemCfg) then
					rtnStrDesc = itemCfg.des
				end
			end
		end
	end
	return rtnStrDesc
end

--主界面斗神印按钮红点提示
--规则：
--（出现）有没镶嵌铭文石的孔（可镶嵌铭文石的孔），而且背包中有本职业铭文石
--（消失）空余孔位没有可镶嵌的铭文石
function GodFightRuneModel:ShowRedTips()
	local isShow = false
	local isHasEmptySlot = false
	if not TableIsEmpty(self.weaponData) then
		for index = 1 , self.weaponData.holeNum do
			local isHas , hasIndex = self:IsHasInscriptionDataByHoldId(index)
			local curInscriptionData = self.inscriptionData[hasIndex] or {}
			if not isHas or TableIsEmpty(curInscriptionData) or curInscriptionData.inscriptionId == 0 then
				isHasEmptySlot = true
				break
			end
		end
	end

	if isHasEmptySlot then
		if not TableIsEmpty(self.godFightRuneData) then
			isShow = true
		end
	end
	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.godFightRune , state = isShow})
end

function GodFightRuneModel:Reset()
	self.weaponData = {} --已经穿戴的主武器数据（改成铭文槽个数）
	self.godFightRuneData = {} --斗神印材料数据
	self.inscriptionData = {} --铭文信息
end