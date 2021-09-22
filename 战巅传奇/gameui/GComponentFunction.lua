local GComponentFunction = {}

function GComponentFunction:initView(extend)
	if self.xmlTips then
		-- 50023
		local mCanHide = false
		local xmlTips = self.xmlTips
		self.xmlTips:setContentSize(display.width, display.height):setTouchEnabled(true)
		self.xmlTips:getWidgetByName("box_open"):align(display.CENTER, display.cx, display.cy):hide()
		local imgShowFun = self.xmlTips:getWidgetByName("imgShowFun"):setLocalZOrder(2)
		local funTitle = self.xmlTips:getWidgetByName("funTitle")

		local effect = self.xmlTips:getWidgetByName("box_open"):getChildByName("funEffect")
		if not effect then
			effect = cc.Sprite:create()
			effect:setName("funEffect"):setLocalZOrder(1)
			self.xmlTips:getWidgetByName("box_open"):addChild(effect)
			local animate = cc.AnimManager:getInstance():getPlistAnimate(4, 50023, 4, 3,false,false,0,function(animate,shouldDownload)
							if animate then
								effect:runAction(cca.repeatForever(animate))
							end
							if shouldDownload==true then
								effect:release()
							end
						end,
						function(animate)
							effect:retain()
						end)
			effect:setPosition(163,167.5)
		end

		GameUtilSenior.asyncload(self.xmlTips, "funBg", "ui/image/MenuIcon/open_img_dt.png")
		GameUtilSenior.asyncload(self.xmlTips, "imgTitleBg", "ui/image/MenuIcon/open_img_zidi.png")
		local imgFlyIcon = self.xmlTips:getWidgetByName("imgFlyIcon")
		imgFlyIcon:show()
		GameUtilSenior.asyncload(self.xmlTips, "imgFlyIcon", "ui/image/MenuIcon/"..extend.icon..".png")
		GameUtilSenior.asyncload(self.xmlTips, "imgShowFun", "ui/image/MenuIcon/"..extend.icon..".png")
		funTitle:setString(extend.funName)
		imgFlyIcon:setPositionY(display.height - 195)
		imgFlyIcon:setPositionX(display.width)
		local targetPosx = display.cx + imgFlyIcon:getContentSize().width / 2
		local targetPosy = display.cy
		local function startHide()
			if mCanHide then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
				if extend.openpanel and extend.openpanel ~= "" and extend.openpanel ~= "null" then
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = extend.openpanel})
				end
			end
		end
		imgFlyIcon:runAction(cc.Sequence:create(
			cca.moveTo(0.5,targetPosx,targetPosy),
			cc.CallFunc:create(function ( ... )
				xmlTips:getWidgetByName("box_open"):show()
				imgFlyIcon:hide()
				mCanHide = true
				xmlTips:runAction(cca.seq({
					cca.delay(7),
					cca.cb(function ()
						startHide()
					end)
				}))
			end)
			))
		GUIFocusPoint.addUIPoint(self.xmlTips, function ()
			startHide()
		end)
	end
end
return GComponentFunction