--[[
    文件名: AutoFightLayer.lua
    创建人: liaoyuangang
    创建时间: 2016-05-27
    描述: 挂机战斗提示确认页面
--]]

local AutoFightLayer = class("AutoFightLayer", function()
    return display.newLayer()
end)

function AutoFightLayer:ctor()
    -- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

    self.mGoodsModelId = 16030006  -- 体力丹模型Id
    local tempModel = GoodsModel.items[self.mGoodsModelId]
    self.mGoodsName = tempModel.name -- 体力丹名称
    self.mGoodsImg = Utility.getDaibiImage(tempModel.typeID, self.mGoodsModelId) -- 体力丹代币图片
    self.mGoodsBuyInfo = {}
    
    -- 添加弹出框层
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 474),
        title = TR("挂机战斗"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 初始化页面控件
    self:initUI()
    --
    self:requestGetShopGoodsInfo()
end

-- 初始化页面控件
function AutoFightLayer:initUI()
    -- 添加背景
    local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(540, 240))
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    bgSprite:setPosition(self.mBgSize.width * 0.5, 120)
    self.mBgSprite:addChild(bgSprite)

    -- 提示信息
    local hintLabel = ui.newLabel({
        text = TR("自动战斗开始，系统将自动挑战未战胜的节点"),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    hintLabel:setPosition(cc.p(self.mBgSize.width * 0.5, self.mBgSize.height - 90))
    self.mBgSprite:addChild(hintLabel)

    -- 创建显示信息
    local function showInfoLabel(posY, strText, btnTitle, btnFunc)
        local tempBgSprite = ui.newScale9Sprite("c_24.png", cc.size(345, 46))
        tempBgSprite:setAnchorPoint(cc.p(0, 0.5))
        tempBgSprite:setPosition(30, posY)
        bgSprite:addChild(tempBgSprite)

        -- 描述文字
        local label = ui.newLabel({
            text = strText,
            color = cc.c3b(0x59, 0x28, 0x17),
        })
        label:setAnchorPoint(cc.p(0, 0.5))
        label:setPosition(20, 23)
        tempBgSprite:addChild(label)

        -- 操作按钮
        if btnTitle and btnFunc then
            local button = ui.newButton({
                normalImage = "c_28.png",
                text = btnTitle,
                clickAction = btnFunc,
            })
            button:setPosition(450, posY)
            bgSprite:addChild(button)
        end

        return label
    end
    self.mVitUseLabel = showInfoLabel(190, TR("#592817当前%s#b2e283{%s}%d", self.mGoodsName, self.mGoodsImg, 0), TR("使用"), function ()
            local tempCount = GoodsObj:getCountByModelId(self.mGoodsModelId)
            if tempCount == 0 then
                ui.showFlashView(TR("没有剩余的%s了", self.mGoodsName))
                return
            end

            self:requestUseVitPellet()
        end)
    self.mVitBuyLabel = showInfoLabel(120, TR("购买%s#b2e283{%s}/{%s}%d", self.mGoodsName, self.mGoodsImg, "", 0), TR("购买"), function ()
            self:requestBuyVitPellet()
        end)
    self.mCurVitLabel = showInfoLabel(50, TR("当前体力值: #ffe748%d", PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT)))

    -- 启动挂机按钮
    local startBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("开始"),
        clickAction = function()
            if not Utility.isResourceEnough(ResourcetypeSub.eVIT, 5, true) then
                return
            end
            if not Utility.checkBagSpace() then
                return
            end
            -- 每次进入自动战斗前需要重置之前自动战斗的结果信息
            AutoFightObj:resetFailedNode(true)

            -- 自动战斗
            AutoFightObj:getNextNode(function(chapterId, nodeId, starLv)
                if not chapterId then
                    ui.showFlashView(TR("没有可自动挑战的关卡"))
                else
                    AutoFightObj:setAutoFight(true)

                    --[[--------新手引导--------]]--
                    local guideID, ordinal, eventID = Guide.manager:getGuideInfo()
                    local recordInfo = nil
                    if eventID == 1203 then
                        recordInfo = Guide.manager:makeExtentionData(guideID, ordinal + 1)
                    end
                    BattleObj:requestFightInfo(chapterId, nodeId, starLv, recordInfo, nil, function(response)
                        if not response or response.Status ~= 0 then
                            return
                        end
                        --[[--------新手引导--------]]--
                        local guideID, ordinal, eventID = Guide.manager:getGuideInfo()
                        if eventID == 1203 then
                            Guide.manager:removeGuideLayer()
                            Guide.manager:nextStep(eventID)
                        end
                    end)
                end
            end)
        end,
    })
    startBtn:setPosition(self.mBgSize.width / 2, 70)
    self.mBgSprite:addChild(startBtn)
    -- 保存按钮，引导使用
    self.startBtn = startBtn
end

-- 刷新页面显示信息
function AutoFightLayer:refreshLayer()
    -- 设置当前拥有体力丹
    local tempCount = GoodsObj:getCountByModelId(self.mGoodsModelId)
    self.mVitUseLabel:setString(TR("当前%s#b2e283{%s}%d", self.mGoodsName, self.mGoodsImg, tempCount))

    -- 设置购买体力丹信息
    local diamondImg = Utility.getDaibiImage(ResourcetypeSub.eDiamond) 
    self.mVitBuyLabel:setString(TR("购买%s#b2e283{%s}/{%s}%d", self.mGoodsName, self.mGoodsImg, diamondImg, self.mGoodsBuyInfo.CurrPrice or 0))

    -- 设置体力信息
    self.mCurVitLabel:setString(TR("当前体力值: #ffe748%d", PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT)))
end

-- ======================= 网络请求相关函数 =================

-- 获取道具购买信息服务器接口请求
function AutoFightLayer:requestGetShopGoodsInfo()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ShopGoods",
        methodName = "GetShopGoodsInfo",
        svrMethodData = {self.mGoodsModelId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            local value = response.Value
            self.mGoodsBuyInfo = value[1]

            -- 刷新页面显示信息
            self:refreshLayer()
        end
    })
end

-- 使用道具服务器接口请求
function AutoFightLayer:requestUseVitPellet()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {EMPTY_ENTITY_ID, self.mGoodsModelId, 1},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 刷新页面显示信息
            self:refreshLayer()
        end
    })
end

-- 购买道具服务器接口请求
function AutoFightLayer:requestBuyVitPellet()
    if self.mGoodsBuyInfo.Num >= self.mGoodsBuyInfo.MaxNum then
        ui.showFlashView(TR("今天购买数量已达到上限，请明日再来！"))
        return
    end

    --元宝不足
    if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, self.mGoodsBuyInfo.CurrPrice, true) then
        return
    end

    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ShopGoods",
        methodName="BuyGoods",
        svrMethodData = {self.mGoodsModelId, 1},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            local value = response.Value
            self.mGoodsBuyInfo.Num = value.Num
            self.mGoodsBuyInfo.CurrPrice = value.CurrPrice

            -- 刷新页面显示信息
            self:refreshLayer()
            --
            ui.showFlashView(TR("购买成功"))
        end
    })
end

-- ========================== 新手引导 ===========================
function AutoFightLayer:onEnterTransitionFinish()
    Utility.performWithDelay(self.mBgSprite, handler(self, self.executeGuide), 0.25)
end

-- 执行新手引导
function AutoFightLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向开始
        [1203] = {clickNode = self.startBtn, hintPos = cc.p(display.cx, 150 * Adapter.MinScale), },
    })
end

return AutoFightLayer