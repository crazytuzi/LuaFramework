--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年6月5日
-- @description    : 
        -- 道具出售功能
---------------------------------
HomePetItemSellPanel = HomePetItemSellPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()

function HomePetItemSellPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "homepet/home_pet_item_sell_panel"

    self.max_count = 10
    self.cur_count = 1
end

function HomePetItemSellPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 


    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("珍品出售"))

    self.close_btn = main_panel:getChildByName("close_btn")

    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("取 消"))

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("出 售"))

    self.item_node = self.main_container:getChildByName("item_node")
    self.item = BackPackItem.new(true,false,nil,0.8)
    self.item_node:addChild(self.item)

    local item_bg = self.main_container:getChildByName("item_bg")

    self.btn_redu = item_bg:getChildByName("btn_redu")
    self.btn_add = item_bg:getChildByName("btn_add")
    self.btn_max = item_bg:getChildByName("btn_max")

    self.item_icon = self.main_container:getChildByName("item_icon")
    self.cur_count_label = self.main_container:getChildByName("cur_count")
    self.total_count_label = self.main_container:getChildByName("total_count")

    self.main_container:getChildByName("num_key"):setString(TI18N("数量:"))
    self.main_container:getChildByName("total_key"):setString(TI18N("总价:"))
end

function HomePetItemSellPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn()  end ,true, 2)
    registerButtonEventListener(self.cancel_btn, function() self:onClosedBtn()  end ,true, 1)
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, 1)
    
    registerButtonEventListener(self.btn_redu, function() self:onReduBtn()  end ,true, 1)
    registerButtonEventListener(self.btn_add, function() self:onAddBtn()  end ,true, 1)
    registerButtonEventListener(self.btn_max, function() self:onMaxBtn()  end ,true, 1)
end

function HomePetItemSellPanel:onClosedBtn()
    controller:openHomePetItemSellPanel(false)
end

--最大
function HomePetItemSellPanel:onMaxBtn()
    if not self.goods_vo then return end
    self.cur_count = self.max_count
    self:updateLabelNum(self.cur_count)
end
--减少
function HomePetItemSellPanel:onReduBtn()
    if not self.goods_vo then return end
    self.cur_count = self.cur_count - 1
    if self.cur_count < 1 then
        self.cur_count = 1
    end
    self:updateLabelNum(self.cur_count)
end
--增加
function HomePetItemSellPanel:onAddBtn()
    if not self.goods_vo then return end
    self.cur_count = self.cur_count + 1
    if self.cur_count > self.max_count then
        self.cur_count = self.max_count
    end
    self:updateLabelNum(self.cur_count)
end

function HomePetItemSellPanel:updateLabelNum(count)
    if self.max_count <= 1 then
        self:setTouchEnable_Redu(true)
        self:setTouchEnable_Add(true)
        self.cur_count_label:setString(1)
        -- self.edit_content:setVisible(false)
        if self.goods_vo and self.goods_vo.config and next(self.goods_vo.config.value) ~= nil then
            local price = self.goods_vo.config.value[1][2]
            self.total_count_label:setString(price)
        end
        return
    end
    
    if count <=  1 then
        self:setTouchEnable_Redu(true)
        self:setTouchEnable_Add(false)
    elseif count == self.max_count then
        self:setTouchEnable_Redu(false)
        self:setTouchEnable_Add(true)
    else
        self:setTouchEnable_Redu(false)
        self:setTouchEnable_Add(false)
    end
    -- self.edit_content:setVisible(true)
    self.cur_count_label:setString(count)

    if self.goods_vo and self.goods_vo.config and next(self.goods_vo.config.value) ~= nil then
        local price = self.goods_vo.config.value[1][2]
        self.total_count_label:setString(count * price)
    end
end

function HomePetItemSellPanel:setTouchEnable_Add(bool)
    setChildUnEnabled(bool,self.btn_add)
    self.btn_add:setTouchEnabled(not bool)
end
function HomePetItemSellPanel:setTouchEnable_Redu(bool)
    setChildUnEnabled(bool,self.btn_redu)
    self.btn_redu:setTouchEnabled(not bool)
end

--确定
function HomePetItemSellPanel:onComfirmBtn()
    if self.goods_vo then 
        BackpackController:getInstance():sender10522(BackPackConst.Bag_Code.PETBACKPACK, {{id=self.goods_vo.id, bid=self.goods_vo.base_id,num=self.cur_count}})
    end
    self:onClosedBtn()
end


function HomePetItemSellPanel:openRootWnd(setting)
    local setting = setting or {}
    self.goods_vo = setting.goods_vo
    if not self.goods_vo then return end
    if not self.goods_vo.config then return end
    self.max_count = setting.max_count or 0
    self.cur_count = 1
    if self.max_count <= 0 then
        self.cur_count = 0
    end

    self.item:setData(self.goods_vo)
    self.item:setGoodsName(self.goods_vo.config.name, nil, 24, cc.c4b(0x95,0x53,0x22,0xff))

    if next(self.goods_vo.config.value) ~= nil then
        local item_config = Config.ItemData.data_get_data(self.goods_vo.config.value[1][1])
        local icon_src = PathTool.getItemRes(item_config.icon)
        loadSpriteTexture(self.item_icon, icon_src, LOADTEXT_TYPE)
    end

    self:updateLabelNum(self.cur_count)
end


function HomePetItemSellPanel:close_callback()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end

    controller:openHomePetItemSellPanel(false)
end
