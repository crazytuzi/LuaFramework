UpShelfThreePanel = UpShelfThreePanel or class("UpShelfThreePanel", WindowPanel)
local UpShelfThreePanel = UpShelfThreePanel

function UpShelfThreePanel:ctor()
    self.abName = "market";
    self.assetName = "UpShelfThreePanel"
    self.layer = "UI"
    self.model = MarketModel:GetInstance()
    self.panel_type = 4                            --窗体样式  1 1280*720  2 850*545
    self.Events = {} --事件
    self.roleItems = {}
    self.roleList = FriendModel:GetInstance():GetFriendList()
    self.is_hide_other_panel = true
end

function UpShelfThreePanel:dctor()
    GlobalEvent:RemoveTabListener(self.Events)
    for i, v in pairs(self.roleItems) do
        v:destroy()
        v = nil
    end
    self.roleItems = {}
end
function UpShelfThreePanel:Open()
    UpShelfThreePanel.super.Open(self)
end

function UpShelfThreePanel:LoadCallBack()

    self.nodes = {
        "UpShelfThreeItem",
        "itemScrollView/Viewport/itemContent",
        "okBtn",
        "NoFriend",

    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)

    self:InitUI()
    self:AddEvent()
    --ShaderManager.GetInstance():SetImageGray(self.img)
    self:SetTileTextImage("market_image", "market_title_3");
end

function UpShelfThreePanel:InitUI()
    dump(self.roleList)

    if table.nums(self.roleList) ~= 0 then
        for i, v in pairs(self.roleList) do
            self.roleItems[i] = UpShelfThreeItem(self.UpShelfThreeItem.gameObject, self.itemContent, "UI")
            self.roleItems[i]:SetData(i)
        end
    else
        SetVisible(self.NoFriend, true)
    end

end

function UpShelfThreePanel:AddEvent()

    function call_back()
        if self.roleID == nil then
            self:Close()
            return
        end
        GlobalEvent:Brocast(MarketEvent.UpShelfMarketClickSelectRole, self.roleID)
        self:Close()
    end
    AddButtonEvent(self.okBtn.gameObject, call_back)
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketClickRole, handler(self, self.UpShelfMarketClickRole))
end

function UpShelfThreePanel:UpShelfMarketClickRole(data)
    self.roleID = data
    for i, v in pairs(self.roleItems) do
        if data == i then
            v:SetSelect(true)
        else
            v:SetSelect(false)
        end
    end
end