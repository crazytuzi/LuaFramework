-- 检测各种服务是否正常


function api_admin_checkserverstats(request)

    local response = {
            ret=-1,
            msg='error',
            data = {},
            stat={},
        }


    local port=tonumber(request.params.port)
    -- 检测work是不是最新的
    local cronParams = {cmd ="admin.getstats",params={checkserver=1}}
    if not (setGameCron(cronParams,1)) then
        setGameCron(cronParams,1) 
    end

    local redis = getRedis()
    local key="zid."..getZoneId().."checkserver"
    local work=redis:get(key)
    local workdesc=""
    if tonumber(work)==1 then
        workdesc="worker 正确"
    elseif tonumber(work)==0 then
        workdesc="worker 不是最新的"
    else
        work=-1
        workdesc="worker 正在检测中请重试"
    end

    response.stat['tank-worker']=work
    response.data['tank-workerdesc']=workdesc
    

   
    


    local config=getConfig("config.z"..getZoneId())
    local portid=tonumber(port%100)
    local redisprot=port+100
    local sport=11300
    local chatport=3002
    
    if portid~=1 then 
        sport=11300+portid
        chatport=chatport+portid*10
    end
    response.stat['scheduleJob']=1
    response.data['scheduleJobdesc']="scheduleJob配置正常"
     -- scheduleJob  配置
    if  sport~=config.scheduleJob.port then
        response.stat['scheduleJob']=0
        response.data['scheduleJobdesc']="scheduleJob端口配置错误"..config.scheduleJob.port
    end
    -- redis
     -- scheduleJob  配置
    response.stat['redis']=1
    response.data['redisdesc']="redis配置正常"
    if  redisprot~=config.redis.port then
        response.stat['redis']=0
        response.data['redisdesc']="redis端口配置错误"..config.redis.port
    end
    --string.sub(目标字符串,起始位置，长度+起始位置)
    local chatUrl=config.chatUrl
    local chatstr=tonumber(string.sub(chatUrl,string.len(chatUrl)-4,-2))
    -- 聊天 
    response.stat['chat']=1
    response.data['chatdesc']="聊天配置正常"
    if  chatstr~=chatport then
        response.stat['chat']=0
        response.data['chatdesc']="聊天端口配置错误"..chatstr
    end

    local actionLogUrl=config.actionLogUrl

    
    local actionlog= string.split(actionLogUrl,"?")
    local actionlog=string.split(actionlog[1],"z")
    local zid=tonumber(actionlog[2] or 0)
    response.stat['actionLog']=1
    response.data['actionLogdesc']="金币日志配置正常"
    if zid~=getZoneId() then
        response.stat['actionLog']=0
        response.data['actionLogdesc']="金币日志配置错误服"..zid
    end
    

    -- 大战
    if type(config.cross)=="table" and next(config.cross) then
        response.stat['cross']=1
        response.data['crossdesc']="个人跨服战配置"..json.encode(config.cross)
        if config.cross.port~=17001 then
            response.stat['cross']=0
            response.data['crossdesc']="个人跨服战配置端口错误"..config.cross.port
        end
    else
        response.stat['cross']=0
        response.data['crossdesc']="未配置个人跨服战配置"
    end

    if type(config.across)=="table" and next(config.across) then
        response.stat['across']=1
        response.data['acrossdesc']="军团跨服战配置"..json.encode(config.across)
        if config.across.port~=17002 then
            response.stat['across']=0
            response.data['acrossdesc']="军团跨服战配置端口错误"..config.across.port
        end
    else
        response.stat['across']=0
        response.data['acrossdesc']="未配置军团跨服战配置"
    end

    if type(config.worldwar)=="table" and next(config.worldwar) then
        response.stat['worldwar']=1
        response.data['worldwardesc']="世界争霸配置"..json.encode(config.worldwar)
        if config.worldwar.port~=17003 then
            response.stat['worldwar']=0
            response.data['worldwardesc']="世界争霸配置端口错误"..config.worldwar.port
        end
    else
        response.stat['worldwar']=0
        response.data['worldwardesc']="未配置世界争霸配置"
    end


    -- 检测gameserver 
    response.stat['gameserver']=1
    response.data['gameserverdesc']="gameserver 正确"
    if  tonumber(getClientIP())==0 then
        response.stat['gameserver']=0
        response.data['gameserverdesc']="gameserver不是最新版本"
    end

    --cross = {host='127.0.0.1', port= 17001},
      --  across = {host='127.0.0.1', port= 15005},
        --worldwar={host='127.0.0.1', port= 15004}, --世


    -- 军团的检测
    local ret=M_alliance.getalliance({getconfig=1})
    local alliancestat=0
    local alliancedesc="军团配置检测失败请重试"
    if ret then
        if ret.db then
            alliancestat=1
            local tank = config.mysql.db:split('_') 
            local alliance = ret.db.dbname:split('_') 
            local aredis=ret.redis.port
            local tredis=config.redis.port
            if tredis~=aredis then
                alliancedesc="军团缓存端口错误"..aredis
                alliancestat=0
            end
            if tank[2]~=alliance[2] then
                if alliancestat==0 then
                    alliancedesc=alliancedesc.."军团数据库错误"..ret.db.dbname
                else
                    alliancedesc="军团数据库错误"..ret.db.dbname
                end
                alliancestat=0
            end

            if alliancestat==1 then
                alliancedesc="军团配置正确"
            end
            response.stat['alliance']=alliancestat
            response.data['alliancedesc']=alliancedesc
        end
    end


   





    response.msg = 'Success'
    response.ret = 0

    return response

end