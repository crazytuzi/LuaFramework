--[[
    文件名: GuildHomeLayer
    描述: 帮派主页
    创建人: chenzhong
    创建时间: 2017.03.36
-- ]]

local GuildHomeLayer = class("GuildHomeLayer",function()
	return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
    {
        isRestoreLayer: 是否是 LayerManager 恢复该页面，调用者一般不用关心该参数，默认为 false
    }
]]
function GuildHomeLayer:ctor(params)
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
    self:initUI()

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            --LayerManager.removeLayer(self)
            LayerManager.addLayer({name = "home.HomeLayer"})
        end
    })
    self.mCloseBtn:setPosition(cc.p(604, 1040))
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 请求帮派信息
    if not params or not params.isRestoreLayer then
        self:requestGuildInfo()
    end
end

-- 初始化页面控件
function GuildHomeLayer:initUI()
    -- 创建页面背景
    local bgSprite = ui.newSprite("bp_01.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 流水(特效)
    local waterEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_bangpai",
            position = cc.p(320, 570),
            loop = true,
        })

    -- 创建主按钮
    self:creaeMainBtn()
    -- 创建右边按钮
    self:createRightBtn()
    -- 创建帮派信息
    self:createInfoView()

end

-- 获取恢复数据
function GuildHomeLayer:getRestoreData()
    local retData = {
        isRestoreLayer = true,
    }

    return retData
end

-- 创建主按钮
function GuildHomeLayer:creaeMainBtn()
    local buildNeedLv = GuildConfig.items[1].buildNeedGuildLv
    local btnInfos = {
        -- 帮派试炼
        {
            normalImage = "bp_02.png",
            iconBg = "bp_10.png",
            iconBgPos = cc.p(37, 551),
            position = cc.p(118, 547),
            checkRedDotFunc = function()  -- 显示小红点判断函数
                -- 是否决战开始
                return RedDotInfoObj:isValid(ModuleSub.eGuildBattle)
            end,
            clickAction = function(sender)
                self:requestGuildBattleInfo()
            end,
        },
        -- 帮派商店
        {
            normalImage = "bp_04.png",
            iconBg = "bp_09.png",
            iconBgPos = cc.p(407, 455),
            position = cc.p(500, 430),
            checkRedDotFunc = function()  -- 显示小红点判断函数
                return false  -- todo
            end,
            clickAction = function(sender)
                LayerManager.addLayer({
                    name = "guild.GuildStoreLayer",
                })
            end
        },
        -- 帮派管理
        {
            normalImage = "bp_05.png",
            iconBg = "bp_08.png",
            iconBgPos = cc.p(172, 835),
            position = cc.p(276, 838),
            checkRedDotFunc = function()  -- 显示小红点判断函数
                -- 检查建筑升级和审核列表是否有小红点
                return RedDotInfoObj:isValid(Enums.ClientRedDot.eGuildMana)
            end,
            clickAction = function(sender)
                LayerManager.addLayer({
                    name = "guild.GuildManaLayer",
                    needRestore = true,
                    cleanUp = false
                })
            end,
            -- bgDescribe = "bp_06.png"
        },
        -- 帮派佣兵
        {
            normalImage = "bp_03.png",
            iconBg = "bp_11.png",
            iconBgPos = cc.p(494, 690),
            position = cc.p(404, 675),
            checkRedDotFunc = function()  -- 显示小红点判断函数
                return GuildObj:getPlayerGuildInfo().IfCanShare
            end,
            clickAction = function(sender)
                LayerManager.addLayer({
                    name = "guild.GuildHireLayer",
                })
            end
        },
        -- 帮派秘籍
        {
            normalImage = "bp_34.png",
            iconBg = "bp_06.png",
            iconBgPos = cc.p(130, 305),
            position = cc.p(237, 325),
            checkRedDotFunc = function()  -- 显示小红点判断函数
                return false  -- todo
            end,
            clickAction = function(sender)
                LayerManager.addLayer({
                    name = "guild.GuildBookHomeLayer",
                })
            end
        },
    }

    for _, btnInfo in pairs(btnInfos) do
        -- 创建按钮
        local tempBtn = ui.newButton(btnInfo)
        self.mParentLayer:addChild(tempBtn)

        local iconBg = ui.newSprite(btnInfo.iconBg)
        iconBg:setPosition(btnInfo.iconBgPos)
        self.mParentLayer:addChild(iconBg)
        if btnInfo.bgDescribe then
            local des = ui.newSprite(btnInfo.bgDescribe)
            des:setPosition(btnInfo.position.x + 60, btnInfo.position.y)
            self.mParentLayer:addChild(des)
        end

        -- 小红点逻辑
        if btnInfo.checkRedDotFunc then
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(btnInfo.checkRedDotFunc())
            end
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = {EventsName.eGuildHomeAll}, parent = iconBg})
        end
    end
end

-- 创建右边按钮
function GuildHomeLayer:createRightBtn()
    local btnInfos = {
        --建设
        {
            normalImage = "tb_17.png",
            checkRedDotFunc = function()  -- 显示小红点判断函数
                return GuildObj:getPlayerGuildInfo().IfCanBuildTime
            end,
            clickAction = function(sender)
                if GuildObj:getBuildLv(34004000) < GuildConfig.items[1].buildNeedGuildLv then
                    MsgBoxLayer.addOKLayer(TR("帮派%d级开启帮派建设,可在每日任务中获得帮派资金提升帮派等级", GuildConfig.items[1].buildNeedGuildLv),TR("提示"))
                    return
                end

                LayerManager.addLayer({
                    name = "guild.GuildBuildLayer",
                })
            end
        },
        -- 排行
        {
            normalImage = "tb_16.png",
            clickAction = function(sender)
                LayerManager.addLayer({
                    name = "guild.GuildRankLayer",
                    cleanUp = false
                })
            end
        },
        -- 成员
        {
            normalImage = "tb_15.png",
            clickAction = function(sender)
                LayerManager.addLayer({
                    name = "guild.GuildMemberLayer",
                    cleanUp = false
                })
            end
        },
        -- 宣言
        {
            normalImage = "tb_14.png",
            clickAction = function(sender)
                local declaration = GuildObj:getGuildInfo().Declaration
                MsgBoxLayer.addOKLayer(declaration,TR("帮派宣言"))
            end
        }
    }

    local startPosX, startPosY = 580, 170
    for index, btnInfo in pairs(btnInfos) do
        -- 创建按钮
        local tempBtn = ui.newButton(btnInfo)
        tempBtn:setPosition(startPosX, startPosY + (index - 1) * 100)
        self.mParentLayer:addChild(tempBtn)

        -- 小红点逻辑
        if btnInfo.checkRedDotFunc then
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(btnInfo.checkRedDotFunc())
            end
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = EventsName.eGuildHomeAll, parent = tempBtn})
        end
    end
end

-- 创建帮派信息
function GuildHomeLayer:createInfoView()
    -- 帮派系信息背景图片
    local infoBgSprite = ui.newSprite("bp_07.png")
    infoBgSprite:setPosition(cc.p(320, 1000))
    self.mParentLayer:addChild(infoBgSprite)
    local bgSize = infoBgSprite:getContentSize()
    
    local nameLabel = ui.newLabel({
        text = "",
        size = 26,
        color = Enums.Color.eBrown,
    })
    nameLabel:setAnchorPoint(0.5, 1)
    nameLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height-5))
    infoBgSprite:addChild(nameLabel)

    -- 帮派等级
    local levelLabel = ui.newLabel({
        text = "",
        size = 22,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    levelLabel:setAnchorPoint(cc.p(0, 0.5))
    levelLabel:setPosition(cc.p(90, 75))
    infoBgSprite:addChild(levelLabel)

    --帮派资金
    local moneyLabel = ui.newLabel({
        text = "",
        size = 22,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    moneyLabel:setAnchorPoint(cc.p(0, 0.5))
    moneyLabel:setPosition(cc.p(90, 35))
    infoBgSprite:addChild(moneyLabel)

    --排名
    local rankLabel = ui.newLabel({
        text = "",
        size = 22,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    rankLabel:setAnchorPoint(cc.p(0, 0.5))
    rankLabel:setPosition(cc.p(355, 75))
    infoBgSprite:addChild(rankLabel)

    --人数
    local memberCountLabel = ui.newLabel({
        text = "",
        size = 22,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        color = Enums.Color.eWhite,
        outlineSize = 2,
    })
    memberCountLabel:setAnchorPoint(cc.p(0, 0.5))
    memberCountLabel:setPosition(cc.p(355, 35))
    infoBgSprite:addChild(memberCountLabel)

    -- 购买人数上限按钮
    local buyBtn = ui.newButton({
            normalImage = "c_21.png",
            clickAction = function ()
                local maxNum = GuildConfig.items[1].maxExpansionNum - GuildObj:getGuildInfo().ExtendCount
                if maxNum <= 0 then
                    ui.showFlashView(TR("帮派人物扩充已达上限"))
                    return
                end
                MsgBoxLayer.selectBuyCountLayer({
                        title = TR("扩充帮派人数"),
                        msgtext = TR("可扩充上限：%d", maxNum),
                        maxNum = maxNum,
                        OkCallback = function (selCount, layerObj, btnObj)
                            self:requestExtendGuild(selCount)
                            LayerManager.removeLayer(layerObj)
                        end,
                        price = Utility.analysisStrResList(GuildConfig.items[1].price),
                    })
            end,
        })
    buyBtn:setPosition(cc.p(530, 35))
    infoBgSprite:addChild(buyBtn)

    -- 注册帮派信息改变后的事件
    local function refreshInfo()
        -- 帮派势力标识
        local forceId = GuildObj:getGuildInfo().ForceId
        local forceTexture = Enums.JHKSamllPic[forceId]

        local guildInfo = GuildObj:getGuildInfo()
        nameLabel:setString(string.format("%s#4e150c%s", forceTexture and "{"..forceTexture.."}" or "", guildInfo.Name or ""))
        levelLabel:setString(TR("等级: %s",  guildInfo.Lv or 0))
        moneyLabel:setString(TR("帮派资金: %s",  Utility.numberWithUnit(guildInfo.GuildFund or 0)))
        rankLabel:setString(TR("排名: %s", guildInfo.RandNum or 0))
        local tempItem = GuildLvRelation.items[guildInfo.Lv or 1]
        local memberMax = tempItem and tempItem.memberNumMax or 0
        memberCountLabel:setString(TR("成员: %s/%s", guildInfo.MemberCount or 0, memberMax+(guildInfo.ExtendCount or 0)))
        -- 帮主，帮派等级达到，扩展上限还有剩余
        local isBangZhu = GuildObj:getPlayerGuildInfo().PostId == 34001001
        local isLvPass = (GuildObj:getGuildInfo().Lv or 0) >= GuildConfig.items[1].guildLvLimit
        local num = GuildConfig.items[1].maxExpansionNum - (GuildObj:getGuildInfo().ExtendCount or 0)
        buyBtn:setVisible(isBangZhu and isLvPass and num > 0)
    end
    Notification:registerAutoObserver(memberCountLabel, refreshInfo, EventsName.eGuildHomeAll)
    refreshInfo(tempSprite)
end

-- ========================= 请求服务器数据相关函数 ===========================

-- 请求帮派信息
function GuildHomeLayer:requestGuildInfo()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetGuildInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            --dump(response, "返回的帮派数据")
            if not response or response.Status ~= 0 then
                if response.Status == -3425 then  -- 尚未加入帮派
                    print("response.Status == -3425")
                    LayerManager.removeLayer(self)
                    LayerManager.addLayer({name = "guild.GuildSearchLayer", cleanUp = false})
                end
                return
            end

            -- 把数据设置到帮派缓存对象中去
            GuildObj:updateGuildInfo(response.Value)
            -- 通知帮派信息改变
            Notification:postNotification(EventsName.eGuildHomeAll)
        end,
    })
end

-- 请求帮派战信息
function GuildHomeLayer:requestGuildBattleInfo()
    HttpClient:request({
        moduleName = "Guild",
        methodName = "GetGuildBattleInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            GuildObj:updateGuildBattleInfo(response.Value)
            -- 报名时间是否结束
            local isEnrollEnd = response.Value.EnrollEndTime - Player:getCurrentTime() <= 0 and true or false
            -- 是否是决战日
            local isFigth = response.Value.IsFightDay
            -- 是否报名
            local isEnroll = response.Value.IsEnroll
            -- 是否到达决战结束时间
            local isFightEnd = response.Value.FightEndTime - Player:getCurrentTime() <= 0 and true or false
            -- 是否到达决战开始时间
            local isFightStart = response.Value.FightStartTime - Player:getCurrentTime() <= 0 and true or false

            if not isEnroll and not isEnrollEnd then
                LayerManager.addLayer({     -- 报名
                            name = "guild.GuildPvpApplyLayer",
                        })
            elseif not isEnroll and isEnrollEnd then
                ui.showFlashView({text = TR("今日帮派战报名时间已结束")})
            elseif isEnroll and isEnrollEnd and not isFightStart then
                ui.showFlashView({text = TR("正在匹配帮派战对手···")})
            elseif isFigth and isEnrollEnd and isFightEnd and isEnroll then
                ui.showFlashView({text = TR("正在结算中···")})
            else
                LayerManager.addLayer({     -- 准备/决战
                            name = "guild.GuildPvpReadyLayer",
                        })
            end
        end,
    })
end

-- 扩充帮派人数上限
function GuildHomeLayer:requestExtendGuild(num)
    HttpClient:request({
        moduleName = "Guild",
        methodName = "ExtendGuild",
        svrMethodData = {num},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 把数据设置到帮派缓存对象中去
            GuildObj:updateGuildInfo(response.Value)
            -- 通知帮派信息改变
            Notification:postNotification(EventsName.eGuildHomeAll)
        end
    })
end

return GuildHomeLayer