-- --------------------------------------------------+
-- 富文本
-- @author whjing2011@gmail.com
-- --------------------------------------------------*/

local labelparser = require("common.richlabel.labelparser")
local CURRENT_MODULE = "common.richlabel.RichLabel"
local Tag_Path = "common/richlabel/labels/label_"

local RichLabel = class("RichLabel", function()
    return cc.Node:create()
end)

-- 共享解析器列表
local shared_parserlist = {}
-- 默认点击事件
local __click_list = {'href', 'click'}

-- 播放动画默认速度
local DEBUG_MARK = "richlabel.debug.drawnodes"

--[[--
-   ctor: 构造函数
	@param: 
		params - 可选参数列表
		params.fontName - 默认的字体名称
		params.fontSize - 默认字体大小
		params.fontColor - 默认字体颜色
		params.maxWidth - Label最大宽度
		params.lineSpace - 行间距
		params.charSpace - 字符间距
]]
function RichLabel:ctor(params)
	params = params or {}
	local fontName 	= params.fontName or "Arial"
	local fontSize 	= params.fontSize or 20
	local fontColor = params.fontColor or cc.c3b(255, 255, 255)
	local linespace = params.lineSpace or 0 -- 行间距
	local charspace = 0 -- params.charSpace or 0 -- 字符距
    local maxWidth = params.maxWidth or 100

	self._default = {}
	self._default.fontName = fontName
	self._default.fontSize = fontSize
	self._default.fontColor = fontColor
	self._default.lineSpace = linespace
	self._default.charSpace = charspace

    -- 画线条等容器
    local draw_line_node = cc.DrawNode:create()
    self:addChild(draw_line_node)

    --可点击的容器
    local click_container = ccui.Widget:create()
    click_container:setAnchorPoint(0, 0)
    self:addChild(click_container)

	-- 精灵容器
	local containerNode = cc.Node:create()
	self:addChild(containerNode)

	self._maxWidth = maxWidth
	self._containerNode = containerNode
    self._drawLineNode = draw_line_node
    self._clickNode = click_container
	self._animationCounter = 0

	-- 允许setColor和setOpacity生效
    self:setCascadeOpacityEnabled(true)
    self:setCascadeColorEnabled(true)
    containerNode:setCascadeOpacityEnabled(true)
    containerNode:setCascadeColorEnabled(true)
    click_container:setCascadeColorEnabled(true)
    click_container:setCascadeOpacityEnabled(true)
end

function RichLabel:getSize()
    return cc.size(self._currentWidth, self._currentHeight)
end

-- 设置行间距
function RichLabel:setLineSpace(space)
	self._default.lineSpace = space
end

--[[--
-   setMaxWidth: 设置行最大宽度
	@param: maxwidth - 行的最大宽度
]]
function RichLabel:setMaxWidth(maxwidth, is_update)
	self._maxWidth = maxwidth
    if is_update then
        self:layout_()
    end
end

function RichLabel:getString()
	return self._currentText
end

--[[--
-   setString: 设置富文本字符串
	@param: text - 必须遵守规范的字符串才能正确解析	
			<div fontcolor=#ffccbb>hello</div>
]]
function RichLabel:setString(text)
	text = text or ""
	-- 字符串相同的直接返回
	if self._currentText == text then return end
	self._currentText = text

	-- 解析字符串，解析成为一种内定格式(表结构)，便于创建精灵使用
	local parsedtable = labelparser.parse(text)
	self._parsedtable = parsedtable

	if parsedtable == nil then
		return self:printf("parser text error")
	end
    -- Debug.info(parsedtable)

    self:layout_()
end

--点击链接的时候
function RichLabel:addTouchLinkListener(call_back, flag_list)
    self._clickNode:setTouchEnabled(true)
    self._clickNode:setSwallowTouches(false)
    self._clickNode:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.ended and call_back then
            local pos = sender:getTouchEndPosition()
            local endPos = self._containerNode:convertToNodeSpace(pos)

            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(pos.x - self.touch_began.x) <= 20 and math.abs(pos.y - self.touch_began.y) <= 20
            end         
            flag_list = flag_list or __click_list
            local bool, type, value = self:isClickByFlag(endPos, __click_list)
            if bool then
                call_back(type, value, self, pos, is_click)
            end
        end
    end)
end
--分割字符
function RichLabel:split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end
-- 直接点击文本
function RichLabel:addTouchEventListener(call_back)
    self._clickNode:setTouchEnabled(true)
    self._clickNode:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended and call_back then
            call_back(type, value, sender)
        end
    end)
end

-- 判断是否点击到指定标签
function RichLabel:isClickByFlag(pos, flag_list)
	 for _, div in pairs(self._parsedtable) do
        for key, value in pairs(flag_list) do
        	if div[value] then
	            for k, node in pairs(div.nodes or {}) do
                    local rect = node:getBoundingBox()
                    if cc.rectContainsPoint(rect, pos) then
                        return true, value, div[value]
	                end
	            end
        	end
        end
    end
    return true, "", ""
end

--[[--
-   debugDraw: 绘制边框
	@param: level - 绘制级别，level<=2 只绘制整体label, level>2 绘制整体label和单个字符的范围
]]
function RichLabel:debugDraw(level)
	level = level or 2
    local containerNode = self._containerNode
	local debugdrawnodes1 = cc.utils:findChildren(containerNode, DEBUG_MARK)
	local debugdrawnodes2 = cc.utils:findChildren(self, DEBUG_MARK)
	function table_insertto(dest, src, begin)
	    if begin <= 0 then
	        begin = #dest + 1
	    end
	    local len = #src
	    for i = 0, len - 1 do
	        dest[i + begin] = src[i + 1]
	    end
	end
	table_insertto(debugdrawnodes1, debugdrawnodes2, #debugdrawnodes1+1)
	for k,v in pairs(debugdrawnodes1) do
		doRemoveFromParent(v)
	end

	local labelSize = self:getContentSize()
    local anchorpoint = self:getAnchorPoint()
	local frame = cc.rect(0, 0, labelSize.width, labelSize.height)
	-- 绘制整个label的边框
    self:drawrect(self._drawLineNode, frame, 1, cc.c4f(0,0,1,0.5)):setName(DEBUG_MARK)
    self:drawrect(self._clickNode, frame, 1, cc.c4f(0,1,0,0.5)):setName(DEBUG_MARK)
    self:drawrect(self, frame, 1):setName(DEBUG_MARK)
    -- 绘制label的锚点
    self:drawdot(self, cc.p(labelSize.width * anchorpoint.x, labelSize.height * anchorpoint.y), 5):setName(DEBUG_MARK)

    -- 绘制每个单独的字符
    if level > 1 then
	    local parsedtable = self._parsedtable
	    local drawcolor = cc.c4f(0,0,1,0.5)
	    for _, div in pairs(parsedtable) do
            for _, node in pairs(div.nodes) do
                local box = node:getBoundingBox()
                local pos = cc.p(node:getPositionX(), node:getPositionY())
                self:drawrect(containerNode, box, 1, drawcolor):setName(DEBUG_MARK)
                self:drawdot(containerNode, pos, 2, drawcolor):setName(DEBUG_MARK)
            end
	    end
	end
end

-- 一般情况下无需手动调用，设置setMaxWidth, setString, setAnchorPoint时自动调用
-- 自动布局文本，若设置了最大宽度，将自动判断换行
-- 否则一句文本中得内容'\n'换行
function RichLabel:layout_()
    self:init_nodes_()
	local linespace = self._default.lineSpace
	local maxwidth = 0
	local maxheight = 0
    local rows = self:create_allnodes_()
    local row
    for i=#rows, 1, -1 do
        row = rows[i]
        for _, node in pairs(row.nodes) do
            node:setPositionY(maxheight + (row.h - node:getBoundingBox().height) / 2)
        end
        maxwidth = math.max(row.w, maxwidth)
        maxheight = maxheight + row.h + linespace
    end
    rows = nil
    maxheight = math.max(0, maxheight - linespace)
	self._currentWidth = maxwidth
	self._currentHeight = maxheight
    --设置点击容器的大小
    self:setContentSize(cc.size(maxwidth, maxheight))
    self._clickNode:setContentSize(cc.size(maxwidth, maxheight))
    self._drawLineNode:setContentSize(cc.size(maxwidth, maxheight))
	-- 根据锚点重新定位
    self:draw_underline_()
end

-- 初始化信息
function RichLabel:init_nodes_()
    for index, params in pairs(self._parsedtable) do
		local labelname = params.labelname
		-- 检测是否存在解析器
		local parser = self:loadLabelParser_(labelname)
		if parser then
            parser(self, params, self._default)
		end
    end
    -- Debug.info(self._parsedtable)
end

-- 画线条
function RichLabel:draw_underline_()
    self._drawLineNode:clear()
	local charSpace = self._default.charSpace
    local size, x, y
    for _, div in pairs(self._parsedtable) do
        if div.href and div.nodes then
            local c4f, c4b
            for _, node in pairs(div.nodes) do
                if not c4f then
                    if div["fontcolor"] then
                        c4b = self:convertColor(string.sub(div["fontcolor"], 2))
                    else
                        c4b = self._default.fontColor
                    end
                    if c4b then
                        c4f = { r = c4b.r/255, g = c4b.g/255, b = c4b.b/255, a = 1 }
                    else--容错处理..bugly会提示c4b是nil --by lwc
                        c4f = { r = 1, g = 1, b = 1, a = 1 }
                    end
                end
                size = node:getBoundingBox()
                x, y = node:getPosition()
                self:drawLine(cc.p(x - charSpace / 2, y-1), cc.p(x+size.width+charSpace+1, y-1), 1, c4f)
            end
        end
    end
end

-- 增加相应节点到容器
function RichLabel:create_allnodes_()
	local parsedtable = self._parsedtable
	local containerNode = self._containerNode
    containerNode:removeAllChildren()

	local maxw = self._maxWidth
    if maxw <= 0 then maxw = 9999999999 end
	local charspace = self._default.charSpace
    local rows = {}
    local rows_nodes = {}
    local row_w = 0
    local row_h = 0
    local size 
    local str, tmp_str, tmp_char, flag
    local node
    for _, v in pairs(parsedtable) do
        if v.nodes then -- 节点已创建
            for _, node in pairs(v.nodes) do
                size = node:getBoundingBox()
                if row_w + size.width > maxw and row_w > 0 then -- 如果增加这个对象 内容超出 则新超一行
                    table.insert(rows, {h = row_h, w = row_w - charspace, nodes = rows_nodes})
                    row_h = 0
                    row_w = 0
                    rows_nodes = {}
                end
                containerNode:addChild(node)
                node:setAnchorPoint(0,0)
                node:setPositionX(row_w)
                row_w = row_w + size.width + charspace
                row_h = math.max(row_h, size.height)
                table.insert(rows_nodes, node)
            end
        elseif v.charlist then -- 节点未创建
            v.nodes = {}
            node = nil
            tmp_str = ""
            str = tmp_str
            for _, char in pairs(v.charlist) do
                flag = (node and (row_w + node:getBoundingBox().width > maxw))
                if flag or char == '\n' then
                    if node and (str ~= '' or char == '\n') then 
                        if flag and str ~= '' then -- 不是第一个字符 加上当前字符才超出
                            node:setString(str)
                            tmp_str = tmp_char
                        elseif flag and char == '\n' then
                            tmp_str = ""
                            table.insert(rows, {h = row_h, w = row_w - charspace, nodes = rows_nodes})
                            row_w = 0
                            row_h = 0
                            rows_nodes = {}
                        else
                            tmp_str = ""
                        end
                        node:setPositionX(row_w)
                        size = node:getBoundingBox()
                        row_w = row_w + size.width + charspace
                        row_h = math.max(row_h, size.height)
                        table.insert(rows_nodes, node)
                        node = nil
                    end
                    table.insert(rows, {h = row_h, w = math.max(0, row_w - charspace), nodes = rows_nodes})
                    row_h = 0
                    row_w = 0
                    rows_nodes = {}
                end
                str = tmp_str
                if char == '\n' then
                    tmp_char = ""
                else
                    tmp_str = tmp_str..char
                    tmp_char = char
                end
                if node == nil and tmp_str ~= "" then
                    node = v.create_node(tmp_str)
                    containerNode:addChild(node)
                    node:setAnchorPoint(0,0)
                    table.insert(v.nodes, node)
                    node:setString(tmp_str)
                elseif node then
                    node:setString(tmp_str)
                end
            end
            if node then
                -- print("end===>", tmp_str)
                node:setPositionX(row_w)
                size = node:getBoundingBox()
                row_w = row_w + size.width + charspace
                row_h = math.max(row_h, size.height)
                table.insert(rows_nodes, node)
            end
        end
    end
    if next(rows_nodes) then
        table.insert(rows, {h = row_h, w = row_w - charspace, nodes = rows_nodes})
    end
    return rows
end


--[[--
-   getElementsWithGroup: 通过属性分组顺序获取一组的元素集合
]]
function RichLabel:getElementsWithGroup(groupIndex)
    if  self._parsedtable[groupIndex] then
        return self._parsedtable[groupIndex].nodes
    end
end
-- 加载标签解析器，在labels文件夹下查找
function RichLabel:loadLabelParser_(label)
	local labelparserlist = shared_parserlist
	local parser = labelparserlist[label]
	if parser then 
		return parser
	end
	-- 组装解析器名
    local dotindex = string.find(CURRENT_MODULE, "%.%w+$")
    if not dotindex then return
    end
    local currentpath = string.sub(CURRENT_MODULE, 1, dotindex-1)
	local parserpath = string.format("%s.labels.label_%s", currentpath, label)
	
	-- 检测是否存在解析器
	if not PathTool.isFileExist(Tag_Path..label..".luac") then
	-- 	print("找不到luac文件:", Tag_Path..label..".luac")
        if not PathTool.isFileExist(Tag_Path..label..".lua") then
 --            print("找不到lua文件:", Tag_Path..label..".lua")
    		return nil
        end
	end
	local parser = require(parserpath)
	if parser then
		labelparserlist[label] = parser
	end
	return parser
end

-- 解析16进制颜色rgb值
function  RichLabel:convertColor(xstr)
	if not xstr then return 
	end
    local toTen = function (v)
        return tonumber("0x" .. v)
    end

    local b = string.sub(xstr, -2, -1) 
    local g = string.sub(xstr, -4, -3) 
    local r = string.sub(xstr, -6, -5)

    local red = toTen(r)
    local green = toTen(g)
    local blue = toTen(b)
    if red and green and blue then 
    	return cc.c4b(red, green, blue, 255)
    end
end

-- 拆分出单个字符
function RichLabel:stringToChars(str)
	-- 主要用了Unicode(UTF-8)编码的原理分隔字符串
	-- 简单来说就是每个字符的第一位定义了该字符占据了多少字节
	-- UTF-8的编码：它是一种变长的编码方式
	-- 对于单字节的符号，字节的第一位设为0，后面7位为这个符号的unicode码。因此对于英语字母，UTF-8编码和ASCII码是相同的。
	-- 对于n字节的符号（n>1），第一个字节的前n位都设为1，第n+1位设为0，后面字节的前两位一律设为10。
	-- 剩下的没有提及的二进制位，全部为这个符号的unicode码。
    local list = {}
    local len = string.len(str)
    local i = 1 
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
            if c >= 48 and c <=57 then              -- 数字类不分开
                local a, b = string.find(string.sub(str, i), "%d+")
                if a and b then 
                    shift = math.min(20, b - a + 1) -- 最长给20个数字连在一起
                end
            end
            if (c >= 65 and c <=90) or (c >= 97 and c <=122) then              -- 字母类不分开
                local a, b = string.find(string.sub(str, i), "%a+")
                if a and b then
                    shift = math.min(20, b - a + 1) -- 最长给20个数字连在一起
                end
            end
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
    table.insert(list, '')
	return list, len
end

-- 预计转换计算字休
-- function RichLabel:_

function RichLabel:printf(fmt, ...)
	return string.format("RichLabel# "..fmt, ...)
end

-- drawdot(self, cc.p(200, 200))
function RichLabel:drawdot(canvas, pos, radius, color4f)
    radius = radius or 2
    color4f = color4f or cc.c4f(1,0,0,0.5)
    local drawnode = cc.DrawNode:create()
    drawnode:drawDot(pos, radius, color4f)
    canvas:addChild(drawnode)
    return drawnode
end

-- drawrect(self, cc.rect(200, 200, 300, 200))
function RichLabel:drawrect(canvas, rect, borderwidth, color4f, isfill)
    local bordercolor = color4f or cc.c4f(1,0,0,0.5)
    local fillcolor = isfill and bordercolor or cc.c4f(0,0,0,0)
    borderwidth = borderwidth or 2

    local posvec = {
        cc.p(rect.x, rect.y),
        cc.p(rect.x, rect.y + rect.height),
        cc.p(rect.x + rect.width, rect.y + rect.height),
        cc.p(rect.x + rect.width, rect.y)
    }
    local drawnode = cc.DrawNode:create()
    drawnode:drawPolygon(posvec, 4, fillcolor, borderwidth, bordercolor)
    canvas:addChild(drawnode)
    return drawnode
end

--画线
function RichLabel:drawLine(beginPos, endPos, radius, color4)
    self._drawLineNode:drawSegment(beginPos, endPos, radius, color4)
end

-- 创建精灵，现在帧缓存中找，没有则直接加载
-- 屏蔽了使用图集和直接使用碎图创建精灵的不同
function RichLabel:getSprite(filename)
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local spriteFrame = spriteFrameCache:getSpriteFrame(filename)

	if spriteFrame then
		return cc.Sprite:createWithSpriteFrame(spriteFrame)
	end
	return cc.Sprite:create(filename)
end

function RichLabel:DeleteMe(  )

end

return RichLabel
