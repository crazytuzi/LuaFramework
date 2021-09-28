local chat = {
	curHistory = 1,
	maxHistory = 10,
	shieldMask = 1,
	msgs = {},
	sendMsgsHistory = {},
	style = {
		target = "",
		channel = "附近",
		input = "keyboard"
	},
	addMsg = function (self, data, color, bgColor, fromClient, user, targetName, ident)
		local msg = {
			data = data,
			color = color,
			bgColor = bgColor,
			fromClient = fromClient,
			ident = ident,
			channel = self.getChannel(self, msg),
			target = targetName,
			user = user or msg.target
		}
		self.msgs[#self.msgs + 1] = msg

		if 50 < #self.msgs then
			table.remove(self.msgs, 1)
		end

		return msg
	end,
	resetHistoryFlag = function (self)
		self.curHistory = 1

		return 
	end,
	getSendMsgHistory = function (self)
		if #self.sendMsgsHistory < self.curHistory then
			self.curHistory = 1
		end

		local idx = self.curHistory
		self.curHistory = self.curHistory + 1

		return self.sendMsgsHistory[idx]
	end,
	addSendMsgHistroy = function (self, msg)
		if string.find(msg, "{") and string.find(msg, "}") and string.find(msg, "#") then
			print("chat:addSendMsgHistroy：检测到富文本编码,不予记录")

			return 
		end

		local tmp = nil
		local endIndx = math.max(#self.sendMsgsHistory, 1)

		for i = endIndx, 1, -1 do
			if i < self.maxHistory then
				self.sendMsgsHistory[i + 1] = self.sendMsgsHistory[i]
			end
		end

		self.sendMsgsHistory[1] = msg

		self.resetHistoryFlag(self)

		return 
	end,
	getChannel = function (self, msg)
		if msg.ident == "near" then
			return "附近"
		elseif msg.ident == "whisper" then
			return "私聊"
		elseif msg.ident == "team" then
			return "组队"
		elseif msg.ident == "loudspeaker" then
			return "喊话"
		elseif msg.ident == "gild" then
			return "行会"
		elseif msg.ident == "system" then
			return "系统"
		elseif msg.ident == "voiceTransfer" then
			return "千里传音"
		end

		return "未知频道"
	end,
	getMsgs = function (self, name, maxLine)
		local ret = {}

		for i = #self.msgs, 1, -1 do
			local msg = self.msgs[i]

			if type(name) == "string" then
				if name == "全部" or msg.channel == name then
					table.insert(ret, 1, msg)
				end
			else
				local channel = self.getChannel(self, msg)

				for i, v in ipairs(name) do
					if v == channel then
						table.insert(ret, 1, msg)

						break
					end
				end
			end

			if maxLine <= #ret then
				break
			end
		end

		return ret
	end,
	getMsgWithMsgID = function (self, msgID, type)
		for i, v in ipairs(self.msgs) do
			for i2, v2 in ipairs(v.data) do
				if v2.type == type and v2.msgID == msgID then
					return v
				end
			end
		end

		return 
	end,
	uptVoiceMsgState = function (self, msgID, state, readed)
		for i, v in ipairs(self.msgs) do
			for i2, v2 in ipairs(v.data) do
				if v2.type == "voice" and v2.msgID == msgID then
					v2.state = state
					v2.readed = v2.readed or readed

					break
				end
			end
		end

		return 
	end,
	setVoiceReaded = function (self, msg)
		for i, v in ipairs(msg.data) do
			if v.type == "voice" then
				v.readed = true

				break
			end
		end

		return 
	end,
	setPicLoaded = function (self, msg)
		for i, v in ipairs(msg.data) do
			if v.type == "pic" then
				v.state = "loadOk"

				break
			end
		end

		return 
	end,
	uptPicMsgState = function (self, msgID, state)
		for i, v in ipairs(self.msgs) do
			for i2, v2 in ipairs(v.data) do
				if v2.type == "pic" and v2.msgID == msgID then
					v2.state = state

					break
				end
			end
		end

		return 
	end,
	uptItemMsgData = function (self, data)
		for i, v in ipairs(self.msgs) do
			for i2, v2 in ipairs(v.data) do
				if v2.type == "item" and v2.makeIndex == data.FItemIdent then
					v2.itemData = data

					return true
				end
			end
		end

		return 
	end,
	setStyle = function (self, key, value)
		self.style[key] = value

		return 
	end,
	getSayText = function (self, str)
		if self.style.channel == "喊话" then
			str = "!" .. str
		end

		return str
	end,
	getChannelIndx = function (self)
		local channelText = {
			组队 = 3,
			喊话 = 5,
			私聊 = 0,
			千里传音 = 6,
			行会 = 1,
			附近 = 4
		}

		return channelText[self.style.channel]
	end,
	setShieldMask = function (self, s)
		self.shieldMask = s

		return 
	end
}

return chat
