local itemInfo = import(".itemInfo")
local chatItem = class("chatItem", function ()
	return display.newNode()
end)
chatItem.ctor = function (self, hScale, labelM, data, noTouch, x, y)
	local h = labelM.wordSize.height*hScale - 2
	local w = h
	local bg = res.get2("pic/common/itembg.png"):anchor(0, 0):add2(self)

	bg.scalex(bg, w/bg.getw(bg))
	bg.scaley(bg, h/bg.geth(bg))
	res.get("items", data.lookID):pos(w/2, h/2):add2(self)

	if not noTouch then
		bg.enableClick(bg, function ()
			local p = self:convertToWorldSpace(cc.p(self:centerPos()))

			if data.itemData then
				itemInfo.show(data.itemData, p)
			else
				g_data.client:setLastQueryChatItem(data.makeIndex, data.name, p.x, p.y)

				local rsb = DefaultClientMessage(CM_QueryFocusItem)
				rsb.FItemIdent = data.makeIndex

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end)
	end

	local fontSize = math.min(labelM.fontSize, 18)
	local title = an.newLabel(data.name, slot10, 1, {
		color = cc.c3b(0, 255, 255)
	}):anchor(0, 0.5):pos(w + 2, h/2):add2(self)
	local sizeW = w + title.getw(title)

	self.size(self, sizeW, h)

	return 
end

return chatItem
