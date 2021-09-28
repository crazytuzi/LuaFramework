XLTRightPanelControll = class("XLTRightPanelControll");

function XLTRightPanelControll:New()
    self = { };
    setmetatable(self, { __index = XLTRightPanelControll });
    return self
end


function XLTRightPanelControll:Init(gameObject, parent)
    self.gameObject = gameObject;
    self.parent = parent;
    self.txtPower = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtPower");


    -- self.valueTxt2 = UIUtil.GetChildByName(self.gameObject, "UILabel", "valueTxt2");
    -- self.valueTxt3 = UIUtil.GetChildByName(self.gameObject, "UILabel", "valueTxt3");

    -- self.valueTxt10 = UIUtil.GetChildByName(self.gameObject, "UILabel", "valueTxt10");
    -- self.valueTxt11 = UIUtil.GetChildByName(self.gameObject, "UILabel", "valueTxt11");

    self.txttonguanLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "txttonguanLabel");

    self.lock = UIUtil.GetChildByName(self.gameObject, "UISprite", "lock");
    self.mingXingIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "mingXingIcon");
    self.mingXingName = UIUtil.GetChildByName(self.gameObject, "UILabel", "mingXingName");

    self.txtXinweiLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtXinweiLabel");

    self.txt_allActive = UIUtil.GetChildByName(self.gameObject, "UILabel", "txt_allActive");

    self.xingmBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "xingmBg");
    self.xingmCbg = UIUtil.GetChildByName(self.gameObject, "UISprite", "xingmCbg");

    -- self.txtRealm = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtRealm");
    -- self.txtFaity = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtFaity");

    self.products = { };
    self.productCtrs = { };

    for i = 1, 2 do
        self.products[i] = UIUtil.GetChildByName(self.gameObject, "Transform", "product" .. i);
        self.productCtrs[i] = ProductCtrl:New();
        self.productCtrs[i]:Init(self.products[i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)
        self.productCtrs[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end

    self.tiaozhanBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "tiaozhanBt");
    -- self.daodangBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "daodangBt");

    -- self.daodangBtLabel = UIUtil.GetChildByName(self.daodangBt, "UILabel", "Label");
    -- self.daodangBt_npoint = UIUtil.GetChildByName(self.daodangBt, "UISprite", "npoint");


    self._onClicktiaozhanBt = function(go) self:_OnClicktiaozhanBt(self) end
    UIUtil.GetComponent(self.tiaozhanBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClicktiaozhanBt);

    --[[
    self._onClickdaodangBt = function(go) self:_OnClickdaodangBt(self) end
    UIUtil.GetComponent(self.daodangBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickdaodangBt);
    ]]
    MessageManager.AddListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_INFOCHANGE, XLTRightPanelControll.SaodandInfoChange, self);

    MessageManager.AddListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_SAO_DANG_COMPLETE, XLTRightPanelControll.SaoDangComplete, self);

    self.elsePlayTime = 0;
    self.taoZhancheckBoxSelected = false;
    self.saoDangcheckBoxSelected = false;

    -- self.daodangBt_npoint.gameObject:SetActive(false);

end

function XLTRightPanelControll:SaoDangComplete()
    MessageManager.Dispatch(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS);
end

--[[
13 获取虚灵塔扫荡进度
输出：
t:剩余时间（-1：标示没有进行扫荡，0：可以领取奖励，大于1：扫荡剩余时间）
0x0F13

]]
function XLTRightPanelControll:SaodandInfoChange(data)


    self.elseTime = data.t;
    self.sn = data.sn;
    --[[
   -- self.daodangBt_npoint.gameObject:SetActive(false);

    if self.elseTime == -1 then
        self.elseTime = -1;
      --  self.daodangBtLabel.text = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label1");

    elseif self.elseTime == 0 then
       -- self.daodangBtLabel.text = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label2");
       -- self.daodangBt_npoint.gameObject:SetActive(true);
    elseif self.elseTime > 0 then

      --  self.daodangBtLabel.text = GetTimeByStr1(self.elseTime);

        if (self._sec_timer) then
            self._sec_timer:Stop()
            self._sec_timer = nil
        end
        self._sec_timer = Timer.New( function()

            self.elseTime = self.elseTime - 1;
           -- self.daodangBtLabel.text = GetTimeByStr1(self.elseTime);

            if self.elseTime <= 0 then
                if self._sec_timer ~= nil then
                    self._sec_timer:Stop();
                    self._sec_timer = nil;
                end
               -- self.daodangBtLabel.text = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label2");
                self.elseTime = 0;
              --  self.daodangBt_npoint.gameObject:SetActive(true);

            end
        end , 1, self.elseTime, false);
        self._sec_timer:Start();

    end

    ]]
    if self.sn ~= nil and self.parent ~= nil then



        InstanceDataManager.UpData(XLTInstancePanel.GetFbLog, self.parent);

    end

end

function XLTRightPanelControll:ResetResluatTaoZhanHandler(data)


    local my_money = MoneyDataManager.Get_gold();
    if my_money < 30 then
        -- iii.仙玉不足时，点击“重置次数”按钮，系统提示：仙玉不足！提示文字红色显示
        MsgUtils.ShowTips("common/xianyubuzu");
    else
        self.taoZhancheckBoxSelected = data.checkBoxSelected;

        local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
        local firstFb = bfCflist[1];

        XLTInstanceProxy.XLTReSetTaoZhanTime(firstFb.id)
    end

end

function XLTRightPanelControll:_OnClicktiaozhanBt()

    if self.hasAllPass then
        MsgUtils.ShowTips("XLTInstance/XLTRightPanelControll/label5");
        return;
    end

    if FBMLTItem.curr_can_play_fb ~= nil then
        local obj = FBMLTItem.curr_can_play_fb;

        if obj.canPlay then
            -- 进入 副本

            self.data = obj.data;

            -- 进入副本
            ModuleManager.SendNotification(XLTInstanceNotes.CLOSE_XLTINSTANCE_PANEL);
            ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

            local tx = SceneInfosGetManager.Get_ins():GetRandom(self.data.position_x);
            local ty = 0;
            local tz = SceneInfosGetManager.Get_ins():GetRandom(self.data.position_z);

            local toScene = { };
            toScene.sid = self.data.map_id;
            toScene.position = Convert.PointFromServer(tx, ty, tz);
            toScene.rot = self.data.toward + 0;

            -- GameSceneManager.to = toScene;
            GameSceneManager.GotoScene(self.data.map_id, nil, to);

            SequenceManager.TriggerEvent(SequenceEventType.Guide.XLT_TIAOZHAN);

        else
            MsgUtils.ShowTips("XLTInstance/XLTRightPanelControll/label3");
        end

        --[[
        if self.elsePlayTime <= 0 then
            -- 次数不足， 需要购买
            local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
            local firstFb = bfCflist[1];


            local hasPass = InstanceDataManager.GetHasPassById(firstFb.id);

            local elseTzTime = VIPManager.GetSelfTeam_instance_Max_buy_num(firstFb.type);

            elseTzTime  = firstFb.number; -- 虚灵塔 改为直接读取 配置表次数

            log("elseTzTime "..elseTzTime);


            if hasPass ~= nil then
                elseTzTime = elseTzTime - hasPass.dt;
                 log("hasPass.dt "..hasPass.dt);
            end



            if elseTzTime > 0 then
                if self.taoZhancheckBoxSelected then
                    local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
                    local firstFb = bfCflist[1];
                    XLTInstanceProxy.XLTReSetTaoZhanTime(firstFb.id)
                else
                    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM3PANEL, {
                        title = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label6"),
                        msg = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label7"),
                        ok_Label = LanguageMgr.Get("common/ok"),
                        cance_lLabel = LanguageMgr.Get("common/cancle"),
                        hander = XLTRightPanelControll.ResetResluatTaoZhanHandler,
                        target = self,
                        data = { hideCheckBox = true }
                    } );
                end
            else
                -- 购买次数已经用完
                MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label8"));
            end



        else
            if obj.canPlay then
                -- 进入 副本

                self.data = obj.data;

                -- 进入副本
                ModuleManager.SendNotification(XLTInstanceNotes.CLOSE_XLTINSTANCE_PANEL);
                ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

                local tx = SceneInfosGetManager.Get_ins():GetRandom(self.data.position_x);
                local ty = 0;
                local tz = SceneInfosGetManager.Get_ins():GetRandom(self.data.position_z);

                local toScene = { };
                toScene.sid = self.data.map_id;
                toScene.position = Convert.PointFromServer(tx, ty, tz);
                toScene.rot = self.data.toward + 0;

                -- GameSceneManager.to = toScene;
                GameSceneManager.GotoScene(self.data.map_id, nil, to);


            else
                MsgUtils.ShowTips("XLTInstance/XLTRightPanelControll/label3");
            end
        end
        ]]


    end




end



function XLTRightPanelControll:ResetResluatSaoDangHandler(data)

    local my_money = MoneyDataManager.Get_gold();
    if my_money < 30 then
        -- iii.仙玉不足时，点击“重置次数”按钮，系统提示：仙玉不足！提示文字红色显示
        MsgUtils.ShowTips("common/xianyubuzu");
    else
        self.saoDangcheckBoxSelected = data.checkBoxSelected;

        local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
        local firstFb = bfCflist[1];

        XLTInstanceProxy.XLTReSetSaoDangTime(firstFb.id);
    end

end
--[[
function XLTRightPanelControll:_OnClickdaodangBt()

    if self.elseTime == nil then
        return;
    end

    if self.elseTime > 0 then
        MsgUtils.ShowTips("XLTInstance/XLTRightPanelControll/label4");
    elseif self.elseTime == 0 then
        -- 领取奖励
        ModuleManager.SendNotification(XLTInstanceNotes.OPEN_XLTSAODANGAWARDPANEL);
    elseif self.elseTime == -1 then
        -- 进行扫荡
        self:TrySaoDang();

    end

end
]]

function XLTRightPanelControll:TrySaoDang()

    if self.elseSaoDangTime <= 0 then
        -- 扫荡次数不足， 需要购买

        local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
        local firstFb = bfCflist[1];

        local hasPass = InstanceDataManager.GetHasPassById(firstFb.id);

        local elseTzTime = VIPManager.GetSweepNum();

        if hasPass ~= nil then

            elseTzTime = elseTzTime - hasPass.st;
        end

        if elseTzTime > 0 then
            if self.saoDangcheckBoxSelected then
                local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
                local firstFb = bfCflist[1];
                XLTInstanceProxy.XLTReSetSaoDangTime(firstFb.id);
            else
                ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM3PANEL, {
                    title = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label6"),
                    msg = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label9"),
                    ok_Label = LanguageMgr.Get("common/ok"),
                    cance_lLabel = LanguageMgr.Get("common/cancle"),
                    hander = XLTRightPanelControll.ResetResluatSaoDangHandler,
                    target = self,
                    data = { hideCheckBox = true }
                } );
            end
        else
            -- 购买次数已经用完
            MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label10"));
        end

    else

        --  local obj = FBMLTItem.curr_can_play_fb;
        --  XLTInstanceProxy.TryXLTSaoDang(obj.data.id);
        XLTInstanceProxy.TryXLTSaoDang();
    end

end

--[[
 S <-- 15:42:51.669, 0x0F01, 15, {"instReds":[{"instId":"756000","rt":0,"s":1,"t":1,"sn":0,"fr":0,"ut":12132}]}
]]
function XLTRightPanelControll:Show()

    local bfCflist = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.XuLingTaInstance, nil);
    local t_num = table.getn(bfCflist);
    local firstFb = bfCflist[1];


    self.instance_num = firstFb.sweep_num;
    local hasPlayTime = 0;
    local hasSaodangTime = 0;
    local ceng = 1;
    local next_ceng = 1;
    local saodang_buyNum = 0;

    local hasPass = InstanceDataManager.GetHasPassById(firstFb.id);
    if hasPass ~= nil then
        -- 没有 通过记录
        ceng = hasPass.s;

        if t_num > ceng then
            next_ceng = ceng + 1;
            self.hasAllPass = false;
        else

            self.hasAllPass = true;
        end


        firstFb = bfCflist[next_ceng];

        -- hasPlayTime = hasPlayTime - hasPass.t;
        -- http://192.168.0.8:3000/issues/4493
        hasPlayTime = hasPass.t;

        --[[
        if hasPass.sn ~= nil then
            hasSaodangTime = self.instance_num - hasPass.sn;
        end
        ]]
        -- http://192.168.0.8:3000/issues/4493
        if hasPass.sn ~= nil then
            hasSaodangTime = hasPass.sn;
        end

        if hasPass.st ~= nil then
            saodang_buyNum = hasPass.st;
        end

    else


    end

    self.currFbCf = firstFb;

    -- self.valueTxt1.text = ceng .. "/" .. t_num;
    -- self.valueTxt2.text = firstFb.name;
    -- self.valueTxt3.text = firstFb.need_power;
    --  self.valueTxt3.text = RealmManager.GetLastComPactConfig(ceng).quality_title

    local mxdata = nil;
    if StarManager ~= nil then
        -- 返回星命层数的解锁星命{p = productInfo, c = nextceng}
        mxdata = StarManager.GetUnLockStar(ceng);
    end


    if mxdata then
        local mxInfo = mxdata.p;
        local nextceng = mxdata.c;
        self.txttonguanLabel.text = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label20", { n = nextceng })
        if mxInfo ~= nil then
            ProductManager.SetIconSprite(self.mingXingIcon, mxInfo:GetIcon_id());
            self.mingXingName.text = mxInfo:GetName();

            self.mingXingIcon.gameObject:SetActive(true);
            self.mingXingName.gameObject:SetActive(true);
            self.lock.gameObject:SetActive(false);

            self.txtXinweiLabel.text = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label30")

        else
            self.mingXingIcon.gameObject:SetActive(false);
            self.mingXingName.gameObject:SetActive(false);
            self.lock.gameObject:SetActive(true);

            self.txtXinweiLabel.text = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label31")
        end

        self.txt_allActive.gameObject:SetActive(false);
    else

        self.txttonguanLabel.gameObject:SetActive(false);
        self.txtXinweiLabel.gameObject:SetActive(false);
        self.xingmBg.gameObject:SetActive(false);
        self.xingmCbg.gameObject:SetActive(false);
        self.lock.gameObject:SetActive(false);
        self.mingXingIcon.gameObject:SetActive(false);
        self.mingXingName.gameObject:SetActive(false);

        self.txt_allActive.gameObject:SetActive(true);

    end






    -- 我的战力
    self.txtPower.text = PlayerManager.GetSelfFightPower() .. "";

    --[[
    -- {"instReds":[{"instId":"753001","s":0,"t":0,"ut":-1}]}
-- instReds:[instId:副本ID,t:次数,s:星级,ut:通关时间，rt:重置次数]
    ]]

    local tiaozhen_buy_num = 0;

    if hasPass ~= nil then
        tiaozhen_buy_num = hasPass.dt;

    end

    -- self.valueTxt10.text = hasPlayTime .. "/" ..(firstFb.number + tiaozhen_buy_num);
    -- self.valueTxt11.text = hasSaodangTime .. "/" ..(self.instance_num + saodang_buyNum);

    local s
    local nc = RealmManager.GetMagicConfigOrNext(ceng)
    if nc >= ceng then
        local c = nc == ceng and "[00ff00]" or "[ff0000]"
        local na, sn = RealmManager.GetMagicNameAndSkillName(nc)
        s = c .. LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label11"
        , { n = nc, faity = na, sk = sn })
    else
        s = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/faityOver")
    end
    -- self.txtRealm.text = s
    nc = RealmManager.GetComPactConfigOrNext(ceng)
    if nc >= ceng then
        local c = nc == ceng and "[00ff00]" or "[ff0000]"
        local na = RealmManager.GetComPactName(nc)
        s = c .. LanguageMgr.Get("XLTInstance/XLTRightPanelControll/label12"
        , { n = nc, sk = na })
    else
        s = LanguageMgr.Get("XLTInstance/XLTRightPanelControll/realmOver")
    end
    -- self.txtFaity.text = s

    self.elsePlayTime =(firstFb.number + tiaozhen_buy_num) - hasPlayTime;
    self.elseSaoDangTime =(self.instance_num + saodang_buyNum) - hasSaodangTime;


    local drop = firstFb.drop;
    t_num = table.getn(drop);

    for i = 1, t_num do
        local dstr = drop[i];
        local drop_arr = string.split(dstr, "_");
        local products = ProductInfo:New();
        products:Init( { spId = drop_arr[1] + 0, am = drop_arr[2] + 0 });
        self.productCtrs[i]:SetData(products);
    end

    self.gameObject.gameObject:SetActive(true);
end

function XLTRightPanelControll:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function XLTRightPanelControll:Dispose()


    UIUtil.GetComponent(self.tiaozhanBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    -- UIUtil.GetComponent(self.daodangBt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onClicktiaozhanBt = nil;
    -- self._onClickdaodangBt = nil;

    MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_INFOCHANGE, XLTRightPanelControll.SaodandInfoChange);
    MessageManager.RemoveListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_SAO_DANG_COMPLETE, XLTRightPanelControll.SaoDangComplete);

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    for i = 1, 2 do
        self.productCtrs[i]:Dispose();
        self.productCtrs[i] = nil;
        self.products[i] = nil;
    end



    self.parent = nil;
    self.gameObject = nil;

    self.txtPower = nil;


    -- self.valueTxt2 = nil;
    -- self.valueTxt3 = nil;

    -- self.valueTxt10 = nil;
    -- self.valueTxt11 = nil;

    -- self.txtRealm = nil
    -- self.txtFaity = nil

    self.tiaozhanBt = nil;
    -- self.daodangBt = nil;

    -- self.daodangBtLabel = nil;


end