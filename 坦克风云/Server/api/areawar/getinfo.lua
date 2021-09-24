-- 获取设置部队信息

function api_areawar_getinfo(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local uid   = tonumber(request.uid)
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops","userareawar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops') 
    local mUserareawar=uobjs.getModel('userareawar') 
    local redis = getRedis()

    local EndAt=getAreaApplyEndAt()
    local bid =getAreaWarId(EndAt)
    if tostring(mUserareawar.bid)~=tostring(bid) or mUserareawar.aid~=mUserinfo.alliance then
        mUserareawar.reset()
        mUserareawar.bid=bid
        mUserareawar.aid=mUserinfo.alliance
    end
    local key="areawar.UsersTask."..bid
    local ret=json.decode(redis:hget(key,uid))
    response.data.swtask = mUserareawar.task
    if type(ret) == 'table' then
       response.data.swtask = ret
    end
    response.data.troops = mUserareawar.info.troops
    response.data.hero = mUserareawar.info.hero
    response.data.equip = mUserareawar.info.equip
    response.data.plane = mUserareawar.info.plane 
    return response
end