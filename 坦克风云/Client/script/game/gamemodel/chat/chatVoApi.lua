require "luascript/script/game/gamemodel/chat/chatVo"

chatVoApi = {
    allChatVo = {}, -- 3个table数据：1为世界，世界里又分为各个语言，有几种语言就有几类 2为私聊，3为联盟
    showNum = 30,
    hasNewData = {},
    maxMore = {},
    indexTab = {},
    isReload = false,
    selectedLanguage = "all",
    isNewPrivateMsg = 1, --是否有私聊信息，有点开面板闪光,-1有，1没有
    chatLimitEndTime = 0, --被其他玩家屏蔽多了限制发言结束的时间戳
    lastTabIndex = 0, --上次关闭面板在哪个页签,0 世界，1 私聊，2 军团
    lastMessage = {}, --最后3次发送的聊天内容，目前只存3条
    translateData = {switchtime = 0, type = 1}, --翻译方式, type1是google翻译, 当google翻译被屏蔽之后启用type2百度翻译, switchtime记录切换时间, 切换百度翻译10分钟之后再切回来
    chatUnSendMsg = nil, --type0:世界，type1:军团，type2:私聊
}

function chatVoApi:clear()
    if self.allChatVo ~= nil then
        for k, v in pairs(self.allChatVo) do
            self.allChatVo[k] = nil
        end
        self.allChatVo = nil
    end
    self.allChatVo = {}
    self.hasNewData = {}
    self.maxMore = {}
    self.indexTab = {}
    self.isReload = false
    self.selectedLanguage = "all"
    self.isNewPrivateMsg = 1
    self.chatLimitEndTime = 0
    self.lastTabIndex = 0
    self.lastMessage = {}
    self.chatUnSendMsg = nil
end
function chatVoApi:clearByType(type)
    if self.allChatVo ~= nil then
        if self.allChatVo[type] ~= nil then
            for k, v in pairs(self.allChatVo[type]) do
                self.allChatVo[type][k] = nil
            end
            self.allChatVo[type] = nil
        end
    end
    self.hasNewData["t0"] = true
    self.hasNewData["t10"] = true
    self.hasNewData["t11"] = true
    self.hasNewData["t12"] = true
    self.hasNewData["t13"] = true
    self.hasNewData["t14"] = true
    -- self.hasNewData["t15"]=true
    self.hasNewData["t16"] = true
    self.hasNewData["t10000"] = true
    self.indexTab[1] = 0
    self.indexTab[10000] = 0
    self.isReload = true
end
function chatVoApi:getLastTabIndex()
    return self.lastTabIndex
end
function chatVoApi:setLastTabIndex(lastTabIndex)
    self.lastTabIndex = lastTabIndex
end

function chatVoApi:getIsReload()
    return self.isReload
end
function chatVoApi:setIsReload(flag)
    self.isReload = flag
end

function chatVoApi:getChatLimitEndTime()
    return self.chatLimitEndTime
end
function chatVoApi:setChatLimitEndTime(data)
    if data then
        if data.nst then
            self.chatLimitEndTime = data.nst or 0
        else
            self.chatLimitEndTime = 0
        end
    end
end

function chatVoApi:getIsNewPrivateMsg()
    return self.isNewPrivateMsg
end
function chatVoApi:setIsNewPrivateMsg(isNewPrivateMsg)
    self.isNewPrivateMsg = isNewPrivateMsg
end

function chatVoApi:getSelectedLanguage()
    return self.selectedLanguage
end
function chatVoApi:setSelectedLanguage(language)
    self.selectedLanguage = language
end

function chatVoApi:isMultiLanguage(cType)
    if platCfg.platCfgChatMultiLan[G_curPlatName()] then
        local platLanCfg = platCfg.platCfgLanType[G_curPlatName()]
        if SizeOfTable(platLanCfg) > 1 and (cType == 1 or cType == 0 or cType == 10000) then
            return true
        end
    end
    return false
end

function chatVoApi:addOneChat(cType, sender, senderName, reciver, reciverName, params)
    if cType > 3 and cType < 10000 then
        do return end
    end
    
    -- local num=self:getChatNum(cType)
    -- if num>=self:getShowNum() then
    -- table.remove(self.allChatVo[cType],1)
    -- self:setMaxMore(cType,true)
    -- end
    
    local subType = params.subType or 1
    local contentType = params.contentType or 1
    local content = ""
    --屏蔽在世界频道显示私聊信息
    if subType == 2 and cType == 1 then
        do return end
    end
    if subType == 4 and contentType == 3 then
        local msgData = params.message
        local isSystem = params.isSystem
        -- print("isSystem",isSystem)
        if isSystem and tostring(isSystem) == "1" then
            if type(msgData) == "table" then
                local key = msgData.key or ""
                local param = msgData.param or {}
                local systemType = tonumber(string.sub(key, -2, -1)) or tonumber(string.sub(key, -1, -1))
                -- print("key",key)
                -- print("systemType",systemType)
                -- print("param[3]",param[3])
                local addStr
                if systemType then
                    -- chatSystemMessage8="【红方军团名】与【蓝方军团名】即将在【战场名】开始对战。",
                    -- chatSystemMessage9="【红方军团名】与【蓝方军团名】在【战场名】的战斗结束，【获胜方军团名】取得了胜利，开始享受为期24小时的资源增产Buff。",
                    -- chatSystemMessage10="今晚【战场开战时间】，【红方军团名】与【蓝方军团名】将在【战场名】展开残酷的对决。",
                    -- chatSystemMessage26="我军团报名的{1}，未遇敌手，将于今晚{2}，直接占领。",
                    -- chatSystemMessage27="{1}战斗结束，{2}取得胜利，开始享受为期{3}小时的资源增产Buff。",
                    if systemType == 8 then
                        local redName = param[1] or ""
                        local blueName = param[2] or ""
                        local warIndex = param[3] or 1
                        local placeStr = ""
                        if base.allianceWar2Switch == 1 and allianceWar2Cfg and allianceWar2Cfg.city and allianceWar2Cfg.city[warIndex] and allianceWar2Cfg.city[warIndex].name then
                            placeStr = getlocal(allianceWar2Cfg.city[warIndex].name)
                        else
                            placeStr = getlocal("allianceWar_cityName_"..warIndex)
                        end
                        param = {redName, blueName, placeStr}
                    elseif systemType == 9 then
                        local redName = param[1] or ""
                        local blueName = param[2] or ""
                        local warIndex = param[3] or 1
                        local placeStr = ""
                        if base.allianceWar2Switch == 1 and allianceWar2Cfg and allianceWar2Cfg.city and allianceWar2Cfg.city[warIndex] and allianceWar2Cfg.city[warIndex].name then
                            placeStr = getlocal(allianceWar2Cfg.city[warIndex].name)
                        else
                            placeStr = getlocal("allianceWar_cityName_"..warIndex)
                        end
                        local victoryName = param[4] or ""
                        local lastTime = param[5] or 0
                        local hourStr = math.floor(lastTime / (3600))
                        local redMVP = param[6] or ""
                        local blueMVP = param[7] or ""
                        if redMVP and redMVP ~= "" and blueMVP and blueMVP ~= "" then
                            addStr = getlocal("chatSystemMessage9_1", {redMVP, blueMVP})
                        end
                        param = {redName, blueName, placeStr, victoryName, hourStr}
                    elseif systemType == 10 then
                        local warTime = param[1] or 0
                        local timeStr = G_getTimeStr(warTime - G_getWeeTs(warTime))
                        local redName = param[2] or ""
                        local blueName = param[3] or ""
                        local warIndex = param[4] or 1
                        local placeStr = ""
                        if base.allianceWar2Switch == 1 and allianceWar2Cfg and allianceWar2Cfg.city and allianceWar2Cfg.city[warIndex] and allianceWar2Cfg.city[warIndex].name then
                            placeStr = getlocal(allianceWar2Cfg.city[warIndex].name)
                        else
                            placeStr = getlocal("allianceWar_cityName_"..warIndex)
                        end
                        param = {timeStr, redName, blueName, placeStr}
                    elseif systemType == 14 or systemType == 15 or systemType == 16 or systemType == 19 or systemType == 20 or systemType == 21 or systemType == 22 or systemType == 23 or systemType == 24 then
                        local name = param[1] or ""
                        local serverName = param[2] or ""
                        param = {serverName, name}
                    elseif systemType == 25 then
                        local aName = param[1] or ""
                        local leaderName = param[2] or ""
                        param = {aName, leaderName}
                    elseif systemType == 26 then
                        local warIndex = param[1] or 1
                        local warTime = param[2] or 0
                        local timeStr = G_getTimeStr(warTime - G_getWeeTs(warTime))
                        local placeStr = ""
                        if allianceWar2Cfg and allianceWar2Cfg.city and allianceWar2Cfg.city[warIndex] and allianceWar2Cfg.city[warIndex].name then
                            placeStr = getlocal(allianceWar2Cfg.city[warIndex].name)
                        end
                        param = {placeStr, timeStr}
                    elseif systemType == 27 then
                        local warIndex = param[1] or 1
                        local placeStr = ""
                        if allianceWar2Cfg and allianceWar2Cfg.city and allianceWar2Cfg.city[warIndex] and allianceWar2Cfg.city[warIndex].name then
                            placeStr = getlocal(allianceWar2Cfg.city[warIndex].name)
                        end
                        local victoryName = param[2] or ""
                        local lastTime = param[3] or 0
                        local hourStr = math.floor(lastTime / (3600))
                        param = {placeStr, victoryName, hourStr}
                    elseif systemType == 101 then
                        local point = param[data]
                        param = {point}
                    end
                end
                content = getlocal(key, param)
                if addStr and addStr ~= "" then
                    content = content..addStr
                end
            else
                content = msgData
            end
        elseif type(msgData) == "table" then
            local key = msgData.key or ""
            local param = msgData.param or {}
            if type(param) == "table" then
                if param.key and param.param then
                    if param.key == "rankName" then
                        param = playerVoApi:getRankName(param.param[1])
                    else
                        param = getlocal(param.key, param.param)
                    end
                else
                    for k, v in pairs(param) do
                        if type(v) == "table" then
                            if v.key and v.param then
                                if v.key == "rankName" then
                                    param[k] = playerVoApi:getRankName(v.param[1])
                                else
                                    if type(v.param) == "table" then
                                        if v.param.key and v.param.param then
                                            if v.param.param and type(v.param.param) == "table" and v.param.param.key and v.param.param.param then
                                                -- for i,j in pairs(v.param.param) do
                                                -- v.param.param[i]=getlocal(v.param.param.key,v.param.param.param)
                                                -- end
                                                v.param.param = {getlocal(v.param.param.key, v.param.param.param)}
                                            elseif v.param.param and type(v.param.param) == "table" then
                                                for m, n in pairs(v.param.param) do
                                                    if type(n) == "table" and n.key and n.param then
                                                        v.param.param[m] = getlocal(n.key, n.param)
                                                    end
                                                end
                                            end
                                            -- v.param[k]=getlocal(v.param.key,v.param.param)
                                            v.param = {getlocal(v.param.key, v.param.param)}
                                        else
                                            for m, n in pairs(v.param) do
                                                if type(n) == "table" and n.key and n.param then
                                                    if type(n.param) == "table" then
                                                        for i, j in pairs(n.param) do
                                                            if type(j) == "table" and j.key and j.param then
                                                                v.param[m][i] = getlocal(j.key, j.param)
                                                            end
                                                        end
                                                    end
                                                    v.param[m] = getlocal(n.key, n.param)
                                                end
                                            end
                                        end
                                    end
                                    param[k] = getlocal(v.key, v.param)
                                end
                            end
                        end
                    end
                end
            end
            content = getlocal(key, param)
        else
            content = msgData
        end
    else
        content = params.message
    end
    if content == nil then
        content = ""
    end
    local from = senderName
    local to = reciverName
    local color = G_ColorWhite
    
    if contentType then
        if contentType == 2 then
            color = G_ColorYellow
        end
        if contentType == 3 then
            from = ""
        end
    end
    --local msgData={isFormat=false}
    local width, height = self:getMessage(cType, subType, from, to, content, sender, params)
    local msgData = {width = width, height = height, color = color}
    
    local param = {}
    if params ~= nil then
        param = params
        param.level = params.level or 1
        param.rank = params.rank or 1
        param.power = params.power or 0
    end
    local time = 0
    if param.ts then
        time = param.ts
    else
        time = base.serverTime
        --time=os.time()
    end
    
    if self:isExist(cType, sender, content, contentType, param.report, time) then
        do return false end
    end
    
    local isMulti = self:isMultiLanguage(cType)
    if isMulti == true then
        local language = "all"
        local num = self:getChatNum(cType, language)
        if num >= self:getShowNum() then
            table.remove(self.allChatVo[cType][language], 1)
            self:setMaxMore(cType, true, language)
        end
        if self.indexTab[cType] == nil then
            self.indexTab[cType] = {}
        end
        if self.indexTab[cType][language] == nil then
            self.indexTab[cType][language] = 0
        end
        self.indexTab[cType][language] = self.indexTab[cType][language] + 1
        local showTab = cType
        if cType == 10000 then
            showTab = 1
        end
        local vo = chatVo:new()
        vo:initWithData(self.indexTab[cType][language], showTab, subType, contentType, content, sender, tostring(from), reciver, tostring(to), param, msgData, time)
        table.insert(self.allChatVo[cType][language], vo)
        
        local num = SizeOfTable(self.allChatVo[cType][language])
        vo.timeVisible = false
        if num == 1 then
            vo.timeVisible = true
        else
            local lastTime = self.allChatVo[cType][language][num - 1].time
            local nowTime = vo.time
            if nowTime - lastTime > 300 then
                vo.timeVisible = true
            end
        end
        
        if self.hasNewData == nil then
            self.hasNewData = {}
        end
        if self.hasNewData["t0"] == nil or type(self.hasNewData["t0"]) ~= "table" then
            self.hasNewData["t0"] = {}
        end
        if self.hasNewData["t1"] == nil or type(self.hasNewData["t1"]) ~= "table" then
            self.hasNewData["t1"] = {}
        end
        if self.hasNewData["t12"] == nil or type(self.hasNewData["t12"]) ~= "table" then
            self.hasNewData["t12"] = {}
        end
        if self.hasNewData["t13"] == nil or type(self.hasNewData["t13"]) ~= "table" then
            self.hasNewData["t13"] = {}
        end
        if self.hasNewData["t14"] == nil or type(self.hasNewData["t14"]) ~= "table" then
            self.hasNewData["t14"] = {}
        end
        -- if self.hasNewData["t15"]==nil or type(self.hasNewData["t15"])~="table" then
        -- self.hasNewData["t15"]={}
        -- end
        self.hasNewData["t0"]["all"] = true
        self.hasNewData["t1"]["all"] = true
        self.hasNewData["t12"]["all"] = true
        self.hasNewData["t13"]["all"] = true
        self.hasNewData["t14"]["all"] = true
        -- self.hasNewData["t15"]["all"]=true
        if cType == 10000 then
            if self.hasNewData["t10000"] == nil or type(self.hasNewData["t10000"]) ~= "table" then
                self.hasNewData["t10000"] = {}
            end
            self.hasNewData["t10000"]["all"] = true
        end
        if (subType == 4 and contentType == 3) or ((contentType == 1 or contentType == 2) and sender == playerVoApi:getUid()) then
            local platLanCfg = platCfg.platCfgLanType[G_curPlatName()]
            for k, v in pairs(platLanCfg) do
                local language2 = k
                local num = self:getChatNum(cType, language2)
                if num >= self:getShowNum() then
                    table.remove(self.allChatVo[cType][language2], 1)
                    self:setMaxMore(cType, true, language2)
                end
                if self.indexTab[cType] == nil then
                    self.indexTab[cType] = {}
                end
                if self.indexTab[cType][language2] == nil then
                    self.indexTab[cType][language2] = 0
                end
                self.indexTab[cType][language2] = self.indexTab[cType][language2] + 1
                local vo = chatVo:new()
                vo:initWithData(self.indexTab[cType][language2], showTab, subType, contentType, content, sender, tostring(from), reciver, tostring(to), param, msgData, time)
                table.insert(self.allChatVo[cType][language2], vo)
                local num = SizeOfTable(self.allChatVo[cType][language2])
                vo.timeVisible = false
                if num == 1 then
                    vo.timeVisible = true
                else
                    local lastTime = self.allChatVo[cType][language2][num - 1].time
                    local nowTime = vo.time
                    if nowTime - lastTime > 300 then
                        vo.timeVisible = true
                    end
                end
                
                self.hasNewData["t0"][language2] = true
                self.hasNewData["t1"][language2] = true
                self.hasNewData["t12"][language2] = true
                self.hasNewData["t13"][language2] = true
                self.hasNewData["t14"][language2] = true
                -- self.hasNewData["t15"][language2]=true
                if cType == 10000 then
                    self.hasNewData["t10000"][language2] = true
                end
            end
        else
            local language1 = params.language
            if language1 ~= nil and language1 ~= "" then
                local num = self:getChatNum(cType, language1)
                if num >= self:getShowNum() then
                    table.remove(self.allChatVo[cType][language1], 1)
                    self:setMaxMore(cType, true, language1)
                end
                if self.indexTab[cType] == nil then
                    self.indexTab[cType] = {}
                end
                if self.indexTab[cType][language1] == nil then
                    self.indexTab[cType][language1] = 0
                end
                self.indexTab[cType][language1] = self.indexTab[cType][language1] + 1
                local vo = chatVo:new()
                vo:initWithData(self.indexTab[cType][language1], showTab, subType, contentType, content, sender, tostring(from), reciver, tostring(to), param, msgData, time)
                table.insert(self.allChatVo[cType][language1], vo)
                local num = SizeOfTable(self.allChatVo[cType][language1])
                vo.timeVisible = false
                if num == 1 then
                    vo.timeVisible = true
                else
                    local lastTime = self.allChatVo[cType][language1][num - 1].time
                    local nowTime = vo.time
                    if nowTime - lastTime > 300 then
                        vo.timeVisible = true
                    end
                end
                
                self.hasNewData["t0"][language1] = true
                self.hasNewData["t1"][language1] = true
                self.hasNewData["t12"][language1] = true
                self.hasNewData["t13"][language1] = true
                self.hasNewData["t14"][language1] = true
                -- self.hasNewData["t15"][language1]=true
                if cType == 10000 then
                    self.hasNewData["t10000"][language1] = true
                end
            end
        end
        return true
    else
        local num = self:getChatNum(cType)
        if num >= self:getShowNum() then
            table.remove(self.allChatVo[cType], 1)
            self:setMaxMore(cType, true)
        end
        
        if self.indexTab[cType] == nil then
            self.indexTab[cType] = 0
        end
        self.indexTab[cType] = self.indexTab[cType] + 1
        
        local showTab = cType
        if cType == 10000 then
            showTab = 1
        end
        local vo = chatVo:new()
        vo:initWithData(self.indexTab[cType], showTab, subType, contentType, content, sender, tostring(from), reciver, tostring(to), param, msgData, time)
        table.insert(self.allChatVo[cType], vo)
        
        local num = SizeOfTable(self.allChatVo[cType])
        vo.timeVisible = false
        if num == 1 then
            vo.timeVisible = true
        else
            local lastTime = self.allChatVo[cType][num - 1].time
            local nowTime = vo.time
            if nowTime - lastTime > 300 then
                vo.timeVisible = true
            end
        end
        return true
    end
    
end

--------------------------------------------------------------------

function chatVoApi:savePrivateChatData(_jsonStr, _mkey)
    local MAX_NUM = 100
    local PREFIX = "chatLog"
    local SUFFIX = "@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
    
    local dataKey = PREFIX..MAX_NUM..SUFFIX
    local lastValue = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    if lastValue and string.len(lastValue) > 0 then
        for i = 1, MAX_NUM - 1 do
            local value = CCUserDefault:sharedUserDefault():getStringForKey(PREFIX..(i + 1)..SUFFIX)
            -- local chatData = G_Json.decode(value)
            -- if _mkey==chatData.mkey then
            -- do return end
            -- end
            CCUserDefault:sharedUserDefault():setStringForKey(PREFIX..i..SUFFIX, value)
            -- CCUserDefault:sharedUserDefault():flush()
        end
    else
        for i = 1, MAX_NUM do
            local key = PREFIX..i..SUFFIX
            local value = CCUserDefault:sharedUserDefault():getStringForKey(key)
            if value == nil or value == "" then
                dataKey = key
                break
                -- else
                -- local chatData = G_Json.decode(value)
                -- if _mkey==chatData.mkey then
                -- do return end
                -- end
            end
        end
    end
    
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey, _jsonStr)
    CCUserDefault:sharedUserDefault():flush()
end
function chatVoApi:deletePrivateChatData(_chatData, _privatePlayerUid)
    if _chatData == nil then
        do return end
    end
    
    local MAX_NUM = 100
    local PREFIX = "chatLog"
    local SUFFIX = "@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
    
    for k, v in pairs(_chatData) do
        CCUserDefault:sharedUserDefault():setStringForKey(v._key, "")
    end
    self.privateChatAllVo[tostring(_privatePlayerUid)] = nil
    
    local _keyIndex = 1
    for i = 1, MAX_NUM do
        local _datakey = PREFIX..i..SUFFIX
        local jsonStr = CCUserDefault:sharedUserDefault():getStringForKey(_datakey)
        if jsonStr and string.len(jsonStr) > 0 then
            if i > _keyIndex then
                CCUserDefault:sharedUserDefault():setStringForKey(_datakey, "")
                CCUserDefault:sharedUserDefault():setStringForKey(PREFIX.._keyIndex..SUFFIX, jsonStr)
            end
            _keyIndex = _keyIndex + 1
        end
    end
    
    CCUserDefault:sharedUserDefault():flush()
    self:initLocalPrivateChatData()
end
function chatVoApi:initLocalPrivateChatData()
    local MAX_NUM = 100
    local PREFIX = "chatLog"
    local SUFFIX = "@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
    
    self.privateChatAllVo = {}
    local function exception(msg)
        print(msg)
    end
    for i = 1, MAX_NUM do
        local _datakey = PREFIX..i..SUFFIX
        local jsonStr = CCUserDefault:sharedUserDefault():getStringForKey(_datakey)
        if jsonStr and string.len(jsonStr) > 0 then
            -- print("cjl ------->>>> " .. i, jsonStr)
            local sData
            local function jsondecode(...)
                sData = G_Json.decode(jsonStr)
                sData._key = _datakey
                local _privatePlayerUid
                if sData.sender ~= playerVoApi:getUid() then
                    _privatePlayerUid = tostring(sData.sender)
                else
                    _privatePlayerUid = tostring(sData.reciver)
                end
                if self.privateChatAllVo[_privatePlayerUid] == nil then
                    self.privateChatAllVo[_privatePlayerUid] = {}
                end
                local size = SizeOfTable(self.privateChatAllVo[_privatePlayerUid])
                self.privateChatAllVo[_privatePlayerUid][size + 1] = sData
            end
            xpcall(jsondecode, exception)
        end
    end
    
    self.privateTlakListTime = {}
    for k, v in pairs(self.privateChatAllVo) do
        local tempTab = {ts = v[SizeOfTable(v)].content.ts, uid = k}
        table.insert(self.privateTlakListTime, tempTab)
    end
    table.sort(self.privateTlakListTime, function(a, b) return a.ts > b.ts end)
end
function chatVoApi:getPrivateChatDataNum()
    if self.privateChatAllVo then
        return SizeOfTable(self.privateChatAllVo)
    end
    return 0
end
function chatVoApi:getPrivateChatData(_index)
    if self.privateChatAllVo and self.privateTlakListTime then
        local _uid = self.privateTlakListTime[_index].uid
        for k, v in pairs(self.privateChatAllVo) do
            if _uid == k then
                return v
            end
        end
    end
end
function chatVoApi:getPrivateChatDataByKey(_privatePlayerUid)
    if self.privateChatAllVo then
        return self.privateChatAllVo[tostring(_privatePlayerUid)]
    end
end
function chatVoApi:getPrivateChatDataNumByKey(_privatePlayerUid)
    if _privatePlayerUid and self.privateChatAllVo and self.privateChatAllVo[tostring(_privatePlayerUid)] then
        return SizeOfTable(self.privateChatAllVo[tostring(_privatePlayerUid)])
    end
    return 0
end
function chatVoApi:addPrivateChatData(_chatData)
    _chatData = _chatData or {}
    self.allChatVo[2] = nil
    self.allChatVo[2] = {}
    self.indexTab[2] = nil
    for k, sData in pairs(_chatData) do
        self:addOneChat(2, sData.sender, sData.sendername, sData.reciver, sData.recivername, sData.content, sData.ts)
    end
    self:setReadData(_chatData)
end
function chatVoApi:setReadData(_chatData)
    if _chatData then
        for k, sData in pairs(_chatData) do
            if sData._isRead ~= 1 then
                sData._isRead = 1
                local _temp = G_clone(sData)
                _temp._key = nil
                local value = G_Json.encode(_temp)
                CCUserDefault:sharedUserDefault():setStringForKey(sData._key, value)
                CCUserDefault:sharedUserDefault():flush()
            end
        end
    end
end
function chatVoApi:setUnReadCount(_chatTabType)
    if _chatTabType == 0 then
        local msgNum = chatVoApi:getChatNum(1)
        local chatVo = chatVoApi:getChatVo(msgNum, 1)
        if chatVo then
            local key = "chatTabType0Timer@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
            CCUserDefault:sharedUserDefault():setStringForKey(key, chatVo.time)
            CCUserDefault:sharedUserDefault():flush()
        end
    elseif _chatTabType == 1 then
        local msgNum = chatVoApi:getChatNum(3)
        local chatVo = chatVoApi:getChatVo(msgNum, 3)
        if chatVo then
            local key = "chatTabType1Timer@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
            CCUserDefault:sharedUserDefault():setStringForKey(key, chatVo.time)
            CCUserDefault:sharedUserDefault():flush()
        end
    elseif _chatTabType == 2 then
    end
    
end

function chatVoApi:getUnReadCount(_chatTabType)
    local _unReadCount = 0
    if _chatTabType == 0 then
        local key = "chatTabType0Timer@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
        local timerStr = CCUserDefault:sharedUserDefault():getStringForKey(key)
        local timer = 0
        if timerStr and string.len(timerStr) > 0 then
            timer = tonumber(timerStr)
        end
        local msgNum = chatVoApi:getChatNum(1)
        for i = 1, msgNum do
            local chatVo = chatVoApi:getChatVo(i, 1)
            -- if chatVo.contentType==1 and chatVo.subType==1 and tonumber(chatVo.time) > timer then
            if chatVo.contentType == 1 and tonumber(chatVo.time) > timer then
                _unReadCount = _unReadCount + 1
                if _unReadCount >= 20 then ----世界最多显示20条
                    break
                end
            end
        end
    elseif _chatTabType == 1 then
        local key = "chatTabType1Timer@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID)
        local timerStr = CCUserDefault:sharedUserDefault():getStringForKey(key)
        local timer = 0
        if timerStr and string.len(timerStr) > 0 then
            timer = tonumber(timerStr)
        end
        local msgNum = chatVoApi:getChatNum(3)
        for i = 1, msgNum do
            local chatVo = chatVoApi:getChatVo(i, 3)
            -- if chatVo.contentType==1 and chatVo.subType==3 and tonumber(chatVo.time) > timer then
            if chatVo.contentType == 1 and tonumber(chatVo.time) > timer then
                _unReadCount = _unReadCount + 1
                if _unReadCount >= 10 then --军团最多显示10条
                    break
                end
            end
        end
    elseif _chatTabType == 2 then
        local num = chatVoApi:getPrivateChatDataNum()
        for i = 1, num do
            local chatData, uid = chatVoApi:getPrivateChatData(i)
            for k, v in pairs(chatData) do
                if v._isRead ~= 1 then
                    _unReadCount = _unReadCount + 1
                end
            end
        end
    end
    return _unReadCount
end
-- _uid:只用于私聊
function chatVoApi:setChatUnSendMsg(_chatTabType, _msgStr, _uid)
    if self.chatUnSendMsg == nil then
        self.chatUnSendMsg = {}
    end
    _msgStr = (_msgStr == "" and nil or _msgStr)
    if _chatTabType == 0 then
        self.chatUnSendMsg.type0 = _msgStr
    elseif _chatTabType == 1 then
        self.chatUnSendMsg.type1 = _msgStr
    elseif _chatTabType == 2 and _uid and self:getPrivateChatDataNumByKey(_uid) > 0 then
        if self.chatUnSendMsg.type2 == nil then
            self.chatUnSendMsg.type2 = {}
        end
        self.chatUnSendMsg.type2[tostring(_uid)] = _msgStr
    end
end
function chatVoApi:getChatUnSendMsg(_chatTabType, _uid)
    if self.chatUnSendMsg then
        if _chatTabType == 0 then
            return self.chatUnSendMsg.type0 or ""
        elseif _chatTabType == 1 then
            return self.chatUnSendMsg.type1 or ""
        elseif _chatTabType == 2 and _uid then
            if self.chatUnSendMsg.type2 then
                return self.chatUnSendMsg.type2[tostring(_uid)] or ""
            end
        end
    end
    return ""
end
--是否聊天2.0版本
function chatVoApi:isChat2_0()
    local numKey = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_chatDisplay")
    if numKey == 2 or numKey == 0 then
        return true
    end
    return false
end

--------------------------------------------------------------------

--聊天即时翻译，使用google + baidu翻译
function chatVoApi:translate(message, callback, paramFrom)
    if(self.translateData.type == 1)then
        -- local translateMap={en="en",fr="fr",it="it",cn="zh-CN",tw="zh-TW",de="de"}
        -- -- local langNum=#(platCfg.platChatTranslateCfg[G_curPlatName()].language) - 1
        -- -- local resultNum=0
        -- -- local resultTb={}
        -- -- for k,v in pairs(platCfg.platChatTranslateCfg[G_curPlatName()].language) do
        -- -- if(v~=G_getCurChoseLanguage())then
        -- local function onTranslate(data,result)
        -- local transResult
        -- if(result==0)then
        -- if(tostring(data)=="0" or tostring(data)=="1")then
        -- self.translateData.type=2
        -- self.translateData.switchtime=base.serverTime
        -- self:translate(message,callback,paramFrom)
        -- else
        -- local jsonData=G_Json.decode(data)
        -- if(type(jsonData)=="table" and jsonData[1] and type(jsonData[1])=="table" and jsonData[1][1] and type(jsonData[1][1])=="table")then
        -- transResult=jsonData[1][1][1]
        -- else
        -- transResult=message
        -- end
        -- end
        -- callback(transResult)
        -- else
        -- self.translateData.type=2
        -- self.translateData.switchtime=base.serverTime
        -- self:translate(message,callback,paramFrom)
        -- end
        -- end
        -- local from=translateMap[paramFrom]
        -- local to=translateMap[G_getCurChoseLanguage()]
        -- if(from==nil or to==nil)then
        -- callback()
        -- do return end
        -- end
        -- local transUrl=base.serverUserIp.."/tankheroclient/webpage/translate/transApi.php"
        -- -- if(G_curPlatName()=="0")then
        -- -- transUrl="http://tank-ger-web01.raysns.com/tankheroclient/webpage/translate/transApi.php"
        -- -- end
        -- G_sendHttpAsynRequest(transUrl,"fm="..from.."&to="..to.."&q="..HttpRequestHelper:URLEncode(message),onTranslate,2)
        -- -- end
        -- -- end
        
        -- 新翻译
        local translateMap = {en = "en", fr = "fr", it = "it", cn = "zh-CN", tw = "zh-TW", de = "de"}
        local function onTranslate(data, result)
            local resultTb = {}
            if(result == 0 and data ~= nil)then
                resultTb = data
                callback(resultTb)
            else
                self.translateData.type = 2
                self.translateData.switchtime = base.serverTime
                self:translate(message, callback, paramFrom)
            end
        end
        local from = translateMap[paramFrom]
        local to = translateMap[G_getCurChoseLanguage()]
        if(from == nil or to == nil)then
            callback()
            do return end
        end
        local transUrl = "http://"..base.serverUserIp.."/tankheroclient/webpage/translate/google/fanyi2.php?"
        G_sendHttpAsynRequest(transUrl.."q="..HttpRequestHelper:URLEncode(message) .. "&sl=auto" .. "&tl="..to, "", onTranslate)
        -- print(" >>>----->> transUrl = ", transUrl.."q="..HttpRequestHelper:URLEncode(message).."&sl=auto".."&tl="..to)
    elseif(self.translateData.type == 2 and self.translateData.switchtime < base.serverTime - 600)then
        self.translateData.type = 1
        self.translateData.switchtime = base.serverTime
        self:translate(message, callback, paramFrom)
    elseif(self.translateData.type == 2)then
        local translateMap = {en = "en", fr = "fra", it = "it", cn = "zh", de = "de", tw = "cht"}
        -- local langNum=#(platCfg.platChatTranslateCfg[G_curPlatName()].language) - 1
        -- local resultNum=0
        -- local resultTb={}
        -- for k,v in pairs(platCfg.platChatTranslateCfg[G_curPlatName()].language) do
        -- if(v~=G_getCurChoseLanguage())then
        local function onTranslate(data, result)
            local transResult
            if(result == 0)then
                local transData = G_Json.decode(data)
                if(transData and transData.trans_result and transData.trans_result.data and transData.trans_result.data[1] and transData.trans_result.data[1].dst)then
                    transResult = transData.trans_result.data[1].dst
                else
                    transResult = message
                end
            else
                transResult = message
            end
            callback(transResult)
        end
        local from = translateMap[paramFrom]
        local to = translateMap[G_getCurChoseLanguage()]
        G_sendHttpAsynRequest("http://fanyi.baidu.com/v2transapi", "from="..from.."&to="..to.."&query="..HttpRequestHelper:URLEncode(message) .. "&transtype=realtime&simple_means_flag=3", onTranslate, 2)
        -- end
        -- end
    else
        if(callback)then
            callback()
        end
    end
end

function chatVoApi:addChat(cType, sender, senderName, reciver, reciverName, content, ts, callback)
    local blackList = G_getBlackList()
    if blackList and SizeOfTable(blackList) > 0 then
        for k, v in pairs(blackList) do
            if tonumber(sender) == tonumber(v.uid) and tostring(senderName) == tostring(v.name) then
                if callback then
                    callback(false)
                end
                do return false end
            end
        end
    end
    
    if cType == 0 then
        cType = 2
    elseif cType == 1 or cType == 10000 then
    else
        local aid = tonumber(playerVoApi:getPlayerAid())
        if aid and type and tostring(cType) == tostring(aid + 1) then
            cType = 3
        else
            if callback then
                callback(false)
            end
            do return false end
        end
    end
    
    local contentType = content.contentType
    local language = content.language
    if (cType <= 3 or cType >= 10000) and contentType and contentType <= 3 then
        if cType == 2 and ts and base.loginTime and ts < base.loginTime then
            return false
        end
        --local idx=1
        if cType <= 3 then
            if self:addOneChat(1, sender, senderName, reciver, reciverName, content, ts) then
                if self.hasNewData == nil then
                    self.hasNewData = {}
                end
                -- self.hasNewData["t0"]=true--mainUI标记
                -- self.hasNewData["t1"]=true
                if self:isMultiLanguage(1) == true then
                    if self.hasNewData["t0"] == nil or (self.hasNewData["t0"] and type(self.hasNewData["t0"]) ~= "table") then
                        self.hasNewData["t0"] = {}
                    end
                    if self.hasNewData["t1"] == nil or (self.hasNewData["t1"] and type(self.hasNewData["t1"]) ~= "table") then
                        self.hasNewData["t1"] = {}
                    end
                    if self.hasNewData["t12"] == nil or (self.hasNewData["t12"] and type(self.hasNewData["t12"]) ~= "table") then
                        self.hasNewData["t12"] = {}
                    end
                    if self.hasNewData["t13"] == nil or (self.hasNewData["t13"] and type(self.hasNewData["t13"]) ~= "table") then
                        self.hasNewData["t13"] = {}
                    end
                    if self.hasNewData["t14"] == nil or (self.hasNewData["t14"] and type(self.hasNewData["t14"]) ~= "table") then
                        self.hasNewData["t14"] = {}
                    end
                    -- if self.hasNewData["t15"] == nil or (self.hasNewData["t15"] and type(self.hasNewData["t15"]) ~= "table") then
                    --     self.hasNewData["t15"] = {}
                    -- end
                    self.hasNewData["t0"]["all"] = true
                    self.hasNewData["t1"]["all"] = true
                    self.hasNewData["t12"]["all"] = true
                    self.hasNewData["t13"]["all"] = true
                    self.hasNewData["t14"]["all"] = true
                    -- self.hasNewData["t15"]["all"]=true
                    -- print('self.hasNewData["t1"]["all"]',self.hasNewData["t1"]["all"])
                    if language ~= nil and language ~= "" then
                        self.hasNewData["t0"][language] = true
                        self.hasNewData["t1"][language] = true
                        self.hasNewData["t12"][language] = true
                        self.hasNewData["t13"][language] = true
                        self.hasNewData["t14"][language] = true
                        -- self.hasNewData["t15"][language]=true
                    end
                else
                    self.hasNewData["t0"] = true--mainUI标记
                    self.hasNewData["t1"] = true
                    self.hasNewData["t12"] = true--世界争霸聊天标示
                    self.hasNewData["t13"] = true
                    self.hasNewData["t14"] = true
                    -- self.hasNewData["t15"]=true
                end
            end
        elseif cType == 10000 then
            local addSuccess = self:addOneChat(cType, sender, senderName, reciver, reciverName, content, ts)
            if addSuccess == true then
                if self.hasNewData == nil then
                    self.hasNewData = {}
                end
                if self:isMultiLanguage(cType) == true then
                    if self.hasNewData["t10000"] == nil or (self.hasNewData["t10000"] and type(self.hasNewData["t10000"]) ~= "table") then
                        self.hasNewData["t10000"] = {}
                    end
                    self.hasNewData["t10000"]["all"] = true
                    if language ~= nil and language ~= "" then
                        self.hasNewData["t10000"][language] = true
                    end
                else
                    self.hasNewData["t10000"] = true
                end
                -- print('self.hasNewData["t10000"]',self.hasNewData["t10000"])
            end
        end
        if cType == 2 or cType == 3 then
            --idx=cType
            if self:addOneChat(cType, sender, senderName, reciver, reciverName, content, ts) then
                self.hasNewData["t"..cType] = true
                if cType == 3 then
                    self.hasNewData["t10"] = true--军团战聊天标示
                    self.hasNewData["t11"] = true--跨服军团战聊天标示
                    self.hasNewData["t14"] = true--跨服军团战聊天标示
                    self.hasNewData["t16"] = true--群雄争霸聊天标示
                elseif cType == 2 then
                    self:setIsNewPrivateMsg(-1)
                end
            end
        end
    elseif contentType and contentType > 3 then
        --世界地图更新
        print("call world change")
    end
    if callback then
        callback(true)
    end
    do return true end
end

function chatVoApi:getMaxMore(idx, language)
    -- return self.maxMore[idx]
    if self:isMultiLanguage(idx) == true then
        if self.maxMore[idx] == nil or type(self.maxMore[idx]) ~= "table" then
            self.maxMore[idx] = {}
        end
        if language == nil or language == "" then
            language = self.selectedLanguage
        end
        return self.maxMore[idx][language]
    else
        return self.maxMore[idx]
    end
end
function chatVoApi:setMaxMore(idx, isMaxMore, language)
    -- self.maxMore[idx]=isMaxMore
    if self:isMultiLanguage(idx) == true then
        if self.maxMore[idx] == nil or type(self.maxMore[idx]) ~= "table" then
            self.maxMore[idx] = {}
        end
        if language == nil or language == "" then
            language = self.selectedLanguage
        end
        self.maxMore[idx][language] = isMaxMore
    else
        self.maxMore[idx] = isMaxMore
    end
end
function chatVoApi:isExist(type, sender, content, contentType, report, time)
    local chatType = self:getChatFromAll(type)
    if chatType and SizeOfTable(chatType) > 0 then
        for k, v in pairs(chatType) do
            if sender and v.sender and tostring(sender) == tostring(v.sender) and tostring(content) == tostring(v.content) and tostring(time) == tostring(v.time) then
                do return true end
            end
        end
    end
    return false
end

function chatVoApi:getNameStr(type, subType, from, to, sender)
    local nameStr = ""
    if sender ~= nil and sender ~= 0 and sender ~= "" and from ~= nil and from ~= "" then
        if subType and subType ~= 4 then
            --if ((type==1 and subType==2) or type==2) and to~=nil and to~="" then
            if (subType == 2 or subType == 5) and to ~= nil and to ~= "" then
                if playerVoApi:getUid() == sender then
                    nameStr = getlocal("chat_whisper_to", {to})--..":"
                else
                    nameStr = getlocal("chat_whisper_from", {from})--..":"
                end
            else
                nameStr = from--..":"
            end
        end
    end
    return nameStr
end
function chatVoApi:getMessage(type, subType, from, to, content, sender, params)
    
    local showMsg = content or ""
    -- print("here>>>>>>>>?????",showMsg)
    local width = 500
    -- local numKey = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_chatDisplay")
    -- if numKey==2 or numKey==0 then
    width = width - 56
    -- end
    
    local messageLabel
    local lbHeight
    if params.paramTab and params.paramTab.addStr then
        if params.paramTab.noRich and tostring(params.paramTab.noRich) == "1" then
            showMsg = content .. " " .. getlocal(params.paramTab.addStr)
            showMsg = string.gsub(showMsg, "<rayimg>", "")
            messageLabel = GetTTFLabelWrap(showMsg, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            lbHeight = messageLabel:getContentSize().height
        else
            showMsg = showMsg .. " " .. "<rayimg>" .. getlocal(params.paramTab.addStr) .. "<rayimg>"
            messageLabel, lbHeight = G_getRichTextLabel(showMsg, {G_ColorWhite, G_ColorGreen}, 26, width, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        end
    else
        showMsg = string.gsub(content, "<rayimg>", "")
        messageLabel = GetTTFLabelWrap(showMsg, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        lbHeight = messageLabel:getContentSize().height
    end
    local height = lbHeight + 5
    --[[
local ttLabel1=GetTTFLabelWrap("啊啊啊啊啊啊啊",28,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
local ttLabel2=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",28,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
print("height1",ttLabel1:getContentSize().height)
print("height2",ttLabel2:getContentSize().height)
]]
    -- if subType~=4 then-- 系统公告
    height = height + 32--35
    -- end
    if params and params.xlpd_invite then --协力攀登组队邀请高度固定
        height = 250
    end
    return width, height
end

function chatVoApi:getHasNewData(cType, language)
    if self.hasNewData == nil then
        self.hasNewData = {}
    end
    -- print("language",language)
    -- return self.hasNewData["t"..cType]
    if self:isMultiLanguage(cType) == true then
        if language == nil or language == "" then
            language = self.selectedLanguage
        end
        if self.hasNewData["t"..cType] == nil or type(self.hasNewData["t"..cType]) ~= "table" then
            self.hasNewData["t"..cType] = {}
            -- self.hasNewData["t"..cType][language]=false
        end
        if self.hasNewData["t"..cType][language] == nil then
            self.hasNewData["t"..cType][language] = false
        end
        return self.hasNewData["t"..cType][language]
    else
        return self.hasNewData["t"..cType]
    end
end
function chatVoApi:setNoNewData(type, language)
    if self.hasNewData == nil then
        self.hasNewData = {}
    end
    -- self.hasNewData["t"..type]=false
    if self:isMultiLanguage(type) == true then
        if self.hasNewData["t"..type] == nil then
            self.hasNewData["t"..type] = {}
        end
        if language == nil or language == "" then
            language = self.selectedLanguage
        end
        self.hasNewData["t"..type][language] = false
    else
        self.hasNewData["t"..type] = false
    end
end
function chatVoApi:getMainUIShowNew()
    return self.mainUIShowNew
end
function chatVoApi:setMainUINotShowNew()
    self.mainUIShowNew = false
end

function chatVoApi:getChatNum(idx, language)
    local typeChat = self:getChatFromAll(idx, language)
    if typeChat == nil then
        typeChat = {}
    end
    return SizeOfTable(typeChat)
end

function chatVoApi:getChatFromAll(idx, language)
    if self.allChatVo[idx] == nil then
        self.allChatVo[idx] = {}
    end
    if self:isMultiLanguage(idx) == true then
        if language == nil or language == "" then
            language = self.selectedLanguage
        end
        if self.allChatVo[idx][language] == nil then
            self.allChatVo[idx][language] = {}
        end
        return self.allChatVo[idx][language]
    else
        return self.allChatVo[idx]
    end
    -- return self.allChatVo[idx]
end

function chatVoApi:getChatVo(index, idx, language)
    local typeChat = self:getChatFromAll(idx, language)
    if typeChat == nil then
        typeChat = {}
    end
    for k, v in pairs(typeChat) do
        --[[
        if tostring(index)==tostring(v.index) then
return v
end
]]
        if tostring(index) == tostring(k) then
            return v
        end
    end
    return nil
end

function chatVoApi:setChatVoKillRedBagTag(index, idx, redbagTag, nextIdx)--用于去掉聊天数据内 有关红包的tag值（目前只针对双11红包使用）
    local typeChat = self:getChatFromAll(idx)
    if index and typeChat[index].params.paramTab.redBagTb and typeChat[index].params.paramTab.redBagTb.tag == redbagTag then
        typeChat[index].params.paramTab.redBagTb.tag = nil
    elseif redbagTag then--用
        for k, v in pairs(typeChat) do
            if v.params and v.params.paramTab and v.params.paramTab.redBagTb and v.params.paramTab.redBagTb.tag == redbagTag then
                typeChat[k].params.paramTab.redBagTb.tag = nil
            end
        end
        local typeChat2 = self:getChatFromAll(nextIdx)
        for k, v in pairs(typeChat2) do
            if v.params and v.params.paramTab and v.params.paramTab.redBagTb and v.params.paramTab.redBagTb.tag == redbagTag then
                typeChat2[k].params.paramTab.redBagTb.tag = nil
            end
        end
    else
        if index then
            print("typeChat[index].params.paramTab.redBagTb.tag-----redbagTag---->", typeChat[index].params.paramTab.redBagTb.tag, redbagTag)
        else
            print(" corp RedbBag Tag is error~~~~~ redbagTag has not found", redbagTag)
        end
    end
end
function chatVoApi:getChatVoByIndex(index, idx, language)
    local typeChat = self:getChatFromAll(idx, language)
    if typeChat == nil then
        typeChat = {}
    end
    for k, v in pairs(typeChat) do
        if v and v.index then
            if tostring(index) == tostring(v.index) then
                return v
            end
        end
    end
    return nil
end

function chatVoApi:getShowNum()
    return self.showNum
end

function chatVoApi:getLast(idx)
    local num = self:getChatNum(idx, self.selectedLanguage)
    if num > 0 then
        local chatVo = self:getChatVo(num, idx, self.selectedLanguage)
        if chatVo then
            do return chatVo end
        end
    end
    return nil
end

--高级vip玩家聊天文字变色
function chatVoApi:getVipChatColor(vip)
    local color = nil
    if platCfg.platCfgChatVipColor[G_curPlatName()] ~= nil then
        if G_chatVipColorStartTime and G_chatVipColorEndTime then
            if base.serverTime >= G_chatVipColorStartTime and base.serverTime <= G_chatVipColorEndTime then
                if vip and vip >= 8 then
                    color = G_ColorVipChat
                end
            end
        end
    end
    return color
end
function chatVoApi:getTypeStr(subType, channel, allianceRole, vip)
    local typeStr = ""
    local color = G_ColorWhite
    local icon
    if subType == 1 then
        typeStr = getlocal("chat_world_icon")
        --color=G_ColorGreen
        local vipColor = self:getVipChatColor(vip)
        if vipColor then
            color = vipColor
        end
        -- icon="chatBtnWorld.png"
        if G_getGameUIVer() == 2 then
            icon = "cin_chatBtnWorld1.png"
        else
            icon = "cin_chatBtnWorld.png"
        end
    elseif subType == 2 then
        typeStr = getlocal("chat_whisper_icon")
        color = G_ColorPurple
        -- icon="chatBtnFriend.png"
        if G_getGameUIVer() == 2 then
            icon = "cin_chatBtnFriend1.png"
        else
            icon = "cin_chatBtnFriend.png"
        end
    elseif subType == 3 then
        typeStr = getlocal("chat_alliance_icon")
        color = G_ColorBlue
        -- icon="chatBtnAlliance.png"
        if G_getGameUIVer() == 2 then
            icon = "cin_chatBtnAlliance1.png"
        else
            icon = "cin_chatBtnAlliance.png"
        end
        if allianceRole and channel and channel == 2 then
            if tonumber(allianceRole) == 0 then
                icon = "soldierIcon.png"
            elseif tonumber(allianceRole) == 1 then
                icon = "deputyHead.png"
            elseif tonumber(allianceRole) == 2 then
                icon = "positiveHead.png"
            end
        end
    elseif subType == 4 then
        typeStr = getlocal("chat_system_icon")
        color = G_ColorYellow
        if G_getGameUIVer() == 2 then
            icon = "systemIcon1.png"
        else
            icon = "systemIcon.png"
        end
    elseif subType == 5 then
        typeStr = getlocal("chat_gm_icon")
        --color=G_ColorYellow
        color = G_ColorRed
        icon = "gmIcon.png"
    end
    return typeStr, color, icon
end

function chatVoApi:getReciverIdByName(name)
    local reciverId = 0
    if name ~= nil and name ~= "" then
        local channelNum = SizeOfTable(self.allChatVo)
        for k = 1, channelNum do
            local typeChat = self:getChatFromAll(k)
            for k, v in pairs(typeChat) do
                if tostring(v.senderName) == tostring(name) then
                    return v.sender
                end
            end
        end
    end
    return reciverId
end

--是否屏蔽信息，防止刷广告 true被屏蔽，false没有
-- 简体和繁体中文的平台：
-- 1.新建账号半小时后升级不到3级 或者 战力为0；
-- 2.记录自己发送的最后3条且长度大于40信息：
-- 与最新发送信息比较，有内容相同；
-- 长度大于40；
-- 3.信息内容匹配：
-- 数字长度大于等于12
function chatVoApi:isShieldMsg(content, sendername)
    if G_getCurChoseLanguage() ~= "cn" and G_getCurChoseLanguage() ~= "tw" then
        do
            return false
        end
    end
    local regdate = playerVoApi:getRegdate()
    if (base.serverTime - regdate) > 1800 and (playerVoApi:getPlayerLevel() < 3 or playerVoApi:getPlayerPower() == 0) and GM_UidCfg[playerVoApi:getUid()] == nil then
        do return true end
    end
    if content and type(content) == "table" then
        if content.contentType and content.contentType == 1 then
            local forbidTab = {{"零", "零", "０"}, {"一", "壹", "１"}, {"二", "贰", "２"}, {"三", "叁", "３"}, {"四", "肆", "４"}, {"五", "伍", "５"}, {"六", "陆", "６"}, {"七", "柒", "７"}, {"八", "捌", "８"}, {"九", "玖", "９"}, {"十", "拾", "１０"}, {"百", "佰", "１００"}, {"千", "仟", "１０００"}, {"万", "萬", "１００００"}, {"亿", "億", "１００００００００"}}
            local aimTab = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100, 1000, 10000, 100000000}
            local keyw = {"购", "售", "买", "卖", "企鹅", "热线", "付", "代", "充", "币", "元", "圆", "送", "赠", "人民币", "rmb"}
            
            if playerVoApi:getPlayerLevel() < 5 then
                local tempSendername = sendername
                if tempSendername and tempSendername ~= "" then
                    tempSendername = string.lower(tempSendername)
                    for k, v in pairs(forbidTab) do
                        if v then
                            for ii = 1, #v do
                                tempSendername = string.gsub(tempSendername, v[ii], aimTab[k])
                            end
                        end
                    end
                    
                    local msgIndex = string.find(tempSendername, '%d.*%d.*%d.*%d.*%d.*%d.*%d.*')
                    if msgIndex then
                        do return true end
                    end
                end
            end
            
            local message = content.message
            if message and type(message) == "string" then
                local tempMessage = string.lower(message)
                for k, v in pairs(forbidTab) do
                    if v then
                        for ii = 1, #v do
                            tempMessage = string.gsub(tempMessage, v[ii], aimTab[k])
                        end
                    end
                end
                local hasKeywd = false
                for k, v in pairs(keyw) do
                    hasKeywd = string.find(tempMessage, v)
                    if hasKeywd then
                        break
                    end
                end
                
                local msgIndex
                if hasKeywd then
                    msgIndex = string.find(tempMessage, '%d.*%d.*%d.*%d.*%d.*%d.*%d.*')
                else
                    msgIndex = string.find(tempMessage, '%d.*%d.*%d.*%d.*%d.*%d.*%d.*%d.*%d.*%d.*%d.*%d.*')
                end
                -- print("tempMessage",tempMessage)
                -- print("message",message)
                -- print("msgIndex",msgIndex)
                if msgIndex then
                    do return true end
                end
                if not content.xlpd_invite then
                    for k, v in pairs(self.lastMessage) do
                        if v == tempMessage then
                            do return true end
                        end
                    end
                end
                -- print("string.len(tempMessage)",string.len(tempMessage))
                if string.len(tempMessage) > 40 then
                    table.insert(self.lastMessage, tempMessage)
                    if SizeOfTable(self.lastMessage) > 3 then
                        table.remove(self.lastMessage, 1)
                    end
                end
            end
        end
    end
    -- print("发出~~~~~")
    return false
end
--玩家是否能聊天
function chatVoApi:canChat(layerNum)
    if base.shutChatSwitch == 1 then
        G_showTipsDialog(getlocal("chat_sys_notopen"))
        do return false end
    end
    -- 检测玩家等级是否到5级
    -- if playerVoApi:getPlayerLevel()<5 then
    -- local curLanguage=G_getCurChoseLanguage()
    -- if curLanguage and curLanguage=="cn" then
    -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("chat_level_limit"),30)
    -- do return false end
    -- end
    -- end
    -- 检测玩家是否被禁言 true没有 false被禁言,
    if (G_forbidType == 1 or G_forbidType == 2 or (G_forbidType == 0 and G_forbidEndTime > 0)) then
        if G_forbidEndTime and G_forbidEndTime > 0 then
            if G_isNotice == 1 then
                local forbidStr = getlocal("forbid_chat_pro", {getlocal("chatinfo")})
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), forbidStr, 30)
                -- if layerNum then
                -- -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),leftTimeStr,nil,layerNum+1)
                -- local tabStr={" ",leftTimeStr," "}
                -- local tabColor={nil,G_ColorWhite,nil}
                -- local td=smallDialog:new()
                -- local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,tabStr,25,tabColor)
                -- sceneGame:addChild(dialog,layerNum+1)
                -- end
                return false, nil
            else
                --特殊情况：禁言了但没有通知给玩家时返回为true
                return true, G_isNotice
            end
        end
    end
    return true, nil
end
--玩家发送的聊天消息，包括战报
function chatVoApi:sendChatMessage(channel, sender, sendername, reciver, recivername, content)
    local chatEnabled, isNotice = self:canChat()
    if chatEnabled == true then
        --等级限制，是否到指定等级，不到则自己发送的信息只能自己看到，其他人看不到
        local chatLvLimit = true
        if channel and channel == 1 and base.chatLvLimit and playerVoApi:getPlayerLevel() < base.chatLvLimit and GM_UidCfg[playerVoApi:getUid()] == nil then
            chatLvLimit = false
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("chat_lvNotEnough"), 28)
            do return false end
        end
        local isJapanV = self:isJapanV()
        if isJapanV and content then
            content.isVipV = 1
        end
        local isShield = false
        if content.emojiId then --动态表情不过滤
        else
            isShield = self:isShieldMsg(content, sendername)
        end
        local flag = true
        if isShield == false and chatLvLimit == true then
            if base.chatReportSwitch == 1 and content and type(content) == "table" and content.contentType and content.contentType == 2 and content.report and SizeOfTable(content.report) > 0 then
                --http请求
                local function sendReport(retStr)
                    -- deviceHelper:luaPrint(retStr)
                    if retStr and retStr ~= "" then
                        local retData = G_Json.decode(retStr)
                        if(retData["ret"] == 0 or retData["ret"] == "0")then
                            if retData.data and retData.data.id then
                                content.reportId = retData.data.id --后台生成的数据记录id
                                if content.report then --向后台发送的数据
                                    content.report = nil
                                end
                                -- socketHelper:sendChatMsg(channel,sender,sendername,reciver,recivername,content)
                                if isNotice and isNotice == 0 then
                                    self:addChat(channel, sender, sendername, reciver, recivername, content, base.serverTime)
                                else
                                    self:realSendChatMessage(channel, sender, sendername, reciver, recivername, content)
                                end
                            end
                        end
                    end
                end
                if HttpRequestHelper:shared().sendAsynHttpRequestPost == nil then
                    local httpUrl = "http://"..base.serverIp.."/tank-server/public/index.php/api/chatrecord/send"
                    local reqStr = "zoneid="..base.curZoneID.."&content="..HttpRequestHelper:URLEncode(G_Json.encode(content.report))
                    -- deviceHelper:luaPrint(httpUrl)
                    -- deviceHelper:luaPrint(reqStr)
                    local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
                    sendReport(retStr)
                else
                    local httpUrl = "http://"..base.serverIp.."/tank-server/public/index.php/api/chatrecord/send"
                    local reqStr = "zoneid="..base.curZoneID.."&content="..HttpRequestHelper:URLEncode(G_Json.encode(content.report))
                    -- deviceHelper:luaPrint(httpUrl)
                    -- deviceHelper:luaPrint(reqStr)
                    G_sendHttpAsynRequest(httpUrl, reqStr, sendReport, 2)
                end
            elseif content and type(content) == "table" and content.contentType and content.contentType == 1 then
                if isNotice and isNotice == 0 then
                    flag = self:addChat(channel, sender, sendername, reciver, recivername, content, base.serverTime)
                else
                    flag = self:realSendChatMessage(channel, sender, sendername, reciver, recivername, content)
                end
                -- local function onTranslate(resultTb)
                -- if(resultTb)then
                -- content.transData=resultTb
                -- end
                -- -- socketHelper:sendChatMsg(channel,sender,sendername,reciver,recivername,content)
                -- self:realSendChatMessage(channel,sender,sendername,reciver,recivername,content)
                -- end
                -- local tmpContent=G_clone(content)
                -- tmpContent.transData={}
                -- tmpContent.transData[G_getCurChoseLanguage()]=content.message
                -- self:addChat(channel,sender,sendername,reciver,recivername,tmpContent,base.serverTime)
                -- if isNotice and isNotice==0 then
                -- else
                -- self:translate(content.message,onTranslate)
                -- end
            else
                -- socketHelper:sendChatMsg(channel,sender,sendername,reciver,recivername,content)
                if isNotice and isNotice == 0 then
                    flag = self:addChat(channel, sender, sendername, reciver, recivername, content, base.serverTime)
                else
                    flag = self:realSendChatMessage(channel, sender, sendername, reciver, recivername, content)
                end
            end
        else
            flag = self:addChat(channel, sender, sendername, reciver, recivername, content, base.serverTime)
        end
        return flag
    else
        return false
    end
end
--真正发送聊天消息，包括战报接口
function chatVoApi:realSendChatMessage(channel, sender, sendername, reciver, recivername, content)
    socketHelper:sendChatMsg(channel, sender, sendername, reciver, recivername, content)
    if acKoulinghongbaoVoApi then
        local acVo = acKoulinghongbaoVoApi:getAcVo()
        if acVo and activityVoApi:isStart(acVo) == true and acVo.v and acVo.num and acVo.v < acVo.num then
            if content and type(content) == "table" and content.contentType == 1 and content.subType == 1 then
                if content.message and type(content.message) == "string" and content.message == getlocal("activity_koulinghongbao_desc") then
                    local function callback(fn, data)
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            if sData and sData.data and sData.data.koulinghongbao then
                                acKoulinghongbaoVoApi:updateData(sData.data.koulinghongbao)
                            end
                        end
                    end
                    socketHelper:activeKoulinghongbao(callback)
                end
            end
        end
    end
    return true
end
--设置战报
function chatVoApi:setChatReport(index, idx, language, report)
    if self.allChatVo[idx] == nil then
        self.allChatVo[idx] = {}
    end
    if self:isMultiLanguage(idx) == true then
        if language == nil or language == "" then
            language = self.selectedLanguage
        end
        if self.allChatVo[idx][language] == nil then
            self.allChatVo[idx][language] = {}
        end
        for k, v in pairs(self.allChatVo[idx][language]) do
            if v and v.index then
                if index and tostring(index) == tostring(v.index) then
                    if v.params and report and SizeOfTable(report) > 0 then
                        v.params.report = report
                    end
                end
            end
        end
    else
        for k, v in pairs(self.allChatVo[idx]) do
            if v and v.index then
                if index and tostring(index) == tostring(v.index) then
                    if v.content and type(v.content) == "table" and report and SizeOfTable(report) > 0 then
                        v.content.report = report
                    end
                end
            end
        end
    end
end
--发送系统消息 contentType=3,,channel:军团发系统公告需要军团uid+1
function chatVoApi:sendSystemMessage(message, paramTab, isCheckExist, subType, channel)
    if channel == nil then
        channel = 1
    end
    local selfUid = playerVoApi:getUid()
    local selfName = playerVoApi:getPlayerName()
    local language = G_getCurChoseLanguage()
    local content = {subType = 4, contentType = 3, message = message, ts = base.serverTime, language = language, paramTab = paramTab}
    socketHelper:sendChatMsg(channel, selfUid, selfName, 0, "", content, false)
end

--发送数据更新消息，不存到聊天里, contentType=4 游戏数据更新
--type 1.加保护，2.移除保护，3.搬家，4.创建军团成功，5.退出军团成功，6.踢出军团成功，7.加入军团，8.修改军团信息，9.修改军团成员贡献，10.军团跨服战上阵人员，11.军团跨服战捐献基地，12.军团跨服战一场战斗结束通知，13.军团跨服战报名, 14. 军功商店购买了物品，15.世界boss，17.修改军团成员活跃度，20.更改军团名称，21.异星矿场，22.区域战设置官职，23.区域战是否有新的军团战报 24.跨平台战捐献部队，25.跨平台战捐献士气 26.新服拉霸即使显示板子使用，27.万圣节大作战活动数据，29.军团协助添加，30.军团协助删除，31.军团所有协助列表刷新,32.除夕之夜活动玩家攻击年兽伤害数据同步，33.港台周年狂欢活动同步集齐五福的玩家个数，34.发送军团邮件,35.被攻击繁荣度掉级或是沦陷，36.矿点升级功能世界地图中有矿点数据发生变化 37.刷新新的金矿矿点,38.刷新世界等级及经验，39.军团boss副本血量发生变化，40.攻击叛军数据 41.滚动提示（vip升级，个人等级提示等）42.叛军刷新时方位提示 43.辞旧迎新活动特殊处理 44.每日捷报点赞,45.每日捷报评论, 46.军团城市操作相关，47.军团城市或领地被系统强制回收，48.军团城市敌军来袭，49.军团城市驻防，50.军团城市全员遣返驻防部队，51：更新世界地图部分地块的数据，52：刷新军团城市数据，53.全民吃鸡(qmcj)军团最新积分,54.全民圣诞(qmsd) 全服最新充值金币数,55.击飞效果处理,56.成就系统全服成就数据变化,57.军团锦标赛更新数据,58.军团旗帜更新数据,59.军团旗帜解锁数据, 60.保护矿 61.协力攀登 刷新接收组队邀请的数据
--channel 频道，默认为1 所有人1.世界，0，私聊，公会是公会aid
function chatVoApi:sendUpdateMessage(type, params, channelType)
    local selfUid = playerVoApi:getUid()
    local selfName = playerVoApi:getPlayerName()
    if params == nil then
        params = {}
    end
    local isQuitChat = false
    if type == 4 or type == 5 or type == 6 or type == 7 then
        if params.baseUid == nil then
            params.baseUid = playerVoApi:getUid()
        end
        if params.x == nil then
            params.x = playerVoApi:getMapX()
        end
        if params.y == nil then
            params.y = playerVoApi:getMapY()
        end
        local selfAlliance = allianceVoApi:getSelfAlliance()
        if selfAlliance and tonumber(selfAlliance.aid) > 0 then
            params.aid = tonumber(selfAlliance.aid)
        end    
        if params.banner == nil then
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance and selfAlliance.banner then
                params.banner = selfAlliance.banner
            end
        end
        if type == 4 or type == 7 then
            base.needLoginChatServer = true
            if(G_curPlatName() == "androidarab")then
                if playerVoApi:getUid() ~= nil then
                    socketHelper:chatServerLogin(base.curUid, base.access_token, base.logints, false)
                    base.needLoginChatServer = false
                end
            end
            worldScene:addSelfAllianceName()
            -- if playerVoApi:getUid()~=nil then
            -- socketHelper:chatServerLogin(base.curUid,base.access_token,base.logints)
            -- end
            
        else
            if type == 5 then
                isQuitChat = true
                if base.isAf == 1 then
                else
                    worldScene:removeAllianceSp()
                end
            end
            
        end
        if serverWarTeamVoApi then
            serverWarTeamVoApi:setWarInfoExpireTime(0)
        end
        if(G_curPlatName() == "androidarab" or G_curPlatName() == "0")then
            if(type == 5)then
                params["isquit"] = 1
                if(params["isDismiss"] == 1)then
                    socketHelper:chatClanMsg(2, params)
                else
                    socketHelper:chatClanMsg(1, params)
                end
            else
                socketHelper:chatClanMsg(1)
            end
        end
    end
    local language = G_getCurChoseLanguage()
    local content = {contentType = 4, type = type, params = params, ts = base.serverTime, language = language}
    local channel = 1
    if channelType and tonumber(channelType) then
        channel = tonumber(channelType)
    end
    socketHelper:sendChatMsg(channel, selfUid, selfName, 0, "", content, false)
    if isQuitChat then
        socketHelper:chatServerLogout()
    end
end
--处理接收数据更新消息
function chatVoApi:updateGameData(content, channel)
    local type = content.type
    local params = content.params
    if type ~= nil and params ~= nil then
        if type == 61 then
            if acXlpdVoApi and params and params[1] ~= playerVoApi:getUid() then
                acXlpdVoApi:refreshMyTeamInfoByMsg(params[2])
            end
        elseif type == 54 then
            local retTb = params.retTb
            if retTb and retTb.newAllRechargeNums and acQmsdVoApi then
                acQmsdVoApi:setAllRechargeNums(retTb.newAllRechargeNums)
            end
        elseif type == 53 then
            local retTb = params.retTb
            if retTb and retTb.scores and acEatChickenVoApi then
                -- print("allianceVoApi:getSelfAlliance().name=====>>>>",allianceVoApi:getSelfAlliance()["name"])
                if allianceVoApi:isHasAlliance() and retTb.allianceName and retTb.allianceName == allianceVoApi:getSelfAlliance()["name"] then
                    acEatChickenVoApi:setNewAllianceScores(retTb.scores)
                end
            end
        elseif type == 35 then
            if params.uid ~= playerVoApi:getUid() then
                worldBaseVoApi:updateBaseStatus(9, params)
            end
        elseif type == 31 then
            if base.allianceHelpSwitch == 1 then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance then
                    local uid = params.uid
                    local id = params.id
                    if uid and uid ~= playerVoApi:getUid() and allianceHelpVoApi then
                        if id then
                            allianceHelpVoApi:addHelpNum(id)
                            allianceHelpVoApi:setFlag(1, 0)
                        else
                            local function callback()
                                allianceHelpVoApi:setFlag(1, 0)
                            end
                            allianceHelpVoApi:formatData(1, callback)
                        end
                    end
                end
            end
        elseif type == 30 then
            if base.allianceHelpSwitch == 1 then
                local uid = params.uid
                local idTab = params.idTab
                if uid and uid ~= playerVoApi:getUid() and idTab and SizeOfTable(idTab) > 0 and allianceHelpVoApi then
                    for k, id in pairs(idTab) do
                        allianceHelpVoApi:removeHelpData(1, id)
                        allianceHelpVoApi:removeHelpData(2, id)
                    end
                    allianceHelpVoApi:setFlag(1, 0)
                    allianceHelpVoApi:setFlag(2, 0)
                end
            end
        elseif type == 29 then
            if base.allianceHelpSwitch == 1 then
                local uid = params.uid
                local newhelp = params.newhelp
                if uid and uid ~= playerVoApi:getUid() and newhelp and allianceHelpVoApi then
                    allianceHelpVoApi:addAllHelpData(newhelp)
                    allianceHelpVoApi:setFlag(1, 0)
                end
            end
        elseif type == 28 then
            local retTb = params.retTb
            if retTb and retTb.data and acChristmasFightVoApi then
                if retTb.ts > acChristmasFightVoApi:getLastUpdateTime() then
                    if retTb.data.devil then
                        acChristmasFightVoApi:setSnowmanData(retTb.data.devil)
                    end
                    acChristmasFightVoApi:setFlag(0)
                    acChristmasFightVoApi:setLastUpdateTime(retTb.ts)
                end
            end
        elseif type == 27 then
            if base.serverWarLocalSwitch == 1 then
                local rankData = params
                if rankData and SizeOfTable(rankData) > 0 then
                    local function sortFunc(a, b)
                        if a and b and a[3] and b[3] then
                            return a[3] < b[3]
                        end
                    end
                    table.sort(rankData, sortFunc)
                    for k, v in pairs(rankData) do
                        local params1 = {subType = 4, contentType = 3, message = {key = "serverWarLocal_chatSystemMessage", param = v}, ts = base.serverTime}
                        chatVoApi:addChat(1, 0, "", 0, "", params1, base.serverTime)
                    end
                end
            end
        elseif type == 26 then
            -- if activityVoApi:isStart("xinfulaba") == true then
            local name = params.name
            local point = params.point
            if name and point then
                print("name", name)
                print("point", point)
                acLuckyCatVoApi:setNewShowData(name, point)
            end
            -- end
        elseif type == 25 then
            if base.platWarSwitch == 1 then
                if params and platWarVoApi and platWarVoApi.updateInfo then
                    platWarVoApi:updateInfo(params)
                    eventDispatcher:dispatchEvent("platWar.updateDonateMorale", {})
                end
            end
        elseif type == 24 then
            if base.platWarSwitch == 1 then
                if params and platWarVoApi and platWarVoApi.updateInfo then
                    platWarVoApi:updateInfo(params)
                    eventDispatcher:dispatchEvent("platWar.updateDonateTroops", {})
                end
            end
        elseif type == 23 then
            if base.localWarSwitch == 1 then
                local uid = params[1]
                if uid and uid == playerVoApi:getUid() then
                elseif localWarVoApi and localWarVoApi.setIsNewReport then
                    localWarVoApi:setIsNewReport(1, 0)
                end
            end
        elseif type == 22 then
            if base.localWarSwitch == 1 then
                local jobid = params[1]
                local infoData = params[2]
                local uid = params[3]
                if uid and uid == playerVoApi:getUid() then
                elseif jobid and infoData then
                    if localWarVoApi and localWarVoApi.setOfficeByType then
                        localWarVoApi:setOfficeByType(jobid, infoData)
                        if localWarVoApi.setOfficeFlag then
                            localWarVoApi:setOfficeFlag(0)
                        end
                    end
                end
            end
        elseif type == 21 then
            local uid = params.uid
            if uid and uid == playerVoApi:getUid() then
            else
                if params.isProtect == true then
                    eventDispatcher:dispatchEvent("alienMines.mineChange", {{x = params.x, y = params.y, isProtect = true}})
                else
                    alienMinesVoApi:setBaseVoByXY(params.vv.x, params.vv.y, params.vv)
                    eventDispatcher:dispatchEvent("alienMines.mineChange", {{x = params.vv.x, y = params.vv.y, vv = params.vv}})
                end
                
            end
        elseif type >= 10 and type <= 13 then
            if base.serverWarTeamSwitch == 1 then
                if type == 13 then
                    local isApply = params[1] or 0
                    if serverWarTeamVoApi and serverWarTeamVoApi.setIsApply then
                        serverWarTeamVoApi:setIsApply(isApply)
                    end
                    -- if allianceVoApi:isHasAlliance()==true then
                    --           local battleMemList=params[2]
                    --           if battleMemList then
                    --           if serverWarTeamVoApi:getLastSetMemTime()==0 then
                    --            serverWarTeamVoApi:formatMemList(battleMemList)
                    --            serverWarTeamVoApi:setMemFlag(0)
                    --            end
                    --           end
                    --    end
                elseif type == 12 then
                    local warId = params[1]
                    local roundIndex = params[2]
                    local battleID = params[3]
                    local currentWarId = serverWarTeamVoApi:getServerWarId()
                    if currentWarId and warId and currentWarId == warId then
                        if roundIndex and battleID then
                            local battleVo = serverWarTeamVoApi:getBattleVoByID(roundIndex, battleID)
                            if battleVo and battleVo.winnerID then
                            else
                                serverWarTeamVoApi:updateAfterBattle()
                            end
                        end
                    end
                elseif type == 11 then
                    if allianceVoApi:isHasAlliance() == true then
                        local lastTime = params[1]
                        local basedonatenum = params[2]
                        local basetroops = params[3]
                        if lastTime and basedonatenum then
                            if lastTime > serverWarTeamVoApi:getLastDonateTime() then
                                serverWarTeamVoApi:setBaseDonateInfo(lastTime, basedonatenum, basetroops)
                                serverWarTeamVoApi:setDonateFlag(0)
                            end
                        end
                    end
                elseif type == 10 then
                    if allianceVoApi:isHasAlliance() == true then
                        local lastTime = params[1]
                        local battleMemList = params[2]
                        if lastTime and battleMemList then
                            if lastTime > serverWarTeamVoApi:getLastSetMemTime() then
                                serverWarTeamVoApi:setLastSetMemTime(lastTime)
                                serverWarTeamVoApi:formatMemList(battleMemList)
                                serverWarTeamVoApi:setMemFlag(0)
                            end
                        end
                    end
                end
            end
        elseif type == 8 then
            allianceVoApi:setAllianceByAid(params)
        elseif type == 9 then
            if channel and tonumber(channel) and tostring(playerVoApi:getPlayerAid()) == tostring(tonumber(channel) - 1) then
                for k, v in pairs(params) do
                    if v == "null" then
                        params[k] = nil
                    end
                end
                local uid = params[1]
                local donate = params[2]
                local weekDonate = params[3]
                local sid = params[4]
                local level = params[5]
                local exp = params[6]
                local donateTime = params[7]
                local point = params[8]
                if uid then
                    if tostring(uid) ~= tostring(playerVoApi:getUid()) then
                        if point and allianceVoApi:isHasAlliance() then
                            local updateData = {point = point}
                            allianceVoApi:formatSelfAllianceData(updateData)
                        end
                        
                        if donateTime and donateTime >= allianceMemberVoApi:getDonateTime(uid) then
                            if donate then
                                local oldDonate = allianceMemberVoApi:getDonate(uid)
                                if donate > oldDonate then
                                    allianceMemberVoApi:setDonate(uid, donate)
                                end
                            end
                            if weekDonate then
                                -- if donateTime>allianceMemberVoApi:getDonateTime(uid) then
                                local isSameWeek = G_getWeekDay(donateTime, allianceMemberVoApi:getDonateTime(uid), true)
                                if isSameWeek then
                                    local oldWeekDonate = allianceMemberVoApi:getWeekDonate(uid)
                                    if weekDonate > oldWeekDonate then
                                        allianceMemberVoApi:setWeekDonate(uid, donateTime, weekDonate)
                                    end
                                else
                                    allianceMemberVoApi:setWeekDonate(uid, donateTime, weekDonate)
                                end
                                -- end
                            end
                        end
                        if sid then
                            if (tonumber(sid) or tonumber(RemoveFirstChar(sid))) == 0 or sid == "alliance" then
                                local selfAlliance = allianceVoApi:getSelfAlliance()
                                if selfAlliance then
                                    local oldMaxnum = selfAlliance.maxnum
                                    if level and level > selfAlliance.level then
                                        allianceVoApi:setAllianceLevel(level)
                                        local isUnlockSkill = false
                                        for k, v in pairs(allianceSkillCfg) do
                                            if tostring(v.allianceUnlockLevel) == tostring(level) then
                                                isUnlockSkill = true
                                            end
                                        end
                                        local newAlliance = allianceVoApi:getSelfAlliance()
                                        local newMaxnum = newAlliance.maxnum
                                        local tipStr = ""
                                        tipStr = getlocal("alliance_levelup", {level})
                                        if newMaxnum > oldMaxnum then
                                            tipStr = tipStr..","..getlocal("alliance_levelup_unlock_maxnum")
                                            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_levelup_unlock_maxnum",{level}),28)
                                        end
                                        if isUnlockSkill then
                                            tipStr = tipStr..","..getlocal("alliance_levelup_unlock_newskill")
                                            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_levelup_unlock_newskill",{level}),28)
                                        end
                                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 28)
                                    end
                                    if exp and exp > selfAlliance.exp then
                                        allianceVoApi:setAllianceExp(exp)
                                    end
                                end
                            else
                                sid = tonumber(sid) or tonumber(RemoveFirstChar(sid))
                                local oldLevel = allianceSkillVoApi:getSkillLevel(sid)
                                if level and level > oldLevel then
                                    allianceSkillVoApi:setSkillLevel(sid, level)
                                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_levelup_skill", {getlocal(allianceSkillCfg[sid].name), level}), 28)
                                end
                                local oldExp = allianceSkillVoApi:getSkillExp(sid)
                                if exp and exp > oldExp then
                                    allianceSkillVoApi:setSkillExp(sid, exp)
                                end
                                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_levelup_skill",{getlocal(allianceSkillCfg[sid].name),level}),28)
                            end
                        end
                        
                    end
                    G_isRefreshAllianceMemberTb = true
                end
            end
        elseif type == 100 then
            --[[删除某个坐标点：{"reciver":"","content":{"contentType":4,"params":{"category":"del","data":[6,3]},"type":100,"ts":1417206271},"sendername":"","sender":"","recivername":"","type":"chat","channel":1}
            增加某个坐标点：{"reciver":"","content":{"contentType":4,"params":{"category":"add","data":[6,3]},"type":100,"ts":1417206280},"sendername":"","sender":"","recivername":"","type":"chat","channel":1}
            坦克数量改变: {"reciver":"","type":"chat","content":{"contentType":4,"type":100,"ts":1417206561,"params":{"data":10990,"category":"num"}},"sendername":"","channel":1,"sender":"","recivername":""}--]]
            if params.category == "del" then
                acJidongbuduiVoApi:delRecordList(params.data)
            elseif params.category == "add" then
                acJidongbuduiVoApi:addRecordList(params.data)
            elseif params.category == "num" then
                acJidongbuduiVoApi:setServerLeftTankNum(params.data)
            end
        elseif type == 101 then
            --[[ ["content"] = {
                ["params"] = {
                    ["data"] = 166640,
                },
                ["type"] = 101,
                ["contentType"] = 4,
                ["ts"] = 1418183075,
            },--]]
        elseif type == 14 then
            if(rpShopVoApi)then
                rpShopVoApi:pushMessage(params)
            end
        elseif type == 114 then
            dailyAnswerVoApi:setNumberOfQuestion(params.data[1][2])
            dailyAnswerVoApi:setAnswerNum(params.data[1])
            dailyAnswerVoApi:setRankList(params.data[2])
            dailyAnswerVoApi:setRankList(params.data[3])
            
        elseif type == 113 then
            dailyAnswerVoApi:setRankList(params.data)
        elseif type == 115 then
            local message = getlocal("dailyAnswer_tab1_rank_tip")
            local selfUid = playerVoApi:getUid()
            local selfName = playerVoApi:getPlayerName()
            local language = G_getCurChoseLanguage()
            local content = {subType = 4, contentType = 3, message = message, ts = base.serverTime, language = language, paramTab = {}}
            
            self:addChat(1, selfUid, selfName, 0, "", content, base.serverTime)
            if dailyAnswerVoApi then
                dailyAnswerVoApi:clear()
            end
        elseif type == 15 then
            if(BossBattleVoApi)then
                BossBattleVoApi:pushMessage(params)
            end
        elseif type == 17 then
            if channel and tonumber(channel) and tostring(playerVoApi:getPlayerAid()) == tostring(tonumber(channel) - 1) then
                for k, v in pairs(params) do
                    if v == "null" then
                        params[k] = nil
                    end
                end
                local uid = params[1]
                local userApoint = params[6]
                local apoint = params[2]
                local alevel = params[3]
                local apoint_at = params[4]
                local ainfo = params[5]
                if uid then
                    if tostring(uid) ~= tostring(playerVoApi:getUid()) then
                        
                        if allianceVoApi:isHasAlliance() then
                            local alliance = allianceVoApi:getSelfAlliance()
                            local oldApoint = alliance.apoint
                            if oldApoint and oldApoint > apoint then
                            else
                                local updateData = {apoint = apoint, alevel = alevel, apoint_at = apoint_at, ainfo = ainfo}
                                allianceVoApi:formatSelfAllianceData(updateData)
                            end
                            
                        end
                    end
                    if userApoint then
                        local oldUserApoint = allianceMemberVoApi:getApoint(uid)
                        if oldUserApoint and oldUserApoint > userApoint then
                        else
                            allianceMemberVoApi:setApoint(uid, userApoint, apoint_at)
                        end
                    end
                    
                    G_isRefreshAllianceMemberTb = true
                end
            end
        elseif type == 20 then
            if channel and tonumber(channel) and tostring(playerVoApi:getPlayerAid()) == tostring(tonumber(channel) - 1) then
                for k, v in pairs(params) do
                    if v == "null" then
                        params[k] = nil
                    end
                end
                local uid = params.uid
                local aname = params.aname
                local setname_at = params.settime
                if tostring(uid) ~= tostring(playerVoApi:getUid()) then
                    if aname and allianceVoApi:isHasAlliance() then
                        local updateData = {name = aname, setname_at = setname_at}
                        allianceVoApi:formatSelfAllianceData(updateData)
                    end
                end
            end
            local data = {}
            data.aName = params.aname
            worldBaseVoApi:updateBaseStatus(8, data)
        elseif type == 32 then --除夕之夜活动玩家攻击年兽伤害同步
            if(acNewYearsEveVoApi)then
                acNewYearsEveVoApi:pushMessage(params)
            end
        elseif type == 33 then --港台周年狂欢活动同步集齐五福的玩家个数
            if acAnniversaryBlessVoApi then
                acAnniversaryBlessVoApi:pushMessage(params)
            end
        elseif type == 34 then --发送军团邮件
            local uid = params.uid
            if uid and uid ~= playerVoApi:getUid() then
                allianceVoApi:setSendEmailNum()
            end
        elseif type == 36 then
            --更新世界地图矿点数据
            worldBaseVoApi:updateBaseStatus(10, params)
        elseif type == 37 and channel and tonumber(channel) == 1 then
            --过期的金矿
            if params.overgm then
                local x = params.overgm[1]
                local y = params.overgm[2]
                local level = params.overgm[3] or 0
                --刷新指定的矿点
                eventDispatcher:dispatchEvent("worldScene.refreshMine", {{x = x, y = y, lv = level}})
                do return end
            end
            local refresh = false
            for k, dir in pairs(params["newGoldMine"]) do
                refresh = true
                -- goldMineVoApi:addGoldMine(tonumber(mine.mid),tonumber(mine.level),tonumber(mine.disappearTime))
                -- local direction=goldMineVoApi:getMineDirection(tonumber(mine.x),tonumber(mine.y))
                local dirName = goldMineVoApi:getDirectionName(tonumber(dir))
                local alienOpen = alienTechVoApi:isCanGatherAlienRes()
                local newParams = {}
                local paramTab = {}
                paramTab.functionStr = "map"
                paramTab.addStr = "immediately_to_collect"
                local blankLb = " "
                if G_getCurChoseLanguage() == "cn" then
                    blankLb = ""
                end
                if alienOpen == true then
                    newParams = {subType = 4, contentType = 3, message = {key = "goldmine_refresh_chatmessage", param = {dirName, getlocal("and_text")..blankLb..getlocal("alien_tech_sub_title3"), goldMineVoApi:getExploitTime()}}, ts = base.serverTime, paramTab = paramTab}
                else
                    newParams = {subType = 4, contentType = 3, message = {key = "goldmine_refresh_chatmessage", param = {dirName, blankLb, goldMineVoApi:getExploitTime()}}, ts = base.serverTime, paramTab = paramTab}
                end
                chatVoApi:addChat(1, 0, "", 0, "", newParams, base.serverTime)
            end
            if refresh == true then
                goldMineVoApi:setRefreshNewMineFlag(true)
            end
        elseif type == 38 and base.wl == 1 then
            if params.wl then
                playerVoApi:setWorldLv(tonumber(params.wl))
            end
            if params.exp then
                playerVoApi:setCurWorldExp(tonumber(params.exp))
            end
        elseif type == 39 then
            if channel and tonumber(channel) and tostring(playerVoApi:getPlayerAid()) == tostring(tonumber(channel) - 1) then
                if(allianceFubenVoApi)then
                    allianceFubenVoApi:updateAllianceBoss(params)
                end
            end
        elseif type == 40 then --攻击叛军数据
            local uid = params.uid
            local rebelInfo = params.rebelInfo
            if rebelInfo then
                local reflectId = rebelInfo.id
                local hp = tonumber(rebelInfo.rebelLeftLife) or 0
                local place
                if rebelInfo.id then
                    place = rebelVoApi:getRebelByReflectId(reflectId)
                elseif rebelInfo.place then
                    place = rebelInfo.place
                end
                if place and place[1] and place[2] then
                    local baseVo = worldBaseVoApi:getBaseVo(place[1], place[2])
                    if(baseVo and baseVo.type == 7)then
                        if hp < 0 then
                            hp = 0
                        end
                        if baseVo.hp > hp then
                            baseVo.hp = hp
                        end
                        if hp == 0 then
                            rebelVoApi:removeRebelByReflectId(reflectId)
                        end
                    end
                end
                if base.isRebelOpen == 1 and hp > 0 then
                    -- 判断是否为自己军团人员攻打叛军
                    local memberVo = allianceMemberVoApi:getMemberByUid(tonumber(uid))
                    -- 是自己军团的人攻打叛军，则在军团建筑头顶显示叛军的图标
                    if memberVo and SizeOfTable(memberVo) > 0 then
                        rebelVoApi:addRebelFind(reflectId)
                    end
                end
            end
        elseif type == 41 then --滚动提示（vip,人物等级，声望等）
            if base.scroll == 1 then
                local note = params.notices
                if note then
                    if tonumber(note.type) == 7 then --系统滚屏公告
                        noteVoApi:addScrollNote(note)
                    end
                else
                    jumpScrollMgr:addScrollMessage(params)
                end
            end
        elseif type == 42 then
            local rebelInfo = params.rebel
            if rebelInfo then
                for k, dir in pairs(rebelInfo) do
                    local paramTab = {}
                    paramTab.functionStr = "map"
                    paramTab.addStr = "go_siege"
                    local dirName = goldMineVoApi:getDirectionName(tonumber(dir))
                    local params = {subType = 4, contentType = 3, message = {key = "world_rebel_appear_notice", param = {dirName}}, ts = base.serverTime, paramTab = paramTab}
                    chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
                end
            end
        elseif type == 43 then --辞旧迎新活动动画处理
            if acCjyxVoApi and acCjyxVoApi.showFireworksEffectDialog then --播放全屏礼花弹
                acCjyxVoApi:showFireworksEffectDialog(params)
            end
        elseif type == 44 then --每日捷报点赞
            local praiseNum = params.praiseNum
            local journalsNum = params.journalsNum
            if praiseNum and journalsNum and dailyNewsVoApi then
                local curJournalsNum = dailyNewsVoApi:getJournalsNum()
                local curPraiseNum = dailyNewsVoApi:getPraiseNum()
                if curJournalsNum == journalsNum and curPraiseNum < praiseNum then
                    dailyNewsVoApi:setPraiseNum(praiseNum)
                    eventDispatcher:dispatchEvent("dailyNewsHeadlines.praiseNum", {})
                end
            end
        elseif type == 45 then --每日捷报评论
            local comment = params.selectIndex
            local commentPlayer = params.commentPlayer
            local journalsNum = params.journalsNum
            if comment and commentPlayer and journalsNum and dailyNewsVoApi then
                local curJournalsNum = dailyNewsVoApi:getJournalsNum()
                if curJournalsNum == journalsNum then
                    dailyNewsVoApi:setComment(comment, commentPlayer)
                    -- eventDispatcher:dispatchEvent("dailyNewsHeadlines.praiseNum",{})
                end
            end
        elseif type == 46 then --军团城市操作相关
            local uid = playerVoApi:getUid()
            if tonumber(uid) ~= tonumber(params.uid) and base.allianceCitySwitch == 1 then
                local changeType = params.type
                if changeType == 1 or changeType == 2 or changeType == 6 then --1：创建军团城市，2：搬迁军团城市，6：移除军团城市
                    local oldpinfo, pinfo, alliance = params.oldpinfo, params.pinfo, params.alliance
                    if oldpinfo then
                        worldScene:removeAllianceCity(oldpinfo, alliance)
                    end
                    if pinfo and alliance then
                        worldScene:createAllianceCity(pinfo, alliance)
                        local myAlliance = allianceVoApi:getSelfAlliance()
                        if myAlliance and myAlliance.aid == alliance.aid then --如果是同一个军团的话就更新城市领地数据
                            allianceCityVoApi:updateData({alliancecity = {pinfo = pinfo}}) --更新城市数据
                        end
                    end
                elseif changeType == 3 or changeType == 4 then --拓展或者回收军团领地
                    local mid, alliance = params.mid, params.alliance
                    local recycleFlag = false
                    if changeType == 4 then
                        recycleFlag = true
                    end
                    worldScene:createOrRecycleTerritory(mid, alliance, recycleFlag) --刷新城市领地
                elseif changeType == 5 then --开启城市保护罩
                    local x, y, ptEndTime = params.x, params.y, params.ptEndTime
                    worldScene:addCityProtect(x, y, ptEndTime)
                end
            end
        elseif type == 47 then --军团城市维护
            if base.allianceCitySwitch == 1 then
                local maintainType = params.mtype or 0
                if maintainType > 0 then
                    local oldpinfo = params.oldpinfo or {}
                    local aid = params.aid
                    local changeData
                    if maintainType == 1 then --警告收回所有拓展领地
                        if oldpinfo and oldpinfo[3] then ---只清除拓展的地块
                            for k, mid in pairs(oldpinfo[3]) do
                                worldScene:createOrRecycleTerritory(mid, {}, true)
                            end
                        end
                    elseif maintainType == 2 then --维护不足，收回城市及所有领地
                        worldScene:removeAllianceCity(oldpinfo, {aid = aid}) --完全清除军团城市
                    end
                    local myAlliance = allianceVoApi:getSelfAlliance()
                    if myAlliance and myAlliance.aid == aid then --维护军团是自己的军团的话，需要同步一下军团城市的数据
                        allianceCityVoApi:initCity(nil, false)
                    end
                end
            end
        elseif type == 48 then --军团城市敌军来袭
            if channel and tonumber(channel) and tostring(playerVoApi:getPlayerAid()) == tostring(tonumber(channel) - 1) and base.allianceCitySwitch == 1 then
                allianceCityVoApi:updateData(params)
            end
        elseif type == 49 then --军团城市驻防(也可用作军团城市数据刷新)
            if channel and tonumber(channel) and tostring(playerVoApi:getPlayerAid()) == tostring(tonumber(channel) - 1) and base.allianceCitySwitch == 1 then
                if params.subtype == 1 then --是玩家发送的聊天，不是服务器主动发送的
                    local uid = playerVoApi:getUid()
                    if tonumber(uid) ~= tonumber(params.uid) then
                        allianceCityVoApi:updateData(params)
                    end
                else
                    allianceCityVoApi:updateData(params)
                end
            end
        elseif type == 50 then --军团城市全员遣返驻防部队
            if channel and tonumber(channel) and tostring(playerVoApi:getPlayerAid()) == tostring(tonumber(channel) - 1) and base.allianceCitySwitch == 1 then
                local issync = params.issync or 0
                -- print("issync--------->>>>>",issync)
                if issync == 1 then --需要重新拉取队列和军团城市数据
                    local function syncHandler()
                        allianceCityVoApi:initCity(nil, false)
                    end
                    G_SyncData(syncHandler)
                end
            end
        elseif type == 51 then --更新世界地图部分地块的数据
            if base.allianceCitySwitch == 1 then
                local uid = playerVoApi:getUid()
                if tonumber(uid) ~= tonumber(params.uid) then
                    worldBaseVoApi:updateBaseStatus(type, params)
                end
            end
        elseif type == 52 then --更新军团城市数据
            if channel and tonumber(channel) and tostring(playerVoApi:getPlayerAid()) == tostring(tonumber(channel) - 1) and base.allianceCitySwitch == 1 then
                if params.alliancecity then
                    local uid = playerVoApi:getUid()
                    if tonumber(uid) ~= tonumber(params.uid) then
                        allianceCityVoApi:updateData(params)
                    end
                end
            end
        elseif type == 55 then --世界地图击飞处理
            worldBaseVoApi:updateBaseStatus(type, params)
        elseif type == 56 then --成就系统全服成就数据同步
            if achievementVoApi and achievementVoApi:isOpen() == 1 then
                local uid = playerVoApi:getUid()
                if uid ~= params.uid then
                    achievementVoApi:onAvtFinished(params)
                end
            end
        elseif type == 57 then --军团锦标赛全员数据推送
            if championshipWarVoApi and championshipWarVoApi:isOpen() == 1 then
                local uid = playerVoApi:getUid()
                if params then
                    if uid ~= params.uid then
                        if params.stageNum then --同步通关数
                            print("sync stage num ----->", params.stageNum)
                            championshipWarVoApi:setAllianceStageNum(params.stageNum)
                        end
                        if params.apply then --同步申请参战人数
                            print("sync apply num ----->", params.apply)
                            championshipWarVoApi:setApply(params.apply)
                        end
                    end
                end
            end
        elseif type == 58 then -- 军团旗帜更新数据
            local selfAlliance = allianceVoApi:getSelfAlliance()
            local uid = playerVoApi:getUid()
            if uid ~= params.uid then
                if params.syncAlFlag then
                    if selfAlliance and selfAlliance.aid == params.aid then
                        G_getAlliance(nil, false)
                    end
                else
                    --如果该玩家同属一个军团则更新军团旗帜数据
                    if selfAlliance and selfAlliance.aid == params.aid then
                        allianceVoApi:formatSelfAllianceData(params.data)
                    end
                    -- 更新军团列表数据
                    local allianceInfo = {aid = params.aid, banner = params.data.banner}
                    allianceVoApi:setAllianceByAid(allianceInfo)
                    --更新世界地图军团旗帜显示
                    worldBaseVoApi:updateBaseStatus(type, params)
                end
                
            end
        elseif type == 59 then -- 军团旗帜解锁数据
            local selfAlliance = allianceVoApi:getSelfAlliance()
            local uid = playerVoApi:getUid()
            if uid ~= params.uid and selfAlliance and selfAlliance.aid == params.aid then
                -- 和发起消息玩家是同一个军团且不是发起消息玩家
                for i, v in ipairs(params.unlock) do
                    for kk, vv in pairs(v) do
                        allianceVoApi:setFlagNewTips(i, kk, vv)
                    end
                end
            end
        elseif type == 60 and channel and tonumber(channel) == 1 then --保护矿（contentType 4）
            --ptype : 1 新生成， 2 要移除
            if params.ptype == 2 and params.rmList and SizeOfTable(params.rmList) > 0 then
                local rmAllList = {}
                for k, v in pairs(params.rmList) do
                    local x = v[1]
                    local y = v[2]
                    local level = 0--保护矿没有用，为了跟金矿统一，防止出现bug，
                    table.insert(rmAllList, {x = x, y = y, lv = level})
                end
                --刷新指定的矿点
                eventDispatcher:dispatchEvent("worldScene.refreshMine", rmAllList)
                do return end
            elseif params.ptype == 1 and channel and tonumber(channel) == 1 then--新矿
                local newParams = {}
                local paramTab = {}
                paramTab.functionStr = "map"
                paramTab.addStr = "immediately_to_collect"
                newParams = {subType = 4, contentType = 3, message = {key = "privateMine_refresh_chatmessage", param = {}}, ts = base.serverTime, paramTab = paramTab}
                chatVoApi:addChat(1, 0, "", 0, "", newParams, base.serverTime)
                privateMineVoApi:setRefreshNewMineFlag(true)
            end
        elseif type == 62 and params and params.bossMine and airShipVoApi:isCanEnter() == true then --欧米伽小队
            for kk, vv in pairs(params.bossMine) do
                if vv[1] then
                    local xPox, yPox = vv[1][1], vv[1][2]
                    local posStr =  "(" .. xPox .. "," .. yPox .. ")"
                    local paramTab = {}
                    paramTab.functionStr = "map"
                    paramTab.airShipBoss = {xPox, yPox}
                    -- paramTab.addStr = getlocal("worldRebel_position", {posStr})
                    paramTab.addStr = "go_attack"
                    local newParams = {subType = 4, contentType = 3, message = {key = "airShip_worldBossMsgText", param = {posStr}}, ts = base.serverTime, paramTab = paramTab}
                    chatVoApi:addChat(1, 0, "", 0, "", newParams, base.serverTime)
                end
            end
        else
            if type == 4 or type == 5 or type == 6 or type == 7 then
                if base.serverWarTeamSwitch == 1 then
                    if serverWarTeamVoApi and serverWarTeamVoApi.setMemFlag then
                        serverWarTeamVoApi:setMemFlag(0)
                    end
                    if serverWarTeamVoApi and serverWarTeamVoApi.setIsMemChange then
                        serverWarTeamVoApi:setIsMemChange(1)
                    end
                end
                if base.allianceHelpSwitch == 1 then
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance and tonumber(selfAlliance.aid) > 0 and allianceHelpVoApi then
                        local function callback()
                            allianceHelpVoApi:setFlag(1, 0)
                        end
                        allianceHelpVoApi:formatData(1, callback)
                    end
                end
                if serverWarTeamVoApi then
                    serverWarTeamVoApi:setWarInfoExpireTime(0)
                end
                --军团成员变动的时候，要发送alliance.get刷新军团数据，因为成员上限有可能会变
                if(type == 5 or type == 6 or type == 7)then
                    local aid = params.aid or 0
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance and tonumber(selfAlliance.aid) > 0 and tonumber(aid) == tonumber(selfAlliance.aid) then
                        if(G_curPlatName() == "androidarab")then
                            local selfAlliance = allianceVoApi:getSelfAlliance()
                            if(selfAlliance and params["aname"] and params["aname"] == selfAlliance.name)then
                                G_getAlliance()
                            end
                        else
                            G_getAlliance()
                        end
                    end
                end
            end
            worldBaseVoApi:updateBaseStatus(type, params)
        end
    end
end

--是否显示军衔
function chatVoApi:isShowRank(rank)
    if rank and rankCfg and rankCfg.chatShowRank and rank >= rankCfg.chatShowRank then
        return true
    else
        return false
    end
end

--过滤黑名单的人
function chatVoApi:filterPlayer()
    local list = G_getBlackList()
    if list then
        for i = 1, 3 do
            if self.allChatVo[i] then
                for k, v in pairs(self.allChatVo[i]) do
                    if v and v.sender then
                        for m, n in pairs(list) do
                            if n and n.uid and tonumber(v.sender) == tonumber(n.uid) then
                                table.remove(self.allChatVo[i], k)
                            end
                        end
                    end
                end
            end
        end
    end
end

function chatVoApi:isJapanV()
    local isVisible = false
    if G_getCurChoseLanguage() == "ja" then
        local vipKey = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_vipLevelShow")
        if vipKey == 2 or numKey == 0 then
        else
            isVisible = true
        end
    end
    return isVisible
end

function chatVoApi:getVipPic(isVipV, vip)
    local vipPic
    if isVipV then
        vipPic = "vipNoLevel.png"
    else
        if(G_curPlatName() == "androidkunlun" or G_curPlatName() == "14" or G_curPlatName() == "androidkunlunz")then
            vipPic = "Vip"..vip..".png"
        else
            vipPic = "chatVip"..vip..".png"
        end
    end
    return vipPic
end

--显示聊天页面，channel：聊天频道，whisperName：如果是私聊的话，是私聊的玩家名称，isCheckForbid：是否检查禁言
function chatVoApi:showChatDialog(layerNum, channel, whisperUid, whisperName, isCheckForbid)
    -- if base.shutChatSwitch == 1 then
    --        G_showTipsDialog(getlocal("chat_sys_notopen"))
    -- do return end
    -- end
    --检测是否被禁言
    if isCheckForbid and isCheckForbid == true and self:canChat(layerNum) == false then
        do return end
    end
    local buildVo = buildingVoApi:getBuildingVoByBtype(15)[1]--军团建筑
    if base.isAllianceSwitch == 1 and buildVo and buildVo.status >= 0 then
        tbArr = {getlocal("chat_world"), getlocal("chat_alliance"), getlocal("chat_private")}
    else
        tbArr = {getlocal("chat_world"), getlocal("chat_private")}
    end
    if channel == nil then
        channel = 0
    end
    require "luascript/script/game/scene/gamedialog/chatDialog/chatDialog"
    require "luascript/script/game/scene/gamedialog/chatDialog/chatDialogTab1"
    require "luascript/script/game/scene/gamedialog/chatDialog/chatDialogTab2"
    require "luascript/script/game/scene/gamedialog/chatDialog/chatDialogTab3"
    local td = chatDialog:new(nil, channel, whisperName, whisperUid)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("chat"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
    -- if whisperUid and whisperName then
    -- td:changeReciver(whisperName,nil,whisperUid)
    -- else
    -- td:tabClick(tonumber(channel))
    -- end
end

function chatVoApi:useDataWithSpecially( sData )
	if sData.content.paramTab and sData.content.paramTab.functionStr then
		local playerCurAid = playerVoApi:getPlayerAid()
		-- print("playerCurAid + 1 == sData.channel======>>>>>",playerCurAid + 1 , sData.channel)
		if sData.content.paramTab.functionStr == "double11NewWithRedBag" and acDouble11NewVoApi and playerCurAid and playerCurAid > 0 and playerCurAid + 1 == sData.channel then--用于双11红包图标在聊天显示的唯一标识
            local redBagTb = sData.content.paramTab.redBagTb
            acDouble11NewVoApi:setRedBagTagbaseIdx(1) --设置唯一标识
            
            if redBagTb and redBagTb.redtype then
                sData.content.paramTab.redBagTb.tag = acDouble11NewVoApi:getRedBagTagbaseIdx() + 1019
            end
            
            if redBagTb and redBagTb.redtype and redBagTb.redtype == 2 and acDouble11NewVoApi then
                local redBagTb = G_clone(sData.content.paramTab.redBagTb)
                redBagTb.ts = sData.content.ts
                acDouble11NewVoApi:setReceivedCorpRedbagTb(redBagTb)
            else
                --print("error in useDataWIthSpecially~~~~~~~")
            end
	    elseif sData.content.paramTab.functionStr =="acXssd2019WithRedBag" and acXssd2019VoApi and playerCurAid and playerCurAid > 0 and playerCurAid + 1 == sData.channel then
	    	local redBagTb = sData.content.paramTab.redBagTb
            acXssd2019VoApi:setRedBagTagbaseIdx(1) --设置唯一标识
            if G_isToday(redBagTb.redbuyedTs) == true then
	            if redBagTb then
	                sData.content.paramTab.redBagTb.tag = acXssd2019VoApi:getRedBagTagbaseIdx() + 2019
	                -- print("sData.content.paramTab.redBagTb.tag=====",sData.content.paramTab.redBagTb.tag)
	            end

		        if redBagTb and acXssd2019VoApi then
		            local redBagTb = G_clone(sData.content.paramTab.redBagTb)
		            redBagTb.ts = sData.content.ts
		            acXssd2019VoApi:setReceivedCorpRedbagTb(redBagTb)
		        else
		        	--print("error in useDataWIthSpecially~~~~~~~")
		        end
		    end
	    end
    end
end

function chatVoApi:loadChatEmoji(isRelease)
    local count = SizeOfTable(self:getChatEmojiCfg().animation)
    if isRelease == true then
        for i = 1, count do
            spriteController:removePlist("public/chatEmoji_" .. i .. ".plist")
            spriteController:removeTexture("public/chatEmoji_" .. i .. ".png")
        end
        spriteController:removePlist("public/chatEmojiImages.plist")
        spriteController:removeTexture("public/chatEmojiImages.png")
    else
        G_addResource8888(function()
            for i = 1, count do
                spriteController:addPlist("public/chatEmoji_" .. i .. ".plist")
                spriteController:addTexture("public/chatEmoji_" .. i .. ".png")
            end
            spriteController:addPlist("public/chatEmojiImages.plist")
            spriteController:addTexture("public/chatEmojiImages.png")
        end)
    end
end

function chatVoApi:getChatEmojiCfg()
    local chatEmojiCfg = G_requireLua("config/gameconfig/chatEmojiCfg")
    if chatEmojiCfg.animation == nil then
        --*********** 后续再增加动画只需要配置下边的animation帧数据即可 ***********
        chatEmojiCfg.animation = {
            -- [1]:总帧数, [2]:每帧间隔时间/{特殊动作的区间帧间隔时间，区间帧的最后一帧停留时间}, [3]:最后一帧停留时间
            ["f1"] = {14, {{["1-4"] = 0.083, ["4"] = 1}, {["5-14"] = 0.083}}, 1.5},
            ["f2"] = {14, 0.125, 1.5},
            ["f3"] = {16, 0.125},
            ["f4"] = {14, 0.142},
            ["f5"] = {19, 0.1, 1.5},
        }
    end
    return chatEmojiCfg
end

function chatVoApi:toNumberChatEmojiId(emojiId)
    if type(emojiId) == "string" and string.sub(emojiId, 1, 1) == "f" then
        emojiId = RemoveFirstChar(emojiId)
    end
    --*********** TEST（若配置的动画文件[animation]与数值配置的数据[faceList]数量不一致时，该逻辑可完美规避报错情况。但界面表现为重复表情动画） **********
    -- local emojiSize = SizeOfTable(self:getChatEmojiCfg().faceList)
    -- local animationSize = SizeOfTable(self:getChatEmojiCfg().animation)
    -- if tonumber(emojiId) > animationSize then
    -- emojiId = emojiId - (emojiSize - animationSize)
    -- end
    --*********** TEST（若配置的动画文件[animation]与数值配置的数据[faceList]数量不一致时，该逻辑可完美规避报错情况。但界面表现为重复表情动画） **********
    return tonumber(emojiId)
end

function chatVoApi:getChatEmojiAnimation(emojiId)
    emojiId = self:toNumberChatEmojiId(emojiId)
    local firstFrameSp = CCSprite:createWithSpriteFrameName("chatEmoji_" .. emojiId .. "_1.png")
    if firstFrameSp then
        local chatEmojiAnimCfg = self:getChatEmojiCfg().animation
        if chatEmojiAnimCfg["f"..emojiId] then
            local frameCount = chatEmojiAnimCfg["f"..emojiId][1]
            local delayPerUnit = chatEmojiAnimCfg["f"..emojiId][2]
            local endDelayTime = chatEmojiAnimCfg["f"..emojiId][3] --最后一帧停留时间
            
            local action
            if type(delayPerUnit) == "table" then
                local seqArry = CCArray:create()
                for k, v in pairs(delayPerUnit) do
                    local startI, endI, perUnit, endIDelayTime
                    for m, n in pairs(v) do
                        if tonumber(m) then
                            endIDelayTime = n
                        else
                            local temp = Split(m, "-")
                            startI = tonumber(temp[1])
                            endI = tonumber(temp[2])
                            perUnit = n
                        end
                    end
                    local fArr = CCArray:create()
                    for i = startI, endI do
                        local frameName = "chatEmoji_" .. emojiId .. "_" .. i .. ".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
                        fArr:addObject(frame)
                    end
                    local animation = CCAnimation:createWithSpriteFrames(fArr, perUnit)
                    local animate = CCAnimate:create(animation)
                    seqArry:addObject(animate)
                    if endIDelayTime then
                        seqArry:addObject(CCDelayTime:create(endIDelayTime))
                    end
                end
                if endDelayTime then
                    seqArry:addObject(CCDelayTime:create(endDelayTime))
                end
                action = CCSequence:create(seqArry)
            else
                local frameArray = CCArray:create()
                for i = 1, frameCount do
                    local frameName = "chatEmoji_" .. emojiId .. "_" .. i .. ".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
                    frameArray:addObject(frame)
                end
                local animation = CCAnimation:createWithSpriteFrames(frameArray, delayPerUnit)
                local animate = CCAnimate:create(animation)
                if endDelayTime then
                    action = CCSequence:createWithTwoActions(animate, CCDelayTime:create(endDelayTime))
                else
                    action = animate
                end
            end
            firstFrameSp:runAction(CCRepeatForever:create(action))
            return firstFrameSp
        end
    end
end

function chatVoApi:getChatEmoji(emojiId)
    local emojiAnimation = self:getChatEmojiAnimation(emojiId)
    if emojiAnimation then
        local emojiBg = CCSprite:createWithSpriteFrameName("chatEmoji_bg.png")
        emojiAnimation:setAnchorPoint(ccp(0.5, 0))
        emojiAnimation:setPosition(emojiBg:getContentSize().width / 2, 0)
        emojiBg:setOpacity(40)
        emojiBg:addChild(emojiAnimation)
        return emojiBg
    elseif self:isChatEmojiStatic(emojiId) == true then
        local emojiBg = CCSprite:createWithSpriteFrameName("chatEmojiStatic_bg.png")
        local emojiIcon = self:getChatEmojiIcon(emojiId)
        if emojiIcon then
            emojiIcon:setAnchorPoint(ccp(0.5, 0))
            emojiIcon:setPosition(emojiBg:getContentSize().width / 2, 0)
            emojiBg:addChild(emojiIcon)
        end
        return emojiBg
    end
end

function chatVoApi:getChatEmojiIcon(emojiId, isLock)
    local isStaticEmoji = self:isChatEmojiStatic(emojiId)
    emojiId = self:toNumberChatEmojiId(emojiId)
    if isStaticEmoji == false and isLock == true then
        return GraySprite:createWithSpriteFrameName("chatEmoji_" .. emojiId .. "_" .. 1 .. ".png")
    else
        return CCSprite:createWithSpriteFrameName("chatEmoji_" .. emojiId .. "_" .. 1 .. ".png")
    end
end

function chatVoApi:isChatEmojiStatic(emojiId)
    if self:getChatEmojiCfg().animation[emojiId] == nil then
        return true
    end
    return false
end

function chatVoApi:isChatEmojiUnlock(emojiId)
    if self:isChatEmojiStatic(emojiId) == true then
        return true
    end
    local unlockChatEmoji = playerVoApi:getUnLockChatEmoji()
    for k, id in pairs(unlockChatEmoji) do
        if emojiId == id then
            return true
        end
    end
    return false
end

function chatVoApi:getChatEmojiData()
    local unlockData, lockData, staticEmojiData = {}, {}, {}
    local emojiList = self:getChatEmojiCfg().faceList
    for k, v in pairs(emojiList) do
        if self:isChatEmojiStatic(v.id) == true then
            table.insert(staticEmojiData, v)
        else
            if self:isChatEmojiUnlock(v.id) == true then
                table.insert(unlockData, v)
            else
                table.insert(lockData, v)
            end
        end
    end
    table.sort(unlockData, function(a, b) return self:toNumberChatEmojiId(a.id) < self:toNumberChatEmojiId(b.id) end)
    table.sort(lockData, function(a, b) return self:toNumberChatEmojiId(a.id) < self:toNumberChatEmojiId(b.id) end)
    table.sort(staticEmojiData, function(a, b) return self:toNumberChatEmojiId(a.id) < self:toNumberChatEmojiId(b.id) end)
    return unlockData, lockData, staticEmojiData
end

function chatVoApi:showChatEmojiSmallDialog(layerNum, sendEventCallback)
    socketHelper:getUnlockChatEmoji(function(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                require "luascript/script/game/scene/gamedialog/chatDialog/chatSmallDialog"
                chatSmallDialog:showEmojiDialog(layerNum, getlocal("chatEmoji_smallDialogTitle"), sendEventCallback)
            end
        end
    end)
end

--购买聊天表情接口
--@ emojiId:表情ID
function chatVoApi:requestBuyChatEmoji(callback, emojiId)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:buyChatEmoji(socketCallback, emojiId)
end

--协力攀登活动组队邀请聊天页面显示内容
function chatVoApi:createXlpdInviteView(msgBg, isUserSelf, xlpd_invite, layerNum)
    local titleFontSize, smallFontSize = 20, 18
    msgBg:setContentSize(CCSizeMake(400, 218))
    --标题
    for k = 1, 2 do
        local pointSp = CCSprite:createWithSpriteFrameName("newPointRect.png")
        pointSp:setPosition(msgBg:getContentSize().width / 2 + (2 ^ k - 3) * 60, msgBg:getContentSize().height - 22)
        msgBg:addChild(pointSp)
        local pointLineSp = CCSprite:createWithSpriteFrameName("newPointLine.png")
        local angle = (k == 1) and 180 or 0
        pointLineSp:setPosition(pointSp:getPositionX() + (2 ^ k - 3) * (15 + pointLineSp:getContentSize().width / 2), pointSp:getPositionY())
        pointLineSp:setRotation(angle)
        msgBg:addChild(pointLineSp)
    end
    local pdTitleLb = GetTTFLabelWrap(getlocal("xlpd_invite_title"), titleFontSize, CCSizeMake(msgBg:getContentSize().width - 100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    pdTitleLb:setPosition(msgBg:getContentSize().width / 2, msgBg:getContentSize().height - 22)
    pdTitleLb:setColor(G_ColorYellowPro)
    msgBg:addChild(pdTitleLb)
    --聊天框边角
    local cornerSp = CCSprite:createWithSpriteFrameName("xlpd_corner.png")
    if isUserSelf == true then
        cornerSp:setAnchorPoint(ccp(0, 1))
        cornerSp:setPosition(msgBg:getContentSize().width + 2, msgBg:getContentSize().height - 9)
    else
        cornerSp:setAnchorPoint(ccp(1, 1))
        cornerSp:setPosition(-2, msgBg:getContentSize().height - 9)
        cornerSp:setFlipX(true)
    end
    msgBg:addChild(cornerSp)
    
    local tvSize = CCSizeMake(msgBg:getContentSize().width - 40, msgBg:getContentSize().height - 100)
    
    local strTb = {
        getlocal("activity_xlpd_troops", {xlpd_invite.leader}), --队伍名称
        getlocal("xlpd_invite_pd", {xlpd_invite.pd}), --队伍攀登值
        getlocal("xlpd_invite_playerNum", {xlpd_invite.pn, xlpd_invite.max}), --队伍人数
        getlocal("xlpd_invite_condition", {xlpd_invite.pdLv}), --进队要求
        xlpd_invite.msg, --进队宣言
    }
    
    local color = ccc3(130, 218, 196)
    local function getInviteContent()
        local textWidth = tvSize.width - 20
        local tb, height = {}, 0
        for k, v in pairs(strTb) do
            local lb, lbHeight = G_getRichTextLabel(v, {color, G_ColorYellowPro, color}, smallFontSize, textWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            lb:setAnchorPoint(ccp(0, 1))
            table.insert(tb, {lb, lbHeight})
            height = lbHeight + height
        end
        return tb, height
    end
    
    local tmpLb = GetTTFLabel(getlocal("xlpd_invite_title"), smallFontSize)
    local lineHeight = tmpLb:getContentSize().height
    
    local tb, height = getInviteContent()
    local tv = G_createTableView(tvSize, 1, CCSizeMake(tvSize.width, height), function(cell, cellSize, idx, cellNum)
        
        local posY = height
        local tb = getInviteContent()
        for k, v in pairs(tb) do
            local lb, lbHeight = v[1], v[2]
            lb:setPosition(15, posY)
            cell:addChild(lb)
            
            local pointSp = CCSprite:createWithSpriteFrameName("reportWhiteBg.png")
            pointSp:setColor(ccc3(92, 210, 122))
            pointSp:setAnchorPoint(ccp(0, 0.5))
            pointSp:setScale(6 / pointSp:getContentSize().width)
            pointSp:setPosition(0, posY - lineHeight / 2)
            cell:addChild(pointSp)
            
            posY = posY - lbHeight
        end
    end)
    tv:setAnchorPoint(ccp(0, 0))
    tv:setPosition(20, 60)
    tv:setTableViewTouchPriority(-(layerNum - 1) * 20 - 4)
    msgBg:addChild(tv)
    if height > tvSize.height then
        tv:setMaxDisToBottomOrTop(80)
    else
        tv:setMaxDisToBottomOrTop(0)
    end
    
    --加入队伍
    local function joinHandler()
        -- print("xlpd_invite.ts===.>>>",xlpd_invite.ts,xlpd_invite.pdLv)
        if ( xlpd_invite.ts and G_isToday(xlpd_invite.ts) == false ) or not xlpd_invite.ts then
            G_showTipsDialog(getlocal("teamsTimeOutStr")..getlocal("backstage62001"))
            do return end
        end
        local vo = activityVoApi:getActivityVo("xlpd")
        if vo and activityVoApi:isStart(vo) == true then
            local function realJoin()
                local function joinCallBack()
                    acXlpdVoApi:chatSendJoinInfo()
                    G_showTipsDialog(getlocal("xlpd_join_success")..getlocal("xlpd_chngeNumCur", {acXlpdVoApi:getTodayLastChngeNum()}))
                end
                acXlpdVoApi:xlpdRequest("join", {teamid = xlpd_invite.tid}, joinCallBack)
            end
            
            local status, stb = acXlpdVoApi:getJoinTeamStatus(xlpd_invite.pdLv)
            -- print("status--->>",status)
            if status == 4 then
                G_showTipsDialog(getlocal("teamsTimeOutStr"))
                do return end
            end
            if status == 3 then
                G_showTipsDialog(getlocal("backstage62003"))
                do return end
            end
            local str = ""
            if status == 1 then
                str = getlocal("xlpd_join_tip2", {xlpd_invite.leader})
            elseif status == 2 then --有队伍
                local teamid = acXlpdVoApi:getMyTeamAnyInfo()
                if teamid == xlpd_invite.tid then
                    G_showTipsDialog(getlocal("backstage62004"))
                    do return end
                end
                local zn, maxZn, playerNum = stb[1] or 0, stb[2] or 3, stb[3] or 1
                if zn >= maxZn then --已达到调换队伍的次数
                    G_showTipsDialog(getlocal("backstage62005"))
                    do return end
                else
                    if playerNum > 1 then --队伍里有其他人则需要给出跳队提示
                        str = getlocal("xlpd_join_tip1")
                    else
                        str = getlocal("xlpd_join_tip2", {xlpd_invite.leader})
                    end
                end
            end
            
            G_showSecondConfirm(layerNum + 1, true, true, getlocal("dialog_title_prompt"), str, false, realJoin)
        else
            G_showTipsDialog(getlocal("acOver"))
        end
    end
    local joinBtn = G_createBotton(msgBg, ccp(msgBg:getContentSize().width / 2, 40), {getlocal("joinTeam"), 18}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", joinHandler, 0.6, -(layerNum - 1) * 20 - 3)
    if isUserSelf == true then
        joinBtn:setEnabled(false)
    end
end
