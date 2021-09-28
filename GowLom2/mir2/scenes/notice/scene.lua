local common = import("..main.common.common")
local scene = class("notice", function ()
	return display.newScene("notice")
end)
local notice35Data = def.notice35
local notice0Data = def.notice0

table.merge(slot1, {
	submitting
})

scene.ctor = function (self)
	g_data.login:setLoginState(GameStateType.notice)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Notice, self, self.onSM_Notice)

	return 
end
scene.showNotice = function (self, text)
	local bg = res.get2("pic/notice/bg.png"):center():addto(self)

	if device.platform == "ios" and not g_data.login.hasCheckServer then
		local msg = "官网：fgcq.3975.com \n公众号：fgcq39"

		an.newLabel(msg, 15, 1, {
			color = def.colors.clWhite
		}):add2(self):pos(display.cx, display.cy + 165):anchor(0.5, 0.5)
	end

	local scroll = an.newScroll(0, 0, 250, 245, {
		labelM = {
			15,
			1
		}
	}):anchor(0.5, 0.5):pos(display.cx, display.cy + 20):addTo(self)
	local strs = string.split(text, "\\n")

	for i, v in ipairs(strs) do
		if 5 < i then
			scroll.labelM:nextLine():addLabel(string.trim(v), def.colors.clWhite)
		end
	end

	local function getNoticeText(level)
		local notices = {}

		if 35 < level then
			notices = notice35Data
		else
			notices = notice0Data
		end

		local id = math.random(#notices)

		if notices[id] then
			return notices[id].notice_text
		end

		return ""
	end

	local noticeFontSize = 24
	local text = slot5(g_data.select:getCurLevel())
	local color = cc.c3b(222, 222, 150)

	an.newLabel(text, noticeFontSize, 2, {
		color = color
	}):addTo(self):pos(display.cx, display.height - 50):anchor(0.5, 0.5)

	local function callback()
		if self.submitting then
			return 
		end

		self.submitting = true

		sound.playSound("104")

		if MirTcpClient:getInstance():isConnected() == false then
			an.newMsgbox("服务器正在维护中，请稍后重试！", function ()
				common.gotoLogin()

				return 
			end, {
				center = true
			})

			return 
		end

		if g_data.setting.base.highFrame then
			cc.Director.getInstance(self):setAnimationInterval(0.016666666666666666)
		else
			cc.Director:getInstance():setAnimationInterval(0.03333333333333333)
		end

		game.gotoscene("main", nil, "fade", 0.5, display.COLOR_BLACK)

		local rsb = DefaultClientMessage(CM_INITOK)

		MirTcpClient:getInstance():postRsb(rsb)

		return 
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), slot9, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/common/confirm.png")
	}):pos(display.cx, display.cy - 140):addto(self)

	if g_data.login:isChangeSkinCheckServer() then
		local children = self.getChildren(self)

		for k, v in pairs(children) do
			v.setVisible(v, false)
		end

		self.runs(self, {
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function ()
				callback()

				return 
			end)
		})
	end

	return 
end
scene.onEnter = function (self)
	p2("res", "notice.scene:onEnter res.purgeCachedData")
	res.purgeCachedData()

	return 
end
scene.onExit = function (self)
	return 
end
scene.reconectFuc = function (self, info)
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	if not self.reconnectBox then
		self.reconnectBox = an.newMsgbox(info .. "\n确定重连?", function (idx)
			if idx == 0 then
				common.gotoLogin({
					logout = true
				})
			elseif idx == 1 then
				self.reconnect = true
				g_data.login.reconnectState = true

				scheduler.performWithDelayGlobal(function ()
					return 
				end, 0)
			end

			self.reconnectBox = nil

			return 
		end, {
			center = true,
			hasCancel = true
		})
	end

	return 
end
scene.onLoseConnect = function (self)
	print("scene:onLoseConnect")

	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	self.reconnectBox = self.reconectFuc(self, "网络连接已断开!")

	return 
end
scene.onNetworkStateChange = function (self, currentState)
	local connectable = network.isHostNameReachable("www.baidu.com")

	if not tolua.isnull(self.reconnectBox) then
		if connectable then
			self.reconnectBox:removeSelf()

			self.reconnectBox = nil
		else
			return 
		end
	end

	if connectable then
		self.reconectFuc(self, "切换到 " .. ((currentState == cc.kCCNetworkStatusReachableViaWiFi and "WIFI网络") or "蜂窝网络"))
	end

	return 
end
scene.onSM_Notice = function (self, result, proIc)
	if result then
		self.showNotice(self, result.FContent)
	end

	return 
end

return scene
