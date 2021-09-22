local GComponentFoe = {}

function GComponentFoe:initView(extend)
	if self.xmlTips then
		-- GameUtilSenior.asyncload(self.xmlTips, "tipsbg", "ui/image/prompt_bg.png")

		self.lblmap = self.xmlTips:getWidgetByName("lblmap"):setString("")
		self.lblposition = self.xmlTips:getWidgetByName("lblposition"):setString("")
		self.enemyName = extend.enemyName
		local btns = {"btn_go","btn_track"}
		local function clickBtns( sender )
			local name = sender:getName()
			if name == btns[1] then
				if self.map then
					GameSocket:PushLuaTable("gui.ContainerFriend.onPanelData",GameUtilSenior.encode({actionid = "gotoEnemy",enemyName = self.enemyName}))
					GComponentFoe.close(self,extend.str)
				end
			elseif name == btns[2] then
				--if GameSocket.mCharacter.mVCoin<200 then
					--GameSocket:PushLuaTable("server.showChongzhi","check")
					--GComponentFoe.close(self,extend.str)
					-- local param = {
					-- 	name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", visible = true, 
					-- 	lblConfirm = "很抱歉,您元宝不足", btnConfirm = "充值",btnCancel = "取消",
					-- 	confirmCallBack = function ()
					-- 		GameSocket:PushLuaTable("gui.PanelBag.handlePanelData",GameUtilSenior.encode({actionid = "opencongzhi"}))
					-- 	end
					-- }
					-- GameSocket:dispatchEvent(param)
				--else
					GameSocket:PushLuaTable("gui.ContainerFriend.onPanelData",GameUtilSenior.encode({actionid = "enemyTrack",enemyName = self.enemyName}))
				--end
			end
		end

		for k,v in pairs(btns) do
			self.xmlTips:getWidgetByName(v):addClickEventListener(clickBtns)
		end
		local function handlePanelData(event)
			if event.type == "enemyTrack" then 
				local data = GameUtilSenior.decode(event.data)
				self.map = data.map
				self.lblmap:setString(data.map)
				self.lblposition:setString(data.x..","..data.y)
				self.xmlTips:getWidgetByName("btn_go"):show()				
			end
		end
		cc.EventProxy.new(GameSocket,self.xmlTips)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, handlePanelData)
	end
end

function GComponentFoe:close()
	self.map = nil
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = self.str})
end

return GComponentFoe
