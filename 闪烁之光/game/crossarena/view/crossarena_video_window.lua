--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-20 17:37:01
-- @description    : 
		-- 跨服竞技场 挑战记录
---------------------------------
local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()

CrossareanVideoWindow = CrossareanVideoWindow or BaseClass(BaseView)

function CrossareanVideoWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "crossarena/crossarena_video_window"
end

function CrossareanVideoWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(main_container, 1)

	main_container:getChildByName("win_title"):setString(TI18N("比赛记录"))
	main_container:getChildByName("txt_tips"):setString(TI18N("录像可在详情中查看"))

	self.close_btn = main_container:getChildByName("close_btn")

	local list_panel = main_container:getChildByName("list_panel")
    self.list_panel = list_panel
	local scroll_view_size = list_panel:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 4,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 603,               -- 单元的尺寸width
        item_height = 216,              -- 单元的尺寸height
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(list_panel, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0,0))

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function CrossareanVideoWindow:createNewCell(  )
	local cell = CrossareanVideoItem.new()
    return cell
end

function CrossareanVideoWindow:numberOfCells(  )
	if not self.video_datas then return 0 end
    return #self.video_datas
end

function CrossareanVideoWindow:updateCellByIndex( cell, index )
	if not self.video_datas then return end
    cell.index = index
    local cell_data = self.video_datas[index]
    cell:setData(cell_data)
end

function CrossareanVideoWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openCrossarenaVideoWindow(false)
	end, true, 2)

	registerButtonEventListener(self.background, function (  )
		_controller:openCrossarenaVideoWindow(false)
	end, false, 2)

	self:addGlobalEvent(CrossarenaEvent.Update_Video_Data_Event, function ( data )
		if data.type == 1 then
			self:setData(data.arena_cluster_log)
		end
	end)
end

function CrossareanVideoWindow:setData( data )
	if not data then return end

	self.video_datas = data

    if #self.video_datas == 0 then
        commonShowEmptyIcon(self.list_panel, true, {text = TI18N("暂无数据")})
    else
        commonShowEmptyIcon(self.list_panel, false)
    end
	self.item_scrollview:reloadData()
end

function CrossareanVideoWindow:openRootWnd(  )
	_controller:sender25616(1)
end

function CrossareanVideoWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openCrossarenaVideoWindow(false)
	_model:updateCrossarenaRedStatus(CrossarenaConst.Red_Index.Record, false)
end

-----------------------------------@ item
CrossareanVideoItem = class("CrossareanVideoItem", function()
    return ccui.Widget:create()
end)

function CrossareanVideoItem:ctor()
	self:configUI()
	self:register_event()
end

function CrossareanVideoItem:configUI(  )
	self.size = cc.size(603, 216)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("crossarena/crossarena_video_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")

    self.left_head_pos = container:getChildByName("left_head_pos")
    self.right_head_pos = container:getChildByName("right_head_pos")
    self.left_arrow = container:getChildByName("left_arrow")
    self.right_arrow = container:getChildByName("right_arrow")
    self.left_result = container:getChildByName("left_result")
    self.right_result = container:getChildByName("right_result")

    self.left_srv_name = container:getChildByName("left_srv_name")
    self.left_name = container:getChildByName("left_name")
    self.left_score = container:getChildByName("left_score")
    self.left_level = container:getChildByName("left_level")

    self.right_srv_name = container:getChildByName("right_srv_name")
    self.right_name = container:getChildByName("right_name")
    self.right_score = container:getChildByName("right_score")
    self.right_level = container:getChildByName("right_level")

    self.battle_result = container:getChildByName("battle_result")
    self.battle_result:setString("")
    self.time_txt = container:getChildByName("time_txt")

    container:getChildByName("left_title_score"):setString(TI18N("积分"))
    container:getChildByName("left_title_level"):setString(TI18N("等级"))
    container:getChildByName("right_title_score"):setString(TI18N("积分"))
    container:getChildByName("right_title_level"):setString(TI18N("等级"))

    self.btn_detial = container:getChildByName("btn_detial")

    if not self.left_head then
		self.left_head = PlayerHead.new(PlayerHead.type.circle)
		self.left_head:setScale(0.8)
	    self.left_head:setAnchorPoint(cc.p(0.5, 0.5))
	    self.left_head:setPosition(cc.p(0, 0))
	    self.left_head_pos:addChild(self.left_head)
	    self.left_head:addCallBack( function()
        	if self.data and self.data.srv_id and self.data.rid and self.data.srv_id ~= "" then
        		local role_vo = RoleController:getInstance():getRoleVo()
        		if self.data.srv_id == role_vo.srv_id and self.data.rid == role_vo.rid then
        			message(TI18N("你不认识你自己了么？"))
        		else
        			FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
        		end
	        else
	        	message(TI18N("来自异域，无法查看"))
	        end
	    end,false)
	end

	if not self.right_head then
		self.right_head = PlayerHead.new(PlayerHead.type.circle)
		self.right_head:setScale(0.8)
	    self.right_head:setAnchorPoint(cc.p(0.5, 0.5))
	    self.right_head:setPosition(cc.p(0, 0))
	    self.right_head_pos:addChild(self.right_head)
	    self.right_head:addCallBack( function()
	    	if self.data and self.data.def_srv_id and self.data.def_rid and self.data.def_srv_id ~= "" then
        		local role_vo = RoleController:getInstance():getRoleVo()
        		if self.data.def_srv_id == role_vo.srv_id and self.data.def_rid == role_vo.rid then
        			message(TI18N("你不认识你自己了么？"))
        		else
        			FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.def_srv_id, rid = self.data.def_rid})
        		end
	        else
	        	message(TI18N("来自异域，无法查看"))
	        end
	    end,false)
	end
end

function CrossareanVideoItem:register_event(  )
	registerButtonEventListener(self.btn_detial, function (  )
		if self.data then
			ElitematchController:getInstance():openElitematchFightVedioPanel(true, self.data, 1, 2)
		end
	end, true)
end

function CrossareanVideoItem:setData( data )
	if not data then return end

	self.data = data

	-- 左侧
	self.left_name:setString(data.atk_name)
	local left_srv_str = getServerName(data.srv_id)
	if left_srv_str == "" then
		left_srv_str = TI18N("异域")
	end
	self.left_srv_name:setString("[" .. left_srv_str .. "]")
	self.left_level:setString(data.atk_lev)
	self.left_score:setString(data.atk_score)
	if self.left_head then
		self.left_head:setHeadRes(data.atk_face, false, LOADTEXT_TYPE, data.atk_face_file, data.atk_face_update_time)
	end

	-- 右侧
	self.right_name:setString(data.def_name)
	local right_srv_str = getServerName(data.def_srv_id)
	if right_srv_str == "" then
		right_srv_str = TI18N("异域")
	end
	self.right_srv_name:setString("[" .. right_srv_str .. "]")
	self.right_level:setString(data.def_lev)
	self.right_score:setString(data.def_score)
	if self.right_head then
		self.right_head:setHeadRes(data.def_face, false, LOADTEXT_TYPE, data.def_face_file, data.def_face_update_time)
	end

	-- 战斗结果
	if data.ret == 1 then -- 进攻方(左侧)胜利
		loadSpriteTexture(self.left_result, PathTool.getResFrame("common", "txt_cn_common_90012"), LOADTEXT_TYPE_PLIST)
		loadSpriteTexture(self.right_result, PathTool.getResFrame("common", "txt_cn_common_90013"), LOADTEXT_TYPE_PLIST)
		-- 积分箭头
		self.left_arrow:setVisible(true)
		self.right_arrow:setVisible(true)
		loadSpriteTexture(self.left_arrow, PathTool.getResFrame("common", "common_1086"), LOADTEXT_TYPE_PLIST)
		loadSpriteTexture(self.right_arrow, PathTool.getResFrame("common", "common_1087"), LOADTEXT_TYPE_PLIST)
	else
		loadSpriteTexture(self.left_result, PathTool.getResFrame("common", "txt_cn_common_90013"), LOADTEXT_TYPE_PLIST)
		loadSpriteTexture(self.right_result, PathTool.getResFrame("common", "txt_cn_common_90012"), LOADTEXT_TYPE_PLIST)

		-- 积分箭头(进攻方失败积分不变化)
		self.left_arrow:setVisible(false)
		self.right_arrow:setVisible(false)
	end

	-- 时间
	self.time_txt:setString(TimeTool.getYMDHM(data.time))
	-- 战斗状态
	local role_vo = RoleController:getInstance():getRoleVo()
	if role_vo then
		if role_vo.rid == data.rid and role_vo.srv_id == data.srv_id then -- 我方为挑战
			if data.ret == 1 then -- 挑战方胜利
				self.battle_result:setTextColor(cc.c3b(36, 144, 3))
				self.battle_result:setString(TI18N("进攻成功"))
			else
				self.battle_result:setTextColor(cc.c3b(217, 80, 20))
				self.battle_result:setString(TI18N("进攻失败"))
			end
		elseif role_vo.rid == data.def_rid and role_vo.srv_id == data.def_srv_id then -- 我为防守
			if data.ret == 1 then -- 挑战方胜利
				self.battle_result:setTextColor(cc.c3b(217, 80, 20))
				self.battle_result:setString(TI18N("防守失败"))
			else
				self.battle_result:setTextColor(cc.c3b(36, 144, 3))
				self.battle_result:setString(TI18N("防守成功"))
			end
		end
	end
end

function CrossareanVideoItem:DeleteMe(  )
	if self.left_head then
		self.left_head:DeleteMe()
		self.left_head = nil
	end
	if self.right_head then
		self.right_head:DeleteMe()
		self.right_head = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end