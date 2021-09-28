-- Filename：	GuildImpl.lua
-- Author：		Cheng Liang
-- Date：		2013-12-18
-- Purpose：		获取军团信息，是否跳转


module("GuildImpl", package.seeall)

local funTable = {} -- 注册关闭二级以上界面回调  

local function init()

end

-- 获取军团列表
function getGuildListCallback(  cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		
	end
end

-- 创建军团
function createGuildCallback(  cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		
	end
end

-- 自己的军团信息
function memberInfoCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		require "script/ui/guild/GuildDataCache"
		GuildDataCache.setMineSigleGuildInfo(dictData.ret)
		
		if( (not table.isEmpty(dictData.ret)) and (dictData.ret.guild_id ~= nil) and tonumber(dictData.ret.guild_id) > 0 ) then
			-- 已经加入军团
			require "script/ui/guild/GuildMainLayer"
			local guildMainLayer = GuildMainLayer.createLayer(true)
			MainScene.changeLayer(guildMainLayer, "guildMainLayer")
		else
			-- 没有加入军团
			require "script/ui/guild/GuildListLayer"
			local guildListLayer = GuildListLayer.createLayer(false)
			MainScene.changeLayer(guildListLayer, "guildListLayer")

			-- 用于删除被T出军团时打开的二级界面
			callBackFun()
		end
	end

end

-- 
function showLayer()
	RequestCenter.guild_getMemberInfo(memberInfoCallback)
end

-- 跳转回调 
function callBackFun( ... )
	-- 遍历回调方法
	print("funTable ** ")
	print_t(funTable)
	for k,v in pairs(funTable) do
		if(v ~= nil)then
			v()
		end
	end
end

-- 注册 跳转删除回调 add by licong
function registerCallBackFun( key, callFun )
	funTable[key] = callFun
end







