--[[
	文件名:ZhenjueExtraLayer.lua
	描述：背包内功心法洗炼页面
	创建人: peiyaoqiang
	创建时间: 2017.04.05
--]]

local ZhenjueExtraLayer = class("ZhenjueExtraLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		zhenjueId: 内功心法实例Id
	}
]]
function ZhenjueExtraLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	-- 整理页面数据
	params = params or {}
	if not Utility.isEntityId(params.zhenjueId) then
		error("zhenjueId is not entityId")
		return 
	end
	-- 内功心法实体对象
	self.mZhenjueItem = ZhenjueObj:getZhenjue(params.zhenjueId)
	-- 该内功心法的模型
	self.mZhenjueModel = ZhenjueModel.items[self.mZhenjueItem.ModelId]

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 
	-- 初始化页面控件
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
end

-- 初始化页面控件
function ZhenjueExtraLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("ng_17.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 创建内功心法的大图片展示
	local figureNode = Figure.newZhenjue({
		modelId = self.mZhenjueItem.ModelId,
		needAction = true,
        viewSize = cc.size(640, 400)
	})
	figureNode:setAnchorPoint(cc.p(0.5, 1))
	figureNode:setPosition(320, 1050)
	self.mParentLayer:addChild(figureNode)

	-- 创建洗炼模块
	self.mExtraView = require("zhenjue.ZhenjueExtraView"):create({
	})
	self.mExtraView:setAnchorPoint(cc.p(0.5, 0))
	self.mExtraView:setPosition(320, 85)
	self.mParentLayer:addChild(self.mExtraView)
	self.mExtraView:changeZhenjue(self.mZhenjueItem)

	-- 关闭按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(585, 1000)
	self.mParentLayer:addChild(self.mCloseBtn)
end

return ZhenjueExtraLayer