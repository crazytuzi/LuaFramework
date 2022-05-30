EventType = {
began = "began",
ended = "ended",
cancel = "cancel"
}
function addTouchListener(node, callBack)
	local imageButton = require("game.Biwu.ImageButton"):new()
	imageButton:addTouchListener(node, callBack)
end

function addNodeTouchListener(node, callBack)
	local touchNode = require("utility.MyLayer").new({
	swallow = true,
	parent = node,
	size = node:getContentSize(),
	touchHandler = function(event)
		callBack(event)
	end,
	})
	return touchNode
end