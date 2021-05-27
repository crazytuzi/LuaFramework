LunHuiData = LunHuiData or BaseClass()

LunHuiData.LUNHUI_ITEM = {3486, 3487}
LunHuiData.LUNHUI_DATA_CHANGE = "lunhui_data_change"

function LunHuiData:__init()
	if LunHuiData.Instance then
		ErrorLog("[LunHuiData]:Attempt to create singleton twice!")
	end
	LunHuiData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	-- 道：地狱0 饿鬼1 畜生2 修罗3 人间4 天5
	-- 境：玄1 生2 破3 虚4 妄5 灭6 进阶7
	self.lunhui_info = {
		lh_grade = 0,
		lh_level = 0,
		lh_consume = 0,
		lh_left_exchange_num = 0,
	}

	self.lunhui_item_cfg = LunHuiExp or {}

	self.lh_max_level = LunHui.MaxLimit[1]		-- 最高境界数
	self.lh_max_grade = LunHui.MaxLimit[2]		-- 最高道数

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetLunHuiRemind, self), RemindName.CanLunHui)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetLunHuiRemind, self), RemindName.CanExchangeLunHui)
end

function LunHuiData:__delete()
	LunHuiData.Instance = nil
end

function LunHuiData:SetAllData(protocol)
	self.lunhui_info = protocol.lunhui_info
	self:DispatchEvent(LunHuiData.LUNHUI_DATA_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.CanLunHui)
	-- RemindManager.Instance:DoRemindDelayTime(RemindName.CanExchangeLunHui)
end

function LunHuiData:GetConsumeNum()
	return self.lunhui_info.lh_consume
end

function LunHuiData:GetLunGrade()
	return self.lunhui_info.lh_grade
end

function LunHuiData:GetLunLevel()
	return self.lunhui_info.lh_level
end

function LunHuiData:GetLunLeftExchangeNum()
	return self.lunhui_info.lh_left_exchange_num
end

-- 轮回是否已满级
function LunHuiData:IsLunHuiMax()
	return 5 == self.lunhui_info.lh_grade and 6 == self.lunhui_info.lh_level
end

function LunHuiData:GetLunHuiMaxLevel()
	return self.lh_max_level
end

function LunHuiData:GetNextLevelConsumeNum()
	local consume = 0
	local grade_index = self.lunhui_info.lh_grade + 1
	local level_index = self.lunhui_info.lh_level + 1

	if LunHui.LunHuiConsumes[grade_index] and LunHui.LunHuiConsumes[grade_index][level_index] then
		consume = consume + LunHui.LunHuiConsumes[grade_index][level_index].consumes[1].count
	elseif LunHui.LunHuiConsumes[grade_index + 1] and LunHui.LunHuiConsumes[grade_index + 1][1] then
		consume = consume + LunHui.LunHuiConsumes[grade_index + 1][1].consumes[1].count
	end

	return consume
end

function LunHuiData:GetRoleLunHuiAttrCfg(grade, level, prof)
	local grade_index = grade or self.lunhui_info.lh_grade
	local level_index = level or self.lunhui_info.lh_level
	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	grade_index = grade_index + 1
	level_index = level_index + 1
	if level_index > 7 then
		grade_index = grade_index + 1
		level_index = 1
	end
	local cfg = ConfigManager.Instance:GetServerConfig("vocation/lunhuiAddProp/prop" .. prof)

	local cur_attr = cfg and cfg[grade_index] and cfg[grade_index][level_index]
	local next_attr = (cfg and cfg[grade_index]) and cfg[grade_index][level_index+1] or nil
	cur_attr = RoleData.FormatRoleAttrStrNotCombination(cur_attr)
	next_attr = next_attr and RoleData.FormatRoleAttrStrNotCombination(next_attr)
	return cur_attr, next_attr
end

function LunHuiData:GetLvExchangeData()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local level_exchange_data = {}
	local exchange_time = #LunHui.LunHuiValueExchange.Exchange - self:GetLunLeftExchangeNum() + 1
	local exchange_cfg = LunHuiData.GetExchangeCfg(exchange_time)
	if exchange_cfg then
		level_exchange_data = {
			
			dh_time = self:GetLunLeftExchangeNum(),
			get_value = exchange_cfg.exchange_val,
			
			consume_rich = string.format("{wordcolor;ffffff;角色等级}{wordcolor;ff0000;下降%d级}\n{wordcolor;ffffff;兑换轮回业力}{wordcolor;55ff00;%d点}", 
				exchange_cfg.exchange_Level, exchange_cfg.exchange_val),
			btn_top_desc_rich = string.format("{colorandsize;edd9b2;18;剩余次数}{colorandsize;1eff00;18;%d}{colorandsize;edd9b2;18;次}", self:GetLunLeftExchangeNum()),
		}
	end

	return level_exchange_data
end

-- function LunHuiData:GetBuyConsumeData()
-- 	-- 商城物品
-- 	local data_list = {}
-- 	-- get_type = 2
-- 	for k, v in pairs(self.lunhui_item_cfg) do
-- 		local item_id = v.item_id
-- 		local shop_cfg = ShopData.GetItemPriceCfg(item_id)
-- 		if shop_cfg then
-- 			local buy_left_times = ShopData.Instance:GetShopLeftBuyTimes(shop_cfg.id)
-- 			local item = CommonStruct.ItemDataWrapper()
-- 			item.item_id = item_id
-- 			item.num = shop_cfg.buyOnceCount

-- 			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
-- 			local data = {
-- 				-- get_type = get_type,
-- 				cell_data = item,
-- 				get_name = get_name,
-- 				get_value = v.value,
-- 				consume_rich = string.format("{colorandsize;edd9b2;18;%s}{image;%s;38,20}{colorandsize;edd9b2;18;%s}", item_cfg.name, ShopData.GetMoneyTypeIcon(shop_cfg.price[1].type), shop_cfg.price[1].price),
-- 				btn_top_desc_rich = buy_left_times and string.format("{colorandsize;edd9b2;18;今日还可购买}{colorandsize;1eff00;18;%d}{colorandsize;edd9b2;18;次}", buy_left_times) or "",
-- 			}
-- 			data_list[#data_list + 1] = data
-- 		end
-- 	end
-- 	return data_list
-- end

function LunHuiData.GetExchangeCfg(time)
	local val_cfg = LunHui.LunHuiValueExchange.Exchange[time]
	if val_cfg then
		return {exchange_val = val_cfg.addSoul, exchange_Level = val_cfg.costlevel}
	-- else
	-- 	return {exchange_val = 0, exchange_Level = level}
	end
end

function LunHuiData:GetLunHuiRemind(remind_name)
	local is_max = self:IsLunHuiMax()
	if is_max then 
		return 0 
	end
	if remind_name == RemindName.CanLunHui then
		local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local consume_has_num = self:GetConsumeNum()
		local consume_need_num = self:GetNextLevelConsumeNum()
		local is_lv = role_level >= LunHui.LunHuiValueExchange.lvLimit
		local is_num = consume_has_num >= consume_need_num
		return (is_lv and is_num) and 1 or 0
	-- elseif remind_name == RemindName.CanExchangeLunHui then
	-- 	return self:GetLunLeftExchangeNum() > 0 and 1 or 0
	end
end
