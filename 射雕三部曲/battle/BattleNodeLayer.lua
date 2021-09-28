--[[
	文件名：BattleNormalLayer.lua
	描述：普通战斗页面(江湖)
	创建人：heguanghui
	创建时间：2017.04.18
--]]

local BattleNodeLayer = class("BattleNodeLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
-- initScrollPos: 大地图滚动的初始位置(比如点击结点返回时)
-- parent: 父Layer
-- nextChapterId: 从章节内返回时下一章ID
-- oldChapterId: 旧章节id
function BattleNodeLayer:ctor(params)
	-- 篇章列表
	self.mPageNodes = {}
    self.parent = params.parent

    -- 场景节点的parent
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 当前scrollview滚动位置
    self.initScrollPos = params.initScrollPos or nil
    -- 下一章id
    self.mNextChapterId = params.nextChapterId or nil
    -- 旧章节id
    self.mOldChapterId = params.nextChapterId and params.nextChapterId - 1 or nil
    -- 需要自动打开的章节
    self.gotoChapterId = params.chapterId
    self.mNodeId = params.nodeId

    -- 当前加载章节数量（防止卡顿）
    self.mLoadNum = 10  -- 初始加载10章

    -- 裁剪区中的控件列表
    self.mClippSubNodeList = {}
    -- 章节列表数据
    self.mChapterList = {}
    -- 请求宝箱数据
    self:requestGetInfo()
end

-- 初始化数据
function BattleNodeLayer:initUI()
    if self.mChapterNodeList and not tolua.isnull(self.mChapterNodeList) then
        return
    end
    -- 创建背景
    local bgSprite = ui.newScale9Sprite("xfb_04.png", cc.size(635, 1136))
    bgSprite:setPosition(320, 0)
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    self.mParentLayer:addChild(bgSprite)
    -- 创建顶部
    local topSprite = ui.newSprite("xfb_05.png")
    topSprite:setPosition(320, 1075)
    self.mParentLayer:addChild(topSprite)

    -- 创建章节列表
    self.mChapterNodeList = ccui.ListView:create()
    self.mChapterNodeList:setDirection(ccui.ScrollViewDir.vertical)
    -- self.mChapterNodeList:setBounceEnabled(true)
    self.mChapterNodeList:setContentSize(cc.size(640, 995))
    self.mChapterNodeList:setItemsMargin(5)
    self.mChapterNodeList:setAnchorPoint(cc.p(0.5, 1))
    self.mChapterNodeList:setPosition(320, 1064)
    self.mParentLayer:addChild(self.mChapterNodeList)

    -- 获取通关章节信息
    BattleObj:getAllChapterInfo(function(chapterList)
        -- 章节列表数据
        self.mChapterList = chapterList or {}
        -- 获取战役信息
        self.mBattleInfo = BattleObj:getBattleInfo() or {}
        self.mNodeInfo = BattleObj:getChapterList() or {}
        -- 最大章节id
        local chapterId = self.mBattleInfo.MaxChapterId or 11
        -- 宝箱节点
        self.mBoxtipList = {}
        -- 保存当前战斗的结点
        self.curChapterId = chapterId

        -- 刷新列表
        self:refreshChapterList()

        -- 创建操作按钮
        self:createOperateBtn()

        -- 新手引导时自动跳转到当前章节
        Utility.performWithDelay(self.mChapterNodeList, handler(self, self.executeGuide), 0.1)
    end)
end

function BattleNodeLayer:refreshChapterList()
    -- 对列表排序
    local chapterList = {}
    for _, chapterInfo in pairs(self.mChapterList) do
        table.insert(chapterList, chapterInfo)
    end
    table.sort(chapterList, function (item1, item2)
        -- 按章节从大到小排序
        return item1.ChapterModelId > item2.ChapterModelId
    end)
    -- 所以章节id列表
    local allChapterIdList = table.keys(BattleChapterModel.items)
    table.sort(allChapterIdList, function (chapterId1, chapterId2)
        return chapterId1 < chapterId2
    end)
    -- 清空列表
    self.mChapterNodeList:removeAllChildren()

    -- 添加一个未开放的章节
    if allChapterIdList[#chapterList+1] then
        local chapterModel = BattleChapterModel.items[allChapterIdList[#chapterList+1]]
        local lvItem = self:createUnlockChapter(chapterModel)
        self.mChapterNodeList:pushBackCustomItem(lvItem)
    end
    -- 需要移动
    if self.initScrollPos then
        -- 填充列表
        for index, chapterInfo in ipairs(chapterList) do
            local lvItem = self:createChapterItem(chapterInfo)
            self.mChapterNodeList:pushBackCustomItem(lvItem)
        end

        -- 移动到记录位置
        Utility.performWithDelay(self.mChapterNodeList, function()
            self.mChapterNodeList:setInnerContainerPosition(self.initScrollPos)
        end,0.01)
    else
        -- 填充列表
        for i = 1, self.mLoadNum-1 do
            if chapterList[i] then
                local lvItem = self:createChapterItem(chapterList[i])
                self.mChapterNodeList:pushBackCustomItem(lvItem)
            end
        end

        -- 延时加载其他项
        Utility.performWithDelay(self.mChapterNodeList, function()
            for i = self.mLoadNum, #chapterList do
                if chapterList[i] then
                    local lvItem = self:createChapterItem(chapterList[i])
                    self.mChapterNodeList:pushBackCustomItem(lvItem)
                end
            end
        end,0.01)
    end

    -- dump(self.mChapterIdList, "宝箱")
    -- -- 宝箱
    -- self.mBoxtipList = {}
    -- for i,v in ipairs(self.mChapterIdList) do
    --     local boxTipSprite = ui.newButton({
    --         normalImage = "xfb_20.png",
    --         clickAction = function(pSender)
    --             self:requestOneKeyDrawBoxs(v)
    --         end
    --         })
    --     boxTipSprite:setPosition(550, 150)
    --     self.mClippSubNodeList[v]:addChild(boxTipSprite)
    --     boxTipSprite:setPressedActionEnabled(false)
    --     self.mBoxtipList[v] = boxTipSprite
    -- end
end

function BattleNodeLayer:createChapterItem(chapterInfo)
    local cellSize = cc.size(self.mChapterNodeList:getContentSize().width, 290)
    local layout = ccui.Layout:create()
    layout:setContentSize(cellSize)

    -- 表中数据
    local chapterModel = BattleChapterModel.items[chapterInfo.ChapterModelId]

    -- 背景按钮
    local bgBtn = ui.newButton({
        normalImage = self:getCellBgPic(chapterInfo.ChapterModelId),
        clickAction = function ()
            -- 当前跳转的章
            LayerManager.addLayer({
                name = "battle.BattleNormalNodeLayer",
                data = {chapterId = chapterInfo.ChapterModelId},
                cleanUp = true
            })
        end,
    })
    bgBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
    layout:addChild(bgBtn)

    -- 保存按钮，新手引导用
    self.mClippSubNodeList[chapterInfo.ChapterModelId] = bgBtn

    -- 章节名
    local nameBg = ui.newSprite("xfb_01.png")
    nameBg:setAnchorPoint(cc.p(0.5, 1))
    nameBg:setPosition(cellSize.width*0.1, cellSize.height)
    layout:addChild(nameBg)

    local nameLabel = ui.newLabel({
        text = chapterModel.name,
        size = 20,
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x14, 0x12, 0x16),
        dimensions = cc.size(30, 0),
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    })
    nameLabel:setPosition(nameBg:getContentSize().width*0.5, nameBg:getContentSize().height*0.4)
    nameBg:addChild(nameLabel)

    -- 是否过关
    if chapterInfo.IfPass then
        local passTagSprite = ui.newSprite("xfb_03.png")
        passTagSprite:setPosition(cellSize.width*0.9, cellSize.height*0.2)
        layout:addChild(passTagSprite)
        if chapterInfo.StarCount >= chapterModel.starCount then
            passTagSprite:setTexture("xfb_02.png")
        end
    end

    if chapterInfo.ChapterModelId > self.curChapterId then
        bgBtn:setClickAction(function ()
            local curLv = PlayerAttrObj:getPlayerAttrByName("Lv")
            if BattleChapterModel.items[chapterInfo.ChapterModelId].needLV > curLv then
                ui.showFlashView(TR("%d级开启本章节", BattleChapterModel.items[chapterInfo.ChapterModelId].needLV))
            else
                ui.showFlashView(TR("开启需通关前一章节"))
            end
        end)
    end

    -- 宝箱
    if self.mChapterIdList[chapterInfo.ChapterModelId] then
        local boxTipSprite = ui.newButton({
            normalImage = "xfb_20.png",
            clickAction = function(pSender)
                self:requestOneKeyDrawBoxs(chapterInfo.ChapterModelId)
            end
            })
        boxTipSprite:setPosition(550, 150)
        layout:addChild(boxTipSprite)
        self.mBoxtipList[chapterInfo.ChapterModelId] = boxTipSprite
    end 

    -- ui.newEffect({
    --     parent = layout,
    --     effectName = "effect_ui_fubentishi",
    --     animation = "texiao",
    --     position = cc.p(cellSize.width*0.5, cellSize.height*0.3),
    --     loop = true,
    --     endRelease = true,
    -- })

    -- 当前战斗的章节
    if chapterInfo.ChapterModelId == self.curChapterId then
        ui.newEffect({
            parent = layout,
            effectName = "effect_ui_fubentishi",
            animation = "texiao",
            position = cc.p(cellSize.width*0.5, cellSize.height*0.3),
            loop = true,
            endRelease = true,
        })

        -- 20级以下添加手指效果
        local curLv = PlayerAttrObj:getPlayerAttrByName("Lv")
        local _, _, eventID = Guide.manager:getGuideInfo()
        if curLv < 20 and not eventID then
            local navSize = bgBtn:getContentSize()
            -- 点击提示光圈和手指
            ui.addGuideArrowEffect(bgBtn, cc.p(navSize.width/2, navSize.height/2))
        end
    end

    return layout
end

function BattleNodeLayer:createUnlockChapter(chapterModel)
    local cellSize = cc.size(self.mChapterNodeList:getContentSize().width, 290)
    local layout = ccui.Layout:create()
    layout:setContentSize(cellSize)


    -- 背景按钮
    local bgBtn = ui.newButton({
        normalImage = self:getCellBgPic(chapterModel.ID),
        clickAction = function ()
            -- 提示
            local curLv = PlayerAttrObj:getPlayerAttrByName("Lv")
            if BattleChapterModel.items[chapterModel.ID].needLV > curLv then
                ui.showFlashView(TR("%d级开启本章节", BattleChapterModel.items[chapterModel.ID].needLV))
            else
                ui.showFlashView(TR("开启需通关前一章节"))
            end
        end,
    })
    bgBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
    layout:addChild(bgBtn)
    -- bgBtn:setBright(false)

    -- 章节名
    local nameBg = ui.newSprite("xfb_01.png")
    nameBg:setAnchorPoint(cc.p(0.5, 1))
    nameBg:setPosition(cellSize.width*0.1, cellSize.height)
    layout:addChild(nameBg)

    local nameLabel = ui.newLabel({
        text = chapterModel.name,
        size = 20,
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x14, 0x12, 0x16),
        dimensions = cc.size(30, 0),
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    })
    nameLabel:setPosition(nameBg:getContentSize().width*0.5, nameBg:getContentSize().height*0.4)
    nameBg:addChild(nameLabel)

    return layout
end

function BattleNodeLayer:getCellBgPic(ChapterModelId)
    -- 图片列表
    local picList = {
        "xfb_06.png",   
        "xfb_07.png",   
        "xfb_08.png",   
        "xfb_09.png",   
        "xfb_10.png",   
        "xfb_11.png",   
        "xfb_12.png",   
        "xfb_13.png",   
    }
    local picNum = ((ChapterModelId-1) % #picList) + 1
    local picName = picList[picNum] or picList[1]

    return picName
end

-- 保存页面数据
function BattleNodeLayer:getRestoreData()
	local ret = {}
	ret.initScrollPos = self.mChapterNodeList:getInnerContainerPosition()
    ret.oldChapterId = self.curChapterId
	return ret
end

-- 创建操作按钮
function BattleNodeLayer:createOperateBtn()
    self.operateBtnList = {}
	local btnInfos = {
		{  -- 挂机
            normalImage = "tb_115.png",
            moduleId = ModuleSub.eBattleAutomatic,
            clickAction = function ()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eBattleAutomatic, true) then
                    return
                end

                LayerManager.addLayer({
                    name = "battle.AutoFightLayer",
                    cleanUp = false,

                })
            end
        },
        {  -- 扫荡
            normalImage = "tb_41.png",
            moduleId = ModuleSub.eBattleForTen,
            clickAction = function ()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eBattleForTen, true) then
                    return
                end

                LayerManager.addLayer({
                    name = "battle.ConFightLayer",
                    cleanUp = true,
                })
            end
        }
	}

	local tempSpace = 120
    local tempPosX, tempPosY = 580, 280
    for _, btnInfo in ipairs(btnInfos) do
        -- 没有模块Id 或 该模块已开启
        if not btnInfo.moduleId or ModuleInfoObj:moduleIsOpenInServer(btnInfo.moduleId) then
            local tempBtn = ui.newButton(btnInfo)
            tempBtn:setPosition(tempPosX, tempPosY)
            self.mParentLayer:addChild(tempBtn)
            -- 保存挂机按钮
            table.insert(self.operateBtnList, tempBtn)

            local tempVisible = true
            if tempVisible then
                tempPosY = tempPosY - tempSpace
            end

            -- 小红点逻辑
            if btnInfo.moduleId then
                local function dealRedDotVisible(redDotSprite)
                    local redDotData = RedDotInfoObj:isValid(btnInfo.moduleId)
                    redDotSprite:setVisible(redDotData)
                end
                ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(btnInfo.moduleId), parent = tempBtn})
            end

            -- 挂机按钮加特效
            if btnInfo.moduleId and btnInfo.moduleId == ModuleSub.eBattleAutomatic then
                ui.newEffect({
                    parent = tempBtn,
                    effectName = "effect_ui_guajitubiao",
                    position = cc.p(tempBtn:getContentSize().width / 2, tempBtn:getContentSize().height / 2),
                    loop = true,
                    endRelease = true
                })
            end
        end
    end
end

-- 创建一键领取按钮
function BattleNodeLayer:createOneKeyBtn()
    local oneKeyBoxBtn = ui.newButton({
        normalImage = "tb_157.png",
        clickAction = function ()
            self:showOneKeyBoxView()
        end
        })
    oneKeyBoxBtn:setPosition(580, 400)
    self.mParentLayer:addChild(oneKeyBoxBtn)
    oneKeyBoxBtn:setVisible(false)

    self.mOneKeyBoxBtn = oneKeyBoxBtn

    if table.maxn(self.mBoxList) ~= 0 then
        oneKeyBoxBtn:setVisible(true)
        local reddot = ui.createBubble({
            position = cc.p(90, 90)
            })
        oneKeyBoxBtn:addChild(reddot)
    end

end

-- 一键领取弹窗
function BattleNodeLayer:showOneKeyBoxView()
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(544, 709),
        title = TR("章节宝箱"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

    local boxListView = ccui.ListView:create()
    boxListView:setDirection(ccui.ScrollViewDir.vertical)
    boxListView:setBounceEnabled(true)
    boxListView:setContentSize(cc.size(495, 550))
    boxListView:setGravity(ccui.ListViewGravity.centerVertical)
    boxListView:setAnchorPoint(cc.p(0.5, 1))
    boxListView:setPosition(270, 650)
    self.mPopBgSprite:addChild(boxListView)
    self.ListView = boxListView

    local function createCell(index)
        local height = 95
        local width = 495
        local info = self.mBoxList[index]
        local starBoxNum = table.maxn(info.starBoxList)
        if starBoxNum > 0 then
            height = height + starBoxNum * 175
        end

        local layout = ccui.Layout:create()
        layout:setContentSize(width, height)

        local greyBgSprite = ui.newScale9Sprite("c_17.png", cc.size(width - 20, height - 20))
        greyBgSprite:setPosition(width / 2, height / 2)
        layout:addChild(greyBgSprite)

        local chapterName = BattleChapterModel.items[info.chapterModelId].name
        local chapterNameLabel = ui.createSpriteAndLabel({
            imgName = "c_25.png",
            scale9Size = cc.size(300, 54),
            labelStr = TR("第%d章  %s",info.chapterModelId - 10, chapterName),
            fontColor = Enums.Color.eNormalWhite,
            fontSize = 22,
            outlineColor = cc.c3b(0x82, 0x49, 0x36),
            outlineSize = 2,
        })
        chapterNameLabel:setPosition(width / 2, height - 40)
        layout:addChild(chapterNameLabel)
        --星数宝箱
        local offsetY = height - 160
        for i = 1, starBoxNum do
            local starBoxId = info.starBoxList[i]
            local boxInfo = BattleChapterBoxRelation.items[starBoxId]
            local rewardData = Utility.analysisStrResList(boxInfo.outputResource)

            -- 超级QQ会员有元宝加成
            if PlayerAttrObj:getPlayerAttrByName("LoginType") == 2 then
                for _, resInfo in pairs(rewardData) do
                    if resInfo.resourceTypeSub == ResourcetypeSub.eDiamond then
                        resInfo.num = resInfo.num + math.floor(resInfo.num*0.2)
                        break
                    end
                end
            end

            local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(460, 170))
            bgSprite:setPosition(248, offsetY)
            layout:addChild(bgSprite)
            local bgSize = bgSprite:getContentSize()

            local boxName = boxInfo.boxName
            local nameLabel = ui.newLabel({
                text = boxName,
                color = cc.c3b(0xd7, 0x59, 0x1d),
                size = 23,
                })
            nameLabel:setPosition(bgSize.width / 2, bgSize.height - 20)
            bgSprite:addChild(nameLabel)

            local cardList = ui.createCardList({
                maxViewWidth = 440,
                viewHeight = 120,
                space = 10,
                cardDataList = rewardData,
                })
            cardList:setPosition(10, 10)
            bgSprite:addChild(cardList)
            offsetY = offsetY - 175
        end

        return layout
    end

    for i = 1, #self.mBoxList do
        self.ListView:pushBackCustomItem(createCell(i))
    end

    local oneKeyGetBox = ui.newButton({
        text = TR("一键领取"),
        normalImage = "c_33.png",
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x18, 0x7e, 0x6d),
        clickAction = function ()
            self:requestOneKeyDrawBoxs()
        end
        })
    oneKeyGetBox:setPosition(272, 55)
    self.mPopBgSprite:addChild(oneKeyGetBox)
end

--处理宝箱数据
function BattleNodeLayer:handldData()
    local boxList = {}
    local chapterIdList = {}
    for index, v in pairs(self.mChapterData) do
        local chapterInfo = BattleChapterModel.items[v.ChapterModelId]
        local i = index - 10
        boxList[i] = {}
        boxList[i].starBoxList = {}
        boxList[i].chapterModelId = v.ChapterModelId
        if not v.IfDrawBoxA and v.StarCount >= chapterInfo.boxANeedStar and chapterInfo.boxANeedStar ~= 0 then
            table.insert(boxList[i].starBoxList, chapterInfo.boxAID)
        end
        if not v.IfDrawBoxB and v.StarCount >= chapterInfo.boxBNeedStar and chapterInfo.boxBNeedStar ~= 0 then
            table.insert(boxList[i].starBoxList, chapterInfo.boxBID)

        end
        if not v.IfDrawBoxC and v.StarCount >= chapterInfo.boxCNeedStar and chapterInfo.boxCNeedStar ~= 0 then
            table.insert(boxList[i].starBoxList, chapterInfo.boxCID)
        end
    end

    for i = #boxList, 1, -1 do
        if table.maxn(boxList[i].starBoxList) == 0 then
            table.remove(boxList, i)
        end
    end
    table.sort(boxList, function(a, b)
        if a.chapterModelId ~= b.chapterModelId then
            return a.chapterModelId < b.chapterModelId
        end
    end)
    for i,v in ipairs(boxList) do
        -- table.insert(chapterIdList, v.chapterModelId)
        chapterIdList[v.chapterModelId] = true
    end
    self.mBoxList = boxList
    self.mChapterIdList = chapterIdList
end
-- ========================== 网络相关 ===========================
-- 获取信息
function BattleNodeLayer:requestGetInfo()
    local battleInfo = clone(BattleObj:getChapterList(function (data)
        if not tolua.isnull(self) then
            self.mChapterData = data
            self:handldData()
            self:initUI()

            self:createOneKeyBtn()

            -- 自动进入新章节
            if (self.gotoChapterId ~= nil) then
                Utility.performWithDelay(self.mChapterNodeList, function ()
                    LayerManager.addLayer({
                        name = "battle.BattleNormalNodeLayer", 
                        data = {chapterId = self.gotoChapterId, nodeId = self.mNodeId}, 
                        cleanUp = true,
                    })
                end, 0.1)
            end
        end
    end))
    -- HttpClient:request({
    --     svrType = HttpSvrType.eGame,
    --     moduleName = "Battle",
    --     methodName = "GetBattleInfo",
    --     svrMethodData = {false, true},
    --     callback = function(response)
    --         if not response or response.Status ~= 0 then
    --             return
    --         end
    --         dump(response.Value.ChapterList)
    --         if not tolua.isnull(self) then
    --             self.mChapterData = response.Value.ChapterList
    --             self:handldData()
    --             self:initData()

    --             self:createOneKeyBtn()
    --         end
    --     end
    -- })
end

-- 一键领取
function BattleNodeLayer:requestOneKeyDrawBoxs(singleChapter)
    local idList = {}
    if singleChapter then
        idList = {singleChapter}
    else
        for key, isBox in pairs(self.mChapterIdList) do
            if isBox then
                table.insert(idList, key)
            end
        end
    end
    BattleObj:requestOneKeyDrawBoxs(idList, function(response)
        if not response or response.Status ~= 0 then
            return
        end
         -- 提示得到的物品
        if singleChapter then
            -- self.mBoxtipList[singleChapter]:stopAllActions()
            self.mBoxtipList[singleChapter]:removeFromParent()
            self.mBoxtipList[singleChapter] = nil
            self.mChapterIdList[singleChapter] = nil

            self.mOneKeyBoxBtn:removeFromParent()
            self.mOneKeyBoxBtn = nil
            self:requestGetInfo()
        else
            LayerManager.removeLayer(self.mPopLayer)
            self.mOneKeyBoxBtn:setVisible(false)
            self.mChapterIdList = {}
            for k, v in pairs(self.mBoxtipList) do
                v:stopAllActions()
                v:removeFromParent()
                v = nil
            end
        end
        ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true)
    end)
end

-- ========================== 新手引导 ===========================

-- 执行新手引导
function BattleNodeLayer:executeGuide()
    -- 记录是否正在新手引导中
    local _, _, eventId = Guide.manager:getGuideInfo()
    local gotoList = clone(Guide.config.battleEvent)
    table.insert(gotoList, 1020001) -- 获取洪凌波
    if table.indexof(gotoList, eventId) then
        Utility.performWithDelay(self.mChapterNodeList, function ()
            LayerManager.addLayer({
                name = "battle.BattleNormalNodeLayer",
                data = {},
                cleanUp = true
            })
        end, 0)
    else
        Guide.helper:executeGuide({
            -- 箭头指向队伍界面(第一章打完后)
            [10301] = {clickNode = self.parent.mCommonLayer_:getNavBtnObj(Enums.MainNav.eFormation)},
            -- 第向第二章节节点
            [10406] = {clickNode = self.mClippSubNodeList[self.curChapterId]},
            -- 自动战斗(挂向挂机)
            [1202] = {clickNode = self.operateBtnList[1]},
        })
    end
end

return BattleNodeLayer
