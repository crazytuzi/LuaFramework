local TaskRewards = class("TaskRewards", function( ) return cc.Layer:create() end)
local MPropOp = require "src/config/propOp"
function TaskRewards:ctor()
	self.bg = createSprite(self, "res/common/bg/itemBg.png", cc.p(35, 35))
	self.prop = createSprite(self, "res/common/bg/itemBg.png", cc.p(35, 35))
end

function TaskRewards:getBgNode()
	return self.bg
end

function TaskRewards:touchback()
	cclog("点击对比装备属性！")--G_MAINSCENE
	local tip = require("src/layers/task/tips").new()
	G_MAINSCENE:addChild(tip, 130)
end

function TaskRewards:setRewards( i_name, num, reward )
	-- body
	local num1 = 0
	if num > 10000 then
		num1 = math.floor( num/10000 )
	end
	if self.bg then
		removeFromParent(self.bg)
		self.bg = nil 
	end
	if self.prop then
		removeFromParent(self.prop)
		self.prop = nil
	end
	if reward == 0 then
			--显示物品的部分需要统一借口：
		local Mprop = require "src/layers/bag/prop"
		local sprite = Mprop.new({ protoId = i_name, cb = "tips", num = num })
		sprite:setPosition(35,35)
		self:addChild(sprite)
	--请大家修改
	else
  		--q_id=9201.0,q_name='增加物理攻击'
  		--q_id=9202.0,q_name='增加魔法攻击'
  		--q_id=9203.0,q_name='增加道士攻击'
  		--q_id=9204.0,q_name='增加战士防御力'
  		--q_id=9205.0,q_name='增加战士魔法防御'
  		--q_id=9206.0,q_name='增加法师防御力'
  		--q_id=9207.0,q_name='增加法师魔法防御力'
  		--q_id=9208.0,q_name='增加道士防御力'
  		--q_id=9209.0,q_name='增加道术魔法防御力'
  		--q_id=9210.0,q_name='增加战士生命'
  		--q_id=9211.0,q_name='增加法师生命'
  		--q_id=9212.0,q_name='增加道士生命',

		local rid = {
				["ry"] = 333333,["exp"] = 444444, ["coin"] = 999998, ["gold"] = 999999,
				["zq"] = 777777,["lj"] = 888888, ["yb"] = 222222
			     }

		--if num1 == 0 then
			--self.taskjl:setString( tostring(num) )
		--else
			--self.taskjl:setString( num1..game.getStrByKey("task_num") )
		--end
		--local size = self.taskjl:getContentSize()
		--self.taskjl:setPositionX( 66 - size.width )
		--self.jangli:setTexture(MPropOp.icon(rid[i_name]))
		--self.prop:setTexture(MPropOp.border(rid[i_name]))

		local Mprop = require "src/layers/bag/prop"
		local sprite = Mprop.new({ protoId = rid[i_name], cb = "tips", num = num })
		sprite:setPosition(35,35)
		self:addChild(sprite)
	end
end

function TaskRewards:setRingUpdate(str, call)
	self.menu = createTouchItem(self, str, cc.p(35,35), call)
end

function TaskRewards:setItems(id, num, call, im, call1)
	--dump(self.bg:getContentSize(),"111111111111111")
	--border(id)
	if id == 1200 and num > 0 then
		self.menu = createSprite(self,MPropOp.icon(id),cc.p(35,35))
		createSprite(self, "res/layers/spiritring/ring_update3.png", cc.p(35, 10))
		self.i_num = createLabel(self,""..num,cc.p(35,12),cc.p(0.5,0.5),14)
		local listenner = cc.EventListenerTouchOneByOne:create()
	    listenner:setSwallowTouches(false)
	    listenner:registerScriptHandler(function(touch,event)
        local pt = touch:getLocation()
        pt = self.menu:convertToNodeSpace(pt)
	        if cc.rectContainsPoint(self.menu:getBoundingBox(),pt) then
				local forever = cc.RepeatForever:create(cc.Sequence:create( cc.CallFunc:create(call),cc.DelayTime:create(0.2) ))
				forever:setTag(1200)
				self:runAction(forever)
			end
			return true
		end,cc.Handler.EVENT_TOUCH_BEGAN)

		listenner:registerScriptHandler(function(touch, event)
			local pt = touch:getLocation()
			pt = self.bg:convertToNodeSpace(pt)
			if not cc.rectContainsPoint(self.bg:getBoundingBox(),pt) then
				self:stopActionByTag(1200)
			end
			-- self:stopActionByTag(1200)
			return true
        end,cc.Handler.EVENT_TOUCH_MOVED )

   		listenner:registerScriptHandler(function(touch, event)
    	    self:stopActionByTag(1200)
        end,cc.Handler.EVENT_TOUCH_ENDED )

		local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)
	else
		self.menu = createTouchItem(self, MPropOp.icon(id), cc.p(35,35), call)  --"res/layers/spiritring/4.png"
		if call1 then
			self.menu:registerTouchDownHandler(call1)
		end
		--registerScriptTouchHandler
		createSprite(self, "res/layers/spiritring/ring_update3.png", cc.p(35, 10))
		self.i_num = createLabel(self,""..num,cc.p(35,12),cc.p(0.5,0.5),14)
		--self.prop:setTexture("res/rolebag/bag/border/"..im..".png")
		--self.prop:setTexture()
	end
end

function TaskRewards:setNum( num )
	-- body
	self.i_num:setString(num.."")
end
return TaskRewards