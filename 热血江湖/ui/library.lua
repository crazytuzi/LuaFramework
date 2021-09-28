module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------
wnd_library = i3k_class("wnd_library", ui.wnd_add_sub)

local CANGSHUSHENGJI ="ui/widgets/cangshushengji"
local CANGSHUJIESUO	= "ui/widgets/cangshujiesuo"
local CANGSHUMAX 	= "ui/widgets/cangshumax"
local CANGSHUT2     = "ui/widgets/cangshut2"
local CANGSHUT      = "ui/widgets/cangshut"
local SHUDAI        = "ui/widgets/shudai"

local MIJI_STATE = 1
local BOOK_STATE = 2

function wnd_library:ctor()
	self.nullCount = nil
	self.coin = nil
	self.showType = 1
	self.ironBg = nil
	self.typeName = {[1] = 442, [2] = 443, [3] = 444, [4] = 445, [5] = 446,[6] = 1040,[7]=1403}
	self.showItem = {}
	self.widgets = nil
	self._recordPresent = nil
	self._state = MIJI_STATE
	self._data = {}
end


function wnd_library:configure()
	local widgets = self._layout.vars
	
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self.new_root = widgets.new_root
	self.scroll = widgets.scroll
	self.cheats_btn = widgets.cheats_btn
	self.books_btn = widgets.books_btn
	self.cheats_btn:onClick(self, self.updateScrollBtn)
	self.books_btn:onClick(self, self.booksBtn)
	self.new_root = widgets.new_root
	self.empowerment_btn   = widgets.empowerment_btn
	self.library_btn   = widgets.library_btn 
	self.penetrate_btn = widgets.penetrate_btn
	self.red_point1 = widgets.red_point1
	self.red_point2 = widgets.red_point2
	self.red_point3 = widgets.red_point3
	self.cheats_point = widgets.cheats_point
	self.book_point = widgets.book_point
	
	self.library_btn:onClick(self,self.libraryBtn)
	self.penetrate_btn:onClick(self,self.penetrateBtn)
	self.empowerment_btn:onClick(self,self.empowermentBtn)
	self.empowerment_btn:stateToNormal()
	self.penetrate_btn:stateToNormal()
	self.library_btn:stateToPressed()
	self.cheats_btn:stateToPressed(true)

	widgets.qiankunBtn:onClick(self,self.qiankunBtn)
	widgets.qiankunBtn:stateToNormal()
	widgets.qiankunBtn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_experience_args.experienceUniverse.showLevel)

end

function wnd_library:refresh()
	self:updateScroll()
end 

function wnd_library:updateScrollBtn(sender)
	self._state = MIJI_STATE
	self.books_btn:stateToNormal(true)
	self.cheats_btn:stateToPressed(true)
	self:updateScroll()
end

function wnd_library:updateMiJiWidget()
	if self._state == MIJI_STATE then
		self:libraryUpLevel()
	end
end

function wnd_library:booksBtn(sender)
	self._state = BOOK_STATE
	self.scroll:removeAllChildren()
	self.cheats_btn:stateToNormal(true)
	self.books_btn:stateToPressed(true)
	self:refreshBooks()
end

function wnd_library:refreshBooks()
	local books = g_i3k_game_context:GetBooksIsLock()
	if next(books) then
		self:booksScroll(books)
	else
		self:initAllBooks()
	end
end

function wnd_library:initAllBooks()
	self.scroll:removeAllChildren()
	local _layer = require(SHUDAI)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	widgets.ok:hide()
	widgets.up:hide()
	widgets.haveBooks:hide()
	widgets.btn_point:setVisible(g_i3k_game_context:redPointForBooks())
	widgets.noBooks:show()
	widgets.tips:setText(i3k_get_string(489))
	widgets.save:onClick(self,self.saveBooks, widgets)
	
end

function wnd_library:booksScroll(books)   --书袋的藏书
	self.cheats_point:setVisible(g_i3k_game_context:redPointForAllCheats())
	self.red_point1:setVisible(g_i3k_game_context:redPointForAllCheats() or g_i3k_game_context:redPointForBooks())
	self.red_point2:setVisible(g_i3k_game_context:qiankunRedPoints())
	self.red_point3:setVisible(g_i3k_game_context:isShowCunWnRed())
	local items = books
	self.scroll:removeAllChildren()
	self.cheats_btn:stateToNormal(true)
	self.books_btn:stateToPressed(true)
	if items == nil then
		return
	end
	local index = 0
	for i, e in pairs(items) do
		index = index + 1
	end
	local all_layer1 = self.scroll:addItemAndChild(CANGSHUT, 5, index)
	local count = 0
	for k,v in pairs(items) do
		count = count + 1
		local widget = all_layer1[count].vars
		self:booksUpdatCell(widget, k, v, count)
	end
	
end

function wnd_library:booksUpdatCell(widget, booksId, booksCount, count)
	local globel_btn = widget.globel_btn
	local icon = widget.iron
	local countLabel = widget.countLabel
	local info = {booksId = booksId, booksCount = booksCount}
	if count == 1 then
		widget.ironBg:show()
		self:booksInfo(info)
	end
	widget.red_point:hide()
	icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(booksId,i3k_game_context:IsFemaleRole()))
	globel_btn:onClick(self,self.bookData, {widget = widget, info = info})
	widget.itemBg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(booksId)))
	widget.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(booksId))
	countLabel:setText(booksCount)
end

function wnd_library:bookData(sender, data)
	self:setCellIsSelectHide()
	data.widget.ironBg:show()
	self:booksInfo(data.info)
end

function wnd_library:booksInfo(info)     --右边
	self.current_num = 1
	local _layer = require(SHUDAI)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max
	widgets.sale_count:setText(1)
	self._count_label = widgets.sale_count
	self.current_add_num = info.booksCount
	
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.onMax)
	local cfg = g_i3k_db.i3k_db_get_common_item_cfg(info.booksId)
	widgets.itemName:setText(cfg.name)
	widgets.haveBooks:show()
	widgets.noBooks:hide()
	widgets.btn_point:setVisible(g_i3k_game_context:redPointForBooks())
	self.book_point:setVisible(g_i3k_game_context:redPointForBooks())
	widgets.save:onClick(self,self.saveBooks)
	widgets.ok:onClick(self,self.extractBtn, info.booksId)
	widgets.tips:setText(i3k_get_string(489))
	self._count_label:setText(self.current_num)
	self:updatefun()
end

function wnd_library:setSaleMoneyCount(count)
	self._count_label:setText(count)
end

function wnd_library:updatefun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Library,"setSaleMoneyCount",self.current_num)
	end
end

function wnd_library:saveBooks(sender)
	local items = g_i3k_game_context:GetAllItemsForType(20)  --获取背包里面所有的藏书
	local tab = {}
	for k,v in pairs(items) do
		tab[v.id] = v.count
	end
	if next(tab) then
		i3k_sbean.goto_rarebook_push(tab)
	else
		g_i3k_ui_mgr:PopupTipMessage("没有任何藏书可以存入书袋")
	end
	
end

function wnd_library:extractBtn(sender, booksId)
	local tab = {}
	tab[booksId] = self.current_num
	if g_i3k_game_context:IsBagEnough(tab) then
		i3k_sbean.goto_rarebook_pop(tab)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包已满，无法提取藏书")
		return
	end
end

function wnd_library:updateScroll(recordID)
	self.scroll:removeAllChildren()
	self.red_point1:setVisible(g_i3k_game_context:redPointForAllCheats() or g_i3k_game_context:redPointForBooks()) --红点逻辑
	self.red_point2:setVisible(g_i3k_game_context:qiankunRedPoints())
	self.red_point3:setVisible(g_i3k_game_context:isShowCunWnRed())
	self.cheats_point:setVisible(g_i3k_game_context:redPointForAllCheats())
	self.book_point:setVisible(g_i3k_game_context:redPointForBooks())
	--local args = i3k_db_experience_library
	
	local roleType = g_i3k_game_context:GetRoleType()
	local roleTypeTb = {}
	local elseTypeTb = {}
	local commonTypeTb = {}
	local index1 = 0
	local index2 = 0
	local index3 = 0
	for k,v in ipairs(i3k_db_experience_library) do 
		local vocation = v[1].needVocation
		if roleType == vocation then
			index1 = index1 + 1
			roleTypeTb[index1] = v
		elseif vocation == 0 then
			index3 = index3 + 1
			commonTypeTb[index3] = v
		else
			index2 = index2 + 1
			elseTypeTb[index2] = v
		end
	end
	local roleTypeItem = self:sortLibrary(roleTypeTb)
	local elseTypeItem = self:sortLibrary(elseTypeTb)
	local commonTypeItem = self:sortLibrary(commonTypeTb)
	local _layer1 = require(CANGSHUT2)()
	_layer1.vars.typeName:setText(i3k_get_string(self.typeName[roleType]))
	self.scroll:addItem(_layer1)
	local all_layer1 = self.scroll:addItemAndChild(CANGSHUT, 5, #roleTypeItem)
	for i, e in pairs(roleTypeItem) do
		local info = e
		local widget = all_layer1[i].vars
		self:updatCell(widget, e, i, recordID)
	end
	
	local _layer2 = require(CANGSHUT2)()
	_layer2.vars.typeName:setText(i3k_get_string(447))
	self.scroll:addItem(_layer2)
	local all_layer2 = self.scroll:addItemAndChild(CANGSHUT, 5, #elseTypeItem)
	for i, e in ipairs(elseTypeItem) do
		local widget = all_layer2[i].vars
		self:updatCell(widget, e, nil, recordID)
	end
	
	local _layer2 = require(CANGSHUT2)()
	_layer2.vars.typeName:setText("通用")
	self.scroll:addItem(_layer2)
	local all_layer3 = self.scroll:addItemAndChild(CANGSHUT, 5, #commonTypeItem)
	for i, e in ipairs(commonTypeItem) do
		local widget = all_layer3[i].vars
		self:updatCell(widget, e, nil, recordID)
	end
	
	if self._recordPresent then
		self.scroll:jumpToListPercent(self._recordPresent)
	end
end

function wnd_library:sortLibrary(sort_items)
	local isLockBooks = {}
	for i, e in ipairs(sort_items) do
		local level = g_i3k_game_context:GetBooksLevel(e[1].libraryID) and g_i3k_game_context:GetBooksLevel(e[1].libraryID) or 0
		if level < #e then
			level = level + 1
		end
		isLockBooks[i] = e[level]
	end 
	return isLockBooks
end

function wnd_library:updatCell(widget, info, i, recordID)
	self.widgets = widget
	local globel_btn = widget.globel_btn
	local ironBg = widget.ironBg
	local itemBg2 = widget.itemBg2
	local iron = widget.iron
	local countLabel = widget.countLabel
	ironBg:hide()
	itemBg2:show()
	iron:setImage(g_i3k_db.i3k_db_get_icon_path(info.libraryIron))
	widget.itemBg:setImage(g_i3k_get_icon_frame_path_by_rank(info.rank))
	globel_btn:onClick(self,self.libraryUpBtn, {info = info ,widget = widget})
	
	widget.suo:setVisible(false)
	local nowInfo = g_i3k_game_context:GetNowCheatsInfo(info.libraryID, info.libraryLvl)
	local level = g_i3k_game_context:GetBooksLevel(info.libraryID)
	--widget.red_point:setVisible(g_i3k_game_context:redPointForCheats(info.libraryID, info.libraryLvl))
	for k,v in ipairs(i3k_db_experience_library) do
		if level and level ~= #v then
			widget.red_point:setVisible(g_i3k_game_context:redPointForCheats(info.libraryID, info.libraryLvl))
			countLabel:setText(i3k_get_string(467, nowInfo.libraryLvl))
		elseif level and level == #v then
			widget.red_point:setVisible(g_i3k_game_context:redPointForCheats(info.libraryID, #v))
			countLabel:setText(i3k_get_string(467, #v))
		elseif level == nil then
			widget.red_point:setVisible(g_i3k_game_context:redPointForCheats(info.libraryID, info.libraryLvl))
			countLabel:setText(i3k_get_string(468))
			widget.suo:setVisible(true);
		end
	end
	
	if recordID and recordID == info.libraryID then
		local recordInfo = g_i3k_game_context:GetRecordBooksId()
		self:setCellIsSelectHide()
		ironBg:show()
		self:libraryUpLevel(recordInfo)
		return
	end
	if i and i == 1 then
		self:setCellIsSelectHide()
		ironBg:show()
		self:libraryUpLevel(info)
	end
	
end

function wnd_library:libraryUpBtn(sender, data)
	self._recordPresent = self.scroll:getListPercent()
	self:setCellIsSelectHide()
	data.widget.ironBg:show()
	self:libraryUpLevel(data.info)
end

function wnd_library:libraryUpLevel(data)
	if data then
		self._data = data
	end
	local info = data or self._data
	local nowInfo = g_i3k_game_context:GetNowCheatsInfo(info.libraryID, info.libraryLvl)
	local level = g_i3k_game_context:GetBooksLevel(info.libraryID)
	for k,v in ipairs(i3k_db_experience_library) do
		if info.libraryID == v[1].libraryID then
			if level and level == #v then
				self:maxlevelLibrary(info)
				return
			end
		end
	end
	
	local _layer
	if level then
		_layer = require(CANGSHUSHENGJI)()
	else
		_layer = require(CANGSHUJIESUO)()
	end
	local widgets = _layer.vars
	self:addNewNode(_layer)
	widgets.tips:setText(i3k_get_string(488))
	local str 
	if level then
		widgets.btnLabel:setText(i3k_get_string(449))
		if nowInfo then
			str = string.format(i3k_get_string(450,info.libraryName,nowInfo.libraryLvl or 1))
		else
			str = string.format(i3k_get_string(450,info.libraryName,1))
		end
	else
		widgets.btnLabel:setText(i3k_get_string(451))
		str = string.format(i3k_get_string(452, info.libraryName))
	end
	
	widgets.item:setText(str)
	local showItem = {}
	local showItem2 = {}
	local propertyID = {}
	local propertyCount = {}
	local expendLibraryID ={}
	local expendLibraryCount = {}
	local propertyNowCount = {}
	local coinID = g_i3k_db.i3k_db_get_base_item_cfg(43).id    --历练币id（固定）
	for i=1, 3 do
		local propertyID = "propertyID"..i
		local propertyCount = "propertyCount"..i
		local propRightMark = "propRightMark" .. i
		local newCount = "newCount"..i
		if level then
			showItem2[i] = {
				propertyID	    = widgets[propertyID],
				propertyCount   = widgets[propertyCount],
				newCount		= widgets[newCount],
				propRightMark	= widgets[propRightMark],
			}
		else
			showItem2[i] = {
				propertyID	    = widgets[propertyID],
				propertyCount   = widgets[propertyCount],
			}
		end
		
	end
	for i=1, 4 do
		local itemName = "pracNameLabel"..i
		local itemIconBg = "pracGradeIcon"..i
		local itemIcon = "pracIcon"..i
		local itemLock = "pracLock"..i
		local itemCount = "pracCountLabel"..i
		local itemBtn = "pracBtn"..i
		local item = "item"..i
		showItem[i] = {
				item			= widgets[item],
				itemName	    = widgets[itemName],
				itemIconBg   	= widgets[itemIconBg],
				itemIcon		= widgets[itemIcon],
				itemLock	    = widgets[itemLock],
				itemCount  	 	= widgets[itemCount],
				itemBtn			= widgets[itemBtn],
			}
	end
	for i=1, 3 do
		propertyID[i] = info["propertyId" .. i]
		propertyCount[i] = info["propertyCount" .. i]
	end
	expendLibraryID[1] = info.expendLibraryID
	expendLibraryID[2] = coinID
	expendLibraryID[3] = info.expend3ID
	expendLibraryID[4] = info.expend4ID
	expendLibraryCount[1] = info.expendLibraryCount
	expendLibraryCount[2] = info.expendExperienceCount
	expendLibraryCount[3] = info.expend3Count
	expendLibraryCount[4] = info.expend4Count
	for i=1,3 do
		if propertyID[i] ~= 0 then
			showItem2[i].propertyCount:setText(i3k_get_prop_show(propertyID[i], propertyCount[i]))
			showItem2[i].propertyID:setText(i3k_db_prop_id[propertyID[i]].desc..":")
			if showItem2[i].newCount then
				if nowInfo then
					propertyNowCount[i] = nowInfo["propertyCount" .. i]
				else
					local property = g_i3k_game_context:GetFirstProperty(info.libraryID, info.libraryLvl)
					propertyNowCount[i] = property["propertyCount" .. i]
				end
				showItem2[i].propertyCount:setText(i3k_get_prop_show(propertyID[i], propertyNowCount[i]))
				showItem2[i].newCount:setText(i3k_get_prop_show(propertyID[i],propertyCount[i]))
			end
		else
			showItem2[i].propertyCount:hide()
			showItem2[i].propertyID:hide()
			if showItem2[i].newCount then
				showItem2[i].newCount:hide()
			end
			if showItem2[i].propRightMark then
				showItem2[i].propRightMark:hide()
			end
		end
	end
	
	for i=1,4 do
		showItem[i].item:hide()
		if expendLibraryID[i] ~= 0 then
			showItem[i].item:show()
			local canUseCount
			if i == 1 then
				canUseCount = g_i3k_game_context:GetBooksCountForID(expendLibraryID[i])   --藏书从书袋里面扣
			else
				canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(expendLibraryID[i])
			end
			local ironImage = g_i3k_db.i3k_db_get_common_item_icon_path(expendLibraryID[i],i3k_game_context:IsFemaleRole())
			local cfg = g_i3k_db.i3k_db_get_common_item_cfg(expendLibraryID[i])
			showItem[i].itemName:setText(cfg.name)
			showItem[i].itemName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(expendLibraryID[i])))
			showItem[i].itemIcon:setImage(ironImage)
			showItem[i].itemIconBg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(expendLibraryID[i])))
			showItem[i].itemLock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(expendLibraryID[i]))
			if info.needVocation == g_i3k_game_context:GetRoleType() or info.needVocation == 0 then
				expendLibraryCount[i] = expendLibraryCount[i]
			else
				expendLibraryCount[i] = expendLibraryCount[i] * 2
			end
			if expendLibraryID[i] == g_BASE_ITEM_COIN then
				showItem[i].itemCount:setText(expendLibraryCount[i])
			else
				showItem[i].itemCount:setText(canUseCount .. "/" .. expendLibraryCount[i])
			end
			showItem[i].itemCount:setTextColor(g_i3k_get_cond_color(canUseCount >= expendLibraryCount[i]))
			showItem[i].itemBtn:onClick(self, self.clickItem, expendLibraryID[i])
		end
		
	end
	widgets.saveBtn:onClick(self,self.UpLvlBtn,{expendLibraryID = expendLibraryID, expendLibraryCount = expendLibraryCount, info = info})
end

function wnd_library:UpLvlBtn(sender, item)
	local itemCount = item.expendLibraryCount
	local itemId = item.expendLibraryID
	local info = item.info
	
	local count = 0
	for i=1,4 do
		local canUseCount
		if i == 1 then
			canUseCount = g_i3k_game_context:GetBooksCountForID(itemId[i])
		else
			canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId[i])
		end
		
		if itemCount[i] <= canUseCount then
			count = count + 1
		end
	end
	if count == 4 then
		local callfunc = function ()
			for i=1,4 do
				if i == 1 then
					g_i3k_game_context:UseBooksCountForID(itemId[i], itemCount[i])
				else
					--g_i3k_game_context:UseCommonItem(itemId[i], itemCount[i])
					local level = g_i3k_game_context:GetBooksLevel(info.libraryID)
					if level then
						g_i3k_game_context:UseCommonItem(itemId[i], itemCount[i],AT_RARE_BOOK_UPLVL)
					else
						g_i3k_game_context:UseCommonItem(itemId[i], itemCount[i],AT_RARE_BOOK_UNLOCK)
					end
				end
			end
		end
		local level = g_i3k_game_context:GetBooksLevel(info.libraryID)
		if level then
			i3k_sbean.goto_rarebook_lvlup(info, callfunc)
		else
			i3k_sbean.goto_rarebook_unlock(info,callfunc)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(453))
	end

end

function wnd_library:maxlevelLibrary(info)
	local _layer = require(CANGSHUMAX)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	local str = string.format(i3k_get_string(450,info.libraryName,info.libraryLvl))
	widgets.items:setText(str)
	widgets.tips:setText(i3k_get_string(488))
	_layer.anis.c_dakai:play()
	local propertyID = {}
	local propertyCount = {}
	for i=1, 3 do
		if info["propertyId" .. i] ~= 0 then
			propertyID[i] = info["propertyId" .. i]
			propertyCount[i] = info["propertyCount" .. i]
			widgets["propertyID"..i]:setText(i3k_db_prop_id[propertyID[i]].desc..":")
			widgets["propertyCount"..i]:setText(i3k_get_prop_show(propertyID[i], propertyCount[i]))
		else
			widgets["propertyID"..i]:hide()
			widgets["propertyCount"..i]:hide()
		end
	end
end

function wnd_library:setCellIsSelectHide()
	for k, v in pairs(self.scroll:getAllChildren()) do
		if v.vars.ironBg then
			v.vars.ironBg:hide()
		end
	end
end


function wnd_library:addNewNode(layer)
	local nodeWidth = self.new_root:getContentSize().width
	local nodeHeight = self.new_root:getContentSize().height
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		self.new_root:removeChild(old_layer[1])
	end
	self.new_root:addChild(layer)
	layer.rootVar:setContentSize(nodeWidth,nodeHeight)
end

function wnd_library:empowermentBtn(sender,data)
	i3k_sbean.goto_expcoin_sync()  --历练协议
end

function wnd_library:penetrateBtn()
	i3k_sbean.goto_grasp_sync()    --参悟协议
end

function wnd_library:clickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

--[[function wnd_library:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Library)
end--]]
function wnd_library:qiankunBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_experience_args.experienceUniverse.openLevel then
		local str = string.format("等级达到%s时乾坤开启", i3k_db_experience_args.experienceUniverse.openLevel)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_Qiankun)
	g_i3k_ui_mgr:RefreshUI(eUIID_Qiankun)
	g_i3k_ui_mgr:CloseUI(eUIID_Library)
end
function wnd_create(layout)
	local wnd = wnd_library.new();
		wnd:create(layout);

	return wnd;
end
