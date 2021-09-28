-- CityData

require "app.cfg.city_info"
require "app.cfg.city_common_event_info"
require "app.cfg.city_end_event_info"


local CityData = class("CityData")

-- 城池的状态，1表示尚未攻占，2表示已攻占尚未巡逻，3表示攻占后可巡逻，4表示可丰收，5表示有暴动
CityData.CITY_NEED_ATTACK = 1
CityData.CITY_NEED_PATROL = 2
CityData.CITY_PATROLLING = 3
CityData.CITY_HARVEST = 4
CityData.CITY_RIOT = 5

CityData.MAX_CITY_NUM = 0

-- 巡逻时长的映射，写死
local hours = {4, 8, 12}
-- 收益时间间隔，写死
local mins = {30, 20, 10}

function CityData:ctor()

    self._cityData = {}
    self._myCurIEEvent = {}
    
    -- 好友列表时间戳
    self._friendTimeStamp = 0
    
    self:resetData()
    
end

function CityData:resetData()
    
--    self._cityData.cities = {
--        {id=1, isLock=true, start=0, ie={}, re={}},
--        {id=2, isLock=true, start=0, ie={}, re={}},
--        {id=3, isLock=true, start=0, ie={}, re={}},
--        {id=4, isLock=true, start=0, ie={}, re={}},
--        {id=5, isLock=true, start=0, ie={}, re={}},
--    }
    
    self._cityData.cities = {}
    local function addCity(cityInfo)
        self._cityData.cities[cityInfo.id] = {id=cityInfo.id, isLock=true, start=0, ie={}, re={}, level = 0}
    end
    
    for i=1, city_info.getLength() do
        addCity(city_info.indexOf(i))
    end
    
    CityData.MAX_CITY_NUM = table.nums(self._cityData.cities)
    
    -- 领地的用户id, 默认是我自己的
    self._cityData._id = 0
    -- 领地用户今日已使用互助次数
    self._cityData._assist_count = self._cityData._assist_count or 0
    -- 时间倍数，测试用
    self._cityData._speed = 1
    -- 当前的互动（暴动）事件
    self._curIEEvent = {}
    
end

function CityData:resetMyCity()
    
    -- 用户id
    self._cityData._id = G_Me.userData.id
    
    -- 当前的互动（暴动）事件，直接改成我自己的
    self._curIEEvent = self._myCurIEEvent or {}

    -- 直接取我自己的数据重新刷新，不考虑数据缺失的情况，因为登录游戏后已经获取了
    self._cityData.cities = self._cityData._myself or {}
    
    -- 然后刷新数据
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_INFO, nil, false)
    
end

-- 存储数据，主要指获取领地的数据
function CityData:setCityInfo(message)
    self:resetData()

    -- 测试用倍数
    self._cityData._speed = message.speed
    -- 用户id
    self._cityData._id = message.id
    -- 好友帮助次数, 第一次为空一定是我自己的
    self._cityData._assist_count = self:isMyCity() and message.assist_count or self._cityData._assist_count

    for i=1, #message.city do
        self:updateOneCityInfo(message.city[i])
    end
    
    -- 默认添加下一个可以攻打的领地，直到没有领地为止
    local cityIndex = #message.city + 1
    if cityIndex <= #self._cityData.cities then
        self:unlockCity(cityIndex)
    end

    -- 我自己城池的缓存
    if self:isMyCity() then
        -- 累计巡逻时间
        self._cityData._totalPatrolTime = rawget(message, "totaltime") or 0

        -- 保存一下cities，注意这里要保存已经转型好的数据，而不是原始数据message，因为服务器没有发送各个状态的数据在里面，需要我们自己记录
        -- 这里存储的是引用，数据会自动同步更新
        self._cityData._myself = self._cityData.cities
        
        -- 同时存储一下暴动的事件table，这里也是为了当前我方自己的数据的计算
        self._myCurIEEvent = self._curIEEvent
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_INFO, nil, false)
    
    if self:isMyCity() then
        G_PlatformProxy:addLocalNotications()
    end
end

-- 这里主要更新有巡逻时间的情况，每一次请求领地数据时间是会变化的(逐渐减少)
function CityData:updateCityInfo()
    
    local cities = self._cityData.cities
    
    -- 当前时间，取自服务器
    local curTime = G_ServerTime:getTime()
    
    for i=1, #cities do
        local city = cities[i]
        
        if not city.isLock and city.state ~= CityData.CITY_NEED_ATTACK and city.state ~= CityData.CITY_NEED_PATROL then
                    
            -- 表示有巡逻
            if city.start > 0 then
                city.state = CityData.CITY_PATROLLING

                -- 巡逻时间，这里是倒计时，根据表中(hours)中配置的时间（小时）减去当前时间与服务器开始巡逻时间的间隔
                city.patrol_time = math.max(0, hours[city.duration] * 3600 / self._cityData._speed - (curTime - city.start))

                if city.patrol_time <= 0 then
                    -- 倒计时已经结束
                    city.state = CityData.CITY_HARVEST
                    city.patrol_time = 0
                end
            end

            local ieLastResolve = nil
            
            -- 检查暴动事件是否过期
            for j=1, #city.ie do
                -- 结束的暴动
                if city.ie[j]["end"] > 0 then
                    city.ie[j].expired = false
                    if ieLastResolve and city.ie[ieLastResolve+1] then
                        if city.ie[ieLastResolve]["end"] < city.ie[ieLastResolve+1].start then
                            city.ie[ieLastResolve+1].expired = false
                        end
                    end
                    ieLastResolve = j
                else
                    city.ie[j].expired = true
                end
            end
            
            if not ieLastResolve then
                if city.ie[1] then
                    city.ie[1].expired = false
                    if curTime >= city.ie[1].displayTime then
                        self._curIEEvent[city.id] = city.ie[1]
                    end
                end
            else
                for s=ieLastResolve+1, #city.ie do
                    if city.ie[ieLastResolve]["end"] < city.ie[s].start then
                        city.ie[s].expired = false
                        if curTime >= city.ie[s].displayTime then
                            self._curIEEvent[city.id] = city.ie[s]
                        end
                        break
                    end
                end
            end
            
            -- 如果直接丰收了就不检查暴动了
            if city.state ~= CityData.CITY_HARVEST then
                -- 检查是否有暴动
                city.state = self._curIEEvent[city.id] and CityData.CITY_RIOT or CityData.CITY_PATROLLING
            else    -- 已经丰收的话就没有暴动事件了
                self._curIEEvent[city.id] = nil
            end
        end
    end
    
    -- 更新下好友的数据
    self:updateCityFriendInfo()
    
    -- 这里还需要计算一下是否需要更新好友帮助次数（过12点）
    local _date =  G_ServerTime:getDate()
    
    if not self._date then
        self._date = _date
    elseif self._date ~= _date then
        -- 表示过了12点了，此时清空已帮助好友次数，注意这里_assist_count存储的是已经帮助过的次数，是正数
        self._cityData._assist_count = 0
        self._date = _date
    end
    
end

function CityData:updateCityFriendInfo()
    
    -- 更新好友的数据
    if self._friendData then
        
        for i=1, #self._friendData.id do
            local friendId = self._friendData.id[i]
            if friendId == self:getCityUserId() then
                -- 有多少城池数
                self._friendData.num[i] = self:getCityNum()
                self._friendData.patrol[i] = self:getCityNumThatIsPatrolling()
                self._friendData.riot[i] = self:getCityNumThatHasRiot()
                break
            end
        end
        
    end
    
end

function CityData:updateOneCityInfo(city)
    
    local _city = self._cityData.cities[city.id]
    assert(_city, "Could not find the city with id: "..city.id)
    
    _city.id = city.id
    _city.isLock = false
    _city.duration = city.duration
    _city.efficiency = city.efficiency
    _city.kac = city.kac
    _city.start = city.start
    _city.re = rawget(city, "re") or {}
    _city.ie = rawget(city, "ie") or {}
    _city.reward = rawget(city, "reward") or {}
    _city.skac = rawget(city, "skac") or 0
    _city.sduration = rawget(city, "sduration") or 0
    _city.sefficiency = rawget(city, "sefficiency") or 0
    _city.level = rawget(city, "level") or 0 -- 领地科技等级

    -- 表示有巡逻
    if _city.start > 0 then
        _city.state = CityData.CITY_PATROLLING

        -- 巡逻时间，这里是倒计时，根据表中(hours)中配置的时间（小时）减去当前时间与服务器开始巡逻时间的间隔
        _city.patrol_time = math.max(0, hours[_city.duration] * 3600 / self._cityData._speed - (G_ServerTime:getTime() - _city.start))

        if _city.patrol_time <= 0 then
            -- 倒计时已经结束，可丰收
            _city.state = CityData.CITY_HARVEST
            _city.patrol_time = 0
        end
        
        -- 自己添加巡逻时间
        for j=1, #_city.re do
            -- 每一次的事件开启时间等于巡逻开始时间+巡逻时间/资源事件次数
            _city.re[j].start = _city.start + hours[_city.duration] * 3600 / self._cityData._speed / #_city.re * (j-1)
            -- 资源事件需要有一个显示用的时间，因为不同的事件用的时间不一样
            _city.re[j].displayTime = _city.re[j].start
        end
        
        for j=1, #_city.ie do
            -- 互动事件也需要displayTime，而且解决与否时间显示不同
            _city.ie[j].displayTime = _city.ie[j].start
            
            -- 插入一个资源事件，主要是用来播放暴动事件的滚动文字
            if _city.ie[j]["end"] > 0 then
                self:insertEvent({
                    id = city_info.get(_city.id).interaction_event_team,
                    start = _city.ie[j]['end'],
                    displayTime = _city.ie[j]['end'],
                    name = _city.ie[j].name
                }, _city.id)
            end
        end
        
        -- 最后有一个丰收事件
        self:insertEvent({
            id = -1,    -- city_end_event_info没有id
            start = _city.start,
            displayTime = _city.start + hours[_city.duration] * 3600 / self._cityData._speed,
            name = "",
            isHarvest = true,
        }, _city.id)

    -- 添加巡逻武将
    else
        _city.state = CityData.CITY_NEED_PATROL
        _city.patrol_time = 0
    end
        
end

-- 更新累计巡逻时间
function CityData:updateTotalPatrolTime(time)
    self._cityData._totalPatrolTime = time or 0
end

-- 更新领地科技等级
function CityData:updateCityTechLevel(cityId, level)
    if cityId then
        local city = self:getCityByIndex(cityId)
        city.level = level or 0

        G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_TECH_LEVEL_UP", {city = city_info.get(cityId).name, num = level}))
    end
end

-- 存储数据，主要指获取领地的数据
function CityData:setCityPatrol(message)
    
    self._curIEEvent[message.city.id] = nil
    
    self:updateOneCityInfo(message.city)
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_INFO, nil, false)
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_PATROL, nil, false)
    
    if self:isMyCity() then
        G_PlatformProxy:addLocalNotications()
    end
    
end

function CityData:setCityAssist(message, index)
    
    if message.ret == NetMsg_ERROR.RET_OK then
    
        -- 当日帮助好友镇压次数+1
        self:addAssistCount(1)

        -- 镇压成功，伪造一个事件到到列表
        local endTime = G_ServerTime:getTime()+1

        -- 需要修改互动事件
        local curIEEvent = self._curIEEvent[index]
        assert(curIEEvent, "Could not find the current IE event with index: "..index)

        -- 主要是修改结束时间，其他可以暂时不管
        curIEEvent["end"] = endTime
        curIEEvent.name = G_Me.userData.name
        
        self._curIEEvent[index] = nil
        
        -- 这里要加到显示列表里，不能直接加到数据列表里
        self:insertEvent({
            id = city_info.get(index).interaction_event_team,
            start = 0,  -- 开始时间就不取了，也用不到，比较麻烦
            displayTime = endTime,
            name = G_Me.userData.name
        }, index)

        -- 再次刷新数据
        self:updateCityInfo()
    
    elseif message.ret == NetMsg_ERROR.RET_RIOT_ASSISTED then
        
        -- 已被别人镇压，伪造一个事件到到列表
        local endTime = G_ServerTime:getTime()+1

        -- 需要修改互动事件
        local curIEEvent = self._curIEEvent[index]
        assert(curIEEvent, "Could not find the current IE event with index: "..index)

        -- 主要是修改结束时间，其他可以暂时不管
        curIEEvent["end"] = endTime
        
        self._curIEEvent[index] = nil
        
        self:updateCityInfo()
        
    end
    
end

function CityData:setCityAssisted(message)
    
    -- 新情况，如果当前收到此通知时不在自己的领地，则curIEEvent其实是别人（好友）的暴动，此时清除的是好友的暴动，但是自己的其实没有清
    -- 暴动一定是解决当前未解决的，并且是我自己的，进入别人的领地所看到的暴动事件不会同步更新
    local curIEEvent = self._myCurIEEvent[message.city_id]
    if not curIEEvent then return end
    
    -- 这里标记这个暴动解决了，end的表示有解决时间了
    curIEEvent['end'] = G_ServerTime:getTime()
    curIEEvent.name = message.name
    
    -- 插入一个资源事件，主要是用来播放滚动文字
    self:insertEvent({
        id = city_info.get(message.city_id).interaction_event_team,
        start = curIEEvent['end'],
        displayTime = curIEEvent['end'],
        name = message.name
    }, message.city_id, true)   -- 最后一个参数表示是不是我自己的城池
    
    self._myCurIEEvent[message.city_id] = nil
    
    -- 之所以要判断是不是我自己的城池是因为可能这个时候在别人的城市界面，主要数据都是别人城池的，所以别人的不刷新
    if self:isMyCity() then
        -- 再次刷新数据
        self:updateCityInfo()

        -- 通知城池更新状态
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_ASSISTED, nil, false)

        -- 主界面更新
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_INFO, nil, false)
    end
    
end

function CityData:setOnekeyPatrolConfig(config)
    for i, v in ipairs(config) do
        local data = self:getCityByIndex(v.city_id)
        data.skac = v.hero_id
        data.sduration = v.duration_type
        data.sefficiency = v.interval_type
    end
end

function CityData:resetCityInfo(index)
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    city.id = index
    city.isLock = false
    city.duration = 0
    city.efficiency = 0
    city.kac = 0
    city.start = 0
    city.re = {}
    city.ie = {}
    city.reward = {}
    
    city.state = CityData.CITY_NEED_PATROL
    city.patrol_time = 0
end

function CityData:resetAllHarvestCityInfo()
    for i, v in ipairs(self._cityData.cities) do
        if v.state == CityData.CITY_HARVEST then
            self:resetCityInfo(i)
        end
    end
end

function CityData:unlockCity(index)
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    if city.isLock then
        city.id = index
        city.isLock = false
        city.state = CityData.CITY_NEED_ATTACK
    end
    
end

-- 各种获取数据的接口

-- 获取累计巡逻时间
function CityData:getTotalPatrolTime()
    return self._cityData._totalPatrolTime
end

-- 获取领地列表，包含从编号从1~5的所有城池，以下标1~5存储
function CityData:getCityList()
    
    -- 因为有计时的关系，所以获取数据前更新下数据的时间
    self:updateCityInfo()
    
    return self._cityData.cities
end

function CityData:getCityByIndex(index)
    
    -- 因为有计时的关系，所以获取数据前更新下数据的时间
    self:updateCityInfo()
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    return city
end

-- 获取可巡逻的城市
function CityData:getCityNeedPatrolByIndex(index)
    local curNeedPatrolIndex = 0
    local cities = self._cityData.cities

    for i, v in ipairs(cities) do
        if v.state == CityData.CITY_NEED_PATROL then
            curNeedPatrolIndex = curNeedPatrolIndex + 1
            if curNeedPatrolIndex == index then
                return v
            end
        end
    end

    return nil
end

function CityData:getCityNum()
    
    local cities = self._cityData.cities
    
    for i=1, #cities do
        local city = cities[i]
        if city.state == CityData.CITY_NEED_ATTACK then
            return i-1
        end
    end
    
    return #cities
end

function CityData:getCityNumNeedPatrol()
    local cities = self._cityData.cities
    local num = 0

    for i, v in ipairs(cities) do
        if v.state == CityData.CITY_NEED_PATROL then
            num = num + 1
        end
    end

    return num
end

function CityData:getCityNumThatIsPatrolling()
    
    local cities = self._cityData.cities
    
    local count = 0
    for i=1, #cities do
        local city = cities[i]
        if city.state == CityData.CITY_PATROLLING or 
            city.state == CityData.CITY_RIOT then
            count = count + 1
        end
    end
    
    return count
end

function CityData:getCityNumThatHasRiot()
    
    local cities = self._cityData.cities
    
    local count = 0
    for i=1, #cities do
        local city = cities[i]
        if city.state == CityData.CITY_RIOT then
            count = count + 1
        end
    end
    
    return count
end

-- 获取当前城池巡逻武将
function CityData:getPatrolKnightIDByIndex(index)
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    return city.kac
    
end

-- 获取当前城池巡逻剩余时间
function CityData:getRemainPatrolTimeByIndex(index)
    
    self:updateCityInfo()
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    return city.patrol_time
end

function CityData:durationToSeconds(duration) return hours[duration] * 3600 / self._cityData._speed end
function CityData:efficiencyToSeconds(efficiency) return mins[efficiency] * 60 / self._cityData._speed end

-- 获取当前城池巡逻时间
function CityData:getPatrolDurationByIndex(index)
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    return city.duration
    
end

-- 获取当前城池巡逻效率
function CityData:getPatrolEfficiencyByIndex(index)
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    return city.efficiency
    
end

-- 打包发送武将advance_code, duration, efficiency
function CityData:getPatrolInfoByIndex(index)
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    return city.kac, city.duration, city.efficiency
    
end

-- 获取当前城池丰收奖励数，这里返回的reward是一个数组，下标对应city_end_event_info的type_1, type_2 ...
function CityData:getHarvestRewardSizeByIndex(index)
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    return city.reward
    
end

-- 获取当前剩余帮助次数，最小为0
function CityData:getRemainAssistCount(level)
    return math.max(0, G_Me.vipData:getData(19).value - self:getAssistCount())
end

-- 是否还能帮助好友镇压
function CityData:hasAbilityToAssist() return self:getRemainAssistCount() > 0 end

-- 获取下一次领奖剩余时间
function CityData:getNextAwardTime(index)
    
    self:updateCityInfo()
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    local efficiency = city.efficiency
    local patrolTime = city.patrol_time
    
    local countdown = patrolTime % (self:efficiencyToSeconds(efficiency))
    
    return patrolTime == 0 and 0 or (countdown == 0 and self:efficiencyToSeconds(efficiency) or countdown)
    
end

function CityData:_getCityAward(index)
    -- 合并事件奖励和丰收奖励
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    local awards = {}
    local function addEventAward(awardId, multiple)
        local award = city_common_event_info.get(awardId)
        assert(award, "Could not find the award in common_event with id: "..awardId)
        
        local _type = award.type
        local _value = award.value
        local _size = award.size * multiple
        local _extraSize = award.size * (multiple - 1)
        if _type ~= 0 then
            local oldAward = awards[tostring(_type).."_".._value]
            if not oldAward then
                awards[tostring(_type).."_".._value] = {type=_type, value=_value, size=_size, extraSize = _extraSize}
            else
                oldAward.size = oldAward.size + _size
                oldAward.extraSize = oldAward.extraSize + _extraSize
            end
        end
    end
    
    local function addHarvestAward()
        
        local cityEndInfo = city_end_event_info.get(city.kac, city.duration, city.efficiency)
        assert(cityEndInfo, "Could not find the city_end_info with advance_code: "..city.kac.." duration: "..city.duration.." efficiency: "..city.efficiency)
        
        for i=1, #city.reward do
            local _type = cityEndInfo['type_'..i]
            local _value = cityEndInfo['value_'..i]
            local _size = city.reward[i]
            if _type ~= 0 then
                local oldAward = awards[tostring(_type).."_".._value]
                if not oldAward then
                    awards[tostring(_type).."_".._value] = {type=_type, value=_value, size=_size}
                else
                    oldAward.size = oldAward.size + _size
                end
            end
        end
    end
    
    -- 互动事件，互动事件必须解决才有奖励领取
    for i=1, #city.ie do
        if city.ie[i]["end"] > 0 then
            local multiple = math.max(rawget(city.ie[i], "times") or 1, 1)
            addEventAward(city.ie[i].id, multiple)
        end
    end
    
    -- 添加资源事件
    for i=1, #city.re do
        if city.re[i].id ~= -1 then     -- -1是专门定义的丰收事件
            local multiple = math.max(rawget(city.re[i], "times") or 1, 1)
            addEventAward(city.re[i].id, multiple)
        end
    end
    
    -- 添加丰收事件
    addHarvestAward()

    return awards
end

-- 获取总奖励(单个城市)
function CityData:getAllCityAwardByIndex(index)
    
    self:updateCityInfo()
    
    local awards = self:_getCityAward(index)
    
    local _awards = {}
    for k, v in pairs(awards) do
        _awards[#_awards+1] = v
    end
    
    table.sort(_awards, function(a, b)
        return a.type < b.type or (a.type == b.type and a.value < b.value)
    end)
    
--    dump(_awards)
    
    return _awards
end

-- 获取所有城市的所有奖励
function CityData:getAllCityAwards()
    self:updateCityInfo()

    local totalAwards = {}
    for i = 1, #self._cityData.cities do
        if self._cityData.cities[i].state == CityData.CITY_HARVEST then
            local award = self:_getCityAward(i)
            for k, v in pairs(award) do
                if totalAwards[k] then
                    totalAwards[k].size = totalAwards[k].size + v.size
                    totalAwards[k].extraSize = totalAwards[k].extraSize + v.extraSize
                else
                    totalAwards[k] = v
                end
            end
        end
    end

    -- return the array-type table, not the key-value-type table
    local returnList = {}
    for k, v in pairs(totalAwards) do
        returnList[#returnList + 1] = v
    end

    table.sort(returnList, function(a, b)
        return a.type < b.type or (a.type == b.type and a.value < b.value)
    end)

    return returnList
end

function CityData:setAutoUpdateEnabled(enable)
    self._autoUpdateEnabled = enable
end

function CityData:isAutoUpdate()
    return self._autoUpdateEnabled
end

function CityData:isMyCity()
    return self._cityData._id == G_Me.userData.id
end

function CityData:getCityUserId()
    return self._cityData._id
end

function CityData:getAssistCount()
    return self._cityData._assist_count
end

function CityData:addAssistCount(count)
    self._cityData._assist_count = self._cityData._assist_count + count
end

-- 是否有城池需要巡逻
function CityData:needPatrol()
    
    self:updateCityInfo()
    
    for i=1, #self._cityData.cities do
        local city = self._cityData.cities[i]
        if city.state == CityData.CITY_NEED_PATROL then
            return true
        end
    end
    
    return false
end

-- 是否所有已攻占城池都需要巡逻
function CityData:needPatrolAll()
    self:updateCityInfo()

    for i=1, #self._cityData.cities do
        local city = self._cityData.cities[i]

        if city.isLock or city.state ~= CityData.CITY_NEED_PATROL then
            return false
        end
    end

    return true
end

-- 是否有城池需要丰收
function CityData:needHarvest()
    
    self:updateCityInfo()
    
    for i=1, #self._cityData.cities do
        local city = self._cityData.cities[i]
        if city.state == CityData.CITY_HARVEST then
            return true
        end
    end
    
    return false
end

-- 是否有暴动
function CityData:hasRiot(index)
    
    self:updateCityInfo()
    
    return self._curIEEvent[index]
end

function CityData:needHarvestByIndex(index)

    self:updateCityInfo()
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    return city.state == CityData.CITY_HARVEST
    
end

-- 是否有事件，这里检查的是资源事件和互动事件
function CityData:nextEvent(index)
    
    self:updateCityInfo()
    
    local ieEvent = nil
    local cities = self._cityData.cities
    local curTime = G_ServerTime:getTime()
    
    -- 直接取当前的互动（暴动）事件
    if self._curIEEvent[index] and not rawget(self._curIEEvent[index], "isDone") then
        self._curIEEvent[index].isDone = true
        ieEvent = self._curIEEvent[index]
    end
    
    local reEvent = nil
    for i=1, #cities[index].re do
        if not rawget(cities[index].re[i], "isDone") and curTime >= cities[index].re[i].displayTime then
            -- 表示有资源事件
            cities[index].re[i].isDone = true
            reEvent = cities[index].re[i]
            break
        end
    end
    
    return ieEvent, reEvent
    
end

-- 返回当前时间节点前的事件
function CityData:previousEvent(index)
    
    self:updateCityInfo()
    
    local ieEvent = {}
    local cities = self._cityData.cities
    local curTime = G_ServerTime:getTime()
    for i=1, #cities[index].ie do
        if cities[index].ie[i].displayTime < curTime and not rawget(cities[index].ie[i], "expired") then
            -- 表示有暴动
            cities[index].ie[i].isDone = true
            ieEvent[#ieEvent+1] = cities[index].ie[i]
        end
    end
    
    local reEvent = {}
    for i=1, #cities[index].re do
        if cities[index].re[i].displayTime <= curTime then
            -- 表示有资源事件
            cities[index].re[i].isDone = true
            reEvent[#reEvent+1] = cities[index].re[i]
        end
    end
    
    return ieEvent, reEvent
    
end

-- 添加事件至资源事件层
function CityData:insertEvent(event, index, isMyCity)
    
    local cities = isMyCity and self._cityData._myself or self._cityData.cities
    local reEvent = cities[index].re
    -- 插入事件至合适的时间位置
    for i=1, #reEvent do
        if reEvent[i].displayTime > event.displayTime then
            table.insert(reEvent, i, event)
            return
        end
    end
    
    reEvent[#reEvent+1] = event
    
end

function CityData:isPatrollingThisCity(index)
    
    self:updateCityInfo()
    
    local city = self._cityData.cities[index]
    assert(city, "Could not find the city with id: "..index)
    
    return city.state == CityData.CITY_PATROLLING or city.state == CityData.CITY_RIOT
    
end

function CityData:isPatrollingThisKnight(knightId)
    
    local cities = self._cityData.cities
    for i=1, #cities do
        local city = cities[i]
        if city.kac and city.kac ~= 0 and knight_info.get(city.kac).advance_code == knight_info.get(knightId).advance_code then
            return true
        end
    end
    
    return false
end

function CityData:needFriendList()
    
    local cooldown = 30
    
    if not self._friendData or self._friendTimeStamp == 0 or G_ServerTime:getTime() - self._friendTimeStamp >= cooldown then
        return true
    else
        return false
    end
end

function CityData:getFriendList(callback)

    -- 是否需要请求数据依据CD时间，未到时间则直接读取缓存
    if self:needFriendList() then
        
        -- 请求好友数据
        local friends = G_Me.friendData:getFriendList()
        local _friends = {}
        local FunctionLevelConst = require("app.const.FunctionLevelConst")
        for i=1, #friends do
            if friends[i].level >= function_level_info.get(FunctionLevelConst.CITY_PLUNDER).level then
                _friends[#_friends+1] = friends[i].id
            end
        end
        
        G_HandlersManager.cityHandler:sendCityCheck(_friends)
        
        -- 这里需要先将事件移除，因为回调函数中用到了callback，在断线重连的情况下可能会过期，导致callback中的一些变量为nil，报错
        uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CITY_CHECK)

        -- 收到消息则更新界面
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_CHECK, function(_, message)
            
            self._friendTimeStamp = G_ServerTime:getTime()
            self._friendData = message
            
            if callback then
                callback(message)
            end
            
            -- 用完就删除，不需要保留
            uf_eventManager:removeListenerWithTarget(self)
            
        end, self)
        
    else
        if callback then
            callback(self._friendData)
        end
    end

end

return CityData