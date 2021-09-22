local GComponentTaskEnd ={}

function GComponentTaskEnd:initView( extend )
	if self.xmlTips then
		-- GameUtilSenior.asyncload(self.xmlTips, "tipsbg", "ui/image/prompt_bg.png")
		for k,v in pairs(extend) do
			print(k,v)
		end
		local config = extend.param.config
		self.playerName = extend.pName or ""
		self.xmlTips:getWidgetByName("achievename"):setString(config.name)
		self.xmlTips:getWidgetByName("lbl_time"):setString(config.time)
		self.xmlTips:getWidgetByName("cangetjf"):setString(config.achieveValue)
		--self.xmlTips:getWidgetByName("icon"):loadTexture("ui/image/"..config.huizhang..".png",ccui.TextureResType.localType):setScale(0.55)
		
		local path = "ui/image/"..config.huizhang..".png"
		asyncload_callback(path, self.xmlTips:getWidgetByName("icon"), function(path, texture)
			self.xmlTips:getWidgetByName("icon"):loadTexture(path):setScale(0.55)
		end)
		
		--self.xmlTips:getWidgetByName("imgtaskfinish"):loadTexture("ui/image/"..config.jiangli..".png",ccui.TextureResType.localType):setScale(0.8)
		
		local path = "ui/image/"..config.jiangli..".png"
		asyncload_callback(path, self.xmlTips:getWidgetByName("imgtaskfinish"), function(path, texture)
			self.xmlTips:getWidgetByName("imgtaskfinish"):loadTexture(path):setScale(0.8)
		end)
		
		local btn_go = self.xmlTips:getWidgetByName("btn_go")
		btn_go:setScale(0.8)
		GameUtilSenior.addHaloToButton(btn_go, "btn_normal_light3")
		self.xmlTips:getWidgetByName("img_jf"):setScale(0.8)

		local btns = {"btn_go","btn_close"}
		local function clickBtns( sender )
			local name = sender:getName()
			if name == btns[1] then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "main_achieve"})
			elseif name == btns[2] then
			end
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end

		for k,v in pairs(btns) do
			self.xmlTips:getWidgetByName(v):addClickEventListener(clickBtns)
		end
		self.xmlTips:stopAllActions()
		self.xmlTips:runAction(cca.seq({
			cca.delay(7),
			cca.cb(function( ... )
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
			end)
		}))
	end
end

return GComponentTaskEnd