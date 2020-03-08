local tbItem = Item:GetClass("WeddingDress")

tbItem.nParamLevel = 1
tbItem.nParamGender = 2
tbItem.nEmptyWeaponId = 301	--空武器模型id

function tbItem:OnUse(it)
	if not Map:IsCityMap(me.nMapTemplateId) and
		not Map:IsHouseMap(me.nMapTemplateId) and
		not Map:IsKinMap(me.nMapTemplateId) then

		me.CenterMsg("婚服只允许在主城、新手村、家族属地、家园中使用");
		return 0;
	end

	if not Env:CheckSystemSwitch(me, Env.SW_ChuangGong) then
		me.CenterMsg("当前状态下不允许使用");
		return
	end

	local nGender = KItem.GetItemExtParam(it.dwTemplateId, self.nParamGender)
	if me.nSex~=nGender then
		me.CenterMsg("此婚服与你的性别不符")
		return 0
	end

	if me.bWeddingDressOn then
		me.CenterMsg("你已经穿上婚服了")
		return 0
	end

	local nWeddingLevel = KItem.GetItemExtParam(it.dwTemplateId, self.nParamLevel)
	local tbResIds = Wedding.tbDressPartResIds[nWeddingLevel]
	if not tbResIds or not next(tbResIds) then
		Log("[x] WeddingDress:OnUse, no resids", tostring(nWeddingLevel))
		return 0
	end

	local szShape = ActionInteract:GetFactionShape(me.nFaction, nGender)
	local tbIds = tbResIds[szShape]
	if not tbIds or not next(tbIds) then
		Log("[x] WeddingDress:OnUse, no shape ids", nWeddingLevel, me.nFaction, nGender, szShape)
		return 0
	end

	local pNpc = me.GetNpc()
	local nHead, nBody = unpack(tbIds)
	if nHead then
		pNpc.ModifyPartFeatureEquip(Npc.NpcResPartsDef.npc_part_head, nHead)
	end
	if nBody then
		pNpc.ModifyPartFeatureEquip(Npc.NpcResPartsDef.npc_part_body, nBody)
	end
	pNpc.ModifyPartFeatureEquip(Npc.NpcResPartsDef.npc_part_weapon, self.nEmptyWeaponId)
	pNpc.ModifyPartFeatureEquip(Npc.NpcResPartsDef.npc_part_weapon, 0, Npc.NpcPartLayerDef.npc_part_layer_effect)

	Wedding:ChangeDressState(me, true)

	return 0
end
