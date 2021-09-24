-- 
-- 远洋征战定时结算 报名/竞选元帅,队长 结算
-- yunhe
-- 
function api_cron_oceanexpedition(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local zoneid = getZoneId()
    local ts = getClientTs()
    local weeTs = getWeeTs()

    writeLog("远洋征战定时脚本" .. ts, "ocean")
    -- 判断当前是哪种结算
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local oceaninfo,code = mServerbattle.getOceanExpeditionInfo()
    if code~=0 or not next(oceaninfo) then
        response.ret = -102
        response.msg = 'not open'
        return response
    end

    local bid = tonumber(oceaninfo.bid)
    local cfg = getConfig("oceanExpedition")
    local db = getDbo()
    local mOceanMatch = getModelObjs("oceanmatches",bid,false,true)
    if not mOceanMatch then
        writeLog("远洋征战定时脚本未获取到mOceanMatch当前bid="..bid, "ocean")
    end

    -- 加成员 
    local function addmem(bid,tid,add,oceaninfo,addtype)
        local noteam = db:getAllRows("select uid from oceanexpedition where bid="..bid.." and info!='{}' and tid=100 and job=3 and apply_at>="..oceaninfo.st.." and apply_at<="..oceaninfo.et.." order by fc desc") 
        if type(noteam)=='table' and next(noteam) and add>0 and tid>0 then
            for i=1,add do
                if noteam[i] then
                    local uid = tonumber(noteam[i]['uid'])
                    local get,uobjs = pcall(getUserObjs,uid)
                    if get then
                        uobjs.load({"oceanexpedition"})
                        local mOcean = uobjs.getModel('oceanexpedition')
                        -- 给不存在队伍补队员
                        if not addtype then
                            -- 给队伍第一个人设置队长
                            if i==1 then
                                mOcean.job = 2
                                mOceanMatch.joinTeam(tid+1,uid,2,mOcean.fc)
                            else
                                mOceanMatch.joinTeam(tid+1,uid,3,mOcean.fc)
                            end
                        else
                            mOceanMatch.joinTeam(tid+1,uid,3,mOcean.fc)
                        end 

                        writeLog("给没队伍的玩家分配队伍:uid="..uid..'job='..mOcean.job..'tid='..tid,"ocean")

                        mOceanMatch.save()
                        
                        mOcean.appteam = {0,0,0,0,0}
                        mOcean.tid = tid
                        mOcean.canMaster = 0
                        mOcean.signUpStatus = 0
                       
                        uobjs.save()

                    end
                end
            end
        end
    end

    -- 给直接加入队伍且队伍没队长的队伍设置队长
    local function setleader(bid)
        for i=1,5 do
            local result = db:getRow("select * from oceanexpedition where job=2 and tid=:tid and bid= :bid",{bid=bid,tid=i})
            if type(result)~='table' or not next(result) then
                local row = db:getRow("select uid from oceanexpedition where job=3 and tid=:tid and bid= :bid order by fc desc limit 1",{bid=bid,tid=i})
                if type(row)=='table' and next(row) then
                    local uid = tonumber(row.uid)
                   
                    local get,uobjs = pcall(getUserObjs,uid)
                    if get then
                         uobjs.load({"oceanexpedition"})
                         local mOcean = uobjs.getModel('oceanexpedition')
                         mOcean.job = 2
                         mOceanMatch.joinTeam(i+1,uid,2,mOcean.fc)
      
                         uobjs.save()
                         writeLog("给直接加入队伍且队伍没队长的队伍设置队长"..uid..'tid='..i, "ocean")
                    end
                end
            end
        end
    end
  
    -- 报名/元帅竞选 
    if mOceanMatch.isstage1(ts,tonumber(oceaninfo.st),cfg) then
        local players = {}
        local failplayers = {}
        local res = db:getAllRows("select uid,nickname,job,signUpStatus from oceanexpedition where job=0 and signUpStatus>0 and bid= "..bid.." and apply_at>="..oceaninfo.st.." and apply_at<="..oceaninfo.et.." order by fc desc") 
        if type(res)=='table' and next(res) then
            local n = 1
            local marshal = false 
            local marshalname = nil
            for k,v in pairs(res) do
                local uid = tonumber(v['uid'])
                local get,uobjs = pcall(getUserObjs,uid)
                if get then
                    uobjs.load({"oceanexpedition"})
                    local mOcean = uobjs.getModel('oceanexpedition')
     
                    if n<=51 then
                        if not marshal then
                            if tonumber(v.signUpStatus) == 1 then
                                marshal = true
                                local content = {type=82,name=v.nickname,zid=zoneid,bid=bid}
                                content = json.encode(content)
                                local ret =MAIL:mailSent(uid,1,uid,'',v.nickname,82,content,1,0)

                                marshalname = v.nickname
                                mOcean.job = 1
                                mOcean.tid = 0
                                mOceanMatch.joinTeam(1,uid,1)

                                mOceanMatch.save()
                                writeLog("设置元帅uid:"..uid, "ocean")
                            end
                        else-- 有统帅了 其他的都是队员
                            if mOcean.signUpStatus ==1 then -- 其他申请过元帅的 需要把积分再扣除了（申请的时候加了）
                                if mOcean.score>cfg.marChoosePoint then
                                    mOcean.score = mOcean.score - cfg.marChoosePoint
                                else
                                    mOcean.score = 0
                                end

                                if marshalname then
                                    local content = {type=83,name=v.nickname,zid=zoneid,bid=bid,mname=marshalname}
                                    content = json.encode(content)
                                    local ret =MAIL:mailSent(uid,1,uid,'',v.nickname,83,content,1,0)
                                end
                            end
                            
                        end
                        if mOcean.job == 0 then
                            mOcean.job = 3
                            mOcean.tid = 100
                        end
                        mOcean.signUpStatus = 0
                        -- 报名成功邮件
                        local content = {type=80,name=v.nickname,zid=zoneid,bid=bid}
                        content = json.encode(content)
                        local ret =MAIL:mailSent(uid,1,uid,'',v.nickname,80,content,1,0)
                        if mOcean.job==3 then
                            if mOceanMatch.qualification(uid,tonumber(oceaninfo.st),cfg.tlLimit) then
                                mOcean.canMaster = 1
                            end
                        end

                        table.insert(players,uid)
                    else--多余的名额  都视为无效报名数据 
                        mOcean.bid = 0
                        --mOcean.apply_at = 0  
                        -- 报名失败发邮件
                        local content = {type=81,name=v.nickname,zid=zoneid,bid=bid}
                        content = json.encode(content)
                        local ret =MAIL:mailSent(uid,1,uid,'',v.nickname,81,content,1,0)
                        table.insert(failplayers,uid)
                    end
                    uobjs.save()
                    n = n+1
                end     
            end
        end
        writeLog("报名/元帅定时ts=" .. ts..'结果:'..json.encode(players), "ocean")
        writeLog("报名/元帅定时 取消资格的玩家:"..json.encode(failplayers), "ocean")
    end

    -- 确认队长
    if mOceanMatch.isstage2(ts,tonumber(oceaninfo.st),cfg) then
        local players = {}
        local failplayers = {}
        local res = db:getAllRows("select uid,nickname,job from oceanexpedition where signUpStatus=2 and bid= "..bid.." and apply_at>="..oceaninfo.st.." and apply_at<="..oceaninfo.et.." order by fc desc") 
        if type(res)=='table' and next(res) then
            local n = 1
            for k,v in pairs(res) do
                local uid = tonumber(v['uid'])
                local get,uobjs = pcall(getUserObjs,uid)
                if get then
                    uobjs.load({"oceanexpedition"})
                    local mOcean = uobjs.getModel('oceanexpedition')
            
                    if n<=5 then   
                        mOcean.job = 2
                        mOcean.tid = n -- 队伍编号
                        mOceanMatch.joinTeam(n+1,uid,2,mOcean.fc)
                        mOceanMatch.save()
                        table.insert(players,uid)
                    else--多余的名额  扣除积分
                        if mOcean.score>cfg.tlChoosePoint then
                            mOcean.score = mOcean.score - cfg.tlChoosePoint
                        else
                            mOcean.score = 0
                        end
                        mOcean.job = 3
                        table.insert(failplayers,uid)
                    end
                    mOcean.signUpStatus = 0
                    mOcean.canMaster = 0
                    uobjs.save()
                    n = n+1
                end
            end
        end
        writeLog("选定队长定时 结果：" ..json.encode(players), "ocean")
        writeLog("选定队长定时 取消资格的玩家:"..json.encode(failplayers), "ocean")
    end

    -- 队伍结算 没有队长的队伍设置队长  分配没队伍的报名玩家
    if mOceanMatch.isstage3(ts,tonumber(oceaninfo.st),cfg) then    -- 检测队id
        local team = {1,2,3,4,5}
        -- 直接申请加入队伍 且该队伍没队长的分配队长
        setleader(bid)
        -- 分配队员
        local res = db:getAllRows("select distinct(`tid`),count(*) as num from oceanexpedition where bid="..bid.." and tid!=0 and tid!=100 and apply_at>="..oceaninfo.st.." and apply_at<="..oceaninfo.et.." group by tid") 
        if type(res)=='table' and next(res) then
            for k,v in pairs(res) do
                local tid = tonumber(v.tid)
                local mems = tonumber(v.num)
                local add = cfg.tpNum - mems
                addmem(bid,tid,add,oceaninfo,true)
                if team[tid] then
                    team[tid] = nil
                end      
            end
        end

        if type(team)=='table' and next(team) then
            for k,v in pairs(team) do
                local tid = tonumber(v)   
                local add = cfg.tpNum
                addmem(bid,tid,add,oceaninfo,false)
            end
        end

        mOceanMatch.setTeams(bid)

        local players = {}
        if type(mOceanMatch.info.teams)=='table' then
            players = copyTable(mOceanMatch.info.teams)
        end
        
        mOceanMatch.save()
        writeLog("队伍成员分配 结果:"..json.encode(players), "ocean")
    end

    -- 结算
    if mOceanMatch.isstage6(ts,tonumber(oceaninfo.st),cfg,mOceanMatch) then
        mOceanMatch.over()
        mOceanMatch.save()
    end

    response.ret=0
    response.msg ='Success'
     
    return response

end