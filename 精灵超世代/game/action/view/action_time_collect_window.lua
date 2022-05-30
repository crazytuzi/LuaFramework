---------------------------------
-- @Author: xhj
-- @Editor: xhj
-- @date 2020/1/8 17:55:01
-- @description: 定时领奖（神明的新春祝福）
---------------------------------
local _controller = ActionController:getInstance()
local _model = _controller:getModel()

ActionTimeCollectWindow = ActionTimeCollectWindow or BaseClass(BaseView)
function ActionTimeCollectWindow:__init()
    self.win_type           = WinType.Big
	self.is_full_screen     = true
	self.view_tag			= ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "action/action_time_collect_window"
    
    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("actiontimecollect", "actiontimecollect"), type = ResourcesType.plist},
    }

    self.is_can_close = false
    self.cur_con_index = 0 -- 当前对话的下标
    self.max_index = 1
    self.role_vo = RoleController:getInstance():getRoleVo()
end

function ActionTimeCollectWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setOpacity(180)

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.skip_btn = self.container:getChildByName("skip_btn")
    self.skip_btn:setVisible(false)
    self.shadow = self.container:getChildByName("shadow")
    self.shadow:setScale(display.getMaxScale())
    
    self.next_btn = self.container:getChildByName("next_btn")
    self.continue_sp = self.next_btn:getChildByName("continue_sp")
    self.continue_txt = self.next_btn:getChildByName("continue_txt")
    self.continue_txt:setString(TI18N("点击继续"))
    self.image_bg = self.container:getChildByName("image_bg")
    self.draw_sp = self.container:getChildByName("draw_sp")
    self.draw_pos_x, self.draw_pos_y = self.draw_sp:getPosition()
    self.name_title_sp = self.container:getChildByName("name_title_sp")
    self.draw_name_txt = self.name_title_sp:getChildByName("draw_name_txt")

    self.dialog_txt = createRichLabel(24, 274, cc.p(0, 1), cc.p(55, 275), 5, nil, 620)
    self.container:addChild(self.dialog_txt)
end

function ActionTimeCollectWindow:register_event()
    registerButtonEventListener(self.image_bg, handler(self, self.onClickContinueBtn), false)
    registerButtonEventListener(self.skip_btn, handler(self, self.onClickSkipBtn), true,1)
end

-- 点击跳过
function ActionTimeCollectWindow:onClickSkipBtn()
    _controller:openActionTimeCollectWindow(false)
end

-- 点击继续
function ActionTimeCollectWindow:onClickContinueBtn()
    if self.is_can_close == true then
        if self.cur_evt_type == 80 then --年兽
            
        else
            if self.cur_id then
                _controller:send16698(self.cur_id)    
            end
        end
        
        _controller:openActionTimeCollectWindow(false)
    else
        self:showNextContent()
    end
end

function ActionTimeCollectWindow:openRootWnd(evt_type, step_id, data)
    self.cur_evt_type = evt_type
    self.step_id = step_id -- 当为位面对话时，此值为格子id
    
    if self.cur_evt_type == 80 then --年兽
        self.skip_btn:setVisible(true)
        if data then
            self.config_info = data    
        end
    else
        self.skip_btn:setVisible(false)
        local data = _model:getActionTimeCollectData()
        if data then
            self.action_id = data.camp_id  
            self.cur_id = data.id    
        end
    
        local tmpCfg = Config.HolidayTimeAwardData.data_dialog[self.action_id]
        if tmpCfg then
            local cfg = tmpCfg[self.cur_id]
            if cfg then
                self.config_info = cfg        
            end
        end
    end
    
    self:showNextContent()
end

function ActionTimeCollectWindow:showNextContent()
    if not self.config_info then
        self.is_can_close = true
        _controller:openActionTimeCollectWindow(false)
        return
    end

    self.cur_con_index = self.cur_con_index + 1
    self.max_index = #self.config_info.dialogue
    local cur_content_cfg = self.config_info.dialogue[self.cur_con_index]
    if cur_content_cfg then
        local name = cur_content_cfg[1] or "" -- 名称
        local is_shwo_shadow = cur_content_cfg[2] or 0 -- 是否显示阴影（用于判断是都自己）
        local bust_id = cur_content_cfg[3] or "" -- 立绘
        local content = cur_content_cfg[4] or "" -- 内容
        local offset_x = cur_content_cfg[5] or 0 --立绘偏移值x
        local offset_y = cur_content_cfg[6] or 0 --立绘偏移值y
        local scale_val = cur_content_cfg[7] or 100 -- 立绘缩放值

        --名字
        if name == "" and self.role_vo then
            self.draw_name_txt:setString(self.role_vo.name)
        else
            self.draw_name_txt:setString(name)
        end
        
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
        end

        if is_shwo_shadow == 1 then --自己
            self.name_title_sp:setPosition(170,320.85)
        else
            self.name_title_sp:setPosition(540,320.85)
        end
        
        if self.cur_con_index == self.max_index then
            self.next_btn:setVisible(false)
            self.is_can_close = true
            if self.cur_evt_type == 80 then --年兽
                self.continue_txt:setString(TI18N("点击结束"))  
            else
                self.continue_txt:setString(TI18N("结束并领取奖励"))    
                self.continue_txt:setPosition(86,12.45)
                self.continue_sp:setVisible(false)
            end
            
        else
            self.is_can_close = false
        end

        self:showStr(content)

    else
        self.is_can_close = true
        _controller:openActionTimeCollectWindow(false)
    end
end


--打字机效果
function ActionTimeCollectWindow:showStr(str)
    doStopAllActions(self.container)
    local list,len = StringUtil.splitStr(str)
    local temp_str = ""
    for i, v in ipairs(list) do
        delayRun(self.container,0.05 * i,function ()
            temp_str = temp_str .. v.char
            self.dialog_txt:setString(temp_str)
            if i>=#list and self.cur_con_index == self.max_index then
                self.next_btn:setVisible(true)
                self.next_btn:setOpacity(0)
                self.next_btn:setScale(0)
                local action1 = cc.FadeIn:create(0.2)
                local action2 = cc.ScaleTo:create(0.2,1)
                doStopAllActions(self.next_btn)
                self.next_btn:runAction(cc.Sequence:create(action1,action2))
            end
        end)
    end
end

function ActionTimeCollectWindow:close_callback()
    if self.bust_res_load then
        self.bust_res_load:DeleteMe()
        self.bust_res_load = nil
    end
    doStopAllActions(self.next_btn)
    doStopAllActions(self.container)
    _controller:openActionTimeCollectWindow(false)
end