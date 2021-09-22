local GComponentItem = {}

function GComponentItem:initView( extend )
	if self.xmlTips then
		local data = extend.tipsdata or {}
		self.xmlTips:getWidgetByName("lbl_name"):setString(data.name or "")
		self.xmlTips:getWidgetByName("lbl_type"):setString(data.type or "装备")
		self.xmlTips:getWidgetByName("lbl_level"):setString(data.level or "")
		self.xmlTips:getWidgetByName("img_icon"):loadTexture(data.icon or "null")

		local desp = {}
		if GameUtilSenior.isString(data.desp) then
			desp = {data.desp}
		elseif GameUtilSenior.isTable(data.desp) then
			desp = data.desp
		end

		local list = self.xmlTips:getWidgetByName("list")
		list:reloadData(#desp, function(subItem)
			local richLabel = subItem:getWidgetByName("richLabel")
			if not richLabel then
				richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 30), space=3,name = "richLabel"})
				richLabel:addTo(subItem)
					:setPosition(cc.p(6,16))
			end
			richLabel:setRichLabel(desp[subItem.tag],"",18)
		end, 0, false)
	end
end

return GComponentItem