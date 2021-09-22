local GComponentGuidCreate = {}

function GComponentGuidCreate:initView( extend )
	if self.xmlTips then
		--GameUtilSenior.asyncload(self.xmlTips, "tipsbg", "ui/image/prompt_bg.png")
		local onClickConfirm = extend.confirmCallBack
		local noAutoClose = extend.noAutoClose

		local imgEditboxBg = self.xmlTips:getWidgetByName("img_editbox_bg")
		local pSize = imgEditboxBg:getContentSize()

		local function onEdit()
			-- body
		end

		local mEditBox = GameUtilSenior.newEditBox({
			name = "editBox",
			image = "#null",
			size = pSize,
			listener = onEdit,
			color = GameBaseLogic.getColor(0xD6BEA9),
			x = 0,
			y = 0,
			fontSize = 20,
			inputMode = cc.EDITBOX_INPUT_MODE_SINGLELINE,
		})

		mEditBox:align(display.CENTER_LEFT,0,pSize.height * 0.5)
			:setPlaceHolder("请输入帮会名")
			:setPlaceholderFontColor(GameBaseLogic.getColor(0xb1a174))
			:setPlaceholderFontSize(20)
			:setPlaceholderFontName(FONT_NAME)
			:addTo(imgEditboxBg)
			:setString("")

		
		local function clickBtns( sender )
			if GameUtilSenior.isFunction(onClickConfirm) then
				onClickConfirm(mEditBox:getText())
			end
			if not noAutoClose then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
			end
		end

		local btnCreateGuild = self.xmlTips:getWidgetByName("btn_create_guild")
		btnCreateGuild:addClickEventListener(clickBtns)

	end
end

-- local param = {
-- 	name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = result.str, btnConfirm = result.labelConfirm,btnCancel = result.labelCancel,
-- 	confirmCallBack = function ()
-- 		self:PushLuaTable(result.callFunc,result.book)
-- 	end
-- }
-- GameSocket:dispatchEvent(param)
return GComponentGuidCreate