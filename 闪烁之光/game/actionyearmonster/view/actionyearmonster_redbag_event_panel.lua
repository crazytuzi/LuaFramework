--------------------------------------------
-- @Author  : lwc
-- @Editor  : lwc
-- @Date    : 2020年1月8日
-- @description    : 
        -- 年兽事件红包
---------------------------------
local _controller = ActionyearmonsterController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

ActionyearmonsterRedbagEventPanel = ActionyearmonsterRedbagEventPanel or BaseClass(BaseView)

function ActionyearmonsterRedbagEventPanel:__init()
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.layout_name = "returnaction/returnaction_redbag_info_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("actionpetard", "actionpetard"), type = ResourcesType.plist},
    }
end

function ActionyearmonsterRedbagEventPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container, 2)

    self.close_btn = main_container:getChildByName("close_btn")

    self.num_txt = main_container:getChildByName("num_txt")

    local list_panel = main_container:getChildByName("list_panel")
    local scroll_size = list_panel:getContentSize()
    local setting = {
        item_class = ReturnActionRedbagInfoItem1,      -- 单元类
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

function ActionyearmonsterRedbagEventPanel:register_event(  )
    registerButtonEventListener(self.background, function (  ) _controller:openActionyearmonsterRedbagEventPanel(false) end, false, 2)
    registerButtonEventListener(self.close_btn, function (  ) _controller:openActionyearmonsterRedbagEventPanel(false) end, true, 2)
end

function ActionyearmonsterRedbagEventPanel:openRootWnd( setting )
    local setting = setting or {}
    info_data = setting.info_data
    self:setData(info_data)
end

function ActionyearmonsterRedbagEventPanel:setData( data )
    if not data then return end
    self.data = data

    if not self.role_name_txt then
        self.role_name_txt = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(242, 580),nil,nil,800)
        self.main_container:addChild(self.role_name_txt)
    end
    if data.flag == 1 then --领取红包成功
        if not self.role_head then
            self.role_head = PlayerHead.new(PlayerHead.type.circle)
            self.role_head:setPosition(cc.p(242, 658))
            self.main_container:addChild(self.role_head)
        end
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo then
            self.role_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)

            local avatar_bid = role_vo.avatar_base_id 
            if self.record_res_bid == nil or self.record_res_bid ~= avatar_bid then
                self.record_res_bid = avatar_bid
                local vo = Config.AvatarData.data_avatar[avatar_bid]
                --背景框
                if vo then
                    local res_id = vo.res_id or 1
                    local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
                    self.role_head:showBg(res, nil, false, vo.offy)
                else
                    local bgRes = PathTool.getResFrame("common","common_1031")
                    self.role_head:showBg(bgRes, nil, true)
                end
            end
        end
        self.role_name_txt:setString(TI18N("<div fontcolor=#ffeeac>成功领取全服红包！</div>"))
    else
        self.role_name_txt:setPositionY(600)
        self.role_name_txt:setString(TI18N("<div fontcolor=#8af77b>未能领取全服红包~o(>﹏<)o</div>"))
    end
  
    -- 剩余个数
    local all_num = data.all_num or 0
    local last_num = data.last_num or 0
    self.num_txt:setString(_string_format(TI18N("剩余个数：%d/%d"), last_num, all_num))

    local role_num = data.role_num or 0
    local role_all_num = data.role_all_num or 0
    self.role_count_txt = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(242, -24))
    self.main_container:addChild(self.role_count_txt)
    self.role_count_txt:setString(_string_format(TI18N("<div fontcolor=#ffeeac>个人红包领取个数:%s/%s</div>"), role_num, role_all_num))
    if data.information and next(data.information) ~= nil then
        local redbag_data = data.information
        local role_vo = RoleController:getInstance():getRoleVo()
        local function sortFunc( objA, objB )
            local a_is_myself = (objA.rid == role_vo.rid and objA.srv_id == role_vo.srv_id)
            local b_is_myself = (objB.rid == role_vo.rid and objB.srv_id == role_vo.srv_id)
            if a_is_myself and not b_is_myself then
                return true
            elseif not a_is_myself and b_is_myself then
                return false
            else
                return objA.unixtime > objB.unixtime
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
    else
        commonShowEmptyIcon(self.item_scrollview, true, {label_color = cc.c4b(0xff,0xff,0xff,0xff), text = TI18N("暂无信息")})
    end
end

function ActionyearmonsterRedbagEventPanel:close_callback(  )
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.role_head then
        self.role_head:DeleteMe()
        self.role_head = nil
    end
    _controller:openActionyearmonsterRedbagEventPanel(false)
end

ReturnActionRedbagInfoItem1 = class("ReturnActionRedbagInfoItem1", function()
    return ccui.Widget:create()
end)

function ReturnActionRedbagInfoItem1:ctor()
    self:configUI()
    self:register_event()
end

function ReturnActionRedbagInfoItem1:configUI(  )
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

function ReturnActionRedbagInfoItem1:register_event(  )
    
end

function ReturnActionRedbagInfoItem1:setData( data )
    if not data then return end
    self.data = data
    -- 头像
    self.role_head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
    local avatar_bid = data.avatar_bid 
    if self.record_res_bid == nil or self.record_res_bid ~= avatar_bid then
        self.record_res_bid = avatar_bid
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        --背景框
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        else
            local bgRes = PathTool.getResFrame("common","common_1031")
            self.role_head:showBg(bgRes, nil, true)
        end
    end

    -- 角色名称
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo.rid == data.rid and role_vo.srv_id == data.srv_id then
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
    self.time_txt:setString(TimeTool.getMDHMS(data.unixtime))

    -- 获得物品
    local award_str = ""
    local reward_list = data.reward_list
    for i,v in ipairs( reward_list) do
        local item_bid = v.base_id
        local item_num = v.num or 0
        local item_cfg = Config.ItemData.data_get_data(item_bid)
        if item_cfg then
            local iconsrc = PathTool.getItemRes(item_cfg.icon)
            award_str = award_str .. _string_format("<img src='%s' scale=0.3 /> %d", iconsrc, item_num)
        end
    end
    self.award_txt:setString(award_str)
end

function ReturnActionRedbagInfoItem1:setIndex( index )
    if self.is_myself or not index then return end

    if (index%2) == 0 then
        self.image_bg:setVisible(false)
    else
        self.image_bg:setVisible(true)
        self.image_bg:loadTexture(PathTool.getResFrame("actionpetard", "actionpetard_1008"), LOADTEXT_TYPE_PLIST)
    end
end

function ReturnActionRedbagInfoItem1:DeleteMe(  )
    if self.role_head then
        self.role_head:DeleteMe()
        self.role_head = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end