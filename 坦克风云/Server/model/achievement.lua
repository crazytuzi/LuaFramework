function model_achievement(uid,data)
    local self = {
        uid = uid,
        level = 0, -- 成就等级
        uinfo = {}, -- 玩家成就数据信息{a0=0,a1=10}(a0表示是否初始化，1有，0或为空则没有)
        reward = {}, -- 玩家领奖信息{p={a1={1522120087,0,0}},a={a1={{1522120087,1522120087,1522120087},{1522120087,0,0},{1522120087,1522120087,0}}}}(p个人领奖,a全服领奖)
        info = {}, -- 其他信息{rank={a1={1,1},a2={2,1}},cup={t={armor={1,"a1"},weapon={2,"a6"},sequip={1,"a3"}},a={a1={2,3},a2={1,1}}}}(排行信息(id:{排名,服id}),显示奖杯信息a全服领奖奖杯，t总奖杯 (a={id={index}},t={模块={1个人或2全服,id}})
        liked = 0,
        achvnum = 0, -- 完成的成就个数
        achvat = 0, -- 最近一次完成成就的时间
        updated_at = 0,
    }

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

        return true
    end

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then
                data[k] = v
            end
        end

        return data
    end

    function self.setAchieveData(data)
        if data and next(data) then
            for aid,num in pairs(data) do
                if aid and num and num > 0 then
                    if self.uinfo[aid] then
                        if num > self.uinfo[aid] then
                            self.uinfo[aid] = num
                        end
                    else
                        self.uinfo[aid] = num
                    end
                end
            end
        end
    end

    -- 统计已完成的成就
    function self.countAchievement()
        local orgnum = self.achvnum
        self.achvnum = 0

        if type(self.reward.p) == "table" then
            for _,rewardInfo in pairs(self.reward.p) do
                for _,rewardAt in pairs(rewardInfo) do
                    if rewardAt > 0 then
                        self.achvnum = self.achvnum + 1
                    end
                end
            end
        end

        if type(self.reward.a) == "table" then
            for _,rewardInfo in pairs(self.reward.a) do
                for _,info in pairs(rewardInfo) do
                    for _, rewardAt in pairs(info) do
                        if rewardAt > 0 then
                            self.achvnum = self.achvnum + 1
                        end
                    end
                end
            end
        end

        -- 如果成就数有增加，设置最新时间
        if orgnum < self.achvnum then
            self.achvat = os.time()
        end
    end

    -- 点赞
    function self.like()
        self.liked = self.liked + 1
    end

    -- 取消点赞
    function self.unlike()
        if self.liked > 0 then
            self.liked = self.liked - 1
        end
    end

    -- 已点赞
    function self.hasLiked(likeUid,uid)
        local params = {uid=tonumber(uid),achvid=tonumber(likeUid)}
        return getDbo():getRow("select id from user_like_achievement where uid = :uid and achvid = :achvid",params)
    end

    function self.setLikedRecord(setUid,likeUid,value)
        local db, ret = getDbo()
        
        if value == 1 then
            ret = db:insert("user_like_achievement",{
                uid=setUid,
                achvid=likeUid,
                updated_at=os.time()
            })
        else
            setUid = db:escape(tonumber(setUid))
            likeUid = db:escape(tonumber(likeUid))
            local sql = string.format("delete from user_like_achievement where uid = %d and achvid = %d limit 1",setUid,likeUid)
            ret = db:query(sql)
        end

        return (ret or 0) > 0
    end

    function self.getLiked()
        return self.liked
    end

    return self
end
