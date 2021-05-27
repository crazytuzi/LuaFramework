--追踪对话框view
TraceDlgView = TraceDlgView or BaseClass(XuiBaseView)
function TraceDlgView:__init()
	self.name = "traceDlgView"
	self:SetModal(true)
	self.config_tab = {
		{"society_ui_cfg", 8, {0}},
	}
	self.data = nil
end

function TraceDlgView:__delete()
	self.data = nil
end

function TraceDlgView:ReleaseCallBack()

end

function TraceDlgView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self:SetTextsColor()
		self:AddEvents()
	end
	
end

function TraceDlgView:SetViewData(data)
	self.data = data
	XuiBaseView.Open(self)
	self:Flush()
end

function TraceDlgView:ShowIndexCallBack(index)
	self:Flush()
end

function TraceDlgView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	
end

function TraceDlgView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--刷新相应界面
function TraceDlgView:OnFlush(param_t, index)
	self.node_t_list.btn_OK.node:setTitleText(self.data.btn_1_name)
	self:SetTraceDlgTexts()
end

function TraceDlgView:AddEvents()
	self.node_t_list["btn_OK"].node:addClickEventListener(BindTool.Bind(self.OnOkClicked, self))
	self.node_t_list["btn_cancel"].node:addClickEventListener(BindTool.Bind(self.OnCancelClicked, self))
end

function TraceDlgView:SetTextsColor()
	self.node_t_list["lbl_player_name"].node:setColor(COLOR3B.OLIVE)
	self.node_t_list["lbl_cur_at_map"].node:setColor(COLOR3B.RED)
	self.node_t_list["lbl_cur_coord"].node:setColor(COLOR3B.RED)
end

function TraceDlgView:SetTraceDlgTexts()
	self.node_t_list["lbl_player_name"].node:setString(self.data.name)
	self.node_t_list["lbl_cur_at_map"].node:setString(self.data.map_name)
	self.node_t_list["lbl_cur_coord"].node:setString(self.data.pos_x .. ":" .. self.data.pos_y)
	RichTextUtil.ParseRichText(self.node_t_list["rich_dialog"].node, Language.Society["TraceTip" .. self.data.index], 22, COLOR3B.OLIVE)
end

function TraceDlgView:OnOkClicked()
	local ok_call_back = self.data.call_back_1
	if ok_call_back then
		ok_call_back()
	end
end

function TraceDlgView:OnCancelClicked()
	self:Close()
end
