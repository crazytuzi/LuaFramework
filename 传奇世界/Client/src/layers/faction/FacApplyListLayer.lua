local FacApplyListLayer = class("FacApplyListLayer", require ("src/TabViewLayer") )

local path = "res/faction/"
local pathCommon = "res/common/"

function FacApplyListLayer:ctor(factionData, bg, memberLayer)
	local msgids = {FACTION_SC_GETAPPLYINFO_RET, FACTION_SC_AGREE_JOIN_RET, FACTION_SC_REFUSE_APPLY_RET}
	require("src/MsgHandler").new(self,msgids)
	g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETAPPLYINFO, "GetApplyFactionInfo", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
    addNetLoading(FACTION_CS_GETAPPLYINFO, FACTION_SC_GETAPPLYINFO_RET)

	self.load_data = {}
	self.select_cell_index = 0
	self.factionData = factionData
	self.memberLayer = memberLayer

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

	local topBg = CreateListTitle(baseNode, cc.p(bg:getContentSize().width/2, 456), 702, 43, cc.p(0.5, 0))
 	local topStr = {
						{text=game.getStrByKey("faction_top_level"), pos=cc.p(380, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_name"), pos=cc.p(160, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_school"), pos=cc.p(270, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_fight"), pos=cc.p(50, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_faction_action"), pos=cc.p(560, topBg:getContentSize().height/2)},
					}
	self.topStr = topStr
	for i,v in ipairs(topStr) do
		createLabel(topBg, topStr[i].text, topStr[i].pos, cc.p(0.5, 0.5), 22, true)
	end

	createSprite(baseNode, path.."sperate.png", cc.p(bg:getContentSize().width/2, 85), cc.p(0.5, 0.5))
	self:createTableView(baseNode, cc.size(700, 365), cc.p(10, 90), true)

	self.numLabel = createLabel(baseNode, game.getStrByKey("faction_tip_menber").."0/0", cc.p(15, 40), cc.p(0, 0.5), 22, true)
	self:updateNumberLabel()

	local touchFunc = function(sender) 
		local auto = not (self.gou_sprite:isVisible())
		self.gou_sprite:setVisible(auto)
		log("touchFunc item")
		g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_CHANGEAUTOJOIN, "ChangeFactionAutoJoin", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID),autoJoin=(auto and 1 or 0)})
	end
	local item = createTouchItem(baseNode, "res/component/checkbox/1.png", cc.p(215, 40), touchFunc)
	local gou = createSprite(item, "res/component/checkbox/1-1.png", getCenterPos(item))
	-- gou:setTag(1)
	self.gou_sprite = gou
	createLabel(baseNode, game.getStrByKey("faction_auto_in"), cc.p(235, 40), cc.p(0, 0.5), 22, true)

    local agreeFunc = function() 
	    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_AGREE_JOIN, "AgreeJoinFaction", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID),opRoleSID=0})
    end
    local refuseFunc = function() 
	    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_REFUSE_APPLY, "RefuseJoinFaction", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), opRoleSID=0})
    end
	local all_pass = createMenuItem(baseNode, "res/component/button/50.png", cc.p(490, 40), agreeFunc)
	createLabel(all_pass, game.getStrByKey("all_pass"), cc.p(all_pass:getContentSize().width/2, all_pass:getContentSize().height/2), nil, 22, true)

	local all_refuse = createMenuItem(baseNode, "res/component/button/50.png", cc.p(630, 40), refuseFunc)
	createLabel(all_refuse, game.getStrByKey("all_refuse"), cc.p(all_refuse:getContentSize().width/2, all_refuse:getContentSize().height/2), nil, 22, true)
end

function FacApplyListLayer:reloadData()
	--self.num_label:setString(#self.load_data)
end

function FacApplyListLayer:updateNumberLabel()
	local function getNumberMax()
		local tab = getConfigItemByKey("FactionUpdate")
		for k,v in pairs(tab) do
			if v.FacLevel == self.factionData.facLv and v.FACTION_MEMBER_COUNT then
				return v.FACTION_MEMBER_COUNT
			end
		end

		return 0
	end
	local numberCount = self.factionData.menberCount
	local numberMax = getNumberMax()
	self.numLabel:setString(game.getStrByKey("faction_tip_menber")..numberCount.."/"..numberMax)
end

function FacApplyListLayer:tableCellTouched(table,cell)
	local posx,posy = cell:getPosition()
	local idx = cell:getIdx()
	-- if not self.picked_bg then
	-- 	self.picked_bg = createScale9Sprite(table,"res/common/scalable/selected.png",cc.p(posx,posy),cc.size(935,83),cc.p(0,0))
	-- 	self.picked_bg:setLocalZOrder(2)
	-- else
	-- 	self.picked_bg:setPosition(cc.p(posx,posy))
	-- end

	local basemenus = {	{game.getStrByKey("private_chat"),1},
						{game.getStrByKey("look_info"),2},
						{game.getStrByKey("re_team"),3},
						--{game.getStrByKey("look_shop"),4},
					  }

	local menuFunc = function(index) 

	local switch = {
			[1] = function()    
				PrivateChat(self.load_data[idx+1][3])
			end,
			[2] = function()   
				LookupInfo(self.load_data[idx+1][3])
			end,
			[3] = function()    
				InviteTeamUp(self.load_data[idx+1][3])
			end,
			-- [4] = function()   
			-- 	LookupBooth(self.load_data[idx+1][3])
			-- end,
		}
		log("menuFunc"..index)
	 	if switch[index] then 
	 		switch[index]()
	 	end
	end

	for k,v in ipairs(basemenus)do 
		v[3] = menuFunc
	end

	local menus = {}

	for i,v in ipairs(basemenus)do
		menus[i] = v
	end 

	local layer = require("src/OperationLayer").new(self,1,menus, "res/component/button/49", "res/common/scalable/7.png")
end

function FacApplyListLayer:cellSizeForTable(table,idx) 
    return 70, 730
end

function FacApplyListLayer:tableCellAtIndex(table, idx)
	local data = self.load_data[idx+1]
	if not data then 
		return
	end
    local cell = table:dequeueCell()
     local zhiye_str = {game.getStrByKey("zhanshi"),game.getStrByKey("fashi"),game.getStrByKey("daoshi")}
    local str_tab = {""..data[2]..game.getStrByKey("faction_player_level"),data[3],zhiye_str[data[4]],""..data[5]}

    local agreeFunc = function() 
    	if self.picked_bg then
    		removeFromParent(self.picked_bg)
    		self.picked_bg = nil
    	end
	    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_AGREE_JOIN, "AgreeJoinFaction", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID),opRoleSID=data[1]})
    end
    local refuseFunc = function() 
    	if self.picked_bg then
    		removeFromParent(self.picked_bg)
    		self.picked_bg = nil
    	end
	    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_REFUSE_APPLY, "RefuseJoinFaction", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), opRoleSID=data[1]})
    end
    if nil == cell then
        cell = cc.TableViewCell:new() 
    else
    	cell:removeAllChildren() 
    end 

    local posx,posy = 78,41
    local cellBg = createSprite(cell, "res/faction/sel_normal.png", cc.p(0, 0), cc.p(0, 0))
    for i=1,4 do
    	createLabel(cellBg, str_tab[i], cc.p(self.topStr[i].pos.x-5, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.lable_black)
    end
    local rep_menu = createMenuItem(cellBg, "res/component/button/48.png", cc.p(500, cellBg:getContentSize().height/2), agreeFunc)
	createLabel(rep_menu, game.getStrByKey("pass"),cc.p(rep_menu:getContentSize().width/2,rep_menu:getContentSize().height/2),nil, 22,true)
	local rep_menu = createMenuItem(cellBg, "res/component/button/48.png", cc.p(620, cellBg:getContentSize().height/2), refuseFunc)
	createLabel(rep_menu, game.getStrByKey("refuse"),cc.p(rep_menu:getContentSize().width/2,rep_menu:getContentSize().height/2),nil, 22,true)

    return cell
end

function FacApplyListLayer:numberOfCellsInTableView(table)
   	return #self.load_data
end

function FacApplyListLayer:networkHander(buff,msgid)
	local switch = {
		[FACTION_SC_AGREE_JOIN_RET] = function()    
			log("get FACTION_SC_AGREE_JOIN_RET"..msgid) 
            local t = g_msgHandlerInst:convertBufferToTable("AgreeJoinFactionRet", buff) 
			local r_id =  t.opRoleSID
			if r_id == 0 then
				self.load_data = {} 
			else 
				for k,v in pairs(self.load_data)do
					if r_id == v[1] then 
						table.remove(self.load_data,k)
					end
				end
			end
			self:getTableView():reloadData()
			if self.memberLayer and self.memberLayer.updateMember then
				self.memberLayer:updateMember()
			end
		end,
		[FACTION_SC_REFUSE_APPLY_RET] = function()    
			log("get FACTION_SC_REFUSE_APPLY_RET"..msgid) 
            local t = g_msgHandlerInst:convertBufferToTable("RefuseJoinFactionRet", buff)  
			local r_id =  t.opRoleSID
			if r_id == 0 then
				self.load_data = {} 
			else 
				for k,v in pairs(self.load_data)do
					if r_id == v[1] then 
						table.remove(self.load_data,k)
					end
				end
			end
			self:getTableView():reloadData() 

		end,
		[FACTION_SC_GETAPPLYINFO_RET] = function()    
			log("get FACTION_SC_GETAPPLYINFO_RET"..msgid) 
            local t = g_msgHandlerInst:convertBufferToTable("GetApplyFactionInfoRet", buff)
			self.load_data = {} 
			local auto,num =  t.autoJoin,#t.infos
			self.gou_sprite:setVisible(auto>0)
			for i=1,num do 
                self.load_data[i] = {t.infos[i].roleSID,t.infos[i].lv,t.infos[i].name,t.infos[i].job,t.infos[i].battle}
				for k,v in ipairs(self.load_data[i])do 
					log("self.load_data"..i.."k"..k.."v"..tostring(v))
				end
			end	

            table.sort( self.load_data, function( a , b )  return a[2] > b[2] end )
			self:getTableView():reloadData()			  
		end,
		
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FacApplyListLayer