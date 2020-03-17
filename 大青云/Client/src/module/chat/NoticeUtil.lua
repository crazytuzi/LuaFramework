--[[
公告解析类
lizhuangzhuang
2014年9月17日22:34:10
]]
_G.classlist['NoticeUtil'] = 'NoticeUtil'
_G.NoticeUtil = {};
NoticeUtil.objName = 'NoticeUtil'
--获取公告文本
function NoticeUtil:GetNoticeStr(id,paramlistStr)
	local cfg = t_notice[id];
	if not cfg then return ""; end
	local text = cfg.text;
	if text == "" then return text; end
	text = self:ParseNoticeParam(text,paramlistStr,false);
	return text;
end

--获取公告在聊天中的显示文本
function NoticeUtil:GetNoticeStrAtChat(id,paramlistStr)
	local cfg = t_notice[id];
	if not cfg then return ""; end
	local text = cfg.prefix .. cfg.text;--补前缀
	if text=="" then return text; end
	--补链接
	if cfg.link ~= "" then
		local serverSend = false;
		local paramlist = split(paramlistStr,"#");
		if paramlistStr == "" then
			paramlistStr = paramlistStr .. tostring(ChatConsts.ChatParam_Link);
		else
			local lastParamStr = paramlist[#paramlist];
			local paramArr = split(lastParamStr,",");
			if #paramArr>0 and toint(paramArr[1])~=ChatConsts.ChatParam_Link then
				paramlistStr = paramlistStr .. "#" .. tostring(ChatConsts.ChatParam_Link);
			else
				--最后一个是服务器发来的脚本参数,在此基础上继续补全
				serverSend = true;
			end
		end
		paramlistStr = paramlistStr .. ",text=" .. cfg.link;
		if cfg.linkScript ~= "" then 
			paramlistStr = paramlistStr .. ",script=" .. cfg.linkScript;
		end
		if cfg.linkParam ~= "" then
			paramlistStr = paramlistStr .. ",t_param=" .. cfg.linkParam;
		end
		if serverSend then
			text = text .. "{" .. #paramlist .."}";
		else
			text = text .. "{" .. #paramlist+1 .."}";
		end
	end
	text = self:ParseNoticeParam(text,paramlistStr,true);
	return text;
end

--解析公告参数
function NoticeUtil:ParseNoticeParam(text,paramlistStr,withLink)
	local paramlist = split(paramlistStr,"#");
	--匹配参数
	text = string.gsub(text,"{[1-9a-z,]+}",
		function(pattern)
			local hasLink = withLink;
			local nolink = string.find(pattern,"nolink");--判断表里是不是配置了不要链接
			if nolink and nolink>-1 then hasLink=false; end
			local patternStr = string.sub(pattern,2,#pattern-1);--去大括号
			local patternParams = split(patternStr,",");--拆分配表中的模式
			if #patternParams <= 0 then return pattern; end
			local index = toint(patternParams[1]);--参数索引
			local paramStr = paramlist[index];--模式对应的参数
			if not paramStr then return pattern; end
			local type = self:GetParamStrType(paramStr);
			local parseClass = ChatConsts.ChatParamMap[type];
			if not parseClass then
				Debug('Error:Notice cannot find param parse class.');
				return pattern;
			end
			local parser = parseClass:new();
			return parser:DecodeToText(paramStr,hasLink);
		end);
	return text;
end

--解析自定义内容公告
function NoticeUtil:ParseContentNotice(text,withLink)
	text = string.gsub(text,"{[^{}]+}",
		function(pattern)
			local paramStr = string.sub(pattern,2,#pattern-1);--去大括号
			local type = self:GetParamStrType(paramStr);
			local parseClass = ChatConsts.ChatParamMap[type];
			if not parseClass then
				Debug('Error:Notice cannot find param parse class.');
				return pattern;
			end
			local parser = parseClass:new();
			return parser:DecodeToText(paramStr,withLink);
		end);
	return text;
end

--获取系统通知文本
function NoticeUtil:GetSysNoticeStr(id,paramlistStr)
	local cfg = t_sysnotice[id];
	if not cfg then return ""; end
	local text = cfg.text;
	if text == "" then return; end
	text = self:ParseNoticeParam(text,paramlistStr,false);
	return text;
end

--获取系统通知在聊天中的文本
function NoticeUtil:GetSysNoticeStrAtChat(id,paramlistStr)
	local cfg = t_sysnotice[id];
	if not cfg then return""; end
	local text = cfg.prefix .. cfg.text;--补前缀
	if text=="" then return text; end
	text = self:ParseNoticeParam(text,paramlistStr,true);
	return text;
end


--获取ParamStr的类型
function NoticeUtil:GetParamStrType(paramStr)
	local list = split(paramStr,",");
	if #list <= 0 then return 0; end
	return toint(list[1]);
end