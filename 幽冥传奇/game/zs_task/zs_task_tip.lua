-- 钻石任务完成后提示
ZsTaskTipView = ZsTaskTipView or BaseClass(BaseView)

function ZsTaskTipView:__init( ... )
	self.is_any_click_close = true
	self.can_penetrate = true
		self.texture_path_list = {
	}
	self.config_tab = {
		{"zs_task_ui_cfg", 2, {0}}
	}
end

function ZsTaskTipView:__delete()
	-- body
end

function ZsTaskTipView:ReleaseCallBack( ... )
	
end

function ZsTaskTipView:OpenCallBack()
	local view = self.real_root_node
	local temp_posx, temp_posy = self.real_root_node:getPosition()
	view:setBackGroundColorOpacity(0)
	view:setScale(0.1)
	local size = view:getContentSize()
	local pos = view:convertToWorldSpace(cc.p(size.width * 0.5, size.height * 0.5))
	local life_time = cc.pGetLength(cc.pSub(pos,cc.p(temp_posx, temp_posy)))*0.00035
	local callback = cc.CallFunc:create(function()
			view:stopAllActions()
	end)
	local action = cc.Spawn:create(cc.MoveTo:create(life_time + 0.2,pos),cc.ScaleTo:create(life_time+0.2, 1))
	local queue = cc.Sequence:create(action,callback)
	view:runAction(queue)
end

function ZsTaskTipView:LoadCallBack()
	local index = ZsTaskData.Instance:GetBigTaskIndex()
	self.node_t_list.lbl_open_task.node:setString(Language.DailyTasks.NewTask .. Language.DailyTasks.TaskType[index-1])
end

function ZsTaskTipView:ShowIndexCallBack( ... )
	-- body
end

function ZsTaskTipView:OnFlush()
	
end

function ZsTaskTipView:CloseCallBack( ... )
end