
CrossServerView = CrossServerView or BaseClass(XuiBaseView)

function CrossServerView:__init()
	if	CrossServerView.Instance then
		ErrorLog("[CrossServerView]:Attempt to create singleton twice!")
	end
	self:SetIsAnyClickClose(true)
	self:SetModal(true)
	
	self.series = 0
end

function CrossServerView:__delete()
end

function CrossServerView:ReleaseCallBack()
end

function CrossServerView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossServerView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local size = cc.size(504, 325)
		self.root_node:setContentSize(size)
		local img_bg = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetBigPainting("cross_server_six"))
		self.root_node:addChild(img_bg)
		local btn = XUI.CreateButton(size.width / 2, 80, 0, 0, false, ResPath.GetCommon("btn_103"))
		btn:setTitleText(Language.Common.Confirm)
		btn:setTitleFontSize(22)
		self.root_node:addChild(btn)
		XUI.AddClickEventListener(btn, BindTool.Bind(self.OnClickBtnClose, self))
	end
end

function CrossServerView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossServerView:OnFlush(param_t, index)
	
end

function CrossServerView:OnClickBtnClose()
	self:Close()
end






