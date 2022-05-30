local WorldBossBattleResultLayer = class("WorldBossBattleResultLayer", function()
	return require("utility.ShadeLayer").new()
end)

function WorldBossBattleResultLayer:ctor(param)
	local confirmFunc = param.confirmFunc
	local data = param.data
	local rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/worldBoss_challenge_layer.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.hurt_lbl:setString(tostring(data["4"].curHurt))
	for i, v in ipairs(data["3"]) do
		if v.t == 7 and v.id == 5 then
			rootnode.shengwang_lbl:setString(tostring(v.n))
		end
	end
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if confirmFunc ~= nil then
			confirmFunc()
		end
	end,
	CCControlEventTouchUpInside)
	
	rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if confirmFunc ~= nil then
			confirmFunc()
		end
	end,
	CCControlEventTouchUpInside)
	
	alignNodesOneByAllCenterX(rootnode.sprite_1:getParent(), {
	rootnode.sprite_0,
	rootnode.sprite_1,
	rootnode.sprite_2
	}, 4)
	alignNodesOneByAllCenterX(rootnode.hurt_lbl_1:getParent(), {
	rootnode.hurt_lbl_1,
	rootnode.hurt_lbl
	}, 4)
	alignNodesOneByAllCenterX(rootnode.label_2:getParent(), {
	rootnode.label_2,
	rootnode.shengwang,
	rootnode.shengwang_lbl
	}, 4)
end

return WorldBossBattleResultLayer