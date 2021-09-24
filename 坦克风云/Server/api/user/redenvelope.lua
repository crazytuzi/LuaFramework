--desc:馈赠红包
--user:chenyunhe

local function api_active_redenvelope(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }
    -- 发红包
    function self.action_send(request)
        local response = self.response
        local uid = request.uid
        local pid = request.params.pid--道具id
        local num = tonumber(request.params.num)--红包个数
        local channel=request.params.channel--聊天频道

        if not table.contains({1,2},channel) or num<=0 then
        	response.ret=-102
        	return response
        end

        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')
        local mProp = uobjs.getModel('props')

        if moduleIsEnabled('redGift') ==0 then
           response.ret=-180
           return response
        end

        local propCfg = getConfig('prop')
    	local cfg = propCfg[pid]

	 	if not mProp.checkPropCanUse(pid) then
	        response.ret = -1995
	        return response
	    end

        local redis = getRedis()
	    local redPacket=getConfig('player.redPacket')
        local date = os.date('%m%d')
        local daykey="zid"..getZoneId()..'.daybags'..date
        local todaynum=tonumber(redis:get(daykey)) or 0
        --超过当天发送数量上限
        if todaynum>=redPacket.sendLimit then
            response.ret=-1993
            return response
        end
        -- 超过最大上限
	    if num>redPacket.useLimit then
	    	response.ret=-1993
	    	return response
	    end


		if  not mBag.use(pid,num) then
	        response.ret = -1989
	        return response
	    end

	    local alliance=mUserinfo.alliance
        --没有军团不能发军团红包
        if alliance==0 and channel==2  then
            response.ret=-102
            return response
        end
	    local redkeys=redis:keys("zid"..getZoneId()..'.redbag*')
        if type(redkeys)=='table' and next(redkeys) then
        	local flag=0
            local alflag=0--玩家所在军团红宝数量
        	for k,v in pairs(redkeys) do
        		local jsonde=json.decode(redis:hget(v,'info'))
        		if jsonde.status==1 and jsonde.ts>ts then
                    if jsonde.alliance==nil then  jsonde.alliance=0 end
                    --如果玩家 在军团中 并且发的是军团红包
                    if channel==2 then
                        if jsonde.alliance==alliance and jsonde.channel==2 then
                            alflag=alflag+1
                        end
                    end
                    if channel==1 then
                        if jsonde.channel==1 then
                            flag=flag+1
                        end
                    end
        		end
        	end

            if channel==2 then
                --军团红包数量限制个数
                if alflag>=redPacket.coexist then
                    response.ret=-8204
                    return response
                end
            end

            if channel==1 then
                --世界红包限制个数
                if flag>=redPacket.coexist then
                    response.ret=-8204
                    return response
                end                
            end
           

        end

        local redid=ts..'_'..uid
        local redkey="zid"..getZoneId()..'.redbag'..redid
        --不能同一时间发送
 		local redinfo=redis:hget(redkey,'info')
	    local redbag=json.decode(redinfo)
	    if type(redbag)=='table' and next(redbag) then
	    	response.ret=-8203--已经存在
	    	return response
	    end

	     ------分配红包start-----------
		 local function randbag(total,bn)
		 	local bags={}--分配的结果
		 	local totalgold=total--总金额
		 	local i=0
		 	local rate1=math.ceil(math.max(1,totalgold/20))
		 	local rate2=math.ceil(math.max(1,totalgold/2))
		 	while(i<bn)
		 	do
		 		if i<bn-1 then
                    setRandSeed()
		 			local rand=math.floor(rand(100*rate1,math.min(100*rate2,100*(totalgold-rate1*(bn-i))))/100)
		 			table.insert(bags,rand)
		 			totalgold=totalgold-rand
		 		else
		 			table.insert(bags,totalgold)
		 		end
		 		i=i+1
		 	end

		 	return bags
		 end

         local bags={}
         local pern=cfg.useSendItem.num
         local pergold=cfg.useSendItem.gems
         -- 每个红包都要独立分配份数
		 for i=1,num do
            local getbags=randbag(pergold,pern)
		 	for k,v in pairs(getbags)  do
		 		table.insert(bags,v)
		 	end
		 end
		------分配红包end-----------

  		--红包的个数
        local bn=cfg.useSendItem.num*num
	    -----end----------
	    --过期时间
        local et=ts+redPacket.existTime

        local result={
           uid=uid,
           vip=mUserinfo.vip,
           pic=mUserinfo.pic,--头像
           picBox=mUserinfo.bpic,--头像框
           picAdd=mUserinfo.apic,--挂件
           name=mUserinfo.nickname,--昵称
           ts=et,--红包过期时间
           id=redid,--红包id
           pid=pid,--红包道具
           num=bn,--红包数量
           list={},--领取玩家的信息
           channel=channel,--频道类型
           status=1,-- 1可领取 2领完
           bagsinfo=bags,--红包数据
           alliance=mUserinfo.alliance--军团id
        }

		local data=json.encode(result)
		redis:hset(redkey,'info',data)
		redis:hset(redkey,'num',bn)
		redis:expireat(redkey,et)

        activity_setopt(uid,'rechargebag',{send=num,pid=pid})
       

        if uobjs.save() then
            redis:set(daykey,todaynum+1)
            redis:expireat(daykey,ts+86400)
            response.ret = 0
            response.msg = 'Success'
            response.data.bag = mBag.toArray(true)
            response.data.rbid=redid--红包id
            response.data.redet=et--过期时间
        else
            response.ret=-106
        end

        return response
    end

    -- 红包数据格式
    function self.form_bag(bag,avoid)
    	local tab={'uid','vip','pic','picBox','picAdd','name','ts','id','pid','num','list','channel','status','alliance'}
    	local r={}
        if type(avoid)~='table' then
            avoid={}
        end

    	if type(bag)=='table' and next(bag) then
    		for k,v in pairs(tab) do
                if not table.contains(avoid,v) then
                    r[v]=bag[v]
                end
    		end
    	end

    	return r
    end

    -- 根据频道类型获得当前频道可领取的红包
    --channel 2军团 1世界 空值或Nil则同时获取军团和世界各30条
    function self.action_getbychannel(request)
		local response = self.response
        local uid = request.uid
        local channel=request.params.channel or ''--聊天频道 没有值则获取所有红包信息
        local ts = getClientTs()

        if not table.contains({1,2,''},channel) or not uid then
        	response.ret=-102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag"})
        local mUserinfo = uobjs.getModel('userinfo')        

        local redis = getRedis()
	    local redkeys=redis:keys("zid"..getZoneId()..'.redbag*')
	    local alredbag={}
        local wdredbag={}
        local alliance=mUserinfo.alliance


		if type(redkeys)=='table' and next(redkeys) then
        	for k,v in pairs(redkeys) do
        		local jsonde=json.decode(redis:hget(v,'info'))
        		if  jsonde.ts>ts then
                    local received=0--没有领取过
                    for k,v in pairs(jsonde.list) do
                        if v[1]==uid then
                            received=1
                            break
                        end
                    end

                    local formbag=self.form_bag(jsonde,{'list'})
                    formbag.received=received
                    if channel=='' or channel==nil then
                        if formbag.channel==2 and #alredbag<31 and alliance>0 and formbag.alliance==alliance then
                            table.insert(alredbag,formbag)
                        end

                        if formbag.channel==1 and #wdredbag<31 then
                            table.insert(wdredbag,formbag)
                        end
                    else
                        if formbag.channel==channel then
                            if channel==2 and alliance>0 and #alredbag<31 and formbag.alliance==alliance then
                                table.insert(alredbag,formbag)
                            elseif channel==1 and #wdredbag<31 then
                                table.insert(wdredbag,formbag)
                            end
                        end
                    end
                   
        		end
        	end
        end

        response.ret = 0
        response.msg = 'Success'
        if channel=='' or channel==nil then
            response.data.wordrb=wdredbag
            response.data.alliancerb=alredbag
        end

        if channel==1 then
             response.data.wordrb=wdredbag
        end

        if channel==2 then
            response.data.alliancerb=alredbag
        end
        

        return response
    end

    -- 获取某个红包的信息  如果没抢过则需要执行抢红包操作
    function self.action_getredinfo(request)
		local response = self.response
        local uid = request.uid
        local redid = request.params.redid--红包id

        if  not uid or not redid then
        	response.ret=-102
        	return response
        end

 		local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUserinfo = uobjs.getModel('userinfo')        

        local redis = getRedis()
        local redkey="zid"..getZoneId()..'.redbag'..redid
	    local redinfo=redis:hget(redkey,'info')
	    local redbag=json.decode(redinfo)
        local empbag=1
        if type(redbag)~='table' then
            redbag={}
            empbag=0
        end

        -- 玩家自己发了军团红包 更换了军团  如果聊天界面不刷新 界面上玩家还是可以去点之前的军团红包(该操作是不允许的)
        if redbag.channel==2 and mUserinfo.alliance~=redbag.alliance then
            response.ret=-2039
            return response
        end        

        --每日玩家领取红包的次数
        local date = os.date('%m%d')
		local ugetkey="zid"..getZoneId()..'.getbag'..date
	    local jsonlog=json.decode(redis:get(ugetkey))
        local uk='u'..uid
		if type(jsonlog)~='table' then
			jsonlog={}
			jsonlog[uk]=0
		else
			if jsonlog[uk]==nil then
				jsonlog[uk]=0
			end
		end

	    --flag 1抢夺成功 2已领取过 3 红包不存在 4 红包派发完
	    --{玩家UID,玩家名字,领取金额,领取时间,}
	    local saveflag=0
        local addgems=0
	    if type(redbag)=="table" and next(redbag) and redbag.uid~=uid and redbag.ts>ts then
	    	local uflag=0
			for k,v in pairs(redbag.list) do
    			if v[1]==uid then
    				uflag=1
    				break
    			end
    		end
    		
    		if uflag==1 then
	    		response.data.flag=2
	    	else
	    		local leftnum=tonumber(redis:hget(redkey,'num'))
				if leftnum<=0 then
					-- 纠正状态
					if redbag.status~=2 then
						redbag.status=2
						local data=json.encode(redbag)
						redis:hset(redkey,'info',data)
						redis:expireat(redkey,redbag.ts+86400)
					end
		    		response.data.flag=4
		    	else
		    		local redPacket=getConfig('player.redPacket')
		    		if jsonlog[uk]>=redPacket.getLimit then
		    			response.ret=-1993
		    			return response
		    		end

		    		local left=redis:hincrby(redkey,"num",-1)
		    		if left<0 then
		    			response.data.flag=4
		    		else

			    		setRandSeed()
			    		local rand=rand(1,#redbag.bagsinfo)
			    		local gems=redbag.bagsinfo[rand]
                        addgems=gems
			    		if not mUserinfo.addResource({gems=gems}) then
			    			response.ret=-403
			    			return response
			    		end

                        if gems>0 then
                             regActionLogs(uid,1,{action=172,item="",value=gems,params={}})
                        end

			    		table.insert(redbag.list,{uid,mUserinfo.nickname,gems,ts})
			    		table.remove(redbag.bagsinfo,rand)
			    		if #redbag.list==redbag.num then
			    			redbag.status=2
			    		end
			    		local data=json.encode(redbag)
						redis:hset(redkey,'info',data)
						redis:expireat(redkey,redbag.ts+86400)

						jsonlog[uk]=jsonlog[uk]+1
					    local logdata=json.encode(jsonlog)
						redis:set(ugetkey,logdata)
						redis:expireat(ugetkey,redbag.ts+86400)

						response.data.flag=1
						saveflag=1
		    		end
		    	end
	    	end
	    else
	    	if type(redbag)~='table' or not next(redbag) then
	    		response.data.flag=3
	    	end
	    end

	    if saveflag==1 then 
	    	if not uobjs.save()  then
	    		response.ret=-106
	    		return response
	    	end
	    end

        response.ret = 0
        response.msg = 'Success'
        response.data.rb=self.form_bag(redbag)

        response.data.rb.received=0
        if response.data.flag==1 or response.data.flag==2  then
               response.data.rb.received=1
        end

        if empbag==0 then
            response.data.rb=nil
        end

        response.data.lognum=jsonlog[uk]
        response.data.addgems=addgems
        return response
    end
   

    return self
end

return api_active_redenvelope
