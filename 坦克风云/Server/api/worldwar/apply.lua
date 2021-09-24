-- 世界大战报名报名

function api_worldwar_apply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local method = request.params.join   or 1 
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local ts = getClientTs()
    local sevCfg=getConfig("worldWarCfg")
    local zoneid=request.zoneid
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --世界大战基本信息
    local mMatchinfo= mServerbattle.getWorldWarBattleInfo()
    if not next(mMatchinfo)  then
        return response
    end
    local ts =getClientTs()
    local start =tonumber(mMatchinfo.st)
    endts=start+sevCfg.signuptime*24*3600
    --报名结束时间
    if ts> endts then
        response.ret=-22003
        return response
    end

    if mUserinfo.rank <sevCfg.signRank then
        response.ret=-22004
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


    --插入数据
    local data={}
    data.uid=uid
    data.bid=mMatchinfo.bid
    data.zid=zoneid
    data.aid=mUserinfo.alliance
    data.level=mUserinfo.level
    data.nickname=mUserinfo.nickname
    data.pic=mUserinfo.pic
    data.bpic=mUserinfo.bpic
    data.apic=mUserinfo.apic
    data.rank=mUserinfo.rank
    data.fc=mUserinfo.fc
    data.aname=mUserinfo.alliancename
    data.st=endts
    data.et=mMatchinfo.et
    data.apply_at=ts
    data.jointype=method
    data.strategy={1,2,3}
    local config = getConfig("config.z"..getZoneId()..".worldwar")
    local sdata={cmd='worldserver.setuser',params={data=data,action='apply'}}
    local ret=sendGameserver(config.host,config.port,sdata)
    if ret.ret~=0 then
        response.ret=ret.ret
        return response
    end
    data.st=nil
    data.et=nil
    data.aid=nil
    data.strategy=json.encode(data.strategy)
    local ret,err = cross:setUserApplyData(data)
    if not ret then
        response.ret=-22005
        response.error=err 
        return response
    end
    response.ret = 0
    response.msg = 'Success'
    return response

end