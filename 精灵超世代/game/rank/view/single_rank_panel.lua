--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019-03-07 11:40:29
-- @description    : 
        -- 排行榜面板
---------------------------------

SingleRankPanel = class("SingleRankPanel",function()
    return ccui.Layout:create()
end)

-- local _controller = RankController:getInstance()
-- local _model = _controller:getModel()
local table_sort = table.sort
local string_format = string.format


function SingleRankPanel:ctor()
    self.is_init = true
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_rank_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.scroll_container = self.root_wnd:getChildByName("scroll_container")
    self.empty_bg = self.scroll_container:getChildByName("empty_bg")
    self.empty_bg:setVisible(false)
    self.empty_bg:setScale(0.9)
    loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), LOADTEXT_TYPE)
    self.desc_label = self.empty_bg:getChildByName("desc_label")
    self.desc_label:setPosition(self.empty_bg:getContentSize().width / 2, -29)
    self.desc_label:setString(TI18N("暂无记录"))

    local scroll_size = self.scroll_container:getContentSize()
    local size = cc.size(scroll_size.width, scroll_size.height-10)
    local setting = {
        item_class = SingleRankItem,
        start_x = 4,
        space_x = 4,
        start_y = 0,
        space_y = 0,
        item_width = 614,
        item_height = 125,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.scroll_container, nil, nil, nil, size, setting)

    local my_container = self.root_wnd:getChildByName("my_container")
    local my_rank_title = my_container:getChildByName("my_rank_title")

    self.rank_img = my_container:getChildByName("rank_img")
    self.rank_img:setVisible(false)
    self.rank_x = self.rank_img:getPositionX()
    self.rank_y = self.rank_img:getPositionY()

    self.role_name = my_container:getChildByName("role_name")
    self.role_power = my_container:getChildByName("role_power")
    self.no_rank = my_container:getChildByName("no_rank")
    self.no_rank:setString(TI18N("未上榜"))
    self.no_rank:setVisible(false)
    self.power_bg = my_container:getChildByName("Image_1")
    
    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    self.role_head:setLev(99)
    my_container:addChild(self.role_head)

    self.my_container = my_container

    self:registerEvent()
end

function SingleRankPanel:registerEvent()
    if self.update_rank_event == nil then
        self.update_rank_event = GlobalEvent:getInstance():Bind(RankEvent.RankEvent_Get_Rank_data, function(data)
            if not data then return end
            if data.type == self.rank_type then
                self:updateRankList(data)
            end
        end)
    end
    --
    if self.guildsecretarea_update_rank_event == nil then
        self.guildsecretarea_update_rank_event = GlobalEvent:getInstance():Bind(GuildsecretareaEvent.GUILD_SECRET_AREA_RANK_COUNT_EVENT, function(data)
            if not data then return end
            if self.rank_type == RankConstant.RankType.guild_secretarea then
                self:updateRankList(data)
            end
        end)
    end
    --巅峰冠军赛
    if self.arenapeakchampion_current_rank_event == nil then
        self.arenapeakchampion_current_rank_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_CURRENT_RANK_EVENT, function(data)
            if not data then return end
            if self.rank_type == RankConstant.RankType.arena_peak_champion then
                self:updateRankList(data)
            end
        end)
    end

    --年兽排行榜
    if self.year_rank_info_event == nil then
        self.year_rank_info_event = GlobalEvent:getInstance():Bind(ActionyearmonsterEvent.Year_Rank_Info_Event, function(data)
            if not data then return end
            if self.rank_type == RankConstant.RankType.year_monster then
                self:updateRankList(data)
            end
        end)
    end

    -- 点赞事件监听，
    if self.role_worship_event == nil then
        self.role_worship_event = GlobalEvent:getInstance():Bind(RoleEvent.WorshipOtherRole, function(rid, srv_id, rank, _type) 
            if not self.rank_type then return end
            self:updateWorshipInfo(rid, srv_id, rank, _type)
        end)
    end
end

function SingleRankPanel:updateWorshipInfo(rid, srv_id, rank, _type)
    if self.rank_type == RankConstant.RankType.arena_peak_champion then --巅峰竞技场
        if self.scroll_view then
            local is_change = false
            local list = self.scroll_view:getItemList()
            if not list then return end
            for k,v in pairs(list) do
                local data = v:getData()
                if data and data.rid == rid and data.srv_id == srv_id then
                    data.worship_status = 1
                    is_change = true
                    v:updateOneBtnInfo()
                    break
                end
            end
            if not is_change then
                local data_list = self.scroll_view.data_list
                for i,data in ipairs(data_list) do
                    if data.rid == rid and data.srv_id == srv_id then
                        data.worship_status = 1
                        break
                    end
                end
            end
        end
        self.day_worship = self.day_worship + 1
        ArenapeakchampionController:getInstance():getModel():setWorshipRedPoint(self.day_worship)
    end
end

function SingleRankPanel:setNodeVisible(status)
    self:setVisible(status)
end

function SingleRankPanel:addToParent(setting)
    -- 窗体打开只请求一次，不是标签显示
    local setting = setting or {}
    self.rank_type = setting.rank_type or RankConstant.RankType.element
    if self.is_init == true then
        if self.rank_type == RankConstant.RankType.guild_secretarea then -- 公会秘境
            local boss_id = setting.boss_id 
            if boss_id then
                GuildsecretareaController:getInstance():sender26806(boss_id, 1)
            end
        elseif self.rank_type == RankConstant.RankType.arena_peak_champion then --巅峰竞技场
            local zone_id = setting.zone_id 
            if zone_id then
                ArenapeakchampionController:getInstance():sender27714(zone_id, 1, 256)
            end 
        elseif self.rank_type == RankConstant.RankType.year_monster then --年兽
            if setting.type then
                ActionyearmonsterController:getInstance():sender28213(setting.type, 1)
            end
        elseif self.rank_type == RankConstant.RankType.sweet then -- 甜蜜大作战(特殊处理，只显示25个)
            RankController:send_12900(self.rank_type, 1, 25)
        else
            --通用的
            RankController:send_12900(self.rank_type)
        end

        self.is_init = false
    end
end

function SingleRankPanel:updateRankList(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self:updateOtherInfo(data, role_vo)

        local power = data.power or 0
        if power == 0 then
            power = role_vo.power
        end
        self.role_name:setString(role_vo.name)
        self.role_power:setString(power)
        local width = self.role_power:getContentSize().width + 75
        local height = self.power_bg:getContentSize().height
        self.power_bg:setContentSize(cc.size(width,height))

        if data.my_idx and data.my_idx <= 3 then
            -- if self.rank_num ~= nil then
            --     self.rank_num:setVisible(false)
            -- end
            if data.my_idx == 0 then
                self.rank_img:setVisible(false)
                self.no_rank:setVisible(true)
            else
                self.no_rank:setVisible(false)
                -- local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.my_idx))
                local res_id = PathTool.getResFrame("common", RankConstant.RankIconRes[data.my_idx])
                if self.rank_res_id ~= res_id then
                    self.rank_res_id  = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            -- if self.rank_num == nil then
            --     self.rank_num = CommonNum.new(1, self.my_container, 1, -2, cc.p(0.5, 0.5))
            --     self.rank_num:setPosition(59,77)
            -- end
            -- self.rank_num:setVisible(true)
            -- self.rank_num:setNum(data.my_idx)
            self.rank_label:setVisible(true)
            self.rank_label:setString(string.format("%s", data.my_idx))
            self.rank_img:setVisible(false)
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

        if data.rank_list ~= nil and next(data.rank_list) ~= nil then
            self.rank_list = data.rank_list
            self.scroll_view:setData(data.rank_list, nil,nil, {rank_type = self.rank_type})
            self.empty_bg:setVisible(false)
        else
            self.empty_bg:setVisible(true)
        end
    end
end

function SingleRankPanel:updateOtherInfo(data, role_vo)
    if self.rank_type == RankConstant.RankType.sandybeach_boss_fight or self.rank_type == RankConstant.RankType.sweet then
        local msg = string.format(TI18N("<div>%s</div><div fontcolor=#249003 fontsize=22>%s</div>"),TI18N("当前积分:"),data.my_val1 or 0)
        if self.my_score_info == nil then
            self.my_score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(520, 65), nil, nil, 300)
            self.my_container:addChild(self.my_score_info)    
        end
        self.my_score_info:setString(msg)
    elseif self.rank_type == RankConstant.RankType.guild_secretarea then --公会秘境
        local dps = 0
        table_sort(data.dps_list, SortTools.KeyLowerSorter("rank"))
        data.my_idx = 0
        for i,v in ipairs(data.dps_list) do
            if role_vo and role_vo.rid == v.rid and role_vo.srv_id == v.srv_id then
                data.my_idx = v.rank
                dps = v.dps
                break
            end
        end
        data.rank_list = data.dps_list
        dps = changeBtValueForBattle(dps)
        if self.my_score_info == nil then
            self.my_score_info = createLabel(22, cc.c4b(0x24,0x90,0x03,0xff), nil, 520, 65, dps, self.my_container, nil, cc.p(0.5,0.5))
        else
            self.my_score_info:setString(dps)
        end
    elseif self.rank_type == RankConstant.RankType.year_monster then --年兽
        local dps = 0
        table_sort(data.dps_list, SortTools.KeyLowerSorter("rank"))
        data.my_idx = 0
        for i,v in ipairs(data.dps_list) do
            if role_vo and role_vo.rid == v.rid and role_vo.srv_id == v.srv_id then
                data.my_idx = v.rank
                dps = v.dps
                break
            end
        end
        data.rank_list = data.dps_list
        dps = changeBtValueForBattle(dps)

        if self.my_score_info == nil then
            self.my_score_info = createLabel(22, cc.c4b(0x24,0x90,0x03,0xff), nil, 520, 65, dps, self.my_container, nil, cc.p(0.5,0.5))
        else
            self.my_score_info:setString(dps)
        end
    elseif self.rank_type == RankConstant.RankType.arena_peak_champion then --巅峰冠军赛
        local count = data.worship or 0
        local score = data.score or 0
        data.my_idx = data.rank
        self.day_worship = data.day_worship
        if self.good_btn == nil then
            local res = PathTool.getResFrame("common","common_1027")
            self.good_btn = createImage(self.my_container, res, 520, 74, cc.p(0.5,0.5), true, 1, true)
            self.good_btn:setScale(0.8)
            -- self.good_btn:setContentSize(cc.size(156, 54))
            -- self.good_btn:setTouchEnabled(true)
            local res = PathTool.getResFrame("common","common_1045")
            local img = createImage(self.my_container, res, 480, 74, cc.p(0.5,0.5), true, 1, false)
            self.my_worship_info = createLabel(22, cc.c4b(0x68,0x45,0x2A,0xff), nil, 60, 14, count, img, nil, cc.p(0.5,0.5))
            -- createImage(self.good_btn, res, 32, 28, cc.p(0.5,0.5), true, 1, false)
            -- self.my_worship_info = createLabel(22, cc.c4b(0x68,0x45,0x2A,0xff), nil, 90, 28, count, self.good_btn, nil, cc.p(0.5,0.5))
            -- registerButtonEventListener(self.good_btn, handler(self, self.onClickBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
            self.my_worship_info:setString(count)
        else
            if self.my_worship_info then
                self.my_worship_info:setString(count)
            end
        end

        if self.my_score_info == nil then
            self.my_score_info = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(520, 34), nil, nil, 300)
            self.my_container:addChild(self.my_score_info)
            -- self.my_score_info = createLabel(22, cc.c4b(0x24,0x90,0x03,0xff), nil, 520, 65, dps, self.my_container, nil, cc.p(0.5,0.5))
        end
        self.my_score_info:setString(string_format(TI18N("选拔赛分数:<div fontcolor=#249003>%s</div>"), score) )
    else
        --其他类型
    end
end

function SingleRankPanel:onClickBtn()
    if self.rank_type == RankConstant.RankType.arena_peak_champion then --巅峰冠军赛
        
    else

    end
    -- body
end

function SingleRankPanel:DeleteMe()
    if self.update_rank_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
    end

    if self.guildsecretarea_update_rank_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.guildsecretarea_update_rank_event)
        self.guildsecretarea_update_rank_event = nil
    end
    if self.arenapeakchampion_current_rank_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.arenapeakchampion_current_rank_event)
        self.arenapeakchampion_current_rank_event = nil
    end
    if self.year_rank_info_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.year_rank_info_event)
        self.year_rank_info_event = nil
    end
    if self.role_worship_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.role_worship_event)
        self.role_worship_event = nil
    end

    -- if self.rank_num then
    --     self.rank_num:DeleteMe()
    --     self.rank_num = nil
    -- end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end

------------------------------@ item
SingleRankItem = class("SingleRankItem",function()
    return ccui.Layout:create()
end)

function SingleRankItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_rank_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.rank_label = container:getChildByName("rank_label")
    self.rank_img = container:getChildByName("rank_img")
    self.role_name = container:getChildByName("role_name")
    self.role_power = container:getChildByName("role_power")

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    container:addChild(self.role_head)
    self.role_head:setLev(99)

    self.container = container

    self:registerEvent()
end

function SingleRankItem:registerEvent()
    self.role_head:addCallBack( function()
        if self.data ~= nil then
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
        end
    end,false)
end

function SingleRankItem:addCallBack(call_back)
    self.call_back = call_back
end
function SingleRankItem:setExtendData(data)
    local data = data or {}
    self.rank_type = data.rank_type or RankConstant.RankType.element
end

function SingleRankItem:setData(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.data = data
        self:updateOtherInfo(data)

        self.role_name:setString(data.name)
        self.role_power:setString(data.val3)
        self.role_head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.role_head:setLev(data.lev)
        local avatar_bid = data.avatar_id 
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        end

        if data.idx <= 3 then
            -- if self.rank_num ~= nil then
            --     self.rank_num:setVisible(false)
            -- end
            if data.idx == 0 then
                self.rank_img:setVisible(false)
            else
                -- local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.idx))
                local res_id = PathTool.getResFrame("common", RankConstant.RankIconRes[data.idx])
                if self.rank_res_id ~= res_id then
                    self.rank_res_id = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            -- if self.rank_num == nil then
            --     self.rank_num = CommonNum.new(1, self.container, 1, -2, cc.p(0.5, 0.5))
            --     self.rank_num:setPosition(59, 77)
            -- end
            -- self.rank_num:setVisible(true)
            -- self.rank_num:setNum(data.idx)
            self.rank_label:setVisible(true)
            self.rank_label:setString(string.format("%s", data.idx))
            self.rank_img:setVisible(false)
        end
    end
end
function SingleRankItem:getData()
    return self.data
end

function SingleRankItem:updateOtherInfo(data)
    if self.rank_type == RankConstant.RankType.sandybeach_boss_fight or self.rank_type == RankConstant.RankType.sweet then
        local msg = string.format(TI18N("<div>%s</div><div fontcolor=#249003 fontsize=22>%s</div>"), TI18N("当前积分:"), data.val1 or 0)
        if self.score_info == nil then
            self.score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(520, 60), nil, nil, 300)
            self.container:addChild(self.score_info)
        end
        self.score_info:setString(msg)
    elseif self.rank_type == RankConstant.RankType.guild_secretarea then -- 公会秘境
        if self.score_info == nil then
            self.score_info = createLabel(22, cc.c4b(0x24,0x90,0x03,0xff), nil, 520, 60, data.dps, self.container, nil, cc.p(0.5,0.5))
        else
            self.score_info:setString(data.dps)
        end
        data.val3 = data.power
        data.idx = data.rank
    elseif self.rank_type == RankConstant.RankType.year_monster then -- 公会秘境
        if self.score_info == nil then
            self.score_info = createLabel(22, cc.c4b(0x24,0x90,0x03,0xff), nil, 520, 60, data.dps, self.container, nil, cc.p(0.5,0.5))
        else
            self.score_info:setString(data.dps)
        end
        data.val3 = data.power
        data.idx = data.rank
    elseif self.rank_type == RankConstant.RankType.arena_peak_champion then --巅峰冠军赛
        local count = data.worship or 0
        local score = data.score or 0
        data.val3 = data.power
        data.idx = data.rank
        if self.good_btn == nil then
            local res = PathTool.getResFrame("common","common_1027")
            self.good_btn = createImage(self.container, res, 520, 74, cc.p(0.5,0.5), true, 1, true)
            self.good_btn:setScale(0.8)
            -- self.good_btn:setContentSize(cc.size(156, 54))
            self.good_btn:setTouchEnabled(true)
            local res = PathTool.getResFrame("common","common_1045")
            local img = createImage(self.container, res, 480, 74, cc.p(0.5,0.5), true, 1, false)
            self.my_worship_info = createLabel(22, cc.c4b(0x68,0x45,0x2A,0xff), nil, 60, 14, count, img, nil, cc.p(0.5,0.5))
            -- createImage(self.good_btn, res, 32, 28, cc.p(0.5,0.5), true, 1, false)
            -- self.my_worship_info = createLabel(22, cc.c4b(0x68,0x45,0x2A,0xff), nil, 90, 28, count, self.good_btn, nil, cc.p(0.5,0.5))
            registerButtonEventListener(self.good_btn, handler(self, self.onClickOneBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil, 0.8)
            self.my_worship_info:setString(count)
        else
            if self.my_worship_info then
                self.my_worship_info:setString(count)
            end
        end

        if self.my_score_info == nil then
            self.my_score_info = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(520, 34), nil, nil, 300)
            self.container:addChild(self.my_score_info)
        end
        self.my_score_info:setString(string_format(TI18N("选拔赛分数:<div fontcolor=#249003>%s</div>"), score) )
        self:updateOneBtnInfo()
    else
        --其他类型
    end
end

function SingleRankItem:updateOneBtnInfo()
    if not self.data then return end
    if self.rank_type == RankConstant.RankType.arena_peak_champion then --巅峰冠军赛
        if self.data.worship_status == 0 then --可模板
            setChildUnEnabled(false, self.good_btn)
            self.good_btn:setTouchEnabled(true)
        else
            setChildUnEnabled(true, self.good_btn)
            self.good_btn:setTouchEnabled(false)
        end
    else

    end
end

function SingleRankItem:onClickOneBtn()
    if not self.data then return end
    if self.rank_type == RankConstant.RankType.arena_peak_champion then --巅峰冠军赛
        RoleController:getInstance():requestWorshipRole(self.data.rid, self.data.srv_id, self.data.rank, WorshipType.peakchampion)
    else

    end
    -- body
end


function SingleRankItem:DeleteMe()
    -- if self.rank_num ~= nil then
    --     self.rank_num:DeleteMe()
    --     self.rank_num = nil
    -- end
    self:removeAllChildren()
    self:removeFromParent()
end