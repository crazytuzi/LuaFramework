require "Core.Manager.ConfigManager";

ShopDataManager = { };
ShopDataManager.typeShops = { };-- 商城分类，引索是商城 的 id 的类别
ShopDataManager.hasPuyProdyct = { };

ShopDataManager.MESSAGE_HAS_BUY_PRODUCTS_CHANGE = "MESSAGE_HAS_BUY_PRODUCTS_CHANGE";
local _sortfunc = table.sort 


ShopDataManager.shtop_ids={};
ShopDataManager.shtop_ids.SUISHENG=5; -- 随身商店

function ShopDataManager.Init()
    ShopDataManager.hasPuyProdyct = { };
    ShopDataManager.InitConfig();
end

function ShopDataManager.InitConfig()
    local cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SHOP);
    local typeShops = { }

    for key, value in pairs(cf) do
        local id = value.id;
        if typeShops[id] == nil then
            typeShops[id] = { };
        end

        local arr = typeShops[id];
        arr[value.order + 0] = value;
    end

    ShopDataManager.typeShops = typeShops;
end

function ShopDataManager.GetCfData(type, product_id)

    local sp = ShopDataManager.typeShops[type];
    for key, value in pairs(sp) do

        if value.product_id == product_id then
            return value;
        end

    end

    return nil;
end

--[[
02 获取商店商品购买次数
输入
s：商店ID

输出：
id：商店id，
shops：[p:道具ID，t:已经购买次数]

0x1002

]]
function ShopDataManager.SetHasBuyProducts(type, items)
    ShopDataManager.hasPuyProdyct[type] = items;

    MessageManager.Dispatch(ShopDataManager, ShopDataManager.MESSAGE_HAS_BUY_PRODUCTS_CHANGE);
end

-- 获取 已经购买过的物品信息
function ShopDataManager.GetHasBuyProduct(type, spid)

    local arr = ShopDataManager.hasPuyProdyct[type];

    if arr == nil then
        return nil;
    else

        for key, value in pairs(arr) do
            local _spid = value.p;
            if _spid == spid then
                return value;
            end
        end

    end
end


function ShopDataManager.GetMyThings(type)
    local arr = ShopDataManager.typeShops[type];
    local req_item = arr[1].req_item;

    if req_item == TShopNotes.req_item_5 then
        return PVPManager.GetPVPPoint();
    elseif req_item == TShopNotes.req_item_7 then
        return StarManager.GetCoin()-- TrumpManager.GetTrumpCoin();
    elseif req_item == TShopNotes.req_item_10 then
     --- 战功
     return PlayerManager.bscore;

    elseif req_item == TShopNotes.req_item_11 then

        return GuildDataManager.GetMyDkp();

    elseif req_item == TShopNotes.req_item_1 then
        return MoneyDataManager.Get_money();
    elseif req_item == TShopNotes.req_item_2 then
        return MoneyDataManager.Get_gold();
    elseif req_item == TShopNotes.req_item_9 then
        return PlayerManager.spend;
    end

    return 0;
end

--[[
条件1
	id=1时，  表示（竞技场中排名1~50排名的玩家可兑换，包括50）
	id=2时，填写为0，表示不需要判断此条件

条件2
	id==1时，表示需要角色等级达到xx级
	id==2时，表示需要角色等级达到xx级

    ['rank_condition'] = 50,	--兑换条件1
		['lev_condition'] = 60	--兑换条件2

]]
--  判断是否符合条件去兑换物品
function ShopDataManager.CheckChange(type, product_id)

    local cf = ShopDataManager.GetCfData(type, product_id);

    local my_info = HeroController:GetInstance().info;
    local my_level = my_info.level;

    local rank_condition = cf.rank_condition;
    local lev_condition = cf.lev_condition;

    local res = { v = true };

    if type == TShopNotes.Shop_type_pvp then
        --  竞技场商店
        local my_pvpRank = PVPManager.GetPVPRank();

        if my_pvpRank == nil or my_pvpRank == 0 then
            my_pvpRank = 999999;
        end

        if rank_condition ~= 0 then
            if my_pvpRank > rank_condition then
                res.v = false;
                res.rank_condition = LanguageMgr.Get("tshop/ShopDataManager/tip_rank", { t = rank_condition });
                res.tip = LanguageMgr.Get("tshop/ShopDataManager/tip_rank1");
            end
        end

    elseif type == TShopNotes.Shop_type_trump then
        --  法宝商店

    elseif type == TShopNotes.Shop_type_fightScene then
        --  战场商店

    elseif type == TShopNotes.Shop_type_team then
        --   帮贡商店

    elseif type == TShopNotes.Shop_type_npc then
        --  NPC商店

    elseif type == TShopNotes.Shop_type_zhongzhi then
        -- 种子商店

    end

    if lev_condition ~= 0 and my_level < lev_condition then
        res.v = false;
        res.lev_condition = LanguageMgr.Get("tshop/ShopDataManager/tip_lv", { t = lev_condition });
        res.tip = LanguageMgr.Get("tshop/ShopDataManager/tip_lv1");
    end

    --  下面 是判断 购买数量上限


    return res;

end


--[[
	['key'] = '2_4',
		['id'] = 2,
		['name'] = '法宝商店',
		['order'] = 4,
		['product_id'] = 310015,
		['num'] = 9999,
		['req_item'] = 310000,
		['price'] = 60,
		['rank_condition'] = 0,
		['lev_condition'] = 40
]]

-- 获取对应类型商城 的物品信息列表
function ShopDataManager.GetProductsByShopType(type)

    local arr = ShopDataManager.typeShops[type];
    local res = ConfigManager.Clone(arr);
    return res;

end



-- 根据  tshop 获取对应的数据 队列
function ShopDataManager.GetProductsForTShop(type)

    local res = ShopDataManager.GetProductsByShopType(type);

    _sortfunc(res, function(a, b)

        a.ct = ShopDataManager.CheckChange(type, a.product_id);
        b.ct = ShopDataManager.CheckChange(type, b.product_id);

        local a_ct = -100000;
        local b_ct = -100000;

        if not a.ct.v then
            a_ct = 0;
        end

        if not b.ct.v then
            b_ct = 0;
        end

        local a_rev = a.order + a_ct;
        local b_rev = b.order + b_ct;


        return a_rev < b_rev

    end )

    ----- 而且后面 是 10 个为一组 数据
    local num = table.getn(res);
    local b_num = num / 10;
    local len = math.ceil(b_num);

    local index = 1;

    local b_res = { };

    for i = 1, len do

        if b_res[i] == nil then
            b_res[i] = { };
        end

        local obj = b_res[i];

        for j = 1, 10 do
            if num >= index then
                obj[j] = res[index];
                index = index + 1;
            else
                obj[j] = nil;
            end
        end
    end


    return b_res;

end

