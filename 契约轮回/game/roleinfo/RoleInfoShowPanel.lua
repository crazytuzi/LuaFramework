-- 
-- @Author: LaoY
-- @Date:   2018-07-20 18:03:38
-- 
RoleInfoShowPanel = RoleInfoShowPanel or class("RoleInfoShowPanel", BaseItem)
local this = RoleInfoShowPanel

function RoleInfoShowPanel:ctor(parent_node, layer)
    self.abName = "roleinfo"
    self.assetName = "RoleInfoShowPanel"
    self.layer = layer
    self.events = {}
    self.model = RoleInfoModel:GetInstance()
    BaseItem.Load(self)
end

function RoleInfoShowPanel:dctor()
    if self.update_fashion_rd_event_id then
        self.model:RemoveListener(self.update_fashion_rd_event_id)
        self.update_fashion_rd_event_id = nil
    end
    if self.update_jobtitle_rd_event_id then
        self.model:RemoveListener(self.update_jobtitle_rd_event_id)
        self.update_jobtitle_rd_event_id = nil
    end
    GlobalEvent:RemoveTabListener(self.events)
    if self.lv_item then
        self.lv_item:destroy()
        self.lv_item = nil
    end
    if self.jt_red_dot then
        self.jt_red_dot:destroy()
        self.jt_red_dot = nil
    end
    if self.fashion_rd then
        self.fashion_rd:destroy()
        self.fashion_rd = nil
    end
    if self.rolemodel then
        self.rolemodel:destroy()
        self.rolemodel = nil
    end
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
end

function RoleInfoShowPanel:LoadCallBack()
    self.nodes = {
        "playerInfo/exp/expTex", "playerInfo/bangpaiName", "playerInfo/exp/exp_bar", "playerInfo/zdlText",
        "world_btn", "edit_name_btn", "heart_btn", "playerInfo/change_head_btn",

        "baseinfo/role_name", "baseinfo/job", "baseinfo/lv_con", "role_model", "baseinfo/vip",

        "btns", "btns/title_btn", "btns/huaxing_btn", "btns/wake_btn", "btns/job_btn", "btns/fasion_btn", --"job_btn", "fasion_btn", "title_btn","huaxing_btn", "wake_btn",

        --基础属性
        "prop/shengmingValue", "prop/baojiValue", "prop/shanbiValue", "prop/mofagongjiValue", "prop/mingzhongValue", "prop/jianrenValue", "prop/fangyuValue", "prop/mofafangyuValue", "prop/gongjiValue", "prop/pojiaValue",

        --高级属性
        "ScrollView/Viewport/Content/gedangchuantouValue", "ScrollView/Viewport/Content/baojishanghaiValue", "ScrollView/Viewport/Content/yidongsuduValue",
        "ScrollView/Viewport/Content/hujiachuantouValue", "ScrollView/Viewport/Content/jinengjianshangValue", "ScrollView/Viewport/Content/baojijilvValue",
        "ScrollView/Viewport/Content/mingzhongjilvValue", "ScrollView/Viewport/Content/renwuhujiaValue", "ScrollView/Viewport/Content/huixinshanghaiValue",
        "ScrollView/Viewport/Content/huixinjilvValue", "ScrollView/Viewport/Content/huixindikangValue", "ScrollView/Viewport/Content/baojidikangValue",
        "ScrollView/Viewport/Content/shanghaijiashenValue", "ScrollView/Viewport/Content/shanbijilvValue", "ScrollView/Viewport/Content/shanghaijianmianValue",
        "ScrollView/Viewport/Content/gedangjilvValue", "ScrollView/Viewport/Content/jinengzengshangValue",

        "bgLayer/bg", "playerInfo/icon_con", "btns/job_btn/job_red_con", "btns/fasion_btn/fashion_rd_con",
    }
    self:GetChildren(self.nodes)
    self:InitUI();

    self:InitModel();

    self:AddEvent();
    self.bg = GetImage(self.bg);
    local res = "role_info_bg";
    lua_resMgr:SetImageTexture(self, self.bg, "iconasset/icon_big_bg_" .. res, res, false);
    self:CheckJobTitleIconRD()
    self:CheckFashionIconRD()

end
function RoleInfoShowPanel:InitModel()
    local mainrole_data = RoleInfoModel.GetInstance():GetMainRoleData();

    local config={}
    config.is_show_magic=true
    self.rolemodel = UIRoleCamera(self.role_model, nil, mainrole_data,nil,nil,nil,config)
    local function callback()
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.btns.transform, nil, true, nil,nil,10)

        --LayerManager.GetInstance():AddOrderIndexByCls(self, self.title_btn, nil, true, 420 )
        --LayerManager.GetInstance():AddOrderIndexByCls(self, self.huaxing_btn, nil, true, 420 )
        --LayerManager.GetInstance():AddOrderIndexByCls(self, self.wake_btn, nil, true, nil,nil,4)
        --LayerManager.GetInstance():AddOrderIndexByCls(self, self.job_btn, nil, true, 420 )
        --LayerManager.GetInstance():AddOrderIndexByCls(self, self.fasion_btn, nil, true, 420 )
        --LayerManager.GetInstance():AddOrderIndexByCls(self, self.job_red_con, nil, true, 420 )
        --LayerManager.GetInstance():AddOrderIndexByCls(self, self.fashion_rd_con, nil, true, 420 )
    end
    self.rolemodel:AddLoadCallBack(callback)
end

function RoleInfoShowPanel:InitUI()
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
    local param = {}
    param.size = 87.5
    local function uploading_cb()
        Notify.ShowText('Uploaded')
    end
    param.uploading_cb = uploading_cb
    self.role_icon = RoleIcon(self.icon_con)
    self.role_icon:SetData(param)

    local mainrole_data = RoleInfoModel.GetInstance():GetMainRoleData();
    if not mainrole_data then
        return ;
    end

    local p_attr = mainrole_data.attr;
    self.zdlText = GetText(self.zdlText);
    self.zdlText.text = tostring(mainrole_data.power);

    local gender = RoleInfoModel:GetInstance():GetSex()
    local res_id = "img_role_head_1"
    if gender == 2 then
        res_id = "img_role_head_2"
    end

    self.expTex = GetText(self.expTex);
    self.exp_bar = GetImage(self.exp_bar);
    if Config.db_role_level[mainrole_data.level] then
        self.exp_bar.fillAmount = mainrole_data.exp / Config.db_role_level[mainrole_data.level].exp;
        local rus = string.format("%.2f", mainrole_data.exp/Config.db_role_level[mainrole_data.level].exp)
        self.expTex.text = string.format("%s%s/%s",rus,"%","100%")
        --self.expTex.text = string.format("%s/%s", GetShowNumber(mainrole_data.exp), GetShowNumber(Config.db_role_level[mainrole_data.level].exp))
    end

    --设置下面那排按钮的
    local level = mainrole_data.level;

    local fashionLevel = GetSysOpenDataById("100@1");
    if fashionLevel and tonumber(fashionLevel) > level then
        SetGameObjectActive(self.fasion_btn.gameObject, false);
    else
        SetGameObjectActive(self.fasion_btn.gameObject, true);
    end

    local visionLevel = GetSysOpenDataById("100@7");
    if visionLevel and tonumber(visionLevel) > level then
        SetGameObjectActive(self.huaxing_btn.gameObject, false);
    else
        SetGameObjectActive(self.huaxing_btn.gameObject, true);
    end

    local wakeLevel = GetSysOpenDataById("600@1");
    if wakeLevel and tonumber(wakeLevel) > level then
        SetGameObjectActive(self.wake_btn.gameObject, false);
    else
        SetGameObjectActive(self.wake_btn.gameObject, true);
    end

    --local job_level = GetSysOpenDataById("100@6");
    --if job_level and tonumber(job_level) > level then
    --    SetGameObjectActive(self.job_btn.gameObject, false);
    --else
    --    SetGameObjectActive(self.job_btn.gameObject, true);
    --end
    local is_open = OpenTipModel.GetInstance():IsOpenSystem(100, 6)
    SetGameObjectActive(self.job_btn.gameObject, is_open);

    local titleLevel = GetSysOpenDataById("240@1");
    if titleLevel and tonumber(titleLevel) > level then
        SetGameObjectActive(self.title_btn.gameObject, false);
    else
        SetGameObjectActive(self.title_btn.gameObject, true);
    end

    self.role_name = GetText(self.role_name);
    self.role_name.text = mainrole_data.name;

    self.vipTex = GetText(self.vip);
    self.vipTex.text = "V" .. mainrole_data.viplv;
    self:UpdateJob()

    if not self.lv_item then
        self.lv_item = LevelShowItem(self.lv_con)
        self.lv_item:SetData(19, nil, "FFFFFF")
    end

    self.bangpaiName = GetText(self.bangpaiName);
    if mainrole_data.guild and tostring(mainrole_data.guild) == "0" then
        self.bangpaiName.text = "Not in a guild";
    else
        self.bangpaiName.text = mainrole_data.gname;
    end

    self.gongjiValue = GetText(self.gongjiValue);
    self.gongjiValue.text = p_attr.att;

    self.pojiaValue = GetText(self.pojiaValue);
    self.pojiaValue.text = p_attr.wreck;

    self.mingzhongValue = GetText(self.mingzhongValue);
    self.mingzhongValue.text = p_attr.hit;

    self.baojiValue = GetText(self.baojiValue);
    self.baojiValue.text = p_attr.crit;

    self.mofagongjiValue = GetText(self.mofagongjiValue);
    self.mofagongjiValue.text = p_attr.holy_att;

    self.shengmingValue = GetText(self.shengmingValue);
    self.shengmingValue.text = p_attr.hpmax;

    self.fangyuValue = GetText(self.fangyuValue);
    self.fangyuValue.text = p_attr.def;

    self.shanbiValue = GetText(self.shanbiValue);
    self.shanbiValue.text = p_attr.miss;

    self.jianrenValue = GetText(self.jianrenValue);
    self.jianrenValue.text = p_attr.tough;

    self.mofafangyuValue = GetText(self.mofafangyuValue);
    self.mofafangyuValue.text = p_attr.holy_def;

    self.shanghaijiashenValue = GetText(self.shanghaijiashenValue);
    self.shanghaijiashenValue.text = (p_attr.dmg_amp / 100) .. "%";

    self.mingzhongjilvValue = GetText(self.mingzhongjilvValue);
    self.mingzhongjilvValue.text = (p_attr.hit_pro / 100) .. "%";

    self.hujiachuantouValue = GetText(self.hujiachuantouValue);
    self.hujiachuantouValue.text = (p_attr.armor_str / 100) .. "%";

    self.gedangchuantouValue = GetText(self.gedangchuantouValue);
    self.gedangchuantouValue.text = (p_attr.block_str / 100) .. "%";

    self.baojijilvValue = GetText(self.baojijilvValue);
    self.baojijilvValue.text = (p_attr.crit_pro / 100) .. "%";

    self.huixinjilvValue = GetText(self.huixinjilvValue);
    self.huixinjilvValue.text = (p_attr.heart_pro / 100) .. "%";

    self.baojishanghaiValue = GetText(self.baojishanghaiValue);
    self.baojishanghaiValue.text = (p_attr.crit_dmg / 100) .. "%";

    self.jinengzengshangValue = GetText(self.jinengzengshangValue);
    self.jinengzengshangValue.text = (p_attr.skill_amp / 100) .. "%";

    self.yidongsuduValue = GetText(self.yidongsuduValue);
    self.yidongsuduValue.text = p_attr.speed;

    self.shanghaijianmianValue = GetText(self.shanghaijianmianValue);
    self.shanghaijianmianValue.text = (p_attr.dmg_red / 100) .. "%";

    self.shanbijilvValue = GetText(self.shanbijilvValue);
    self.shanbijilvValue.text = (p_attr.miss_pro / 100) .. "%";

    self.renwuhujiaValue = GetText(self.renwuhujiaValue);
    self.renwuhujiaValue.text = (p_attr.armor_pro / 100) .. "%";

    self.gedangjilvValue = GetText(self.gedangjilvValue);
    self.gedangjilvValue.text = (p_attr.block_pro / 100) .. "%";

    self.baojidikangValue = GetText(self.baojidikangValue);
    self.baojidikangValue.text = (p_attr.crit_res / 100) .. "%";

    self.huixindikangValue = GetText(self.huixindikangValue);
    self.huixindikangValue.text = (p_attr.heart_res / 100) .. "%";

    self.huixinshanghaiValue = GetText(self.huixinshanghaiValue);
    self.huixinshanghaiValue.text = (p_attr.heart_dmg / 100) .. "%";

    self.jinengjianshangValue = GetText(self.jinengjianshangValue);
    self.jinengjianshangValue.text = (p_attr.skill_red / 100) .. "%";
end

function RoleInfoShowPanel:RefreshData()

end

function RoleInfoShowPanel:AddEvent()
    AddClickEvent(self.huaxing_btn.gameObject, handler(self, self.HandleHuaxing));
    AddClickEvent(self.change_head_btn.gameObject, handler(self, self.HandleChangeHead));
    AddClickEvent(self.fasion_btn.gameObject, handler(self, self.HandleFasion));
    AddClickEvent(self.job_btn.gameObject, handler(self, self.HandleJob));
    AddClickEvent(self.title_btn.gameObject, handler(self, self.HandleTitle));
    AddClickEvent(self.wake_btn.gameObject, handler(self, self.HandleWake));
    AddClickEvent(self.world_btn.gameObject, handler(self, self.HandleWorld));
    AddClickEvent(self.edit_name_btn.gameObject, handler(self, self.HandleEditName));
    AddClickEvent(self.heart_btn.gameObject, handler(self, self.HandleHeart));

    self.events[#self.events + 1] = GlobalEvent:AddListener(RoleInfoEvent.RoleReName, handler(self, self.RoleReName))
    self.events[#self.events + 1] = GlobalEvent:AddListener(RoleInfoEvent.TitleName, handler(self, self.UpdateJob))
    self.update_jobtitle_rd_event_id = self.model:AddListener(RoleInfoEvent.UpdateJobTitleRedDot, handler(self, self.CheckJobTitleIconRD))
    self.update_fashion_rd_event_id = self.model:AddListener(RoleInfoEvent.UpdateFashionRedDot, handler(self, self.CheckFashionIconRD))
end

--化形/幻化
function RoleInfoShowPanel:HandleHuaxing(go, x, y)
    lua_panelMgr:GetPanelOrCreate(WingHuaXingPanel):Open(1);
end

--更换头像
function RoleInfoShowPanel:HandleChangeHead(go, x, y)
    --self.role_icon:SetIcon()
    lua_panelMgr:GetPanelOrCreate(MarryChangeHeadPanel):Open(self.role_icon)
end

--时装
function RoleInfoShowPanel:HandleFasion(go, x, y)
    GlobalEvent:Brocast(FashionEvent.OpenFashionPanel)
end

function RoleInfoShowPanel:HandleJob(go, x, y)
    --print2("RoleInfoShowPanel:HandleJob");
    UnpackLinkConfig("100@6")
    --BrocastModelEvent()
end

function RoleInfoShowPanel:HandleTitle()
    --OpenLink()
    --print2("RoleInfoShowPanel:HandleTitle");
    local num = #Config.db_fashion_type
    num = num + 1
    UnpackLinkConfig("240@1@" .. num)
    --TitleController:GetInstance():RequestTitleInfo()
end
--觉醒
function RoleInfoShowPanel:HandleWake()
    GlobalEvent:Brocast(WakeEvent.OpenWakePanel)
end
--世界经验
function RoleInfoShowPanel:HandleWorld()
    lua_panelMgr:GetPanelOrCreate(WorldLevelPanel):Open()
end

function RoleInfoShowPanel:HandleEditName()
    --print2("RoleInfoShowPanel:HandleEditName");
    lua_panelMgr:GetPanelOrCreate(RoleReNamePanel):Open(2)
end

function RoleInfoShowPanel:HandleHeart()
    --print2("RoleInfoShowPanel:HandleHeart");
end

--头衔红点
function RoleInfoShowPanel:CheckJobTitleIconRD()
    self:SetJobTitleRedDot(self.model.is_show_jobtitle_rd)
end

function RoleInfoShowPanel:SetJobTitleRedDot(isShow)
    if not self.jt_red_dot then
        self.jt_red_dot = RedDot(self.job_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.jt_red_dot:SetPosition(0, 0)
    self.jt_red_dot:SetRedDotParam(isShow)
end

--时装红点
function RoleInfoShowPanel:CheckFashionIconRD()
    self:SetFashionIconRD(self.model.is_show_fashion_rd)
end

function RoleInfoShowPanel:SetFashionIconRD(isShow)
    if not self.fashion_rd then
        self.fashion_rd = RedDot(self.fashion_rd_con, nil, RedDot.RedDotType.Nor)
    end
    self.fashion_rd:SetPosition(0, 0)
    self.fashion_rd:SetRedDotParam(isShow)
end

--改名
function RoleInfoShowPanel:RoleReName(name)
    self.role_name.text = name
end

function RoleInfoShowPanel:UpdateJob()
    local mainrole_data = RoleInfoModel.GetInstance():GetMainRoleData();
    if mainrole_data then
        self.jobTex = GetText(self.job);
        self.jobOutline = self.job:GetComponent('Outline')
        local job_level = mainrole_data.figure.jobtitle and mainrole_data.figure.jobtitle.model or 0
        local config = Config.db_jobtitle[job_level]
        if config then
            self.jobTex.text = config.name
            local r, g, b, a = HtmlColorStringToColor(config.color)
            SetOutLineColor(self.jobOutline, r, g, b, a)
        else
            self.jobTex.text = "";
        end
    end
end
