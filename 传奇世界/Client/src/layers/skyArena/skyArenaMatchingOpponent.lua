local skyArenaMatchingOpponent = class("skyArenaMatchingOpponent", function() return cc.Node:create() end)


function skyArenaMatchingOpponent:ctor(parent)

--	log("[skyArenaMatchingOpponent:ctor] called.")

--	if parent then
--		self.parent = parent
--		parent:addChild(self)
--	end

	-----------------------------------------------------------
    isInArenaScene = true

	local nodeDlg = createSprite(self, COMMONPATH .. "bg/bg31.png", cc.p(0, 0), cc.p(0.5, 0.5))


	local centerX = getCenterPos(nodeDlg).x


	-- title
	local strTitle = game.getStrByKey("sky_arena_matching_opponent")
	createLabel(nodeDlg, strTitle, cc.p(centerX, 261), cc.p(0.5, 0.5), 24, true, 10)

	-- info
	createLabel(nodeDlg, game.getStrByKey("sky_arena_matching_info"), cc.p(centerX, 115), cc.p(0.5, 0.5), 20, true, 10)


	-- image
	createSprite(nodeDlg, "res/layers/skyArena/group/group_name_bg.png", cc.p(centerX, 136), cc.p(0.5, 0.0))


	-- animation
	local effect = Effects:create(false)
	nodeDlg:addChild(effect)
	effect:setPosition(cc.p(centerX, 177))
--	effect:playActionData2("matching", 1, -1)
	effect:playActionData("matching", 4, 1, -1)


    -------------------------------------------------------
    -- button
	
	local funcCBCancel = function()
--		if self.parent then
--			self.parent:closeMatchingPanel()
--		end
        
		g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_EXIT_MATCH, "P3V3ExitMatchProtocol", {type = 0})
		cclog("[PVP3V3_CS_EXIT_MATCH] sent.")
        self.btnCancel:setEnabled(false)
        removeFromParent(self);--点击取消后发送给服务器取消消息, 服务器将不会再发送开始匹配消息,因此不许要考虑这种情况,否则应该设置self tag 为非commConst.TAG_3V3_MATCHINGOPPONENT,来保证新对话框弹出
        
        isInArenaScene = false
	end

	self.btnCancel = createMenuItem(nodeDlg, "res/component/button/50.png", cc.p(centerX, 48), funcCBCancel)
	createLabel(self.btnCancel, game.getStrByKey("cancel"), getCenterPos(self.btnCancel), cc.p(0.5, 0.5), 22, true, 10)


    -------------------------------------------------------

	SwallowTouches(nodeDlg)


	Manimation:transit(
	{
		ref = getRunScene(),
		node = self,
		curve = "-",
		sp = cc.p(0, 0),
		zOrder = 200,
		swallow = false,
	})

    -------------------------------------------------------

--	g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_START_MATCH, "P3V3StartMatchProtocol", {type = 0})
--	cclog("[PVP3V3_CS_START_MATCH] sent. role_id = %s.")

end



-----------------------------------------------------------

return skyArenaMatchingOpponent
