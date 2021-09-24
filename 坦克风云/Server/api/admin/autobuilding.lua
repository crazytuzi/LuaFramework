--建筑自动升级
function api_admin_autobuilding(request)
    local response = {
        ret=0,
        msg='success',
        data = {},
    }

      --没有开启自动升级
    if not getConfig("gameconfig").auto_build or getConfig("gameconfig").auto_build.enable~=1 then
        response.ret = -1
        return response
    end
    
    local ts = getClientTs()

    local redis = getRedis()
    -- local key = "z"..getZoneId()..".autoUpgrade.alluids"
    -- local uids =  redis:get(key)
    -- local data = {}
    -- local isUpdate = false
    -- uids = uids and json.decode(uids)
    -- --更新下未超时的玩家
    -- if not uids then
    --     local db = getDbo()        
    --     uids = db:getAllRows("select uid, auto_expire expire from buildings where auto=1 and auto_expire > :ts ",{ts=ts})
    --     isUpdate = true
    -- else 
    --     for k, v in pairs(uids) do
    --         if v.expire > ts then
    --             table.insert(data, v)
    --         elseif not isUpdate then
    --             isUpdate = true
    --         end
    --     end    
    -- end
    -- if isUpdate then
    --     redis:set(key, json.encode(data))
    -- end

    local db = getDbo()        
    uids = db:getAllRows("select uid, auto_expire expire from buildings where auto=1 and auto_expire > :ts ",{ts=ts})

    if type(uids) == 'table' and #uids > 0 then
        --print(uids)
        writeLog('auto building check ' .. #uids.." people",'auto_building')
        for k,v in pairs(uids) do
                local uobjs = getUserObjs(tonumber(v.uid))
                -- uobjs.load({"userinfo", "techs","props","buildings","bag"})
                local mUserinfo = uobjs.getModel('userinfo')
                local mProp = uobjs.getModel('props')
                local mTroop = uobjs.getModel('troops')
                local mTech = uobjs.getModel('techs')
                local mBuilding = uobjs.getModel('buildings')    
                local mBag = uobjs.getModel('bag')
                local mTask = uobjs.getModel('task')

                mProp.update()
                mProp.updateUsePropCd()
                mTroop.update()
                mTech.update()
                mBuilding.autoUpgrade()
                mTask.check()  
              
                if not uobjs.save() then
                    writeLog('uid: ' ..v.uid .." auto building failed",'auto_building')
                end

        end

        --注册下次执行
        -- local cronParams = {cmd ="admin.autobuilding",params={}}
        -- setGameCron(cronParams, 5*60)        
        key = "z"..getZoneId()..".autoUpgrade.exect"
        redis:set(key, ts)

        response.ret = 0
    end

                
    return response

end
