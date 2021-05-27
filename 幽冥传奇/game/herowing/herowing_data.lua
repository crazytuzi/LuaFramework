HeroWingData = HeroWingData or BaseClass()

-- ========================英雄光翼状态========================
HERO_WING_STATE = {
				DISCHARGE = 0,          	--卸戴状态
				DRESS = 1,         	        --穿戴状态
				ACTIVE = 2,        	        --需要激活
}

-- 战将激活条件类型
HeroWingData.CondType = {
	"level",
	"vipGrade",
	"loginDay",
	"yuanBao",
	"openDay",
}

function HeroWingData:__init()
	if HeroWingData.Instance then
		ErrorLog("[HeroWingData] attempt to create singleton twice!")
		return
	end
	HeroWingData.Instance = self
	self.herowing_info_list = {}
	self:InitAllHeroesBaseInfo()
end

function HeroWingData:__delete()
	HeroWingData.Instance = nil

end
function HeroWingData:InitAllHeroesBaseInfo()
	local info_list = {}
	for k, v in ipairs(HeroSwingConfig) do
		local tmp = {
			idx = k,
			swingId = v.swingId,
			[OBJ_ATTR.ACTOR_WING_APPEARANCE] = v.modelId,
			modelIcon = v.modelIcon,
			activateCond = v.activateCond,
			state = HERO_WING_STATE.ACTIVE,	--默认需要激活
			desc = v.desc,
			is_need_remind = false,		-- 是否需要提醒
		}
		table.insert(info_list, tmp)
	end

	self.herowing_info_list = info_list

end

function HeroWingData:GetWingInfoById(wing_id)
	return self.herowing_info_list[wing_id]
end	

function HeroWingData:SetTilteActList(n_title_act_t)
	for k, v in ipairs(self.herowing_info_list) do
		local act_flag = n_title_act_t[33 - k]
		if act_flag ~= 0 then
			local cur_dress_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_USING_HERO_SWING)
			v.state = HERO_WING_STATE.DISCHARGE
			if cur_dress_id == v.swingId then
				v.state = HERO_WING_STATE.DRESS
			end
		end
	end
end

function HeroWingData:ChangeDress(wingId)
	for k, v in ipairs(self.herowing_info_list) do
		if v.state ~= HERO_WING_STATE.ACTIVE then
			v.state = wingId == v.swingId and HERO_WING_STATE.DRESS or HERO_WING_STATE.DISCHARGE 
		end
	end
end

function HeroWingData:GetHeroesInfoList()
	return self.herowing_info_list
end
-- 光翼附加属性配置
function HeroWingData.GetHeroWingAttrCfgByLv(type,lv)
	local cfg = ConfigManager.Instance:GetServerConfig("attr/HeroSwingAttrsConfig")[1][type]
	if cfg then
		return cfg[lv]
	end
end
function HeroWingData:GetHeroWingAddAttrByLv(index,lv)
	local attr_str_t = {}
	local cfg = HeroWingData.GetHeroWingAttrCfgByLv(index,lv)
	local prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local attr_t = {} 
	if cfg then
		attr_t = CommonDataManager.DelAttrByProf(prof, cfg)
	end
	attr_str_t = RoleData.FormatRoleAttrStr(attr_t, is_range, item_cfg, prof)
	return attr_str_t
end

-- 是否需要激活提醒
function HeroWingData:IsNeedActivateRemind(hero_data)
	local is_need_remind = false
	local activate_type = nil
	local activate_val = nil
	local is_lack_money = nil
	if hero_data.state == HERO_WING_STATE.ACTIVE then
		-- if hero_data.swingId ~= 1 then
		-- 	if HERO_WING_STATE.ACTIVE == self:GetPreHeroActivateState(hero_data.swingId) then
		-- 		return false
		-- 	end
		-- end 
		local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 等级
		local vipLv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)		-- VIP等级
		local login_day = OtherData.Instance:GetLoginDays()						-- 登陆天数
		local ingot_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)		-- 元宝数量
		local open_day = OtherData.Instance:GetOpenServerDays()					-- 开服天数
		for i, v in ipairs(hero_data.activateCond) do
			-- local cnt = #v
			-- print("数量：", cnt)
			-- local achieve_cnt = 0
			-- if hero_data.swingId ~= 1 then
			-- 	if HERO_WING_STATE.ACTIVE ~= self:GetPreHeroActivateState(hero_data.swingId) then
			-- 		achieve_cnt = 1
			-- 	end
			-- end
			for k, v_2 in pairs(v) do
				for k_3, v_3 in pairs(v_2) do
					-- print("k_3: ", k_3)
					-- if hero_data.swingId == 5 then
					-- 	if k_3 == HeroWingData.CondType[3] and login_day >= v_3 then
					-- 		is_need_remind = true
					-- 	elseif  k_3 == HeroWingData.CondType[4] then
					-- 		if is_need_remind == true then
					-- 			activate_type = k_3
					-- 			activate_val = v_3
					-- 			if ingot_num < v_3 then
					-- 				is_lack_money = true
					-- 			end	
					-- 		end		
					-- 	end	
					-- else		
					if k_3 == HeroWingData.CondType[1] and role_lv >= v_3 then
						is_need_remind = true
						break
					elseif k_3 == HeroWingData.CondType[2] then
						if vipLv >= v_3 then
							is_need_remind = true
							break
						else
							activate_type = k_3
							activate_val = v_3
						end
					elseif k_3 == HeroWingData.CondType[3] and login_day >= v_3 then
						is_need_remind = true
						break
					elseif k_3 == HeroWingData.CondType[4] then
						if ingot_num >= v_3 then
							is_need_remind = true
							activate_type = k_3
							activate_val = v_3
							break
						else
							activate_type = k_3
							activate_val = v_3
						end
					elseif k_3 == HeroWingData.CondType[5] and open_day >= v_3 then
						is_need_remind = true
						break
					end
				end	
				if is_need_remind then
					break
				end
			end
			if is_need_remind then
				break
			end
		end
	end

	return is_need_remind, activate_type, activate_val, is_lack_money
end
-- 获取前一个翅膀激活状态
function HeroWingData:GetPreHeroActivateState(hero_wing_id)
	local last_id = (hero_wing_id - 1) >= 1 and 1 or (hero_wing_id - 1)
	for k, v in pairs(self.herowing_info_list) do
		if v.swingId == last_id then
			return v.state
		end
	end
end

function HeroWingData:GetHeroWingRemindNum()
	local remind_num = 0
	for k, v in pairs(self.herowing_info_list) do
		local need_remind, activate_type, activate_val = self:IsNeedActivateRemind(v)
		if v.swingId ~= 5 then
			if need_remind == true then
				remind_num = 1
				break
			end
		end	
	end
	return remind_num
end





