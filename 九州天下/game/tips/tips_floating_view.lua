TipsFloatingView = TipsFloatingView or BaseClass(BaseView)

function TipsFloatingView:__init()
	self.ui_config = {"uis/views/tips/floatingtips", "FloatingTips"}
	self.view_layer = UiLayer.PopTop

	self.messge = nil
	self.close_timer = nil
	self.pos_x = 0
	self.pos_y = 0
	self.call_back = nil
end

function TipsFloatingView:__delete()
end

function TipsFloatingView:LoadCallBack()
	self.text = self:FindVariable("Text")
	self.show_spec_text = self:FindVariable("ShowSpecText")
	self.show_spec_img = self:FindVariable("ShowSpecImg")
	self.img_path = self:FindVariable("ImgWord")
	self.show_normal_img = self:FindVariable("ShowNormalImg")
end

function TipsFloatingView:ReleaseCallBack()
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
	end

	-- 清理变量和对象
	self.text = nil
	self.show_spec_text = nil
	self.show_spec_img = nil
	self.show_normal_img = nil
	self.img_path = nil
	self.call_back = nil
end

function TipsFloatingView:CloseCallBack()
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
	end
end

function TipsFloatingView:Show(msg, pos_x, pos_y, is_show_spec_text, is_show_spec_img, spec_img_bundle, spec_img_asset, is_show_normal_img, call_back)
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
	end
	self.close_timer = GlobalTimerQuest:AddDelayTimer(
		BindTool.Bind(self.CloseTips, self), 3)
	self.messge = msg
	self.pos_x = pos_x or 200
	self.pos_y = pos_y or -250
	self.is_show_spec_text = is_show_spec_text or false
	self.is_show_spec_img = is_show_spec_img or false
	self.spec_img_bundle = spec_img_bundle or ""
	self.spec_img_asset = spec_img_asset or ""
	self.is_show_normal_img = is_show_normal_img or false
	self.call_back = call_back
	self:Open()
	self:Flush()
end

function TipsFloatingView:CloseTips()
	self:Close()

	if self.call_back ~= nil then
		self.call_back()
		self.call_back = nil
	end
end

function TipsFloatingView:SetRendering(value)

end

function TipsFloatingView:OnFlush(param_list)
	self.show_spec_text:SetValue(self.is_show_spec_text)
	self.show_spec_img:SetValue(self.is_show_spec_img)
	self.show_normal_img:SetValue(self.is_show_normal_img)
	if self.spec_img_bundle and self.spec_img_asset then
		self.img_path:SetAsset(self.spec_img_bundle, self.spec_img_asset)
	end
	self.text:SetValue(self.messge)
	self.root_node.transform.localPosition = Vector3(self.pos_x, self.pos_y, 0)
end