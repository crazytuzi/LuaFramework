--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-11 17:34:09
-- @description    : 
		-- 天界副本章节
---------------------------------
local _controller = HeavenController:getInstance()
local _model = _controller:getModel()
local _table_sort = table.sort
local _string_format = string.format

HeavenMainChapter = class("HeavenMainChapter", function()
    return ccui.Widget:create()
end)

function HeavenMainChapter:ctor()
	self.chapter_list = {}
	self.line_list = {}

	self:configUI()
	self:register_event()
end

function HeavenMainChapter:configUI(  )
	self.size = cc.size(720, 840)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

    self.container = ccui.Layout:create()
    self.container:setTouchEnabled(true)
    self.container:setContentSize(self.size)
    self.container:setAnchorPoint(0,0)
    self:addChild(self.container)
end

function HeavenMainChapter:setExtendData( last_chapter_id )
	self.last_chapter_id = last_chapter_id or 1
end

function HeavenMainChapter:setData( data )
	if not data then return end

	local chapter_datas = data.chapter_datas or {}
	local index = data.index or 1
	self.c_type = 1
	if index%2 == 0 then
		self.c_type = 2
	end

	for k,v in pairs(self.line_list) do
		v:setVisible(false)
	end

	local is_delay = true -- 是否分帧创建，第一次分帧
	for k,v in pairs(self.chapter_list) do
		is_delay = false
		v:setVisible(false)
	end

	for i,cData in ipairs(chapter_datas) do
		if is_delay then
			delayRun(self.container, i*2 / display.DEFAULT_FPS, function()
				self:createChapterItem(i, cData)
	        end)
		else
			self:createChapterItem(i, cData)
		end
	end
end

-- 创建连接线
function HeavenMainChapter:createChapterLine( index )
	local line_info = HeavenConst.Chapter_Line_Info_1
	if self.c_type ~= 1 then
		line_info = HeavenConst.Chapter_Line_Info_2
	end
	local l_info = line_info[index]
	if l_info then
		local line_pos = l_info[1]
		local line_width = l_info[2]
		local line_rotate = l_info[3]
		local line_node = self.line_list[index]
		if not line_node then
			line_node = createImage(self.container, PathTool.getResFrame("heaven", "heaven_1001"), line_pos.x, line_pos.y, cc.p(0.5, 0.5), true, 1, true)
			self.line_list[index] = line_node
		end
		line_node:setPosition(line_pos)
		line_node:setContentSize(cc.size(line_width, 9))
		line_node:setRotation(line_rotate)
		line_node:setVisible(true)
	end
end

function HeavenMainChapter:createChapterItem( index, chapter_data )
	local chapter_item = self.chapter_list[index]
	if not chapter_item then
		chapter_item = HeavenChapterItem.new()
		self.container:addChild(chapter_item, 2)
    	self.chapter_list[index] = chapter_item
	end
	chapter_item:setVisible(true)
    chapter_item:setData(chapter_data, index, self.c_type)

    -- 连接线
    if self.last_chapter_id and self.last_chapter_id ~= chapter_data.id then
    	self:createChapterLine(index)
    end
end

function HeavenMainChapter:register_event(  )
	
end

function HeavenMainChapter:DeleteMe(  )
	for k,v in pairs(self.chapter_list) do
		v:DeleteMe()
		v = nil
	end
	self:removeAllChildren()
    self:removeFromParent()
end

-----------------------@ item 
-- 章节item
HeavenChapterItem = class("HeavenChapterItem", function()
    return ccui.Widget:create()
end)

function HeavenChapterItem:ctor()
	self:configUI()
	self:register_event()
end

function HeavenChapterItem:configUI( )
	self.size = cc.size(200, 200)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

    self.container = ccui.Layout:create()
    self.container:setTouchEnabled(true)
    self.container:setContentSize(self.size)
    self.container:setAnchorPoint(0.5, 0.5)
    self.container:setPosition(cc.p(self.size.width/2, self.size.height/2))
    self:addChild(self.container)
end

function HeavenChapterItem:register_event(  )
	registerButtonEventListener(self.container, function (  )
		self:onClickChapterItem()
	end, true)
end

function HeavenChapterItem:onClickChapterItem(  )
	if not self.is_open then
		message(self.close_msg or "")
		return
	end
	if self.config_data then
		_controller:openHeavenChapterWindow(true, self.config_data.id)
	end
end

function HeavenChapterItem:onClickAwardItem(  )
	if self.config_data then
		_controller:openHeavenStarAwardWindow(true, self.config_data.id)
	end
end

function HeavenChapterItem:setData( data, index, c_type )
	if not data then return end

	self.index = index or 1
	self.c_type = c_type or 1

	if self.chapter_vo ~= nil then
        if self.update_self_event ~= nil then
            self.chapter_vo:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end

	self.config_data = data
	self.chapter_vo = _model:getChapterDataById(data.id) -- 可能是没有的

	if self.chapter_vo then
		if self.update_self_event == nil then
            self.update_self_event = self.chapter_vo:Bind(HeavenEvent.Update_Chapter_Vo_Event, function()
                self:updateChapterItem()
            end)
        end
	end

	self:updateChapterItem()
end

function HeavenChapterItem:updateChapterItem(  )
	if not self.config_data then return end

	-- 位置
	local pos
	if self.c_type == 1 then
		pos = HeavenConst.Chapter_Pos_1[self.index]
	else
		pos = HeavenConst.Chapter_Pos_2[self.index]
	end
	if pos then
		self:setPosition(pos)
	end

	if not self.chapter_icon then
		self.chapter_icon = createImage(self.container, nil, self.size.width/2, self.size.height/2, cc.p(0.5, 0.5), false)
	end

	if not self.award_icon then
		self.award_icon = createImage(self.container, PathTool.getResFrame("heaven", "heaven_1003"), self.size.width-24, self.size.height-24, cc.p(0.5, 0.5), true)
		self.award_icon:setTouchEnabled(true)
		registerButtonEventListener(self.award_icon, function (  )
			self:onClickAwardItem()
		end, true)
	end

	if not self.title_bg then
		self.title_bg = createImage(self.container, PathTool.getResFrame("heaven", "heaven_1004"), self.size.width/2, 27, cc.p(0.5, 0.5), true, nil, true)
	    self.title_bg:setCapInsets(cc.rect(22, 17, 1, 1))
	    self.title_bg:setContentSize(cc.size(156, 34))
	end

	-- 章节
	if not self.title_txt then
		self.title_txt = createLabel(26,cc.c3b(255, 242, 199),cc.c3b(55, 16, 0),self.size.width/2,27,"",self.container,2,cc.p(0.5, 0.5))
	end

	-- 满星通关
	if self.chapter_vo and self.chapter_vo.is_finish == HeavenConst.Chapter_Pass_Status.FullPass then
		self:showPassIcon(true)
	else
		self:showPassIcon(false)
	end

	local icon_res = PathTool.getPlistImgForDownLoad("bigbg/heaven", string.format("heaven_chapter_%d", self.config_data.ico or 1))
	local function load_callback(  )
		self.size = self.chapter_icon:getContentSize()
		self:setContentSize(self.size)
		self.container:setContentSize(self.size)
		self:adjustNodePos()
	end
	self.bg_load = loadImageTextureFromCDN(self.chapter_icon, icon_res, ResourcesType.single, self.bg_load, nil, load_callback)

	self.title_txt:setString(self.config_data.type)

	-- 是否开启
	self.is_open, self.close_msg = _model:checkHeavenChapterIsOpen(self.config_data.id)
	if self.is_open then
		setChildUnEnabled(false, self.container)
		self.award_icon:setVisible(true)
		self.title_txt:setVisible(true)
		self.title_bg:setVisible(true)
	else
		setChildUnEnabled(true, self.container)
		self.award_icon:setVisible(false)
		self.title_txt:setVisible(false)
		self.title_bg:setVisible(false)
		self:showPassIcon(false)
	end

	-- 红点
	if self.award_icon then
		local red_status = false
		if self.chapter_vo then
			red_status = self.chapter_vo:getRedStatus()
		end
		addRedPointToNodeByStatus(self.award_icon, red_status, 5, 5)
	end
end

-- 调整位置
function HeavenChapterItem:adjustNodePos(  )
	self.container:setPosition(cc.p(self.size.width/2, self.size.height/2))
	self.chapter_icon:setPosition(cc.p(self.size.width/2, self.size.height/2))
	self.title_bg:setPosition(cc.p(self.size.width/2, 27))
	self.title_txt:setPosition(cc.p(self.size.width/2, 27))
	self.award_icon:setPosition(cc.p(self.size.width-24, self.size.height-24))
	if self.pass_icon then
		self.pass_icon:setPosition(cc.p(32, self.size.height-30))
	end
end

-- 通过状态
function HeavenChapterItem:showPassIcon( status )
	if status == true then
		if not self.pass_icon then
			self.pass_icon = createImage(self.container, PathTool.getResFrame("heaven", "txt_cn_heaven_pass"), 25, self.size.height-60, cc.p(0.5, 0.5), true, 2)
		end
		self.pass_icon:setVisible(true)
	elseif self.pass_icon then
		self.pass_icon:setVisible(false)
	end
end

function HeavenChapterItem:DeleteMe(  )
	if self.bg_load then
		self.bg_load:DeleteMe()
		self.bg_load = nil
	end
	if self.chapter_vo ~= nil then
        if self.update_self_event ~= nil then
            self.chapter_vo:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end
	self:removeAllChildren()
    self:removeFromParent()
end