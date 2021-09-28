
return { new = function(params)

local Mnode = require "src/young/node"
-----------------------------------------------------------------------
local res = "res/component/progress/"
-----------------------------------------------------------------------
local barBg = cc.Sprite:create(params.bg or res .. "2_bg.png")
local barBgSize = barBg:getContentSize()

local progressBar = cc.Sprite:create(params.bar)
local progressBarSize = progressBar:getContentSize()

Mnode.addChild(
{
	parent = barBg,
	child = progressBar,
	anchor = cc.p(0, 0.5),
	pos = cc.p(2, barBgSize.height/2),
	zOrder = 1,
})

local progressValue = Mnode.createLabel(
{
	src = "",
	size = 20,
})

Mnode.addChild(
{
	parent = barBg,
	child = progressValue,
	pos = cc.p(barBgSize.width/2, barBgSize.height/2),
	zOrder = 2,
})

local attrBar = nil
if type(params.label) == "table" then
	attrBar = Mnode.combineNode(
	{
		nodes = 
		{
			Mnode.createLabel(params.label),
			
			barBg,
		},
		
		margins = 8,
	})
else
	attrBar = barBg
end

local M = Mnode.beginNode(attrBar)

setProgress = function(self, value, duration)
	local progress = nil
	
	if type(value) == "table" then
		progress = value.cur / value.max
		progressValue:setString(value.cur .. "/" .. value.max)
	elseif type(value) == "number" then
		progress = value
		progressValue:setString(value * 100 .. "%")
	else
		return
	end
	
	self.progress = progress
	
	duration = duration or 0
	
	if duration == 0 then
		progressBar:setTextureRect( cc.rect(0, 0, progressBarSize.width * progress, progressBarSize.height) )
	elseif duration > 0 then
	end
end
if params.progress then attrBar:setProgress(params.progress) end

return attrBar
-----------------------------------------------------------------------
end }