-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛玩家排行榜
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionRankWindow = ArenaChampionRankWindow or BaseClass(BaseView)

local role_vo = RoleController:getInstance():getRoleVo()
local string_format = string.format

function ArenaChampionRankWindow:__init(view_type)
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
    self.is_full_screen = false
	self.layout_name = "arena/arena_champion_rank_window"
	self.res_list = {
	}

    self.view_type = view_type or ArenaConst.champion_type.normal
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl = ArenaController:getInstance()
    else
        self.ctrl = CrosschampionController:getInstance()
    end
    self.rank_list = {}
end 

function ArenaChampionRankWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
    self.item = main_container:getChildByName("item")
    self.item:setVisible(false)

    local main_panel = main_container:getChildByName("main_panel")
    main_panel:getChildByName("win_title"):setString(TI18N("排行榜"))

    self.close_btn = main_panel:getChildByName("close_btn")
    self.list_view = main_panel:getChildByName("list_view")
    self.my_container = main_panel:getChildByName("my_container")
    self.my_container:getChildByName("my_rank_title"):setString(TI18N("我的排名"))
    self.rank_img = self.my_container:getChildByName("rank_img")        -- sprite
    self.rank_index = self.my_container:getChildByName("rank_id")
    self.role_name = self.my_container:getChildByName("role_name")
    self.power_name = self.my_container:getChildByName("power_name")
    self.power_name:setString(TI18N("战力："))
    self.role_power = self.my_container:getChildByName("role_power")
    local wish_container = self.my_container:getChildByName("wish_container")
    self.my_wish = wish_container:getChildByName("num")

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(157, 65)
    self.role_head:setLev(99)
    self.my_container:addChild(self.role_head)

    self.empty_tips = main_panel:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("暂无任何排名"))
end

function ArenaChampionRankWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			ArenaController:getInstance():openArenaChampionRankWindow(false)
		end
	end)
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			ArenaController:getInstance():openArenaChampionRankWindow(false)
		end
	end)

    if self.update_rank_event == nil then
        self.update_rank_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateChampionRankEvent, function(data) 
            self:updateRankListInfo(data)
        end)
    end

    if self.update_worship_event == nil then
        self.update_worship_event = GlobalEvent:getInstance():Bind(RoleEvent.WorshipOtherRole, function(rid, srv_id, idx)
            if idx ~= nil and self.select_item ~= nil and self.select_item.data ~= nil then
                if idx == self.select_item.data.rank then
                    self.select_item:updateWorshipStatus()
                end
            end
        end)
    end
end

function ArenaChampionRankWindow:openRootWnd()
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl:requestChompionRank()
    else
        self.ctrl:sender26214()
    end
end

--==============================--
--desc:设置我的排行基础信息
--time:2018-08-05 11:42:00
--@rank:
--@worship:
--@return 
--==============================--
function ArenaChampionRankWindow:updateMyInfo(data)
    if data == nil then return end
    local rank = data.rank or 0
    local worship = data.worship or 0

    local my_info = data.rank_list[data.rank]
    local lev = role_vo.lev
    local power = role_vo.power
    local face_id = role_vo.face_id
    local face_file = role_vo.face_file
    local face_update_time = role_vo.face_update_time
    if my_info then
        lev = my_info.lev
        power = my_info.power
        face_id = my_info.face
        face_file = my_info.face_file
        face_update_time = my_info.face_update_time
    end
    if rank <= 3 then
        if self.rank_num ~= nil then
            self.setVisible(false)
        end
        if rank == 0 then
            self.rank_img:setVisible(false)
            self.rank_index:setVisible(false)
        else
            local res_id = PathTool.getResFrame("common", RankConstant.RankIconRes[rank])
            if self.rank_res_id ~= res_id then
                self.rank_res_id  = res_id
                loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
            end
            self.rank_img:setVisible(true)
            self.rank_index:setVisible(false)
        end
    else
        -- if self.rank_num == nil then
        --     self.rank_num = CommonNum.new(17, self.my_container, 1, -2, cc.p(0.5, 0.5))
        --     self.rank_num:setPosition(59,77)
        -- end
        -- self.rank_num:setVisible(true)
        -- self.rank_num:setNum(data.rank)
        self.rank_img:setVisible(false)
        self.rank_index:setString(rank)
        self.rank_index:setVisible(true)
    end

    -- 选拔赛分数
    if not self.my_score_label then
        self.my_score_label = createRichLabel(18, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(520, 34))
        self.my_container:addChild(self.my_score_label)
    end
    local my_score = data.score or 0

    self.my_score_label:setString(string_format("%s<div fontColor=%s>%s</div>", TI18N("选拔赛分数:"), Config.ColorData.data_new_color_str[12], my_score))
    self.role_name:setString(role_vo.name)
    self.role_power:setString(MoneyTool.GetMoneyString(changeBtValueForPower(power)))
    self.my_wish:setString(worship)
    self.role_head:setHeadRes(face_id, false, LOADTEXT_TYPE, face_file, face_update_time)
    self.role_head:setLev(lev)
end

--==============================--
--desc:更新排行榜数据
--time:2018-07-31 05:48:34
--@return 
--==============================--
function ArenaChampionRankWindow:updateRankListInfo(data)
    if data == nil or data.rank_list == nil then return end
    self:updateMyInfo(data)


    if next(data.rank_list) == nil then
        self.empty_tips:setVisible(true)
        if self.scroll_view then
            self.scroll_view:setVisible(false)
        end
    else
        self.empty_tips:setVisible(false)
        if self.scroll_view == nil then
            local size = self.list_view:getContentSize()
            local setting = {
                start_x = 0,
                space_x = 4,
                start_y = 0,
                space_y = 4,
                item_width = 614,
                item_height = 125,
                row = 0,
                col = 1,
                need_dynamic = true
            }
            self.scroll_view = CommonScrollViewSingleLayout.new(self.list_view, nil, nil, nil, size, setting, cc.p(0, 0))

            self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
            self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
            self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        end
        self.scroll_view:setVisible(true)
        self.rank_list = data.rank_list
        self.scroll_view:reloadData()
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenaChampionRankWindow:createNewCell()
    local cell = ArenaChampionRankItem.new()
	if cell.setExtendData and self.item then
		cell:setExtendData(self.item)
    end
    cell:addCallBack(function(item) self:worshipOtherRole(item) end)
    return cell
end

--获取数据数量
function ArenaChampionRankWindow:numberOfCells()
    if not self.rank_list then return 0 end
    return #self.rank_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenaChampionRankWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.rank_list[index]
    if not data then return end
    cell:setData(data)
end

function ArenaChampionRankWindow:worshipOtherRole(item)
    if item.data ~= nil then
        self.select_item = item
        if self.view_type == ArenaConst.champion_type.normal then
            RoleController:getInstance():requestWorshipRole(item.data.rid, item.data.srv_id, item.data.rank)
        else
            RoleController:getInstance():requestWorshipRole(item.data.rid, item.data.srv_id, item.data.rank, WorshipType.crosschampion)
        end
    end
end

function ArenaChampionRankWindow:close_callback()
    if self.role_head then
        self.role_head:DeleteMe()
        self.role_head = nil
    end
    if self.rank_num then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    if self.update_rank_event then
        GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
    end
    if self.update_worship_event then
        GlobalEvent:getInstance():UnBind(self.update_worship_event)
        self.update_worship_event = nil
    end
	ArenaController:getInstance():openArenaChampionRankWindow(false)
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军联赛的排行单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionRankItem = class("ArenaChampionRankItem", function()
	return ccui.Layout:create()
end)

function ArenaChampionRankItem:ctor()
    self.is_completed = false
end

--==============================--
--desc:设置扩展参数  {node = self.item, count = self.interaction_count} 
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function ArenaChampionRankItem:setExtendData(node)	
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
		
        self.rank_img = self.root_wnd:getChildByName("rank_img")
        self.rank_index = self.root_wnd:getChildByName("rank_id")
        self.wish_container = self.root_wnd:getChildByName("wish_container")
        self.wish_num = self.wish_container:getChildByName("num")
        self.wish_num:setString("")
        self.role_name = self.root_wnd:getChildByName("role_name")
        self.power_name = self.root_wnd:getChildByName("power_name")
        self.power_name:setString(TI18N("战力："))
        self.role_power = self.root_wnd:getChildByName("role_power")
        -- self.power_bg = self.root_wnd:getChildByName("Image_1")
        self.rank_img:ignoreContentAdaptWithSize(true)

        self.role_head = PlayerHead.new(PlayerHead.type.circle)
        self.role_head:setHeadLayerScale(0.95)
        self.role_head:setPosition(157, 65)
        self.root_wnd:addChild(self.role_head)
        self.role_head:setLev(99)

        self.score_label = createRichLabel(18, Config.ColorData.data_new_color4[6], cc.p(1, 0.5), cc.p(588, 34))
        self.root_wnd:addChild(self.score_label)

		self:registerEvent()
	end
end

function ArenaChampionRankItem:registerEvent()
    self.role_head:addCallBack( function()
        if self.data ~= nil and self.data.srv_id ~= "" then
            if self.data.srv_id == "robot" then
                message(TI18N("神秘人太高冷，不给查看"))
            else
                FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
            end
        end
    end,false)

    self.wish_container:addTouchEventListener(function(sender, event_type)
        customClickAction(sender,event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data ~= nil then
                if self.call_back ~= nil then
                    self.call_back(self)
                end
            end
        end
    end)
end

function ArenaChampionRankItem:addCallBack(callback)
	self.call_back = callback
end

function ArenaChampionRankItem:setData(data)
	if data then
        self.data = data
        self.role_name:setString(transformNameByServ(data.name, data.srv_id))
        self.role_power:setString(changeBtValueForPower(data.power))
        local width = self.role_power:getContentSize().width + 75
        -- local height = self.power_bg:getContentSize().height
        -- self.power_bg:setContentSize(cc.size(width,height))
        self.role_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.role_head:setLev(data.lev)
        self.wish_num:setString(data.worship)

        if data.worship_status == TRUE or role_vo:isSameRole(data.srv_id, data.rid) then
            self.wish_container:setTouchEnabled(false)
            setChildUnEnabled(true, self.wish_container, Config.ColorData.data_color4[1])
            self.wish_num:enableOutline(Config.ColorData.data_color4[2], 2)
        else
            self.wish_container:setTouchEnabled(true)
            setChildUnEnabled(false, self.wish_container, Config.ColorData.data_color4[175])
            self.wish_num:enableOutline(Config.ColorData.data_new_color4[9], 2)
        end

        if data.rank <= 3 then
            if self.rank_num ~= nil then
                self.rank_num:setVisible(false)
            end
            if data.rank == 0 then
                self.rank_img:setVisible(false)
                self.rank_index:setVisible(false)
            else
                local res_id = PathTool.getResFrame("common", RankConstant.RankIconRes[data.rank])
                if self.rank_res_id ~= res_id then
                    self.rank_res_id = res_id
                    self.rank_img:loadTexture(res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
                self.rank_index:setVisible(false)
            end
        else
            -- if self.rank_num == nil then
            --     self.rank_num = CommonNum.new(17, self.root_wnd, 1, -2, cc.p(0.5, 0.5))
            --     self.rank_num:setPosition(59, 77)
            -- end
            -- self.rank_num:setVisible(true)
            -- self.rank_num:setNum(data.rank)
            self.rank_img:setVisible(false)
            self.rank_index:setString(data.rank)
            self.rank_index:setVisible(true)
        end
        local desc = string_format("%s<div fontColor=%s>%s</div>", TI18N("选拔赛分数:"), Config.ColorData.data_new_color_str[12], data.score)
        self.score_label:setString(desc)
	end
end

function ArenaChampionRankItem:updateWorshipStatus()
	if self.data ~= nil then
		self.data.worship = self.data.worship + 1
		self.data.worship_status = TRUE
		self.wish_num:setString(self.data.worship)
		self.wish_container:setTouchEnabled(false)
		setChildUnEnabled(true, self.wish_container, Config.ColorData.data_color4[1])
        self.wish_num:enableOutline(Config.ColorData.data_color4[2], 2)
	end
end 

function ArenaChampionRankItem:DeleteMe()
    if self.role_head then
        self.role_head:DeleteMe()
        self.role_head = nil
    end
    if self.rank_num then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end 