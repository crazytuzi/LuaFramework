-- 商店购买


function api_areateamwar_buy(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local tId = request.params.tId
    if uid == nil then
        response.ret = -102
        return response
    end
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --跨平台大战基本信息
    local mMatchinfo=mServerbattle.getserverareabattlecfg()
    if not next(mMatchinfo)  then
        return response
    end



    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","areacrossinfo","userexpedition"})
    local mTroop = uobjs.getModel('troops')
    local mAreacrossinfo = uobjs.getModel('areacrossinfo')

    local sCfg
    -- hwm 开红色配件后，商店配置切换为版本2
    if switchIsEnabled("ra") then
        sCfg = getConfig('serverWarLocalCfg.ShopItems2')
    else
        sCfg = getConfig('serverAreaWarCfg.ShopItems')
    end

    local shopItem = sCfg[tId]
    local limitNum = shopItem.buynum
    local reward = shopItem.serverReward
    local cost = shopItem.price

    
   
    
    --验证积分是否够用
    local matchId=mMatchinfo.bid
    local ret,errorCode=mAreacrossinfo.usePoint(matchId, cost, tId, limitNum, type, 50) 
    if not ret then
        response.ret = errorCode
        return response
    end
    if not takeReward(uid,reward) then        
        response.ret = -403 
        return response
    end
    
    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    return response


    

end