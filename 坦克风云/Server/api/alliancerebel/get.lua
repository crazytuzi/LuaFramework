-- 获取叛军信息

function api_alliancerebel_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
        },
    }

    -- 军团叛军没有开启
    if moduleIsEnabled('acerebel')  == 0 then
        response.ret = -17000
        return response
    end

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    local get = tonumber(request.params.get)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","hero","userforces","userexpedition"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserforces = uobjs.getModel('userforces')
    local ts = getClientTs()
    local weets = getWeeTs()
    local killcount=0
    local limit=10
    local find={}
    local over={}
    local select={}
    local overlist={}
    if mUserinfo.alliance>0 and get~=1 then
        local battlelogLib=require "lib.battlelog"
        local result,kill=battlelogLib:allianceLogGet(mUserinfo.alliance,uid)
        killcount=kill
        response.data.killlog=result
        local ret=M_alliance.getforces{aid=mUserinfo.alliance,uid=uid}
        local mRebel = loadModel("model.rebelforces")
        --local rebelInfo = mRebel.getRebelInfo(mapId) 
        if ret~=nil and ret.data~=nil then
            local info =json.decode(ret.data)
            if type(info)=="table" and next(info) then
                for k,v in pairs(info) do
                    --  mapid  过期时间  等级 ，名字的id   最大血量，当前
                    -- v=$id,$ts,$lvl,$nid
                    local mid=v[1]
                    local ets=v[2]
                    local lvl=v[3]
                    local rfname=v[4]
                    if  ets>ts and #find<limit then
                        local rebelInfo = mRebel.getRebelInfo(v[1]) 
                        if type(rebelInfo)=='table' and tonumber(v[2])==tonumber(rebelInfo.expireTs) then
                            if rebelInfo.isDie~=nil then
                                if rebelInfo.isDie~=mUserinfo.alliance then
                                    table.insert(over,{mid.."-"..ets,lvl,rfname,ets})
                                    table.insert(select,"'"..mid.."-"..ets.."'")
                                end
                            else
                                --mid  过期时间 等级 ，名字的id   最大血量，当前剩余血量
                                table.insert(find,{mid,ets,lvl,rfname,rebelInfo.maxHp,rebelInfo.hp,rebelInfo.x,rebelInfo.y})    
                            end
                        end
                    else
                        if ets>weets then
                            table.insert(over,{mid.."-"..ets,lvl,rfname,ets})
                            table.insert(select,"'"..mid.."-"..ets.."'")
                        else
                            break
                        end
                    end

                    
                end
            end
            if next(select) then
                -- 找出被击杀今天的记录
                local log=battlelogLib:allianceLogGetData(select,mUserinfo.alliance)
                for k,v in pairs (over) do
                    if #overlist>=limit then
                        break
                    end
                    local addflag=true
                    local info={}
                    for lk,lv in pairs(log) do
                        if tostring(lv.dieid)==tostring(v[1])  then
                            info=lv
                            if tonumber(lv.aid)==mUserinfo.alliance  then
                                addflag=false
                                break
                            end
                        end
                    end

                    if addflag then
                        -- 没有逃跑
                        if next(info) then
                            -- 名字id  mid+过期时间  ,击杀时间   等级 ，   击杀军团名字
                            table.insert(overlist,{v[3],info.dieid,info.kill_at,v[2],info.alliancename})
                        else --逃跑
                            --                    逃跑时间   根据第五个位置判断
                            table.insert(overlist,{v[3],v[1],v[4],v[2]})
                        end
                        
                    end

                end
            end
        end
    end
    
    response.data.forcesfind = find
    response.data.overlist= overlist
    response.data.userforces = mUserforces.toArray(true)
    response.data.userforces.killcount=killcount
    response.ret = 0
    response.msg = 'Success'
    return response
end