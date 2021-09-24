local function api_killrace_killrace(request)
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

            ["action_buy"] = {
                item = {"required","string"},
                grade = {"required","number"},
            },

            ["action_gradeReward"] = {
                grade = {"required","number"},
            },

        }
    end

    function self.before(request) 
        -- 开关未开启
        if not switchIsEnabled('kRace') then
            self.response.ret = -102
            return self.response
        end

        -- 检测击杀赛是否开启
        local libKillRace = loadModel("lib.killrace")
        if not libKillRace.isOpen() then
            self.response.ret = -2105
            return self.response
        end

        self.libKillRace = libKillRace
    end

    --[[
        获取用户击杀赛的基础数据，并赠送每日部队,返给客户端做弹板显示
    ]]
    function self.action_get(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel('userkillrace')
        local libKillRace = loadModel("lib.killrace")

        if mKillrace.season > 0 and mKillrace.season ~= libKillRace.season then
            response.ret = -2103
            return response
        end

        -- 如果没有报名,直接返回空数据,前端以空数据来判断是否需要报名
        if not mKillrace.isApply() then
            response.ret = 0
            response.msg = 'Success'
            return response
        end

        local saveFlag = false
        if request.params.uname and mKillrace.nickname ~= request.params.uname then
            mKillrace.nickname = request.params.uname
            saveFlag = true
        end

        -- 如果未赠送部队,按当前段位赠送部队
        if mKillrace.day_troops_give == 0 and libKillRace.isBattle() then
            local troops = libKillRace.troopsGive(mKillrace.grade,mKillrace.queue)
             -- 添加部队
            mKillrace.troopsAdd(troops)
            -- 设置赠送标识
            mKillrace.day_troops_give = mKillrace.day_troops_give + 1
            
            saveFlag = true
            response.data.gives = troops
        else
            response.ret = 0
            response.msg = 'Success'
        end

        if saveFlag and uobjs.save() then
            if response.data.gives then
                -- 兑兵日志(系统赠送)
                libKillRace.addChangeLog(uid,1,response.data.gives)
            end

            response.ret = 0
            response.msg = 'Success'
        end

        if response.ret == 0 then
            local killRaceCfg = getConfig("killRaceCfg")
            response.data.userkillrace = mKillrace.toArray(true)
            response.data.userkillrace.grade_reward_flags = mKillrace.parseFlags(mKillrace.grade_reward_flags,mKillrace.max_grade)
            response.data.userkillrace.day_reward_flags = mKillrace.parseFlags(mKillrace.day_reward_flags,#killRaceCfg.dailyTask)
        end

        return response
    end

    --[[
        报名,并设置用户昵称
    ]]
    function self.action_apply(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel('userkillrace')
        local mUserinfo = uobjs.getModel('userinfo')

        if mKillrace.season > 0 and mKillrace.season ~= self.libKillRace.season then
            response.ret = -2103
            return response
        end

        if not mKillrace.isApply() and mKillrace.score > 0 then
            mKillrace.inherit()
        end

        -- 设置用户昵称(冗余),方便后面的排行榜展示用
        mKillrace.setNickname(mUserinfo.nickname)
        mKillrace.apply(self.libKillRace.season)

        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        匹配对手
    ]]
    function self.action_match(request)
        local response = self.response
        local uid = request.uid

        -- 客户端传过来的消费金币数
        local cost = request.params.cost or 0

        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel('userkillrace')

        -- match_info为空的情况(首次匹配/掉段/战斗胜利)无需消费
        if cost > 0 and not next(mKillrace.match_info) then
            response.ret = -102
            response.match_info = mKillrace.match_info
            return response
        end

        -- 战斗期才能战斗
        local libKillRace = loadModel("lib.killrace")
        if not libKillRace.isBattle() then
            response.ret = -2108
            return response
        end
        -- match_info不为空时,为更换匹配对手,需要收费
        -- 匹配有固定免费次数,超过之后按首次收费+首次后每次所需费用叠加得到本次所需的总费用
        if next(mKillrace.match_info) then
            local killRaceCfg = getConfig("killRaceCfg")            
            local gemCost = 0
            if mKillrace.day_match_num >= killRaceCfg.matchRule[2] then
                local n = mKillrace.day_match_num - killRaceCfg.matchRule[2]
                gemCost = killRaceCfg.matchRule[3] + killRaceCfg.matchRule[4] * n
                if gemCost > killRaceCfg.matchRule[5] then
                    gemCost = killRaceCfg.matchRule[5]
                end
            end

            -- 验证前后端消耗的金币数是否一致
            if gemCost ~= cost then
                response.ret = -102
                response.gemCost = gemCost
                return response
            end

            if gemCost > 0 then
                local mUserinfo = uobjs.getModel('userinfo')
                if not mUserinfo.useGem(gemCost) then
                    response.ret = -109
                    return response
                end

                -- actionlog 使用金币匹配镜像
                regActionLogs(uid,1,{action=166,item="",value=gemCost,params={curMatchNum=mKillrace.day_match_num}})
            end
        end

        -- 获取镜像及天气，地形
        local imageInfo = libKillRace.match(uid,mKillrace.grade)
        local weather,ocean = libKillRace.getWeatherAndOcean(mKillrace.match_weather,mKillrace.match_ocean)

        -- 没有目标异常
        if not imageInfo then
            response.ret = -2103
            response.imageInfo = "nil"
            return response
        end

        mKillrace.match(imageInfo,weather,ocean)

        if uobjs.save() then
            response.data.userkillrace = {
                match_info = mKillrace.match_info,
                match_grade = mKillrace.match_grade,
                match_ocean = mKillrace.match_ocean,
                match_weather = mKillrace.match_weather,
                day_match_num = mKillrace.day_match_num,
            }
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        部队兑换
        每次只能兑换每组可使用的固定数量的船
    ]]
    function self.action_exchange(request)
        local response = self.response
        local uid = request.uid
        local list = request.params.list

        if #list < 1 then return response  end 

        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel("userkillrace")
        local mTroop = uobjs.getModel('troops')

        -- 战斗期才能战斗
        local libKillRace = loadModel("lib.killrace")
        if not libKillRace.isBattle() then
            response.ret = -2108
            return response
        end
        local consume = libKillRace.getChangeConsum(mKillrace.day_change)
        
        local killRaceCfg = getConfig("killRaceCfg")
        local killRaceVerCfg = libKillRace.getRaceVerCfg()
        local boatLimit = killRaceVerCfg.groupMsg[mKillrace.grade][mKillrace.queue].boatLimit
        local tankCfg = getConfig("tank")

        local changeLog = {}
        local totalConsume = 0
        for _,info in pairs(list) do
            local v = info[1]
            local clientConsume = info[2]

            if clientConsume ~= consume then
                response.ret = -102
                response.consume = {clientConsume,consume}
                return response
            end

            -- 兑换的部队超过自己段位可用部队的上限
            if tankCfg[v].level > boatLimit[2] then
                response.err = {boatLimit[2],tankCfg[v].level,mKillrace.grade,mKillrace.queue,v}
                response.ret = -2104
                return response
            end

            -- 待消耗的部队不够
            if not mTroop.consumeTanks(v,consume) then
                response.ret = -5006
                return response
            end

            -- 每次兑换出的部队的数量是固定的
            mKillrace.troopAdd(v,killRaceCfg.troopsNum)
            -- 增加兑换次数
            mKillrace.day_change = mKillrace.day_change + 1
            mKillrace.total_change = mKillrace.total_change + 1
            table.insert(changeLog,{v,consume,killRaceCfg.troopsNum})
            totalConsume = totalConsume + consume

            -- 重新计算消耗
            consume = libKillRace.getChangeConsum(mKillrace.day_change)
        end

        -- 消耗日志
        regKfkLogs(uid,'tankChange',{
                addition={
                    {desc="技巧战兑换",value=list},
                    {desc="消耗",value=totalConsume}
                }
            }
        )

        -- 战力可能会变化
        processEventsBeforeSave()

        if uobjs.save() then
            processEventsAfterSave()

            -- 增加兑换日志
            libKillRace.addChangeLog(uid,0,changeLog)

            response.data.userkillrace = {
                troops = mKillrace.troops,
                day_change = mKillrace.day_change,
            }

            response.data.troops = mTroop.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        领取每日任务奖励,领奖标识每日凌晨重置
    ]]
    function self.action_dailyReward(request)
        local response = self.response
        local uid = request.uid
        local item = tonumber(request.params.item)

        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel("userkillrace")

        -- 段位变化不能影响到任务,所以配置按当天重置时的段位来算
        local killRaceCfg = getConfig("killRaceCfg")
        local dailyTaskCfg = killRaceCfg.dailyTask[mKillrace.day_grade][item]

        -- item invalid
        if not dailyTaskCfg then
            response.ret = -102
            response.dailyTaskCfg = dailyTaskCfg
            return response
        end

        -- 任务未完成
        if not mKillrace.taskIsCompleted(item,dailyTaskCfg[1]) then
            response.ret = -1981
            return response
        end

        -- 奖励已领取
        if mKillrace.getDayRewardFlag(item) then
            response.ret = -1976
            return response
        end

        -- 设置领奖标识
        mKillrace.setDayRewardFlag(item)

        -- 奖励只有K币
        mKillrace.addKCoin(dailyTaskCfg[2])

        if uobjs.save() then
            response.data.userkillrace = {
                kcoin = mKillrace.kcoin,
                day_reward_flags = mKillrace.parseFlags(mKillrace.day_reward_flags,#killRaceCfg.dailyTask),
            }

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        领取段位奖励
    ]]
    function self.action_gradeReward(request)
        local response = self.response
        local uid = request.uid
        local grade = request.params.grade

        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel("userkillrace")

        -- 段位不符合
        if grade > mKillrace.max_grade then
            response.ret = -2102
            return response
        end

        local killRaceCfg = getConfig("killRaceCfg")
        local levelTaskCfg = killRaceCfg.levelTask[grade]

        if not levelTaskCfg then
            response.ret = -102
            response.levelTaskCfg = "levelTaskCfg error"
            return response
        end
        
        -- 任务未完成
        if not mKillrace.levelTaskIsCompleted(grade) then
            response.ret = -1981
            return response
        end

        -- 奖励已领取
        if mKillrace.getGradeRewardFlag(grade) then
            response.ret = -1976
            return response
        end

        -- 设置领奖标识
        mKillrace.setGradeRewardFlag(grade)

        -- K币奖励
        mKillrace.addKCoin(levelTaskCfg.r[1])

        -- 奖励物品
        if not takeReward(uid,levelTaskCfg.r[3]) then
            response.ret = -403
            return response
        end

        if uobjs.save() then
            response.data.userkillrace = {
                kcoin = mKillrace.kcoin,
                grade_reward_flags = mKillrace.parseFlags(mKillrace.grade_reward_flags,mKillrace.max_grade),
            }

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        领取赛季奖励
        赛季奖励的标识记在了段位奖励里,因为段位1没有奖励,所以用1段位来放了赛季奖励
    ]]
    function self.action_seasonReward(request)
        local response = self.response
        local grade = request.params.grade
        local queue = request.params.queue
        local uid = request.uid

        -- 休赛期才能领取赛季奖励
        if not self.libKillRace.isOff() then
            response.ret = -2106
            return response
        end

        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel("userkillrace")

        -- 段位不符合
        if grade ~= mKillrace.grade or mKillrace.queue ~= queue then
            response.ret = -2102
            return response
        end

        -- 段位1没有相关的段位奖励，这里用1标识位来记录赛季奖励是否已经领取
        local flag = 1

        -- 奖励已领取
        if mKillrace.getGradeRewardFlag(flag) then
            response.ret = -1976
            return response
        end

        mKillrace.setGradeRewardFlag(flag)

        local killRaceCfg = getConfig("killRaceCfg")
        local rewardCfg = killRaceCfg.seasonReward[grade][queue]
        if not rewardCfg then
            response.ret = -102
            response.rewardCfg = "nil"
            return response
        end

        mKillrace.addKCoin(rewardCfg[1])

        -- 物品添加
        if not takeReward(uid,rewardCfg[3]) then
            response.ret = -403
            return response
        end

        if uobjs.save() then
            response.data.userkillrace = {
                kcoin = mKillrace.kcoin,
                day_reward_flags = mKillrace.parseFlags(mKillrace.day_reward_flags,#killRaceCfg.dailyTask),
            }

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        K币商店购买
    ]]
    function self.action_buy(request)
        local response = self.response
        local item = request.params.item
        local grade = request.params.grade
        local uid = request.uid

        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel("userkillrace")
        local libKillRace = loadModel("lib.killrace")
        local killRaceVerCfg = libKillRace.getRaceVerCfg()

        local shopCfg = killRaceVerCfg.raceShop[grade][item]
        if not shopCfg then
            response.ret = -102
            response.shopCfg = shopCfg or "shopCfg err"
            return response
        end

        -- 段位不够
        if mKillrace.grade < grade or (mKillrace.grade == grade and mKillrace.queue < shopCfg[1]) then
            response.ret = -2102
            return response
        end

        -- 限购检测
        if shopCfg[3] > 0 then
            if mKillrace.getShopItem(grade,item) >= shopCfg[3] then
                response.ret = -1987
                return response
            end

            mKillrace.setShop(grade,item)
        end
        
        -- K币不足
        if not mKillrace.useKCoin(shopCfg[2]) then
            response.ret = -2101
            return response
        end

        -- 物品添加失败
        if not takeReward(uid,shopCfg[5]) then
            response.ret = -403
            return response
        end

        if uobjs.save() then
            response.data.userkillrace = {
                kcoin = mKillrace.kcoin,
                shop = mKillrace.shop,
            }

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        战斗
    ]]
    function self.action_battle(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel("userkillrace")
        local mUserinfo = uobjs.getModel("userinfo")
        local killRaceCfg = getConfig("killRaceCfg")

        -- 无匹配信息
        if not next (mKillrace.match_info) then
            response.ret = -102
            return response
        end

        -- 战斗期检测
        local libKillRace = loadModel("lib.killrace")
        if not libKillRace.isBattle() then
            response.ret = -2108
            return response
        end

        -- 双方坦克对比
        local troopsInfo = {a={},d={}}
        -- 本次双方损失的坦克数量
        local lostShip = {attacker={},defenser={}}

        local fleetInfo = {}
        for m, n in pairs(request.params.fleetinfo) do
            n[1] = string.format("a%d",n[1])

            -- 使用的部队数量固定
            if not next(n) or n[2] ~= killRaceCfg.troopsNum then
                response.ret = -102
                return response
            end

            -- 扣除部队
            if not mKillrace.troopConsume(n[1],n[2]) then
                response.ret = -5006
                return response
            end

            fleetInfo[m] = n
            troopsInfo.a[n[1]] = (troopsInfo.a[n[1]] or 0) + n[2]
        end

        -- 部队组数要配满6只
        if #fleetInfo < 6 then return response end

        local imageInfo = mKillrace.getImage()
        local imageTroops = {}
        for k,v in pairs(imageInfo[8]) do
            imageTroops[k] = {v,killRaceCfg.troopsNum}
            troopsInfo.d[v] = (troopsInfo.d[v] or 0) + killRaceCfg.troopsNum
        end

        local aFleetInfo = initTankAttribute(fleetInfo)
        local dFleetInfo = initTankAttribute(imageTroops)

        -- 天气和地形对双方部队的影响
        local ocean = mKillrace.match_ocean
        local weather = mKillrace.match_weather
        libKillRace.setTroopsAttributeByWeatherAndOcean(aFleetInfo,weather,ocean)
        libKillRace.setTroopsAttributeByWeatherAndOcean(dFleetInfo,weather,ocean)

        local oceanEffect = {
            killRaceCfg.ocean[ocean].effectType,
            killRaceCfg.ocean[ocean].attValue,
        }

        require "lib.battle"
        local report, aInavlidFleet, dInvalidFleet, attSeq, seqPoint,aSurviveNum,dSurviveNum= {}
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq, seqPoint = battle(aFleetInfo,dFleetInfo,0,nil,{killrace=oceanEffect})
        report.t = {imageTroops,fleetInfo}
        report.p = {{imageInfo[1],imageInfo[2],0,seqPoint[2]},{mUserinfo.nickname,mUserinfo.level,1,seqPoint[1]}}
        report.ocean = getBattleOcean()

        aSurviveNum,lostShip.attacker = self.count(fleetInfo,aInavlidFleet)
        dSurviveNum,lostShip.defenser = self.count(imageTroops,dInvalidFleet)

        -- 返还战后留存的部队
        for k,v in pairs(aInavlidFleet) do
            assert(v.num <= killRaceCfg.troopsNum)
            if v.num and v.num > 0 then
                mKillrace.troopAdd(v.id,v.num)
            end
        end
        
        -- 总出战部队数固定6组*每组的部队数
        local totalTroopsNum = killRaceCfg.troopsNum * 6
        -- 击杀数为总部队数减去敌方存活部队数
        local killed = totalTroopsNum - dSurviveNum
        -- 战损率是我方的存活部队数与部部队数的比率
        local damageRate = aSurviveNum / totalTroopsNum

        mKillrace.addKillNum(killed)
        mKillrace.setBattleResult(report.r)
        mKillrace.clearMatchInfo()
        response.data.dmgrate = mKillrace.setDamageRate(damageRate)

        local score,kcoin = 0,0

        -- 战斗胜利可获得相关积分和K币
        if report.r == 1 then
            score,kcoin = mKillrace.getWinReward(damageRate)
            mKillrace.addKCoin(kcoin)

            -- 如果战力设置成功,或在此段位没有设置过镜像,需要更新镜像
            local fight = mKillrace.getTroopsFight(fleetInfo)
            if mKillrace.setFight(fight) or not mKillrace.isImageSet() then
                mKillrace.updateImage(mUserinfo.nickname,mUserinfo.pic,mUserinfo.level,fleetInfo,fight,damageRate,mUserinfo.bpic,mUserinfo.apic)
            end
        end

        -- 增加积分,得到本次段位升级的相关信息
        -- 0分也会触发段位升级,分数已够,战斗次数和击杀数未够的情况
        local upgradeInfo = mKillrace.addScore(score)

        local db,duobjs
        if upgradeInfo then
            -- 如果是大段位首次升级,需要按升级后的段位赠送一次部队
            if mKillrace.upgrade(upgradeInfo.nextGrade,upgradeInfo.nextQueue) then
                local troops = libKillRace.troopsGive(mKillrace.grade,mKillrace.queue)
                mKillrace.troopsAdd(troops)
                libKillRace.addChangeLog(uid,1,troops)
                response.data.gives = troops
            end

            -- 如果有降阶的用户,需要执行降阶操作
            if upgradeInfo.dropUid then
                duobjs = getUserObjs(upgradeInfo.dropUid)
                local dUserKillrace = duobjs.getModel("userkillrace") 
                dUserKillrace.degrade(upgradeInfo.grade,upgradeInfo.queue)
            end
        end

        -- 成就数据
        updatePersonAchievement(uid,{'a51','a52'})

        if duobjs then
            db = getDbo()
            db.conn:setautocommit(false)

            if uobjs.save() and duobjs.save() and db.conn:commit() then
                response.ret = 0   
                response.msg = 'Success'
            else
                db.conn:rollback()
            end

            db.conn:setautocommit(true)
        else
            if uobjs.save() then
                response.ret = 0   
                response.msg = 'Success'
            end
        end

        if response.ret == 0 then
            -- 战报
            libKillRace.addBattleReport({
                uid=uid,
                defenderName=imageInfo[1],
                score=score,
                grade=upgradeInfo and upgradeInfo.nextGrade,
                queue=upgradeInfo and upgradeInfo.nextQueue,
                isvictory=report.r,
                content={
                    report=report,
                    destroy =lostShip,
                    tank=troopsInfo,
                    kcoin = kcoin,
                    ocean = ocean,
                    weather = weather,
                },
                updated_at=os.time(),
            })

            -- 设置排行榜
            libKillRace.setGradeRanking(uid,mKillrace.grade,mKillrace.queue,mKillrace.score)

            response.data.report = report
            response.data.userkillrace = mKillrace.toArray(true)
        end

        return response
    end

    function self.count(fleetInfo,invalidFleetInfo)
        local num = 0
        local dietroops = {}
        for k,v in pairs(fleetInfo) do
            num = num + invalidFleetInfo[k].num
            if v[2] > invalidFleetInfo[k].num then
                dietroops[v[1]] = (dietroops[v[1]] or 0) + v[2] - invalidFleetInfo[k].num
            end
        end
        return num,dietroops
    end

    --[[
        获取所有的领奖标识
    ]]
    function self.action_rewardFlags(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mKillrace = uobjs.getModel("userkillrace")
        local killRaceCfg = getConfig("killRaceCfg")

        response.data.userkillrace = {
            grade_reward_flags = mKillrace.parseFlags(mKillrace.grade_reward_flags,mKillrace.max_grade),
            day_reward_flags = mKillrace.parseFlags(mKillrace.day_reward_flags,#killRaceCfg.dailyTask),
            day_grade = mKillrace.day_grade,
        }
        
        response.ret = 0   
        response.msg = 'Success'
        return response
    end

    --[[
        开关设置
    ]]
    function self.action_setting(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel("userkillrace")

        if mKillrace.setSwitch(request.params.switch) then
            if uobjs.save() then
                response.ret = 0   
                response.msg = 'Success'
            end
        else
            response.ret = 0   
            response.msg = 'Success'
        end

        return response
    end

    -- function self.after() end

    return self
end

return api_killrace_killrace