HonourData = HonourData or BaseClass()
function HonourData:__init()
	if HonourData.Instance then
		ErrorLog("[ElementBattleData] attempt to create singleton twice!")
		return
	end
	HonourData.Instance = self
	self.info = {}
	self.old_day = 0
	RemindManager.Instance:Register(RemindName.Honour, BindTool.Bind(self.GetRemind, self))
end

function HonourData:__delete()
	HonourData.Instance = nil
     RemindManager.Instance:UnRegister(RemindName.Honour)
end

function HonourData:SetHonourInfo(protocol)
	self.info.can_uplevel = protocol.uplevel or 0
	self.info.level = protocol.level or 0
	self.info.honour = protocol.honour or 0
	self.info.add_hp = protocol.add_hp or 0
	self.info.add_gongji = protocol.add_gongji or 0
	self.info.add_fangyu = protocol.add_fangyu or 0
end

function HonourData:GetHonourInfo()
	return self.info
end

function HonourData:GetXunZhangCfg()
	if not self.cfg then
		self.cfg = ConfigManager.Instance:GetAutoConfig("xunzhangconfig_auto").cross_medal_cfg or {}
	end
	return self.cfg
end

function HonourData:GetRongYaoRewardCfg()
	if not self.rongyao_reward_cfg then
		self.rongyao_reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_dakuafu_auto").scene_cfg or {}
	end
	return self.rongyao_reward_cfg
end

function HonourData:GetShowRewardCfg()
	if not self.reward_cfg then
		self.reward_cfg = ConfigManager.Instance:GetAutoConfig("cross_dakuafu_auto").other or {}
	end
	return self.reward_cfg
end


function HonourData:GetEnterInfoByLevel(role_level)
	local enter_info_info = self:GetRongYaoRewardCfg()
	if enter_info_info then
		for k,v in pairs(enter_info_info) do
			if v then
				if role_level >= v.enter_level and role_level <= v.max_level then
					return v
				end
			end
		end
	end
end

function HonourData:GetDayXunZhangCfg()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if nil ~= self.honour_cfg and self.old_day == open_day then
		return self.honour_cfg
	end
	self.honour_cfg = {}
	self.old_day = open_day
	local cfg = self:GetXunZhangCfg()
	for k,v in pairs(cfg) do
		if open_day >= v.opengame_day then
			self.honour_cfg[v.index] = v
		else
			break
		end
	end
	return self.honour_cfg
end

-- 获取当前勋章等级对应升级所需荣誉
function HonourData:GetAutoIndex(lv)
	local cfg = self:GetDayXunZhangCfg()
	local cur_num = 0
	local min_num = 0
	local max_num = #cfg
	local num = math.floor(max_num / 2)
	if lv == 0 then
		return cfg[min_num].need_cross_rongyao
	end
	if cfg[max_num] and cfg[max_num].upper_level < lv then
		return cfg[max_num].need_cross_rongyao
	end
	for i = 0, num do
		if cfg[cur_num] then
			cur_num = math.floor((min_num + max_num) / 2)
			if lv == cfg[cur_num].lower_level then
				return cfg[cur_num].need_cross_rongyao
			elseif lv > cfg[cur_num].lower_level then
				if lv <= cfg[cur_num].upper_level then
					return cfg[cur_num].need_cross_rongyao
				else
					min_num = cur_num + 1
				end
			else
				max_num = cur_num - 1
			end
		end
	end
	return 0
end

--获取当人物等级所对应勋章最高等级限制
function HonourData:GetMaxHonourLimit()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local cfg = self:GetDayXunZhangCfg()
	local max_num = #cfg
	while(max_num >= 0) do
		if cfg[max_num] and cfg[max_num].level_limit <= vo.level then
			return cfg[max_num].upper_level
		end
		max_num = max_num - 1
	end
	return 0
end

function HonourData:GetPowerFight(attack,fangyu,hp)
	local value = {}
	local num = 0
	value.attack = attack
	value.fangyu = fangyu
	value.hp = hp
	num = CommonDataManager.GetCapabilityCalculation(value)
	return num
end

function HonourData:GetRemind()
	if self.info and self.info.can_uplevel then
		return self.info.can_uplevel
	end
	return 0
end
