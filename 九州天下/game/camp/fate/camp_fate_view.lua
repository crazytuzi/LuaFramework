require("game/camp/fate/fate_item_render")
CampFateView = CampFateView or BaseClass(BaseRender)

function CampFateView:__init()
	self.lbl_bottom_fate_num = {}
	self.lbl_bottom_speed = {}
	self.lbl_bottom_btn = {}
	self.lbl_bottom_getfate = {}
	self.image_bg_asset = {}
	self.image_rank_asset = {}
	self.qiyun_rank_list = {}

	self.lbl_top_text = {}
	self.obj_top_text = {}
end

function CampFateView:__delete()
	if self.camp_attack_cell_list then
		for k,v in pairs(self.camp_attack_cell_list) do
			v:DeleteMe()
		end
	end
	self.camp_attack_cell_list = {}

	if self.camp_defend_cell_list then
		for k,v in pairs(self.camp_defend_cell_list) do
			v:DeleteMe()
		end
	end
	self.camp_defend_cell_list = {}

	self.lbl_bottom_fate_num = {}
	self.lbl_bottom_speed = {}
	self.lbl_bottom_btn = {}
	self.lbl_bottom_getfate = {}
	self.image_bg_asset = {}
	self.image_rank_asset = {}
	self.qiyun_rank_list = {}

	self.lbl_top_text = {}
	self.obj_top_text = {}

	self.camp_attack_list = nil
	self.camp_defend_list = nil

	self.lbl_fate_score_num = nil
	self.is_fate_truce = nil
	self.lbl_fate_truce_text = nil
end

function CampFateView:SendRequest()
	CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_QUERY_QIYUN_STATUS)
	CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_QUERY_QIYUN_REPORT)
end

function CampFateView:LoadCallBack(instance)

	----------------------------------------------------
	-- 进攻战报列表生成滚动条
	self.camp_attack_cell_list = {}
	self.camp_attack_listview_data = {}
	self.camp_attack_list = self:FindObj("AttackListView")
	local camp_attack_list_delegate = self.camp_attack_list.list_simple_delegate
	--生成数量
	camp_attack_list_delegate.NumberOfCellsDel = function()
		return #self.camp_attack_listview_data or 0
	end
	--刷新函数
	camp_attack_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCampFateAttackListView, self)
	----------------------------------------------------

	----------------------------------------------------
	-- 防守战报列表生成滚动条
	self.camp_defend_cell_list = {}
	self.camp_defend_listview_data = {}
	self.camp_defend_list = self:FindObj("DefendListView")
	local camp_defend_list_delegate = self.camp_defend_list.list_simple_delegate
	--生成数量
	camp_defend_list_delegate.NumberOfCellsDel = function()
		return #self.camp_defend_listview_data or 0
	end
	--刷新函数
	camp_defend_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCampFateDefendListView, self)
	----------------------------------------------------

	-- 监听UI事件
	for i = 1, GameEnum.MAX_CAMP_NUM do
		self:ListenEvent("BtnFateCamp" .. i, BindTool.Bind(self.OnBtnFateCampHandler, self, i))
	end
	self:ListenEvent("BtnFateExchange", BindTool.Bind(self.OnBtnFateExchangeHandler, self))
	self:ListenEvent("BtnFateTips", BindTool.Bind(self.OnBtnFateTipsHandler, self))

	-- 获取变量
	for i = 1, GameEnum.MAX_CAMP_NUM do
		self.lbl_bottom_fate_num[i] = self:FindVariable("BottomFateNum_" .. i)
		self.lbl_bottom_speed[i] = self:FindVariable("BottomSpeed_" .. i)
		self.lbl_bottom_btn[i] = self:FindVariable("BottomBtn_" .. i)
		self.lbl_bottom_getfate[i] = self:FindVariable("BottomGetfate_" .. i)
		self.image_bg_asset[i] = self:FindVariable("BgImage_" .. i)
		self.image_rank_asset[i] = self:FindVariable("RankIcon_" .. i)

		self.lbl_top_text[i] = {}
		self.obj_top_text[i] = {}
		for j = 1, GameEnum.MAX_CAMP_NUM do
			self.lbl_top_text[i][j] = self:FindVariable("TopText" .. i .. "_" .. j)
			self.obj_top_text[i][j] = self:FindObj("TopLabel" .. i .. "_" .. j)
		end
	end
	self.baohu_effect_root = {}
	self.jiachen_effect_root = {}
	for i = 1, 3 do
		self.baohu_effect_root[i] = self:FindVariable("BaoHuEffectRoot_" .. i)
		self.jiachen_effect_root[i] = self:FindVariable("JiaChenEffectRoot_" .. i)
	end
	self.lbl_fate_score_num = self:FindVariable("FateScoreNum")

	self.is_fate_truce = self:FindVariable("IsFateTruce")
	self.lbl_fate_truce_text = self:FindVariable("FateTruceText")

	self:Flush()
end

function CampFateView:OnFlush(param_list)
	self.lbl_fate_score_num:SetValue(ExchangeData.Instance:GetScoreByScoreType(EXCHANGE_PRICE_TYPE.FATE))

	self:FlushCampFateData()

	local fate_war_battle_info = CampData.Instance:GetCampQiyunBattleReport()

	-- 设置进攻战报list数据
	self.camp_attack_listview_data = fate_war_battle_info.attack_report_list
	-- SortTools.SortAsc(self.camp_attack_listview_data, "report_timestamp")
	if self.camp_attack_list.scroller.isActiveAndEnabled then
		self.camp_attack_list.scroller:ReloadData(0)
	end

	-- 设置防守战报list数据
	self.camp_defend_listview_data = fate_war_battle_info.defend_report_list
	-- SortTools.SortAsc(self.camp_defend_listview_data, "report_timestamp")
	if self.camp_defend_list.scroller.isActiveAndEnabled then
		self.camp_defend_list.scroller:ReloadData(0)
	end
end

-- 刷新休战面板
function CampFateView:FlushCampXiuzhan(is_xiuzhan)
	if is_xiuzhan then
		local campwar_fate_other_cfg = NationalWarfareData.Instance:GetCampWarFateOtherCfg()

		-- 无敌开启时间（HHMM -> 分钟）
		local wudi_time_hhmm = campwar_fate_other_cfg.wudi_time
		local wudi_begin_h = math.floor(wudi_time_hhmm / 100)
		local wudi_begin_m = wudi_time_hhmm % 100
		local wudi_time = wudi_begin_h * 60 + wudi_begin_m
		
		-- 无敌结束时间（分钟）
		local wudi_end_time = wudi_time + campwar_fate_other_cfg.wudi_duration
		local wudi_end_time_h = math.floor(wudi_end_time / 60)
		local wudi_end_time_m = wudi_end_time - wudi_end_time_h * 60

		-- 开始战斗时间（字符串）
		local fight_time = string.format("%02d:%02d", wudi_end_time_h, wudi_end_time_m)

		self.is_fate_truce:SetValue(true)
		self.lbl_fate_truce_text:SetValue(string.format(Language.Camp.FateTruceText, fight_time))
	else
		self.is_fate_truce:SetValue(false)
	end
end

-- 左边面板
function CampFateView:FlushCampFateData()
	local fate_tower_status_info = CampData.Instance:GetCampQiyunTowerStatus()
	if not next(fate_tower_status_info.item_list) then return end
	-- 刷新休战面板
	self:FlushCampXiuzhan(fate_tower_status_info.is_xiuzhan == 1)

	------------------------------------------------------------------------

	for i = 1, GameEnum.MAX_CAMP_NUM do
		for j = 1, GameEnum.MAX_CAMP_NUM do
			self.obj_top_text[i][j]:SetActive(false)
		end
	end

	------------------------------------------------------------------------
	local my_camp = PlayerData.Instance.role_vo.camp
	local server_time = TimeCtrl.Instance:GetServerTime()
	for i = 1, GameEnum.MAX_CAMP_NUM do
		local item_list = fate_tower_status_info.item_list[i] -- 单个国家的状态
		-- 当前气运加成
		self.lbl_bottom_fate_num[i]:SetValue(string.format(Language.Camp.FateTowerRate,
			Language.Common.CampName[i], item_list.cur_add_percent))

		-- 当前速度
		local campwar_fate_other_cfg = NationalWarfareData.Instance:GetCampWarFateOtherCfg()
		if campwar_fate_other_cfg.base_product_speed then
			local speed_num = math.floor(item_list.cur_add_percent * 0.01 * campwar_fate_other_cfg.base_product_speed)
			self.lbl_bottom_speed[i]:SetValue(string.format(Language.Camp.FateTowerSpeed, speed_num))
		end

		-- 累计获得气运
		self.lbl_bottom_getfate[i]:SetValue(item_list.qiyun_val)
		-- 气运排行
		self.qiyun_rank_list[i] = {}
		self.qiyun_rank_list[i].id = i
		self.qiyun_rank_list[i].speed = speed_num or 0
		self.qiyun_rank_list[i].value = item_list.qiyun_val or 0

		if my_camp == i then
			-- 自己国家：前往保护
			self.lbl_bottom_btn[i]:SetValue(Language.Camp.FateBottomBtnText[1])
		else
			if item_list.is_alive == 1 then
				-- 其他国家，未被摧毁：前往摧毁
				self.lbl_bottom_btn[i]:SetValue(Language.Camp.FateBottomBtnText[2])
			else
				-- 其他国家，已被摧毁：元宝解除
				self.lbl_bottom_btn[i]:SetValue(Language.Camp.FateBottomBtnText[3])
			end
		end

		-- 气运塔状态：加成、衰弱、正常
		local cur_row = 1

		-- 衰弱/正常状态
		do
			local time_reduce = 0
			for j = 1, GameEnum.MAX_CAMP_NUM do
				local time_reduce_tmp = item_list.speed_reduce_end_timestamp[j] - server_time
				if time_reduce_tmp > time_reduce then
					time_reduce = time_reduce_tmp
				end
			end

			local content = ""

			if time_reduce > 0 then
				content = string.format(Language.Camp.FateTopText[3], TimeUtil.FormatSecond2Str(time_reduce, 1))
				if item_list.is_alive ~= 1 then
					self.baohu_effect_root[i]:SetValue(true)
				end
			else
				content = Language.Camp.FateTopText[1]
			end

			self.lbl_top_text[i][cur_row]:SetValue(content)
			self.obj_top_text[i][cur_row]:SetActive(true)

			cur_row = cur_row + 1
		end

		-- 加成状态
		do
			for j = 1, GameEnum.MAX_CAMP_NUM do

				local time_increase = item_list.speed_increase_end_timestmap[j] - server_time

				if time_increase > 0 then
					local content = string.format(Language.Camp.FateTopText[2], Language.Common.CampNameAbbr[j], TimeUtil.FormatSecond2Str(time_increase, 1))
					self.lbl_top_text[i][cur_row]:SetValue(content)
					self.obj_top_text[i][cur_row]:SetActive(true)
					self.jiachen_effect_root[i]:SetValue(true)

					cur_row = cur_row + 1
				end
			end
		end
	end

	-- 气运排名
	SortTools.SortDesc(self.qiyun_rank_list, "value", "speed")
	for i = 1, GameEnum.MAX_CAMP_NUM do
		self.image_bg_asset[self.qiyun_rank_list[i].id]:SetAsset(ResPath.GetCampRes("camp_fateinfo_bg_" .. i))
		self.image_rank_asset[self.qiyun_rank_list[i].id]:SetAsset(ResPath.GetRankIcon(i))
	end
end

-- 进攻战报列表listview
function CampFateView:RefreshCampFateAttackListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local camp_attack_cell = self.camp_attack_cell_list[cell]
	if camp_attack_cell == nil then
		camp_attack_cell = CampFateAttackItemRender.New(cell.gameObject)
		self.camp_attack_cell_list[cell] = camp_attack_cell
	end

	camp_attack_cell:SetIndex(data_index)
	camp_attack_cell:SetData(self.camp_attack_listview_data[data_index])
end

-- 防守战报列表listview
function CampFateView:RefreshCampFateDefendListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local camp_defend_cell = self.camp_defend_cell_list[cell]
	if camp_defend_cell == nil then
		camp_defend_cell = CampFateDefendItemRender.New(cell.gameObject)
		self.camp_defend_cell_list[cell] = camp_defend_cell
	end

	camp_defend_cell:SetIndex(data_index)
	camp_defend_cell:SetData(self.camp_defend_listview_data[data_index])
end

function CampFateView:OnBtnFateCampHandler(index)
	local fate_other_cfg = NationalWarfareData.Instance:GetCampWarFateOtherCfg()
	local fate_tower_status_info = CampData.Instance:GetCampQiyunTowerStatus()
	local item_list = fate_tower_status_info.item_list[index]
	local my_camp = PlayerData.Instance.role_vo.camp
	if item_list then
		if item_list.is_alive == 0 and my_camp ~= index then
			local des = string.format(Language.Camp.IsRelieveFate, fate_other_cfg.reborn_qiyun_tower_gold or 0, ToColorStr(Language.Common.CampName[camp], CAMP_COLOR[camp]))
			TipsCtrl.Instance:ShowCommonAutoView(nil, des, function ()
				CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_QIYUN_REBORN_TOWER, index)
			end)
		else
			local pos = fate_other_cfg["camp_" .. index .. "_qiyun_tower_pos"]
			if pos then
				-- 先执行取消选中目标
				GuajiCtrl.Instance:CancelSelect()
				local scene_id = CampData.Instance:GetCampScene(index)
				local pos_t = Split(pos, ",")
				local x, y = pos_t[1], pos_t[2]
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(scene_id, x, y, nil, nil, nil, nil, true)
				ViewManager.Instance:CloseAll()
			end
		end
	end
end

function CampFateView:OnBtnFateExchangeHandler()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_mojing)
end

function CampFateView:OnBtnFateTipsHandler()
	-- 拍卖Tips
	TipsCtrl.Instance:ShowHelpTipView(172)
end


