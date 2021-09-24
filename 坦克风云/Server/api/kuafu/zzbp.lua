-- 跨服战资比拼
-- chenyunhe
local function api_kuafu_zzbp(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    -- 获取活动配置数据 
    function self.action_getcfg(request)
        local response = self.response
        local uid =  request.uid
        if not uid then
            response.ret = -101
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"zzbpuser"})
        local mZzbpuser = uobjs.getModel('zzbpuser') 
        
        require "model.zzbp"
        local zzbp = model_zzbp()
        local  flag,cfg = zzbp.check()
    
        if not flag then
            response.ret = -1977
            return response
        end

        cfg.zones = json.decode(cfg.zones)
        cfg.task = json.decode(cfg.task)
       
        response.data.zzbp = cfg
        response.data.uinfo = mZzbpuser.toArray()
        response.data.uinfo.zscore = mZzbpuser.serverscore(cfg) -- 全服的总积分
        response.ret = 0
        response.msg = 'success'  

        return response
    end

    -- 获取个人积分排行榜
    function self.action_prank(request)
        local response = self.response
        local uid =  request.uid

        if not uid then
            response.ret = -102
            return response
        end

        require "model.zzbp"
        local zzbp = model_zzbp()
        local  flag,cfg = zzbp.check()
  
        if not flag then
            response.ret = -1977
            return response
        end

        response.data.ranklist = zzbppersonalrank(cfg) -- 个人
        response.data.fserver = getzzbpfirstserver(cfg)-- 积分第一服
        response.ret = 0
        response.msg = 'success'
       
        return response
    end

    -- 领取全服积分奖励
    function self.action_sreward(request)
        local response = self.response  
        local uid =  request.uid
        local itemid = tonumber(request.params.itemid) or 0 --领取的奖励下标
        local zid = getZoneId()
        local ts = getClientTs()

        if not uid or itemid <= 0 then
            response.ret = -102
            return response
        end

        require "model.zzbp"
        local zzbp = model_zzbp()
        local  flag,cfg = zzbp.check()

        if not flag then
            response.ret = -1977
            return response
        end
  
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","zzbpuser"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mZzbpuser = uobjs.getModel('zzbpuser') 

        local totalscore = mZzbpuser.serverscore(cfg) -- 获取当前服务器获得总积分
        if mZzbpuser.server[itemid]==1 then
            response.ret = -1976
            return response
        end

        local zzbpCfg = getConfig("zzbp")
        local curCfg = zzbpCfg[tonumber(cfg.cfgid)]
        
        -- 校验领取奖励编号
        local percent = tonumber(string.format("%0.2f",totalscore/cfg.sScore)) 
        local nums = #curCfg.serverScore  
     
        local gindex = 0
        for i=nums,1,-1 do
            if percent >= curCfg.serverScore[i] then
                gindex = i
                break
            end
        end

        if gindex<=0 or itemid > gindex then
            response.ret = -102
            return response
        end

        local reward = curCfg.sgift['sgift'..itemid]
        if type(reward)~='table'  then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mZzbpuser.server[itemid] = 1
        if uobjs.save() then
            response.data.reward = formatReward(reward)

            response.ret = 0
            response.msg = 'success'

        else
            response.ret = -106
        end

        return response
    end

    -- 领取个人积分奖励
    function self.action_preward(request)
        local response = self.response  
        local uid =  request.uid
        local itemid = tonumber(request.params.itemid) or 0 --领取的奖励下标
        local zid = getZoneId()
        local ts = getClientTs()

        if not uid then
            response.ret = -102
            return response
        end

        require "model.zzbp"
        local zzbp = model_zzbp()
        local  flag,cfg = zzbp.check()
  
        if not flag then
            response.ret = -1977
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","zzbpuser"})
        local mUserinfo = uobjs.getModel('userinfo') 
        local mZzbpuser = uobjs.getModel('zzbpuser')
       
        -- 更新领取记录
        if mZzbpuser.person[itemid]==1 then
            response.ret = -1976
            return response
        end


        local zzbpCfg = getConfig("zzbp")
        local curCfg = zzbpCfg[tonumber(cfg.cfgid)]
    
        -- 校验领取奖励编号
        local percent = tonumber(string.format("%0.2f",mZzbpuser.score/cfg.pScore)) 
        local nums = #curCfg.personalScore
     
        local gindex = 0
        for i=nums,1,-1 do
            if percent >= curCfg.personalScore[i] then
                gindex = i
                break
            end
        end


        if gindex<=0 or itemid > gindex then
            response.ret = -102
            return response
        end

        local reward = curCfg.pgift['pgift'..itemid]
        if type(reward)~='table'  then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mZzbpuser.person[itemid] = 1
        if uobjs.save() then
            response.data.reward = formatReward(reward)
            response.ret = 0
            response.msg = 'success'

        else
            response.ret = -106
        end

        return response

    end

    -- 领取排行榜奖励
    function self.action_rankreward(request)
        local response = self.response
        local otherid = tonumber(request.params.otherid) or 0 --转让的玩家id
        local uid =  request.uid
        local zid = getZoneId()
        local ts = getClientTs()

        if not uid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","zzbpuser"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mZzbpuser = uobjs.getModel('zzbpuser')

        -- 此处可能需要做等级限制 待定

        require "model.zzbp"
        local zzbp = model_zzbp()
        local  flag,cfg = zzbp.check()
  
        if not flag then
            response.ret = -1977
            return response
        end


        -- 检测是否可以领取奖励
        if not zzbp.checkreceive(cfg) then
            response.ret = -102
            return response
        end

        -- 已领取过个人积分奖励
        if mZzbpuser.rank>0 then
            response.ret = - 1976
            return response
        end

        local myrank = 0
        local rank = zzbppersonalrank(cfg)

        for k,v in pairs(rank) do
            if tonumber(v.zid) ==zid and uid == tonumber(v.uid) then
                myrank = k
                break
            end
        end


        if myrank==0 then
            response.ret = -102
            return response
        end

        local zzbpCfg = getConfig("zzbp")
        local curCfg = zzbpCfg[tonumber(cfg.cfgid)]
        local rankgid = 0
        for k,v in pairs(curCfg.section) do
            if myrank>=v[1] and myrank<=v[2] then
                rankgid = k
                break
            end
        end

        local rankRewardCfg = curCfg.rank['rank'..rankgid]
        if type(rankRewardCfg)~='table' or not next(rankRewardCfg) then
            response.ret = -102
            return response
        end

        if otherid>0 then
            -- 不能给自己转赠
            if uid == otherid then
                response.ret = -102
                return response
            end
            -- 当前玩家排名能否转赠
            if myrank > curCfg.givenLimit[2] or myrank < curCfg.givenLimit[1] then
                response.ret = -27005
                return response
            end 

            local touobjs = getUserObjs(otherid)
            touobjs.load({"userinfo","zzbpuser"})
            local tomZzbpuser = touobjs.getModel('zzbpuser')
            local tomUserinfo = touobjs.getModel('userinfo')
            
            -- 被转赠的人积分限制
            if tomZzbpuser.score < curCfg.givenScore then
                response.ret = -27004
                return response
            end

            -- 这个玩家已经被送过了
            if tomZzbpuser.receive>0 then
                response.ret = -27003
                return response
            end

            tomZzbpuser.receive = uid
            -- 给玩家发邮件
            local ret = MAIL:mailSent(otherid,0,otherid,tomUserinfo.nickname,'',1,'',1,0,9,rankRewardCfg)

            if not ret or not touobjs.save() then
               response.ret = -1
               return response
            end 

            mZzbpuser.senduid = otherid
        else
            if not takeReward(uid,rankRewardCfg.h) then
                response.ret = -403
                return response
            end
        end

        mZzbpuser.rank = myrank
        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
            if otherid==0 then
                response.data.reward = formatReward(rankRewardCfg.h)
            end
        else
            response.ret = -106
        end

        return response
    end

    -- 领取排名第一服务器奖励
    function self.action_firstserver(request)
        local response = self.response
        local uid =  request.uid
        local zid = getZoneId()
        local ts = getClientTs()

        if not uid then
         
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","zzbpuser"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mZzbpuser = uobjs.getModel('zzbpuser')

        require "model.zzbp"
        local zzbp = model_zzbp()
        local  flag,cfg = zzbp.check()
  
        if not flag then
            response.ret = -1977
            return response
        end

        -- 检测是否可以领取奖励
        if not zzbp.checkreceive(cfg) then
            response.ret = -102
            return response
        end

        local server = getzzbpfirstserver(cfg)
        local zzbpCfg = getConfig("zzbp")
        local curCfg = zzbpCfg[tonumber(cfg.cfgid)]

        -- 一分没获得的玩家不能领取奖励
        if mZzbpuser.score < curCfg.sGetLimit then
            response.ret = -102
            return response
        end

        -- 已领取过个人积分奖励
        if mZzbpuser.fserver == 1 then
            response.ret = - 1976
            return response
        end

        if server.zid ~= zid then
          
            response.ret = -102
            return response
        end

        local reward = curCfg.srank1
        if type(reward)~='table'  then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mZzbpuser.fserver = 1
        if uobjs.save() then
            --response.data.zzbpuser = mZzbpuser.toArray()
            response.data.reward = formatReward(reward)
            response.ret = 0
            response.msg = 'success'

        else
            response.ret = -106
        end

        return response
    end

    -- 获取可转赠奖励的玩家列表(军团、玩家好友)
    function self.action_sendlist(request)
        local response = self.response
        local uid =  request.uid
        local ts = getClientTs()
        local zid = getZoneId()

        if not uid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","zzbpuser"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mZzbpuser = uobjs.getModel('zzbpuser')

        require "model.zzbp"
        local zzbp = model_zzbp()
        local  flag,cfg = zzbp.check()
  
        if not flag then
            response.ret = -1977
            return response
        end

        -- 检测是否可以领取奖励
        if not zzbp.checkreceive(cfg) then
            response.ret = -102
            return response
        end
      
        -- 已领取过个人积分奖励
        if mZzbpuser.rank>0 then
            response.ret = - 1976
            return response
        end

        local zzbpCfg = getConfig("zzbp")
        local curCfg = zzbpCfg[tonumber(cfg.cfgid)]

        local myrank = 0
        local rank = zzbppersonalrank(cfg)

        for k,v in pairs(rank) do
            if tonumber(v.zid) ==zid and uid == tonumber(v.uid) then
                myrank = k
                break
            end
        end
     
        if myrank==0 then
            response.ret = -102
            return response
        end
    
        -- 当前玩家排名能否转赠
        if myrank > curCfg.givenLimit[2] or myrank < curCfg.givenLimit[1] then
            response.ret = -27005
            return response
        end 

        local memlist = {} -- 军团成员可赠送列表
        local frilist = {} -- 好友可赠送列表
        if mUserinfo.alliance > 0 then
            local mems = M_alliance.getMemberList{uid=uid,aid=mUserinfo.alliance}

            if mems then
                for _,v in pairs( mems.data.members) do
                    local mid = tonumber(v.uid)
                    local touobjs = getUserObjs(mid)
                    touobjs.load({"zzbpuser","userinfo"})
                    local tomUserinfo = touobjs.getModel('userinfo')
                    local tomZzbpuser = touobjs.getModel('zzbpuser')
                    -- 去掉自己  分数满足  没接收过
                    if mid ~= uid and (tonumber(tomZzbpuser.score) or 0)>= curCfg.givenScore and tomZzbpuser.receive== 0 then
                        table.insert(memlist,{uid=mid,nickname=v.name,lv=tomUserinfo.level,fc=tomUserinfo.fc})
                    end
                end
            end
        end

        local mFriends = uobjs.getModel('friends')
        if next(mFriends.info) then
            local db = getDbo()
            local str=table.concat( mFriends.info, ",")
            local result =db:getAllRows("SELECT uid,nickname,fc,level FROM userinfo WHERE uid in ("..str..")")
           
            for k,v in pairs(result) do
                local fid = tonumber(v.uid)
                local fouobjs = getUserObjs(fid)
                fouobjs.load({"zzbpuser","userinfo"})
                 local fmUserinfo = fouobjs.getModel('userinfo')
                local fmZzbpuser = fouobjs.getModel('zzbpuser')
                -- 分数满足 没接收过
                if (tonumber(fmZzbpuser.score) or 0)>= curCfg.givenScore and fmZzbpuser.receive== 0 then
                    table.insert(frilist,{uid=fid,nickname=v.nickname,lv=fmUserinfo.level,fc=fmUserinfo.fc})
                end
            end
        end
       
        response.data.mlist = memlist
        response.data.flist = frilist
        response.ret = 0
        response.msg = 'success'
          
        return response
    end

    return self
end

return api_kuafu_zzbp
