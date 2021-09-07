OtherCtrl = OtherCtrl or BaseClass(BaseController)

MODULE_OPERATE_TYPE = {
	OP_MOUNT_UPGRADE = 1,						-- 坐骑进阶
	OP_MOUNT_UPBUILD = 2,						-- 骑兵打造
	OP_XIANNV_PROMOTE_LEVEL = 3,				-- 仙女等级
	OP_XIANNV_PROMOTE_YUANSH = 4,				-- 仙女升级元神
	OP_XIANNV_PROMOTE_ZIZHI = 5,				-- 仙女提升资质
	OP_Wing_UPEVOL = 6,							-- 羽翼进化
	OP_EQUIP_STRENGTHEN = 7,					-- 装备强化
	OP_STONE_UPLEVEL = 8 ,						-- 宝石升级成功
	OP_FISH_POOL_EXTEND_CAPACITY_SUCC = 9,		-- 鱼池扩展成功
	OP_WING_UPGRADE_SUCC = 10,					-- 羽翼进阶
	OP_MOUNT_FLYUP = 11,						-- 坐骑飞升
	OP_XIANNV_HALO_UPGRADE = 12,				-- 仙女守护
	OP_WUSHAUNG_EQUIP_DAZAO = 13,				-- 无双装备打造
	OP_XIANNV_JIE_UPGRADE = 14,					-- 仙女升阶
	OP_XIANJIAN_JIE_UPGRADE = 15,				-- 仙剑升阶
	OP_EQUIP_UP_STAR_SUCC = 16,					-- 装备升星成功
	OP_JINGLING_UPGRADE = 17,					-- 精灵升阶
	OP_SHENZHUANG_JINJIE = 18,					-- 神装进阶
	OP_BABY_JIE_UPGRADE  = 19,                  -- 宝宝进阶
	OP_PET_JIE_UPGRADE = 20,					-- 宠物自动进阶
	OP_QINGYUAN_JIE_UPGRADE  = 21 ,             -- 情缘进阶
	OP_HUASHEN_UPLEVEL = 22,					-- 化神进阶
	OP_PET_QINMI_PROMOTE = 23,					-- 宠物亲密度
	OP_MULTI_MOUNT_UPGRADE = 24,				-- 双人坐骑进阶
	OP_WUSHANG_EQUIP_UPSTAR = 25,               -- 跨服装备升星
	OP_JINGLING_HALO_UPSTAR = 26,				-- 精灵光环升级(美人光环)
	OP_FAIRY_TREE_UPGRADE = 27,					-- 仙树升级
	OP_MAGIC_EQUIPMENT_STRENGTHEN = 28,			-- 魔器强化
	OP_HALO_UPGRADE = 29,						-- 进阶光环升级
	OP_SHENGONG_UPGRADE = 30,					-- 进阶神弓升级(足迹)
	OP_SHENYI_UPGRADE = 31,						-- 进阶神翼升级(披风)
	OP_XIANNV_PROMOTE_HUANHUA_LEVEL = 32,		-- 仙女幻化等级
	OP_JINGLING_FAZHEN_UPGRADE = 33,			-- 精灵法阵升阶(圣物进阶)
	OP_SHENGONG_UPSTAR = 34,					-- 神弓升星
	OP_SHENYI_UPSTAR = 35,						-- 神翼升星
	OP_HUASHEN_UPGRADE_SPIRIT = 36,				-- 化神精灵进阶
	OP_FIGHT_MOUNT_UPGRADE = 37,				-- 战斗坐骑进阶
	OP_LIEMING_CHOUHUN = 38,					-- 猎命抽魂结果
	OP_SHENQI_SHENGBING_UPLEVEL = 39,			-- 神器-神兵升级
	OP_SHENQI_BAOJIA_UPLEVEL = 40,				-- 神器-宝甲升级
	OP_BEAUTY_UPGRADE = 41,						-- 美人进阶
	OP_MOUNT_UPSTAR = 42,						-- 坐骑升星
	OP_WING_UPSTAR = 43,						-- 羽翼升星
	OP_HALO_UPSTAR = 44,						-- 光环升星
	OP_FIGHT_MOUNT_UPSTAR = 45,					-- 战骑升星
	OP_SHEN_BING_UPGRADE = 46,					-- 神兵进阶
	OP_SHENZHOU_WEAPON = 47,					-- 魂器
	OP_FAZHEN_UPGRADE = 48,						-- 人物法阵
	OP_TEAM_SKILL_UPGRADE = 49,					-- 组队技能
	OP_BEAUTY_CHANMIAN_UPGRADE = 50,			-- 美人缠绵进阶
	OP_GREATE_SOLDIER_WASH_ATTR = 51,			-- 名将属性洗练
	OP_RA_MAPHUNT_AUTO_FLUSH = 52,				-- 地图寻宝自动刷新
	OP_GREATE_SOLDIER_SLOT_UPLEVEL = 53, 		-- 名将槽位
	OP_REBIRTH_UPLEVEL = 54,					-- 转生自动升级
	OP_BABY_JL_UPGRADE = 55, 					-- 宝宝进阶
	OP_MUSEUM_CARD_UPGRADE = 56,				-- 卡牌升星
	OP_UGS_HEAD_WEAR_UPGRADE = 57,				-- 头饰进阶
	OP_UGS_MASK_UPGRADE = 58,					-- 面饰进阶
	OP_UGS_KIRIN_ARM_UPGRADE = 59,				-- 麒麟臂进阶
	OP_UGS_WAIST_UPGRADE = 60,					-- 腰饰进阶
	OP_UGS_BEAD_UPGRADE = 61,					-- 灵珠进阶
	OP_UGS_FABAO_UPGRADE = 62,					-- 法宝进阶
	OP_ELEMENT_HEART_UPGRADE = 63,				-- 元素之心进阶
	OP_ELEMENT_EQUIP_UPGRADE = 64,				-- 元素之心装备进阶
	OP_ELEMENT_TEXTURE_UPGRADE = 65,			-- 元素之心附纹进阶
 }

local SHOP_MODE = {
	[1] = CHEST_SHOP_MODE.CHEST_GENERAL_MODE_1,
	[10] = CHEST_SHOP_MODE.CHEST_GENERAL_MODE_10,
	[50] = CHEST_SHOP_MODE.CHEST_GENERAL_MODE_50,
}
function OtherCtrl:__init()
	OtherCtrl.Instance = self

	self.get_item_view = QuickBuy.New()
	self:RegisterEvent()
	self:RegisterAllProtocals()
end

function OtherCtrl:__delete()
	self.get_item_view:DeleteMe()
	self.get_item_view = nil
end

function OtherCtrl:GetAutoBuyFlag()
	return self.get_item_view:GetAutoBuyFlag()
end

function OtherCtrl:SetAutoBuyFlag(flag)
	self.get_item_view:SetAutoBuyFlag(flag)
end

function OtherCtrl:RegisterEvent()
	self:BindGlobalEvent(KnapsackEventType.KNAPSACK_LECK_ITEM, BindTool.Bind1(self.OpenGetItemView, self))
end

function OtherCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCOperateResult, "OnOperateResult")
	self:RegisterProtocol(SCDrawResult, "OnSCDrawResult")
end

function OtherCtrl:OnOperateResult(protocol)
	GlobalEventSystem:Fire(OtherEventType.OPERATE_RESULT, protocol.operate, protocol.result, protocol.param1, protocol.param2)
	if MODULE_OPERATE_TYPE.OP_MOUNT_UPGRADE == protocol.operate then
		-- 坐骑进阶
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:MountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_MOUNT_UPSTAR == protocol.operate then
		-- 坐骑升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:MountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_WING_UPGRADE_SUCC == protocol.operate then
		-- 羽翼升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:WingUpgradeResult(protocol.result)
		end
	elseif	MODULE_OPERATE_TYPE.OP_HALO_UPGRADE == protocol.operate then
		-- 光环升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:HaloUpgradeResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_SHENGONG_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:OnShengongUpGradeResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_XIANNV_HALO_UPGRADE == protocol.operate then
		if nil ~= GoddessShouhuCtrl then
			GoddessShouhuCtrl.Instance:OnUppGradeOptResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_SHENYI_UPSTAR == protocol.operate then
		if nil ~= ShenyiCtrl then
			ShenyiCtrl.Instance:OnUppGradeOptResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_JINGLING_FAZHEN_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:OnHalidomUppGradeOptResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_JINGLING_HALO_UPSTAR == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:OnBeautyHaloUppGradeOptResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_HUASHEN_UPGRADE_SPIRIT == protocol.operate then
		if nil ~= SpiritCtrl then
			HuashenCtrl.Instance:OnSpiritUpgradeResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_FAZHEN_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:OnFightMountUpgradeResult(protocol.result)
		end
	-- elseif MODULE_OPERATE_TYPE.OP_LIEMING_CHOUHUN == protocol.operate then
	-- 	if 1 == protocol.result then return end

	-- 	local item_id = 22606
	-- 	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
	-- 	if item_cfg == nil then
	-- 		TipsCtrl.Instance:ShowItemGetWayView(item_id)
	-- 		return
	-- 	end

	-- 	if item_cfg.bind_gold == 0 then
	-- 		TipsCtrl.Instance:ShowShopView(item_id, 2)
	-- 		return
	-- 	end

	-- 	local func = function(_item_id, item_num, is_bind, is_use)
	-- 		MarketCtrl.Instance:SendShopBuy(_item_id, item_num, is_bind, is_use)
	-- 	end

	-- 	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1)
	elseif	MODULE_OPERATE_TYPE.OP_HUASHEN_UPLEVEL == protocol.operate then
		if nil ~= HuashenCtrl then
			HuashenCtrl.Instance:OnUpgradeResult(protocol.result)
		end
	elseif	MODULE_OPERATE_TYPE.OP_SHEN_BING_UPGRADE == protocol.operate then
		if nil ~= ShenBingCtrl then
			ShenBingCtrl.Instance:OnUpgradeResult(protocol.result)
		end
	elseif	MODULE_OPERATE_TYPE.OP_SHENZHOU_WEAPON == protocol.operate then
		if nil ~= HunQiCtrl then
			HunQiCtrl.Instance:HunQiUpGrade(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHENYI_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:OnShenyiUpGradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHENQI_SHENGBING_UPLEVEL == protocol.operate then
		if nil ~= ShenqiCtrl then
			ShenqiCtrl.Instance:OnShenbingUpGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHENQI_BAOJIA_UPLEVEL == protocol.operate then
		if nil ~= ShenqiCtrl then
			ShenqiCtrl.Instance:OnBaojiaUpGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_BEAUTY_UPGRADE == protocol.operate then
		if nil ~= BeautyCtrl then
			BeautyCtrl.Instance:OnBeautyUpGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_BEAUTY_CHANMIAN_UPGRADE == protocol.operate then
		if nil ~= BeautyCtrl then
			BeautyCtrl.Instance:OnBeautyChanMianOptResult(protocol.result, protocol.param1)
		end
	elseif MODULE_OPERATE_TYPE.OP_GREATE_SOLDIER_WASH_ATTR == protocol.operate then
		if nil ~= FamousGeneralCtrl then
			FamousGeneralCtrl.Instance:OnSoldierWashOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_TEAM_SKILL_UPGRADE == protocol.operate then
		if nil ~= RoleSkillCtrl then
			RoleSkillCtrl.Instance:OnTeamSkillUpGradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_RA_MAPHUNT_AUTO_FLUSH == protocol.operate  then
		if nil ~= MapFindCtrl then
			if protocol.result == 1 and MapFindCtrl.Instance:GetRush() then
				MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_AUTO_FLUSH,MapFindData.Instance:GetSelect(),5)
			else
				MapFindCtrl.Instance:EndRush()
			end
		end
	elseif MODULE_OPERATE_TYPE.OP_GREATE_SOLDIER_SLOT_UPLEVEL == protocol.operate then
		if nil ~= FamousGeneralCtrl then
			FamousGeneralCtrl.Instance:OnGreateSoldierUpLevel(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_MULTI_MOUNT_UPGRADE == protocol.operate then
		if nil ~= MultiMountCtrl then
			MultiMountCtrl.Instance:OnMultiMountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_REBIRTH_UPLEVEL == protocol.operate then
		if nil ~= RebirthCtrl then
			RebirthCtrl.Instance:OnRebirthUpGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_BABY_JL_UPGRADE == protocol.operate then
		if nil ~= BaobaoCtrl then
			BaobaoCtrl.Instance:OnBabyUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_MUSEUM_CARD_UPGRADE == protocol.operate then
		if nil ~= MuseumCardCtrl then
			MuseumCardCtrl.Instance:OnCardUpStarResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_UGS_HEAD_WEAR_UPGRADE == protocol.operate then
		if nil ~= DressUpCtrl then
			DressUpCtrl.Instance:HeadwearUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_UGS_MASK_UPGRADE == protocol.operate then
		if nil ~= DressUpCtrl then
			DressUpCtrl.Instance:MaskUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_UGS_KIRIN_ARM_UPGRADE == protocol.operate then
		if nil ~= DressUpCtrl then
			DressUpCtrl.Instance:KirinArmUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_UGS_WAIST_UPGRADE == protocol.operate then
		if nil ~= DressUpCtrl then
			DressUpCtrl.Instance:WaistUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_UGS_BEAD_UPGRADE == protocol.operate then
		if nil ~= DressUpCtrl then
			DressUpCtrl.Instance:BeadUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_UGS_FABAO_UPGRADE == protocol.operate then
		if nil ~= DressUpCtrl then
			DressUpCtrl.Instance:FaBaoUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_ELEMENT_HEART_UPGRADE == protocol.operate then
		if nil ~= SymbolCtrl.Instance then
			SymbolCtrl.Instance:OnElementHeartUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_ELEMENT_EQUIP_UPGRADE == protocol.operate then
		if nil ~= SymbolCtrl.Instance then
			SymbolCtrl.Instance:UpGradeResult(protocol.result)
		end
			elseif MODULE_OPERATE_TYPE.OP_ELEMENT_TEXTURE_UPGRADE == protocol.operate then
	if nil ~= SymbolCtrl.Instance then
			SymbolCtrl.Instance:OnElementTextureUpgradeResult(protocol.result)
		end
	else
		print_warning("cannot find auto upgrade result:", protocol.operate)
	end
end

function OtherCtrl:OpenGetItemView(item_id, item_count)
	print_log("物品不足-->> id : ", item_id)
	if item_id == 90054 then
		-- TipsCtrl.Instance:ShowLackDiamondView()
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoBindGold)
		print_log("绑定元宝不足")
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		print_log("物品不存在，请更新配置-->> id : ", item_id)
		return
	else
		if 31 == item_cfg.search_type then	--勾玉不弹获取提示
			return
		end
	end
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	if 0 == tonumber(way[1]) and (nil == item_cfg.get_msg or "" == item_cfg.get_msg) then
		item_count = item_count or 1
		local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if shop_item_cfg == nil then
			item_cfg = ItemData.Instance:GetItemConfig(item_id)
			TipsCtrl.Instance:ShowSystemMsg(ToColorStr(item_cfg.name, TEXT_COLOR.GREEN).."不足")
			print("缺少物品ID:",item_id)
		else
			if TipsCommonBuyView.AUTO_LIST[item_id] then
				local is_bind_gold = 0
				local shop_price = 0
				local need_sprice = 0
				local money = GameVoManager.Instance:GetMainRoleVo().bind_gold
				if shop_item_cfg.bind_gold and 0 ~= shop_item_cfg.bind_gold then
					shop_price = shop_item_cfg.bind_gold
				elseif shop_item_cfg.vip_gold and 0 ~= shop_item_cfg.vip_gold then
					shop_price = shop_item_cfg.vip_gold
				end

				if money < shop_price or (shop_item_cfg.bind_gold == 0 and shop_item_cfg.vip_gold == 0) then
					shop_price = shop_item_cfg.gold
				end
				need_sprice = shop_price * item_count

				if need_sprice <= PlayerData.Instance.role_vo.bind_gold then
					local shop_cfg = ShopData:GetShopItemCfg(item_id)
					if shop_cfg.bind_gold > 0 then
						is_bind_gold = 1
					end
				end
				
				MarketCtrl.Instance:SendShopBuy(item_id, item_count, is_bind_gold, 0)
			else
				local func = function(item_id2, item_num, is_bind, is_use)
					MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				end
				TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, item_count)
			end
		end
	else
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
	end
end

function OtherCtrl:OnSCDrawResult(protocol)
	local reason = protocol.draw_reason
	if reason == DRAW_REASON.DRAW_REASON_BEAUTY then
		BeautyData.Instance:SetPrayItemList(protocol.item_info_list)
		if protocol.item_count == 1 then
			TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY1, true)
		else
			TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY10, true)
		end
	elseif reason == DRAW_REASON.DRAW_REASON_GREATE_SOLDIER then
		FamousGeneralData.Instance:SetItemList(protocol.item_info_list)
		TipsCtrl.Instance:ShowTreasureView(SHOP_MODE[protocol.item_count])
		-- GlobalEventSystem:Fire(OtherEventType.CHEST_SHOP_ITEM_LIST, protocol.item_info_list)
	elseif reason == DRAW_REASON.DRAW_REASON_HAPPY_DRAW then
		HappyBargainData.Instance:SetDrawResultList(protocol)
		TipsCtrl.Instance:ShowTreasureView(HappyBargainData.Instance:GetChestShopMode())
	elseif reason == DRAW_REASON.DRAW_REASON_HAPPY_DRAW2 then
		-- MidAutumnLotteryCtrl.Instance:DelayOpenRewardView(protocol)
		MidAutumnLotteryData.Instance:SetDrawResultList(protocol)
		TipsCtrl.Instance:ShowTreasureView(MidAutumnLotteryData.Instance:GetChestShopMode(),true)
	end
end