-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      循环赛的排行榜
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopRankPanel = class("ArenaLoopRankPanel",function()
    return ccui.Layout:create()
end)

local controller = ArenaController:getInstance()
local model = ArenaController:getInstance():getModel() 

function ArenaLoopRankPanel:ctor()
    self.is_init = true
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_loop_rank_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.scroll_container = self.root_wnd:getChildByName("scroll_container")
    local size = self.scroll_container:getContentSize()
    local setting = {
        item_class = ArenaLoopRankItem,
        start_x = 4,
        space_x = 4,
        start_y = 0,
        space_y = 4,
        item_width = 614,
        item_height = 125,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.scroll_container, cc.p(0, 10), nil, nil, cc.size(size.width, size.height-20), setting)

    local my_container = self.root_wnd:getChildByName("my_container")
    local my_rank_title = my_container:getChildByName("my_rank_title")

    self.rank_img = my_container:getChildByName("rank_img")
    self.rank_img:setVisible(false)
    self.rank_x = self.rank_img:getPositionX()
    self.rank_y = self.rank_img:getPositionY()

    local wish_container = my_container:getChildByName("wish_container")
    self.wish_num = wish_container:getChildByName("num")

    self.role_name = my_container:getChildByName("role_name")
    self.role_power = my_container:getChildByName("role_power")
    self.power_bg = my_container:getChildByName("Image_1")

    self.my_score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(520, 38), nil, nil, 300)
    my_container:addChild(self.my_score_info)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    self.role_head:setLev(99)
    my_container:addChild(self.role_head)

    self.my_container = my_container

    self:registerEvent()
end

function ArenaLoopRankPanel:registerEvent()
    if self.update_rank_event == nil then
        self.update_rank_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateLoopChallengeRank, function(data) 
            self:updateRankList(data)
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
    if self.arena_fight_result_evetn == nil then
        self.arena_fight_result_evetn = GlobalEvent:getInstance():Bind(ArenaEvent.ArenaFightResultEvent, function()
            self.is_init = true
        end)
    end
end

function ArenaLoopRankPanel:setNodeVisible(status)
    self:setVisible(status)
    if status then
        self:addToParent()
    end
end

function ArenaLoopRankPanel:addToParent()
    -- 窗体打开只请求一次，不是标签显示
    if self.is_init == true then
        ArenaController:getInstance():requestLoopChalllengeRank()
        self.is_init = false
    end
end

--[[
    @desc:更新自己的信息，还是走这里把
    author:{author}
    time:2018-05-17 10:17:08
    --@is_event: 
    return
]]
function ArenaLoopRankPanel:updatePanelInfo(is_event)

end

function ArenaLoopRankPanel:updateRankList(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.role_name:setString(role_vo.name)
        self.role_power:setString(role_vo.power)
        local width = self.role_power:getContentSize().width + 75
        local height = self.power_bg:getContentSize().height
        self.power_bg:setContentSize(cc.size(width,height))
        self.wish_num:setString(data.worship)

        if data.rank and data.rank <= 3 then
            if self.rank_num ~= nil then
                self.rank_num:setVisible(false)
            end
            if data.rank == 0 then
                self.rank_img:setVisible(false)
            else
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.rank))
                if self.rank_res_id ~= res_id then
                    self.rank_res_id  = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            if self.rank_num == nil then
                self.rank_num = CommonNum.new(1, self.my_container, 1, -2, cc.p(0.5, 0.5))
                self.rank_num:setPosition(59,77)
            end
            self.rank_num:setVisible(true)
            self.rank_num:setNum(data.rank)
            self.rank_img:setVisible(false)
        end

        local config = model:getZoneConfig()
        if config ~= nil then
            local msg = string.format(TI18N("段位积分:<div fontcolor=#249003 fontsize=22>%s</div>"),data.score or 0)
            self.my_score_info:setString(msg)
        end
        self.role_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
        self.role_head:setLev(role_vo.lev)
        local avatar_bid = role_vo.avatar_base_id
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        end

        -- 创建排行榜。。。。。这里做点击回到用于记录更新点赞数量
        local function click_callback(item)
            self:worshipOtherRole(item)
        end
        if data.rank_list ~= nil and next(data.rank_list) ~= nil then
            self.scroll_view:setData(data.rank_list, click_callback)
        end
    end
end

--[[
    @desc: 主要用于点击点赞按钮，在这做记录等返回成功之后做按钮的更新处理
    author:{author}
    time:2018-05-28 23:42:51
    --@item: 
    return
]]
function ArenaLoopRankPanel:worshipOtherRole(item)
    if item.data ~= nil then
        self.select_item = item
        RoleController:getInstance():requestWorshipRole(item.data.rid, item.data.srv_id, item.data.rank)
    end
end

function ArenaLoopRankPanel:DeleteMe()
    if self.update_rank_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
    end
    if self.update_worship_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_worship_event)
        self.update_worship_event = nil
    end
    if self.arena_fight_result_evetn ~= nil then
        GlobalEvent:getInstance():UnBind(self.arena_fight_result_evetn)
        self.arena_fight_result_evetn = nil
    end

    if self.rank_num then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      循环赛排行榜单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopRankItem = class("ArenaLoopRankItem",function()
    return ccui.Layout:create()
end)

function ArenaLoopRankItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arean_loop_rank_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.rank_img = container:getChildByName("rank_img")
    self.wish_container = container:getChildByName("wish_container")
    self.wish_num = self.wish_container:getChildByName("num")
    self.wish_num:setString("")
    self.role_name = container:getChildByName("role_name")
    self.role_power = container:getChildByName("role_power")
    self.power_bg = container:getChildByName("Image_1")
    self.score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(520, 38), nil, nil, 300)
    container:addChild(self.score_info)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    container:addChild(self.role_head)
    self.role_head:setLev(99)

    self.container = container

    self:registerEvent()
end

function ArenaLoopRankItem:registerEvent()
    self.role_head:addCallBack( function()
        if self.data ~= nil then
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
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

function ArenaLoopRankItem:addCallBack(call_back)
    self.call_back = call_back
end

function ArenaLoopRankItem:updateWorshipStatus()
    if self.data ~= nil then
        self.data.worship = self.data.worship + 1
        self.data.worship_status = TRUE
        self.wish_num:setString(self.data.worship)
        self.wish_num:enableOutline(Config.ColorData.data_color4[2], 2)
        self.wish_container:setTouchEnabled(false)
        setChildUnEnabled(true, self.wish_container, Config.ColorData.data_color4[1])
    end
end

function ArenaLoopRankItem:setData(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.data = data
        self.role_name:setString(data.name)
        self.role_power:setString(data.power)
        local width = self.role_power:getContentSize().width + 75
        local height = self.power_bg:getContentSize().height
        self.power_bg:setContentSize(cc.size(width,height))
        self.role_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.role_head:setLev(data.lev)
        self.wish_num:setString(data.worship)
        local avatar_bid = data.avatar_id 
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        end

        if data.worship_status == TRUE or role_vo:isSameRole(data.srv_id, data.rid) then
            self.wish_container:setTouchEnabled(false)
            self.wish_num:enableOutline(Config.ColorData.data_color4[2], 2)
            setChildUnEnabled(true, self.wish_container, Config.ColorData.data_color4[1])
        else
            self.wish_container:setTouchEnabled(true)
            self.wish_num:enableOutline(Config.ColorData.data_color4[277], 2)
            setChildUnEnabled(false, self.wish_container, Config.ColorData.data_color4[175])
        end

        if data.rank <= 3 then
            if self.rank_num ~= nil then
                self.rank_num:setVisible(false)
            end
            if data.rank == 0 then
                self.rank_img:setVisible(false)
            else
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.rank))
                if self.rank_res_id ~= res_id then
                    self.rank_res_id = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            if self.rank_num == nil then
                self.rank_num = CommonNum.new(1, self.container, 1, -2, cc.p(0.5, 0.5))
                self.rank_num:setPosition(59, 77)
            end
            self.rank_num:setVisible(true)
            self.rank_num:setNum(data.rank)
            self.rank_img:setVisible(false)
        end

        local model = ArenaController:getInstance():getModel()
        local config = model:getZoneConfig(data.score)
        if config ~= nil then
            local msg = string.format(TI18N("段位积分:<div fontcolor=#249003 fontsize=22>%s</div>"),data.score or 0)
            self.score_info:setString(msg)
        end 
    end
end

function ArenaLoopRankItem:DeleteMe()
    if self.rank_num ~= nil then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
