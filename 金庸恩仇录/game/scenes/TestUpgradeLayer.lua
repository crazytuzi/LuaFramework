local TestUpgradeLayer = class("TestUpgradeLayer", function()
	return require("utility.ShadeLayer").new()
end)
function TestUpgradeLayer:ctor()
	self:setNodeEventEnabled(true)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("public/testupdate.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	rootnode.tag_close:addHandleOfControlEvent(function()
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.testMusic:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX("u_testmusic"))
	end,
	CCControlEventTouchUpInside)
	
	rootnode.testAnim:addHandleOfControlEvent(function()
		local path = "testanim/yanlong/yanlong.ExportJson"
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(path)
		local tempArma = CCArmature:create("yanlong")
		tempArma:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
		end)
		tempArma:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		end)
		tempArma:getAnimation():playWithIndex(0)
		rootnode.animNode:addChild(tempArma)
	end,
	CCControlEventTouchUpInside)
	
	rootnode.testRes:addHandleOfControlEvent(function()
		local sprite = display.newSprite("testanim/bixiejiandian1.png")
		rootnode.spriteNode:addChild(sprite)
	end,
	CCControlEventTouchUpInside)
	
end

return TestUpgradeLayer