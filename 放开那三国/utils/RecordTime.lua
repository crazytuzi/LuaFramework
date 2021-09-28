-- FileName: RecodTime.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]


local _timeMap = {}
--[[
	@des:计时方法
--]]
function RecordTime( pTag, pType )
    local index = nil
    for k,v in pairs(_timeMap) do
        if v.tag == pTag then
            index = k
        end
    end
    if index == nil then
        local timeInfo = {}
        timeInfo.tag = pTag
        timeInfo.lastTime = os.clock()
        table.insert(_timeMap, timeInfo)
    else
        if _timeMap[index].deltTime == nil then
            _timeMap[index].deltTime =os.clock() - _timeMap[index].lastTime
        else
            if pType == 0 then
                _timeMap[index].lastTime = os.clock()
            else
                _timeMap[index].deltTime = _timeMap[index].deltTime + (os.clock() - _timeMap[index].lastTime)
            end
        end
    end
end

--[[
	@des:清除所有计时
--]]
function clearRecordTime()
	_timeMap = {}
end

--[[
	@des:打印记录
--]]
function printRecordTime()
    print("-------------------[RecordTime]-------------------")
    local times = table.sort(_timeMap, function ( h1, h2 )
        if h1.deltTime > h2.deltTime then
            return true
        else
            return false
        end
    end)
    print_t(_timeMap)
end

--[[
	@des:打印单条记录
--]]
function printRecordByTag( pTag )
    local timeInfo = nil
    for k,v in pairs(_timeMap) do
        if v.tag == pTag then
            timeInfo = v
        end
    end
    if timeInfo then
        print("TIME_TEST :"..pTag.."["..timeInfo.deltTime.."]")
    end
end