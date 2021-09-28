local DragonStory = class("DragonStory", function() return cc.Node:create() end)

function DragonStory:ctor(dragonCfg)
    self.m_talkNode = nil;
    self.m_dragonCfg = dragonCfg; -- 配置表
    self.m_state = 0;
    self.m_startId = 0;
    self.m_endId = 0;
    self.m_switch = {}; -- 自定义操作表
    self.m_name = require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME);
    
    if self.m_dragonCfg ~= nil then
        self.m_startId = self.m_dragonCfg.q_id_start;
        self.m_endId = self.m_dragonCfg.q_id_end;
        
        for i=self.m_startId, self.m_endId do
            local storyCfg = getConfigItemByKeys("dragonTalk", {"q_plot", "q_id"}, {self.m_dragonCfg.q_plot, i});
            if storyCfg ~= nil then
                local isNeedName = storyCfg.q_needName;
                table.insert(self.m_switch, function()
                    self:AddTalk(i, nil, nil, nil, isNeedName==1 and self.m_name);
                end);
            end
        end
    end

    local listenner = cc.EventListenerTouchOneByOne:create();
    listenner:setSwallowTouches(true);
    listenner:registerScriptHandler(function(touch, event)
            return true;
        end, cc.Handler.EVENT_TOUCH_BEGAN);
    listenner:registerScriptHandler(function(touch, event)
            print("touch end");
        end, cc.Handler.EVENT_TOUCH_ENDED);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self);
end

function DragonStory:UpdateState()
    self.m_state = self.m_state + 1
    if self.m_state <= (self.m_endId - self.m_startId + 1) then
        if #self.m_switch > 0 then
            self.m_switch[self.m_state]();
        end
    else
        self:EndStory();
    end
end

function DragonStory:AddTalk(id, delay, delayDestory, text, name)
    if self.m_dragonCfg == nil then
        return;
    end

    if self.m_talkNode ~= nil then
        removeFromParent(self.m_talkNode);
        self.m_talkNode = nil;
    end
    
    local record = getConfigItemByKeys("dragonTalk", {"q_plot", "q_id"}, {self.m_dragonCfg.q_plot, id});

    self.m_talkNode = cc.Node:create();
    self:addChild(self.m_talkNode);

    local function createTalk(delayDestory)
        local path = "res/story/";

        -- 性别、职业
        local sex = require("src/layers/role/RoleStruct"):getAttr(PLAYER_SEX)
        local school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
        
        local bg = createSprite(self.m_talkNode, path .. "bg.png", cc.p(display.cx, 0), cc.p(0.5, 0))
        bg:setOpacity(0)
        bg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))
        if record.q_role > 0 then
            local npcData = getConfigItemByKey("NPC", "q_id"  )[record.q_role];
            if npcData ~= nil and npcData["q_boby"] then  --npc半身像
                createSprite(bg, "res/mainui/npc_big_head/" .. npcData["q_boby"] .. ".png", cc.p(bg:getContentSize().width/2-display.width/2, bg:getContentSize().height), cc.p(0, 0))
            end
        else
            createSprite(bg, "res/mainui/npc_big_head/"..(sex-1)*3+school..".png", cc.p(bg:getContentSize().width/2+display.width/2+15, bg:getContentSize().height), cc.p(1, 0))
        end

        local richText = require("src/RichText").new(bg, cc.p(bg:getContentSize().width/2-(display.width-200)/2, 140), cc.size(display.width-200, 30), cc.p(0, 1), 30, 24, MColor.lable_yellow)
        if text then
            richText:addText(text)
        else
            if name then
                richText:addText(string.format(record.q_text, name))
            else
                richText:addText(record.q_text)
            end
        end
        richText:format()

        if not delayDestory then
            createLabel(bg, record.q_btn_text, cc.p(bg:getContentSize().width/2+display.width/2-120, 30), cc.p(1, 0.5), 22, true, nil, nil, MColor.white)
            local arrow = createSprite(bg, "res/group/arrows/13.png", cc.p(bg:getContentSize().width/2+display.width/2-110, 30), cc.p(0, 0.5), nil, 0.6)
            arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(bg:getContentSize().width/2+display.width/2-100, 30)), cc.MoveTo:create(0.3, cc.p(bg:getContentSize().width/2+display.width/2-110, 30)))))

            local  listenner = cc.EventListenerTouchOneByOne:create()
            listenner:setSwallowTouches(false)
            listenner:registerScriptHandler(function(touch, event)
                    return true
                end,cc.Handler.EVENT_TOUCH_BEGAN )
            listenner:registerScriptHandler(function(touch, event)
                    print("StoryNode:addTalk touch end")
                    if self.m_talkNode then
                        removeFromParent(self.m_talkNode)
                        self.m_talkNode = nil
                    end
                    self:UpdateState()
                end,cc.Handler.EVENT_TOUCH_ENDED )
            local eventDispatcher = self:getEventDispatcher()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.m_talkNode)
        else
            startTimerAction(self, delayDestory, false, function() 
                    if self.m_talkNode then
                        removeFromParent(self.m_talkNode)
                        self.m_talkNode = nil
                    end
                end)
        end
    end

    startTimerAction(self, delay or 0, false, function() createTalk(delayDestory) end)
end

function DragonStory:EndStory()
    G_MAINSCENE:ExitDragonStoryMode(self.m_dragonCfg);
end

return DragonStory;