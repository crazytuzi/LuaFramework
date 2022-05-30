--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-09-20 14:55:06
-- @description    : 
		-- 花火大会单个红包的信息
---------------------------------
local _controller = PetardActionController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

PetardRedbagInfoWindow = PetardRedbagInfoWindow or BaseClass(BaseView)

function PetardRedbagInfoWindow:__init()
	self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "petard/petard_redbag_info_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("actionpetard", "actionpetard"), type = ResourcesType.plist},
	}
end

function PetardRedbagInfoWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(main_container , 2)

	self.close_btn = main_container:getChildByName("close_btn")

	self.num_txt = main_container:getChildByName("num_txt")

	local list_panel = main_container:getChildByName("list_panel")
	local scroll_size = list_panel:getContentSize()
	local setting = {
        item_class = PetardRedbagInfoItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 453,               -- 单元的尺寸width
        item_height = 92,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_size, setting)
end

function PetardRedbagInfoWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openRedbagInfoWindow(false)
	end, true, 2)
end

function PetardRedbagInfoWindow:openRootWnd( data )
	self:setData(data)
end

function PetardRedbagInfoWindow:setData( data )
	if not data then return end

	self.data = data

	-- 红包发放者
	if not self.role_head then
		self.role_head = PlayerHead.new(PlayerHead.type.circle)
	    self.role_head:setPosition(cc.p(242, 658))
	    self.main_container:addChild(self.role_head)
	end
	if data.send_face_id then
		self.role_head:setHeadRes(data.send_face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
	end
	if not self.role_name_txt then
		self.role_name_txt = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(242, 580))
		self.main_container:addChild(self.role_name_txt)
	end
	self.role_name_txt:setString(_string_format(TI18N("<div fontcolor=#ffea96>%s</div>的红包"), data.send_name or ""))

	-- 是否过期
	local cur_time = GameNet:getInstance():getTime()
	if cur_time >= data.end_time then -- 过期了
		self.num_txt:setString(TI18N("红包已过期"))
	else
		-- 剩余个数
		local max_num = data.max_num or 0
		local get_num = data.get_num or 0
		local left_num = max_num - get_num
		self.num_txt:setString(_string_format(TI18N("剩余个数：%d/%d"), left_num, max_num))
	end

	if data.get_red_packet_list and next(data.get_red_packet_list) ~= nil then
		local redbag_data = data.get_red_packet_list
		local role_vo = RoleController:getInstance():getRoleVo()
		local function sortFunc( objA, objB )
			local a_is_myself = (objA.r_rid == role_vo.rid and objA.r_srvid == role_vo.srv_id)
			local b_is_myself = (objB.r_rid == role_vo.rid and objB.r_srvid == role_vo.srv_id)
			if a_is_myself and not b_is_myself then
				return true
			elseif not a_is_myself and b_is_myself then
				return false
			else
				return objA.time > objB.time
			end
		end
		table.sort(redbag_data, sortFunc)

		self.item_scrollview:setData(redbag_data)
		self.item_scrollview:addEndCallBack(function()
	        local item_list = self.item_scrollview:getItemList()
	        for index,item in ipairs(item_list) do
	            item:setIndex(index)
	        end
	    end)
	end
end

function PetardRedbagInfoWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
	_controller:openRedbagInfoWindow(false)
end