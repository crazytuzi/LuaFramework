require("game/spirit/spirit_data")
require("game/spirit/spirit_view")
require("game/spirit/son_spirit_view")
require("game/spirit/spirit_exchange_view")
require("game/spirit/spirit_hunt_view")
require("game/spirit/spirit_warehouse_view")
require("game/spirit/spirit_huanhua_view")
require("game/spirit/spirit_soul_view")
require("game/spirit/spirit_soul_item")
require("game/spirit/spirit_fazhen_view")
require("game/spirit/spirit_halo_view")
require("game/spirit/spirit_image_view")
require("game/spirit/spirit_fazhen_huanhua_view")
require("game/spirit/spirit_halo_huanhua_view")
require("game/spirit/spirit_handbook_view")

SpiritCtrl = SpiritCtrl or BaseClass(BaseController)

function SpiritCtrl:__init()
	if SpiritCtrl.Instance ~= nil then
		print_error("[SpiritCtrl]:Attempt to create singleton twice!")
		return
	end
	SpiritCtrl.Instance = self

	self.spirit_view = SpiritView.New(ViewName.SpiritView)
	self.spirit_data = SpiritData.New()
	self.spirit_huanhua_view = SpiritHuanHuaView.New(ViewName.SpiritHuanHuaView)
	self.fazhen_huanhua_view = SpiritFazhenHuanHuaView.New(ViewName.SpiritFazhenHuanHuaView)
	self.halo_huanhua_view = SpiritHaloHuanHuaView.New(ViewName.SpiritHaloHuanHuaView)
	self.spirit_image_view = SpiritImageView.New()
	self.spirit_handbook_view=SpiritHandbook.New(ViewName.SoulHandBook)
	self.enter_scene_load = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.EnterSceneLoad, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
	self:RegisterAllProtocols()
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

	if self.spirit_data then
		self.spirit_data:DeleteMe()
		self.spirit_data = nil
	end

	if self.spirit_huanhua_view then
		self.spirit_huanhua_view:DeleteMe()
		self.spirit_huanhua_view = nil
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

	SpiritCtrl.Instance = nil
end

function SpiritCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCJingLingInfo, "GetJingLingInfoReq")
	-- self:RegisterProtocol(SCSelfChestShopItemList, "GetSpiritWarehouseItemList")
	self:RegisterProtocol(SCJingLingViewChange, "GetJingLingViewChangeReq")
	--self:RegisterProtocol(SCLieMingSlotInfo, "GetSpiritSlotSoulInfoReq")
	-- self:RegisterProtocol(SCLieMingBagInfo, "GetSpiritSoulBagInfoReq")
	-- self:RegisterProtocol(SCJinglingFazhenInfo, "GetSpiritFazhenInfoReq")
	-- self:RegisterProtocol(SCJinglingGuanghuanInfo, "GetSpiritHaloInfoReq")
	self:RegisterProtocol(CSJinglingGuanghuanUplevelEquip)
	self:RegisterProtocol(CSJinglingFazhenUplevelEquip)
end

function SpiritCtrl:EnterSceneLoad()
	self:SendGetSpiritWarehouseItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
end

function SpiritCtrl:MianUIOpenComlete()
	-- RemindManager.Instance:Fire(RemindName.Spirit)
end

function SpiritCtrl:GetJingLingInfoReq(protocol)
	self.spirit_data:SetSpiritInfo(protocol)
	self.spirit_view:Flush("spirit")
	self.spirit_huanhua_view:Flush()

	-- RemindManager.Instance:Fire(RemindName.Spirit)

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
	end
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
	-- RemindManager.Instance:Fire(RemindName.Spirit)
end

-- 精灵法阵信息
function SpiritCtrl:GetSpiritFazhenInfoReq(protocol)
	self.spirit_data:SetSpiritFazhenInfo(protocol)
	self.spirit_view:Flush()
	self:FlushSpiritImageView()
	self.fazhen_huanhua_view:Flush()
	-- RemindManager.Instance:Fire(RemindName.Spirit)
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

-- 精灵法阵升级装备请求
function SpiritCtrl:SendJinglingFazhenUplevelEquip(equip_idx)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingFazhenUplevelEquip)
	send_protocol.equip_idx = equip_idx or 0
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
	-- self.spirit_view:Flush()
	-- self:FlushSpiritImageView()
	-- self.halo_huanhua_view:Flush()
	-- RemindManager.Instance:Fire(RemindName.Spirit)
	-- 进阶装备
	AdvanceCtrl.Instance:FlushEquipView()
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

-- 精灵光环升级装备请求
function SpiritCtrl:SendJinglingGuanghuanUplevelEquip(equip_idx)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingGuanghuanUplevelEquip)
	send_protocol.equip_idx = equip_idx or 0
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
	self.spirit_image_view:SetFromView(from_view)
	self.spirit_image_view:SetCallBack(callback)
	self.spirit_image_view:Open()
end

function SpiritCtrl:FlushSpiritImageView()
	self.spirit_image_view:Flush()
end