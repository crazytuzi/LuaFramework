local FactionLayer = class("FactionLayer", function() return cc.Layer:create() end)

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionLayer:ctor(index, subindex, isWithoutMenu)
	local msgids = {FACTION_SC_GETFACTIONINFO_RET,
	FACTION_SC_LEAVEFACTION_RET,
	FACTION_SC_EDITCOMMENT_RET,
	--FACTION_SC_GETALLFACTION_RET,
	FACTION_SC_FRESHUI,
	FACTION_SC_PRAY_SUC,
	FACTION_SC_UPLEVEL_RET}
	require("src/MsgHandler").new(self,msgids)

	-- 行会 id 保存位置 属性更新可能暂时未更新
    local factionId = (G_FACTION_INFO and G_FACTION_INFO.id) or require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID);
    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETFACTIONINFO, "GetFactionInfo", {["factionID"]=factionId})
	addNetLoading(FACTION_CS_GETFACTIONINFO, FACTION_SC_GETFACTIONINFO_RET)

	self.selIndex = index or 1
	self.subSelIndex = subindex
	local bg = createBgSprite(self, nil,nil,true)
	self.bg = bg

	--行会是否加入微信群的标志
	self.isInWXgroup = false
	self.hasWXgroup = false

	local menuFunc = function(tag, sender, param1)
		if self.factionData == nil then
			log("self.factionData is nil !!!")
			return true
		end

		-- for i,v in ipairs(self.tab_control) do
		-- 	if tag == i then
		-- 		v.menu_item:selected()
		-- 		v.label:setColor(MColor.lable_yellow)
		-- 	else 
		-- 		v.menu_item:unselected()
		-- 		v.label:setColor(MColor.lable_black)
		-- 	end
		-- end

		self.selIndex = tag

		if tag == 1 then
			if self.buildLayer then
				--self.buildLayer:setVisible(false)
				removeFromParent(self.buildLayer)
				self.buildLayer = nil
			end

			if self.menberLayer then
				--self.menberLayer:setVisible(false)
				removeFromParent(self.menberLayer)
				self.menberLayer = nil
			end

			if self.mapLayer then
				self.mapLayer:setVisible(true)
			else
                --package.loaded["src/layers/faction/FactionMapLayer"] = nil
				self.mapLayer = require("src/layers/faction/FactionMapLayer").new(self.factionData, self.bg, self)
				self.bg:addChild(self.mapLayer)
			end

            if self.taskLayer then
				removeFromParent(self.taskLayer)
				self.taskLayer = nil
			end
		elseif tag == 2 then
			if self.buildLayer then
				self.buildLayer:setVisible(true)
			else
                --package.loaded["src/layers/faction/FactionBuildLayer"] = nil
				self.buildLayer = require("src/layers/faction/FactionBuildLayer").new(self.factionData, self.bg, self.factionData.job, self.subSelIndex)            
                self.bg:addChild(self.buildLayer)
			end

			if param1 then
				self.buildLayer:select(param1)
			end

			if self.menberLayer then
				--self.menberLayer:setVisible(false)
				removeFromParent(self.menberLayer)
				self.menberLayer = nil
			end

			if self.mapLayer then
				--self.mapLayer:setVisible(false)
				removeFromParent(self.mapLayer)
				self.mapLayer = nil
			end

            if self.taskLayer then
				removeFromParent(self.taskLayer)
				self.taskLayer = nil
			end
		elseif tag == 3 then
			if self.buildLayer then
				--self.buildLayer:setVisible(false)
				removeFromParent(self.buildLayer)
				self.buildLayer = nil
			end

			if self.menberLayer then
				self.menberLayer:setVisible(true)
			else
                --package.loaded["src/layers/faction/FactionMembersLayer"] = nil
				self.menberLayer = require("src/layers/faction/FactionMembersLayer").new(self.factionData, self.bg, self.factionData.job)
				self.bg:addChild(self.menberLayer)
			end

			if self.mapLayer then
				--self.mapLayer:setVisible(false)
				removeFromParent(self.mapLayer)
				self.mapLayer = nil
			end

            if self.taskLayer then
				removeFromParent(self.taskLayer)
				self.taskLayer = nil
			end
        elseif tag == 4 then
			if self.buildLayer then
				removeFromParent(self.buildLayer)
				self.buildLayer = nil
			end

			if self.menberLayer then
				removeFromParent(self.menberLayer)
				self.menberLayer = nil
			end

			if self.mapLayer then
				removeFromParent(self.mapLayer)
				self.mapLayer = nil
			end

            if self.taskLayer then
				self.taskLayer:setVisible(true)
			else
                --package.loaded["src/layers/faction/FactionTaskLayer"] = nil
				self.taskLayer = require("src/layers/faction/FactionTaskLayer").new(self.factionData, self.bg, self)            
                self.bg:addChild(self.taskLayer)
			end
		end
	end
	self.menuFunc = menuFunc

	-- local title = {
	-- 				{text=game.getStrByKey("faction_total"), pos=cc.p(325, 605)}, 
	-- 				{text=game.getStrByKey("faction_build"), pos=cc.p(480, 605)},
	-- 				{text=game.getStrByKey("faction_member"), pos=cc.p(635, 605)},
 --                    {text=game.getStrByKey("faction_task"), pos=cc.p(790, 605)},
	-- 			}
	-- local tab_control = {}
	-- self.tab_control = tab_control
	-- for i=1,4 do 
	-- 	tab_control[i] = {}
	-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
	-- 	tab_control[i].menu_item:setPosition(title[i].pos)
	-- 	tab_control[i].callback = menuFunc
	-- 	tab_control[i].label = createLabel(tab_control[i].menu_item, title[i].text, getCenterPos(tab_control[i].menu_item), cc.p(0.5, 0.5), 24, true)
	-- end
	-- local menu = creatTabControlMenu(bg, tab_control, 1)
	-- --menuFunc(2)

	-- if isWithoutMenu then
	-- 	--startTimerAction(self, 0.5, false, function() removeFromParent(menu) end)
	-- 	menu:setPosition(cc.p(menu:getPositionX(), menu:getPositionY()+500))
	-- end

	local tab_faction_total = game.getStrByKey("faction_total")
	local tab_faction_build = game.getStrByKey("faction_build")
	local tab_faction_member = game.getStrByKey("faction_member")
	local tab_faction_task = game.getStrByKey("faction_task")

	local tabs = {}
	tabs[#tabs+1] = tab_faction_total
	tabs[#tabs+1] = tab_faction_build
	tabs[#tabs+1] = tab_faction_member
	tabs[#tabs+1] = tab_faction_task

	local TabControl = Mnode.createTabControl(
	{
		src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
		size = 22,
		titles = tabs,
		margins = 2,
		ori = "|",
		align = "r",
		side_title = true,
		cb = function(node, tag)
			menuFunc(tag)
			local title_label = bg:getChildByTag(12580)
			if title_label then title_label:setString(tabs[tag]) end
		end,
		selected = self.selIndex,
	})
	Mnode.addChild(
	{
		parent = bg,
		child = TabControl,
		anchor = cc.p(0, 0.0),
		pos = cc.p(931, 460),
		zOrder = 200,
	})
	self.tab_control = TabControl
	local memu_item = TabControl:tabAtIdx(3)
    self.member_redPoint = createSprite(memu_item , "res/component/flag/red.png" ,cc.p( memu_item:getContentSize().width - 5 ,memu_item:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
	self.member_redPoint:setVisible( false )
	local memu_item = TabControl:tabAtIdx(2)
    self.building_redPoint = createSprite( memu_item , "res/component/flag/red.png" ,cc.p( memu_item:getContentSize().width - 5 , memu_item:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
	self.building_redPoint:setVisible( false )


	SwallowTouches(self)

	self:registerScriptHandler(function(event)
        if event == "enter" then  
        	G_TUTO_NODE:setShowNode(self, SHOW_FACTION)

            local updateRedFunc = function() 
                if G_MAINSCENE ~= nil and G_MAINSCENE.factionEventMap ~= nil then
                   local bV = not not G_MAINSCENE.factionEventMap[1] 
                   self.member_redPoint:setVisible( bV )
                   if self.menberLayer ~= nil then
                   		if self.menberLayer.apply_redPoint then
				        	self.menberLayer.apply_redPoint:setVisible(bV)
				        end
                   end

                   bV = not not G_MAINSCENE.factionEventMap[2]
                   self.building_redPoint:setVisible(bV)
				   if self.buildLayer ~= nil then
						self.buildLayer.boss_redPoint:setVisible(bV)
				   end
                end
            end
            
            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateRedFunc, 0.05, false)
        elseif event == "exit" then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerHandle)
        end
    end)
end

function FactionLayer:updateData(selectIndex)
	self:updateUI(selectIndex)
end

function FactionLayer:updateUI(selectIndex)
	self.menuFunc(selectIndex)
end

function FactionLayer:updateUIEx(factionData)
	if self.mapLayer then
		self.mapLayer:updateFactionInfo(factionData)
	end
end

function FactionLayer:networkHander(buff,msgid)
	local switch = {
		[FACTION_SC_GETFACTIONINFO_RET] = function()
			log("get FACTION_SC_GETFACTIONINFO_RET"..msgid)
            local t = g_msgHandlerInst:convertBufferToTable("GetFactionInfoRet", buff)
			self.factionData = {}
			self.factionData.id = t.info.id
			self.factionData.facLv = t.info.lv
			self.factionData.flagLv = t.info.bannerlv
			self.factionData.shopLv = t.info.storelv
			self.factionData.name = t.info.name
			self.factionData.leaderName = t.info.leaderName
			self.factionData.rank = t.info.rank
			self.factionData.menberCount = t.info.allMemberCnt
			self.factionData.money = t.info.money
			self.factionData.notice = t.info.Comment
			self.factionData.myMoney = t.contribution
			--self.factionData.myMoneyTotal = t.cumContrib
			self.factionData.job = t.position
			self.factionData.exp = t.info.facXp
			self.factionData.expMax = getConfigItemByKey("FactionUpdate", "FacLevel", self.factionData.facLv, "upNeedXp")
			G_FACTION_INFO.Money = self.factionData.money
            G_FACTION_INFO.job = self.factionData.job
			dump(self.factionData)
			self:updateData(self.selIndex)
			self:updateUIEx(self.factionData)
		end,
		[FACTION_SC_LEAVEFACTION_RET] = function()
			removeFromParent(self)
		end
		,
		[FACTION_SC_EDITCOMMENT_RET] = function()
            local t = g_msgHandlerInst:convertBufferToTable("EditCommentRet", buff)
			self.factionData.notice = t.comment
			dump(self.factionData.notice)
			self:updateUIEx()

		end
		,
		-- [FACTION_SC_GETALLFACTION_RET] = function()
		-- 	log("FACTION_SC_GETALLFACTION_RET")
		-- 	removeFromParent(self)
		-- end
		-- ,
		[FACTION_SC_FRESHUI] = function()
			log("FACTION_SC_FRESHUI")
            local t = g_msgHandlerInst:convertBufferToTable("FactionFreshUI", buff)
			local id = t.roleSID
			dump(id)
			dump(userInfo.currRoleStaticId)
			if userInfo.currRoleStaticId == id then
				removeFromParent(self)
			else
				local factionId = G_FACTION_INFO.id or require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
                g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETFACTIONINFO, "GetFactionInfo", {["factionID"]=factionId})
			end
		end
		,
		[FACTION_SC_PRAY_SUC] = function()
			log("FACTION_SC_PRAY_SUC")
            local t = g_msgHandlerInst:convertBufferToTable("FactionPrayNotify", buff)
			self.factionData.exp = t.facXp
			self:updateUIEx(self.factionData)
		end
		,
		[FACTION_SC_UPLEVEL_RET] = function() 
			local factionId = (G_FACTION_INFO and G_FACTION_INFO.id) or require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID);
    		g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETFACTIONINFO, "GetFactionInfo", {["factionID"]=factionId})
		end,
	}

 	if switch[msgid] then
 		switch[msgid]()
 	end
end

return FactionLayer