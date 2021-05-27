RefiningExpView = RefiningExpView or BaseClass(BaseView)

function RefiningExpView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetRefiningExp("img_exp_1")
	self.texture_path_list[1] = 'res/xui/refiningexp.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"refiningexp_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.arrow_eff = nil -- 箭头特效
	self.box_eff = nil -- 宝箱特效

end

function RefiningExpView:__delete()
end

function RefiningExpView:ReleaseCallBack()
	if self.flush_timer_quest then
		GlobalTimerQuest:CancelQuest(self.flush_timer_quest)
		self.flush_timer_quest = nil
	end

	if self.exp_num then
		self.exp_num:DeleteMe()
		self.exp_num = nil
	end

	if self.level_num then
		self.level_num:DeleteMe()
		self.level_num = nil
	end

	-- if nil ~= self.cell then
	-- 	self.cell:DeleteMe()
	-- 	self.cell = nil
	-- end

	self.refining_exp_view_is_no_delete = nil
	self.refining_exp_view_is_open = nil
	self.arrow_eff = nil -- 箭头特效
	self.box_eff = nil -- 宝箱特效
end

function RefiningExpView:LoadCallBack(index, loaded_times)
	if not self.refining_exp_view_is_no_delete then
		self.refining_exp_view_is_no_delete = true
		RefiningExpCtrl.Instance:SendRefiningExpReq(1)
	end
	
	self:CreateCountDown() 	-- 创建倒计时
	self:CreateNumberBar() 	-- 创建数字栏
	self:CreateEffectView() -- 创建特效

	XUI.AddClickEventListener(self.node_t_list.layout_btn.node, BindTool.Bind(self.OnClickGetExpHandler, self), true)
	self.node_t_list.lbl_time.node:setColor(COLOR3B.GREEN)
	XUI.EnableOutline(self.node_t_list.lbl_time.node)

	EventProxy.New(RefiningExpData.Instance, self):AddEventListener(RefiningExpData.REFINING_EXP_MSG_CHANGE, BindTool.Bind(self.Flush, self))
end

-- 创建特效
function RefiningExpView:CreateEffectView()
	-- 箭头特效
	if not self.arrow_eff then
		local path, name = ResPath.GetEffectUiAnimPath(1147)
		self.arrow_eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, 0.12, false)
		self.arrow_eff:setPosition(257.5, 389)
		self.node_t_list.layout_common.node:addChild(self.arrow_eff, 20)
		self.arrow_eff:setVisible(true)
	end

	-- 奖励物品创建
	-- if nil == self.cell then
	-- 	self.cell = BaseCell.New()
	-- 	self.cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	-- 	self.cell:SetIndex(i)
	-- 	self.cell:SetAnchorPoint(0.5, 0.5)
	-- 	self.view:addChild(self.cell:GetView(), 1)
	-- end	

	-- 宝箱特效
	-- if not self.box_eff then
	-- 	path, name = ResPath.GetEffectUiAnimPath(1148)
	-- 	eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, 0.12, false)
	-- 	eff:setPosition(700, 450)
	-- 	self.node_t_list.layout_common.node:addChild(eff, 20)
	-- 	eff:setVisible(true)
	-- end

	-- RenderUnit.CreateEffect(1147, self.node_t_list.layout_common.node, 10, nil, nil, 392.5, 540)
	-- RenderUnit.CreateEffect(1148, self.node_t_list.layout_common.node, 10, nil, nil, 860, 450)
end

function RefiningExpView:CreateNumberBar()
	-- 经验值
	self.exp_num = NumberBar.New()
	self.exp_num:SetRootPath(ResPath.GetRefiningExp("num_exp_"))
	self.exp_num:SetPosition(410, 202)
	self.exp_num:SetGravity(NumberBarGravity.Left)
	self.node_t_list.layout_common.node:addChild(self.exp_num:GetView(), 300, 300)

	-- 等级
	self.level_num = NumberBar.New()
	self.level_num:SetRootPath(ResPath.GetRefiningExp("num_exp_"))
	self.level_num:SetPosition(430, 151)
	self.level_num:SetGravity(NumberBarGravity.Center)
	self.node_t_list.layout_common.node:addChild(self.level_num:GetView(), 301, 301)
	
end

-- 倒计时
function RefiningExpView:CreateCountDown()
	if not self.refining_exp_view_is_open then
		self.refining_exp_view_is_open = true

		if nil == self.flush_timer_quest then
			self.flush_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnFlushRemainTime, self),1)
		end
	end
end

---- 按钮 ----
function RefiningExpView:OnClickGetExpHandler()
	local data = RefiningExpData.Instance:GetCfgData()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
    local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
    local max_level = GlobalConfig.maxLevel[circle+1]
    local addExp = data.addExp and 0 or data.upLevel

	if RefiningExpData.Instance:GetNowCount() <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.RefiningExp.NoCount)
	else
	    if level + addExp >= max_level then
			ViewManager.Instance:OpenViewByDef(ViewDef.RefiningTip)
	    else
	    	RefiningExpCtrl.Instance:SendRefiningExpReq(2)
	    end
	end

end

function RefiningExpView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:CreateCountDown()
end

function RefiningExpView:ShowIndexCallBack(index)
	self:Flush(index)
end

function RefiningExpView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if nil ~= self.flush_timer_quest then
		GlobalTimerQuest:CancelQuest(self.flush_timer_quest)
		self.flush_timer_quest = nil
	end
	self.refining_exp_view_is_open = nil
end

function RefiningExpView:OnFlush(param_t, index)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local data = RefiningExpData.Instance:GetCfgData()
	
	if data == nil then return end

	self.exp_num:SetNumber(data.addExp and 0 or data.upLevel)
	self.level_num:SetNumber(level + (data.upLevel or 0))
	RefiningExpData.Instance:GetCanToLevel()
	-- self.cell:SetData({type = data.award.type, item_id = data.award.id, is_bind = data.award.bind, num = data.award.count})

	local yuanbao = data.consume and data.consume.count or 0
	self.node_t_list.lbl_1.node:setString(yuanbao .. Language.Common.Diamond)

	self.node_t_list.txt_remain.node:setString(RefiningExpData.Instance:GetNowCount() .. "/" .. RefiningExpData.Instance:GetMaxCountDay())

	self:OnFlushRemainTime()
end

-- 刷新活动剩余时间
function RefiningExpView:OnFlushRemainTime()
	if nil == self.node_t_list.lbl_time then return end
	local time_s = RefiningExpData.Instance:GetRefiningExpRemainTime()
	if time_s <= 0 then
		self.node_t_list.lbl_time.node:setString(Language.RefiningExp.ActEnd)

		if nil ~= self.flush_timer_quest then
			GlobalTimerQuest:CancelQuest(self.flush_timer_quest)
			self.flush_timer_quest = nil
		end
		return
	end

	local time_t = TimeUtil.Format2TableDHMS(time_s)
	local time_str = time_t.day .. Language.Common.TimeList.d .. time_t.hour .. Language.Common.TimeList.h
		 .. time_t.min .. Language.Common.TimeList.min .. time_t.s .. Language.Common.TimeList.s
	self.node_t_list.lbl_time.node:setString(time_str)
end
