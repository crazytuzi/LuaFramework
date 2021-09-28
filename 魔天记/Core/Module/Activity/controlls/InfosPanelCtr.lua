InfosPanelCtr = class("InfosPanelCtr");

function InfosPanelCtr:New()
    self = { };
    setmetatable(self, { __index = InfosPanelCtr });
    return self
end


function InfosPanelCtr:Init(gameObject)
    self.gameObject = gameObject;

    for i = 1, 7 do
        self["labeTxt" .. i] = UIUtil.GetChildByName(self.gameObject, "UILabel", "labeTxt" .. i);
    end

    for i = 1, 5 do
        self["product" .. i] = UIUtil.GetChildByName(self.gameObject, "Transform", "product" .. i);
        self["productCtr" .. i] = ProductCtrl:New();
        self["productCtr" .. i]:Init(self["product" .. i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
        self["productCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
        self["product" .. i].gameObject:SetActive(false);
    end

    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self.gameObject.gameObject:SetActive(true);
    self:Hide()

end

function InfosPanelCtr:_OnClickBtn()

    self:Hide()
end

--[[
['id'] = 1,	--活动id
		['activity_type'] = 1,	--活动类型
		['order'] = 1,	--界面显示排序
		['activity_name'] = '悬赏任务',	--活动名称
		['interface_id'] = 1,	--对应界面id
		['interface_data'] = '0',	--对应副本
		['activity_icon'] = 'richang_01',	--活动图标
		['produce_des'] = '0',	--产出描述
		['activity_times'] = 10,	--活动次数
		['hide_button'] = 0,	--完成时是否隐藏按钮
		['active_degree'] = 1,	--单次活跃点数
		['max_degree'] = 10,	--当日活跃上限

		['min_lev'] = 10,	--需求最小等级
		['show_lev'] = 5,	--显示等级
		['max_lev'] = 100,	--需求最大等级

		['num_limit'] = 1,	--人数条件
		['active_date'] = {1,2,3,4,5,6,7},	--活动日期
		['active_time'] = {'00:00-23:59'},	--活动时间
		['active_reward'] = '主要产出修为，其次为灵石。',	--活动奖励
		['active_des'] = '全天开放。虽修仙之人可食气而神明，然灵谷乃是增加自身法力的玄妙食材，因此种植灵谷是每一个宗门中必然要完成的任务。',	--活动描述


]]
function InfosPanelCtr:Show(data)

    self.data = data;

    self.labeTxt1.text = LanguageMgr.Get("Activity/InfosPanelCtr/label1", { n = self.data.activity_name });

    self.icon.spriteName = self.data.activity_icon;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv >= self.data.min_lev then
        self.labeTxt2.text = LanguageMgr.Get("Activity/InfosPanelCtr/label2", { n = "[77ff47]" .. self.data.min_lev .. "[-]" });
    else
        self.labeTxt2.text = LanguageMgr.Get("Activity/InfosPanelCtr/label2", { n = "[bb0000]" .. self.data.min_lev .. "[-]" });
    end

    local timeInfo = ActivityDataManager.GetActive_time_label(self.data.active_time, self.data.active_date);
   

    self.labeTxt3.text = LanguageMgr.Get("Activity/InfosPanelCtr/label3", { n = timeInfo.label });

    local num_limit = self.data.num_limit;

    if num_limit == 1 then
        self.labeTxt4.text = LanguageMgr.Get("Activity/InfosPanelCtr/label4");
    else
        self.labeTxt4.text = LanguageMgr.Get("Activity/InfosPanelCtr/label5");
    end

    self.labeTxt5.text = LanguageMgr.Get("Activity/InfosPanelCtr/label6");

    self.labeTxt6.text = "[b3cbff]" .. self.data.active_des .. "[-]";

    -- self.labeTxt7.text = LanguageMgr.Get("Activity/InfosPanelCtr/label7", { n = self.data.active_reward });

    for i = 1, 5 do
         self["product" .. i].gameObject:SetActive(false);
    end

    local reward_icon = self.data.reward_icon;
    local l_num = table.getn(reward_icon);
    for i = 1, l_num do
        local arr = ConfigSplit(reward_icon[i]);
        local id = tonumber(arr[1]);
        local num = tonumber(arr[2]);


        local pinfo = ProductInfo:New();
        pinfo:Init( { spId = id, am = num });

        self["productCtr" .. i]:SetData(pinfo);
        self["product" .. i].gameObject:SetActive(true);
    end

    -- self.gameObject.gameObject:SetActive(true);
  

    SequenceManager.TriggerEvent(SequenceEventType.Guide.ACTIVITY_SHOW_TIPS, data.id);

end

function InfosPanelCtr:Hide()

ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY_TIP);

end

function InfosPanelCtr:Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    self.gameObject = nil;

    for i = 1, 7 do
        self["labeTxt" .. i] = nil;
    end

    for i = 1, 5 do

        self["productCtr" .. i]:Dispose();
        self["productCtr" .. i] = nil;
        self["product" .. i] = nil;
    end

    self._onClickBtn = nil;

    self.data = nil;


end