local function api_admin_tool(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["action_worldwarTestApply"] = {
                join = {"required","number"},
            },
        }
    end

    -- function self.before(request) end

    function self.action_refreshMilitaryRanking(request)
        local response = self.response
        local db = getDbo()
        local redis = getRedis()

        -- 删除无排名的数据
        db:query("delete FROM `userarena` WHERE `ranking` =0 ")

        local res = db:getAllRows("select uid,ranking from userarena order by ranking ASC") 
        if type(res)=='table' and next(res) then
            for k,v in pairs (res) do
                if k>tonumber(v.ranking) then
                    local key = "z"..getZoneId()..".udata."..v.uid
                    db:update("userarena",{ranking=k},"uid="..v.uid)
                    redis:del(key)
                end
            end
        end
        redis:del("z"..getZoneId()..".rank.arena")

        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 世界大战塞测试数据
    function self.action_worldwarTestApply(request)
        local response = self.response

        local uid = request.uid
        local method = request.params.join or 1 
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","task"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mTroop = uobjs.getModel('troops')
        local ts = getClientTs()
        local sevCfg=getConfig("worldWarCfg")
        local zoneid=request.zoneid
        require "model.serverbattle"
        local mServerbattle = model_serverbattle()
            --世界大战基本信息
        local mMatchinfo= mServerbattle.getWorldWarBattleInfo()
        if not next(mMatchinfo)  then
            response.ret = -101
            return response
        end
        
        -- 检测是否报名
        local worldserver = require "model.worldserverin"
        local cross = worldserver.new()
        local ApplyData =cross:getUserApplyData(mMatchinfo.bid,zoneid,uid)
        if type (ApplyData)=='table' and next(ApplyData) then
            response.ret=-22006 
            return response
        end

        local ts =getClientTs()
        local start =tonumber(mMatchinfo.st)
        endts=start+sevCfg.signuptime*24*3600

        local testtroops = {}
        for i=2,502 do
            table.insert(testtroops,{
                    {"a10001",i},
                    {"a10001",i},
                    {"a10001",i},
                    {"a10001",i},
                    {"a10001",i},
                    {"a10001",i}
                }
            )
        end

        local count=1
        local datatable={}
        for i=zoneid*1000000+20000+method*10000,zoneid*1000000+20000+method*10000+100 do
            --插入数据
            local data={}
            data.uid=i
            data.bid=mMatchinfo.bid
            data.zid=zoneid
            data.level=30
            data.nickname=i
            data.pic=1
            data.rank=12
            data.fc=i
            data.aname=""
            data.st=endts
            data.et=mMatchinfo.et
            data.apply_at=ts
            data.jointype=method
            data.strategy={1,2,3}
            local binfo=mTroop.getFleetdata(testtroops[count],testtroops[count],testtroops[count],{},{},{})
            data.binfo=binfo
            
            table.insert(datatable,data)
            count=count+1
        end

        setRandSeed()
        for i=1,100 do
            local len =#datatable
            local key =rand(1,len)
            local config = getConfig("config.z"..getZoneId()..".worldwar")
            local sdata={cmd='worldserver.setuser',params={data=datatable[key],action='apply'}}
            local ret=sendGameserver(config.host,config.port,sdata)

            if ret.ret~=0 then
                response.ret=ret.ret
                return response
            end
            table.remove(datatable,key)
            --data.st=nil
        end

        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- function self.after() end

    return self
end

return api_admin_tool