--
-- 禁言功能记录
-- User: luoning
-- Date: 14-10-30
-- Time: 下午4:19
--

function api_user_addblack(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local toBlackUid = request.params.uid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local allowLevel = mUserinfo.level

    local uobjs = getUserObjs(toBlackUid)
    uobjs.load({"userinfo", "blacklist"})
    local mUserinfo = uobjs.getModel('userinfo')
    local nickName = mUserinfo.nickname
    local mBlackList = uobjs.getModel('blacklist')
    local level = mUserinfo.level
    local diffConfig = mBlackList.getCustomCfg()

    if level > (allowLevel + diffConfig[3]) then
        return response
    end

    mBlackList.addBlackList(nickName)

    if uobjs.save() then
        response.msg = "Success"
        response.ret = 0
    end

    return response
end

