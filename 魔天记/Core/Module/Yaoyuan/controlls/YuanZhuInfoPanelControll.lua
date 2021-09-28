

YuanZhuInfoPanelControll = class("YuanZhuInfoPanelControll");

function YuanZhuInfoPanelControll:New()
    self = { };
    setmetatable(self, { __index = YuanZhuInfoPanelControll });
    return self
end


function YuanZhuInfoPanelControll:Init(gameObject)
    self.gameObject = gameObject;

    self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
    self.level = UIUtil.GetChildByName(self.gameObject, "UILabel", "level");

    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self.eicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "eicon");

    self.yaoyuan_level = UIUtil.GetChildByName(self.gameObject, "UILabel", "slider/level");
    self.yaoyuan_pconer = UIUtil.GetChildByName(self.gameObject, "UISprite", "slider/pconer");

     self.expTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "slider/expTxt");
end


function YuanZhuInfoPanelControll:Show()

    self.gameObject.gameObject:SetActive(true);
end

function YuanZhuInfoPanelControll:Hide()

    self.gameObject.gameObject:SetActive(false);
end


--[[
   --wts= [0]
   --n= [任亦涵]
   --l= [99]
   --c= [0]
   --pid= [20100341]
   ]]
function YuanZhuInfoPanelControll:SetData(data,pf)

    self.data = data;

    self.name_txt.text = data.n;
    self.level.text = data.l .. "";
    self.icon.spriteName = data.c .. "";

    self.yaoyuan_level.text = LanguageMgr.Get("Yaoyuan/MyInfoPanelControll/label1",{v=pf.l}); --"药园" .. fram_lv .. "级";

    local maxExp = FarmsDataManager.GetFarmMaxExp(pf.l);

    self.yaoyuan_pconer.width =(pf.exp / maxExp) * 160;

    if pf.exp <= 0 then
     self.yaoyuan_pconer.gameObject:SetActive(false);
    else
     self.yaoyuan_pconer.gameObject:SetActive(true);
    end

    self.expTxt.text = pf.exp.."/"..maxExp;

    self.eicon.spriteName="a"..pf.e;


    self:Show()

end







function YuanZhuInfoPanelControll:Dispose()

  self.gameObject = nil;

    self.name_txt = nil;
    self.level = nil;

    self.icon = nil;
    self.eicon =nil;

    self.yaoyuan_level = nil;
    self.yaoyuan_pconer = nil;


end