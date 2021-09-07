CampMemberListView = CampMemberListView or BaseClass(BaseView)

function CampMemberListView:__init()
	self.ui_config = {"uis/views/camp", "CampMemberListView"}
	self:SetMaskBg(true)

	-- self.full_screen = true								-- 是否是全屏界面(ViewManager里面调用)
	self.play_audio = true									-- 播放音效


	self.role_id = 0
	self.lbl_title_type = 1


	-- 根据面板类型绑定请求数据
	self.panel_type_search_type = {
		[CampData.JinYanGuanLi] = SEARCH_TYPE.SEARCH_TYPE_TALK,
		[CampData.NeiJianBiaoJi] = SEARCH_TYPE.SEARCH_TYPE_SET_NEIJIAN,
		[CampData.JieChuNeiJian] = SEARCH_TYPE.SEARCH_TYPE_UNSET_NEIJIAN,
	}

end

function CampMemberListView:__delete()
end

function CampMemberListView:ReleaseCallBack()
	if self.camp_search_mem_cell_list then
		for k,v in pairs(self.camp_search_mem_cell_list) do
			v:DeleteMe()
		end
	end
	self.camp_search_mem_cell_list = {}

	self.lbl_title_name = nil
	self.is_show_search = nil
	self.is_jinyan_panel = nil
	self.is_neijian_panel = nil
	self.is_jiechuneijian_panel = nil
	self.is_reset_btn = nil
	self.lbl_day_num = nil
	self.edit_text = nil
	self.camp_search_mem_list = {}
end

function CampMemberListView:LoadCallBack()
	--监听UI事件
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickCloseHandler, self))
	self:ListenEvent("BtnJinYanSearch", BindTool.Bind(self.OnBtnSearchHandler, self))
	self:ListenEvent("BtnJinYan", BindTool.Bind(self.OnBtnConfirmHandler, self))
	self:ListenEvent("BtnNeiJianSearch", BindTool.Bind(self.OnBtnSearchHandler, self))
	self:ListenEvent("BtnNeiJian", BindTool.Bind(self.OnBtnConfirmHandler, self))
	self:ListenEvent("BtnReSet", BindTool.Bind(self.OnBtnReSetHandler, self))
	self:ListenEvent("BtnRelieve", BindTool.Bind(self.OnBtnConfirmHandler, self))

	self:ListenEvent("BtnConfirmSearch", BindTool.Bind(self.OnBtnConfirmSearchHandler, self))
	self:ListenEvent("OnCloseSearch", BindTool.Bind(self.OnBtnColseSearchHandler, self))

	-- 获取变量
	self.lbl_title_name = self:FindVariable("TitleNmae")
	self.is_show_search = self:FindVariable("IsShowSearch")
	self.is_jinyan_panel = self:FindVariable("IsJinYanPanel")
	self.is_neijian_panel = self:FindVariable("IsNeiJianPanel")
	self.is_jiechuneijian_panel = self:FindVariable("IsJieChuNeiJianPanel")
	self.is_reset_btn = self:FindVariable("IsReSetBtn")
	self.lbl_day_num = self:FindVariable("DayNum")

	self.edit_text = self:FindObj("InputName")

	----------------------------------------------------
	-- 列表生成滚动条
	self.camp_search_mem_cell_list = {}
	self.camp_search_mem_listview_data = {}
	self.camp_search_mem_list = self:FindObj("ListView")
	local camp_search_mem_list_delegate = self.camp_search_mem_list.list_simple_delegate
	--生成数量
	camp_search_mem_list_delegate.NumberOfCellsDel = function()
		return #self.camp_search_mem_listview_data or 0
	end
	--刷新函数
	camp_search_mem_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCampSearchMemListView, self)
	-- 移动scrollerview的时候调用
	-- self.camp_search_mem_list.scroller.scrollerScrollingChanged = function ()
	-- end
	----------------------------------------------------
end

function CampMemberListView:OpenCallBack()
	CampMemberListItemRender.SelectIndex = -1
	if self.is_reset_btn then
		self.is_reset_btn:SetValue(false)
	end
	self.role_id = 0
	self.lbl_title_type = CampData.Instance:GetMemberListType()
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SEARCH_USER, self.panel_type_search_type[self.lbl_title_type] or SEARCH_TYPE.SEARCH_TYPE_TALK)
end

function CampMemberListView:CloseCallBack()
	self.role_id = 0
	self.lbl_title_type = 1
	self.camp_search_mem_listview_data = {}
	self.camp_search_mem_list.scroller:ReloadData(0)
	CampData.Instance:ClearCampSearchMemList()
end

function CampMemberListView:OnClickCloseHandler()
	ViewManager.Instance:Close(ViewName.CampMemberList)
end

function CampMemberListView:ShowIndexCallBack(index)
	self:Flush()
end

function CampMemberListView:OnFlush(param_list)
	CampMemberListItemRender.SelectIndex = -1
	self.is_jinyan_panel:SetValue(false)
	self.is_neijian_panel:SetValue(false)
	self.is_jiechuneijian_panel:SetValue(false)

	local camp_search_meem_info = CampData.Instance:GetCampSearchMemList()

	self.lbl_title_name:SetValue(Language.Camp.CampMemberListName[self.lbl_title_type] or "")

	local day_num = ""
	if self.lbl_title_type == CampData.JinYanGuanLi then
		self.is_jinyan_panel:SetValue(true)
	elseif self.lbl_title_type == CampData.NeiJianBiaoJi then
		self.is_neijian_panel:SetValue(true)
		day_num = string.format(Language.Camp.DayNum, CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.NEIJIANBIAOJI))
	elseif self.lbl_title_type == CampData.JieChuNeiJian then
		self.is_jiechuneijian_panel:SetValue(true)
		day_num = string.format(Language.Camp.DayNum, CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.SHEMIANNEIJIAN))
	end
	self.lbl_day_num:SetValue(day_num)

	-- 设置list数据
	self.camp_search_mem_listview_data = camp_search_meem_info.item_info_list
	if self.camp_search_mem_list.scroller.isActiveAndEnabled then
		self.camp_search_mem_list.scroller:ReloadData(0)
	end
end

-- 列表listview
function CampMemberListView:RefreshCampSearchMemListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local camp_search_mem_cell = self.camp_search_mem_cell_list[cell]
	if camp_search_mem_cell == nil then
		camp_search_mem_cell = CampMemberListItemRender.New(cell.gameObject)
		camp_search_mem_cell:SetToggleGroup(self.camp_search_mem_list.toggle_group)
		camp_search_mem_cell:SetClickCallBack(BindTool.Bind1(self.ClickCampSearchMemHandler, self))
		self.camp_search_mem_cell_list[cell] = camp_search_mem_cell
	end
	camp_search_mem_cell:SetIndex(data_index)
	camp_search_mem_cell:SetData(self.camp_search_mem_listview_data[data_index])
end

-- 回调函数
function CampMemberListView:ClickCampSearchMemHandler(cell)
	if nil == cell or nil == cell.data then return end
	self.role_id = cell.data.role_id
end

-- 搜索
function CampMemberListView:OnBtnSearchHandler()
	self.is_show_search:SetValue(true)
end

-- 关闭搜索面板
function CampMemberListView:OnBtnColseSearchHandler()
	self.is_show_search:SetValue(false)
end

-- 搜索名字
function CampMemberListView:OnBtnConfirmSearchHandler()
	if self.edit_text.input_field.text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.SearchName)
		return
	end
	CampCtrl.Instance:SendCampAppointSearchUser(SEARCH_TYPE.SEARCH_TYPE_NAME, self.edit_text.input_field.text)
	self.is_show_search:SetValue(false)
	self.is_reset_btn:SetValue(true)
end

-- 确定
function CampMemberListView:OnBtnConfirmHandler()
	if self.role_id > 0 then
		if self.lbl_title_type == CampData.JinYanGuanLi then
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_FORBID_TALK, self.role_id)
		elseif self.lbl_title_type == CampData.NeiJianBiaoJi then
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_SET_NEIJIAN, self.role_id, 1)
		elseif self.lbl_title_type == CampData.JieChuNeiJian then
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_SET_NEIJIAN, self.role_id, 0)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.ConfirmRoleTips)
	end
end

-- 重置信息
function CampMemberListView:OnBtnReSetHandler()
	self:OpenCallBack()
end


----------------------------------------------------------------------------
--CampMemberListItemRender	成员列表
----------------------------------------------------------------------------
CampMemberListItemRender = CampMemberListItemRender or BaseClass(BaseCell)
CampMemberListItemRender.SelectIndex = -1

function CampMemberListItemRender:__init()
	self.lbl_guanzhi = self:FindVariable("GuanZhi")
	self.show_deny = self:FindVariable("ShowDeny")
	self.show_not_deny = self:FindVariable("ShowNotDeny")
	self.show_traitor = self:FindVariable("ShowTraitor")
	self.lbl_player_name = self:FindVariable("PlayerName")
	self.show_vip_icon = self:FindVariable("ShowVipIcon")
	self.is_female = self:FindVariable("IsFemale")
	self.lbl_level = self:FindVariable("Level")
	self.lbl_subjection_family = self:FindVariable("SubjectionFamily")
	self.lbl_capability = self:FindVariable("Capability")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItemHandler, self))
end

function CampMemberListItemRender:__delete()
end

function CampMemberListItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	self.lbl_guanzhi:SetValue("")
	self.show_deny:SetValue(false)
	self.show_not_deny:SetValue(false)
	self.show_traitor:SetValue(false)

	local member_list_type = CampData.Instance:GetMemberListType()
	if member_list_type == CampData.JinYanGuanLi then
		self.show_deny:SetValue(self.data.is_forbidden_talk == 1)
		self.show_not_deny:SetValue(self.data.is_forbidden_talk ~= 1)
	elseif member_list_type == CampData.NeiJianBiaoJi then
		if self.data.is_neijian == 1 then
			self.show_traitor:SetValue(true)
		else
			self.lbl_guanzhi:SetValue(Language.Common.CampPost[self.data.post] or "")
		end
	elseif member_list_type == CampData.JieChuNeiJian then
		self.show_traitor:SetValue(true)
	end

	self.lbl_player_name:SetValue(self.data.name or "")
	self.show_vip_icon:SetValue(self.data.vip_level > 0)
	self.is_female:SetValue(self.data.sex == GameEnum.FEMALE)
	self.lbl_level:SetValue(self.data.level)
	if self.data.guild_name == "" then
		self.lbl_subjection_family:SetValue(Language.Common.No)
	else
		self.lbl_subjection_family:SetValue(self.data.guild_name or Language.Common.No)
	end
	self.lbl_capability:SetValue(self.data.capability)
	
	self.root_node.toggle.isOn = (CampMemberListItemRender.SelectIndex == self.index)

end

function CampMemberListItemRender:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function CampMemberListItemRender:OnClickItemHandler()
	self.root_node.toggle.isOn = true
	CampMemberListItemRender.SelectIndex = self.index
	self:OnClick()
end