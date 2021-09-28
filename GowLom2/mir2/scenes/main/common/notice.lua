local notice = class("notice", function ()
	return display.newNode()
end)
local common = import(".common")

table.merge(slot0, {
	numRP = 0,
	groupCount = {}
})

notice.ctor = function (self)
	local w = 66
	local h = 66

	self.size(self, w*3, h)

	local deviceFix = 0

	if game.deviceFix then
		deviceFix = game.deviceFix
	end

	self.pos(self, deviceFix + 50, display.height - 50 - h)

	self.mails = nil
	self.msgs = {}
	self.maxLine = 10
	self.btn_mail = an.newBtn(res.gettex2("pic/console/notice/mail.png"), function ()
		self.mails = nil

		self:checkShow()
		main_scene.ui:showPanel("mail", {
			tag = self.mailTag
		})

		return 
	end, {
		pressBig = true
	}).addTo(slot4, self, 1):pos(w/2, h/2):anchor(0.5, 0.5)
	local numbg = res.get2("pic/console/notice/num.png"):addTo(self.btn_mail):pos(self.btn_mail:getw() + 7, self.btn_mail:geth() + 9):anchor(1, 1)
	self.btn_mail.num = an.newLabel("", 16, 1):addTo(numbg):pos(numbg.getw(numbg)/2, numbg.geth(numbg)/2):anchor(0.5, 0.5)
	self.btn_msgs = an.newBtn(res.gettex2("pic/console/notice/icon.png"), function ()
		if 0 < #self.msgs then
			local msg = nil

			repeat
				msg = self.msgs[1]

				if msg then
					table.remove(self.msgs, 1)

					if type(msg.fun) == "function" then
						msg.fun()
						self:checkShow()

						return 
					end
				end
			until not msg

			self:checkShow()
		end

		return 
	end, {
		pressBig = true
	}).addTo(slot5, self, 1):pos(w/2*3, h/2):anchor(0.5, 0.5)
	self.btn_redPacket = an.newBtn(res.gettex2("pic/console/notice/noticeRP.png"), function ()
		self.numRP = 0

		self:checkShow()
		main_scene.ui:showPanel("redPacket")

		return 
	end, {
		pressBig = true
	}).addTo(slot5, self, 1):pos(w/2*5, h/2):anchor(0.5, 0.5)
	local numbgRP = res.get2("pic/console/notice/num.png"):addTo(self.btn_redPacket):pos(self.btn_redPacket:getw() + 7, self.btn_redPacket:geth() + 9):anchor(1, 1)
	self.btn_redPacket.num = an.newLabel("", 16, 1):addTo(numbgRP):pos(numbgRP.getw(numbgRP)/2, numbgRP.geth(numbgRP)/2):anchor(0.5, 0.5)

	self.checkShow(self)

	return 
end
notice.showCustomNotic = function (self, pic, callback)
	if not self.curstomBtn then
		self.curstomBtn = an.newBtn(res.gettex2(pic), function ()
			callback()

			return 
		end, {
			pressBig = true
		}).addTo(slot3, self, 1):pos(231, 33):anchor(0.5, 0.5)

		scheduler.performWithDelayGlobal(function ()
			if self and self.curstomBtn then
				self.curstomBtn:removeSelf()

				self.curstomBtn = nil
			end

			return 
		end, 10)
	end

	self.show(slot0)

	return 
end
notice.checkShow = function (self)
	local w = 66
	local h = 66
	local show = false

	if 0 < #self.msgs then
		self.btn_msgs:show()
		self.btn_msgs:pos(w/2, h/2)

		show = true
	else
		self.btn_msgs:hide()
	end

	if self.mails then
		self.btn_mail:show()
		self.btn_mail:pos(w/2, h/2)
		self.btn_msgs:pos(w/2*3, h/2)

		show = true
	else
		self.btn_mail:hide()
	end

	if self.numRP ~= 0 then
		self.btn_redPacket:show()
		self.btn_redPacket:pos(w/2, h/2)

		if self.mails then
			self.btn_mail:pos(w/2*3, h/2)
			self.btn_msgs:pos(w/2*5, h/2)
		else
			self.btn_msgs:pos(w/2*3, h/2)
		end

		show = true
	else
		self.btn_redPacket:hide()
	end

	if show and not g_data.login:isChangeSkinCheckServer() then
		self.show(self)
	else
		self.hide(self)
	end

	return 
end
notice.uptMailCnt = function (self, cnt, tag)
	self.mails = cnt
	self.mailTag = tag

	self.btn_mail.num:setString(self.mails .. "")
	self.checkShow(self)

	return 
end
notice.removeMailCnt = function (self)
	self.mails = nil

	self.checkShow(self)

	return 
end
notice.uptRPCnt = function (self, cnt, tag)
	self.numRP = cnt

	self.btn_redPacket.num:setString(self.numRP .. "")
	self.checkShow(self)

	return 
end
notice.removeRPCnt = function (self)
	self.numRP = 0

	self.checkShow(self)

	return 
end
notice.addMsg = function (self, funName, msg)
	self.msgs[#self.msgs + 1] = self["add" .. funName](self, msg)
	self.groupCount[msg.FName] = (self.groupCount[msg.FName] or 0) + 1

	self.checkShow(self)

	return 
end
notice.removeMsg = function (self, funName, msg)
	for i, v in ipairs(self.msgs) do
		if self["remove" .. funName](self, v, msg) then
			table.remove(self.msgs, i)
		end
	end

	self.checkShow(self)

	return 
end
notice.addFriendApply = function (self, msg)
	local function funOld()
		local info = {
			[0] = " 请求加入您的队伍！",
			" 请求添加您为好友，是否同意？"
		}
		local name = msg.FName
		local id = msg.FUserId
		local cmd = info[msg.FMsgType]

		local function reply(idx)
			local rsb = DefaultClientMessage(CM_ReplyRequestMessage)
			rsb.FAgree = idx == 2
			rsb.FMsgType = msg.FMsgType
			rsb.FUserId = msg.FUserId

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end

		local msgbox = an.newMsgbox(slot1 .. cmd, function (idx)
			if idx == 1 then
				reply(2)
			else
				reply(1)
			end

			return 
		end, {
			manualRemoved = true,
			btnTexts = {
				"同  意",
				"拒  绝"
			}
		})

		return 
	end

	local function fun()
		if main_scene.ui.panels.relation then
			main_scene.ui:togglePanel("relation")
		end

		main_scene.ui:showPanel("relation", 5)

		return 
	end

	g_data.relation.addRequest(slot4, msg)

	return {
		fun = fun,
		name = msg.FName,
		cmd = msg.FMsgType
	}
end
notice.addgroupApply = function (self, msg)
	local function fun()
		local info = {
			[0] = " 请求加入您的队伍！",
			" 请求添加您为好友，是否同意？"
		}
		local name = msg.FName
		local cmd = info[msg.FMsgType]

		local function reply(idx)
			local rsb = DefaultClientMessage(CM_ReplyRequestMessage)
			rsb.FAgree = idx == 2
			rsb.FMsgType = msg.FMsgType
			rsb.FUserId = msg.FUserId

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end

		local msgbox = an.newMsgbox(slot1 .. cmd, function (idx)
			if idx == 1 then
				reply(2)
			else
				reply(1)
			end

			return 
		end, {
			manualRemoved = true,
			btnTexts = {
				"同  意",
				"拒  绝"
			}
		})

		return 
	end

	return {
		fun = fun,
		name = msg.FName,
		cmd = msg.FMsgType
	}
end
notice.removeFriendApply = function (self, listMsg, msg)
	if listMsg.name and listMsg.name == msg.FName and listMsg.cmd and listMsg.cmd == msg.FMsgType then
		return true
	end

	return false
end
notice.removegroupApply = function (self, listMsg, msg)
	if listMsg.name and listMsg.name == msg.FName and listMsg.cmd and listMsg.cmd == msg.FMsgType then
		return true
	end

	return false
end
notice.checkGroup = function (self, result)
	if self.groupCount[result.FName] and 1 < self.groupCount[result.FName] then
		self.groupCount[result.FName] = self.groupCount[result.FName] - 1

		scheduler.performWithDelayGlobal(function ()
			self:checkGroup(result.FName)

			return 
		end, 10)
	else
		self.removeMsg(slot0, "groupApply", result)
	end

	return 
end

return notice
