KaiFuBiPinView = KaiFuBiPinView or BaseClass(BaseView)
BiPinActiveType = {
	{active_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK, func = function () return MountData.Instance:GetMountInfo() end},
	{active_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK, func = function () return HaloData.Instance:GetHaloInfo() end},
	{active_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK, func = function () return WingData.Instance:GetWingInfo() end},
	{active_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JL_GUANGHUAN_RANK, func = function () return BeautyHaloData.Instance:GetBeautyHaloInfo() end},
	{active_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK, func = function () return ShenyiData.Instance:GetShenyiInfo() end},
	{active_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_ZHIBAO_RANK, func = function () return FaZhenData.Instance:GetFightMountInfo() end},
	{active_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FIGHT_MOUNT_RANK, func = function () return HalidomData.Instance:GetHalidomInfo() end},
}

function KaiFuBiPinView:__init()
	self.ui_config = {"uis/views/kaifuchargeview","BiPinView"}
	self:SetMaskBg()
end

function KaiFuBiPinView:OnCloseClick()
	self:Close()
end

function KaiFuBiPinView:ReleaseCallBack()
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.bipin_cell_list then
		for k,v in pairs(self.bipin_cell_list) do
			v:DeleteMe()
		end
		self.bipin_cell_list = {}
		self.bipin_cell_list = nil

	end
	if self.cell_item then
		self.cell_item:DeleteMe()
		self.cell_item = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.role_info_callback then
		GlobalEventSystem:UnBind(self.role_info_callback)
		self.role_info_callback = nil
	end

	for i=1,3 do
		if self.reward_one[i] then
			self.reward_one[i]:DeleteMe()
			self.reward_one[i] = nil
		end
	end
	self.reward_one = nil
	self.jie_shu = nil
	self.red_point = nil
	self.bipin_scroller = nil
	self.binpin_type = nil
	self.binpin_day = nil
	self.my_cur_jieshu = nil
	self.mu_biao = nil
	self.type_name = nil
	self.rest_hour = nil
	self.rest_min = nil
	self.rest_sec = nil
	self.show_rest_day = nil
	self.cur_num = nil
	self.zong_num = nil
	self.btn_enble = nil
	self.rest_day = nil
	self.role_name = nil
	self.rank_no1_jieshu = nil
	self.is_reward = nil
	self.display = nil
	self.des_jieshu = nil
end

function KaiFuBiPinView:LoadCallBack()
	self.bipin_cell_list = {}
	self.role_name = {}
	self.jie_shu = {}
	self.image_obj = {}
	self.raw_image_obj = {}
	self.reward_one = {}
	self.cur_grade = 0
	self.cur_index = 0
	self.rank_index = 0 -- 根据rank那边来赋值的
	for i=1,3 do
		self.role_name[i] = self:FindVariable("Role_Name"..i)
		self.jie_shu[i] = self:FindVariable("JieShu"..i)
		self.image_obj[i] = self:FindObj("Image_Obj"..i)
		self.raw_image_obj[i] = self:FindObj("Raw_Image_Obj"..i)
		self.reward_one[i] = ItemCell.New()
		self.reward_one[i]:SetInstanceParent(self:FindObj("ItemReward"..i))
	end

	self.binpin_type = self:FindVariable("BinPinType")
	self.binpin_day = self:FindVariable("BinPinDay")
	self.my_cur_jieshu = self:FindVariable("MyCurJieShu")
	self.mu_biao = self:FindVariable("MuBiao")
	self.type_name = self:FindVariable("TypeName")
	self.rest_hour = self:FindVariable("RestHour")
	self.rest_min = self:FindVariable("RestMin")
	self.rest_sec = self:FindVariable("RestSecond")
	self.show_rest_day = self:FindVariable("ShowRestDay")
	self.cur_num = self:FindVariable("CurNum")
	self.zong_num = self:FindVariable("ZongNum")
	self.btn_enble = self:FindVariable("BtnEnble")
	self.rest_day = self:FindVariable("RestDay")
	self.role_name = self:FindVariable("RoleName")
	self.rank_no1_jieshu = self:FindVariable("RankNo1")
	self.is_reward = self:FindVariable("IsReward")
	self.display = self:FindObj("Display")
	self.red_point = self:FindVariable("ShowRedPoint")
	self.des_jieshu = self:FindVariable("DesJieShu")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self.cell_item = ItemCell.New(self:FindObj("Item"))

	self:ListenEvent("CloseView", BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("ClickCheck", BindTool.Bind(self.OnClickCheck, self))
	self:ListenEvent("ClickReward", BindTool.Bind(self.ClickReward, self))
	self.remind_change = BindTool.Bind(self.BiPinBtnRedPoint, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.KaiFuBiPinBtn)

	self.role_info_callback = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoCallBack, self))
	KaiFuChargeCtrl.Instance:ActSendGetRankListReq()
	self:BiPinScroller()
	self:OpenCallBack()
	RemindManager.Instance:Fire(RemindName.KaiFuBiPinBtn)
end

function KaiFuBiPinView:OnClickCheck()
	RankData.Instance:SetRankToProductId(3, self.rank_index) --排行的第二个标签是形象的,rank_index是哪一形象
	ViewManager.Instance:Open(ViewName.Ranking)
end

function KaiFuBiPinView:OpenCallBack()
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
	self:SendRankNo1()

	
end

function KaiFuBiPinView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KaiFuBiPinView:OnFlush()
	self:BiPinScroller()
	self:BiPinTypeAndDay()
	self:CurValueGrade()
	if self.bipin_scroller.scroller.isActiveAndEnabled then
		self.bipin_scroller.scroller:ReloadData(0)
	end
	self:SendRankNo1()
end

-- 请求排行第一玩家数据
function KaiFuBiPinView:SendRankNo1()
	local rank_info = RankData.Instance:GetRankList()
	if rank_info[1] then
		CheckCtrl.Instance:SendQueryRoleInfoReq(rank_info[1].user_id)
	end
end

function KaiFuBiPinView:RoleInfoCallBack(role_id, protocol)
	if self.model then
		self.model:SetModelResInfo(protocol)
	end
	self.role_name:SetValue(protocol.role_name)
end

-- 点击领取奖励
function KaiFuBiPinView:ClickReward()
	local flag_seq = KaiFuChargeData.Instance:BiPinActCurRewardFlagSeq()
	local binpin_type_cfg = KaiFuChargeData.Instance:GetCurBiPinActJieShuCfg(flag_seq)
	local act = KaiFuChargeData.Instance:GetBiPinActivity()
	local flag_seq = KaiFuChargeData.Instance:BiPinActCurRewardFlagSeq()
	if self.cur_grade < binpin_type_cfg.cond2 and self.cur_index > 0 then
		ViewManager.Instance:Open(ViewName.Advance, self.cur_index)
	else
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(act, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, flag_seq)
	end
end

function KaiFuBiPinView:SetRestTime(diff_time)
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

function KaiFuBiPinView:BiPinTypeAndDay()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local activity = KaiFuChargeData.Instance:GetBiPinActivity()
	if activity == nil then return end
	local binpin_type_bundle, binpin_type_asset = ResPath.GetBiPinTypeImage(activity)
	local binpin_type_name_bundle, binpin_type_name_asset = ResPath.GetBiPinTypeNameImage(activity)
	if server_day <= 7 then
		self.binpin_type:SetAsset(binpin_type_bundle, binpin_type_asset)
		self.binpin_day:SetValue(server_day)
		self.type_name:SetAsset(binpin_type_name_bundle, binpin_type_name_asset)
	end
end

function KaiFuBiPinView:CurValueGrade()
	local mount_info = MountData.Instance:GetMountInfo()     					-- 坐骑阶数
	local halo_info = HaloData.Instance:GetHaloInfo() 		  				 	-- 光环阶数
	local wind_info = WingData.Instance:GetWingGrade() 		  				 	-- 羽翼阶数
	local meiren_guanghuan_info = BeautyHaloData.Instance:GetBeautyHaloInfo()   -- 美人光环
	local shengong_info = ShengongData.Instance:GetShengongInfo() 			 	-- 神弓阶数（足迹）
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo() 					-- 神翼阶数 （披风）
	local fight_mount_info = FaZhenData.Instance:GetFightMountInfo()     		-- 战斗坐骑
	local halidom_info = HalidomData.Instance:GetHalidomInfo() 					-- 圣物法宝
	local flag_seq = KaiFuChargeData.Instance:BiPinActCurRewardFlagSeq()
	local rank_info = RankData.Instance:GetRankList()
	local player_cur_grade = 0

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK) and mount_info.grade then
		player_cur_grade = KaiFuChargeData.Instance:ConvertGrade(mount_info.grade)
		self.cur_grade = mount_info.grade
		self.cur_index = TabIndex.mount_jinjie
		self.rank_index = 1
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK) and halo_info.star_level then
		player_cur_grade = KaiFuChargeData.Instance:ConvertGrade(halo_info.grade)
		self.cur_grade = halo_info.grade
		self.cur_index = TabIndex.halo_jinjie
		self.rank_index = 3
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK) and wind_info then
		player_cur_grade = KaiFuChargeData.Instance:ConvertGrade(wind_info)
		self.cur_grade = wind_info
		self.cur_index = TabIndex.wing_jinjie
		self.rank_index = 2
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JL_GUANGHUAN_RANK) and meiren_guanghuan_info.grade then
		player_cur_grade = KaiFuChargeData.Instance:ConvertGrade(meiren_guanghuan_info.grade)
		self.cur_grade = meiren_guanghuan_info.grade
		self.cur_index = TabIndex.meiren_guanghuan
		self.rank_index = 5
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK) and shenyi_info.grade then
		player_cur_grade = KaiFuChargeData.Instance:ConvertGrade(shenyi_info.grade)
		self.cur_grade = shenyi_info.grade
		self.cur_index = TabIndex.shenyi_jinjie
		self.rank_index = 7
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_ZHIBAO_RANK) then
		player_cur_grade = KaiFuChargeData.Instance:ConvertGrade(halidom_info.grade)
		self.cur_grade = halidom_info.grade
		self.cur_index = TabIndex.halidom_jinjie
		self.rank_index = 6
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FIGHT_MOUNT_RANK) and fight_mount_info.grade then
		player_cur_grade = KaiFuChargeData.Instance:ConvertGrade(fight_mount_info.grade)
		self.cur_grade = fight_mount_info.grade
		self.cur_index = TabIndex.fight_mount
		self.rank_index = 4
	end 
	local binpin_type_cfg = KaiFuChargeData.Instance:GetCurBiPinActJieShuCfg(flag_seq)
	if binpin_type_cfg  then
		self.mu_biao:SetValue(math.ceil(binpin_type_cfg.cond2 / 10)  .. Language.Competition.Jie)
		self.cell_item:SetData(binpin_type_cfg.reward_item[0])
	end
	self.my_cur_jieshu:SetValue(player_cur_grade)
	self.zong_num:SetValue(5)
	self.cur_num:SetValue(flag_seq - 5)
	self.btn_enble:SetValue(not(flag_seq - 5 >= 5))
	if binpin_type_cfg ~= nil then
		self.is_reward:SetValue(self.cur_grade < binpin_type_cfg.cond2 and Language.Activity.GoGrade or Language.Common.LingQuJiangLi)
	end
	if rank_info[1] then
		self.rank_no1_jieshu:SetValue(KaiFuChargeData.Instance:ConvertGrade(rank_info[1].rank_value))
	end
end

-- 前三个人排行
function KaiFuBiPinView:ShowRankNum()
	local rank_info = RankData.Instance:GetRankList()
	for i=1,3 do
		if rank_info[i] then
			local grade = KaiFuChargeData.Instance:ConvertGrade(rank_info[i].rank_value)
			self.role_name[i]:SetValue(rank_info[i].user_name)
			self.jie_shu[i]:SetValue(grade)
			AvatarManager.Instance:SetAvatarKey(rank_info[i].user_id, rank_info[i].avatar_key_big, rank_info[i].avatar_key_small)
			local avatar_path_small = AvatarManager.Instance:GetAvatarKey(rank_info[i].user_id)
			if AvatarManager.Instance:isDefaultImg(rank_info[i].user_id) == 0 or avatar_path_small == 0 then
				self.image_obj[i].gameObject:SetActive(true)
				self.raw_image_obj[i].gameObject:SetActive(false)
				local bundle, asset = AvatarManager.GetDefAvatar(rank_info[i].prof, false, rank_info[i].sex)
				self.image_obj[i].image:LoadSprite(bundle, asset)
			else
				local function callback(path)
					if IsNil(self.image_obj[i].gameObject) or IsNil(self.raw_image_obj[i].gameObject) then
						return
					end
					if path == nil then
						path = AvatarManager.GetFilePath(rank_info[i].user_id, false)
					end
					self.raw_image_obj[i].raw_image:LoadSprite(path, function ()
						self.image_obj[i].gameObject:SetActive(false)
						self.raw_image_obj[i].gameObject:SetActive(true)
					end)
				end
				AvatarManager.Instance:GetAvatar(rank_info[i].user_id, false, callback)
			end
		end
	end
end

--比拼Item
function KaiFuBiPinView:BiPinScroller()
	self.bipin_scroller = self:FindObj("BiPinItem")
	local delegate = self.bipin_scroller.list_simple_delegate
	local bipin_type = KaiFuChargeData.Instance:GetBiPinActivity()
	local data_des = KaiFuChargeData.Instance:GetBiPinActCfg(bipin_type)
	local cell_data_des = {}

	if data_des then
	    cell_data_des = TableCopy(data_des[1])
		for i=1,3 do
		--self.reward_one[i]:SetData(cell_data_des.reward_item[i-1])
		self.reward_one[i]:SetData(cell_data_des.item_special[i-1])
		end

		self.des_jieshu:SetValue(string.sub(cell_data_des.description, 0, 6))
	end		
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #KaiFuChargeData.Instance:GetBiPinActCfg(bipin_type) - 1
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		data_index = data_index + 2
		local target_cell = self.bipin_cell_list[cell]
		if nil == target_cell then
			self.bipin_cell_list[cell] = BiPinCell.New(cell.gameObject)
			target_cell = self.bipin_cell_list[cell]
			target_cell.mother_view = self
		end
		local data = KaiFuChargeData.Instance:GetBiPinActCfg(bipin_type)
		local cell_data = TableCopy(data[data_index])
		if cell_data then
			cell_data.data_index = data_index
			target_cell:SetData(cell_data)
		end
	end
end

function KaiFuBiPinView:BiPinBtnRedPoint(name, num)
	if self.red_point then
		self.red_point:SetValue(num > 0)
	end
end

---------------------------------------------------------------
--比拼滚动条格子

BiPinCell = BiPinCell or BaseClass(BaseCell)

function BiPinCell:__init()
	self.task_dec = self:FindVariable("Dec")
	self.cur_jieshu = self:FindVariable("Cur_JieShu")
	self.rank_img = self:FindVariable("RankImg")
	self.rank_num = self:FindVariable("RankNum")

	self.reward_btn_enble = self:FindVariable("BtnEnble")
	self.reward_btn_txt = self:FindVariable("RewardBtnTxt")
	self.cost = self:FindVariable("Cost")
	self.reward = {}
	for i=1,3 do
		self.reward[i] = ItemCell.New()
		self.reward[i]:SetInstanceParent(self:FindObj("Item"..i))
	end

	self:ListenEvent("Reward",
		BindTool.Bind(self.ClickLevelReward, self))

end

function BiPinCell:__delete()
	for k, v in pairs(self.reward) do
		if self.reward then
			v:DeleteMe()
		end
	end
	self.reward = {}
	self.mother_view = nil
end

function BiPinCell:ClickLevelReward()
	if self.data == nil then return end
	local act_num = KaiFuChargeData.Instance:GetBiPinActivity()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(act_num,RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, self.data.seq)
	self:Flush()
end

function BiPinCell:OnFlush()
	if self.data == nil then return end
	self.task_dec:SetValue(self.data.description)
	for i=1,3 do
		self.reward[i]:SetData(self.data.item_special[i-1])
	end
	-- self:CurValueGrade()
	if self.data.data_index <= 3 then 
		local bundle, asset = ResPath.GetRankIcon(self.data.data_index)
		self.rank_img:SetAsset(bundle, asset)
	else
		self.rank_num:SetValue(self.data.data_index)
	end
end

function BiPinCell:CurValueGrade()
	local mount_info = MountData.Instance:GetMountInfo()     					-- 坐骑阶数
	local halo_info = HaloData.Instance:GetHaloInfo() 		  				 	-- 光环阶数
	local wind_info = WingData.Instance:GetWingGrade() 		  				 	-- 羽翼阶数
	local shengong_info = ShengongData.Instance:GetShengongInfo() 			 	-- 神弓阶数（足迹）
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo() 					-- 神翼阶数 （披风）
	local fight_mount_info = FaZhenData.Instance:GetFightMountInfo()     	-- 战斗坐骑
	local grade = KaiFuChargeData.Instance:ConvertGrade(mount_info.grade)

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK) and mount_info.grade then
		self.cur_jieshu:SetValue(grade)
	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK) and halo_info.star_level then
		self.cur_jieshu:SetValue(KaiFuChargeData.Instance:ConvertGrade(halo_info.star_level))

	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK) and wind_info.grade then
		self.cur_jieshu:SetValue(KaiFuChargeData.Instance:ConvertGrade(wind_info.grade))

	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_JL_GUANGHUAN_RANK) and shengong_info.grade then
		self.cur_jieshu:SetValue(KaiFuChargeData.Instance:ConvertGrade(shengong_info.grade))

	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK) and shenyi_info.grade then
		self.cur_jieshu:SetValue(KaiFuChargeData.Instance:ConvertGrade(shenyi_info.grade))

	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_ZHIBAO_RANK) then
		self.cur_jieshu:SetValue("披风暂缺")

	elseif ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FIGHT_MOUNT_RANK) and fight_mount_info.grade then
		self.cur_jieshu:SetValue(KaiFuChargeData.Instance:ConvertGrade(fight_mount_info.grade))
	end 
end