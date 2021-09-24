-- 预热
-- 报名/元帅选拔
-- 队长选拔
-- 队伍调整
-- 比赛+结算

local function api_oceanexpedition_set(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"}
            },

            ["action_morale"] = {
                bid = {"required", "number"},
                gems = {"required", "number", {"min", 1}},
                flowers = {"required","number", {"min", 1}},
            },
        }
    end

    local oceancfg = {}

    function self.before(request)
        local response = self.response
        local uid=request.uid
    
        if not uid then
            response.ret = -102
            return response
        end

        local oceaninfo,code = loadFuncModel("serverbattle").getOceanExpeditionInfo()
        if not next(oceaninfo) then
            response.ret = -27022
            return response
        end

        -- TODO 是否需要copy
        oceancfg = copyTable(oceaninfo)
    end

       -- 报名
    function self.action_apply(request)
        local response = self.response
        local uid = request.uid
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        local cfg = getConfig("oceanExpedition")
        if mUserinfo.level<cfg.levelLimit then
            response.ret = -27023
            return response
        end

        local mOceanMatch = getModelObjs("oceanmatches")
        -- 是不是在报名期
        if not mOceanMatch.isstage1(ts,oceancfg.st,cfg) then
            response.ret = -27025
            return response
        end
     
        if mOcean.signUpStatus == 3 then
            response.ret = -27024
            return response
        end
        
        mOcean.bid = oceancfg.bid
        mOcean.nickname = mUserinfo.nickname
        mOcean.level = mUserinfo.level
        mOcean.signUpStatus = 3
        mOcean.fc = mUserinfo.fc
        mOcean.apply_at = ts
        -- 是否有资格竞选元帅
        if mOceanMatch.qualification(uid,oceancfg.st,cfg.marLimit) then
            mOcean.canMaster = 1
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
            response.data.oceanExpedition = mOcean.toArrayForClient()
        else
            response.ret = -106
        end

        return response
    end

    -- 元帅竞选 
    function self.action_setmarshal(request)
        local response = self.response
        local uid = request.uid
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        local cfg = getConfig("oceanExpedition")
        if not getModelObjs("oceanmatches").isstage1(ts,oceancfg.st,cfg) then
            response.ret = -27025
            return response
        end
     
        if mOcean.bid==0 or mOcean.signUpStatus==0 then
            response.ret = -102
            return response
        end

        if mOcean.signUpStatus==1 then
            response.ret = -27024
            return response
        end
        -- 没设置部队不能申请
        if type(mOcean.info)~='table' or not next(mOcean.info) then
            response.ret = -27028
            return response
        end

        if mOcean.canMaster~=1 then
            response.ret = -27026
            return response
        end

        mOcean.signUpStatus = 1
        mOcean.addscore(cfg.marChoosePoint)
	writeLog("竞选元帅 ：uid="..uid, "oceanmarshal")
        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
            response.data.oceanExpedition = mOcean.toArrayForClient()
        else
            response.ret = -106
        end

        return response
    end

    -- 第三天申请队长  没有设置部队不能竞选
    function self.action_captain(request)
        local response = self.response
        local uid = request.uid
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        local cfg = getConfig("oceanExpedition")
        if not getModelObjs("oceanmatches").isstage2(ts,oceancfg.st,cfg) then
            response.ret = -27025
            return response
        end

        if mOcean.bid==0 then
            response.ret = -102
            return response
        end
        -- 元帅不可以申请
        if mOcean.job==1 then
            response.ret = -27027
            return response
        end

        if mOcean.signUpStatus==2 then
            response.ret = -27037
            return response
        end

        --没设置部队不能申请
        if type(mOcean.info)~='table' or not next(mOcean.info) then
            response.ret = -27028
            return response
        end

        if mOcean.canMaster~=1 then
            response.ret = -27026
            return response
        end
     
        mOcean.signUpStatus = 2
        mOcean.addscore(cfg.tlChoosePoint)
        if uobjs.save() then
            response.data.oceanExpedition = mOcean.toArrayForClient()
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response
    end

    -- 放弃竞选元帅/或者队长
    function self.action_cancel(request)
        local response = self.response
        local uid = request.uid
        local act = request.params.act -- 放弃职位 1元帅 2队长

        if not table.contains({1,2},act) then
            response.ret = -102
            return response
        end
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        local cfg = getConfig("oceanExpedition")
        if mOcean.bid==0 or mOcean.bid~=tonumber(oceancfg.bid) or mOcean.signUpStatus==0 then
            response.ret = -102
            return response
        end

        local mOceanMatch = getModelObjs("oceanmatches")
        if act==1 then
            if not mOceanMatch.isstage1(ts,oceancfg.st,cfg) then
                response.ret = -27034
                return response
            end

            if mOcean.signUpStatus~=1 then
                response.ret = -102
                return response
            end
            mOcean.reducescore(cfg.marChoosePoint)
        else
            if not mOceanMatch.isstage2(ts,oceancfg.st,cfg) then
                response.ret = -27034
                return response
            end

            if mOcean.signUpStatus~=2 then
                response.ret = -102
                return response
            end
            mOcean.reducescore(cfg.tlChoosePoint)
        end
    
        mOcean.signUpStatus = 3
        if uobjs.save() then
            --response.data.oceanExpedition = mOcean.toArrayForClient()
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response
    end

    -- 报名玩家申请加入队伍
    -- 如果没队长直接加入
    function self.action_appteam(request)
        local response = self.response
        local uid = request.uid
        local tid = request.params.tid -- 1,2,3,4,5

        if not table.contains({1,2,3,4,5},tid) then
            response.ret = -102
            return response
        end

        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        local cfg = getConfig("oceanExpedition")
        if mOcean.bid==0 or mOcean.bid~=tonumber(oceancfg.bid) or mOcean.job~=3  then
            response.ret = -102
            return response
        end
  
        if mOcean.tid~=100 then
            response.ret = -102
            return response
        end

        local mOceanMatch = getModelObjs("oceanmatches",mOcean.bid)
        if not mOceanMatch.isstage3(ts,oceancfg.st,cfg) then
            response.ret = -27034
            return response
        end

        if mOcean.appteam[tid]==1 then
            response.ret = -27024
            return response
        end
        local savelag = false
        local joinflag = 0
        local mOceanMatch = getModelObjs("oceanmatches",mOcean.bid)
        if mOceanMatch.captainExits(oceancfg.bid,oceancfg.st,oceancfg.et,tid) then
            -- 申请上限
            local apnum = mOceanMatch.applynum(oceancfg.bid,oceancfg.st,oceancfg.et,tid)
            if apnum>=cfg.ApplyLimit then
                response.ret = -121
                return response
            end

            mOcean.appteam[tid]=1
        else
            -- 没队长直接加入  需要判断该队伍当前数量
            local memnum = mOceanMatch.checkMems(oceancfg.bid,oceancfg.st,oceancfg.et,tid)
            if cfg.tpNum <= memnum then
                response.ret = -27035
                return response
            end
            mOcean.tid = tid
            mOcean.appteam = {0,0,0,0,0}

            mOceanMatch.joinTeam(tid+1,uid,3,mOcean.fc)
            savelag = true
            joinflag = 1
        end

 
        if uobjs.save() then
            if savelag then
                mOceanMatch.save()
            end

            response.data.join = joinflag
            --response.data.oceanExpedition = mOcean.toArrayForClient()
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response
    end

    -- 队长拒绝队员
    function self.action_refuse(request)
        local response = self.response
        local uid = request.uid
        local tid = request.params.tid
        local targid = request.params.targid

        if not targid then
            response.ret = -102
            return response
        end
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        local tuobjs = getUserObjs(targid)
        tuobjs.load({'oceanexpedition'})
        local tmOcean = tuobjs.getModel('oceanexpedition')

        local cfg = getConfig("oceanExpedition")
        if mOcean.bid==0 or mOcean.bid~=tonumber(oceancfg.bid) or mOcean.job~=2  then
            response.ret = -102
            return response
        end

        if tmOcean.bid==0 or tmOcean.bid~=tonumber(oceancfg.bid) or tmOcean.job~=3  then
            response.ret = -102
            return response
        end

        -- 有可能在这个时候 被申请的其他队伍通过了
        if tmOcean.tid~=100 then
            response.ret = -27036
            return response
        end
    
        if mOcean.tid==0  then
            response.ret = -102
            return response
        end
        -- 判断时间
        if not getModelObjs("oceanmatches").isstage3(ts,oceancfg.st,cfg) then
            response.ret = -27034
            return response
        end

        tmOcean.appteam[mOcean.tid] = 0
        if tuobjs.save() then
            response.ret = 0
            response.msg = 'success'
            local list = getModelObjs("oceanmatches").applist(mOcean.bid,oceancfg.st,oceancfg.et,mOcean.tid)
            response.data.applist = list
        else
            response.ret = -106
        end

        return response
    end

    -- 队长一键拒绝
    function self.action_easyrefuse(request)
        local response = self.response
        local uid = request.uid
        local ts = getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        if mOcean.bid==0 or mOcean.bid~=tonumber(oceancfg.bid) or mOcean.job~=2 then
            response.ret = -102
            return response
        end
        local cfg = getConfig("oceanExpedition")
        -- 判断时间
        if not getModelObjs("oceanmatches").isstage3(ts,oceancfg.st,cfg) then
            response.ret = -27034
            return response
        end

        local list = getModelObjs("oceanmatches").applist(mOcean.bid,oceancfg.st,oceancfg.et,mOcean.tid)
        if type(list)=='table' and next(list) then
            for k,v in pairs(list) do
                local tuid = tonumber(v[1])
                local tuobjs = getUserObjs(tuid)
                tuobjs.load({'oceanexpedition'})
                local tmOcean = tuobjs.getModel('oceanexpedition') 
                if tmOcean.job==3  and tmOcean.tid==100 then
                    tmOcean.appteam[mOcean.tid] = 0
                    tuobjs.save()
                end  
            end
        end
        
        local list = getModelObjs("oceanmatches").applist(mOcean.bid,oceancfg.st,oceancfg.et,mOcean.tid)
        response.data.applist = list
        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 队长通过队员申请
    function self.action_pass(request)
        local response = self.response
        local uid = request.uid
        local tid = request.params.tid
        local targid = request.params.targid

        if not targid then
            response.ret = -102
            return response
        end
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        local tuobjs = getUserObjs(targid)
        tuobjs.load({'oceanexpedition','userinfo'})
        local tmOcean = tuobjs.getModel('oceanexpedition')
        local tmUserinfo = tuobjs.getModel('userinfo')

        local cfg = getConfig("oceanExpedition")
        if mOcean.bid==0 or mOcean.bid~=tonumber(oceancfg.bid) or mOcean.job~=2  then
            response.ret = -102
            return response
        end

        if tmOcean.bid==0 or tmOcean.bid~=tonumber(oceancfg.bid) or tmOcean.job~=3  then
            response.ret = -102
            return response
        end

        if tmOcean.tid~=100 then
            response.ret = -27036
            return response
        end
    
        if mOcean.tid==0  then
            response.ret = -102
            return response
        end

        local mOceanMatch = getModelObjs("oceanmatches",mOcean.bid)
        -- 判断时间
        if not mOceanMatch.isstage3(ts,oceancfg.st,cfg) then
            response.ret = -27034
            return response
        end
        
        local memnum = mOceanMatch.checkMems(oceancfg.bid,oceancfg.st,oceancfg.et,mOcean.tid)
        if cfg.tpNum <= memnum then
            response.ret = -27035
            return response
        end

        if tmOcean.appteam[mOcean.tid]~=1 then
            response.ret = -102
            return response
        end

        tmOcean.appteam = {0,0,0,0,0}
        tmOcean.tid = mOcean.tid

        mOceanMatch.joinTeam(mOcean.tid+1,targid,3,tmOcean.fc)
        response.data.addmem = {{tmUserinfo.nickname,3,tmOcean.fc,tmUserinfo.pic,tmUserinfo.apic or '',tmUserinfo.bpic or '',targid}}
        if tuobjs.save() then
            mOceanMatch.save()
            response.ret = 0
            response.msg = 'success'

            local list = getModelObjs("oceanmatches").applist(mOcean.bid,oceancfg.st,oceancfg.et,mOcean.tid)
            response.data.applist = list
        else
            response.ret = -106
        end

        return response
    end

    -- 一键通过
    function self.action_easypass(request)
        local response = self.response
        local uid = request.uid
        local ts = getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        if mOcean.bid==0 or mOcean.bid~=tonumber(oceancfg.bid) or mOcean.job~=2 then
            response.ret = -102
            return response
        end
        local cfg = getConfig("oceanExpedition")
        local mOceanMatch = getModelObjs("oceanmatches",mOcean.bid)

        -- 判断时间
        if not mOceanMatch.isstage3(ts,oceancfg.st,cfg) then
            response.ret = -27034
            return response
        end
        local addmem = {}
        local flag = false
        local list = mOceanMatch.applist(mOcean.bid,oceancfg.st,oceancfg.et,mOcean.tid)
        if type(list)=='table' and next(list) then
            local memnum = mOceanMatch.checkMems(oceancfg.bid,oceancfg.st,oceancfg.et,mOcean.tid)
            local curnum = memnum -- 去掉队长本身
            local passnum = cfg.tpNum - curnum
            if passnum>0 then
                 for k,v in pairs(list) do
                    local tuid = tonumber(v[1])
                    local tuobjs = getUserObjs(tuid)
                    tuobjs.load({'oceanexpedition','userinfo'})
                    local tmOcean = tuobjs.getModel('oceanexpedition') 
                    local tmUserinfo = tuobjs.getModel('userinfo')
        
                    if tmOcean.job==3  and tmOcean.tid==100 and k<=passnum then
                        tmOcean.appteam = {0,0,0,0,0}
                        tmOcean.tid = mOcean.tid
                        mOceanMatch.joinTeam(mOcean.tid+1,tuid,3,tmOcean.fc)
                        tuobjs.save()
                        flag = true
                        table.insert(addmem,{tmUserinfo.nickname,3,tmUserinfo.fc,tmUserinfo.pic,tmUserinfo.apic or '',tmUserinfo.bpic or '',tuid})
                    end  
                end 
            end    
        end

        if flag then
            mOceanMatch.save()
        end
        
        local list = mOceanMatch.applist(mOcean.bid,oceancfg.st,oceancfg.et,mOcean.tid)
        response.data.applist = list
        response.data.addmem = addmem
        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 队长移除队员
    function self.action_remove(request)
        local response = self.response
        local uid = request.uid
        local tid = request.params.tid
        local targid = request.params.targid

        if not targid then
            response.ret = -102
            return response
        end
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        local tuobjs = getUserObjs(targid)
        tuobjs.load({'oceanexpedition'})
        local tmOcean = tuobjs.getModel('oceanexpedition')

        local cfg = getConfig("oceanExpedition")
        if mOcean.bid==0 or mOcean.bid~=tonumber(oceancfg.bid) or mOcean.job~=2  then
            response.ret = -102
            return response
        end

        if tmOcean.bid==0 or tmOcean.bid~=tonumber(oceancfg.bid) or tmOcean.job~=3  then
            response.ret = -102
            return response
        end

        if tmOcean.tid~=mOcean.tid then
            response.ret = -102
            return response
        end
    
        -- 判断时间
        if not getModelObjs("oceanmatches").isstage3(ts,oceancfg.st,cfg) then
            response.ret = -27034
            return response
        end
        local tid = tmOcean.tid
        tmOcean.tid = 100

        local mOceanMatch = getModelObjs("oceanmatches",mOcean.bid)
        mOceanMatch.quitTeam(tid+1,targid,tmOcean.fc)

        -- 移除玩家发邮件        
        local content = {type=84,name=tmOcean.nickname,cname=mOcean.nickname,tid=mOcean.tid}
        content = json.encode(content)
        local ret =MAIL:mailSent(targid,1,targid,'',tmOcean.nickname,84,content,1,0)
        if tuobjs.save() then
            mOceanMatch.save()
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response

    end

    -- 成员退出队伍
    function self.action_quit(request)
        local response = self.response
        local uid = request.uid
    
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        if mOcean.bid==0 or mOcean.bid~=tonumber(oceancfg.bid) or mOcean.job~=3  then
            response.ret = -102
            return response
        end 

        if mOcean.tid==100 or mOcean.job==1 then
            response.ret = -102
            return response
        end

        local tid = mOcean.tid
        local cfg = getConfig("oceanExpedition")
        if not getModelObjs("oceanmatches").isstage3(ts,oceancfg.st,cfg) then
            response.ret = -27034
            return response
        end

        mOcean.tid = 100
        mOcean.appteam = {0,0,0,0,0}
        local mOceanMatch = getModelObjs("oceanmatches",mOcean.bid)
        mOceanMatch.quitTeam(tid+1,uid,mOcean.fc)
        if uobjs.save() then
            mOceanMatch.save()
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response
    end


    --[[

        设置阵形
    ]]
    function self.action_formation( request )
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserOceanExp = uobjs.getModel('oceanexpedition')

        local formation = request.params.formation
        if type(formation) ~= "table" then
            response.ret = -102
            response.err = "formation must be a table"
            return response
        end

        -- 元帅才能设置阵型
        if not mUserOceanExp.isMarshal() then
            response.ret = -27033
            return response
        end

        -- TODO 时间判断


        -- 验证阵型
        if not loadModel("model.oceanexpeditionserver"):checkFormation(formation) then
            response.ret = -102
            response.err = "invalid formation"
            return response
        end

        local ret, code = mUserOceanExp.setFormation(formation)

        if ret then
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = code or -27030
        end

        return response
    end

    -- 设置旗帜
    function self.action_flag( request )
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserOceanExp = uobjs.getModel('oceanexpedition')

        -- 队长才能设置旗帜
        if not mUserOceanExp.isCaptain() then
            response.ret = -27031
            return response
        end

        -- TODO 时间判断

        if type(request.params.flag) == "table" and next(request.params.flag) then
            local ret, code = mUserOceanExp.setFlag(request.params.flag)

            if ret then
                response.ret = 0
                response.msg = 'Success'
            else
                response.ret = code or -27030
            end
        end

        return response 
    end

    -- 组建队伍
    function self.action_teamMembers( request )
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserOceanExp = uobjs.getModel('oceanexpedition')

        -- 队长才能设置旗帜
        if not mUserOceanExp.isCaptain() then
            response.ret = -27031
            return response
        end

        -- TODO 时间判断
        -- 成员判断

        local members = request.params.members

        if type(members) == "table" and next(members) and members[1] == uid then
            local ret, code = mUserOceanExp.setTeamMembers(members)

            if ret then
                response.ret = 0
                response.msg = 'Success'
            else
                response.ret = code or -27030
            end
        end

        return response 
    end

    -- 设置部队
    function self.action_troops( request )
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserOceanExp = uobjs.getModel('oceanexpedition')

        -- TODO 这里如果是前30名,可以竞选元帅的
        -- 已参战的玩家才能设置部队
        if not mUserOceanExp.hasJoined() then
            if mUserOceanExp.canMaster == 0 then
                response.ret = -27032
                return response
            end
        end

        -- 队伍调整期是23点半，调整期后只有在调整期前设置过部队的人才能继续调整部队
        local ts = os.time()
        local sevCfg = getConfig("oceanExpedition")
        if ts > ( (getWeeTs(oceancfg.st) + sevCfg.tpTime * 86400) - 1800 ) then
            if not next(mUserOceanExp.getTroops()) then
                response.ret = -27038
                return response
            end
        end

        -- TODO 时间判断
        -- 成员判断


        local zid = request.zoneid
        local hero  =request.params.hero or {}
        local equip = request.params.equip
        local plane = request.params.plane
        
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mTroop    = uobjs.getModel('troops') 
        local mHero     = uobjs.getModel('hero')
        

        local fleetInfo = request.params.fleetinfo
        if not mTroop.checkWorldWarFleetInfo(fleetInfo,equip) then
            response.ret = -5006
            return response
        end
        
        local oldtank=copyTab(mUserOceanExp.getTroops())

         -- check new heroes
        if type(hero)=='table' and next(hero) then
            if not mHero.checkFleetHeroStats(hero) then
                response.ret=-11016 
                return response
            end
        end

        -- 这儿给个默认值战报里占位(后面部队如果不带军徽客户端会不传,后端更新时要去掉上一次设置的)
        equip = equip or 0
        if equip ~= 0 then
            -- 军徽(超级装备)检测
            local mSequip = uobjs.getModel('sequip')
            if equip and not mSequip.checkFleetEquipStats(equip) then
                response.ret=-8650 
                return response        
            end

            equip=mSequip.formEquip(equip)
        end

        -- 飞机给个默认值占位
        plane = plane or 0

        -- 检测扣的坦克是否能够
        local function getdeltroops(oldtank,troops)
            local old={}
            local new={}
            local result={}
            if next(oldtank) then
                for k,v in pairs(oldtank) do
                    if v[2]~=nil and v[2]>0 then
                        old[v[1]]=(old[v[1]] or 0)+v[2]
                    end
                end
            end
            for k,v in pairs(troops) do
                if v[2]~=nil and  v[2]>0 then
                    new[v[1]]=(new[v[1]] or 0)+v[2]
                end
            end
            if next(new) then
                for k,v in pairs(new) do
                    local count =v- (old[k] or 0)
                    if count>0 then
                        result[k]=count
                    end
                end

            end
            return result
        end

        local deltroops =getdeltroops(oldtank,fleetInfo)
        local tank={}
        if  next(deltroops) then
            for k,v in pairs(deltroops) do
                local v =math.ceil(v/sevCfg.ratio)
                local tmp={}
                table.insert(tmp,mTroop.troops[k])
                if not mTroop.troops[k] or v > mTroop.troops[k] or not mTroop.consumeTanks(k,v) then
                    response.ret = -115
                    return response
                end
                table.insert(tmp,mTroop.troops[k])
                tank[k]=tmp
            end
            
            regKfkLogs(uid,'tankChange',{
                    addition={
                        {desc="远洋征战减少坦克",value=tank},
                        {desc="远洋征战上次设置部队",value=oldtank},
                        {desc="远洋征战本次设置部队",value=fleetInfo},
                    }
                }
            )
        end

        local binfo = mTroop.gettroopsinfo(fleetInfo, hero, equip, 0, plane)
        local troopAddRate = mUserOceanExp.getTroopAttrAddRate(binfo)

        local fleet = {
            troops = fleetInfo,
            hero=hero,
            heroList=request.params.heroList,
            equip=equip,
            plane=plane,
        }

        local ret, code = mUserOceanExp.setTroops(fleet,binfo,troopAddRate)

        if not ret then
            response.ret = code
            return response
        end

        if uobjs.save() then 
            if next(tank)  then
                writeLog(uid..'|'..json.encode(tank),'oceanExptroops') 
            end
            response.data.troops = mTroop.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 激励士气
    function self.action_morale(request)
        local response = self.response
        local uid = request.uid
        local bid = request.params.bid
        local gems = request.params.gems
        local flowers = request.params.flowers

        local oceanExpCfg = getConfig("oceanExpedition")
        local useGems = flowers * oceanExpCfg.morale.fowler2Money

        if useGems < 1 or gems ~= useGems then
            response.ret = -102
            response.gems = {gems,useGems}
            return response
        end

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")
        local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus("oceanmorale")
        if activStatus ~= 1 then
            response.ret = -27034
            return response
        end

        if not mUserinfo.useGem(useGems) then
            response.ret = -109 
            return response
        end

        local morale = oceanExpCfg.morale.costFlowerMor * flowers
        local point = oceanExpCfg.morale.costFlowerP * flowers

        -- 金币日志
        regActionLogs(uid,1,{
            action=252,
            item=pid,
            value=useGems,
            params={
                    flowers=flowers,
                    morale=morale,
                    point=point,
                }
            }
        )
        
        local mOceanMatch
        if point > 0 and morale > 0 then
            mOceanMatch = getModelObjs("oceanmatches",bid)
            if mOceanMatch then
                local ret, code = mOceanMatch.addMorale(morale)
                if not ret  then
                    response.ret = code or -1
                    return response
                end
            end

            local mOcean = uobjs.getModel('oceanexpedition')
            mOcean.addFlowerScore(point)
            mOcean.addmorale(morale)
            response.data.oceanExpedition = mOcean.simpleDataForClient(
                {score=mOcean.score,fscore=mOcean.fscore,morale=mOcean.morale},
                {morale=mOceanMatch.getMorale()}
            )

            if mOcean.apply_at==0 then
                mOcean.apply_at = getClientTs()
            end
            
        end


        if uobjs.save() then
            if mOceanMatch then
                mOceanMatch.save()
            end

            response.ret = 0
            response.msg = 'Success'
        end
        
        return response
    end

    -- 商店
    function self.action_shop(request)
        local response = self.response
        local uid = request.uid
        local id = request.params.id   -- 商品id
        local num = request.params.num -- 购买的数量
        local sid = request.params.sid -- 商店id
        local score = request.params.score -- 消耗的积分
        if not table.contains({1,2,3},sid) then
            response.ret = -102
            return response
        end
       
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mUserinfo = uobjs.getModel('userinfo')
        local mOcean = uobjs.getModel('oceanexpedition')

        if sid==1 and mOcean.job~=1 then
            response.ret = -102
            return response
        end

        if sid==2 and not table.contains({1,2},mOcean.job) then
            response.ret = -102
            return response
        end

        if num<=0 or score<=0 then
            response.ret = -102
            return response
        end 

        local cfg = getConfig("oceanExpedition")
        if not getModelObjs("oceanmatches").isstage5(ts,oceancfg.st,cfg,oceancfg) then
            response.ret = -27034
            return response
        end

        local shopkey = {"highShop","middleShop","lowShop"}
        local shopCfg = cfg[shopkey[sid]][id]
     
        if type(shopCfg)~='table' or not next(shopCfg) then
            response.ret = -102
            return response
        end

        if type(mOcean.shop)~='table' then
            mOcean.shop = {}
        end

        for i=1,3 do
            if type(mOcean.shop[i])~='table' then
                mOcean.shop[i]={}
            end
        end
        
        local curtimes = mOcean.shop[sid][id] or 0
        if curtimes+num>shopCfg.bn then
            response.ret = -121
            return response
        end

        local costscore = shopCfg.p*num
        if costscore~=score then
            response.ret = -100
            return response
        end
        
        if not mOcean.reducescore(costscore) then
            response.ret = -1996
            return response
        end

        local reward = {}
        for k,v in pairs(shopCfg.sr) do
            reward[k] = v*num
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return responsedate
        end

        mOcean.shop[sid][id] = (mOcean.shop[sid][id] or 0) + num
        if mOcean.apply_at==0 then
            mOcean.apply_at = ts
        end
        
        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
            response.data.reward = formatReward(reward)
            response.data.oceanExpedition = {}
            response.data.oceanExpedition.oceaninfo = {
                score = mOcean.score,
                shop = mOcean.shop
            }
        else
            response.ret = -106
        end

        return response
    end

    return self
end

return api_oceanexpedition_set
