GPageServerList = class("GPageServerList", function()
    return display.newScene("GPageServerList")
end)

local needloadImg = {
	-- ["imgSceneBg"] = {res = "img_battle.jpg", needscale = true, posX = display.cx, posY = display.cy, anchor = display.CENTER},
	--["serverListBg"] = {res = "img_SelGate_serverBg.png", posX = display.cx, posY = display.cy, anchor = display.CENTER}
}

local buttonTable = {"btnLogout", "btnEnterGame", "btnSelectServer", "btnLastServer"}

function GPageServerList:ctor()
	self.m_serverUI = nil
	self.panelLogin = nil
	self.panelServerList = nil
	self.curPanel = nil
	self.loginManager = nil
	self.zoneList = {}
	self.zoneListItem = {}
	self.serverList = {}
	self.curServerList = {}
	self.curServerListItem = {}
	self.serverId = 1
	self.currentZoneIndex=1

	self.svrpath = cc.FileUtils:getInstance():getWritablePath().."serverList.json"
	self.directEnter = false
end

function GPageServerList:onEnter()
	if GameMusic.musicName~="music/43.mp3" then
		GameMusic.music("music/43.mp3")
	end

	self.m_serverUI = GUIAnalysis.load("ui/layout/GPageServerList.uif")
	if self.m_serverUI then
		self.m_serverUI:size(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy):addTo(self,2)
		local sceneScale = display.height / 640
		for k,v in pairs(needloadImg) do
			local imgNeedLoad = self.m_serverUI:getWidgetByName(k):loadTexture("ui/image/"..v.res):setTouchEnabled(true):show()
			if v.needscale then imgNeedLoad:setScale(sceneScale) end
			if v.posX then imgNeedLoad:align(v.anchor, v.posX, v.posY) end
		end
		local img_bottom_bg = self.m_serverUI:getWidgetByName("img_bottom_bg")
		local img_top_bg = self.m_serverUI:getWidgetByName("img_top_bg")

		--img_left:setPositionX(display.cx)
		--img_right:setPositionX(display.cx)
		img_top_bg:align(display.CENTER, display.cx, display.cy)
		asyncload_callback("ui/image/server_select.png", img_top_bg, function (filepath, texture)
		end)
		asyncload_callback("ui/image/server_select_1.png", img_top_bg, function (filepath, texture)
			if GameUtilSenior.isObjectExist(img_top_bg) then
				img_top_bg:loadTexture(filepath):scale(cc.MAX_SCALE)
			end
		end)
		--img_right:setFlippedX(true)
		--self:openDoor(self.m_serverUI)
		-- asyncload_callback("ui/image/tip_chenmi.png", self, function (filepath, texture)
		-- 	if GameUtilSenior.isObjectExist(self) then
		-- 		self.tip_chenmi = ccui.ImageView:create(filepath):align(display.BOTTOM_CENTER, display.cx, 0):addTo(self,3):hide()
		-- 	end
		-- end)

		if device.platform ~= "windows" then
			local assetsCode = GameCCBridge.getConfigString("assets_code")
			local version = GameCCBridge.getConfigString("version")
			if not assetsCode or assetsCode=="" or assetsCode=="0" then
				assetsCode = version
			end

			--local lblAssetsCode = GameUtilSenior.newUILabel({
			--	text = GameLanguage.Com_Resource..":"..assetsCode,
			--	font = FONT_NAME,
			--	fontSize = 24,
			--	color = cc.c3b(255, 165, 0),
			--}):addTo(self,11):align(display.RIGHT_TOP, display.right - 10, display.top - 10):enableOutline(cc.c4b(24,19,11,200),1)

			--local lblAssetsCode = GameUtilSenior.newUILabel({
			--	text = GameLanguage.Com_Game..":"..version,
			--	font = FONT_NAME,
			--	fontSize = 24,
			--	color = cc.c3b(255, 165, 0),
			--}):addTo(self,11):align(display.LEFT_TOP, display.left + 10, display.top - 10):enableOutline(cc.c4b(24,19,11,200),1)
		end

		self.panelLogin = self.m_serverUI:getWidgetByName("panelLogin"):align(display.CENTER, display.cx, display.cy):hide()

		self.panelServerList = self.m_serverUI:getWidgetByName("panelServerList"):align(display.CENTER, display.cx, display.cy):hide()
			--:setContentSize(cc.size(display.width, display.height)):setTouchEnabled(true)
		self.curPanel = self.panelLogin

		local imgSelectBg = self.panelLogin:getChildByName("Image_1")
		--imgSelectBg:pos(display.cx, display.cy)

		local btnSelectServer = self.m_serverUI:getWidgetByName("btnSelectServer")
		--btnSelectServer:pos(display.cx + btnSelectServer:getContentSize().width/2, display.cy)
		btnSelectServer:addClickEventListener(function ()
			self:onSelectServer()
		end)
		
		self.m_serverUI:getWidgetByName("btnSelectServerContainer"):pos(display.width/2, display.height/2)


		self.panelConnect = self.m_serverUI:getWidgetByName("Panel_Connect")
		self.panelConnect:setContentSize(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy)
		self.panelConnect:setTouchEnabled(true)
		self.panelConnect:setVisible(false)

		--固定屏幕位置
		-- self.panelLogin:getWidgetByName("btnLogout"):pos(104,45)
		-- self.panelLogin:getWidgetByName("btnEnterGame"):pos(978,45)
		local btnLogout = self.panelServerList:getWidgetByName("btnLogout");
		local btnEnterGame = self.panelServerList:getWidgetByName("btnEnterGame");
		
		local btnLogoutSize = btnLogout:getContentSize();
		btnLogout:pos(display.left+btnLogoutSize.width/2+20, 45)

		local btnEnterGameSize = btnEnterGame:getContentSize();
		--btnEnterGame:pos(display.right-btnEnterGameSize.width/2-20, 45)
		btnEnterGame:pos(display.cx,50)

		self.panelLogin:setContentSize(display.width, display.height)

		for i,v in ipairs(buttonTable) do
			local btnScence = self.m_serverUI:getWidgetByName(v)
			if v == "btnLogout" then
				-- btnScence:align(display.LEFT_TOP, display.left + 10, display.height - 10)
			elseif v == "btnAnnounceMent" then
				btnScence:align(display.RIGHT_TOP, display.right - 10, display.height - 10)
			end
			GUIFocusPoint.addUIPoint(btnScence, handler(self, self.pushSceneButtons))
		end
		GUIFocusPoint.addUIPoint(self.panelServerList, handler(self, self.pushSceneButtons))
				
		local startNum = 1
		local function startShowBg()
			
			btnEnterGame:loadTextureNormal("new_common_ui_enter_game_now_"..startNum..".png",ccui.TextureResType.plistType)

			startNum= startNum+1
			if startNum ==11 then
				startNum =1
			end
		end
		self.panelLogin:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(10)))
	end

	cc.EventProxy.new(GameSocket,self)
		:addEventListener(GameMessageCode.EVENT_LOADCHAR_LIST, handler(self, self.handleCharLoaded))
		:addEventListener(GameMessageCode.EVENT_KEYBOARD_PASSED, handler(self, self.onKeyboard))

	self.loginManager = GameLogin:new()
	self:handleScenePartVisible(false)
	--默认显示列表
	self:onSelectServer()
	self:showServerZoneList()

end

function GPageServerList:showDragon()
	--我家大门常打开
	self.panelLogin:getChildByName("btnSelectServerContainer"):getChildByName("Image_1"):setVisible(false)
	self.panelLogin:getChildByName("btnSelectServerContainer"):getChildByName("btnSelectServer"):setVisible(false)
	
	--不再显示动画
	--self:pushLoginButton()
	
	--以下是显示开门动画
	--[[
	local startNum = 1
	local img_bottom_bg = self.m_serverUI:getWidgetByName("img_bottom_bg")
	img_bottom_bg:align(display.CENTER, display.cx, display.cy)
	local function startOpen()
		if startNum < 9 then
			asyncload_callback("ui/image/dragon_"..startNum..".png", img_bottom_bg, function (filepath, texture)
				if GameUtilSenior.isObjectExist(img_bottom_bg) then
					img_bottom_bg:loadTexture(filepath):scale(display.height/640)
				end
			end)
		end
		startNum = startNum + 1
		if startNum >= 9 then
			self:pushLoginButton()
		end
	end
	self.m_serverUI:runAction(cca.rep(cca.seq({cca.delay(0.25),cca.cb(startOpen)}),tonumber(10)))
	]]
	local img_top_bg = self.m_serverUI:getWidgetByName("img_top_bg")
	img_top_bg:loadTexture("ui/image/server_select.png"):scale(cc.MAX_SCALE)
	self:pushLoginButton()
end

function GPageServerList:openDoor(ui)
	--我家大门常打开
	local startNum = 1
	local doorNum = 7
	local img_left = ui:getWidgetByName("img_leftdoor")
	local img_right = ui:getWidgetByName("img_rightdoor")
	local function startOpen()
		asyncload_callback("ui/image/OpenDoor/img_door"..startNum..".jpg", img_left, function (filepath, texture)
			if GameUtilSenior.isObjectExist(img_left) then
				img_left:loadTexture(filepath):scale(display.height/640)
			end
			if GameUtilSenior.isObjectExist(img_right) then
				img_right:loadTexture(filepath):scale(display.height/640)
			end
		end)
		startNum = startNum + 1
		if startNum >= 8 then
			-- img_left:hide()
			-- img_right:hide()
			img_left:runAction(cca.fadeOut(0.5))
			img_right:runAction(cca.fadeOut(0.5))
			self:handleScenePartVisible(false)
		end
	end
	img_right:setFlippedX(true)
	ui:runAction(cca.rep(cca.seq({cca.delay(0.25),cca.cb(startOpen)}),tonumber(7)))
end
function GPageServerList:onKeyboard(event)
	if event.key=="back" then
		-- GameBaseLogic.ShowExit()
	end
end

function GPageServerList:onSelectServer(  ) --选择服务器
	self:hideAndShowPanel(self.panelServerList)
end

function GPageServerList:showServerZoneList()
	self.serverList = self.loginManager:getServers()
	--服务器组列表
	self.zoneList = {}
	for i=1,#self.serverList,1 do
		local hasSave = false
		for j=1,#self.zoneList,1 do
			if tonumber(self.zoneList[j].zoneNumber)==tonumber(self.serverList[i].zoneNumber) then
				hasSave = true
			end
		end
		if hasSave == false then
			self.zoneList[#self.zoneList+1]={}
			self.zoneList[#self.zoneList].zoneName=self.serverList[i].zoneName
			self.zoneList[#self.zoneList].zoneNumber=tonumber(self.serverList[i].zoneNumber)
		end
	end
	print("self.zoneList",#self.zoneList)
	local zoneListUI = self.m_serverUI:getWidgetByName("zoneServer")
	zoneListUI:reloadData(#self.zoneList, handler(self, self.updateServerZoneList))
	self:showHistoryList()
end

function GPageServerList:showHistoryList()
	self.serverId=GameSetting.Data["LastServerId"]


	local recommendId = self.loginManager:getRecommendServer()
	-- local btnRecommandServer = self.m_serverUI:getWidgetByName("btnRecommandServer")
	-- if recommendId then
	-- 	btnRecommandServer.tag = recommendId
	-- 	btnRecommandServer:getChildByName("lblSVRName"):setString(self.serverList[recommendId].name)
	-- 	btnRecommandServer:getChildByName("imgSVRStatus"):loadTexture("img_svr_status"..self.serverList[recommendId].status, ccui.TextureResType.plistType)
	-- 	btnRecommandServer:show()
	-- else
	-- 	btnRecommandServer:hide()
	-- end
	-- GUIFocusPoint.addUIPoint(btnRecommandServer, handler(self, self.pushServerButton))
	if self.serverId == nil or self.serverId == "" then
		self.serverId = self.serverList[recommendId].serverId
	end
	
	local info = self.loginManager:getServerById(self.serverId)
	if info then
		self.m_serverUI:getWidgetByName("btnSelectServer"):getChildByName("lblServerName"):setString(info.name)

		local btnLastServer = self.m_serverUI:getWidgetByName("btnLastServer")
		btnLastServer.tag = 99999
		btnLastServer.serverId = self.serverId
		btnLastServer:getChildByName("lblSVRLast"):setString(info.name)
		btnLastServer:loadTextureNormal("btn_gate_sel.png", ccui.TextureResType.plistType)
		local status = info.status
		if tonumber(info.status) > 2 then
			status = 1
		end

		btnLastServer:getChildByName("imgSVRStatus"):loadTexture("img_svr_status"..status..".png", ccui.TextureResType.plistType)
		GUIFocusPoint.addUIPoint(btnLastServer, handler(self, self.pushServerButton))

		if self.directEnter and info.socket and info.socket ~= "" then
			self:pushLoginButton()
			GameCCBridge.showMsg(GameLanguage.Com_Loading, 1)
		end
	else
		self.m_serverUI:getWidgetByName("btnLastServer"):setVisible(false)
	end
end

function GPageServerList:updateServerInfo(zoneNumber)
	self.serverList = self.loginManager:getServers()
	--print("--------------serverList = "..json.encode(self.serverList))
	
	self.curServerListItem = {}
	
	self.curServerList = {}
	for i=1,#self.serverList,1 do
		if tonumber(self.serverList[i].zoneNumber) == tonumber(zoneNumber) then
			self.curServerList[#self.curServerList+1] = self.serverList[i]
		end
	end
	
	--服务器列表
	local list = self.m_serverUI:getWidgetByName("listServer")
	list:reloadData(#self.curServerList, handler(self, self.updateServerList))

	self.directEnter = false
end

function GPageServerList:pushSceneButtons(pSender)
	local btnName = pSender:getName()
	if btnName == "btnEnterGame" then 
		self:hideAndShowPanel()
		self:showDragon()
	elseif btnName == "btnLogout" and not GameBaseLogic.disEnterButton then
		GameUtilSenior.showAlert(GameLanguage.Com_Tip,"要退出当前账号吗？",{GameLanguage.Com_Confirm, GameLanguage.Com_Cancel},function (event)
			if event.buttonIndex == 1 then
				self:handleScenePartVisible(true)
				GameBaseLogic.ExitToRelogin()
		    end
		end, self)
	elseif btnName == "btnLastServer" or btnName == "panelServerList" then 
		self:hideAndShowPanel()
	end
end

function GPageServerList:showRelatePanel(panel)
	self.curPanel = panel
	if panel then
		--self.tip_chenmi:setVisible(self.curPanel == self.panelServerList)
		self.curPanel:pos(display.cx, display.cy):show()
	end
end

function GPageServerList:hideAndShowPanel(panel)
	local tempPanel = panel or self.panelLogin
	if self.curPanel == tempPanel then return end

	self.curPanel:hide()
	self:showRelatePanel(tempPanel)
end

function GPageServerList:updateServerZoneList(item)
	--self.zoneListItem[#self.zoneListItem+1] = item
	table.insert(self.zoneListItem,item)
	item:getWidgetByName("lblSVRName"):setString(self.zoneList[item.tag].zoneName)
	item.zoneNumber=tonumber(self.zoneList[item.tag].zoneNumber)
	GUIFocusPoint.addUIPoint(item, handler(self, self.pushServerZoneButton))
	if item.tag==self.currentZoneIndex then
		self:pushServerZoneButton(item)
	end
end


function GPageServerList:pushServerZoneButton(cell)
	self.currentZoneIndex = cell.tag
	for i=1,#self.zoneListItem,1 do
		self.zoneListItem[i]:loadTextureNormal("zone_btn.png", ccui.TextureResType.plistType)
	end
	cell:loadTextureNormal("zone_btn_sel.png", ccui.TextureResType.plistType)
	self:updateServerInfo(tonumber(cell.zoneNumber))
end

function GPageServerList:updateServerList(item)
	--print("----------GPageServerList:updateServerList---------item.tag="..item.tag)
	--local svrData = self.loginManager:getServerByIndex(item.tag)
	--self.curServerListItem[#self.curServerListItem+1] = item
	table.insert(self.curServerListItem,item)
	local svrData = self.curServerList[item.tag]
	item:hide()--:setTouchEnabled(false)
	if svrData then
		item:setOpacity(255 * 0.6)
		item:getWidgetByName("lblSVRName"):setString(svrData.name)
		item:getWidgetByName("img_role_num_bg"):hide()
		item:getWidgetByName("imgSVRStatus"):loadTexture("img_svr_status0.png", ccui.TextureResType.plistType)
		if svrData.socket and svrData.socket ~= ""  then
			local status = svrData.status
			if tonumber(svrData.status) > 2 then
				status = 1
			end
			-- 0 维护 1 流畅  2 爆满
			item:getWidgetByName("imgSVRStatus"):loadTexture("img_svr_status"..status..".png", ccui.TextureResType.plistType)
		end
		if GameBaseLogic.svrRole and type(GameBaseLogic.svrRole)=="table" then
			if GameBaseLogic.svrRole[svrData.serverId] and tonumber(GameBaseLogic.svrRole[svrData.serverId])>0 then
				item:getWidgetByName("img_role_num_bg"):show()
				item:getWidgetByName("img_role_num_bg"):getWidgetByName("lbl_role_num"):setString(tostring(GameBaseLogic.svrRole[svrData.serverId]))
			end
		end
		if svrData.role and tonumber(svrData.role)>0 then
			item:getWidgetByName("img_role_num_bg"):show()
			item:getWidgetByName("img_role_num_bg"):getWidgetByName("lbl_role_num"):setString(tostring(svrData.role))
		end
		item.socket = svrData.socket
		if not item.cellCallBack then
			item.cellCallBack = true
			GUIFocusPoint.addUIPoint(item, handler(self, self.pushServerButton))
		end
		local imgSVRTag = item:getChildByName("imgSVRTag")
		if svrData.isNew and tonumber(svrData.isNew) == 1 then
			if not imgSVRTag then
				imgSVRTag = ccui.ImageView:create("img_svr_tag1.png", ccui.TextureResType.plistType):setName("imgSVRTag")
					:align(display.CENTER, 210, 35)
					:addTo(item)
			end
			imgSVRTag:show()			
		elseif imgSVRTag then
			imgSVRTag:hide()
		end
		item:show()
	end
end

function GPageServerList:pushServerButton(cell)
	print("------pushServerButton-----")
	print("---------cell.tag = "..cell.tag)

	--最近登录
	self.m_serverUI:getWidgetByName("btnLastServer"):loadTextureNormal("btn_gate.png", ccui.TextureResType.plistType)
	--服务器列表
	for i=1,#self.curServerListItem,1 do
		self.curServerListItem[i]:loadTextureNormal("btn_gate.png", ccui.TextureResType.plistType)
	end
	cell:loadTextureNormal("btn_gate_sel.png", ccui.TextureResType.plistType)
	
	local svrData  = nil
	if cell.tag==99999 then
		--最近登录
		svrData =  self.loginManager:getServerById(cell.serverId)
	else
		--服务器列表
		svrData = self.curServerList[cell.tag]
	end
	
	--local svrData = self.loginManager:getServerByIndex(cell.tag)
	
	if (cell.tag ~= nil) and (svrData ~= nil) then
		local info = svrData

		if info and info.status then
			self.serverId = info.id
			self.m_serverUI:getWidgetByName("btnSelectServer"):getChildByName("lblServerName"):setString(info.name)
			--self:hideAndShowPanel()
		-- elseif info and info.status and tonumber(info.status) == 0 then
		-- 	GameUtilSenior.showAlert("", GameLanguage.GPageServerList_Server_Weihu.."!", "")
		-- elseif info and info.status and tonumber(info.status) == 6 then
		-- 	GameUtilSenior.showAlert("", "尚未到开区时间，请稍后进入".."!", "")
		end
	end
end

function GPageServerList:onExit()
	-- loginScene和GPageServerList 都用的同一个合图， 所以这里不能removeFramesByFile
	-- cc.SpriteManager:getInstance():removeFramesByFile("ui/sprite/GPageServerList")
	cc.CacheManager:getInstance():releaseUnused(false)
	
	GameBaseLogic.disEnterButton = false
end

function GPageServerList:pushLoginButton(pSender)
	if not GameBaseLogic.disEnterButton then
		local svrData = self.loginManager:getServerById(self.serverId)--GameBaseLogic.lastSvr
		if svrData == nil then
			svrData = self.serverList[1]
		end

		if svrData.socket and svrData.socket ~= "" then
			local errorFun= function (code, msg)
				GameUtilSenior.showAlert(GameLanguage.Com_Tip,msg,{GameLanguage.Com_Confirm},function (event)

				end, self)
			end
			local progressFun=function (code,msg)
				--GameBaseLogic.showConnecting(self.connectBox,true,msg)
				self.panelConnect:setVisible(true)
				self.panelConnect:getChildByName("Text_Connect"):setString(msg):align(display.CENTER, display.cx, display.cy + 80)
								:setLocalZOrder(2)

				local sprite = cc.Sprite:create()
    						:align(display.CENTER, display.cx, display.cy + 15)
    						:addTo(self.panelConnect)

				if not sprite then return end
				cc.Director:getInstance():getActionManager():removeAllActionsFromTarget(sprite)
				
				local frames = display.newFrames("loadingtips%d.png", 1, 10)
				local animation = display.newAnimation(frames, 0.1)
				sprite:playAnimationForever(animation)
				sprite:setScale(1.5)
				
			end
			local successFun=function()
				GameSocket:ListCharacter()
			end
			self.loginManager:selectServer(svrData.id,errorFun,progressFun,successFun)
    		return
		else
			GameUtilSenior.showAlert(GameLanguage.Com_Not_Open, GameLanguage.Com_Open_Zone_Time.."："..svrData.openDateTime..","..GameLanguage.GPageServerList_Refresh_List.."?" ,{GameLanguage.Com_Confirm, GameLanguage.Com_Cancel}, function (event)
				if event.buttonIndex == 1 then
					self.directEnter = true
					self:requestServerList()
				end
			end)
			-- GameUtilSenior.showAlert("尚未开启", "开区时间："..svrData.openDateTime, "确定")
			return
		end
		GameUtilSenior.showAlert("", GameLanguage.GPageServerList_ServerData_YiChang, GameLanguage.Com_Confirm)
	end
end

function GPageServerList:handleCharLoaded(event)
	cc.SpriteManager:getInstance():removeFramesByFile("ui/sprite/GPageServerList")
	
	if #GameSocket._netChars > 0 then
		asyncload_frames("ui/sprite/GPageCharacterSelect",".png",function ()
			display.replaceScene(GPageCharacterSelect.new())
	    end,self)
	else
		asyncload_frames("ui/sprite/GPageCharacterCreate",".png",function ()
			display.replaceScene(GPageCharacterCreate.new())
		end,self)
	end
end

function GPageServerList:handleScenePartVisible(isAccount)
	if isAccount then
		print("====>GPageServerList.isAccount = true")
	else
		print("====>GPageServerList.isAccount = false")
	end

	--self.m_serverUI:getWidgetByName("btnLogout"):setVisible(not isAccount)
	if isAccount then
		self.curPanel:setVisible(false)
	end

	self.curPanel = self.panelLogin:setVisible(not isAccount)
	if not isAccount then self.curPanel:pos(display.cx, display.cy) end
end

return GPageServerList