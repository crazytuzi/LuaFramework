-- Filename: UserModel.lua
-- Author: fang
-- Date: 2013-05-31
-- Purpose: 该文件用于用户数据模型

module ("UserModel", package.seeall)

local _userInfo = nil

-- 观察者数组，观察者为数据变更观察者，观察者自身应该为视图
local observers = nil

-- 用户信息结构
--[[
    uid:用户id,
    uname:用户名字,
    utid:用户模版id,
    htid:主角武将的htid
    level:玩家级别
    execution:当前行动力,
    execution_time : 上次恢复行动力时间
    buy_execution_accum : 今天已经购买行动力数量
    vip:vip等级,
    silver_num:银两,
    gold_num:金币RMB,
    exp_num:阅历,
    soul_num:将魂数目
    wm_num:跨服赛争霸令数目
    stamina:耐力
    stamina_time:上次恢复耐力的时间
    stamina_max_num:耐力上限
    fight_cdtime : 战斗冷却
    ban_chat_time : 禁言结束时间
    max_level:玩家的等级上限
    hero_limit:武将数目限制
    charge_gold:当前充金币数目
    jewel_num：魂玉数目
    prestige_num：声望数目
    figure:玩家头像
    title:玩家称号
-- added by fang, for client data cache
    fight_force: 玩家战斗力
    dayOffset:时间的偏移量
    mergeServerTime:合服时间
    mergeServerCount:合服组数
    execution_max_num:体力上限
    fame_num:名望值
    book_num:科技图纸数量
    hid:主角hid
    fs_exp : 战魂经验
--]]

function getUserInfo()
    if (_userInfo == nil) then
        CCLuaLog (GetLocalizeStringBy("key_1067"))
    end
    return _userInfo
end

function setUserInfo(pUserInfo)
    if _userInfo == nil then
        _userInfo = pUserInfo
    else
        --刷新userInfo
        table.paste(_userInfo, pUserInfo)
    end
    if _userInfo and _userInfo.unlockPay then
        print("_userInfo.unlockPay",_userInfo.unlockPay)
        Platform.fnLockPay(_userInfo.unlockPay)
    end
end

function getUserHid(  )
    if _userInfo.hid == nil then
        require "script/model/hero/HeroModel"
        _userInfo.hid = HeroModel.getNecessaryHero().hid
    end
    return _userInfo.hid
end


--是否可发言，true为可发言，false为不可，方法未写完
function isChatable()
    if(getUserInfo().ban_chat_time<=0) then
        return true
    else
        return false
    end
end

-- 判断用户是否达到最大等级
function hasReachedMaxLevel( ... )
    return tonumber(_userInfo.level) >= tonumber(_userInfo.max_level)
end

-- 用户升级表数据
local _tObserverForLevelUp = {}
-- 为用户升级提供观察者
-- pKey, string类型, pFnObserver唯一标识符
-- pFnObserver: 需要调用的函数
function addObserverForLevelUp(pKey, pFnObserver)
-- for debug
-- 以下代码用于调试，正式代码应该去掉
    if type(pKey) ~= "string" or type(pFnObserver) ~= "function" then
        print("Error, UserModel.addObserverForLevelUp, new observer is wrong.")
        return
    end
    for k, v in pairs(_tObserverForLevelUp) do
        if k == pKey then
            print("Error, UserModel.addObserverForLevelUp, observers have the same key named as ", k)
            break
        end
    end

    _tObserverForLevelUp[pKey] = pFnObserver
end
-- 删除自定义观察者
function removeObserverForLevelUp(pKey)
    _tObserverForLevelUp[pKey]=nil
end

-- 获取体力值方法
function getEnergyValue()
    if _userInfo then
        return tonumber(_userInfo.execution)
    end
    return 0
end

-- 获得 max_level added by zhz
function getUserMaxLevel( )
    return tonumber(_userInfo.max_level)
end

-- 获取服务器相关时间的偏移量  -- add by chengliang
function getSvrDayOffsetSec()
    local sec_offset = 0
    if(_userInfo.dayOffset)then
        sec_offset = tonumber(_userInfo.dayOffset)
    end
    return sec_offset
end

-- 获得玩家的sex added by zhz
-- return, 1男，2女
function getUserSex()
    require "db/DB_Heroes"
    local model_id = DB_Heroes.getDataById(tonumber(_userInfo.htid)).model_id
    if model_id == 20001 then
        return 1
    elseif model_id == 20002 then
        return 2
    end
    return -1
end

-- 获得玩家的model_id
function getUserModelId()
    require "db/DB_Heroes"
    local modelId = DB_Heroes.getDataById(_userInfo.htid).model_id
    return modelId
end

function checkValueCallback(cbFlag, dictData, bRet)
    print_table("checkValueCallback",dictData)
    if(dictData.ret~=nil and (tonumber(dictData.ret.exp_num)~=tonumber(_userInfo.exp_num) or tonumber(dictData.ret.level)~=tonumber(_userInfo.level))) then
        require "script/network/RequestCenter"
        require "script/network/Network"
        RequestCenter.gm_reportClientError(nil,Network.argsHandler("exp error _userInfo.exp_num:" .. _userInfo.exp_num .. ",_userInfo.level:" .. _userInfo.level))
    end
end

-- 增加经验值方法
function addExpValue(value,symbolString)
    if hasReachedMaxLevel() then
        return
    end

    _userInfo.exp_num = tonumber(_userInfo.exp_num) + value
    
    require "script/model/hero/HeroModel"
    require "script/ui/main/MainScene"
    require "db/DB_Level_up_exp"
    local tUpExp = DB_Level_up_exp.getDataById(2)
    local bUpgraded = false
    local status = true
    if tonumber(_userInfo.level) >= tonumber(_userInfo.max_level) then
        status = false
    end
    while status do
        local nLevelUpExp = tUpExp["lv_"..(tonumber(_userInfo.level)+1)]
        if (tonumber(_userInfo.exp_num) >= nLevelUpExp) then
            _userInfo.exp_num = tonumber(_userInfo.exp_num) - nLevelUpExp
            
            bUpgraded = true
            _userInfo.level = tonumber(_userInfo.level) + 1
            addGoldNumber(10)
        else
            status = false
        end
    end
    if bUpgraded then
        for k, fn in pairs(_tObserverForLevelUp) do
            fn(_userInfo.level)
        end
        HeroModel.setMainHeroLevel(_userInfo.level)
        MainScene.fnUpdateFightValue()
        
        --通知Platform层 角色升级
        Platform.sendInformationToPlatform(Platform.kRoleLevelInfo,_userInfo.level)
    end
    MainScene.updateExpValueUI()
    --
    -- if(BTUtil:getDebugStatus()==true)then
    --     --验证经验
    --     require "script/network/RequestCenter"
    --     require "script/network/Network"
    --     RequestCenter.user_checkValue(checkValueCallback,Network.argsHandler("exp_num",_userInfo.exp_num,symbolString .. ""))
    -- end
    --]]
end
-- 通过传入经验值判断是否会升级
-- tParam = {}
-- tParam.exp_num(用户的当前经验)
-- tParam.add_exp_num (增加的经验值)
-- tParam.level (相应的等级) 
-- 返回值 tRet = {}
-- tRet.isUpgraded=true(升级了), false(未升级)
-- tRet.level（返回的等级）
-- tRet.ratio (剩于的比率)
function getUpgradingStatusIfAddingExp(tParam)
    local tRet = {}
    tRet.level = tParam.level
    require "db/DB_Level_up_exp"
    local tUpExp = DB_Level_up_exp.getDataById(2)
    local bUpgraded = false
    local status = true
    local nTotalExpNum = tParam.exp_num+tParam.add_exp_num
    while status do
        local nLevelUpExp = tUpExp["lv_"..(tRet.level+1)]
        if (nTotalExpNum >= nLevelUpExp) then
            bUpgraded = true
            nTotalExpNum = nTotalExpNum - nLevelUpExp
            tRet.level = tRet.level + 1
        else
            tRet.ratio = nTotalExpNum/nLevelUpExp
            status = false
        end
    end
    tRet.isUpgraded = bUpgraded

    return tRet
end

--获取新服活动上线时间
function getNewServerOnlineTime( ... )
    return tonumber(_userInfo.timeConf.newserveractvitiy) or 0
end
-- 获得用户当前vip等级
function getVipLevel()
    local vipLevel = 0
    if(_userInfo ~= nil)then
        vipLevel = _userInfo.vip
    end
    return tonumber(vipLevel)
end

-- 修改用户当前vip等级
function setVipLevel( pLv )
    if _userInfo == nil then
        return
    end
    _userInfo.vip = pLv
end

-- 获得用户当前武将限制数量
function getHeroLimit( ... )
    return tonumber(_userInfo.hero_limit)
end
-- 设置用户当前武将限制数量
function setHeroLimit(pHeroLimit)
    _userInfo.hero_limit = pHeroLimit
end

-- 获取银币值
function getSilverNumber()
    local nValue = tonumber(_userInfo.silver_num)
    if nValue < 0 then
        nValue = 0
    end
    return nValue
end
-- 获取兵符积分
function getTallyPointNumber()
    local nValue = tonumber(_userInfo.tally_point)
    if nValue < 0 then
        nValue = 0
    end
    return nValue
end
-- 设置兵符积分
function addTallyPointNumber(pNum)
    _userInfo.tally_point = tonumber(_userInfo.tally_point) + pNum
end
-- 获取金币值
function getGoldNumber()
    return tonumber(_userInfo.gold_num)
end

-- 获取耐力上限
function getMaxStaminaNumber()
    if _userInfo then
        return tonumber(_userInfo.stamina_max_num)
    else
        return 0
    end
end

--获取体力值上限
function getMaxExecutionNumber()
    if _userInfo then
        return tonumber(_userInfo.execution_max_num)
    else
        return 0
    end
end

-- 获取耐力值
function getStaminaNumber()
    if _userInfo then
        return tonumber(_userInfo.stamina)
    else
        return 0
    end
end
-- 获得上次恢复耐力时间
function getStaminaTime()
    if _userInfo then
        return tonumber(_userInfo.stamina_time)
    else
        return 0
    end
end
-- 获取经验值方法
function getExpValue(value)
    return tonumber(_userInfo.exp_num)
end
-- 获取当前等级方法
function getHeroLevel()
    return tonumber(_userInfo.level)
end
-- 获取当前等级方法
function getAvatarLevel()
    return tonumber(_userInfo.level)
end
-- 获得将魂数量方法
function getSoulNum( ... )
    --
    return tonumber(_userInfo.soul_num)
end
-- 获得用户uid
function getUserUid()
    return tonumber(_userInfo.uid)
end
-- 获得用户utid
function getUserUtid()
    return tonumber(_userInfo.utid)
end
-- 获得用户的名字
function getUserName()
    return _userInfo.uname
end
-- 获得玩家的htid
function getAvatarHtid( ... )
    return _userInfo.htid
end
-- 当前充金币数目 , 此函数已废弃，charge_gold 放在 DataCache 中 中 added by zhz 
-- function getChargeGoldNum( ... )
--     return tonumber(_userInfo.charge_gold)
-- end
-- 获取玩家“角色创建时间戳”
function getCreateTime( ... )
    return _userInfo.create_time
end
-- 获得上次恢复体力时间
function getEnergyValueTime()
    if _userInfo and _userInfo.execution_time then
        return tonumber(_userInfo.execution_time)
    end
    return os.time()
end
-- 获得用户声望
function getPrestigeNum( ... )
    return tonumber(_userInfo.prestige_num)
end

-- 获得玩家比武荣誉
function getHonorNum( ... )
    return tonumber(_userInfo.honor_num)
end

-- 增加比武荣誉
function addHonorNum( p_count )
    _userInfo.honor_num = tonumber(_userInfo.honor_num) + p_count
end

-- 获得玩家魂玉
function getJewelNum( ... )
    return tonumber(_userInfo.jewel_num)
end

-- 获得玩家争霸令数量
function getWmNum( ... )
    return tonumber(_userInfo.wm_num) or 0
end
-- 增加玩家跨服赛争霸令
function addWmNum( pNum )
    _userInfo.wm_num = _userInfo.wm_num or 0
    _userInfo.wm_num = tonumber(_userInfo.wm_num) + tonumber(pNum)
end

-- 得到玩家名望值
function getFameNum()
    return tonumber(_userInfo.fame_num) or 0
end
-- 增加玩家名望值
function addFameNum(pNum)
    if _userInfo.fame_num == nil then
        _userInfo.fame_num = 0
    end
    _userInfo.fame_num = tonumber(_userInfo.fame_num) + pNum 
end
-- 减少玩家名望值
function reduceFameNum(pNum)
    if _userInfo.fame_num == nil then
        _userInfo.fame_num = 0
    end
    _userInfo.fame_num = _userInfo.fame_num - pNum
end

function getFigureId()
    return tonumber(_userInfo.figure)
end

function setFigureId(figure_id)
    _userInfo.figure = tostring(figure_id)
end

-- 加减将魂方法
function addSoulNum(nSoulNumber)
    _userInfo.soul_num = tonumber(_userInfo.soul_num) + nSoulNumber
    if(BTUtil:getDebugStatus()==true)then
        --验证
        require "script/network/RequestCenter"
        require "script/network/Network"
        --RequestCenter.user_checkValue(nil,Network.argsHandler("soul_num",_userInfo.soul_num,""),"user.checkValue_soul_num" .. math.random(999))
    end
end
-- 加减耐力值方法
function addStaminaNumber(nStaminaNumber)
    _userInfo.stamina = tonumber(_userInfo.stamina) + nStaminaNumber
    MainScene.updateStaminaValueUI()
    
    if(BTUtil:getDebugStatus()==true)then
        --验证耐力
        require "script/network/RequestCenter"
        require "script/network/Network"
        RequestCenter.user_checkValue(nil,Network.argsHandler("stamina",_userInfo.stamina,""),"user.checkValue_stamina" .. math.random(999))
        
    end
end

-- 加减耐力值上线得方法
function addStaminaMaxNumber(nStaminaNumber)
    _userInfo.stamina_max_num = tonumber(_userInfo.stamina_max_num) + nStaminaNumber
    MainScene.updateStaminaValueUI()
end

--增加体力上限
function addExecutionMaxNumber(p_executionNumber)
    _userInfo.execution_max_num = tonumber(_userInfo.execution_max_num) + p_executionNumber
    MainScene.updateEnergyValueUI()
    if(BTUtil:getDebugStatus()==true)then
        --验证耐力
        require "script/network/RequestCenter"
        require "script/network/Network"
        RequestCenter.user_checkValue(nil,Network.argsHandler("execution",_userInfo.execution,""),"user.checkValue_execution" .. math.random(999))
        
    end
end

-- 增减银币
function addSilverNumber(nSilverNumber)
    _userInfo.silver_num = tonumber(_userInfo.silver_num) + nSilverNumber
    require "script/ui/main/MainScene"
    MainScene.updateAvatarInfo()

    if(BTUtil:getDebugStatus()==true)then
        require "script/network/RequestCenter"
        require "script/network/Network"
        --RequestCenter.user_checkValue(nil,Network.argsHandler("silver_num",tonumber(_userInfo.silver_num),""),"user.checkValue_silver_num" .. math.random(999))
    end

    require "script/utils/TopGoldSilver"
    TopGoldSilver.refreshSilverCallback()
end
-- 增减金币
function addGoldNumber(nGoldNumber)
    _userInfo.gold_num = tonumber(_userInfo.gold_num) + nGoldNumber
    require "script/ui/main/MainScene"
    MainScene.updateAvatarInfo()
    if(BTUtil:getDebugStatus()==true)then
        require "script/network/RequestCenter"
        require "script/network/Network"
        --RequestCenter.user_checkValue(nil,Network.argsHandler("gold_num",tonumber(_userInfo.gold_num),""),"user.checkValue_gold_num" .. math.random(999))
    end

    require "script/utils/TopGoldSilver"
    TopGoldSilver.refreshGoldCallback()
end
-- 增减体力值方法
function addEnergyValue(value)
    _userInfo.execution = tonumber(_userInfo.execution)+value
    require "script/ui/main/MainScene"
    MainScene.updateEnergyValueUI()
    
    -- if(BTUtil:getPlatform() == kBT_PLATFORM_IOS or BTUtil:getPlatform() == kBT_PLATFORM_ANDROID) then
        -- 体力变化时，调用体力注册通知 add by chengliang
        require "script/utils/NotificationUtil"
        NotificationUtil.addRestoreEnergyNotification()
    -- end
    if(BTUtil:getDebugStatus()==true)then
        --验证耐力
        require "script/network/RequestCenter"
        require "script/network/Network"
        RequestCenter.user_checkValue(nil,Network.argsHandler("execution",_userInfo.execution,""),"user.checkValue_execution" .. math.random(999))
        
    end
end
-- 增减声望值方法
function addPrestigeNum(nValue)
    _userInfo.prestige_num = tonumber(_userInfo.prestige_num) + nValue
    if(BTUtil:getDebugStatus()==true)then
        require "script/network/RequestCenter"
        require "script/network/Network"
        --RequestCenter.user_checkValue(nil,Network.argsHandler("prestige_num",tonumber(_userInfo.prestige_num),""),"user.checkValue_prestige_num" .. math.random(999))
    end
    return _userInfo.prestige_num
end
-- 增减玩家魂玉值方法
function addJewelNum( nValue )
    _userInfo.jewel_num = tonumber(_userInfo.jewel_num) + nValue

    if(BTUtil:getDebugStatus()==true)then
        require "script/network/RequestCenter"
        require "script/network/Network"
        --RequestCenter.user_checkValue(nil,Network.argsHandler("jewel_num",tonumber(_userInfo.jewel_num),""),"user.checkValue_jewel_num" .. math.random(999))
    end
    return _userInfo.jewel_num
end

-- 设置耐力值方法
function setStaminaNumber(nStaminaNumber)
    _userInfo.stamina = tonumber(nStaminaNumber)
     MainScene.updateStaminaValueUI()
end
-- 设置上次恢复体力时间
function setEnergyValueTime( value )
    _userInfo.execution_time = value
end

-- 设置体力回复满的时间，若满则为： 0
function getEnergyFullTime( )
    local energyNum =  g_maxEnergyNum - _userInfo.execution
    local energyAddTime = energyNum*g_energyTime
    local energyFullTime=0  --= energyAddTime + _userInfo.execution_time - BTUtil:getSvrTimeInterval() 
    if(tonumber(g_maxEnergyNum) >  tonumber(_userInfo.execution) ) then
        energyFullTime= energyAddTime + _userInfo.execution_time - BTUtil:getSvrTimeInterval() 
    else
        energyFullTime=0 
    end
    return energyFullTime

end

-- 设置耐力值
function setStainValue(value  )
    _userInfo.stamina= tonumber(value)
    MainScene.updateStaminaValueUI()
end

-- 设置上次恢复耐力时间
function setStaminaTime( value )
    _userInfo.stamina_time = value
end

-- 重新设置主角的htid
function setAvatarHtid( htid)
    require "script/model/hero/HeroModel"
    if HeroModel.isNecessaryHero(htid) then
       _userInfo.htid = htid
       HeroModel.setNecessaryHeroHtid(htid)
       -- 更新主角信息面板的主角icon
       require "script/ui/main/MainScene"
       MainScene.resetAvatarIcon()
    end
end

-- 设置玩家的姓名
function setUserName( name  )
    _userInfo.uname = name
end


-- 得到天工令数量
function getGodCardNum( ... )
    return tonumber(_userInfo.tg_num)
end
-- 增加天工令数量
function addGodCardNum( num )
    _userInfo.tg_num = tonumber(_userInfo.tg_num) + num
end

-- 设置天工令
function setGodCardNum( num )
    _userInfo.tg_num = tonumber(num)
end

-- 得到战魂经验
function getFSExpNum()
    return tonumber(_userInfo.fs_exp) 
end

-- 增加战魂经验
function addFSExpNum( p_num )
    _userInfo.fs_exp = tonumber(_userInfo.fs_exp) + tonumber(p_num)
end


--武将精华
function getHeroJh( ... )
    return tonumber(_userInfo.jh) or 0
end

--增加武将精华
function addHeroJh( pNum )
    _userInfo.jh = getHeroJh() + pNum
end

--[[
    @desc:      获得科技图纸数量
    @return:    number 科技图纸数量
--]]
function getBookNum()
    return tonumber(_userInfo.book_num) or 0
end

--[[
    @desc: 增加玩家科技图纸数量
--]]
function addBookNum( pNum )
    _userInfo.book_num = tonumber(_userInfo.book_num) + tonumber(pNum) 
end

--[[
    @desc: 获取玩家当前称号ID
--]]
function getTitleId()
    return tonumber(_userInfo.title)
end

--[[
    @desc: 设置玩家称号ID
    @param: pTitleId 称号ID
--]]
function setTitleId( pTitleId )
    _userInfo.title = tonumber(pTitleId)
end

----------------------- 通知到界面的委托方法 added by zhz  --------------------
local _rechargeChangedDelegate = nil
function setRechargeChangedDelete( delegateFunc )
    _rechargeChangedDelegate = delegateFunc
end
-- 修改用户信息
function changeUserInfo(tParam)
    if not (tParam and type(tParam)=="table") then
        return
    end
    if tParam.execution then
        _userInfo.execution = tParam.execution
    end
    if tParam.level then
        _userInfo.level = tParam.level
    end
    if tParam.execution_time then
        _userInfo.execution_time = tParam.execution_time
    end
    if tParam.vip then
        _userInfo.vip = tParam.vip
    end
    if tParam.silver_num then
        _userInfo.silver_num = tParam.silver_num
    end
    if tParam.gold_num then
        _userInfo.gold_num = tParam.gold_num
    end
    if tParam.exp_num then
        _userInfo.exp_num = tParam.exp_num
    end
    if tParam.soul_num then
        _userInfo.soul_num = tParam.soul_num
    end
    if tParam.stamina then
        _userInfo.stamina = tParam.stamina
    end
    if tParam.stamina_time then
        _userInfo.stamina_time = tParam.stamina_time
    end
    if tParam.stamina_max_num then
        _userInfo.stamina_max_num = tParam.stamina_max_num
    end
    if tParam.fight_cdtime then
        _userInfo.fight_cdtime = tParam.fight_cdtime
    end
    if tParam.ban_chat_time then
        _userInfo.ban_chat_time = tParam.ban_chat_time
    end
    if tParam.max_level then
        _userInfo.max_level = tParam.max_level
    end
    if tParam.hero_limit then
        _userInfo.hero_limit = tParam.hero_limit
    end
    if tParam.charge_gold then
        _userInfo.charge_gold = tParam.charge_gold
    end
    if tParam.mergeServerTime then
        _userInfo.mergeServerTime = tParam.mergeServerTime
    end
    if tParam.wm_num then
        _userInfo.wm_num = tParam.wm_num
    end
    MainScene.updateAvatarInfo()

    if(_rechargeChangedDelegate ~= nil) then
        _rechargeChangedDelegate()
        _rechargeChangedDelegate = nil
    end
   
    -- require "script/ui/shop/RechargeLayer"
    -- RechargeLayer.refreshUI()
    -- require "script/ui/shop/ShopLayer"
    -- ShopLayer.refreshTopUI()
     -- added by zhz

-- anything else?
end

function setFightForceValue(pFightValue)
    _userInfo.fight_force = pFightValue
end

function getFightForceValue()
    if _userInfo.fight_force then
        return _userInfo.fight_force
    else
        return 0
    end
end

-- 获取合服时间
function getMergeServerTime()
    return _userInfo.mergeServerTime
end

-- 获取跨服荣誉 add by yangrui
function getCrossHonor( ... )
    return tonumber(_userInfo.cross_honor)
end

-- 添加跨服荣誉 add by yangrui
function addCrossHonor( pNum )
    _userInfo.cross_honor = tonumber(_userInfo.cross_honor) + pNum
end

---------- 下面的方面将会被废弃掉，上面已经有下面方法的替代方法 --------------------

-- 增减银币
function changeSilverNumber(nSilverNumber)
    addSilverNumber(nSilverNumber)
end
-- 增减金币
function changeGoldNumber(nGoldNumber)
    addGoldNumber(nGoldNumber)
end
-- 增减将魂方法
function changeHeroSoulNumber(nSoulNumber)
    addSoulNum(nSoulNumber)
end
-- 增减耐力值方法
function changeStaminaNumber(nStaminaNumber)
    addStaminaNumber(nStaminaNumber)
end
-- 增减体力值方法
function changeEnergyValue(value)
    addEnergyValue(value)
end

-- 得到玩家的时装信息
function getDressIdByPos( pos_id ) 
    if _userInfo.dress[tostring(pos_id)] ~= nil and tonumber(_userInfo.dress[tostring(pos_id)]) == 0 then
        return nil
    end
    return _userInfo.dress[tostring(pos_id)]
end

-- 设置玩家时装id
function setDressIdByPos( pos_id, dress_id )
    _userInfo.dress[tostring(pos_id)] = dress_id
end

function getDress( ... )
    return _userInfo.dress
end

--[[
    @des:得到某些特定活动的开启时间
--]]
function getTimeConfig( p_key )
   return _userInfo.timeConf[p_key]
end

--[[
    @des:得到英雄的技能信息
--]]
function getUserSkillInfo()
    return _userInfo.masterSkill
end
--[[
    @des:得到英雄的普通技能信息
--]]
function getUserNormalSkill()
    local skillInfo = getUserSkillInfo()
    require "db/DB_Heroes"
    local heroInfo = DB_Heroes.getDataById(getAvatarHtid())
    local normalInfo = skillInfo.attackSkill
    if normalInfo == nil then
        return tonumber(heroInfo.normal_attack),0
    end
    if(tonumber(heroInfo.normal_attack) == tonumber(normalInfo[1]))then
        --这种情况针对于 从星魂处得到了普通技能，但是当前装备的还是自己的普通技能
        normalInfo[2] = 0
    end
    return tonumber(normalInfo[1]),tonumber(normalInfo[2])
end

--[[
    @des:得到英雄的特殊技能信息
--]]
function getUserRageSkill()
    local skillInfo = getUserSkillInfo()
    require "db/DB_Heroes"
    local heroInfo = DB_Heroes.getDataById(getAvatarHtid())
    local rangeInfo = skillInfo.rageSkill
    if rangeInfo == nil then
        return  tonumber(heroInfo.rage_skill_attack),0
    end
    return tonumber(rangeInfo[1]),tonumber(rangeInfo[2])
end

--[[
    @des    :设置用户普通技能
    @param  :技能id
    @param  :类型  0 来自自己 1  来自名将   2   来自星魂
--]]
function setUserNormalSkill(p_skillId,p_type)
    _userInfo.masterSkill.attackSkill = {}
    _userInfo.masterSkill.attackSkill[1] = tonumber(p_skillId)
    _userInfo.masterSkill.attackSkill[2] = tonumber(p_type)
end

--[[
    @des    :设置用户怒气技能
    @param  :技能id
    @param  :类型  0 来自自己 1  来自名将   2   来自星魂
--]]
function setUserRangeSkill(p_skillId,p_type)
    _userInfo.masterSkill.rageSkill = {}
    _userInfo.masterSkill.rageSkill[1] = tonumber(p_skillId)
    _userInfo.masterSkill.rageSkill[2] = tonumber(p_type)    
end

--[[
    @des    :换回user本身的技能
    @param  :1 普通技能  2 怒气技能
    @param  :
--]]
function backToUserSkill(p_skillId,p_callfun)
    local serviceCallBack = function(cbFlag,dictData,bRet)
        if not bRet then
            return
        end
        if cbFlag == "user.removeSkill" then
            if p_callfun ~= nil then
                p_callfun()
            end
        end 

    end
    
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(p_skillId))   
    Network.rpc(serviceCallBack,"user.removeSkill","user.removeSkill",arg,true)
end

--[[
    @des:得到pid
--]]
function getPid()
    if _userInfo.pid then
        return _userInfo.pid
    else
        return 0
    end
end

--[[
    @des:得到serverId
--]]
function getServerId()
    if _userInfo.server_id then
        return _userInfo.server_id
    else
        return 0
    end
end