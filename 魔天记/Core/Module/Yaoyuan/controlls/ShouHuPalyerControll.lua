

ShouHuPalyerControll = class("ShouHuPalyerControll");




function ShouHuPalyerControll:New()
    self = { };
    setmetatable(self, { __index = ShouHuPalyerControll });
    return self
end


function ShouHuPalyerControll:Init(gameObject)
    self.gameObject = gameObject;

    self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
    self.level = UIUtil.GetChildByName(self.gameObject, "UILabel", "level");
    self.elseTime_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "elseTime_txt");

    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
     self.eicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "eicon");
end

--[[
S <-- 10:35:35.330, 0x140C, 0, {"name":"\u59DC\u5FD7\u6613","l":48,"c":101000,"pf":{"e":4,"st":6921,"gts":1,"sts":0,"odd":0,"gt":0,"wt":0,"l":1,"gpi":""},"f":1,"id":"20100003"}
]]

function ShouHuPalyerControll:SetData(data, completeHandler, hd_tg)

    self.data = data;

    self.completeHandler = completeHandler;
    self.hd_tg = hd_tg;

    local name = data.name; -- 守护者名字
    if name == nil then
        name = "null";
    end

    local pf = data.pf;
    local gt = pf.gt;
    local e = pf.e; -- 五行属性

    local lv = data.l;  -- 守护者等级
    local c = data.c;  -- 守护者 职业

    self.level.text = "" .. lv;
    self.name_txt.text = name;
    self.icon.spriteName = c.."";
    self.eicon.spriteName="a"..e;


    if gt > 0 then

        self.djsTime = gt;

        if self._sec_timer ~= nil then
            self._sec_timer:Stop();
            self._sec_timer = nil;
        end

        self.elseTime_txt.text = GetTimeByStr(self.djsTime);

        self._sec_timer = Timer.New( function()

            self.djsTime = self.djsTime - 1;
            self.elseTime_txt.text = GetTimeByStr(self.djsTime);

            if self.djsTime <= 0 then
                if self._sec_timer ~= nil then
                    self._sec_timer:Stop();
                    self._sec_timer = nil;
                end

                if self.completeHandler ~= nil then
                    self.completeHandler(self.hd_tg);
                end

            end
        end , 1, self.djsTime, false);
        self._sec_timer:Start();

    end


end

function ShouHuPalyerControll:Show()

    self.gameObject.gameObject:SetActive(true);
end

function ShouHuPalyerControll:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function ShouHuPalyerControll:Dispose()

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    self.gameObject = nil;

    self.name_txt = nil;
    self.level = nil;
    self.elseTime_txt =nil;

    self.icon = nil;

     self.eicon = nil;

end