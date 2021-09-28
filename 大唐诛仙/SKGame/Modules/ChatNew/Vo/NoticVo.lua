 NoticVo =BaseClass(ChatBaseVo)

function NoticVo:__init(data)
	self.msgId = data.msgId --消息ID	
	self.msgContent = data.msgContent --消息内容
	self.type = 0 --消息类型(类型说明 0:喇叭,1:世界,2:工会,3:组队,4:私人,5:系统,6:附近)
	self.isRollMsg = false
	self.params = {}
	self.isNotic = true

	if data.param and data.param ~= "" then
		local paramT = StringToTable(data.param)
		for i = 1, #paramT do
			local param = {}
			param.type = tonumber(paramT[i][1])
			param.paramInt = tonumber(paramT[i][2])
			param.paramInt2 = tonumber(paramT[i][3])
			param.paramStr = paramT[i][4]
			table.insert(self.params, param)
		end
	end

	self.content = ""
	self.cfg = GetCfgData("notice"):Get(self.msgId)
	if self.cfg then
		self.content = self.cfg.msgContent
		self.content2 = self.cfg.msgContent or ""
		self.type = self.cfg.chatChannel
		self.isRollMsg = self.cfg.isBroadcast == 1
		ChatVo.ParseParam(self)
	else
		self.content = self.msgContent
		self.content2 = self.msgContent or ""
		self.type = ChatNewModel.Channel.System
		self.isRollMsg = true
	end
	self.content2 = "[color="..ChatNewModel.ChannelColor[self.type].."]"..self.content2.."[/color]"
end
