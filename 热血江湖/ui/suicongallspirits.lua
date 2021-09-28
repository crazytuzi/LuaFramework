-------------------------------------------------------
module(..., package.seeall)

local require = require;

-- local ui = require("ui/base");
local ui = require("ui/add_sub")

local RowitemCount = 5
local DEFAULT_COUNT = 25
-------------------------------------------------------

wnd_suicongAllSpirits= i3k_class("wnd_suicongAllSpirits",ui.wnd_add_sub)

local LAYER_XINFA = "ui/widgets/scwkt2"
local LAYER_ITEMT = "ui/widgets/scwkt"
local BOOKS_ITEM_SRC = "ui/widgets/zqqsbgt"

function wnd_suicongAllSpirits:ctor()
	self._info = nil
	self.bookCount = 0
	self.bookGirdCount = 0
	self.selectBookId = 0

	self.current_num = 0
	self.current_add_num = 0

	self.currClickBtn = nil
	self.chosenIconNode = nil
end

function wnd_suicongAllSpirits:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll 
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.bagGrid = widgets.bagGrid
	self.spiritsGrid = widgets.spiritsGrid
	self.spiritsRed = widgets.spiritsRed
	self.bookRed	= widgets.bookRed

	self.currClickBtn = widgets.spirits_btn
	self.bag_btn = widgets.bag_btn
	widgets.bag_btn:onClick(self, self.showSpiritsOrBag)
	widgets.spirits_btn:onClick(self, self.showSpiritsOrBag)
	self.currClickBtn:stateToPressed()

	self.bookScroll = widgets.bookScroll
	self.bookScroll:setBounceEnabled(false)
	widgets.saveBtn:onClick(self, self.saveBook)
	widgets.getBtn:onClick(self, self.takeoutBook)

	self.itemName = widgets.itemName
	self.save_red = widgets.save_red
	self.sale_count = widgets.sale_count

	widgets.jia:onTouchEvent(self, self.onAdd)
	widgets.jian:onTouchEvent(self, self.onSub)
	widgets.max:onTouchEvent(self, self.onMax)
	widgets.tips:setText(i3k_get_string(16944))
	self.sale_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.sale_count:addEventListener(function(eventType)
		if eventType == "ended" then
			local num = tonumber(self.sale_count:getText()) or 1
			
			if num < 1 then
				num = 1
			end
			if num > self.current_add_num then
				num = self.current_add_num
			end
			self.current_num = num
			self.sale_count:setText(num)
		end
	end)
end

function wnd_suicongAllSpirits:refresh()
	self:updateScrollData()

	self.current_num = 0
	self.current_add_num = 0
	self.sale_count:setText(self.current_num)
	self:updateSaveRed()
	self:updateBookmark()
end

function wnd_suicongAllSpirits:updateScrollData(spiritID)
	local item = self:sorItem()
	self.scroll:removeAllChildren()
	local jumpIndex = 0
	if next(item) then
		for i,e in ipairs(item) do
			local layer = require(LAYER_XINFA)()
			local widget = layer.vars
			if e.order > -1000 then
				widget.btn:stateToPressed()
				widget.level:show()
				widget.name:show()
				widget.name2:hide()
				widget.isHave:hide()
				widget.level:setText(e.level .. "级")
			else
				widget.isHave:show()
				widget.name2:show()
				widget.name:hide()
				widget.level:hide()
				widget.btn:stateToNormal()
			end
			widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_suicong_spirits[e.id][1].icon))
			widget.name:setText(i3k_db_suicong_spirits[e.id][1].name)
			widget.name2:setText(i3k_db_suicong_spirits[e.id][1].name)
			widget.btn:onClick(self, self.selectSpiritsData, {info = e, cselect = widget.select})
			widget.redPoint:setVisible(g_i3k_game_context:getWuKuRedPointVisibleById(e.id))
			if spiritID or self._info then
				if spiritID == e.id or self._info.id == e.id then
					jumpIndex = i
					local tab = {info = e, cselect = widget.select}
					self:selectSpiritsData(nil, tab)
				end
			else 
				if i==1 then
					local tab = {info = e, cselect = widget.select}
					self:selectSpiritsData(nil, tab)
				end
			end
			self.scroll:addItem(layer)
		end
		if jumpIndex ~= 0 then
			self.scroll:jumpToChildWithIndex(jumpIndex)
		end
	end
end

function wnd_suicongAllSpirits:selectSpiritsData(sender, data)
	self:updateSelect()
	data.cselect:setImage(g_i3k_db.i3k_db_get_icon_path(2988))
	self._info = data.info
	self:showSpiritsData()
end

function wnd_suicongAllSpirits:showSpiritsData()
	local info = self._info
	local cfg = i3k_db_suicong_spirits[info.id][info.level + 1]
	local tmp = {}
	tmp[1] = info
	tmp[2] = cfg

	self._layout.vars.scroll1:removeAllChildren()
	if info.order < -1000 then
		self._layout.vars.gird1:show()
		self._layout.vars.root3:show()
		self._layout.vars.root1:hide()
		self._layout.vars.root2:hide()
		self._layout.vars.label3:show()
		self._layout.vars.level3:show()
		self._layout.vars.label3:setText("等级:")
		self._layout.vars.desc3:setText(info.desc)
		self._layout.vars.level3:setText(info.level)
		self._layout.vars.icon3:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_suicong_spirits[info.id][1].icon))
		self._layout.vars.name3:setText(i3k_db_suicong_spirits[info.id][1].name)
		self._layout.vars.showMax:hide()
		for i=1, 2 do
			local itemId = info["needItemId".. i]
			if itemId ~= 0 then
				local layer = require(LAYER_ITEMT)()
				local widget = layer.vars
				widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
				widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
				widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
				widget.item_Bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
				widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemId))

				local haveCount = 0
				local needCount = info["needItemCount".. i]
				local haveStr
				if itemId == g_BASE_ITEM_COIN then
					haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
					haveStr = needCount
				else
					haveCount =g_i3k_game_context:getPetBooksWithId(itemId)
					haveStr = haveCount .. "/" .. needCount
				end

				widget.item_count:setText(haveStr)

				widget.item_count:setTextColor(g_i3k_get_cond_color(haveCount >= needCount))
				widget.tip_btn:onClick(self, self.onTips, cfg["needItemId" .. i])
				self._layout.vars.scroll1:addItem(layer)
			end
			
		end
		self._layout.vars.up_btn:onClick(self, self.upLevelBtn, info) --解锁
		self._layout.vars.btn_label:setText("解锁")
	elseif cfg then
		self._layout.vars.gird1:show()
		self._layout.vars.root3:hide()
		self._layout.vars.root1:show()
		self._layout.vars.root2:show()
		self._layout.vars.up_btn:show()
		self._layout.vars.showMax:hide()

		for i = 1, 2 do
			self._layout.vars["label" .. i]:show()
			self._layout.vars["level" .. i]:show()
			self._layout.vars["label" .. i]:setText("等级:")
			self._layout.vars["desc" .. i]:setText(tmp[i].desc)
			self._layout.vars["level" .. i]:setText(tmp[i].level)
			self._layout.vars["icon_" .. i]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_suicong_spirits[info.id][1].icon))
			self._layout.vars["name_" .. i]:setText(i3k_db_suicong_spirits[info.id][1].name)
			local itemId = cfg["needItemId".. i]
			if itemId ~= 0 then
				local layer = require(LAYER_ITEMT)()
				local widget = layer.vars
				widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
				widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
				widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
				widget.item_Bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
				widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemId))

				local haveCount = 0
				local needCount = cfg["needItemCount".. i]
				local haveStr
				if info["needItemId".. i] == g_BASE_ITEM_COIN then
					haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
					haveStr = needCount
				else
					haveCount = g_i3k_game_context:getPetBooksWithId(itemId)
					haveStr = haveCount .. "/" .. needCount
				end

				widget.item_count:setText(haveStr)
				widget.item_count:setTextColor(g_i3k_get_cond_color(haveCount >= needCount))
				widget.tip_btn:onClick(self, self.onTips, cfg["needItemId" .. i])
				self._layout.vars.scroll1:addItem(layer)
			end
		end
		self._layout.vars.up_btn:onClick(self, self.upLevelBtn, cfg) --升级
		self._layout.vars.btn_label:setText("升级")
	elseif not cfg then
		self._layout.vars.gird1:hide()
		self._layout.vars.root3:show()
		self._layout.vars.label3:show()
		self._layout.vars.level3:show()
		self._layout.vars.showMax:show()
		self._layout.vars.label3:setText("等级:")
		self._layout.vars.desc3:setText(info.desc)
		self._layout.vars.level3:setText(info.level)
		self._layout.vars.icon3:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_suicong_spirits[info.id][1].icon))
		self._layout.vars.name3:setText(i3k_db_suicong_spirits[info.id][1].name)
	end
end

function wnd_suicongAllSpirits:upLevelBtn(sender, info)
	local count = 0
	local nCount = 0
	local tmp = {}
	for i=1, 2 do
		local itemId = info["needItemId" .. i]
		if itemId ~= 0 then
			count = count + 1
			local haveCount = 0
			if itemId == g_BASE_ITEM_COIN then
				haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
			else
				haveCount = g_i3k_game_context:getPetBooksWithId(itemId)
			end

			if haveCount >= info["needItemCount" .. i] then
				nCount = nCount + 1
				tmp[itemId] = info["needItemCount" .. i]
			end
		end
	end
	if nCount == count then
		local fun = function ()
			for k,v in pairs(tmp) do
				if k == g_BASE_ITEM_COIN then
					g_i3k_game_context:UseCommonItem(k, v)
				else
					g_i3k_game_context:subPetBook(k,v)
				end
			end
		end
		i3k_sbean.petspirit_lvlup(info.id, info.level, fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("材料不足，操作失败"))
	end
end

function wnd_suicongAllSpirits:sorItem()
	local a = {}
	a[1] = {b =1 }
	a[2] = {b = 1}
	for _,e in ipairs(a) do
		e.c = 1
	end
	for i,e in ipairs(a) do
		a[i].d = 2
	end
	local i = {a=1}
	i.c = 2
	local item = {}
	local spirits = g_i3k_game_context:getPetAllSpirits()
	for _,e in ipairs(i3k_db_suicong_spirits) do
		for i,v in ipairs(e) do
			if spirits[v.id] then
				if spirits[v.id] == v.level then
					v.order = 1 - v.id
					table.insert(item, v)
				end
			else
				if v.level == 1 then
					v.order = -1000-v.id
					table.insert(item,v)
				end
			end
			
		end
	end
	table.sort(item, function (a,b)
			return a.order > b.order
		end)
	return item
end

function wnd_suicongAllSpirits:updateSelect()
	local allRoot = self.scroll:getAllChildren()
	for i, e in pairs(allRoot) do
		e.vars.select:setImage(g_i3k_db.i3k_db_get_icon_path(2987))
	end
end

function wnd_suicongAllSpirits:onTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

---书包部分
function wnd_suicongAllSpirits:getBooksInBag()
	local books = {}

	for k,v in pairs(g_i3k_game_context:getPetBooks()) do
		table.insert(books, {sortid = g_i3k_db.i3k_db_get_bag_item_order(k), id = k, count = v})
	end

	table.sort(books,function (a,b)
		return a.sortid < b.sortid
	end)
	return books
end

function wnd_suicongAllSpirits:updateBooksScroll()
	local books = self:getBooksInBag()

	local allItem = self.bookScroll:getAllChildren()

	for i = 1 , #allItem do
		self:clearCell(allItem[i].vars)
	end

	self.bookCount = 0
	self.chosenIconNode = nil
	for k = 1, #books do
		local id, count = books[k].id, books[k].count
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(id)
		local cell_count = g_i3k_get_use_bag_cell_size(count, stack_count)
		for i = 1, cell_count do
			self.bookCount = self.bookCount + 1
			local itemCount = i == cell_count and count-(cell_count-1)*stack_count or stack_count
			self:updateCell(allItem[k].vars, id, itemCount)
		end
	end
end

function wnd_suicongAllSpirits:updateCell(widget, id, count)
	widget.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.itemIcon:show():setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widget.count:show():setText(count)
	widget.lock:show():setVisible(id>0)
	widget.item_btn:show():onClick(self, self.onSelectBook, {id = id, count = count, chosenIcon = widget.chosenIcon})
	if id == self.selectBookId then
		widget.chosenIcon:show()
		self.chosenIconNode = widget.chosenIcon
	end
end

function wnd_suicongAllSpirits:onSelectBook(sender, args)
	if self.selectBookId == id then
		return
	end
	args.chosenIcon:show()
	if self.chosenIconNode then
		self.chosenIconNode:hide()
	end
	self.chosenIconNode = args.chosenIcon
	self:updateSeleCountInfo(args.id, 1,args.count)
end

function wnd_suicongAllSpirits:updateSeleCountInfo(id, num, count)
	self.selectBookId = id or 0
	self.current_num = num or 0
	self.current_add_num = count or 0
	self.sale_count:setText(self.current_num)
	self.itemName:setText(g_i3k_db.i3k_db_get_common_item_name(self.selectBookId))
end

function wnd_suicongAllSpirits:clearCell(widget)
	widget.bgIcon:setImage(g_i3k_get_icon_frame_path_by_rank(0))
	widget.itemIcon:hide()
	widget.count:hide()
	widget.lock:hide()
	widget.item_btn:hide()
	widget.chosenIcon:hide()
end

function wnd_suicongAllSpirits:getCellCount(items)
	local cell_count = 0
	for id, count in pairs(items) do
		cell_count = cell_count + g_i3k_get_use_bag_cell_size(count, g_i3k_db.i3k_db_get_bag_item_stack_max(id))
	end
	return cell_count
end

function wnd_suicongAllSpirits:InitBooksScroll()
	local totalItem = self:getCellCount(g_i3k_game_context:getPetBooks())
	
	self.bookGirdCount = totalItem < DEFAULT_COUNT and DEFAULT_COUNT or math.ceil(totalItem/RowitemCount)*RowitemCount
	self.bookScroll:addChildWithCount(BOOKS_ITEM_SRC, RowitemCount, self.bookGirdCount)
	self:updateBooksScroll()
	self:initAddOrSubFunc()
	self:updateSeleCountInfo()
end

function wnd_suicongAllSpirits:changeBookScroll(items)
	local Books = g_i3k_game_context:getPetBooks()
	if items then
		local totalItem = self:getCellCount(g_i3k_game_context:getPetBooks())

		if totalItem > self.bookGirdCount then
			local need_cnt = math.ceil((totalItem-self.bookGirdCount)/RowitemCount)*RowitemCount
			self.bookScroll:addItemAndChild(BOOKS_ITEM_SRC, RowitemCount, need_cnt)
			self.bookGirdCount = self.bookGirdCount + need_cnt
		end
	end

	if self.selectBookId ~= 0 and Books[self.selectBookId] then
		self:updateSeleCountInfo(self.selectBookId, 1, Books[self.selectBookId])
	else
		self:updateSeleCountInfo()
	end

	self:updateBooksScroll()
	self:updateSaveRed()
end

function wnd_suicongAllSpirits:updateSaveRed()
	local red = g_i3k_game_context:havePetBooksInBag()
	self.save_red:setVisible(red)
	self.bookRed:setVisible(red)
end

function wnd_suicongAllSpirits:initAddOrSubFunc()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AllSpirits, "updateNum")
	end
end

function wnd_suicongAllSpirits:updateNum()
	self.sale_count:setText(self.current_num)
end

function wnd_suicongAllSpirits:takeoutBook()
	if self.selectBookId == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16914))
	end
	local books = {}
	books[self.selectBookId] = self.current_num
	i3k_sbean.petbook_popReq(books)
end

function wnd_suicongAllSpirits:saveBook()
	if g_i3k_game_context:havePetBooksInBag() then
		i3k_sbean.petbook_pushReq(g_i3k_game_context:getPetBooksInBag())
	else
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16915))
	end
end

function wnd_suicongAllSpirits:showSpiritsOrBag(sender)
	if self.currClickBtn == sender then
		return
	end

	if self.bag_btn == sender then
		self.bagGrid:show()
		self.spiritsGrid:hide()
		if self.bookGirdCount ~= 0 then
			self:changeBookScroll()
		else
			self:InitBooksScroll()
		end
	else
		self.bagGrid:hide()
		self.spiritsGrid:show()
		self:updateScrollData()
	end
	sender:stateToPressed()
	self.currClickBtn:stateToNormal()
	self.currClickBtn = sender
end

function wnd_suicongAllSpirits:updateBookmark()
	self.spiritsRed:setVisible(g_i3k_game_context:getWuKuRedPointVisible())
end

function wnd_create(layout)
	local wnd = wnd_suicongAllSpirits.new()
		wnd:create(layout)
	return wnd
end
