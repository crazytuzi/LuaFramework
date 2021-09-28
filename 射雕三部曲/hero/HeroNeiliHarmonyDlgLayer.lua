--[[
    文件名: HeroNeiliHarmonyDlgLayer.lua
	描述: 人物内力融合技页面
	创建人: yanghongsheng
	创建时间: 2018.6.25
--]]

local HeroNeiliHarmonyDlgLayer = class("HeroNeiliHarmonyDlgLayer", function()
    return display.newLayer()
end)

--[[
    params:
    {
        heroId              hero实体id
        callback            主页面刷新
    }
--]]
function HeroNeiliHarmonyDlgLayer:ctor(params)
    -- 传入参数
    self.mHeroId = params.heroId
    self.mCallback = params.callback
    -- 获取人物信息
    self.mHeroInfo = HeroObj:getHero(self.mHeroId)
    -- 已经选择的buff列表
    self.mFloorTalList = {}
    self:dealFloorTal()
    
    -- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(620, 750),
        title = TR("融合技"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 初始化界面
    self:initUI()
end

-- 解析字符串为融合技列表
function HeroNeiliHarmonyDlgLayer:dealFloorTal()
    local floorTalStr = self.mHeroInfo.HeroNeiliHarmonyInfo.TalModelIdStr
    if not floorTalStr or floorTalStr == "" then
        self.mFloorTalList = {}
        return
    end

    local floorTalList = Utility.analysisStrAttrList(floorTalStr)
    for _, floorTalInfo in pairs(floorTalList) do
        self.mFloorTalList[floorTalInfo.fightattr] = floorTalInfo.value
    end
end

function HeroNeiliHarmonyDlgLayer:initUI()
    -- 黑背景
    local blackSize = cc.size(560, 650)
    local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
    blackBg:setAnchorPoint(cc.p(0.5, 1))
    blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-70)
    self.mBgSprite:addChild(blackBg)
    -- 列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(530, blackSize.height-10))
    self.mListView:setItemsMargin(5)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
    blackBg:addChild(self.mListView)

    -- 刷新列表
    self:refreshListView()
end

-- 刷新列表
function HeroNeiliHarmonyDlgLayer:refreshListView()
    self.mListView:removeAllChildren()

    for i, _ in ipairs(NeiliHarmonyModel.items) do
        local item = ccui.Layout:create()
        self.mListView:pushBackCustomItem(item)
        self:refreshItem(i)
    end
end

-- 刷新项
function HeroNeiliHarmonyDlgLayer:refreshItem(index)
    -- 融合信息
    local harmonyModel = NeiliHarmonyModel.items[index]
    local harmonyInfo = self.mHeroInfo.HeroNeiliHarmonyInfo or {}

    local cellSize = cc.size(530, 150)
    local layout = self.mListView:getItem(index - 1)
    layout:setContentSize(cellSize)
    layout:removeAllChildren()

    local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
    bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
    layout:addChild(bgSprite)

    local floorSprite = ui.newSprite(self.getFloorPic(harmonyModel.floor))
    floorSprite:setPosition(60, cellSize.height*0.5)
    layout:addChild(floorSprite)

    -- 是否大于内力升级重数
    if harmonyModel.floor > self:getNeiliFloor() then
        -- 提示字符串
        local hintLabel = ui.newLabel({
                text = TR("融合%d重解锁", harmonyModel.floor),
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                outlineSize = 3,
                size = 24,
            })
        hintLabel:setPosition(cellSize.width*0.5, cellSize.height*0.5)
        layout:addChild(hintLabel)

        -- 预览按钮
        local previewBtn = ui.newButton({
                normalImage = "nl_19.png",
                clickAction = function ()
                    self:selectSkillBox(index, true)
                end,
            })
        previewBtn:setPosition(460, cellSize.height*0.5)
        layout:addChild(previewBtn)
    -- 是否已融合内力
    elseif (harmonyInfo.Floor or 0) >= harmonyModel.floor then
        -- 是否已选择融合技
        if self.mFloorTalList[harmonyModel.floor] then
            -- 技能描述
            local descLabel = ui.newLabel({
                    text = TalModel.items[self.mFloorTalList[harmonyModel.floor]].intro,
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    dimensions = cc.size(270, 0),
                })
            descLabel:setAnchorPoint(cc.p(0, 0.5))
            descLabel:setPosition(140, cellSize.height*0.5)
            layout:addChild(descLabel)
            -- 切换按钮
            local selectBtn = ui.newButton({
                    normalImage = "zy_13.png",
                    clickAction = function ()
                        self:selectSkillBox(index)
                    end,
                })
            selectBtn:setPosition(460, cellSize.height*0.5)
            layout:addChild(selectBtn)
        else
            -- 点击选择融合技
            local selectBtn = ui.newButton({
                    normalImage = "nl_21.png",
                    clickAction = function ()
                        self:selectSkillBox(index)
                    end,
                })
            selectBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(selectBtn)
        end
    else
        -- 点击激活融合技
        local activeBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("融合"),
                clickAction = function ()
                    self:requestHarmony(index)
                end,
            })
        activeBtn:setPosition(450, cellSize.height*0.4)
        layout:addChild(activeBtn)
        -- 资源消耗
        local useList = Utility.analysisStrResList(harmonyModel.consume)
        -- 需要
        local strLabel = ui.newLabel({
                text = TR("需要："),
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
        strLabel:setPosition(140, cellSize.height*0.8)
        layout:addChild(strLabel)
        -- 预览按钮
        local previewBtn = ui.newButton({
                normalImage = "nl_19.png",
                clickAction = function ()
                    self:selectSkillBox(index, true)
                end,
            })
        previewBtn:setPosition(140, cellSize.height*0.4)
        layout:addChild(previewBtn)
        -- 剔除铜币
        local goldRes = nil
        local useTextList = {}
        for i, resInfo in pairs(useList) do
            if resInfo.resourceTypeSub == ResourcetypeSub.eGold then
                goldRes = resInfo
            else
                local daiImage = Utility.getDaibiImage(resInfo.resourceTypeSub, resInfo.modelId)
                local ownCount = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId)
                local useText = "{"..daiImage.."}"..Utility.numberWithUnit(ownCount).."/"..Utility.numberWithUnit(resInfo.num)
                if resInfo.num > ownCount then
                    useText = Enums.Color.eRedH.."{"..daiImage.."}"..Utility.numberWithUnit(ownCount).."#46220d".."/"..Utility.numberWithUnit(resInfo.num)
                end
                table.insert(useTextList, useText)
            end
        end
        local useText = table.concat(useTextList, "\n")
        local resLabel = ui.newLabel({
                text = useText,
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
        resLabel:setAnchorPoint(cc.p(0, 0.5))
        resLabel:setPosition(180, cellSize.height*0.5)
        layout:addChild(resLabel)
        
        -- 显示铜币
        if goldRes then
            local ownCount = Utility.getOwnedGoodsCount(ResourcetypeSub.eGold, 0)
            local goldLabel = ui.newLabel({
                    text = string.format("{%s}%s", Utility.getDaibiImage(ResourcetypeSub.eGold), Utility.numberWithUnit(goldRes.num)),
                    color = ownCount >= goldRes.num and cc.c3b(0x46, 0x22, 0x0d) or Enums.Color.eRed,
                })
            goldLabel:setPosition(450, cellSize.height*0.75)
            layout:addChild(goldLabel)
        end
    end

    return layout
end

-- 获取重数图片
function HeroNeiliHarmonyDlgLayer.getFloorPic(floor)
    local floorPicList = {
        "nl_01.png",
        "nl_02.png",
        "nl_03.png",
        "nl_04.png",
        "nl_05.png",
        "nl_06.png",
        "nl_07.png",
        "nl_08.png",
        "nl_09.png",
        "nl_10.png",
    }

    return floorPicList[floor]
end

-- 获取内力升级重数
function HeroNeiliHarmonyDlgLayer:getNeiliFloor()
    local neiliFloor = 100
    for i = 1, 3 do
        local neiliInfo = self.mHeroInfo.HeroNeiliInfo[tostring(i)] or {}
        local floor = neiliInfo.Floor or 0
        if neiliFloor > floor then
            neiliFloor = floor
        end
    end

    return neiliFloor
end

-- 选内力技弹窗
--[[
    index       第几重索引
    isPreview   是否是预览
]]
function HeroNeiliHarmonyDlgLayer:selectSkillBox(index, isPreview)
    local harmonyModel = NeiliHarmonyModel.items[index]
    if not harmonyModel then return end

    local function DIYfunc(boxRoot, bgSprite, bgSize)
        local hintLabel = ui.createSpriteAndLabel({
            imgName = "c_25.png",
            scale9Size = cc.size(540, 55),
            labelStr = TR("选择要上阵的融合技"),
            outlineColor = Enums.Color.eOutlineColor,
        })
        hintLabel:setPosition(bgSize.width*0.5, bgSize.height-90)
        bgSprite:addChild(hintLabel)

        -- 黑背景
        local blackSize = cc.size(530, 315)
        local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
        blackBg:setPosition(bgSize.width*0.5, 250)
        bgSprite:addChild(blackBg)

        -- 创建技能项
        local function createBuffItem(skillTalId, pos)
            local itemSize = cc.size(520, 95)
            local itemBg = ui.newScale9Sprite("c_18.png", itemSize)
            itemBg:setPosition(pos)
            blackBg:addChild(itemBg)

            -- 技能描述
            local descLabel = ui.newLabel({
                    text = TalModel.items[skillTalId].intro,
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    dimensions = cc.size(320, 0),
                })
            descLabel:setAnchorPoint(cc.p(0, 0.5))
            descLabel:setPosition(40, itemSize.height*0.5)
            itemBg:addChild(descLabel)

            if self.mFloorTalList[harmonyModel.floor] == skillTalId then
                -- 已上阵
                local hadSelectSprite = ui.newSprite("nl_14.png")
                hadSelectSprite:setPosition(445, itemSize.height*0.5)
                itemBg:addChild(hadSelectSprite)
            else
                -- 选择按钮
                local selectBtn = ui.newButton({
                        normalImage = "c_28.png",
                        text = TR("选择"),
                        clickAction = function ()
                            if isPreview then
                                ui.showFlashView(TR("预览中不可选择"))
                                return
                            end
                            self:requestChoiceTal(index, skillTalId)
                            LayerManager.removeLayer(boxRoot)
                        end,
                    })
                selectBtn:setPosition(445, itemSize.height*0.5)
                itemBg:addChild(selectBtn)
            end
        end

        -- 创建项
        createBuffItem(harmonyModel.tal1, cc.p(blackSize.width*0.5, 260))
        createBuffItem(harmonyModel.tal2, cc.p(blackSize.width*0.5, 160))
        createBuffItem(harmonyModel.tal3, cc.p(blackSize.width*0.5, 60))
    end



    -- 创建对话框
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            bgSize = cc.size(597, 537),
            notNeedBlack = true,
            title = TR("融合技"),
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {}
        }
    })
end

-----------------------------服务器相关----------------------------
-- 选择内功融合技能
function HeroNeiliHarmonyDlgLayer:requestChoiceTal(index, skillTalId)
    HttpClient:request({
        moduleName = "HeroNeili",
        methodName = "ChoiceHarmonyTal",
        svrMethodData = {self.mHeroId, NeiliHarmonyModel.items[index].floor, skillTalId},
        callback = function(response)
            if response.Status ~= 0 then return end
            -- 更新缓存
            HeroObj:modifyHeroItem(response.Value.HeroInfo)
            -- 更新页面数据
            self.mHeroInfo = response.Value.HeroInfo
            self:dealFloorTal()
            -- 刷新列表项
            for i, v in ipairs(self.mListView:getItems()) do
                self:refreshItem(i)
            end
        end
    })
end

-- 内功融合
function HeroNeiliHarmonyDlgLayer:requestHarmony(index)
    if (NeiliHarmonyModel.items[index].floor - 1) ~= (self.mHeroInfo.HeroNeiliHarmonyInfo.Floor or 0) then
        ui.showFlashView(TR("请先融合上一重内力"))
        return
    end
    -- 资源是否足够
    local useList = Utility.analysisStrResList(NeiliHarmonyModel.items[index].consume)
    for _, resInfo in pairs(useList) do
        if resInfo.resourceTypeSub == ResourcetypeSub.eGold then
            if not Utility.isResourceEnough(resInfo.resourceTypeSub, resInfo.num) then
                return
            end
        else
            local ownCount = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId)
            if ownCount < resInfo.num then
                LayerManager.addLayer({
                    name = "hero.DropWayLayer",
                    data = {
                        resourceTypeSub = resInfo.resourceTypeSub,
                        modelId = resInfo.modelId
                    },
                    cleanUp = false,
                })
                return
            end
        end
    end

    HttpClient:request({
        moduleName = "HeroNeili",
        methodName = "Harmony",
        svrMethodData = {self.mHeroId},
        callback = function(response)
            if response.Status ~= 0 then return end
            -- 更新缓存
            HeroObj:modifyHeroItem(response.Value.HeroInfo)
            -- 更新页面数据
            self.mHeroInfo = response.Value.HeroInfo
            self:dealFloorTal()
            -- 刷新列表项
            for i, v in ipairs(self.mListView:getItems()) do
                self:refreshItem(i)
            end
            -- 刷新主页面融合重数
            if self.mCallback then
                self.mCallback()
            end
            -- 选择融合技
            self:selectSkillBox(index)
        end
    })
end

return HeroNeiliHarmonyDlgLayer