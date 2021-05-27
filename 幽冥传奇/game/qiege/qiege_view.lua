
require("scripts/game/qiege/qiege_panel")
require("scripts/game/qiege/shenbin_panel")

QieGeView = QieGeView or BaseClass(BaseView)

function QieGeView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("QieGe")
	self.texture_path_list = {
		'res/xui/qiege.png',
		'res/xui/bag.png',
		
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},

	}

	--self.btn_info = {ViewDef.QieGeView.QieGe, ViewDef.QieGeView.Shenbi｝
	
	self.btn_info = {ViewDef.QieGeView.QieGe, ViewDef.QieGeView.Shenbi, }

	self.remind_list = {}
	for k, v in pairs(self.btn_info) do
		if v.remind_group_name then
			self.remind_list[v.remind_group_name] = k
		end
	end
	self.panel_list = {}

	self.panel_list[1] = QieGePanel.New(ViewDef.QieGeView.QieGe)
	self.panel_list[2] = ShenbinPanel.New(ViewDef.QieGeView.Shenbi)

	--self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))

end

function QieGeView:__delete()
	
end

function QieGeView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.open_event then
		GlobalEventSystem:UnBind(self.open_event)
		self.open_event = nil
	end

	if self.remind_event then
		GlobalEventSystem:UnBind(self.remind_event)
		self.remind_event = nil
	end
	if self.level_change then
		GlobalEventSystem:UnBind(self.level_change)
		self.level_change = nil
	end
	if self.info_change then
		GlobalEventSystem:UnBind(self.info_change)
		self.info_change = nil
	end
end

function QieGeView:LoadCallBack(index, loaded_times)
	if (loaded_times <= 1) then
		if  nil == self.tabbar then
			self.tabbar = Tabbar.New()
			self.tabbar:SetTabbtnTxtOffset(2, 12)
			self.tabbar:SetClickItemValidFunc(function(index)
				return ViewManager.Instance:CanOpen(self.btn_info[index]) 
			end)
			self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
				Language.QieGe.Group, true, ResPath.GetCommon("toggle_110"), 25, true)
		end
		self.tabbar:ChangeToIndex(index or 1)
		self.open_event = GlobalEventSystem:Bind(OPEN_VIEW_EVENT.OpenEvent, BindTool.Bind1(self.ChangTabbar, self))


		--self.remind_cahnge = GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindQieGeChange, self))

		--self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.RemindQieGeChange, self))

		self.level_change = GlobalEventSystem:Bind(QIEGE_EVENT.UpGrade_Result, BindTool.Bind1(self.FlushAllPoint, self))
	
		self.info_change = GlobalEventSystem:Bind(QIEGE_EVENT.GetRewardInfo, BindTool.Bind1(self.FlushAllPoint, self))

		self.wapon_level_change = GlobalEventSystem:Bind(QIEGE_EVENT.QieGeShenBinUp, BindTool.Bind1(self.FlushAllPoint, self))
	end
end

function QieGeView:ChangTabbar(index)
	self.tabbar:ChangeToIndex(index or 1)
end

function QieGeView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
end

function QieGeView:OpenCallBack()
	-- print("ssssssss")
end

function QieGeView:ShowIndexCallBack(index)
	self:Flush(index)

end

function QieGeView:CloseCallBack()
	-- override
end

function QieGeView:OnFlush(param_list)
	-- body
	self:FlushAllPoint()
end

function QieGeView:RemindQieGeChange(remind_name, num)
	if remind_name == RemindName.ShenBin then
		self:FlushBtnRemind(2)
	elseif remind_name == RemindName.QieGe then
		self:FlushBtnRemind(1)
	end
end



function QieGeView:FlushAllPoint( ... )
	for k, v in pairs(self.btn_info) do
		self:FlushBtnRemind(k)
	end
end




function QieGeView:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_group_name then
		local vis = false 
		if index == 1 then
			vis = QieGeData.Instance:GetAllCanup()
		else
			vis = QieGeData.Instance:GetShenBinCanUp()
		end
		self.tabbar:SetRemindByIndex(index, vis)
	end
end


