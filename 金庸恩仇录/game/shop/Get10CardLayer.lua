local Get10CardLayer = class("Get10CardLayer", function()
	return require("utility.ShadeLayer").new()
end)
function Get10CardLayer:ctor(isOneFree, times, listener)
	local proxy = CCBProxy:create()
	local subNode = {}
	local submenu = CCBuilderReaderLoad("shop/shop_zhaojiang.ccbi", proxy, subNode)
	submenu:setPosition(display.cx, display.cy)
	self:addChild(submenu, 10)
	if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
		local frameNo = display.newSpriteFrame("icon_lv_silver.png")
		subNode.leftCost:setDisplayFrame(frameNo)
		subNode.rightCost:setDisplayFrame(frameNo)
	end
	if isOneFree ~= nil and isOneFree == true then
		subNode.leftCost:setVisible(false)
		subNode.leftFree_lbl:setVisible(true)
	else
		subNode.leftCost:setVisible(true)
		subNode.leftFree_lbl:setVisible(false)
	end
	
	subNode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		sender:runAction(transition.sequence({
		CCCallFunc:create(function()
			self:removeSelf()
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	if times > 0 then
		subNode.tag_left_times:setString(common:getLanguageString("@zhaomubd1", times))
	else
		subNode.tag_left_times:setString(common:getLanguageString("@zhaomubd"))
	end
	
	subNode.tag_zhaojiang_1:registerScriptTapHandler(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if listener then
			listener(1)
		end
		self:removeSelf()
	end)
	
	subNode.tag_zhaojiang_10:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if listener then
			listener(10)
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
end

return Get10CardLayer