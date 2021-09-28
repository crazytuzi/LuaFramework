--[[
    文件名：GuildHireLayer
    描述：帮派佣兵
    创建人：chenzhong
    创建时间：2016.3.7
-- ]]

local GuildHireLayer = class("GuildHireLayer", function(params)
    return display.newLayer()
end)

local tabPageTags = {
    eMyHire = 1,             -- 我的佣兵
    eGuildHire = 2,          -- 帮派佣兵
}

function GuildHireLayer:ctor()
    -- 初始化
    self.mGuildShareInfo = {}
    -- 当前选中的tab页签
    self.mPageTag = tabPageTags.eMyHire

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- TabView 子页面控件的parent
    self.mSubLayer = ui.newStdLayer()
    self:addChild(self.mSubLayer)

    -- 初始化界面
    self:initUI()

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eGold, 
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eMerit
        }
    })
    self:addChild(tempLayer)

     -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 请求数据
    self:requesetGetGuildShare()
end

-- 初始化页面控件
function GuildHireLayer:initUI()
    -- 创建底层背景
    self.mBgSprite = ui.newSprite("bp_12.jpg")
    self.mBgSprite:setPosition(cc.p(320, 570))
    self.mParentLayer:addChild(self.mBgSprite)

    -- 挂灯左（特效）
    local lightLeftEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_juhunge",
            position = cc.p(120, 840),
            loop = true,
        })
    -- 挂灯右（特效）
    local lightRightEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_juhunge",
            position = cc.p(520, 840),
            loop = true,
        })

    -- 创建页面切换控件 tabview
    self:createTabLayer()
end


-- 创建页面切换控件 tabview
function GuildHireLayer:createTabLayer()
     -- 添加黑底
    local decBgSize = cc.size(640, 97)
    local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
    decBg:setPosition(cc.p(320, 1053))
    self.mParentLayer:addChild(decBg)

    local btnInfo = {
        {
            text = TR("我的佣兵"), 
            tag = tabPageTags.eMyHire,
            checkRedDotFunc = function()  
                return not self.mGuildShareInfo.ShareId
            end,
        },
        {
            text = TR("帮派佣兵"), 
            tag = tabPageTags.eGuildHire
        }
    }

    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = btnInfo,
        defaultSelectTag = self.mPageTag,
        onSelectChange = function(selectTag)
            if self.mPageTag == selectBtnTag then
                return 
            end
            self.mPageTag = selectTag
            self:changePage()
        end
    })
    tabLayer:setAnchorPoint(0.5, 1)
    tabLayer:setPosition(320, 1080)
    self.mParentLayer:addChild(tabLayer)

    -- 小红点逻辑
    for _, _btnInfo in pairs(btnInfo) do
        if _btnInfo.checkRedDotFunc ~= nil then
            local tabBtns = tabLayer:getTabBtns() or {}
            local btnObj  = tabBtns[tabPageTags.eMyHire]
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(_btnInfo.checkRedDotFunc())
            end
            -- 事件名
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = EventsName.eGuildHomeAll, parent = btnObj})
        end
    end
end

-- 创建我的佣兵页面
function GuildHireLayer:createMyHireLayer()
    self.mSubLayer:removeAllChildren()

    -- 我的共享佣兵信息
    local myShareInfo = {}
    for _, item in pairs(self.mGuildShareInfo.GuildShareInfo or {}) do
        if item.ShareId == self.mGuildShareInfo.ShareId then
            myShareInfo = item
            break
        end
    end

    if next(myShareInfo) then
        -- 页面中间显示的大人物模型
        local heroView = Figure.newHero({
            parent = self.mSubLayer,
            heroModelID = myShareInfo.ModelId,
            IllusionModelId = myShareInfo.IllusionModelId,
            heroFashionId = myShareInfo.CombatFashionOrder,
            needRace = true,
            position = cc.p(320, 200),
            scale = 0.35,
        })

        -- 顶部框
        local topSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 150))
        topSprite:setPosition(cc.p(320, 920))
        self.mSubLayer:addChild(topSprite)

        -- 创建英雄头像
        local header = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = tonumber(myShareInfo.ModelId),
            IllusionModelId = myShareInfo.IllusionModelId,
            cardShowAttrs = {CardShowAttr.eBorder},
            needGray = false,
            onClickCallback = function ()end
        })
        header:setPosition(60 ,90)
        header:setAnchorPoint(cc.p(0,0.5))
        topSprite:addChild(header)

        -- 名字
        local tmpName, tmpStep = ConfigFunc:getHeroName(myShareInfo.ModelId, {heroStep = myShareInfo.Step, IllusionModelId = myShareInfo.IllusionModelId, heroFashionId = myShareInfo.CombatFashionOrder})
        local nameStr = string.format(myShareInfo.Step > 0 and "Lv%d  %s%s %s+%d" or "Lv%d  %s%s",
            myShareInfo.Lv, 
            "#46220d", tmpName, 
            Enums.Color.eOrangeH, tmpStep)
        local nameLabel = ui.newLabel({
            text = nameStr,
            color = Enums.Color.eOrange,
            size = 24,
            anchorPoint = cc.p(0, 0.5),
        })
        nameLabel:setPosition(280, 105)
        topSprite:addChild(nameLabel)

        --描述
        local tempList = self.mGuildShareInfo.GuildShareInfo or {}
        local decsLabel = ui.newLabel({
            text = TR("当前帮派已有%s%d#46220d名佣兵", Enums.Color.eOrangeH, #tempList),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 22,
        })
        decsLabel:setPosition(140, 865)
        self.mSubLayer:addChild(decsLabel)

        --战斗力
        local fAPBgSprite = ui.newFAPView(myShareInfo.FAP, false)
        fAPBgSprite:setPosition(cc.p(320, 730))
        self.mSubLayer:addChild(fAPBgSprite)

        -- 共享时间
        local shareTimeLabel = ui.newLabel({
            text = "",
            size = 20,
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
        })
        shareTimeLabel:setPosition(280, 75)
        topSprite:addChild(shareTimeLabel)

        -- 佣兵收入
        local shareRewardLable = ui.newLabel({
            text = "",
            size = 20,
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
        })
        shareRewardLable:setPosition(280, 45)
        topSprite:addChild(shareRewardLable)

        -- 倒计时
        Utility.schedule(shareRewardLable, function()
            -- 共享时间
            local shareTime = Player:getCurrentTime() - self.mGuildShareInfo.ShareTime
            shareTimeLabel:setString(TR("共享时间:%s%s", Enums.Color.eOrangeH, MqTime.formatAsHour(shareTime)))

            -- 佣兵收入
            local shareConfig = GuildShareRelation.items[1]
            local rewardCount = shareConfig.validIncomeOnceGold * math.floor(shareTime / shareConfig.validIncomeInterval)
            local daibiImg = Utility.getDaibiImage(ResourcetypeSub.eGold)
            shareRewardLable:setString(TR("佣兵收入:{%s}%s%s", daibiImg, Enums.Color.eOrangeH, rewardCount))
        end, 1.0)

        -- 所属
        local tempSprite = ui.newLabel({
            text = TR("所属：%s", myShareInfo.PlayerName),
            outlineColor = Enums.Color.eBlack,
            size = 22,
        })
        tempSprite:setPosition(cc.p(320, 820))
        self.mSubLayer:addChild(tempSprite)

        -- 英雄名字
        local underNameStr = string.format(myShareInfo.Step > 0 and "%s %s+%d" or "%s",
            tmpName, 
            Enums.Color.eOrangeH, tmpStep)
        local tempSprite = ui.createLabelWithBg({
            bgFilename = "c_25.png",
            bgSize = cc.size(300, 45),
            labelStr = underNameStr,
            alignType = ui.TEXT_ALIGN_CENTER,
            color = Utility.getQualityColor(HeroModel.items[myShareInfo.ModelId].quality, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        })
        tempSprite:setPosition(cc.p(320, 780))
        self.mSubLayer:addChild(tempSprite)
    else
        -- 顶部框
        local topSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 130))
        topSprite:setPosition(cc.p(320, 920))
        self.mSubLayer:addChild(topSprite)

        local tempLabel = ui.newLabel({
            text = TR("共享佣兵不会影响侠客的上阵，并且还能获得金钱收入，#46220d作为#d38312佣兵的等级越高#46220d，每分钟获取的#d38312收益越大"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            alignType = ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(550, 0)
        })
        tempLabel:setPosition(cc.p(320, 925))
        self.mSubLayer:addChild(tempLabel)

        local tempSpirte = ui.createLabelWithBg({
            bgFilename = "c_25.png",
            bgSize = cc.size(620, 50),
            labelStr = TR("只有上阵侠客才能被共享，主角不能被共享"),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            alignType = ui.TEXT_ALIGN_CENTER,
        })
        tempSpirte:setPosition(cc.p(320, 830))
        self.mSubLayer:addChild(tempSpirte)

        -- 黑色人物影子
        local blackHero = ui.newSprite("c_36.png")
        blackHero:setPosition(cc.p(320, 470))
        self.mSubLayer:addChild(blackHero)

        -- 选择按钮
        local chooseBtn = ui.newButton({
            normalImage = "bp_15.png",
            position = cc.p(320, 480),
            clickAction = function ()
                LayerManager.addLayer({
                    name = "guild.GuildHireChooseLayer",
                })
            end
            })
        self.mSubLayer:addChild(chooseBtn)
    end
end

-- 创建帮派用兵页面
function GuildHireLayer:createGuildHireLayer()
    self.mSubLayer:removeAllChildren()

    local shareInfoList = self.mGuildShareInfo.GuildShareInfo or {}
    if not next(shareInfoList) then
        local tempSprite = ui.createEmptyHint(TR("帮派暂无佣兵"))
        tempSprite:setPosition(320,568)
        self.mSubLayer:addChild(tempSprite)
        return 
    end

    -- 顶部框
    local topSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 150))
    topSprite:setPosition(cc.p(320, 920))
    self.mSubLayer:addChild(topSprite)

    -- "帮派佣兵可以在大罗金库玩法中招募"
    local tempStr = TR("帮派佣兵可以在\n#d38212%s, %s#46220d玩法中招募", 
        ModuleSubModel.items[ModuleSub.eXrxs].name,
        ModuleSubModel.items[ModuleSub.eGuildBattle].name)
    local tempLabel = ui.newLabel({
        text = tempStr,
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d),
        align = cc.TEXT_ALIGNMENT_CENTER,
        dimensions = cc.size(300, 0)
    })
    tempLabel:setPosition(450, 75)
    topSprite:addChild(tempLabel)

    -- 添加左右箭头
    for i=1,2 do
        local posX = i==1 and 20 or 620
        local arrowSprite = ui.newSprite("c_26.png")
        arrowSprite:setPosition(cc.p(posX, 500))
        self.mSubLayer:addChild(arrowSprite)
        if i == 1 then 
            arrowSprite:setRotation(180)
        end     
    end

    -- 帮派用兵列表
    local sliderView = require("common.SliderTableView").new({
        width = 640,
        height = 1010,
        isVertical = false,
        selItemOnMiddle = true,
        itemCountOfSlider = function(sliderObj)
            return #shareInfoList
        end,
        itemSizeOfSlider = function(sliderObj)
            return 640, 1010
        end,
        sliderItemAtIndex = function(sliderObj, itemNode, index, isSelected)
            -- 英雄模样
            local shareInfo = shareInfoList[index + 1]

            -- 英雄模型
            local heroView = Figure.newHero({
                heroModelID = shareInfo.ModelId,
                IllusionModelId = shareInfo.IllusionModelId,
                heroFashionId = shareInfo.CombatFashionOrder,
                needRace = true,
                parent = itemNode,
                position = cc.p(320, 200),
                scale = 0.35,
            })

            -- 所属
            local ownSprite = ui.newLabel({
                text = TR("所属：%s", shareInfo.PlayerName),
                outlineColor = Enums.Color.eBlack,
                size = 22,
            })
            ownSprite:setPosition(cc.p(320, 820))
            itemNode:addChild(ownSprite)

            -- 英雄名字
            local tmpName, tmpStep = ConfigFunc:getHeroName(shareInfo.ModelId, {heroStep = shareInfo.Step, IllusionModelId = shareInfo.IllusionModelId, heroFashionId = shareInfo.CombatFashionOrder})
            local underNameStr = string.format(shareInfo.Step > 0 and "%s %s+%d" or "%s",
                tmpName, 
                Enums.Color.eOrangeH, tmpStep)
            local nameSprite = ui.createLabelWithBg({
                bgFilename = "c_25.png",
                bgSize = cc.size(300, 45),
                labelStr = underNameStr,
                alignType = ui.TEXT_ALIGN_CENTER,
                color = Utility.getQualityColor(HeroModel.items[shareInfo.ModelId].quality, 1),
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            })
            nameSprite:setPosition(cc.p(320, 780))
            itemNode:addChild(nameSprite)

            --战斗力
            local fAPBgSprite = ui.newFAPView(shareInfo.FAP)
            fAPBgSprite:setPosition(cc.p(320, 730))
            itemNode:addChild(fAPBgSprite)
        end,
        selectItemChanged = function(sliderObj, selectIndex)
            local shareInfo = shareInfoList[selectIndex + 1]
            -- 创建英雄头像
            if not self.guildShareHeader or tolua.isnull(self.guildShareHeader) then
                self.guildShareHeader = CardNode.createCardNode({
                    resourceTypeSub = ResourcetypeSub.eHero,
                    modelId = tonumber(shareInfo.ModelId),
                    IllusionModelId = shareInfo.IllusionModelId,
                    cardShowAttrs = {CardShowAttr.eBorder},
                    needGray = false,
                    onClickCallback = function ()end
                })
                self.guildShareHeader:setPosition(60 ,90)
                self.guildShareHeader:setAnchorPoint(cc.p(0,0.5))
                topSprite:addChild(self.guildShareHeader)
            else
                self.guildShareHeader:setCardData({
                        resourceTypeSub = ResourcetypeSub.eHero,
                        modelId = tonumber(shareInfo.ModelId),
                        IllusionModelId = shareInfo.IllusionModelId,
                        cardShowAttrs = {CardShowAttr.eBorder},
                        needGray = false,
                        onClickCallback = function ()end
                    })
            end
            
        end
    })
    sliderView:setAnchorPoint(0, 0)
    sliderView:setPosition(0, 0)
    sliderView:setSelectItemIndex(0)
    self.mSubLayer:addChild(sliderView)

    -- 左箭头
    local leftSprite = ui.newSprite("c_39.png")
    leftSprite:setPosition(cc.p(50, 450))
    self.mSubLayer:addChild(leftSprite)
    -- 右箭头
    local rightSprite = ui.newSprite("c_39.png")
    rightSprite:setPosition(cc.p(590, 450))
    rightSprite:setFlippedX(true)
    self.mSubLayer:addChild(rightSprite)

    --描述
    local decsLabel = ui.newLabel({
        text = TR("当前帮派已有%s%d%s名佣兵", Enums.Color.eOrangeH, #shareInfoList, "#46220D"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
    })
    decsLabel:setPosition(140, 865)
    self.mSubLayer:addChild(decsLabel)
end

-- 切换页面
function GuildHireLayer:changePage()
    if self.mPageTag == tabPageTags.eMyHire then
        self:createMyHireLayer()
    else
        self:createGuildHireLayer()
    end
end

-- =============================== 请求服务器数据相关函数 ===================

function GuildHireLayer:requesetGetGuildShare()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetGuildShare",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mGuildShareInfo = response.Value or {}

             Notification:postNotification(EventsName.eGuildHomeAll)
            -- 切换页面
            self:changePage()
        end,
    })
end

return GuildHireLayer