local FactionBuildLayer = class("FactionBuildLayer", require ("src/TabViewLayer") )

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionBuildLayer:ctor(factionData, parentBg, job, index)
	local msgids = {FACTION_SC_GETPRAYINFO_RET,FACTION_SC_PRAY_RET,FACTION_SC_CONTRIBUTE_RET}
	require("src/MsgHandler").new(self,msgids)
    local MRoleStruct = require("src/layers/role/RoleStruct")
    if MRoleStruct ~= nil then
 	    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETPRAYINFO, "GetFactionPrayInfo", {factionID=MRoleStruct:getAttr(PLAYER_FACTIONID)})
        addNetLoading(FACTION_CS_GETPRAYINFO, FACTION_SC_GETPRAYINFO_RET)
    end

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

    --createSprite(baseNode, "res/common/bg/bg-6.png", cc.p(480, 290), cc.p(0.5, 0.5))
  
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

	local tab = {
		{text=game.getStrByKey("faction_qifuta"), 
		func=function() 
				self.rightBg:removeAllChildren()

                --package.loaded["src/layers/faction/FactionQFTLayer"] = nil
				local layer = require("src/layers/faction/FactionQFTLayer").new(factionData, self.rightBg, self)
				self.rightBg:addChild(layer)
			 end},
		{text=game.getStrByKey("faction_baibaoge"), 
		func=function()
				self.rightBg:removeAllChildren() 

                --package.loaded["src/layers/faction/FactionShopLayer"] = nil
				local layer = require("src/layers/faction/FactionShopLayer").new(factionData, self.rightBg)
				self.rightBg:addChild(layer)
			end},
		{text=game.getStrByKey("faction_juyitang"), 
		func=function() 
				self.rightBg:removeAllChildren() 

				--package.loaded["src/layers/faction/FactionJYTLayer"] = nil
				local layer = require("src/layers/faction/FactionFBLayer").new(factionData, self.rightBg)
				self.rightBg:addChild(layer)
			end},
		{text=game.getStrByKey("faction_zhanqitai"), 
		func=function() 
				self.rightBg:removeAllChildren()
				
                --package.loaded["src/layers/faction/FactionBannerLayer"] = nil
				local layer = require("src/layers/faction/FactionBannerLayer").new(factionData, self.rightBg)
				self.rightBg:addChild(layer)
			end},
		{text=game.getStrByKey("faction_yishiting"), 
		func=function() 
				self.rightBg:removeAllChildren()
				
                --package.loaded["src/layers/faction/FactionYSTLayer"] = nil
				local layer = require("src/layers/faction/FactionYSTLayer").new(factionData, self.rightBg)
				self.rightBg:addChild(layer)
			end},
		{text=game.getStrByKey("faction_junjichu"), 
		func=function() 
				self.rightBg:removeAllChildren()
				
                --package.loaded["src/layers/faction/FactionYSTLayer"] = nil
				local layer = require("src/layers/faction/FactionJunjichuLayer").new(factionData, self.rightBg)
				self.rightBg:addChild(layer)
			end},	
     --[[   {text=game.getStrByKey("faction_notopen"), 
		func=function() 
				self.rightBg:removeAllChildren()
			end},
        ]]
	}
	self.tab = tab

	local textTab = {}
	for i,v in ipairs(tab) do
		textTab[i] = tab[i].text
	end

	local callback = function(idx)
		log("idx = "..idx)
		if tab[idx].func then
			tab[idx].func()
		end
	end
	self.leftSelectNode = require("src/LeftSelectNode").new(leftBg, textTab, cc.size(200, 465), cc.p(2, 30), callback)
	-- tab[index or 1].func()
	self:select(index or 1)
	--startTimerAction(self, 0.0, false, function() self:select(index or 1) end)

	-------------------------------------------------------

	local targetCell = self.leftSelectNode:getTableView():cellAtIndex(2)
	if targetCell then
		self.boss_redPoint = createSprite(targetCell, "res/component/flag/red.png", cc.p(160, 50), cc.p(0.5, 0.5))
		local showRedPoint = false
		if G_MAINSCENE.factionEventMap ~= nil then
			showRedPoint = G_MAINSCENE.factionEventMap[2] or false
		end
		self.boss_redPoint:setVisible(showRedPoint)
	end

end

function FactionBuildLayer:select(index)
	-- self.leftSelectNode:tableCellTouched(self.leftSelectNode:getTableView(), self.leftSelectNode:getTableView():cellAtIndex(index+1))
	dump(index)
	dump(self.leftSelectNode:getTableView():cellAtIndex(index-1))
	--startTimerAction(self, 0.1, false, function() 
	--	self.leftSelectNode:tableCellTouched(self.leftSelectNode:getTableView(), self.leftSelectNode:getTableView():cellAtIndex(index-1))
	--	end)
    self.leftSelectNode:tableCellTouched(self.leftSelectNode:getTableView(), self.leftSelectNode:getTableView():cellAtIndex(index-1))
	self.tab[index].func()
end

function FactionBuildLayer:changeRed(index, isRed)
	log("FactionBuildLayer:changeRed index = "..index)
	local button
	local tab = self.leftSelectNode:getTableView():cellAtIndex(index-1)
	if tab then
		button = tab:getChildByTag(10)
	end
	if button then
		button:removeChildByTag(100)
		log("test 1")
		if isRed then
			log("test 2")
			dump(button:getContentSize())
			local redSpr = createSprite(button, "res/component/flag/red.png", cc.p(button:getContentSize().width - 5, button:getContentSize().height - 15), cc.p(0.5, 0.5))
			redSpr:setTag(100)
		end
	end
end

function FactionBuildLayer:networkHander(buff, msgid)
	local switch = {
		[FACTION_SC_GETPRAYINFO_RET] = function()    
            local t = g_msgHandlerInst:convertBufferToTable("GetFactionPrayInfoRet", buff) 
            dump(t.infos)

            local num = #t.infos
            for i=1, num do
                if t.infos[i].prayType == 1 then
                	if t.infos[i].dayLeftCount > 0 then
            			self:changeRed(1, true)
		            else
		            	self:changeRed(1, false)
                	end
                end
            end
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionBuildLayer