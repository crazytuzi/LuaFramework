require "Core.Module.Common.UISubPanel";

GuildInfoSubDetail = class("GuildInfoSubDetail", UISubPanel);

function GuildInfoSubDetail:_InitReference()
    
    self._txtTitle = UIUtil.GetChildByName(self._transform, "UILabel", "txtTitle");
    self._txtLeader = UIUtil.GetChildByName(self._transform, "UILabel", "titleLeader/txtLeader");
    self._txtLevel = UIUtil.GetChildByName(self._transform, "UILabel", "titleLevel/txtLevel");
    self._txtExp = UIUtil.GetChildByName(self._transform, "UILabel", "titleExp/txtExp");
    self._sliderExp = UIUtil.GetChildByName(self._transform, "UISlider", "titleExp/sliderExp");

    self._txtNum = UIUtil.GetChildByName(self._transform, "UILabel", "titleNum/txtNum");
    self._txtFight = UIUtil.GetChildByName(self._transform, "UILabel", "titleFight/txtFight");
    self._txtMoney = UIUtil.GetChildByName(self._transform, "UILabel", "titleMoney/txtMoney");
    self._txtTodayRepair = UIUtil.GetChildByName(self._transform, "UILabel", "titleTodayRepair/txtTodayRepair");
    self._txtRank = UIUtil.GetChildByName(self._transform, "UILabel", "titleRank/txtRank");
    self._txtTodayMoneyMax = UIUtil.GetChildByName(self._transform, "UILabel", "titleTodayMoneyMax/txtTodayMoneyMax");
    self._txtTodayExpMax = UIUtil.GetChildByName(self._transform, "UILabel", "titleTodayExpMax/txtTodayExpMax");

    self._btnClose = UIUtil.GetChildByName(self._transform, "UIButton", "btnClose");
    self._onClickClose = function(go) self:_OnClickClose() end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickClose); 
end
    
function GuildInfoSubDetail:_DisposeReference()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickClose = nil;
end

function GuildInfoSubDetail:_OnEnable()
    self:UpdateDisplay();
end

function GuildInfoSubDetail:UpdateDisplay()
    local data = GuildDataManager.data;
    local info = GuildDataManager.info;
    

    self._txtTitle.text = data.name;
    self._txtLeader.text = data.leader;
    self._txtLevel.text = data.level;

    local nextLvCfg = ConfigManager.GetGuildLevelConfig(data.level + 1);
    local lvCfg = ConfigManager.GetGuildLevelConfig(data.level);
    if nextLvCfg then
        local max = lvCfg.exp;
        local cur = data.exp;
        self._txtExp.text = LanguageMgr.Get("common/numMax", {num = cur, max = max});
        self._sliderExp.value = cur / max;
    else
        self._txtExp.text = LanguageMgr.Get("guild/lvMax");
        self._sliderExp.value = 1;
    end 
    
    
    self._txtNum.text = LanguageMgr.Get("common/numMax", {num = data.num, max = lvCfg.number});
    self._txtFight.text = data.fight;
    self._txtMoney.text = data.money;
    self._txtTodayRepair.text = lvCfg.maintenance_und;
    self._txtRank.text = data.rank;
    self._txtTodayMoneyMax.text = lvCfg.capital_limit;
    self._txtTodayExpMax.text = lvCfg.experience_limit;
end

function GuildInfoSubDetail:_OnClickClose()
    self:Disable();
end
