-- FileName:CountryWarCheerData.lua
-- Author:FQQ
-- Data:2015-11-19
-- Purpose:国战助威数据层

module ("CountryWarCheerData",package.seeall)

require "script/ui/countryWar/CountryWarMainData"


local _mySupportPepole = nil

function getForceInfo( ... )
    local cheerInfo = CountryWarMainData.getSupportInfo()
    return  cheerInfo.forceInfo
end

--[[
    @des:得到被助威人的信息
--]]
function getMemberInfo( ... )
    local _cheerInfo = CountryWarMainData.getSupportInfo()
    local numberList = _cheerInfo.memberInfo
    -- print("助威选手~~~~~~")
    -- print_t(numberList)
    if table.isEmpty(numberList) then
        numberList = {}
    end
    return numberList
end

--判断side值
function getSide( ... )
    local _cheerInfo = CountryWarMainData.getSupportInfo()
    local side = 0
    if not table.isEmpty(_cheerInfo.mySupport) then
        side = tonumber(_cheerInfo.mySupport.side) or 0
    end
    return side
end

--判断是否助威势力
function isSupportedSide( ... )
    local ret = false
    local side = getSide()
    if(side == 0)then
        --没有助威为true
        ret = true
    else
        --助威了为false
        ret = false
    end
    return ret
end
--[[
    @des:设置我的助威势力
    @parm:pSide 势力id
--]]
function setSide( pSide )
    local mainSupportInfo = CountryWarMainData.getSupportInfo()
    mainSupportInfo.mySupport.side = pSide or 0
end


function getSupportCountryId( ... )
    local _cheerInfo = CountryWarMainData.getSupportInfo()
    local supportCountry = _cheerInfo.mySupport.countryId
    return supportCountry
end


function setMySupportUserInfo( p_Info )
    local mainSupportInfo = CountryWarMainData.getSupportInfo()
    mainSupportInfo.mySupport.user = p_Info
end

function getMySupportUserInfo()
    local mainSupportInfo = CountryWarMainData.getSupportInfo()
    if  table.isEmpty(mainSupportInfo.mySupport) then
        return {}
    else
        return mainSupportInfo.mySupport.user
    end
end


function addPlayerFans( pPid, pServerId, pFansNum)
    local memberInfo = getMemberInfo()
    for k,v in pairs(memberInfo) do
        if tonumber(v.pid) == tonumber(pPid) and tonumber(v.server_id) == tonumber(pServerId) then
            memberInfo[k].fans_num = tonumber(memberInfo[k].fans_num) or 0
            memberInfo[k].fans_num = memberInfo[k].fans_num + pFansNum
            break
        end
    end
end

--[[
    @des:判断自己当前有没有助威过
    @ret:bool 
--]]
function isSupportedUser()
    local mainSupportInfo = CountryWarMainData.getSupportInfo()
    if table.isEmpty(mainSupportInfo.mySupport.user) then
        return false
    else
        return true
    end
end


--获取助威势力的奖励金币
function getSideIncon( ... )
    require "db/DB_National_war"
    local data = DB_National_war.getDataById(1)
    local sideIncon = string.split(data.cheer_reward1, "|")
    -- local itemsideIncon = {}
    -- itemsideIncon.type = sideIncon[1]
    -- itemsideIncon.num  = sideIncon[2]
    -- itemsideIncon.incon = sideIncon[3]
    return sideIncon[3]
end
--获取助威玩家的奖励金币
function getUserIncon( ... )
    local data = DB_National_war.getDataById(1)
    local sideIncon = string.split(data.cheer_reward2, "|")
    -- local itemuserIncon = {}
    -- itemuserIncon.type = sideIncon[1]
    -- itemuserIncon.num  = sideIncon[2]
    -- itemuserIncon.incon = sideIncon[3]
    return sideIncon[3]
end

