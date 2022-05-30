-- --------------------------------------------------------------------
-- 
-- 
-- @author: whjing2012@163.com(必填, 创建模块的人员)
-- @editor: whjing2012@163.com(必填, 后续维护以及修改的人员)
-- @description:
--      连续自动作战
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

BattleDramaAutoCombatWindow = BattleDramaAutoCombatWindow or BaseClass(BaseView)
local controller = BattleDramaController:getInstance()
local model = BattleDramaController:getInstance():getModel()

function BattleDramaAutoCombatWindow:__init()
    self.layout_name = "battledrama/battle_drama_auto_combat"
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
end

function BattleDramaAutoCombatWindow:open_callback()
    self.background_panel = self.root_wnd:getChildByName("background_panel")
    self.background_panel:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.main_container = self.main_panel:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.label = createRichLabel(24, 175, cc.p(0, 0.5), cc.p(30,60), nil, nil, 500)
    self.main_container:addChild(self.label)
    self.label:setString(TI18N("开启连续作战将自动不断向下一关卡挑战，离线也不会中断，直到挑战失败或背包载满"))

    self.checkbox = self.main_panel:getChildByName("checkbox")
    self.checkbox_label = self.main_panel:getChildByName("checkbox_label")
    self.checkbox:setSelected(false)

    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    -- self.close_btn:setVisible(self.external_close_callback ~= nil)
end

function BattleDramaAutoCombatWindow:register_event()
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openDramBattleAutoCombatView(false) 
            end
        end)
    end
    if self.cancel_btn then
        self.cancel_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                if self.checkbox:isSelected() then
                    model.auto_combat = 0
                end
                controller:send13003(0)
                controller:openDramBattleAutoCombatView(false) 
            end
        end)
    end
    if self.ok_btn then
        self.ok_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                if self.checkbox:isSelected() then
                    model.auto_combat = 1
                end
                controller:send13003(1)
                controller:openDramBattleAutoCombatView(false) 
            end
        end)
    end
end

