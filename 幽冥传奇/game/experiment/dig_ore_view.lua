local DigOreView = DigOreView or BaseClass(SubView)

function DigOreView:__init()
	self.def_index = 1
	self.texture_path_list = {'res/xui/experiment.png'}
	self.config_tab = {
		{"experiment_ui_cfg", 1, {0}},
	}

	-- 管理自定义对象
	self._objs = {}

	self.def_index = 1

	self.old_quality = 0	--品质
	self.act_list = {}		--动画列表
end

function DigOreView:__delete()
end

function DigOreView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then	
	end
	EventProxy.New(ExperimentData.Instance, self):AddEventListener(ExperimentData.INFO_CHANGE, BindTool.Bind(self.ExperimentDataChangeCallback, self))

	XUI.AddClickEventListener(self.node_t_list.btn_dig.node, function ()
		-- Scene.SendTransmitSceneReq(290, 42, 54)
		ExperimentCtrl.SendExperimentOptReq(1)
		ViewManager.Instance:CloseViewByDef(ViewDef.Experiment)
	end)

	--更新品质
	self.old_quality = ExperimentData.Instance:GetBaseInfo().quality

	--创建人物动画
	local res_cfg = MiningActConfig.ClientResCfg[self.old_quality]

	local anim_path2, anim_name2 = ResPath.GetRoleAnimPath(res_cfg.res_id, "atk1", GameMath.DirLeft)
	local ph2 = self.ph_list.ph_action
	local role_animate = RenderUnit.CreateAnimSprite(anim_path2, anim_name2, nil, nil)
	role_animate:setScale(1.1)
	role_animate:setPosition(ph2.x, ph2.y)
	self.node_t_list.layout_dig_ore.node:addChild(role_animate, 999)
	self.act_list.role = role_animate

	local anim_path, anim_name = ResPath.GetRoleAnimPath(res_cfg.wuqi_res_id, "atk1", GameMath.DirLeft)
	local ph2 = self.ph_list.ph_action
	local wuqi_animate = RenderUnit.CreateAnimSprite(anim_path, anim_name, nil, nil)
	wuqi_animate:setScale(1.1)
	wuqi_animate:setPosition(ph2.x, ph2.y)
	self.node_t_list.layout_dig_ore.node:addChild(wuqi_animate, 998)
	self.act_list.wuqi = wuqi_animate


	XUI.AddClickEventListener(self.node_t_list.layout_dig_ore.btn_help.node, function ()
		DescTip.Instance:SetContent(Language.DescTip.DigContent, Language.DescTip.DigTitle)
	end)

	self:ReatPlayItemFly()
end

function DigOreView:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack ExperimentView") end
		v:DeleteMe()
	end
	self._objs = {}

	self.act_list = {}

	self:DeleteOnlineTimer()
	self:DeleteResumeTimer()

	self.fly_items = nil
end

function DigOreView:FlushCountTxt()
	local data = ExperimentData.Instance:GetBaseInfo()
	local max_time1 = MiningActConfig.initTimes
	local max_time2 = MiningActConfig.torob.daytimes
	self.node_t_list.lbl_dig_num.node:setString((max_time1 - data.dig_num) .. "/" .. max_time1)
	self.node_t_list.lbl_rob_num.node:setString((max_time2 - data.plunder_num) .. "/" .. max_time2)
end

function DigOreView:UpdateTime()
	-- 在线时间
	local info = ExperimentData.Instance:GetBaseInfo()
	local time = info.end_dig_time - TimeCtrl.Instance:GetServerTime()
	if time < 0 then
		self:DeleteOnlineTimer()
	end
	self.node_t_list.layout_dig_ore.lbl_dig_time.node:setString("挖矿中（" .. TimeUtil.FormatSecond(time) .. "）")
	-- self.node_t_list.layout_dig_ore.lbl_dig_time.node:setColor(COLOR3B.GREEN)
end

function DigOreView:ReatPlayItemFly(parent)
	if self.fly_items then return end
	self.fly_items = {}
	local ph = cc.p(self.ph_list.ph_action.x - 100, self.ph_list.ph_action.y)
	local fly_act = function (item, idx)
		local p2 = cc.p(ph.x - idx * 20 - 20, ph.y + 30)
		local p3 = cc.p(ph.x - idx * 40 + 50, ph.y + idx * 10 - 60)
		local bezier_to = cc.BezierTo:create(0.4, {cc.p(ph.x, ph.y), p2, p3})
		local sequence = cc.Sequence:create(cc.FadeTo:create(0.1, 255), bezier_to, cc.FadeTo:create(0.4, 125), cc.CallFunc:create(function ()
			item:setOpacity(0)
			item:setPosition(ph.x, ph.y)
		end), cc.FadeTo:create(0.1, 0))
		item:runAction(cc.RepeatForever:create(sequence))
	end

	for i,v in ipairs(MiningActConfig.Miner[#MiningActConfig.Miner].Awards) do
		local item = XUI.CreateImageView(ph.x, ph.y, ResPath.GetItem(ItemData.Instance:GetItemConfig(v.id).icon), false)
		item:setScale(0.6)
		self.node_t_list.layout_dig_ore.node:addChild(item, 998)
		table.insert(self.fly_items, item)
	end

	local idx = 1
	for k,v in pairs(self.fly_items) do
		fly_act(v, idx)
		idx = idx + 1
	end
end

function DigOreView:FlushTimer()
	local info = ExperimentData.Instance:GetBaseInfo()
	local time = info.end_dig_time - TimeCtrl.Instance:GetServerTime()

	if nil == self.online_timer and time > 0 then
		self.online_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateTime, self), 1)
		self:UpdateTime()
	end
end

function DigOreView:DeleteOnlineTimer()
	if self.online_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.online_timer)
		self.online_timer = nil
	end
end

function DigOreView:ResumeTimerFunc()
	local time2 = ExperimentData.Instance:GetBaseInfo().resum_dig_num_time + COMMON_CONSTS.SERVER_TIME_OFFSET - TimeCtrl.Instance:GetServerTime()
	if time2 <= 0 then
		self.node_t_list.layout_dig_ore.lbl_spare_time_tip.node:setString("2小时恢复一次")
		self:DeleteResumeTimer()
	else
		self.node_t_list.layout_dig_ore.lbl_spare_time_tip.node:setString("恢复倒计时：" .. TimeUtil.FormatSecond(time2))
	end
end

function DigOreView:FlushResumeTimer()
	if nil == self.resume_timer and ExperimentData.Instance:IsResuming() then
		self.resume_timer = GlobalTimerQuest:AddRunQuest(function ()
			self:ResumeTimerFunc()
		end, 1)
		self:ResumeTimerFunc()
	end
end

function DigOreView:DeleteResumeTimer()
	if self.resume_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.resume_timer)
		self.resume_timer = nil
	end
end

function DigOreView:ExperimentDataChangeCallback()
	local data = ExperimentData.Instance:GetBaseInfo()
	if data.quality ~= self.old_quality then
		local res_cfg = MiningActConfig.ClientResCfg[data.quality]
		local anim_path, anim_name = ResPath.GetRoleAnimPath(res_cfg.res_id, "atk1", GameMath.DirLeft)
		local anim_path2, anim_name2 = ResPath.GetRoleAnimPath(res_cfg.wuqi_res_id, "atk1", GameMath.DirLeft)
		self.act_list.role:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.act_list.wuqi:setAnimate(anim_path2, anim_name2, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.old_quality = data.quality
	end

	self:FlushCountTxt()

	-- 倒计时
	self:FlushTimer()
end

function DigOreView:OpenCallBack()
end

function DigOreView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DigOreView:ShowIndexCallBack(index)
	self:Flush(index)

	self:FlushCountTxt()

	self.node_t_list.lbl_dig_time.node:setVisible(ExperimentData.Instance:IsDiging())
	-- self.node_t_list.btn_dig.node:setVisible(not ExperimentData.Instance:IsDiging())

	-- 倒计时
	self:FlushTimer()
	self:FlushResumeTimer()
end

function DigOreView:OnFlush(param_list, index)
	for k, v in pairs(param_list) do
	end
end

return DigOreView