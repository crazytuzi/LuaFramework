--RelationEventParse.lua
--/*-----------------------------------------------------------------
 --* Module:  RelationEventParse.lua
 --* Author:  seezon
 --* Modified: 2014年4月22日
 --* Purpose: Implementation of the class RelationEventParse
 -------------------------------------------------------------------*/

--赠花
CSGIVEFLOWER = {}
--RELATION_CS_GIVEFLOWER前端写消息
--params:roleID，targetName（目标名字）
CSGIVEFLOWER.writeFun = function(roleID, targetSid, targetName, giveFlowerStyle)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(RELATION_CS_GIVEFLOWER)
	retBuff:pushInt(roleID)
    retBuff:pushInt(targetSid)
	retBuff:pushString(targetName)
    retBuff:pushChar(giveFlowerStyle)
	return retBuff
end

--RELATION_CS_GIVEFLOWER后端读消息
CSGIVEFLOWER.readFun = function(buffer)
	local roleID = buffer:popInt()
    local targetSid = buffer:popInt()
	local targetName = buffer:popString()
    local giveFlowerStyle = buffer:popChar()
	local data = {}
	data[1] = roleID
    data[2] = targetSid
    data[3] = targetName
    data[4] = giveFlowerStyle
	return data
end

--赠花返回
SCGIVEFLOWERRET = {}
--RELATION_SC_GIVEFLOWER_RET后端写消息
--params:ret(结果)
SCGIVEFLOWERRET.writeFun = function(giveFlowerStyle)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(RELATION_SC_GIVEFLOWER_RET)
    retBuff:pushChar(giveFlowerStyle)
	return retBuff
end


--查看赠花记录
CSFLOWERRECORD = {}
--RELATION_CS_FLOWERRECORD前端写消息
--params:roleID
CSFLOWERRECORD.writeFun = function(roleID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(RELATION_CS_FLOWERRECORD)
	retBuff:pushInt(roleID)
	return retBuff
end

--RELATION_CS_FLOWERRECORD后端读消息
CSFLOWERRECORD.readFun = function(buffer)
	local roleID = buffer:popInt()
	return roleID
end



--查看赠花记录返回
SCFLOWERRECORDRET = {}

--RELATION_SC_FLOWERRECORD_RET后端读消息
SCFLOWERRECORDRET.readFun = function(buffer)
	local rNum = buffer:popChar()
    local records = {}
    for i=1,rNum do
        local record = {}
        record.giveTime = buffer:popInt()
        record.sourceRoleName = buffer:popString()
        record.targetRoleName = buffer:popString()
        record.giveFlowerStyle = buffer:popChar()
        table.insert(records, record)
    end
	return records
end


