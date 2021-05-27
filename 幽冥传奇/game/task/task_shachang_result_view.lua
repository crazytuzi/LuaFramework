 ShaChengResultView = ShaChengResultView or BaseClass(BaseView)
function ShaChengResultView:__init( ... )
	self:SetBgOpacity(200)
	self:SetModal(true)
	self.is_any_click_close = true	
	self.texture_path_list = {
		"res/xui/task_ui.png",
		
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"mainui_task_effect_ui_cfg", 4, {0}},
		--{"team_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}},
	}
end

function ShaChengResultView:__delete( ... )
	-- body
end

function ShaChengResultView:ReleaseCallBack( ... )
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

	if self.flush_timer then
		GlobalTimerQuest:CancelQuest(self.flush_timer)
		self.flush_timer = nil
	end

end

function ShaChengResultView:LoadCallBack( ... )
	 XUI.AddClickEventListener(self.node_t_list.btn_sure.node, BindTool.Bind1(self.CloseBtnView, self), true)
end


function ShaChengResultView:OpenCallBack()
	-- override
end

function ShaChengResultView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ShaChengResultView:CloseCallBack(...)
	
end


function ShaChengResultView:CloseBtnView()
	ViewManager.Instance:CloseViewByDef(ViewDef.TaskShaChengResultGuide)
end




function ShaChengResultView:OnFlush(param_list, index)
	self.node_t_list.layout_result_sha.node:setScale(0.1)
	local scaleTo = cc.ScaleTo:create(0.2, 1)
	local queue = cc.Sequence:create(scaleTo)
	self.node_t_list.layout_result_sha.node:runAction(queue)
	for k, v in pairs(param_list) do
		if k == "param1" then
			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			local role_name = role_vo.name

			local text = string.format("行会: {wordcolor;00ffff;%s}", "沙巴克")
			local text1 = string.format("行会会长: {wordcolor;00ffff;%s}", role_name)
			local text2 = string.format("行会副会长: {wordcolor;00ff00;%s}", "沙城副将")
			RichTextUtil.ParseRichText(self.node_t_list.text_show1.node, text, 22)
			RichTextUtil.ParseRichText(self.node_t_list.text_show2.node, text1, 22)
			RichTextUtil.ParseRichText(self.node_t_list.text_show3.node, text2, 22)
			
			local text = string.format(Language.Task.ShaChengDesc, "沙巴克")
			RichTextUtil.ParseRichText(self.node_t_list.text_desc.node, text, 22)
		elseif k == "param2" then

			local text = string.format("行会: {wordcolor;00ffff;%s}", v.guild_name)
			local text1 = string.format("行会会长: {wordcolor;00ffff;%s}", v.huizhang_name)
			local text2 = string.format("行会副会长: {wordcolor;00ffff;%s}", v.guild_fuhuizhuang_name)

			RichTextUtil.ParseRichText(self.node_t_list.text_show1.node, text, 22)
			RichTextUtil.ParseRichText(self.node_t_list.text_show2.node, text1, 22)
			RichTextUtil.ParseRichText(self.node_t_list.text_show3.node, text2, 22)

			local text = string.format(Language.Task.ShaChengDesc, v.guild_name)
			RichTextUtil.ParseRichText(self.node_t_list.text_desc.node, text, 22)
		end
	end
end
