--
-- Author: Daneil
-- Date: 2015-01-29 15:40:17
--
EventType  = { 
	began  = "began",
	ended  = "ended",
	cancel = "cancel"
}

addTouchListener = function (node,callBack)
	local imageButton = require("game.Biwu.ImageButton"):new()
	imageButton:addTouchListener(node,callBack)
end








