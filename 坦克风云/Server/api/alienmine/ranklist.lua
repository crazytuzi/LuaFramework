-- 异星矿场排行榜

function api_alienmine_ranklist(request)
    
    local response = {}
    response.data={}
    
    local method = tonumber(request.params.method) or  2
    local ts = getClientTs()
    local uid = tonumber(request.uid) 
    local uobjs = getUserObjs(uid,true)
    uobjs.load({"userinfo","task","alien"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAlien    = uobjs.getModel('alien')

    local alienMineCfg = getConfig("alienMineCfg")
    local weets = getWeeTs()
    local endTime = weets + alienMineCfg.endTime[1]*3600 + alienMineCfg.endTime[2]*60+300
    local list = {}
    local function getRank(method)
        -- body
        local list={}
        local anamedata={}
        local ranklist={}
        if method==1 then

            list=getAlienMineRanking(99)
        else
            list,aidlist=getAlienMineAllinceRanking(99)
            if next(aidlist) then
                local setRet,code=M_alliance.getalliancesname{aids=json.encode(aidlist)}
                if setRet then
                    anamedata=setRet.data
                end
            end
        end
        if type(list)=='table' and next(list) then
            for k,v in pairs(list) do
                local id = tonumber(v.id)
                local item = {}
                if method==1 then
                    if id>0 then
                        local uobjs = getUserObjs(id,true)
                        local userinfo = uobjs.getModel('userinfo')
                        table.insert(item,userinfo.uid)
                        table.insert(item,userinfo.nickname)
                        table.insert(item,userinfo.level)
                        table.insert(item,v.rank)
                        table.insert(item,v.score)
                        table.insert(ranklist,item)
                    end
                else

                    table.insert(item,tonumber(v.id))
                    if anamedata[k] then
                        table.insert(item,anamedata[k].name)
                        table.insert(item,anamedata[k].level)
                    else
                        table.insert(item,"")
                        table.insert(item,0)
                    end
                    table.insert(item,k)
                    table.insert(item,v.score)
                    table.insert(ranklist,item)
                end
            end
        end
        return ranklist
    end
    local redis=getRedis()
    local ranklist={}
    local key = "z"..getZoneId()..".rank.alienMineDayrank."..method.."ts."..weets
    if ts>=endTime then
        ranklist=json.decode(redis:get(key))
        if ranklist ==nil then
            ranklist=getRank(method)
            redis:set(key,json.encode(ranklist))
            redis:expire(key,432000)
        end
    else
        ranklist=getRank(method)
    end
    local mcount=0
    if mAlien.mine_at>=weets then
        mcount=mAlien.m_count
    end
    
    response.data.mcount=mcount
    response.data.ranking = ranklist
    response.ret = 0        
    response.msg = 'Success'
    return response
end