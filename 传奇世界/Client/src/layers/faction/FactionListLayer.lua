local FactionListLayer = class("FactionListLayer", require ("src/TabViewLayer") )
FactionListLayer.onlyshowtag = {false,false}

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionListLayer:ctor(parent, parentBg)
	self.parent = parent
	self.getString = game.getStrByKey

    -- ÐÐ»á id ±£´æÎ»ÖÃ ÊôÐÔ¸üÐÂ¿ÉÄÜÔÝÊ±Î´¸üÐÂ
    local factionId = (G_FACTION_INFO and G_FACTION_INFO.id) or require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID);
    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETFACTIONINFO, "GetFactionInfo", {["factionID"]=factionId})
	
	local msgids = {FACTION_SC_GETALLFACTION_RET,FACTION_SC_APPLYJOIN_RET,FACTION_SC_CANCEL_APPLY_RET}
	require("src/MsgHandler").new(self,msgids)

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

	--local bg = createSprite(baseNode, "res/common/bg/bg-6.png", cc.p(parentBg:getContentSize().width/2, 25), cc.p(0.5, 0))
    local bg = cc.Node:create()
    bg:setPosition(cc.p(15, 23))
    bg:setContentSize(cc.size(930, 535))
    bg:setAnchorPoint(cc.p(0, 0))
    baseNode:addChild(bg)

    --createScale9Sprite(bg, pathCommon.."bg/bg60.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height/2), cc.size(896, 500), cc.p(0.5, 0.5))
    createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(17, 20),
        cc.size(896, 500),
        5
    )

	createSprite(bg, "res/faction/title_min3.png", cc.p(bg:getContentSize().width/2, 80), cc.p(0.5, 0.5))
	
	local top = CreateListTitle(bg, cc.p(bg:getContentSize().width/2, 472), 888, 43, cc.p(0.5, 0))
	local topStr = {
						{text=game.getStrByKey("faction_top_faction_name"), pos=cc.p(100, top:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_faction_level"), pos=cc.p(240, top:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_faction_menber"), pos=cc.p(405, top:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_faction_fight"), pos=cc.p(565, top:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_faction_action"), pos=cc.p(780, top:getContentSize().height/2)},
					}
	self.topStr = topStr
	for i,v in ipairs(topStr) do
		dump(topStr[i])
		createLabel(top, topStr[i].text, topStr[i].pos, cc.p(0.5, 0.5), 22, true)
	end

	self.select_cell_index = 0
	self.fac_data = {}
	self.load_data = {}

	self:createTableView(bg,cc.size(888,384),cc.p(24,88),true, true)
	self:getTableView():setLocalZOrder(125)
	-- self:getTableView():setPosition(cc.p(1525,110))
 --    self:getTableView():runAction(cc.MoveTo:create(0.5, cc.p(17,110)))
    self:getTableView():reloadData()

	local str_tab = {self.getString("faction_only_dec"),self.getString("faction_agree_dec")}
	self.unshowtag = {}
	local touchFunc = function(sender) 
		local gou = tolua.cast(sender:getChildByTag(1),"cc.Sprite")
		gou:setVisible(not (gou:isVisible()))
		local tag = sender:getTag()
		FactionListLayer.onlyshowtag[tag] = not FactionListLayer.onlyshowtag[tag]
		log("touchFunc item"..sender:getTag())
		self:resetLoadData() 
	end

	for i=0,1 do
		local item = createTouchItem(baseNode,"res/component/checkbox/1.png",cc.p(100+i*440,75),touchFunc)
		item:setTag(i+1)
		local gou = createSprite(item,"res/component/checkbox/1-1.png",getCenterPos(item))
		gou:setTag(1)
		gou:setVisible(FactionListLayer.onlyshowtag[i+1])
		createLabel(item, str_tab[i+1], cc.p(item:getContentSize().width + 5, item:getContentSize().height/2), cc.p(0,0.5), 20, true, nil, nil, MColor.lable_black)
	end

	-- local createFunc = function() 
	-- 	local layer = require("src/layers/faction/FactionCreateLayer").new(self)
	-- 	self:addChild(layer,254)
	-- end
	-- local create_menu = createMenuItem(baseNode, "res/component/button/11.png", cc.p(850, 55), createFunc)
	-- --createSprite(create_menu,"res/faction/11.png",cc.p(create_menu:getContentSize().width/2,create_menu:getContentSize().height/2))
	-- createLabel(create_menu, self.getString("faction_create"), cc.p(create_menu:getContentSize().width/2,create_menu:getContentSize().height/2), cc.p(0.5, 0.5), 22, true)

	--self:setPosition(0,-1*g_scrSize.height)
    --self:runAction(cc.MoveTo:create(0.2, cc.p(0,0)))

    self:registerScriptHandler(function(event)
		if event == "enter" then
			--G_TUTO_NODE:setShowNode(root, SHOW_FACTION_LIST)
		elseif event == "exit" then
			--G_TUTO_NODE:setShowNode(root, SHOW_MAIN)
		end
	end)
end

function FactionListLayer:resetLoadData() 
	self.load_data = {}
	for k,v in ipairs (self.fac_data)do
		if FactionListLayer.onlyshowtag[1] and (not v[7]) then
		elseif FactionListLayer.onlyshowtag[2] and (not v[8]) then
		else
			self.load_data[#self.load_data+1] = v	
		end
	end
	self:getTableView():reloadData()
end

function FactionListLayer:tableCellTouched(table,cell)
	-- local posx,posy = cell:getPosition()
	-- if not self.picked_bg then
	-- 	self.picked_bg = createScale9Sprite(table,"res/common/scalable/selected.png",cc.p(0,0),cc.size(935,83),cc.p(0,0))
	-- else
	-- 	self.picked_bg:setPosition(cc.p(posx,posy))
	-- end

	-- if self.lastSelect then
	-- 	local bgSprite = self.lastSelect:getChildByTag(0)
	-- 	if bgSprite then
	-- 		bgSprite:setTexture("res/common/49.png")
	-- 	end
	-- end
	-- local bgSprite = cell:getChildByTag(0)
	-- if bgSprite then
	-- 	bgSprite:setTexture("res/common/48.png")
	-- end
	-- self.lastSelect = cell
end


function FactionListLayer:cellSizeForTable(table,idx) 
    return 75,915
end

function FactionListLayer:tableCellAtIndex(table, idx)

	local data = self.load_data[idx+1]
	if not data then 
		return
	end

    local cell = table:dequeueCell()
    local str_tab = {data[2],string.format(self.getString("faction_level_dec"),data[3]),""..data[4].."/"..data[5],""..data[6]}

    local func = function() 
	    log("idx"..idx)
	    if data[9] then 
            g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_CANCEL_APPLY, "CancelApplyJoinFaction", {factionID=data[1]})
	    else
            g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_APPLYJOIN, "ApplyJoinFaction", {factionID=data[1]} )
		end
	end

	local createCell = function(cell)  
		local ldData = getFactionCapturedMap(data[1]) --获取领地数据
		print("ldData===",ldData)
		local ldIndex =0
        if ldData[3] == 1 then
            ldIndex =3
        elseif ldData[2] == 1 then
            ldIndex =2
        elseif ldData[1] == 1 then
            ldIndex =1
        end
        local cellBg = createSprite(cell,"res/faction/cell_list.png",cc.p(0,0),cc.p(0.0,0.0))
        cellBg:setTag(0)

        for i=1,4 do
        	local label = createLabel(cellBg,str_tab[i],cc.p(self.topStr[i].pos.x, cellBg:getContentSize().height/2),nil,20, true, nil, nil, MColor.lable_black)

        	if i == 1 then
        		if ldIndex> 0 then
             		createSprite(cellBg, "res/faction/ld" .. ldIndex .. ".png", 
             		cc.p(4,cellBg:getContentSize().height/2), cc.p(0, 0.5))
        		end
        	end

        end
        local rep_menu = createMenuItem(cellBg, "res/component/button/39.png", cc.p(780, cellBg:getContentSize().height/2), func)
     	local item = createLabel(rep_menu,self.getString("faction_button_apply"),cc.p(rep_menu:getContentSize().width/2,rep_menu:getContentSize().height/2), nil, 22, true, nil, nil, MColor.lable_yellow)
    	if data[9] then
    		rep_menu:setImages("res/component/button/39.png")
    		item = createLabel(rep_menu,self.getString("faction_button_cancel_apply"),cc.p(rep_menu:getContentSize().width/2,rep_menu:getContentSize().height/2), nil, 22, true, nil, nil, MColor.lable_yellow)
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

function FactionListLayer:numberOfCellsInTableView(table)
   	return #self.load_data
end


function FactionListLayer:networkHander(buff,msgid)
	log("msgid" ..msgid )
	local switch = {
		[FACTION_SC_GETALLFACTION_RET] = function()
			log("get FACTION_SC_GETALLFACTION_RET"..msgid)
			self.fac_data = {} 
			
            local t = g_msgHandlerInst:convertBufferToTable("GetAllFactionInfoRet", buff) 
            for i=1,#t.infos do 
				self.fac_data[i] = {t.infos[i].id, t.infos[i].name,t.infos[i].lv,t.infos[i].allMemberCnt,t.infos[i].maxMemberCnt,t.infos[i].totalAbility,(t.infos[i].leaderOnline > 0),(t.infos[i].autoJoin > 0)}
			end

            for i=1,#t.applyedFactions do
				local facid = t.applyedFactions[i]
				for k,v in pairs(self.fac_data)do 
					if facid == v[1] then 
						v[#v+1] = true
					end
				end
			end
            
            self:resetLoadData() 
		end,
	
		[FACTION_SC_APPLYJOIN_RET] = function()    
			log("get FACTION_SC_APPLYJOIN_RET"..msgid)

            local t = g_msgHandlerInst:convertBufferToTable("ApplyJoinFactionRet", buff) 
			local isSuc,facid,ecode = (t.joinResult > 0), t.factionID, t.resultCode
			dump(isSuc)
			dump(facid)
			if isSuc == true then
				G_FACTION_INFO.id = facid
				local layer = require("src/layers/faction/FactionLayer").new()
				getRunScene():addChild(layer,200,109)
				removeFromParent(self.parent)	
			else
				for k,v in pairs(self.load_data)do
					if v[1] == facid then
						v[9] = true
					end
				end
				local offset = self:getTableView():getContentOffset()
				self:getTableView():reloadData()
				self:getTableView():setContentOffset(offset)
			end
		end,
		[FACTION_SC_CANCEL_APPLY_RET] = function()    
			log("get FACTION_SC_CANCEL_APPLY_RET"..msgid)
            local t = g_msgHandlerInst:convertBufferToTable("CancelApplyJoinFactionRet", buff) 
			local facid,ecode = t.factionID,t.resultCode
			for k,v in pairs(self.load_data)do
				if v[1] == facid then
					v[9] = nil
				end
			end
			local offset = self:getTableView():getContentOffset()
			self:getTableView():reloadData()
			self:getTableView():setContentOffset(offset)
		end,
	
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end
return FactionListLayer