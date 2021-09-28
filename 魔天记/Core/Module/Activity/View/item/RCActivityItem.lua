require "Core.Module.Common.UIItem"



RCActivityItem = class("RCActivityItem");

RCActivityItem.MESSAGE_SELECTED = "MESSAGE_SELECTED";
RCActivityItem.MESSAGE_DOHANDLER = "MESSAGE_DOHANDLER";
RCActivityItem.MESSAGE_SHOWINFO = "MESSAGE_SHOWINFO";



RCActivityItem.currSelected = nil;

function RCActivityItem:New()
    self = { };
    setmetatable(self, { __index = RCActivityItem });
    return self
end



function RCActivityItem:Init(gameObject)
    self.gameObject = gameObject


    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self.selectBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "selectBg");
    self.hasdoIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "hasdoIcon");
    self.fatIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "fatIcon");

    self.nameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "nameTxt");
    self.huoyueTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "huoyueTxt");
    self.timeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "timeTxt");

    self.awardDecTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "awardDecTxt");


    self.ctTipTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "ctTipTxt");

    self.doBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "doBt");
    self.doBtLabel = UIUtil.GetChildByName(self.doBt, "UILabel", "tltle");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self._onClickDoBtn = function(go) self:_OnClickDoBtn(self) end
    UIUtil.GetComponent(self.doBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickDoBtn);

    self._onClickiconBtn = function(go) self:_OnClickiconBtn(self) end
    UIUtil.GetComponent(self.icon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickiconBtn);

    if self.ctTipTxt ~= nil then
        self.ctTipTxt.gameObject:SetActive(false);
    end
    self.fatIcon.gameObject:SetActive(false);

    self.doBtLabel.text = LanguageMgr.Get("Activity/RCActivityItem/label3");
    self.needSetSelect_id = nil;
    self:SetSelected(false);
    self:SetHasDo(false);
end

function RCActivityItem:SetSelected(v)

    self.selected = v;
    self.selectBg.gameObject:SetActive(v);
end

function RCActivityItem:SetSelect(activity_id)

    if self.data == nil then
        self.needSetSelect_id = activity_id;

    else
        if self.data.id == activity_id then
            self:_OnClickBtn();
            return true;
        end
    end
    return false;


end

function RCActivityItem:SetHasDo(v)

    self.hasdoIcon.gameObject:SetActive(v);

end

--[[['id'] = 1,	--活动id
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
--[[需要  设置 购买次数

]]
function RCActivityItem:SetData(d, has_nPoint)
    self.data = d;
    self.enbel = false;

    self.needHideBt = false;

    local max_num = 0;

    self.has_nPoint = has_nPoint;
    if has_nPoint and self.npoint == nil then
        self.npoint = UIUtil.GetChildByName(self.gameObject, "UISprite", "npoint");
        self.npoint.gameObject:SetActive(false);
    end

    if d == nil then

        self:SetActive(false);
    else

        if self.fatIcon ~= nil then
            if d.lable_icon ~= nil and d.lable_icon ~= "" then

                self.fatIcon.spriteName = d.lable_icon;
                self.fatIcon.gameObject:SetActive(true);
            else
                self.fatIcon.gameObject:SetActive(false);
            end

        end

        self.enbel = true;

        local interface_id = self.data.interface_id;

        self.gameObject.gameObject.name = interface_id;

        self.icon.spriteName = self.data.activity_icon;
        self.nameTxt.text = self.data.activity_name;

        self.timeInfo = ActivityDataManager.GetActive_time_label(self.data.active_time, self.data.active_date);
        local ft_data = ActivityDataManager.GetFtById(self.data.id);


        self.awardDecTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label9", { n = self.data.reward_des })

        ----------------------------------http://192.168.0.8:3000/issues/4419--------------------------------------------------
        local buy_num = 0;

        if interface_id == ActivityDataManager.interface_id_26 then
            --  剧情副本
            buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.MainInstance);

        elseif interface_id == ActivityDataManager.interface_id_28 then
            buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.EquipInstance);

        elseif interface_id == ActivityDataManager.interface_id_30 then
            buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.type_jiuyouwangzuo);

        elseif interface_id == ActivityDataManager.interface_id_14 then
            buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(InstanceDataManager.InstanceType.type_MingZhuRuQing);

        elseif interface_id == ActivityDataManager.interface_id_3 then
            -- 竞技场购买次数
            buy_num = PVPManager.GetPVPBuyTime();

        elseif interface_id == ActivityDataManager.interface_id_1 then
            -- 悬赏购买次数
            buy_num = TaskManager.data.rewardBuy;

        elseif interface_id == ActivityDataManager.interface_id_8 then
            --  虚灵塔扫荡购买次数
            --  buy_num = InstanceDataManager.GetbuyReds(InstanceDataManager.InstanceType.XuLingTaInstance);
            local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);

            local firstFb = bfCflist[1];
            local hasPass = InstanceDataManager.GetHasPassById(firstFb.id);

            if hasPass ~= nil then
                buy_num = hasPass.st;
            end
        end


        ------------------------------------------------------------------------------------
        if buy_num == nil then
            buy_num = 0;
        end

        max_num = self.data.activity_times + buy_num;

       -- log(" interface_id " .. interface_id .. " activity_name " .. self.data.activity_name .. " max_num " .. max_num .. " buy_num " .. buy_num);

        if ft_data == nil then

            if self.data.activity_times > 0 then
                self.timeTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label1", { n = "0/" .. max_num })
            else
                self.timeTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label1", { n = "-/-" })
            end



            if self.data.max_degree > 0 then
                self.huoyueTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label2", { n = "0/" .. self.data.max_degree })
            else
                self.huoyueTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label2", { n = "-/-" })

            end

        else

            if self.data.activity_times > 0 then

                self.timeTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label1", { n = ft_data.ft .. "/" .. max_num })

            else
                self.timeTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label1", { n = "-/-" })
            end

            --  local curr_n = self.data.active_degree * ft_data.ft;
            local curr_n = ft_data.v;
            if curr_n > self.data.max_degree then
                curr_n = self.data.max_degree;
            end

            if self.data.max_degree > 0 then

                self.huoyueTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label2", { n = curr_n .. "/" .. self.data.max_degree })
            else
                self.huoyueTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label2", { n = "-/-" })

            end



            if ft_data.ft == max_num then

                if d.hide_button == 1 then
                    self.needHideBt = true;
                end

            end

        end


        self.canDo = false;

        local activity_type = self.data.activity_type;
        if activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY then
            self.openTimeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "openTimeTxt");
            self.openTimeTxt.text = self.timeInfo.label;
        end


        if self.timeInfo.type == ActivityDataManager.TIME_TYPE_UNOPEN then



            if self.timeInfo.isInData then
                -- self.doBt.gameObject:SetActive(true);
                self:SetDoV(true)
                self.hasdoIcon.gameObject:SetActive(false);
                self.canDo = true;
            else
                -- self.doBt.gameObject:SetActive(false);
                -- http://192.168.0.8:3000/issues/9213
                self:SetDoV(true)
                self.hasdoIcon.spriteName = "sign_weikaifang";
                self.hasdoIcon.gameObject:SetActive(true);
            end

        elseif self.timeInfo.type == ActivityDataManager.TIME_TYPE_HASPASS then

            self.hasdoIcon.spriteName = "sign_yijieshu";
            self.hasdoIcon.gameObject:SetActive(true);
            -- self.doBt.gameObject:SetActive(false);
            self:SetDoV(false)


        elseif self.timeInfo.type == ActivityDataManager.TIME_TYPE_IN_ACTIVITY then
            self.doBtLabel.text = LanguageMgr.Get("Activity/RCActivityItem/label3");
            -- self.doBt.gameObject:SetActive(true);
            self:SetDoV(true)
            self.hasdoIcon.gameObject:SetActive(false);


            local activity_type = self.data.activity_type;

            if activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY then
                self.openTimeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "openTimeTxt");
                self.openTimeTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label10");
            end

        end

        self:CheckCt();

        if ft_data ~= nil then

            local hide_button = self.data.hide_button;
            if hide_button == 1 and ft_data.ft == max_num then
                -- 需要隐藏 按钮
                -- self.doBt.gameObject:SetActive(false);
                self:SetDoV(false)
            end

        end

        local me = HeroController:GetInstance();
        local heroInfo = me.info;
        local my_lv = heroInfo.level;

        local show_lev = self.data.show_lev;
        local min_lev = self.data.min_lev;

        if my_lv >= show_lev then
            self:SetActive(true);
        else
            self:SetActive(false);
        end

        if self.needHideBt then
            -- self.doBt.gameObject:SetActive(false);
            self:SetDoV(false)
        end


        if self.hasCtToPlay and self.timeInfo.type == ActivityDataManager.TIME_TYPE_HASPASS then
            -- 已经达到开启条件
            -- http://192.168.0.8:3000/issues/2187
            local activity_type = self.data.activity_type;

            if activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY then
                self:SetDoV(true);
                self.doBtLabel.text = LanguageMgr.Get("Activity/RCActivityItem/label3");
            end

        end




        local interface_id = self.data.interface_id;
        if interface_id == ActivityDataManager.interface_id_7 then
            -- 奇花苑  活动 奇花苑前往按钮 有药材成熟时
            if not self.getingFramsData and self.canDo then
                MessageManager.RemoveListener(FarmsDataManager, FarmsDataManager.MESSAGE_FARMS_DATA_CHANGE, RCActivityItem.FarmsDataChange);
                MessageManager.AddListener(FarmsDataManager, FarmsDataManager.MESSAGE_FARMS_DATA_CHANGE, RCActivityItem.FarmsDataChange, self);

                self.getingFramsData = true;
                YaoyuanProxy.TryOpenYaoYuan()
            end


        elseif interface_id == ActivityDataManager.interface_id_8 then
            -- 虚灵塔  虚灵塔前往按钮 扫荡奖励可领取或者闯关奖励可领取时
            if not self.getingFramsData and self.canDo then

                self.xlt_sd_t = -1;
                self.xlt_chuanguan_g = false;

                MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_INFOCHANGE, RCActivityItem.SaodandInfoChange);
                MessageManager.AddListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_INFOCHANGE, RCActivityItem.SaodandInfoChange, self);

                MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_CHUANGGUAN_AWARDLOG, RCActivityItem.ChuanGuanAwardLog);
                MessageManager.AddListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_CHUANGGUAN_AWARDLOG, RCActivityItem.ChuanGuanAwardLog, self);


                XLTInstanceProxy.TryGetXLTSaoDangInfo();
                XLTInstanceProxy.GetChuangGuanAwardLog();

                self.getingFramsData = true;
            end

        elseif interface_id == ActivityDataManager.interface_id_10 and my_lv >= min_lev then

            -- 魔主之影  总是 显示前往按钮
            self:SetDoV(true);
            self.doBtLabel.text = LanguageMgr.Get("Activity/RCActivityItem/label3");

        elseif interface_id == ActivityDataManager.interface_id_15 and not self.can_not_lv_to_play then
            -- http://192.168.0.8:3000/issues/2153
            -- http://192.168.0.8:3000/issues/9113
            self.hasdoIcon.gameObject:SetActive(false);
            self:SetDoV(true)
            if self.timeInfo.type == ActivityDataManager.TIME_TYPE_HASPASS then

                self.doBtLabel.text = self.timeInfo.active_time[1];

            end



            -- elseif interface_id == ActivityDataManager.interface_id_16 then
            --     self:SetDoV(true);

        end


    end

    self:CheckPoint(max_num);


    if self.needSetSelect_id ~= nil then

        self:SetSelect(self.needSetSelect_id);
        self.needSetSelect_id = nil;
    end

end

--[[ 判断设置 红点
]]
function RCActivityItem:CheckPoint(max_num)


    local b = ActivityDataManager.CheckShowPoint(self.data)
    self.npoint.gameObject:SetActive(b);


    if self.data ~= nil then

        local activity_type = self.data.activity_type;

        if activity_type == ActivityDataManager.TYPE_DAY_ACTIVITY then
            -- 日常活动
            local ft_data = ActivityDataManager.GetFtById(self.data.id);


            if ft_data ~= nil and max_num <= ft_data.ft then

                -- log("-----------------max_num " .. max_num .. "  ft_data.ft " .. ft_data.ft .. "  id " .. self.data.id);
                self.hasdoIcon.spriteName = "sign_yiwancheng";
                self.hasdoIcon.gameObject:SetActive(true);

            end
        end

    end



end

function RCActivityItem:SaodandInfoChange(data)

    self.getingFramsData = true;
    self.xlt_sd_t = data.t;

    self:CehckXMLTip();

    self.getingFramsData = false;
end

function RCActivityItem:ChuanGuanAwardLog(data)

    self.getingFramsData = true;
    self.xlt_chuanguan_g = data.canGetAward;

    self:CehckXMLTip();

    self.getingFramsData = false;
end

function RCActivityItem:CehckXMLTip()

    if self.xlt_sd_t == 0 or self.xlt_chuanguan_g then
        self.npoint.gameObject:SetActive(true);
    else

        local buy_num = 0;
        if interface_id == ActivityDataManager.interface_id_8 then
            --  虚灵塔扫荡购买次数
            local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);

            local firstFb = bfCflist[1];
            local hasPass = InstanceDataManager.GetHasPassById(firstFb.id);

            if hasPass ~= nil then
                buy_num = hasPass.st;
            end
        end

        local max_num = self.data.activity_times + buy_num;

        self:CheckPoint(max_num)

    end
end

function RCActivityItem:SetDoV(v)
    self.doBt.gameObject:SetActive(v);
    self.canDo = v;
end

function RCActivityItem:FarmsDataChange()


    self.getingFramsData = true;

    local b = FarmsDataManager.IfHasChengshu();
    self.npoint.gameObject:SetActive(b);


    self.getingFramsData = false;
end



RCActivityItem.CT_TYPE_1 = 1; -- 指是否加入仙盟
RCActivityItem.CT_TYPE_2 = 2; -- 指仙盟等级条件 tong_extend  表的   id==5  level
RCActivityItem.CT_TYPE_3 = 3; -- 活动需求等级

function RCActivityItem:CheckCt()

    local myData = HeroController:GetInstance().info
    local mylv = myData.level;
    self.can_not_lv_to_play = false;

    self.hasCtToPlay = true;

    if self.ctTipTxt ~= nil then
        self.ctTipTxt.gameObject:SetActive(false);
        local interface_data = self.data.interface_data;
        local interface_param = self.data.interface_param
        local a_arr = string.split(interface_data, "_");

        local t_num = table.getn(a_arr);
        for i = 1, t_num do
            local tp = a_arr[i] + 0;
            local parm = interface_param[i]
            if tp == RCActivityItem.CT_TYPE_1 then
                -- 指是否加入仙盟
                local inGuild = GuildDataManager.InGuild();
                if not inGuild then
                    self.ctTipTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label4");
                    self.ctTipTxt.gameObject:SetActive(true);
                    self:HideBtl(false);

                    self.hasdoIcon.gameObject:SetActive(false);
                    self.hasCtToPlay = false;
                    return;
                end

            elseif tp == RCActivityItem.CT_TYPE_2 then
                -- 指仙盟等级条件 tong_extend  表的   id==5  level
                local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GUILDEXTEND);
                local index = tonumber(parm);

                local cfdata = config[index];
                if cfdata == nil then
                    log("---- ------------------------------------ not find in tong_extend , index: " .. index);
                end

                local g = GuildDataManager.GetMyGuildData()
                if g.level < cfdata.level then
                    self.ctTipTxt.text = LanguageMgr.Get("Activity/RCActivityItem/label5", { n = cfdata.level });
                    self.ctTipTxt.gameObject:SetActive(true);
                    self:HideBtl(false);
                    self.hasCtToPlay = false;
                end

            elseif tp == RCActivityItem.CT_TYPE_3 then
                -- 最后判断 最近的等级
                local min_lev = self.data.min_lev;
                if mylv < min_lev then
                    self.can_not_lv_to_play = true;
                    self.ctTipTxt.text = GetLvDes1(min_lev) .. LanguageMgr.Get("Activity/RCActivityItem/label6");
                    self.ctTipTxt.gameObject:SetActive(true);
                    self:HideBtl(false);

                    self.hasdoIcon.gameObject:SetActive(false);
                    self.hasCtToPlay = false;
                    return;
                end
            end
        end
    end

end

function RCActivityItem:HideBtl(v)
    -- self.doBt.gameObject:SetActive(v);
    self:SetDoV(v)
    self.huoyueTxt.gameObject:SetActive(v);
    self.timeTxt.gameObject:SetActive(v);
    self.awardDecTxt.gameObject:SetActive(v);

    local activity_type = self.data.activity_type;
    if activity_type == ActivityDataManager.TYPE_TIME_ACTIVITY then
        self.openTimeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "openTimeTxt");
        self.openTimeTxt.gameObject:SetActive(v);
    end

end

function RCActivityItem:_OnClickBtn()


    if self.enbel then
        if RCActivityItem.currSelected ~= nil then

            RCActivityItem.currSelected:SetSelected(false);
        end

        RCActivityItem.currSelected = self;
        RCActivityItem.currSelected:SetSelected(true);

        MessageManager.Dispatch(RCActivityItem, RCActivityItem.MESSAGE_SELECTED, self.data);
    end
end



function RCActivityItem:_OnClickDoBtn()
    if self.enbel then
       
     ActivityDataManager.ActiveDo(self.data.id);


    end



end

function RCActivityItem.TryReqEnterZone()
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
    GuildProxy.ReqEnterZone();
end

function RCActivityItem:_OnClickiconBtn()
    if self.enbel then
        self.data.timeInfo = self.timeInfo;
        MessageManager.Dispatch(RCActivityItem, RCActivityItem.MESSAGE_SHOWINFO, self.data);
    end
end

function RCActivityItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function RCActivityItem:Dispose()

    MessageManager.RemoveListener(FarmsDataManager, FarmsDataManager.MESSAGE_FARMS_DATA_CHANGE, RCActivityItem.FarmsDataChange);
    MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_INFOCHANGE, RCActivityItem.SaodandInfoChange);
    MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_CHUANGGUAN_AWARDLOG, RCActivityItem.ChuanGuanAwardLog);

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    UIUtil.GetComponent(self.doBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickDoBtn = nil;

    UIUtil.GetComponent(self.icon, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickiconBtn = nil
    self.gameObject = nil;
    self.icon = nil;
    self.selectBg = nil;
    self.hasdoIcon = nil;
    self.nameTxt = nil;
    self.huoyueTxt = nil;
    self.timeTxt = nil;
    self.ctTipTxt = nil;
    self.doBt = nil;
    self.doBtLabel = nil;
    self._onClickBtn = nil;
    self._onClickDoBtn = nil;
    self._onClickiconBtn = nil;
    self.ctTipTxt = nil;
end 