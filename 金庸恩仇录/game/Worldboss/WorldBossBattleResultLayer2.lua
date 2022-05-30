local WorldBossBattleResultLayer2 = class("WorldBossBattleResultLayer2", function()
	return require("utility.ShadeLayer").new()
end)

function WorldBossBattleResultLayer2:ctor(param)
	local confirmFunc = param.confirmFunc
	local data = param.data
	local rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/worldBoss_challenge_laye2.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.hurt_lbl:setString(tostring(data["4"].curHurt))
	for i, v in ipairs(data["3"]) do
		if v.t == 7 and v.id == 5 then
			rootnode.shengwang_lbl:setString(tostring(v.n))
		else
			rootnode.receive_icon:removeAllChildren()
			local itemType = ResMgr.ITEM
			if v.t == 8 then
				itemType = ResMgr.HERO
			elseif v.t == 4 then
				itemType = ResMgr.EQUIP
			elseif v.t == 14 or v.t == 13 then
				itemType = ResMgr.PET
			end
			local item = require("game.Huodong.RewardItem").new()
			local t = item:create({
			unShowName = true,
			itemData = {
			id = v.id,
			type = v.t,
			iconType = itemType,
			num = v.n
			},
			viewSize = cc.size(95, 95)
			})
			rootnode.receive_icon:addChild(t)
			t:setPosition(0, -15)
			if v.t == 7 and v.id == 2 then
				local money = game.player:getSilver() + v.n
				game.player:setSilver(money)
				PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			end
		end
	end
	if data["7"] ~= nil then
		game.player:setGold(data["7"])
		PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	end
	if data["8"] ~= nil then
		rootnode.leftTime:setString(tostring(data["8"]))
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
end

return WorldBossBattleResultLayer2