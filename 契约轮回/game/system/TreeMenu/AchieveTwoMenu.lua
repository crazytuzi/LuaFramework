AchieveTwoMenu = AchieveTwoMenu or class("AchieveTwoMenu",BaseTreeTwoMenu)
local AchieveTwoMenu = AchieveTwoMenu

function AchieveTwoMenu:ctor(parent_node,layer,first_menu_item)
    self.abName = "system"
    self.assetName = "AchieveTwoMenu"
    --self.layer = layer

    --self.layer = layer
    --self.first_menu_item = first_menu_item
    --self.parent_cls_name = self.first_menu_item.parent_cls_name
    --self.model = 2222222222222end:GetInstance()
    self.index = 1
    AchieveTwoMenu.super.Load(self)
end

function AchieveTwoMenu:dctor()
   -- AchieveTwoMenu.super.dctor(self)
    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end
end

function AchieveTwoMenu:LoadCallBack()
    self.nodes = {
        "arror","redParent"
    }
    self:GetChildren(self.nodes)
    AchieveTwoMenu.super.LoadCallBack(self)
    self.redPoint = RedDot(self.redParent, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(96, 22)

end
--
function AchieveTwoMenu:AddEvent()
    AchieveTwoMenu.super.AddEvent(self)

    self.globalEvents[#self.globalEvents+1] =  GlobalEvent:AddListener(AchieveEvent.AchieveReward,handler(self,self.AchieveInfo))
end
--
function AchieveTwoMenu:SetData(first_menu_id,data, select_sub_id,menuSpan, index)
    AchieveTwoMenu.super.SetData(self,first_menu_id,data, select_sub_id,menuSpan)
    self.group = first_menu_id
    self.page = data[1]
    self.index = index
    self:UpdateText(first_menu_id,data[1])
    if self.data.isRed ~= nil then
        self:SetRedDot(self.data.isRed)
    end
end


function AchieveTwoMenu:UpdateText(group,page)
    local curNum = AchieveModel:GetInstance():GetTypeReceiveNums(group,page)
    local allNum = AchieveModel:GetInstance():GetTypeNums(group,page)
    if self.Text then
       -- self.Text:GetComponent('Text').text = self.data[2]
        self.Text:GetComponent('Text').text = string.format("%s(%s/%s)",self.data[2],curNum,allNum)
    end
end

function AchieveTwoMenu:AchieveInfo(id)
    local cfg = Config.db_achieve[id]
    if cfg.group == self.group and cfg.page == self.page then
        self:UpdateText(cfg.group,cfg.page)
        if self.data.isRed ~= nil then
            self:SetRedDot(self.data.isRed)
        end
    end
end


function AchieveTwoMenu:SetRedDot(isShow)
    self.redPoint:SetRedDotParam(isShow)
end


