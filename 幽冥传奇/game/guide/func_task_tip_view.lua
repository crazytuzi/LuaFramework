FuncTaskTipView = FuncTaskTipView or BaseClass(XuiBaseView)

function FuncTaskTipView:__init()
	self:SetModal(false)
	-- self.can_penetrate = true
	self.texture_path_list[1] = 'res/xui/funcnote.png'
	self.config_tab  = {
		{"func_task_ui_cfg",1,{0},}
	}
end

function FuncTaskTipView:__delete()
end	

function FuncTaskTipView:ReleaseCallBack()

end

function FuncTaskTipView:LoadCallBack(index, loaded_times)
	
	self.node_t_list.desc_rich_text.node:setVerticalAlignment(RichVAlignment.VA_CENTER)
end	

function FuncTaskTipView:OnFlush(params_t, index)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local guide = GuideData.Instance:GetTaskGuideCfg()
	local res = TaskData.Instance:GetTaskList()
	for k, v in pairs(res) do
		for k1, v1 in pairs(guide) do
			if k == k1 then
				self.node_t_list.img_bg.node:loadTexture(ResPath.GetBigPainting("func_task_tip_bg", true))
				RichTextUtil.ParseRichText(self.node_t_list.desc_rich_text.node, v1, 23,COLOR3B.GREEN)
			end
		end
	end

	for k2, v2 in pairs(ClientLevelTipCfg) do
		if k2 == level then
			self.node_t_list.img_bg.node:loadTexture(ResPath.GetBigPainting("func_task_tip_bg_" .. 1, true))
			RichTextUtil.ParseRichText(self.node_t_list.desc_rich_text.node, v2, 23,COLOR3B.GREEN)
		end
	end

	

	-- self.node_t_list.level_open_text.node:setString(Language.Guide.TaskPrompt)
end	

function FuncTaskTipView:ShowIndexCallBack()
	self:Flush()
end