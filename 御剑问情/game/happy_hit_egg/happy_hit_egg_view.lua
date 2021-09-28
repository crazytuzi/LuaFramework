HappyHitEggView = HappyHitEggView or BaseClass(BaseView)

local MAX_PROG_GRADE = 3
local MAX_BUTTON_NUM = 3

local HAPPYEGG_OPERATE_PARAM = {
	[1] = RA_HUANLEZADAN_CHOU_TYPE.RA_HUANLEZADAN_CHOU_TYPE_1,
	[2] = RA_HUANLEZADAN_CHOU_TYPE.RA_HUANLEZADAN_CHOU_TYPE_10,
	[3] = RA_HUANLEZADAN_CHOU_TYPE.RA_HUANLEZADAN_CHOU_TYPE_30,
}
local HAPPYEGG_CHESTSHOP_MODE = {
	[1] = CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_1,
	[2] = CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_10,
	[3] = CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_30,
}

function HappyHitEggView:__init()
	self.ui_config = {"uis/views/happyhitegg_prefab", "HappyHitEgg"}
end

function HappyHitEggView:__delete()

end
--加载回调
function HappyHitEggView:LoadCallBack()
	self.diamond_num_list = {}
	self.total_list = {}
	self.timer = self:FindVariable("timer")
	self.free_time = self:FindVariable("free_timer")
	self.diamond = self:FindVariable("diamond")
	self.total_count = self:FindVariable("total_count")
	self.reddot_activate = self:FindVariable("reddot_activate")
	self.key_num = self:FindVariable("key_num")
	self.is_have_key = self:FindVariable("is_have_key")
	self.left_button = self:FindVariable("left_button")
	self.right_button = self:FindVariable("right_button")
	self.is_show_free = self:FindVariable("is_show_free")
	self.show_redpoint = self:FindVariable("show_redpoint")
	self.show_time = self:FindVariable("show_time")
	self.draw_lot_ani = {}
	for i=1,3 do
		self.diamond_num_list[i] = self:FindVariable("diamond_num_"..i)
		self.draw_lot_ani[i] = self:FindObj("draw_lot_"..i)
		self.total_list[i] = self:FindVariable("total_"..i)
		self.total_list[i+3] = self:FindVariable("total_"..i+3)
	end

	self.display = self:FindObj("display")
	self.model = RoleModel.New("huanlezadan_xian_nv_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")
	self.list_view_delegate = self.scroller.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.scroller.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.FlushPage, self))

	self:ListenEvent("OnCloseClick", BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("OnWareHoseClick", BindTool.Bind(self.OnWareHoseClick, self))

	for i=1,MAX_BUTTON_NUM do
		self:ListenEvent("OnClick"..i, BindTool.Bind(self.OnClickDraw, self, i))
	end

	self:ListenEvent("OnClickTurnPageLeft", BindTool.Bind2(self.OnClickTurnPage, self, "left"))
	self:ListenEvent("OnClickTurnPageRight", BindTool.Bind2(self.OnClickTurnPage, self, "right"))
	self:ListenEvent("OnClcikLog", BindTool.Bind(self.OnClcikLog, self))

	self.total_reward_list = {}
	for i=1,self:GetRewardCount() do
		self.total_reward_list[i] = ItemCell.New()
		local obj = self:FindObj("total_reward_"..i)
		self.total_reward_list[i]:SetInstanceParent(obj)
		self.total_reward_list[i]:SetIndex(i)
	end

	self:InitModle()
end

--打开界面的回调
function HappyHitEggView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN,RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_QUERY_INFO)
	self:Flush()
end


--关闭界面的回调
function HappyHitEggView:CloseCallBack()
	-- override
end

--关闭界面释放回调
function HappyHitEggView:ReleaseCallBack()
	self.diamond_num_list = {}
	self.total_list = {}
	self.timer = nil
	self.free_time = nil
	self.diamond = nil
	self.total_count = nil
	self.reddot_activate = nil
	self.key_num = nil
	self.is_have_key = nil
	self.cell_list = nil
	self.list_view_delegate  = nil
	self.left_button = nil
	self.right_button = nil
	self.scroller = nil
	self.display = nil
	self.is_show_free = nil
	self.show_redpoint = nil
	self.show_time = nil
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self:ClearClickDelay()
end

-- --刷新
function HappyHitEggView:OnFlush(param_list)
	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushActNextTime, self), 1)
		self:FlushActNextTime()
	end
-- 	--读取消费的钻石数量
	local configs = HappyHitEggData.Instance:GetHappyHitEggConfigs()
	self.diamond_num_list[1]:SetValue(configs.other[1].huanlezadan_once_gold)
	self.diamond_num_list[2]:SetValue(configs.other[2].huanlezadan_tentimes_gold)
	self.diamond_num_list[3]:SetValue(configs.other[3].huanlezadan_thirtytimes_gold)
	--读取累计抽奖配置
	for i = 1,self:GetRewardCount() do
		self.total_list[i]:SetValue(configs.huanlezadan_reward[i].choujiang_times) 
		self.total_reward_list[i]:SetData(configs.huanlezadan_reward[i].reward_item )
	end

	--判断寻宝次数是否满足
	self:WhetherItMeets()
-- 	--抽奖次数进度
	local flush_times = HappyHitEggData.Instance:GetChouTimes() or 0
	self.total_count:SetValue(flush_times)
	local key_num = ItemData.Instance:GetItemNumInBagById(configs.other[1].huanlezadan_thirtytimes_item_id) or 0
	self.is_have_key:SetValue(key_num > 0)
	self.key_num:SetValue(Language.HappyHitEgg.KeyText..key_num)
	self.show_redpoint:SetValue(key_num > 0)

	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
end

--判断寻宝次数是否满足
function HappyHitEggView:WhetherItMeets()
	local total_config = HappyHitEggData.Instance:GetHappyHitEggConfigs()
	local draw_times = HappyHitEggData.Instance:GetChouTimes() or 0
	for i = 1,self:GetRewardCount() do
		if nil == total_config.huanlezadan_reward[i].choujiang_times then return end
		if draw_times >= total_config.huanlezadan_reward[i].choujiang_times and 
			not HappyHitEggData.Instance:GetCanFetchFlag(self.total_reward_list[i]:GetIndex()) then
			self.total_reward_list[i]:ShowGetEffect(true)
			self.total_reward_list[i]:ListenClick(BindTool.Bind(self.OnClick, self, i))

		else
			self.total_reward_list[i]:ShowGetEffect(false)
			self.total_reward_list[i]:ListenClick()
		end

		if HappyHitEggData.Instance:GetCanFetchFlag(self.total_reward_list[i]:GetIndex()) then
			self.total_reward_list[i]:ShowHaseGet(true)
		else
			self.total_reward_list[i]:ShowHaseGet(false)
		end
	end
end

--点击奖励物品事件
function HappyHitEggView:OnClick(i)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN,RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_FETCH_REWARD, self.total_reward_list[i]:GetIndex() - 1)
end

function HappyHitEggView:SetIndex(index)
	self.index = index
end

function HappyHitEggView:GetRewardCount()
	return #HappyHitEggData.Instance:GetHappyHitEggRewardConfig()
end

function HappyHitEggView:FlushActNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.timer:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	elseif time > 3600 then
		self.timer:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 1) .. "</color>")
	else
		self.timer:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 2) .. "</color>")
	end
end


function HappyHitEggView:OnCloseClick()
	self:Close()
end

function HappyHitEggView:OnWareHoseClick()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end

function HappyHitEggView:OnClickDraw(index)
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN
	local operate_type = RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_TAO
	local param1 = HAPPYEGG_OPERATE_PARAM[index]
	HappyHitEggData.Instance:SetChestShopMode(HAPPYEGG_CHESTSHOP_MODE[index])
	self.draw_lot_ani[index].animator:SetTrigger("draw")

	self:ClearClickDelay()
	self.send_delay = GlobalTimerQuest:AddDelayTimer(function ()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, operate_type, param1)
	end, 0.4)
end

function HappyHitEggView:ClearClickDelay()
	if self.send_delay then
		GlobalTimerQuest.CancelQuest(self.send_delay)
		self.send_delay = nil
	end
end

--滚动条数量
function HappyHitEggView:GetNumberOfCells()
	return 2
end

--滚动条刷新
function HappyHitEggView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = HappyHitEggRewardItem.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	group_cell:SetPageIndex(data_index)
	group_cell:Flush()
end

function HappyHitEggView:FlushPage()
	local page = self.scroller.list_page_scroll:GetNowPage()
	if page == 0 then
		self.left_button:SetValue(false)
		self.right_button:SetValue(true)
	elseif page == 1 then
		self.left_button:SetValue(true)
		self.right_button:SetValue(false)
	else
		self.left_button:SetValue(true)
		self.right_button:SetValue(true)
	end
end

function HappyHitEggView:OnClickTurnPage(dir)
	local page = self.scroller.list_page_scroll:GetNowPage()
	if dir == "left" then
		page = page - 1
		if page < 0 then
			return
		end
	else
		page = page + 1
	end

	if page == 0 then
		self.left_button:SetValue(false)
		self.right_button:SetValue(true)
	elseif page == 1 then
		self.left_button:SetValue(true)
		self.right_button:SetValue(false)
	else
		self.left_button:SetValue(true)
		self.right_button:SetValue(true)
	end
	self.scroller.list_page_scroll:JumpToPage(page)
end

function HappyHitEggView:InitModle()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	for i, v in pairs(cfg) do
		if open_day <= v.opengame_day then
			local res_id = v.happyegg_showmodel
			local role_cfg = ItemData.Instance:GetItemConfig(res_id)
			local display_role = role_cfg.is_display_role
			if display_role == DISPLAY_TYPE.MOUNT then
				self.model:SetPanelName("huanlezadan_mount_panel")
			elseif display_role == DISPLAY_TYPE.WING then
				self.model:SetPanelName("huanlezadan_wing_panel")
			elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
				self.model:SetPanelName("huanlezadan_fight_mount_panel")
			elseif display_role == DISPLAY_TYPE.HALO then
				self.model:SetPanelName("huanlezadan_halo_panel")
			elseif display_role == DISPLAY_TYPE.FOOTPRINT then
				self.model:SetPanelName("huanlezadan_foot_panel")
			elseif display_role == DISPLAY_TYPE.SPIRIT then
				self.model:SetPanelName("huanlezadan_spirit_panel")
			end
			self.model:ClearModel()
			ItemData.ChangeModel(self.model, res_id)
			break
		end
	end
end

function HappyHitEggView:OnClcikLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN)
end

function HappyHitEggView:FlushNextTime()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	self.diamond:SetValue(true)
	self.reddot_activate:SetValue(false)
	self.is_show_free:SetValue(false)
	self.show_time:SetValue(true)
	-- 免费倒计时
	local next_free_tao_timestamp = HappyHitEggData.Instance:GetNextFreeTaoTimestamp()
	local choujiang_times = HappyHitEggData.Instance:GetChouTimes()
	if next_free_tao_timestamp == 0 then
		self.show_time:SetValue(false)
	end
	if next_free_tao_timestamp ~= 0 or choujiang_times == 0 then
		self:FlushCanNextTime()
		self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanNextTime, self), 1)
	end
end

function HappyHitEggView:FlushCanNextTime()
	local next_free_tao_timestamp = HappyHitEggData.Instance:GetNextFreeTaoTimestamp()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_str = next_free_tao_timestamp - server_time or 0
	local value_str = string.format(Language.HappyHitEgg.FreeTime,	TimeUtil.FormatSecond(time_str))
 	self.free_time:SetValue(value_str)
 	if time_str <= 0 then
 		-- 移除计时器
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end
		self.diamond:SetValue(false)
		self.reddot_activate:SetValue(true)
		self.is_show_free:SetValue(true)
		self.show_time:SetValue(false)
		HappyHitEggData.Instance:FlushHallRedPoindRemind()
 	end
end

-- -------------------------------------------显示奖励物品-------------------------------------------------------

------------------------------------------------------------------------
HappyHitEggRewardItem = HappyHitEggRewardItem  or BaseClass(BaseRender)

-- local NOW_PAGE = -1
function HappyHitEggRewardItem:__init()
	self.page_index = 0
	-- 累计翻牌达到的档次
	self.cur_grade = 0

	self.item_list = {}
	for i=0,2 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
		self.item_list[i]:ListenClick(BindTool.Bind(self.ItemClick, self, i))
	end
	self.text_desc_list = {}
	for i=0,2 do
		self.text_desc_list[i] = self:FindVariable("text_desc_" .. i)
	end

	self.is_show_effect_list = {}
	for i=0,2 do
		self.is_show_effect_list[i] = self:FindVariable("ShowEff" .. i)
	end

	self.show_effect_flag_list = {}
end

function HappyHitEggRewardItem:__delete()
	self.page_index = 0
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end

	self.item_list = {}
	self.text_desc_list = {}
	self.is_show_effect_list = {}
end

function HappyHitEggRewardItem:ItemClick(i)
	if self.cur_grade >= i + 1 then
		local configs = HappyHitEggData.Instance:GetHappyHitEggConfigs()
		local index = (self.page_index * MAX_PROG_GRADE) + (i + 1)
		local return_reward_list = configs.huanlezadan_reward
		local data = return_reward_list[index] or {}
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN,
																							RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_FETCH_REWARD, index - 1)
	else
		self.item_list[i]:OnClickItemCell()
	end
end

function HappyHitEggRewardItem:SetPageIndex(page_index)
	self.page_index = page_index
end

function HappyHitEggRewardItem:OnFlush()
	--local configs =  HappyHitEggData.Instance:GetHappyHitEggConfigs()
	local return_reward_list = HappyHitEggData.Instance:GetHappyHitEggRewardConfig()
	local draw_times = HappyHitEggData.Instance:GetChouTimes() or 0
	self.cur_grade = 0
	for i=0,2 do
		local index = (self.page_index * MAX_PROG_GRADE) + (i + 1)
		local data = return_reward_list[index] or {}
		local cell = self.item_list[i]
		cell:SetData(data.reward_item)
		self.text_desc_list[i]:SetValue(data.choujiang_times)

		-- 获取当前达到第几个档次
		local is_show_effect = false
		local is_show_has_get = false
		if draw_times >= data.choujiang_times then
			local reward_flag = HappyHitEggData.Instance:GetCanFetchFlag(index)
			if reward_flag == true then
				is_show_has_get = true
			else
				is_show_effect = true
			end
			self.cur_grade = self.cur_grade + 1
		end
		cell:ShowHaseGet(is_show_has_get)

		if self.show_effect_flag_list[i] == nil or self.show_effect_flag_list[i] ~= is_show_effect then
			self.show_effect_flag_list[i] = is_show_effect
			self.is_show_effect_list[i]:SetValue(is_show_effect)
		end
		self.is_show_effect_list[i]:SetValue(is_show_effect)
		cell:SetHighLight(false)
	end
end