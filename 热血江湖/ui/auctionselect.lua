-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_auctionSelect = i3k_class("wnd_auctionSelect", ui.wnd_base)

local EQUIP_TYPE =
{
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[8] = true,
}
local TYPE_XINFA = 18 -- 心法类型

function wnd_auctionSelect:ctor()
	self._blue = "FFFFF0D5"
	self._yellow = "FFDBFF7A"

	self._selectLevel = 1 -- 等级
end

function wnd_auctionSelect:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.pageRight:onClick(self, self.onPageRight)
	widgets.pageLeft:onClick(self, self.onPageLeft)
	widgets.levelBtn:onClick(self, self.onLevelBtn)
	widgets.gradeBtn:onClick(self, self.onGradeBtn)

	self._gradeTable = {
		[0] = {nameLabel = self._layout.vars.gradeLabel1, btn = self._layout.vars.gradeBtn1, color = self._yellow},
		[1] = {nameLabel = self._layout.vars.gradeLabel2, btn = self._layout.vars.gradeBtn2, color = g_i3k_get_color_by_rank(1)},
		[2] = {nameLabel = self._layout.vars.gradeLabel3, btn = self._layout.vars.gradeBtn3, color = g_i3k_get_color_by_rank(2)},
		[3] = {nameLabel = self._layout.vars.gradeLabel4, btn = self._layout.vars.gradeBtn4, color = g_i3k_get_color_by_rank(3)},
		[4] = {nameLabel = self._layout.vars.gradeLabel5, btn = self._layout.vars.gradeBtn5, color = g_i3k_get_color_by_rank(4)},
		[5] = {nameLabel = self._layout.vars.gradeLabel6, btn = self._layout.vars.gradeBtn6, color = g_i3k_get_color_by_rank(5)}
	}
	self._gradeTable[0].btn:stateToPressed()
	self._gradeTable[0].nameLabel:setTextColor(self._yellow)
end

function wnd_auctionSelect:onShow()
	-- self:sendCmd(1, "", 1, 0, 0, 0, 1, nil)
end

function wnd_auctionSelect:refresh(itemType, classType)
	self._refreshClassType = classType
	self:sendCmd(itemType, "", 1, 0, 0, 0, classType, nil)
end

-- 服务器模拟器
function wnd_auctionSelect:serverSimulator(itemType, str, page, order, rank, level, classType, callback)
	self:setUIData(itemType, page, rank, level, classType)
	if callback then
		callback(itemType)
	end
end

function wnd_auctionSelect:sendCmd(itemType, str, page, order, rank, level, classType, callback)
	local flag = self:checkGradeOrLevelChange(rank, level)
	if flag then
		page = 1
	end
	self._args =
	{
		itemType = itemType,
		str = str,
		page = page,
		order = order or 2, -- 颜色品质（0所有，1白色。。。）
		rank = rank,
		level = level,
		classType = classType,
		callback = callback,
	}
	local data = self._args

	-- g_i3k_ui_mgr:PopupTipMessage("type="..data.itemType.." page="..data.page.." rank="..data.rank.." level="..data.level.." classType="..(data.classType or "nil"))
	self:serverSimulator(data.itemType, data.str, data.page, data.order, data.rank, data.level, data.classType, data.callback)
end
function wnd_auctionSelect:checkGradeOrLevelChange(grade, level)
	if self._args then
		if grade ~= self._args.rank or level ~= self._args.level then
			return true
		end
	end
	return false
end

function wnd_auctionSelect:onPageChanged(data)
	self:sendCmd(data.itemType, data.str, data.page, data.order, data.rank, data.level, data.classType, data.callback)
end
function wnd_auctionSelect:onPageRight(sender)
	self._args.page = self._args.page + 1
	self:onPageChanged(self._args)
end
function wnd_auctionSelect:onPageLeft(sender)
	if self._args.page == 1 then
		g_i3k_ui_mgr:PopupTipMessage("已经是第一页了")
		return
	end
	self._args.page = self._args.page - 1
	self:onPageChanged(self._args)
end
-- rank & level default 0
-- 设置ui的入口方法。
function wnd_auctionSelect:setUIData(itemType, page, rank, level, classType)
	self:updateBuyScrollLeft(itemType)
	self:updateScrollItems(itemType, page, rank, level, classType)
end

----------------计算数据相关begin--------------------------
function wnd_auctionSelect:getTableName(type)
	for k, v in pairs(g_auction_search) do
		for _, j in ipairs(v) do
			if j == type then
				return k
			end
		end
	end
end
-- 返回一个array
function wnd_auctionSelect:getTableByType(type)
	local tableName = self:getTableName(type)
	local dbName = "i3k_db_auction_select_"..tableName
	local db = _G[dbName]
	return db[type]
end

function wnd_auctionSelect:checkIsEquipByType(type)
	return self:getTableName(type) == "equip" or self:getTableName(type) == "xinfa"
end
-- 获取装备表下面，对应 部位-职业
function wnd_auctionSelect:getEquipTable(type, classType)
	local array = self:getTableByType(type)
	if classType ~= 0 then -- 0表示所有职业
		return array[classType]
	else
		local result = {}
		if self._args.itemType == eEquipArmor then
			for i, j in ipairs(array[1]) do
				table.insert(result, j)
			end
		else
			for k, v in pairs(array)do
				for i, j in ipairs(v) do
					table.insert(result, j)
				end
			end
		end
		return result
	end
end

-- 只分类品质
function wnd_auctionSelect:sortGrade(array, grade)
	if grade == 0 then
		return array
	end
	local result = {}
	for i, v in ipairs(array) do
		if v.quality == grade then
			table.insert(result, v)
		end
	end
	return result
end
-- 只分类等级
function wnd_auctionSelect:sortLevel(array, level)
	if level == 0 then
		return array
	end
	local result = {}
	local a, b = self:getBeginEndLevel(level)
	for i, v in ipairs(array)do
		if a <= v.level  and v.level <= b then
			table.insert(result, v)
		end
	end
	return result
end
-- 输入装备的表，然后根据等级和品质筛选
function wnd_auctionSelect:sortGradeAndLevel(array, grade, level)
	local gradeList = self:sortGrade(array, grade)
	return self:sortLevel(gradeList, level)
end

-- 排序表(优先级： 排序字段 > 等级 > 品质)
function wnd_auctionSelect:sortMap(array)
	local sortImpl = function(a, b, fun)
		if a then
			if a == b then
				return fun
			else
				return a > b
			end
		else
			return fun
		end
	end
	local sortFunc = function (a, b)
		return sortImpl(a.rank, b.rank, sortImpl(a.level, b.level, sortImpl(a.quality, b.quality, sortImpl(a.id, b.id))))
	end
	table.sort(array, sortFunc)
	return array
end
-- 获取需要显示的所有数据
function wnd_auctionSelect:getItemMap(itemType, classType)
	local array = nil
	if self:checkIsEquipByType(itemType) then
		array = self:getEquipTable(itemType, classType)
	else
		array = self:getTableByType(itemType)
	end
	return self:sortMap(array)
end

-- 获取当前页需要显示的数据
function wnd_auctionSelect:getItemMapAtPage(itemType, classType, page, rank, level)
	local pageSize = 10 -- 单页显示的最大数量 TODO
	local array = self:getItemMap(itemType, classType)
	local sortGradeLevel = self:sortGradeAndLevel(array, rank, level)
	local beginIndex = (page - 1) * pageSize + 1
	local endIndex = page * 10
	-- 接取排好序中的一段
	local result = {}
	local count = 0
	for i = beginIndex, endIndex do
		if sortGradeLevel[i] then
			table.insert(result, sortGradeLevel[i])
		end
	end
	return result
end
-----------------计算数据相关end----------------------
-- 获取需要显示的数据
function wnd_auctionSelect:updateScrollItems(itemType, page, rank, level, classType)
	local showData = self:getItemMapAtPage(itemType, classType, page, rank, level)
	self:setGradeLevel(itemType, page, rank, level, classType)
	if #showData == 0 then
		if self._args.page == 1 then
			local scroll = self._layout.vars.buyScrollRight
			scroll:removeAllChildren()
			return
		end
		if self._args.page > 1 then
			self._args.page = self._args.page - 1
			self._layout.vars.pageLabel:setText(self._args.page)
			g_i3k_ui_mgr:PopupTipMessage("已经到最后一页了")
		end
		return
	end
	self:updateScrollRight(showData)
end

-- 设置品质和等级的显示
function wnd_auctionSelect:setGradeLevel(itemType, page, rank, level, classType)
	self._layout.vars.pageLabel:setText(self._args.page)
	self._layout.vars.gradeLabel:setText(self._gradeTable[rank].nameLabel:getText())
	self._layout.vars.levelLabel:setText(self:getLevelString(level + 1))

	local needValueGradeAndLevel = {itemType = itemType, page = page, order = order, rank = rank, level = level, classType = classType}
	for i, v in pairs(self._gradeTable) do
		v.btn:setTag(i)
		v.btn:onClick(self, self.selectGrade, needValueGradeAndLevel)
	end

	self._layout.vars.levelScroll:removeAllChildren()
	for i = 1, (#g_i3k_db.i3k_db_get_auction_select_level() + 1), 1 do
		local node = require("ui/widgets/pmht")()
		node.vars.levelBtn:setTag(i)
		local text = self:getLevelString(i)
		node.vars.levelLabel:setText(text)
		node.vars.levelBtn:onClick(self, self.selectLevel, needValueGradeAndLevel)
		self._layout.vars.levelScroll:addItem(node)
	end
	self._layout.vars.levelScroll:hide()
end


-- 设置滚动条中显示的数据
function wnd_auctionSelect:updateScrollRight(array)
	local scroll = self._layout.vars.buyScrollRight
	scroll:removeAllChildren()
	local widgetName = "ui/widgets/pmhsxt"
	local children = scroll:addItemAndChild(widgetName, 2, #array)
	for i, widget in ipairs(children)do
		local info = array[i]
		local id = info.id
		widget.vars.infoBtn:onClick(self, self.onItemInfoBtn, info)
		widget.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		widget.vars.orangeTX:hide()
		widget.vars.purpleTX:hide()
		widget.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		local needRank = g_i3k_db.i3k_db_get_common_item_rank(id)
		widget.vars.nameLabel:setTextColor(g_i3k_get_color_by_rank(needRank))
		if not info.level then
			widget.vars.countLabel:hide()
		else
			widget.vars.countLabel:setText(info.level.."级")
		end
	end
end

function wnd_auctionSelect:onItemInfoBtn(sender, info)
	-- g_i3k_ui_mgr:PopupTipMessage("id="..info.id.." name="..info.name)
	local data = self._args
	data.page = 1
	i3k_sbean.sync_auction(data.itemType, info.name, data.page, data.order, data.rank, data.level, data.classType, data.callback, info.id)
	g_i3k_ui_mgr:RefreshUI(eUIID_Auction, data.itemType, data.classType) -- 刷新拍卖行的ui
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "onResetBtnClickData", data, info.name, info.id) -- 修复寄售行ui翻页出现问题
	g_i3k_ui_mgr:CloseUI(eUIID_AuctionSelect)
end
--------------------------------------------
-- itemType default 1
function wnd_auctionSelect:updateBuyScrollLeft(itemType)
	local scrollLeft = self._layout.vars.buyScrollLeft
	scrollLeft:setBounceEnabled(false)
	scrollLeft:removeAllChildren(true)
	local index = 1
	local typeTable = {}
	for i,v in pairs(i3k_db_auction_type) do
		table.insert(typeTable, v)
	end
	table.sort(typeTable, function (a, b) return a.typeId < b.typeId end)
	for i,v in ipairs(typeTable) do
		local node = require("ui/widgets/goumait1")()
		node.vars.nameLabel:setText(v.name)
		node.vars.openImg:setVisible(itemType == v.typeId)
		node.vars.pickupImg:setVisible(itemType ~= v.typeId)
		scrollLeft:addItem(node)
		node.vars.btn:setTag(v.typeId)
		if itemType == v.typeId then
			node.vars.btn:stateToPressed()
			index = i
			if g_auction_classType[itemType] then
				node.vars.btn:onClick(self, self.pickUpList, index)
				for _, t in ipairs(i3k_db_generals) do
					local widget = require("ui/widgets/goumait2")()
					widget.vars.nameLabel:setText(t.name)
					if classType and classType==t.id then
						widget.vars.nameLabel:setTextColor(self._yellow)
					end
					local needValue = {classType = t.id, itemType = v.typeId, page = 1, order = 2, rank = 0, level = 0}
					widget.vars.btn:setTag(t.id)
					widget.vars.btn:onClick(self, self.selectOccupation, needValue) -- 点小的
					if self._refreshClassType then
						if t.id == self._refreshClassType then
							widget.vars.btn:stateToPressed()
							self._refreshClassType = nil
						end
					end
					scrollLeft:addItem(widget)
				end
			end
		else
			node.vars.btn:onClick(self, self.selectItemType) -- 点大的
		end
	end
	scrollLeft:jumpToChildWithIndex(index)
	self._layout.vars.selectGradeRoot:setVisible(EQUIP_TYPE[itemType]) -- 是否是装备
	self._layout.vars.selectLvlRoot:setVisible(EQUIP_TYPE[itemType])
end

function wnd_auctionSelect:pickUpList(sender, index)
	local children = self._layout.vars.buyScrollLeft:getAllChildren()
	for i=1, #i3k_db_generals do
		self._layout.vars.buyScrollLeft:removeChildAtIndex(index + 1)
	end
	children[index].vars.btn:onClick(self, self.selectItemType)
	children[index].vars.openImg:hide()
	children[index].vars.pickupImg:show()
end

-- 点击左侧大标签
function wnd_auctionSelect:selectItemType(sender)
	local typeId = sender:getTag()
	self._selectType = typeId
	local callback = function (itemType)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AuctionSelect, "updateBuyScrollLeft", itemType)
	end
	local classType = nil
	if EQUIP_TYPE[typeId] or typeId == TYPE_XINFA then -- 装备和心法
		classType = 0 -- 默认装备，不区分职业
	end
	self:sendCmd(typeId, "", 1, 2, 0, 0, classType, callback)
end

-- 点击大标签下的小标签
function wnd_auctionSelect:selectOccupation(sender, needValue)
	self._selectType = needValue.itemType
	self._selectClassType = needValue.classType
	local callback = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AuctionSelect, "selectOccupationCB", needValue)
	end
	self:sendCmd(needValue.itemType, "", needValue.page, needValue.order, needValue.rank, needValue.level, needValue.classType, callback)
end

function wnd_auctionSelect:selectOccupationCB(needValue)
	local children = self._layout.vars.buyScrollLeft:getAllChildren()
	if children then
		local list = {}
		for k, v in pairs(i3k_db_auction_type) do
			table.insert(list, v)
		end
		table.sort(list, function (a, b)
			return a.typeId < b.typeId
		end)
		for i,v in ipairs(children) do
			-- i 连续，但是 needValue.itemType 不连续
			if list[i].typeId == needValue.itemType then
				for k = 1, #i3k_db_generals do
					if children[i + k] then
						local btn = children[i + k].vars.btn
						local tag = btn:getTag()
						if tag == needValue.classType then
							btn:stateToPressed()
						else
							btn:stateToNormal()
						end
					end
				end
				return;
			end
		end
	end
end

-----------------------------------------------------




------------------------------
-- 通用函数
function wnd_auctionSelect:getBeginEndLevel(id)
	local table = g_i3k_db.i3k_db_get_auction_select_level()
	if id == 1 then
		return 1, table[1]
	else
		return table[id - 1] + 1 , table[id]
	end
end
function wnd_auctionSelect:getLevelString(id)
	if id == 1 then
		return "全部等级"
	else
		local a, b = self:getBeginEndLevel(id - 1)
		return a.."~"..b.."级"
	end
end
function wnd_auctionSelect:onGradeBtn(sender)
	self._layout.vars.gradeRoot:setVisible(not self._layout.vars.gradeRoot:isVisible())
	self._layout.vars.levelRoot:hide()
	self._layout.vars.levelScroll:hide()
end

function wnd_auctionSelect:onLevelBtn(sender)
	local vis = self._layout.vars.levelRoot:isVisible()
	self._layout.vars.levelRoot:setVisible(not vis)
	self._layout.vars.levelScroll:setVisible(not vis)
	if not vis then
		local level = self._selectLevel
		self._layout.vars.levelLabel:setText(self:getLevelString(level))
		self:setLevelScroll(level)
	end
	self._layout.vars.gradeRoot:hide()
end

function wnd_auctionSelect:setLevelScroll(level)
	local children = self._layout.vars.levelScroll:getAllChildren()
	for i, v in ipairs(children)do
		if v.vars.levelBtn:getTag() ~= level then
			v.vars.levelBtn:stateToNormal()
			v.vars.levelLabel:setTextColor(self._blue)
		else
			v.vars.levelBtn:stateToPressed()
			v.vars.levelLabel:setTextColor(self._yellow)
		end
	end
end


-- 选择具体等级
function wnd_auctionSelect:selectLevel(sender, needValue)
	local level = sender:getTag()
	self._selectLevel = level
	self._layout.vars.levelLabel:setText(self:getLevelString(level))
	self:setLevelScroll(level)
	self._layout.vars.levelRoot:hide()
	self._layout.vars.levelScroll:hide()
	--发协议查询
	self:sendCmd(needValue.itemType, "", needValue.page, needValue.order, needValue.rank, level - 1, needValue.classType)
end

-- 选择具体品质
function wnd_auctionSelect:selectGrade(sender, needValue)
	local rank = sender:getTag()
	self._selectRank = rank
	self._layout.vars.gradeLabel:setText(self._gradeTable[rank].text)
	for i,v in pairs(self._gradeTable) do
		if i~=rank then
			v.btn:stateToNormal()
			v.nameLabel:setTextColor(self._blue)
		else
			v.btn:stateToPressed()
			v.nameLabel:setTextColor(self._yellow)
		end
	end
	self._layout.vars.gradeRoot:hide()
	--发协议查询
	self:sendCmd(needValue.itemType, "", needValue.page, needValue.order, rank, needValue.level, needValue.classType)
end

function wnd_create(layout, ...)
	local wnd = wnd_auctionSelect.new()
	wnd:create(layout, ...)
	return wnd;
end
