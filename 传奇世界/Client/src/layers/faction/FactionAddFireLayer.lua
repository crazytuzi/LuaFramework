local FactionAddFireLayer = class("FactionAddFireLayer", function() return cc.Layer:create() end)

local path = "res/faction/"

function FactionAddFireLayer:ctor()
	local msgids = {FACTIONAREA_SC_GET_WOOD_NUM_RET}
	require("src/MsgHandler").new(self, msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(FACTIONAREA_CS_GET_WOOD_NUM, "ii", G_ROLE_MAIN.obj_id, require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID))
	g_msgHandlerInst:sendNetDataByTableExEx(FACTIONAREA_CS_GET_WOOD_NUM, "FactionAreaGetWoodNumProtocol", {})
	--addNetLoading(FACTIONAREA_CS_GET_WOOD_NUM, FACTIONAREA_SC_GET_WOOD_NUM_RET)

	--self:showMessageBox(1)
end

function FactionAddFireLayer:showMessageBox(time)
	local function yesCallback()
		--g_msgHandlerInst:sendNetDataByFmtExEx(FACTIONAREA_CS_OPEN_FIRE, "ii", G_ROLE_MAIN.obj_id, require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID))
		local t = {}
		t.factionID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
		g_msgHandlerInst:sendNetDataByTableExEx(FACTIONAREA_CS_OPEN_FIRE, "FactionAreaOpenFireProtocol", t)
	end

	local function noCallback()

	end
	local str = string.format(game.getStrByKey("faction_add_time_tip"), time)
	local bg = MessageBoxYesNo(nil, game.getStrByKey("faction_add_content"), yesCallback, noCallback)

	local richText = require("src/RichText").new(bg, cc.p(bg:getContentSize().width/2, 100), cc.size(150, 30) , cc.p(0.5, 0.5), 20, 20, MColor.lable_yellow)
  	richText:addText(str, MColor.lable_yellow, true)
  	richText:format()
end

function FactionAddFireLayer:networkHander(buff, msgid)
	local switch = {
		[FACTIONAREA_SC_GET_WOOD_NUM_RET] = function()    
			log("get FACTIONAREA_SC_GET_WOOD_NUM_RET") 
			local t = g_msgHandlerInst:convertBufferToTable("FactionAreaGetWoodNumRetProtocol", buff)
			local time = t.count
			if time > 0 then
				self:showMessageBox(time)
				removeFromParent(self)
			else
				TIPS({str = game.getStrByKey("faction_add_time_zero_tip"), type = 1})
				removeFromParent(self)
			end
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionAddFireLayer