local FactionMembersLayer = class("FactionMembersLayer", require ("src/TabViewLayer") )
FactionMembersLayer.reload = nil

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionMembersLayer:ctor(factionData, parentBg, job)
	local msgids = {FACTION_SC_GETALLMEMBER_RET,FACTION_SC_APPOINTPOSITION_RET,
					FACTION_SC_REMOVEMEMBER_RET,FACTION_COMMAND_SC_SET_USERID}
	require("src/MsgHandler").new(self,msgids)

	g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETALLMEMBER, "GetAllFactionMemberInfo", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
    addNetLoading(FACTION_CS_GETALLMEMBER, FACTION_SC_GETALLMEMBER_RET)

	self.data = {}
	self.job = job
	self.factionData = factionData

    self.zhihuiID = G_FACTION_INFO.zhihuiID

    --createSprite(self, "res/common/bg/bg-6.png", cc.p(480, 290), cc.p(0.5, 0.5))

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

	local leftBg = createScale9Frame(
		baseNode,
		"res/common/scalable/panel_outer_base_1.png",
		"res/common/scalable/panel_outer_frame_scale9_1.png",
		cc.p(31, 39),
		cc.size(180, 501),
		4
	)
	self.leftBg = leftBg
	
    local rightBg = createScale9Frame(
		baseNode,
		"res/common/scalable/panel_outer_base_1.png",
		"res/common/scalable/panel_outer_frame_scale9_1.png",
		cc.p(218, 39),
		cc.size(710, 501),
		4
	)
	self.rightBg = rightBg

	local rightBaseNode = cc.Node:create()
	rightBg:addChild(rightBaseNode)
	rightBaseNode:setPosition(cc.p(0, 0))
	self.rightBaseNode = rightBaseNode
	
 	local topBg = CreateListTitle(rightBaseNode, cc.p(rightBg:getContentSize().width/2, 456), 702, 43, cc.p(0.5, 0))
 	local topStr = {
						{text=game.getStrByKey("faction_top_level"), pos=cc.p(340, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_name"), pos=cc.p(160, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_school"), pos=cc.p(270, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_fight"), pos=cc.p(50, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_devote"), pos=cc.p(420, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_job"), pos=cc.p(500, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("state"), pos=cc.p(605, topBg:getContentSize().height/2)},
					}
	self.topStr = topStr
	for i,v in ipairs(topStr) do
		createLabel(topBg, topStr[i].text, topStr[i].pos, cc.p(0.5, 0.5), 22, true)
	end
	createSprite(rightBaseNode, path.."sperate.png", cc.p(rightBg:getContentSize().width/2, 85), cc.p(0.5, 0.5))
	self:createTableView(rightBaseNode, cc.size(700, 365), cc.p(10, 90), true)

	createLabel(self.rightBaseNode, game.getStrByKey("online_number"), cc.p(15, 40), cc.p(0, 0.5), 22, true)
	self.onlineLabel = createLabel(self.rightBaseNode, "0/0", cc.p(122, 40), cc.p(0, 0.5), 22, true)

	local exitYesFunc = function() 
		g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_LEAVEFACTION, "LeaveFaction", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID),name=require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME)})
        g_EventHandler["loaddata"] = nil
	end
	local exitFunc = function()
		local text = string.format(game.getStrByKey("faction_exit_content"), G_FACTION_INFO.facname)
        if self.job == 4 then
            text = string.format(game.getStrByKey("faction_exit_content2"), G_FACTION_INFO.facname)
        end

		MessageBoxYesNo(game.getStrByKey("faction_exit_title"), text, exitYesFunc, nil)
	end
	local exitBtn = createMenuItem(rightBaseNode, "res/component/button/50.png", cc.p(630, 40), exitFunc)
	createLabel(exitBtn, game.getStrByKey("exit_faction"), getCenterPos(exitBtn), nil, 22, true)

	self:addList()
end

function FactionMembersLayer:addList()
	removeFromParent(self.leftSelectNode)

	local textTab = 
	{
		game.getStrByKey("faction_btn_member"),
		--game.getStrByKey("recruit_member")
	}

	if self.job and (self.job > 2) then
		table.insert(textTab, game.getStrByKey("recruit_member"))
	end

	local callback = function(idx)
		log("idx = "..idx)
		if idx == 1 then
			if self.applyLayer then
				removeFromParent(self.applyLayer)
				self.applyLayer = nil
			end
			self.rightBaseNode:setVisible(true)
		elseif idx == 2 then
			self.rightBaseNode:setVisible(false)
		
			if self.applyLayer then
				removeFromParent(self.applyLayer)
				self.applyLayer = nil
			end

			self.applyLayer = require("src/layers/faction/FacApplyListLayer").new(self.factionData, self.rightBg, self)
			self.rightBg:addChild(self.applyLayer)
		end
	end
	self.leftSelectNode = require("src/LeftSelectNode").new(self.leftBg, textTab, cc.size(200, 465), cc.p(2, 30), callback)

	local cell = self.leftSelectNode:getTableView():cellAtIndex(1)
	if cell then
		local button = cell:getChildByTag(10)
		if button then
			self.apply_redPoint = createSprite(button , "res/component/flag/red.png" ,cc.p(button:getContentSize().width - 5 , button:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
			self.apply_redPoint:setLocalZOrder(99)
		    self.apply_redPoint:setVisible(false)
		end
	end
end

function FactionMembersLayer:updateJob()
	self:addList()
end

function FactionMembersLayer:updateMember()
	g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETALLMEMBER, "GetAllFactionMemberInfo", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
    addNetLoading(FACTION_CS_GETALLMEMBER, FACTION_SC_GETALLMEMBER_RET)
end

function FactionMembersLayer:reloadOnlineNum()
	local online = 0
	for k,v in pairs(self.data) do
		if v[8] == 0 then 
			online = online + 1
		end
	end
	self.onlineLabel:setString(""..online.."/"..#self.data)
end

function FactionMembersLayer:reloadData()
	g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETALLMEMBER, "GetAllFactionMemberInfo", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
    FactionMembersLayer.reload = nil
end

function FactionMembersLayer:tableCellTouched(table,cell)
	local data = self.data[cell:getIdx() + 1]
	--dump(data)
	if self:isVisible() then
		local posx,posy = cell:getPosition()
		if self.lastSelect then
			local bgSprite = self.lastSelect:getChildByTag(0)
			if bgSprite then
				--bgSprite:setTexture("res/common/49.png")
			end
		end
		local bgSprite = cell:getChildByTag(0)
		if bgSprite then
			--bgSprite:setTexture("res/common/48.png")
		end
		self.lastSelect = cell

		local basemenus = {	{game.getStrByKey("private_chat"),1},
						{game.getStrByKey("up_job"),2},
						{game.getStrByKey("look_up"),3},
						{game.getStrByKey("president_transfer"),4},
						{game.getStrByKey("make_team"),5},
						{game.getStrByKey("down_job"),6},
						{game.getStrByKey("add_friend"),7},
						{game.getStrByKey("kick_out_faction"),8}}

		local menuFunc = function(index) 

			local switch = {
				[1] = function()    
					PrivateChat(data[3])
				end,
				[2] = function()   
					if data[6] < 3 then 
					  g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_APPOINTPOSITION, "AppointPosition", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID),opRolesSID=data[1],opPosition=data[6]+1})
                    else
						TIPS( { type = 1 , str = game.getStrByKey("faction_promote_tip") }  )
					end
				end,
				[3] = function()    
					LookupInfo(data[3])
				end,
				[4] = function()   
					local callBack = function()
					    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_APPOINTPOSITION, "AppointPosition", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID),opRolesSID=data[1],opPosition=4})
                    end
					MessageBoxYesNo(nil, string.format(game.getStrByKey("faction_change_chairman_tip"), data[3]), callBack, nil, nil, nil)
				end,
				[5] = function()    
					InviteTeamUp(data[3])
				end,
				[6] = function()    
					if data[6] > 1 then 
					    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_APPOINTPOSITION, "AppointPosition", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID),opRolesSID=data[1],opPosition=data[6]-1})
                    else
						TIPS( { type = 1 , str = game.getStrByKey("faction_promote_tip2") }  )
                    end
				end,
				[7] = function()    
					AddFriends(data[3])
				end,
				[8] = function()    
					local callBack = function()
                        g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_REMOVEMEMBER, "RemoveFactionMember", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID),opRoleSID=data[1]})
					end
					MessageBoxYesNo(nil, string.format(game.getStrByKey("faction_remove_menber_tip"), data[3]), callBack, nil, nil, nil)
				end,
                [9] = function()   
                    if G_FACTION_INFO.zhihuiID and data[1] == G_FACTION_INFO.zhihuiID then
                        --解除指挥
                        g_msgHandlerInst:sendNetDataByTableExEx(FACTION_COMMAND_CS_SET_USERID, "FactionCommandSetUserIdProtocol", {memberid="0"})
                    else
                        --任命指挥
                        g_msgHandlerInst:sendNetDataByTableExEx(FACTION_COMMAND_CS_SET_USERID, "FactionCommandSetUserIdProtocol", {memberid=data[1]})                       
                    end
                end,
			}
			log("menuFunc"..index)
		 	if switch[index] then 
		 		switch[index]()
		 	end

		 	removeFromParent(self.operationLayer)
		 	self.operationLayer = nil
		end
		for i,v in ipairs(basemenus)do 
			v[3] = menuFunc
			if v[2] and v[2] == 4 then
				v[4] = true
			end
		end
		local menus = {}
		if self.job and self.job < 3 then
			for k,v in ipairs(basemenus)do
				if k%2 ~= 0 then 
					menus[#menus+1] = v
				end
			end 
		elseif self.job and self.job < 4 then
			menus = basemenus
			menus[8] = nil
		else 
			menus = basemenus
		end

        --指挥者或
        if (self.job and self.job >= 3) or (G_FACTION_INFO.zhihuiID and G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId) then
            local str = game.getStrByKey("faction_add_zhihui")
            if G_FACTION_INFO.zhihuiID and data[1] == G_FACTION_INFO.zhihuiID then
                str = game.getStrByKey("faction_del_zhihui")
            end
        
            menus[#menus+1] = {str, 9, menuFunc}
        end

		local row = 1 
		if #menus > 5 then row = 2 end
		if data[1] ~= userInfo.currRoleStaticId then
			log("data[1]"..data[1].."G_ROLE_MAIN.obj_id "..G_ROLE_MAIN.obj_id )
			local layer = require("src/OperationLayer").new(self,row,menus, "res/component/button/49", "res/common/scalable/7.png")
			self.operationLayer = layer
		end
	end
end

function FactionMembersLayer:cellSizeForTable(table,idx) 
    return 70, 730
end

function FactionMembersLayer:getStrByTime(time)
	if time and time == 0 then 
		return game.getStrByKey("faction_onLine")
	else 
		local span_time = GetTime()-time
		if span_time >= 720*3600 then
			return game.getStrByKey("faction_month")
		elseif span_time >= 168*3600 then 
			return game.getStrByKey("faction_week")
		elseif span_time >= 24*3600 then 
			local day = math.floor(span_time/(24*3600))
			return ""..day..game.getStrByKey("faction_day")
		elseif span_time >= 3600 then 
			local hour = math.floor(span_time/3600)
			return ""..hour..game.getStrByKey("faction_hour")
		elseif span_time >= 60 then 
			local min = math.floor(span_time/60)
			return ""..min..game.getStrByKey("faction_minute")
		else
			if span_time <= 0 then
				span_time = 1
			end
			return ""..span_time..game.getStrByKey("faction_second")
		end
	end
end

function FactionMembersLayer:tableCellAtIndex(table, idx)
	local data = self.data[idx+1]
	if not data then 
		return
	end

    local cell = table:dequeueCell()
    local school_str = {game.getStrByKey("zhanshi"), game.getStrByKey("fashi"), game.getStrByKey("daoshi")}
    local job_str = {game.getStrByKey("lowlife"), game.getStrByKey("the_hall"), game.getStrByKey("deputy_leader"), game.getStrByKey("the_leader")}
    
    local job_tmp = game.getStrByKey("lowlife")
    if data[6] and data[6] < 5 and data[6] > 0 then
        job_tmp = job_str[data[6]]
        if self.zhihuiID and data[1] == self.zhihuiID then
            job_tmp = job_str[data[6]].."-"..game.getStrByKey("faction_name_zhihui")
        end
    end   
    
    local str_tab = {string.format(game.getStrByKey("how_level"),data[2]), data[3], school_str[data[4]], ""..data[7],""..data[9],
    				job_tmp, self:getStrByTime(data[8])} 
    if data[3] and data[8] then 
  		log("factionMembersLayer:name = "..data[3].." lastLoadTimeSec=".. data[8].." lastLoadTime="..formatDateTimeStr(data[8]) .." clientTimeSec="..GetTime().." " .."clientTime="..formatDateTimeStr(GetTime()).. " getStrByTime="..self:getStrByTime(data[8]))
    else
    	log("factionMembersLayer , nil" )
    end  
    local function createCell(cell)
    	local cellBg = createSprite(cell, "res/faction/sel_normal.png", cc.p(0,0), cc.p(0, 0))
        cellBg:setTag(0)
        for i=1,7 do
        	local label = createLabel(cellBg, str_tab[i], cc.p(self.topStr[i].pos.x - 5, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.lable_black)
        	label:setTag(10+i)
        	if data[1] == userInfo.currRoleStaticId then
        		label:setColor(MColor.lable_yellow)
        	end
        end
    end
    if nil == cell then
        cell = cc.TableViewCell:new()   
        createCell(cell)
    else
    	cell:removeAllChildren()	
    	createCell(cell)
    end

    return cell
end

function FactionMembersLayer:numberOfCellsInTableView(table)
   	return #self.data
end

function FactionMembersLayer:sortMember()
   	local onLine = {}
    local offLine = {}
    for i=1, #self.data do
        local d = self.data[i]
        if d[8] == 0 then
            table.insert(onLine, d)
        else
            table.insert(offLine, d)
        end
    end

    self.data = {}
    table.sort( onLine, function( a , b )  return a[2] > b[2] end )
    table.sort( offLine, function( a , b )  return a[2] > b[2] end )

    for i=1, #onLine do
        table.insert(self.data, onLine[i])
    end

    for i=1, #offLine do
        table.insert(self.data, offLine[i])
    end
end

function FactionMembersLayer:networkHander(buff,msgid)
	local switch = {
		[FACTION_SC_GETALLMEMBER_RET] = function()    
			log("get FACTION_SC_GETALLMEMBER_RET"..msgid)
			self.data = {} 
			
            local t = g_msgHandlerInst:convertBufferToTable("GetAllFactionMemberInfoRet", buff) 
            local num =  #t.members
			for i=1,num do 
                local s = t.members[i]
                self.data[i] = {s.memSID, s.lv, s.name, s.job, 0, s.position, s.ability, s.activeState, s.contribution}
				for k,v in ipairs(self.data[i])do 
					log("self.data"..i.."k"..k.."v"..tostring(v))
				end
			end	

            self:sortMember()
			self:getTableView():reloadData()	
			self:reloadOnlineNum()	
		end,
		[FACTION_SC_APPOINTPOSITION_RET] = function()    
			log("get FACTION_SC_APPOINTPOSITION_RET"..msgid)
            local t = g_msgHandlerInst:convertBufferToTable("AppointPositionRet", buff) 
			local data =  {t.rolesSID,t.opRolesSID,t.position,t.opPosition}
			for k,v in ipairs(data)do 
				log("data".."k"..k.."v"..tostring(v))
			end
			for k,v in pairs(self.data)do 
				if v[1] == data[1] then 
					v[6] = data[3]
				elseif v[1] == data[2] then 
					v[6] = data[4]
				end
			end
			if data[1] == userInfo.currRoleStaticId then 
				log("111111111111111111111111111")
				if self.job and self.job ~= data[3] then
					self.job = data[3]
					self.factionData.job = data[3]
					self:updateJob()
				end
			elseif data[2] == userInfo.currRoleStaticId then 
				log("222222222222222222222222222")
				if self.job and self.job ~= data[4] then
					self.job = data[4]
					self.factionData.job = data[4]
					self:updateJob()
				end
			end

            self:sortMember()
			self:getTableView():reloadData()		
		end,
		[FACTION_SC_REMOVEMEMBER_RET] = function()    
			log("get FACTION_SC_REMOVEMEMBER_RET"..msgid)
            local t = g_msgHandlerInst:convertBufferToTable("RemoveFactionMemberRet", buff)
			local data =  {t.opRoleName,t.opRoleSID}
			for k,v in ipairs(data)do 
				log("data".."k"..k.."v"..tostring(v))
			end
			for k,v in pairs(self.data)do 
				if v[1] == data[2] then 
					table.remove(self.data,k)
				end
			end
            self:sortMember()
			self:getTableView():reloadData()
			self:reloadOnlineNum()			
		end,
        [FACTION_COMMAND_SC_SET_USERID] = function()            
            local t = g_msgHandlerInst:convertBufferToTable("FactionCommandSetUserIdRetProtocol", buff)
			self.zhihuiID = t.memberid

            self:getTableView():reloadData()
        end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionMembersLayer