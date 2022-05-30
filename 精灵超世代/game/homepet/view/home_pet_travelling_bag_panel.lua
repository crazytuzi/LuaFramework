--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年6月5日
-- @description    : 
        -- 萌宠行囊功能
---------------------------------
HomePetTravellingBagPanel = HomePetTravellingBagPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()
local model = controller:getModel()
--背包
local backpack_model = BackpackController:getInstance():getModel()

local table_insert = table.insert

function HomePetTravellingBagPanel:__init(show_type)
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "homepet/home_pet_travelling_bag_panel"

    self.homepet_vo = model:getHomePetVo()
    self.show_type = show_type or 1
end

function HomePetTravellingBagPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("行囊"))
    self.look_btn = main_panel:getChildByName("look_btn")

    self.close_btn = main_panel:getChildByName("close_btn")
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("确 定"))

    self.main_container:getChildByName("label_1"):setString(TI18N("本次出行"))
    self.main_container:getChildByName("label_2"):setString(TI18N("下次出行"))
    self.main_container:getChildByName("label_3"):setString(TI18N("食物"))
    self.main_container:getChildByName("label_4"):setString(TI18N("食物"))
    self.main_container:getChildByName("label_5"):setString(TI18N("道具"))
    self.main_container:getChildByName("label_6"):setString(TI18N("道具"))
    self.tips = self.main_container:getChildByName("tips")
    self.tips:setString(TI18N("请携带食物，否则萌宠不会出行噢~"))

    --位置根据协议定的
    self.item_type_list = {
        [1] = BackPackConst.item_tab_type.HOMEPET_FOOD,
        [2] = BackPackConst.item_tab_type.HOMEPET_ITEM,
        [3] = BackPackConst.item_tab_type.HOMEPET_FOOD,
        [4] = BackPackConst.item_tab_type.HOMEPET_ITEM
    }
    self.item_list = {}
    for i=1,4 do
        local item_node = self.main_container:getChildByName("item_node_"..i)
        self.item_list[i] = BackPackItem.new(true,true,nil,1)
        self.item_list[i]:addCallBack(function() self:onClickItemIndex(i) end)
        item_node:addChild(self.item_list[i])
    end

    self.btn_goto = self.main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("label"):setString(TI18N("旅行中"))
end

function HomePetTravellingBagPanel:playEnterAnimatian()
    if not self.main_container then return end
    commonOpenActionLeftMove(self.main_container)


    if self.show_type and self.show_type == 1 then
        commonOpenActionCentreScale(self.main_container)
    else
        commonOpenActionRightMove(self.main_container)
    end
end

function HomePetTravellingBagPanel:register_event(  )
    -- registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, 1)
    registerButtonEventListener(self.btn_goto, function() self:onGotoBtn()  end ,true, 1)

    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config = Config.HomePetData.data_const.travelling_bag_tips
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,true, 1)

    self:addGlobalEvent(HomepetEvent.HOME_PET_TRAVELLING_BAG_UPDATE_EVENT, function()
        -- self:updateItemList()
        self:onClosedBtn()
    end)
    
    self:addGlobalEvent(HomepetEvent.HOME_PET_SELECT_ITEM_CALLBACK_EVENT, function(select_key, item_id)
        if not select_key then return end
        if not self.homepet_vo then return end
        -- item_id == nil 表示取消
        self.dic_set_item_id[select_key] = item_id
        self:updateItemList()
    end)
end

function HomePetTravellingBagPanel:onClosedBtn()
    controller:openHomePetTravellingBagPanel(false) 
end

function HomePetTravellingBagPanel:onGotoBtn()
    --跳转旅行中
    if self.is_goto then
        -- doStopAllActions(self.main_container)
        -- local y = self.main_container:getPositionY()

        -- local moveto = cc.EaseBackOut:create(cc.MoveTo:create(0.3, cc.p(720, y))) 
        -- local fadeOut = cc.FadeOut:create(0.25)
        -- local spawn_action = cc.Spawn:create(moveto, fadeOut)
        -- local callback = function()
            self:onClosedBtn()
        -- end
        -- self.main_container:runAction(cc.Sequence:create(spawn_action, cc.CallFunc:create(callback)))

        controller:openHomePetGooutProgressPanel(true, {show_type = 2})
    end
end

--确定
function HomePetTravellingBagPanel:onComfirmBtn()
    if not self.homepet_vo then return end
    if not self.dic_set_item_id then return end

    local set_item = {}
    for k,id in pairs(self.dic_set_item_id) do
        table_insert(set_item, {key = k, id = id})
    end
    controller:sender26107(set_item)
end

--点击item
function HomePetTravellingBagPanel:onClickItemIndex(index)
    if not self.item_type_list then return end
    if not self.homepet_vo then return end
    if (index == 1 or index == 2) and self.homepet_vo:getPetState() ~= HomepetConst.state_type.eHome then
        message(TI18N("萌宠已出行"))
        return
    end

    local setting = {}
    setting.select_key = index

    --计算另外一个索引
    local other_index = 0
    for i,v in ipairs(self.item_type_list) do
        if v == self.item_type_list[index] then
            if i ~= index then
                other_index = i
            end
        end
    end
    setting.select_item_id = self.dic_set_item_id[index]
    setting.other_item_id = self.dic_set_item_id[other_index]

    if self.item_type_list[index] == BackPackConst.item_tab_type.HOMEPET_FOOD then
        setting.index = HomepetConst.Item_bag_tab_type.eFoodType
        setting.show_type = HomepetConst.Item_bag_show_type.eSelectFoodType
    else
        setting.index = HomepetConst.Item_bag_tab_type.eItemType
        setting.show_type = HomepetConst.Item_bag_show_type.eSelectItemType
    end
    controller:openHomePetItemBagPanel(true, setting)
end


function HomePetTravellingBagPanel:openRootWnd(setting)
    local setting = setting or {}
    self.is_goto = setting.is_goto or false
    if self.btn_goto then
        self.btn_goto:setVisible(self.is_goto)
    end
    local homepet_vo = model:getHomePetVo()
    self.dic_set_item_id =  deepCopy(homepet_vo:getSetItemInfo())
    if self.dic_set_item_id[1] ~= nil or self.dic_set_item_id[3] ~= nil then
        self.tips:setVisible(false)
    end
    self:updateItemList()

    if self.is_goto and self.item_list then
        setChildUnEnabled(true, self.item_list[1])
        setChildUnEnabled(true, self.item_list[2])
    end
end

function HomePetTravellingBagPanel:updateItemList(dic_set_item_id)
    for key, item in ipairs(self.item_list) do
        local item_id = self.dic_set_item_id[key]
        if item_id then
            local item_data =backpack_model:getHomePetItemById(item_id)
            if item_data then
                item:setBaseData(item_data.base_id, 1)
                item:showAddIcon(false)
            else
                item:setBaseData(nil)
                item:showAddIcon(true)
            end
        else
            item:setBaseData(nil)
            item:showAddIcon(true)
        end
    end
end


function HomePetTravellingBagPanel:close_callback()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self.item_list = {}

    controller:openHomePetTravellingBagPanel(false)
end