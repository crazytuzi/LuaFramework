--[[
    文件名: BattleMainLayer.lua
    描述: 副本导航页面
    创建人: heguanghui
    创建时间: 2017-04-18
--]]

local BattleMainLayer = class("BattleMainLayer", function(params)
	return display.newLayer()
end)

--[[
-- 参数 params 中的各个字段为
    {
        subPageType: 子页面的类型, 取值为EnumsConfig.lua文件中ModuleSub的eBattleNormal、eBattleElite
        subPageData = {  -- 根据 subPageType 传入的值传入对应页面的参数
            [ModuleSub.eBattleNormal] = {  -- 打开普通副本页面的参数
                chapterId: -- 需要进入章节的章节模型Id
                NodeId: -- 要跳转的节点.有该参数时直接弹出出战窗
            },
            [ModuleSub.eBattleElite] = { -- 打开精英副本页面的参数
                -- Todo
            },
        }
    }
]]
function BattleMainLayer:ctor(params)
    params = params or {}
    -- 需要打开的子页面，默认打开普通副本
    self.mSubPageType = params.subPageType or ModuleSub.eBattleNormal
    -- 引导时自动切换到武林谱
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 10801 then
        self.mSubPageType = ModuleSub.eBattleElite
    end
    -- 需要打开页面的参数
    self.mSubPageData = params.subPageData or {}
    -- 当前打开的页面对象
    self.mCurrPageNode = nil

    -- 子页面的parent
    self.mSubParent = cc.Node:create()
    self:addChild(self.mSubParent)

	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

    -- 最底部导航按钮页面(因为底部导航按钮应该显示在最上面，所以需要最后 addChild)
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eDiamond, ResourcetypeSub.eGold},
        currentLayerType = Enums.MainNav.eBattle,
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

	-- 初始化页面控件
	self:initUI()
end

-- 获取恢复数据
function BattleMainLayer:getRestoreData()
    local retData = {
        subPageType = self.mSubPageType,
        subPageData = {
            [self.mSubPageType] = self.mCurrPageNode.getRestoreData and self.mCurrPageNode:getRestoreData()
        },
    }

    return retData
end

-- 初始化页面控件
function BattleMainLayer:initUI()
    -- 添加白底
    local whiteSprite = ui.newSprite("xfb_19.png")
    whiteSprite:setAnchorPoint(cc.p(0.5, 1))
    whiteSprite:setPosition(320, 1085)
    self.mParentLayer:addChild(whiteSprite)
    self.mTopParent = whiteSprite
    -- 刷新顶部按钮
    self:refreshTop()
    -- 刷新页面显示
    self:refreshPage()
    -- 添加黑底
    -- local decBgSize = cc.size(640, 97)
    -- local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
    -- decBg:setPosition(cc.p(320, 1043))
    -- self.mParentLayer:addChild(decBg)

    -- local tabBtnInfos = {
    --     {
    --         text = TR("江湖"),
    --         tag = ModuleSub.eBattleNormal,
    --     },
    --     {
    --         text = TR("武林谱"),
    --         tag = ModuleSub.eBattleElite,
    --     },
    -- }

    -- self.mTabView = require("common.TabView"):create({
    --     btnInfos = tabBtnInfos,
    --     needLine = true,
    --     defaultSelectTag = self.mSubPageType,
    --     viewSize = cc.size(640, 80),
    --     btnSize = cc.size(135, 58),
    --     space = 20,
    --     allowChangeCallback = function(btnTag)
    --         -- 判断服务器是否开启了该模块
    --         if not ModuleInfoObj:moduleIsOpenInServer(btnTag) then
    --             ui.showFlashView(TR("暂未开启"))
    --             return false
    --         end

    --         -- 判断是否达到开启等级
    --         return ModuleInfoObj:modulePlayerIsOpen(btnTag, true)
    --     end,

    --     onSelectChange = function(selBtnTag)
    --         if self.mSubPageType == selBtnTag then
    --             return
    --         end

    --         -- 缓存老页面的恢复数据
    --         if not tolua.isnull(self.mCurrPageNode) then
    --             self.mSubPageData[self.mSubPageType] = self.mCurrPageNode.getRestoreData and self.mCurrPageNode:getRestoreData()
    --         end

    --         self.mSubPageType = selBtnTag
    --         -- 切换页面
    --         self:refreshPage()
    --     end
    -- })
    -- self.mTabView:setAnchorPoint(cc.p(0.5, 0))
    -- self.mTabView:setPosition(320, 988)
    -- self.mParentLayer:addChild(self.mTabView)
    -- --
    -- self:refreshPage()

    -- -- 小红点逻辑
    -- for key, btnObj in pairs(self.mTabView:getTabBtns() or {}) do
    --     local function dealRedDotVisible(redDotSprite)
    --         local redDotData = RedDotInfoObj:isValid(key)
    --         redDotSprite:setVisible(redDotData)
    --     end
    --     -- 事件名
    --     ui.createAutoBubble({parent = btnObj, eventName = RedDotInfoObj:getEvents(key), refreshFunc = dealRedDotVisible})
    -- end
end

-- 刷新顶部按钮
function BattleMainLayer:refreshTop()
    self.mTopParent:removeAllChildren()

    local bgSize = self.mTopParent:getContentSize()

    local showPicList = {
        [ModuleSub.eBattleNormal] = "xfb_17.png",
        [ModuleSub.eBattleElite] = "xfb_15.png",
    }

    -- 显示当前选项
    local curSprite = ui.newSprite(showPicList[self.mSubPageType] or showPicList[ModuleSub.eBattleNormal])
    curSprite:setPosition(bgSize.width*0.5, 30)
    self.mTopParent:addChild(curSprite)
    -- 小红点逻辑
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(self.mSubPageType)
        redDotSprite:setVisible(redDotData)
    end
    -- 事件名
    ui.createAutoBubble({parent = curSprite, eventName = RedDotInfoObj:getEvents(self.mSubPageType), refreshFunc = dealRedDotVisible})
    -- 花边
    local curX, curY = curSprite:getPosition()
    local curSpriteSize = curSprite:getContentSize()
    local space = 15
    local leftSprite = ui.newSprite("xfb_18.png")
    local rightSprite = ui.newSprite("xfb_18.png")
    rightSprite:setRotation(180)

    leftSprite:setAnchorPoint(cc.p(1, 0.5))
    rightSprite:setAnchorPoint(cc.p(1, 0.5))

    leftSprite:setPosition(curX-(space + curSpriteSize.width*0.5), curY)
    rightSprite:setPosition(curX+(space + curSpriteSize.width*0.5), curY)

    self.mTopParent:addChild(leftSprite)
    self.mTopParent:addChild(rightSprite)

    -- 切换按钮
    local btnList = {
        -- 武林谱
        {
            normalImage = self.mSubPageType == ModuleSub.eBattleElite and "xfb_16.png" or "xfb_14.png",
            position = cc.p(bgSize.width*0.75, bgSize.height*0.75),
            moduldId = self.mSubPageType == ModuleSub.eBattleElite and ModuleSub.eBattleNormal or ModuleSub.eBattleElite,
        },
    }
    -- 创建按钮
    for _, btnInfo in pairs(btnList) do
        if not btnInfo.clickAction then
            btnInfo.clickAction = function ()
                -- 判断服务器是否开启了该模块
                if not ModuleInfoObj:moduleIsOpen(btnInfo.moduldId, true) then
                    return false
                end

                -- 缓存老页面的恢复数据
                if not tolua.isnull(self.mCurrPageNode) then
                    self.mSubPageData[self.mSubPageType] = self.mCurrPageNode.getRestoreData and self.mCurrPageNode:getRestoreData()
                end
                -- 刷新页标签
                self.mSubPageType = btnInfo.moduldId
                -- 刷新顶部
                self:refreshTop()
                -- 刷新显示页面
                self:refreshPage()
            end
        end

        local tempBtn = ui.newButton(btnInfo)
        self.mTopParent:addChild(tempBtn)

        -- 小红点逻辑
        local function dealRedDotVisible(redDotSprite)
            local redDotData = RedDotInfoObj:isValid(btnInfo.moduldId)
            redDotSprite:setVisible(redDotData)
        end
        -- 事件名
        ui.createAutoBubble({parent = tempBtn, eventName = RedDotInfoObj:getEvents(btnInfo.moduldId), refreshFunc = dealRedDotVisible})
    end

end

-- 刷新显示页面
function BattleMainLayer:refreshPage()
    -- 先删除原来的子页面
    if not tolua.isnull(self.mCurrPageNode) then
        self.mCurrPageNode:removeFromParent()
        self.mCurrPageNode = nil
    end

    local subPageData = self.mSubPageData[self.mSubPageType] or {}
    subPageData.parent = self
    if self.mSubPageType == ModuleSub.eBattleNormal then -- 江湖
        self.mCurrPageNode = require("battle.BattleNodeLayer"):create(subPageData)
        self.mSubParent:addChild(self.mCurrPageNode)
    elseif self.mSubPageType == ModuleSub.eBattleElite then -- 武林谱
        self.mCurrPageNode = require("battle.BattleEliteLayer"):create(subPageData)
        self.mSubParent:addChild(self.mCurrPageNode)
    end
end

-- 切换页面，供外部调用者使用
function BattleMainLayer:changePage(subPageType)
    if self.mTabView:activeTabBtnByTag(subPageType) then
        -- 缓存老页面的恢复数据
        if not tolua.isnull(self.mCurrPageNode) then
            self.mSubPageData[self.mSubPageType] = self.mCurrPageNode.getRestoreData and self.mCurrPageNode:getRestoreData()
        end

        self.mSubPageType = subPageType
        -- 切换页面
        self:refreshPage()
    end
end

return BattleMainLayer
