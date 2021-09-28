--[[
    文件名：IllustrateHomeLayer.lua
    描述：群侠谱首页
    创建人：peiyaoqiang
    创建时间：2017.11.13
-- ]]

----------------------------------------------------------------------------------------------------
--
local IllustrateHomeLayer = class("IllustrateHomeLayer", function()
    return display.newLayer()
end)

--[[
--]]
function IllustrateHomeLayer:ctor(params)
    self.mCurrTab = params.defaultTab or 3       -- 当前Tab页面
    self.mActiveData = {}   -- 已激活的全部人物
    self.mShowData = {}     -- 要显示的人物数据
    self.mRaceState = {}    -- 各阵营的选择状态
    self.mSelectState = {}  -- 筛选菜单选择状态
    
    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation,
        topInfos = {
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold,
            ResourcetypeSub.eHeroExp,
        }
    })
    self:addChild(topResource, 1)

    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 侠客录的父节点
    self.mHeroParent = cc.Node:create()
    self.mParentLayer:addChild(self.mHeroParent, 1)

    -- 绝学录的父节点
    self.mFashionParent = cc.Node:create()
    self.mParentLayer:addChild(self.mFashionParent, 1)

    -- 背景图
    local bgSprite = ui.newSprite("qxp_05.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 1))
    bgSprite:setPosition(320, 1136)
    self.mParentLayer:addChild(bgSprite)

    -- 退出按钮
    local btnClose = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1020),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(btnClose, 2)

    -- 初始化页面
    self:initUI()

    -- 获取数据
    local function showData()
        -- 自动跳转到可激活或可升星的分页
        if (params.defaultTab == nil) then
            self.mCurrTab = self:calcDefaultTabPage()
            self.tabLayer:activeTabBtnByTag(self.mCurrTab)
        end
        self:showWhichParent()
        self:refreshView()

        -- 保存当前的侠谱大师等级
        self.oldMasterList = self:readMasterList()
    end
    self:requestGetInfo(showData)
end

-- 创建UI
function IllustrateHomeLayer:initUI()
    -- 号令群侠
    local btnAttr = ui.newButton({
        normalImage = "qxp_09.png",
        position = cc.p(60, 1020),
        clickAction = function()
            self:showMasterLayer()
        end
    })
    self.mParentLayer:addChild(btnAttr, 2)

    -- Tab列表
    self.tabConfigs = {
        {tag = 3, text = TR("传说")},
        {tag = 2, text = TR("神话")},
        {tag = 1, text = TR("宗师")},
        {tag = 4, text = TR("绝学录")},
    }
    local tabLayer = ui.newTabLayer({
        btnInfos = self.tabConfigs,
        defaultSelectTag = self.mCurrTab,
        needLine = false,
        onSelectChange = function(tag)
            if (self.mCurrTab ~= tag) then
                self.mCurrTab = tag
                
                self:showWhichParent()
                self:refreshView()
            end
        end,
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setPosition(cc.p(320, 992))
    self.mParentLayer:addChild(tabLayer)
    self.tabLayer = tabLayer

    -- 列表框背景
    local viewBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 930))
    viewBgSprite:setAnchorPoint(cc.p(0.5, 0))
    viewBgSprite:setPosition(320, 0)
    self.mParentLayer:addChild(viewBgSprite)

    -- 暂无侠谱的提示图
    local emptyHintSprite = ui.createEmptyHint(TR("没有符合条件的侠谱"))
    emptyHintSprite:setAnchorPoint(cc.p(0.5, 0))
    emptyHintSprite:setPosition(310, 520)
    emptyHintSprite:setVisible(false)
    self.mParentLayer:addChild(emptyHintSprite, 1)
    self.emptyHintSprite = emptyHintSprite
    
    -- 创建列表框
    self:createHeroListView()
    self:createFashionListView()

    -- 创建筛选框
    self:createSelectView()

    -- 创建属性框
    self:createAttrView()

    -- 设置默认显示
    self:showWhichParent()
end

-- 创建侠客列表框
function IllustrateHomeLayer:createHeroListView()
    self.mHeroListView = self:createCommonListView(self.mHeroParent, cc.size(620, 730), function (item)
        LayerManager.addLayer({name = "hero.IllustrateHeroInfo", data = {
            HeroList = self.mShowData, 
            CurrHeroModelId = item.HeroModelId,
            curCampId = self.mCurrTab, 
            callback = function ()
                self:requestGetInfo(function (response)
                        self:refreshView()

                        -- 判断升星大师是否激活
                        local currMasterList = self:readMasterList()
                        self.oldMasterList = self.oldMasterList or {}
                        
                        local oldLv = self.oldMasterList[self.mCurrTab] or 0
                        local newLv = currMasterList[self.mCurrTab] or 0
                        if (newLv > oldLv) and (newLv >= 2) then
                            local newLayer = require("hero.ActiveIllustrateMasterLayer").new({curTab = self.mCurrTab, masterLv = newLv})
                            LayerManager.getMainScene():addChild(newLayer, Enums.ZOrderType.eNewbieGuide + 1)
                        end

                        -- 保存当前的数据
                        self.oldMasterList = clone(currMasterList)
                    end)
            end,
        }, cleanUp = false})
    end)
end

-- 创建绝学列表框
function IllustrateHomeLayer:createFashionListView()
    self.mFashionListView = self:createCommonListView(self.mFashionParent, cc.size(620, 790), function (item)
        LayerManager.addLayer({name = "hero.IllustrateHeroInfo", data = {
            HeroList = self.mShowData, 
            CurrHeroModelId = item.HeroModelId,
            curCampId = self.mCurrTab, 
            callback = function ()
                self:requestGetInfo(function (response)
                        self:refreshView()
                    end)
            end,
        }, cleanUp = false})
    end)
end

-- 创建绝学列表框
function IllustrateHomeLayer:createCommonListView(parent, listBgSize, callFunc)
    local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(320, 100)
    parent:addChild(listBgSprite)

    -- 创建列表
    local mListView = ccui.ListView:create()
    mListView:setContentSize(600, listBgSize.height - 20)
    mListView:setAnchorPoint(0.5, 0)
    mListView:setPosition(310, 10)
    mListView:setDirection(ccui.ScrollViewDir.vertical)
    mListView:setBounceEnabled(true)
    listBgSprite:addChild(mListView)

    -- 列表刷新接口
    mListView.refreshShow = function (target)
        target:removeAllItems()
        target:jumpToTop()
        self.emptyHintSprite:setVisible(false)

        -- 判断是否有内容
        local nCount = #self.mShowData
        if (nCount == 0) then
            self.emptyHintSprite:setVisible(true)
            return
        end

        -- 辅助接口：添加一个人物
        local function addOneHeader(index, parent, pos)
            local item = self.mShowData[index]
            if (item == nil) then
                return
            end

            -- 背景底板
            local bgPanelSprite = ui.newSprite("qxp_04.png")
            bgPanelSprite:setPosition(pos)
            parent:addChild(bgPanelSprite)

            -- 背景框
            local bgBorderImgs = {[1] = "qxp_01.png", [2] = "qxp_02.png", [3] = "qxp_03.png", [4] = "qxp_01.png"}
            local bgBorderSprite = ui.newSprite(bgBorderImgs[self.mCurrTab])
            local bgBorderSize = bgBorderSprite:getContentSize()
            bgBorderSprite:setPosition(pos)
            parent:addChild(bgBorderSprite)

            -- 模板
            local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 128))
            stencilNode:setContentSize(cc.size(bgBorderSize.width - 22, bgBorderSize.height - 20))
            stencilNode:setIgnoreAnchorPointForPosition(false)
            stencilNode:setAnchorPoint(cc.p(0.5, 0.5))
            stencilNode:setPosition(cc.p(bgBorderSize.width / 2 - 2, bgBorderSize.height / 2))

            -- 创建剪裁
            local clipNode = cc.ClippingNode:create()
            clipNode:setAlphaThreshold(1.0)
            clipNode:setStencil(stencilNode)
            clipNode:setPosition(cc.p(0, 0))
            bgPanelSprite:addChild(clipNode)

            -- 绝学静态图
            local heroModel = IllustratedHeroLihuiRelation.items[item.HeroModelId]
            local staticSprite = ui.newSprite(heroModel.pic .. ".png")
            staticSprite:setAnchorPoint(cc.p(0.5, 0))
            staticSprite:setPosition(bgBorderSize.width / 2, 0)
            staticSprite:setScale(0.3)
            clipNode:addChild(staticSprite)

            -- 未激活的图片置灰
            if (item.StarNum == 0) then
                bgPanelSprite:setGray(true)
                staticSprite:setGray(true)
            end

            -- 名字
            local nameSprite = ui.newSprite(heroModel.smallPic .. ".png")
            nameSprite:setScale(0.7)
            nameSprite:setAnchorPoint(cc.p(0, 1))
            nameSprite:setPosition(8, bgBorderSize.height - 25)
            bgBorderSprite:addChild(nameSprite)

            -- 星级
            self:addStarLevel(item.StarNum - 1, bgBorderSprite, bgBorderSize)

            -- 可激活或升级的标志
            local activeImg = (item.isCanStarUp == true) and "qxp_07.png" or nil
            if (item.isCanActive == true) then
                activeImg = "qxp_06.png"
            end
            if (activeImg ~= nil) then
                ui.createGlitterSprite({
                    filename = activeImg,
                    parent = bgBorderSprite,
                    position = cc.p(bgBorderSize.width / 2 - 10, bgBorderSize.height / 2),
                    actionScale = 1.05,
                })
            end

            -- 透明按钮
            local btnUp = ui.newButton({
                normalImage = "c_83.png",
                size = cc.size(bgBorderSize.width - 20, bgBorderSize.height - 20),
                position = cc.p(bgBorderSize.width / 2, bgBorderSize.height / 2),
                clickAction = function ()
                    callFunc(item)
                end
            })
            btnUp:setSwallowTouches(false)
            bgBorderSprite:addChild(btnUp)
        end

        -- 显示内容
        local nLine = math.ceil(nCount / 3) + 1     -- 为了最后一行不被挡住，在最后面加一个空白行
        for i=1,nLine do
            local layout = ccui.Layout:create()
            layout:setContentSize(600, ((i == nLine) and 200 or 260))
            target:pushBackCustomItem(layout)

            -- 顺序添加三个侠客
            addOneHeader(((i-1)*3)+1, layout, cc.p(100, 130))
            addOneHeader(((i-1)*3)+2, layout, cc.p(300, 130))
            addOneHeader(((i-1)*3)+3, layout, cc.p(500, 130))
        end
    end
    mListView:refreshShow()

    return mListView
end

-- 创建筛选框
function IllustrateHomeLayer:createSelectView()
    local tmpBgSprite = ui.newSprite("sc_19.png")
    tmpBgSprite:setScaleX(2.2)
    tmpBgSprite:setScaleY(1.5)
    tmpBgSprite:setPosition(320, 870)
    self.mHeroParent:addChild(tmpBgSprite)

    -- 是否升星
    local selectBtn = ui.newButton({
        normalImage = "bg_01.png",
        text = TR("筛选"),
        fontSize = 22,
        outlineColor = cc.c3b(0x18, 0x7e, 0x6d),
    })
    selectBtn:setPosition(60, 870)
    self.mHeroParent:addChild(selectBtn, 2)

    -- 三角形箭头
    local triangle = ui.newSprite("bg_02.png")
    triangle:setRotation(90)
    triangle:setPosition(84, 22)
    selectBtn:addChild(triangle)

    --控制展示或者关闭菜单
    local temp, offset = true, nil
    local numberText = {[0] = TR("未激活"), [1] = TR("未升星"), [2] = TR("一星"), [3] = TR("二星"), [4] = TR("三星"), [5] = TR("四星"), [6] = TR("五星"), [7] = TR("一月"), [8] = TR("二月"), [9] = TR("三月"), [10] = TR("四月"), [11] = TR("五月")}
    self.mSelectState = {
        [0] = true,
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = true,
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true,
    }
    selectBtn:setClickAction(function(pSender)
        pSender:setEnabled(false)
        local showAction
        local touchLayer = display.newLayer()
        touchLayer:setPosition(0, 0)
        self.mHeroParent:addChild(touchLayer, 99)
        ui.registerSwallowTouch({
            node = touchLayer,
            allowTouch = true,
            endedEvent = function(touch, event)
                temp, offset = true, 1
                triangle:setRotation(offset*90)
                
                local callfunDelete = cc.CallFunc:create(function()
                    if self.mSelBgSprite then
                        self.mSelBgSprite:removeFromParent()
                        self.mSelBgSprite = nil
                    end
                end)
                local callfunCT = cc.CallFunc:create(function()
                    pSender:setEnabled(true)
                    touchLayer:removeFromParent()
                end)
                local scale = cc.ScaleTo:create(0.3, 1)
                self.mSelBgSprite:runAction(cc.Sequence:create(scale, callfunDelete, callfunCT))
            end
            })

        if temp then
            offset = 0
            temp = false
            local callfunCT = cc.CallFunc:create(function()
                pSender:setEnabled(true)
            end)
            local scale = cc.ScaleTo:create(0.3, 2)
            showAction = cc.Sequence:create(scale, callfunCT)
        end
        triangle:setRotation(offset*90)

        if not self.mSelBgSprite then
            --菜单背景
            local selBgSize = cc.size(100, 150)
            local selBgSprite = ui.newScale9Sprite("zb_05.png", selBgSize)
            selBgSprite:setAnchorPoint(0, 1)
            selBgSprite:setPosition(10, 840)
            touchLayer:addChild(selBgSprite)
            self.mSelBgSprite = selBgSprite
            
            --菜单列表
            local selectListView = ccui.ListView:create()
            selectListView:setPosition(selBgSize.width * 0.5, selBgSize.height)
            selectListView:setAnchorPoint(0.5, 1)
            selectListView:setContentSize(selBgSize.width - 10, selBgSize.height - 5)
            selectListView:setDirection(ccui.ScrollViewDir.vertical)
            selectListView:setBounceEnabled(true)
            self.mSelBgSprite:addChild(selectListView)

            for i = 0, #self.mSelectState do
                local layout = ccui.Layout:create()
                layout:setContentSize(138, 20)
                layout:setScale(0.5)
                selectListView:pushBackCustomItem(layout)

                -- 复选框
                local checkBtn = ui.newCheckbox({
                    text = numberText[i] .. TR("侠谱"),
                    textColor = cc.c3b(0x46, 0x22, 0x0d),
                    callback = function(pSenderC)
                        self.mSelectState[i] = (not self.mSelectState[i])
                        self:refreshView()
                    end
                })
                checkBtn:setAnchorPoint(cc.p(0, 0.5))
                checkBtn:setPosition(10, 10)
                layout:addChild(checkBtn)
                checkBtn:setCheckState(self.mSelectState[i])
                
                -- 透明按钮
                local touchBtn = ui.newButton({
                    normalImage = "c_83.png",
                    size = cc.size(138, 20),
                    clickAction = function()
                        self.mSelectState[i] = (not self.mSelectState[i])
                        checkBtn:setCheckState(self.mSelectState[i])
                        self:refreshView()
                    end
                })
                touchBtn:setPosition(69, 10)
                layout:addChild(touchBtn)
            end
        end

        self.mSelBgSprite:runAction(showAction)
    end)

    -- 阵容类型
    local function createCheckBox(raceType, xPos)
        local tmpCheckBox = ui.newCheckbox({
            normalImage = "c_60.png",
            selectImage = "c_61.png",
            isRevert = false,
            text = Utility.getRaceNameById(raceType),
            outlineColor = Enums.Color.eOutlineColor,
            callback = function(State)
                self.mRaceState[raceType] = State
                self:refreshView()
            end
        })
        tmpCheckBox:setPosition(xPos, 870)
        tmpCheckBox:setCheckState(true)     -- 默认选中
        self.mRaceState[raceType] = true    -- 默认选中
        self.mHeroParent:addChild(tmpCheckBox)
    end

    createCheckBox(Enums.HeroRace.eRace3, 200)
    createCheckBox(Enums.HeroRace.eRace2, 350)
    createCheckBox(Enums.HeroRace.eRace1, 500)
end

-- 创建属性框
function IllustrateHomeLayer:createAttrView()
    local attrBgSprite = ui.newSprite("qxp_10.png")
    local attrBgSize = attrBgSprite:getContentSize()
    attrBgSprite:setAnchorPoint(cc.p(0.5, 0))
    attrBgSprite:setPosition(320, 100)
    self.mParentLayer:addChild(attrBgSprite, 1)

    -- 标题
    local titleSprite = ui.newSprite("qxp_08.png")
    titleSprite:setAnchorPoint(cc.p(0.5, 0))
    titleSprite:setPosition(320, 250)
    self.mParentLayer:addChild(titleSprite, 1)

    -- 读取某个人物的升星加成属性
    local function readAttrOfStar(item)
        for _,tabList in pairs(IllustratedAttrRelation.items) do
            for modelId,v in pairs(tabList) do
                if (tonumber(modelId) == item.HeroModelId) then
                    return v[item.StarNum].currentAttr
                end
            end
        end
        return ""
    end
    local posList = {
        cc.p(attrBgSize.width * 0.08, 110), cc.p(attrBgSize.width * 0.4, 110), cc.p(attrBgSize.width * 0.72, 110), 
        cc.p(attrBgSize.width * 0.08, 75), cc.p(attrBgSize.width * 0.4, 75), cc.p(attrBgSize.width * 0.72, 75), 
        cc.p(attrBgSize.width * 0.08, 40), cc.p(attrBgSize.width * 0.4, 40), cc.p(attrBgSize.width * 0.72, 40), 
    }

    --
    self.mAttrView = attrBgSprite
    self.mAttrView.refreshShow = function (target)
        target:removeAllChildren()

        -- 叠加所有相同的属性
        local allAttrList = {}
        for _,v in pairs(self.mActiveData) do
            for _,v1 in ipairs(string.split(readAttrOfStar(v), ",")) do
                local tmpAttr = string.split(v1, "||")
                if (allAttrList[tonumber(tmpAttr[1])] == nil) then
                    allAttrList[tonumber(tmpAttr[1])] = {}
                end
                local typeList = allAttrList[tonumber(tmpAttr[1])]
                local attrList = string.split(tmpAttr[2], "|")
                local attrValue = typeList[tonumber(attrList[1])] or 0
                typeList[tonumber(attrList[1])] = attrValue + tonumber(attrList[2])
            end
        end

        -- 显示属性
        local index = 0
        for range,list in pairs(allAttrList) do
            for attr,value in pairs(list) do
                index = index + 1

                local attrLabel = ui.newLabel({
                    text = string.format("%s%s%s+%s", Utility.getRangeStr(range), FightattrName[attr], "#A8FF5B", value),
                    size = 22,
                })
                attrLabel:setAnchorPoint(cc.p(0, 0.5))
                attrLabel:setPosition(posList[index])
                target:addChild(attrLabel)
            end
        end
        if (index == 0) then
            local infoLabel = ui.newLabel({
                text = TR("暂未激活任何属性"),
                size = 30,
            })
            infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
            infoLabel:setPosition(attrBgSize.width * 0.5, 75)
            target:addChild(infoLabel)
        end
    end
    self.mAttrView:refreshShow()
end

-- 切换显示侠客或绝学的内容
function IllustrateHomeLayer:showWhichParent()
    self.mHeroParent:setVisible(self.mCurrTab ~= 4)
    self.mFashionParent:setVisible(self.mCurrTab == 4)
end

----------------------------------------------------------------------------------------------------

-- 联网请求最新数据
function IllustrateHomeLayer:requestGetInfo(callback)
    HttpClient:request({
        moduleName = "Illustrated",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if (response.Value ~= nil) and (response.Value.IllustratedInfo ~= nil) then
                self.mActiveData = clone(response.Value.IllustratedInfo)
                callback()
            end
        end
    })
end

-- 刷新当前数据
function IllustrateHomeLayer:refreshData()
    -- 辅助接口：判断某个人物是否可以显示
    local function itemCanShow(item)
        -- 如果不是侠客，那就是绝学
        local tempModel = HeroModel.items[item.HeroModelId]
        if (tempModel == nil) then
            return true
        end

        -- 筛选阵营
        local raceState = self.mRaceState[tempModel.raceID]
        if (raceState == nil) or (raceState == false) then
            return false
        end

        -- 筛选星级
        local starState = self.mSelectState[item.StarNum]
        if (starState == nil) or (starState == false) then
            return false
        end

        return true
    end

    -- 读取全部的人物数据
    local tmpData = {}
    for k,v in pairs(IllustratedAttrRelation.items[self.mCurrTab]) do
        local currModelId = tonumber(k)
        table.insert(tmpData, {HeroModelId = currModelId, StarNum = self:getStarNumByModelId(currModelId), usedNum = self:getUsedNumByModelId(currModelId)})
    end

    -- 筛选要显示的人物
    self.mShowData = {}
    for _,v in ipairs(tmpData) do
        if itemCanShow(v) then
            local tmpV = clone(v)
            tmpV.isCanActive = self:itemCanActive(v)
            tmpV.isCanStarUp, tmpV.ownNum = self:itemCanStarUp(v)
            tmpV.ownNum = tmpV.ownNum or 0
            table.insert(self.mShowData, tmpV)
        end
    end
    table.sort(self.mShowData, function(a, b)
        -- 可激活的在前
        if (a.isCanActive ~= b.isCanActive) then
            return (a.isCanActive == true)
        end

        -- 可升星的在前
        if (a.isCanStarUp ~= b.isCanStarUp) then
            return (a.isCanStarUp == true)
        end

        -- 数量大于0的在前
        if (a.ownNum > 0) ~= (b.ownNum > 0) then
            return (a.ownNum > 0)
        end

        -- 星数低的在前
        return a.StarNum < b.StarNum
    end)
end

-- 刷新页面的显示
function IllustrateHomeLayer:refreshView()
    self:refreshData()
    if (self.mCurrTab == 4) then
        self.mFashionListView:refreshShow()
    else
        self.mHeroListView:refreshShow()
    end
    self.mAttrView:refreshShow()
end

-- 第一个可激活或可升星的页面：传说>神话>宗师
function IllustrateHomeLayer:calcDefaultTabPage()
    for _,tabIdx in ipairs({3, 2, 1, 4}) do
        -- 读取全部的人物数据
        local tmpData = {}
        for k,v in pairs(IllustratedAttrRelation.items[tabIdx]) do
            -- 找到任意一个可升星的人物即可返回
            local currModelId = tonumber(k)
            local tmpItem = {HeroModelId = currModelId, StarNum = self:getStarNumByModelId(currModelId)}
            if (self:itemCanStarUp(tmpItem, tabIdx) == true) then
                return tabIdx
            end
        end
    end

    return self.mCurrTab
end

---------------------------------------------辅助接口-------------------------------------------------

-- 显示星级
function IllustrateHomeLayer:addStarLevel(starNum, parent, parentSize)
    if (starNum == nil) or (starNum <= 0) then
        return
    end

    local xPos, yPos = parentSize.width - 35, 170
    local space = -32
    local monStars = 5
    local monNum = starNum - monStars

    -- 月亮
    if monNum > 0 then
        for i = 1, monNum do
            local starSprite = ui.newSprite("zs_04.png")
            parent:addChild(starSprite)
            starSprite:setPosition(xPos, yPos)
            yPos = yPos + space
        end
    -- 星星
    else
        for i = 1, starNum do
            local starSprite = ui.newSprite("c_75.png")
            parent:addChild(starSprite)
            starSprite:setPosition(xPos, yPos)
            yPos = yPos + space
        end
    end
end

-- 辅助接口：读取侠客对应的星级
function IllustrateHomeLayer:getStarNumByModelId(heroModelId)
    local retNum = 0
    for _,v in pairs(self.mActiveData) do
        if (heroModelId == v.HeroModelId) then
            retNum = v.StarNum
            break
        end
    end
    return retNum
end

-- 辅助接口：读取侠客在当前星数已消耗的同名侠客数据
function IllustrateHomeLayer:getUsedNumByModelId(heroModelId)
    local retNum = 0
    for _,v in pairs(self.mActiveData) do
        if (heroModelId == v.HeroModelId) then
            retNum = v.Num
            break
        end
    end
    return retNum
end

-- 辅助接口：判断是否可升星
function IllustrateHomeLayer:itemCanStarUp(item, tabIndex)
    local configList = nil
    for k,v in pairs(IllustratedAttrRelation.items[tabIndex or self.mCurrTab]) do
        if (tonumber(k) == item.HeroModelId) then
            configList = clone(v)
            break
        end
    end
    if (configList == nil) then
        return false
    end

    -- 读取升星配置
    local nextConfig = configList[item.StarNum + 1]
    if (nextConfig == nil) then
        return false
    end

    -- 读取升星需求同名卡的数量
    local needNum = nextConfig.consumHeroNum
    local ownNum = 0
    if Utility.isFashion(math.floor(item.HeroModelId / 10000)) then
        ownNum = FashionObj:getFashionCount(item.HeroModelId) - 1
        if (ownNum < 0) then
            ownNum = 0   -- 不管是否上阵，该绝学必须保留一件不被消耗
        end
    else
        ownNum = HeroObj:getCountByModelId(item.HeroModelId, {notInFormation = true, maxLv = 1, maxStep = 0})
    end
    
    return (ownNum >= needNum), ownNum
end

-- 辅助接口：判断是否可激活
function IllustrateHomeLayer:itemCanActive(item)
    return ((item.StarNum == 0) and self:itemCanStarUp(item))
end

---------------------------------------------号令群侠-------------------------------------------------

-- 弹出号令群侠的对话框
function IllustrateHomeLayer:readMasterList()
    -- 辅助接口：读取某个Tab当前的升星大师等级
    local function readStarMasterLv(nTab)
        local retLv = 999
        for k,v in pairs(IllustratedAttrRelation.items[nTab]) do
            local currStar = self:getStarNumByModelId(tonumber(k))
            if (retLv > currStar) then
                retLv = currStar
            end
        end
        return retLv
    end

    -- 读取全部的升星大师等级
    local masterList = {
        [1] = readStarMasterLv(1),
        [2] = readStarMasterLv(2),
        [3] = readStarMasterLv(3),
    }
    return masterList
end

function IllustrateHomeLayer:refreshMasterView(parentNode, starCountList)
    -- 获取当前tag名
    local tagName = ""
    for _,v in ipairs(self.tabConfigs) do
        if self.masterSelectedTag == v.tag then
            tagName = v.text
            break
        end
    end
    
    local tagStarCount = starCountList[self.masterSelectedTag]
    parentNode:removeAllChildren()

    -- 创建所有加成label
    local attrStringList = IllustratedMasterRelation.items[self.masterSelectedTag]
    local startStarCount = tagStarCount < 2 and 2 or tagStarCount
    local showIndex = 1
    for i=startStarCount, table.maxn(attrStringList) do
        local attrList = Utility.analysisStrFashionAttrList(attrStringList[i].currentAttr)
        local attrStrList = {}
        for _, v in pairs(attrList) do
            local tempStr = Utility.getRangeStr(v.range)
            tempStr = tempStr .. FightattrName[v.fightattr]
            tempStr = tempStr .. Enums.Color.eGreenH .. "+" .. tostring(v.value) .. Enums.Color.eNormalWhiteH
            table.insert(attrStrList, tempStr)
        end
        local introTempStr = table.concat(attrStrList, ", ")
        local lineStr = TR("所有%s侠谱%s%d星%s: %s", tagName, Enums.Color.eYellowH, i-1, Enums.Color.eNormalWhiteH, introTempStr)
        if i > 6 then
            lineStr = TR("所有%s侠谱%s%d月%s: %s", tagName, Enums.Color.eYellowH, i-6, Enums.Color.eNormalWhiteH, introTempStr)
        end
        if i == tagStarCount then
            lineStr = lineStr .. Enums.Color.eYellowH .. TR(" (已激活)")
        end
        -- 创建显示
        local text1 = ui.newLabel({
            text = lineStr,
            size = 24,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x30, 0x30, 0x30),
            dimensions = cc.size(440, 50),
        })
        
        -- 创建item
        local labelItem = ccui.Layout:create()
        local itemSize = cc.size(parentNode:getContentSize().width, text1:getContentSize().height+20)
        labelItem:setContentSize(itemSize)
        text1:setPosition(itemSize.width*0.5, itemSize.height*0.5)
        labelItem:addChild(text1)
        parentNode:pushBackCustomItem(labelItem)

        showIndex = showIndex + 1
    end
end

function IllustrateHomeLayer:showMasterLayer()
    self.masterSelectedTag = nil

    -- 号令群侠暂时不包括绝学
    local tmpTabConfig = {}
    for _,v in ipairs(self.tabConfigs) do
        if (v.tag ~= 4) then
            table.insert(tmpTabConfig, clone(v))
        end
    end
    local function msgDiyFunction(layer, layerBgSprite, layerSize)
        -- 黑色背景框
        local blackSize = cc.size(layerSize.width*0.9, (layerSize.height-230))
        local blackBg = ui.newScale9Sprite("c_38.png", blackSize)
        blackBg:setAnchorPoint(0.5, 0)
        blackBg:setPosition(layerSize.width/2, 100)
        layerBgSprite:addChild(blackBg)
        
        -- list空间
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setContentSize(cc.size(blackSize.width-10, blackSize.height-20))
        listView:setItemsMargin(5)
        listView:setGravity(ccui.ListViewGravity.centerHorizontal)
        listView:setAnchorPoint(cc.p(0.5, 0.5))
        listView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
        blackBg:addChild(listView)

        -- Tab列表
        local tabLayer = ui.newTabLayer({
            btnInfos = tmpTabConfig,
            viewSize = cc.size(515, 436),
            defaultSelectTag = self.masterSelectedTag,
            needLine = false,
            onSelectChange = function(tag)
                if (self.masterSelectedTag ~= tag) then
                    self.masterSelectedTag = tag
                    self:refreshMasterView(listView, self:readMasterList())
                end
            end,
        })
        tabLayer:setAnchorPoint(cc.p(0, 0))
        tabLayer:setPosition(cc.p(26, 543))
        layerBgSprite:addChild(tabLayer)
    end
    MsgBoxLayer.addDIYLayer({
        bgSize=cc.size(581, 685), 
        title=TR("号令群侠"), 
        closeBtnInfo={}, 
        DIYUiCallback = msgDiyFunction, 
        notNeedBlack=true
    })
end

----------------------------------------------------------------------------------------------------

return IllustrateHomeLayer
