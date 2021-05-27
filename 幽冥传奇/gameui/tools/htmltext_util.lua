-------------------------------------------------
--专门解程html的工具。如<font color='#00ff00' size='15'>英雄</font>,去哪呢？
--解析流程:
--1.对html标签进行深入拆分，并记录标签的起始位置
--2.根据起始位置，分析标签属性，并记录
--3.对各个记录进行分别串化
--4.对各个记录点根据配对偶数,范围取值进一步分析两点之间的内容，color,size等属性
--5.最终生成完整table。如{{text = "英雄", color = font_color, size = font_size},{text = "去哪呢", color = font_color, size = font_size}}
------------------------------------------------
HtmlTextUtil = HtmlTextUtil or {}
HtmlTextUtil.DEFAULT_COLOR = "ffffff"
HtmlTextUtil.FONT_SIZE = 20

function HtmlTextUtil.SetString(rich_text, content)
	if rich_text == nil then
		return
	end
	rich_text:removeAllElements()
	HtmlTextUtil.pos_t = {}
	HtmlTextUtil.node_t = {}
	HtmlTextUtil.attribute_t = {}

	if content ~= "" and content ~= nil then
		HtmlTextUtil.ParseContent(rich_text, content)

		local color = HtmlTextUtil.DEFAULT_COLOR
		local size = HtmlTextUtil.FONT_SIZE
		for k,v in pairs(HtmlTextUtil.node_t) do
			color = v.color or color
			size = v.size or size
			local color3b = cc.c3b("0x" .. string.sub(color, 1, 2), "0x" .. string.sub(color, 3, 4), "0x" .. string.sub(color, 5, 6))
			XUI.RichTextAddText(rich_text, v.text, COMMON_CONSTS.FONT, size, color3b, nil, nil, v.outline_size)
		end
	end
end

--解析html内容
function HtmlTextUtil.ParseContent(rich_text, content)
	content = "<font color='#" .. HtmlTextUtil.DEFAULT_COLOR.. "' size='" .. HtmlTextUtil.FONT_SIZE .. "'>" .. content .. "</font>"
	HtmlTextUtil.SplitGroup(content,0)	
	for k,v in pairs(HtmlTextUtil.pos_t) do
		if k % 2 == 0 and HtmlTextUtil.pos_t[k + 1] ~= nil then
			local str = string.sub(content, HtmlTextUtil.pos_t[k].pos + 1, HtmlTextUtil.pos_t[k + 1].pos - 1)
			if str ~= nil and str ~= "" then
				local font_color = HtmlTextUtil.DEFAULT_COLOR
				local font_size = HtmlTextUtil.FONT_SIZE
				local font_outline_size = nil
				for m,n in pairs(HtmlTextUtil.attribute_t) do
					if HtmlTextUtil.pos_t[k].pos >= n.s and HtmlTextUtil.pos_t[k].pos <= n.e then
						font_color = n.color
						font_size = n.size
						font_outline_size = n.outline_size
					end
				end
				HtmlTextUtil.node_t[#HtmlTextUtil.node_t + 1] = {text = str, color = font_color, size = font_size, outline_size = tonumber(font_outline_size)}
			end
		end
	end
end

--对html进行深入分割
function HtmlTextUtil.SplitGroup(content,pos_offest)
	local start_pos = 1
	while true do
		local s1, e1 = string.find(content, "<font(.-)>", start_pos)
		start_pos = e1
		if s1 ~= nil then
			local s2,e2 = HtmlTextUtil.GetMateTagPos(content, start_pos)
			if s2 ~= 0 and s2 ~= nil then
				local one_html_str = string.sub(content, s1, e2)
				local t = {}
				t.s = pos_offest + e1
				t.e = pos_offest + s2
				HtmlTextUtil.ParseTagAttribute(one_html_str, t)
				HtmlTextUtil.attribute_t[#HtmlTextUtil.attribute_t + 1] = t

				start_pos = e2
				HtmlTextUtil.pos_t[#HtmlTextUtil.pos_t + 1] = {pos = pos_offest + s1, color = t.color, size = t.size, outline_size = t.outline_size}
				HtmlTextUtil.pos_t[#HtmlTextUtil.pos_t + 1] = {pos = pos_offest + e1, color = t.color, size = t.size, outline_size = t.outline_size}
				HtmlTextUtil.SplitGroup(string.sub(content, e1 + 1, s2 - 1), pos_offest + e1)
				HtmlTextUtil.pos_t[#HtmlTextUtil.pos_t + 1] = {pos = pos_offest + s2, color = t.color, size = t.size, outline_size = t.outline_size}
				HtmlTextUtil.pos_t[#HtmlTextUtil.pos_t + 1] = {pos = pos_offest + e2, color = t.color, size = t.size, outline_size = t.outline_size}
			end
		else
			break
		end
	end
end

function HtmlTextUtil.ParseTagAttribute(content, t)
	local i, j = string.find(content, "color='#(.-)'")

	if i ~= nil and j ~= nil then
		t.color = string.sub(content, i + 8, j - 1)
	else
		t.color = nil
	end

	i, j = string.find(content, "size='(.-)'")
	if i ~= nil and j ~= nil then
		t.size = string.sub(content, i + 6, j - 1)
	else
		t.size = nil
	end

	i, j = string.find(content, "outline_size='(.-)'")
	if i ~= nil and j ~= nil then
		t.outline_size = string.sub(content, i + 14, j - 1)
	else
		t.outline_size = nil
	end
end

--找到成对匹配的标签位置
function HtmlTextUtil.GetMateTagPos(content, start_pos)
	if content == nil or start_pos == nil then
		return 0
	end
	 local num = 1
	 local flag = 1
	 while true do
	 	local i, j = string.find(content, "<font(.-)>", start_pos)
	 	local m, n = string.find(content, "</font>", start_pos)
	 	if m == nil then
 			Log("html格式错误，找不到对应的标签")
			return 0
	 	end

		if j == nil or m < j then		--找到
			start_pos = m + 1
			flag = flag - 1
		else
			start_pos = j + 1
			flag = flag + 1
		end

		if flag == 0 then
			return m, n
		else
			num = num + 1
		end
		if num > 255 then
			Log("html格式错误，找不到对应的标签")
			return 0
		end
	 end
end

