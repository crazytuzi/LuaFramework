TaskCompeteTip = TaskCompeteTip or BaseClass(XuiBaseView)
function TaskCompeteTip:__init()
	-- if TaskCompeteTip.Instance then
	-- 	ErrorLog("[TaskCompeteTip] Attemp to create a singleton twice !")
	-- end
	self.texture_path_list[1] = 'res/xui/charge.png'
	TaskCompeteTip.Instance = self
	self.is_modal = true
	self.background_opacity = 200
	self.config_tab  = {
		{"func_task_ui_cfg",2,{0},}
	}
	self.root_node_off_pos = {x = -50, y = 0}

end

function TaskCompeteTip:__delete()
	--TaskCompeteTip.Instance = nil
end

function TaskCompeteTip:LoadCallBack()
	
	XUI.AddClickEventListener(self.node_t_list.layout_btn.node, BindTool.Bind1(self.CloseWindow, self))
	XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.CloseWindow, self))
end

--欢迎界面的logo替换写到了opencallback中
function TaskCompeteTip:ShowIndexCallBack()
	
end

function TaskCompeteTip:CloseWindow()
	ViewManager.Instance:Open(ViewName.Activity)
	self:Close()
end