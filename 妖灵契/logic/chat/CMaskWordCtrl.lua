local CMaskWordCtrl = class("CMaskWordCtrl")

function CMaskWordCtrl.ctor(self)
	self.m_MaskWordTree = CMaskWordTree.New()
	self.m_MaskWordTree:UpdateNodes(data.maskworddata.DATA)
end

function CMaskWordCtrl.ReplaceMaskWord(self, str)
	return self.m_MaskWordTree:ReplaceMaskWord(str)
end

function CMaskWordCtrl.IsContainMaskWord(self, str)
	return self.m_MaskWordTree:IsContainMaskWord(str)
end

function CMaskWordCtrl.GetMaskWord(self, str)
	return self.m_MaskWordTree:GetMaskWord(str)
end

function CMaskWordCtrl.IsContainSpecialWord(self, str)
	local t = {" "}
	local d = string.getutftable(str)
	for i,v in ipairs(d) do
		for _i, _v in ipairs(t) do
			if v == _v then
				return true
			end
		end
	end
	return false
end

function CMaskWordCtrl.ReplaceHideStr(self, str)
	if self:IsContainHideStr(str) then
		str = "{link14,3,}"..str
	end
	return str
end

function CMaskWordCtrl.IsContainHideStr(self, str)
	local s = string.gsub(str, "%b{}", "")
	s = string.gsub(s, "#%a", "")
	s = string.gsub(s, "#%d+", "")
	local strList = string.getutftable(s)
	if self:IsManyDigit(strList) then
		return true
	end
	
	if self:IsHideStr(s) then
		return true
	end
	
	return false
end

CMaskWordCtrl.m_DigitList = {
	"①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", 
	"⑴", "⑵", "⑶", "⑷", "⑸", "⑹", "⑺", "⑻", "⑼",
	"⒈", "⒉", "⒊", "⒋", "⒌", "⒍", "⒎", "⒏", "⒐",
	"㈠", "㈡", "㈢", "㈣", "㈤", "㈥", "㈦", "㈧", "㈨",
	"Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ",
	"❶", "❷", "❸", "❹", "❺", "❻", "❼", "❽", "❾", 
	"一", "二", "三", "四", "五", "六", "七", "八", "九",
	"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖",
	"零", "〇", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	"a", "b", "c", "d", "d", "e", "f", "g", "h", "i", "j", "k",
	"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w",
	"x", "y", "z",
}
function CMaskWordCtrl.IsManyDigit(self, strList)
	local iAmount, iMaxAmount = 0, 7
	for _, c in ipairs(strList) do
		c = string.lower(c)
		if table.index(CMaskWordCtrl.m_DigitList, c) then
			iAmount = iAmount + 1
			if iAmount >= iMaxAmount then
				break
			end
		end
	end
	if iAmount >= iMaxAmount then
		printc("连续字符屏蔽")
		return true
	end
	return false
end

function CMaskWordCtrl.IsHideStr(self, str)
	local str = string.lower(str)
	for _, v in ipairs(data.chatdata.ADWords) do
		if string.match(str, v.word) then
			printc(v.word.."字符串屏蔽")
			return true
		end
	end
	return false
end

function CMaskWordCtrl.GetMaskWordTree(self)
	return self.m_MaskWordTree
end

return CMaskWordCtrl