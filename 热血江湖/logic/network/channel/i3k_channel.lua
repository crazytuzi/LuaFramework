------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_global");
require("logic/network/channel/i3k_channel_def");

------------------------------------------------------
i3k_net_channel = i3k_class("i3k_net_channel");
function i3k_net_channel:ctor()
	self._channel	= "none";
	self._onSend	= nil;
	self._onProc	= nil;
	self._cmds		= { };
end

function i3k_net_channel:RegisterCmd(cmd)
	if cmd and self._cmds then
		self._cmds[cmd:GetCmdName()] = cmd;
	end
end

function i3k_net_channel:SendCmd(...)
	local arg = { ... };

	local cmd = arg[1];

	local hdr = self._cmds[cmd]
	if hdr then
		return hdr:SendCmd(...);
	end

	return false;
end

function i3k_net_channel:ProcCmd(args)
	local cmd = args:pop_str();

	local hdr = self._cmds[cmd]
	if hdr then
		return hdr:ProcCmd(args);
	end

	return false;
end

function i3k_net_channel:GetChannelName()
	return self._channel;
end


-------------------------------------------------------
i3k_net_channel_cmd = i3k_class("i3k_net_channel_cmd");
function i3k_net_channel_cmd:ctor()
	self._cmd	= "none";
	self._cmds	= { };
end

function i3k_net_channel_cmd:SendCmd(...)
	return false;
end

function i3k_net_channel_cmd:ProcCmd(args)
	local cmd = args:pop_str();

	local hdr = self._cmds[cmd]
	if hdr then
		return hdr:ProcCmd(args);
	end

	return false;
end

function i3k_net_channel_cmd:GetCmdName()
	return self._cmd;
end

function i3k_net_channel_cmd:RegisterCmd(cmd)
	if cmd and self._cmds then
		self._cmds[cmd:GetCmdName()] = cmd;
	end
end
