  
-- --------------------------------------------------------------------
-- tips来源
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
TipsOnlySource = TipsOnlySource or BaseClass(BaseView)

local controller = BackpackController:getInstance()
local model = BackpackController:getInstance():getModel()

function TipsOnlySource:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/tips_only_source"
    self.win_type = WinType.Mini   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {}
end

function TipsOnlySource:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    local title_con = self.main_container:getChildByName("title_con")
    local title_label = title_con:getChildByName("title_label")
    title_label:setString(TI18N("获取途径"))

    -- self.name = self.main_container:getChildByName("name")
    -- self.own_label = self.main_container:getChildByName("own_label")

    self.scrollCon = self.main_container:getChildByName("scrollCon")
    self.scroll_size = self.scrollCon:getContentSize()
    self.scrollView = createScrollView(self.scroll_size.width,self.scroll_size.height-3,-6,2,self.scrollCon,ccui.ScrollViewDir.vertical)

    self.close_btn = self.main_container:getChildByName("close_btn")
end

function TipsOnlySource:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openTipsOnlySource(false)
        end
    end)
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openTipsOnlySource(false)
            end
        end)
    end
end

function TipsOnlySource:openRootWnd(data,extend_data, item_list)
    self.data = data
    self.extend_data = extend_data
    self.need_item_list = item_list
    self:createSourceList()
end

function TipsOnlySource:createSourceList(  )
    if self.data == nil then return end
    local config 
    if self.data.config then 
        config = self.data.config
    else
        config = self.data
    end
    if not config then return end

    local source_list = config.source
    if source_list and next(source_list)~=nil then
        local list = {}
        for k,v in pairs(source_list) do
            local data = Config.SourceData.data_source_data[v[1]]
            if data and data.evt_type ~= "evt_league_help" then --帮内求助特殊处理下 只出现在特定场合 
                table.insert(list,v)
            else
                if self.extend_data and next(self.extend_data)~=nil then 
                    if self.extend_data[1] == "evt_league_help" and self.extend_data[2] then
                        table.insert(list,v)
                    end
                end
            end
        end

        local max_height = math.max(self.scroll_size.height,(SourceItem.HEIGHT)*#list)
        self.scrollView:setInnerContainerSize(cc.size(self.scroll_size.width,max_height))
        local final_list = {}
        for k,v in pairs(list) do
            local data = Config.SourceData.data_source_data[v[1]]
            local is_lock ,str = self:checIsOpen(data.lev_limit)
            v.id = data.id
            v.infon_data = data
            v.is_lock  = is_lock
            v.str = str
            table.insert(final_list,v)
        end
        local sort_func = SortTools.tableLowerSorter({"is_lock"})
        table.sort(final_list,sort_func)
        if final_list and next(final_list or {}) ~= nil then
            for i,v in ipairs(final_list) do
                local item = SourceItem.new(config.id, self.need_item_list)
                item:setCloseCallBack(function() controller:openTipsOnlySource(false)  end)
                self.item_list[i] = item
                self.scrollView:addChild(item)
                item:setData(v)
                item:setPosition(10,max_height-6-(SourceItem.HEIGHT-2)*(i-1))
            end
        end
    end
end


function TipsOnlySource:checIsOpen(data)
    if data then
        local not_is_lock = TRUE --默认都锁
        local str = ''
        if data[1] and data[1] == 'dungeon' then --关卡的
            local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
            if drama_data and data[2] then
                local dungeon_id = data[2]
                if drama_data.max_dun_id >= dungeon_id then
                    not_is_lock = FALSE
                end
                local config = Config.DungeonData.data_drama_dungeon_info(dungeon_id)
                if config then
                    str = TI18N('通关') .. config.name .. TI18N('解锁')
                end
            end
        elseif data[1] and data[1] == 'lev' then -- 等级的
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and data[2] then
                local lev = data[2]
                if role_vo.lev >= lev then
                    not_is_lock = FALSE
                end
                str = lev .. TI18N('级解锁')
            end
        elseif data[1] and data[1] == 'guild' then --公会等级
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and role_vo.gid ~= 0 and role_vo.gsrv_id ~= "" then --表示有公会
                local guild_info = GuildController:getInstance():getModel():getMyGuildInfo()
                if guild_info then
                    local lev = data[2]
                    if guild_info.lev >= lev then
                        not_is_lock = FALSE
                    else
                        not_is_lock = TRUE
                        str = TI18N('公会')..lev .. TI18N('级解锁')
                    end
                end
            else
                not_is_lock = TRUE
                str = TI18N("尚未加入公会")
            end
            --
        end
        return not_is_lock, str
    end
end


function TipsOnlySource:close_callback()
    for k,v in pairs(self.item_list) do
        if v and v["DeleteMe"] then
            v:DeleteMe()
        end
    end
    controller:openTipsOnlySource(false)
end