-- 服务端枚举
HOT_KEY ={
	SKILL_BAR_1 = 0, 								-- 快捷键1
	SKILL_BAR_2 = 1, 								-- 快捷键2
	SKILL_BAR_3 = 2, 								-- 快捷键3
	SKILL_BAR_4 = 3, 								-- 快捷键4
	SKILL_BAR_5 = 4, 								-- 快捷键5
	SKILL_BAR_6 = 5, 								-- 快捷键6
	SKILL_BAR_7 = 6, 								-- 快捷键7
	SKILL_BAR_8 = 7, 								-- 快捷键8
	AUTO_USE_SKILL = 8, 							-- 自动使用技能
	SYS_SETTING = 9,								-- 系统设置
	GUAJI_SETTING = 10,								-- 挂机设置
	SUPPLY = 11,									-- 补给
	SOUND = 12,										-- 声音
	SELECT_OPTION = 13,								-- 可选挂机项 
	GUAJI_SKILL = 14,								-- 挂机技能
	FASHION_SAVE = 15,								-- 时装保存位置(服务端占用)
	APPEAR_SAVE = 16,								-- 热血武器衣服，时装是否勾选
	SKILL_BAR_0 = 17,								-- 普攻技能栏，就是最大的那个
}

-- HOT_KEY.SYS_SETTING 的标志位
SETTING_TYPE = {
	CLOSE_BG_MUSIC 		= 1,						--关闭背景音乐
	CLOSE_SOUND_EFFECT	= 2,						--关闭音效
	SIMPLE_ROLE_NAME	= 3,						--仅显示人物名称
	SHIELD_MONSTER_NAME	= 4,						--显示怪物名称
	SHIELD_FALL_NAME	= 5,						--屏蔽物品名称
	SHIELD_OTHERS 		= 6,						--屏蔽所有玩家
	SHIELD_MONSTER 		= 7,						--屏蔽普通怪物
	SHIELD_PET 			= 8,						--屏蔽宠物怪
	SHIELD_WING 		= 9,						--屏蔽翅膀
	CLOSE_TITLE			= 10,						--屏蔽称号
	SHIELD_HANDS		= 11,						--屏蔽手套
	SHIELD_SAME_CAMP 	= 12,						--屏蔽本行会成员
	FRIEND_REQUEST 		= 13,						--拒绝加好友
	TRADE_REQUEST 		= 14,						--拒绝交易
	SHIELD_SHAKE		= 15,						--屏蔽震屏
	NEAR_C_SPEECH 		= 16,						--附近频道自动播放语音
	WORLD_C_SPEECH 		= 17,						--世界频道自动播放语音
	GUILD_C_SPEECH 		= 18,						--行会频道自动播放语音
	TEAM_C_SPEECH 		= 19,						--队伍频道自动播放语音
	PRIVATE_C_SPEECH 	= 20,						--私聊频道自动播放语音
	SPEAKER_C_SPEECH 	= 21,						--喇叭频道自动播放语音
	WEAR_TITLE_TIP 		= 22,						--屏蔽称号穿戴提示
	SHIELD_ZHENQI 		= 23,						--屏蔽真气

	-- 显示和设置都在组队面板
	AUTO_JOIN_TEAM		= 31,						--自动加入队伍
	REFUSE_JOIN_TEAM	= 32,						--拒绝加入队伍

	-- 已废弃
	-- LITTLE_FIREWALL		= 13,						--缩小小火墙特效
	-- LITTLE_SHENSHOU		= 14,						--缩小神兽宠物
	-- SHIELD_HERO			= 25,						--屏蔽战将
	-- SHIELD_SYSTEM_NOTICE = 26,						--屏蔽系统公告
	-- SHIELD_PHANTOM		= 27,						--屏蔽幻影特效
}

-- HOT_KEY.GUAJI_SETTING_TYPE 的标志位
GUAJI_SETTING_TYPE = {
	HP_AUTO						= 1,						--自动补血
	MP_AUTO						= 2,						--自动补魔
	HP_AUTO_RUN					= 3,						--自动逃跑
	SPECIFIC_DRUG_AUTO_BUY		= 4,						--自动购买特效药
	REMISSION_DRUG_AUTO_BUY		= 5,						--自动购买缓解药
	AUTO_ATTACT_BACK			= 6,						--自动反击
	AUTO_CALL_HERO				= 7,						--自动召唤战将
	AUTO_PICKUP_DRUG			= 8,						--自动拾取药品
	AUTO_PICKUP_STUFF			= 9,						--自动拾取材料
	AUTO_PICKUP_OTHER			= 10,						--自动拾取其它
	AUTO_PICKUP_CS_EQUIP		= 11,						--自动拾取传世装备
	AUTO_PICKUP_COIN			= 12,						--自动拾取元宝
	AUTO_PICKUP_EQUIP			= 13,						--自动拾取装备
	AUTO_PICKUP_DAN				= 14,						--自动拾取等级丹
}

SKILL_BAR_TYPE = {
	ITEM = 1,
	SKILL = 2
}

SettingData = SettingData or BaseClass()

SettingData.SKILL = {{{3}, {4}}, {{12, 83}, {17, 18}}, {{22}, {28, 27}}}
SettingData.SkillOption = {{4, 6, 7, 8, 16, 122, 123, 9, 10}, {16}, {25, 26}}
-- SettingData.SkillOption = {{4, 6}, {16}, {25, 26}} --现在暂时屏蔽下技能
SettingData.CanSetAutoSkill = {16}

function SettingData:__init()
	if SettingData.Instance ~= nil then
		ErrorLog("[SettingData] Attemp to create a singleton twice !")
	end
	SettingData.Instance = self

	self.is_tongbu_server_data = false		-- 是否已同步服务端数据
	self.user_default = {}

	self.hp_run_percent = 0
	self.hp_percent = 0
	self.mp_percent = 0
	self.music_percent = 0
	self.voice_percent = 0

	self.level_dan_select = 0 -- 20-28 拾起等级丹的条件index
	self.money_select = 0 -- 17-20 拾起元宝的条件index
	self.hp_select = 0
	self.mp_select = 0
	self.run_select = 0
	self.pick_eq_select = 0

	self.single_select = 0
	self.group_select = 0


	for _, skill_id in pairs(SPECIAL_SKILL_LIST) do
		SettingData.CanSetAutoSkill[skill_id] = 1
	end
	for k, v in pairs(SettingData.SkillOption) do
		for _, skill_id in pairs(v) do
			SettingData.CanSetAutoSkill[skill_id] = 1
		end
	end
end

function SettingData:__delete()

end

function SettingData:IsTongbuServerData()
	return self.is_tongbu_server_data
end

function SettingData:SetSettingData(user_default)
	self.is_tongbu_server_data = true
	self.user_default = user_default
	self:CalcSupplyPercent()
	self:CalcSoundPercent()
	self:CalcSelectOption()
	self:CalcGuajiSkill()
end

function SettingData:GetSettingData()
	return self.user_default
end

function SettingData:SetDataByIndex(index, value)
	if nil == index then
		return
	end
	if nil == self.user_default[index] then
		self.user_default[index] = {}
	end

	self.user_default[index].index = index
	self.user_default[index].type = 1
	self.user_default[index].value = value

	if index == HOT_KEY.SUPPLY then
		self:CalcSupplyPercent()
	end

	if index == HOT_KEY.SOUND then
		self:CalcSoundPercent()
	end

	if index == HOT_KEY.SELECT_OPTION then
		self:CalcSelectOption()
	end

	if index == HOT_KEY.GUAJI_SKILL then
		self:CalcGuajiSkill()
	end

	if index == HOT_KEY.GUAJI_SETTING then
		self.auto_pick_up_list = nil
	end
end

function SettingData:GetDataByIndex(index)
	local info = self.user_default[index]
	if nil == info then
		return 0, 0
	end

	return info.value, info.type
end

function SettingData:GetSupplyData()
	return self.hp_percent, self.mp_percent, self.hp_run_percent
end

function SettingData:SetSupplyData(hp_percent, mp_percent, hp_run_percent)
	local data = bit:_lshift(hp_run_percent, 16) + bit:_lshift(hp_percent, 8) + mp_percent
	self:SetDataByIndex(HOT_KEY.SUPPLY, data)
end

function SettingData:GetSoundData()
	return self.music_percent, self.voice_percent
end

function SettingData:SetSoundData(music_percent, voice_percent)
	local data = bit:_lshift(music_percent, 8) + voice_percent
	self:SetDataByIndex(HOT_KEY.SOUND, data)
end

function SettingData:GetSelectOptionData()
	return self.hp_select, self.mp_select, self.run_select, self.pick_eq_select, self.money_select, self.level_dan_select
end

function SettingData:SetSelectOptionData(hp_select, mp_select, run_select, pick_eq_select, money_select, level_dan_select)
	local data = bit:_lshift(level_dan_select, 20) + bit:_lshift(money_select, 16) +bit:_lshift(hp_select, 12) + bit:_lshift(mp_select, 8)+ bit:_lshift(run_select, 4) + pick_eq_select
	self:SetDataByIndex(HOT_KEY.SELECT_OPTION, data)
end

function SettingData:GetGuajiSkillData()
	return self.single_select , self.group_select
end

function SettingData:SetGuajiSkillData(single_select, group_select)
	local data = bit:_lshift(single_select, 8) + group_select
	self:SetDataByIndex(HOT_KEY.GUAJI_SKILL, data)
end

function SettingData:CalcSupplyPercent()
	local data = self:GetDataByIndex(HOT_KEY.SUPPLY) or 0
	self.hp_run_percent = bit:_rshift(data, 16)
	self.hp_percent = bit:_and(bit:_rshift(data, 8), 0xff)
	self.mp_percent = bit:_and(data, 0xff)
end

function SettingData:CalcSoundPercent()
	local data = self:GetDataByIndex(HOT_KEY.SOUND) or 0
	self.music_percent = bit:_rshift(data, 8)
	self.voice_percent = bit:_and(data, 0xff)
end

SettingData.DRUG_T = {488, 489, 490}			 -- 自动使用和购买的 瞬间 回复药品列表
SettingData.REMISSION_DRUG = {496, 497, 487}	 -- 自动使用和购买的 缓慢 回复药品列表
SettingData.DELIVERY_T = {454, 455}				 -- 自动使用的传送石列表
SettingData.PICK_EQLV = {1, 24, 30, 36, 50}		 -- 拾起装备的条件
-- SettingData.MONEY = {100, 500, 800, 1000, 1500, 2000, 3000, 5000}			 -- 自动拾起的元宝列表
SettingData.MONEY = { 	 -- 自动拾起的元宝列表
	{1469, 1470},
	{1471, 1472, 1473},
	{1474, 1475, 1476, 2121},
	{1477, 2122, 2123, 1478, 2124},
	{266, 267, 268, 269, 270, 271}
}
SettingData.LEVEL_DAN = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}	 -- 自动拾起的的等级丹列表
function SettingData:CalcSelectOption()
	local old_money_select = self.money_select
	local old_level_dan_select = self.level_dan_select

	local data = self:GetDataByIndex(HOT_KEY.SELECT_OPTION) or 0
	self.level_dan_select = bit:_and(bit:_rshift(data, 20), 0xff) -- 20-28 拾起等级丹的条件index
	self.money_select = bit:_and(bit:_rshift(data, 16), 0xf)-- 17-20 拾起元宝的条件index
	self.hp_select = bit:_and(bit:_rshift(data, 12), 0xf) 	-- 12-16 自动使用的HP药品index
	self.mp_select = bit:_and(bit:_rshift(data, 8), 0xf)	-- 9-12  自动使用的MP药品index
	self.run_select = bit:_and(bit:_rshift(data, 4), 0xf)	-- 5-8   自动使用的传送石index
	self.pick_eq_select = bit:_and(data, 0xf)				-- 1-4   拾起装备的条件index
	
	if old_money_select ~= self.money_select or old_level_dan_select ~= self.level_dan_select then
		self:SetAutoPickUpList()
	end
end

-- 设置自动拾取的物品列表
function SettingData:SetAutoPickUpList()
	self.auto_pick_up_list = self.auto_pick_up_list or {}
	for index, item_id_list in ipairs(SettingData.MONEY) do
		if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_PICKUP_COIN) and index >= (self.money_select + 1) then
			for i, item_id in ipairs(item_id_list) do
				self.auto_pick_up_list[item_id] = true
			end
		else
			for i, item_id in ipairs(item_id_list) do
				self.auto_pick_up_list[item_id] = false
			end
		end
	end

	for i,v in ipairs(SettingData.LEVEL_DAN) do
		if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_PICKUP_DAN) and i >= (self.level_dan_select + 1) then
			self.auto_pick_up_list[v] = true
		else
			self.auto_pick_up_list[v] = false
		end
	end
end

-- 获取自动拾取的物品列表
function SettingData:GetAutoPickUpList()
	if nil == self.auto_pick_up_list then
		self:SetAutoPickUpList()
	end

	return self.auto_pick_up_list
end

-- 删除自动拾取的物品列表 (用于重置列表)
function SettingData:RemoveAutoPickUpList()
	self.auto_pick_up_list = nil
end

function SettingData:CalcGuajiSkill()
	local data = self:GetDataByIndex(HOT_KEY.GUAJI_SKILL) or 0
	self.single_select = bit:_and(bit:_rshift(data, 8), 0xff)
	self.group_select = bit:_and(data, 0xff)
end

-- 获取技能槽技能
function SettingData:GetOneShowSkill(index)
	if self.user_default[index] == nil or self.user_default[index].value == 0 then
		return nil
	else
		local value = self.user_default[index].value
		local data = {}
		data.type =  math.floor(value / 1000000)
		data.id = value % 1000000
		return data
	end
end

-- 获取某一系统设置
function SettingData:GetOneSysSetting(index)
	local data = self:GetDataByIndex(HOT_KEY.SYS_SETTING) or 0
	return bit:_and(1, bit:_rshift(data, index - 1)) > 0
end

-- 获取某一挂机系统设置
function SettingData:GetOneGuajiSetting(index)
	local data = self:GetDataByIndex(HOT_KEY.GUAJI_SETTING) or 0
	return bit:_and(1, bit:_rshift(data, index - 1)) > 0
end

--获取某一时装勾选设置
function SettingData:GetOneFashionSetting(index)
	local data = self:GetDataByIndex(HOT_KEY.APPEAR_SAVE) or 0
	return bit:_and(1, bit:_rshift(data, index - 1)) > 0
end

-- 是否显示自动设置
function SettingData.ShowSkillAutoSetting(skill_id)
	for k,v in pairs(SettingData.SkillOption) do
		for k1,v1 in pairs(v) do
			if skill_id == v1 then
				return true
			end 
		end
	end
	return false
end

