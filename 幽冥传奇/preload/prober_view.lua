local prober_view = {
	text = nil,
	error_log = nil,
}

function prober_view:Create()
	if nil ~= self.text then return end

	local size = cc.Director:getInstance():getWinSize()

	self.text = XText:create("", "res/fonts/MNJCY.ttf", 20, cc.size(size.width - 200, size.height - 100), 
		cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
	self.text:setPosition(size.width / 2, size.height / 2)
	self.text:setColor(cc.c3b(255, 255, 0))
	HandleRenderUnit:AddUi(self.text, COMMON_CONSTS.ZORDER_ERROR + 1, 0)
end

function prober_view:Destroy()
	self.text = nil
	self.error_log = nil
end

function prober_view:Update()
	if nil ~= self.error_log then return end

	self.error_log = MainProber.error_log
	if nil == self.error_log or "" == self.error_log then
		return
	end

	if nil == self.text then
		self:Create()
	end

	self.text:setString(self.error_log)
end

return prober_view
