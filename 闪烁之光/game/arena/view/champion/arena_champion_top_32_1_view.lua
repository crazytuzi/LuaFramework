-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      32强赛中的第一个标签内容,及时集齐4组32强列表的
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionTop321View = class("ArenaChampionTop321View", function()
	return ccui.Layout:create()
end)

local table_sort = table.sort
local table_insert = table.insert

function ArenaChampionTop321View:ctor(view_type)
	self.tab_list = {}
    self.video_group = 0
    self.video_pos = 0
	self.size = cc.size(720,778)
	self:setContentSize(self.size)

    self.view_type = view_type or ArenaConst.champion_type.normal
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl = ArenaController:getInstance()
        self.model = self.ctrl:getChampionModel()
    else
        self.ctrl = CrosschampionController:getInstance()
        self.model = self.ctrl:getModel()
    end

    self.notice_label = createLabel(22, cc.c4b(0xff,0x8d,0x55,0xff), 2, 360, 778, "", self, nil, cc.p(0.5,0))
end

function ArenaChampionTop321View:addToParent(status)
    self:setVisible(status)
    self:handleEvent(status)
end

function ArenaChampionTop321View:handleEvent(status)
    if status == false then
        if self.update_top32_info_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_top32_info_event)
            self.update_top32_info_event = nil
        end
        if self.update_324_guess_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_324_guess_event)
            self.update_324_guess_event = nil
        end
    else
        if self.update_top32_info_event == nil then
            self.update_top32_info_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateTop32InfoEvent, function(list) 
                self:updateTop32InfoList(list)
            end)
        end

        if self.update_324_guess_event == nil then
            self.update_324_guess_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateTop324GuessGroupEvent, function(group,pos)
                self.video_group = group
                self.video_pos = pos
                if group == 0 or pos == 0 then return end

                local panel = self.tab_list[group]
                if panel and panel.updateGuessStatus then
                    panel:updateGuessStatus(true, pos)
                end
            end)
        end
    end
end

function ArenaChampionTop321View:updateCheckStatus(cur_page)
    self.notice_label:setString(ArenaConst.getGroup(cur_page))
    if self.video_group == 0 or self.video_pos == 0 then return end
    if self.video_group and self.video_group == cur_page and self.video_pos then
        local panel = self.tab_list[cur_page]
        if panel then
            panel:updateGuessStatus(true, self.video_pos)
        end
    end
end

function ArenaChampionTop321View:updateInfo(status)
    local base_info = self.model:getBaseInfo()
    local role_info = self.model:getRoleInfo()
    if base_info == nil or role_info == nil then return end
    self.is_change_tab = status
    if status == true or base_info.flag ~= 0 then
        if self.view_type == ArenaConst.champion_type.normal then
            self.ctrl:requestTop32Info()
        else
            self.ctrl:sender26209()
        end
    end
end

--==============================--
--desc:更新32强数据,可能是已经创建了,也可能还未创建
--time:2018-08-06 10:07:49
--@data:
--@return 
--==============================--
function ArenaChampionTop321View:updateTop32InfoList(list)
    if list == nil then return end
    -- 这里做一个排序
    table_sort( list, function(a, b) 
        return a.group < b.group
    end)
    -- 保存pageview的当前数据
    self.page_view_list = list 
    if self.page_view == nil then
        if self.page_view == nil then
            local tot_page = 4
            if self.view_type == ArenaConst.champion_type.cross then
                tot_page = 8
            end
            self.page_view = CustomPageView.new(self.size, true, false, 0, 0, tot_page)
            self:addChild(self.page_view)
            self.page_view.per_page = 1

            -- 不能用参数的数据做处理,因为后面2页可能没切换的时候还是旧数据,当切换的时候不能用旧数据做处理
            local function createPage(data_list, page, layout)
                page = page or 1
                local item = ArenaChampionTop32Item.new()
                local temp_data = self.page_view_list[page]
                item:setData(temp_data)
                layout:addChild(item)
                table_insert(self.tab_list, item)
            end
            local function turnPage(cur_page, page_sum)
                self:updateCheckStatus(cur_page)
            end
            self.page_view:addCreatePageCallBack(createPage)
            self.page_view:addTurnCallBack(turnPage)
            self.page_view:setViewData(list)
        end
    else
        for i, panel in ipairs(self.tab_list) do
            panel:setData(list[i])
        end
    end
    --同步请求一下竞猜位置信息
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl:requestGuessGroupInfo()
    else
        self.ctrl:sender26211()
    end
end

function ArenaChampionTop321View:DeleteMe()
    self:handleEvent(false)
    for k, panel in pairs(self.tab_list) do
        panel:DeleteMe()
    end
    self.tab_list = nil

    if self.page_view then
        self.page_view:dispose()
    end
    self.page_view = nil
end 



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      32强赛分页内容
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionTop32Item = class("ArenaChampionTop32Item", function()
	return ccui.Layout:create()
end)

function ArenaChampionTop32Item:ctor()	
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_champion_top_32_item"))
	
	self.size = self.root_wnd:getContentSize()
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
	local container = self.root_wnd:getChildByName("container")

    -- 找出属于每一个位置的线
    self.pos_line_list = {}
    for i=1, 12 do
        local pos_line = container:getChildByName("pos_line_"..i)
        if pos_line then
            local normal_1 = pos_line:getChildByName("normal_1")
            local normal_2 = pos_line:getChildByName("normal_2")
            local select_1 = pos_line:getChildByName("select_1")
            local select_2 = pos_line:getChildByName("select_2")
            local object = {}
            object.normal_1 = normal_1
            object.normal_2 = normal_2
            object.select_1 = select_1
            object.select_2 = select_2
            select_1:setVisible(false)
            select_2:setVisible(false)
            self.pos_line_list[i] = object
        end
    end

    -- 找出共同线
    self.pos_line_list_2 = {}
    self.check_btn_list = {}
    for i=1,7 do
        local _index_1 = (i - 1) * 2 + 1
        local _index_2 = i * 2
        local pos_line = container:getChildByName(string.format("pos_line_%s_%s", _index_1, _index_2))
        if pos_line then
            local normal = pos_line:getChildByName("normal")
            local select = pos_line:getChildByName("select")
            local object = {}
            object.normal = normal
            object.select = select
            select:setVisible(false)
            self.pos_line_list_2[getNorKey(_index_1, _index_2)] = object
        end

        local check_btn = container:getChildByName("check_btn_".._index_1)
        if check_btn then
            self.check_btn_list[_index_1] = check_btn
            check_btn:setVisible(false)
        end
    end

    -- 找出当前位角色底图和名字
    self.role_pos_list = {}
    self.role_name_list = {}
    for i=1,14 do
        local role_pos = container:getChildByName("role_pos_"..i)
        if role_pos then
            local normal = role_pos:getChildByName("normal")
            local select = role_pos:getChildByName("select")
            local object = {}
            object.normal = normal
            object.select = select
            select:setVisible(false)
            self.role_pos_list[i] = object
        end
        -- 角色名字
        local role_name = container:getChildByName("role_name_"..i)
        if role_name then
            self.role_name_list[i] = role_name
            role_name:setString("")
        end
    end

    self.guess_btn = container:getChildByName("guess_btn")
    self.guess_btn:getChildByName("label"):setString(TI18N("竞猜"))
    self.guess_btn:setVisible(false)
    self:registerEvent()
end

function ArenaChampionTop32Item:registerEvent()
    for k,check_btn in pairs(self.check_btn_list) do
        check_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.data then
                    GlobalEvent:getInstance():Fire(ArenaEvent.CheckFightInfoEvent, true, self.data.group, k) 
                end
            end
        end)
    end
    self.guess_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            GlobalEvent:getInstance():Fire(ArenaEvent.ChangeTanFromTop324)
        end
    end)
end

--==============================--
--desc:设置竞猜显示
--time:2018-08-06 11:39:25
--@status:
--@return 
--==============================--
function ArenaChampionTop32Item:updateGuessStatus(status, pos)
    self.guess_btn:setVisible(status) 
    if status == true and pos ~= nil then
        local target_check = self.check_btn_list[pos] 
        if target_check then
            self.guess_btn:setPosition(target_check:getPositionX(), target_check:getPositionY())
        end
    end
end

function ArenaChampionTop32Item:setData(data)
    if data == nil or data.pos_list == nil or next(data.pos_list) == nil then return end
    self:updateGuessStatus(false)
    self.data = data
    -- 按照位置排序一下
    local pos_list = data.pos_list
    table_sort(pos_list, function(a, b) 
        return a.pos < b.pos
    end)
    for k,role_name in pairs(self.role_name_list) do
        local pos_info = pos_list[k]
        if pos_info then
            role_name:setString(pos_info.name)
            if pos_info.ret == 0 then -- 未打
                role_name:setTextColor(Config.ColorData.data_color4[175])
            elseif pos_info.ret == 1 then -- 胜利
                role_name:setTextColor(Config.ColorData.data_color4[175])
            else
                role_name:setTextColor(cc.c4b(0x5b,0x5b,0x5b,0xff))
            end
            -- 姓名下面的底框
            local role_bg = self.role_pos_list[k]
            if role_bg then
                if role_bg.select then
                    role_bg.select:setVisible(pos_info.ret == 1)
                end
                if role_bg.normal then
                    if pos_info.ret == 2 then
                        setChildUnEnabled(true, role_bg.normal)
                    else
                        setChildUnEnabled(false, role_bg.normal)
                    end
                end
            end
            -- 独立线条
            local line_list = self.pos_line_list[k]
            if line_list and line_list.select_1 and line_list.select_2 then
                line_list.select_1:setVisible(pos_info.ret == 1)
                line_list.select_2:setVisible(pos_info.ret == 1)
            end
            -- 公共线条,只要打过了,那么就找出这个公共线条
            local check_index = 0
            local public_index = 0
            if k % 2 == 0 then
                check_index = k - 1
                public_index = getNorKey(check_index, k)
            else
                check_index = k
                public_index = getNorKey(check_index, k + 1)
            end
            local check_btn = self.check_btn_list[check_index]
            if check_btn then
                -- check_btn:setVisible(pos_info.ret ~= 0)
                check_btn:setVisible(true)
            end
            if k ~= 13 and k ~= 14 then
                local line_list_2 = self.pos_line_list_2[public_index] 
                if line_list_2 and line_list_2.select then
                    line_list_2.select:setVisible(pos_info.ret ~= 0)
                end
            end
        end
    end
end

function ArenaChampionTop32Item:DeleteMe()

end 