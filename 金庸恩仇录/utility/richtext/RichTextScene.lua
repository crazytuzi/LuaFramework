require("utility.richtext.richText")
local RichTextScene = class("RichTextScene", function ()
	return display.newScene("RichTextScene")
end)
function RichTextScene:ctor()
	local htmlText = "<font size=\"30\" color=\"#ff0000\"><a href='http://www.baidu.com'>1234567梵蒂冈的非官方的890123gdfg过大范甘迪发4567890</a></font><font size=\"24\" color=\"#ffff00\">遇sdfdsfd甘道夫到</font><font size=\"36\" color=\"#ff00ff\">噜啦啦房顶上丰盛的广泛地</font>"
	local text = getRichText(htmlText, 300, function (href)
		dump(common:getLanguageString("@dian") .. href)
	end)
	text:pos(0, display.top - 60)
	text:addTo(self)
end

return RichTextScene
