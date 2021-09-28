--[[
    文件名: ActivityStartworkRewardLayer.lua
	描述: 开工红包页面, 模块Id为：ModuleSub.eStartworkReward
	效果图: 开工大礼.png
	创建人: yanghongsheng
	创建时间: 2017.3.11
--]]

local ActivityStartworkRewardLayer = class("ActivityStartworkRewardLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
]]
function ActivityStartworkRewardLayer:ctor(params)
	params = params or {}
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()
    --请求奖励预览
    self:requestStartworkRewardInfo()
end

-- 获取恢复数据
function ActivityStartworkRewardLayer:getRestoreData()
	
end

-- 初始化页面控件
function ActivityStartworkRewardLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("jc_05.jpg")
	bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(320,568)
    self.mParentLayer:addChild(bgSprite)
	self.mBgSprite = bgSprite

	-- 说明标签
    local describeLabel = ui.newLabel({
        text = TR("长老们出差了，各位道友礼拜一\n也许会有特殊收获哦!"),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x32, 0x0d, 0x04),
    })
    describeLabel:setPosition(400, 760)
    bgSprite:addChild(describeLabel)

    -- 元宝
    self.diamondCard = self:createRewardSprite({
        resourceTypeSub = ResourcetypeSub.eDiamond,
        num = 100,
        position = cc.p(225,390)
        })
    self.diamondCard:setVisible(false)

    -- 领取按钮
    self.mChargeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("摘取"),
        fontSize = 24,
        textColor = Enums.Color.eWhite,
        clickAction = function()
            if self.mWeek == 5 or self.mWeek == 6 or self.mWeek == 7 then
                -- 周五周六周日
                ui.showFlashView(TR("下周一后可领取开工红包,周一领取元宝双倍！"))
            else
                -- 领取奖励
                self:requestStartworkReward() 
            end
        end
    })
    self.mChargeBtn:setScale(1.2)
    self.mChargeBtn:setPosition(320, 220)
    bgSprite:addChild(self.mChargeBtn) 

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)
end

--[[
描述:生成红包图对象
参数:resourceTypeSub      资源类型
    num                  数量
    position             坐标 
]]
function ActivityStartworkRewardLayer:createRewardSprite(params)
    -- 资源卡
    local diamCard = CardNode.createCardNode({
                resourceTypeSub = params.resourceTypeSub,
                modelId = params.modelId or 0,
                num = params.num,
                cardShowAttrs = {CardShowAttr.eNum}
            })
    diamCard:setPosition(params.position)
    self.mBgSprite:addChild(diamCard)
    -- 资源名
    local name = Utility.getGoodsName(params.resourceTypeSub, params.modelId)
    local nameLabel = ui.newLabel({
            text = TR("%s", name),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x32, 0x0b, 0x04),
        })
    nameLabel:setAnchorPoint(cc.p(0.5, 0))
    nameLabel:setPosition(diamCard:getContentSize().width*0.5, -30)
    diamCard:addChild(nameLabel)
    -- 周一双倍
    local doubleSprite = ui.newScale9Sprite("jc_03.png")
    doubleSprite:setAnchorPoint(cc.p(0,1))
    doubleSprite:setPosition(3,diamCard:getContentSize().height-3)
    diamCard:addChild(doubleSprite)

    local doubleLabel = ui.newLabel({
        text = TR("周1双倍"),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0xea, 0x30, 0x0b),
        outlineSize = 1,
        size = 15,
        })
    doubleLabel:setAnchorPoint(cc.p(0,0))
    doubleLabel:setPosition(10,10)
    doubleLabel:setRotation(-45)
    doubleSprite:addChild(doubleLabel)

    return diamCard
end

--------------------------网络相关-----------------------------
-- 获取开工奖励配置
function ActivityStartworkRewardLayer:requestStartworkRewardInfo()
    HttpClient:request({
        moduleName = "StartworkReward",
        methodName = "GetStartworkRewardInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
            if not response.Value or response.Status ~= 0 then
                return
            end
            self.mWeek = response.Value.Week
            -- 设置元宝数量
            self.diamondCard:setVisible(true)
            self.diamondCard:setCardCount(response.Value.Diamond)
            -- 添加另一种资源
            local resource = response.Value.Resource[1]
            if not self.rewardCard then
                self.rewardCard = self:createRewardSprite({
                    resourceTypeSub = resource.ResourceTypeSub,
                    modelId = resource.ModelId,
                    num = resource.Count,
                    position = cc.p(380,422)
                })
            end
        end
    })
end
-- 获取开工奖励
function ActivityStartworkRewardLayer:requestStartworkReward()
    HttpClient:request({
        moduleName = "StartworkReward",
        methodName = "GetStartworkReward",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
        	if not response.Value or response.Status ~= 0 then
                return
            end

            --dump(response.Value, "领取到的奖励")
            
        	-- 显示奖励
        	ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            -- 领取之后不能再领取
            self.mChargeBtn:setEnabled(false)
        end
    })
end

return ActivityStartworkRewardLayer