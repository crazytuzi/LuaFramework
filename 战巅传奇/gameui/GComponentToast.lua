local GComponentToast = class("GComponentToast")

function GComponentToast:initView(extend)
	if self.xmlTips then
		
		-- GameUtilSenior.asyncload(self.xmlTips, "tipsbg", "ui/image/prompt_bg.png")
		local onClickConfirm = extend.confirmCallBack
		local btns = {
			["btnConfirm"] = GameConst.str_titletext_confirm,--"是"
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
			local lbl_confirm_content = self.xmlTips:getWidgetByName("lbl_confirm_content")
			lbl_confirm_content:setString("")--extend.lblConfirm
			local richtext = self.xmlTips:getWidgetByName("richtext")			
			local cloneStr,n = GameBaseLogic.clearHtmlText(extend.lblConfirm)
			local length = cc.SystemUtil:getUtf8StrLen(cloneStr)
			local multiline = false
			length = length*21
			if length>lbl_confirm_content:getContentSize().width then
				multiline = true
			end
			length = GameUtilSenior.bound(0, length, lbl_confirm_content:getContentSize().width)
			if not richtext then
				richtext = GUIRichLabel.new({size = cc.size(length, 30),space = 10,anchor = cc.p(0,0)})
					:addTo(lbl_confirm_content)
					:setName("richtext")
					:setPosition(GameUtilSenior.half(lbl_confirm_content:getContentSize()))
			end
			richtext:setContentSize(cc.size(length, 30))
			richtext:setRichLabel(extend.lblConfirm,20)
			if not multiline then
				richtext:setPositionX(lbl_confirm_content:getContentSize().width/2-length/2)
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

return GComponentToast
--[[
	local param = {
		name = GameMessageCode.EVENT_SHOW_TIPS, str = "alert", 
		lblConfirm =  "您的镖车被".."<font color=#b2a58b>埃斯沙德</font>击碎", 
		btnConfirm = "确定",
		confirmCallBack = function ()
			-- self:PushLuaTable(result.callFunc,result.book)
		end
	}
]]