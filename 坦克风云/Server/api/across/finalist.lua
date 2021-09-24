--抓去参加跨服军团战前几个军团名称
function api_across_finalist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    
    local battletype = 2
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --1 个人战
        --缓存跨服战的基本信息
    local mMatchinfo, code = mServerbattle.getAcrossBattleInfo()
    

    writeLog('afinalist-----------info -------'..json.encode(mMatchinfo)..'----------- info','setAerror')
    if not next(mMatchinfo)  then
        return response
    end
    
    local sevCfg={}
    if battletype==1 then
        sevCfg=getConfig("serverWarPersonalCfg")
    else
        sevCfg=getConfig("serverWarTeamCfg")
    end
    local servers=table.length(json.decode(mMatchinfo.servers))
    local count  =math.floor(sevCfg.sevbattleAlliance/servers)
    local preparetime=sevCfg.preparetime
    local updated_at = tonumber(mMatchinfo.updated_at)
    local weets      = getWeeTs(updated_at)
    local start =tonumber(mMatchinfo.st)
    start=start+(preparetime)*24*3600
     -- 判断今天抓完数据 就不用在抓了啊！
    if weets==start then
         response.ret=0
         response.msg = 'Success'
         response.data ={"send data ok"}
         return response
     end

    local ts =getWeeTs()

    if ts~=start then
         response.ret=0
         response.msg = 'Success'
         response.data ={"day error"}
         return response
    end
    

    local battleinfo={}
    battleinfo.info=json.encode(list)
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local ret = M_alliance.getalliance{alliancebattle=1,count=count,method=0}    
    if ret then 
       local list ={}
       local members = {}
       if ret.data.ranklist then
            for k,v in pairs(ret.data.ranklist) do
                local commander_id=tonumber(v.commander_id)
                local item ={tonumber(v.aid),v.name}
                table.insert(list,item)
                members[commander_id]=v.name
            end
       end
       local battleinfo={}
       battleinfo.info=json.encode(list)
       battleinfo.type=2
       local ret = mServerbattle.setserverbattlecfg(mMatchinfo.id,battleinfo)
       if ret then
        
            for k,v in pairs(members) do

                local content = {type=19,aName=v}
                content = json.encode(content)

                local ret =MAIL:mailSent(k,1,k,'',v,19,content,1,0)

            end
            writeLog('afinalist-----------ok -------'..json.encode(list)..'----------- info','setAerror')
            response.ret = 0
            response.msg = 'Success'
       end
   
    end
    return response
end