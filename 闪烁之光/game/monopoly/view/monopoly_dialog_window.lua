---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/22 17:55:01
-- @description: 大富翁对话事件界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()

MonopolyDialogWindow = MonopolyDialogWindow or BaseClass(BaseView)
function MonopolyDialogWindow:__init()
    self.win_type           = WinType.Big
	self.is_full_screen     = true
	self.view_tag			= ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "monopoly/monopoly_dialog_window"
    
    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("monopoly", "monopolyboard"), type = ResourcesType.plist},
    }

    self.is_send_proto = false -- 是否选择过选项
    self.is_can_close = false
    self.cur_con_index = 0 -- 当前对话的下标
    self.chose_object_list = {} -- 待选择的对话列表
end

function MonopolyDialogWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setOpacity(180)

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container , 1) 

    self.shadow = self.container:getChildByName("shadow")
    self.shadow:setScale(display.getMaxScale())
    self.container:getChildByName("continue_txt"):setString(TI18N("点击继续"))
    self.image_bg = self.container:getChildByName("image_bg")
    self.draw_sp = self.container:getChildByName("draw_sp")
    self.draw_pos_x, self.draw_pos_y = self.draw_sp:getPosition()
    self.draw_name_txt = self.container:getChildByName("draw_name_txt")
    self.skip_btn = self.container:getChildByName("skip_btn")

    self.dialog_txt = createRichLabel(26, 274, cc.p(0.5, 1), cc.p(360, 275), 5, nil, 620)
    self.container:addChild(self.dialog_txt)
end

function MonopolyDialogWindow:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
    registerButtonEventListener(self.skip_btn, handler(self, self.onClickSkipBtn), true)
    registerButtonEventListener(self.image_bg, handler(self, self.onClickContinueBtn), false)
end

-- 点击背景关闭
function MonopolyDialogWindow:onClickCloseBtn()
    if self.is_can_close then
        _controller:openMonopolyDialogWindow(false)
    else
        self:onClickContinueBtn()
    end
end

-- 点击跳过
function MonopolyDialogWindow:onClickSkipBtn()
    self:showNextContent(true)
end

-- 点击继续
function MonopolyDialogWindow:onClickContinueBtn()
    if not self.is_show_answer or self.is_show_answer ~= 1 then
        self:showNextContent(false, true)
    end
end

function MonopolyDialogWindow:openRootWnd(evt_type, step_id, data)
    self.cur_evt_type = evt_type or MonopolyConst.Event_Type.Dialog
    self.step_id = step_id -- 当为位面对话时，此值为格子id
    if data and next(data) ~= nil then
        self:setData(data)
    else
        local cur_data = _model:getRandomDialogByEvtAndStep(evt_type, step_id)
        if cur_data and next(cur_data) ~= nil then
            self:setData(cur_data)
        else
            self.is_can_close = true
        end
    end
end

function MonopolyDialogWindow:setData(data)
    if not data then return end

    self.data = data

    self:showNextContent()
end

function MonopolyDialogWindow:showNextContent(is_skip, flag)
    if not self.data then return end

    if is_skip then
        local is_have_answer = false
        for i, cfg in ipairs(self.data.dialogue) do
            if cfg[2] == 1 then
                is_have_answer = true
                self.cur_con_index = i
                break
            end
        end
        if not is_have_answer then -- 没有选项的对话直接关闭界面
            _controller:openMonopolyDialogWindow(false)
            return
        end
    else
        self.cur_con_index = self.cur_con_index + 1
    end
    local cur_content_cfg = self.data.dialogue[self.cur_con_index]
    if cur_content_cfg then
        local name = cur_content_cfg[1] or "" -- 名称
        local is_show_answer = cur_content_cfg[2] or 0 -- 是否显示答案选项
        local is_shwo_shadow = cur_content_cfg[3] or 0 -- 是否显示阴影
        local bust_id = cur_content_cfg[4] or "" -- 立绘
        local content = cur_content_cfg[5] or "" -- 内容
        local offset_x = cur_content_cfg[6] or 0 --立绘偏移值
        local offset_y = cur_content_cfg[7] or 0 --立绘偏移值
        local scale_val = cur_content_cfg[8] or 100 -- 立绘缩放值

        self.is_show_answer = is_show_answer
        self.draw_name_txt:setString(name)
        self.shadow:setVisible(is_shwo_shadow == 1)

        if bust_id and bust_id ~= "" then
            local bust_res = PathTool.getPlistImgForDownLoad("herodraw/herodrawres", bust_id, false)
            if not self.cur_bust_res or self.cur_bust_res ~= bust_res then
                self.cur_bust_res = bust_res
                self.bust_res_load = loadSpriteTextureFromCDN(self.draw_sp, bust_res, ResourcesType.single, self.bust_res_load)
                self.draw_sp:setScale(scale_val/100)
                self.draw_sp:setPosition(self.draw_pos_x+offset_x, self.draw_pos_y+offset_y)
            end
            self.draw_sp:setVisible(true)
        else
            self.draw_sp:setVisible(false)
        end

        self.dialog_txt:setString(content)

        if is_show_answer == 1 then
            self:updateChoseItmeList(true, self.data.answer)
        else
            self:updateChoseItmeList(false)
        end
        if self.cur_con_index == #self.data.dialogue and is_show_answer ~= 1 then
            self.is_can_close = true
            self.skip_btn:setVisible(false)
        else
            self.is_can_close = false
        end
    else
        self.is_can_close = true
        if self.is_show_answer == 1 or flag then -- 选完答案后并且没有对话了直接关闭界面
            _controller:openMonopolyDialogWindow(false)
        end
    end
end

-- 更新待选择的对话列表
function MonopolyDialogWindow:updateChoseItmeList(status, data_list)
    for _, object in pairs(self.chose_object_list) do
        if object.dialog_bg then
            object.dialog_bg:setVisible(false)
        end
    end
    if status == false then return end
    if not data_list or type(data_list[1]) ~= "table" then return end

    local num = #data_list
    if num > 0 then
        self.shadow:setVisible(true)
    end
    local space_y = 100
    local start_pos_y = 740 + (num -1)*(space_y*0.5)
    for i, info in ipairs(data_list) do
        local object = self.chose_object_list[i]
        if not object then
            object = self:createDialogObject()
            self.chose_object_list[i] = object
            registerButtonEventListener(object.dialog_bg, function ()
                self:onClickChoseItem(i)
            end, true)
        end
        object.num = info[1]
        object.dialog_bg:setPositionY(start_pos_y-(i-1)*space_y)
        object.dialog_txt:setString(info[2] or "")
    end
end

function MonopolyDialogWindow:createDialogObject()
    local object = {}
    object.dialog_bg = createImage(self.container, PathTool.getResFrame("monopoly", "monopolyboard_1011", false, "monopolyboard"), 360, 0, cc.p(0.5, 0.5), true, 1, true)
    object.dialog_bg:setContentSize(cc.size(412, 62))
    object.dialog_bg:setTouchEnabled(true)    
    object.dialog_txt = createLabel(26, 274, nil, 412*0.5, 62*0.5, "", object.dialog_bg, nil, cc.p(0.5, 0.5))
    return object
end

function MonopolyDialogWindow:onClickChoseItem(index)
    local object = self.chose_object_list[index]
    if object and self.data then
        if self.cur_evt_type == MonopolyConst.Event_Type.Dialog then
            _controller:sender27404({{type=5, arg1=self.data.id, arg2=object.num or 1}})
            self.is_send_proto = true
        elseif self.cur_evt_type == MonopolyConst.Event_Type.Flag then
            _controller:sender27404({{type=6, arg1=object.num, arg2=0}})
            self.is_send_proto = true
        elseif self.cur_evt_type == 99 then -- 特殊触发的剧情
            _controller:sender27407(self.data.type, object.num or 1)
            self.is_send_proto = true
        elseif self.cur_evt_type == 88 then -- 位面对话
            PlanesController:getInstance():sender23104( self.step_id, 1, {{type=PlanesConst.Proto_23104._5, val1=object.num or 1, val2 = 0}} )
        elseif self.cur_evt_type == 80 then -- 年兽
            ActionyearmonsterController:getInstance():sender28203(self.step_id, 1, {})
        end
        self:showNextContent()
    end
end

function MonopolyDialogWindow:close_callback()
    if not self.is_send_proto and self.data then -- 没有选项的对话默认发1
        if self.cur_evt_type == MonopolyConst.Event_Type.Dialog then
            _controller:sender27404({{type=5, arg1=self.data.id, arg2=1}})
        elseif self.cur_evt_type == MonopolyConst.Event_Type.Flag then
            _controller:sender27404({{type=6, arg1=1, arg2=0}})
        elseif self.cur_evt_type == 99 then -- 特殊触发的剧情
            _controller:sender27407(self.data.type, 1)
        elseif self.cur_evt_type == 88 then -- 位面对话
            PlanesController:getInstance():sender23104( self.step_id, 1, {{type=PlanesConst.Proto_23104._5, val1=1, val2 = 0}} )
        elseif self.cur_evt_type == 80 then -- 年兽
            ActionyearmonsterController:getInstance():sender28203(self.step_id, 1, {})
        end
    end
    if self.bust_res_load then
        self.bust_res_load:DeleteMe()
        self.bust_res_load = nil
    end
    doStopAllActions(self.container)
    _controller:openMonopolyDialogWindow(false)
end