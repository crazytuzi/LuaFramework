-- --------------------------------------------------------------------
-- 变强 常见问题面板
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
ProblemPanel = class("ProblemPanel", function()
    return ccui.Widget:create()
end)

local offset_y = 5

function ProblemPanel:ctor()
	self.ctrl = StrongerController:getInstance()
	self.model = self.ctrl:getModel()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.item_list = {}
	self.cur_select = nil
	self.cur_index = 1

	self:configUI()
	self:register_event()
end

function ProblemPanel:configUI(  )
	self.root_wnd = ccui.Layout:create()
	self.root_wnd:setContentSize(cc.size(620,770))
	self.root_wnd:setAnchorPoint(0,0)
	self:addChild(self.root_wnd)

	-- local res = PathTool.getResFrame("common", "common_1034")
	-- self.bg = createScale9Sprite(res, self.root_wnd:getContentSize().width/2,self.root_wnd:getContentSize().height/2, LOADTEXT_TYPE_PLIST, self.root_wnd)
	-- self.bg:setContentSize(cc.size(617,772))
	-- self.bg:setAnchorPoint(0.5,0.5)

	-- self.scroll = createScrollView(self.bg:getContentSize().width,self.bg:getContentSize().height-15,1,10,self.bg,ccui.ScrollViewDir.vertical)
	self.scroll = createScrollView(617,772-15,1,10,self.root_wnd,ccui.ScrollViewDir.vertical)

	self:createItemList()
end

function ProblemPanel:createItemList(  )
	local list = deepCopy(Config.StrongerData.data_problem) --PartnerController:getModel():getAllPartnerList()
	table.sort(list,SortTools.KeyLowerSorter("sort"))

	self.max_height = math.max((133+offset_y)*#list,self.scroll:getContentSize().height)
	self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height))

	for k,v in pairs(list) do
		delayRun(self.scroll,0.05*k,function (  )
			local item = ProblemItem.new()
			item:setData(v)
			self.scroll:addChild(item)
			item:setPosition(5,self.max_height-3-(item:getContentSize().height+offset_y)*(k-1))
			self.item_list[k] = item
			-- item:addCallBack(function ( cell )
			-- 	if self.cur_select ~= nil then 
			-- 		self.cur_select:setSelect(false)
			-- 		self.cur_select:showMessagePanel(false)
			-- 	end
			-- 	self.cur_select = cell
			-- 	self.cur_index = k
			-- 	self.cur_select:setSelect(true)
			-- 	self.cur_select:showMessagePanel(true)
			-- 	self:adjustPos()
			-- end)

			item:setBtnCallBack(function ( cell )
				self.cur_index = k
				self:clickCallBack(cell)
			end)
		end)
	end
end

function ProblemPanel:clickCallBack( cell )
	if self.cur_select ~= nil and self.cur_select:getData().id~=cell:getData().id then 
		self.cur_select:setSelect(false)
		self.cur_select:showMessagePanel(false)
	end
	self.cur_select = cell
	local status = self.cur_select:getIsShow()
	if status then 
		--位置缩回去
		self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height))
		local height = self.max_height
		for k,v in pairs(self.item_list) do
			v:setPosition(5,height-3-(v:getContentSize().height+offset_y)*(k-1))
		end
		self.cur_select:setSelect(false)
		self.cur_select:showMessagePanel(false)
	else
		self.cur_select:setSelect(true)
		self.cur_select:showMessagePanel(true)
		self:adjustPos()
	end

	if self.cur_select then 
		local offset_height = (self.cur_index - 1) * 136
		local temp_percent = offset_height / self.max_height * 100
		if self.height then 
			offset_height = (self.cur_index - 1) * 270
			temp_percent = offset_height / (self.max_height+self.height) * 100
		end
		self.scroll:jumpToPercentVertical(math.ceil(temp_percent))
	end
	
end

function ProblemPanel:adjustPos(  )
	if self.cur_select ~= nil then 
		self.height = self.cur_select.msg_panel:getContentSize().height or 310
		self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height +self.height))
		local height = self.max_height+self.height
		for k,v in pairs(self.item_list) do
			if k<=self.cur_index then 
				v:setPosition(5,height-3-(133+offset_y)*(k-1))
			else
				v:setPosition(5,height-3-self.height-(133+offset_y)*(k-1))
			end
		end
	end
end

function ProblemPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)    
end

function ProblemPanel:register_event(  )
end

function ProblemPanel:DeleteMe()
	doStopAllActions(self.scroll)
	if self.item_list and self.item_list ~= nil then 
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
end



-- --------------------------------------------------------------------
-- 变强 推荐阵容面板子项
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
ProblemItem = class("ProblemItem", function()
    return ccui.Widget:create()
end)

function ProblemItem:ctor()
	self.ctrl = StrongerController:getInstance()
	self.model = self.ctrl:getModel()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.item_list = {}
	self.is_show = false

	self:configUI()
	self:register_event()
end

function ProblemItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("stronger/problem_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    --self:setPosition(-40,-32)
    self:setAnchorPoint(0,1)
    self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(604,133))
	self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.name = self.main_container:getChildByName("name")
    self.bg = self.main_container:getChildByName("bg")
    self.btn = self.main_container:getChildByName("btn")
    self.btn_label = self.btn:getChildByName("btn_label")
    self.btn_label:setString(TI18N("查看"))
	-- self.btn:setTitleText(TI18N("查看"))

	self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(cc.c4b(0x29,0x4a,0x15,0xff), 2)
    end
end

function ProblemItem:register_event(  )
	self.btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
        	playButtonSound2()
			if self.btn_callback then
				self:btn_callback()
			end
        end
    end)

    self:addTouchEventListener(function(sender, event_type) 
		if event_type == ccui.TouchEventType.ended then
				self.touch_end = sender:getTouchEndPosition()
				local is_click = true
				if self.touch_began ~= nil then
					is_click =
						math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
						math.abs(self.touch_end.y - self.touch_began.y) <= 20
				end
				if is_click == true then
					playButtonSound2()
					if self.callback then
						self:callback()
					end
				end
			elseif event_type == ccui.TouchEventType.moved then
			elseif event_type == ccui.TouchEventType.began then
				self.touch_began = sender:getTouchBeganPosition()
			elseif event_type == ccui.TouchEventType.canceled then
			end
	end)
end

function ProblemItem:addCallBack( value )
	self.callback =  value
end

function ProblemItem:setBtnCallBack( value )
	self.btn_callback = value
end

function ProblemItem:setData( data )
	self.data = data
	self.name:setString(data.name)
end

function ProblemItem:getData(  )
	return self.data
end

function ProblemItem:getIsShow(  )
	return self.is_show
end

function ProblemItem:setSelect(bool)
	-- local res 
	-- if bool then 
	-- 	res = PathTool.getResFrame("common","common_1020")
	-- else
	-- 	res = PathTool.getResFrame("common","common_1029")
	-- end
	-- self.bg:loadTexture(res, LOADTEXT_TYPE_PLIST)
end

function ProblemItem:showMessagePanel( bool )
	self.is_show = bool
	if bool then 
		if self.msg_panel == nil then
			self:createMessagePanel()
		end
		-- self.btn:setTitleText(TI18N("收起"))
		self.btn_label:setString(TI18N("收起"))
	else
		-- self.btn:setTitleText(TI18N("查看"))
		self.btn_label:setString(TI18N("查看"))
	end
	self.msg_panel:setVisible(bool)
end

function ProblemItem:createMessagePanel( )
	if self.msg_panel == nil then 
		-- self.msg_panel = ccui.Layout:create()
		-- self.msg_panel:setContentSize(cc.size(585,218))
		-- self.msg_panel:setAnchorPoint(0,0)
		-- self.main_container:addChild(self.msg_panel)
		local res = PathTool.getResFrame("common","common_1021")
		self.msg_panel = createScale9Sprite(res, 10, -5, LOADTEXT_TYPE_PLIST, self.main_container)
		self.msg_panel:setContentSize(cc.size(585,210))
		self.msg_panel:setAnchorPoint(0,1)
	end

	self.desc = createRichLabel(22, 175, cc.p(0,1), cc.p(17,self.msg_panel:getContentSize().height-15), 0, 0, 550)
	self.msg_panel:addChild(self.desc)
	--self.desc:setString(TI18N("很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的描述"))
	self.desc:setString(self.data.desc)
	self.msg_panel:setContentSize(cc.size(585,self.desc:getSize().height + 20))
	self.desc:setPosition(17, self.msg_panel:getContentSize().height - 7 )
end

function ProblemItem:DeleteMe()
end
