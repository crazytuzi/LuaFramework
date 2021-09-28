--
-- Author: zhouhongjie@apowo.com
-- Date: 2014-07-09 19:47:53
--
require("utility.richtext.richText")
local RichTextScene = class('RichTextScene', function ()
	return display.newScene('RichTextScene')
end)

function RichTextScene:ctor()

	local htmlText = "<font size=\"30\" color=\"#ff0000\"><a href='http://www.baidu.com'>1234567梵蒂冈的非官方的890123gdfg过大范甘迪发4567890</a></font><font size=\"24\" color=\"#ffff00\">遇sdfdsfd甘道夫到</font><font size=\"36\" color=\"#ff00ff\">噜啦啦房顶上丰盛的广泛地</font>"
	getRichText(htmlText, 300, function (href)
		print("点击了" .. href)
	end):pos(0, display.top - 60):addTo(self)

	-- ui.newTTFLabel({text = '一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十', y = display.cy, x = 0}):addTo(self)
	-- local str, leftStr = getSubStrByWidth("一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十", "Arial", 24, 160)
	-- print(str, leftStr)
end

return RichTextScene