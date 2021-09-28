--[[
    文件名：ZhenYuanTabLayer.lua
    描述：真元产出主页面（练气、气海、真元兑换）
    创建人：chenzhong
    创建时间：2017.12.14
--]]

local ZhenYuanTabLayer = class("ZhenYuanTabLayer", function (params)
    return display.newLayer()
end)

local TagList = {
    lianQiTag = 1,   -- 练气
    zhenYuanTag = 2, -- 真元
    qiHaiTag = 3     -- 气海
}
--[[
-- 参数 params 中的各项为
    moduleSub: 模块ID， 定义在EnumsConfig.lua 的 ModuleSub中定义
]]
function ZhenYuanTabLayer:ctor(params)
    -- 当前显示子页面类型
    self.mSubPageType = params.moduleSub or TagList.lianQiTag

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
            ResourcetypeSub.eHeroCoin,
            ResourcetypeSub.eGold,
            ResourcetypeSub.eDiamond
        }
    })
    self:addChild(self.mCommonLayer)

    -- 显示默认页面
    self:changePage()
end

-- 相关UI设置
function ZhenYuanTabLayer:initUI()
    -- 背景页面
    self.mBackSprite = ui.newSprite("zy_18.jpg")
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

    -- 规则
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        clickAction = function()
            local rule = {
                TR("1.练气从低到高分为心浮气躁、心平气和、心静如水、心无旁骛、物我两忘5种心境状态，心境状态越高，获得真元的品质越高。"),
                TR("2.每次练气需要花费神魂和铜币，不同状态练气花费的神魂和铜币不同。"),
                TR("3.点击一键收纳会将所有真元收纳到气海中。"),
                TR("4.点击一键聚气，高品质真元会直接吞噬低品质真元升级（如果真元品质相同，排序靠前的真元会吞噬排序靠后的所有真元）。"),
                TR("5.点击一键练气会直接获得大量真元，最高可获得30个真元，一键练气的花费最高等同于30次练气的花费。"),
                TR("6.花费200元宝点击心无旁骛，可以直接进入心无旁骛状态。"),
                TR("7.每次练气会获得修炼值，修炼值可以用于兑换真元。"),
            }
            MsgBoxLayer.addRuleHintLayer(TR("规则"), rule)
        end
    })
    ruleBtn:setPosition(514, 1040)
    self.mParentLayer:addChild(ruleBtn)
end

--------------------数据恢复-----------------------
function ZhenYuanTabLayer:getRestoreData()
    local retData = {
        moduleSub = self.mSubPageType
    }
    return retData
end

function ZhenYuanTabLayer:showTabLayer()
    -- 添加黑底
    local decBgSize = cc.size(640, 97)
    local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
    decBg:setPosition(cc.p(320, 1053))
    self.mParentLayer:addChild(decBg)

    -- 创建分页
    local buttonInfos = {
        {
            text = TR("练气"),
            tag = TagList.lianQiTag,
            position = cc.p(70, 1042)
        },
        {
            text = TR("真元"),
            tag = TagList.zhenYuanTag,
            position = cc.p(210, 1042)
        },
        {
            text = TR("气海"),
            tag = TagList.qiHaiTag,
            position = cc.p(350, 1042)
        }
    }

    -- -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        normalImage = "lt_05.png",
        lightedImage = "lt_04.png",
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
    tabLayer:setPosition(cc.p(320, 1040))
    self.mParentLayer:addChild(tabLayer)
end

-- 切换子页面
function ZhenYuanTabLayer:changePage()
    -- 删除原来的子页面
    self.mContentLayer:removeAllChildren()

    if self.mSubPageType == TagList.lianQiTag then -- 练气
        local tempLayer = require("zhenyuan.LianQiLayer"):create({parent = self})
        self.mContentLayer:addChild(tempLayer)
    elseif self.mSubPageType == TagList.zhenYuanTag then -- 真元
        local tempLayer = require("zhenyuan.ZhenYuanExchangeLayer"):create()
        self.mContentLayer:addChild(tempLayer)
    elseif self.mSubPageType == TagList.qiHaiTag then -- 气海
        local tempLayer = require("zhenyuan.ZhenYuanBagLayer"):create()
        self.mContentLayer:addChild(tempLayer)
    end
end

----------------- 新手引导 -------------------
-- 由子界面触发
function ZhenYuanTabLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向返回按钮
        [10014] = {clickNode = self.mCloseBtn},
    })
end

return ZhenYuanTabLayer
