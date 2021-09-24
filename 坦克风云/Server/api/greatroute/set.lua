local function api_greatroute_set(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"}
            },

            ["action_shop"] = {
                item = {"required","string"},
                num = {"required","number"},
                cost = {"required","number"},
            },

            ["action_buyAcPoint"] = {
                cost = {"required","number"},
            },
        }
    end

    function self.before(request) 
        local response = self.response
        local matchInfo,code = loadFuncModel("serverbattle").getGreatRouteInfo()
        if not next(matchInfo) then
            response.ret = -180
            return response
        end
    end

    --[[
        伟大航线报名
    ]]
    function self.action_apply(request)
        local response = self.response
        local uid = request.uid
        local aid = getUserObjs(uid,true).getModel("userinfo").alliance

        if aid <= 0 then
            response.ret = -102
            return response
        end

        local matchInfo,code = loadFuncModel("serverbattle").getGreatRouteInfo()
        if not next(matchInfo) then
            response.ret = -180
            return response
        end

        local mAGreatRoute = getModelObjs("agreatroute",aid)

        -- 非报名期
        if not mAGreatRoute.isApplyStage(matchInfo.st) then
            response.ret = -8493
            return response
        end

        -- 已报名
        if mAGreatRoute.checkApplyOfWar() then
            response.ret = -8480
            return response
        end

        local ainfo,code = M_alliance.getalliance{alliancebattle=1,method=1,aid=aid,uid=uid}
        if not ainfo then
            response.ret = code
            return response
        end

        -- 不是军团长
        if tonumber(ainfo.data.myrole) < 1 then
            response.ret = -8482
            return response
        end

        local greatRouteCfg = getConfig("greatRoute")

        -- 军团等级太低，无法报名
        if tonumber(ainfo.data.level) < greatRouteCfg.main.allianceLevel then
            response.ret = -8481
            return response
        end

        --消耗军团资金
        local execRet,code = M_alliance.costacpoint{
            uid=uid,
            aid=aid,
            costpoint=greatRouteCfg.main.wealthCost
        }

        if not execRet then
            response.ret = -8042
            response.err = "costacpoint failed"
            return response
        end

        if not mAGreatRoute.applyForWar(matchInfo.bid,matchInfo.st,ainfo.data) then
            response.ret = -8488
            return response
        end

        if mAGreatRoute.save() then
            -- 军团报名成功给全团成员邮件通知
            mAGreatRoute.mailNotify(86, ainfo.data.members)

            response.ret = 0
            response.msg = "Success"
        end
        
        return response 
    end

    --[[
        设置参战部队
    ]]
    function self.action_troops( request )
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local aid = uobjs.getModel("userinfo").alliance
        local mAGreatRoute = getModelObjs("agreatroute",aid,true)

        -- 未报名，无法设置部队
        if not mAGreatRoute.checkApplyOfWar() then
            response.ret = -8483
            return response
        end

        local hero  =request.params.hero or {}
        local equip = request.params.equip
        local plane = request.params.plane
        local fleetInfo = request.params.fleetinfo
        
        local mTroop = uobjs.getModel('troops') 

        -- 兵力检测
        if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
            response.ret = -5006
            return response
        end

         -- check new heroes
        if type(hero)=='table' and next(hero) then
            if not uobjs.getModel('hero').checkFleetHeroStats(hero) then
                response.ret=-11016 
                return response
            end
        end

        -- 这儿给个默认值战报里占位(后面部队如果不带军徽客户端会不传,后端更新时要去掉上一次设置的)
        equip = equip or 0
        if equip ~= 0 then
            -- 军徽(超级装备)检测
            local mSequip = uobjs.getModel('sequip')
            if equip and not mSequip.checkFleetEquipStats(equip) then
                response.ret=-8650 
                return response        
            end

            equip=mSequip.formEquip(equip)
        end

        -- 飞机给个默认值占位
        plane = plane or 0
        
        -- 战斗用数据
        local binfo = mTroop.initFleetAttribute(fleetInfo, 0, {hero=hero,equip=equip,plane=plane})

        -- 给客户端展示用
        local fleet = {
            troops = fleetInfo,
            hero=hero,
            heroList=request.params.heroList,
            equip=equip,
            plane=plane,
        }

        local mTGreatRoute = getModelObjs("tgreatroute",uid,true)
        local ret, code = mTGreatRoute.setTroops(mAGreatRoute.bid,fleet,binfo)
        if not ret then
            response.ret = code
            return response
        end

        if mTGreatRoute.save() then
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 购买行动点数
    function self.action_buyAcPoint(request)
        local response = self.response
        local uid = request.uid
        local cliCost = request.params.cost
        local cliCost = request.params.cost

        local uobjs = getUserObjs(uid)
        local mUGreatRoute = uobjs.getModel("ugreatroute")

        local gemCost, point = mUGreatRoute.getAPointSellInfo()

        -- 与客户端所需的消耗不符
        if gemCost ~= cliCost then
            response.err = {serverCost=gemCost}
            response.ret = -102
            return response
        end

        if gemCost > 0 then
            local mUserinfo = uobjs.getModel('userinfo')
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end

            -- actionlog 伟大航线-购买行动点数
            regActionLogs(uid,1,{action=273,item="",value=gemCost,params={}})

            mUGreatRoute.buyAcPoint(point)

            if uobjs.save() then
                response.data.greatRoute = {
                    ugreatroute = mUGreatRoute.toArray(true),
                }
                response.ret = 0
                response.msg = 'Success'
            end
        end

        return response
    end

    --[[
        获取自己的军团名次
        消耗自己的军团积分
    ]]
    function self.action_shop(request)
        local response = self.response
        local uid = request.uid
        local item = request.params.item
        local num = math.floor(request.params.num)
        local cliCost = request.params.cost

        local uobjs = getUserObjs(uid)
        local aid = uobjs.getModel("userinfo").alliance
        local mUGreatRoute = uobjs.getModel("ugreatroute")
        local mAGreatRoute = getModelObjs("agreatroute",aid,true)

        -- 没有报名无法操作
        if not mAGreatRoute.checkApplyOfWar() then
            response.ret = -8480
            return response
        end

        -- 不是领奖期，不能购买
        if not mAGreatRoute.isRewardStage() then
            response.ret = -8492
            return response
        end

        local shopCfg = getConfig("greatRoute").shopList
        if num < 1 or not shopCfg[item] then
            response.ret = -102
            return response
        end

        -- 不能批量购买
        if num > 1 and shopCfg[item].bulkbuy == 0 then
            response.ret = -102
            return response
        end

        -- 排行要求
        if shopCfg[item].rankNeed > 0 then
            if mAGreatRoute.ranking <= 0 then
                response.ret = -8491
                return response
            end

            if shopCfg[item].rankNeed < mAGreatRoute.ranking then
                response.ret = -8491
                return response
            end
        end

        -- 限购
        if shopCfg[item].limit > 0 then
            -- 达到购买上限
            if mUGreatRoute.setShop(item,num) > shopCfg[item].limit then
                response.ret = -1987
                return response
            end
        end

        local scoreCost = math.ceil(shopCfg[item].scoreCost * num)
        if scoreCost < shopCfg[item].scoreCost then
            return response
        end

        -- 与客户端所需的消耗不符
        if scoreCost ~= cliCost then
            response.err = {serverCost=scoreCost}
            response.ret = -102
            return response
        end

        -- 积分不足，无法购买商品
        if not mUGreatRoute.reduceScore(scoreCost) then
            response.ret = -8490
            return response
        end

        -- 物品添加失败
        if not takeReward(uid,shopCfg[item].get) then
            response.ret = -403
            return response
        end

        if uobjs.save() then
            response.data.greatRoute = {
                ugreatroute = mUGreatRoute.toArray(true),
            }

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    return self
end

return api_greatroute_set