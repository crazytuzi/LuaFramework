local skyArenaRelive = class("skyArenaRelive", function() return cc.LayerColor:create(cc.c4b(255,255,128,96)) end)

local rescompath = "res/layers/skyArena/"
local deadTimes=0
		
function skyArenaRelive:resetDeadTimes()
	deadTimes=0
end
function skyArenaRelive:ctor(parent)

--	log("[skyArenaRelive:ctor] called.")
	
	if parent then
		self.parent = parent
		parent:addChild(self)
	end	
	addEffectWithMode(self,4)
	-----------------------------------------------------------

	local nodeDlg = createSprite(self, rescompath .. "result/relive-bg.png", cc.p(display.cx, 500), cc.p(0.5, 0.5))
	self.nodeDlg = nodeDlg

	-------------------------------------------------------

	local text_size = 20
	local centerX = 222
	deadTimes=deadTimes+1
	deadTimes=math.min(deadTimes,3)
	local arena3v3DB = require "src/config/P3V3DB"
	self.time_remain = arena3v3DB.reliveTime[deadTimes]

	local strText = string.format("00:%02s", self.time_remain)
	createLabel(nodeDlg, game.getStrByKey("you_are_killed"), cc.p(centerX, 60), cc.p(0.5, 0.5), text_size, true, 10)
	self.labTimeValue = createLabel(nodeDlg, strText, cc.p(centerX, 40), cc.p(0.5, 0.5), text_size, true, 10)


    -------------------------------------------------------

	SwallowTouches(nodeDlg)


	local funcUpdate = function()
		self:timeUpdate()
	end
	startTimerActionEx(self, 1.0, true, funcUpdate)

end


function skyArenaRelive:timeUpdate()

	if self.time_remain > 1 then
		self.time_remain = self.time_remain - 1


		if self.labTimeValue then
			local strText = string.format("00:%02s", self.time_remain)
			self.labTimeValue:setString(strText)
		end
	else
		if G_MAINSCENE then
			if G_MAINSCENE.map_layer then
				if G_MAINSCENE.map_layer.isSkyArena then
					G_MAINSCENE.map_layer:hideRelivePanel()
				end
			end
		end
	end

end



-----------------------------------------------------------

return skyArenaRelive
