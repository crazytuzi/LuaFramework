local CreateRoleScene = class("CreateRoleScene",function() return cc.Scene:create() end)

local CommPath = "res/createRole/"

function CreateRoleScene:ctor()
	__G_ON_CREATE_ROLE = true

    print("g_scrSize.width=[" .. g_scrSize.width .. "] g_scrSize.height=[" .. g_scrSize.height .. "]");

	local msgids = {LOGIN_SC_DELETE_PLAYER}
    require("src/MsgHandler").new(self,msgids)

    self:getSaveData()
    self.showIndex = nil

    local path = "res/createRole/"

    --if Device_target == cc.PLATFORM_OS_WINDOWS then
    local game_str = g_Channel_tab.game or "longwen"
	local bg = createSprite(self, path.."bg.jpg", cc.p(display.cx,0), cc.p(0.5,0.0))

    local c_size = bg:getContentSize()
    local scale = g_scrSize.width/c_size.width
    if g_scrSize.height/c_size.height > scale then scale = g_scrSize.height/c_size.height end
    bg:setScale(scale)

    --左侧柱子
    local LC = createSprite(self, CommPath.."left.png", cc.p(0,0), cc.p(0.0,0.0))
    LC:setScale(scale)

    --右侧柱子
    local RC = createSprite(self, CommPath.."right.png", cc.p(display.width,0), cc.p(1.0,0.0))
    RC:setScale(scale)

    --底座
    local BT = createSprite(self, CommPath.."bottom.png", cc.p(display.cx,0), cc.p(0.5,0.0))

    --[[
    local bg0 = createSprite(self, path.."bg.jpg", cc.p(display.cx,0), cc.p(0.5,0.0))
    bg0:setScale(scale)
    bg0:setLocalZOrder(-1)

    local mars = Effects:create(false)
    mars:playActionData("createmars", 12, 1, -1)
	bg:addChild(mars)
	mars:setPosition(cc.p(600, 400))
    addEffectWithMode(mars, 3)
    ]]

    --createSprite(self, CommPath.."title_chose.png", cc.p(display.cx, display.height-40), cc.p(0.5,   0.5))

    local fireLeft = Effects:create(false)
    fireLeft:playActionData("createfire", 12, 2, -1)
	BT:addChild(fireLeft)
	fireLeft:setPosition(cc.p(250, 285))
    addEffectWithMode(fireLeft, 3)

	local fireRight = Effects:create(false)
	fireRight:playActionData("createfire", 12, 2, -1)
	BT:addChild(fireRight)
	fireRight:setPosition(cc.p(900, 285))
    addEffectWithMode(fireRight, 3)

    --上下镶边
    createSprite(self, CommPath.."sperate.png", cc.p(display.cx,display.height), cc.p(0.5,1.0),999)
    local sper2 = createSprite(self, CommPath.."sperate.png", cc.p(display.cx,0), cc.p(0.5,0.0),999)
    sper2:setFlippedY(true)


    local startGame = function()
		__G_ON_CREATE_ROLE = nil
		if self.roleTab[self.selectIndex] and self.roleTab[self.selectIndex].data.RoleID then
			AudioEnginer.playEffect("sounds/uiMusic/ui_enter.mp3", false)
			game.goToScenes("src/login/OpenDoor", self.roleTab[self.selectIndex].data.RoleID)
			setLocalRecordByKey(2,"lastRoleID", self.roleTab[self.selectIndex].data.RoleID) 
	    else
	    	AudioEnginer.playEffect("sounds/uiMusic/ui_role.mp3", false)
	    	game.goToScenes("src/login/CreateRole")
	    end
	end

	self.roleTab = {}
	for i=1,3 do
		if g_roleTable[i] then
			self.roleTab[i] = {}
			self.roleTab[i].data = g_roleTable[i]
			self.roleTab[i].node = cc.Node:create()
			local effect = Effects:create(false)
			effect:playActionData("createRole"..self.roleTab[i].data.School.."-"..self.roleTab[i].data.Sex, 5, 2.0, -1)
			--effect:setScale(0.85)
			effect:setCascadeOpacityEnabled(true)
			self.roleTab[i].node:addChild(effect)
            effect:setTag(991)

            local effect2 = Effects:create(false)
			effect2:playActionData("createRoleEff"..self.roleTab[i].data.School.."-"..self.roleTab[i].data.Sex, 10, 2.0, -1)
			--effect2:setScale(0.85)
			effect2:setCascadeOpacityEnabled(true)
			self.roleTab[i].node:addChild(effect2)
            effect2:setTag(992)
            addEffectWithMode(effect2, 2);

            --[[
			local nameBg = createSprite(self.roleTab[i].node, "res/common/100.png", cc.p(0, -170), cc.p(0.5, 0.5), nil, 0.8)
			nameBg:setTag(100)
			local deleteNode = cc.Node:create()
			nameBg:addChild(deleteNode)
			deleteNode:setPosition(cc.p(250, nameBg:getContentSize().height/2))
			deleteNode:setTag(100)
            local nameLabel = createLabel(nameBg, "Lv."..self.roleTab[i].data.Level.. " "..self.roleTab[i].data.Name, getCenterPos(nameBg), cc.p(0.5, 0.5), 26, true, nil, nil)
			nameLabel:enableOutline(cc.c4b(20,20,20,255),1)
            ]]

			self.roleTab[i].showFunc = function() 
											self.selectIndex = i 
											self:updateData() 
											log("self.selectIndex = "..self.selectIndex) 

                                            --[[
											-- if self.deleteBtn then
											local nameBg = self.roleTab[i].node:getChildByTag(100)
											if nameBg then
												local deleteNode = nameBg:getChildByTag(100)
												if deleteNode then
													startTimerAction(self, 0.0, false, function()
														deleteNode:removeAllChildren()

														for i,v in ipairs(self.roleTab) do
															local nameBg = self.roleTab[i].node:getChildByTag(100)
															if nameBg then
																local deleteNode = nameBg:getChildByTag(100)
																if deleteNode then
																	deleteNode:removeAllChildren()
																end
															end
														end

														local deleteFunc = function()
															--AudioEnginer.playTouchPointEffect()
															local yesCallback = function()
																local yesCallback1 = function()
																	--g_msgHandlerInst:sendNetDataByFmtEx(LOGIN_CS_DELETE_PLAYER, "ii", userInfo.userId, self.roleTab[self.selectIndex].data.RoleID)
																	local t = {}
																	t.userID = userInfo.userId
																	t.roleID = self.roleTab[self.selectIndex].data.RoleID
																	t.sessionToken = userInfo.sessionToken
																	g_msgHandlerInst:sendNetDataByTableEx(LOGIN_CS_DELETE_PLAYER, "LoginDeletePlayerReq", t)
																	addNetLoading(LOGIN_CS_DELETE_PLAYER, LOGIN_SC_DELETE_PLAYER, false, 1, 2)
																end
																local noCallback1 = function()
																end
																MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("login_deleteConfirm2"),yesCallback1,noCallback1,game.getStrByKey("sure"),game.getStrByKey("cancel"))
															end
															local noCallback = function()
															end
															MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("login_deleteConfirm"),yesCallback,noCallback,game.getStrByKey("sure"),game.getStrByKey("cancel"))
														end
														--local deleteBtn = createTouchItem(self, path.."delRole.png", cc.p(display.width-110, display.height-50), deleteFunc)
														local deleteBtn = createTouchItem(deleteNode, CommPath.."delete.png", cc.p(0, 0), deleteFunc)
														deleteBtn:setScale(0.8)
													end)
												end
											end
											-- end
                                            ]]

										end
			self.roleTab[i].touchFunc = function() 
											
			 							end

			if self.roleTab[i].data.RoleID == self.saveRoleID then
				self.showIndex = i
				-- dump(self.showIndex)
			end
		else
			self.roleTab[i] = {}
			self.roleTab[i].data = nil
			self.roleTab[i].node = cc.Node:create()
			local effect = Effects:create(false)
			effect:playActionData("createRole1-1", 4, 0.8, -1)
			--effect:setScale(0.85)
			effect:setCascadeOpacityEnabled(true)
			effect:setColor(cc.c3b(0, 0, 0))
			self.roleTab[i].node:addChild(effect)
			--createSprite(self.roleTab[i].node, path.."modelb.png", cc.p(self.roleTab[i].node:getContentSize().width/2, 160), cc.p(0.5, 0.5), -1, 0.8)
			self.roleTab[i].showFunc = function() 
											self.selectIndex = nil 
											self:updateData() 
											log("self.selectIndex = nil") 
										end
			self.roleTab[i].touchFunc = function()
                -- 点击未知角色，直接开启创建角色
                if self.selectIndex == nil then
				    startGame();
                end
			end
		end
	end

	--开始游戏或创建角色
	local btnMenu = cc.Menu:create()
	btnMenu:setPosition(cc.p(0,0))
	self:addChild(btnMenu)
	self.rolesp_tab = {}

	local createItem = createMenuItem(self, CommPath.."enter.png", cc.p(display.cx+360, 65), startGame,nil,nil,true)--cc.MenuItemImage:create(path.."btn.png",path.."btn.png")
	self.createItem = createItem
	-- self.startImage = createSprite(createItem,path.."startgame.png",cc.p(128,38))
	-- createItem:setPosition(cc.p(g_scrSize.width-130,50))
	-- createItem:registerScriptTapHandler(startGame)
	-- btnMenu:addChild(createItem)

	--返回
	local backFunc = function()
		AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false)
		g_msgHandlerInst:sendNetDataByTableExEx(LOGIN_CG_EXIT_LOGIN, "LoginClientExitLoginReq", {});
		globalInit()
		game.ToLoginScene()	
	end
	createMenuItem(self, CommPath.."back.png", cc.p(display.cx-360,65), backFunc,nil,nil,true)

    self.m_editBg = createSprite(self, "res/createRole/bg_name.png", cc.p(display.cx, 35), cc.p(0.5, 0));
    local editBgSize = self.m_editBg:getContentSize();

    self.m_selRoleLal = createLabel(self.m_editBg, "", cc.p(editBgSize.width/2-20, editBgSize.height/2-5), cc.p(0.5, 0.5), 24, true, nil, nil, cc.c3b(238, 198, 146));

    local deleteFunc = function()
            AudioEngine.playEffect("sounds/liuVoice/68.mp3", false)

		    local yesCallback = function()
			    local yesCallback1 = function()
				    local t = {}
				    t.userID = userInfo.userId
				    t.roleID = self.roleTab[self.selectIndex].data.RoleID
                    t.sessionToken = userInfo.sessionToken
				    g_msgHandlerInst:sendNetDataByTableEx(LOGIN_CS_DELETE_PLAYER, "LoginDeletePlayerReq", t)
				    addNetLoading(LOGIN_CS_DELETE_PLAYER, LOGIN_SC_DELETE_PLAYER, false, 1, 2)
			    end
			    local noCallback1 = function()
			    end
			    MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("login_deleteConfirm2"),yesCallback1,noCallback1,game.getStrByKey("sure"),game.getStrByKey("cancel"))
		    end
		    local noCallback = function()
		    end
		    MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("login_deleteConfirm"),yesCallback,noCallback,game.getStrByKey("sure"),game.getStrByKey("cancel"))
	    end
    self.m_selRoledeleteBtn = createTouchItem(self.m_editBg, "res/createRole/delete1.png", cc.p(editBgSize.width-50, 30), deleteFunc);
    
	local preBtnFunc = function()
		--log("preBtnFunc 1111111111111111")
		-- AudioEnginer.playEffect("sounds/uiMusic/ui_change.mp3", false)
		if self.showLayer then
			self.showLayer:startAutoMovePre()
		end
	end
	local preBtn = createMenuItem(self, "res/group/arrows/13-1.png", cc.p(display.cx-400, 300), preBtnFunc)
	preBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.cx-400-5, 300)), cc.MoveTo:create(0.3, cc.p(display.cx-400, 300)))))
	preBtn:setOpacity(255*0.5)
    preBtn:setVisible(false)

	local nextBtnFunc = function()
		--log("nextBtnFunc 2222222222222222")
		-- AudioEnginer.playEffect("sounds/uiMusic/ui_change.mp3", false)
		if self.showLayer then
			self.showLayer:startAutoMoveNext()
		end
	end
	local nextBtn = createMenuItem(self, "res/group/arrows/13.png", cc.p(display.cx+400, 300), nextBtnFunc)
	nextBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.cx+400+5, 300)), cc.MoveTo:create(0.3, cc.p(display.cx+400, 300)))))
	nextBtn:setOpacity(255*0.5)
    nextBtn:setVisible(false)

	local param = {}
    param.radius = 220
    param.nodeNum = 3
    param.moveRate = 0.5
    param.autoMove = 8
    param.yOff = display.height * - 20 / 640
    param.centrePos = cc.p(display.cx - 10 * display.width/1050, display.cy - 25 * display.height/640)
    param.boxWidth = 100
    param.boxHeight = 250
    param.moveFunc = function()  
    					--log("move !!!!!!!!!!!")
   						for i,v in ipairs(self.roleTab) do
							local nameBg = self.roleTab[i].node:getChildByTag(100)
							if nameBg then
								local deleteNode = nameBg:getChildByTag(100)
								if deleteNode then
									deleteNode:removeAllChildren()
								end
							end
						end
					end
    -- dump(display)
    dump(g_scrSize)
    if g_scrSize.width > 1050 and g_scrSize.height > 640 then 
        for i=1,3 do
        	self.roleTab[i].node:setScale(1)
        end
    	param.radius = 370
    	param.centrePos = cc.p(display.cx-20, display.cy-55)
    	deleteBtn:setPosition(cc.p(display.width/2+115, 185))
    end

    -- if g_scrSize.width == 960 and g_scrSize.height == 640 then 
    --     for i=1,3 do
    --     	self.roleTab[i].node:setScale(1)
    --     end
    -- 	param.radius = 295
    -- 	param.centrePos = cc.p(display.cx-20, display.cy)
    -- 	param.yOff = 35
    -- 	deleteBtn:setPosition(cc.p(display.width/2+115, 140))
    -- end

    -- if g_scrSize.width == 1280 and g_scrSize.height == 960 then 
    -- 	param.yOff = -400
    -- 	param.centrePos = cc.p(display.cx, display.cy-35)
    -- end

    param.nodes = {{node=self.roleTab[1].node, showFunc=self.roleTab[1].showFunc, touchFunc=self.roleTab[1].touchFunc},
                    {node=self.roleTab[2].node, showFunc=self.roleTab[2].showFunc, touchFunc=self.roleTab[2].touchFunc},
                    {node=self.roleTab[3].node, showFunc=self.roleTab[3].showFunc, touchFunc=self.roleTab[3].touchFunc},}
    local layer = require("src/ShowOnCircleLayer").new(param)
    self.showLayer = layer
    layer:setPositionY( -1*(display.cy - 185 - 175))
    self:addChild(layer)

    if self.showIndex then
    	layer:setShowNodeByIndex(self.showIndex)
    end

    if not AudioEnginer.isBackgroundMusicPlaying() then
		AudioEnginer.playMusic("sounds/login.mp3",true)
	end
end

function CreateRoleScene:updateData()
	self:updateUI()
end

function CreateRoleScene:updateUI()
	if self.selectIndex == nil then
		--self.startImage:setTexture("res/createRole/createWord.png")
		self.createItem:setImages(CommPath.."create.png")
        self.m_selRoleLal:setString("");
		self.m_editBg:setVisible(false)
	else
		--self.startImage:setTexture("res/createRole/startgame.png")
		self.createItem:setImages(CommPath.."enter.png")
        self.m_selRoleLal:setString("Lv."..self.roleTab[self.selectIndex].data.Level.. " "..self.roleTab[self.selectIndex].data.Name);
		self.m_editBg:setVisible(true)
	end
end

function CreateRoleScene:getSaveData()
	self.server =  getLocalRecordByKey(1,"lastServer",-1)
	if self.server == -1 then
		self.server = 0
	end
	self.saveRoleID = getLocalRecordByKey(2, "lastRoleID", "0");
end

function CreateRoleScene:networkHander(luaBuffer,msgid)    --删除角色成功服务器返回
    local switch = {
        [LOGIN_SC_DELETE_PLAYER] = function()
        	local t = g_msgHandlerInst:convertBufferToTable("LoginDeletePlayerRet", luaBuffer) 
        	local id = t.roleID
        	local flg = t.result
        	if flg == 0 then
	        	setLocalRecordByKey( 2 , "activityPopKey" .. tostring(id) , "" )  	--清除角色活动弹出键值
	        	for k,v in pairs(g_roleTable)do
					if v["RoleID"] == id then
						setRoleInfo(2, nil, nil, nil, v.Name)
						table.remove(g_roleTable,k)
						if g_roleTable and #g_roleTable > 0 then              --删除后是否还存留角色
							--game.goToScenes("src/login/CreateRoleFirst")
                            package.loaded[ "src/login/CreateRole" ] = nil
							Director:replaceScene(require("src/login/CreateRoleFirst").new())
						else
                            package.loaded[ "src/login/CreateRole" ] = nil
							game.goToScenes("src/login/CreateRole")
							--Director:replaceScene(require("src/login/CreateRole").new())
						end
						break
					end
				end

			else
				TIPS( {str = game.getStrByKey("login_delPlayer"), isMustShow = true })
			end
        end,
    }
    if switch[msgid] then 
        switch[msgid]()
    end
end

return CreateRoleScene