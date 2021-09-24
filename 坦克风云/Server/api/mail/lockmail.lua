-- 邮件解锁
function api_mail_lockmail(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if moduleIsEnabled('lockEmail') == 0 then
        response.ret = -9000
        return response
    end

    local uid = request.uid
    local messageid = request.params.eid
    local mlock = tonumber(request.params.mlock) or 0

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local playerCfg = getConfig('player')

    -- vip特权次数已满
    if not tonumber( mUserinfo.flags.lmail ) then
        mUserinfo.flags.lmail = 0
    end
    local mlockcfg = tonumber(playerCfg.vipRelatedCfg.lockmailNum[mUserinfo.vip+1]) or 0
    if mlock==1 and tonumber(mUserinfo.flags.lmail) >= mlockcfg then
        response.ret = -18011
        return response
    end  

    local msg = MAIL:mailLock(uid, messageid, mlock)
    if type(msg) ~= 'table' then
        return response
    end
    -- 更新锁定邮件数
    local lmailcount = MAIL:lockmailCount(uid)
    if not tonumber( lmailcount ) then
        response.ret = -18012
        return response
    end
    mUserinfo.flags.lmail = lmailcount

    if uobjs.save() then
        --response.data.userinfo=mUserinfo.toArray(true)
        --response.data.mail=msg
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'save fail'
    end

    return response
end
