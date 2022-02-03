-- --------------------------------------------------------------------
--背包物品合成
-- --------------------------------------------------------------------
ArenaLoopChallengeBuy = ArenaLoopChallengeBuy or BaseClass(BaseView)

local controller = ArenaController:getInstance()
local role_vo = RoleController:getInstance():getRoleVo()
function ArenaLoopChallengeBuy:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "arena/arean_loop_challenge_buy"
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.change_num = 1
    self.init_change_num = 1
end

function ArenaLoopChallengeBuy:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.btn_close = self.main_container:getChildByName("btn_close")
    self.title_txt = self.main_container:getChildByName("Sprite_1"):getChildByName("Text_1")
    self.title_txt:setString(TI18N("道具购买"))
    self.item_name = self.main_container:getChildByName("Text_2")

    self.main_container:getChildByName("cost_title"):setString(TI18N("共花费:"))
    self.buy_tips = self.main_container:getChildByName("buy_tips")
    self.buy_tips:setVisible(false)
    
    self.gold_change = self.main_container:getChildByName("gold_change")
    self.buy_num = self.main_container:getChildByName("Image_num"):getChildByName("buy_num")
    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.btn_buy:getChildByName("Text_3"):setString(TI18N("确定"))
    self.btn_redu = self.main_container:getChildByName("btn_redu")
    self.btn_add = self.main_container:getChildByName("btn_add")

    self.edit_content = createEditBox(self.main_container, PathTool.getResFrame("common","common_99998"),cc.size(90,36), Config.ColorData.data_color4[175], 26, Config.ColorData.data_color4[175], 26, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content:setAnchorPoint(cc.p(0.5,0.5))
    self.edit_content:setPosition(cc.p(320, 209))

    local begin_change_label = false
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if begin_change_label then  
                begin_change_label = false
                self.buy_num:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.input_text then
                    local num = tonumber(str)
                    if num ~= nil and num >= 0 then
                        self:showEditNum(num)
                    else
                        self:showEditNum(self.change_num)
                        message(TI18N("请输入数字"))
                    end
                else
                    self:showEditNum(self.change_num)
                end 

            end
        elseif strEventName == "began" then
            if not begin_change_label then
                self.buy_num:setVisible(false)
                begin_change_label = true
            end
        elseif strEventName == "changed" then

        end
    end
    self.edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)

    self.cost_icon = self.main_container:getChildByName("icon")
    self.cost_icon:setScale(0.3)
end

function ArenaLoopChallengeBuy:register_event()
    registerButtonEventListener(self.background, function()
        controller:openArenaLoopChallengeBuy(false)
    end,false, 2)
    registerButtonEventListener(self.btn_close, function()
        controller:openArenaLoopChallengeBuy(false)
    end,true, 2)

    registerButtonEventListener(self.btn_redu, function()
        local have_num = role_vo.gold
        if self.cost_item_key and self.cost_item_key ~= "gold" then
            have_num = role_vo[self.cost_item_key] or 0
        end
        if have_num <= 0 then message(TI18N("数量不足")) return end
        self.change_num = self.change_num - 1
        if self.change_num <= 0 then
            self.change_num = 1
            message(TI18N("购买数量不能为0"))
        end
        local str = string.format(TI18N("<div fontcolor=#fff6e4>%s /</div><div fontcolor=#84e766> %s</div>"),MoneyTool.GetMoneyString(have_num), MoneyTool.GetMoneyString(self.expend_num*self.change_num))
        self.richlabel_num:setString(str)
        self.buy_num:setString(self.change_num)
    end,true, 1)
    registerButtonEventListener(self.btn_add, function()
        local have_num = role_vo.gold
        if self.cost_item_key and self.cost_item_key ~= "gold" then
            have_num = role_vo[self.cost_item_key] or 0
        end
        if have_num <= 0 then message(TI18N("数量不足")) return end
        self.change_num = self.change_num + 1
        if self.change_num >= self.init_change_num then
            self.change_num = self.init_change_num
            message(TI18N("已达最大购买值"))
        end        
        local str = string.format(TI18N("<div fontcolor=#fff6e4>%s /</div><div fontcolor=#84e766> %s</div>"),MoneyTool.GetMoneyString(have_num), MoneyTool.GetMoneyString(self.expend_num*self.change_num))
        self.richlabel_num:setString(str)
        self.buy_num:setString(self.change_num)
    end,true, 1)
    registerButtonEventListener(self.btn_buy, function()
        if self.change_num <= 0 then
            message(TI18N("购买数量不能为0"))
            return
        end
        if self.view_type == ArenaConst.view_type.summon then
            EliteSummonController:getInstance():send16692(self.change_num)
        elseif self.view_type == ArenaConst.view_type.elfin then
            if self.extra_data then
                ElfinController:getInstance():sender26507(self.extra_data, self.item_bid, self.change_num)
                controller:openArenaLoopChallengeBuy(false)
            end
        else
            controller:sender20207(self.change_num)
        end
    end,true, 1)
end

function ArenaLoopChallengeBuy:showEditNum( num )
    if not num then return end

    if num <= 0 then
        num = self.change_num
        message(TI18N("购买数量不能为0"))
    elseif num >= self.init_change_num then
        num = self.init_change_num
        message(TI18N("已达最大购买值"))
    end
    self.change_num = num
    self.buy_num:setString(num)
    self.buy_num:setVisible(true)
    local have_num = role_vo.gold
    if self.cost_item_key and self.cost_item_key ~= "gold" then
        have_num = role_vo[self.cost_item_key] or 0
    end
    local str = string.format(TI18N("<div fontcolor=#fff6e4>%s /</div><div fontcolor=#84e766> %s</div>"),MoneyTool.GetMoneyString(have_num), MoneyTool.GetMoneyString(self.expend_num*self.change_num))
    self.richlabel_num:setString(str)
end

function ArenaLoopChallengeBuy:openRootWnd(setting)
    setting = setting or {}
    self.item_bid = setting.item_bid
    self.view_type = setting.view_type or ArenaConst.view_type.arena
    self.extra_data = setting.extra_data

    if self.view_type == ArenaConst.view_type.arena then
        self.title_txt:setString(TI18N("道具购买"))
        self.buy_tips:setVisible(false)
    elseif self.view_type == ArenaConst.view_type.elfin then
        self.title_txt:setString(TI18N("快速补充"))
        if setting.tips_str then
            self.buy_tips:setVisible(true)
            self.buy_tips:setString(setting.tips_str)
        end
    end

    --消耗物品的单价
    self.expend_num = Config.ArenaData.data_const.ticket_price.val[1][2]
    if setting.item_price then
        self.expend_num = setting.item_price
    end

    local config = Config.ArenaData.data_const
    self.goods_item = BackPackItem.new(true,true)
    self.main_container:addChild(self.goods_item)
    self.goods_item:setPosition(cc.p(self.main_container:getContentSize().width/2, 307))

    if self.item_bid then
        local item_config = Config.ItemData.data_get_data(self.item_bid)
        self.item_name:setString(item_config.name)
        self.item_name:setTextColor(BackPackConst.getWhiteQualityColorC4B(item_config.quality))
        self.goods_item:setBaseData(self.item_bid)
    else
        self.item_name:setString(TI18N("竞技挑战劵"))
        local item_config = Config.ItemData.data_get_data(Config.ArenaData.data_const.arena_ticketcost.val[1][1])
        self.goods_item:setBaseData(item_config.icon)
    end
    self.richlabel_num = createRichLabel(26, cc.c4b(255,246,228,255), cc.p(0.5, 0.5), cc.p(self.gold_change:getContentSize().width*0.5+10, self.gold_change:getContentSize().height*0.5), nil, nil, 250)
    self.gold_change:addChild(self.richlabel_num)

    -- 价格类型
    if setting.cost_item_id then
        self.cost_item_key = Config.ItemData.data_assets_id2label[setting.cost_item_id]
        local item_config = Config.ItemData.data_get_data(setting.cost_item_id)
        loadSpriteTexture(self.cost_icon, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
    else
        self.cost_item_key = "gold"
        local item_config = Config.ItemData.data_get_data(Config.ArenaData.data_const.ticket_price.val[1][1])
        loadSpriteTexture(self.cost_icon, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
    end

    local have_num = role_vo.gold
    if self.cost_item_key and self.cost_item_key ~= "gold" then
        have_num = role_vo[self.cost_item_key] or 0
    end
    local str = string.format(TI18N("<div fontcolor=#fff6e4>%s /</div><div fontcolor=#84e766> %s</div>"),MoneyTool.GetMoneyString(have_num), MoneyTool.GetMoneyString(self.expend_num))
    self.richlabel_num:setString(str)

    self.init_change_num = math.floor(have_num / Config.ArenaData.data_const.ticket_price.val[1][2])
    if setting.max_buy_num and setting.max_buy_num < self.init_change_num then
        self.init_change_num = setting.max_buy_num
    end
    if self.init_change_num < 1 then self.init_change_num = 1 end
    if have_num >= Config.ArenaData.data_const.ticket_price.val[1][2] then
        self.change_num = 1
    end
    self.buy_num:setString(self.change_num)
end

function ArenaLoopChallengeBuy:close_callback()
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
    self.goods_item = nil
    controller:openArenaLoopChallengeBuy(false)
end