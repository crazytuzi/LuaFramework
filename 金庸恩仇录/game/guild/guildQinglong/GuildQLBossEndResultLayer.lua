--修改完成
local GuildQLBossEndResultLayer = class("GuildQLBossEndResultLayer", function()
	return require("utility.ShadeLayer").new()
end)

function GuildQLBossEndResultLayer:ctor(param)
	local rtnObj = param.data.rtnObj
	local confirmFunc = param.confirmFunc
	local rstObj = rtnObj.res
	local awardAry = rtnObj.awardAry
	local rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("guild/guild_worldBoss_result_layer.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	--确认
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if confirmFunc ~= nil then
			confirmFunc()
		end
	end,
	CCControlEventTouchUpInside)
	
	if rstObj.kill ~= nil and rstObj.kill ~= "" then
		rootnode.state_lbl:setString(rstObj.kill .. common:getLanguageString("@QingLongKilled"))
	else
		rootnode.state_lbl:setString(common:getLanguageString("@QingLongAlive"))
	end
	rootnode.attack_lbl:setString(rstObj.hurt)
	if rstObj.rank ~= nil and rstObj.rank <= 0 then
		rootnode.rank_lbl:setString(common:getLanguageString("@NotHave"))
	else
		rootnode.rank_lbl:setString(common:getLanguageString("@DI") .. rstObj.rank .. common:getLanguageString("@RankNo2"))
	end
	for i, v in ipairs(awardAry) do
		if v.t == 7 and v.id == 2 then
			rootnode.silver_lbl:setString(tostring(v.n))
		elseif v.t == 7 and v.id == 5 then
			rootnode.shengwang_lbl:setString(tostring(v.n))
		elseif v.t == 7 and v.id == 8 then
			rootnode.guild_contribute_lbl:setString(tostring(v.n))
		end
	end
end

return GuildQLBossEndResultLayer