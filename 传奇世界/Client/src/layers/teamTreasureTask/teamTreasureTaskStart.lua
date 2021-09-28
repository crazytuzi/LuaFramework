local teamTreasureTaskStart = class("teamTreasureTaskStart", function() return cc.Node:create() end)

local rescompath = "res/layers/teamTreasureTask/"


function teamTreasureTaskStart:ctor()
	self.mType = 0
	self.mIconSelect = nil

	-----------------------------------------------------------

	local text_size = 18
	local color_text = cc.c3b(180, 140, 100)
	local posX = 428
	local posY = 500
	local offsetY = text_size + 4
	local posCXL = 272

	local nodeParent = createBgSprite(self, game.getStrByKey("treasure_ancient"))

	nodeParent:setPosition(cc.p(0, 0))
	nodeParent:setAnchorPoint(cc.p(0.5, 0.5))
	local ndSize = nodeParent:getContentSize()
	--local nodeDlg = createSprite(nodeParent, COMMONPATH .. "bg/bg-6.png", cc.p(ndSize.width/2, ndSize.height/2-30), cc.p(0.5, 0.5))
    local nodeDlg = cc.Node:create()
    nodeDlg:setPosition(cc.p(15, 23))
    nodeDlg:setContentSize(cc.size(930, 535))
    nodeDlg:setAnchorPoint(cc.p(0, 0))
    nodeParent:addChild(nodeDlg)

    createScale9Frame(
        nodeDlg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(16, 16),
        cc.size(515, 501),
        5
    )
	--createSprite(nodeDlg, "res/common/bg/bg67-1.png", cc.p(16, 16), cc.p(0.0, 0.0))
	createSprite(nodeDlg, rescompath .. "image_left.png", cc.p(538, 16), cc.p(0.0, 0.0))
	createSprite(nodeDlg, "res/common/bg/bg67-1-1.png", cc.p(posCXL, 316), cc.p(0.5, 0.5))



	-------------------------------------------------------
	-- level

	posX = 40
	posY = 490
	local needLevel = 30
	local strLvName = game.getStrByKey("bodyguard_lv") .. game.getStrByKey("colon")
	createLabel(nodeDlg, strLvName, cc.p(posX, posY), cc.p(0.0, 0.5), text_size, true, 10)
	posY = posY - offsetY
	createLabel(nodeDlg, game.getStrByKey("treasure_participate"), cc.p(posX, posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(color_text)


	-------------------------------------------------------
	-- desc

	posY = posY - offsetY - 6
	createLabel(nodeDlg, game.getStrByKey("bodyguard_tip") .. game.getStrByKey("colon"), cc.p(posX, posY), cc.p(0.0, 0.5), text_size, true, 10)

	posY = posY - offsetY + 10
	local strTextDesc = game.getStrByKey("treasure_desc2")
	local richText = require("src/RichText").new(nodeDlg, cc.p(posX, posY), cc.size(470, 0), cc.p(0, 1), 24, text_size, color_text)
	richText:setAutoWidth()
	richText:addText(strTextDesc, nil, true)
	richText:format()


    -------------------------------------------------------

	posY = posY - offsetY - 20
	createLabel(nodeDlg, game.getStrByKey("treasure_kill_time"), cc.p(posX, posY), cc.p(0.0, 0.5), text_size, true, 10, nil, MColor.red)

	posY = posY - offsetY
	createLabel(nodeDlg, game.getStrByKey("treasure_share"), cc.p(posX, posY), cc.p(0.0, 0.5), text_size, true, 10, nil, MColor.red)


	posY = posY - offsetY - 26
	createLabel(nodeDlg, game.getStrByKey("treasure_choose"), cc.p(posCXL, posY), cc.p(0.5, 0.5), text_size+2, true, 10)


    -------------------------------------------------------
	-- prize icon select

	local package_item_count = {0, 0, 0}
	posX = posCXL - 160
	posY = 240

	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)

	local IconPosX = {posX, posX+160, posX+320}
	local IconPosY = posY

	local funcCBChoose = function(sender)
		if sender then
			local tag = sender:getTag()
			self.mType = tag
			cclog("[teamTreasureTaskStart:ctor] Current type = %s.", self.mType)

			self.mIconSelect:setVisible(true)
			self.mIconSelect:setPosition(cc.p(IconPosX[tag], IconPosY))
			self.mIconSelect:playActionData2("guildup", 300, -1, 0)
			self.mIconSelect:setScale(0.8)
		end
	end

	local icon_file = {"tt_icon_copper.png", "tt_icon_silver.png", "tt_icon_gold.png"}
	for i = 1, 3 do
		local item_id = 6200035 + i
		local nAward = 6200038 + i
		package_item_count[i] = pack:countByProtoId(item_id)
		
		local btnIcon = createTouchItem(nodeDlg, rescompath .. icon_file[i], cc.p(IconPosX[i], IconPosY), funcCBChoose)
		btnIcon:setTag(i)
		btnIcon:setScale(0.8)

		local dc = "^c(red)"
		if package_item_count[i] >= 1 then
			dc = "^c(green)"
		end

		local strCount = string.format("(%s/1)", package_item_count[i])
		local strKey = "treasure_graph_" .. i
		local strName = game.getStrByKey(strKey)
		local strVal = strName .. "^c(lable_yellow)(^" .. dc .. tostring(package_item_count[i]) .. "^" .. "^c(lable_yellow)/1)^"
		local richText = require("src/RichText").new(nodeDlg, cc.p(posX, posY-72), cc.size(160, 0), cc.p(0.5, 0.5), 24, text_size, color_text)
		richText:setAutoWidth()
		richText:addText(strVal, nil, true)
		richText:format()

		strKey = "treasure_item_" .. i
		-- createLabel(nodeDlg, game.getStrByKey(strKey), cc.p(posX, posY - 98), cc.p(0.5, 0.5), text_size, true, 10, nil, color_text)
		-- local richText = require("src/RichText").new(nodeDlg, cc.p(posX, posY - 98), cc.size(160, 0), cc.p(0.5, 0.5), 24, text_size, color_text)
		-- richText:setAutoWidth()
		-- -- richText:addText(strVal, nil, true)
		-- richText:addTextItem(game.getStrByKey(strKey), color_text, false, true, true, 
		-- 	function()  
		-- 		local Mtips = require "src/layers/bag/tips"
		-- 		Mtips.new(
		-- 		{ 
		-- 			protoId = tonumber(nAward),
		-- 			--grid = gird,
		-- 			pos = cc.p(0, 0),
		-- 			--actions = actions,
		-- 		}) 
		-- 	end )
		-- richText:format()
		-- GetUIHelper():underLine(richText, 2, MColor.red, 40, 15)
		--parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor
		local tempLabel = createLabel(nodeDlg, "奖励", cc.p(posX - 50, posY - 98), cc.p(0.5, 0.5), text_size, true, 10, nil, color_text)
		local needsLabel = createLinkLabel(nodeDlg, game.getStrByKey(strKey), cc.p(posX + 20, posY - 98), cc.p(0.5, 0.5), 20, true, nil, MColor.yellow, nil, function() 
				local Mtips = require "src/layers/bag/tips"
				Mtips.new(
				{ 
					protoId = tonumber(nAward),
					--grid = gird,
					pos = cc.p(0, 0),
					--actions = actions,
				}) 
		 end, true)
		posX = posX + 160
	end

	local icon_effect = Effects:create(true)
	icon_effect:setPosition(cc.p(IconPosX[1], IconPosY))
	addEffectWithMode(icon_effect, 1)
	nodeDlg:addChild(icon_effect)
	icon_effect:setVisible(false)

	self.mIconSelect = icon_effect


    -------------------------------------------------------
    -- button
	
--	local funcCBClose = function()
--		removeFromParent(self)
--	end

	local funcCBAccept = function()
		local ret = self:startTreasureTask(self.mType)
		if ret then
			removeFromParent(self)
		end
	end

	local btnAccept = createMenuItem(nodeDlg, "res/component/button/2.png", cc.p(posCXL-100, 86), funcCBAccept)
	createLabel(btnAccept, game.getStrByKey("accept") .. game.getStrByKey("task"), getCenterPos(btnAccept), cc.p(0.5,0.5), 22, true)

    -------------------------------------------------------
	-- count

	local pcount_cur = 0
	local pcount_max = 1
	local pcount_text
	local pcount_color
	if pcount_cur < pcount_max then
		pcount_text = game.getStrByKey("participate_count") .. game.getStrByKey("colon") .. (pcount_max-pcount_cur) .. " / " .. pcount_max
		pcount_color = MColor.name_gray
	else
		pcount_text = game.getStrByKey("participate_count") .. game.getStrByKey("participate_runout")
		pcount_color = MColor.red
	end
	self.mLabCount = createLabel(nodeDlg, pcount_text, cc.p(posCXL, 42), cc.p(0.5,0.5), text_size, true, 10, nil, pcount_color)

	
    -------------------------------------------------------

	SwallowTouches(nodeDlg)

    -------------------------------------------------------

	Manimation:transit(
	{
		ref = getRunScene(),
		node = self ,
		curve = "-",
		sp = cc.p(0, 0),
		zOrder = 199 ,
		swallow = false,
	})

    -------------------------------------------------------

	local msgids = {TASK_SC_GET_SHARED_TASK_TIMES}
	require("src/MsgHandler").new(self,msgids)

	local MainRoleId = 0
	if userInfo then
		MainRoleId = userInfo.currRoleId
	end

	g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_GET_SHARED_TASK_TIMES, "GetSharedTaskTimesProtocol", {})
	cclog("[TASK_CS_GET_SHARED_TASK_TIMES] sent. role_id = %s.", MainRoleId)


	local function findTeam( ... )
		-- body
		require("src/layers/teamTreasureTask/AncientTreasureTeamPanel").new(nil, 199)
	end

	local btnFind = createMenuItem(nodeDlg, "res/component/button/2.png", cc.p(posCXL + 100, 86), findTeam)
	createLabel(btnFind, "寻找队伍", getCenterPos(btnAccept), cc.p(0.5,0.5), 22, true)
end

function teamTreasureTaskStart:startTreasureTask(typeid)
	if typeid == 0 then
		MessageBox(game.getStrByKey("treasure_please_choose"), game.getStrByKey("sure"))
		return false
	end

	local MainRoleId = 0
	if userInfo then
		MainRoleId = userInfo.currRoleId
	end

	local t = {}
	t.taskRank = typeid
	g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_ACCEPT_SHARED_TASK, "AcceptSharedTaskProtocol", t)
	cclog("[TASK_CS_ACCEPT_SHARED_TASK] sent. role_id = %s, typeid = %s.", MainRoleId, typeid)

	return true
end

function teamTreasureTaskStart:updateInterface(PCountCur, PCountMax)
	local pcount_cur = PCountCur
	local pcount_max = PCountMax
	local pcount_rem = PCountMax - PCountCur
	local pcount_text
	local pcount_color
	if pcount_cur < pcount_max then
		pcount_text = game.getStrByKey("participate_count") .. game.getStrByKey("colon") .. pcount_rem .. " / " .. pcount_max
		pcount_color = MColor.name_gray
	else
		pcount_text = game.getStrByKey("participate_count") .. game.getStrByKey("participate_runout")
		pcount_color = MColor.red
	end

	if self.mLabCount then
		self.mLabCount:setString(pcount_text)
		self.mLabCount:setColor(pcount_color)
	end
end


function teamTreasureTaskStart:networkHander(buff, msgid)
	local switch = {
	[TASK_SC_GET_SHARED_TASK_TIMES] = function()
		local t = g_msgHandlerInst:convertBufferToTable("GetSharedTaskTimesRetProtocol", buff)
		local count_cur = t.remainNum
		local count_max = t.allNum

		log("[TASK_SC_GET_SHARED_TASK_TIMES] received. count_cur = %s, count_max = %s.", count_cur, count_max)

		self:updateInterface(count_cur, count_max)
	end,
	}

	if switch[msgid] then
		switch[msgid]()
	end
end


-----------------------------------------------------------

return teamTreasureTaskStart
