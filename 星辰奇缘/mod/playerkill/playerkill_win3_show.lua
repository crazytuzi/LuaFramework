-- ------------------------------
-- 擂台3连胜展示
-- hosr
-- ------------------------------
PlayerkillWin3Show = PlayerkillWin3Show or BaseClass()

function PlayerkillWin3Show:__init(parent, callback)
	self.parent = parent
	self.callback = callback
	self.index = 0
end

function PlayerkillWin3Show:__delete()
	self:EndLoop()
	for i,v in ipairs(self.parent.winList) do
		v:NoBoom()
	end
end

function PlayerkillWin3Show:Show()
	self:EndLoop()
	self.timeId = LuaTimer.Add(0, 150, function() self:Loop() end)
end

function PlayerkillWin3Show:EndLoop()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function PlayerkillWin3Show:Loop()
	if self.index == 3 then
		self:EndLoop()
		self:EndShow()
		return
	end

	self.index = self.index + 1
	self.parent.winList[self.index]:Boom()
end

function PlayerkillWin3Show:EndShow()
	if self.callback ~= nil then
		self.callback()
	end
end