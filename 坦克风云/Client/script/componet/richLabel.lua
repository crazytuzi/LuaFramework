richLabel = {}

function richLabel:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self

	self.fontName = nil
	self.fontSize = nil
	self.fontColor = nil
	self.containLayer = nil
	self.spriteArray = nil
	self.textStr = nil
	self.maxWidth = nil
	self.maxHeight = nil
	self.pureStr = nil
	self.labelStatus = 1

	return nc
end

function richLabel:init(params)
	local node = CCNode:create()
	self.fontName   = params.fontName or "Helvetica" --默认字体
	self.fontSize   = params.fontSize or 28
	 --默认大小
	self.fontColor = params.fontColor or ccc3(255, 255, 255) --默认白色
	self.dimensions = params.dimensions or CCSize(450, 0) --默认无限扩展，即沿着x轴往右扩展
	local text       = params.text

	local containLayer = CCLayer:create()
	self.containLayer = containLayer
	node:addChild(self.containLayer)

	self:setLabelString(text)
	return node, self.pureStr

end

function richLabel:setLabelString(text)
	if self.textStr == text then
		return -- 相同则忽略
	end

	if self.textStr then -- 删除之前的string
		self.spriteArray = nil
		self.containLayer:removeAllChildren()
	end

	self.labelStatus = 1
	self.textStr = text

	--转化好的数组
	local parseArray = self:parseString(text)


	--将字符串拆分成一个个字符
	self:formatString(parseArray)

	local str = ""
	for k,v in pairs(parseArray) do
		str = str .. v.text
	end
	self.pureStr = str

	--创建精灵
	local spriteArray = self:createSprite(parseArray)

	self.spriteArray = spriteArray

	self:adjustPosition()

end

--调整位置（设置文字和尺寸都会触发此方法）
function richLabel:adjustPosition()

	local spriteArray = self.spriteArray

	if not spriteArray then --还没创建
		return
	end

	--获得每个精灵的宽度和高度
	local widthArr, heightArr = self:getSizeOfSprites(spriteArray)

	--获得每个精灵的坐标
	local pointArrX, pointArrY = self:getPointOfSprite(widthArr, heightArr, self.dimensions)

	for i, sprite in ipairs(spriteArray) do
		sprite:setPosition(pointArrX[i], pointArrY[i])
	end
	
end

--获得每个精灵的尺寸
function richLabel:getSizeOfSprites(spriteArray)
	local widthArr = {} --宽度数组
	local heightArr = {} --高度数组

	--精灵的尺寸
	for i, sprite in ipairs(spriteArray) do
		local contentSize = sprite:getContentSize()
		widthArr[i] = contentSize.width
		heightArr[i] = contentSize.height
	end
	return widthArr, heightArr

end

--获得每个精灵的位置
function richLabel:getPointOfSprite(widthArr, heightArr, dimensions)
	local totalWidth = dimensions.width
	local totalHight = dimensions.height

	local maxWidth = 0
	local maxHeight = 0

	local spriteNum = #widthArr

	--从左往右，从上往下拓展
	local curX = 0 --当前x坐标偏移
	
	local curIndexX = 1 --当前横轴index
	local curIndexY = 1 --当前纵轴index
	
	local pointArrX = {} --每个精灵的x坐标

	local rowIndexArr = {} --行数组，以行为index储存精灵组
	local indexArrY = {} --每个精灵的行index

	--计算宽度，并自动换行
	for i, spriteWidth in ipairs(widthArr) do
		local nexX = curX + spriteWidth
		local pointX
		local rowIndex = curIndexY

		local halfWidth = spriteWidth * 0.5
		if nexX > totalWidth and totalWidth ~= 0 then --超出界限了
			pointX = halfWidth
			if curIndexX == 1 then --当前是第一个，
				curX = 0-- 重置x
			else --不是第一个，当前行已经不足容纳
				rowIndex = curIndexY + 1 --换行
				curX = spriteWidth
			end
			curIndexX = 1 --x坐标重置
			curIndexY = curIndexY + 1 --y坐标自增
		else
			pointX = curX + halfWidth --精灵坐标x
			curX = pointX + halfWidth --精灵最右侧坐标
			curIndexX = curIndexX + 1
		end
		pointArrX[i] = pointX --保存每个精灵的x坐标

		indexArrY[i] = rowIndex --保存每个精灵的行

		local tmpIndexArr = rowIndexArr[rowIndex]

		if not tmpIndexArr then --没有就创建
			tmpIndexArr = {}
			rowIndexArr[rowIndex] = tmpIndexArr
		end
		tmpIndexArr[#tmpIndexArr + 1] = i --保存相同行对应的精灵

		if curX > maxWidth then
			maxWidth = curX
		end
	end

	local curY = 0
	local rowHeightArr = {} --每一行的y坐标

	--计算每一行的高度
	for i, rowInfo in ipairs(rowIndexArr) do
		local rowHeight = 0
		for j, index in ipairs(rowInfo) do --计算最高的精灵
			local height = heightArr[index]
			if height > rowHeight then
				rowHeight = height
			end
		end
		local pointY = curY + rowHeight * 0.5 --当前行所有精灵的y坐标（正数，未取反）
		rowHeightArr[#rowHeightArr + 1] = - pointY --从左往右，从上到下扩展，所以是负数
		curY = curY + rowHeight --当前行的边缘坐标（正数）

		if curY > maxHeight then
			maxHeight = curY
		end
	end

	self._maxWidth = maxWidth
	self._maxHeight = maxHeight

	local pointArrY = {}

	for i = 1, spriteNum do
		local indexY = indexArrY[i] --y坐标是先读取精灵的行，然后再找出该行对应的坐标
		local pointY = rowHeightArr[indexY]
		pointArrY[i] = pointY
	end

	return pointArrX, pointArrY
end

--创建精灵
function richLabel:createSprite(parseArray)
	local spriteArray = {}
	

	for i, dic in ipairs(parseArray) do
		local textArr = dic.textArray
		if #textArr > 0 then --创建文字

			local fontName = dic.fontName or self.fontName
			local fontSize = dic.fontSize or self.fontSize
			local fontColor = dic.fontColor or self.fontColor
			for j, word in ipairs(textArr) do

				local label = CCLabelTTF:create(word, fontName, fontSize)
				label:setColor(fontColor)
				spriteArray[#spriteArray + 1] = label

				self.containLayer:addChild(label)
			end
		elseif dic.image then

			local sprite = CCSprite:create(dic.image)
			local scale = dic.scale or 1
			sprite:setScale(scale)
			spriteArray[#spriteArray + 1] = sprite
			self.containLayer:addChild(sprite)
		else
			error("not define")
		end
	end
	print(self:SizeOfTable(spriteArray))
	return spriteArray
end



-- 将字符串转换成一个个字符
function richLabel:formatString(parseArray)
	for i,dic in ipairs(parseArray) do
		local text = dic.text
		if text then
			local textArr = self:stringToChar(text)
			dic.textArray = textArr
		end
	end
end

--文字解析，按照顺序转换成数组，每个数组对应特定的标签
function richLabel:parseString(str)
	local clumpheadTab = {} -- 标签头
	--作用，取出所有格式为[xxxx]的标签头
	for w in string.gfind(str, "%b[]") do 
		if  string.sub(w,2,2) ~= "/" then-- 去尾
			table.insert(clumpheadTab, w)
			
		end
	end

	

	-- 解析标签
	local totalTab = {}
	for k,ns in pairs(clumpheadTab) do
		local tab = {}
		local tStr  
		-- 第一个等号前为块标签名
		string.gsub(ns, string.sub(ns, 2, #ns-1), function (w)
			local n = string.find(w, "=")
			if n then
				local temTab = self:stringSplit(w, " ") -- 支持标签内嵌
				for k,pstr in pairs(temTab) do
					local temtab1 = self:stringSplit(pstr, "=")
			
					local pname = temtab1[1]

					if k == 1 then 
						tStr = pname 
					end -- 标签头
					
					local js = temtab1[2]

					local p = string.find(js, "[^%d.]")

        			if not p then 
        				js = tonumber(js) 
        			end

					local switchState = {
						["fontColor"]	 = function()
							tab["fontColor"] = self:convertColor(js)
						end,
					} --switch end

					local fSwitch = switchState[pname] --switch 方法

					--存在switch
					if fSwitch then 
						--目前只是颜色需要转换
						local result = fSwitch() --执行function
					else --没有枚举
						tab[pname] = js

						return
					end
				end
			end
		end)
		if tStr then
			-- 取出文本
			local beginFind,endFind = string.find(str, "%[%/"..tStr.."%]")
			local endNumber = beginFind-1
			local gs = string.sub(str, #ns+1, endNumber)
			if string.find(gs, "%[") then
				tab["text"] = gs
			else
				string.gsub(str, gs, function (w)
					tab["text"] = w
				end)
			end
			-- 截掉已经解析的字符
			str = string.sub(str, endFind+1, #str)
			table.insert(totalTab, tab)
		end
	end

	
	-- 普通格式label显示
	if self:SizeOfTable(clumpheadTab) == 0 then
		local ptab = {}
		ptab.text = str
		table.insert(totalTab, ptab)
	end

	return totalTab

end

function richLabel:SizeOfTable(tb)
    local size=0
    for k,v in pairs(tb) do
        size=size+1
    end
    return size
end

--[[解析16进制颜色rgb值]]
function richLabel:convertColor(xStr)
	local function toTen(v)
        return tonumber("0x" .. v)
    end

    local b = string.sub(xStr, -2, -1) 
    local g = string.sub(xStr, -4, -3) 
    local r = string.sub(xStr, -6, -5)

    local red = toTen(r) or self.fontColor.r
    local green = toTen(g) or self.fontColor.g
    local blue = toTen(b) or self.fontColor.b
    return ccc3(red, green, blue)
end


function richLabel:stringSplit(str, flag)
	local tab = {}
	while true do
		local n = string.find(str, flag)
		if n then
			local first = string.sub(str, 1, n-1) 
			str = string.sub(str, n+1, #str) 
			table.insert(tab, first)
		else
			table.insert(tab, str)
			break
		end
	end
	return tab
end

function richLabel:stringToChar(str)
	 local list = {}
    local len = string.len(str)
    local i = 1 
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
    end
	return list, len
end

