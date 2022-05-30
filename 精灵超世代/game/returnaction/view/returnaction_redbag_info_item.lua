--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2019-12-13 17:11:14
-- @description    : 
		-- 红包信息界面item
---------------------------------
local _controller = ReturnActionController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

ReturnActionRedbagInfoItem = class("ReturnActionRedbagInfoItem", function()
    return ccui.Widget:create()
end)

function ReturnActionRedbagInfoItem:ctor()
	self:configUI()
	self:register_event()
end

function ReturnActionRedbagInfoItem:configUI(  )
	self.size = cc.size(453, 92)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("returnaction/returnaction_redbag_info_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container

    self.image_bg = main_container:getChildByName("image_bg")
    self.time_txt = main_container:getChildByName("time_txt")
    self.time_txt:setTextColor(cc.c4b(255, 255, 255, 255))
    self.time_txt:setPosition(cc.p(102, 30))

    self.name_txt = createRichLabel(24, cc.c4b(255,234,150,255), cc.p(0, 0.5), cc.p(102, 62))
    main_container:addChild(self.name_txt)

    self.award_txt = createRichLabel(24, 1, cc.p(1, 0.5), cc.p(425, 46))
    main_container:addChild(self.award_txt)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setScale(0.8)
    self.role_head:setPosition(cc.p(50, 46))
    main_container:addChild(self.role_head)
end

function ReturnActionRedbagInfoItem:register_event(  )
	
end

function ReturnActionRedbagInfoItem:setData( data )
	if not data then return end

	self.data = data

	-- 头像
	self.role_head:setHeadRes(data.face_id)

	-- 角色名称
	local role_vo = RoleController:getInstance():getRoleVo()
	if role_vo.rid == data.r_rid and role_vo.srv_id == data.r_srvid then
		self.is_myself = true
		local myself_res = PathTool.getResFrame("actionpetard", "txt_cn_petard_myself")
		self.name_txt:setString(_string_format("%s  <img src='%s' scale=1.0 />", data.name, myself_res))
		self.image_bg:setVisible(true)
		self.image_bg:loadTexture(PathTool.getResFrame("actionpetard", "actionpetard_1009"), LOADTEXT_TYPE_PLIST)
	else
		self.is_myself = false
		self.name_txt:setString(data.name)
	end

	-- 时间
	self.time_txt:setString(TimeTool.getMDHMS(data.time))

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

function ReturnActionRedbagInfoItem:setIndex( index )
	if self.is_myself or not index then return end

	if (index%2) == 0 then
		self.image_bg:setVisible(false)
	else
		self.image_bg:setVisible(true)
		self.image_bg:loadTexture(PathTool.getResFrame("actionpetard", "actionpetard_1008"), LOADTEXT_TYPE_PLIST)
	end
end

function ReturnActionRedbagInfoItem:DeleteMe(  )
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end