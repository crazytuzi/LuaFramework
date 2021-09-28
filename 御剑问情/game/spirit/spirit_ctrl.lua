require("game/spirit/spirit_data")
require("game/spirit/spirit_new_sys_data")
require("game/spirit/spirit_new_attr_view")
require("game/spirit/spirit_new_aptitude_view")
require("game/spirit/spirit_view")
require("game/spirit/son_spirit_view")
require("game/spirit/spirit_exchange_view")
require("game/spirit/spirit_hunt_view")
require("game/spirit/spirit_warehouse_view")
require("game/spirit/spirit_huanhua_view")
require("game/spirit/spirit_soul_view")
require("game/spirit/spirit_soul_item")
require("game/spirit/spirit_fazhen_view")
require("game/spirit/spirit_get_skill_view")
require("game/spirit/spirit_halo_view")
require("game/spirit/spirit_zhenfa_view")
require("game/spirit/spirit_image_view")
require("game/spirit/tips_spirit_zhenfa_value_view")
require("game/spirit/tips_spirit_zhenfa_promote_view")
require("game/spirit/spirit_fazhen_huanhua_view")
require("game/spirit/spirit_halo_huanhua_view")
require("game/spirit/spirit_handbook_view")
require("game/spirit/son_skill_view")
require("game/spirit/spirit_home_view")
require("game/spirit/spirit_exp_fight_view")
require("game/spirit/spirit_exp_reward_view")
require("game/spirit/spirit_explore_view")
require("game/spirit/spirit_choose_model_view")
require("game/spirit/flush_spirit_skill_little_view")
require("game/spirit/flush_spirit_skill_big_view")
require("game/spirit/spirit_skill_info")
require("game/spirit/spirit_skill_copy")
require("game/spirit/spirit_skill_book_view")
require("game/spirit/spirit_home_fight_view")
require("game/spirit/spirit_harvert_victory_view")
require("game/spirit/spirit_harvert_lose_view")
require("game/spirit/spirit_home_revenge_view")
require("game/spirit/spirit_lingpo_view")
require("game/spirit/spirit_explore_victory_view")
require("game/spirit/spirit_explore_lose_view")
require("game/spirit/spirit_meet_view")
require("game/spirit/spirit_item_get_way_view")
require("game/spirit/spirit_soul_find_rush_view")
require("game/spirit/spirit_special_tip_view")

SpiritCtrl = SpiritCtrl or BaseClass(BaseController)

function SpiritCtrl:__init()
	if SpiritCtrl.Instance ~= nil then
		print_error("[SpiritCtrl] Attemp to create a singleton twice !")
		return
	end
	SpiritCtrl.Instance = self

	self.spirit_view = SpiritView.New(ViewName.SpiritView)
	self.spirit_data = SpiritData.New()
	self.spirit_get_skill_view = SpiritGetSkillView.New(ViewName.SpiritGetSkillView)
	self.flush_spirit_skill_little_view = FlushSpiriLittleSkillView.New()
	self.flush_spirit_skill_big_view = FlushSpiriBigSkillView.New()
	self.spirit_skill_info = SpiritSkillInfo.New()
	self.spirit_skill_copy = SpiritSkillCopy.New()
	self.spirit_skill_book_view = SpiritSkillBookView.New()
	self.spirit_exchange = SpiritExchangeView.New()
	self.spirit_warehouse_view = SpiritWarehouseView.New()

	self.spirit_huanhua_view = SpiritHuanHuaView.New(ViewName.SpiritHuanHuaView)
	-- self.fazhen_huanhua_view = SpiritFazhenHuanHuaView.New(ViewName.SpiritFazhenHuanHuaView)
	-- self.halo_huanhua_view = SpiritHaloHuanHuaView.New(ViewName.SpiritHaloHuanHuaView)
	-- self.spirit_image_view = SpiritImageView.New()
	self.spirit_handbook_view = SpiritHandbook.New(ViewName.SoulHandBook)
	self.spirit_home_revenge_view = SpiritHomeRevengeView.New(ViewName.SpiritHomeRevengeView)

	self.explore_view = SpiritExploreView.New(ViewName.SpiritExploreView)
	self.explore_reward_view = SpiritExpRewardView.New(ViewName.SpiritExpRewardView)
	self.explore_fight_view = SpiritExpFightView.New(ViewName.SpiritExpFightView)
	self.explore_choose_model_view = SpiritChooseModelView.New(ViewName.SpiritChooseModelView)
	self.explore_victory_view = SpiritExploreVictoryView.New(ViewName.SpiritExploreVictory)
	self.explore_lose_view = SpiritExploreLoseView.New(ViewName.SpiritExploreLose)

	self.enter_scene_load = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.EnterSceneLoad, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
	self.spirit_zhenfa_value_view = TipsSpiritZhenFaValueView.New(ViewName.TipsSpiritZhenFaValueView)
	self.spirit_zhenfa_promote_view = TipsSpiritZhenFaPromoteView.New(ViewName.TipsSpiritZhenFaPromoteView)

	self.spirit_home_fight_view = SpiritHomeFightView.New(ViewName.SpiritHomeFightView)
	self.spirit_harvert_victory = SpiritHarvertVictoryView.New()
	self.spirit_harvert_lose = SpiritHarvertLoseView.New()
	self.spirit_item_get_way = SpiritGetWayView.New()
	self.spirit_new_sys_data = SpiritNewSysData.New()
	self.soul_quick_flush_view = SoulQuickFlushView.New(ViewName.SoulQuickFlushView)
	self.spirit_special_tip_view = SpiritSpecialView.New(ViewName.SpiritSpecialView)

	self:RegisterAllProtocols()
	-- self.spirit_meet_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SpiritMeetTimeQuest, self), 60 * 10)  --10分钟提醒一次
end

function SpiritCtrl:__delete()
	if self.enter_scene_load then
		GlobalEventSystem:UnBind(self.enter_scene_load)
		self.enter_scene_load = nil
	end
	if self.main_view_complete then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.spirit_view then
		self.spirit_view:DeleteMe()
		self.spirit_view = nil
	end

	if self.spirit_skill_info then
		self.spirit_skill_info:DeleteMe()
		self.spirit_skill_info = nil
	end

	if self.flush_spirit_skill_little_view then
		self.flush_spirit_skill_little_view:DeleteMe()
		self.flush_spirit_skill_little_view = nil
	end

	if self.flush_spirit_skill_big_view then
		self.flush_spirit_skill_big_view:DeleteMe()
		self.flush_spirit_skill_big_view = nil
	end

	if self.spirit_skill_copy then
		self.spirit_skill_copy:DeleteMe()
		self.spirit_skill_copy = nil
	end

	if self.spirit_skill_book_view then
		self.spirit_skill_book_view:DeleteMe()
		self.spirit_skill_book_view = nil
	end

	if self.spirit_exchange then
		self.spirit_exchange:DeleteMe()
		self.spirit_exchange = nil
	end

	if self.spirit_data then
		self.spirit_data:DeleteMe()
		self.spirit_data = nil
	end

	if self.spirit_get_skill_view then
		self.spirit_get_skill_view:DeleteMe()
		self.spirit_get_skill_view = nil
	end

	if self.spirit_huanhua_view then
		self.spirit_huanhua_view:DeleteMe()
		self.spirit_huanhua_view = nil
	end

	if self.spirit_zhenfa_value_view then
		self.spirit_zhenfa_value_view:DeleteMe()
		self.spirit_zhenfa_value_view = nil
	end

	if self.spirit_zhenfa_promote_view then
		self.spirit_zhenfa_promote_view:DeleteMe()
		self.spirit_zhenfa_promote_view = nil
	end

	if self.spirit_image_view then
		self.spirit_image_view:DeleteMe()
		self.spirit_image_view = nil
	end

	if self.fazhen_huanhua_view then
		self.fazhen_huanhua_view:DeleteMe()
		self.fazhen_huanhua_view = nil
	end

	if self.halo_huanhua_view then
		self.halo_huanhua_view:DeleteMe()
		self.halo_huanhua_view = nil
	end

	if nil ~= self.spirit_handbook_view then
		self.spirit_handbook_view:DeleteMe()
		self.spirit_handbook_view = nil
	end

	if self.explore_view then
		self.explore_view:DeleteMe()
		self.explore_view = nil
	end

	if self.explore_reward_view then
		self.explore_reward_view:DeleteMe()
		self.explore_reward_view = nil
	end

	if self.explore_fight_view then
		self.explore_fight_view:DeleteMe()
		self.explore_fight_view = nil
	end

	if self.explore_choose_model_view ~= nil then
		self.explore_choose_model_view:DeleteMe()
		self.explore_choose_model_view = nil
	end

	if self.spirit_home_fight_view ~= nil then
		self.spirit_home_fight_view:DeleteMe()
		self.spirit_home_fight_view = nil
	end

	if self.spirit_harvert_victory ~= nil then
		self.spirit_harvert_victory:DeleteMe()
		self.spirit_harvert_victory = nil
	end

	if self.spirit_harvert_lose ~= nil then
		self.spirit_harvert_lose:DeleteMe()
		self.spirit_harvert_lose = nil
	end

	if self.spirit_home_revenge_view ~= nil then
		self.spirit_home_revenge_view:DeleteMe()
		self.spirit_home_revenge_view = nil
	end

	if self.explore_victory_view ~= nil then
		self.explore_victory_view:DeleteMe()
		self.explore_victory_view = nil
	end

	if self.explore_lose_view ~= nil then
		self.explore_lose_view:DeleteMe()
		self.explore_lose_view = nil
	end

	if self.spirit_warehouse_view then
		self.spirit_warehouse_view:DeleteMe()
		self.spirit_warehouse_view = nil
	end

	if self.spirit_item_get_way then
		self.spirit_item_get_way:DeleteMe()
		self.spirit_item_get_way = nil
	end

	if self.spirit_meet_time_quest then
		GlobalTimerQuest:CancelQuest(self.spirit_meet_time_quest)
		self.spirit_meet_time_quest = nil
	end

	if self.soul_quick_flush_view then
		self.soul_quick_flush_view:DeleteMe()
		self.soul_quick_flush_view = nil
	end

	if self.spirit_special_tip_view then
		self.spirit_special_tip_view:DeleteMe()
		self.spirit_special_tip_view = nil
	end

	self:CacleDelayTime()
	self:CacleSendDelayTime()

	SpiritCtrl.Instance = nil
end

function SpiritCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCJingLingInfo, "GetJingLingInfoReq")
	-- self:RegisterProtocol(SCSelfChestShopItemList, "GetSpiritWarehouseItemList")
	self:RegisterProtocol(SCJingLingViewChange, "GetJingLingViewChangeReq")
	self:RegisterProtocol(SCLieMingSlotInfo, "GetSpiritSlotSoulInfoReq")
	self:RegisterProtocol(SCLieMingBagInfo, "GetSpiritSoulBagInfoReq")
	self:RegisterProtocol(SCJinglingFazhenInfo, "GetSpiritFazhenInfoReq")
	self:RegisterProtocol(SCJinglingGuanghuanInfo, "GetSpiritHaloInfoReq")

	--精灵家园
	self:RegisterProtocol(CSJingLingHomeOperReq)
	self:RegisterProtocol(SCJingLingHomeInfo, "OnSCJingLingHomeInfo")
	self:RegisterProtocol(SCJingLingHomeListInfo, "OnSCJingLingHomeListInfo")
	self:RegisterProtocol(SCJingLingHomeRobRecord, "OnSCJingLingHomeRobRecord")
	self:RegisterProtocol(SCJingLingHomeRobAck, "OnSCJingLingHomeRobAck")

	--精灵探险
	self:RegisterProtocol(CSJinglIngExploreOperReq)
	self:RegisterProtocol(SCJinglIngExploreInfo, "OnSCJinglIngExploreInfo")

	--精灵奇遇
	self:RegisterProtocol(SCJingLingAdvantageInfo, "OnSCJingLingAdvantageInfo")
	self:RegisterProtocol(SCJingLingAdvantageCount, "OnSCJingLingAdvantageCount")

	--特殊宠物
	self:RegisterProtocol(SCSpecialJingLingInfo,"OnSCSpecialJingLingInfo")
end

function SpiritCtrl:EnterSceneLoad()
	self:SendGetSpiritWarehouseItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
end

function SpiritCtrl:MianUIOpenComlete()
end

function SpiritCtrl:GetJingLingInfoReq(protocol)
	--灵魄进度条动画客户端自行判断播放
	--必须在存data前播放这假动画
	local flush_lingpo_slider = self.spirit_data:CheckPlayLingPoSliderAnim(protocol.jinglingcard_list)
	if flush_lingpo_slider then
		self.spirit_view:Flush("ling_po_slider")
		self.spirit_data:SetCurAdvanceLingPoType(-1)
	end

	self.spirit_data:SetSpiritInfo(protocol)
	self.spirit_view:Flush("spirit")
	self.spirit_huanhua_view:Flush()
	self.spirit_zhenfa_promote_view:Flush()
	self.flush_spirit_skill_little_view:Flush()
	self.flush_spirit_skill_big_view:Flush()
	self.spirit_skill_copy:Flush()
	self.spirit_skill_info:Flush()
	self.spirit_get_skill_view:Flush()
	self.spirit_view:Flush("ling_po")
	self.spirit_special_tip_view:Flush()

	RemindManager.Instance:Fire(RemindName.SpiritBag)
	RemindManager.Instance:Fire(RemindName.SpiritUpgrade)
	RemindManager.Instance:Fire(RemindName.SpiritUpgradeWuxing)
	RemindManager.Instance:Fire(RemindName.SpiritHomeBreed)
	-- RemindManager.Instance:Fire(RemindName.SpiritPlunder)
	RemindManager.Instance:Fire(RemindName.SpiritExplore)
	RemindManager.Instance:Fire(RemindName.SpiritSkillLearn)
	RemindManager.Instance:Fire(RemindName.SpiritShangZhen)
	RemindManager.Instance:Fire(RemindName.SpiritZhenFaUplevel)
	RemindManager.Instance:Fire(RemindName.SpiritZhenFaHunyu)

	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		main_role:SetAttr("used_sprite_id", protocol.use_jingling_id)
		main_role:SetAttr("sprite_name", protocol.jingling_name)
	end
end

function SpiritCtrl:GetJingLingViewChangeReq(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		obj:SetAttr("used_sprite_id", protocol.jingling_id)
		obj:SetAttr("sprite_name", protocol.jingling_name)
		obj:SetAttr("user_pet_special_img", protocol.user_pet_special_img)
	end
	self.spirit_data:SetCurSpiritId(protocol)
	self.spirit_huanhua_view:Flush()
end

function SpiritCtrl:SendJingLingInfoReq(oper_type, param1, param2, param3, param4, jingling_name)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJingLingOper)
	send_protocol.oper_type = oper_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol.jingling_name = jingling_name or ""

	send_protocol:EncodeAndSend()
end

function SpiritCtrl:SendExchangeJingLingReq(scoretoitem_type, index, num)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSScoreToItemConvert)
	send_protocol.scoretoitem_type = scoretoitem_type
	send_protocol.index = index or 0
	send_protocol.num = num or 0
	send_protocol:EncodeAndSend()
end

function SpiritCtrl:SendTakeOutJingLingReq(grid_index, if_fetch_all, shop_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFetchChestShopItem)
	send_protocol.grid_index = grid_index
	send_protocol.if_fetch_all = if_fetch_all or 0
	send_protocol.shop_type = shop_type or 0
	send_protocol:EncodeAndSend()
end

-- 命魂自动穿戴，跟换
function SpiritCtrl:SendLieMingExchangeList(exchange_count, source_index_list, dest_index_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLieMingExchangeList)
	send_protocol.exchange_count = exchange_count
	send_protocol.exchange_source_index_list = source_index_list or {}
	send_protocol.exchange_dest_index_list = dest_index_list or {}
	send_protocol:EncodeAndSend()
end

-- 发送请求寻宝免费
function SpiritCtrl:SendHuntSpiritGetFreeInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChestShopGetFreeInfo)
	send_protocol:EncodeAndSend()
end

-- 发送寻宝请求
function SpiritCtrl:SendHuntSpiritReq(mode, shop_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyChestShopItem)
	protocol.mode = mode or 0
	protocol.shop_type = shop_type or 0
	protocol:EncodeAndSend()
end

-- 发送请求精灵仓库信息
function SpiritCtrl:SendGetSpiritWarehouseItemListReq(shop_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSelfChestShopItemList)
	protocol.shop_type = shop_type
	protocol:EncodeAndSend()
end

-- 发送获取精灵积分请求
function SpiritCtrl:SendGetSpiritScore()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetSocreInfoReq)
	send_protocol:EncodeAndSend()
end

-- 发送回收精灵请求
function SpiritCtrl:SendRecoverySpirit(shop_type, max_color, is_auto, grid_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChestShopAutoRecycle)
	send_protocol.shop_type = shop_type or 0
	send_protocol.max_color = max_color or 0
	send_protocol.is_auto = is_auto or 1
	send_protocol.grid_index = grid_index or 0
	send_protocol:EncodeAndSend()
end

-- 精灵命魂操作
function SpiritCtrl:SendSpiritSoulOperaReq(opera_type, param_1, param_2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLieMingHunshouOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol:EncodeAndSend()
end

-- 精灵命魂槽信息
function SpiritCtrl:GetSpiritSlotSoulInfoReq(protocol)
	self.spirit_data:SetSpiritSlotSoulInfo(protocol)
	self.spirit_view:Flush()
	RemindManager.Instance:Fire(RemindName.SpiritSoul)
end

-- 精灵命魂背包信息
function SpiritCtrl:GetSpiritSoulBagInfoReq(protocol)
	if self.spirit_data:GetSpiritSoulBagInfo().hunshou_exp then
		local delta_hunshou_exp = protocol.hunshou_exp - self.spirit_data:GetSpiritSoulBagInfo().hunshou_exp
		if delta_hunshou_exp > 0 then
			TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddSoulExp, delta_hunshou_exp))
		end
	end
	self.spirit_data:SetSpiritSoulBagInfo(protocol)
	self.spirit_view:Flush()
	RemindManager.Instance:Fire(RemindName.SpiritSoul)
end

-- 精灵法阵信息
function SpiritCtrl:GetSpiritFazhenInfoReq(protocol)
	self.spirit_data:SetSpiritFazhenInfo(protocol)
	self.spirit_view:Flush()
	self:FlushSpiritImageView()
	-- self.fazhen_huanhua_view:Flush()
	RemindManager.Instance:Fire(RemindName.Spirit)
end

-- 精灵法阵升星请求
function SpiritCtrl:SendSpiritFazhenUpStar(is_auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingFazhenUpStarLevel)
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol:EncodeAndSend()
end

-- 精灵法阵使用形象请求
function SpiritCtrl:SendSpiritFazhenUseImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseJinglingFazhenImage)
	send_protocol.image_id = image_id or 0
	send_protocol:EncodeAndSend()
end

-- 精灵法阵特殊形象进阶
function SpiritCtrl:SendSpiritFazhenSpecialImgUpgrade(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingFazhenSpecialImgUpgrade)
	send_protocol.special_image_id = image_id or 0
	send_protocol:EncodeAndSend()
end

-- 精灵法阵信息请求
function SpiritCtrl:SendGetSpiritFazhenInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingFazhenGetInfo)
	send_protocol:EncodeAndSend()
end

-- 法阵进阶结果返回
function SpiritCtrl:OnFazhenUppGradeOptResult(result)
	self.spirit_view:SetFazhenUppGradeOptResult(result)
end

-- 精灵光环信息
function SpiritCtrl:GetSpiritHaloInfoReq(protocol)
	self.spirit_data:SetSpiritHaloInfo(protocol)
	self.spirit_view:Flush()
	self:FlushSpiritImageView()
	-- self.halo_huanhua_view:Flush()
	RemindManager.Instance:Fire(RemindName.Spirit)
end

-- 精灵光环升星请求
function SpiritCtrl:SendSpiritHaloUpStar(is_auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingGuanghuanUpStarLevel)
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol:EncodeAndSend()
end

-- 精灵光环使用形象请求
function SpiritCtrl:SendSpiritHaloUseImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseJinglingGuanghuanImage)
	send_protocol.image_id = image_id or 0
	send_protocol:EncodeAndSend()
end

-- 精灵光环特殊形象进阶
function SpiritCtrl:SendSpiritHaloSpecialImgUpgrade(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingGuanghuanSpecialImgUpgrade)
	send_protocol.special_image_id = image_id or 0
	send_protocol:EncodeAndSend()
end

-- 精灵光环信息请求
function SpiritCtrl:SendGetSpiritHaloInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingGuanghuanGetInfo)
	send_protocol:EncodeAndSend()
end

-- 光环进阶结果返回
function SpiritCtrl:OnHaloUpGradeOptResult(result)
	self.spirit_view:SetHaloUpGradeOptResult(result)
end

function SpiritCtrl:FlushSpiritView()
	self.spirit_view:Flush()
end

-- 一键装备精灵
function SpiritCtrl:AutoEquipOrChange()
	local list = self.spirit_data:GetBagBestSpirit()
	local spirit_info = self.spirit_data:GetSpiritInfo()
	local temp_list = {}
	if nil == next(list) then return end
	if nil == spirit_info.jingling_list then return end
	for k, v in pairs(list) do
		local can_insert = true
		for _, m in pairs(spirit_info.jingling_list) do
			if v.item_id == m.item_id then
				can_insert = false
			end
		end
		for _, j in pairs(temp_list) do
			if j.item_id == v.item_id then
				can_insert = false
			end
		end
		local cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if cfg and nil == cfg.sub_type then
			can_insert = false
		end
		if can_insert then
			table.insert(temp_list, v)
		end
	end

	if nil == next(spirit_info.jingling_list) then
		for i = 1, 4 do
			if temp_list[i] then
				local item_cfg = ItemData.Instance:GetItemConfig(temp_list[i].item_id)
				if item_cfg.sub_type then
					PackageCtrl.Instance:SendUseItem(temp_list[i].index, temp_list[i].num, i, 0)
				-- else
				-- 	TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.BagNoJingLing)
				end
			end
		end
		return
	else
		for i = 1, (4 - spirit_info.count) do
			if temp_list[i] then
				local item_cfg = ItemData.Instance:GetItemConfig(temp_list[i].item_id)
				if item_cfg.sub_type then
					PackageCtrl.Instance:SendUseItem(temp_list[i].index, temp_list[i].num, i, 0)
				end
			end
		end
	end
end

-- 一键回收背包精灵
function SpiritCtrl:OneKeyRecoverSpirit(color)
	color = color or GameEnum.ITEM_COLOR_PURPLE
	self:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_ONEKEY_RECYCL_BAG, color)
end

function SpiritCtrl:ShowSpiritImageListView(from_view, callback)
	-- self.spirit_image_view:SetFromView(from_view)
	-- self.spirit_image_view:SetCallBack(callback)
	-- self.spirit_image_view:Open()
end

function SpiritCtrl:FlushSpiritImageView()
	-- self.spirit_image_view:Flush()
end

function SpiritCtrl:OpenFlsuhSkillLittleView()
	self.flush_spirit_skill_little_view:Open()
end

function SpiritCtrl:OpenFlsuhSkillBigView()
	self.flush_spirit_skill_big_view:Open()
end

function SpiritCtrl:CloseFlsuhSkillBigView()
	self.flush_spirit_skill_big_view:Close()
end

function SpiritCtrl:OpenSkillInfoView(from_view)
	self.spirit_skill_info:SetFromView(from_view)
	self.spirit_skill_info:Open()
end

function SpiritCtrl:CloseSkillInfoView()
	self.spirit_skill_info:Close()
end

function SpiritCtrl:OpenSkillCopyView()
	self.spirit_skill_copy:Open()
end

function SpiritCtrl:OpenSkillBookView()
	self.spirit_skill_book_view:Open()
end

function SpiritCtrl:OpenExchangeview()
	self.spirit_exchange:Open()
end

function SpiritCtrl:OpenWarehouseView()
	self.spirit_warehouse_view:Open()
end

function SpiritCtrl:OpenSpiritGetWayTip(get_item_id)
	self.spirit_item_get_way:SetData(get_item_id)
	self.spirit_item_get_way:Open()
end

function SpiritCtrl:FlushSpiritTopButton(enable)
	self.spirit_view:FlushSpiritTopButton(enable)
end


--精灵家园----------------------------------------------
function SpiritCtrl:SendJingLingHomeOperReq(oper_type, role_id, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJingLingHomeOperReq)
	send_protocol.oper_type = oper_type
	send_protocol.role_id = role_id
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol:EncodeAndSend()
end

function SpiritCtrl:OnSCJingLingHomeInfo(protocol)
	self.spirit_data:SetSpiritHomeInfo(protocol)
	if self.spirit_view ~= nil and self.spirit_view:IsOpen() then
		if not self.spirit_data:GetIsMyHome() then
			self.spirit_view:Flush("enter_other_home")
			TipsCtrl.Instance:FlushSpiritHomeHarvestView()
			TipsCtrl.Instance:FlushPreview()
		else
			if JING_LING_HOME_REASON.JING_LING_HOME_REASON_QUICK == protocol.reason then
				--if TipsCtrl.Instance:GetTreasureViewIsOpen() then
					--TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RANK_JINYIN_QUICK_REWARD)
				--else
					--self.spirit_view:Flush("add_reward")
					TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RANK_JINYIN_QUICK_REWARD)
					self.spirit_view:Flush()
				--end
			else
				self.spirit_view:Flush()
				TipsCtrl.Instance:FlushSpiritHomeHarvestView()
				TipsCtrl:FlushSpiritHomeSendTimer()
				TipsCtrl.Instance:FlushPreview()
			end

			--TipsCtrl.Instance:FlushSpiritHomeHarvestView()
		end
	end

	RemindManager.Instance:Fire(RemindName.SpiritHomeBreed)
	RemindManager.Instance:Fire(RemindName.SpiritHomeReward)
end

function SpiritCtrl:FlushCapChangeList()
	if self.spirit_view ~= nil then
		if self.spirit_view ~= nil and self.spirit_view:IsOpen() then
			self.spirit_view:Flush("flush_cap")
		end
	end
end

function SpiritCtrl:OnSCJingLingHomeListInfo(protocol)
	self.spirit_data:SetSpiritHomeListInfo(protocol)
	if self.spirit_view ~= nil and self.spirit_view:IsOpen() then
		self.spirit_view:Flush("flush_plunder")
	end
end

function SpiritCtrl:OnSCJingLingHomeRobRecord(protocol)
	self.spirit_data:SetSpiritHomeRecordInfo(protocol)

	if self.spirit_home_revenge_view:IsOpen() then
		self.spirit_home_revenge_view:Flush()
	end

	-- RemindManager.Instance:Fire(RemindName.SpiritHomeRevnge)
end

function SpiritCtrl:OnSCJingLingHomeRobAck(protocol)
	self.spirit_data:SetSpiritHomeRobData(protocol)
	self.spirit_data:SetFightResult(protocol.is_win)
	self:OpenSpiritHomeFightView(SPIRIT_FIGHT_TYPE.HOME)
end

function SpiritCtrl:CloseSpiritHomeRevengeView()
	self.spirit_home_revenge_view:Close()
end

function SpiritCtrl:OpenSpiritHomeRevengeView()
	self:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_READ_ROB_RECORD, 0)
	self.spirit_home_revenge_view:Open()
end

function SpiritCtrl:ChangeSpiritHomeFightChoose()
	if self.spirit_view ~= nil and self.spirit_view:IsOpen() then
		self.spirit_view:Flush("change_fight_choose")
	end
end

function SpiritCtrl:OpenSpiritHomeFightView(fight_type)
	local my_item = 0
	local enemy_item = 0
	if fight_type == nil then
		return
	end

 	local my_cfg = self.spirit_data:GetEnterOtherSpirit()
 	if my_cfg ~= nil and my_cfg.item_id > 0 then
 		my_item = my_cfg.item_id
 	end

 	if SPIRIT_FIGHT_TYPE.HOME == fight_type then
	 	local enemy_index = self.spirit_data:GetHarvertSpirit()
	 	if enemy_index == nil then
	 		return
	 	end
	 	local enemy_cfg = self.spirit_data:GetSpiritHomeInfoByIndex(enemy_index)
	 	if enemy_cfg ~= nil then
	 		enemy_item = enemy_cfg.item_id
	 	end
	elseif SPIRIT_FIGHT_TYPE.EXPLORE == fight_type then
		local last_data = self.spirit_data:GetExpFightCfg()
		if last_data == nil or last_data.explore_info_list == nil then
			local cur_stage = self.spirit_data:GetCurChallenge()
	 		local cur_data = self.spirit_data:GetStageInfoByIndex(cur_stage)
	 		if cur_data ~= nil and cur_data.jingling_id then
	 			enemy_item = cur_data.jingling_id
	 		end
		else
			for i = 1, 6 do
				if last_data.explore_info_list[i].hp > 0 then
					enemy_item = last_data.explore_info_list[i].jingling_id
					break
				end
			end
		end

		local my_data = SpiritData.Instance:GetMySpiritInOther()
		if my_data ~= nil and my_data.item_id > 0 then
			my_item = my_data.item_id
		end
 	end

 	if my_item > 0 and enemy_item > 0 then
 		self.spirit_home_fight_view:SetData(my_item, enemy_item, fight_type)
 	end
end

function SpiritCtrl:CloseHomeFightView()
	if self.spirit_home_fight_view:IsOpen() then
		self.spirit_home_fight_view:Close()
	end
end

function SpiritCtrl:OpenHarvertVictory()
	self.spirit_harvert_victory:SetData()
end

function SpiritCtrl:OpenHarvertLose()
	self.spirit_harvert_lose:SetData()
end

function SpiritCtrl:GetSpiritCanvas()
	return self.spirit_view.root_node:GetComponent(typeof(UnityEngine.Canvas))
end

function SpiritCtrl:SetSelectPlunderIndex(index)
	self.spirit_view:SetSelectPlunderIndex(index)
end


-------------精灵奇遇------------------------------------
function SpiritCtrl:OnSCJingLingAdvantageInfo(protocol)
	self.spirit_data:SetSpiritMeetInfo(protocol)
	RemindManager.Instance:Fire(RemindName.SpiritMeet)
	self.spirit_view:Flush("flush_meet")
end

function SpiritCtrl:OnSCJingLingAdvantageCount(protocol)
	self.spirit_data:SetSpiritMeetCount(protocol)
	RemindManager.Instance:Fire(RemindName.SpiritMeet)
	self.spirit_view:Flush("flush_meet")
end

-------------特殊宠物------------------------------------
function SpiritCtrl:OnSCSpecialJingLingInfo(protocol)
	self.spirit_data:SetSpecialSpiritInfo(protocol)
	self.spirit_special_tip_view:Flush()
	self.spirit_view:Flush("spirit")

end

-----------精灵探险--------------------------------------
function SpiritCtrl:SendJingLingExploreOperReq(oper_type, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglIngExploreOperReq)
	send_protocol.oper_type = oper_type
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol:EncodeAndSend()
end

function SpiritCtrl:OnSCJinglIngExploreInfo(protocol)
	self.spirit_data:SetSpiritExploreInfo(protocol)
	if JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_SELECT == protocol.reason then
		if not self.explore_view:Open() then
			self.explore_view:Open()
		else
			self.explore_view:Flush()
		end
	else
		if self.explore_view:IsOpen() then
			self.explore_view:Flush()
		end

		if JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_FETCH == protocol.reason then
			if self.explore_reward_view:IsOpen() then
				self.explore_reward_view:Flush()
			else
				self:OpenExploreRewardView()
			end
		end

		if JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_CHALLENGE_SUCC == protocol.reason or
		 JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_CHALLENGE_FAIL == protocol.reason then
		 	self:OpenSpiritHomeFightView(SPIRIT_FIGHT_TYPE.EXPLORE)
		end

		if JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_RESET == protocol.reason then
			if self.explore_view:IsOpen() then
				self.explore_view:Close()
				self:OpenChooseModeView()
			end
		end

		if JL_EXPLORE_INFO_REASON.JL_EXPLORE_INFO_REASON_BUY_BUFF == protocol.reason then
			TipsCtrl.Instance:FlushSpiritExpBuyBuffView()
		end
	end

	if self.spirit_view:IsOpen() then
		self.spirit_view:Flush("flush_explore_red")
	end
end

function SpiritCtrl:OpenExploreRewardView()
	local stage_index = self.spirit_data:GetExploreGetStageIndex()
	if stage_index ~= nil then
		self.spirit_data:SetExploreGetStageIndex(nil)
		self.explore_reward_view:SetData(stage_index)
	end
end

function SpiritCtrl:OpenExpFightView(stage)
	self.explore_fight_view:SetData(stage)
end

function SpiritCtrl:OpenChooseModeView()
	local max_hp = self.spirit_data:GetSpiritModeMaxHp()
	if max_hp == 0 then
		self.explore_choose_model_view:Open()
	else
		self.explore_view:Open()
	end
end

function SpiritCtrl:OpenSpiritExploreVictory()
	self.explore_victory_view:SetData()
end

function SpiritCtrl:OpenSpiritExploreLose()
	self.explore_lose_view:SetData()
end

function SpiritCtrl:CloseSpiritView()
	self.spirit_view:OnClickClose()
end
----------------------------------------------------------
function SpiritCtrl:ShowSpiritZhenFaValueView()
	self.spirit_zhenfa_value_view:Open()
	self.spirit_zhenfa_value_view:Flush()
end

function SpiritCtrl:ShowSpiritZhenFaPromoteView(tab_index)
	--self.spirit_zhenfa_promote_view:ChooseTab(tabname)
	-- self.spirit_zhenfa_promote_view:SetData(tab_index)
	self.spirit_zhenfa_promote_view:Open(tab_index)
end

function SpiritCtrl:OnSkillFreeRefreshTimesChange(times)
	self.spirit_data:SetSpiritSkillFreeRefreshTimes(times)
	self.flush_spirit_skill_little_view:Flush()
end

function SpiritCtrl:CloseGetSkillViewAutoBuy()
	self.spirit_get_skill_view:CloseAutoBuy()
end

function SpiritCtrl:SpiritMeetTimeQuest()
	self.spirit_data.spirit_meet_remind = true
	RemindManager.Instance:Fire(RemindName.SpiritMeet)
end


function SpiritCtrl:OnAttrOperateResult(result)
	if self.spirit_view.son_spirit_view then
		if self.spirit_view.son_spirit_view.attr_view then
			self.spirit_view.son_spirit_view.attr_view:OnUpgradeResult(result)
		end
	end
end

function SpiritCtrl:OnAptitudeOperateResult(result)
	if self.spirit_view.son_spirit_view then
		if self.spirit_view.son_spirit_view.aptitude_view then
			self.spirit_view.son_spirit_view.aptitude_view:OnUpgradeResult(result)
		end
	end
end

function SpiritCtrl:OpenHunt()
	self.spirit_view:OpenHunt()
	self.spirit_view:Flush()
end

-----------------------------------------精灵命魂-自动改命------------------------------------------
function SpiritCtrl:OpenSoulQuickFlushView()
	if self.soul_quick_flush_view and not self.soul_quick_flush_view:IsOpen() then
		self.soul_quick_flush_view:Open()
	end
end

function SpiritCtrl:OnQuickGaiMingResult(result)
	self:CacleSendDelayTime()
	self:CacleDelayTime()
	if self.spirit_view and self.spirit_view:IsOpen() then
		local soul_view_is_open = self.spirit_view:IsOpenSoulView()
		if not soul_view_is_open then
			self:RecoverData()
			return
		end

		if result == 0 then
			local state = self.spirit_data:GetQuickChangeLifeState()
			if state == QUICK_FLUSH_STATE.GAI_MING_ZHONG then
				self:ChangeLifeContinue()
				return
			end

			self:RecoverData()
			return
		else
			self:SoulQuickFlushAction()
			return
		end
	end
	self:RecoverData()
end

function SpiritCtrl:SoulQuickFlushAction()
	local state = self.spirit_data:GetQuickChangeLifeState()
	if state == QUICK_FLUSH_STATE.NO_START then
		self:RecoverData()
	elseif state == QUICK_FLUSH_STATE.REQUIRE_START then
		self:BeginSendChangeLifePro()
	elseif state == QUICK_FLUSH_STATE.GAI_MING_ZHONG then
		self:ChangeLifeContinue()
	elseif state == QUICK_FLUSH_STATE.CHOU_HUN_ZHONG then
		self:ChouHunEnd()
	end
end

function SpiritCtrl:BeginSendChangeLifePro()
	if self.spirit_view and self.spirit_view:IsOpen() then
		local soul_view_is_open = self.spirit_view:IsOpenSoulView()
		if not soul_view_is_open then
			self:RecoverData()
			return
		end

		local gold_enough = self.spirit_data:SoulGoldIsEnough()
		if not gold_enough then
			TipsCtrl.Instance:ShowLackDiamondView()
			self:RecoverData()
			return 
		end

		local select_color = self.spirit_data:GetSeclectColorSeq()
		if select_color == -1 then
			self:RecoverData()
			return
		end

		self:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.SUPER_CHOUHUN, select_color)
		self:CacleSendDelayTime()
		self.delay_send_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.RecoverData, self), 5)
		self.spirit_view:SoulQuickFlushButtonState(true)
		self.spirit_data:SetQuickChangeLifeState(QUICK_FLUSH_STATE.GAI_MING_ZHONG)
	else
		self:RecoverData()
	end
end

function SpiritCtrl:ChangeLifeContinue()
	if self.spirit_view and self.spirit_view:IsOpen() then
		local soul_view_is_open = self.spirit_view:IsOpenSoulView()
		if not soul_view_is_open then
			self:RecoverData()
			return
		end

		local select_color = self.spirit_data:GetSeclectColorSeq()
		if select_color == -1 then
			self:RecoverData()
			return
		end

		local is_continue = self:IsChongHunStart()
		if is_continue then
			self:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.CHOUHUN, select_color)
			self:CacleSendDelayTime()
			self.delay_send_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.RecoverData, self), 5)
			self.spirit_data:SetQuickChangeLifeState(QUICK_FLUSH_STATE.CHOU_HUN_ZHONG)
		else
			self:RecoverData()
		end
	else
		self:RecoverData()
	end
end

function SpiritCtrl:ChouHunEnd()
	self:CacleDelayTime()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
		self.spirit_data:SetQuickChangeLifeState(QUICK_FLUSH_STATE.REQUIRE_START)
		self:BeginSendChangeLifePro()
	end, 0.5)
end

function SpiritCtrl:RecoverData()
	self:CacleDelayTime()
	self:CacleSendDelayTime()
	self.spirit_data:SetQuickChangeLifeState(QUICK_FLUSH_STATE.NO_START)
	self.spirit_data:SetSeclectColorSeq(-1)
	if self.spirit_view and self.spirit_view:IsOpen() then
		self.spirit_view:SoulQuickFlushButtonState(false)
	end
end

function SpiritCtrl:CacleDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function SpiritCtrl:CacleSendDelayTime()
	if self.delay_send_time then
		GlobalTimerQuest:CancelQuest(self.delay_send_time)
		self.delay_send_time = nil
	end
end

function SpiritCtrl:IsChongHunStart()
	local soul_bag_info = self.spirit_data:GetSpiritSoulBagInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local color = soul_bag_info and soul_bag_info.liehun_color or -1
	local cfg = self.spirit_data:GetSpiritCallSoulCfg()
	if not cfg then 
		return false 
	end

	local is_auto_buy = self.spirit_data:GetHunLiIsAutoBuy()

	for k, v in pairs(cfg) do
		if v.chouhun_color == color then
			if vo.hunli < v.cost_hun_li then
				local item_id = 22606
				local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
				if item_cfg == nil then
					TipsCtrl.Instance:ShowItemGetWayView(item_id)
					return false
				end

				if item_cfg.bind_gold == 0 then
					TipsCtrl.Instance:ShowShopView(item_id, 2)
					return false
				end

				local func = function(_item_id, item_num, is_bind, is_use, is_quick_use)
					MarketCtrl.Instance:SendShopBuy(_item_id, item_num, is_bind, is_use)
					if is_quick_use then
						self.spirit_data:SetHunLiIsAutoBuy(is_quick_use)
					end
				end

				if not is_auto_buy then
					TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1)
					return false
				else
					if vo.bind_gold >= item_cfg.bind_gold then
						MarketCtrl.Instance:SendShopBuy(item_id, 1, 1, 1)
					elseif vo.gold >= item_cfg.bind_gold then
						MarketCtrl.Instance:SendShopBuy(item_id, 1, 0, 1)
					elseif vo.gold < item_cfg.bind_gold then
						TipsCtrl.Instance:ShowLackDiamondView()
						return false
					end
				end
			end
		end
	end
	return true
end