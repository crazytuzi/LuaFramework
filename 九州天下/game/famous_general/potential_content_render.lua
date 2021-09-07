PotentialRenderView = PotentialRenderView or BaseClass(BaseRender)
function PotentialRenderView:__init()
	self.prog_list = {}
	self.cell_list = {}
	self.select_index = 1
	self.cur_index = nil
	self.cur_select_index = 1
	self.cur_capability = 0
	self.new_capability = 0
	self.flag = false
end
function PotentialRenderView:ReleaseCallBack()
	self.flag = nil
	self.stop_up_level = nil
end

function PotentialRenderView:LoadCallBack()
	self.wash_item = ItemCell.New()
	self.wash_item:SetInstanceParent(self:FindObj("ItemCell"))
	self.name = self:FindVariable("Name")
	self.desc = self:FindVariable("Desc")
	self.desc1 = self:FindVariable("Desc1")
	self.capability = self:FindVariable("Capability")
	for i = 1, 3 do
		local data = {}
		data.text = self:FindVariable("prog_value_" .. i)
		data.progress = self:FindVariable("Progress_" .. i)
		data.progress_bg = self:FindVariable("Progress_bg_" .. i)
		self.prog_list[i] = data
	end
	self.item_num = self:FindVariable("ItemNum")
	self.btn_text = self:FindVariable("BtnText")
	self.stop_up_level = self:FindVariable("StopUpLevel")

	self:ListenEvent("OnClickUp", BindTool.Bind(self.OnClickUp, self))
	self:ListenEvent("OnClickLeft", BindTool.Bind(self.OnClickArrow, self, -1))
	self:ListenEvent("OnClickRight", BindTool.Bind(self.OnClickArrow, self, 1))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoleNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRoleCell, self)

	local display = self:FindObj("Display")
	self.role_model = RoleModel.New("famous_general_panel")
	self.role_model:SetDisplay(display.ui3d_display)
	
	self.desc:SetValue(Language.FamousGeneral.PotentialDesc)
	self.desc1:SetValue(string.format(Language.FamousGeneral.PotentialDesc1,FamousGeneralData.Instance:GeneralInfoCfg()[1].wash_attr_critial_add_gongji))
	self.cur_select_index = FamousGeneralData.Instance:GetSelectIndex()
	self.select_index = FamousGeneralData.Instance:AfterSortList()[self.cur_select_index].seq + 1
	FamousGeneralCtrl.Instance:SetCurSelectIndex(self.select_index - 1)
	self:ListenEvent("OnClickGetWay", BindTool.Bind(self.OnClickGetWay, self))
end

function PotentialRenderView:OpenCallBack()
	self.list_view.scroller:ReloadData(0)
end

function PotentialRenderView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.wash_item then 
		self.wash_item:DeleteMe()
		self.wash_item = nil
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	self.cur_capability = 0
	self.new_capability = 0
end

function PotentialRenderView:OnClickUp()
	if self.flag then 
		self:StopOnClickUpLevel()
		return
	end
	self.stop_up_level:SetValue(true)
	self.flag = true
	self:ContinueUpLevel()
end

function PotentialRenderView:ContinueUpLevel()
	if nil ~= self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	local select_seq = self.select_index - 1
	local function send()
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GRAETE_SOLDIER_REQ_TYPE_WASH_ATTR, select_seq)
	end
	if self.flag then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(send, self), 0.1)
	end	
end

function PotentialRenderView:StopOnClickUpLevel()
	self.flag = false
	self.stop_up_level:SetValue(false)
end

function PotentialRenderView:GetRoleNum()
	return #FamousGeneralData.Instance:AfterSortList()
end

function PotentialRenderView:RefreshRoleCell(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.cell_list[cell]
	local data_list = FamousGeneralData.Instance:AfterSortList()
	if not item_cell then
		item_cell = GeneralHeadRender.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end
	item_cell:SetParent(self)
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data_list[cell_index])
	item_cell:ListenClick(BindTool.Bind(self.OnClickRoleListCell, self, cell_index, data_list[cell_index], item_cell))
	item_cell:FlushHL()
	item_cell:CurSelectTab(2)
end

function PotentialRenderView:GetSelectIndex()
	return self.cur_select_index
end

function PotentialRenderView:OnClickRoleListCell(cell_index, cell_data, item_cell)
	if self.cur_select_index == cell_index then return end
	self:StopOnClickUpLevel()
	FamousGeneralData.Instance:SetSelectIndex(cell_index)
	self.select_index = cell_data.seq + 1
	self.cur_select_index = cell_index
	self:FlushAllHl()
	self:Flush()
	FamousGeneralCtrl.Instance:SetCurSelectIndex(self.select_index - 1)
end

function PotentialRenderView:OnClickGetWay()
	local other_info = FamousGeneralData.Instance:GetOtherCfg()
	if not other_info then return end
	ViewManager.Instance:OpenByCfg(other_info.wash_open_panel)
end

function PotentialRenderView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "list_data" then
			-- self.cur_select_index = FamousGeneralData.Instance:GetIndexBySeq(self.select_index - 1)
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
			-- self.list_view.scroller:JumpToDataIndexForce(self.cur_select_index - 1)
		elseif k == "change_index" then
			-- self.cur_select_index = FamousGeneralData.Instance:GetSelectIndex()
			-- self.select_index = FamousGeneralData.Instance:AfterSortList()[self.cur_select_index].seq + 1
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
			-- self.list_view.scroller:JumpToDataIndexForce(self.cur_select_index - 1)
		elseif k == "Continue" then
			self:ContinueUpLevel()
		elseif k == "Stop" then
			self:StopOnClickUpLevel()	
		end
	end
	local select_cfg = FamousGeneralData.Instance:GetSingleDataBySeq(self.select_index - 1)
	if not select_cfg then return end
	local select_info = FamousGeneralData.Instance:GetGeneralSingleInfoBySeq(select_cfg.seq)
	if not select_info then return end
	local wash_point_limit = FamousGeneralData.Instance:GetWashPointLimitByIndexAndLevel(self.select_index, select_info.level)

	local wash_info = select_info.wash_attr_points
	for k,v in pairs(wash_info) do
		local index = k + 1
		local prog = self.prog_list[index]
		if prog then
			local percent = v * 100 / wash_point_limit[FamousGeneralData.PotentialLimit[index]]
			local color = FamousGeneralData.Instance:GetTextColor(percent)
			prog.text:SetValue(ToColorStr(v, ITEM_COLOR[color]) .. "/" .. wash_point_limit[FamousGeneralData.PotentialLimit[index]])
			prog.progress:SetValue(percent)
			local bundle, asset = ResPath.GetFamousGeneral("prog_" .. color)
			prog.progress_bg:SetAsset(bundle, asset)
		end
	end
	local own_num = ItemData.Instance:GetItemNumInBagById(select_cfg.wash_attr_item_id)
	self.item_num:SetValue(own_num .. "/1")
	self.wash_item:SetData({item_id = select_cfg.wash_attr_item_id})
	local is_orangeo = FamousGeneralData.Instance:IsAllOrangeo(self.select_index - 1)
	local ratio = is_orangeo and 1.2 or 1
	local cap_data = {}
	cap_data.gongji = select_info.wash_attr_points[0]
	cap_data.fangyu = select_info.wash_attr_points[1]
	cap_data.maxhp = select_info.wash_attr_points[2]
	self.cur_capability = CommonDataManager.GetCapability(cap_data)
	self.capability:SetValue(self.cur_capability)

	local temp_is_orangeo = FamousGeneralData.Instance:IsTempAllOrangeo(self.select_index - 1)
	local temp_ratio = temp_is_orangeo and 1.2 or 1
	local new_info = {
		["gongji"] = select_info.gongji_tmp,
		["fangyu"] = select_info.fangyu_tmp,
		["hp"] = select_info.hp_tmp,
		}
	self.new_capability = CommonDataManager.GetAllAttrSum(new_info) * 2 * ratio						-- 策划觉得评分太低 要改计算方式

	if self.cur_index ~= self.select_index then
		local bundle, asset = ResPath.GetMingJiangRes(select_cfg.image_id)
		self.role_model:SetMainAsset(bundle, asset)
		self.role_model:SetTrigger("attack10")
		self.cur_index = self.select_index
	end
	-- self.name:SetValue(select_cfg.name)
	local name_str = ToColorStr(select_cfg.name, ITEM_COLOR[select_cfg.color])
	self.name:SetValue(string.format(Language.FamousGeneral.Name, name_str, select_info.level))
end

function PotentialRenderView:OnClickArrow(num)
	local max_num = self:GetRoleNum()
	self.select_index = self.select_index + num
	if self.select_index > max_num then
		self.select_index = max_num
		return
	elseif self.select_index < 1 then
		self.select_index = 1
		return 
	end
	self:FlushAllHl()  
	self.list_view.scroller:JumpToDataIndex(self.select_index - 1)
	self:Flush()
end

function PotentialRenderView:FlushAllHl()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function PotentialRenderView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(199)
end