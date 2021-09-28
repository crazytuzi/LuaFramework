--[[
    文件名: MeetTaofaLayer.lua
	描述: 奇遇-讨伐恶徒
	创建人: yanghongsheng
	创建时间: 2017.4.10
--]]

local MeetTaofaLayer = class("MeetTaofaLayer", function()
    return display.newLayer()
end)

function MeetTaofaLayer:ctor()
	-- body
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()
end

function MeetTaofaLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("cdjh_20.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(320,568)
    self.mParentLayer:addChild(bgSprite)
end


return MeetTaofaLayer