--右侧有组合的图鉴界面
illustrationRightComposePanel = illustrationRightComposePanel or class("illustrationRightComposePanel",BaseItem)

function illustrationRightComposePanel:ctor(parent_node)
    self.abName = "illustration"
    self.assetName = "illustrationRightComposePanel"
    self.layer = "UI"

    self.ill_model = illustrationModel.GetInstance()
    self.ill_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    
    self.ill_compose_items = {}  --图鉴组合项

    BaseItem.Load(self)
end

function illustrationRightComposePanel:dctor()
    if table.nums(self.ill_model_events) > 0 then
        self.ill_model:RemoveTabListener(self.ill_model_events)
        self.ill_model_events = nil
    end

    if table.nums(self.ill_compose_items) > 0 then
        for k,v in pairs(self.ill_compose_items) do
            v:destroy()
        end
        self.ill_compose_items = nil
    end
end

function illustrationRightComposePanel:LoadCallBack(  )
    self.nodes = {
        "mid_scroll_view/view_port/mid_content",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function illustrationRightComposePanel:InitUI(  )
    
end

function illustrationRightComposePanel:AddEvent(  )
    
end

--data
--com_ids 组合表
function illustrationRightComposePanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function illustrationRightComposePanel:UpdateView()
    for i,v in ipairs(self.data.com_ids) do
        local item = self.ill_compose_items[i] or illustrationComposeItem(self.mid_content)
        self.ill_compose_items[i] = item

        local com_cfg = Config.db_illustration_combination[v]
        local data = {}
        data.name = com_cfg.name
        data.ill_ids =String2Table(com_cfg.illustrations)
        data.props = String2Table(com_cfg.attr)
        
        item:SetData(data)
    end

     --多出来的图鉴组合项UI隐藏掉
     local max_num = table.nums(self.data.com_ids)
     for i,v in ipairs(self.ill_compose_items) do
         SetVisible(v.transform,i <= max_num)
     end
end