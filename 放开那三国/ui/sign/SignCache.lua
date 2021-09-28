-- Filename: signCache.lua
-- Author: zhz
-- Date: 2013-07-31
-- Purpose: 该文件用于:数据存储和方法的存储  

module ("SignCache", package.seeall)

require "script/model/user/UserModel"
require "script/ui/hero/HeroPublicCC"
require "db/DB_Normal_sign"
require "db/DB_Accumulate_sign"


------------------------------------------------------ 设置网络数据  --------------------------

local _signInfo = nil                --  连续签到信息，从网络中获取
local _accSignInfo= nil              -- 累计签到信息，
local _normalList = {}
-- 设置网络数据
function setSignInfo( signInfo)
    _signInfo = signInfo
    -- print_t(_signInfo)
end
function getSignInfo()
    return _signInfo
end

-- 获得 normal_list  //未领取 0 已领取1 不可领取2
function getNormalList( )
    return _signInfo.normal_list
end

function setAccSignInfo( accSignInfo )
    _accSignInfo= accSignInfo
    -- print("accumulate  is :")
    print_t(_accSignInfo)
end

function getAccSignInfo( ... )
    return _accSignInfo
end

-- 获得 acc_got 
function getAccGot(  )
    return _accSignInfo.acc_got
end

-- 获得累计签到的次数  sign_num
function getSignTimes(  )
    return _accSignInfo.sign_num
end

-- 改变normal_list 第 index 个的状态, 有未领取变成已领取
function changeSignInfoStatus(index  )
    _signInfo.normal_list[tostring(index)] = 1
end
-- 增加累计签到
function addAccGot( index )
    table.insert(_accSignInfo.acc_got ,index)
end

-- 获得已领取累计签到的奖励次数
function getAccSignTimes( )
    if(_accSignInfo== nil or table.isEmpty(_accSignInfo.acc_got)) then
       -- print("SignCache.getAccSignTimes() dddd  is : ")
       print_t(_accSignInfo.acc_got)
        return 0
    end

    -- print("SignCache.getAccSignTimes()  is : ")
    return table.count(_accSignInfo.acc_got )
end

-- 判断连续签到是否可以领取
function getBoolEffect( )
    local boolEffect = false
    if(_signInfo== nil ) then
        return boolEffect
    end
    for i=1 , table.count(_signInfo.normal_list) do
--        print("_signInfo.normal_list[tostring(i)]  is: ", _signInfo.normal_list[tostring(i)])
        if( tonumber(_signInfo.normal_list[tostring(i)]) == 0) then
            boolEffect = true
            break
        end
    end
    return boolEffect  
end

-- -- 判断累计签到是否可以领取
function getBoolAccEffect( )
    local boolEffect = false
    local canReceiveNum = 0

    -- print(" _accSignInfo _accSignInfo _accSignInfo _accSignInfo ")
    -- print_t(_accSignInfo)
    if(_accSignInfo == nil) then
        return boolEffect, canReceiveNum
    end

    -- 有几个奖励尚未领取   
    local sign_num =tonumber(_accSignInfo.sign_num)
    if(not table.isEmpty(_accSignInfo.acc_got) ) then
        if( table.count( _accSignInfo.acc_got)< sign_num) then
            boolEffect = true
            canReceiveNum= sign_num - table.count( _accSignInfo.acc_got)
 --           print(" 2222 boolEffect  is : ", boolEffect, "   canReceiveNum  is :", canReceiveNum)
        end
    else
        boolEffect = true
        canReceiveNum= sign_num
    end
    return boolEffect, canReceiveNum

end

-- 获得第n个领取的连续签到奖励
function getIndexOfCanReceive(  )
    local index=0
    
    if(_signInfo== nil ) then
        return index
    end

    for i=1 , table.count( _signInfo.normal_list) do
        if( tonumber(_signInfo.normal_list[tostring(i) ]) == 1) then
            index = i 
        end

        if( tonumber(_signInfo.normal_list[tostring(i) ]) == 0) then
            index = i -1
            break
        end
    end

    if(index== table.count(_signInfo.normal_list)) then
         index = index -2
    end
    return index  
end

-- 获得累计签到第n个可领取的奖励
function getAccIndexofCanReceive(  )
    local index=0

    if(_accSignInfo== nil or table.isEmpty(_accSignInfo.acc_got) ) then
        return index
    end

    -- 全部领完后
    if( table.count(DB_Accumulate_sign.Accumulate_sign) == table.count(_accSignInfo.acc_got)) then

        index= _accSignInfo.sign_num -1
        -- print("index= _signInfo.sign_num -1  ", index)
        return index
    end 

    local rewardInfo={}
    table.hcopy(_accSignInfo.acc_got, rewardInfo)
    local function keySort ( rewardData_1, rewardData_2 )
        return tonumber(rewardData_1 ) < tonumber(rewardData_2)
    end
    table.sort( rewardInfo, keySort)
    -- print("rewardInfo  is : ")
    print_t(rewardInfo)


    for i=1,#rewardInfo do
        if(i~= tonumber(rewardInfo[i])) then
            index= i-1
            break
        else
            index = i
        end
    end

    return index 
end



-- 通过奖励类型判断物品 1、银币,2、将魂,3、金币,4、体力,5、耐力,6、物品,7、多个物品,8、等级*银币,9、等级*将魂
-- 获取物品的图片

function getItemSp(rewardData)
   local reward_type = tonumber(rewardData.reward_type)
   local reward_values = tonumber(rewardData.reward_values)
   local reward_ID=  tonumber(rewardData.reward_ID)
    local itemSp 
    if(reward_type == 1) then
        itemSp = CCSprite:create("images/common/siliver_big.png")
    elseif(reward_type == 2) then
        itemSp = CCSprite:create("images/common/soul_big.png")
    elseif(reward_type == 3) then
        itemSp = CCSprite:create("images/common/gold_big.png")
    elseif(reward_type == 4) then
        itemSp = CCSprite:create("images/online/reward/energy_big.png")
    elseif(reward_type == 5) then
        itemSp = CCSprite:create("images/online/reward/stain_big.png")
    elseif(reward_type == 8) then
        itemSp = CCSprite:create("images/common/siliver_big.png")
    elseif(reward_type == 9 ) then
        itemSp =CCSprite:create("images/common/soul_big.png")
    elseif(reward_type == 10) then
          itemSp = ItemSprite.getHeroIconItemByhtid( tonumber(reward_ID), -605) --HeroPublicCC.getCMISHeadIconByHtid(reward_ID)
    end
    return itemSp
    
end

-- 获取所有连续签到奖励的信息
function getAllRewardData()
    require "db/DB_Normal_sign"
    local tData = {}
    for k,v in pairs(DB_Normal_sign.Normal_sign) do
        table.insert(tData, v)
    end
    local rewardData = {}
    for k,v in pairs(tData) do
        table.insert(rewardData, DB_Normal_sign.getDataById(v[1]))
    end

    local function keySort ( rewardData_1, rewardData_2 )
        return tonumber(rewardData_1.id ) < tonumber(rewardData_2.id)
    end
    table.sort( rewardData, keySort)
    return rewardData
end

-- 通过 id 获得连续奖励的数据
function getRewardTable(id )

    -- 把奖励改成需要的形式
    local all_good = {}
    local cellValues = DB_Normal_sign.getDataById(tonumber(id))
    for i=1,tonumber(cellValues.reward_num) do
        if(cellValues["reward_type" .. i]~= nil) then
            local t = {}
            t.reward_type = cellValues["reward_type" .. i]
            t.reward_quality = cellValues["reward_quality" ..i]
            t.reward_desc = cellValues["reward_desc" .. i]
            if(t.reward_type == 6) then
                t.reward_ID = cellValues["reward_val" .. i]
                t.reward_values = 1
            elseif(t.reward_type == 7) then
                t.reward_ID =  lua_string_split(cellValues["reward_val" .. i],'|')[1]
                t.reward_values = lua_string_split(cellValues["reward_val" .. i],'|')[2]
                elseif(t.reward_type == 10) then
                    t.reward_ID = cellValues["reward_val" .. i]
                    t.reward_values = 1
            else
                t.reward_values =  cellValues["reward_val" .. i]
            end
            table.insert(all_good,t)
        end
    end

    return all_good
end


-- 获取所有累计签到奖励（也就是开服30天得奖励）的信息
function getAccRewardData()

    require "db/DB_Accumulate_sign"
    local tData = {}
    for k,v in pairs(DB_Accumulate_sign.Accumulate_sign) do
        table.insert(tData, v)
    end
    local rewardData = {}
    for k,v in pairs(tData) do
        table.insert(rewardData, DB_Accumulate_sign.getDataById(v[1]))
    end

    local function keySort ( rewardData_1, rewardData_2 )
        return tonumber(rewardData_1.id ) < tonumber(rewardData_2.id)
    end
    table.sort( rewardData, keySort)
    return rewardData
end


function getAccRewardTable(id )
    -- 把奖励改成需要的形式
    local all_good = {}
    local cellValues = DB_Accumulate_sign.getDataById(tonumber(id))
    for i=1,tonumber(cellValues.reward_num) do
        if(cellValues["reward_type" .. i]~= nil) then
            local t = {}
            t.reward_type = cellValues["reward_type" .. i]
            t.reward_quality = cellValues["reward_quality" ..i]
            t.reward_desc = cellValues["reward_desc" .. i]
            if(t.reward_type == 6) then
                t.reward_ID = cellValues["reward_value" .. i]
                t.reward_values = 1
            elseif(t.reward_type == 7) then
                t.reward_ID =  lua_string_split(cellValues["reward_value" .. i],'|')[1]
                t.reward_values = lua_string_split(cellValues["reward_value" .. i],'|')[2]
                elseif(t.reward_type == 10) then
                    t.reward_ID = cellValues["reward_value" .. i]
                    t.reward_values = 1
            else
                t.reward_values =  cellValues["reward_value" .. i]
            end
            table.insert(all_good,t)
        end
    end

    return all_good
end


-- 将奖励添加的用户信息中
function addUserReward( all_good )

    for i=1, #all_good do
        local reward_type = tonumber(all_good[i].reward_type )
        local reward_values = tonumber(all_good[i].reward_values)
        local userInfo = UserModel.getUserInfo()
        if( reward_type == 1 ) then
            UserModel.addSilverNumber(reward_values)
        elseif( reward_type == 2) then
            UserModel.addSoulNum(reward_values)
        elseif(reward_type ==3) then
            UserModel.addGoldNumber(reward_values)
        elseif(reward_type == 4) then
            UserModel.addEnergyValue(reward_values)
        elseif(reward_type == 5) then
            UserModel.addStaminaNumber(reward_values)
        elseif(reward_type ==6) then
            -- 物品 ，后端直接推
        elseif(reward_type ==7) then
            -- 物品 ，后端直接推
        elseif(reward_type ==8) then
            local silver = tonumber(reward_values)*tonumber(userInfo.level)
            UserModel.addSilverNumber(silver)
        elseif(reward_type == 9) then
            local soul  = tonumber(reward_values)*tonumber(userInfo.level)
            UserModel.addSoulNum(soul)
        elseif(reward_type == 10) then

        end
    end
    
end

-- 获得奖励提示
function getTipByReward( all_good )
    local tip = GetLocalizeStringBy("key_1914")
    for i=1,#all_good do
        tip = tip .. all_good[i].reward_desc .. "*" .. all_good[i].reward_values .. "\n"

    end
    return tip
end



---------------------------------------------  废弃的代码 --------------------------------- 
require "db/DB_Normal_sign"
local _signInfo = nil               --  签到信息，从网络中获取
local _signTable = nil              -- 连续签到表的信息
local _accumulateTable = nil
-- local _boolEffect= false                   -- 判断是否有特效

-- 判断是否有特效
-- function getBoolEffect( )
--      _boolEffect = false
--     if(_signInfo == nil ) then
--         _boolEffect = true
--         return _boolEffect
--     end
--     if(_signTable == nil ) then
--         _signTable = getAllNormalData()
--     end
--     print("_signInfo    in getBoolEffect is : ",_signInfo )
--     if(_accumulateTable == nil) then
--         _accumulateTable = getAccSignData()
--     end
   
--     for i=1,#_signTable do
--         if(_signTable[i].canReceived == true) then
--             _boolEffect = true
--         end
--     end
--     for i=1 , #_accumulateTable do
--         if(_accumulateTable[i].canReceived == true) then
--             _boolEffect = true
--         end
--     end
--     -- print("==================== =======  getBoolEffect")
--     -- print_t(_signTable)
--     return _boolEffect
-- end


------------------------------ 连续签到 ----------------------------------------
function changeSignTableStatus(index)
    
    _signTable[8- index].isReceived = true
    _signTable[8- index].canReceived = false
end

function getCurNormalSingTable()
    local curIndex = _signInfo.normal_step 
    return _signTable[8 - curIndex]
end
-- 一个时间戳，如何判断是否是今天
local function isToday(timestamp)
    local today = os.date("*t")
    local secondOfToday = os.time({day=today.day, month=today.month,
        year=today.year, hour=0, minute=0, second=0})
    if timestamp >= secondOfToday and timestamp < secondOfToday + 24 * 60 * 60 then
        return true
    else
        return false
    end
end
-- 获得s所有连续签到表的数据
function getAllNormalData()
    -- 通过step来找到所有的数据
    _signTable ={}     -- 这个是处理所有的数据，把从网络传来的数据转变成对应的7个table
    local tempData = DB_Normal_sign.getDataById(_signInfo.normal_step) -- t1这次获得的数据
    local curStep = tonumber(_signInfo.normal_step)
    -- 把对应的 step 装换成 ID
    local curID =(tonumber(_signInfo.normal_sign_level) - 1)*7 + curStep
    local startStep = math.ceil(curID/7)
   -- print("startStep is :" .. startStep)
    for tempStep = startStep*7,(startStep-1)*7+1,-1 do        -- 
        local tempData = DB_Normal_sign.getDataById(tempStep) 
       -- print("tempStep is " .. tempStep)
        local tempTable = {}
        tempTable.normal_sign_level = _signInfo.normal_sign_level
        if(tempStep < curID ) then
            tempTable.isReceived = true
            tempTable.canReceived = false
        elseif(tempStep == curID) then 
            draw_normal_time = tonumber(_signInfo.draw_normal_time)
            if isToday(draw_normal_time)then
                tempTable.isReceived = true
                tempTable.canReceived= false
            else
                tempTable.isReceived = false
                tempTable.canReceived= true
            end
                -- tempTable.isReceived = false
                -- tempTable.canReceived= true
                -- print("_signTable.draw_normal_time is :" .._signInfo.draw_normal_time )
        elseif(tempStep > curStep) then
            tempTable.isReceived = false
            tempTable.canReceived = false
        end
        tempTable.id = tempData.id
        --tempTable.setp = tempStep
        tempTable.reward_num = tempData.reward_num
        tempTable.level_require = tempData.level_require

        for i=1,4 do
            if(tempData["reward_type" .. i]~= nil) then
                tempTable["reward_type" .. i] = tempData["reward_type" .. i]
                tempTable["reward_quality" .. i] = tempData["reward_quality" .. i]
                tempTable["reward_desc" .. i] = tempData["reward_desc" .. i]
                if( tempTable["reward_type" .. i] == 6 ) then
                    tempTable["reward_ID" .. i] = tempData["reward_val" .. i]
                    tempTable["reward_values" .. i] = 1
                elseif(tempTable["reward_type" .. i] == 7) then
                      tempTable["reward_ID" .. i]=  string.split(tempData["reward_val" .. i],'|')[1]
                      tempTable["reward_values" ..i] = string.split(tempData["reward_val" .. i],'|')[2]
                else
                    tempTable["reward_values" .. i] = tempData["reward_val" .. i]
                end
            end
        end
        table.insert( _signTable,tempTable)

       -- print_t( tempTable) 
       
    end
    return _signTable
end

-------------------------------------------- 累积签到的奖励 -----------------------------
require "db/DB_Accumulate_sign"
-- 获得本次可以领取奖励的信息，这个有问题，本次有可能可以多次领取就奖励
local _curAccID
function getCurAccID( )
    return _curAccID
end
function setCurAccID(id)
    _curAccID = id
end

-- 累积签到所有的表，
-- -- 真心被策划整惨了，又TMD得改
function getAccumulateData( )
    _accumulateTable = {}
    local  acc_step = tonumber(_signInfo.acc_step)  
    local acc_sign_times= tonumber(_signInfo.acc_sign_times) -- 累积签到的次数
    local curID = acc_step + 1
end

-- 改变领取奖励的状态
function changeAccTableStatus( index)
    --local tableIndex = #_accumulateTable+1- index
   -- print("#_accumulateTable is :" .. #_accumulateTable)
    for i=1,#_accumulateTable do
        if(_accumulateTable[i].id ==index) then
            _accumulateTable[i].isReceived = true
            _accumulateTable[i].canReceived = false
        end
    end
end
-- 
function getAccSignData( )
	 _accumulateTable  ={}     -- 这个是处理所有的数据，把从网络传来的数据转变成对应的7个table

    local va_sign = _signInfo.va_sign
    local curID = 1
    if( table.isEmpty( va_sign ) ) then
        curID = 1
        print("curID is :  -------")
    else
        local function cmp( k1,k2)
            return tonumber(k1) < tonumber(k2)
        end
        table.sort(va_sign,cmp)
        curID = va_sign[#va_sign]+1
    end
 
  
    local curData = DB_Accumulate_sign.getDataById(curID)
    if(curData == nil) then
       curData = DB_Accumulate_sign.getDataById(tonumber(curID) -1)
    end
    local acc_sign_times= tonumber(_signInfo.acc_sign_times) -- 累积签到的次数
    -- 从数据DB中获取的所有表
    local tempData = DB_Accumulate_sign.getArrDataByField("accumulate_type",curData.accumulate_type )

    -- 插入数据
    for i=#tempData,1,-1 do
        local tempTable= {}
        if(acc_sign_times < tempData[i].add_up_days) then
                tempTable.isReceived =false
                tempTable.canReceived = false
         else
                tempTable.isReceived = false
                tempTable.canReceived = true
        end

        tempTable.id = tempData[i].id

        for i=1,#va_sign do
            if(tonumber(va_sign[i]) == tonumber(tempTable.id)) then

                tempTable.isReceived = true
                tempTable.canReceived = false
            end
        end

       
        tempTable.add_up_days = tempData[i].add_up_days
        tempTable.reward_num = tempData[i].reward_num
      -- 四个物品
        for j=1,4 do
            if( tempData[i]["reward_type" .. j]~= nil) then
                tempTable["reward_type" .. j] = tempData[i]["reward_type" .. j]
                tempTable["reward_quality" .. j] = tempData[i]["reward_quality" .. j]
                tempTable["reward_desc" .. j] =tempData[i]["reward_desc" .. j]
                if( tempTable["reward_type" .. j] == 6 ) then -- reward_values
                    tempTable["reward_ID" .. j] = tempData[i]["reward_value" .. j]
                    tempTable["reward_values" .. j] = 1
                elseif(tempTable["reward_type" .. j] == 7) then
                      tempTable["reward_ID" .. j]=  string.split(tempData[i]["reward_value" .. j],"|")[1]
                      tempTable["reward_values" ..j] = string.split(tempData[i]["reward_value" .. j],"|")[2]
                else
                    tempTable["reward_values" .. j] = tempData[i]["reward_value" .. j]
                end
            end
        end
       
        table.insert( _accumulateTable,tempTable)
    end
    print("=============== accumulate")
    print_t(_accumulateTable)

    local function keySort ( w1 , w2 )
     return tonumber(w1.id) > tonumber(w2.id)
    end
    table.sort( _accumulateTable, keySort )
  --  print_table("_accumulateTable", _accumulateTable)
    return _accumulateTable
    
end
