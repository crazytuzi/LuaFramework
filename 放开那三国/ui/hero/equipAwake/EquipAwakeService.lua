-- Filename: EquipAwakeService.lua
-- Author: FQQ
-- Date: 2016-01-05
-- Purpose:装备觉醒网络层

module ("EquipAwakeService",package.seeall)

-- /**
--     * 激活主角天赋
--     * @param $index int 天赋装配的位置 从1开始 1,2...
--     * @param $talentId int 天赋id
--     * @return string 'ok'
--     */

function activeMasterTalent( index, talentId, pCallback )
    local requestFunc = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
    local args = CCArray:create()
    args:addObject(CCInteger:create(index))
    args:addObject(CCInteger:create(talentId))
    Network.rpc(requestFunc,"hero.activeMasterTalent","hero.activeMasterTalent",args,true)
end

-- /**
--      * 主角可装备的天赋
--      * @return array
--      * [
--      *  $time(时间戳) => $talentId(天赋id)
--      * ]
--      */
function getArrMasterTalent(pCallback)
    local requestFunc = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
    Network.rpc(requestFunc,"athena.getArrMasterTalent","athena.getArrMasterTalent",nil,true)
end

