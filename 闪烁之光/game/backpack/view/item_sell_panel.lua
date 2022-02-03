-- --------------------------------------------------------------------
--道具出售  可以批量 --by lwc
--日期 2018年11月29日
-- --------------------------------------------------------------------
ItemSellPanel = ItemSellPanel or BaseClass(BaseView)

local controller = BackpackController:getInstance()

function ItemSellPanel:__init()
    self.ctrl = BackpackController:getInstance()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "backpack/item_sell_panel"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.cur_number = 1
    self.init_number = 1 --初始化是最大合成的个数
end

function ItemSellPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
    self.text_name = self.main_panel:getChildByName("text_name")
    self.text_name:enableOutline(Config.ColorData.data_color4[2], 1)
    self.text_name:setString("")
    self.btn_redu = self.main_panel:getChildByName("btn_redu")
    self.btn_add = self.main_panel:getChildByName("btn_add")
    self.comp_num = self.main_panel:getChildByName("Image_2"):getChildByName("comp_num")
    self.comp_num:setString("")
    self.btn_comp = self.main_panel:getChildByName("btn_comp")
    self.btn_comp_label = self.btn_comp:getChildByName("Text_1")
    self.btn_comp_label:setString(TI18N("出售"))

    self.goods_item =  BackPackItem.new(true,true,nil,1,false)
    self.goods_item:setPosition(cc.p(self.main_panel:getContentSize().width/2,276))
    self.main_panel:addChild(self.goods_item)

    local cost_bg = self.main_panel:getChildByName("cost_bg_2014")
    local x ,y = cost_bg:getPosition()
    self.cost_label = createRichLabel(26,1, cc.p(0.5,0.5),cc.p(x , y))
    self.cost_label:setString("")
    self.main_panel:addChild(self.cost_label)

    self.sell_tips = self.main_panel:getChildByName("sell_tips")
    self.sell_tips:setVisible(false)

    local res = PathTool.getResFrame("common","common_99998")
    local edit_content = createEditBox(self.main_panel, res,cc.size(200,40), nil, 22, nil, 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content = edit_content
    edit_content:setAnchorPoint(cc.p(0.5,0.5))
    edit_content:setPlaceholderFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setPosition(cc.p(299, 188))

    local begin_change_label = false
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if begin_change_label then  
                begin_change_label = false
                self.comp_num:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.input_text then
                    local num = tonumber(str)
                    if num ~= nil and num > 0 then
                        self:checkShowNum(num)
                    else
                        self:checkShowNum(0)
                        message(TI18N("请输入数字"))
                    end
                else
                    self:checkShowNum(0)
                end 

            end
        elseif strEventName == "began" then
            if not begin_change_label then
                self.comp_num:setVisible(false)
                begin_change_label = true
            end
        elseif strEventName == "changed" then

        end
    end
    edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

function ItemSellPanel:checkShowNum(num)
    self.cur_number = num
    if self.cur_number <= 0 then
        self.cur_number= 1
    elseif self.cur_number >= self.init_number then
        self.cur_number = self.init_number
    end
    self:setBtnStatus()
    self.comp_num:setString(self.cur_number)
    self:setCostInfo(self.cur_number)
end

function ItemSellPanel:register_event()
    registerButtonEventListener(self.background, function() controller:openItemSellPanel(false) end,false, 2)

    registerButtonEventListener(self.btn_redu, function()
        self.cur_number = self.cur_number - 1
        if self.cur_number < 1 then
            self.cur_number = 1
        end
        self:setBtnStatus()
        self.comp_num:setString(self.cur_number)
        self:setCostInfo(self.cur_number)
    end,true, 1)

    registerButtonEventListener(self.btn_add, function()
        self.cur_number = self.cur_number + 1
        if self.cur_number > self.init_number then
            self.cur_number = self.init_number
        end
        self:setBtnStatus()
        self.comp_num:setString(self.cur_number)
        self:setCostInfo(self.cur_number)
    end,true, 1)

    registerButtonEventListener(self.btn_comp, function()
        if not self.goods_vo then return end
        if self.cur_number <  0 then return end
        if self.open_type == 2 then
            if self.item_config and self.item_config.value and next(self.item_config.value) ~= nil then
                local item_list = {}
                for i,v in ipairs(self.item_config.value) do
                    table.insert(item_list, {id = v[1], num = v[2]*self.cur_number})
                end
                local tips_str = string.format(TI18N("出售家具<div fontcolor=%s>【%s*%d】</div>可获得以下资源："), BackPackConst.getWhiteQualityColorStr(self.item_config.quality), self.item_config.name, self.cur_number)
                HeroController:getInstance():openHeroResetOfferPanel(true, item_list, false, function()
                    controller:sender10522(self.bag_type, {{id=self.goods_vo.id, bid=self.goods_vo.base_id,num=self.cur_number}})
                end, HeroConst.ResetType.eFunriture, tips_str)
            end
            controller:openItemSellPanel(false)
        else
            self:senderProto(true)
        end
        
    end,true, 1)
    
    if not self.elfin_plan_tips_event then
        self.elfin_plan_tips_event = GlobalEvent:getInstance():Bind(ElfinEvent.Elfin_Plan_Must_Tips_Event, function(data)
            if data and data.flag == TRUE then
                self:showTips(data)
            else
                self:senderProto(false)
            end
        end)
    end
end

function ItemSellPanel:showTips(data)
    local function fun()
        self:senderProto(false)
    end
    local str 
    if data.type == 0 then
        str = string.format(TI18N('<div fontcolor=%s>【%s】</div>精灵已在玩法中上阵，羽化后精灵将被下阵，是否确认羽化？'), BackPackConst.getWhiteQualityColorStr(self.item_config.quality), self.item_config.name)
    else
        str = string.format(TI18N('<div fontcolor=%s>【%s】</div>精灵已在方案【%s】中上阵，羽化后精灵将被下阵，是否确认羽化？'), BackPackConst.getWhiteQualityColorStr(self.item_config.quality), self.item_config.name, data.name)
    end
    CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
end


function ItemSellPanel:senderProto(is_check)
    if is_check then
        if self.item_config.sub_type == BackPackConst.item_tab_type.ELFIN then
            --如果是精灵 需要多一步
            ElfinController:getInstance():send26563(self.goods_vo.base_id, self.cur_number)
        else
            controller:sender10522(self.bag_type, {{id=self.goods_vo.id, bid=self.goods_vo.base_id,num=self.cur_number}})  
            controller:openItemSellPanel(false)  
        end
    else
        controller:sender10522(self.bag_type, {{id=self.goods_vo.id, bid=self.goods_vo.base_id,num=self.cur_number}})
        controller:openItemSellPanel(false)
    end
end

function ItemSellPanel:setBtnStatus()
    if self.init_number == 1 then
        self:setTouchEnable_Redu(true)
        self:setTouchEnable_Add(true)
    else
        if self.cur_number == 1 then
            self:setTouchEnable_Redu(true)
            self:setTouchEnable_Add(false)
        elseif self.cur_number == self.init_number then
            self:setTouchEnable_Redu(false)
            self:setTouchEnable_Add(true)
        else
            self:setTouchEnable_Redu(false)
            self:setTouchEnable_Add(false)
        end
    end
end

function ItemSellPanel:setTouchEnable_Add(bool)
    setChildUnEnabled(bool,self.btn_add)
    self.btn_add:setTouchEnabled(not bool)
end
function ItemSellPanel:setTouchEnable_Redu(bool)
    setChildUnEnabled(bool,self.btn_redu)
    self.btn_redu:setTouchEnabled(not bool)
end

-- open_type: 1:物品物品出售 2:家具出售 3:精灵羽化（出售）
function ItemSellPanel:openRootWnd(goods_vo, bag_type, open_type)
    if not goods_vo then return end
    self.open_type = open_type or 1
    self.bag_type = bag_type or BackPackConst.Bag_Code.BACKPACK
    self.goods_vo = goods_vo
    self.item_config = goods_vo.config
    self:setBaseInfo(self.cur_number)

    if self.open_type == 3 then
        local elfin_cfg = Config.SpriteData.data_elfin_data(self.item_config.id)
        if (elfin_cfg and elfin_cfg.step >= 4) or self.item_config.quality >= 4 then
            setChildUnEnabled(true, self.btn_comp)
            self.btn_comp_label:disableEffect(cc.LabelEffect.OUTLINE)
            self.btn_comp:setTouchEnabled(false)
            self.timer = 3
            self.btn_comp_label:setString(string.format("%s(%s)", TI18N("羽化"), self.timer))
            self:showAutoBtnTimer()
            self.sell_tips:setVisible(true)
        else
            self.btn_comp_label:setString(TI18N("羽化"))
        end
        if not self.elfin_tips then
            self.elfin_tips = createRichLabel(22, cc.c4b(224, 191, 152, 255), cc.p(0.5, 0.5), cc.p(299, 390), nil, nil, 590)
            self.main_panel:addChild(self.elfin_tips)
        end
        self.elfin_tips:setString(TI18N("精灵羽化后将<div fontcolor=#ef3a3a>消失</div>，您将得到相应数量的奥术之尘"))
    else
        self.btn_comp_label:setString(TI18N("出售"))
    end
end

function ItemSellPanel:showAutoBtnTimer(  )
    if not self.timer then return end
    self.timer_id = GlobalTimeTicket:getInstance():add(function()
        if self.timer > 1 then
            self.timer = self.timer - 1
            self.btn_comp_label:setString(string.format("%s(%s)", TI18N("羽化"), self.timer))
        else
            self.btn_comp_label:setString(TI18N("羽化"))
            self.sell_tips:setVisible(false)
            setChildUnEnabled(false, self.btn_comp)
            self.btn_comp:setTouchEnabled(true)
            self.btn_comp_label:enableOutline(Config.ColorData.data_color4[264],2)
        end
    end, 1, self.timer)
end

function ItemSellPanel:setBaseInfo()
    if not self.item_config then return end

    self.goods_item:setData(self.goods_vo)
    self.text_name:setString(self.item_config.name)
    local fontcolor = BackPackConst.getEquipTipsColor(self.item_config.quality)
    if fontcolor then
        self.text_name:setTextColor(fontcolor)
    end
    if self.item_config.overlap > 1 then
        local count = BackpackController:getInstance():getModel():getPackItemNumByBid(self.bag_type,self.item_config.id)
        if self.open_type == 2 then -- 家具出售特殊处理
            if self.goods_vo.have_num > self.goods_vo.bag_num then
                self.init_number = self.goods_vo.bag_num
            else
                self.init_number = self.goods_vo.have_num
            end
            if self.init_number > 1 then
                self.cur_number = self.init_number - 1
            else
                self.cur_number = 1
            end
        else
            self.cur_number = count
            self.init_number = count
        end
    else
        self.cur_number = 1
        self.init_number = self.cur_number
    end
    
    self.comp_num:setString(self.cur_number)

    self:setBtnStatus()

    --计算价值
    self:setCostInfo(self.cur_number)
end

function ItemSellPanel:setCostInfo(count)
    if not self.item_config then return end
    if self.item_config.value and next(self.item_config.value) ~= nil then
        local item_id = self.item_config.value[1][1]
        local price = self.item_config.value[1][2]
        local total_price = self.cur_number * price
        local item_cfg = Config.ItemData.data_get_data(item_id)
        if item_cfg then
            local res = PathTool.getItemRes(item_cfg.icon)
            local str = string.format("<img src=%s scale=0.35 visible=true /><div fontColor=#FFF6DD>%s</div>",res, total_price)
            self.cost_label:setString(str)
        end
    end
end

function ItemSellPanel:close_callback()


    if self.elfin_plan_tips_event then
        GlobalEvent:getInstance():UnBind(self.elfin_plan_tips_event)
        self.elfin_plan_tips_event = nil
    end
    if self.timer_id then
        GlobalTimeTicket:getInstance():remove(self.timer_id)
    end
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
    self.goods_item = nil
    controller:openItemSellPanel(false)
end
