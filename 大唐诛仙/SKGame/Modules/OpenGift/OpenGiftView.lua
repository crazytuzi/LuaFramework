OpenGiftView = BaseClass()

function OpenGiftView:__init()
	self:InitData()
	self:InitEvent()
	self:LayoutUI()
end

function OpenGiftView:__delete()
	if self.openGiftPanel and self.openGiftPanel.isInited then
		self.openGiftPanel:Destroy()
	end
	self.openGiftPanel = nil
end

function OpenGiftView:InitData()
	self.openGiftPanel = nil
end

function OpenGiftView:InitEvent()

end

function OpenGiftView:LayoutUI()
	if self.isInited then return end
	self.isInited = true
end

function OpenGiftView:Open()
	if not self.openGiftPanel or not self.openGiftPanel.isInited then
		self.openGiftPanel = OpenGiftPanel.New()
	end
	self.openGiftPanel:Open()
end

function OpenGiftView:GetopenGiftPanel()
	return self.openGiftPanel
end
