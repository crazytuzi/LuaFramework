-- --------------------------------------------------------------------
--背包物品合成
-- --------------------------------------------------------------------
CompChooseTips = CompChooseTips or BaseClass(BaseView)

local partner_data = Config.PartnerData.data_get_compound_info
function CompChooseTips:__init()
    self.ctrl = BackpackController:getInstance()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/comp_choose_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.cur_number = nil
    self.init_number = 1 --初始化是最大合成的个数
end
local imput_number = 500 --输入最大数量
function CompChooseTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    local main_panel = self.root_wnd:getChildByName("main_panel")
    self.text_name = main_panel:getChildByName("text_name")
    self.text_name:setString("")
    self.btn_redu = main_panel:getChildByName("btn_redu")
    self.btn_add = main_panel:getChildByName("btn_add")
    self.comp_num_text = main_panel:getChildByName("comp_num")
    self.comp_num_text:setString("")
    self.btn_comp = main_panel:getChildByName("btn_comp")
    self.btn_comp_label = self.btn_comp:getChildByName("Text_1")
    self.btn_comp_label:setString(TI18N("合成"))
    self.btn_comp_label:enableOutline(Config.ColorData.data_color4[264], 2)

    main_panel:getChildByName("Text_2"):setString(TI18N("点击数字框可输入数字"))
    --合成数字
    local comp_node = main_panel:getChildByName("comp_node")
    self.comp_number_edit = createEditBox(comp_node, PathTool.getResFrame("common", "common_1021"), cc.size(194, 41), cc.c4b(0x00,0x00,0x00,0xff), 26, cc.c4b(0x00,0x00,0x00,0xff), 26, "", nil, 6, LOADTEXT_TYPE_PLIST)
    self.comp_number_edit:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)

    local function onEditCompNumberEvent(event,sender)
        if event == "ended" then
            local str = sender:getText()
            sender:setText("")
            self.comp_num_text:setVisible(true)
            if str ~= "" then
                local num = tonumber(str)
                if num == nil then 
                    num = 0
                end
                if num <= 0 then
                    num = 1
                    self:setTouchEnable_Add(false)
                    self:setTouchEnable_Redu(true)
                elseif num >= self.init_number then
                    self:setTouchEnable_Add(true)
                    self:setTouchEnable_Redu(false)
                else
                    self:setTouchEnable_Add(false)
                    self:setTouchEnable_Redu(false)
                end
                if num >= imput_number then
                    num = imput_number
                end
                self.comp_num_text:setString(num)
                self.cur_number = num
            else
                message(TI18N("需写入合成数量哦~~"))
                self.comp_num_text:setString("")
                self.cur_number = nil
                return
            end
        elseif event == "began" then
            self.comp_num_text:setVisible(false)
        elseif event == "changed" then
        end
    end
    self.comp_number_edit:registerScriptEditBoxHandler(onEditCompNumberEvent)

    self.goods_item =  BackPackItem.new(true,true,nil,1,false)
    self.goods_item:setPosition(cc.p(main_panel:getContentSize().width/2,279))
    main_panel:addChild(self.goods_item)
end

function CompChooseTips:register_event()
    registerButtonEventListener(self.background, function()
        self:close()
        TipsManager:getInstance():showCompChooseTips(false)
    end,false, 2)

    registerButtonEventListener(self.btn_redu, function()
        if self.cur_number then
            self:touch_redu()
        end
    end,true, 1)

    registerButtonEventListener(self.btn_add, function()
        if self.cur_number then
            self:touch_add()
        end
    end,true, 1)

    registerButtonEventListener(self.btn_comp, function()
        if not self.cur_number then
            return
        end
        if self.cur_number < 1 then
            if self.view_type == 2 then
                message(TI18N("使用数量不能少于1"))
            else
                message(TI18N("合成数量不能少于1"))
            end
            return
        end
        if self.cur_number > self.init_number then
            if self.view_type == 2 then
                message(TI18N("背包物品数量不足"))
            else
                message(TI18N("背包碎片数量不足"))
            end
            return
        end
        if self.item_config then
            if self.view_type == 2 then
                local firework_bid_cfg = Config.HolidayPetardData.data_const["firework_bid"]
                if firework_bid_cfg and firework_bid_cfg.val == self.item_config.id then
                    PetardActionController:getInstance():openAffirmWindow(true, self.item_config.id, self.cur_number)
                else
                    PetardActionController:getInstance():sender27001(self.item_config.id, self.cur_number)
                end
                TipsManager:getInstance():showCompChooseTips(false)
            else
                if partner_data[self.item_config.id] then
                    BackpackController:getInstance():sender11008(self.item_config.id, self.cur_number)
                end
            end
        end
    end,true, 1)
end
function CompChooseTips:touch_redu()
    self.cur_number = self.cur_number - 1
    if self.cur_number < self.init_number then
        self:setTouchEnable_Add(false)
        self:setTouchEnable_Redu(false)
    end
    if self.cur_number <= 1 then
        self:setTouchEnable_Add(false)
        self:setTouchEnable_Redu(true)
    end
    self.comp_num_text:setString(self.cur_number)
end

function CompChooseTips:touch_add()
    self.cur_number = self.cur_number + 1
    if self.cur_number > 1 then
        self:setTouchEnable_Add(false)
        self:setTouchEnable_Redu(false)
    end
    if self.cur_number >= self.init_number then
        self:setTouchEnable_Add(true)
        self:setTouchEnable_Redu(false)
    end
    self.comp_num_text:setString(self.cur_number)
end

function CompChooseTips:setTouchEnable_Add(bool)
    setChildUnEnabled(bool,self.btn_add)
    self.btn_add:setTouchEnabled(not bool)
end
function CompChooseTips:setTouchEnable_Redu(bool)
    setChildUnEnabled(bool,self.btn_redu)
    self.btn_redu:setTouchEnabled(not bool)
end

-- view_type:1 碎片合成 2:烟花物品使用
function CompChooseTips:openRootWnd(item_bid, view_type)
    if not item_bid then return end
    self.view_type = view_type or 1
    local config = Config.ItemData.data_get_data(item_bid)
    self.item_config = config
    self:setBaseInfo()
end

function CompChooseTips:setBaseInfo()
    if self.item_config == nil then return end
    self.goods_item:setBaseData(self.item_config.id)
    self.text_name:setString(self.item_config.name)

    local item_data = BackpackController:getModel():getBackPackItemNumByBid(self.item_config.id)
    if self.view_type == 2 then -- 特殊物品烟花的使用
        self.btn_comp_label:setString(TI18N("使用"))
        self.cur_number = item_data
        self.init_number = self.cur_number
    else
        local comp_num = 1
        if partner_data[self.item_config.id] then
            comp_num = partner_data[self.item_config.id].num
        else
            local hallows_data = BackpackController:getModel():getHallowsCompData(self.item_config.id)
            comp_num = hallows_data.num
        end
        self.cur_number = math.floor(item_data/comp_num)
        self.init_number = self.cur_number
    end
    self.comp_num_text:setString(self.cur_number)
    self:setTouchEnable_Add(true)
end

function CompChooseTips:close_callback()
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
    self.goods_item = nil
    TipsManager:getInstance():showCompChooseTips(false)
end
