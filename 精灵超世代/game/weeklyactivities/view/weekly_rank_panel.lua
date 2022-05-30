--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-07 11:40:29
-- @description    : 
		-- 圣殿排行榜
---------------------------------

WeeklyRankPanel = class("WeeklyRankPanel",function()
    return ccui.Layout:create()
end)

local _controller = WeeklyActivitiesController:getInstance()
local _model = _controller:getModel()

function WeeklyRankPanel:ctor()
    self.is_init = true
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/hippocrene_rank_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.scroll_container = self.root_wnd:getChildByName("scroll_container")
    self.empty_bg = self.scroll_container:getChildByName("empty_bg")
    self.empty_bg:setVisible(false)
    loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), LOADTEXT_TYPE)
    self.desc_label = self.empty_bg:getChildByName("desc_label")
    self.desc_label:setPositionX(self.empty_bg:getContentSize().width / 2)
    self.desc_label:setString(TI18N("暂无记录"))

    local scroll_size = self.scroll_container:getContentSize()
    local size = cc.size(scroll_size.width, scroll_size.height-10)
    local setting = {
        item_class = WeeklyRankItem,
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

    self.percentage_text = my_container:getChildByName("percentage_text")

    self.my_score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(520, 65), nil, nil, 300)
    my_container:addChild(self.my_score_info)
 
    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    self.role_head:setLev(99)
    my_container:addChild(self.role_head)

    self.my_container = my_container
    self.title_node = self.my_container:getChildByName("title_node")

    self.activity_id =  _model:getWeeklyActivityId() or 1 
    local title_name_str = { TI18N("探索次数"), TI18N("培育次数"),TI18N("石室次数")}
    self.title_node:getChildByName("sterilization_num"):setString(title_name_str[self.activity_id])

    self:registerEvent()
end

function WeeklyRankPanel:registerEvent()
    if self.update_rank_event == nil then
        self.update_rank_event = GlobalEvent:getInstance():Bind(RankEvent.RankEvent_Get_Rank_data, function(data) 
            if data.type == RankConstant.RankType.cultivate_activity or 
                data.type == RankConstant.RankType.underground_palace or
                data.type == RankConstant.RankType.stone_chamber 
             then
                --dump(data, "---------------------排行榜数据")
                self:updateRankList(data)
            end
        end)
    end
end

function WeeklyRankPanel:setNodeVisible(status)
    self:setVisible(status)
end

function WeeklyRankPanel:addToParent()
    -- 窗体打开只请求一次，不是标签显示
    if self.is_init == true then
        local  tabs = {
                        RankConstant.RankType.underground_palace,
                        RankConstant.RankType.cultivate_activity,
                        RankConstant.RankType.stone_chamber
                    }
        local activice_id = _model:getWeeklyActivityId()
        print("tabs[activice_id]--->")
        RankController:send_12900(tabs[activice_id])
        self.is_init = false
    end
end

function WeeklyRankPanel:updateRankList(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.role_name:setString(role_vo.name)
        self.role_power:setString(changeBtValueForPower(role_vo.power))

        if data.my_idx and data.my_idx <= 3 then
            if self.rank_num ~= nil then
                self.setVisible(false)
            end
            if data.my_idx == 0 then
                self.rank_img:setVisible(false)
                self.no_rank:setVisible(true)
            else
                self.no_rank:setVisible(false)
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.my_idx))
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
            self.rank_num:setNum(data.my_idx)
            self.rank_img:setVisible(false)
        end

        --local msg = string.format(
        --    TI18N("<div>%s</div><div fontcolor=#249003 fontsize=22>%s</div>"),
        --    TI18N("最大通关数:"),
        --    data.my_val1 or 0
        --)
        self.percentage_text:setString(data.my_val1 or 0) 
         
        self.my_score_info:setString(msg)
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
            self.scroll_view:setData(data.rank_list)
            self.empty_bg:setVisible(false)
        else
            self.empty_bg:setVisible(true)
        end
    end
end

function WeeklyRankPanel:DeleteMe()
    if  self.update_rank_event then
        self.update_rank_event = GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
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

------------------------------@ item
WeeklyRankItem = class("WeeklyRankItem", function()
    return ccui.Layout:create()
end)

function WeeklyRankItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/hippocrene_rank_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.rank_img = container:getChildByName("rank_img")
    self.role_name = container:getChildByName("role_name")
    self.role_power = container:getChildByName("role_power")
    self.role_power = container:getChildByName("role_power")
    self.mun_cont   = container:getChildByName("mun_cont")

    self.score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(520, 60), nil, nil, 300)
    container:addChild(self.score_info)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    container:addChild(self.role_head)
    self.role_head:setLev(99)

    self.container = container

    self:registerEvent()
end

function WeeklyRankItem:registerEvent()
    self.role_head:addCallBack( function()
        if self.data ~= nil then
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
        end
    end,false)
end

function WeeklyRankItem:addCallBack(call_back)
    self.call_back = call_back
end
function WeeklyRankItem:setData(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.data = data
        self.role_name:setString(data.name)
        self.role_power:setString(changeBtValueForPower(data.val2))
        self.role_head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.role_head:setLev(data.lev)


        local avatar_bid = data.avatar_id 
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        self.mun_cont:setString(data.val1 or 0) 

        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        end
--
        if data.idx <= 3 then
            if self.rank_num ~= nil then
                self.rank_num:setVisible(false)
            end
            if data.idx == 0 then
                self.rank_img:setVisible(false)
            else
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.idx))
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
            self.rank_num:setNum(data.idx)
            self.rank_img:setVisible(false)
        end
    end
end

function WeeklyRankItem:DeleteMe()
    if self.rank_num ~= nil then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end