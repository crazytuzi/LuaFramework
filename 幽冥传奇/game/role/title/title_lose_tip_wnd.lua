-- 失去称号提醒弹窗
TitleLoseView = TitleLoseView or BaseClass(XuiBaseView)
function TitleLoseView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.def_index = 1
	self.config_tab = {
		{"role_ui_cfg", 14, {0}},
	}
end

function TitleLoseView:__delete()
end

function TitleLoseView:ReleaseCallBack()
	if self.title then
		self.title:DeleteMe()
		self.title = nil
	end
end

function TitleLoseView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- self:CreateTopTitle(Language.WaBao.WabaoName, nil, content_size.height - 53)
		self.title = Title.New()
		local size = self.node_t_list.layout_title_lose_tip.node:getContentSize()
		self.title:GetView():setPosition(cc.p(size.width / 2, size.height - 60))
		self.node_t_list.layout_title_lose_tip.node:addChild(self.title:GetView(), 100)
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind(self.Close, self))
		-- self.node_t_list.btn_enter.node:addClickEventListener(BindTool.Bind(self.Enter, self))
	end
end

function TitleLoseView:SetDataOpen(data)
	self.data = data
	self:Open()
end

function TitleLoseView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function TitleLoseView:OpenCallBack()

end
	
function TitleLoseView:CloseCallBack()

end


function TitleLoseView:OnFlush(param_t, index)
	self.title:SetTitleId(self.data)
end