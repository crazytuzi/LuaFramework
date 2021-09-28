local NewCreateRoleEndScene = class("NewCreateRoleFirstScene", function() return cc.Scene:create() end)

function NewCreateRoleEndScene:ctor(roleID)
    self.m_roleID = 0;

    self.m_bg = nil;
    self.m_leftNode = nil;
    self.m_rightNode = nil;
    self.m_centerBg = nil;

    self.m_standEff = nil;

    -- 正在播放
    self.m_isPlaying = false;

    self.m_roleBtns = {};

    ------------------------------------待机动作配置-----------------------------------------------------------------
    self.m_roleInfo = {
        {profession = 1, sex = 1, x = 505, y = 340, interval = 120, touchRect = cc.rect(324, 98, 323, 399)},
        {profession = 1, sex = 2, x = 500, y = 320, interval = 120, touchRect = cc.rect(370, 117, 241, 370)},
        {profession = 2, sex = 1, x = 500, y = 330, interval = 120, touchRect = cc.rect(365, 116, 293, 374)},
        {profession = 2, sex = 2, x = 500, y = 310, interval = 120, touchRect = cc.rect(335, 109, 300, 335)},
        {profession = 3, sex = 1, x = 500, y = 320, interval = 120, touchRect = cc.rect(360, 100, 286, 358)},
        {profession = 3, sex = 2, x = 500, y = 340, interval = 120, touchRect = cc.rect(365, 108, 250, 403)},
    }

    ------------------------------------展示动作配置-----------------------------------------------------------------
    self.m_roleShowInfo = {
        {profession = 1, sex = 1, x = 490, y = 340, interval = 80, plist = 2},
        {profession = 1, sex = 2, x = 500, y = 320, interval = 90, plist = 2},
        {profession = 2, sex = 1, x = 500, y = 330, interval = 100, plist = 2},
        {profession = 2, sex = 2, x = 500, y = 310, interval = 100, plist = 2},
        {profession = 3, sex = 1, x = 500, y = 320, interval = 100, plist = 1},
        {profession = 3, sex = 2, x = 500, y = 340, interval = 100, plist = 1},
    }

    __G_ON_CREATE_ROLE = true;

    local msgids = {LOGIN_SC_DELETE_PLAYER}
    require("src/MsgHandler").new(self,msgids)

    ------------------------------------roleid矫正-----------------------------------------------------------------
    if roleID == nil then
        local isFind = false;
        local lastRoleID = getLocalRecordByKey(1, "lastRoleID");
        if lastRoleID ~= nil then
            if g_roleTable and #g_roleTable > 0 then
                for i = 1, #g_roleTable do
                    if g_roleTable[i].RoleID == lastRoleID then
                        isFind = true;
                        break;
                    end
                end
            end
        end
        
        if isFind then
            self.m_roleID = lastRoleID;
        else
            if g_roleTable and #g_roleTable > 0 then
                self.m_roleID = g_roleTable[1].RoleID;
            else
                self.m_roleID = 0;
            end
        end
    else
        -- 确认是否双开或者多开客户端[能小退，肯定有一个角色]
        if g_roleTable and #g_roleTable > 0 then
            local isRoleExit = false;
            for i=1, #g_roleTable do
                if g_roleTable[i].RoleID == roleID then
                    isRoleExit = true;
                    break;
                end
            end

            if isRoleExit then
                self.m_roleID = roleID;
            else
                self.m_roleID = g_roleTable[1].RoleID;
            end
        else
            TIPS{ type = 1, str = game.getStrByKey("login_dataError") };
            self.m_roleID = 0;
        end
    end

    ------------------------------------防止分辨率过大的黑底-----------------------------------------------------------------
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 240), g_scrSize.width, g_scrSize.height);
    self:addChild(layerColor);

    self.m_bg = cc.Node:create();
    self.m_bg:setContentSize(cc.size(1050,640));
    self.m_bg:setPosition(cc.p((g_scrSize.width-1050)/2,(g_scrSize.height-640)/2));
    self:addChild(self.m_bg);
    
    print("g_scrSize.width=[" .. g_scrSize.width .. "] g_scrSize.height=[" .. g_scrSize.height .. "]");

    self.m_centerBg = createSprite( self.m_bg , "res/createRole/bg1.jpg", cc.p(1050/2, 640/2), cc.p(0.5, 0.5))
    local c_size = self.m_centerBg:getContentSize();

    ------ 暗遮罩
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

    ------------------------------------脚部光环-----------------------------------------------------------------
    local lightEff = Effects:create(false);
    lightEff:playActionData2("firstCharge", 120, -1, 0);
    self.m_frontLayerColor:addChild(lightEff);
    lightEff:setPosition(cc.p(510, 300));
    lightEff:setScale(1.2)

    ------------------------------------------------------------------------------------------------

    self.m_professionInfoSpan = createSprite(self.m_frontLayerColor, "res/createRole/detail.png", cc.p(g_scrSize.width*5/6, 380));

    --function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
    local upSpr = createSprite(self.m_bg, "res/createRole/up.png", cc.p(1050/2, 640-17), cc.p(0.5, 0));

    -----------------------------------------------------------------------------------------------------
    local curSelRoleData = nil;
    self.role_tab = {};
    for i=1, 3 do
        if g_roleTable and g_roleTable[i] then
            self.role_tab[i] = {};
            self.role_tab[i].roleID = g_roleTable[i].RoleID;
            self.role_tab[i].Sex = g_roleTable[i].Sex;
            self.role_tab[i].School = g_roleTable[i].School;
            self.role_tab[i].Name = g_roleTable[i].Name;
            self.role_tab[i].Level = g_roleTable[i].Level;

            if self.m_roleID == self.role_tab[i].roleID then
                curSelRoleData = self.role_tab[i];
            end
        else
            self.role_tab[i] = {};
            self.role_tab[i].roleID = 0;
        end
    end

    -- 左边
    local btnY = 0;
    for i = 1, #self.role_tab do
        btnY = 520 - (i-1)*150;
        
        local tmpRoleBtn = self:CreateSingleRoleBtn(self.role_tab[i]);
        if tmpRoleBtn then
            tmpRoleBtn:setPosition(cc.p(60, btnY));
            self.m_roleBtns[i] = tmpRoleBtn;
        end
    end

    local backBtn = createMenuItem(downSpr, "res/createRole/back1.png", cc.p(210, 40), function()
        AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false);

        g_msgHandlerInst:sendNetDataByTableExEx(LOGIN_CG_EXIT_LOGIN, "LoginClientExitLoginReq", {});
		globalInit();
		game.ToLoginScene();
	end)

    self.m_editBg = createSprite(downSpr, "res/createRole/nameBg1.png", cc.p(downSpr:getContentSize().width/2, 10), cc.p(0.5, 0));
    local editBgSize = self.m_editBg:getContentSize();

    self.m_selRoleLal = createLabel(self.m_editBg, "", cc.p(editBgSize.width/2-20, editBgSize.height/2), cc.p(0.5, 0.5), 20, true, nil, nil, cc.c3b(238, 198, 146));

    local deleteFunc = function()
            AudioEngine.playEffect("sounds/liuVoice/68.mp3", false)

		    local yesCallback = function()
			    local yesCallback1 = function()
				    local t = {}
				    t.userID = userInfo.userId
				    t.roleID = self.m_roleID;
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
    self.m_selRoledeleteBtn = createTouchItem(self.m_editBg, "res/createRole/delete1.png", cc.p(self.m_editBg:getContentSize().width-54, 27), deleteFunc);

    local startBtn = createMenuItem(downSpr, "res/createRole/start.png", cc.p(1050-246 + 150 + (g_scrSize.width-1050)/2, 40), function()
        __G_ON_CREATE_ROLE = nil;

		if self.m_roleID > 0 then
			AudioEnginer.playEffect("sounds/uiMusic/ui_enter.mp3", false);

			game.goToScenes("src/login/OpenDoor", self.m_roleID);
			setLocalRecordByKey(1, "lastRoleID", self.m_roleID);
        else
            game.goToScenes("src/login/NewCreateRoleScene");
	    end
	end)

    -- 根据数据更新当前选中的待机动作
    if curSelRoleData then
        self:UpdateStandEff(curSelRoleData);
    end

    -- 响应点击事件
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
                for i, v in pairs(self.m_roleInfo) do
                    if cc.rectContainsPoint(v.touchRect, pt) then
                        if not self.m_isPlaying and self.m_standEff then
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

    if not AudioEnginer.isBackgroundMusicPlaying() then
		AudioEnginer.playMusic("sounds/login.mp3",true)
	end
end

------------------------------------ 播放一次展示动作 -----------------------------------------------------------------
function NewCreateRoleEndScene:CreateShowEffect()
    local curSelRoleData = nil;
    if g_roleTable then
        for i = 1, #g_roleTable do
            if g_roleTable[i] and self.m_roleID == g_roleTable[i].RoleID then
                curSelRoleData = g_roleTable[i];
                break;
            end
        end
    end

    if curSelRoleData == nil then
        return;
    end

    local showEffX = 0;
    local showEffY = 0;
    local showInterval = 0;
    local plist = 1;
    for i, v in pairs(self.m_roleShowInfo) do
        if(curSelRoleData.School == v.profession and curSelRoleData.Sex == v.sex) then
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
    local showEffPath = "crshow" .. nameStrs[curSelRoleData.School] .. curSelRoleData.Sex;

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

------------------------------------更换待机动作-----------------------------------------------------------------
function NewCreateRoleEndScene:UpdateStandEff(roleTab)    
    if roleTab == nil then
        return;
    end
    
    if self.m_rightNode then
        self.m_standEff = nil;
        self.m_rightNode:removeFromParent();
        self.m_rightNode = nil;
    end

    self.m_rightNode = self:CreateRoleByData(roleTab);

    self.m_selRoleLal:setString("Lv." .. roleTab.Level .. " " .. roleTab.Name);

    for i=1, #self.m_roleBtns do
        if self.m_roleBtns[i] then
            local tag = self.m_roleBtns[i]:getTag();
            if tag > 0 then
                local showSpr = self.m_roleBtns[i]:getChildByTag(1);
                local arrowSpr = self.m_roleBtns[i]:getChildByTag(2);
                if showSpr and arrowSpr then
                    if tag == self.m_roleID then
                        showSpr:setVisible(true);
                        arrowSpr:setVisible(true);
                    else
                        showSpr:setVisible(false);
                        arrowSpr:setVisible(false);
                    end
                end
            end
        end
    end

    -------------------------------------技能描述文字-----------------------------------------------------------
	self.m_professionInfoSpan:removeAllChildren();
    local professionInfoSize = self.m_professionInfoSpan:getContentSize();
    local professionInfoSpr = createSprite(self.m_professionInfoSpan, "res/createRole/detail_" .. roleTab.School .. ".png", cc.p(professionInfoSize.width/2, 310), cc.p(0.5, 0));

    local sch_str = {"zhanshi","fashi","daoshi"};
    local professionLal = createLabel(self.m_professionInfoSpan, game.getStrByKey(sch_str[roleTab.School]), cc.p(professionInfoSize.width/2,280), cc.p(0.5, 0), 26, true, nil, nil, cc.c3b(238, 198, 146));

    local sch_desc_strs = {
        "createZSDesc",
        "createFSDesc",
        "createDSDesc"
        };
    -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
    local richText = require("src/RichText").new( self.m_professionInfoSpan , cc.p( professionInfoSize.width/2, 110) , cc.size( 230 , 400 ) , cc.p( 0.5 , 0 ) , 40 , 20 , MColor.lable_yellow, nil, nil, false);
    richText:setAutoWidth();
    richText:addText(game.getStrByKey(sch_desc_strs[roleTab.School]));
	richText:format();

    ------------------------------------------------------------------------------------------------
end

------------------------------------左边的点击按钮-----------------------------------------------------------------
function NewCreateRoleEndScene:CreateSingleRoleBtn(roleTab)
    local bgNode = nil;

    local roleTouchFun = function()
        if roleTab then
            if roleTab.roleID == 0 then
                game.goToScenes("src/login/NewCreateRoleScene");
            else
                -- 正在播放展示动作不允许切换
                if roleTab.roleID ~= self.m_roleID and not self.m_isPlaying then
                    self.m_roleID = roleTab.roleID;
                    self:UpdateStandEff(roleTab);
                end
            end
        end
    end

    -- 无角色
    if roleTab.roleID == 0 then
        bgNode = createTouchItem(self.m_frontLayerColor, "res/createRole/head_bg.png", cc.p(0, 0), roleTouchFun);
        bgNode:setTag(0);
    else
        bgNode = createTouchItem(self.m_frontLayerColor, "res/createRole/head_bg.png", cc.p(0, 0), roleTouchFun);
        local bgNodeSize = bgNode:getContentSize();
        bgNode:setTag(roleTab.roleID);

        local showBgNode = createSprite(bgNode, "res/createRole/head_bg_sel.png", cc.p(bgNodeSize.width/2, bgNodeSize.height/2), cc.p(0.5, 0.5));
        showBgNode:setTag(1);
        showBgNode:setVisible(false);

        --function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
        local arrow = createSprite(bgNode, "res/group/arrows/9.png", cc.p(bgNodeSize.width, bgNodeSize.height/2), cc.p(0, 0.5))
        arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(bgNodeSize.width-5, bgNodeSize.height/2)), cc.MoveTo:create(0.3, cc.p(bgNodeSize.width, bgNodeSize.height/2)))))
		arrow:setTag(2)
        arrow:setVisible(false);

        local head_path = "res/mainui/head/"..(roleTab.School+(roleTab.Sex-1)*3)..".png";
        local sprite = createSprite(bgNode, head_path, cc.p(58, 70));

        createLabel(bgNode, "Lv." .. roleTab.Level, cc.p(bgNodeSize.width/2, 5), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_yellow);    
    end

    return bgNode;
end

function NewCreateRoleEndScene:CreateRoleByData(roleTab)
    local bgNode = cc.Node:create();
    self.m_frontLayerColor:addChild(bgNode);

    local tmpPlist = 1;
    local effX = 0;
    local effY = 0;
    local interval = 0;
    for i, v in pairs(self.m_roleInfo) do
        if(roleTab.School == v.profession and roleTab.Sex == v.sex) then
            effX = v.x;
            effY = v.y;
            interval = v.interval;

            -- stand、 show 动作数目一致都为6个
            if self.m_roleShowInfo[i] then
                tmpPlist = self.m_roleShowInfo[i].plist;
            end
            break;
        end
    end

    self.m_standEff = Effects:create(false);
    ----------------------------------------------------------------------------------
    -- 预加载一下
    local tmpNameStrs = {"zs", "fs", "ds"};
    local tmpShowEffPath = "crshow" .. tmpNameStrs[roleTab.School] .. roleTab.Sex;
    self.m_standEff:setPlistNum(tmpPlist);
    self.m_standEff:playActionData2(tmpShowEffPath, 120, 1, 0);
    ----------------------------------------------------------------------------------
    local tmpNameStrs = {"zs", "fs", "ds"};
    local effPath = "crstand" .. tmpNameStrs[roleTab.School] .. roleTab.Sex;
    self.m_standEff:setPlistNum(1);
    self.m_standEff:playActionData2(effPath, interval, -1, 0);
    bgNode:addChild(self.m_standEff);
    self.m_standEff:setPosition(cc.p(effX, effY));

    return bgNode;
end

function NewCreateRoleEndScene:networkHander(luaBuffer,msgid)    --删除角色成功服务器返回
    local switch = {
        [LOGIN_SC_DELETE_PLAYER] = function()
        	local t = g_msgHandlerInst:convertBufferToTable("LoginDeletePlayerRet", luaBuffer) 
        	local id = t.roleID
        	local flg = t.result
        	if flg == 0 then
	        	setLocalRecordByKey( 2 , "activityPopKey" .. tostring(id) , "" )  	--清除角色活动弹出键值
	        	for k,v in pairs(g_roleTable)do
					if v["RoleID"] == id then
						table.remove(g_roleTable,k);
						if g_roleTable and #g_roleTable > 0 then              --删除后是否还存留角色
							Director:replaceScene(require("src/login/NewCreateRoleEndScene").new())
						else
							game.goToScenes("src/login/NewCreateRoleScene");
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

return NewCreateRoleEndScene;