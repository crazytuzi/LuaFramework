local TaskTargetLable = class("TaskTargetLable", function( ) return cc.Node:create() end)

function TaskTargetLable:ctor(text_size)
	-- body
	local size1 = 18
	if text_size then
		size1 = text_size
	end
	self.labeltask1 = createLabel(self, game.getStrByKey("task_kill"),cc.p(0,0),cc.p(0.0,0.5),size1)
	self.labeltask2 = createLabel(self, "",cc.p(20,0),cc.p(0.0,0.5),size1)
	self.labeltask2:setColor(cc.c3b(124,252,0))
	self.labeltask3 = createLabel(self, "(1/99)",cc.p(30,0),cc.p(0.0,0.5),size1)
	self.labeltask3:setColor(cc.c3b(255,0,0))
end

function TaskTargetLable:setText(collect, name, num1, num2)
	-- body
	local sizex = 0
	if collect then
		self.labeltask1:setString(game.getStrByKey("task_collect"))
		--name = getConfigItemByKey("src/config/NPC", "q_id", goodsid, "q_name")
	else
		self.labeltask1:setString(game.getStrByKey("task_kill"))
		--name = getConfigItemByKey("src/config/monster", "q_id", goodsid, "q_name")
	end

	self.labeltask2:setString(name)

	local w1 = self.labeltask1:getContentSize().width
	self.labeltask2:setPositionX(w1 + 10)
	self.labeltask3:setString("("..num1.."/"..num2..")")
	local w2 = self.labeltask2:getContentSize().width
	self.labeltask3:setPositionX( w1 + 20 + w2 )
	sizex = w1 + 20 + w2 + self.labeltask3:getContentSize().width
	return sizex
end

function TaskTargetLable:setText1(t_name, color1, t_text, color2)
	-- body
   	local c1 = color1 or cc.c3b(255,255,255)
   	local c2 = color2 or cc.c3b(255,255,255)
   	if self.labeltask3 then
		removeFromParent(self.labeltask3)
		self.labeltask3 = nil 
	end
	self.labeltask1:setString(t_name)
	self.labeltask1:setColor(c1)
	self.labeltask2:setString(t_text)
	self.labeltask2:setColor(c2)
	self.labeltask2:setPositionX(3 + self.labeltask1:getContentSize().width)
end

return TaskTargetLable