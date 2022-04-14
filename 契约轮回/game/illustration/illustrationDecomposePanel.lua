--图鉴分解界面
illustrationDecomposePanel= illustrationDecomposePanel or class("illustrationDecomposePanel",WindowPanel)

function illustrationDecomposePanel:ctor(parent_node)
    self.abName = "illustration"
    self.assetName = "illustrationDecomposePanel"
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
    self.item_uids = {}  --要分解的UID列表
    self.count = 0

    self.v_scroll_view = nil --虚拟列表


    self.stencil_id = 12

--[[     local essence = Config.db_illustration_star[1].essence
    essence = String2Table(essence)
    self.icon_id = essence[1][1]
    self:SetTileTextImage("illustration_image","title_ill_decompose",false) ]]

    BagController.GetInstance():RequestBagInfo(BagModel.illustration)
end

function illustrationDecomposePanel:dctor()
    if table.nums(self.ill_model_events) > 0 then
        self.ill_model:RemoveTabListener(self.ill_model_events)
        self.ill_model_events = nil
    end
    if table.nums(self.bag_model_events) > 0 then
        self.bag_model:RemoveTabListener(self.bag_model_events)
        self.bag_model_events = nil
    end
    if self.v_scroll_view then
        self.v_scroll_view:destroy()
        self.v_scroll_view = nil
    end
end

function illustrationDecomposePanel:LoadCallBack(  )
    self.nodes = {
        "scroll_view/view_port/content","txt_count","img_icon","scroll_view","btn_decompose",
    }

    self:GetChildren(self.nodes)

    --显示满星图鉴升级物品
    self.item_datas = self.ill_model:GetMaxStarUpIll()

	self:InitUI()
    self:AddEvent()
    
    self.need_update_view = true
    if self.need_update_view then
       self:UpdateView()
    end

    self:SetTileTextImage("illustration_image","title_ill_decompose",false)
end

function illustrationDecomposePanel:InitUI(  )
   self.txt_count = GetText(self.txt_count)
   self.img_icon = GetImage(self.img_icon)
end

function illustrationDecomposePanel:AddEvent(  )
    
    --图鉴分解完毕
    local function call_back(p_item_base)
        self.item_uids = {}
        self.count = 0
        self:UpdateCount()
    end
    self.ill_model_events[#self.ill_model_events + 1 ] = self.ill_model:AddListener(illustrationEvent.DecomposeComplete,call_back)

    --点击图鉴物品
    local function call_back(p_item_base)
        self:SelectItem(p_item_base)
    end
   self.bag_model_events[#self.bag_model_events+1] = self.bag_model:AddListener(BagEvent.SmeltItemClick, call_back)


   --图鉴背包信息刷新
   local function call_back()
        --强制刷新下当前图鉴物品列表
        self.item_datas = self.ill_model:GetMaxStarUpIll()
        if self.v_scroll_view then
            self.v_scroll_view:ForceUpdate()
        end
   end
   self.bag_model_events[#self.bag_model_events+1] = self.bag_model:AddListener(illustrationEvent.LoadillustrationItems, call_back)

    --分解按钮
    local function call_back()

        if table.nums(self.item_uids) == 0 then
            Notify.ShowText("Please select the atlas you want to dismantle")
            return
        end

        illustrationController.GetInstance():RequestDecompose(self.item_uids)
        
    end
    AddClickEvent(self.btn_decompose.gameObject,call_back)

end

--data
function illustrationDecomposePanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function illustrationDecomposePanel:UpdateView()
    self.need_update_view = false

    self:UpdateBag()
    self:SelectMaxStarUpIll()
    self:UpdateCount()
end

--刷新分解物品背包
function illustrationDecomposePanel:UpdateBag()
    if not self.v_scroll_view then
        local count = Config.db_bag[107].open
        self:CreateItems(count)
    else
        for i=1, #self.items do
            self:UpdateCellCB(self.items[i])
        end
    end
end


--默认选中已满星图鉴的升级材料
function illustrationDecomposePanel:SelectMaxStarUpIll()
    --[[ local max_star_up_ill = self.ill_model:GetMaxStarUpIll()

    if table.nums(max_star_up_ill) == 0 then
        return
    end

    for k,v in pairs(self.items) do
        if max_star_up_ill[v.data.id] then
            --选中
            v:Select(true)
            self:SelectItem(v.data)
        end
    end ]]
    for k,v in pairs(self.items) do
        --选中
         v:Select(true)
         self:SelectItem(v.data)
    end 

end

function illustrationDecomposePanel:CreateItems(cellCount)
    local param = {}
    local cellSize = {width = 70,height = 70}
    param["scrollViewTra"] = self.scroll_view
    param["cellParent"] = self.content
    param["cellSize"] = cellSize
    param["cellClass"] = BagSmeltItem
    param["begPos"] = Vector2(40,-40)
    param["spanX"] = 17
    param["spanY"] = 12.25
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = cellCount
    self.v_scroll_view = ScrollViewUtil.CreateItems(param)
end

function illustrationDecomposePanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS, true)
end

function illustrationDecomposePanel:UpdateCellCB(itemCLS)
    local index = itemCLS.__item_index
    local item = self.item_datas[index]
    itemCLS:SetData(item, self:IsSelect(item), self.stencil_id)
    if item then
        self.items[index] = itemCLS
    end


end

function illustrationDecomposePanel:GetItemDataByIndex(index)
    return self.item_datas[index]
end

--图鉴是否选中
function illustrationDecomposePanel:IsSelect(p_item_base)
    if not p_item_base then
        return false
    end
    return self.item_uids[p_item_base.uid]
end

--选中要分解的图鉴
function illustrationDecomposePanel:SelectItem(p_item_base)
    local cellid = p_item_base.uid
    
    local item_cfg = Config.db_item[p_item_base.id]
    local count = item_cfg.effect
    local num = p_item_base.num
    count = tonumber(count) * num

    if self.item_uids[cellid] then
        self.item_uids[cellid] = nil
        --logError("取消选中"..cellid)

        self.count = self.count - count
        if self.count < 0 then
            self.count = 0
        end
    else
        self.item_uids[cellid] = true
        --logError("选中"..cellid)
        self.count = self.count + count
    end
    
    self:UpdateCount()
end

--更新分解可获得物品数量
function illustrationDecomposePanel:UpdateCount(  )
    self.txt_count.text = self.count
end