-- --------------------------------------------------------------------
-- 我要变强列表子项
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
StrongerItem = class("StrongerItem", function()
    return ccui.Widget:create()
end)

function StrongerItem:ctor(type)
	self.ctrl = StrongerController:getInstance()
	self.model = self.ctrl:getModel()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.item_list = {}

	self.scroe = {}
	self.max = {}

	self:configUI()
	self:register_event()
end

function StrongerItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("stronger/stronger_item"))
	
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(606,133))
	self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")
	self.main_container:setTouchEnabled(true)
	self.main_container:setSwallowTouches(false)

	self.bg = self.main_container:getChildByName("bg")

	self.name = self.main_container:getChildByName("name")
	self.title = self.main_container:getChildByName("title")
	self.title:setString(TI18N("当前评分/本服最高："))

	self.btn = self.main_container:getChildByName("btn")
	self.btn_label = self.btn:getChildByName("btn_label")
	self.btn_label:setString(TI18N("展开"))
	-- self.btn:setTitleText(TI18N("展开"))
	self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(cc.c4b(0x29,0x4a,0x15,0xff), 2)
    end
	--[[self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
    end--]]

    self.goods_icon = self.main_container:getChildByName("goods_icon")
end

function StrongerItem:setData( data )
	self.data = data
	self.name:setString(data.name)
	if data.icon then 
		local res = PathTool.getItemRes(data.icon)
		loadSpriteTexture(self.goods_icon,res,LOADTEXT_TYPE)
	end
end

function StrongerItem:register_event(  )
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

--获取资源子项隐藏这些
function StrongerItem:hideBg(  )
	self.title:setString(self.data.desc)
	self.btn:setPositionY(68)
end

function StrongerItem:addCallBack( value )
	self.callback =  value
end

function StrongerItem:setBtnCallBack( value )
	self.btn_callback = value
end

function StrongerItem:getIsShow(  )
	return self.is_show
end

function StrongerItem:setSelect(bool)
	-- local res 
	-- if bool then 
	-- 	res = PathTool.getResFrame("common","common_1020")
	-- else
	-- 	res = PathTool.getResFrame("common","common_1029")
	-- end
	-- self.bg:loadTexture(res, LOADTEXT_TYPE_PLIST)
end

function StrongerItem:showMessagePanel( bool )
	self.is_show = bool
	if bool then 
		if self.msg_panel == nil then
			self:createMessagePanel()
		end
		-- self.btn:setTitleText(TI18N("收起"))
		self.btn_label:setString(TI18N("收起"))
	else
		-- self.btn:setTitleText(TI18N("展开"))
		self.btn_label:setString(TI18N("展开"))
	end
	self.msg_panel:setVisible(bool)
end

function StrongerItem:createMessagePanel( )
	if self.msg_panel == nil then 
		self.msg_panel = ccui.Layout:create()
		self.msg_panel:setAnchorPoint(0,1)
		self.main_container:addChild(self.msg_panel)
	end
	if self.data.final_sub_list and next(self.data.final_sub_list)~=nil then --有子项, 这个是后续动态添加进去的,所以不能直接用配置表的 sub_list
		local len = #self.data.final_sub_list
		self.msg_panel:setContentSize(cc.size(585,len*(118+5)))
		self.msg_panel:setPosition(10,0)
		for i,v in pairs(self.data.final_sub_list) do
			local item = StrongerSecItem.new()
			self.item_list[i] = item
			item:setData(Config.StrongerData.data_resource_two[v])
			self.msg_panel:addChild(item)
			item:setPosition(cc.p(0,self.msg_panel:getContentSize().height-(118+5)*(i-1)))
		end	
	end
end


--获取资源隐藏这些
function StrongerItem:hideBgII(  )
	for k,v in pairs(self.item_list) do
		v:hideBg()
	end
end

--返回msgpanel大小
function StrongerItem:getMsgPanleSize(  )
	if self.msg_panel then 
		return self.msg_panel:getContentSize()
	end
end

function StrongerItem:clearList(  )
end

function StrongerItem:DeleteMe(  )
	if self.item_list and self.item_list ~= nil then 
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
end