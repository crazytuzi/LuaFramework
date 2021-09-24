-- desc:狂欢日
-- user:chenyunhe
-- 注：秒杀区域的数据生成 会根据配置数量个数 使用对应的随机规则 随机出来的三个物品不一样
-- 随机方式1：配置数量是3的倍数<2  纯随机   
-- 随机方式2：配置数量是3的倍数>=2 下一次随机物品 跟上一次不能相同 且保证所有物品都有机会出现  一轮之后  重新开始
-- 随机方式3：配置数量不是3的倍数 且倍数>=2  下一次随机的物品跟上一次的不一样

-- 秒杀区 每隔一段时间刷新
-- 折扣区 不刷新
-- 活动开一天 整个活动从早9点到晚9点
-- 所有物品全服共享

local function api_active_orgiasticday(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'orgiasticday',
    }

    -- 验证 当前时间是否在开启时间点范围内
    function self.checktime(timeShow)
    	if type(timeShow)~='table' then
    		return false
    	end
    	local hour = tonumber(getDateByTimeZone(ts,'%H'))
	    if hour>=timeShow[1] and hour<timeShow[2] then
	     	return true
	    end

	    return false
    end

    -- 获取物品列表  秒杀和折扣
    function self.action_shoplist(request)
		local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end

    	local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local redis = getRedis()
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 折扣商店数据
        local buyShop = copyTable(activeCfg.serverreward.buyShop)
        local clientBuyShop={}--客户端商店列表
        for k,v in pairs(buyShop) do
            local cachekey ="zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..".shop1.id."
            local c =tonumber(redis:get(cachekey..k)) or 0
            
            v['left'] = v['bn']-c -- 剩余数量
            if v['left']<0 then
            	v['left'] = 0
            end
            v['id'] = k
            table.insert(clientBuyShop,v)
        end

 		local miaoShaShop = {}
   		-- 开启时间段判断  秒杀商店
		if  self.checktime(activeCfg.timeShow)  then
	 		-- 玩家在秒杀商店购买记录
	        local grabogkey ="zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."grablog.uid_"..uid
		    local grablog=json.decode(redis:get(grabogkey))
			if type(grablog)~='table' then
				grablog={}
			end

	        local miaoShaCfg = copyTable(activeCfg.serverreward.shopItems)
	        local flag,randkey = self.randgrabshop(activeCfg,mUseractive.info[self.aname].st)
	        if not flag then
	        	response.ret = -102
	        	return response
	        end

	        for _,v in pairs(randkey) do
	        	local tmpitem = {}
	        	local sid = 'i'..v
	        	local cachekey ="zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..".shop2.id."
	        	local c =tonumber(redis:get(cachekey..sid)) or 0
	        	tmpitem= miaoShaCfg[sid]
	        	tmpitem['isBuy'] = 0
	            if type(grablog) == 'table' and table.contains(grablog,sid) then
	            	tmpitem['isBuy'] = 1
	            end

	        	tmpitem['left'] = tmpitem['bn'] - c --剩余数量
	        	if tmpitem['left']<0 then
	        		tmpitem['left'] = 0
	        	end
	        	tmpitem['id'] = sid
	        	table.insert(miaoShaShop,tmpitem)
	        end

        end

        response.data.buyShop = clientBuyShop
        response.data.grabShop = miaoShaShop

        response.ret = 0
        response.msg = 'Success'

        return response

    end
    
    -- 获取数据刷新标记
    function self.getrefreshnum(activeCfg)
    	-- 判断是否按设定时间间隔刷新数据
 		local starttime = getWeeTs() + activeCfg.timeShow[1]*3600
        local ts    = getClientTs()
        local curminute = math.floor((ts-starttime)/60)
        local refreshnum = math.floor(curminute/activeCfg.refreshTime)
        return refreshnum
    end

    -- 生成秒杀商店物品
    function self.randgrabshop(activeCfg,st)
    	local ret = true
    	local shoplist = {}
    	local itemnum=(table.length(activeCfg.serverreward.shopItems))
    	local ts    = getClientTs()

    	if itemnum<3 then
    		ret = false
    		return ret,shoplist
    	end
        -- 出售物品不重复
		local function rand1(result,itemnum)
    		local rd=rand(1,itemnum)
			if table.contains(result,rd) then
				return rand1(result,itemnum)
			end

			return rd
    	end

        -- 获取数据刷新标记
        local refreshnum = self.getrefreshnum(activeCfg)
        local redis =  getRedis()
    	local shop2key = "zid."..getZoneId().."."..self.aname.."ts"..st..".shop2_refresh."..refreshnum
		local shop2=json.decode(redis:get(shop2key))
   
		if type(shop2)~='table' then
 			-- 之前的刷新数据都清理掉
	        local refreshkeys =redis:keys("zid."..getZoneId().."."..self.aname.."ts"..st..".shop2_refresh.*")
	        if type(refreshkeys)=='table' then
				for k,v in pairs(refreshkeys) do
	        		redis:del(v)
	        	end
	        end

			setRandSeed()
            --本次随机三个结果可以与上次重复
	    	if itemnum<6 then
	    		for i=1,3 do
	    			local rd = rand1(shoplist,itemnum)
	    			table.insert(shoplist,rd)
	    		end
	    	end

            local lastlistkey = "zid."..getZoneId().."."..self.aname.."ts"..st..".lastshoplist"
	        local lastlist=json.decode(redis:get(lastlistkey))
            -- 本次随机三个结果与上次不同 且如果时间间隔数足够 要保证所有配置都能出现 一轮之后 依次类推
	    	if itemnum%3 ==0 and itemnum>=6 then
				local shopusedkey = "zid."..getZoneId().."."..self.aname.."ts"..st..".shopused"
	    		local shopused = json.decode(redis:get(shopusedkey))
	    		local finish = false -- 完成一轮标识
	    		if type(shopused) == 'table' and next(shopused) then
	    			-- 都出现过了 重新记录值
	    			if #shopused == itemnum then
	    				shopused = {}
	    				finish = true
	    			end
	    		else
	    			shopused = {}
	    		end

    			local newpool = {}
    			for i=1,itemnum do
    				if finish and type(lastlist)=='table' and next(lastlist) then
    					if not table.contains(lastlist,i) then
    						table.insert(newpool,i)
    					end
    				else
						if not table.contains(shopused,i) then
	    					table.insert(newpool,i)
	    				end
    				end
    			end

                local poolnum = #newpool
                local tmprand = {}
    			for i=1,3 do
    				local rd = rand1(tmprand,poolnum)
    				table.insert(tmprand,rd)
    				table.insert(shoplist,newpool[rd])
    				table.insert(shopused,newpool[rd])
    			end

	    		local useddata = json.encode(shopused)
				redis:set(shopusedkey,useddata)
	        	redis:expireat(shopusedkey,ts+86400)
	    	end
            -- 下一次随机结果跟上一次不同
	    	if itemnum%3 ~= 0 and itemnum>6 then
	    		local newpool = {}
	    		if type(lastlist) == 'table' and next(lastlist) then
	    			for i=1,itemnum do
	    				if not table.contains(lastlist,i) then
	    					table.insert(newpool,i)
	    				end
	    			end
	    		else
					for i=1,itemnum do
	    			    table.insert(newpool,i)
	    			end	    			
	    		end  

				local poolnum = #newpool
                local tmprand = {}
    			for i=1,3 do
    				local rd = rand1(tmprand,poolnum)
    				table.insert(tmprand,rd)
    				table.insert(shoplist,newpool[rd])
    			end	    		
	    	end

            -- 保存本次三个物品
	    	local data = json.encode(shoplist)
	        redis:set(shop2key,data)
	        redis:expireat(shop2key,ts+activeCfg.refreshTime*60)
            
            -- 第2,3两种随机方式  保证下一次与上一次不同(本次和上一次做对比)
			redis:set(lastlistkey,data)
	        redis:expireat(lastlistkey,ts+86400)

	        -- 清除玩家的购买记录
	        local grabogkeys =redis:keys("zid."..getZoneId().."."..self.aname.."ts"..st.."grablog.uid_*")
	        if type(grabogkeys)=='table' then
				for k,v in pairs(grabogkeys) do
	        		redis:del(v)
	        	end
	        end
	       
            -- 清除购买物品记录
	 		local redkeys=redis:keys("zid."..getZoneId().."."..self.aname.."ts"..st..".shop2.id.*")
	        if type(redkeys)=='table' and next(redkeys) then
	        	for k,v in pairs(redkeys) do
	        		redis:del(v)
	        	end
	        end	        
	    else
	        shoplist = shop2
		end

    	return ret,shoplist
    end

    --  秒杀商品 
    --  参数 itemid: 例 i1
    function self.action_grab(request)
		local response = self.response
        local uid = request.uid
        local itemid =  request.params.itemid -- 购买物品的编号
        if not uid or not itemid then
            response.ret = -102
            return response
        end

    	local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive','hero','accessory'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mHero = uobjs.getModel('hero')
        local mAccessory = uobjs.getModel('accessory')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
    	if not self.checktime(activeCfg.timeShow)  then
        	response.ret=-102
        	return response
        end
        -- 验证 当前刷新物品
        local refreshnum = self.getrefreshnum(activeCfg)
        local redis = getRedis()
        local shop2key = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..".shop2_refresh."..refreshnum
		local shop2=json.decode(redis:get(shop2key))

		if type(shop2) ~= 'table' then
			response.ret = -4001
			return response
		else
			local sid = tonumber(string.sub(itemid,2,-1))
			if not table.contains(shop2,sid) then
				response.ret = -102
				return response
			end
		end

 		local iteminfo = activeCfg.serverreward.shopItems[itemid]
        if type(iteminfo)~='table' or iteminfo.g<=0 then
        	request.ret=-102
        	return response
        end

		if not mUserinfo.useGem(iteminfo.g) then
            response.ret = -109
            return response
        end        

   	    -- 验证玩家购买状态
        local grabogkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."grablog.uid_"..uid
	    local grablog=json.decode(redis:get(grabogkey))
		if type(grablog)~='table' then
			grablog={}
		end
		if table.contains(grablog,itemid) then
			response.ret = -23304
			return respose
		end
        -- 购买上限判断
		local cachekey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..".shop2.id."..itemid
        local c = tonumber(redis:get(cachekey)) or 0
        if iteminfo.bn<=c then
        	response.ret = -1987
        	return response
        end
        local  curbuynum = tonumber(redis:incr(cachekey)) or 0
        if curbuynum>iteminfo.bn then
			response.ret = -1987
        	return response        	
        end
        redis:expire(cachekey,activeCfg.refreshTime*60)

        if not takeReward(uid,iteminfo.sr) then
        	response.ret= -403
        	return response
        end

        if iteminfo.g>0 then
        	 regActionLogs(uid,1,{action=177,item="",value=iteminfo.g,params={num=1}})
        end
        -- 记录购买物品
        table.insert(grablog,itemid)
        local jsongrab = json.encode(grablog)
        redis:set(grabogkey,jsongrab)
        redis:expire(grabogkey,activeCfg.refreshTime*60)

		if uobjs.save() then
			response.data.accessory = mAccessory.toArray(true)
        	response.data.hero = mHero.toArray(true)			
			response.data.reward = formatReward(iteminfo.sr)
	        response.ret = 0
	        response.msg = 'Success' 
	    else
	        response.ret=-106       	
        end
        
        return response                 
    end

    -- 折扣商店购买
    -- 参数 itemid:例 i1
    function self.action_buy(request)
		local response = self.response
        local uid = request.uid
        local itemid=request.params.itemid --购买物品的编号
        if not uid or not itemid then
            response.ret = -102
            return response
        end

    	local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive','hero','accessory'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
    	local mHero = uobjs.getModel('hero')
        local mAccessory = uobjs.getModel('accessory')        

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local iteminfo = activeCfg.serverreward.buyShop[itemid]
        if type(iteminfo)~='table' or iteminfo.g<=0 then
        	request.ret=-102
        	return response
        end
        -- 判断物品是否可购买
        local redis = getRedis()
		local cachekey ="zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..".shop1.id."..itemid
        local c =tonumber(redis:get(cachekey)) or 0
        if iteminfo.bn<=c then
        	response.ret = -1987
        	return response
        end
        local  curbuynum= tonumber(redis:incr(cachekey)) or 0
        if curbuynum>iteminfo.bn then
			response.ret = -1987
        	return response        	
        end
        redis:expire(cachekey,86400)

        if not takeReward(uid,iteminfo.sr) then
        	response.ret= -403
        	return response
        end

 		if not mUserinfo.useGem(iteminfo.g) then
            response.ret = -109
            return response
        end

        if iteminfo.g>0 then
        	 regActionLogs(uid,1,{action=177,item="",value=iteminfo.g,params={num=1}})
        end        

        if uobjs.save() then
        	response.data.accessory = mAccessory.toArray(true)
        	response.data.hero = mHero.toArray(true)
			response.data.reward = formatReward(iteminfo.sr)
	        response.ret = 0
	        response.msg = 'Success' 
	    else
	        response.ret=-106       	
        end
        
        return response
    end

    return self
end

return api_active_orgiasticday