-- 活跃度
ActiveDegreeView = ActiveDegreeView or BaseClass(XuiBaseView)

function ActiveDegreeView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/active_degree.png'
	self.texture_path_list[2] = 'res/xui/activity.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"active_degree_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	self.active_type_list = nil
end

function ActiveDegreeView:__delete()
end

function ActiveDegreeView:OpenCallBack()
end

function ActiveDegreeView:CloseCallBack()
	
end

function ActiveDegreeView:ReleaseCallBack()
	if self.active_type_list then
		self.active_type_list:DeleteMe()
		self.active_type_list = nil 
	end

	if self.delay_flush_time ~= nil  then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil
	end

	if self.effec_list then
		for k, v in pairs(self.effec_list) do
			v:removeFromParent()
		end
	end
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)	
	end
end

function ActiveDegreeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateActivityList()
		self:SetShowPlayEff()
		self:SetChestsBtns()
		self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
		RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	end
end

function ActiveDegreeView:OpenCallBack()
	ActiveDegreeCtrl.Instance:ActivenessActivityReq(0)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	-- RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
end

function ActiveDegreeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActiveDegreeView:CreateActivityList()
	if self.active_type_list == nil then
		local ph = self.ph_list.ph_active_type_list
		self.active_type_list = ListView.New()
		self.active_type_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActiveDegreeActivityRender, nil, nil, self.ph_list.ph_active_item)
		self.active_type_list:GetView():setAnchorPoint(0, 0)
		self.active_type_list:SetItemsInterval(5)
		-- self.active_type_list:SetIsUseStepCalc(false)
		self.active_type_list:SetMargin(3)
		self.active_type_list:SetJumpDirection(ListView.Top)
		--self.active_type_list:SetSelectCallBack(BindTool.Bind(self.SelectCallback, self))  --按钮回调
		self.node_t_list.layout_active.node:addChild(self.active_type_list:GetView(), 100)
	end

end

function ActiveDegreeView:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL then
		self:FlushActiveTypeList()
	end
end

function ActiveDegreeView:ShowIndexCallBack(index)
	self:Flush()
end

function ActiveDegreeView:OnFlush(param_t, index)
	self:FlushActiveTypeList()
	local activedegreeCnt = ActiveDegreeData.Instance:GetDailyCound()	
	self.node_t_list.txt_degree_count.node:setString(activedegreeCnt .."/" ..LivenessActivityCfg.dailyActivityTotalNum)
	self.node_t_list.prog9_reward.node:setPercent(activedegreeCnt/LivenessActivityCfg.dailyActivityTotalNum*100)

	local stage_t = ActiveDegreeData.Instance:GetDailyData()
	for i, v in ipairs(stage_t) do
		local path =(v.state_get == 2 and ResPath.GetActiveDegree("chest_get_"..i) or ResPath.GetActiveDegree("chest_"..i))
		self.node_t_list["btn_chest_"..i].node:loadTextures(path)
		if v.state_get == 1 then
			self.effec_list[i]:setVisible(true)
		else
			self.effec_list[i]:setVisible(false)
		end
	end
end

function ActiveDegreeView:SetChestsBtns()
	for i = 1, 4 do
		local chest = self.node_t_list["btn_chest_" .. i].node
		chest:setLocalZOrder(998)
		chest:setTouchEnabled(true)
		chest:setIsHittedScale(false)
		chest:addTouchEventListener(BindTool.Bind(self.OnTouchLayout, self, i))
	end
end

function ActiveDegreeView:SetShowPlayEff()
	self.effec_list = {}
	for i = 1, 4 do
		local play_eff = AnimateSprite:create()
		local pos_x, pos_y = self.node_t_list["btn_chest_" .. i].node:getPosition()
		play_eff:setPosition(pos_x+5, pos_y + 15)
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(29)
		play_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		play_eff:setVisible(false)
		self.root_node:addChild(play_eff, 999)
		self.effec_list[i] = play_eff
	end
end

function ActiveDegreeView:OnTouchLayout(btn_type, sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		self.is_long_click = false
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end
		self.delay_flush_time = GlobalTimerQuest:AddDelayTimer(function ()
			self.is_long_click = true
			ActiveDegreeCtrl.Instance:OpenShowRewardView(btn_type)
		end,0.2)
	elseif event_type == XuiTouchEventType.Moved then
	elseif event_type == XuiTouchEventType.Ended then
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end
		if self.is_long_click then
			ActiveDegreeCtrl.Instance:CloseTip()
		else
			ActiveDegreeCtrl.Instance:ActivenessActivityReq(btn_type)
		end	
	else	
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end

		if self.is_long_click then
			ActiveDegreeCtrl.Instance:CloseTip()
		end	
	end	
end


function ActiveDegreeView:SelectCallback(item, index)
	if not item or not item:GetData() then return end
	local data = item:GetData()
	if ActivityData.IsSwitchToOtherView(data.teleId) then
		local tele_cfg = ActivityData.GetCommonTeleCfg(data.teleId)
		ActivityCtrl.Instance:OpenOneActView(tele_cfg)
	else
		Scene.Instance:CommonSwitchTransmitSceneReq(data.teleId)
	end
	self:Close()
end

function ActiveDegreeView:FlushActiveTypeList()
	local data = ActiveDegreeData.GetAddActiveDegreeCountList()
	local filter_list = TableCopy(data)

	local function sort_list()	
		return function(c, d)
			local bool_finish =  AchieveData.Instance:GetAwardState(c.achieveId) and AchieveData.Instance:GetAwardState(c.achieveId).finish
			local bool_finish_1 = AchieveData.Instance:GetAwardState(d.achieveId) and AchieveData.Instance:GetAwardState(d.achieveId).finish
			if bool_finish ~= bool_finish_1 then
				return bool_finish < bool_finish_1
			elseif bool_finish == 0 then
				if c.is_lev ~= d.is_lev then
					return c.is_lev  > d.is_lev
				else
					return c.is_lev < d.is_lev
				end
			end
		end
	end
	table.sort(filter_list, sort_list()) 
	
	self.active_type_list:SetDataList(filter_list)
end

------------------------------------------
-- ActiveDegreeActivityRender
------------------------------------------
ActiveDegreeActivityRender = ActiveDegreeActivityRender or BaseClass(BaseRender)
function ActiveDegreeActivityRender:__init()
	
end

function ActiveDegreeActivityRender:__delete()
	
end

function ActiveDegreeActivityRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_quick_links
	self.text_node = RichTextUtil.CreateLinkText("", 20, COLOR3B.WHITE, nil, true)
	self.text_node:setPosition(ph.x, ph.y)
	self.text_node:setString(Language.ActiveDegree.ActivityQuickLinks)
	self.text_node:setColor(COLOR3B.GREEN)
	self.view:addChild(self.text_node, 999)
	XUI.AddClickEventListener(self.text_node, BindTool.Bind1(self.QuickLinks, self), true)
end

function ActiveDegreeActivityRender:OnFlush()
	if not self.data then return end
	local color = COLOR3B.GRAY
	if self.data.is_open_today == 1 then
		if self.data.is_open == 1 then
			color = COLOR3B.BRIGHT_GREEN
		else
			color = COLOR3B.RED
		end
		if self.data.is_over == 1 then
			color = COLOR3B.GRAY
		end
	end

	local achieve_cfg = ExploitData.Instance:GetOneAchieveCfgByAchiID(self.data.achieveId)
	self.node_tree.txt_name.node:setString(self.data.name)
	self.node_tree.txt_active_degree.node:setString("+" .. achieve_cfg.awards[1].count)
	-- print(achieve_cfg.awards[1].count)
	local finish_cond = achieve_cfg.conds[1].count
	self.is_finish = AchieveData.Instance:GetAwardState(self.data.achieveId) and AchieveData.Instance:GetAwardState(self.data.achieveId).finish == 1 and true or false
	local prog = nil 
	if self.data.achieveId == 317 then
		self.text_node:setVisible(false)
	end
	if self.data.is_lev == 1 then
		self.node_tree.img_notlev.node:setVisible(false)
		self.node_tree.txt_state.node:setVisible(true)
		self.node_tree.txt_name.node:setColor(COLOR3B.BRIGHT_GREEN)
		if self.is_finish then 
			prog = finish_cond .. "/" .. finish_cond
			self.node_tree.txt_state.node:setString(Language.ActiveDegree.ActivityStateText[1])
			self.node_tree.txt_cond.node:setColor(color)
			self.node_tree.txt_cnt.node:setColor(color)
			self.node_tree.txt_name.node:setColor(color)
			self.node_tree.img_bg_1.node:setGrey(self.data.is_open_today ~= 1 or self.data.is_over == 1)
		else
			prog = AchieveData.Instance:GetAchieveFinishCount(achieve_cfg.conds[1].eventId).count .. "/" .. finish_cond
			self.node_tree.txt_state.node:setString(Language.ActiveDegree.ActivityStateText[2])

		end
		self.node_tree.txt_cnt.node:setString(prog)
		self.node_tree.txt_cond.node:setString(self.data.describe)
	else
		if not self.is_finish then 
			prog = AchieveData.Instance:GetAchieveFinishCount(achieve_cfg.conds[1].eventId).count .. "/" .. finish_cond
		end
		self.node_tree.img_notlev.node:setVisible(true)
		self.node_tree.txt_state.node:setVisible(false)
		self.node_tree.txt_name.node:setColor(COLOR3B.RED) 
			
		self.node_tree.txt_cnt.node:setString(prog)
		self.node_tree.txt_cond.node:setString(self.data.describe)
	end

	
end

function ActiveDegreeActivityRender:QuickLinks()
	if self.data == nil or self.is_finish == true then return end
	if ActivityData.IsSwitchToOtherView(self.data.teleId) then
		local tele_cfg = ActivityData.GetCommonTeleCfg(self.data.teleId)
		ActivityCtrl.Instance:OpenOneActView(tele_cfg)
	else
		Scene.Instance:CommonSwitchTransmitSceneReq(self.data.teleId)
	end
	ViewManager.Instance:Close(ViewName.ActiveDegree)
end

