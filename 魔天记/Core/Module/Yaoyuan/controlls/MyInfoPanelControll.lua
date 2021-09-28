

MyInfoPanelControll = class("MyInfoPanelControll");

function MyInfoPanelControll:New()
    self = { };
    setmetatable(self, { __index = MyInfoPanelControll });
    return self
end


function MyInfoPanelControll:Init(gameObject)
    self.gameObject = gameObject;

    self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
    self.level = UIUtil.GetChildByName(self.gameObject, "UILabel", "level");

    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self.eicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "eicon");

    self.yaoyuan_level = UIUtil.GetChildByName(self.gameObject, "UILabel", "slider/level");
    self.yaoyuan_pconer = UIUtil.GetChildByName(self.gameObject, "UISprite", "slider/pconer");

    self.expTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "slider/expTxt");

    MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_MY_YAOYUAN_LEVEL_CHANGE, MyInfoPanelControll.MyYaoYuanLevelChange, self);



end


function MyInfoPanelControll:Show()




    self.gameObject.gameObject:SetActive(true);
end

--[[
S <-- 12:05:22.607, 0x1401, 13, {"farms":[{"st":0,"gt":0,"s":"","wt":0,"i":2},{"st":0,"gt":0,"s":"","wt":0,"i":4},{"st":0,"gt":0,"s":"","wt":0,"i":1},
{"st":0,"gt":0,"s":"","wt":0,"i":3}],

"pf":{"st":75857,"gts":0,"sts":0,"odd":0,"gt":758574,"wt":0,"l":1}}

]]
function MyInfoPanelControll:SetData(pf)
    self.data = pf;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;


    self.name_txt.text = heroInfo.name;
    self.level.text = heroInfo.level .. "";

    local level = self.data.l;
    self.yaoyuan_level.text = LanguageMgr.Get("Yaoyuan/MyInfoPanelControll/label1", { v = level });

    local maxExp = FarmsDataManager.GetFarmMaxExp(level);

    self.yaoyuan_pconer.width =(pf.exp / maxExp) * 160;

    if pf.exp <= 0 then
        self.yaoyuan_pconer.gameObject:SetActive(false);
    else
        self.yaoyuan_pconer.gameObject:SetActive(true);
    end

     self.expTxt.text = pf.exp.. "/"..maxExp;
    self.icon.spriteName = "" .. heroInfo.kind;
    self.eicon.spriteName = "a" .. pf.e;



end

--[[
14 药园升级通知（服务端发出）
输出：
exp:经验
lv：等级

]]
function MyInfoPanelControll:MyYaoYuanLevelChange(data)

    local exp = data.exp;
    local lv = data.lv;

    if lv == nil then
        lv = self.data.l;
    else
        self.data.l = lv;
    end


    self.yaoyuan_level.text = LanguageMgr.Get("Yaoyuan/MyInfoPanelControll/label1", { v = lv });


    local maxExp = FarmsDataManager.GetFarmMaxExp(lv);

    if exp == nil then
       exp = FarmsDataManager.GetMy_pf().exp;
    end 

    self.yaoyuan_pconer.width =(exp / maxExp) * 160;

    if exp <= 0 then
        self.yaoyuan_pconer.gameObject:SetActive(false);
    else
        self.yaoyuan_pconer.gameObject:SetActive(true);
    end
  
     self.expTxt.text = exp.. "/"..maxExp;

end

function MyInfoPanelControll:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function MyInfoPanelControll:Dispose()

    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_MY_YAOYUAN_LEVEL_CHANGE, MyInfoPanelControll.MyYaoYuanLevelChange);

    self.gameObject = nil;

    self.name_txt = nil;
    self.level = nil;

    self.icon = nil;
    self.eicon = nil;

    self.yaoyuan_level = nil;
    self.yaoyuan_pconer = nil;


    

end