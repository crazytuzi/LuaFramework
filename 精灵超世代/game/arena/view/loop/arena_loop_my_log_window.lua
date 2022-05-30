-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      循环赛我的比赛日志
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopMyLogWindow = ArenaLoopMyLogWindow or BaseClass(BaseView)

local controller = ArenaController:getInstance()
local string_format = string.format
local role_vo = RoleController:getInstance():getRoleVo()

function ArenaLoopMyLogWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.is_full_screen = false
	self.layout_name = "arena/arena_loop_my_log_window"
	self.res_list = {
	-- {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist},
	}
end

function ArenaLoopMyLogWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
	local main_panel = main_container:getChildByName("main_panel")
	self.good_cons = main_panel:getChildByName("good_cons")
	main_panel:getChildByName("win_title"):setString(TI18N("比赛记录"))
	
	self.close_btn = main_panel:getChildByName("close_btn")
	-- self.list_view = main_panel:getChildByName("list_view")
	
	self.empty_tips = main_panel:getChildByName("empty_tips")
	self.empty_tips:getChildByName("desc"):setString(TI18N("暂无任何竞猜"))
	
	self.item = main_panel:getChildByName("item")
end

function ArenaLoopMyLogWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openArenaLoopMyLogWindow(false)
		end
	end)
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openArenaLoopMyLogWindow(false)
		end
	end)
	if self.update_my_log_list_event == nil then
		self.update_my_log_list_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateMylogListEvent, function(list)
			self:updateMyGuessList(list)
		end)
	end
end

function ArenaLoopMyLogWindow:openRootWnd()
	controller:requestMyLoopLogInfo()
end

function ArenaLoopMyLogWindow:updateMyGuessList(list)
	if list == nil or next(list) == nil then
		self.empty_tips:setVisible(true)
		if self.scroll_view then
			self.scroll_view:setVisible(false)
		end
	else
		self.empty_tips:setVisible(false)
		if self.scroll_view == nil then
			local size = self.good_cons:getContentSize()
			local setting = {
				item_class = ArenaLoopMyLogItem,
				start_x = 6.5,
				space_x = 0,
				start_y = 5,
				space_y = 5,
				item_width = 600,
				item_height = 136,
				row = 0,
				col = 1,
				need_dynamic = true
			}
			self.scroll_view = CommonScrollViewLayout.new(self.good_cons, nil, nil, nil, size, setting)
		end
		self.scroll_view:setVisible(true)
		self.scroll_view:setData(list, nil, nil, self.item)
	end
end

function ArenaLoopMyLogWindow:close_callback()
	if self.update_my_log_list_event then
		GlobalEvent:getInstance():UnBind(self.update_my_log_list_event)
		self.update_my_log_list_event = nil
	end
	if self.scroll_view then
		self.scroll_view:DeleteMe()
		self.scroll_view = nil
	end
	controller:openArenaLoopMyLogWindow(false)
end




-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛我的竞猜单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopMyLogItem = class("ArenaLoopMyLogItem", function()
	return ccui.Layout:create()
end)

function ArenaLoopMyLogItem:ctor()
	self.is_completed = false
end

--==============================--
--desc:设置扩展参数  {node = self.item, count = self.interaction_count} 
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function ArenaLoopMyLogItem:setExtendData(node)	
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)
		
		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)
		
		local left_role = self.root_wnd:getChildByName("left_role")
		self.left_head = PlayerHead.new(PlayerHead.type.circle)
		self.left_head:setPosition(60, 60)
		left_role:addChild(self.left_head)
		
		local right_role = self.root_wnd:getChildByName("right_role")
		self.right_head = PlayerHead.new(PlayerHead.type.circle)
		self.right_head:setPosition(60, 60)
		right_role:addChild(self.right_head)
		
		self.success_img = self.root_wnd:getChildByName("success_img")  -- 胜利的标志,在该竞猜有结果才会显示
		self.left_name = self.root_wnd:getChildByName("left_name")
		self.right_name = self.root_wnd:getChildByName("right_name")

        self.fight_result = createRichLabel(24, 175, cc.p(0, 0.5), cc.p(295, 34))
        self.root_wnd:addChild(self.fight_result)

		self.fight_type = self.root_wnd:getChildByName("fight_type")
		self.root_wnd:getChildByName("info_btn"):setVisible(false)
		self.check_fight_btn = self.root_wnd:getChildByName("check_fight_btn") -- 该竞猜已经出结果的时候的观战按钮
		self.check_fight_btn:getChildByName("label"):setString(TI18N("观看"))

        self.time = self.root_wnd:getChildByName("time")
		
		self:registerEvent()
	end
end

function ArenaLoopMyLogItem:registerEvent()
	self.right_head:addCallBack(function()
		if self.data ~= nil then
            if self.data.srv_id ~= "" then
			    FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
            else
                
            end
		end
	end, false)
	
	self.check_fight_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.data.replay_id ~= 0 then
				BattleController:getInstance():csRecordBattle(self.data.replay_id)
			end
		end
	end)
end

function ArenaLoopMyLogItem:setData(data)
	if data then
		self.data = data
        -- 左边都是自己
		self.left_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
		self.left_name:setString(role_vo.name)
		self.right_head:setHeadRes(self.data.face, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
		self.right_name:setString(self.data.name)

        if self.data.ret == 1 then
            self.success_img:loadTexture(PathTool.getResFrame("common", "txt_cn_common_90012"), LOADTEXT_TYPE_PLIST)
        else
            self.success_img:loadTexture(PathTool.getResFrame("common", "txt_cn_common_90013"), LOADTEXT_TYPE_PLIST)
        end
        if self.data.type == 1 then     -- 进攻
            if self.data.ret == 1 then
                self.fight_type:setString(TI18N("进攻成功"))
            else
                self.fight_type:setString(TI18N("进攻失败"))
            end
        else
            if self.data.ret == 1 then
                self.fight_type:setString(TI18N("防守成功"))
            else
                self.fight_type:setString(TI18N("防守失败"))
            end
        end
        self.time:setString(TimeTool.getYMDHMS(data.time))

        local config =  Config.ArenaData.data_const.score_iocn
        local str = ""
        if config then
            if data.score == 0 then
                str = string_format("<img src=%s scale=0.3 visible=true />%s", PathTool.getItemRes(config.val), TI18N("不变"))
            else
                if data.ret == 1 then --赢了
                    str = string_format("<img src=%s scale=0.3 visible=true /><div fontcolor=#249003>+%s</div>  <img src=%s scale=1 visible=true />", PathTool.getItemRes(config.val), data.score, PathTool.getResFrame("common", "common_1086"))
                else
                    str = string_format("<img src=%s scale=0.3 visible=true /><div fontcolor=#e14737>%s</div>  <img src=%s scale=1 visible=true />", PathTool.getItemRes(config.val), data.score, PathTool.getResFrame("common", "common_1087"))
                end
            end
        end
        self.fight_result:setString(str)
	end
end


function ArenaLoopMyLogItem:DeleteMe()
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