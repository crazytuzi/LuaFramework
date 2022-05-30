-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      冒险情报tip面板
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaQingBaoTipsView = BattleDramaQingBaoTipsView or BaseClass(BaseView)

local controller = BattleDramaController:getInstance() 
local model = BattleDramaController:getInstance():getModel()

function BattleDramaQingBaoTipsView:__init()
    self.layout_name = "battledrama/battle_drama_qingbao_tips_view"
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {}
    self.quick_battle_status = 0 --0是免费,1是有道具,2是用钱
    self.role_vo = RoleController:getInstance():getRoleVo()
end
function BattleDramaQingBaoTipsView:open_callback()
    self.panel_bg = self.root_wnd:getChildByName("Panel_bg")
    self.background = self.panel_bg:getChildByName("background")
    self.panel_bg:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.desc_label = createLabel(24, Config.ColorData.data_color3[175],nil, 360,800, "", self.main_container, 2, cc.p(0.5, 0.5))
    self.desc_label:setWidth(550)
    self.reward_label = self.main_container:getChildByName("reward_label")
    self.reward_label:setString(TI18N("冒险奖励"))
    self.title_label = self.main_container:getChildByName("title_label")
    self.title_label:setString(TI18N("小提示"))
    self.go_btn = self.main_container:getChildByName("go_btn")
    self.go_btn.label = self.go_btn:getTitleRenderer()
    if self.go_btn.label ~= nil then
        self.go_btn:setTitleText(TI18N("前往冒险"))
        self.go_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
    self.item_crollView = self.main_container:getChildByName("item_crollView")
    self.item_crollView:setScrollBarEnabled(false)
end

function BattleDramaQingBaoTipsView:updateData(data)
    local str = TI18N("  冒险情报用于神界冒险中探索新的岛屿，完成事件后可获得丰厚金币和道具奖励")
    local max_energy_num = BattleDramaController:getInstance():getModel():getMaxEnergyMax()

    if Config.DungeonData.data_drama_const and max_energy_num and self.role_vo then
        if self.role_vo.energy >= max_energy_num then
            str = TI18N("  冒险情报已满，无法继续增加，建议前往冒险探索")
        else
            str = TI18N("  冒险情报用于神界冒险中探索新的岛屿，完成事件后可获得丰厚金币和道具奖励")
        end
    end
    self.desc_label:setString(str)
    if Config.DungeonData.data_drama_const and Config.DungeonData.data_drama_const["advanture_item"] then
        local data = Config.DungeonData.data_drama_const["advanture_item"].val
        self:updateItem(data)
    end
end

function BattleDramaQingBaoTipsView:updateItem(data)
    if not data then return end
    local item = nil
    local single_item_height = BackPackItem.Height + 10
    local single_item_width = BackPackItem.Width  + 20
    local item_height = (single_item_height) * (math.floor(tableLen(data) / 4)) + (5 * tableLen(data) % 4) + single_item_height
    local max_height = math.max(self.item_crollView:getContentSize().height,item_height)
    self.item_crollView:setInnerContainerSize(cc.size(self.item_crollView:getContentSize().width, max_height))
    for i, v in ipairs(data) do
        if not self.item_list[i] then
            local item = BackPackItem.new(true, true)
            item:setBaseData(v[1], v[2])
            --item:setScale(0.9)
            item:setAnchorPoint(cc.p(0, 1))
            item:setDefaultTip()
            self.item_crollView:addChild(item)
            --item:getNumLable():setVisible(false)
            item:setPosition(10 + single_item_width * ((i - 1) % 4), max_height - single_item_height * math.floor((i - 1) / 4) - 10)
            self.item_list[i] = item
        end
    end
end
function BattleDramaQingBaoTipsView:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openBattleDramaQingBaoTipsView(false) 
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openBattleDramaQingBaoTipsView(false)
            end
        end)
    end
    if self.go_btn then
        self.go_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                -- MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.sky_scene)
            end
        end)
    end

    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "energy" then
                    local str = TI18N("  冒险情报用于神界冒险中探索新的岛屿，完成事件后可获得丰厚金币和道具奖励")
                    local max_energy_num = BattleDramaController:getInstance():getModel():getMaxEnergyMax()
                    if Config.DungeonData.data_drama_const and max_energy_num and self.role_vo then
                        if self.role_vo.energy >= max_energy_num then
                            str = TI18N("  冒险情报已满，无法继续增加，建议前往冒险探索")
                        else
                            str = TI18N("  冒险情报用于神界冒险中探索新的岛屿，完成事件后可获得丰厚金币和道具奖励")
                        end
                    end
                    self.desc_label:setString(str)
                end
            end)
        end
    end
end


function BattleDramaQingBaoTipsView:openRootWnd(data)
    self:updateData(data)
end

function BattleDramaQingBaoTipsView:close_callback()
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end
    controller:openBattleDramaQingBaoTipsView(false)
end
