TaskActiveOtheriew = TaskActiveOtheriew or BaseClass(BaseView)
function TaskActiveOtheriew:__init( ... )
	self:SetBgOpacity(200)
	self:SetModal(true)

	self.texture_path_list = {
		"res/xui/task_ui.png",
		
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"mainui_task_effect_ui_cfg", 2, {0}},
		--{"team_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}},
	}
end

function TaskActiveOtheriew:__delete( ... )
	-- body
end

function TaskActiveOtheriew:ReleaseCallBack( ... )
	-- if self.progress then
	-- 	self.progress:DeleteMe()
	-- 	self.progress = nil 
	-- end
	-- if self.delay_timer then
	-- 	GlobalTimerQuest:CancelQuest(self.delay_timer)
	-- 	self.delay_timer = nil
	-- end
	-- if self.effect_show1 then
	-- 	self.effect_show1:setStop()
	-- 	self.effect_show1 = nil
	-- end
end

function TaskActiveOtheriew:LoadCallBack( ... )
	 XUI.AddClickEventListener(self.node_t_list.layout_close.node, BindTool.Bind1(self.CloseView, self), true)
	 self.data = nil

end


function TaskActiveOtheriew:OpenCallBack()
	-- override
end

function TaskActiveOtheriew:ShowIndexCallBack(index)
	self:Flush(index)
end

function TaskActiveOtheriew:CloseCallBack(...)
	
end


function TaskActiveOtheriew:CloseView( ... )
	if  self.data ~= nil then
		ViewManager.Instance:OpenViewByStr(self.data.view_def)
		ViewManager.Instance:CloseViewByDef(ViewDef.TaskNewXiTongGuide)
		TaskCtrl.Instance:FlyToConbar( self.data.view_node, self.data.view_node_name, ResPath.GetTaskUIPath("icon_"..(self.data.view_index)))
	end
end

--ZhangJiangView node_name = "iconbar"


function TaskActiveOtheriew:OnFlush(param_list, index)

	for k, v in pairs(param_list) do
		if k == "param1" then
			self.data = v
			local path1 = ResPath.GetTaskUIPath("text_img"..(self.data.view_index))
			local path2 = ResPath.GetTaskUIPath("icon_"..(self.data.view_index))
			self.node_t_list.img_icon_1.node:loadTexture(path2)
			self.node_t_list.img_text1.node:loadTexture(path1)
		end
	end
end