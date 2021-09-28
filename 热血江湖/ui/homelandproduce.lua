module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_homeLandProduce = i3k_class("wnd_homeLandProduce", ui.wnd_base)

local ITEMWIDGET = "ui/widgets/jiayuansct1"
local NAMEWIDGET = "ui/widgets/jiayuansct2"
local TYPEWIDGET = "ui/widgets/jiayuansct3"

local FurnitureType = 1
local SundriesType = 2
local MaxCount = 5

--local startPos, endPos = {}, {}

function wnd_homeLandProduce:ctor()
	self._state = SundriesType
	self._furniture = {}
	self._isCanProduce = false
	self._isProducing = false
	self._isAllProduce = false
	self._timeCount = 0
	self._produceType = nil
	self._produceIndex = 1
	self._curPage = 1
	self._maxPage = 1
	--self._rotation = {x = 0, y = math.pi * 0.5}
end

function wnd_homeLandProduce:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.furniture_btn:onClick(self, self.onFurnitureBtn)
	self._layout.vars.sundries_btn:onClick(self, self.onSundriesBtn)
	self._layout.vars.rightBtn:onClick(self, self.onNextPage)
	self._layout.vars.leftBtn:onClick(self, self.onLastPage)
	self._layout.vars.product_btn:onClick(self, self.onProduceBtn, false)
	self._layout.vars.product_all:onClick(self, self.onProduceBtn, true)
	--self._layout.vars.rotateBtn:onTouchEvent(self, self.onRotateBtn)
end

function wnd_homeLandProduce:refresh()
	self._state = FurnitureType
	self._layout.vars.furniture_btn:stateToPressed()
	self._layout.vars.sundries_btn:stateToNormal()
	self:setFurnitureData()
	self:setRedPoint()
	self:sortFurniture()
	self:updateFurnitureData()
end

function wnd_homeLandProduce:setFurnitureData()
	for k, v in pairs(i3k_db_home_land_production) do
		if i3k_db_home_land_base.produceCfg.furnitureTypes[v.type] then
			if not self._furniture[FurnitureType] then
				self._furniture[FurnitureType] = {}
			end
			if not self._furniture[FurnitureType][v.type] then
				self._furniture[FurnitureType][v.type] = {}
			end
			table.insert(self._furniture[FurnitureType][v.type], v)
		elseif i3k_db_home_land_base.produceCfg.sundriesTypes[v.type] then
			if not self._furniture[SundriesType] then
				self._furniture[SundriesType] = {}
			end
			if not self._furniture[SundriesType][v.type] then
				self._furniture[SundriesType][v.type] = {}
			end
			table.insert(self._furniture[SundriesType][v.type], v)
		end
	end
end

function wnd_homeLandProduce:setRedPoint()
	for i = 1, 2 do
		for k, v in pairs(self._furniture[i]) do
			for n, m in ipairs(v) do
				local canProduce = true
				for _, j in ipairs(m.need_items) do
					if g_i3k_game_context:GetCommonItemCanUseCount(j.id) < j.count then
						canProduce = false
						break
					end
				end
				
				if m.need_home_lvl > g_i3k_game_context:GetHomeLandLevel() or m.need_role_lvl > g_i3k_game_context:GetLevel() then
					canProduce = false	
				end
				
				m.redPoint = canProduce
			end
		end
	end
end

function wnd_homeLandProduce:sortFurniture()
	for i = 1, 2 do
		for k, v in pairs(self._furniture[i]) do
			for n, m in ipairs(v) do
				if m.need_home_lvl <= g_i3k_game_context:GetHomeLandLevel() then
					m.sortId = m.id
				else
					m.sortId = m.id + 10000
				end
				if m.need_role_lvl > g_i3k_game_context:GetLevel() then
					m.sortId = m.sortId + 1000
				end
			end
		end
		for k, v in pairs(self._furniture[i]) do
			table.sort(v, function (a, b)
				return a.sortId < b.sortId
			end)
		end
	end
end

function wnd_homeLandProduce:onFurnitureBtn(sender)
	self:onCancelBtn()
	if self._state ~= FurnitureType then
		self._state = FurnitureType
		self._layout.vars.furniture_btn:stateToPressed()
		self._layout.vars.sundries_btn:stateToNormal()
		self:updateFurnitureData()
	end
end

function wnd_homeLandProduce:onSundriesBtn(sender)
	self:onCancelBtn()
	if self._state ~= SundriesType then
		self._state = SundriesType
		self._layout.vars.furniture_btn:stateToNormal()
		self._layout.vars.sundries_btn:stateToPressed()
		self:updateFurnitureData()
	end
end

function wnd_homeLandProduce:updateFurnitureData()
	self._layout.vars.type_scroll:removeAllChildren()
	self._layout.vars.type_scroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	self._produceType = nil
	local info = {}
	if self._state == FurnitureType then
		for k, _ in pairs(i3k_db_home_land_base.produceCfg.furnitureTypes) do
			table.insert(info, {sortId = k})
		end
	else
		for k, _ in pairs(i3k_db_home_land_base.produceCfg.sundriesTypes) do
			table.insert(info, {sortId = k})
		end
	end
	table.sort(info, function(a, b)
		return a.sortId < b.sortId
	end)
	for _, v in ipairs(info) do
		if self._furniture[self._state][v.sortId] then
			if not self._produceType then
				self._produceType = v.sortId
			end
			local node = require(TYPEWIDGET)()
			node.vars.type_btn:onClick(self, self.changeProduceType, v.sortId)
			node.vars.type_btn:setTag(v.sortId)
			node.vars.type_text:setText(i3k_db_home_land_produce_name[v.sortId])
			node.vars.red_icon:hide()
			if g_i3k_game_context:getHomeLandProduceRedPoint() then
				for _, j in ipairs(self._furniture[self._state][v.sortId]) do
					if j.redPoint then
						node.vars.red_icon:show()
						break
					end
				end
			end
			self._layout.vars.type_scroll:addItem(node)
		end
	end
	self:updateProduceType()
end

function wnd_homeLandProduce:changeProduceType(sender, produceType)
	self:onCancelBtn()
	self._produceType = produceType
	self:updateProduceType()
end

function wnd_homeLandProduce:updateProduceType()
	self._curPage = 1
	local children = self._layout.vars.type_scroll:getAllChildren()
	for k, v in ipairs(children) do
		if v.vars.type_btn:getTag() == self._produceType then
			v.vars.type_btn:stateToPressed(true)
		else
			v.vars.type_btn:stateToNormal(true)
		end
	end
	self:updateLeftScroll()
end

function wnd_homeLandProduce:updateLeftScroll()
	local produce = self._furniture[self._state][self._produceType]
	local min = 1
	local max = #produce
	if self._state == FurnitureType then
		min = (self._curPage - 1) * MaxCount + 1
		self._maxPage, left = math.modf(#produce / MaxCount)
		if left > 0 then
			self._maxPage = self._maxPage + 1
		end
		if self._curPage < self._maxPage then
			max = self._curPage * MaxCount
		end
	else
		self._curPage = 1
		self._maxPage = 1
	end
	self._layout.vars.pageLable:setText(string.format("第%s/%s页", self._curPage, self._maxPage))
	self._layout.vars.left_scroll:removeAllChildren()
	for i = min, max do
		local info = produce[i]
		local node = require(NAMEWIDGET)()
		node.vars.production_btn:onClick(self, self.changeLeftNameBtn, i)
		node.vars.production_rank:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.produce_id))
		node.vars.production_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.produce_id))
		node.vars.lock:setVisible(info.produce_id > 0)
		if info.produce_count > 1 then
			node.vars.production_name:setText(g_i3k_db.i3k_db_get_common_item_name(info.produce_id).."*"..info.produce_count)
		else
			node.vars.production_name:setText(g_i3k_db.i3k_db_get_common_item_name(info.produce_id))
		end
		node.vars.production_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(info.produce_id)))
		node.vars.production_exp:hide()
		node.vars.production_lvl:hide()
		node.vars.red_icon:hide()
		local red = false

		if info.need_home_lvl > g_i3k_game_context:GetHomeLandLevel() then
			node.vars.need_text:show()
			node.vars.need_text:setText(string.format("需要家园%s级", info.need_home_lvl))
		elseif info.need_role_lvl > g_i3k_game_context:GetLevel() then
			--node.vars.production_lvl:show()
			--node.vars.production_lvl:setText(info.need_role_lvl.."级")
			node.vars.need_text:setText(string.format("需要人物%s级", info.need_role_lvl))
		else
			red = true
			node.vars.need_text:hide()
		end
		
		if g_i3k_game_context:getHomeLandProduceRedPoint() then
			local value = red and info.redPoint
			node.vars.red_icon:setVisible(value)
		end
		
		self._layout.vars.left_scroll:addItem(node)
	end
	self._produceIndex = min
	self:updateLeftNameBtn()
end

function wnd_homeLandProduce:changeLeftNameBtn(sender, index)
	self:onCancelBtn()
	self._produceIndex = index
	self:updateLeftNameBtn()
end

function wnd_homeLandProduce:updateLeftNameBtn()
	local index = self._produceIndex
	if self._state == FurnitureType then
		index = self._produceIndex - (self._curPage - 1) * MaxCount
	end
	local children = self._layout.vars.left_scroll:getAllChildren()
	for k ,v in ipairs(children) do
		if k == index then
			v.vars.production_bg:setImage(g_i3k_db.i3k_db_get_icon_path(706))
		else
			v.vars.production_bg:setImage(g_i3k_db.i3k_db_get_icon_path(707))
		end
	end
	self:updateNeedData()
end

function wnd_homeLandProduce:updateNeedData()
	local produce = self._furniture[self._state][self._produceType][self._produceIndex]
	self._rotation = {x = 0, y = math.pi * 0.5}
	if produce.produce_count > 1 then
		self._layout.vars.production_name:setText(g_i3k_db.i3k_db_get_common_item_name(produce.produce_id).."*"..produce.produce_count)
	else
		self._layout.vars.production_name:setText(g_i3k_db.i3k_db_get_common_item_name(produce.produce_id))
	end
	self._layout.vars.production_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(produce.produce_id)))
	self._layout.vars.production_lvl:hide()
	self._layout.vars.production_limit:hide()
	self._layout.vars.unBindLabel:setText(produce.produce_id > 0 and "绑定" or "非绑定")
	self._layout.vars.production_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(produce.produce_id))
	if i3k_db_new_item[produce.produce_id].type == UseItemFurniture then
		self._layout.vars.rotateBtn:enableWithChildren()
		self._layout.vars.produce_root:hide()
		self._layout.vars.production_lvl:show()
		self._layout.vars.production_limit:show()
		local furnitureData = g_i3k_db.i3k_db_get_furniture_data(i3k_db_new_item[produce.produce_id].args1, i3k_db_new_item[produce.produce_id].args2)
		self._layout.vars.model:show()
		local pos = self._layout.vars.model:getPosition()
		self._layout.vars.model:setPosition(pos.x, furnitureData.produceHeight)
		self._layout.vars.model:setSprite(i3k_db_models[furnitureData.models[1]].path)
		self._layout.vars.model:setSprSize(i3k_db_models[furnitureData.models[1]].uiscale)
		self._layout.vars.model:setCameraAngle(furnitureData.angle.x, furnitureData.angle.y, furnitureData.angle.z)
		self._layout.vars.production_lvl:setText("限制摆放："..furnitureData.limitCount)
		self._layout.vars.production_limit:setText("家俱等级："..furnitureData.level)
		--ui_set_hero_model(self._layout.vars.model, modelId)
	else
		self._layout.vars.rotateBtn:disableWithChildren()
		self._layout.vars.produce_root:show()
		self._layout.vars.production_rank:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(produce.produce_id))
		self._layout.vars.production_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(produce.produce_id))
		self._layout.vars.model:hide()
	end
	self._layout.vars.need_scroll:removeAllChildren()
	local canProduce = true
	for k, v in ipairs(produce.need_items) do
		if v.id ~= 0 then
			local node = require(ITEMWIDGET)()
			node.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
			node.vars.item_btn:onClick(self, self.onItemInfo, v.id)
			local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
			node.vars.item_count:setText(string.format("%s/%s", haveCount, v.count))
			node.vars.item_count:setTextColor(g_i3k_get_cond_color(v.count <= haveCount))
			if v.count > haveCount then
				canProduce = false
			end
			self._layout.vars.need_scroll:addItem(node)
		end
	end
	
	if produce.need_home_lvl > g_i3k_game_context:GetHomeLandLevel() or produce.need_role_lvl > g_i3k_game_context:GetLevel() then
		canProduce = false	
	end
	
	if canProduce then
		self._layout.vars.product_btn:enableWithChildren()
		self._layout.vars.product_all:enableWithChildren()
		self._isCanProduce = true
	else
		self._layout.vars.product_btn:disableWithChildren()
		self._layout.vars.product_all:disableWithChildren()
		self._isCanProduce = false
	end
end

function wnd_homeLandProduce:onProduceBtn(sender, isAll)
	self._isProducing = true
	self._isAllProduce = isAll
	self._layout.vars.producing:show()
	self._layout.vars.production_cancel:onClick(self, self.onCancelBtn)
	--self._layout.vars.produce_load:setPercent(0)
end

function wnd_homeLandProduce:onCancelBtn(sender)
	self._layout.vars.producing:hide()
	self._isProducing = false
	self._isAllProduce = false
	self._timeCount = 0
end

function wnd_homeLandProduce:onNextPage(sender)
	if self._curPage < self._maxPage then
		self._curPage = self._curPage + 1
		self:updateLeftScroll()
	end
end

function wnd_homeLandProduce:onLastPage(sender)
	if self._curPage > 1 then
		self._curPage = self._curPage - 1
		self:updateLeftScroll()
	end
end

--生产成功之后刷新
function wnd_homeLandProduce:updateProduceData()
	self:updateNeedData()
	if self._isAllProduce and self._isCanProduce then
		self._isProducing = true
		self._layout.vars.producing:show()
		self._layout.vars.production_cancel:onClick(self, self.onCancelBtn)
	end
end

function wnd_homeLandProduce:onItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

--[[function wnd_homeLandProduce:onRotateBtn(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		self._layout.vars.model:setRotation(self._rotation.y, self._rotation.x)
		startPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
	else
		endPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
		local isEnd = false
		if eventType == ccui.TouchEventType.ended then
			isEnd = true
		end
		self:setModelRotate(isEnd)
	end
end

function wnd_homeLandProduce:setModelRotate(isEnd)
	local btnPos = self._layout.vars.rotateBtn:getPosition()
	local btnSize = self._layout.vars.rotateBtn:getContentSize()
	local minPosX = btnPos.x - btnSize.width / 2
	local maxPosX = btnPos.x + btnSize.width / 2
	local minPosY = btnPos.y - btnSize.height / 2
	local maxPosY = btnPos.y + btnSize.height / 2
	if endPos.x < minPosX then
		endPos.x = minPosX
	elseif endPos.x > maxPosX then
		endPos.x = maxPosX
	end
	if endPos.y < minPosY then
		endPos.y = minPosY
	elseif endPos.y > maxPosY then
		endPos.y = maxPosY
	end
	local angelY = self._rotation.y + math.rad(startPos.x - endPos.x)
	local angelX = self._rotation.x + math.rad(startPos.y - endPos.y)
	if isEnd then
		self._rotation.y = angelY
		self._rotation.x = angelX
	end
	self._layout.vars.model:setRotation(angelY, angelX)
	--self._layout.vars.model:setRotation(self._rotation.y)
end--]]

function wnd_homeLandProduce:onUpdate(dTime)
	if self._isProducing then
		self._timeCount = self._timeCount + dTime
		self._layout.vars.produce_load:setPercent(self._timeCount / i3k_db_home_land_base.produceCfg.timeLimit * 100)
		if self._timeCount >= i3k_db_home_land_base.produceCfg.timeLimit then
			self._timeCount = 0
			self._layout.vars.producing:hide()
			self._isProducing = false
			i3k_sbean.homeland_produce(self._furniture[self._state][self._produceType][self._produceIndex])
		end
	end
end

function wnd_homeLandProduce:onHide()
	g_i3k_game_context:setHomeLandProduceRedPoint(false)
end

function wnd_create(layout)
	local wnd = wnd_homeLandProduce.new();
		wnd:create(layout);
	return wnd;
end
