--------------------------------------------------------
-- 钻石萌宠
--------------------------------------------------------

DiamondPetData = DiamondPetData or BaseClass()

DiamondPetData.DIAMOND_PET_DATA_CHANGE = "diamond_pet_data_change"
DiamondPetData.OBTAIN_DIAMOND = "obtain_diamond"

function DiamondPetData:__init()
	if DiamondPetData.Instance then
		ErrorLog("[DiamondPetData]:Attempt to create singleton twice!")
	end
	DiamondPetData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		pet_lv = 0,			-- uchar萌宠激活等级
		excavate_times = 0, -- uchar当天已挖掘次数
		today_diamond = 0, 	-- uint当天获得的钻石
	}

	self.can_play_diamond_obtain = false -- 播放钻石获取特效

	self.bag_item_change = BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.BagItemChange, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.DiamondPetCanActivate)

	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.CREATURE_LEVEL, BindTool.Bind(self.OnRoleLvChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_CUTTING_LEVEL, BindTool.Bind(self.OnZSVipLevelChange, self))
end

function DiamondPetData:__delete()
	DiamondPetData.Instance = nil
end

----------设置----------

-- 接收钻石萌宠数据
function DiamondPetData:SetDiamondPetData(protocol)
	local old_today_diamond = self.data.today_diamond
	local old_excavate_times = self.data.excavate_times
	self.data.pet_lv = protocol.pet_lv
	self.data.excavate_times = protocol.excavate_times
	self.data.today_diamond = protocol.today_diamond

	self:DispatchEvent(DiamondPetData.DIAMOND_PET_DATA_CHANGE)

	if self.can_play_diamond_obtain then
		if old_excavate_times < self.data.excavate_times and old_today_diamond < self.data.today_diamond then
			DiamondPetCtrl.Instance:StartFlyItem()
			self:DispatchEvent(DiamondPetData.OBTAIN_DIAMOND, self.data.today_diamond - old_today_diamond)
		end
	else
		self.can_play_diamond_obtain = true
	end
	
	RemindManager.Instance:DoRemindDelayTime(RemindName.DiamondPetCanActivate)
end

--获取钻石萌宠数据
function DiamondPetData:GetDiamondPetData()
	return self.data
end

--------------------
function DiamondPetData:GetRemindIndex()
	local index = 0
	local cfg = DiamondsPetsConfig and DiamondsPetsConfig.level or {}
	local pet_data = DiamondPetData.Instance:GetDiamondPetData()
	local next_cfg = cfg[pet_data.pet_lv + 1]
	if next_cfg then
		local condition = next_cfg.condition or {lv = 0,viplv = 0}
		local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local zslv = ZsVipData.Instance:GetZsVipLv() or 0
		local cfg_role_lv = condition.lv or 0
		local cfg_zslv = condition.zslv or 0
		local can_activate = role_lv >= cfg_role_lv and zslv >= cfg_zslv
		index = can_activate and 1 or 0
	end

	return index
end

function DiamondPetData.OnRoleLvChange()
	RemindManager.Instance:DoRemindDelayTime(RemindName.DiamondPetCanActivate)
end

function DiamondPetData.OnZSVipLevelChange()
	RemindManager.Instance:DoRemindDelayTime(RemindName.DiamondPetCanActivate)
end

-- 上线检查背包中使用过的宝箱
function DiamondPetData:BagItemChange()
	local item_type = ItemData.ItemType.itItemBox
	local all_box = BagData.Instance:GetBagItemDataListByType(item_type)
	for i,v in pairs(all_box) do
		if v.durability_max > 0 then
			DiamondPetCtrl.SendDeleteBoxReq(v.series)
			break
		end
	end

	BagData.Instance:RemoveEventListener(self.bag_item_change)
end
