--[[
    文件名：PlayerInfoLayer.lua
    描述： 个人信息
    创建人：  wusonglin
    创建时间：2016.6.21
-- ]]

local PlayerInfoLayer = class("PlayerInfoLayer", function(params)
    return cc.LayerColor:create()
end)

-- 初始化
function PlayerInfoLayer:ctor(params)
    -- 存放中间的头像
    self.mCenterHeader = {}
    
    -- 设置ui
    self:setUI()
end

-- 设置ui
function PlayerInfoLayer:setUI()
    -- 设置背景大小
    local bgWidth = 590
    local bgHeight = 922

    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("个人信息"),
        bgSize = cc.size(bgWidth, bgHeight),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    self.mBgSprite = bgLayer.mBgSprite

    -- 显示人物头像
    self.infoStartX = 152
    self:setPlayerHeader(PlayerAttrObj:getPlayerInfo().HeadImageId)

    -- 显示玩家名字
    self:getNameVIPString()

    -- 战力
    local fapLabel = ui.newLabel({
        text = TR("战力: #d17b00%s", Utility.numberFapWithUnit(PlayerAttrObj:getPlayerInfo().FAP)),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    fapLabel:setPosition(cc.p(self.infoStartX, bgHeight - 135.5))
    fapLabel:setAnchorPoint(cc.p(0, 1))
    self.mBgSprite:addChild(fapLabel)
    --添加战斗力更新
    Notification:registerAutoObserver(fapLabel, function ()
        fapLabel:setString(TR("战力: #d17b00%s", Utility.numberFapWithUnit(PlayerAttrObj:getPlayerInfo().FAP)))
    end, {EventsName.eFAP})

    -- 玩家等级背景
    local lvLabel = ui.newLabel({
        text = TR("等级: #d17b00%s", PlayerAttrObj:getPlayerInfo().Lv),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    lvLabel:setPosition(cc.p(self.infoStartX, bgHeight - 159))
    lvLabel:setAnchorPoint(cc.p(0, 1))
    self.mBgSprite:addChild(lvLabel)
    --添加战斗力更新
    Notification:registerAutoObserver(lvLabel, function ()
        lvLabel:setString(TR("等级: #d17b00%s", PlayerAttrObj:getPlayerInfo().Lv))
    end, {EventsName.eLv})

    -- 经验进度条
    local expProgBar = require("common.ProgressBar"):create({
        bgImage = "sy_28.png",
        barImage = "sy_29.png",
    })
    expProgBar:setAnchorPoint(cc.p(0, 1))
    expProgBar:setPosition(self.infoStartX + 89, bgHeight - 160)
    self.mBgSprite:addChild(expProgBar)
    -- 经验值
    local expLabel = ui.newLabel({
        text = string.format("%d/%d", 0, 0),
        color = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBlack,
        size = 16,
    })
    expLabel:setAnchorPoint(cc.p(0.5, 0.5))
    expLabel:setPosition(expProgBar:getContentSize().width*0.5, expProgBar:getContentSize().height*0.5)
    expProgBar:addChild(expLabel)
    -- 注册玩家经验和等级改变后，经验进度条改变的事件
    local function setExpProgress(progBar)
        local player = PlayerAttrObj:getPlayerInfo()
        local currLvExpTotal, nextLvExpTotal = 0, 100
        if player.Lv <= PlayerLvRelation.items_count and player.Lv > 0 then
            if player.Lv > 0 then
                currLvExpTotal = PlayerLvRelation.items[player.Lv].EXPTotal
            end
            if PlayerLvRelation.items[player.Lv + 1] then
                nextLvExpTotal = PlayerLvRelation.items[player.Lv + 1].EXPTotal
            end
        end
        local maxValue = nextLvExpTotal - currLvExpTotal
        local curValue = player.EXP - currLvExpTotal
        progBar:setMaxValue(maxValue)
        progBar:setCurrValue(curValue)
        expLabel:setString(TR("%s/%s", Utility.numberWithUnit(curValue), Utility.numberWithUnit(maxValue)))
    end
    setExpProgress(expProgBar)
    Notification:registerAutoObserver(expProgBar, setExpProgress, {EventsName.eEXP, EventsName.eLv})

    -- 称号
    local designPicBtn = ui.newButton({
        normalImage = "ch_03.png",
        clickAction = function()
            LayerManager.addLayer({name = "home.DesignationBagLayer",})
        end,
    })
    designPicBtn:setPosition(470, 820)
    self.mBgSprite:addChild(designPicBtn)

    -- 更名
    local exchangeNameBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("更名"),
        clickAction = function()
            LayerManager.addLayer({
                name    = "more.ModifyNameLayer",
                data    = {},
                cleanUp = false
            })
        end,
    })
    exchangeNameBtn:setPosition(470, 760)
    self.mBgSprite:addChild(exchangeNameBtn)

    -- 显示下方的头像
    self:showCenterHeader()
    -- dump(PlayerAttrObj:getPlayerInfo(),"AAAAAA")

    -- 显示资源数量
    self:showAttrInfo()

    -- 更换头像
    local exchangeHeadBtn = ui.newButton({
        normalImage = "c_28.png",
        size = 24,
        text = TR("更换头像"),
        outlineColor = cc.c3b(0x8e, 0xf4f, 0x09),
        outlineSize = 2,
        clickAction = function()
            if not self.mHeroId then return end

            if (self.mHeroId == PlayerAttrObj:getPlayerInfo().HeadImageId and not (self.mIllusionModelId > 0)) 
                or self.mIllusionModelId == PlayerAttrObj:getPlayerInfo().HeadImageId then
                ui.showFlashView(TR("当前选择头像在使用中"))
                return
            end

            self:requestAlterPlayerHeadId(self.mHeroId)
        end,
    })
    exchangeHeadBtn:setAnchorPoint(cc.p(0.5, 0))
    exchangeHeadBtn:setPosition(cc.p(bgWidth / 2, 30))
    self.mBgSprite:addChild(exchangeHeadBtn)
end

-- 创建玩家头像
function PlayerInfoLayer:setPlayerHeader(heroModelId)
    if self.mPlayHead == nil then
        self.mPlayHead = CardNode:create()
        self.mPlayHead:setAnchorPoint(cc.p(0, 1.0))
        self.mPlayHead:setPosition(40, self.mBgSprite:getContentSize().height - 80)
        self.mBgSprite:addChild(self.mPlayHead)
    end

    local function getHeroCreateConfig()
        local headType = math.floor(heroModelId / 10000)
        local heroInfo = {
            FashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
            pvpInterLv = PlayerAttrObj:getPlayerInfo().DesignationId,
        }
        heroInfo.ModelId = heroModelId
        if Utility.isIllusion(headType) then 
            heroInfo.IllusionModelId = heroModelId
        end 

        return heroInfo
    end

    local function setPlayerHeader( ... )
        local headType = math.floor(heroModelId / 10000)
        self.mPlayHead:setHero(getHeroCreateConfig(), {CardShowAttr.eBorder})
    end
    setPlayerHeader()
end

-- 显示vip名称
function PlayerInfoLayer:getNameVIPString()
    local bgHeight = self.mBgSprite:getContentSize().height
    local forcePic = Enums.JHKSamllPic[PlayerAttrObj:getPlayerInfo().JianghuKillForceId]
    self.mPlayerName = ui.newLabel({
        text = (forcePic and "{"..forcePic.."}" or "")..PlayerAttrObj:getPlayerInfo().PlayerName,
        color = cc.c3b(0xff, 0xed, 0xc5),
        outlineColor = cc.c3b(0x34, 0x1f, 0x00),
        outlineSize = 2,
        size = 22
    })
    self.mPlayerName:setAnchorPoint(cc.p(0.0, 1.0))
    self.mPlayerName:setPosition(cc.p(self.infoStartX, bgHeight - 79))
    self.mBgSprite:addChild(self.mPlayerName)
    --玩家名更新
    Notification:registerAutoObserver(self.mPlayerName, function()
        self.mPlayerName:setString(PlayerAttrObj:getPlayerInfo().PlayerName)
    end, {EventsName.ePlayerName})

    -- 显示所在服务器
    local ownServer = ui.newLabel({
        text = Player:getSelectServer().ServerName,
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
    })
    ownServer:setAnchorPoint(cc.p(0, 1.0))
    ownServer:setPosition(self.infoStartX, bgHeight - 112.5)
    self.mBgSprite:addChild(ownServer)

    -- 玩家VIP等级
    local vipStartPosX, vipStartPosY = self.mPlayerName:getContentSize().width + 152 + 5, bgHeight - 79
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eVIP) then
        local vipNode = ui.createVipNode(PlayerAttrObj:getPlayerInfo().Vip)
        vipNode:setPosition(vipStartPosX, vipStartPosY)
        vipNode:setAnchorPoint(cc.p(0, 1))
        self.mBgSprite:addChild(vipNode)
        -- vip自动更新
        Notification:registerAutoObserver(vipNode.vipLabel, function()
            -- 玩家名变化需要修改vip的位置
            local vipStartPosX, vipStartPosY = self.mPlayerName:getContentSize().width + 152 + 5, bgHeight - 79
            vipNode:setPosition(vipStartPosX, vipStartPosY)
            vipNode.vipLabel:setString(tostring(PlayerAttrObj:getPlayerInfo().Vip))
        end, {EventsName.eVip, EventsName.ePlayerName})
    end
end

-- 显示资源数量
function PlayerInfoLayer:showAttrInfo()
    if self.attrBgSprite then
        self.attrBgSprite:removeFromParent()
        self.attrBgSprite = nil
    end
    local attrInfo = PlayerAttrObj:getPlayerInfo()
    local attrBgWidth, attrBgHeight  = 520, 328
    local bgBackWith, bgBackHeight = 500, 150
    local attrBgSprite = ui.newScale9Sprite("c_17.png", cc.size(attrBgWidth, attrBgHeight))
    attrBgSprite:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2 ,566))
    self.mBgSprite:addChild(attrBgSprite)
    self.attrBgSprite = attrBgSprite

    local blockBg = {}
    -- 添加两个背景
    for i=1,2 do
        local backSprite = ui.newScale9Sprite("c_18.png", cc.size(bgBackWith, bgBackHeight))
        backSprite:setPosition(cc.p(attrBgWidth / 2 ,243 - (i-1)*(9 + 150)))
        attrBgSprite:addChild(backSprite)
        blockBg[i] = backSprite
    end

    -- 体力和气力
    for index1, typeSub in ipairs({ResourcetypeSub.eVIT,ResourcetypeSub.eSTA}) do
        local tempNode = ui.createResCount(typeSub)
        tempNode:setScale(0.85)
        tempNode:setPosition(45, bgBackHeight*3/4 - (index1 - 1)*(bgBackHeight/2))
        tempNode:setAnchorPoint(cc.p(0, 0.5))
        tempNode.Label:setColor(cc.c3b(0x46, 0x22, 0x0d))
        blockBg[1]:addChild(tempNode)

        -- 时间显示
        local timeBg = ui.newScale9Sprite("c_24.png", cc.size(318, 60))
        timeBg:setPosition(cc.p(170 ,bgBackHeight*3/4 - (index1 - 1)*(bgBackHeight/2 - 6) - 3))
        timeBg:setAnchorPoint(0, 0.5)
        blockBg[1]:addChild(timeBg)

        for i=1, 2 do
            local timeLabel = ui.newLabel({
                text = "",
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 18,
                x = 10,
                y = 45 - (i-1)*30
            })
            timeLabel:setAnchorPoint(0, 0.5)
            timeBg:addChild(timeLabel)

            -- local scheduleAction = nil
            local timeParams = nil
            timeParams = {
                label = timeLabel,
                typeSub = typeSub,
                index = i,      -- 1代表下一点体力恢复时间  2代表全部恢复时间
                -- scheduleAction = scheduleAction
            }
            -- scheduleAction = Utility.schedule(self, function()
            self:updateTime(timeParams)
            -- end, 1.0)
        end
    end

    -- 玩家资源
    local subList = {
        [1] = ResourcetypeSub.eHeroCoin,
        [2] = ResourcetypeSub.eHeroExp,
        [3] = ResourcetypeSub.eGold,
        [4] = ResourcetypeSub.eDiamond,
    }
    for index=1, 4 do
        local resourcetypeSub = subList[index]
        local with = 35+(1-(index%2))*242
        local height = 27+math.floor((index-1)/2)*57
        local resourcesBg = ui.newScale9Sprite("c_24.png", cc.size(202, 40))
        resourcesBg:setPosition(cc.p(with, height))
        resourcesBg:setAnchorPoint(0, 0)
        blockBg[2]:addChild(resourcesBg)

        -- 添加数量和图标
        local tempStr = Utility.getDaibiImage(resourcetypeSub, modelId)
        tempSprite = ui.newSprite(tempStr)
        tempSprite:setPosition(10, 20)
        resourcesBg:addChild(tempSprite)
        local tempLabel = ui.newLabel({
            text = PlayerAttrObj:getPlayerAttr(resourcetypeSub),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        tempLabel:setPosition(40, 20)
        tempLabel:setAnchorPoint(0, 0.5)
        resourcesBg:addChild(tempLabel)
    end

    --经验加成
    local expAdd = PlayerAttrObj:getPlayerAttrByName("ExpAddR")
    local expAddRSprite = ui.newSprite("c_174.png")
    expAddRSprite:setPosition(self.mBgSprite:getContentSize().width / 2 , 350)
    self.mBgSprite:addChild(expAddRSprite)

    if expAdd > 0 then
        local expTipLabel = ui.newLabel({
            text = TR("由于当前世界等级较高，您可享受以下加成："),
            color = Enums.Color.eBlack,
            size = 20,
            })
        expTipLabel:setAnchorPoint(0, 0.5)
        expTipLabel:setPosition(100, 85)
        expAddRSprite:addChild(expTipLabel)

        local expAddLabel = ui.newLabel({
            text = TR("所有玩法经验#5d9137+%s%%", expAdd/100),
            color = Enums.Color.eBlack,
            size = 20,
            })
        expAddLabel:setAnchorPoint(0, 0.5)
        expAddLabel:setPosition(100, 60)
        expAddRSprite:addChild(expAddLabel)
    else
        local expTipLabel = ui.newLabel({
            text = TR("当前没有享受任何加成"),
            color = Enums.Color.eBlack,
            size = 20,
            })
        expTipLabel:setAnchorPoint(0, 0.5)
        expTipLabel:setPosition(100, 55)
        expAddRSprite:addChild(expTipLabel)
    end

end

-- 活动倒计时
function PlayerInfoLayer:updateTime(info)
    local attrInfo = PlayerAttrObj:getPlayerInfo()
    -- 得到结束时间
    local timeEnd = 0
    local string = nil
    if info.typeSub == ResourcetypeSub.eVIT then
        timeEnd = info.index == 1 and attrInfo.VITNextRecoverTime or attrInfo.VITMaxRecoverTime or 0
        string = info.index == 1 and TR("体力恢复时间:") or TR("体力全部恢复:")
    elseif info.typeSub == ResourcetypeSub.eSTA then
        timeEnd = info.index == 1 and attrInfo.STANextRecoverTime or attrInfo.STAMaxRecoverTime or 0
        string = info.index == 1 and TR("气力恢复时间:") or TR("气力全部恢复:")
    end

    -- 获取体力值，气力值上限
    local maxCount = 0
    local currentNUm = PlayerAttrObj:getPlayerAttr(info.typeSub)
    if ResourcetypeSub.eVIT == info.typeSub then  -- 体力
        maxCount = VitConfig.items[1].maxNum
    elseif ResourcetypeSub.eSTA == info.typeSub then  -- 气力
        maxCount = PlayerAttrObj:getPlayerAttrByName("STAMaxNum")
    end
    -- 获取当前体力值，气力值
    local currentNum = PlayerAttrObj:getPlayerAttr(info.typeSub)
    -- 当前体力值，气力值是否已满
    if maxCount <= currentNUm then
        local suffixText = info.index == 1 and "00:00:00" or TR("#5d9137已满")
        info.label:setString(string.format("%s%s", string, suffixText))
        -- 停止倒计时
        -- if info.scheduleAction then
        --     self:stopAction(info.scheduleAction)
        --     info.scheduleAction = nil
        -- end
    -- 当体力没有达到最大时 需要刷新时间
    else
        local strInto = info.index == 1 and TR("恢复1点") or TR("全部恢复")
        -- 获取时间差
        local timeLeft = timeEnd - Player:getCurrentTime()
        if timeLeft > 0 then
            info.label:setString(TR("%s预计%s分钟后%s", string, math.ceil(timeLeft/60), strInto))
        end
    end
end

-- 显示下方可选择的头像
function PlayerInfoLayer:showCenterHeader()
    -- body
    local dataFormation = FormationObj:getSlotInfos()
    local headBgWidth  = 500
    local headBgHeight = 240

    local headBgSprite = ui.newScale9Sprite("c_83.png", cc.size(headBgWidth, headBgHeight))
    headBgSprite:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2 ,190))
    self.mBgSprite:addChild(headBgSprite)

    -- 遍历阵容
    for i,v in ipairs(dataFormation) do
        if v.ModelId ~= nil and v.ModelId > 0 then
            local heroIllusionModeId = HeroObj:getHero(v.HeroId).IllusionModelId
            self.mCenterHeader[i] = CardNode.createCardNode({
                resourceTypeSub = heroIllusionModeId ~= 0 and ResourcetypeSub.eIllusion or ResourcetypeSub.eHero,
                modelId = heroIllusionModeId ~= 0 and heroIllusionModeId or v.ModelId,
                fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
                allowClick = true,
                cardShowAttrs = {
                   CardShowAttr.eBorder,
                },
                onClickCallback = function ()
                    self.mHeroId = v.ModelId
                    -- 当前幻化
                    self.mIllusionModelId = heroIllusionModeId

                    for m, n in ipairs(self.mCenterHeader) do
                        -- 点击到某个头像设置为选中状态，其余的去除选中状态
                        -- 每次点击都重新设置CardNode的值，此方法较low。CardNode没有暴露更好的接口
                        local tmpData = dataFormation[m]
                        local tmpIllusionModelId = HeroObj:getHero(tmpData.HeroId).IllusionModelId
                        if m == i then
                            n:setCardData({
                                resourceTypeSub = tmpIllusionModelId ~= 0 and ResourcetypeSub.eIllusion or ResourcetypeSub.eHero,
                                modelId = tmpIllusionModelId ~= 0 and tmpIllusionModelId or tmpData.ModelId,
                                fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
                                allowClick = true,
                                cardShowAttrs = {
                                  CardShowAttr.eBorder,
                                  CardShowAttr.eSelected,
                                },

                            })
                        else
                            n:setCardData({
                                resourceTypeSub = tmpIllusionModelId ~= 0 and ResourcetypeSub.eIllusion or ResourcetypeSub.eHero,
                                modelId = tmpIllusionModelId ~= 0 and tmpIllusionModelId or tmpData.ModelId,
                                fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
                                allowClick = true,
                                cardShowAttrs = {
                                    CardShowAttr.eBorder,
                                },
                            })

                        end
                    end
                end
            })

            if PlayerAttrObj:getPlayerInfo().HeadImageId == v.ModelId then
                self.mHeroId = v.ModelId
                -- 当前幻化
                self.mIllusionModelId = heroIllusionModeId

                self.mCenterHeader[i]:setSelectedImg()
            end
            -- 计算坐标
            local indexW = i > 3 and i - 3 or i
            local indexH = i > 3 and 1 or 2
            local nodeWidth  = self.mCenterHeader[i]:getContentSize().width
            local nodeHeight = self.mCenterHeader[i]:getContentSize().height
            local detalW = (headBgWidth  - nodeWidth  * 3) / 4
            local detalH = (headBgHeight - nodeHeight * 2) / 3
            local posX = detalW * indexW + (indexW - 1) * nodeWidth
            local posY = detalH * indexH + indexH * nodeHeight
            self.mCenterHeader[i]:setAnchorPoint(cc.p(0, 1.0))
            self.mCenterHeader[i]:setPosition(cc.p(posX, posY))
            headBgSprite:addChild(self.mCenterHeader[i])
        end
    end
end

----------[[-------网络相关-----]]---------
-- 更换头像
function PlayerInfoLayer:requestAlterPlayerHeadId(heroId)
    HttpClient:request({
       moduleName = "Player",
       methodName = "AlterPlayerHeadId",
       svrMethodData = {heroId},
       callback = function(data)
           self:setPlayerHeader(PlayerAttrObj:getPlayerInfo().HeadImageId)
           ui.showFlashView({
               text = TR("更换头像成功"),
           })
       end,
    })
end


return PlayerInfoLayer
