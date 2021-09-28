-- 用户基础信息
local PlotlineDungeonType = require("app.const.PlotlineDungeonType")
local UserData = class("UserData")

function UserData:ctor()
    self.id = 0
    self.name = ""
    self.level = 0
    self.vit =0           --体力
    self.spirit = 0        --精力
    self.refresh_vit_time = 0
    self.refresh_spirit_time = 0
    self.exp = 0
    self.money =  0           --银两
    self.gold =  0          --元宝
    self.prestige = 0       --声望
    self.vip = 0
    self.fight_value = 0    -- 战斗力
    self.medal = 0          -- 奖章
    self.tower_score = 0    -- 爬塔积分
    --self.snatch_score = 0   -- 夺宝积分
    self.battle_token = 0   -- 出征令
    self.battle_token_time = 0 -- 出征令恢复时间
    self.skill_point = 0        -- 技能点
    self.essence = 0 --精魄
    self.forbid_battle_time = 0 --免战时间戳
    self.guide_id = -1
    self.hof_points = 0          -- 点赞次数
    -- 记录上一次角色信息
    self.lastData = nil
    self._date = nil
    
    self.god_soul = 0           -- 神魂
    self.contest_point = 0      -- 演武勋章
    self.invitor_score = 0           -- 推广积分
    self.coupon = 0             -- 团购券

    self._nPlotlineDungeonType = PlotlineDungeonType.EASY --主线副本类型

    -- 当前佩戴的称号ID
    self.title_id = 0
    -- 当前所有已激活的称号列表
    self.title_list = nil

    --头像框ID
    self.frameId = 0

    self.pet_points = 0   --战宠积分 or 兽魂 or 征战积分

    self.dailyPVPScore = 0

    self.hero_soul_point = 0 -- 灵玉（将灵模块所属）
    self.qiyu_point = 0      -- 奇遇点（将灵模块所属）
    -- 换装道具对应id 和持续时间
    self.cloth_id = 0
    self.cloth_time = 0
    self.cloth_open = true

    self.changeNameCnt = 0 -- 改名次数

    self.fight_base = 0 -- 战斗底座ID
end

function UserData:getLastData(valueName)
       if self.lastData == nil then
           self.lastData = {}
       end

       if self.lastData[valueName] == nil then
            self.lastData[valueName] = self[valueName]
       end

      local _value = self[valueName]  - self.lastData[valueName] 
      --self.lastData[valueName] = self[valueName]
      return _value or 0
end

function UserData:setLastValue(valueName,value)
    if self.lastData == nil then
        self.lastData = {}
    end
    self.lastData[valueName] = value
end

function UserData:setBaseData(user)
    self._date = G_ServerTime:getDate()
    
    if self.lastData == nil then
        self.lastData = {}
        self.lastData.money = user.money
        self.lastData.gold = user.gold
        self.lastData.fight_value = user.fight_value
        self.lastData.vit = user.vit
        self.lastData.spirit = user.spirit
    else
        if user.money ~= self.money then
            self.lastData.money = self.money
        end

        if user.gold ~= self.gold then
            self.lastData.gold = self.gold
        end

        if user.fight_value ~= self.fight_value then
            self.lastData.fight_value = self.fight_value
        end

         if user.vit ~= self.vit then
            self.lastData.vit = self.vit
        end

         if user.spirit ~= self.spirit then
            self.lastData.spirit = self.spirit
        end
        --self.lastData.gold = G_Me.userData.gold
        --self.lastData.fight_value = G_Me.userData.fight_value
        --self.lastData.vit = G_Me.userData.vit
        --self.lastData.spirit = G_Me.userData.spirit
    end


    self.id = user.id
    self.name = user.name
    self.level = user.level
    self.vit = user.vit       -- 体力
    self.spirit = user.spirit -- 精力
    self.refresh_vit_time = user.refresh_vit_time
    self.refresh_spirit_time = user.refresh_spirit_time
    self.exp = user.exp 
    self.money =  user.money 
    self.gold =  user.gold 
    self.medal = user.medal 
    self.prestige = user.prestige
    self.tower_score = user.tower_score   
    --self.snatch_score = user.snatch_score  
    self.battle_token = user.battle_token   
    self.battle_token_time = user.battle_token_time 
    self.skill_point = user.skill_point
    self.essence = user.essence
    self.fight_value = user.fight_value
    self.forbid_battle_time = user.forbid_battle_time
    self.guide_id = user.guide_id
    self.corp_point = user.corp_point
    
    self.god_soul = user.god_soul
    self.contest_point = user.contest_point

    self.title_id = user.title_id
    self.title_list = user.title_list
    self.invitor_score = user.spread_sum_score
    self.coupon = user.coupon

    self.frameId = rawget(user,"fid") and user.fid or 0

    self.pet_points = rawget(user,"fight_score") and user.fight_score or 0
    self.changeNameCnt = rawget(user, "cnt") and user.cnt or 0

    self.cloth_id = rawget(user,"cloth_id") and user.cloth_id or 0
    self.cloth_time = rawget(user,"cloth_time") and user.cloth_time or 0
    if rawget(user,"cloth_open") ~= nil then 
        self.cloth_open = rawget(user,"cloth_open")
    end
    -- 灵玉 
    if rawget(user, "ksoul_point") then
        self.hero_soul_point = user.ksoul_point
    end
    -- 奇遇点
    if rawget(user, "ksoul_summon_score") then
        self.qiyu_point = user.ksoul_summon_score
    end
    
    -- 战斗底座
    self.fight_base = rawget(user, "ksoul_fight_base") or 1
    self.fight_base = math.max(self.fight_base, 1)
end
function UserData:getClothId()
    if self.cloth_time > 0 and self.cloth_open then 
        return self.cloth_id
    else 
        return 0
    end 
end

function UserData:setClothOpen(_isOpen)
    self.cloth_open = _isOpen
end 
function UserData:getClothOpen()
    return self.cloth_open
end 

-- 返回秒数
function UserData:getClothTime()
    -- 判断是否过期
    local serverTime = G_ServerTime:getTime()
    if self.cloth_id == 0 or self.cloth_time == 0 
        or self.cloth_time < serverTime then 
        return 0
    else 
        return self.cloth_time - serverTime
    end 
end

-- 判断数据是否正常，是否过期
function UserData:checkCltm(_cltm)
    if not _cltm or _cltm < 0 or _cltm < G_ServerTime:getTime() then 
        return false
    end 
    return true
end 
-- 返回字符串  高于1小时显示x天x小时 低于1小时显示x分x秒
function UserData:getDiffTimeString(diff_time)
    local minute = 60
    local hour = minute * 60
    local day = hour * 24
    return string.format("%d天%d小时%d分%d秒",math.floor(diff_time/day), math.floor((diff_time%day)/hour),
        math.floor((diff_time%hour)/minute), diff_time%minute )
end

function UserData:setHofPoints(points)
    self.hof_points = points
end

function UserData:setVip(vip)
    self.vip = vip
end

function UserData:setFrameId(fid)
    self.frameId = fid
end

function UserData:getFrameId()
    
    --TODO 针对特殊头像框要判断有没有过期
    return self.frameId

end

function UserData:getPetPoints()
    return self.pet_points
end

function UserData:setTowerScore(score)
    self.tower_score = score
end

-- 设置当前个消耗品点数
function UserData:setCurrCostValue(_vit,_spirit,_battle_token)
    self.vit = _vit
    self.spirit = _spirit
    self.battle_token = _battle_token
end

function UserData:getMaxTeamSlot(  )
    require("app.cfg.role_info")

    local roleInfo = role_info.get(self.level)
    if roleInfo then
        return roleInfo.team_num
    end
    
    return 1
end

function UserData:getMaxPartnerSlot( ... )
    require("app.cfg.role_info")

    local roleInfo = role_info.get(self.level)
    if roleInfo then
        return roleInfo.battle_friends_num
    end
    
    return 0
end

function UserData:getTeamSlotOpenLevel( ... )
    require("app.cfg.role_info")

    local levelArr = {}
    local teamNum = 1

    for loopi = 1, role_info.getLength() do 
        local roleInfo = role_info.get(loopi)
        if roleInfo and roleInfo.team_num == teamNum then 
            table.insert(levelArr, #levelArr + 1, roleInfo.level)
            teamNum = teamNum + 1
        end

        if teamNum >= 12 then
            return levelArr
        end
    end

    return levelArr
end

-- @desc 是否重新需要拉数据
function UserData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

-- 设置主线副本模式
function UserData:setPlotlineDungeonType(nType)
    self._nPlotlineDungeonType = nType or PlotlineDungeonType.EASY
end
function UserData:getPlotlineDungeonType()
    return self._nPlotlineDungeonType
end

-- 获取自己的titleid
function UserData:getTitleId( ... )
    if G_Me.bagData:isTitleOutOfDate(self.title_id) then
        return 0
    else
        return self.title_id
    end
end

--经验加成，大的覆盖小的
function UserData:getExpAdd(exp)
    local expStr = self:getExpAdd2(exp)
    return expStr
end

function UserData:getExpAdd2(exp)
    local expAdd = 0
    local expStr = ""
    local data = G_Me.legionData:getTechAdd()
    if data[25] then
        local add = data[25]/1000
        if add > expAdd then
            expAdd = add
            expStr = G_lang:get("LANG_LEGION_TECH_EXP_ADD",{exp=math.floor(exp*expAdd)})
        end
    end
    local buffData = G_Me.rookieBuffData:getBuffExpAdd()
    if buffData > 0 then
        local add = buffData/100
        if add > expAdd then
            expAdd = add
            expStr = G_lang:get("LANG_ROOKIE_BUFF_ADDEXP",{addExp=math.floor(exp*expAdd)})
        end
    end
    return expStr, math.floor(exp*expAdd)
end

-- 更改名字成功之后需要将新名字设置一下
function UserData:setName( name )
    self.name = name
end

-- 获取已经改过几次名字
function UserData:getChangeNameCnt(  )
    return self.changeNameCnt
end

-- 改名成功后需要将次数加1
function UserData:addChangeNameCnt(  )
    self.changeNameCnt = self.changeNameCnt + 1
end

return UserData
