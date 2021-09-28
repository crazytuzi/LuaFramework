local _M = {}

local function openPanelByName(data, panel_name)
	if data and data.item_id == COMMON_CONSTS.GuildTanheItemId and PlayerData.Instance.role_vo.guild_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
		return
	end

	local item_id = nil
	if data then
		item_id = data.item_id
	end
	ViewManager.Instance:OpenByCfg(panel_name, data)
end

local function onOKCallBack(data, from_view, handle_type, handle_param_t, num)
	if data == nil then
		return
	end

	local item_num = tonumber(num)
	local maxnum = ItemData.Instance:GetItemNumInBagByIndex(data.index)
	--if from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
		--maxnum = GuildData.Instance:GetGuildStorgeItemNum(self.data.index)
	--end
	if item_num > maxnum then
		item_num = maxnum
	end
	handle_param_t.num = item_num
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if handle_type == TipsHandleDef.HANDLE_USE then
		PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
	elseif handle_type == TipsHandleDef.HANDLE_SALE then
		item_num = ItemData.Instance:GetItemNumInBagByIndex(data.index, data.item_id)
		PackageCtrl.Instance:SendDiscardItem(data.index, num, data.item_id, item_num, 0)
	--elseif from_view == TipsFormDef.FROM_CARD_UP then
		--CardCtrl.Instance:SendCardOperate(CARD_OPERATE_TYPE.UPLEVEL, self.handle_param_t.card_index, self.data.index, num)
	elseif from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE then
		if num == 1 then
			GuildCtrl.Instance:SendStorgetPutItem(data.index, num)
		else
			local ok_callback = function (out_num)
				GuildCtrl.Instance:SendStorgetPutItem(data.index, out_num)
			end
			TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil, num)
		end
	elseif from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
		if num == 1 then
			GuildCtrl.Instance:SendStorgetOutItem(data.index, num, data.item_id)
		else
			local ok_callback = function (out_num)
				GuildCtrl.Instance:SendStorgetOutItem(data.index, out_num, data.item_id)
			end
			TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil, num)
		end
	else
		if not PlayerCtrl.Instance.role_view:IsOpen() then
			PlayerCtrl.Instance.role_view:Open()
		end
		PlayerCtrl.Instance.role_view:HandleItemTipCallBack(data, handle_type, handle_param_t)
	end
end

local function onOpenPopNum(data, from_view, handle_type, handle_param_t)
	if data == nil then
		return
	end

	if nil == _M.pop_num_view then
		_M.pop_num_view = NumKeypad.New()
	end

	local maxnum = ItemData.Instance:GetItemNumInBagByIndex(data.index)
	--if from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
		--maxnum = GuildData.Instance:GetGuildStorgeItemNum(data.index)
	--end
	if maxnum == 1 then  --数量为1时不弹
		onOKCallBack(data, from_view, handle_type, handle_param_t, maxnum)
	else
		if maxnum < 1 then
			maxnum = 1
		end
		_M.pop_num_view:Open()
		_M.pop_num_view:SetText(maxnum)
		_M.pop_num_view:SetMaxValue(maxnum)
		_M.pop_num_view:SetOkCallBack(BindTool.Bind(onOKCallBack, data, from_view, handle_type, handle_param_t))
	end
end

local common_operationstate_func = function(data, item_cfg, big_type, t, from_view)
	if from_view == TipsFormDef.FROM_BAG_EQUIP or from_view == TipsFormDef.FROM_CAMP_EQUIP then
		if MojieData.IsMojie(data.item_id) then
			if data.mojie_level and data.mojie_level > 0 then
				t[#t+1] = TipsHandleDef.HANDLE_SHENGJI
			else
				t[#t+1] = TipsHandleDef.HANDLE_JIHUO
			end
		elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
			t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
		elseif EquipData.IsGouYuEqType(item_cfg.sub_type) then
			t[#t+1] = TipsHandleDef.HANDLE_UPLEVEL
			t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
		elseif not CampData.IsCampEquip(item_cfg.sub_type)
			and item_cfg.sub_type ~= GameEnum.WQUIP_TYPE_SUPER1
			and item_cfg.sub_type ~= GameEnum.WQUIP_TYPE_SUPER2 then
			t[#t+1] = TipsHandleDef.HANDLE_FORGE
			t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
		end
	elseif from_view == TipsFormDef.FROM_SPIRIT_BAG then
		t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
	end
end

local common_doclickhandler_func = function(data, item_cfg, handle_type, from_view, handle_param_t)
	if from_view == TipsFormDef.FROM_SJ_JC_OFF then
		return
	end

	if handle_type == TipsHandleDef.HANDLE_BACK_BAG then 	--取出 从仓库取回到背包
		local index = -1
		local max_bag_grid_num = ItemData.Instance:GetMaxKnapsackValidNum()
		for i = 0, max_bag_grid_num - 1 do
			if nil == ItemData.Instance:GetGridData(i) then
				index = i
				break
			end
		end

		if index < 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
			return
		end
		if from_view == TipsFormDef.FROM_STORGE_ON_SPRITRT_STORGE then--item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and
			SpiritCtrl.Instance:SendTakeOutJingLingReq(data.server_grid_index, 0, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
		elseif from_view == TipsFormDef.FROM_LITTLEPET_WAREHOUSE then
			TreasureCtrl.Instance:SendQuchuItemReq(data.server_grid_index, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, 0)
		elseif from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
			if data.num == 1 then
				GuildCtrl.Instance:SendStorgetOutItem(data.index, data.num, data.item_id)
			else
				local ok_callback = function (out_num)
					GuildCtrl.Instance:SendStorgetOutItem(data.index, out_num, data.item_id)
				end
				TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil, data.num)
			end


		else
			PackageCtrl.Instance:SendRemoveItem(data.index, index)-- + COMMON_CONSTS.MAX_BAG_COUNT
			print("取出  从仓库取回到背包==========", "index =========",index, "data.index =========", data.index)
		end
	elseif handle_type == TipsHandleDef.HANDLE_TAKEOFF then
		if from_view == TipsFormDef.FROM_CARD then
			local cfg = CardData.Instance:GetCardPieceCfg(data.item_id)
			if cfg then
				CardCtrl.SendCardSlotTakeOff(cfg.card_idx, cfg.slot_idx)
			end
		elseif CampData.IsCampEquip(item_cfg.sub_type) then
			CampCtrl.Instance:SendCampEquipOperate(CAMPEQUIP_OPERATE_TYPE.CAMPEQUIP_OPERATE_TYPE_TAKEOFF, handle_param_t.fromIndex)
		elseif from_view == TipsFormDef.FROM_SPIRIT_BAG then
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_TAKEOFF,
				data.index, 0, 0, 0, item_cfg.name)
		elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
			MarryEquipCtrl.SendTakeOffQingyuanEquip(handle_param_t.fromIndex)
		else
			-- if not PlayerCtrl.Instance.view:IsOpen() then
			-- 	PlayerCtrl.Instance.view:Open()
			-- end
			PlayerCtrl.Instance:HandleItemTipCallBack(data, handle_type, handle_param_t, item_cfg)
			-- if not PlayerCtrl.Instance.role_view:IsOpen() then
			-- 	PlayerCtrl.Instance.role_view:Open()
			-- end
			-- PlayerCtrl.Instance.role_view:HandleItemTipCallBack(data, handle_type, handle_param_t)
		end
	end
end

local operationState =
{
	--在背包界面中（没有打开仓库和出售）
	[TipsFormDef.FROM_BAG] = function(data, item_cfg, big_type, t)
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		if data then
			if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and math.floor(item_cfg.sub_type / 100) < 9
				or (item_cfg.sub_type and item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX)
				or EquipData.IsMarryEqType(item_cfg.sub_type) then	--装备类型
				if item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING then
					t[#t+1] = TipsHandleDef.HANDLE_JINGLING
				elseif role_vo.prof == item_cfg.limit_prof or item_cfg.limit_prof == 5 then
					t[#t+1] = TipsHandleDef.HANDLE_EQUIP
				end
				-- 红装
				-- if 0 == data.is_bind and item_cfg.color >= 5 and GuildData.Instance.guild_id > 0 and item_cfg.search_type ~= GameEnum.MARRY_EQUIP_SEARCH then
				-- 	t[#t+1] = TipsHandleDef.HANDLE_GUILD
				-- end
				if ForgeData.Instance:CanComposePinkEquip(data.item_id) then
					t[#t+1] = TipsHandleDef.HANDLE_COMPOSE
				end
				-- 红色一星以下装备不能出售
				if 0 == data.is_bind and not EquipData.IsMarryEqType(item_cfg.sub_type) and item_cfg.color > GameEnum.ITEM_COLOR_ORANGE
				and data.param and data.param.xianpin_type_list and #data.param.xianpin_type_list > 0 then
					t[#t+1] = TipsHandleDef.HANDLE_SALE
				end
				if item_cfg.cansell == 1 or EquipData.IsMarryEqType(item_cfg.sub_type) then
					t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
				end

				-- 转生装备分解
				if item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX then
					t[#t+1] = TipsHandleDef.HANDLE_DECOMPOSE
				end
			elseif big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and math.floor(item_cfg.sub_type / 100) == 9 then
				t[#t+1] = TipsHandleDef.HANDLE_USE
				t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
			elseif item_cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET then
				t[#t+1] = TipsHandleDef.HANDLE_USE
				t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
			elseif EquipData.IsLittlePetToyType(item_cfg.sub_type) then
				t[#t+1] = TipsHandleDef.HANDLE_USE
				t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
			else
				if item_cfg.click_use >= 1 or (item_cfg.click_use == 0 and item_cfg.open_panel ~= "" and item_cfg.open_panel ~= 0) then
					if CardData.Instance:IsCardPiece(data.item_id) then
						t[#t+1] = TipsHandleDef.HANDLE_EQUIP
					else
						t[#t+1] = TipsHandleDef.HANDLE_USE
					end
				end
				-- 剔除合成列表类型10的物品，点物品Tip的时候不让他出现合成按钮(因为类型10的物品合成功能已经没有用到了)
				-- 但是配置又不能删，因为幻装商城用了合成的配置（类型10）
				if ComposeData.Instance:GetProductCfg(data.item_id, {[10] = true}) then
					t[#t+1] = TipsHandleDef.HANDLE_COMPOSE
				end
				if 0 == data.is_bind then
					t[#t+1] = TipsHandleDef.HANDLE_SALE
				end
				if item_cfg.cansell == 1 then
					if CardData.Instance:IsCardPiece(data.item_id) then
						t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
					else
						t[#t+1] = TipsHandleDef.HANDLE_RECOVER
					end
				end
			end
		end
	end,
	--打开仓库界面时，来自背包
	[TipsFormDef.FROM_BAG_ON_BAG_STORGE] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_STORGE
		--if big_type ~= GameEnum.ITEM_BIGTYPE_EQUIPMENT and item_cfg.sellprice > 0 then
			-- t[#t+1] = TipsHandleDef.HANDLE_SALE
		--end
	end,
	--打开仓库界面时，来自仓库
	[TipsFormDef.FROM_STORGE_ON_BAG_STORGE] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_BACK_BAG
	end,
	--打开售卖界面时，来自背包
	[TipsFormDef.FROM_BAG_ON_BAG_SALE] = function(data, item_cfg, big_type, t)
		if item_cfg.recycltype ~= 0 and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
			t[#t+1] = TipsHandleDef.HANDLE_RECOVER
		end
	end,
	--打开售卖界面时，来自背包
	[TipsFormDef.FROM_BAG_ON_BAG_SALE_JL] = function(data, item_cfg, big_type, t)
		if item_cfg.recycltype ~= 0 and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
			t[#t+1] = TipsHandleDef.HANDLE_RECOVER
		end
	end,
	--打开装备界面时，来自装备
	[TipsFormDef.FROM_BAG_EQUIP] = common_operationstate_func,
	[TipsFormDef.FROM_SJ_JC_OFF] = common_operationstate_func,
	[TipsFormDef.FROM_CAMP_EQUIP] = common_operationstate_func,
	--打开宝箱界面时，来自宝箱
	[TipsFormDef.FROM_BAOXIANG] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.BAOXIANG_QUCHU
	end,
	[TipsFormDef.FROM_MARKET_JISHOU] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.SHICHANG_CHEHUI
	end,
	[TipsFormDef.FROME_MARKET_GOUMAI] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.SHICHANG_GOUMAI
	end,
	--来自生肖背包
	[TipsFormDef.FROM_SHENGXIAO_BAG] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_USE
		t[#t+1] = TipsHandleDef.HANDLE_COMPOSE
	end,
	--来自仙盟背包
	[TipsFormDef.FROM_BAG_ON_GUILD_STORGE] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.HANDLE_TAKEON
	end,
	--来自卡牌升级
	[TipsFormDef.FROM_CARD_UP] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_RECOVER
	end,
	--来自仙盟仓库
	[TipsFormDef.FROM_STORGE_ON_GUILD_STORGE] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.HANDLE_BACK_BAG
	end,
	[TipsFormDef.FROM_SHENZHOU_EQUIP] = function(data, item_cfg, big_type, t)
	end,
	[TipsFormDef.FROM_MAGICCARD_JIHUO] = function(data, item_cfg, big_type, t)
	end,
	--来自寻宝取出
	[TipsFormDef.FROM_XUNBAO_QUCHU] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.HANDLE_TAKEOFF
	end,
	--来自卡牌取出
	[TipsFormDef.FROM_CARD] = function(data, item_cfg, big_type, t)
		t[#t + 1] = TipsHandleDef.HANDLE_TAKEOFF
	end,
	-- 精灵背包
	[TipsFormDef.FROM_SPIRIT_BAG] = function(data, item_cfg, big_type, t)
		if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
			t[#t + 1] = TipsHandleDef.HANDLE_JINGLING
		else
			t[#t + 1] = TipsHandleDef.HANDLE_USE
		end
		if 0 == data.is_bind then
			t[#t+1] = TipsHandleDef.HANDLE_SALE
		end
		if 1 == item_cfg.cansell then
			t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
		end
	end,
	-- 来自精灵仓库
	[TipsFormDef.FROM_STORGE_ON_SPRITRT_STORGE] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_BACK_BAG
		if 1 == item_cfg.cansell then
			t[#t+1] = TipsHandleDef.HANDLE_RECOVER_SPIRIT
		end
	end,
	-- 来自快速使用
	[TipsFormDef.FROM_QUICK_USE] = function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_USE end,
	-- 来自转生装备
	[TipsFormDef.FROM_ZHUANSHENG_VIEW] =  function(data, item_cfg, big_type, t)
		t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
	end,
	--来自天赋 装备
	[TipsFormDef.FROM_TALENT_EQUIP] = function(data, item_cfg, big_type, t)
		if FamousTalentData.Instance:IsBagTalentBookItems(data.item_id) then
			t[#t+1] = TipsHandleDef.HANDLE_TALENT_EQUIP
		end
	end,
	-- 来自小宠物-家园
	[TipsFormDef.FROM_LITTLEPET_HOME] = function(data, item_cfg, big_type, t)
		if item_cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET then
			t[#t+1] = TipsHandleDef.HANDLE_DEMOUNT
		end
	end,
	-- 来自小宠物-仓库
	[TipsFormDef.FROM_LITTLEPET_WAREHOUSE] = function(data, item_cfg, big_type, t)
		if item_cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET or item_cfg.search_type == GameEnum.USE_TYPE_LITTLE_PET_FEED then
			t[#t+1] = TipsHandleDef.HANDLE_BACK_BAG
		end
	end,
}

local doClickHandler =
{
	--装备
	[TipsHandleDef.HANDLE_EQUIP] = function (data, item_cfg, handle_type, from_view)
		-- print_error("@@@@@@@@@@@@@@@@@@@@@@@@@", data, item_cfg)
		if CardData.Instance:IsCardPiece(data.item_id) then
			local cfg = CardData.Instance:GetCardPieceCfg(data.item_id)
			if cfg then
				CardCtrl.SendCardSlotPutOn(cfg.card_idx, cfg.slot_idx, data.index)
			end
			return
		end
		if data.item_id == 12100 then
			PackageCtrl.Instance:SendUseItem(data.index, 1, data.sub_type, item_cfg.need_gold)
			return
		end

		if item_cfg.sub_type < 200 and item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_JINGLING then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			if equip_index ~= -1 then
				local yes_func = function ()
					PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index, item_cfg.need_gold)
				end
				local equip_suit_type = ForgeData.Instance:GetCurEquipSuitType(equip_index)
				if equip_suit_type ~= 0 then
					local equip_list = EquipData.Instance:GetDataList()
					local equip_suit_id = ForgeData.Instance:GetSuitIdByItemId(equip_list[equip_index].item_id)
					local item_suit_id = ForgeData.Instance:GetSuitIdByItemId(item_cfg.id)
					if equip_suit_id ~= 0 and item_suit_id ~= 0 and equip_suit_id == item_suit_id then
						PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index, item_cfg.need_gold)
					else
						TipsCtrl.Instance:ShowCommonAutoView("", Language.Forge.ReturnSuitRock, yes_func)
					end
				else
					PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index, item_cfg.need_gold)
				end
			end
		elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
			PackageCtrl.Instance:SendUseItem(data.index, 1, MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type), item_cfg.need_gold)
		elseif (item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX) then
			PackageCtrl.Instance:SendUseItem(data.index, 1, data.sub_type, item_cfg.need_gold)
		end
	end,
	--精灵
	[TipsHandleDef.HANDLE_JINGLING] = function(data, item_cfg, handle_type)
		if from_view == TipsFormDef.FROM_SPIRIT_BAG then
				PackageCtrl.Instance:SendUseItem(data.index, 1, SpiritData.Instance:GetSpiritItemIndex(), item_cfg.need_gold)
		else
			ViewManager.Instance:Close(ViewName.Player)
			ViewManager.Instance:Open(ViewName.SpiritView, TabIndex.spirit_spirit)
			PackageCtrl.Instance:SendUseItem(data.index, 1, SpiritData.Instance:GetSpiritItemIndex(), item_cfg.need_gold)
		end
	end,
	--合成
	[TipsHandleDef.HANDLE_COMPOSE] = function(data, item_cfg, handle_type)
		if ForgeData.Instance:CanComposePinkEquip(data.item_id) then
			ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_compose, "compose_jump", data)
		else
			local cfg = ComposeData.Instance:GetProductCfg(data.item_id)
			if cfg then
				local index = TabIndex.compose_stone
				if 2 == cfg.type then
					index = TabIndex.compose_jinjie
				elseif 3 == cfg.type then
					index = TabIndex.compose_other
				end
				ComposeData.Instance:SetToProductId(data.item_id)
				ViewManager.Instance:Open(ViewName.Compose, index, "all", data)
			end
		end
	end,
	--兑换
	[TipsHandleDef.HANDLE_EXCHANGE] = function(data, item_cfg, handle_type)
	end,
	--存放
	[TipsHandleDef.HANDLE_STORGE] = function(data, item_cfg, handle_type)
		local index = -1
		local storage_index_max = ItemData.Instance:GetMaxStorageValidNum() + COMMON_CONSTS.MAX_BAG_COUNT - 1
		for i = COMMON_CONSTS.MAX_BAG_COUNT , storage_index_max do
			if nil == ItemData.Instance:GetGridData(i) then
				index = i
				break
			end
		end

		if index < 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Role.StorgeFull)
			return
		end

		PackageCtrl.Instance:SendRemoveItem(data.index, index)
	end,
	[TipsHandleDef.HANDLE_SALE] = function(data, item_cfg, handle_type)
		ViewManager.Instance:Open(ViewName.QuickSell, nil, "all", data)
	end,
	--取出 从仓库取回到背包
	[TipsHandleDef.HANDLE_BACK_BAG] = common_doclickhandler_func,
	--取下
	[TipsHandleDef.HANDLE_TAKEOFF] = common_doclickhandler_func,
	--使用
	[TipsHandleDef.HANDLE_USE] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		local prof = PlayerData.Instance:GetRoleBaseProf() or 0
		if item_cfg.limit_prof and item_cfg.limit_prof ~= 5 and item_cfg.limit_prof ~= prof then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.ProfDif)
			return
		end

		--活动物品处理
		if item_cfg.activity_type and item_cfg.activity_type > 0  or item_cfg.activity_type == -1 then
			if ActivityData.Instance:GetActivityIsOpen(item_cfg.activity_type) then
				if item_cfg.open_panel ~= "" then
					ViewManager.Instance:CloseAll()
					openPanelByName(data, item_cfg.open_panel)
				end
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.CompetitionActivity.HasNotOpen)
			end
			return
		end

		if PlayerData.Instance.role_vo.level >= item_cfg.limit_level then
			-- 弹劾令牌
			if item_cfg.id == 26911 then
				local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
				if guild_id < 1 then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
					return
				end
				local post = GuildData.Instance:GetGuildPost()
				if post == GuildDataConst.GUILD_POST.TUANGZHANG then
					SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuildTanHeZiJi)
					return
				end
				local describe = Language.Guild.ConfirmTanHeMengZhuTip
				local yes_func = function() GuildCtrl.Instance:SendGuildCheckCanDelateReq() end
				TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
				return
			-- 建会令牌
			elseif item_cfg.id == 26910 then
				local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
				if guild_id < 1 then
					ViewManager.Instance:Open(ViewName.Guild, nil, "CreateGuild", {true})
					return
				end
				ViewManager.Instance:Open(ViewName.Guild)

			-- 公会改名卡
			elseif item_cfg.id == 26922 then
				local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
				if guild_id < 1 then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
					return
				end
				local post = GuildData.Instance:GetGuildPost()
				if post ~= GuildDataConst.GUILD_POST.TUANGZHANG then
					SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
					return
				end
				local describe = Language.Role.RenameGuildTxt
				local yes_func = function(new_name) GuildCtrl.Instance:SendResetNameReq(guild_id, new_name) end
				TipsCtrl.Instance:ShowRename(yes_func, nil, 26922, nil, describe)
				return
			-- 角色改名卡
			elseif item_cfg.id == PlayerDataReNameItemId.ItemId then
				local callback = function (new_name)
					PlayerCtrl.Instance:SendRoleResetName(1, new_name)
				end
				TipsCtrl.Instance:ShowRename(callback, true, PlayerDataReNameItemId.ItemId)
				return
			-- 气泡框
			elseif item_cfg.id >= 27703 and item_cfg.id <= 27707 then
				ViewManager.Instance:Open(ViewName.CoolChat, TabIndex.bubble, "bubble", {index = item_cfg.id - 27703 + 1})
				return
			--婚戒材料
			elseif item_cfg.id == 27406 then
				local lover_uid = GameVoManager.Instance:GetMainRoleVo().lover_uid
				if lover_uid <= 0 then
					SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotMarryToRingDes)
					return
				end
			elseif ForgeData.Instance:CheckIsSuitRock(data.item_id) then
			--使用套装石（跳转到锻造套装界面）
				ViewManager.Instance:Open(ViewName.Forge, TabIndex.forge_suit)
				return
			elseif data.item_id == 27689 then
			--使用套装石碎片
				print_log("使用套装石碎片")
				ViewManager.Instance:Open(ViewName.Compose)
			elseif data.item_id == 27800 or data.item_id == 27801 or data.item_id == 27802 or data.item_id == 27803 then
				-- 开服集字活动
				if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION) then
					TipsCtrl.Instance:ShowSystemMsg(Language.OpenServer.RollActivityEnd)
					return
				end

				if from_view == TipsFormDef.FROM_BAG then
					if ViewManager.Instance:IsOpen(ViewName.Player) then
						ViewManager.Instance:Close(ViewName.Player)
					end
				end
				ViewManager.Instance:Open(ViewName.KaifuActivityView, TabIndex.kaifu_jizi)
			elseif item_cfg.gift_type and item_cfg.gift_type == 3 then
				MojieData.Instance:SetMojieGiftBagIndex(data.index)
				MojieData.Instance:SetMojieGiftId(data.item_id)
				ViewManager.Instance:Open(ViewName.MojieGift)
				return
				--直升丹(太恶心了)
			elseif (data.item_id == 23237 and ShengongData.Instance:GetShengongInfo().grade < 6)
				or (data.item_id == 23238 and ShenyiData.Instance:GetShenyiInfo().grade < 6)
				or (data.item_id == 23234 and MountData.Instance:GetMountInfo().grade < 6)
				or (data.item_id == 23235 and WingData.Instance:GetWingInfo().grade < 6)
				or (data.item_id == 23236 and HaloData.Instance:GetHaloInfo().grade < 6)
				or (data.item_id == 23256 and MountData.Instance:GetMountInfo().grade < 6)
				or (data.item_id == 23257 and WingData.Instance:GetWingInfo().grade < 6) then
				local max_use_lv = ItemData.Instance:GetItemConfig(data.item_id).param2 - 1
				max_use_lv = CommonDataManager.GetDaXie(max_use_lv)
				local describe = string.format(Language.Competition.BiPin_text, max_use_lv)
				local call_back = function ()
					PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
				end
				TipsCtrl.Instance:ShowCommonAutoView("", describe, call_back, nil, nil)
				return
				-- 小宠物
			elseif item_cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET then
				ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_home)
				ViewManager.Instance:Close(ViewName.Player)
				return
			elseif EquipData.IsLittlePetToyType(item_cfg.sub_type) then
				ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_toy)
				ViewManager.Instance:Close(ViewName.Player)
				return
			end
			if item_cfg.click_use == 1 then
				--背包,仓库,扩展格子，特殊处理
				if item_cfg.id == 26914 or item_cfg.id == 26915 then
					local storage_type = (item_cfg.id == 26914) and GameEnum.STORAGER_TYPE_BAG or GameEnum.STORAGER_TYPE_STORAGER
					local type_name = (storage_type == GameEnum.STORAGER_TYPE_BAG) and Language.Role.BeiBao or Language.Role.CangKu
					local item_num = ItemData.Instance:GetItemNumInBagById(item_cfg.id) or 0
					local can_open_num, need_number, old_need_num = PackageData.Instance:GetCanOpenHowManySlot(storage_type, item_num)
					--if item_cfg.id == 26915 then
						--can_open_num, need_number, old_need_num = ItemData.Instance:GetWareHouseCellOpenNeedCount(storage_type, item_num)
					--end
					if can_open_num < 0 then
						SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Role.NoMoreSlot, type_name))
						return
					elseif can_open_num < 1 then
						SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Role.NeedOpenSlotItem, type_name, need_number, item_cfg.name))
						return
					end
					local label_str = string.format(Language.Role.IfOpenSlotWithItem, old_need_num, item_cfg.name, can_open_num, type_name)
					if item_cfg.id == 26914 then
						label_str = Language.Common.KuoZhandai
					end
					local ok_func = function()
						PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(storage_type, can_open_num, 0)
					end
					TipsCtrl.Instance:ShowCommonAutoView(nil, label_str, ok_func)
					return
				end

				if data.is_from_shengxiao then
					local bag_index = ItemData.Instance:GetItemIndex(data.item_id)
					PackageCtrl.Instance:SendUseItem(bag_index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
					return
				end
				PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
				if item_cfg.open_panel ~= "" then
					openPanelByName(data, item_cfg.open_panel)
				end
			elseif item_cfg.click_use == 2 then					--批量使用
				-- 我不管 反正这好恶心的，我就直接这么写了。以后新项目果断重写这东西。
				if item_cfg.need_gold and item_cfg.need_gold > 0 then
					local function tips_callback()
						if ItemData.Instance:GetItemNumInBagByIndex(data.index) == 1 then
							PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
						else
							local ok_callback = function (num)
								PackageCtrl.Instance:SendUseItem(data.index, num, data.sub_type, item_cfg.need_gold)
							end
							TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil,
								ItemData.Instance:GetItemNumInBagByIndex(data.index))
						end
						if item_cfg.open_panel ~= "" then
							openPanelByName(data, item_cfg.open_panel)
						end
					end
					TipsCtrl.Instance:ShowCommonAutoView("", string.format(Language.Common.ConsumeGold, item_cfg.need_gold), tips_callback)
					return
				end

				local have_num = ItemData.Instance:GetItemNumInBagByIndex(data.index)
				if item_cfg.use_type == 73 then
					--符文宝箱做特殊处理（最多一次使用5个）
					local used_num = have_num > 6 and 6 or have_num
					RuneData.Instance:SetBaoXiangId(data.item_id)
					PackageCtrl.Instance:SendUseItem(data.index, used_num, data.sub_type, item_cfg.need_gold)
					return
				end
				if have_num == 1 then
					PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type, item_cfg.need_gold)
				else
					local ok_callback = function (num)
						PackageCtrl.Instance:SendUseItem(data.index, num, data.sub_type, item_cfg.need_gold)
					end
					TipsCtrl.Instance:OpenCommonInputView(have_num, ok_callback, nil,
						have_num)
				end
				if item_cfg.open_panel ~= "" then
					openPanelByName(data, item_cfg.open_panel)
				end
			elseif item_cfg.click_use == 0 and item_cfg.open_panel ~= "" and nil ~= item_cfg.open_panel then
				-- 进阶装备特殊处理
				local t = Split(item_cfg.open_panel, "#")
				local view_name = t[1]
				local tab_index = t[2]
				if view_name == ViewName.AdvanceEquipView then
					local is_active, activite_grade = AdvanceData.Instance:IsOpenEquip(TabIndex[tab_index])
					if not is_active then
						local name = Language.Advance.PercentAttrNameList[TabIndex[tab_index]] or ""
						TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
						return
					end

					ViewManager.Instance:CloseAll()
					if TabIndex[tab_index] == TabIndex.goddess_shengong or TabIndex[tab_index] == TabIndex.goddess_shenyi then
						ViewManager.Instance:Open(ViewName.Goddess, TabIndex[tab_index])
					else
						ViewManager.Instance:Open(ViewName.Advance, TabIndex[tab_index])
					end
				end
				openPanelByName(data, item_cfg.open_panel)
			elseif item_cfg.click_use == 0 and item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING then
				ViewManager.Instance:Close(ViewName.Player)
				ViewManager.Instance:Open(ViewName.SpiritView)
			elseif item_cfg.click_use == 0 and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX and item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN then
				PackageCtrl.Instance:SendUseItem(data.index, handle_param_t.num, data.sub_type)
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.UseLevelLimit)
		end
	end,
	--从寻宝仓库取出
	[TipsHandleDef.BAOXIANG_QUCHU] = function(data, item_cfg, handle_type)
		local pack_empty_num = ItemData.Instance:GetMaxKnapsackValidNum() - #ItemData.Instance:GetBagItemDataList()
		if pack_empty_num > 0 then
			local grid_index = TreasureData.Instance:GetGridIndexById(data.item_id)
			TreasureCtrl.Instance:SendQuchuItemReq(grid_index , CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, 0)
		end
	end,
--撤回寄售的物品
	[TipsHandleDef.SHICHANG_CHEHUI] = function(data, item_cfg, handle_type)
	    if nil == _M.alert_window then
			_M.alert_window = Alert.New(nil, nil, nil, nil, false)
		end
		_M.alert_window:SetContent(Language.Market.AlerTips)
		_M.alert_window:SetOkFunc(BindTool.Bind2(MarketCtrl.Instance.SendRemovePublicSaleItem, MarketCtrl.Instance, data.sale_index))
		_M.alert_window:Open()
	end,
	--从市场中购买
	[TipsHandleDef.SHICHANG_GOUMAI] = function(data, item_cfg, handle_type)
		local cost_gold = data.gold_price
		print("*****************gold_price",cost_gold)
		print("*****************price_type",data.price_type)
		MarketCtrl.Instance:SendBuyPublicSaleItem(data.seller_uid, data.sale_index, data.item_id, data.num, data.gold_price, data.sale_value, data.sale_item_type, data.price_type)
		-- if MarketData.PriceTypeGold == data.price_type and cost_gold > PlayerData.Instance:GetRoleVo()["gold"] then
		-- -- 	UiInstanceMgr.Instance:ShowChongZhiView()
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Market.GoldNotEnough)
		-- else
		-- 	MarketCtrl.Instance:SendBuyPublicSaleItem(data.seller_uid, data.sale_index, data.item_id, data.num, data.gold_price, data.sale_value, data.sale_item_type, data.price_type)
		-- end
	end,
	--融合
	[TipsHandleDef.RONGHE] = function(data, item_cfg, handle_type)
		local equip_select_index = MarriageData.Instance:GetSelectEquipIndex()
		if equip_select_index == 0 then
			return
		end
		MarriageCtrl.Instance:SendQingyuanUpLevel(data.item_id, equip_select_index - 1)
	end,
	--锻造s
	[TipsHandleDef.HANDLE_FORGE] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		ForgeCtrl.Instance:OpenViewToIndex(data.index)
		return true
	end,
	--升级
	[TipsHandleDef.HANDLE_UPLEVEL] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if item_cfg.sub_type == GameEnum.EQUIP_TYPE_GOUYU_LEFT then
			ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_shengwang)
		elseif item_cfg.sub_type == GameEnum.EQUIP_TYPE_GOUYU_RIGHT then
			ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_rongyao)
		end
		return true
	end,
	--回收 \ 丢弃
	[TipsHandleDef.HANDLE_RECOVER] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if from_view == TipsFormDef.FROM_CARD_UP then
			onOpenPopNum(data, from_view, handle_type, handle_param_t)
		elseif(from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE and item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_JINGLING)
			or (from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE_JL and item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING) then
			onOpenPopNum(data, from_view, handle_type, handle_param_t)
		elseif from_view == TipsFormDef.FROM_STORGE_ON_SPRITRT_STORGE then -- 从精灵仓库丢弃
		else
			local str = item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and Language.Tip.IsSureRecoverJl
				or (item_cfg.sub_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and Language.Tip.IsSureRecover or Language.Tip.IsSureRecoverProp)
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		end
	end,
	--放入
	[TipsHandleDef.HANDLE_TAKEON] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if from_view == TipsFormDef.FROM_SJ_JC_ON then
			ForgeCtrl.Instance:TakeOnSjJcCell(data, handle_param_t)
		elseif from_view == TipsFormDef.FROM_BAG_ON_GUILD_STORGE then
			if data.num == 1 then
				GuildCtrl.Instance:SendStorgetPutItem(data.index, data.num)
			else
				local ok_callback = function (out_num)
					GuildCtrl.Instance:SendStorgetPutItem(data.index, out_num)
				end
				TipsCtrl.Instance:OpenCommonInputView(ItemData.Instance:GetItemNumInBagByIndex(data.index), ok_callback, nil, data.num)
			end
		end
	end,
	--仙盟
	[TipsHandleDef.HANDLE_GUILD] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if from_view == TipsFormDef.FROM_BAG then
			ViewManager.Instance:Open(ViewName.Guild,TabIndex.guild_storge)
		end
	end,
	--情缘
	[TipsHandleDef.HANDLE_QINGYUSN] = function(data, item_cfg, handle_type)
	end,
	-- 激活
	[TipsHandleDef.HANDLE_JIHUO] = function(data, item_cfg, handle_type)
		if data and MojieData.IsMojie(data.item_id) then
			ViewManager.Instance:Open(ViewName.Mojie, data.index)
		end
	end,
	-- 进阶装备升级
	[TipsHandleDef.HANDLE_SHENGJI] = function(data, item_cfg, handle_type)
		if data and MojieData.IsMojie(data.item_id) then
			ViewManager.Instance:Open(ViewName.Mojie, data.index)
		else
			local index = nil
			ViewManager.Instance:Close(ViewName.Player, TabIndex.role_bag)
		end
	end,
	--回收 \ 丢弃
	[TipsHandleDef.HANDLE_RECOVER_SPIRIT] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if from_view == TipsFormDef.FROM_CARD_UP then
			onOpenPopNum(data, from_view, handle_type, handle_param_t)
		elseif(from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE and item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_JINGLING)
			or (from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE_JL and item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING) then
			onOpenPopNum(data, from_view, handle_type, handle_param_t)
		elseif (from_view == TipsFormDef.FROM_BAG and item_cfg.recycltype == 6) or (item_cfg.recycltype == 5 and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX and item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN) then
			local str = item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and SpiritData.Instance:GetRecycleText(data.param.param1 or 0) or Language.Tip.IsSureRecover
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		elseif EquipData.IsMarryEqType(item_cfg.sub_type) then
			local str = Language.Tip.IsSureRecover
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		elseif CardData.Instance:IsCardPiece(data.item_id) then
			local str = Language.Tip.IsSureRecoverCard
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		elseif from_view == TipsFormDef.FROM_STORGE_ON_SPRITRT_STORGE then
			local str = item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and SpiritData.Instance:GetRecycleText(data.param.param1 or 0) or Language.Tip.IsSureRecover
			local ok_func = function()
				SpiritCtrl.Instance:SendRecoverySpirit(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING, 0, 0, data.server_grid_index)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		elseif from_view == TipsFormDef.FROM_BAG and item_cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET  or EquipData.IsLittlePetToyType(item_cfg.sub_type) then
			ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_home)
			ViewManager.Instance:Open(ViewName.LittlePetHomeRecycleView)
		else
			local str = item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING and SpiritData.Instance:GetRecycleText(data.param.param1 or 0)
			or (item_cfg.sub_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and SpiritData.Instance:GetRecycleText(data.param.param1 or 0) or Language.Tip.IsSureRecoverProp)
			local ok_func = function()
				PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
			end
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, ok_func)
		end
	end,
	-- 放生（宠物）
	[TipsHandleDef.HANDLE_FREE_PET] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		local ok_func = function()
			PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Common.PetReliveTip, ok_func)
	end,
	-- 分解转生装备
	[TipsHandleDef.HANDLE_DECOMPOSE] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		local ok_func = function()
			PackageCtrl.Instance:SendDiscardItem(data.index, data.num, data.item_id, data.num, 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Common.ZhuanShengDecomposeTip, ok_func)
	end,
	--天赋 装备
	[TipsHandleDef.HANDLE_TALENT_EQUIP] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		FamousGeneralCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_PUTON, handle_param_t.talent_type,  handle_param_t.grid_index, data.index)
		ViewManager.Instance:Close(ViewName.FamousTalentBagView)
	end,
	--小宠物 卸下
	[TipsHandleDef.HANDLE_DEMOUNT] = function(data, item_cfg, handle_type, from_view, handle_param_t)
		if item_cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET then
			LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_TAKEOFF, handle_param_t)
			local pet_id = data and data.id
			LittlePetData.Instance:SetTakeOffPetId(pet_id)
			LittlePetCtrl.Instance:OnMainRoleTakeOffPet()
		end
	end
}

function _M.GetOperationState(from_view, data, item_cfg, big_type)
	local handler_types = {}
	local func = operationState[from_view]
	if func == nil or item_cfg == nil or data == nil then
		return handler_types
	end

	func(data, item_cfg, big_type, handler_types, from_view)
	return handler_types
end

function _M.DoClickHandler(data, item_cfg, handle_type, from_view, handle_param_t)
	local func = doClickHandler[handle_type]
	if func == nil or data == nil or item_cfg == nil then
		return false
	end
	func(data, item_cfg, handle_type, from_view, handle_param_t)
	return true
end

function _M.IsShowSellViewState(from_view)
	local salestate = true
	if from_view == TipsFormDef.FROM_BAG then							--在背包界面中（没有打开仓库和出售）
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAG_ON_BAG_STORGE then			--打开仓库界面时，来自背包
		salestate = true
	elseif from_view == TipsFormDef.FROM_STORGE_ON_BAG_STORGE then		--打开仓库界面时，来自仓库
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE then			--打开售卖界面时，来自背包
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAG_ON_BAG_SALE_JL then		--打开精灵售卖界面时，来自背包
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAG_EQUIP then					--打开装备界面时，来自装备
		salestate = true
	elseif from_view == TipsFormDef.FROM_CAMP_EQUIP then				--打开阵营装备界面时，来自阵营装备
		salestate = true
	elseif from_view == TipsFormDef.FROM_BAOXIANG then					--打开宝箱界面时，来自宝箱
		salestate = false
	elseif from_view == TipsFormDef.FROM_MARKET_JISHOU then
		salestate = false
	elseif from_view == TipsFormDef.FROME_MARKET_GOUMAI then
		salestate = false
	else
		salestate = false
	end
	return salestate
end

function _M.DeleteMe(self)
	if _M.pop_num_view ~= nil then
		_M.pop_num_view:DeleteMe()
		_M.pop_num_view = nil
	end
	if _M.alert ~= nil then
		_M.alert:DeleteMe()
		_M.alert = nil
	end
end

return _M