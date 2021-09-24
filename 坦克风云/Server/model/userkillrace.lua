function model_userkillrace(uid,data)
    local self = {
        uid = uid,
        nickname = '',
        entry = 0, -- 报名标识
        score = 0, -- 积分
        kcoin = 0, -- K币数量
        fight = 0, -- 标准战力
        grade = 1, -- 当前大段位
        queue = 1, -- 小段位
        max_grade = 1, -- 最高大段位
        max_queue = 1, -- 最高小段位
        max_dmg_rate = 0, -- 最高战损率(整数部分)
        -- troops_give = 0, -- 部队赠送标识
        total_change = 0, -- 部队总兑换次数
        
        total_killed = 0, -- 总击杀数
        total_battle_num = 0, -- 总战斗次数
        grade_battle_num = 0, -- 最高段位总战斗次数(这个用来检测升级任务)
        
        match_info = {}, -- 匹配信息
        match_ocean = 0, -- 匹配到的地形
        match_weather = 0, -- 匹配到的天气
        image_flags = 0, -- 镜像设置标识
        grade_reward_flags = 0, -- 段位奖励领取标识
        grade_task = 1, -- 段位任务1-5,一定是从低到高
        season = 0, -- 赛季

        day_grade = 0, -- 跨天时的段位(用来算每日任务)
        day_change = 0, -- 当日部队兑换次数
        day_killed = 0, -- 当日击杀数
        day_match_num = 0, -- 重置匹配次数
        day_wins = 0, -- 当日胜利次数
        day_battle_num = 0, -- 当日战斗次数
        day_max_continue_wins = 0, -- 当日最大连胜次数
        day_continue_wins = 0, -- 当时连胜次数(失败会被清掉)
        day_troops_give = 0, -- 每日部队赠送
        day_reward_flags = 0, -- 每日奖励领取标识
        day_at = 0, -- 当日时间戳,以此为依据跨天清数据
        switch = 0, -- 自动补兵开关信息
        troops = {}, -- 部队
        shop = {}, -- 商店信息

        -- 专为成就准备的字段
        avt_total_killed = 0,   -- 成就总击杀
        avt_gold_wins = 0,  -- 成就黄金总胜利场数

        updated_at=0,
    }

    local libKillRace = nil

    local function getLibKillRace()
        if not libKillRace then 
            libKillRace = loadModel("lib.killrace")
        end
        return libKillRace
    end

    -- 将数转换为可标识位数
    -- 1234 > 1248
    local function num2Flag(num)
        return math.pow(2,num-1)
    end

    -- 设置标识
    local function setFlag(flags,flag)
        return bit32.bor(flags,flag);
    end

    -- 标识是否已被设置
    local function isFlagSet(flags,flag)
        return bit32.band(flag,flags) == flag
    end

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end

        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
            end
        end

        -- 重置与天相关的数据
        local weeTs = getWeeTs()
        if self.day_at < weeTs then
            self.resetDailyData()
            self.day_at = weeTs
        end

        return true
    end

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then
                data[k] = v
            end
        end

        if format then
            data.day_reward_flags = nil
            data.grade_reward_flags = nil
        end

        return data
    end

    -- 重置当天所有数据
    function self.resetDailyData()
        self.day_match_num = 0
        self.day_change = 0
        self.day_killed = 0
        self.day_wins = 0
        self.day_battle_num = 0
        self.day_max_continue_wins = 0
        self.day_continue_wins = 0
        self.day_troops_give = 0
        self.switch = 0
        self.day_reward_flags = 0

        -- day_grade 用来记录当天最早时候的段位,每日任务按此计算
        self.day_grade = self.grade
    end

    -- 报名
    function self.apply(season)
        if self.entry == 0 then
            getLibKillRace().userApply()
        end

        self.entry = 1
        self.season = season
        return true
    end

    -- 排行榜要显示名字
    function self.setNickname(nickname)
        self.nickname = nickname
    end

    -- 是否报名
    function self.isApply()
        return 1 == self.entry
    end

    -- 自动竞兵开关设置(每天重置)
    function self.setSwitch(switch)
        if switch ~= self.switch then 
            self.switch = switch  
            return true
        end
    end

    function self.troopsAdd( troops )
        for k,v in pairs(troops) do
            self.troops[k] = (self.troops[k] or 0) + v
        end
    end

    function self.troopAdd(troop,num)
        self.troops[troop] = (self.troops[troop] or 0) + num
    end

    -- 部队消耗
    function self.troopConsume(troop,num)
        if (self.troops[troop] or 0) >= num then
            self.troops[troop] = self.troops[troop] - num
            return true
        end
    end

    -- 增加K币
    function self.addKCoin(coin)
        if coin > 0 then
            self.kcoin = self.kcoin + coin
        end
    end

    function self.useKCoin(coin)
        if self.kcoin >= coin then
            self.kcoin = self.kcoin - coin
            return true
        end
    end

    --[[
        获取下一段位的相关信息
        不管分数和任务完成到任何阶段,一次只能往上升一阶
    ]]
    function self.getNextGradeInfo()
        local libKillRace = getLibKillRace()
        local killRaceVerCfg = libKillRace.getRaceVerCfg()

        local nextGrade,nextQueue
        if killRaceVerCfg.groupMsg[self.grade][self.queue].up then
            -- 大段位进阶
            nextGrade = self.grade + 1
            nextQueue = 1
        else
            -- 小段位进阶
            nextGrade = self.grade
            nextQueue = self.queue + 1
        end

        if killRaceVerCfg.groupMsg[nextGrade] and killRaceVerCfg.groupMsg[nextGrade][nextQueue] then
            return killRaceVerCfg.groupMsg[nextGrade][nextQueue].scoreRequire,nextGrade,nextQueue
        end
    end

    --[[
        检测段位等级任务
            大段位进阶必需完成对应的段位任务
            方便刷排行榜用,直接用grade_task字段记录是否完成
            高段位任务完成的情况下,低段位任务一定完成grade_task只需记录最高值
    ]]
    function self.checkLevelTask()
        local killRaceCfg = getConfig("killRaceCfg")
        local levelTaskCfg

        local maxGrade = 0 
        for k,v in pairs(killRaceCfg.levelTask) do
            if k > maxGrade then maxGrade = k end
        end

        for i=self.grade_task+1,maxGrade do
            levelTaskCfg = killRaceCfg.levelTask[i]
            if levelTaskCfg then
                if self.score >= levelTaskCfg.t[1] and self.total_killed >= levelTaskCfg.t[2] and self.grade_battle_num >= levelTaskCfg.t[3] then
                    self.grade_task = i
                else
                    break
                end
            end
        end
    end

    --[[
        段位升段
            首次升级到该大段位会发赠送部队
    ]]
    function self.upgrade(grade,queue)
        -- 大段位首次升级标识
        local firstUp = false

        self.grade = grade
        self.queue = queue

        if self.grade > self.max_grade then
            firstUp = true

            self.max_grade = self.grade
            self.max_queue = self.queue

            -- 大段位升级后,重置掉
            self.grade_battle_num = 0
        elseif self.grade == self.max_grade and self.queue > self.max_queue then
            self.max_queue = self.queue
        end

        return firstUp
    end

    --[[
        掉段
            被人挤到下一段位后,需要清除当前匹配信息,并推送消息给该玩家
    ]]
    function self.degrade(grade,queue)
        self.grade = grade
        self.queue = queue

        -- 清除当前匹配信息
        self.clearMatchInfo()

        local data = {userkillrace={
            grade=self.grade,
            queue=self.queue,
        }}

        regSendMsg(self.uid,'userkillrace.push',data)
    end

    --[[
        增加积分
            检测等级任务,触发升级检测

        param int score 积分值
        return 升阶信息
    ]]
    function self.addScore(score)
        self.score = self.score + math.floor(score)
        self.checkLevelTask()
        
        local nextScore,nextGrade,nextQueue = self.getNextGradeInfo()
        if nextGrade and self.score >= nextScore and self.levelTaskIsCompleted(nextGrade) then
            local libKillRace = getLibKillRace()
            local upgrade,dropUid = libKillRace.upgradeCheck(uid,self.grade,self.queue,nextGrade,nextQueue,self.score)

            if upgrade then
                return {
                    grade=self.grade,
                    queue=self.queue,
                    nextGrade=nextGrade,
                    nextQueue=nextQueue,
                    dropUid=dropUid,
                }
            end
        end
    end

    --[[
        获取战斗积分和K币
        param int damageRate 战损率
        return int ini 积分,k币
    ]]
    function self.getWinReward(damageRate)
        if damageRate > 1 then damageRate = 1 end
        local libKillRace = getLibKillRace()
        local killRaceVerCfg = libKillRace.getRaceVerCfg()
        local groupCfg = killRaceVerCfg.groupMsg[self.grade][self.queue]
        local score = groupCfg.winScoreBase + math.floor(groupCfg.killRateScore * damageRate)
        local kcoin = groupCfg.KgoldReward

        return score, kcoin
    end

    -- 获取段位号对应的标识号
    function self.getGradeFlag()
        return num2Flag(self.grade)
    end

    -- 设置镜像标识
    function self.setImageFlag()
        self.image_flags = setFlag(self.image_flags,self.getGradeFlag())
    end

    -- 镜像是否设置
    function self.isImageSet()
        return isFlagSet(self.image_flags,self.getGradeFlag())
    end

    --[[
        检测每日任务是否已完成
            1、每日胜利次数
            2、每日战斗次数
            3、每日击杀次数
            4、每日兑换次数
            5、每日连续胜利次数
        param int taskId 1-5
        param int condition 需要达到的条件数
    ]]
    function self.taskIsCompleted(taskId,condition)
        if taskId == 1 then
            return self.day_wins >= condition
        elseif taskId == 2 then
            return self.day_battle_num >= condition 
        elseif taskId == 3 then
            return self.day_killed >= condition
        elseif taskId == 4 then
            return self.day_change >= condition
        elseif taskId == 5 then
            return self.day_max_continue_wins >= condition
        end
    end

    -- 等级任务是否完成
    function self.levelTaskIsCompleted(grade)
        return self.grade_task >= grade
    end

    -- 设置每日领奖标识
    function self.setDayRewardFlag(item)
        self.day_reward_flags = setFlag(self.day_reward_flags,num2Flag(item))
    end

    -- 获取每日领奖标识
    function self.getDayRewardFlag(item)
        return isFlagSet(self.day_reward_flags,num2Flag(item))
    end

    -- 设置段位奖励领奖标识
    function self.setGradeRewardFlag(grade)
        self.grade_reward_flags = setFlag(self.grade_reward_flags,num2Flag(grade))
    end

    -- 获取段位奖励领奖标识
    function self.getGradeRewardFlag(grade)
        return isFlagSet(self.grade_reward_flags,num2Flag(grade))
    end

    --[[
        更新镜像数据
            如果未设置过镜像,添加
    ]]
    function self.updateImage(nickname,pic,level,troops,fight,damageRate,bpic,apic)
        local libKillRace = getLibKillRace()

        -- 存部队标识就可以了,数量是固定的读取时用配置还原
        local troopsInfo = {}
        for k,v in pairs(troops) do
            table.insert(troopsInfo,v[1])
        end

        local image = {
            uid = self.uid,
            nickname = nickname,
            level=level,
            pic=pic,
            grade=self.grade,
            queue=self.queue,
            dmgrate=self.rateFormat(damageRate),
            fight=fight,
            troops=troopsInfo,
            bpic=bpic,
            apic=apic,
        }

        -- 已经设置过镜像,直接更新
        if self.isImageSet() then
            libKillRace.updateImage(self.uid,image)
        else
            -- 未设置过镜像,判断镜像是否已满,如果未满新增一个镜像,并且设置'已设标识'
            local imageNum,isFull = libKillRace.getImageNum(self.grade) 
            if not isFull then
                libKillRace.addImage(image)
                self.setImageFlag()
            end
        end
    end

    --[[
        设置标准战力
            当前阵容战斗力高于标准战力时，生成镜像，替换镜像库中原镜像，并且，将本次镜像标记为标准战力；
            当前阵容战斗力低于标准战力，降低幅度＜标准战力的5%，生成镜像，并执行替换。标准战力不替换，仍为之前的战力值；
            当前阵容低于标准战力，降低幅度＞标准战力的5%，不生成镜像；不替换镜像；
    ]]
    function self.setFight(fight)
        local updateImageFlag = false
        if fight > self.fight then
            self.fight = fight
            updateImageFlag = true
        elseif fight < self.fight then
            local killRaceCfg = getConfig("killRaceCfg")
            if (fight / self.fight) > killRaceCfg.imageNum[2] then
                updateImageFlag = true
            end
        end

        return updateImageFlag
    end

    -- 获取部队战力
    function self.getTroopsFight(troops)
        local fight = 0
        local tankCfg = getConfig("tank")
        for k,v in pairs(troops) do
            fight = fight + tankCfg[v[1]].Fighting * math.pow(v[2],0.7)
        end
        return fight
    end

    -- 设置最大战损率
    function self.setDamageRate(rate)
        rate = self.rateFormat(rate)
        if rate > self.max_dmg_rate then
            self.max_dmg_rate = rate
            local libKillRace = getLibKillRace()
            libKillRace.setDmgRateRanking(self.uid,self.max_dmg_rate)
        end
        return rate
    end

    --[[
        增加击杀数,并设置排行榜
        param int num 击杀的数量,不分类型
    ]]
    function self.addKillNum(num)
        if num > 0 then
            if self.avt_total_killed == 0 then
                local uobjs = getUserObjs(self.uid)
                local mAchievement = uobjs.getModel("achievement")
                if type(mAchievement.uinfo) == "table" and mAchievement.uinfo.a52 then
                    if tonumber(mAchievement.uinfo.a52) > self.avt_total_killed then
                        self.avt_total_killed = tonumber(mAchievement.uinfo.a52)
                    end
                end
            end

            self.total_killed = self.total_killed + num
            self.day_killed = self.day_killed + num
            self.avt_total_killed = self.avt_total_killed + num

            -- repair
            if self.avt_total_killed < self.total_killed then
                self.avt_total_killed = self.total_killed
            end

            self.checkLevelTask()

            local libKillRace = getLibKillRace()
            libKillRace.setTotalKilledRanking(self.uid,self.total_killed)
        end
    end

    -- 增加战斗次数
    function self.addBattleNum()
        self.day_battle_num = self.day_battle_num + 1
        self.total_battle_num = self.total_battle_num + 1

        -- 如果当前的大段位和最高大段位一致
        if self.grade >= self.max_grade then
            self.grade_battle_num = self.grade_battle_num + 1
            self.checkLevelTask()
        end
    end

    --[[
        战斗结果相关设置
            失败清除连胜次数
        param int result 战斗结果1是胜利
    ]]
    function self.setBattleResult(result)
        if result == 1 then
            self.day_wins = self.day_wins + 1
            self.day_continue_wins = self.day_continue_wins + 1

            if self.grade >= 3 then
                -- if self.avt_gold_wins == 0 then
                    local uobjs = getUserObjs(self.uid)
                    local mAchievement = uobjs.getModel("achievement")
                    if type(mAchievement.uinfo) == "table" and mAchievement.uinfo.a51 then
                        if tonumber(mAchievement.uinfo.a51) > self.avt_gold_wins then
                            self.avt_gold_wins = tonumber(mAchievement.uinfo.a51)
                        end
                    end
                -- end

                self.avt_gold_wins = self.avt_gold_wins + 1
            end
        else
            self.day_continue_wins = 0
        end

        if self.day_continue_wins > self.day_max_continue_wins then
            self.day_max_continue_wins = self.day_continue_wins
        end

        self.addBattleNum()
    end

    --[[
        设置匹配信息
        param table matchInfo 对手信息 [昵称,等级,图像,大段位,击杀率,战力]
        param int weather 天气
        param int ocean 地形
    ]]
    function self.match(matchInfo,weather,ocean)
        -- 已有匹配信息时设置是更换,每日匹配次数需要加1
        if next(self.match_info) then
            self.day_match_num = self.day_match_num + 1
        end

        self.match_info = matchInfo
        self.match_weather = weather
        self.match_ocean = ocean
    end

    --[[
        清除匹配的对手信息
        降阶/战斗胜利后,用户需要重新匹配对手
    ]]
    function self.clearMatchInfo()
        self.match_info = {}                     
        self.match_ocean = 0
        self.match_weather = 0
    end

    function self.getImage()
        return self.match_info
    end

    -- 商店购买设置次数
    function self.setShop(grade,item)
        grade = tostring(grade)
        if not self.shop[grade] then
            self.shop[grade] = {}
        end

        self.shop[grade][item] = (self.shop[grade][item] or 0) + 1
    end

    -- 获取商品购买次数
    function self.getShopItem(grade,item)
        grade = tostring(grade)
        return self.shop[grade] and self.shop[grade][item] or 0
    end

    -- 获取段位配置
    function self.getGroupMsgCfg()
        local libKillRace = loadModel("lib.killrace")
        local raceVerCfg = libKillRace.getRaceVerCfg()
        return raceVerCfg.groupMsg[self.grade][self.queue]
    end

    -- 相关概率处理为整数
    function self.rateFormat(rate)
        if rate < 1 then
            return math.floor(rate * 1000)
        end

        return rate
    end

    -- 解析标识
    function self.parseFlags(n,typeCount)
        local tb = {}
        for i=0,(typeCount or 8)-1 do
            if bit32.extract(n,i,1) == 1 then
                tb[i+1] = 1
            else
                tb[i+1] = 0
            end
        end
        return tb
    end

    -- 继续上一赛季的段位
    function self.inherit()
        if self.score > 0 then
            local killRaceCfg = getConfig("killRaceCfg")
            local libKillRace = loadModel("lib.killrace")
            local raceVerCfg = libKillRace.getRaceVerCfg()

            local score = self.score > killRaceCfg.inherit[2] and killRaceCfg.inherit[2] or self.score 
            local inheritGrade, inheritQueue
            for grade,gradeVal in pairs(raceVerCfg.groupMsg) do
                for queue,queueVal in pairs(gradeVal) do
                    if score >= queueVal.scoreRequire then
                        inheritGrade = grade
                        inheritQueue = queue
                    else
                        break
                    end
                end
            end

            if inheritGrade and inheritQueue then
                self.grade = inheritGrade
                self.queue = inheritQueue
                self.max_grade = self.grade
                self.max_queue = self.queue
                self.grade_task = self.grade
                self.day_grade = self.grade
                self.grade_battle_num = 0
            end
        end
    end

    -- 获取成就数据
    -- ntype：1.数量 2.等级
    function self.getAchievementData(ntype,data,subType)
        -- 夺海骑兵击杀数达到50000
        if subType == "d" then
            if self.avt_total_killed > self.total_killed then
                return self.avt_total_killed
            end

            return self.total_killed
            
        -- 夺海骑兵黄金场及以上战斗胜利场次达到10次
        else
            return self.avt_gold_wins
        end
    end

    return self
end
