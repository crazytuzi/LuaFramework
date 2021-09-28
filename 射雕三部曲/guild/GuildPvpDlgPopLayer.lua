--[[
    文件名：GuildPvpDlgPopLayer.lua
    描述：人物详情查看页面
    创建人：chenzhong
    创建时间：2018.1.9
--]]
local GuildPvpDlgPopLayer = class("GuildPvpDlgPopLayer", function(params)
    return cc.Layer:create()
end)

-- 初始化函数
--[[
    params: 参数列表
    {
        isEnemy         -- 是否是敌人
        heroInfo        -- 当前人物信息
        guildId         -- 当前人物所处的帮派ID

        campCallBack    -- 查看布阵回调
    }
--]]
function GuildPvpDlgPopLayer:ctor(params)
    self.mIsEnemy = params.isEnemy
    self.mHeroInfo = params.heroInfo or {}
    self.mGuildId = params.guildId or EMPTY_ENTITY_ID
    self.mCampCallBack = params.campCallBack

    -- 创建原始界面
    self:initLayer()
end

-- 初始化界面
--[[
    无参数
--]]
function GuildPvpDlgPopLayer:initLayer()
    local popSprite = require("commonLayer.PopBgLayer").new({
        title = TR("详 情"),
        bgSize = cc.size(580, self.mIsEnemy and 660 or 594),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(popSprite)

    local bgSprite = popSprite.mBgSprite
    self.bgSize = bgSprite:getContentSize()
    self.bgSprite = bgSprite

    -- hero头像
    local heroBg = ui.newSprite("fb_32.png")
    heroBg:setAnchorPoint(0, 1)
    heroBg:setPosition(0, self.bgSize.height - 50)
    heroBg:setScale(0.9)
    bgSprite:addChild(heroBg)
    local heroBgSize = heroBg:getContentSize()
    local hero = Figure.newHero({
        heroModelID = self.mHeroInfo.HeadImageId,
        fashionModelID = self.mHeroInfo.FashionModelId or 0,
        position = cc.p(heroBgSize.width/2, 30),
        scale = 0.18,
        buttonAction = function()
        end,
    })
    heroBg:addChild(hero)

    -- 最佳挑战信息背景
    local py = self.mIsEnemy and 10 or 20
    local introBg = ui.newSprite("bpz_41.png")
    introBg:setPosition(self.bgSize.width/2, self.bgSize.height/2-py)
    bgSprite:addChild(introBg)
    self.mIntroBg = introBg

    -- 奖励背景框
    local cellSprite = ui.newScale9Sprite("c_17.png",cc.size(self.bgSize.width - 60, 200))
    cellSprite:setAnchorPoint(cc.p(0.5, 0))
    cellSprite:setPosition(self.bgSize.width * 0.5, 25)
    self.bgSprite:addChild(cellSprite)
    local listSprite = ui.newScale9Sprite("c_54.png", cc.size(self.bgSize.width - 70, 190))
    listSprite:setAnchorPoint(cc.p(0.5, 0))
    listSprite:setPosition(self.bgSize.width * 0.5, 28)
    self.bgSprite:addChild(listSprite)
    self.mListSprite = listSprite

    -- 刷新Layer
    self:refreshLayer()

    -- 获取战报信息
    self:getBattleInfo()
end

-- 刷新界面
function GuildPvpDlgPopLayer:refreshLayer()
    -- 显示玩家名
    local nameLabel = ui.newLabel({
        text = self.mHeroInfo.Name, 
        color = cc.c3b(0xff, 0x66, 0xf3), 
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        size = 24, 
        x = 420, 
        y = self.bgSize.height - 100, 
    })
    self.bgSprite:addChild(nameLabel)
    local fapLabel = ui.newLabel({
        text = TR("战力: #d17b00%s",Utility.numberFapWithUnit(self.mHeroInfo.FAP)), 
        color = cc.c3b(0x46, 0x22, 0x0d), 
        size = 22, 
        x = 420, 
        y = self.bgSize.height - 140, 
    })
    self.bgSprite:addChild(fapLabel)

    local fightImage = ""
    local closeFun = nil
    if self.mIsEnemy then 
        -- 星星变为3表示已经失去了全部星星，只能切磋
        fightImage = self.mHeroInfo.Star < 3 and  "bpz_19.png" or "bpz_40.png" 
        closeFun = function ( ... )
            self:challengeFight()
        end
    else 
        -- 自己人只显示布阵按钮
        fightImage = "tb_11.png"
        closeFun = function ( ... )
            print("布阵！！！")
            if self.mCampCallBack then 
                self.mCampCallBack()
            end     
        end
    end 
    local fightBtn = ui.newButton({
        normalImage = fightImage,
        position = cc.p(420, self.bgSize.height-210),
        clickAction = closeFun
    })
    self.bgSprite:addChild(fightBtn)
end

-- 查看战报或者奖励
function GuildPvpDlgPopLayer:createRewardInfo()
    self.mListSprite:removeAllChildren()
    --单项名
    local itemNameLabel = ui.newLabel({
        text = self.mIsEnemy and TR("三星奖励") or TR("%s的挑战记录", self.mHeroInfo.Name),
        outlineColor = cc.c3b(0x83, 0x49, 0x38),
        outlineSize = 2,
        size = 26,
        x = (self.bgSize.width - 70)/2,
        y = 185,
    })
    itemNameLabel:setAnchorPoint(cc.p(0.5, 1))
    self.mListSprite:addChild(itemNameLabel) 

    -- 敌方显示奖励
    if self.mIsEnemy then 
        -- 计算满星积分（代表奖励的数量）
        local sorce = 3*(51-self.mHeroInfo.Order)*2
        local rewardInfo = GuildbattleConfig.items[1].baseResource
        local tempList = Utility.analysisStrResList(rewardInfo)
        -- 奖励数量更新为满星数量
        for i,v in ipairs(tempList) do
            if v.num ~= nil then 
                v.num = sorce
            end     
        end
        if #tempList == 0 then
            local notLabel = ui.newLabel({
                text = TR("暂无战利品"),
                font = _FONT_PANGWA,
                size = 28,
                color = cc.c3b(0x46, 0x22, 0x0d), 
                x = (self.bgSize.width - 70)/2,
                y = 85,
                align = ui.TEXT_ALIGN_CENTER
            })
            self.mListSprite:addChild(notLabel)
            return
        end
        -- 创建物品列表
        for _, rewardItem in pairs(tempList) do
            rewardItem.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
        end
        local cardList = ui.createCardList({
            cardDataList = tempList,
            maxViewWidth = 400,
            allowClick = true,
        })
        cardList:setAnchorPoint(cc.p(0.5, 0.5))
        cardList:setPosition((self.bgSize.width - 70)/2, 75)
        self.mListSprite:addChild(cardList)

        -- 展示积分
        local sorceLabel = ui.newLabel({
            text = TR("三星胜利获得帮派积分:%s", sorce),
            font = _FONT_PANGWA,
            size = 24,
            color = cc.c3b(0x46, 0x22, 0x0d), 
            x = 10,
            y = 225,
            align = ui.TEXT_ALIGN_CENTER
        })
        sorceLabel:setAnchorPoint(0, 0.5)
        self.mListSprite:addChild(sorceLabel)
    else 
        -- 我方显示出战记录
        if #self.mBattleInfo.AttackInfo == 0 then
            local notLabel = ui.newLabel({
                text = TR("暂无战报信息"),
                font = _FONT_PANGWA,
                size = 28,
                color = cc.c3b(0x46, 0x22, 0x0d), 
                x = (self.bgSize.width - 70)/2,
                y = 85,
                align = ui.TEXT_ALIGN_CENTER
            })
            self.mListSprite:addChild(notLabel)
            return
        end

        local listViewSize = cc.size(self.bgSize.width - 70, 140)
        local listView = ccui.ListView:create()
        listView:setContentSize(listViewSize)
        listView:setPosition(listViewSize.width * 0.5, 5)
        listView:setAnchorPoint(cc.p(0.5, 0))
        listView:setDirection(ccui.ListViewDirection.vertical)
        self.mListSprite:addChild(listView)

        for i, v in ipairs(self.mBattleInfo.AttackInfo) do
            local cellSize = cc.size(self.bgSize.width - 70, 60)
            local cellSprite = ccui.Layout:create()
            cellSprite:setContentSize(cellSize)
            listView:pushBackCustomItem(cellSprite)

            local px = 20
            local reportLabel = ui.newLabel({
                text = TR("第%s次挑战: %s", i, v.DefenderName),
                color = cc.c3b(0x46, 0x22, 0x0d), 
                size = 22,
                x = px,
                y = cellSize.height/2,
                font = _FONT_PANGWA,
                align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.TEXT_ALIGNMENT_CENTER,
            })
            reportLabel:setAnchorPoint(cc.p(0, 0.5))
            cellSprite:addChild(reportLabel)

            -- 显示队友的回放
            local btnReport = ui.newButton({
                normalImage = "bpz_18.png",
                position = cc.p(cellSize.width - 58, cellSize.height/2),
                clickAction = function ()
                    self:replayBattle(i)
                end,
            })
            btnReport:setScale(0.75)
            cellSprite:addChild(btnReport)

            local staNum = v.GetStar or 0
            for i=1, 3 do
                local starImage = staNum >= i and "c_75.png" or "c_102.png"
                local starSprite = ui.newSprite(starImage)
                starSprite:setAnchorPoint(0, 0.5)
                starSprite:setPosition(px+reportLabel:getContentSize().width + 10 + (i-1)*35, cellSize.height/2)
                cellSprite:addChild(starSprite)
            end 
        end        
    end 
end

-- 刷新最佳挑战
function GuildPvpDlgPopLayer:refreshBestBattle()
    self.mIntroBg:removeAllChildren()
    local introSize = self.mIntroBg:getContentSize()
    if not next(self.mBattleInfo.DefendInfo) then 
        local introLabel = ui.newLabel({
            text = TR("无"), 
            color = cc.c3b(0x46, 0x22, 0x0d), 
            size = 28, 
            x = 250, 
            y = introSize.height/2, 
        })
        introLabel:setAnchorPoint(0, 0.5)
        self.mIntroBg:addChild(introLabel)
        return
    end
    local px = 120
    local introLabel = ui.newLabel({
        text = self.mBattleInfo.DefendInfo.AttackerName, 
        color = cc.c3b(0x46, 0x22, 0x0d), 
        size = 22, 
        x = px, 
        y = introSize.height/2, 
    })
    introLabel:setAnchorPoint(0, 0.5)
    self.mIntroBg:addChild(introLabel)

    -- 获得星星
    local staNum = self.mBattleInfo.DefendInfo.GetStar or 0
    for i=1, 3 do
        local starImage = staNum >= i and "c_75.png" or "c_102.png"
        local starSprite = ui.newSprite(starImage)
        starSprite:setAnchorPoint(0, 0.5)
        starSprite:setPosition(px+introLabel:getContentSize().width + 10 + (i-1)*35, introSize.height/2+2)
        self.mIntroBg:addChild(starSprite)
    end  

    --添加最佳战斗回放按钮   
    local againBtn = ui.newButton({
        normalImage = "bpz_18.png",
        position = cc.p(480, introSize.height/2),
        clickAction = function ()
            self:replayBattle(0)
        end
    })
    self.mIntroBg:addChild(againBtn)
end

-- 获取当前玩家的战报信息
function GuildPvpDlgPopLayer:getBattleInfo()
    HttpClient:request({
        moduleName = "GuildbattleInfo",
        methodName = "GetBattleReport",
        callbackNode = self,
        svrMethodData = {self.mGuildId, self.mHeroInfo.Id, self.mIsEnemy and 0 or 1},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --dump(response, "response")
            self.mBattleInfo = response.Value
            -- 显示战报或者奖励
            self:createRewardInfo()
            -- 刷新最佳挑战
            self:refreshBestBattle()
        end,
    })
end

--添加回放功能
--[[
    type: 0表示最佳回放 大于1表示己方的挑战Index
]]
function GuildPvpDlgPopLayer:replayBattle(type)
    -- 战斗页面控制信息
    local controlParams = Utility.getBattleControl(ModuleSub.eGuildBattle)
    -- 战斗详细信息
    local battelInfo = type == 0 and self.mBattleInfo.DefendInfo or self.mBattleInfo.AttackInfo[type]
    --dump(battelInfo.GetStar,"battelInfo.GetStar")
    -- 调用战斗页面
    LayerManager.addLayer({
        name = "ComBattle.BattleLayer",
        data = {
            data = cjson.decode(battelInfo.FightInfo),
            skip = controlParams.skip,
            trustee = controlParams.trustee,
            skill = controlParams.skill,
            map = Utility.getBattleBgFile(ModuleSub.eGuildBattle),
            callback = function(retData)
                PvpResult.showPvpResultLayer(
                    ModuleSub.eGuildBattle,
                    cjson.decode(battelInfo.FightInfo),
                    {
                        PlayerName = battelInfo.AttackerName or "",
                        FAP = battelInfo.AttackerFAP or 0,
                        GetStar = battelInfo.GetStar or 0,  
                    },
                    {
                        PlayerName = battelInfo.DefenderName or "",
                        FAP = battelInfo.DefenderFAP or 0,
                    }
                )

                if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                    controlParams.trustee.changeTrusteeState(retData.trustee)
                end
            end
        },
    })
end

-- 挑战或者切磋
function GuildPvpDlgPopLayer:challengeFight()
    -- 策划说次数什么都不用判断 直接跳转到战斗前阵容查看界面
    self.mHeroInfo.challengeType = self.mHeroInfo.Star < 3 and 1 or 0
    LayerManager.addLayer({
        name = "guild.GuildPvpFormationLayer",
        data = self.mHeroInfo,
        cleanUp = true,
    })
end

return GuildPvpDlgPopLayer