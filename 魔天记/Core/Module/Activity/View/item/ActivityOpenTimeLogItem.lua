require "Core.Module.Common.UIItem"

ActivityOpenTimeLogItem = class("ActivityOpenTimeLogItem", UIItem);



function ActivityOpenTimeLogItem:New()
    self = { };
    setmetatable(self, { __index = ActivityOpenTimeLogItem });
    return self
end


function ActivityOpenTimeLogItem:_Init()

    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");
    self.timeTxt = UIUtil.GetChildInComponents(txts, "timeTxt");

    self.dayActTxts = { };
    for i = 1, 7 do
        self.dayActTxts[i] = UIUtil.GetChildInComponents(txts, "dayTxt" .. i);
    end

    self.bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self.bg1 = UIUtil.GetChildByName(self.transform, "UISprite", "bg1");

    self:UpdateItem(self.data)
end



function ActivityOpenTimeLogItem:_Dispose()




end

-- {id=1,open_time=2,name1=3,name2=4,name3=5,name4=6,name5=7,name6=8,name7=9}
-- {1,'10:00','古魔来袭','古魔来袭','古魔来袭','古魔来袭','古魔来袭','古魔来袭','古魔来袭'},
function ActivityOpenTimeLogItem:UpdateItem(data)
    self.data = data
    if (self.data) then
        self.timeTxt.text = self.data.open_time;

        for i = 1, 7 do
            self.dayActTxts[i].text = self.data["name" .. i];
        end

        if self.data.changeBg then
            self.bg.gameObject:SetActive(true);
            self.bg1.gameObject:SetActive(false);
        else
            self.bg.gameObject:SetActive(false);
            self.bg1.gameObject:SetActive(true);

        end

    end
end
