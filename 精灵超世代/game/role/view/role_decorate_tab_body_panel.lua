-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      冒险形象
-- <br/> 2019年8月16日
-- --------------------------------------------------------------------
RoleDecorateTabBodyPanel =
    class(
    "RoleDecorateTabBodyPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = RoleController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()

local table_sort = table.sort
local math_floor = math.floor

function RoleDecorateTabBodyPanel:ctor(parent)
    self:config()
    if setting then
        --配置的是物品id
        self.show_item_id = setting.id
    end
    self:layoutUI()
    self:registerEvents()
end

function RoleDecorateTabBodyPanel:config()
    -- self.size = cc.size(680,372.97)
    -- self:setContentSize(self.size)
end

function RoleDecorateTabBodyPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("roleinfo/role_decorate_tab_body_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")

    local tab_container = self.main_container:getChildByName("tab_container")

    self.tab_list = {}

    local tab_name = {
        [1] = TI18N("1~5星"),
        [2] = TI18N("6星"),
        [3] = TI18N("10星")
        --[4] = TI18N("皮肤"),
    }
    for i = 1, 4 do
        local tab_btn = {}
        local item = tab_container:getChildByName("tab_btn_" .. i)
        tab_btn.btn = item
        tab_btn.index = i
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.label = item:getChildByName("label")
        tab_btn.label:setString(tab_name[i] or "")
        tab_btn.label:setTextColor(Config.ColorData.data_new_color4[6])
        -- tab_btn.btn:setVisible(false)

        self.tab_list[i] = tab_btn
    end

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_btn_label:setString(TI18N("确定"))

    self.scrollCon = self.main_container:getChildByName("scrollCon")

    self.main_container:getChildByName("att_label"):setString(TI18N("形象属性"))
    self.main_container:getChildByName("lock_label"):setString(TI18N("解锁条件"))

    self.unlock = createRichLabel(18, 178, cc.p(0.5, 0.5), cc.p(448, 406), nil, nil, 240)
    self.main_container:addChild(self.unlock)
    self.unlock:setString(TI18N("当前形象已解锁"))
    self.unlock:setVisible(false)

    self.not_attr_tips = createRichLabel(18, 186, cc.p(0.5, 0.5), cc.p(448, 544), nil, nil, 240)
    self.main_container:addChild(self.not_attr_tips)
    self.not_attr_tips:setString(TI18N("当前形象无属性加成"))
    self.not_attr_tips:setVisible(false)

    self.attr_label_list = {}
    local pos = {
        [1] = cc.p(350, 544),
        [2] = cc.p(460, 544),
        [3] = cc.p(350, 510),
        [4] = cc.p(460, 510)
    }
    for i = 1, 4 do
        self.attr_label_list[i] = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0, 0), pos[i])
        self.main_container:addChild(self.attr_label_list[i])
        self.attr_label_list[i]:setString("")
        -- self.attr_label_list[i]:setVisible(false)
    end

    local pos_x = 325
    local pos_y = 421
    local pos_w = 570 --pos_x到最右边的位置
    self.term_list = {}
    self.term_status_list = {}
    for i = 1, 3 do
        local y = pos_y - 24 * ((i - 1) * 2)
        self.term_list[i] = createRichLabel(16, 175, cc.p(0, 0), cc.p(pos_x, y))
        self.term_status_list[i] =
            createRichLabel(16, Config.ColorData.data_new_color4[6], cc.p(1, 0), cc.p(pos_w, y - 24))
        self.main_container:addChild(self.term_list[i])
        self.main_container:addChild(self.term_status_list[i])
    end

    --申请形象信息
    controller:requestRoleModelInfo()
end

--事件
function RoleDecorateTabBodyPanel:registerEvents()
    registerButtonEventListener(
        self.comfirm_btn,
        function()
            self:onComfirmBtn()
        end,
        true,
        REGISTER_BUTTON_SOUND_BUTTON_TYPY
    )

    for index, tab_btn in ipairs(self.tab_list) do
        registerButtonEventListener(
            tab_btn.btn,
            function()
                self:changeTabType(index, true)
            end,
            false,
            1
        )
    end

    if not self.updateModelList then
        self.updateModelList =
            GlobalEvent:getInstance():Bind(
            RoleEvent.GetModelList,
            function(data)
                if data ~= nil then
                    self:setData(data)
                end
            end
        )
    end
    --更换
    if not self.updateModelEvent then
        self.updateModelEvent =
            GlobalEvent:getInstance():Bind(
            RoleEvent.UpdateModel,
            function(id)
                if not id then
                    return
                end
                if not self.dic_datas then
                    return
                end
                if self.dic_datas[id] == nil then
                    return
                end

                self.dic_datas[self.use_id].used = 0
                self.dic_datas[id].used = 1

                local index = self:checkIndexByConfig(self.dic_datas[id].vo)
                if self.dic_index_data[index] then
                    local sort_func = SortTools.tableCommonSorter({{"used", true}, {"show", false}, {"id", false}})
                    table_sort(self.dic_index_data[index], sort_func)
                end
                self.use_id = id
                if self.cur_tab_index == index then
                    self:updateList(index)
                end
            end
        )
    end
    --激活
    if not self.activeModelEvent then
        self.activeModelEvent =
            GlobalEvent:getInstance():Bind(
            RoleEvent.ActiveModel,
            function(id)
                if not id or self.dic_datas[id] == nil then
                    return
                end
                self.show_list[id] = true
                self.dic_datas[id].show = 2
                local cell_list = self.list_view:getActiveCellList()
                for i, cell in ipairs(cell_list) do
                    local vo = cell.vo
                    if vo then
                        if vo.id == id then
                            self:updateCellByIndex(cell, cell.index)
                        end
                    end
                end
                if self.select_item and self.select_item.vo and self.select_item.vo.id == id then
                    self.comfirm_btn_label:setString(TI18N("更 换"))
                end
            end
        )
    end
end

--确定
function RoleDecorateTabBodyPanel:onComfirmBtn()
    if not self.show_list then
        return
    end
    if self.select_item then
        local vo = self.select_item.vo
        if not vo then
            return
        end
        if self.show_list[vo.id] or next(vo.attr) == nil then
            if vo and vo.id == self.use_id then
                message(TI18N("该形象已在使用中"))
                return
            end
            controller:changeRoleModel(vo.id)
        else
            --未激活
            local hero_star = HeroController:getModel():getHadHeroStarBybid(vo.bid)
            local role_vo = RoleController:getInstance():getRoleVo()
            local lev = role_vo and role_vo.lev or 0
            --玩家等级
            if lev < vo.lev then
                message(TI18N("等级不足"))
                return
            end

            -- 星数
            if hero_star < vo.star then
                message(string_format(TI18N("%s未达到%s星"), vo.name, vo.star))
                return
            end

            if next(vo.expend) then
                local item_data = Config.ItemData.data_get_data(vo.expend[1][1])
                if item_data then
                    local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item_data.id)
                    if count < vo.expend[1][2] then
                        BackpackController:getInstance():openTipsSource(true, item_data)
                        return
                    end
                else
                    return
                end
            end
            --可激活了
            controller:activeRoleModel(vo.id)
        end
    end
end

function RoleDecorateTabBodyPanel:setData(scdata)
    self.use_id = scdata.use_id
    self.show_list = {}
    if scdata.list then
        for k, v in pairs(scdata.list) do
            self.show_list[v.id] = true
        end
    end
    local config = Config.LooksData.data_data
    if not config then
        return
    end
    self.dic_datas = {}
    self.dic_index_data = {}
    for i = 1, 4 do
        self.dic_index_data[i] = {}
    end
    local dic_skin_data = {}
    --使用的宝可梦所在索引
    local cur_index = 1
    for i, v in pairs(config) do
        local index = self:checkIndexByConfig(v)
        local data = {}
        data.vo = v
        data.id = v.id
        if self.show_list[v.id] then
            data.show = 2 --已激活
        else
            --保留可激活的逻辑 --
            local is_active = self:getIsActiveByConfig(v)
            if is_active then
                data.show = 1 --可激活(这个 1 下面有判断..要一起改)
            else
                data.show = 3 -- 未激活
            end
        end
        if self.use_id == v.id then
            cur_index = index
            data.used = 1
        else
            data.used = 0
        end
        if index == 4 then --皮肤页签
            if dic_skin_data[v.ico_id] == nil then
                dic_skin_data[v.ico_id] = {}
            end
            table_insert(dic_skin_data[v.ico_id], data)
        else
            table_insert(self.dic_index_data[index], data)
        end
        self.dic_datas[v.id] = data
    end

    --皮肤页签 只能显示一个选择最大已激活的data数据..如果都未激活拿第一个
    local is_have = false
    for k, list in pairs(dic_skin_data) do
        table_sort(
            list,
            function(a, b)
                return a.id < b.id
            end
        )
        local len = #list
        is_have = false
        for i = len, 1, -1 do
            local data = list[i]
            if data and data.show == 2 then --已激活
                is_have = true
                table_insert(self.dic_index_data[4], data)
                if data.vo.pre_id and self.use_id == data.vo.pre_id then
                    data.used = 1
                    self.use_id = data.vo.id
                end
                break
            end
        end
        if not is_have and list[1] then
            table_insert(self.dic_index_data[4], list[1])
        end
    end

    local sort_func = SortTools.tableCommonSorter({{"used", true}, {"show", false}, {"id", false}})
    for i = 1, 4 do
        table_sort(self.dic_index_data[i], sort_func)
    end

    self:changeTabType(cur_index)
end

--根据配置检查在那个索引
function RoleDecorateTabBodyPanel:checkIndexByConfig(config)
    if config then
        if config.skin_id and config.skin_id ~= 0 then
            return 4
        elseif config.star <= 5 then
            return 1
        elseif config.star >= 6 and config.star <= 9 then
            return 2
        else
            return 3
        end
    end
end

-- @_type 参考 HeroConst.MainInfoTab 定义
--@check_repeat_click 是否检查重复点击
function RoleDecorateTabBodyPanel:changeTabType(index, check_repeat_click)
    if not self.show_list then
        return
    end
    if check_repeat_click and self.cur_tab_index == index then
        return
    end
    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[6])
        self.cur_tab.select_bg:setVisible(false)
    end
    self.cur_tab_index = index
    self.cur_tab = self.tab_list[self.cur_tab_index]

    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.cur_tab.select_bg:setVisible(true)
    end

    self:updateList(index)
end

function RoleDecorateTabBodyPanel:updateList(index)
    if not index then
        return
    end
    if not self.scrollCon then
        return
    end
    if self.list_view == nil then
        local scroll_view_size = self.scrollCon:getContentSize()
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = 118,
            item_height = 130,
            row = 0,
            col = 5,
            need_dynamic = true
        }
        self.list_view =
            CommonScrollViewSingleLayout.new(
            self.scrollCon,
            cc.p(0, 0),
            ScrollViewDir.vertical,
            ScrollViewStartPos.top,
            scroll_view_size,
            list_setting,
            cc.p(0, 0)
        )

        self.list_view:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(
            handler(self, self.updateCellByIndex),
            ScrollViewFuncType.UpdateCellByIndex
        ) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self, self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.data_list = self.dic_index_data[index] or {}

    if self.show_item_id ~= nil then
        local is_have = false
        for i, data in ipairs(self.data_list) do
            if next(data.vo.expend) and v.expend[1][1] == self.show_item_id then
                is_have = true
                self.list_view:reloadData(i)
            end
        end
        if not is_have then
            self.list_view:reloadData(1)
        end
        self.show_item_id = nil
    else
        self.list_view:reloadData(1)
    end
end

--创建cell
--@width 是setting.item_width
--@height 是setting.item_height
function RoleDecorateTabBodyPanel:createNewCell(width, height)
    local cell = RoleBodyItem.new()
    cell:setTouchFunc(
        function()
            self:onCellTouched(cell)
        end
    )
    return cell
end
--获取数据数量
function RoleDecorateTabBodyPanel:numberOfCells()
    return #self.data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function RoleDecorateTabBodyPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.data_list[index]
    cell:setData(cell_data.vo, index)

    --设置解锁
    if self.show_list[cell_data.id] then
        cell:showLock(false)
    else
        cell:showLock(true)
    end

    -- --是否能激活
    if cell_data.show == 1 then
        cell:showActiveIcon(true)
    else
        cell:showActiveIcon(false)
    end

    --使用中
    if cell_data.used == 1 then
        cell:showUseIcon(true)
    else
        cell:showUseIcon(false)
    end

    if self.select_id and self.select_id == cell_data.id then
        cell:setSelected(true)
    else
        cell:setSelected(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function RoleDecorateTabBodyPanel:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.data_list[index]

    if self.select_item ~= nil then
        self.select_item:setSelected(false)
    end
    self.select_id = cell_data.id
    self.select_item = cell
    self.select_item:setSelected(true)
    self:updateMessage(cell_data.vo)
end

function RoleDecorateTabBodyPanel:updateMessage(vo)
    if not vo then
        return
    end

    local setAttr = function(attr_list)
        self.not_attr_tips:setVisible(false)
        if #attr_list <= 0 then
            self.not_attr_tips:setVisible(true)
        else
            for i, v in ipairs(self.attr_label_list) do
                -- local attr = vo.attr[i]
                local attr = attr_list[i]
                if attr ~= nil then
                    v:setVisible(true)
                    local name = Config.AttrData.data_key_to_name[attr[1]]
                    local is_per = PartnerCalculate.isShowPerByStr(attr[1])
                    if is_per then
                        v:setString(string_format("%s: %s%%", name, attr[2] / 10))
                    else
                        v:setString(string_format("%s: %s", name, attr[2]))
                    end
                else
                    v:setVisible(false)
                end
            end
        end
    end

    if vo.skin_id and vo.skin_id ~= 0 then --是皮肤
        local skin_config = Config.PartnerSkinData.data_skin_info[vo.skin_id]
        if skin_config then
            setAttr(skin_config.skin_attr)
        else
            self.not_attr_tips:setVisible(true)
        end
        self.comfirm_btn_label:setString(TI18N("更 换"))
    elseif next(vo.expend) then -- 需要激活
        if next(vo.attr) then
            setAttr(vo.attr)
        end
        --更改按钮
        if self.show_list[vo.id] then
            self.comfirm_btn_label:setString(TI18N("更 换"))
        else
            self.comfirm_btn_label:setString(TI18N("激 活"))
        end
    else
        self.not_attr_tips:setVisible(true)
        for i, v in ipairs(self.attr_label_list) do
            v:setVisible(false)
        end
        self.comfirm_btn_label:setString(TI18N("更 换"))
    end
    local hero_star = HeroController:getModel():getHadHeroStarBybid(vo.partner_id)
    --解锁条件
    if vo.id ~= self.use_id then --不在使用中
        if self.select_item:getIsLock() then
            self.unlock:setVisible(false)
            local str_list = {}
            local str_status_list = {}
            local index = 1

            if vo.skin_id and vo.skin_id ~= 0 then --有皮肤
                str_list[index] = string_format(TI18N("解锁皮肤%s"), vo.name)
                local is_unlock = HeroController:getModel():isUnlockHeroSkin(vo.skin_id)
                if is_unlock then
                    str_status_list[index] = TI18N("<div fontcolor=#249003>已达成</div>")
                else
                    str_status_list[index] = TI18N("<div fontcolor=#d95014>未达成</div>")
                end
                index = index + 1
                local partner_config = Config.PartnerData.data_partner_base[vo.partner_id]
                --星数
                if vo.star > 0 then
                    local name
                    if partner_config then
                        name = partner_config.name
                    else
                        name = vo.name
                    end

                    str_list[index] = string_format(TI18N("%s达到%s星"), name, vo.star)
                    if hero_star >= vo.star then
                        str_status_list[index] = TI18N("<div fontcolor=#249003>已达成</div>")
                    else
                        str_status_list[index] = TI18N("<div fontcolor=#d95014>未达成</div>")
                    end
                    index = index + 1
                end
            else
                --星数
                if vo.star > 0 then
                    str_list[index] = string_format(TI18N("%s达到%s星"), vo.name, vo.star)

                    if hero_star >= vo.star then
                        str_status_list[index] = TI18N("<div fontcolor=#249003>已达成</div>")
                    else
                        str_status_list[index] = TI18N("<div fontcolor=#d95014>未达成</div>")
                    end
                    index = index + 1
                end
                --玩家等级
                if vo.lev > 0 then
                    str_list[index] = string_format(TI18N("玩家等级达到%s"), vo.lev)

                    local role_vo = RoleController:getInstance():getRoleVo()
                    local lev = role_vo and role_vo.lev or 0
                    if lev >= vo.lev then
                        str_status_list[index] = TI18N("<div fontcolor=#249003>已达成</div>")
                    else
                        str_status_list[index] = TI18N("<div fontcolor=#d95014>未达成</div>")
                    end
                    index = index + 1
                end
            end
            --需求物品
            if next(vo.expend) then
                local item_data = Config.ItemData.data_get_data(vo.expend[1][1])
                if item_data then
                    local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item_data.id)
                    str_list[index] = string_format(TI18N("拥有%s个%s"), vo.expend[1][2], item_data.name)

                    if count >= vo.expend[1][2] then
                        str_status_list[index] = TI18N("<div fontcolor=#249003>已达成</div>")
                    else
                        str_status_list[index] = TI18N("<div fontcolor=#d95014>未达成</div>")
                    end
                    index = index + 1
                end
            end

            for i, v in ipairs(self.term_list) do
                if str_list[i] then
                    v:setVisible(true)
                    self.term_status_list[i]:setVisible(true)
                    v:setString(str_list[i])
                    self.term_status_list[i]:setString(str_status_list[i])
                else
                    v:setVisible(false)
                    self.term_status_list[i]:setVisible(false)
                end
            end
        else
            for i, v in ipairs(self.term_list) do
                v:setVisible(false)
            end
            for i, v in ipairs(self.term_status_list) do
                v:setVisible(false)
            end
            self.unlock:setVisible(true)
        end
    else --使用中
        for i, v in ipairs(self.term_list) do
            v:setVisible(false)
        end
        for i, v in ipairs(self.term_status_list) do
            v:setVisible(false)
        end
        self.unlock:setVisible(true)
    end
    self:updateSpine(vo)
end

--改变模型
function RoleDecorateTabBodyPanel:updateSpine(vo)
    if self.record_id and self.record_id == vo.id then
        return
    end
    self.record_id = vo.id
    local fun = function()
        if not self.spine then
            self.spine = BaseRole.new(BaseRole.type.role, vo.id, nil)
            self.spine:setAnimation(0, PlayerAction.show, true)
            self.spine:setCascade(true)
            self.spine:setPosition(cc.p(150, 484))
            self.spine:setAnchorPoint(cc.p(0.5, 0))
            -- self.spine:setScale(0.8)
            self.main_container:addChild(self.spine)
            self.spine:setCascade(true)
            self.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(cc.Sequence:create(action))
        end
    end
    if self.spine then
        -- end)))
        self.spine:setCascade(true)
        --如果有快速切换 不要这个延迟
        -- local action = cc.FadeOut:create(0.2)
        -- self.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
        doStopAllActions(self.spine)
        self.spine:removeFromParent()
        self.spine = nil
        fun()
    else
        fun()
    end
end

--根据配置能否激活
function RoleDecorateTabBodyPanel:getIsActiveByConfig(vo)
    if vo.skin_id and vo.skin_id ~= 0 then
        --皮肤没有激活的
        return false
    end
    local is_star = true
    --星数
    if vo.star > 0 then
        local hero_star = HeroController:getModel():getHadHeroStarBybid(vo.bid)
        if hero_star < vo.star then
            is_star = false
        end
    end

    local is_lev = true
    --玩家等级
    if vo.lev > 0 then
        local role_vo = RoleController:getInstance():getRoleVo()
        local lev = role_vo and role_vo.lev or 0
        if lev < vo.lev then
            is_lev = false
        end
    end

    local is_item = true
    --需求物品
    if next(vo.expend) then
        local item_data = Config.ItemData.data_get_data(vo.expend[1][1])
        if item_data then
            local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item_data.id)
            if count < vo.expend[1][2] then
                is_item = false
            end
        end
    else
        is_item = false
    end
    local is_active = is_item and is_lev and is_star

    return is_active, is_star, is_lev, is_item
end

function RoleDecorateTabBodyPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function RoleDecorateTabBodyPanel:DeleteMe()
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    if self.item_list then
        for k, v in pairs(self.item_list) do
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.item_list = nil

    if self.updateModelList then
        self.updateModelList = GlobalEvent:getInstance():UnBind(self.updateModelList)
        self.updateModelList = nil
    end

    if self.updateModelEvent then
        self.updateModelEvent = GlobalEvent:getInstance():UnBind(self.updateModelEvent)
        self.updateModelEvent = nil
    end
    if self.activeModelEvent then
        self.activeModelEvent = GlobalEvent:getInstance():UnBind(self.activeModelEvent)
        self.activeModelEvent = nil
    end
end

-- --------------------------------------------------------------------
-- 头像框子项
--
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RoleBodyItem =
    class(
    "RoleBodyItem",
    function()
        return ccui.Widget:create()
    end
)

function RoleBodyItem:ctor(index)
    self.width = 85
    self.height = 85
    self.is_lock = false
    self.is_use = false
    self.is_can_active = false

    self:setContentSize(cc.size(self.width, self.height))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:configUI()
end

function RoleBodyItem:setTouchFunc(value)
    self.call_fun = value
end
--[[
@功能:创建视图
@参数:
@返回值:
]]
function RoleBodyItem:configUI()
    --底内框
    self.back = ccui.Widget:create()
    self.back:setCascadeOpacityEnabled(true)
    self.back:setContentSize(cc.size(100, 100))
    self.back:setAnchorPoint(cc.p(0, 0))
    self.back:setTouchEnabled(true)
    self:addChild(self.back)

    self.back:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                if self.call_fun then
                    self:call_fun(self.vo)
                end
            end
        end
    )

    self.player_head = PlayerHead.new(PlayerHead.type.circle)
    self.player_head:setAnchorPoint(cc.p(0.5, 0.5))
    self.player_head:setPosition(cc.p(self.width / 2, 55))
    self.player_head:setScale(0.8)
    self.player_head:setTouchEnabled(false)
    self:addChild(self.player_head)

    --选择框
    self.select = ccui.ImageView:create(PathTool.getResFrame("common", "common_1060"), LOADTEXT_TYPE_PLIST)
    self.select:setAnchorPoint(cc.p(0.5, 0.5))
    self.select:setPosition(cc.p(self.width / 2, 55))
    self.select:setScale(0.8)
    self.select:setVisible(false)
    self:addChild(self.select)
    self.name =
        createLabel(20, Config.ColorData.data_new_color4[6], nil, self.width / 2, -25, "name", self, 0, cc.p(0.5, 0))

    self:showLock(true)
end

--[[
@功能:设置数据
@参数:
@返回值:
]]
function RoleBodyItem:setData(data)
    self.vo = data
    if data.skin_id and data.skin_id ~= 0 then
        local skin_config = Config.PartnerSkinData.data_skin_info[data.skin_id]
        if skin_config then
            self.player_head:setHeadRes(skin_config.head_id)
        end
    else
        self.player_head:setHeadRes(data.partner_id)
    end
    self.name:setString(data.name)
end
function RoleBodyItem:setSelected(bool)
    self.select:setVisible(bool)
    if bool == true then
        local fadein = cc.FadeIn:create(0.7)
        local fadeout = cc.FadeOut:create(0.7)
        self.select:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein, fadeout)))
    else
        doStopAllActions(self.select)
    end
end
--锁定 激活
function RoleBodyItem:showLock(bool)
    setChildUnEnabled(bool, self.player_head)
    self.is_lock = bool
end

--使用中
function RoleBodyItem:showUseIcon(bool)
    self.is_use = bool
    if not self.use_icon and bool == false then
        return
    end
    if not self.use_icon then
        local res = PathTool.getTargetRes("face/txt_face","txt_face_use",false)
        self.use_icon = createImage(self, res, 60, 25, cc.p(0.5, 0.5), false, 1, false)
    end
    self.use_icon:setVisible(bool)
end

function RoleBodyItem:showActiveIcon(bool)
    if bool and not self.active_icon then
        local res = PathTool.getResFrame("common", "txt_cn_common_30017")
        self.active_icon = createImage(self, res, 60, 25, cc.p(0.5, 0.5), true, 1, false)
        self.active_icon:setScale(0.7)
    end
    if self.active_icon then
        self.active_icon:setVisible(bool)
    end
end

function RoleBodyItem:getData()
    return self.vo
end
function RoleBodyItem:getIsLock()
    return self.is_lock
end

function RoleBodyItem:DeleteMe()
    if self.player_head then
        self.player_head:DeleteMe()
    end
    self:removeAllChildren()
    self:removeFromParent()
    self.vo = nil
end
