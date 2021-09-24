-- 服内服外报名
-- lmh

function api_across_apply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local method = request.params.method   or 1 
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance <= 0 then
        return response
    end 
    local mtype=0
    local ts = getClientTs()
    local sevCfg=getConfig("serverWarTeamCfg")
    local tomail =false
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --缓存跨服军团战的基本信息
    local mMatchinfo= mServerbattle.getAcrossBattleInfo()
    if not next(mMatchinfo)  then
        return response
    end
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

    local start =tonumber(mMatchinfo.st)
    local join_start=start+(sevCfg.preparetime)*24*3600
    start=start+(sevCfg.preparetime+sevCfg.signuptime)*24*3600

    local data = {}
    data.aid=mUserinfo.alliance
    data.bid=mMatchinfo.bid
    data.zid=getZoneId()
    data.servers=mMatchinfo.servers
    data.zrank=rank
    data.name=mUserinfo.alliancename
    data.round=mMatchinfo.round
    data.st        =start
    data.et        =tonumber(mMatchinfo.et)
    data.apply_at=ts

    local ret = M_alliance.getalliance{alliancebattle=1,method=1,aid=mUserinfo.alliance} 
    data.level=ret.data.level
    data.fight=ret.data.fight
    data.num =ret.data.num
    data.logo = ret.data.logo
    data.commander=ret.data.wname

    if type(data.logo) ~= "table" then data.logo = {} end

    local teams = {}
    --[[local count=0
    for uk,uv in pairs(ret.data.members) do
        if  tonumber(uv.join_at)<=join_start  then 
            if count>=15 then
                break
            end
            table.insert(teams,tonumber(tonumber(uv.uid)))
            count=count+1
        end

    end]]
    data.teams=json.encode(teams)
    if method==1 then
        
        local endts =start+sevCfg.applyedtime[1]*3600+sevCfg.applyedtime[2]*60
        if ts < start or ts > endts then
            response.ret=-21003 
            --return response
        end
        mtype=20
        
        local acrossserver = require "model.acrossserverin"
        local across = acrossserver.new()
        local ApplyData =across:getAllianceApplyData(mMatchinfo.bid,data.zid,mUserinfo.alliance)
        if type (ApplyData)=='table' and next(ApplyData) then
            response.ret=-21006 
            return response
        end
        local ret = across:setAllianceData(data)

        if not ret then
            response.ret=-21005 
            return response
        end

        tomail=true
       
    else
        --服外的报名
        mtype=21
        local acrossserver = require "model.acrossserverin"
        local across = acrossserver.new()
        local ApplyData =across:getAllianceApplyData(mMatchinfo.bid,getZoneId(),mUserinfo.alliance)
        if type (ApplyData)=='table' and next(ApplyData) then
            response.ret=-21006 
            return response
        end

        local config = getConfig("config.z"..getZoneId()..".across")
        local senddata = data
        senddata.round=nil
        senddata.teams=teams
        senddata.servers=json.decode(mMatchinfo.servers)
        local sdata={cmd='acrossserver.setalliance',params={data=senddata,action='apply'}}
        local ret=sendGameserver(config.host,config.port,sdata)
        if ret.ret~=0 then
            response.ret=ret.ret
            return response
        end
        local ret = across:setAllianceData(data)
        if not ret  then
            response.ret=-21005 
            return response
        end
        tomail=true
    end

    if tomail then
        
        if ret.data.members then
            for k,v in pairs(ret.data.members) do
               local content = {type=mtype,aName=ret.data.aname,hName=ret.data.wname}
                content = json.encode(content)
                local muid = tonumber(v.uid)
                local ret =MAIL:mailSent(muid,1,muid,'',ret.data.aName,mtype,content,1,0)
            end
            response.ret = 0
            response.msg = 'Success'
        end
    end
    response.data.teams=teams
    return response

end