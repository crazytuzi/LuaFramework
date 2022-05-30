-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: gongjianjun@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      商城的数据存储层
-- <br/>Create: 2017-05-11
-- --------------------------------------------------------------------
MallModel = MallModel or BaseClass()

function MallModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function MallModel:config()
    self.buy_list ={}
    self.shop_list = {}

    self.mall_red_list = {} -- 红点数据
end

function MallModel:setBuyList(data)   
    self.buy_list = data
end
function MallModel:getBuyList()
    return self.buy_list
end

function MallModel:getScoreBuyList(shop_type)
    if self.shop_list[shop_type] and next(self.shop_list[shop_type]) ~=nil then 
        return self.shop_list[shop_type]
    end
    return nil
end

--检查当前神格商店中是否存在上阵的的伙伴碎片
function MallModel:checkHeroChips(item_id)
    local is_has = false
    local pos_list = HeroController:getInstance():getModel():getMyPosList()
    if pos_list and next(pos_list or {}) ~= nil then
        for k, v in pairs(pos_list) do
            local partner_data = HeroController:getInstance():getModel():getHeroById(v.id)
            if partner_data and partner_data.chips_id == item_id then
                is_has = true
            end
        end
        return is_has
    end
end


--根据商店类型以及支付类型和单价来判断能够买多少个
function MallModel:checkMoenyByType(pay_type, price)
    local role_vo = RoleController:getInstance():getRoleVo()
    local is_can_buy_num = 0
    local single_price = 0
    if role_vo then
        if type(pay_type) == "number" then --有些资产类型传过来是数字
            if pay_type == Config.ItemData.data_assets_label2id.hero_soul then --神格
                local hero_soul = role_vo.hero_soul
                is_can_buy_num = math.floor(hero_soul / price)
            elseif pay_type == Config.ItemData.data_assets_label2id.silver_coin then
                local silver_coin = role_vo.silver_coin
                is_can_buy_num = math.floor(silver_coin / price)
            elseif pay_type == Config.ItemData.data_assets_label2id.coin then --金币
                local coin = role_vo.coin
                is_can_buy_num = math.floor(coin / price)
            elseif pay_type == Config.ItemData.data_assets_label2id.gold then
                local sum_gold = role_vo.red_gold + role_vo.gold
                is_can_buy_num = math.floor(sum_gold / price)
            elseif pay_type == Config.ItemData.data_assets_label2id.star_point then --探宝积分
                local star_point = role_vo.star_point
                is_can_buy_num = math.floor(star_point / price)
            elseif pay_type == Config.ItemData.data_assets_label2id.arena_guesscent then --冠军积分
                local arena_guesscent = role_vo.arena_guesscent
                is_can_buy_num = math.floor(arena_guesscent / price)
            elseif pay_type == Config.ItemData.data_assets_label2id.gold then --钻石
                local sum_gold = role_vo.gold
                is_can_buy_num = math.floor(sum_gold / price)
            elseif pay_type == Config.ItemData.data_assets_label2id.skin_debris then --皮肤碎片
                local skin_debris = role_vo.skin_debris
                is_can_buy_num = math.floor(skin_debris / price)
            elseif pay_type == Config.ItemData.data_assets_label2id.home_coin then --家园币
                local home_coin = role_vo.home_coin
                is_can_buy_num = math.floor(home_coin / price)
            elseif pay_type == Config.ItemData.data_assets_label2id.cluster_guess_cent then --冠军币
                local cluster_guess_cent = role_vo.cluster_guess_cent
                is_can_buy_num = math.floor(cluster_guess_cent / price)
            else
                local count = BackpackController:getInstance():getModel():getItemNumByBid(pay_type)
                is_can_buy_num = math.floor(count / price)
            end
        else
            if pay_type == 'gold' then
                local gold = role_vo.gold
                is_can_buy_num = math.floor(gold / price)
            elseif pay_type == 'silver_coin' then
                local silver_coin = role_vo.silver_coin
                is_can_buy_num = math.floor(silver_coin / price)
            elseif pay_type == 'coin' then
                local coin = role_vo.coin
                is_can_buy_num = math.floor(coin / price)
            elseif pay_type == "red_gold_or_gold" then
                local sum_gold = role_vo.red_gold + role_vo.gold
                is_can_buy_num = math.floor(sum_gold / price)
            elseif pay_type == "arena_cent" then
                local arena_cent = role_vo.arena_cent
                is_can_buy_num =  math.floor(arena_cent / price)
            elseif pay_type == "friend_point" then
                local friend_point = role_vo.friend_point
                is_can_buy_num =  math.floor(friend_point / price)
            elseif pay_type == "guild" then
                local guild = role_vo.guild
                is_can_buy_num = math.floor(guild / price)
            elseif pay_type == "boss_point" then
                local boss_point = role_vo.boss_point
                is_can_buy_num = math.floor(boss_point / price)
            elseif pay_type == "arena_guesscent" then
                local arena_guesscent = role_vo.arena_guesscent
                is_can_buy_num = math.floor(arena_guesscent / price)
            elseif pay_type == "star_point" then
                local star_point = role_vo.star_point
                is_can_buy_num = math.floor(star_point / price)
            elseif pay_type == "sky_coin" then
                local sky_coin = role_vo.sky_coin
                is_can_buy_num = math.floor(sky_coin / price)
            elseif pay_type == "recruithigh_hero" then
                local recruithigh_hero = role_vo.recruithigh_hero
                is_can_buy_num = math.floor(recruithigh_hero / price)
            elseif pay_type == "expedition_medal" then
                local expedition_medal = role_vo.expedition_medal
                is_can_buy_num = math.floor(expedition_medal / price)
            elseif pay_type == "elite_coin" then
                local elite_coin = role_vo.elite_coin
                is_can_buy_num = math.floor(elite_coin / price)
            elseif pay_type == "skin_debris" then
                local skin_debris = role_vo.skin_debris
                is_can_buy_num = math.floor(skin_debris / price)
            elseif pay_type == "home_coin" then
                local home_coin = role_vo.home_coin
                is_can_buy_num = math.floor(home_coin / price)
            elseif pay_type == "cluster_guess_cent" then
                local cluster_guess_cent = role_vo.cluster_guess_cent
                is_can_buy_num = math.floor(cluster_guess_cent / price)
            elseif pay_type == "peak_guess_cent" then
                local peak_guess_cent = role_vo.peak_guess_cent
                is_can_buy_num = math.floor(peak_guess_cent / price)
            end
        end
    end
    return is_can_buy_num
end

function MallModel:checkActionMoenyByType(pay_type, price)
    local dic_item_id = Config.ItemData.data_assets_id2label
    if dic_item_id and dic_item_id[pay_type] then
        --是一般资产 
        local num = self:checkMoenyByType(pay_type, price)
        return self:checkMoenyByType(pay_type, price)
    end

    local role_vo = RoleController:getInstance():getRoleVo()
    local is_can_buy_num = 0
    if role_vo then
        local count = role_vo:getActionAssetsNumByBid(pay_type)
        is_can_buy_num = math.floor(count / price)
    end
    return is_can_buy_num
end

function MallModel:updateMallRedStatus( bid, status )
    --[[ local _status = self.mall_red_list[bid]
    if _status == status then return end

    self.mall_red_list[bid] = status

    if bid == MallConst.Red_Index.Variety then
        Area_sceneController:getInstance():setBuildRedStatus(Area_sceneConst.Shop_Type.sprite, {{bid = bid, status = status}})
    else
        Area_sceneController:getInstance():setBuildRedStatus(Area_sceneConst.Shop_Type.gift, {{bid = bid, status = status}})
    end
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.shop, {bid = bid, status = status})
    GlobalEvent:getInstance():Fire(MallEvent.Update_Mall_Red_Event, bid, status) ]]
end

function MallModel:getMallRedStateByBid( bid )
    return self.mall_red_list[bid]
end

function MallModel:getChargeShopRedData(  )
    local red_data = {}
    -- 周、月、自选礼包
    for k,bid in pairs(MallConst.Red_Index) do
        if k ~= "Variety" then
            local red_status = self:getMallRedStateByBid(bid)
            table.insert( red_data, {bid = bid, status = red_status} )
        end
    end
    -- 充值、每日礼包、特权礼包红点
    local vip_red_data = VipController:getInstance():getVipRedData()
    for k,v in pairs(vip_red_data) do
        table.insert( red_data, v )
    end
    return red_data
end

function MallModel:__delete()
end
