local EmpireDeadInfoNode = class("EmpireDeadInfoNode", function() return cc.Node:create() end)

local path = "res/empire/"

function EmpireDeadInfoNode:ctor(data)
	local bg = createSprite(self, "res/common/bg/bg36.png", cc.p(0, 0), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("empire_dead_info_title"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height - 20), cc.p(0.5, 1), 22, true)

    self.aliveTimeLeft = data.aliveTimeLeft or 10
    self.aliveCountDown = require("src/RichText").new(self.bg, cc.p(self.bg:getContentSize().width/2, 60), cc.size(340, 30), cc.p(0.5, 0.5), 24, 18, MColor.green)
    self.aliveCountDown:addText(string.format(game.getStrByKey("empire_dead_info_wait_time"), self.aliveTimeLeft))
    self.aliveCountDown:format()

    startTimerAction(self, 1, true, function() 
            self.aliveTimeLeft = self.aliveTimeLeft - 1
            if self.aliveTimeLeft <= 0 then
                removeFromParent(self)
            end
            removeFromParent(self.aliveCountDown)
            self.aliveCountDown = require("src/RichText").new(self.bg, cc.p(self.bg:getContentSize().width/2, 60), cc.size(340, 30), cc.p(0.5, 0.5), 24, 18, MColor.green)
            self.aliveCountDown:addText(string.format(game.getStrByKey("empire_dead_info_wait_time"), self.aliveTimeLeft))
            self.aliveCountDown:format()
        end)

	self:updateUI(data)
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
        return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)    
end

function EmpireDeadInfoNode:updateUI(data)
    local richText = require("src/RichText").new(self.bg, cc.p(self.bg:getContentSize().width/2, 230), cc.size(340, 30), cc.p(0.5, 1), 24, 18, MColor.red)
    if data.killerName and data.killerFactionName then        
        if data.killerName == "" then
            data.killerName = game.getStrByKey("monster")
        end
        if data.killerFactionName ~= "" then
            data.killerFactionName = string.format(game.getStrByKey("empire_dead_info_killerEmpire"), data.killerFactionName)
        end
        richText:addText(string.format(game.getStrByKey("empire_dead_info_killer"), data.killerFactionName, data.killerName, data.buffNum))
    else
        richText:addText(game.getStrByKey("empire_dead_info_dead"))
    end
    -- local timeStr = string.format("%02d", (math.floor(data.killeTime/60)%60))..":"..string.format("%02d", math.floor(data.killeTime%60)) 
    -- richText:addText(string.format(game.getStrByKey("empire_dead_info_kill_time"), timeStr))
    richText:format()

    createSprite(self.bg, path.."20.png", cc.p(self.bg:getContentSize().width/2, 170), cc.p(0.5, 0.5))

   	richText = require("src/RichText").new(self.bg, cc.p(self.bg:getContentSize().width/2, 170), cc.size(340, 30), cc.p(0.5, 1), 24, 18, MColor.yellow)
    richText:addText(game.getStrByKey("empire_dead_info_tip"))
    richText:format()

    createSprite(self.bg, path.."20.png", cc.p(self.bg:getContentSize().width/2, 80), cc.p(0.5, 0.5))
end

return EmpireDeadInfoNode