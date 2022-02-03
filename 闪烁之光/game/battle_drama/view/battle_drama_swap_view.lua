-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      扫荡次数界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

BattlDramaSwapWindow = BattlDramaSwapWindow or BaseClass(BaseView)

local controller = BattleDramaController:getInstance() 
local model = BattleDramaController:getInstance():getModel()

function BattlDramaSwapWindow:__init(dun_id)
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.dun_id = dun_id
    self.layout_name = "battledrama/battle_drama_swap_view"
end

function BattlDramaSwapWindow:open_callback()
    self.panel_bg = self.root_wnd:getChildByName("Panel_bg")
    self.background = self.panel_bg:getChildByName("background")
    self.panel_bg:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("root")
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.ack_button = self.main_container:getChildByName("ack_button")
    self.ack_button.label = self.ack_button:getTitleRenderer()
    self.ack_button.label:enableOutline(Config.ColorData.data_color4[82], 2)
    self.swap_num_desc = self.main_container:getChildByName("swap_num_desc")
    self.swap_num_desc:setString(TI18N("扫荡卷的数量:"))
    self.swap_num = self.main_container:getChildByName("swap_num")
    local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const["swap_item"].val)
    self.swap_num:setString(num)
    -- self.title_label = self.main_container:getChildByName("title_label")
    -- self.title_label:setString(TI18N("选择您想要扫荡的次数"))

    self.swap_num_label = createRichLabel(24, 117, cc.p(0.5, 0.5), cc.p(365, 630), nil, nil, 1000)
    self.main_container:addChild(self.swap_num_label)
    self.swap_num_label:setVisible(true)
    self.icon = self.main_container:getChildByName("icon")
    local icon = Config.ItemData.data_get_data(Config.DungeonData.data_drama_const["swap_item"].val).icon
    self.icon:loadTexture(PathTool.getItemRes(icon), LOADTEXT_TYPE)
    self.num_bar = CommonNumBar.New(self.main_container, cc.size(165, 52), 20)
    self.num_bar:setMinSuffix(1)
    self.num_bar:setAnchorPoint(0, 1)
    self.num_bar:setPosition(285, 705)
    self.num_bar:setNum(1)
    self.num_bar.background:setContentSize(cc.size(165, 52))
    local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    if drama_data then
        if self.num_bar then
            self.num_bar:registerHandle(function (type,num)
                local swap_item_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const["swap_item"].val)
                local data = model:getCurDunInfoByID(self.dun_id)
                if data and data.auto_num then
                    local remain_swap_num =  drama_data.auto_num_max - data.auto_num
                    local min_num = math.min(swap_item_num,remain_swap_num) --求出2者最少值
                    if type == "add" or "push" then --增加
                        if num > min_num then --如果增加数量大于最少值
                            message(TI18N("已达最大次数"))
                            self.num_bar:setNum(min_num)
                            return 
                        end
                    elseif type == "sub" then -- 减少
                    end
                end
            end)    
        end
        local data  = model:getCurDunInfoByID(self.dun_id)
        if data and data.auto_num then
            local str = string.format(TI18N("<div fontColor=#68452a>(剩余:%s次)</div>"),drama_data.auto_num_max - data.auto_num)
            self.swap_num_label:setString(str)
        end
    end
end

function BattlDramaSwapWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openDramSwapView(false) 
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openDramSwapView(false) 
            end
        end)
    end
    if self.ack_button then
        self.ack_button:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.dun_id then
                    self.num = self.num_bar:getNum()
                    if self.num and self.num ~= 0 then
                        controller:send13005(self.dun_id,self.num)
                    else
                        message("请选择扫荡次数")
                    end
                end
            end
        end)
    end
end



function BattlDramaSwapWindow:openRootWnd(type)
end

function BattlDramaSwapWindow:close_callback()
    if self.num_bar then
        self.num_bar:DeleteMe()
    end
    controller:openDramSwapView(false)
end