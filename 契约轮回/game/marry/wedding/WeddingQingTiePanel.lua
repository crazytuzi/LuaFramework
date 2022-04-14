---
--- Created by  Administrator
--- DateTime: 2019/7/11 19:14
---
WeddingQingTiePanel = WeddingQingTiePanel or class("WeddingQingTiePanel", BasePanel)
local this = WeddingQingTiePanel

function WeddingQingTiePanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "WeddingQingTiePanel"
    self.layer = LayerManager.LayerNameList.UI
    self.use_background = true
    self.change_scene_close = true
    self.events = {}
    self.model = MarryModel:GetInstance()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
end

function WeddingQingTiePanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end

    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end
end

function WeddingQingTiePanel:LoadCallBack()
    self.nodes = {
        "enemyObj/enemy_bg/enemy_icon","myObj/role_bg/level_bg/level","goBtn","enemyObj/enemyName","GetQtBtn","time",
        "enemyObj/enemy_bg/level_bg/enemyLevel","myObj/role_bg/role_icon","myObj/myName","des1","closeBtn"
    }
    self:GetChildren(self.nodes)
    self.level = GetText(self.level)
    self.myName = GetText(self.myName)
   -- self.role_icon = GetImage(self.role_icon)
    self.enemyName = GetText(self.enemyName)
    self.enemyLevel = GetText(self.enemyLevel)
   -- self.enemy_icon = GetImage(self.enemy_icon)
    self.des1 = GetText(self.des1)
    self.time = GetText(self.time)
    self:AddEvent()
    MarryController:GetInstance():RequsetWeddingNotice()
end

function WeddingQingTiePanel:InitUI()
    local roles = self.model.weddingInfo.couple
    local name1 = ""
    local name2 = ""
    for i, v in pairs(roles) do
        if v.gender == 1 then
            name1 = v.name
            self.myName.text = v.name
            self.level.text = v.level
            if self.role_icon1 then
                self.role_icon1:destroy()
                self.role_icon1 = nil
            end
            local param = {}
            local function uploading_cb()
                --  logError("回调")
            end
            param["is_squared"] = true
            param["is_hide_frame"] = true
            param["size"] = 85
            param["uploading_cb"] = uploading_cb
            param["role_data"] = v
            self.role_icon1 = RoleIcon(self.role_icon)
            self.role_icon1:SetData(param)
            --lua_resMgr:SetImageTexture(self,self.role_icon, 'main_image', "img_role_head_1", true)
        else
            name2 = v.name
            self.enemyName.text = v.name
            self.enemyLevel.text = v.level
            if self.role_icon2 then
                self.role_icon2:destroy()
                self.role_icon2 = nil
            end
            local param = {}
            local function uploading_cb()
                --  logError("回调")
            end
            param["is_squared"] = true
            param["is_hide_frame"] = true
            param["size"] = 85
            param["uploading_cb"] = uploading_cb
            param["role_data"] = v
            self.role_icon2 = RoleIcon(self.enemy_icon)
            self.role_icon2:SetData(param)
            --lua_resMgr:SetImageTexture(self,self.enemy_icon, 'main_image', "img_role_head_2", true)
        end
    end
    self.des1.text = string.format("%s and %s’s Wedding at the Titan's Realm!",name1,name2)

end

function WeddingQingTiePanel:AddEvent()

    local function call_back()  --索要请帖
        MarryController:GetInstance():RequsetInvitationRequest(self.model.weddingInfo.start_time,self.model.weddingInfo.end_time)
    end
    AddButtonEvent(self.GetQtBtn.gameObject,call_back)
    
    local function call_back()  --参见婚礼
        --local cfg = String2Table(Config.db_marriage["scene"].val)
        --local scene = cfg[1]
        --print2(scene)
        local db = Config.db_activity[10124]
        local scene = db.scene
        SceneControler:GetInstance():RequestSceneChange(scene, 4,nil,nil,10124)
    end
    AddButtonEvent(self.goBtn.gameObject,call_back)


    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.InvitationRequest,handler(self,self.InvitationRequest))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.WeddingNotice,handler(self,self.WeddingNotice))
end

function WeddingQingTiePanel:WeddingNotice(data)
    self:InitUI()
    local info = data.wedding
    local roles = info.couple
    local isMe = false
    for i, v in pairs(roles) do
        if v.id == self.role.id then
            isMe = true
            break
        end
    end
    SetVisible(self.GetQtBtn,not isMe)
   -- self.time.text = "婚宴时间："..TimeManager
    local timeTab = TimeManager:GetTimeDate(info.start_time)
    local timestr = "";
    if timeTab.month then
        timestr = timestr .. string.format("%02d", timeTab.month) .. "M";
    end
    if timeTab.day then
        timestr = timestr .. string.format("%d", timeTab.day) .. "Sunday ";
    end
    if timeTab.hour then
        timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
    end
    if timeTab.min then
        timestr = timestr .. string.format("%02d", timeTab.min) .. "";
    end
    self.time.text = "Banquet time:"..timestr
end

function WeddingQingTiePanel:InvitationRequest()
    Notify.ShowText("Invitation claimed")
    self:Close()
end