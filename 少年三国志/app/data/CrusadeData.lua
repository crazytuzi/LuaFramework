local CrusadeData = class("CrusadeData")
require("app.cfg.battlefield_position_info")
require("app.cfg.battlefield_award_info")

local MAX_OPEN_TREASURE_TIMES = 5   --宝藏开启次数
local MAX_POSITION = 0
local MAX_STAGE = 4


function CrusadeData:ctor()

    self._inited = false       --数据是否同步过
    self._lastPullDate = 0     --最后一次拉取信息时间
    self:initData()

    MAX_POSITION = math.max(battlefield_position_info.getLength(),3)        
end

function CrusadeData:isInited()
    return self._inited
end


-- @desc 是否重新需要拉数据 --重置次数重置
function CrusadeData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._lastPullDate  or not self._inited then
        return true
    else
        return false
    end
end


function CrusadeData:initData( ... )
    --battle field info 
    self._curStage = 0   --当前大关
    self._leftChallengeTimes = 0  --剩余挑战次数
    self._resetCost = 0   --重置花费 0为免费
    self._resetCount = 0  --剩余重置次数
    self._currentId = 0   --当前正在攻打目标
    self._maxPoints = 0   --历史最大兽魂
    self._curPoints = 0   --当前累计兽魂

    self._lastRequestHeroID= 0     --上次请求的目标ID
    self._lastPosY = 0  --临时记录scrollview滑动位置用于返回主界面定位

    --battlefield sample info
    self._battleFieldSample = {}

    if not self._bf_type or self._bf_type > 1 then
        self._curDropId = 0
        self._dropTimes = 0
        self._dropCost = 1
    end
    
    self._bf_type = 0    

end

--正常拉取信息、重置、下一关都会走这里
function CrusadeData:setBattleFieldInfo(data)

    if not data or type(data) ~= "table" then return end

    --区分主动请求battleinfo信息还是服务器推送
    --挑战胜利解锁新的对手也是走这条协议，但不能把数据重置
    if self._bf_type > 0 then
        self:initData()
    end

    self._inited = true

    self._lastPullDate = G_ServerTime:getDate()

    self._curStage = rawget(data,"bf_tag") and data.bf_tag or 1
    self._leftChallengeTimes = rawget(data,"challenge_count") and data.challenge_count or 0
    self._resetCost = rawget(data,"reset_cost") and data.reset_cost or 0
    self._resetCount = rawget(data,"reset_count") and data.reset_count or 0
    self._currentId = rawget(data,"current_id") and data.current_id or 0
    self._maxPoints = rawget(data,"history_pet_point") and data.history_pet_point or 0
    self._curPoints = rawget(data,"current_pet_point") and data.current_pet_point or 0

    self:_setBattleFieldSample(data)

    --dump(data)

end

function CrusadeData:_setOneBattleFieldSample(data)

    if not data or type(data) ~= "table" then return end

    local bf_sample_id = rawget(data, "id") and data.id or 0

    local bf_sample = self._battleFieldSample[bf_sample_id]

    --信息已部分缓存
    if bf_sample ~= nil then
        --bf_sample.new_unlock = false
        bf_sample.id = rawget(data, "id") and data.id or 0  
        bf_sample.sid = rawget(data, "sid") and data.sid or 0
        bf_sample.user_id = rawget(data, "user_id") and data.user_id or 0
        bf_sample.fight_value = rawget(data, "fight_value") and data.fight_value or 0
        bf_sample.hp_rate = rawget(data, "hp_rate") and data.hp_rate or 0
        bf_sample.level = rawget(data, "level") and data.level or 0
        bf_sample.name = rawget(data, "name") and data.name or ""
    else
        --新增项
        self._battleFieldSample[bf_sample_id] = 
            {
                new_unlock = true,   -----新解锁
                id = rawget(data, "id") and data.id or 0, 
                sid = rawget(data, "sid") and data.sid or 0,
                user_id = rawget(data, "user_id") and data.user_id or 0,
                fight_value = rawget(data, "fight_value") and data.fight_value or 0,
                hp_rate = rawget(data, "hp_rate") and data.hp_rate or 0,
                level = rawget(data, "level") and data.level or 0,
                name = rawget(data, "name") and data.name or "",

            }
    end
end


function CrusadeData:_setBattleFieldSample(data)
   
    if rawget(data, "battle_field") and type(data.battle_field) == "table" then
        
        if #data.battle_field == 0 then
            --G_MovingTip:showMovingTip(G_lang:get("LANG_CRUSADE_NO_TARGETS"))
        else
            for i=1, #data.battle_field do
                local bf_sample = data.battle_field[i]
                self:_setOneBattleFieldSample(bf_sample)
            end
        end

        --dump(self._battleFieldSample)
    end
end


function CrusadeData:setBattleFieldDetail(data)
   if not data or type(data) ~= "table" then return end
   
    local bf_sample_id = rawget(data, "id") and data.id or 0

    local bf_sample = self._battleFieldSample[bf_sample_id]

    self._lastRequestHeroID = bf_sample_id

    if bf_sample ~= nil then

        bf_sample.user = {} --先重置下
        bf_sample.user = rawget(data, "user") and data.user or {}
        bf_sample.pet_point = rawget(data, "pet_point") and data.pet_point or 0
        bf_sample.knights = {} --单位血量信息

        if rawget(data, "knights") and type(data.knights) == "table" then
            for i=1, #data.knights do
                local knight = data.knights[i]
                bf_sample.knights[i] = 
                    {                   
                        index = rawget(knight, "index") and knight.index or 0,
                        hp = rawget(knight, "hp") and knight.hp or 0,
                        max_hp = rawget(knight, "max_hp") and (knight.max_hp > 0 and knight.max_hp or 1) or 0,
                        base_id = rawget(knight, "base_id") and knight.base_id or 0,
                    }
            end
        end
    end
   
   -- dump(self._battleFieldSample[bf_sample_id])

end

function CrusadeData:setBattleFieldType(_type)
    if not _type or type(_type) ~= "number" then return end

    self._bf_type = _type
end

--更新剩余挑战次数
function CrusadeData:setChallengeInfo(data)
    if not data or type(data) ~= "table" then return end

    if rawget(data, "challenge_count") then
        self._leftChallengeTimes = data.challenge_count
    else
        self._leftChallengeTimes = math.max(self._leftChallengeTimes-1,0)  --手动减1
    end

    --挑战过了 重置 下次挑战还需要请求
    self._lastRequestHeroID = 0

    --更新被攻击对象信息
    if rawget(data, "sample") then
        self:_setOneBattleFieldSample(data.sample)
    end

end

--更新宝藏信息
function CrusadeData:setTreasureInfo(data)
    if not data or type(data) ~= "table" then return end
   
    self._curDropId = rawget(data,"drop_id") and data.drop_id or 0
    self._dropCost = rawget(data,"drop_cost") and data.drop_cost or 0
    self._dropTimes = rawget(data,"drop_time") and data.drop_time or 0

end


function CrusadeData:getHeroInfo(id)

    if not id or type(id) ~= "number" or id < 1 then return nil end

    return self._battleFieldSample[id]

end


function CrusadeData:getHeroInfoByIndex(id)
   
    if not id or type(id) ~= "number" then return nil end

    if #self._battleFieldSample >= 1 then
        for i=1, #self._battleFieldSample do
            if self._battleFieldSample[i].id == id then
                return self._battleFieldSample[i]
            end
        end
    end

    return nil
end

--是否为新解锁的 
function CrusadeData:getNewUnlocked(sample)
    return sample and sample.new_unlock == true 
end

function CrusadeData:setNewUnlocked(sample, status)  

    if sample and type(sample) == "table" then
        sample.new_unlock = status
    end
end

function CrusadeData:getLastRequestID()
    return self._lastRequestHeroID
end

function CrusadeData:getLastPos()
    return self._lastPosY
end

function CrusadeData:setLastPos(posY)
    self._lastPosY = posY or 0
end

function CrusadeData:getCurrentId()
    return self._currentId
end

function CrusadeData:getMaxPoints()
    return self._maxPoints
end

function CrusadeData:getCurPoints()
    return self._curPoints
end

function CrusadeData:getCurStage()
    return self._curStage
end

function CrusadeData:getResetCount()
    return self._resetCount
end

function CrusadeData:getFreeResetCount()

    --没有重置次数了
    if self._resetCount == 0 then
        return 0
    else
        --每天仅有一次免费重置次数
        return self._resetCost > 0 and 0 or 1 
    end

end

function CrusadeData:isBeAttacked(id)
    if not id or type(id) ~= "number" then return nil end
    
    return id == self._currentId
end

function CrusadeData:getResetCost()
    return self._resetCost
end

function CrusadeData:canOpenTreasureFree( ... )
    return self:canOpenTreasure() and self:getOpenTreasureCost() == 0
end

--主入口是否显示红点
function CrusadeData:showMainEntryTip( ... )
    return (self:canOpenTreasureFree() or self:getFreeResetCount() > 0 
        or self:getLeftChallengeTimes() > 0) -- or G_Me.shopData:shouldShowPetShop()) 战宠商店红点不体现在征战按钮上
end

--是否能继续开宝箱
function CrusadeData:canOpenTreasure()
    return self:hasPassStage() and self._dropTimes < MAX_OPEN_TREASURE_TIMES
end

function CrusadeData:getOpenTreasureCost()
    return self._dropCost
end

function CrusadeData:getDropId()
    return self._curDropId
end

function CrusadeData:getLeftOpenTreasureTimes( ... )
    
    return math.max(MAX_OPEN_TREASURE_TIMES-self._dropTimes, 0)
end

--是否通关
function CrusadeData:hasPassStage()

    --只要战胜最后排三个位置任意之一即可 
    if self._battleFieldSample[MAX_POSITION] and self._battleFieldSample[MAX_POSITION].hp_rate <= 0 then
        return true
    elseif self._battleFieldSample[MAX_POSITION-1] and self._battleFieldSample[MAX_POSITION-1].hp_rate <= 0 then
        return true
    elseif self._battleFieldSample[MAX_POSITION-2] and self._battleFieldSample[MAX_POSITION-2].hp_rate <= 0 then
        return true
    else
        return false
    end
    
end


function CrusadeData:hasPassAllStage()
    if self:hasPassStage() and self:getCurStage() == MAX_STAGE then
        return true
    else
        return false
    end

end


function CrusadeData:getLeftChallengeTimes()
    return self._leftChallengeTimes
end


return CrusadeData

