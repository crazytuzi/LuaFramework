--[[
    文件名: NormalNodePopLayer.lua
    描述: 普通副本关卡节点弹窗
    创建人: liaoyuangang
    创建时间: 2016-06-08 
--]]

local NormalNodePopLayer = class("NormalNodePopLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 140))
end)

--[[
	参数 params 中的各项为：
	{
        chapterModelId: 章节模型Id
        nodeModelId: 节点模型Id
		fightCallback: 单次挑战的回调接口 fightCallback(chapterModelId, nodeModelId, starLv)
	}
--]]
function NormalNodePopLayer:ctor(params)
    params = params or {}
    -- 章节模型Id
    self.mChapterModelId = params.chapterModelId
    -- 节点模型Id
    self.mNodeModelId = params.nodeModelId
    -- 单次挑战的回调接口
    self.fightCallback = params.fightCallback

    -- 节点缓存信息
    self.mNodeInfo = BattleObj:getNodeInfo(self.mChapterModelId, self.mNodeModelId)
    -- 节点模型数据
    self.mNodeModel = BattleNodeModel.items[self.mNodeModelId]
    -- 读取当前星级
    self.starLv = math.min(self.mNodeInfo.StarCount + 1, self.mNodeModel.starCount)

    -- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self,needTouchClose = true})

	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function NormalNodePopLayer:initUI()
    -- 背景图片
    self.mBgSize = cc.size(586, 628)
    self.mBgSprite = ui.newScale9Sprite("c_30.png", self.mBgSize)
    self.mBgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSprite)

    -- 显示弹出动画
    ui.showPopAction(self.mBgSprite)

    -- 人物背景光
    local heroBgSprite = ui.newSprite("fb_32.png")
    heroBgSprite:setAnchorPoint(cc.p(0.5, 0))
    heroBgSprite:setPosition(cc.p(135, 340))
    heroBgSprite:setScale(0.8)
    self.mBgSprite:addChild(heroBgSprite)

    -- 当前关卡人物形象
    local heroFigure = Figure.newHero({
        parent = self.mBgSprite, 
        heroModelID = tonumber(self.mNodeModel.pic),
        scale = 0.22,
        position = cc.p(135, 350), 
        needAction = true,
    })
    -- 关闭按钮
    local mCloseBtn = ui.newButton({
    	normalImage = "c_29.png",
    	clickAction = function()
    		LayerManager.removeLayer(self)
    	end,
    })
    mCloseBtn:setPosition(self.mBgSize.width - 35, self.mBgSize.height - 32)
    self.mBgSprite:addChild(mCloseBtn)

    -- 创建节点基本信息
    self:createBaseInfo()
    -- 创建掉落预览信息
    self:createDropInfo()
    -- 创建挑战操作信息
    self:createFightInfo()

    -- 显示布阵按钮
    local campBtn = ui.newButton({
        normalImage = "tb_11.png",
        clickAction = function()
            LayerManager.addLayer({name = "team.CampLayer", cleanUp = false,})
        end
    })
    campBtn:setPosition(self.mBgSize.width - 65, self.mBgSize.height - 270)
    campBtn:setScale(0.85)
    self.mBgSprite:addChild(campBtn)

    -- 加成
    local attrLabel = ConfigFunc:getMonthAddAttrStr(true)
    if attrLabel then
        attrLabel:setPosition(500, 480)
        self.mBgSprite:addChild(attrLabel)
    end
end

-- 创建节点基本信息
function NormalNodePopLayer:createBaseInfo()
    -- 显示名字
    local tempTitleLabel = ui.newLabel({
        text = TR("%s", self.mNodeModel.name),
        size = 28,
        color = cc.c3b(0xd1, 0x7b, 0x00),
    })
    tempTitleLabel:setAnchorPoint(cc.p(0, 0.5))
    tempTitleLabel:setPosition(294, 524)
    self.mBgSprite:addChild(tempTitleLabel)

    -- 显示难度星级
    local mStarNode = ui.newStarLevel(self.starLv, "c_105.png")
    mStarNode:setAnchorPoint(cc.p(0, 0.5))
    mStarNode:setPosition(240, 370)
    self.mBgSprite:addChild(mStarNode)

    -- 显示挑战次数
    local countLabel = ui.newLabel({
        text = "",
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    countLabel:setAnchorPoint(cc.p(0, 0.5))
    countLabel:setPosition(360, 430)
    self.mBgSprite:addChild(countLabel)
    -- 注册节点信息改变事件
    local function dealNodeInfoChange()
        local leftCount = self.mNodeModel.fightNumMax - self.mNodeInfo.FightCount
        countLabel:setString(TR("挑战次数:  %s%d/%d", "#258711", leftCount, self.mNodeModel.fightNumMax))
    end
    local eventName = EventsName.eBattleNodePrefix .. tostring(self.mNodeModelId)
    Notification:registerAutoObserver(countLabel, dealNodeInfoChange, {eventName})
    dealNodeInfoChange()

    -- 显示消耗体力
    local VITLabel = ui.newLabel({
        size = 22,
        text = TR("消耗体力:  %s%d", "#258711", 5),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    VITLabel:setAnchorPoint(cc.p(0, 0.5))
    VITLabel:setPosition(360, 400)
    self.mBgSprite:addChild(VITLabel)
end

-- 创建掉落预览信息
function NormalNodePopLayer:createDropInfo()
    local dropBgSize = cc.size(520, 176)
    local dropBgSprite = ui.newScale9Sprite("c_54.png", dropBgSize)
    dropBgSprite:setPosition(cc.p(self.mBgSize.width / 2, self.mBgSize.height - 400))
    self.mBgSprite:addChild(dropBgSprite)

    -- 显示标题
    local tempTitleLabel = ui.newLabel({
        text = TR("几率掉落"),
        size = 24,
        color = cc.c3b(0xfa, 0xf6, 0xf1),
        outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
        outlineSize = 2,
    })
    tempTitleLabel:setPosition(dropBgSize.width / 2, dropBgSize.height - 22)
    dropBgSprite:addChild(tempTitleLabel)

    -- 显示掉落列表
    local tempList = ConfigFunc:getBattleNodeDrop(self.mNodeModelId)
    local propsList = {}
    for _, item in pairs(tempList) do   -- 去掉重复的
        local tempKey = item.modelId ~= 0 and item.modelId or item.resourceTypeSub
        propsList[tempKey] = item
    end
    -- 整理需要显示卡牌的数据
    local viewDataList = {}
    for _, item in pairs(propsList) do
        item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
        table.insert(viewDataList, item)
    end
    table.sort(viewDataList, function(item1, item2)
        local colorLv1 = Utility.getColorLvByModelId(item1.modelId, item1.resourceTypeSub)
        local colorLv2 = Utility.getColorLvByModelId(item2.modelId, item2.resourceTypeSub)
        if colorLv1 ~= colorLv2 then
            return colorLv1 > colorLv2
        end
        return (item1.modelId or 0) > (item2.modelId or 0)
    end)    
    local cardListNode = ui.createCardList({
        maxViewWidth = dropBgSize.width * 0.9, 
        space = -10, 
        cardDataList = viewDataList,
        cardShape = Enums.CardShape.eCircle, 
        allowClick = true, 
        needArrows = true
    })
    cardListNode:setAnchorPoint(cc.p(0.5, 0.5))
    cardListNode:setPosition(dropBgSize.width / 2, 70)
    dropBgSprite:addChild(cardListNode)
end

-- 创建挑战操作信息
function NormalNodePopLayer:createFightInfo()
    -- 显示难度图标
    local lvIcons = {"c_86.png", "c_87.png", "c_89.png", "c_90.png"}
    local tempSprite = ui.newSprite(lvIcons[self.starLv] or "c_86.png")
    tempSprite:setAnchorPoint(cc.p(1, 0.5))
    tempSprite:setPosition(330, 450)
    self.mBgSprite:addChild(tempSprite)

    -- 显示掉落的铜钱
    local function showDropItem(dropType, dropNum, yPos)
        local fightBgSprite = ui.newScale9Sprite("c_24.png", cc.size(114, 38))
        fightBgSprite:setAnchorPoint(cc.p(0, 0.5))
        fightBgSprite:setPosition(cc.p(80, yPos))
        self.mBgSprite:addChild(fightBgSprite)

        local fightDaibi = ui.createDaibiView({
            resourceTypeSub = dropType,
            number = dropNum,
            fontColor = cc.c3b(0x46, 0x22, 0x0d),
        })
        fightDaibi:setAnchorPoint(cc.p(0, 0.5))
        fightDaibi:setPosition(cc.p(80, yPos))
        self.mBgSprite:addChild(fightDaibi)
    end
    showDropItem(ResourcetypeSub.eGold, self.mNodeModel.dropGold, 105)
    showDropItem(ResourcetypeSub.eHeroExp, self.mNodeModel.dropHeroExp, 55)

    -- 显示扫荡按钮
    local sweepBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("扫荡"),
        clickAction = function()
            if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleForTen, true) then
                return
            end

            -- x星才可扫荡
            if self.mNodeInfo.StarCount < self.mNodeModel.starCount then
                ui.showFlashView(TR("达成%d壶酒条件后开启扫荡！", self.mNodeModel.starCount))
                return
            end

            -- 判断挑战次数是否足够
            if not self:checkFightCount() then
                return
            end

            MsgBoxLayer.conFightCountLayer(self.mNodeModel.ID, function(fightCount)
                -- 体力是否足够
                -- local conFightCount = math.min(self.mNodeModel.fightNumMax - self.mNodeInfo.FightCount, 10)
                if not Utility.isResourceEnough(ResourcetypeSub.eVIT, VitConfig.items[1].perUseNum * fightCount, true) then
                    return
                end

                -- 判断背包是否已满
                if not Utility.checkBagSpace(nil, true) then
                    return
                end

                -- 剩余可以挑战次数
                self:requestConFight(fightCount, 3)
            end)

            
        end,
    })
    sweepBtn:setPosition(300, 80)
    self.mBgSprite:addChild(sweepBtn)

    -- 显示出战按钮
     local fightBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("挑战"),
        clickAction = function()
            -- 判断挑战次数是否足够
            if not self:checkFightCount() then
                return
            end

            -- 判断体力是否足够
            if not Utility.isResourceEnough(ResourcetypeSub.eVIT, VitConfig.items[1].perUseNum, true) then
                return
            end

            -- 判断背包是否已满
            if not Utility.checkBagSpace(nil, true) then
                return 
            end

            if self.fightCallback then
                self.fightCallback(self.mChapterModelId, self.mNodeModelId, self.starLv)
            end
        end,
    })
    fightBtn:setPosition(470, 80)
    self.mBgSprite:addChild(fightBtn)
end

-- 判断挑战次数是否足够
function NormalNodePopLayer:checkFightCount()
    if self.mNodeInfo.FightCount < self.mNodeModel.fightNumMax then
        return true
    end

    MsgBoxLayer.resetNodeHintLayer(self.mNodeInfo.ResetFightCount, function(fightUse)
        self:requestResetCount(fightUse)
    end)
end

-- ============================== 网络请求相关函数 (需要调用 CacheBattle 中相关的函数)============================

-- 重置节点挑战次数数据请求
--[[
-- 参数
    useType: 消耗资源类型，在Enums.BattleFightUse 中定义 2(道具)，3(元宝)
]]
function NormalNodePopLayer:requestResetCount(useType)
    BattleObj:requestResetCount(self.mChapterModelId, self.mNodeModelId, useType, function(response)
        if not response or response.Status ~= 0 then 
            return
        end
    end)
end

-- 连战节点数据请求
function NormalNodePopLayer:requestConFight(conCount, useType)
    local starLv = math.min(self.mNodeInfo.StarCount + 1, self.mNodeModel.starCount)
    BattleObj:requestConFight(self.mChapterModelId, self.mNodeModelId, starLv, conCount, useType, function(response)
        if not response or response.Status ~= 0 then 
            return
        end

        -- 展示扫荡结果
        LayerManager.addLayer({
            name = "battle.ConFightResultLayer",
            data = {
                dropBaseInfo = response.Value.BaseGetGameResourceList
            },
            cleanUp = false,
        })
        -- 升级检查放到了扫荡结果展示页面后
    end)
end

return NormalNodePopLayer