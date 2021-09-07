HunQiData = HunQiData or BaseClass()

HunQiData.SHENZHOU_WEAPON_COUNT = 6								--魂器格子数量
HunQiData.SHENZHOU_WEAPON_SLOT_COUNT = 8						--魂器最大八卦牌数量
HunQiData.SHENZHOU_ELEMET_MAX_TYPE = 4							--魂器炼魂最大类型
HunQiData.SLOT_MAX_LEVEL = 100									--八卦牌最大等级
HunQiData.SHENZHOU_WEAPON_BOX_HELP_MAX_CONUT = 4				--最大协助数量
HunQiData.SHENZHOU_HUNYIN_MAX_SLOT = 8							--魂器镶嵌魂印数量
HunQiData.BAOZANG_HELP_NUM = 4									--魂器宝藏最大协助人数
HunQiData.SHENZHOU_XIlIAN_MAX_SLOT = 8							--魂器洗练最大个数
HunQiData.HUQI_WEAPON_COUNT = 8									--魂器数量

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
	SHENZHOU_REQ_TYPE_XILIAN_REQ = 16,                                      -- 请求洗练，param1 魂器类型， param2锁定槽0-7位表示1-8位属性, param3洗练材料类型,param4 是否自动购买, param5 是否免费
}

HunQiData.ElementItemList = {27501, 27502, 27503, 27504}

HunQiData.XiLianStuffColor = {
	FREE = 0,               -- 免费
	BLUE = 1,               -- 蓝
	PURPLE = 2,				-- 紫
	ORANGE = 3,				-- 橙
	RED = 4, 				-- 红
}

function HunQiData:__init()
	if nil ~= HunQiData.Instance then
		return
	end
	HunQiData.Instance = self

	--local hunqi_system_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto")
	--self.hunqi_slot_level_cfg = ListToMapList(hunqi_system_cfg.hunqi_slot_level_attr, "hunqi", "slot", "level")
	--self.identify_level_cfg = ListToMapList(hunqi_system_cfg.identify_level, "level", "star_level")
	--self.hunqi_skill_cfg = hunqi_system_cfg.hunqi_skill
	--self.hunqi_name_cfg = hunqi_system_cfg.hunqi_name
	--self.identify_item_cfg = hunqi_system_cfg.identify_item_cfg
	--self.exchange_identify_exp_cfg = hunqi_system_cfg.exchange_identify_exp
	--self.box_cfg = hunqi_system_cfg.box[1]
	--self.box_reward_count_cfg = hunqi_system_cfg.box_reward_count_cfg
	--self.other_cfg = hunqi_system_cfg.other[1]
	--self.box_reward_cfg = hunqi_system_cfg.box_reward
	--self.element_cfg = ListToMapList(hunqi_system_cfg.element_cfg, "hunqi", "element_type", "element_level")
	--self.element_name_cfg = hunqi_system_cfg.element_name
	--self.hunyin_info = ListToMapList(hunqi_system_cfg.hunyin, "hunyin_id")
	--self.hunyin_suit_cfg = hunqi_system_cfg.hunyin_suit
	--self.hunyin_all =  hunqi_system_cfg.hunyin_all
	--self.lingshu_info = ListToMapList(hunqi_system_cfg.lingshu, "hunqi_id", "hunyin_slot", "slot_level")
	--self.hunyin_get = hunqi_system_cfg.hunyin_get
	--self.hunyin_slot_open = hunqi_system_cfg.hunyin_slot_open
	--self.all_item_cfg = ConfigManager.Instance:GetAutoConfig("item/other_auto")!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--self.gift_item_cfg = ConfigManager.Instance:GetAutoConfig("item/gift_auto")!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--self.xilian_open_cfg = ListToMapList(hunqi_system_cfg.xilian_open, "hunqi_id", "slot_id")
	--self.xilian_shuxing_type = ListToMapList(hunqi_system_cfg.xilian_shuxing_type, "hunqi_id", "shuxing_type")
	--self.xilian_xilian_comsume = hunqi_system_cfg.xilian_comsume
	--self.xilian_suit = ListToMapList(hunqi_system_cfg.xilian_suit, "hunqi_id")
	self.xilian_stuff_list = {}
	--self.xilian_lock_comsume = hunqi_system_cfg.lock_comsume
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
	self.current_select_page = 1

	RemindManager.Instance:Register(RemindName.HunYin_Inlay, BindTool.Bind(self.CalcHunYinInlayRedPoint, self))
	RemindManager.Instance:Register(RemindName.HunYin_LingShu, BindTool.Bind(self.CalcHunYinLingShuRedPoint, self))
	RemindManager.Instance:Register(RemindName.HunQiRemind, BindTool.Bind(self.GetHunQiRemind, self))
	RemindManager.Instance:Register(RemindName.HunYinRemind, BindTool.Bind(self.CalcKaiLingRedPoint, self))
	RemindManager.Instance:Register(RemindName.Gatheremind, BindTool.Bind(self.GetGatheremind, self))
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function HunQiData:__delete()
	RemindManager.Instance:UnRegister(RemindName.HunYin_Inlay)
	RemindManager.Instance:UnRegister(RemindName.HunYin_LingShu)
	RemindManager.Instance:UnRegister(RemindName.HunQiRemind)
	RemindManager.Instance:UnRegister(RemindName.HunYinRemind)
	RemindManager.Instance:UnRegister(RemindName.Gatheremind)


	if nil ~= HunQiData.Instance then
		HunQiData.Instance = nil
	end
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function HunQiData:GetHunQiCfg()
	return ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto") or {}
end

function HunQiData:GetAllItemCfg()
	return ConfigManager.Instance:GetAutoConfig("item/other_auto") or {}
end

function HunQiData:GetGiftItemCfg()
	return ConfigManager.Instance:GetAutoConfig("item/gift_auto") or {}
end

function HunQiData:GetHunQiSlotLevelCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.hunqi_slot_level_cfg then
		self.hunqi_slot_level_cfg = ListToMapList(hunqi_system_cfg.hunqi_slot_level_attr, "hunqi", "slot")
	end
	return self.hunqi_slot_level_cfg
end

function HunQiData:GetIdentifyLevelCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.identify_level_cfg then
		self.identify_level_cfg = ListToMapList(hunqi_system_cfg.identify_level, "level", "star_level")
	end
	return self.identify_level_cfg
end

function HunQiData:GetHunQiSkillCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.hunqi_skill_cfg then
		self.hunqi_skill_cfg = hunqi_system_cfg.hunqi_skill
	end
	return self.hunqi_skill_cfg
end

function HunQiData:GetHunQiNameCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.hunqi_name_cfg then
		self.hunqi_name_cfg = hunqi_system_cfg.hunqi_name
	end
	return self.hunqi_name_cfg
end

function HunQiData:GetIdentifyItemCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.identify_item_cfg then
		self.identify_item_cfg = hunqi_system_cfg.identify_item_cfg
	end
	return self.identify_item_cfg
end

function HunQiData:GetExchangeIdentifyExpCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.exchange_identify_exp_cfg then
		self.exchange_identify_exp_cfg = hunqi_system_cfg.exchange_identify_exp
	end
	return self.exchange_identify_exp_cfg
end

function HunQiData:GetBoxCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.box_cfg then
		self.box_cfg = hunqi_system_cfg.box[1]
	end
	return self.box_cfg
end

function HunQiData:GetBoxRewardCount()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.box_reward_count_cfg then
		self.box_reward_count_cfg = hunqi_system_cfg.box_reward_count_cfg
	end
	return self.box_reward_count_cfg
end

function HunQiData:GetOtherCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.other_cfg then
		self.other_cfg = hunqi_system_cfg.other[1]
	end
	return self.other_cfg
end

function HunQiData:GetBoxRewardCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.box_reward_cfg then
		self.box_reward_cfg = hunqi_system_cfg.box_reward
	end
	return self.box_reward_cfg
end

function HunQiData:GetElementCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.element_cfg then
		self.element_cfg = ListToMapList(hunqi_system_cfg.element_cfg, "hunqi", "element_type", "element_level")
	end
	return self.element_cfg
end

function HunQiData:GetElementNameCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.element_name_cfg then
		self.element_name_cfg = hunqi_system_cfg.element_name
	end
	return self.element_name_cfg
end

function HunQiData:GetHunYinInfo()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.hunyin_info then
		self.hunyin_info = ListToMapList(hunqi_system_cfg.hunyin, "hunyin_id")
	end
	return self.hunyin_info
end

function HunQiData:GetHunYinSuitCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.hunyin_suit_cfg then
		self.hunyin_suit_cfg = hunqi_system_cfg.hunyin_suit
	end
	return self.hunyin_suit_cfg
end

function HunQiData:GetHunYinAll()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.hunyin_all then
		self.hunyin_all =  hunqi_system_cfg.hunyin_all
	end
	return self.hunyin_all
end

function HunQiData:GetLingShuInfo()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.lingshu_info then
		self.lingshu_info = ListToMapList(hunqi_system_cfg.lingshu, "hunqi_id", "hunyin_slot", "slot_level")
	end
	return self.lingshu_info
end

function HunQiData:GetHunYinGet()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.hunyin_get then
		self.hunyin_get = hunqi_system_cfg.hunyin_get
	end
	return self.hunyin_get
end

function HunQiData:GetHunYinSlotOpen()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.hunyin_slot_open then
		self.hunyin_slot_open = hunqi_system_cfg.hunyin_slot_open
	end
	return self.hunyin_slot_open
end

function HunQiData:GetXiLianOpenCfg()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.xilian_open_cfg then
		self.xilian_open_cfg = ListToMapList(hunqi_system_cfg.xilian_open, "hunqi_id", "slot_id")
	end
	return self.xilian_open_cfg
end

function HunQiData:GetXiLianShuXingType()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.xilian_shuxing_type then
		self.xilian_shuxing_type = ListToMapList(hunqi_system_cfg.xilian_shuxing_type, "hunqi_id", "shuxing_type")
	end
	return self.xilian_shuxing_type
end

function HunQiData:GetXiLianComsume()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.xilian_xilian_comsume then
		self.xilian_xilian_comsume = hunqi_system_cfg.xilian_comsume
	end
	return self.xilian_xilian_comsume
end

function HunQiData:GetXiLianSuit()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.xilian_suit then
		self.xilian_suit = ListToMapList(hunqi_system_cfg.xilian_suit, "hunqi_id")
	end
	return self.xilian_suit
end

function HunQiData:GetXiLianLockConsume()
	local hunqi_system_cfg = self:GetHunQiCfg()
	if nil == self.xilian_lock_comsume then
		self.xilian_lock_comsume = hunqi_system_cfg.lock_comsume
	end
	return self.xilian_lock_comsume
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
	if nil == self:GetOtherCfg() then
		return times
	end
	local max_help_times = self:GetOtherCfg().box_help_num_limit
	times = max_help_times - self.today_help_box_num
	return times
end

--获取宝箱最大免费开启次数
function HunQiData:GetMaxFreeBoxTimes()
	local times = 0
	if nil == self:GetOtherCfg() then
		return times
	end
	return self:GetOtherCfg().box_free_times
end

--获取宝箱免费开启的cd时间
function HunQiData:GetFreeBoxCD()
	local cd = 0
	if nil == self:GetOtherCfg() then
		return cd
	end
	return self:GetOtherCfg().box_free_times_cd
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

function HunQiData:GetBoxRewardCountCfg()
	if nil == self:GetBoxRewardCount() then
		return nil
	end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg = nil
	for k, v in ipairs(self:GetBoxRewardCount()) do
		if role_level >= v.level then
			cfg = v
		end
	end
	return cfg
end

--获取魂器红点
function HunQiData:CalcHunQiRedPoint()
	local flag = 0
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
	return flag
end

--获取宝藏红点
function HunQiData:CalcBaoZangRedPoint()
	local flag = 0
	--先判断是否有免费次数
	-- if self.today_open_free_box_times < self:GetMaxFreeBoxTimes() then
	-- 	local server_time = TimeCtrl.Instance:GetServerTime()
	-- 	local times = server_time - self.last_open_free_box_timestamp
	-- 	--再判断是否在cd时间内
	-- 	if times >= self:GetFreeBoxCD() then
	-- 		flag = 1
	-- 	end
	-- end

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
		local attr_data = self:GetSlotAttrByLevel(hunqi_index - 1, k - 1, v)
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
			local attr_data = self:GetSlotAttrByLevel(k - 1, i - 1, j)
			if nil ~= attr_data then
				attr_data = attr_data[1]
				attr_data = CommonDataManager.GetAttributteByClass(attr_data)
				all_attr_info = CommonDataManager.AddAttributeAttr(all_attr_info, attr_data)
			end
		end
	end
	return all_attr_info
end

-- 获取魂器current_select_hunqi属性列表
function HunQiData:GetHunQiAttrByIndex(current_select_hunqi)
	local attr_info = CommonStruct.Attribute()
	if nil == self.hunqi_list then
		return attr_info
	end
	local hunqi_cfg = self.hunqi_list[current_select_hunqi]
	local kapai_data_list = hunqi_cfg.weapon_slot_level_list
	for i, j in ipairs(kapai_data_list) do
		local attr_data = self:GetSlotAttrByLevel(current_select_hunqi - 1, i - 1, j)
		if nil ~= attr_data then
			attr_data = attr_data[1]
			attr_data = CommonDataManager.GetAttributteByClass(attr_data)
			attr_info = CommonDataManager.AddAttributeAttr(attr_info, attr_data)
		end
	end
	return attr_info
end

-- 获取魂器current_select_hunqi属性1级属性列表
function HunQiData:GetHunQiAttrByOne(current_select_hunqi)
	local attr_info = CommonStruct.Attribute()
	if nil == self.hunqi_list then
		return attr_info
	end
	local hunqi_cfg = self.hunqi_list[current_select_hunqi]
	local kapai_data_list = hunqi_cfg.weapon_slot_level_list
	for i, j in ipairs(kapai_data_list) do
		local attr_data = self:GetSlotAttrByLevel(current_select_hunqi - 1, i - 1, 1)
		if nil ~= attr_data then
			attr_data = attr_data[1]
			attr_data = CommonDataManager.GetAttributteByClass(attr_data)
			attr_info = CommonDataManager.AddAttributeAttr(attr_info, attr_data)
		end
	end
	return attr_info
end

--获取对应魂器八卦牌的属性
function HunQiData:GetSlotAttrByLevel(hunqi, slot, level)
	if nil == self:GetHunQiSlotLevelCfg() or nil == self:GetHunQiSlotLevelCfg()[hunqi] or nil == self:GetHunQiSlotLevelCfg()[hunqi][slot] then
		return nil
	end

	local tab = TableCopy(self:GetHunQiSlotLevelCfg()[hunqi][slot])
	for k,v in pairs(CommonDataManager.AttrViewList) do
		if tab[1] ~= nil and tab[1][v] ~= nil and tab[1][v] ~= 0 then
			tab[1][v] = tab[1][v] * level
		end
	end
	return tab
end

function HunQiData:GetidentifyLevelInfo(level, star_level)
	if nil == self:GetIdentifyLevelCfg() or nil == self:GetIdentifyLevelCfg()[level] then
		return nil
	end
	return self:GetIdentifyLevelCfg()[level][star_level]
end

-- 获取属性值大于零的属性并且排序
function HunQiData:GetSloatAndSortAttr(slotAttr, next_data)
	local curr_data,flag = self:GetHunQiAttrValue(slotAttr)
	if flag then
		if nil == next_data then
			return curr_data
		end
		local next_attr_data,flag = self:GetHunQiAttrValue(next_data)
		-- 下级属性显示
		for k, v in pairs(next_attr_data) do
			next_attr_data[k] = v
		end
		local sort_data = self:SortAttrTable(next_attr_data)

		return sort_data, true
	else
		local sort_data = self:SortAttrTable(curr_data)

		return sort_data, false
	end
end

-- 获取属性值
function HunQiData:GetNextSloatAttr(slotAttr)
	local next_attr_data = self:GetHunQiAttrValue(slotAttr)
	-- 下级属性显示
	for k, v in pairs(next_attr_data) do
		next_attr_data[k] = 0
	end
	return next_attr_data
end


-- 获取属性值大于零的属性
function HunQiData:GetSloatAttr(slotAttr,next_data)
	local curr_data,flag = self:GetHunQiAttrValue(slotAttr)
	if flag then
		if nil == next_data then
			return curr_data
		end
		local next_attr_data,flag = self:GetHunQiAttrValue(next_data)
		-- 下级属性显示
		for k, v in pairs(next_attr_data) do
			next_attr_data[k] = v
		end
		return next_attr_data
	else
		return curr_data
	end
end

-- 对属性值进行排序
function HunQiData:SortAttrTable(attr_table)
	local temp_tab = {}
	if nil ~= attr_table then
		for k, v in pairs(attr_table) do
			local temp_index = Language.HunQi.AttrNameIndex[k]
			local tab = {}
			tab[k] = v
			temp_tab[temp_index] = tab
		end
	end
	local tab_index = 1
	local result_tab = {}
	for i = 1, 12 do
		if temp_tab[i] then
			result_tab[tab_index] = temp_tab[i]
			tab_index = tab_index + 1
		end
	end
 	return result_tab
end

function HunQiData:GetHunQiAttrValue(attr_data)
	local attr_info = CommonStruct.Attribute()
	if nil == attr_data then
		return attr_info, true
	end
	-- 属性值大于零
	local result_attr = {}
	-- 属性值小于等于零
	local min_attr = {}
	-- 属性值大于零的数目
	local result_count = 0

	local array_attr = {}
	array_attr[Language.HunQi.AttrName.hp] = attr_data.maxhp or attr_data.max_hp
	array_attr[Language.HunQi.AttrName.gongji] = attr_data.gongji or attr_data.gong_ji
	array_attr[Language.HunQi.AttrName.fangyu] = attr_data.fangyu or attr_data.fang_yu
	array_attr[Language.HunQi.AttrName.mingzhong] = attr_data.mingzhong or attr_data.ming_zhong
	array_attr[Language.HunQi.AttrName.shanbi] = attr_data.shanbi or attr_data.shan_bi
	array_attr[Language.HunQi.AttrName.baoji] = attr_data.baoji or attr_data.bao_ji
	array_attr[Language.HunQi.AttrName.jianren] = attr_data.jianren or  attr_data.jian_ren
	if attr_data.ice_master then
		array_attr[Language.HunQi.AttrName.ice_master] = attr_data.ice_master
	end
	if attr_data.fire_master then
		array_attr[Language.HunQi.AttrName.fire_master] = attr_data.fire_master
	end
	if attr_data.thunder_master then
		array_attr[Language.HunQi.AttrName.thunder_master] = attr_data.thunder_master
	end
	if attr_data.poison_master then
		array_attr[Language.HunQi.AttrName.poison_master] = attr_data.poison_master
	end
	if attr_data.ignore_fangyu then
		array_attr[Language.HunQi.AttrName.ignore_fangyu] = attr_data.ignore_fangyu
	end
	local total_value = 0
	for k,v in pairs(array_attr) do
		if v > 0 then
			result_attr[k] = v
			result_count = result_count + 1
		else
			min_attr[k] = v
		end
		total_value = total_value + v
	end

	-- 需要4条属性
	-- if result_count < 4 then
	-- 	local que_count = 4 - result_count
	-- 	for k, v in pairs(min_attr) do
	-- 		result_attr[k] = v
	-- 		que_count = que_count - 1
	-- 		if que_count <= 0 then
	-- 			break
	-- 		end
	-- 	end
	-- end

	if total_value <= 0 then
		return result_attr, true
	end

	return result_attr, false
end
--获取魂器名字和颜色
function HunQiData:GetHunQiNameAndColorByIndex(hunqi_index)
	local name = ""
	local color = GameEnum.ITEM_COLOR_WHITE
	if nil == self:GetHunQiNameCfg() then
		return name, color
	end
	for k, v in ipairs(self:GetHunQiNameCfg()) do
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
	if nil == self:GetHunQiNameCfg() then
		return skill_name
	end
	for k, v in ipairs(self:GetHunQiNameCfg()) do
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
	if nil == self:GetHunQiNameCfg() then
		return res_id
	end
	for k, v in ipairs(self:GetHunQiNameCfg()) do
		if v.hunqi == hunqi_index then
			res_id = v.res_id or 0
			break
		end
	end
	return res_id
end

--获取魂器特效的资源id
function HunQiData:GetHunQiEffectIdByIndex(hunqi_index)
	local effect_str = string.format(Language.HunQi.HunqiEffectString, 1)
	if nil == self:GetHunQiNameCfg() then
		return effect_str
	end
	for k, v in ipairs(self:GetHunQiNameCfg()) do
		if v.hunqi == hunqi_index then
			effect_str = string.format(Language.HunQi.HunqiEffectString, v.effect)
			return effect_str
		end
	end
	return effect_str
end

function HunQiData:GetHunqiEffectTab()
	local result_tab = {}
	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
		result_tab[i + 1] = self:GetHunQiEffectIdByIndex(i)
	end
	return result_tab
end

function HunQiData:GetHunQiSkillResIdByIndex(hunqi_index)
	local res_id = 0
	if nil == self:GetHunQiNameCfg() then
		return res_id
	end
	for k, v in ipairs(self:GetHunQiNameCfg()) do
		if v.hunqi == hunqi_index then
			res_id = v.skill_img or 0
			break
		end
	end
	return res_id
end

--获取对应的技能信息
function HunQiData:GetSkillInfoByIndex(hunqi_index, level, is_next)
	if nil == self:GetHunQiSkillCfg() then
		return nil
	end

	for k, v in ipairs(self:GetHunQiSkillCfg()) do
		if hunqi_index == v.hunqi then
			if level == v.level then
				if is_next then
					local skill_info = self:GetHunQiSkillCfg()[k+1]
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
					return self:GetHunQiSkillCfg()[k-1]
				end
			end
		end
	end
end

--返回魂器图标名称等信息表
function HunQiData:GetHunQiNameTable()
	return self:GetHunQiNameCfg()
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
	return self:GetIdentifyItemCfg()
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
	return self:GetExchangeIdentifyExpCfg()
end

--获取当前经验
function HunQiData:GetNowExp()
	return self.identify_exp
end

function HunQiData:GetTodayLeftGatherTimes()
	local left_times = 0
	if nil == self:GetOtherCfg() then
		return left_times
	end
	local total_count = self:GetOtherCfg().role_day_gather_num + self.today_buy_gather_times
	left_times = total_count - self.today_gather_times
	return left_times
end

--获取单个魂魄的属性列表
function HunQiData:GetSoulAttrInfo(hunqi, element_type, element_level)
	if nil == self:GetElementCfg() or nil == self:GetElementCfg()[hunqi] or nil == self:GetElementCfg()[hunqi][element_type] then
		return nil
	end
	return self:GetElementCfg()[hunqi][element_type][element_level]
end

--获取下一个有增加属性百分比的属性列表
function HunQiData:GetNextAddAttrInfo(hunqi, element_type, element_level)
	if nil == self:GetElementCfg() or nil == self:GetElementCfg()[hunqi] or nil == self:GetElementCfg()[hunqi][element_type] then
		return nil
	end
	for k, v in pairs(self:GetElementCfg()[hunqi][element_type]) do
		if k > element_level then
			local attr_info = self:GetElementCfg()[hunqi][element_type][element_level]
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
	if nil == self:GetElementNameCfg() then
		return name
	end

	for k, v in ipairs(self:GetElementNameCfg()) do
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
				local attr_info = self:GetSoulAttrInfo(k1 - 1, k2 - 1, v2)
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

--获取魂器聚魂1级总属性(包括特殊属性)hunqi_index从1开始
function HunQiData:GetAllElementAttrOneInfo(hunqi_index)
	if nil == self.hunqi_list then
		return nil
	end

	local attr_list = CommonStruct.Attribute()
	local special = 0
	for k1, v1 in ipairs(self.hunqi_list) do
		if hunqi_index == k1 then
			local element_level_list = v1.element_level_list
			for k2, v2 in ipairs(element_level_list) do
				local attr_info = self:GetSoulAttrInfo(k1 - 1, k2 - 1, 1)
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
	if self.hunqi_list and nil ~= self.hunqi_list[hunqi_index].hunyin_slot_list then
		hunyin_slot_list = self.hunqi_list[hunqi_index].hunyin_slot_list
	end
	return hunyin_slot_list
end

--灵枢经验
function HunQiData:GetLingshuExp()
	return self.lingshu_exp or 0
end

function HunQiData:GetCurrentHunYinSuitLevel(hunqi_index)
	return self.hunqi_list[hunqi_index].hunyin_suit_level or 0
end

function HunQiData:GetHunQiInfo()
	return self:GetHunYinInfo() or {}
end

function HunQiData:IsHunyinItem(item_id)
 	return nil ~= self:GetHunYinInfo()[item_id]
end

function HunQiData:GetHunYinSuitCfgByIndex(index)
	local data = {}
	if nil ~= self:GetHunYinSuitCfg() then
		for k,v in pairs(self:GetHunYinSuitCfg()) do
			if v.hunqi_id == index then
			 table.insert(data, v)
			end
		end
	end
	return data
end

function HunQiData:GetHunYinAllInfo()
	return self:GetHunYinAll() or {}
end

--根据等级 魂器ID取得灵枢属性
function HunQiData:GetLingshuAttrByIndex(hunqi, solt, level)
	return self:GetLingShuInfo()[hunqi][solt][level][1] or {}
end

function HunQiData:IsHunYinLockAndNeedLevel(hunqi_id, hunyin_id)
	hunqi_id = hunqi_id - 1
	local current_hunyin_open_list = {}
	for k,v in pairs(self:GetHunYinSlotOpen()) do
	 	if hunqi_id == v.hunqi then
	 		table.insert(current_hunyin_open_list, v)
	 	end
	end
	local need_level = current_hunyin_open_list[hunyin_id].open_hunqi_level
	return self:GetHunQiLevelByIndex(hunqi_id) < need_level, need_level
end

--获取魂印对应icon
function HunQiData:GetHunYinItemIconId(item_id)
	if nil ~= self:GetAllItemCfg()[item_id] then
		return self:GetAllItemCfg()[item_id].icon_id
	else
		return 0
	end
end

function HunQiData:GetGiftItemIconId(item_id)
	if nil ~= self:GetGiftItemCfg()[item_id] then
		return self:GetGiftItemCfg()[item_id].icon_id
	else
		return 0
	end
end

function HunQiData:GetHunQiHunYinOpenLevel(hunqi_index)
	for k,v in pairs(self:GetHunYinSlotOpen()) do
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

-- 魂器红点
function HunQiData:GetHunQiRemind()
	if not OpenFunData.Instance:CheckIsHide("hunqi") then
		return 0
	end
	local hunqi_list = self:GetHunQiList()
	if nil == hunqi_list then
		return 0
	end
	-- 魂器
 	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
 		local kapai_level_list = hunqi_list[i + 1].weapon_slot_level_list
		if nil == kapai_level_list then
			return 0
		end
 		-- 魂器的卡牌
 		for k = 0, 7 do
 			local kapai_level = kapai_level_list[k + 1]
 			if nil ~= kapai_level and kapai_level < HunQiData.SLOT_MAX_LEVEL then
				local kapai_data = self:GetSlotAttrByLevel(i, k, kapai_level)
				if nil ~= kapai_data then
					kapai_data = kapai_data[1]
					local up_level_item_data = kapai_data.up_level_item
					local now_item_num = ItemData.Instance:GetItemNumInBagById(up_level_item_data.item_id)
					if now_item_num >= up_level_item_data.num then
						return 1
					end
				end
			end
 		end
 	end
	return 0
end

function HunQiData:GetHunYinRemind()

	return 1
end

-- 聚魂红点
function HunQiData:GetGatheremind()
	if not OpenFunData.Instance:CheckIsHide("hunqi") then
		return 0
	end
	local hunqi_list = self:GetHunQiList()
	if nil == hunqi_list then
		return 0
	end
	-- 魂器
 	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
 		local element_level_list = hunqi_list[i + 1].element_level_list
		if nil == element_level_list then
			return 0
		end
 		for k = 1, 4 do
 			local next_attr_info = self:GetSoulAttrInfo(i, k - 1, element_level_list[k] + 1)
			if nil ~= next_attr_info then
			 	local attr_info = self:GetSoulAttrInfo(i, k - 1, element_level_list[k])
				if nil == attr_info then
					return 0
				end
				attr_info = attr_info[1]
				if hunqi_list[i + 1].weapon_level >= attr_info.huqi_level_limit then
					local up_level_item = attr_info.up_level_item
					local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
					if have_num >= up_level_item.num then
						return 1
					end
				end
			end
 		end
 	end
	return 0
end

-- 计算镶嵌红点
function HunQiData:CalcHunYinInlayRedPoint()
	if not OpenFunData.Instance:CheckIsHide("hunqi") then
		return 0
	end
	local flag = 0
	for j=1,HunQiData.HUQI_WEAPON_COUNT do
		for i=1, 8 do
			if self:CalcShenglingInlayCellInlayRedPoint(i, j) then
				flag = 1
				break
			end
		end
	end
	return flag
end

function HunQiData:CalcKaiLingRedPoint()
	if not OpenFunData.Instance:CheckIsHide("hunqi") then
		return 0
	end
	local lingshu = HunQiData.Instance:CalcHunYinLingShuRedPoint()
	if lingshu ~= nil and lingshu == 1 then
		return lingshu
	end

	local inlay = HunQiData.Instance:CalcHunYinInlayRedPoint()
	if inlay ~= nil and inlay == 1 then
		return inlay
	end
	return 0
end
-- 计算灵枢升级红点
function HunQiData:CalcHunYinLingShuRedPoint()
	if not OpenFunData.Instance:CheckIsHide("hunqi") then
		return 0
	end
	local flag = 0
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

	for i,v in ipairs(self:GetXiLianComsume()) do
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

--计算魂器按钮红点
function HunQiData:CalcHunQiBtnRedPoint(hunqi_index)
	--如果是镶嵌
	if self.hunyin_is_inlay then
		for i=1,8 do
			if self:CalcShenglingInlayCellInlayRedPoint(i, hunqi_index) then
				return true
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

function HunQiData:GetHunQIListRedPoint()
	local show_list_red_point = {}
	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
		show_list_red_point[i] = false
 	end
 	for i = 1, HunQiData.HUQI_WEAPON_COUNT do
 		-- 魂器的卡牌
 		for k = 1, 8 do
 			local num = self:GetCurrenSelectPage()
 			if num ~= nil and num == 1 then
 				if self:CalcShenglingInlayCellInlayRedPoint(k, i) then
					show_list_red_point[i - 1] = true
				end
			elseif num ~= nil and num == 2 then
				if self:ShowLingShuUpdateRep(k,i) then
					show_list_red_point[i - 1] = true
				end
 			end
 		end
 	end
 	return show_list_red_point
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
	if current_hunyin_id == nil then
		return false
	end
	local bag_hunyin_info = {}
	local item_id_list = {}
	for k,v in pairs(self:GetHunYinInfo()) do
		table.insert(item_id_list, k)
	end
	for k, v in pairs(item_id_list) do
		local count = ItemData.Instance:GetItemNumInBagById(v)
		local solt_index = self:GetHunYinInfo()[v][1].inlay_slot + 1
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
			if self:GetHunYinInfo()[v.item_id] and self:GetHunYinInfo()[current_hunyin_id] then
				if v.solt_index == index and self:GetHunYinInfo()[v.item_id][1].hunyin_color > self:GetHunYinInfo()[current_hunyin_id][1].hunyin_color then
					return true
				end
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
	if current_lingshu_exp ~= nil then
		local current_lingshu_info = self:GetHunYinListByIndex(hunqi_index)[shengling_index]
		if current_lingshu_info ~= nil then
			local lingshu_level = current_lingshu_info.lingshu_level
 			local hunyin_id = current_lingshu_info.hunyin_id
 			if hunyin_id == 0 or nil == self:GetHunYinInfo()[hunyin_id] then
 				return false
 			end
 			local hunyin_color = self:GetHunYinInfo()[hunyin_id][1].hunyin_color
 			--是否达到灵枢升级上限
 			if lingshu_level == 25 then
 				return false
 			end
 			local current_lingshu_update_need = self:GetLingshuAttrByIndex(hunqi_index - 1, shengling_index - 1,lingshu_level).up_level_exp
			if current_lingshu_exp ~= 0 then
				if current_lingshu_exp >= current_lingshu_update_need then
					return true
				end
			end
		end

	end

	return false
end

-- 获取某魂器魂印属性
function HunQiData:GetHunYinDataAttr(HunyinData)
	local attr_info = CommonStruct.Attribute()
	if nil == HunyinData then
		return attr_info
	end
	for k, v in pairs(HunyinData) do
		if v.hunyin_id > 0 then
			local attr_data = self:GetHunYinInfo()[v.hunyin_id][1]
			attr_data = CommonDataManager.GetAttributteByClass(attr_data)
			attr_info = CommonDataManager.AddAttributeAttr(attr_info, attr_data)
		end
	end
	return attr_info
end


-- 获取魂器的名字
function HunQiData:GetHunQiName()
	return self:GetHunQiNameCfg()
end

function HunQiData:GetHunQiXiLianOpenCfg(hunqi_id, slot_id)
	return self:GetXiLianOpenCfg()[hunqi_id][slot_id][1]
end

function HunQiData:GetHunQiCfgBySeq(seq)
	return self:GetXiLianOpenCfg()[seq] or {}
end
--	属性分类固定数值
function HunQiData:GetHunQiXiLianShuXingType(hunqi_id, shuxing_type)
	if self:GetXiLianShuXingType()[hunqi_id][shuxing_type] then
		return self:GetXiLianShuXingType()[hunqi_id][shuxing_type][1]
	end
	return {}
end

function HunQiData:GetHunQiXiLianLockConsume(num)
	return self:GetXiLianLockConsume()[num + 1]
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

--根据选择的美人id，获取美人总共的星星
function HunQiData:GetHunQiXiLianTotalStarNumById(hunqi_id)
	local num = 0
	if not self.xilian_data[hunqi_id] then
		return num
	end
	for i,v in ipairs(self.xilian_data[hunqi_id].xilian_shuxing_star) do 	--所有已开启的属性星数累加
		num = num + v
	end
	return num
end

function HunQiData:GetHunQiXiLianOpenConsume(hunqi_id, slot_id)
	if not self.xilian_data[hunqi_id] then
		return
	end
	local open_list = {}
	local cfg = self:GetXiLianOpenCfg()[hunqi_id - 1]
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
	return self:GetXiLianComsume()
end

function HunQiData:GetHunQiXiLianDefaultInfo()
	local stuff_cfg = {}
	local consume_cfg = self:GetXiLianComsume()
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
	local consume_cfg = self:GetXiLianComsume()
	for i,v in ipairs(consume_cfg) do
		if v.comsume_color ~= HunQiData.XiLianStuffColor.FREE then
			table.insert(consume_list, v)
		end
	end
	return consume_list
end

function HunQiData:GetHunQiXiLianSuitAttrById(hunqi_id)
	local star_num = self:GetHunQiXiLianTotalStarNumById(hunqi_id + 1)
	local cfg = self:GetXiLianSuit()[hunqi_id]
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

-- 洗练战力计算
function HunQiData:GetHunQiXiLianCapability(hunqi_id)
	local capability = 0
	local xilian_info = self.xilian_data[hunqi_id]
	if not xilian_info then
		return capability
	end

	local attr_base_list = {}
	local attr_jinjie_list = {}
	local attr_shengji_list = {}
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
				if attr_jinjie_list[attr_name] then
					attr_jinjie_list[attr_name] = attr_jinjie_list[attr_name] + attr_value
				else
					attr_jinjie_list[attr_name] = attr_value
				end
			else
				if attr_shengji_list[attr_name] then
					attr_shengji_list[attr_name] = attr_shengji_list[attr_name] + attr_value
				else
					attr_shengji_list[attr_name] = attr_value
				end
			end
		end
	end

	-- 基础属性
	attr_base_list = CommonDataManager.GetAttributteByClass(attr_base_list)
	-- 进阶属性
	attr_jinjie_list = self:GetHunQiXiCapability(hunqi_id, attr_jinjie_list)
	-- 升级属性
	attr_shengji_list = self:GetHunQiJianDingCapability(hunqi_id, attr_shengji_list)

	local total_attr = CommonDataManager.AddAttributeAttr(attr_base_list, attr_jinjie_list)
	local total_attr2 = CommonDataManager.AddAttributeAttr(total_attr, attr_shengji_list)
	capability = CommonDataManager.GetCapability(total_attr2)
	return capability
end
-- 魂器属性计算 进阶
function HunQiData:GetHunQiXiCapability(hunqi_id, attr_hunqi_list)
	attr_hunqi_list = CommonDataManager.GetAttributteByClass(attr_hunqi_list)

	local info = BeautyData.Instance:GetBeautyInfo()[hunqi_id]
	local hunqi_attr_info = BeautyData.Instance:GetBeautyUpgrade(hunqi_id - 1, info.grade > 0 and info.grade or 1)
	if nil == hunqi_attr_info then
		return hunqi_attr_info
	end
	hunqi_attr_info = CommonDataManager.GetAttributteByClass(hunqi_attr_info)
	for k,v in pairs(attr_hunqi_list) do
		if v > 0 then
			attr_hunqi_list[k] = hunqi_attr_info[k] * v / 10000
		end
	end
	return attr_hunqi_list
end

-- 鉴定属性计算 升级
function HunQiData:GetHunQiJianDingCapability(hunqi_id, attr_jianding_list)
	attr_jianding_list = CommonDataManager.GetAttributteByClass(attr_jianding_list)
	local info = BeautyData.Instance:GetBeautyInfo()[hunqi_id]
	local jian_ding_attr_info = BeautyData.Instance:GetShengJiLevelCfg(hunqi_id - 1, info.level > 0 and info.level or 1)
	if nil == jian_ding_attr_info then
		return attr_jianding_list
	end
	jian_ding_attr_info = CommonDataManager.GetAttributteByClass(jian_ding_attr_info)
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
			local hunyin_cfg = self:GetHunYinInfo()[v.hunyin_id]
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
	for i,v in ipairs(self:GetXiLianComsume()) do
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

function HunQiData:SetCurrenSelectPage(int)
	self.current_select_page = int or 1
end

function HunQiData:GetCurrenSelectPage( )
	return self.current_select_page
end
