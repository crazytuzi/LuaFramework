local FactionInviteListView = class("FactionInviteListView", require("src/TabViewLayer"))

local rescompath = "res/layers/skyArena/"


function FactionInviteListView:ctor(data)

	self.mRankData = data
	-- self.mRankData[#self.mRankData+1] = self.mRankData[1]
	-- self.mRankData[#self.mRankData +1] = self.mRankData[1]
	-- self.mRankData[#self.mRankData +1] = self.mRankData[1]
	-- self.mRankData[#self.mRankData +1] = self.mRankData[1]
	-- self.mRankData[#self.mRankData +1] = self.mRankData[1]

	-- self.mRankData[#self.mRankData +1] = self.mRankData[1]
	-- self.mRankData[#self.mRankData +1] = self.mRankData[1]
	-- self.mRankData[#self.mRankData +1] = self.mRankData[1]

	-- self.mRankData[#self.mRankData +1] = self.mRankData[1]
	if not data then
		print("FactionInviteListView:ctor error!")
	end

	local nodeDlg = createSprite(self, COMMONPATH .. "bg/bg18.png", cc.p(display.cx, display.cy))
	local centerX = getCenterPos(nodeDlg).x + 3

	-- createSprite(nodeDlg, COMMONPATH .. "bg/bg18-7.png", cc.p(centerX, 15), cc.p(0.5, 0.0))
	-- createSprite(nodeDlg, COMMONPATH .. "bg/bg18-13.png", cc.p(centerX, 62), cc.p(0.5, 0.0))

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
	local strTitle = game.getStrByKey("faction_invite_list")
	createLabel(nodeDlg, strTitle, cc.p(centerX, 502), cc.p(0.5, 0.5), 24, true, 10)

	-------------------------------------------------------
	-- head line

	local posCfg = {80 + 20, 220 + 20, 390 + 20, 540 + 20, 700 + 20}
	local strCfg = {"factionYST_name", "factionYST_LeaderName", "factionYST_level", "factionYST_fight", "faction_top_faction_action"}
	for i=1,5 do
		createLabel(nodeDlg, game.getStrByKey(strCfg[i]), cc.p(posCfg[i],  448), cc.p(0.5, 0.5), 22, true, 10)
	end
	-------------------------------------------------------
	-- bottom line
	createLabel(nodeDlg, game.getStrByKey("faction_invite_tips"), cc.p(centerX, 40), nil, 22):setColor(MColor.red)
	-------------------------------------------------------
	-- rank list

	self:createTableView(nodeDlg, cc.size(754, 362), cc.p(50, 64), true)
	self:getTableView():setBounceable(true)
	self:getTableView():reloadData()

    -------------------------------------------------------
    -- button
	
	local funcCBClose = function()
		removeFromParent(self)
	end

	createMenuItem(nodeDlg, "res/component/button/X.png", cc.p(812, 502), funcCBClose)

    -------------------------------------------------------
    local n_prompt = __createHelp(
	{
		parent = nodeDlg,
		str = require("src/config/PromptOp"):content(65),
		pos = cc.p(630, 40),
	})

	n_prompt:setScale(0.8)

	SwallowTouches(nodeDlg)
end


function FactionInviteListView:numberOfCellsInTableView(table)
	return #self.mRankData
end

function FactionInviteListView:tableCellTouched(table, cell)

end

function FactionInviteListView:cellSizeForTable(table, idx) 
    return 60, 754
end

function FactionInviteListView:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if cell == nil then
		cell = cc.TableViewCell:new()   
	else
		cell:removeAllChildren()
	end

	-------------------------------------------------------

	local parNode = cell
	local idxf = idx + 1
	local posY = 33
	local data_entry = self.mRankData[idxf]
	if data_entry then
		createSprite(parNode, "res/common/bg/line9.png", cc.p(0, 2), cc.p(0.0, 0.0))

	    createLabel(parNode, data_entry.facName, cc.p(32 + 14, posY), cc.p(0.5, 0.5), 20, true, 10):setColor(MColor.lable_black)
		createLabel(parNode, data_entry.facLeaderName, cc.p(172 + 17, posY), cc.p(0.5, 0.5), 20, true, 10):setColor(MColor.lable_black)
		createLabel(parNode, data_entry.facLevel, cc.p(340 + 20, posY), cc.p(0.5, 0.5), 20, true, 10):setColor(MColor.lable_black)
		createLabel(parNode, data_entry.facBattle, cc.p(490 + 20, posY), cc.p(0.5, 0.5), 20, true, 10):setColor(MColor.lable_black)

		local func = function()
        	local facid = data_entry.facID
        	print("FACTION_INVADE_CS_ENTER .. ", facid, MRoleStruct:getAttr(PLAYER_FACTIONID))
			g_msgHandlerInst:sendNetDataByTableExEx(FACTION_INVADE_CS_ENTER, "FactionInvadeEnterReq", {facID = facid})
		end
		local item = createMenuItem(parNode, "res/component/button/49.png", cc.p(650 + 20, posY), func)
		createLabel(item, "入侵驻地", getCenterPos(item), cc.p(0.5, 0.5), 22, true)
	end	

	-------------------------------------------------------

    return cell
end


-----------------------------------------------------------

return FactionInviteListView
