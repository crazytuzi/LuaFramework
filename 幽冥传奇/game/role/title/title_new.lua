
TitleNewView = TitleNewView or BaseClass(XuiBaseView)
function TitleNewView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.def_index = 1

	self.config_tab = {
		{"role_ui_cfg", 11, {0}},
	}
end

function TitleNewView:__delete()
end

function TitleNewView:ReleaseCallBack()

end

function TitleNewView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- self:CreateTopTitle(Language.WaBao.WabaoName, nil, content_size.height - 53)
		self.title = Title.New()
		local size = self.node_t_list.layout_new_title.node:getContentSize()
		self.title:GetView():setPosition(cc.p(size.width / 2, size.height - 60))
		self.node_t_list.layout_new_title.node:addChild(self.title:GetView(), 100)
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind(self.Close, self))
		self.node_t_list.btn_enter.node:addClickEventListener(BindTool.Bind(self.Enter, self))
	end
end

function TitleNewView:SetDataOpen(data)
	self.data = data
	self:Open()
end

function TitleNewView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function TitleNewView:OpenCallBack()

end

	
function TitleNewView:Enter()
	local head_title = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE)
	local title_1 = bit:_and(head_title, 0x000000ff)
	local title_2 = bit:_rshift(bit:_and(head_title, 0x0000ff00), 8)
	if title_1 == 0 then
		title_1 = self.data
	else
		title_2 = self.data
	end

	TitleCtrl.SendTitleSelectReq(title_1, title_2)
	self:Close()
end

function TitleNewView:CloseCallBack()

end


function TitleNewView:OnFlush(param_t, index)
	self.title:SetTitleId(self.data)
end