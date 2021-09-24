function api_notice_reward(request)
     local response = {
            ret=-1,
            msg='error',
            data = {noticereward={}},
        }

    local uid = request.uid
    local nid = tonumber(request.params.nid)
    
     if uid == nil or nid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local sysNotice = require "model.notice"

    if not mUserinfo.flags.cmp then
        mUserinfo.flags.cmp = {}
    end

    if type(mUserinfo.flags.cmp) == 'table' and #mUserinfo.flags.cmp > 0 then
        
        if table.contains(mUserinfo.flags.cmp,nid) then
            response.ret = -1976
            return response
        end

        local disNotices = sysNotice:getUserDisabledNotices(mUserinfo.flags.cmp)
        if type(disNotices) == 'table' then
            for k,v in ipairs(mUserinfo.flags.cmp) do                
                if disNotices[tostring(v)] == 1 then
                    table.remove(mUserinfo.flags.cmp,k)
                end
            end
        end
    end

    local noticeInfo = sysNotice:compensationNotice(nid)

    if not noticeInfo then
        response.ret = -2011
        return response
    end

    if noticeInfo.nid~='' and noticeInfo.nid~=nil then
        if table.contains(mUserinfo.flags.cmp,noticeInfo.nid) then
            response.ret = -1976
            return response
        end
        table.insert(mUserinfo.flags.cmp,noticeInfo.nid)
    else
        table.insert(mUserinfo.flags.cmp,nid)
    end  
    --奖励50金币
    local ret,reward 
    if tonumber(noticeInfo.gift) == 1 then
        reward = {u={gems=50}}        
        ret = takeReward(uid,{userinfo_gems=50})
    end
    --奖励道具
    if tonumber(noticeInfo.gift) == 2 then

       
        local item=json.decode(noticeInfo.item)
        --ptb:p(item)
        if type(item)=='table' and next(item) then
            ret = takeReward(uid,item)
            reward = formatReward(item) 
        end

    end

    if ret and uobjs.save() then
        response.data.noticereward.reward = reward
        response.ret = 0        
        response.msg = 'Success'
    end

    return response
end
