---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 18/12/25 20:23
---
EmptyGirl = EmptyGirl or class("EmptyGirl", BaseItem)
local this = EmptyGirl

function EmptyGirl:ctor(parent_node, txt)
    self.abName = "system";
    self.image_ab = "system_image";
    self.assetName = "empty_girl";
    self.layer = "UI";
    self.txt = txt;
    self.events = {};
    self.schedules = {};
    EmptyGirl.super.Load(self);
end

function EmptyGirl:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    self:StopAllSchedules()
end

function EmptyGirl:LoadCallBack()
    self.nodes = {
        "dialog",
    }
    self:GetChildren(self.nodes)


    SetLocalPosition(self.transform, self.posx or 0, self.posy or 0, self.posz or 0)

    self:InitUI();

    self:AddEvent();
end

function EmptyGirl:InitUI()
    self.dialog = GetText(self.dialog);

    if self.txt then
        self.dialog.text = tostring(self.txt);
    end
end

function EmptyGirl:AddEvent()
    AddClickEvent(self.gameObject, handler(self, self.HandleClick));
end

--@ling autofun
function EmptyGirl:HandleClick(go, x, y)

end

function EmptyGirl:SetPos(x, y, z)
    if self.transform then
        SetLocalPosition(self.transform, x, y, z);
    else
        self.posx = x;
        self.posy = y;
        self.posz = z;
    end
end

function EmptyGirl:StopAllSchedules()
    for i = 1, #self.schedules, 1 do
        GlobalSchedule:Stop(self.schedules[i]);
    end
    self.schedules = {};
end