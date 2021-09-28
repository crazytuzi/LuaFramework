local FactionUpdateLayer = class("FactionUpdateLayer",function() return cc.Layer:create() end )

local FactionUpdateType = {}
FactionUpdateType.typeFaction = 1
FactionUpdateType.typeShop = 2
FactionUpdateType.typeFlag = 3

function FactionUpdateLayer:ctor(factionData, index)
	local msgids = {FACTION_SC_PREUPLEVEL_RET, FACTION_SC_UPLEVEL_RET, FACTIONCOPY_CS_GET_PASS_TIME}
	require("src/MsgHandler").new(self,msgids)

	g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_GET_PASS_TIME, "FactionCopyGetPassTime", {})
    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_PREUPLEVEL, "PreUpLevelFaction", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})

	self.factionData = factionData
	self.nUpNeedMoney = 0
	self.nOpenBossNeedMoney = 0

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("faction_update"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 24, true)
	local contentBg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
	local textBg = createSprite(contentBg, "res/common/bg/bg18-6.png", cc.p(contentBg:getContentSize().width/2, 115), cc.p(0.5, 0))
	createSprite(textBg, "res/group/arrows/15.png", getCenterPos(textBg), cc.p(0.5, 0.5))

	local maxBg = createSprite(contentBg, "res/common/bg/bg18-6.png", cc.p(contentBg:getContentSize().width/2, 115), cc.p(0.5, 0))
	createLabel(maxBg, game.getStrByKey("fullLevel"), getCenterPos(maxBg), cc.p(0.5, 0.5), 24, true)
	self.maxBg = maxBg
	self.maxBg:setVisible(false)

	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() self:removeFromParent() end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)

	createLabel(textBg, game.getStrByKey("faction_update_now"), cc.p(40, 130), cc.p(0, 0), 22, true)
	createLabel(textBg, game.getStrByKey("faction_update_next"), cc.p(470, 130), cc.p(0, 0), 22, true)
	createLabel(textBg ,game.getStrByKey("faction_update_need"),cc.p(470, 55),cc.p(0, 0), 22,nil,nil,nil,cc.c3b(215,195,144))
	createLabel(textBg, game.getStrByKey("faction_update_cost"), cc.p(470, 20), cc.p(0, 0), 22, true)
		
	self.update_labels = {}

	local tab_control = {}
	self.tab_control = tab_control
	local menuFunc = function(tag) 
		if self.select_index ~= tag then 
			self.select_index = tag

			for i,v in ipairs(self.tab_control) do
				if i == tag then
					v.menu_label:setColor(MColor.lable_yellow)
				else
					v.menu_label:setColor(MColor.lable_black)
				end
			end

			self:updateInfo()
		end
	end
    
	local pos = {cc.p(contentBg:getContentSize().width/2-140, 385), cc.p(contentBg:getContentSize().width/2, 385), cc.p(contentBg:getContentSize().width/2+140, 385)}
	local imgs = {"res/faction/3.png", "res/faction/3-3.png", "res/faction/3-2.png"}
	local str_tab = {"faction_level", "faction_baibaoge", "faction_zhanqitai"}
	for i=1,3 do 
		tab_control[i] = {}
		tab_control[i].menu_item = cc.MenuItemImage:create("res/component/button/54.png", "res/component/button/54_sel.png")
		createSprite(tab_control[i].menu_item, imgs[i], getCenterPos(tab_control[i].menu_item, 5, -2), cc.p(0.5, 0.5))
		tab_control[i].menu_item:setPosition(pos[i])
		tab_control[i].callback = menuFunc
		tab_control[i].menu_label = createLabel(contentBg, game.getStrByKey(str_tab[i]), cc.p(pos[i].x, pos[i].y-60), cc.p(0.5, 1), 22)
	end
	local indexDefault = 1
	if index then
		indexDefault = index
	end
	creatTabControlMenu(contentBg, tab_control, indexDefault)
	menuFunc(indexDefault)

	local updateBtnFunc = function()
		local curMoney = self.factionData.money
		local uplvNeedMoney = self.nUpNeedMoney
		local openBossNeedMoney = self.nOpenBossNeedMoney

		local funcUpdate = function()
		    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_UPLEVEL, "UpLevelFaction", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), upType=self.select_index, curLevel=self.levels[self.select_index]})
        end

		if openBossNeedMoney > 0 and curMoney - uplvNeedMoney < openBossNeedMoney then
			MessageBoxYesNo(nil, game.getStrByKey("faction_hintUpgrade"), funcUpdate, nil)
		else
			funcUpdate()
		end
	end
	local updateBtn = createTouchItem(contentBg, "res/component/button/50.png", cc.p(contentBg:getContentSize().width/2, 55), updateBtnFunc)
	updateBtn:setEnable(false)
	self.updateBtn = updateBtn
	createLabel(updateBtn, game.getStrByKey("upgrade"), getCenterPos(updateBtn), cc.p(0.5, 0.5), 22, true)

	self.update_node = cc.Node:create()
    textBg:addChild(self.update_node, 10)

	SwallowTouches(self)
    registerOutsideCloseFunc(bg, closeFunc)
end

function FactionUpdateLayer:updateInfo() 
	log("FactionUpdateLayer:updateInfo")
	if self.levels == nil then
		return
	end

	local level = self.levels[self.select_index]
	log("level = "..level)
	local str_tab

	if level == 9 then
		str_tab = {string.format(game.getStrByKey("how_level"),level),
					"",
					self:getUpdateString(self.select_index, level), 
					"",
					""
					}
		self.maxBg:setVisible(true)	
		self.updateBtn:setVisible(false)		
	else
		str_tab = {string.format(game.getStrByKey("how_level"),level),
					string.format(game.getStrByKey("how_level"),level+1),
					self:getUpdateString(self.select_index, level), 
					self:getUpdateString(self.select_index, level+1),
					self:getNeedString(self.select_index, level),
					}
		self.maxBg:setVisible(false)
		self.updateBtn:setVisible(true)
	end

	local pos = {cc.p(175,130),cc.p(605,130),cc.p(40,95),cc.p(470,95),cc.p(570,55),cc.p(570,20)}
	for i=1,5 do 
		if self.update_labels[i] then 
			self.update_labels[i]:setString(str_tab[i])
		else 
			self.update_labels[i] = createLabel(self.update_node,str_tab[i],pos[i],cc.p(0, 0), 22)
		end

		if i == 1 or i == 2 then
			self.update_labels[i]:setColor(MColor.lable_yellow)
		else
			self.update_labels[i]:setColor(MColor.lable_black)
		end
	end

	local strNeedMoney = self:getUpdateData(self.select_index, level, "xhcf")
	self.nUpNeedMoney = tonumber(strNeedMoney)

	if self.richText then
		removeFromParent(self.richText)
		self.richText = nil
	end
	self.richText = require("src/RichText").new(self.update_node, pos[6], cc.size(200, 20), cc.p(0, 0), 20, 20, MColor.lable_black)
    self.richText:addText("^c(white)"..strNeedMoney.."^"..game.getStrByKey("faction_money"))
    self.richText:format()

	log("FactionUpdateLayer:updateInfo end")
end

function FactionUpdateLayer:networkHander(buff, msgid)
	local switch = {
		[FACTION_SC_PREUPLEVEL_RET] = function() 
			log("get FACTION_SC_PREUPLEVEL_RET"..msgid)  
            local t = g_msgHandlerInst:convertBufferToTable("PreUpLevelFactionRet", buff)  
			self.levels = {t.lv, t.storeLv, t.bannerLv}
			--dump(self.levels)
			self:updateInfo()
			if self.updateBtn then
				self.updateBtn:setEnable(true)
			end
		end,	
		[FACTION_SC_UPLEVEL_RET] = function() 
			log("get FACTION_SC_UPLEVEL_RET"..msgid)  
            local t = g_msgHandlerInst:convertBufferToTable("UpLevelFactionRet", buff)   
			local lv,ecode,monney= t.curLevel,t.upType,t.factionMoney
			log("lv = "..lv)
			log("ecode = "..ecode)
			log("monney = "..monney)
			if ecode == 6 then
				self.factionData.facLv = lv
			elseif ecode == 7 then
				self.factionData.shopLv = lv
			elseif ecode == 8 then
				self.factionData.flagLv = lv
			end
			self.levels[ecode-5] = lv
			self.factionData.money = monney
			self:updateInfo()

			local parent = self:getParent()
			if parent and parent.updateFactionInfo then
				parent:updateFactionInfo()
			end
		end,

		[FACTIONCOPY_SC_GET_PASS_TIME_RET] = function()
            local t = g_msgHandlerInst:convertBufferToTable("FactionCopyGetPassTimeRet", buff)
			local bossTime = t.secToOpen
			local copyId = t.copyID
			local copySetCount = t.openTimes

			self.nOpenBossNeedMoney = 0
			if copyId > 0 then
				local factionInfo = getConfigItemByKey("FactionCopyDB", "ID", copyId)
				if factionInfo then
					self.nOpenBossNeedMoney = factionInfo.costResource
				end
			end

			log("[FACTIONCOPY_SC_GET_PASS_TIME_RET] In FactionUpdateLayer. time = %s, copyid = %s, setcount = %s.", bossTime, copyId, copySetCount)
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

function FactionUpdateLayer:getUpdateData(updateType, level, region)
	log("FactionUpdateLayer:getUpdateData")
	log("updateType = "..updateType)
	log("level = "..level)
	log("region = "..region)
	local updateTab = require("src/config/FactionUpdate")
	local count = 0
	local startIndex
	for i,v in ipairs(updateTab) do
		--log("v.FacLevel = "..v.FacLevel)
		if v.FacLevel == 1 then
			count = count + 1
			if count == updateType then
				startIndex = i
			end
		end
	end
	--log("startIndex"..startIndex)
	for i = startIndex,#updateTab do
		if updateTab[i].FacLevel == level then
			--log("i = "..i)
			if updateTab[i][region] then
				return updateTab[i][region]
			else
				return ""
			end
		end
	end
end

function FactionUpdateLayer:getUpdateString(updateType, level)
	log("getUpdateString")
	if updateType == FactionUpdateType.typeFaction then
		return string.format(game.getStrByKey("faction_updateString_menber"), self:getUpdateData(FactionUpdateType.typeFaction, level, "FACTION_MEMBER_COUNT"))
	elseif updateType == FactionUpdateType.typeShop then
		return string.format(game.getStrByKey("faction_updateString_shop"), level)
	elseif updateType == FactionUpdateType.typeFlag then
		return string.format(game.getStrByKey("faction_updateString_flag"), level)
	end
end

function FactionUpdateLayer:getNeedString(updateType, level)
	if updateType == FactionUpdateType.typeFaction then
		return game.getStrByKey("faction_level")..string.format(game.getStrByKey("how_level"), level)
	elseif updateType == FactionUpdateType.typeShop then
		return game.getStrByKey("faction_baibaoge")..string.format(game.getStrByKey("how_level"), level)
	elseif updateType == FactionUpdateType.typeFlag then
		return game.getStrByKey("faction_zhanqitai")..string.format(game.getStrByKey("how_level"), level)
	end
end

return FactionUpdateLayer