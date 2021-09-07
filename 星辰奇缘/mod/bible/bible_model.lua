BibleModel = BibleModel or BaseClass(BaseModel)

function BibleModel:__init()
    self.bibleWin = nil

    self.brewModel = nil
    self.invest_type = 2

    self.tagType = {
        None = 0,
        Worth = 1,
    }

    self.tribleData = {}
    self.tribleStatusData = {}
    self.data20493 = {} --每日直购信息

    self.limitClick = {}
    self.timerId = {}

    self.qrCodeData = {message = {qrcode_url = "", url = ""}}

    -- self.bibleList = {
    --     [1] = {key=1, name = TI18N("每日签到"), icon = "WelfareIcon2",index = 1}
    --     , [2] = {key=2, name = TI18N("七天登录"), icon = "WelfareIcon4",index = 6}
    --     , [3] = {key=3, name = TI18N("等级礼包"), icon = "WelfareIcon1",index = 8}
    --     , [4] = {key=4,name = TI18N("伊芙的钻石袋"), icon = "Assets90002", package = AssetConfig.base_textures, index = 7, tag = self.tagType.Worth}
    --     , [5] = {key=5, name = TI18N("首充奖励"), icon = "WelfareIcon3",index = 2, tag = self.tagType.Worth}
    --     , [6] = {key=6, name = TI18N("本周特惠"), icon = "WelfareIcon2",index = 11}
    --     , [7] = {key=7, name = TI18N("CDkey礼包"), icon = "WelfareIcon1",index = 12}
    --     , [8] = {key=8, name = TI18N("幸运转盘"), icon = "WelfareIcon1",index = 5}
    --     , [9] = {key=9, name = TI18N("限时特惠"), icon = "WelfareIcon9",index = 9, tag = self.tagType.Worth}
    --     , [10] = {key=10,name = TI18N("每日祝福"), icon = "WelfareIcon10", index = 3}
    --     , [11] = {key=11,name = TI18N("节日礼物"), icon = "WelfareIcon3", index = 12}
    --     , [12] = {key=12,name = TI18N("超级VIP"), icon = "svfimg", package = AssetConfig.eyou_activity_textures, index = 9}
    --     , [13] = {key=13,name = TI18N("五星评价"), icon = "fefimg", package = AssetConfig.eyou_activity_textures, index = 10}
    --     , [14] = {key=14,name = TI18N("关注送礼"), icon = "I18Nfgfimg", package = AssetConfig.eyou_activity_textures, index = 11}
    --     , [15] = {key=15,name = "", icon = "2021", index = 12, tag = self.tagType.Worth} -- 三个礼包专用
    --     , [16] = {key=16,name = TI18N("限时礼包"), icon = "WelfareIcon3", index = 4, tag = self.tagType.Worth}
    --     , [17] = {key=17,name = TI18N("月度礼包"), icon = "I18N_Monthly", index = 9,tag = self.tagType.Worth}
    --     , [18] = {key=18,name = TI18N("成长基金"), icon = "Gift2", index = 9,tag = self.tagType.Worth}
    --     , [19] = {key=19,name = TI18N("招募奖励"), icon = "RegressionIcon1", index = 11}
    --     , [20] = {key=20, name = TI18N("实名制"), icon = "WelfareIcon11",index = 13}
    -- }

    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.bibleList = {
            [1] = {key=1, name = TI18N("每日签到"), icon = "WelfareIcon2",index = 1}
            , [2] = {key=2, name = TI18N("七天登录"), icon = "WelfareIcon4",index = 6}
            , [3] = {key=3, name = TI18N("等级礼包"), icon = "WelfareIcon1",index = 8}
            , [4] = {key=4,name = TI18N("伊芙的钻石袋"), icon = "Assets90002", package = AssetConfig.base_textures, index = 7, tag = self.tagType.Worth}
            , [5] = {key=5, name = TI18N("首充奖励"), icon = "WelfareIcon3",index = 2, tag = self.tagType.Worth}
            , [6] = {key=6, name = TI18N("本周特惠"), icon = "WelfareIcon2",index = 11}
            , [8] = {key=8, name = TI18N("幸运转盘"), icon = "WelfareIcon1",index = 5}
            , [9] = {key=9, name = TI18N("限时特惠"), icon = "WelfareIcon9",index = 9, tag = self.tagType.Worth}
            , [10] = {key=10,name = TI18N("每日祝福"), icon = "WelfareIcon10", index = 3}
            , [16] = {key=16,name = TI18N("限时礼包"), icon = "WelfareIcon3", index = 4, tag = self.tagType.Worth}
            , [11] = {key=11,name = TI18N("节日礼物"), icon = "WelfareIcon3", index = 12}
            , [15] = {key=15,name = "", icon = "2021", index = 10, tag = self.tagType.Worth}
            , [17] = {key=17,name = TI18N("月度礼包"), icon = "I18N_Monthly", index = 9,tag = self.tagType.Worth}
            , [18] = {key=18,name = TI18N("成长基金"), icon = "Gift2", index = 9,tag = self.tagType.Worth}
            , [19] = {key=19,name = TI18N("招募奖励"), icon = "RegressionIcon1", index = 11}
            , [20] = {key=20, name = TI18N("实名制"), icon = "WelfareIcon11",index = 14}
            , [21] = {key=21, name = TI18N("新品时装"), icon = "Item1", index = 13}
            , [22] = {key=22,name = "", icon = "2021", index = 10, tag = self.tagType.Worth}
            , [23] = {key=23, name = TI18N("充值好礼"), icon = "IconImg", index = 4}
        }

        -- if BaseUtils.GetPlatform() == "jailbreak" then
        if BaseUtils.GetLocation() ~= KvData.localtion_type.sg then
            if not BaseUtils.IsVerify then
                self.bibleList[7] = {key=7, name = TI18N("CDkey礼包"), icon = "WelfareIcon1",index = 11}
            end
        end
        -- end
        if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
            self.bibleList = {
                [1] = {key=1, name = TI18N("每日签到"), icon = "WelfareIcon2",index = 1}
                , [2] = {key=2, name = TI18N("七天登录"), icon = "WelfareIcon4",index = 3}
                , [3] = {key=3, name = TI18N("等级礼包"), icon = "WelfareIcon1",index = 4}
                -- , [4] = {key=4,name = "伊芙的钻石袋", icon = "Assets90002", package = AssetConfig.base_textures, index = 5}
                -- , [5] = {key=5, name = "首充奖励", icon = "WelfareIcon3",index = 9}
                , [6] = {key=6, name = TI18N("本周特惠"), icon = "WelfareIcon2",index = 8}
                , [8] = {key=8, name = TI18N("幸运转盘"), icon = "WelfareIcon1",index = 2}
                , [9] = {key=9, name = TI18N("限时特惠"), icon = "WelfareIcon9",index = 6, tag = self.tagType.Worth}
                , [11] = {key=11,name = TI18N("节日礼物"), icon = "WelfareIcon3", index = 11}
                , [15] = {key=15,name = TI18N(""), icon = "2021", index = 7, tag = self.tagType.Worth}
                , [16] = {key=16,name = TI18N("限时礼包"), icon = "WelfareIcon3", index = 4, tag = self.tagType.Worth}
                , [17] = {key=17,name = TI18N("月度礼包"), icon = "I18N_Monthly", index = 9,tag = self.tagType.Worth}
                , [18] = {key=18,name = TI18N("成长基金"), icon = "Gift2", index = 9,tag = self.tagType.Worth}
                , [19] = {key=19,name = TI18N("招募奖励"), icon = "RegressionIcon1", index = 11}
                , [21] = {key=21, name = TI18N("新品时装"), icon = "Item1", index = 10}
                , [22] = {key=22,name = "", icon = "2021", index = 10, tag = self.tagType.Worth}
                , [23] = {key=23, name = TI18N("充值好礼"), icon = "IconImg", index = 4}
            }
        end
    else
        self.bibleList = {
            [1] = {key=1, name = TI18N("每日签到"), icon = "WelfareIcon2",index = 1}
            , [2] = {key=2, name = TI18N("七天登录"), icon = "WelfareIcon4",index = 6}
            , [3] = {key=3, name = TI18N("等级礼包"), icon = "WelfareIcon1",index = 8}
            , [4] = {key=4,name = TI18N("伊芙的钻石袋"), icon = "Assets90002", package = AssetConfig.base_textures, index = 7, tag = self.tagType.Worth}
            , [5] = {key=5, name = TI18N("首充奖励"), icon = "WelfareIcon3",index = 2, tag = self.tagType.Worth}
            , [6] = {key=6, name = TI18N("本周特惠"), icon = "WelfareIcon2",index = 11}
            , [7] = {key=7, name = TI18N("CDkey礼包"), icon = "WelfareIcon1",index = 12}
            , [8] = {key=8, name = TI18N("幸运转盘"), icon = "WelfareIcon5",index = 5}
            , [9] = {key=9, name = TI18N("限时特惠"), icon = "WelfareIcon9",index = 9, tag = self.tagType.Worth}
            , [10] = {key=10,name = TI18N("每日祝福"), icon = "WelfareIcon10", index = 3}
            , [11] = {key=11,name = TI18N("节日礼物"), icon = "WelfareIcon3", index = 14}
            , [15] = {key=15,name = "", icon = "2021", index = 10, tag = self.tagType.Worth}
            , [16] = {key=16,name = TI18N("限时礼包"), icon = "WelfareIcon3", index = 4, tag = self.tagType.Worth}
            , [17] = {key=17,name = TI18N("月度礼包"), icon = "I18N_Monthly", index = 9,tag = self.tagType.Worth}
            , [18] = {key=18,name = TI18N("成长基金"), icon = "Gift2", index = 9,tag = self.tagType.Worth}
            , [19] = {key=19,name = TI18N("招募奖励"), icon = "RegressionIcon1", index = 12}
            , [20] = {key=20, name = TI18N("实名制"), icon = "WelfareIcon11",index = 14}
            , [21] = {key=21, name = TI18N("新品时装"), icon = "Item1", index = 13}
            , [22] = {key=22,name = "", icon = "2021", index = 10, tag = self.tagType.Worth}
            , [23] = {key=23, name = TI18N("充值好礼"), icon = "IconImg", index = 4}
        }
        if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
            self.bibleList = {
                [1] = {key=1, name = TI18N("每日签到"), icon = "WelfareIcon2",index = 1}
                , [2] = {key=2, name = TI18N("七天登录"), icon = "WelfareIcon4",index = 3}
                , [3] = {key=3, name = TI18N("等级礼包"), icon = "WelfareIcon1",index = 5}
                -- , [4] = {key=4,name = "伊芙的钻石袋", icon = "Assets90002", package = AssetConfig.base_textures, index = 5}
                -- , [5] = {key=5, name = "首充奖励", icon = "WelfareIcon3",index = 7}
                , [6] = {key=6, name = TI18N("本周特惠"), icon = "WelfareIcon2",index = 9}
                , [7] = {key=7, name = TI18N("CDkey礼包"), icon = "WelfareIcon1",index = 10}
                , [8] = {key=8, name = TI18N("幸运转盘"), icon = "WelfareIcon5",index = 2}
                , [9] = {key=9, name = TI18N("限时特惠"), icon = "WelfareIcon9",index = 6, tag = self.tagType.Worth}
                , [11] = {key=11,name = TI18N("节日礼物"), icon = "WelfareIcon3", index = 11}
                , [15] = {key=15,name = "", icon = "2021", index = 8, tag = self.tagType.Worth}
                , [16] = {key=16,name = TI18N("限时礼包"), icon = "WelfareIcon3", index = 4, tag = self.tagType.Worth}
                , [17] = {key=17,name = TI18N("月度礼包"), icon = "I18N_Monthly", index = 9,tag = self.tagType.Worth}
                , [18] = {key=18,name = TI18N("成长基金"), icon = "Gift2", index = 9,tag = self.tagType.Worth}
                , [19] = {key=19,name = TI18N("招募奖励"), icon = "RegressionIcon1", index = 10}
                , [20] = {key=20, name = TI18N("实名制"), icon = "WelfareIcon11",index = 13}
                , [21] = {key=21, name = TI18N("新品时装"), icon = "Item1", index = 12}
                , [22] = {key=22,name = "", icon = "2021", index = 10, tag = self.tagType.Worth}
                , [23] = {key=23, name = TI18N("充值好礼"), icon = "IconImg", index = 4}
            }
        end
        if BaseUtils.GetLocation() == KvData.localtion_type.sg then
            self.bibleList = {
                [1] = {key=1, name = TI18N("每日签到"), icon = "WelfareIcon2",index = 1}
                , [2] = {key=2, name = TI18N("七天登录"), icon = "WelfareIcon4",index = 6}
                , [3] = {key=3, name = TI18N("等级礼包"), icon = "WelfareIcon1",index = 7}
                , [4] = {key=4,name = TI18N("伊芙的钻石袋"), icon = "Assets90002", package = AssetConfig.base_textures, index = 8, tag = self.tagType.Worth}
                , [5] = {key=5, name = TI18N("首充奖励"), icon = "WelfareIcon3",index = 2, tag = self.tagType.Worth}
                , [6] = {key=6, name = TI18N("本周特惠"), icon = "WelfareIcon2",index = 13}
                -- , [7] = {key=7, name = TI18N("CDkey礼包"), icon = "WelfareIcon1",index = 10}
                , [8] = {key=8, name = TI18N("幸运转盘"), icon = "WelfareIcon5",index = 5}
                , [9] = {key=9, name = TI18N("限时特惠"), icon = "WelfareIcon9",index = 14, tag = self.tagType.Worth}
                , [10] = {key=10,name = TI18N("每日祝福"), icon = "WelfareIcon10", index = 3}
                , [11] = {key=11,name = TI18N("节日礼物"), icon = "WelfareIcon3", index = 15}
                , [12] = {key=12,name = TI18N("超级VIP"), icon = "svfimg", package = AssetConfig.eyou_activity_textures, index = 9}
                , [13] = {key=13,name = TI18N("五星评价"), icon = "fefimg", package = AssetConfig.eyou_activity_textures, index = 10}
                , [14] = {key=14,name = TI18N("关注送礼"), icon = "I18Nfgfimg", package = AssetConfig.eyou_activity_textures, index = 11}
                , [15] = {key=15,name = "", icon = "2021", index = 12, tag = self.tagType.Worth}
                , [16] = {key=16,name = TI18N("限时礼包"), icon = "WelfareIcon3", index = 4, tag = self.tagType.Worth}
                , [17] = {key=17,name = TI18N("月度礼包"), icon = "I18N_Monthly", index = 9,tag = self.tagType.Worth}
                , [18] = {key=18,name = TI18N("成长基金"), icon = "Gift2", index = 9,tag = self.tagType.Worth}
                , [19] = {key=19,name = TI18N("招募奖励"), icon = "RegressionIcon1", index = 10}
                , [21] = {key=21, name = TI18N("新品时装"), icon = "Item1", index = 10}
                , [22] = {key=22,name = "", icon = "2021", index = 10, tag = self.tagType.Worth}
                , [23] = {key=23, name = TI18N("充值好礼"), icon = "IconImg", index = 4}
            }
        end
    end

    self.bibleList[24] = {key=24, name = TI18N("实名认证"), icon = "WelfareIcon2", index = 16}
    self.bibleList[25] = {key=25, name = TI18N("二维码分享"), icon = "erweima", index = 17}
    self.bibleList[26] = {key=26, name = TI18N("更新好礼"), icon = "WelfareIcon11", index = 7}
    self.bibleList[28] = {key=28, name = TI18N("萌萌喵喵"), icon = "WelfareIcon28", index = 4}

    for id, v in pairs(DataBible.data_list) do
        self.bibleList[id] = v
    end

    self.classList = {
        [1] = {name = TI18N("礼包")}
        ,[2] = {name = TI18N("指引")}
        ,[3] = {name = TI18N("帮助"), icon = "Strategy", package = AssetConfig.strategy_textures}
        ,[4] = {name = TI18N("活动")}
    }


    self.LevelGiftStatus = {
        Get = 1, -- 已领取
        Receivable = 2, -- 可领取
        Cannot = 3,   -- 不可领取
    }

    self.levelupShowData = {}   -- 等级礼包的显示全部基于该表，数据发生变化时只能通过函数 CheckForLevelGift 修改此表
    self.levelGiftStatus = {}
    self:Init()

    EventMgr.Instance:AddListener(event_name.logined, function() self:LevelGift() end)

    self.openArgs = nil

    self.bibleDailyGiftSocketData = nil
    self.billeDailyGiftDebugTime =  3600

    self:GroupQuestsByLevelBracket()
end

function BibleModel:__delete()
    if self.bibleWin ~= nil then
        self.bibleWin:DeleteMe()
        self.bibleWin = nil
    end
end

function BibleModel:Init()
    -- self.brewModel = BibleBrewModel.New(self)
end

function BibleModel:OpenWindow(args)
    if BaseUtils.IsVerify and BaseUtils.IsIosVest() then  
        return
    end
    self.openArgs = args
    self:CheckForLevelGift()
    if self.bibleWin == nil then
        self.bibleWin = BibleWindow.New(self)
    end
    self.bibleWin:Open(args)
end

function BibleModel:CloseWindow()
    WindowManager.Instance:CloseWindow(self.bibleWin)
end

function BibleModel:LevelGift()
    self.levelupList = {}           -- 免费等级礼包
    self.levelUnfreeList = {}       -- 收费等级礼包
    local classes = RoleManager.Instance.RoleData.classes
    for _,v in pairs(DataAgenda.data_lev_gift) do
        if v.classes == classes then
            table.insert(self.levelupList, BaseUtils.copytab(v))
        end
    end
    for i=1,#self.levelupList do
        self.levelupList[i].got = 0
        self.levelupList[i].lev = i * 10
    end
    -- BaseUtils.dump(self.levelupList, "===================================111111111111111111")
    for _,v in pairs(DataAgenda.data_lev_unfree) do
        if v.classes == classes or v.classes == 0 then
            self.levelUnfreeList[v.lev] = BaseUtils.copytab(v)
        end
    end
    table.sort(self.levelupList, function(a,b) return a.base_id < b.base_id end)
    for i,v in ipairs(self.levelupList) do
        v.lev = i * 10
    end

    self.theLastLevelGiftbaseId = self.levelupList[#self.levelupList].base_id
end

function BibleModel:CheckForLevelGift()
    local data_lev_gift = DataAgenda.data_lev_gift
    local myLevel = RoleManager.Instance.RoleData.lev
    local baseList = {}
    for _,v in pairs(data_lev_gift) do
        baseList[v.base_id] = 1
    end
    local baseids = {}
    for k,_ in pairs(baseList) do
        table.insert(baseids, k)
    end
    table.sort(baseids, function(a, b) return a < b end)
    self.currentLevelGift = 0
    -- BibleManager.Instance.redPointDic[1][3] = false

    if BackpackManager.Instance.volumeOfItem == 0 then
        return
    end

    for i=1,#baseids do
        if BackpackManager.Instance:GetItemCount(baseids[i]) > 0 then
            self.currentLevelGift = i
            break
        end
    end

    local size = #self.levelupList -- DataAgenda.data_lev_gift_length / #KvData.classes_name
    for i=1,size do
        local status = nil
        if myLevel >= i * 10 then
            if ((RoleManager.Instance.RoleData.lev_break_times or 0) > 0) and QuestManager.Instance.questTab[40103] == nil then  -- 经过等级突破的
                status = self.LevelGiftStatus.Get           -- 经过突破后，并且已经领过世界英雄任务，只能不严谨地认为是已领取
            else
                status = self.LevelGiftStatus.Receivable    -- 当前等级比所需等级高，应被认为是可以领取的
            end
        else
            status = self.LevelGiftStatus.Cannot            -- 当前等级不足肯定是不能领取的
        end
        self.levelGiftStatus[i] = {status = status, base_id = baseids[i]}
    end

    -- BaseUtils.dump(self.levelGiftStatus, "<color='#ffff00'>self.levelGiftStatus</color>")

    -- print(self.currentLevelGift .. "   -----------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    -- BaseUtils.dump(self.levelupList, "<color='#00ffff'>self.levelupList</color>")

    -- self.currentLevelGift 表示当前背包的礼物，背包里面有10*n级礼包，self.currentLevelGift = n，否则self.currentLevelGift = 0
    if self.currentLevelGift == 0 then
        -- 背包没有最高等级礼物，并且人物等级不低于最高级，可认为所有等级礼物都领取过了
        if RoleManager.Instance.RoleData.lev >= size * 10 then
            for _,v in pairs(self.levelupList) do
                v.got = 1
            end

        -- 经过等级突破，等级肯定不低于95级
        elseif (RoleManager.Instance.RoleData.lev_break_times or 0) > 0 then
            -- 已经完成世界英雄任务，因为背包里面没有等级礼物，所以认为用过所有礼物了
            if QuestManager.Instance.questTab[40103] == nil then
                for _,v in pairs(self.levelupList) do
                    v.got = 1
                end
            else
                -- 未完成世界英雄任务，则90级礼包一定没领取
                for _,v in pairs(self.levelupList) do
                    if v.lev < 90 then
                        v.got = 1
                    else
                        v.got = 0
                    end
                end
            end

        -- 未经过突破，因为背包没有礼物，则世界英雄任务一定未完成，90级礼包一定没领
        elseif RoleManager.Instance.RoleData.lev >= 80 then
            for k,v in pairs(self.levelupList) do
                if v.lev < 90 then
                    v.got = 1
                else
                    v.got = 0
                end
            end
        end
    else
        -- 背包里面有礼物，那就说明之前的都领取过了，之后都没领取
        for i=1,self.currentLevelGift - 1 do
            self.levelupList[i].got = 1
        end
        for i=self.currentLevelGift,size do
            self.levelupList[i].got = 0
        end
    end

    -- BaseUtils.dump(self.levelUnfreeList, "<color='#00ffff'>self.levelUnfreeList</color>")
    self.levelupShowData = {}
    local tempList = {}
    for k,v in pairs(self.levelUnfreeList) do
        if v.is_buy ~= 1 and v.time >= BaseUtils.BASE_TIME then
            tempList[v.lev] = {lev = v.lev, limitTime = v.time, idx = v.idx, itemList = v.show_item_list, worth = v.worth, loss = v.loss}
        end
    end

    -- BaseUtils.dump(tempList, "tempList")
    -- BaseUtils.dump(self.levelupList, "<color='#00ffff'>self.levelupList</color>")
    for k,v in pairs(self.levelupList) do
        if v ~= nil then
            if v.got ~= 1 then
                if tempList[v.lev] == nil then
                    tempList[v.lev] = {}
                end
                tempList[v.lev].lev = v.lev
                tempList[v.lev].limitTime = nil
                tempList[v.lev].itemList = v.item_list
                tempList[v.lev].base_id = v.base_id
            else
            end
        end
    end

    -- BaseUtils.dump(tempList, "<color='#00ffff'>tempList</color>")
    for k,v in pairs(tempList) do
        if v ~= nil then
            if self.currentLevelGift ~= 0 then
                if v.lev < (self.currentLevelGift + 3) * 10 then
                    table.insert(self.levelupShowData, v)
                end
            else
                if myLevel >= 80 then
                    table.insert(self.levelupShowData, v)
                end
            end
        end
    end

    table.sort(self.levelupShowData, function(a,b) return a.lev < b.lev end)
    -- BaseUtils.dump(self.levelupShowData, "<color='#00ffff'>self.levelupShowData -- 2</color>")

    -- 检查红点
    local isShowLevelUpRedPoint = false
    for i,v in ipairs(self.levelupShowData) do
        if v.limitTime == nil then          -- 等级礼包
            isShowLevelUpRedPoint = isShowLevelUpRedPoint or (myLevel >= v.lev)
        else
            isShowLevelUpRedPoint = isShowLevelUpRedPoint or true
        end
    end
    BibleManager.Instance.redPointDic[1][3] = (BibleManager.Instance.notShowedLevelGift == true) and isShowLevelUpRedPoint
    if #self.levelupShowData == 0 then
        BibleManager.Instance.redPointDic[1][3] = false
    end

    BibleManager.Instance:CheckMainUIIconRedPoint()
end

-- 分类指引任务
function BibleModel:GroupQuestsByLevelBracket()
    local allQuest = DataQuest.data_get
    self.guideQuestList = {}
    self.guildQuestNum = {}
    local ceil = math.ceil
    local part = nil
    for _,id in ipairs(DataQuest.data_guild[13]) do
        local questData = DataQuest.data_get[id]
        part = ceil((questData.lev + 1) / 10)
        if self.guideQuestList[part] == nil then
            self.guideQuestList[part] = {}
            self.guildQuestNum[part] = 0
        end
        self.guideQuestList[part][questData.id] = questData
        self.guildQuestNum[part] = self.guildQuestNum[part] + 1
    end
    for k,v in pairs(allQuest) do
        if v.sec_type == QuestEumn.TaskType.guide then
        end
    end
end

function BibleModel:AnalyQuestList()
    self.guideQuestListForShow = {}
    self.partToShowIndex = {}
    -- local questList = QuestManager.Instance.questTab
    for k,v in pairs(self.guideQuestList) do
        table.insert(self.guideQuestListForShow, {key = k, value = {}})
        for _,quest in pairs(v) do
            table.insert(self.guideQuestListForShow[#self.guideQuestListForShow].value, quest)
        end

        -- table.sort(self.guideQuestListForShow[#self.guideQuestListForShow].value, function (a,b)
        --     return self:CompareQuest(a,b)
        -- end)
    end
    table.sort(self.guideQuestListForShow, function(a, b) return a.key < b.key end)
    for i,v in ipairs(self.guideQuestListForShow) do
        self.partToShowIndex[v.key] = i
    end
end

function BibleModel:CompareQuest(a, b)
    local questTab = QuestManager.Instance.questTab
    local lev = RoleManager.Instance.RoleData.lev
    if questTab[a.id] == nil then
        if questTab[b.id] == nil then
            return a.lev > b.lev
        else
            return false
        end
    else
        if questTab[b.id] == nil then
            return true
        else
            if questTab[a.id].finish == questTab[b.id].finish then
                return a.id < b.id
            else
                return questTab[a.id].finish > questTab[b.id].finish
            end
        end
    end
end

function BibleModel:FriendHelp()
    if self.help_bags_panel == nil then
        self.help_bags_panel = FriendHelpPanel.New()
    end
    self.help_bags_panel:Show()
end

function BibleModel:OpenToHelpWin(data)
    if self.tohelp_bags_panel == nil then
        self.tohelp_bags_panel = WelfareBagsTohelpPanel.New(self)
    end
    -- print("ooooooooooooooooooooooooo")
    -- print(data)
    -- print(data.extraData.helpId)
    -- BaseUtils.dump(data,"BibleModel:OpenToHelpWin(data)")
    self.tohelp_bags_panel:Show(data)
end

--检查限时礼包是否显示
function BibleModel:CheckDailyGiftShow()
    if self.bibleDailyGiftSocketData == nil then
        return false
    end
    local timeLeft = self.bibleDailyGiftSocketData.max_time - (self.bibleDailyGiftSocketData.keep_time + (BaseUtils.BASE_TIME - math.max(self.bibleDailyGiftSocketData.login_time,self.bibleDailyGiftSocketData.start_time))) - self.billeDailyGiftDebugTime
    if timeLeft >= 0 then
        return true
    end
    return false
end

--检查限时礼包倒计时剩余时间
function BibleModel:GetDailyGiftLeftTime()
    local leftTime = 0
    if self.bibleDailyGiftSocketData ~= nil then
        leftTime = self.bibleDailyGiftSocketData.max_time - (self.bibleDailyGiftSocketData.keep_time + (BaseUtils.BASE_TIME - math.max(self.bibleDailyGiftSocketData.login_time,self.bibleDailyGiftSocketData.start_time))) - self.billeDailyGiftDebugTime
    end
    return leftTime
end


-- 每日礼包
function BibleModel:checkDailyHoroscope()
    return RoleManager.Instance.RoleData.lev >= DailyHoroscopeManager.Instance.model.open_lev
end

-- 限时特惠
function BibleModel:checkLimittimePrivilege()
    local leftTime = 0
    if PrivilegeManager.Instance.limitTimePrivilegeInfo ~= nil and PrivilegeManager.Instance.limitTimePrivilegeInfo.flag == 1 then
        local dataIfo = PrivilegeManager.Instance.limitTimePrivilegeInfo
        leftTime = dataIfo.max_time - (dataIfo.keep_time + (BaseUtils.BASE_TIME - math.max(dataIfo.login_time,dataIfo.start_time))) - 1800
    end
    return leftTime
end

-- 在线奖励
function BibleModel:checkOnlineReward()
    local isNeedShow = false
    local dataItemList = CampaignManager.Instance:GetCampaignDataList(CampaignEumn.Type.OnLine)
    for i,v in ipairs(dataItemList) do
        if v.status == 0 or v.status == 1 then
            isNeedShow = true
            break
        end
    end
    return isNeedShow
end

--只有配置bible_data才有效
function BibleModel:CheckTabShowById(id)
    local v = DataBible.data_list[id]
    if v == nil then 
        return false
    end
    local flag = false
    --开启结束时间验证
    local sTime = v.sTime[1]
    local eTime = v.eTime[1]
    
    local start_time = tonumber(os.time{year = sTime[1], month = sTime[2], day = sTime[3], hour = sTime[4], min = sTime[5], sec = sTime[6]})
    local end_time = tonumber(os.time{year = eTime[1], month = eTime[2], day = eTime[3], hour = eTime[4], min = eTime[5], sec = eTime[6]})

    if BaseUtils.BASE_TIME >= start_time and BaseUtils.BASE_TIME <= end_time then
        flag = true
    end

    local open_flag = false
    --开服持续时间验证
    if BaseUtils.BASE_TIME <= CampaignManager.Instance.open_srv_time + v.day * 86400 then
        open_flag = true
    end

    --渠道验证
    local chanle_flag = true
    if #v.platformChanleId > 0 then
        chanle_flag = false
        for _, channelId in ipairs(v.platformChanleId) do
            if ctx.PlatformChanleId == channelId then
                chanle_flag = true
                break
            end
        end
    end
    return (flag or open_flag) and chanle_flag
end

function BibleModel:CheckTabShow()
    -- local showBuyThree = false
    -- if CampaignManager.Instance.buyThreeTab ~= nil then
    --     for _,v in pairs(CampaignManager.Instance.buyThreeTab.sub) do
    --         showBuyThree = showBuyThree or (CampaignManager.Instance.campaignTab[v.id].status ~= 2)
    --     end
    -- end
    return {
        [2] = false   -- 检查七天登录
        , [3] = (#self.levelupShowData ~= 0)                  -- 检查等级礼包
        , [4] = not BaseUtils.IsVerify and (BibleManager.Instance.isShowInvest == true or BibleManager.Instance.isShowInvest2 == true)    -- 检查投资计划
        ,[5] = false --(FirstRechargeManager.Instance:isHadDoFirstRecharge2() ~= true) --首充页签
        -- ,[7] = ctx.PlatformChanleId ~= 74 --cdkey
        ,[8] = self:checkOnlineReward() --在线奖励
        ,[9] = self:checkLimittimePrivilege() > 0--限时特惠
        ,[10] = self:checkDailyHoroscope() --每日
        ,[15] = false -- showBuyThree and (RoleManager.Instance.RoleData.lev >= 30) -- 三个活动礼包
        ,[16] = not BaseUtils.IsVerify and self:CheckDailyGiftShow()-- PrivilegeManager.Instance.charge > 0
        ,[17] = not (BaseUtils.IsVerify and BaseUtils.IsIosVest())
        ,[18] = not BaseUtils.IsVerify and (RoleManager.Instance.RoleData.lev < 65 or (PrivilegeManager.Instance.growthFundCanReceive == true))
        ,[19] = not BaseUtils.IsVerify and RoleManager.Instance.RoleData.lev >= 70
        ,[11] = RoleManager.Instance.RoleData.lev >= 20
        ,[20] = RoleManager.Instance:ShowRealName()
        ,[22] = (self.showTribleReward == true and RoleManager.Instance.RoleData.lev >= 30)
        ,[23] = self:CheckRechargeTab()
        -- ,[24] = not BaseUtils.IsVerify and not BaseUtils.IsIosVest() and ctx.PlatformChanleId ~= 33 and SdkManager.Instance:IsOpenRealName() and BibleManager.Instance.isRealName == 0
        ,[24] = ctx.PlatformChanleId == 33 or ctx.PlatformChanleId == 74 or ctx.PlatformChanleId == 0
        ,[25] = not BaseUtils.IsVerify and (ctx.PlatformChanleId == 33 or ctx.PlatformChanleId == 0 or ctx.PlatformChanleId == 74 or ctx.PlatformChanleId == 174)
        -- ,[26] = (Application.platform == RuntimePlatform.Android and (DownLoadManager.Instance.model.hasReward_Type2 == 0 or BaseUtils.CSVersionToNum() < 10700) 
        --         and (ctx.PlatformChanleId == 0 or ctx.PlatformChanleId == 33 or ctx.PlatformChanleId == 51 or ctx.PlatformChanleId == 12 or ctx.PlatformChanleId == 22 or ctx.PlatformChanleId == 9 or ctx.PlatformChanleId == 15 or ctx.PlatformChanleId == 32 or ctx.PlatformChanleId == 124 or ctx.PlatformChanleId == 121 or ctx.PlatformChanleId == 11 or ctx.PlatformChanleId == 110 or ctx.PlatformChanleId == 8 or ctx.PlatformChanleId == 13))
        --         or (Application.platform == RuntimePlatform.IPhonePlayer and BaseUtils.GetGameName() == "xcqy" and (DownLoadManager.Instance.model.hasReward_Type2 == 0 or BaseUtils.CSVersionToNum() < 20900))
        ,[26] = false
        ,[27] = self:CheckTabShowById(27) and RoleManager.Instance.RoleData.lev >= 30
        ,[28] = self:CheckDirectBuy()
    }
end

function BibleModel:BuildTribleData(data)
    local idList = {}
    for id,v in pairs(self.tribleData) do
        if v ~= nil then
            table.insert(idList, id)
        end
    end
    for _,id in ipairs(idList) do
        self.tribleData[id] = nil
    end

    for _,v in ipairs(data.list) do
        self.tribleData[v.id] = self.tribleData[v.id]  or {group = {}}
        local tab = self.tribleData[v.id]
        tab.id = v.id
        tab.start_time = v.start_time
        tab.end_time = v.end_time
        tab.desc1 = v.desc1
        tab.desc2 = v.desc2
        tab.title = v.title
        for _,item in ipairs(v.item_list) do
            tab.group[item.group] = tab.group[item.group] or {gift_list = {}}
            local group = tab.group[item.group]
            group.gift_list[item.gift_id] = group.gift_list[item.gift_id] or {reward = {}}
            local gift = group.gift_list[item.gift_id]
            gift.price = item.price
            gift.origin_price = item.origin_price
            gift.title = item.title
            gift.desc1 = item.desc1
            gift.desc2 = item.desc2
            gift.gift_id = item.gift_id
            table.insert(gift.reward, {
                    item_id = item.item_id,
                    num = item.num,
                    classes = item.classes,
                    sex = item.sex,
                    bind = item.bind,
                    min_lev = item.min_lev,
                    max_lev = item.max_lev,
                    min_lev_break = item.min_lev_break,
                    max_lev_break = item.max_lev_break,
                })
        end
    end

    self:OnCheckTrible()
end

function BibleModel:UpdateTribleStatus(data)
    for _,v in ipairs(data.list) do
        if self.tribleData[v.id] ~= nil and self.tribleData[v.id].group[v.group] ~= nil then
            self.tribleData[v.id].group[v.group].status = 1
        end
    end

    self.showTribleReward = false
    BibleManager.Instance.redPointDic[1][22] = false
    if self.currentTribleData ~= nil then
        for _,group in pairs(self.currentTribleData.group) do
            for _,gift in pairs(group.gift_list) do
                if group.status == 0 or group.status == nil then
                    self.showTribleReward = true
                    if #gift.price == 0 then
                        BibleManager.Instance.redPointDic[1][22] = true
                    end
                end
            end
        end
    end

    BibleManager.Instance.onUpdateRedPoint:Fire()
end

function BibleModel:OnCheckTrible()
    local nowTrible = nil
    for k,v in pairs(self.tribleData) do
        if v ~= nil then
            if BaseUtils.BASE_TIME >= v.start_time and BaseUtils.BASE_TIME < v.end_time then
                nowTrible = v
                break
            end
        end
    end
    if (nowTrible == nil and self.currentTribleData == nil) or (nowTrible ~= nil and self.currentTribleData ~= nil and nowTrible.id == self.currentTribleData.id) then
        self.currentTribleData = nowTrible
    else
        self.currentTribleData = nowTrible
        BibleManager.Instance.onUpdateTrible:Fire()
    end
end

function BibleModel:CheckDirectBuy()
    local openTime = CampaignManager.Instance.open_srv_time
    local startTime = openTime + 15 * 86400
    if BaseUtils.BASE_TIME > startTime then
        return true
    end
    return false
end

function BibleModel:CheckRechargeTab()
    -- print("开服活动时间=======================================================================================================================")
    local openTime = CampaignManager.Instance.open_srv_time

    local oy = tonumber(os.date("%Y", openTime))
    local om = tonumber(os.date("%m", openTime))
    local od = tonumber(os.date("%d", openTime))


    local beginTime = tonumber(os.time{year = oy, month = om, day = od, hour = 0, min = 00, sec = 0}) or 0

    if beginTime ~= 0 then
        local baseTime = BaseUtils.BASE_TIME
        local distanceTime = baseTime - beginTime

        local d = math.ceil(distanceTime / 86400)

        -- print(d)
        -- print(tostring(BibleManager.Instance.isShowRechargeTab))
        if d > 14  then
            if BibleManager.Instance.isShowRechargeTab == false then
               BibleManager.Instance.isShowRechargeTab = true
            end
            return true
        end
    end
    BibleManager.Instance.isShowRechargeTab = false
    return false
end

--直购红点状态
function BibleModel:CheckDirectBuyRedPointStatus(data)
    if (data or {}).camp_info == nil then
        return false
    end
    local status = false
    for i, info in pairs(data.camp_info) do
        if info.type == 0 then
            if data.active_val >= info.need_val and info.time > 0 then
                status = true
                break
            end
        end
    end
    return status
end

function BibleModel:StartLimitClickDirectBuy(i)
    self.limitClick[i] = true
    self.timerId[i] = LuaTimer.Add(5 * 60 * 1000, function()
        self.limitClick[i] = false
    end)
end

function BibleModel:CloseLimitClickDirectBuy(i)
    self.limitClick[i] = false
    if self.timerId[i] then
        LuaTimer.Delete(self.timerId[i])
    end
end
