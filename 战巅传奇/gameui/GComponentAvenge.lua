local GComponentAvenge = {}--class("GComponentAvenge")
--复仇宣言
function GComponentAvenge:initView(extend)
	if self.xmlTips then
		self.revengeInfo = ""
		local img_input_bg = self.xmlTips:getWidgetByName("img_input_bg"):setTouchEnabled(true)
		self.xmlTips:getWidgetByName("layerbg"):setTouchEnabled(true)
		local function updateRevengeInfo()
			local richRevenge = img_input_bg:getChildByName("richRevenge"):show()
			richRevenge:setRichLabel("<font color=#E7BA52>"..self.revengeInfo.."</font>", "", 18)
		end

		local strlen
		local function onEdit(event,editBox)
			
			if event == "began" then
				
			elseif event == "return" then
				self.revengeInfo = editBox:getText()
				updateRevengeInfo()
				editBox:setText("")
			end
		end
		local editbox = img_input_bg:getWidgetByName("editboxFind")
		local pSize = img_input_bg:getContentSize()
		if not editbox then
			editbox = GameUtilSenior.newEditBox({
				name = "editboxFind",
				image = "image/icon/null.png",
				size = cc.size(pSize.width, 28),
				listener = onEdit,
				color = GameBaseLogic.getColor(0xe7ba52),
				x = 0,
				y = 0,
				fontSize = 18,
				maxlen = 30,
				inputMode = cc.EDITBOX_INPUT_MODE_ANY,
				placeHolder = "",
				placeHolderColor = GameBaseLogic.getColor(0xe7ba52),
			})

			editbox:align(display.LEFT_TOP,0,pSize.height)
				-- :setPlaceHolder(GameConst.str_input)
				:addTo(img_input_bg)
				:setTouchEnabled(false)
		end


		local richRevenge = img_input_bg:getChildByName("richRevenge")
		if not richRevenge then
			richRevenge = GUIRichLabel.new({size = cc.size(pSize.width, 30),fontSize = 18, space=5,name = "taskDesp"})
			richRevenge:setName("richRevenge")
			richRevenge:setColor(GameBaseLogic.getColor(0xB2A58B))
			img_input_bg:addChild(richRevenge)
		end
		richRevenge:setRichLabel("", "", 18)
		richRevenge:align(display.LEFT_TOP, 0, pSize.height)

		GUIFocusPoint.addUIPoint(img_input_bg, function ()
			editbox:setText(self.revengeInfo)
			-- richRevenge:setRichLabel("", "", 18)
			richRevenge:runAction(cca.seq({cca.delay(1/60), cca.hide()}))
			editbox:touchDownAction(editbox, ccui.TouchEventType.ended)
		end)

		
		local btns = {"btn_sure","btn_close"}
		local function clickBtns( sender )
			local name = sender:getName()
			if name == btns[1] then
				-- local str = editbox:getText()
				GameSocket:PushLuaTable("gui.PanelFriend.onPanelData", GameUtilSenior.encode({actionid = "revengeChange",str = self.revengeInfo}))
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
			elseif name == btns[2] then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
			end
		end

		for k,v in pairs(btns) do
			self.xmlTips:getWidgetByName(v):addClickEventListener(clickBtns)
		end
		cc.EventProxy.new(GameSocket,self.xmlTips):addEventListener(GameMessageCode.EVENT_REVENGE_CHANGE,function(event)
			self.revengeInfo = event.str
			updateRevengeInfo("")
		end)

		GameSocket:PushLuaTable("gui.PanelFriend.onPanelData", GameUtilSenior.encode({actionid = "getRevenge"}))
	end
end

return GComponentAvenge