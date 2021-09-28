-- FileName : StageEnhanceService.lua
-- Author   : YangRui
-- Date     : 2015-12-07
-- Purpose  : 

module("StageEnhanceService", package.seeall)

require "script/ui/formation/secondfriend/stageenhance/StageEnhanceData"

-- /**
--  * 强化某个属性小伙伴位置
--  * @param $index int 位置
--  * @return string 'ok'
--  */
-- public function strengthAttrExtra($index);
function strengthAttrExtra( pIndex, pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
    local args = Network.argsHandlerOfTable({ pIndex })
    Network.rpc(requestFunc,"formation.strengthAttrExtra","formation.strengthAttrExtra",args,true)
end

-- /**
--  * 返回属性小伙伴位置的等级
 -- * 返回属性小伙伴位置的等级
 -- * @return array
 -- * [
 -- *      0=>level(-1未开，0开了，N等级),1=>level,...
 -- * ]
 -- */  0=>level,1=>level,...  -- TODO
-- public function getAttrExtraLevel();
function getAttrExtraLevel( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		-- 设置助战位等级数据
		StageEnhanceData.setStageLvData(dictData.ret)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
    Network.rpc(requestFunc,"formation.getAttrExtraLevel","formation.getAttrExtraLevel",nil,true)
end
