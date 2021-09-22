GPageCharacterCreate = class("GPageCharacterCreate", function()
	return display.newScene("GPageCharacterCreate")
end)

function GPageCharacterCreate:ctor()
	self._curJob			= nil
	self._curGender			= 1
	self._createName		= nil
	self._xmlScene			= nil
	self._isSameName		= nil
	self._lbl_editBoxText	= nil
	self.isEditing 			= false
	self.jobTable 			= {"zs", "fs", "ds"}
	self.RotateMenu         = nil
	self.isWaiting			= false
	self.rolePos 			= {{x=58,y=32},{x=10,y=14},{x=-4,y=34},{x=-4,y=4},{x=24,y=0},{x=30,y=-6}}
	self.effectPos 			= {{x=-5,y=0},{x=0,y=-5},{x=6,y=10},{x=0,y=0},{x=0,y=0},{x=0,y=0}}
	self.roleCenter			= {x=528,y=230}
end

function GPageCharacterCreate:onKeyboard(event)
	if event.key=="back" and not self.isEditing then
		if #GameSocket._netChars < 1 then 
			GameUtilSenior.showAlert("提示","要重新登录吗？",{"确定","取消"},function (event)
				if event.buttonIndex == 1 then
					GameBaseLogic.ExitToRelogin()
				end
			end,self)
		else
			asyncload_frames("ui/sprite/GPageCharacterSelect",".png",function ()
				display.replaceScene(GPageCharacterSelect.new())
			end,self)
		end
	end
end

function GPageCharacterCreate:onPlatformLogout()
	GameBaseLogic.ExitToRelogin()
end

function GPageCharacterCreate:onEnter()

	if GameMusic.musicName~="music/49.mp3" then
		GameMusic.music("music/49.mp3")
	end

	self._xmlScene = GUIAnalysis.load("ui/layout/GPageCharacterCreate.uif")
		:setContentSize(display.width, display.height)
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

	self._xmlScene:getWidgetByName("box_roleBase"):align(display.BOTTOM_CENTER, display.cx, 0)
	self._xmlScene:getWidgetByName("node_title"):setPositionY(display.height)

	self._lbl_editBoxText = self._xmlScene:getWidgetByName("lbl_editBoxText")
	self.lbl_alert = self._xmlScene:getWidgetByName("lbl_alert")

	local imgCreateRoleBottom = self._xmlScene:getWidgetByName("img_createRole_bottom")
		:align(display.CENTER, display.cx, display.cy)
	-- if display.height > 640 then imgCreateRoleBottom:scale(display.height/640) end
	-- asyncload_callback("ui/image/img_gate_closed.jpg", imgCreateRoleBottom, function (filepath, texture)
		-- if GameUtilSenior.isObjectExist(imgCreateRoleBottom) then
			imgCreateRoleBottom:loadTexture("ui/image/img_gate_closed.jpg")
			imgCreateRoleBottom:scale(cc.MAX_SCALE)
		-- end
	-- end)

	local widgetContent = ccui.Widget:create():setContentSize(cc.size(1136,640)):align(display.CENTER, display.cx, display.cy)
	widgetContent:addTo(self):setLocalZOrder(10)

	-- local glow = cc.Sprite:create()
	-- glow:addTo(self._xmlScene):align(display.CENTER,display.cx, 226):setLocalZOrder(10)
	-- cc.AnimManager:getInstance():getPlistAnimateAsync(glow,4,53000,4,0)

	local img_title = self._xmlScene:getWidgetByName("node_title")

	if display.height > 640 then 
		imgCreateRoleBottom:scale(display.height/640)
		widgetContent:scale(display.height/640)
		-- glow:scale(display.height/640):align(display.CENTER,display.cx, 226*(display.height/640))
		-- img_title:scale(display.height/640):align(display.TOP_CENTER, display.cx, display.height-44*(display.height/640))
	else
		-- img_title:align(display.TOP_CENTER, display.cx, display.height-44)
	end

	cc.EventProxy.new(GameSocket,self)
		:addEventListener(GameMessageCode.EVENT_CREATECHARACTOR, handler(self, self.handleRoleCreated))
		:addEventListener(GameMessageCode.EVENT_SOCKET_ERROR, handler(self, self.onSocketError))
		-- :addEventListener(GameMessageCode.EVENT_KEYBOARD_PASSED,handler(self, self.onKeyboard))
		:addEventListener(GameMessageCode.EVENT_PLATFORM_LOGOUT,handler(self, self.onPlatformLogout))

	-- self.roleCenter	= {x=display.cx+46,y=285+(CONFIG_SCREEN_HEIGHT-GameConst.WIN_HEIGHT)/4}
	-- self.roleCenter = {x=568,y=320}

	self.roleImage = ccui.ImageView:create()
	self.roleImage:addTo(widgetContent):align(display.CENTER, self.roleCenter.x-47,self.roleCenter.y+30)

	self.animeSprite = cc.Sprite:create()
	self.animeSprite:setName("animeSprite")
	self.animeSprite:addTo(widgetContent):align(display.CENTER, self.roleCenter.x,self.roleCenter.y)

	for i=1,1 do
		local btn = self._xmlScene:getWidgetByName("btn_job_"..i)
		btn.tag = i
		btn:addClickEventListener(function (sender)
			self:selectJob(sender.tag)
		end)
	end

	self:refreshScene()

	-- print(CONFIG_SCREEN_HEIGHT,display.height)
	-- GameMusic.music("music/juese.mp3")
end

function GPageCharacterCreate:selectJob(job)
	local jobsIntroduce = {
		[1] = {shortName = "zs", fullName = "战士", info = "穿越在蛮荒战场之中的勇士，用自己的实力横扫寰宇，为了心中的梦想赴汤蹈火在所不惜！"},
		[2] = {shortName = "fs", fullName = "法师", info = "信仰魔法之力的游荡者，利用元素之力来摆平遇到的一切困难。"},
		[3] = {shortName = "ds", fullName = "道士", info = "于大自然中诞生，于大自然中醒悟的智者，利用异世的力量来普济众生。"}
	}
	if self._curJob == job then
		return
	end

	self._xmlScene:getWidgetByName("img_job_1"):hide()

	self._curJob = job
	self._xmlScene:getWidgetByName("img_job_"..self._curJob):show()
	self._xmlScene:getWidgetByName("img_jobFeature"):show():loadTexture(string.format("img_info_%s", jobsIntroduce[self._curJob].shortName), ccui.TextureResType.plistType)
	

	if self._createName and not self._lbl_editBoxText._customInput then
		self._createName:setString(self:randomName())
	end

	local idxtag = (self._curJob-1)*2+self._curGender-1
	--self.roleImage:loadTexture("ui/image/create_role_"..idxtag..".png")
	
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
	
	--[[
	self.animeSprite:stopAllActions()
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4, 80000 + idxtag, 4, 7,false,false,0,function(animate,shouldDownload)
							if animate then
								self.animeSprite:runAction(cca.repeatForever(animate))
							end
							if shouldDownload==true then
								self.animeSprite:release()
							end
						end,
						function(animate)
							self.animeSprite:retain()
						end)
	
	self.roleImage:align(display.CENTER, self.roleCenter.x+self.rolePos[idxtag+1].x,self.roleCenter.y+self.rolePos[idxtag+1].y)
	self.animeSprite:align(display.CENTER, self.roleCenter.x+self.rolePos[idxtag+1].x+self.effectPos[idxtag+1].x,self.roleCenter.y+self.rolePos[idxtag+1].y+self.effectPos[idxtag+1].y)
	]]
	-- cc.AnimManager:getInstance():getPlistAnimateAsync(self.animeSprite, 4, 80000 + (self._curJob - 1) * 2 + self._curGender - 1, 4, 0, 7)
end

function GPageCharacterCreate:refreshScene()
	local tab_gender = self._xmlScene:getWidgetByName("tab_gender")
	local function selectGender(sender, isCalledManually)
		if self._curGender then
			tab_gender:getWidgetByName("btn_gender_"..self._curGender):setTouchEnabled(true):setLocalZOrder(4)
		end

		self._curGender = tonumber(string.sub(sender:getName(), -1))
		if not isCalledManually then
			local idxtag = (self._curJob-1)*2+self._curGender-1
			--self.roleImage:loadTexture("ui/image/create_role_"..idxtag..".png")
			
			local startNum = 1
			local function startShowBg()
				
				asyncload_callback("ui/image/roles/war_man_"..startNum..".png", self.roleImage, function (filepath, texture)
					if GameUtilSenior.isObjectExist(self.roleImage) then
						self.roleImage:loadTexture(filepath)
					end
				end)
				startNum= startNum+1
				if startNum ==41 then
					startNum =1
				end
			end
			self.roleImage:stopAllActions()
			self.roleImage:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(40)))
			
			--[[
			self.animeSprite:stopAllActions()
			local animate = cc.AnimManager:getInstance():getPlistAnimate(4, 80000 + idxtag, 4, 7,false,false,0,function(animate,shouldDownload)
							if animate then
								self.animeSprite:runAction(cca.repeatForever(animate))
							end
							if shouldDownload==true then
								self.animeSprite:release()
							end
						end,
						function(animate)
							self.animeSprite:retain()
						end)
			self.roleImage:align(display.CENTER, self.roleCenter.x+self.rolePos[idxtag+1].x,self.roleCenter.y+self.rolePos[idxtag+1].y)
			self.animeSprite:align(display.CENTER, self.roleCenter.x+self.rolePos[idxtag+1].x+self.effectPos[idxtag+1].x,self.roleCenter.y+self.rolePos[idxtag+1].y+self.effectPos[idxtag+1].y)
			-- cc.AnimManager:getInstance():getPlistAnimateAsync(self.animeSprite, 4, 80000 + (self._curJob - 1) * 2 + self._curGender - 1, 4, 0, 7)
			]]
		end

		sender:setTouchEnabled(false)
		if self._createName and not self._lbl_editBoxText._customInput then
			self._createName:setString(self:randomName())
		end
	end

	local randomJobIndex =  os.time() % 3 + 1
	local randomGenderIndex =  os.time() % 2 + 1
	
	randomGenderIndex = 1

	tab_gender:addTabEventListener(selectGender)
	local randomGenderBtn = tab_gender:getWidgetByName("btn_gender_"..randomGenderIndex)
	randomGenderBtn:setBrightStyle(1)
	selectGender(randomGenderBtn, true)
	randomJobIndex = 1
	self:selectJob(randomJobIndex)

	local function editBoxListener(event,editBox)
		-- print("event", event)
		if event == "began" then
			self.isEditing = true
			-- self._xmlScene:performWithDelay(function ()
			-- 	self.isEditing = false
			-- end, 0.5)
			if self._isSameName then
				editBox:setString("")
				self._isSameName = false
				self:handleSameName()
			end
			self._lbl_editBoxText:hide()
			self._lbl_editBoxText._customInput = true
		elseif event == "return" then
			self.isEditing = false
			if GameUtilSenior.isObjectExist(self._lbl_editBoxText) then
				--self._lbl_editBoxText:show()
			end
		end
		local name = editBox:getText()
		-- if event == "ended" or event == "return" then
			if not self:checkName(name) then
				return
			end
		-- end
		self.lbl_alert:hide()
		self._lbl_editBoxText:setString(name)
	end

	local imgEditBoxBg = self._xmlScene:getWidgetByName("img_editBoxBg")
	local pSize = imgEditBoxBg:getContentSize()

	self._createName = GameUtilSenior.newEditBox({
		image		= "image/icon/null.png",
		size		= cc.size(240, 45),
		listener	= editBoxListener,
		placeHolder	= "请输入角色姓名",
		fontSize	= 22,
		--color = GameBaseLogic.getColor(0xFFFFFF),
	}):align(display.LEFT_CENTER, 27, pSize.height * 0.5):addTo(imgEditBoxBg)
	self._createName:setString(self:randomName())

	-- self._createName:setMaxLength(14)
	self._xmlScene:getWidgetByName("btn_randomName"):addClickEventListener(function ()
		self._lbl_editBoxText._customInput = false
		self._createName:setString(self:randomName())
	end)

	local btn_back = self._xmlScene:getWidgetByName("btn_back")
	local btn_backSize = btn_back:getContentSize();
	btn_back:pos(display.left+btn_backSize.width/2+20, 45)
	btn_back:addClickEventListener(function ()
		self:onKeyboard({key = "back"})
	end)

	local btn_entergame = self._xmlScene:getWidgetByName("btn_entergame")
	local btn_entergameSize = btn_entergame:getContentSize();
	btn_entergame:pos(display.right-btn_entergameSize.width/2-20, 45)
	btn_entergame:addClickEventListener(function ()
		if not self.isEditing then
			local name = self._lbl_editBoxText:getString()
			if not self:checkName(name) then
				return
			end
			GameBaseLogic.chrName = name
			GameBaseLogic.level = 1
			GameSocket.mCreateJob = self._curJob + 99
			GameSocket.mCreateGender = self._curGender + 199
			local svrid = 0
			if GameBaseLogic.lastSvr then
				svrid = tonumber(GameBaseLogic.lastSvr.serial) or 0
			end
			GameSocket:CreateCharacter(GameBaseLogic.chrName, GameSocket.mCreateJob, GameSocket.mCreateGender, svrid, "")
			self._createName:setTouchEnabled(false)
		end
	end)
	

	local startNum = 1
	local function startShowBg()
		
		btn_entergame:loadTextureNormal("new_common_ui_enter_game_now_"..startNum..".png",ccui.TextureResType.plistType)

		startNum= startNum+1
		if startNum ==11 then
			startNum =1
		end
	end
	self._xmlScene:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(10)))
end

function GPageCharacterCreate:onExit()
	cc.SpriteManager:getInstance():removeFramesByFile("ui/sprite/GPageCharacterCreate")
	cc.CacheManager:getInstance():releaseUnused(false)
end

function GPageCharacterCreate:onSocketError(event)
	GameCCBridge.showMsg("服务器连接已断开")
	GameBaseLogic.ExitToRelogin()
end

function GPageCharacterCreate:handleRoleCreated(event)
	if event.result == 100 then
		if GameSocket._connected then
			asyncload_frames("ui/sprite/GPageResourceLoad",".png",function ()
				GameBaseLogic.seedName = event.seedname
				GameBaseLogic.preScene = "GPageCharacterCreate"
				display.replaceScene(GPageResourceLoad.new())
			end,self)
		else
			GameBaseLogic.ExitToRelogin()
		end
	elseif event.result == 103 then--重名
		self._isSameName = true
		self:handleSameName()
		self._createName:setTouchEnabled(true)
	else
		-- GameUtilSenior.showAlert("", event.msg, "知道了")
		self.lbl_alert:show():setString(event.msg)
		self._createName:setTouchEnabled(true)
	end
end

function GPageCharacterCreate:handleSameName()
	if self._isSameName then
		self.lbl_alert:show():setString("名称已存在")
	else
		self.lbl_alert:hide()
	end
end

function GPageCharacterCreate:getNameLen(name)
	local chineseNum, asciiNum = GameUtilSenior.getStrLen(name)
	return chineseNum * 2 + asciiNum
end

function GPageCharacterCreate:checkName(name)
	local nameLen = self:getNameLen(name)
	if nameLen > 14 then
		self.lbl_alert:show():setString("名称过长")
		return
	end

	if GameUtilSenior.checkInvalidChar(name) then
		self.lbl_alert:show():setString("名称不得包含非法字符")
		return
	end

	return true
end

function GPageCharacterCreate:runAnimeAction(target, anime, actionTag)
	local pos = cc.p(target:getPosition())
	local foreverAction = cc.RepeatForever:create(
			cc.Spawn:create(
				anime,
				cc.Sequence:create(
					cc.EaseSineInOut:create(cc.MoveTo:create(1,cc.p(pos.x,pos.y+10))),
					cc.EaseSineInOut:create(cc.MoveTo:create(1,cc.p(pos.x,pos.y-10)))
				)
			)
		)
	if actionTag then
		foreverAction:setTag(actionTag)
	end
	target:runAction(foreverAction)
end

function GPageCharacterCreate:randomName()
	self._isSameName = false
	self:handleSameName()
	local random = math.random(1,#GameConst.familyName)
	--local familyName = GameConst.familyName[random]
	--local randName = familyName[math.random(1,#familyName)]
	--if random == 1 then
	randName = GameConst.familyName[random]..GameConst.firstName[self._curGender][math.random(1,#GameConst.firstName[self._curGender])]
	--end

	self._lbl_editBoxText:setString(randName)

	return randName
end

function GPageCharacterCreate:onShakeScene()
	if not self.isRunningAction then
		self:stopAllActions()
		self.isRunningAction = true
		local times = 1
		self:runAction(
			cca.seq({
				cca.rep(
					cca.seq({
						cca.moveBy(0.05, self:getPositionX()-20, self:getPositionY()),
						cca.moveBy(0.05, self:getPositionX()+20, self:getPositionY())
						}),
					times
				),cca.cb(function()
					self.isRunningAction = false
				end)
			})
		)
	end
end

return GPageCharacterCreate
