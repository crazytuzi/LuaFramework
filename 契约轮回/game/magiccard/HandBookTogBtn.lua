HandBookTogBtn = HandBookTogBtn or class("HandBookTogBtn", Node)
local this = HandBookTogBtn

function HandBookTogBtn:ctor(obj)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.image_ab = "magiccard_image";
    self.transform_find = self.transform.Find;
    self.events = {};
    self:Init();
    self:AddEvents();
end

function HandBookTogBtn:Init()
    self.is_loaded = true;
    self.nodes = {
        "tog_1", "tog_2", "tog_1/Label1", "tog_2/Label",
    }
    self:GetChildren(self.nodes);

    self:InitUI();
end

function HandBookTogBtn:InitUI()
    self.Label1 = GetText(self.Label1);
    self.Label = GetText(self.Label);
end

function HandBookTogBtn:SetSelected(bool)
    bool = toBool(bool);
    SetGameObjectActive(self.tog_1.gameObject, not bool);
    SetGameObjectActive(self.tog_2.gameObject, bool);
end

function HandBookTogBtn:SetTxt(str)
    self.Label.text = str;
    self.Label1.text = str;
end

function HandBookTogBtn:AddEvents()

end

function HandBookTogBtn:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
end
