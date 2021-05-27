 TaskTiYanEquipGuide = TaskTiYanEquipGuide or BaseClass(BaseView)
function TaskTiYanEquipGuide:__init( ... )
	--self:SetBgOpacity(200)
	self:SetModal(true)
	self.is_any_click_close = true	
	self.zorder = COMMON_CONSTS.PANEL_MAX_ZORDER 
	self.texture_path_list = {
		"res/xui/task_ui.png",
		
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"mainui_task_effect_ui_cfg", 5, {0}},
		--{"team_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}},
	}
	self.data =  nil
end

function TaskTiYanEquipGuide:__delete( ... )
	-- body
end

function TaskTiYanEquipGuide:ReleaseCallBack( ... )


end

function TaskTiYanEquipGuide:LoadCallBack( ... )
	 XUI.AddClickEventListener(self.node_t_list.btn_sure.node, BindTool.Bind1(self.OpenView, self), true)
end


function TaskTiYanEquipGuide:OpenCallBack()
	-- override
end

function TaskTiYanEquipGuide:ShowIndexCallBack(index)
	self:Flush(index)
end


function TaskTiYanEquipGuide:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "change_btn" then
			self.node_t_list.btn_sure.node:loadTextures(ResPath.GetTaskUIPath("btn_tiyan"))
			self.data = v.index
		elseif k == "change_btn1" then
			self.node_t_list.btn_sure.node:loadTextures(ResPath.GetTaskUIPath("btn_tiyan2"))
			self.data = nil
		end
	end
end

function TaskTiYanEquipGuide:CloseCallBack(...)
	
end

function TaskTiYanEquipGuide:OpenView()
	if self.data then
		--ViewManager.Instance:OpenViewByDef(ViewDef.Explore.RareTreasure)
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.TaskEquipTiYanGuide)
end