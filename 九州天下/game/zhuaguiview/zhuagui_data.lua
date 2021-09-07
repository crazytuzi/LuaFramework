ZhuaGuiData = ZhuaGuiData or BaseClass()

function ZhuaGuiData:__init()
	if ZhuaGuiData.Instance ~= nil then
		ErrorLog("[ZhuaGuiData] Attemp to create a singleton twice !")
	end
	ZhuaGuiData.Instance = self
	self.zhongkuizhuagui_info = {}
	self.zhongkuizhuagui_fb_info = {}
	self.zhongkuizhuagui_person_info = {}

	self.other_cfg = ConfigManager.Instance:GetAutoConfig("zhuagui_auto").other_cfg
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("zhuagui_auto").monster_cfg
	self.reward_dec = ConfigManager.Instance:GetAutoConfig("zhuagui_auto").reward_dec
	self.team_add_per = ConfigManager.Instance:GetAutoConfig("zhuagui_auto").team_add_per
end

function ZhuaGuiData:__delete()
	ZhuaGuiData.Instance = nil
end

-- 设置当天捉鬼信息
function ZhuaGuiData:SetCurDayZhuaGuiInfo(info)
	self.zhongkuizhuagui_info.zhuagui_day_gethunli = info.zhuagui_day_gethunli
	self.zhongkuizhuagui_info.zhuagui_day_catch_count = info.zhuagui_day_catch_count
end

function ZhuaGuiData:GetLevelLimit()
	return self.other_cfg[1].m_limit_lv
end

function ZhuaGuiData:GetTeamAllPreByNum(num)
	return self.team_add_per[num].hunli_add_per
end

-- 获取基本魂力信息
function ZhuaGuiData:GetBaseHunLi()
	local temp_info = ScoietyData.Instance:GetTeamInfo()
	local temp_level = 0
	if temp_info then
		for k,v in pairs(temp_info.team_member_list) do
			temp_level = temp_level + v.level
		end
	end

	local team_num = ScoietyData.Instance:GetTeamNum()
	temp_level = math.floor(temp_level/team_num)
	for i,v in ipairs(self.monster_cfg) do
		if temp_level >= v.team_level_min and temp_level <= v.team_level_max then
			return v
		end
	end
	return self.monster_cfg[#self.monster_cfg]
end

-- 获取魂力加成data
function ZhuaGuiData:GetAddHunLiDataByTime(time)
	local temp_time = self.reward_dec[1].kill_monster
	if time > temp_time then
		return self.reward_dec[2]
	end

	return self.reward_dec[1]
end

-- 获取抓鬼配置
function ZhuaGuiData:GetZhuaGuiOtherCfg()
	return self.other_cfg[1]
end

-- 获取当天捉鬼信息
function ZhuaGuiData:GetCurDayZhuaGuiInfo()
	return self.zhongkuizhuagui_info
end

-- 获取伴侣魂力加成
function ZhuaGuiData:GetmarriedHunliAddPer()
	return self.other_cfg[1].married_hunli_add_per or 0
end

-- 设置抓鬼副本信息
function ZhuaGuiData:SetZhuaGuiFBInfo(info)
	self.zhongkuizhuagui_fb_info.reason = info.reason
	self.zhongkuizhuagui_fb_info.monster_count = info.monster_count
	self.zhongkuizhuagui_fb_info.ishave_boss = info.ishave_boss
	self.zhongkuizhuagui_fb_info.boss_isdead = info.boss_isdead
	self.zhongkuizhuagui_fb_info.kick_time = info.kick_time
	self.zhongkuizhuagui_fb_info.zhuagui_info_list = info.zhuagui_info_list

	self.zhongkuizhuagui_fb_info.enter_role_num = info.enter_role_num
	self.zhongkuizhuagui_fb_info.item_count = info.item_count
	self.zhongkuizhuagui_fb_info.zhuagui_item_list = info.zhuagui_item_list

end

-- 获取抓鬼副本信息
function ZhuaGuiData:GetZhuaGuiFBInfo()
	return self.zhongkuizhuagui_fb_info
end

--设置抓鬼新增个人信息
function ZhuaGuiData:SetZhuaguiAddPerInfo(info)
	self.zhongkuizhuagui_person_info.couple_hunli_add_per = info.couple_hunli_add_per
	self.zhongkuizhuagui_person_info.couple_boss_add_per = info.couple_boss_add_per
	self.zhongkuizhuagui_person_info.team_hunli_add_per = info.team_hunli_add_per
	self.zhongkuizhuagui_person_info.team_boss_add_per = info.team_boss_add_per
end

-- 获取抓鬼副本个人信息
function ZhuaGuiData:GetZhuaGuiPerInfo()
	return self.zhongkuizhuagui_person_info
end

-- 获取本次副本自己的活力
function ZhuaGuiData:GetCurFBSelfhunliAndmojing()
	local self_hunli = 0
	local self_mojing = 0
	local self_kill_boss_count = 0
	if self.zhongkuizhuagui_fb_info.zhuagui_info_list then
		for k,v in pairs(self.zhongkuizhuagui_fb_info.zhuagui_info_list) do
			if v.uid == GameVoManager.Instance:GetMainRoleVo().role_id then
				self_hunli = v.get_hunli
				self_mojing = v.get_mojing
				self_kill_boss_count = v.kill_boss_count
			end
		end
	end
	return self_hunli, self_mojing, self_kill_boss_count
end

-- 获取是否出现特殊鬼
function ZhuaGuiData:GetIsHasSpecialMonster()
	return 1 == self.zhongkuizhuagui_fb_info.ishave_boss
end