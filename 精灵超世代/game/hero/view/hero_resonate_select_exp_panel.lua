-- --------------------------------------------------------------------
--经验注入  --by lwc
--日期 2019年8月2日
-- --------------------------------------------------------------------
HeroResonateSelectExpPanel = HeroResonateSelectExpPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()

function HeroResonateSelectExpPanel:__init()
    self.ctrl = BackpackController:getInstance()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/hero_resonate_select_exp_panel"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.cur_number = 1
    self.init_number = 1 --初始化是最大合成的个数
end

function HeroResonateSelectExpPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel , 2) 
    self.text_name = self.main_panel:getChildByName("text_name")
    self.text_name:setString("")
    self.btn_redu = self.main_panel:getChildByName("btn_redu")
    self.btn_add = self.main_panel:getChildByName("btn_add")
    self.comp_num = self.main_panel:getChildByName("Image_2"):getChildByName("comp_num")
    self.comp_num:setString("")
    self.btn_comp = self.main_panel:getChildByName("btn_comp")
    self.btn_comp:getChildByName("Text_1"):setString(TI18N("放入"))

    self.goods_item =  BackPackItem.new(true,true,nil,1,false)
    self.goods_item:setPosition(cc.p(self.main_panel:getContentSize().width/2, 342))
    self.main_panel:addChild(self.goods_item)

    local cost_bg = self.main_panel:getChildByName("cost_bg_2014")
    local x ,y = cost_bg:getPosition()
    self.cost_label = createRichLabel(26,1, cc.p(0.5,0.5),cc.p(x , y))
    self.cost_label:setString("")
    self.main_panel:addChild(self.cost_label)

    self.tips1 = self.main_panel:getChildByName("tips1")
    -- self.tips1:setString(TI18N("点击数字框编辑本次提炼的材料个数"))
    self.tips2 = self.main_panel:getChildByName("tips2")
    self.tips2:setString(TI18N("点击数字框编辑本次提炼的材料个数"))
    -- self.tips2:setString(TI18N("注入上限:xx个"))

    local res = PathTool.getResFrame("common","common_99998")
    local edit_content = createEditBox(self.main_panel, res,cc.size(194,40), nil, 22, nil, 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content = edit_content
    edit_content:setAnchorPoint(cc.p(0.5,0.5))
    edit_content:setPlaceholderFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setPosition(cc.p(299, 239))

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
                        self:checkShowNum(self.init_number)
                        message(TI18N("请输入数字"))
                    end
                else
                    self:checkShowNum(self.init_number)
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

function HeroResonateSelectExpPanel:register_event()
    registerButtonEventListener(self.background, function() controller:openHeroResonateSelectExpPanel(false) end,false, 2)

    registerButtonEventListener(self.btn_redu, function()
        self.cur_number = self.cur_number - 1
        if self.cur_number < 1 then
            self.cur_number = 1
        end
        self:checkShowNum()
    end,true, 1)

    registerButtonEventListener(self.btn_add, function()
        self.cur_number = self.cur_number + 1
        if self.cur_number > self.init_number then
            self.cur_number = self.init_number
        end
        self:checkShowNum()
    end,true, 1)

    registerButtonEventListener(self.btn_comp, function()
        if self.cur_number then
            controller:sender26411(self.cur_number)
            controller:openHeroResonateSelectExpPanel(false)
        end
    end,true, 1)
end

function HeroResonateSelectExpPanel:checkShowNum(num)
    if num then
        self.cur_number = num
        if self.cur_number > self.init_number then
            self.cur_number = self.init_number
        end
    end
    self:setBtnStatus()
    self.comp_num:setString(self.cur_number)
    self:setCostInfo(self.cur_number)
end

function HeroResonateSelectExpPanel:setBtnStatus()
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

function HeroResonateSelectExpPanel:setTouchEnable_Add(bool)
    setChildUnEnabled(bool,self.btn_add)
    self.btn_add:setTouchEnabled(not bool)
end
function HeroResonateSelectExpPanel:setTouchEnable_Redu(bool)
    setChildUnEnabled(bool,self.btn_redu)
    self.btn_redu:setTouchEnabled(not bool)
end

--setting.limit_count 限制购买数量
--setting.target_item_id 目标id
--setting.cost_item_id 消耗id
--setting.price 消耗价格
--setting.bag_type 背包类型 BackPackConst.Bag_Code.BACKPACK

function HeroResonateSelectExpPanel:openRootWnd(setting)
    local setting = setting or {}
    self.limit_count = setting.limit_count 
    self.target_item_id =  setting.target_item_id or 1
    self.cost_item_id = setting.cost_item_id or Config.ItemData.data_assets_label2id.hero_exp
    self.price = setting.price or 1
    
    --单个消耗
    self.item_config = Config.ItemData.data_get_data(self.target_item_id)
    self.cost_item_config = Config.ItemData.data_get_data(self.cost_item_id)
    self.bag_type = setting.bag_type or BackPackConst.Bag_Code.BACKPACK
    self:setBaseInfo()
end

function HeroResonateSelectExpPanel:setBaseInfo()
    if not self.item_config then return end
    if not self.cost_item_config then return end
    self.goods_item:setBaseData(self.item_config.id, 1)
    self.text_name:setString(self.item_config.name)

    local count = self.ctrl:getModel():getItemNumByBid(self.cost_item_config.id, self.bag_type)
    local max_count = math.floor(count/self.price)

    if self.limit_count then
        self.init_number = self.limit_count
        if max_count > self.limit_count then
            self.cur_number = self.limit_count
        else
            self.cur_number = max_count
        end
    else
        self.init_number = max_count
        self.cur_number = max_count
    end
    if self.cur_number == 0 then
        self.cur_number = 1
    end
    if self.init_number == 0 then
        self.init_number = 1
    end

    self.tips1:setString(string.format(TI18N("本次提炼上限:%s个"), self.init_number))

    self.comp_num:setString(self.cur_number)

    self:setBtnStatus()

    --计算价值
    self:setCostInfo(self.cur_number)
end

function HeroResonateSelectExpPanel:setCostInfo(count)
    if not self.cost_item_config then return end

    local total_price = count * self.price
    local count = self.ctrl:getModel():getItemNumByBid(self.cost_item_config.id, self.bag_type)
    local res = PathTool.getItemRes(self.cost_item_config.icon)
    local str 
    if total_price > count then --不够
        str = string.format("<img src=%s scale=0.35 visible=true /><div fontColor=#FF0000>%s</div>",res, total_price)
    else
        str = string.format("<img src=%s scale=0.35 visible=true /><div fontColor=#FFF6DD>%s</div>",res, total_price)
    end
    self.cost_label:setString(str)
    
end

function HeroResonateSelectExpPanel:close_callback()
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
    self.goods_item = nil
    controller:openHeroResonateSelectExpPanel(false)
end
