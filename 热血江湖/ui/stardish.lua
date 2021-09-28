-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
local starPoint	= "ui/widgets/xingyaot1"
local starPart 	= "ui/widgets/xingyaot2"
local propArg1	= "ui/widgets/xingyaosxt2"
local propArg2	= "ui/widgets/xingyaosxt3"
local propArg3	= "ui/widgets/xingyaosxt4"

local Catalog1	= "ui/widgets/xingyaolbt1"
local Catalog2	= "ui/widgets/xingyaolbt2"

local PointBg	= 4780;
local Color		= 4648;

local colorNum = 6;
local starX = i3k_db_martial_soul_cfg.starLength
local starY = i3k_db_martial_soul_cfg.starWide

local None		= 0;
local Embattle	= 1;--布阵
local Activate	= 2;--激活

local PartBg	= 4781--放入星盘底板
local PartBg1	= 4782--普通底板
local PartBg2	= 4783--布阵底板
local l_partMinPosInStarDish

wnd_star_dish = i3k_class("wnd_star_dish",ui.wnd_base)

function wnd_star_dish:ctor()
	self._validPoint = {}
	self._isChange = false
	self._poptick = 0
	self.itemParent = nil
	self.unitX = 0
	self.unitY = 0
	self.originX = 0
	self.originY = 0
	self.listItems = nil
	self._state	= None;
	self.starPartNodes = {}
	self._insertCount = 0
	self._chlidList = {};
	self._insert = false
	self._partMinPosInStarDish = { }
	self._activateStarId = 0;
end

function wnd_star_dish:configure()
	local widgets = self._layout.vars
	self.starRed	= widgets.starRed
	self.soulRed	= widgets.soulRed
	self.shenDouRed = widgets.shenDouRed
	self.rankDesc	= widgets.rankDesc
	self.starDish	= widgets.starDish
	self.stateText	= widgets.stateText
	self.scroll		= widgets.Scroll
	self.starScroll	= widgets.itemScroll
	self.bz			= widgets.bz
	self.activate	= widgets.activate
	self.desText	= widgets.desText
	self.desText1	= widgets.desText1
	self.starBtn	= widgets.starBtn
	self.propBtn	= widgets.propBtn
	self.allBtn		= widgets.allBtn
	self.soulBtn	= widgets.soulBtn
	self.bzText1	= widgets.bzText1;
	self.bzText2	= widgets.bzText2;
	self.starBg		= widgets.starBg;
	self.closeBtn	= widgets.closeBtn;
	self.desTextBg	= widgets.desTextBg
	
	widgets.desText1:setText(i3k_get_string(1110))
	widgets.starBtn:stateToPressed(true)
	widgets.propBtn:stateToPressed(true)

	widgets.soulBtn:onClick(self, self.OnSoul)
	widgets.helpBtn:onClick(self, self.onHelpBtn)
	widgets.closeBtn:onClick(self, self.closeUI)
	widgets.starBtn:onClick(self, self.onStarDish)
	widgets.allBtn:onClick(self, self.onAllBtn)
	widgets.propBtn:onClick(self, self.onPropBtn)
	widgets.bzBtn:onClick(self, self.onEmbattleBtn)
	widgets.exitBtn:onClick(self, self.onExitBtn)
	widgets.resetBtn:onClick(self, self.onResetBtn)	
	widgets.activateBtn:onClick(self, self.onActivateBtn)
	widgets.leadBtn:onClick(self, self.onLeanBtn)
	widgets.shenDouBtn:onClick(self, self.onShenDouBtn)
	widgets.shenDouBtn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_martial_soul_cfg.shenDouShowLvl)
	self.tempPart = {}
	self.tempPartRoot = widgets.rootGird
	for i=1,9 do
		table.insert(self.tempPart, widgets["x"..i])	
	end
end

function wnd_star_dish:refresh()
	l_partMinPosInStarDish = g_i3k_game_context:getPosInStarDish()
	self:initPartWidget()
	self:rightData()
	self:leftData()
	self:updateMartialSoulRed()
end

function wnd_star_dish:CraetStarDish()
	self.starDish:removeAllChildren()
	local all_layer = self.starDish:addItemAndChild(starPoint, starX, starX*starY)
	for  i=1, starX*starY do
		local widget = all_layer[i].vars
		widget.poinText:hide()
		widget.point:hide()
		widget.pointBg:setImage(g_i3k_db.i3k_db_get_icon_path(PointBg))
	end
end

function wnd_star_dish:SetPosition()
	self.starDish:setBounceEnabled(false)
	local all_layer = self.starDish:getAllChildren()
	for  i=1, starX*starY do
		local widget = all_layer[i].vars
		widget.rootGird:onTouchEvent(self, self.clearListItemColor)
	end

	self.itemParent = all_layer[1].vars.rootGird:getParent()
	local pos1 = all_layer[1].vars.rootGird:getPosition()
	local pos2 = all_layer[2].vars.rootGird:getPosition()
	self.unitX = pos2.x - pos1.x
	pos2 = all_layer[8].vars.rootGird:getPosition()
	self.unitY = pos1.y - pos2.y
	pos2 = all_layer[42].vars.rootGird:getPosition()
	self.originX = pos1.x
	self.originY = pos2.y
	self.listItems = all_layer
	local expectId = g_i3k_game_context:GetExpectDish()
	if starId then
		expectId = starId;
	end
	if expectId then
		self:setCurStarColr(expectId, true);
	end

	local one
	local minPos
	for k,v in pairs(l_partMinPosInStarDish) do
		one = self.starPartNodes[k].vars
		one.bg:setImage(g_i3k_db.i3k_db_get_icon_path(PartBg))
		one.rootGird:setTouchEnabled(false)
		minPos = 8
		local partImg = g_i3k_db.i3k_db_get_icon_path(i3k_db_martial_soul_part[k].starName)
		for pos , info in pairs(v) do
			one = all_layer[info[1]].vars
			local color = i3k_db_star_soul_colored_color[info[2]].iconID;
			one.poinText:show()
			one.point:show()
			one.point:setImage(g_i3k_db.i3k_db_get_icon_path(color))
			one.poinText:setImage(partImg)
			one.rootGird:setProperty({v, k})
			self._validPoint[info[1]] = info[2];
			if minPos > pos then
				minPos = pos
			end
		end
		self._partMinPosInStarDish[k] = v[minPos][1] - 1
	end
end

function wnd_star_dish:CraetStarColr()
	self:ClearPartState();
	local curStar = g_i3k_game_context:GetCurStar();
	if curStar then
		local all_layer = self.starDish:getAllChildren()
		self:setCurStarColr(curStar);
	end
end

function wnd_star_dish:changeStar()
	if self._state	~= Embattle then
		self:starText()
		self:CraetStarDish()
		self:CraetStarColr()
	end
end

function wnd_star_dish:rightData(starId)
	self:starText() 
	local isPressed = self.propBtn:isStatePressed()
	if isPressed then
		self.desText1:show()
		self.desTextBg:show()
		self.propBtn:stateToPressed(true)
		self.allBtn:stateToNormal(true)
	else
		self.desText1:hide()
		self.desTextBg:hide()
		self.allBtn:stateToPressed(true)
		self.propBtn:stateToNormal(true)
	end
	self.starDish:setBounceEnabled(false)
	self:CraetStarDish();
	if self._state	== Embattle then
		self:SetPosition()
	else
		self:CraetStarColr();
	end
end

function wnd_star_dish:setCurStarColr(curStar, isLead)
	local star = i3k_db_star_soul[curStar];
	if star then
		local all_layer = self.starDish:getAllChildren()
		for i,e in ipairs(star.starDisk) do
			local widget = all_layer[e + 1].vars
			if isLead then
				local color = i3k_db_star_soul_colored_color[star.color[i]].leadIcon;
				widget.pointBg:setImage(g_i3k_db.i3k_db_get_icon_path(color))
			else
				widget.point:show()
				local color = i3k_db_star_soul_colored_color[star.color[i]].iconID;
				widget.point:setImage(g_i3k_db.i3k_db_get_icon_path(color))
			end
		end
	end
end

function wnd_star_dish:leftData()
	self.scroll:removeAllChildren()
	self.desText:hide();
	local curStar = g_i3k_game_context:GetCurStar();
	if curStar then
		local power = math.modf(g_i3k_db.i3k_db_get_battle_power(g_i3k_game_context:GetStarPropData()))
		local rankCfg = i3k_db_star_soul[curStar]
		local selecticon = require(propArg1)()
		selecticon.vars.name:setText(rankCfg.name)
		self.scroll:addItem(selecticon)
		local selecticon = require(propArg2)()
		selecticon.vars.power:setText(power)
		self.scroll:addItem(selecticon)
		if rankCfg then
			local count = g_i3k_game_context:GetActiveStarsCount();
			local addition = i3k_db_martial_soul_cfg.addition[count];
			local ratio = g_i3k_db.i3k_db_get_shen_dou_skill_prop_ratio(g_SHEN_DOU_SKILL_STAR_ID)
			for _, e in ipairs(rankCfg.propTb) do
				if e.propID ~= 0 then
					local node = require(propArg3)()
					local icon = g_i3k_db.i3k_db_get_property_icon(e.propID)
					node.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
					node.vars.propertyName:setText(g_i3k_db.i3k_db_get_property_name(e.propID))
					local value = e.propValue
					if addition and addition > 0 then
						value = e.propValue + e.propValue * addition;
					end
					node.vars.propertyValue:setText(i3k_get_prop_show(e.propID, math.modf(value * (1 + ratio))))
					self.scroll:addItem(node)
				end
			end
		end
	else
		self.desText:show();
	end
end

function wnd_star_dish:initPartWidget()
	local widgets = self._layout.vars
	local part = g_i3k_game_context:GetWeaponSoulParts();
	for i=1, 8 do
		local partBtn = "part"..i;
		local partdata = part[i].balls;
		local logsBar = require(starPart)()
		widgets[partBtn]:addChild(logsBar)
		local starName = i3k_db_martial_soul_part[i].starName;
		logsBar.vars.wordTxt:setImage(g_i3k_db.i3k_db_get_icon_path(starName))
		logsBar.vars.rootGird:setSizePercent(1.188, 1.188)
		logsBar.vars.rootGird:onTouchEvent(self, self.MoveTempPart, i)
		self.starPartNodes[i] = logsBar
		logsBar.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(PartBg1))
		for n = 1 , 9 do
			logsBar.vars["x"..(n)]:hide();
		end
		for k,v in pairs(partdata) do
			logsBar.vars["x"..(k+1)]:show()
			local color = i3k_db_star_soul_colored_color[v].partIcon;
			logsBar.vars["x"..(k+1)]:setImage(g_i3k_db.i3k_db_get_icon_path(color))
		end
	end
end

function wnd_star_dish:updatePartWidget(arg)
	l_partMinPosInStarDish[arg.partID] = nil
	for i = 1 , 9 do
		self.starPartNodes[arg.partID].vars["x"..(i)]:hide();
	end
	for k,v in pairs(arg.shape) do
		self.starPartNodes[arg.partID].vars["x"..(k+1)]:show()
		local color = i3k_db_star_soul_colored_color[v].partIcon;
		self.starPartNodes[arg.partID].vars["x"..(k+1)]:setImage(g_i3k_db.i3k_db_get_icon_path(color))
	end
end

function wnd_star_dish:logTable( table_name )
	local str = ""
	for k,v in pairs(table_name) do
		str = str.."k:"..k.."v:"..v.." "
	end
end

function wnd_star_dish:onActivateBtn(sender)
	self._state	= Embattle
	if self:isCanStarDisk() then
		self:logTable(self._partMinPosInStarDish)
		i3k_sbean.StarActivate(self._partMinPosInStarDish)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1135))
	end
end

function wnd_star_dish:closeUI(sender)
	if self._state	~= Embattle then
		g_i3k_ui_mgr:CloseUI(eUIID_StarDish)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1137))
	end
end

function wnd_star_dish:onLeanBtn(sender)
	if not g_i3k_ui_mgr:GetUI(eUIID_StarDishLead) then
		g_i3k_ui_mgr:OpenUI(eUIID_StarDishLead)
		g_i3k_ui_mgr:RefreshUI(eUIID_StarDishLead)
	end
end

function wnd_star_dish:onEmbattleBtn(sender)
	self:isEmbattle()
end

function wnd_star_dish:isEmbattle(starId)
	self.bz:hide();
	self.activate:show();
	self.bzText2:setText(i3k_get_string(1117))
	self._state	= Embattle;

	self:ChangePartBg(PartBg2)
	self:rightData(starId);
	local expectId = g_i3k_game_context:GetExpectDish()
	if expectId then
		local name = i3k_db_star_soul[expectId].name;
		self.stateText:setText(i3k_get_string(1113, name))
	else
		self.stateText:setText(i3k_get_string(1115))
	end
end

function wnd_star_dish:ChangePartBg(iconID)
	for i=1, 8 do
		self.starPartNodes[i].vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
	end
end

function wnd_star_dish:onExitBtn(sender)
	local tmp_str = i3k_get_string(1136)
	local fun = (function(ok)
		if ok then
			self.bz:show();
			self.bzText1:setText(i3k_get_string(1116))
			self.activate:hide();
			self:starText()
			self._state	= None;
			self:rightData();
			g_i3k_game_context:ClsCanActivateStar()
			self:ChangePartBg(PartBg1)
		end
	end)
	g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1139), i3k_get_string(1140), tmp_str, fun)
end

function wnd_star_dish:onResetBtn(sender)
	local tmp_str = i3k_get_string(1125)
	local fun = (function(ok)
		if ok then
			l_partMinPosInStarDish = g_i3k_game_context:clearPosInStarDish()
			self:rightData();
			self:ClearPartState()
			self:ChangePartBg(PartBg2)
		end
	end)
	g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1139), i3k_get_string(1140), tmp_str, fun)
end

function wnd_star_dish:onPropBtn(sender)
	local isPressed = self.propBtn:isStatePressed()
	if not isPressed then
		self.propBtn:stateToPressed(true)
		self.allBtn:stateToNormal(true)
		self._insert = false
		self.desTextBg:show()
		self.desText:show();
		self.desText1:show();
		self.scroll:show();
		self.starScroll:hide();
		self:leftData()
	end
end

function wnd_star_dish:onAllBtn(sender)
	local isPressed = self.allBtn:isStatePressed()
	if not isPressed then
		self:updateAllBtn()
		self:updateCatalog()
	end
end

function wnd_star_dish:updateAllBtn()
	self.allBtn:stateToPressed(true)
	self.propBtn:stateToNormal(true)
	self.desText:hide();
	self.desText1:hide();
	self.scroll:hide();
	self.desTextBg:hide()
	self.starScroll:show();
end

function wnd_star_dish:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1111))
end

function wnd_star_dish:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_star_dish:onStarDish(sender)
	if self._state	~= Embattle then
		if not g_i3k_ui_mgr:GetUI(eUIID_StarDish) then
			g_i3k_ui_mgr:CloseUI(eUIID_MartialSoul)
			g_i3k_ui_mgr:OpenUI(eUIID_StarDish)
			g_i3k_ui_mgr:RefreshUI(eUIID_StarDish)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1137))
	end
end

function wnd_star_dish:OnSoul(sender)
	if self._state	~= Embattle then
		g_i3k_ui_mgr:CloseUI(eUIID_StarDish)
		g_i3k_ui_mgr:OpenUI(eUIID_MartialSoul)
		g_i3k_ui_mgr:RefreshUI(eUIID_MartialSoul)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1137))
	end
end

function wnd_star_dish:onShenDouBtn(sender)
	if self._state	~= Embattle then
		g_i3k_logic:OpenShenDouUI(eUIID_StarDish)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1137))
	end
end
function wnd_star_dish:starText()
	local curStar = g_i3k_game_context:GetCurStar();
	if curStar then
		local rankCfg = i3k_db_star_soul[curStar]
		self.stateText:setText(rankCfg.name)
		if self._state	~= Embattle and rankCfg.bgIcon and rankCfg.bgIcon > 0 then
			self.starBg:show():setImage(g_i3k_db.i3k_db_get_icon_path(rankCfg.bgIcon))
		else
			self.starBg:hide();
		end
	else
		self.stateText:setText(i3k_get_string(1114))
	end
end

function wnd_star_dish:MoveTempPart(sender,eventType, part)
	local allPart = g_i3k_game_context:GetWeaponSoulParts();
	local startInfo = allPart[part].balls
	if self._state	== Embattle then
		local touchPos = g_i3k_ui_mgr:GetMousePos()
		local pos = self.tempPartRoot:getParent():convertToNodeSpace(touchPos)

		if eventType == ccui.TouchEventType.began then
			for i = 1 , 9 do
				self.tempPart[i]:hide()
			end
			for k, v in pairs(startInfo) do
				local color = i3k_db_star_soul_colored_color[v].iconID;
				self.tempPart[k+1]:show():setImage(g_i3k_db.i3k_db_get_icon_path(color))
			end
			self.tempPartRoot:show()
			self.tempPartRoot:setPosition(pos)
			
		elseif eventType == ccui.TouchEventType.moved then
			self.tempPartRoot:setPosition(pos)
		elseif eventType == ccui.TouchEventType.ended then
			self.tempPartRoot:hide()
		elseif eventType == ccui.TouchEventType.canceled then
			local rtb = {}
			local minPos = 8
			for k, v in pairs(startInfo) do
				if k < minPos then
					minPos = k
				end
			end
			local one = self.tempPart[minPos+1]
			pos =  one:getParent():convertToWorldSpace(one:getPosition())
			pos =  self.itemParent:convertToNodeSpace(pos)

			local x, y = i3k_round((pos.x - self.originX)/self.unitX + 1.0), i3k_round(6.0 - (pos.y - self.originY)/self.unitY)
			one = x + (y-1) * starX
			if x < 1 or x > starX or y < 1 or y > starY or self._validPoint[one] then
				self.tempPartRoot:hide()
				return
			end
			rtb[minPos] = {one, startInfo[minPos]}

			local x1, y1
			for k, v in pairs(startInfo) do
				if k ~= minPos then
					x1 = x + (k%3) - (minPos%3)
					y1 = y + i3k_integer(k/3) - i3k_integer(minPos/3)
					one = x1 + (y1-1) * starX
					if x1 < 1 or x1 > starX or y1 < 1 or y1 > starY or self._validPoint[one] then
						self.tempPartRoot:hide()
						return
					end
					rtb[k] = {one,v}
				end
			end
			
			self._partMinPosInStarDish[part] = rtb[minPos][1] -1
			l_partMinPosInStarDish[part] = rtb
			local partImg = g_i3k_db.i3k_db_get_icon_path(i3k_db_martial_soul_part[part].starName)
			for k,v in pairs(rtb) do
				one = self.listItems[v[1]].vars
				local color = i3k_db_star_soul_colored_color[v[2]].iconID;
				one.poinText:show()
				one.point:show()
				one.point:setImage(g_i3k_db.i3k_db_get_icon_path(color))
				one.poinText:setImage(partImg)
				one.rootGird:setProperty({rtb, part})
				self._validPoint[v[1]] = v[2];
			end
			self.starPartNodes[part].vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(PartBg))
			sender:setTouchEnabled(false)
			self.tempPartRoot:hide()
		end
	else
		if not g_i3k_ui_mgr:GetUI(eUIID_StarShape) then
			g_i3k_ui_mgr:OpenUI(eUIID_StarShape)
			local arg = {startInfo = startInfo, part = part};
			g_i3k_ui_mgr:RefreshUI(eUIID_StarShape, arg)
		end
	end
end

function wnd_star_dish:ClearPartState()
	self._validPoint = {}
	self._partMinPosInStarDish = {}
	for i,e in ipairs(self.starPartNodes) do
		e.vars.rootGird:setTouchEnabled(true)
		e.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(PartBg2))
	end
end

function wnd_star_dish:clearListItemColor(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		local partTbl = sender:getProperty()
		if partTbl then
			for k,v in pairs(partTbl[1]) do
				local one = self.listItems[v[1]].vars
				one.point:setImage(g_i3k_db.i3k_db_get_icon_path(PointBg))
				one.poinText:hide()
				one.point:hide()
				one.rootGird:setProperty(nil)
				self._validPoint[v[1]] = nil;
			end
			self.starPartNodes[partTbl[2]].vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(PartBg2))
			self._partMinPosInStarDish[partTbl[2]] = nil
			l_partMinPosInStarDish[partTbl[2]] = nil
			self.starPartNodes[partTbl[2]].vars.rootGird:setTouchEnabled(true)
		end
	end
end

function wnd_star_dish:isCanStarDisk()
	local nothave = {};
	g_i3k_game_context:ClsCanActivateStar()
	local have = g_i3k_game_context:GetActiveStars()
	for k,v in pairs(i3k_db_star_soul) do
		if not have[k] then
			table.insert(nothave, v);
		end
	end
	table.sort(nothave ,function (a,b)
		return a.starSoulId < b.starSoulId
	end)
	for k,v in ipairs(nothave) do
		local count = 0;
		for k1,v1 in ipairs(v.starDisk) do
			if self._validPoint[v1 + 1] then 
				if (self._validPoint[v1 + 1] == v.color[k1]) or (self._validPoint[v1 + 1] == colorNum) then
					count = count + 1;
				end
			end
		end
		if count == #v.starDisk then
			g_i3k_game_context:SetCanActivateStar(v.starSoulId)
		end
	end
	local canActivaStars = g_i3k_game_context:GetCanActivateStar()
	if #canActivaStars > 0 then
		return true;
	end
	return false;
end

function wnd_star_dish:updateCatalog(pickUp)
	local isPressed = self.allBtn:isStatePressed()
	if isPressed then
		if pickUp then
			self._insert = false
		end
		local firstNode = self:updateCatalogList() 
		if firstNode then
			self:updateSelectedCatalog(firstNode.vars.btn)
		end
	end
end

function wnd_star_dish:updateSelectedCatalog(sender, gearsId)
	local isPressed = self.allBtn:isStatePressed()
	if isPressed then
		if not gearsId then
			local starId =  g_i3k_game_context:GetCurStar()
			if self._activateStarId and self._activateStarId > 0 then
				starId = self._activateStarId;
			end
			if starId then
				gearsId = i3k_db_star_soul[starId].rank;
			else
				gearsId = 1;
			end
		end
		for i, e in ipairs(self.starScroll:getAllChildren()) do
			if  e.vars.btn.actID == gearsId then
				e.vars.btn:stateToPressed(true)
			else
				e.vars.btn:stateToNormal(true)
			end
		end
		if self.sender == sender and not self.isPickUp then
			self._insert = false
			sender:stateToNormal(true)
			self:pickUpList()
			return
		else
			self.sender = sender
			if self._insert then
				self:pickUpList()
			end
			self.isPickUp = false
		end

		-- 判断是否包含子目录
		self:addChildCatalog(gearsId)
		self.starScroll:jumpToChildWithIndex(gearsId+1)
	end
end

function wnd_star_dish:jumpToCatalog(gearsId)
	self:updateAllBtn()
	self._activateStarId = gearsId;
	self:updateCatalog(true)
	self._activateStarId  = 0;
end

function wnd_star_dish:updateCatalogList()
	local firstNode
	self.starScroll:removeAllChildren()
	for i,e in ipairs(i3k_db_star_soul_gears) do
		local node = require(Catalog2)()
		local starId =  g_i3k_game_context:GetCurStar()
		if self._activateStarId and self._activateStarId > 0 then
			starId = self._activateStarId;
		end
		if starId then
			if i == i3k_db_star_soul[starId].rank then
				firstNode = node
			end
		else
			if i == 1 then
				firstNode = node
			end
		end
		node.vars.name:setText(e.name);	
		node.vars.btn:onClick(self, self.updateSelectedCatalog, e.gearsId)
		node.vars.btn.actID = e.gearsId
		self.starScroll:addItem(node)
	end
	return firstNode;
end

function wnd_star_dish:SelectedStar(sender, starId)
	g_i3k_ui_mgr:OpenUI(eUIID_StarFlare)
	g_i3k_ui_mgr:RefreshUI(eUIID_StarFlare, starId)
end

function wnd_star_dish:addChildCatalog(gearsId)
	local validRank = {};
	self._insertCount = 0;
	for k,v in pairs(i3k_db_star_soul) do
		if v.rank == gearsId then
			table.insert(validRank, v);
		end
	end
	table.sort(validRank ,function (a,b)
		return a.starSoulId < b.starSoulId
	end)
	
	for i,e in ipairs(validRank) do
		self._insertCount = self._insertCount + 1
		local node = require(Catalog1)()
		node.vars.nameLabel:setText(e.name)
		node.vars.btn:onClick(self, self.SelectedStar, e.starSoulId)
		node.vars.btn.actID = gearsId + self._insertCount
		node.vars.colorPoint:setImage(g_i3k_db.i3k_db_get_icon_path(e.listIcon));
		if g_i3k_game_context:isUseStar(e.starSoulId) then
			node.vars.state:setImage(g_i3k_db.i3k_db_get_icon_path(4701));
		elseif g_i3k_game_context:isHaveStar(e.starSoulId) then
			node.vars.state:setImage(g_i3k_db.i3k_db_get_icon_path(4700));
		else
			node.vars.state:setImage(g_i3k_db.i3k_db_get_icon_path(4699));
		end 
		self.starScroll:insertChildToIndex(node, gearsId + self._insertCount)
	end
	local children = self.starScroll:getAllChildren()
	for i, e in ipairs(children) do
		if e.vars.nameLabel then
			self._insert = true
		end
	end
	self._chlidList = {insertCount = self._insertCount, gearsId = gearsId};
end

--收起
function wnd_star_dish:pickUpList()
	--删除这几个
	local children = self.starScroll:getAllChildren()
	for i=1, self._chlidList.insertCount do
		self.starScroll:removeChildAtIndex(self._chlidList.gearsId  + 1)
	end
	self.isPickUp = true
	self._insert = false
end

function wnd_star_dish:LeadStarDish(starId)
	self:ClearPartState()
	self:isEmbattle(starId);
end

function wnd_star_dish:updateMartialSoulRed()
	self.soulRed:setVisible(g_i3k_game_context:IsWeaponSoulCanUp())
	self.shenDouRed:setVisible(g_i3k_db.i3k_db_get_shen_dou_red())
end

function wnd_create(layout)
	local wnd = wnd_star_dish.new()
	wnd:create(layout)
	return wnd
end
	
