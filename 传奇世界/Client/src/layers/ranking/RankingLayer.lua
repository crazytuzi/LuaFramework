local RankingLayer = class("RankingLayer", require("src/TabViewLayer"))

local path = "res/ranking/"

require("src/layers/ranking/RankingDefine")

function RankingLayer:ctor(isSelfServer)
	local bg = cc.Node:create()--createBgSprite(self, "", path.."8.png")
	bg:setPosition(cc.p(0, 0))
	self:addChild(bg)
	--local leftBg = createSprite(bg, COMMONPATH.."bg/buttonBg2.png", cc.p(13, 25), cc.p(0, 0))
	local leftBg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(20, 25),
        cc.size(185, 522),
        5
    )
	--local rightBg = createSprite(bg, COMMONPATH.."bg/tableBg2.png", cc.p(204, 25), cc.p(0, 0))
	local rightBg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(205, 25),
        cc.size(735, 522),
        5
    )
	leftBg:setLocalZOrder(2)
	rightBg:setLocalZOrder(1)
	self.rightBgSize = rightBg:getContentSize()

	--createSprite(bg, path.."26.png", cc.p(20, 590), cc.p(0, 0))
	--createLabel(bg, game.getStrByKey("rank_title5"), cc.p(20, 590), cc.p(0, 0), 20):setColor(MColor.lable_yellow)

	--底部提示条
	--self.tipBg = createSprite(bg, "res/common/59.png", cc.p(18, 10), cc.p(0, 0))
	local selfRankeNode = cc.Node:create()
	rightBg:addChild(selfRankeNode)
	selfRankeNode:setLocalZOrder(2)
	createSprite(selfRankeNode, COMMONPATH.."bg/bg-1.png", cc.p(370, 75), cc.p(0.5, 0))
	self.mayRanktip = createLabel(selfRankeNode, game.getStrByKey("my_rank"), cc.p(25, 40), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
	createLabel(selfRankeNode, game.getStrByKey("rank_title5"), cc.p(255, 40), cc.p(0, 0.5), 20):setColor(MColor.lable_yellow)
	--self.tip = createLabel(selfRankeNode, "", cc.p(220, 35), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_black)
	self.isSelfServer = true
	self.selectIdx = 0

	local checkRoleFunc = function()
		local name = self.rankingListLayer:getSelected()
		if name == G_ROLE_MAIN:getTheName() then
			TIPS({ str = game.getStrByKey("charm_CheckSelf"), type = 1}) 
			return
		end
		if name then
			log("ckeck role "..name)
			local map_focus = {1,1,1,1,2,3,13,12}  --{1,1,2,3,1,13,12,1}
			LookupInfo(name,map_focus[self.selectIdx+1])
		end
	end
	self.checkRoleBtn = createMenuItem(selfRankeNode, "res/component/button/51.png", cc.p(660, 40), checkRoleFunc)
	createLabel(self.checkRoleBtn, game.getStrByKey("look_up"), cc.p(self.checkRoleBtn:getContentSize().width/2, self.checkRoleBtn:getContentSize().height/2), cc.p(0.5, 0.5), 22, true)
	
	self.leftBtnData = {
		{RANK_LEVEL, "16.png", "level"},
		--{RANK_BATTLE, "15.png", "combat_power"},
		{RANK_FACTION,"37.png", "faction"},
		{RANK_PK, "35.png", "Murderer"},
		--{RANK_WING, "14.png", "wing"},
		--{RANK_RIDE, "13.png", "horse"},
		-- {RANK_ZHANJIA,"39.png"},
		-- {RANK_ZHANREN,"40.png"},
	}

	self.leftBtn = {}
	self:createTableView(leftBg ,cc.size(195, 513), cc.p(0, 3), true)

	self.rankingListLayer = require("src/layers/ranking/RankingListLayer").new(function(enable) self.checkRoleBtn:setEnabled(enable) end)
	rightBg:addChild(self.rankingListLayer)

	g_EventHandler["setSelfRank"] = function(rank, rankType)
		self:setSelfRank(rank, rankType)
	end
    self:registerScriptHandler(function(event)
		if event == "enter" then
		elseif event == "exit" then
			g_EventHandler["setSelfRank"] = nil
		end
	end)

	local myData = require("src/layers/spiritring/ringdata"):getServerData()
end

function RankingLayer:setIsSelfServer(bValue, index)
	self.isSelfServer = bValue
	self.selectIdx = index or self.selectIdx
	self:select(self.selectIdx)
end

function RankingLayer:setSelfRank(rank, rankType)
	local str = game.getStrByKey("my_rank")
	if rankType == RANK_FACTION then
		str = game.getStrByKey("myFaction_rank")
	end
	if rank and rank ~= 0 then
		self.mayRanktip:setString(str .. " " .. rank)
	else
		self.mayRanktip:setString(str .. " " .. game.getStrByKey("ranking_no_rank"))
	end

	self:setTip(rank, rankType)
end

function RankingLayer:select(index)
	local button
	if index == 1 then
		self.checkRoleBtn:setEnabled(false)
		self.checkRoleBtn:setVisible(false)
	else
		self.checkRoleBtn:setEnabled(true)
		self.checkRoleBtn:setVisible(true)
	end

	self.selectIdx = index
	log("self.selectIdx = "..self.selectIdx)
	self.rankingListLayer:setDataShow(self.leftBtnData[self.selectIdx+1][1], self.isSelfServer)
	self:changeState(self:getTableView():cellAtIndex(index))
end

function RankingLayer:setTip(rank, rankType)
	if rank == 0 then
		rank = 101
	end

	local rankTypeToId =
	{
		[RANK_LEVEL] = "q_grade_ranking",
		[RANK_BATTLE] = "q_battle_ranking",
		[RANK_FACTION] = "q_bp_ranking",
		[RANK_PK] = "q_pk_ranking",
		[RANK_WING] = "q_wing_ranking",
		--[RANK_RIDE] = "q_horse_ranking",
		-- [RANK_ZHANJIA] = "q_armor_ranking",
		-- [RANK_ZHANREN] = "q_weapons_ranking",
	}
	local tab = require("src/config/RankingTips")
	for i,v in pairs(tab) do
		if i == #tab or rank <= v.q_ranking then
			local str = v[rankTypeToId[rankType]]
			-- if self.tip then
			-- 	self.tip:setString(str)
			-- 	self.tip:setPosition(cc.p(self.rightBgSize.width/2, 35))
			-- end
			break
		end
	end
end

function RankingLayer:reloadData()
	self:getTableView():reloadData()
end

function RankingLayer:tableCellTouched(table, cell)
	local index = cell:getIdx()
	AudioEnginer.playTouchPointEffect()
	self:select(index)
end

function RankingLayer:changeState( cell )
	if not cell then return end
	if self.curItem and tolua.cast(self.curItem, "cc.TableViewCell") then 
        self.curItem.bg:setTexture("res/component/button/40.png") 
        removeFromParent( self.curItem.arrowsFlag )
        self.curItem.arrowsFlag = nil
    end		
    self.curItem = cell 
    cell.bg:setTexture("res/component/button/40_sel.png") 
    cell.arrowsFlag = createSprite( cell.bg , "res/group/arrows/9.png" , cc.p( cell.bg:getContentSize().width , cell.bg:getContentSize().height/2) , cc.p( 0 , 0.5 ) )
end

function RankingLayer:cellSizeForTable(table, idx) 
    return 70, 192
end

function RankingLayer:tableCellAtIndex(tableView, idx)
	--log("idx = "..idx)

	local cell = tableView:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	else 
		cell:removeAllChildren()
	end  
	local button = createSprite(cell, "res/component/button/40.png", cc.p(5, 2), cc.p(0, 0))
	cell.bg = button
	for i,v in ipairs(self.leftBtnData) do
		if i == (idx + 1) then
			createLabel(button, game.getStrByKey(v[3]), getCenterPos(button), cc.p(0.5, 0.5), 22, true):setColor(MColor.lable_yellow)
		end
	end

    return cell
end

function RankingLayer:numberOfCellsInTableView(table)
   	return #self.leftBtnData
end

return RankingLayer