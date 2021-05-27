MainUIArrowBtn = MainUIArrowBtn or BaseClass()


function MainUIArrowBtn:__init(parent,path,is_plist,w,h,is_flap_true)
	self.parent = parent
	self.width = w
	self.height = h
	self.is_flap_true = is_flap_true --是否折叠为真

	self.container = XUI.CreateLayout(0,0,w,h)
	self.container:setAnchorPoint(0,0)
	parent:addChild(self.container)

	self.arrow_btn = XUI.CreateImageView(0,0,path,is_plist)
	self.container:addChild(self.arrow_btn)

	self:SetIsOn(true)

	XUI.AddClickEventListener(self.arrow_btn,BindTool.Bind(self.OnToggleHandler, self),true)

end

function MainUIArrowBtn:__delete()
end	

function MainUIArrowBtn:OnToggleHandler()
	self:SetIsOn(not self:GetInOn())
	if self.callback ~= nil then
		self.callback()
	end	
end	

function MainUIArrowBtn:SetCallBack(callback)
	self.callback = callback
end	


function MainUIArrowBtn:GetView()
	return self.container
end	

function MainUIArrowBtn:SetIsOn(state)
	self.is_on = state
	if self.is_on then
		if self.is_flap_true then
			self.arrow_btn:setScaleX(-1)
		else
			self.arrow_btn:setScaleX(1)
		end	
	else
		if self.is_flap_true then
			self.arrow_btn:setScaleX(1)
		else
			self.arrow_btn:setScaleX(-1)
		end
	end	
end	

function MainUIArrowBtn:GetInOn()
	return self.is_on
end	

function MainUIArrowBtn:SetRemindVis(visible)
	if nil == self.remind_bg_img then
		self.remind_bg_img = XUI.CreateImageView(self.width - 56, self.height - 40, ResPath.GetMainui("remind_flag"), true)
		self.container:addChild(self.remind_bg_img, 300, 300)
	end
	self.remind_bg_img:setVisible(visible)
end