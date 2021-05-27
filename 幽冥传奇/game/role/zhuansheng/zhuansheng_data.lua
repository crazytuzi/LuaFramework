ZhuanshengData  = ZhuanshengData or BaseClass()

ZhuanshengData.LEVEL_EXCHANGE_TIMES_CHANGE = "level_exchange_times_change"

function ZhuanshengData:__init()
	if ZhuanshengData.Instance then
		ErrorLog("[ZhuanshengData] attempt to create singleton twice!")
		return
	end
	ZhuanshengData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.left_exchange_times = 0
	self.left_points = 0
	self.opt_point_list = {}
	self.attr_point_list = {}
	self.zhuansheng_item_cfg = CircleExp or {}
	self.base_attr_list = {}
	self:InitBaseAttrList()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CanZhuansheng)
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CanExchangeZhuanSheng)
end

function ZhuanshengData:__delete()
	ZhuanshengData.Instance = nil
	self.attr_point_list = nil
	self.opt_point_list = nil
	self.base_attr_list = nil
end

function ZhuanshengData:InitBaseAttrList()
	for _, v in pairs(Circle.point) do
		self.base_attr_list[v.type] = v.value
	end
end

-- 是否可以转生
function ZhuanshengData:GetRemindNum(remind_name)
	if remind_name == RemindName.CanZhuansheng then
		local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		local is_max = self:IsMax(circle + 1)
		local consume_cfg = ZhuanshengData.GetZhuanshengConsumeCfg(circle + 1)
		local consume_has_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE_SOUL)
		local is_enough = false
		if not is_max then
			local consume_need_num = consume_cfg.consumes[1].count
			is_enough = consume_has_num >= consume_need_num
		end

		if not is_enough then
			is_enough = self:GetCanChangeLevel()
		end

		return is_enough and 1 or 0
	-- elseif remind_name == RemindName.CanExchangeZhuanSheng then
	-- 	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	-- 	local is_max = self:IsMax(circle + 1)
	-- 	return (self:GetLeftExchangeTimes() > 0 and not is_max) and 1 or 0
	end
end

function ZhuanshengData:GetCanChangeLevel( ... )
	local exchange_cfg = ZhuanshengData.GetZhuanshengSoulExchangeCfg(#Circle.CircleSoulExchange - self:GetLeftExchangeTimes() + 1)
	if exchange_cfg then
		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN) >= exchange_cfg.Consume[1].count then
			return true
		end
	end
	return false
end

function ZhuanshengData:SetLeftExchangeTimes(times)
	self.left_exchange_times = times
	self:DispatchEvent(ZhuanshengData.LEVEL_EXCHANGE_TIMES_CHANGE)
end

function ZhuanshengData:GetLeftExchangeTimes()
	return self.left_exchange_times
end

function ZhuanshengData:SetPointChange(protocol)
	self.left_points = protocol.left_points
	ViewManager.Instance:FlushViewByDef(ViewDef.Role.ZhuanSheng.AddPoint)
end

function ZhuanshengData:SetPointInfo(protocol)
	
	self.left_points = protocol.left_points
	self.attr_point_list = {}
	for k, v in pairs(Circle.point) do
		table.insert(self.attr_point_list, {type = v.type, value = protocol.attr_point_list[k] or 0})
	end
	

	ViewManager.Instance:FlushViewByDef(ViewDef.Role.ZhuanSheng.AddPoint)
end

function ZhuanshengData:GetLeftPoint()
	return self.left_points
end

function ZhuanshengData:IsMax(zhuan)
	return zhuan > 0 and nil == ZhuanshengData.GetZhuanshengConsumeCfg(zhuan)
end

function ZhuanshengData.GetRoleZhuanshengCfg(zhuan)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	return ConfigManager.Instance:GetServerConfig("vocation/circleAddProp/" .. "prop" .. prof)[zhuan]
end

-- 获取转生消耗配置
function ZhuanshengData.GetZhuanshengConsumeCfg(zhuan)
	return Circle.CircleConsumes[zhuan]
end

-- 获取转生兑换修为配置
function ZhuanshengData.GetZhuanshengSoulExchangeCfg(count)
	return Circle.CircleSoulExchange[count]
end

function ZhuanshengData:GetBuyConsumeValData()
	local data_list = {}

	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local get_name = "获得修为"
	local get_type

	-- 兑换
	get_type = 1
	local item = CommonStruct.ItemDataWrapper()
	if self:GetLeftExchangeTimes() > 0 then
		local exchange_cfg = ZhuanshengData.GetZhuanshengSoulExchangeCfg(#Circle.CircleSoulExchange - self:GetLeftExchangeTimes() + 1)
		local consume = exchange_cfg and exchange_cfg.Consume and exchange_cfg.Consume[1] or {}
		local color = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN) >= consume.count and "1eff00" or "ff0000"
		local item_data = ItemData.InitItemDataByCfg(consume)
		local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)

		local level_exchange_data = {
			get_type = get_type,
			cell_data = item,
			icon_id = CLIENT_GAME_GLOBAL_CFG.circle_exchange_icon,	-- 显示图标id
			get_name = get_name,
			YuanBao = consume.count,
			get_value = exchange_cfg.addSoul,
			custom_func = function ()
				ZhuangShengCtrl.SendExchangeTurnTimeReq()
			end,
			
			consume_rich = string.format(Language.ZhuanSheng.AlertTip, color, consume.count .. item_cfg.name, exchange_cfg.addSoul),

			btn_top_desc_rich = string.format(Language.ZhuanSheng.HasCount, self:GetLeftExchangeTimes(), #Circle.CircleSoulExchange),
		}
		return level_exchange_data
	else
		local level_exchange_data = {
			consume_rich = Language.ZhuanSheng.HasNoCount,
			btn_top_desc_rich = string.format(Language.ZhuanSheng.HasCount, self:GetLeftExchangeTimes(), #Circle.CircleSoulExchange),
		}
		return level_exchange_data
	end
	--data_list[#data_list + 1] = level_exchange_data
	--
	---- 商城物品
	--get_type = 2
	--for k, v in pairs(self.zhuansheng_item_cfg) do
	--	local item_id = v.item_id
	--	local shop_cfg = ShopData.GetItemPriceCfg(item_id)
	--	if shop_cfg then
	--		local buy_left_times = ShopData.Instance:GetShopLeftBuyTimes(shop_cfg.id)
	--		local item = CommonStruct.ItemDataWrapper()
	--		item.item_id = item_id
	--		item.num = shop_cfg.buyOnceCount
	--
	--		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	--		local data = {
	--			get_type = get_type,
	--			cell_data = item,
	--			get_name = get_name,
	--			get_value = v.value,
	--			consume_rich = string.format("{colorandsize;edd9b2;18;%s}{image;%s;38,20}{colorandsize;edd9b2;18;%s}", item_cfg.name, ShopData.GetMoneyTypeIcon(shop_cfg.price[1].type), shop_cfg.price[1].price),
	--			btn_top_desc_rich = buy_left_times and string.format("{colorandsize;edd9b2;18;今日还可购买}{colorandsize;1eff00;18;%d}{colorandsize;edd9b2;18;次}", buy_left_times) or "",
	--		}
	--		data_list[#data_list + 1] = data
	--	end
	--end

	--return data_list
end

-- 获取操作加点列表的数据
function ZhuanshengData:GetAddPointData()
    local add_point_data_list = {}
	local attr_data = RoleData.FormatRoleAttrStrNotCombination(self.attr_point_list)
	--PrintTable(self.attr_point_list)
	for k,v in pairs(attr_data) do
		local add_point_data ={
			type = v.type,
			type_str = v.type_str,
			value = v.value or 0,
			percent = 0,
			opt_point = 0,
			old_point = 0,
		}
		add_point_data.old_point = self:GetHadAddPointBytyoe(v.type)
		add_point_data.percent = (add_point_data.old_point or 0)/ZhuanshengData.Instance:GetHadGetPoint() * 100
		table.insert(add_point_data_list, add_point_data)
	end
	-- table.sort(add_point_data_list, function(a, b)
	-- 	if a.type < b.type then
	-- 		return true
	-- 	end
	-- end)
	return add_point_data_list
end

function ZhuanshengData:GetHadAddPointBytyoe(type)
	for k,v in pairs(self.attr_point_list) do
		if v.type == type then
			return v.value or 0
		end
	end
	return 0
end

-- 当前等级总属性点
function ZhuanshengData.GetTotalPoints()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if 0 == circle then return 1 end
	local zhuansheng_cfg = ZhuanshengData.GetZhuanshengConsumeCfg(circle)
	return zhuansheng_cfg.totalPoints
end

---- init操作的属性点
--function ZhuanshengData:InitOptPoints()
--	self.opt_point =
--end
-- 设置操作的属性点列表
function ZhuanshengData:SetOptPointList(index, opt_point)
	self.opt_point_list[index] = opt_point
end

-- 获取上次拉动滑块属性点点数
function ZhuanshengData:GetLastOptPoints(index)
	return self.opt_point_list[index] or 0
end

-- 获取上次拉动滑块属性点点数列表
function ZhuanshengData:GetLastOptPointsList()
	return self.opt_point_list
end

-- 获取操作的属性点总点数
function ZhuanshengData:GetTotleOptPoints()
	local opt_points = 0
	--PrintTable(self.opt_point_list)
	for k, v in pairs(self.opt_point_list) do
		opt_points = opt_points + v
	end
	return opt_points
end

--获取操作后的属性
function ZhuanshengData:GetOptAttrList()
	local point_list = {}
	for k, v in pairs(self.attr_point_list) do
		local temp = {
			type = v.type,
			value =0,
		}
		temp.value = (v.value or 0 ) + tonumber(self.opt_point_list[v.type] or 0)
		table.insert(point_list, temp)
	end
	return self:GetAttrList(point_list)
end

--获得操作的属性
function ZhuanshengData:GetOprateAttrList()
	local point_list = {}
	for k, v in pairs(self.attr_point_list) do
		local temp = {
			type = v.type,
			value =0,
		}
		temp.value =  tonumber(self.opt_point_list[v.type] or 0)
		table.insert(point_list, temp)
	end
	return self:GetAttrList(point_list)
end

--获取当前属性
function ZhuanshengData:GetAttrList(point_list)
	local attr_list = {}
	local format_point_list = RoleData.FormatRoleAttrStrNotCombination(point_list)
	for k, v in pairs(format_point_list) do
		attr_list[k] = {
			type = v.type,
			type_str = v.type_str,
			value = (v.value  or 0)* self.base_attr_list[v.type],
		}
	end
	return attr_list
end

function ZhuanshengData:GetHadGetPoint()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if circle == 0 then
		return 1
	end
	local total_point_cfg = Circle.CircleConsumes[circle]
	if total_point_cfg == nil then
		total_point_cfg = Circle.CircleConsumes[#Circle.CircleConsumes]
	end
	return total_point_cfg.totalPoints or 1
end


function ZhuanshengData:GetOprateEndPoint()
	local point_list = {}
	for k, v in pairs(self.attr_point_list) do
		local temp = {
			type = v.type,
			value =0,
		}
		table.insert(point_list, temp)
	end
	return self:GetAttrList(point_list)
end


function ZhuanshengData:GetPointCanShowAddItem()
	return self.left_points > 0 and 1 or 0
end

function ZhuanshengData:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_COIN or vo.key == OBJ_ATTR.CREATURE_LEVEL or vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		RemindManager.Instance:DoRemindDelayTime( RemindName.CanZhuansheng, 0.2)
	end
end