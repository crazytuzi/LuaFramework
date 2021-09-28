local JJCSelHall = class("JJCSelHall", function() return cc.Layer:create() end)

local comPath = "res/jjc/"
function JJCSelHall:ctor()
	local addSprite = createSprite
	local addLabel = createLabel

	local bg = createBgSprite(self,"",comPath.."jjc_word.png")
	self.bg = bg
    
	--顶部
    self.leftBg = addSprite(bg,comPath.."7.jpg",cc.p(248.5,285))
    self.rightBg = addSprite(bg,comPath.."8.jpg",cc.p(711.5,285))
    --addLabel(bg, game.getStrByKey("my_rank"),cc.p(100,520), cc.p(0.5,0.5),24):setColor(MColor.yellow_gray)

    local func = function(mode)
        local jjcLayer = require("src/layers/jjc/JJCHall").new(mode)
          Manimation:transit(
          {
              ref = getRunScene(),
              node = jjcLayer,
              curve = "-",
              sp = cc.p(display.width/2, display.height/2),
              zOrder = 200,
             -- tag = 305,
              swallow = true,
          })
    end
    addSprite(self.leftBg,comPath.."5.png",cc.p(231.5,460))
    createLabel(self.leftBg,game.getStrByKey("jjc_lvlRequire"),cc.p(54.5, 170), cc.p(0.0,0.5), 21,true)
    createLabel(self.leftBg,"25"..game.getStrByKey("jjc_ji"),cc.p(160, 170), cc.p(0.0,0.5), 21,true):setColor(MColor.green)
    createLabel(self.leftBg,game.getStrByKey("jjc_desc1"),cc.p(54.5, 135), cc.p(0.0,0.5), 21,true,nil,nil,nil,nil,335):setColor(MColor.green)
    local item = createMenuItem(self.leftBg,"res/component/button/4.png",cc.p(231.5,40),function() func(1) end)
    createLabel(item,game.getStrByKey("jjc_enter"),cc.p(61.5, 29.5), nil, 24,true)
    G_TUTO_NODE:setTouchNode(item, TOUCH_BATTLE_LOCAL)

    addSprite(self.rightBg,comPath.."6.png",cc.p(231.5,460))
    createLabel(self.rightBg,game.getStrByKey("jjc_lvlRequire"),cc.p(54.5, 170), cc.p(0.0,0.5), 21,true)
    createLabel(self.rightBg,"50"..game.getStrByKey("jjc_ji"),cc.p(160, 170), cc.p(0.0,0.5), 21,true):setColor(MColor.green)
    createLabel(self.rightBg,game.getStrByKey("jjc_desc2"),cc.p(54.5, 135), cc.p(0.0,0.5), 21,true,nil,nil,nil,nil,335):setColor(MColor.green)
    local item = createTouchItem(self.rightBg,"res/component/button/4.png",cc.p(231.5,40),function() func(2) end, true)
    createLabel(item,game.getStrByKey("jjc_enter"),cc.p(61.5, 29.5), nil, 24,true)
    if MRoleStruct:getAttr(ROLE_LEVEL) < 50 then
      item:setEnable(false)
    end

    self:initTouch()

    self:registerScriptHandler(function(eventType)
        if eventType == "enter" then
            G_TUTO_NODE:setShowNode(self, SHOW_BATTLE)
        elseif eventType == "exit" then
           
        end
    end)
end

function JJCSelHall:initTouch() 
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    local tempSel = nil
    listenner:registerScriptHandler(function(touch, event)
	     	 -- 	local pt = self.bg:convertTouchToNodeSpace(touch)
	     	 -- 	if self.currDisChannel <= 2 then
		     	--  	if (pt.x) < 245 and (pt.x) > 20 and self.fbTabs[self.currDisChannel] and self.fbTabs[self.currDisChannel].detailPanel:getScaleX() ~= 0 then
		     	-- -- 		cclog("收起来")
	     		--  		self.fbTabs[self.currDisChannel]:spread(false)
		     	--  	end
		     	-- end
     		return true
        end,cc.Handler.EVENT_TOUCH_BEGAN)  
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)
end

return JJCSelHall