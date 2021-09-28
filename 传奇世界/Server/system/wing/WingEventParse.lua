--WingEventParse.lua
--/*-----------------------------------------------------------------
 --* Module:  WingEventParse.lua
 --* Author:  seezon
 --* Modified: 2014年6月9日
 --* Purpose: Implementation of the class WingEventParse
 -------------------------------------------------------------------*/
 --光翼进阶
CSWINGPROMOTE = {}
--WING_CS_PROMOTE后端读消息
CSWINGPROMOTE.readFun = function(buffer)
	local roleID = buffer:popInt()
	local autoUseYuanbao = buffer:popChar()
	local data = {}
	data[1] = roleID
	data[2] = autoUseYuanbao
	return data
end

--玩家登入发送光翼初始数据
SCWINGLOADDATA = {}
--WING_SC_LOADDATA后端写消息
SCWINGLOADDATA.writeFun = function(roleID, isActive)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(WING_SC_LOADDATA)
    local memInfo = g_wingMgr:getRoleWingInfo(roleID)
    if not memInfo then
		return
    end
    memInfo:getloadData(retBuff, isActive)
	return retBuff
end

 --获取进阶祝福值时限
CSWINGBLESSTIMELIMIT = {}
--WING_CS_BLESS_TIMELIMIT后端读消息
CSWINGBLESSTIMELIMIT.readFun = function(buffer)
	local roleID = buffer:popInt()
	local data = {}
	data[1] = roleID
	return data
end

--获取进阶祝福值时限返回
SCWINGBLESSTIMELIMITRET = {}
--WING_SC_BLESS_TIMELIMIT_RET后端写消息
SCWINGBLESSTIMELIMITRET.writeFun = function(timeLimit)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(WING_SC_BLESS_TIMELIMIT_RET)
	retBuff:pushInt(timeLimit)
	return retBuff
end

 --穿上和取下光翼
CSWINGCHANGSTATE = {}
--WING_CS_CHANG_STATE后端读消息
CSWINGCHANGSTATE.readFun = function(buffer)
	local roleID = buffer:popInt()
	local opType = buffer:popChar()
	local data = {}
	data[1] = roleID
	data[2] = opType
	return data
end


 --客户端获取进阶符价格
CSGETWINGPRICE = {}
--WING_CS_GET_WING_PRICE后端读消息
CSGETWINGPRICE.readFun = function(buffer)
	local roleID = buffer:popInt()
	local data = {}
	data[1] = roleID
	return data
end

--客户端获取进阶符价格返回
SCGETWINGPRICERET = {}
--WING_SC_GET_WING_PRICE_RET后端写消息
SCGETWINGPRICERET.writeFun = function(price)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(WING_SC_GET_WING_PRICE_RET)
	retBuff:pushInt(price)
	return retBuff
end