--------------------------------------------------------------------------------------
-- 文件名:	g_NewLabelTTF.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2014-1-22 9:37
-- 版  本:	1.0
-- 描  述:	新label,行间距 列间距 中英文自动换行
-- 应  用:  本例子是用类对象的方式实现
 
---------------------------------------------------------------------------------------
RichLabel = class("CPlayer", function() return  Layout:create()  end)
RichLabel.__index = RichLabel
--[[
local strArr = {}
	strArr[1] = "[image=UI/Char_InBattle.png scale=2][/image][image=UI/Char_Title_HandBook1.png][/image][fontColor=f75d85 fontSize=20]hello world[/fontColor][fontColor=fefefe]这是测试代码[/fontColor][fontColor=ff7f00 fontName=ArialRoundedMTBold]我日[/fontColor][fontColor=3232cd]活动时间!!![/fontColor][fontColor=222222]东莞[/fontColor]" --图片
	strArr[2] = "[image=UI/CheckBox_Group_Check.png][/image][image=UI/CheckBox_Group_Check.png][/image][image=UI/CheckBox_Group_Check.png][/image][image=UI/CheckBox_Group_Check.png][/image][image=UI/CheckBox_Group_Check.png][/image]"
	strArr[3] = "[fontSize=60]hello world!!!!!![/fontSize]"
	strArr[4] =	"[fontSize=30]啊撒啊啊撒啊撒啊[/fontSize]"


	local params = {
						text = strArr[1],
						curWidth = 50,
						curHeight = 20,
						horizontalSpace  = 30,
						verticalSpace = 20,
					}
	local testLabel = RichLabel:create(widget,label,params)
]]

RichLabel.__index      = RichLabel
RichLabel._fontName = nil
RichLabel._fontSize = nil
RichLabel._fontColor = nil
RichLabel._containLayer = nil --装载layer
RichLabel._spriteArray = nil --精灵数组
RichLabel._textStr = nil
RichLabel._maxWidth = nil
RichLabel._maxHeight = nil

--创建方法 
--[[
	local params = {
		fontName = "Arial",
		fontSize = 30,
		fontColor = ccc3(255, 0, 0),
		dimensions = CCSize(300, 200),
		text = [fontColor=f75d85 fontSize=20]hello world[/fontColor],
	}
	text 目前支持参数
			文字 
			fontName  : font name
			fontSize  : number
			fontColor : 十六进制

			图片
			image : "xxx.png"
			scale : number
]]--

function RichLabel:create(params,label)
	local ret = RichLabel.new()
	ret:init_(params)

	if label then
		local LabelPos = label:getPosition()
		ret:setPosition(LabelPos)
		label:setVisible(false)
		local widget = label:getParent()
		widget:addChild(ret)
	end
	return ret
end

--设置text
function RichLabel:setLabelString(text)
	if self._textStr == text then
		return --相同则忽略
	end

	if self._textStr then --删除之前的string
		self._spriteArray = nil
		self._containLayer:removeAllChildren()
	end

	self._labelStatus = 1 --未开始
	self:unscheduleUpdate() --init

	self._textStr = text
	
	--转化好的数组
	local parseArray = self:parseString_(text)

	--将字符串拆分成一个个字符
	self:formatString_(parseArray)

	--创建精灵
	local spriteArray = self:createSprite_(parseArray)
	self._spriteArray = spriteArray

	self:adjustPosition_()
end

--设置尺寸
function RichLabel:setDimensions(_ccSize)
	self._containLayer:setContentSize(_ccSize)
	self._dimensions = _ccSize
	self:adjustPosition_()
end
--设置间距
function RichLabel:setSpaces(horizontalSpace,verticalSpace)
	self._horizontalSpace  = horizontalSpace or 0
	self._verticalSpace = verticalSpace or 0
	self:adjustPosition_()
end

--获得label尺寸
function RichLabel:getLabelSize()
	local width = self._maxWidth or 0
	local height = self._maxHeight or 0
	return CCSize(width, height)
end


function RichLabel:getHeight()
	return self.sizeHeight
end
function RichLabel:getWidth()
	return self.sizeWidth
end
function RichLabel:getspriteHeight()
	return self.spriteHeight
end


function RichLabel:init_(params)
	--如果text的格式指定字体则使用指定字体，否则使用默认字体
	--大小和颜色同理
	local fontName   = params.fontName or "Arial" --默认字体
	local fontSize   = params.fontSize or 27 --默认大小
	local fontColor  = params.fontColor or ccc3(255, 255, 255) --默认白色
	local dimensions = CCSize(params.curWidth,params.curHeight)  or CCSize(510, 0) --默认无限扩展，即沿着x轴往右扩展
	local text       = params.text
	local horizontalSpace  = params.horizontalSpace or 0
	local verticalSpace = params.verticalSpace or 0

	--装文字和图片精灵
	local containLayer =  Layout:create() -- display.newLayer()
	self:addChild(containLayer)
	
    self._fontName     = fontName
    self._fontSize     = fontSize
    self._fontColor    = fontColor
    self._dimensions   = dimensions
	self._horizontalSpace = horizontalSpace
	self._verticalSpace = verticalSpace
    self._containLayer = containLayer
	
    self:setLabelString(text)
end

--获得每个精灵的尺寸
function RichLabel:getSizeOfSprites_(spriteArray)
	local widthArr = {} --宽度数组
	local heightArr = {} --高度数组

	--精灵的尺寸
	for i, sprite in ipairs(spriteArray) do
		local rect = sprite:getContentSize()
		local scale = sprite:getScale()

		widthArr[i] = rect.width*scale + self._horizontalSpace
		heightArr[i] = rect.height*scale + self._verticalSpace
		
		if self._dimensions.width ~=0 and widthArr[i]>self._dimensions.width   then
			cclog("===整体宽度curWidth 小于第"..i.." 单个控件宽== 请重新填写===")
			--return 
		end
	end
	return widthArr, heightArr
end

--获得每个精灵的位置
function RichLabel:getPointOfSprite_(widthArr, heightArr, dimensions,spriteArray)
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
	local startIndex = 1
	--计算宽度，并自动换行
	for i, spriteWidth in ipairs(widthArr) do
		local nexX = curX + spriteWidth
		local pointX
		local rowIndex = curIndexY

		local halfWidth = spriteWidth * 0.5
	    local sprite = spriteArray[i]
		local tag = sprite:getTag()
		if (nexX > totalWidth and totalWidth ~= 0 ) or tag == 100  then --超出界限了
			pointX = halfWidth
			if curIndexX == 1 then --当前是第一个，
				rowIndex = curIndexY + 1
				curX = spriteWidth-- 重置x
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
		if i == 1 then
			startIndex = rowIndex
		end
		table.insert(tmpIndexArr, i )
		--tmpIndexArr[#tmpIndexArr + 1] = i --保存相同行对应的精灵

		if curX > maxWidth then
			maxWidth = curX
		end
		self.sizeWidth = curX
	end

	local curY = 0
	local rowHeightArr = {} --每一行的y坐标

	--计算每一行的高度
	for i = startIndex,#rowIndexArr do
		local rowInfo = rowIndexArr[i]
	--for i = startIndex, rowInfo in ipairs(rowIndexArr) do
		local rowHeight = 0
		for j, nIndex in ipairs(rowInfo) do --计算最高的精灵
			local height = heightArr[nIndex]
			if height > rowHeight then
				rowHeight = height
			end
		end

		local pointY = curY + rowHeight * 0.5   --当前行所有精灵的y坐标（正数，未取反）
		table.insert(rowHeightArr, - pointY )
		--rowHeightArr[#rowHeightArr + 1] = --从左往右，从上到下扩展，所以是负数
		curY = curY + rowHeight --当前行的边缘坐标（正数）

		if curY > maxHeight then	
			maxHeight = curY
		end
		self.sizeHeight = curY + rowHeight
		
		self.spriteHeight = self.spriteHeight or 0
		if i == startIndex then
			self.spriteHeight = rowHeight
		end

	end

	self._maxWidth = maxWidth
	self._maxHeight = maxHeight

	local pointArrY = {}

	for i = 1, spriteNum do
		local indexY = indexArrY[i] --y坐标是先读取精灵的行，然后再找出该行对应的坐标
		local pointY = rowHeightArr[indexY+1 - startIndex]
		pointArrY[i] = pointY + self._verticalSpace
	end

	return pointArrX, pointArrY
end

--调整位置（设置文字和尺寸都会触发此方法）
function RichLabel:adjustPosition_()

	local spriteArray = self._spriteArray

	if not spriteArray then --还没创建
		return
	end

	--获得每个精灵的宽度和高度
	local widthArr, heightArr = self:getSizeOfSprites_(spriteArray)

	--获得每个精灵的坐标
	local pointArrX, pointArrY = self:getPointOfSprite_(widthArr, heightArr, self._dimensions,spriteArray)

	for i, sprite in ipairs(spriteArray) do
		sprite:setPosition(ccp(pointArrX[i], pointArrY[i]))
	end
end
 
--创建精灵
function RichLabel:createSprite_(parseArray)
	local spriteArray = {}

	for i, dic in ipairs(parseArray) do
		local textArr = dic.textArray
		if #textArr > 0 then --创建文字
			local fontName = dic.fontName or self._fontName
			local fontSize = dic.fontSize or self._fontSize
			local fontColor = dic.fontColor or self._fontColor
			local fontRotate = dic.fontRotate or 0
			for j, word in ipairs(textArr) do
				local label = CCLabelTTF:create(word, fontName, fontSize)
				label:setColor(fontColor)
				label:setRotation(fontRotate)
				spriteArray[#spriteArray + 1] = label
				self._containLayer:addNode(label)
				if word == '\n' then
					label:setTag(100)
				end
			end
		elseif dic.image then
			local sprite = CCSprite:create(dic.image)
			local scale = dic.scale or 1
			if not sprite then
				cclog("====couldn't found=imagePath==0======"..dic.image)
			end
			sprite:setScale(scale)
			spriteArray[#spriteArray + 1] = sprite
			self._containLayer:addNode(sprite)
		else
			error("not define")
		end
	end

	return spriteArray
end

--将字符串转换成一个个字符
function RichLabel:formatString_(parseArray)
	for i,dic in ipairs(parseArray) do
		local text = dic.text
		if text then
			local textArr = self:stringToChar_(text)
			dic.textArray = textArr
		end
	end
end

function RichLabel:parseString_(str)
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
				local temTab = self:stringSplit_(w, " ") 
				for k,pstr in ipairs(temTab) do
					local temtab1 = self:stringSplit_(pstr, "=")
					
					local pname = temtab1[1]

					if k == 1 then 
						tStr = pname 
					end -- 标签头
					
					local js = temtab1[2]

					local p = string.find(js, "[^%d.]")
        			if not p then 
        				js = tonumber(js)
					else
        			end

					local switchState = {
						["fontColor"]	 = function()
							tab["fontColor"] = self:convertColor_(js)
						end,
					} 

					local fSwitch = switchState[pname] 
					if fSwitch then 
						--目前只是颜色需要转换
						local result = fSwitch() --执行function
					else --没有枚举
						tab[pname] = js		
						--return
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
	if table.nums(clumpheadTab) == 0 then
		local ptab = {}
		ptab.text = str
		table.insert(totalTab, ptab)
	end
	return totalTab
end


--[[解析16进制颜色rgb值]]
function  RichLabel:convertColor_(xStr)
    local function toTen(v)
        return tonumber("0x" .. v)
    end

    local b = string.sub(xStr, -2, -1) 
    local g = string.sub(xStr, -4, -3) 
    local r = string.sub(xStr, -6, -5)

    local red = toTen(r) or self._fontColor.r
    local green = toTen(g) or self._fontColor.g
    local blue = toTen(b) or self._fontColor.b
    return ccc3(red, green, blue)
end

-- string.split()
function RichLabel:stringSplit_(str, flag)
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

-- 拆分出单个字符
function RichLabel:stringToChar_(str)
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

return RichLabel
