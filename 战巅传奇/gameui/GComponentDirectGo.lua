local GComponentDirectGo = class("GComponentDirectGo")

function GComponentDirectGo:initView(extend)
	if self.xmlTips then
		local param = extend.param
		self.xmlTips:setContentSize(display.width, display.height):setTouchEnabled(true)
		self.xmlTips:getWidgetByName("box_fly"):align(display.CENTER, display.cx, display.cy)
		-- GameUtilSenior.asyncload(self.xmlTips, "tips_bg", "ui/image/prompt_bg.png")
		print("GComponentDirectGo:initView", extend.str, param.flyId, param.time)

		local function pushFlyButton(sender)
			GameSocket:PushLuaTable("player.reqDirectFly",GameUtilSenior.encode({flyId = param.flyId}))
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end
		local timeRemain = param.time

		local lblConfirmTime = self.xmlTips:getWidgetByName("lbl_confirm_time"):setString(timeRemain.."秒后自动传送")

		lblConfirmTime:runAction(cca.repeatForever(cca.seq({
			cca.delay(1),
			cca.cb(function (sender)
				if timeRemain <= 0 then
					lblConfirmTime:stopAllActions()
					pushFlyButton()
				else
					timeRemain = timeRemain - 1
					lblConfirmTime:setString(timeRemain.."秒后自动传送")
				end
			end)
		})))

		local btnConfirm = self.xmlTips:getWidgetByName("btn_confirm")
		GUIFocusPoint.addUIPoint(btnConfirm, pushFlyButton)
	end
end

return GComponentDirectGo