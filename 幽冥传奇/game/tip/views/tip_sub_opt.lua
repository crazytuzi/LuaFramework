TipSubOpt = TipSubOpt or BaseClass(TipSub)

TipSubOpt.SIZE = cc.size(0, 0)

function TipSubOpt:__init()
	self.y_order = 0
	self.label_t = Language.Tip.ButtonLabel
	self.buttons = {}

	self.is_ignore_height = true
end

function TipSubOpt:__delete()
end

function TipSubOpt:AlignSelf()
	self.view:setPosition(BaseTip.WIDTH, 50)
end

function TipSubOpt:SetData(data, fromView, param_t)
	self.data = data
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}

	self.handle_type = 0
	self.item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.item_color3b = Str2C3b(string.sub(string.format("%06x", self.item_cfg.color), 1, 6))
	self.item_prof_limit = ItemData.Instance:GetItemLimit(self.data.item_id, ItemData.UseCondition.ucJob)
	self.limit_level = ItemData.Instance:GetItemLimit(self.data.item_id, ItemData.UseCondition.ucLevel)
	self.circle_level = ItemData.Instance:GetItemLimit(self.data.item_id, ItemData.UseCondition.ucMinCircle)

	self:Flush()
end

function TipSubOpt:Release()
	self.buttons = {}
end

function TipSubOpt:CreateChild()
	TipSubOpt.super.CreateChild(self)

	self.buttons = {}
	for i = 1, 5 do
		node = XUI.CreateButton(109 / 2, 55 / 2 + (i - 1) * (55 + 40), 0, 0, false, ResPath.GetCommon("btn_144_select"), "", "", XUI.IS_PLIST)
		node:setTitleFontName(COMMON_CONSTS.FONT)
		node:setTitleFontSize(22)
		node:setTitleColor(COLOR3B.OLIVE)
		XUI.AddClickEventListener(node, BindTool.Bind(self.OperationClickHandler, self, node))
		self.view:addChild(node)
		table.insert(self.buttons, node)
	end
end

function TipSubOpt:OnFlush()
	self:ShowOperationState()
end


--根据不同的状态出现不同的按钮
function TipSubOpt:ShowOperationState()
	local handle_types = self:GetOperationLabelByType(self.fromView)
	if handle_types then

		for k, v in ipairs(self.buttons) do
			local label = self.label_t[handle_types[k]]	--获得文字内容
			if label ~= nil then
				v:setVisible(true)
				v:setTag(handle_types[k])
				v:setTitleText(label)
			else
				v:setVisible(false)
			end
		end
	end
end

function TipSubOpt:GetOperationLabelByType(fromView)
	local t = {}
	local item_cfg = self.item_cfg
	if IS_ON_CROSSSERVER then	-- 跨服中不能对装备进行操作
		return t
	end
	if fromView == EquipTip.FROM_BAG then
		--在背包界面中
		if not item_cfg.flags.denyDestroy then
			if item_cfg.type ==  ItemData.ItemType.itFashion or item_cfg.type ==  ItemData.ItemType.itWuHuan then
				local is_over_time = FashionData.Instance:GetFashionIsOverTime(self.data)
				if is_over_time then
					t[#t+1] = EquipTip.HANDLE_DESTROY
				else
					t[#t+1] = EquipTip.HANDLE_DISCARD
				end
			else
				if self.data.is_bind == 0 then
					t[#t+1] = EquipTip.HANDLE_DISCARD
				else
					t[#t+1] = EquipTip.HANDLE_DESTROY
				end
			end
		end
		if ItemData.ItMedicaments[self.data.item_id] then
			t[#t+1] = EquipTip.HANDLE_USE
		end
		if StoneData.IsStoneEquip(item_cfg.type) then
			t[#t+1] = EquipTip.HANDLE_INLAY
		end
		if ItemData.ItemType.itItemDiamond == item_cfg.type then
			t[#t+1] = EquipTip.HANDLE_INLAY
		end

		if ItemData.IsBaseEquipType(item_cfg.type) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

		-- 影翼
		if ItemData.GetIsWingEquip(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

		-- 战宠装备
		if ItemData.GetIsHeroEquip(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

		if ItemData.GetIsCard(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_DECOMPOSE
		end

		--战纹
		if ItemData.GetIsZhanwenType(item_cfg.type) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

		if ItemData.GetIsZhanwenType(item_cfg.type) then
			t[#t+1] = EquipTip.HANDLE_DECOMPOSE
		end

		--星魂
		if ItemData.GetIsConstellation(item_cfg.item_id) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

		if ItemData.GetIsConstellation(item_cfg.item_id) then
			t[#t+1] = EquipTip.HANDLE_COLLECT
		end

		-- -- 特戒
		-- if ItemData.IsSpecialRing(item_cfg.type) then
		-- 	t[#t+1] = EquipTip.HANDLE_EQUIP
		-- end		
		
		if ItemData.GetIHandEquip(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

		-- 传世
		if ItemData.GetIsHandedDown(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

		-- 守护神装
		if ItemData.IsGuardEquip(item_cfg.type) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end
		-- 新时装
		if ItemData.GetIsFashion(self.data.item_id) or ItemData.GetIsHuanWu(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

		--新热血神装
		if ItemData.IsZhanShenEquip(self.data.item_id) or ItemData.IsShaShenEquip(self.data.item_id) or ItemData.IsReXueEquip(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

	elseif fromView == EquipTip.FROM_BAG_EQUIP then

		if not EquipData.CannotTakeOffEquip(item_cfg.type) then
			if item_cfg.type ~= ItemData.ItemType.itPrimitiveRingPos then 
				t[#t+1] = EquipTip.HANDLE_TAKEOFF
			end
		end
		if StoneData.IsStoneEquip(item_cfg.type) then
			t[#t+1] = EquipTip.HANDLE_INLAY
		end
		local hand_pos = QianghuaData.Instance:GetBetterStrengthHandPos(item_cfg.type)
		if QianghuaData.IsStrengthEquip(EquipData:GetEquipIndexByType(item_cfg.type, hand_pos)) then
			t[#t+1] = EquipTip.HANDLE_STRENGTHEN
		end
		if EquipmentData.IsXuelianEquip(EquipData:GetEquipIndexByType(item_cfg.type, hand_pos)) then
			t[#t+1] = EquipTip.HANDLE_XUELIAN
		end
	elseif fromView == EquipTip.FROM_BAG_ON_GUILD_STORAGE then
		if not item_cfg.flags.denyDestroy then
			t[#t+1] = EquipTip.HANDLE_DISCARD
		end
		if ItemData.ItMedicaments[self.data.item_id] then
			t[#t+1] = EquipTip.HANDLE_USE
		end
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CS_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CS_CONSUM then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_CS_DECOMPOSE_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CS_DECOMPOSE_VIEW then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_BAG_ON_BAG_STORAGE then
		if not item_cfg.flags.denyDestroy then
			t[#t+1] = EquipTip.HANDLE_DISCARD
		end
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_STORAGE_ON_GUILD_STORAGE then
		if not RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_COMMON) then
			-- 除了行会普通成员外，其它职位均可摧毁行会仓库物品
			t[#t+1] = EquipTip.HANDLE_DESTROY
		end
		t[#t+1] = EquipTip.HANDLE_EXCHANGE
	elseif fromView == EquipTip.FROM_STORAGE_ON_BAG_STORAGE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_HERO_EQUIP then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
	elseif fromView == EquipTip.FROM_BAG_ON_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_CARD_DESCOMPOSE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_BAG_ON_CARD_DESCOMPOSE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CONSIGN_ON_SELL then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CONSIGN_ON_BUY then
		if not ConsignData.Instance:GetItemSellerIsMe(self.data) then
			t[#t+1] = EquipTip.HANDLE_BUY
		end
	elseif fromView == EquipTip.FROM_XUNBAO_BAG then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_CHAT_BAG then
		t[#t+1] = EquipTip.HANDLE_SHOW
	elseif fromView == EquipTip.FROM_EXCHANGE_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView ==EquipTip.FROME_BROWSE_ROLE then
	elseif fromView ==EquipTip.FROM_ROLE_HAND then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
		t[#t+1] = EquipTip.HANDLE_ADD
	-- elseif fromView ==EquipTip.FROM_RUNE then
	-- 	t[#t+1] = EquipTip.HANDLE_TAKEOFF
	elseif fromView ==EquipTip.FROM_FASHION_CLOTHES then 
		if self.handle_param_t.is_compose then
			t[#t+1] = EquipTip.HANDLE_INPUT
		else
			t[#t+1] = EquipTip.HANDLE_TAKEOFF
		end
	elseif fromView == EquipTip.FROM_FULING_TO_MATE or
	       fromView == EquipTip.FROM_FULING_TO_MAIN or 
	       fromView == EquipTip.FROM_FULING_SHIFT_TO_MAIN or
	       fromView == EquipTip.FROM_FULING_SHIFT_TO_MATE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_FULING_TAKE_MAIN or
	       fromView == EquipTip.FROM_FULING_TAKE_MATE or
	       fromView == EquipTip.FROM_FULING_SHIFT_TAKE_MAIN or
	       fromView == EquipTip.FROM_FULING_SHIFT_TAKE_MATE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_HOLY_SYNTHESIS then	
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROME_EQUIP_STONE then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
		t[#t+1] = EquipTip.HANDLE_UPGRADE2
	elseif fromView == EquipTip.FROME_BAG_STONE then
		t[#t+1] = EquipTip.HANDLE_INLAY
		t[#t+1] = EquipTip.HANDLE_ONEKEY_SYNTHETIC
	elseif fromView == EquipTip.FROM_HOROSCOPE then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
	elseif fromView == EquipTip.FROM_COLLECTION then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_COLLECTION_BAG then
		t[#t+1] = EquipTip.HANDLE_COLLECT
	elseif fromView == EquipTip.FROM_WING_EQUIP_SHOW then
		if WingData.Instance:GetWingHhIndex(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_NOT_HUANHUA
			t[#t+1] = EquipTip.HANDLE_TAKEOFF
		else
			t[#t+1] = EquipTip.HANDLE_HUANHUA
			t[#t+1] = EquipTip.HANDLE_TAKEOFF
		end
	elseif fromView == EquipTip.FROM_WING_EQUIP then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
	elseif fromView == EquipTip.FROM_GUN_OR_CAR then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
		t[#t+1] = EquipTip.HANDLE_UPGRADE

	elseif fromView == EquipTip.FROM_SHI_ZHUANG_GUI then
		t[#t+1] = EquipTip.HANDLE_HUISHOU
		if self.data.zhuan_level == 1 then
			t[#t+1] = EquipTip.HANDLE_NOT_HUANHUA
		else
			t[#t+1] = EquipTip.HANDLE_HUANHUA
		end
	elseif fromView == EquipTip.FROM_SPECIAL_RING_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_ROlE_CHUANG_SHI then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
		t[#t+1] = EquipTip.HANDLE_GANGWEN
	elseif fromView == EquipTip.FROM_ROlE_NEWREXUE_EQUIP then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
		t[#t+1] = EquipTip.HANDLE_UPGRADE
	elseif fromView == EquipTip.FROM_WING_BAG then -- 来自神翼背包
		t[#t+1] = EquipTip.HANDLE_INPUT
	end
	
	return t
end

function TipSubOpt:OperationClickHandler(psender)
	if self.data == nil then
		return
	end
	self.handle_type = psender:getTag()
	if self.handle_type == nil then
		return
	end

	TipCtrl.Instance:UseItem(self.handle_type, self.data, self.handle_param_t, self.fromView)
	self:Close()
end

return TipSubOpt
