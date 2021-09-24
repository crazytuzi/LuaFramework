-- 获取装备的信息

function api_equip_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid 
    local pid = request.params.pid
    local hc = request.params.hc
    
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('he') == 0 then
        response.ret = -18000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'equip',"hero","userarena","userexpedition","hchallenge"})
    local mEquip = uobjs.getModel('equip')
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserarena = uobjs.getModel('userarena')
    local mUserExpedition = uobjs.getModel('userexpedition')
    local hchallenge = uobjs.getModel('hchallenge')
    if mUserinfo.level<moduleIsEnabled('hel') then
        response.ret = -18000
        return response
    end
    
    if hc and hc == 1 then
        response.data.hchallenge = hchallenge.getChallengeAllData()
        response.data.hchallenge.reward = hchallenge.reward
    end
    response.data.equip = mEquip.toArray(true)
    response.data.equip.ap = mUserarena.point
    response.data.equip.ep = mUserExpedition.point
    response.ret = 0        
    response.msg = 'Success'
    return response
end