local AddFriendLayer = class("AddFriendLayer", require ("src/TabViewLayer") )

function AddFriendLayer:ctor(parentBg, parent)
	local msgids = {RELATION_SC_RECOMMEND_FRIEND_RET,RELATION_SC_ADDRELATION_RET}
	require("src/MsgHandler").new(self,msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_RECOMMEND_FRIEND,"i",G_ROLE_MAIN.obj_id)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_RECOMMEND_FRIEND, "RecommendFriendProtocol", {})
	
	self.load_data = {}
	self.parent = parent

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("add_friend"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 24, true)
	local contentBg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() self:removeFromParent() end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)
	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_SOCIAL_ADD_FIREND_CLOSE)

	createLabel(contentBg, game.getStrByKey("add_friend_by_name"), cc.p(40, 410), cc.p(0, 0), 22, true, nil, nil, MColor.lable_black)
	local editeBoxBg = createScale9Sprite(contentBg, "res/common/scalable/input_1.png", cc.p(40, 380), cc.size(275, 48), cc.p(0, 0.5))
	local editBox = createEditBox(editeBoxBg, nil, getCenterPos(editeBoxBg), cc.size(275, 34), MColor.white)
	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	editBox:setPlaceHolder(game.getStrByKey("faction_input"))

	local addBtnFunc = function() 
		local name_str = editBox:getText()
    	if string.len(name_str) > 0 then
    		--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION, "iccS", G_ROLE_MAIN.obj_id, 1, 1, name_str)
    		AddFriendsEx(name_str)
		end
	end
	local addBtn = createMenuItem(contentBg, "res/component/button/50.png", cc.p(400, 380), addBtnFunc)
	createLabel(addBtn, game.getStrByKey("add"), getCenterPos(addBtn), cc.p(0.5, 0.5), 22, true)
  
	createLabel(contentBg, game.getStrByKey("add_friend_by_system"), cc.p(40, 320), cc.p(0, 0), 22, true, nil, nil, MColor.lable_black)
	local oneKeyBtnFunc = function(sender) 
		local args = {}
		local name_num = #self.load_data
    	if name_num > 0 then
			-- local fat_str = "icc"
			-- --if name_num > 5 then name_num = 4 end
			-- for i=1,name_num do 
			-- 	fat_str = fat_str .. "S"
			-- 	args[i] = self.load_data[i][1]
			-- end

			-- g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,fat_str,G_ROLE_MAIN.obj_id,1,name_num,args[1],
			-- 		args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11],args[12],args[13],args[14],args[15])
			local t = {}
			t.relationKind = 1
			t.targetName = {}
			for i,v in ipairs(self.load_data) do
				table.insert(t.targetName, self.load_data[i][1])	
			end
			dump(t)
			g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
		end

		startTimerAction(self, 0.3, false, function() self.oneKeyBtn:setEnabled(false) end)
	end	
	local oneKeyBtn = createMenuItem(contentBg, "res/component/button/50.png", cc.p(contentBg:getContentSize().width/2, 35), oneKeyBtnFunc)
	self.oneKeyBtn = oneKeyBtn
	G_TUTO_NODE:setTouchNode(oneKeyBtn, TOUCH_SOCIAL_ADD_FIREND_QUICK)
	createLabel(oneKeyBtn, game.getStrByKey("add_all"), getCenterPos(oneKeyBtn), cc.p(0.5, 0.5), 22, true)

	createSprite(contentBg, "res/common/bg/bg-1.png", cc.p(contentBg:getContentSize().width/2, 78), cc.p(0.5, 0.5))
    self:createTableView(contentBg, cc.size(730, 230), cc.p(40, 85), true)

    SwallowTouches(self)
    registerOutsideCloseFunc(bg, closeFunc)
end

function AddFriendLayer:tableCellTouched(table,cell)

end

function AddFriendLayer:cellSizeForTable(table,idx) 
    return 65, 730
end

function AddFriendLayer:tableCellAtIndex(table, idx)
	local data = self.load_data[idx+1]
	if not data then 
		return
	end
    local cell = table:dequeueCell()
    local zhiye_str = {game.getStrByKey("zhanshi"),game.getStrByKey("fashi"),game.getStrByKey("daoshi")}
    local xingbie = {game.getStrByKey("man"),game.getStrByKey("female")}
    local str_tab = {data[1],xingbie[data[2]],string.format(game.getStrByKey("how_level"),data[3]),zhiye_str[data[4]]}

    local addBtnFunc = function() 
    	if G_ROLE_MAIN and G_ROLE_MAIN.obj_id then
			--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,"iccS",G_ROLE_MAIN.obj_id,1,1,data[1])
			local t = {}
			t.relationKind = 1
			t.targetName = {data[1]}
			g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
		end
	end

	local function createCellContent(cell)
		local cellBg = createSprite(cell, "res/common/table/cell12.png", cc.p(0, 0), cc.p(0, 0))
		local posX = {30, 215, 300, 400, 500}
		local posY = cellBg:getContentSize().height/2
		for i=1,4 do
        	createLabel(cell, str_tab[i], cc.p(posX[i], posY), cc.p(0, 0.5), 22, true, nil, nil, MColor.lable_black)
        end
        local addBtn = createMenuItem(cellBg, "res/component/button/50.png", cc.p(655, posY), addBtnFunc)
        addBtn:setScale(0.9)
        createLabel(addBtn, game.getStrByKey("addas_friend"), getCenterPos(addBtn), cc.p(0.5, 0.5), 22, true)
	end

	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
		createCellContent(cell)
	else
		cell:removeAllChildren()
		createCellContent(cell)  
	end

    return cell
end

function AddFriendLayer:numberOfCellsInTableView(table)
   	return #self.load_data
end

function AddFriendLayer:networkHander(buff,msgid)
	local switch = {
		[RELATION_SC_ADDRELATION_RET] = function() 
			log("get RELATION_SC_ADDRELATION_RET"..msgid)  
			local t = g_msgHandlerInst:convertBufferToTable("AddRelationRetProtocol", buff)  
			local e_code = t.errId
			local name = t.targetName
			log("e_code,name"..e_code..name)
			if e_code >= 0 then 
				local is_loaddata = nil
				for k,v in pairs(self.load_data)do 
					if name == v[1] then 
						is_loaddata = true
						table.remove(self.load_data,k)
						break
					end
				end
				--require("src/layers/friend/MyFriendsLayer").reload = true
				log("is_loaddata = "..tostring(is_loaddata))
				if is_loaddata then
					self:getTableView():reloadData()
					-- if #self.load_data < 5 then 
					-- 	g_msgHandlerInst:sendNetDataByFmt(RELATION_CS_RECOMMEND_FRIEND,"i",G_ROLE_MAIN.obj_id)
					-- end
				end

				if self.parent and self.parent.reloadNetData then
					if self.reloadNetDataAction then
						self:stopAction(self.reloadNetDataAction)
						self.reloadNetDataAction = nil
					end

					self.reloadNetDataAction = startTimerAction(self, 0.3, false, function() self.parent:reloadNetData() end)
				end
			end
		end,
		[RELATION_SC_RECOMMEND_FRIEND_RET] = function() 
			log("get RELATION_SC_RECOMMEND_FRIEND_RET"..msgid) 
			local t = g_msgHandlerInst:convertBufferToTable("RecommendFriendRetProtocol", buff) 
			-- local num = buff:readByFmt("c")
			-- log("num = "..num)
			-- self.load_data = {}
			-- for i=1,num do 
			-- 	self.load_data[i]= {buff:readByFmt("Scccc")}
			-- end
			dump(t)
			dump(t.roleData)

			for i,v in ipairs(t.roleData) do
				-- dump(v)
				-- dump(i)
				-- dump(v.name)
				-- dump(v.sex)
				-- dump(v.level)
				-- dump(v.school)
				self.load_data[i] = {}
				self.load_data[i][1] = v.name
				self.load_data[i][2] = v.sex
				self.load_data[i][3] = v.level
				self.load_data[i][4] = v.school
				dump(i)
			end
			dump(#self.load_data)
			if #self.load_data > 0 then
				self.oneKeyBtn:setEnabled(true)
			else
				self.oneKeyBtn:setEnabled(false)
			end

			self:getTableView():reloadData()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return AddFriendLayer