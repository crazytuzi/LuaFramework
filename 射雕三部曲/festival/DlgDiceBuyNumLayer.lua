--[[
    文件名: DlgDiceBuyNumLayer.lua
    创建人: peiyaoqiang
    创建时间: 2017-09-24
    描述: 国庆活动——掷骰子——购买次数
--]]

local DlgDiceBuyNumLayer = class("DlgDiceBuyNumLayer", function()
    return display.newLayer()
end)

function DlgDiceBuyNumLayer:ctor(params)
    -- 读取参数
    self.callback = params.callback
    self.nowBuyCount = params.nowBuyCount   -- 今日已经购买的次数
    self.diceConfig = DiceConfig.items[1]

    -- 添加弹出框层
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(550, 340),
        title = TR("购买骰子"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 
    self:initUI()
end

-- 初始化页面控件
function DlgDiceBuyNumLayer:initUI()
    local listBgSprite = ui.newScale9Sprite("c_17.png", cc.size(self.mBgSize.width - 60, 165))
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(self.mBgSize.width * 0.5, 100)
    self.mBgSprite:addChild(listBgSprite)

    -- 提示文字
    local selectCount = 0
    local allNeedGold = 0
    local infoLabel = ui.newLabel({
        text = "",
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
    infoLabel:setPosition(self.mBgSize.width * 0.5, 220)
    infoLabel.refreshNum = function (target, newNum)
        -- (消耗=向上取整(当前次数/2)*基础消耗)
        allNeedGold = 0
        for i=1,newNum do
            allNeedGold = allNeedGold + (math.ceil((self.nowBuyCount + i)/2) * self.diceConfig.buyNumBaseUseNum)
        end
        target:setString(TR("是否要花费%s%d{db_1111.png}%s购买%s%d个%s骰子？", Enums.Color.eNormalGreenH, allNeedGold, "#46220D", Enums.Color.eNormalGreenH, newNum, "#46220D"))
        selectCount = newNum
    end
    infoLabel:refreshNum(1)
    self.mBgSprite:addChild(infoLabel)

    --选择数量控件
    local maxSelNum = self.diceConfig.buyNum - self.nowBuyCount
    local selectCountView = require("common.SelectCountView"):create({
        currSelCount = 1,
        maxCount = maxSelNum,
        viewSize = cc.size(480, 200),
        changeCallback = function(selCount)
            infoLabel:refreshNum(selCount)
        end
        })
    selectCountView:setPosition(self.mBgSize.width * 0.5, 150)
    self.mBgSprite:addChild(selectCountView)

    -- 选择按钮
    local btnOk = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        position = cc.p(self.mBgSize.width * 0.5, 60),
        clickAction = function()
            if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, allNeedGold, true) then
                return
            end
            -- 执行回调
            if (self.callback ~= nil) then
                self.callback(selectCount)
            end
            LayerManager.removeLayer(self)
        end
    })
    self.mBgSprite:addChild(btnOk)
end

return DlgDiceBuyNumLayer