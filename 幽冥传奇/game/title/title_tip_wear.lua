TitleTipWear = TitleTipWear or BaseClass(BaseView)
function TitleTipWear:__init()
	self.config_tab = {
		{"dialog_ui_cfg", 5, {0},},
	}
	self.is_any_click_close = true
end

function TitleTipWear:__delete()
	-- body
end


function TitleTipWear:ReleaseCallBack()
	if self.role_title then
		self.role_title:DeleteMe()
		self.role_title = nil
	end
end

function TitleTipWear:LoadCallBack(index, loaded_times)
	if nil == self.role_title then
		local ph = self.ph_list.ph_title 
		self.role_title = Title.New()
		self.role_title:GetView():setPosition(ph.x + 85, ph.y)
		self.node_t_list.layout_title_tip_wear.node:addChild(self.role_title:GetView(), 100)
		self.role_title:SetScale(1)
		-- CommonAction.ShowJumpAction(self.role_title:GetView(), 10)
	end

	XUI.AddClickEventListener(self.node_t_list.btn_go.node, BindTool.Bind1(self.OpenNewFashionView, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, BindTool.Bind1(self.CloseTitleView, self), true)
end

function TitleTipWear:OpenCallBack()
	-- override
end

function TitleTipWear:ShowIndexCallBack(index)
	self:Flush(index)
end

function TitleTipWear:CloseCallBack(...)
	-- override
end



function TitleTipWear:OnFlush(param_list, index)
	for k,v in pairs(param_list) do
		if k == "title_change" then
			self.role_title:SetTitleId(v.titleId)
		end
	end
end

function TitleTipWear:OpenNewFashionView()
	ViewManager.Instance:OpenViewByDef(ViewDef.Fashion.Title.TitlePossession)
	ViewManager.Instance:CloseViewByDef(ViewDef.WearTitleTip)
end

function TitleTipWear:CloseTitleView()
	ViewManager.Instance:CloseViewByDef(ViewDef.WearTitleTip)
end