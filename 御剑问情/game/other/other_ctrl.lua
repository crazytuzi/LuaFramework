require("game/other/other_data")

OtherCtrl = OtherCtrl or BaseClass(BaseController)

MODULE_OPERATE_TYPE = {
	OP_MOUNT_UPGRADE = 1,						-- 坐骑进阶
	OP_MOUNT_UPBUILD = 2,						-- 骑兵打造
	OP_Wing_UPEVOL = 6,							-- 羽翼进化
	OP_EQUIP_STRENGTHEN = 7,					-- 装备强化
	OP_STONE_UPLEVEL = 8 ,						-- 宝石升级成功
	OP_FISH_POOL_EXTEND_CAPACITY_SUCC = 9,		-- 鱼池扩展成功
	OP_WING_UPGRADE_SUCC = 10,
	OP_MOUNT_FLYUP = 11,						-- 坐骑飞升
	OP_XIANNV_HALO_UPGRADE = 12,				-- 仙女守护
	OP_JINGLING_UPGRADE = 17,					-- 精灵升阶
	OP_SHENZHUANG_JINJIE = 18,					-- 神装进阶
	OP_BABY_JIE_UPGRADE  = 19,                  -- 宝宝进阶
	OP_PET_JIE_UPGRADE = 20,					-- 宠物自动进阶
	OP_QINGYUAN_JIE_UPGRADE  = 21 ,             -- 情缘进阶
	OP_HUASHEN_UPLEVEL = 22,					-- 化神进阶
	OP_MULTI_MOUNT_UPGRADE = 24,				-- 双人坐骑进阶
	OP_WUSHANG_EQUIP_UPSTAR = 25,               -- 跨服装备升星
	OP_JINGLING_HALO_UPSTAR = 26,				-- 精灵光环升级
	OP_HALO_UPGRADE = 29,						-- 进阶光环升级
	OP_SHENGONG_UPGRADE = 30,					-- 进阶神弓升级
	OP_SHENYI_UPGRADE = 31,						-- 进阶神翼升级
	OP_JINGLING_FAZHEN_UPGRADE = 33,			-- 精灵法阵升阶
	OP_SHENGONG_UPSTAR = 34,					-- 神弓升星
	OP_SHENYI_UPSTAR = 35,						-- 神翼升星
	OP_HUASHEN_UPGRADE_SPIRIT = 36,				-- 化神精灵进阶
	OP_FIGHT_MOUNT_UPGRADE = 37,				-- 战斗坐骑进阶
	OP_LIEMING_CHOUHUN = 38,					-- 猎命抽魂结果
	OP_MOUNT_UPSTAR = 39,						-- 坐骑升星
	OP_WING_UPSTAR = 40,						-- 羽翼升星
	OP_HALO_UPSTAR = 41,						-- 光环升星
	OP_FIGHT_MOUNT_UPSTAR = 42,					-- 战骑升星
	OP_SHEN_BING_UPGRADE = 43,					-- 神兵进阶
	OP_SHENZHOU_WEAPON = 44,					-- 魂器
	OP_UP_ETERNITY = 45,						-- 永恒装备升级
	OP_RA_MAPHUNT_AUTO_FLUSH = 46,				-- 地图寻宝自动刷新
	OP_FOOTPRINT_UPGRADE = 47,					-- 足迹升阶
	OP_FOOTPRINT_UPSTAR = 48,					-- 足迹升星
	OP_CLOAK_UPLEVEL = 49,						-- 披风升级
	OP_JL_CZ_UPGRADE = 50,						-- 精灵成长进阶
	OP_JL_WX_UPGRADE = 51,						-- 精灵悟性进阶
	OP_BABY_JL_UPGRADE = 52,				    -- 宝宝守卫精灵进阶
	OP_SHENQI_SHENGBING_UPLEVEL = 53,			-- 神兵升级
	OP_SHENQI_BAOJIA_UPLEVEL = 54,				-- 宝甲升级
	OP_LOVE_TREE_UPLEVEL = 55,					-- 相思树浇水
	OP_GLOD_HUNT = 56,							-- 黄金猎场
	OP_RA_FANFAN_REFRESH = 57,					-- 寻字好礼
	OP_ONEKEY_LIEMING_GAIMING = 58,				-- 精灵命魂-自动改命-改命
	OP_ONEKEY_LIEMING_CHOUHUN = 59,				-- 精灵命魂-自动改命-抽魂
	OP_BOSS_HANDBOOK_UPLEVEL = 61,				-- BOSS图鉴升级
	OP_WAIST = 62,								-- 外观-腰饰
	OP_TOUSHI = 63,								-- 外观-头饰
	OP_QILINBI = 64,							-- 外观-麒麟臂
	OP_MASK = 65,								-- 外观-面饰
	OP_XIANBAO = 66,							-- 外观-仙宝
	OP_LINGZHU = 67,							-- 外观-灵珠
	OP_LINGCHONG = 68,							-- 外观-灵宠
	OP_LINGGONG = 69,							-- 外观-灵弓
	OP_LINGQI = 70,								-- 外观-灵骑
	OP_ELEMENT_HEART_UPGRADE = 71,				-- 元素之心进阶
	OP_ELEMENT_EQUIP_UPGRADE = 72,				-- 元素之心装备进阶
	OP_ELEMENT_TEXTURE_UPGRADE = 73,			-- 元素之心纹进阶
	OP_SHEN_YIN_LIEHUN = 74,					-- 神印系统猎魂
    OP_SHEN_YIN_SUPER_CHOU_HUN = 75,            -- 神印系统改命
	OP_WEIYAN = 80,								-- 外观-尾焰
	OP_IMP_GUARD_RENEW = 81,					-- 小鬼守护续费结果
 }

function OtherCtrl:__init()
	OtherCtrl.Instance = self

	self.get_item_view = QuickBuy.New()
	self.data = OtherData.New()
	self:RegisterEvent()
	self:RegisterAllProtocals()
end

function OtherCtrl:__delete()
	if self.get_item_view then
		self.get_item_view:DeleteMe()
		self.get_item_view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
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
end

function OtherCtrl:OnOperateResult(protocol)
	GlobalEventSystem:Fire(OtherEventType.OPERATE_RESULT, protocol.operate, protocol.result, protocol.param1, protocol.param2)
	-- print_error(protocol.operate, protocol.result)
	if MODULE_OPERATE_TYPE.OP_MOUNT_UPSTAR == protocol.operate or MODULE_OPERATE_TYPE.OP_MOUNT_UPGRADE == protocol.operate then
		-- 坐骑升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:MountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_FOOTPRINT_UPSTAR == protocol.operate or MODULE_OPERATE_TYPE.OP_FOOTPRINT_UPGRADE == protocol.operate then
		-- 足迹升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:FootUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_WING_UPSTAR == protocol.operate or MODULE_OPERATE_TYPE.OP_WING_UPGRADE_SUCC == protocol.operate then
		-- 羽翼升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:WingUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_HALO_UPSTAR == protocol.operate or MODULE_OPERATE_TYPE.OP_HALO_UPGRADE == protocol.operate then
		-- 光环升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:HaloUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHENGONG_UPSTAR == protocol.operate or MODULE_OPERATE_TYPE.OP_SHENGONG_UPGRADE == protocol.operate then
		if nil ~= ShengongCtrl then
			ShengongCtrl.Instance:OnUppGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_XIANNV_HALO_UPGRADE == protocol.operate then
		if nil ~= GoddessShouhuCtrl then
			GoddessShouhuCtrl.Instance:OnUppGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHENYI_UPSTAR == protocol.operate or MODULE_OPERATE_TYPE.OP_SHENYI_UPGRADE == protocol.operate then
		if nil ~= ShenyiCtrl then
			ShenyiCtrl.Instance:OnUppGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_JINGLING_FAZHEN_UPGRADE == protocol.operate then
		if nil ~= SpiritCtrl then
			SpiritCtrl.Instance:OnFazhenUppGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_JINGLING_HALO_UPSTAR == protocol.operate then
		if nil ~= SpiritCtrl then
			SpiritCtrl.Instance:OnHaloUpGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_HUASHEN_UPGRADE_SPIRIT == protocol.operate then
		if nil ~= SpiritCtrl then
			HuashenCtrl.Instance:OnSpiritUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_FIGHT_MOUNT_UPSTAR == protocol.operate or MODULE_OPERATE_TYPE.OP_FIGHT_MOUNT_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:OnFightMountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_LIEMING_CHOUHUN == protocol.operate then
		if 1 == protocol.result then return end
		local item_id = 22606
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(item_id, 2)
			return
		end

		local func = function(_item_id, item_num, is_bind, is_use, is_auto_buy)
			SpiritData.Instance:SetAutoLieHun(is_auto_buy)
			MarketCtrl.Instance:SendShopBuy(_item_id, item_num, is_bind, is_use)
		end
		if SpiritData.Instance:GetAutoLieHun() == true then
			local is_bind = 0
	        local shop_cfg = ShopData:GetShopItemCfg(item_id)
	        if shop_cfg and shop_cfg.bind_gold > 0 then
	          is_bind = 1
	        end
			MarketCtrl.Instance:SendShopBuy(item_id, 1, is_bind, 1)
		else
			TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1)
		end
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
	elseif MODULE_OPERATE_TYPE.OP_CLOAK_UPLEVEL == protocol.operate then
		-- 披风升级
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:CloakUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_MULTI_MOUNT_UPGRADE == protocol.operate then
		if nil ~= MultiMountCtrl then
			MultiMountCtrl.Instance:OnMultiMountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_JL_CZ_UPGRADE == protocol.operate then
		if nil ~= SpiritCtrl then
			SpiritCtrl.Instance:OnAttrOperateResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_JL_WX_UPGRADE == protocol.operate then
		if nil ~= SpiritCtrl then
			SpiritCtrl.Instance:OnAptitudeOperateResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_BABY_JL_UPGRADE == protocol.operate then
		if nil ~= BaobaoCtrl then
			BaobaoCtrl.Instance:OnOperateResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_LOVE_TREE_UPLEVEL == protocol.operate then
		if nil ~= MarriageCtrl.Instance then
			MarriageCtrl.Instance:OnLoveTreeOperateResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHENQI_BAOJIA_UPLEVEL == protocol.operate then
		if nil ~= ShenqiCtrl.Instance then
			ShenqiCtrl.Instance:OnBaojiaUpGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHENQI_SHENGBING_UPLEVEL == protocol.operate then
		if nil ~= ShenqiCtrl.Instance then
			ShenqiCtrl.Instance:OnShenbingUpGradeOptResult(protocol.result)
		end
	-- elseif  MODULE_OPERATE_TYPE.OP_GLOD_HUNT == protocol.operate then
	-- 	if nil ~= GoldHuntCtrl.Instance then
	-- 		GoldHuntCtrl.Instance:OnHuntRushOptResult(protocol.result)
	-- 	end
	elseif MODULE_OPERATE_TYPE.OP_RA_FANFAN_REFRESH == protocol.operate then
		if nil ~= PuzzleCtrl.Instance then
			PuzzleCtrl.Instance:OnFastFilpResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_ONEKEY_LIEMING_GAIMING == protocol.operate then
		if nil ~= SpiritCtrl.Instance and nil ~= SpiritData.Instance then
			local state = SpiritData.Instance:GetQuickChangeLifeState()
			if state ~= QUICK_FLUSH_STATE.GAI_MING_ZHONG then return end
			SpiritCtrl.Instance:OnQuickGaiMingResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_ONEKEY_LIEMING_CHOUHUN == protocol.operate then
		if nil ~= SpiritCtrl.Instance and nil ~= SpiritData.Instance then
			local state = SpiritData.Instance:GetQuickChangeLifeState()
			if state ~= QUICK_FLUSH_STATE.CHOU_HUN_ZHONG then return end
			SpiritCtrl.Instance:OnQuickGaiMingResult(protocol.result)
		end
	--改命
	elseif MODULE_OPERATE_TYPE.OP_SHEN_YIN_SUPER_CHOU_HUN == protocol.operate then
		if nil ~= ShenYinCtrl.Instance and nil ~= ShenYinData.Instance then
			local state = ShenYinData.Instance:GetQuickChangeLifeState()
			if state ~= RARE_FLUSH_STATE.GAI_MING_ZHONG then return end
			ShenYinCtrl.Instance:OnQuickGaiMingResult(protocol.result)
		end
	--抽魂
	elseif MODULE_OPERATE_TYPE.OP_SHEN_YIN_LIEHUN == protocol.operate then
		if nil ~= ShenYinCtrl.Instance and nil ~= ShenYinData.Instance then
			local state = ShenYinData.Instance:GetQuickChangeLifeState()
			-- print_error("state",state)
			if state ~= RARE_FLUSH_STATE.CHOU_HUN_ZHONG then return end
			ShenYinCtrl.Instance:OnQuickGaiMingResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_BOSS_HANDBOOK_UPLEVEL == protocol.operate then
		if nil ~= IllustratedHandbookCtrl.Instance then
			IllustratedHandbookCtrl.Instance:FlushEffect(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_WAIST == protocol.operate then
		if nil ~= WaistCtrl.Instance then
			WaistCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_TOUSHI == protocol.operate then
		if nil ~= TouShiCtrl.Instance then
			TouShiCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_QILINBI == protocol.operate then
		if nil ~= QilinBiCtrl.Instance then
			QilinBiCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_MASK == protocol.operate then
		if nil ~= MaskCtrl.Instance then
			MaskCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_LINGZHU == protocol.operate then
		if nil ~= LingZhuCtrl.Instance then
			LingZhuCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_LINGCHONG == protocol.operate then
		if nil ~= LingChongCtrl.Instance then
			LingChongCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_XIANBAO == protocol.operate then
		if nil ~= XianBaoCtrl.Instance then
			XianBaoCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_LINGGONG == protocol.operate then
		if nil ~= LingGongCtrl.Instance then
			LingGongCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_LINGQI == protocol.operate then
		if nil ~= LingQiCtrl.Instance then
			LingQiCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_WEIYAN == protocol.operate then
		if nil ~= WeiYanCtrl.Instance then
			WeiYanCtrl.Instance:UpGradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_IMP_GUARD_RENEW == protocol.operate then
		local des = ""
		if protocol.result == 0 then
			des = Language.Common.XuFeiFail
		else
			des = Language.Common.XuFeiSucc
			TipsCtrl.Instance:UpDateImpGuardTimeOutData(protocol.param1)
			TipsCtrl.Instance:CheckImpGuardTimeOutTips()
		end
		SysMsgCtrl.Instance:ErrorRemind(des)

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

	if item_id == 27287 then
		TipsCtrl.Instance:ShowSystemMsg(Language.FuBen.ExpFuBenError)
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
			local func = function(item_id2, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func,item_id)
		end
	else
		-- 伙伴光环和法阵，升级过程中消耗完物品以后，你活哥不给弹物品不足的Tip
		-- 只有再次点击进阶按钮的时候才允许弹
		local nvshen_fazhen_cfg = ShengongData.Instance:GetShengongUpStarPropCfg()
		local nvshen_guanghuan_cfg = ShenyiData.Instance:GetShenyiUpStarPropCfg()
		if item_id == nvshen_fazhen_cfg[1].up_star_item_id or item_id == nvshen_fazhen_cfg[2].up_star_item_id or item_id == nvshen_fazhen_cfg[3].up_star_item_id
			or item_id == nvshen_guanghuan_cfg[1].up_star_item_id or item_id == nvshen_guanghuan_cfg[2].up_star_item_id or item_id == nvshen_guanghuan_cfg[3].up_star_item_id then
			return
		end
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
	end
end