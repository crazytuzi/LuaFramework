HunQiData = HunQiData or BaseClass()

HunQiData.SHENZHOU_WEAPON_COUNT = 6								--魂器格子数量
HunQiData.SHENZHOU_WEAPON_SLOT_COUNT = 8						--魂器最大八卦牌数量
HunQiData.SHENZHOU_ELEMET_MAX_TYPE = 4							--魂器炼魂最大类型
HunQiData.SLOT_MAX_LEVEL = 100									--八卦牌最大等级
HunQiData.SHENZHOU_WEAPON_BOX_HELP_MAX_CONUT = 4				--最大协助数量
HunQiData.SHENZHOU_HUNYIN_MAX_SLOT = 8							--魂器镶嵌魂印数量
HunQiData.BAOZANG_HELP_NUM = 4									--魂器宝藏最大协助人数
HunQiData.SHENZHOU_XIlIAN_MAX_SLOT = 8							--魂器洗练最大个数
HunQiData.SPECIAL_SHENZHOU_WEAPON_SLOT_COUNT = 2				--魂器格子数量
HunQiData.SPECIAL_SHENZHOU_WEAPON_SLOT_COUNT_SERVER = 4			--魂器格子数量(服务器个数)

SHENZHOU_REQ_TYPE = {
	SHENZHOU_REQ_TYPE_INFO_REQ = 0,											-- 请求所有信息
	SHENZHOU_REQ_TYPE_BUY_GATHER_TIME = 1,									-- 购买采集次数
	SHENZHOU_REQ_TYPE_EXCHANGE_IDENTIFY_EXP = 2,							-- 兑换鉴定经验
	SHENZHOU_REQ_TYPE_INDENTIFY = 3,										-- 鉴定物品 param1 背包物品下标, param2 鉴定数量
	SHENZHOU_REQ_TYPE_UPGRADE_WEAPON_SLOT = 4,								-- 提升魂器部件等级， param1 魂器类型，param2 魂器部位
	SHENZHOU_REQ_TYPE_GATHER_INFO_REQ = 5,									-- 请求采集信息
	SHENZHOU_REQ_TYPE_HELP_OTHER_BOX = 6,									-- 协助别人的宝箱    param_1 对方的uid
	SHENZHOU_REQ_TYPE_OPEN_BOX = 7,											-- 打开宝箱 param_1 开几次
	SHENZHOU_REQ_TYPE_BOX_INFO = 8,											-- 请求宝箱信息
	SHENZHOU_REQ_TYPE_PUT_BOX = 9,											-- 放入宝箱
	SHENZHOU_REQ_TYPE_UPLEVEL_ELEMENT = 10,									-- 提升元素等级， param1 魂器类型，param2 元素类型
	SHENZHOU_REQ_TYPE_UPLEVEL_LINGSHU = 11,									-- 提升灵枢等级， param1 魂器类型， param2 魂印槽
	SHENZHOU_REQ_TYPE_HUNYIN_INLAY = 12,									-- 镶嵌魂印， param1 魂器类型， param2 魂印槽， param3背包索引
	SHENZHOU_REQ_TYPE_INVITE_HELP_OTHER_BOX = 13,							-- 邀请协助宝箱
	SHENZHOU_REQ_TYPE_REMOVE_HELP_BOX = 14,									-- 清除协助
	SHENZHOU_REQ_TYPE_XILIAN_OPEN_SLOT = 15,                                -- 开启洗练槽，param1 魂器类型， param2 属性槽
	SHENZHOU_REQ_TYPE_XILIAN_REQ = 16,                                      -- 请求洗练，param1 魂器类型， param2锁定槽0-7位表示1-8位属性, param3洗练材料类型,param4 是否自动购买, param5 是否免费 1,免费
	SEHNZHOU_REQ_TYPE_SPECIAL_HUNYIN_INLAY = 17,							-- 镶嵌特殊魂印，param1 魂器类型， param2 魂印槽， param3背包索引
	SEHNZHOU_REQ_TYPE_SPECIAL_HUNYIN_INFO = 18,								-- 请求特殊魂印信息
}

HunQiData.ElementItemList = {27501, 27502, 27503, 27504}

HunQiData.XiLianStuffColor = {
	FREE = 0,               -- 免费
	BLUE = 1,               -- 蓝
	PURPLE = 4,				-- 紫
	ORANGE = 7,				-- 橙
	RED = 9, 				-- 红
}

local DISPLAYNAME = {
	[17006] = "hunqi_content_panel_special_1",
	[17005] = "hunqi_content_panel_special_2"
}

function HunQiData:__init()
	if nil ~= HunQiData.Instance then
		return
	end
	HunQiData.Instance = self

	local hunqi_system_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto")
	self.hunqi_slot_level_cfg = ListToMapList(hunqi_system_cfg.hunqi_slot_level_attr, "hunqi", "slot", "level")
	HunQiData.SLOT_MAX_LEVEL = #self.hunqi_slot_level_cfg[0][0]
	self.identify_level_cfg = ListToMapList(hunqi_system_cfg.identify_level, "level", "star_level")
	self.hunqi_skill_cfg = hunqi_system_cfg.hunqi_skill
	self.hunqi_name_cfg = hunqi_system_cfg.hunqi_name
	self.identify_item_cfg = hunqi_system_cfg.identify_item_cfg
	self.exchange_identify_exp_cfg = hunqi_system_cfg.exchange_identify_exp
	self.box_cfg = hunqi_system_cfg.box[1]
	self.box_reward_count_cfg = hunqi_system_cfg.box_reward_count_cfg
	self.other_cfg = hunqi_system_cfg.other[1]
	self.box_reward_cfg = hunqi_system_cfg.box_reward
	self.element_cfg = ListToMapList(hunqi_system_cfg.element_cfg, "hunqi", "element_type", "element_level")
	self.element_name_cfg = hunqi_system_cfg.element_name
	self.hunyin_info = ListToMapList(hunqi_system_cfg.hunyin, "hunyin_id")
	self.hunyin_suit_cfg = hunqi_system_cfg.hunyin_suit
	self.hunyin_all = hunqi_system_cfg.hunyin_all
	self.lingshu_info = ListToMap(hunqi_system_cfg.lingshu, "hunqi_id", "hunyin_slot", "slot_level")
	self.hunyin_get = hunqi_system_cfg.hunyin_get
	self.hunyin_slot_open = hunqi_system_cfg.hunyin_slot_open
	self.all_item_cfg = ConfigManager.Instance:GetAutoConfig("item/other_auto")
	self.gift_item_cfg = ConfigManager.Instance:GetAutoConfig("item/gift_auto")

	self.xilian_open_cfg = ListToMapList(hunqi_system_cfg.xilian_open, "hunqi_id", "slot_id")
	self.xilian_shuxing_type = ListToMapList(hunqi_system_cfg.xilian_shuxing_type, "hunqi_id", "shuxing_type")
	self.special_hunyin_open = ListToMapList(hunqi_system_cfg.special_hunyin_open, "hunqi", "hunyin_slot")
	self.xilian_lock_comsume = hunqi_system_cfg.lock_comsume
	self.xilian_xilian_comsume = hunqi_system_cfg.xilian_comsume
	self.xilian_suit = ListToMapList(hunqi_system_cfg.xilian_suit, "hunqi_id")
	self.xilian_stuff_list = {}
	self:InItXiLianStuffId()

	self.today_gather_times = 0
	self.today_buy_gather_times = 0
	self.today_exchange_identify_exp_times = 0
	self.identify_level = 0
	self.identify_star_level = 0
	self.identify_exp = 0
	self.hunqi_jinghua = 0
	self.box_id = 0
	self.today_open_free_box_times = 0
	self.last_open_free_box_timestamp = 0
	self.today_help_box_num = 0

	self.current_lingshu_exp = 0
	self.current_lingshu_update_need = 0
	self.current_select_hunqi = 1
	self.hunyin_is_inlay = true

	self.day_free_xilian_times = 0
	self.xilian_data = {}
	self.is_show_xilian_red = true

	RemindManager.Instance:Register(RemindName.HunQi_HunQi, BindTool.Bind(self.CalcHunQiRedPoint, self))
	-- RemindManager.Instance:Register(RemindName.HunQi_DaMo, BindTool.Bind(self.CalcDaMoRedPoint, self))
	RemindManager.Instance:Register(RemindName.HunQi_BaoZang, BindTool.Bind(self.CalcBaoZangRedPoint, self))
	RemindManager.Instance:Register(RemindName.HunQi_JuHun, BindTool.Bind(self.CalcJuHunRedPoint, self))
	RemindManager.Instance:Register(RemindName.HunYin_Inlay, BindTool.Bind(self.CalcHunYinInlayRedPoint, self))
	RemindManager.Instance:Register(RemindName.HunYin_LingShu, BindTool.Bind(self.CalcHunYinLingShuRedPoint, self))
	RemindManager.Instance:Register(RemindName.HunQi_XiLian, BindTool.Bind(self.CalcHunQiXiLianShuRedPoint, self))

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function HunQiData:__delete()
	RemindManager.Instance:UnRegister(RemindName.HunQi_HunQi)
	-- RemindManager.Instance:UnRegister(RemindName.HunQi_DaMo)
	RemindManager.Instance:UnRegister(RemindName.HunQi_BaoZang)
	RemindManager.Instance:UnRegister(RemindName.HunQi_JuHun)
	RemindManager.Instance:UnRegister(RemindName.HunYin_Inlay)
	RemindManager.Instance:UnRegister(RemindName.HunYin_LingShu)
	RemindManager.Instance:UnRegister(RemindName.HunQi_XiLian)

	if nil ~= HunQiData.Instance then
		HunQiData.Instance = nil
	end

	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function HunQiData:SetIdentifyRewardList(reward_list)
	self.identify_reward_list = reward_list
end

function HunQiData:GetIdentifyRewardList()
	return self.identify_reward_list
end

function HunQiData:SetHunQiAllInfo(protocol)
	self.today_gather_times = protocol.today_gather_times											--今日采集总数
	self.today_buy_gather_times = protocol.today_buy_gather_times									--今日购买采集总次数
	self.today_exchange_identify_exp_times = protocol.today_exchange_identify_exp_times				--今日兑换鉴定经验次数
	self.identify_level = protocol.identify_level												 	--鉴定等级
	self.identify_star_level = protocol.identify_star_level											--鉴定星级
	self.identify_exp = protocol.identify_exp														--鉴定经验
	self.hunqi_jinghua = protocol.hunqi_jinghua														--魂器精华
	self.lingshu_exp = protocol.lingshu_exp

	self.day_free_xilian_times = protocol.day_free_xilian_times                                     --今日已免费洗练次数
	self.xilian_data = protocol.xilian_data                                                         --洗练信息
	self.hunqi_list = protocol.all_weapon_level_list												--魂器信息列表
end

function HunQiData:SetBaoZangInfo(protocol)
	self.box_id = protocol.box_id
	self.today_open_free_box_times = protocol.today_open_free_box_times								--今天免费开启的宝箱次数
	self.last_open_free_box_timestamp = protocol.last_open_free_box_timestamp						--今天最后免费开启宝箱的时间
	self.today_help_box_num = protocol.today_help_box_num											--今天协助次数

	self.box_help_uid_list = protocol.box_help_uid_list												--已协助列表
end

function HunQiData:GetBoxId()
	return self.box_id
end

function HunQiData:GetTodayOpenFreeBoxNum()
	return self.today_open_free_box_times
end

function HunQiData:GetLastOpenFreeBoxTimeStamp()
	return self.last_open_free_box_timestamp
end

function HunQiData:GetTodayCanHelpBoxNum()
	local times = 0
	if nil == self.other_cfg then
		return times
	end
	local max_help_times = self.other_cfg.box_help_num_limit
	times = max_help_times - self.today_help_box_num
	return times
end

--获取宝箱最大免费开启次数
function HunQiData:GetMaxFreeBoxTimes()
	local times = 0
	if nil == self.other_cfg then
		return times
	end
	return self.other_cfg.box_free_times
end

--获取宝箱免费开启的cd时间
function HunQiData:GetFreeBoxCD()
	local cd = 0
	if nil == self.other_cfg then
		return cd
	end
	return self.other_cfg.box_free_times_cd
end

function HunQiData:GetBoxHelpList()
	return self.box_help_uid_list
end

--获取协助人数
function HunQiData:GetHelpCount()
	local count = 0
	if nil == self.box_help_uid_list then
		return count
	end

	for _, v in ipairs(self.box_help_uid_list) do
		if v > 0 then
			count = count + 1
		end
	end
	return count
end

function HunQiData:GetBoxRewardCfg()
	return self.box_reward_cfg
end

--获取宝藏配置表
function HunQiData:GetBoxCfg()
	return self.box_cfg
end

function HunQiData:GetBoxRewardCountCfg()
	if nil == self.box_reward_count_cfg then
		return nil
	end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg = nil
	for k, v in ipairs(self.box_reward_count_cfg) do
		if role_level >= v.level then
			cfg = v
		end
	end
	return cfg
end

--获取魂器红点
function HunQiData:CalcHunQiRedPoint()
	local flag = 0
	--先判断功能是否开启
	if not OpenFunData.Instance:CheckIsHide("hunqi") then
		return flag
	end

	if nil == self.hunqi_list then
		return flag
	end
	--判断材料是否足够
	for k, v in ipairs(self.hunqi_list) do
		if flag == 1 then
			break
		end
		local hunqi_level = v.weapon_level
		if hunqi_level < HunQiData.SLOT_MAX_LEVEL then
			local kapai_level_list = v.weapon_slot_level_list
			for i, j in ipairs(kapai_level_list) do
				if j < HunQiData.SLOT_MAX_LEVEL then
					local kapai_data = self:GetSlotAttrByLevel(k-1, i-1, j)
					if nil ~= kapai_data then
						kapai_data = kapai_data[1]
						local up_level_item_data = kapai_data.up_level_item
						local now_item_num = ItemData.Instance:GetItemNumInBagById(up_level_item_data.item_id)
						if now_item_num >= up_level_item_data.num then
							flag = 1
							break
						end
					end
				end
			end
		end

		--判断炼魂红点
		local element_level_list = v.element_level_list
		for i, j in ipairs(element_level_list) do
			local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(k-1, i-1, j+1)
			if nil ~= next_attr_info then
				local attr_info = HunQiData.Instance:GetSoulAttrInfo(k-1, i-1, j)
				attr_info = attr_info[1]
				local limit_level = attr_info.huqi_level_limit
				if hunqi_level >= limit_level then
					local up_level_item = attr_info.up_level_item
					local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
					if have_num >= up_level_item.num then
						flag = 1
						break
					end
				end
			end
		end
	end
	return flag
end

--获取打磨红点
function HunQiData:CalcDaMoRedPoint()
	local flag = 0
	--先判断功能是否开启
	if not OpenFunData.Instance:CheckIsHide("hunqi") then
		return flag
	end
	--判断是否存在可以打磨的物品
	local damo_list = self:GetIdentifyItemList()
	if nil == damo_list then
		return flag
	end
	for k, v in ipairs(damo_list) do
		local item_id = v.consume_item_id
		local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
		if have_num > 0 then
			flag = 1
			break
		end
	end
	-- 远古遗迹采集次数
	local caiji_num= HunQiData.Instance:GetTodayLeftGatherTimes()
	if caiji_num and caiji_num > 0 then
		flag = 1
	end
	return flag
end

--获取宝藏红点
function HunQiData:CalcBaoZangRedPoint()
	local flag = 0
	--先判断功能是否开启
	if not OpenFunData.Instance:CheckIsHide("hunqi") then
		return flag
	end
	--先判断是否有免费次数
	if self.today_open_free_box_times < self:GetMaxFreeBoxTimes() then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local times = server_time - self.last_open_free_box_timestamp
		--再判断是否在cd时间内
		if times >= self:GetFreeBoxCD() then
			flag = 1
		end
	end

	-- --判断协助人数是否已满
	-- if flag == 0 then
	-- 	if nil == self.box_help_uid_list then
	-- 		return flag
	-- 	end
	-- 	flag = 1
	-- 	for k, v in ipairs(self.box_help_uid_list) do
	-- 		if v <= 0 then
	-- 			flag = 0
	-- 			break
	-- 		end
	-- 	end
	-- end
	return flag
end

--获得聚魂红点
function HunQiData:CalcJuHunRedPoint()
	local hunqi_list = self:GetHunQiList()
	if hunqi_list == nil then
		return
	end

	local is_show = false
	for k1, v1 in ipairs(hunqi_list) do
		if is_show then
			break
		end
		local hunqi_level = v1.weapon_level
		local element_level_list = v1.element_level_list
		for k2, v2 in ipairs(element_level_list) do
			local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(k1-1, k2-1, v2+1)
			if nil ~= next_attr_info then
				local attr_info = HunQiData.Instance:GetSoulAttrInfo(k1-1, k2-1, v2)
				attr_info = attr_info[1]
				local limit_level = attr_info.huqi_level_limit
				if hunqi_level >= limit_level then
					local up_level_item = attr_info.up_level_item
					local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
					if have_num >= up_level_item.num then
						is_show = true
						break
					end
				end
			end
		end
	end
	return is_show and 1 or 0
end


--是否已经查看过一次宝箱红点消息
function HunQiData:SetIsCheckBoxRemind(state)
	self.is_check_box_remind = state
end

function HunQiData:GetIsCheckBoxRemind()
	return self.is_check_box_remind
end

--获取对应魂器的战斗力
function HunQiData:GetHunQiCapability(hunqi_index)
	local capability = 0
	if nil == self.hunqi_list then
		return capability
	end
	local kapai_data_list = self.hunqi_list[hunqi_index].weapon_slot_level_list
	if nil == kapai_data_list then
		return capability
	end
	local attr_info = CommonStruct.Attribute()
	for k, v in ipairs(kapai_data_list) do
		local attr_data = self:GetSlotAttrByLevel(hunqi_index-1, k-1, v)
		if nil ~= attr_data then
			attr_data = attr_data[1]
			attr_data = CommonDataManager.GetAttributteByClass(attr_data)
			attr_info = CommonDataManager.AddAttributeAttr(attr_info, attr_data)
		end
	end
	capability = CommonDataManager.GetCapabilityCalculation(attr_info)
	return capability
end

--获取总属性列表
function HunQiData:GetAllAttrInfo()
	local all_attr_info = CommonStruct.Attribute()
	if nil == self.hunqi_list then
		return all_attr_info
	end
	for k, v in ipairs(self.hunqi_list) do
		local kapai_data_list = v.weapon_slot_level_list
		for i, j in ipairs(kapai_data_list) do
			local attr_data = self:GetSlotAttrByLevel(k-1, i-1, j)
			if nil ~= attr_data then
				attr_data = attr_data[1]
				attr_data = CommonDataManager.GetAttributteByClass(attr_data)
				all_attr_info = CommonDataManager.AddAttributeAttr(all_attr_info, attr_data)
			end
		end
	end
	return all_attr_info
end

--获取对应魂器八卦牌的属性
function HunQiData:GetSlotAttrByLevel(hunqi, slot, level)
	if nil == self.hunqi_slot_level_cfg or nil == self.hunqi_slot_level_cfg[hunqi] or nil == self.hunqi_slot_level_cfg[hunqi][slot] then
		return nil
	end
	return self.hunqi_slot_level_cfg[hunqi][slot][level]
end

function HunQiData:GetidentifyLevelInfo(level, star_level)
	if nil == self.identify_level_cfg or nil == self.identify_level_cfg[level] then
		return nil
	end
	return self.identify_level_cfg[level][star_level]
end

--获取魂器名字和颜色
function HunQiData:GetHunQiNameAndColorByIndex(hunqi_index)
	local name = ""
	local color = GameEnum.ITEM_COLOR_WHITE
	if nil == self.hunqi_name_cfg then
		return name, color
	end
	for k, v in ipairs(self.hunqi_name_cfg) do
		if v.hunqi == hunqi_index then
			if self:IsActiveSpecial(hunqi_index+1) then
				name = v.other_name or ""
			else
				name = v.name or ""
			end
			color = v.color or GameEnum.ITEM_COLOR_WHITE
			break
		end
	end
	return name, color
end

--获取技能名字
function HunQiData:GetHunQiSkillByIndex(hunqi_index)
	local skill_name = ""
	if nil == self.hunqi_name_cfg then
		return skill_name
	end
	for k, v in ipairs(self.hunqi_name_cfg) do
		if v.hunqi == hunqi_index then
			skill_name = v.skill_name or ""
			break
		end
	end
	return skill_name
end

--获取魂器的资源id
function HunQiData:GetHunQiResIdByIndex(hunqi_index)
	local res_id = 0
	if nil == self.hunqi_name_cfg then
		return res_id
	end
	for k, v in ipairs(self.hunqi_name_cfg) do
		if v.hunqi == hunqi_index then
			res_id = v.res_id or 0
			break
		end
	end
	return res_id
end

function HunQiData:GetHunQiSkillResIdByIndex(hunqi_index)
	local res_id = 0
	if nil == self.hunqi_name_cfg then
		return res_id
	end
	for k, v in ipairs(self.hunqi_name_cfg) do
		if v.hunqi == hunqi_index then
			res_id = v.skill_img or 0
			break
		end
	end
	return res_id
end

--获取对应的技能信息
function HunQiData:GetSkillInfoByIndex(hunqi_index, level, is_next)
	if nil == self.hunqi_skill_cfg then
		return nil
	end

	for k, v in ipairs(self.hunqi_skill_cfg) do
		if hunqi_index == v.hunqi then
			if level == v.level then
				if is_next then
					local skill_info = self.hunqi_skill_cfg[k+1]
					if skill_info and skill_info.hunqi ~= hunqi_index then
						skill_info = nil
					end
					return skill_info
				else
					return v
				end
			elseif level < v.level then
				if is_next then
					return v
				else
					return self.hunqi_skill_cfg[k-1]
				end
			end
		end
	end
end

--返回魂器图标名称等信息表
function HunQiData:GetHunQiNameTable()
	return self.hunqi_name_cfg
end

--获取对应的魂器等级
function HunQiData:GetHunQiLevelByIndex(hunqi_index)
	local level = 0
	if nil == self.hunqi_list then
		return level
	end
	if nil == self.hunqi_list[hunqi_index + 1] then
		return level
	end
	level = self.hunqi_list[hunqi_index + 1].weapon_level or 0
	return  level
end

--获取打磨需要消耗的物品列表
function HunQiData:GetIdentifyItemList()
	return self.identify_item_cfg
end

function HunQiData:GetIdentifyLevel()
	return self.identify_level
end

function HunQiData:GetIdentifyStarLevel()
	return self.identify_star_level
end

function HunQiData:GetHunQiList()
	return self.hunqi_list
end

--获取已兑换经验次数
function HunQiData:GetExChangeTimes()
	return self.today_exchange_identify_exp_times
end

function HunQiData:GetExChangeCfg()
	return self.exchange_identify_exp_cfg
end

--获取当前经验
function HunQiData:GetNowExp()
	return self.identify_exp
end

function HunQiData:GetTodayLeftGatherTimes()
	local left_times = 0
	if nil == self.other_cfg then
		return left_times
	end
	local total_count = self.other_cfg.role_day_gather_num + self.today_buy_gather_times
	left_times = total_count - self.today_gather_times
	return left_times
end

--获取单个魂魄的属性列表
function HunQiData:GetSoulAttrInfo(hunqi, element_type, element_level)
	if nil == self.element_cfg or nil == self.element_cfg[hunqi] or nil == self.element_cfg[hunqi][element_type] then
		return nil
	end
	return self.element_cfg[hunqi][element_type][element_level]
end

--获取下一个有增加属性百分比的属性列表
function HunQiData:GetNextAddAttrInfo(hunqi, element_type, element_level)
	if nil == self.element_cfg or nil == self.element_cfg[hunqi] or nil == self.element_cfg[hunqi][element_type] then
		return nil
	end
	for k, v in pairs(self.element_cfg[hunqi][element_type]) do
		if k > element_level then
			local attr_info = self.element_cfg[hunqi][element_type][element_level]
			if attr_info then
				attr_info = attr_info[1]
				local now_attr_add_per = attr_info.attr_add_per
				local attr_add_per = v[1].attr_add_per
				if attr_add_per > now_attr_add_per then
					return v
				end
			end
		end
	end
	return nil
end

--是否已激活了特殊属性(用于魂器特殊展示使用)hunqi_index从1开始
function HunQiData:IsActiveSpecial(hunqi_index)
	local is_active_special = false
	if nil == self.hunqi_list then
		return is_active_special
	end
	local hunqi_data = self.hunqi_list[hunqi_index]
	if nil == hunqi_data then
		return is_active_special
	end
	local element_level_list = hunqi_data.element_level_list
	local active_count = 0
	for k, v in ipairs(element_level_list) do
		if v > 0 then
			active_count = active_count + 1
		end
	end
	if active_count >= HunQiData.SHENZHOU_ELEMET_MAX_TYPE then
		is_active_special = true
	end
	return is_active_special
end

function HunQiData:GetElementNameByType(element_type)
	local name = ""
	if nil == self.element_name_cfg then
		return name
	end

	for k, v in ipairs(self.element_name_cfg) do
		if v.element_type == element_type then
			name = v.element_name
			break
		end
	end
	return name
end

--获取魂器聚魂总属性(包括特殊属性)hunqi_index从1开始
function HunQiData:GetAllElementAttrInfo(hunqi_index)
	if nil == self.hunqi_list then
		return nil
	end

	local attr_list = CommonStruct.Attribute()
	local special = 0
	for k1, v1 in ipairs(self.hunqi_list) do
		if hunqi_index == k1 then
			local element_level_list = v1.element_level_list
			for k2, v2 in ipairs(element_level_list) do
				local attr_info = self:GetSoulAttrInfo(k1-1, k2-1, v2)
				if nil ~= attr_info then
					attr_info = attr_info[1]
					special = special + attr_info.attr_add_per
					attr_info = CommonDataManager.GetAttributteByClass(attr_info)
					attr_list = CommonDataManager.AddAttributeAttr(attr_list, attr_info)
				end
			end
		end
	end
	attr_list.special = special
	return attr_list
end

--获取魂器信息
function HunQiData:GetHunQiInfoList()
	return self.hunqi_list
end

--通过索引获取魂器的魂印列表信息
function HunQiData:GetHunYinListByIndex(hunqi_index)
	local hunyin_slot_list = {}
	if not self.hunqi_list then return hunyin_slot_list end
	if nil ~= self.hunqi_list[hunqi_index].hunyin_slot_list then
		hunyin_slot_list = self.hunqi_list[hunqi_index].hunyin_slot_list
	end
	return hunyin_slot_list
end

--灵枢经验
function HunQiData:GetLingshuExp()
	return self.lingshu_exp or 0
end

function HunQiData:GetCurrentHunYinSuitLevel(hunqi_index)
	if not self.hunqi_list then return 0 end
	return self.hunqi_list[hunqi_index].hunyin_suit_level or 0
end

function HunQiData:GetHunQiInfo()
	return self.hunyin_info or {}
end

function HunQiData:IsHunyinItem(item_id)
 	return nil ~= self.hunyin_info[item_id]
end

function HunQiData:GetHunYinSuitCfgByIndex(index)
	local data = {}
	if nil ~= self.hunyin_suit_cfg then
		for k,v in pairs(self.hunyin_suit_cfg) do
			if v.hunqi_id == index then
			 table.insert(data, v)
			end
		end
	end
	return data
end

function HunQiData:GetHunYinAllInfo()
	return self.hunyin_all or {}
end

--根据等级 魂器ID取得灵枢属性
function HunQiData:GetLingshuAttrByIndex(hunqi, solt, level)
	return self.lingshu_info[hunqi][solt][level] or {}
end

--根据魂器ID槽位取得灵枢最大等级
function HunQiData:GetLingshuAttrMaxLevel(hunqi, solt)
	if self.lingshu_info[hunqi] and self.lingshu_info[hunqi][solt] then
		return #self.lingshu_info[hunqi][solt]
	end
	return 0
end

function HunQiData:GetHunYinGet()
	return self.hunyin_get or {}
end

function HunQiData:IsHunYinLockAndNeedLevel(hunqi_id, hunyin_id)
	if nil == hunqi_id or nil == hunyin_id then return false, 1 end

	hunqi_id = hunqi_id - 1
	local current_hunyin_open_list = {}
	for k,v in pairs(self.hunyin_slot_open) do
	 	if hunqi_id == v.hunqi then
	 		table.insert(current_hunyin_open_list, v)
	 	end
	end
	local need_level = current_hunyin_open_list[hunyin_id].open_hunqi_level
	return self:GetHunQiLevelByIndex(hunqi_id) < need_level, need_level
end

--获取魂印对应icon
function HunQiData:GetHunYinItemIconId(item_id)
	if nil ~= self.all_item_cfg[item_id] then
		return self.all_item_cfg[item_id].icon_id
	else
		return 0
	end
end

function HunQiData:GetGiftItemIconId(item_id)
	if nil ~= self.gift_item_cfg[item_id] then
		return self.gift_item_cfg[item_id].icon_id
	else
		return 0
	end
end

function HunQiData:GetHunQiHunYinOpenLevel(hunqi_index)
	for k,v in pairs(self.hunyin_slot_open) do
		if v.hunqi == hunqi_index then
			return v.open_hunqi_level or 0
		end
	end
	return 0
end

--设置灵枢经验以及当前灵枢需要的经验
function HunQiData:SetLingShuExpAndCurrentNeed(current, need)
	self.current_lingshu_exp = current or 0
	self.current_lingshu_update_need = need or 0
end

function HunQiData:GetLingShuExpAndCurrentNeed()
	return self.current_lingshu_exp, self.current_lingshu_update_need
end

--设置当前选择的魂器
function HunQiData:SetCurrenSelectHunqi(current_select_hunqi)
	self.current_select_hunqi = current_select_hunqi or 1
end

function HunQiData:GetCurrenSelectHunqi()
	return self.current_select_hunqi or 1
end

--获取当前魂印列表
function HunQiData:GetCurrentHunYinListInfo()
	return self:GetHunYinListByIndex(self.current_select_hunqi)
end

function HunQiData:SetIsInlayOrUpdate(state)
	self.hunyin_is_inlay = state
end

-- 计算镶嵌红点
function HunQiData:CalcHunYinInlayRedPoint()
	local flag = 0
	--先判断功能是否开启
	if not OpenFunData.Instance:CheckIsHide("hunqi_hunyin") then
		return flag
	end
	for j=1,6 do
		for i=1, 8 do
			if self:CalcShenglingInlayCellInlayRedPoint(i, j) then
				return 1
			end
		end
	end
	flag = self:CalSpecialSlotRedPoint()
	return flag
end

-- 特殊签文红点
function HunQiData:CalSpecialSlotRedPoint()
	for i = 1, HunQiData.SHENZHOU_WEAPON_COUNT do
		for j = 1, HunQiData.SPECIAL_SHENZHOU_WEAPON_SLOT_COUNT do
			-- 判断魂器是否开启
			if self:CalSingleSpecialSlotRedPoint(j + HunQiData.SHENZHOU_WEAPON_SLOT_COUNT, i) then
				return 1
			end
		end
	end
	return 0
end

-- 单个特殊签文红点
function HunQiData:CalSingleSpecialSlotRedPoint(hunyin_index, hunqi_index)
	--index 9-10 -1为当前solt_index
	if nil == hunqi_index then
		hunqi_index = self.current_select_hunqi
	end
	if hunyin_index <= HunQiData.SHENZHOU_WEAPON_SLOT_COUNT then
		return false
	end

	-- 魂器是否开启
	local level = self:GetHunQiLevelByIndex(hunqi_index - 1)
	local open_level = self:GetHunQiHunYinOpenLevel(hunqi_index - 1)
	--未开启直接返回false
	if level < open_level then
		return false
	end

	-- 特殊槽位是否开启
	if self:GetSpecialShenYinIsOpen(hunqi_index, hunyin_index - HunQiData.SHENZHOU_WEAPON_SLOT_COUNT) == false then
		return false
	end

	-- 当前槽位信息
	local special_hunyin_slot_info = self:GetSpecialHunyinInfo(hunqi_index, hunyin_index - HunQiData.SHENZHOU_WEAPON_SLOT_COUNT)
	if next(special_hunyin_slot_info) == nil then
		return false
	end

	-- 特殊签文在背包信息,背包中没有特殊签文直接返回
	local special_hunyin_info_in_bag = HunQiData.Instance:GetSpecialShenYinInBag()
	if next(special_hunyin_info_in_bag) == nil then
		return false
	end

	if special_hunyin_slot_info.hunyin_id == 0 and special_hunyin_info_in_bag[1].num > 0 then
		return true
	end

	return false
end

-- 计算灵枢升级红点
function HunQiData:CalcHunYinLingShuRedPoint()
	local flag = 0
	--先判断功能是否开启
	if not OpenFunData.Instance:CheckIsHide("hunqi_hunyin") then
		return flag
	end
	for i=1, HunQiData.SHENZHOU_WEAPON_COUNT do
		for j=1, HunQiData.SHENZHOU_HUNYIN_MAX_SLOT do
		 	if self:ShowLingShuUpdateRep(j, i) then
		 		flag = 1
		 		break
		 	end
		end
	end

	return flag
end

-- 计算洗练红点
function HunQiData:CalcHunQiXiLianShuRedPoint()
	local has_item = false

	for i,v in ipairs(self.xilian_xilian_comsume) do
		if 0 ~= v.consume_item.item_id then
			local item_num = ItemData.Instance:GetItemNumInBagById(v.consume_item.item_id)
			if item_num > 0 then
				has_item = true
				break
			end
		end
	end

	local num = (self.is_show_xilian_red and has_item) and 1 or 0
	return num
end

function HunQiData:CalcHunQiXiLianShuRedPointById(hunqi_id)
	return 0
	-- local num = 0
	-- local has_open = false
	-- local has_stuff = false
	-- local has_free_time = false
	-- local xilian_data = self.xilian_data[hunqi_id]
	-- if not xilian_data then
	-- 	return 0
	-- end

	-- for i = 0, 31 do
	-- 	if 1 == xilian_data.xilian_slot_open_falg[32 - i] then
	-- 		has_open = true
	-- 		break
	-- 	end
	-- end

	-- local consume_cfg = self.xilian_xilian_comsume
	-- for i,v in ipairs(consume_cfg) do
	-- 	if v.comsume_color ~= HunQiData.XiLianStuffColor.FREE then
	-- 		local stuff_num = ItemData.Instance:GetItemNumInBagById(v.consume_item.item_id)
	-- 		if stuff_num > 0 then
	-- 			has_stuff = true
	-- 		end
	-- 	end
	-- end

	-- local free_max_times = self:GetOtherCfg().free_xilian_times
	-- local yet_free_times = self:GetHunQiXiLianFreeTimes()
	-- local surplus = free_max_times - yet_free_times
	-- has_free_time = surplus > 0 and true or false

	-- num = has_open and (has_stuff or has_free_time) and 1 or 0
	-- return num
end

--计算魂器按钮红点
function HunQiData:CalcHunQiBtnRedPoint(hunqi_index)
	--如果是镶嵌
	if self.hunyin_is_inlay then
		for i=1,8 do
			if self:CalcShenglingInlayCellInlayRedPoint(i, hunqi_index) then
				return true
			end
			if i <= HunQiData.SPECIAL_SHENZHOU_WEAPON_SLOT_COUNT then
				if self:CalSingleSpecialSlotRedPoint(i + HunQiData.SHENZHOU_WEAPON_SLOT_COUNT, hunqi_index) then
					return true
				end
			end
		end
	else
		for i=1,8 do
			if self:CalcShenglingInlayCellUpdateRedPoint(i, hunqi_index) then
				return true
			end
		end
	end
	return false
end

function HunQiData:CalcShenglingInlayCellInlayRedPoint(index, hunqi_index)
	--index 1-8 -1为当前solt_index
	if nil == hunqi_index then
		hunqi_index = self.current_select_hunqi
	end
	local current_hunqi_data = self:GetHunYinListByIndex(hunqi_index)
	--先判断当前魂器是否开启
	local level = self:GetHunQiLevelByIndex(hunqi_index - 1)
	local open_level = self:GetHunQiHunYinOpenLevel(hunqi_index - 1)
	--未开启直接返回false
	if level < open_level then
		return false
	end
	local current_shengling_data = current_hunqi_data[index]
	if nil == current_shengling_data then
		return false
	end
	local current_hunyin_id = current_shengling_data.hunyin_id
	local bag_hunyin_info = {}
	local item_id_list = {}
	for k,v in pairs(self.hunyin_info) do
		table.insert(item_id_list, k)
	end
	for k, v in pairs(item_id_list) do
		local count = ItemData.Instance:GetItemNumInBagById(v)
		local solt_index = self.hunyin_info[v][1].inlay_slot + 1
		if count > 0 and solt_index == index then
			table.insert(bag_hunyin_info, {item_id = v, solt_index = solt_index, })
		end
	end
	if current_hunyin_id == 0 then
		--未镶嵌
		for k,v in pairs(bag_hunyin_info) do
			--如果有可镶嵌在当前槽的魂印
			if v.solt_index == index then
				return true
			end
		end
	else
		--已镶嵌
		for k,v in pairs(bag_hunyin_info) do
			--如果有可镶嵌在当前槽的魂印
			if v.solt_index == index and self.hunyin_info[v.item_id][1].hunyin_color > self.hunyin_info[current_hunyin_id][1].hunyin_color then
				return true
			end
		end
	end
	return false
end

--计算灵枢升级界面下魂器按钮的红点
function HunQiData:CalcShenglingInlayCellUpdateRedPoint(index, hunqi_index)
	--index 1-8 -1为当前solt_index
	if nil == hunqi_index then
		hunqi_index = self.current_select_hunqi
	end
	if self:ShowLingShuUpdateRep(index, hunqi_index) then
		return true
	end
	return false
end

--显示灵枢升级按钮红点
function HunQiData:ShowLingShuUpdateRep(shengling_index, hunqi_index)
	if nil == hunqi_index then
		hunqi_index = self.current_select_hunqi
	end
	--判断魂器是否开启
	local is_lock = self:IsHunYinLockAndNeedLevel(hunqi_index, shengling_index)
	if is_lock then
		return false
	end
	--判断灵枢是否镶嵌魂印
	local current_lingshu_exp = self:GetLingshuExp()
 	local current_lingshu_info = self:GetHunYinListByIndex(hunqi_index)[shengling_index]
 	if nil == current_lingshu_info then
 		return false
 	end

 	local lingshu_level = current_lingshu_info.lingshu_level
 	local hunyin_id = current_lingshu_info.hunyin_id
 	if hunyin_id == 0 then
 		return false
 	end
 	local hunyin_color = self.hunyin_info[hunyin_id][1].hunyin_color
 	--是否达到灵枢升级上限
 	if lingshu_level == (hunyin_color * 25) or lingshu_level >= self:GetLingshuAttrMaxLevel(hunqi_index - 1, shengling_index - 1) then
 		return false
 	end
 	local current_lingshu_update_need = self:GetLingshuAttrByIndex(hunqi_index - 1, shengling_index - 1,lingshu_level).up_level_exp
	if current_lingshu_exp ~= 0 then
		if current_lingshu_exp >= current_lingshu_update_need then
			return true
		end
	end
	return false
end

function HunQiData:GetOtherCfg()
	return self.other_cfg
end

function HunQiData:GetHunQiXiLianOpenCfg(hunqi_id, slot_id)
	return self.xilian_open_cfg[hunqi_id][slot_id][1]
end

function HunQiData:GetHunQiXiLianShuXingType(hunqi_id, shuxing_type)
	if self.xilian_shuxing_type[hunqi_id][shuxing_type] then
		return self.xilian_shuxing_type[hunqi_id][shuxing_type][1]
	end
	return {}
end

function HunQiData:GetHunQiXiLianLockConsume(num)
	return self.xilian_lock_comsume[num + 1]
end

function HunQiData:GetHunQiXiLianFreeTimes()
	return self.day_free_xilian_times
end

function HunQiData:GetHunQiXiLianInfoById(hunqi_id)
	return self.xilian_data[hunqi_id]
end

function HunQiData:GetHunQiXiLianShuXingRange(hunqi_id, shuxing_type, shuxing_star)
	local cfg = self:GetHunQiXiLianShuXingType(hunqi_id, shuxing_type)
	local min_value = cfg["star_min_" .. shuxing_star - 1]
	local max_value = cfg["star_max_" .. shuxing_star - 1]
	return min_value, max_value
end

function HunQiData:GetHunQiXiLianTotalStarNumById(hunqi_id)
	local num = 0
	if not self.xilian_data[hunqi_id] then
		return num
	end
	for i,v in ipairs(self.xilian_data[hunqi_id].xilian_shuxing_star) do
		num = num + v
	end
	return num
end

function HunQiData:GetHunQiXiLianOpenConsume(hunqi_id, slot_id)
	if not self.xilian_data[hunqi_id] then
		return
	end
	local open_list = {}
	local cfg = self.xilian_open_cfg[hunqi_id - 1]
	local open_flag_info = self.xilian_data[hunqi_id].xilian_slot_open_falg
	local yet_open = -1
	for i,v in ipairs(open_flag_info) do
		if v == 1 then
			yet_open = 32 - i
			break
		end
	end
	local total_consume = 0
	for i = yet_open + 2, slot_id do
		total_consume = total_consume + cfg[i - 1][1].gold_cost
		table.insert(open_list, cfg[i - 1][1].slot_id)
	end
	return slot_id - (yet_open + 1), total_consume, open_list
end

function HunQiData:GetHunQiXiLianConsumeCfg()
	return self.xilian_xilian_comsume
end

function HunQiData:GetHunQiXiLianDefaultInfo()
	local stuff_cfg = {}
	local consume_cfg = self.xilian_xilian_comsume
	for i,v in ipairs(consume_cfg) do
		if v.comsume_color ~= HunQiData.XiLianStuffColor.FREE then
			local stuff_num = ItemData.Instance:GetItemNumInBagById(v.consume_item.item_id)
			if stuff_num > 0 then
				stuff_cfg = v
			end
		end
	end
	if not next(stuff_cfg) then
		stuff_cfg = consume_cfg[HunQiData.XiLianStuffColor.BLUE + 1]
	end
	return stuff_cfg
end

function HunQiData:GetHunQiXiLianStuffList()
	local consume_list = {}
	local consume_cfg = self.xilian_xilian_comsume
	for i,v in ipairs(consume_cfg) do
		if v.comsume_color ~= HunQiData.XiLianStuffColor.FREE then
			table.insert(consume_list, v)
		end
	end
	return consume_list
end

function HunQiData:GetHunQiXiLianSuitAttrById(hunqi_id)
	local star_num = self:GetHunQiXiLianTotalStarNumById(hunqi_id + 1)
	local cfg = self.xilian_suit[hunqi_id]
	local suit_index = 0
	for i,v in ipairs(cfg) do
		if star_num >= v.need_start_count then
			suit_index = i
		end
	end
	local cur_attr = {}
	local next_attr = {}
	if 0 == suit_index then
		cur_attr = nil
		next_attr = cfg[suit_index + 1]
	elseif #cfg == cur_attr then
		cur_attr = cfg[suit_index]
		next_attr = nil
	else
		cur_attr = cfg[suit_index]
		next_attr = cfg[suit_index + 1]
	end
	return cur_attr, next_attr
end

function HunQiData:GetHunQiXiLianHasRareById(hunqi_id)
	local has_rare = false
	local num = 0
	if not self.xilian_data[hunqi_id] then
		return has_rare
	end
	for i,v in ipairs(self.xilian_data[hunqi_id].xilian_shuxing_star) do
		if v >= 7 and not XiLianContentView.Instance:GetIsLockByIndex(i) then
			has_rare = true
			num = num + 1
		end
	end
	return has_rare, num
end

-- 洗练战力计算
function HunQiData:GetHunQiXiLianCapability(hunqi_id)
	local capability = 0
	local xilian_info = self.xilian_data[hunqi_id]
	if not xilian_info then
		return capability
	end

	local attr_base_list = {}
	local attr_hunqi_list = {}
	local attr_jianding_list = {}
	local suit_attr = {}
	for i = 1, HunQiData.SHENZHOU_XIlIAN_MAX_SLOT do
		local attr_open = xilian_info.xilian_slot_open_falg[33 - i]
		local attr_type = xilian_info.xilian_shuxing_type[i]
		local attr_value = xilian_info.xilian_shuxing_value[i]
		if 1 == attr_open then
			local attr_cfg = self:GetHunQiXiLianShuXingType(hunqi_id - 1, attr_type)
			local attr_name = Language.HunQi.XiLianAttr[attr_type]
			if not attr_name then
				return 0
			end
			if 1 == attr_cfg.shuxing_classify then
				if attr_base_list[attr_name] then
					attr_base_list[attr_name] = attr_base_list[attr_name] + attr_value
				else
					attr_base_list[attr_name] = attr_value
				end
			elseif 2 == attr_cfg.shuxing_classify then
				if attr_hunqi_list[attr_name] then
					attr_hunqi_list[attr_name] = attr_hunqi_list[attr_name] + attr_value
				else
					attr_hunqi_list[attr_name] = attr_value
				end
			else
				if attr_jianding_list[attr_name] then
					attr_jianding_list[attr_name] = attr_jianding_list[attr_name] + attr_value
				else
					attr_jianding_list[attr_name] = attr_value
				end
			end
		end
	end

	-- 基础属性
	attr_base_list = CommonDataManager.GetAttributteByClass(attr_base_list)
	-- 魂器百分比属性
	attr_hunqi_list = self:GetHunQiXiCapability(hunqi_id, attr_hunqi_list)
	-- 鉴定百分比属性
	attr_jianding_list = self:GetHunQiJianDingCapability(hunqi_id, attr_jianding_list)
    --套装属性
	suit_attr = self:GetHunQiXiLianSuitCapability(hunqi_id)

	local total_attr = CommonDataManager.AddAttributeAttr(attr_base_list, attr_hunqi_list)
	local total_attr2 = CommonDataManager.AddAttributeAttr(total_attr, attr_jianding_list)
	local total_attr3 = CommonDataManager.AddAttributeAttr(total_attr2, suit_attr)
	capability = CommonDataManager.GetCapability(total_attr3)
	return capability
end
-- 魂器属性计算
function HunQiData:GetHunQiXiCapability(hunqi_id, attr_hunqi_list)
	attr_hunqi_list = CommonDataManager.GetAttributteByClass(attr_hunqi_list)
	-- 魂器百分比属性
	if nil == self.hunqi_list then
		return attr_hunqi_list
	end

	local kapai_data_list = self.hunqi_list[hunqi_id].weapon_slot_level_list
	if nil == kapai_data_list then
		return attr_hunqi_list
	end

	local hunqi_attr_info = self:GetAllAttrInfo()

	for k,v in pairs(attr_hunqi_list) do
		if v > 0 then
			attr_hunqi_list[k] = hunqi_attr_info[k] * v / 10000
		end
	end
	return attr_hunqi_list
end

-- 鉴定属性计算
function HunQiData:GetHunQiJianDingCapability(hunqi_id, attr_jianding_list)
	attr_jianding_list = CommonDataManager.GetAttributteByClass(attr_jianding_list)
	local big_level = self:GetIdentifyLevel()
	local small_level = self:GetIdentifyStarLevel()
	local jian_ding_attr_info = HunQiData.Instance:GetidentifyLevelInfo(big_level, small_level)
	if nil == jian_ding_attr_info then
		return attr_jianding_list
	end
	jian_ding_attr_info = CommonDataManager.GetAttributteByClass(jian_ding_attr_info[1])

	for k,v in pairs(attr_jianding_list) do
		if v > 0 and jian_ding_attr_info[k] then
			attr_jianding_list[k] = jian_ding_attr_info[k] * v / 10000
		end
	end
	return attr_jianding_list
end

-- 魂器洗练套装属性计算
function HunQiData:GetHunQiXiLianSuitCapability(hunqi_id)
	local cur_attr, next_attr = HunQiData.Instance:GetHunQiXiLianSuitAttrById(hunqi_id - 1)
	local cur_add_per = 0
	if cur_attr then
		cur_add_per = cur_attr.add_per / 100
	end
	local total_attribute = CommonStruct.Attribute()
	for i = 1, HunQiData.SHENZHOU_WEAPON_COUNT  do
		local hunyin_data = self:GetHunYinListByIndex(i)
		for k, v in ipairs(hunyin_data) do
			-- 灵枢部分加成
			local data = self:GetLingshuAttrByIndex(i - 1, k - 1, v.lingshu_level)
			local attribute = CommonDataManager.MulAttribute(CommonDataManager.GetAttributteByClass(data), (cur_add_per / 100))
			total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)
			-- 魂印部分加成
			local hunyin_cfg = self.hunyin_info[v.hunyin_id]
			if hunyin_cfg then
				hunyin_cfg = hunyin_cfg[1]
				attribute = CommonDataManager.MulAttribute(CommonDataManager.GetAttributteByClass(hunyin_cfg), (cur_add_per / 100))
				total_attribute = CommonDataManager.AddAttributeAttr(total_attribute, attribute)
			end
		end
	end
	return total_attribute
end

function HunQiData:SetXiLianRedPoint(value)
	self.is_show_xilian_red = value
end

function HunQiData:GetXiLianRedPoint()
	return self.is_show_xilian_red
end

function HunQiData:InItXiLianStuffId()
	for i,v in ipairs(self.xilian_xilian_comsume) do
		if 0 ~= v.consume_item.item_id then
			self.xilian_stuff_list[v.consume_item.item_id] = v.consume_item.item_id
		end
	end
end

function HunQiData:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.xilian_stuff_list[item_id] then
		if new_num > old_num then
			self.is_show_xilian_red = true
			RemindManager.Instance:Fire(RemindName.HunQi_XiLian)
		end
	end
end

function HunQiData:GetHunYinCfg(index)
	local hunyin_get_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto").hunyin_get
	for k,v in pairs(hunyin_get_cfg) do
		if v.hunyin_slot == index then
			return v
		end
	end
end

function HunQiData:SetSpecialModle(modle_id)
	local display_name = "hunqi_content_panel"
	local id = tonumber(modle_id)
	for k,v in pairs(DISPLAYNAME) do
		if id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end

function HunQiData:SetSpecialHunyinInfo(protocol)
	self.special_hunyin_slot = protocol.special_hunyin_slot
end

function HunQiData:GetSpecialHunyinInfo(hunqi_index, special_slot_index)
	if self.special_hunyin_slot == nil
		or self.special_hunyin_slot[hunqi_index] == nil
		or self.special_hunyin_slot[hunqi_index][special_slot_index] == nil then
		return {}
	end
	return self.special_hunyin_slot[hunqi_index][special_slot_index] or {}
end

-- 判断特殊槽位是否开启, hunqi_index从1开始, slot_index从1开始
function HunQiData:GetSpecialShenYinIsOpen(hunqi_index, slot_index)
	if next(self.special_hunyin_open) == nil or hunqi_index == nil or slot_index == nil then
		return false
	end

	local hunqi_open_cfg = self.special_hunyin_open[hunqi_index - 1]
	if hunqi_open_cfg == nil then
		return false
	end
	local slot_open_cfg = hunqi_open_cfg[slot_index - 1]
	if slot_open_cfg == nil then
		return false
	end
	local slot_open_level = slot_open_cfg[1].role_level or 999
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	return slot_open_level <= main_role_vo.level
end

-- 获取背包中的彩色签文
function HunQiData:GetSpecialShenYinInBag()
	local special_hunyin_info = {}
	local special_hunqi_item_id_list = self:GetSpecialHunQiItemID()
	if special_hunqi_item_id_list == nil then
		return special_hunyin_info
	end

	for k, v in pairs(special_hunqi_item_id_list) do
		local count = ItemData.Instance:GetItemNumInBagById(v)
		if count > 0 then
			local group_count = math.ceil(count / 999)
			if group_count > 1 then
				for i=1, group_count - 1 do
					table.insert(special_hunyin_info, {item_id = v, num = 999, is_bind = 0 })
				end
				count = count % 999
				table.insert(special_hunyin_info, {item_id = v, num = count, is_bind = 0 })
			else
				table.insert(special_hunyin_info, {item_id = v, num = count, is_bind = 0 })
			end
		end
	end

	return special_hunyin_info
end

function HunQiData:SetSpecialHunQiItemID()
	self.special_hunqi_item_id_list = {}
	for k,v in pairs(self.hunyin_info) do
		if v[1].special_hunyin == 1 then
			table.insert(self.special_hunqi_item_id_list, k)
		end
	end
end

function HunQiData:GetSpecialHunQiItemID()
	if self.special_hunqi_item_id_list == nil then
		self:SetSpecialHunQiItemID()
	end

	return self.special_hunqi_item_id_list
end

function HunQiData:GetSpecialSlotPower(hunqi_index, special_hunyin_id)
	local hunyin_slot_list = self:GetHunYinListByIndex(hunqi_index)
	if next(hunyin_slot_list) == nil then
		return 0
	end

	local current_hunyi_info = self.hunyin_info[special_hunyin_id]
	if current_hunyi_info == nil then
		return 0
	end
	current_hunyi_info = current_hunyi_info[1]
	local addition = current_hunyi_info.attr_per_add

	-- 已镶嵌的基础战力
	local power = 0
	for k,v in pairs(hunyin_slot_list) do
		power = self:GetHunyinBasePowerByID(v.hunyin_id) * addition / 10000 + power
	end

	-- 特殊符文基础战力
	for i = 1, HunQiData.SPECIAL_SHENZHOU_WEAPON_SLOT_COUNT do
		local special_hunyin_info = self:GetSpecialHunyinInfo(hunqi_index, i)
		if next(special_hunyin_info) ~= nil then
			if special_hunyin_info.hunyin_id and special_hunyin_info.hunyin_id ~= nil then
				power = self:GetHunyinBasePowerByID(special_hunyin_info.hunyin_id) * addition / 10000 + power
			end
		end
	end

	local base_power = self:GetHunyinBasePowerByID(special_hunyin_id)

	return math.ceil(power + base_power)
end

function HunQiData:GetHunyinBasePowerByID(hunyin_id)
	local current_hunyi_info = self.hunyin_info[hunyin_id]
	if current_hunyi_info == nil then
		return 0
	end
	current_hunyi_info = current_hunyi_info[1]
	local all_attr_info = {}
	all_attr_info = CommonStruct.AttributeNoUnderline()
	all_attr_info.fangyu = current_hunyi_info.fangyu + all_attr_info.fangyu
	all_attr_info.baoji = current_hunyi_info.baoji + all_attr_info.baoji
	all_attr_info.jianren = current_hunyi_info.jianren + all_attr_info.jianren
	all_attr_info.mingzhong = current_hunyi_info.mingzhong + all_attr_info.mingzhong
	all_attr_info.maxhp = current_hunyi_info.maxhp + all_attr_info.maxhp
	all_attr_info.gongji = current_hunyi_info.gongji + all_attr_info.gongji
	all_attr_info.shanbi = current_hunyi_info.shanbi + all_attr_info.shanbi

	return CommonDataManager.GetCapabilityCalculation(all_attr_info)
end