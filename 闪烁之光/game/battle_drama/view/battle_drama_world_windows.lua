-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      剧情副本世界地图
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaWorldWindows = BattleDramaWorldWindows or BaseClass(BaseView)

local controller = BattleDramaController:getInstance()
local model = BattleDramaController:getInstance():getModel()

function BattleDramaWorldWindows:__init()
    self.is_full_screen = true
    self.layout_name = "battledrama/battle_drama_world_windows"
    self.tab_list    = {}                -- 当前用于储存标签列表
    self.item_list   = {}
    self.cur_tab     = nil
end

function BattleDramaWorldWindows:open_callback()
    self.panel_bg = self.root_wnd:getChildByName("Panel_bg")
    self.background = self.panel_bg:getChildByName("background")
    self.panel_bg:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel:setScale(display.getMaxScale())
    self.close_btn = self.main_container:getChildByName("close_btn")
    -- self.diffcult_btn = self.main_container:getChildByName("diffcult_btn")
    -- self.normal_btn = self.main_container:getChildByName("normal_btn")
    local tab_btn = nil
    local type, label = nil, nil
    for i = 1, 1 do
        tab_btn = self.main_container:getChildByName(string.format("tab_btn_%s", i))
        tab_btn.label = tab_btn:getTitleRenderer()
        tab_btn:setBright(false)
        tab_btn.label:setTextColor(cc.c4b(245, 224, 185, 255))
        type, label = self:getTabType(i)
        tab_btn.type = type
        tab_btn.label:setString(label)
        self.tab_list[type] = tab_btn
    end
end

function BattleDramaWorldWindows:getTabType(index)
    if index == 1 then
        return BattleDramaConst.Normal, TI18N("简单")
    elseif index == 2 then
        return BattleDramaConst.Diffcult, TI18N("困难")
    end
end

function BattleDramaWorldWindows:openRootWnd(type)
    type = type or BattleDramaConst.Normal
    self:changeTabView(type)
end

function BattleDramaWorldWindows:register_event()
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                controller:openDramWorldView(false) 
            end
        end)
    end
    for k, tab_btn in pairs(self.tab_list) do
        tab_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playTabButtonSound()
                if tab_btn.type ~= nil then
                    local data = model:getModeListByMode(tab_btn.type)
                    if not data then
                        message("暂没开放")
                        return
                    else
                        self:changeTabView(tab_btn.type)
                    end
                end
            end
        end)
    end
end

function BattleDramaWorldWindows:changeTabView(type)
    if self.cur_type == type then return end
    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(Config.ColorData.data_color4[155])
        self.cur_tab:setBright(false)
    end
 
    self.cur_type = type
    self.cur_tab = self.tab_list[self.cur_type]
    if Config.DungeonData.data_drama_world_info and Config.DungeonData.data_drama_world_info[type] then
        local config = Config.DungeonData.data_drama_world_info[type]
        local data = model:getModeListByMode(type)
        local daram_data = model:getDramaData()
        local chapter_pass_sum = model:getHasPassChapterPassList(type)
        local open_num = math.min(chapter_pass_sum + 1,tableLen(config))
        if config then
            local list = {}
            local table_insert = table.insert
            for k, v in pairs(config) do
                table_insert(list,v)
            end
            table.sort(list,function(a,b)
                return  a.chapter_id < b.chapter_id
            end)
            local item = nil
            if self.item_list and next(self.item_list or {}) ~= nil then
                for i, item in pairs(self.item_list) do
                    if item then
                        item:removeAllChildren()
                        item:removeFromParent()
                    end
                end
                self.item_list = {}
            end
            for i, v in ipairs(list) do
                if not self.item_list[v.chapter_id] then
                    item = createImage(self.main_container,PathTool.getResFrame("common","common_1019"),0,0,cc.p(0.5,0.5),true,1,true)
                    item:setContentSize(158,50)
                    --item:setScale(3)
                    item:setTouchEnabled(true)
                    local label = createLabel(24,155,nil,item:getContentSize().width/2,item:getContentSize().height/2,"1212",item)
                    label:setAnchorPoint(cc.p(0.5,0.5))
                    item.label = label
                    local charpter_label = createLabel(24, 155, nil, item:getContentSize().width / 2,65, "1212", item)
                    charpter_label:setAnchorPoint(cc.p(0.5, 0.5))
                    item.charpter_label = charpter_label
                    local has_pass_label = createLabel(24, 155, nil, item:getContentSize().width / 2,-15, "1212", item)
                    has_pass_label:setAnchorPoint(cc.p(0.5, 0.5))
                    item.has_pass_label = has_pass_label
                    local item_tag = createImage(item,PathTool.getResFrame("common","common_1001"),80,90,cc.p(0.5,0.5),true,1,true)
                    item_tag:setScale(2)
                    item_tag:setVisible(false)
                    if v.chapter_id == daram_data.chapter_id then
                        item_tag:setVisible(true)
                    end
                    item:setPosition(175 + 180 * ((i - 1) % 3), 600 - 120 * math.floor((i - 1) / 3))
                    v.mode_type = type
                    item.data = v
                    self.item_list[v.chapter_id] = item
                end
                item = self.item_list[v.chapter_id]  
                if item then
                    if i <= open_num then
                        item.data.is_open = true
                        setChildDarkShader(false,item,Config.ColorData.data_color4[155])
                    else
                        item.data.is_open = false
                        setChildDarkShader(true,item,Config.ColorData.data_color4[155])
                    end
                    local sum_num = model:getHasCurChapterPassListNum(type,v.chapter_id)
                    item.label:setString(v.name)
                    item.charpter_label:setString("第"..StringUtil.numToChinese(v.chapter_id).."章")
                    item.has_pass_label:setString(sum_num.."/"..tableLen(Config.DungeonData.data_drama_info[type][v.chapter_id]))
                end
            end
        end
    end
    for k, item_btn in pairs(self.item_list) do
        if item_btn then
            item_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    customClickAction(sender, event_type)
                    if item_btn.data.is_open == true then
                        local chapter_list = model:getChapterListByID(item_btn.data.mode_type,item_btn.data.chapter_id)
                        local max_dun_id = model:getHasPassChapterMaxDunId(item_btn.data.mode_type, item_btn.data.chapter_id)
                        if chapter_list and max_dun_id ~= 0 then --直接切换
                            local cur_drama_data = model:getDramaData()
                            cur_drama_data.mode = item_btn.data.mode_type
                            cur_drama_data.chapter_id = item_btn.data.chapter_id
                            cur_drama_data.dun_id = max_dun_id
                            BattleDramaController:getInstance():getModel():setDramaData(cur_drama_data)
                        else
                            BattleDramaController:getInstance():send13002()
                        end
                        controller:openDramWorldView(false) 
                    else
                        message("前面章节暂没通关")
                    end
                end
            end)
        end
    end
    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(cc.c4b(89, 52, 41, 255))
        self.cur_tab:setBright(true)
    end
end

function BattleDramaWorldWindows:close_callback()
    controller:openDramWorldView(false)
end