NewlyBossView = NewlyBossView or BaseClass(BaseView)

function NewlyBossView:__init()
	self.title_img_path = ResPath.GetWord("word_boss")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/boss.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"new_boss_ui_cfg", 13, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}
	
	self.btn_info = {ViewDef.NewlyBossView.Wild, ViewDef.NewlyBossView.Rare, ViewDef.NewlyBossView.Drop}

	require("scripts/game/newly_boss/wild_boss/nwild_boss_view").New(ViewDef.NewlyBossView.Wild, self)
	require("scripts/game/newly_boss/nrare_boss/nrare_boss_view").New(ViewDef.NewlyBossView.Rare, self)
	require("scripts/game/newly_boss/drop/drop_view").New(ViewDef.NewlyBossView.Drop, self)
end

function NewlyBossView:ReleaseCallBack()
	self.newly_tabbar:DeleteMe()

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	GlobalEventSystem:UnBind(self.scene_change)
	self.scene_change = nil
end

function NewlyBossView:LoadCallBack(index, loaded_times)
	self.tabbar_index = 1
	FubenCtrl.GetFubenEnterInfo()
	NewBossCtrl.Instance:SendBossKillInfoReq()
	self:InitTabbar()

	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, function ()
		ViewManager.Instance:CloseViewByDef(ViewDef.NewlyBossView)
	end)

	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.TUMO_ADD_TIME, BindTool.Bind(self.Flush, self))
end

--标签栏初始化
function NewlyBossView:InitTabbar()
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.newly_tabbar = Tabbar.New()
	self.newly_tabbar:SetTabbtnTxtOffset(2, 12)
	self.newly_tabbar:SetClickItemValidFunc(function(index)
		self.tabbar_index = index
		return ViewManager.Instance:CanOpen(self.btn_info[index]) 
	end)
	self.newly_tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
		name_list, true, ResPath.GetCommon("toggle_110"), 25, true)
end

--选择标签回调
function NewlyBossView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	--刷新标签栏显示
	for k, v in pairs(self.btn_info) do
		if v.open then
			self.newly_tabbar:ChangeToIndex(k)
			break
		end
	end
end

function NewlyBossView:ShowIndexCallBack(index)
	for k, v in pairs(self.btn_info) do
		if v.open then
			self.newly_tabbar:ChangeToIndex(k)
			break
		end
	end
	self:Flush()
end

function NewlyBossView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function NewlyBossView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function NewlyBossView:OnFlush(param_t, index)
	self.node_t_list.layout_add_time.node:setVisible(self.tabbar_index ~= 3)

	local n = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN)
	self.node_t_list.lbl_num.node:setString(n .. "/" .. GlobalConfig.nInitDevilToken)

	local time = NewlyBossData.Instance:GetAddTime()
	local left_time = time - os.time()
	if left_time > 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end

		local callback = function()
			
			local left_time = time - os.time()
			if left_time > 0 then
				self.node_t_list["lbl_addtime"].node:setString("(" .. TimeUtil.FormatSecond(left_time, 3) .. "+1)")
			else
				if self.timer then
					GlobalTimerQuest:CancelQuest(self.timer)
					self.timer = nil
				end
			end
		end
		callback()
		self.timer = GlobalTimerQuest:AddTimesTimer(callback, 1, left_time)
	else
		self.node_t_list.lbl_addtime.node:setString("")
	end
end