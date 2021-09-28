local NewCreateRoleScene = class("NewCreateRoleScene", function() return cc.Scene:create() end)

function NewCreateRoleScene:ctor()
    self.m_bg = nil;

    __G_ON_CREATE_ROLE = true;

    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 240), g_scrSize.width, g_scrSize.height);
    self:addChild(layerColor);

    self.m_bg = cc.Node:create();
    self.m_bg:setContentSize(cc.size(1050,640));
    self.m_bg:setPosition(cc.p((g_scrSize.width-1050)/2,(g_scrSize.height-640)/2));
    self:addChild(self.m_bg);

    self.m_picNode = cc.Node:create();
    self.m_picNode:setContentSize(cc.size(1050,640));
    self.m_bg:addChild(self.m_picNode);

    local centerBg = createSprite( self.m_picNode , "res/createRole/bg1.jpg", cc.p(1050/2, 640/2), cc.p(0.5, 0.5))
    local c_size = centerBg:getContentSize();

    --function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
    local upSpr = createSprite(self.m_picNode, "res/createRole/up.png", cc.p(1050/2, 640-17), cc.p(0.5, 0));
    local downSpr = createSprite(self.m_picNode, "res/createRole/down.png", cc.p(1050/2, 0), cc.p(0.5, 0));
    
    local roleInfo = {
        {profession = 1, sex = 1, x = 415, y = 310, interval = 110, touchRect = cc.rect(295, 96, 200, 331)},
        {profession = 1, sex = 2, x = 700, y = 495, interval = 118, touchRect = cc.rect(512, 391, 172, 215)},
        {profession = 2, sex = 1, x = 200, y = 240, interval = 115, touchRect = cc.rect(0, 72, 185, 345)},
        {profession = 2, sex = 2, x = 920, y = 210, interval = 105, touchRect = cc.rect(748, 60, 208, 313)},
        {profession = 3, sex = 1, x = 330, y = 367, interval = 108, touchRect = cc.rect(185, 249, 109, 262)},
        {profession = 3, sex = 2, x = 780, y = 335, interval = 112, touchRect = cc.rect(595, 195, 155, 214)},
    }
    
    for i=1, #roleInfo do
        local eff = Effects:create(false);
        local effPath = "role_" .. roleInfo[i].profession .. "_" .. roleInfo[i].sex;
        eff:playActionData2(effPath, roleInfo[i].interval, -1, 0);
        centerBg:addChild(eff);
        eff:setPosition(cc.p(roleInfo[i].x, roleInfo[i].y));
    end

    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event)
            return true;
        end, cc.Handler.EVENT_TOUCH_BEGAN);
    listener:registerScriptHandler(function(touch, event)
            if touch and event and centerBg then
                -- ¸¸½Úµã×ª»»
                local pt = self.m_bg:convertTouchToNodeSpace(touch);
                for i, v in pairs(roleInfo) do
                    if cc.rectContainsPoint(v.touchRect, pt) then
                        game.goToScenes("src/login/NewCreateRoleFirstScene", {v.profession, v.sex});
                        return true;
                    end
                end
            end

            return false;
        end, cc.Handler.EVENT_TOUCH_ENDED);
    local eventDispatcher = centerBg:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, centerBg);
    
    local backBtn = createMenuItem(downSpr, "res/createRole/back1.png", cc.p(210, 40), function()
        AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false);

        if g_roleTable and #g_roleTable > 0 then
            game.goToScenes("src/login/NewCreateRoleEndScene");
        else
            g_msgHandlerInst:sendNetDataByTableExEx(LOGIN_CG_EXIT_LOGIN, "LoginClientExitLoginReq", {});
		    globalInit();
		    game.ToLoginScene();
        end
	end)

    createLabel(downSpr, game.getStrByKey("newCreateWelcome"), cc.p(downSpr:getContentSize().width/2, 28), cc.p(0.5, 0), 20, true, nil, nil, cc.c3b(238, 198, 146));

    createSprite(downSpr, "res/createRole/start_gray.png", cc.p(1050-246 + 40 + (g_scrSize.width-1050)/2, 10), cc.p(0, 0));
     
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

return NewCreateRoleScene;