-- 设置上阵名单
function api_across_setteams(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local zid = request.zoneid
    local members = request.params.members  
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')


    if mUserinfo.alliance <= 0 then
        return response
    end 
    local mtype=0
    local ts = getClientTs()
    local sevCfg=getConfig("serverWarTeamCfg")


    local len =#members

    if len>sevCfg.numberOfBattle then
        response.ret =-102
        return response
    end

    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --缓存跨服军团战的基本信息
    local mMatchinfo= mServerbattle.getAcrossBattleInfo()



    if not next(mMatchinfo)  then
        return response
    end
    local ts = getClientTs()
    local weets      = getWeeTs()
    require "model.amatches"
    local mMatches = model_amatches()
   local start =tonumber(mMatchinfo.st)
    start=start+(sevCfg.preparetime+sevCfg.signuptime)*24*3600
    --报名结束时间
    local endts =start+sevCfg.applyedtime[1]*3600+sevCfg.applyedtime[2]*60
    if ts>endts then
        local ainfo,myround=mMatches.getMatchInfo(zid,mUserinfo.alliance,0)
        
        if myround>0 then
            local endts =weets+sevCfg.startBattleTs[myround][1]*3600+sevCfg.startBattleTs[myround][2]*60+sevCfg.warTime
            local stts = weets+sevCfg.startBattleTs[myround][1]*3600+sevCfg.startBattleTs[myround][2]*60-sevCfg.setTroopsLimit
            if ts < endts  and  ts>stts then
                response.ret =-21009
                return response
            end
        end
    end

    local tomail =false
    
    local flag =true
    local list =json.decode(mMatchinfo.info)
    local rank = 0
    for k,v in pairs(list) do
            if v[1]==mUserinfo.alliance then
                flag=false
                rank=k
            end
    end
    if flag then   
            response.ret=-21004 
            return response
    end


    local acrossserver = require "model.acrossserverin"
    local across = acrossserver.new()
    local ApplyData =across:getAllianceApplyData(mMatchinfo.bid,zid,mUserinfo.alliance)
    if not next(ApplyData) then
            response.ret=-21007 
            return response
    end
    local ret,code = M_alliance.getalliance{alliancebattle=1,method=1,aid=mUserinfo.alliance,uid=uid}
    if not ret then
        response.ret=code
        return response
    end


    if tonumber(ret.data.myrole)~=2 then
        response.ret=-8008
        return response
    end


    if not next(ret.data.members) then
        response.ret=-21008
        return response
    end

    local teams = {}
    local start =tonumber(mMatchinfo.st)
    local returnflag = false
    start=start+(sevCfg.preparetime)*24*3600
    for k,v in pairs(members)  do
        local  flag = false
        for k1,v1 in pairs(ret.data.members) do
            if tonumber(v1.uid)==v and tonumber(v1.join_at)<=start  then 
                flag=true
                break
            end
        end
        if flag then
            table.insert(teams,v)
        else
            returnflag=true
        end
    end
    
    local data = ApplyData
    data.teams=json.encode(teams)
    local senddata = {}
    senddata.teams=teams
    senddata.aid=mUserinfo.alliance
    senddata.bid=mMatchinfo.bid
    senddata.zid=zid
    local config = getConfig("config.z"..zid..".across")
    local sdata={cmd='acrossserver.setalliance',params={data=senddata,action='update'}}
    local ret=sendGameserver(config.host,config.port,sdata)
    if ret.ret~=0 then
        response.ret=ret.ret
        return response
     end



    local ret=across:updateAllianceData(data)

    if ret then 
        response.ret = 0
        if returnflag then
            response.data.teams=teams
        end
        response.msg = 'Success'
    end
    
   
    return response



end