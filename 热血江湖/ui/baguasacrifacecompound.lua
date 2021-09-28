module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_baguaSacrifaceCompound = i3k_class("wnd_baguaSacrifaceCompound", ui.wnd_base)

local WEIGHT1 = "ui/widgets/baguajipinhct"
local WEIGHT2 = "ui/widgets/baguajipinhct2"
local WEIGHT3 = "ui/widgets/baguajipinhct3"
local DEFAULT_COUNT = 4 --默认格子数

function wnd_baguaSacrifaceCompound:ctor()
	self._suit = {}
	self._curCost = 0
	self._costId = i3k_db_bagua_sacrifice_compound[1].needId
	self._curSuit = 0
	self._curParts = {}
end 

function wnd_baguaSacrifaceCompound:configure()
	local weight = self._layout.vars
	weight.close:onClick(self, self.onCloseUI)
	weight.filterBtn:onClick(self, self.onFiterBt)
	weight.gradeBtn:onClick(self, self.onFiterBt)
	weight.ok:onClick(self, self.onOKBt)
end

function wnd_baguaSacrifaceCompound:refresh()
	self:refreshFiterScroll()
	self:refreshCostImage()
end

function wnd_baguaSacrifaceCompound:onFiterBt()
	local weight = self._layout.vars
	local visible = weight.levelRoot:isVisible()
	weight.levelRoot:setVisible(not visible)
end 

function wnd_baguaSacrifaceCompound:refreshFiterScroll()
	local weight = self._layout.vars
	local scroll = weight.filterScroll
	scroll:removeAllChildren()
	local compoundData = g_i3k_db.i3k_db_get_bagua_sacriface_suit()
    local suitData = {}
	
    for i, v in ipairs(i3k_db_bagua_suit_prop) do
		if compoundData[v.id] then
			suitData[v.id] = v
		end
    end

    local result = {}
    for _, v in pairs(suitData) do
        table.insert(result, v)
    end

    table.sort(
        result,
        function(a, b)
            return a.id < b.id
        end
    )
	
	self._suit = suitData

    for i, v in pairs(result) do
		local weight = require(WEIGHT1)()
        local item = weight.vars
        --local haveCount = g_i3k_game_context:getBaguaCountBySuitId(v.id)
        item.levelLabel:setText(v.name)
        item.levelLabel:setTextColor(v.suitColor)
        item.levelBtn:onClick(
			self,
            function()
                self:choseSuit(v.id)
            end
        )
        scroll:addItem(weight)
    end

    self:choseSuit(result[1].id)
end

function wnd_baguaSacrifaceCompound:choseSuit(suitId)
	self._curSuit = suitId
	self._curParts = {}
	local weight = self._layout.vars
	
	if weight.levelRoot:isVisible() then
		weight.levelRoot:setVisible(false)
	end
	
	weight.gradeLabel:setText(self._suit[suitId].name)
    weight.propScroll:removeAllChildren()
	
    for _, v in ipairs(i3k_db_bagua_suit_prop) do
    	if v.id == suitId then
    		for i = 1, 3 do
    			if v["desc" .. i] ~= "" then
    				local ui = require(WEIGHT2)()
					local node = ui.vars
					
    				if i == 1 then
						node.num:setVisible(true)
    					node.num:setText(i3k_get_string(17816, v.needCnt))
						node.des:setText(v["desc" .. i])
    				else
    					node.des:setText(v["desc" .. i])
						node.num:setVisible(false)
    				end
									
    				if g_i3k_game_context:getBaguaCountBySuitId(v.id) >= v.needCnt then
	    				node.des:setTextColor(g_i3k_get_green_color())
	    			end
					
	    			weight.propScroll:addItem(ui)
    			end
    		end
    	end
    end
	
	weight.sacrifaceScroll:removeAllChildren()	
	local suits = g_i3k_db.i3k_db_get_bagua_suit_sacriface(suitId)
	table.sort(suits, function(a, b) return a.partId < b.partId end)
	local totalItem = #suits
	local cellCount = totalItem < DEFAULT_COUNT and DEFAULT_COUNT or math.ceil(totalItem / DEFAULT_COUNT) * DEFAULT_COUNT
	local all_layer = weight.sacrifaceScroll:addChildWithCount(WEIGHT3, DEFAULT_COUNT, cellCount)
	local cell_index = 1
	
	for _, v in ipairs(suits) do
		local widght = all_layer[cell_index].vars
		widght.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.compoundId, g_i3k_game_context:IsFemaleRole()))
		widght.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.compoundId))
		widght.suo:setVisible(true)
		widght.select:setVisible(false)
		widght.name:setText(g_i3k_db.i3k_db_get_common_item_name(v.compoundId))
		--widght.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.compoundId)))
		widght.bt:onClick(self, self.onItemClick, {info = v, node = widght})	
		cell_index = cell_index + 1
	end
	
	for k = cell_index, cellCount do --显示空格
		if k > totalItem then
			local widght = all_layer[k].vars
			widght.root:setVisible(false)
		end
	end
	
	self:refreshCostTxt(self._curCost, false)
	self._curCost = 0
end

function wnd_baguaSacrifaceCompound:onItemClick(sender, suitInfo)
	local node = suitInfo.node
	local info = suitInfo.info
	local visible = not node.select:isVisible()
	node.select:setVisible(visible)
	self:refreshCostTxt(info.needCnt, visible)
	
	if visible then
		table.insert(self._curParts, info)
	else
		local index = 0
		
		for k, v in ipairs(self._curParts) do
			if v.partId == info.partId then
				index = k
			end
		end
		
		if index ~= 0 then
			table.remove(self._curParts, index)
		end
	end
end

function wnd_baguaSacrifaceCompound:refreshCostTxt(count, flag)
	local weight = self._layout.vars
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(self._costId)
	local ratio = flag and 1 or -1
	self._curCost = self._curCost + ratio * count
	weight.cost:setText(haveCount .. "/" .. self._curCost)
	weight.cost:setTextColor(g_i3k_get_cond_color(haveCount >= self._curCost))
	
	if self._curCost == 0 then
		weight.ok:disableWithChildren()	
	else
		weight.ok:enableWithChildren()	
	end
end

function wnd_baguaSacrifaceCompound:refreshCostImage()
	local weight = self._layout.vars
	weight.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._costId))
	weight.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._costId, g_i3k_game_context:IsFemaleRole()))
	weight.needname:setText(g_i3k_db.i3k_db_get_common_item_name(self._costId))
	weight.needname:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self._costId)))
	weight.tips:onClick(self, function()
		g_i3k_ui_mgr:ShowCommonItemInfo(self._costId)
	end)
end

function wnd_baguaSacrifaceCompound:onOKBt()
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(self._costId)
	
	if self._curCost > haveCount then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17815))
		return
	end
	
	local bagData ={}
	local gainData ={}
	local parts = {}
	
	for _, v in ipairs(self._curParts) do
		bagData[v.compoundId] = 1
		table.insert(gainData, {id = v.compoundId, count = 1})
		parts[v.partId] = true
	end
	
	local isEnough = g_i3k_game_context:IsBagEnough(bagData)
	
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
		return

	end
	
	i3k_sbean.sacrifaceCompound(self._curSuit, parts, {[self._costId] = self._curCost}, gainData)
end

function wnd_create(layout)
	local wnd = wnd_baguaSacrifaceCompound.new();
	wnd:create(layout);
	return wnd;
end
