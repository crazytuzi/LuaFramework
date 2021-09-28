local FactionDevoteLayer = class("FactionDevoteLayer", require ("src/TabViewLayer") )

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionDevoteLayer:ctor(factionData, bg)
	local msgids = {FACTION_SC_OPENCONTRIWIN_RET,FACTION_SC_CONTRIBUTE_RET}
	require("src/MsgHandler").new(self,msgids)
	--g_msgHandlerInst:sendNetDataByFmtExEx(FACTION_CS_OPENCONTRIWIN,"ici",G_ROLE_MAIN.obj_id,2,require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID))

	self.factionData = factionData

	local baseNode = cc.Node:create()
	bg:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

	local topBg = CreateListTitle(baseNode, cc.p(10, 480), 416, 46, cc.p(0, 0))
 	local topStr = {
						{text=game.getStrByKey("rank"), pos=cc.p(30, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("faction_top_name"), pos=cc.p(180, topBg:getContentSize().height/2)},
						{text=game.getStrByKey("wealth"), pos=cc.p(340, topBg:getContentSize().height/2)},
						--{text=game.getStrByKey("faction_top_time_2"), pos=cc.p(340, topBg:getContentSize().height/2)},
					}
	self.topStr = topStr
	for i,v in ipairs(topStr) do
		createLabel(topBg, topStr[i].text, topStr[i].pos, cc.p(0.5, 0.5), 22, true)
	end

	self.select_cell_index = 0

	self.load_data = {}

	self:createTableView(baseNode, cc.size(420, 470), cc.p(10, 10), true)
	self:getTableView():reloadData()

	local infoBg = createSprite(baseNode, pathCommon.."bg/infoBg.png", cc.p(bg:getContentSize().width-5, bg:getContentSize().height/2), cc.p(1, 0.5))
	createTitleLine(infoBg, cc.p(infoBg:getContentSize().width/2, 230), 286, cc.p(0.5,0.5))
	createTitleLine(infoBg, cc.p(infoBg:getContentSize().width/2, 425), 286, cc.p(0.5,0.5))

	local richText = require("src/RichText").new(infoBg, cc.p(15, 220), cc.size(285, 30), cc.p(0, 1), 26, 20, MColor.lable_yellow)
    richText:addText(game.getStrByKey("faction_devote_tip"))
    richText:format()

	self.updata_labels = {}
	self.updata_labels[1] = createLabel(infoBg, string.format(game.getStrByKey("my_devotes"), 0), cc.p(50, 445), cc.p(0,0), 22, nil, nil, nil, MColor.lable_yellow)
	self.updata_labels[2] = createLabel(infoBg, string.format(game.getStrByKey("fac_wealth"), 0), cc.p(50, 480), cc.p(0,0), 22, nil, nil, nil, MColor.lable_yellow)

	local getDevoteStr = function(flag)
		local record = require("src/config/FactionUpdate")[1]
		local str
		if flag == 1 then
			local data = record["jbhb"]
			local strings = stringsplit(data, ",")
			str = strings[1]..game.getStrByKey("faction_gold").."="..strings[2]..game.getStrByKey("faction_money").."+"..strings[3]..game.getStrByKey("faction_rich")
		else
			local data = record["ybhb"]
			local strings = stringsplit(data, ",")
			str = strings[1]..game.getStrByKey("faction_yuanbao").."="..strings[2]..game.getStrByKey("faction_money").."+"..strings[3]..game.getStrByKey("faction_rich")
		end
		return str
	end

	local edit_box_handler = function(strEventName,pSender)
        local edit = tolua.cast(pSender,"ccui.EditBox") 

        if strEventName == "began" then --编辑框开始编辑时调用

        elseif strEventName == "ended" then --编辑框完成时调用

        elseif strEventName == "return" then --编辑框return时调用
        	log("return")
        	local str = edit:getText()
        	local num = tonumber(str)
        	--log("num = "..num)
        	if num then
        		if edit == self.edit_box1 then
        			if num >= 100000 then
        				num = num - num % 100000
        				--log("num = "..num)
        			end
        		elseif edit == self.edit_box2 then
        			if num >= 1 then
        				num = num - num % 1
        				--log("num = "..num)
        			end
        		end
        		edit:setText(num)
        	end
        elseif strEventName == "changed" then --编辑框内容改变时调用
        	log("changed")

        end
	end


	self.currIngotlabel = createLabel(infoBg,game.getStrByKey("currect_gold")..G_ROLE_MAIN.currIngot,cc.p(15,380),cc.p(0.0,0.5),20,true,nil,nil,MColor.lable_yellow)
	createLabel(infoBg, getDevoteStr(2), cc.p(15, 340), cc.p(0, 0.5), 20, true, nil, nil, MColor.red)
	local editBg = createScale9Sprite(infoBg, pathCommon.."bg/inputBg.png", cc.p(15, 265), cc.size(180, 45), cc.p(0, 0))
	createSprite(editBg, "res/group/currency/3.png", cc.p(10, editBg:getContentSize().height/2), cc.p(0, 0.5), nil, 0.7)
	local edit_box2 = createEditBox(editBg, nil, getCenterPos(editBg, 30), cc.size(140, 45), MColor.lable_yellow)
	edit_box2:setPlaceHolder(game.getStrByKey("faction_input"))
	edit_box2:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	edit_box2:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	edit_box2:registerScriptEditBoxHandler(edit_box_handler)
	self.edit_box2 = edit_box2

	startTimerAction(self, 0.3, true, function() self.currIngotlabel:setString(game.getStrByKey("currect_gold")..G_ROLE_MAIN.currIngot) end)
	-- createLabel(infoBg,game.getStrByKey("materials_devote"),cc.p(570,110),cc.p(0.0,0.5), 20,true,nil,nil,cc.c3b(237, 215, 27))
	
	-- local devoteFunc = function()
	-- 	local number = tonumber(edit_box1:getText())
	-- 	if number and number > 0 then
	-- 		if number >= 100000 then
	-- 			g_msgHandlerInst:sendNetDataByFmtExEx(FACTION_CS_CONTRIBUTE,"iic",G_ROLE_MAIN.obj_id,number,1)
	-- 		elseif number < 100000 then
	-- 			MessageBox(game.getStrByKey("faction_devote_number_error_not_enough_tip"), nil, nil)
	-- 		end
	-- 	else
	-- 		MessageBox(game.getStrByKey("faction_devote_number_error_tip"), nil, nil)
	-- 	end
	-- 	edit_box1:setText("")
	-- end
	-- local devote = createMenuItem(infoBg, "res/component/button/51.png", cc.p(250, 337), devoteFunc)
	-- createLabel(devote,game.getStrByKey("devote"),cc.p(devote:getContentSize().width/2,devote:getContentSize().height/2),nil, 22, true)

	local devoteFunc1 = function() 
		local number = tonumber(edit_box2:getText())
		if number and number >= 1 then
			--g_msgHandlerInst:sendNetDataByFmtExEx(FACTION_CS_CONTRIBUTE,"iic",G_ROLE_MAIN.obj_id,number,2)
		else
			MessageBox(game.getStrByKey("faction_devote_number_error_tip"), nil, nil)
		end
		edit_box2:setText("")
	end
	local devote = createMenuItem(infoBg, "res/component/button/51.png", cc.p(250, 287), devoteFunc1)
	createLabel(devote,game.getStrByKey("devote"),cc.p(devote:getContentSize().width/2,devote:getContentSize().height/2),nil, 22, true)

	-- createLabel(infoBg, game.getStrByKey("onekey_materials_devote"), cc.p(infoBg:getContentSize().width/2, 115), cc.p(0.5, 0.5), 22, true)
	-- local onekeyDevoteFunc = function() 
	-- 	g_msgHandlerInst:sendNetDataByFmtExEx(FACTION_CS_CONTRIBUTE,"iic",G_ROLE_MAIN.obj_id,3000,3)
	-- end
	-- local devote = createMenuItem(infoBg, "res/component/button/50.png", cc.p(infoBg:getContentSize().width/2, 50), onekeyDevoteFunc)
	-- createLabel(devote,game.getStrByKey("onekey_devote"),cc.p(devote:getContentSize().width/2,devote:getContentSize().height/2),nil, 22, true)

	self.devote_data = {}

	local menuFunc = function(tag) 
		if tag ~= self.select_index then
			self.select_index = tag
			if not self.devote_data[tag] then 
				--g_msgHandlerInst:sendNetDataByFmtExEx(FACTION_CS_OPENCONTRIWIN,"ici",G_ROLE_MAIN.obj_id,tag,require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID))
			else 
				self.load_data = self.devote_data[tag]
				self:getTableView():reloadData()
			end
		end
	end

	-- local tab_control = {}
	-- local posx,posy = 595,595
	-- for i=1,2 do
	-- 	tab_control[i] = {}
	-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/5.png","res/component/TabControl/6.png")
	-- 	tab_control[i].menu_item:setPosition(cc.p(posx,posy))
	-- 	tab_control[i].callback = menuFunc
	-- 	createSprite(tab_control[i].menu_item,"res/faction/"..57+i..".png",cc.p(tab_control[i].menu_item:getContentSize().width/2,tab_control[i].menu_item:getContentSize().height/2-5))
	-- 	posx = posx + 180
	-- end
	-- creatTabControlMenu(bg,tab_control,1)
	self.select_index = 1
	menuFunc(1)
	-- SwallowTouches(self)
	-- bg:setScale(0.01)
 --    bg:runAction(cc.ScaleTo:create(0.2, 1))
end

function FactionDevoteLayer:updateInfo()
	self.updata_labels[1]:setString(string.format(game.getStrByKey("my_devotes"),self.glob_data[1]))
	self.updata_labels[2]:setString(string.format(game.getStrByKey("fac_wealth"),self.glob_data[2])) 
	--self.currGoldlabel:setString(game.getStrByKey("currect_coin")..G_ROLE_MAIN.currGold)
	self.currIngotlabel:setString(game.getStrByKey("currect_gold")..G_ROLE_MAIN.currIngot)
end

function FactionDevoteLayer:tableCellTouched(table,cell)
	-- local posx,posy = cell:getPosition()
	-- if not self.picked_bg then
	-- 	-- self.picked_bg = self.createSprite(table,"res/teamup/15.png",cc.p(posx,posy-2),cc.p(0,0),9)
	-- 	-- self.picked_bg:setScaleX(0.54)
	-- 	self.picked_bg = createScale9Sprite(table,"res/common/scalable/selected.png",cc.p(posx,posy),cc.size(444,74),cc.p(0,0))
	-- else
	-- 	self.picked_bg:setPosition(cc.p(posx,posy))
	-- end
end

function FactionDevoteLayer:cellSizeForTable(table,idx) 
    return 70, 420
end

function FactionDevoteLayer:tableCellAtIndex(table, idx)
	local data = self.load_data[idx+1]
	if not data then 
		return
	end
    local cell = table:dequeueCell()
    local str_tab = {tostring(idx+1), data[2], ""..data[3]}

    local function createCellContent(cell)
    	local cellBg =  createSprite(cell, pathCommon.."table/cell3.png", cc.p(0, 0), cc.p(0, 0))
    	for i=1,3 do
	    	createLabel(cell, str_tab[i], cc.p(self.topStr[i].pos.x, cellBg:getContentSize().height/2), nil, 20, true, nil, nil, MColor.lable_black)
	    end
    end
    if nil == cell then
        cell = cc.TableViewCell:new()  
        createCellContent(cell)
    else
    	cell:removeAllChildren()
    	createCellContent(cell)
    end

    return cell
end

function FactionDevoteLayer:numberOfCellsInTableView(table)
   	return #self.load_data
end

function FactionDevoteLayer:networkHander(buff,msgid)
	local compare = function(a,b)
		return a[3]>b[3]
	end
	local switch = {
		[FACTION_SC_OPENCONTRIWIN_RET] = function() 
			--self.glob_data = {buff:readByFmt("iicc")}
			--local load_data = {}
			--for i=1,self.glob_data[4] do 
			--	load_data[i] = {buff:readByFmt("iSi")}  
			--end
			--table.sort(load_data,compare)
			--self.devote_data[self.glob_data[3]] = load_data
			--self.load_data = self.devote_data[self.glob_data[3]]
			--self:updateInfo()
			--self:getTableView():reloadData()
		end,
		[FACTION_SC_CONTRIBUTE_RET] = function() 
		--[[	local ret_data = {buff:readByFmt("iiii")}
			self.glob_data[1],self.glob_data[2] = ret_data[3],ret_data[4]
			local has_find = false
			if self.devote_data[1] then 
				for k,v in pairs(self.devote_data[1])do
					if ret_data[1] == v[1] then 
						v[3] = ret_data[2]
						has_find = true
					end
				end
				if not has_find then 
					local temp = {ret_data[1] ,G_ROLE_MAIN.base_data.name,ret_data[2] }
					table.insert(self.devote_data[self.select_index],temp)
				end
				table.sort(self.devote_data[1],compare)
			end
			if self.devote_data[2] then 
				has_find = false
				for k,v in pairs(self.devote_data[2])do
					if ret_data[1] == v[1] then 
						v[3] = ret_data[3]
						has_find = true
					end
				end
				if not has_find then 
					local temp = {ret_data[1] ,G_ROLE_MAIN.base_data.name,ret_data[3] }
					table.insert(self.devote_data[2],temp)
				end
				table.sort(self.devote_data[2],compare)
			end
			self:updateInfo()
			-- if g_EventHandler["loaddata"] then
			-- 	g_EventHandler["loaddata"](11,self.glob_data[1])
			-- 	g_EventHandler["loaddata"](9,self.glob_data[2])
			-- end
			self.factionData.myMoney = ret_data[3]
			self.factionData.money = ret_data[4]
			self:getTableView():reloadData()
            ]]
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end
return FactionDevoteLayer