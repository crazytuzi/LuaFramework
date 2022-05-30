-- --------------------------------------------------------------------
-- 
-- 
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: lwc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ActionSkinDirectPurchasePanel = ActionSkinDirectPurchasePanel or BaseClass(BaseView)

local controller = ActionController:getInstance()
local model = controller:getModel()
local table_insert = table.insert

function ActionSkinDirectPurchasePanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big

    self.is_full_screen = true
    self.layout_name = "action/action_skin_direct_purchase_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("actionskindp","actionskindp"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/action", "txt_cn_skin_direct_purchase_bg", false), type = ResourcesType.single},
    }

    self.touch_buy_skin = true
end

function ActionSkinDirectPurchasePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.bg = self.main_container:getChildByName("bg")
    loadSpriteTexture(self.bg, PathTool.getPlistImgForDownLoad("bigbg/action", "txt_cn_skin_direct_purchase_bg", false), LOADTEXT_TYPE)

    self.close_btn = self.main_container:getChildByName("close_btn")
    self.show_btn = self.main_container:getChildByName("show_btn")
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn_label = self.comfirm_btn:getChildByName("label")
    self.time_text_0 = self.main_container:getChildByName("time_text_0")
    self.time_text_0:setString(TI18N("剩余时间:"))
    self.time_text = self.main_container:getChildByName("time_text")

    self.scroll_container = self.main_container:getChildByName("scroll_container")
    local size = self.scroll_container:getContentSize()
    self.scroll_view = createScrollView(size.width, size.height, 0, 0, self.scroll_container, ScrollViewDir.horizontal ) 
end 


function ActionSkinDirectPurchasePanel:register_event()
    -- registerButtonEventListener(self.background, function (  )  
    --     controller:openActionSkinDirectPurchasePanel(false)
    -- end, nil, 2)

    registerButtonEventListener(self.close_btn, function (  )
        controller:openActionSkinDirectPurchasePanel(false)
    end, true, 2)


    registerButtonEventListener(self.show_btn, function (  ) self:onShowBtn() end, true, 2, nil,nil, 2)
    registerButtonEventListener(self.comfirm_btn, function (  ) self:onComfirmBtn() end, true, 2)



    -- 已完成冒险奇遇刷新
    self:addGlobalEvent(ActionEvent.UPDATE_HOLIDAY_SIGNLE, function ( data )
        if not data then return end
        if data.bid == ActionRankCommonType.skin_direct_purchase then
            self:setData(data)
        end
    end)
end

function ActionSkinDirectPurchasePanel:onShowBtn()
    TimesummonController:getInstance():send23219(ActionRankCommonType.skin_direct_purchase)
end

function ActionSkinDirectPurchasePanel:onComfirmBtn()
    if not self.touch_buy_skin then return end
    if not self.cur_skin_id then return end

    --判断皮肤是否拥有
    local is_has_skin = HeroController:getModel():isUnlockHeroSkin(self.cur_skin_id, true)
    if is_has_skin then
        local skin_info = Config.PartnerSkinData.data_skin_info
        if skin_info and skin_info[self.cur_skin_id] then
            local data = skin_info[self.cur_skin_id].diamond_num
            if data and data[1] then
                local item_config = Config.ItemData.data_get_data(data[1][1])
                local icon_src = PathTool.getItemRes(item_config.icon)
                local str = string.format(TI18N("您已拥有当前皮肤的永久使用权，再次购买后使用将会转化成 <img src='%s' scale=0.3 /><div fontcolor=#289b14> *%d </div>，是否继续购买"),icon_src,data[1][2])
                local call_back = function()
                    self:setChargeSkin()
                end
                CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
                return
            end
        end
    end
    self:setChargeSkin()
end

function ActionSkinDirectPurchasePanel:setChargeSkin()
    if self.buy_skin_ticket == nil then
        self.buy_skin_ticket = GlobalTimeTicket:getInstance():add(function()
            self.touch_buy_skin = true
            if self.buy_skin_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.buy_skin_ticket)
                self.buy_skin_ticket = nil
            end
        end,3)
    end
    self.touch_buy_skin = nil
    if self.buy_charge_id then
        local charge_config = Config.ChargeData.data_charge_data[self.buy_charge_id]
        if charge_config then
            sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name)
        end
    end
end




function ActionSkinDirectPurchasePanel:openRootWnd()
    controller:cs16603(ActionRankCommonType.skin_direct_purchase)
end

function ActionSkinDirectPurchasePanel:setData(data_list)
    commonCountDownTime(self.time_text, data_list.remain_sec)
    local data = data_list.aim_list or nil
    if data and data[1] then
        local skin_list = keyfind('aim_args_key', 35, data[1].aim_args) or nil
        local skin_count
        if skin_list then
            self.cur_skin_id = skin_list.aim_args_val or 101
            self:setAttrData(self.cur_skin_id)
        end

        if data[1].item_list and next(data[1].item_list) ~= nil then
            local data_list = {}
            for i,v in ipairs(data[1].item_list) do
                table_insert(data_list, {v.bid, v.num})
            end
            local setting = {}
            setting.scale = 0.9
            setting.start_x = 0
            setting.space_x = 10
            setting.max_count = 5
            setting.is_center = true
            self.item_list = commonShowSingleRowItemList(self.scroll_view, self.item_list, data_list, setting)
        end

        if data_list.finish ~= 0 then
            setChildUnEnabled(true, self.comfirm_btn)
            self.comfirm_btn_label:setString(TI18N("已购买"))
            self.comfirm_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            self.comfirm_btn:setTouchEnabled(false)
        else
            --现价
            local new_list = keyfind('aim_args_key', 33, data[1].aim_args) or nil
            local buy_charge_id
            if new_list then
                buy_charge_id = new_list.aim_args_val or 0
            end
            if buy_charge_id then
                self.buy_charge_id = buy_charge_id
                local charge_data = Config.ChargeData.data_charge_data
                if charge_data[buy_charge_id] then
                    self.comfirm_btn_label:setString("￥"..charge_data[buy_charge_id].val)
                end
            end
        end
    end
end

function ActionSkinDirectPurchasePanel:setAttrData(bid)
    local skin_attr = Config.PartnerSkinData.data_skin_info
    if skin_attr and skin_attr[bid] then
        local attr = skin_attr[bid].skin_attr or {}
        local str_sttr = {}
        for i,v in pairs(attr) do
            local attr_icon = PathTool.getAttrIconByStr(v[1])
            local name = Config.AttrData.data_key_to_name[v[1]] or ""
            local sttr_1,sttr_2,sttr_3 = commonGetAttrInfoByKeyValue(v[1], v[2])
            str_sttr[i] = string.format("<img src=%s visible=true scale=1 /><div fontColor=#89ff83 outline=2,#000000> %s+%s</div>",sttr_1,sttr_2,sttr_3)
        end
        local str = ""
        for i=1, #str_sttr do
            str = str .. str_sttr[i] .. "  "
        end

        local attr_msg = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(1, 0.5), cc.p(673,289),nil,nil,600)
        self.main_container:addChild(attr_msg)
        attr_msg:setString(TI18N("<div fontColor=#ffffff outline=2,#000000>属性加成：</div>")..str)
    end
end


function ActionSkinDirectPurchasePanel:close_callback()
    controller:openActionSkinDirectPurchasePanel(false)
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:DeleteMe()
        end
    end
    self.item_list = nil

end