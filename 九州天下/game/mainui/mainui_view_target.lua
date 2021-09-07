MainUIViewTarget = MainUIViewTarget or BaseClass(BaseRender)

function MainUIViewTarget:__init()
	-- 找到要控制的变量
	self.show_target = self:FindVariable("ShowTarget")
	self.target_level = self:FindVariable("TargetLevel")
	self.target_name = self:FindVariable("TargetName")
	self.target_portrait = self:FindVariable("TargetPortrait")
	self.boss_hp = self:FindVariable("BossHp")
	self.boss_hp_bg = self:FindVariable("BossHpBg")
	self.show_boss_hp_bg = self:FindVariable("ShowBossHpBg")
	self.boss_hp_count = self:FindVariable("BossHpCount")
	self.camp = {}
	self.shang_hai = {}
	self.show_camp = {}
	for i=1,3 do
		self.camp[i] = self:FindVariable("Camp"..i)
		self.shang_hai[i] = self:FindVariable("Shang_Hai"..i)
		self.show_camp[i] = self:FindVariable("Show_Camp"..i)
	end

	self.show_camp_dachen = self:FindVariable("Show_Camp_DaChen")

	self.show_first_hurt = self:FindVariable("Show_First_Hurt")
	self.first_hurt_str = self:FindVariable("First_Hurt_Str")
	self.first_hurt_player = self:FindVariable("First_Hurt_Player")

	-- 监听系统事件
	self:BindGlobalEvent(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObjHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(ObjectEventType.TARGET_HP_CHANGE, BindTool.Bind(self.OnTargetHpChangeHead, self))
	self:BindGlobalEvent(ObjectEventType.SPECIAL_SHIELD_CHANGE, BindTool.Bind(self.OnSpecialShieldChangeBlood, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_MONSTER_CHANGE,BindTool.Bind(self.OnObjMonsterChange, self))
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.ClearFirstHurt, self))

	self.hp_bar = self:FindObj("HpBar")
	self.hp_slider_top = self:FindVariable("HpValue")

	self.boss_hp_bar = self:FindObj("BossHpBar")
	self.boss_hp_slider_top = self:FindVariable("BossHpValue")
	self.boss_dun_slider = self:FindVariable("BossDunValue")
	self.dun_pro = self:FindObj("BossHpBar/DunPro")
	self.dun_pro:SetActive(false)

	self.portrait_label = self:FindObj("PortraitLabel")
	self.portrait = self:FindObj("portrait")
	self.portrait_raw = self:FindObj("portrait_raw")

	self.boss_portrait_label = self:FindObj("BossPortraitLabel")
	self.boss_portrait = self:FindObj("Bossportrait")
	self.boss_portrait_raw = self:FindObj("Bossportrait_raw")

	-- self.show_long_bg = self:FindVariable("show_long_bg")
	-- self.show_belong_camp = self:FindVariable("show_belong_camp")
	-- self.belong_camp = self:FindVariable("belong_camp")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))

	-- 首次刷新数据
	self:OnSelectObjHead(nil, nil)
	self.is_show = true
	self.is_show_first_hurt = false

	-- self.rect = self.root_node.transform:GetComponent(typeof(UnityEngine.RectTransform))
	-- local x, y = self.rect.anchoredPosition.x, self.rect.anchoredPosition.y
	-- self.height_pos = Vector2(x, 0);
	-- self.pos = Vector2(x, y);
end

-- 选择对象显示头像
function MainUIViewTarget:OnSelectObjHead(target_obj, select_type)
	-- 攻城战旗帜
	local qizhi_id = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss2_id or 0
	--隐藏护盾
	self.dun_pro:SetActive(false)
	if nil == target_obj
		or target_obj:GetType() == SceneObjType.MainRole
		or target_obj:GetType() == SceneObjType.TruckObj
		or target_obj:GetType() == SceneObjType.EventObj
		or target_obj:GetType() == SceneObjType.Trigger
		or target_obj:GetType() == SceneObjType.MingRen
		or target_obj:IsNpc()
		or (target_obj.IsGather and target_obj:IsGather())
		or (target_obj:IsMonster() and not target_obj:IsBoss() and target_obj:GetMonsterId() ~= qizhi_id)
		or (target_obj:GetType() == SceneObjType.Role and target_obj:GetVo().shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_QINGLOU_DANCER)
		or (target_obj:GetType() == SceneObjType.Monster and target_obj:GetMonsterId() == 1101 and Scene.Instance:GetSceneType() == SceneType.QunXianLuanDou) then
		self.target_obj = nil
		self.show_target:SetValue(false)
		return
	end
	self.target_obj = target_obj
	self.show_target:SetValue(self.target_obj ~= nil and self.is_show)
	if self.target_obj == nil then
		return
	end

	local scene_type = Scene.Instance:GetSceneType()
    if scene_type == SceneType.Kf_OneVOne then
    	self.show_target:SetValue(false)
    	return
    end

    -- 连服场景中改变位置
    if Scene.Instance:GetSceneType() == SceneType.CrossGuildBattle or Scene.Instance:GetSceneType() == SceneType.XianYangCheng then
	  	self.root_node.transform.anchorMax = Vector2(0, 1)
		self.root_node.transform.anchorMin = Vector2(0, 1) 
		self.root_node.transform.anchoredPosition3D = Vector3(320, -60, 0)
	else
		self.root_node.transform.anchorMax = Vector2(0, 1)
		self.root_node.transform.anchorMin = Vector2(0, 1)
		self.root_node.transform.anchoredPosition3D = Vector3(402, 0, 0)
	end

	local vo = target_obj:GetVo()
	if target_obj:IsRole() then
		self.hp_bar:SetActive(true)
		self.boss_hp_bar:SetActive(false)
		self.portrait_label:SetActive(true)
		self.boss_portrait_label:SetActive(false)
		self.portrait_raw.gameObject:SetActive(false)
		self.portrait.gameObject:SetActive(true)
		self.target_name:SetValue(target_obj:GetName())
		local lv, zhuan = PlayerData.GetLevelAndRebirth(target_obj:GetAttr("level"))
		self.target_level:SetValue(string.format(Language.Mainui.Level2, lv, zhuan))
		self:SetHpPercent(target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp"))
		self:OnHeadChange(vo)
		if self.show_camp_dachen then
			self.show_camp_dachen:SetValue(false)
		end
		if self.show_first_hurt then
			self.show_first_hurt:SetValue(false)
		end
	elseif target_obj:IsMonster() then
		self.hp_bar:SetActive(false)
		self.boss_hp_bar:SetActive(true)
		self.portrait_label:SetActive(false)
		self.boss_portrait_label:SetActive(true)
		self.boss_portrait_raw.gameObject:SetActive(false)
		self.boss_portrait.gameObject:SetActive(true)
		self:SetHpPercent(target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp"))
		local monster_id = vo.monster_id
		local config = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
		if config then
			if config[monster_id] then
				local level = config[monster_id].level or 0
				self.target_name:SetValue(string.format("<color=#07cc72>" .. Language.Mainui.Level3 .. level .. "</color>" .. target_obj:GetName()))
				self.target_level:SetValue("")
			end
		end
		self.monste_obj = target_obj.vo
		self.select_monster_id = target_obj.vo.monster_id
		self.select_target_obj = target_obj:IsMonster()
		self:OnObjMonsterChange(target_obj.vo)
		if self.show_first_hurt then
			self.show_first_hurt:SetValue(self.is_show_first_hurt)
		end
		if self.monste_obj.monster_camp_type > 0 then
			if self.show_camp_dachen:GetBoolean() then
				self.show_first_hurt:SetValue(false)
			else
				self.show_first_hurt:SetValue(true)
				self.first_hurt_str:SetValue(Language.Boss.BelongingToCamp)
				self.first_hurt_player:SetValue(CampData.Instance:GetCampNameByCampType(self.monste_obj.monster_camp_type, false, true, true))
			end
		else
			self.show_first_hurt:SetValue(self.is_show_first_hurt)
		end
	else
		self:SetHpPercent(1)
	end
	if Scene.Instance:GetSceneType() == SceneType.ClashTerritory then
		self.target_name:SetValue(ClashTerritoryData.Instance:GetMonsterName(target_obj.vo))
	end
	if Scene.Instance:GetSceneType() == SceneType.CrossGuildBattle then
		local flag_cfg = KuafuGuildBattleData.Instance:GetSceneFlagCfg(Scene.Instance:GetSceneId(), target_obj.vo.monster_id)
		if flag_cfg then
			self.target_name:SetValue(flag_cfg.flag_name)
		end
	end

	if target_obj:IsMonster() then
		if target_obj:GetMonsterHead() > 0 then
			local bundle, asset = ResPath.GetBossIcon(target_obj:GetMonsterHead())
			self.target_portrait:SetAsset(bundle, asset)
		else
			self.boss_portrait:SetActive(false)
		end
	end
end

-- 取消
function MainUIViewTarget:OnObjDeleteHead(obj)
	if self.target_obj == obj then
		self.target_obj = nil
		self.show_target:SetValue(false)
	end
end

-- 目标血量改变
function MainUIViewTarget:OnTargetHpChangeHead(target_obj)
	self:SetHpPercent(target_obj:GetAttr("hp") / target_obj:GetAttr("max_hp"))
end

function MainUIViewTarget:OnSpecialShieldChangeBlood(info)
	if self.target_obj and self.target_obj:GetObjId() == info.obj_id then
		self.boss_dun_slider:SetValue(info.left_times / info.max_times)
		self.dun_pro:SetActive(info.left_times / info.max_times > 0)
		if info.max_times <= 0 then
			self.dun_pro:SetActive(false)
			self.boss_dun_slider:SetValue(0)
			if self.cal_time_quest then
				GlobalTimerQuest:CancelQuest(self.cal_time_quest)
				self.cal_time_quest = nil
			end
		end
	end
	if self.cal_time_quest == nil then
		self:CalTimeHideDun()
	end
end

function MainUIViewTarget:CalTimeHideDun()
	local timer_cal = 20
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal < 0 then
			self.dun_pro:SetActive(false)
			self.boss_dun_slider:SetValue(0)
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
			self.cal_time_quest = nil
		end
	end, 0)
end

-- 设置目标血条
local old_index = 0
function MainUIViewTarget:SetHpPercent(percent)
	self.hp_slider_top:SetValue(percent)
	local index = math.floor(percent * 100)
	local per = percent * 100 - index
	if per == 0 and percent ~= 0 then
		per = 1
		index = index - 1
	end
	local res_index = index % 5
	self.boss_hp:SetAsset(ResPath.GetBossHp(5 - res_index))
	self.show_boss_hp_bg:SetValue(index > 0)
	if index > 0 then
		self.boss_hp_bg:SetAsset(ResPath.GetBossHp(6 - res_index > 5 and 1 or 6 - res_index))
	end
	self.boss_hp_count:SetValue(index == 0 and "" or ("X " .. index))
	self.boss_hp_slider_top:SetValue(per)

	old_index = index
end

function MainUIViewTarget:SetState(switch)
	self.is_show = switch or false
	if self.target_obj then
		if self.is_show then
			self.show_target:SetValue(true)
		else
			self.show_target:SetValue(false)
		end
	end
end

function MainUIViewTarget:OnClick()
	if self.target_obj then
		if self.target_obj:GetVo().role_id == 99999 then
			return
		end
		if self.target_obj:GetType() == SceneObjType.Role then
			local name = self.target_obj:GetName()
			if name then
				ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
			end
		end
	end
end

-- 头像更换
function MainUIViewTarget:OnHeadChange(vo)
	if not vo then return end
	local avatar_path_big = AvatarManager.Instance:GetAvatarKey(vo.role_id, false)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(vo.role_id)

	if IS_ON_CROSSSERVER then
		--温泉场景使用默认头像
		self.portrait_raw.gameObject:SetActive(false)
		self.portrait.gameObject:SetActive(true)
		local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(vo.prof), false, vo.sex)
		self.target_portrait:SetAsset(bundle, asset)
		return
	end

	if AvatarManager.Instance:isDefaultImg(vo.role_id) == 0 or avatar_path_small == 0 then
		self.portrait_raw.gameObject:SetActive(false)
		self.portrait.gameObject:SetActive(true)
		local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(vo.prof), false, vo.sex)
		self.target_portrait:SetAsset(bundle, asset)
		return
	end

	local callback = function (path)
		self.avatar_path_small = path or AvatarManager.GetFilePath(vo.role_id, false)
		self.portrait_raw.raw_image:LoadSprite(self.avatar_path_small, function()
			self.portrait_raw.gameObject:SetActive(true)
			self.portrait.gameObject:SetActive(false)
		end)
	end
	AvatarManager.Instance:GetAvatar(vo.role_id, false, callback)
end

function MainUIViewTarget:ChangeToHigh(value)
	-- if self.rect then
	-- 	self.rect.anchoredPosition = value and self.pos or self.height_pos
	-- end
end

-- 攻击大臣国家伤害信息
function MainUIViewTarget:OnObjMonsterChange(monster_info)
	if nil == self.select_monster_id or self.select_target_obj == false then return end
	if self.select_monster_id > 0 and self.select_target_obj == true then
		local dachen_cfg = NationalWarfareData.Instance:GetDachenOtherInfo()
		local guoqi_cfg = NationalWarfareData.Instance:GetGuoQiOtherInfo()
		local qiyunta_cfg = NationalWarfareData.Instance:GetCampWarFateOtherCfg()
		local dachen_info = NationalWarfareData.Instance:GetCampDachenActStatus()
		local guoqi_info = NationalWarfareData.Instance:GetCampGuoQiActStatus()
		local cur_camp_dachen_info = NationalWarfareData.Instance:GetDaChenCampInfo()
		local cur_camp_guoqi_info = NationalWarfareData.Instance:GetGuoQiCampInfo()
		local cur_camp_qiyunta_info = CampData.Instance:GetCampQiyunTowerStatus()
		local dakuafu_boss_id = SupremacyData.Instance:GetBossId()
		if self.select_monster_id == dachen_cfg[1].camp_1_dachen_monster_id
			or self.select_monster_id == dachen_cfg[1].camp_2_dachen_monster_id
			or self.select_monster_id == dachen_cfg[1].camp_3_dachen_monster_id then
			if cur_camp_dachen_info then
				for i=1,3 do
					self.camp[i]:SetValue(Language.RankTogle.Camp[i]..Language.NationalWarfare.ShangHai)
					self.shang_hai[i]:SetValue(cur_camp_dachen_info.hurt_percent[i].."%")
					self.show_camp[i]:SetValue(dachen_info[i].act_status ~= 1)
				end
			end
			self.show_camp_dachen:SetValue(true)
		elseif self.select_monster_id == guoqi_cfg[1].camp_1_flag_monster_id
			or self.select_monster_id == guoqi_cfg[1].camp_2_flag_monster_id
			or self.select_monster_id == guoqi_cfg[1].camp_3_flag_monster_id then
			if cur_camp_guoqi_info then
				for i=1,3 do
					self.camp[i]:SetValue(Language.RankTogle.Camp[i]..Language.NationalWarfare.ShangHai)
					self.shang_hai[i]:SetValue(cur_camp_guoqi_info.hurt_percent[i].."%")
					self.show_camp[i]:SetValue(guoqi_info[i].act_status ~= 1)
				end
			end
			self.show_camp_dachen:SetValue(true)
		elseif self.select_monster_id == qiyunta_cfg.camp_1_qiyun_tower_id
			or self.select_monster_id == qiyunta_cfg.camp_2_qiyun_tower_id
			or self.select_monster_id == qiyunta_cfg.camp_3_qiyun_tower_id then
			local scene_index = CampData.Instance:GetCurCampSceneIndex()
			if cur_camp_qiyunta_info then
				for i=1,3 do
					if cur_camp_qiyunta_info.item_list[i] then
						self.camp[i]:SetValue(Language.RankTogle.Camp[i]..Language.NationalWarfare.ShangHai)
						if scene_index == i then
							for j=1,3 do
								self.shang_hai[j]:SetValue(cur_camp_qiyunta_info.item_list[i].hurt_percent[j].."%")
							end
							self.shang_hai[i]:SetValue(cur_camp_qiyunta_info.item_list[i].hurt_percent[i].."%")
						end
						self.show_camp[i]:SetValue(scene_index ~= i)
					end
				end
			end
			self.show_camp_dachen:SetValue(true)
		else
			self.show_camp_dachen:SetValue(false)
		end
	end
end

function MainUIViewTarget:OnFirstHurtChange(is_show, name)
	local is_boss_scene = false
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		is_boss_scene = BossData.IsWorldBossScene(scene_id)
		or BossData.IsFamilyBossScene(scene_id)
		or BossData.IsMikuBossScene(scene_id)
		or BossData.IsNeutralBossScene(scene_id)
		or SupremacyData.Instance:IsSupremacyScene(scene_id)
		or BossData.IsBabyBossScene(scene_id)
	end

	if is_show == 1 and is_boss_scene then
		self.is_show_first_hurt = true
		self.show_first_hurt:SetValue(true)
		self.first_hurt_str:SetValue(Language.Boss.BelongingToDrop)
		self.first_hurt_player:SetValue(name or Language.Common.ZanWu)
	else
		self.is_show_first_hurt = false
		self.show_first_hurt:SetValue(false)
	end
end

function MainUIViewTarget:ClearFirstHurt()
	self.is_show_first_hurt = false
end