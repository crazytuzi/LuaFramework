---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/22 20:24:26
-- @description: 大富翁提示弹窗
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

MonopolyTips = MonopolyTips or BaseClass(BaseView)

function MonopolyTips:__init()
    self.is_full_screen = false
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "monopoly/monopoly_tips"
    self.res_list = {
    }
end

function MonopolyTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container , 2) 
    self.ui_panel = container:getChildByName("ui_panel")
    self.ui_panel:setVisible(false)
    self.ui_panel:getChildByName("title_txt"):setString(TI18N("提示"))
    self.got_sp_1 = self.ui_panel:getChildByName("got_sp_1")
    self.got_sp_2 = self.ui_panel:getChildByName("got_sp_2")
    self.close_btn = self.ui_panel:getChildByName("close_btn")
    self.tips_txt_1 = self.ui_panel:getChildByName("tips_txt_1")
    self.tips_txt_2 = self.ui_panel:getChildByName("tips_txt_2")

    delayRun(self.ui_panel, 1.2, function ()
        self.ui_panel:setVisible(true)
    end)

    self.pos_node = container:getChildByName("pos_node")
end

function MonopolyTips:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
end

function MonopolyTips:onClickCloseBtn()
    _controller:openMonopolyTips(false)
end

function MonopolyTips:openRootWnd(data)
    self:setData(data)
    self:handleEffect(true)
end

function MonopolyTips:setData(data)
    if not data then return end
    self.data= data
    self.cfg_data = Config.MonopolyMapsData.data_customs[data.id]
    if not self.cfg_data then return end

    local time_state = false -- 时间条件是否达成
    local dev_state = false  -- 探索值条件是否达成
    local cur_time = GameNet:getInstance():getTime()
    if cur_time >= self.cfg_data.start_unixtime then
        time_state = true
    end
    local pre_dev_val = _model:getGuildDevelopValById(data.id - 1) -- 上一阶段的公会探索值
    if pre_dev_val >= self.cfg_data.develop and self.cfg_data.develop ~= 0 then
        dev_state = true
    end

    self.tips_txt_1:setString(_string_format(TI18N("%s将于%s解锁！"), self.cfg_data.name, TimeTool.getYMDHM(self.cfg_data.start_unixtime)))
    local pre_cfg_data = Config.MonopolyMapsData.data_customs[data.id-1]
    if pre_cfg_data then
        local percent = self.cfg_data.develop/pre_cfg_data.max_develop*100
        if percent > 100 then
            percent = 100
        end
        self.tips_txt_2:setString(_string_format(TI18N("%s探索值达到%d%%"), pre_cfg_data.name, percent))
        self.tips_txt_2:setVisible(true)
    else
        self.tips_txt_2:setVisible(false)
    end

    -- 勾选框和字色
    if time_state then
        self.got_sp_1:setVisible(true)
        self.tips_txt_1:setTextColor(cc.c4b(100, 50, 35, 255))
    else
        self.got_sp_1:setVisible(false)
        self.tips_txt_1:setTextColor(cc.c4b(105, 105, 105, 255))
    end
    if dev_state then
        self.got_sp_2:setVisible(true)
        self.tips_txt_2:setTextColor(cc.c4b(149, 83, 34, 255))
    else
        self.got_sp_2:setVisible(false)
        self.tips_txt_2:setTextColor(cc.c4b(105, 105, 105, 255))
    end
end

-- 播放特效
function MonopolyTips:handleEffect( status )
    if status == true then
        if not tolua.isnull(self.pos_node) and self.enter_effect == nil then
            self.enter_effect = createEffectSpine(Config.EffectData.data_effect_info[1503], cc.p(-360, -752), cc.p(0, 0), false, PlayerAction.action_1)
            self.pos_node:addChild(self.enter_effect)
        end
    else
        if self.enter_effect then
            self.enter_effect:clearTracks()
            self.enter_effect:removeFromParent()
            self.enter_effect = nil
        end
    end
end

function MonopolyTips:close_callback()
    self:handleEffect(false)
    _controller:openMonopolyTips(false)
end