-- --------------------------------------------------------------------
-- 练武场的子项
-- 
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-4-9
-- --------------------------------------------------------------------
PractisetowerItem = class("PractisetowerItem", function()
    return ccui.Widget:create()
end)
function PractisetowerItem:ctor()
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function PractisetowerItem:config()
    self.ctrl = PractisetowerController:getInstance()
    self.size = cc.size(720,390)
    self:setContentSize(self.size)
    self.is_lock = false
    self:retain()
    self.item_list = {}
    self.model_id = 0
end
function PractisetowerItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("practisetower/practise_tower_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    --背景
    self.background = self.main_panel:getChildByName("bg")
    self.background:setVisible(false)
    --锁
    self.lock_icon = self.main_panel:getChildByName("lock")
    self.lock_icon:setVisible(false)
    --通关图标
    self.pass_icon = self.main_panel:getChildByName("pass_icon")
    self.pass_icon:setVisible(false)

    self.model_panel = self.main_panel:getChildByName("model_panel")
    self.model_panel:setVisible(false)
    self.tips_lab = self.main_panel:getChildByName("tips_lab")
    self.tips_lab:setString(TI18N("请先通过前一层"))
    self.tips_lab:setVisible(false)
    self.tips_lab_bg = self.main_panel:getChildByName("tips_lab_bg")
    self.tips_lab_bg:setVisible(false)

    self.cur_panel = self.main_panel:getChildByName("cur_panel")
    self.cur_panel:setVisible(false)

    self.comfirm_btn = self.cur_panel:getChildByName("comfirm_btn")
    self.comfirm_btn_lab = self.comfirm_btn:getChildByName("label")
    self.comfirm_btn_lab:setString(TI18N("挑战BOSS"))
    
    self.progress_container = self.cur_panel:getChildByName("progress_container")
    self.progress = self.progress_container:getChildByName("progress") 				-- 血量进度条
    --self.progress:setScale9Enabled(true)
    self.hp_value = self.progress_container:getChildByName("hp_value") 				-- 血量百分比显示
    self.cur_panel:getChildByName("Text_28"):setString(TI18N("血量:"))


    self.award_panel = self.main_panel:getChildByName("award_panel")
    self.award_panel:setVisible(false)
    self.award_panel_bg = self.main_panel:getChildByName("award_panel_bg")
    self.award_panel_bg:setVisible(false)
    
    self.item_scrollview = self.award_panel:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)

    self.power_info = self.main_panel:getChildByName("power_info")
    self.power_info:setVisible(false)
    self.power_lab = self.power_info:getChildByName("power_lab")

    self.num_lab = self.main_panel:getChildByName("num_lab")
    self.num_lab_bg = self.main_panel:getChildByName("num_lab_bg")
    
end


function PractisetowerItem:setData(data)
    if not data then return end
    if data.is_top_2 == true then
        return
    end
    self.data = data
    self:updateMessage()
end

function PractisetowerItem:sweepCount()
    if not self.data then return end
    local pt_data = self.ctrl:getModel():getPractiseTowerData()
    if not pt_data then return end

    if pt_data.last_unixtime-GameNet:getInstance():getTime() <= 0 then
        setChildUnEnabled(true, self.comfirm_btn) 
        self.comfirm_btn_lab:disableEffect(cc.LabelEffect.OUTLINE)
    else
        setChildUnEnabled(false, self.comfirm_btn) 
        self.comfirm_btn_lab:enableOutline(cc.c4b(0x68, 0x18, 0x0d, 0xff), 2)
    end
    
    self.num_lab:setString(string.format( TI18N("第%d层"),self.data.id ))
    self.num_lab:setVisible(true)
    self.num_lab_bg:setVisible(true)
    local max_tower = self.ctrl:getModel():getNowTowerId() or 0
    local bool = false
    if self.data.id <= max_tower then
        bool = true
    end
    self.is_pass = bool
    
    self.is_lock = self.data.id > max_tower+2
    self.lock_icon:setVisible(self.is_lock)
    self.tips_lab:setVisible(false)
    self.tips_lab_bg:setVisible(false)
    self.cur_panel:setVisible(false)
    if self.is_lock == false and self.is_pass == false then
        self.main_panel:runAction(
            cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
                if self and self.updateModel then
                    self:updateModel(true,self.data)
                end
        end)))

        
        if self.data.id == max_tower+1 then
            self.cur_panel:setVisible(true)
            self.progress:setPercent(pt_data.radio)
            self.hp_value:setString(string.format( "%d%%",pt_data.radio ))
        elseif self.data.id == max_tower+2 then
            self.tips_lab:setVisible(true)
            self.tips_lab_bg:setVisible(true)
            local code = cc.Application:getInstance():getCurrentLanguageCode()
            if code ~= "zh" then
                self.tips_lab_bg:setContentSize(cc.size(460,60))
            end
        end
    else
        self.model_panel:setVisible(false)
    end
    self.pass_icon:setVisible(self.is_pass)    
    
    if self.is_lock == true then
        self.power_lab:setString(TI18N("推荐战力：？？？"))
    else
        self.power_lab:setString(string.format(TI18N("推荐战力：%d"),self.data.power))
    end
   
    self:updateAwardInfo()
   
end

function PractisetowerItem:updateModel(status,data)
    self.model_panel:setVisible(status)
    if status == true then
        if not data then return end
        
        if self.model_id ~= tonumber(data.mode_id) then
            if self.partner_model then
                self.partner_model:DeleteMe()
                self.partner_model = nil
            end
        end
        
        if not self.partner_model then 
            self.partner_model = BaseRole.new(BaseRole.type.unit, tonumber(data.mode_id),nil,{scale = 0.6})
            self.partner_model:setAnimation(0,PlayerAction.show,true)
            self.model_panel:addChild(self.partner_model)
            self.partner_model:setPosition(cc.p(50,120))
        end
        self.model_id = data.mode_id
    else
        if self.partner_model then
            self.partner_model:DeleteMe()
            self.partner_model = nil
        end
    end
end


function PractisetowerItem:updateAwardInfo()
    if not self.data then
        return
    end
    local data_list = self.data.reward or {}
    self.award_panel_bg:setVisible(true)
    self.award_panel:setVisible(true)
    self.power_info:setVisible(true)
    local setting = {}
    setting.scale = 0.6
    setting.max_count = 2
    setting.is_center = true
    setting.is_show_got = self.is_pass
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
end


function PractisetowerItem:updateMessage()
    if not self.data then return end
    self.background:setVisible(false)  
    if self.data.type == 1 then
        loadSpriteTexture(self.background, PathTool.getPlistImgForDownLoad("practisetower","practisetower_bg_2"), LOADTEXT_TYPE)
        self.background:setVisible(true)  
    elseif self.data.type == 2 then
        loadSpriteTexture(self.background, PathTool.getResFrame("practisetower", "practisetower_2"), LOADTEXT_TYPE_PLIST)
        self.background:setVisible(true)  
    else
        if self.index%2 == 0 then
            loadSpriteTexture(self.background, PathTool.getResFrame("practisetower", "practisetower_2"), LOADTEXT_TYPE_PLIST)
        else
            loadSpriteTexture(self.background, PathTool.getResFrame("practisetower", "practisetower_3"), LOADTEXT_TYPE_PLIST)
        end
        self.background:setVisible(true)  
    end
    
    
    self.pass_icon:setVisible(false)
    self.award_panel_bg:setVisible(false)
    self.award_panel:setVisible(false)
    self.power_info:setVisible(false)
    self.lock_icon:setVisible(false)
    self.tips_lab:setVisible(false)
    self.tips_lab_bg:setVisible(false)
    self.cur_panel:setVisible(false)
    self.num_lab:setVisible(false)
    self.num_lab_bg:setVisible(false)
    
    if self.data.type == 1 or self.data.type == 2 then
        self.model_panel:setVisible(false)
        return
    end
    
    self:sweepCount()
    
end

--事件
function PractisetowerItem:registerEvents()
    registerButtonEventListener(self.comfirm_btn, function()
        local pt_data = self.ctrl:getModel():getPractiseTowerData()
        if not pt_data or not self.data then return end

        if pt_data.last_unixtime-GameNet:getInstance():getTime() <= 0 then
            message(TI18N("当前活动已结束"))
            return
        end

        if pt_data.time <= 0 and pt_data.is_recombat == 0 then
            if pt_data.last_buy_time >0 then
                
                local buy_config = Config.HolidayPractiseTowerData.data_const.holiday_practise_tower_buy_loss
                local role_vo = RoleController:getInstance():getRoleVo()
                if buy_config and buy_config.val and buy_config.val[1] and buy_config.val[1][1] and buy_config.val[1][2] and role_vo then 
                    local cur_gold = role_vo.gold
                    if  cur_gold>= buy_config.val[1][2] then
                        local function fun()
                            self.ctrl:getModel():setIsTouchFight({id = self.data.id, power = self.data.power})
                            self.ctrl:sender29104()
                        end
    
                        local item_id = buy_config.val[1][1]
                        local num = buy_config.val[1][2] or 0
                        local item_config = Config.ItemData.data_get_data(item_id)
                        if item_config and item_config.icon then
                            local res = PathTool.getItemRes(item_config.icon)
                            local str = string.format( TI18N("是否花费<img src='%s' scale=0.25 />%s购买一次挑战次数？"),res, num)
                            CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,24)
                        end
                    else
                        local pay_config = nil
                        local pay_type = buy_config.val[1][1]
                        if type(pay_type) == 'number' then
                            pay_config = Config.ItemData.data_get_data(pay_type)
                        else
                            pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[pay_type])
                        end
                        if pay_config then
                            if pay_config.id == Config.ItemData.data_assets_label2id.gold then
                                if FILTER_CHARGE then
                                    message(TI18N("钻石不足"))
                                else
                                    local function fun()
                                        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                                    end
                                    local str = string.format(TI18N('%s不足，是否前往充值？'), pay_config.name)
                                    CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
                                end
                            else
                                BackpackController:getInstance():openTipsSource(true, pay_config)
                            end
                        end
                    end
                end
            else
                message(TI18N("挑战次数不足"))
            end
            return
        end
        local setting = {}
        setting.select_base_id = self.data.id
        setting.is_send = false
        setting.power = self.data.power
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.PractiseTower,setting)
    end,true, 1)

 
end

function PractisetowerItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function PractisetowerItem:addCallBack(call_fun)
    self.call_fun =call_fun
end


function PractisetowerItem:setVisibleStatus(bool)
    self:setVisible(bool)
end
function PractisetowerItem:getData()
    return self.data
end

function PractisetowerItem:clearInfo()
    self:removeFromParent()
end


function PractisetowerItem:DeleteMe()
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end

    if self.partner_model then
        self.partner_model:DeleteMe()
        self.partner_model = nil
    end

    self:removeFromParent()
    self:removeAllChildren()
    self:release()
end



