---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/22 20:59:17
-- @description: 大富翁选择步数界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

MonopolyChoseStepWindow = MonopolyChoseStepWindow or BaseClass(BaseView)

function MonopolyChoseStepWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "monopoly/monopoly_chose_step_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("monopoly","monopoly_big_bg_2"), type = ResourcesType.single},
    }
end

function MonopolyChoseStepWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container , 2) 
    container:getChildByName("tips_txt"):setString(TI18N("想走几步都可以做到哦"))

    self.close_btn = container:getChildByName("close_btn")
    self.step_btn_list = {}
    for i = 1, 4 do
        local step_btn = container:getChildByName("step_btn_" .. i)
        if step_btn then
            _table_insert(self.step_btn_list, step_btn)
        end
    end
end

function MonopolyChoseStepWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)

    for i, step_btn in ipairs(self.step_btn_list) do
        registerButtonEventListener(step_btn, function ()
            self:onClickStepBtn(i)
        end, true)
    end

    -- 选择步数结果
    self:addGlobalEvent(MonopolyEvent.Get_Dice_Result_Event, function ( num )
        self:onGetDiceResultData(num)
    end)
end

function MonopolyChoseStepWindow:onGetDiceResultData(num)
    if not num then return end
    GlobalEvent:getInstance():Fire(MonopolyEvent.Get_Role_Move_Event, num)
    _controller:openMonopolyChoseStepWindow(false)
end

function MonopolyChoseStepWindow:onClickCloseBtn()
    _controller:openMonopolyChoseStepWindow(false)
end

function MonopolyChoseStepWindow:onClickStepBtn(index)
    _controller:sender27403(2, index)
end

function MonopolyChoseStepWindow:openRootWnd()
end

function MonopolyChoseStepWindow:close_callback()
    _controller:openMonopolyChoseStepWindow(false)
end