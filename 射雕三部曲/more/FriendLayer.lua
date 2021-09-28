--[[
    文件名: FriendLayer.lua
    描述：好友页面
    创建人：chenzhong
    创建时间：2016.06.15
    修改人：wukun
    修改时间：2016.08.30
--]]

local FriendLayer = class("FriendLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为
    pageType: 初始页面, 取值在 Enums.lua的 Enums.FriendPageType 中定义
]]
function FriendLayer:ctor(params)
    -- 当前显示子页面类型
    self.mSubPageType = params.pageType or Enums.FriendPageType.eList
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面控件的父对象
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 子页面控件的父对象
    self.mSubLayer = ui.newStdLayer()
    self:addChild(self.mSubLayer)

    -- 初始化页面控件
    self:initUI()
    -- 显示初始页面
    self:changePage()
end

-- 获取恢复该页面数据
function FriendLayer:getRestoreData()
    local retData = {}

    retData.pageType = self.mSubPageType
    --dump(retData,"retData:::")
    return retData
end

-- 初始化页面控件
function FriendLayer:initUI()
    -- 背景
    self.bgSprite = ui.newSprite("c_34.jpg")
    self.bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.bgSprite)

    -- 子背景
    -- local subBgSprite = ui.newScale9Sprite("c_124.png", cc.size(640, 125))
    -- subBgSprite:setAnchorPoint(cc.p(0.5, 1))
    -- subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, self.mParentLayer:getContentSize().height))
    -- self.mParentLayer:addChild(subBgSprite)

    local bottomBgSprite = ui.newScale9Sprite("c_19.png",cc.size(640, 990))
    bottomBgSprite:setAnchorPoint(0.5, 0)
    bottomBgSprite:setPosition(320, 10)
    self.mParentLayer:addChild(bottomBgSprite)

    self.mUnderBgSprite = ui.newScale9Sprite("c_17.png",cc.size(606, 780))
    self.mUnderBgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mUnderBgSprite)

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eSTA,  
            ResourcetypeSub.eDiamond, 
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)

    -- 创建分页
    self:showTabLayer()
    -- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)
end

-- 创建分页
function FriendLayer:showTabLayer()
    -- 创建分页
    local tabItms = {
        {
            text = TR("好友列表"),
            tag = Enums.FriendPageType.eList,
            --outlineSize = 2,
        },
        {
            text = TR("推荐好友"),
            tag = Enums.FriendPageType.eRecommend,
            --outlineSize = 2,
        },
        {
            text = TR("领取气力"),
            tag = Enums.FriendPageType.eGetSTA,
            --outlineSize = 2,
        },
    }

    -- 创建tablayer
    self.tableLayer = ui.newTabLayer({
        viewSize = cc.size(640, 80),
        btnInfos = tabItms,
        space = 20,
        defaultSelectTag = self.mSubPageType,
        onSelectChange = function (selectBtnTag)
            if selectBtnTag == self.mSubPageType then
                return 
            end
            self.mSubPageType = selectBtnTag
            -- 切换子页面
            self:changePage()
        end,
    })
    -- self.tableLayer:setAnchorPoint(cc.p(0, 1))
    self.tableLayer:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(self.tableLayer)

    -- 添加小红点
    local btn = self.tableLayer:getTabBtns()
    -- 小红点逻辑
    if btn then
        local function dealRedDotVisible(redDotSprite)
            local redDotData = RedDotInfoObj:isValid(ModuleSub.eFriendRewardSTA)
            redDotSprite:setVisible(redDotData)
        end
        ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(ModuleSub.eFriendRewardSTA), parent = btn[3]})
    end
end    

-- 切换子页面
function FriendLayer:changePage()
    -- 删除原来的子页面
    self.mSubLayer:removeAllChildren()
    if self.mSubPageType == Enums.FriendPageType.eList then             -- 好友列表
        local tempLayer = require("more.FriendListLayer").new()
        self.mSubLayer:addChild(tempLayer)
    elseif self.mSubPageType == Enums.FriendPageType.eRecommend then    -- 推荐好友
        local tempLayer = require("more.FriendRecommendLayer").new()
        self.mSubLayer:addChild(tempLayer)
    elseif self.mSubPageType == Enums.FriendPageType.eGetSTA then       -- 领取气力
        local tempLayer = require("more.FriendGetSTALayer").new()
        self.mSubLayer:addChild(tempLayer)
    end
end

return FriendLayer