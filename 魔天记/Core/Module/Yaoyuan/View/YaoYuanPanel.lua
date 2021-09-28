require "Core.Module.Common.Panel"

require "Core.Module.Yaoyuan.controlls.MyInfoPanelControll"
require "Core.Module.Yaoyuan.controlls.ShouHuPalyerControll"
require "Core.Module.Yaoyuan.controlls.YuanZhuInfoPanelControll"

require "Core.Module.Yaoyuan.controlls.FarmsControll"

YaoYuanPanel = class("YaoYuanPanel", Panel);
YaoYuanPanel.curr_info = nil;

function YaoYuanPanel:New()
    self = { };
    setmetatable(self, { __index = YaoYuanPanel });
    return self
end


function YaoYuanPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function YaoYuanPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
     self.btn_gotoheCheng = UIUtil.GetChildInComponents(btns, "btn_gotoheCheng");

    self._btn_myXM = UIUtil.GetChildInComponents(btns, "btn_myXM");
    self._btn_diFangXM = UIUtil.GetChildInComponents(btns, "btn_diFangXM");
    self._btn_yijianshouhuo = UIUtil.GetChildInComponents(btns, "btn_yijianshouhuo");
    self.btn_yijintouqu = UIUtil.GetChildInComponents(btns, "btn_yijintouqu");
    self.btn_yijianjiaoshui = UIUtil.GetChildInComponents(btns, "btn_yijianjiaoshui");

    self._btn_zhongziStop = UIUtil.GetChildInComponents(btns, "btn_zhongziStop");
    self._btn_zhongzicangku = UIUtil.GetChildInComponents(btns, "btn_zhongzicangku");
    self._btn_yaoyuanjilu = UIUtil.GetChildInComponents(btns, "btn_yaoyuanjilu");

    self.btn_myYaoYuan = UIUtil.GetChildInComponents(btns, "btn_myYaoYuan");

    self._btn_myXM_label = UIUtil.GetChildByName(self._btn_myXM, "UILabel", "Label");
    self._btn_diFangXM_label = UIUtil.GetChildByName(self._btn_diFangXM, "UILabel", "Label");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");
    self.shouHuAdd = UIUtil.GetChildByName(self.mainView, "Transform", "shouHuAdd");
    self.addicon = UIUtil.GetChildByName(self.shouHuAdd, "Transform", "addicon");

    self.hasNotYaoQingTip = UIUtil.GetChildByName(self.mainView, "UILabel", "hasNotYaoQingTip");


    self.shouHuPalyer = UIUtil.GetChildByName(self.mainView, "Transform", "shouHuPalyer");
    self.myInfoPanel = UIUtil.GetChildByName(self.mainView, "Transform", "myInfoPanel");
    self.yuanZhuInfoPanel = UIUtil.GetChildByName(self.mainView, "Transform", "yuanZhuInfoPanel");

    self.farms = UIUtil.GetChildByName(self.mainView, "Transform", "farms");

    self.shouHuPalyerControll = ShouHuPalyerControll:New();
    self.myInfoPanelControll = MyInfoPanelControll:New();
    self.yuanZhuInfoPanelControll = YuanZhuInfoPanelControll:New();



    self.farmsCtr = FarmsControll:New();

    self.shouHuPalyerControll:Init(self.shouHuPalyer);
    self.myInfoPanelControll:Init(self.myInfoPanel);
    self.yuanZhuInfoPanelControll:Init(self.yuanZhuInfoPanel);

    self.farmsCtr:Init(self.farms);

    self._onAddicon = function(go) self:_OnAddicon(self) end
    UIUtil.GetComponent(self.addicon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onAddicon);

    MessageManager.AddListener(FarmsDataManager, FarmsDataManager.MESSAGE_FARMS_DATA_CHANGE, YaoYuanPanel.FarmsDataChange, self);

    MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_XIANMEN_INFO_COMPLETE, YaoYuanPanel.JoinOtherFrams, self);



    MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_SHOUHU_TJ, YaoYuanPanel.Rec_shouhu_tj, self);

    MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_TRYGETYAOYUANJS_TY_TIME_COMPLETE, YaoYuanPanel._ttimeHandler, self);


    YaoyuanProxy.TryOpenYaoYuan();



    self._btn_zhongziStop.gameObject:SetActive(false);
    self._btn_zhongzicangku.gameObject:SetActive(false);

    self.btn_myYaoYuan.gameObject:SetActive(false);

end

function YaoYuanPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
   
   self._onClickBtn_gotoheCheng = function(go) self:_OnClickBtn_gotoheCheng(self) end
    UIUtil.GetComponent(self.btn_gotoheCheng, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_gotoheCheng);
   
   
    self._onClickBtn_myXM = function(go) self:_OnClickBtn_myXM(self) end
    UIUtil.GetComponent(self._btn_myXM, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_myXM);
    self._onClickBtn_diFangXM = function(go) self:_OnClickBtn_diFangXM(self) end
    UIUtil.GetComponent(self._btn_diFangXM, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_diFangXM);
    self._onClickBtn_yijianshouhuo = function(go) self:_OnClickBtn_yijianshouhuo(self) end
    UIUtil.GetComponent(self._btn_yijianshouhuo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_yijianshouhuo);
    self._onClickBtn_zhongziStop = function(go) self:_OnClickBtn_zhongziStop(self) end
    UIUtil.GetComponent(self._btn_zhongziStop, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_zhongziStop);
    self._onClickBtn_zhongzicangku = function(go) self:_OnClickBtn_zhongzicangku(self) end
    UIUtil.GetComponent(self._btn_zhongzicangku, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_zhongzicangku);
    self._onClickBtn_yaoyuanjilu = function(go) self:_OnClickBtn_yaoyuanjilu(self) end
    UIUtil.GetComponent(self._btn_yaoyuanjilu, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_yaoyuanjilu);


    self._onClickBtn_myYaoYuan = function(go) self:_OnClickBtn_myYaoYuan(self) end
    UIUtil.GetComponent(self.btn_myYaoYuan, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_myYaoYuan);


    self._onClickBtn_yijintouqu = function(go) self:_OnClickBtn_yijintouqu(self) end
    UIUtil.GetComponent(self.btn_yijintouqu, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_yijintouqu);

    self._onClickBtn_yijianjiaoshui = function(go) self:_OnClickBtn_yijianjiaoshui(self) end
    UIUtil.GetComponent(self.btn_yijianjiaoshui, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_yijianjiaoshui);



end




function YaoYuanPanel:_OnClickBtn_gotoheCheng()


self:_OnClickBtn_close();

  ModuleManager.SendNotification(LingYaoNotes.OPEN_LINGYAOPANEL, { selectIndex = 2 });

end

function YaoYuanPanel:_OnClickBtn_yijintouqu()

    YaoyuanProxy.TryTouQuAll(YaoYuanPanel.curr_info.pid);
end

function YaoYuanPanel:_OnClickBtn_yijianjiaoshui()

    YaoyuanProxy.TryJiaoShuiAll(YaoYuanPanel.curr_info.pid, YaoYuanPanel.YijianjiaoshuiHandler, self);

end

--[[
10 一键浇水
输出：
id:对方玩家ID
输出：
farms:{[i:下标ID，s:种子ID,gt:成熟收获时间，wt：浇水次数...]}
items:[(spid,num)....]

]]

function YaoYuanPanel:YijianjiaoshuiHandler(data)

    local items = data.items;
    local farms = data.farms;

    local t_num = table.getn(farms);

    if t_num > 0 then

        MsgUtils.ShowTips("Yaoyuan/YaoYuanPanel/label1");

        -- 需要重新 拉 数据
        YaoyuanProxy.TryGetXianMenNumberInfo(YaoYuanPanel.curr_info.pid, YaoyuanProxy.NUMBER_INFO_TYPE_1, YaoYuanPanel.curr_info)

    end

end

--[[
 S <-- 14:28:06.265, 0x1413, 19, {"sts":1,"wt":0}
]]
function YaoYuanPanel:_ttimeHandler(data)

    local sts = data.sts;
    local wt = data.wt;

    FarmsDataManager.sts = sts;
    FarmsDataManager.wt = wt;

    local fpcf = FarmsDataManager.GetFarmBaseConfig();

    FarmsDataManager.jiaoshuiElseTime =(fpcf.water_times - wt) .. "/" .. fpcf.water_times;
    FarmsDataManager.touyaoElseTime =(fpcf.stolen_times - sts) .. "/" .. fpcf.stolen_times;

    FarmsDataManager.jiaoshuiElse = fpcf.water_times - wt;
    FarmsDataManager.touyaoElse = fpcf.stolen_times - sts;

    self._btn_myXM_label.text = LanguageMgr.Get("Yaoyuan/YaoYuanPanel/label2") ..(fpcf.water_times - wt) .. "/" .. fpcf.water_times;
    self._btn_diFangXM_label.text = LanguageMgr.Get("Yaoyuan/YaoYuanPanel/label3") ..(fpcf.stolen_times - sts) .. "/" .. fpcf.stolen_times;

    self.farmsCtr:UpInfos();

end




function YaoYuanPanel:_OnAddicon()
    ModuleManager.SendNotification(YaoyuanNotes.OPEN_YAOYUANMYXIANMENYAOQINGPANEL);

end



function YaoYuanPanel:FarmsDataChange()

    self:SetData(FarmsDataManager.farms);

    -- 这个 自己的 农场

    self.yuanZhuInfoPanelControll:Hide();
    self.myInfoPanelControll:SetData(self.pf);
end

--[[

 S <-- 14:33:06.106, 0x1404, 17, {"farms":[{"st":0,"gt":0,"s":"","wt":0,"i":2},{"st":0,"gt":0,"s":"","wt":0,"i":4},
 {"st":0,"gt":0,"s":"","wt":0,"i":1},{"st":0,"gt":0,"s":"","wt":0,"i":3}],
 "gp":{"n":"\u59DC\u5FD7\u6613","pid":"20100003","l":48,"c":101000},
 "pf":{"e":3,"st":1470358860000,"gts":1,"sts":0,"odd":85,"gt":19468,"wt":0,"l":1,"gpi":"20100003"}}

]]
-- 进入 其他人的 药园
function YaoYuanPanel:JoinOtherFrams(data)

    --[[
   --wts= [0]
--n= [任亦涵]
--l= [99]
--c= [0]
--pid= [20100341]
   ]]

    local hinfo = data.hinfo;
    local type = data.type;

    self.type = type;

    local farms = data.farms;


    YaoYuanPanel.curr_info = hinfo;

    self.yuanZhuInfoPanelControll:SetData(hinfo, data.pf);

    self.farmsCtr:SetData(farms, type);

    if type == YaoyuanProxy.NUMBER_INFO_TYPE_1 then
        -- 我的仙盟 药园

        MessageManager.Dispatch(YaoYuanMyXianMenPanel, YaoYuanMyXianMenPanel.MESSAGE_TRY_CLOSE_YAOYUANMYXIANMENPANEL);

        self._btn_yijianshouhuo.gameObject:SetActive(false);
        self.btn_yijintouqu.gameObject:SetActive(false);
        self.btn_yijianjiaoshui.gameObject:SetActive(true);

        local gp = data.gp;
        local sdata = { name = gp.n, l = gp.l, c = gp.c, pf = data.pf };

        self:Rec_otherShouhu_tj(sdata);

    elseif type == YaoyuanProxy.NUMBER_INFO_TYPE_2 then
        -- 敌对仙盟 药园

        MessageManager.Dispatch(YaoYuanDiFangXianMenPanel, YaoYuanDiFangXianMenPanel.MESSAGE_TRY_CLOSE_YAOYUANDIFANGXIANMENPANEL);
        self._btn_yijianshouhuo.gameObject:SetActive(false);
        self.btn_yijintouqu.gameObject:SetActive(true);
        self.btn_yijianjiaoshui.gameObject:SetActive(false);

        local gp = data.gp;
        local sdata = { name = gp.n, l = gp.l, c = gp.c, pf = data.pf };

        self:Rec_otherShouhu_tj(sdata);

    end

    self.btn_myYaoYuan.gameObject:SetActive(true);
    self._btn_zhongziStop.gameObject:SetActive(false);
    self._btn_zhongzicangku.gameObject:SetActive(false);

end
--[[
S <-- 17:49:49.265, 0x140C, 0, {"name":"\u5211\u5E38\u575A","pf":{"e":0,"st":1470190475000,"gts":0,"sts":0,"odd":300000,"gt":1470314952691,"wt":0,"l":1},"f":1,"id":"20100002"}

]]

function YaoYuanPanel:Rec_shouhu_tj(data)

    local pf = data.pf;
    local gt = pf.gt;

    self.hasNotYaoQingTip.gameObject:SetActive(false);

    if gt > 0 then
        self.shouHuAdd.gameObject:SetActive(false);
        self.shouHuPalyer.gameObject:SetActive(true);
        self.shouHuPalyerControll:SetData(data, YaoYuanPanel.ShouhuComplete, self)

    else
        self.shouHuAdd.gameObject:SetActive(true);
        self.shouHuPalyer.gameObject:SetActive(false);
    end
end

--[[

进入其他人药园时的显示守护时间
]]
function YaoYuanPanel:Rec_otherShouhu_tj(data)

    self.shouHuAdd.gameObject:SetActive(false);

    local pf = data.pf;
    local gt = pf.gt;

    if gt > 0 then
        self.shouHuPalyer.gameObject:SetActive(true);
        self.shouHuPalyerControll:SetData(data, YaoYuanPanel.ShouhuComplete, self)
        self.hasNotYaoQingTip.gameObject:SetActive(false);
    else
        self.shouHuPalyer.gameObject:SetActive(false);
        self.hasNotYaoQingTip.gameObject:SetActive(true);
    end


end


function YaoYuanPanel:ShouhuComplete()

    self.shouHuAdd.gameObject:SetActive(true);
    self.shouHuPalyer.gameObject:SetActive(false);

end

--[[

{"farms":[{"st":0,"gt":0,"s":"","wt":0,"i":2},{"st":0,"gt":0,"s":"","wt":0,"i":4},
{"st":0,"gt":0,"s":"","wt":0,"i":1},{"st":0,"gt":0,"s":"","wt":0,"i":3}],

"gp":{"n":"\u59DC\u5FD7\u6613","pid":"20100003","l":48,"c":101000},
"pf":{"e":3,"st":1470358860000,"gts":1,"sts":0,"odd":85,"gt":28789,"wt":0,"l":1,"gpi":"20100003"}}


]]
function YaoYuanPanel:SetData(data)


    self.type = YaoyuanProxy.NUMBER_INFO_TYPE_0;

    self.farms = data.farms;
    self.pf = data.pf;

    self.farmsCtr:SetData(self.farms, YaoyuanProxy.NUMBER_INFO_TYPE_0);

    self._btn_yijianshouhuo.gameObject:SetActive(true);
    self.btn_yijintouqu.gameObject:SetActive(false);
    self.btn_yijianjiaoshui.gameObject:SetActive(false);

    -- self.shouHuAdd
    local gt = self.pf.gt;

    FarmsDataManager.sts = self.pf.sts;
    FarmsDataManager.wt = self.pf.wt;

    local fpcf = FarmsDataManager.GetFarmBaseConfig();

    FarmsDataManager.jiaoshuiElseTime =(fpcf.water_times - self.pf.wt) .. "/" .. fpcf.water_times;
    FarmsDataManager.touyaoElseTime =(fpcf.stolen_times - self.pf.sts) .. "/" .. fpcf.stolen_times;

    FarmsDataManager.jiaoshuiElse = fpcf.water_times - self.pf.wt;
    FarmsDataManager.touyaoElse = fpcf.stolen_times - self.pf.sts;

    self._btn_myXM_label.text = LanguageMgr.Get("Yaoyuan/YaoYuanPanel/label2") ..(fpcf.water_times - self.pf.wt) .. "/" .. fpcf.water_times;
    self._btn_diFangXM_label.text = LanguageMgr.Get("Yaoyuan/YaoYuanPanel/label3") ..(fpcf.stolen_times - self.pf.sts) .. "/" .. fpcf.stolen_times;

    if gt > 0 then
        self.shouHuAdd.gameObject:SetActive(false);
        self.shouHuPalyer.gameObject:SetActive(true);

        --[[
        S <-- 10:35:35.330, 0x140C, 0, {"name":"\u59DC\u5FD7\u6613","l":48,"c":101000,"pf":{"e":4,"st":6921,"gts":1,"sts":0,"odd":0,"gt":0,"wt":0,"l":1,"gpi":""},"f":1,"id":"20100003"}

        ]]
        local gp = data.gp;
        local sdata = { name = gp.n, l = gp.l, c = gp.c, pf = self.pf };
        self.shouHuPalyerControll:SetData(sdata, YaoYuanPanel.ShouhuComplete, self)
    else
        self.shouHuAdd.gameObject:SetActive(true);
        self.shouHuPalyer.gameObject:SetActive(false);
    end

    self.btn_myYaoYuan.gameObject:SetActive(false);
    self._btn_zhongziStop.gameObject:SetActive(true);
    self._btn_zhongzicangku.gameObject:SetActive(true);
    self.hasNotYaoQingTip.gameObject:SetActive(false);


end

--[[
去到别人的药园， 然后回到 自己的药园
]]
function YaoYuanPanel:_OnClickBtn_myYaoYuan()

    YaoyuanProxy.TryOpenYaoYuan();
end

function YaoYuanPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(YaoyuanNotes.CLOSE_YAOYUANROOTPANEL);
end

function YaoYuanPanel:_OnClickBtn_myXM()
    ModuleManager.SendNotification(YaoyuanNotes.OPEN_YAOYUANMYXIANMENPANEL);
end

function YaoYuanPanel:_OnClickBtn_diFangXM()
    ModuleManager.SendNotification(YaoyuanNotes.OPEN_YAOYUANDIFANGXIANMENPANEL);
end

function YaoYuanPanel:_OnClickBtn_yijianshouhuo()

    YaoyuanProxy.TryHarvestAll();
end

function YaoYuanPanel:_OnClickBtn_yaoyuanjilu()
    ModuleManager.SendNotification(YaoyuanNotes.OPEN_YAOYUANJILUPANEL);
end

function YaoYuanPanel:_OnClickBtn_zhongziStop()
    ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, {type = TShopNotes.Shop_type_zhongzhi});
end

function YaoYuanPanel:_OnClickBtn_zhongzicangku()
    ModuleManager.SendNotification(YaoyuanNotes.OPEN_ZHONGZHICANGKUPANEL);
end

function YaoYuanPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function YaoYuanPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

   
    UIUtil.GetComponent(self.btn_gotoheCheng, "LuaUIEventListener"):RemoveDelegate("OnClick");
     self._onClickBtn_gotoheCheng  = nil;

    UIUtil.GetComponent(self._btn_myXM, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_myXM = nil;
    UIUtil.GetComponent(self._btn_diFangXM, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_diFangXM = nil;
    UIUtil.GetComponent(self._btn_yijianshouhuo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_yijianshouhuo = nil;
    UIUtil.GetComponent(self._btn_zhongziStop, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_zhongziStop = nil;
    UIUtil.GetComponent(self._btn_zhongzicangku, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_zhongzicangku = nil;
    UIUtil.GetComponent(self._btn_yaoyuanjilu, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_yaoyuanjilu = nil;

    UIUtil.GetComponent(self.addicon, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onAddicon = nil;


    UIUtil.GetComponent(self.btn_myYaoYuan, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_myYaoYuan = nil;



    UIUtil.GetComponent(self.btn_yijintouqu, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btn_yijianjiaoshui, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onClickBtn_yijintouqu = nil;
    self._onClickBtn_yijianjiaoshui = nil;

end

function YaoYuanPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_myXM = nil;
    self._btn_diFangXM = nil;
    self._btn_yijianshouhuo = nil;
    self._btn_zhongziStop = nil;
    self._btn_zhongzicangku = nil;
    self._btn_yaoyuanjilu = nil;

    YaoYuanPanel.curr_info = nil;

    self.shouHuPalyerControll:Dispose();
    self.myInfoPanelControll:Dispose();
    self.yuanZhuInfoPanelControll:Dispose();

    self.farmsCtr:Dispose();

    MessageManager.RemoveListener(FarmsDataManager, FarmsDataManager.MESSAGE_FARMS_DATA_CHANGE, YaoYuanPanel.FarmsDataChange);
    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_XIANMEN_INFO_COMPLETE, YaoYuanPanel.JoinOtherFrams);



    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_SHOUHU_TJ, YaoYuanPanel.Rec_shouhu_tj);

    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_TRYGETYAOYUANJS_TY_TIME_COMPLETE, YaoYuanPanel._ttimeHandler);



    self._btn_zhongziStop = nil;
    self._btn_zhongzicangku = nil;
    self._btn_yaoyuanjilu = nil;

    self.btn_myYaoYuan = nil;

    self._btn_myXM_label = nil;
    self._btn_diFangXM_label = nil;

    self.mainView = nil;
    self.shouHuAdd = nil;
    self.addicon = nil;

    self.hasNotYaoQingTip = nil;


    self.shouHuPalyer = nil;
    self.myInfoPanel = nil;
    self.yuanZhuInfoPanel = nil;

    self.farms = nil;

    self.shouHuPalyerControll = nil;
    self.myInfoPanelControll = nil;
    self.yuanZhuInfoPanelControll = nil;

    self.farmsCtr = nil;

end
