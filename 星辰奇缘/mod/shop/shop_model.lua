ShopModel = ShopModel or BaseClass(BaseModel)

function ShopModel:__init()
    self.shopWin = nil
    self.update_shop_item = "Update_Shop_Item"
    self.update_points_shop_item = "Update_Points_Shop_Item"
    self.update_mystery_shop_item = "Update_Mystery_Shop_Item"
    self.update_weekly_shop_item = "Update_Weekly_Shop_Item"
    self.currentSub = 2
    self.currentMain = 1
    self.mysteryRefresh = 0
    self.mysteryRefreshed = 0
    self.productId_IOS = nil
    
    --[[
    1: 全部商品
    2: 每周限购
    3: 神秘商店
    ]]--
    self.datalist = {[1] = {nil, nil, nil}, [2] = {nil, nil, nil}}
    self.pageNum = {[1] = {0, 0, 0, 0}, [2] = {0, 0, 0, 0, 0}}

    self.itemBuyLimitList = {}

    self.isShowRechargeTable = false
    self.dataTypeList = {
        {name = TI18N("商城"), order = 1,
            subList = {
                [1] = {name = TI18N("全部商品"), order = 1}
                , [2] = {name = TI18N("本周优惠"), icon = "weekly", order = 3}
                , [3] = {name = TI18N("神秘商店"), icon = "mystery", lev = 40, order = 4}
                , [4] = {name = TI18N("时装商店"), icon = "fashionshop", order = 5}
                -- , [5] = {name = TI18N("红钻商城"), icon = "90026",textures = AssetConfig.itemicon5, order = 2}
            }
        }
        , {name = TI18N("积分"), order = 2,
            subList = {
                [1] = {name = TI18N("积分商店"), icon = "Assets90012", textures = AssetConfig.base_textures, order = 1}
                , [2] = {name = TI18N("人品兑换"), icon = "Assets90007", textures = AssetConfig.base_textures, order = 3}
                , [3] = {name = TI18N("恩爱兑换"), icon = "Assets90018", textures = AssetConfig.base_textures, order = 4}
                , [4] = {name = TI18N("师道兑换"), icon = "Assets90019", textures = AssetConfig.base_textures, order = 5}
                , [5] = {name = TI18N("王者兑换"), icon = "Assets90020", textures = AssetConfig.base_textures, order = 5, lev = 70, order = 2}
            }
        }
        , { name = TI18N("充值"), order = 3,
            subList = {
                {name = TI18N("充 值"), order = 1}
                , {name = TI18N("充值返利"), order = 2}
                , {name = TI18N("钻石礼物"), order = 3}
            }
        }
        , {name = TI18N("礼包"), order = 4, subList = {}}
    }

    -- ios
    self.rechargeList = {
        {tag = "StardustRomance3K60", rmb = 6, gold = 60}
        , {tag = "StardustRomance3K500", rmb = 50, gold = 500}
        , {tag = "StardustRomance3K980", rmb = 98, gold = 980}
        , {tag = "StardustRomance3K1980", rmb = 198, gold = 1980}
        , {tag = "StardustRomance3K3280", rmb = 328, gold = 3280}
        , {tag = "StardustRomance3K6480", rmb = 648, gold = 6480}
    }
    -- android
    self.androidRechargeList = {
        {tag = "StardustRomance10", rmb = 10, gold = 100}
        , {tag = "StardustRomance50", rmb = 50, gold = 500}
        , {tag = "StardustRomance100", rmb = 100, gold = 1000}
        , {tag = "StardustRomance2000", rmb = 200, gold = 2000}
        , {tag = "StardustRomance5000", rmb = 500, gold = 5000}
        , {tag = "StardustRomance10000", rmb = 1000, gold = 10000}
    }

    self.helpRPText = {
        {
            TI18N("积分可以通过活动和竞技场获得")
            ,TI18N("1.竞技场：<color='#ffff00'>6-12</color>{assets_2, 90012}/场")
            ,TI18N("2.段位赛：<color='#ffff00'>5-10</color>{assets_2, 90012}/场")
            ,TI18N("3.竞技场排名：<color='#ffff00'>20-80</color>{assets_2, 90012}/天")
            ,TI18N("竞技场排名越靠前，获得的积分越高")
        }
        ,{
            TI18N("每天带新人完成以下任务可以获得{assets_2, 90007}")
            ,TI18N("1.悬赏任务：<color='#ffff00'>3-6</color>{assets_2, 90007}/场战斗")
            ,TI18N("2.副本挑战：<color='#ffff00'>6-12</color>{assets_2, 90007}/场战斗")
            ,TI18N("3.天空之塔：<color='#ffff00'>10-20</color>{assets_2, 90007}/场战斗")
            ,TI18N("每天最多可获得<color='#ffff00'>500</color>{assets_2, 90007}，助人为乐从我开始^_^")
        }
        ,{
            TI18N("结缘和完成伴侣任务都会获得恩爱值")
            ,TI18N("1.豪华典礼：<color='#ffff00'>299</color>{assets_2, 90018}")
            ,TI18N("2.普通典礼：<color='#ffff00'>20</color>{assets_2, 90018}")
            ,TI18N("3.伴侣任务： <color='#ffff00'>大量</color>{assets_2, 90018}")
            ,TI18N("典礼浪漫度越高，获得的恩爱值越高")
        }
        ,{
            TI18N("良师值可以通过验收徒弟功课、目标以及师徒任务获得")
            ,TI18N("1.日常功课：<color='#ffff00'>5-10</color>{assets_2, 90019}/次")
            ,TI18N("2.成长目标：<color='#ffff00'>10-30</color>{assets_2, 90019}/个")
            ,TI18N("3.师徒任务：<color='#ffff00'>1-3</color>{assets_2, 90019}/环")
            ,TI18N("师傅积极帮助徒弟提升实力，获得奖励就越快哦~")
        }
        ,{
            TI18N("<color='#ffff00'>王者积分</color>可通过参加<color='#00ff00'>天下第一武道会</color>、<color='#00ff00'>巅峰对决</color>获得")
            ,TI18N("1.武道战斗：胜4{assets_2,90020}、负2{assets_2,90020}")
            ,TI18N("2.晋级奖励：根据晋级头衔获得{assets_2,90020}")
            ,TI18N("3.每周奖励：根据当前头衔获得{assets_2,90020}")
            ,TI18N("4.赛季结算：根据结算时头衔获得{assets_2,90020}")
            ,TI18N("5.巅峰战斗：胜2-4{assets_2,90020}、负1-2{assets_2,90020}")
        }
    }

    self.itemidToRes = {
        [23096] = "Excharge2",
        [23097] = "Excharge3",
        [23098] = "Excharge4",
    }

    self.iosVestRechargeData = {} -- 新马甲包计费点从协议获取
end

function ShopModel:__delete()
    if self.shopWin ~= nil then
        self.shopWin:DeleteMe()
        self.shopWin = nil
    end
end

function ShopModel:OpenWindow()
    if self.shopWin == nil then
        self.shopWin = ShopMainWindow.New(self)
    end

    print(self.currentMain.."_"..self.currentSub)
    self.shopWin:Open()
end

function ShopModel:CloseMain()
    if self.shopWin ~= nil then
        WindowManager.Instance:CloseWindow(self.shopWin)
    end
end

function ShopModel:RoleAssetsListener()
    if self.shopWin ~= nil then
        self.shopWin:RoleAssetsListener()
    end
end

function ShopModel:SetStoreData()
    self.datalist[2][1] = {}
    self.datalist[2][2] = {}
    self.datalist[2][3] = {}
    self.datalist[2][4] = {}
    self.datalist[2][5] = {}
    self.datalist[2][6] = {}

    local roleData = RoleManager.Instance.RoleData
    for _,v in pairs(ShopManager.Instance.itemPriceTab) do
        if v.tab == 2 and (v.sex == roleData.sex or v.sex == 2) and (v.classes == roleData.classes or v.classes == 0) then
            table.insert(self.datalist[2][v.tab2], {tab = 2, tab2 = v.tab2, base_id = v.base_id, id = v.id, num = 1, price = v.price, limit_role = v.limit_role, label = v.label, sort = v.sort})
        end
    end

    table.sort(self.datalist[2][1], function(a,b) return a.sort < b.sort end)
    table.sort(self.datalist[2][2], function(a,b) return a.sort < b.sort end)
    table.sort(self.datalist[2][3], function(a,b) return a.sort < b.sort end)
    table.sort(self.datalist[2][4], function(a,b) return a.sort < b.sort end)
    table.sort(self.datalist[2][5], function(a,b) return a.sort < b.sort end)
    table.sort(self.datalist[2][6], function(a,b) return a.sort < b.sort end)

    --BaseUtils.dump(self.datalist)
    --BaseUtils.dump(self.datalist[2][6])

    for k,v in pairs(self.datalist[2]) do
        self.pageNum[2][k] = math.ceil((#self.datalist[2][k]) / 8)
    end
end


function ShopModel:OpenQuickBuyPanel(args)
    if self.quickbuypanel == nil then
        self.quickbuypanel = ShopQuickBuyPanel.New(self)
    end
    self.quickbuypanel:Show(args)
end

function ShopModel:CloseQuickBuyPanel()
    if self.quickbuypanel ~= nil then
        self.quickbuypanel:DeleteMe()
        self.quickbuypanel = nil
    end
end

function ShopModel:GetChargeList()
    local chargeList = {}
    if Application.platform == RuntimePlatform.IPhonePlayer then
        local iosList = DataRecharge.data_ios
        if BaseUtils.IsNewIosVest() then -- 新马甲包计费点从协议获取
            iosList = self.iosVestRechargeData 
        end
        
        for i,v in pairs(iosList) do
            if v.game_name == BaseUtils.GetGameName() and (v.show_state == 1 or (BaseUtils.IsVerify and not BaseUtils.IsIosVest())) then
                if BaseUtils.IsVerify and v.level > 22 then
                    
                else
                    table.insert(chargeList, {tag = iosList[i].tag, rmb = iosList[i].rmb, gold = iosList[i].gold, tokes = iosList[i].tokes})
                end
            end
        end

        table.sort(chargeList, function(a, b)
            if a.rmb == 30 then
                return true
            elseif b.rmb == 30 then
                return false
            else
                return a.rmb < b.rmb
            end
        end)
    else
        local platformId = ctx.PlatformChanleId
        if platformId == nil then
            platformId = 0
        end
        if BaseUtils.GetLocation() == KvData.localtion_type.sg then
            -- 跟ios同一个配置
            local andriodList = DataRecharge.data_ios
            for i,v in pairs(andriodList) do
                if v.game_name == BaseUtils.GetGameName() and v.show_state == 1 then
                    table.insert(chargeList, {tag = andriodList[i].tag, rmb = andriodList[i].rmb, gold = andriodList[i].gold, tokes = andriodList[i].tokes})
                end
            end
            -- table.sort(chargeList, function(a, b) return a.rmb < b.rmb end)
        else
            local androidList = nil
            if DataRecharge.data_android[platformId] == nil then
                androidList = DataRecharge.data_android[0].rmb2Glod
            else
                androidList = DataRecharge.data_android[platformId].rmb2Glod
            end
            for i=1,#androidList do
                table.insert(chargeList, {tag = "StardustRomance"..androidList[i][1], rmb = androidList[i][1], gold = androidList[i][2], tokes = androidList[i][3]})
            end
        end
    end

    return chargeList
end

function ShopModel:GetSpecialChargeData(gold)
    local gameName = BaseUtils.GetGameName()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        if gameName == "xcqy" then
            return string.format("StardustRomance3K%s", tostring(gold))
        else
            local iosList = DataRecharge.data_ios
            if BaseUtils.IsNewIosVest() then -- 新马甲包计费点从协议获取
                iosList = self.iosVestRechargeData 
            end
            for i,v in pairs(iosList) do
                if v.game_name == gameName and v.gold == gold then
                    return v.tag
                end
            end
        end
    elseif Application.platform == RuntimePlatform.Android then
        return string.format("StardustRomance3K%s", tostring(gold))
    end
end

function ShopModel:GetReturnList()
    local rtTplDataDic = {}
    for k,v in pairs(DataCampaign.data_list) do
        if (tonumber(v.iconid)) == CampaignEumn.Type.Rebate then
            table.insert(rtTplDataDic,v)
        end
    end

    table.sort(rtTplDataDic,function (a,b) return a.group_index < b.group_index end)

    return rtTplDataDic
end

function ShopModel:Update_QuickPricve()
    if self.quickbuypanel ~= nil then
        self.quickbuypanel:RefreshSlivePrive()
    end
end

function ShopModel:OpenRechargeExplain(args)
    if self.explainWin == nil then
        self.explainWin = RechargeExplainWindow.New(self)
    end
    self.explainWin:Open(args)
end

function ShopModel:CloseRechargeExplain()
    if self.explainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.explainWin)
    end
end
