local teamTreasureTaskIntroduce = class("teamTreasureTaskIntroduce", function() return cc.Node:create() end)

local rescompath = "res/layers/teamTreasureTask/"


function teamTreasureTaskIntroduce:ctor(parent)

--	log("[teamTreasureTaskIntroduce:ctor] called.")

	if parent then
		self.parent = parent
		parent:addChild(self)
	end

	-----------------------------------------------------------

	local text_size = 22
	local color_desc = MColor.orange
	local posX = display.cx
	local posY = 500

	local nodeDlg = createBgSprite(self)

	createSprite(nodeDlg, "res/common/bg/bg.png", cc.p(14, 25), cc.p(0.0, 0.0))
	createSprite(nodeDlg, rescompath .. "image_top.png", cc.p(19, 310), cc.p(0.0, 0.0))
	createSprite(nodeDlg, "res/common/bg/bg12-1.png", cc.p(84, 160), cc.p(0.0, 0.0))


	-- Create title
	createLabel(nodeDlg, game.getStrByKey("treasure_ancient"), cc.p(display.width/2-(g_scrSize.width-960)/2, 606), cc.p(0.5, 0.5), 28, true, 10)



	posX = 36

	-------------------------------------------------------
	-- time
	createLabel(nodeDlg, game.getStrByKey("activity_time"), cc.p(posX, 280), cc.p(0.0, 0.5), text_size, true, 10)
	createLabel(nodeDlg, game.getStrByKey("every_day"), cc.p(posX + 114, 280), cc.p(0.0, 0.5), text_size, true, 10, nil, color_desc)


	-------------------------------------------------------
	-- desc
	createLabel(nodeDlg, game.getStrByKey("bodyguard_tip") .. game.getStrByKey("colon"), cc.p(posX, 240), cc.p(0.0, 0.5), text_size, true, 10)
	local strTextDesc = game.getStrByKey("treasure_desc")
	local richText = require("src/RichText").new(nodeDlg, cc.p(posX + 114, 252), cc.size(600, 0), cc.p(0, 1), 26, text_size, color_desc)
	richText:setAutoWidth()
	richText:addText(strTextDesc, nil, true)
	richText:format()


	-------------------------------------------------------
	-- level

	local needLevel = 30
	local strLvName = game.getStrByKey("activity") .. game.getStrByKey("level") .. game.getStrByKey("colon")
	createLabel(nodeDlg, strLvName, cc.p(774, 280), cc.p(0.0, 0.5), text_size, true, 10)
	createLabel(nodeDlg, tostring(needLevel), cc.p(774 + 110, 280), cc.p(0.0, 0.5), text_size, true, 10, nil, color_desc)


    -------------------------------------------------------
	-- prize

	createLabel(nodeDlg, game.getStrByKey("activity_awards"), cc.p(posX, 125), cc.p(0.0, 0.5), text_size, true, 10)

	posX = posX + 166
	posY = 95
	local item_id = {6200039, 6200040, 6200041}
	local prize_count = #item_id
	local Mprop = require "src/layers/bag/prop"
	for i = 1, prize_count do
		local icon = Mprop.new(
		{
			protoId = tonumber(item_id[i]),
			swallow = true,
			cb = "tips",
		})
		nodeDlg:addChild(icon)
		icon:setPosition(cc.p(posX, posY))
		icon:setAnchorPoint(0.5, 0.5)

		posX = posX + 96
	end


    -------------------------------------------------------
    -- button
	
	local funcCBGoto = function()
		self:gotoNPC()
	end

	local btnGoto = createMenuItem(nodeDlg, "res/component/button/2.png", cc.p(842, 80), funcCBGoto)
	createLabel(btnGoto, game.getStrByKey("faction_gotoJoin"), getCenterPos(btnGoto), cc.p(0.5,0.5), 22, true)


    -------------------------------------------------------

	SwallowTouches(nodeDlg)
end

function teamTreasureTaskIntroduce:gotoNPC()
	local ILevel = MRoleStruct:getAttr(ROLE_LEVEL)
	if ILevel == nil or ILevel < 30 then
		TIPS({type=1, str=string.format(game.getStrByKey("activity_begain_atLev"), 30)})
		return
	end

	-------------------------------------------------------

	local mapId, posX, posY = 2100, 100, 91
	local npcCfg = require("src/config/NPC")
	for i=1, #npcCfg do
		if tonumber(npcCfg[i].q_id) == 10465 then
			mapId = tonumber(npcCfg[i].q_map)
			posX = tonumber(npcCfg[i].q_x)
			posY = tonumber(npcCfg[i].q_y)
			break
		end
	end
	local WorkCallBack = function()
		if G_ROLE_MAIN and G_MAINSCENE then
			require("src/layers/mission/MissionNetMsg"):sendClickNPC(10465)
		end
	end

	local tempData = {targetType = 4, mapID = mapId, x = posX, y = posY, callFun = WorkCallBack}
	__TASK:findPath(tempData)
	__removeAllLayers()
end


-----------------------------------------------------------

return teamTreasureTaskIntroduce
