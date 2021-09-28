local inviteJoin = class("inviteJoin",require("src/TabViewLayer"))

function inviteJoin:ctor(parent)
	self.itemData = {}
	--createSprite(self, "res/common/bg/bg.png", cc.p(480, 285), cc.p(0.5 , 0.5))
	--createSprite(self,"res/common/bg/bg-6.png",cc.p(480,285))
	-- createSprite(self,"res/common/bg/bg-7.png",cc.p(480,328))
	self.tipLab = nil
	local leftbg = cc.Sprite:create("res/common/scalable/panel_outer_base_1.png",cc.rect(0,0,180,465))
	leftbg:setAnchorPoint(cc.p(0,1))
	leftbg:setPosition(cc.p(32,500))
	leftbg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
	self:addChild(leftbg)	
	createScale9Sprite(self, "res/common/scalable/panel_outer_frame_scale9_1.png", cc.p(32,500), cc.size(180, 465), cc.p(0, 1))
	local rightbg = cc.Sprite:create("res/common/scalable/panel_outer_base_1.png",cc.rect(0,0,708,465))
	rightbg:setAnchorPoint(cc.p(1,1))
	rightbg:setPosition(cc.p(928,500))
	rightbg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
	self:addChild(rightbg)
	self.rightbg = rightbg
	createScale9Sprite(self, "res/common/scalable/panel_outer_frame_scale9_1.png", cc.p(928,500), cc.size(708, 465), cc.p(1,1))

	CreateListTitle(rightbg, cc.p(3, 440), 702, 43, cc.p(0, 0.5))
	local abc = {{game.getStrByKey("show_flowers3"),cc.p(80, 440)},{game.getStrByKey("level"), cc.p(190, 440)},
	{game.getStrByKey("combat_power"), cc.p(316, 440)},{game.getStrByKey("school"), cc.p(440, 440)},
	{game.getStrByKey("faction_top_faction_action"), cc.p(580, 440)}}

	for i=1,#abc do
    	createLabel(rightbg,abc[i][1] ,abc[i][2] , cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    end

    if G_TEAM_ATUOTURN and G_TEAM_ATUOTURN[1] then 
		createTouchItem(self,"res/component/checkbox/1.png",cc.p(432,520),function() self:changeSelect(4) end)
		self.allow_spr2 = createSprite(self,"res/component/checkbox/1-1.png",cc.p(432,520))
		print(getLocalRecord("autoTeam"),"getLocalRecord(autoTeam)555555555555555555555555555")
		self.allow_spr2:setVisible(getLocalRecord("autoTeam"))
		createLabel(self, game.getStrByKey("team_autoIn"),cc.p(462,520), cc.p(0,0.5), 18, true, 1, nil,MColor.lable_black)
	end

    createTouchItem(self,"res/component/checkbox/1.png",cc.p(577,520),function() self:changeSelect(1) end)
	self.allow_spr = createSprite(self,"res/component/checkbox/1-1.png",cc.p(577,520))
	self.allow_spr:setVisible(getGameSetById(GAME_SET_TEAM_IN) == 1)
	createLabel(self, game.getStrByKey("team_autoInvite"),cc.p(607,520), cc.p(0,0.5), 18, true, 1, nil,MColor.lable_black)

	createTouchItem(self,"res/component/checkbox/1.png",cc.p(762,520),function() self:changeSelect(2) end)
	self.allow_spr1 = createSprite(self,"res/component/checkbox/1-1.png",cc.p(762,520))
	self.allow_spr1:setVisible(getGameSetById(GAME_SET_TEAM) == 1)
	createLabel(self, game.getStrByKey("team_allowTeam"),cc.p(792,520), cc.p(0,0.5), 18, true, 1, nil,MColor.lable_black)

	self:createTableView(self, cc.size(704, 414), cc.p(223, 38), true,true)

    self.title_select_idx = 1
    self:send()
    local callback = function(idx)
    	self.title_select_idx = idx
    	self:send()
    	-- self:getTableView():reloadData()
  	end
    local tab = {game.getStrByKey("team_nearPlayer"),game.getStrByKey("team_myF"),game.getStrByKey("faction_member")}
	require("src/LeftSelectNode").new(self,tab,cc.size(200,458),cc.p(35,38),callback,nil,nil,self.title_select_idx-1)

	-- self:createTableView(self, cc.size(704, 414), cc.p(223, 38), true,true)
	local num = G_TEAM_INFO.has_team and 10 or 0
	local n = num == 0 and 0 or (G_TEAM_INFO.memCnt or 0)
	self.team_tip1 = createLabel(self,game.getStrByKey("team_memNum"),cc.p(32,520),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
	self.team_tip2 = createLabel(self,tostring(n).."/"..tostring(num),cc.p(170,520),cc.p(0,0.5),20,true,nil,nil,MColor.white)
end

function inviteJoin:send()
	if self.title_select_idx == 1 then
		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_AOUNDPLAYER, "TeamGetAroundPlayerProtocol", {aroundType = 2})
	else
		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_SPE_ROLE, "TeamGetSpeRole", {speType = self.title_select_idx-1})
	end

	g_msgHandlerInst:registerMsgHandler(TEAM_SC_GET_AOUNDPLAYER_RET,function(buff)	
		if self then
		 	self:onAroundPlayer(buff) 
		end
	end)
	g_msgHandlerInst:registerMsgHandler(TEAM_SC_GET_SPE_ROLE_RET,function(buff)	
		if self then	
		 	self:onAround(buff) 
		end
	end)

end

function inviteJoin:onAroundPlayer(buff)
	local t = g_msgHandlerInst:convertBufferToTable("TeamGetArroundPlayerRetProtocol", buff)
	local type1 = t.aroundType
	if type1 == 2 then
		self.itemData = {}
		local noTeamCnt = t.noTeamCnt
		for i=1, noTeamCnt do
			self.itemData[i] = {t.noTeaminfos[i].roleSID,t.noTeaminfos[i].sex,t.noTeaminfos[i].school,t.noTeaminfos[i].level,t.noTeaminfos[i].battle,t.noTeaminfos[i].name,t.noTeaminfos[i].factionName}
		end
	end
	self:reloadData()
end

function inviteJoin:onAround(buff)
	local t = g_msgHandlerInst:convertBufferToTable("TeamGetSpeRoleRet", buff)
	local speType = t.speType
	local speInfo = t.speInfo
	self.itemData = {}
	-- for i=1,#speInfo do
	-- 	self.itemData[i] = {t.speInfo[i].roleSID,t.speInfo[i].sex,t.speInfo[i].school,t.speInfo[i].level,t.speInfo[i].battle,t.speInfo[i].name,t.speInfo[i].factionName}
	-- end
	local i,j = 1,1
	while j <= #speInfo do
		if speInfo[j].roleSID and speInfo[j].roleSID == userInfo.currRoleStaticId then			
		else
			self.itemData[i] = {speInfo[j].roleSID,speInfo[j].sex,speInfo[j].school,speInfo[j].level,speInfo[j].battle,speInfo[j].name,speInfo[j].factionName,speInfo[i].teamID}					
			i = i+1
		end
		j = j + 1
	end
	table.sort( self.itemData, function(a, b) return a[8] < b[8] end)
	self:reloadData()
end

function inviteJoin:changeSelect(chooseOne)
	if self.allow_spr and self.allow_spr1 and chooseOne then
		if chooseOne == 1 then
			local isVisible = self.allow_spr:isVisible()
			self.allow_spr:setVisible(not isVisible)
			setGameSetById(GAME_SET_TEAM_IN,not isVisible and 1 or 0)
			g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_AUTOINVITE, "TeamChangeAutoInviteProtocol", { ["inviteValue"] = not isVisible and 2 or 1 ,["inviteType"] = 1 })
		elseif chooseOne == 2 then
			local isVisible = self.allow_spr1:isVisible()
			self.allow_spr1:setVisible(not isVisible)
			setGameSetById(GAME_SET_TEAM,not isVisible and 1 or 0)
			g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_AUTOINVITE, "TeamChangeAutoInviteProtocol", { ["inviteValue"] = not isVisible and 2 or 1 ,["inviteType"] = 2 })
		elseif chooseOne == 4 then
			local autoTeamSta = getLocalRecord("autoTeam") 
			local fun = function(checkIsField)
				if checkIsField and G_MAINSCENE.mapId then
					local field = getConfigItemByKey("MapInfo","q_map_id",G_MAINSCENE.mapId,"q_sjlevel")
					local isOutField = string.find(tostring(field),"2") 
					if isOutField then
						g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_FAST_ENTER, "TeamFastEnter", {["enterType"] = 2})
					end
				end
				setLocalRecord("autoTeam",not autoTeamSta)
				self.allow_spr2:setVisible(not autoTeamSta)
			end			
			if not autoTeamSta then
				MessageBoxYesNo(nil, game.getStrByKey("team_tip5"), function() fun(true) end  )
			else
				fun()
			end
		end
	end
	self:reloadData()
end

function inviteJoin:reloadData()
	if self.tipLab then
		removeFromParent(self.tipLab)
		self.tipLab = nil
	end
	if table.nums(self.itemData) <= 0 then		
		self.tipLab = createLabel(self.rightbg,game.getStrByKey("team_tip10"),cc.p(347,225),nil,22,true,nil,nil,MColor.white)
	end
	self:getTableView():reloadData()
end

function inviteJoin:invite(name)
	if G_TEAM_INFO  and G_TEAM_INFO.has_team and G_TEAM_INFO.memCnt and G_TEAM_INFO.memCnt > 10 then
		TIPS( { type = 1 , str = game.getStrByKey( "teamup_tips2" ) } )
		return
	end
	InviteTeamUp(name )
end

function inviteJoin:tableCellTouched( table,cell )
	
end

function inviteJoin:tableCellAtIndex( table,idx )
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
    else
    	cell:removeAllChildren()
    end
    local str1 = {game.getStrByKey("zhanshi"),game.getStrByKey("fashi"),game.getStrByKey("daoshi")}
    local spr = createSprite(cell, "res/common/table/cell21.png", cc.p(0, 1), cc.p(0, 0))  

    createLabel(spr,self.itemData[idx+1][6],cc.p(41,35),cc.p(0,0.5),22,true,nil,nil,MColor.white)
    createLabel(spr,tostring(self.itemData[idx+1][4]),cc.p(186,35),nil,22,true,nil,nil,MColor.white)
    createLabel(spr,tostring(self.itemData[idx+1][5]),cc.p(312,35),nil,22,true,nil,nil,MColor.white)
    createLabel(spr,str1[self.itemData[idx+1][3]],cc.p(438,35),nil,22,true,nil,nil,MColor.white)
    local applyBtn = createMenuItem(cell,"res/component/button/50.png", cc.p( 600 , 35 ),function() self:invite(self.itemData[idx+1][6]) end)
	createLabel(applyBtn,game.getStrByKey("invite_join"),cc.p(69,29),nil,24,true)
	if self.title_select_idx ~= 1 then
		if self.itemData[idx+1][8] and self.itemData[idx+1][8] > 0 then
	    	applyBtn:setEnabled(false)    	
	    else
	    	applyBtn:setEnabled(true)
	    	createSprite(spr,"res/teamup/canInvite.png",cc.p(36,35),cc.p(1,0.5))
	    end
	end
    return cell
end

function inviteJoin:cellSizeForTable( table, idx )
	return 70,490
end

function inviteJoin:numberOfCellsInTableView( table )
	return #self.itemData
end



return inviteJoin