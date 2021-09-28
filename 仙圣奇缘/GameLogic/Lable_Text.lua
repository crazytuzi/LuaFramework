--------------------------------------------------------------------------------------
-- 文件名:	Lable_Text.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2016-01-14 10:24
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  组合文字颜色的lable 不能支持换行的
---------------------------------------------------------------------------------------
local Lable_Color = 
{
	["#00"] = ccc3(255, 255, 255),				--白色	品质1
	["#01"] = ccc3(180, 180, 180), 				--灰色	品质1
	["#02"] = ccc3(35, 220, 55),   				--深绿	品质2
	["#03"] = ccc3(0, 191, 255),   				--深蓝	品质3
	["#04"] = ccc3(255, 0, 255),   				--洋红	品质4
	["#05"] = ccc3(255, 241, 0),   				--金色	品质5
	["#06"] = ccc3(255, 0, 0),     				--纯红	品质6
	["#07"] = ccc3(255, 255, 255), 				--白色
	["#08"] = ccc3(144, 238, 144), 				--浅绿
	["#09"] = ccc3(135, 206, 250), 				--浅蓝
	["#10"] = ccc3(238, 130, 238), 				--粉色
	["#11"] = ccc3(153, 50, 204),  				--紫色
	["#12"] = ccc3(207, 181, 59),  				--暗金色
	["#13"] = ccc3(255, 140, 0),   				--橙色
	["#14"] = ccc3(255, 69, 0),    				--橘红
	["#15"] = ccc3(255, 20, 147),  				--DeepPink
	["#16"] = ccc3(245, 222, 179), 				--麦色
	["#17"] = ccc3(255, 184, 17),  				--描述橙色
	["#18"] = ccc3(181, 174, 156), 				--描述暗黄
	["#19"] = ccc3(205, 92, 92),   				--印度红
	["#20"] = ccc3(50, 255, 50),   				--亮绿--界面提示
	["#21"] = ccc3(100, 100, 100),   			--灰色
	["#22"] = ccc3(0, 255, 0),   				--绿色
}

local Color_Text = class("Color_Text")
Color_Text.__index = Color_Text

function Color_Text:ctor()
	self.color = Lable_Color["#00"]
	self.text = ""
end

--strParse cXX***** or *******
function Color_Text:inittext(strParse)
	local txt = tostring(strParse)
--	print("====Color_Text:inittext====="..txt)

	if string.find(txt, '#', 1) then
		local key = string.sub(txt,1, 3)
--		key = string.lower(key)
		if Lable_Color[key] then
			self.color = Lable_Color[key]
		end
		
--		print("====Color_Text:inittext=== key="..key)

		if string.len(txt) > 3 then
			self.text = string.sub(txt, 4, string.len(txt))
		end
	else
		self.text = txt
	end

--	print("====Color_Text:inittext=== text="..self.text)
end


--[[
 @lableModle 标签模版 通过模版的锚点 平接文子
]]
function gCreateColorLable(lableModle ,strText)
	local txt = tostring(strText)
	local tbText = {}
	local beg = 1
	local char = ""
	local ColorText = ""
    while(beg <= string.len(txt))do

    	local c = string.byte(txt, beg)
--    	print("===char==="..c)
        local shift = 1
        --0.192.224.240.248.252
        if c >= 0x00 and c < 0xc0 then shift = 1
        elseif c >= 0xc0 and c < 0xe0 then shift = 2
        elseif c >= 0xe0 and c < 0xf0 then shift = 3
        elseif c >= 0xf0 and c < 0xf8 then shift = 4
        elseif c >= 0xf8 and c < 0xfc then shift = 5
        else  shift = 6
        end
        char = string.sub(txt, beg, beg+shift-1)

        --if c > 0 and c <= 127 then --英文字符
            --shift = 1
            --char = string.sub(txt, beg, beg)

            if char == "#" then
            	local check = string.sub(txt, beg, beg+2)
            	-- print("=check=gCreateColorLable=="..check)
            	if Lable_Color[check] ~= nil then
            		-- print("找到了一个颜色 "..check)
            		if ColorText ~= "" then --有一条记录了
            			table.insert(tbText, ColorText)
            			ColorText = ""
            		end
            	end
            end
        --else
			--shift = 3
			--char = string.sub(txt, beg, beg+shift-1)
        --end
        ColorText = ColorText..tostring(char)
        beg = beg + shift
    end
    --判断最后一个有没有加入
    local beg = #tbText
    if tbText[beg] == nil or tbText[beg] ~= ColorText then
    	table.insert(tbText, ColorText)
    end


    if not lableModle then return false end
--    echoj("=======createtbtext===", tbText)
    --创建
    local offx = 0
    local backtext = ""
    for k, v in ipairs(tbText)do
    	local lable = Color_Text.new()
    	lable:inittext(v)
   
    	if lableModle and lableModle:isExsit() and lable.text ~= "" then
    		local  labelnode = Label:create()
			labelnode:setText(lable.text)
			backtext = backtext..lable.text
			labelnode:setColor(lable.color)

			labelnode:setFontSize(lableModle:getFontSize())
			labelnode:setAnchorPoint(ccp(0,0))
			if offx > 0 then
				local pos = labelnode:getPosition()
				pos.x = pos.x + offx
				labelnode:setPosition(ccp(pos.x,pos.y))
			end

			lableModle:addChild(labelnode)
			offx = offx + labelnode:getContentSize().width
    	end
    end

    lableModle:setAnchorPoint(ccp(0,0))
	local show = ""
	for i=1, g_string_num(backtext) do show = show.." " end
	lableModle:setText(show)

	return offx
end

--去掉颜色转意字符，分段翻译
function _TC(mystring)

    local tmpStr = ""
    local reStr = ""
    local i = 1
	while i <=  string.len(mystring) do
		local c = string.byte(mystring, i)
        local shift = 1
        --0.192.224.240.248.252
        if c >= 0x00 and c < 0xc0 then shift = 1
        elseif c >= 0xc0 and c < 0xe0 then shift = 2
        elseif c >= 0xe0 and c < 0xf0 then shift = 3
        elseif c >= 0xf0 and c < 0xf8 then shift = 4
        elseif c >= 0xf8 and c < 0xfc then shift = 5
        else  shift = 6
        end

        local substr = string.sub(mystring, i, i+shift-1)

        if substr == "#"  then
            local check = string.sub(mystring, i, i+2)
            if Lable_Color[check] ~= nil then
                reStr = reStr .. _T(tmpStr)
                reStr = reStr .. check
                tmpStr = ""
                i = i + 2
            end

        else
            tmpStr = tmpStr .. substr
        end
        i = i + shift
    end 
    if  tmpStr ~= "" then reStr = reStr .. _T(tmpStr) end

    return reStr

end