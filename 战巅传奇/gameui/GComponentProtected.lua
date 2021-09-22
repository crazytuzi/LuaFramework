local GComponentProtected ={}

function GComponentProtected:initView( extend )
	if self.xmlTips then
		self.xmlTips:align(display.CENTER, display.cx, display.height * 0.6)
		local wordDefendResult = self.xmlTips:getWidgetByName("word_defend_result")
		local btnConfirm = self.xmlTips:getWidgetByName("btn_confirm")
		btnConfirm:setTitleText("确定")

		GUIFocusPoint.addUIPoint(btnConfirm, function (pSender)
			-- GameSocket:PushLuaTable("gui.PanelDefend.onPanelData", GameUtilSenior.encode({actionid = "getAward"}));
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS, str = "defendResult"})
		end)

		local result = extend.param

		-- print("GameUtilSenior.encode", result.success, result.successType, GameUtilSenior.encode(result.awards))

		if result.success then
			wordDefendResult:show()
			--self.xmlTips:getWidgetByName("tips_bg"):loadTexture("ui/image/protect_success_bg.png")
			GameUtilSenior.asyncload(self.xmlTips, "tips_bg", "ui/image/protect_success_bg.png")
			self.successType = result.successType
			self.defendLevel = result.defendLevel
			if result.successType == "sweep" then
				wordDefendResult:loadTexture("word_defend_success_sweep", ccui.TextureResType.plistType)
			else
				wordDefendResult:loadTexture("word_defend_success_challenge", ccui.TextureResType.plistType)
			end
		else
			wordDefendResult:hide()
			--self.xmlTips:getWidgetByName("tips_bg"):loadTexture("ui/image/protect_failure_bg.png")
			GameUtilSenior.asyncload(self.xmlTips, "tips_bg", "ui/image/protect_failure_bg.png")
			-- GameUtilSenior.asyncload(self.xmlTips, "tips_bg", "ui/image/img_defend_failure_bg.png")
		end

		local wordDefendFailureTips = self.xmlTips:getWidgetByName("word_defend_failure_tips"):show()
		
		local awards
		if result.awards and #result.awards > 0 then
			awards = result.awards
			btnConfirm:setTitleText("领取奖励")
			wordDefendFailureTips:hide()
		end
		local awardIcon, param
		for i=1,3 do
			awardIcon = self.xmlTips:getWidgetByName("award_icon"..i):show()
			if awards then
				param = {parent = awardIcon}
				if awards[i] then
					param.typeId = awards[i].id
					param.num = awards[i].count
				end
				-- print("////////GUIItem.getItem///////", param.typeId, param.num)
				GUIItem.getItem(param)
			else
				awardIcon:hide()
			end
		end

	end
end

function GComponentProtected:closeCall()
	GameSocket:PushLuaTable("gui.PanelDefend.onPanelData", GameUtilSenior.encode({actionid = "getAward", awardType = self.successType, level = self.defendLevel}));
end

return GComponentProtected