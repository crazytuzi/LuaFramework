TShopNotes = { }

TShopNotes.OPEN_TSHOP = "OPEN_TSHOP";
TShopNotes.CLOSE_TSHOP = "CLOSE_TSHOP";


TShopNotes.Shop_type_temp = 0 --临时商店
TShopNotes.Shop_type_pvp = 1;  --  竞技场商店    PVPManager.GetPVPPoint()
TShopNotes.Shop_type_trump = 2;  --  法宝商店    TrumpManager.GetTrumpCoin();
TShopNotes.Shop_type_fightScene = 3;  --  战场商店 
TShopNotes.Shop_type_team = 4; -- 帮贡商店
TShopNotes.Shop_type_npc = 5; -- NPC商店   -- 使用灵石  MoneyDataManager.Get_money()
TShopNotes.Shop_type_zhongzhi = 6; -- 种子商店  
TShopNotes.Shop_type_star = 7; -- 命星兑换  

TShopNotes.req_item_1=1; -- 灵石
TShopNotes.req_item_2=2; -- 仙玉
TShopNotes.req_item_5=5; --竞技场积分 
TShopNotes.req_item_7=7; -- 法则碎片
TShopNotes.req_item_9=9; -- 修为
TShopNotes.req_item_10=10; -- 战功
TShopNotes.req_item_11=11; -- 仙盟贡献


TShopNotes.Icons = { };

TShopNotes.Icons[TShopNotes.Shop_type_temp] = "xianyu";
TShopNotes.Icons[TShopNotes.Shop_type_pvp] = "pvpPoint";
TShopNotes.Icons[TShopNotes.Shop_type_trump] = "fabaosuipian";
TShopNotes.Icons[TShopNotes.Shop_type_fightScene] = "xiuwei";
TShopNotes.Icons[TShopNotes.Shop_type_team] = "xianmenggongxian";
TShopNotes.Icons[TShopNotes.Shop_type_npc] = "lingshi";
TShopNotes.Icons[TShopNotes.Shop_type_zhongzhi] = "xianmenggongxian";