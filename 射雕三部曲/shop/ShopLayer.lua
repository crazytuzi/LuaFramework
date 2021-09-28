--[[
    文件名：ShopLayer.lua
    文件描述：商城招募主页面
    创建人：chenzhong
    创建时间：2017.3.14
--]]

local ShopLayer = class("ShopLayer", function (params)
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为
    moduleSub: 模块ID， 定义在EnumsConfig.lua 的 ModuleSub中定义
]]
function ShopLayer:ctor(params)
    -- 当前显示子页面类型
    self.mSubPageType = params.moduleSub or ModuleSub.eHeroRecruit

    -- 屏蔽触摸事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)


    -- UI相关
    self:initUI()

    -- 包含顶部底部的公共layer
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType   = Enums.MainNav.eStore,
        topInfos = {
            ResourcetypeSub.eSTA,
            ResourcetypeSub.eGold,
            ResourcetypeSub.eDiamond
        }
    })
    self:addChild(self.mCommonLayer)

    -- 显示默认页面
    self:changePage()
end

-- 相关UI设置
function ShopLayer:initUI()
    -- 背景页面
    self.mBackSprite = ui.newSprite("sc_09.jpg")
    self.mBackSprite:setPosition(320, 568)
    self.mBackSize = self.mBackSprite:getContentSize()
    self.mParentLayer:addChild(self.mBackSprite)

    -- 为了避免人为设置zOrder,此处创建一个分页页面的父节点，位于tabView控件下层
    self.mContentLayer = cc.Layer:create()
    self.mContentLayer:setContentSize(cc.size(640, 1136))
    self.mBackSprite:addChild(self.mContentLayer)

    -- 创建分页
    self:showTabLayer()

    -- 返回按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function (sender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)
end

--------------------数据恢复-----------------------
function ShopLayer:getRestoreData()
    local retData = {
        moduleSub = self.mSubPageType
    }
    return retData
end

function ShopLayer:showTabLayer()
    -- 添加黑底
    local decBgSize = cc.size(640, 88)
    local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
    decBg:setPosition(cc.p(320, 1050))
    self.mParentLayer:addChild(decBg)

    -- 创建分页
    local buttonInfos = {
        {
            text = TR("招募"),
            tag = ModuleSub.eHeroRecruit,
            position = cc.p(70, 1042)
        },
        {
            text = TR("道具"),
            tag = ModuleSub.eStoreProps,
            position = cc.p(210, 1042)
        }
    }
    -- Vip按钮配置
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eStoreGiftBag) then
        table.insert(buttonInfos, {
            text = TR("VIP礼包"),
            tag = ModuleSub.eStoreGiftBag,
            position = cc.p(350, 1042)
        })
    end

    -- -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        needLine = false,
        btnSize = cc.size(135, 58),
        defaultSelectTag = self.mSubPageType,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mSubPageType == selectBtnTag then
                return
            end

            self.mSubPageType = selectBtnTag
            -- 切换子页面
            self:changePage()
        end
    })
    -- tabLayer:setAnchorPoint(0.5, 1)
    tabLayer:setPosition(cc.p(320, 1040))
    self.mParentLayer:addChild(tabLayer)

    -- 小红点逻辑
    for key, btnObj in pairs(tabLayer:getTabBtns() or {}) do
        local function dealRedDotVisible(redDotSprite)
            -- 招募的道具数量判断在RedDotInfoObj中自动进行
            local redDotData = RedDotInfoObj:isValid(key)
            redDotSprite:setVisible(redDotData)
        end

        -- 事件名(招募的道具变化事件在RedDotInfoObj中自动添加)
        ui.createAutoBubble({parent = btnObj, eventName = RedDotInfoObj:getEvents(key), refreshFunc = dealRedDotVisible})
    end

    -- 单独加下划线
    local lineSprite = ui.newScale9Sprite("sc_21.png", cc.size(640, 5))
    lineSprite:setPosition(320, 1008)
    self.mParentLayer:addChild(lineSprite)
end

-- 切换子页面
function ShopLayer:changePage()
    -- 删除原来的子页面
    self.mContentLayer:removeAllChildren()

    if self.mSubPageType == ModuleSub.eStoreProps then -- 道具
        local tempLayer = require("shop.PropLayer"):create()
        self.mContentLayer:addChild(tempLayer)
    elseif self.mSubPageType == ModuleSub.eHeroRecruit then -- 招募人物
        local tempLayer = require("shop.HeroRecruitLayer"):create({
            shopLayer = self,
        })
        self.mContentLayer:addChild(tempLayer)
    elseif self.mSubPageType == ModuleSub.eStoreGiftBag then -- VIP礼包
        local tempLayer = require("shop.VipGiftLayer"):create()
        self.mContentLayer:addChild(tempLayer)
    end
end

return ShopLayer
