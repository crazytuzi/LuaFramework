-- 购买体力值

function api_alliancerebel_buyenergy(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            userarena={},
        },
    }

    -- 军团叛军没有开启
    if moduleIsEnabled('acerebel')  == 0 then
        response.ret = -17000
        return response
    end

    local uid = request.uid
    local num = tonumber(request.params.num) or 1
    local uobjs = getUserObjs(uid)
    local cost =tonumber(request.params.cost) or 1
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","hero","userforces","userexpedition"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserforces = uobjs.getModel('userforces')
    local weets = getWeeTs()
    if mUserinfo.alliance<=0 then
        response.ret=-102
        return response
    end
    if mUserforces.buyts<=weets then
        mUserforces.energybuy=0
    end
    local rebelCfg = getConfig('rebelCfg')
    local buynum=rebelCfg.vipBuyLimit[mUserinfo.vip+1]
    local maxenergy=rebelCfg.energyMax
    local energy=num
    local gems=0
    for i=1,num do
        gems=gems+(rebelCfg.needMoney[mUserforces.energybuy+i] or rebelCfg.needMoney[#rebelCfg.needMoney])
    end
    if cost~=gems then
        response.ret=-102
        return response
    end
    -- 攻击的时候设置一下军团发现 ts ＝叛军过期时间 id 地图id aid=军团id
    --aid,mid,exts,lvl,name,reward,alliancename,uid
    --M_alliance.killforces(mUserinfo.alliance,1,11111,1,mUserinfo.nickname,{props_p12=1,props_p13=21},mUserinfo.alliancename,uid)
    --  超过购买次数不能购买
    if mUserforces.energybuy+num>buynum and buynum>0 then
        response.ret=-24001
        return response
    end
    -- 最大不能购买
    if mUserforces.getEnergy()>=maxenergy then
        response.ret=-24002
        return response
    end
    if  not mUserinfo.useGem(gems) then
        response.ret = -109
        return response
    end
    mUserforces.buyEnergy(energy,maxenergy)
    regActionLogs(uid,1,{action=132,item="",value=gems,params={}})

    if uobjs.save() then        
        processEventsAfterSave()
        response.data.userforces = mUserforces.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response





end