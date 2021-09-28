-- Filename：    PillService.lua
-- Author：      DJN
-- Date：        2015-10-8
-- Purpose：     丹药网络层
module("PillService", package.seeall)

--卸下一个丹药
function removePill(p_hid,p_PillId,p_callbackFunc )
   local callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            --GuildRankData.setRankGuildListData(dictData.ret)
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    local args = CCArray:create()
    args:addObject(CCInteger:create(p_hid))
    args:addObject(CCInteger:create(p_PillId))
    Network.rpc(callback, "hero.removePill", "hero.removePill", args, true)
end
--卸下这个类型的所有的丹药
function removePillByType(p_hid,p_type,p_callbackFunc )
   local callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            --GuildRankData.setRankGuildListData(dictData.ret)
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    local args = CCArray:create()
    args:addObject(CCInteger:create(p_hid))
    args:addObject(CCInteger:create(p_type))
    Network.rpc(callback, "hero.removePillByType", "hero.removePillByType", args, true)
end

--[[
    @desc   : 一键服用丹药
    @param  : pHid 武将ID pPillType 丹药类型 pCallback 回调方法
    @return : table {
                bagModify : 背包修改信息
                pill : 武将丹药信息
            }
    /**
     * 一键装备丹药
     * 
     * @param hid 武将ID
     * @param pillType 丹药类型
     * 
     * @return pillInfo @see getAllHeroes
     * */
    public function addArrPills($hid, $pillType);
--]]
function addArrPills( pHid, pPillType, pCallback )
    local requestFunc = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
    local args = Network.argsHandlerOfTable({ pHid , pPillType })
    Network.rpc(requestFunc,"hero.addArrPills","hero.addArrPills",args,true)
end

--[[
    @desc   : 合成丹药
    @param  : pIndex 合成丹药类型对应的index pIsAll 是否是全部合成 pCallback 回调方法
    @return : 
    /**
     * 合成丹药
     * @param int $index      //合成的index,对应的是normall_config表里的物品的index
     * @param int $isAll       //是否是全部合成 0 否 1 是
     * @return 'ok';合成成功
     * @return 'not enouph item';  //物品不足
     */
    pill.fuse($index,$isAll)
--]]
function fusePill( pCallback, pIndex, pIsAll )
    local requestFunc = function(cbFlag,dictData,bRet)
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
    -- 后端index从0 开始，so -1
    local args = Network.argsHandlerOfTable({ pIndex-1 , pIsAll })
    Network.rpc(requestFunc,"pill.fuse","pill.fuse",args,true)
end