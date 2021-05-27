RedEnvelopesView = RedEnvelopesView or BaseClass(XuiBaseView)

function RedEnvelopesView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/redenvelopes.png'
	self.config_tab = {
		{"redenvelopes_ui_cfg", 1, {0}},
		{"redenvelopes_ui_cfg", 2, {0}}
	}
end

function RedEnvelopesView:__delete()
	
end

function RedEnvelopesView:ReleaseCallBack()
	if nil~=self.grid_hongbao_scroll_list then
		self.grid_hongbao_scroll_list:DeleteMe()
	end
	self.grid_hongbao_scroll_list = nil
end


function RedEnvelopesView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateHongBaoGridScroll()
	end
end

function RedEnvelopesView:ShowIndexCallBack(index)
	RedEnvelopesCtrl.Instance:RedEnvelopesReq(1, 1)
	self:Flush(index)
end

function RedEnvelopesView:OnFlush(param_list, index)
	for k, v in pairs(param_list) do
		if "all" == k then
			self.grid_hongbao_scroll_list:SetDataList(RedEnvelopesData.Instance:GetRedEnvelopesItemList())
			self.grid_hongbao_scroll_list:JumpToTop(true)
		elseif "showAnim" == k then
			self:ShowPickUpAnim(param_list.showAnim.index)
		end	
	end
end

function RedEnvelopesView:CreateHongBaoGridScroll()
	if nil == self.node_t_list.layout_hongbao_list then
		return
	end
	if nil == self.grid_hongbao_scroll_list then
		local ph = self.ph_list.ph_hongbao_view_list
		self.grid_hongbao_scroll_list = ListView.New()
		self.grid_hongbao_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, nil, RedEnvelopesItemRender, nil, true, self.ph_list.ph_hongbao_list)
		self.grid_hongbao_scroll_list:SetMargin(2)
		self.node_t_list.layout_hongbao_list.node:addChild(self.grid_hongbao_scroll_list:GetView(), 100)
	end
end

function RedEnvelopesView:ShowPickUpAnim(index)
	if nil == index then return end
		local act_render = self.grid_hongbao_scroll_list:GetItemAt(index)
		if nil == act_render then 
			return 
		end
		local old_x= act_render:GetView():getPositionX()
		local action_time = 0.5
		local move_action = cc.MoveBy:create(action_time, cc.p(650, 0))
		local fadeout_action = cc.FadeOut:create(action_time)
		local spawn_action = cc.Spawn:create(move_action, fadeout_action)
		local callback = cc.CallFunc:create(function()
				act_render:GetView():setPositionX(old_x)
				act_render:GetView():setOpacity(255)
				self.grid_hongbao_scroll_list:SetDataList(RedEnvelopesData.Instance:GetRedEnvelopesItemList())
				self.grid_hongbao_scroll_list:JumpToTop(true)
				self.grid_hongbao_scroll_list:GetView():refreshView()
				RedEnvelopesData.Instance:SetActIndex(-1)
			end)
		local action = cc.Sequence:create(spawn_action, callback)
		act_render:GetView():runAction(action)
end
--------------------------
-----天降红包
--------------------------
RedEnvelopesItemRender = RedEnvelopesItemRender or BaseClass(BaseRender)
function RedEnvelopesItemRender:__init()

end

function RedEnvelopesItemRender:__delete()
	if nil ~= self.cell_hongbao_list then
		for k,v in pairs(self.cell_hongbao_list) do
			v:DeleteMe()
    		v = nil
		end
    end
	self.cell_hongbao_list = {}

	if nil ~= self.level_num then
		self.level_num:DeleteMe()
		self.level_num = nil
	end

	if nil ~= self.buy_alert then 
		self.buy_alert:DeleteMe()
		self.buy_alert = nil
	end
end

function RedEnvelopesItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_hongbao_list = {}
	for i = 1, 6 do 
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_hongbao_award_"..i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(cell:GetView(), 300)
		table.insert(self.cell_hongbao_list, cell)
		local cell_effect = AnimateSprite:create()
		cell_effect:setPosition(ph.w / 2 - 5, ph.h / 2 - 2)
		cell:GetView():addChild(cell_effect, 300)
		cell_effect:setVisible(false)
		cell.cell_effect = cell_effect
	end
	XUI.AddClickEventListener(self.node_tree.btn_hongbao_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
	self:CreateNumberBar()
end

function RedEnvelopesItemRender:CreateNumberBar()
	local ph = self.ph_list.ph_level_num
	self.level_num = NumberBar.New()
	self.level_num:SetRootPath(ResPath.GetCommon("num_118_"))
	self.level_num:SetPosition(ph.x, ph.y - 2)
	self.level_num:SetGravity(NumberBarGravity.Center)
	self.level_num:GetView():setScale(0.8)
	self.view:addChild(self.level_num:GetView(), 300, 300)
end

function RedEnvelopesItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	RedEnvelopesData.Instance:SetActIndex(self.index)
	local btntext = self.node_tree.btn_hongbao_lingqu.node:getTitleText()
	if btntext == Language.RedEnvelopes.QuickUpgrade then                                              --等级未达到弹出经验获取面板
		self.OpenExp()
	elseif self.data.index < RedEnvelopesData.Instance:GetConsumLevel(ViewName.RedEnvelopes) then       --直接领取
		RedEnvelopesCtrl.Instance:RedEnvelopesReq(1, 2, self.data.index)
	else                                                                                                --消耗元宝
		if nil == self.data.consume then return end
		self.buy_alert = self.buy_alert or Alert.New()
		self.buy_alert:SetShowCheckBox(false)
		local des = string.format(Language.RedEnvelopes.BuyAlert, self.data.consume, self.data.consume)
		self.buy_alert:SetLableString(des)
		self.buy_alert:SetOkString(Language.RedEnvelopes.BuyAlertPick)
		self.buy_alert:SetCancelString(Language.RedEnvelopes.BuyAlertRecharge)
		self.buy_alert:SetOkFunc(function()
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) < self.data.consume then
				SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.NoEnoughGold)
			end
			RedEnvelopesCtrl.Instance:RedEnvelopesReq(1, 2, self.data.index) 
		end)
		self.buy_alert:SetCancelFunc(function()
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
		end)
		self.buy_alert:Open()
	end
end

function RedEnvelopesItemRender:OnFlush()
	if nil == self.data then
		return
	end
	for k,v in pairs(self.cell_hongbao_list) do
		local item_data = {}
		if nil ~= self.data[k] then
			item_data.item_id = self.data[k].id
			item_data.num = self.data[k].count
			item_data.is_bind = self.data[k].bind
			item_data.effectId = self.data[k].effectId
			v:SetData(item_data)
			if item_data.effectId ~= nil then
				local path, name = ResPath.GetEffectUiAnimPath(item_data.effectId)
				if path and name then
					v.cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.23, false)
					v.cell_effect:setVisible(true)
				end
			end
		else
			v:SetData(nil)
		end
		v:SetVisible(self.data[k] ~= nil)
	end
	
	local level = self.data.level
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	self.level_num:SetNumber(level)
	if nil == self.data.sign then return end
	local is_lingqu = self.data.sign > 0
	local can_lingqu = level - role_level
	local show_btn = self.data.show_btn
	local path = is_lingqu and ResPath.GetCommon("stamp_1") or ResPath.GetEnvelopes("word_stamp")
	local text = can_lingqu > 0 and Language.RedEnvelopes.QuickUpgrade or Language.RedEnvelopes.BuyAlertPick
	self.node_tree.img_hongbao_reward_state.node:loadTexture(path)
	self.node_tree.img_hongbao_reward_state.node:setVisible(not show_btn or is_lingqu)
	self.node_tree.btn_hongbao_lingqu.node:setTitleText(text)
	self.node_tree.btn_hongbao_lingqu.node:setVisible(show_btn and not is_lingqu)
	self.node_tree.lv1.node:setVisible((show_btn and not is_lingqu) and can_lingqu > 0)
	self.node_tree.lv2.node:setVisible((show_btn and not is_lingqu) and can_lingqu > 0)
	self.node_tree.lv2.node:setString(can_lingqu)
end

function RedEnvelopesItemRender:OpenExp()
	local role_guild_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
	local data = {
		{stuff_way = Language.Task.TaskHelp[1], open_view = ViewName.RefiningExp},                                                    --经验炼制
		{stuff_way = Language.Task.TaskHelp[2], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(83), task_id = 4000},      --降妖除魔
		{stuff_way = Language.Task.TaskHelp[3], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(79), task_id = 4001},      --封魔塔防
		{stuff_way = Language.Task.TaskHelp[4], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(90)},                      --休闲挂机
		{stuff_way = Language.Task.TaskHelp[7], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(81), task_id = 4002},      --押镖
		{stuff_way = Language.Task.TaskHelp[8], open_view = ViewName.Guild},                                                          --行会禁地
		{stuff_way = Language.Task.TaskHelp[9], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(179), task_id = 4010},      --多人副本
		-- {stuff_way = Language.Task.TaskHelp[5], open_view =  ViewName.ChargeFirst},                                                   --首冲大礼包
		{stuff_way = Language.Task.TaskHelp[6], open_view =  ViewName.Explore},  
	}
	local task_help_list = {}
	for i,v in ipairs(data) do
		if v.open_view then
			if ViewManager.Instance:CanShowUi(v.open_view) then
				if v.open_view == ViewName.Guild then
					if role_guild_id > 0 then 
						task_help_list[#task_help_list + 1] = v
					end
				elseif v.remind == nil or RemindManager.Instance:GetRemind(v.remind) > 0 then
					task_help_list[#task_help_list + 1] = v
				end
			end
		elseif v.task_id then
			if TaskData.Instance:GetTaskInfo(v.task_id) then
				local count_t = TaskData.Instance:GetTaskDoCount(v.task_id)
				if count_t == nil or (type(count_t) == "table" and count_t.now_count and count_t.max_count and count_t.now_count < count_t.max_count) then
					task_help_list[#task_help_list + 1] = v
				end
			end
		else
			task_help_list[#task_help_list + 1] = v
		end
	end
	TipCtrl.Instance:OpenStuffTip(Language.Task.TaskHelpTitle, task_help_list)
end