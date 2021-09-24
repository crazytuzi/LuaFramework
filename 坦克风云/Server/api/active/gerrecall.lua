--
-- desc: 德国召回
-- user: chenyunhe
--
local function api_active_gerrecall(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'gerrecall',
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
        local ts = getClientTs()
    
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        activity_setopt(uid,'gerrecall',{act='login',nickname=mUserinfo.nickname,lt=ts,level=mUserinfo.level,vip=mUserinfo.vip})

        -- 根据不同身份处理数据
        if mUseractive.info[self.aname].u == 2 then
            --同步绑定玩家 和 充值钻石
            local senddata = {
                zid  = getZoneId(),
                uid  = uid,
                st = mUseractive.info[self.aname].st, 
            }

            local respbody = gerrecallrequest(senddata,4)
            respbody = json.decode(respbody)
            local gem = 0
            if respbody and type(respbody.data)=='table' and next(respbody.data) then
                mUseractive.info[self.aname].hyplayer.us={}
                for k,v in pairs(respbody.data) do
                    local flag = false

                    for _,val in pairs(mUseractive.info[self.aname].hyplayer.us) do
                        if tonumber(v.uid)==val[4] then
                            flag = true
                            break
                        end
                    end
                    if not flag then
                        table.insert(mUseractive.info[self.aname].hyplayer.us,{v.name,v.level,v.zid,v.uid})
                    end
                    gem = gem + tonumber(v.gem)
                end
            end

            if gem>tonumber(mUseractive.info[self.aname].hyplayer.gem or 0) then
                mUseractive.info[self.aname].hyplayer.gem = gem
            end
        end

        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]  
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end
    

        return response
    end


    -- 活跃玩家领取召回老玩家数量奖励
    function self.action_hyreward(request)
        local response = self.response
        local uid=request.uid
        local item  = request.params.id -- 领取的哪个奖励
        if not item then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if mUseractive.info[self.aname].u~=2 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if activeCfg.levelLimit>mUserinfo.level then
            response.ret = -102
            return response
        end

        if type(mUseractive.info[self.aname].hyplayer.h1)~='table' then
            response.ret = -102
            return response
        end
        if mUseractive.info[self.aname].hyplayer.h1[item] == 1 then
            response.ret = -1976
            return response
        end

        local giftCfg = copyTable(activeCfg.serverreward.callList1[item])
        if type(giftCfg)~= 'table' then
            response.ret = -102
            return response
        end

        -- 当前已经召回的玩家
        if type(mUseractive.info[self.aname].hyplayer.us)~='table' then
            mUseractive.info[self.aname].hyplayer.us = {}
        end
        local recallnum = #mUseractive.info[self.aname].hyplayer.us
        if recallnum<giftCfg.num then
            response.ret = -102
            return response
        end
   
        if not takeReward(uid,giftCfg.serverreward) then    
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].hyplayer.h1[item] = 1
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(giftCfg.serverreward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 活跃玩家领取召回玩家充值奖励
    function self.action_hycharge(request)
        local response = self.response
        local uid=request.uid
        local item  = request.params.id -- 领取的哪个奖励
        if not item then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUseractive.info[self.aname].u~=2 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if activeCfg.levelLimit>mUserinfo.level then
            response.ret = -102
            return response
        end

        if type(mUseractive.info[self.aname].hyplayer.h1)~='table' then
            response.ret = -102
            return response
        end
        if mUseractive.info[self.aname].hyplayer.h2[item] == 1 then
            response.ret = -1976
            return response
        end

        local giftCfg = copyTable(activeCfg.serverreward.callList2[item])
        if type(giftCfg)~= 'table' then
            response.ret = -102
            return response
        end

        if giftCfg.num>(mUseractive.info[self.aname].hyplayer.gem or 0) then
            response.ret = -102
            return response
        end

        if not takeReward(uid,giftCfg.serverreward) then    
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].hyplayer.h2[item] = 1
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(giftCfg.serverreward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response

    end

    -- 流失玩家领取回归奖励
    function self.action_lsreward(request)
        local response = self.response
        local uid=request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUseractive.info[self.aname].u~=1 then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].lsplayer.lg ==1 then
            response.ret = -1976
            return response
        end
        
        if not mUseractive.info[self.aname].lsplayer.r or mUseractive.info[self.aname].lsplayer.r == 0 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if activeCfg.returnLevel>mUserinfo.level then
            response.ret = -102
            return response
        end

        local giftCfg = copyTable(activeCfg.serverreward.gift[mUseractive.info[self.aname].lsplayer.r])
        if type(giftCfg)~= 'table' then
            response.ret = -102
            return response
        end

        local reward = {}
        for k,v in pairs(giftCfg) do
            reward[k] =math.floor(v * mUseractive.info[self.aname].lsplayer.ratio)
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].lsplayer.lg = 1
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 流失玩家领取回归充值奖励
    function self.action_lscharge(request)
        local response = self.response
        local uid=request.uid
        local item  = request.params.id -- 领取的哪个奖励
        if not item then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUseractive.info[self.aname].u~=1 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if activeCfg.returnLevel>mUserinfo.level then
            response.ret = -102
            return response
        end
        if type(mUseractive.info[self.aname].lsplayer.ch)~='table' then
            response.ret = -102
            return response
        end
        if mUseractive.info[self.aname].lsplayer.ch[item] == 1 then
            response.ret = -1976
            return response
        end

        local giftCfg = copyTable(activeCfg.serverreward.returnList[item])
        if type(giftCfg)~= 'table' then
            response.ret = -102
            return response
        end

        if giftCfg.num>(mUseractive.info[self.aname].lsplayer.gem or 0) then
            response.ret = -102
            return response
        end

        if not takeReward(uid,giftCfg.serverreward) then    
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].lsplayer.ch[item] = 1
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(giftCfg.serverreward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 流失玩家商店购买
    function self.action_lsshop(request)
        local response = self.response
        local uid=request.uid
        local item  = request.params.id -- 购买的商品id
        if not item then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUseractive.info[self.aname].u~=1 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if activeCfg.returnLevel>mUserinfo.level then
            response.ret = -102
            return response
        end
        if type(mUseractive.info[self.aname].lsplayer.sh)~='table' then
            response.ret = -102
            return response
        end

        local shopCfg = copyTable(activeCfg.serverreward.shopList[mUseractive.info[self.aname].lsplayer.sid])
        if type(shopCfg)~= 'table' then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].lsplayer.sh[item] >= shopCfg.limit then
            response.ret = -1976
            return response
        end

        local gems = shopCfg.value[item]
        if gems<=0 then
            response.ret = -102
            return response
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action = 239, item = "", value = gems, params = {}})
        end

        if not takeReward(uid,shopCfg.serverreward[item]) then    
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].lsplayer.sh[item] = 1
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(shopCfg.serverreward[item])
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 回归玩家绑定
    function self.action_bind(request)
        local response = self.response
        local uid=request.uid
        local code  = request.params.code -- 召回码
        local ts = getClientTs()
        if not code then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
      
        if mUseractive.info[self.aname].u~=1 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if activeCfg.returnLevel>mUserinfo.level then
            response.ret = -102
            return response
        end

        if next(mUseractive.info[self.aname].lsplayer.bind) then
            response.ret = -27020
            return response
        end

        local senddata = {
            zid  = getZoneId(),
            uid  = uid,
            name = mUserinfo.nickname,-- 玩家的昵称
            st = mUseractive.info[self.aname].st, 
            level = mUserinfo.level,
            code = code,
        }

        local respbody = gerrecallrequest(senddata,2)
        respbody = json.decode(respbody)
        if type(respbody.data)~= 'table' then
            response.ret = -1
            return response
        end
        
        if respbody.ret ~= 0 then
            response.ret = -1
            return response
        end

        if respbody.data.flag~=0 then
            response.ret = respbody.data.flag
            return response
        end
    
        mUseractive.info[self.aname].lsplayer.bind = {respbody.data.bzid,respbody.data.buid,respbody.data.bname,code}
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 领取绑定奖励
    function self.action_bdreward(request)
        local response = self.response
        local uid=request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if mUseractive.info[self.aname].u~=1 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if activeCfg.returnLevel>mUserinfo.level then
            response.ret = -102
            return response
        end

        if not next(mUseractive.info[self.aname].lsplayer.bind) then
            response.ret = -27021
            return response
        end

        if (mUseractive.info[self.aname].lsplayer.bd or 0)==1 then
            response.ret = -1976
            return response
        end

        if not takeReward(uid,activeCfg.serverreward.bindGift) then    
            response.ret=-403
            return response
        end
       
        mUseractive.info[self.aname].lsplayer.bd = 1
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(activeCfg.serverreward.bindGift)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

   
    return self
end

return api_active_gerrecall
