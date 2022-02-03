--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2019-12-14 14:25:24
-- @description    : 
		-- 回归红包传闻item
---------------------------------
local _controller = ReturnActionController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

ReturnActionRedbagMsgItem = class("ReturnActionRedbagMsgItem", function()
    return ccui.Widget:create()
end)

function ReturnActionRedbagMsgItem:ctor()
	self:configUI()
	self:register_event()
end

function ReturnActionRedbagMsgItem:configUI(  )
	self.size = cc.size(596, 123)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("returnaction/returnaction_redbag_msg_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container

    self.time_txt = main_container:getChildByName("time_txt")
    self.time_txt:setPosition(cc.p(126, 36))

    self.msg_txt = createRichLabel(24, 274, cc.p(0, 0.5), cc.p(126, 90))
    main_container:addChild(self.msg_txt)

    self.award_txt = createRichLabel(26, cc.c4b(149,83,34,255), cc.p(1, 0.5), cc.p(560, 61.5))
    main_container:addChild(self.award_txt)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setPosition(cc.p(64, 61.5))
    main_container:addChild(self.role_head)
end

function ReturnActionRedbagMsgItem:register_event(  )
	
end

function ReturnActionRedbagMsgItem:setData( data )
	if not data then return end

	self.data = data

	-- 头像
	self.role_head:setHeadRes(data.face_id)
	self.role_head:setLev(data.lev)

	-- 角色名称
	self.msg_txt:setString(_string_format(TI18N("<div fontcolor=249003>%s</div> 拆开红包获得"), data.name))

	-- 时间
	self.time_txt:setString(TimeTool.getYMDHM(data.time))

	-- 获得物品
	local award_str = ""
	for i,v in ipairs(data.item or {}) do
		local item_bid = v.item_id
		local item_num = v.num or 0
		local item_cfg = Config.ItemData.data_get_data(item_bid)
		if item_cfg then
			local iconsrc = PathTool.getItemRes(item_cfg.icon)
			award_str = award_str .. _string_format("<img src='%s' scale=0.3 /> %d", iconsrc, item_num)
		end
	end
	self.award_txt:setString(award_str)
end

function ReturnActionRedbagMsgItem:DeleteMe(  )
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end