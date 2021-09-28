module ("ShopUtils",package.seeall)
require "script/ui/shopall/ExploitsExchangeLayer"
require "script/ui/shopall/godShop/GodShopLayer"
require "script/ui/shopall/FindLongExchangeLayer"
require "script/ui/shopall/MysteryShop/MysteryShopLayer"
require "script/ui/shopall/MysteryMerchant/MysteryMerchantLayer"
require "script/ui/shopall/weekendShop/WeekendShopLayer"
require "script/ui/shopall/prop/PropLayer"
require "script/ui/shopall/honor/HonorShopLayer"
require "script/ui/shopall/arena/PrestigeShop"
require "script/ui/moon/MoonShopLayer"
require "script/ui/shopall/GuildShopLayer"
require "script/ui/shopall/liangcao/BarnExchangeLayer"
require "script/ui/guild/GuildDataCache"
require "script/ui/shopall/purgatoryshop/PurgatoryShopLayer"
require "script/ui/shopall/loardwarshop/LordwarShopLayer"
require "script/ui/mission/shop/MissionShopLayer"
require "script/ui/kfbw/kfbwshop/KFBWShopLayer"
require "script/ui/kfbw/KuafuData"
require "script/ui/countryWar/shop/CountryWarShopLayer"
require "script/ui/shopall/tally/TallyShopLayer"
require "script/ui/deviltower/shop/DevilTowerShopLayer"
require "script/ui/deviltower/DevilTowerData"
require "script/ui/sevenlottery/shop/SevenLotteryShopLayer"

local _shopTable = nil

function shopAllInfo( ... )
    if _shopTable ~= nil then
        return _shopTable
    end
    require "script/ui/shopall/ShoponeLayer"
    local centerLayerSize = ShoponeLayer.getCenterSize()
    _shopTable ={

            {
                --道具商店
                img = {images_n = "images/shop/shopall/prop_n.png",images_h = "images/shop/shopall/prop_h.png",},
                tag = ShoponeLayer.ksTagPropShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState(ksSwitchShop, false),
                    hasTip = false,
                    callback = PropLayer.createLayer,
                    args = {nil,true},
                },
            },

            {
                --神秘商人
                img = {images_n = "images/recharge/btn_mystery_merchant1.png",images_h = "images/recharge/btn_mystery_merchant2.png",},
                tag = ShoponeLayer.ksTagMysteryPerson,
                note_data = {
                    isOpen = true,
                    callback = MysteryMerchantLayer.createCenterLayer,
                    hasTip = false,
                    args = {centerLayerSize},
                },
            },

            {
                --竞技商店
                img = {images_n = "images/shop/shopall/arena_n.png",images_h = "images/shop/shopall/arena_h.png",},
                tag = ShoponeLayer.ksTagArenaShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState( ksSwitchArena, false),
                    hasTip = false,
                    callback = PrestigeShop.createPrestigeShopLayer,
                    args = {nil,true},

                },
            },

            {
                --神秘商店
                img = {images_n = "images/recharge/mystery_shop/shop_n.png",images_h = "images/recharge/mystery_shop/shop_h.png",},
                tag = ShoponeLayer.ksTagMysteryShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState(ksSwitchResolve, false),
                    hasTip = ActiveCache.secretTip,
                    args = {centerLayerSize},
                    callback = MysteryShopLayer.createCenterLayer,

                },
            },


            {
                --军团商店
                img = {images_n = "images/shop/shopall/legion_n.png",images_h = "images/shop/shopall/legion_h.png",},
                tag = ShoponeLayer.ksTagLegionShop,
                note_data = {
                    isOpen = GuildDataCache.getMineSigleGuildId() ~= 0,
                    hasTip = false,
                    callback = GuildShopLayer.createCenterLayer,
                    args = {centerLayerSize},

                },
            },

            {
                --战功商店
                img = {images_n = "images/shop/shopall/battabel_n.png",images_h = "images/shop/shopall/battabel_h.png",},
                tag = ShoponeLayer.ksTagBattabelShop,
                note_data = {
                    isOpen = GuildBossCopyData.isOpen(),
                    callback = ExploitsExchangeLayer.createCenterLayer,
                    hasTip = false,
                    args = {centerLayerSize},
                },
            },

            {
                --粮草商店
                img = {images_n = "images/shop/shopall/liangcao_n.png",images_h = "images/shop/shopall/liangcao_h.png",},
                tag = ShoponeLayer.ksTagLiangcaoShop,
                note_data = {
                    isOpen = GuildDataCache.getBarnIsOpen(),
                    hasTip = false,
                    args = {centerLayerSize},
                    callback = BarnExchangeLayer.createCenterLayer,
                },
            },

            {
                --比武商店
                img = {images_n = "images/shop/shopall/match_n.png",images_h = "images/shop/shopall/match_h.png",},
                tag = ShoponeLayer.ksTagMatchShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState( ksSwitchContest, false),
                    hasTip = false,
                    callback = HonorShop.createHonorShopLayer,
                    args = {nil,true},

                },
            },

            {
                --炼狱商店
                img = {images_n = "images/shop/shopall/lianyu_n.png",images_h = "images/shop/shopall/lianyu_h.png",},
                tag = ShoponeLayer.ksTagLianyuShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState(ksSwitchHellCopy, false),
                    hasTip = false,
                    args = {centerLayerSize},
                    callback = PurgatoryShopLayer.createCenterLayer,
                },
            },

            {
                --周末商店
                img = {images_n = "images/weekendShop/weekend_btn_n.png",images_h = "images/weekendShop/weekend_btn_h.png",},
                tag = ShoponeLayer.ksTagZhoumoPerson,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState(ksWeekendShop, false),
                    key    = "weekendShop",
                    hasTip = false,
                    args = {centerLayerSize},
                    callback = WeekendShopLayer.createCenterLayer,

                },
            },

            {
                --神兵商店
                img = {images_n = "images/shop/shopall/god_n.png",images_h = "images/shop/shopall/god_h.png",},
                tag = ShoponeLayer.ksTagGodShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState(ksSwitchGodWeapon, false),
                    callback = GodShopLayer.entry,
                    args = {-499, 1009, 1},
                    hasTip = false,

                },
            },

            {
                --符印商店
                img = {images_n = "images/shop/shopall/moon_n.png",images_h = "images/shop/shopall/moon_h.png",},
                tag = ShoponeLayer.ksTagMoonShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState(ksSwitchMoon, false),
                    hasTip = false,
                    callback = MoonShopLayer.createCenterLayer,
                    args = {centerLayerSize},
                },
            },

            {
                --寻龙商店
                img = {images_n = "images/shop/shopall/xunlong_n.png",images_h = "images/shop/shopall/xunlong_h.png",},
                tag = ShoponeLayer.ksTagXunLongShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState(ksFindDragon, false),
                    hasTip = false,
                    callback = FindLongExchangeLayer.createCenterLayer,
                    args = {centerLayerSize}
                },
            },

            {
                --跨服商店
                img = {images_n = "images/shop/shopall/kuafu_n.png",images_h = "images/shop/shopall/kuafu_h.png",},
                tag = ShoponeLayer.ksTagKuaFuShop,
                note_data = {
                    isOpen = ActivityConfigUtil.isActivityOpen("lordwar"),
                    hasTip = false,
                    callback = LordwarShopLayer.createCenterLayer,
                    args = {centerLayerSize},
                },
            },

            {
                --  名望商店
                img = {images_n = "images/shop/shopall/mingwang_n.png",images_h = "images/shop/shopall/mingwang_h.png",},
                tag =ShoponeLayer.ksTagMingWang,
                note_data = {
                    isOpen = MissionShopLayer.isOpen(),
                    hasTip = false,
                    callback = MissionShopLayer.createLayer,
                    args = {centerLayerSize},
                },
            },


            {
                -- 跨服比武商店
                img = {images_n = "images/shop/shopall/kuafubiwu_n.png",images_h = "images/shop/shopall/kuafubiwu_h.png",},
                tag = ShoponeLayer.ksTagKuaWu,
                note_data = {
                    isOpen = KuafuData.isOpenKuafuShop(),
                    hasTip = false,
                    callback = KFBWShopLayer.createCenterLayer,
                    args = {centerLayerSize},
                },
            },

            {
                --国战商店
                img = {images_n = "images/shop/shopall/guozhan_n.png",images_h = "images/shop/shopall/guozhan_h.png",},
                tag = ShoponeLayer.ksTagCountryWar,
                note_data = {
                    isOpen = ShoponeLayer.isOpenCW(),
                    hasTip = false,
                    callback = CountryWarShopLayer.createCenterLayer,
                    args = {centerLayerSize},
                },
            },

            {
                --符印商店
                img = {images_n = "images/shop/shopall/bingfu_n.png",images_h = "images/shop/shopall/bingfu_h.png",},
                tag = ShoponeLayer.ksTagTallyShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState(ksSwitchTally, false),
                    hasTip = false,
                    callback = TallyShopLayer.createCenterLayer,
                    args = {centerLayerSize},
                },
            },

            {
                --梦魇商店
                img = {images_n = "images/tower/mengyan_n.png",images_h = "images/tower/mengyan_h.png",},
                tag = ShoponeLayer.ksTagDevilTowerShop,
                note_data = {
                    isOpen = DevilTowerData.isDevilTowerOpen(false),
                    hasTip = false,
                    callback = DevilTowerShopLayer.createCenterLayer,
                    args = {centerLayerSize},
                },
            },

             {
                --七星台商店
                img = {images_n = "images/shop/shopall/qixing-n.png",images_h = "images/shop/shopall/qixing-h.png",},
                tag = ShoponeLayer.ksTagSevenLotteryShop,
                note_data = {
                    isOpen = DataCache.getSwitchNodeState(ksSwitchSevenLottery, false),
                    hasTip = false,
                    callback = SevenLotteryShopLayer.createCenterLayer,
                    args = {centerLayerSize},
                },
            },
    }

    return _shopTable
end

function getShopIndexByTag( p_shopTag )
    local shopIndex = 1
    if p_shopTag == nil then
        return shopIndex
    end
    local shopTable = shopAllInfo()
    for i = 1, #shopTable do
        if shopTable[i].tag == p_shopTag then
            shopIndex = i
            break
        end
    end
    return shopIndex
end




