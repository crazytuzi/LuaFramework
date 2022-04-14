---
--- Created by  Administrator
--- DateTime: 2020/6/28 17:10
---
ArtifactUpGradeAttrItem = ArtifactUpGradeAttrItem or class("ArtifactUpGradeAttrItem", BaseCloneItem)
local this = ArtifactUpGradeAttrItem

function ArtifactUpGradeAttrItem:ctor(obj, parent_node, parent_panel)
    ArtifactUpGradeAttrItem.super.Load(self)
    self.events = {}
end

function ArtifactUpGradeAttrItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ArtifactUpGradeAttrItem:LoadCallBack()
    self.nodes = {
        "attrvalue","attrName",
    }
    self:GetChildren(self.nodes)
    self.attrName = GetText(self.attrName)
    self.attrvalue = GetText(self.attrvalue)
    self:InitUI()
    self:AddEvent()
end

function ArtifactUpGradeAttrItem:InitUI()

end

function ArtifactUpGradeAttrItem:AddEvent()

end

function ArtifactUpGradeAttrItem:SetData(data,nextData)
    self.data = data
    self.nextData = nextData
    self.attrName.text = PROP_ENUM[self.data[1]].label.."："
    local value = self.nextData[2] - self.data[2]
   -- logError(self.data[2],value)
    --32488 +<color=#62e23a>2345</color>
    if self.data[1] >= 13 then
        self.attrvalue.text = string.format("%s<color=#62e23a>+%s</color>",GetPreciseDecimal(tonumber(self.data[2]) / 100, 2) .. "%",GetPreciseDecimal(tonumber(value) / 100, 2) .. "%")
    else
        self.attrvalue.text = string.format("%s<color=#62e23a>+%s</color>",self.data[2],value)
    end


end