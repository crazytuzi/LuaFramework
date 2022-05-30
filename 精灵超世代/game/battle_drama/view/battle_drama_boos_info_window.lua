-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      剧情副本boss信息界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattlDramaBossInfoWindow = BattlDramaBossInfoWindow or BaseClass(BaseView)

local controller = BattleDramaController:getInstance()
local model = BattleDramaController:getInstance():getModel()

function BattlDramaBossInfoWindow:__init(data)
    self.dungeon_data = data
    self.layout_name = "battledrama/battle_darma_boos_info_windows"
    self.res_list = {
            { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_5"), type = ResourcesType.single },
        }
    self.swap_status = 0 --0:不可挑战,1可挑战,2,扫荡
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {}
end
function BattlDramaBossInfoWindow:open_callback()
    self.panel_bg = self.root_wnd:getChildByName("Panel_bg")
    self.background = self.panel_bg:getChildByName("background")
    self.panel_bg:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.ack_button = self.main_container:getChildByName("ack_button")
    -- self.ack_button.label = self.ack_button:getTitleRenderer()
    -- self.ack_button.label:enableOutline(Config.ColorData.data_color4[156], 2)
    self.window_title_label = self.main_container:getChildByName("window_title_label")
    self.window_title_label:setString(TI18N("关卡信息"))
    self.dungeon_name = self.main_container:getChildByName("dungeon_name")
    --self.boss_name_desc = self.main_container:getChildByName("boss_name_desc")
    --self.boss_name_desc:setString(TI18N("BOSS:"))
    self.boss_name = self.main_container:getChildByName("boss_name")
    --self.diffcult_label_desc = self.main_container:getChildByName("diffcult_label_desc")
    --self.diffcult_label_desc:setString(TI18N("战斗力:"))
    --self.diffcult_label = self.main_container:getChildByName("diffcult_label")
    self.item_container = self.main_container:getChildByName("item_container")
    self.title_label = self.item_container:getChildByName("title_label")
    self.title_label:setString(TI18N("可能掉落"))
    self.item_scroolview = self.item_container:getChildByName("item_scroolview")
    self.item_scroolview:setScrollBarEnabled(false)
    self.role_bg = self.main_container:getChildByName("role_bg")
    --if self.role_bg ~= nil then
    --    loadSpriteTexture(self.role_bg,PathTool.getPlistImgForDownLoad("bigbg", "bigbg_5"), LOADTEXT_TYPE)
    --end
    self.swap_label = createRichLabel(24, 117, cc.p(0, 0.5), cc.p(70,370), nil, nil, 1000)
    self.main_container:addChild(self.swap_label)
    self.swap_label:setVisible(false)
  
    self.swap_num_label = createRichLabel(26, 117, cc.p(0, 0.5), cc.p(410,685), nil, nil, 1000)
    self.main_container:addChild(self.swap_num_label)
    self.swap_num_label:setVisible(false)

    self.free_swap_label = createRichLabel(26, 117, cc.p(0, 0.5), cc.p(485,330), nil, nil, 1000)
    self.free_swap_label:setString(TI18N("本次扫荡免费"))
    self.main_container:addChild(self.free_swap_label)
    self.free_swap_label:setVisible(false)


    self.fight_bg = self.main_container:getChildByName("Image_41")

    self.fight_label = CommonNum.new(20, self.fight_bg, 99999, - 2, cc.p(0.5, 0.5))
    self.fight_label:setPosition(self.fight_bg:getContentSize().width/2, self.fight_bg:getContentSize().height/2 +14)

    self:updateData()
end

function BattlDramaBossInfoWindow:updateData()
    if self.dungeon_data then
        self.dungeon_name:setString(self.dungeon_data.info_data.name)
        --self.boss_name:setString(self.dungeon_data.info_data.name)
        local config = Config.UnitData.data_unit(self.dungeon_data.info_data.unit_id)
        local cur_dungeon_data = model:getCurDunInfoByID(self.dungeon_data.info_data.id) or self.dungeon_data.v_data
        local status = cur_dungeon_data.status
        if config then
            self.boss_name:setString(config.name)
        end
        --self.diffcult_label:setString(self.dungeon_data.info_data.power)
        self.fight_label:setNum(self.dungeon_data.info_data.power)
        local str = string.format(TI18N("<div fontColor=#764519>扫荡次数: </div><div fontColor=#249003>%s</div>/%s"),cur_dungeon_data.auto_num, Config.DungeonData.data_drama_const["swap_time"].val)
        if cur_dungeon_data.auto_num >= Config.DungeonData.data_drama_const["swap_time"].val then
            str = string.format(TI18N("<div fontColor=#764519>扫荡次数: </div><<div fontColor=#249003>%s/%s</div>"),cur_dungeon_data.auto_num, Config.DungeonData.data_drama_const["swap_time"].val)
        end
        self.swap_num_label:setString(str)
        
        local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const["swap_item"].val)
        local item_icon = Config.ItemData.data_get_data(Config.DungeonData.data_drama_const["swap_item"].val).icon
        -- local str = string.format(TI18N("<img src=%s visible=true scale=0.5 /> <div fontColor=#764519>扫荡券的数量: </div><div fontColor=#289b14 fontsize= 26>%s</div>"),PathTool.getItemRes(item_icon),num)
        -- self.swap_label:setString(str)
        self:updateItemReward(self.dungeon_data.info_data.show_items)
        self:updateRole(config.body_id)
        local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
        local offset_num = Config.DungeonData.data_drama_const["swap_time"].val - drama_data.auto_num
        if drama_data and offset_num <= 0 then
            -- self.ack_button:setTouchEnabled(false)
            -- self.ack_button.label:disableEffect(cc.LabelEffect.OUTLINE)
            -- setChildUnEnabled(true, self.ack_button)
        else
            self:updateBtnStatus(status)
            self:updateFreeData()
        end        
    end
end
function BattlDramaBossInfoWindow:updateFreeData()
    local free_num = Config.DungeonData.data_drama_const['free_swap'].val
    local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    self.is_free = drama_data.auto_num - free_num < 0
    -- self.free_swap_label:setVisible(self.is_free)
end
function BattlDramaBossInfoWindow:updateBtnStatus(status)
    if status == 3 then --已通关
        self.swap_status = 2
        -- self.ack_button:setTouchEnabled(true)
        --self.swap_num_label:setVisible(true)
        -- setChildUnEnabled(false, self.ack_button)
        -- self.ack_button:setTitleText(TI18N("扫荡"))
        -- self.ack_button.label:enableOutline(Config.ColorData.data_color4[82], 2)
    else
        self.swap_status = 0
        --self.ack_button:setTouchEnabled(false)
        --self.swap_num_label:setVisible(false)
        -- setChildUnEnabled(true, self.ack_button)
        -- self.ack_button:setTitleText(TI18N("挑战"))
        -- self.ack_button.label:enableOutline(Config.ColorData.data_color4[84], 2)
        --如果倒计时还是大于0
        if status == 2 then
            -- self.ack_button:setTouchEnabled(true)
            -- setChildUnEnabled(false, self.ack_button)
            self.swap_status = 1
            -- self.ack_button.label:enableOutline(Config.ColorData.data_color4[82], 2)
        end
 
    end
end
function BattlDramaBossInfoWindow:updateRole(body_id)
    if not self.spine_model and body_id ~= "" then
        self.spine_model = createSpineByName(body_id, PlayerAction.show)
        self.spine_model:setPosition(self.role_bg:getContentSize().width / 2, self.role_bg:getContentSize().height/2)
        self.spine_model:setScale(1.5)
        self.role_bg:addChild(self.spine_model)
        self.spine_model:setAnimation(0, PlayerAction.show, true)
    end
end

function BattlDramaBossInfoWindow:updateItemReward(data)
    if not data then return  end
    local item = nil
    local item_width = BackPackItem.Width * #data + #data * 10
    local max_width = math.max(self.item_scroolview:getContentSize().width, item_width)
    self.item_scroolview:setInnerContainerSize(cc.size(max_width, self.item_scroolview:getContentSize().height))
    for i, v in ipairs(data) do
        if not self.item_list[i] then
            item = BackPackItem.new(true,true)
            item:setAnchorPoint(0.5,0.5)
            self.item_scroolview:addChild(item)
            self.item_list[i] = item
        end
        item = self.item_list[i]
        if item then
            item:setPosition(BackPackItem.Width/2 + (i-1) * (BackPackItem.Width + 10),self.item_scroolview:getContentSize().height/2)
            local temp_data = {bid = v[1],num = v[2]}
            item:setBaseData(v[1],v[2],true)
            --local config = Config.ItemData.data_get_data(v[1])
            -- local is_equip = item:checkIsEquip(config.type)
            -- if is_equip == true then
            --     self:setEquipJie(true)
            -- end
            item:setDefaultTip()
        end
    end
end

function BattlDramaBossInfoWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openDramBossInfoView(false) 
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openDramBossInfoView(false) 
            end
        end)
    end
    -- if self.ack_button then
    --     self.ack_button:addTouchEventListener(function(sender, event_type)
    --         if event_type == ccui.TouchEventType.ended then
    --             playButtonSound2()
    --             if self.dungeon_data then
    --                 if self.swap_status == 2 then
    --                     self:checkSwapAlert()
    --                 elseif self.swap_status == 1 then
    --                     BattleDramaController:getInstance():openDramBattleAutoCombatView(true)
    --                 else
    --                     message("尚未达到挑战条件")
    --                 end
    --             end
    --         end
    --     end)
    -- end
    if not self.update_dram_boss_data_event then
        self.update_dram_boss_data_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Boss_Update_Data, function(data)
            if data then
                local str = string.format("<div fontColor=#764519>扫荡次数: </div><div fontColor=#289b14>%s</div>/%s",data.auto_num, Config.DungeonData.data_drama_const["swap_time"].val)
                if data.auto_num >= Config.DungeonData.data_drama_const["swap_time"].val then
                    str = string.format(TI18N("<div fontColor=#764519>扫荡次数: </div> <div fontColor=#249003>%s</div><div fontColor=#249003>/%s</div>"),data.auto_num, Config.DungeonData.data_drama_const["swap_time"].val)
                end
                self.swap_num_label:setString(str)
                local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const["swap_item"].val)
                -- str = string.format("扫荡券的数量:<div fontColor=#289b14>%s</div>", num)
                -- self.swap_label:setString(str)
    
            end
        end)
    end
    if not self.update_dram_data_event then
        self.update_dram_data_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Update_Data, function(data)
            self:updateData()
        end)
    end
    if not self.update_drama_quick then
         self.update_drama_quick = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Quick_Battle_Data, function(data)
           self:updateFreeData()
        end)
    end
end

function BattlDramaBossInfoWindow:checkSwapAlert()
    local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const['swap_item'].val)
    if not self.is_free then
        if num <= 0 then --扫荡券不足
            local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
            local swap_num = math.min(drama_data.auto_num + 1, tableLen(Config.DungeonData.data_swap_data))
            -- mjb("@@@@@@",swap_num)
            local loss = Config.DungeonData.data_swap_data[swap_num].loss

            local str = string.format(TI18N("扫荡券不足,是否使用<img src=%s visible=true scale=0.5 /><div fontColor=#289b14 fontsize= 26>%s</div>扫荡关卡?"),PathTool.getItemRes(loss[1][1]),loss[1][2])
            local call_back = function()
                if self.dungeon_data and self.dungeon_data.info_data then
                    BattleDramaController:getInstance():send13005(self.dungeon_data.info_data.id,1)
                end
            end
            CommonAlert.show(str, TI18N('确定'), call_back, TI18N('取消'), nil, CommonAlert.type.rich)
        else
            controller:openDramSwapView(true, self.dungeon_data.info_data.id)
        end
    else
        if self.dungeon_data and self.dungeon_data.info_data then
            BattleDramaController:getInstance():send13005(self.dungeon_data.info_data.id, 1)
        end
    end
end

function BattlDramaBossInfoWindow:openRootWnd(type)
end

function BattlDramaBossInfoWindow:close_callback()
    if self.update_dram_data_event then
        GlobalEvent:getInstance():UnBind(self.update_dram_data_event)
        self.update_dram_data_event = nil
    end
    if self.update_drama_quick then
        GlobalEvent:getInstance():UnBind(self.update_drama_quick)
        self.update_drama_quick = nil
    end
    if self.update_dram_boss_data_event then
        GlobalEvent:getInstance():UnBind(self.update_dram_boss_data_event)
        self.update_dram_boss_data_event = nil
    end
    controller:openDramBossInfoView(false)
end
