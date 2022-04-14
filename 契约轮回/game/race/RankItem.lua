RankItem = RankItem or class("RankItem",BaseItem)

function RankItem:ctor(parent_node,layer,asset_name)
    self.abName = "Race"
    self.assetName = asset_name
    self.layer = layer


    self.race_model = RaceModel.GetInstance()
    self.race_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.role_icon_item = nil --角色头像UI项

    RankItem.super.Load(self)
end

function RankItem:dctor()
    if table.nums(self.race_model_events) > 0 then
        self.race_model:RemoveTabListener(self.race_model_events)
        self.race_model_events = nil
    end

    if self.role_icon_item then
        self.role_icon_item:destroy()
        self.role_icon_item = nil
    end
end

function RankItem:LoadCallBack(  )
    self.nodes = {
        "txt_name","role_icon","txt_rank",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function RankItem:InitUI(  )
    self.txt_name = GetText(self.txt_name)
    self.txt_rank = GetText(self.txt_rank)
end

function RankItem:AddEvent(  )
    
end

--data
--name 名字
--rank 排名
--role_data 角色数据
--role_icon_size 头像框大小
function RankItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function RankItem:UpdateView()
    self.need_update_view = false

    self.txt_name.text = self.data.name
    self.txt_rank.text = self.data.rank

    self.role_icon_item = RoleIcon(self.role_icon)
    local param = {}
    param.is_squared = true
    param.size = self.data.role_icon_size
    param.role_data = self.data.role_data

    self.role_icon_item:SetData(param)

    local rank = self.data.rank 
    self.data.rank = nil
    self:ChangeRank(rank)
end

--修改排名
function RankItem:ChangeRank(rank)
    if self.data.rank == rank then
        return
    end

    self.data.rank = rank
    self.txt_rank.text = self.data.rank
    self.transform:SetSiblingIndex(rank - 1)
end
