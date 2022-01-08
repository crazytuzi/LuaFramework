--[[
客户端本地默认服务器列表，格式：
{
	serverId 		= 1,						--服务器ID
	address 		= '113.107.167.32:8800',	--游戏服登录IP:PORT
	name 			= '外网服务器',  			--区服名称(显示用)，utf8编码
	load 			= 0,						--[int]>0，负载情况(越小越空闲)，=0时无效
	mark			= 2,						--[int][按位取]0:普通;1:新服;2:推荐
}
]]
local defaultServerList = {
	{
		serverId	= 1,
		address 	= '112.74.111.206:8800',
		name 		= '外网服务器', 
		load 		= 0,
		mark		= 2,
	},
	{
		serverId	= 2,
		address 	= '192.168.10.115:8800',
		name 		= '内网服务器',
		load 		= 0,
		mark		= 1,
	},
	{
		serverId	= 3,
		address 	= '192.168.10.100:8800',
		name 		= '戴哥',
		load 		= 0,
		mark		= 0,
	},
	{
		serverId	= 4,
		address 	= '112.74.111.206:8801',
		name 		= '阿里云-研发',
		load 		= 0,
		mark		= 0,
	},
	{
		serverId	= 5,
		address 	= '192.168.10.115:8801',
		name 		= '土匪-研发',
		load 		= 0,
		mark		= 0,
	},
	{
		serverId	= 6,
		address 	= '120.131.3.221:8800',
		name 		= '黑桃-封测版',
		load 		= 0,
		mark		= 0,
	},
	{
		serverId	= 7,
		address 	= '192.168.10.250:8800',
		name 		= 'self',
		load 		= 0,
		mark		= 0,
	}
}
return defaultServerList
