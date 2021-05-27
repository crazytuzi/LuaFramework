--抽奖活动
ActTurnbleBaseView = ActTurnbleBaseView or BaseClass(ActBaseView)

--抽奖状态
ActTurnbleBaseView.STATE = {
	AUTO_DRAW = 1, --自动抽奖
}
-- 注册通用点击事件
function ActTurnbleBaseView:AddActCommonClickEventListener()
	if nil == self.node_t_list.layout_act_auto_hook or nil == self.node_t_list.layout_act_auto_draw_hook then return end
	XUI.AddClickEventListener(self.node_t_list.layout_act_auto_hook.btn_nohint_checkbox.node, BindTool.Bind(self.OnClickZhuanPanAutoUse, self, 1), true)
	self.node_t_list.layout_act_auto_hook.img_hook.node:setVisible(false)
	XUI.AddClickEventListener(self.node_t_list.layout_act_auto_draw_hook.btn_nohint_checkbox.node, BindTool.Bind(self.OnClickZhuanPanAutoUse, self, 2), true)
	self.node_t_list.layout_act_auto_draw_hook.img_hook.node:setVisible(false)
end

function ActTurnbleBaseView:CloseCallback()
	self:CancelAutoDraw()
end

function ActTurnbleBaseView:SwitchIndexView()
	self:CancelAutoDraw()
end

function ActTurnbleBaseView:OnClickZhuanPanAutoUse(tag)
	if tag == 1 then
		local vis = self.node_t_list.layout_act_auto_hook.img_hook.node:isVisible()
		self.node_t_list.layout_act_auto_hook.img_hook.node:setVisible(not vis)
	else
		local vis_2 = self.node_t_list.layout_act_auto_draw_hook.img_hook.node:isVisible()
		if vis_2 then self:CancelAutoDraw() end --checkbox点击后立即取消自动抽奖 避免延时调用影响
		self.node_t_list.layout_act_auto_draw_hook.img_hook.node:setVisible(not vis_2)
	end
end

--设置自动抽奖定时器，次数用完时自动停止
local add_time = 0
function ActTurnbleBaseView:UpdateAutoDrawTimer(time, can_draw)
	--判断是否勾选自动抽奖，是否满足抽奖条件，否则跳出循环
	if not can_draw or not self:GetIsAutoDraw() then
		self:CancelAutoDraw()
		return
	end

	self:AddStopButton(self.act_id)	--进入自动抽奖时 创建停止按钮

	local function AutoDrawCallFunc()
		if not self:GetIsIgnoreAction() then
			add_time = add_time + 0.5
			if add_time < time  then
				return
			else
				add_time = 0
			end
		end

		self:OnClickTurntableHandler() --一定时间后自动点击抽奖
	end

	if nil == self.auto_draw_time_quest then
		self.auto_draw_time_quest = GlobalTimerQuest:AddRunQuest(AutoDrawCallFunc, 0.5)
	end
end

--根据id添加停止按钮
local spiecl_button_ui_name = {
	[25] = "img_25_stop",
	[45] = "act_img_45_stop",
	[54] = "act_54_stop_draw",
	[79] = "act_54_stop_draw",
}

local stop_button_pos = {
	[10] = {x = 485.35, y = 78.8},
	[27] = {x = 355.85, y = 100},
	[25] = {x = 217, y = 213},
	[45] = {x = 363, y = 250.05},
	[54] = {x = 228,y = 185},
	[79] = {x = 514,y = 233},
}

function ActTurnbleBaseView:AddStopButton(act_id)
	if nil == self.stop_button then
		local path = spiecl_button_ui_name[act_id] and ResPath.GetActivityBrilliant(spiecl_button_ui_name[act_id]) or ResPath.GetCommon("btn_103")
		self.stop_button = XUI.CreateButton(stop_button_pos[act_id].x, stop_button_pos[act_id].y, 0, 0, false, path, "", "", true)
		if not spiecl_button_ui_name[act_id] then
			self.stop_button:setTitleText(Language.ActivityBrilliant.TurnbleStopDarw)
			self.stop_button:setTitleFontSize(24)
			self.stop_button:setTitleFontName(COMMON_CONSTS.FONT)
		end
		self.tree.node:addChild(self.stop_button, 999)
		XUI.AddClickEventListener(self.stop_button, BindTool.Bind(function ()
			self:CancelAutoDraw()
		end))
	end
	self.stop_button:setVisible(true)
end

--停止自动抽奖
function ActTurnbleBaseView:CancelAutoDraw()
	self:CancelAutoDrawTimer()
	if self.stop_button then
		self.stop_button:setVisible(false)
	end
end

--停止定时器
function ActTurnbleBaseView:CancelAutoDrawTimer()
	self:CloseAutoDraw()
	if self.auto_draw_time_quest then
		GlobalTimerQuest:CancelQuest(self.auto_draw_time_quest)
	end
	self.auto_draw_time_quest = nil
end

function ActTurnbleBaseView:GetIsAutoDraw()
	return self.node_t_list.layout_act_auto_draw_hook and self.node_t_list.layout_act_auto_draw_hook.img_hook.node:isVisible()
end

function ActTurnbleBaseView:CloseAutoDraw()
	if self.node_t_list.layout_act_auto_draw_hook then
		self.node_t_list.layout_act_auto_draw_hook.img_hook.node:setVisible(false)
	end
end

function ActTurnbleBaseView:GetIsIgnoreAction()
	return self.node_t_list.layout_act_auto_hook and self.node_t_list.layout_act_auto_hook.img_hook.node:isVisible()
end

function ActTurnbleBaseView:TryDrawIgnoreAction(tag)
	if self:GetIsIgnoreAction() then
		ActivityBrilliantCtrl.Instance.ActivityReq(4, self.act_id, tag)
		return true
	end
end

--点击抽奖
function ActTurnbleBaseView:OnClickTurntableHandler()
end
