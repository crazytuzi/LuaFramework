AnswerActivityTipView = AnswerActivityTipView or BaseClass(XuiBaseView)

function AnswerActivityTipView:__init()
	self.zorder = 100
	self.config_tab = {
		{"welkin_ui_cfg", 6, {0}},
	}
	self.root_node_off_pos = {x = 0, y = -200}
end

function AnswerActivityTipView:__delete()

end

function AnswerActivityTipView:ReleaseCallBack()

end

function AnswerActivityTipView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		-- local screen_h = HandleRenderUnit:GetHeight()
		-- self.node_t_list.layout_tip.node:setPositionY(screen_h/2 - 200)
	end
end

function AnswerActivityTipView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function AnswerActivityTipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function AnswerActivityTipView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--刷新界面
function AnswerActivityTipView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "bool" then
			local bool_sure = 0
			if v.gonggao_type == 4 then
				bool_sure = 1
			else
				bool_sure = 0
			end
			self.node_t_list.img_sure.node:loadTexture(ResPath.GetCommon("activity_answer_"..bool_sure))
			RichTextUtil.ParseRichText(self.node_t_list.txt_desc.node, v.str, 20, COLOR3B.YELLOW, nil, nil, nil, nil, true)
		end
	end
end