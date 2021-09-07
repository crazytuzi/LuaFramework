CompetitionActivityView = CompetitionActivityView or BaseClass(BaseView)

local rank_type_list ={
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL ,			--战力榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL,					--等级榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP,					--装备榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT, 					--坐骑榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING, 					--羽翼榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO, 					--光环榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT,				--战骑
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING, 		--精灵总榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY, 		--女神总榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG, 				--神弓榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI, 					--神翼榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM, 				--魅力总榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL,		--全身装备强化总等级榜
	PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL,		--全身宝石总等级榜
}

local RankType = {
	EQUIP = 1,
	MOUNT = 4,
	WING = 5,
	HALO = 6,
	SHENGONG = 10,
	SHENYI = 11,
	STRENGTH = 13,
	STONE = 14,
}

local PaiHangBang_Index = {
	RankType.MOUNT,
	RankType.WING,
	RankType.SHENGONG,
	RankType.SHENYI,
	RankType.HALO,
	RankType.STRENGTH,
	RankType.STONE,
}

local Model_Config = {
	[DISPLAY_TYPE.MOUNT] = {
		rotation = Vector3(0, 45, 0),
		scale = Vector3(0.5, 0.5, 0.5),
	},
	[DISPLAY_TYPE.WING] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(0.8, 0.8, 0.8),
	},
	[DISPLAY_TYPE.HALO] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[DISPLAY_TYPE.FIGHT_MOUNT] = {
		rotation = Vector3(90, 0, 0),
		scale = Vector3(0.7, 0.7, 0.7),
	},
	[DISPLAY_TYPE.SPIRIT_HALO] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[DISPLAY_TYPE.SPIRIT_FAZHEN] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[DISPLAY_TYPE.SHENYI] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
}

-- local COMPETITION_ACTIVITY_TYPE = {
-- 	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK,
-- 	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK,
-- 	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK,
-- 	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK,
-- 	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK,
-- 	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK,
-- 	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK,
-- }

function CompetitionActivityView:__init()
	self.ui_config = {"uis/views/competitionactivityview","CompetitionActivityView"}
	self.play_audio = true
	self.item_list = {}
	self.cell_list = {}
	self.reward_item_list = {}
	self.show_item = {}
	self.show_select = {}
	self.day_type = 0
	self.rank_type = 8
	self.is_flush = true
	self.is_stop_load_effect = false
	self:SetMaskBg()
end

function CompetitionActivityView:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil
	self.temp_display_role = nil
end

function CompetitionActivityView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.equip_bg_effect_obj  ~= nil then
		GameObject.Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end

	-- 清理变量和对象
	self.list = nil
	self.list_delegate = nil
	self.cur_day_title = nil
	self.first_name = nil
	self.portrait_asset_imag = nil
	self.fight_power = nil
	self.title_asset = nil
	self.portrait_raw_image_obj = nil
	self.portrait_image_obj = nil
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
	self.des_jieshu = nil
	self.my_jieshu = nil
	self.show_reward= nil
	self.top_one_grade = nil
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

	self.portrait_raw_image_obj = self:FindObj("PortraitRawImage")
	self.portrait_image_obj = self:FindObj("PortraitImage")

	self:ListenEvent("OnClickPaiHangBang", BindTool.Bind(self.OnClickPaiHangBang, self))
	self:ListenEvent("OnClickZhuLiOpen", BindTool.Bind(self.OnClickZhuLiOpen, self))
	for i = 1, 4 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self:FindObj("Item"..i))
		self.item_list[i] = cell
	end

	self.model_display = self:FindObj("ModelDisplay")
	self.model = RoleModel.New("bipin_model_2")
	self.model:SetDisplay(self.model_display.ui3d_display)

	for i = 1, 2 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self:FindObj("RewardItem"..i))
		self.reward_item_list[i] = cell
	end
	self.desc = self:FindVariable("Desc")
	self.can_reward = self:FindVariable("can_reward")
	self:ListenEvent("close_view", BindTool.Bind(self.OnClose, self))
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGetReward, self))
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
	self.role_power = self:FindVariable("role_power")
	self.image_obj = self:FindObj("image_obj")
	self.raw_image_obj = self:FindObj("raw_image_obj")
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
	self.des_jieshu = self:FindVariable("DesJieshu")
	self.my_jieshu = self:FindVariable("MyJieshu")
	self.show_reward = self:FindVariable("ShowReward")
	self.top_one_grade = self:FindVariable("TopOneGrade")
	self.is_target = false
end

function CompetitionActivityView:OpenCallBack()
	self:OnClickItem(TimeCtrl.Instance:GetCurOpenServerDay())
	-- self:Flush(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK)

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

	self.is_loading = true

	-- PrefabPool.Instance:Load(AssetID("effects2/prefab/ui_prefab", "UI_tongyongbaoju_1"), function(prefab)
	-- 	if prefab then
	-- 		if self.is_stop_load_effect then
	-- 			self.is_stop_load_effect = false
	-- 			self.is_loading = false
	-- 			return
	-- 		end
	-- 		if self.equip_bg_effect_obj  ~= nil then
	-- 			GameObject.Destroy(self.equip_bg_effect_obj)
	-- 			self.equip_bg_effect_obj = nil
	-- 		end
	-- 		local obj = GameObject.Instantiate(prefab)
	-- 		PrefabPool.Instance:Free(prefab)
	-- 		local transform = obj.transform
	-- 		transform:SetParent(self.model_effect.transform, false)
	-- 		transform.localScale = Vector3(3, 3, 3)
	-- 		self.equip_bg_effect_obj = obj.gameObject
	-- 		self.color = 0
	-- 		self.is_loading = false
	-- 	end
	-- end)
end

function CompetitionActivityView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.temp_display_role = nil

	self.day_type = 0

	if self.equip_bg_effect_obj  ~= nil then
		GameObject.Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end

	if self.is_loading then
		self.is_stop_load_effect = true
	end
end

function CompetitionActivityView:OnClickZhiShengYiJie()
	ViewManager.Instance:Open(ViewName.KaifuActivityView, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUNDER_TIMES_SHOP + 100000)
	self:Close()
end

function CompetitionActivityView:OnClose()
	ViewManager.Instance:Close(ViewName.CompetitionActivity)
end

-- 点击查看排行榜
function CompetitionActivityView:OnClickPaiHangBang()
	local grade, jinjie_type = KaifuActivityData.Instance:GetCondByType(self.activity_type)
	if RankCtrl.Instance and jinjie_type then
		local index = PaiHangBang_Index[self.day_type]
		if self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL
			or self.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL then
			self.rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
			-- index = RankType.EQUIP
			self.is_flush = false
		end
		local rank_view = RankCtrl.Instance:GetRankView()
		rank_view:SetCurIndex(index)
		RankCtrl.Instance:SendGetPersonRankListReq(self.rank_type)
		RankData.Instance:SetRankToProductId(RANK_TOGGLE_TYPE.XING_XIANG_BANG + 1, self.day_type)
		ViewManager.Instance:Open(ViewName.Ranking)
	end
end

function CompetitionActivityView:OnClickZhuLiOpen()
	ViewManager.Instance:Open(ViewName.KaiFuChargeView, TabIndex.kaifu_rising_star)
	self:Close()
end

function CompetitionActivityView:GetNumberOfCells()
	return 3
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

function CompetitionActivityView:OnClickGetReward()
	--local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)

	-- KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type,
	-- 		RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, #cfg or 0)
	local seq = KaifuActivityData.Instance:GetRewardSeq(self.activity_type)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type,
			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH,seq)
end

function CompetitionActivityView:OnClickItem(day_type)
	self.is_flush = true
	for k, v in pairs(COMPETITION_ACTIVITY_TYPE) do
		if ActivityData.Instance:GetActivityIsOpen(v) and day_type == k then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			break
		end
	end
	RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[PaiHangBang_Index[day_type]])

	if self.day_type == day_type then return end
	self.day_type = day_type
	self.rank_type = rank_type_list[PaiHangBang_Index[self.day_type]]
	self:Flush(COMPETITION_ACTIVITY_TYPE[day_type])
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
	self:CurValueGrade()
	self:FlushBtnReward()
end

function CompetitionActivityView:OnClickItemNotOpen(i)
	if i == TimeCtrl.Instance:GetCurOpenServerDay() then
		self:OnClickItem(TimeCtrl.Instance:GetCurOpenServerDay())
		return
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.CompetitionActivity.HasNotOpen)
end

function CompetitionActivityView:FlushRankInfo()
	if not self.is_flush then return end
	local rank_data = RankData.Instance:GetRankList()
	self.role_name:SetValue(Language.Competition.NoRank)
	self.role_power:SetValue("")
	self.image_obj.gameObject:SetActive(false)
	self.raw_image_obj.gameObject:SetActive(false)
	if nil == next(rank_data) then return end
	self.role_name:SetValue(rank_data[1].user_name)
	self.role_power:SetValue(rank_data[1].rank_value)

	local user_id = 0
	local avatar_key_big = 0
	local avatar_key_small = 0
	local prof = 0
	local sex = 0
	if rank_data[1] then
		user_id = rank_data[1].user_id
		avatar_key_big = rank_data[1].avatar_key_big
		avatar_key_small = rank_data[1].avatar_key_small
		prof = rank_data[1].prof
		sex = rank_data[1].sex
	else
		local vo = GameVoManager.Instance:GetMainRoleVo()
		user_id = vo.role_id
		avatar_key_big = vo.avatar_key_big
		avatar_key_small = vo.avatar_key_small
		prof = vo.prof
		sex = vo.sex
	end
	AvatarManager.Instance:SetAvatarKey(user_id, avatar_key_big, avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(user_id)
	if AvatarManager.Instance:isDefaultImg(user_id) == 0 or avatar_path_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(prof, false, sex)
		self.image_obj.image:LoadSprite(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(user_id, false)
			end
			self.raw_image_obj.raw_image:LoadSprite(path, function ()
				self.image_obj.gameObject:SetActive(false)
				self.raw_image_obj.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(user_id, false, callback)
	end

	CheckCtrl.Instance:SendQueryRoleInfoReq(user_id)
end

-- function CompetitionActivityView:FlushRoleInfo()
-- 	local data = CheckCtrl.Instance.data:GetRoleInfo()
-- 	if self.role_power then
-- 		self.role_power:SetValue(data.rank_value)
-- 	end
-- end
function CompetitionActivityView:CurValueGrade()
	local info
	local reward_list = {}
	local item_list = {}
	if self.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK then -- 坐骑
		info = MountData.Instance:GetMountInfo()  
	elseif self.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK then -- 羽翼
		info = WingData.Instance:GetWingInfo() 
	elseif self.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK then -- 天罡
		info = HaloData.Instance:GetHaloInfo()
	elseif self.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK then -- 法印
		info = FaZhenData.Instance:GetFightMountInfo()
	elseif self.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK then -- 芳华
		info = BeautyHaloData.Instance:GetBeautyHaloInfo()
	elseif self.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN then -- 圣物
		info = HalidomData.Instance:GetHalidomInfo() 
	elseif self.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE then -- 披风
		info = ShenyiData.Instance:GetShenyiInfo() 
	end
	if info ~= nil then
		local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
		if cfg == nil then return end
		self.des_jieshu:SetValue(Language.CompetitionActivity.Type_Text_List[self.activity_type])
			self.my_jieshu:SetValue(KaiFuChargeData.Instance:ConvertGrade(info.grade))
			self.show_reward:SetValue(cfg[1].activity_second_word)

		local index_seq = KaifuActivityData.Instance:GetRewardSeq(self.activity_type)
		index_seq = index_seq > 9 and 9 or index_seq
		for i,v in ipairs(cfg) do
			if v.seq == index_seq then
				self.desc:SetValue(v.description)
				if info.grade >= v.cond2 then
					self.is_target = true
				else
					self.is_target = false
				end
				 reward_list = v.reward_item

				for k, v in pairs(reward_list) do
					local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
					if big_type == GameEnum.ITEM_BIGTYPE_GIF then
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
				for k, v in pairs(self.reward_item_list) do
					v:SetActive(nil ~= item_list[k])
					if item_list[k] then
						v:SetData(item_list[k])
					end
				end
				return
			end
		end
	end
end

function CompetitionActivityView:Flush(activity_type)
	self.activity_type = activity_type or self.activity_type
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	-- if jinjie_type then
	local rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(self.activity_type)
	if rank_info then
		if rank_info.top1_uid and rank_info.top1_uid <= 0 then
			self.cur_day_title:SetValue(Language.Activity.NoFirstRole)
			self.top_one_grade:SetValue("")
		else
			self.cur_day_title:SetValue(rank_info.role_name or "")
			self.top_one_grade:SetValue(KaiFuChargeData.Instance:ConvertGrade(rank_info.top1_param or 0))
		end
	end
	-- end
	self.is_up_one_grade:SetValue(activity_type ~= RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN_RANK and activity_type ~= RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE_RANK)

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

	local item_gift_list = ItemData.Instance:GetGiftItemList(cfg[1].reward_item[0].item_id)
	local display_role = 0
	local item_cfg = nil
	local item_id = 0
	local is_destory_effect = true

	for k, v in pairs(self.item_list) do
		v:SetActive(nil ~= item_gift_list[k])
		if item_gift_list[k] then
			v:SetGiftItemId(cfg[1].reward_item[0].item_id)

			if k == 1 then
				v:IsDestoryActivityEffect(false)
				v:SetActivityEffect()
			end

			v:SetData(item_gift_list[k])
			item_cfg = ItemData.Instance:GetItemConfig(item_gift_list[k].item_id)
			if display_role == 0 then
				display_role = item_cfg and item_cfg.is_display_role or 0
				item_id = item_gift_list[k].item_id
			end
		end
	end

	-- self:SetFirstInfo(activity_type)

	self:SetRoleModel(display_role, item_id)
	self:SetFightPower(display_role, item_id)

	-- local item_list = {}
	-- local reward_list = cfg[#cfg].reward_item
	-- for k, v in pairs(reward_list) do
	-- 	local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
	-- 	if big_type == GameEnum.ITEM_BIGTYPE_GIF then
	-- 		local item_gift_list = ItemData.Instance:GetGiftItemList(v.item_id)
	-- 		if gift_cfg and gift_cfg.rand_num and gift_cfg.rand_num > 0 then
	-- 			item_gift_list = {v}
	-- 		end
	-- 		for _, v2 in pairs(item_gift_list) do
	-- 			local item_cfg = ItemData.Instance:GetItemConfig(v2.item_id)
	-- 			if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
	-- 				table.insert(item_list, v2)
	-- 			end
	-- 		end
	-- 	else
	-- 		table.insert(item_list, v)
	-- 	end
	-- end

	-- for k, v in pairs(self.reward_item_list) do
	-- 	v:SetActive(nil ~= item_list[k])
	-- 	if item_list[k] then
	-- 		v:SetData(item_list[k])
	-- 	end
	-- end

	--self.desc:SetValue(cfg[#cfg].description)

	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for i = 1, GameEnum.NEW_SERVER_DAYS do
		self.show_item[i]:SetValue(server_day <= i)
	end

	self.reward_slider:SetValue((server_day - 1) / (GameEnum.NEW_SERVER_DAYS - 1))

	local day = self.day_type < GameEnum.NEW_SERVER_DAYS and self.day_type or 6
	local bundle, asset = ResPath.GetCompetitionActivity("word_" .. day)
	self.word_bg:SetAsset(bundle, asset)

	self.word1:SetValue(cfg[1].activity_first_word)
	self.word2:SetValue(cfg[1].activity_second_word)
	self:CurValueGrade()
	self:FlushBtnReward()
end

function CompetitionActivityView:FlushBtnReward()
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	if cfg then
		local is_reward = false
		local is_complete = false
		for i=5, #cfg do
			 is_reward = KaifuActivityData.Instance:IsGetReward(cfg[i].seq, self.activity_type)
			 if not is_reward then break end
		end
		for i=5, #cfg do
			 is_complete = KaifuActivityData.Instance:IsComplete(cfg[i].seq, self.activity_type)
			 if is_complete then break end
		end
		--local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
		--self.show_get_btn:SetValue(not is_reward)
		self.can_reward:SetValue(is_complete and not is_reward and self.is_target) --and server_day == self.day_type)
		--local btn_str = server_day == self.day_type and Language.Common.LingQu or Language.Common.HadOverdue
		local btn_str = is_reward and Language.Common.YiLingQu or Language.Common.LingQu
		self.get_btn_text:SetValue(btn_str)
	end
	--local is_reward = KaifuActivityData.Instance:IsGetReward(cfg[#cfg].seq, self.activity_type)
	--local is_complete = KaifuActivityData.Instance:IsComplete(cfg[#cfg].seq, self.activity_type)
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
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function CompetitionActivityView:SetRoleModel(display_role, item_id)
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	self.model:SetDisplayPositionAndRotation("bipin_model_" .. display_role)

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
		elseif display_role == DISPLAY_TYPE.WING then
			for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
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
					self.model:SetRoleResid(temp_res_id)
					self.model:SetWeaponResid(weapon_res_id)
					if weapon2_res_id then
						self.model:SetWeapon2Resid(weapon2_res_id)
					end
					self.model:SetModelTransformParameter("role_model", 001001, DISPLAY_PANEL.ADVANCE_SUCCE)
					-- bundle, asset = ResPath.GetRoleModel(res_id)
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.HALO then
				for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
					if v.item_id == item_id then
						res_id = v.res_id
						break
					end
				end
				self.model:SetRoleResid(main_role:GetRoleResId())
				self.model:SetHaloResid(res_id)
		elseif display_role == DISPLAY_TYPE.SPIRIT then
			for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
				if v.id == item_id then
					bundle, asset = ResPath.GetSpiritModel(v.res_id)
					res_id = v.res_id
					break
				end
			end
		elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
			for k, v in pairs(FaZhenData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					bundle, asset = ResPath.GetFightMountModel(v.res_id)
					res_id = v.res_id
					break
				end
			end
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
					local main_role = Scene.Instance:GetMainRole()
					info.role_res_id = main_role:GetRoleResId()
					info.wing_res_id = v.res_id
					self:SetModel(info, DISPLAY_TYPE.SHENYI)
					self.title_asset:SetAsset('', '')
					return
				end
			end
		elseif display_role == DISPLAY_TYPE.XIAN_NV then
			local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
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
					return
				end
				res_id = xiannv_resid
			end
		elseif display_role == DISPLAY_TYPE.BUBBLE then
			-- self.show_ani:SetValue(true)

			local index = CoolChatData.Instance:GetBubbleIndexByItemId(item_id)
			if index > 0 then
				local PrefabName = "BubbleChat" .. index

				PrefabPool.Instance:Load(AssetID("uis/chatres/bubbleres/" .. "bubble" .. index .. "_prefab", PrefabName), function(prefab)
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
		elseif display_role == DISPLAY_TYPE.SPIRIT_HALO then
			local spirit_halo = BeautyHaloData.Instance:GetSpecialImagesCfgByItemId()
			for k,v in pairs(spirit_halo) do
				if v.item_id == item_id then
					--获得美人资源
					local bundle_main, asset_main = ResPath.GetGoddessNotLModel(11101)
					self.model:SetMainAsset(bundle_main, asset_main)
					self.model:SetHaloResid(v.res_id, true)
					return
				end
			end
		elseif display_role == DISPLAY_TYPE.SPIRIT_FAZHEN then
			local spirit_fazhen = HalidomData.Instance:GetSpecialImagesCfg()
			if spirit_fazhen then
				for k, v in pairs(spirit_fazhen) do
					if v.item_id == item_id then
						bundle, asset = ResPath.GetBaoJuModel(v.res_id)
						break
					end
				end
			end
		end
	end

	-- if self.model and res_id > 0 then
	-- 	self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[display_role], res_id, DISPLAY_PANEL.ADVANCE_SUCCE)
	-- end
	-- self.can_reset_ani = display_role ~= DISPLAY_TYPE.FIGHT_MOUNT
	if bundle and asset and self.model then
		self.model:SetDisplayPositionAndRotation("bipin_model_" .. display_role)
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
	self.model:SetTransform(Model_Config[display_role])
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
		for k, v in pairs(FaZhenData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = FaZhenData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
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
		local beauty_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto")
		local beauty_huanhua_cfg = beauty_cfg.beauty_huanhua
		for k, v in pairs(beauty_huanhua_cfg) do
			if v.need_item == item_id then
				cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.seq, 1)
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
	local cfg = nil
	if display_type == DISPLAY_TYPE.XIAN_NV then
		self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[display_type], info.role_res_id, DISPLAY_PANEL.ADVANCE_SUCCE)
	elseif display_type == DISPLAY_TYPE.SHENYI then
		self.model:SetRoleResid(info.role_res_id)
		self.model:SetMantleResid(info.wing_res_id)
	elseif display_type == DISPLAY_TYPE.SHENGONG then
		self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[display_type], 001001, DISPLAY_PANEL.ADVANCE_SUCCE)
	end
	-- self:CalToShowAnim(true)
end

function CompetitionActivityView:SetFirstInfo(activity_type)
	local rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(activity_type)
	if rank_info  == nil or next(rank_info) == nil then return end

	local avatar_path_big = AvatarManager.Instance:GetAvatarKey(rank_info.top1_uid, true)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(rank_info.top1_uid)
	if rank_info.top1_uid <= 0 then
		self.portrait_raw_image_obj.gameObject:SetActive(false)
		self.portrait_image_obj.gameObject:SetActive(false)
		self.first_name:SetValue("")
		return
	end

	self.first_name:SetValue(rank_info.role_name)
	if AvatarManager.Instance:isDefaultImg(rank_info.top1_uid) == 0 or avatar_path_big == 0 then
		self.portrait_raw_image_obj.gameObject:SetActive(false)
		self.portrait_image_obj.gameObject:SetActive(true)
		local bundle, asset = AvatarManager.GetDefAvatar(rank_info.role_prof, false, rank_info.role_sex)
		self.portrait_asset_imag:SetAsset(bundle, asset)
		return
	end
	local callback = function (path)
		self.avatar_path_big = path or AvatarManager.GetFilePath(rank_info.top1_uid, true)
		self.portrait_raw_image_obj.raw_image:LoadSprite(self.avatar_path_big, function()
			self.portrait_raw_image_obj.gameObject:SetActive(true)
			self.portrait_image_obj.gameObject:SetActive(false)
		end)
	end
	AvatarManager.Instance:GetAvatar(rank_info.top1_uid, true, callback)
end



PanelSixListCell = PanelSixListCell or BaseClass(BaseRender)

function PanelSixListCell:__init(instance)
	self.desc = self:FindVariable("Desc")
	self.desc_lan = self:FindVariable("DescLan")
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
	self.desc_lan:SetValue(Language.CompetitionActivity.Text_List[data.seq - 1])
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

	for k, v in pairs(self.cells) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			v:SetGiftItemId(gift_id)
			v:SetData(item_list[k])
		end
	end

	-- self.show_btn:SetValue((data.cond2 and data.cond2 > 0) and not is_get)
	-- self.show_had_imag:SetValue(is_get)
	self.get_btn.button.interactable = is_complete
end

function PanelSixListCell:ListenClick(handler)
	self:ListenEvent("OnClickGet", handler)
end
