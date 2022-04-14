--图鉴背包界面
illustrationBagPanel = illustrationBagPanel or class("illustrationBagPanel",WindowPanel)

function illustrationBagPanel:ctor(parent_node)
    self.abName = "illustration"
    self.assetName = "illustrationBagPanel"
    self.layer = "UI"

    self.panel_type = 5
    self.use_background = true  
    self.is_click_bg_close = true

    self.ill_model = illustrationModel.GetInstance()
    self.ill_model_events = {}
    self.bag_model = BagModel.GetInstance()
    self.bag_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.items = {}  --背包物品UI
    self.item_datas = {}  --背包物品数据

    self.v_scroll_view = nil --虚拟列表

    --drop down value到color num的映射
    self.value_color_map = {  
        [0] = -1,
        [1] =  3,
        [2] =  4,
        [3] =  5,
        [4] =  6,
        [5] =  7,
    }

    self.stencil_id = 12
end

function illustrationBagPanel:dctor()
    if table.nums(self.ill_model_events) > 0 then
        self.ill_model:RemoveTabListener(self.ill_model_events)
        self.ill_model_events = nil
    end
    if table.nums(self.bag_model_events) > 0 then
        self.bag_model:RemoveTabListener(self.bag_model_events)
        self.bag_model_events = nil
    end
    if table.nums(self.items) > 0 then
      for k,v in pairs(self.items) do
          v:destroy()
      end
      self.items = nil
    end
    if self.v_scroll_view then
        self.v_scroll_view:destroy()
        self.v_scroll_view = nil
    end
    
end

function illustrationBagPanel:LoadCallBack(  )
    self.nodes = {
        "scroll_view","scroll_view/view_port/content","drop_down",
    }

    self:GetChildren(self.nodes)

    --默认显示全部品阶的
    self.item_datas = self.ill_model:GetTargetColorItem(-1)

	self:InitUI()
    self:AddEvent()
    
    self.need_update_view = true
    if self.need_update_view then
       self:UpdateView()
    end

    self:SetTileTextImage("illustration_image","title_ill_bag",false)
    BagController.GetInstance():RequestBagInfo(BagModel.illustration)
end

function illustrationBagPanel:InitUI(  )
    self.drop_down = GetDropDown(self.drop_down)

    --选中品质颜色
    local function call_back(go, value)
       --logError("选中了".. value)
        local color_num = self.value_color_map[value]
        self.item_datas = self.ill_model:GetTargetColorItem(color_num)
        self.v_scroll_view:ForceUpdate()
    end
    AddValueChange(self.drop_down.gameObject, call_back)
end

function illustrationBagPanel:AddEvent(  )
    --图鉴背包信息刷新
    local function call_back()
        self.item_datas = self.ill_model:GetTargetColorItem(-1)
        if self.v_scroll_view then
            self.v_scroll_view:ForceUpdate()
        end
    end
    self.bag_model_events[#self.bag_model_events+1] = self.bag_model:AddListener(illustrationEvent.LoadillustrationItems, call_back)
   

end

--data
function illustrationBagPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function illustrationBagPanel:UpdateView()
    self.need_update_view = false

    self:UpdateBag()
end

function illustrationBagPanel:UpdateBag()
    if not self.v_scroll_view then
        local count = Config.db_bag[107].open
        self:CreateItems(count)
    else
        for i=1, #self.items do
            self:UpdateCellCB(self.items[i])
        end
    end
end

function illustrationBagPanel:CreateItems(cellCount)
    local param = {}
    local cellSize = {width = 70,height = 70}
    param["scrollViewTra"] = self.scroll_view
    param["cellParent"] = self.content
    param["cellSize"] = cellSize
    param["cellClass"] = BagItemSettor
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 17
    param["spanY"] = 12.25
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = cellCount
    self.v_scroll_view = ScrollViewUtil.CreateItems(param)
end

function illustrationBagPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS, true)
end

function illustrationBagPanel:UpdateCellCB(itemCLS)
    itemCLS.bag = BagModel.illustration
    itemCLS.need_deal_quick_double_click = false
    if self.item_datas ~=nil then
        local itemBase =  self.item_datas[itemCLS.__item_index]
        if itemBase ~= nil and itemBase ~= 0 then
            local configItem = Config.db_item[itemBase.id]
            if configItem ~= nil then --配置表存该物品
                --type,uid,id,num,bag,bind,outTime
                local param = {}
                param["type"] = configItem.type
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = itemBase.bag
                param["bind"] = false
                param["itemSize"] = {x=80, y=80}
                param["outTime"] = itemBase.etime
                param["get_item_cb"] = handler(self,self.GettemDataByIndex)
                param["quick_double_click_call_back"] = nil
                param["model"] =  BagModel.GetInstance()
                param["itemIndex"] = itemCLS.__item_index
                param["stencil_id"] = self.stencil_id

                itemCLS:UpdateItem(param)
            end

        else
            local param = {}
            param["bag"] = BagModel.illustration
            param["get_item_cb"] = handler(self,self.GettemDataByIndex)
            param["quick_double_click_call_back"] = nil
            param["model"] =  BagModel.GetInstance()
            param["stencil_id"] = self.stencil_id
            param["itemSize"] = {x=80, y=80}
            param["bind"] = false
            itemCLS:InitItem(param)
        end
    else
        local param = {}

        param["bag"] =BagModel.illustration
        param["get_item_cb"] = handler(self,self.GettemDataByIndex)
        param["quick_double_click_call_back"] = nil
        param["model"] =  BagModel.GetInstance()
        param["stencil_id"] = self.stencil_id
        param["itemSize"] = {x=80, y=80}
        param["bind"] = false
        itemCLS:InitItem(param)
    end

    self.items[itemCLS.__item_index] = itemCLS
    --itemCLS:SetCellIsLock(BagModel.illustration)

end

function illustrationBagPanel:GettemDataByIndex(index)
    return self.item_datas[index]
end