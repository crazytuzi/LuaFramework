local AreaUpView = class("AreaUpView", function()
	return require("utility.ShadeLayer").new()
end)

function AreaUpView:ctor(data)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("arena/arena_up.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.tupo_up01:setString(data.newRank)
	rootnode.tupo_up02:setString(data.upperRank)
	if data.gold > 0 then
		rootnode.rank_max:setVisible(false)
		rootnode.rank_gold:setVisible(true)
		rootnode.tupo_gold:setString(data.gold)
	else
		rootnode.rank_max:setVisible(true)
		rootnode.rank_gold:setVisible(false)
		rootnode.rank_max_ttf:setString(data.maxRank)
	end
	alignNodesOneByOne(rootnode.tupo4, rootnode.tupo5)
	alignNodesOneByOne(rootnode.tupo5, rootnode.tupo_gold)
	
	self:setTouchFunc(function(event)
		--dump("===========================")
		self:removeSelf()
	end)
end

return AreaUpView