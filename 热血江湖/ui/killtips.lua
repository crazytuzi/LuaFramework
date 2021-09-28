-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_killTips = i3k_class("wnd_killTips", ui.wnd_base)

local WEIGHT = "ui/widgets/zdshalut"
local RED = 7580
local BULE = 7581
local BLUEOUTCOLOR = "FF191356"
local REDOUTCOLOR = "FF561313" 

function wnd_killTips:ctor()
	self._timeTick = 0;
	self._pool = i3k_queue.new();
end

function wnd_killTips:configure()

end

function wnd_killTips:onShow()
end

function wnd_killTips:onHide()
	
end

function wnd_killTips:refresh(info)
	local itemNode = self:refreshItem(info)
	local itemVars = itemNode.vars
	local layerRoot = self._layout.vars.root
	local size = self._pool:size()
	local contentSize = layerRoot:getContentSize()
	local width = contentSize.width
	local height = contentSize.height
	
	if size ~= 0 then
		self._timeTick = 0
		
		for i = self._pool._first, self._pool._last, 1 do
			local value = self._pool._value[i]
			
			if value then
				self._pool._value[i].timeTick = self._pool._value[i].timeTick + i3k_db_common.killTipsCfg.addTime
				local moveRoot = self._pool._value[i].node.vars.weightRoot
				local nodePos = moveRoot:getPosition()
				needPosY = moveRoot:getContentSize().height + nodePos.y
				local move2 = cc.MoveTo:create(0.2, {x = nodePos.x, y = needPosY})
				local fadeOut2 = cc.FadeOut:create(0.2)
				local spawn2 = cc.Spawn:create(fadeOut2, move2)
				local seq = cc.Sequence:create(spawn2, cc.CallFunc:create(function ()
				end))
				moveRoot:runAction(seq)
			end
		end		
	end
	
	layerRoot:addChild(itemNode)
	itemVars.weightRoot:setContentSize(width, height)
	local data = {node = itemNode, timeTick = 0}
	self._pool:push(data)
end

function wnd_killTips:refreshItem(info)
	local item = require(WEIGHT)()
	local weight = item.vars	
	local kill = info.killer
	local dead = info.deader
	local killerForceType = info.killerForceType
	weight.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(kill.headIcon, false))
	weight.name:setText(kill.name)
	weight.icon2:setImage(g_i3k_db.i3k_db_get_head_icon_path(dead.headIcon, false))
	weight.name2:setText(dead.name)
	
	if g_i3k_game_context:GetForceType() == killerForceType then
		weight.name:enableOutline(BLUEOUTCOLOR)
		weight.bottom:setImage(i3k_db_icons[BULE].path)
	else
		weight.name:enableOutline(REDOUTCOLOR)
		weight.bottom:setImage(i3k_db_icons[RED].path)
	end
	
	return item
end

function wnd_killTips:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime;
	
	if self._pool:size() ~= 0 then
		for i = self._pool._first, self._pool._last, 1 do
			local value = self._pool._value[i]
			
			if value then
				value.timeTick = value.timeTick + dTime
				
				if value.timeTick > i3k_db_common.killTipsCfg.existenceTime then
					local fadeOut = cc.FadeOut:create(0.2)
					local seq = cc.Sequence:create(cc.CallFunc:create(function ()
						self._pool:pop()
						self._layout.vars.root:removeChild(value.node)
					end), fadeOut)
					value.node.vars.weightRoot:runAction(seq)
				end
			end
		end		
	end
	
	if self._timeTick > i3k_db_common.killTipsCfg.existenceTime then
		g_i3k_ui_mgr:CloseUI(eUIID_KillTips);
	end
end

function wnd_create(layout)
	local wnd = wnd_killTips.new();
	wnd:create(layout);
	return wnd;
end

