require "Core.Module.Broadcast.controll.BroadcastListManager"

PlantCtr = class("PlantCtr");

function PlantCtr:New()
    self = { };
    setmetatable(self, { __index = PlantCtr });
    return self
end


function PlantCtr:Init(gameObject)
    self.gameObject = gameObject;

    self.tubg = UIUtil.GetChildByName(self.gameObject, "UISprite", "tubg");
    self.plant = UIUtil.GetChildByName(self.gameObject, "UITexture", "plant");

    self.unopen_tu_tip = UIUtil.GetChildByName(self.gameObject, "Transform", "unopen_tu_tip");

    self.tipIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "tipIcon");
    self.time_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "time_txt");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.tubg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
    self.djsTime = 0;

end

function PlantCtr:Click_type0()
    if self.djsTime > 0 then

        -- MsgUtils.ShowTips("Yaoyuan/PlantCtr/label1");
        local cost = math.ceil(self.djsTime / 3600 * self.cfData.speed_cost)

        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("Yaoyuan/PlantCtr/label12"),
            msg = LanguageMgr.Get("Yaoyuan/PlantCtr/label13",{ n = cost }),

            ok_Label = LanguageMgr.Get("common/ok"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = PlantCtr.ZhijieChengshu,
            target = self,
            data = nil
        } );


    else
        -- 这里 有可能是 没有种 的田
        if self.hasPanel then
            YaoyuanProxy.TryHarvest(self.index);
        else

            if self.lock then

                -- MsgUtils.ShowTips("Yaoyuan/PlantCtr/label2");

                local cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FARM_EXTEND);
                local cost = cf[tonumber(self.idx)].cost;

                ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                    title = LanguageMgr.Get("Yaoyuan/PlantCtr/label10"),
                    msg = LanguageMgr.Get("Yaoyuan/PlantCtr/label11",{ n = cost }),

                    ok_Label = LanguageMgr.Get("common/ok"),
                    cance_lLabel = LanguageMgr.Get("common/cancle"),
                    hander = PlantCtr.OpenPanl,
                    target = self,
                    data = nil
                } );


            else
                -- 这是 一块空地
                ModuleManager.SendNotification(YaoyuanNotes.OPEN_ZHONGZHICANGKUPANEL, self.idx);

            end

        end

    end

end

function PlantCtr:ZhijieChengshu()

    YaoyuanProxy.YijianChengshu(tonumber(self.idx))
end


function PlantCtr:OpenPanl()

    YaoyuanProxy.OpenPanelForYaoyuan(tonumber(self.idx))
end

--[[
05 浇水
输入：
id:对方玩家ID
index：下标
输出：
farm:i:下标ID，s:种子ID,gt:成熟收获时间，wt：浇水次数
items:[(spid,num)....]

 S <-- 14:51:07.657, 0x1405, 18, {"farm":{"st":0,"gt":103,"s":"356030","wt":1,"i":1},"items":[{"am":1,"spId":355030},{"am":5000,"spId":1}]}

]]
function PlantCtr:JiaoShuiHandler(data)


    local farm = data.farm;
    local items = data.items;

    BroadcastListManager.Get_ins():Crean();
    BroadcastListManager.Get_ins():AddMsg(LanguageMgr.Get("Yaoyuan/PlantCtr/label3"), 50);

    local t_num = table.getn(items);

    for i = 1, t_num do
        local obj = items[i];
        local spId = obj.spId;
        local am = obj.am;
        local cf = ProductManager.GetProductById(spId);

        BroadcastListManager.Get_ins():AddMsg(LanguageMgr.Get("Yaoyuan/PlantCtr/label4", { a = am, n = cf.name }), 50);
    end

    BroadcastListManager.Get_ins():Start();


    self.data.st = farm.st;
    self.data.gt = farm.gt;
    self.data.wt = farm.wt;

    self:SetData(self.data, self.idx, self.type, true)

end

function PlantCtr:Click_type1()
    if self.djsTime > 0 then
        -- 植物还没成熟

        if self.data ~= nil then
            if self.data.wt <= 0 then
                -- 可以浇水   提示  得到你的灌溉，灵药成熟速度加快了！

                local pid = YaoYuanPanel.curr_info.pid;
                YaoyuanProxy.TryYaoYuanJiaoShui(pid, self.data.i, PlantCtr.JiaoShuiHandler, self)

            else

                MsgUtils.ShowTips("Yaoyuan/PlantCtr/label5");
            end
        end


    else
        -- 这里 有可能是 没有种 的田
        if self.hasPanel then

            MsgUtils.ShowTips("Yaoyuan/PlantCtr/label6");
        else

            if self.lock then

            else
                -- 这是 一块空地
                MsgUtils.ShowTips("Yaoyuan/PlantCtr/label7");
            end

        end

    end
end

function PlantCtr:Click_type2()


    if self.djsTime > 0 then
        -- 植物还没成熟

        MsgUtils.ShowTips("Yaoyuan/PlantCtr/label1");
    else
        -- 这里 有可能是 没有种 的田
        if self.hasPanel then
            --  已经有植物成熟了
            if self.canTouQu then
                local pid = YaoYuanPanel.curr_info.pid;
                YaoyuanProxy.TrytouQu(pid, self.data.i);

            else

                MsgUtils.ShowTips("Yaoyuan/PlantCtr/label8");
            end

        else

            if self.lock then

            else
                -- 这是 一块空地

                MsgUtils.ShowTips("Yaoyuan/PlantCtr/label9");
            end

        end

    end
end



function PlantCtr:_OnClickBtn()

    if self.type == YaoyuanProxy.NUMBER_INFO_TYPE_0 then
        self:Click_type0()
    elseif self.type == YaoyuanProxy.NUMBER_INFO_TYPE_1 then
        self:Click_type1()
    elseif self.type == YaoyuanProxy.NUMBER_INFO_TYPE_2 then
        self:Click_type2()
    end

end

function PlantCtr:FindMyIdInList(list,my_id)
   
      local t_num = table.getn(list);
            for i = 1, t_num do
             local id = tonumber(list[i]);
               if id == my_id then
                 return true;
               end
            end

   return false;
end

--[[
 {"st":0,"gt":1469160068,"s":"","wt":0,"i":3}
]]

--[[
S <-- 16:57:55.813, 0x1401, 16, {"farms":[{"st":0,"gt":1469436071,"s":"","wt":0,"i":2},{"st":0,"gt":1469436071,"s":"","wt":0,"i":4},
{"st":0,"gt":1469458621,"s":"356030","wt":0,"i":1},
{"st":0,"gt":1469436071,"s":"","wt":0,"i":3}],"pf":{"st":"2016-07-25 1

]]
function PlantCtr:SetData(data, idx, type, issetLock)

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    self.data = data;
    self.idx = idx;
    self.type = type;

    self.index = -1;

    self.djsTime=0;

    if data == nil then
        self.plant.gameObject:SetActive(false);
        self.tipIcon.gameObject:SetActive(false);
        self.time_txt.gameObject:SetActive(false);
        self.hasPanel = false;

        if issetLock then
            self:SetLock(true);
        end


    else

        local s = data.s;

        self.djsTime = data.gt;
        self.index = data.i;
        self.sp = data.sp;

        if issetLock then
            self:SetLock(false);
        end


        if s == "" then
            self.plant.gameObject:SetActive(false);
            self.tipIcon.gameObject:SetActive(false);
           
            self.time_txt.gameObject:SetActive(false);
            self.hasPanel = false;
        else
            self.hasPanel = true;
            self.cfData = FarmsDataManager.GetCfBySeed_id(s);

            self.plantStage = 0;
            self:CheckStage();

            if self.djsTime > 0 then
                self.plant.gameObject:SetActive(true);
                self.time_txt.gameObject:SetActive(true);
                self.time_txt.text = GetTimeByStr(self.djsTime);
                self.tipIcon.gameObject:SetActive(false);
                 
                if self._sec_timer ~= nil then
                    self._sec_timer:Stop();
                    self._sec_timer = nil;
                end

                if self.type == YaoyuanProxy.NUMBER_INFO_TYPE_1 then

                --  http://192.168.0.8:3000/issues/3573
                -- 需要每个人对同一块底 只能 浇水一次
                --  wt 只是表示 这块地被浇水多少次
                -- 需要修改
                  local me = HeroController:GetInstance();
                  local heroInfo = me.info;
                 local my_id = tonumber(heroInfo.id);

                 local inlist = self:FindMyIdInList(self.data.wp,my_id);
                   -- if self.data.wt <= 0 then
                   if not inlist then

                        if FarmsDataManager.jiaoshuiElse > 0 then
                            self.tipIcon.spriteName = "7";
                            self.tipIcon.gameObject:SetActive(true);
                            
                        else
                            self.tipIcon.gameObject:SetActive(false);
                            
                        end


                    else
                        self.tipIcon.gameObject:SetActive(false);
                       
                    end

                end

                self._sec_timer = Timer.New( function()

                    self.djsTime = self.djsTime - 1;
                    self.time_txt.text = GetTimeByStr(self.djsTime);

                    self:CheckStage();

                    if self.djsTime <= 0 then
                        if self._sec_timer ~= nil then
                            self._sec_timer:Stop();
                            self._sec_timer = nil;
                        end
                        self.canShouhuo = true;
                        self:CheckCS();

                        self.time_txt.gameObject:SetActive(false);


                    end
                end , 1, self.djsTime, false);
                self._sec_timer:Start();

            else
                self.plant.gameObject:SetActive(true);
                self.time_txt.gameObject:SetActive(false);

                self:CheckCS();

                self.canShouhuo = true;
            end

            self.hasPanel = true;
        end

    end


end

function PlantCtr:CheckCS()


    if self.type == YaoyuanProxy.NUMBER_INFO_TYPE_0 then
        self.tipIcon.spriteName = "9";
        self.tipIcon.gameObject:SetActive(true);

    elseif self.type == YaoyuanProxy.NUMBER_INFO_TYPE_1 then
        self.tipIcon.gameObject:SetActive(false);
    elseif self.type == YaoyuanProxy.NUMBER_INFO_TYPE_2 then

        if FarmsDataManager.touyaoElse > 0 then

            self.tipIcon.spriteName = "8";
            self.tipIcon.gameObject:SetActive(true);

        else
            self.tipIcon.gameObject:SetActive(false);

        end


        self.canTouQu = true;

        local t_num = table.getn(self.sp);
        if t_num > 0 then

            local me = HeroController:GetInstance();
            local heroInfo = me.info;
            local my_id = heroInfo.id + 0;

            for i = 1, t_num do

                local o_id = self.sp[i] + 0;
                if o_id == my_id then
                    self.tipIcon.gameObject:SetActive(false);
                    self.canTouQu = false;
                    return;
                end
            end
        end

    end


end



function PlantCtr:CheckStage()

    --  self.plantStage

    local mature_time = self.cfData.mature_time;
    -- 成熟时间
    local plant_time = self.cfData.plant_time;
    -- 种子阶段

    local gTime = mature_time - self.djsTime;
    -- 当前 成长时间



    if gTime <= plant_time then
        -- 种子阶段
        if self.plantStage ~= 1 then
            self.plantStage = 1;
            self:TryRecycleTexture();

            self._mainTexturePath = "plant/" .. self.cfData.id .. "_" .. self.plantStage;

            self.plant.mainTexture = UIUtil.GetTexture(self._mainTexturePath)

        end

    elseif gTime > plant_time and gTime <= mature_time then
        -- 成长 阶段
        if self.plantStage ~= 2 then
            self.plantStage = 2;
            self:TryRecycleTexture();
            self._mainTexturePath = "plant/" .. self.cfData.id .. "_" .. self.plantStage;

            self.plant.mainTexture = UIUtil.GetTexture(self._mainTexturePath)

        end

    else
        -- 成熟阶段
        if self.plantStage ~= 3 then

            self.plantStage = 3;
            self:TryRecycleTexture();
            self._mainTexturePath = "plant/" .. self.cfData.id .. "_" .. self.plantStage;

            self.plant.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
        end

    end


end


function PlantCtr:SetLock(v)
    self.lock = v;

    if v then

        self.tubg.spriteName = "unopen_tu";
        self.unopen_tu_tip.gameObject:SetActive(true);

    else

        self.tubg.spriteName = "open_tu";
        self.unopen_tu_tip.gameObject:SetActive(false);
    end


end

function PlantCtr:Show()




    self.gameObject.gameObject:SetActive(true);
end

function PlantCtr:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function PlantCtr:TryRecycleTexture()
    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath);
        -- self.plant.mainTexture = nil;
        self._mainTexturePath = nil;
    end
end

function PlantCtr:Dispose()

    self:TryRecycleTexture();

    UIUtil.GetComponent(self.tubg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    self.gameObject = nil;

    self.tubg = nil;
    self.plant = nil;

    self.unopen_tu_tip = nil;

    self.tipIcon = nil;
    self.time_txt = nil;

    self._onClickBtn = nil;


end