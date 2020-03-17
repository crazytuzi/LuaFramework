--[[
GM监控聊天
lizhuangzhuang
2015年10月15日17:35:52
]]

_G.GMChatVO = {};

function GMChatVO:new()
	local obj = {};
	for k,v in pairs(GMChatVO) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end

GMChatVO.channel = 0;
GMChatVO.text = "";
GMChatVO.hornId = "";


function GMChatVO:SetData(msg)
	self.channel = msg.channel;
	self.hornId = msg.hornId;
	self.sendTime = msg.sendTime;
	--
	self.text = "";
	local text = "";
	local senderStr = string.format("{0,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,0}:",
						msg.senderID,msg.senderName,msg.senderTeamId,msg.senderGuildId,msg.senderGuildPos,
						msg.senderVIP,msg.senderLvl,msg.senderIcon,msg.senderCityPos,msg.senderVflag,msg.senderIsGM);
	if msg.toID~="0_0" and msg.toID~=msg.senderID then
		local toStr = string.format("{0,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,0}:",
						msg.toID,msg.toName,msg.toTeamId,msg.toGuildId,msg.toGuildPos,
						msg.toVIP,msg.toLvl,msg.toIcon,msg.toFlag,msg.toCityPos,msg.toVflag,msg.toIsGM);
		text = senderStr .. StrConfig["gm024"] .. toStr .. msg.text;
	else
		text = senderStr .. msg.text;
	end
	text = string.gsub(text,"{[^{}]+}",
		function(pattern)
			local paramStr = string.sub(pattern,2,#pattern-1);--去大括号
			local params = split(paramStr,",");
			if #params <= 0 then return pattern; end
			local type = toint(params[1]);
			local parseClass = ChatConsts.ChatParamMap[type];
			if not parseClass then
				Debug('Error:Chat cannot find param parse class.');
				return pattern;
			end 
			local parser = parseClass:new();
			return parser:DecodeToText(paramStr,true);
		end);
	--
	local str = "<font color='"..ChatConsts:GetChannelColor(self.channel).."'>";
	if self.channel == ChatConsts.Channel_Horn then
		str = str .. StrConfig["gm025"];
	elseif self.channel ~= ChatConsts.Channel_Private then
		str = str .. "<img src='img://resfile/icon/chat_ch_" ..self.channel.. ".png'/>";
	end
	self.text = str .. text .. "</font>"
end