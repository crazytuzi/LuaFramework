--[[
聊天中的人
发送者以及公告中的参数
lizhuangzhuang
2014年9月29日16:51:49
]]

_G.ChatRoleVO = {};

function ChatRoleVO:new()
	local obj = {};
	for k,v in pairs(ChatRoleVO) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end

--解析字符串
function ChatRoleVO:ParseStr(str)
	if not str then return; end
	if str=="" then return; end
	--去中括号
	local startIndex = string.find(str,"{");
	if not startIndex then 
		startIndex = 1;
	end
	local endIndex = string.find(str,"}");
	if not endIndex then 
		endIndex = str:len();
	end
	str = string.sub(str,startIndex,endIndex);
	local params = split(str,",");
	self.roleId = params[2];
	self.roleName = params[3];
	self.teamId = params[4];
	self.guildId = params[5];
	self.guildPos = tonumber(params[6]);
	self.vip = tonumber(params[7]);
	self.lvl = tonumber(params[8]);
	self.icon = tonumber(params[9]);
	self.cityPos = tonumber(params[10]);--王城职位
	self.vflag = tonumber(params[11]);
	self.isGM = tonumber(params[12]);
	self.cross = tonumber(params[13]);--跨服
	self.fromChannel = tonumber(params[14]);--来自哪个频道
end

--拷贝我的信息
function ChatRoleVO:CopyMeInfo()
	self.roleId= MainPlayerModel.mainRoleID;
	self.roleName = MainPlayerModel.humanDetailInfo.eaName;
end

function ChatRoleVO:GetID()
	return self.roleId;
end

function ChatRoleVO:GetName()
	return self.roleName;
end

function ChatRoleVO:GetTeamId()
	return self.teamId;
end

function ChatRoleVO:GetGuildId()
	return self.guildId;
end

function ChatRoleVO:GetGuildPos()
	return self.guildPos;
end

function ChatRoleVO:GetVIP()
	return self.vip;
end

function ChatRoleVO:GetLvl()
	return self.lvl;
end

function ChatRoleVO:GetIcon()
	return self.icon;
end

function ChatRoleVO:GetFromChannel()
	return self.fromChannel;
end