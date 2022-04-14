---
--- Created by  Administrator
--- DateTime: 2019/9/24 14:21
---
StigmasItem = StigmasItem or class("StigmasItem", BaseItem)
local this = StigmasItem

function StigmasItem:ctor(parent_node, layer)
    self.abName = "stigmas"
    self.assetName = "StigmasItem"
    self.layer = layer
    self.events = {}
    self.model = StigmasModel:GetInstance()
    StigmasItem.super.Load(self)
end

function StigmasItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)

    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function StigmasItem:LoadCallBack()
    self.nodes = {
        "select/head","name","unSelect","select","bg","selectImg","select/attrImg"
    }
    self:GetChildren(self.nodes)
    self.head = GetImage(self.head)
    self.name = GetText(self.name)
    self.attrImg = GetImage(self.attrImg)

    self.red = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.red:SetPosition(-62, 36)

    self:InitUI()
    self:AddEvent()
    if  self.is_need_setData  then
        self:SetData(self.index,self.type)
    end
    if self.is_need_setShow then
        self:SetSelect(self.isShow)
    end

end

function StigmasItem:InitUI()

end

function StigmasItem:AddEvent()

    local function call_back()
        if self.type == 1 then
            self.model:Brocast(StigmasEvent.StigmasItemClick1,self.index)
        else
            self.model:Brocast(StigmasEvent.StigmasItemClick2,self.index)
        end
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function StigmasItem:SetData(data,type)
    self.index = data
    self.type = type
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self:UpdateInfo()
end

function StigmasItem:UpdateInfo()
    local godId = self.model:GetSlotByIndex(self.index)
    local isRed = self.model:CheckHaveBetterGodByPos(self.index)
    self.red:SetRedDotParam(isRed)
    if godId == 0 then  --没有布置
        SetVisible(self.unSelect,true)
        SetVisible(self.select,false)
        self.name.text = "None"
        return
    end
    self.name.text = Config.db_dunge_soul_morph[godId].name
    SetVisible(self.unSelect,false)
    SetVisible(self.select,true)
    lua_resMgr:SetImageTexture(self, self.head, "iconasset/icon_god", godId, true)
    lua_resMgr:SetImageTexture(self, self.attrImg, "iconasset/icon_god", "attr_"..godId, true)
end

function StigmasItem:SetSelect(isShow)
    self.isShow = isShow
    if not self.is_loaded then
        self.is_need_setShow = true
        return
    end
    SetVisible(self.selectImg,isShow)
end

