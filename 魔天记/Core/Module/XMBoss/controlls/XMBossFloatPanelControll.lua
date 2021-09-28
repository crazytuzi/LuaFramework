

XMBossFloatPanelControll = class("XMBossFloatPanelControll");

XMBossFloatPanelControll.MESSAGE_XMBOSS_FBOVER = "MESSAGE_XMBOSS_FBOVER";

function XMBossFloatPanelControll:New()
    self = { };
    setmetatable(self, { __index = XMBossFloatPanelControll });
    return self
end


function XMBossFloatPanelControll:Init(gameObject)
    self.gameObject = gameObject;

    self.joinPlayerNumTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "joinPlayerNumTxt");
    self.useTimeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "useTimeTxt");
    self.bossNameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "bossNameTxt");
    self.bosslvTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "bosslvTxt");

    self.imgIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgIcon");
    self.xmBossHpCt = UIUtil.GetChildByName(self.gameObject, "UISprite", "sliderHP/Foreground");

    self.seeJoinPlayerBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "seeJoinPlayerBt");


    self.boxBt1 = UIUtil.GetChildByName(self.gameObject, "UIButton", "boxBt1");
    self.boxBt2 = UIUtil.GetChildByName(self.gameObject, "UIButton", "boxBt2");
    self.boxBt3 = UIUtil.GetChildByName(self.gameObject, "UIButton", "boxBt3");

    self._onClickSeeJoinPlayerBt = function(go) self:_OnClickSeeJoinPlayerBt(self) end
    UIUtil.GetComponent(self.seeJoinPlayerBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickSeeJoinPlayerBt);

    --[[
    self._onClickBoxBt1 = function(go) self:_OnClickBoxBt1(self) end
    UIUtil.GetComponent(self.boxBt1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBoxBt1);

    self._onClickBoxBt2 = function(go) self:_OnClickBoxBt2(self) end
    UIUtil.GetComponent(self.boxBt2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBoxBt2);

    self._onClickBoxBt3 = function(go) self:_OnClickBoxBt3(self) end
    UIUtil.GetComponent(self.boxBt3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBoxBt3);
    ]]

    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETFB_ELSETIME, XMBossFloatPanelControll.FBElseTimeChange, self);
    MessageManager.AddListener(XMBossFloatPanelControll, XMBossFloatPanelControll.MESSAGE_XMBOSS_FBOVER, XMBossFloatPanelControll.GameOver, self);

    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_HP_CHANGE, XMBossFloatPanelControll.BossHpChange, self);

    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_MAO_JOININFO, XMBossFloatPanelControll.MapJoint, self);

    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_BOX_CHANGE, XMBossFloatPanelControll.BoxChange, self);

    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETJOINNUM_COMPLETE, XMBossFloatPanelControll.BossJoinNumHandler, self);

    self.getJoinNumTime = 15;
    self.hasGetFBElseTime = false;


end


function XMBossFloatPanelControll:_OnClickSeeJoinPlayerBt()

    ModuleManager.SendNotification(XMBossNotes.OPEN_XMBOSSJOININFOSPANEL);
end

function XMBossFloatPanelControll:_OnClickBoxBt1()

    self:TryGetBox(1);
end

function XMBossFloatPanelControll:_OnClickBoxBt2()

    self:TryGetBox(2);
end

function XMBossFloatPanelControll:_OnClickBoxBt3()

    self:TryGetBox(3);
end

--
--  self["boxBt"..obj.idx.."info"] = obj;

function XMBossFloatPanelControll:TryGetBox(idx)

    local s = self["boxBt" .. idx .. "info"].s;

    XMBossProxy.TryGetXMBossBox(idx);

end



function XMBossFloatPanelControll:Show()
    SetUIEnable(self.gameObject.transform, true)

    --    self.gameObject.gameObject:SetActive(true);
    self.showing = true;

    XMBossProxy.TryGetXMBossMapInfo();

    if not self.hasGetFBElseTime then
        XMBossProxy.TryGetXMBossFB_ElseTime();
    end


end

function XMBossFloatPanelControll:Close()
    SetUIEnable(self.gameObject.transform, false)

    --    self.gameObject.gameObject:SetActive(false);
    self.showing = false;

end

--[[
06 进入副本获取boss信息，宝箱信息
输入：
输出：
mid：怪物defId
hp：当前血量
mhp：最大血量
lv：当前等级
chest：{[idx:下标，s:状态（0：没有获得，1：获得，2：领取）]}


 S <-- 11:29:58.040, 0x1606, 24, {"mid":125001,"chest":[{"s":0,"idx":2},{"s":0,"idx":1},{"s":0,"idx":3}],"hp":57000,"mhp":114000,"lv":1}

]]
function XMBossFloatPanelControll:MapJoint(data)

    local mid = data.mid;
    local hp = data.hp;
    local mhp = data.mhp;
    local lv = data.lv;
    local num = data.num;
    -- 参战人数

    local minCf = ConfigManager.GetMonById(mid);

    self.imgIcon.spriteName = "" .. data.mid;
    self.bossNameTxt.text = minCf.name;
    self.bosslvTxt.text = "" .. lv;
    self.joinPlayerNumTxt.text = LanguageMgr.Get("XMBoss/XMBossFloatPanelControll/label1") .. num;

    self.xmBossHpCt.width =(hp / mhp) * 180;

    local chest = data.chest;

    local t_num = table.getn(chest);
    for i = 1, t_num do
        local obj = chest[i];
        self["boxBt" .. obj.idx].normalSprite = "box" .. obj.s;
        self["boxBt" .. obj.idx .. "info"] = obj;
    end

end

-- {idx=obj.idx,s=obj.s}
function XMBossFloatPanelControll:BoxChange(data)

    local idx = data.idx;
    local s = data.s;
    self["boxBt" .. idx].normalSprite = "box" .. s;
    self["boxBt" .. idx .. "info"] = data;


end


--[[
05 活动boss血量改变（服务器发出）
输出：
mid：怪物defId
hp：当前血量
mhp：最大血量

]]
function XMBossFloatPanelControll:BossHpChange(data)

    local mid = data.mid;
    local hp = data.hp;
    local mhp = data.mhp;
    local lv = data.lv;

    local monsterCf = ConfigManager.GetMonById(mid);


    self.bosslvTxt.text = lv;

    local pc = hp / mhp;

    if hp == 0 then

        if XMBossDataManager.tong_monsterCf[1].monster_id == mid then
            mid = XMBossDataManager.tong_monsterCf[2].monster_id;
            monsterCf = ConfigManager.GetMonById(mid);
            pc = 1;
        elseif XMBossDataManager.tong_monsterCf[2].monster_id == mid then
            mid = XMBossDataManager.tong_monsterCf[3].monster_id;
            monsterCf = ConfigManager.GetMonById(mid);
            pc = 1;
        end

    end

    self.xmBossHpCt.width = pc * 180;
    self.bossNameTxt.text = monsterCf.name;
    self.imgIcon.spriteName = "" .. mid;

end

function XMBossFloatPanelControll:BossJoinNumHandler(data)

    self.joinPlayerNumTxt.text = LanguageMgr.Get("XMBoss/XMBossFloatPanelControll/label1") .. data.n;

end

function XMBossFloatPanelControll:FBElseTimeChange(finishTimeStamp)


    self.hasGetFBElseTime = true;

    self.FB_gameOver = false;
    self._finishTimeStamp = finishTimeStamp
    self._fb_else_totalTime = self._finishTimeStamp - GetTime();

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    if self._fb_else_totalTime > 0 then

        self.FB_gameOver = false;

        self._sec_timer = Timer.New( function()

            if not self.showing then
                return;
            end


            local tstr = GetTimeByStr1(self._fb_else_totalTime);
            self._fb_else_totalTime = self._finishTimeStamp - GetTime();

            self.useTimeTxt.text = tstr;
            -- 倒计时:
            self.getJoinNumTime = self.getJoinNumTime - 1;

            if self.getJoinNumTime == 0 then
                XMBossProxy.GetXMBossFBJoinNum();
                self.getJoinNumTime = 15;
            end

            if self._fb_else_totalTime < 0 or self.FB_gameOver == true then
                if self._sec_timer ~= nil then
                    self._sec_timer:Stop();
                    self._sec_timer = nil;
                    self.FB_gameOver = true;
                end
            end

        end , 1, self._fb_else_totalTime + 10, false);
        self._sec_timer:Start();
    end

end

function XMBossFloatPanelControll:GameOver()
    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end
    self.FB_gameOver = true;
end

function XMBossFloatPanelControll:Dispose()


    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    UIUtil.GetComponent(self.seeJoinPlayerBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --[[
    UIUtil.GetComponent(self.boxBt1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.boxBt2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.boxBt3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    ]]

    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETJOINNUM_COMPLETE, XMBossFloatPanelControll.BossJoinNumHandler);

    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETFB_ELSETIME, XMBossFloatPanelControll.FBElseTimeChange);
    MessageManager.RemoveListener(XMBossFloatPanelControll, XMBossFloatPanelControll.MESSAGE_XMBOSS_FBOVER, XMBossFloatPanelControll.GameOver);
    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_HP_CHANGE, XMBossFloatPanelControll.BossHpChange);

    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_MAO_JOININFO, XMBossFloatPanelControll.MapJoint);

    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_BOX_CHANGE, XMBossFloatPanelControll.BoxChange);


    self.gameObject = nil;

    self.joinPlayerNumTxt = nil;
    self.useTimeTxt = nil;
    self.bossNameTxt = nil;
    self.bosslvTxt = nil;

    self.imgIcon = nil;
    self.xmBossHpCt = nil;

    self.seeJoinPlayerBt = nil;


    self.boxBt1 = nil;
    self.boxBt2 = Unil;
    self.boxBt3 = nil;


end