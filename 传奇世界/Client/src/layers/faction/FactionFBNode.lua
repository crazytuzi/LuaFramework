local FactionFBNode = class("FactionFBNode", function() return cc.Node:create() end)
local FBRank = class("FBRank", require("src/TabViewLayer"))

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionFBNode:ctor(objId)
	local msgids = {FACTIONCOPY_SC_GET_PASS_TIME_RET, FACTIONCOPY_SC_FRESH_RANK, FACTIONCOPY_SC_RELIVEINFO, FACTIONCOPY_SC_OVER, FACTIONCOPY_SC_GET_ALL_RANK_RET}
	require("src/MsgHandler").new(self,msgids)    
	g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_GET_PASS_TIME, "FactionCopyGetPassTime", {})
	--addNetLoading(FACTIONCOPY_CS_GET_PASS_TIME, FACTIONCOPY_SC_GET_PASS_TIME_RET)

	self.data = {}
	self.isShow = true
	self.data.myHurt = 0
	self.fbData = require("src/config/FactionCopyDB")
	self.rank_data = {}
	
	local bg = createSprite(self, "res/mainui/sideInfo/sideInfoBg.png", cc.p(2, 0), cc.p(0, 0.5))
	self.bg = bg
	local size = bg:getContentSize()
	self.bgSize = size

	local bgSub = createSprite(bg, "res/mainui/sideInfo/sideInfoBg-Sub.png", cc.p(7, 8), cc.p(0, 0))

    local showBtn, hideBtn = nil, nil 
    local function hideBg( _b )
        showBtn:setVisible(_b)
        showBtn:setEnabled(_b )
        bg:runAction( cc.EaseBackOut:create( cc.MoveTo:create(0.3 , _b and cc.p( -246 - 38, 0) or cc.p(2, 0) ) ) )
    end
    hideBtn = createMenuItem(bg, "res/mainui/sideInfo/hideBtn.png" , cc.p( 246 + 10 , 108 ) , function() hideBg( true ) end )
    showBtn = createMenuItem(bg, "res/mainui/sideInfo/showBtn.png" , cc.p( 246 + 59 , 108 ) , function() hideBg( false ) end )
    --self.floorSpr = createSprite(hideBtn, "res/mainui/sideInfo/factionFb.png", cc.p(52, 109))
--	createLabel(hideBtn, game.getStrByKey("faction_setOpen"), cc.p(250, 110), nil, 18, true)
	createMultiLineLabel(hideBtn, game.getStrByKey("damage_ranking"), cc.p(51, 148), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.yellow, 30, 25, true)
    hideBg(false)

	local textSize = 16
	local posX = 14
	local posY = 200
	local lineSpace = 20


--    self.timeTitleLab = createLabel(bg, game.getStrByKey("faction_bossTimeReset"), cc.p(self.bgSize.width/2, 190), nil, 18, true)
--    self.timeTitleLab:setColor(MColor.yellow)
--    self.leftTimeLab = createLabel(bg, "0", cc.p(self.bgSize.width/2, 160), nil, 18, true)
--	self.leftTimeLab:setColor(MColor.green)

	posY = 47
    createLabel(bg, game.getStrByKey("rank_selfRank")..game.getStrByKey("colon"), cc.p(posX, posY), cc.p(0, 0.5), textSize, true):setColor(MColor.yellow)
    createLabel(bg, game.getStrByKey("damage_personal")..game.getStrByKey("colon"), cc.p(posX, posY-lineSpace-2), cc.p(0, 0.5), textSize, true):setColor(MColor.yellow)
    self.myRankLab = createLabel(bg, "0", cc.p(posX + 85, posY), cc.p(0, 0.5), textSize, true)
    self.myRankLab:setColor(MColor.yellow)
    self.myHurtLab = createLabel(bg, "" .. self.data.myHurt, cc.p(posX + 85, posY-lineSpace-2), cc.p(0, 0.5), textSize, true)
	self.myHurtLab:setColor(MColor.yellow)

--    local item = createMenuItem(bg, "res/component/button/50.png" , cc.p( size.width/2 - 60 , 35 ) , function() self:openRank() end )
--    createLabel(item, game.getStrByKey("rank_title1"), getCenterPos(item), nil, 24, true):setColor(MColor.lable_yellow)
--    item:setScale(0.8)
--	local item = createMenuItem(bg, "res/component/button/50.png" , cc.p( size.width/2 + 60 , 35-100 ) , function() self:exit() end )
--    createLabel(item, game.getStrByKey("exit"), getCenterPos(item), nil, 24, true):setColor(MColor.lable_yellow)
--    item:setScale(0.8)


	local item = createMenuItem(self, "res/component/button/1.png", cc.p(g_scrSize.width-70, display.cy - 160), function() self:exit() end)
--	local item = createMenuItem(self, "res/component/button/1.png", cc.p(g_scrSize.width-70, 20), function() self:exit() end)
	item:setSmallToBigMode(false)
	createLabel(item, game.getStrByKey("exit"), getCenterPos(item), cc.p(0.5,0.5), 22, true):setColor(MColor.lable_yellow)    

	-------------------------------------------------------

	posY = 193
    createLabel(bg, game.getStrByKey("name_ranking"), cc.p(posX+40, posY), cc.p(0, 0.5), textSize, true):setColor(MColor.yellow)
    createLabel(bg, game.getStrByKey("faction_bossMakeHurt"), cc.p(posX+136, posY), cc.p(0, 0.5), textSize, true):setColor(MColor.yellow)

	posY = 170
	self.mRankLab = {}
	self.mRankDataCount = 0
	for i = 1, 5 do
		local itemRankText = {}
		itemRankText.labIndex = createLabel(bg, ""..i..". ", cc.p(posX, posY), cc.p(0.0, 0.5), textSize, true):setVisible(false)
		itemRankText.labName = createLabel(bg, "", cc.p(posX+70, posY), cc.p(0.5, 0.5), textSize, true):setVisible(false)
		itemRankText.labDamage = createLabel(bg, "", cc.p(posX+170, posY), cc.p(0.5, 0.5), textSize, true):setVisible(false)
		self.mRankLab[i] = itemRankText

		posY = posY - lineSpace
	end

--	g_msgHandlerInst:sendNetDataByFmtExEx(FACTIONCOPY_CS_GET_ALL_RANK, "i", G_ROLE_MAIN.obj_id)
--	self:startUpdateRankAll()
end

function FactionFBNode:updateTime(leftTime)
--	local showTime = leftTime
--	if showTime < 0 then showTime = 0 end

--	self.leftTimeLab:setString(secondParse(showTime))
--	if self.timeAction then
--		self:stopAction(self.timeAction)
--		self.timeAction = nil
--	end

--	if leftTime <= -10 then
--		self.leftTimeLab:setString("")
--	else
--		self.timeAction = startTimerAction(self, 1, true, function()
--			if showTime > 0 then
--				showTime = showTime - 1
--				self.leftTimeLab:setString(secondParse(showTime))
--			end
--		end)
--	end
end

function FactionFBNode:startUpdateRankAll()
	self.timeActionRank = startTimerAction(self, 5, true, function()
            g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_GET_ALL_RANK, "FactionCopyAllRank", {})
		end)
end

function FactionFBNode:updateRankAll()
	log("[FactionFBNode:updateRankAll]")

	for i = 1, 5 do
		if i <= self.mRankDataCount then
			self.mRankLab[i].labName:setString(self.rank_data[i][2])
			self.mRankLab[i].labDamage:setString(tostring(self.rank_data[i][6]))

			self.mRankLab[i].labIndex:setVisible(true)
			self.mRankLab[i].labName:setVisible(true)
			self.mRankLab[i].labDamage:setVisible(true)
		else
			self.mRankLab[i].labIndex:setVisible(false)
			self.mRankLab[i].labName:setVisible(false)
			self.mRankLab[i].labDamage:setVisible(false)
		end
	end
end

function FactionFBNode:updateRank()
	log("FactionFBNode:updateRank")
	-- self.rankLayer = tolua.cast(self.rankLayer, "cc.Node")
	-- if self.rankLayer then
	-- 	self.rankLayer:updateRankInfo(self.data.rankData)
	-- end
	if self.myRankLab then
		self.myRankLab:setString("" .. self.data.myRank)
	end
	if self.myHurtLab then
		self.myHurtLab:setString("" .. self.data.myHurt)
	end
end

function FactionFBNode:exit()
	print("FactionFBNode:exit")
    g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_OUT, "FactionCopyOut", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
end

function FactionFBNode:openRank()
	print("FactionFBNode:openRank")
	local layer = FBRank.new()
	Manimation:transit(
	{
		ref = getRunScene(),
		node = layer,
		curve = "-",
		sp = cc.p(display.cx, display.cy),
		zOrder = 200,
		tag = 109,
		swallow = true,
	})
	self.rankLayer = layer	
end

function FactionFBNode:showDeathTime(time)
	if not time or time <= 0 then
		return
	end

	local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 175))
	G_MAINSCENE.base_node:addChild(colorbg)
	colorbg:setLocalZOrder(200)
	registerOutsideCloseFunc(colorbg, function()  end, true)

	local deadNode = cc.Layer:create()
	deadNode:setContentSize(cc.size(960, 640))
	deadNode:setPosition(cc.p(g_scrSize.width/2, g_scrSize.height/2))	
	deadNode:ignoreAnchorPointForPosition(false)
	deadNode:setAnchorPoint(cc.p(0.5, 0.5))
	G_MAINSCENE.base_node:addChild(deadNode, 200)

	createLabel(deadNode, game.getStrByKey("faction_bossRelive"), cc.p(480, 500), nil, 26, true):setColor(MColor.yellow)
	local timeLab = createLabel(deadNode, secondParse(time), cc.p(480, 450), nil, 24, true)
	timeLab:setColor(MColor.red)

	startTimerAction(deadNode, 1, true, function()
		if time > 1 then
			time = time - 1
			timeLab:setString(secondParse(time))
		else
			removeFromParent(colorbg)
			removeFromParent(deadNode)
		end
	end)
end

function FactionFBNode:networkHander(buff,msgid)
	local switch = {
	[FACTIONCOPY_SC_GET_PASS_TIME_RET] = function ()
        local t = g_msgHandlerInst:convertBufferToTable("FactionCopyGetPassTimeRet", buff)
		self.bossTime = t.secToOpen
		self.copyId = t.copyID
		self.copySetCount = t.openTimes

		log("[FACTIONCOPY_SC_GET_PASS_TIME_RET] FactionFBNode time = %s, copyid = %s, setcount = %s.", self.bossTime, self.copyId, self.copySetCount)

		local theBossTime = self.bossTime

		if theBossTime == 0 then
			if self.timeTitleLab then
				self.timeTitleLab:setString(game.getStrByKey("faction_bossTimeReset"))
			end

			self:updateTime(-10)
		end

--		local index = 1
--		if G_FACTION_INFO.StartFbId ~= 0 then
--			for i=1, #self.fbData do
--				if tonumber(self.fbData[i].ID) == G_FACTION_INFO.StartFbId then
--					index = i
--				end
--			end
--		end

--		local data = self.fbData[index]
--		if passTime < tonumber(data.bossFreshTime) then
--			if self.timeTitleLab then
--				self.timeTitleLab:setString(game.getStrByKey("faction_bossContinueTime2"))
--			end
--			self:updateTime(tonumber(data.bossFreshTime) - passTime)

--			self.ChangeTitleTime = startTimerAction(self, tonumber(data.bossFreshTime) - passTime, false, function()
--				if self.timeTitleLab then
--					self.timeTitleLab:setString(game.getStrByKey("faction_bossContinueTime"))
--				end
--				self:updateTime(data.totalTime)					
--			end)
--		else
--			local leftTime = tonumber(data.totalTime) - passTime
--			self:updateTime(leftTime)
--		end
	end,
	[FACTIONCOPY_SC_FRESH_RANK] = function ()
		local t = g_msgHandlerInst:convertBufferToTable("FactionCopyFreshRank", buff) 
        
        self.data.myRank = t.rank  --自己的名次
		self.data.myHurt = t.hurt  --自己的伤害
		print("FACTIONCOPY_SC_FRESH_RANK..............rank:" .. self.data.myRank .. "hurt:" .. self.data.myHurt)
		self:updateRank()
	end,
	[FACTIONCOPY_SC_RELIVEINFO] = function ()
        local t = g_msgHandlerInst:convertBufferToTable("FactionCopyReliveInfo", buff) 
		local deathTime = t.relivePeriod
		self:showDeathTime(deathTime)
		print("FACTIONCOPY_SC_RELIVEINFO................" .. deathTime)
	end,
	[FACTIONCOPY_SC_OVER] = function ( )
		local t = g_msgHandlerInst:convertBufferToTable("FactionCopyOver", buff) 
        
        if self.timeTitleLab then
			self.timeTitleLab:setString(game.getStrByKey("faction_bossContinueTime1"))
		end
		self:updateTime(60)
		log("[FACTIONCOPY_SC_OVER] enter called.")
		
		self:openRank()
		
		local type = t.outTime
		local notify = t.prize
		if notify == 1 then
			local funcD = function()
				TIPS({type = 1, str = game.getStrByKey("fb_notify_getmailprize")})
				log("[FACTIONCOPY_SC_OVER] called.")
			end
			performWithDelay(self, funcD, 3.0)
		end
		
		if G_MAINSCENE then
			G_MAINSCENE:showBaseButtonFactionBoss(false, false)
		end

	end,

	[FACTIONCOPY_SC_GET_ALL_RANK_RET] = function ()
		local t = g_msgHandlerInst:convertBufferToTable("FactionCopyAllRankRet", buff) 
        
        local count = #t.infos
		if count > 5 then
			count = 5
		end
		for i=1, count do
			self.rank_data[i] = {}
			self.rank_data[i][1] = "" .. i
			self.rank_data[i][2] = t.infos[i].name
			self.rank_data[i][3] = t.infos[i].lv
			self.rank_data[i][0] = t.infos[i].viplv
			self.rank_data[i][4] = t.infos[i].job
			local facjob = t.infos[i].position
			local hurt = t.infos[i].hurt
			self.rank_data[i][6] = (hurt >= 10000) and ("" .. math.floor(hurt / 10000) .. game.getStrByKey("task_num")) or hurt
		end

		self.mRankDataCount = count
		self:updateRankAll()
	end,
	}

	if switch[msgid] then
		switch[msgid]()
	end
end

--///////////////////////////////////////////////////////////////////////////////////////

function FBRank:ctor()
	local msgids = {FACTIONCOPY_SC_GET_ALL_RANK_RET}
	require("src/MsgHandler").new(self,msgids)    
	g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_GET_ALL_RANK, "FactionCopyAllRank", {})
	self.data = {}

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	createLabel(bg, game.getStrByKey("rank_list"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 28, true)
	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )

	local tipSp = CreateListTitle(bg, cc.p(425,448), 790, 46, cc.p(0.5,0.5))

	local closeFunc = function() 
	   	bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() removeFromParent(self) end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)
	registerOutsideCloseFunc(bg, function() removeFromParent(self) end, true)

	local textTitle = {"rank_title1", "name", "level","faction_top_school","faction_top_job","faction_bossMakeHurt"}
	self.posData = {52, 185, 315, 445, 575, 705}

	for i=1,#textTitle do
		createLabel(tipSp, game.getStrByKey(textTitle[i]), cc.p(self.posData[i], 23), nil, 20, true)--:setColor(MColor.Lable_yellow)
	end

	self:createTableView(bg,cc.size(790, 408),cc.p(33, 18),true)
    self:getTableView():setBounceable(true)
end

function FBRank:exit()
	removeFromParent(self)
end

function FBRank:cellSizeForTable(table,idx) 
    return 83, 790
end

function FBRank:numberOfCellsInTableView(table)
    return #self.data or 0
end

function FBRank:tableCellAtIndex(table, idx)
    local addSprite = createSprite
    local addLabel = createLabel
    local _idx = 1 + idx
    local record = self.data[_idx]
    local cell = table:dequeueCell()
	local createVip = function(node, vip)
		if vip and vip>0 and vip<=10 then
			local vipBg = createSprite(node, "res/layers/vip/vipTitle/bg.png", cc.p(0, node:getContentSize().height/2), cc.p(1, 0.5), nil, 1)
	        createSprite(vipBg, "res/layers/vip/vipTitle/v.png", cc.p(vipBg:getContentSize().width/2, vipBg:getContentSize().height/2), cc.p(1, 0.5), nil, 1)
	        createSprite(vipBg, "res/layers/vip/vipTitle/"..vip..".png", cc.p(vipBg:getContentSize().width/2, vipBg:getContentSize().height/2), cc.p(0.3, 0.5), nil, 1)
	    end    
	end

    local new = function()
    	local bg = createSprite(cell, "res/common/table/cell_16.png", cc.p(0, 2), cc.p(0, 0)) 
    	for i,v in ipairs(record) do
			if i > 0 and i ~= 2 then
				local label = createLabel(bg, v, cc.p(self.posData[i], 41), cc.p(0.5, 0.5), 20, nil)
				label:setColor( MColor.lable_black)
			elseif i == 2 then
				local label = createLabel(bg, v, cc.p(self.posData[i] - 5, 41), cc.p(0.5, 0.5), 20, nil)
				label:setColor( MColor.lable_black)
				createVip(label, record[0])
			end 
		end       
    end
        
    if nil == cell then
        cell = cc.TableViewCell:new()
        new()
    else
        cell:removeAllChildren()
        new()
    end
    
    return cell
end

function FBRank:networkHander(buff,msgid)
	local switch = {
	[FACTIONCOPY_SC_GET_ALL_RANK_RET] = function ()
		local t = g_msgHandlerInst:convertBufferToTable("FactionCopyAllRankRet", buff) 
        local num = #t.infos
		local jobStr = {"lowlife","the_hall", "deputy_leader", "the_leader","lowlife","lowlife"}
		for i=1, num do
			self.data[i] = {}
			self.data[i][1] = "" .. i
			self.data[i][2] = t.infos[i].name
			self.data[i][3] = t.infos[i].lv
			self.data[i][0] = t.infos[i].viplv
			self.data[i][4] = t.infos[i].job
			if self.data[i][4] == 1 then
				self.data[i][4] = game.getStrByKey("zhanshi")
			elseif self.data[i][4] == 2 then
				self.data[i][4] = game.getStrByKey("fashi")
			elseif self.data[i][4] == 3 then
				self.data[i][4] = game.getStrByKey("daoshi")
			end			
			local facjob = t.infos[i].position
			self.data[i][5] = game.getStrByKey(jobStr[facjob])
			local hurt = t.infos[i].hurt
			self.data[i][6] = (hurt >= 10000) and ("" .. math.floor(hurt / 10000) .. game.getStrByKey("task_num")) or hurt
		end
		dump(self.data)

		self:getTableView():reloadData()
	end,
	}
	if switch[msgid] then
		switch[msgid]()
	end
end

return FactionFBNode