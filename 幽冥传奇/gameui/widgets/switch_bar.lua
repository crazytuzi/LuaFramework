SwitchBar = SwitchBar or BaseClass(BaseRender)

function SwitchBar:__init()
	self.on_img = nil
	self.off_img = nil
	self.ball_img = nil
	self.desc_text = nil
	self.callback = nil
	self.width = 104
	self.height = 39

	self:SetSkin(ResPath.GetCommon("switch_on"), ResPath.GetCommon("switch_off"), ResPath.GetCommon("switch_ball"))
	self:SetContentSize(self.width, self.height)
	self:SetIsOn(false)

	self:AddClickEventListener(BindTool.Bind(self.OnSwitchState, self), false)
end

function SwitchBar:__delete()

end

function SwitchBar:SetSkin(on_path, off_path, ball_path)
	if nil ~= on_path then
		self.on_img = XUI.CreateImageView(0, 0, on_path)
		self.view:addChild(self.on_img)
		self.on_img:setAnchorPoint(0, 0)
		self.on_img:setVisible(false)
	end

	if nil ~= off_path then
		self.off_img = XUI.CreateImageView(0, 0, off_path)
		self.off_img:setAnchorPoint(0, 0)
		self.view:addChild(self.off_img)
	end

	if nil ~= ball_path then
		-- self.ball_img = XUI.CreateImageView(0, 0, ball_path)
		-- self.ball_img:setAnchorPoint(0, 0)
		-- self.ball_img:setPositionY((self.height - self.ball_img:getContentSize().height) / 2)
		-- self.view:addChild(self.ball_img)
	end

	if nil == self.desc_text then
		self.desc_text = XUI.CreateText(0,20,30,0,0," ")
		self.desc_text:setAnchorPoint(0, 0.5)
		self.view:addChild(self.desc_text)
	end	
end

function SwitchBar:OnSwitchState()
	self:SetIsOn(not self.is_on)

	if nil ~= self.callback then
		self.callback()
	end	
end

function SwitchBar:SetCallback(callback)
	self.callback = callback
end	

function SwitchBar:GetIsOn()
	return self.is_on
end	

function SwitchBar:SetIsOn(is_on)
	self.is_on = is_on

	if nil ~= self.on_img then
		self.on_img:setVisible(is_on)
	end

	if nil ~= self.off_img then
		self.off_img:setVisible(not is_on)
	end

	if is_on then
		-- self.ball_img:setPositionX(self.width - self.ball_img:getContentSize().width + 6)
		self.desc_text:setPositionX(self.width - self.desc_text:getContentSize().width - 13)
		self.desc_text:setString(Language.Common.Kai)
	else
		-- self.ball_img:setPositionX(-6)
		self.desc_text:setPositionX(10)
		self.desc_text:setString(Language.Common.Guan)
	end
end