require "Core.Module.Common.UIItem"



ActivityFBItem = class("ActivityFBItem");

function ActivityFBItem:New()
    self = { };
    setmetatable(self, { __index = ActivityFBItem });
    return self
end



function ActivityFBItem:Init(gameObject)
    self.gameObject = gameObject


    self.fbIcon = UIUtil.GetChildByName(self.gameObject, "UITexture", "fbIcon");

    self.unknown = UIUtil.GetChildByName(self.gameObject, "UISprite", "unknown");
    self.nameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "nameTxt");
    self.timeNumtxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "timeNumtxt");
    self.huoyueNumtxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "huoyueNumtxt");

    self.lvLimTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "lvLimTxt");


    self.awardtxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "awardtxt");

    self.npoint = UIUtil.GetChildByName(self.gameObject, "UISprite", "npoint");

    self.selectIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "selectIcon");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);


end

function ActivityFBItem:SetSelect(activity_id)


    if self.data ~= nil and self.data.id == activity_id then
        self.selectIcon.gameObject:SetActive(true);
    end

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

function ActivityFBItem:SetData(d)
    self.data = d;
    self.enbel = false;
    if self.data == nil then
        self:SetActive(false);
    else


        self.gameObject.gameObject.name = self.data.interface_id;
        local interface_id = self.data.interface_id;

        local show_lev = self.data.show_lev;

        local me = HeroController:GetInstance();
        local heroInfo = me.info;
        local my_lv = heroInfo.level;

        if my_lv >= self.data.min_lev then
            self.lvLimTxt.gameObject:SetActive(false);
            self.lvLim = false;
        else
            self.lvLimTxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label5", { lv = self.data.min_lev })
            self.lvLimTxt.gameObject:SetActive(true);
            self.lvLim = true;
        end

        self.awardtxt.text = LanguageMgr.Get("Activity/RCActivityItem/label12", { n = self.data.reward_des })


        if my_lv >= show_lev then
            self.enbel = true;
            self.unknown.gameObject:SetActive(false);
            self.fbIcon.gameObject:SetActive(true);

            -- self.fbIcon.spriteName = self.data.activity_icon;

            if self._mainTexturePath then
                -- UIUtil.RecycleTexture(self._mainTexturePath)
                self._mainTexturePath = nil;
                -- self.fbIcon.mainTexture = nil;
            end

            self._mainTexturePath = "Instance_FBIcons/" .. self.data.activity_icon;
            self.fbIcon.mainTexture = UIUtil.GetTexture(self._mainTexturePath)

            if self.fbIcon.mainTexture == nil then
                self._mainTexturePath = "Instance_FBIcons/fb_zx01";
                self.fbIcon.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
            end


            self.nameTxt.text = self.data.activity_name;

            -- interface_id
            -- InstanceDataManager.InstanceType

            local buy_num = ActivityDataManager.Get_buy_num(interface_id)


            local temnum = self.data.activity_times + buy_num;

            if temnum > 0 then

                local ft_data = ActivityDataManager.GetFtById(self.data.id);

                if ft_data == nil then


                    self.timeNumtxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label1", { n = "0/" .. temnum })

                    if self.data.max_degree > 0 then
                        self.huoyueNumtxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label2", { n = "0/" .. self.data.max_degree })

                    else
                        self.huoyueNumtxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label2", { n = "-/-" })

                    end

                else


                    self.timeNumtxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label1", { n = ft_data.ft .. "/" .. temnum })


                    local te =(self.data.active_degree * ft_data.ft);
                    -- max_degree
                    if te > self.data.max_degree then
                        te = self.data.max_degree;
                    end

                    if self.data.max_degree > 0 then
                        self.huoyueNumtxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label2", { n = te .. "/" .. self.data.max_degree })
                    else
                        self.huoyueNumtxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label2", { n = "-/-" })
                    end



                end
            else
                self.timeNumtxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label1", { n = "-/-" })

                if self.data.max_degree > 0 then
                    self.huoyueNumtxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label2", { n = "0/" .. self.data.max_degree })
                else
                    self.huoyueNumtxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label2", { n = "-/-" })
                end


            end




        else
            self.unknown.gameObject:SetActive(true);
            self.fbIcon.gameObject:SetActive(false);

            self.nameTxt.text = "";
            self.timeNumtxt.text = "";
            self.huoyueNumtxt.text = "";
        end


        self:SetActive(true);
    end

    self:CheckPoint()

end

--[[
 判断设置 红点
 -- 日常活动、多人副本标签页下面的活动有次数时，均需要显示红点，红点的位置见截图（标签页上和前往按钮）
 http://192.168.0.8:3000/issues/3976
]]
function ActivityFBItem:CheckPoint()

    local b = ActivityDataManager.CheckShowPoint(self.data)
    self.npoint.gameObject:SetActive(b);

end

function ActivityFBItem:_OnClickBtn()

   
    if self.enbel then

        if self.data.minipack_open == 0 and not AppSplitDownProxy.SysCheckLoad(nil, PlayerManager.GetPlayerLevel()) then return end


        if self.lvLim then

            MsgUtils.ShowTips("Activity/ActivityFBItem/label6");
            return;

        end

        local interface_id = self.data.interface_id;


        SequenceManager.TriggerEvent(SequenceEventType.Guide.ACTIVITY_RCFB_SELECTED, interface_id);



        -- 这里都不关闭活动界面
        -- http://192.168.0.8:3000/issues/1222

        if interface_id == ActivityDataManager.interface_id_26 then
            -- 剧情副本
            -- ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

            ModuleManager.SendNotification(InstancePanelNotes.OPEN_INSTANCEPANEL);

        elseif interface_id == ActivityDataManager.interface_id_25 then
            --  宗门历练
            -- ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

            ModuleManager.SendNotification(ZongMenLiLianNotes.OPEN_ZONGMENLILIANPANEL);

            ----------------------------------------------- 以下是界面一样的 功能 ------------------------------------------------------------------
        else

            local instance_type = self.data.instance_type;

            local args = { name = self.data.activity_name, interface_id = interface_id, interface_data = self.data.interface_data, type = instance_type, kind = InstanceDataManager.kind_0 };
            -- ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
            ModuleManager.SendNotification(LSInstanceNotes.OPEN_LSINSTANCEPANEL, args);


            -----------------------------------------------------------------------------------------------------------------
        end

    end

end




function ActivityFBItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function ActivityFBItem:Dispose()

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");

    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath)
        self._mainTexturePath = nil;
        -- self.fbIcon.mainTexture = nil;
    end

    self._onClickBtn = nil;

    self.gameObject = nil;


    self.fbIcon = nil;
    self.unknown = nil;
    self.nameTxt = nil;
    self.timeNumtxt = nil;
    self.huoyueNumtxt = nil;

    self._onClickBtn = nil;

end