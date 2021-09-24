-- 远洋征战
-- chenyunhe
function model_oceanexpedition(uid,data)
    local self = {
        uid = uid,
        nickname='',
        level = 0,
        bid = 0,-- 当前的哪一组
        signUpStatus = 0,--是否报名0未报名1元帅2队长3小喽啰
        canMaster = 0,--0没有资格竞选元帅1有资格
        job = 0,-- 职位 1统帅 2队长 3成员
        tid = 100,-- 队伍id 1,2,3,4,5  0元帅  100 是前后端默认的
        fc = 0,-- 战力
        score = 0,--积分
        fscore = 0, --献花积分 
        scoreround=0, -- 获取的积分轮次，记录哪一场次的积分已经同步加来了，此值是2表示1，2场的积分都同步回来了
        feats = 0,-- 功绩
        morale = 0,-- 士气值
        info = {},-- '部队数据'
        shop = {},-- 商店数据
        battr = {}, -- 提供的战斗加成属性，只有元帅和小队长的会被继承,这里的记录只是为了展示用
        appteam = {0,0,0,0,0},-- 玩家申请的队伍记录
        apply_at = 0,-- 报名时间
        updated_at = 0,
    }

    local consts = {
        JOB_MARSHAL=1,  -- 元帅
        JOB_MEMBER=3,   -- 成员
        JOB_CAPTAIN=2,  -- 队长

        BATTLE_TYPE=6, -- 大战类型ID
    }

    -- 远洋征战信息
    local oceanExpeditionInfo = nil

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end
   
        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function"  then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
            end
        end

        self.intdata()

        return true
    end

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                if format then
                    data[k] = v
                else
                    data[k] = v
                end
            end
        end

        return data
    end

    --  给客户端的格式
    function self.toArrayForClient()
        local data = self.toArray(true)
        local r = {}
        
        r.oceaninfo =copyTable(data)
        r.pubinfo = self.getcfg()

        -- 特殊处理一下,ext1指代士气
        r.pubinfo.morale = r.pubinfo.ext1 or 0

        local mOceanMatch = getModelObjs("oceanmatches")
        r.pubinfo.minfo = mOceanMatch.getmarshal(tonumber(r.pubinfo.bid)) or {} -- 元帅的数据

        return r
    end

    function self.simpleDataForClient(oceaninfo,pubinfo)
        return {
            oceaninfo=oceaninfo,
            pubinfo=pubinfo,
        }
    end

    -- 获取配置
    function self.getcfg()
        if not oceanExpeditionInfo then
            local mServerbattle = loadFuncModel("serverbattle")
            local oceaninfo,code = mServerbattle.getOceanExpeditionInfo()
         
            if code~=0 or not next(oceaninfo) then
                oceanExpeditionInfo = {}
            else
                oceanExpeditionInfo = oceaninfo
            end
        end

        return oceanExpeditionInfo
    end

    -- 初始化
    function self.intdata()
        local oceaninfo = self.getcfg()
        if next(oceaninfo) then
            if self.apply_at<oceaninfo.st or  self.apply_at>oceaninfo.et then
                self.nickname=''
                self.level = 0
                self.bid = 0
                self.job = 0 -- 职位0成员 1统帅 2队长
                self.signUpStatus = 0
                self.canMaster = 0
                self.tid = 100 -- 队伍id 1,2,3,4,5
                self.fc = 0 -- 战力
                self.feats = 0 -- 功绩
                self.score = 0 -- 积分
                self.scoreround=0
                self.fscore = 0 -- 献花积分
                self.morale = 0 -- 士气值
                self.info = {} -- 设置的部队
                self.shop = {} -- 商店
                self.apply_at = 0
                self.appteam = {0,0,0,0,0}
            end
        end
    end

    -- 增加积分
    function self.addscore(num)
        if num>0 then
            self.score = self.score + num
            return true
        end

        return false
    end

    -- 增加献花积分
    function self.addFlowerScore(num)
        if self.addscore(num) then
            self.fscore = self.fscore + num
        end
    end

    -- 减少积分
    function self.reducescore(num)
        if num>0 then
            if self.score<num then
                return false
            end
            self.score = self.score - num
            return true
        end

        return false
    end

    -- 是否队长
    function self.isCaptain(job)
        return (job or self.job) == consts.JOB_CAPTAIN
    end

    -- 是否元帅
    function self.isMarshal(job)
        return (job or self.job) == consts.JOB_MARSHAL
    end

    -- 是否是成员
    function self.isMember(job)
        return (job or self.job) == consts.JOB_MEMBER
    end

    -- 是否已参战
    function self.hasJoined()
        return self.isMember() or self.isMarshal() or self.isCaptain()
    end

    -- 跨服战是否开启
    function self.isOpen()
        return next(self.getcfg())
    end

    -- 刷新用户获取比赛积分信息
    function self.bindJoinPoint()
        local saveFlag

        if self.hasJoined() then
            local mOceanMatch = getModelObjs("oceanmatches",self.bid,true)
            local bdays = mOceanMatch.getMatchDays()
            if self.scoreround < bdays then
                local schedule = mOceanMatch.schedule()
                local zoneId = getZoneId()
                if type(schedule) == "table" then
                    local userRoundLog
                    for i=self.scoreround+1, bdays do
                        if schedule[i] and mOceanMatch.checkSchedule(schedule[i]) then

                            if not userRoundLog then
                                local data={
                                    cmd='oceanexpedition.server.getUserRoundLog',
                                    uid=self.uid,
                                    params={
                                        bid="b"..self.bid,
                                    }
                                }

                                local ret,result = self.serverRequest(data)
                                
                                if ret and result.data and result.data.roundLog then
                                    userRoundLog = result.data.roundLog
                                end
                            end

                            if not userRoundLog then
                                break
                            end

                            if userRoundLog[i] and userRoundLog[i][1] then
                                self.addscore(userRoundLog[i][1])
                                self.scoreround = i
                                saveFlag = true
                            end

                            if self.fscore > 0 and mOceanMatch.winOfRound(schedule[i],zoneId) then
                                local winFlowerScore = math.floor(self.fscore * getConfig("oceanExpedition").morale.costFlowerWinP)
                                self.addscore(winFlowerScore)
                                saveFlag = true
                            end
                        end
                    end
                end
            end
        end

        return saveFlag
    end

    function self.serverRequest(params)
        local config = getConfig("config.z"..getZoneId()..".worldwar")
        local result = sendGameserver(config.host,config.port,params)

        -- 服务器无返回
        if type(result) ~= "table" then
            writeLog({params=params,serverRequest=result or "no result"},"ocean")
            return false
        end

        if result.ret == 0 then
            return true, result
        end

        return false, result.ret
    end

    -- 设置阵型
    function self.setFormation(formation)
        local data={
            cmd='oceanexpedition.server.setFormation',
            params={
                zoneid=getZoneId(),
                bid="b"..self.bid,
                formation=formation,
            }
        }

        if not self.serverRequest(data) then
            return false, -27029
        end

        oceanExpeditionInfo.info.formation = formation
        local mOceanMatch = getModelObjs("oceanmatches",self.bid)
        mOceanMatch.setInfo(oceanExpeditionInfo.info)

        local ret = mOceanMatch.save()

        return ret
    end

    -- 设置旗帜
    function self.setFlag(flag)
        if not oceanExpeditionInfo.info.flag then
            local teamNum = getConfig("oceanExpedition").teamNum
            oceanExpeditionInfo.info.flag = {}
            for i=1, teamNum do
                table.insert(oceanExpeditionInfo.info.flag,{})
            end
        end

        -- 这儿加1是方便存
        local tid = self.tid + 1
        oceanExpeditionInfo.info.flag[tid] = flag

        local data={
            cmd='oceanexpedition.server.setFlag',
            params={
                zoneid=getZoneId(),
                bid="b"..self.bid,
                flag=oceanExpeditionInfo.info.flag,
            }
        }

        if not self.serverRequest(data) then
            return false, -27029
        end
        
        local mOceanMatch = getModelObjs("oceanmatches",self.bid)
        mOceanMatch.setInfo(oceanExpeditionInfo.info)

        local ret = mOceanMatch.save()

        return ret
    end

    -- 设置队伍成员
    function self.setTeamMembers(memberList)
        if not oceanExpeditionInfo.info.teams then
            local teamNum = getConfig("oceanExpedition").teamNum
            oceanExpeditionInfo.info.teams = {}
            for i=1, teamNum do
                table.insert(oceanExpeditionInfo.info.teams,{})
            end
        end

        -- 这儿加1是方便存
        local tid = self.tid + 1
        oceanExpeditionInfo.info.teams[tid] = memberList
        local mOceanMatch = getModelObjs("oceanmatches",self.bid)
        mOceanMatch.setInfo(oceanExpeditionInfo.info)

        if not mOceanMatch.setTeams(self.bid) then
            return false
        end
        
        local ret = mOceanMatch.save()

        return ret
    end

    function self.getTroops()
        return self.info.troops or {}
    end

    -- 设置部队
    function self.setTroops(fleet,troopsInfo,troopAddRate)
        local data={
            cmd='oceanexpedition.server.setMember',
        }

        local mUserinfo = getUserObjs(uid).getModel('userinfo')
        local action='apply'
        if next(self.info) then
            action = "update"
        end

        bid = "b"..self.bid
        data.params = {
            action=action,
            bid=bid,
            member={
                bid=bid,
                uid=self.uid,
                nickname=self.nickname,
                fc=self.fc,
                pic=mUserinfo.pic,
                bpic=mUserinfo.bpic,
                apic=mUserinfo.apic,
                level=self.level,
                fc=self.fc,
                job=self.job,
                zid=getZoneId(),
                binfo=troopsInfo,
                battr=troopAddRate, -- 在战斗中自己的战斗加成
            }
        }
        
        if not self.serverRequest(data) then
            return false, -27029
        end
        
        self.info = fleet
        self.battr = troopAddRate

        return true
    end

    local function getbattrCfg()
        -- 攻击、血量、命中、暴击、抗暴、闪避
        return {
            {"dmg","attack"},
            {"maxhp","life"},
            {"accuracy","accurate"},
            {"crit","critical"},
            {"anticrit","decritical"},
            {"evade","avoid"},
        }
    end

    -- 获取自己的可继承的属性
    function self.getTroopAttrAddRate(binfo)
        local attrCfg = getbattrCfg()

        -- 从binfo中提取出需要计算的相关属性
        local tmpKeys = {id=true}
        for k,v in pairs(attrCfg) do
            tmpKeys[v[1]] = true
        end

        local att4Idx = {}
        for i,attName in pairs(binfo[1]) do
            if tmpKeys[attName] then
                att4Idx[attName] = i
            end
        end

        -- binfo[2]下边还包了一层(应该是为了兼容有多支部队的情况)
        local troopAttrs = {}
        for k,v in pairs(binfo[2][1]) do
            troopAttrs[k] = {}
            for attName,idx in pairs(att4Idx) do
                troopAttrs[k][attName] = v[idx]
            end
        end

        -- 提了出来的数据结构如下
        -- troopAttrs[1].id = "a10073"
        -- troopAttrs[1].dmg = 10000
        -- troopAttrs[1].maxhp = 10000
        -- troopAttrs[1].accuracy = 3
        -- troopAttrs[1].crit = 3
        -- troopAttrs[1].anticrit = 3
        -- troopAttrs[1].evade = 3

        local attrVal = {}
        local count = 0
        local troopCfg = getConfig("tank")
        local alienValue = getConfig("oceanExpedition").alienValue

        if type(troopAttrs) == "table" then
            for k,v in pairs(troopAttrs) do
                if v.id then
                    for _,attr in pairs(attrCfg) do
                        if attr[1] == "dmg" or attr[1] == "maxhp" then
                            attrVal[attr[1]] = (attrVal[attr[1]] or 0) + v[attr[1]] / troopCfg[v.id][attr[2]] / alienValue
                        else
                            attrVal[attr[1]] = (attrVal[attr[1]] or 0) + (v[attr[1]] - troopCfg[v.id][attr[2]]/100)
                        end
                    end

                    count = count + 1
                end
            end
        end

        -- 保留4位
        local e = 10^4
        for k,v in pairs(attrVal) do
            attrVal[k] = math.floor(v/count * e) / e
        end  

        -- 按指定属性顺序存放
        local addRate = {}
        for _,v in pairs(attrCfg) do
            table.insert(addRate,attrVal[v[1]] or 0)
        end

        return addRate
    end

    function self.getBAttr()
        -- [1.5,1.5,0.5,0.5,0.5,0.5]
        if next(self.battr) then
            local battr = {}
            local attrCfg = getbattrCfg()
            for k,v in pairs(attrCfg) do
                battr[v[1]] = self.battr[k]
            end
            return battr
        end
    end

    -- 增加士气值
    function self.addmorale(num)
        if num>0 then
            self.morale = self.morale + num
            return true
        end

        return false
    end

    -- 检验部队信息
    function self.checkjob()
        local oceaninfo = self.getcfg()
        if next(oceaninfo) then
            if self.apply_at>oceaninfo.st and self.apply_at<oceaninfo.et and self.bid==oceaninfo.bid then
                local mOceanMatch = getModelObjs("oceanmatches",self.bid,false,true)
                if mOceanMatch then
                    if self.tid>=0 and self.tid<=5 then
                        local tid = self.tid + 1
                        if not mOceanMatch.checkUidExists(self.uid,tid) then
                            mOceanMatch.joinTeam(tid,uid,self.job,self.fc)
                            mOceanMatch.save()
                        end
                    end
                end
            end
        end
    end


    -----------------------------------------
    return self
end  