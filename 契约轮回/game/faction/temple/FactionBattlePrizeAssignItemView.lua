---
--- Created by R2D2.
--- DateTime: 2019/2/21 16:02
---
FactionBattlePrizeAssignItemView = FactionBattlePrizeAssignItemView or class("FactionBattlePrizeAssignItemView", Node)
local this = FactionBattlePrizeAssignItemView

function FactionBattlePrizeAssignItemView:ctor(obj, tab)
    self.transform = obj.transform
    self.data = tab

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI();
    self:AddEvent();
end

function FactionBattlePrizeAssignItemView:dctor()

end

function FactionBattlePrizeAssignItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Check", "Name", "Job", "Lv", "Vip", "Mask/HeadImage", }
    self:GetChildren(self.nodes)

    self.headImg = GetImage(self.HeadImage)
    self.checkBox = GetToggle(self.Check)
    self.nameText = GetText(self.Name)
    self.jobText = GetText(self.Job)
    self.lvText = GetText(self.Lv)
    self.vipText = GetText(self.Vip)

    self:RefreshView()
end

function FactionBattlePrizeAssignItemView:SetCallBack(group, callback)
    self.checkBox.group = group
    self.CheckCallBack = callback
end

function FactionBattlePrizeAssignItemView:AddEvent()
    local function toggle_callback()
        if (self.CheckCallBack and self.checkBox.isOn) then
            self.CheckCallBack(self.data)
        end
    end
    AddValueChange(self.checkBox.gameObject, toggle_callback)
end

function FactionBattlePrizeAssignItemView:RefreshView()
    if (self.data == nil) then
        return
    end

    lua_resMgr:SetImageTexture(self, self.headImg, "main_image",
            "img_role_head_" .. self.data.base.career, true)
    self.nameText.text = self.data.base.name
    self.jobText.text = tostring(self.data.post)
    self.lvText.text = tostring(self.data.base.level)
    self.vipText.text = "V" .. self.data.base.viplv
end
