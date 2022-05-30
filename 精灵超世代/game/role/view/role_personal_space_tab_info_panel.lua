-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      竖版伙伴培养信息面板
-- <br/> 2018年11月15日
-- --------------------------------------------------------------------
RolePersonalSpaceTabInfoPanel =
    class(
    "RolePersonalSpaceTabInfoPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = RoleController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function RolePersonalSpaceTabInfoPanel:ctor(parent)
    self.parent = parent
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function RolePersonalSpaceTabInfoPanel:config()
    NoticeController:getInstance():sender10813() --客服中心红点
end

function RolePersonalSpaceTabInfoPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("roleinfo/role_personal_space_tab_info_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)

    self.main_panel = self.main_container:getChildByName("main_panel")
    self.title_img = self.main_panel:getChildByName("title_img")
    self.title_btn = self.main_panel:getChildByName("title_btn")
    self.honor_img = self.main_panel:getChildByName("honor_img")

    --属性
    self.attr_panel = self.main_container:getChildByName("attr_panel")
    local attr_name_list = {
        [1] = TI18N("等级:"),
        [2] = TI18N("公会:"),
        [3] = TI18N("粉丝:"),
        [4] = TI18N("段位:")
    }
    self.attr_item_list = {}
    for i = 1, 4 do
        local item = {}
        item.attr_icon = self.attr_panel:getChildByName("attr_icon" .. i)
        item.attr_key = self.attr_panel:getChildByName("attr_key" .. i)
        item.attr_key:setString(attr_name_list[i])
        item.attr_value = self.attr_panel:getChildByName("attr_value" .. i)
        item.attr_key:setFontSize(14)
        item.attr_value:setFontSize(14)
        self.attr_item_list[i] = item
    end
    --省份
    self.province_key = self.attr_panel:getChildByName("province_key")
    self.province_key:setString(TI18N("省市:"))
    self.province_value = self.attr_panel:getChildByName("province_value")
    --城市
    self.city_key = self.attr_panel:getChildByName("city_key")
    self.city_key:setString(TI18N("地区:"))
    self.city_value = self.attr_panel:getChildByName("city_value")
    --省份按钮
    self.province_btn = self.attr_panel:getChildByName("province_btn")
    --城市按钮
    self.city_btn = self.attr_panel:getChildByName("city_btn")

    --下拉框面板
    self.combobox_panel = self.main_container:getChildByName("combobox_panel")
    self.combobox_bg = self.combobox_panel:getChildByName("bg")
    self.combobox_bg_size = self.combobox_bg:getContentSize()
    self.combobox_max_size = cc.size(240, 182) --最大size 根据示意图得出来的

    self.look_btn = self.attr_panel:getChildByName("look_btn")

    self.role_head_node = self.main_container:getChildByName("role_head_node")
    --self.role_head_node:setPositionX(338)
    --local res = PathTool.getResFrame("rolepersonalspace","role_personal_space_34")
    --local mask_res = PathTool.getResFrame("rolepersonalspace","role_personal_space_35")--cc.size(138, 138)
    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    -- self.role_head:setScale(1.3)
    self.role_head:setAnchorPoint(cc.p(0.5, 0.5))
    -- self.role_head:setPosition(cc.p(20, 40))
    self.role_head_node:addChild(self.role_head)

    self.role_name = self.main_container:getChildByName("role_name")
    --self.chang_name = self.main_container:getChildByName("chang_name")
    --改名
    self.change_name_btn = self.main_container:getChildByName("change_name_btn")
    --关注
    self.follow_btn = self.main_container:getChildByName("follow_btn")

    self.set_btn_list = {}
    for i = 1, 4 do
        self.set_btn_list[i] = {}
        self.set_btn_list[i].btn = self.main_container:getChildByName("set_btn_" .. i)
        self.set_btn_list[i].label = self.set_btn_list[i].btn:getChildByName("label")
    end
    local set_res_list
    local set_name_list
    if self.parent.role_type == RoleConst.role_type.eOther then
        --其他人
        self.province_btn:setVisible(false)
        self.city_btn:setVisible(false)
        --self.chang_name:setVisible(false)
        self.change_name_btn:setVisible(false)

        --四个按钮的资源 不同显示不同
        set_res_list = {
            [1] = "role_personal_space_22", --举报
            -- [2] = "role_personal_space_23", --关注
            [3] = "role_personal_space_20" --家园
            -- [4] = "role_personal_space_24"  --加好友
            -- [5] = "role_personal_space_25"  --私聊
            -- [5] = "role_personal_space_26"  --取消关注
        }
        set_name_list = {
            [1] = TI18N("举报"),
            [2] = TI18N("关注"),
            [3] = TI18N("家园"),
            [4] = TI18N("加好友")
        }
    else
        self.follow_btn:setVisible(false)
        --自己
        self.role_head:addCallBack(
            function()
                controller:openRoleDecorateView(true)
            end
        )
        --self.chang_name:setString(TI18N("更换"))
        --四个按钮的资源 不同显示不同
        set_res_list = {
            [1] = "role_personal_space_18", --冒险形象
            [2] = "role_personal_space_19", --称号
            [3] = "role_personal_space_20", --家园
            [4] = "role_personal_space_21" --系统设置
        }
        set_name_list = {
            [1] = TI18N("冒险形象"),
            [2] = TI18N("称号"),
            [3] = TI18N("家园"),
            [4] = TI18N("系统设置")
        }
    end

    for i, v in ipairs(self.set_btn_list) do
        if set_res_list[i] then
            local res = PathTool.getResFrame("rolepersonalspace", set_res_list[i])
            v.btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
        end
        if set_name_list[i] then
            v.label:setString(set_name_list[i])
        end
    end

    local x = 1
    local hero_node = self.main_container:getChildByName("hero_node")
    self.hero_item_list = {}
    local item_width = 116
    local x = -item_width * 5 * 0.5 + item_width * 0.5
    for i = 1, 5 do
        self.hero_item_list[i] = HeroExhibitionItem.new(0.9, true)
        self.hero_item_list[i]:setPosition(x + (i - 1) * item_width, 0)
        self.hero_item_list[i]:addCallBack(
            function()
                self:onClickHeroItemByIndex(i)
            end
        )
        self.hero_item_list[i]:setBgOpacity(128)
        hero_node:addChild(self.hero_item_list[i])
    end

    --tips面板
    self.tips_panel = self.main_container:getChildByName("tips_panel")
    self.tips_title_img = self.tips_panel:getChildByName("title_img")
    self.tips_title_img:setScale(0.8)
    self.tips_name = self.tips_panel:getChildByName("name")

    --隐藏
    self:onShowTipsPanel(false)
    self:onHideComboboxPanel()
end

--事件
function RolePersonalSpaceTabInfoPanel:registerEvents()
    registerButtonEventListener(
        self.province_btn,
        function()
            self:onProvinceBtn()
        end,
        false,
        1
    )
    registerButtonEventListener(
        self.city_btn,
        function()
            self:onCityBtn()
        end,
        false,
        1
    )
    registerButtonEventListener(
        self.change_name_btn,
        function()
            self:onChangNameBtn()
        end,
        true,
        1
    )
    registerButtonEventListener(
        self.title_btn,
        function()
            self:onTitleBtn()
        end,
        false,
        1
    )
    --应策划要求.暂时没有点击事件
    -- registerButtonEventListener(self.follow_btn, function() self:onFollowBtn()  end ,true, 1)
    --详情
    registerButtonEventListener(
        self.look_btn,
        function()
            self:onClickLookBtn()
        end,
        true,
        1
    )

    registerButtonEventListener(
        self.main_container,
        function()
            self:onHideComboboxPanel()
            self:onShowTipsPanel(false)
        end,
        false,
        0
    )

    for i, v in ipairs(self.set_btn_list) do
        registerButtonEventListener(
            v.btn,
            function()
                self:onSetBtn(i)
            end,
            true,
            1
        )
    end

    if self.All_Feedback_Event_Data == nil then
        self.All_Feedback_Event_Data =
            GlobalEvent:getInstance():Bind(
            NoticeEvent.All_Feedback_Event_Data,
            function()
                --
                local status = NoticeController:getInstance():getModel():getRedStatus() or false
                if #self.set_btn_list >= 4 then
                    addRedPointToNodeByStatus(self.set_btn_list[4], status, 6, 6, nil)
                end
            end
        )
    end

    --是自己才有监听
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        if self.role_vo then
            if self.role_update_event == nil then
                self.role_update_event =
                    self.role_vo:Bind(
                    RoleEvent.UPDATE_ROLE_ATTRIBUTE,
                    function(key, value)
                        if key == "face_id" or key == "face_update_time" then
                            self:updateRoleHead()
                        elseif key == "avatar_base_id" then
                            self:updateHeadBg(value)
                        elseif key == "name" then
                            self.role_name:setString(value)
                        elseif key == "sex" then
                        elseif key == "backdrop_id" then
                            self:setBackgroundRes(value)
                        end
                    end
                )
            end
        end

        --获取称号
        if self.get_title_list_event == nil then
            self.get_title_list_event =
                GlobalEvent:getInstance():Bind(
                RoleEvent.GetTitleList,
                function(data)
                    if not data then
                        return
                    end
                    self:updateHonorInfo(data.base_id)
                end
            )
        end
        --使用称号事件
        if self.use_title_event == nil then
            self.use_title_event =
                GlobalEvent:getInstance():Bind(
                RoleEvent.UseTitle,
                function(base_id)
                    if not base_id then
                        return
                    end
                    self:updateHonorInfo(base_id)
                end
            )
        end

        --阵法刷新事件
        -- if self.form_drama_event == nil then
        --     self.form_drama_event = GlobalEvent:getInstance():Bind(HeroEvent.Form_Drama_Event,function ()
        --         -- if not base_id then return end
        --         self:updateMySelfHeroInfo()
        --     end)
        -- end

        --布阵信息返回
        if not self.update_fun_form then
            self.update_fun_form =
                GlobalEvent:getInstance():Bind(
                HeroEvent.Update_Fun_Form,
                function(data)
                    if data and data.type and data.type == PartnerConst.Fun_Form.PersonalSpace then
                        self:updateMySelfHeroInfo(data)
                    end
                end
            )
        end

        --粉丝榜事件
        if not self.role_fans_rank_event then
            self.role_fans_rank_event =
                GlobalEvent:getInstance():Bind(
                RoleEvent.ROLE_FANS_RANK_EVENT,
                function(data)
                    if not data then
                        return
                    end
                    self:updateMyRankInfo(data)
                end
            )
        end
        --城市设置事件
        if not self.role_city_event then
            self.role_city_event =
                GlobalEvent:getInstance():Bind(
                RoleEvent.ROLE_CITY_EVENT,
                function(data)
                    if not data then
                        return
                    end
                    if self.record_city_id then
                        self:setProvinceAndCity(self.record_city_id)
                        self.role_vo:setRoleAttribute("city_id", self.record_city_id)
                        self.record_city_id = nil
                    end
                end
            )
        end
    else --他人的 事件
        if not self.role_follow_event then
            self.role_follow_event =
                GlobalEvent:getInstance():Bind(
                RoleEvent.ROLE_FOLLOW_EVENT,
                function(data)
                    if not data then
                        return
                    end
                    if not self.parent then
                        return
                    end
                    if self.parent.other_data then
                        if self.parent.other_data.is_fanse and self.parent.other_data.is_fanse == 1 then
                            self.parent.other_data.fans_num = self.parent.other_data.fans_num - 1
                            self.parent.other_data.is_fanse = data.flag
                            self:updateFollowInfo(self.parent.other_data.fans_num)
                        else
                            self.parent.other_data.fans_num = self.parent.other_data.fans_num + 1
                            self.parent.other_data.is_fanse = data.flag
                            self:updateFollowInfo(self.parent.other_data.fans_num)
                        end
                    end
                end
            )
        end
    end
end

function RolePersonalSpaceTabInfoPanel:updateRoleHead()
    print("updateRoleHead")
    if self.role_vo == nil then
        return
    end
    print("self.role_vo.face_id", self.role_vo.face_id)
    self.role_head:setHeadRes(
        self.role_vo.face_id,
        false,
        LOADTEXT_TYPE,
        self.role_vo.face_file,
        self.role_vo.face_update_time
    )
end

--点击省份
function RolePersonalSpaceTabInfoPanel:onProvinceBtn()
    self:onShowTipsPanel(false)
    local datalist
    if self.province_config_list == nil then
        self.province_config_list = {}
        local list = Config.RoleData.data_province_list or {}
        for k, v in pairs(list) do
            table_insert(self.province_config_list, v)
        end
        table.sort(
            self.province_config_list,
            function(a, b)
                return a.province_id < b.province_id
            end
        )
    end
    self.combobox_panel:setPositionX(183)
    self:updateComboboxList(self.province_config_list, 1)
end
--点击城市
function RolePersonalSpaceTabInfoPanel:onCityBtn()
    self:onShowTipsPanel(false)
    local list = self:getCurrentCityList()
    if list then
        self.combobox_panel:setPositionX(468)
        self:updateComboboxList(list, 2)
    end
end
--获取当前城市列表
function RolePersonalSpaceTabInfoPanel:getCurrentCityList()
    if not self.city_config then
        return
    end
    local list = Config.RoleData.data_city_list[self.city_config.province_id]
    if list then
        table.sort(
            list,
            function(a, b)
                return a.city_id < b.city_id
            end
        )
    end
    return list
end

--隐藏列表
function RolePersonalSpaceTabInfoPanel:onHideComboboxPanel()
    -- body
    if self.combobox_panel then
        self.combobox_panel:setPositionX(-10000)
    end
end
--改名
function RolePersonalSpaceTabInfoPanel:onChangNameBtn()
    if isQingmingShield and isQingmingShield() then
        return
    end
    if not self.role_vo then
        return
    end

    if self.parent.role_type == RoleConst.role_type.eMySelf then
        if self.role_vo.sex == 2 then
            controller:openRoleChangeNameView(true)
            return
        end
        local function confirm_callback(str)
            if str == nil or str == "" then
                message(TI18N("名字不合法"))
                return
            end
            if not self.role_vo then
                return
            end
            local text = string.gsub(str, "\n", "")
            controller:changeRoleName(text, self.role_vo.sex)
            --self.set_name_alert关闭在名字改变成功后[图片]
        end
        local msg
        if self.role_vo ~= nil and self.role_vo.is_first_rename == TRUE then
            msg = TI18N("首次更改免费哦~")
        else
            msg =
                string.format(
                TI18N("<div fontcolor=#a95f0f>改名需消耗200 <img src=%s scale=0.3 visible=true /></div>"),
                PathTool.getItemRes(Config.ItemData.data_get_data(3).icon)
            )
        end
        self.set_name_alert =
            CommonAlert.showInputApply(
            msg,
            TI18N("请输入名字(限制6字)"),
            TI18N("确 定"),
            confirm_callback,
            TI18N("取 消"),
            nil,
            true,
            nil,
            20,
            CommonAlert.type.rich,
            FALSE,
            cc.size(270, 80),
            12,
            {off_y = -15},
            true
        )
        self.set_name_alert.alert_txt:setPositionY(20)
        --self.set_name_alert.line:setVisible(false)
        local label =
            createLabel(
            26,
            Config.ColorData.data_color4[175],
            nil,
            75,
            75,
            TI18N("名字："),
            self.set_name_alert.alert_panel
        )
    end
end

function RolePersonalSpaceTabInfoPanel:onFollowBtn()
end

function RolePersonalSpaceTabInfoPanel:closeSetNameAlert()
    if self.set_name_alert then
        self.set_name_alert:close()
        self.set_name_alert = nil
    end
end

function RolePersonalSpaceTabInfoPanel:onTitleBtn()
    if not self.parent then
        return
    end
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        controller:openRoleDecorateView(true, 5)
    end
end

function RolePersonalSpaceTabInfoPanel:onSetBtn(index)
    if not self.parent then
        return
    end
    if not self.role_vo then
        return
    end
    if index == 1 then
        if self.parent.role_type == RoleConst.role_type.eMySelf then
            --冒险形象
            controller:openRoleDecorateView(true, 3)
        else
            --举报
            if self.parent.other_data then
                controller:openRoleReportedPanel(
                    true,
                    self.parent.other_data.rid,
                    self.parent.other_data.srv_id,
                    self.parent.other_data.name
                )
            end
        end
    elseif index == 2 then
        if self.parent.role_type == RoleConst.role_type.eMySelf then
            --称号
            controller:openRoleDecorateView(true, 4)
        else
            -- local config = Config.RoleData.data_role_const.fan_like_levlimit
            -- if config and config.val
            if self.parent.other_data then
                controller:send25801(self.parent.other_data.rid, self.parent.other_data.srv_id)
            end
        end
    elseif index == 3 then
        local config = Config.HomeData.data_const.open_lev
        if config and self.role_vo.lev < config.val then
            message(config.desc)
            return
        end
        if self.parent.role_type == RoleConst.role_type.eMySelf then
            if self.role_vo.is_open_home == 1 then
                HomeworldController:getInstance():requestOpenMyHomeworld()
                self.parent:onClosedBtn()
            else
                message(TI18N("暂未开启家园"))
            end
        elseif self.parent.other_data then
            if self.parent.other_data.is_open_home == 1 then
                HomeworldController:getInstance():sender26003(self.parent.other_data.rid, self.parent.other_data.srv_id)
                self.parent:onClosedBtn()
            else
                --message(TI18N("对方暂未拥有家园"))
                message(TI18N("暂未开启家园"))
            end
        end
    elseif index == 4 then
        if self.parent.role_type == RoleConst.role_type.eMySelf then
            --系统设置
            controller:openRoleSystemSetPanel(true)
        else
            --加好友或者 私聊
            if self.parent.other_data then
                if self.parent.other_data.is_friend == 1 then
                    -- 私聊
                    ChatController:getInstance():openChatPanel(
                        ChatConst.Channel.Friend,
                        "friend",
                        self.parent.other_data
                    )
                    self.parent:onClosedBtn()
                else
                    -- 加好友
                    FriendController:getInstance():addOther(self.parent.other_data.srv_id, self.parent.other_data.rid)
                end
            end
        end
    end
end

function RolePersonalSpaceTabInfoPanel:onClickLookBtn()
    self:onHideComboboxPanel()
    self:onShowTipsPanel(true)
end

--点击宝可梦 根据索引
function RolePersonalSpaceTabInfoPanel:onClickHeroItemByIndex(pos)
    if not self.role_vo then
        return
    end
    if not self.hero_list then
        return
    end
    local hero_data = self.hero_list[pos]

    if self.parent.role_type == RoleConst.role_type.eMySelf then
        if hero_data == nil then
            controller:openRoleHeroShowFormPanel(true)
        else
            HeroController:getInstance():openHeroTipsPanel(true, hero_data, {is_show_form_btn = true})
        end
    else
        if not hero_data then
            return
        end
        LookController:getInstance():sender11061(hero_data.rid, hero_data.srv_id, hero_data.id)
    end
end

function RolePersonalSpaceTabInfoPanel:setBackgroundRes(backdrop_id)
    if not backdrop_id then
        return
    end

    if backdrop_id == 0 then
        --默认图片
        res_id = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace_head", "100000")
    else
        local config = Config.ItemData.data_get_data(backdrop_id)
        if config then
            res_id = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace_head", config.icon)
        else
            res_id = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace_head", "100000")
        end
    end
    if self.record_title_img_res == nil or self.record_title_img_res ~= res_id then
        self.record_title_img_res = res_id
        self.item_load_title_img_res =
            loadSpriteTextureFromCDN(self.title_img, res_id, ResourcesType.single, self.item_load_title_img_res)
    end
end

--@hero_vo 宝可梦数据
function RolePersonalSpaceTabInfoPanel:setData()
    if not self.role_vo then
        return
    end
    if not self.parent then
        return
    end
    -- 标题

    if self.parent.role_type == RoleConst.role_type.eMySelf then
        self:setBackgroundRes(self.role_vo.backdrop_id)
        self.attr_item_list[1].attr_value:setString(self.role_vo.lev)
        if self.role_vo.gname and self.role_vo.gname == "" then
            self.attr_item_list[2].attr_value:setString(TI18N("未加入公会"))
        else
            self.attr_item_list[2].attr_value:setString(self.role_vo.gname)
        end
        self.attr_item_list[3].attr_value:setString(self.role_vo.fans_num)
        self:updateElitelev(self.role_vo.arena_elite_lev)

        self.role_head:setHeadRes(
            self.role_vo.face_id,
            false,
            LOADTEXT_TYPE,
            self.role_vo.face_file,
            self.role_vo.face_update_time
        )
        self:updateHeadBg(self.role_vo.avatar_base_id)

        self.role_name:setString(self.role_vo.name)

        self:setProvinceAndCity(self.role_vo.city_id)

        setChildUnEnabled(self.role_vo.is_open_home ~= 1, self.set_btn_list[3].btn)
        setChildUnEnabled(false, self.set_btn_list[3].label)

        --获取称号信息
        controller:sender23300()
        --获取布阵信息
        HeroController:getInstance():sender11211(PartnerConst.Fun_Form.PersonalSpace)
    else
        if self.parent.other_data then
            self:setBackgroundRes(self.parent.other_data.backdrop_id)

            self.role_head:setHeadRes(
                self.parent.other_data.face_id,
                false,
                LOADTEXT_TYPE,
                self.parent.other_data.face_file,
                self.parent.other_data.face_update_time
            )
            self:updateHeadBg(self.parent.other_data.avatar_bid)
            self.role_name:setString(self.parent.other_data.name)
            self:updateFollowInfo(self.parent.other_data.fans_num)
            if self.parent.other_data.is_friend == 1 then
                if self.set_btn_list[4] then
                    self.set_btn_list[4].label:setString(TI18N("私聊"))
                    local res = PathTool.getResFrame("rolepersonalspace", "role_personal_space_25")
                    self.set_btn_list[4].btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
                end
            else
                if self.set_btn_list[4] then
                    self.set_btn_list[4].label:setString(TI18N("加好友"))
                    local res = PathTool.getResFrame("rolepersonalspace", "role_personal_space_24")
                    self.set_btn_list[4].btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
                end
            end

            setChildUnEnabled(self.parent.other_data.is_open_home ~= 1, self.set_btn_list[3].btn)
            setChildUnEnabled(false, self.set_btn_list[3].label)

            self.attr_item_list[1].attr_value:setString(self.parent.other_data.lev)
            if self.parent.other_data.gname and self.parent.other_data.gname == "" then
                self.attr_item_list[2].attr_value:setString(TI18N("未加入公会"))
            else
                self.attr_item_list[2].attr_value:setString(self.parent.other_data.gname)
            end
            self.attr_item_list[3].attr_value:setString(self.parent.other_data.fans_num)
            self:updateElitelev(self.parent.other_data.elite_lev)

            self:setProvinceAndCity(self.parent.other_data.city_id)
            self:updateOtherHeroInfo()
            --称号
            self:updateHonorInfo(self.parent.other_data.honor)
            --是否粉丝
            if self.parent.other_data.is_be_fanse == TRUE then
                self.follow_btn:setVisible(true)
            else
                self.follow_btn:setVisible(false)
            end
        end
        self:updateHeadBg()
    end
end

function RolePersonalSpaceTabInfoPanel:updateElitelev(elite_lev)
    if not elite_lev then
        return
    end
    local config = Config.ArenaEliteData.data_elite_level_fun(elite_lev)
    if config then
        if self.attr_item_list[4] then
            self.attr_item_list[4].attr_value:setString(config.name)
        end
    end
end
--更新关注信息
function RolePersonalSpaceTabInfoPanel:updateFollowInfo(fans_num)
    if self.parent.other_data.is_fanse and self.parent.other_data.is_fanse == 1 then
        if self.set_btn_list[2] then
            self.set_btn_list[2].label:setString(TI18N("取消关注"))
            local res = PathTool.getResFrame("rolepersonalspace", "role_personal_space_26")
            self.set_btn_list[2].btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
        end
    else
        if self.set_btn_list[2] then
            self.set_btn_list[2].label:setString(TI18N("关注"))
            local res = PathTool.getResFrame("rolepersonalspace", "role_personal_space_23")
            self.set_btn_list[2].btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
        end
    end
    if self.attr_item_list[3] then
        self.attr_item_list[3].attr_value:setString(fans_num)
    end
end

--自己宝可梦列表信息
function RolePersonalSpaceTabInfoPanel:updateMySelfHeroInfo(data)
    if not self.hero_item_list then
        return
    end
    if not data then
        return
    end
    local dic_pos_id = {}
    for i, v in ipairs(data.pos_info) do
        dic_pos_id[v.pos] = v.id
    end
    self.hero_list = {}
    local hero_model = HeroController:getInstance():getModel()
    --宝可梦
    for pos, hero_item in ipairs(self.hero_item_list) do
        if dic_pos_id[pos] then
            local hero_data = hero_model:getHeroById(dic_pos_id[pos])
            if hero_data then
                -- hero_item.can_click = true
                -- hero_item.can_effect = true
                self.hero_list[pos] = hero_data
                hero_item:setData(hero_data)
                hero_item:showAddIcon(false)
                hero_item:setBgOpacity(255)
            else
                -- hero_item.can_click = false
                -- hero_item.can_effect = false
                hero_item:setData(nil)
                hero_item:showAddIcon(true)
                hero_item:setBgOpacity(128)
            end
        else
            -- hero_item.can_click = false
            -- hero_item.can_effect = false
            hero_item:setData(nil)
            hero_item:showAddIcon(true)
            hero_item:setBgOpacity(128)
        end
    end
end

function RolePersonalSpaceTabInfoPanel:updateOtherHeroInfo()
    -- partner_list 结构参考 10315协议的 partner_list
    if not self.parent then
        return
    end
    if not self.parent.other_data then
        return
    end

    self.hero_list = {}
    local rid = self.parent.other_data.rid
    local srv_id = self.parent.other_data.srv_id
    local partner_list = self.parent.other_data.room_partner_list

    local dic_pos_id = {}
    for i, v in ipairs(partner_list) do
        dic_pos_id[v.pos] = v
    end

    for pos, hero_item in ipairs(self.hero_item_list) do
        self.hero_list[pos] = dic_pos_id[pos]
        if self.hero_list[pos] then
            self.hero_list[pos].rid = rid
            self.hero_list[pos].srv_id = srv_id
            hero_item:setData(self.hero_list[pos])
            hero_item:setBgOpacity(255)
            hero_item.can_click = true
            hero_item.can_effect = true
        else
            hero_item:setData(nil)
            hero_item:setBgOpacity(128)
            hero_item.can_click = false
            hero_item.can_effect = false
        end
    end
    for i, v in ipairs(partner_list) do
        self.hero_list[i] = v
    end
end

function RolePersonalSpaceTabInfoPanel:updateHeadBg(avatar_base_id)
    local vo = Config.AvatarData.data_avatar[avatar_base_id]
    if vo then
        local res_id = vo.res_id or 1
        local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
        self.role_head:showBg(res, nil, false, vo.offy)
        self.role_head:setHeadBgScale(1)
        self.role_head:setEffectBgScale(1)
    end
end

--称号信息
function RolePersonalSpaceTabInfoPanel:updateHonorInfo(use_id)
    if not use_id then
        return
    end
    local vo = Config.HonorData.data_title[use_id]
    if vo and vo.res_id then
        local res = PathTool.getTargetRes("honor", "txt_cn_honor_" .. vo.res_id, false, false)
        self.item_load_title =
            createResourcesLoad(
            res,
            ResourcesType.single,
            function()
                if not tolua.isnull(self.honor_img) then
                    loadSpriteTexture(self.honor_img, res, LOADTEXT_TYPE)
                end
            end,
            self.item_load_title
        )
    end
end

--更新下拉列表
--@_type 1 表示省份 2 表示城市
function RolePersonalSpaceTabInfoPanel:updateComboboxList(data_list, _type)
    if not data_list then
        return
    end
    local item_height = 42
    if self.combobox_scrollview == nil then
        local setting = {
            start_x = 2, -- 第一个单元的X起点
            space_x = 0, -- x方向的间隔
            start_y = 0, -- 第一个单元的Y起点
            space_y = 0, -- y方向的间隔
            item_width = 240, -- 单元的尺寸width
            item_height = item_height, -- 单元的尺寸height
            row = 1, -- 行数，作用于水平滚动类型
            col = 1, -- 列数，作用于垂直滚动类型
            delay = 1, -- 创建延迟时间
            once_num = 1 -- 每次创建的数量
        }
        self.combobox_scrollview =
            CommonScrollViewSingleLayout.new(
            self.combobox_panel,
            cc.p(0, 4),
            ScrollViewDir.vertical,
            ScrollViewStartPos.top,
            self.combobox_max_size,
            setting,
            cc.p(0, 0)
        )

        self.combobox_scrollview:registerScriptHandlerSingle(
            handler(self, self.createNewCell),
            ScrollViewFuncType.CreateNewCell
        ) --创建cell
        self.combobox_scrollview:registerScriptHandlerSingle(
            handler(self, self.numberOfCells),
            ScrollViewFuncType.NumberOfCells
        ) --获取数量
        self.combobox_scrollview:registerScriptHandlerSingle(
            handler(self, self.updateCellByIndex),
            ScrollViewFuncType.UpdateCellByIndex
        ) --更新cell
    end
    if next(data_list) ~= nil then
        local count = #data_list
        if count > 4 then
            self.combobox_scrollview:setClickEnabled(true)
            self.combobox_bg:setContentSize(self.combobox_bg_size)
        else
            self.combobox_scrollview:setClickEnabled(false)
            local total_height = count * item_height + (self.combobox_bg_size.height - self.combobox_max_size.height)
            self.combobox_bg:setContentSize(cc.size(self.combobox_bg_size.width, total_height))
        end
        self.show_list = data_list
        local select_index = nil
        for i, v in ipairs(self.show_list) do
            if _type == 1 then --省份
                if self.city_config and v.province_id and self.city_config.province_id == v.province_id then
                    select_index = i
                end
            else
                if v.city_id and self.city_id and self.city_id == v.city_id then
                    select_index = i
                end
            end
        end

        self.combobox_scrollview:reloadData(select_index)
    end
end

--创建cell
--@width 是setting.item_width
--@height 是setting.item_height
function RolePersonalSpaceTabInfoPanel:createNewCell(width, height)
    local cell = ccui.Layout:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0.5, 0.5)
    cell:setTouchEnabled(true)
    cell:setContentSize(cc.size(width, height))

    local size = cc.size(width - 20, 2)
    local res = PathTool.getResFrame("common", "common_1097")
    cell.bg = createImage(cell, res, 10, 0, cc.p(0, 0), true, 0, true)
    cell.bg:setContentSize(size)
    cell.bg:setCapInsets(cc.rect(1, 1, 1, 1))
    --
    --local res = PathTool.getResFrame("common","common_90058_1")
    --cell.select_bg = createImage(cell, res, 0, 2, cc.p(0, 0), true, 0, true)
    --cell.select_bg:setContentSize(size)
    ---- cell.select_bg:setOpacity(90)
    --cell.select_bg:setCapInsets(cc.rect(8, 10, 2, 1))
    --cell.select_bg:setVisible(false)

    cell.label =
        createLabel(22, Config.ColorData.data_new_color4[6], nil, 10, height * 0.5, "", cell, nil, cc.p(0, 0.5))

    local mark_res = PathTool.getResFrame("common", "common_1043")
    cell.mark_img = createSprite(mark_res, width - 10, height * 0.5 + 2, cell, cc.p(1, 0.5), LOADTEXT_TYPE_PLIST)
    cell.mark_img:setScale(0.8)

    -- cell.

    -- registerButtonEventListener(cell, function() self:setCellTouched(cell) end ,false, 1)
    cell:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.began then
                --cell.select_bg:setVisible(true)
                cell.touch_began = sender:getTouchBeganPosition()
            elseif event_type == ccui.TouchEventType.moved then
                --cell.select_bg:setVisible(false)
            elseif event_type == ccui.TouchEventType.ended then
                local touch_began = cell.touch_began
                local touch_end = sender:getTouchEndPosition()
                if
                    touch_began and touch_end and
                        (math.abs(touch_end.x - touch_began.x) > 10 or math.abs(touch_end.y - touch_began.y) > 10)
                 then
                    --点击无效了
                    return
                end

                playButtonSound2()
                self:setCellTouched(cell)
            end
        end
    )
    return cell
end

--获取数据数量
function RolePersonalSpaceTabInfoPanel:numberOfCells()
    if not self.show_list then
        return 0
    end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function RolePersonalSpaceTabInfoPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then
        return
    end
    --cell.select_bg:setVisible(false)
    if data.province_name then
        cell.label:setString(data.province_name)
        if self.city_config and self.city_config.province_id == data.province_id then
            cell.mark_img:setVisible(true)
        else
            cell.mark_img:setVisible(false)
        end
    elseif data.city_name then
        cell.label:setString(data.city_name)
        if self.city_id and self.city_id == data.city_id then
            cell.mark_img:setVisible(true)
        else
            cell.mark_img:setVisible(false)
        end
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function RolePersonalSpaceTabInfoPanel:setCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then
        return
    end
    self.record_city_id = nil
    if data.province_name then
        local list = Config.RoleData.data_city_list[data.province_id]
        if list and next(list) ~= nil then
            table.sort(
                list,
                function(a, b)
                    return a.city_id < b.city_id
                end
            )
            self:setProvinceAndCity(list[1].city_id)
            self.record_city_id = list[1].city_id
        end
    elseif data.city_name then
        self:setProvinceAndCity(data.city_id)
        self.record_city_id = data.city_id
    end

    if self.record_city_id ~= nil then
        controller:send25800(self.record_city_id)
    end

    self:onHideComboboxPanel()
end

--设置省份和城市
function RolePersonalSpaceTabInfoPanel:setProvinceAndCity(city_id)
    if not city_id then
        return
    end
    self.city_id = city_id
    self.city_config = Config.RoleData.data_city_id_to_province_id(self.city_id)
    if self.city_config then
        self.province_value:setString(self.city_config.province_name)
        self.city_value:setString(self.city_config.city_name)
    else
        self.province_value:setString(TI18N("未设置"))
        self.city_value:setString(TI18N("未设置"))
    end
end

function RolePersonalSpaceTabInfoPanel:onShowTipsPanel(status)
    if not self.tips_panel then
        return
    end
    if status then
        self.tips_panel:setPositionX(252)
        if self.tips_label1 == nil then
            self.tips_label1 =
                createRichLabel(16, cc.c4b(0xe0, 0xbf, 0x98, 0xff), cc.p(0, 1), cc.p(25, 220), nil, nil, 240)
            self.tips_panel:addChild(self.tips_label1)
        end

        local text1 = Config.RoleData.data_role_const.fans_tips_text1.desc
        print("text1 content:" .. text1)
        self.tips_label1:setString(text1)

        if self.tips_label2 == nil then
            self.tips_label2 =
                createRichLabel(16, cc.c4b(0xe0, 0xbf, 0x98, 0xff), cc.p(0, 1), cc.p(25, 86), nil, nil, 240)
            self.tips_panel:addChild(self.tips_label2)
        end

        local text2 = Config.RoleData.data_role_const.fans_tips_text2.desc
        self.tips_label2:setString(text2)

        if self.my_rank == nil then
            self.my_rank = createRichLabel(16, cc.c4b(0xff, 0x7d, 0x27, 0xff), cc.p(0, 1), cc.p(25, 20), nil, nil, 600)
            self.tips_panel:addChild(self.my_rank)
        end

        local fans_avatar_id = Config.RoleData.data_role_const.fans_avatar_id or {}
        local config = Config.AvatarData.data_avatar[fans_avatar_id.val]
        if config then
            local res_id = config.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            if not self.item_load_tips then
                self.item_load_tips =
                    loadSpriteTextureFromCDN(self.tips_title_img, res, ResourcesType.single, self.item_load_tips)

                print("cdn res is "..res)
            end

            self.tips_name:setString(config.name)
            self.tips_name:setFontSize(16)
        end

        --排行榜
        if self.parent.role_type == RoleConst.role_type.eMySelf then
            if self.rank_btn == nil then
                self.rank_btn = createRichLabel(18, cc.c3b(36, 144, 3), cc.p(0, 1), cc.p(256, 20))
                self.rank_btn:setString(string_format("<div href=xxx>%s</div>", TI18N("前往排行榜")))
                self.tips_panel:addChild(self.rank_btn)

                self.rank_btn:addTouchLinkListener(
                    function(type, value, sender, pos)
                        RankController:getInstance():openRankView(true, RankConstant.RankType.fans)
                    end,
                    {"click", "href"}
                )
            end
            if not self.init_rank_data then
                controller:send25802()
                self.init_rank_data = true
            end
        else
            if self.parent.other_data then
                --他人排行榜
                if self.parent.other_data.fans_rank and self.parent.other_data.fans_rank == 0 then
                    self.my_rank:setString(TI18N("他的排名:未上榜"))
                else
                    self.my_rank:setString(string_format(TI18N("他的排名:%s"), self.parent.other_data.fans_rank))
                end
            end
        end
    else
        self.tips_panel:setPositionX(-10000)
    end
end

function RolePersonalSpaceTabInfoPanel:updateMyRankInfo(data)
    if self.my_rank then
        if data.rank == 0 then
            self.my_rank:setString(TI18N("我的排名:未上榜"))
        else
            self.my_rank:setString(string_format(TI18N("我的排名:%s"), data.rank))
        end
    end
end

function RolePersonalSpaceTabInfoPanel:setVisibleStatus(bool)
    self:setVisible(bool)

    if bool then
        GlobalEvent:getInstance():Fire(RoleEvent.ROLE_PS_CHANGE_PANEL_EVENT)
        if not self.is_init then
            self:setData()
        end
    end
end

--移除
function RolePersonalSpaceTabInfoPanel:DeleteMe()
    if self.get_title_list_event then
        GlobalEvent:getInstance():UnBind(self.get_title_list_event)
        self.get_title_list_event = nil
    end

    if self.use_title_event then
        GlobalEvent:getInstance():UnBind(self.use_title_event)
        self.use_title_event = nil
    end

    if self.form_drama_event then
        GlobalEvent:getInstance():UnBind(self.form_drama_event)
        self.form_drama_event = nil
    end
    if self.role_fans_rank_event then
        GlobalEvent:getInstance():UnBind(self.role_fans_rank_event)
        self.role_fans_rank_event = nil
    end

    if self.All_Feedback_Event_Data then
        GlobalEvent:getInstance():UnBind(self.All_Feedback_Event_Data)
        self.All_Feedback_Event_Data = nil
    end

    if self.role_city_event then
        GlobalEvent:getInstance():UnBind(self.role_city_event)
        self.role_city_event = nil
    end
    if self.update_fun_form then
        GlobalEvent:getInstance():UnBind(self.update_fun_form)
        self.update_fun_form = nil
    end
    if self.role_follow_event then
        GlobalEvent:getInstance():UnBind(self.role_follow_event)
        self.role_follow_event = nil
    end

    if self.item_load_tips then
        self.item_load_tips:DeleteMe()
        self.item_load_tips = nil
    end
    if self.item_load_title then
        self.item_load_title:DeleteMe()
        self.item_load_title = nil
    end
    if self.item_load_title_img_res then
        self.item_load_title_img_res:DeleteMe()
        self.item_load_title_img_res = nil
    end

    if self.combobox_scrollview then
        self.combobox_scrollview:DeleteMe()
        self.combobox_scrollview = nil
    end

    if self.role_update_event and self.role_vo then
        self.role_update_event = self.role_vo:UnBind(self.role_update_event)
        self.role_update_event = nil
    end
end
