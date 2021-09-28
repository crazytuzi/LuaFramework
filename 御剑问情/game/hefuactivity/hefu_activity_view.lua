HefuActivityView = HefuActivityView or BaseClass(BaseView)

-- 这里面的sub_type 对应枚举game_enum里面的COMBINE_SERVER_ACTIVITY_SUB_TYPE
function HefuActivityView:__init()
	self.ui_config = {"uis/views/hefuactivity_prefab", "HeFuView"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.cur_index = 1
	self.cell_list = {}
	self.panel_list = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.cur_tab_list_length = 0

	self.cur_sub_type = 0 							-- 当前显示活动对应的活动号
	self.last_sub_type = 0 							-- 上一个显示活动对应的活动号

	-- key:sub_type
	-- value:script_file
	self.script_list = {
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU] = RushToPurchase,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL] = LucklyTurntable,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_GONGCHENGZHAN] = CityContend,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS] = BossLoot,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK] = CombineServerChongZhiRank,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK] = CombineServerConsubeRank,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_PERSONAL_PANIC_BUY] = PersonFullServerSnapView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY] = HeFuFullServerSnapView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SINGLE_CHARGE] = CombineServerDanBiChongZhi,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_LOGIN_Gift] = LoginjiangLiView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS] = HeFuBossView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI] = HeFuTouZiView,
		[COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_JIJIN] = HeFuJiJinView,
	}
end

function HefuActivityView:__delete()
	self.script_list = {}
end

function HefuActivityView:ReleaseCallBack()
	self.cur_sub_type = 0
	self.last_sub_type = 0

	self.cur_index = 1
	self.cur_day = nil

	for k, v in pairs(self.panel_list) do
		v:DeleteMe()
	end
	self.panel_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.HefuActivityView)
	end
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	-- 清理变量和对象
	self.panel_obj_list = nil
	self.panel_list = nil
	self.btn_close = nil
	self.right_content = nil
	self.tab_list = nil
end

function HefuActivityView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self.panel_obj_list = {
	}

	self.panel_list = {}

	self.tab_list = self:FindObj("ToggleList")
	local list_delegate = self.tab_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:Flush()

	self.btn_close = self:FindObj("BtnClose")								--关闭按钮
	self.right_content = self:FindObj("RightContent")
	-- FunctionGuide.Instance:RegisteGetGuideUi(ViewName.HefuActivityView, BindTool.Bind(self.GetUiCallBack, self))
	-- RemindManager.Instance:Bind(self.remind_change, RemindName.HeFu)
end

function HefuActivityView:GetNumberOfCells()
	self.cur_tab_list_length = #HefuActivityData.Instance:GetCombineSubActivityList()
	return #HefuActivityData.Instance:GetCombineSubActivityList()
end

function HefuActivityView:RefreshCell(cell, data_index)
	local list = HefuActivityData.Instance:GetCombineSubActivityList()
	if not list or not next(list) then return end

	local config_index = data_index + 1

	local sub_type = list[config_index] and list[config_index].sub_type or 0

	local tab_btn = self.cell_list[cell]
	if tab_btn == nil then
		tab_btn = LeftTableButton.New(cell.gameObject)
		tab_btn:SetToggleGroup(self.tab_list.toggle_group)
		self.cell_list[cell] = tab_btn
	end
	tab_btn:SetHighLight(self.cur_sub_type == sub_type)
	tab_btn:ListenClick(BindTool.Bind(self.OnClickTabButton, self, sub_type, config_index, tab_btn))

	local data = {}
	data.is_show = HefuActivityData.Instance:GetShowRedPointBySubType(sub_type)
	data.is_show_effect = false
	data.name = list[config_index].name
	tab_btn:SetData(data)
end

function HefuActivityView:OnClickClose()
	self:Close()
end

function HefuActivityView:OnClickTabButton(sub_type, index, tab_btn)
	tab_btn:SetHighLight(true)
	if self.cur_sub_type == sub_type then
		return
	end

	self.cur_index = index
	self:ChangeShowChildPanle(sub_type)
	self:Flush()
end

function HefuActivityView:ChangeShowChildPanle(sub_type)
	if self.cur_sub_type == sub_type then
		return
	end

	self.last_sub_type = self.cur_sub_type
	self.cur_sub_type = sub_type

	self:OpenChildPanel()
	self:CloseChildPanel()
end

-- 因为opencallback没有传参数，所以这里其实只在open调用一次后不再调用,当opencallback使用
function HefuActivityView:ShowIndexCallBack(sub_type)
	local list = HefuActivityData.Instance:GetCombineSubActivityList()
	local def_sub_type = list[1] and list[1].sub_type or 0
	sub_type = sub_type > 0 and sub_type or def_sub_type

	self:ChangeShowChildPanle(sub_type)
	self:Flush()
end

function HefuActivityView:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_INFO_REQ)
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_RANK_REQ)
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ROLE_INFO_REQ)
end

function HefuActivityView:CloseCallBack()
	self.cur_tab_list_length = 0
end

function HefuActivityView:RemindChangeCallBack(remind_name, num)
	self:Flush()
end

function HefuActivityView:OnFlush(param_t)
	-- 刷新左边按钮
	self:FlushLeftTabListView(list)
	-- 刷新当前显示面板
print_error(self.cur_sub_type)
	local cur_show_panel = self.panel_list[self.cur_sub_type]
	if cur_show_panel then
		for k,v in pairs(param_t) do
			if k == "luckly" then
				cur_show_panel:Flush(k)
				return
			else
				cur_show_panel:Flush()
			end
		end
	end
end

function HefuActivityView:FlushLeftTabListView()
	local list = HefuActivityData.Instance:GetCombineSubActivityList()
	if list == nil or next(list) == nil then return end

	if self.tab_list.scroller.isActiveAndEnabled then
		if self.cur_day ~= TimeCtrl.Instance:GetCurOpenServerDay() or self.cur_tab_list_length ~= #list then
			self.tab_list.scroller:ReloadData(0)
		else
			self.tab_list.scroller:RefreshActiveCellViews()
		end
	end
	self.cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
end

function HefuActivityView:OpenChildPanel()
	local panel = self.panel_list[self.cur_sub_type]
	if nil == panel then
		UtilU3d.PrefabLoad(
			"uis/views/hefuactivity/childpanel_prefab",
			"panel_" .. self.cur_sub_type,
			function(obj)
				obj.transform:SetParent(self.right_content.transform, false)
				obj = U3DObject(obj)
				if nil == self.script_list[self.cur_sub_type] then
					print_error("没有对应的脚本文件！！！！, 活动号：", self.cur_sub_type)
					return
				end
				panel = self.script_list[self.cur_sub_type].New(obj)
				self.panel_list[self.cur_sub_type] = panel
				panel:SetActive(true)
				if panel.OpenCallBack then
					panel:OpenCallBack()
				end
			end)
	else
		panel:SetActive(true)

		if panel.OpenCallBack then
			panel:OpenCallBack()
		end
	end
end

function HefuActivityView:CloseChildPanel()
	if self.cur_sub_type == self.last_sub_type then
		return
	end

	local panel = self.panel_list[self.last_sub_type]
	if nil == panel then
		return
	end
	if panel.CloseCallBack then
		panel:CloseCallBack()
	end
	panel:SetActive(false)

end

function HefuActivityView:FlushTurntable()
	if self.cur_sub_type == COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL then
		self.panel_list[self.cur_sub_type]:FlushNeedle()
	end
end

