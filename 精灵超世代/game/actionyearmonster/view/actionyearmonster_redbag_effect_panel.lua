-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: lwc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      红包打开流程界面
-- <br/>Create: 2020年1月8日
-- --------------------------------------------------------------------

ActionyearmonsterRedbagEffectPanel = ActionyearmonsterRedbagEffectPanel or BaseClass(BaseView)
function ActionyearmonsterRedbagEffectPanel:__init()
    self.ctrl = ActionyearmonsterController:getInstance()
    self.is_full_screen = false
    self.layout_name = 'redbag/redbg_open_view'
    self.res_list = {

    }
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
    self.is_can_close = false
end

function ActionyearmonsterRedbagEffectPanel:open_callback()
    self.background = self.root_wnd:getChildByName('background')
    self.background:setScale(display.getMaxScale())
    self.background:setVisible(true)
    self.main_panel = self.root_wnd:getChildByName('main_container')
    self:playEnterAnimatianByObj(self.main_panel, 2)
    self.main_panel:setTouchEnabled(true)
    self.main_panel:setScale(display.getMaxScale())
end

function ActionyearmonsterRedbagEffectPanel:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openActionyearmonsterRedbagEffectPanel(false)
        end
    end)
end

function ActionyearmonsterRedbagEffectPanel:openRootWnd(data)
    self.data = data 
    if data then
        self:showAfterEffect()
    end
end

function ActionyearmonsterRedbagEffectPanel:showAfterEffect()
    if self.after_effect then
        self.after_effect:runAction(cc.RemoveSelf:create(true))
        self.after_effect = nil
    end
    if not self.after_effect then
        self.after_effect = createEffectSpine(PathTool.getEffectRes(332), cc.p(self.main_panel:getContentSize().width / 2, self.main_panel:getContentSize().height / 2), cc.p(0.5, 0.5), false, PlayerAction.action)
        self.main_panel:addChild(self.after_effect)
        delayOnce(function()
            if self.data then
                local list = {}
                if self.data.role_reward_list and next(self.data.role_reward_list) ~= nil then
                    for i,v in ipairs(self.data.role_reward_list) do
                        table.insert(list, {bid = v.role_base_id, num = v.role_num})
                    end
                end
                if next(list) == nil  then
                    list = {{bid = 1, num = 10}}
                end   
                MainuiController:getInstance():openGetItemView(true, list, nil, {is_backpack = true, is_year_red_bag = true,info_data = self.data})
                self.ctrl:openActionyearmonsterRedbagEffectPanel(false)
            end
        end,1)
    end
end

function ActionyearmonsterRedbagEffectPanel:close_callback()
    if self.after_effect then
        self.after_effect:runAction(cc.RemoveSelf:create(true))
        self.after_effect = nil
    end

    self.ctrl:openActionyearmonsterRedbagEffectPanel(false)
end
