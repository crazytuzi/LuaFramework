---
--- Created by  Administrator
--- DateTime: 2019/10/31 14:26
---
LimitTowerPanel = LimitTowerPanel or class("LimitTowerPanel", WindowPanel)
local this = LimitTowerPanel

function LimitTowerPanel:ctor()
    self.abName = "limitTower"
    self.assetName = "LimitTowerPanel"
    self.image_ab = "limittower_image";
    self.layer = "UI"
    self.panel_type = 7
    self.title = "limiTower_title_text"
    self.events = {}
    self.gevent = {}
    self.items = {}
    self.isFirst = true
    self.model = LimitTowerModel:GetInstance()
    self.roleInfo = RoleInfoModel.GetInstance():GetMainRoleData()


end

function LimitTowerPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.gevent)
    if self.items then
        for i, v in pairs(self.items) do
            v:destroy()
        end
    end
    self.items = {}

    if self.monster then
        self.monster:destroy()
    end

    if self.roloModel then
        self.roloModel:destroy()
    end
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end

    if self.camera_component then
        self.camera_component.targetTexture = nil
    end
    if self.rawImage then
        self.rawImage.texture = nil
    end
    if self.render_texture then
        ReleseRenderTexture(self.render_texture)
        self.render_texture = nil
    end

end

function LimitTowerPanel:LoadCallBack()
    self.nodes = {
        "LimitTowerItem","right/ScrollView/Viewport/Content",
        "right/SingleBtn","left/modelCon","left/wenhao","right/TeamBtn",
        "right/powerObj/myPower","right/ScrollView","left/time","left/textImg2","left/textImg",
        "left/roleCon","left/roleCon/Camera",
    }
    self:GetChildren(self.nodes)
    self.myPower = GetText(self.myPower)
    self.time = GetText(self.time)
    self.textImg2 = GetImage(self.textImg2)
    self.textImg3 = GetImage(self.textImg)

    self.rawImage = self.roleCon:GetComponent("RawImage")
    self.camera_component = self.Camera:GetComponent("Camera")
    self:InitUI()
    self:AddEvent()
	
	DungeonCtrl:GetInstance():RequestDungeonPanel(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER)
    LayerManager:GetInstance():AddOrderIndexByCls(self,self.modelCon,nil,true,nil,nil,3)
   -- LayerManager:GetInstance():AddOrderIndexByCls(self,self.textImg2.transform,nil,true,nil,nil,4)
   -- LayerManager:GetInstance():AddOrderIndexByCls(self,self.textImg.transform,nil,true,nil,nil,4)

end

function LimitTowerPanel:OpenCallBack()
    self:SetTitleImgPos(-305,282)
    local texture = CreateRenderTexture()
    self.camera_component.targetTexture = texture
    self.rawImage.texture = texture
    self.render_texture = texture
end

function LimitTowerPanel:CountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";
    timeTab = TimeManager:GetLastTimeData(os.time(), self.openData.act_etime);
    if table.isempty(timeTab) then
        Notify.ShowText("The event is over");
        -- self.rTime.text = "活动剩余：已结束"
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
        end
        self.time.text = string.format("Event time left：<color=#%s>%s</color>","ff0000","Ended")

    else
        if timeTab.day then
            timestr = timestr .. string.format(formatTime, timeTab.day) .. "Days";
        end
        if timeTab.hour then
            timestr = timestr .. string.format(formatTime, timeTab.hour) .. "hr";
        end
        if timeTab.min then
            timestr = timestr .. string.format(formatTime, timeTab.min) .. "min";
        end
        --if timeTab.sec then
        --    timestr = timestr .. string.format(formatTime, timeTab.sec);
        --end
        if timeTab.sec and not timeTab.day and not timeTab.hour and not timeTab.min then
            timestr = "1 pts"
        end
        local color  = "58F95F"
        self.time.text = string.format("Event time left：<color=#%s>%s</color>",color,timestr)
        -- self.rTime.text = "活动剩余：" .. timestr;
    end
end

function LimitTowerPanel:InitUI()
    local cfg = Config.db_yunying_dunge_limit_tower
    local index = 1
    for i = 1, #cfg do
        local actId = cfg[i].act_id
        if OperateModel:GetInstance():IsActOpenByTime(actId) then
            self.actId = actId
            local item = self.items[index]
            if not item then
                item = LimitTowerItem(self.LimitTowerItem.gameObject,self.Content,"UI")
                self.items[index] = item
            end
            item:SetData(cfg[i])
            index = index + 1
        end

    end
    self.myPower.text = self.roleInfo.power
    self.openData = OperateModel:GetInstance():GetAct(self.actId)
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    self.schedules = GlobalSchedule:Start(handler(self, self.CountDown), 0.2, -1);
    --dump(self.items[1].data.chartlet)
    --logError(self.items[1].data.chartlet[1])
    local tab = String2Table(self.items[1].data.chartlet)
   -- dump(tab)
    local str = ""
    if table.nums(tab) == 1 then
        SetVisible(self.modelCon,true)
        SetVisible(self.roleCon,false)
        self:InitModel(self.items[1].data.chartlet)
        str = "limitTower_text1"

    else
        SetVisible(self.modelCon,false)
        SetVisible(self.roleCon,true)
        self:InitRoleModel(tab)
        str = "limitTower_text5"
    end
    local res 
	if self.actId == 170100 then
		res= "limitTower_text2"
	else
		res= "limitTower_text6"
	end
	local function call_back(sp)
		self.textImg3.sprite = sp
		LayerManager:GetInstance():AddOrderIndexByCls(self,self.textImg3.transform,nil,true,nil,nil,4)	
	end
	lua_resMgr:SetImageTexture(self,self.textImg3,"limitTower_image",res, false,call_back)
	
    local function call_back(sp)
        self.textImg2.sprite = sp
        LayerManager:GetInstance():AddOrderIndexByCls(self,self.textImg2.transform,nil,true,nil,nil,4)
    end
    lua_resMgr:SetImageTexture(self,self.textImg2,"limitTower_image",str, false,call_back)

end

function LimitTowerPanel:InitRoleModel(tab)
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local gender = role.gender
    local id = tab[1]
    local type = tab[2]
    local cfgData = Config.db_fashion[id.."@"..type]

    local roleModelId
    if gender == 1 then
        roleModelId = cfgData.man_model
    else
        roleModelId = cfgData.girl_model
    end
    local ori_weapon
    if role.figure.weapon  then
        ori_weapon = role.figure.weapon.model
    end
    local data = {}
    data.res_id = roleModelId
    data.default_weapon = ori_weapon
    self.roloModel =  UIRoleModel(self.roleCon, handler(self, self.HandleRoloLoaded), data)
end

function LimitTowerPanel:HandleRoloLoaded()
    SetLocalPosition(self.roloModel.transform, -1010, -132, 267)
    SetLocalRotation(self.roloModel.transform,172,6,178)
end

function LimitTowerPanel:AddEvent()

    local function call_back()  --组队
        --if not TeamModel:GetInstance():GetTeamInfo() then
        --    Notify.ShowText("你还没有队伍，请先创建一个队伍");
        --    return ;
        --end
        --
        --if not TeamModel:GetInstance():IsCaptain(RoleInfoModel:GetInstance():GetMainRoleId()) then
        --    Notify.ShowText("你不是队长,请联系队长进入");
        --    return ;
        --end
        --local okFun = function()
        --    --服务端定一个协议
        --    logError(self.dungeonId)
        --    TeamController:GetInstance():DungeEnterAsk(self.dungeonId, 1);
        --
        --end
        --if TeamModel:GetInstance():GetMyTeamMemberNum() == 1 then
        --    Dialog.ShowTwo("提示", "队伍只有一个人,确定要进入副本吗?", "确定", okFun, nil, "取消");
        --else
        --    okFun();
        --end

        local subtab = TeamModel:GetInstance():GetSubIDByDungeID(self.dungeonId)
        if TeamModel:GetInstance():GetTeamInfo() then
            --Notify.ShowText("你还没有队伍，请先创建一个队伍");
            lua_panelMgr:GetPanelOrCreate(MyTeamPanel):Open(subtab.id)
            return ;
        end
        lua_panelMgr:GetPanelOrCreate(TeamListPanel):Open(subtab.id)
    end
    AddClickEvent(self.TeamBtn.gameObject,call_back)


    local function call_back()
        ShowHelpTip(HelpConfig.LimitTower.Help,true)
    end
    AddButtonEvent(self.wenhao.gameObject,call_back)

    local function call_back()  --单人
        if self.assist == 0 then --不可助战
            DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER,self.curFloor,self.dungeonId)
        else
            local function okFun()
                DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER,self.curFloor,self.dungeonId)
            end
            Dialog.ShowTwo("Tip", "You may ask for assistance in this stage, solo it?", "Confirm", okFun, nil, "Cancel");
        end

    end
    AddClickEvent(self.SingleBtn.gameObject,call_back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData,handler(self,self.UpdateDungeonData))
    self.gevent[#self.gevent + 1] = self.model:AddListener(LimitTowerEvent.LimitTowerItemClick,handler(self,self.LimitTowerItemClick))
end

function LimitTowerPanel:UpdateDungeonData(stype,data)
    --dump(data)
    --logError("--1--")
    if stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER then
        return
    end
    self.info = DungeonModel:GetInstance().dungeon_info_list[stype]
    self:UpdateItems()
	self.model:UpdateMainRed()
end

function LimitTowerPanel:UpdateItems()
    for i, v in pairs(self.items) do
        v:UpdateCrossInfo()
    end
    --for i = 1, #self.items do
    --    self.items[i]:UpdateCrossInfo()
    --end
    --logError(self.info.info.cur_floor)
    local clickIndex = self.info.info.cur_floor
    if self.info.info.cur_floor > 12 then
        clickIndex = 1
    end
    self:LimitTowerItemClick(clickIndex)

    --if self.assist  == 0 then --单人
    --
    --end
end


function LimitTowerPanel:LimitTowerItemClick(floor)
    for i, v in pairs(self.items) do
        if v.floor == floor then
            self.curFloor = floor
            self.dungeonId = v.data.dunge
            self.assist = v.data.assist
            v:SetSelect(true)
        else
            v:SetSelect(false)
        end
    end
    if self.isFirst then
        self.isFirst = false
        if self.curFloor < 9  then
            SetLocalPositionY(self.Content.transform, ((self.curFloor - 1) * 106))
        else
            SetLocalPositionY(self.Content.transform, 826)
        end
    end
    SetVisible(self.TeamBtn,self.assist == 1)

end


function LimitTowerPanel:InitModel(name)
    -- self.curResName
   -- local resName = Config.db_yunying_dunge_limit_tower[1].chartlet

    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -2005, y = -150, z = 217}
    cfg.scale = {x = 70,y = 70,z = 70}
    self.monster = UIModelCommonCamera(self.modelCon, nil, name,nil,false)
    self.monster:SetConfig(cfg)
end