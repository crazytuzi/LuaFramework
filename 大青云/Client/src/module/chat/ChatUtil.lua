--[[
聊天Util
lizhuangzhuang
2014年9月22日20:08:52
]]
_G.classlist['ChatUtil'] = 'ChatUtil'
_G.ChatUtil = {};
ChatUtil.objName = 'ChatUtil'
--初始化屏蔽字
function ChatUtil:InitFilter()
	if self.filter then return; end
	self.filter = _Filter.new();
	self.filter:addFile("config\\chat\\filter.flt")
	self.filter.divided = true;
	self.filter.replacer = "***";
end

--解析聊天
function ChatUtil:ParseChatMsg(msg)
	local chatVO = ChatVO:new();
	chatVO.channel = msg.channel;
	chatVO.hornId = msg.hornId;
	local corss = msg.channel==ChatConsts.Channel_Cross and 1 or 0;
	local paramStr = string.format("{0,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s}:",
						msg.senderID,msg.senderName,msg.senderTeamId,msg.senderGuildId,msg.senderGuildPos,
						msg.senderVIP,msg.senderLvl,msg.senderIcon,msg.senderCityPos,msg.senderVflag,msg.senderIsGM,corss,
						msg.channel);
	local senderVO = ChatRoleVO:new();
	senderVO:ParseStr(paramStr);
	chatVO:SetSenderInfo(senderVO);
	local text = msg.text;
	--私聊频道不显示人名
	if msg.channel ~= ChatConsts.Channel_Private then
		text = paramStr .. text;
	end
	--解析参数
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
	chatVO:SetText(text);
	return chatVO;
end

--过滤输入
function ChatUtil:FilterInput(text)
	--过滤非法字符
	local str = string.gsub(text,ChatConsts.InputReg,"*");
	--过滤回车,保留最后一个
	local returnStr = nil;
	local hasEnter = false;--是否有回车
	if str:tail("\r") then
		returnStr = string.sub(str,str:len(),str:len());
		str = string.sub(str,1,str:len()-1);
	end
	str = string.gsub(str,"\r",function()
		hasEnter = true;
		return "";
	end);
	if returnStr then
		str = str .. returnStr;
	end
	return str,hasEnter;
end

--过滤发送聊天
function ChatUtil:FilterSend(text)
	if not self.filter then return text; end
	--{}内的东西不做屏蔽
	-- local paramlist = {};
	-- text = string.gsub(text,"{[^{}]*}",
		-- function(pattern)
			-- table.push(paramlist,pattern);
			-- return "{}";
		-- end);
	text = self.filter:filter(text);
	--还原参数
	-- text = string.gsub(text,"{[^{}]*}",
		-- function(pattern)
			-- if #paramlist > 0 then
				-- return table.remove(paramlist,1);
			-- else
				-- return pattern;
			-- end
		-- end);
	--表情
	text = string.gsub(text,"%[[^%[%]]+%]",
		function(pattern)
			for i,vo in ipairs(ChatConsts.Face) do
				if vo.key == pattern then
					if vo.vip and not VipController:VIPFace() then
						return "***";
					end
					return pattern;
				end
			end
		end);
	return text;
end

--过滤接收聊天(转义表情)
function ChatUtil:FilterReceive(text)
	text = string.gsub(text,"%[[^%[%]]+%]",
		function(pattern)
			for i,vo in ipairs(ChatConsts.Face) do
				if vo.key == pattern then
					return vo.url;
				end
			end
		end);
	return text;
end

--检查输入内容的长度
--最后一个是回车保留
function ChatUtil:CheckInputLength(text,maxLen)
	if not maxLen then
		maxLen = ChatConsts.MaxInputNum;
	end
	local i = 1;
    local len = 0;
    local strLen = text:len()
    while i <= strLen do
        local v = string.byte(text, i, i)
        if type(v) == "number" then
            if v >= 128 then
                i = i + 3
                len = len + 2
            else
                i = i + 1
                len = len + 1
            end
        end
		if len >= maxLen then
			if string.sub(text,i,i) == "\r" then
				text = string.sub(text,1,i);
			else
				text = string.sub(text,1,i-1);
			end
			break;
		end
    end
    return text,len
end

--获取在聊天列表里显示的频道
function ChatUtil:GetShowChannels(isInput)
	local list = {};
	local alwaysShow = nil;
	if isInput then
		alwaysShow = {ChatConsts.Channel_World}--,ChatConsts.Channel_Cross};
	else
		alwaysShow = {ChatConsts.Channel_All,ChatConsts.Channel_World}; --,ChatConsts.Channel_Cross
	end
	for index,channel in ipairs(alwaysShow) do
		local vo = {};
		vo.channel = channel;
		vo.name = ChatConsts:GetChannelName(channel);
		vo.state = 1;
		table.push(list,vo);
	end
	--关闭跨服
	if not isInput then
		local vo = {};
		vo.channel = ChatConsts.Channel_Cross;
		vo.name = ChatConsts:GetChannelName(ChatConsts.Channel_Cross);
		vo.state = 0;
		table.push(list,vo)
	end
	-- 帮派
	local vo = {};
	vo.channel = ChatConsts.Channel_Guild;
	vo.name = ChatConsts:GetChannelName(ChatConsts.Channel_Guild);
	vo.state = UnionUtils:CheckMyUnion() and 1 or 0;
	if vo.state == 1 then
		table.push(list,vo);
	else
		if not isInput then
			table.push(list,vo);
		end
	end
	-- 阵营
	local vo = {};
	vo.channel = ChatConsts.Channel_Camp;
	vo.name = ChatConsts:GetChannelName(ChatConsts.Channel_Camp);
	vo.state = ChatModel.campOpen and 1 or 0;
	if vo.state == 1 then
		table.push(list,vo);
		if not isInput then
			self:AddSystemChannel(list);
		end
		return list;--有阵营时不要组队
	end
	--组队
	local vo = {};
	vo.channel = ChatConsts.Channel_Team;
	vo.name = ChatConsts:GetChannelName(ChatConsts.Channel_Team);
	vo.state = TeamModel:IsInTeam() and 1 or 0;
	if vo.state == 1 then
		table.push(list,vo);
	else
		if not isInput then
			table.push(list,vo);
		end
	end
	--系统
	if not isInput then
		self:AddSystemChannel(list);
	end
	return list;
end

function ChatUtil:GetCrossSeverChannels()
	local list = {}
	local alwaysShow = {ChatConsts.Channel_Cross_Map, ChatConsts.Channel_Cross_Server}--区域--本服
	-- local alwaysGrey = {ChatConsts.Channel_World, ChatConsts.Channel_Guild, ChatConsts.Channel_Team}
	local alwaysGrey = {}
	for index, channel in ipairs(alwaysShow) do
		local vo = {};
		vo.channel = channel
		vo.name = ChatConsts:GetChannelName(channel)
		vo.state = 1
		table.push(list,vo)
	end
	for index, channel in ipairs(alwaysGrey) do
		local vo = {};
		vo.channel = channel
		vo.name = ChatConsts:GetChannelName(channel)
		vo.state = 0
		table.push(list,vo)
	end
	return list
end

--添加系统频道
function ChatUtil:AddSystemChannel(list)
	local vo = {};
	vo.channel = ChatConsts.Channel_System;
	vo.name = ChatConsts:GetChannelName(ChatConsts.Channel_System);
	vo.state = 1;
	table.push(list,vo);
end
