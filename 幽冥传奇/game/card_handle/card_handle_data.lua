CardHandlebookData = CardHandlebookData or BaseClass()

CardHandlebookData.UPDATE_CARD_INFO = "update_card_info"
CardHandlebookData.CARD_DESCOMPOSE_RESULT = "card_descompose_result"
CardHandlebookData.CLICK_CARD_DATA = "click_card_data"
CardHandlebookData.CARD_CHESS_CHANGE = "CARD_CHESS_CHANGE"

function CardHandlebookData:__init()
	if CardHandlebookData.Instance then
		ErrorLog("[CardHandlebookData]:Attempt to create singleton twice!")
	end

	CardHandlebookData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.show_card_list = {}
	self.bag_card_list = {}
	self.descompose_list = {}
	self:InitCardData()

	self.type_show = {[1] = 1, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0, [7] = 0}
end

function CardHandlebookData:__delete()
	CardHandlebookData.Instance = nil
end

function CardHandlebookData:SetListenerEvent()
	CardHandlebookCtrl.CardHandleInfoReq()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CardHandlebook)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetCardCanDescompose, self), RemindName.CardCanDescompose)
end

function CardHandlebookData:OnBagItemChange(event)
	local bool = false
	for i, v in pairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			bool = true
			break
		else
			local item_type = v.data.type
			if item_type == ItemData.ItemType.itPokedex then
				bool = true
				break
			end
		end
	end
	
	if bool then
		RemindManager.Instance:DoRemindDelayTime(RemindName.CardHandlebook)
	end
end

-------------------------
--图鉴展示
-------------------------
--初始化图鉴展示列表
function CardHandlebookData:UpdateJihuoCardData(protocol)
	self.show_card_list[protocol.type_index][protocol.caowei_index].level = protocol.card_level
	self.show_card_list[protocol.type_index][protocol.caowei_index].is_jihuo = true
	RemindManager.Instance:DoRemindDelayTime(RemindName.CardHandlebook)
	self:DispatchEvent(CardHandlebookData.UPDATE_CARD_INFO)
end

function CardHandlebookData:UpdateUpCardData(protocol)
	self.show_card_list[protocol.type_index][protocol.caowei_index].level = protocol.card_level
	self.show_card_list[protocol.type_index][protocol.caowei_index].battle_num = CommonDataManager.GetAttrSetScore(self.GetOneCardAttr(protocol.type_index, protocol.caowei_index, protocol.card_level or 0))
	RemindManager.Instance:DoRemindDelayTime(RemindName.CardHandlebook)
	self:DispatchEvent(CardHandlebookData.UPDATE_CARD_INFO)
end

function CardHandlebookData:InitCardData()
	self.show_card_list = {}
	for type_index, v in pairs(PokedexUpgradeConfig) do
		if nil == self.show_card_list[type_index] then
			self.show_card_list[type_index] = {}
		end
		for ser_index, v1 in pairs(v) do
			local vo = {
				item_id = v1.activation[1].id,
				level = nil, --为空则未激活 
				is_jihuo = false,
				battle_num = 0,
				xl_index = type_index,	--系列索引
				cw_index = ser_index,	--槽位索引
				is_show = false,
			}
			self.show_card_list[type_index][ser_index] = vo
		end
	end
end

function CardHandlebookData:SetShowCardData(protocol)
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combind_days = OtherData.Instance:GetCombindDays()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	for type_index, v in pairs(PokedexUpgradeConfig) do
		for ser_index, v1 in pairs(v) do
			local card_data = self.show_card_list[type_index][ser_index]
			if open_days >= v1.activation[1].opensvrday
				and combind_days >= v1.activation[1].combinesvrday
				and level >= v1.activation[1].level
				and circle >= v1.activation[1].circle then
				local _level = protocol.card_list[type_index] and protocol.card_list[type_index][ser_index]
				card_data.level = _level
				card_data.is_jihuo = _level ~= nil
				card_data.battle_num = CommonDataManager.GetAttrSetScore(self.GetOneCardAttr(type_index, ser_index, _level or 0))
				card_data.is_show = true
			end
		end
	end
	RemindManager.Instance:DoRemindDelayTime(RemindName.CardHandlebook)
	self:DispatchEvent(CardHandlebookData.UPDATE_CARD_INFO)
end

--获取系列内展示图鉴
function CardHandlebookData:GetRemindNum()
	for type_index, v in pairs(self.show_card_list) do
		if self:GetIsRemindByIndex(type_index) then
			return 1
		end
	end
	return 0
end

function CardHandlebookData:GetCardCanDescompose()
	local desc_list = self:GetDescomposeCardBagList()
	if desc_list and desc_list[1] then 
		return 1;
	end
	return 0
end

function CardHandlebookData:GetIsRemindByIndex(type_index)
	if nil == type_index then return 0 end
	for k,v in pairs(self.show_card_list[type_index]) do
		local max_level = #CardHandlebookData.GetServerPokedexAttrCfg(type_index)[k] - 1
		if v.is_jihuo then
			if (RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RIDE_LEVEL) >= self.GetOneCardConsumNum(v.xl_index, v.cw_index, v.level) and v.level < max_level) then
				return true
			end
		elseif BagData.Instance:GetOneItem(v.item_id) and v.is_show then
			return true
		end
	end
	return false
end

--获取系列内展示图鉴
function CardHandlebookData.GetOneCardConsumNum(type_index, ser_index, level)
	local max_level = #CardHandlebookData.GetServerPokedexAttrCfg(type_index)[ser_index] - 1
	if level == max_level then return 0 end
	if PokedexUpgradeConfig[type_index][ser_index].consume[1] then 
		return PokedexUpgradeConfig[type_index][ser_index].consume[level and level + 1 or 1].count
	end
	return 0
end

function CardHandlebookData:GetOneCardShowData(type_index, ser_index)
	return self.show_card_list[type_index][ser_index]
end

--获取系列内展示图鉴
function CardHandlebookData:GetTypeCardShowData(type_index)
	if nil == type_index then return end
	local list = {}
	for k, v in pairs(self.show_card_list[type_index]) do
		if v.is_show then
			table.insert(list, v)
		end
	end
	return list
end

--根据颜色获取卡片档次
local color_to_level = {
	["00ff00"] = 1,	--绿
	["00c0ff"] = 2, --蓝
	["ff0000"] = 3, --红
	["de00ff"] = 4, --紫
	["ff8a00"] = 5, --橙
	["ffff00"] = 6, --金
}
function CardHandlebookData.GetCardShowLevelByColor(color)
	return color_to_level[color] or 1
end

function CardHandlebookData:GetCardAddtionStringDataByIdx(type_index, is_hang)
	local all_num = 0
	local min_level = 0

	local cfg = CardHandlebookData.GetServerPokedexAddAttrCfg(type_index)
	if nil == cfg then return end
	local card_list = self:GetTypeCardShowData(type_index)
	for k,v in pairs(card_list) do
		if v.is_jihuo then
			all_num = all_num + 1
		end
	end

	--获取加成等级
	for k,v in pairs(cfg) do
		if all_num < v.count then
			min_level = v.level - 1
			break
		else
			min_level = k
		end
	end
	if all_num == 0 or min_level <= 0 then
		min_level = 1
	end

	local is_fulfil = all_num >= cfg[1].count
	local is_last = (min_level == #cfg)
	local next_level = is_last and min_level or min_level + 1

	--生成文本
	local get_string_show_data = function (level)
		return cfg[level].name, all_num >= cfg[level].count and cfg[level].count or all_num, cfg[level].count
	end
	-- local title_name = Language.CardHandlebook.TypeName[type_index] .. Language.CardHandlebook.AddTip
	local prof = RoleData.Instance:GetRoleBaseProf()
	local attr_list = {}
	for k, v in pairs(cfg[min_level].attrs) do
		if v.job == prof or v.job == nil then
			table.insert(attr_list, v)
		end
	end
	local min_attr_text = RoleData.FormatAttrContent(attr_list, {type_str_color = COLOR3B.OLIVE})
	local min_name = string.format(Language.CardHandlebook.CardCount, get_string_show_data(min_level)) .. "\n"
	-- local min_text = (is_fulfil and Language.Common.AddTipText1 or "") .. min_name .. min_attr_text 
	if is_hang then
		local txt = ""
		local str = Split(min_attr_text, "\n")
		for i = 1, #str do
			txt = txt .. str[i] .. "   "
		end
		min_attr_text = txt
	end
	local min_text = min_name .. min_attr_text 

	local next_attr_text = RoleData.FormatAttrContent(cfg[next_level].attrs, {type_str_color = COLOR3B.GRAY})
	local next_name = string.format(Language.CardHandlebook.CardCount, get_string_show_data(next_level)) .. "\n"
	local next_text = Language.Common.AddTipText2 .. next_name .. next_attr_text

	--是否提示下级加成
	-- if is_last or all_num == 0 or not is_fulfil then
	-- 	next_text = nil
	-- end

	-- return {title_name, min_text, next_text,}
	return {all_num, #card_list, min_text, next_text}
end

--获取系列战力
function CardHandlebookData:GetTypeIndexPowerNum(type_index)
	if nil == type_index then return 0 end
	local num = 0
	for k,v in pairs(self.show_card_list[type_index]) do
		if v.level then --等级为空即未激活
			num = num + v.battle_num
		end
	end
	return num
end

-- 获取所有系列总战力
function CardHandlebookData:GetAllPowerNum()
	local num = 0
	for k, v in pairs(self.show_card_list) do
		num = num + self:GetTypeIndexPowerNum(k)
	end
	return num
end

--获取服务端图鉴属性配置
function CardHandlebookData.GetServerPokedexAttrCfg(type_index)
	if not type_index then return end
	local cfg_path = "scripts/config/server/config/item/PokedexAttrs/PokedexSuit_" .. type_index
	local cfg = require(cfg_path)
	if not cfg or not cfg[1] then return end

	return cfg[1]
end

--获取服务端图鉴加成属性配置
function CardHandlebookData.GetServerPokedexAddAttrCfg(type_index)
	if not type_index then return end
	local cfg_path = "scripts/config/server/config/AttriPlus/PokedexSuitPlusAttr/PokedexPlusSuit_" .. type_index
	local cfg = require(cfg_path)

	return cfg and cfg[1].attrPlus
end

function CardHandlebookData.GetOneCardAttr(type_index, cw_index, level)
	if nil == level then return {} end
	local cfg = CardHandlebookData.GetServerPokedexAttrCfg(type_index)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local attr_cfg = {}
	if cfg[cw_index] then 
		for k,v in pairs(cfg[cw_index][level + 1]) do
			-- if prof == v.job then 
				table.insert(attr_cfg, v)
			-- end
		end
	end
	return attr_cfg
end

-- 根据item_id获取图鉴属性
function CardHandlebookData:GetAttrByItemId(item_id)
	local type_index, cw_index = CardHandlebookData.GetCardSeriessAndIndexById(item_id)
	if type_index then
		return CardHandlebookData.GetOneCardAttr(type_index, cw_index, 0)
	end
end

function CardHandlebookData.GetOneCardAttrShowString(type_index, cw_index, level)
	local get_attr_string = function (_type_index, _cw_index, _level)
		 return RoleData.FormatAttrContent(CardHandlebookData.GetOneCardAttr(_type_index, _cw_index, _level), {type_str_color = COLOR3B.OLIVE, prof_ignore = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)})
	end
	local max_level = #CardHandlebookData.GetServerPokedexAttrCfg(type_index)[cw_index] - 1
	if nil == level then
		right_txt = nil
		left_txt = get_attr_string(type_index, cw_index, 0)
	elseif level < max_level then
		right_txt = get_attr_string(type_index, cw_index, level)
		left_txt = get_attr_string(type_index, cw_index, level + 1)
	elseif level >= max_level then
		right_txt = get_attr_string(type_index, cw_index, level)
		left_txt = nil
	end
	return right_txt, left_txt
end

function CardHandlebookData:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_RIDE_LEVEL or 
		vo.key == OBJ_ATTR.CREATURE_LEVEL or
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
			CardHandlebookCtrl.CardHandleInfoReq()
			RemindManager.Instance:DoRemindDelayTime(RemindName.CardHandlebook)
			self:DispatchEvent(CardHandlebookData.UPDATE_CARD_INFO)
	end
end

function CardHandlebookData:SetOpenCardData(data)
	self.cur_card_data = data;
	self:DispatchEvent(CardHandlebookData.CLICK_CARD_DATA)
end

function CardHandlebookData:GetOpenCardData()
	return self.cur_card_data
end


-------------------------
--图鉴分解
-------------------------
--初始化图鉴分解
function CardHandlebookData:InitDescomposeCardDataList()
	self.bag_card_list = {}
	for k,v in pairs(BagData.Instance:GetItemDataList()) do
		if v.type == ItemData.ItemType.itPokedex then
			local type_index = self.GetCardSeriessAndIndexById(v.item_id)
			if type_index then 
				local card_list = self:GetTypeCardShowData(type_index)
				for k,v1 in pairs(card_list) do
					if v1.item_id == v.item_id then   -- and v1.is_jihuo 
						local data = {}
						data.item_id = v.item_id
						data.num = v.num
						data.series = v.series
						data.is_bind = v.is_bind
						table.insert(self.bag_card_list, data)
					end
				end
			end
		end
	end
end

--获取套装序列和槽位
function CardHandlebookData.GetCardSeriessAndIndexById(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then return end

	local seriess, index
	for k,v in pairs(item_cfg.conds) do
		if v.cond == 19 then
			seriess = v.value
		end

		if v.cond == 20 then
			index = v.value
		end
	end
	return seriess, index
end

function CardHandlebookData:GetCardTypeName(item_id)
	local seriess = self.GetCardSeriessAndIndexById(item_id)
	if nil == seriess then return end
	return Language.CardHandlebook.TypeName[seriess]
end

function CardHandlebookData:GetDescomposeCardBagList()
	self:InitDescomposeCardDataList()
	return self.bag_card_list
end

--分解图鉴精华
function CardHandlebookData.GetDecomposeCardExp(item_id)
	local type_index, cw_index = CardHandlebookData.GetCardSeriessAndIndexById(item_id)
	if nil ~= type_index then
		return PokedexResolveCfg[type_index].items[cw_index] and PokedexResolveCfg[type_index].items[cw_index][2] or 0
	else
		return 0
	end
end

--分解结果
function CardHandlebookData:SetCardDecomposeResult(protocol)
	self.exp = protocol.exp
	self.num = protocol.num
	self:DispatchEvent(CardHandlebookData.CARD_DESCOMPOSE_RESULT)
end

-- 图鉴回收分类
function CardHandlebookData:SetCardChessData(index, vis)
	self.type_show[index] = vis and 1 or 0

	self:DispatchEvent(CardHandlebookData.CARD_CHESS_CHANGE)
end

function CardHandlebookData:GetRecycleChess()
	return self.type_show
end

-- 回收分类
function CardHandlebookData:RevertTypeEquip(data)
	local tab_item = {}
	self:InitDescomposeCardDataList()
	for k, v in pairs(data) do
		if v == 1 then
			local data = self:RquipTypeShow(k)
			for k1, v1 in pairs(data) do
				table.insert(tab_item, v1)
			end
		end
	end
	if not tab_item[0] and tab_item[1] then
		tab_item[0] = table.remove(tab_item, 1)
	end
	return tab_item
end

function CardHandlebookData:RquipTypeShow(type)
	local item_cfg = nil
	local item_data = {}
	local index = 0
	
	for k, v in pairs(self.bag_card_list) do
		local card_typr = CardHandlebookData.GetCardSeriessAndIndexById(v.item_id)
		if card_typr == type then
			index = index + v.num
			table.insert(item_data, v)
		end
	end
	return item_data, index
end

--获取分解列表内可得图鉴精华
function CardHandlebookData:GetDecomposeListObtain(data)
	local exp = 0
	for k,v in pairs(data) do
		local _exp = 0
		local type_index, cw_index = CardHandlebookData.GetCardSeriessAndIndexById(v.item_id)
		if nil == type_index then return 0 end
		_exp = PokedexResolveCfg[type_index].items[cw_index] and PokedexResolveCfg[type_index].items[cw_index][2]
		exp = exp + _exp * v.num
	end
	return exp
end