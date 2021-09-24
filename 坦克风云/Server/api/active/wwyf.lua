 --
-- desc: 三周年-无畏远方
-- user: chenyunhe
--
local function api_active_wwyf(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'wwyf',
    }

    function self.before(request)
        local response = self.response    
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        if not uid then
            response.ret = -102
            return response
        end

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
    end

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local weeTs = getWeeTs()
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')


        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 初始化生涯日志
        local flag = false
        if type(mUseractive.info[self.aname].ca) ~='table' or type(mUseractive.info[self.aname].cr)~='table' then
        	flag = true
            mUseractive.info[self.aname].ca = {}
            mUseractive.info[self.aname].cr = {}
            for k,v in pairs(activeCfg.serverreward.careerList) do
                table.insert(mUseractive.info[self.aname].ca,{})
                table.insert(mUseractive.info[self.aname].cr,0)
            end
        end

        if not mUseractive.info[self.aname].fb then
            mUseractive.info[self.aname].fb = 0
        end

        -- 1.注册时间
    	if not next(mUseractive.info[self.aname].ca[1]) then
    		flag =  true
    		mUseractive.info[self.aname].ca[1] ={mUserinfo.regdate}
    	end

        if not mUseractive.info[self.aname].join then
            flag = true
            mUseractive.info[self.aname].join = 0
        end

        -- 2.加入军团时间和军团名称
		if mUseractive.info[self.aname].join==0 then
    		flag =  true
            if mUserinfo.alliance>0  then
                local adt = 0
                local execRet,code = M_alliance.getalliance{uid=uid,aid=mUserinfo.alliance,acallianceLevel=1}
                if execRet and execRet.data then
                    adt = tonumber(execRet.data.join_at) or 0
                    mUseractive.info[self.aname].ca[2] ={adt, mUserinfo.alliancename}
                end
            end
            mUseractive.info[self.aname].join=1
    	end

        -- 3.军功
		if not next(mUseractive.info[self.aname].ca[3]) then
    		flag =  true
            if mUserinfo.rp>0 then
                mUseractive.info[self.aname].ca[3] ={mUserinfo.rp}
            else
                mUseractive.info[self.aname].ca[3] ={0}
            end
    	end    	
        -- 4.好友数
		if not next(mUseractive.info[self.aname].ca[4]) then
    		flag =  true
    		local mFriends = uobjs.getModel('friends')
            local fnum = table.length(mFriends.info)
            if fnum>0 then
                mUseractive.info[self.aname].ca[4] ={fnum}
            else
                mUseractive.info[self.aname].ca[4] ={0}
            end	
    	end    	
        -- 5.游戏时长
		if not next(mUseractive.info[self.aname].ca[5]) then
    		flag =  true
            if mUserinfo.olt>0 then
                mUseractive.info[self.aname].ca[5] ={tonumber(string.format('%.2f',mUserinfo.olt/3600))}
            else
                mUseractive.info[self.aname].ca[5] = {0}
            end	
    	end

        if type(mUseractive.info[self.aname].gt)~='table' then
            flag = true
        	mUseractive.info[self.aname].gt={}
        	for k,v in pairs(activeCfg.serverreward.giftList) do
        		table.insert(mUseractive.info[self.aname].gt,0)
        	end
        end

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取生涯奖励
    function self.action_careerreward(request)
    	local response = self.response
        local uid= request.uid
        local item = request.params.i
        local ts = getClientTs()

        if not item then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUserinfo.level < activeCfg.levelLimit then
        	response.ret = -102
        	return response
        end

        if not next(mUseractive.info[self.aname].ca[item]) then
        	response.ret = -1981
        	return response
        end

        if mUseractive.info[self.aname].cr[item]==1 then
        	response.ret = -1976
        	return response
        end

        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        if currDay<item then
            response.ret = -102
            return response
        end


        local itemcfg = activeCfg.serverreward.careerList[item]
        if type(itemcfg)~='table' then
            response.ret = -102
            return response
        end
          
        if not takeReward(uid,itemcfg.r) then
        	response.ret = -403
        	return response
        end
    	mUseractive.info[self.aname].cr[item] = 1
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(itemcfg.r)
            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response        
    end

    -- 特别礼包
    function self.action_gift(request)
        local response = self.response
        local uid= request.uid
        local item = request.params.i
        local ts = getClientTs()

        if not item then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUserinfo.level < activeCfg.levelLimit then
            response.ret = -102
            return response
        end

        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        if item~=currDay then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].gt[item]==1 then
            response.ret = -1976
            return response
        end

        local itemcfg = activeCfg.serverreward.giftList[item]
        if type(itemcfg)~='table' then
            response.ret = -102
            return response
        end

        if not takeReward(uid,itemcfg.r) then
            response.ret = -403
            return response
        end

        if not mUserinfo.useGem(itemcfg.price) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action = 258, item = "", value = itemcfg.price, params = {i=item}})
    
        mUseractive.info[self.aname].gt[item] = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(itemcfg.r)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response        
    end

    -- facebook分享奖励
    function self.action_fbreward(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
 
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 已经领取过
        if mUseractive.info[self.aname].fb==1 then
            response.ret=-1976
            return response
        end

        local reward = copyTable(activeCfg.serverreward.fbreward)
        local report = {}
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        -- 修改状态
        mUseractive.info[self.aname].fb = 1 
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    --facebook分享地址 https://www.facebook.com/Flotten-Kommando-Community-681743588593889
    function self.action_fbURL(request)
        local uid = request.uid
        local response = self.response
        local zoneid = request.zoneid
        local lang = request.lang
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not zoneid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
     
        local url = nil
        local urlkey = "facebookshareurl"
        local freedata = getFreeData(urlkey)
        if freedata then
            url = freedata.info[lang] or nil
        end
        
        
        response.data.fb = mUseractive.info[self.aname].fb or 0
        response.data.url =  url
        response.ret = 0
        response.msg = 'Success'

        return response
    end
   


    return self
end

return api_active_wwyf
