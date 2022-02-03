-- --------------------------------------------------------------------
-- 竖版图书馆系统
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PokedexWindow = PokedexWindow or BaseClass(BaseView)
local table_sort = table.sort
local table_insert = table.insert
function PokedexWindow:__init()
    self.ctrl = PokedexController:getInstance()
    self.is_full_screen = true
    self.win_type = WinType.Full      
    self.layout_name = "pokedex/pokedex_window"
    self.title_str = TI18N("图书馆")
    self.is_init = true
    self.cur_type = 0
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("pokedex","pokedex"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_35",true), type = ResourcesType.single },
    }

    self.hall_list = {}          --书架列表
    self.tab_list = {}           --标签列表
    self.item_list = {}          --图鉴子项列表
    self.rend_list = {}          --数据缓存列表
    self.group_list = {}         --以流派优先排序的二维列表
    self.group_title = {}        --流派标题
    self.have_list = {}
    self.item_list_pool = {}

    self.have_list = {}

    self.now_attr = {}
    self.next_attr = {}

    self.select_type = 1
    self.scroll_width = 0
    self.scroll_height = 0
    self.max_height = 0
end

function PokedexWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_35",true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.pokedex_panel = self.main_container:getChildByName("pokedex_panel")
    self.drama_panel = self.main_container:getChildByName('drama_panel')

    self.tab_panel = self.pokedex_panel:getChildByName("tab_panel")
    self.scroll_panel = self.pokedex_panel:getChildByName("scroll_panel")
    self.bottom_panel = self.pokedex_panel:getChildByName("bottom_panel")
    self.next_panel = self.bottom_panel:getChildByName("next_panel")

    local res = PathTool.getResFrame("pokedex","txt_cn_pokedex_5")
    self.full_icon = createImage(self.bottom_panel, res,455,20, cc.p(0,0), true, 0, false)
    self.full_icon:setVisible(false)
    self.close_btn = self.main_container:getChildByName("close_btn")

    self:initTabButton()

    local list = {[1]=TI18N("全部"),[2]=TI18N("物攻"),[3]=TI18N("法攻"),[4]=TI18N("肉盾"),[5]=TI18N("辅助"),}
    for i=1,5 do
        local btn = self.tab_panel:getChildByName("tab_btn_"..i)
        if btn then 
            local tab = {}
            tab.btn = btn
            tab.select_bg = btn:getChildByName("select_bg")
            tab.select_bg:setVisible(false)
            tab.title = btn:getChildByName("title")
            tab.title:setString(list[i])
            tab.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
            tab.index = i
            self.tab_list[i] = tab
        end
    end
  
    self.scroll_width = 720
    self.scroll_height = 660
    self.scroll_view = createScrollView(self.scroll_width,self.scroll_height,0,0,self.scroll_panel,ccui.ScrollViewDir.vertical)

    self:createBaseMessage()
end

function PokedexWindow:changeTabBarIndex( index, dun_id )
    if index == 1 then
        if not self.initPokedex then
            self.initPokedex = true
            self.ctrl:sender11040()
        end
    elseif index == 2 then
        if not self.initDrama then
            self.initDrama = true
            self.drama_view = PokedexDramaLookPanel.new(handler(self, self._onDramaPanelCallBack))
            self.drama_panel:addChild(self.drama_view)
        end
        if dun_id then
            self.drama_view:showPlayingDunDrama(dun_id)
        else
            self.drama_view:changeViewTypeShow(1)
            self.drama_close_flag = false
        end
    end
    self.pokedex_panel:setVisible(index == 1)
    self.drama_panel:setVisible(index == 2)
    self.select_tab_index = index
end

function PokedexWindow:_onDramaPanelCallBack( flag )
    self.drama_close_flag = flag
end

function PokedexWindow:initTabButton(  )
    self.tabBar = TabSelectBar.New(self.main_container, TabSelectBarDirection.horizontal, 5, nil, nil, nil, 0, nil, false)
    self.tabBar:setTitleSize(22)
    self.tabBar:setAnchorPoint(0, 1)
    self.tabBar:setPosition(0,1008)
    self:openTabLev()
    self.tabBar:setChangeItemByIndex(function(index)
        self:changeTabBarIndex(index)
    end)
end

function PokedexWindow:openTabLev()
    local select_path = PathTool.getResFrame("common", "common_1011")
    local unselect_path = PathTool.getResFrame("common", "common_1012")
    local arrow_path = PathTool.getResFrame("common", "common_1040")
    local tab_table = {}
    local lable_list = {[1] = TI18N("英雄图鉴"), [2] = TI18N("剧情回顾")}
    local label = ""
    for i = 1, 2 do
        table.insert(tab_table, { select_color = Config.ColorData.data_color4[179], unselect_color = Config.ColorData.data_color4[141], 
        select_path = select_path, unselect_path = unselect_path, width = 165, height = 65, label = lable_list[i],name = i,
        arrow_path = arrow_path, extend_name = "guidesing_boss_"..i})
    end
    self.tabBar.per_select_index = nil
    self.tabBar:setTabArray(tab_table)
end

function PokedexWindow:openRootWnd(group, index, dun_id)
    index = index or 1
    self.select_type = 1
    if group then 
        self.click_group = group 
    end
    if self.tabBar then
        self.tabBar:setSelectByIndex(index)
        self:changeTabBarIndex(index, dun_id)

    end
end

function PokedexWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            if self.select_tab_index == 2 and self.drama_close_flag == true then
                self.drama_close_flag = false
                if self.drama_view then
                    self.drama_view:changeViewTypeShow(1)
                end
            else
                self.ctrl:openPokedexWindow(false)
            end
        end
    end)
    if self.up_btn then
        self.up_btn:addTouchEventListener(function(sender, event_type) 
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self.ctrl:send11047()
            end
        end)
    end
    for i,tab in pairs(self.tab_list) do
        tab.btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:changeTabIndex(tab.index)
            end
        end)
    end

    if not self.get_all_event then 
        self.get_all_event = GlobalEvent:getInstance():Bind(PokedexEvent.Get_All_Event,function(data)
            if not data then return end
            local have_list = {}
            for i,v in pairs(data.partners) do
                have_list[v.partner_id] = v
            end
            self.have_list = have_list or {}
            self:changeTabIndex(self.select_type)

            if self.is_call == true then 
                self:updateHeroList()
                self.is_call = false
            end
            -- self:updateHeroList()
            self:updateAttrList(data.all_star,data.lev)
        end)
    end
   if not self.up_end_event then 
        self.up_end_event = GlobalEvent:getInstance():Bind(PokedexEvent.Up_End_Event,function(data)
            if not data then return end
            self:updateAttrList(data.old_star,data.cur_lev)
        end)
    end
    if not self.call_event then 
        self.call_event = GlobalEvent:getInstance():Bind(PartnerEvent.Partner_Call_Event,function()
            self.is_call = true 
            self.ctrl:sender11040()
        end)
    end
end

function PokedexWindow:createBaseMessage()
    local size = self.bottom_panel:getContentSize()
    --标题
    local title =  createLabel(26,Config.ColorData.data_color4[175],nil,size.width/2,165,"",self.bottom_panel,0, cc.p(0.5,0))
    title:setString(TI18N("累计升星奖励"))
    --当前
    local title =  createLabel(22,Config.ColorData.data_color4[175],nil,size.width/2-200,134,"",self.bottom_panel,0, cc.p(0.5,0))
    title:setString(TI18N("当前"))
    --下一级
    self.next_label =  createLabel(22,Config.ColorData.data_color4[175],nil,size.width/2+200,134,"",self.next_panel,0, cc.p(0.5,0))
    self.next_label:setString(TI18N("下一级"))
    
    --累计星数
    local label = self.pokedex_panel:getChildByName("all_label")
    label:setString(TI18N("累计升星数："))
    self.all_star_label = createRichLabel(24, Config.ColorData.data_color4[190], cc.p(0,0), cc.p(410,-23), 0, 0, 500)
    self.pokedex_panel:addChild(self.all_star_label)
    self.up_btn = createButton(self.pokedex_panel, TI18N(''), 590,-12, cc.size(161, 62), PathTool.getResFrame('common', 'common_1018'), 24)
    self.up_btn:setVisible(true)
    self.up_btn:setRichText(TI18N('<div fontColor=#ffffff fontsize=24 outline=2,#478425>提升</div>'))
end

function PokedexWindow:updateAttrList(now_star,lev)
    now_star = now_star or 0
    local config = Config.PartnerData.data_pokedex_attr
    local config_star = 0
    local max_star = 0
    local min_star = -1
    local next_lev = math.min(lev + 1 ,tableLen(config))
    -- for i,info in pairs(config) do
    --     if info.lev <= now_star and info.next_star > now_star then 
    --         config_star = info.star
    --     end
    --     max_star = math.max(max_star,info.star)
    --     if min_star <0 then 
    --         min_star = info.star
    --     else
    --         min_star = math.min(min_star,info.star)
    --     end
    -- end
    -- if max_star <= now_star then 
    --     config_star = max_star
    -- end
    local now_config = Config.PartnerData.data_pokedex_attr[lev]

    local next_config = Config.PartnerData.data_pokedex_attr[next_lev]

    local value_list = {}
    if now_config and now_config.attr then
        for i,v in pairs(now_config.attr) do
            if v and v[1] and v[2] then 
                value_list[v[1]] = v[2]
            end
        end
    end
    local attr_list = {[1]="hp_max",[2]="atk",[3]="def"}
    --当前属性
    for i=1,3 do
        local attr_str = attr_list[i]
        local value = value_list[attr_str] or 0
        if not self.now_attr[i] then 
            local pos = cc.p(65,120-33*i)
            local res = PathTool.getAttrIconByStr(attr_str)
            local name = Config.AttrData.data_key_to_name[attr_str] or ""
            local attr = self:createOneAttr(pos,res,name,value,self.bottom_panel)
            self.now_attr[i] = attr
        end
       
        self.now_attr[i].value_label:setString("+"..value)
    end

   
    local is_full = false
    local next_star = 0
    if next_config then
        next_star = next_config.star or 0
    end
    local str =""
    if next_star~=0 then
        str = now_star.."/"..next_star
    else
        str = now_star
    end
    if next_config.next_star == 0 then 
        is_full = true
    end
    self.full_icon:setVisible(is_full)
    self.next_panel:setVisible(true)
    if now_star >= next_star and not is_full then
        self.up_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=24 outline=2,#478425>提升</div>"))
        self.up_btn:setGrayAndUnClick(false)
        self.up_btn:showRedPoint(true)
    else
        if is_full == true then
            self.up_btn:setRichText(TI18N("<div fontColor=#ffffff >已满级</div>"))
        else
            self.up_btn:setRichText(TI18N("<div fontColor=#ffffff >提升</div>"))
        end
        self.up_btn:setGrayAndUnClick(true)
        self.up_btn:showRedPoint(false)
    end
    self.all_star_label:setString(str)

    if is_full == true then 
        self.next_panel:setVisible(false)
        return
    end



    if not next_config then return end
    local value_list = {}
    for i,v in pairs(next_config.attr) do
        if v and v[1] and v[2] then 
            value_list[v[1]] = v[2]
        end
    end
    --下一级属性
    local size = self.next_panel:getContentSize()
    for i=1,3 do
        local attr_str = attr_list[i]
        local value = value_list[attr_str] or 0
        if not self.next_attr[i] then 
            local pos = cc.p(480,120-33*i)
            local res = PathTool.getAttrIconByStr(attr_str)
            local name = Config.AttrData.data_key_to_name[attr_str] or ""
            local attr = self:createOneAttr(pos,res,name,value,self.next_panel)
            self.next_attr[i] = attr
            local res = PathTool.getResFrame("common","common_90017")
            local arrow = createImage(self.next_panel, res,size.width/2,120-33*i, cc.p(0.5,0), true, 0, false)
        end
       
        self.next_attr[i].value_label:setString("+"..value)
        self.next_attr[i].value_label:setTextColor(Config.ColorData.data_color4[178])
    end

end
function PokedexWindow:createOneAttr(pos,res,name,value,con)
    local icon_res = PathTool.getResFrame("common",res)
    local icon =  createImage(con, icon_res,pos.x-5,pos.y, cc.p(0,0), true, 0, false)
    local label1 =  createLabel(24,Config.ColorData.data_color4[175],nil,0,0,name,con,2, cc.p(0,0))
    label1:setPosition(cc.p(pos.x+30,pos.y))
    local label2 =  createLabel(24,Config.ColorData.data_color4[175],nil,0,0,"+"..value,con,2, cc.p(0,0))
    label2:setPosition(cc.p(pos.x+90,pos.y))
    return {name_label =label1,value_label =label2,icon=icon}
end
function PokedexWindow:setPanelData()
end

function PokedexWindow:changeTabIndex(index)
    if self.select_btn and self.select_btn.index == index then return end

    if self.select_btn then 
        self.select_btn.select_bg:setVisible(false)
        self.select_btn.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
    end

    self.select_btn = self.tab_list[index]
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(true)
        self.select_btn.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end

    self.select_type = index
    self:updateHeroList()
end
function PokedexWindow:updateHeroList()
    self:clearList()
    local partner_list = Config.PartnerData.data_pokedex
    local list = {}
    local index = 1
    local type_list= {[1]=1,[2]=3,[3]=2,[4]=4,[5]=5,[6]=0,}
    self.group_list = {}
    local group_num = 0
    local backpack_model  = BackpackController:getInstance():getModel()
    for i,v in pairs(partner_list) do
        local config = Config.PartnerData.data_partner_base[v.bid]
        if config then 
            if self.select_type == 1 or type_list[self.select_type] == config.type then
                local is_have = false
                config.is_have = 1
                if  self.have_list and self.have_list[v.bid] then 
                    is_have = true
                    config.is_have = 2
                else
                    local chips_id = config.chips_id or 0
                    local count = backpack_model:getBackPackItemNumByBid(chips_id) or 0
                    local chips_num = config.chips_num or 0
                    if count >= chips_num then 
                        config.is_have = 3
                    end
                end
                list[index] = {data=config,pokedex_data=v,is_have = is_have}
                index = index +1
                if not self.group_list[v.group_id] then 
                    self.group_list[v.group_id] = {}
                    group_num = group_num+1
                end
                table_insert(self.group_list[v.group_id],config)
            end
        end
    end
    local all_row_num = 0
    local sort_func = SortTools.tableUpperSorter({"is_have","rare_type"})
    self.row_list = {}
    for i,group_list in pairs(self.group_list) do
        table_sort(group_list, sort_func)
        local row_num = math.ceil(#group_list/3)
        self.row_list[i] = row_num
        all_row_num = all_row_num +row_num
    end
    self.all_row_num = all_row_num
    local function callback(item,vo)
        if vo and next(vo)~=nil then
            self.ctrl:openCheckHeroWindow(true,vo)
        end
    end
    -- self.list_view:setData(list, callback)

    self.rend_list = list
    self.max_height = math.max(all_row_num*400+40,self.scroll_height)
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_width,self.max_height))
   

    -- local hall_num = math.ceil(all_row_num/3)
    for i=1,all_row_num do
        if not self.hall_list[i] then 
            local res = PathTool.getResFrame("pokedex","pokedex_16")
            local item = createImage(self.scroll_view, res, 0, 0, cc.p(0.5,0), true, 0, true)
            item:setContentSize(cc.size(720,440))
            self.hall_list[i] = item
        end
        self.hall_list[i]:setVisible(true)
        self.hall_list[i]:setPosition(cc.p(self.scroll_width/2,self.max_height-400*i-40))
    end


    self:createHeroList(true)

end
function PokedexWindow:clearList()
    for i,v in pairs(self.item_list) do
        if not tolua.isnull(v) then
            v:setVisible(false)
        end
        table.insert(self.item_list_pool, v)
    end
    self.item_list = {}

    for i,v in pairs(self.hall_list) do
        v:setVisible(false)
    end

    for i,v in pairs(self.group_title) do
        if v and v.title_bg then 
            v.title_bg:setVisible(false)
        end
    end
end
function PokedexWindow:createHeroList(bool)
        if self.timer then 
            GlobalTimeTicket:getInstance():remove(self.timer)
            self.timer = nil
        end
    if bool == true then
        local index = 1
        local num = 1
        local group_id = 1
        local size = #self.rend_list
        local row_num = 0
        
        if not self.timer then 
            self.timer = GlobalTimeTicket:getInstance():add(function()
                if self.group_list[group_id] then 
                    local vo = self.group_list[group_id][index]               
                    if not vo then 
                        index = 1
                        local group_row_num =  self.row_list[group_id] or 0
                        row_num = row_num +group_row_num
                        
                        group_id = group_id +1
                    else
                        if not self.group_title[group_id] then 
                            local title = {}
                            local res = PathTool.getResFrame("pokedex","pokedex_14")
                            local title_bg = createImage(self.scroll_view, res, 0, 0, cc.p(0.5,0), true, 0, false)

                            local title_str = createLabel(22,Config.ColorData.data_color4[1],nil,14,9,"",title_bg,0, cc.p(0,0))

                            title.title_bg = title_bg
                            title.title_str = title_str
                            self.group_title[group_id] = title
                        end
                        local group_config = Config.PartnerData.data_pokedex[vo.bid]
                        if group_config then 
                            local str = group_config.group_name or ""
                            if self.group_title[group_id] and self.group_title[group_id].title_str and self.group_title[group_id].title_bg then 
                                self.group_title[group_id].title_str:setString(str)
                                self.group_title[group_id].title_bg:setVisible(true)

                                self.group_title[group_id].title_bg:setPosition(cc.p(100,self.max_height-row_num*400-82))
                            end
                        end
                        self:createItem(vo,num,row_num,index)
                        num = num+1
                        index = index +1
                    end
                else
                    group_id = group_id +1
                end
                if num > size then
                    if self.timer then 
                        GlobalTimeTicket:getInstance():remove(self.timer)
                        self.timer = nil
                    end
                end
            end,1 / display.DEFAULT_FPS)
        end
    end
end

function PokedexWindow:createItem(vo,index,row_num,now_index)
    local item = nil
    if next(self.item_list_pool) then
        item = table.remove(self.item_list_pool, 1)
        item:setVisible(true)
    else
        item = PokedexItem.new() 
        self.scroll_view:addChild(item)
    end
    item:changeHaveStatus(false)
    if  self.have_list  and self.have_list[vo.bid] then 
        item:changeHaveStatus(true)
    end
    item:addCallBack(function(item,vo)
        if vo and next(vo)~=nil then
            self.ctrl:openCheckHeroWindow(true,vo)
        end
    end)
    item:addLoadCallBack(function(item)
        if self.is_init == true then 
            if self.click_group then 
                local config = Config.PartnerData.data_pokedex[vo.bid]
                if config and next(config) ~=nil and config.group_id == self.click_group then 
                    self.scroll_view:scrollToPercentVertical(math.ceil(110*(row_num)/self.all_row_num),1,true)
                    self.is_init = false
                    return
                end
            end
            if item:getIsCall() == true then
                self.is_init = false
                self.scroll_view:scrollToPercentVertical(math.ceil(110*(row_num)/self.all_row_num),1,true)
            end
        end
    end)
    item:setData(vo)
    local offx = ((now_index-1)%3)*220+140
    local offy =self.max_height-row_num*400 - math.ceil(now_index/3)*400+160
    item:setPosition(cc.p(offx,offy))
    self.item_list[index] = item
end

function PokedexWindow:onEnterAnim()
end

function PokedexWindow:close_callback()
    self.ctrl:openPokedexWindow(false)
    self:createHeroList(false)
    self:clearList()
    for i,v in pairs(self.item_list) do
        v:DeleteMe() 
    end
    self.item_list = nil
    for i,v in ipairs(self.item_list_pool) do
        v:DeleteMe()
    end
    self.item_list_pool = nil

    if self.drama_view then
        self.drama_view:DeleteMe()
    end

    if self.get_all_event then 
        GlobalEvent:getInstance():UnBind(self.get_all_event)
        self.get_all_event = nil
    end
    if self.up_end_event then
        GlobalEvent:getInstance():UnBind(self.up_end_event)
        self.up_end_event = nil
    end
    if self.call_event then 
        GlobalEvent:getInstance():UnBind(self.call_event)
        self.call_event = nil
    end
end
