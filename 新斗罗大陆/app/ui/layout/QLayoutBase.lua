local QLayoutBase = class("QLayoutBase")

QLayoutBase.CENTER = 0
QLayoutBase.LEFT = 1
QLayoutBase.RIGHT = 2
QLayoutBase.TOP = 3
QLayoutBase.BOTTOM = 4

--[[
	By Kumo
	对背景框里面的部件进行拉伸配置
	
	@name ：部件在ccb中的引用名
	@horizontal ：是否可以横向拉伸
	@offsetHorizontal ：横向拉伸偏移量
	@vertical ：是否可以纵向拉伸
	@offsetVertical ：纵向拉伸偏移量
	@offsetX ：X坐标偏移量
	@offsetY ：Y坐标偏移量
]]
QLayoutBase.normalConfig = {}
QLayoutBase.normalConfig.res = {}
table.insert(QLayoutBase.normalConfig.res, 
	{name = "__sp_bg", 		horizontal = true, offsetHorizontal = 0, vertical = true, 	offsetVertical = 0, offsetX = 0, offsetY = 0})
table.insert(QLayoutBase.normalConfig.res, 
	{name = "__sp_top", 	horizontal = true, offsetHorizontal = 0, vertical = false,	offsetVertical = 0, offsetX = 0, offsetY = 0})
table.insert(QLayoutBase.normalConfig.res, 
	{name = "__sp_bottom",	horizontal = true, offsetHorizontal = 0, vertical = false,	offsetVertical = 0, offsetX = 0, offsetY = 0})

QLayoutBase.wideConfig = {}
QLayoutBase.wideConfig.res = {}
table.insert(QLayoutBase.wideConfig.res, 
	{name = "__sp_bg", 		horizontal = true, offsetHorizontal = 0, vertical = true, 	offsetVertical = 0, offsetX = 0, offsetY = 0})
table.insert(QLayoutBase.wideConfig.res, 
	{name = "__sp_top", 	horizontal = true, offsetHorizontal = 0, vertical = false,	offsetVertical = 0, offsetX = 0, offsetY = 0})
table.insert(QLayoutBase.wideConfig.res, 
	{name = "__sp_bottom", 	horizontal = true, offsetHorizontal = 0, vertical = false,	offsetVertical = 0, offsetX = 0, offsetY = 0})

function QLayoutBase:ctor(options)
	assert(options, "invalid args, 'options' is nil.")
	assert(options.displayOwner, "invalid args, 'displayOwner' is nil.")
	assert(options.config, "invalid args, 'config' is nil.")

	self.displayOwner = options.displayOwner
	self.config = options.config
end

--[[
	By Kumo
	获取整体变化的数值，因为它们并不是一样的规格。

	@_offsetWidth ：横向拉伸的量
	@_offsetHeight ： 纵向拉伸的量
	@_topOffsetVertical ：上梁的偏移量
	@_bottomOffsetVertical ： 下梁的偏移量
]]
function QLayoutBase:_getOffset(size)
	local _offsetWidth = 0
	local _offsetHeight = 0
	local _topOffsetVertical = 0
	local _bottomOffsetVertical = 0

	if size then 
		local target = self.displayOwner['__show_size']
		if target ~= nil then
			local _size = target:getContentSize()
			print( "[Kumo] layer_bj:size(), __show_size:size()  ===> ", size.width, size.height, _size.width, _size.height )
			_offsetWidth = size.width - _size.width
			_offsetHeight = size.height - _size.height

			for _, v in ipairs(self.config.res) do
				local tg = self.displayOwner[v.name]
				if tg then
					local pos = ccp( tg:getPosition() )
					if v.name == '__sp_top' then
						_topOffsetVertical = pos.y - _size.height / 2
					elseif v.name == '__sp_bottom' then
						_bottomOffsetVertical = pos.y + _size.height / 2
					end
				end
			end
		end
	end

	return _offsetWidth, _offsetHeight, _topOffsetVertical, _bottomOffsetVertical
end

--[[
	By Kumo
	背景会根据模版的大小来进行调整。
	一般模版在ccb里面的引用名为layer_bj

	@size : 模版的尺寸
	@posX ：模版的X坐标，即背景框的X坐标
	@posY ：模版的Y坐标，即背景框的Y坐标
	@alignmentHorizontal ： 背景框的横向对齐方式
	@alignmentVertical ： 背景框的纵向对齐方式
]]
function QLayoutBase:setObjectSize(size, pos, alignmentHorizontal, alignmentVertical)
	if not pos then pos = ccp( 0, 0 ) end
	if not alignmentHorizontal then alignmentHorizontal = QLayoutBase.CENTER end
	if not alignmentVertical then alignmentVertical = QLayoutBase.CENTER end
	
	local _offsetWidth, _offsetHeight, _topOffsetVertical, _bottomOffsetVertical = self:_getOffset(size)
	-- print( "[Kumo] QLayoutBase:setObjectSize() ", _offsetWidth, _offsetHeight, _topOffsetVertical, _bottomOffsetVertical )

	for _, v in ipairs(self.config.res) do
		local target = self.displayOwner[v.name]
		if target ~= nil then
			local perSize = target:getContentSize()
			if v.horizontal then
				perSize.width = perSize.width + _offsetWidth + (v.offsetHorizontal or 0)
			end
			if v.vertical then
				perSize.height = perSize.height + _offsetHeight + (v.offsetVertical or 0)
			end
			target:setPreferredSize(perSize)

			-- QLayoutBase.CENTER, QLayoutBase.LEFT, QLayoutBase.RIGHT, QLayoutBase.TOP, QLayoutBase.BOTTOM
			local posX = 0
			if alignmentHorizontal == QLayoutBase.CENTER then
				posX = pos.x + (v.offsetX or 0)
			elseif alignmentHorizontal == QLayoutBase.LEFT then
				posX = pos.x + (v.offsetX or 0) + size.width / 2
			elseif alignmentHorizontal == QLayoutBase.RIGHT then
				posX = pos.x + (v.offsetX or 0) - size.width / 2
			end
			target:setPositionX(posX)

			local posY = 0
			if alignmentVertical == QLayoutBase.CENTER then
				if v.name == "__sp_bg" then
					posY = pos.y + (v.offsetY or 0)
				elseif v.name == "__sp_top" then
					posY = pos.y + (v.offsetY or 0) + size.height / 2 + _topOffsetVertical
				elseif v.name == "__sp_bottom" then
					posY = pos.y + (v.offsetY or 0) - size.height / 2 + _bottomOffsetVertical
				else
					assert(false, "v.name not exist in config.")
				end
			elseif alignmentVertical == QLayoutBase.TOP then
				if v.name == "__sp_bg" then
					posY = pos.y + (v.offsetY or 0) - size.height / 2
				elseif v.name == "__sp_top" then
					posY = pos.y + (v.offsetY or 0)  + _topOffsetVertical
				elseif v.name == "__sp_bottom" then
					posY = pos.y + (v.offsetY or 0) - size.height + _bottomOffsetVertical
				else
					assert(false, "v.name not exist in config.")
				end
			elseif alignmentVertical == QLayoutBase.BOTTOM then
				if v.name == "__sp_bg" then
					posY = pos.y + (v.offsetY or 0) + size.height / 2
				elseif v.name == "__sp_top" then
					posY = pos.y + (v.offsetY or 0) + size.height + _topOffsetVertical
				elseif v.name == "__sp_bottom" then
					posY = pos.y + (v.offsetY or 0) + _bottomOffsetVertical
				else
					assert(false, "v.name not exist in config.")
				end
			end
			target:setPositionY(posY)

			-- print( "[Kumo] QLayoutBase:setObjectSize() ", perSize.width, perSize.height, posX, posY)
		else
			print( "[Kumo] QLayoutBase:setObjectSize() ", v.name , "con't find")
		end
	end
end

return QLayoutBase