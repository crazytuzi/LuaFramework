CombinedServerActView = CombinedServerActView or BaseClass(BaseView)
local DZP_COUNT = 8
function CombinedServerActView:LoadTurntableView()
	local ph = self.ph_list.ph_dzp_point
	self.btn_arrow = XUI.CreateImageView(ph.x, ph.y, ResPath.GetCombind("combind_turntable_point"), true)
	self.node_t_list.layout_turntable.node:addChild(self.btn_arrow, 50)
	self.btn_arrow:setAnchorPoint(0.5, 0)

	self.node_t_list.btn_truntable_start.node:addClickEventListener(BindTool.Bind(self.OnClickTurntableHandler, self))
	self.node_t_list.btn_dzp_rechange.node:addClickEventListener(BindTool.Bind(self.OnClickDzpRechangeHandler, self))
	self:CreateDZPReward()
	self:CreateDZPRewardLog()
	self.node_t_list.rich_dzp_open_limit.node:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
	self.node_t_list.rich_dzp_open_limit.node:setIgnoreSize(true)
	XUI.RichTextSetCenter(self.node_t_list.rich_dzp_stuff_1.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_dzp_stuff_2.node)
	local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_turntable)
	

	XUI.AddClickEventListener(self.node_t_list.layout_act_auto_hook.btn_nohint_checkbox.node, BindTool.Bind(self.OnClickZhuanPanAutoUse, self, 1), true)
	self.node_t_list.layout_act_auto_hook.img_hook.node:setVisible(false)
	XUI.AddClickEventListener(self.node_t_list.layout_act_auto_draw_hook.btn_nohint_checkbox.node, BindTool.Bind(self.OnClickZhuanPanAutoUse, self, 2), true)
	self.node_t_list.layout_act_auto_draw_hook.img_hook.node:setVisible(false)

end

function CombinedServerActView:DeleteTurntableView()
	if self.dzp_log_list then
		self.dzp_log_list:DeleteMe()
		self.dzp_log_list = nil
	end
	for k,v in pairs(self.table_reward_t) do
		v:DeleteMe()
	end
	self.table_reward_t = {}
end

function CombinedServerActView:CreateDZPReward()
	self.table_reward_t = {}
    local ph = self.ph_list.ph_point
	local r = 150
	local x = ph.x
    local y = ph.y
	for i = 1, DZP_COUNT do
		local cell = BaseCell.New()
--		cell:SetPosition(x + r * math.cos(math.rad(360 / DZP_COUNT / 2 * 3 - 360 / DZP_COUNT * (i - 1))), y + r * math.sin(math.rad(67.5 - 360 / DZP_COUNT * (i - 1))))
		cell:SetPosition(x + r * math.sin(math.rad(360 / DZP_COUNT * (i-1))), y + r * math.cos(math.rad(360 / DZP_COUNT * (i - 1))))
   
		cell:SetCellBg()
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_turntable.node:addChild(cell:GetView(), 300)
		table.insert(self.table_reward_t, cell)
	end
	local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_turntable)
	local act_cfg = CombinedServerActData.GetCombinedServActCfg(act_id)
	local sex_key = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) == GameEnum.MALE and "male" or "female"
	local awards_list = act_cfg and act_cfg.luckDraw and act_cfg.luckDraw[sex_key]
	if nil ~= awards_list then
		for i,v in ipairs(self.table_reward_t) do
			local data = awards_list[i].awards
			if data then
				if data.type == tagAwardType.qatEquipment then
					v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = data.bind})
				else
					local virtual_item_id = ItemData.GetVirtualItemId(data.type)
					if virtual_item_id then
						v:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind = 0})
					end
				end
			else
				v:SetData()
			end
		end
	end
end

function CombinedServerActView:CreateDZPRewardLog()
	local ph = self.ph_list.ph_dzp_reward_list
	self.dzp_log_list = ListView.New()
	self.dzp_log_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CombinedDZPLogRender, nil, nil, self.ph_list.ph_dzp_reward_item)
	self.dzp_log_list:GetView():setAnchorPoint(0.5, 0.5)
	self.dzp_log_list:SetJumpDirection(ListView.Top)
	self.dzp_log_list:SetItemsInterval(8)
	self.node_t_list.layout_turntable.node:addChild(self.dzp_log_list:GetView(), 100)
end

function CombinedServerActView:FlushTurntableView(param_t)
	for k,v in pairs(param_t) do
		if k == "result" and not self:GetIsIgnoreAction() then
			self.btn_arrow:stopAllActions()
			local rotate = self.btn_arrow:getRotation() % 360
			local to_rotate =(720 - rotate)+ 360 / DZP_COUNT * (v.result - 1)
			local rotate_by = cc.RotateBy:create(2, to_rotate)
			local callback = cc.CallFunc:create(function ()
				self.node_t_list.btn_truntable_start.node:setEnabled(true)
                self.node_t_list.layout_act_auto_hook.node:setEnabled(true)
                self.node_t_list.layout_act_auto_draw_hook.node:setEnabled(true)
				ItemData.Instance:SetDaley(false)
				CombinedServerActCtrl.SendSendCombinedInfo(CombinedActId.DZP)
			end)
			local sequence = cc.Sequence:create(rotate_by, callback)
			self.btn_arrow:runAction(sequence)
		else
			if self.node_t_list.btn_truntable_start.node:isEnabled() then
				self.dzp_log_list:SetDataList(CombinedServerActData.Instance:GetDZPRewardLog())
			end
			local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_turntable)
			local act_cfg = CombinedServerActData.GetCombinedServActCfg(act_id)
			local act_info = CombinedServerActData.Instance:GetActInfo(act_id)
			if nil == act_cfg or nil == act_info then return end
--			self.node_t_list.rich_dzp_open_limit.node:setVisible(act_info.is_open == 0)
			self.node_t_list.rich_dzp_stuff_1.node:setVisible(act_info.is_open == 1)
			self.node_t_list.rich_dzp_stuff_2.node:setVisible(act_info.is_open == 1)
--			self.node_t_list.btn_truntable.node:setVisible(act_info.is_open == 1)
			local color = act_info.ylq_count < act_cfg.maxYlBook and "ff0000" or "00ff00"
			local content = string.format(Language.CombinedServerAct.TurntableStuff1, color, act_info.ylq_count, act_cfg.maxYlBook, act_info.ylq_gold)
			RichTextUtil.ParseRichText(self.node_t_list.rich_dzp_stuff_1.node, content, 20)
			color = act_info.cqq_count < act_cfg.maxCqBook and "ff0000" or "00ff00"
			local content = string.format(Language.CombinedServerAct.TurntableStuff2, color, act_info.cqq_count, act_cfg.maxCqBook, act_info.cqq_gold)
			RichTextUtil.ParseRichText(self.node_t_list.rich_dzp_stuff_2.node, content, 20)


            local act_cfg = CombinedServerActData.GetCombinedServActCfg(act_id)
	        local open_count = act_cfg and act_cfg.payMaxYb or 5000
            local charge_count = OtherData.Instance:GetDayChargeGoldNum()
            open_count =  open_count - charge_count
	        RichTextUtil.ParseRichText(self.node_t_list.rich_dzp_open_limit.node, string.format(Language.CombinedServerAct.TurntableOpenDec, open_count > 0 and open_count or 0), 20)
		end
	end
end

function CombinedServerActView:OnClickZhuanPanAutoUse(tag)
	if tag == 1 then
		local vis = self.node_t_list.layout_act_auto_hook.img_hook.node:isVisible()
		self.node_t_list.layout_act_auto_hook.img_hook.node:setVisible(not vis)
	else
		local vis_2 = self.node_t_list.layout_act_auto_draw_hook.img_hook.node:isVisible()
		self.node_t_list.layout_act_auto_draw_hook.img_hook.node:setVisible(not vis_2)
	end
end

function CombinedServerActView:OnClickTurntableHandler()
    if BagData.Instance:GetEmptyNum() <= 0 then 
        SysMsgCtrl.Instance:ErrorRemind("背包已满")
        return 
    end
	local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_turntable)
	local act_cfg = CombinedServerActData.GetCombinedServActCfg(act_id)
	local act_info = CombinedServerActData.Instance:GetActInfo(act_id)
	if nil == act_cfg or nil == act_info then
		return
	end

	local can_draw = act_info.is_open and act_info.ylq_count >= act_cfg.maxYlBook and act_info.cqq_count >= act_cfg.maxCqBook
	self:SetAutoDrawTimer(5, can_draw) --每隔5秒抽一次

	if self:GetIsIgnoreAction() then
		CombinedServerActCtrl.SendSendCombinedReq(CombinedActId.DZP)
		CombinedServerActCtrl.SendSendCombinedInfo(CombinedActId.DZP)
		self.btn_arrow:stopAllActions()
		ItemData.Instance:SetDaley(false)
		return
	end --成功则跳过动画

	if act_info.is_open == 0 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombinedServerAct.TurntableLimit[1])
		return
	end
	if act_info.ylq_count < act_cfg.maxYlBook then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombinedServerAct.TurntableLimit[2])
		return
	end
	if act_info.cqq_count < act_cfg.maxCqBook then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombinedServerAct.TurntableLimit[3])
		return
	end
	local rotate_by1 = cc.RotateBy:create(2, 360 * 5)
	local rotate_by2 = cc.RotateBy:create(4, 360 * 10)
	local callback = cc.CallFunc:create(function ()
		ItemData.Instance:SetDaley(true)
		CombinedServerActCtrl.SendSendCombinedReq(CombinedActId.DZP)
	end)
	local callback2 = cc.CallFunc:create(function ()
		self.node_t_list.btn_truntable_start.node:setEnabled(true)
        self.node_t_list.layout_act_auto_hook.node:setEnabled(true)
        self.node_t_list.layout_act_auto_draw_hook.node:setEnabled(true)
	end)
	local sequence = cc.Sequence:create(rotate_by1, callback, rotate_by2, callback2)
	self.node_t_list.btn_truntable_start.node:setEnabled(false)
    self.node_t_list.layout_act_auto_hook.node:setEnabled(false)
    self.node_t_list.layout_act_auto_draw_hook.node:setEnabled(false)
	self.btn_arrow:runAction(sequence)
end

function CombinedServerActView:OnClickDzpRechangeHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

--设置自动抽奖定时器，次数用完时停止
local add_time = 0
function CombinedServerActView:SetAutoDrawTimer(time, can_draw)
	--判断是否勾选自动抽奖，是否满足抽奖条件，否则不进入
	if not can_draw or not self:GetIsAutoDraw()  then
		self:CancelAutoDrawTimer()
		return
	end
	
	local function AutoDrawCallFunc()
		if not self:GetIsIgnoreAction() then
			add_time = add_time + 0.5
			if add_time < time  then
				return
			else
				add_time = 0
			end
		end

		self:OnClickTurntableHandler()
	end

	if nil == self.auto_draw_time_quest then
		self.auto_draw_time_quest = GlobalTimerQuest:AddRunQuest(AutoDrawCallFunc, 0.5)
	end
end

--停止定时器
function CombinedServerActView:CancelAutoDrawTimer()
	self:CloseAutoDraw()
	if self.auto_draw_time_quest then
		GlobalTimerQuest:CancelQuest(self.auto_draw_time_quest)
	end
	self.auto_draw_time_quest = nil
end

function CombinedServerActView:GetIsAutoDraw()
	return self.node_t_list.layout_act_auto_draw_hook and self.node_t_list.layout_act_auto_draw_hook.img_hook.node:isVisible()
end

function CombinedServerActView:CloseAutoDraw()
	if self.node_t_list.layout_act_auto_draw_hook then
		self.node_t_list.layout_act_auto_draw_hook.img_hook.node:setVisible(false)
	end
end

function CombinedServerActView:GetIsIgnoreAction()
	return self.node_t_list.layout_act_auto_hook and self.node_t_list.layout_act_auto_hook.img_hook.node:isVisible()
end

CombinedDZPLogRender = CombinedDZPLogRender or BaseClass(BaseRender)
function CombinedDZPLogRender:__init()	
end

function CombinedDZPLogRender:__delete()	
end

function CombinedDZPLogRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.rich_dzp_reward.node:setIgnoreSize(true)
end

function CombinedDZPLogRender:OnFlush()
	if self.data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then 
		return 
	end
	local content = string.format(Language.CombinedServerAct.DZPLog, self.data.name, item_cfg.color, item_cfg.name, self.data.item_id, self.data.num)
	RichTextUtil.ParseRichText(self.node_tree.rich_dzp_reward.node, content, 20)
end

function CombinedDZPLogRender:CreateSelectEffect()
end
