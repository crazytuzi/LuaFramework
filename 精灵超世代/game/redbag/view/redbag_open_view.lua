-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      红包打开流程界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

RedBagOpenView = RedBagOpenView or BaseClass(BaseView)
function RedBagOpenView:__init()
    self.ctrl = RedbagController:getInstance()
    self.is_full_screen = false
    self.layout_name = 'redbag/redbg_open_view'
    self.res_list = {

    }
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
    self.is_can_close = false
end

function RedBagOpenView:open_callback()
    self.background = self.root_wnd:getChildByName('background')
    self.background:setScale(display.getMaxScale())
    self.background:setVisible(true)
    self.main_panel = self.root_wnd:getChildByName('main_container')
    self.main_panel:setTouchEnabled(true)
    self.main_panel:setScale(display.getMaxScale())
end

function RedBagOpenView:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openRegBagWindow(false)
        end
    end)
end

function RedBagOpenView:openRootWnd(data)
    self.data = data 
    if data then
        self:showAfterEffect()
    end
end

function RedBagOpenView:showAfterEffect()
    if self.after_effect then
        self.after_effect:runAction(cc.RemoveSelf:create(true))
        self.after_effect = nil
    end
    if not self.after_effect then
        self.after_effect = createEffectSpine(PathTool.getEffectRes(261), cc.p(self.main_panel:getContentSize().width / 2, self.main_panel:getContentSize().height / 2), cc.p(0.5, 0.5), false, PlayerAction.action_1)
        self.main_panel:addChild(self.after_effect)
        delayOnce(function()
            if self.data then
                local assets = Config.GuildData.data_guild_red_bag[self.data.type].assets
                local list = {{bid = Config.ItemData.data_assets_label2id[assets], num = self.data.val}}
                MainuiController:getInstance():openGetItemView(true, list, nil, {is_backpack = true,is_red_bag = true,info_data = self.data})
                self.ctrl:openRegBagWindow(false)
            end
        end,1)
    end
    if self.begin_effect then
        self.begin_effect:runAction(cc.RemoveSelf:create(true))
        self.begin_effect = nil
    end
    if not self.begin_effect then
        self.begin_effect =
            createEffectSpine(
            PathTool.getEffectRes(261),
            cc.p(self.main_panel:getContentSize().width / 2, self.main_panel:getContentSize().height / 2),
            cc.p(0.5, 0.5),
            false,
            PlayerAction.action_2
        )
        self.main_panel:addChild(self.begin_effect)
    end
    if not self.red_bg_sp then
        local config = Config.GuildData.data_guild_red_bag[self.data.type]
        if config then
            local res = PathTool.getResFrame('redbag',config.res_name)
            self.red_bg_sp = createSprite(res,self.main_panel:getContentSize().width / 2 + 5, self.main_panel:getContentSize().height / 2 + 10,self.main_panel,cc.p(0.5,0.5))
            self.red_bg_sp:setOpacity(0)
            self.red_bg_sp:setScale(0.8)
            self.red_bg_sp:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
        end
    end
end

function RedBagOpenView:close_callback()
    if self.after_effect then
        self.after_effect:runAction(cc.RemoveSelf:create(true))
        self.after_effect = nil
    end
    if self.begin_effect then
        self.begin_effect:runAction(cc.RemoveSelf:create(true))
        self.begin_effect = nil
    end

    self.ctrl:openRegBagWindow(false)
end
