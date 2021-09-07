CampAppointView = CampAppointView or BaseClass(BaseView)

function CampAppointView:__init()
	self.ui_config = {"uis/views/camp", "AppointView"}
	self:SetMaskBg(true)

	-- self.full_screen = true								-- 是否是全屏界面(ViewManager里面调用)
	self.play_audio = true									-- 播放音效


	self.role_id = 0
	self.camp_post = 0
	self.player_name = ""
end

function CampAppointView:__delete()
end

function CampAppointView:ReleaseCallBack()
	if self.camp_search_mem_cell_list then
		for k,v in pairs(self.camp_search_mem_cell_list) do
			v:DeleteMe()
		end
	end
	self.camp_search_mem_cell_list = {}

	self.is_show_search = nil
	self.is_reset_btn = nil
	self.edit_text = nil

	self.camp_search_mem_list = nil
end

function CampAppointView:LoadCallBack()
	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.OnCloseHandler, self))
	self:ListenEvent("OnBtnSearch", BindTool.Bind(self.OnBtnSearchHandler, self))
	self:ListenEvent("OnBtnBanned", BindTool.Bind(self.OnBtnBannedHandler, self))
	self:ListenEvent("BtnColseSearch", BindTool.Bind(self.OnBtnColseSearchHandler, self))
	self:ListenEvent("BtnConfirmSearch", BindTool.Bind(self.OnBtnConfirmSearchHandler, self))
	self:ListenEvent("BtnReSet", BindTool.Bind(self.OnBtnReSetHandler, self))

	-- 获取变量
	self.is_show_search = self:FindVariable("IsShowSearch")
	self.is_reset_btn = self:FindVariable("IsReSetBtn")

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

function CampAppointView:OpenCallBack()
	CampAppointItemRender.SelectIndex = -1
	self.role_id = 0
	self.camp_post = CampData.Instance:GetAppointCampPost()
	self.player_name = ""
	if self.is_reset_btn then
		self.is_reset_btn:SetValue(false)
	end
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SEARCH_USER, SEARCH_TYPE.SEARCH_TYPE_SET_NEIJIAN)
end

function CampAppointView:CloseCallBack()
	self.role_id = 0
	self.player_name = ""
end

function CampAppointView:OnCloseHandler()
	ViewManager.Instance:Close(ViewName.CampAppoint)
end

function CampAppointView:ShowIndexCallBack(index)
	self:Flush()
end

function CampAppointView:OnFlush(param_list)
	CampAppointItemRender.SelectIndex = -1
	local camp_search_meem_info = CampData.Instance:GetCampSearchMemList()

	-- 设置list数据
	self.camp_search_mem_listview_data = camp_search_meem_info.item_info_list
	if self.camp_search_mem_list.scroller.isActiveAndEnabled then
		self.camp_search_mem_list.scroller:ReloadData(0)
	end
	
end

-- 列表listview
function CampAppointView:RefreshCampSearchMemListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local camp_search_mem_cell = self.camp_search_mem_cell_list[cell]
	if camp_search_mem_cell == nil then
		camp_search_mem_cell = CampAppointItemRender.New(cell.gameObject)
		camp_search_mem_cell:SetToggleGroup(self.camp_search_mem_list.toggle_group)
		camp_search_mem_cell:SetClickCallBack(BindTool.Bind1(self.ClickCampSearchMemHandler, self))
		self.camp_search_mem_cell_list[cell] = camp_search_mem_cell
	end
	camp_search_mem_cell:SetIndex(data_index)
	camp_search_mem_cell:SetData(self.camp_search_mem_listview_data[data_index])
end

-- 回调函数
function CampAppointView:ClickCampSearchMemHandler(cell)
	if nil == cell or nil == cell.data then return end
	-- self.player_name = cell.data.name
	self.role_id = cell.data.role_id
end

-- 搜索
function CampAppointView:OnBtnSearchHandler()
	self.is_show_search:SetValue(true)
end

-- 任命
function CampAppointView:OnBtnBannedHandler()
	if self.role_id > 0 and self.camp_post > 0 then
		CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_APPOINT_OFFICER, self.role_id, self.camp_post)
		self:Close()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.RenMingTips)
	end
end

-- 关闭搜索面板
function CampAppointView:OnBtnColseSearchHandler()
	self.is_show_search:SetValue(false)
end

-- 搜索名字
function CampAppointView:OnBtnConfirmSearchHandler()
	if self.edit_text.input_field.text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.SearchName)
		return
	end
	CampCtrl.Instance:SendCampAppointSearchUser(SEARCH_TYPE.SEARCH_TYPE_NAME, self.edit_text.input_field.text)
	self.is_show_search:SetValue(false)
	self.is_reset_btn:SetValue(true)
end

-- 重置用户信息
function CampAppointView:OnBtnReSetHandler()
	self:OpenCallBack()
end


----------------------------------------------------------------------------
--CampAppointItemRender	成员列表
----------------------------------------------------------------------------
CampAppointItemRender = CampAppointItemRender or BaseClass(BaseCell)
CampAppointItemRender.SelectIndex = -1

function CampAppointItemRender:__init()
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

function CampAppointItemRender:__delete()

end

function CampAppointItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	self.lbl_guanzhi:SetValue(Language.Common.CampPost[self.data.post] or "")
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

	self.root_node.toggle.isOn = (CampAppointItemRender.SelectIndex == self.index)

	-- self.content_label:SetValue(ToColorStr(self.data.user_name, COLOR.YELLOW) .. ":" .. self.data.contract_notice)
end

function CampAppointItemRender:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function CampAppointItemRender:OnClickItemHandler()
	self.root_node.toggle.isOn = true
	CampAppointItemRender.SelectIndex = self.index
	self:OnClick()
end