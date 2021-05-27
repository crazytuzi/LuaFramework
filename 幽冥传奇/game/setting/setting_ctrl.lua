require("scripts/game/setting/setting_view")
require("scripts/game/setting/setting_assist_view")
require("scripts/game/setting/setting_protect_view")
require("scripts/game/setting/setting_fighting_view")
require("scripts/game/setting/setting_pick_up_view")
require("scripts/game/setting/setting_data")

-- 设置
SettingCtrl = SettingCtrl or BaseClass(BaseController)

function SettingCtrl:__init()
	if SettingCtrl.Instance ~= nil then
		ErrorLog("[SettingCtrl] Attemp to create a singleton twice !")
	end
	SettingCtrl.Instance = self
	self.setting_view = SettingView.New(ViewDef.Setting)
	self.setting_data = SettingData.New()

	self.is_check_def_setting = true

	self:RegisterAllProtocols()
end

function SettingCtrl:__delete()
	self.setting_data:DeleteMe()
	self.setting_data = nil

	self.setting_view:DeleteMe()
	self.setting_view = nil

	SettingCtrl.Instance = nil
end

function SettingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGameSetData, "OnGameSetData")
end

function SettingCtrl:SendHotkeyInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHotkeyInfoReq)
	protocol:EncodeAndSend()
end

function SettingCtrl:SendChangeHotkeyReq(index, value)
	-- 数据未和服务端同步时，不保存数据
	if not self.setting_data:IsTongbuServerData() or nil == index or nil == value then
		return
	end
	local save_list = self.setting_data:GetSettingData()
	save_list[index] = {index = index, value = value}
	self:SendGameOptionsSaveReq(save_list)
end


function SettingCtrl:SendGameOptionsSaveReq(save_list)
	local count = 0
	for k,v in pairs(save_list) do
		count = count + 1
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGameOptionsSaveReq)
	protocol.count = count
	protocol.save_list = save_list
	protocol:EncodeAndSend()
end

-- 检查默认设置
function SettingCtrl:CheckDefaultSetting()
	local data, param = SettingData.Instance:GetDataByIndex(HOT_KEY.GUAJI_SETTING)
	if data == 0 and param == 0 then
		--挂机设置 true为勾选
		local guaji_default_select = {
			[GUAJI_SETTING_TYPE.HP_AUTO] = true,					--自动补血
			[GUAJI_SETTING_TYPE.MP_AUTO] = false,					--自动补魔
			[GUAJI_SETTING_TYPE.HP_AUTO_RUN] = false,				--自动逃跑
			[GUAJI_SETTING_TYPE.SPECIFIC_DRUG_AUTO_BUY] = true,		--自动购买特效药
			[GUAJI_SETTING_TYPE.REMISSION_DRUG_AUTO_BUY] = true,	--自动购买缓解药
			[GUAJI_SETTING_TYPE.AUTO_CALL_HERO] = true,				--自动召唤战将
			[GUAJI_SETTING_TYPE.AUTO_PICKUP_DRUG] = true,			--自动拾取药品
			[GUAJI_SETTING_TYPE.AUTO_PICKUP_STUFF] = true,			--自动拾取材料
			[GUAJI_SETTING_TYPE.AUTO_PICKUP_OTHER] = true,			--自动拾取其它
			[GUAJI_SETTING_TYPE.AUTO_PICKUP_COIN] = true,			--自动拾取金币
			[GUAJI_SETTING_TYPE.AUTO_PICKUP_EQUIP] = true,			--自动拾取装备
			[GUAJI_SETTING_TYPE.AUTO_PICKUP_CS_EQUIP] = true,		--自动拾取传世装备
			[GUAJI_SETTING_TYPE.AUTO_PICKUP_DAN] = true,			--自动拾取等级丹
		}
		self:ChangeGuaJiSetting(guaji_default_select)
	end

	-- 特殊：显示怪物名称
	-- data, param = SettingData.Instance:GetDataByIndex(HOT_KEY.SYS_SETTING)
	-- if data == 0 and param == 0 then
	-- 	SettingCtrl.Instance:ChangeSetting({[SETTING_TYPE.SHIELD_MONSTER_NAME] = true})
	-- end

	-- 系统设置 true为勾选
	data, param = SettingData.Instance:GetDataByIndex(HOT_KEY.SYS_SETTING)
	if data == 0 and param == 0 then
		local sys_setting = {
			[SETTING_TYPE.TRADE_REQUEST] = false, 	--拒绝交易
			[SETTING_TYPE.GUILD_C_SPEECH] = true,	--行会频道自动播放语音
			[SETTING_TYPE.TEAM_C_SPEECH] = true, 	--队伍频道自动播放语音
			[SETTING_TYPE.PRIVATE_C_SPEECH] = true,--私聊频道自动播放语音
		}
						
		SettingCtrl.Instance:ChangeSetting(sys_setting)
	end

	data, param = SettingData.Instance:GetDataByIndex(HOT_KEY.SUPPLY)
	if data == 0 and param == 0 then
		--保护-安全设置      低于百分比自动使用 对应设置中的顺序
		self:ChangeSupplySetting(60, 80, 80)
	end

	data, param = SettingData.Instance:GetDataByIndex(HOT_KEY.SOUND)
	if data == 0 and param == 0 then
		--辅助             背景音乐 音效音量
		self:ChangeSoundSetting(30, 60)
	end

	data, param = SettingData.Instance:GetDataByIndex(HOT_KEY.SELECT_OPTION)
	if data == 0 and param == 0 then
		self:ChangeSelectOptionSetting(0, 0, 0, 0, 0, 0)
	end

	data, param = SettingData.Instance:GetDataByIndex(HOT_KEY.GUAJI_SKILL)
	if data == 0 and param == 0 then
		--战斗-挂机设置		  单体攻击 群体攻击
		self:ChangeGuajiSkillSetting(0, 0)
	end
end

function SettingCtrl:Open(tab_index)
	-- self.setting_view:Open(tab_index)
end

--获取技能自动使用设置信息
function SettingCtrl:GetAutoSkillSetting(guaji_setting_type)
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.AUTO_USE_SKILL)
	if data ~= nil then
		local set_flag = bit:d2b(data)
		return set_flag[33 - guaji_setting_type] == 1
	end
end

function SettingCtrl:OnGameSetData(protocol)
	SettingData.Instance:SetSettingData(protocol.save_list)
	self:RearrangeSkill()

	--技能栏设置
	GlobalEventSystem:Fire(SettingEventType.SKILL_BAR_CHANGE)

	--系统设置
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.SYS_SETTING)
	local flag_t = bit:d2b(data)
	for i = 1, self.setting_view.OPTION_COUNT do
		local flag = (1 == flag_t[33 - i])
		GlobalEventSystem:Fire(SettingEventType.SYSTEM_SETTING_CHANGE, i, flag)
	end

	--挂机设置
	local guaji_data = SettingData.Instance:GetDataByIndex(HOT_KEY.GUAJI_SETTING)
	local guaji_flag_t = bit:d2b(guaji_data)
	for i = 1, self.setting_view.GJ_OPTION_COUNT2 do
		local flag = (1 == guaji_flag_t[33 - i])
		GlobalEventSystem:Fire(SettingEventType.GUAJI_SETTING_CHANGE, i, flag)
	end

	--时装
	local fashion_data = SettingData.Instance:GetDataByIndex(HOT_KEY.APPEAR_SAVE)
	GlobalEventSystem:Fire(SettingEventType.FASHION_SAVE_CHANGE, fashion_data)

	self.setting_view:Flush(TabIndex.setting_assist)
	self.setting_view:Flush(TabIndex.setting_protect)

	if self.is_check_def_setting then
		self:CheckDefaultSetting()
		self.is_check_def_setting = false
	end
end

-- 改变系统设置
function SettingCtrl:ChangeSetting(setting_t)
	local setting_t = setting_t or {}

	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.SYS_SETTING)
	local set_flag = bit:d2b(data)
	for k, v in pairs(setting_t) do 
		set_flag[33 - k] = v and 1 or 0
	end

	data = bit:b2d(set_flag)
	SettingData.Instance:SetDataByIndex(HOT_KEY.SYS_SETTING, data)
	self:SendChangeHotkeyReq(HOT_KEY.SYS_SETTING, data)

	self.setting_view:Flush(TabIndex.setting_assist)

	for k, v in pairs(setting_t) do 
		GlobalEventSystem:Fire(SettingEventType.SYSTEM_SETTING_CHANGE, k, v)
	end
end

-- 改变挂机设置
function SettingCtrl:ChangeGuaJiSetting(setting_t)
	local setting_t = setting_t or {}

	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.GUAJI_SETTING)
	local set_flag = bit:d2b(data)
	for k, v in pairs(setting_t) do
		set_flag[33 - k] = v and 1 or 0
	end

	data = bit:b2d(set_flag)
	SettingData.Instance:SetDataByIndex(HOT_KEY.GUAJI_SETTING, data)
	self:SendChangeHotkeyReq(HOT_KEY.GUAJI_SETTING, data)

	self.setting_view:Flush(TabIndex.setting_protect)
	
	for k, v in pairs(setting_t) do 
		GlobalEventSystem:Fire(SettingEventType.GUAJI_SETTING_CHANGE, k, v)
	end
	SettingData.Instance:RemoveAutoPickUpList()
end

-- 改变自动使用技能设置
function SettingCtrl:ChangeAutoSkillSetting(setting_t)
	local setting_t = setting_t or {}

	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.AUTO_USE_SKILL)
	local set_flag = bit:d2b(data)
	for k, v in pairs(setting_t) do
		set_flag[33 - k] = v and 1 or 0
	end

	data = bit:b2d(set_flag)
	SettingData.Instance:SetDataByIndex(HOT_KEY.AUTO_USE_SKILL, data)
	self:SendChangeHotkeyReq(HOT_KEY.AUTO_USE_SKILL, data)	
	for k, v in pairs(setting_t) do 
		GlobalEventSystem:Fire(SettingEventType.AUTO_SKILL_CHANGE, k, v)
	end
end

-- 改变补给设置
function SettingCtrl:ChangeSupplySetting(hp_percent, mp_percent, hp_run_percent)
	SettingData.Instance:SetSupplyData(hp_percent, mp_percent, hp_run_percent)
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.SUPPLY)
	self:SendChangeHotkeyReq(HOT_KEY.SUPPLY, data)
end

-- 改变声音设置
function SettingCtrl:ChangeSoundSetting(music_percent, voice_percent)
	SettingData.Instance:SetSoundData(music_percent, voice_percent)
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.SOUND)
	self:SendChangeHotkeyReq(HOT_KEY.SOUND, data)
end

-- 改变可选项设置
function SettingCtrl:ChangeSelectOptionSetting(hp_select, mp_select, run_select, pick_eq_select, money_select, level_dan_select)
	SettingData.Instance:SetSelectOptionData(hp_select, mp_select, run_select, pick_eq_select, money_select, level_dan_select)
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.SELECT_OPTION)
	self:SendChangeHotkeyReq(HOT_KEY.SELECT_OPTION, data)
end

-- 改变挂机技能
function SettingCtrl:ChangeGuajiSkillSetting(single_select, group_select)
	SettingData.Instance:SetGuajiSkillData(single_select, group_select)
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.GUAJI_SKILL)
	self:SendChangeHotkeyReq(HOT_KEY.GUAJI_SKILL, data)
end

-- 技能栏设置
function SettingCtrl:SetOneShowSkill(info, index)
	local data = nil
	if info then
		data = {}
		if info.item_id then
			data.type = SKILL_BAR_TYPE.ITEM
		else
			data.type = info.type or SKILL_BAR_TYPE.SKILL
		end
		data.id = info.id or info.item_id or info.skill_id
	end
	if data then
		for i = 1, SKILL_BAR_COUNT do
			local value = SettingData.Instance:GetDataByIndex(HOT_KEY["SKILL_BAR_" .. i])
			if value then
				local info_type = math.floor(value / 1000000)
				local id = value % 1000000
				if info_type == data.type and id == data.id then
					self:SendChangeHotkeyReq(HOT_KEY["SKILL_BAR_" .. i], 0)
				end
			end
		end
		self:SendChangeHotkeyReq(index, data.type * 1000000 + data.id)
	else
		self:SendChangeHotkeyReq(index, 0)
	end
	GlobalEventSystem:Fire(SettingEventType.SKILL_BAR_CHANGE)
end

-- 重新排列技能，因为需要把3，12，22技能放到大的技能按钮
function SettingCtrl:RearrangeSkill()
	local user_default = SettingData.Instance:GetSettingData()
	for k, v in pairs(user_default) do
		if k >= HOT_KEY.SKILL_BAR_1 and k <= HOT_KEY.SKILL_BAR_8 then
			local skill_id = v.value % 1000000
			if 3 == skill_id or 12 == skill_id or 22 == skill_id then
				SettingCtrl.Instance:SetOneShowSkill(nil, k)
				SettingCtrl.Instance:SetOneShowSkill({type = SKILL_BAR_TYPE.SKILL, id = skill_id}, HOT_KEY["SKILL_BAR_" .. 0])
				break
			end
		end
	end

	for i = HOT_KEY.SKILL_BAR_2, HOT_KEY.SKILL_BAR_8 do	-- 前8个前挪一位
		local cur_data = user_default[i]
		local pre_data = user_default[i - 1]
		if nil ~= cur_data and (nil == pre_data or 0 == pre_data.value) then
			SettingCtrl.Instance:SetOneShowSkill(nil, i)
			SettingCtrl.Instance:SetOneShowSkill({type = math.floor(cur_data.value / 1000000) , id = cur_data.value % 1000000}, i - 1)
		end
	end
end