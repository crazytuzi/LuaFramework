local skyArenaRank = class("skyArenaRank", function() return cc.Node:create() end)

local rescompath = "res/layers/skyArena/"


function skyArenaRank:ctor(parent, data)

--	log("[skyArenaRank:ctor] called.")

	self.parent = parent
	parent:addChild(self)
	
	self.mRankData = data

	-----------------------------------------------------------


	local nodeDlg = createSprite(self, COMMONPATH .. "bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))


	local centerX = getCenterPos(nodeDlg).x + 3
	--createSprite(nodeDlg, COMMONPATH .. "bg/bg18-7.png", cc.p(centerX, 15), cc.p(0.5, 0.0))
	--createSprite(nodeDlg, COMMONPATH .. "bg/bg18-13.png", cc.p(centerX, 62), cc.p(0.5, 0.0))

	createScale9Frame(
        nodeDlg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(centerX, 15),
        cc.size(790, 454),
        5,
        cc.p(0.5, 0.0)
    )
	
	createScale9Frame(
        nodeDlg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(centerX, 62),
        cc.size(772, 366),
        5,
        cc.p(0.5, 0.0)
    )

	-- title
	local strTitle = game.getStrByKey("sky_arena_title") .. game.getStrByKey("rank_list")
	createLabel(nodeDlg, strTitle, cc.p(centerX, 502), cc.p(0.5, 0.5), 24, true, 10)


	-------------------------------------------------------

	local my_ranking = 0
	local my_combat_power = MRoleStruct:getAttr(PLAYER_BATTLE)
	local my_total_score = 0

	if G_SKYARENA_DATA then
		if G_SKYARENA_DATA.SelfData then
			my_total_score = G_SKYARENA_DATA.SelfData.SScore
			my_ranking = G_SKYARENA_DATA.SelfData.SRanking
		end
	end


	local text_size = 22
	local color_text = cc.c3b(180, 140, 100)
	local color_number = cc.c3b(255, 255, 255)


	-------------------------------------------------------
	-- head line

	local headLinePosY = 448
	createLabel(nodeDlg, game.getStrByKey("name_ranking"), cc.p(80,  headLinePosY), cc.p(0.5, 0.5), text_size, true, 10)
	createLabel(nodeDlg, game.getStrByKey("char_name"),    cc.p(220, headLinePosY), cc.p(0.5, 0.5), text_size, true, 10)
	createLabel(nodeDlg, game.getStrByKey("school"),       cc.p(390, headLinePosY), cc.p(0.5, 0.5), text_size, true, 10)
	createLabel(nodeDlg, game.getStrByKey("combat_power"), cc.p(540, headLinePosY), cc.p(0.5, 0.5), text_size, true, 10)
	createLabel(nodeDlg, game.getStrByKey("total_score"),  cc.p(700, headLinePosY), cc.p(0.5, 0.5), text_size, true, 10)


	-------------------------------------------------------
	-- bottom line

	local text_my = game.getStrByKey("my")
	local text_colon = game.getStrByKey("colon")
	local bottomLinePosY = 40

	local my_ranking_text = text_my .. game.getStrByKey("name_ranking") .. text_colon
	createLabel(nodeDlg, my_ranking_text,  cc.p(60, bottomLinePosY), cc.p(0.0, 0.5), text_size, true, 10)
	createLabel(nodeDlg, my_ranking == 0 and game.getStrByKey("ranking_no_rank") or tostring(my_ranking),  cc.p(170, bottomLinePosY), cc.p(0.0, 0.5), text_size, true, 10, nil, color_number)

	local my_combat_power_text = text_my .. game.getStrByKey("combat_power") .. text_colon
	createLabel(nodeDlg, my_combat_power_text,  cc.p(270, bottomLinePosY), cc.p(0.0, 0.5), text_size, true, 10)
	createLabel(nodeDlg, tostring(my_combat_power),  cc.p(405, bottomLinePosY), cc.p(0.0, 0.5), text_size, true, 10, nil, color_number)

	local my_total_score_text = text_my .. game.getStrByKey("total_score") .. text_colon
	createLabel(nodeDlg, my_total_score_text,  cc.p(540, bottomLinePosY), cc.p(0.0, 0.5), text_size, true, 10)
	createLabel(nodeDlg, tostring(my_total_score),  cc.p(676, bottomLinePosY), cc.p(0.0, 0.5), text_size, true, 10, nil, color_number)


	-------------------------------------------------------
	-- rank list

	local tvSize = cc.size(754, 367)
	local tableView = cc.TableView:create(tvSize)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setPosition(cc.p(50, 62))
	tableView:setDelegate()
	nodeDlg:addChild(tableView)
	tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
--	tableView:registerScriptHandler(function(table, cell) self:tableCellTouched(table, cell) end,cc.TABLECELL_TOUCHED)    
	tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end ,cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end ,cc.TABLECELL_SIZE_AT_INDEX)
	tableView:reloadData()


    -------------------------------------------------------
    -- button
	
	local funcCBClose = function()
		if self.parent then
			self.parent:closeRankPanel()
		end
	end

	createMenuItem(nodeDlg, "res/component/button/X.png", cc.p(812, 502), funcCBClose)

    -------------------------------------------------------

	SwallowTouches(nodeDlg)
end


function skyArenaRank:numberOfCellsInTableView(table)
	return #self.mRankData
end

function skyArenaRank:tableCellTouched(table, cell)

end

function skyArenaRank:cellSizeForTable(table, idx) 
    return 50, 754
end

function skyArenaRank:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if cell == nil then
		cell = cc.TableViewCell:new()   
	else
		cell:removeAllChildren()
	end

	-------------------------------------------------------

	local parNode = cell
	local idxf = #self.mRankData - idx
	local posY = 28

	createSprite(parNode, "res/common/bg/line9.png", cc.p(0, 2), cc.p(0.0, 0.0))

	if idxf >= 1 and idxf <= 3 then
		local image_file = "res/ranking/no_" .. idxf .. ".png"
		local image_flag = createSprite(parNode, image_file, cc.p(32, posY), cc.p(0.5, 0.5))
		image_flag:setScale(0.6)
	else
		local strText = string.format("%s", idxf)
		createLabel(parNode, strText, cc.p(32, posY), cc.p(0.5, 0.5), 22, true, 10)
	end

	-------------------------------------------------------

	local data_entry = self.mRankData[idxf]
    local Mconvertor = require "src/config/convertor"
	createLabel(parNode, data_entry.char_name, cc.p(172, posY), cc.p(0.5, 0.5), 22, true, 10)
	createLabel(parNode, Mconvertor:school(data_entry.char_school), cc.p(340, posY), cc.p(0.5, 0.5), 22, true, 10)
	createLabel(parNode, data_entry.combat_power, cc.p(490, posY), cc.p(0.5, 0.5), 22, true, 10)
	createLabel(parNode, data_entry.total_score, cc.p(650, posY), cc.p(0.5, 0.5), 22, true, 10)


	-------------------------------------------------------

    return cell
end


-----------------------------------------------------------

return skyArenaRank
