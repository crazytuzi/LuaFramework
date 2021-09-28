KuaFuChongZhiRankView = KuaFuChongZhiRankView or  BaseClass(BaseView)

function KuaFuChongZhiRankView:__init()
	self.ui_config = {"uis/views/kuafuchongzhirank_prefab", "KuaFuChongZhiRankView"}
	self.cell_list = {}
	self.reward_info = {}
	self.reward_list = {}
	self.attur_number = 3
	self.slot_num = 10
	self.show_fram = true
	self.act_time = nil
end

function KuaFuChongZhiRankView:__delete()


end

function KuaFuChongZhiRankView:LoadCallBack()
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnCanyu", BindTool.Bind(self.OnCanyu, self))
	-- self:ListenEvent("OnLastPage", BindTool.Bind(self.OnLastPage, self))
	-- self:ListenEvent("OnNextPage", BindTool.Bind(self.OnNextPage, self))
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self.frame = self:FindObj("Frame")

	local total_chongzhi = KuaFuChongZhiRankData.Instance:GetChongZhiInfo()

	self.zuamshicount = self:FindVariable("zuamshicount")
	self.zuamshicount:SetValue(total_chongzhi)
	self.act_time = self:FindVariable("Acttime")
	self.page_text = self:FindVariable("page_text")
	self.frame:SetActive(false)

	local data = KuaFuChongZhiRankData.Instance:GetChongZhiRank()
	local num = 0
	for k,v in pairs(data) do
		self.reward_info[num] = v
		num = num + 1
	end

	local rest_time = 0
	rest_time = ActivityData.Instance:GetCrossRandActivityStatusByType(4000)["end_time"] or 0
	if self.consume_discount then
		CountDown.Instance:RemoveCountDown(self.consume_discount)
		self.consume_discount = nil
	end
	self.consume_discount = CountDown.Instance:AddCountDown(rest_time, 1, BindTool.Bind1(self.UpdataRollerTime, self), BindTool.Bind1(self.CompleteRollerTime, self))
	self:InitScroller()
end

function KuaFuChongZhiRankView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}

	self.list_view_reward = nil
	self.act_time = nil
	self.new_list_view_attur = nil
	self.gongXianJianglistview = nil
	self.ranklist = nil
	self.list_view_delegate = nil
	self.scroller = nil
	self.zuamshicount = nil
	self.act_time = nil
	self.page_text = nil
	self.frame = nil

	if self.consume_discount then
		CountDown.Instance:RemoveCountDown(self.consume_discount)
		self.consume_discount = nil
	end
end

function KuaFuChongZhiRankView:OpenCallBack()
	KuaFuChongZhiRankCtrl.SendTianXiangOperate2(MT_CROSS_RA_CHONGZHI_RANK_GET_RANK_CS)
	self:Flush()
end

function KuaFuChongZhiRankView:CompleteRollerTime()

end

function KuaFuChongZhiRankView:UpdataRollerTime(elapse_time, next_time)
	local time = math.floor(next_time - TimeCtrl.Instance:GetServerTime())
	if self.act_time ~= nil then
		if time > 0 then
			local format_time = TimeUtil.Format2TableDHM(time)
			local str_list = Language.Common.TimeList
			local time_str = ""
			if format_time.day > 0 then
				time_str = format_time.day .. str_list.d
			end
			if format_time.hour > 0 then
				time_str = time_str .. format_time.hour .. str_list.h
			end
			time_str = time_str .. format_time.min .. str_list.min
			self.act_time:SetValue(string.format(Language.ZeroGift.TimeText2, time_str))

		end
 	end
end

--初始化滚动条
function KuaFuChongZhiRankView:InitScroller()

	self.scroller = self:FindObj("ScrollRanklist")

	self.list_view_delegate = self.scroller.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.ranklist = self:FindObj("Ranklist")
	self.list_view_reward = self.ranklist.list_simple_delegate

	self.list_view_reward.NumberOfCellsDel = BindTool.Bind(self.GetRankCells, self)
	self.list_view_reward.CellRefreshDel = BindTool.Bind(self.RefreshRankView, self)

	self.gongXianJianglistview = self:FindObj("GongXianJianglistview")
	self.new_list_view_attur = self.gongXianJianglistview.list_simple_delegate

	self.new_list_view_attur.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfNewAtturCells, self)
	self.new_list_view_attur.CellRefreshDel = BindTool.Bind(self.RefreshNewAtturView, self)
end

function KuaFuChongZhiRankView:OnCanyu()
	if self.show_fram == true then
		self.frame:SetActive(true)
		self.show_fram = false
	else
		self.show_fram = true
		self.frame:SetActive(false)
	end
end


function KuaFuChongZhiRankView:GetNumberOfCells()
	return self.slot_num or 0
end

function KuaFuChongZhiRankView:RefreshNewAtturView(cell, data_index)
	local item_cell = self.reward_list[cell]
	if item_cell == nil then
		item_cell = KuaFuChongzhiRewardItemCell.New(cell.gameObject, self)
		self.reward_list[cell] = item_cell
		self.reward_list[cell]:SetToggleGroup(self.gongXianJianglistview.toggle_group)
	end
	self.reward_list[cell]:SetIndex(data_index + 1)
	self.reward_list[cell]:SetData(self.reward_info[data_index])

end

function KuaFuChongZhiRankView:RefreshView(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = KuaFuChongZhiRankCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.scroller.toggle_group)
	end
	the_cell:SetIndex(cell_index + 1)
	the_cell:Flush()
end


function KuaFuChongZhiRankView:GetRankCells()
	return self.slot_num
end

function KuaFuChongZhiRankView:RefreshRankView(cell, data_index)
	local item_cell = self.cell_list[cell]
	if item_cell == nil then
		item_cell = KuaFuChongzhiItemCell.New(cell.gameObject, self)
		self.cell_list[cell] = item_cell
		self.cell_list[cell]:SetToggleGroup(self.ranklist.toggle_group)
	end
	self.cell_list[cell]:SetIndex(data_index + 1)
	self.cell_list[cell]:SetData(self.reward_info[data_index])
	item_cell:Flush()

end

function KuaFuChongZhiRankView:GetNumberOfNewAtturCells()
	return 3
end

function KuaFuChongZhiRankView:OnClickHelp()
	local tips_id = 250
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function KuaFuChongZhiRankView:OnFlush()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end

	local total_chongzhi = KuaFuChongZhiRankData.Instance:GetChongZhiInfo()
	self.zuamshicount:SetValue(total_chongzhi)
end
--------------------------------------------------------------------
KuaFuChongZhiRankCell=KuaFuChongZhiRankCell or BaseClass(BaseCell)

function KuaFuChongZhiRankCell:__init(instance)
	self.rank = 0
	self.qufu_text = self:FindVariable("qufu")
	self.name_text = self:FindVariable("name")
	self.zuanshicount_text = self:FindVariable("zuanshicount")
end

function KuaFuChongZhiRankCell:__delete()

end

function KuaFuChongZhiRankCell:OnFlush()
	self.root_node.gameObject:SetActive(true)
	local rank_info = KuaFuChongZhiRankData.Instance:GetCrossRankInfo()
	local index = self:GetIndex()

	if nil == rank_info[index] then
		return
	end

	local server_id = rank_info[index].mvp_server_id
	local server_name = LoginData.Instance:GetServerName(server_id)

	if rank_info[index].total_chongzhi == 0 then
		return
	end
	self.qufu_text:SetValue(string.format(Language.KuaFuChongzhi.qufu, server_id, server_name))
	self.zuanshicount_text:SetValue(string.format(Language.KuaFuChongzhi.zuanshicount, rank_info[index].total_chongzhi))
	self.name_text:SetValue(rank_info[index].mvp_name)

end




function KuaFuChongZhiRankCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

--------------
KuaFuChongzhiItemCell = KuaFuChongzhiItemCell or BaseClass(BaseCell)

function KuaFuChongzhiItemCell:__init(instance)

	self.from_view = 0
	self.click_hanser = nil
	self.show = ItemCell.New()
	-- self.show:ShowQuality(false)
	self.show:SetInstanceParent(self:FindObj("itemcell"))
	self.place_name = self:FindVariable("info")
	self.place_name1 = self:FindVariable("info2")
	self:ListenEvent("Onclick", BindTool.Bind(self.Onclick, self))
end

function KuaFuChongzhiItemCell:__delete()
	if self.show then
		self.show:DeleteMe()
		self.show = nil
	end
end

function KuaFuChongzhiItemCell:Onclick()
	if self.click_hanser then
		self.click_hanser()
	end
end


function KuaFuChongzhiItemCell:SetToggleGroup(group)
  	self.root_node.toggle.group = group
end

function KuaFuChongzhiItemCell:OnFlush()
	local data = self.data
	self.show:SetData(data.join_reward_item)

	-- self.show:ShowQuality(false)

	local cfg = KuaFuChongZhiRankData.Instance:GetChongZhiRank()
	local index = self:GetIndex()
	if nil == cfg[index] then
		return
	end
	self.place_name:SetValue(string.format(Language.KuaFuChongzhi.NoRank, cfg[index].rank))
	self.place_name1:SetValue(string.format(Language.KuaFuChongzhi.Reward, cfg[index].need_total_chongzhi))
end


------------------------------------
KuaFuChongzhiRewardItemCell = KuaFuChongzhiRewardItemCell or BaseClass(BaseCell)

function KuaFuChongzhiRewardItemCell:__init(instance)
	self.from_view = 0
	self.click_hanser = nil
	self.cell_list = {}

	for i = 1, 3 do 
		self.cell_list[i] = ItemCell.New()
		self.cell_list[i]:SetInstanceParent(self:FindObj("itemcellgongxian" .. i))
	end

	self.reward_info = self:FindVariable("gongxianjiangliinfo")
	self:ListenEvent("onClick", BindTool.Bind(self.OnClick, self))
end

function KuaFuChongzhiRewardItemCell:__delete()
	if self.cell_list then
		for i = 1, 3 do 
			if self.cell_list[i] then
				self.cell_list[i]:DeleteMe()
				self.cell_list[i] = nil
			end
		end
		self.cell_list = nil
	end
end

function KuaFuChongzhiRewardItemCell:SetToggleGroup(toggle_group)
	 self.root_node.toggle.group = toggle_group
end

function KuaFuChongzhiRewardItemCell:OnClick()
	if self.click_hanser then
		self.click_hanser()
	end
end
function KuaFuChongzhiRewardItemCell:OnFlush()
	local data = self.data
	
	if data and data.person_reward_item and data.person_reward_item.item_id then
		local list = KuaFuChongZhiRankData.Instance:GetGiftCfgById(data.person_reward_item.item_id)
		if list then
			for i = 1, 3 do
				if list[i] then
					self.cell_list[i]:SetData(list[i])
				end	
			end
		end

		local cfg = KuaFuChongZhiRankData.Instance:GetChongZhiRank()
		local index = self:GetIndex() or 0
		if not cfg or nil == cfg[index] then
			return
		end
		self.reward_info:SetValue(string.format(Language.KuaFuChongzhi.ChongzhiReward, cfg[index].rank))
	end
end