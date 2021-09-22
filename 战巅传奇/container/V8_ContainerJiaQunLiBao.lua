local V8_ContainerJiaQunLiBao = {}
local var = {}


function V8_ContainerJiaQunLiBao.initView(extend)
	var = {
		xmlPanel,
		code,
		mobile,
		sms,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/V8_ContainerJiaQunLiBao.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V8_ContainerJiaQunLiBao.handlePanelData)

		
		--var.xmlPanel:getWidgetByName("ditu1"):addClickEventListener(function ( sender )
		--	GameSocket:PushLuaTable("npc.v4_shouchongditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=1}))
		--	
		--end)
		
		--礼包码
		local label_input = var.xmlPanel:getWidgetByName("label_input_bg")
		var.mSendText = GameUtilSenior.newEditBox({
			image = "image/icon/null.png",
			size = label_input:getContentSize(),
			x = 0,
			y = 0,
			fontSize = 18,
			placeHolderSize = 18,
			color=GameBaseLogic.getColor(0xffffff),
			placeHolderColor=GameBaseLogic.getColor(0xffffff),
		})
		var.mSendText:setPlaceHolder("输入领取码")
		var.mSendText:setString("")
		var.mSendText:setAnchorPoint(cc.p(0,0))
		label_input:addChild(var.mSendText,1,100)

		local btnCdk = var.xmlPanel:getWidgetByName("get_gift_btn")
		btnCdk:addClickEventListener(function ()
			var.code = var.mSendText:getText()
			if string.len(var.code)>0 then
				if GameSocket:isBagFull() then
					return GameSocket:alertLocalMsg("背包已满，先清理再兑换！", "alert")
				end
				GameHttp:requestCDKey(var.code,var.xmlPanel,reponse)
				var.mSendText:setString("")
			else
				GameSocket:alertLocalMsg("请输入正确的领取码！", "alert")
			end
		end)
		
		
		--手机号
		local label_input_2 = var.xmlPanel:getWidgetByName("label_input_bg_2")
		var.mSendText_2 = GameUtilSenior.newEditBox({
			image = "image/icon/null.png",
			size = label_input_2:getContentSize(),
			x = 0,
			y = 0,
			fontSize = 18,
			placeHolderSize = 18,
			color=GameBaseLogic.getColor(0xffffff),
			placeHolderColor=GameBaseLogic.getColor(0xffffff),
			inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
			maxlen = 11
		})
		var.mSendText_2:setPlaceHolder("输入手机号")
		var.mSendText_2:setString("")
		var.mSendText_2:setAnchorPoint(cc.p(0,0))
		label_input_2:addChild(var.mSendText_2,1,100)

		local btnCdk_2 = var.xmlPanel:getWidgetByName("get_gift_btn_2")
		btnCdk_2:addClickEventListener(function ()
			var.mobile = var.mSendText_2:getText()
			if string.len(var.mobile)==11 then
				if GameSocket:isBagFull() then
					return GameSocket:alertLocalMsg("背包已满，先清理再兑换！", "alert")
				end
				GameHttp:requestSMS(var.mobile,var.xmlPanel,reponse)
				var.mSendText_2:setString("")
			else
				GameSocket:alertLocalMsg("请输入正确的手机号码！", "alert")
			end
		end)
		
		
		--验证码
		local label_input_3 = var.xmlPanel:getWidgetByName("label_input_bg_3")
		var.mSendText_3 = GameUtilSenior.newEditBox({
			image = "image/icon/null.png",
			size = label_input_3:getContentSize(),
			x = 0,
			y = 0,
			fontSize = 18,
			placeHolderSize = 18,
			color=GameBaseLogic.getColor(0xffffff),
			placeHolderColor=GameBaseLogic.getColor(0xffffff),
			inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
			maxlen = 4
		})
		var.mSendText_3:setPlaceHolder("输入验证码")
		var.mSendText_3:setString("")
		var.mSendText_3:setAnchorPoint(cc.p(0,0))
		label_input_3:addChild(var.mSendText_3,1,100)

		local btnCdk_3 = var.xmlPanel:getWidgetByName("get_gift_btn_3")
		btnCdk_3:addClickEventListener(function ()
			var.sms = var.mSendText_3:getText()
			if string.len(var.sms)==4 then
				if GameSocket:isBagFull() then
					return GameSocket:alertLocalMsg("背包已满，先清理再兑换！", "alert")
				end
				GameHttp:requestSmsCDKey(var.code,var.mobile,var.sms,var.xmlPanel,reponse)
				var.mSendText_3:setString("")
			else
				GameSocket:alertLocalMsg("请输入正确的验证码！", "alert")
			end
		end)
		
		
		V8_ContainerJiaQunLiBao.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function reponse(str)
	if "mobile"==str then
		local bg_pic = var.xmlPanel:getWidgetByName("bg_pic")
		bg_pic:loadTexture("V8_ContainerJiaQunLiBao_bg_2.png", ccui.TextureResType.plistType)
		var.xmlPanel:getWidgetByName("bg_1"):setVisible(false)
		var.xmlPanel:getWidgetByName("bg_2"):setVisible(true)
		var.xmlPanel:getWidgetByName("bg_3"):setVisible(false)
	elseif "sms"==str then
		local bg_pic = var.xmlPanel:getWidgetByName("bg_pic")
		bg_pic:loadTexture("V8_ContainerJiaQunLiBao_bg_3.png", ccui.TextureResType.plistType)
		var.xmlPanel:getWidgetByName("bg_1"):setVisible(false)
		var.xmlPanel:getWidgetByName("bg_2"):setVisible(false)
		var.xmlPanel:getWidgetByName("bg_3"):setVisible(true)
	elseif "验证码错误"==str then
		GameSocket:alertLocalMsg(str, "alert")
	else
		GameSocket:alertLocalMsg(str, "alert")
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "V8_ContainerJiaQunLiBao"})
	end
end

function V8_ContainerJiaQunLiBao.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V8_ContainerJiaQunLiBao.handlePanelData(event)
	if event.type == "V8_ContainerJiaQunLiBao" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			for i=1,#data.itemList,1 do
				local awardItem=var.xmlPanel:getWidgetByName("equip_"..i)
				local param={parent=awardItem, typeId=data.itemList[i].typeid, num=data.itemList[i].num}
				GUIItem.getItem(param)
				local lowSprite = cc.Sprite:create()
				lowSprite:setPosition(30,30)
				awardItem:addChild(lowSprite)
				local animate = cc.AnimManager:getInstance():getPlistAnimate(4, 65078, 4, 3,false,false,0,function(animate,shouldDownload)
							lowSprite:runAction(cca.repeatForever(animate))
							if shouldDownload==true then
								lowSprite:release()
							end
						end,
						function(animate)
							lowSprite:retain()
						end)
				
			end
		end
	end
end


function V8_ContainerJiaQunLiBao.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.V8_JiaQunLiBao.handlePanelData",GameUtilSenior.encode({actionid = "jiaqun_gift"}))
end

function V8_ContainerJiaQunLiBao.onPanelClose()

end

return V8_ContainerJiaQunLiBao