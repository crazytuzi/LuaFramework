
CandyTaskItem = CandyTaskItem or class("CandyTaskItem", BaseItem)
local CandyTaskItem = CandyTaskItem

function CandyTaskItem:ctor(parent_node, layer)
    self.abName = "candy"
    self.assetName = "CandyTaskItem"
    self.layer = layer

    self.config  = nil
    
    self.model= CandyModel:GetInstance()
    self.reward_item_list = {}

    CandyTaskItem.super.Load(self)
end

function CandyTaskItem:dctor()
  
end

function CandyTaskItem:LoadCallBack()
    self.nodes = {
       "img_bg","img_sel","task_name","reward_content","text_state",
    }
    self:GetChildren(self.nodes)

  
    self.task_name = GetText(self.task_name)
    self.text_state = GetText(self.text_state)
   
    SetVisible(self.img_sel,false)
    
    self:AddEvent()
    self:UpdateView()
end

function CandyTaskItem:AddEvent()

   --选中任务项高亮
   local function call_back(target, x, y)
    self:OnClick()
    end
    AddClickEvent(self.img_bg.gameObject, call_back)

end

function CandyTaskItem:UpdateView()
    local time = self.config.time
    self.task_name.text = "Send"..time.."Gift, reward:"

    --判断是否为跨服活动
    local str = self.config.reward
    if self.model:IsCross() then
        str = self.config.cross_reward
    end
    local reward_tbl = String2Table(str)

   --[[  for i = 1, #reward_tbl do
        local param = {}
        local operate_param = {}
        local item_id = reward_tbl[i][1]
        param["item_id"] = item_id
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 50, y = 50 }
        local final_num = reward_tbl[i][2]
        if item_id == enum.ITEM.ITEM_PLAYER_EXP or item_id == enum.ITEM.ITEM_WORLDLV_EXP then
            final_num = GetProcessedExpNum(item_id, final_num)
        end
        param["num"] = final_num
        local itemIcon = GoodsIconSettorTwo(self.reward_content)
        itemIcon:SetIcon(param)
        self.reward_item_list[#self.reward_item_list + 1] = itemIcon
    end ]]
    local param = {}
    local operate_param = {}
    local item_id = reward_tbl[1]
    param["item_id"] = item_id
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 50, y = 50 }
    local final_num = reward_tbl[2]
    if item_id == enum.ITEM.ITEM_PLAYER_EXP or item_id == enum.ITEM.ITEM_WORLDLV_EXP then
        final_num = GetProcessedExpNum(item_id, final_num)
    end
    param["num"] = final_num
    local itemIcon = GoodsIconSettorTwo(self.reward_content)
    itemIcon:SetIcon(param)
    self.reward_item_list[#self.reward_item_list + 1] = itemIcon
end

function CandyTaskItem:SetData(config)
    self.config = config
end

function CandyTaskItem:OnClick()

    if self.model.curSelectTaskItem then

        if self.model.curSelectTaskItem == self then
            return
        end

        SetVisible(self.model.curSelectTaskItem.img_sel,false)
    end

    self.model.curSelectTaskItem = self
    SetVisible(self.img_sel,true)


end






