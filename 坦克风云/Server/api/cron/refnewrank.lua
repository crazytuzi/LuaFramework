--  每天第一个人来触发刷新军衔
function api_cron_refnewrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local cuuturt =getWeeTs()+10800
    local redis = getRedis()
    local key = "z"..getZoneId()..".refUserNewRank.ts."..cuuturt
    local uid   = request.params.uid or 0
    local admin = request.params.admin  or 0

    -- 验证入口机时间
    local zoneid=getZoneId()
    local url=getConfig("config.z".. zoneid ..".giftCenterUrl")
    if  url==nil then
        response.ret=-102
        response.msg ='error'
        response.data={'url error'}
        return response
    end
    url=url.."getservertime"
    local http = require("socket.http")
    http.TIMEOUT= 5
    local sendret = http.request(url)

    local sendret = sendret and json.decode(sendret)

    if type(sendret) ~= "table" or sendret.ret ~= 0 or  sendret.time == nil then
        response.ret=-102
        response.msg ='error'
        response.data={'time not retun  error'}
        return response
    end
    local ts = getClientTs()
    if math.abs((tonumber(sendret.time)- ts))>60 then
        response.ret=-102
        response.msg ='error'
        response.data={'time error'}
        return response
    end

    -- 如果今天没有刷新最新的军衔  要执行一下跑今天前100
    local refret=redis:get(key)
    if refret~=nil and tonumber(refret) == 1 and admin==0 then
        response.ret=0
        response.msg ='Success'
        response.data={'ref ok'}
        return response
    end
    redis:set(key,1)
    redis:expireat(key,cuuturt+2*24*3600)

    if admin==1 then
       local delkey = "z"..getZoneId()..".dayUserNewRank.All"
       redis:del(delkey)
    end
    local rankCfg =getConfig("rankCfg")
    local dayrankkey = "z"..getZoneId()..".dayUserNewRank.All.100"..cuuturt
    local daylist = {}
    local ranklist =getNewRankRanking(0,rankCfg.listLength+100-1)
    local _havecount = {}
    for i=1, #rankCfg.rank do
        _havecount[i] = 0
    end

    if next(ranklist) then
        for k,v in pairs(ranklist) do
            --大于前100的就算一下今天获得战功
            --if v.uid~=uid then
                local uobjs = getUserObjs(tonumber(v.uid),true)
                local userinfo = uobjs.getModel('userinfo')

                local oldurt=userinfo.urt
                if oldurt==0 then  urt=cuuturt  end
                -- 军工算衰减,（今天自己没有衰减过）
                if userinfo.rp>rankCfg.minPoint and userinfo.urt ~= cuuturt then
                    userinfo.rp=rankCfg.minPoint+math.floor((userinfo.rp-rankCfg.minPoint)*math.pow((1-rankCfg.pointDecrease),((cuuturt-oldurt)/86400)))
                end
                -- 排名100之外刷新军衔
                if k>(rankCfg.listLength+50) then
                    -- if userinfo.rp >=rankCfg.minRankPoint then
                    --     userinfo.setRank(rankCfg.minRank)
                    --     if userinfo.level<rankCfg.minlevel then
                    --         userinfo.updateRank(userinfo.rp)
                    --     end

                    -- else
                    --     userinfo.updateRank(userinfo.rp)
                    -- end
                    -- 等级或军工不够，直接更新军衔
                    if userinfo.rp<rankCfg.minRankPoint or userinfo.level<rankCfg.minlevel then
                        userinfo.updateRank(userinfo.rp)
                    else
                        -- 都够，固定军衔
                        userinfo.setRank(rankCfg.minRank)
                    end
                else
                    
                    local isUpdate = false
                    --等级或军工不够，直接更新军衔
                    if userinfo.level<rankCfg.minlevel or userinfo.rp < rankCfg.minRankPoint then
                            userinfo.updateRank(userinfo.rp)
                            isUpdate = true
                    end

                    -- 军工和军衔都符合条件，有人数限制, 设置军衔
                    if isUpdate == false then
                        for i=#rankCfg.rank,1,-1 do
                            local rv = rankCfg.rank[i]
                            if next(rv.ranking) then
                                local cntlimit = rv.ranking[2] -rv.ranking[1] + 1
                                if userinfo.level>=rv.lv and userinfo.rp >=rv.point and _havecount[i] < cntlimit then
                                    userinfo.setRank(rv.id)
                                    _havecount[i] = _havecount[i] + 1
                                    isUpdate = true
                                    break 
                                end
                            end 
                        end
                    end
                    --等级和军工都够，没进前100，设置军衔
                    if isUpdate == false and (userinfo.level > rankCfg.minlevel and userinfo.rp >= rankCfg.minRankPoint)  then
                        userinfo.setRank(rankCfg.minRank)
                    end
                    --print(v.uid, userinfo.rank, userinfo.level, userinfo.rp)
                    if k <= rankCfg.listLength then 
                        table.insert(daylist,v)
                    end

                end
                userinfo.urt=cuuturt
                userinfo.drp=0
                setNewRankRanking(tonumber(v.uid),userinfo.rp)
                if not uobjs.save() then 
                    table.insert(response.data,uid)
                end

            --end
        end

    end
    
    redis:set(dayrankkey,json.encode(daylist))
    redis:expireat(dayrankkey,cuuturt+5*24*3600)
    response.ret=0
    response.msg ='Success'
    return response

end