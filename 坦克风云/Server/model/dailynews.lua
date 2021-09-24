--[[
    每日捷报
]]
local dailyNews = {
    articles = {}
}

local cacheKeys = {
    -- 投过票的用户
    voteuser = "z%s.dailynews.voteuser.%d",
}

-- 生成缓存key
local function mkCacheKey(cacheKey, ...)
    if cacheKeys[cacheKey] then
        return string.format(cacheKeys[cacheKey], getZoneId(), ...)
    end
end

function dailyNews.init()
    dailyNews.day = dailyNews.getDay()
    dailyNews.weets = getWeeTs()
    dailyNews.ts = os.time()
end

-- 获取从1970年开始到现在的天数
function dailyNews.getDay()
    local zone = getConfig('base.TIMEZONE')
    local weets = getWeeTs()
    weets = weets + zone * 3600
    local day = weets / 86400

    return day
end

-- 设置投票用户
function dailyNews:setVoteUser(uid)
    local key = mkCacheKey("voteuser",self.weets)
    local redis = getRedis()
    redis:sadd(key,uid)
    redis:expire(key,172800)
end

-- 用户是否投票
-- return bool
function dailyNews:isVote(uid)
    local key = mkCacheKey("voteuser",self.weets)
    local redis = getRedis()
    return redis:sismember(key,uid)
end

-- 增加一篇新的资讯
function dailyNews.addArticle(article)
    article.day = dailyNews.day
    article.updated_at = dailyNews.ts
    getDbo():insert("news_article",article)
end

-- 增加一条新的头条
function dailyNews.addHeadline(data)
    local headline = {
        day = dailyNews.day,
        title=data.title,
        content=data.content,
        updated_at = dailyNews.ts,
    }
    getDbo():insert("news_headline",headline)
end

-- 按天获取所有的资讯记录
function dailyNews:getArticlesFromDb(day)
    if not day then day = self.day end
    return getDbo():getAllRows("select id,title,content from news_article where day = :day",{day=day})
end

-- 按赛季获取资讯记录(一个赛季不能重复生成)
function dailyNews:getSkyladderAritcle(season)
    return getDbo():getAllRows("select id,title,content,ext1 from news_article where title in('d23','d26') and ext1=:season",{season=season})
end

-- 按天获取头条
function dailyNews:getHeadlineFromDb(day)
    if not day then day = self.day end
    return getDbo():getRow("select id,title,content,goodpost,comment,commenter from news_headline where day = :day",{day=day})
end

-- 按头条id获取头条
function dailyNews:getHeadlineById(newsId)
    return getDbo():getRow("select id,title,content,goodpost,comment,commenter from news_headline where id = :id",{id=newsId})
end

-- 更新头条相关信息
function dailyNews:updateHeadLine(data)
    data.updated_at = self.ts
    getDbo():update("news_headline",data,{"id"})
end

-- 获取记录的历史公共数据(需要累计的，比如连续xx天第一)
function dailyNews:getHistoryCommonData()
    local db = getDbo()
    local sql = "select * from news_history_common where updated_at < :weets"
    local result = db:getAllRows(sql,{weets=self.weets})

    local data = {}
    for k,v in pairs(result) do
        v.updated_at = tonumber(v.updated_at)
        data[v.name] = v
    end

    return data
end

-- 保存历史公共数据
function dailyNews:saveHistoryCommonData(data)
    local db = getDbo()
    for k,v in pairs(data) do
        db:update("news_history_common",{value1=v.value1,value2=v.value2,name=v.name,updated_at=self.weets},{"name"})
    end
end

-- 更新记录的用户历史数据(战力,关卡等数据)
function dailyNews:updateHistoryUserOldData()
    local sql = string.format("update news_history_user set fcrankold=fcrank,challangerankold=challangerank,arenarankold=arenarank,ranklvold=ranklv,accessorypointold=accessorypoint,heropointold=heropoint,updated_at=%d where updated_at < %d",self.weets,self.weets)

    getDbo():query(sql)
end

-- 设置连续保持战力第一的记录
-- value1 记录uid
-- value2 记录连续天数
function dailyNews.setFcFirst(uid,record)
    if record.updated_at < getWeeTs() then
        if tonumber(record.value1) == tonumber(uid) then
            record.value2 = tonumber(record.value2) + 1
        else
            record.value2 = 1
        end

        record.value1 = uid
        record.updated_at = os.time()
    end
end

-- 设置连续保持军衔第一的记录
-- value1 记录uid
-- value2 记录连续天数
function dailyNews.setRankFirst(uid,record)
    if record.updated_at < getWeeTs() then
        if tonumber(record.value1) == tonumber(uid) then
            record.value2 = tonumber(record.value2) + 1
        else
            record.value2 = 1
        end

        record.value1 = uid
        record.updated_at = os.time()
    end
end

-- 设置连续保持军演第一的记录
-- value1 记录uid
-- value2 记录连续天数 
function dailyNews.setArenaFirst(uid,record)
    if record.updated_at < getWeeTs() then
        if tonumber(record.value1) == tonumber(uid) then
            record.value2 = tonumber(record.value2) + 1
        else
            record.value2 = 1
        end

        record.value1 = uid
        record.updated_at = os.time()
    end
end

-- 获取有效用户相关信息(等级大于等于10的,并且20天之内登录过)
-- 用户信息/配件/英雄/英雄装备/
function dailyNews.getValidUsers()
    local limit = 1000
    local lastLoginTs = os.time() - 1728000
    local uid = 0
    local users = {}
    local db = getDbo()
    while true do
        -- TEST
        -- lastLoginTs = 0
        local sql = string.format("select user.uid uid, user.rank rank, aes.used usedaes, hero.hero hinfo, equip.info einfo from userinfo user left join accessory aes on user.uid = aes.uid left join hero on user.uid = hero.uid left join equip on user.uid = equip.uid where user.uid > %d and user.level >= 10 and user.logindate > %d order by user.uid limit %s",uid,lastLoginTs,limit)
        local data = db:getAllRows(sql)

        if not next(data) then 
            break
        end

        for k,v in pairs(data) do
            users[v.uid] = {
                accessory=json.decode(v.usedaes) or {},
                hero = json.decode(v.hinfo) or {},
                equip = json.decode(v.equip) or {},
                rank=v.rank or 0,
            }
            uid = tonumber(v.uid)
        end
    end

    return users
end

-- 用户历史数据(前一天的战力,关卡排行,配件强度,英雄强度,军演等级,军衔)
function dailyNews.insertHistoryUser(uids)
    local db = getDbo()
    local ts = os.time()
    for k,v in pairs(uids) do
        db:insert("news_history_user",{
            uid=v,
            updated_at = 0,
        })
    end
end

-- 获取已经记录的历史用户id(确定是否有新用户记录生成)
function dailyNews.getHitoryUids()
    local db = getDbo()
    local result = db:getAllRows("select uid from news_history_user")
    local uids = {}
    if type(result) == "table" then
        for k,v in pairs(result) do
            uids[v.uid] = v.uid
        end
    end

    return uids
end

-- 获取新增的需要保存历史记录的用户id
function dailyNews.getAddUids(validUsers,historyUids)
    local uids = {}
    for k,v in pairs(validUsers) do
        if not historyUids[k] then 
            table.insert(uids,k)
        end
    end
    return uids
end

-- d1 战力上升最大的用户(当前排名要小于昨日排名)
function dailyNews.getFcMaxUp()
    return getDbo():getRow("select uid,fcrank,fcrankold, fcrankold-fcrank as up from news_history_user where updated_at > 0 and fcrank < fcrankold order by up desc limit 1")
end

-- d3 关卡排行上升最大的用户(当前排名要小于昨日排名)
function dailyNews.getChallengeMaxUp()
    return getDbo():getRow("select uid,challangerank,challangerankold, challangerankold-challangerank as up from news_history_user where updated_at > 0 and challangerank < challangerankold order by up desc limit 1")
end

-- d4 军衔上升最大的用户(当前军衔要大于昨日军衔)
function dailyNews.getRankMaxUp()
    return getDbo():getRow("select uid,ranklv,ranklvold, ranklv-ranklvold as up from news_history_user where updated_at > 0 and ranklv > ranklvold order by up desc limit 1")
end

-- d6 军演上升最大的用户(当前排名要小于昨日排名)
function dailyNews.getArenaMaxUp()
    return getDbo():getRow("select uid,arenarank,arenarankold, arenarankold-arenarank as up from news_history_user where updated_at > 0 and arenarank < arenarankold order by up desc limit 1")
end

-- d9 配件强度上升最大的用户(当前强度要大于昨日强度)
function dailyNews.getAccessoryPointMaxUp()
    return getDbo():getRow("select uid,accessorypoint,accessorypointold, accessorypoint-accessorypointold as up from news_history_user where updated_at > 0 and accessorypoint > accessorypointold order by up desc limit 1")
end

-- d10 英雄强度上升最大的用户(当前强度要大于昨日强度)
function dailyNews.getHeroPointMaxUp()
    return getDbo():getRow("select uid,heropoint,heropointold, heropoint-heropointold as up from news_history_user where updated_at > 0 and heropoint > heropointold order by up desc limit 1")
end

-- 获取一批用户的昵称,图片,等级等信息
function dailyNews.getUserinfoList(uidList)
    local list = {}
    if type(uidList) == "table" and next(uidList) then
        local sql = "select uid,nickname,pic,bpic,apic,level,fc,alliancename,rank from userinfo where uid in(%s)"
        local uids = table.concat(uidList,",")
        local data = getDbo():getAllRows(string.format(sql,uids))
        for k,v in pairs(data) do
            list[v.uid] = v
        end
    end

    return list
end

-- 获取一批军团的信息
function dailyNews.getAllianceInfoList(aidlist)
    local list = {}
    if next(aidlist) then
        local result = M_alliance.getalliancesname{aids=json.encode(aidlist)}
        if result and type(result.data) == "table" then
            for k,v in pairs(result.data) do
                list[tonumber(v.aid)] = {
                    v.name,
                    v.level,
                    v.commander,
                    v.fight,
                    v.amaxnum,
                    v.memberNum,
                    v.type,
                    v.level_limit,
                    v.fight_limit,
                    v.notice,
                    v.aid,
                }
            end
        end
    end

    return list
end

-- 获取对应资讯上升最大的相关信息
function dailyNews:getMaxUpInfo(newsId)
    local upInfo
    if newsId == "d1" then 
        upInfo =  self.getFcMaxUp()
    elseif newsId == "d3" then 
        upInfo = self.getChallengeMaxUp()
    elseif newsId == "d4" then 
        upInfo = self.getRankMaxUp()
    elseif newsId == "d6" then 
        upInfo = self.getArenaMaxUp()
    elseif newsId == "d9" then 
        upInfo = self.getAccessoryPointMaxUp()
    elseif newsId == "d10" then 
        upInfo = self.getHeroPointMaxUp()
    end
    
    return upInfo
end

-- 处理所有的信息生成相关的资讯及头条
function dailyNews:process()
    local dailyNewsCfg = getConfig("dailyNewsCfg")
    local historyUids = self.getHitoryUids()
    local validUsers = self.getValidUsers()

    -- 未记录历史信息的用户需要添加进历史记录表中
    local addUids = self.getAddUids(validUsers,historyUids)
    if next(addUids) then 
        self.insertHistoryUser(addUids) 
    end
    addUids = nil

    -- 公共记录
    local commonHistoryRecord = self:getHistoryCommonData()

    -- 战力榜
    local fcList = self.getFcRanking()

    -- 设置连续战力第一的记录信息
    if commonHistoryRecord.d2 and next(fcList) then
        self.setFcFirst(fcList[1],commonHistoryRecord.d2)
    end

    -- 设置用户的当前战力
    for k,v in pairs(fcList) do
        if validUsers[v] then
            validUsers[v].fcrank = k
        end
    end

    -- 关卡榜
    local challengeRankingList = self.getChallengeRanking()

    -- 设置用户的当前关卡排名
    for k,v in pairs(challengeRankingList) do
        if validUsers[v] then
            validUsers[v].challangerank = k
        end
    end

    -- 军演榜
    local arenaRankingList = self.getArenaRanking() or {}

    -- 设置军演连续第一的记录信息
    if commonHistoryRecord.d7 and next(arenaRankingList) then
        local uid = tonumber(arenaRankingList[1][1]) or 0
        local rank = tonumber(arenaRankingList[1][2]) or 0
        if uid > 1000000 and rank == 1 then
            self.setArenaFirst(uid,commonHistoryRecord.d7)
        end
    end

    -- 设置用户的当前军演排行
    for k,v in pairs(arenaRankingList) do
        if #v == 2 then
            if validUsers[v[1]] then
                validUsers[v[1]].arenarank = v[2]
            end
        end
    end

    local rankRankingList = self.getNewRankRanking()

    -- 设置军衔连续第一的记录
    if commonHistoryRecord.d5 and next(rankRankingList) then
        self.setRankFirst(rankRankingList[1],commonHistoryRecord.d5)
    end

    local accessoryCfg = getConfig("accessory")
    local db = getDbo()
    for k,v in pairs(validUsers) do
        local uid=tonumber(k) or 0
        local ranklv=tonumber(v.rank) or 0 -- 军衔等级
        local fcrank=tonumber(v.fcrank) or 0 -- 战力排名
        local challangerank=tonumber(v.challangerank) or 0 -- 关卡排名
        local arenarank=tonumber(v.arenarank) or 0 -- 军演排名
        local accessorypoint=self.getUsedAccessoryFighting(accessoryCfg,v.accessory) -- 配件强度分值
        local heropoint = self:getAllHeroPower(v.hero,v.equip) -- 英雄强度分值

        -- 设置用户今日的最新信息
        if uid > 0 then
            local sql = string.format("UPDATE news_history_user SET accessorypoint=%d , heropoint=%d , challangerank=%d , fcrank=%d , ranklv=%d , arenarank=%d WHERE uid='%d' and (accessorypoint != %d or heropoint!=%d or challangerank!=%d or fcrank!=%d or ranklv!=%d or arenarank!=%d)",accessorypoint, heropoint , challangerank , fcrank, ranklv, arenarank, uid,accessorypoint, heropoint , challangerank , fcrank, ranklv, arenarank)

            db:query(sql)
        end
    end

    validUsers = nil

    -- 生成连续第一的相关资讯
    if next(commonHistoryRecord) then
        for _,nid in pairs({"d2","d5","d7"}) do
            local continueValue = commonHistoryRecord[nid] and tonumber(commonHistoryRecord[nid].value2)
            if continueValue >= dailyNewsCfg.dailyList[nid].condition1 and ((continueValue % dailyNewsCfg.dailyList[nid].condition1) == 0) then 
                table.insert(self.articles,{
                    title=nid,
                    content={
                        id=commonHistoryRecord[nid].value1,
                        num={continueValue},
                    },
                })
            end
        end
    end

    -- 保存公共数据
    self:saveHistoryCommonData(commonHistoryRecord)

    -- 实力提升类
    for _,nid in pairs({"d1","d3","d4","d6","d9","d10",}) do
        local upInfo = self:getMaxUpInfo(nid)
        if type(upInfo) == "table" then
            upInfo.up = tonumber(upInfo.up) or 0
            if upInfo.up >= dailyNewsCfg.dailyList[nid].condition1 then
                local num = {upInfo.up}
                if nid == "d4" then
		            num = {upInfo.ranklvold}
                    -- table.insert(num,upInfo.ranklvold)
                    table.insert(num,upInfo.ranklv)
                end

                table.insert(self.articles,{
                    title=nid,
                    content={
                        id=upInfo.uid,
                        num=num,
                    },
                })
            end
        end
    end

    -- 个人排行榜类
    for _,nid in pairs({"d11","d12","d18"}) do
        local info = getNewsRanking(1,nid)
        if type(info) == 'table' and next(info) then
            info[1][2] = tonumber(info[1][2]) or 0
            if not dailyNewsCfg.dailyList[nid].condition1 or info[1][2] >= dailyNewsCfg.dailyList[nid].condition1 then
                table.insert(self.articles,{
                    title=nid,
                    content={
                        id=info[1][1],
                        num={info[1][2]},
                    },
                })
            end
        end
    end

    -- 军团排行榜类
    for _,nid in pairs({"d13"}) do
        local info = getNewsRanking(1,nid)
        if type(info) == 'table' and next(info) then
            info[1][2] = tonumber(info[1][2]) or 0
            if info[1][2] >= dailyNewsCfg.dailyList[nid].condition1 then
                table.insert(self.articles,{
                    title=nid,
                    content={
                        aid=info[1][1],
                        num={info[1][2]},
                    },
                })
            end
        end
    end

    -- 排行榜前三
    local listTb = {
        ["d14"]=fcList,
        ["d15"]=challengeRankingList,
        ["d16"]=self.getNewRankRanking(),
    }

    for nid,rankList in pairs(listTb) do
        if type(rankList) == "table" and next(rankList) then
            local news = {
                title=nid,
                content={
                    id=rankList[1],
                    ids = {rankList[1],rankList[2],rankList[3]}
                },
            }
            table.insert(self.articles,news)
        end
    end

    if switchIsEnabled('ladder') then
        -- 天梯榜结算当天生成一次资讯
        local skyladderData = self.getSkyladderHistory()
        if skyladderData then
            if skyladderData.updated_at and getWeeTs(skyladderData.updated_at) == self.weets then
            -- if skyladderData.updated_at and 1 then
                local skyladderAritcle = self:getSkyladderAritcle(skyladderData.season)
                if not next(skyladderAritcle) then
                    local skyladderUser = {}

                    -- 玩家排行
                    for k,v in pairs(skyladderData.info.p) do
                        skyladderUser[k] = {
                            v[3],
                            v[5],
                            v[4],
                            skyladderData.season,
                            v[6],
                        }
                    end

                    -- 军团排行
                    local skyladderAlliance = {}
                    for k,v in pairs(skyladderData.info.a) do
                        skyladderAlliance[k] = {
                            v[3],
                            v[5],
                            v[4],
                            skyladderData.season,
                            "",
                        }
                    end

                    -- 直接添加
                    self.addArticle({
                        title="d23",
                        content={skyladderUser=skyladderUser},
                        ext1=skyladderData.season,
                    })

                    self.addArticle({
                        title="d26",
                        content={skyladderAlliance=skyladderAlliance},
                        ext1=skyladderData.season,
                    })
                end
            end
        end
    end

    self:createArticles()
    self:createHeadline()
    self:updateHistoryUserOldData()
end

-- 创建资讯
function dailyNews:createArticles()
    local uidList = {}
    local aidList = {}

    for k,v in pairs(self.articles) do
        if v.content.id then 
            table.insert(uidList,v.content.id) 
        end

        if v.content.ids then
            for _,uid in pairs(v.content.ids) do
                table.insert(uidList,uid)
            end
        end

        if v.content.aid then
            table.insert(aidList,v.content.aid)
        end
    end

    -- 统一取所有用户的信息
    local userinfoList = self.getUserinfoList(uidList)
    local allinaceInfoList = self.getAllianceInfoList(aidList)

    uidList = nil
    aidList = nil

    for k,v in pairs(self.articles) do
        if v.content.id then
            v.content.userinfo = {}
            local userinfo = userinfoList[tostring(v.content.id)]
            if userinfo then
                table.insert(v.content.userinfo,{
                    userinfo.pic,
                    userinfo.nickname,
                    userinfo.level,
                    userinfo.fc,
                    userinfo.alliancename,
                    userinfo.uid,
                    userinfo.bpic,
                    userinfo.apic,
                })
            end

            if v.title == "d5" then
                table.insert(v.content.num, userinfo.rank or 0)
            end

            v.content.id = nil
        end

        if v.content.ids then
            v.content.username = {}
            for _,n in pairs(v.content.ids) do
                local nickname = userinfoList[tostring(n)] and userinfoList[tostring(n)].nickname or ""
                table.insert(v.content.username, nickname)
            end

            -- 新一轮高级将领军衔晋升完成，其中{xxx}晋升{xx}，{xxx}晋升{xx}，{xxx}晋升{xx}。
            -- 需要额外记录晋升后的军衔
            if v.title == "d16" then
                v.content.num = {}
                for _,n in pairs(v.content.ids) do
                    local rankLv = userinfoList[tostring(n)] and userinfoList[tostring(n)].rank or 0
                    table.insert(v.content.num, rankLv)
                end
            end

            v.content.ids = nil
        end

        if v.content.aid then
            v.content.allianceinfo = {
                allinaceInfoList[tonumber(v.content.aid)],
            }
        end

        self.addArticle({
            title=v.title,
            content=v.content
        })
    end

    self.articles = {}
    allinaceInfoList = nil
    userinfoList = nil
end

-- 创建头条
function dailyNews:createHeadline()
    local dailyNewsCfg = getConfig("dailyNewsCfg")
    local articles = self:getArticlesFromDb()
    if type(articles) == "table" and next(articles) then
        for k,v in pairs(articles) do
            local nid = v.title
            v.sortId = dailyNewsCfg.dailyList[nid].index
            v.index = dailyNewsCfg.dailyList[nid].index

            if dailyNewsCfg.dailyList[nid].condition2 and v.content.num then
                local num = tonumber(v.content.num[1]) or 0
                if num >= dailyNewsCfg.dailyList[nid].condition2[1] then
                    v.sortId = v.sortId + dailyNewsCfg.dailyList[nid].condition2[2]
                end
            end
        end

        table.sort(articles,self.newsSort)
        if not self:getHeadlineFromDb() then
            self.addHeadline(articles[1])
        end
    end
end

function dailyNews.newsSort(a,b)
    if a.sortId == b.sortId then
        return a.index > b.index
    else
        return a.sortId > b.sortId
    end
end

-- 获取所有战力排行榜
function dailyNews.getFcRanking()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.fc"
    local list = redis:zrevrange(key,0,-1)
    return list
end

-- 获取所有关卡排行榜
function dailyNews.getChallengeRanking()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.challenge"
    local list = redis:zrevrange(key,0,-1)
    return list
end

-- 获取所有军演排行榜
function dailyNews.getArenaRanking()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.arena"
    local list = redis:zrange(key,0,-1,"withscores")
    return list
end

-- 获取新军衔排行榜
function dailyNews.getNewRankRanking()
    local redis = getRedis()
    local key = "z"..getZoneId()..".dayUserNewRank.All"
    local list = redis:zrevrange(key,0,2) or {}
    return list
end

-- 获取配件战力分数
function dailyNews.getUsedAccessoryFighting(cfg,used)
    local accessoryCfg = cfg.aCfg
    local fightValueCfg = cfg.fightingValue
    local fightingValue = 0
    for k,v in pairs(used) do
        for pname,pinfo in pairs(v) do
            local quality = tonumber(accessoryCfg[pinfo[1]].quality)
            if quality then
                fightingValue = fightingValue + (1 + pinfo[2]) * fightValueCfg[pname][1][quality] + pinfo[3] * fightValueCfg[pname][2][quality]
            end
            if type(pinfo[4])=="table"  and next(pinfo[4]) then
                local rpoint=0
                for k,v in pairs(pinfo[4]) do
                    if k>2 then
                        rpoint=rpoint+v*20
                    else
                        rpoint=rpoint+v*800
                    end
                end
                fightingValue=fightingValue+math.floor(rpoint)
            end
            if pinfo[5]==1 then
                fightingValue=fightingValue+fightValueCfg[pname][3]
            end 
        end
    end
    return fightingValue
end

-- 获取所有英雄的强度值将领信息，将领装备信息
function dailyNews:getAllHeroPower(hero,einfo)
   local Power={}
   local point=0 
   if type(hero)=='table' and next(hero) then
        for k,v in pairs(hero) do
            local power =self.getHeroValue(k,v,einfo)
            table.insert(Power,power)
        end
   end 
   if next(Power) then
      table.sort(Power,function(a,b)return (a> b) end)
      for k,v in pairs (Power) do
          if k>6 then
            break
          end
          point=point+v
      end
   end

   return math.floor(point)
end

function dailyNews.getHeroValue(hid,hinfo,einfo)
    local heroCfg =getConfig('heroListCfg.'..hid)
    
    -- 英雄的等级,英雄的等级点数,英雄的品阶，英雄的技能
    
    local lvl =hinfo[1]
    local p   =hinfo[3]
    local Attr=0
    for k,v in pairs(heroCfg.heroAtt) do
        Attr=Attr+p*v[1]+lvl*v[2]
    end
    -- Attr=math.floor(Attr*10)
    Attr=Attr*10
    local skill={}
    for k1,v1 in pairs(hinfo[4]) do
        if v1 >0 then
            skill[k1]=v1
            --local skillCfg =getConfig('heroSkillCfg.'..k1)
            --Attr=Attr+(tonumber(skillCfg.skillPower)*v1)
        end
    end
    if type(hinfo[5])=='table' then
        for k2,v2 in pairs(hinfo[5]) do
            if v2 >0 then
                skill[k2]=v2
                --local skillCfg =getConfig('heroSkillCfg.'..k2)
                --Attr=Attr+(tonumber(skillCfg.skillPower)*v2)
            end
        end
        
    end
    -- 二次授勋的技能可以支持N次以后的
    if type(hinfo[7])=='table' then
        for k3,v3 in pairs(hinfo[5]) do
            if type(v3)=="table" then
                for sk,sv in pairs (v3) do
                    skill[sk]=sv
                end
                --local skillCfg =getConfig('heroSkillCfg.'..k2)
                --Attr=Attr+(tonumber(skillCfg.skillPower)*v2)
            end
        end
        
    end


      -- 将领装备-----------------------
    if moduleIsEnabled('he') == 1 then 
        local equipCfg = getConfig('equipCfg')
        local eattrs={}
        for i=1,6 do
            local sid='e'..i
            local upgrade=equipCfg[hid][sid].upgrade.att
            local grow=equipCfg[hid][sid].grow.att
            local awaken=equipCfg[hid][sid].awaken.att
            --ptb:p(equipCfg[hid][sid].awaken)
            local qlevel=1
            local plevel=1
            local alevel=0
            if type(einfo[hid])=='table' and type(einfo[hid][sid])=='table' then
                qlevel=einfo[hid][sid][1]
                plevel=einfo[hid][sid][2]
                alevel=einfo[hid][sid][3]
                --[[if alevel>0 then
                    local eskill=equipCfg[hid][sid].awaken.skill 
                    if type(eskill)=='table' and next(skill) then
                        for sk,sv in pairs (eskill) do
                            for k,v in pairs (skill) do
                                if sk==k then
                                    skill[sv]=v
                                    skill[k]=nil
                                end
                            end
                        end
                    end
                end]]
            end

            for k,v in pairs (grow)  do
                eattrs[k]=(eattrs[k] or 0) +v*qlevel
            end 
            for k,v in pairs (upgrade)  do
                eattrs[k]=(eattrs[k] or 0) +v*plevel
            end 
            for k,v in pairs (awaken)  do
                eattrs[k]=(eattrs[k] or 0) +v*alevel
            end 
        end

        if next(eattrs) then
            local point=0
            for k,v in pairs(eattrs)  do
                if k=='first' and  k=='antifirst'  then
                    point=point+v*4.5
                else
                    point=point+v*10
                end
            end
            Attr=Attr+point
        end


    end

    for sk2,sv2 in pairs(skill) do
            if sv2 >0 then
                local skillCfg =getConfig('heroSkillCfg.'..sk2)
                Attr=Attr+(tonumber(skillCfg.skillPower)*sv2)
            end
    end
    
    return Attr
end

-- 获取天梯榜数据
function dailyNews.getSkyladderHistory()
    require "model.skyladder"
    local skyladder = model_skyladder()
    local data = skyladder.getAllHistory(0,1)

    if data and type(data) == 'table' and next(data) then
        for i,v in pairs(data) do
            v.info = json.decode(v.info) or {}
        end

        return data[1]
    end
end

return dailyNews