local function api_territory_get(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    -- 获取领地成员信息
    function self.action_member(request)
        local response = self.response
        local uid = request.uid

        if not uid then
        	response.ret = -102
        	return response
        end
        local uobjs = getUserObjs(uid)
    	uobjs.load({"userinfo"})
    	local mUserinfo = uobjs.getModel('userinfo')

	    if mUserinfo.alliance==0 then
	        response.ret = - 102
	        return response
	    end    	
        local mAtmember = uobjs.getModel('atmember')

        response.data.member = mAtmember.toArray(true)
        response.ret = 0
        response.msg = "Success"
        return response
    end
    
    -- 获取成员破译信息
  	function self.action_crack(request)
        local response = self.response
        local uid = request.uid

        if not uid then
        	response.ret = -102
        	return response
        end
        local uobjs = getUserObjs(uid)
    	uobjs.load({"userinfo"})
    	local mUserinfo = uobjs.getModel('userinfo')

	    if mUserinfo.alliance==0 then
	        response.ret = - 102
	        return response
	    end    	
        local mAtmember = uobjs.getModel('atmember')

        response.data.crack = mAtmember.crack
        response.ret = 0
        response.msg = "Success"
        return response
    end

    -- 获取军团领地击杀海盗排名
    function self.action_acrank(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid

        if not uid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance==0 then
            response.ret = - 102
            return response
        end

        local mAterritory = getModelObjs("aterritory",aid,true)
        response.data.list = mAterritory.killlist()


        local flag,lasttime = mAterritory.rewardtime()
        local mAtmember = uobjs.getModel('atmember')
        -- 没有参与本轮击杀  但是军团有奖励可领取
        if mAtmember.kill_at ~=  lasttime then
            mAtmember.killreward = 0 
        end

        response.data.received =  mAtmember.killreward -- 有没有领取奖励 0未领取 1已领取
        response.ret = 0
        response.msg = "Success"
        return response

    end

    -- 获取军团个人击杀海盗排名
    function self.action_personalrank(request)
        local response = self.response
        local uid = request.uid

        if not uid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"atmember","userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance==0 then
            response.ret = - 102
            return response
        end

        local mAtmember = uobjs.getModel('atmember')
        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,true)

        if not mAterritory.isNormal() then
            response.data.list = {}
            response.ret = 0
            response.msg = "Succresess"
            return response
        end

        response.data.list = mAtmember.killlist()
        response.ret = 0
        response.msg = "Succresess"
        return response
    end

    -- 获取击杀海盗排行榜奖励  奖励只添加铀矿 和 天然气
    function self.action_rankreward(request)
        local response = self.response
        local uid = request.uid

        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance==0 then
            response.ret = - 102
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false)
        if not mAterritory.isNormal() then
            response.ret = -8411
            return response
        end

        local rankdata = mAterritory.killlist()
        if type(rankdata)~='table' or not next(rankdata)  then
            response.ret = -8412
            return response
        end
        -- 判断是不是在领奖时间
        local flag,lasttime = mAterritory.rewardtime()
        if not flag then
            response.ret = -8413
            return response
        end

        local rank = 0
        for k,v in pairs(rankdata) do
            if tonumber(v[2])==mUserinfo.alliance then
                rank = v[1]
                break
            end

        end

        if rank ==0 then
            response.ret = -8412
            return response
        end

        local mAtmember = uobjs.getModel('atmember')
        -- 没有参与本轮击杀  但是军团有奖励可领取
        if mAtmember.kill_at ~=  lasttime then
            mAtmember.killreward = 0 
            mAtmember.kill_at = lasttime
            mAtmember.killcount = 0
        end

        if mAtmember.killreward == 1 then
            response.ret = -20018
            return response
        end

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=mUserinfo.alliance,uid=mUserinfo.uid}
        if not ainfo then
            response.ret = code
            return response
        end

        local allianceBuidCfg = getConfig('allianceCity')
        local reward = {}
        local commander =  false
        -- 判断是不是军团长
        if tonumber(ainfo.data.role)==2 then
            commander=true
            local index = 0
            for k,v in pairs(allianceBuidCfg.allianceRank.serverRankReward) do
                if rank>=v[1][1] and rank<=v[1][2] then
                    reward = v[2]
                    break
                end
            end

            if not mAterritory.addResource(reward) then
                response.ret = -403
                return response
            end
            response.data.areward=allianceBuidCfg.allianceRank
        end

        local seacoin = 0
        for k,v in pairs(allianceBuidCfg.personRank.serverRankReward) do
            if rank>=v[1][1] and rank<=v[1][2] then
                seacoin = v[2]['seacoin']
                break
            end
        end
  
        mAtmember.addSeacoin(seacoin)
        mAtmember.killreward = 1
        if uobjs.save() and mAterritory.saveData() then
            response.data.territory=mAterritory.formatedata()
            response.data.rank=rank
            response.data.commander = commander

            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        return response
    end

    -- 获取军团任务和个人任务
    function self.action_task(request)
        local response = self.response
        local uid = request.uid

        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance==0 then
            response.ret = - 102
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false)
        if not mAterritory.isNormal() then
            response.ret = -8411
            return response
        end

        local mAtmember = uobjs.getModel('atmember')

        local atask,aflag = mAterritory.tasklist()
        response.data.task = atask
        response.data.task.auto = (atask.auto or 0)
        local ptask,flag = mAtmember.getTask()
        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end
        if aflag then
            if not mAterritory.saveData() then
                response.ret = -106
                return response                
            end
        end
        response.data.personaltask = ptask
        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 军团任务发布列表
    function self.action_publist(request)
        local response = self.response
        local uid = request.uid

        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance==0 then
            response.ret = - 102
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false)
        if not mAterritory.isNormal() then
            response.ret = -8411
            return response
        end

        local task,flag = mAterritory.tasklist()

        if flag then
            if not mAterritory.saveData() then
                response.ret = -106
                return response
            end
        end
        response.data.task = task.l
        response.data.upt = task.upt
        response.data.rn = task.rn or 0
        
        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 领取军团任务奖励
    function self.action_taskreward(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid
        local tid = request.params.tid
        local tp =  request.params.tp --2军团任务 1个人任务
        local ts= getClientTs()
        local weeTs = getWeeTs()  

        if not uid or not tid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance==0 or mUserinfo.alliance~=aid then
            response.ret = - 102
            return response
        end

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=mUserinfo.alliance,uid=mUserinfo.uid}
        if not ainfo then
            response.ret = code
            return response
        end
        local commander =  false -- 是不是军团长

        local allianceCityCfg = getConfig('allianceCity')
        local mAterritory = getModelObjs("aterritory",aid,false)
        local mAtmember = uobjs.getModel('atmember')

        local keys = tid:split('_')
        local taskinfo = {}

        local flagtime = weeTs + allianceCityCfg.pubTaskTime[1]*3600
        local refreshtime = 0 
        if ts > weeTs and ts < flagtime then
            refreshtime = flagtime-86400
        else
            refreshtime = flagtime
        end

        local allianceBuidCfg = getConfig('allianceBuid')
        local taskinfo = {}
        -- 军团任务
        if tp==2 then
            if type(mAterritory.task)~='table' or not next(mAterritory.task) then
                response.ret = -8416
                return response
            end
            -- 非当天的任务
            if mAterritory.task.upt~=refreshtime then
                response.ret = -102
                return response
            end

            if mAtmember.task.rflag[1]==1 then
                response.ret = -1976
                return response
            end

            taskinfo = allianceCityCfg.task.taskList[2][tonumber(keys[1])].list[tonumber(keys[2])]
            if type(taskinfo)~='table' then
                response.ret = -102
                return response
            end


            local cur = 0
            if tonumber(keys[1])==5 then
                for i=1,4 do    
                    cur = cur + (mAterritory.task.tk.cur['r'..i] or 0)
                end
            else
                cur = mAterritory.task.tk.cur
            end

            if cur < mAterritory.task.tk.con then
                response.ret = -30002
                return response
            end

            mAtmember.task.rflag[1]=1

            -- 军团长可以领取资源 团员只能领公海币
            if tonumber(ainfo.data.role)==2  then
                commander =  true
                local resource = {}
                for k,v in pairs(taskinfo[3]) do
                    resource[v[1]] = (resource[v[1]] or 0) + v[2]
                end

                if next(resource) then
                    if not mAterritory.addResource(resource) then
                        response.ret = -106
                        return response
                    end
                end
            end
        else--个人任务
            if mAtmember.task.upt~=refreshtime then
                response.ret = -102
                return response
            end

            -- 判断是第几个个人任务
            local index=0
            for k,v in pairs(mAtmember.task.tk) do
                if v.tid == tid then
                    index =  k
                    break
                end
            end

            if index==0 then
                response.ret = -102
                return response
            end

            local pindex = index+1
            if mAtmember.task.rflag[pindex]==1 then
                response.ret = -1976
                return response
            end

            taskinfo = allianceCityCfg.task.taskList[1][tonumber(keys[1])].list[tonumber(keys[2])]
            if type(taskinfo)~='table' then
                response.ret = -102
                return response
            end

            local cur = 0
            if tonumber(keys[1])==3 then
                for i=1,4 do
                    cur = cur + (mAtmember.task.tk[index].cur['r'..i] or 0)
                end
            else
                cur = mAtmember.task.tk[index].cur
            end

            if cur < mAtmember.task.tk[index].con then
                response.ret = -30002
                return response
            end

            mAtmember.task.rflag[pindex]=1

            local resource = {}
            for k,v in pairs(taskinfo[3]) do
                resource[v[1]] = (resource[v[1]] or 0) + v[2]
            end

            if next(resource) then
                if not mAterritory.addResource(resource) then
                    response.ret = -106
                    return response
                end
            end
        end

        local seacoin = taskinfo[2][2]
        if seacoin >= 0 then
            if not mAtmember.addSeacoin(seacoin) then
                response.ret = -106
                return response
            end
        end

        if uobjs.save() and mAterritory.saveData() then
            response.data.task = mAterritory.task
            response.data.personaltask = mAtmember.task
            response.data.commander =  commander            

            response.ret = 0
            response.msg = "Success" 
        else
            response.ret = -106
        end

        return response
    end

    function self.action_territoryrank(request)
        local response = self.response
        local uid = request.uid

        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance==0 then
            response.ret = 0
            response.msg = "Success"              
            response.data.ranklist={}
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,true)

        response.data.ranklist = mAterritory.rank()
        response.ret = 0
        response.msg = "Success"  
        return response       
    end

    -- 军团任务贡献度列表
    function self.action_atcontrilist(request)
        local response = self.response
        local uid = request.uid

        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance==0 then
            response.ret = - 102
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,true)
        if not mAterritory.isNormal() then
            response.ret = -8411
            return response
        end

        local contrilist = {}
        response.data.contrilist = mAterritory.atcontrilist()

        response.ret = 0
        response.msg = 'success'

        return response
    end


    return self
end

return api_territory_get