--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-24 14:27:49
-- @description    : 
		-- 通用的tab按钮
---------------------------------
CommonTabBtn = class("CommonTabBtn", function()
    return ccui.Widget:create()
end)

function CommonTabBtn:ctor()
	self.index = 0
	self.open_status = true
    self:configUI()
    self:register_event()
end

function CommonTabBtn:configUI(  )
	self.size = cc.size(147, 64)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("common/common_tab_btn")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.container:setSwallowTouches(false)

    self.unselect_bg = self.container:getChildByName("unselect_bg")
    self.select_bg = self.container:getChildByName("select_bg")
    self.title = self.container:getChildByName("title")
    self.tab_tips = self.container:getChildByName("tab_tips")
    self.tab_tips:setVisible(false)
    self.red_num = self.container:getChildByName("red_num")
    self.red_num:setVisible(false)

    self:setBtnSelectStatus(false)
end

function CommonTabBtn:register_event(  )
	registerButtonEventListener(self.container, function (  )
		if not self.open_status then
			if self.data and self.data.notice then
				message(self.data.notice)
			end
		elseif self.clickCallBack then
			self.clickCallBack(self)
		end
	end, false, 3, nil, nil, nil, true)
end

function CommonTabBtn:addCallBack( callback )
	self.clickCallBack = callback
end

function CommonTabBtn:setExtendData( extend )
	if extend then
		if extend.tab_name then
			self.tabExtendName = extend.tab_name
		end
		-- 默认选中的index
		self.default_index = extend.default_index
		self.red_offset = extend.red_offset or cc.p(0, 0)
		self.red_scale = extend.red_scale or 1
		self.tab_tips:setScale(self.red_scale)
		self.title_offset = extend.title_offset or cc.p(0, 0)
		self.select_color = extend.select_color or cc.c4b(0xff,0xed,0xd6,0xff)
		self.select_outline = extend.select_outline or cc.c4b(0x2a,0x16,0x0f,0xff)
		self.normal_color = extend.normal_color or  cc.c4b(0xcf,0xb5,0x93,0xff)
		self.normal_outline = extend.normal_outline or cc.c4b(0x2a,0x16,0x0f,0xff)
		if extend.select_res then
			self.select_bg:loadTexture(extend.select_res, LOADTEXT_TYPE_PLIST)
		end

		if extend.normal_res then
			self.unselect_bg:loadTexture(extend.normal_res, LOADTEXT_TYPE_PLIST)
		end

		if extend.img_rect then
			self.select_bg:setCapInsets(extend.img_rect)
			self.unselect_bg:setCapInsets(extend.img_rect)
		end

		if extend.tab_size then
			self.size = extend.tab_size
			self:setContentSize(self.size)
			self.root_wnd:setContentSize(self.size)
			self.container:setContentSize(self.size)
		    self.unselect_bg:setContentSize(self.size)
		    self.select_bg:setContentSize(self.size)
		    self.tab_tips:setPosition(cc.p(self.size.width*0.88 + self.red_offset.x, self.size.height*0.9 + self.red_offset.y))
		    self.red_num:setPosition(cc.p(self.size.width*0.88-2+ self.red_offset.x, self.size.height*0.9 + self.red_offset.y))
		    self.title:setPosition(cc.p(self.size.width/2+self.title_offset.x, self.size.height/2+self.title_offset.y))
		    self.unselect_bg:setPosition(cc.p(self.size.width/2, self.size.height/2))
		    self.select_bg:setPosition(cc.p(self.size.width/2, self.size.height/2))
		end
	end
end

function CommonTabBtn:setData( data )
	if not data then return end

	-- 引导需要
	if self.tabExtendName then
		self.container:setName(self.tabExtendName..(data.index or 0))
	end

	self.data = data
	self.index = data.index
	if self.default_index then
		self:setBtnSelectStatus(self.index == self.default_index)
	end
	self.title:setString(data.title)

	if self.default_index and self.default_index == data.index then
		self.default_index = nil
		if self.clickCallBack then
			self.clickCallBack(self)
		end
	end
end

-- 刷新选择状态
function CommonTabBtn:setBtnSelectStatus( status )
	if status then
		self.unselect_bg:setVisible(false)
		self.select_bg:setVisible(true)
		self.title:setTextColor(self.select_color or cc.c4b(0xff,0xed,0xd6,0xff))
		self.title:enableOutline(self.select_outline or cc.c4b(0x2a,0x16,0x0f,0xff), 2)

	else
		self.unselect_bg:setVisible(true)
		self.select_bg:setVisible(false)
		self.title:setTextColor(self.normal_color or cc.c4b(0xcf,0xb5,0x93,0xff))
		self.title:enableOutline(self.normal_outline or cc.c4b(0x2a,0x16,0x0f,0xff), 2)
	end
end

-- 设置按钮是否可点击（置灰）
function CommonTabBtn:setBtnOpenStatus( status )
	self.open_status = status
	setChildUnEnabled(not status, self)
end

-- 显示红点
function CommonTabBtn:setRedStatus( status, num )
	if status then
		self.tab_tips:setVisible(true)
		if num and num > 0 then
			self.red_num:setVisible(true)
			if num > 99 then
				self.red_num:setString("99")
			else
				self.red_num:setString(num)
			end
		else
			self.red_num:setVisible(false)
		end
	else
		self.tab_tips:setVisible(false)
		self.red_num:setVisible(false)
	end
end

function CommonTabBtn:getIndex(  )
	return self.index
end

function CommonTabBtn:DeleteMe(  )
	
end