local StoryExNode = class("StoryExNode", function() return cc.Node:create() end)

local path = "res/story/"

function StoryExNode:ctor()
    self.state = 0
    self.name = require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME)
    dump(self.name)
    local listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
            print("touch end")
        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end

function StoryExNode:updateState()
    log("StoryExNode:updateState state = "..self.state)
    --self:stopAllActions()

    self.state = self.state + 1

    local switch = {
        function() 
            startTimerAction(self, 2, false, function() 
                self.name = require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME)
                dump(self.name)
                self:addTalk(51, nil, nil, nil, self.name) 
                end)
        end
        ,

        function() 
            self:addTalk(52, nil, nil, nil, self.name) 
            AudioEnginer.playLiuEffect("sounds/liuVoice/1.mp3", false)
        end
        ,

        function() 
            self:addTalk(53, nil, nil, nil, self.name) 
        end
        ,

        function() 
            self:addTalk(54) 
             AudioEnginer.playLiuEffect("sounds/liuVoice/3.mp3", false)
        end
        ,

        function() 
            self:addTalk(55, nil, nil, nil, self.name) 
        end
        ,

        function() 
            self:addTalk(56) 
             AudioEnginer.playLiuEffect("sounds/liuVoice/4.mp3", false)
        end
        ,

        function() 
            self:addTalk(57, nil, nil, nil, self.name) 
        end
        ,

        function() 
            self:endStroy()
        end
        ,
    }

    if switch[self.state] then 
        switch[self.state]()
    end
end

function StoryExNode:endStroy()
    initShortForChat()
    setLocalRecord("storyExTuto", true)
    G_MAINSCENE:exitStoryExMode()
end

function StoryExNode:addTalk(id, delay, delayDestory, text, name)
    if self.talkNode then
        removeFromParent(self.talkNode)
        self.talkNode = nil
    end

    local record = getConfigItemByKey("storyTalk", "q_id", id)
    dump(record)

    self.talkNode = cc.Node:create()
    self:addChild(self.talkNode)

    local function createTalk(delayDestory)
        local sex = require("src/layers/role/RoleStruct"):getAttr(PLAYER_SEX)
        local school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
        dump(delayDestory)
        local bg = createSprite(self.talkNode, path.."bg.png", cc.p(display.cx, 0), cc.p(0.5, 0))
        bg:setOpacity(0)
        bg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))
        if record.q_role == 0 then
            createSprite(bg, "res/mainui/npc_big_head/"..record.q_role..".png", cc.p(bg:getContentSize().width/2-display.width/2, bg:getContentSize().height), cc.p(0, 0))
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
            createLabel(bg, game.getStrByKey("story_talk_tip"), cc.p(bg:getContentSize().width/2+display.width/2-120, 30), cc.p(1, 0.5), 22, true, nil, nil, MColor.white)
            local arrow = createSprite(bg, "res/group/arrows/13.png", cc.p(bg:getContentSize().width/2+display.width/2-110, 30), cc.p(0, 0.5), nil, 0.6)
            arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(bg:getContentSize().width/2+display.width/2-100, 30)), cc.MoveTo:create(0.3, cc.p(bg:getContentSize().width/2+display.width/2-110, 30)))))

            local  listenner = cc.EventListenerTouchOneByOne:create()
            listenner:setSwallowTouches(false)
            listenner:registerScriptHandler(function(touch, event)
                    return true
                end,cc.Handler.EVENT_TOUCH_BEGAN )
            listenner:registerScriptHandler(function(touch, event)
                    print("StoryNode:addTalk touch end")
                    AudioEnginer.playEffect("sounds/uiMusic/ui_click.mp3", false)
                    if self.talkNode then
                        removeFromParent(self.talkNode)
                        self.talkNode = nil
                    end
                    self:updateState()
                end,cc.Handler.EVENT_TOUCH_ENDED )
            local eventDispatcher = self:getEventDispatcher()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.talkNode)
        else
            startTimerAction(self, delayDestory, false, function() 
                    if self.talkNode then
                        removeFromParent(self.talkNode)
                        self.talkNode = nil
                    end
                    --self:updateState() 
                end)
        end
    end

    startTimerAction(self, delay or 0, false, function() createTalk(delayDestory) end)
end

return StoryExNode