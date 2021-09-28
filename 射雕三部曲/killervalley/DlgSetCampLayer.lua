--[[
    文件名：DlgSetCampLayer.lua
    描述：绝情谷的布阵界面
    创建人：peiyaoqiang
    创建时间：2018.1.25
--]]

local DlgSetCampLayer = class("DlgSetCampLayer", function(params)
    return display.newLayer()
end)

-- 控件大小与位置等显示相关变量
local HeroWidth, HeroHeight = 256, 122

--[[
params = {
    playerId            玩家Id，如果不传，默认为玩家自己
}
--]]
function DlgSetCampLayer:ctor(params)
    -- 读取参数
    self.mPlayerId = params.playerId or PlayerAttrObj:getPlayerAttrByName("PlayerId")
    self.mPlayerData = KillerValleyHelper:getPlayerData(self.mPlayerId)
    self.mIsSelf = (self.mPlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId"))
    
    -- 预定义量
    self.mFormationData = {}
    self.OwnHeroesCount = 7    -- 角色栏位数量
    self.layoutSize = cc.size(560, 540)
    self.layoutPos = cc.p(310, 365)
    
    -- 计算所有人物位置的列表（竖排出手顺序）
    local bgHeight = 570
    self.mPosList = {
        cc.p(417, 466), cc.p(417, 336), cc.p(417, 206), 
        cc.p(143, 466), cc.p(143, 336), cc.p(143, 206), 
    }
    if self.mIsSelf then
        -- 可以布阵
        table.insert(self.mPosList, cc.p(280, 76))
        bgHeight = 700
    else
        -- 查看布阵
        self.OwnHeroesCount = 6
        for i,v in ipairs(self.mPosList) do
            v.y = v.y - 130
        end
        self.layoutSize.height = self.layoutSize.height - 130
        self.layoutPos.y = self.layoutPos.y - 70
    end

    -- 按照出手顺序构造数据
    for i = 1, self.OwnHeroesCount do
        self.mFormationData[i] = self.mPlayerData.Formations[i] or 0
    end
    self.helpModelId = self.mFormationData[7]   -- 助阵侠客的模型ID

    -- 创建背景框
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = self.mIsSelf and TR("布阵") or TR("查看布阵"),
        bgSize = cc.size(620, bgHeight),
        closeImg = "c_29.png",
        closeAction = function()
            -- 如果捡到的助阵侠客不为空，且没有被换上，则需要执行布阵接口将其删除
            if (self.helpModelId ~= nil) and (self.helpModelId > 0) and (self.helpModelId == self.mItemData[7].data) then
                self:requestSetFormation()
            else
                LayerManager.removeLayer(self)
            end
        end
    })
    self:addChild(bgLayer)

    self.mBgLayer = bgLayer.mBgSprite
    self.mBgSize = self.mBgLayer:getContentSize()

    -- 初始化UI
    self:initUI()
end

-- 刷新显示
function DlgSetCampLayer:initUI()
    -- 半透明背景
    local heroBgSprite = ui.newScale9Sprite("c_17.png", self.layoutSize)
    heroBgSprite:setPosition(self.layoutPos)
    self.mBgLayer:addChild(heroBgSprite)

    -- 创建所有侠客
    self.mItemData = {}
    for i = 1, self.OwnHeroesCount do
        local layout = self:createEmptyLayout(i)
        heroBgSprite:addChild(layout)

        -- 显示内容
        self:addHeroInfoView(layout, i)
        self.mItemData[i] = {showIndex = i, pos = self.mPosList[i], nodeSprite = layout, data = self.mFormationData[i], hps = self.mPlayerData.HPs[i] or 0}
    end

    -- 自己才可拖动布阵
    if self.mIsSelf then
       ui.registerSwallowTouch({
            node = heroBgSprite,
            allowTouch = false,
            beganEvent = function(touch, event)
                local touchPos = heroBgSprite:convertTouchToNodeSpace(touch)
                self:onBeganEvent(touchPos.x, touchPos.y)
                return true
            end,
            movedEvent = function(touch, event)
                local touchPos = heroBgSprite:convertTouchToNodeSpace(touch)
                self:onMovedEvent(touchPos.x, touchPos.y)
            end,
            endedEvent = function(touch, event)
                local touchPos = heroBgSprite:convertTouchToNodeSpace(touch)
                self:onEndedEvent(touchPos.x, touchPos.y)
            end,
        })
    end

    -- 确定按钮
    local button = ui.newButton({
        normalImage = "c_28.png",
        text = self.mIsSelf and TR("保存并退出") or TR("确定"),
        size = cc.size(160, 55),
        position = cc.p(self.mBgSize.width * 0.5, 55),
        clickAction = function()
            self:requestSetFormation()
        end
    })
    self.mBgLayer:addChild(button)

    -- 提示文字
    if self.mIsSelf then
        local infoLabel = ui.newLabel({
            text = TR("该阵位的侠客在离开此界面后将会被遣散"),
            color = Enums.Color.eRed,
            size = 18,
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            dimensions = cc.size(140, 0),
        })
        infoLabel:setAnchorPoint(cc.p(0, 1))
        infoLabel:setPosition(410, 80)
        heroBgSprite:addChild(infoLabel)
    end
end

-- 创建英雄信息
function DlgSetCampLayer:createEmptyLayout(index)
    -- 容器
    local layout = ccui.Layout:create()
    layout:setContentSize(HeroWidth, HeroHeight)
    layout:setAnchorPoint(0.5, 0.5)
    layout:setPosition(self.mPosList[index])

    --背景
    local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(HeroWidth, HeroHeight))
    bgSprite:setPosition(HeroWidth / 2, HeroHeight / 2)
    layout:addChild(bgSprite)
    layout.bgSprite = bgSprite

    local tmpBgSprite = ui.newSprite("zr_36.png")
    tmpBgSprite:setPosition(HeroWidth * 0.5, HeroHeight * 0.5)
    bgSprite:addChild(tmpBgSprite)

    -- 头像背景图片
    local heroHeadBgPic = ui.newScale9Sprite("c_83.png", cc.size(140, HeroHeight))
    heroHeadBgPic:setPosition(cc.p(70, HeroHeight * 0.5))
    bgSprite:addChild(heroHeadBgPic)

    -- 模板
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
    stencilNode:setContentSize(cc.size(HeroWidth, HeroHeight + 10))
    stencilNode:setIgnoreAnchorPointForPosition(false)
    stencilNode:setAnchorPoint(cc.p(0.5, 0))
    stencilNode:setPosition(cc.p(72, 2))

    -- 创建剪裁
    local clipNode = cc.ClippingNode:create()
    clipNode:setAlphaThreshold(1.0)
    clipNode:setStencil(stencilNode)
    clipNode:setPosition(cc.p(0, 0))
    heroHeadBgPic:addChild(clipNode)
    layout.clipNode = clipNode

    return layout
end

-- 创建英雄信息
function DlgSetCampLayer:addHeroInfoView(layout, index)
    local playerModelId = self.mFormationData[index]
    if (playerModelId ~= nil) and (playerModelId > 0) then
        -- 显示人物半身照
        local heroBase = HeroModel.items[playerModelId] or {}
        Figure.newHero({
            parent = layout.clipNode,
            heroModelID = playerModelId,
            position = cc.p(72, -140),
            scale = 0.2,
            async = function (figureNode)
            end,
        })

        -- 显示人物名和等级突破
        local strName, tempStep = ConfigFunc:getHeroName(playerModelId, {heroStep = 0, IllusionModelId = 0, playerName = self.mPlayerData.Name})
        if tempStep > 0 then
            strName = strName .. "+".. tempStep
        end
        local heroName = ui.newLabel({
            text = strName,
            color = Utility.getQualityColor(heroBase.quality, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            size = 20,
        })
        heroName:setAnchorPoint(cc.p(1, 0.5))
        heroName:setPosition(245, HeroHeight * 0.5)
        layout.bgSprite:addChild(heroName)

        -- 显示血量进度条
        if (self.mPlayerData.HPs ~= nil) then
            local currHp = self.mPlayerData.HPs[index] or 0
            local maxHp = KillervalleyHeroModel.items[playerModelId].HP
            local progressBar = require("common.ProgressBar"):create({
                bgImage = "zd_01.png",
                barImage = "zd_02.png",
                currValue = currHp,
                maxValue = maxHp,
            })
            progressBar:setAnchorPoint(cc.p(1, 0.5))
            progressBar:setPosition(cc.p(245, 30))
            progressBar:setScale(1.2)
            layout.bgSprite:addChild(progressBar)
        end
    else
        -- 显示一个黑色人物
        local figureNode = ui.newSprite("c_36.png")
        figureNode:setPosition(HeroWidth * 0.5, 30)
        figureNode:setScale(0.35)
        layout.clipNode:addChild(figureNode)
    end
end

-- 提交布阵信息
function DlgSetCampLayer:requestSetFormation()
    -- 非玩家自己不能布阵
    if not self.mIsSelf then
        LayerManager.removeLayer(self)
        return
    end
    
    -- 读取新的阵位信息
    local newFormationList = {}
    for _,v in ipairs(self.mItemData) do
        table.insert(newFormationList, v.data)
    end
    
    -- 提交布阵接口
    KillerValleyHelper:changeFormation(newFormationList, function ()
            LayerManager.removeLayer(self)
        end)
end

----------------------------------------------------------------------------------------------------

-- 辅助函数：返回点击位置所处的node
function DlgSetCampLayer:getClickItem(posX, posY)
    local retItem = nil
    local nodeHalfW, nodeHalfH = HeroWidth/2, HeroHeight/2
    for _,v in ipairs(self.mItemData) do
        local pos = v.pos
        if ((posX >= (pos.x - nodeHalfW)) and (posX <= (pos.x + nodeHalfW)) and (posY >= pos.y - nodeHalfH) and (posY <= (pos.y + nodeHalfH))) then
            retItem = v
            break
        end
    end

    return retItem
end

function DlgSetCampLayer:onBeganEvent(posX, posY)
    -- 找到被点击的node，并记录当前位置
    self.lastClickPos = nil     -- 记录移动位置
    self.lastNodePos = nil      -- 记录node位置
    self.clickItem = self:getClickItem(posX, posY)
    if (self.clickItem ~= nil) then
        self.clickItem.nodeSprite:setLocalZOrder(2)
        self.lastNodePos = self.clickItem.pos
    else
        self.clickItem = nil
    end
end

function DlgSetCampLayer:onMovedEvent(posX, posY)
    -- 和上个位置距离超过3才移动
    if (self.lastClickPos == nil) then
        self.lastClickPos = cc.p(posX, posY)
    else
        local xOffset = posX - self.lastClickPos.x
        local yOffset = posY - self.lastClickPos.y
        if ((math.abs(xOffset) >= 3) or (math.abs(yOffset) >= 3)) then
            if ((self.clickItem ~= nil) and (self.lastNodePos ~= nil)) then
                self.lastNodePos = cc.p(self.lastNodePos.x + xOffset, self.lastNodePos.y + yOffset)
                self.clickItem.nodeSprite:setPosition(self.lastNodePos)
            end
            self.lastClickPos = cc.p(posX, posY)
        end
    end
end

function DlgSetCampLayer:onEndedEvent(posX, posY)
    if ((self.clickItem == nil) or (self.lastClickPos == nil)) then
        return
    end
    
    -- 计算落点的位置，判断是否可以交换
    local endItem = self:getClickItem(posX, posY)
    local function filterExchange()
        if (endItem == nil) or (endItem.showIndex == self.clickItem.showIndex) then
            return false
        end
        -- 起点是主角，终点是佣兵
        local clickHeroModel = HeroModel.items[self.clickItem.data] or {}
        if (endItem.showIndex == 7) and (clickHeroModel.specialType ~= nil) and (clickHeroModel.specialType == Enums.HeroType.eMainHero) then
            ui.showFlashView(TR("主角不能被换下!!!"))
            return false
        end
        -- 起点是佣兵，终点是主角
        local endHeroModel = HeroModel.items[endItem.data] or {}
        if (self.clickItem.showIndex == 7) and (endHeroModel.specialType ~= nil) and (endHeroModel.specialType == Enums.HeroType.eMainHero) then
            ui.showFlashView(TR("主角不能被换下!!!"))
            return false
        end

        -- 判断前六个人有几个人有血
        local haveHpsNum = 0
        for i=1, 6 do
            local hps = self.mItemData[i].hps
            if hps > 0 then 
                haveHpsNum = haveHpsNum + 1
            end 
        end
        -- 第七号位人物的血量
        local sevenHps = self.mItemData[7].hps
        -- 前六个人里面只有一个人有血量并且第七号位没有血量不能交换
        if haveHpsNum <= 1 and sevenHps <= 0 then 
            -- 如果点击的是前六人并且血量大于0不能交换
            if (self.clickItem.showIndex < 7) and (self.clickItem.hps > 0) then
                ui.showFlashView(TR("不能下阵最后一位未阵亡的侠客！"))
                return false 
            -- 如果点击的是七号位并且交换的人的血量大于0不能交换    
            elseif (self.clickItem.showIndex == 7) and (endItem.hps > 0) then 
                ui.showFlashView(TR("不能下阵最后一位未阵亡的侠客！"))
                return false 
            end 
        end 

        return true
    end
    if (filterExchange() == true) then
        self.clickItem.nodeSprite:runAction(cc.MoveTo:create(0.1, endItem.pos))
        endItem.nodeSprite:runAction(cc.MoveTo:create(0.1, self.clickItem.pos))

        -- 交换数据
        for k,v in pairs(self.clickItem) do
            if (k ~= "showIndex") and (k ~= "pos") then
                local oldValue = clone(v)
                self.clickItem[k] = endItem[k]
                endItem[k] = oldValue
            end
        end
    else
        -- 落在其他范围
        self.clickItem.nodeSprite:runAction(cc.MoveTo:create(0.1, self.clickItem.pos))
    end

    self.clickItem.nodeSprite:setLocalZOrder(0)
    self.clickItem = nil
    self.lastClickPos = nil
    self.lastNodePos = nil
end

----------------------------------------------------------------------------------------------------

return DlgSetCampLayer