---
--- Created by  Administrator
--- DateTime: 2019/3/11 15:46
---
SevenDayLittleItem = SevenDayLittleItem or class("SevenDayLittleItem", BaseCloneItem)
local this = SevenDayLittleItem

function SevenDayLittleItem:ctor(obj, parent_node, parent_panel)
    self.events = {}
    self.model = SevenDayModel:GetInstance()
    SevenDayLittleItem.super.Load(self)
end

function SevenDayLittleItem:dctor()
    self.model:RemoveTabListener(self.events)
    if self.monster then
        self.monster:destroy();
    end


    if self.ylqRedPoint then
        self.ylqRedPoint:destroy()
        self.ylqRedPoint = nil
    end
end

function SevenDayLittleItem:LoadCallBack()
    self.nodes = {
        "bg","select","dayTex","ylq","des","modelCon","showImg"
    }
    self:GetChildren(self.nodes)
    SetVisible(self.ylq,false)
    self.dayTex = GetText(self.dayTex)
    self.des = GetText(self.des)
    self.showImg = GetImage(self.showImg)
    self.bg = GetImage(self.bg)

    self.ylqRedPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.ylqRedPoint:SetPosition(87, 85)


    self:AddEvent()
    self:InitUI()


end

function SevenDayLittleItem:InitUI()

end

function SevenDayLittleItem:AddEvent()
    local function call_back()
        self.model:Brocast(SevenDayEvent.SevenDayItemClick,self.index)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function SevenDayLittleItem:SetData(data,pageIndex)
    self.index = pageIndex
    self.data = data
    local db = Config.db_yylogin[self.index]
    if not db then
        return
    end
    self.dayTex.text = db.name
    self.des.text = db.des
    self:InitTexture(db.itemtex)
end



function SevenDayLittleItem:InitTexture(name)
    lua_resMgr:SetImageTexture(self,self.showImg,"iconasset/icon_sevenday",name, false)
end
function SevenDayLittleItem:UpdateInfo()
    SetVisible(self.ylq,self.model:IsGetReward(self.index))
    if not self.model:IsGetReward(self.index) and self.index <= self.model.dayNums  then
        self.ylqRedPoint:SetRedDotParam(true)
    else
        self.ylqRedPoint:SetRedDotParam(false)
    end

    --if self.model:IsGetReward(self.index) then
    --    ShaderManager:GetInstance():SetImageGray(self.bg)
    --end
end

function SevenDayLittleItem:Select(show)
    SetVisible(self.select,show)
end