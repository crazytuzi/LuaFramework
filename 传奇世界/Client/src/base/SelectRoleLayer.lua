local SelectRoleLayer = class("SelectRoleLayer",require("src/TabViewLayer"))

function SelectRoleLayer:ctor(cur_mode)
    local isPosNear = function(node)
		local pos = node:getServerTile()
		local rolePos = G_ROLE_MAIN.tile_pos
		return math.max(math.abs(pos.x-rolePos.x),math.abs(pos.y-rolePos.y)) < 16 			
	end
	
	local isShawarHoldName = function(name)
		if G_MAINSCENE.map_layer.mapID ~= 4100 or nil == G_SHAWAR_DATA.holdData or not G_MAINSCENE:checkShaWarState() then 
			return 
		end	

		for i=1, 4 do
			local index =i
			local holdData = G_SHAWAR_DATA.holdData[index] or {}
			if holdData and holdData.HoldName and holdData.HoldName ~= "" and holdData.HoldName == name then
				return true
			end
		end
		return false
	end

	local msgids = {RELATION_SC_GETENEMYNAME_RET}
	local msg_hander =  require("src/MsgHandler")
	msg_hander.new(self,msgids,nil)
	self.dataShow = {}
	self.enemy_tab = {}
	self.friend_tab = {}
	self.select_roleid = 0
	local m_fac_name = MRoleStruct:getAttr(PLAYER_FACTIONID)
	local resetData = function(flag)
		if self.dataShow[self.select_index] then
			self.select_roleid = self.dataShow[self.select_index][1]
		end
		self.dataShow = {}
		if flag == 1 then
            if G_MAINSCENE.map_layer.isStory then
                --获取敌方
                if G_MAINSCENE.storyNode.playerTab and G_MAINSCENE.storyNode.playerTab[2] then
                    local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
                    for k, v in pairs(G_MAINSCENE.storyNode.playerTab[2]) do
                        if v:getHP() > 0 then
                            local targetPos = G_MAINSCENE.map_layer:space2Tile(cc.p(v:getPosition()))
                            if math.abs(myPos.x - targetPos.x) < 10 and math.abs(myPos.y - targetPos.y) < 10 then
                                local record = {}
                                record[1] = v:getTag()
                                record[2] = v:getTheName()
                                record[5] = 8
                                record[6] = 0
                                table.insert(self.dataShow, record)
                            end
                        end
                    end
                end
            else
			    for k,v in pairs(G_MAINSCENE.map_layer.role_tab) do               
                    local role_item = G_MAINSCENE.map_layer:isValidStatus(v) --tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(k), "SpritePlayer")
				    if k ~= G_ROLE_MAIN.obj_id and role_item then
					    local record = {}
					    record[1] = k
					    --print("record[1]",record[1]  )
					    record[2] = role_item:getTheName()
					    --record[3] = role_item:getSchool()
					    --record[4] = role_item:getLevel()
					    record[5] = 8    --排列优先级
					    record[7] = MColor.white  --颜色
				    	local nameNode = role_item:getNameBatchLabel()
					    if nameNode then
						    record[7] = nameNode:getColor()
						end
					    local fac_name = MRoleStruct:getAttr(PLAYER_FACTIONID,k)					    
					    if G_MAINSCENE.map_layer.carry_owner_objid[k] then
						    record[5] = 2
						    record[8] = 2    --图标
						elseif isShawarHoldName(record[2]) then
						    record[5] = 2
						    record[8] = 3
						elseif G_MAINSCENE.map_layer.banner_owner_objid[k] then
							record[5] = 2
						    record[8] = 5
					    elseif self.enemy_tab[record[2]] then
						    record[5] = 3
						    record[8] = 4
					    else
						    if theSameColor(record[7], MColor.name_orange) then
							    record[5] = 5
						    elseif  theSameColor(record[7], MColor.name_green) then
							    record[5] = 6
						    elseif theSameColor(record[7], MColor.name_blue) then
							    record[5] = 7
						    end
						    if fac_name == m_fac_name and m_fac_name > 0 then
							    record[5] = 9
						    end
					    end
					    record[6] = 0
					    --if isPosNear(role_item) then
						    --table.insert(self.dataShow, record)
					    --end
					    --print("getGameSetById(GAME_SET_HIDEGUILDSPLAYER)",getGameSetById(GAME_SET_HIDETEAMPLAYER),self:isCanAttack(1,k),record[2])
					    if (fac_name == m_fac_name and m_fac_name > 0) then
						    record[6] = 1
					    end
					    if (not self:isCanAttack(1,k)) then
						    record[6] = record[6]+2
					    end
					    if getGameSetById(GAME_SET_HIDEGUILDSPLAYER) == 1 and (fac_name == m_fac_name and m_fac_name > 0) then
					    elseif getGameSetById(GAME_SET_HIDETEAMPLAYER) == 1 and (not self:isCanAttack(1,k)) then
					    elseif getGameSetById(GAME_SET_HIDEALLIANCEPLAYER) == 1 and (not self:isCanAttack(2,k)) then
					    elseif getGameSetById(GAME_SET_HIDEFRIEND) == 1 and (self.friend_tab[record[2]]) then
					    elseif role_item:isVisible() then
						    table.insert(self.dataShow, record)
					    end
				    end
			    end
			    for k,v in pairs(G_MAINSCENE.map_layer.monster_tab) do
				    local role_item = G_MAINSCENE.map_layer:isValidStatus(v)  --tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(k), "SpriteMonster")
				    if role_item then
					    local m_type = role_item:getType()
					    if m_type >= 11 and role_item:getLevel() < 99 and role_item:isVisible() then
						    local protoId = role_item:getMonsterId()
						    if protoId < 90000 then 
							    local owen_name =  MRoleStruct:getAttr(ROLE_HOST_NAME,k)
							    if not owen_name then
								    local record = {}
								    record[1] = k
								    record[2] = role_item:getTheName()
								    --record[3] = role_item:getType()
								    --record[4] = role_item:getLevel()
								    record[5] = 0
								    record[8] = 0
								    if m_type == 11 then
									    record[5] = 1
									    record[8] = 1
								    end
								    --if isPosNear(role_item)  then
									    table.insert(self.dataShow,record)
								    --end
							    end
						    end
					    end 
				    end
			    end
			    local sortFunc = function(a , b )
				    return a[5] < b[5] or (a[5] == b[5] and a[1] > b[1])
			    end
			    table.sort(self.dataShow, sortFunc )
            end
		else
			for k,v in pairs(G_MAINSCENE.map_layer.monster_tab) do
				local role_item = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(k), "SpriteMonster")
				if role_item then
					local protoId = role_item:getMonsterId()
					if protoId < 90000  then
						local record = {}
						record[1] = k
						record[2] = role_item:getTheName()
						--record[3] = role_item:getType()
						--record[4] = role_item:getLevel()
						if record[3] ~= 10 then--and isPosNear(role_item)  then
							table.insert(self.dataShow, record)
						end
					end 
				end
			end
		end

		for k,v in pairs(self.dataShow)do
			if self.select_roleid == v[1] then
				self.select_index = k
			end
		end
		if (self.old_num ~= 0 and self.old_num ~= #self.dataShow) or self.old_num == 0 then	
			self.old_num = #self.dataShow		
			local height = self.old_num*40
			if  self.old_num <= 1 then height = 80 end
			if height > 300 then height = 280 end
			if self.bg then self.bg:setContentSize(cc.size(210,height+10)) end
			if self.m_tabView then
				self.m_tabView:setViewSize(cc.size(210, height))
				self.offset = self:getTableView():getContentOffset()
				self:getTableView():reloadData()
				if self.offset and (not(self.offset.y == 0 and self.old_num < 3)) then
					self:getTableView():setContentOffset(self.offset)
				end
				self.m_tabView:_updateContentSize()
				if self.selectedRect then
					local cell = self.m_tabView:cellAtIndex(self.select_index-1)
					if cell then
						local x, y = cell:getPosition()
						self.selectedRect:setPosition(cc.p(x, y))
					end
				end
			end			
		end
	end

	self.reloadFunc = resetData
	self.old_num = 0
	self.select_index = 1
	if tablenums(self.enemy_tab) == 0 then 
		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETENEMYNAME, "GetEnemyNameProtocol", {relationType = 1})
		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETENEMYNAME, "GetEnemyNameProtocol", {relationType = 2})
	else
		resetData(1)
	end
	local height = self.old_num*40
	local schedule_time = 2
	if height > 300 then 
		height = 280 
	end
	if  self.old_num <= 1 then height = 80 end
	self.bg = createScale9Sprite(self,"res/common/scalable/8.png",cc.p(0,0),cc.size(210,height+10),cc.p(0.5,0.0))
    --self:initTouch() 
	self.bg:setScale(0.01)
    self.bg:runAction(cc.ScaleTo:create(0.15, 1))
	self:createTableView(self.bg ,cc.size(210, height+10), cc.p(0, 5), true)
	self:getTableView():setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
	self:getTableView():setContentOffset(cc.p(0,0))
	--local allow_strs = {game.getStrByKey("set_hide_monster"),game.getStrByKey("set_hide_player")}
	-- local changeSelect = function(change) 
	-- 	G_MAINSCENE.map_layer.hide_monster = not G_MAINSCENE.map_layer.hide_monster
	-- 	self.allow_spr:setVisible( G_MAINSCENE.map_layer.hide_monster)
	-- 	G_MAINSCENE.map_layer:setShowNormalMonster()
	-- end

	-- createTouchItem(self.bg,"res/component/checkbox/1.png",cc.p(150,25),changeSelect)
	-- self.allow_spr = createSprite(self.bg,"res/component/checkbox/1-1.png",cc.p(150,25))
	-- self.alllow_str = createLabel(self.bg, game.getStrByKey("set_hide_monster"),cc.p(120,25), cc.p(1.0,0.5), 18, 1.0, 1, nil)
	-- self.allow_spr:setVisible(not not G_MAINSCENE.map_layer.hide_monster)

	--creatTabControlMenu(self.bg,tab_control,1)
	--menuFunc(1)
	-- local closeFunc = function()
	-- 	self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 0.0), cc.CallFunc:create(function() removeFromParent(self) end)))	
	-- end
	-- registerOutsideCloseFunc(self.bg, closeFunc)
	self.update_time = 0
	self:initTouch() 
	local updateData = function()
		self.update_time = self.update_time + 1
		if self.update_time < 6 or self.update_time%2 == 0 then
			resetData(1)
		end
	end
	updateData()
	schedule(self, updateData, schedule_time)
	self:registerScriptHandler(function(event)
		if event == "enter" then  
			if G_MAINSCENE and G_MAINSCENE.operate_node and not G_MAINSCENE.map_layer.isStory then
				G_MAINSCENE.operate_node:setLocalZOrder(199)
			end
		elseif event == "exit" then
			if G_MAINSCENE and G_MAINSCENE.operate_node and not G_MAINSCENE.map_layer.isStory then
				G_MAINSCENE.operate_node:setLocalZOrder(6)
			end
		end
	end)
end

function SelectRoleLayer:initTouch() 
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    	local pt = self:convertTouchToNodeSpace(touch)
		if cc.rectContainsPoint(self.bg:getBoundingBox(), pt) then
    		return true
    	else
    		if pt.x > 0 and pt.x < 60 and pt.y < 0  then
    			AudioEnginer.playTouchPointEffect()	
    			performWithDelay(self,function() removeFromParent(self) end,0)
    			return true
    		else
                -- 移除多次点击的声音
	    		--AudioEnginer.playTouchPointEffect()	
	    		removeFromParent(self)
	    	end

    	end
    	return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
        listenner:registerScriptHandler(function(touch, event) 	
        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self.bg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self.bg)

end


function SelectRoleLayer:tableCellTouched(table, cell)
	local x, y = cell:getPosition()
	if self.selectedRect == nil then
		self.selectedRect = createScale9Sprite(table, "res/common/scalable/selected.png", cc.p(0, 0), cc.size(200, 40), cc.p(0, 0.0), nil, nil, 2)
	end
	self.selectedRect:setPosition(cc.p(x, y))
	local index = cell:getIdx() + 1
	self.select_index = index
	local role_item = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(self.dataShow[index][1]), "SpriteMonster")
	if role_item then
		if role_item:getType() >= 20 then
			G_MAINSCENE.map_layer:touchRoleFunc(role_item)
		else
			G_MAINSCENE.map_layer:touchMonsterFunc(role_item)
		end
	end
	self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08, 0.0), cc.CallFunc:create(function() removeFromParent(self) end)))	
end

function SelectRoleLayer:cellSizeForTable(table, idx) 
    return 40, 200
end

function SelectRoleLayer:tableCellAtIndex(table, idx)
	local paddingLeft = 30
	local width = 500
	--dump(self.dataShow)
	-- local getNameColor = function(objId)
	-- 	--print("getNameColor ")
	-- 	local defaultColor = MColor.white
	-- 	local role = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(objId), "SpriteMonster")
	-- 	local nameNode
	-- 	if role then
	-- 	    nameNode = role:getNameLabel():getChildByTag(10)
	-- 	end
	-- 	if nameNode then
	-- 		defaultColor = nameNode:getColor() or defaultColor
	-- 	end
	-- 	return defaultColor
	-- end

	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()  
    else
    	cell:removeAllChildren()
    end
	local color = self.dataShow[idx+1][7]
	createLabel(cell, self.dataShow[idx+1][2], cc.p(40, 20), cc.p(0.0, 0.5), 20, nil, nil, nil, color)
	if self.dataShow[idx+1][8] then
		createSprite(cell,"res/layers/friend/status"..self.dataShow[idx+1][8]..".png",cc.p(5,20),cc.p(0.0,0.5))
	end
	--同会，同组
	if self.dataShow[idx+1][6] and self.dataShow[idx+1][6] > 0 then
		if self.dataShow[idx+1][6] == 3 then
			--createSprite(cell,"res/layers/friend/status9.png",cc.p(160,20),cc.p(0.0,0.0))
			createSprite(cell,"res/layers/friend/status10.png",cc.p(165,20),cc.p(0.0,0.5))
		else
			createSprite(cell,"res/layers/friend/status"..(self.dataShow[idx+1][6]+8)..".png",cc.p(165,20),cc.p(0.0,0.5))
		end
	end
    return cell
end

function SelectRoleLayer:numberOfCellsInTableView(table)
   	return #self.dataShow
end

function SelectRoleLayer:networkHander(buff,msgid)
	if msgid == RELATION_SC_GETENEMYNAME_RET then
		--local enemyData = {}
		local t = g_msgHandlerInst:convertBufferToTable("GetEnemyNameRetProtocol", buff) 
		local relationType = t.relationType
		if relationType == 1 then
			for i,v in ipairs(t.name) do
				self.friend_tab[v] = true
			end			
		elseif relationType == 2 then
			for i,v in ipairs(t.name) do
				self.enemy_tab[v] = true
			end
		end
		self.old_num = 0
		--SelectRoleLayer.enemy_tab = enemyData
		self.reloadFunc(1)		
	end
end

function SelectRoleLayer:isCanAttack(pkmode,tag,isadd,is_sort)
	if G_MAINSCENE.map_layer.isStory then
        local node = G_MAINSCENE.map_layer.item_Node:getChildByTag(tag)
        return G_MAINSCENE.storyNode:isMonster(node)
    end
    
    local isTeamMeb = function(o_id)
		local is_team_meb = false
		local role_node = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(o_id),"SpritePlayer")
		if G_TEAM_INFO and G_TEAM_INFO.team_data and G_TEAM_INFO.has_team and G_TEAM_INFO.memCnt and G_TEAM_INFO.memCnt > 0 then
			for k,v in pairs(G_TEAM_INFO.team_data)do
				if k <= G_TEAM_INFO.memCnt and v.name == role_node:getTheName() then
					is_team_meb = true
					break
				end
			end
		end
		if not is_team_meb and G_MAINSCENE.map_layer.mapID == 5003 then
			local teamID = MRoleStruct:getAttr(PLAYER_TEAMID, tag)
			local myTeamID = MRoleStruct:getAttr(PLAYER_TEAMID)
			if myTeamID ~= nil and myTeamID ~= 0 and teamID ~= nil and teamID ~= 0 and teamID == myTeamID then
				is_team_meb = true
			end
		end
		return is_team_meb
	end

	local hasTheBuffById = function(obj_id,buff_id)
		local buffs = g_buffs_ex[obj_id]
	    if buffs == nil or buffs[buff_id] == nil then
	      return false
	    else
	      return true
	    end
	end
	local can_attack,is_wudi_buff = false,nil
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
		local tar_camp_id = MRoleStruct:getAttr(PLAYER_TEAMID,tag)
		local my_camp_id = MRoleStruct:getAttr(PLAYER_TEAMID)
		if my_camp_id and tar_camp_id then
			if tar_camp_id == my_camp_id and (not isadd) then
				return false
			elseif isadd and my_camp_id ~= tar_camp_id then
				return false
			end
		end
	end
	if pkmode == 0 then
	elseif hasTheBuffById(tag,16) then
		is_wudi_buff = true
		if not is_sort then
			return can_attack,is_wudi_buff
		end
	elseif pkmode == 1 then
		can_attack = tag ~= G_ROLE_MAIN.obj_id and (not isTeamMeb(tag)) 
	elseif pkmode == 2 then
		local my_fac_id = MRoleStruct:getAttr(PLAYER_FACTIONID)
		local ally_fac_list = {}
		if my_fac_id then
			ally_fac_list[#ally_fac_list+1] = my_fac_id
		end
		if G_FACTION_INFO.ally_fac_list then
			for k,v in pairs(G_FACTION_INFO.ally_fac_list)do
				ally_fac_list[#ally_fac_list+1] = v
			end
		end
		if tag ~= G_ROLE_MAIN.obj_id then
			local fac_id = MRoleStruct:getAttr(PLAYER_FACTIONID,tag)
			local getCanAttack = function(m_fac_id)
				local temp_can_attack = false
				if isadd then
					temp_can_attack = (not (m_fac_id and fac_id and (fac_id>0))) or (not (fac_id == m_fac_id))
				else
					temp_can_attack = not(m_fac_id and fac_id and (fac_id>0) and (fac_id == m_fac_id)) 
				end
				return temp_can_attack
			end
			for k,v in pairs(ally_fac_list)do
				can_attack = getCanAttack(v)
				if (can_attack and isadd) or ((not can_attack) and (not isadd)) then
					break
				end
			end
		end
	elseif pkmode == 3 then
		can_attack = (tag ~= G_ROLE_MAIN.obj_id)
	elseif pkmode == 4 then
		local rolePk = MRoleStruct:getAttr(PLAYER_PK, tag) or 0
		can_attack = (tag ~= G_ROLE_MAIN.obj_id) and (rolePk >= 4 or hasTheBuffById(tag,24))
	elseif pkmode == 5 then
		local role_node = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(tag),"SpritePlayer")
		if role_node then
			local nameNode = role_node:getNameBatchLabel()
			if nameNode then
				local color = nameNode:getColor()
				can_attack = (tag ~= G_ROLE_MAIN.obj_id and theSameColor(color, MColor.name_orange))
				if isadd then
					can_attack = not can_attack
				end
			end
		end
	end	
	return can_attack
end

function SelectRoleLayer:isCanAttackMonster(pkmode,tag,isadd,is_sort)
	if pkmode == 0 then
		local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,tag)
		if owner_name then
			return false
		end
	elseif pkmode == 1 then
		if G_MAINSCENE.map_layer.mapID == 5003 then
			local teamID = MRoleStruct:getAttr(PLAYER_TEAMID, tag)
			local myTeamID = MRoleStruct:getAttr(PLAYER_TEAMID)
			if myTeamID ~= nil and myTeamID ~= 0 and teamID ~= nil and teamID ~= 0 and teamID == myTeamID then
				return false
			end
		end
	end
	return true
end

return SelectRoleLayer