OtherCampYunBiaoView = OtherCampYunBiaoView or BaseClass(BaseView)

function OtherCampYunBiaoView:__init()
	self.ui_config = {"uis/views/nationalwarfareview","OtherCampYunBiaoInfo"}
	self:SetMaskBg(true)
	self.cur_index = 0
end

function OtherCampYunBiaoView:__delete()

end

function OtherCampYunBiaoView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickJieBiao", BindTool.Bind(self.OnClickJieBiao, self))
	self.cell_list = {}
	self:InitScroller()
end

function OtherCampYunBiaoView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.scroller = nil
	self.list_view_delegate = nil
	self.enhanced_cell_type = nil
end

function OtherCampYunBiaoView:OpenCallBack()
	local info = NationalWarfareData.Instance:GetCampYunbiaoUsers()
	if nil ~= info[1] and nil ~= next(info[1]) then
		CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_GET_ROB_YUNBIAO_USER, info[1].role_id)
	end
end

function OtherCampYunBiaoView:OnFlush()
	self:FlushYunBiao()
end

function OtherCampYunBiaoView:OnClickClose()
	self:Close()
end

function OtherCampYunBiaoView:OnClickJieBiao()
	local info = NationalWarfareData.Instance:GetCampYunbiaoUsers()
	if nil == info or nil == next(info) then return end
	local data = CampData.Instance:GetCampCommonInfo()
	if nil == data or nil == next(data) then return end
	local str = ""
	if data.result_type == CAMP_RESULT_TYPE.RESULT_TYPE_ROB_USER_INFO then
		local scene_config = ConfigManager.Instance:GetSceneConfig(data.param4)
		if nil == scene_config then return end
		str = string.format(Language.NationalWarfare.QianWangYunBiao, scene_config.name, data.param1, data.param2, info[self.cur_index + 1].role_name)
	end
	local ok_fun = function ()
		self:Close()
		ViewManager.Instance:Close(ViewName.NationalWarfare)
		local data = CampData.Instance:GetCampCommonInfo()
		if data.result_type == CAMP_RESULT_TYPE.RESULT_TYPE_ROB_USER_INFO then
			GuajiCtrl.Instance:MoveToPos(data.param4, data.param1, data.param2, 0, 0)
		end
	end
		
	TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, str)
end

-- 刷新运镖列表
function OtherCampYunBiaoView:FlushYunBiao()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

-- 初始化申请列表
function OtherCampYunBiaoView:InitScroller()
	self.scroller_data = {}

	self.list_view_delegate = ListViewDelegate()
	self.scroller = self:FindObj("Scroller")

	PrefabPool.Instance:Load(AssetID("uis/views/nationalwarfareview_prefab", "YunBiaoItemInfo"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.enhanced_cell_type = enhanced_cell_type
		self.scroller.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)

		PrefabPool.Instance:Free(prefab)
	end)
end

--滚动条数量
function OtherCampYunBiaoView:GetNumberOfCells()
	local info = NationalWarfareData.Instance:GetCampYunbiaoUsers()
	return #info
end

--滚动条大小 68
function OtherCampYunBiaoView:GetCellSize(data_index)
	return 68
end

--滚动条刷新
function OtherCampYunBiaoView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)

	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = YunBiaoInfoViewScrollCell.New(cell_view)
		cell = self.cell_list[cell_view]
		-- cell.info_view = self
		cell:AddClickEventListener(BindTool.Bind(self.OnClickItemCallBack, self, cell_index))
		-- cell:ListenAllEvent()
	end
	cell:SetData(data_index)
	return cell_view
end

function OtherCampYunBiaoView:OnClickItemCallBack(cell_index)
	self.cur_index = cell_index
	NationalWarfareData.Instance:SetYunBiaoCurIndex(cell_index)
	self.scroller.scroller:ReloadData(0)
	local info = NationalWarfareData.Instance:GetCampYunbiaoUsers()
	if nil ~= info[cell_index + 1] and nil ~= next(info[cell_index + 1]) then
		CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_GET_ROB_YUNBIAO_USER, info[cell_index + 1].role_id)
	end
end
---------------------------------------------YunBiaoInfoViewScrollCell-------------------------------------------
YunBiaoInfoViewScrollCell = YunBiaoInfoViewScrollCell or BaseClass(BaseCell)

function YunBiaoInfoViewScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.color = self:FindVariable("Color")
	self.name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.job = self:FindVariable("Job")
	self.power = self:FindVariable("Power")
	self.show_select = self:FindVariable("show_select")
end

function YunBiaoInfoViewScrollCell:__delete()

end

function YunBiaoInfoViewScrollCell:Flush()
	local info = NationalWarfareData.Instance:GetCampYunbiaoUsers()[self.data + 1]

	if info then
		local yunbiao_user = ToColorStr(Language.Common.CampNameAbbr[info.camp], CAMP_COLOR[info.camp]) .. info.role_name
		--self.color:SetValue(Language.Card.ColorName[info.task_color])							--Language.Card.ColorName[info.task_color]
		self.color:SetValue(ToColorStr(Language.Card.ColorName[info.task_color], YUNBIAO_COLOR[info.task_color]))
		self.name:SetValue(yunbiao_user)
		self.level:SetValue(info.level)
		self.job:SetValue(Language.Common.ProfName[info.prof]) 			--Language.Common.ProfName[info.prof]
		self.power:SetValue(tostring(info.capability))
	end
	local cur_select = NationalWarfareData.Instance:GetYunBiaoCurIndex()
	self.show_select:SetValue(cur_select == self.data)
end
