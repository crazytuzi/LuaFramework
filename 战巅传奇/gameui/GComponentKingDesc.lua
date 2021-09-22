local GComponentKingDesc = {}--class("GComponentKingDesc")

function GComponentKingDesc:initView( extend )
	if self.xmlTips then
		local data = {
			"<font color=#F3CD67 size=20>专属特权：</font>",
			"<font color=#AAFF85 size=18>    称号：皇家城主专属称号，全服唯一</font>",
			-- "<font color=#1E90FF>    幻武：专属武器“魅影之刃”</font>",
			"<font color=#FF40F8 size=18>    福利：成为城主，获得海量元宝</font>",
		}

		local list = self.xmlTips:getWidgetByName("list")
		list:reloadData(#data, function(subItem)
			local richLabel = subItem:getWidgetByName("richLabel")
			if not richLabel then
				richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 30), space=3,name = "richLabel"})
				richLabel:addTo(subItem)
					:setPosition(cc.p(16,16))
			end
			richLabel:setRichLabel(data[subItem.tag],"",18)
		end, 0, false)
	end
end

return GComponentKingDesc