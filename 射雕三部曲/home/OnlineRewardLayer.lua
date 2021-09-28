--[[
    文件名: OnlineRewardLayer.lua
    描述: 在线奖励页面
    创建人: liaoyuangang
    修改人：chenqiang
    创建时间: 2016.07.1
--]]

local OnlineRewardLayer = class("OnlineRewardLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为:
	{
		resourceList: 奖励列表
	}
]]
function OnlineRewardLayer:ctor(params)
	-- 奖励列表
	self.mResourceList = params.resourceList or {}

	-- 初始化页面
	self:initUI()
end

-- 初始化页面
function OnlineRewardLayer:initUI()
	local bgSize = cc.size(550, 380)
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("在线奖励"),
        bgSize = bgSize,
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    self.mBgSprite = bgLayer.mBgSprite

    -- 提示信息
    local hintLabel = ui.newLabel({
    	text = TR("在线时间越长，奖励越精彩哦～"),
        size = 27,
    	color = Enums.Color.eBlack,
    })
    hintLabel:setAnchorPoint(cc.p(0.5, 0.5))
    hintLabel:setPosition(bgSize.width / 2, bgSize.height*0.75)
    self.mBgSprite:addChild(hintLabel)

    -- 奖励列表的背景
    local tempSize = cc.size(527, 151)
    local tempSprite = ui.newScale9Sprite("mrjl_01.png", tempSize)
    tempSprite:setPosition(bgSize.width / 2, bgSize.height*0.47)
    self.mBgSprite:addChild(tempSprite)
    -- 创建奖励列表
    local cardListNode = ui.createCardList({
    	maxViewWidth = tempSize.width - 20,
    	cardDataList = self.mResourceList,
    	needArrows = true,
    })
    cardListNode:setAnchorPoint(cc.p(0.5, 0.5))
    cardListNode:setPosition(tempSize.width / 2, tempSize.height * 0.5)
    tempSprite:addChild(cardListNode)

    -- 确定按钮
    local okBtn = ui.newButton({
    	normalImage = "c_28.png",
    	text = TR("确定"),
    	clickAction = function()
    		LayerManager.removeLayer(self)
    	end
    })
    okBtn:setPosition(bgSize.width / 2, bgSize.height*0.15)
    self.mBgSprite:addChild(okBtn)
end

return OnlineRewardLayer
