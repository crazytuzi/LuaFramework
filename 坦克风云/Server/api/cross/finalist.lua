--抓去参加跨服战前几名人员信息

function api_cross_finalist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local count   = tonumber(request.params.count) or 0
    local battletype =request.params.type or 1
   
    local function getdata(uid,rank,fleetInfo1,fleetInfo2,fleetInfo3,sevCfg,info,nama,level,fc,pic,newrank,aname,bpic,apic,aid,logo)


        local npc=sevCfg.npc
        --uid 
        local params = {}
        params[1]=uid
        --name
        params[2]=nama or npc.name..uid
        --服务器ID
        params[3]=getZoneId()
        -- 公会名称
        params[4] =aname or ''
        -- 头像(pic)
        params[5]=pic or npc.pic
        -- 军衔
        params[6]=newrank or  npc.rank
        -- 等级
        params[7]=level or npc.level
        --战斗力
        params[8]=fc or npc.fc
        --坦克数据 
        params[9]={{},{}}
        
        --st 
        
        --st
        params[10]=tonumber(info.st)+sevCfg.preparetime*24*3600
        --et
        params[11]=tonumber(info.et)
        -- 战斗id
        params[12]=info.matchId
        --跨服所有服
        params[13]=json.decode(info.servers)
        -- --排名
        
        params[14]=rank
        local keys={}
        for k,v in pairs (fleetInfo1[1]) do   
            table.insert(keys,k)
        end 
        params[9][1]=keys
        params[9][2]={}
        local troops = {}    
        for i=1,3 do
            for k,v in pairs(keys) do
                local  attfleetInfo = {}
                if(i==1) then
                    attfleetInfo=fleetInfo1
                end
                if(i==2) then
                    attfleetInfo=fleetInfo2
                end
                if(i==3) then
                     attfleetInfo=fleetInfo3
                end
                for k1,v1 in pairs(attfleetInfo)  do
                    if type (troops[i]) ~='table' then troops[i]={} end
                    if type (troops[i][k1])~='table' then troops[i][k1]={}  end
                    if next(v1) then 
                        troops[i][k1][k]=v1[v]
                    end
                    
                end
            end
        end

        params[9][2]=troops
        params[15] =bpic or ''
        params[16] =apic or ''
		-- 军团id 
        params[17]=aid or 0
        -- 军团logo
        params[18]=logo or "[]"
        return params
        -- body
    end 
    require "model.matches"


    local mMatches = model_matches(true)

    local info =mMatches.base  

    writeLog('finalist-----------info -------'..json.encode(info)..'----------- info','setuserserror')
    if not next(info)  then
        response.ret = mMatches.errorCode

        return response
    end
    local sevCfg={}
    if battletype==1 then
        sevCfg=getConfig("serverWarPersonalCfg")
    else
        sevCfg=getConfig("serverWarCfg")
    end
    local servers=table.length(json.decode(info.servers))
   
    
    count =math.floor(sevCfg.sevbattlePlayer/servers)
   
    local preparetime=sevCfg.preparetime
    local updated_at = tonumber(info.updated_at)
    local weets      = getWeeTs(updated_at)
    local start =tonumber(info.st)
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
    
    local oldinfo =json.decode(info.info)


    local pcount = 1
    local list = {}
    if type(oldinfo)=='table' and next(oldinfo) then
        list=oldinfo
    else
        list = getArenaTopRank(sevCfg.militaryrank,count)
        local length=#list
        if (length<count) then
            for i=length+1,count do
                local item = {i,i}
                table.insert(list,item) 
            end

        end 
    end
    
    local battleinfo={}
    battleinfo.info=json.encode(list)
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()

    local ret = mServerbattle.setserverbattlecfg(info.id,battleinfo)
    local udata = {}
    for k,v in pairs(list) do
        list[k][2]=k
        local  rank =k
        if next(v) then
            local muid=v[1]
            if muid>1000000 then
                local uobjs = getUserObjs(muid)
                local userinfo = uobjs.getModel('userinfo')
                local name=""
                if (userinfo.alliance~=nil and userinfo.alliance>0) then
                    name=userinfo.alliancename
                end
                local fleetInfo=sevCfg.troops
                local fl = initTankAttribute(fleetInfo)

                -- 天梯榜优化加上军团logo
                local logo
                if tonumber(userinfo.alliance) > 0 then
                    local result = M_alliance.get{aid=userinfo.alliance,uid=muid}
                    if result.ret == 0 then
                        if type (result.data) == 'table' and type(result.data.alliance) == 'table' and next(result.data.alliance) then
                            logo = json.encode(result.data.alliance.logo)
                        end
                    end
                end

                local data=getdata(muid,rank,fl,fl,fl,sevCfg,info,userinfo.nickname,userinfo.level,userinfo.fc,userinfo.pic,userinfo.rank,name,userinfo.bpic,userinfo.apic,userinfo.alliance,logo)
                data[14]=rank
                --local data2=copyTable(data)
                --data2[1]=data2[1]+1000000
                --data2[3]=data2[3]*2
                table.insert(udata,data)
                --table.insert(udata,data2)
                

            else
            --补充机器人
                local fleetInfo=sevCfg.troops
                local fl = initTankAttribute(fleetInfo)
                local data ={}
                data=getdata(rank,rank,fl,fl,fl,sevCfg,info)
                --local data2=copyTable(data)
                --data2[1]=data2[1]*2
                --data2[3]=data2[3]*2
                table.insert(udata,data)
                --table.insert(udata,data2)-
            end
        
        end


       

    end
    
    if ret then 
        mMatches.clearCache()
        response.data ={}
        local data={cmd='crossserver.setusers',params={udata=udata}}
        local config = getConfig("config.z"..getZoneId()..".cross")

        for i=1,5 do
            local ret=sendGameserver(config.host,config.port,data)
            
            if  ret==nil or (type(ret)=='table' and ret.ret~=0) then
                writeLog('finalist----'..json.encode(config)..'-------error-------'..json.encode(list)..'-----------  error','setuserserror')
                local battleinfo={}
                battleinfo.info=info.info
                battleinfo.updated_at=tonumber(info.updated_at)
                mServerbattle.setserverbattlecfg(info.id,battleinfo)
                mMatches.clearCache()
                return response
            end

            if ret.ret==0 then
                    --成功后发邮件
                    for k,v in pairs(list) do
                         if v[1]>1000000 then
                            local content = {}
                            content.ts=start
                            content.type=15
                            MAIL:mailSent(v[1],1,v[1],'','',15,content,1,0)
                         end
                    end
                    response.ret = 0
                    response.msg = 'Success'
                    
                 break
            end
        end

        
       
    end
    return response
end