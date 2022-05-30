-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      荣誉墙
-- <br/> 2019年5月30日
-- --------------------------------------------------------------------
RolePersonalSpaceTabHonorWallPanel = class("RolePersonalSpaceTabHonorWallPanel", function()
    return ccui.Widget:create()
end)

local controller = RoleController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local math_floor = math.floor

function RolePersonalSpaceTabHonorWallPanel:ctor(parent)
    self.parent = parent
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:config()
    self:loadResources()
end

function RolePersonalSpaceTabHonorWallPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("rolehonorwall","rolehonorwall"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        if tolua.isnull(self) then return end
        self:layoutUI()
        self:registerEvents()
        self.is_load_completed = true
        if self.visible_status then
            self:setVisibleStatus(true)
        end
    end)
end

function RolePersonalSpaceTabHonorWallPanel:setVisibleStatus(bool)
    if not self.role_vo then return end
    if not self.parent then return end

    self.visible_status = bool or false 
    self:setVisible(bool)
    
    if bool and self.is_load_completed then
        GlobalEvent:getInstance():Fire(RoleEvent.ROLE_PS_CHANGE_PANEL_EVENT)
        if not self.is_init then
            if self.parent.role_type == RoleConst.role_type.eMySelf then
                controller:send25806(self.role_vo.rid, self.role_vo.srv_id)
            else
                if self.parent.other_data then
                    controller:send25806(self.parent.other_data.rid, self.parent.other_data.srv_id)
                end
            end
        end
    end
end


function RolePersonalSpaceTabHonorWallPanel:config()

end

function RolePersonalSpaceTabHonorWallPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("roleinfo/role_personal_space_tab_honor_wall_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.title_img = self.main_container:getChildByName("title_img")

     -- 标题
    local res = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "role_honor_wall_bg", false)
    if self.record_title_img_res == nil or self.record_title_img_res ~= res then
        self.record_title_img_res = res
        self.item_load_title_img_res = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load_title_img_res) 
    end 

    --进度条
    self.progress_node = self.main_container:getChildByName("progress_node")
    --荣誉icon
    self.honor_btn = self.main_container:getChildByName("honor_btn")
    self.honor_icon = self.honor_btn:getChildByName("honor_icon")
    self.honor_count = self.main_container:getChildByName("honor_count")
    self.honor_name = self.main_container:getChildByName("honor_name")
    self.reward_count = self.main_container:getChildByName("reward_count")
    self.reward_per = self.main_container:getChildByName("reward_per")

    --分享按钮
    self.share_btn = self.main_container:getChildByName("share_btn")
    self.share_btn:getChildByName("label"):setString(TI18N("分享"))

    --展示设置
    self.show_set_btn = self.main_container:getChildByName("show_set_btn")
    self.show_label = self.show_set_btn:getChildByName("label")
    self.show_label:setString(TI18N("展示设置"))
    setLabelAutoScale(self.show_label,self.show_set_btn,20)

    --列表
    self.lay_srollview = self.main_container:getChildByName("lay_srollview")
end

--事件
function RolePersonalSpaceTabHonorWallPanel:registerEvents()
    registerButtonEventListener(self.share_btn, function(param, sender) self:onShareBtn(sender)  end ,true, 1)
    registerButtonEventListener(self.show_set_btn, function() self:onShowSetBtn()  end ,true, 1)
    registerButtonEventListener(self.honor_btn, function() self:onHonorBtn()  end ,true, 1)



    if self.get_honor_wall_event == nil then
        self.get_honor_wall_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_GET_HONOR_WALL_EVENT,function (data)
            if not data then return end
            self.is_init = true
            self:setData(data)
        end)
    end

    if self.update_honor_wall_event == nil then
        self.update_honor_wall_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_UPDATE_HONOR_WALL_EVENT,function (data)
            if not data then return end
            if self.dic_use_honor_icon_list then
                if data.id == 0 then
                    self.dic_use_honor_icon_list[data.pos] = nil
                else
                    self.dic_use_honor_icon_list[data.pos] = {pos = data.pos, id = data.id}
                end
            end
            
        end)
    end


end

--点击荣誉等级
function RolePersonalSpaceTabHonorWallPanel:onHonorBtn()
    if not self.scdata then return end

    if self.parent.role_type == RoleConst.role_type.eMySelf then
        local setting = {}
        local point = self.scdata.point or 0
        setting.point = point
        setting.num = self.active_count
        setting.role_data = self.role_vo
        setting.show_type = RoleConst.role_type.eMySelf

        local _, _, max = model:getHonorPointName(point)
        if max == -1 then
            TipsController:getInstance():openHonorLevelTips(true, setting)
        else
            TipsController:getInstance():openHonorNextLevelTips(true, setting)
        end
    else
        local setting = {}
        local point = self.scdata.point or 0
        setting.point = point
        setting.num = self.active_count
        setting.role_data = self.parent.other_data
        setting.show_type = RoleConst.role_type.eOther
        setting.is_hide_btn_label = true
        TipsController:getInstance():openHonorLevelTips(true, setting)
    end
end

--分享
function RolePersonalSpaceTabHonorWallPanel:onShareBtn(sender)
    if not self.scdata then return end
    local setting = {}
    setting.world_pos = sender:convertToWorldSpace(cc.p(0.5, 0.5))
    setting.callback = function(share_type) 
        if tolua.isnull(self) then return end
        self:shareCallback(share_type) 
    end
    TaskController:getInstance():openTaskSharePanel(true, setting)
end

function RolePersonalSpaceTabHonorWallPanel:shareCallback(share_type)
    if not self.scdata then return end
    if share_type == VedioConst.Share_Btn_Type.eWorldBtn then --分享到世界
        controller:send25819(ChatConst.Channel.World)
    elseif share_type == VedioConst.Share_Btn_Type.eGuildBtn then --分享公会
        controller:send25819(ChatConst.Channel.Gang)
    elseif share_type == VedioConst.Share_Btn_Type.eCrossBtn then --跨服分享
        controller:send25819(ChatConst.Channel.Cross)
    end
end


--展示设置
function RolePersonalSpaceTabHonorWallPanel:onShowSetBtn()
    if not self.role_vo then return end
    if not self.parent then return end
    if self.parent.role_type == RoleConst.role_type.eMySelf and self.dic_use_honor_icon_list then
        local setting = {}
        setting.use_honor_icon_list = deepCopy(self.dic_use_honor_icon_list)
        setting.active_list = self.active_list
        controller:openRoleSelectHonorListPanel(true, setting)
    end
end


--初始化数据
function RolePersonalSpaceTabHonorWallPanel:initdata()
    if not self.scdata then return end
    local config_list = Config.RoomFeatData.data_honor_icon_info
    if not config_list then return end

    local total_count = #Config.RoomFeatData.data_show_list[0]

    local dic_type_list = {}
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        --自己的
        local dic_honor = {}
        for i,v in ipairs(self.scdata.honor_badges) do
            dic_honor[v.id] = v
        end

        --已经在使用的荣誉icon数据
        self.dic_use_honor_icon_list = {}
        self.active_list = {}
        for i,v in ipairs(self.scdata.use_badges) do
            if dic_honor[v.id] then
                self.dic_use_honor_icon_list[v.pos] = v
                self.dic_use_honor_icon_list[v.pos].time = dic_honor[v.id].time or 0
            end
        end
        --不隐藏的激活数量
        local act_count = 0
        --隐藏的激活数量
        local hide_act_count = 0
        for id,config in pairs(config_list) do
            local data
            if dic_honor[id] then --激活
                dic_honor[id].lock = 0
                dic_honor[id].config = config
                data = dic_honor[id]
                if config.is_show == 1 then
                    hide_act_count = hide_act_count + 1
                else
                    act_count = act_count + 1
                end
                table_insert(self.active_list, data)
            else --未激活
                data = {}
                data.id = id
                data.lock = 1
                data.config = config
            end

            if dic_type_list[config.type_id] == nil then
                dic_type_list[config.type_id] = {}
            end
            --如果未激活 并且定义为隐藏的.则这里不显示
            if (data.lock == 1 and config.is_show ~= 1) or data.lock == 0 then
                table_insert(dic_type_list[config.type_id], data)
            end
        end
        self.active_count = act_count +  hide_act_count
        self.total_count = total_count + hide_act_count

    else
        --不隐藏的激活数量
        local act_count = 0
        --隐藏的激活数量
        local hide_act_count = 0

        --他人的 只显示已激活的
        for i,v in ipairs(self.scdata.honor_badges) do
            local config = config_list[v.id]
            if config then
                v.config = config
                v.lock = 0
                if dic_type_list[config.type_id] == nil then
                    dic_type_list[config.type_id] = {}
                end
                if config.is_show == 1 then
                    hide_act_count = hide_act_count + 1
                else
                    act_count = act_count + 1
                end
                table_insert(dic_type_list[config.type_id], v)
            end
        end
        self.active_count = act_count +  hide_act_count
        self.total_count = total_count + hide_act_count
    end 
    self.show_list = {}
    for type_id, list in pairs(dic_type_list) do
        table_sort(list, function(a, b) return a.id < b.id end)
        local count = #list 
        if count > 0 then
            local row = math_floor((count-1)/4) + 1
            for i=1,row do
                local show_data = {}
                show_data.type_id = type_id
                show_data.sort_index = i
                show_data.honor_item_list = {}
                show_data.honor_item_list[1] = list[(i - 1) * 4 + 1]
                show_data.honor_item_list[2] = list[(i - 1) * 4 + 2]
                show_data.honor_item_list[3] = list[(i - 1) * 4 + 3]
                show_data.honor_item_list[4] = list[(i - 1) * 4 + 4]

                if list[i] then
                    if i == 1 then
                        show_data.title_name = list[i].config.type_name
                    end
                    table_insert(self.show_list, show_data)
                end
            end
        end
    end
    local sort_func = SortTools.tableCommonSorter({{"type_id", false}, {"sort_index", false}})
    table_sort(self.show_list, sort_func)
    if #self.show_list < 4 then
        for i=1,4 do
            if self.show_list[i] == nil then
                self.show_list[i] = {}
                self.show_list[i].honor_item_list = {}
            end
        end
    end
end

function RolePersonalSpaceTabHonorWallPanel:setData(scdata)
    self.scdata = scdata
    self:initdata()
    if not self.role_vo then return end
    if not self.parent then return end

    local point = self.scdata.point or 0
    self.honor_count:setString(point)
    local name, res_id = model:getHonorPointName(point)
    self.honor_name:setFontSize(16)
    self.honor_name:setString(name or "")

    --荣誉icon res_id
    res_id = res_id or 1
    local res = PathTool.getPlistImgForDownLoad("rolehonorwall/honorwarllicon", "honor_level_"..res_id, false)
    if self.record_honor_icon_res == nil or self.record_honor_icon_res ~= res then
        self.record_honor_icon_res = res
        self.item_load_honor_icon = loadSpriteTextureFromCDN(self.honor_icon, res, ResourcesType.single, self.item_load_honor_icon) 
    end


    local active_count = self.active_count or 0
    local total_count = self.total_count or 0

    self.reward_count:setString(active_count)
    if total_count == 0 then
        self.reward_per:setString("0%")
        self:showProgress(true, 0, "0/0")
    else
        local per = math.floor(active_count * 100/total_count)
        local str = string_format("%s/%s",active_count, total_count)
        self.reward_per:setString(per.."%")
        self:showProgress(true, per, str)
    end
    
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        
    else
        self.share_btn:setVisible(false)
        self.show_set_btn:setVisible(false)
    end

    self:updateHonorItemlist()
end

--进度条
function RolePersonalSpaceTabHonorWallPanel:showProgress(status, percent, label)
    if status then
        if self.comp_bar == nil then
            local size = cc.size(315, 19)
            local res = PathTool.getResFrame("common","common_90005")
            local res1 = PathTool.getResFrame("common","common_90006")
            local bg,comp_bar = createLoadingBar(res, res1, size, self.progress_node, cc.p(0.5,0.5), 0, 0, true, true)
            self.comp_bar_bg = bg
            self.comp_bar = comp_bar
        else
            self.comp_bar_bg:setVisible(true)
        end

        if not self.comp_bar_label then
            local size = cc.size(315, 19)
            local text_color = cc.c3b(255,255,255)
            local line_color = cc.c3b(0,0,0)
            self.comp_bar_label = createLabel(16, text_color, line_color, size.width/2, size.height/2, "", self.comp_bar, 2, cc.p(0.5, 0.5))
        end

        self.comp_bar:setPercent(percent)
        self.comp_bar_label:setString(label)  
    else
        if self.comp_bar_bg then
            self.comp_bar_bg:setVisible(false)
        end
    end
end


--列表
function RolePersonalSpaceTabHonorWallPanel:updateHonorItemlist()
    if not self.show_list then return end
    if self.scrollview_list == nil then
        local scrollview_size = self.lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 567,                -- 单元的尺寸width
            item_height = 182,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.scrollview_list:reloadData()

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true)
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function RolePersonalSpaceTabHonorWallPanel:createNewCell(width, height)
    local cell = RoleHonorWallItem.new(width, height, self.parent)
    return cell
end

--获取数据数量
function RolePersonalSpaceTabHonorWallPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function RolePersonalSpaceTabHonorWallPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setData(data)
end

--点击cell .需要在 createNewCell 设置点击事件
function RolePersonalSpaceTabHonorWallPanel:setCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end
end

--移除
function RolePersonalSpaceTabHonorWallPanel:DeleteMe()
    if self.get_honor_wall_event then
        GlobalEvent:getInstance():UnBind(self.get_honor_wall_event)
        self.get_honor_wall_event = nil
    end
    if self.update_honor_wall_event then
        GlobalEvent:getInstance():UnBind(self.update_honor_wall_event)
        self.update_honor_wall_event = nil
    end

    if self.item_load_honor_icon then
        self.item_load_honor_icon:DeleteMe()
        item_load_honor_icon = nil
    end

    if self.item_load_title_img_res then
        self.item_load_title_img_res:DeleteMe()
        item_load_title_img_res = nil
    end
    self.role_vo = nil
end


-- 子项
RoleHonorWallItem = class("RoleHonorWallItem", function()
    return ccui.Widget:create()
end)

function RoleHonorWallItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function RoleHonorWallItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("roleinfo/role_honor_wall_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    --self.title_img = self.main_container:getChildByName("title_img")
    self.title_name = self.main_container:getChildByName("title_name")

    self.item_load_list = {}
    self.item_list = {}
    for i=1,4 do
        local item_bg = self.main_container:getChildByName("item_bg_"..i)
        self.item_list[i] = {}
        self.item_list[i].item_btn = item_bg
        self.item_list[i].item_btn:setSwallowTouches(false)
        local item_node = item_bg:getChildByName("item_node")
        self.item_list[i].honor_item = RoleHonorItem.new(1)
        item_node:addChild(self.item_list[i].honor_item)
        self.item_list[i].lock_img = item_bg:getChildByName("lock_img")
        self.item_list[i].honor_name = item_bg:getChildByName("honor_name")
     end 
end

function RoleHonorWallItem:register_event( )
    for i,v in ipairs(self.item_list) do
        registerButtonEventListener(v.item_btn, function() self:onClickItemBtn(i) end, false, 1, nil, nil, nil, true)
    end
end

--点击了某个荣誉
function RoleHonorWallItem:onClickItemBtn(index)
    if not self.data then return end
    if self.data.honor_item_list[index] ~= nil then
        local setting = {}
        if self.parent.role_type == RoleConst.role_type.eMySelf then
            setting.config = self.data.honor_item_list[index].config
            setting.have_time = self.data.honor_item_list[index].time
        else
            setting.config = self.data.honor_item_list[index].config
            setting.show_type = RoleConst.role_type.eOther
            if self.parent.other_data then
                setting.have_name = self.parent.other_data.name
            end
            setting.have_time = self.data.honor_item_list[index].time
        end
        TipsController:getInstance():openHonorIconTips(true, setting)
    end
end


function RoleHonorWallItem:setData(data)
    self.data = data
    if data.title_name then
        --self.title_img:setVisible(true)
        self.title_name:setVisible(true)
        self.title_name:setString(data.title_name)
        -- self.title_name:setFontSize(20)
    else
        --self.title_img:setVisible(false)
        self.title_name:setVisible(false)
    end


    local honor_item_list = data.honor_item_list or {}
    for i,v in ipairs(self.item_list) do
        local honor_data = honor_item_list[i]
        if honor_data then
            v.honor_name:setVisible(true)
            v.honor_name:setString(honor_data.config.name)
            v.honor_name:setFontSize(16)

            v.honor_item:setVisible(true)
            v.honor_item:setData(honor_data)

            if honor_data.lock == 1 then
                v.lock_img:setVisible(true)
                v.honor_item:setIconUnEnabled(true)
                v.honor_item:setShowEffect(false)
            else
                v.lock_img:setVisible(false)
                v.honor_item:setIconUnEnabled(false)
                v.honor_item:setShowEffect(true)
            end
        else
            v.honor_name:setVisible(false)
            v.honor_item:setVisible(false)
            v.lock_img:setVisible(false)
        end
    end
end

function RoleHonorWallItem:DeleteMe()
    if self.item_list then
        for i,item in ipairs(self.item_list) do
            item.honor_item:DeleteMe()
        end
        self.item_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end

