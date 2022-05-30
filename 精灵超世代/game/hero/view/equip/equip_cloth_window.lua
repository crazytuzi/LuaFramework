-- --------------------------------------------------------------------
-- 竖版装备穿戴
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EquipClothWindow = EquipClothWindow or BaseClass(BaseView)
    
local controller = HeroController:getInstance()
local model = controller:getModel()
local table_insert =table.insert
local table_sort = table.sort
local string_format = string.format

--@holy_data 神装方案数据 结构参考 协议25220
function EquipClothWindow:__init(pos, partner_id, data, holy_data, enter_type)
    self.is_full_screen = false
    
    self.enter_type = enter_type or HeroConst.EnterType.eOhter
    self.holy_data = holy_data
    self.cloth_data = data or {}
    self.empty_res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("hero","hero"), type = ResourcesType.plist },
        { path = self.empty_res, type = ResourcesType.single },
    }

    if BackPackConst.checkIsHolyEquipment(pos) then
        self.title_str = TI18N("神装更换")
    else
        self.title_str = TI18N("装备更换")
    end
    

    self.win_type = WinType.Big    
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.is_init = true
    self.click_pos = pos or 1
    self.click_partner = partner_id or 0
    self.is_put_off = false
end

function EquipClothWindow:open_callback()
    local csbPath = PathTool.getTargetCSB("hero/equip_cloth_panel")
    local root = cc.CSLoader:createNode(csbPath)
    self.container:addChild(root)

    self.main_panel = root:getChildByName("main_panel")
end

function EquipClothWindow:register_event()
    -- if not self.put_equip_event then 
    --     self.put_equip_event = GlobalEvent:getInstance():Bind(PartnerEvent.Equip_Update_Event,function()
    --         if self.is_put_off == true then 
    --             if self.cloth_item then 
    --                 self.cloth_item:DeleteMe()
    --                 self.cloth_item = nil
    --             end
    --             self.cloth_data = nil
    --             if self.list_view then 
    --                 local scroll_view_size = cc.size(620,712)
    --                 self.list_view:resetSize(scroll_view_size)
    --             end
    --             self:updateEquipList()
    --         end
    --         self.is_put_off = false
    --     end)
    -- end
    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function(list)
        if self.click_partner then
            for i,v in ipairs(list) do
                if self.click_partner == v.partner_id then
                    if self.close then
                        self:close()
                    end
                end
            end
        end
    end)
end

--显示空白
function EquipClothWindow:showEmptyIcon(bool)
    if not self.empty_con and bool == false then return end
    if not self.empty_con then 
        local size = cc.size(200,200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setPosition(cc.p(335,370))
        self.main_panel:addChild(self.empty_con,100)

        local bg = createImage(self.empty_con, self.empty_res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
        self.empty_label = createLabel(24,cc.c4b(0x76,0x45,0x19,0xff),nil,size.width/2,-10,"",self.empty_con,0, cc.p(0.5,0))
    end
    local str = TI18N("背包中无可穿戴装备")
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end

function EquipClothWindow:openRootWnd() 
    self:updateEquipList()
end

function EquipClothWindow:updateEquipList()
    local scroll_view_size = cc.size(620,712)
    --有穿戴的要创建穿戴的
    if self.cloth_data and next(self.cloth_data) ~=nil then 
        if not self.cloth_item then 
            local size = self.main_panel:getContentSize()
            self.cloth_item = EquipClothItem.new(2)
            self.main_panel:addChild(self.cloth_item)
            self.cloth_item:setPosition(cc.p(size.width/2,680))
            self.cloth_item:addCallBack(function(item,vo)
                self.is_put_off = true
                if BackPackConst.checkIsHolyEquipment(self.click_pos) then
                    controller:sender11093(self.click_partner, vo.id, 0) --卸下
                else
                    controller:sender11011(self.click_partner,self.cloth_data.id)
                end
                controller:openEquipPanel(false)
            end)
        end
        self.cloth_item:setData(self.cloth_data)
        if self.cloth_item.holy_equip_bg then
            self.cloth_item.holy_equip_bg:setVisible(false)
        end
        scroll_view_size = cc.size(620,555)
    end

    if self.list_view == nil then
        local setting = {
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = -6,                    -- 第一个单元的Y起点
            space_y = 10,                   -- y方向的间隔
            item_width = 620,               -- 单元的尺寸width
            item_height = 114,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1,                        -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.main_panel, cc.p(12, 46) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    local list = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.EQUIPS) or {}

    local show_list = {}
    for i,v in pairs(list) do
        if v and v.config and v.config.type then
            if self.click_pos == v.config.type then
                if self.cloth_data and self.cloth_data.id ~= v.id then
                    table_insert(show_list, v)
                end
            end
        end
    end

    if self.holy_data and next(self.holy_data) ~= nil and BackPackConst.checkIsHolyEquipment(self.click_pos) then
        --神装管理要显示穿戴在宝可梦上面的装备
        local hero_equip_list = model:getAllHeroHolyEquipList()
        for k,v in pairs(hero_equip_list) do
            if v.config and v.config.type and self.click_pos == v.config.type then
                if self.cloth_data and self.cloth_data.id ~= v.id then
                    table_insert(show_list, v)
                end
            end
        end
    end

    if #show_list > 0 then
        if show_list[1].sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
            local sort_func = SortTools.tableUpperSorter({"eqm_star", "eqm_jie", "base_id"})
            table_sort(show_list, sort_func)
        else
            local sort_func = SortTools.KeyUpperSorter("all_score")
            table_sort(show_list, sort_func)
        end
    end

    if not show_list or next(show_list) == nil then 
        self:showEmptyIcon(true)
    else
        self:showEmptyIcon(false)    
    end
    self.show_list = show_list
    self.list_view:reloadData()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function EquipClothWindow:createNewCell(width, height)
    local cell = EquipClothItem.new()
    cell:setExtendData({my_equip_score = self.cloth_data.all_score, enter_type = self.enter_type})
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function EquipClothWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function EquipClothWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function EquipClothWindow:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.show_list[index]
    self:clickFun(cell_data)
end

function EquipClothWindow:clickFun(vo)
    if not vo then return end
    --神装方案穿戴
    if self.holy_data and next(self.holy_data) ~= nil and BackPackConst.checkIsHolyEquipment(self.click_pos) then
        local partner_id = self.holy_data.partner_id or 0
        --检查道具是否在神装管理里面
        local id_status,plan_data = model:checkHolyEquipmentPalnByItemID(vo.id)
        --检查是否勾选今日不再提示
        local status = SysEnv:getInstance():getBool(SysEnv.keys.holy_plan_save_tip, false)

        if id_status and not status then
            local holy_data = {}
            holy_data.id = self.holy_data.id
            holy_data.name = self.holy_data.name
            holy_data.partner_id = partner_id
            holy_data.item_list = {}
            holy_data.equip_list = self.holy_data.equip_list
            holy_data.select_vo = vo

            --装备已穿戴/在背包
            local item_vo = model:getHolyEquipById(vo.id)
            if not item_vo then
                item_vo = BackpackController:getModel():getBagItemById(BackPackConst.Bag_Code.EQUIPS, vo.id)
            end
            local holy_type = item_vo.config.type
            for _,data in pairs(plan_data.list) do
                if data and vo.id == data.item_id then
                    table_insert(holy_data.item_list, holy_type, {item_vo = item_vo, name = plan_data.name})
                end
            end
            --判断是否有已被其他宝可梦穿戴的神装，有则提示
            if holy_data and next(holy_data.item_list) ~= nil then
                controller:openHolyequipmentSaveTips(true, holy_data)
            end
        else
            local is_new = true
            local list = {}
            if self.holy_data.equip_list then
                for _type , equip_vo in pairs(self.holy_data.equip_list) do
                    local each_partner_id =  0
                    if vo.config.type ==  _type then
                        if model.dic_itemid_to_partner_id[vo.id] then
                            each_partner_id = model.dic_itemid_to_partner_id[vo.id]
                        end
                        table.insert(list, {partner_id = each_partner_id, item_id = vo.id})
                        is_new = false
                    else
                        if model.dic_itemid_to_partner_id[equip_vo.id] then
                            each_partner_id = model.dic_itemid_to_partner_id[equip_vo.id]
                        end
                        table.insert(list, {partner_id = each_partner_id, item_id = equip_vo.id})
                    end
                end
            end
            if is_new then
                local each_partner_id =  0
                if model.dic_itemid_to_partner_id[vo.id] then
                    each_partner_id = model.dic_itemid_to_partner_id[vo.id]
                end
                table.insert(list, {partner_id = each_partner_id, item_id = vo.id})
            end
            controller:sender25221(self.holy_data.id, partner_id, self.holy_data.name, list) --新增神装方案
            
        end
    else
        if BackPackConst.checkIsHolyEquipment(self.click_pos) then
            controller:sender11093(self.click_partner, vo.id, 1)
        else
            controller:sender11010(self.click_partner,vo.id)
        end
    end
    controller:openEquipPanel(false)
end

--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function EquipClothWindow:setPanelData()
end

function EquipClothWindow:close_callback()
    controller:openEquipPanel(false)
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.cloth_item then 
        self.cloth_item:DeleteMe()
        self.cloth_item = nil
    end
    if self.put_equip_event then 
        GlobalEvent:getInstance():UnBind(self.put_equip_event)
        self.put_equip_event = nil
    end
end



-- --------------------------------------------------------------------
-- 竖版装备穿戴子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EquipClothItem = class("EquipClothItem", function()
    return ccui.Widget:create()
end)

function EquipClothItem:ctor(open_type)  
    self.open_type = open_type or 1
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function EquipClothItem:setExtendData(extend_info)
    self.my_equip_score = extend_info.my_equip_score or 0
    self.enter_type = extend_info.enter_type
end
function EquipClothItem:config()
    self.size = cc.size(620,150)
    self:setContentSize(self.size)
    self.attr_list = {}
    self.star_list = {}
end
function EquipClothItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/equip_cloth_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.equip_item = BackPackItem.new(false,true,false,0.8)
    self.equip_item:setPosition(cc.p(75,56))
    self.main_panel:addChild(self.equip_item)
    self.equip_item:addCallBack(function ()
        controller:openEquipTips(true, self.data, PartnerConst.EqmTips.other)
    end)

    self.bg = self.main_panel:getChildByName("bg")
   
    self.cloth_btn = self.main_panel:getChildByName("lev_btn")
    self.cloth_btn:setTitleText(TI18N("穿戴"))
    local title = self.cloth_btn:getTitleRenderer()
    title:enableShadow(Config.ColorData.data_new_color4[3], cc.size(0, -2),2)
    --title:enableOutline(Config.ColorData.data_color4[264], 2)

    local res = PathTool.getResFrame("common","common_2040")
    self.cloth_btn:setBright(true)
    if self.open_type == 2 then 
        --res = PathTool.getResFrame("common","common_1020")
        self.cloth_btn:setBright(false)
        self.cloth_btn:setTitleText(TI18N("卸下"))
        title:enableShadow(Config.ColorData.data_new_color4[2], cc.size(0, -2),2)
    	--title:enableOutline(Config.ColorData.data_color4[263], 2)
    end
    self.bg:loadTexture(res,LOADTEXT_TYPE_PLIST)

    --装备名字
    self.equip_name = createLabel(24,Config.ColorData.data_new_color4[10],nil,130,65,"",self.main_panel,0, cc.p(0,0))

    self.plan_eqm_name = createRichLabel(22, cc.c4b(0xd9,0x50,0x14,0xff), cc.p(1, 0.5), cc.p(601, 118), nil, nil, 380)
    self.main_panel:addChild(self.plan_eqm_name)
end

function EquipClothItem:setData(data)
    if not data then return end
    if not data.config then return end
    -- 引导需要,这里做修改
    if data._index then
        self.cloth_btn:setName("guildsign_equip_list_item_"..data._index)
    end

    local id_status,plan_data = model:checkHolyEquipmentPalnByItemID(data.id)
    if id_status then
        self.plan_eqm_name:setString(string_format(TI18N("【%s】方案"),plan_data.name))
    else
        self.plan_eqm_name:setString("")
    end
    if self.enter_type == HeroConst.EnterType.eHolyPlan and self.open_type ~= 2 then
        self.cloth_btn:setTitleText(TI18N("装配"))
    end

    self.data = data
    -- self.equip_item:setBaseData(data.base_id)
    self.equip_item:setData(data)
    
    self.equip_item:setEnchantLev(data.enchant)

    local name = data.config.name or ""
    local str = name
    local enchant = data.enchant or 0
    if enchant > 0 then 
        str = name .. "+" .. enchant
    end
    self.equip_name:setString(str)

    if self.data.config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
        self:updateHolyEquipInfo()
    else --普通装备

        --装备等级
        if self.equip_lev == nil then
            self.equip_lev = createLabel(20,Config.ColorData.data_new_color4[6],nil,130,20,"",self.main_panel,0, cc.p(0,0))
        end
        --评分
        if self.equip_score == nil then
            self.equip_score = createLabel(20,Config.ColorData.data_new_color4[6],nil,250,20,"",self.main_panel,0, cc.p(0,0))
        end

        local effect = data.config.value
        local lev = data.config.lev or 0
        self.equip_lev:setString(TI18N("等级：")..lev)

        local score = data.all_score or 0
        local showScore = changeBtValueForPower(score)
        self.equip_score:setString(TI18N("评分：")..showScore)
        --self:updateAttrList()

        if self.open_type ~= 2 then
            if self.my_equip_score < score then
                addRedPointToNodeByStatus(self.cloth_btn, true, 5, 5)
            else
                addRedPointToNodeByStatus(self.cloth_btn, false, 5, 5)
            end
        end
    end
end

function EquipClothItem:updateAttrList()
    local main_attr = self.data.main_attr or {}
    local jing_attr = self.data.attr or {}
    local jing_list = {}
    for i,v in pairs(jing_attr) do
        jing_list[v.attr_id] = v
    end
  
    local index = 1
    for i,v in pairs(main_attr) do
        if not self.attr_list[index] then 
            local label = createRichLabel(22, Config.ColorData.data_color4[156], cc.p(0,0), cc.p(150*index+27,30), 0, 0, 400)
            self.attr_list[index] = label
            self.main_panel:addChild(label)
            local icon = createImage(self.main_panel, nil,150*index+5,30, cc.p(0,0), true, 0, false)
            icon:setScale(0.8)

            self.attr_list[index].icon = icon
        end
        local name = Config.AttrData.data_id_to_name[v.attr_id] or ""
        local value = v.attr_val 

        local attr_key = Config.AttrData.data_id_to_key[v.attr_id]
        local res = PathTool.getResFrame("common", PathTool.getAttrIconByStr(attr_key))
        self.attr_list[index].icon:loadTexture(res, LOADTEXT_TYPE_PLIST)
        if jing_list[v.attr_id] then 
            
            local jing_val = jing_list[v.attr_id].attr_val 
            value = value + math.ceil(jing_val/100)/10
        end
        if PartnerCalculate.isShowPer(v.attr_id) == true then
            value = ((value/1000) * 100).."%"
        end
        -- value = math.ceil(value/100)/10
        local str = string_format("%s：%s",name,value)
        self.attr_list[index]:setString(str)

        index =index +1
    end
end

function EquipClothItem:updateHolyEquipInfo()
    self.equip_name:setPositionY(106)
    --基本属性的位置
    local label_x = 150
    local label_y = 76
    --属性值的x位置 y 位置和 label 一样

    local label_y2 = 44

    local attr_x = 222
    local attr_x2 = 345

    if self.holy_equip_bg == nil then
        local res = PathTool.getResFrame("common","common_2008")
        self.holy_equip_bg = createImage(self.main_panel, res, 312,58, cc.p(0.5, 0.5), true, 0, true)
        self.holy_equip_bg:setContentSize(cc.size(330,90))
        self.holy_equip_bg:setOpacity(180)
        self.holy_equip_bg:setCapInsets(cc.rect(8, 5, 1, 1))
    end


    if self.holy_base_label == nil then
        self.holy_base_label = createLabel(20, Config.ColorData.data_color4[156], nil, label_x, label_y, "", self.main_panel, 0, cc.p(0,0.5))
        self.holy_base_label:setString(TI18N("基础:"))
    end

    local main_attr1 = self.data.main_attr or {}
    if main_attr1 and next(main_attr1) ~= nil then
        --神装的主属性只有一条..多的无视掉
        local main_attr = main_attr1[1] or {}
        local res, attr_name, attr_val = commonGetAttrInfoByIDValue(main_attr.attr_id, main_attr.attr_val)

        if res then
            if self.base_attr_label == nil then
                self.base_attr_label = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(attr_x, label_y), nil, nil, 380)
                self.main_panel:addChild(self.base_attr_label)
            end
            -- <img src='%s' scale=1 />
            local attr_str = string_format("<div fontcolor=#955322> %s %s </div>", attr_name, attr_val)
            self.base_attr_label:setString(attr_str)
        end
    end

    if self.holy_random_label == nil then
        local x = label_x
        local y = label_y2
        self.holy_random_label = createLabel(20, Config.ColorData.data_color4[156], nil, x, y , "", self.main_panel, 0, cc.p(0,0.5))
        self.holy_random_label:setString(TI18N("随机:"))
    end

    local dic_holy_eqm_attr = {}
    for i,v in ipairs(self.data.holy_eqm_attr) do
        dic_holy_eqm_attr[v.pos] = v
    end
    --神装随机属性最多 2 条  多的需要调整ui才可以
    if self.random_holy_equip_attr == nil then
        self.random_holy_equip_attr = {}
    end
    for i=1,2 do
        if self.random_holy_equip_attr[i] == nil then
            local x = attr_x 
            if i >= 2 then
                x = attr_x2
            end
            local y = label_y2
            self.random_holy_equip_attr[i] = createRichLabel(20, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0, 0.5), cc.p(x, y), nil, nil, 380)
            self.main_panel:addChild(self.random_holy_equip_attr[i])
        end

        local random_eqm_attr = dic_holy_eqm_attr[i] 
        if random_eqm_attr then
            local res, attr_name, attr_val = commonGetAttrInfoByIDValue(random_eqm_attr.attr_id, random_eqm_attr.attr_val)
            if res then
                local attr_key = Config.AttrData.data_id_to_key[random_eqm_attr.attr_id]
                local color = model:getHolyEquipmentColorByItemIdAttrKey(self.data.config.id, attr_key, random_eqm_attr.attr_val, 1, 2)
                -- local color = BackPackConst.getBlackQualityColorStr(1) --<img src='%s' scale=1 />
                local attr_str = string_format("<div fontcolor=#955322> %s </div><div fontcolor=%s>%s</div>", attr_name, color, attr_val)
                self.random_holy_equip_attr[i]:setString(attr_str)
            end
        else
            if i == 1 then
                self.random_holy_equip_attr[i]:setString(TI18N("无"))
            else
                self.random_holy_equip_attr[i]:setString("")
            end
        end
    end
end
--事件
function EquipClothItem:registerEvents()
    self.cloth_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.call_fun then 
                self:call_fun(self.data)
            end
        end
    end)
    
end
function EquipClothItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function EquipClothItem:addCallBack(call_fun)
    self.call_fun =call_fun
end

function EquipClothItem:setVisibleStatus(bool)
    self:setVisible(bool)
end

function EquipClothItem:DeleteMe()
    if self.equip_item then 
        self.equip_item:DeleteMe()
        self.equip_item = nil
    end
    self.data = nil
    self:removeFromParent()
end




