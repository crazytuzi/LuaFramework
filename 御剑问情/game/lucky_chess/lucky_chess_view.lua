LuckyChessView = LuckyChessView or BaseClass(BaseView)

local OUT_SIDE_COUNT = 25
local IN_SIDE_COUNT = 13

-- 0元宝，1物品，2内圈，3双开
local REWARD_TYPE = {
	GOLD = 0,
	ITEM = 1,
	INSIDE = 2,
	DOUBLE = 3,
}

-- 动画圈数，时间
local ANI_LOOP = 2
local ANI_TIME = 6

function LuckyChessView:__init()
	self.ui_config = {"uis/views/randomact/luckychess_prefab", "LuckyChessView"}
	self.play_audio = true

	self.auto_buy_flag_list = {
		["auto_type_1"] = false,
		["auto_type_10"] = false,
	}
end

function LuckyChessView:Open()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end

	BaseView.Open(self)
end

function LuckyChessView:LoadCallBack()
	self.hl_1 = self:FindObj("HL1")
	self.hl_2 = self:FindObj("HL2")
	self.hl_3 = self:FindObj("HL3")
	self.hl_4 = self:FindObj("HL4")

	--获取外部格子
	self.out_side_cell_list = {}
	local out_side_cfg = LuckyChessData.Instance:GetLuckOutsideReward()
	for i = 0, OUT_SIDE_COUNT do
		local obj = self:FindObj("OutCell" .. i)
		local cell = LuckyChessCell.New(obj.gameObject)
		cell:SetData(out_side_cfg[i])
		-- table.insert(self.out_side_cell_list, {cell = cell, obj = obj})
		self.out_side_cell_list[i] = {cell = cell, obj = obj}
	end

	--获取内部格子
	self.in_side_cell_list = {}
	local in_side_cfg = LuckyChessData.Instance:GetLuckInsideReward()
	for i = 0, IN_SIDE_COUNT do
		local obj = self:FindObj("InCell" .. i)
		local cell = LuckyChessCell.New(obj.gameObject)
		cell:SetData(in_side_cfg[i])
		self.in_side_cell_list[i] = {cell = cell, obj = obj}
	end

	self.list_data = LuckyChessData.Instance:GetReturnRewardCfg()
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local list_simple_delegate = self.list_view.list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickOne",BindTool.Bind(self.ClickOne, self))
	self:ListenEvent("ClickTen",BindTool.Bind(self.ClickTen, self))
	self:ListenEvent("OnClickOpen",BindTool.Bind(self.OnClickOpen, self))
	self:ListenEvent("OnClickCloseAni",BindTool.Bind(self.OnClickCloseAni, self))
	self:ListenEvent("ClickTip", handler or BindTool.Bind(self.ClickTip, self))

	self.text_once_cost = self:FindVariable("text_once_cost")
	self.text_ten_cost = self:FindVariable("text_ten_cost")
	self.btn_one = self:FindObj("BtnOne")
	self.btn_ten = self:FindObj("BtnTen")
	self.act_time = self:FindVariable("act_time")
	self.ani_toggle = self:FindObj("AniToggle")
	self.recharge_times = self:FindVariable("recharge_times")
	self.show_key_str = self:FindVariable("show_key_str")
	self.key_str = self:FindVariable("key_str")
	self.btn_one_gray = self:FindVariable("btn_one_gray")
	self.btn_ten_gray = self:FindVariable("btn_ten_gray")
	self.is_free = self:FindVariable("IsFree")

	self.target_index = 0
	self.is_out_side_type = true
	self.is_close_ani = false
	self.cur_cell_list = {}
	self.tweener_list = {}
end

function LuckyChessView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for _, v in ipairs(self.out_side_cell_list) do
		v.cell:DeleteMe()
	end
	self.out_side_cell_list = {}

	for _, v in ipairs(self.in_side_cell_list) do
		v.cell:DeleteMe()
	end
	self.in_side_cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.tweener_list = {}

	self.hl_1 = nil
	self.hl_2 = nil
	self.list_view = nil
	self.ani_toggle = nil
	self.recharge_times = nil

	self.text_once_cost = nil
	self.text_ten_cost = nil
	self.target_index = 0
	self.is_out_side_type = true
	self.cur_cell_list = {}
	self.btn_one = nil
	self.btn_ten = nil
	self.is_onclick_req = false
	self.act_time = nil
	self.hl_3 = nil
	self.hl_4 = nil
	self.show_key_str = nil
	self.key_str = nil
	self.btn_ten_gray = nil
	self.btn_one_gray = nil
	self.is_free = nil
end

function LuckyChessView:GetCellNumber()
	return #self.list_data
end

function LuckyChessView:OnClickCloseAni()
	self.is_close_ani = not self.is_close_ani
	self:FlsuhToggle()
end

function LuckyChessView:FlsuhToggle()
	self.ani_toggle.toggle.isOn = self.is_close_ani
end

function LuckyChessView:CellRefresh(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.cell_list[cell]
	if nil == reward_cell then
		reward_cell = LuckyChessRewardCell.New(cell.gameObject)
		self.cell_list[cell] = reward_cell
	end
	local data = self.list_data[data_index] or {}
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(data)
end

function LuckyChessView:CloseWindow()
	self:Close()
end

function LuckyChessView:ClickTip()
	TipsCtrl.Instance:ShowHelpTipView(TipsOtherHelpData.Instance:GetTipsTextById(239))
end


function LuckyChessView:ClickOne()
	local func = function(is_auto)
		self.auto_buy_flag_list["auto_type_1"] = is_auto
		self.is_onclick_req = true
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP,
															RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 1)
	end

	local can_free = LuckyChessData.Instance:GetIsFree()
	if can_free then
		func(true)	
	elseif self.auto_buy_flag_list["auto_type_1"] then
		func(true)
	else
		local init_data = LuckyChessData.Instance:GetInitData()
		local str = string.format(Language.Fanfanzhuan.CostTip, init_data.money_one, CommonDataManager.GetDaXie(1))
		TipsCtrl.Instance:ShowCommonAutoView("luck_chess_auto1", str, func, nil, nil, nil, nil, nil, true, true)	
	end


end

function LuckyChessView:ClickTen()
	local func = function(is_auto)
		self.auto_buy_flag_list["auto_type_10"] = is_auto
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP,
															RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 10)
	end

	local init_data = LuckyChessData.Instance:GetInitData()
	local item_num = ItemData.Instance:GetItemNumInBagById(init_data.times_use_item)

	if self.auto_buy_flag_list["auto_type_10"] or item_num > 0 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP,
															RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 10)
	else
		local init_data = LuckyChessData.Instance:GetInitData()
		local str = string.format(Language.Fanfanzhuan.CostTip, init_data.money_ten, CommonDataManager.GetDaXie(10))
		TipsCtrl.Instance:ShowCommonAutoView("luck_chess_auto10", str, func, nil, nil, nil, nil, nil, true, true)
	end
end

function LuckyChessView:OnClickOpen()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end

function LuckyChessView:OpenCallBack()
	-- self.hl_1:SetActive(false)
	-- self.hl_2:SetActive(false)
	-- self.hl_3:SetActive(false)
	-- self.hl_4:SetActive(false)

	self.is_close_ani = false

	local data = LuckyChessData.Instance:GetDayDayUpStartData()
	self.target_index = data.target_index or 0
	LuckyChessCtrl.Instance:SendAllInfoReq()
	self:OpenBtn()

	-- self:Flush()
end

function LuckyChessView:CloseCallBack()
	for k,v in pairs(self.tweener_list) do
		v:Pause()
	end
end

function LuckyChessView:OnFlush(param_t)
	-- self.out_side_path_list = {}
	-- for i = 1, OUT_SIDE_COUNT do
	-- 	local cell = self.out_side_cell_list[i]
	-- 	table.insert(self.out_side_path_list, obj.transform.position)
	-- end

	-- 花费显示


	local init_data = LuckyChessData.Instance:GetInitData()
	self.text_once_cost:SetValue(init_data.money_one)
	self.text_ten_cost:SetValue(init_data.money_ten)

	self.is_free:SetValue(true)

	local can_free = LuckyChessData.Instance:GetIsFree()
	if can_free then
		--免费
		self.is_free:SetValue(false)
		self.text_once_cost:SetValue(Language.LuckChess.Free)
	end
	--钥匙显示
	local item_num = ItemData.Instance:GetItemNumInBagById(init_data.times_use_item)
	self.show_key_str:SetValue(item_num > 0)

	local item_cfg = ItemData.Instance:GetItemConfig(init_data.times_use_item)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>X" .. item_num
	self.key_str:SetValue(name_str)

	-- 右边列表刷新
	self.list_data = LuckyChessData.Instance:GetReturnRewardCfg()
	self.list_view.scroller:RefreshAndReloadActiveCellViews(true)

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	self.recharge_times:SetValue(LuckyChessData.Instance:GetRewardCount())

	self:FlsuhToggle()
	self:FlushHL(param_t)
end

function LuckyChessView:FlushHL(param_t)
	local data = LuckyChessData.Instance:GetDayDayUpStartData()
	self.is_out_side_type = data.start_pos.circle_type == RA_PROMOTING_POSITION_CIRCLE_TYPE.RA_PROMOTING_POSITION_CIRCLE_TYPE_OUTSIDE
	self.cur_cell_list = self.is_out_side_type and self.out_side_cell_list or self.in_side_cell_list
	self.target_index = data.target_index or 0
	self.hl_1.transform.position = self.cur_cell_list[self.target_index].obj.transform.position
	self.hl_3.transform.position = self.cur_cell_list[self.target_index].obj.transform.position
	self.hl_4.transform.position = self.cur_cell_list[self.target_index].obj.transform.position

	self.hl_2:SetActive(false)
	self.hl_4:SetActive(false)

	local change_point = false
	for k,v in pairs(param_t) do
		if k == "reward" then
			change_point = true
		end
	end
	if not change_point then
		return
	end
	if self.is_onclick_req then
		self.hl_1:SetActive(true)
		self.is_onclick_req = false

		local target_cell_data = self.cur_cell_list[self.target_index].cell:GetData()
		if self.is_close_ani then
			for k,v in pairs(self.tweener_list) do
				v:Pause()
			end
			self.hl_3:SetActive(true)
			self.hl_3.transform.position = self.cur_cell_list[self.target_index].obj.transform.position
			self.hl_1.transform.position = self.cur_cell_list[self.target_index].obj.transform.position
			if target_cell_data.reward_type == REWARD_TYPE.DOUBLE then
				local double_data = LuckyChessData.Instance:GetDayDayUpShowData()
				if nil == double_data then 
					return
				end				
				local target_index = double_data.reward_info_list[1].target_index or 0
				local target_index2 = double_data.reward_info_list[2].target_index or 0

				self.hl_2:SetActive(true)
				self.hl_4:SetActive(true)
				self.hl_1.transform.position = self.cur_cell_list[target_index].obj.transform.position
				self.hl_3.transform.position = self.cur_cell_list[target_index].obj.transform.position
				self.hl_2.transform.position = self.cur_cell_list[target_index2].obj.transform.position
				self.hl_4.transform.position = self.cur_cell_list[target_index2].obj.transform.position
			end
		else
			self.hl_3:SetActive(false)
			self:PlayAnimation(target_cell_data.reward_type == REWARD_TYPE.DOUBLE)
		end
	end
end

function LuckyChessView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.act_time:SetValue(self:GetTimeStr(time, 1))
	elseif time > 3600 then
		self.act_time:SetValue(self:GetTimeStr(time, 2))
	else
		self.act_time:SetValue(self:GetTimeStr(time, 2))
	end
end

-- 播放动画
function LuckyChessView:PlayAnimation(is_doublt)
	self.hl_3:SetActive(false)
	self.hl_4:SetActive(false)
	self:CloseBtn()
	local path_list = {}
	local count = self.is_out_side_type and OUT_SIDE_COUNT or IN_SIDE_COUNT
	--两圈
	for i=1,ANI_LOOP do
		for i = 0, count do
			local cell = self.cur_cell_list[i]
			table.insert(path_list, cell.obj.transform.position)
		end
	end

	for i = 0, self.target_index do
		local cell = self.cur_cell_list[i]
		table.insert(path_list, cell.obj.transform.position)
	end
	local function complete_func()
		-- 选中特效
		self.hl_3:SetActive(true)
		self.hl_3.transform.position = self.cur_cell_list[self.target_index].obj.transform.position
		-- 双开动画
		if is_doublt then
			local double_data = LuckyChessData.Instance:GetDayDayUpShowData()
			if nil ~= double_data.reward_info_list[1] and double_data.split_position ~= 0 then
				self:PlayDoubleAnimation(self.target_index, double_data.reward_info_list[1].target_index or 0, double_data.reward_info_list[2].target_index or 0)
			end
		else
			self:OpenBtn()
		end
	end

	self.hl_1.transform.position = self.cur_cell_list[0].obj.transform.position
	self:RunBaseAnima(self.hl_1, path_list, complete_func)
end

-- 播放双开动画
function LuckyChessView:PlayDoubleAnimation(start_index, target_index, target_index2)
	self.hl_3:SetActive(false)
	self.hl_4:SetActive(false)
	local count = self.is_out_side_type and OUT_SIDE_COUNT or IN_SIDE_COUNT
	count = count + 1
	-- 光环1动画
	local path_list1 = {}
	local left_index = target_index >= start_index and (target_index - start_index) or (count - start_index + target_index)
	local all_index = count * ANI_LOOP + left_index
	for i = 0, all_index do
		local index = (start_index + i) % count
		local cell = self.cur_cell_list[index]
		if cell then
			table.insert(path_list1, cell.obj.transform.position)
		end

	end
	self.hl_1.transform.position = self.cur_cell_list[start_index].obj.transform.position
	self:RunBaseAnima(self.hl_1, path_list1)

	local function complete_func()
		-- 特效
		self.hl_3:SetActive(true)
		self.hl_4:SetActive(true)

		self.hl_3.transform.position = self.cur_cell_list[target_index].obj.transform.position
		self.hl_2.transform.position = self.cur_cell_list[target_index2].obj.transform.position
		self.hl_4.transform.position = self.cur_cell_list[target_index2].obj.transform.position
		-- 是否再双开
		local target_cell_data1 = self.cur_cell_list[target_index].cell:GetData()
		local target_cell_data2 = self.cur_cell_list[target_index2].cell:GetData()
		if target_cell_data1.reward_type == REWARD_TYPE.DOUBLE or target_cell_data2.reward_type == REWARD_TYPE.DOUBLE then
			local double_data = LuckyChessData.Instance:GetDayDayUpShowData()
			if nil ~= double_data.reward_info_list[1] and double_data.split_position ~= 0 then
				local start_index = 0
				if target_cell_data1.reward_type == REWARD_TYPE.DOUBLE then
					start_index = target_index
				else
					start_index = target_index2
				end
				self:PlayDoubleAnimation(start_index, double_data.reward_info_list[1].seq, double_data.reward_info_list[2].seq)
			end
		else
			self:OpenBtn()
		end
	end
	-- 光环2动画
	self.hl_2:SetActive(true)
	local path_list2 = {}
	left_index = target_index2 >= start_index and (count - target_index2 + start_index) or (start_index - target_index2)
	all_index = count * ANI_LOOP + left_index
	for i = 0, all_index do
		local index = (start_index - i) % count
		index = index < 0 and (count + index) or index
		local cell = self.cur_cell_list[index]
		table.insert(path_list2, cell.obj.transform.position)
	end

	self.hl_2.transform.position = self.cur_cell_list[start_index].obj.transform.position
	self:RunBaseAnima(self.hl_2, path_list2, complete_func)
end

function LuckyChessView:RunBaseAnima(obj, path, call_back)
	local tweener = obj.transform:DOPath(
		path,
		ANI_TIME,
		DG.Tweening.PathType.Linear,			--Linear直来直往的, CatmullRom平滑的（一般是在转弯的时候）
		DG.Tweening.PathMode.TopDown2D,
		1)
	tweener:SetEase(DG.Tweening.Ease.InOutQuart)
	if call_back then
		tweener:OnComplete(call_back)
	end

	self.tweener_list[obj] = tweener
end

function LuckyChessView:CloseBtn()
	self.btn_one_gray:SetValue(true)
	self.btn_ten_gray:SetValue(true)
end

function LuckyChessView:OpenBtn()
	self.btn_one_gray:SetValue(false)
	self.btn_ten_gray:SetValue(false)
end

function LuckyChessView:GetTimeStr(time, model)
	local s = ""
	if time > 0 then
		local day = math.floor(time / (3600 * 24))
		hour = math.floor((time - day * 3600 * 24) / 3600)
		local minute = math.floor((time / 60) % 60)
		local second = math.floor(time % 60)

		if 1 == model then
			if day > 10 then
				s = string.format("%02d天", day)
			else
				s = string.format("%01d天", day)
			end
			if hour > 10 then
				s = s..string.format("%02d时", hour)
			else
				s = s..string.format("%01d时", hour)
			end
		elseif 2 == model then
			if hour > 10 then
				s = string.format("%02d时", hour)
			else
				s = string.format("%01d时", hour)
			end
			if minute > 10 then
				s = s..string.format("%02d分", minute)
			else
				s = s..string.format("%01d分", minute)
			end
		end
	else
		s = "0天0时"
	end
	return s
end

--奖励格子
LuckyChessCell = LuckyChessCell or BaseClass(BaseCell)

function LuckyChessCell:__init()
	self.path_img = self:FindVariable("Res")
	self.item_obj = self:FindObj("ItemCell")
	self.is_show_item = self:FindVariable("IsItem")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.item_obj)
	-- self.item:SetActive(false)

end

function LuckyChessCell:__delete()
	self.path_img = nil
	self.item = nil
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
	self.item_obj = nil
end

function LuckyChessCell:OnFlush()
	if nil == self.data then
		return
	end

	local reward_type = self.data.reward_type

	if reward_type == REWARD_TYPE.ITEM then
		-- self.item:SetActive(true)
		self.is_show_item:SetValue(true)
		self.item:SetData(self.data.reward_item)
	else
		local path = ResPath.GetLuckychessActRes
		local init_data = LuckyChessData.Instance:GetInitData()
		local res_name = ""
		if reward_type == REWARD_TYPE.GOLD then
			local reward_gold = self.data.reward_gold_rate or 0
			local get_gold = init_data.money_one + reward_gold
			-- local multiple = get_gold / init_data.money_one
			-- res_name = "Multiple0" .. (multiple * 10)
			self.is_show_item:SetValue(true)
			local data = {item_id = 65534, num = get_gold, is_bind = 0}
			self.item:SetData(data)
		else
			if reward_type == REWARD_TYPE.INSIDE then
				res_name = "LuckyInside"
			elseif reward_type == REWARD_TYPE.DOUBLE then
				res_name = "LuckyTwo"
			else
				res_name = "LuckyStart"
			end
			self.path_img:SetAsset(path(res_name))
		end
	end
end

--奖励列表格子
LuckyChessRewardCell = LuckyChessRewardCell or BaseClass(BaseCell)

function LuckyChessRewardCell:__init()
	self.text_times = self:FindVariable("text_times")
	self.text_vip_level = self:FindVariable("text_vip_level")
	self.text_desc = self:FindVariable("text_desc")
	self.can_get_reward = self:FindVariable("can_get_reward")
	self.has_get_reward = self:FindVariable("has_get_reward")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	self:ListenEvent("Click",BindTool.Bind(self.Click, self))
end

function LuckyChessRewardCell:__delete()
	self.text_times = nil
	self.text_vip_level = nil
	self.text_desc = nil
	self.can_get_reward = nil
	self.has_get_reward = nil
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function LuckyChessRewardCell:OnFlush()
	if nil == self.data then
		return
	end
	local is_get_reward = LuckyChessData.Instance:GetIsGetReward(self.index - 1)

	local cur_times = LuckyChessData.Instance:GetRewardCount()
	local times_limit = self.data.play_times
	local time_desc = is_get_reward and "" or times_limit
	self.text_times:SetValue(time_desc)

	self.text_vip_level:SetValue(self.data.vip_limit)

	local str = is_get_reward and Language.LuckChess.Desc2 or Language.LuckChess.Desc1
	self.text_desc:SetValue(str)
	self.has_get_reward:SetValue(is_get_reward)

	local role_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	local can_get_reward = cur_times >= times_limit and role_vip >= self.data.vip_limit and not is_get_reward
	self.can_get_reward:SetValue(can_get_reward)

	self.item:SetData(self.data.reward_item)
end

function LuckyChessRewardCell:Click()
	if nil == self.data then
		return
	end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP,
														RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_MAX, self.data.seq)
end