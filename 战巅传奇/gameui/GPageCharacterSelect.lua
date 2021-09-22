GPageCharacterSelect = class("GPageCharacterSelect", function(relogin)
    return display.newScene("GPageCharacterSelect")
end)

function GPageCharacterSelect:ctor(relogin)
	self._xmlScene			= nil
	self._curChar			= nil
	self._relogin			= relogin
	self.box_role_1 		= nil
	self.box_role_2 		= nil
	self.box_role_3 		= nil
	self.m_handler  		= nil
	self.btnReName			= nil
	self.editboxReName 		= nil
	self.isEditing 			= false
	self.jobTable 			= {"zs", "fs", "ds"}
	self.rolePos 			= {{x=58,y=32},{x=10,y=14},{x=-4,y=34},{x=-4,y=4},{x=24,y=0},{x=30,y=-6}}
	self.effectPos 			= {{x=-5,y=0},{x=0,y=-5},{x=6,y=10},{x=0,y=0},{x=0,y=0},{x=0,y=0}}
	self.roleCenter			= {x=568,y=260}
end

function GPageCharacterSelect:onPlatformLogout()
	GameBaseLogic.ExitToRelogin()
end

function GPageCharacterSelect:onEnter()

	if GameMusic.musicName~="music/49.mp3" then
		GameMusic.music("music/49.mp3")
	end

	self.m_handler = cc.EventProxy.new(GameSocket, self)
		:addEventListener(GameMessageCode.EVENT_SOCKET_ERROR, handler(self, self.onSocketError))
		:addEventListener(GameMessageCode.EVENT_KEYBOARD_PASSED,handler(self, self.onKeyboard))
		:addEventListener(GameMessageCode.EVENT_LOADCHAR_LIST,handler(self, self.handleCharLoaded))
		:addEventListener(GameMessageCode.EVENT_PLATFORM_LOGOUT,handler(self, self.onPlatformLogout))

	self._xmlScene = GUIAnalysis.load("ui/layout/GPageCharacterSelect.uif")
		:setContentSize(display.width, display.height)
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

	local widgetContent = ccui.Widget:create():setContentSize(cc.size(1136,640)):align(display.CENTER, display.cx, display.cy)
	widgetContent:addTo(self._xmlScene):setLocalZOrder(10)
	self._xmlScene:getWidgetByName("layer_confirm"):setLocalZOrder(20)

	--调整背景的大小
	local imgSelectRoleBottom = self._xmlScene:getWidgetByName("img_selectRole_bottom")
		:align(display.CENTER, display.cx, display.cy)
	-- asyncload_callback("ui/image/img_gate_closed.jpg", imgSelectRoleBottom, function (filepath, texture)
		-- if GameUtilSenior.isObjectExist(imgSelectRoleBottom) then
			imgSelectRoleBottom:loadTexture("ui/image/img_gate_closed.jpg")
			imgSelectRoleBottom:scale(cc.MAX_SCALE);
		-- end
	-- end)

	self._xmlScene:getWidgetByName("node_role"):setPositionY(display.height):setLocalZOrder(15)

	-- local role_select = ccui.ImageView:create()
	-- role_select:loadTexture("role_select",ccui.TextureResType.plistType)
	-- role_select:addTo(imgSelectRoleBottom):align(display.CENTER,display.cx+4, 125)

	-- local glow = cc.Sprite:create()
	-- glow:addTo(widgetContent):align(display.CENTER,display.cx, 202):setLocalZOrder(100)
	-- cc.AnimManager:getInstance():getPlistAnimateAsync(glow,4,53000,4,0)

	local img_title = self._xmlScene:getWidgetByName("node_title")

	if display.height > 640 then 
		imgSelectRoleBottom:scale(display.height/640)
		widgetContent:scale(display.height/640)
		img_title:scale(display.height/640):align(display.TOP_CENTER, display.cx, display.height-44*(display.height/640))
	else
		img_title:align(display.TOP_CENTER, display.cx, display.height-44)
	end

	local btn_back = self._xmlScene:getWidgetByName("btn_back")
	local btn_backSize = btn_back:getContentSize();
	btn_back:pos(display.left+btn_backSize.width/2+20, 45)
	btn_back:addClickEventListener(function ()
		return self:onKeyboard({key = "back"})
	end)

	local btn_entergame = self._xmlScene:getWidgetByName("btn_entergame")
	local btn_entergameSize = btn_entergame:getContentSize();
	btn_entergame:pos(display.right-btn_entergameSize.width/2-20, 45)
	btn_entergame:addClickEventListener(handler(self, self.pushEnterGame))
	
	for i = 1,3 do
		local box_role = self._xmlScene:getWidgetByName("box_role_"..i)
		self["box_role_"..i] = box_role
		box_role.tag = i
		box_role:addClickEventListener(function (sender)
			if not GameSocket._netChars[sender.tag] and not self.isWaiting then
				-- require_ex("gameui.GPageCharacterCreate")
				return self:enterScene("GPageCharacterCreate") 
			end
			self:selectOneRole(sender.tag)
		end)
		box_role:setZoomScale(0)

		local btn_delete = box_role:getWidgetByName("btn_delete")
		btn_delete.tag = i
		btn_delete:addClickEventListener(function (sender)
			self:pushDeleteRole(GameSocket._netChars[sender.tag].mName)
		end)

		box_role:getWidgetByName("lbl_name"):enableOutline(cc.c3b(0, 0, 0), 1)
		box_role:getWidgetByName("lbl_lv"):enableOutline(cc.c3b(0, 0, 0), 1)
		box_role:getWidgetByName("lbl_job"):enableOutline(cc.c3b(0, 0, 0), 1)
		box_role:getWidgetByName("lbl_plus"):enableOutline(cc.c3b(0, 0, 0), 1)
		-- box_role:getWidgetByName("img_plus"):setVisible(true)
	end

	-- self.roleCenter	= {x=display.cx+46,y=285+(CONFIG_SCREEN_HEIGHT-GameConst.WIN_HEIGHT)/4}

	self.roleImage = ccui.ImageView:create()
	self.roleImage:addTo(widgetContent):align(display.CENTER, self.roleCenter.x-90,self.roleCenter.y)

	-- self.animeSprite = cc.Sprite:create()
	-- self.animeSprite:addTo(widgetContent):align(display.CENTER, self.roleCenter.x,self.roleCenter.y)

	self.layer_confirm = self._xmlScene:getWidgetByName("layer_confirm"):pos(display.cx, display.cy)
	self.layer_confirm:setLocalZOrder(200)
	self.layer_confirm:setTouchEnabled(true)
	asyncload_callback("ui/image/prompt_bg.png", self.layer_confirm, function (filepath, texture)
		if GameUtilSenior.isObjectExist(self.layer_confirm) then
			self.layer_confirm:getWidgetByName("panel_confirm"):loadTexture(filepath)
		end
	end)
	self.layer_confirm:getWidgetByName("btn_confirm"):addClickEventListener(function ()
		if self._delName then
			GameSocket:DeleteCharacter(self._delName)
		end
		self._delName = nil
		self.layer_confirm:hide()
	end)
	self.layer_confirm:getWidgetByName("btn_cancel"):addClickEventListener(function ()
		self.layer_confirm:hide()
	end)
	local lbl_confirm = self.layer_confirm:getWidgetByName("lbl_confirm")
	lbl_confirm:setString("角色删除后将无法恢复\n\r确定删除吗？")
	lbl_confirm:enableOutline(GameBaseLogic.getColor(0x000000),1)

	if self._relogin then
		self.m_handler:addEventListener(GameMessageCode.EVENT_CONNECT_ON, handler(self, self.onConnect))
			:addEventListener(GameMessageCode.EVENT_AUTHENTICATE, handler(self, self.onAuth))
		GameSocket:connect(GameBaseLogic.serverIP, GameBaseLogic.serverPort)
		self.isWaiting = true
	else
		self:handleCharLoaded()
	end

	local startNum = 1
	local function startShowBg()
		
		btn_entergame:loadTextureNormal("new_common_ui_enter_game_now_"..startNum..".png",ccui.TextureResType.plistType)

		startNum= startNum+1
		if startNum ==11 then
			startNum =1
		end
	end
	self._xmlScene:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(10)))
	-- GameMusic.music("music/bajian.mp3")
end

function GPageCharacterSelect:onExit()
	cc.SpriteManager:getInstance():removeFramesByFile("ui/sprite/GPageCharacterSelect")
	cc.CacheManager:getInstance():releaseUnused(false)
end

function GPageCharacterSelect:onSocketError(event)
	GameCCBridge.showMsg("服务器连接已断开")
	GameBaseLogic.ExitToRelogin()
end

function GPageCharacterSelect:handleCharLoaded(event)
	if #GameSocket._netChars == 0 then return self:enterScene("GPageCharacterCreate") end
	self._curChar = GameSocket._netChars[1]
	self._curCharTag = 1
	self:updateListCharactor()

	-- 上次登录的玩家名
	-- print("chrName", chrName)
	-- if chrName then
	-- 	if self.playerTag[chrName] and type(self.playerTag[chrName]) == "number" then
	-- 		local curItemIndex = self.RotateMenu:getCurrentItemIndex()
	-- 		local diff = curItemIndex - (4 - self.playerTag[chrName])

	-- 		self.RotateMenu:changeCurItem(diff)
	-- 	end	
	-- end	
end

function GPageCharacterSelect:pushDeleteRole(name)
	-- if self._curChar then
		-- local function onButtonClicked(event)
		-- 	if event.buttonIndex == 1 then
		-- 		-- local name = self._curChar.mName
		-- 		GameSocket:DeleteCharacter(name)
		-- 	else
		-- 		print("cancel delete")
		-- 	end
		-- end
		-- GameUtilSenior.showAlert("", "角色删除后将无法恢复，确定删除吗？", {"确定删除", "点错了"}, onButtonClicked)
		self.layer_confirm:show()
		self._delName = name
	-- end
end

function GPageCharacterSelect:onConnect(event)
	GameSocket:Authenticate(101,GameBaseLogic.gameTicket,0,0)
end

function GPageCharacterSelect:onDisConnect(event)
end

function GPageCharacterSelect:onAuth(event)
	print("=================GPageCharacterSelect:onAuth=============")
	print(event.result)
	print(GameBaseLogic.gameKey)
	print("=================GPageCharacterSelect:onAuth=============")
	if event.result == 100 then
		GameSocket:ListCharacter()
	else
		GameBaseLogic.ExitToRelogin()
	end
end

function GPageCharacterSelect:selectOneRole(tag)
	if not GameSocket._netChars[tag] then
		self:handleReNameVisible(false)
		self._curChar = nil
		self._curCharTag = nil
		return
	end
	self._curChar = GameSocket._netChars[tag]
	self._curCharTag = tag
	self:updateListCharactor()
	if self._curChar and string.sub(self._curChar.mName, 1, 2) == "CM" then
		-- self:handleReNameVisible(true)
	else 
		self:handleReNameVisible(false)
	end
end

function GPageCharacterSelect:updateListCharactor()
	self.playerTag = {}
	local charList = GameSocket._netChars
	for i = 1, 3 do
		local box_role = self["box_role_"..i]
		if box_role then
			local hasRole
			if charList[i] then
				hasRole = true
				local idx = charList[i].mJob-100+1
				if self.jobTable[idx] then
					box_role:loadTextureNormal("img_"..self.jobTable[idx].."_sel", ccui.TextureResType.plistType)
					box_role:setOpacity(255 * 0.4)
					-- box_role:getWidgetByName("img_job"):hide()
				end
				if self._curCharTag == i then
					local idxtag = (self._curChar.mJob-100)*2+self._curChar.mGender-200
					--self.roleImage:loadTexture("ui/image/create_role_"..((self._curChar.mJob-100)*2+self._curChar.mGender-200)..".png")
					
					
					local startNum = 1
					local function startShowBg()
						
						asyncload_callback("ui/image/roles/war_man_"..startNum..".png", self.roleImage, function (filepath, texture)
							if GameUtilSenior.isObjectExist(self.roleImage) then
								self.roleImage:loadTexture(filepath)
							end
						end)
						startNum= startNum+1
						if startNum ==20 then
							startNum =1
						end
					end
					self.roleImage:stopAllActions()
					self.roleImage:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(40)))
		
					box_role:getWidgetByName("imgMask"):show()
					-- self.animeSprite:stopAllActions()
					-- local animate = cc.AnimManager:getInstance():getPlistAnimate(4, 80000 + (self._curChar.mJob-100)*2+self._curChar.mGender-200, 4, 7)
					-- if animate then
					-- 	self.animeSprite:runAction(cca.repeatForever(animate))
					-- end
					-- self.roleImage:align(display.CENTER, self.roleCenter.x+self.rolePos[idxtag+1].x,self.roleCenter.y+self.rolePos[idxtag+1].y)
					-- self.animeSprite:align(display.CENTER, self.roleCenter.x+self.rolePos[idxtag+1].x+self.effectPos[idxtag+1].x,self.roleCenter.y+self.rolePos[idxtag+1].y+self.effectPos[idxtag+1].y)
					-- cc.AnimManager:getInstance():getPlistAnimateAsync(self.animeSprite, 4, 80000 + (self._curChar.mJob - 100) * 2 + self._curChar.mGender - 200, 4, 0, 7)
				else
					box_role:getWidgetByName("imgMask"):hide()
					-- box_role:loadTextureNormal("img_null", ccui.TextureResType.plistType)
					-- local idx = charList[i].mJob-100+1
					-- if self.jobTable[idx] then
					-- 	box_role:getWidgetByName("img_job"):show():loadTexture("img_"..self.jobTable[idx], ccui.TextureResType.plistType)
					-- else
					-- 	box_role:getWidgetByName("img_job"):hide()
					-- end
				end

				self:updatePlayerNormalInfo(box_role, charList[i])
				box_role.infos = GameUtilSenior.encode(charList[i])
				self.playerTag[charList[i].mName] = i
			else
				hasRole = false
				box_role:loadTextureNormal("img_null", ccui.TextureResType.plistType)
				box_role:getWidgetByName("imgMask"):hide()
				-- box_role:getWidgetByName("img_job"):hide()
			end
			box_role:getWidgetByName("lbl_name"):setVisible(hasRole)
			box_role:getWidgetByName("lbl_lv"):setVisible(hasRole)
			box_role:getWidgetByName("lbl_job"):setVisible(hasRole)
			box_role:getWidgetByName("btn_delete"):setVisible(hasRole)
			-- box_role:getWidgetByName("img_plus"):setVisible(not hasRole)
			box_role:getWidgetByName("lbl_plus"):setVisible(not hasRole)
		end
	end

	self.isWaiting = false
end

function GPageCharacterSelect:onKeyboard(event)
	if self.isEditing then return end
	if event.key=="back" then
		GameUtilSenior.showAlert("提示","要重新选区吗？",{"确定","取消"},function (event)
			if event.buttonIndex == 1 then
				-- GameBaseLogic.ExitToRelogin()
				GameSocket:disconnect()
				GameSocket:init()

				self:enterScene("GPageServerList")
			end
		end,self)
	end
end

function GPageCharacterSelect:pushEnterGame()
	if self._curChar then
		if GameSocket._connected then
			GameBaseLogic.chrName = self._curChar.mName
			GameBaseLogic.seedName = self._curChar.mSeedName
			GameBaseLogic.job = self._curChar.mJob
			GameBaseLogic.gender = self._curChar.mGender
			GameBaseLogic.level = self._curChar.mLevel

			if not GameBaseLogic.chrName or not GameBaseLogic.seedName or tostring(GameBaseLogic.chrName)=="" or tostring(GameBaseLogic.seedName)=="" then
				GameCCBridge.showMsg("角色信息错误")
				return
			end
			self:enterScene("GPageResourceLoad")
		else
			GameBaseLogic.ExitToRelogin()
		end
	elseif not self.isWaiting then
		self:enterScene("GPageCharacterCreate")
	end
end

function GPageCharacterSelect:updatePlayerNormalInfo(parent, infos)
	parent:getWidgetByName("lbl_job"):setString(GameConst.job_name[infos.mJob])
	parent:getWidgetByName("lbl_name"):setString(infos.mName)
	parent:getWidgetByName("lbl_lv"):setString(infos.mLevel.."级")
end

function GPageCharacterSelect:handleReNameVisible(visible)
	if visible then
		if not self.btnReName then
			self.btnReName = ccui.Button:create("btn_rename", "btn_rename_sel", "", ccui.TextureResType.plistType)
				:align(display.RIGHT_CENTER, display.width * 0.95, 50)
				:addTo(self._xmlScene)
			self.btnReName:addClickEventListener(function ()
				local chrname = self.editboxReName:getText()
				if GameUtilSenior.checkInvalidChar(chrname) then
					GameUtilSenior.showAlert("","名称中包含非法字符","确定")
					return
				elseif chrname == self._curChar.mName then
					GameUtilSenior.showAlert("","名称未改变","确定")
					return
				elseif chrname == "请输入新的名字" then
					GameUtilSenior.showAlert("","名称不可用","确定")
					return
				end
				if self._curChar and string.sub(self._curChar.mName, 1, 2) == "CM" then
					GameHttp:requestRename(self._curChar.mName , chrname, self)
				end
			end)
			local function editBoxListener(event,editBox)
				if event == "began" then
					self.isEditing = true
				elseif event == "return" then
					self.isEditing = false
				end
			end

			self.editboxReName = GameUtilSenior.newEditBox({
				image = "image/icon/img_task_word_bottom.png",
				size = cc.size(240,45),
				color = cc.c4b(200, 200, 200,255),
				listener = editBoxListener,
				placeHolder = "请输入新的名字",
				fontSize = 22,
			}):align(display.RIGHT_CENTER, display.width * 0.95 - self.btnReName:getContentSize().width - 10, 50)
			:addTo(self._xmlScene):setTouchEnabled(true)

		end
		self.btnReName:show()
		self.editboxReName:show()
	elseif self.btnReName then
		self.btnReName:hide()
		self.editboxReName:hide()
	end
end

function GPageCharacterSelect:enterScene(sceneName)
	if self.isEditing then return end
	print("-------------GPageCharacterSelect:enterScene = "..sceneName)
	asyncload_frames(string.format("ui/sprite/%s", sceneName),".png",function ()
		display.replaceScene(_G[sceneName].new())
	end,self)
end

return GPageCharacterSelect