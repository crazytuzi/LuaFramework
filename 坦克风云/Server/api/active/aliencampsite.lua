--
-- desc: 异星营地、异星营地换皮（徽章）
-- user:chenyunhe
-- 注 ：换皮是基于原功能上修改的 根据活动配置版本不同 选择异星武器或者徽章配置
--      换皮后关于徽章的活动任务列表中没有配置关于徽章品质的任务
local function api_active_aliencampsite(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'aliencampsite',
    }

    --掠夺
    function self.action_pillage(request)
        local uid = request.uid
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local num = tonumber(request.params.num) -- 抓取选项
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local response = self.response
  
        if not table.contains({0,1},free) or not table.contains({1,10},num) or not uid then
           response.ret=-102
           return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        -- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].t ~= weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
            if type(mUseractive.info[self.aname].tk)  == "table" then
                mUseractive.info[self.aname].tk = nil
            end
        end
        if mUseractive.info[self.aname].v ==1 and free==1 then
            response.ret = -102
            return response
        end

        -- 判断是否有免费次数 必须先领取 免费的 fuck
        if mUseractive.info[self.aname].v == 0 and free ~=1 then
            response.ret = -102
            return response
        end


        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 消耗钻石
        local gems = 0
        if free==1 then
             mUseractive.info[self.aname].v=1
        else
            if  num == 1 then
                gems = activeCfg.cost1
            else
                gems = activeCfg.cost2
            end
        end

        local reward={}
        local report={}
        local allreward={}
        local blueQuality = 0 -- 蓝色品质
        local purpleQuality = 0 -- 紫色品质
	    local orangeQuality = 0 -- 橙色品质
        
        local cfg = {}
        -- 配置小于3 异星武器碎片配置
        if mUseractive.info[self.aname].cfg<3 then
            cfg = getConfig("alienWeaponCfg")
        else
            -- 徽章配置
            cfg = getConfig("badge.fragmentList")
        end

        for i=1,num do
            local result
            if num == 1 then
                result,_ = getRewardByPool(activeCfg.serverreward['pool1'],1)
            else 
                result,_ = getRewardByPool(activeCfg.serverreward['pool2'],1)
            end
        
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                    local quality = 0
                    rkList = rk:split('_')
                    if rkList[1] == "aweapon" and string.find(rkList[2], 'af') then
                        local weaponId = cfg.fragmentList[rkList[2]].weaponId
                        quality = cfg.weaponList[weaponId].color
                    elseif rkList[1] == "badge" and string.find(rkList[2], 'mf') then
                        quality = cfg[rkList[2]].quality
                    end
                    if quality == 3 then
                        blueQuality = blueQuality + rv
                    elseif quality == 4 then
                        purpleQuality = purpleQuality + rv
		            elseif quality == 5 then
                        orangeQuality = orangeQuality + rv
                    end
                end
            end
            local currrew={}
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    currrew[rk]=(currrew[rk] or 0)+rv
                end
            end
            --本次抽奖获得的奖励
            table.insert(allreward,i,formatReward(currrew))
        end

        local taskConf = activeCfg.taskList
        mUseractive.info[self.aname].tk = mUseractive.info[self.aname].tk or {}
        for k, v in pairs(taskConf) do
            mUseractive.info[self.aname].tk[v.index] = mUseractive.info[self.aname].tk[v.index] or {}
            mUseractive.info[self.aname].tk[v.index].r = mUseractive.info[self.aname].tk[v.index].r or 0
            mUseractive.info[self.aname].tk[v.index].index = mUseractive.info[self.aname].tk[v.index].index or v.index
            
            local cur = mUseractive.info[self.aname].tk[v.index].cur or 0
            mUseractive.info[self.aname].tk[v.index].cur = cur
            if  cur < v.num then
                if v.type == "yx1" and num == 1 then
                    cur = cur + 1
                end
                if v.type == "yx2" then
                    cur = cur + blueQuality   -- 统计蓝色
                end
                if v.type =="yx3"  then
                    cur = cur + purpleQuality --统计紫色
                end
                if v.type == "yx4" and num == 10 then
                    cur = cur + 1
                end 
                if v.type == "yx5" then
                    cur = cur + gems
                end

		        if v.type == "yx6" then
                    cur = cur + orangeQuality   -- 统计橙色
                end
            end 

            mUseractive.info[self.aname].tk[v.index].cur = cur

            if cur >= v.num and (mUseractive.info[self.aname].tk[v.index].r or 0) == 0 then
                mUseractive.info[self.aname].tk[v.index].r = 1
            end
        end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
             regActionLogs(uid,1,{action=173,item="",value=gems,params={num=num}})
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','aliencampsite',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end

        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            
            table.insert(data,1,{ts,report,num,harCReward})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end         
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward
            end
            response.data[self.aname].reward=allreward
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    --掠夺log
    function self.action_pillagelog(request)
        local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"useractive"})
        local mUseractive = uobjs.getModel('useractive')

        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data

        return response
    end

    --掠夺刷新
    function self.action_pillagerefresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local weeTs = getWeeTs()
        local flag = false
        if mUseractive.info[self.aname].t < weeTs then
            if type(mUseractive.info[self.aname].tk)  == "table" then
                mUseractive.info[self.aname].tk = nil
                flag = true
            end
        end

        if flag then
            uobjs.save()
        end
        response.data[self.aname] =mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    --营地任务
    function self.action_campsitetask(request)
        local response=self.response
        local uid=request.uid
        local tid=request.params.tid

        if not tid or not uid then
            response.ret=-102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive',"props","bag",})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- 未完成
        if mUseractive.info[self.aname].tk[tid].r==0 then
            response.ret=-1981
            return response
        end
        -- 已领取
        if mUseractive.info[self.aname].tk[tid].r==2 then
            response.ret=-8037
            return response
        end
        -- 其他值
        if mUseractive.info[self.aname].tk[tid].r~=1 then
            response.ret=-102
            return response
        end
      
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local rewardCfg=activeCfg.serverreward.taskList[tid].serverreward
        --配置判断
        if type(rewardCfg)~='table' or not next(rewardCfg) then
            response.ret=-102
            return response
        end

        local reward={}
        for k,v in pairs(rewardCfg) do
            reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].tk[tid].r=2
        if uobjs.save() then
            response.data.reward=formatReward(reward)
            response.data.tk = mUseractive.info[self.aname].tk or {}
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
    ------------------------------------------------------------
    return self
end

return api_active_aliencampsite