local GComponentFriend ={}-- class("GComponentFriend")
--收到加好友请求
--可能同时收到多条加好友请求

function GComponentFriend:initView( extend )
	if self.xmlTips then
		-- GameUtilSenior.asyncload(self.xmlTips, "tipsbg", "ui/image/prompt_bg.png")
		
		self.playerName = extend.pName or ""
		self.xmlTips:getWidgetByName("lblname"):setString(self.playerName)

		local btns = {"btn_agree","btn_refuse"}
		local function clickBtns( sender )
			local name = sender:getName()
			if name == btns[1] then
				GameSocket:FriendApplyAgree(self.playerName,1)
			elseif name == btns[2] then
				GameSocket:FriendApplyAgree(self.playerName,0)
			end
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end

		for k,v in pairs(btns) do
			self.xmlTips:getWidgetByName(v):addClickEventListener(clickBtns)
		end

	end
end

return GComponentFriend