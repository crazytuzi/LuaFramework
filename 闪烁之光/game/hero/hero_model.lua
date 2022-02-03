-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      英雄model, 客户端 lwc 策划 陈星宇
-- <br/>Create: 2018-11-14
-- --------------------------------------------------------------------
HeroModel = HeroModel or BaseClass()

local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort
local table_remove = table.remove
function HeroModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function HeroModel:config()
    --伙伴数据列表 (id :英雄唯一标识)
    --结构 self.hero_list[id] = hero_vo
    self.hero_list = {}  
    -- 伙伴bid列表的  
    --结构 self.hero_bid_list[bid] = {hero_vo1,hero_vo2}
    self.hero_bid_list = {}
    --伙伴数据数组形式存储，便于排序
    self.hero_array = Array.New() 

    --记录星级数量 self.dic_star_count[star] = n
    self.dic_star_count = {}

    --皮肤数据  结构: self.hero_skin_list[皮肤id] = 皮肤结束时间   (如果时间 == 0 表永久)
    self.hero_skin_list = nil   --nil用于判定是否初始化
    --英雄上限
    self.hero_max_count = 0
    --英雄已激活上限次数 
    self.buy_num = 0

    --英雄图书馆信息
    self.dic_pokedex_info = nil
    --英雄图书馆信息 [bid] = 数据
    self.dic_pokedex_bid = {}

    --熔炼祭坛的列表
    self.dic_fuse_info = nil
    --熔炼祭坛主界面是否显示红点
    self.is_fuse_redpoint = false
    --熔炼祭坛记录红点信息 self.dic_fuse_redpoint[bid] = true
    self.dic_fuse_redpoint = {}

    --已拥过有英雄id [bid] = 1
    self.dic_had_hero_info = {}

    --位置参数
    self.pos_param = 10
    --布阵站位信息 self.pos_list[布阵类型][pos] = v(网络返回的数据)
    --pos 结构 其值 = index * self.pos_param + pos   其中 index 表示(队伍索引 - 1)  pos 才是其在阵法上的位置
    self.pos_list = {}

    self.expedit_list = nil
    --阵法类型
    self.use_formation_type = 1
    --使用的圣器id
    self.use_hallows_id = 0

    --装备红点背包已更新 记录
    self.is_equip_redpoint_bag_update = true
    --装备红点英雄已更新 记录
    self.is_equip_redpoint_hero_update = true

    --是否延迟红点更新中 例子:self.is_delay_redpoint_update[HeroConst.RedPointType.eRPLevelUp] = true
    --目前只有升级红点用
    self.is_delay_redpoint_update = {}

    --进阶和升星材料消耗 只能写死 如果策划改了.跟着改吧
    self.upgrade_star_cost_id = 10001 
    self.upgrade_star_cost_id_2 = 10090
    --天赋技能升星的材料
    self.talent_skill_cost_id = 10450

    --升星红点背包已更新 记录
    self.is_upgradestar_redpoint_bag_update = true
    --升星红点英雄已更新 记录
    self.is_upgradestar_redpoint_hero_update = true

    --阵法 红点 (一次性的)
    self.is_redpoint_form = false
    --圣器 红点 (一次性的)
    self.is_redpoint_hallows = false

    --记录登陆时候角色的等级 判断阵法是否新解锁用
    self.record_login_lev = 0

    --符文解锁条件信息
    local artifact_one = Config.PartnerData.data_partner_const["artifact_one"].val 
    local artifact_two = Config.PartnerData.data_partner_const["artifact_two"].val
    self.artifact_lock_list = {artifact_one, artifact_two}
    self.artifact_lucky = 0 -- 符文祝福值
    self.artifact_lucky_red = false -- 祝福值红点

    --英雄信息界面 升星页签的参数  6星才限时页签(后面策划要求熔炼祭坛的也加入)
    self.hero_info_upgrade_star_param = 6
    --(4-5星的ui 和 11星ui一致) ...(6-10星的ui一致)
    self.hero_info_upgrade_star_param2 = 10
    self.hero_info_upgrade_star_param3 = 11
    self.hero_info_upgrade_star_param4 = 12

    --英雄信息界面 天赋页签的参数  6星才限时页签
    self.hero_info_talent_skill_param =  Config.PartnerSkillData.data_partner_skill_const["skill_slot"].val   
    
    --天赋技能可学习的列表 用于红点 结构 self.dic_hero_talent_skill_learn_redpoint[skill_id] = 1
    self.dic_hero_talent_skill_learn_redpoint  = {}

    self.is_need_update_talent_redpoint = true

    --穿戴在英雄身上的神装信息结构 self.hero_holy_list[id] = good_vo
    self.hero_holy_list = {}

    --穿戴在英雄身上的神装ID信息结构 self.dic_itemid_to_partner_id[id] = partner_id
    self.dic_itemid_to_partner_id = {}


    --共鸣水晶等级
    self.resonate_cystal_lev = 0

    --英雄共鸣锁定信息
    self.dic_resonate_lock_info = {}
    --共鸣石碑等级
    self.resonate_stone_level = 0
    --共鸣历史星级
    self.resonate_max_partner_lev = nil --一定要nil 有地方判断nil来决定有木有数据
    --共鸣精炼红点
    self.is_resonate_extract_redpoint = false

    --重生次数(针对 100级以下的)
    self.reset_count = 0
end

function HeroModel:resetAllData()
    self.hero_list = {} 
    self.hero_bid_list = {}
    self.hero_array = Array.New() 

    self.hero_skin_list = nil

    self.hero_holy_list = {}
    self.dic_itemid_to_partner_id = {}
    self.pos_list = {}
    self.is_delay_redpoint_update = {}
end


-------------------英雄信息--------------------------
--更新英雄信息列表 not_show_power:不显示战力变化提示
--@is_detail_info 是否是详细信息
function HeroModel:updateHeroList(data_list, not_show_power, is_detail_info)
    if not data_list then return end
    --设置数据
    for __, info in pairs(data_list) do
        self:updateHeroVo(info, not_show_power, is_detail_info)
    end
end

--更新单个英雄信息 如果没该英雄是新增
function HeroModel:updateHeroVo(info, not_show_power, is_detail_info)
    if info == nil then return end
    --新旧版本容错的
    info.id = info.partner_id
    --新旧版本容错的
    local hero_id = info.id
    local is_add = false  --判断是否增加新伙伴
    if not self.hero_list[hero_id] then
        if is_detail_info then
            return
        end
        self.hero_list[hero_id] = HeroVo.New()
        is_add = true
    end
    local hero_vo = self.hero_list[hero_id]

    if not is_detail_info then
        --获取数据缺少的项 配置表信息
        --由于出现 camp_type 的类型不对问题..暂时把此赋值开放..查看导致英雄数据bug是否还出现
        local bid = info.bid
        local config = Config.PartnerData.data_partner_base[bid]
        if config then
            for key,value in pairs(config) do
                if key ~= "skills" then 
                    info[key] = value
                end
            end
            local star = info.star or config.init_star
            if self.dic_had_hero_info[bid] then
                if self.dic_had_hero_info[bid] < star then
                    self.dic_had_hero_info[bid] = star
                end
            else
                self.dic_had_hero_info[bid] = star
            end
        end
    end
    -- 设置伙伴的角色id
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo ~= nil then
        info.rid = role_vo.rid
        info.srv_id = role_vo.srv_id
    end
    local old_vo
    local open_type = 0
    if not is_add then
        --处理战力提升特效(11007更新英雄列表时不飘战力提示)
        if not not_show_power and hero_vo.power < info.power   then 
            -- if info.resonate_lev and info.resonate_lev > 0 then
            --     --原力水晶的英雄 不显示战力飘字
            -- else
                GlobalMessageMgr:getInstance():showPowerMove( info.power-hero_vo.power,nil,hero_vo.power )
            -- end
        end

        if not is_detail_info then
            --处理升星 进阶
            if info.star and hero_vo.star < info.star then
                open_type = 1 
                old_vo = clone(hero_vo)
                if hero_vo.star == (self.hero_info_talent_skill_param[2] - 1) then
                    hero_vo.is_open_talent = true
                end
                if info.star >= 10 then
                    --清除 星级数量记录
                    self.dic_star_count = {}
                end
            elseif info.break_lev and hero_vo.break_lev < info.break_lev then 
                if not self:isResonateCystalHero(info) then --不是共鸣水晶上面的英雄才计算进阶逻辑
                    open_type = 2
                    old_vo = clone(hero_vo)
                end
            end
        end
    end

    hero_vo:updateHeroVo(info)
    if is_add then
        self.hero_array:PushBack(hero_vo)
        if not self.hero_bid_list[hero_vo.bid] then
            self.hero_bid_list[hero_vo.bid] = {}
        end
        table_insert(self.hero_bid_list[hero_vo.bid], hero_vo)
    else
        if open_type == 1 and old_vo and next(old_vo) ~= nil then
            self.ctrl:openHeroUpgradeStarExhibitionPanel(true,old_vo,hero_vo)
            --升星可能导致上阵英雄有红点
            HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPStar)
        elseif open_type == 2 and old_vo and next(old_vo) ~= nil then
            self.ctrl:openBreakExhibitionWindow(true,old_vo,hero_vo)
        end
        if is_detail_info then
            hero_vo:setInitAttr()
            GlobalEvent:getInstance():Fire(HeroEvent.Hero_Detail_Data_Update, hero_vo)
        else
            GlobalEvent:getInstance():Fire(HeroEvent.Hero_Data_Update, hero_vo)
        end
    end
end

--通过bid获取等级最高的英雄信息
function HeroModel:getTopLevHeroInfoByBid(bid)
    if not bid then return end
    local list = self.hero_bid_list[bid]
    if list then
        table_sort(list, SortTools.tableUpperSorter({"lev","power"}))
        return list[1]
    end
    return nil
end

function HeroModel:getHeroNumByBid(bid)
    if not bid then return 0 end
    local list = self.hero_bid_list[bid] or {}
    return #list
end

--根据bid 和star 获取对应的英雄信息
--@return 英雄信息列表
function HeroModel:getHeroInfoByBidStar(bid, star)
    if not bid or not star then return end
    local list = self.hero_bid_list[bid]
    if list then
        local return_list = {}
        for i, hero_vo in ipairs(list) do
            if hero_vo.star == star then
                table_insert(return_list, hero_vo)
            end
        end
        return return_list
    end
    return nil
end

--增加详细信息
function HeroModel:updateHeroVoDetailedInfo(info)
    if not info then return end
    if self.hero_list[info.partner_id] then
        for k,v in pairs(info) do
            self.hero_list[info.partner_id][k] = v
        end
        self.hero_list[info.partner_id]:setIsHadDetail(true)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Vo_Detailed_info, self.hero_list[info.partner_id])
    end
end
function HeroModel:clearHeroVoDetailedInfoByPartnerID(partner_id)
    if self.hero_list and self.hero_list[partner_id] then
        self.hero_list[partner_id]:setIsHadDetail(false)
    end
end

--清除英雄信息信息的记录
function HeroModel:clearHeroVoDetailedInfo()
    if not self.hero_list then return end
    for k,v in pairs(self.hero_list) do
        v:setIsHadDetail(false)
    end
end
--更新天赋信息
function HeroModel:updateHeroVoTalent(data_list, is_not_check)
    local is_team = false
    for i,v in ipairs(data_list) do
        if self.hero_list[v.partner_id] then
            self.hero_list[v.partner_id]:updateSkill(v.dower_skill)
            --因为天赋可能会影响影响的详细信息  这里标志要刷新一下
            self.hero_list[v.partner_id]:setIsHadDetail(false)
            if not is_team then
                if self.hero_list[v.partner_id]:isFormDrama() then
                    is_team = true
                end
            end
        end
    end
    if is_team and not is_not_check then
        --如果有剧情阵容的英雄..需要检查红点
        --检测红点
        HeroCalculate.checkAllHeroRedPoint()    
    end
end

-- 根据符石bid判断，上阵英雄中是否有已经学习的英雄
function HeroModel:checkTalentIsLearnByBid( bid )
    local is_learn = false
    for k,hero_vo in pairs(self.hero_list) do
        if hero_vo:isFormDrama() and hero_vo:checkIsHaveTalentByBid(bid) then
            is_learn = true
            break
        end
    end
    return is_learn
end

function HeroModel:setLockByPartnerid(partner_id, is_lock)
    if self.hero_list[partner_id] ~= nil then
        self.hero_list[partner_id].is_lock = is_lock or 0
    end
end

--删除英雄 
--list 
function HeroModel:delHeroDataList(list)
    if list == nil then return end
    for i,v in ipairs(list) do
        if self.hero_list[v.partner_id] then
            local temp_bid = self.hero_list[v.partner_id].bid
            self.hero_list[v.partner_id] = nil
            --同时从bid英雄列表删除该英雄记录
            local bidlist = self.hero_bid_list[temp_bid]
            if bidlist then
                for i=#bidlist,1,-1 do
                    local hero_vo = bidlist[i]
                    if hero_vo.partner_id == v.partner_id then
                        table_remove(bidlist, i)
                    end
                end
            end
        end
    end
    self.hero_array = Array.New()
    for i,v in pairs(self.hero_list) do 
        self.hero_array:PushBack(v)
    end
    

    self:checkHeroChangeRedPoint()

    GlobalEvent:getInstance():Fire(HeroEvent.Del_Hero_Event, list)
end

--检测英雄数量或者英魂发生变化的时候需要做的事情
function HeroModel:checkHeroChangeRedPoint()
    --消除熔炼祭坛的红点 删除也要重新算
    HeroCalculate.clearAllStarFuseRedpointRecord()

    --升星红点
    self.is_upgradestar_redpoint_hero_update = true
    self:checkUpgradeStarRedPointUpdate()
end

--雇佣的
function HeroModel:getExpeditHeroData()
    local hero_list = self:getAllHeroArray().items
    local list = {}

    for i,hero in ipairs(hero_list) do
        local tab = {}
        tab.power = hero.power
        tab.name = hero.name
        tab.bid = hero.bid
        tab.index = i

        tab.rid = hero.rid
        tab.srv_id = hero.srv_id
        tab.id = hero.id
        tab.star = hero.star
        tab.lev = hero.lev
        tab.use_skin = hero.use_skin
        table_insert(list, tab)
    end
   
    table.sort(hero_list, function(a, b) return b.power < a.power end)
    return hero_list
end

--获取当前拥有的英雄数据,
--@ return Array
function HeroModel:getAllHeroArray()
    return self.hero_array or Array.New()
end

--获取最高战力的英雄战力
function HeroModel:getMaxFight()
    if self.hero_array then
        self.hero_array:UpperSortByParams("power")
        local hero_vo = self.hero_array:Get(0)
        if hero_vo then
            return hero_vo.power
        end
    end
    return 0
end

--获取当前拥有英雄数据 [唯一id] = 英雄数据
function HeroModel:getHeroList()
    return self.hero_list or {}
end

--获取单个伙伴数据,id
--@id 是英雄唯一标识id 
function HeroModel:getHeroById(partner_id)
    if not self.hero_list then return end
    if not partner_id or type(partner_id) ~= "number" then return end
    return self.hero_list[partner_id] or {}
end

--根据初始星级 或者对应英雄最大进阶次数
function HeroModel:getHeroMaxBreakCountByInitStar(init_star)
    if self.dic_max_break == nil then
        local val = Config.PartnerData.data_partner_const.advanced_limit.val
        self.dic_max_break = {}
        for i,v in ipairs(val) do
            self.dic_max_break[v[1]] = v[2]
        end
    end
    return self.dic_max_break[init_star] or 0
end

--根据根据品质获取获取随机头像
function HeroModel:getRandomHeroHeadByQuality( quality)
    if self.dic_random_hero_head == nil then
        local val = Config.PartnerData.data_partner_const.random_hero_icon.val
        self.dic_random_hero_head = {}
        for i,v in ipairs(val) do
            local item_config = Config.ItemData.data_get_data(v[2])
            if item_config then
                self.dic_random_hero_head[v[1]] = item_config.icon
            end
        end
    end
    local quality = quality or 0
    if quality < 0 then
        quality = 0
    elseif quality > 5 then
        quality = 5
    end
    return self.dic_random_hero_head[quality] or 1
end

--根据阵营和星级.得到对应来源的道具id
--self.dic_source_item_ids[camp][star] = item_id
function HeroModel:getSourceHeroCombinationByCampStar(camp, star)
    if self.dic_source_item_ids == nil then
        self.dic_source_item_ids = {}
        local val = Config.PartnerData.data_partner_const.source_hero_combination.val
        for i,v in ipairs(val) do
            if self.dic_source_item_ids[v[1]] == nill then
                self.dic_source_item_ids[v[1]] = {}
            end
            self.dic_source_item_ids[v[1]][v[2]] = v[3]
        end
    end
    if self.dic_source_item_ids[camp] then
        local star = star or 0
        if star == 0 then
            star = 3 --最低星就三
        end
        return self.dic_source_item_ids[camp][star]
    end
end

--英雄上限
function  HeroModel:setHeroMaxCount(count)   --英雄上限
    if count then
        self.hero_max_count = count 
    end
end
--获取英雄上限
--return 英雄上限, 当前英雄数量
function  HeroModel:getHeroMaxCount()   --英雄上限
    local max_count = self.hero_max_count or 0
    local count = self:getAllHeroArray():GetSize()

    return max_count, count
end
--获取购买已购买英雄次数
function HeroModel:getHeroBuyNum( )
    return self.buy_num or 0
end

--获取购买已购买英雄次数
function HeroModel:setHeroBuyNum(num)
    self.buy_num = num or 0
end

function HeroModel:setHadHeroInfo(list)
    if not list then return end
    for i,v in ipairs(list) do
        if self.dic_had_hero_info[v.partner_id] then
            if self.dic_had_hero_info[v.partner_id] < v.max_star then
                self.dic_had_hero_info[v.partner_id]  = v.max_star
            end
        else
            self.dic_had_hero_info[v.partner_id] = v.max_star --最大星级
        end
    end
end

function HeroModel:getHadHeroInfo()
    return self.dic_had_hero_info or {}
end

function HeroModel:getHadHeroStarBybid(bid)
    if self.dic_had_hero_info and self.dic_had_hero_info[bid] then
        return self.dic_had_hero_info[bid]
    end
    return 0
end

--是否开启天赋 判断一个
function HeroModel:isOpenTanlentById(partner_id)
    if self.hero_list[partner_id] then
        return self:isOpenTanlentByHerovo(self.hero_list[partner_id])
    end
    return false
    
end

function HeroModel:isOpenTanlentByHerovo(hero_vo)
    if hero_vo[self.hero_info_talent_skill_param[1]] then
        if hero_vo[self.hero_info_talent_skill_param[1]] >= self.hero_info_talent_skill_param[2] then
            return true
        end
    end
    return false
end

--@config Config.PartnerSkillData.data_partner_skill_pos
function HeroModel:checkOpenTanlentByconfig(config, hero_vo)
    if not config then return end
    if not hero_vo then return end
    if config.pos_limit[1] == 'star' then
        is_open = (hero_vo.star >= config.pos_limit[2])
        if is_open then
            return is_open
        else
            return is_open, (config.pos_limit[2]..TI18N("星开启"))
        end
    end
end


--判断一个英雄的星级是不是满星
function HeroModel:isMaxStarHero(bid, star)
    if not bid or not star then return false end
    local max_star = Config.PartnerData.data_partner_max_star[bid]
    if max_star and star >= max_star then
        return true
    end
    return false
end

--初始化英雄图鉴数据
function HeroModel:getHeroPokedexList()
    if self.dic_pokedex_info == nil then
        self.dic_pokedex_info = {}
        -- self.dic_pokedex_info[0] = {} --表示全部
        self.dic_pokedex_info[HeroConst.CampType.eWater] = {} --阵营 水
        self.dic_pokedex_info[HeroConst.CampType.eFire]  = {} --阵营 火
        self.dic_pokedex_info[HeroConst.CampType.eWind]  = {} --阵营 风
        self.dic_pokedex_info[HeroConst.CampType.eLight] = {} --阵营 光
        self.dic_pokedex_info[HeroConst.CampType.eDark]  = {} --阵营 暗
        if Config.PartnerData.data_partner_pokedex then
            for bid,star_list in pairs(Config.PartnerData.data_partner_pokedex) do
                local base_config = Config.PartnerData.data_partner_base[bid]
                if base_config then
                    for i,v in ipairs(star_list) do
                        local star = v.star
                        local key = getNorKey(bid,star)
                        local info = self:getHeroPokedexByBid(key)
                        if MAKELIFEBETTER == true then
                            info.aaaaa = math.random( 1, 1000 )
                        end
                        if info then
                            if MAKELIFEBETTER == true then
                                info.aaaaa = math.random( 1, 1000 )
                            end
                            table.insert(self.dic_pokedex_info[info.camp_type], info)
                        end
                    end
                end
            end

            --排序
            local sort_func
            if MAKELIFEBETTER == true then
                sort_func = SortTools.tableLowerSorter({"aaaaa"})
            else
                sort_func = SortTools.tableLowerSorter({"camp_type", "star", "bid"})
            end
            for k,_table in pairs(self.dic_pokedex_info) do
                table.sort(_table, sort_func)    
            end
        end
    end
    return self.dic_pokedex_info
end

--@ key 如: key = 50507_10
--@ data 是 Config.PartnerData.data_partner_pokedex信息
function HeroModel:getHeroPokedexByBid(key)
    if self.dic_pokedex_bid[key] then
        return self.dic_pokedex_bid[key]
    end
    local data = Config.PartnerData.data_partner_show(key)
    if not data then 
        if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
            message(string.format("英雄图鉴没有[%s](bid_star)的数据", tostring(key)))
        end
        return nil  
    end
    local base_config = Config.PartnerData.data_partner_base[data.bid]
    if base_config then
        --这里由于是图鉴..所以不怕被破坏数据
        local break_lev = self:getHeroMaxBreakCountByInitStar(data.star)
        data.hp_max = data.hp --为了计算战力用的 
        data.power = PartnerCalculate.calculatePower(data)
        data.camp_type = base_config.camp_type
        data.name = base_config.name
        data.init_star = base_config.init_star
        data.type  = base_config.type 
        data.break_id = base_config.break_id 
        data.introduce_str = base_config.introduce_str 
        data.break_lev = break_lev
        --定义一个唯一id
        data.partner_id = data.bid * 10 + data.star
        data.is_pokedex = true -- 是不是图鉴
        self.dic_pokedex_bid[key] = data
        return self.dic_pokedex_bid[key]
    end
    return nil
end

function HeroModel:getIsFuseRedPoint( )
    return self.is_fuse_redpoint or false
end

function HeroModel:setIsFuseRedPoint(is_point)
    self.is_fuse_redpoint = is_point or false
end

--检测熔炼祭坛是否有新的红点信息
function HeroModel:checkNewFuseRedPoint()
    if not self.dic_fuse_info then return false end

    local is_new_redpoint = false
    local list = self.dic_fuse_info[0] or {}
    for i,v in ipairs(list) do
        if v.cur_redpoint == 1 then
            if self.dic_fuse_redpoint[v.bid] == nil then
                is_new_redpoint = true
                break
            end
        end
    end
    return is_new_redpoint
end

--记录红点信息
function HeroModel:recordFuseRedPointInfo()
    if not self.dic_fuse_info then return false end
    local list = self.dic_fuse_info[0] or {}
    for i,v in ipairs(list) do
        if v.cur_redpoint == 1 then
            self.dic_fuse_redpoint[v.bid] = true
        end
    end
end

--获取熔炼祭坛的数据列表
function HeroModel:getStarFuseList()
    if self.dic_fuse_info then 
        return self.dic_fuse_info
    end

    self.dic_fuse_info = {}
    self.dic_fuse_info[0] = {} --表示全部
    self.dic_fuse_info[HeroConst.CampType.eWater] = {} --阵营 水
    self.dic_fuse_info[HeroConst.CampType.eFire]  = {} --阵营 火
    self.dic_fuse_info[HeroConst.CampType.eWind]  = {} --阵营 风
    self.dic_fuse_info[HeroConst.CampType.eLight] = {} --阵营 光
    self.dic_fuse_info[HeroConst.CampType.eDark]  = {} --阵营 暗

    for bid,star_list in pairs(Config.PartnerData.data_partner_fuse_star) do
        local base_config = Config.PartnerData.data_partner_base[bid]
      
        if base_config then
            for i,v in ipairs(star_list) do
                local star = v.star
                local key = getNorKey(bid, star)
                local star_config = Config.PartnerData.data_partner_star(key)
                if star_config and #star_config.expend1 > 0 then
                    local fuse_data = {}
                    fuse_data.base_config = base_config
                    fuse_data.star_config = star_config
                    fuse_data.camp_type = base_config.camp_type
                    fuse_data.bid = bid
                    fuse_data.star = star
                    if MAKELIFEBETTER == true then
                        fuse_data.aaaaa = math.random( 1, 10000 )
                    end
                    table.insert(self.dic_fuse_info[0], fuse_data)
                    table.insert(self.dic_fuse_info[base_config.camp_type], fuse_data)
                end
            end
        end
    end
    --排序
    local sort_func = SortTools.tableLowerSorter({"star", "camp_type", "bid"})
    for k,_table in pairs(self.dic_fuse_info) do
        table.sort(_table, sort_func)    
    end
    return self.dic_fuse_info
end

--根据bid 获取一个模拟herovo对象..属性都是1级的
function HeroModel:getMockHeroVoByBid(bid)
    local base_config = Config.PartnerData.data_partner_base[bid]
    local attr_config = Config.PartnerData.data_partner_attr[bid]
    if not base_config or not attr_config then
        return
    end

    local hero_vo = DeepCopy(base_config)
    hero_vo.star = base_config.init_star --默认星数
    hero_vo.break_lev = 0 --默认进阶
    for k,v in pairs(attr_config) do
        if hero_vo[k] == nil then
            hero_vo[k] = v
        end
    end
    hero_vo.hp = attr_config.hp_max --血量等于最大血量
    hero_vo.power = PartnerCalculate.calculatePower(hero_vo)
    return hero_vo
end

--活动英雄列表 根据匹配信息 --熔炼祭坛用
--@dic_the_conditions --指定匹配 dic_the_conditions[bid][star] = 数量
--@dic_random_conditions --随机阵容匹配 dic_the_conditions[camp][star] = 数量
--@dic_hero_id 标志已用
--return
--@ count 拥有不重复英雄总数量
function HeroModel:getHeroListByMatchInfo(dic_the_conditions, dic_random_conditions, dic_hero_id)
    --找不重复的数量
    local count  = 0
    local dic_hero_id = dic_hero_id or {}
    local dic_count = {}

    local _setDicCount = function( partner_id, str, max)
        --判断是否重复
        if dic_hero_id[partner_id] == nil then
            if dic_count[str] == nil then
                dic_count[str] = 0
            end
            if dic_count[str] < max then
                dic_count[str] = dic_count[str] + 1
                count = count + 1    
                dic_hero_id[partner_id] = 1
            end
        end 
    end

    for k,hero in pairs(self.hero_list) do
        if not hero:isResonateHero() then
            if dic_the_conditions and dic_the_conditions[hero.bid] and dic_the_conditions[hero.bid][hero.star] then
                --指定的.范围最小
                local str = string_format("%s%s", hero.bid, hero.star)
                _setDicCount(hero.partner_id, str, dic_the_conditions[hero.bid][hero.star])
            end

            if dic_random_conditions then
                if dic_random_conditions[hero.camp_type] and dic_random_conditions[hero.camp_type][hero.star] then
                    --先判定指定阵营的 ,先小范围.再大范围
                    local str = string_format("_%s%s", hero.camp_type, hero.star)
                    _setDicCount(hero.partner_id, str, dic_random_conditions[hero.camp_type][hero.star])
                elseif dic_random_conditions[0] and dic_random_conditions[0][hero.star] then
                    --0表示所有阵营的合适
                    local str = string_format("_%s%s", 0, hero.star)
                    _setDicCount(hero.partner_id, str, dic_random_conditions[0][hero.star])
                end    
            end
        end
    end

    local list = BackpackController:getInstance():getModel():getHeroHunList()

    for k,good_vo in pairs(list) do
        if good_vo.config then
            local camp_type = good_vo.config.camp_type
            local star = good_vo.config.eqm_jie
            if dic_random_conditions[camp_type] and dic_random_conditions[camp_type][star] then
                local str = string_format("_%s%s", camp_type, star)

                if dic_count[str] == nil then
                    dic_count[str] = 0
                end
                if dic_count[str] < dic_random_conditions[camp_type][star] then
                    local cur_count = dic_random_conditions[camp_type][star] - dic_count[str]
                    if good_vo.quantity < cur_count then
                        cur_count = good_vo.quantity
                    end
                    count = count + cur_count 
                    dic_count[str] = dic_count[str] + cur_count
                end
            end
        end
    end

    return count
end
-------------------英雄信息结束--------------------------


---------------------装备相关------------------------------
function HeroModel:updateHeroEquipList(data)
    local id = data.partner_id or 0
    if self.hero_list[id] then 
        local hero_vo =  self.hero_list[id]
        if hero_vo.power < data.power then 
            GlobalMessageMgr:getInstance():showPowerMove( data.power-hero_vo.power,nil,hero_vo.power  )     
        end
        self.hero_list[id]:updateHeroVo(data)
        -- local bool = PartnerCalculate.getIsJingEquip(hero_vo.bid)
        -- hero_vo:updateRedPoint(PartnerConst.Vo_Red_Type.EequipJing,bool)
    end
end

function HeroModel:getHeroEquipList(id)
    if self.hero_list[id] then 
        return self.hero_list[id].eqm_list or {}
    end
    return {}
end
----------------------装备相关结束---------------------------------------


----------------------------------神装开始----------------------------------------

--神装页签是否开启
function HeroModel:isOpenHolyEquipMentTabByHerovo(hero_vo, is_show_tips)
    if not hero_vo then return false end
    --神装开启所需英雄星级
    local tips = ""
    local config = Config.PartnerHolyEqmData.data_const.show_star_condition
    local star = hero_vo.star or 1
    if config then
        if hero_vo.star < config.val then
            return false
        end
        tips = config.desc
    end

    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = 0
    if role_vo then
        lev = role_vo.lev or 0
    end

    --策划要求两个情况 : 1世界等级110且个人等级105开启 2个人等级120开启
     -- 个人等级限制 --先判断2
    local role_second_lv_cfg = Config.PartnerHolyEqmData.data_const.open_lev_second_condition
    if role_second_lv_cfg and lev < role_second_lv_cfg.val then
        --不满足2 再判断1
        -- 个人等级条件
        local role_lv_cfg = Config.PartnerHolyEqmData.data_const.open_lev_condition
        if lev < role_lv_cfg.val then
            return false
        end
        -- 世界等级限制
        local world_lv_cfg = Config.PartnerHolyEqmData.data_const.open_worldlev_condition
        local world_lev = RoleController:getInstance():getModel():getWorldLev()
        if world_lev and world_lv_cfg and world_lev < world_lv_cfg.val then
            -- if is_show_tips then
            --     message(world_lv_cfg.desc)
            -- end
            return false
        end
    end

    return true, tips
end

   
--是否神装开启 --旧的 改变前的条件判断 写死的
--神装改开启条件了,但是需要兼容旧数据,判断玩家之前有神装的装备的 也能显示页签 并且显示开启状态
function HeroModel:isOpenHolyEquipMentOldByHerovo(hero_vo, is_show_tips)
    if not hero_vo then return false end
    --旧的数据记录一下
    -- ["open_star_condition"] = {val=6, desc="神装开启所需英雄星级"},
    -- ["open_worldlev_condition"] = {val=110, desc="神装开启所需世界等级"},
    -- ["open_lev_condition"] = {val=105, desc="神装开启所需个人等级"},
    -- ["open_lev_second_condition"] = {val=120, desc="神装开启所需第二个人等级"},
    --神装开启所需英雄星级
    local star = hero_vo.star or 1
    if hero_vo.star < 6  then 
        return false
    end

    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = 0
    if role_vo then
        lev = role_vo.lev or 0
    end

    --策划要求两个情况 : 1世界等级110且个人等级105开启 2个人等级120开启
     -- 个人等级限制 --先判断2
    if lev < 120 then
        --不满足2 再判断1
        -- 个人等级条件
        if lev < 105 then
            return false
        end
        -- 世界等级限制
        local world_lev = RoleController:getInstance():getModel():getWorldLev()
        if world_lev and world_lev < 110 then
            return false
        end
    end

    return true
end

--是否神装开启
--@is_show_tips 是否显示提示 --暂时没用
function HeroModel:isOpenHolyEquipMentByHerovo(hero_vo, is_show_tips)
    if not hero_vo then return false end

    --神装开启所需英雄星级
    local config = Config.PartnerHolyEqmData.data_const.open_star_condition
    local star = hero_vo.star or 1
    if config and hero_vo.star < config.val  then
        -- if is_show_tips then
        --     message(config.desc)
        -- end
        return false
    end

    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = 0
    if role_vo then
        lev = role_vo.lev or 0
    end

    --策划要求两个情况 : 1世界等级110且个人等级105开启 2个人等级120开启
     -- 个人等级限制 --先判断2
    local role_second_lv_cfg = Config.PartnerHolyEqmData.data_const.open_lev_second_condition
    if role_second_lv_cfg and lev < role_second_lv_cfg.val then
        --不满足2 再判断1
        -- 个人等级条件
        local role_lv_cfg = Config.PartnerHolyEqmData.data_const.open_lev_condition
        if lev < role_lv_cfg.val then
            return false
        end
        -- 世界等级限制
        local world_lv_cfg = Config.PartnerHolyEqmData.data_const.open_worldlev_condition
        local world_lev = RoleController:getInstance():getModel():getWorldLev()
        if world_lev and world_lv_cfg and world_lev < world_lv_cfg.val then
            -- if is_show_tips then
            --     message(world_lv_cfg.desc)
            -- end
            return false
        end
    end

    return true
end

function HeroModel:updateHolyEquipmentInfo(data)
    local id = data.partner_id or 0
    if self.hero_list[id] then 
        local hero_vo =  self.hero_list[id]
        if hero_vo.power < data.power then 
            GlobalMessageMgr:getInstance():showPowerMove( data.power-hero_vo.power ,nil,hero_vo.power )
        end

        --先清空神装记录
        if hero_vo.holy_eqm_list then
            for _, equip_vo in pairs(hero_vo.holy_eqm_list) do
                self.hero_holy_list[equip_vo.id] = nil
                self.dic_itemid_to_partner_id[equip_vo.id] = nil
            end
        end
        hero_vo:updateHeroVo(data)
        --在重新记录新的记录
        if hero_vo.holy_eqm_list then
            for _, equip_vo in pairs(hero_vo.holy_eqm_list) do
                self.hero_holy_list[equip_vo.id] = equip_vo
                self.dic_itemid_to_partner_id[equip_vo.id] = hero_vo.partner_id
            end
        end
        GlobalEvent:getInstance():Fire(HeroEvent.Holy_Equipment_Update_Event,hero_vo)
    end
end

function HeroModel:getHeroHolyEquipList(id)
    if self.hero_list[id] then 
        return self.hero_list[id].holy_eqm_list or {}
    end
    return {}
end

--获取所有英雄穿戴的装备信息
--@ return 
function HeroModel:getAllHeroHolyEquipList()
    return self.hero_holy_list or {}
end

function HeroModel:getHolyEquipById(id)
    if self.hero_holy_list then
        return self.hero_holy_list[id] 
    end
end

--更新神装信息
function HeroModel:updateHeroVoHolyEquipment(data_list, is_not_check)
    local is_team = false
    for i,v in ipairs(data_list) do
        if self.hero_list[v.partner_id] then
            self.hero_list[v.partner_id]:updateHolyEqmList(v.holy_eqm)
            if not is_team then
                if self.hero_list[v.partner_id]:isFormDrama() then
                    is_team = true
                end
            end
        end
    end
    self.hero_holy_list = {}
    for k,v in pairs(self.hero_list) do
        if v.holy_eqm_list then
            for _, equip_vo in pairs(v.holy_eqm_list) do
                self.hero_holy_list[equip_vo.id] = equip_vo
                self.dic_itemid_to_partner_id[equip_vo.id] = v.partner_id
            end
        end
    end

    -- 检查红点是要的暂时不考虑.留着
    -- if is_team and not is_not_check then
    --     --如果有剧情阵容的英雄..需要检查红点
    --     --检测红点
    --     HeroCalculate.checkAllHeroRedPoint()    
    -- end
end

--获取神装的属性颜色 根据 套装id 和神装属性
--@item_id 道具id
--@ attr_key  属性名字 
--@ value 属性值
--@return_format 返回格式  1 格式: #ffffff  2 格式: c4b(0xff,0xff,0xff,0xff) 默认1
--@color_type  1 黑底  2 白底 默认 1
function HeroModel:getHolyEquipmentColorByItemIdAttrKey(item_id, attr_key, value, return_format, color_type)
    local return_format = return_format or 1
    local color_type = color_type or 1
    local quality = self:getHolyEquipmentQualityByItemIdAttrKey(item_id, attr_key, value)
   
    if return_format == 2 then
        if color_type == 2 then
            return BackPackConst.getWhiteQualityColorC4B(quality)
        else
            return BackPackConst.getBlackQualityColorC4B(quality)
        end
    else
        if color_type == 2 then
           return BackPackConst.getWhiteQualityColorStr(quality)
        else
            return BackPackConst.getBlackQualityColorStr(quality)
        end
    end   
end

--获取品质
--@item_id 道具id
--@ attr_key  属性名字 
--@ value 属性值
function HeroModel:getHolyEquipmentQualityByItemIdAttrKey(item_id, attr_key, value)
    local quality = 0
    local holy_equip_config = Config.PartnerHolyEqmData.data_base_info(item_id)
    if holy_equip_config then
        local key = getNorKey(holy_equip_config.group_id, attr_key)
        local config = Config.PartnerHolyEqmData.data_attr_color_rule_fun(key)
        if value > 0 and config and config.color_list[1] then
            local list = config.color_list[1] -- {0-12}
            for i,v in ipairs(list) do
                if list[i+1] then
                    if value >= list[i] and value < list[i+1] then
                        quality = i - 1
                    end
                else
                    if value >= list[i] then
                       quality = i - 1
                    end
                end
            end
        end
    end
    return quality
end

--获取某个属性最大值
function HeroModel:getHolyEquipmentMaxAttrByItemIdAttrKey(item_id, attr_key)
    local max_count = 1
    local holy_equip_config = Config.PartnerHolyEqmData.data_base_info(item_id)
    if holy_equip_config then
        local config = Config.PartnerHolyEqmData.data_attr_max_info[holy_equip_config.group_id]
        if config then
            for i,v in ipairs(config.max_attr) do
                if v[1] and v[1] == attr_key then
                    max_count = v[2] or 1
                    break
                end
            end
        end
    end

    return max_count
end


----------------------------------神装结束----------------------------------------


----------------------红点检查-------------------------------------------
--检测升级红点更新
function HeroModel:checkLevelRedPointUpdate()
    GlobalEvent:getInstance():Fire(HeroEvent.Level_RedPoint_Event) 
    if self.is_delay_redpoint_update[HeroConst.RedPointType.eRPLevelUp] then
        return
    end
    self.is_delay_redpoint_update[HeroConst.RedPointType.eRPLevelUp] = true
    --清除升级红点记录
    HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPLevelUp, true)
    
end

--设置更新equip红点的记录
function HeroModel:setEquipUpdateRecord(bool)
    self.is_equip_redpoint_bag_update = bool
    self.is_equip_redpoint_hero_update = bool
end


function HeroModel:checkEquipRedPointUpdate()
    --需要 背包 返回 和 英雄更新返回 才处理红点计算
    if self.is_equip_redpoint_bag_update and self.is_equip_redpoint_hero_update then
        --清除装备红点记录
        HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPEquip)
        GlobalEvent:getInstance():Fire(HeroEvent.Equip_RedPoint_Event)
    end
end

--设置更新升星红点的记录
function HeroModel:setUpgradeStarUpdateRecord(bool)
    self.is_upgradestar_redpoint_bag_update = bool
    self.is_upgradestar_redpoint_hero_update = bool
end


function HeroModel:checkUpgradeStarRedPointUpdate()
    --需要 背包 返回 和 英雄更新返回 才处理红点计算
    if self.is_upgradestar_redpoint_bag_update and self.is_upgradestar_redpoint_hero_update then
        --清除升星红点记录
        HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPStar)
        -- GlobalEvent:getInstance():Fire(HeroEvent.UpgradeStar_RedPoint_Event)
    end
end

--检测天赋红点更新
function HeroModel:checkTalentRedPointUpdate()
    -- GlobalEvent:getInstance():Fire(HeroEvent.Level_RedPoint_Event) 
    if self.is_delay_redpoint_update[HeroConst.RedPointType.eRPTalent] then
        return
    end
    self.is_delay_redpoint_update[HeroConst.RedPointType.eRPTalent] = true
    --清除天赋红点记录
    HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPTalent, true)
    
end

--检查阵法解锁    
--@lev 角色等级
function HeroModel:checkUnlockFormRedPoint(lev)
    local config = Config.FormationData.data_form_data
    if config then
        for i,v in pairs(config) do
            if v.need_lev > self.record_login_lev and v.need_lev <= lev then
                self.is_redpoint_form = true
                GlobalEvent:getInstance():Fire(HeroEvent.Form_RedPoint_Event) 
            end
        end
    end
    self.record_login_lev = lev
end

--检查圣器解锁
function HeroModel:checkUnlockHallowsRedPoint()
   self.is_redpoint_hallows = true
end

--------------------------------红点检查结束---------------------

---------------------神器相关相关------------------------------
function HeroModel:updatePartnerArtifactList(data)
    local id = data.partner_id or 0
    if self.hero_list[id] then 
        local hero_vo =  self.hero_list[id]
        if hero_vo.power < data.power then 
            GlobalMessageMgr:getInstance():showPowerMove( data.power-hero_vo.power ,nil,hero_vo.power )
        end
        self.hero_list[id]:updateHeroVo(data)
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Update_Event,hero_vo)
        local is_artifact =  PartnerCalculate.getIsCanClothArtifact(hero_vo.bid) 
        hero_vo:updateRedPoint(PartnerConst.Vo_Red_Type.Artifact,is_artifact)
    end
   
end
function HeroModel:getPartnerArtifactList(id)
    if self.hero_list[id] then 
        return self.hero_list[id].artifact_list or {}
    end
    return {}
end
function HeroModel:getArtifactByType(id,pos)
    if self.hero_list[id] then 
        local artifact_list = self.hero_list[id].artifact_list or {}
        for i,v in pairs(artifact_list) do 
            if v and v.pos == pos then 
                return v
            end
        end
    end
    return {}
end

-- 符文祝福值
function HeroModel:setArtifactLucky( value )
    self.artifact_lucky = value
    self:updateArtifactLuckyRed()
end
function HeroModel:getArtifactLucky(  )
    return self.artifact_lucky
end

function HeroModel:updateArtifactLuckyRed(  )
    local max_lucky = 0
    local lucky_cfg = Config.PartnerArtifactData.data_artifact_const["change_condition"]
    if lucky_cfg and lucky_cfg.val then
        max_lucky = lucky_cfg.val
    end
    if self.artifact_lucky >= max_lucky then
        self.artifact_lucky_red = true
    else
        self.artifact_lucky_red = false
    end
    GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Lucky_Red_Event)
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.mall, self.artifact_lucky_red)
end

-- 根据符文的技能id判断是否为稀有高级技能
local artifact_tag_list = Config.PartnerArtifactData.data_artifact_const.recast_tag
function HeroModel:checkIsUnusualSkillById( skill_id )
    local is_unusual = false
    if artifact_tag_list then
        for _,v in pairs(artifact_tag_list.val) do
            if skill_id == v then
               is_unusual = true
               break 
            end
        end
    end
    return is_unusual
end

-- 根据符文的技能id判断是否为强力高级技能
local recast_power_tag_list = Config.PartnerArtifactData.data_artifact_const.recast_power_tag
function HeroModel:checkIsUnusualSkillById2( skill_id )
    local is_unusual = false
    if recast_power_tag_list then
        for _,v in pairs(recast_power_tag_list.val) do
            if skill_id == v then
               is_unusual = true
               break 
            end
        end
    end
    return is_unusual
end

-- 获取符文祝福红点状态
function HeroModel:getArtifactLuckyRedStatus(  )
    return self.artifact_lucky_red
end

-- 符文重铸次数相关数据
function HeroModel:updateArtifactRecastCount( data_list )
    self.artifact_recast_data = data_list or {}
end
-- 根据符文品质获取对应品质的重铸次数
function HeroModel:getArtifactRecastCountByQuality( quality )
    local count = 0
    local max_count = 0
    local _type = 0 
    if quality == BackPackConst.quality.orange then -- 彩虹符文
        _type = 1
    elseif quality == BackPackConst.quality.red then -- 闪烁符文
        _type = 2
    end
    if self.artifact_recast_data and _type > 0 then
        for k,v in pairs(self.artifact_recast_data) do
            if v.type == _type then
                count = v.current
                max_count = v.limit
                break
            end
        end
    end
    return count, max_count
end

------------------------神器相关相关结束-------------------------------------

-------------------阵法相关--------------------------
function HeroModel:setFormList(data, index)
    local form_type = data.type or PartnerConst.Fun_Form.Drama
    local index = index or 1

    if self.pos_list[form_type]  then
        if next(self.pos_list[form_type]) ~= nil then 
            for pos, v in pairs(self.pos_list[form_type]) do
                local _index = math.floor(pos/self.pos_param) + 1
                if _index == index then
                    local vo = self:getHeroById(v.id)
                    --容错处理  bugly出现说  updateFormPos 这个是 (a nil value)
                    if vo and vo.updateFormPos then
                        vo:updateFormPos(0, form_type)
                        self.pos_list[form_type][pos] = nil
                    end
                end
            end
        end
    else
        self.pos_list[form_type] = {}
    end

    for i,v in pairs(data.pos_info) do 
        local pos = v.pos + (index - 1) * self.pos_param
        self.pos_list[form_type][pos] = v
        local vo = self:getHeroById(v.id)
        --容错处理  bugly出现说  updateFormPos 这个是 (a nil value)
        if vo and vo.updateFormPos then
            vo:updateFormPos(pos, form_type)
        end
    end

    --剧情阵法逻辑
    if form_type == PartnerConst.Fun_Form.Drama then

        self.form_power = data.power or 0
        --阵法类型
        self.use_formation_type = data.formation_type
        --使用的圣器id
        self.use_hallows_id = data.hallows_id

        GlobalEvent:getInstance():Fire(HeroEvent.Form_Drama_Event,data)
        
        local list = {}
        for k,v in pairs(self.pos_list[form_type]) do
            table_insert(list, {partner_id = v.id})
        end
        --请求天赋的
        HeroController:getInstance():sender11099(list)
        --请求神装
        -- HeroController:getInstance():sender11092(list)
    end
end

--发送获取所有英雄的属性 装备等数据
function HeroModel:sendAllHeroInfo()
    if self.hero_list then
        local list = {}
        for k,v in pairs(self.hero_list) do
            table_insert(list, {partner_id = v.id})
        end
        if #list > 0 then
            --请求英雄详细信息
            HeroController:getInstance():sender11026(list)
        end
    end
end

--批量请求英雄的属性 装备等数据 11026
function HeroModel:batchSendHeroInfo()
    if self.hero_list then
        local list = {}
        for k,v in pairs(self.hero_list) do
            table_insert(list, {partner_id = v.id})
            if #list > 150 then
                HeroController:getInstance():sender11026(list)
                list = {}    
            end
        end
        if #list > 0 then
            --请求英雄详细信息
            HeroController:getInstance():sender11026(list)
        end
    end
end

--获取所有英雄的神装信息
function HeroModel:sendAllHeroHolyEquipInfo()
    if self.hero_list then
        local list = {}
        for k,v in pairs(self.hero_list) do
            if not v:ishaveHolyEquipmentData() then
                table_insert(list, {partner_id = v.id})
            end
        end
        if #list > 0 then
            --所有英雄的神装信息
            HeroController:getInstance():sender11092(list)
        end
    end
end

--获取自己的队伍阵法站位
--@team_index --队伍索引 不传返回所有队伍的信息 
function HeroModel:getMyPosList(team_index)
    if not self.pos_list[PartnerConst.Fun_Form.Drama] then return {} end
    if team_index == nil then
        local drama_list = self.pos_list[PartnerConst.Fun_Form.Drama] or {}
        local pos_list = {}
        for pos, v in pairs(drama_list) do
            if self.hero_list[v.id] then
                pos_list[pos] = v
            end
        end
        return pos_list
    end
    local list = {}
    for pos,v in pairs(self.pos_list[PartnerConst.Fun_Form.Drama]) do
        local index = math.floor(pos/self.pos_param) + 1
        if index == team_index and self.hero_list[v.id] then
            table_insert(list, v) 
        end
    end
    return list
end

-----------------------------------阵法结束--------------------------


-------------------------------天赋技能开始===================================

--设置更新天赋红点
function HeroModel:setUpdateTalentRedpoint()
    self.is_need_update_talent_redpoint = true
end

--获取可学习天赋的记录 dic_hero_talent_skill_learn_redpoint[skill_id] = true
function HeroModel:getTalentRedpointRecord()
    if self.is_need_update_talent_redpoint then
        local dic_config = Config.PartnerSkillData.data_partner_skill_learn
        if dic_config then
            local is_enough
            for k,config in pairs(dic_config) do
                self.dic_hero_talent_skill_learn_redpoint[config.id] = nil
                is_enough = true
                for i,v in ipairs(config.expend) do
                    local count = BackpackController:getInstance():getModel():getItemNumByBid(v[1])
                    if count < v[2] then
                        is_enough = false
                        break
                    end
                end
                if is_enough then
                    self.dic_hero_talent_skill_learn_redpoint[config.id] = config.id
                end
            end
        end
    end
    self.is_need_update_talent_redpoint = false
    return self.dic_hero_talent_skill_learn_redpoint
end

-------------------------------天赋技能结束===================================

--创建星星显示
--@num 星星数量
--@star_con 星星父类
--@star_setting 星星设置结构
--star_setting.star_list = {}  1到5星的星星对象集合
--star_setting.star_list2 = {}  6到9星的星星对象集合
--star_setting.star10  10星对象
--star_setting.star_label  11星label
--@star_width 星星位置宽度

function HeroModel:createStar(num, star_con, star_setting, star_width)
    local num = num or 0
    local star_setting = star_setting or {}
    if star_setting.star_list == nil then
        star_setting.star_list = {}
    end

    if star_setting.star_list2 == nil then
        star_setting.star_list2 = {}
    end

    for i,v in pairs(star_setting.star_list) do
        v:setVisible(false)
    end
    for i,v in pairs(star_setting.star_list2) do
        v:setVisible(false)
    end
    if star_setting.star10 then
        star_setting.star10:setVisible(false)
    end

    local _cStar = function(star_count, res, star_list)
        local width = star_width or (29 + 3)
        local x = - star_count * width * 0.5 + width * 0.5
        for i=1,star_count do
            if not star_list[i] then 
                local star = createImage(star_con,res,0,0,cc.p(0.5,0.5),true,0,false)
                star:setScale(1)
                star_list[i] = star
            end
            star_list[i]:setVisible(true)
            star_list[i]:setPositionX(x + (i-1) * width)
        end
    end

    if num > 0 and num <= 5 then
        local res = PathTool.getResFrame("common","common_90074")
        _cStar(num, res, star_setting.star_list)
    elseif num >= 6 and num <= 9 then
        local res = PathTool.getResFrame("common","common_90075")
        local count = num - 5
        _cStar(count, res, star_setting.star_list2)
    elseif num >= 10 then
        local new_num  = num - 10
        local res = PathTool.getResFrame("common","common_90073")
        if star_setting.star10 == nil then 
            local star = createImage(star_con,res,0, 0,cc.p(0.5,0.5),true,0,false)
            star:setScale(1.2)
            star:setCascadeOpacityEnabled(true)
            star_setting.star10 = star
        else
            star_setting.star10:setVisible(true)
            -- star_setting.star_label:setString("10")
        end

        if new_num > 0 then
            if star_setting.star_label == nil then
                local size = star_setting.star10:getContentSize()
                star_setting.star_label = createLabel(12,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],size.width * 0.5 - 2, size.height * 0.5,"10",star_setting.star10, 1, cc.p(0.5,0.5))
            else
                star_setting.star_label:setVisible(true)
            end
            star_setting.star_label:setString(new_num)
        else
            if star_setting.star_label then
                star_setting.star_label:setVisible(false)
            end
        end
    end
    return star_setting
end


function HeroModel:getTipsStr(star)
    local tips_str
    if star == 11 then
        tips_str = TI18N("满足以下任意条件开启：\n1. 个人等级达到110级或世界等级达到100级 \n2. 拥有5个不同的10星英雄 并且个人等级达到100级")
    elseif star == 12 then
        tips_str = TI18N("满足以下任意条件开启：\n1. 个人等级达到150级或世界等级达到140级 \n2. 拥有5个不同的11星英雄 并且个人等级达到120级")
    elseif star == 13 then
        tips_str = TI18N("满足以下任意条件开启：\n1. 拥有2个不同的12星英雄 并且个人和世界等级达到170级 \n2. 拥有2个不同的12星英雄 并且个人等级到达180级 \n3. 拥有5个不同的12星英雄 并且个人等级达到150级")
    else
        tips_str = ""
    end
    return tips_str
end

--检查是否开启11星条件 retur true:开启  false:不开启
function HeroModel:checkOpenStar11(is_show_tips)
    --策划要求 要么满足世界等级条件
    local config = Config.PartnerData.data_partner_const.staropen11_world_lev
    local is_open = true
    if config then
        if config.val[1] == "world_lev" then
            local world_lev = RoleController:getInstance():getModel():getWorldLev() or 0
            if world_lev < config.val[2]  then
                is_open = false
            end
        end
    end

    --要么满足 个人等级条件
    if not is_open then
        is_open = true
        local config_lev = Config.PartnerData.data_partner_const.staropen11_player_lev
        if config_lev and config_lev.val[1] == "lev" then
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and role_vo.lev < config_lev.val[2] then
                is_open = false
            end
        end
    end
    --策划加的额外条件
    local config = Config.PartnerData.data_partner_const.staropen11_3rd_open_limit
    local is_condition_3 = self:checkExtOpenInfo(config)
    if not is_open then
        is_open = is_condition_3 or false
    end

    local tips_str = nil
    if is_show_tips and not is_open then
        tips_str = self:getTipsStr(11)
    end

    return is_open, tips_str
end

-- 检查是否开启12星条件
function HeroModel:checkOpenStar12(is_show_tips)
    local config = Config.PartnerData.data_partner_const.staropen12_world_lev
    local is_open = true
    if config then
        if config.val[1] == "world_lev" then
            local world_lev = RoleController:getInstance():getModel():getWorldLev() or 0
            if world_lev < config.val[2]  then
                is_open = false
            end
        end
    end

     --要么满足 个人等级条件
    if not is_open then
        is_open = true
        local config_lev = Config.PartnerData.data_partner_const.staropen12_player_lev
        if config_lev and config_lev.val[1] == "lev" then
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and role_vo.lev < config_lev.val[2] then
                is_open = false
            end
        end
    end
    
    --策划加的额外条件
    local config = Config.PartnerData.data_partner_const.staropen12_3rd_open_limit
    local is_condition_3 = self:checkExtOpenInfo(config)
    if not is_open then
        is_open = is_condition_3 or false
    end

    local tips_str = nil
    if is_show_tips and not is_open then
        tips_str = self:getTipsStr(12)
    end

    return is_open, tips_str
end


-- 检查是否开启13星条件
function HeroModel:checkOpenStar13(is_show_tips)
    if self.is_star13_open then --如果已经计算开启过了.就不计算了
        return true
    end
    --优先判断 等级 第一条件不满足再判断第二条件
    local config = Config.PartnerData.data_partner_const.staropen13_limit_lev2
    local is_open = true
    if config then
        if self:checkOpenByKeyValue(config.val[1],config.val[2]) then
            is_open = false
        end
    end
    --如果上面不满足 再判断第二个条件
    if not is_open then
        is_open = true
        local config = Config.PartnerData.data_partner_const.staropen13_limit_lev1
        if config then
            for i,v in ipairs(config.val) do
                if self:checkOpenByKeyValue(v[1],v[2]) then
                    is_open = false
                    break
                end
            end
        end
    end
    --条件1 个人和世界等级达到170级 或 个人等级到达180级 开启升星
    local is_condition_1 = is_open
    --条件2 拥有2个12星英雄开启升星
    local is_condition_2 = false
    --条件3 个人等级达到150，且拥有5个及以上的12星，13星
    local is_condition_3 = false

    --第二个硬性条件
    --13星特殊要 曾经有2个12星英雄
    local config = Config.PartnerData.data_partner_const.staropen13_limit_partner
    if config and next(config.val) then
        local count = 0
        for k,star in pairs(self.dic_had_hero_info) do
            if star >= config.val[1] then
                count = count + 1
                if count >= config.val[2] then
                    break
                end
            end
        end
        if count < config.val[2] then
            is_open = false
            is_condition_2 = false
        else
            is_condition_2 = true
        end
    end
    is_condition_2 = is_open

    --策划加的额外条件
    local config = Config.PartnerData.data_partner_const.staropen13_3rd_open_limit
    is_condition_3 = self:checkExtOpenInfo(config)
    if not is_open then
        is_open = is_condition_3 
    end
    
    local tips_str = nil
    if is_show_tips and not is_open then
        -- if not is_condition_1 and not is_condition_2 and not is_condition_3 then
        --     --三个条件都不满足
        --     tips_str = TI18N("满足以下任意条件开启：1.拥有2个12星英雄 并且个人和世界等级达到170级 \n2. 拥有2个12星英雄 并且个人等级到达180级 \n3.拥有5个12星英雄 并且个人等级达到150级")
        -- end

        -- if not is_condition_1 and not is_condition_2 then
        --     --两个都不满足
        --     tips_str = TI18N("满足以下条件开启：1.拥有2个12星英雄\n2.个人和世界等级达到170级 或 个人等级到达180级")
        -- elseif not is_condition_1 and is_condition_2 then
        --     tips_str = TI18N("个人和世界等级达到170级 或 个人等级到达180级 开启升星")
        -- else
        --     tips_str = TI18N("拥有2个12星英雄开启升星")
        -- end
        tips_str = self:getTipsStr(13)
    end
    if is_open then
        --如果已经开启 那么记录
        self.is_star13_open = true
    end
    return is_open, tips_str
end

function HeroModel:checkExtOpenInfo(config)
    -- 策划要求:原来的条件没变。只是新增一个或条件，
    -- 个人等级达到100/120/150，且拥有5个及以上的10/11/12星，开启11/12/13星
    local val = config.val
    if val == nil or next(val) == nil then return false end

    if self:checkOpenByKeyValue(val[1][1], val[1][2]) then
        return false
    end 
    if val[2] == nil then return false end
    -- local hero_star = val[2][1] or "hero_star" --这个前端不需要..因为需要写死的
    local star = val[2][2] or 10
    local count = val[2][3] or 5


    if self.dic_star_count[star] == nil then
        self.dic_star_count[star] = 0
        for k,_star in pairs(self.dic_had_hero_info) do
            if _star >= star then
                self.dic_star_count[star] = self.dic_star_count[star] + 1
                if self.dic_star_count[star] >= count then
                    break
                end
            end
        end
        if self.dic_star_count[star] >= count then
            return true
        end
    else
        if self.dic_star_count[star] >= count then
            return true
        end
    end
    return false
end

--return true 表示不满足  false 表示满足
function HeroModel:checkOpenByKeyValue(key, value)
    if not value then return false end
    if key == "world_lev" then
        local world_lev = RoleController:getInstance():getModel():getWorldLev() or 0
        return world_lev < value
    elseif key == "lev" then
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo and role_vo.lev < value then
            return true
        end
    end
    return false
end


--获取神装套装描述
--@equip_vo_list 装备列表 结构{goods_vo,goods_vo,...}  
--return 描述list
-- 返回结构 {}
function HeroModel:getHolyEquipSuitDes(equip_vo_list)
    if not equip_vo_list then return {} end
        

    local dic_suit_set = {}
    local dic_eqm_set_list = {}
    local math_floor = math.floor
    for k,euip_vo in pairs(equip_vo_list) do
        if euip_vo.config then
            local eqm_key = math_floor(euip_vo.config.eqm_set/100)
            if dic_suit_set[eqm_key] == nil then
                dic_suit_set[eqm_key] = 1
                dic_eqm_set_list[eqm_key] = {euip_vo.config.eqm_set}
            else
                dic_suit_set[eqm_key] = dic_suit_set[eqm_key] + 1
                table_insert(dic_eqm_set_list[eqm_key], euip_vo.config.eqm_set)
            end
        end
    end
    local suit_config = {}
    for eqm_key, count in pairs(dic_suit_set) do
        local eqm_set_list = dic_eqm_set_list[eqm_key]
        if count > 1 then
            table.sort( eqm_set_list, function(a,b) return a > b end)

            local cur_eqm_set = nil
            local cur_config = nil
            for i,eqm_set in ipairs(eqm_set_list) do
                if cur_eqm_set == nil then
                    cur_eqm_set = eqm_set
                    cur_config = Config.PartnerHolyEqmData.data_suit_info[eqm_set]
                    table_sort( cur_config, function(a, b) return a.num < b.num end)
                else
                    if cur_eqm_set ~= eqm_set then
                        cur_config = Config.PartnerHolyEqmData.data_suit_info[eqm_set]
                        table_sort( cur_config, function(a, b) return a.num < b.num end)    
                    end
                    for _,suit_info in ipairs(cur_config) do
                        if suit_info.num == i then
                            table_insert(suit_config, suit_info)
                            break
                        end
                    end
                end
            end
        end
    end
    -- local suit_data_list = {}
    local list = {}
    for i,v in ipairs(suit_config) do
        --说明是激活的
        local eqm_set = v.id
        local id = math_floor(eqm_set/100)
        local config = Config.PartnerHolyEqmData.data_suit_res_prefix_fun(id)
        if config then
            local data = {}
            data.num = v.num
            data.icon_res = PathTool.getSuitRes(config.prefix)
            data.name = string_format("%s(%s件套)", v.name, v.num)
            data.id  = eqm_set 

            -- if suit_data_list[eqm_set] == nil or suit_data_list[eqm_set].num < v.num then 
            --     suit_data_list[eqm_set] = data
            -- end
            table_insert(list, data)
        end
    end

    -- for k,v in pairs(suit_data_list) do
    --     table_insert(list, v)
    -- end
    local sort_fun = SortTools.tableLowerSorter({"id","num"})
    table_sort(list, sort_fun)

    return list
end

--初始化皮肤 信息英雄皮肤 
function HeroModel:initHeroSkin(data)
    if not data then return end

    --判定是否要显示卡片展示界面
    if self.hero_skin_list then
        local show_skin_id
        for i,v in ipairs(data.partner_skins) do
            if self.hero_skin_list[v.id] == nil then
                --说明本地没有 --只第一个
                show_skin_id = v.id
                break
            end
        end
        if show_skin_id then
            --显示
            local skin_config = Config.PartnerSkinData.data_skin_info[show_skin_id]
            if skin_config then
                local setting = {}
                setting.partner_bid = skin_config.bid
                setting.is_chips = 1
                setting.init_star = 5
                setting.status = 1
                setting.show_type = PartnersummonConst.Gain_Show_Type.Skin_show
                setting.skin_id = show_skin_id
                PartnersummonController:getInstance():openSummonGainShowWindow(true, setting, 2)
            end
        end
    end

    self.hero_skin_list = {}
    --是否开启定时器 时间后端算了..前端不用背锅
    -- local can_start_ticket = false
    for i,v in ipairs(data.partner_skins) do
        self.hero_skin_list[v.id] = v.end_time
        -- if v.end_time > 0 then
        --     can_start_ticket = true
        -- end
    end

    -- --启动定时器算时间
    -- if can_start_ticket and self.hero_skin_time_ticket == nil  then
    --     self.hero_skin_time_ticket = GlobalTimeTicket:getInstance():add(function()
    --         local sever_time = GameNet:getInstance():getTime()
    --         local have_skin_time = false
    --         for k,end_time in pairs(self.hero_skin_list) do
    --             if end_time ~= 0 then
    --                 if end_time <= sever_time  then
    --                     self.hero_skin_list[k] = nil
    --                 else
    --                     have_skin_time = true
    --                 end
    --             end
    --         end
    --         if not have_skin_time then
    --             self:clearHeroSkinTimeTicket()
    --         end
    --     end,1)
    -- end
end

--根据皮肤id 返回皮肤数据  
--@return 皮肤有效时间点..  如果永久返回 0 如果返回nil 表示 没有解锁该皮肤
function HeroModel:getHeroSkinInfoBySkinID(skin_id)
    if self.hero_skin_list and self.hero_skin_list[skin_id] then
        return self.hero_skin_list[skin_id]
    end
end
--是否解锁该皮肤
--is_check_time:判断是否存在过期
function HeroModel:isUnlockHeroSkin(skin_id, is_check_time)
    if self.hero_skin_list and self.hero_skin_list[skin_id] then
        if is_check_time then
            if self.hero_skin_list[skin_id] > 0 then
                return false
            end 
        end
        return true
    end 
    return false
end



function HeroModel:clearHeroSkinTimeTicket()
    if self.hero_skin_time_ticket then
        GlobalTimeTicket:getInstance():remove(self.hero_skin_time_ticket)
        self.hero_skin_time_ticket = nil
    end
end
--远征阵法
function HeroModel:setExpeditPosList(data)
    
end
function HeroModel:getExpeditPosList()
    return self.expedit_list or {}
end

function HeroModel:updateHolyEquipmentPlan(data)
    if data.num then --格子上限
        self.holy_equip_plan_count = data.num
    end
    if self.holy_equip_plan == nil then
        self.holy_equip_plan = {}
    end
    if data.holy_eqm_set_cell then
        for i,cell in ipairs(data.holy_eqm_set_cell) do
            if self.holy_equip_plan[cell.id] then
                for k,v in pairs(cell) do
                    self.holy_equip_plan[cell.id][k] = v
                end
            else
                self.holy_equip_plan[cell.id] = cell
            end
        end
    end
end

function HeroModel:getHolyEquipmentPlanData()
    return self.holy_equip_plan
end

--检查道具是否在神装管理里面
--@item_id 物品唯一id
function HeroModel:checkHolyEquipmentPalnByItemID( item_id)
    if not item_id then return false end
    if not self.holy_equip_plan then return false end
    for i,cell in pairs(self.holy_equip_plan) do
        for i,v in ipairs(cell.list) do
            if item_id == v.item_id then
                return true,cell
            end
        end
    end
    return false
end

function HeroModel:getCystalPreLevLimit( )
    if self.cystal_pre_lev_limit == nil then
        self.cystal_pre_lev_limit = 340
        local config = Config.ResonateData.data_const.cystal_pre_lev_limit
        if config then
            self.cystal_pre_lev_limit = config.val
        end
    end
    return self.cystal_pre_lev_limit or 340
end

--是否共鸣水晶最大等级 注意: 还有一个突破上限等级  后端传过来的
function HeroModel:isResonateCystalMaxLev()
    --340 英雄 13星升级的最大等级 
    if self.resonate_cystal_lev and self.resonate_cystal_lev >= self:getCystalPreLevLimit() then
        return true
    end
    return false
end

function HeroModel:isCanShowLabelMaxLev(lev)
    if lev and lev < self:getCystalPreLevLimit() then
        return false
    end
    return true
end

function HeroModel:getDicResonateFiveHeroVo(  )
    return self.dic_resonate_five_hero_vo or {}
end

--是否共鸣水晶上阵的英雄 如果 hero_vo 不确定是 hero_vo 类的 用此方法判断
function HeroModel:isResonateCystalHero(hero_vo)
    if hero_vo.isResonateCrystalHero then
        if hero_vo:isResonateCrystalHero() then
            return true
        end
    elseif hero_vo.resonate_lev and hero_vo.resonate_lev > 0 then
        return true
    end
    return false
end

--更新共鸣锁定信息
function HeroModel:updateResonateCystalInfo(data)
    if not data then return end
    self.resonate_cystal_lev = data.lev

    self.dic_resonate_five_hero_vo = {}

    local star = 0
    for i,v in ipairs(data.con_list) do
        if v.id ~= 0 then
            local hero_vo = self:getHeroById(v.id)
            if hero_vo and next(hero_vo) ~= nil then
                self.dic_resonate_five_hero_vo[hero_vo.id] = hero_vo
            end
            if hero_vo.star then
                star = star + hero_vo.star
            end
        end
    end

    for id, hero_vo in pairs(self.dic_resonate_lock_info) do
        if hero_vo.updateLock then
            local data = {{lock_type = HeroConst.LockType.eHeroResonateLock, is_lock = 0}}
            hero_vo:updateLock(data)
        end
    end
    self.dic_resonate_lock_info = {}
    for i,v in ipairs(data.res_list) do
        if v.id ~= 0 then
            local hero_vo = self:getHeroById(v.id)
            if hero_vo and hero_vo.updateLock then
                self.dic_resonate_lock_info[v.id] = hero_vo
                local data = {{lock_type = HeroConst.LockType.eHeroResonateLock, is_lock = 1}}
                hero_vo:updateLock(data)
            end
        end
    end
    if self.resonate_max_partner_lev == nil then
        -- 说明26400没有返回了
        self.resonate_max_partner_lev = star
    end
end

function HeroModel:updateResonateLockInfo(data)
    self.resonate_stone_level = data.lev or 0
    self.resonate_max_partner_lev = data.max_partner_lev or 0
    -- for id, hero_vo in pairs(self.dic_resonate_lock_info) do
    --     if hero_vo.updateLock then
    --         local data = {{lock_type = HeroConst.LockType.eHeroResonateLock, is_lock = 0}}
    --         hero_vo:updateLock(data)
    --     end
    -- end
    -- self.dic_resonate_lock_info = {}
    -- for i,v in ipairs(data.list) do
    --     if v.id ~= 0 then
    --         local hero_vo = self:getHeroById(v.id)
    --         if hero_vo and hero_vo.updateLock then
    --             self.dic_resonate_lock_info[v.id] = hero_vo
    --             local data = {{lock_type = HeroConst.LockType.eHeroResonateLock, is_lock = 1}}
    --             hero_vo:updateLock(data)
    --         end
    --     end
    -- end

    --判断是有红点
    self:checkResonateRedPoint()
end

function HeroModel:checkResonateRedPoint()
    if not self.resonate_stone_level then return end
    if not self.resonate_max_partner_lev then return end

    local resonate_stone_condition = 50
    local config = Config.ResonateData.data_const.amp_all_start_limit
    if config then
        resonate_stone_condition = config.val
    end
    --不满足开启不计算显示了
    if self.resonate_max_partner_lev < resonate_stone_condition then
        return 
    end

    local config = Config.ResonateData.data_level_up(self.resonate_stone_level)
    local is_redpoint = false
    if config then
        if config.expend and next(config.expend) ~= nil then
            is_redpoint = true
            for i,v in ipairs(config.expend) do
                local bid = v[1] 
                local num = v[2] 
                local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                if num and num > have_num then
                    is_redpoint = false
                end
            end
        end
    end
    self.is_resonate_stone_redpoint = is_redpoint
    local data = {bid = HeroConst.RedPointType.eResonate_stone, status = self.is_resonate_stone_redpoint}
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.resonate, {data})
end
--是否最高等级
function HeroModel:isResonateMaxLevel(lev)
    if lev then
        local config = Config.ResonateData.data_level_up(lev + 1)
        if config == nil then
            return true
        end
    end
    return false
    -- body
end
-- 共鸣是否开启
function HeroModel:checkResonateIsOpen( not_tips )
    local role_vo = RoleController:getInstance():getRoleVo()
    local limit_lv_cfg = Config.ResonateData.data_const["open_lev"]
    if limit_lv_cfg and role_vo and limit_lv_cfg.val <= role_vo.lev then
        return true
    end
    if not not_tips and limit_lv_cfg then
        message(limit_lv_cfg.desc)
    end
    return false
end

--检查共鸣精炼经验的红点 data 是 26410协议结构
function HeroModel:checkResonateExtractRedpoint(data)
    if not self:checkResonateIsOpen(true) then
        return 
    end
    self.is_resonate_extract_redpoint = false

    if not self.resonate_max_partner_lev then return end
    
    local resonate_stone_condition = 50
    local config = Config.ResonateData.data_const.amp_all_start_limit
    if config then
        resonate_stone_condition = config.val
    end
    --不满足开启不计算显示了
    if self.resonate_max_partner_lev < resonate_stone_condition then
        return 
    end

    if data.all_num ~= 0 then
        local count = data.do_num + data.get_num
        if count >= data.all_num then
            self.is_resonate_extract_redpoint = true
        end
    else
        self.is_resonate_extract_redpoint = (data.is_point == 1)
        if self.is_resonate_extract_redpoint then
            --等级不满的情况下
            if not self:isResonateMaxLevel(self.resonate_stone_level) then
                local config = Config.ResonateData.data_const.single_refine_consume
                if config and next(config.val) ~= nil then
                    local cost_item_id = config.val[1][1]
                    local single_cost_count = config.val[1][2]
                    local count = BackpackController:getInstance():getModel():getItemNumByBid(cost_item_id, BackPackConst.Bag_Code.BACKPACK)
                    if count < single_cost_count then
                        self.is_resonate_extract_redpoint = false
                    end
                end
            end
        end
    end

    --策划要求不显示在主界面 
    local data = {bid = HeroConst.RedPointType.eResonate_extract, status = self.is_resonate_extract_redpoint}
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.resonate, {data})

    --红点有变化
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Extract_Redpoint_Event, self.is_resonate_extract_redpoint)
end
--是否有共鸣精炼经验红点
function HeroModel:isResonateExtractRedpoint()
    return (self.is_resonate_extract_redpoint == true)
end


--重生次数
function HeroModel:setResetCount(data)
    if not data then return end
    self.reset_count = data.day_num
    local hero_vo = self:getHeroById(data.partner_id)
    if hero_vo and next(hero_vo) ~= nil then
        hero_vo:initResetTime(data.end_time)
    end
end

function HeroModel:getResetCount()
    return self.reset_count 
end
function HeroModel:removeResetTimeInfo()
   for k,v in pairs(self.hero_list) do
       v.reset_time = nil
   end
end

--是否是公会pvp 阵法类型 
function HeroModel:isGuildPvpFrom(form_type)
    if self.dic_guild_from_type == nil then
        self.dic_guild_from_type = {}
        local config_list = Config.CombatTypeData.data_fight_list
        if config_list then
            for k,config in pairs(config_list) do
                if config.is_guild_pvp == 1 then
                    if next(config.from) ~= nil then
                        for _,form in pairs(config.from[1]) do
                            self.dic_guild_from_type[form] = true
                        end
                    end
                end
            end
        end
    end
    return self.dic_guild_from_type[form_type]
end

function HeroModel:__delete()
end