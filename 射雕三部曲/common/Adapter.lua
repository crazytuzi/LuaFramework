--[[
    文件名：Adapter.lua
    描述：界面自适应辅助对象。
	创建人：liaoyuangang
    创建时间：2016.3.29
-- ]]

Adapter = {}

-- 定义全局访问地址
function Adapter.init()
    local glview = cc.Director:getInstance():getOpenGLView()
    local visibleSize = glview:getFrameSize()
	-- 计算缩放比例
    local scaleX = visibleSize.width / CC_DESIGN_RESOLUTION.width
    local scaleY = visibleSize.height / CC_DESIGN_RESOLUTION.height
	local minScale = ((scaleX>scaleY) and scaleY) or scaleX
    print(string.format("# Adapter scaleX = %0.2f, scaleY = %0.2f, minScale = %0.2f", scaleX, scaleY, minScale))

	-- set scale
	Adapter.AutoScaleX = scaleX
	Adapter.WidthScale = scaleX
	Adapter.AutoScaleY = scaleY
	Adapter.HeightScale = scaleY
	Adapter.MinScale = minScale

    Adapter.TopY = display.cy + 568 * minScale
    Adapter.BottomY = display.cy - 568 * minScale
end

-- auto pos
function Adapter.AutoPosX(xpos)
	return xpos * Adapter.AutoScaleX
end
Adapter.AutoWidth = Adapter.AutoPosX

function Adapter.AutoPosY(ypos)
	return ypos * Adapter.AutoScaleY
end
Adapter.AutoHeight = Adapter.AutoPosY

function Adapter.AutoPos(x, y)
	return cc.p(x * Adapter.AutoScaleX, y * Adapter.AutoScaleY)
end

function Adapter.AutoSize(width, height)
	return cc.size(width * Adapter.AutoScaleX, height * Adapter.AutoScaleY)
end

-- min pos
function Adapter.MinPosX(xpos)
	return xpos * Adapter.MinScale
end
Adapter.MinWidth = Adapter.MinPosX

function Adapter.MinPosY(ypos)
	return ypos * Adapter.MinScale
end
Adapter.MinHeight = Adapter.MinPosY

function Adapter.MinPos(x, y)
	return cc.p(x * Adapter.MinScale, y * Adapter.MinScale)
end

function Adapter.MinSize(width, height)
	return cc.size(width * Adapter.MinScale, height * Adapter.MinScale)
end

-- width pos
function Adapter.WidthPos(x, y)
	return cc.p(x * Adapter.AutoScaleX, y * Adapter.AutoScaleX)
end

function Adapter.WidthSize(width, height)
	return cc.size(width * Adapter.AutoScaleX, height * Adapter.AutoScaleX)
end

-- height pos
function Adapter.HeightPos(x, y)
	return cc.p(x * Adapter.AutoScaleY, y * Adapter.AutoScaleY)
end

function Adapter.HeightSize(width, height)
	return cc.size(width * Adapter.AutoScaleY, height * Adapter.AutoScaleY)
end

Adapter.init() -- 在require该文件时就初始化

