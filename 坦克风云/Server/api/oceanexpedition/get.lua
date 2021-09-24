
-- 第一天预热
-- 第二天报名/元帅选拔
-- 第三天队长选拔
-- 第四天 队伍调整
-- 第五-七天 比赛+结算


local function api_oceanexpedition_get(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    local oceancfg = {}

    function self.before(request)
        local response = self.response
        local uid=request.uid
    
        if not uid then
            response.ret = -102
            return response
        end

        require "model.serverbattle"
        local mServerbattle = model_serverbattle()
        local oceaninfo,code = mServerbattle.getOceanExpeditionInfo()
     
        if code~=0 or not next(oceaninfo) then
            response.ret = -27022
            return response
        end

        oceancfg = copyTable(oceaninfo)
    end

    -- 报名
    function self.action_init(request)
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

        -- 检测当前玩家队伍信息
        mOcean.checkjob()

        local mOceanMatch = getModelObjs("oceanmatches",oceancfg.bid,true)
        local flag = false
        -- 判断 是否有竞选元帅或者队长的资格
        if mOceanMatch.isstage1(ts,oceancfg.st,cfg) then
            if mOceanMatch.qualification(uid,oceancfg.st,cfg.marLimit) then
                mOcean.canMaster = 1
                flag = true
            end
        end

        -- 是否有竞选队长请求
        if mOceanMatch.isstage2(ts,oceancfg.st,cfg) then  
            if mOceanMatch.qualification(uid,oceancfg.st,cfg.tlLimit) then
                mOcean.canMaster = 1
                flag = true
            end
        end     

        if flag then
            uobjs.save()
        end
         
        response.data.oceanExpedition = mOcean.toArrayForClient()
        response.data.oceanExpedition.pubinfo.crossIp = getConfig("config.worldwarserver.worldwarserverurl")

        -- 返回对阵列表信息
        response.data.oceanExpedition.schedule = mOceanMatch.scheduleForClient()

        response.ret = 0
        response.msg = 'success'
       
        return response
    end

    -- 报名列表  1元帅 2队长 3普通
    function self.action_list(request)
        local response = self.response
        local uid = request.uid
        local ts = getClientTs()
        local act = request.params.act  -- 1竞选元帅列表 2竞选队长列表 3普通玩家列表 4参加且确认名单
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo'})
        local mUserinfo = uobjs.getModel('userinfo')
       
        local cfg = getConfig("oceanExpedition")

        local bid  = oceancfg.bid
        local list = {}
        local db = getDbo()
        local result ={}
        if act == 1 then
            result = db:getAllRows(string.format("select uid,nickname,level,job,tid,fc,feats from oceanexpedition where bid="..bid.." and signUpStatus=1 order by fc desc"))
        elseif act == 2 then
            result = db:getAllRows(string.format("select uid,nickname,level,job,tid,fc,feats from oceanexpedition where bid="..bid.." and signUpStatus=2 order by fc desc"))
        elseif act ==3 then
            result = db:getAllRows(string.format("select uid,nickname,level,job,tid,fc,feats from oceanexpedition where bid="..bid.." and apply_at>="..tonumber(oceancfg.st).." and apply_at<="..tonumber(oceancfg.et).."  order by fc desc limit 76"))
        elseif act ==4 then
            result = db:getAllRows(string.format("select uid,nickname,level,job,tid,fc,feats from oceanexpedition where bid="..bid.." and job>0 order by fc desc limit 100"))
        end
        
        if type(result)=='table' and next(result) then
            for k,v in pairs(result) do
                local tmp = {
                    uid= tonumber(v.uid),
                    nickname = v.nickname,
                    level = tonumber(v.level),
                    job = tonumber(v.job),
                    tid = tonumber(v.tid),
                    fc = tonumber(v.fc),
                    feats = tonumber(v.feats),
                }
                table.insert(list,tmp)
            end
        end  

        response.data.list = list
        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 拉取对阵列表
    function self.action_schedule(request)
        local response = self.response
        local bid = tonumber(request.params.bid)
        local schedule, code = getModelObjs("oceanmatches",bid,true).schedule()

        if not schedule then
            response.ret = code
            return response
        end

        -- local schedule = {
            -- {
            --     ["3"]=
            --     {
            --         -- {2,1},{6,2}
            --     },
            --     ["4"]={
            --         -- {4,2},{7,1}
            --         {4,1}
            --     },
            --     ["1"]={
            --         {1,2},{8,1}
            --     },
            --     ["2"]={
            --         {3,1},{5,2}
            --     }
            -- },

            -- {
            --  ["3"]=
            --  {
            --      {2},{6}
            --  },
            --  ["4"]={
            --      -- {4,2},{7,1}
            --      {4}
            --  },
            --  -- ["1"]={
            --  --  {1,2},{8,1}
            --  -- },
            --  ["2"]={
            --      {3},{5}
            --  }
            -- },

            -- {
            --  ["1"]={{3,1},{8,2}},
            --  ["2"]={{2,1},{7,2}}
            -- },
            -- {
            --  ["1"]={
            --      {2},{3}
            --  }
            -- }
        -- }

        local function len(dayInfo)
            local len = 0
            for k,v in pairs(dayInfo) do
                if tonumber(k) > len then
                    len = tonumber(k)
                end
            end
            return len
        end

        -- 客户端要求的格式
        local forClient = {}

        for day,dayInfo in pairs(schedule) do
            local n = len(dayInfo)
            local nextFlag=false
            local nextData = {}
            local roundData = {}

            roundData = {}

            local group,groupInfo
            local ins = {}
            for i=1,n do 
                group = tostring(i)
                groupInfo = dayInfo[group]

                ins[1] = i*2-1
                ins[2] = i*2

                roundData[ins[1]] = 0
                roundData[ins[2]] = 0

                if type(groupInfo) == "table" and next(groupInfo) then
                    for j=1,len(groupInfo) do
                        local zoneInfo = groupInfo[j]
                        roundData[ins[j]] = zoneInfo[1]

                        -- 下一轮数据
                        if zoneInfo[2] then
                            if zoneInfo[2] == 1 then
                                table.insert(nextData,zoneInfo[1])
                            end
                            nextFlag = true
                        end
                    end
                else
                    table.insert(nextData,0)
                end
            end

            if not forClient[day] then
                forClient[day] = roundData
            end

            if nextFlag then
                forClient[day+1] = nextData
            end

        end

        response.data.schedule = forClient
        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 队伍申请列表
    function self.action_applist(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','oceanexpedition'})
        local mOcean = uobjs.getModel('oceanexpedition')

        if mOcean.job~=2 then
            response.ret = -102
            return response
        end


        local list = getModelObjs("oceanmatches").applist(mOcean.bid,oceancfg.st,oceancfg.et,mOcean.tid)
        response.data.applist = list
        response.ret = 0
        response.msg = 'success'
        return response
    end


    -- 战队信息
    function self.action_corps(request)
        local response = self.response
        local bid = tonumber(request.params.bid)
        local uid = request.uid
        local mUserOceanExp = getUserObjs(uid,true).getModel('oceanexpedition')

        -- 只有参赛后才能看战队信息
        if not mUserOceanExp.hasJoined() then
            response.ret = -102
            return response
        end

        local mOceanMatch = getModelObjs("oceanmatches",bid,true)
        if not mOceanMatch.isEmpty() then
            local teams = mOceanMatch.getTeams()
            local flags = mOceanMatch.getFlags()
            local logo = {1,1,1,1}

            local corpsInfo = {}
            for i=1,getConfig("oceanExpedition").teamNum do
                corpsInfo[i] = {
                    logo,"",0,
                }
            end

            for k,v in pairs(teams) do
                if v[1] and v[1] > 0 then
                    corpsInfo[k][2] = getUserObjs(v[1],true).getModel('userinfo').nickname
                end

                if v[2] then corpsInfo[k][3] = #(v[2]) end
                
                -- 旗帜
                if flags[k] and next(flags[k]) then
                    corpsInfo[k][1] = flags[k]
                end
            end
            
            response.data.corps = corpsInfo
        end

        response.data.battr = mOceanMatch.getBAttrByTeam(1)

        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 队伍信息
    function self.action_team(request)
        local response = self.response
        local bid = tonumber(request.params.bid)
        local uid = request.uid

        -- 客户端从0开始算的，后端是存了一个标准table，从1开始算
        local tid = request.params.tid + 1

        local mUserOceanExp = getUserObjs(uid,true).getModel('oceanexpedition')

        if not mUserOceanExp.hasJoined() then
            response.ret = -102
            return response
        end

        local logo = {1,1,1,1}

        local mOceanMatch = getModelObjs("oceanmatches",bid,true)
        if not mOceanMatch.isEmpty() then
            local teams = mOceanMatch.getTeams()
            local flags = mOceanMatch.getFlags()
            local team = teams[tid]

            -- 如果有队员
            if team and type(team[2]) == "table" then
                local memberList = {}
                for _,mid in pairs(team[2]) do
                    mid = tonumber(mid) or 0
                    if mid > 0 then
                        local uobjs = getUserObjs(mid,true)
                        local mUserinfo = uobjs.getModel('userinfo')
                        local mUserOceanExp = uobjs.getModel('oceanexpedition')

                        table.insert(memberList,{
                            mUserOceanExp.nickname,
                            mUserOceanExp.job,
                            mUserOceanExp.fc,
                            mUserinfo.pic,
                            mUserinfo.apic,
                            mUserinfo.bpic,
                            mid,
                        })
                    end
                end

                response.data.memberList = memberList
                response.data.flag = flags[tid]
            end
        end

        -- 客户端要求有默认值
        if not response.data.flag or not next(response.data.flag) then
            response.data.flag = logo
        end
      
        response.data.rank = mOceanMatch.getteamrank(tid)

        response.data.battr = mOceanMatch.getBAttrByTeam(tid)

        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 成员信息
    function self.action_member(request)
        local response = self.response
        local bid = tonumber(request.params.bid)
        local uid = request.uid
        local mid = request.params.mid
        local mUserOceanExp = getUserObjs(uid,true).getModel('oceanexpedition')

        if not mUserOceanExp.hasJoined() then
            response.ret = -102
            return response
        end

        local mMemberOceanExp = getUserObjs(mid,true).getModel('oceanexpedition')
        response.data.troopInfo = mMemberOceanExp.info

        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 打开商店界面调用，会同步跨服积分
    function self.action_shop(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mOcean = uobjs.getModel('oceanexpedition')

        if mOcean.bindJoinPoint() then
            uobjs.save()
        end

        response.data.score = mOcean.score
        response.ret = 0
        response.msg = 'success'
        return response
    end
    
    return self
end

return api_oceanexpedition_get
