--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionCreateList = UIUnionListBase:new("UIUnionCreateList")

function UIUnionCreateList:Create()
	self:AddSWF("unionCreateListPanel.swf", true, nil);
end

function UIUnionCreateList:AddNotice(txt)
	if self.TipPos then
		UIFloat:ShowNormal(txt,self.TipPos.x,self.TipPos.y);
	end
end

