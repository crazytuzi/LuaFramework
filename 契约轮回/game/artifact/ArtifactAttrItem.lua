---
--- Created by  Administrator
--- DateTime: 2020/6/23 10:12
---
ArtifactAttrItem = ArtifactAttrItem or class("ArtifactAttrItem", BaseCloneItem)
local this = ArtifactAttrItem

function ArtifactAttrItem:ctor(obj, parent_node, parent_panel)
    ArtifactAttrItem.super.Load(self)
    self.events = {}
    self.model = ArtifactModel:GetInstance()
end

function ArtifactAttrItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ArtifactAttrItem:LoadCallBack()
    self.nodes = {
        "attrName","attrValue","lock","bValue"
    }
    self:GetChildren(self.nodes)
    self.attrName = GetText(self.attrName)
    self.attrValue = GetText(self.attrValue)

    if self.bValue then
        self.bValue = GetText(self.bValue)
        SetVisible(self.bValue,false)
    end

    SetVisible(self.lock,false)
    self:InitUI()
    self:AddEvent()
end

function ArtifactAttrItem:InitUI()

end

function ArtifactAttrItem:AddEvent()

end

function ArtifactAttrItem:SetData(name,value,index,artId)
    --self.data = data
   -- logError(name,value)
    if string.utf8len(PROP_ENUM[name].label) == 2 then
        --if space then
        --    self.attrName.text = table.concat(string.utf8list(PROP_ENUM[name].label), "      ") .. ":";
        --else
            self.attrName.text = table.concat(string.utf8list(PROP_ENUM[name].label), "      ") .. ":";
       -- end
    else
        self.attrName.text = PROP_ENUM[name].label .. ":";
    end
    if name >= 13 then
        self.attrValue.text = GetPreciseDecimal(tonumber(value) / 100, 2) .. "%";
    else
        self.attrValue.text = value
    end
    if index then
       -- logError(string.format("%s是否解锁:%s",index,self.model:IsLockEnchant(artId,index)))
        local lock = self.model:IsLockEnchant(artId,index)
        local index1Lock = self.model:IsLockEnchant(artId,1)
        if index1Lock then
            SetVisible(self.lock,not lock)
            if lock then
                self:SetColor(0,255,78)
                local num = math.floor(value/self.model:GetBaseAttr(artId,index)* 100)
               -- logError(num)
                --if num > 100 then
                --    num = 100
                --end
                self.bValue.text = "("..num.."%)"

                logError(num)
                SetVisible(self.bValue,true)
            else
                self:SetColor(255,0,42)
                SetVisible(self.bValue,false)
            end
        else
            self:SetColor(255,0,42)
            SetVisible(self.bValue,false)
            SetVisible(self.lock,true)
        end

    end
end

function ArtifactAttrItem:SetColor(r,g,b)
   -- if color then
        SetColor(self.attrName, r, g, b)
   -- end
end