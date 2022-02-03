-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      选择重生英雄皮肤兑换界面
-- <br/> 2020年2月12日
-- --------------------------------------------------------------------
ActionHeroSkinResetPanel = ActionHeroSkinResetPanel or BaseClass(BaseView)

local controller = ActionController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function ActionHeroSkinResetPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "action/action_hero_skin_reset_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single }
    }

end

function ActionHeroSkinResetPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("皮肤置换"))


    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("取 消"))

    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn_lab = self.right_btn:getChildByName("label")
    setChildUnEnabled(true, self.right_btn)
    self.right_btn_lab:disableEffect(cc.LabelEffect.OUTLINE)
    self.right_btn:setTouchEnabled(false)
    self.timer = 5
    self.right_btn_lab:setString(string.format("%s(%s)", TI18N("确认消耗"), self.timer))
    self:showAutoBtnTimer()

    self.one_box = self.main_container:getChildByName("one_box")
    self.one_box:setSelected(false)
    self.two_box = self.main_container:getChildByName("two_box")
    self.two_box:setSelected(false)

    self.left_item_1 = BackPackItem.new(true, true,nil,nil,nil,true)
    self.left_item_1:setAnchorPoint(0.5, 0.5)
    self.left_item_1:setPosition(self.main_container:getContentSize().width / 2-130, 440)
    self.main_container:addChild(self.left_item_1)
    

    self.right_item_1 = BackPackItem.new(true, true,nil,nil,nil,true)
    self.right_item_1:setAnchorPoint(0.5, 0.5)
    self.right_item_1:setPosition(self.main_container:getContentSize().width / 2+170, 440)
    self.main_container:addChild(self.right_item_1)

    self.left_item_2 = BackPackItem.new(true, true,nil,nil,nil,true)
    self.left_item_2:setAnchorPoint(0.5, 0.5)
    self.left_item_2:setPosition(self.main_container:getContentSize().width / 2-130, 304)
    self.main_container:addChild(self.left_item_2)

    self.right_item_2 = BackPackItem.new(true, true,nil,nil,nil,true)
    self.right_item_2:setAnchorPoint(0.5, 0.5)
    self.right_item_2:setPosition(self.main_container:getContentSize().width / 2+170, 304)
    self.main_container:addChild(self.right_item_2)

    self.close_btn = self.main_container:getChildByName("close_btn")

    self.tips_text = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(self.main_container:getContentSize().width / 2, 200), nil, nil, 600)
    self.main_container:addChild(self.tips_text)
    self:updateTipsText()
end

--更新tips显示
function ActionHeroSkinResetPanel:updateTipsText()
    local name = ""
    local num = 0
    local sum_num = 0
    local reborn_skin_id =  Config.PartnerData.data_partner_const.reborn_skin_id
    if self.one_box:isSelected() == true then
        if reborn_skin_id then
            local config_1 = Config.ItemData.data_get_data(reborn_skin_id.val[1][2])
            if config_1 then
                name = config_1.name
                num = num+1
            end
            local is_has_skin = HeroController:getModel():getHeroSkinInfoBySkinID(reborn_skin_id.val[1][1])
            local item_num = BackpackController:getInstance():getModel():getItemNumByBid(reborn_skin_id.val[1][2])
            if is_has_skin == 0 then
                sum_num = sum_num+1 
            end
            if item_num and item_num>0 then
                sum_num = sum_num + item_num
            end
        end
    end

    if self.two_box:isSelected() == true then
        if reborn_skin_id then
            local config_2 = Config.ItemData.data_get_data(reborn_skin_id.val[2][2])
            if config_2 then
                if name == "" then
                    name = config_2.name
                else
                    name = name .. "、" ..config_2.name
                end
                num = num+1
            end
            local is_has_skin = HeroController:getModel():getHeroSkinInfoBySkinID(reborn_skin_id.val[2][1])
            local item_num = BackpackController:getInstance():getModel():getItemNumByBid(reborn_skin_id.val[2][2])
            if is_has_skin == 0 then
                sum_num = sum_num+1 
            end
            if item_num and item_num>0 then
                sum_num = sum_num + item_num
            end
        end
    end

    local tips = ""
    if name == "" then
        tips = TI18N("请先<div fontcolor=#D95014>勾选</div>想要参与置换的皮肤\n          并获得自选皮肤礼盒")
    else
        local name_2 = ""
        local reborn_skin_reward =  Config.PartnerData.data_partner_const.reborn_skin_reward
        if reborn_skin_reward then
            local config_3 = Config.ItemData.data_get_data(reborn_skin_reward.val)
            if config_3 then
                name_2 = config_3.name
            end
        end
        local temp = "\n                 并获取"
        if num >= 2 then
            temp = "\n                                  并获取"
        end
        tips = string_format(TI18N("是否确认<div fontcolor=#D95014>消耗</div>所有<div fontcolor=#D95014>%s</div>皮肤%s<div fontcolor=#D95014>%s*%d</div>"),name,temp,name_2,sum_num)
    end
    self.tips_text:setString(tips)
    
end

function ActionHeroSkinResetPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.left_btn, handler(self, self._onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.right_btn, handler(self, self._onClickBtnRight) ,true, 2)

    self.one_box:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            local reborn_skin_id =  Config.PartnerData.data_partner_const.reborn_skin_id
            if reborn_skin_id then
                local is_has_skin = HeroController:getModel():getHeroSkinInfoBySkinID(reborn_skin_id.val[1][1])
                local num = BackpackController:getInstance():getModel():getItemNumByBid(reborn_skin_id.val[1][2])
                if is_has_skin == 0 or num > 0 then
                    self:updateTipsText()
                    return
                end
            end
            
            message(TI18N("该皮肤未拥有"))
            self.one_box:setSelected(false)
            self:updateTipsText()
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            self:updateTipsText()
        end
        
    end)

    self.two_box:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            local reborn_skin_id =  Config.PartnerData.data_partner_const.reborn_skin_id
            if reborn_skin_id then
                local is_has_skin = HeroController:getModel():getHeroSkinInfoBySkinID(reborn_skin_id.val[2][1])
                local num = BackpackController:getInstance():getModel():getItemNumByBid(reborn_skin_id.val[2][2])
                if is_has_skin == 0 or num > 0 then
                    self:updateTipsText()
                    return
                end
            end
            message(TI18N("该皮肤未拥有"))
            self.two_box:setSelected(false)
            self:updateTipsText()
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            self:updateTipsText()
        end
        
    end)
end

--关闭
function ActionHeroSkinResetPanel:_onClickBtnClose()
    controller:openActionHeroSkinResetPanel(false)
end

--确认消耗
function ActionHeroSkinResetPanel:_onClickBtnRight()
    local list = {}
    
    if self.one_box:isSelected() == true then
        local reborn_skin_id =  Config.PartnerData.data_partner_const.reborn_skin_id
        if reborn_skin_id then
            table_insert(list,{skin_ids = reborn_skin_id.val[1][1]})
        end
    end

    if self.two_box:isSelected() == true then
        local reborn_skin_id =  Config.PartnerData.data_partner_const.reborn_skin_id
        if reborn_skin_id then
            table_insert(list,{skin_ids = reborn_skin_id.val[2][1]})
        end
    end
    if #list <= 0 then
        message(TI18N("选择需要消耗的皮肤"))
        return
    end
    controller:sender11074(list)
    self:_onClickBtnClose()
end

--@
function ActionHeroSkinResetPanel:openRootWnd()
   self:setData()
    
end


function ActionHeroSkinResetPanel:setData()
    
    local reborn_skin_id =  Config.PartnerData.data_partner_const.reborn_skin_id
    if reborn_skin_id then
        local vo = {}
        vo = deepCopy(Config.ItemData.data_get_data(reborn_skin_id.val[1][2]))
        self.left_item_1:setData(vo)

        local vo_3 = {}
        vo_3 = deepCopy(Config.ItemData.data_get_data(reborn_skin_id.val[2][2]))
        self.left_item_2:setData(vo_3)
    end
    

    local reborn_skin_reward =  Config.PartnerData.data_partner_const.reborn_skin_reward
    if reborn_skin_reward then
        local vo_2 = {}
        vo_2 = deepCopy(Config.ItemData.data_get_data(reborn_skin_reward.val))
        self.right_item_1:setData(vo_2)
        self.right_item_2:setData(vo_2)
    end
    
    local reborn_skin_id =  Config.PartnerData.data_partner_const.reborn_skin_id
    if reborn_skin_id then
        local is_has_skin = HeroController:getModel():getHeroSkinInfoBySkinID(reborn_skin_id.val[1][1])
        local num = BackpackController:getInstance():getModel():getItemNumByBid(reborn_skin_id.val[1][2])
        if is_has_skin ~= 0 and num <= 0 then
            self.left_item_1:grayStatus(true,150,TI18N("未拥有"))
        else
            self.left_item_1:grayStatus(false)
        end

        local is_has_skin2 = HeroController:getModel():getHeroSkinInfoBySkinID(reborn_skin_id.val[2][1])
        local num2 = BackpackController:getInstance():getModel():getItemNumByBid(reborn_skin_id.val[2][2])
        if is_has_skin2 ~= 0 and num2<= 0 then
            self.left_item_2:grayStatus(true,150,TI18N("未拥有"))
        else
            self.left_item_2:grayStatus(false)
        end
    end

end

function ActionHeroSkinResetPanel:showAutoBtnTimer(  )
    if not self.timer then return end
    self.timer_id = GlobalTimeTicket:getInstance():add(function()
        if self.timer > 1 then
            self.timer = self.timer - 1
            self.right_btn_lab:setString(string.format("%s(%s)", TI18N("确认消耗"), self.timer))
        else
            self.right_btn_lab:setString(TI18N("确认消耗"))
            setChildUnEnabled(false, self.right_btn)
            self.right_btn:setTouchEnabled(true)
            self.right_btn_lab:enableOutline(Config.ColorData.data_color4[264],2)
        end
    end, 1, self.timer)
end

function ActionHeroSkinResetPanel:close_callback()
    if self.timer_id then
        GlobalTimeTicket:getInstance():remove(self.timer_id)
    end

    if self.left_item_1 then
        self.left_item_1:DeleteMe()
    end
    self.left_item_1 = nil

    if self.right_item_1 then
        self.right_item_1:DeleteMe()
    end
    self.right_item_1 = nil

    if self.left_item_2 then
        self.left_item_2:DeleteMe()
    end
    self.left_item_2 = nil

    if self.right_item_2 then
        self.right_item_2:DeleteMe()
    end
    self.right_item_2 = nil

    controller:openActionHeroSkinResetPanel(false)
end