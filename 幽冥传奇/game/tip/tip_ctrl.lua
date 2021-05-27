require("scripts/game/tip/tip_def")

require("scripts/game/tip/views/base_tip")
require("scripts/game/tip/views/tip_sub")
require("scripts/game/tip/views/tip_sub_top")
require("scripts/game/tip/views/tip_sub_attr")
require("scripts/game/tip/views/tip_sub_desc")
require("scripts/game/tip/views/tip_sub_skill_desc")
require("scripts/game/tip/views/tip_sub_opt")
require("scripts/game/tip/views/tip_sub_itemdesc")
require("scripts/game/tip/views/tip_sub_itemopt")
require("scripts/game/tip/views/tip_eff_show_top")


require("scripts/game/tip/item_tips")
require("scripts/game/tip/buff_tip")
require("scripts/game/tip/vip_limit_tip")
require("scripts/game/tip/stuff_tip")
require("scripts/game/tip/melt_soul_tip")
require("scripts/game/tip/inner_tip")
require("scripts/game/tip/select_item_num_tip")

require("scripts/game/tip/card_base_tips")
require("scripts/game/tip/preview_item_tip")
require("scripts/game/tip/fuben_tip")
require("scripts/game/tip/task_guide_level_view")
require("scripts/game/tip/red_packet_tip")

require("scripts/game/tip/select_item_tip")
require("scripts/game/tip/special_equip_tip")

require("scripts/game/tip/skill_special_tip")

require("scripts/game/tip/award_show_tip")

TipCtrl = TipCtrl or BaseClass(BaseController)

function TipCtrl:__init()
	if TipCtrl.Instance ~= nil then
		error("[TipCtrl] attempt to create singleton twice!")
		return
	end
	TipCtrl.Instance = self

	self.equip_tip = BaseTip.New(ViewDef.EquipTip)
	self.equip_tip:SetPartsCfg({TipSubTop, TipSubAttr, TipSubDesc,TipSubSkillDesc, TipSubOpt})
	self.equip_tip:SetModal(true)

	self.equip_eff_show_tip = BaseTip.New(ViewDef.EquipEffShowTip)
	self.equip_eff_show_tip:SetPartsCfg({TipSubEffShowTop, TipSubAttr, TipSubDesc,TipSubSkillDesc, TipSubOpt})
	self.equip_eff_show_tip:SetModal(true)

	self.compare_equip_tip = BaseTip.New(ViewDef.CompareEquipTip)
	self.compare_equip_tip:SetPartsCfg({TipSubTop, TipSubAttr, TipSubDesc, TipSubSkillDesc, TipSubOpt})

	self.compare_equip_eff_show_tip = BaseTip.New(ViewDef.CompareEquipEffShowTip)
	self.compare_equip_eff_show_tip:SetPartsCfg({TipSubEffShowTop, TipSubAttr, TipSubDesc, TipSubSkillDesc, TipSubOpt})
	-- self.compare_equip_tip:SetModal(false)
	-- self.compare_equip_tip:SetIsAnyClickClose(false)

	self.item_tips = BaseTip.New(ViewDef.ItemTip)
	self.item_tips:SetPartsCfg({TipSubTop, TipSubItemDesc, TipSubItemOpt})

	self.item_tips1 = BaseTip.New(ViewDef.ItemTip1)
	self.item_tips1:SetPartsCfg({TipSubTop, TipSubAttr,TipSubItemDesc, TipSubItemOpt})

	self.buff_tip = BuffTipView.New()
	self.desc_tip = DescTip.New()
	self.stuff_tip = StuffTipsView.New()
	self.melt_soul_tip = MeltSoulTipsView.New()
	self.viplimit_tip = VipLimitView.New(ViewDef.VIPLimit)
	self.inner_tip = InnerTipView.New()
	self.red_packet_tip = RedPacketTip.New()
	self.select_item_tip = SelectItemTip.New()
	self.select_item_num_tip = SelectItemNumTip.New()

	
	self.preview_item_tip = PreviewTip.New()

	self.battle_line_item_tip = BaseTip.New(ViewDef.BattleLineTip)
	local battle_ui = require("scripts/game/tip/battle_line_tip_ui_control")
	self.battle_line_item_tip:SetPartsCfg({battle_ui.TipTop, battle_ui.TipCurrAttr, battle_ui.TipNextAttr, battle_ui.TipDesc, TipSubOpt})

	self.fuben_tip = FubenTip.New()

	self.special_equip_tip = SpecialEquipTip.New(ViewDef.SpecialEquipTipShow)

	--引导提示界面
	self.guide_level = GuideLevelUpView.New(ViewDef.GuideLevelUp)	--等级成长

	self.skill_special_tip = SkillSpecialTip.New(ViewDef.SkillSpecialTip)

	self.award_show_tip = AwardShowTip.New(ViewDef.AwardShowTip)
end

function TipCtrl:__delete()
	TipCtrl.Instance = nil

	self.equip_tip:DeleteMe()
	self.equip_tip = nil

	self.equip_eff_show_tip:DeleteMe()
	self.equip_eff_show_tip = nil

	self.compare_equip_tip:DeleteMe()
	self.compare_equip_tip = nil

	self.item_tips:DeleteMe()
	self.item_tips = nil

	self.battle_line_item_tip:DeleteMe()
	self.battle_line_item_tip = nil

	self.buff_tip:DeleteMe()
	self.buff_tip = nil

	self.desc_tip:DeleteMe()
	self.desc_tip = nil

	self.viplimit_tip:DeleteMe()
	self.viplimit_tip = nil

	self.stuff_tip:DeleteMe()
	self.stuff_tip = nil

	self.preview_item_tip:DeleteMe()
	self.preview_item_tip = nil

	if self.destroy_alert then
		self.destroy_alert:DeleteMe()
		self.destroy_alert = nil
	end

	self.melt_soul_tip:DeleteMe()
	self.melt_soul_tip = nil

	self.inner_tip:DeleteMe()
	self.inner_tip = nil

	self.select_item_tip:DeleteMe()
	self.select_item_tip = nil

	if self.item_tips1 then
		self.item_tips1:DeleteMe()
		self.item_tips1 = nil
	end

	if self.special_equip_tip then
		self.special_equip_tip:DeleteMe()
		self.special_equip_tip = nil
	end

	self.red_packet_tip:DeleteMe()
	self.red_packet_tip = nil

	self.select_item_num_tip:DeleteMe()
	self.select_item_num_tip = nil
end

function TipCtrl:CloseEquip()
	self.equip_tip:Close()
end

function TipCtrl:ShowSelectItemNumip(data)
	if self.select_item_num_tip then
		self.select_item_num_tip:SetData(data)
		self.select_item_num_tip:Open()
	end
end

--打开面板
function TipCtrl:ShowRedPacketTip(data)
	if self.red_packet_tip then
		self.red_packet_tip:SetData(data)
		self.red_packet_tip:Open()
	end
end

function TipCtrl:FlushRedPacketTip()
	if self.red_packet_tip then
		self.red_packet_tip:Flush()
	end
end

function TipCtrl:OpenAttrdan(attr_type, attr_list)
	self.attrdan_tip:SetData(attr_type, attr_list)
	self.attrdan_tip:Open()
end

--打开副本tip面板
function TipCtrl:ShowFubenTip(awards, bossNum, type, time)
	if self.fuben_tip then
		self.fuben_tip:SetData(awards, bossNum, type, time)
		self.fuben_tip:Open()
		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true)
	end
end

function TipCtrl:CloseSelectView()
	self.select_item_tip:Close()
end

function TipCtrl:OpenSeletItemTip(data)
	self.select_item_tip:Open()
	self.select_item_tip:Flush(0, "all", data)
end

--双击使用
function TipCtrl:DoubleClickUseItem(data, fromView)
	local handle_types = {}
	if ItemData.GetIsEquip(data.item_id) or 
	ItemData.GetIsShengXiao(data.item_id) or
		ItemData.GetIsHeroEquip(data.item_id) or 
		ItemData.GetIsFashion(data.item_id) or
		ItemData.GetIsFuwen(data.item_id) then
		self.equip_tip.data = data
		handle_types = self.equip_tip:GetOperationLabelByType(fromView)
	else
		self.item_tips.data = data
		handle_types = self.item_tips:GetOperationLabelByType(fromView)
	end
	for k,v in pairs(handle_types) do
		if v == EquipTip.HANDLE_EQUIP or v == EquipTip.HANDLE_USE then
			self:UseItem(v, data, nil, fromView)
			return true
		end
	end
	return false
end

-- function TipCtrl:( ... )
-- 	-- body
-- end

function TipCtrl:OpenItem(data, fromView, param_t)
	if nil == data then return end

	-- 仓库打开时 背包物品fromView变化
	if fromView == EquipTip.FROM_BAG then
		if ViewManager.Instance:IsOpen(ViewDef.Storage) then
			fromView = EquipTip.FROM_BAG_ON_BAG_STORAGE
		end
	end
	local is_had_compare = false
	if nil ~= data.item_id then
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		local tip_type = TIP_SHOW_TYPE_CFG[item_cfg.type] or TIP_SHOW_TYPE.ITEM
		if tip_type == TIP_SHOW_TYPE.EQUIP or tip_type == TIP_SHOW_TYPE.EFF_SHOW then
			-- 查看基础装备时需要打开主角自己装备对比tip
			local compare_eq = nil
			if fromView ~= EquipTip.FROM_BAG_EQUIP and fromView ~= EquipTip.FROM_EQUIP_GODFURANCE then
				if data.type and data.hand_pos and ItemData.IsBaseEquipType(data.type) then
					local main_role_equip
					if (data.type == 5 or data.type == 6) then 		--对戒指和手镯进行特殊判断
						local equip_left_slot = EquipData.Instance:GetEquipSlotByType(data.type, EquipData.EQUIP_HAND_POS.LEFT)
						local equip_right_slot = EquipData.Instance:GetEquipSlotByType(data.type, EquipData.EQUIP_HAND_POS.RIGHT)
						local equip_left = EquipData.Instance:GetEquipDataBySolt(equip_left_slot)
						local equip_right = EquipData.Instance:GetEquipDataBySolt(equip_right_slot)
						--如果同一个类型有两件装备，显示评分低的那件装备的那件
						if(equip_left and equip_right and equip_left ~= data and equip_right ~= data) then
							local equip_left_cfg = ItemData.Instance:GetItemConfig(equip_left.item_id) or CommonStruct.ItemConfig()
							local equip_right_cfg = ItemData.Instance:GetItemConfig(equip_right.item_id) or CommonStruct.ItemConfig()
							local is_low = ItemData.Instance:GetItemScore(equip_left_cfg, equip_left) < ItemData.Instance:GetItemScore(equip_right_cfg, equip_right)
							if(is_low) then
								compare_eq = equip_left
							else
								compare_eq = equip_right 
							end
						else
							compare_eq = nil   --如果只有一个则不显示     
						end
					else
						local equip_slot = EquipData.Instance:GetEquipSlotByType(data.type, data.hand_pos)
						compare_eq = EquipData.Instance:GetEquipDataBySolt(equip_slot)
					end
					if nil ~= compare_eq and data ~= compare_eq then
						is_had_compare = true
					end
				elseif GodFurnaceData.Instance:IsVirtualEquipType(item_cfg.type) then
					local gf_slot = GodFurnaceData.Instance:GetGfSlotByItemType(item_cfg.type)
					local compare_eq = GodFurnaceData.Instance:GetVirtualEquipData(gf_slot)
					if nil ~= compare_eq then
						is_had_compare = true
					end
				end

			end

			local is_show_top_eff = item_cfg.showQualityBg == 9
			local is_show_left_eff = not is_had_compare and SpecialTipsCfg[data.item_id] and item_cfg.showQualityBg ~= 9

			local tip_view = is_show_top_eff and self.equip_eff_show_tip or self.equip_tip
			local compare_view = is_show_top_eff and self.compare_equip_eff_show_tip or self.compare_equip_tip
			
			if is_had_compare and compare_eq then
				compare_view:SetData(compare_eq, EquipTip.FROM_EQUIP_COMPARE)
			end

			if is_show_left_eff then
				tip_view:SetData(data, fromView, param_t, 150, true)
			else
				tip_view:SetData(data, fromView, param_t) --有比较
			end
			tip_view:ChangeModal(not is_had_compare)

		elseif tip_type == TIP_SHOW_TYPE.ITEM then
			if (data.item_id >= 10000 ) and item_cfg.type == 1000 then
				self.item_tips1:SetData(data, fromView, param_t)
			elseif ItemData.IsJinYanZhuUseItemType(item_cfg.type) then
				self.item_tips1:SetData(data, fromView, param_t)
			else
				self.item_tips:SetData(data, fromView, param_t)
			end
		elseif tip_type == TIP_SHOW_TYPE.CARD then
			self.preview_item_tip:SetData(data, fromView, param_t)
		elseif tip_type == TIP_SHOW_TYPE.BATTLE_LINE then
			self.battle_line_item_tip:SetData(data, fromView, param_t)
		end
		return
	end
end

function TipCtrl:UseItem(handle_type, data, handle_param_t, fromView)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)

	if handle_type == EquipTip.HANDLE_DISCARD then							--丢弃
		self.destroy_alert = self.destroy_alert or Alert.New()
		local content = string.format(Language.Guild.DescardItemAlert, string.format("%06x", item_cfg.color), EquipTip.GetEquipName(item_cfg, data, fromView))
		self.destroy_alert:SetLableString(content)
		self.destroy_alert:SetOkFunc(BindTool.Bind(function ()
				BagCtrl.Instance:SendDeleteItem(data.series)
			end, self))
		self.destroy_alert:SetCancelString(Language.Common.Cancel)
		self.destroy_alert:SetOkString(Language.Common.Confirm)
		self.destroy_alert:SetShowCheckBox(true)
		self.destroy_alert:Open()
	elseif handle_type == EquipTip.HANDLE_USE then			
		--使用
		if data.item_id == CLIENT_GAME_GLOBAL_CFG.change_name_card then
			OtherCtrl.Instance:OpenChangeName(data)
			return
		end


		if item_cfg.openUi and item_cfg.openUi ~= "" then
			-- 技能书特殊处理
			local cfg = CleintItemShowCfg or {} -- 文件名 cleint_item_effect_cfg
			local skill_id = cfg[4] and cfg[4][data.item_id] -- 当前技能书物品ID对应的技能id
			if skill_id then
				if not SkillData.Instance:GetSkill(skill_id) then
					BagCtrl.Instance:SendUseItem(data.series, 0, 1)
					return
				end
			end

			local view_param = Split(item_cfg.openUi or "", "#")
			local def = ViewManager.Instance:GetDefByKeyT(view_param)
			if ViewManager.Instance:CanOpen(def) then
				ViewManager.Instance:OpenViewByDef(def)
			else
				if def.v_open_cond then
					local tip = GameCond[def.v_open_cond] and GameCond[def.v_open_cond].Tip or ""
					SysMsgCtrl.Instance:FloatingTopRightText(tip)
				end
			end
			return
		end

		local num = 1
		if item_cfg.batchStatus and item_cfg.batchStatus >= ItemData.BatchStatus.BatchUse then
			num = data.num
		end

        --自定义称号特殊处理
        if data.item_id == CLIENT_GAME_GLOBAL_CFG.custom_title_a or CLIENT_GAME_GLOBAL_CFG.custom_title_b == data.item_id then
            local comtom_title_can_use = false
            local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
            local effect_list = {}
            if cc.FileUtils:getInstance():isFileExist("scripts/config/client/title/customized_title.lua") then
                if data.item_id == CLIENT_GAME_GLOBAL_CFG.custom_title_a then
		            effect_list = ConfigManager.Instance:GetClientConfig("title/customized_title")[13]
                else
                    effect_list = ConfigManager.Instance:GetClientConfig("title/customized_title")[14]
                end
	        end
            if nil ~= effect_list then
                for k,v in ipairs(effect_list) do
                    if v.role_id == role_id then
                        comtom_title_can_use = true
                    end
                end
            end
            if not comtom_title_can_use then
                SysMsgCtrl.Instance:ErrorRemind(Language.Role.UseTitleLimit)
                return
            end
        end

        if item_cfg.type == ItemData.ItemType.itItemBox then
        	DiamondPetCtrl.Instance:OpenBox(data)
        	return
        end

        if (item_cfg.type == 102 or item_cfg.type == 103 or item_cfg.type == 104) and not EquipData.CheckHasLimit(item_cfg) then
			local fly_node = ItemData.GetViewNameByFlyType(item_cfg.flyType)
			if fly_node then
				ItemData.USE_ITEM_EFF_CACHE = {series = data.series, item_cfg = item_cfg}
			end
		end
		
		if item_cfg.type == ItemData.ItemType.itSelectItem then
			self:OpenSeletItemTip(data)
			return
		end	
        if ItemData.IsJinYanZhuUseItemType(item_cfg.type) then
        	local cur_exp = data.durability or 0
			local max_exp = data.durability_max or 0 
        	if cur_exp  < max_exp then
        		 SysMsgCtrl.Instance:FloatingTopRightText(Language.Tip.TipShow4)
        		 return
       		else
       			if BagData.Instance:GetCanUseJiYanZhu() then
	       			ViewManager.Instance:OpenViewByDef(ViewDef.JiYanView)
					ViewManager.Instance:FlushViewByDef(ViewDef.JiYanView, 0, "jiyan", {item_data = data})
				else
					SysMsgCtrl.Instance:FloatingTopRightText(Language.Bag.TipShow8)
				end
       			return
        	end
        end
     
		BagCtrl.Instance:SendUseItem(data.series, 0, 1)

	
	elseif handle_type == EquipTip.HANDLE_SPLIT then						--拆分
		BagCtrl.Instance:SendSplitItem(data.series, handle_param_t.num or 1)
		if fromView == EquipTip.FROM_CONSIGN_ON_SELL then
			-- ConsignCtrl.Instance:SplitItemCallBack()
		end
	elseif handle_type == EquipTip.HANDLE_EQUIP then						--装备
		if ItemData.GetIsHeroEquip(data.item_id) then
			ZhanjiangCtrl.HeroPutOnEquipReq(data.series)
		elseif ItemData.GetIsCard(data.item_id) then
			ViewManager.Instance:OpenViewByDef(ViewDef.CardHandlebook.CardView)
		elseif ItemData.GetIsFashion(data.item_id) or ItemData.GetIsHuanWu(data.item_id) or ItemData.GetIsZhenqi(item_id) then
			local item_type = item_cfg.type or 0
			local data_list = FashionData:GetFashionDataByItemType(item_type)
			
			local cur_count = 0
			for i,v in pairs(data_list or {}) do
				cur_count = cur_count + 1
			end
			
			if cur_count < GlobalConfig.nImageGridMaxCount then
				FashionCtrl.Instance:SendXingXiangGuan(data.series) --放入形象框的直接幻化
				FashionCtrl.Instance:SendHuanhuaEquipReq(data.series) --幻化
			else
				local EquipTypeName = Language.EquipTypeName[item_type] or ""
				local str  = Language.EquipTypeName[item_type] .. "槽位已满"
				SysMsgCtrl.Instance:FloatingTopRightText(str)
			end

		elseif ItemData.GetIsShengXiao(data.item_id) then
			FashionCtrl.SendEquipFashionReq(data.series)
		elseif ItemData.IsBaseEquipType(item_cfg.type) then
			local is_better, hand_pos = EquipData.Instance:GetIsBetterEquip(data)
			hand_pos = hand_pos or EquipData.EQUIP_HAND_POS.LEFT
			EquipCtrl.Instance:FitOutEquip(data, hand_pos)
		elseif ItemData.GetIsZhanwenType(item_cfg.type) then
			ViewManager.Instance:OpenViewByDef(ViewDef.BattleFuwen)
		elseif ItemData.GetIsWingEquip(data.item_id) then 				-- 影翼装备
			
			WingCtrl.SendEquipmentShenyu(data.series)
		elseif ItemData.GetIsConstellation(data.item_id) then
			HoroscopeCtrl.PutOnConstellation(data.series)
		elseif ItemData.GetIHandEquip(data.item_id) then
			EquipCtrl.Instance:FitOutEquip(data)
		elseif ItemData.GetIsHandedDown(data.item_id) then
			EquipCtrl.Instance:FitOutEquip(data)
		elseif ItemData.IsGuardEquip(item_cfg.type) then 				-- 守护神装
			GuardEquipCtrl.Instance.SendWearGuardEquipReq(data.series)
		elseif ItemData.IsZhanShenEquip(data.item_id) or ItemData.IsShaShenEquip(data.item_id) or ItemData.IsReXueEquip(data.item_id)  then -- 战神装备
			EquipCtrl.Instance:FitOutEquip(data)
		end
	elseif handle_type == EquipTip.HANDLE_INLAY then						--镶嵌
		if fromView == EquipTip.FROME_BAG_STONE then
			StoneCtrl.Instance.SendEquipInlayGemReq(handle_param_t.equip_slot, handle_param_t.stone_slot, handle_param_t.stone_series)
		else
			ViewManager.Instance:OpenViewByDef(ViewDef.Equipment.Stone) 
		end
	elseif handle_type == EquipTip.HANDLE_ONEKEY_SYNTHETIC then				--一键合成
		if fromView == EquipTip.FROME_BAG_STONE then
			StoneData.Instance:OneKeyComposeStone(data.item_id)
		end
	elseif handle_type == EquipTip.HANDLE_STRENGTHEN then					--强化
		ViewManager.Instance:OpenViewByDef(ViewDef.Equipment.Strength) 

	elseif handle_type == EquipTip.HANDLE_TAKEOFF then						--卸下
		if fromView == EquipTip.FROM_BAG_EQUIP or fromView == EquipTip.FROM_GUN_OR_CAR or fromView == EquipTip.FROM_ROLE_HAND then
			EquipCtrl.SendTakeOffEquip(data.series)
		elseif fromView == EquipTip.FROM_RUNE then
			-- FuwenCtrl.SendFuwenTakeOffReq(handle_param_t.boss_index, handle_param_t.fuwen_index)
		elseif fromView == EquipTip.FROM_FASHION_CLOTHES then
			FashionCtrl.SendTakeOffFashionClothReq(data.seriess, data.fashion_index)
		elseif fromView == EquipTip.FROME_EQUIP_STONE then
			StoneCtrl.SendEquipUnloadStoneReq(handle_param_t.equip_slot, handle_param_t.stone_slot)
		elseif fromView == EquipTip.FROM_HERO_EQUIP then
			ZhanjiangCtrl.HeroPutOffEquipReq(data.series)
		elseif fromView == EquipTip.FROM_WING_EQUIP_SHOW then 		-- 影翼装备
			local index = WingData.Instance:GetWingIndex(data.item_id)

			WingCtrl.SendTakeOfftShenyu(index)
		elseif fromView == EquipTip.FROM_WING_EQUIP then 				-- 翅膀装备
			local index = WingData.Instance:GetWingIndex(data.item_id)
			
			WingCtrl.SendTakeOfftShenyu(index)
		elseif fromView == EquipTip.FROM_HOROSCOPE then
			HoroscopeCtrl.TakeOffOneConstellation(handle_param_t.horoscope_slot)
		elseif fromView == EquipTip.FROM_ROlE_CHUANG_SHI then
			EquipCtrl.SendTakeOffEquip(data.series)
		elseif fromView == EquipTip.FROM_ROlE_NEWREXUE_EQUIP then
			EquipCtrl.SendTakeOffEquip(data.series)
		end
	elseif handle_type == EquipTip.HANDLE_INPUT then						--投入
		if fromView == EquipTip.FROM_BAG_ON_GUILD_STORAGE then
			GuildCtrl.MoveToGuildStorageFromBag(data.series)
		elseif fromView == EquipTip.FROM_MEIBA_BAG then
			MeiBaShouTaoData.Instance:InPutItemCompose(data)
		elseif fromView == EquipTip.FROM_CS_BAG then
			EquipData.Instance:InputCsCompose(data)
		elseif fromView == EquipTip.FROM_CS_DECOMPOSE_BAG then
			EquipData.Instance:InputCsDecompose(data)
		elseif fromView == EquipTip.FROM_BAG_ON_BAG_STORAGE then
			local storage_id = -1
			if 1 < item_cfg.dup then	-- 可堆叠物品
				for k, v in pairs(BagData.Instance:GetStorageList()) do
					if (v.num + data.num) <= item_cfg.dup and v.item_id == data.item_id and v.is_bind == data.is_bind then
						storage_id = math.floor(k / BagData.STORAGE_PAGE_COUNT) + 1
						BagCtrl.Instance:SendMoveItemToBagFromStorage(storage_id, v.series)
						break
					end
				end
			end
			if -1 == storage_id then
				storage_id = BagData.Instance:GetOneEmptyStorage()
			end
			if storage_id >= 0 then
				BagCtrl:SendMoveItemToStorageFromBag(1, data.series)
			end
		elseif fromView == EquipTip.FROM_BAG_ON_RECYCLE then
		elseif fromView == EquipTip.FROM_CONSIGN_ON_SELL then
			ConsignCtrl.Instance:InputSellItem(data)
		elseif fromView == EquipTip.FROM_EXCHANGE_BAG then
			ExchangeCtrl.InputItemReq(data.series)
		elseif fromView == EquipTip.FROM_FASHION_CLOTHES then
			FashionCtrl.Instance:SetComposeItem(data)
		elseif fromView == EquipTip.FROM_FULING_TO_MAIN then
			EquipmentCtrl.Instance:MoveItemToFulingMainCell(data)
		elseif fromView == 	EquipTip.FROM_FULING_TO_MATE then
			EquipmentCtrl.Instance:MoveItemToFulingMateCell(data)
		elseif fromView == EquipTip.FROM_FULING_SHIFT_TO_MAIN then
			EquipmentCtrl.Instance:MoveItemToFulingShiftMain(data)
		elseif fromView == EquipTip.FROM_FULING_SHIFT_TO_MATE then
			EquipmentCtrl.Instance:MoveItemToFulingShiftMate(data)
		elseif fromView == EquipTip.FROM_WING_BAG then   		-- 神翼来自背包
			WingCtrl.Instance:MoveItemToWingFromBag(data)
		-- elseif fromView == EquipTip.FROM_BAG_ON_CARD_DESCOMPOSE then
		-- 	CardHandlebookCtrl.Instance:MoveItemToDecomposeFromBag(data)
		elseif fromView == EquipTip.FROM_SPECIAL_RING_BAG then   -- 来自时特戒背包
			SpecialRingData.Instance:SetInPutData(data)
			ViewManager.Instance:CloseViewByDef(ViewDef.SpecialRingBag)
		end
	elseif handle_type == EquipTip.HANDLE_EXCHANGE then						--兑换
		if fromView == EquipTip.FROM_STORAGE_ON_GUILD_STORAGE then
			GuildCtrl.MoveToBagFromGuildStorage(data.series)
		end
	elseif handle_type == EquipTip.HANDLE_DESTROY then						--摧毁
		if fromView == EquipTip.FROM_STORAGE_ON_GUILD_STORAGE
		or fromView == EquipTip.FROM_BAG then
			self.destroy_alert = self.destroy_alert or Alert.New()
			local content = string.format(Language.Guild.DestroyItemAlert, string.format("%06x", item_cfg.color), EquipTip.GetEquipName(item_cfg, data, fromView))
			self.destroy_alert:SetLableString(content)
			if fromView == EquipTip.FROM_STORAGE_ON_GUILD_STORAGE then
				self.destroy_alert:SetOkFunc(BindTool.Bind1(function ()
					GuildCtrl.SendOnKeyDestroyStorageEq({data})
				end, self))
			elseif fromView == EquipTip.FROM_BAG then
				self.destroy_alert:SetOkFunc(BindTool.Bind1(function ()
					BagCtrl.Instance:SendDeleteItem(data.series)
				end, self))
			end
			self.destroy_alert:SetCancelString(Language.Common.Cancel)
			self.destroy_alert:SetOkString(Language.Common.Confirm)
			self.destroy_alert:SetShowCheckBox(true)
			self.destroy_alert:Open()
		end
	elseif handle_type == EquipTip.HANDLE_TAKEOUT then						--取出
		if fromView == EquipTip.FROM_STORAGE_ON_BAG_STORAGE then
			BagCtrl.Instance:SendMoveItemToBagFromStorage(data.storage_id, data.series)
		end
		if fromView == EquipTip.FROM_XUNBAO_BAG then
			ExploreCtrl.Instance:SendMovetoBagReq(data.series)
		end

		if fromView == EquipTip.FROM_CS_CONSUM then
			EquipData.Instance:ClearCsComposeData()
		end

		if fromView == EquipTip.FROM_CS_DECOMPOSE_VIEW then
			EquipData.Instance:ClearCsDecomposeData()
		end

		if fromView == EquipTip.FROM_RECYCLE then
			BagData.Instance:CancelRecycleGridData(data)
		end
		-- if fromView == EquipTip.FROM_CARD_DESCOMPOSE then
		-- 	CardHandlebookCtrl.Instance:MoveItemToBagFromDecompose(data.series)
		-- end
		if fromView == EquipTip.FROM_FULING_TAKE_MAIN then
			EquipmentCtrl.Instance:RemoveFulingMainCellData()
		end
		if fromView == EquipTip.FROM_FULING_TAKE_MATE then
			EquipmentCtrl.Instance:RemoveFulingMateCellData()
		end
		if fromView == EquipTip.FROM_FULING_SHIFT_TAKE_MAIN then
			EquipmentCtrl.Instance:RemoveFulingShiftMainCell()
		end
		if fromView == EquipTip.FROM_FULING_SHIFT_TAKE_MATE then
			EquipmentCtrl.Instance:RemoveFulingShiftMateCell()
		end
		if fromView == EquipTip.FROM_HOLY_SYNTHESIS then
			GodFurnaceData.Instance:TakeOutHolySynthesis(data)
		end
		if fromView == EquipTip.FROM_WING_CL_SHOW then
			WingCtrl.Instance:MoveDataToWing()
		end
		if fromView == EquipTip.FROM_COLLECTION then
			local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
			HoroscopeCtrl.CancleCollectReq(item_cfg.stype, handle_param_t.grid_idx)
		end
	elseif handle_type == EquipTip.HANDLE_BUY then							--购买
		if fromView == EquipTip.FROM_CONSIGN_ON_BUY then
			ConsignCtrl.Instance:SendBuyConsignItem(data)
		end
	elseif handle_type == EquipTip.HANDLE_ZHURU then							--注入
		WingCtrl.SendAddWingHunshiReq(data.item_id)
	elseif handle_type == EquipTip.HANDLE_SHOW then							--展示
		local edit_text = ChatCtrl.Instance:GetEditTextByCurPanel()
		if ChatData.ExamineEditText(edit_text:getText(), 2) then
			edit_text:setText(edit_text:getText() .. "[" .. item_cfg.name .. "]")
			ChatData.Instance:InsertItemTab(data, handle_param_t.selcetec_index == 1)
		end
	elseif handle_type == EquipTip.HANDLE_QUICK_USE then
		-- BagCtrl.SentOnekeyUseItemReq(data.series)
	elseif handle_type == EquipTip.HANDLE_FIND_PATH then
		GuajiCtrl.Instance:MoveToPos(data.scene_id, data.scene_x, data.scene_y, 0, 0)
	elseif handle_type == EquipTip.HANDLE_DECOMPOSE then 				--分解
		if ItemData.GetIsCard(data.item_id) then
			ViewManager.Instance:OpenViewByDef(ViewDef.CardHandlebook.Descompose)
		elseif ItemData.GetIsZhanwenType(item_cfg.type) then
			ViewManager.Instance:OpenViewByDef(ViewDef.BattleFuwen.DecomposeZhanwen)
		elseif ItemData.ItHandedDownProp[data.item_id] then
			ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip.Decompose)
		end
	elseif handle_type == EquipTip.HANDLE_HUANHUA then 

		if ItemData.GetIsFashion(data.item_id) or ItemData.GetIsHuanWu(data.item_id) then

			FashionCtrl.Instance:SendHuanhuaEquipReq(data.series)
		else
	 		--幻化FashionCtrl:SendSHouhuiEquipReq(series)
			local index = WingData.Instance:IsWingEquip(data.item_id) - 1

			WingCtrl.SendEquipDie(index)
		end
	elseif handle_type == EquipTip.HANDLE_NOT_HUANHUA then   	-- 取消幻化
		if ItemData.GetIsFashion(data.item_id) or ItemData.GetIsHuanWu(data.item_id) then
			FashionCtrl.Instance:SendCancelHuanHuaEquipReq(data.series)
		else
			WingCtrl.SendCancelDie()
		end
	elseif handle_type == EquipTip.HANDLE_COLLECT then  		--收藏
		if ItemData.GetIsConstellation(data.item_id) then
			if fromView == EquipTip.FROM_COLLECTION_BAG then
				HoroscopeCtrl.CollectReq(data.series, handle_param_t.type, handle_param_t.grid_idx)
			else
				ViewManager.Instance:OpenViewByDef(ViewDef.Horoscope.Collection)
			end
		end
	elseif handle_type == EquipTip.HANDLE_UPGRADE then  		--收藏
		if fromView == EquipTip.FROM_GUN_OR_CAR then
			ViewManager.Instance:OpenViewByDef(ViewDef.CrossBoss.LuxuryEquipCompose)
			-- ViewManager.Instance:FlushViewByDef(ViewDef.LuxuryEquipUpgrade, 0, "param", handle_param_t)
		elseif fromView == EquipTip.FROM_ROlE_NEWREXUE_EQUIP then
			if ItemData.IsReXueEquip(data.item_id) then
				ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquip)
				ViewManager.Instance:FlushViewByDef(ViewDef.MainGodEquipView.RexueGodEquip, 0, "second_tabbbar_change", {child_index = 1})	
			elseif ItemData.IsZhanShenEquip(data.item_id) then
				ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquip)
				ViewManager.Instance:FlushViewByDef(ViewDef.MainGodEquipView.RexueGodEquip, 0, "second_tabbbar_change", {child_index = 3})	
			elseif ItemData.IsShaShenEquip(data.item_id) then
				ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquip)
				ViewManager.Instance:FlushViewByDef(ViewDef.MainGodEquipView.RexueGodEquip, 0, "second_tabbbar_change", {child_index = 4})	
			end
		end
	elseif handle_type == EquipTip.HANDLE_HUISHOU then
		 
		 if data.zhuan_level == 1 then --如果已幻化的需要取回背包，取消幻化
		 	FashionCtrl.Instance:SendCancelHuanHuaEquipReq(data.series)
		 end
		 FashionCtrl.Instance:SendSHouhuiEquipReq(data.series)
			
	elseif handle_type == EquipTip.HANDLE_GANGWEN then
		ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip.Blood)
	elseif handle_type == EquipTip.HANDLE_GET then
		ViewManager.Instance:OpenViewByDef(ViewDef.OutOfPrint)
		local id2idx = {[311] = 1, [312] = 2, [313] = 3}
		ViewManager.Instance:FlushViewByDef(ViewDef.OutOfPrint, 0, "gear", {gear = id2idx[item_cfg.item_id]})
	elseif handle_type == EquipTip.HANDLE_UPGRADE2 then
		if fromView == EquipTip.FROME_EQUIP_STONE then
			local stone_lv, stone_slot = StoneData.Instance:GetStoneLevelAndSlot(item_cfg.item_id)
			local select_equip_slot = StoneData.Instance:GetSelectEquipSlot()
			if select_equip_slot then
				StoneCtrl.SendStoneUpgradeReq(select_equip_slot, stone_slot)
			end
		end
	elseif handle_type == EquipTip.HANDLE_ADD then
		ViewManager.Instance:OpenViewByDef(ViewDef.MeiBaShouTao.HandAdd)
	end
end

function TipCtrl:OpenBuffTip(data)
	self.buff_tip:Open()
	self.buff_tip:Flush(0, nil, data)
end

function TipCtrl:CloseBuffTip()
	self.buff_tip:Close()
end

function TipCtrl.HasVipPower(vip, is_pop, param_t)
	local role_vip = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	if role_vip < vip then
		if is_pop then
			ViewManager.Instance:OpenViewByDef(ViewDef.VIPLimit)
  			ViewManager.Instance:FlushViewByDef(ViewDef.VIPLimit, 0, "param", param_t)
  		end
  		return false
  	end
  	return true
end

function TipCtrl:OpenStuffTip(title, data)
	self.stuff_tip:Open()
	self.stuff_tip:SetTitleText(title)
	self.stuff_tip:Flush(0, "all", data)
end

-- 打开通用快速购买界面 param_t = {item_id, MoneyType}
function TipCtrl:OpenQuickBuyItem(param_t)
	ViewManager.Instance:OpenViewByDef(ViewDef.QuickBuy)
	ViewManager.Instance:FlushViewByDef(ViewDef.QuickBuy, 0, "param", param_t)
end

-- 打开寻宝通用快速购买界面 param_t = {item_id, MoneyType}
function TipCtrl:OpenQuickTipItem(is_tip, param_t)
	-- ExploreData.Instance:GetIsVisTip()
	if is_tip then
		local item = ShopData.GetItemPriceCfg(param_t[1], param_t[2])
		local need_auto_use = not ItemData.Instance:GetItemConfig(param_t[1]).openUi
		ShopCtrl.BuyItemFromStore(item.id, param_t[3], param_t[1], 1)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.QuickTip)
		ViewManager.Instance:FlushViewByDef(ViewDef.QuickTip, 0, "param", param_t)
	end
end

-- 打开通用获取材料界面
function TipCtrl:OpenGetStuffTip(item_id)
	if nil == item_id then
		return
	end
	local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
	local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
	self:OpenBuyTip(data)
end

function TipCtrl:OpenBuyTip(data)
	ViewManager.Instance:OpenViewByDef(ViewDef.BuyTip)
	ViewManager.Instance:FlushViewByDef(ViewDef.BuyTip, 0, "param", {data})
end

-- 打开通用获取材料界面(新带购买的)
function TipCtrl:OpenGetNewStuffTip(item_id, num)
	if nil == item_id then
		return
	end
	local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
	local data = string.format("{reward;0;%d;%d}", item_id, num or 1) .. (ways and ways or "")
	self:OpenNewBuyTip(data)
end

function TipCtrl:OpenNewBuyTip(data)
	ViewManager.Instance:OpenViewByDef(ViewDef.NewBuyTip)
	ViewManager.Instance:FlushViewByDef(ViewDef.NewBuyTip, 0, "param", {data})
end


function TipCtrl:OpenMeltSoulTip(data)
	self.melt_soul_tip:Open()
	self.melt_soul_tip:SetData(data)
	self.melt_soul_tip:Flush(0)
end

function TipCtrl:IsFuBenTipOpen()
	return self.fuben_tip:IsOpen()
end

function TipCtrl:OpenInnerTip(slot)
	self.inner_tip:Open()
	self.inner_tip:SetData(slot)
	self.inner_tip:Flush(0)
end


function TipCtrl:OpenTipSkill(skill_id, skill_level, suittype, suitlevel)
	ViewManager.Instance:OpenViewByDef(ViewDef.SkillSpecialTip)
	ViewManager.Instance:FlushViewByDef(ViewDef.SkillSpecialTip, 0, "param1",{skill_id = skill_id, skill_level = skill_level, suit_type =suittype,suit_level = suitlevel})
end

function TipCtrl:OpenAwardShowTip(text, item_list)
	self.award_show_tip:SetData(text, item_list)
	ViewManager.Instance:OpenViewByDef(ViewDef.AwardShowTip)
	ViewManager.Instance:FlushViewByDef(ViewDef.AwardShowTip)
end