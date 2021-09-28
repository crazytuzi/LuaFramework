
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_starShape = i3k_class("wnd_starShape",ui.wnd_base)
local starPoint	= "ui/widgets/xingyaot1"
local StarPart1	= "ui/widgets/xingweit2"
local StarPart2	= "ui/widgets/xingweit3"
local PointBg	= 4780;
local Color		= 4797;
local colorSign = 1;
local shapeSign = 2;
local starX = i3k_db_martial_soul_cfg.starLength
local starY = i3k_db_martial_soul_cfg.starWide

function wnd_starShape:ctor()
	self._curPart = 0;
	self._oldColorPoint = false;
	self._newColorPoint = false;
	self._isCache = false;
	self._isNeedSave = false;
	self._oldPureColor = false;
	self._newPureColor = false;
	self._curShape = nil;
end

function wnd_starShape:configure()
	local widget = self._layout.vars
	self.scroll = widget.scroll
	widget.closeBtn:onClick(self, self.onCloseUI)
	self.lockItem = {}
	self.newPart	= widget.newPart;
	self.partRoot	= widget.partRoot;
	self.part		= widget.part;
	self.part1		= widget.part1;
	self.resetBtn	= widget.resetBtn;
	self.chooseImg1 = widget.chooseImg1;
	self.chooseImg2 = widget.chooseImg2;
	self.saveBtn	= widget.saveBtn;
	self.resetBtn1	= widget.resetBtn1;
	self.partText	= widget.partText;
	self.mustChange1 = widget.mustChange1
	self.mustChange2 = widget.mustChange2

	widget.saveBtn:onClick(self,self.onSaveBtn)
	widget.resetBtn:onClick(self, self.onResetBtn)
	widget.resetBtn1:onClick(self,self.onResetBtn)
	
	self.parts = {}
	for i = 1 , 2 do
		widget["setBtn"..i]:onClick(self, self.onSetShapeBtn, i)
		local tempPart = require(StarPart2)()
		widget["setBtn"..i]:addChild(tempPart)
		widget['mustChange'..i]:onClick(self, self.onMustChangeBtn, i)
		widget['mustChange'..i]:hide()
		tempPart = tempPart.vars
		tempPart.rootGird:hide() 
		tempPart.rootGird:setSizePercent(1, 1)
		tempPart.wordTxt:hide()
		table.insert(self.parts, tempPart)
	end
	self.tempPart = require(StarPart1)()
	self.tempPart1 = require(StarPart1)()
	self.tempPart2 = require(StarPart1)()
	widget.partRoot:addChild(self.tempPart)
	widget.part:addChild(self.tempPart1)
	widget.part1:addChild(self.tempPart2)
	self.tempPart.vars.rootGird:setSizePercent(1, 1)
	self.tempPart1.vars.rootGird:setSizePercent(1, 1)
	self.tempPart2.vars.rootGird:setSizePercent(1, 1)
end

function wnd_starShape:refresh(arg)
	self:updateHide()
	self:updateStar(arg);
	self:updateNeedItem()
end

function wnd_starShape:updateHide()
	self.saveBtn:hide()
	self.resetBtn1:hide()
	self.newPart:hide()
	-- local curStar = g_i3k_game_context:GetExpectDish();
	-- if curStar then
	-- 	local name = i3k_db_star_soul[curStar].name
	-- else

	-- end
end

function wnd_starShape:updateStar(arg)
	self._curPart = arg.part;
	local starName = i3k_db_martial_soul_part[arg.part].starName;
	self.partText:setImage(g_i3k_db.i3k_db_get_icon_path(starName));
	self:isHaveColorPoint(arg.startInfo)
	self:updateNewPart(arg.startInfo, self.tempPart)
	self:updateNewPart(arg.startInfo, self.tempPart1)
	self:onUpdateShapeBtn();
	self:haveCall(arg.part)
	if self:isPureColor(arg.startInfo) then
		self._oldPureColor = true;
	end
end

function wnd_starShape:haveCall(partId)
	local part = g_i3k_game_context:GetWeaponSoulParts()
	if part[partId] then
		local cache = part[partId].cache;
		for k,v in pairs(cache) do
			self._isCache = true;
			self:updatePart(part[partId].cache)
			break;
		end
	end
end

function wnd_starShape:isHaveColorPoint(startInfo)
	for k, v in pairs(startInfo) do
		local color = i3k_db_star_soul_colored_color[v].partIcon;
		if color == Color then
			self._oldColorPoint = true
		end

		
	end
end

function wnd_starShape:updateNewPart(startInfo, shape)
	for i = 1,9 do
		shape.vars["x"..i]:hide()
	end
	for k, v in pairs(startInfo) do
		local color = i3k_db_star_soul_colored_color[v].partIcon;
		shape.vars["x"..(k+1)]:show():setImage(g_i3k_db.i3k_db_get_icon_path(color))
	end
end

function wnd_starShape:savePart(startInfo)
	self._isNeedSave = false;
	self._oldColorPoint = false;
	self._oldPureColor = false;
	self.partRoot:show();
	self.newPart:hide();
	self.saveBtn:hide()
	self.resetBtn1:hide()
	self.resetBtn:show()
	if self:isPureColor(startInfo) then
		self._oldPureColor = true;
	end
	self:updateNewPart(startInfo, self.tempPart)
	self:updateNewPart(startInfo, self.tempPart1)
end

function wnd_starShape:updatePart(arg)
	self._isNeedSave = true;
	self._newColorPoint = false;
	self.saveBtn:show()
	self.resetBtn1:show()
	self.resetBtn:hide()
	self.partRoot:hide();
	self.newPart:show();
	self._curShape = arg;
	self.resetBtn1:setTouchEnabled(true)
	self:updateNewPart(arg, self.tempPart2)
	if self:isSatisfyLead() then
		local tmp_str = i3k_get_string(1132) 
		local fun = (function(ok)
			if ok then
				i3k_sbean.StarSaveReset(self._curPart, self._curShape)
			end
		end)
		g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1138),i3k_get_string(1140), tmp_str, fun) 
	end
	if self:isPureColor(arg) then
		self._newPureColor = true;
		local tmp_str = i3k_get_string(1134) 
		local fun = (function(ok)
			if ok then
				self._newPureColor = false;
				i3k_sbean.StarSaveReset(self._curPart, self._curShape)
			end
		end)
		g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1138),i3k_get_string(1140), tmp_str, fun) 
	end
end

function wnd_starShape:isPureColor(arg, mustChange)
	local colorNum = 0;
	local colorPoint = 6;
	local tempColor = nil;
	for k,v in pairs(arg) do
		if not tempColor and v ~= colorPoint then
			tempColor = v
			colorNum = colorNum + 1
		else
			if tempColor == v or v == colorPoint then
				colorNum = colorNum + 1
			else
				break
			end
		end
	end
	if mustChange then return colorNum == 3 end
	if colorNum == 3 and not self:isSatisfyLead() then
		return true;
	end
	return false;
end

function wnd_starShape:isSatisfyLead()
	if self._curShape then
		local star = g_i3k_game_context:GetExpectStar()
		local nextStar = {};
		local colorNum = 0;
		for k,v in pairs(self._curShape) do
			local color = i3k_db_star_soul_colored_color[v].partIcon;
			if color == Color then
				self._newColorPoint = true;
			end
			table.insert(nextStar, {shape = k, color = v});
		end
		table.sort(nextStar ,function (a,b)
			return a.shape < b.shape
		end)
		for i,e in pairs(star) do
			local count = 0;
			if e.shape then
				for k,v in ipairs(nextStar) do
					local color = i3k_db_star_soul_colored_color[v.color].partIcon;
					if e.colorIndex == 0 or e.colorIndex == 5 then
						if v.shape == e.shape[k] then
							count = count + 1;
						else
							break;
						end
					else
						if color == e.color or color == Color then
							if v.shape == e.shape[k] then
								count = count + 1;
							else
								break;
							end
						end
					end
				end
				if count == #e.shape then
					return true;
				end
			end
		end
	end
	return false;
end

function wnd_starShape:onCloseUI(sender)
	if self._isNeedSave then
		local tmp_str = i3k_get_string(1141) 
		local fun = (function(ok)
			if ok then
				if self._isCache then
					i3k_sbean.StarQuitReset(self._curPart)
				end
				g_i3k_ui_mgr:CloseUI(eUIID_StarShape)
			end
		end)

		g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1142), i3k_get_string(1140), tmp_str, fun)
			
	else
		if self._isCache then
			i3k_sbean.StarQuitReset(self._curPart)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_StarShape)
	end
end

function wnd_starShape:onSaveBtn(sender)
	if (self._oldColorPoint and not self._newColorPoint) or (self._oldPureColor and not self._newPureColor) then
		local tmp_str = nil;
		if self._oldPureColor then
			tmp_str = i3k_get_string(1143)
		elseif self._oldColorPoint then
			tmp_str = i3k_get_string(1144)
		end

		local fun = (function(ok)
			if ok then
				i3k_sbean.StarSaveReset(self._curPart, self._curShape)
			end
		end)
		g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1139), i3k_get_string(1140), tmp_str, fun)
	else
		i3k_sbean.StarSaveReset(self._curPart, self._curShape)
	end
end

function wnd_starShape:isCanReset()
	local colorLock = g_i3k_game_context:GetColorSign() == 1;
	local shapeLock = g_i3k_game_context:GetShapeSign() == 1;
	local needItem = i3k_db_martial_soul_cfg.needItem;
	local needSign = i3k_db_martial_soul_cfg.needSign;
	local signItem = {}
	local counts = 0;
	if needItem then
		for i,e in ipairs(needItem) do
			if g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) >= e.needItemCount then
				counts = counts + 1;
				table.insert(signItem, e);
			end
		end
		if counts == #needItem then
			local isShapeSign = g_i3k_game_context:GetCommonItemCanUseCount(needSign[shapeSign].needItemID) >= needSign[shapeSign].needItemCount
			local isColorSign =  g_i3k_game_context:GetCommonItemCanUseCount(needSign[colorSign].needItemID) >= needSign[colorSign].needItemCount
			if shapeLock then
				counts = counts + 1;
			end
			if colorLock then
				counts = counts + 1;
			end
			if shapeLock and isShapeSign and not colorLock then
				table.insert(signItem, needSign[shapeSign]);
			elseif colorLock and isColorSign and not shapeLock then
				table.insert(signItem, needSign[colorSign]);
			elseif shapeLock and isShapeSign and colorLock and isColorSign then
				for i,e in ipairs(needSign) do
					table.insert(signItem, e);	
				end
			end
			if counts == #signItem then
				return signItem;
			end
		end
	end
	
	return false;
end

function wnd_starShape:onResetBtn(sender)
	local colorLock = g_i3k_game_context:GetColorSign();
	local shapeLock = g_i3k_game_context:GetShapeSign();
	local isColorLock = g_i3k_game_context:GetColorSign() == 1;
	local needItem =  self:isCanReset();
	if needItem then
		if self:isSatisfyLead() or (not isColorLock and self._newColorPoint) then
			local tmp_str = nil;
			if self:isSatisfyLead() then
				tmp_str = i3k_get_string(1133) 
			elseif self._newColorPoint then
				tmp_str = i3k_get_string(1126) 
			end
			
			local fun = (function(ok)
				if ok then
					self.resetBtn1:setTouchEnabled(false)
					i3k_sbean.StarPartReset(self._curPart, shapeLock, colorLock, needItem)
				end
			end)

			g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1145), i3k_get_string(1140), tmp_str, fun)
		else
			self.resetBtn1:setTouchEnabled(false)
			i3k_sbean.StarPartReset(self._curPart, shapeLock, colorLock, needItem)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1146))
	end
end

function wnd_starShape:chooseLockItem(sender, arg)
	if arg == 1 then
		if self.chooseImg1:isVisible() then
			self.chooseImg1:hide()
			g_i3k_game_context:SetShapeSign(0)
		else
			g_i3k_game_context:SetShapeSign(1)
			self.chooseImg1:show()
		end
	else
		if self.chooseImg2:isVisible() then
			g_i3k_game_context:SetColorSign(0)
			self.chooseImg2:hide()
		else
			g_i3k_game_context:SetColorSign(1)
			self.chooseImg2:show()
		end
	end
end

function wnd_starShape:updateNeedItem()
	self.chooseImg1:setVisible(g_i3k_game_context:GetShapeSign() == 1);
	self.chooseImg2:setVisible(g_i3k_game_context:GetColorSign() == 1);
	local widget = self._layout.vars
	local needSign = i3k_db_martial_soul_cfg.needSign;
	for i,e in ipairs(needSign) do
		widget["chooseBtn"..i]:onClick(self,self.chooseLockItem, i)
		widget["itemBg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.needItemID))
		widget["itemName"..i]:setText(g_i3k_db.i3k_db_get_common_item_name(e.needItemID))
		widget["itemName"..i]:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.needItemID)))
		widget["itemBtn"..i]:onClick(self, self.onClickItem, e.needItemID)
		widget["itemLockImg"..i]:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.needItemID))
		if e.needItemID == g_BASE_ITEM_DIAMOND or e.needItemID == g_BASE_ITEM_COIN then
			widget["itemNum"..i]:setText(e.needItemCount)
		else
			widget["itemNum"..i]:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) .."/".. e.needItemCount)
		end
		widget["itemNum"..i]:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) >= e.needItemCount))
		widget["itemImg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.needItemID,g_i3k_game_context:IsFemaleRole()))
	end
	
	local needItem = i3k_db_martial_soul_cfg.needItem;
	self.scroll:removeAllChildren()
	for i,e in ipairs(needItem) do
		local item = require("ui/widgets/xingweit")()
		item.vars.itemBorder:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.needItemID))
		item.vars.btn:onClick(self, self.onClickItem, e.needItemID)
		item.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.needItemID,g_i3k_game_context:IsFemaleRole()))
		item.vars.lockImg:setVisible(e.needItemID > 0)
		item.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(e.needItemID))
		item.vars.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.needItemID)))
		if e.needItemID == g_BASE_ITEM_DIAMOND or e.needItemID == g_BASE_ITEM_COIN then
			item.vars.num:setText(e.needItemCount)
		else
			item.vars.num:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) .."/".. e.needItemCount)
		end
		item.vars.num:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) >= e.needItemCount))
		self.scroll:addItem(item)
	end
end

function wnd_starShape:onSetShapeBtn(sender, index)
	if not g_i3k_ui_mgr:GetUI(eUIID_StarChangeShape) then
		g_i3k_ui_mgr:OpenUI(eUIID_StarChangeShape)
		g_i3k_ui_mgr:RefreshUI(eUIID_StarChangeShape, index)
	end
end

function wnd_starShape:onUpdateShapeBtn()
	local arg = g_i3k_game_context:GetExpectStar()
	local widget = self._layout.vars
	for i,e in pairs(arg) do
		if e.index then
			widget["text"..e.index]:hide()
			widget['mustChange'..e.index]:show()
			self.parts[e.index].rootGird:show()
			self.parts[e.index].wordTxt:show():setText(i3k_get_string(1147,e.index))
			self:changeShapeAndColor(e)
		end
	end
end

function wnd_starShape:ClsExpectStar(index)
	local widget = self._layout.vars
	local color = 4774
	self.parts[index].rootGird:hide()
	widget["text"..index]:show()
	widget['mustChange'..index]:hide()
	for i=1,9 do
		self.parts[index]["x"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(color))
	end
end

function wnd_starShape:changeShapeAndColor(arg)
	local part = self.parts[arg.index]
	for i=1,9 do
		part["x"..i]:hide()	
	end
	for k, v in pairs(arg.shape) do
		part["x"..(v+1)]:show():setImage(g_i3k_db.i3k_db_get_icon_path(arg.color))
	end
end

function wnd_starShape:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_starShape:onMustChangeBtn(sender, index)
	local arg = g_i3k_game_context:GetExpectStar()
	for k, v in pairs(arg) do
		if v.index == index then
			local curShape = g_i3k_game_context:GetPartShape(self._curPart)
			local isPureColor = self:isPureColor(curShape, true)
			local curColor = nil
			for k2, v2 in pairs(curShape) do
				if i3k_db_star_soul_colored_color[v2].isColorHole == 0 then
					curColor = v2
				end
			end
			local isSameShape = true
			for k2,v2 in pairs(v.shape) do
				if not curShape[v2] then
					isSameShape = false
					break
				end
			end
			local isSameColor = curColor == v.colorIndex
			if isPureColor and isSameColor and not isSameShape then
				g_i3k_ui_mgr:OpenUI(eUIID_StarShapeConfirm)
				g_i3k_ui_mgr:RefreshUI(eUIID_StarShapeConfirm, self._curPart, v.shapeIndex, curColor)
			else
				g_i3k_ui_mgr:OpenUI(eUIID_StarShapeTips)
				g_i3k_ui_mgr:RefreshUI(eUIID_StarShapeTips, isPureColor, isSameColor, isSameShape)
			end
		end
	end
end
function wnd_starShape:onMustChangeSucceed(arg)
	local consume = i3k_db_martial_soul_cfg.mustChangeConsume
	for i, v in ipairs(consume) do
		g_i3k_game_context:UseCommonItem(v.id, v.count)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_StarShape)
	g_i3k_ui_mgr:OpenUI(eUIID_StarShape)
	g_i3k_ui_mgr:RefreshUI(eUIID_StarShape, arg)
end
function wnd_create(layout, ...)
	local wnd = wnd_starShape.new()
	wnd:create(layout, ...)
	return wnd;
end

