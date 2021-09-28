-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_social_action = i3k_class("wnd_social_action", ui.wnd_base)

local LAYER_AN7 = "ui/widgets/an7"
local LAYER_AN8 = "ui/widgets/an8"

function wnd_social_action:ctor()

end

function wnd_social_action:configure()
	self.scroll = self._layout.vars.scroll
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_social_action:onShow()

end

function wnd_social_action:refresh()
	self:updateAction()
end

function wnd_social_action:updateAction()
	self.scroll:removeAllChildren()
	local fashionId = g_i3k_game_context:GetCurFashion()
	local cfg = fashionId and i3k_db_fashion_dress[fashionId].withEffect == 1 and i3k_db_fashion_dress[fashionId].actionIds
	if cfg then
		for i,v in ipairs(cfg) do
			local widget = require(LAYER_AN7)()
			local iconid = i3k_db_social[v].icon_id
			widget.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon_id))
			widget.vars.btnName:setText(i3k_db_social[v].name)
			widget.vars.btn:onClick(self,self.onPlayAction,v)
			self.scroll:addItem(widget)
		end
	end
	for k,v in ipairs(i3k_db_social) do
		if v.isEffectAct == 0 then
			local layer = require(LAYER_AN7)()
			local icon = layer.vars.icon
			local btn = layer.vars.btn
			local btnName = layer.vars.btnName
			btnName:setText(v.name)
			btn:onClick(self,self.onPlayAction,k)
			icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon_id))
			self.scroll:addItem(layer)
		end
	end
end

function wnd_social_action:onPlayAction(sender,id)
	if g_i3k_game_context:IsOnRide() then
		return g_i3k_ui_mgr:PopupTipMessage("骑乘时无法施展社交动作")
	end
	--local
	g_i3k_game_context:UnRide(function()
		--判断当前的棋局任务是否能完成
		local chess = g_i3k_game_context:getChessTask()
		if chess.curTaskID and chess.curTaskID > 0 then
			local cfg = i3k_db_chess_task[chess.curTaskID]
			--下面这部分可以单独写成一个方法，每种任务都调用判断能否完成，但是完成任务的协议每个任务是独立的
			if cfg.type == g_TASK_PLAY_SOCIALACT and cfg.arg1 == id then
				local selectRole = g_i3k_game_context:GetSelectedRoleData()
				if selectRole then
					local isExtra = 0
					if selectRole.type == cfg.arg2 then
						isExtra = 1
					end
					g_i3k_game_context:tellSeverChessTaskFinished(isExtra, g_TASK_PLAY_SOCIALACT, cfg.arg1)
				end
			end
		end
		local festival = g_i3k_game_context:getFestivalLimitTask()
		for k, v in pairs(festival) do
			if v.curTask and v.curTask.state == 1 then
				local taskInfo = i3k_db_festival_task[v.curTask.groupId][v.curTask.index]
				if taskInfo.type == g_TASK_PLAY_SOCIALACT and taskInfo.arg1 == id then
					g_i3k_game_context:tellSeverFestivalFinish(g_TASK_PLAY_SOCIALACT, id, taskInfo.arg2, 1)
				elseif taskInfo.type == g_TASK_NPC_SOCIAL_ACTION and taskInfo.arg1 == g_i3k_game_context:GetSelectNpcId() and taskInfo.arg2 == id then
					g_i3k_game_context:tellSeverFestivalFinish(g_TASK_NPC_SOCIAL_ACTION, g_i3k_game_context:GetSelectNpcId(), id, 1)
				end
			end
		end
		
		i3k_sbean.play_role_socialaction(g_i3k_game_context:GetRoleId(), id, g_i3k_game_context:GetRoleName(), g_i3k_game_context:GetSelectName())
	end)
	g_i3k_ui_mgr:CloseUI(eUIID_SocialAction)
end

function wnd_create(layout, ...)
	local wnd = wnd_social_action.new();
		wnd:create(layout, ...);
	return wnd;
end
