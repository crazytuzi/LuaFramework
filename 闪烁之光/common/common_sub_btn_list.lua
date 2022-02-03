--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-20 20:06:16
-- @description    : 
		-- 通用的二级菜单按钮列表(见家园商店)
---------------------------------

CommonSubBtnList = class("CommonSubBtnList", function() 
	return ccui.Widget:create()
end)

function CommonSubBtnList:ctor( parent, anchorpoint, pos, btn_size, call_back )
	self.btn_objects = {}
	self.call_back = call_back
	self.init_flag = true

	if parent ~= nil then
		parent:addChild(self)
	end
	anchorpoint = anchorpoint or cc.p(0.5, 0.5)
	self:setAnchorPoint(anchorpoint)
	if pos ~= nil then
		self:setPosition(pos)
	end
	self.btn_size = btn_size or cc.size(129, 54)
end

-- data 必须为从1开始连续的列表
function CommonSubBtnList:setData( data, select_index )
	if not data then return end
	self.data = data
	self.btn_num = #data

	local size = cc.size(self.btn_num*self.btn_size.width + 6, self.btn_size.height)
	self:setContentSize(size)

	if not self.image_bg then
		self.image_bg = createImage(self, PathTool.getResFrame("common","common_2020"), 0, 0, cc.p(0, 0), true, nil, true)
	end
	self.image_bg:setContentSize(size)

	for k,object in pairs(self.btn_objects) do
		if object.btn then
			object.btn:setVisible(false)
		end
	end

	for i,btnInfo in ipairs(data) do
		local object = self.btn_objects[i]
		if not object then
			object = self:createSubButton(btnInfo.index)
			self.btn_objects[i] = object
		end
		object.btn:setVisible(true)
		if btnInfo.status ~= nil then
			self:setBtnOpenStatus(object.btn,btnInfo.status)
		end
		
		local pos_x = 3 + (i-1)*self.btn_size.width
		object.btn:setPosition(cc.p(pos_x, 0))

		local normal_res = self:getBtnResByIndex(i, false)
		object.normal_bg:loadTexture(normal_res, LOADTEXT_TYPE_PLIST)
		local select_res = self:getBtnResByIndex(i, true)
		object.select_bg:loadTexture(select_res, LOADTEXT_TYPE_PLIST)

		object.title = btnInfo.title
		object.label:setString(string.format("<div fontcolor=#CFB593 outline=2,#2A160E>%s</div>", object.title))
		if i == 1 then
			object.normal_bg:setScaleX(-1)
			object.select_bg:setScaleX(-1)
		else
			object.normal_bg:setScaleX(1)
			object.select_bg:setScaleX(1)
		end
	end

	if self.init_flag or select_index then
		self.init_flag = false
		select_index = select_index or 1
		self.cur_index = nil
		self:_onClickSubBtnByIndex(select_index)
	end
end

-- index：第几个按钮 is_select:是否为选中
function CommonSubBtnList:getBtnResByIndex( index, is_select )
	local res = PathTool.getResFrame("common","common_2022")
	if index == 1 or index == self.btn_num then
		if is_select then
			res = PathTool.getResFrame("common","common_2021")
		else
			res = PathTool.getResFrame("common","common_2023")
		end
	elseif is_select then
		res = PathTool.getResFrame("common","common_2024")
	end
	return res
end

function CommonSubBtnList:createSubButton( index )
	local object = {}
	object.btn = ccui.Widget:create()
    object.btn:setCascadeOpacityEnabled(true)
    object.btn:setTouchEnabled(true)
    object.btn:setAnchorPoint(cc.p(0, 0))
    object.btn:setContentSize(self.btn_size)
    self:addChild(object.btn)

    registerButtonEventListener(object.btn, function (  )
    	self:_onClickSubBtnByIndex(index)
    end, false)

    object.normal_bg = createImage(object.btn, nil, self.btn_size.width*0.5, self.btn_size.height*0.5, cc.p(0.5, 0.5), true, nil, true)
    object.normal_bg:setContentSize(self.btn_size)

    object.select_bg = createImage(object.btn, nil, self.btn_size.width*0.5, self.btn_size.height*0.5, cc.p(0.5, 0.5), true, nil, true)
    object.select_bg:setContentSize(self.btn_size)

    object.label = createRichLabel(24, cc.c4b(207,181,147,255), cc.p(0.5, 0.5), cc.p(self.btn_size.width*0.5, self.btn_size.height*0.5))
    object.btn:addChild(object.label)

    object.index = index

    return object
end

-- 点击按钮
function CommonSubBtnList:_onClickSubBtnByIndex( index )
	if self.cur_index and self.cur_index == index then return end

	for i,btnInfo in ipairs(self.data) do
		if btnInfo.index == index and btnInfo.status ~= nil and btnInfo.status == false then
			if btnInfo.tips ~=nil then
				message(btnInfo.tips)
			end
			return
		end
	end

	self.cur_index = index

	for i,object in ipairs(self.btn_objects) do
		if object.index == index then
			object.normal_bg:setVisible(false)
			object.select_bg:setVisible(true)
			if object.title then
				object.label:setString(string.format("<div fontcolor=#FFEDD6 outline=2,#2A160E>%s</div>", object.title))
			end
		else
			object.normal_bg:setVisible(true)
			object.select_bg:setVisible(false)
			if object.title then
				object.label:setString(string.format("<div fontcolor=#CFB593 outline=2,#2A160E>%s</div>", object.title))
			end
		end
	end

	if self.call_back then
		self.call_back(index)
	end
end

-- 设置按钮是否可点击（置灰）
function CommonSubBtnList:setBtnOpenStatus( obj,status )
	setChildUnEnabled(not status, obj)
end

-- 引导需要
function CommonSubBtnList:setGuideName( name )
	for k,object in pairs(self.btn_objects) do
		object.btn:setName("guide_btn_" .. name .. k)
	end
end

-- 红点
function CommonSubBtnList:setBtnRedStatus( index, red_status )
	for i,object in ipairs(self.btn_objects) do
		if object.index == index then
			addRedPointToNodeByStatus(object.btn, red_status, 2, 8)
			break
		end
	end
end

function CommonSubBtnList:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end