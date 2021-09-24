-- 异星科技 商店购买 
function api_alien_buyshop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    
    if uid == nil then
        response.ret=-102
        return response
    end
    
    if moduleIsEnabled('alienshop') == 0 then
        response.ret = -16000
        return response
    end

    local alienShopCfg = getConfig("alienShopCfg")

    local uobjs = getUserObjs(uid)
    uobjs.load({"alien","userinfo","bag","troops"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAlien= uobjs.getModel('alien')

    local self = {}
    -- 购买刷新
    function self.buyRef()
        local weeTs = getWeeTs()
        if not mAlien.shop.cntTs or not mAlien.shop.buycnt or mAlien.shop.cntTs < weeTs then
            mAlien.shop.cntTs = weeTs
            mAlien.shop.buycnt = 0
        end

        --购买次数不够
        if mAlien.shop.buycnt > alienShopCfg.refreshCount4Vip[mUserinfo.vip + 1] then
            response.ret = -403
            return false, response
        end

        -- 扣钻
        local useGems = nil
        if mAlien.shop.buycnt >= #alienShopCfg.refresh then
            useGems = alienShopCfg.refresh[#alienShopCfg.refresh]
        else
            useGems = alienShopCfg.refresh[mAlien.shop.buycnt + 1]
        end
        if not mUserinfo.useGem(useGems) then
            response.ret = -109         
            return false, response
        end

        --累计
        mAlien.shop.buycnt = mAlien.shop.buycnt + 1

        -- 刷新
        if not mAlien.refreshAlienShop() then
            response.ret = -405
            return false, response
        end
        -- 陨石冶炼
        activity_setopt(uid, 'yunshiyelian', {action='ra'})

        -- 异星商店刷新
        regActionLogs(uid,1,{action=134,item="",value=useGems,params={}})
        return true
    end

    --购买道具
    function self.buyItem(idx, r)
        -- 已经购买了
        if not mAlien.shop.list[idx] or mAlien.shop.list[idx].s ~= 0 then
            response.ret = -406
            response.msg = 'had buy'
            return false, response
        end
        if mAlien.shop.list[idx].r ~= r then
            response.ret = -8201
            return false, response
        end

        local shelf = alienShopCfg.allShelfs[idx] --位置转换为格子
        local itemCfg = alienShopCfg.reward[ mAlien.shop.ver ][shelf]
        local slot = mAlien.shop.list[idx].r --奖励位置

        -- 扣资源
        local useGems = nil
        if itemCfg.priceType == 'gems' then --钻石单独扣
            useGems = itemCfg.price[slot]
            if not mUserinfo.useGem(useGems) then
                response.ret = -109         
                return false, response
            end
        else
            local r = { [itemCfg.priceType] = itemCfg.price[slot] } -- [币种]=价格
            if not mAlien.useProps(r) then
                response.ret= -107
                return false, response
            end           
        end 

        --[奖励key]=奖励数量
        local reward = {[itemCfg.pool[3][slot][1]] = itemCfg.pool[3][slot][2] * mAlien.shop.list[idx].rate}
        if not takeReward(uid, reward) then        
            response.ret = -403 
            return false, response
        end

        mAlien.shop.list[idx].s = 1

        if useGems then
            -- 异星商店购买道具
            regActionLogs(uid,1,{action=135,item="",value=useGems,params={reward=reward}})
        end
        
        -- 春节攀升
        activity_setopt(uid, 'chunjiepansheng', {action='rs'})
        -- 陨石冶炼
        activity_setopt(uid, 'yunshiyelian', {action='rs'})
        -- 悬赏任务
        activity_setopt(uid,'xuanshangtask',{t='',e='rs',n=1})
        -- 点亮铁塔
        activity_setopt(uid,'lighttower',{act='rs',num=1})            
        -- 愚人节大作战-异星商店中购买X件货物
        activity_setopt(uid,'foolday2018',{act='task',tp='rs',num=1},true)  
        -- 节日花朵
        activity_setopt(uid,'jrhd',{act="tk",id="rs",num=1})     
       
        -- 感恩节拼图     
        activity_setopt(uid,'gejpt',{act='tk',type='rs',num=1})      

        return true, reward
    end

    -- 商店数据刷新
    function self.refresh()
        -- 检测商店物品刷新
        mAlien.checkShopRef()

        -- 检测刷新商店次数
        if not mAlien.shop.cntTs or not mAlien.shop.buycnt or mAlien.shop.cntTs < getWeeTs() then
            mAlien.shop.cntTs = getWeeTs()
            mAlien.shop.buycnt = 0
        end

        return true
    end
    -----------------------------------------------

    local action = request.params.action
    local index = request.params.index
    local r = request.params.reward
    local ret, code = nil, nil
    if action == 1 then -- 定时刷新
        ret = self.refresh()
    elseif action == 2 then -- 购买刷新
        ret, code = self.buyRef()
    elseif action == 3 then -- 购买道具
        ret, code = self.buyItem(index, r)
        --日常任务
        local mDailyTask = uobjs.getModel('dailytask')
        mDailyTask.changeTaskNum1('s1017')
    end

    if not ret then
        return code
    end

    if uobjs.save() then 
        if action == 3 then
            response.data.reward = formatReward(code)
            response.data.userinfo = mUserinfo.toArray(true)
        end
        response.data.alien = {prop=mAlien.prop, shop=mAlien.shop, pinfo=mAlien.pinfo }
        response.ret = 0        
        response.msg = 'Success'
        processEventsAfterSave()
    end
    
    return response

end
