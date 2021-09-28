LianXuChongZhiGao = LianXuChongZhiGao or BaseClass(BaseRender)
function LianXuChongZhiGao:__init()
	self:InitListView()
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("lianchongtehui_chu_panel")
	self.model:SetDisplay(self.display.ui3d_display)
	self.today_coin_gao = self:FindVariable("today_coin_gao")
	self.num_today_gao = self:FindVariable("num_today_gao")
	self.lianchonggao_day = self:FindVariable("lianchonggao_day")
	self.lianchonggao_name = self:FindVariable("lianchonggao_name")
	self.lianchonggao_zhanli = self:FindVariable("lianchonggao_zhanli")
	self.day_res = self:FindVariable("day_image")
	self.type_res = self:FindVariable("type_image")
	self.isfoot = false
	self:Flush()
	self:FlushView()
	self:FlushModel()
end

function LianXuChongZhiGao:__delete()
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

function LianXuChongZhiGao:InitListView()
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function LianXuChongZhiGao:GetNumberOfCells()
	return #KaifuActivityData.Instance:ChongZhiTeHuiGao()
end

function LianXuChongZhiGao:RefreshCell(cell, cell_index)
	local shop_cell = self.cell_list[cell]
	if nil == shop_cell then
		shop_cell = ChongZhiItemCellGroup.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end
	local index = cell_index + 1
	local item_id_group = KaifuActivityData.Instance:ChongZhiTeHuiGao()
	local data = item_id_group[index]
	shop_cell:SetIndex(index)
	shop_cell:SetData(data)
end

function LianXuChongZhiGao:FlushView()
	self.list_view.scroller:ReloadData(0)
end

function LianXuChongZhiGao:OnFlush()
	local opengao_start, opengao_end = KaifuActivityData.Instance:GetActivityOpenDay(TEMP_ADD_ACT_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO)
	local opengao_time = opengao_end - TimeCtrl.Instance:GetServerTime()
	self:SetRestTimeGao(opengao_time)

	local info_gao = KaifuActivityData.Instance:GetChongZhiGao()
	if nil ~= info_gao then
		self.num_today_gao:SetValue(info_gao.continue_chongzhi_days)
		self.today_coin_gao:SetValue(info_gao.today_chongzhi)
	end

	if self.model and self.isfoot then
		self.model:SetInteger("status", 1)
	end
end

function LianXuChongZhiGao:FlushModel()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local show_item_gao, show_type_gao, model_name_gao, power_gao, show_day = self:GetTeHuiItemGao()
	local show_item_list = Split(show_item_gao, ",")
	local show_item_type = Split(show_type_gao, ",")
	local show_type = 0
    if nil ~= show_item_list and nil ~= show_item_type then
  		-- local res_id = FashionData.GetFashionResByItemId(tonumber(show_item_list[2]), main_role_vo.sex, main_role_vo.prof) or 0
  		-- self.model:SetMainAsset(ResPath.GetRoleModel(res_id))
  		-- local wuqi_id = FashionData.GetFashionResByItemId(tonumber(show_item_list[1]), main_role_vo.sex, main_role_vo.prof) or 0
  		-- print_error(ItemData.Instance:GetItem(show_item_list[1]))
  		-- self.model:SetWeaponResid(wuqi_id)
  		for i,v in ipairs(show_item_type) do
  			show_type = tonumber(v)
	  		KaifuActivityData.Instance:ModelSet(self.display, self.model, tonumber(v), tonumber(show_item_list[i]))
	  		if tonumber(v) == FASHION_SHOW_TYPE.FOOT then
	  			self.isfoot = true
	  		end
  		end
  		if #show_item_type > 1 then
  			show_type = 0
  		--伙伴光环和光环用一个字段显示
  		elseif show_type == FASHION_SHOW_TYPE.GODDRESS_HALO then
			show_type = FASHION_SHOW_TYPE.HALO
  		end
		self.type_res:SetAsset(ResPath.GetOpenGameActivityRes("text_" .. show_type))
		self.day_res:SetAsset(ResPath.GetOpenGameActivityRes("day_" .. show_day))

		self.lianchonggao_name:SetValue(model_name_gao)
		self.lianchonggao_zhanli:SetValue(power_gao)
	end
end

function LianXuChongZhiGao:GetTeHuiItemGao()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = KaifuActivityData.Instance:ChongZhiTeHuiGao()
	if nil == cfg then
		return
	end
	for k, v in pairs(cfg) do
		if open_server_day <= v.open_server_day then
			return v.show_item, v.show_type, v.model_name, v.power, v.show_day
		end
	end
end

function LianXuChongZhiGao:SetRestTimeGao(diff_time)
	if self.count_down_gao == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down_gao ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down_gao)
					self.count_down_gao = nil
				end
				return
			end
			local time_str = ""
			local left_day = math.floor(left_time / 86400)
			if left_day > 0 then
				time_str = TimeUtil.FormatSecond(left_time, 7)
			elseif left_time < 86400 then
				if math.floor(left_time / 3600) > 0 then
					time_str = TimeUtil.FormatSecond(left_time, 1)
				else
					time_str = TimeUtil.FormatSecond(left_time, 2)
				end
			end
			self.lianchonggao_day:SetValue(time_str)
		end
		self:CancelCountDown()
		diff_time_func(0, diff_time)
		self.count_down_gao = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function LianXuChongZhiGao:CancelCountDown()
	if self.count_down_gao ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_gao)
		self.count_down_gao = nil
	end
end

-----------------------------ChongZhiItemCellGroup--------------------------
ChongZhiItemCellGroup = ChongZhiItemCellGroup or BaseClass(BaseRender)

function ChongZhiItemCellGroup:__init()
	self.cell_list = {}
	local cell = ChongZhitemCell.New(self:FindObj("item"))
	table.insert(self.cell_list, cell)

end

function ChongZhiItemCellGroup:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ChongZhiItemCellGroup:SetToggleGroup()

end

function ChongZhiItemCellGroup:SetData(data)
	self.cell_list[1]:SetData(data)
end

function ChongZhiItemCellGroup:SetIndex(index)
	self.cell_list[1]:SetIndex(index)
end

-----------------------------ChongZhitemCell--------------------------
ChongZhitemCell = ChongZhitemCell or BaseClass(BaseCell)
function ChongZhitemCell:__init()
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

function ChongZhitemCell:__delete()
	for i = 1,3 do
		self["item_cell_" .. i]:DeleteMe()
	end
end

function ChongZhitemCell:OnClickLingQu()

	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CHONGZHI_GAO, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD, self.data.day_index)
end

function ChongZhitemCell:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ChongZhitemCell:OnFlush()
	local item_num = KaifuActivityData.Instance:GetChongZhiGao()
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
	local tehuigao = KaifuActivityData.Instance:ChongZhiTeHuiGao()
	for k, v in pairs(tehuigao) do
		if open_sever_day <= v.open_server_day then
			self.chongzhi_coin:SetValue(v.need_chongzhi)
			return
		end
	end

end