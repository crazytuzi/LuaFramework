-- Filename:LoyaltyService.lua
-- Author: djn
-- Date: 2015-06-25
-- Purpose: 聚义厅网络层

module ("LoyaltyService", package.seeall)
require "script/ui/star/loyalty/LoyaltyData"
--[[
    @des    :获取已装备武将的信息
    @param  :
    @return :
--]]
function getInfo( p_callbackFunc )
    local InfoCallback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            LoyaltyData.setNetData(dictData.ret)
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(InfoCallback, "union.getInfo", "union.getInfo", nil, true)
end
--[[
    @des    :获取增加的羁绊和属性，登陆时拉取
    @param  :
    @return :
--]]
function getLoginInfo( p_callbackFunc )
    local InfoCallback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            LoyaltyData.setLoginInfo(dictData.ret)
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(InfoCallback, "union.getInfoByLogin", "union.getInfoByLogin", nil, true)
end
--[[
    @des    :镶嵌一个
    @param  :
    @return :
--]]
function fill( p_arg,p_callbackFunc )
    local InfoCallback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(InfoCallback, "union.fill", "union.fill", p_arg, true)
end
