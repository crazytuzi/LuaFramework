
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_starChangeShape = i3k_class("wnd_starChangeShape",ui.wnd_base)
local Star	= "ui/widgets/xwxzt"
local starPoint	= "ui/widgets/xingweit3"
local Gray		= 4774;
local partPressBg	= 4804
local partNormalBg	= 4805
local colorPressBg 	= 4803
local colorNormalBg = 4802
function wnd_starChangeShape:ctor()
	self._curShape = {};
	self._ishaveShape = false;
	self._curColor = 0;
	self._index = 0
	self._colorIndex = 0
	self._shapeIndex = 0
	self._shapes = nil
end

function wnd_starChangeShape:configure()
	local widget = self._layout.vars
	self.scroll = widget.scroll
	self.newPart	= widget.newPart;
	self.saveBtn	= widget.saveBtn;
	self.resetBtn	= widget.resetBtn;
	
	widget.saveBtn:onClick(self,self.onSaveBtn)
	widget.close:onClick(self, self.onCloseUI)
	widget.resetBtn:onClick(self, self.onResetBtn)
	self.colorsBg = {}
	for i = 1 , 5 do
		widget["colorBtn"..i]:onClick(self, self.ColorBtn, i)
		table.insert(self.colorsBg, widget["colorBg"..i])
	end
	self.tempPart = require(starPoint)()
	widget.newPart:addChild(self.tempPart)
	self.tempPart.vars.rootGird:setSizePercent(1, 1)
end

function wnd_starChangeShape:refresh(index)
	self._index = index
	self:initPartWidget()
end

function wnd_starChangeShape:initPartWidget()
	local expectStar = g_i3k_game_context:GetExpectStar()
	if expectStar and expectStar[self._index] then
		local shape =  expectStar[self._index].shape;
		if shape then
			self._curShape = expectStar[self._index].shape;
			self._curColor = expectStar[self._index].color;
			self._ishaveShape = true;
			self._shapeIndex = expectStar[self._index].shapeIndex
			self._colorIndex = expectStar[self._index].colorIndex
			if self._colorIndex ~= 0 then
				self.colorsBg[self._colorIndex]:setImage(g_i3k_db.i3k_db_get_icon_path(partPressBg))
			end
		end
	end
	self:updateNewPart()
	self.scroll:removeAllChildren()
	self.scroll:setBounceEnabled(false)
	local children = self.scroll:addChildWithCount(Star,4,#i3k_db_star_soul_shape)
	self._shapes = children
	for i,e in ipairs(children) do
		local pos = i3k_db_star_soul_shape[i].pos;
		e.vars.bg:onClick(self, self.SetCurShape, i)
		if self._shapeIndex == i then
			e.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(colorPressBg))
		end
		for i = 1,9 do
			e.vars["x"..i]:hide()
		end
		for k,v in pairs(pos) do
			e.vars["x"..(v+1)]:show():setImage(g_i3k_db.i3k_db_get_icon_path(Gray))
		end
	end
end

function wnd_starChangeShape:SetCurShape(sender,index)
	if self._shapeIndex == index then
		return
	end
	if self._shapeIndex ~= 0 then
		self._shapes[self._shapeIndex].vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(colorNormalBg))
	end
	sender:setImage(g_i3k_db.i3k_db_get_icon_path(colorPressBg))

	self._shapeIndex = index
	self._curShape = i3k_db_star_soul_shape[index].pos;
	self._ishaveShape = true;
	self:updateNewPart()
end

function wnd_starChangeShape:updateNewPart()
	self.tempPart.vars.wordTxt:setText(i3k_get_string(1150))
	for i = 1,9 do
		self.tempPart.vars["x"..i]:hide()
	end
	for k, v in pairs(self._curShape) do
		self.tempPart.vars["x"..(v+1)]:show():setImage(g_i3k_db.i3k_db_get_icon_path(self._curColor))
	end
end

function wnd_starChangeShape:onSaveBtn(sender)
	local arg = {index = self._index, shape = self._curShape, color = self._curColor, shapeIndex = self._shapeIndex, colorIndex = self._colorIndex};
	g_i3k_game_context:SetExpectStar(arg)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarShape, "onUpdateShapeBtn")
	g_i3k_ui_mgr:CloseUI(eUIID_StarChangeShape)
end

function wnd_starChangeShape:onResetBtn(sender)
	g_i3k_game_context:ClsExpectStar(self._index)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarShape, "ClsExpectStar", self._index)
	g_i3k_ui_mgr:CloseUI(eUIID_StarChangeShape)
end

function wnd_starChangeShape:ColorBtn(sender, arg)
	if self._ishaveShape then
		if self._colorIndex == arg then
			return
		end
		if self._colorIndex ~= 0 then
			self.colorsBg[self._colorIndex]:setImage(g_i3k_db.i3k_db_get_icon_path(partNormalBg))
		end
		self.colorsBg[arg]:setImage(g_i3k_db.i3k_db_get_icon_path(partPressBg))
		self._colorIndex = arg
		local color = i3k_db_star_soul_colored_color[arg].partIcon;
		self._curColor = color;
		self:updateNewPart()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1151))
	end
end

function wnd_starChangeShape:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_starChangeShape.new()
	wnd:create(layout, ...)
	return wnd;
end

