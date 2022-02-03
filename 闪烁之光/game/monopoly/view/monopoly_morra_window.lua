---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/23 19:04:33
-- @description: 大富翁猜拳界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _morra_type = {
    [1] = 1, -- 拳头
    [2] = 3, -- 剪刀
    [3] = 2, -- 布
}

MonopolyMorraWindow = MonopolyMorraWindow or BaseClass(BaseView)

function MonopolyMorraWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "monopoly/monopoly_morra_window"
    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("monopoly", "monopolymorra"), type = ResourcesType.plist},
    }
    
    self.is_can_close = false
end

function MonopolyMorraWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container , 2) 

    container:getChildByName("title_txt"):setString(TI18N("石头剪刀布"))
    self.left_role_layout = container:getChildByName("left_role_layout")
    self.right_role_layout = container:getChildByName("right_role_layout")
    self:createRoleSpine()

    self.chose_panel = container:getChildByName("chose_panel")
    self.morra_object_list = {}
    for i = 1, 3 do
        local object = {}
        object.morra_btn = self.chose_panel:getChildByName("morra_btn_" .. i)
        local pos_x, pos_y = object.morra_btn:getPosition()
        object.pos = cc.p(pos_x, pos_y)
        object.num = _morra_type[i]
        _table_insert(self.morra_object_list, object)
    end
    self.select_img = self.chose_panel:getChildByName("select_img")
    self.select_img:setVisible(false)
    self.rule_btn = self.chose_panel:getChildByName("rule_btn")
    self.rule_btn:setVisible(false)
    self.affirm_btn = self.chose_panel:getChildByName("affirm_btn")
    self.affirm_btn:getChildByName("label"):setString(TI18N("出手"))

    self.result_panel = container:getChildByName("result_panel")
    self.result_panel:setVisible(false)
    self.left_result_sp = self.result_panel:getChildByName("left_result_sp")
    self.left_result_sp:setPositionX(-100)
    self.left_result_sp:setOpacity(0)
    self.left_result_sp:getChildByName("label"):setString(TI18N("我方"))
    self.right_result_sp = self.result_panel:getChildByName("right_result_sp")
    self.right_result_sp:setPositionX(730)
    self.right_result_sp:setOpacity(0)
    self.right_result_sp:getChildByName("label"):setString(TI18N("敌方"))
    self.win_sp = self.result_panel:getChildByName("win_sp")
    self.win_sp:setVisible(false)
    self.vs_sp_1 = self.result_panel:getChildByName("vs_sp_1")
    self.vs_sp_1:setOpacity(0)
    self.vs_sp_1:setScale(3)
end

function MonopolyMorraWindow:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
    registerButtonEventListener(self.rule_btn, handler(self, self.onClickRuleBtn), true)
    registerButtonEventListener(self.affirm_btn, handler(self, self.onClickAffirmBtn), true, 1, nil, nil, 0.5)

    for i, object in ipairs(self.morra_object_list) do
        if object.morra_btn then
            registerButtonEventListener(object.morra_btn, function ()
                self:onClickMorraBtn(i)
            end, true)
        end
    end

    self:addGlobalEvent(MonopolyEvent.Get_Morra_Result_Event, function (data)
        self:onGetResultData(data)
    end)
end

function MonopolyMorraWindow:onClickMorraBtn(index)
    local object = self.morra_object_list[index]
    if object then
        self.select_img:setPosition(object.pos)
        self.select_img:setVisible(true)
        self.chose_morra_num = object.num
    end
end

function MonopolyMorraWindow:onClickCloseBtn()
    if self.is_can_close then
        _controller:openMonopolyMorraWindow(false)
    end
end

function MonopolyMorraWindow:onClickRuleBtn()
    
end

function MonopolyMorraWindow:onClickAffirmBtn()
    if not self.chose_morra_num then
        message(TI18N("你还没有选择任何一项"))
        return
    end

    self.select_img:setVisible(false)
    local function ani_end_callback()
        self.chose_panel:setVisible(false)
        self.result_panel:setVisible(true)
        self.left_result_sp:runAction(cc.Spawn:create(cc.FadeIn:create(0.2), cc.MoveTo:create(0.2, cc.p(180, 210))))
        self.right_result_sp:runAction(cc.Spawn:create(cc.FadeIn:create(0.2), cc.MoveTo:create(0.2, cc.p(540, 210))))
        self.vs_sp_1:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.Spawn:create(cc.FadeIn:create(0.1), cc.ScaleTo:create(0.1, 1))))
        
        _controller:sender27404({{type=4, arg1=self.chose_morra_num, arg2=0}})
    end
    for i, object in ipairs(self.morra_object_list) do
        if i == 1 then
            object.morra_btn:runAction(cc.Spawn:create(cc.FadeOut:create(0.2), cc.MoveTo:create(0.2, cc.p(-100, 210))))
        elseif i == 2 then
            object.morra_btn:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), cc.CallFunc:create(ani_end_callback)))
        else
            object.morra_btn:runAction(cc.Spawn:create(cc.FadeOut:create(0.2), cc.MoveTo:create(0.2, cc.p(730, 210))))
        end
    end
end

-- 显示左右两边的角色动画
function MonopolyMorraWindow:createRoleSpine()
    -- 左边
    local look_id = _model:getHomeLookId()
    local figure_cfg = Config.HomeData.data_figure[look_id]
    local effect_id = "H60001"
    if figure_cfg then
        effect_id = figure_cfg.look_id
    end
    self.left_role_spine = createEffectSpine( effect_id, cc.p(160, -30), cc.p(0.5, 0.5), true, PlayerAction.idle )
    self.left_role_layout:addChild(self.left_role_spine)

    -- 右边
    self.right_role_spine = createEffectSpine( "H60004", cc.p(160, -30), cc.p(0.5, 0.5), true, PlayerAction.idle )
    self.right_role_spine:setScaleX(-1)
    self.right_role_layout:addChild(self.right_role_spine)
end

-- 显示翻转动画和猜拳结果
function MonopolyMorraWindow:showMorraResultAni(left_num, right_num, ret)
    local function call_back_1()
        local res_str = self:getMorraResByNum(left_num)
        loadSpriteTexture(self.left_result_sp, res_str, LOADTEXT_TYPE_PLIST)
    end
    local function call_back_2()
        local res_str = self:getMorraResByNum(right_num)
        loadSpriteTexture(self.right_result_sp, res_str, LOADTEXT_TYPE_PLIST)
    end
    self.left_result_sp:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.01, 1.4), cc.CallFunc:create(call_back_1), cc.ScaleTo:create(0.1, 1)))
    self.right_result_sp:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.01, 1.4), cc.CallFunc:create(call_back_2), cc.ScaleTo:create(0.1, 1)))

    self.win_sp:setVisible(false)
    if ret == 1 then -- 胜利
        self.win_sp:setVisible(true)
        self.win_sp:setPosition(244, 144)
    elseif ret == 2 then -- 失败
        self.win_sp:setVisible(true)
        self.win_sp:setPosition(478, 144)
    end
    self.is_can_close = true
end

function MonopolyMorraWindow:getMorraResByNum(num)
    local res_str = PathTool.getResFrame("monopoly", "monopolymorra_1007", false, "monopolymorra")
    if num == 2 then
        res_str = PathTool.getResFrame("monopoly", "monopolymorra_1006", false, "monopolymorra")
    elseif num == 3 then
        res_str = PathTool.getResFrame("monopoly", "monopolymorra_1005", false, "monopolymorra")
    end
    return res_str
end

-- 获得猜拳结果数据
function MonopolyMorraWindow:onGetResultData(data)
    if not data then return end
    self:showMorraResultAni(data.choice, data.system_choice, data.ret)
end

function MonopolyMorraWindow:openRootWnd()

end

function MonopolyMorraWindow:close_callback()
    if self.left_role_layout then
        self.left_role_layout:setClippingEnabled(false)
    end
    if self.right_role_layout then
        self.right_role_layout:setClippingEnabled(false)
    end
    if self.left_role_spine then
        self.left_role_spine:clearTracks()
        self.left_role_spine:removeFromParent()
        self.left_role_spine = nil
    end
    if self.right_role_spine then
        self.right_role_spine:clearTracks()
        self.right_role_spine:removeFromParent()
        self.right_role_spine = nil
    end
    _controller:openMonopolyMorraWindow(false)
end