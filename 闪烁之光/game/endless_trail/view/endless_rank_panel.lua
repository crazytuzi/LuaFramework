-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      无尽试炼排行榜数据
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessRankPanel = class("EndlessRankPanel",function()
    return ccui.Layout:create()
end)

local controller = Endless_trailController:getInstance()
local model = Endless_trailController:getInstance():getModel() 

function EndlessRankPanel:ctor(type)
    self.type = type or Endless_trailEvent.endless_type.old
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
    loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), LOADTEXT_TYPE)
    self.desc_label = self.empty_bg:getChildByName("desc_label")
    self.desc_label:setPositionX(self.empty_bg:getContentSize().width / 2)
    self.desc_label:setString(TI18N("暂无记录"))

    local size = cc.size(self.scroll_container:getContentSize().width, self.scroll_container:getContentSize().height-10)
    local setting = {
        item_class = EndlessRankItem,
        start_x = 4,
        space_x = 4,
        start_y = 0,
        space_y = -3,
        item_width = 614,
        item_height = 125,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.scroll_container, cc.p(0, 5), nil, nil, size, setting)

    local my_container = self.root_wnd:getChildByName("my_container")
    local my_rank_title = my_container:getChildByName("my_rank_title")

    self.rank_img = my_container:getChildByName("rank_img")
    self.rank_img:setVisible(false)
    self.rank_x = self.rank_img:getPositionX()
    self.rank_y = self.rank_img:getPositionY()


    self.role_name = my_container:getChildByName("role_name")
    self.role_power = my_container:getChildByName("role_power")
    self.power_bg = my_container:getChildByName("Image_1")
    self.no_rank = my_container:getChildByName("no_rank")
    self.no_rank:setString(TI18N("未上榜"))
    self.no_rank:setVisible(false)
    self.my_score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(520, 65), nil, nil, 300)
    my_container:addChild(self.my_score_info)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    self.role_head:setLev(99)
    my_container:addChild(self.role_head)

    self.my_container = my_container

    self:registerEvent()
end

function EndlessRankPanel:registerEvent()
    if self.update_rank_event == nil then
        self.update_rank_event = GlobalEvent:getInstance():Bind(RankEvent.RankEvent_Get_Rank_data, function(data) 
            if self.type_rank and data.type == self.type_rank then
                self:updateRankList(data)
            end
        end)
    end
end

function EndlessRankPanel:setNodeVisible(status)
    self:setVisible(status)
end

function EndlessRankPanel:addToParent()
    -- 窗体打开只请求一次，不是标签显示
    if self.is_init == true then
        local type_rank = RankConstant.RankType.endless
    
        if self.type == Endless_trailEvent.endless_type.water then
            type_rank = RankConstant.RankType.endless_water
        elseif self.type == Endless_trailEvent.endless_type.fire then
            type_rank = RankConstant.RankType.endless_fire
        elseif self.type == Endless_trailEvent.endless_type.wind then
            type_rank = RankConstant.RankType.endless_wind
        elseif self.type == Endless_trailEvent.endless_type.light_dark then
            type_rank = RankConstant.RankType.endless_lightdark
        end
        self.type_rank = type_rank
        RankController:send_12900(type_rank)
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
function EndlessRankPanel:updatePanelInfo(is_event)

end

function EndlessRankPanel:updateRankList(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.role_name:setString(role_vo.name)
        self.role_power:setString(role_vo.power)
        local width = self.role_power:getContentSize().width + 75
        local height = self.power_bg:getContentSize().height
        self.power_bg:setContentSize(cc.size(width, height))
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

        local msg = string.format(
            TI18N("<div>%s</div><div fontcolor=#249003 fontsize=22>%s</div>"),
            TI18N("最大通关数:"),
            data.my_val1 or 0
        )
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

        -- 创建排行榜。。。。。这里做点击回到用于记录更新点赞数量
        local function click_callback(item)
            self:worshipOtherRole(item)
        end
        if data.rank_list ~= nil and next(data.rank_list) ~= nil then
            self.scroll_view:setData(data.rank_list, click_callback)
            self.empty_bg:setVisible(false)
        else
            self.empty_bg:setVisible(true)
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
function EndlessRankPanel:worshipOtherRole(item)
    if item.data ~= nil then
        self.select_item = item
    end
end

function EndlessRankPanel:DeleteMe()
    if self.update_rank_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
    end
    if self.update_worship_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_worship_event)
        self.update_worship_event = nil
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
EndlessRankItem = class("EndlessRankItem",function()
    return ccui.Layout:create()
end)

function EndlessRankItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_rank_item"))
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
    self.power_bg = container:getChildByName("Image_1")
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

function EndlessRankItem:registerEvent()
    self.role_head:addCallBack( function()
        if self.data ~= nil then
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
        end
    end,false)
end

function EndlessRankItem:addCallBack(call_back)
    self.call_back = call_back
end
function EndlessRankItem:setData(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.data = data
        self.role_name:setString(data.name)
        self.role_power:setString(data.val2)
        local width = self.role_power:getContentSize().width + 75
        local height = self.power_bg:getContentSize().height
        self.power_bg:setContentSize(cc.size(width,height))
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
        local msg = string.format(TI18N("<div>%s</div><div fontcolor=#249003 fontsize=22>%s</div>"), TI18N("最大通关数:"), data.val1 or 0)
        self.score_info:setString(msg)
    end
end

function EndlessRankItem:DeleteMe()
    if self.rank_num ~= nil then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
