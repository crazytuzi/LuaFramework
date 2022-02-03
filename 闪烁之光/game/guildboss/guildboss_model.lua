-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-07
-- --------------------------------------------------------------------
GuildbossModel = GuildbossModel or BaseClass()

local table_sort = table.sort
local table_insert = table.insert

function GuildbossModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function GuildbossModel:config()
    self.guildboss_red_list = {}
    self.role_rank_list = {} --319排行协议列表
end

--==============================--
--desc:退出公会的时候清空掉相关的数据
--time:2018-06-13 09:38:22
--@return 
--==============================--
function GuildbossModel:clearGuildBossInfo()
    self.base_info = {}             -- 基础信息
    self.first_pass_list = {}       -- 公会boss首通奖励
    self.day_box_list = {}          -- 每日宝箱
    self.guildboss_red_list = {}    -- 公会红点相关，主要包含了首通奖励红点，每日击杀红点以及拥有次数的红点
    self._initFirstPassData = {}    --首通
end

function GuildbossModel:updateGuildRedStatus(bid, status)
    local base_data = Config.FunctionData.data_base
    local bool = MainuiController:getInstance():checkIsOpenByActivate(base_data[6].activate)
    if bool == false then return end

    local _status = self.guildboss_red_list[bid]
    if _status == status then return end
    
    self.guildboss_red_list[bid] = status

    -- 更新场景红点状态
    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, {bid = bid, status = status}) 

    --限时活动
    local limitRed = false
    if self.base_info and self.base_info.count then
        if ActivityController:getInstance():getBossActivityDoubleTime() == true and self.base_info.count > 0 then
            limitRed = true
        end
    end
    -- 事件用于同步更新公会主ui的红点
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildRedStatus, bid, status) 
end

--==============================--
--desc:公会副本是否有红点状态
--time:2018-06-15 04:16:12
--@return 
--==============================--
function GuildbossModel:checkGuildDunRedStatus()
    if not self.base_info then return false end
    if next(self.base_info) == nil then
        --判断是否是首次加入公会
        self:updateGuildRedStatus(GuildConst.red_index.boss_times, true)
    end
    for k,v in pairs(self.guildboss_red_list) do
        if v == true then
            return true
        end
    end
    return false
end

--==============================--
--desc:根据类型获取红点，
--time:2018-06-15 04:34:59
--@type:GuildConst.red_index
--@return 
--==============================--
function GuildbossModel:getRedStatusByType(type)
    return self.guildboss_red_list[type]
end

--==============================--
--desc:公会副本基础信息,或者清除
--time:2018-06-09 03:26:15
--@return 
--==============================--
function GuildbossModel:updateGuildDunBaseInfo(data)
    local length = Config.GuildDunData.data_guildboss_list_length
    local need_update_red_status = false
    if self.base_info == nil or self.base_info.count ~= data.count then
        need_update_red_status = true
    end
    self.base_info = data -- fid:当前id max_id:历史最高副本id count:剩余挑战次数 type:重置类型（0：正常 1：章节回退）buy_count:购买次数
    GlobalEvent:getInstance():Fire(GuildbossEvent.UpdateGuildDunBaseInfo)
    --判断一下当前的Boss是否能打
    -- 更新红点
    if data and data.max_id >= length then
        self:updateGuildRedStatus(GuildConst.red_index.boss_times, 0)
    end
    if need_update_red_status == true then
        --判断全部通关的时候
        local count = self.base_info.count
        if data.max_id >= length then
            if data.info and next(data.info) ~= nil then
                if data.info[1].hp and data.info[1].hp == 0 then
                    count = 0
                end
            end
        end
        self:updateGuildRedStatus(GuildConst.red_index.boss_times, (count > 0))
    end
end
--获取挑战次数
function GuildbossModel:getChangeCount()
    if self.base_info then
        if not self.base_info.count then return false end
        if self.base_info.count > 0 then
            return true
        else
            return false
        end
    end
end

--==============================--
--desc:获取基础信息
--time:2018-06-09 03:43:51
--@return 
--==============================--
function GuildbossModel:getBaseInfo()
    return self.base_info
end

--==============================--
--desc:更新剩余挑战次数以及购买次数
--time:2018-06-11 05:46:01
--@count:
--@buy_count:
--@buy_type:FALSE为普通购买TRUE为挑战购买
--@return 
--==============================--
function GuildbossModel:updateBaseWithTimes(count, buy_count, buy_type)
    if self.base_info == nil then 
        self.base_info = {}
    end
    self.base_info.count = count
    self.base_info.buy_count = buy_count 
    GlobalEvent:getInstance():Fire(GuildbossEvent.UpdateGuildBossChallengeTimes, buy_type) 
    -- 更新红点
    self:updateGuildRedStatus(GuildConst.red_index.boss_times, (self.base_info.count > 0))
end

--==============================--
--desc:首通奖励数据
--time:2018-06-12 03:28:41
--@return 
--==============================--
function GuildbossModel:initFirstPassRewardList(data)    
    -- self._initFirstPassData = data
    -- local red_status = false
    -- for i,v in pairs(self._initFirstPassData.award_list) do
    --     if v.status == 1 then
    --         red_status = true
    --     end
    -- end
    -- GlobalEvent:getInstance():Fire(GuildbossEvent.UpdateFirstPassReward)
end
function GuildbossModel:getFirstPassRewardList()
    local return_list = {}  --0:未达成
    local return_list1 = {} --1:可领取
    local return_list2 = {} --2:已领取
    if not self._initFirstPassData.award_list then return end
    for i,v in pairs(self._initFirstPassData.award_list) do
        if v.status == 0 then
            table_insert(return_list, v)
        elseif v.status == 1 then
            table_insert(return_list1, v)
        elseif v.status == 2 then
            table_insert(return_list2, v)
        end
    end

    if #return_list ~= 0 then
        for i,v in pairs(return_list) do
            table_insert(return_list1,v)
        end
    end
    if #return_list2 ~= 0 then
        for i,v in pairs(return_list2) do
            table_insert(return_list1,v)
        end
    end
    return return_list1
end

--请求领取的信息处理
function GuildbossModel:setChargeGetPassData(fid)
    -- for i,v in pairs(self._initFirstPassData.award_list) do
    --     if v.fid == fid then
    --         v.status = 2
    --     end
    -- end
    -- local red_status = false
    -- for i,v in pairs(self._initFirstPassData.award_list) do
    --     if v.status == 1 then
    --         red_status = true
    --     end
    -- end
    -- GlobalEvent:getInstance():Fire(GuildbossEvent.UpdateFirstPassReward)
end

--==============================--
--desc:根据排名获取伤害排名奖励
--time:2018-06-12 08:03:40
--@rank:
--@return 
--==============================--
function GuildbossModel:getRankAward(rank)
    rank = rank or 1
    for k,v in pairs(Config.GuildDunData.data_rank_reward) do
        if v.rank1 <= rank and rank <= v.rank2 then
            return v.award
        end
    end
    return {}
end

--==============================--
--desc:初始化每日宝箱奖励的
--time:2018-06-13 09:43:03
--@data_list:
--@return 
--==============================--
function GuildbossModel:initDayBoxRewardsStatus(data_list)
    self.day_box_list = {}
    for i=1, Config.GuildDunData.data_chapter_box_length do
        self.day_box_list[i] = 0
    end

    local red_status = false 
    for i,v in ipairs(data_list) do
        self.day_box_list[v.fid] = v.num
        if v.num > 0 and red_status == false then
            red_status = true
        end
    end
    GlobalEvent:getInstance():Fire(GuildbossEvent.UpdateBoxRewardsStatus)
end

--==============================--
--desc:更新指定宝箱数量
--time:2018-06-13 06:39:48
--@fid:
--@num:
--@return 
--==============================--
function GuildbossModel:updateBoxRewards(fid, num)
    if self.day_box_list[fid] == nil then return end
    self.day_box_list[fid] = num

    local red_status = false 
    for k,v in pairs(self.day_box_list) do
        if v > 0 then
            red_status = true 
            break
        end
    end
    -- GlobalEvent:getInstance():Fire(GuildbossEvent.UpdateBoxRewardsStatus, true) 
end

--==============================--
--desc:返回击杀宝箱的数量状态
--time:2018-06-13 06:42:39
--@return 
--==============================--
function GuildbossModel:getBoxRewardList()
    return self.day_box_list or {}
end

--保存排行榜协议
function GuildbossModel:setRaknRoleList(list)
    self.role_rank_list = list
end


--获取前三个
function GuildbossModel:getRaknRoleTopThreeList()
    local list = {{rank = 1,name = TI18N("虚位以待")},{ rank = 2, name = TI18N("虚位以待") },{rank = 3,name = TI18N("虚位以待")}}
    if self.role_rank_list.rank_list and next(self.role_rank_list.rank_list or {}) ~= nil then
        local rank_list = self.role_rank_list.rank_list
        for i,v in ipairs(rank_list) do
           for i2,v1 in ipairs(list) do
                if v.rank == v1.rank then
                    list[i2] = v
                end
           end
        end
    end
    return  list
end

function GuildbossModel:__delete()
end
