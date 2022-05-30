-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      战斗领取界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessAwardsTips = EndlessAwardsTips or BaseClass(BaseView)

local controller = Endless_trailController:getInstance()
local model = Endless_trailController:getInstance():getModel()
local string_format = string.format

function EndlessAwardsTips:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.item_list = {}
    self.is_full_screen = false
    self.layout_name = "endlesstrail/endlesstrail_awards_tips"
end

function EndlessAwardsTips:open_callback()
    self.background_panel = self.root_wnd:getChildByName("background_panel")
    self.background = self.background_panel:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
    self.main_container = self.main_panel:getChildByName("main_container")
    self.desc_label = self.main_panel:getChildByName("desc_label")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn.label = self.ok_btn:getChildByName("label")
    self.ok_btn.label:setString(TI18N("领取"))
    self.title_container = self.main_panel:getChildByName("title_container")
    self.title_label = self.title_container:getChildByName("title_label")
    self.title_label:setString(TI18N("奖励"))
end

function EndlessAwardsTips:register_event()
   if self.background then
        self.background:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    controller:openEndlessRewardTips(false) 
                end
            end
        )
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(
            function(sender, event_type)
                customClickAction(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    controller:openEndlessRewardTips(false) 
                end
            end
        )
    end
    if self.ok_btn then
        self.ok_btn:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    if self.data then
                        local base_data = model:getEndlessBattleData()
                        if base_data then
                            controller:send23904(self.data.id,base_data.type)
                        end
                    end
                end
            end
        )
    end

end

function EndlessAwardsTips:openRootWnd(data)
    self.data = data 
    local base_data = model:getEndlessBattleData()
    if data and base_data then
        if Config.EndlessData.data_first_data and Config.EndlessData.data_first_data[base_data.type] and Config.EndlessData.data_first_data[base_data.type][self.data.id] then
            local config = Config.EndlessData.data_first_data[base_data.type][self.data.id]
            self:updateItemData(config)
        end
    end
end

function EndlessAwardsTips:updateItemData(config)
    if config then
        local str  = string.format(TI18N("第%s关首通奖励"),config.limit_id)
        self.desc_label:setString(str)
        local sum = #config.items
        self.space = 30
        local total_width = sum * BackPackItem.Width + (sum - 1) * self.space
        self.start_x = (self.main_container:getContentSize().width - total_width) * 0.5

        for i, v in ipairs(config.items) do
            if not self.item_list[i] then
                local item = BackPackItem.new(true,true)
                item:setBaseData(v[1],v[2])
                local _x = self.start_x + BackPackItem.Width * 0.5 + (i - 1) * (BackPackItem.Width + self.space)
                item:setPosition(cc.p(_x, self.main_container:getContentSize().height/2))
                item:setDefaultTip()
                self.main_container:addChild(item)
                self.item_list[i] = item
            end
        end
    end
    if self.data then
        if self.data.status == TRUE then
            if self.ok_btn.label then
                setChildUnEnabled(false, self.ok_btn)
                --self.ok_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
                self.ok_btn.label:setString(TI18N("领取"))
            end
        else
            if self.ok_btn.label then
                setChildUnEnabled(true,self.ok_btn)
                --self.ok_btn.label:disableEffect(cc.LabelEffect.OUTLINE)
                self.ok_btn.label:setString(TI18N("不可领取"))
            end
        end
    end

end


function EndlessAwardsTips:close_callback()
    controller:openEndlessRewardTips(false)
end
