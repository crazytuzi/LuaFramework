--
-- desc: 矩阵商店
-- user: chenyunhe
--
local function api_active_armorshop(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'armorshop',
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
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local flag = false
        if type(mUseractive.info[self.aname].shop1) ~= 'table' then
            flag = true
            local mArmor = uobjs.getModel('armor')
            local matrixListCfg=getConfig('armorCfg.matrixList')
            local activeCfg = mUseractive.getActiveConfig(self.aname)
            local location = activeCfg.serverreward.location-- 参照第几个矩阵 初始化相应的矩阵品质
            local vipindex = mUserinfo.vip+1

            local maxrand = #activeCfg.serverreward.vip[2][vipindex]
            setRandSeed()     

            mUseractive.info[self.aname].shop1 = {} -- 商店数据
            local selected = mArmor.used[location] or {}

            for i=1,6 do
                local quality = 1
                if next(selected) and selected[i]~=0 then
                    local mid = selected[i]
                    local armor = mArmor.info[mid]
                    local ql = matrixListCfg[armor[1]]['quality']
                
                    if ql >= activeCfg.serverreward.changePoint then
                        quality = 2
                    end
                end

                local dicindex = rand(1,maxrand)
                local vipdic = activeCfg.serverreward.vip[2][vipindex][dicindex]
            
                local itemcfg = activeCfg.serverreward.goods[quality]
                --客户端格式 服务端格式 品质 原价 现价 vip折扣 是否已购买
 
                local curprice = math.floor(itemcfg[2][i]*vipdic+0.5)
                table.insert(mUseractive.info[self.aname].shop1,{formatReward(itemcfg[1][i]),itemcfg[1][i],quality,itemcfg[2][i],curprice,vipdic,0})
            end

            mUseractive.info[self.aname].shop2 = {}
            for k,v in pairs(activeCfg.serverreward.disGoods[1]) do
                -- 客户端格式  服务端格式 品质 原价 现价  折扣  是否购买
                local price = activeCfg.serverreward.disGoods[2][k]
                table.insert(mUseractive.info[self.aname].shop2,{formatReward(v),v,2,price,math.ceil(price*activeCfg.serverreward.getCount),activeCfg.serverreward.getCount,0})
            end   
        end

        if not mUseractive.info[self.aname].gem then
            flag = true
            mUseractive.info[self.aname].gem = 0--累计充值
            mUseractive.info[self.aname].dk = 0 --抵扣钻石
            mUseractive.info[self.aname].zk = 0 --折扣券
            mUseractive.info[self.aname].zkn = 0 -- 折扣券总数
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
    
    --  商店兑换
    function self.action_buy(request)
        local response = self.response
        local uid=request.uid
        local shop = request.params.shop -- 哪个商店
        local item =  request.params.id -- 购买的哪一个商品
        if not item or not table.contains({1,2},shop) then
           response.ret =-102
           return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if type(mUseractive.info[self.aname]['shop'..shop])~='table' then
            response.ret = -102
            return response
        end

        local shopcfg = copyTable(mUseractive.info[self.aname]['shop'..shop][item]) 
       
        if type(shopcfg)~='table' then
            response.ret = -102
            return response
        end

        -- 已经购买了
        if shopcfg[7] ==1 then
            response.ret = -1976
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local costgem = 0
        if shop==1 then
            -- 优先使用抵扣券
            if mUseractive.info[self.aname].dk >= shopcfg[5] then
                mUseractive.info[self.aname].dk = mUseractive.info[self.aname].dk-shopcfg[5]
            else             
                costgem = shopcfg[5]-mUseractive.info[self.aname].dk
                mUseractive.info[self.aname].dk=0
            end
        else
            -- 使用了折扣券
            if request.params.usezk then
                if mUseractive.info[self.aname].zk <= 0 then
                    response.ret = -102
                    return responsem
                end

                costgem = math.ceil(shopcfg[5]*activeCfg.discountRate)
                mUseractive.info[self.aname].zk = mUseractive.info[self.aname].zk - 1 
            else
                costgem = shopcfg[5]
            end
        end

        if costgem>0 then
            if not mUserinfo.useGem(costgem) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action = 196, item = "", value = costgem, params = {}})
        end
 
        if not takeReward(uid,shopcfg[2]) then
            response.ret =-403
            return response
        end
        
        mUseractive.info[self.aname]['shop'..shop][item][7] = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = shopcfg[1]
            response.data.userinfo = mUserinfo.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response        
    end

    return self
end

return api_active_armorshop