--[[
	文件名：FashionHomeLayer.lua
	描述：时装页面
	创建人: peiyaoqiang
	创建时间: 2017.09.15
--]]

local FashionHomeLayer = class("FashionHomeLayer", function()
	return display.newLayer()
end)

-- 构造函数
function FashionHomeLayer:ctor(params)
	-- 添加弹出框层
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = TR(""),
		bgSize = cc.size(630, 1000),
		closeImg = "c_29.png",
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

    -- 读取参数
    self.callback = params.callback
    self.defaultTag = params.defaultTag or 1

	-- 保存弹窗控件信息
	self.bgSprite = bgLayer.mBgSprite
	self.bgSize = bgLayer.mBgSprite:getContentSize()

	-- 初始化UI
	self:initUI()
end

-- 初始化UI
function FashionHomeLayer:initUI()
	-- 添加Tab分页
    local tabItems = {
        {tag = 1, text = TR("绝学")},
        {tag = 2, text = TR("绝学组合")},
        {tag = 3, text = TR("绝学分解")},
    }
    self.tabHeight = self.bgSize.height - 150
    self.tabSize = cc.size(self.bgSize.width - 50, self.tabHeight)

    local function cellOfPages(tag)
        if (self.currLayer ~= nil) then
            self.currLayer:removeFromParent()
            self.currLayer = nil
        end
	    local tmpLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
	    tmpLayer:setContentSize(self.tabSize)
	    tmpLayer:setIgnoreAnchorPointForPosition(false)
	    tmpLayer:setAnchorPoint(cc.p(0.5, 0))
	    tmpLayer:setPosition(cc.p(self.bgSize.width * 0.5, 22))
	    self.bgSprite:addChild(tmpLayer)
	    self.currLayer = tmpLayer

	    -- 显示子页面
	    local viewSrcList = {
            [1] = "fashion.SubFashionView",
            [2] = "fashion.SubGroupView",
            [3] = "fashion.SubFashionRefine",
        }
        local mSubView = require(viewSrcList[tag]):create({
            viewSize = self.tabSize,
            callback = self.callback,
        })
        mSubView:setPosition(0, 0)
        self.currLayer:addChild(mSubView)
    end

    local tabLayer = ui.newTabLayer({
        normalImage = "c_51.png",
        lightedImage = "c_50.png",
        viewSize = cc.size(self.tabSize.width, 80),
        needLine = false,
        btnInfos = tabItems,
        btnSize = cc.size(130, 58),
        defaultSelectTag = self.defaultTag,
        onSelectChange = cellOfPages,
        })
    tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setPosition(self.bgSize.width * 0.5, self.bgSize.height - 50)
    self.bgSprite:addChild(tabLayer)

    -- 显示线条
    local lineSprite = ui.newSprite("c_20.png")
    lineSprite:setScaleX(0.91)
    lineSprite:setPosition(self.bgSize.width * 0.5, self.bgSize.height - 120)
    self.bgSprite:addChild(lineSprite)
end

----------------------------------------------------------------------------------------------------

return FashionHomeLayer
