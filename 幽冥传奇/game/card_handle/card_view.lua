CardView = CardView or BaseClass(BaseView)

function CardView:__init()
	self.title_img_path = ResPath.GetWord("word_cardhandlebook")
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	
	self.texture_path_list = {
		'res/xui/boss.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		-- {"new_boss_ui_cfg", 13, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}
	
	self.btn_info = {ViewDef.CardHandlebook.CardView, ViewDef.CardHandlebook.Descompose}

	require("scripts/game/card_handle/car_view/car_class_view").New(ViewDef.CardHandlebook.CardView, self)
	require("scripts/game/card_handle/descompose_card/descompose_card_view").New(ViewDef.CardHandlebook.Descompose, self)

end

function CardView:ReleaseCallBack()
	self.card_tabbar:DeleteMe()

	-- if self.timer then
	-- 	GlobalTimerQuest:CancelQuest(self.timer)
	-- 	self.timer = nil
	-- end

	-- GlobalEventSystem:UnBind(self.scene_change)
	-- self.scene_change = nil
end

function CardView:LoadCallBack(index, loaded_times)
	self.tabbar_index = 1

	self:InitTabbar()

	-- self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, function ()
	-- 	ViewManager.Instance:CloseViewByDef(ViewDef.CardView)
	-- end)

	self:CardRemindTabbar()

	EventProxy.New(CardHandlebookData.Instance, self):AddEventListener(CardHandlebookData.UPDATE_CARD_INFO, BindTool.Bind(self.CardRemindTabbar, self))
end

--标签栏初始化
function CardView:InitTabbar()
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.card_tabbar = Tabbar.New()
	self.card_tabbar:SetTabbtnTxtOffset(2, 12)
	self.card_tabbar:SetClickItemValidFunc(function(index)
		self.tabbar_index = index
		return ViewManager.Instance:CanOpen(self.btn_info[index]) 
	end)
	self.card_tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
		name_list, true, ResPath.GetCommon("toggle_110"), 25, true)
end

--选择标签回调
function CardView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	--刷新标签栏显示
	for k, v in pairs(self.btn_info) do
		if v.open then
			self.card_tabbar:ChangeToIndex(k)
			break
		end
	end
end

function CardView:ShowIndexCallBack(index)
	for k, v in pairs(self.btn_info) do
		if v.open then
			self.card_tabbar:ChangeToIndex(k)
			break
		end
	end
end

function CardView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CardView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CardView:OnFlush(param_t, index)
	
end

-- 标签栏提醒
function CardView:CardRemindTabbar()
	self.card_tabbar:SetRemindByIndex(1, CardHandlebookData.Instance:GetRemindNum() > 0)
	-- self.card_tabbar:SetRemindByIndex(2, CardHandlebookData.Instance:GetCardCanDescompose() > 0)
end