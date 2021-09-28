LianXuChongZhiChu = LianXuChongZhiChu or BaseClass(BaseRender)

function LianXuChongZhiChu:__init()
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("lianchongtehui_chu_panel")
	self.model:SetDisplay(self.display.ui3d_display)
	self.lianchongchu_day = self:FindVariable("lianchongchu_day")
	self.lianchongchu_name = self:FindVariable("lianchongchu_name")
	self.lianchongchu_zhanli = self:FindVariable("lianchongchu_zhanli")
	self.today_coin_chu = self:FindVariable("today_coin_chu")
	self.num_today_chu = self:FindVariable("num_today_chu")
	self.day_res = self:FindVariable("day_image")
	self.type_res = self:FindVariable("type_image")
	self.isfoot = false
	self:InitListView()
	self:Flush()
	self:FlushView()
	self:FlushModel()
end

function LianXuChongZhiChu:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}
	self.isfoot = nil
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self:CancelCountDown()
end

function LianXuChongZhiChu:InitListView()
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function LianXuChongZhiChu:GetNumberOfCells()
	return #KaifuActivityData.Instance:ChongZhiTeHuiChu()
end

function LianXuChongZhiChu:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]
	if nil == shop_cell then
		shop_cell = ChongZhiItemCellGroupChu.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end

	local index = cell_index + 1
	local item_id_group = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	local data = item_id_group[index]
	shop_cell:SetIndex(index)
	shop_cell:SetData(data)
end

function LianXuChongZhiChu:FlushView()
	self.list_view.scroller:ReloadData(0)
end

function LianXuChongZhiChu:OnFlush()
	local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU)
	local openchu_time = openchu_end - TimeCtrl.Instance:GetServerTime()
	self:SetRestTimeChu(openchu_time)

	local info_chu = KaifuActivityData.Instance:GetChongZhiChu()
	if nil ~= info_chu then
		self.num_today_chu:SetValue(info_chu.continue_chongzhi_days)
		self.today_coin_chu:SetValue(info_chu.today_chongzhi)
	end

	if self.model and self.isfoot then
		self.model:SetInteger("status", 1)
	end
end

function LianXuChongZhiChu:FlushModel()
	local main_role = Scene.Instance:GetMainRole()
	local show_item_chu, show_type_chu, model_name_chu, power_chu, show_day = self:GetTeHuiItemChu()
	local show_item_list = Split(show_item_chu, ",")
	local show_item_type = Split(show_type_chu, ",")
	local show_type = 0
	if nil ~= show_item_list and nil ~= show_item_type then
  		for i,v in ipairs(show_item_type) do
  			show_type = tonumber(v)
	  		KaifuActivityData.Instance:ModelSet(self.display, self.model, tonumber(v), tonumber(show_item_list[i]))
	  		if tonumber(v) == FASHION_SHOW_TYPE.FOOT then
	  			self.isfoot = true
	  		end
  		end
  		if #show_item_type > 1 then
  			show_type = 0
  		elseif show_type == FASHION_SHOW_TYPE.GODDRESS_HALO then
			show_type = FASHION_SHOW_TYPE.HALO
  		end
		self.type_res:SetAsset(ResPath.GetOpenGameActivityRes("text_" .. show_type))
		self.day_res:SetAsset(ResPath.GetOpenGameActivityRes("day_" .. show_day))
		self.lianchongchu_name:SetValue(model_name_chu)
		self.lianchongchu_zhanli:SetValue(power_chu)
	end
end

function LianXuChongZhiChu:GetTeHuiItemChu()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	if nil == cfg then
		return
	end
	for k, v in pairs(cfg) do
		if open_server_day <= v.open_server_day then
			return v.show_item, v.show_type, v.model_name, v.power, v.show_day
		end
	end
end

function LianXuChongZhiChu:SetRestTimeChu(diff_time)
	if self.count_down_chu == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down_chu ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down_chu)
					self.count_down_chu = nil
				end
				return
			end
			local time_str = ""
			local left_day = math.floor(left_time / 86400)
			if left_day > 0 then
				time_str = TimeUtil.FormatSecond(left_time, 7)
			elseif math.floor(left_time / 3600) > 0 then
				time_str = TimeUtil.FormatSecond(left_time, 1)
			else
				time_str = TimeUtil.FormatSecond(left_time, 2)
			end
			self.lianchongchu_day:SetValue(time_str)
		end
		self:CancelCountDown()
		diff_time_func(0, diff_time)
		self.count_down_chu = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function LianXuChongZhiChu:CancelCountDown()
	if self.count_down_chu ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_chu)
		self.count_down_chu = nil
	end
end

-----------------------------ChongZhiItemCellGroupChu--------------------------
ChongZhiItemCellGroupChu = ChongZhiItemCellGroupChu or BaseClass(BaseRender)

function ChongZhiItemCellGroupChu:__init()
	self.cell_list = {}
	local cell = ChongZhitemCellChu.New(self:FindObj("item"))
	table.insert(self.cell_list, cell)
end

function ChongZhiItemCellGroupChu:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ChongZhiItemCellGroupChu:SetToggleGroup()

end

function ChongZhiItemCellGroupChu:SetData(data)
	self.cell_list[1]:SetData(data)
end

function ChongZhiItemCellGroupChu:SetIndex(index)
	self.cell_list[1]:SetIndex(index)
end

-----------------------------ChongZhitemCellChu--------------------------
ChongZhitemCellChu = ChongZhitemCellChu or BaseClass(BaseCell)
function ChongZhitemCellChu:__init()
	self.leiji_day = self:FindVariable("leiji_day")
	self.chongzhi_coin = self:FindVariable("chongzhi_coin")
	self.button_lq = self:FindVariable("button_lq")
	self.button_cz = self:FindVariable("button_cz")
	self.button_ylq = self:FindVariable("button_ylq")
	self:ListenEvent("button_lingqu", BindTool.Bind(self.OnClickLingQu, self))
	self:ListenEvent("button_chongzhi", BindTool.Bind(self.OnClickChongZhi, self))
	for i = 1,3 do
		self["item_cell_" .. i] = ItemCell.New()
		self["item_cell_" .. i]:SetInstanceParent(self:FindObj("picture_" .. i))
		self["item_cell_" .. i]:ShowHighLight(false)
	end
end

function ChongZhitemCellChu:__delete()
	for i = 1,3 do
		self["item_cell_" .. i]:DeleteMe()
	end
end

function ChongZhitemCellChu:OnClickLingQu()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_CHU, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD, self.data.day_index)
end

function ChongZhitemCellChu:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ChongZhitemCellChu:OnFlush()
	local item_num = KaifuActivityData.Instance:GetChongZhiChu()
	local can_fetch_reward_flag = bit:d2b(item_num.can_fetch_reward_flag)
	local has_fetch_reward_falg = bit:d2b(item_num.has_fetch_reward_falg)
	if nil == item_num then
		return
	end
	if can_fetch_reward_flag[32 - self.data.day_index] == 0 then
		self.button_lq:SetValue(false)
		self.button_cz:SetValue(true)
		self.button_ylq:SetValue(false)
	end
	if can_fetch_reward_flag[32 - self.data.day_index] == 1 then
		if has_fetch_reward_falg[32 - self.data.day_index] == 0 then
			self.button_lq:SetValue(true)
			self.button_cz:SetValue(false)
			self.button_ylq:SetValue(false)
		end
		if has_fetch_reward_falg[32 - self.data.day_index] == 1 then
			self.button_lq:SetValue(false)
			self.button_cz:SetValue(false)
			self.button_ylq:SetValue(true)
		end
	end

	local item_group = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)

	for i=1,3 do
		self["item_cell_" .. i]:SetData(item_group[i])
		self["item_cell_" .. i]:SetShowRedPoint(false)
	end
	self.leiji_day:SetValue(self.data.day_index)

	local open_sever_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local tehuigao = KaifuActivityData.Instance:ChongZhiTeHuiChu()
	for k, v in pairs(tehuigao) do
		if open_sever_day <= v.open_server_day then
			self.chongzhi_coin:SetValue(v.need_chongzhi)
			return
		end
	end
end