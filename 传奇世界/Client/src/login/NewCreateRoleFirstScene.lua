local NewCreateRoleFirstScene = class("NewCreateRoleFirstScene", function() return cc.Scene:create() end)

require "src/utf8"

function NewCreateRoleFirstScene:ctor(params)
    self.m_bg = nil;
    self.m_editBg = nil;
    self.m_nickNameCtrl = nil;
    self.m_standEff = nil;
    self.m_centerBg = nil;

    self.m_profession = 0;
    self.m_sex = 0;
    self.m_inputName = nil;
    self.isSend = false;
    -- 正在播放
    self.m_isPlaying = false;

    __G_ON_CREATE_ROLE = true;

    if params == nil or type(table) ~= "table" then
        self.m_profession = math.floor( math.random (1000,3999)/1000);
        self.m_sex = math.floor( math.random (1000,2999)/1000);
    else
        self.m_profession = params[1];
        self.m_sex = params[2];
    end

    local msgids = {LOGIN_SC_CREATEPLAYER,LOGIN_SC_RANDNAME}
    require("src/MsgHandler").new(self,msgids);

    self.m_server =  getLocalRecordByKey(1,"lastServer",-1);
    if self.m_server == -1 then
		cclog("self.server got -1, default to 0")
		self.m_server = 0;
	end

    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 240), g_scrSize.width, g_scrSize.height);
    self:addChild(layerColor);

    self.m_bg = cc.Node:create();
    self.m_bg:setContentSize(cc.size(1050,640));
    self.m_bg:setPosition(cc.p((g_scrSize.width-1050)/2,(g_scrSize.height-640)/2));
    self:addChild(self.m_bg);

    self.m_centerBg = createSprite( self.m_bg , "res/createRole/bg1.jpg", cc.p(1050/2, 640/2), cc.p(0.5, 0.5))
    local c_size = self.m_centerBg:getContentSize();

    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 120), g_scrSize.width, g_scrSize.height);
    layerColor:setContentSize(cc.size(g_scrSize.width,g_scrSize.height));
    layerColor:setPosition(cc.p(1050/2-g_scrSize.width/2, 640/2-g_scrSize.height/2));
    self.m_bg:addChild(layerColor);

    --function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
    local downSpr = createSprite(self.m_bg, "res/createRole/down.png", cc.p(1050/2, 0), cc.p(0.5, 0));

    self.m_frontLayerColor = cc.Node:create();
    self.m_frontLayerColor:setContentSize(cc.size(g_scrSize.width,g_scrSize.height));
    self.m_frontLayerColor:setPosition(cc.p(1050/2-g_scrSize.width/2, 640/2-g_scrSize.height/2));
    self.m_bg:addChild(self.m_frontLayerColor);

    local lightEff = Effects:create(false);
    lightEff:playActionData2("firstCharge", 120, -1, 0);
    self.m_frontLayerColor:addChild(lightEff);
    lightEff:setPosition(cc.p(510, 300));
    lightEff:setScale(1.2)

    local upSpr = createSprite(self.m_bg, "res/createRole/up.png", cc.p(1050/2, 640-17), cc.p(0.5, 0));
    
    ------------------------------------------------------------------------------------------------
    local roleInfo = {
        {profession = 1, sex = 1, x = 505, y = 340, interval = 120, touchRect = cc.rect(324, 98, 323, 399)},
        {profession = 1, sex = 2, x = 500, y = 320, interval = 120, touchRect = cc.rect(370, 117, 241, 370)},
        {profession = 2, sex = 1, x = 500, y = 330, interval = 120, touchRect = cc.rect(365, 116, 293, 374)},
        {profession = 2, sex = 2, x = 500, y = 310, interval = 120, touchRect = cc.rect(335, 109, 300, 335)},
        {profession = 3, sex = 1, x = 500, y = 320, interval = 120, touchRect = cc.rect(360, 100, 286, 358)},
        {profession = 3, sex = 2, x = 500, y = 340, interval = 120, touchRect = cc.rect(365, 108, 250, 403)},
    }

    local effX = 0;
    local effY = 0;
    local interval = 0;
    for i, v in pairs(roleInfo) do
        if(self.m_profession == v.profession and self.m_sex == v.sex) then
            effX = v.x;
            effY = v.y;
            interval = v.interval;
            break;
        end
    end

    local skillShowSpr = createSprite(self.m_frontLayerColor, "res/createRole/skill_show.png", cc.p(g_scrSize.width/5-65, 360));
    
    
    local tmpPlistNums = {
        {profession = 1, sex = 1, plist = 2},
        {profession = 1, sex = 2, plist = 2},
        {profession = 2, sex = 1, plist = 2},
        {profession = 2, sex = 2, plist = 2},
        {profession = 3, sex = 1, plist = 1},
        {profession = 3, sex = 2, plist = 1},
    }
    
    local tmpPlist = 1;
    for i=1, #tmpPlistNums do
        if self.m_profession == tmpPlistNums[i].profession and self.m_sex == tmpPlistNums[i].sex then
            tmpPlist = tmpPlistNums[i].plist;
            break;
        end
    end

    
    self.m_standEff = Effects:create(false);
    ----------------------------------------------------------------------------------
    -- 预加载一下
    local tmpNameStrs = {"zs", "fs", "ds"};
    local tmpShowEffPath = "crshow" .. tmpNameStrs[self.m_profession] .. self.m_sex;
    self.m_standEff:setPlistNum(tmpPlist);
    self.m_standEff:playActionData2(tmpShowEffPath, 120, 1, 0);
    ----------------------------------------------------------------------------------
    local effPath = "crstand" .. tmpNameStrs[self.m_profession] .. self.m_sex;
    self.m_standEff:setPlistNum(1);
    self.m_standEff:playActionData2(effPath, interval, -1, 0);
    self.m_frontLayerColor:addChild(self.m_standEff);
    self.m_standEff:setPosition(cc.p(effX, effY));
    
    ------------------------------------------------------------------------------------------------

    ------------------------------------------------------------------------------------------------
    local listener = cc.EventListenerTouchOneByOne:create();
    --listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event)
            return true;
        end, cc.Handler.EVENT_TOUCH_BEGAN);
    listener:registerScriptHandler(function(touch, event)
            if touch and event and self.m_frontLayerColor then
                -- 父节点转换
                local pt = self.m_bg:convertTouchToNodeSpace(touch);
                for i, v in pairs(roleInfo) do
                    if cc.rectContainsPoint(v.touchRect, pt) then
                        if not self.m_isPlaying then
                            self.m_standEff:setVisible(false);
                            self:CreateShowEffect();
                            self.m_isPlaying = true;
                        end
                        return true;
                    end
                end
            end

            return false;
        end, cc.Handler.EVENT_TOUCH_ENDED);
    local eventDispatcher = self.m_frontLayerColor:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_frontLayerColor);
    ------------------------------------------------------------------------------------------------

    local professionInfoSpan = createSprite(self.m_frontLayerColor, "res/createRole/detail.png", cc.p(g_scrSize.width*4/5+65, 380));
    local professionInfoSize = professionInfoSpan:getContentSize();
    local professionInfoSpr = createSprite(professionInfoSpan, "res/createRole/detail_" .. self.m_profession .. ".png", cc.p(professionInfoSize.width/2, 310), cc.p(0.5, 0));

    local sch_str = {"zhanshi","fashi","daoshi"};
    local professionLal = createLabel(professionInfoSpan, game.getStrByKey(sch_str[self.m_profession]), cc.p(professionInfoSize.width/2,280), cc.p(0.5, 0), 26, true, nil, nil, cc.c3b(238, 198, 146));

    local sch_desc_strs = {
        "createZSDesc",
        "createFSDesc",
        "createDSDesc"
        };
    -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
    local richText = require("src/RichText").new( professionInfoSpan , cc.p( professionInfoSize.width/2, 110) , cc.size( 230 , 400 ) , cc.p( 0.5 , 0 ) , 40 , 20 , MColor.lable_yellow, nil, nil, false);
    richText:setAutoWidth();
    richText:addText(game.getStrByKey(sch_desc_strs[self.m_profession]));
	richText:format();
 
	self.m_editBg = createSprite(downSpr, "res/createRole/nameBg1.png", cc.p(downSpr:getContentSize().width/2, 10), cc.p(0.5, 0));
    local editBgSize = self.m_editBg:getContentSize();

	local function editBoxTextEventHandle(strEventName,pSender)
	 	local edit = tolua.cast(pSender,"ccui.EditBox") 

        if strEventName == "began" then --编辑框开始编辑时调用
            --print("began")
        elseif strEventName == "ended" then --编辑框完成时调用
            --print("ended")
        elseif strEventName == "return" then --编辑框return时调用
        	print("return")
        	local str = edit:getText()
        	if str ~= "" then
        		self.inputName = str
        	end
        	self:updateNameCtrlPos()
        elseif strEventName == "changed" then --编辑框内容改变时调用
        	print("changed")
        	self:updateNameCtrlPos()
        end
	end

    local editBgSize = self.m_editBg:getContentSize();
	self.m_nickNameCtrl = createEditBox(self.m_editBg, nil, cc.p((editBgSize.width-176)/2-30, editBgSize.height/2), cc.size(176, 34), MColor.white, 24, game.getStrByKey("create_input_name"))
	self.m_nickNameCtrl:setAnchorPoint(cc.p(0, 0.5))
    self.m_nickNameCtrl:setText("")
    self.m_nickNameCtrl:setFontColor(MColor.lable_yellow);
    self.m_nickNameCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_nickNameCtrl:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    self.m_nickNameCtrl:registerScriptEditBoxHandler(editBoxTextEventHandle)
    self.m_nickNameCtrl:setMaxLength(12);
    
    ------------------------------------------------------------------------------------------------------
    local LoginScene = require("src/login/LoginScene")
    local tmpPlat = sdkGetPlatform();
    -- 微信/QQ登录
    if tmpPlat ~= 0 and LoginScene.myNickName then
        local nickName = LoginScene.myNickName;
        require("src/utf8");
        if string.utf8len(LoginScene.myNickName) > 6 then
            nickName = string.utf8sub(LoginScene.myNickName, 1, 6);
        end 
        
		self.m_nickNameCtrl:setText(nickName)
		self:updateNameCtrlPos();
    else
        self:generateNameBySex();
    end

    local diceBtn = createMenuItem(self.m_editBg , "res/createRole/dice.png", cc.p(editBgSize.width-60, editBgSize.height/2), function()
            self.m_inputName = nil;
            self:generateNameBySex();
        end)
    diceBtn:setScale(0.8);
    
    local backBtn = createMenuItem(downSpr, "res/createRole/back1.png", cc.p(210, 40), function()
        game.goToScenes("src/login/NewCreateRoleScene");
	end)

    local confirmBtn = createMenuItem(downSpr, "res/createRole/start.png", cc.p(1050-246 + 150 + (g_scrSize.width-1050)/2, 40), function()
        self:ReqCreateRole();
	end)
    
    local netSim = require("src/net/NetSimulation")
    if netSim.OpenBtn then
        local func = function( )
            self:removeChildByTag(107)
            local sub_node = require("src/net/NetSimulation").new()
            if sub_node then
                self:addChild(sub_node, 200, 107)
            end
        end 
        createTouchItem(self, "res/component/checkbox/2-1.png", cc.p(25, 28), func)
    end

end

function NewCreateRoleFirstScene:CreateShowEffect()
    local roleShowInfo = {
        {profession = 1, sex = 1, x = 490, y = 340, interval = 80, plist = 2},
        {profession = 1, sex = 2, x = 500, y = 320, interval = 90, plist = 2},
        {profession = 2, sex = 1, x = 500, y = 330, interval = 100, plist = 2},
        {profession = 2, sex = 2, x = 500, y = 310, interval = 100, plist = 2},
        {profession = 3, sex = 1, x = 500, y = 320, interval = 100, plist = 1},
        {profession = 3, sex = 2, x = 500, y = 340, interval = 100, plist = 1},
    }

    local showEffX = 0;
    local showEffY = 0;
    local showInterval = 0;
    local plist = 1;
    for i, v in pairs(roleShowInfo) do
        if(self.m_profession == v.profession and self.m_sex == v.sex) then
            showEffX = v.x;
            showEffY = v.y;
            showInterval = v.interval;
            plist = v.plist;
            maxnum = v.maxnum;
            time = v.time;
            break;
        end
    end

    local showEff = Effects:create(false);
    
    local nameStrs = {"zs", "fs", "ds"};
    local showEffPath = "crshow" .. nameStrs[self.m_profession] .. self.m_sex;

    showEff:setPlistNum(plist);
    local animation = showEff:createEffect2(showEffPath, showInterval, 0)
    animation:setLoops(1);
    local actions = {}
	actions[#actions+1] = cc.Show:create()
	actions[#actions+1] = cc.Animate:create(animation)
	actions[#actions+1] = cc.CallFunc:create(function()
        self.m_isPlaying = false;
        self.m_standEff:setVisible(true);

	    showEff = tolua.cast(showEff,"Effects")
	    if showEff then
		    removeFromParent(showEff)
		    showEff = nil;
		    end
	    end)
	showEff:runAction(cc.Sequence:create(actions))
    
    --showEff:playActionData2(showEffPath, showInterval, 1, 0);
    self.m_frontLayerColor:addChild(showEff);
    showEff:setPosition(cc.p(showEffX, showEffY));
end

function NewCreateRoleFirstScene:ReqCreateRole()
	AudioEnginer.playEffect("sounds/uiMusic/ui_enter.mp3", false)
	if self.isSend then
		return;
	end

	local txt = self.m_nickNameCtrl:getText()
    if self:checkNameRule(txt) == false then
		return
	end
	
	local t = {}
	t.userName = txt
	t.sex = self.m_sex
	t.userID = userInfo.userId
	t.worldID = userInfo.serverId
	t.school = self.m_profession;
	t.modelID = 1;
	t.worldName	= userInfo.serverName
	
	g_msgHandlerInst:sendNetDataByTableEx(LOGIN_CS_CREATEPLAYER, "LoginCreatePlayer", t)
    addNetLoading(LOGIN_CS_CREATEPLAYER, LOGIN_SC_CREATEPLAYER, false, 1, 2)
	
	self.isSend = true
	G_ONCREATE_GAME = true
	performWithDelay(self, function() self.isSend = false end ,2.0)
end

-- 1：不能以空格开头、也不能以空格结尾
-- 2：不能以传奇世界、传世、GM、gm、官方、活动XX、宣传XX、推广XX、
-- 3：取名不支持换行
function NewCreateRoleFirstScene:checkNameRule(name)
    if name == nil or type(name) ~= "string" or string.len(name) <=0 then
		TIPS({ type = 1 , str = game.getStrByKey("login_tip_empty_name") , isMustShow = true})
		return false;
	end

	if string.find(name, " ") or string.find(name, "\n") or string.find(name, "\r") or string.find(name, "%^") then
		TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
		return false;
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

	return true
end

function NewCreateRoleFirstScene:updateNameCtrlPos()
	local str = self.m_nickNameCtrl:getText();
	if str == "" then
		str = game.getStrByKey("create_input_name")
	end
	local label = createLabel(nil, str, cc.p(0, 0), cc.p(0, 0), 24)
	
	local x = self.m_editBg:getContentSize().width/2 - label:getContentSize().width/2
    if x < 70 then
        x = 70;
    end
    
	self.m_nickNameCtrl:setPosition(cc.p(x-30, self.m_editBg:getContentSize().height/2))
end

function NewCreateRoleFirstScene:generateNameBySex()
	g_msgHandlerInst:sendNetDataByTableEx(LOGIN_CS_RANDNAME, "LoginRandNameReq", {worldID = self.m_server, sex = self.m_sex} )
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

function NewCreateRoleFirstScene:networkHander(luaBuffer, msgid)
    local switch = {
        [LOGIN_SC_CREATEPLAYER] = function()
            local t = g_msgHandlerInst:convertBufferToTable("LoginCreatePlayerRet", luaBuffer) 
        	userInfo.userid = t.userID
			local roleID = t.roleID
            local ret = t.ret

			print("ret" .. ret)
			if ret == 0 then
                local roleparam = {}
                roleparam.RoleID = roleID;
                roleparam.Name = self.m_nickNameCtrl:getText();
                roleparam.Level = 1;
                roleparam.School = self.m_profession;
                roleparam.Sex = self.m_sex;
                table.insert(g_roleTable,roleparam)
                
                saveLoginHistory()

                -- 直接确定后进入游戏
                AudioEnginer.playEffect("sounds/uiMusic/ui_enter.mp3", false);

			    game.goToScenes("src/login/OpenDoor", roleID);
			    setLocalRecordByKey(1, "lastRoleID", roleID);
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
			self.isSend = false;
        end,
        [LOGIN_SC_RANDNAME] = function()
        	local retTable = g_msgHandlerInst:convertBufferToTable("LoginRandNameRet", luaBuffer)
        	local nickName = retTable.name
        	print("retTable.worldID" .. retTable.worldID);
			self.m_nickNameCtrl:setText(nickName)
			self:updateNameCtrlPos();
        end,
    }
    if switch[msgid] then 
        switch[msgid]()
    end
end

return NewCreateRoleFirstScene;