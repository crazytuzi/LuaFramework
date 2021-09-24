-- 战舰修理打折（常开的每日活动）
local function getFixDiscount(level,costName)
    local rate = 1

    -- 打折开关是否打开
    if switchIsEnabled("rsd") then
        local fixCfg = getConfig("dailyactive.fixdiscount")
        local ts = getClientTs()

        -- 判断用户等级，判断周几。%w:[0-6 = Sunday-Saturday]
        local today = tonumber(getDateByTimeZone(ts,"%w"))
        local h1,h2
        for k,v in ipairs(fixCfg.openWeek) do
            if v == today then
                h1=fixCfg.openTime[k][1]
                h2=fixCfg.openTime[k][2]
                break
            end
        end

        if level >= fixCfg.levelLimit and h1 and h2 then
            local weelTs = getWeeTs(ts)
            local st = weelTs + h1 * 3600
            local et = weelTs + h2 * 3600

            -- 判断小时
            if ts >= st and ts <= et then
                if costName == 'gemCost' then
                    rate = fixCfg.gemDiscount
                elseif costName == 'glodCost' then
                    rate = fixCfg.goldDiscount
                end
            end
        end
    end
    return rate
end

function api_troop_repair(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local aid =  request.params.aid and 'a' .. request.params.aid    
    local costType = request.params.costtype
    local num = tonumber(request.params.num) or 0

    if uid == nil or costType == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mTroop = uobjs.getModel('troops')
    local mUserinfo = uobjs.getModel('userinfo')
    local mSkills  = uobjs.getModel('skills')

    ------------------------------------------------
    local repairAll = {}
    if aid and mTroop.damaged[aid] then
        repairAll[aid] = num
        if repairAll[aid] == 0 or repairAll[aid] > mTroop.damaged[aid] then
            repairAll[aid] = mTroop.damaged[aid]
        end
    else
        for k,v in pairs(mTroop.damaged) do
            if v>0 then
                repairAll[k] = v
            end
        end
    end

    local tankCfg = getConfig('tank')
    local costName = costType == 2 and 'gemCost' or 'glodCost'
    local totalCostNum = 0
    local oldTroops = {}
    local newTroops = {}
    local qtFlag = 0 -- 潜艇标识

    local fixDiscount = getFixDiscount(mUserinfo.level,costName)

    for aid,num in pairs(repairAll) do
        -- 需要的资源量
        local costNum = tonumber(tankCfg[aid][costName]) or 0
        local costNums = math.ceil (costNum * num) 
        oldTroops[aid] = mTroop.troops[aid] or 0
        local desCostNums = activity_setopt(uid,'baifudali',{golds=costNums,type="repair"})
        if desCostNums then
            costNums = costNums - desCostNums
        end
        
        if costName == 'glodCost' then
            local resDiscount = activity_setopt(uid,'yongwangzhiqian',{action="getResDiscount",costName=costName,num=costNums})
            if resDiscount then
                costNums = costNums - resDiscount
            end
        end
        
        -- 修理打折
        costNums = math.ceil(costNums * fixDiscount)
        -- 全民劳动
        local laborrate = activity_setopt(uid,'laborday',{act='upRate',n=5})
        if laborrate then
            costNums = math.ceil(costNums * (1-laborrate))
        end

        
        if costNums > 0 then
            if costType == 1 then
                -- 新技能的修复减少
                local Srate=mSkills.getSkillRate(4)
                local costNums=costNums*(1-Srate)
                if not mUserinfo.useResource({gold=costNums}) then
                    response.ret = -108
                    return response
                end
            else
                if not mUserinfo.useGem(costNums) then
                    response.ret = -109
                    return response
                end
                totalCostNum = totalCostNum + costNums
            end
        end
        
        if not mTroop.repairTanks(aid,num) then            
            return response
        end      

        newTroops[aid] = mTroop.troops[aid] or 0

        if tankCfg[aid].type==2 then qtFlag=qtFlag+1 end
    end
	
    if qtFlag>0 and costName=='gemCost' then
        -- 猎杀潜航
        activity_setopt(uid,'silentHunter',{action='ms',num=1})
    end

    local mTask = uobjs.getModel('task')
    mTask.check()

    if totalCostNum > 0 then
        regActionLogs(uid,1,{action=22,item="repair",value=totalCostNum,params={oldTroops=oldTroops,newTroops=newTroops,troopsInfo=repairAll}})
    end

    processEventsBeforeSave()

    if uobjs.save() then        
        processEventsAfterSave()
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1        
    end

    return response
end
