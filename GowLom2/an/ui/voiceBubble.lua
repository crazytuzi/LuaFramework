local unreadUseW = 20
local voiceBubble = class("an.voiceBubble", function ()
	return display.newNode()
end)

table.merge(slot1, {
	config,
	msgID,
	horn,
	loading,
	err,
	unread
})

voiceBubble.init = function (config)
	voiceBubble.config = config or {}

	for k, v in pairs(config) do
		if type(v) == "userdata" and (tolua.type(v) == "cc.Texture2D" or tolua.type(v) == "cc.Animation") then
			v.retain(v)
		end
	end

	if config.bg then
		for k, v in pairs(config.bg) do
			if type(v) == "userdata" and (tolua.type(v) == "cc.Texture2D" or tolua.type(v) == "cc.Animation") then
				v.retain(v)
			end
		end
	end

	return 
end
voiceBubble.ctor = function (self, h, bgkey, dur, msgID, state, readed)
	assert(self.config, "voiceBubble not inited.")

	local w = math.min(1, dur/60)*80 + 100
	local size = cc.size(w, h)
	self.msgID = msgID

	self.size(self, w + unreadUseW, h)

	local tex = self.config.bg[bgkey] or self.config.bg.default
	local texSize = tex.getContentSize(tex)
	local frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, texSize.width, texSize.height))

	display.newScale9Sprite(frame):anchor(0, 0):size(size):add2(self)
	an.newLabel(" " .. dur .. "''", 16, 1, {
		color = cc.c3b(0, 255, 255)
	}):anchor(1, 0.5):pos(self.getw(self) - unreadUseW - 5, self.geth(self)/2):add2(self)

	self.horn = display.newSprite(self.config.hornAni:getFrames()[1]:getSpriteFrame()):scale((self.geth(self) - 6)/self.config.hornAni:getFrames()[1]:getSpriteFrame():getRect().height):pos(25, self.geth(self)/2):add2(self)

	self.setState(self, state)

	if not readed then
		self.showUnread(self)
	end

	return 
end
voiceBubble.setState = function (self, state)
	if state == "start" then
		self.playHorn(self)
	elseif state == "stop" then
		self.stopHorn(self)
	elseif state == "loading" then
		self.showLoading(self)
	elseif state == "loadOk" then
		self.hideLoading(self)
	elseif state == "loadErr" then
		self.showErr(self)
	end

	return 
end
voiceBubble.playHorn = function (self)
	self.stopHorn(self)
	self.horn:run(cc.RepeatForever:create(cc.Animate:create(self.config.hornAni)))

	return 
end
voiceBubble.stopHorn = function (self)
	self.horn:stopAllActions()
	self.horn:setSpriteFrame(self.config.hornAni:getFrames()[1]:getSpriteFrame())

	return 
end
voiceBubble.showLoading = function (self)
	if not self.loading then
		self.loading = display.newSprite(self.config.loadingAni:getFrames()[1]:getSpriteFrame()):scale((self.geth(self) - 6)/self.config.loadingAni:getFrames()[1]:getSpriteFrame():getRect().height):pos((self.getw(self) - unreadUseW + 5)/2, self.geth(self)/2):add2(self):run(cc.RepeatForever:create(cc.Animate:create(self.config.loadingAni)))
	end

	self.hideErr(self)

	return 
end
voiceBubble.hideLoading = function (self)
	if self.loading then
		self.loading:removeSelf()

		self.loading = nil
	end

	return 
end
voiceBubble.showErr = function (self)
	if not self.err then
		self.err = display.newSprite(self.config.errTex):scale((self.geth(self) - 6)/self.config.errTex:getContentSize().height):pos((self.getw(self) - unreadUseW + 5)/2, self.geth(self)/2):add2(self)
	end

	self.hideLoading(self)

	return 
end
voiceBubble.hideErr = function (self)
	if self.err then
		self.err:removeSelf()

		self.err = nil
	end

	return 
end
voiceBubble.showUnread = function (self)
	if not self.unread then
		self.unread = display.newSprite(self.config.unreadTex):pos(self.getw(self) - 10, self.geth(self)/2):add2(self)
	end

	return 
end
voiceBubble.hideUnread = function (self)
	if self.unread then
		self.unread:removeSelf()

		self.unread = nil
	end

	return 
end

return voiceBubble
