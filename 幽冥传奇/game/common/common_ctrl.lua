
CommonCtrl = CommonCtrl or BaseClass(BaseController)

function CommonCtrl:__init()
	if CommonCtrl.Instance then
		ErrorLog("[CommonCtrl]:Attempt to create singleton twice!")
	end
	CommonCtrl.Instance = self
	
	RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleDataChange, self))
	BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EquipData.Instance:AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
end

function CommonCtrl:__delete()
	CommonCtrl.Instance = nil
end

function CommonCtrl:OnRoleDataChange(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_BIND_COIN then
		RemindManager.Instance:DoRemindDelayTime(RemindName.InnerLevelCanUp)
	elseif key == OBJ_ATTR.ACTOR_INNER_LEVEL then
		RemindManager.Instance:DoRemindDelayTime(RemindName.InnerLevelCanUp)
		RemindManager.Instance:DoRemindDelayTime(RemindName.InnerEquip)
	elseif key == OBJ_ATTR.ACTOR_CIRCLE_SOUL then
		RemindManager.Instance:DoRemindDelayTime(RemindName.CanZhuansheng)
	elseif key == OBJ_ATTR.CREATURE_LEVEL then
		RemindManager.Instance:DoRemindDelayTime(RemindName.CanZhuansheng)
		RemindManager.Instance:DoRemindDelayTime(RemindName.HeartEquip)
		-- RemindManager.Instance:DoRemindDelayTime(RemindName.CanExchangeZhuanSheng)
		-- RemindManager.Instance:DoRemindDelayTime(RemindName.CanExchangeLunHui)
	elseif key == OBJ_ATTR.ACTOR_CIRCLE then
		RemindManager.Instance:DoRemindDelayTime(RemindName.CanExchangeFuwen)
		RemindManager.Instance:DoRemindDelayTime(RemindName.HeartEquip)
		-- RemindManager.Instance:DoRemindDelayTime(RemindName.CanExchangeZhuanSheng)
		-- RemindManager.Instance:DoRemindDelayTime(RemindName.CanExchangeLunHui)
	end
end

function CommonCtrl:OnBagItemChange()
	-- 神炉的提升消耗背包中的物品
	RemindManager.Instance:DoRemindDelayTime(RemindName.TheDragonCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShieldCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.GemStoneCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.DragonSpiritCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.FireGodPowerCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.HeartEquip)
	RemindManager.Instance:DoRemindDelayTime(RemindName.GodFurnaceShenDingCanUp)
	
	-- 角色提醒
	RemindManager.Instance:DoRemindDelayTime(RemindName.InnerEquip)
	-- RemindManager.Instance:DoRemindDelayTime(RemindName.GodEquipCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.GodEquipCanDecompose)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ChuanShiCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.RexueCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.BetterFuwen)
	RemindManager.Instance:DoRemindDelayTime(RemindName.FuwenCanZhuling)
	RemindManager.Instance:DoRemindDelayTime(RemindName.CanDecomposeFuwen)
	RemindManager.Instance:DoRemindDelayTime(RemindName.CanExchangeFuwen)

	-- 图鉴
	-- RemindManager.Instance:DoRemindDelayTime(RemindName.CardCanDescompose)
	-- RemindManager.Instance:DoRemindDelayTime(RemindName.CardHandlebook)
end

function CommonCtrl:OnChangeOneEquip()
	-- RemindManager.Instance:DoRemindDelayTime(RemindName.GodEquipCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ChuanShiCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.RexueCanUp)
end
