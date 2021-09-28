--[[
    SpecialVipLayer.lua
    描述: vip6弹窗页面
    创建人: yanghongsheng
    创建时间: 2017.8.7
-- ]]

local SpecialVipLayer = class("SpecialVipLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 200))
end)

--[[
    params:
        popType  -- 弹窗类型（默认nil, 1:领取会员奖励 2:去购买礼包）
]]

function SpecialVipLayer:ctor(params)
    self.popType = params.popType
    -- 屏蔽点击事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化
    self:setUI()
end

function SpecialVipLayer:setUI()
    --背景
    local bgSpriteTexture = "cz_17.png"
    if self.popType == 1 then
        bgSpriteTexture = "cz_21.png"
    elseif self.popType == 2 then
        bgSpriteTexture = "cz_22.png"
    end
    local bgSprite = ui.newSprite(bgSpriteTexture)
    bgSprite:setPosition(320, 650)
    self.mParentLayer:addChild(bgSprite)

    if self.popType == 1 then
        -- 领取按钮
        local goBtn = ui.newButton({
            text = TR("领取"),
            normalImage = "c_28.png",
            position = cc.p(320, 240),
            clickAction = function()
                self:requestGet()
                LayerManager.removeLayer(self)
            end
        })
        self.mParentLayer:addChild(goBtn)
    elseif self.popType == 2 then
        -- 判断是否还有可以购买的礼包
        self:requestShopGiftList()
        -- 去购买按钮
        local goBtn = ui.newButton({
            text = TR("去购买"),
            normalImage = "c_28.png",
            position = cc.p(320, 240),
            clickAction = function()
                LayerManager.removeLayer(self)
                LayerManager.showSubModule(ModuleSub.eStoreGiftBag, nil, true)
            end
        })
        self.mParentLayer:addChild(goBtn)
    else
        -- 确定按钮
        local goBtn = ui.newButton({
            text = TR("确定"),
            normalImage = "c_28.png",
            position = cc.p(320, 240),
            clickAction = function()
                LayerManager.removeLayer(self)
            end
        })
        self.mParentLayer:addChild(goBtn)
    end
end

-----------------服务器相关-----------------
-- 领取奖励
function SpecialVipLayer:requestGet()
    HttpClient:request({
        moduleName = "Player",
        methodName = "DrawTwelveReward",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            if response.Value then
                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            else
                ui.showFlashView({text = TR("已领取")})
            end
        end
    })
end

-- 请求服务器，获取各个Vip礼包的信息
function SpecialVipLayer:requestShopGiftList()
    HttpClient:request({
        moduleName = "ShopGift",
        methodName = "ShopGiftList",
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data or data.Status ~= 0 then
                return
            end

            for i, v in ipairs(data.Value) do
                -- 无购买次数限制 或 未达到最大购买次数的礼包
                if v.MaxNum <= 0 or v.MaxNum > v.Num then
                    -- 比玩家Vip等级高6级以下的礼包
                    if i <= PlayerAttrObj:getPlayerAttrByName("Vip") + 6 and v.MaxNum > v.Num then
                        return
                    end
                end
            end
            LayerManager.removeLayer(self)
        end
    })
end

return SpecialVipLayer