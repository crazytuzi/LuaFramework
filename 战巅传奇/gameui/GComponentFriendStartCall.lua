local GComponentFriendStartCall = {}--class("GComponentFriendStartCall")

function GComponentFriendStartCall:initView( extend )
	if self.xmlTips then

		-- GameUtilSenior.asyncload(self.xmlTips, "tipsbg", "ui/image/prompt_bg.png")
		self.playerName = extend.playerName or ""
		self.xmlTips:getWidgetByName("lblname"):setString(self.playerName)

		self.vcoin = extend.vcoin or "0"
		self.xmlTips:getWidgetByName("lblvcoin"):setString(self.vcoin)

		local btns = {"btn_call"}
		local function clickBtns( sender )
			local name = sender:getName()
			if name == btns[1] then
				if os.time()-GameSocket.lastCallFriendTime>=120 then
					GameSocket:PushLuaTable("gui.PanelFriend.onPanelData", GameUtilSenior.encode({actionid = "callFriend", param = {self.playerName}}))
				else
					GameSocket:alertLocalMsg("距离下次召唤好友还有"..(120-os.time()+GameSocket.lastCallFriendTime).."秒！", "alert")
				end
			end
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end
		
		for k,v in pairs(btns) do
			self.xmlTips:getWidgetByName(v):addClickEventListener(clickBtns)
		end

	end
end

return GComponentFriendStartCall