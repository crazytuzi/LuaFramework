CompetitionActivityView = CompetitionActivityView or BaseClass(BaseView)
-- 当前排行榜顺序
-- local rank_type_list ={
-- 	[1] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL ,			--战力榜
-- 	[2] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL,					--等级榜
-- 	[3] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP,					--装备榜
-- 	[4] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT, 					--坐骑榜
-- 	[5] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING, 					--羽翼榜
-- 	[6] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO, 					--光环榜
-- 	[7] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FOOTPRINT,                --足迹榜
-- 	[8] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT,				--战骑
-- 	[9] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING, 		--仙宠总榜
-- 	[10] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY, 		--伙伴总榜
-- 	[11] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG, 				--伙伴光环榜
-- 	[12] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI, 					--伙伴法阵榜
-- 	[13] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL,		--全身装备强化总等级榜
-- 	[14] = PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL,		--全身宝石总等级榜
-- }

function CompetitionActivityView:__init()
	self.ui_config = {"uis/views/competitionactivityview_prefab","CompetitionActivityView"}
	self.play_audio = true
	self.item_list = {}
	self.cell_list = {}
	self.show_item = {}
	self.show_select = {}
	self.day_type = 0
	self.rank_type = 8
	self.is_stop_load_effect = false
end

function CompetitionActivityView:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil
	self.temp_display_role = nil
	self:CancelCountDown()
end

function CompetitionActivityView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	-- 清理变量和对象
	self.list = nil
	self.list_delegate = nil
	self.cur_day_title = nil
	self.first_name = nil
	self.portrait_asset_imag = nil
	self.fight_power = nil
	self.title_asset = nil
	self.model_display = nil
	self.desc = nil
	self.can_reward = nil
	for i = 1, 7 do
		self.show_item[i] = nil
		self.show_select[i] = nil
	end
	self.reward_slider = nil
	self.role_name = nil
	self.role_power = nil
	self.image_obj = nil
	self.raw_image_obj = nil
	self.word_bg = nil
	self.word1 = nil
	self.word2 = nil
	self.show_rest_day = nil
	self.rest_day = nil
	self.rest_hour = nil
	self.rest_min = nil
	self.rest_sec = nil
	self.attr_desc = nil
	self.model_effect = nil
	self.show_get_btn = nil
	self.get_btn_text = nil
	self.reward_day_txt = nil
	self.is_up_one_grade = nil
	self.self_rank = nil
	self.show_effect = nil
	self.title_image = nil
end

function CompetitionActivityView:LoadCallBack()
	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate

	self.cur_day_title = self:FindVariable("CurTitle")
	self.first_name = self:FindVariable("FirstName")
	self.portrait_asset_imag = self:FindVariable("PortraitImage")
	self.fight_power = self:FindVariable("CapValue")
	self.title_asset = self:FindVariable("TitleAsset")
	self.is_up_one_grade = self:FindVariable("IsUpOneGrade")

	self:ListenEvent("OnClickPaiHangBang", BindTool.Bind(self.OnClickPaiHangBang, self))
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self:FindObj("Item"..i))
		self.item_list[i] = cell
	end

	self.model_display = self:FindObj("ModelDisplay")
	self.model = RoleModel.New("competition_activity_panel")
	self.model:SetDisplay(self.model_display.ui3d_display)

	self.desc = self:FindVariable("Desc")
	self.can_reward = self:FindVariable("can_reward")
	self:ListenEvent("close_view", BindTool.Bind(self.OnClose, self))
	self:ListenEvent("OnClickZhiShengYiJie", BindTool.Bind(self.OnClickZhiShengYiJie, self))

	for i = 1, 7 do
		self:ListenEvent("OnClickItem" .. i, BindTool.Bind(self.OnClickItem, self, i))
		self:ListenEvent("OnClickItemNotOpen"..i, BindTool.Bind(self.OnClickItemNotOpen, self, i))
	end

	for i = 1, 7 do
		self.show_item[i] = self:FindVariable("show_item" .. i)
		self.show_select[i] = self:FindVariable("ShowSelect" .. i)
	end

	self.reward_slider = self:FindVariable("reward_slider")
	self.role_name = self:FindVariable("role_name")
	self.self_rank = self:FindVariable("self_rank")
	self.role_power = self:FindVariable("role_power")
	self.image_obj = self:FindObj("image_obj")
	self.word_bg = self:FindVariable("word_bg")
	self.word1 = self:FindVariable("word1")
	self.word2 = self:FindVariable("word2")
	self.show_rest_day = self:FindVariable("ShowRestDay")
	self.rest_day = self:FindVariable("RestDay")
	self.rest_hour = self:FindVariable("RestHour")
	self.rest_min = self:FindVariable("RestMin")
	self.rest_sec = self:FindVariable("RestSecond")
	self.attr_desc = self:FindVariable("AttrDesc")
	self.model_effect = self:FindObj("ModelEffect")
	self.show_get_btn = self:FindVariable("ShowGetBtn")
	self.get_btn_text = self:FindVariable("GetBtnText")
	self.reward_day_txt = self:FindVariable("RewardDayTxt")
	self.show_effect = self:FindVariable("ShowEffect")
	self.title_image = self:FindVariable("Title")
end

function CompetitionActivityView:OpenCallBack()
	self:OnClickItem(TimeCtrl.Instance:GetCurOpenServerDay())

	local end_act_day = 0--GameEnum.NEW_SERVER_DAYS - TimeCtrl.Instance:GetCurOpenServerDay()
	if end_act_day == 0 then
		local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
		local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
		local reset_time_s = 24 * 3600 - cur_time
		self.show_rest_day:SetValue(false)
		self:SetRestTime(reset_time_s)
	else
		self.rest_day:SetValue(end_act_day)
		self.show_rest_day:SetValue(true)
	end
	self:Flush()
end

function CompetitionActivityView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.temp_display_role = nil
	self.day_type = 0
end

function CompetitionActivityView:OnClickZhiShengYiJie()
	ViewManager.Instance:Open(ViewName.LeiJiDailyView)
	self:Close()
end

function CompetitionActivityView:OnClose()
	self:Close()
end

-- 点击查看排行榜
function CompetitionActivityView:OnClickPaiHangBang()
	local bipin_cfg = CompetitionActivityData.Instance:GetBiPinActTypeList()
	if nil == bipin_cfg or nil == bipin_cfg[self.day_type] then
		return
	end
	local index = bipin_cfg[self.day_type].bipin_ranktype
	local rank_view = RankCtrl.Instance:GetRankView()
	rank_view:SetCurIndex(index)
	rank_view:SetCurtype(self.rank_type)
	RankCtrl.Instance:SendGetPersonRankListReq(self.rank_type)
	ViewManager.Instance:Open(ViewName.Ranking)
end

function CompetitionActivityView:GetNumberOfCells()
	return (#KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type) - 2)
end

function CompetitionActivityView:RefreshCell(cell, data_index)
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(self.activity_type)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelSixListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local is_get = KaifuActivityData.Instance:IsGetReward(data_index + 2, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(data_index + 2, self.activity_type)

	cell_item:SetData(cfg[data_index + 2], is_get, is_complete)
	cell_item:ListenClick(BindTool.Bind(self.OnClickGet, self, cfg[data_index + 2], is_get, is_complete))
end

function CompetitionActivityView:OnClickGet(cfg, is_get, is_complete)
	if cfg and is_complete and not is_get then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type,
			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, cfg.seq or 0)
	end
end

function CompetitionActivityView:OnClickItem(day_type)
	local bipin_cfg = CompetitionActivityData.Instance:GetBiPinActTypeList()
	if nil == bipin_cfg or nil == bipin_cfg[day_type] then
		return
	end

	for k, v in pairs(bipin_cfg) do
		if ActivityData.Instance:GetActivityIsOpen(v.activity_type) and day_type == k then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			break
		end
	end

	local rank_type_list = RankData.Instance:GetRankTypeList()
	local rank_type = bipin_cfg[day_type].bipin_ranktype
	RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[rank_type])

	if self.day_type == day_type then return end
	self.day_type = day_type
	self.rank_type = rank_type_list[rank_type]

	self:FlushInfo(bipin_cfg[day_type].activity_type)

	for i = 1, 7 do
		self.show_select[i]:SetValue(i == day_type)
	end

	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self.can_reward:SetValue(server_day == day_type)

	if self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL then
		self.attr_desc:SetValue(Language.CompetitionActivity.StrengthLevelDesc)
	elseif self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
		self.attr_desc:SetValue(Language.CompetitionActivity.StoneLevelDesc)
	else
		self.attr_desc:SetValue(Language.CompetitionActivity.TotalAttrDesc)
	end
	self:FlushBtnReward()
end

function CompetitionActivityView:OnClickItemNotOpen(i)
	if i == TimeCtrl.Instance:GetCurOpenServerDay() then
		self:OnClickItem(TimeCtrl.Instance:GetCurOpenServerDay())
		return
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.CompetitionActivity.HasNotOpen)
end

function CompetitionActivityView:FlushInfo(activity_type)
	self.activity_type = activity_type or self.activity_type
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	if nil == cfg or nil == next(cfg) then
		return
	end

	local rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(self.activity_type)
	if rank_info then
		if rank_info.top1_uid and rank_info.top1_uid <= 0 then
			self.cur_day_title:SetValue(Language.Activity.NoFirstRole)
		else
			self.cur_day_title:SetValue(rank_info.role_name or "")
		end
	end
	-- end
	self.is_up_one_grade:SetValue(activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPIRIT and activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PERSON_CAPABILITY)

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	if self.activity_type == self.temp_activity_type then
		self.list.scroller:RefreshActiveCellViews()
	else
		if self.list.scroller.isActiveAndEnabled then
			self.list.scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = self.activity_type

	local item_gift_list = ItemData.Instance:GetGiftItemListByProf(cfg[1].reward_item[0].item_id)
	local display_role = 0
	local item_cfg = nil
	local item_id = 0
	local title_id = 0
	local is_destory_effect = true

	for k, v in pairs(self.item_list) do
		v:SetActive(nil ~= item_gift_list[k])
		if item_gift_list[k] then
			v:SetGiftItemId(cfg[1].reward_item[0].item_id)
			for _, v2 in pairs(cfg[1].item_special or {}) do
				if v2.item_id == item_gift_list[k].item_id then
					v:IsDestoryActivityEffect(false)
					v:SetActivityEffect()
					is_destory_effect = false
					break
				end
			end

			if is_destory_effect then
				v:IsDestoryActivityEffect(false)
				v:SetActivityEffect()
			end

			v:SetData(item_gift_list[k])
			item_cfg = ItemData.Instance:GetItemConfig(item_gift_list[k].item_id)
			if display_role == 0 then
				display_role = item_cfg and item_cfg.is_display_role or 0
				item_id = item_gift_list[k].item_id
			end
			if title_id == 0 and item_cfg and item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE then
				title_id = item_gift_list[k].item_id
			end
		end
	end
	local title_item_cfg = ItemData.Instance:GetItemConfig(title_id)
	self.show_effect:SetValue(false)
	if title_item_cfg and title_item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE then
		self.show_effect:SetValue(true)
		local bundle, asset = ResPath.GetTitleIcon(title_item_cfg.param1)
		self.title_image:SetAsset(bundle, asset)
		self.fight_power:SetValue(title_item_cfg.power)
	else
		self:SetRoleModel(display_role, item_id)
		self:SetFightPower(display_role, item_id)
	end

	self.desc:SetValue(cfg[#cfg].description)

	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for i = 1, GameEnum.NEW_SERVER_DAYS do
		self.show_item[i]:SetValue(server_day <= i)
	end

	self.reward_slider:SetValue((server_day - 1) / (GameEnum.NEW_SERVER_DAYS - 1))

	local bundle, asset = ResPath.GetCompetitionActivity("word_" .. self.day_type)
	self.word_bg:SetAsset(bundle, asset)

	self.word1:SetValue(cfg[1].activity_first_word)
	self.word2:SetValue(cfg[1].activity_second_word)
end

function CompetitionActivityView:FlushBtnReward()
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	if cfg == nil then
		return
	end

	local is_reward = KaifuActivityData.Instance:IsGetReward(cfg[#cfg].seq, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(cfg[#cfg].seq, self.activity_type)
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()

	self.show_get_btn:SetValue(not is_reward)
	self.can_reward:SetValue(is_complete and not is_reward and server_day == self.day_type)

	local btn_str = server_day == self.day_type and Language.Common.LingQuJiangLi or Language.Common.HadOverdue
	self.get_btn_text:SetValue(btn_str)
end

function CompetitionActivityView:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.rest_hour:SetValue(left_hour)
			self.rest_min:SetValue(left_min)
			self.rest_sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self:CancelCountDown()
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function CompetitionActivityView:CancelCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function CompetitionActivityView:SetRoleModel(display_role, item_id)
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0

	if self.model and self.temp_display_role ~= display_role then
		local halo_part = self.model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = self.model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = self.model.draw_obj:GetPart(SceneObjPart.Wing)
		if halo_part then
			halo_part:RemoveModel()
		end
		if wing_part then
			wing_part:RemoveModel()
		end
		if weapon_part then
			weapon_part:RemoveModel()
		end
		self.model:ClearModel()
	end

	if self.temp_display_role ~= display_role or self.temp_display_role == DISPLAY_TYPE.FASHION then
		self.temp_display_role = display_role
		if display_role == DISPLAY_TYPE.MOUNT then
			for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					bundle, asset = ResPath.GetMountModel(v.res_id)
					res_id = v.res_id
					break
				end
			end
			self.model:SetPanelName("competition_activity_panel_mount")
		elseif display_role == DISPLAY_TYPE.WING then
			for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			self.model:SetPanelName("competition_activity_panel_wing")
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWingResid(res_id)
		elseif display_role == DISPLAY_TYPE.FASHION then
			for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
				if v.active_stuff_id == item_id then
					local weapon_res_id = 0
					local weapon2_res_id = 0
					local temp_res_id = 0
					if v.part_type == 1 then
						temp_res_id = v["resouce"..game_vo.prof..game_vo.sex]
						weapon_res_id = main_role:GetWeaponResId()
						weapon2_res_id = main_role:GetWeapon2ResId()
					else
						temp_res_id = main_role:GetRoleResId()
						weapon_res_id = v["resouce"..game_vo.prof..game_vo.sex]
						local temp = Split(weapon_res_id, ",")
						weapon_res_id = temp[1]
						weapon2_res_id = temp[2]
					end
					self.model:SetPanelName("competition_activity_panel_fashion")
					self.model:SetRoleResid(temp_res_id)
					self.model:SetWeaponResid(weapon_res_id)
					if weapon2_res_id then
						self.model:SetWeapon2Resid(weapon2_res_id)
					end
					-- self.model:SetModelTransformParameter("role_model", 001001, DISPLAY_PANEL.ADVANCE_SUCCE)
					-- bundle, asset = ResPath.GetRoleModel(res_id)
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.HALO then
				for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
					if v.item_id == item_id then
						res_id = v.res_id
						break
					end
				end
				self.model:SetPanelName("competition_activity_panel_halo")
				self.model:SetRoleResid(main_role:GetRoleResId())
				self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
				self.model:SetFootResid(res_id)
		elseif display_role == DISPLAY_TYPE.SPIRIT then
			for k, v in pairs(SpiritData.Instance:GetHuanHuaSpiritResourceCfg()) do
				if v.item_id == item_id then
					bundle, asset = ResPath.GetSpiritModel(v.res_id)
					res_id = v.res_id
					break
				end
			end
			self.model:SetPanelName("competition_activity_panel_spirit")
		elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
			for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					bundle, asset = ResPath.GetFightMountModel(v.res_id)
					res_id = v.res_id
					break
				end
			end
			self.model:SetPanelName("competition_activity_panel_fightmount")
		elseif display_role == DISPLAY_TYPE.SHENGONG then
			for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					local info = {}
					info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
					info.weapon_res_id = v.res_id
					self:SetModel(info, DISPLAY_TYPE.SHENGONG)
					self.title_asset:SetAsset('', '')
					return
				end
			end
		elseif display_role == DISPLAY_TYPE.SHENYI then
			for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					local info = {}
					info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
					info.wing_res_id = v.res_id
					self:SetModel(info, DISPLAY_TYPE.SHENYI)
					self.title_asset:SetAsset('', '')
					return
				end
			end
		elseif display_role == DISPLAY_TYPE.XIAN_NV then
			local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
			self.model:SetPanelName("competition_activity_panel_xiannv")
			if goddess_cfg then
				local xiannv_resid = 0
				local xiannv_cfg = goddess_cfg.xiannv
				if xiannv_cfg then
					for k, v in pairs(xiannv_cfg) do
						if v.active_item == item_id then
							xiannv_resid = v.resid
							break
						end
					end
				end
				if xiannv_resid == 0 then
					local huanhua_cfg = goddess_cfg.huanhua
					if huanhua_cfg then
						for k, v in pairs(huanhua_cfg) do
							if v.active_item == item_id then
								xiannv_resid = v.resid
								break
							end
						end
					end
				end
				if xiannv_resid > 0 then
					local info = {}
					info.role_res_id = xiannv_resid
					bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
					self:SetModel(info, DISPLAY_TYPE.XIAN_NV)
					self.model:SetTrigger("show_idle_1")
					return
				end
				res_id = xiannv_resid
			end
		elseif display_role == DISPLAY_TYPE.BUBBLE then
			-- self.show_ani:SetValue(true)

			local index = CoolChatData.Instance:GetBubbleIndexByItemId(item_id)
			if index > 0 then
				local PrefabName = "BubbleChat" .. index

				PrefabPool.Instance:Load(AssetID("uis/chatres", PrefabName), function(prefab)
					if prefab then
						local obj = GameObject.Instantiate(prefab)
						PrefabPool.Instance:Free(prefab)
						local transform = obj.transform
						for i = 0, self.ani_obj.transform.childCount - 1 do
							local child = self.ani_obj.transform:GetChild(i)
							if child then
								GameObject.Destroy(child.gameObject)
							end
						end
						transform:SetParent(self.ani_obj.transform, false)
					end
				end)
			end
		elseif display_role == DISPLAY_TYPE.ZHIBAO then
			for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
				if v.active_item == item_id then
					bundle, asset = ResPath.GetBaoJuModel(v.image_id)
					res_id = v.image_id
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.TITLE then 	-- 称号
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			self.title_asset:SetAsset(ResPath.GetTitleModel(item_cfg and item_cfg.param1 or 0))
		end
	end

	if self.model and res_id > 0 then
		-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[display_role], res_id, DISPLAY_PANEL.ADVANCE_SUCCE)
	end
	-- self.can_reset_ani = display_role ~= DISPLAY_TYPE.FIGHT_MOUNT
	if bundle and asset and self.model then
		self.model:SetMainAsset(bundle, asset)
		if display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
			self.model:SetTrigger("rest")
		end
	elseif display_role == DISPLAY_TYPE.TITLE then
		if self.model then
			self.model:ClearModel()
		end
	end

	if display_role ~= DISPLAY_TYPE.TITLE then
		self.title_asset:SetAsset('', '')
	end
end

function CompetitionActivityView:SetFightPower(display_role, item_id)
	local fight_power = 0
	local cfg = {}

	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FASHION then
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == item_id then
				cfg = FashionData.Instance:GetFashionUpgradeCfg(v.index, v.part_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		-- for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
		-- 	if v.id == item_id then
		-- 	end
		-- end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		for k, v in pairs(goddess_cfg.huanhua) do
			if v.active_item == item_id then
				cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))

	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetZhiBaoHuanHua()) do
			if v.stuff_id == item_id then
				cfg = ZhiBaoData.Instance:GetHuanHuaLevelCfg(v.huanhua_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.TITLE then
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		cfg = TitleData.Instance:GetTitleCfg(item_cfg and item_cfg.param1 or 0)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	end

	self.fight_power:SetValue(fight_power)
end

function CompetitionActivityView:SetModel(info, display_type)
	self.model:ResetRotation()
	self.model:SetGoddessModelResInfo(info)
end

function CompetitionActivityView:FlushRankInfo()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local bipin_cfg = CompetitionActivityData.Instance:GetBiPinActTypeList()
	if nil == bipin_cfg or nil == bipin_cfg[server_day] then
		return
	end

	self.role_name:SetValue(Language.Competition.NoRank)
	self.role_power:SetValue("")

	local active_rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(bipin_cfg[server_day].activity_type)

	if nil == active_rank_info or nil == next(active_rank_info) or active_rank_info.top1_uid <= 0 then
		self.self_rank:SetValue(Language.Competition.NotOnTheList)
		return
	end
	if active_rank_info.myself_rank < 100 then
		self.self_rank:SetValue(string.format(Language.Competition.Rank, active_rank_info.myself_rank + 1))
	else
		self.self_rank:SetValue(Language.Competition.NotOnTheList)
	end
	self.role_name:SetValue(active_rank_info.role_name)
	self.role_power:SetValue(tostring(active_rank_info.capability))
end

function CompetitionActivityView:OnFlush(param_list)
	self:FlushRankInfo()
end

PanelSixListCell = PanelSixListCell or BaseClass(BaseRender)
function PanelSixListCell:__init(instance)
	self.desc= self:FindVariable("Desc")
	self.cells = {}
	for i = 1, 3 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self:FindObj("Item"..i))
		self.cells[i] = cell
	end
	self.show_btn = self:FindVariable("ShowGetBtn")
	self.show_had_imag = self:FindVariable("ShowHad")

	self.get_btn = self:FindObj("GetButton")
end

function PanelSixListCell:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function PanelSixListCell:SetData(data, is_get, is_complete)
	if data == nil then return end
	self.desc:SetValue(data.description)

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_list = {}
	local gift_id = 0

	for k, v in pairs(data.reward_item) do
		local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			gift_id = v.item_id
			local item_gift_list = ItemData.Instance:GetGiftItemList(v.item_id)
			if gift_cfg and gift_cfg.rand_num and gift_cfg.rand_num > 0 then
				item_gift_list = {v}
			end
			for _, v2 in pairs(item_gift_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.item_id)
				if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
					table.insert(item_list, v2)
				end
			end
		else
			table.insert(item_list, v)
		end
	end

	local is_destory_effect = true
	for k, v in pairs(self.cells) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			for _, v2 in pairs(data.item_special or {}) do
				if v2.item_id == item_list[k].item_id then
					v:IsDestoryActivityEffect(false)
					v:SetActivityEffect()
					is_destory_effect = false
					break
				end
			end

			if is_destory_effect then
				v:IsDestoryActivityEffect(is_destory_effect)
				v:SetActivityEffect()
			end

			v:SetGiftItemId(gift_id)
			v:SetData(item_list[k])
		end
	end

	self.get_btn.button.interactable = is_complete
end

function PanelSixListCell:ListenClick(handler)
	self:ListenEvent("OnClickGet", handler)
end