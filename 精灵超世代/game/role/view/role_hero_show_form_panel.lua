-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      选择荣誉icon界面
-- <br/> 2019年5月30日
-- --------------------------------------------------------------------
RoleHeroShowFormPanel = RoleHeroShowFormPanel or BaseClass(BaseView)

local controller = RoleController:getInstance()
local model = controller:getModel()
local hero_model = HeroController:getInstance():getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

function RoleHeroShowFormPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "roleinfo/role_hero_show_form_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("roleheroshow","roleheroshow"), type = ResourcesType.plist },
    }

    self.dic_hero_data = {}
end

function RoleHeroShowFormPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)

    self.add_res = PathTool.getResFrame("roleheroshow","roleheroshow_01")

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("展示设置"))

    self.close_btn = main_panel:getChildByName("close_btn")
    self.btn_save = self.main_container:getChildByName("btn_save")
    self.btn_save:getChildByName("label"):setString(TI18N("保存"))

    self.item_list = {}
    local width = HeroExhibitionItem.Width * 0.8
    for i=1,5 do
        local item_bg = self.main_container:getChildByName("item_bg_"..i)
        self.item_list[i] = {}
        self.item_list[i].item_btn = item_bg
        local item_node = item_bg:getChildByName("item_node")
        self.item_list[i].hero_item = HeroExhibitionItem.new(0.8, true, 0, true) 
        self.item_list[i].hero_item:setBgOpacity(128)
        item_node:addChild(self.item_list[i].hero_item)
        local x, y = item_node:getPosition()
        self.item_list[i].rect = cc.rect( x - width*0.5 ,y - width*0.5 , width, width)
        self.item_list[i].change_img = item_bg:getChildByName("lock_img")
    end 


    local camp_node = self.main_container:getChildByName("camp_node")
    self.camp_node = camp_node
    self.camp_btn_list = {}
    self.camp_btn_list[0] = camp_node:getChildByName("camp_btn0")
    self.camp_btn_list[HeroConst.CampType.eWater] = camp_node:getChildByName("camp_btn1")
    self.camp_btn_list[HeroConst.CampType.eFire]  = camp_node:getChildByName("camp_btn2")
    self.camp_btn_list[HeroConst.CampType.eWind]  = camp_node:getChildByName("camp_btn3")
    self.camp_btn_list[HeroConst.CampType.eLight] = camp_node:getChildByName("camp_btn4")
    self.camp_btn_list[HeroConst.CampType.eDark]  = camp_node:getChildByName("camp_btn5")
    self.img_select = camp_node:getChildByName("img_select")
    local x, y = self.camp_btn_list[0]:getPosition()
    self.img_select:setPosition(x - 0.5, y + 1)


    self.lay_srollview = self.main_container:getChildByName("lay_srollview")

    self.tip_name = self.main_container:getChildByName("tip_name")
    self.tip_name:setString(TI18N("长按可查看宝可梦信息"))
end

function RoleHeroShowFormPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose), false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose), true, 2)
    registerButtonEventListener(self.btn_save, handler(self, self.onClickBtnSave), true, 1)

    if self.item_list then
        self.long_touch_type = LONG_TOUCH_INIT_TYPE
        for i,item in ipairs(self.item_list) do
            item.hero_item:addTouchEventListener(function(sender, event_type)
                --播放动作中 和 数据为空
                if self.is_play_item_action then return end
                if self.hero_pos_list and self.hero_pos_list[i] == nil then return end
                if event_type == ccui.TouchEventType.began then
                    --有长点击效果
                    self.touch_began = sender:getTouchBeganPosition()
                    doStopAllActions(self.main_container)
                    self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
                    delayRun(self.main_container, 0.6, function ()
                        if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                            if self.hero_pos_list[i] then
                                HeroController:getInstance():openHeroTipsPanel(true, self.hero_pos_list[i])
                            end
                        end
                        self.long_touch_type = LONG_TOUCH_END_TYPE
                    end)
                elseif event_type == ccui.TouchEventType.moved then
                    if self.long_touch_type == LONG_TOUCH_END_TYPE then
                        --事件触发了就不处理移动事件了
                        return 
                    elseif self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        local touch_began = self.touch_began
                        local touch_end = sender:getTouchMovePosition()
                        if touch_began and touch_end and (math.abs(touch_end.x - touch_began.x) > 20 or math.abs(touch_end.y - touch_began.y) > 20) then 
                            --移动大于20了..表示取消长点击效果
                            doStopAllActions(self.main_container)
                            self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                        end 
                    end
                    self:onClickHeroItemMove(i, sender)
                elseif event_type == ccui.TouchEventType.canceled then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        doStopAllActions(self.main_container)
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                    elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                        --事件触发了就不处理点击事件了
                        if self.move_hero_item then
                            self.move_hero_item:setPosition(-10000, 0)
                        end
                        self:setHeroItemData(item.hero_item, self.hero_pos_list[i])
                        return
                    end

                    self:onClickHeroItemCanceled(i, sender)
                elseif event_type == ccui.TouchEventType.ended then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        doStopAllActions(self.main_container)
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                    elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                        --事件触发了就不处理点击事件了
                        if self.move_hero_item then
                            self.move_hero_item:setPosition(-10000, 0)
                        end
                        self:setHeroItemData(item.hero_item, self.hero_pos_list[i])
                        return
                    end

                    self:onClickHeroItemEnd(i, sender)
                end
            end)
        end
    end

       --阵营按钮
    if self.camp_btn_list then
        for select_camp, v in pairs(self.camp_btn_list) do
            registerButtonEventListener(v, function() self:onClickBtnShowByIndex(select_camp) end ,true, 2)
        end
    end

    --布阵信息返回
    self:addGlobalEvent(HeroEvent.Update_Fun_Form, function(data)
        if not data then return end
        self:setData(data)
    end)
    -- 设置布阵返回
    self:addGlobalEvent(HeroEvent.Update_Save_Form, function(data)
        if not data then return end
        if data.type == PartnerConst.Fun_Form.PersonalSpace then
            message(TI18N("保存宝可梦展示成功"))
            HeroController:getInstance():sender11211(PartnerConst.Fun_Form.PersonalSpace)
        end
    end)
end

--关闭
function RoleHeroShowFormPanel:onClickBtnClose()
    controller:openRoleHeroShowFormPanel(false)
end

--保存
function RoleHeroShowFormPanel:onClickBtnSave()
    --播放中不给发送
    if self.is_play_item_action then return end
    if not self.hero_pos_list then return end

    local pos_info = {}
    for i,v in pairs(self.hero_pos_list) do
        local d = {}
        d.pos = i
        d.id = v.partner_id
        table_insert(pos_info, d)
    end
    -- if #pos_info == 0 then
    --     message(TI18N("至少需要展示一个宝可梦"))
    --     return
    -- end
     HeroController:getInstance():sender11212(PartnerConst.Fun_Form.PersonalSpace, 1, pos_info, 0)
end

--显示根据类型 0表示全部
function RoleHeroShowFormPanel:onClickBtnShowByIndex(select_camp)
    if self.img_select and self.camp_btn_list[select_camp] then
        local x, y = self.camp_btn_list[select_camp]:getPosition()
        self.img_select:setPosition(x - 0.5, y + 1)
    end
    self:updateHeroList(select_camp)
end

function RoleHeroShowFormPanel:setHeroItemData(hero_item, data)
    if data then
        hero_item:setData(data)
        hero_item:showAddIcon(false)
        hero_item:setBgOpacity(255)
    else
        hero_item:setData(nil)
        hero_item:showAddIcon(true, self.add_res)
        hero_item:setBgOpacity(128)
    end
end


--点击5个宝可梦Item move
function RoleHeroShowFormPanel:onClickHeroItemMove(index, sender)
    if not self.hero_pos_list then return end
    --判断是否有移动
    self.is_move_hero = true

    if self.move_hero_item == nil then
        self.move_hero_item = HeroExhibitionItem.new(0.8, false)
        self.main_container:addChild(self.move_hero_item, 1)
    end
    self.move_hero_item:setData(self.hero_pos_list[index])
    self:setHeroItemData(self.item_list[index].hero_item, nil)

    local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.main_container:convertToNodeSpace(touch_pos) 
    self.move_hero_item:setPosition(target_pos)
end

--点击5个宝可梦Item Cancel
function RoleHeroShowFormPanel:onClickHeroItemCanceled(index, sender)
    if not self.hero_pos_list then return end
    self.is_move_hero = false
    if self.move_hero_item then
        --相当于隐藏
        self.move_hero_item:setPosition(-10000, 0)
    end
    
    local touch_pos = sender:getTouchMovePosition()
    for i,item in ipairs(self.item_list) do
        local target_pos = item.item_btn:convertToNodeSpace(touch_pos) 
        if cc.rectContainsPoint( item.rect, target_pos ) then
            if i ~= index then
                --转换
                local temp_hero_vo = self.hero_pos_list[i]
                self.hero_pos_list[i] = self.hero_pos_list[index]

                self:setHeroItemData(item.hero_item, self.hero_pos_list[i])
                self:setHeroItemData(self.item_list[index].hero_item, temp_hero_vo)

                if temp_hero_vo ~= nil then
                    self.hero_pos_list[index] = temp_hero_vo
                else
                    -- self.dic_hero_data[self.hero_pos_list[index].id] = nil
                    self.hero_pos_list[index] = nil
                end
                return
            else
                --点自己是下阵了 
                --这里系统直接执行 self:onClickHeroItemEnd()方法了
            end
        end
    end
    --上面没有遇到说不用交换 直接放回去
    self:setHeroItemData(self.item_list[index].hero_item, self.hero_pos_list[index])
end

--点击5个宝可梦Item end
function RoleHeroShowFormPanel:onClickHeroItemEnd(index, sender)
    if not self.hero_pos_list then return end
    if self.move_hero_item then
        --相当于隐藏
        self.move_hero_item:setPosition(-10000, 0)
    end

    -- if self.item_list[index] and self.item_list[index].can_touch then 
    --     for i,item in ipairs(self.item_list) do
    --         item.can_touch = false
    --         item.change_img:setVisible(false)
    --     end
    --     if self.select_index ~= 0 and self.show_list[self.select_index] then
    --         local hero_vo = self.show_list[self.select_index]

    --     end
    -- end

    -- --说明是点击了 item 下阵
    if self.list_view then
        local cell_list = self.list_view:getActiveCellList() or {}
        for i,item in ipairs(cell_list) do
            local hero_vo = item:getData()
            if hero_vo and hero_vo.partner_id == self.hero_pos_list[index].partner_id then

                item:setSelected(false)
                --结束位置 
                local world_pos = item:convertToWorldSpace(cc.p(HeroExhibitionItem.Width * 0.5, HeroExhibitionItem.Height * 0.5))    
                local end_pos = self.main_container:convertToNodeSpace(world_pos) 
                local x, y =  self.item_list[index].item_btn:getPosition()
                self:showMoveEffect(cc.p(x,y), end_pos, hero_vo)

                self:setHeroItemData(self.item_list[index].hero_item, nil)
                self.hero_pos_list[index] = nil
                self.dic_hero_data[hero_vo.id] = nil
                return
            end
        end
    end
    --上面没有找到 直接下阵
    local hero_vo = self.hero_pos_list[index]
    local item = self.camp_btn_list[hero_vo.camp_type]
    if item == nil then
        --默认是全部那个
        item = self.camp_btn_list[0]
    end
    local world_pos = item:convertToWorldSpace(cc.p(58 * 0.5, 58 * 0.5))    
    local end_pos = self.main_container:convertToNodeSpace(world_pos) 
    local x, y =  self.item_list[index].item_btn:getPosition()
    self:showMoveEffect(cc.p(x,y), end_pos, hero_vo)

    self:setHeroItemData(self.item_list[index].hero_item, nil)

    self.dic_hero_data[hero_vo.id] = nil
    self.hero_pos_list[index] = nil
end



--显示移动效果
--@start_pos 开始位置 
--@end_pos 结束位置
function RoleHeroShowFormPanel:showMoveEffect(start_pos, end_pos, hero_vo, callback)
    self.is_play_item_action = true
    if self.move_hero_item == nil then
        self.move_hero_item = HeroExhibitionItem.new(0.8, false)
        self.main_container:addChild(self.move_hero_item, 1)
    end
    self.move_hero_item:setData(hero_vo)
    self.move_hero_item:setPosition(start_pos)
    local action1 = cc.MoveTo:create(0.2, end_pos)
    local callfunc = cc.CallFunc:create(function()
        if self.move_hero_item then
            self.move_hero_item:setPosition(-10000, 0)
        end
        self.is_play_item_action = false
        if callback then
            callback()
        end
    end)
    self.move_hero_item:runAction(cc.Sequence:create(action1,callfunc))
end

-- function RoleHeroShowFormPanel:updateEquipInfo(data)
--     if data.id == 0 then
--         --卸下
--         if self.hero_pos_list[data.pos] then
--             self.dic_hero_data[self.hero_pos_list[data.pos].id] = nil
--         end
--         self.hero_pos_list[data.pos] = nil
--         self:updateItemByindex(data.pos)

--         for i,item in ipairs(self.item_list) do
--             item.can_touch = false
--             item.change_img:setVisible(false)
--         end
--     else
--         --装备
--         local new_data = {pos = data.pos, id = data.id}
--         self.hero_pos_list[data.pos] = new_data
--         self.dic_hero_data = {}
--         for k,v in pairs(self.hero_pos_list) do
--             self.dic_hero_data[v.id] = v
--         end
--         self.dic_hero_data[data.id] = new_data
--         self:updateItemByindex(data.pos, new_data)
--     end

--     if self.list_view then
--         self.list_view:resetCurrentItems()
--     end
-- end


function RoleHeroShowFormPanel:openRootWnd(setting)
   
    HeroController:getInstance():sender11211(PartnerConst.Fun_Form.PersonalSpace)
end

function RoleHeroShowFormPanel:setData(data)    
    --选中宝可梦信息 [id] = hero_vo
    self.dic_hero_data = {}
    --位置上的宝可梦信息 [pos] = hero_vo
    self.hero_pos_list = {}
    if data and data.pos_info then
        for i,v in ipairs(data.pos_info) do
            local hero_data = hero_model:getHeroById(v.id)
            self.hero_pos_list[v.pos] = hero_data
            self.dic_hero_data[v.id] = hero_data
        end
    end
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            if self.hero_pos_list[i] then
                self:updateItemByindex(i, self.hero_pos_list[i])
            else
                self:updateItemByindex(i)
            end
        end
    end
    self:updateHeroList(self.select_camp)
end

function RoleHeroShowFormPanel:updateItemByindex(index, data)
    if self.item_list[index] then
        self.item_list[index].change_img:setVisible(false)
        if data then
            self.item_list[index].hero_item:setData(data)
            self.item_list[index].hero_item:setBgOpacity(255)
            self.item_list[index].hero_item:showAddIcon(false)
        else
            self.item_list[index].hero_item:setData(nil)
            self.item_list[index].hero_item:setBgOpacity(128)
            self.item_list[index].hero_item:showAddIcon(true, self.add_res)
        end
    end
end

--显示可替换图片
function RoleHeroShowFormPanel:showChangeImg()
    for i,item in ipairs(self.item_list) do
        if self.hero_pos_list[i] then
            item.change_img:setVisible(true)
            item.can_touch = true
        else
            item.change_img:setVisible(false)
        end
    end
end

--检查是否有空位置可方法
-- @ return 是否有空位, 空位索引
function RoleHeroShowFormPanel:checkHeroEmptyList()
    if not self.hero_pos_list then return false end
    for i,item in ipairs(self.item_list) do
        if self.hero_pos_list[i] == nil then
            return true, i
        end
    end
    return false
end

--获取宝可梦信息列表
function RoleHeroShowFormPanel:getHeroListByCamp(select_camp)
    local hero_list = hero_model:getHeroList()
    local show_list = {}
    for k, hero_vo in pairs(hero_list) do
        if hero_vo and  not hero_vo:isResonateHero() and (select_camp == 0 or (select_camp == hero_vo.camp_type)) then
            -- 锁定 , 上阵, 7星以上都不能被分解
            table_insert(show_list, hero_vo)
        end
    end 
    local sort_func = SortTools.tableUpperSorter({"star", "lev", "camp_type", "bid", "sort_order"})
    table_sort(show_list, sort_func) 

    return show_list
end

--创建宝可梦列表 
function RoleHeroShowFormPanel:updateHeroList(select_camp)
    if not self.lay_srollview then return end
    local select_camp = select_camp or 0
    if self.select_camp and select_camp == self.select_camp then 
        return
    end

    if self.list_view == nil then
        local scroll_view_size = self.lay_srollview:getContentSize()
        local list_setting = {
            start_x = 1,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = 120,
            item_height = 120,
            row = 0,
            col = 5,
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.select_camp = select_camp
    self.show_list = self:getHeroListByCamp(self.select_camp)

    self.list_view:reloadData()

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("暂无该类型宝可梦")})
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function RoleHeroShowFormPanel:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(0.9, true)
    cell:setLongTimeTouchEffect(true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function RoleHeroShowFormPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function RoleHeroShowFormPanel:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.show_list[index]
    if not hero_vo then return end
    cell:setData(hero_vo)
    -- if self.select_index and self.select_index == index then
    --     cell:setBoxSelected2(true)
    -- else
    --     cell:setBoxSelected2(false)
    -- end

    if self.dic_hero_data[hero_vo.id] then
        cell:setSelected(true)
    else
        cell:setSelected(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function RoleHeroShowFormPanel:onCellTouched(cell)
    if self.is_play_item_action then return end
    if not self.dic_hero_data then return end
    local index = cell.index
    local hero_vo = self.show_list[index]
    if not hero_vo then return end

    -- if self.select_cell then
    --     self.select_cell:setBoxSelected2(false)
    -- end
    -- self.select_cell = cell
    -- self.select_cell:setBoxSelected2(true)
    -- self.select_index = index

    --说明在上阵中 下阵
    if self.dic_hero_data[hero_vo.partner_id] ~= nil then
        local s_index = -1
        for i,v in pairs(self.hero_pos_list) do
            if v.partner_id == hero_vo.partner_id then
                s_index = i
                break
            end
        end
        if  s_index == -1 then
            -- self.dic_hero_data[hero_vo.partner_id] = nil
            return 
        end

        if self.item_list[s_index] == nil then return end
        --是选中的 下阵了
        cell:setSelected(false)
        --结束位置 
        local world_pos = cell:convertToWorldSpace(cc.p(HeroExhibitionItem.Width * 0.5, HeroExhibitionItem.Height * 0.5))    
        local end_pos = self.main_container:convertToNodeSpace(world_pos) 
        local x, y =  self.item_list[s_index].item_btn:getPosition()

        self:showMoveEffect(cc.p(x,y), end_pos, hero_vo)

        self:setHeroItemData(self.item_list[s_index].hero_item, nil)
        self.hero_pos_list[s_index] = nil
        self.dic_hero_data[hero_vo.partner_id] = nil
    else
        local is_have, pos_index = self:checkHeroEmptyList()
        if is_have then
            -- 有位置 要上阵
            local world_pos = cell:convertToWorldSpace(cc.p(HeroExhibitionItem.Width * 0.5, HeroExhibitionItem.Height * 0.5))    
            local start_pos = self.main_container:convertToNodeSpace(world_pos) 
            local x, y =  self.item_list[pos_index].item_btn:getPosition()
            self:showMoveEffect(start_pos, cc.p(x,y), hero_vo, function()
                if self.item_list and self.item_list[pos_index] then
                    self.hero_pos_list[pos_index] = hero_vo
                    self.dic_hero_data[hero_vo.partner_id] = hero_vo
                    self:setHeroItemData(self.item_list[pos_index].hero_item, hero_vo)
                end
            end)
            cell:setSelected(true)
        else
            message(TI18N("展示宝可梦已满"))
            -- self:showChangeImg()
        end    
    end 
end



function RoleHeroShowFormPanel:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end 

    if self.item_load_title_img then 
        self.item_load_title_img:DeleteMe()
        self.item_load_title_img = nil
    end

    if self.item_list then
        for i,v in ipairs(self.item_list) do
            if v.item_load then
                v.item_load:DeleteMe()
                v.item_load = nil
            end
        end
    end

    doStopAllActions(self.main_containe)
    controller:openRoleHeroShowFormPanel(false)
end

