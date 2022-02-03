-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      选择阵法界面
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
FormationSelectPanel = FormationSelectPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function FormationSelectPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/formation_select_panel"

    self.res_list = {
     { path = PathTool.getPlistImgForDownLoad("form","form"), type = ResourcesType.plist },
    }
end

function FormationSelectPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("阵法更换"))
    self.main_container:getChildByName("tips_label"):setString(TI18N("点击图标选中阵法"))
    
    self.scrollview = self.main_container:getChildByName("scrollview")
    self.scrollview:setScrollBarEnabled(false)
    -- self.scrollview:setTouchEnabled(false)
    self.scrollview_size = self.scrollview:getContentSize()

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("确 定"))
end

function FormationSelectPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn) ,true, 2)
    -- --添加英雄升星成功返回
    -- self:addGlobalEvent(HeroEvent.Next_Break_Info_Event, function(next_data) 
    --     if not next_data then return end
    --     if not self.hero_vo then return end
    --     self:setData(self.hero_vo,next_data)
    -- end)
end

--关闭
function FormationSelectPanel:onClickBtnClose()
    controller:openFormationSelectPanel(false)
end

--确定
function FormationSelectPanel:onClickComfirmBtn()
    if not self.old_select then return end
    if not self.select_index then return end
    -- controller:sender11004(self.hero_vo.id)
    if self.old_select ~= self.select_index then
        --发改变阵法 协议
        if self.callback then
            local formation_type = self.config_list[self.select_index].type
            self.callback(formation_type, self.team_index)
        end
    end
    self:onClickBtnClose()
end

function FormationSelectPanel:openRootWnd(formation_type, callback, team_index)
    if not team_index then return end
    self.team_index = team_index
    self.callback = callback
    self:setData(formation_type)
end

function FormationSelectPanel:setData(formation_type)
    local formation_type = formation_type or 1
    local config = Config.FormationData.data_form_data
    
    --初始化数据
    self.config_list = {}
    for i,v in pairs(config) do
        table_insert(self.config_list, v)
    end
    table_sort( self.config_list, function(a, b) return a.order < b.order end )

    --找选中(一定要排序后.)
     self.select_index = 1
    for i,v in ipairs(self.config_list) do
        if formation_type == v.type then
            self.select_index = i
        end
    end
    self.old_select = self.select_index

    local role_vo = RoleController:getInstance():getRoleVo()
    local role_lev = role_vo and role_vo.lev or 0
    
    local item_width  = 98
    local width = (item_width + 16) * #self.config_list
    local max_width = math.max(self.scrollview_size.width, width)
    self.scrollview:setInnerContainerSize(cc.size(max_width, self.scrollview_size.height))

    self.item_list = {}
    local index = 1
    self:clearTimeTicket()
    self.time_ticket = GlobalTimeTicket:getInstance():add(function()
        if tolua.isnull(self.scrollview) then return end
        if self.config_list[index] ~= nil then
            local config = self.config_list[index]
            if self.item_list[index] == nil then
                
                self.item_list[index] = self:createItem(config, item_width, index, role_lev)
                self.scrollview:addChild(self.item_list[index].con)
            end
            self.item_list[index].con:setPosition( (index-1 + 0.5) * (item_width + 16), 100)
            index = index + 1
        else
            self:clearTimeTicket()
        end
    end, 3 / display.DEFAULT_FPS)
end

function FormationSelectPanel:createItem(config, item_width, index, role_lev)
    local size = cc.size(item_width, item_width)
    local item = {}

    item.config = config
    local is_select = self.select_index == index
    
    local con = ccui.Widget:create()
    con:setContentSize(size)
    con:setTouchEnabled(true)
    con:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.item_list then return end
            if role_lev < config.need_lev and self.team_index ~= 999 then -- 999 新手训练营特殊类型
                message(config.need_lev..TI18N("级解锁"))
                return
            end
            self.select_index = index
            for i,item in ipairs(self.item_list) do
                if item.select_img then
                    if self.select_index == i then
                        item.select_img:setVisible(true)
                    else
                        item.select_img:setVisible(false)
                    end
                end
            end
        end
    end)
    --背景
    local res = PathTool.getNormalCell()
    local bg = createImage(con, res,  size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
    bg:setContentSize(size)

    item.con = con

    --阵法icon
    local res = PathTool.getResFrame("form", "form_icon_"..config.type)
    item.icon = createImage(item.con, res,  size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, false)
    item.icon:setScale(0.8)
    --选择框
    local select_res = PathTool.getResFrame("common", "common_90019")
    item.select_img = createImage(item.con, select_res,  size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
    item.select_img:setContentSize(size)

    
    if is_select == true then
        item.select_img:setVisible(true)
        --当前背景
        local cur_res = PathTool.getResFrame("common", "common_30012")
        item.cur_img = createImage(item.con, cur_res,  30,67, cc.p(0.5,0.5), true, 0, false)
        local cur_name = createLabel(18,cc.c3b(0xff,0xff,0xff),nil, 20, 39, TI18N("当前"), item.cur_img, nil, cc.p(0.5,0.5),nil)
        cur_name:enableOutline(cc.c3b(0xff,0x59,0x43), 2)
        cur_name:setRotation(-45)
    else
        item.select_img:setVisible(false)
    end

    local name_res = PathTool.getResFrame("common","common_90010")
    local name_bg = createImage(item.con,name_res,size.width/2,-27,cc.p(0.5,0.5),true,0,true)
    name_bg:setContentSize(cc.size(105,37))
    --阵法名字 --68452a
    item.name = createLabel(24,cc.c3b(0x68,0x45,0x2a),nil, item_width * 0.5,-27 ,config.name, item.con,nil, cc.p(0.5,0.5),nil)

    --锁
    if role_lev < config.need_lev and self.team_index ~= 999 then --999 新手训练营特殊类型
        local res = PathTool.getResFrame("common","common_90009")
        item.lock_icon =createImage(item.con, res, size.width/2, 62, cc.p(0.5,0.5),true,0,false)
        local str = string_format("%s%s", config.need_lev, TI18N("解锁"))
        createLabel(22, Config.ColorData.data_color4[1], Config.ColorData.data_color4[9], size.width/2,10,str, item.con, 2, cc.p(0.5,0))

        setChildUnEnabled(true, item.icon)
    end

    return item
end

function FormationSelectPanel:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 

function FormationSelectPanel:close_callback()
    self:clearTimeTicket()
    controller:openFormationSelectPanel(false)
end