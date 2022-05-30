local BaseScene = require("game.BaseScene")
local ItemChooseScene = class("ItemChooseScene", BaseScene)

function ItemChooseScene:ctor(param)
	ItemChooseScene.super.ctor(self, {
	contentFile = "public/window_content_scene.ccbi",
	subTopFile = "lianhualu/lianhualu_item_tab_view.ccbi",
	bottomFile = "lianhualu/lianhualu_bottom_frame.ccbi",
	bgImage = "ui_common/common_bg.png",
	imageFromBottom = true
	})
	
	ResMgr.removeBefLayer()
	local _list = param.list
	local _items = param.items
	local _closeListener = param.closeListener
	local _splitType = param.splitType or 1
	local _select = param.selected or {}
	local _viewType = param.viewType
	
	local tabPx, tabPy = self._rootnode.tab1:getPosition()
	local tabLabPx, tabLabPy = self._rootnode.tab_lable1:getPosition()
	
	for i = 1, 6 do
		local bg = self._rootnode["tab" .. i]
		bg:setPosition(tabPx, tabPy)
		self._rootnode["tab" .. i]:setScale(0.8)
		local size = bg:getContentSize()
		local pos = bg:convertToWorldSpace(cc.p(size.width/2, size.height/2))
		local lable = self._rootnode["tab_lable" .. i]
		pos = lable:getParent():convertToNodeSpace(pos)
		lable:align(display.CENTER)
		lable:setPosition(pos)
		lable:setScale(0.8)
		tabPx = tabPx + 100
		tabLabPx = tabLabPx + 100
	end
	
	
	local _tabMap = {
	[LIAN_HUA_TYEP.HERO] = _items[LIAN_HUA_TYEP.HERO],
	[LIAN_HUA_TYEP.EQUIP] = _items[LIAN_HUA_TYEP.EQUIP],
	[LIAN_HUA_TYEP.SKILL] = _items[LIAN_HUA_TYEP.SKILL],
	[LIAN_HUA_TYEP.PET] = _items[LIAN_HUA_TYEP.PET],
	[LIAN_HUA_TYEP.SHIZHUANG] = _items[LIAN_HUA_TYEP.SHIZHUANG],
	[LIAN_HUA_TYEP.CHEATS] = _items[LIAN_HUA_TYEP.CHEATS]
	}
	local function getIndexByValue(x)
		for k, v in ipairs(_tabMap[_splitType]) do
			if v == x then
				return k
			end
		end
	end
	local i = 1
	for k, v in pairs(_select) do
		if v then
			local idx = getIndexByValue(k)
			if idx then
				_tabMap[_splitType][i], _tabMap[_splitType][idx] = _tabMap[_splitType][idx], _tabMap[_splitType][i]
				i = i + 1
			end
		end
	end
	local _tmpSelect = {}
	for k, v in pairs(_select) do
		if v then
			_tmpSelect[k] = v
		end
	end
	local function countSelected()
		local i = 0
		for k, v in pairs(_tmpSelect) do
			if v then
				i = i + 1
			end
		end
		return i
	end
	local function onTabBtn(tag)
		for i = 1, 6 do
			if tag == i then
				self._rootnode["tab" .. i]:selected()
			else
				self._rootnode["tab" .. i]:unselected()
			end
		end
		_splitType = tag
		_tmpSelect = {}
		_select = {}
		table.sort(_tabMap[_splitType], function(l, r)
			return l < r
		end)
		self._itemList:resetListByNumChange(#_tabMap[_splitType])
		self._rootnode.selectedLabel:setString(tostring(countSelected()))
		_SELECTNUM = #_items[_splitType]
		self._rootnode.maxSelectedLabel:setString("/" .. tostring(_SELECTNUM))
	end
	
	_SELECTNUM = #_items[_splitType]
	self._rootnode.maxSelectedLabel:setString("/" .. tostring(_SELECTNUM))
			
	self._rootnode["tab" .. tostring(_splitType)]:selected()	
	self._rootnode.tab1:registerScriptTapHandler(onTabBtn)
	self._rootnode.tab2:registerScriptTapHandler(onTabBtn)
	self._rootnode.tab3:registerScriptTapHandler(onTabBtn)
	self._rootnode.tab4:registerScriptTapHandler(onTabBtn)
	self._rootnode.tab5:registerScriptTapHandler(onTabBtn)
	self._rootnode.tab6:registerScriptTapHandler(onTabBtn)
	local _sz = self._rootnode.listView:getContentSize()
	local function close(sel)
		if _closeListener then
			_closeListener(_splitType, sel)
		end
		pop_scene()
	end
	local function touch(idx)
		if _tmpSelect[idx] then
			_tmpSelect[idx] = nil
		elseif countSelected() >= _SELECTNUM then
			show_tip_label(common:getLanguageString("@zuiduoxz", _SELECTNUM))
			return
		else
			_tmpSelect[idx] = true
		end
		self._rootnode.selectedLabel:setString(tostring(countSelected()))
	end
	
	self._rootnode.selectedLabel:setString(tostring(countSelected()))
	
	local function onConfirmBtn(sender, eventname)
		close(_tmpSelect)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	
	local function choseAllBtn(sender, eventname)
		local items = _tabMap[_splitType]
		for i = 1, #items do
			_tmpSelect[items[i]] = true
		end
		self._rootnode.selectedLabel:setString(tostring(#items))
		self._itemList:resetCellNum(#items)
	end
	
	if _viewType == 1 then
		display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
		local allBtn = cc.ControlButton:create("", FONTS_NAME.font_fzcy, 24)
		allBtn:setTitleForState(common:getLanguageString("@AllSelect"), CCControlStateNormal)
		allBtn:setBackgroundSpriteFrameForState(display.newSpriteFrame("com_btn_blue.png"), CCControlStateNormal)
		allBtn:setPreferredSize(self._rootnode.okBtn:getPreferredSize())
		
		local x, y = self._rootnode.okBtn:getPosition()
		allBtn:setPosition(x - 165, y + 10)
		
		self._rootnode.okBtn:getParent():addChild(allBtn)
		self._rootnode.okBtn:setPosition(x - 20, y + 10)
		self._rootnode.okBtn:setScale(0.8)
		
		allBtn:addHandleOfControlEvent(choseAllBtn, CCControlEventTouchUpInside)
		allBtn:setScale(0.8)
	else
		local x, y = self._rootnode.okBtn:getPosition()
		self._rootnode.okBtn:setPositionX(x - 30)
	end
	
	
	self._rootnode.okBtn:addHandleOfControlEvent(onConfirmBtn, CCControlEventTouchUpInside)
	
	self._rootnode.returnBtn:setPositionY(self._rootnode.returnBtn:getPositionY() + 20)
	self._rootnode.returnBtn:setScale(0.8)
	self._rootnode.returnBtn:addHandleOfControlEvent(function()
		close(_select)
	end,
	CCControlEventTouchUpInside)
	
	local function initItems()
		self._itemList = require("utility.TableViewExt").new({
		size = _sz,
		direction = kCCScrollViewDirectionVertical,
		createFunc = function(idx)
			local item = require("game.SplitStove.SplitItem").new()
			idx = idx + 1
			return item:create({
			viewSize = _sz,
			itemData = _list[_splitType][_tabMap[_splitType][idx]],
			idx = idx,
			sel = _tmpSelect[_tabMap[_splitType][idx]],
			itemType = _splitType
			})
		end,
		refreshFunc = function(cell, idx)
			idx = idx + 1
			cell:refresh({
			idx = idx,
			itemData = _list[_splitType][_tabMap[_splitType][idx]],
			sel = _tmpSelect[_tabMap[_splitType][idx]],
			itemType = _splitType
			})
		end,
		cellNum = #_tabMap[_splitType],
		cellSize = require("game.SplitStove.SplitItem").new():getContentSize(),
		touchFunc = function(cell)
			local idx = cell:getIdx() + 1
			if _viewType == 2 and countSelected() >= 1 then
				for k, v in pairs(_tmpSelect) do
					if v and k ~= _tabMap[_splitType][idx] then
						for kk, vv in ipairs(_tabMap[_splitType]) do
							if vv == k then
								_tmpSelect[k] = nil
								local preCell = self._itemList:cellAtIndex(kk - 1)
								if preCell then
									preCell:refresh({
									idx = kk,
									itemData = _list[_splitType][k],
									sel = false,
									itemType = _splitType
									})
								end
								break
							end
						end
						break
					end
				end
			end
			touch(_tabMap[_splitType][idx])
			cell:refresh({
			idx = idx,
			itemData = _list[_splitType][_tabMap[_splitType][idx]],
			sel = _tmpSelect[_tabMap[_splitType][idx]],
			itemType = _splitType
			})
		end
		})
		self._itemList:setPosition(0, 0)
		self._rootnode.listView:addChild(self._itemList, 1)
	end
	initItems()
end

return ItemChooseScene