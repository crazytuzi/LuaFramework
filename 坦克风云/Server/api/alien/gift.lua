--
-- 异星科技 礼物赠送和接收
-- User: luoning
-- Date: 15-2-7
-- Time: 下午2:38
--
function api_alien_gift(request)

    local response = {
        ret=-1,
        msg='Success',
        data = {},
    }

    local uid = request.uid
    local action = request.params.action
    local uids = request.params.uids

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"alliancememgift","userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mMemgift = uobjs.getModel('alliancememgift')
    local mFriends = uobjs.getModel('friends')
    mMemgift.refresh()
    if type(uids) ~= "table" then
        uids = {}
    end

    if action == "give" then

        if not next(uids) then
            response.ret = -1981
            return response
        end
        local allianceMemList
        if mUserinfo.alliance ~= 0 then
            allianceMemList = M_alliance.getMemberList{uid=uid,aid=mUserinfo.alliance }
        end
        local allanceMembers
        if type(allianceMemList) == "table"
                and allianceMemList.ret == 0
                and type(allianceMemList.data) == "table"
                and type(allianceMemList.data.members) == "table"
                and next(allianceMemList.data.members)
        then
            allanceMembers = allianceMemList.data.members
        end

        local memsUid = {}
        --好友可以赠送
        if type( mFriends.info ) == 'table' and next(mFriends.info) then
            for _, v in pairs( mFriends.info ) do
                table.insert(memsUid, tonumber(v) )
            end
        end

        if type(allanceMembers) == 'table' and next(allanceMembers) then 
            for _,v in pairs(allanceMembers) do
                table.insert(memsUid, tonumber(v.uid))
            end
        end

        local uidCount = 0
        for i,v in pairs(uids) do
            v = tonumber(v)
            uids[i] = v
            if not table.contains(memsUid, v) or v == tonumber(uid) then
                response.ret = -1981
                return response
            end
            
            uidCount = uidCount + 1
        end

        if not mMemgift.canGiveGift(uids) then
            response.ret = -1981
            return response
        end

        mMemgift.giveGift(uids)
        -- 春节攀升
        activity_setopt(uid, 'chunjiepansheng', {action='rg', num=uidCount})
        -- 国庆七天乐
        activity_setopt(uid,'nationalday2018',{act='tk',type='rg',num=uidCount})  

    elseif action == "receive" then

        local giftUids = mMemgift.getGiftList()
        local activeCfg = getConfig("alienTechCfg")
        if not next(uids) then
            response.ret = -1981
            return response
        end

        for i,v in pairs(uids) do
            uids[i] = tonumber(v)
        end

        if not mMemgift.canGetGift(uids, giftUids, activeCfg.rewardlimit) then
            response.ret = -1981
            return response
        end

        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            if tmpData[1] == "alien" then tmpPrefix = "r" end
            return tmpPrefix, tmpType
        end

        setRandSeed()
        local tmpreward = {}
        local clientReward = {}
        for _,receiveUid in pairs(uids) do
            local reward = getRewardByPool(activeCfg.rewardPool)
            local tmpClientReward = {}
            for mtype,mNum in pairs(reward) do
                --客户端奖励
                local tmpPrefix, tmpType = serverToClient(mtype)
                if not tmpClientReward[tmpPrefix] then
                    tmpClientReward[tmpPrefix] = {}
                end
                if tmpClientReward[tmpPrefix][tmpType] then
                    tmpClientReward[tmpPrefix][tmpType] = tmpClientReward[tmpPrefix][tmpType] + mNum
                else
                    tmpClientReward[tmpPrefix][tmpType] = mNum
                end
                --服务器端奖励
                if tmpreward[mtype] then
                    tmpreward[mtype] = tmpreward[mtype] + mNum
                else
                    tmpreward[mtype] = mNum
                end
            end
            table.insert(clientReward, {receiveUid, tmpClientReward})
        end

        if not takeReward(uid, tmpreward) then
            return response
        end

        mMemgift.recordGift(uids)
        if #mMemgift.receive > activeCfg.rewardlimit then
            response.ret = -1981
            return response
        end

        response.data.giftreward = clientReward
    end

    response.data.friendgift={
        give=mMemgift.give,
        giftlist=mMemgift.getGiftList(),
        receive=mMemgift.receive,
        refreshtime=mMemgift.reftime
    }

    if uobjs.save() then
        response.msg = "Success"
        response.ret = 0
    end

    return response
end
