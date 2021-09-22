local GComponentConfirm = {}

function GComponentConfirm:initView( extend )
	if self.xmlTips then
		-- GameUtilSenior.asyncload(self.xmlTips, "tipsbg", "ui/image/prompt_bg.png")
		local onClickConfirm, onClickCancel = extend.confirmCallBack,extend.cancelCallBack
		local btns = {
			["btnConfirm"] = GameConst.str_titletext_confirm,--"是"
			["btnCancel"] = GameConst.str_titletext_cancel,--"否"
		}
		local checkBox = self.xmlTips:getWidgetByName("checkBox")
		if not checkBox then
			checkBox = GUIConfirm.new("")
				:addTo(self.xmlTips)
				:setPosition(cc.p(120,120))
				:setName("checkBox")
				:hide()
				:setString("下次不再提示")
		end

		local function clickBtns( sender )
			local name = sender:getName()
			if name == "btnConfirm" then
				if GameUtilSenior.isFunction(onClickConfirm) then
					onClickConfirm()
				end
			elseif name == "btnCancel" then
				if GameUtilSenior.isFunction(onClickCancel) then
					onClickCancel()
				end
			end
			if GameUtilSenior.isString(extend.checkBox) and checkBox:isSelected() then
				GameSocket.GUIConfirm[extend.checkBox] = true
			end
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end
		local btn
		for k,v in pairs(btns) do
			btn = self.xmlTips:getWidgetByName(k)
			btn:addClickEventListener(clickBtns)
			btn:setTitleText(extend[k] or v)
		end

		if GameUtilSenior.isString(extend.lblConfirm) then
			self.xmlTips:getWidgetByName("lbl_confirm_content"):setString(extend.lblConfirm)
		elseif GameUtilSenior.isTable(extend.lblConfirm) then
			local list_confirm_content = self.xmlTips:getWidgetByName("list_confirm_content")
			list_confirm_content:removeAllItems()
			for i,v in ipairs(extend.lblConfirm) do
				local richLabel = GUIRichLabel.new({size = cc.size(list_confirm_content:getContentSize().width, 30), space=3,name = "hintMsg"..i})
				richLabel:setRichLabel(v)
				list_confirm_content:pushBackCustomItem(richLabel)
			end
		end
		if GameUtilSenior.isString(extend.checkBox) then
			checkBox:show()
			if GameSocket.GUIConfirm[extend.checkBox] then
				onClickConfirm()
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = self.str})
			end
		end
	end
end

function GComponentConfirm:closeCall()
	
end
-- local param = {
-- 	name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = result.str, btnConfirm = result.labelConfirm,btnCancel = result.labelCancel,
-- 	confirmCallBack = function ()
-- 		self:PushLuaTable(result.callFunc,result.book)
-- 	end
-- }
-- GameSocket:dispatchEvent(param)
return GComponentConfirm