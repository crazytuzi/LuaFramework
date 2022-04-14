---
--- Created by  Administrator
--- DateTime: 2019/11/22 11:58
---
CompeteDungelPanel = CompeteDungelPanel or class("CompeteDungelPanel", DungeonMainBasePanel)
local this = CompeteDungelPanel

function CompeteDungelPanel:ctor(parent_node, parent_panel)
    self.abName = "compete"
    self.imageAb = "compete_image"
    self.assetName = "CompeteDungelPanel"
    self.events = {}
    self.gevents = {}
    self.schedules = {}
    self.myHeats = {}
    self.eHeats = {}
    self.buffs = {}
    self.model = CompeteModel:GetInstance()
    self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
end

function CompeteDungelPanel:AfterCreate()
    CompeteDungelPanel.super.AfterCreate(self)
    if self.dungeonExit then
        self.dungeonExit:destroy()
    end
end

function CompeteDungelPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gevents)
    self.model.isOpenBattlePanel = false
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    self.schedules = nil

    if self.autoRequestRank then
        GlobalSchedule.StopFun(self.autoRequestRank);
    end
    self.autoRequestRank = nil;
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end

    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end

    if self.role_update_list and self.role_data then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end

    if not table.isempty( self.buffs ) then
        for i, v in pairs( self.buffs ) do
            v:destroy()
        end
        self.buffs = {}
    end

    if not table.isempty( self.myHeats ) then
        for i, v in pairs( self.myHeats ) do
            v:destroy()
        end
        self.myHeats = {}
    end
    if not table.isempty( self.eHeats ) then
        for i, v in pairs( self.eHeats ) do
            v:destroy()
        end
        self.eHeats = {}
    end
    --
    --if self.eUpdate_Buff then
    --    self.enemyRole.object_info:RemoveListener(self.eUpdate_Buff);
    --end

end

function CompeteDungelPanel:Open()
    self.model.isOpenBattlePanel = true
    WindowPanel.Open(self);
end

function CompeteDungelPanel:LoadCallBack()
    self.nodes = {
        "con/buffParent","CompeteDungelBuffItem","endTime/endTitleTxt","con","endTime",
        "myObj/myHp","myObj/myName","myObj/mlevelBg/myLevel","myObj/myHead","myObj/myzhanl/myPower","myObj","myObj/myzhanl",
        --"myObj/myHeatParent/myHeat5","myObj/myHeatParent/myHeat3","myObj/myHeatParent/myHeat1","myObj/myHeatParent/myHeat2","myObj/myHeatParent/myHeat4",
        "CompeteDungelMingItem","myObj/myHeatParent","enemyObj/eHeatParent","enemyObj/elevelBg","myObj/mlevelBg",
        "enemyObj/ezhanl/enemyPower","enemyObj/elevelBg/enemyLevel","enemyObj/enemyHp","enemyObj/eName","enemyObj/eHead",
        "myObj/myVip","enemyObj/eVip","enemyObj","enemyObj/ezhanl"
        --"enemyObj/eHeatParent/eHeat3","enemyObj/eHeatParent/eHeat5","enemyObj/eHeatParent/eHeat4","enemyObj/eHeatParent/eHeat2","enemyObj/eHeatParent/eHeat1",
    }
    self:GetChildren(self.nodes)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.myHp = GetImage(self.myHp)
    self.myName = GetText(self.myName)
    self.myLevel = GetText(self.myLevel)
    self.myPower = GetText(self.myPower)
    self.elevelBg = GetImage(self.elevelBg)
    self.mlevelBg = GetImage(self.mlevelBg)

    self.enemyPower = GetText(self.enemyPower)
    self.enemyLevel = GetText(self.enemyLevel)
    self.enemyHp = GetImage(self.enemyHp)
    self.eName = GetText(self.eName)
    self.myVip = GetText(self.myVip)
    self.eVip = GetText(self.eVip)
    --self.eHead = GetImage(self.eHead)


    self:InitUI()
    self:AddEvent()
    self:InitScene()
    CompeteController:GetInstance():RequstCompeteFightInfo()
    CompeteController:GetInstance():RequstCompeteBattleInfo()
    SetAlignType(self.con.transform, bit.bor(AlignType.Left, AlignType.Null))
end

function CompeteDungelPanel:InitUI()
    local  tab = self.model:GetBuffs()
    for i = 1, #tab do
        local buffsTab = tab[i]
        if buffsTab then
            local showId = buffsTab[1]
            local buffId = buffsTab[2]
            local buffCostTab = buffsTab[4]
            local costId = buffCostTab[1][1]
            local costNum = buffCostTab[1][2]
            local item = self.buffs[i]
            if not item then
                item = CompeteDungelBuffItem(self.CompeteDungelBuffItem.gameObject,self.buffParent,"UI")
                self.buffs[i] = item
            end
            item:SetData(buffId,costId,costNum,showId)
            
        end
    end

    --命数
    local maxNum =  self.model:GetMingNum()
    for i = 1, maxNum do
        local item = self.myHeats[i]
        if not item  then
            item = CompeteDungelMingItem(self.CompeteDungelMingItem.gameObject,self.myHeatParent,"UI")
            self.myHeats[i]= item
        end
        item:SetData(i)
    end

    for i = 1, maxNum do
        local item = self.eHeats[i]
        if not item  then
            item = CompeteDungelMingItem(self.CompeteDungelMingItem.gameObject,self.eHeatParent,"UI")
            self.eHeats[i]= item
        end
        item:SetData(i)
    end

end

function CompeteDungelPanel:InitScene()
    local createdMonTab = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT);
    if createdMonTab then
        for k, monster in pairs(createdMonTab) do
            self:HandleNewCreate(monster);
        end
    end

    if table.isempty(createdMonTab) then
        local createdMonTab2 = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROLE);
        if createdMonTab2 then
            for k, monster in pairs(createdMonTab2) do
                self:HandleNewCreate(monster);
            end
        end

    end
end

function CompeteDungelPanel:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteBattleInfo,handler(self,self.CompeteBattleInfo))
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteBuffInfo,handler(self,self.CompeteBuffInfo))
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteFightInfo,handler(self,self.BattlePrepare))


    local function call_back()
        self:UpdateMainHp()
    end

    self.role_update_list = {}
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hp", call_back)
    local function call_back()
        self:UpdateMainHp()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hpmax", call_back)

    local function call_back()
        --dump(self.role_data.buffs)
        --local list = self.role_data:GetShowBuffList() or {}
        --dump(list)
        self:UpdateMyBuff()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("buffs", call_back)


    GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.gevents);
end

--战场信息返回
function CompeteDungelPanel:CompeteBattleInfo(data)
    self.startTime = data.etime  --结束时间
    self:StartCountDown()
    self:SetMyInfo()
    self:UpdateMyBuff()
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    self.schedules = nil
    self.schedules = GlobalSchedule:Start(handler(self, self.StartCountDown), 0.1, -1);
end

function CompeteDungelPanel:CompeteBuffInfo()
    --local list = self.role_data:GetShowBuffList() or {}
    --dump(list)
    Notify.ShowText("Purchased")
end

function CompeteDungelPanel:StartCountDown()
    if self.startTime then
        local timeTab = nil;
        local timestr = "";
        local formatTime = "%02d";
        --SetGameObjectActive(self.endTime.gameObject, true);
        timeTab = TimeManager:GetLastTimeData(os.time(), self.startTime);
        if table.isempty(timeTab) then
            -- Notify.ShowText("副本结束了,需要做清理了");
            if self.schedules then
                GlobalSchedule:Stop(self.schedules);
            end
            self.schedules = nil
        else
            if timeTab.min then
                timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.endTitleTxt.text = timestr;--"副本倒计时: " ..
        end
    end
end

function CompeteDungelPanel:HandleNewCreate(monster)
    if not monster.object_info or monster.object_info.uid == self.role_data.uid then
        return
    end
    if monster and monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT or monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
        local call_back1 = function(hp)
         --   logError("hp:"..hp.."maxHp"..monster.object_info.hpmax)
            local buff = self.model:GetMingBuff(monster.object_info.buffs)
            local value = hp / monster.object_info.hpmax
            if self.enemyHp then
                self.enemyHp.fillAmount = value
            end
           -- logError(buff.value.."命")
           -- if monster and monster.object_info and monster.object_info.hp <= 0 and buff.value <= 1 then
           --     --call_back();
           --     monster.object_info:RemoveListener(self.update_blood);
           -- end
        end
        self.enemyHp.fillAmount = 1
       -- if not self.update_blood  then
            self.update_blood = monster.object_info:BindData("hp", call_back1);
      --  end
        
        
        local function call_back()
            self:UpdateEBuff(monster.object_info.buffs)
        end

       -- if not self.eUpdate_Buff then
            self:UpdateEBuff(monster.object_info.buffs)
            self.eUpdate_Buff = monster.object_info:BindData("buffs", call_back);
       -- end
        self:SetEnemyInfo(monster.object_info)
    end
end




function CompeteDungelPanel:UpdateMainHp()
    if not self.role_data or not self.role_data.attr or not self.role_data.hp or not self.role_data.hpmax or not self.is_loaded then
        return
    end
    local value = self.role_data.hp / self.role_data.hpmax
    self.myHp.fillAmount = value
end




--敌人信息
function CompeteDungelPanel:SetEnemyInfo(role)
    self.enemyPower.text = role.power
    self:SetLevel(role.level,self.elevelBg,self.enemyLevel)
    self.eName.text = role.name
    self.eVip.text = "V"..role.viplv
    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    --param["is_squared"] = true
    --param["is_hide_frame"] = true
    param["size"] = 90
    param["uploading_cb"] = uploading_cb
    param["role_data"] = role
    self.role_icon2 = RoleIcon(self.eHead)
    self.role_icon2:SetData(param)
end

--自己的信息
function CompeteDungelPanel:SetMyInfo()
    self:SetLevel(self.role_data.level,self.mlevelBg,self.myLevel)
    self.myPower.text = self.role_data.power
    self.myName.text = self.role_data.name
    self.myVip.text = "V"..self.role_data.viplv
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    --param["is_squared"] = true
    --param["is_hide_frame"] = true
    param["size"] = 90
    param["uploading_cb"] = uploading_cb
    param["role_data"] = self.role_data
    self.role_icon1 = RoleIcon(self.myHead)
    self.role_icon1:SetData(param)
end

function CompeteDungelPanel:SetLevel()
    
end

function CompeteDungelPanel:UpdateMyBuff()
    local role =  RoleInfoModel:GetInstance():GetMainRoleData()
    local buffs = role.buffs
    local buff = self.model:GetMingBuff(buffs)
    if buff then
        local mingNum = buff.value
        for i = 1, #self.myHeats do
            if i > mingNum then
                self.myHeats [i]:UpdateInfo(false)
            else
                self.myHeats [i]:UpdateInfo(true)
            end
        end
    end

    for i, v in pairs(self.buffs) do
        v:SetBtnState()
    end
end

function CompeteDungelPanel:UpdateEBuff(buffs)
    local buff = self.model:GetMingBuff(buffs)
    if  buff then
       -- logError(buff.value.."敌人命数")


        for i = 1, #self.eHeats do
            if i > buff.value then
                self.eHeats[i]:UpdateInfo(false)
            else
                self.eHeats[i]:UpdateInfo(true)
            end
        end
    end
end

function CompeteDungelPanel:SetLevel(lv,lv_frame_img,nameText)
    local result = lv
    local img_idx = 1
    local critical = String2Table(Config.db_game.level_max.val)[1]
    if lv > critical then
        result = lv - critical
        img_idx = 2
    end
    lua_resMgr:SetImageTexture(self, lv_frame_img, "main_image", "img_main_role_lv_bg_" .. img_idx, false, nil, false)
    nameText.text = result
end


function CompeteDungelPanel:BattlePrepare(data)
    --logError("111111111111")
    --dump(data)
    self.pos = data.index
    if self.pos == 1 then --自己的位置在左

    else --自己的位置在右
        SetLocalScale(self.myHead.transform,-1,1,1)
        SetLocalScale(self.myObj.transform,-1,1,1)
        SetLocalPositionX(self.myObj.transform,45)
        SetLocalScale(self.mlevelBg.transform,-1,1,1)
        SetLocalScale(self.myzhanl.transform,-1,1,1)
        SetLocalScale(self.myName.transform,-1,1,1)
        SetLocalScale(self.myVip.transform,-1,1,1)
        SetLocalPositionX(self.myVip.transform,-274)
        --SetLocalPositionX(self.myzhanl.transform,-275)
        SetLocalPositionX(self.myName.transform,-144)


        SetLocalScale(self.eHead.transform,-1,1,1)
        SetLocalScale(self.enemyObj.transform,-1,1,1)
        SetLocalPositionX(self.enemyObj.transform,-578)
        SetLocalScale(self.elevelBg.transform,-1,1,1)
       -- SetLocalScale(self.ezhanl.transform,-1,1,1)
        SetLocalScale(self.eName.transform,-1,1,1)
        SetLocalScale(self.eVip.transform,-1,1,1)
        SetLocalPositionX(self.ezhanl.transform,-360)
        SetLocalPositionX(self.eName.transform,-455)
        SetLocalPositionX(self.eVip.transform,-320)

    end
    SetVisible(self.myObj,true)
    SetVisible(self.enemyObj,true)
end


