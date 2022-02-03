--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2019-12-13 14:12:50
-- @description    : 
		-- 回归红包item
---------------------------------
local _controller = ReturnActionController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

ReturnActionRedbagItem = class("ReturnActionRedbagItem", function()
    return ccui.Widget:create()
end)

function ReturnActionRedbagItem:ctor()
	self:configUI()
	self:register_event()
end

function ReturnActionRedbagItem:configUI(  )
	self.size = cc.size(239, 328)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("returnaction/returnaction_redbag_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    main_container:setSwallowTouches(false)
    self.main_container = main_container

    self.wish_txt = main_container:getChildByName("wish_txt")
	self.wish_txt:setVisible(false)
    self.got_mask = main_container:getChildByName("got_mask")

    self.name_txt = createRichLabel(20, cc.c4b(255,75,82,255), cc.p(0.5, 0.5), cc.p(119.5, 30))
    main_container:addChild(self.name_txt)
end

function ReturnActionRedbagItem:register_event(  )
	registerButtonEventListener(self.main_container, handler(self, self.onClickItem), true, 1, nil, nil, nil, true)
end

function ReturnActionRedbagItem:addClickCallBack( callback )
	self.callback = callback
end

function ReturnActionRedbagItem:onClickItem(  )
	if not self.data then return end

	if self.callback then
		self.callback(self.data.red_packet_id, self.data.status)
	end
end

function ReturnActionRedbagItem:setData( data )
	if not data then return end

	self.data = data

	-- 发红包的角色名称
	if data.name then
		self.name_txt:setString(_string_format(TI18N("来自<div fontcolor=edd05d>%s</div>"), data.name))
	end

	self.got_mask:setVisible(data.status == 2)
end

function ReturnActionRedbagItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end