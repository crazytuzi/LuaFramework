---
--- Created by  Administrator
--- DateTime: 2019/3/11 15:47
---
SevenDayBigItem = SevenDayBigItem or class("SevenDayBigItem", BaseCloneItem)
local this = SevenDayBigItem

function SevenDayBigItem:ctor(obj, parent_node, parent_panel)
    self.events = {}
    self.model = SevenDayModel:GetInstance()
    SevenDayBigItem.super.Load(self)
end

function SevenDayBigItem:dctor()
    self.model:RemoveTabListener(self.events)
    if self.ylqRedPoint then
        self.ylqRedPoint:destroy()
        self.ylqRedPoint = nil
    end
end

function SevenDayBigItem:LoadCallBack()
    self.nodes = {
        "bg","select","dayTex","ylq","des","showImg"
    }
    self:GetChildren(self.nodes)
    self.dayTex = GetText(self.dayTex)
    self.des = GetText(self.des)
    self.showImg = GetImage(self.showImg)
    self.ylqRedPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.ylqRedPoint:SetPosition(257, 85)

    self:InitUI()
    self:AddEvent()
end

function SevenDayBigItem:InitUI()

end


function SevenDayBigItem:AddEvent()
    local function call_back()
        self.model:Brocast(SevenDayEvent.SevenDayItemClick,self.index)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function SevenDayBigItem:SetData(data,pageIndex)
    self.data = data
    self.index = pageIndex
    local db = Config.db_yylogin[self.index]
    if not db then
        return
    end
    self.dayTex.text = db.name
    self.des.text = db.des
    self:InitTexture(db.itemtex)
  --  self:UpdateInfo()
end

function SevenDayBigItem:UpdateInfo()
    SetVisible(self.ylq,self.model:IsGetReward(self.index))
    if not self.model:IsGetReward(self.index) and self.index <= self.model.dayNums  then
        self.ylqRedPoint:SetRedDotParam(true)
    else
        self.ylqRedPoint:SetRedDotParam(false)
    end
    --if self.model.IsGetReward then
    --
    --end
end
function SevenDayBigItem:InitTexture(name)
    if self.index == 7 then
        SetLocalPosition(self.showImg.transform,111,10,0)
    elseif self.index == 14 then
        SetLocalPosition(self.showImg.transform,121,21,0)
    end
   --lua_resMgr:SetImageTexture(self,self.showImg,"sevenDay_image","yylogin_item"..self.index, false)
    lua_resMgr:SetImageTexture(self,self.showImg,"iconasset/icon_sevenday",name, false)
end

function SevenDayBigItem:Select(show)
    SetVisible(self.select,show)
end