-- --------------------------------------------------------------------
--背包物品合成
-- --------------------------------------------------------------------
BackpackCompTips = BackpackCompTips or BaseClass(BaseView)

local partner_data = Config.PartnerData.data_get_compound_info
function BackpackCompTips:__init()
    self.ctrl = BackpackController:getInstance()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/backpack_comp_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
end

function BackpackCompTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.text_name = self.main_panel:getChildByName("text_name")
    self.get_path = self.main_panel:getChildByName("get_path")
    self.get_path:setVisible(false)
    self.get_path:getChildByName("Text_2"):setString(TI18N("获取途径"))
    self.goto_btn = self.get_path:getChildByName("goto")
    self.text_desc = self.main_panel:getChildByName("text_desc")

    self.goods_item =  BackPackItem.new(true,true,nil,1,false)
    self.goods_item:setPosition(cc.p(113,258))
    self.main_panel:addChild(self.goods_item)

end

function BackpackCompTips:register_event()
    registerButtonEventListener(self.background, function()
        self:close()
        TipsManager:getInstance():showBackPackCompTips(false)
    end,false, 2)

    registerButtonEventListener(self.goto_btn, function()
        if self.item_config then
            BackpackController:getInstance():openTipsSource(true, self.item_config.id)
            TipsManager:getInstance():showBackPackCompTips(false)
        end
    end, true, 1)
end

function BackpackCompTips:openRootWnd(item_bid)
    if not item_bid then return end
    local config = Config.ItemData.data_get_data(item_bid)
    
    local btn_num = 1
    if partner_data[config.id] then
        local random = partner_data[config.id].is_random
        if random == 1 then
            btn_num = 2
            self.get_path:setVisible(false)
        else
            self.get_path:setVisible(true)
        end
    else
        --符文
        local hallows_data = BackpackController:getModel():getHallowsCompData(config.id)
        if hallows_data then
            self.get_path:setVisible(true)
        end
    end
    self.item_config = config
    self:showBtn(btn_num)
    self:setBaseInfo()
end

--显示按钮个数
function BackpackCompTips:showBtn(num)
    local pos = num == 1 and self.main_panel:getContentSize().width/2 or (self.main_panel:getContentSize().width/2 + 120)
    local btn = createButton(self.main_panel,TI18N("合成"),pos,60,cc.size(168,62),PathTool.getResFrame("common","common_1017"),24,Config.ColorData.data_color4[1])
    btn:setName("com_btn")
    btn:setRichText(TI18N('<div fontColor=#ffffff fontsize=24 shadow=0,-2,2,#0e73b3>合成</div>'))
    btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            local item_data = BackpackController:getModel():getBackPackItemNumByBid(self.item_config.id)
            local num = 1
            local status = false
            local product_id 
            if partner_data[self.item_config.id] then
                product_id = self.item_config.id
                local comp_num = partner_data[self.item_config.id].num
                num = math.floor(item_data/comp_num)
                status = true
            else
                local hallows_data = BackpackController:getModel():getHallowsCompData(self.item_config.id)
                product_id = hallows_data.bid
                num = math.floor(item_data/hallows_data.num)
            end

            if num >= 2 then
                if status == true then
                    TipsManager:getInstance():showCompChooseTips(true,self.item_config.id)
                else
                    BackpackController:getInstance():sender10523(product_id, 1)
                end
            else
                if num ~= 0 then
                    if status == true then
                        BackpackController:getInstance():sender11008(self.item_config.id, 1)
                    else
                        BackpackController:getInstance():sender10523(product_id, 1)
                    end
                else
                    message(TI18N("数量不足"))
                end 
            end
        end
    end)
    if num == 2 then
        local btn1 = createButton(self.main_panel,TI18N("详情"),self.main_panel:getContentSize().width/2 - 120,60,cc.size(168,62),PathTool.getResFrame("common","common_1017"),24,Config.ColorData.data_color4[1])
        btn1:setRichText(TI18N('<div fontColor=#ffffff fontsize=24 shadow=0,-2,2,#0e73b3>详情</div>'))
        btn1:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                if self.item_config.effect and self.item_config.effect[1].val and self.item_config.eqm_jie then
                    TipsManager:getInstance():showBackPackCompTips(false)
                    HeroController:getInstance():openHeroInfoWindowByBidStar(self.item_config.effect[1].val, self.item_config.eqm_jie)
                end
            end
        end)
    end
end

--==============================--
function BackpackCompTips:setBaseInfo()
    if self.item_config == nil then return end

    self.goods_item:setBaseData(self.item_config.id)
    self.text_name:setString(self.item_config.name)
    self.text_desc:setString(self.item_config.use_desc)
end

function BackpackCompTips:close_callback()
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
    self.goods_item = nil
    TipsManager:getInstance():showBackPackCompTips(false)
end
