--[[
    文件名：DlgStatistDamageLayer.lua
    描述：丹方界面
    创建人：yanghongsheng
    创建时间： 2017.12.21
--]]

local DlgStatistDamageLayer = class("DlgStatistDamageLayer", function(params)
    return display.newLayer()
end)

require("ComLogic.StatisticsManager")

--[[
    params:
     statData       统计数据
]]

function DlgStatistDamageLayer:ctor(params)
    params = params or {}
    if not params.statData or params.statData == "" then
        ui.showFlashView({text = "无战斗数据"})
        return
    end
    self.mStatData = params.statData and cjson.decode(params.statData) or StatisticsManager.getStatisticsData()
    -- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(630, 950),
        title = TR("战斗数据"),
    })
    self:addChild(parentLayer)

    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 创建页面控件
    self:initUI()
end

function DlgStatistDamageLayer:initUI()
    -- 双方图
    local tempSprite = ui.newSprite("zdjs_34.png")
    tempSprite:setPosition(self.mBgSize.width*0.5, 800)
    self.mBgSprite:addChild(tempSprite)

    -- 列表控件
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(560, 730))
    self.mListView:setItemsMargin(10)
    self.mListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(self.mBgSize.width*0.5, 30)
    self.mBgSprite:addChild(self.mListView)

    -- 四个切换按钮
    self:createTopButton()
end

function DlgStatistDamageLayer:createTopButton()
    local buttonLists = {
        -- 伤害输出
        {
            text = TR("伤害输出"),
            normalImage = "c_155.png",
            code = "Damage",
            position = cc.p(135, 860),
            size = cc.size(110, 50),
        },
        -- 治疗生命
        {
            text = TR("治疗生命"),
            normalImage = "c_155.png",
            code = "Heal",
            position = cc.p(258, 860),
            size = cc.size(110, 50),
        },
        -- 伤害承受
        {
            text = TR("伤害承受"),
            normalImage = "c_155.png",
            code = "BeHit",
            position = cc.p(382, 860),
            size = cc.size(110, 50),
        },
        -- 控制效果
        {
            text = TR("控制效果"),
            normalImage = "c_155.png",
            code = "Buff",
            position = cc.p(505, 860),
            size = cc.size(110, 50),
        },
    }

    self.mTopBtnList = {}

    for _, buttonInfo in ipairs(buttonLists) do
        buttonInfo.clickAction = function ()
            self:refreshList(buttonInfo.code)
        end

        local tempBtn = ui.newButton(buttonInfo)
        self.mBgSprite:addChild(tempBtn)
        tempBtn.code = buttonInfo.code

        table.insert(self.mTopBtnList, tempBtn)
    end

    self.mTopBtnList[1]:mClickAction()
end

-- 刷新显示列表
function DlgStatistDamageLayer:refreshList(code)
    if self.mCode and self.mCode == code then
        return
    end

    self.mCode = code
    -- 刷新按钮图片显示
    for _, btn in pairs(self.mTopBtnList) do
        if btn.code == self.mCode then
            btn:loadTextures("c_154.png", "c_154.png")
        else
            btn:loadTextures("c_155.png", "c_155.png")
        end
    end

    self.mListView:removeAllChildren()
    -- 获取数据列表
    local dataList = self:getListData(code)
    -- 获取数据长度
    local len = #dataList.ownList > #dataList.otherList and #dataList.ownList or #dataList.otherList
    -- 创建列表项
    for i = 1, len do
        local item = self:createItem(dataList.ownList[i], dataList.otherList[i], dataList.ownMaxValue, dataList.otherMaxValue)
        self.mListView:pushBackCustomItem(item)
    end
end

-- 创建列表项
function DlgStatistDamageLayer:createItem(ownData, otherData, ownMaxValue, otherMaxValue)
    local cellItem = ccui.Layout:create()
    local cellSize = cc.size(self.mListView:getContentSize().width, 150)
    cellItem:setContentSize(cellSize)

    local blackSprite = ui.newScale9Sprite("c_17.png", cellSize)
    blackSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
    cellItem:addChild(blackSprite)
    -- 我方数据
    if ownData then
        -- 头像
        local head1 = CardNode.createCardNode({
            resourceTypeSub = Utility.getTypeByModelId(ownData.ModelId),
            modelId = self:getHeadModelId(ownData),
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = false,
        })
        head1:setPosition(60, cellSize.height*0.5)
        cellItem:addChild(head1)
        -- 名字
        local nameLabel1 = ui.newLabel({
            text = self:getName(ownData),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        nameLabel1:setAnchorPoint(cc.p(0, 0.5))
        nameLabel1:setPosition(120, 110)
        cellItem:addChild(nameLabel1)
        -- 伤害，治疗，承伤
        if self.mCode ~= "Buff" then
            -- 数值
            local numberLabel = ui.newLabel({
                text = math.floor(ownData[self.mCode]),
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
            numberLabel:setAnchorPoint(cc.p(1, 0.5))
            numberLabel:setPosition(cellSize.width*0.5-20, 80)
            cellItem:addChild(numberLabel)
            -- 进度
            local barImageList = {Damage = "zdjs_41.png", Heal = "zdjs_40.png", BeHit = "zdjs_42.png"}
            local progressBar = require("common.ProgressBar"):create({
                bgImage = "zdjs_39.png",
                barImage = barImageList[self.mCode],
                currValue = ownData[self.mCode],
                maxValue = ownMaxValue,
            })
            progressBar:setPosition(190, 40)
            cellItem:addChild(progressBar)
        -- buff
        else
            local buffTypeList = {
                BanAct = TR("眩晕"),
                BanRA = TR("沉默"),
                BanNA = TR("麻痹"),
                HPDOT = TR("流血"),
                Freeze = TR("冰冻"),
            }
            local buffData = ownData[self.mCode]
            local count = 0
            for key, str in pairs(buffTypeList) do
                local buffLabel = ui.newLabel({
                    text = str.." x "..buffData[key],
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 18,
                })
                buffLabel:setAnchorPoint(cc.p(0, 0.5))
                local x, y = count%2, math.floor(count/2)
                buffLabel:setPosition(120+x*80, 80-y*30)
                cellItem:addChild(buffLabel)

                count = count + 1
            end
        end
    end

    if otherData then
        local head2 = CardNode.createCardNode({
            resourceTypeSub = Utility.getTypeByModelId(otherData.ModelId),
            modelId = self:getHeadModelId(otherData),
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = false,
        })
        head2:setPosition(cellSize.width-60, cellSize.height*0.5)
        cellItem:addChild(head2)

        local nameLabel2 = ui.newLabel({
            text = self:getName(otherData),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        nameLabel2:setAnchorPoint(cc.p(1, 0.5))
        nameLabel2:setPosition(cellSize.width-120, 110)
        cellItem:addChild(nameLabel2)

        if self.mCode ~= "Buff" then
            -- 数值
            local numberLabel = ui.newLabel({
                text = math.floor(otherData[self.mCode]),
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
            numberLabel:setAnchorPoint(cc.p(0, 0.5))
            numberLabel:setPosition(cellSize.width*0.5+20, 80)
            cellItem:addChild(numberLabel)

            -- 进度
            local barImageList = {Damage = "zdjs_41.png", Heal = "zdjs_40.png", BeHit = "zdjs_42.png"}
            local progressBar = require("common.ProgressBar"):create({
                bgImage = "zdjs_39.png",
                barImage = barImageList[self.mCode],
                currValue = otherData[self.mCode],
                maxValue = otherMaxValue,
            })
            progressBar:setPosition(cellSize.width-190, 40)
            cellItem:addChild(progressBar)
        else
            local buffTypeList = {
                BanAct = TR("眩晕"),
                BanRA = TR("沉默"),
                BanNA = TR("麻痹"),
                HPDOT = TR("流血"),
                Freeze = TR("冰冻"),
            }
            local buffData = otherData[self.mCode]
            local count = 0
            for key, str in pairs(buffTypeList) do
                local buffLabel = ui.newLabel({
                    text = str.." x "..buffData[key],
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 18,
                })
                buffLabel:setAnchorPoint(cc.p(0, 0.5))
                local x, y = count%2, math.floor(count/2)
                buffLabel:setPosition(300+x*80, 80-y*30)
                cellItem:addChild(buffLabel)

                count = count + 1
            end
        end
    end

    return cellItem
end

-- 获取侠客头像模型id
function DlgStatistDamageLayer:getHeadModelId(heroData)
    -- 侠客
    if HeroModel.items[heroData.ModelId] then
        local illusionModelId = ConfigFunc:getIllusionModelId(heroData.LargePic)
        local fashionModelId = ConfigFunc:getFashionModelId(heroData.LargePic)

        if illusionModelId ~= 0 then return illusionModelId end

        if fashionModelId ~= 0 then return fashionModelId end

        return heroData.ModelId
    -- 外功
    else
       return heroData.ModelId
    end
end

-- 获取侠客名字
function DlgStatistDamageLayer:getName(heroData)
    -- 侠客
    if HeroModel.items[heroData.ModelId] then
        if heroData.Name ~= "" then
            return bd.interface.b64decode(heroData.Name)
        else
            return HeroModel.items[heroData.ModelId].name
        end
    -- 外功
    elseif PetModel.items[heroData.ModelId] then
        return PetModel.items[heroData.ModelId].name
    -- 珍兽
    elseif ZhenshouModel.items[heroData.ModelId] then
        return ZhenshouModel.items[heroData.ModelId].name
    end
end

-- 获取列表数据
function DlgStatistDamageLayer:getListData(code)
    local dataList = {}
    dataList.ownList = {}
    dataList.otherList = {}
    dataList.ownMaxValue = 0
    dataList.otherMaxValue = 0
    -- 侠客
    local heroIdexList = table.keys(self.mStatData.Hero)
    for i = 1, #heroIdexList do
        local heroIndex = heroIdexList[i]
        local heroData = self.mStatData.Hero[heroIndex]

        -- 我方数据
        if heroIndex <= 6 then
            -- 找最大值
            if type(heroData[code]) == type(0) then
                if dataList.ownMaxValue < heroData[code] then
                    dataList.ownMaxValue = heroData[code]
                end
            end

            table.insert(dataList.ownList, heroData)
        -- 对方数据
        else
            -- 找最大值
            if type(heroData[code]) == type(0) then
                if dataList.otherMaxValue < heroData[code] then
                    dataList.otherMaxValue = heroData[code]
                end
            end

            table.insert(dataList.otherList, heroData)
        end
    end

    -- 珍兽
    if code == "Damage" or code == "Heal" then
        local itemData = {}
        if self.mStatData.Zhenshou[1] then
            -- 找最大值
            if dataList.ownMaxValue < self.mStatData.Zhenshou[1][code] then
                dataList.ownMaxValue = self.mStatData.Zhenshou[1][code]
            end

            table.insert(dataList.ownList, self.mStatData.Zhenshou[1])
        end
        if self.mStatData.Zhenshou[2] then
            -- 找最大值
            if dataList.otherMaxValue < self.mStatData.Zhenshou[2][code] then
                dataList.otherMaxValue = self.mStatData.Zhenshou[2][code]
            end

            table.insert(dataList.otherList, self.mStatData.Zhenshou[2])
        end
    end

    -- 外功
    if code == "Damage" or code == "Heal" then
        local petIdexList = table.keys(self.mStatData.Pet)
        for i = 1, #petIdexList do
            local petIndex = petIdexList[i]
            local petData = self.mStatData.Pet[petIndex]

            if petIndex <= 6 then
                -- 找最大值
                if dataList.ownMaxValue < petData[code] then
                    dataList.ownMaxValue = petData[code]
                end

                table.insert(dataList.ownList, petData)
            else
                -- 找最大值
                if dataList.otherMaxValue < petData[code] then
                    dataList.otherMaxValue = petData[code]
                end

                table.insert(dataList.otherList, petData)
            end
        end
    end

    return dataList
end

return DlgStatistDamageLayer