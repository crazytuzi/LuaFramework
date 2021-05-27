ActGoldTurntableView = ActGoldTurntableView or BaseClass(ActTurnbleBaseView)
local DZP_COUNT = 10
local pos_list = {3, 8, 1, 5, 6, 10, 4, 9, 7, 2,}

function ActGoldTurntableView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ActGoldTurntableView:__delete()
	if self.draw_record_list then
		self.draw_record_list:DeleteMe()
		self.draw_record_list = nil
	end

	if self.spare_76_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_76_time)
		self.spare_76_time = nil
	end
end

function ActGoldTurntableView:InitView()
	self.node_t_list.btn_76_draw.node:addClickEventListener(BindTool.Bind(self.OnClickCZZPHandler, self))
	self.node_t_list.layout_gold_point.node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_select_eff.node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_select_eff.node:setVisible(false)

	self.node_t_list.btn_charge.node:addClickEventListener(function () ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge) end)
	self:CreateNumList()
	self:CreateDrawRecordList()
	self:CreateSpareFFTimer()
end


function ActGoldTurntableView:CreateDrawRecordList()
	local ph = self.ph_list.ph_drow_record_list
	self.draw_record_list = ListView.New()
	self.draw_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, GoldDrawRecordRender, nil, nil, nil)
	self.draw_record_list:GetView():setAnchorPoint(0.5, 0.5)
	self.draw_record_list:SetJumpDirection(ListView.Top)
	self.draw_record_list:SetItemsInterval(5)
	self.node_t_list.layout_gold_turntable.node:addChild(self.draw_record_list:GetView(), 100)
end

function ActGoldTurntableView:CreateNumList()
	self.number_list = {}
	local r = 112
	local x, y = self.node_t_list.layout_gold_point.node:getPosition()
	for i = 1, DZP_COUNT do
		local num = NumberBar.New()
		num:SetPosition(x - 30 + r * math.cos(math.rad(72 - 360 / DZP_COUNT * (pos_list[i] - 1))), y - 10 + r * math.sin(math.rad(72 - 360 / DZP_COUNT * (pos_list[i] - 1))))
		-- num:SetPosition(x - 30 + r * math.cos(math.rad(72 - 360 / DZP_COUNT * (i - 1))), y - 10 + r * math.sin(math.rad(72 - 360 / DZP_COUNT * (i - 1))))
		num:SetRootPath(ResPath.GetAct_73_83("num_act_76_"))
		num:SetSpace(-4)
		num:SetAnchorPoint(1, 0.5)
		self.node_t_list.layout_gold_turntable.node:addChild(num:GetView(), 300)
		table.insert(self.number_list, num)
	end
end

function ActGoldTurntableView:RefreshView(param_list)
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.GZP)
	local cur_grade = ActivityBrilliantData.Instance:GetCurDrawGrade()
	local is_last_grade = false
	if nil == cur_grade or 0 == cur_grade then 
		cur_grade = 1
	end
	self.node_t_list.btn_76_draw.node:setEnabled(true)
	if act_cfg.config and cur_grade > #act_cfg.config then 
		cur_grade = #act_cfg.config
		self.node_t_list.btn_76_draw.node:setEnabled(false)
		is_last_grade = true
	end
	if act_cfg.config and act_cfg.config[cur_grade] then
		local grade_data = act_cfg.config[cur_grade]
		local charge_money = ActivityBrilliantData.Instance:GetCurChargeMoney()
		local count = grade_data.paymoney
		local lost_money = count - charge_money
		local content = string.format(Language.ActivityBrilliant.ChargeToActive, lost_money > 0 and lost_money or 0)
		if is_last_grade then 
			content = Language.ActivityBrilliant.IsTheLastGrade
		end
		RichTextUtil.ParseRichText(self.node_t_list.rich_active_charge.node, content, 18)
		XUI.RichTextSetCenter(self.node_t_list.rich_active_charge.node)
		self.node_t_list.lbl_draw_money.node:setString(grade_data.consume)
		self.node_t_list.img_round_text.node:loadTexture(ResPath.GetAct_73_83("text_round_" .. cur_grade))
		for i,v in ipairs(self.number_list) do
			local number_t = self:NumberToList(grade_data.proTable[i].multiple)
			v:SetNumberList(number_t)
		end
		local draw_list = ActivityBrilliantData.Instance:GetDrawRrecord()
		self.draw_record_list:SetDataList(draw_list)
	end

	if nil == act_cfg then return end
	for k,v in pairs(param_list) do
		if k == "flush_view" and v.result and v.act_id == act_cfg.act_id and not self:GetIsIgnoreAction() then
			self.node_t_list.layout_gold_point.node:stopAllActions()
			local rotate = self.node_t_list.layout_gold_point.node:getRotation() % 360
			local to_rotate = 720 - rotate + 360 / DZP_COUNT / 2 + 360 / DZP_COUNT * (pos_list[v.result] - 1)
			local rotate_by = cc.RotateBy:create(2, to_rotate)
			self.node_t_list.layout_select_eff.node:setRotation(360 / DZP_COUNT * (pos_list[v.result] - 1) + 20)
			local callback = cc.CallFunc:create(function ()
				self.node_t_list.btn_76_draw.node:setEnabled(true)
				ItemData.Instance:SetDaley(false)

				self.node_t_list.layout_select_eff.node:setRotation(360 / DZP_COUNT * (pos_list[v.result] - 1) + 18)
				self.node_t_list.layout_select_eff.node:setVisible(true)
				
				local draw_list = ActivityBrilliantData.Instance:GetDrawRrecord()
				self.draw_record_list:SetDataList(draw_list)
			end)
			local sequence = cc.Sequence:create(rotate_by, callback)
			self.node_t_list.layout_gold_point.node:runAction(sequence)
		end
	end
end

function ActGoldTurntableView:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.GZP)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.layout_gold_turntable.lbl_activity_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ActGoldTurntableView:CreateSpareFFTimer()
	self.spare_76_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
	self:UpdateSpareFFTime()
end

-- function ActGoldTurntableView:OnClickTurntableHandler()
-- 	-- local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.GZP)
-- 	-- local can_draw = ActivityBrilliantData.Instance:GetCZZPData().draw_num > 0 
-- 	self:UpdateAutoDrawTimer(6, can_draw) --每隔1秒抽一次

-- 	if self:TryDrawIgnoreAction() then
-- 		self.node_t_list.btn_76_draw.node:setEnabled(true)
-- 		ItemData.Instance:SetDaley(false)
-- 		return
-- 	end --成功则跳过动画

-- 	self:OnClickCZZPHandler()
-- end

function ActGoldTurntableView:OnClickCZZPHandler()
	local can_draw = ActivityBrilliantData.Instance:GetZhuanPanRemindNum() > 0
	if not can_draw then
		-- SysMsgCtrl.Instance:FloatingTopRightText("投资不足")
		return
	end
	self.node_t_list.layout_select_eff.node:setVisible(false)
	local rotate_by1 = cc.RotateBy:create(2, 360 * 5)
	local rotate_by2 = cc.RotateBy:create(4, 360 * 10)
	local callback = cc.CallFunc:create(function ()
		ItemData.Instance:SetDaley(true)
   		ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.GZP)
	end)
	local callback2 = cc.CallFunc:create(function ()
		self.node_t_list.btn_76_draw.node:setEnabled(true)
	end)
	local sequence = cc.Sequence:create(rotate_by1, callback, rotate_by2, callback2)
	local sequence2 = cc.Sequence:create(rotate_by1, callback, rotate_by2, callback2)
	self.node_t_list.btn_76_draw.node:setEnabled(false)
	self.node_t_list.layout_gold_point.node:runAction(sequence)
end

function ActGoldTurntableView:NumberToList(num)
	local str = tostring(num)
    list = {}
	for i = 1, string.len(str) do
		local s = string.sub(str,i,i)
		if "." == s then 
			s = "point"
		end
        list[i] = s
	end
	list[string.len(str) + 1] = "mult"
	return list
end



GoldDrawRecordRender = GoldDrawRecordRender or BaseClass(BaseRender)
function GoldDrawRecordRender:__init(w, h, list_view)	
	self.view_size = cc.size(320, 24)
	self.view:setContentSize(self.view_size)
	self.list_view = list_view	
end

function GoldDrawRecordRender:__delete()	
end

function GoldDrawRecordRender:CreateChild()
	BaseRender.CreateChild(self)
	self.rich_text = RichTextUtil.ParseRichText(nil, "", 20, nil, 0, 0, self.view_size.width, self.view_size.height)
	self.rich_text:setAnchorPoint(0, 0)
	-- self.rich_text:setIgnoreSize(true)
	self.view:addChild(self.rich_text, 9)
end

function GoldDrawRecordRender:OnFlush()
	if self.data == nil then return end
	local content = string.format(Language.ActivityBrilliant.GoldDrawRecordStr, self.data.name, self.data.mult, self.data.gold)
	RichTextUtil.ParseRichText(self.rich_text, content, 18)
	self.rich_text:refreshView()
	local inner_size = self.rich_text:getInnerContainerSize()
	local size = {
		width = math.max(inner_size.width, self.view_size.width),
		height = math.max(inner_size.height, self.view_size.height),
	}
	self.rich_text:setContentSize(size)
	self.view:setContentSize(size)
	self.list_view:requestRefreshView()
end

function GoldDrawRecordRender:CreateSelectEffect()
end
