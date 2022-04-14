--- Created by Admin.
--- DateTime: 2019/11/1 11:40
GodsDungePanel = GodsDungePanel or class("GodsDungePanel", DungeonMainBasePanel)
local this = GodsDungePanel


function GodsDungePanel:ctor(parent_node, parent_panel)
    self.abName = "dungeon"
    self.assetName = "GodsDungePanel"
    self.events = {}
    self.mEvents = {}
    self.items = {}
    self.curObj = nil
    self.curWave = 0  -- 当前波数
    self.curNum = 0   -- 现在逃跑数
    self.whiteItemList = {}
    self.crystals = {}
end

function GodsDungePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)

    if self.items then
        for i, v in pairs(self.items) do
            v:destroy()
        end
        self.items = {}
    end
    self:HandleAutoExit()

    if self.whiteItemList then
        self.whiteItemList = {}
    end
    if self.redItemList then
        self.redItemList = {}
    end
    if self.curObj then
      cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.curObj)
    end
    destroyTab(self.crystals);
    self.crystals = nil;
    self.crystalsList = {}
    self.curObj = nil
    self.curWave = 0
    self.curNum = 0
end

function GodsDungePanel:LoadCallBack()
    self.nodes = {
        "con/count","con/escape/pos1","con/Scroll View/Viewport/Content","tip5",
        "con","tip1","tip2","tip1/tipNum","tip2/tip2Num","con/survivalNum","con/escapeNum",
        "con/noReward","startTimeP", "startTimeP/time","effectPos","tip3","tip4","guide","guide/Image",
        "con/escape/pos1/white1","con/escape/pos1/white2","con/escape/pos1/white3","con/escape/pos1/white4",
        "con/escape/pos1/white5","con/escape/pos1/white6","con/escape/pos1/white7","con/escape/pos1/white8",
        "crystal/crystal_item_1","crystal/crystal_item_2","crystal/crystal_item_3","crystal",
    }
    self:GetChildren(self.nodes)

    self.countTex = GetText(self.count)
    self.tipNumTex = GetText(self.tipNum)
    self.tip2NumTex = GetText(self.tip2Num)
    self.survivalNumTex = GetText(self.survivalNum)
    self.escapeNumTex = GetText(self.escapeNum)
    self.timeTex = GetText(self.time)
    self:InitUI()
    self:AddEvent()
    SetAlignType(self.con.transform, bit.bor(AlignType.Left, AlignType.Top))
    SetAlignType(self.crystal.transform,bit.bor(AlignType.Right, AlignType.Null))

    DungeonCtrl:GetInstance():RequeseExpDungeonInfo()

    self:StartTimeCD()

end

function GodsDungePanel:StartTimeCD()
    SetVisible(self.startTimeP.transform, true)
    self.time = Config.db_dunge[30601].prep
    self.timeTex.text =  self.time
    local function call_back()
        self.time = self.time - 1
        self.timeTex.text =  self.time
        if self.time < 1 then
            SetVisible(self.startTimeP.transform, false)
            self.time = nil
            if self.time_id then
                GlobalSchedule:Stop(self.time_id)
                self.time_id = nil
            end
        end
    end
    self.time_id = GlobalSchedule:Start(call_back,1)
end


function GodsDungePanel:InitUI()
    self.whiteItemList[1] = GetImage(self.white1)
    self.whiteItemList[2] = GetImage(self.white2)
    self.whiteItemList[3] = GetImage(self.white3)
    self.whiteItemList[4] = GetImage(self.white4)
    self.whiteItemList[5] = GetImage(self.white5)
    self.whiteItemList[6] = GetImage(self.white6)
    self.whiteItemList[7] = GetImage(self.white7)
    self.whiteItemList[8] = GetImage(self.white8)

    self:UpdateGuide()
    self:InitScene()
end

function GodsDungePanel:AddEvent()
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, handler(self, self.HandleData))
    AddEventListenerInTab(DungeonEvent.DUNGEON_AUTO_EXIT, handler(self, self.HandleAutoExit), self.events);
    AddEventListenerInTab(SceneEvent.UPDATE_ACTOR_HP, handler(self, self.HandleActorHp), self.events);
    AddEventListenerInTab(MainEvent.HideTopRightIcon, handler(self, self.HandlerShowCry), self.events);
    AddEventListenerInTab(MainEvent.ShowTopRightIcon, handler(self, self.HandlerHideCry), self.events);
   -- AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.events);
end




function GodsDungePanel:HandleData(data)
    if data.stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_GOD then
        return ;
    end
    self:UpdateData(data.info);
    self:UpdateReward(data.drops)
end

function GodsDungePanel:UpdateGuide()
    local function call_back()
        local id = FightManager:GetInstance().client_lock_target_id
       -- local monster = SceneManager:GetInstance():GetObject(id)
        local monster = SceneManager:GetInstance():GetCreepByTypeId()
        if not monster then
            SetVisible(self.guide.gameObject, false)
        else
            local myData =  SceneManager:GetInstance():GetMainRole()
            local s = myData:GetPosition()
            local s1 = monster:GetPosition()
            local dis = Vector3.Distance(s, s1)
            if  dis > 730 then
                SetVisible(self.guide.gameObject, true)

                local x = s.x - s1.x
                local y = s.y - s1.y
                local z = s.z - s1.z
                local  lookAtEuler = Vector3.Angle(Vector3(x,y,z), Vector3.right)
                local  dot = Vector3.Dot(Vector3(x,y,z), Vector3.up)
                if (dot < 0) then
                    lookAtEuler = 360 - lookAtEuler
                end
                SetLocalRotation(self.Image.transform, 0, 0, (lookAtEuler + 180))
            else
                SetVisible(self.guide.gameObject, false)
            end
        end
    end
    self.time_id_3 = GlobalSchedule:Start(call_back, 0.2)
end

function GodsDungePanel:UpdateData(data)
    local num = Config.db_dunge_god[data.cur_wave].escape
    self.survivalNumTex.text = data.alive
    if data.escape == 0 then
        self.escapeNumTex.text = "<color=#1AFF36>" ..data.escape .."</color>/".. num
    else
        self.escapeNumTex.text = "<color=red>" ..data.escape .."</color>/".. num
    end

    if self.curWave == data.cur_wave then
        if self.curNum ~= data.escape and num >= data.escape then
            if data.escape ==0 then return end
            self.curNum = data.escape
            for i = 1, data.escape do
                local res = "gods_12"
                lua_resMgr:SetImageTexture(self, self.whiteItemList[i], "dungeon_image", res, true, nil, false)
                SetVisible(self.whiteItemList[i].gameObject, true)
            end
            self.tip2NumTex.text = data.escape
            self:SetObjState(self.tip2)
            self:SetEffect()

            if num == data.escape then
                self:SetObjState(self.tip4, true)
            end
            if self.curWave == DungeonModel:GetInstance().maxWave and data.alive == 0 then
                self:SetObjState(self.tip3, true)
            end
        end

    else
        for i = 1, 8 do
            SetVisible(self.whiteItemList[i].gameObject, false)
            local res = "gods_11"
            lua_resMgr:SetImageTexture(self, self.whiteItemList[i], "dungeon_image", res, true, nil, false)
        end
        self.curWave = data.cur_wave
        for i = 1, num do
            SetSizeDeltaX(self.whiteItemList[i].transform, 200 / num)
            SetVisible(self.whiteItemList[i].gameObject, true)
        end
        self.countTex.text = string.format("Wave %s", self.curWave)
        local function call_back()
            if self.time then return end
            self.tipNumTex.text = self.curWave
            self:SetObjState(self.tip1)
            if self.time_id_5 then
                GlobalSchedule:Stop(self.time_id_5)
            end
        end
        if self.time_id_5 then
            GlobalSchedule:Stop(self.time_id_5)
            self.time_id_5= nil
        end
        self.time_id_5 = GlobalSchedule:Start(call_back,1)
    end
end

function GodsDungePanel:SetObjState(obj, bool)
    if self.time_id_1 then
            GlobalSchedule:Stop(self.time_id_1)
            self.time_id_1 = nil
    end

    if self.curObj then
        SetVisible(self.curObj.gameObject, false)
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.curObj)
        self.curObj = nil
    end


    SetLocalScale(obj.transform, 0.75,0.75,0.75)
    SetVisible(obj.gameObject, true)
    local moveAction
    if bool then
        moveAction = cc.Spawn(cc.MoveTo(0.2, 50, 60, 0),cc.ScaleTo(0.2,1, 1))
    else
        moveAction = cc.Spawn(cc.MoveTo(0.2, 50, 200, 0),cc.ScaleTo(0.2,1, 1))
    end

    cc.ActionManager:GetInstance():addAction(moveAction, obj)

    local function call_back()
        SetVisible(obj.gameObject, false)
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.curObj)
        self.curObj = nil
        if self.time_id_1 then
            GlobalSchedule:Stop(self.time_id_1)
            self.time_id_1 = nil
        end
    end

    self.curObj = obj
    self.time_id_1 = GlobalSchedule:StartOnce(call_back,1.5)
end

function GodsDungePanel:SetEffect()
    if self.time_id_2 then
        GlobalSchedule:Stop(self.time_id_2)
        self.time_id_2 = nil
    end

    if self.effect then
        self.effect:destroy()
        self.effect = nil
    end

    self.effect = UIEffect(self.effectPos.transform, 10103, false)
    local scale_x = ScreenWidth/512
    local scale_y = ScreenHeight/256
    local config = {scale = Vector3(scale_x,scale_y,1)}
    self.effect:SetConfig(config)
    self.effect:SetOrderIndex(100)
    local function call_back()
        if self.effect then
            self.effect:destroy()
            self.effect = nil
        end
        GlobalSchedule:Stop(self.time_id_2)
        self.time_id_2 = nil
    end
    self.time_id_2 = GlobalSchedule:StartOnce(call_back,0.5)
end


function GodsDungePanel:UpdateReward(reward)
    if table.isempty(reward) then
        SetVisible(self.noReward.gameObject, true)
        return
    end

    SetVisible(self.noReward.gameObject, false)

    for i, v in pairs(reward) do
        if self.items[i] == nil then
            self.items[i] = GoodsIconSettorTwo(self.Content.transform)
        end

        local param = {}
        param["item_id"] = i;
        param["num"] = v;
        param["can_click"] = true;
        self.items[i]:SetIcon(param)
    end
end


function GodsDungePanel:InitScene()
    local createdMonTab = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP);
    if createdMonTab then
        for k, monster in pairs(createdMonTab) do
            self:HandleNewCreate(monster);
        end
    end
end

function GodsDungePanel:HandleNewCreate(monster)
    local crystalIDTab = Config.db_creep_born[30601];
    local cid1 = 3060301;
    local cid2 = 3060302;
    local cid3 = 3060303;
    if crystalIDTab then
        local creeps = String2Table(crystalIDTab["creeps"]);
        for k, v in pairs(creeps) do
            if k == 1 then
                cid1 = v[1];
            elseif k == 2 then
                cid2 = v[1];
            elseif k == 3 then
                cid3 = v[1];
            end
        end
    end
    if monster and monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        local object_info = monster.object_info;
        local config = Config.db_creep[object_info.id];
        if object_info.id == cid1 then
            if self.crystals[1] then
                self.crystals[1]:UpdateData(object_info);
            else
                self.crystals[1] = PetCrystalItem(self.crystal_item_1, object_info, 1);
            end
        elseif object_info.id == cid2 then
            if self.crystals[2] then
                self.crystals[2]:UpdateData(object_info);
            else
                self.crystals[2] = PetCrystalItem(self.crystal_item_2, object_info, 2);
            end
        elseif object_info.id == cid3 then
            if self.crystals[3] then
                self.crystals[3]:UpdateData(object_info);
            else
                self.crystals[3] = PetCrystalItem(self.crystal_item_3, object_info, 3);
            end
        elseif monster.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT and self.cur_wave and tonumber(self.cur_wave) <= 3 then
            monster.advance_container = AdvanceDungeonItem();
            monster.advance_container:ShowDes(true, "Tap to collect");
            monster.advance_container:UpdateLockPos(-monster:GetBodyHeight() / 2);
            monster:SetAdvanceItemPos();
        end

        if monster.object_info and monster.object_info["ext"] and monster.object_info["ext"]["disappear"] then
            local time = monster.object_info["ext"]["disappear"];
            SetGameObjectActive(self.boom_exit.gameObject, true);

            local call_back = function()
                SetGameObjectActive(self.boom_exit.gameObject, false);
            end
            if self.boom_exit_schedule then
                GlobalSchedule.StopFun(self.boom_exit_schedule);
            end
            self.boom_exit_schedule = GlobalSchedule.StartFunOnce(call_back, 15);

            local call_back1 = function()
                if monster and monster.object_info and monster.object_info.hp <= 0 then
                    call_back();
                    monster.object_info:RemoveListener(self.update_blood);
                end
            end

            self.update_blood = monster.object_info:BindData("hp", call_back1);
        end
    end
end

function GodsDungePanel:HandleActorHp(data)
    local uid = data.uid;--uid
    local hp = data.hp;--当前血量
    local hpmax = data.hpmax;--最大血量

    for i, v in pairs(self.crystals) do
        if v.data.uid == uid then
            self.crystals[i]:UpdateHP(hp, hpmax);
            if hp <= 0 then
                self:SetObjState(self.tip5)
            end
        end
    end
end

function GodsDungePanel:HandlerShowCry()
    SetVisible(self.crystal.gameObject, true)
end

function GodsDungePanel:HandlerHideCry()
    SetVisible(self.crystal, false)
end

function GodsDungePanel:HandleAutoExit()
    SetVisible(self.tip2.gameObject, false)
    SetVisible(self.tip1.gameObject, false)
    GlobalEvent:RemoveTabListener(self.events)
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
    end
    if self.time_id_1 then
        GlobalSchedule:Stop(self.time_id_1)
    end
    if self.time_id_3 then
        GlobalSchedule:Stop(self.time_id_3)
    end
    if self.time_id_2 then
        GlobalSchedule:Stop(self.time_id_2)
    end
    if self.time_id_5 then
        GlobalSchedule:Stop(self.time_id_5)
    end
    if self.time_1 then
        GlobalSchedule:Stop(self.time_1)
    end
    if self.time_2 then
        GlobalSchedule:Stop(self.time_2)
    end
    self.time_id_3 = nil
    self.time_id = nil
    self.time_id_1 = nil
    self.time_id_2 = nil
    self.time_id_5 = nil
    self.time_1 = nil
    self.time_2 = nil
    if self.effect then
        self.effect:destroy()
    end
    self.effect = nil
end





