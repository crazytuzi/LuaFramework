local CreateRoleScene = class("CreateRoleScene",function() return cc.Scene:create() end)
require "src/utf8"

local CommPath = "res/createRole/"

function CreateRoleScene:ctor()
	__G_ON_CREATE_ROLE = true
	
	local midX = g_scrSize.width/2
	if not AudioEnginer.isBackgroundMusicPlaying() then
		AudioEnginer.playMusic("sounds/login.mp3",true)
	end

	local msgids = {LOGIN_SC_CREATEPLAYER,LOGIN_SC_RANDNAME}
    require("src/MsgHandler").new(self,msgids)
	self.server =  getLocalRecordByKey(1,"lastServer",-1)
	if self.server == -1 then
		cclog("self.server got -1, default to 0")
		self.server = 0
	end
	--bg
	local logo_scale = 1
	local bg = createSprite(self,CommPath.."bg.jpg",cc.p(midX,0),cc.p(0.5,0.0))
    --if g_scrSize.width > 960 and g_scrSize.height > 640 then 
        local c_size = bg:getContentSize()
        local scale = g_scrSize.width/c_size.width
        if g_scrSize.height/c_size.height > scale then scale = g_scrSize.height/c_size.height end
        bg:setScale(scale)
        if g_scrSize.width > 960 and g_scrSize.height > 640 then 
	        if Device_target ~= cc.PLATFORM_OS_ANDROID then
	        	logo_scale = 1.4
	        end
	    end
    --end

    --左侧柱子
    local LC = createSprite(self, CommPath.."left.png", cc.p(0,0), cc.p(0.0,0.0))
    LC:setScale(scale)
    self.LC = LC

    --右侧柱子
    local RC = createSprite(self, CommPath.."right.png", cc.p(display.width,0), cc.p(1.0,0.0))
    RC:setScale(scale)
    self.RC = RC

    --底座
    local BT = createSprite(self, CommPath.."bottom.png", cc.p(display.cx,0), cc.p(0.5,0.0))

 --[[   local bg0 = createSprite(self, CommPath.."bg.jpg", cc.p(display.cx,0), cc.p(0.5,0.0))
    bg0:setScale(scale)
    bg0:setLocalZOrder(-1)

    local mars = Effects:create(false)
    mars:playActionData("createmars", 12, 2, -1)
	bg:addChild(mars)
	mars:setPosition(cc.p(600, 400))
    addEffectWithMode(mars, 3)
]]

    self.bg = bg
    self.random_id = 0
    --createSprite(self, CommPath.."title_create.png", cc.p(display.cx, display.height-40), cc.p(0.5, 0.5))

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

	math.randomseed(os.clock()*10000)
	self.currSchool = math.random(1,3) 
	self.role_tab = {}
	if g_roleTable and #g_roleTable > 0 then
		for k,v in pairs(g_roleTable)do
			local index = v["School"]+(tonumber(v["Sex"])-1)*3
			self.role_tab[index] = {}
			self.role_tab[index].name = v["Name"]
			self.role_tab[index].lv = v["Level"]
			if self.role_tab[index].lv == 0 then
				self.role_tab[index].lv = 1
			end
			self.role_tab[index].RoleID = v["RoleID"]
			school = index
		end
	end
	math.randomseed(os.time()) 
	self.cur_sel = math.floor(math.random(1000,3999)/1000)
	if self.role_tab[self.cur_sel] then
		for i=1,3 do
			if not self.role_tab[i] then
				self.cur_sel = i
				break
			end
		end
	end
	self.currSex = 1--math.ceil(self.cur_sel/3)
	self.select_index = self.cur_sel - (self.currSex-1)*3

	--button
	local btnMenu = cc.Menu:create()
	btnMenu:setPosition(cc.p(0,0))
	self:addChild(btnMenu)
    self.menu_items = {}
 
	self.name_bg = createSprite(self,CommPath.."nameBg.png",cc.p(midX,65),cc.p(0.5,0.5))
	local name_lab = createLabel(self.name_bg,"name",getCenterPos(self.name_bg),cc.p(0.5,0.5),24,true)
	if self.role_tab[self.cur_sel] then
		self.name_bg:setVisible(true)
		name_lab:setString(self.role_tab[self.cur_sel].name.." Lv."..self.role_tab[self.cur_sel].lv )
		name_lab:setColor(MColor.yellow)
	else
		self.name_bg:setVisible(false)
	end
	local sch_str = {"zhanshi","fashi","daoshi"}
	self.random_names = {}

	local menuFunc = function(tag,sender,sex)
		self.currSchool = tag 
		self.cur_sel = self.currSchool+(self.currSex-1)*3
	 	-- local txt = self.nickNameCtrl:getText()
	 	-- if string.len(txt) > 0 and  then
	 	-- 	self.random_names[self.currSex] = txt
	 	-- end
		-- AudioEnginer.stopAllEffects()
		--cc.SimpleAudioEngine:getInstance():playEffect("sounds/roleMusic/"..self.cur_sel..".mp3", false)

		if self.inputName then
			self.nickNameCtrl:setText(self.inputName)
			self:updateNameCtrlPos()
		else
			if self.random_names[self.currSex] then
				self.nickNameCtrl:setText(self.random_names[self.currSex])	
				self:updateNameCtrlPos()			
			else
                local LoginScene = require("src/login/LoginScene")
                local tmpPlat = sdkGetPlatform();
                -- 微信/QQ登录
                require("src/utf8");
                if tmpPlat ~= 0 and LoginScene.myNickName and string.isValidUtf8(LoginScene.myNickName) then
                    local nickName = LoginScene.myNickName;
                    
                    if string.utf8len(LoginScene.myNickName) > 6 then
                        nickName = string.utf8sub(LoginScene.myNickName, 1, 6);
                    end 
        
		            self.nickNameCtrl:setText(nickName)
		            self:updateNameCtrlPos();
                else
				    self:generateNameBySex()
                end
			end
		end

		if self.edit_bg then
			--self.edit_bg:setVisible(not self.role_tab[self.cur_sel])
			self.edit_bg:setVisible(true)
		end
		if self.name_bg then
			--self.name_bg:setVisible(not not self.role_tab[self.cur_sel])
			self.name_bg:setVisible(true)
		end
	end
	self.menuFunc = menuFunc

	self.edit_bg = createSprite(self,CommPath.."nameBg.png",cc.p(midX,65),cc.p(0.5,0.5))
    local editBgSize = self.edit_bg:getContentSize();
	self.edit_bg:setLocalZOrder(4)
	self.edit_bg:setVisible(not self.role_tab[self.cur_sel])
	local function editBoxTextEventHandle(strEventName,pSender)
	 	local edit = tolua.cast(pSender,"ccui.EditBox") 

        if strEventName == "began" then --编辑框开始编辑时调用

        elseif strEventName == "ended" then --编辑框完成时调用

        elseif strEventName == "return" then --编辑框return时调用
        	log("return")
        	local str = edit:getText()
        	-- if string.utf8len(str) > 6 then
        	-- 	TIPS({str = game.getStrByKey("create_role_name_long_tip"), type = 1})
        	-- 	return
        	-- end
        	if str ~= "" then
        		self.inputName = str
        	end
        	self:updateNameCtrlPos()
        elseif strEventName == "changed" then --编辑框内容改变时调用
        	log("changed")
        	self:updateNameCtrlPos()
        end
	end

	--local editeBg = createScale9Sprite(self.edit_bg, "res/common/scalable/input_1.png", cc.p(45, 25), cc.size(180, 42), cc.p(0, 0.5))
	local nickNameCtrl = createEditBox(self.edit_bg, nil, cc.p((editBgSize.width-176)/2-30, editBgSize.height/2), cc.size(176, 34), MColor.white, 24, game.getStrByKey("create_input_name"))
	nickNameCtrl:setAnchorPoint(cc.p(0, 0.5))
    nickNameCtrl:setText("")
    nickNameCtrl:setFontColor(MColor.lable_yellow);
    nickNameCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    nickNameCtrl:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    nickNameCtrl:registerScriptEditBoxHandler(editBoxTextEventHandle)
    nickNameCtrl:setMaxLength(12)

    self.nickNameCtrl = nickNameCtrl;
    self:updateNameCtrlPos()

    local diceBtn = createMenuItem(self.edit_bg , CommPath.."dice.png", cc.p(editBgSize.width-60,editBgSize.height/2), function()
        self.inputName = nil;
        self:generateNameBySex();
    end)
    diceBtn:setScale(0.8);

	local createCb = function(tag,sender)
		self:createCb(tag,sender)
	end
	local createItem = createMenuItem(self, CommPath.."enter.png", cc.p(display.cx+360, 65), createCb,nil,nil,true)--cc.MenuItemImage:create(CommPath.."btn.png",CommPath.."btnSel.png")

    
	local function sex1func()
		self.sex1Btn:setTexture(CommPath.."sex1.png")
		self.sex2Btn:setTexture(CommPath.."sex2-1.png")
		AudioEnginer.playEffect("sounds/uiMusic/ui_click3.mp3", false)
		self.currSex = 1
		menuFunc(self.currSchool, nil, self.currSex)
		self:createShow()
	end
	self.sex1Btn = createTouchItem(self, CommPath.."sex1.png", cc.p(display.cx+360-59, 150), sex1func,nil,nil,true)

	local function sex2func()
		self.sex1Btn:setTexture(CommPath.."sex1-1.png")
		self.sex2Btn:setTexture(CommPath.."sex2.png")
		AudioEnginer.playEffect("sounds/uiMusic/ui_click3.mp3", false)
		self.currSex = 2
		menuFunc(self.currSchool, nil, self.currSex)
		self:createShow()
	end
	self.sex2Btn = createTouchItem(self, CommPath.."sex2-1.png", cc.p(display.cx+360+59, 150), sex2func,nil,nil,true)
    

	local backFunc = function()
		AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false)
		if #g_roleTable > 0 then 
			game.goToScenes("src/login/CreateRoleFirst")	
		else
			g_msgHandlerInst:sendNetDataByTableExEx(LOGIN_CG_EXIT_LOGIN, "LoginClientExitLoginReq", {});
			globalInit()
			game.ToLoginScene()
		end	
	end
	createMenuItem(self, CommPath.."back.png", cc.p(display.cx-360,65), backFunc,nil,nil,true)

	local preBtnFunc = function()
		if self.showLayer then
			self.showLayer:startAutoMovePre()
		end
	end
	local preBtn = createMenuItem(self, "res/group/arrows/13-1.png", cc.p(display.cx-400, 300), preBtnFunc)
	preBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.cx-400-5, 300)), cc.MoveTo:create(0.3, cc.p(display.cx-400, 300)))))
	preBtn:setOpacity(255*0.5)
    preBtn:setVisible(false)

	local nextBtnFunc = function()
		if self.showLayer then
			self.showLayer:startAutoMoveNext()
		end
	end
	local nextBtn = createMenuItem(self, "res/group/arrows/13.png", cc.p(display.cx+400, 300), nextBtnFunc)
	nextBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.cx+400+5, 300)), cc.MoveTo:create(0.3, cc.p(display.cx+400, 300)))))
	nextBtn:setOpacity(255*0.5)
    nextBtn:setVisible(false)

	self:createShow()
end

function CreateRoleScene:updateNameCtrlPos()
	local str = self.nickNameCtrl:getText()
	if str == "" then
		str = game.getStrByKey("create_input_name")
	end
	local label = createLabel(nil, str, cc.p(0, 0), cc.p(0, 0), 24)
	--self.nickNameCtrl:setContentSize(label:getContentSize())
	local x = self.edit_bg:getContentSize().width/2 - label:getContentSize().width/2
    x = x/2;
	if x < 70 then
		x = 70
	end

	self.nickNameCtrl:setPosition(cc.p(x, self.edit_bg:getContentSize().height/2))
end

function CreateRoleScene:updateShoolEffect(preSchool, school)
	if self.schoolSpr == nil then
		self.schoolSpr = createSprite(self.RC, CommPath.."school"..school..".png", cc.p(170, 350), cc.p(0.5, 0.5))
	else
		self.schoolSpr:runAction(cc.Sequence:create(
			cc.CallFunc:create(function() self.schoolSpr:setTexture(CommPath.."school"..school..".png") self.schoolSpr:setOpacity(0) end),
			cc.CallFunc:create(function() 
				if preSchool then
				    local effect = Effects:create(false)
				    performWithDelay(effect,function() removeFromParent(effect) effect = nil end,0.5)
				    effect:playActionData("createRoleSchool"..preSchool, 9, 0.5, 1)
					self.RC:addChild(effect)
					effect:setPosition(cc.p(170, 350))
				end
			 end),
			cc.DelayTime:create(0.2),
			cc.FadeIn:create(0.1)
			))
	end

	if self.schoolSprEx == nil then

		self.schoolSprEx = createSprite(self.LC, CommPath.."school"..school.."-1.png", cc.p(100, 370), cc.p(0.5, 0.5))
	else
		self.schoolSprEx:runAction(cc.Sequence:create(
			cc.CallFunc:create(function() self.schoolSprEx:setTexture(CommPath.."school"..school.."-1.png") self.schoolSprEx:setOpacity(0) end),
			cc.CallFunc:create(function() 
				if preSchool then
				    local effect = Effects:create(false)
				    performWithDelay(effect,function() removeFromParent(effect) effect = nil end,0.5)
				    effect:playActionData("createRoleSchool"..preSchool.."-1", 9, 0.5, 1)
				    log("effect: ".."createRoleSchool"..preSchool.."-1")
					self.LC:addChild(effect)
					effect:setPosition(cc.p(100, 370))
				end
			 end),
			cc.DelayTime:create(0.2),
			cc.FadeIn:create(0.1)
			))
	end
end

function CreateRoleScene:createShow()
	if self.showLayer then
		self.showLayer:removeFromParent()
		self.showLayer = nil
	end

	self.roleTab = {}
	for i=1,3 do
		--print("i = "..i)
		self.roleTab[i] = {}
		self.roleTab[i].node = cc.Node:create()

		local effect = Effects:create(false)
		effect:playActionData("createRole"..i.."-"..self.currSex, 5, 2.0, -1)
		--effect:setScale(0.85)
		effect:setCascadeOpacityEnabled(true)
        effect:setTag(991)
        self.roleTab[i].node:addChild(effect)


        local effect2 = Effects:create(false)
        effect2:playActionData("createRoleEff" .. i .. "-" .. self.currSex, 10, 2.0, -1)
        -- effect2:setScale(0.85)
        effect2:setCascadeOpacityEnabled(true)
        self.roleTab[i].node:addChild(effect2)
        effect2:setTag(992)
        addEffectWithMode(effect2, 2);
		
		--createSprite(self.roleTab[i].node, "res/createRole/modelb.png", cc.p(self.roleTab[i].node:getContentSize().width/2, 160), cc.p(0.5, 0.5), -1, 1)
		-- local shoolBg = createSprite(self.roleTab[i].node, "res/createRole/sbg.png", cc.p(self.roleTab[i].node:getContentSize().width/2-160, 200), cc.p(0.5, 0.5), nil, 1)
		-- createSprite(shoolBg, "res/createRole/s"..i..".png", getCenterPos(shoolBg), cc.p(0.5, 0.5))
		self.roleTab[i].showFunc = function() self:updateShoolEffect(self.currSchool, i) self.currSchool = i  self.menuFunc(i,nil,self.currSex) end
		self.roleTab[i].touchFunc = function() end
	end

	local param = {}
    param.radius = 220
    param.nodeNum = 3
    param.moveRate = 0.5
    param.autoMove = 8
    param.yOff = display.height * - 20 / 640
    param.centrePos = cc.p(display.cx - 10 * display.width/1050, display.cy - 32 * display.height/640)
    param.boxWidth = 100
    param.boxHeight = 250
    param.defaultIndex = self.currSchool
    if g_scrSize.width > 1050 and g_scrSize.height > 640 then 
        for i=1,3 do
            self.roleTab[i].node:setScale(1)
        end
        param.radius = 370
        param.centrePos = cc.p(display.cx-20, display.cy-55)
    end

    -- if g_scrSize.width == 960 and g_scrSize.height == 640 then 
    --     for i=1,3 do
    --     	self.roleTab[i].node:setScale(1)
    --     end
    -- 	param.radius = 295
    -- 	param.centrePos = cc.p(display.cx-20, display.cy)
    -- 	param.yOff = 35
    -- end

  	-- if g_scrSize.width == 1280 and g_scrSize.height == 960 then 
  	-- 	param.yOff = -20
   --  	param.centrePos = cc.p(display.cx, display.cy-35)
   --  end
    param.nodes = {{node=self.roleTab[1].node, showFunc=self.roleTab[1].showFunc, touchFunc=self.roleTab[1].touchFunc},
                    {node=self.roleTab[2].node, showFunc=self.roleTab[2].showFunc, touchFunc=self.roleTab[2].touchFunc},
                    {node=self.roleTab[3].node, showFunc=self.roleTab[3].showFunc, touchFunc=self.roleTab[3].touchFunc},}
    local layer = require("src/ShowOnCircleLayer").new(param)
    self:addChild(layer)
    self.showLayer = layer
    layer:setPositionY( -1*(display.cy - 185 - 175))
end

function CreateRoleScene:createCb()
	AudioEnginer.playEffect("sounds/uiMusic/ui_enter.mp3", false)
	if self.isSend then
		return
	end

	local txt = self.nickNameCtrl:getText()
	-- if string.find(txt," ") or string.find(txt,"%^") then
	-- 	TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
	-- 	return
	-- end
	-- require "src/utf8"
	-- if string.utf8len(txt) > 6 then
	-- 	TIPS({ type = 1 , str = game.getStrByKey("invilid_namelen") , isMustShow = true})
	-- 	return
	-- elseif string.utf8len(txt) <= 0 then
	-- 	TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
	-- 	return
	-- end

	if self:checkNameRule(txt) == false then
		return
	end

--[[	local shieldList =  getConfigItemByKey("shieldword","name")
    if shieldList then
    	for k,v in pairs(shieldList) do
		 	local pos = string.find(txt,k) 
			if pos then 
				TIPS({ type = 1 , str = game.getStrByKey("invilid_namelen_ex") , isMustShow = true})
				return
			end
		end
    end
]]

	-- if true then
	-- 	log("ok !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	-- 	return
	-- end

	local param = {}
	param.is_create = true
	param.nickname = txt
	param.sex = self.currSex
	--if self.currSchool == 2 then param.sex = 1 end
	param.school = self.currSchool
	log("param.sex"..param.sex)
	if self.random_names[self.currSex] and self.random_names[self.currSex] ~= param.nickname then
		self.random_id = 0
	end
	self.param = param
	--g_msgHandlerInst:sendNetDataByFmtEx(LOGIN_CS_CREATEPLAYER,"SiiiiiSi",param.nickname,param.sex,userInfo.userId,userInfo.serverId,param.school,1,userInfo.serverName,self.random_id)
	local t = {}
	t.userName = param.nickname
	t.sex = param.sex
	t.userID = userInfo.userId
	t.worldID = userInfo.serverId
	t.school = param.school
	t.modelID = 1;
	t.worldName	= userInfo.serverName
	dump(t)
	g_msgHandlerInst:sendNetDataByTableEx(LOGIN_CS_CREATEPLAYER, "LoginCreatePlayer", t)
    addNetLoading(LOGIN_CS_CREATEPLAYER, LOGIN_SC_CREATEPLAYER, false, 1, 2)
	
	self.isSend = true
	G_ONCREATE_GAME = true
	performWithDelay(self,function() self.isSend = false end ,2.0)
end

-- 1：不能以空格开头、也不能以空格结尾
-- 2：不能以传奇世界、传世、GM、gm、官方、活动XX、宣传XX、推广XX、
-- 3：取名不支持换行
function CreateRoleScene:checkNameRule(name)
	-- log(name)
	-- dump(string.utf8len(name))
	-- dump(string.utf8sub(name, 0, 1))
	-- dump(string.utf8sub(name, -1))
	
	-- if string.utf8len(txt) > 6 then
	-- 	TIPS({ type = 1 , str = game.getStrByKey("invilid_namelen") , isMustShow = true})
	-- 	return
	-- elseif string.utf8len(txt) <= 0 then
	-- 	TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
	-- 	return
	-- end

	if string.find(name, " ") or string.find(name, "%^") then
		TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
		return
	end

	if string.utf8sub(name, 0, 1) == " " then
		TIPS({ type = 1 , str = game.getStrByKey("role_name_rule_1") , isMustShow = true})
		return false
	elseif string.utf8sub(name, -1) == " " then
		TIPS({ type = 1 , str = game.getStrByKey("role_name_rule_1") , isMustShow = true})
		return false
	end

	local word = {"传奇世界", "传世", "GM", "gm", "官方", "活动", "宣传", "推广"}
	for i,v in ipairs(word) do
		if string.find(name, v) then
			--TIPS({ type = 1 , str = string.format(game.getStrByKey("role_name_rule_2"), v) , isMustShow = true})
			TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
			return false
		end
	end

	if string.find(name, "\n") or string.find(name, "\r") then
		TIPS({ type = 1 , str = game.getStrByKey("role_name_rule_3") , isMustShow = true})
		return false
	end

    if DirtyWords:isHaveDirytWords(name) then
        TIPS({ type = 1 , str = game.getStrByKey("invilid_namelen_ex") , isMustShow = true})
		return false;
    end

    require("src/utf8");
    if string.utf8len(name) > 6 then
		TIPS({ type = 1 , str = game.getStrByKey("login_tip_too_long") , isMustShow = true})
		return false;
	end

	log("11111111111111111111111111111")
	return true
end

function CreateRoleScene:generateNameBySex()
	print("send sex = "..self.currSex)

	g_msgHandlerInst:sendNetDataByTableEx(LOGIN_CS_RANDNAME, "LoginRandNameReq", {worldID = self.server, sex = self.currSex} )
    addNetLoading(LOGIN_CS_RANDNAME, LOGIN_SC_RANDNAME, false, 1, 2)
end

local function saveLoginHistory()
    local serStr = getLocalRecordByKey(2, "loginHistory" .. sdkGetOpenId(), "")

    local json = require("json")
    local ret = json.decode(serStr)
    local flg = true
    if ret and #ret > 0 then
        for i,v in ipairs(ret) do
            if v == userInfo.serverId then
                flg = false
                break
            end
        end
    else
        ret = {}
    end

    if flg then
        ret[#ret + 1] = userInfo.serverId
        serStr = json.encode(ret)

        setLocalRecordByKey(2, "loginHistory" .. sdkGetOpenId(), serStr)

        --发送创建角色信息到dir服务器
        local function serverListConnected()
            weakCallbackTab.onServerListConnected = nil
            ServerList.sendLoginServer(sdkGetArea(), userInfo.serverId, true)
        end

        if ServerList.isConnected() then
            serverListConnected()
        else
            weakCallbackTab.onServerListConnected = serverListConnected
            ServerList.connect()
        end
    end
end

function CreateRoleScene:networkHander(luaBuffer,msgid)
    cclog("CreateRoleScene:networkHander")
    local switch = {
        [LOGIN_SC_CREATEPLAYER] = function() 
        	local t = g_msgHandlerInst:convertBufferToTable("LoginCreatePlayerRet", luaBuffer) 
        	userInfo.userid = t.userID
			local roleID = t.roleID
			local ret = t.ret

			print("ret" .. ret)
			if ret == 0 then
                local roleparam = {}
                roleparam.RoleID = roleID
                roleparam.Name = self.param.nickname
                roleparam.Level = 1
                roleparam.School = self.currSchool
                roleparam.Sex = self.currSex
                table.insert(g_roleTable,roleparam)

                saveLoginHistory()
                
                -- 直接确定后进入游戏
                AudioEnginer.playEffect("sounds/uiMusic/ui_enter.mp3", false);

				game.goToScenes("src/login/OpenDoor",roleID)
			elseif ret == -1 then
                removeNetLoading()
                MessageBox(game.getStrByKey("create_no_name"))
            elseif ret == -2 then
                removeNetLoading()
                MessageBox(game.getStrByKey("create_same_name"))
            elseif ret == -3 then
                removeNetLoading()
                MessageBox(game.getStrByKey("create_too_long"))             
            elseif ret == -4 then
                removeNetLoading()
                MessageBox(game.getStrByKey("create_invalid_char"))             
            elseif ret == -5 then
                removeNetLoading()
                MessageBox(game.getStrByKey("create_no_more"))                          
            else
				removeNetLoading()
				cclog("create role failed!")
			end
			self.isSend = false
        end,
        [LOGIN_SC_RANDNAME] = function()
        	local retTable = g_msgHandlerInst:convertBufferToTable("LoginRandNameRet", luaBuffer)
        	local nickName = retTable.name
        	cclog("got name:"..nickName) 
        	self.random_id = retTable.worldID
        	self.random_names[self.currSex] = nickName
			self.nickNameCtrl:setText(nickName)
			self:updateNameCtrlPos()
        end,
    }
    if switch[msgid] then 
        switch[msgid]()
    end
end

return CreateRoleScene