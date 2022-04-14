---
--- Created by  Administrator
--- DateTime: 2019/12/10 20:30
---
ReviveHelpPanel = ReviveHelpPanel or class("ReviveHelpPanel", WindowPanel)
local this = ReviveHelpPanel

function ReviveHelpPanel:ctor(parent_node, parent_panel)
    self.abName = "system"
    self.assetName = "ReviveHelpPanel"
    self.layer = "UI"
    self.panel_type = 4
    self.events = {}
end

function ReviveHelpPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
end

function ReviveHelpPanel:LoadCallBack()
    self.nodes = {
        "goBtn","headObj","des","toggle/duihao","centerBtn","toggle/toggleBg",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self:InitUI()
    self:AddEvent()
end

function ReviveHelpPanel:InitUI()
    self.data = DungeonModel:GetInstance().sosData
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    --param["is_hide_frame"] = true
    param["size"] = 70
    param["uploading_cb"] = uploading_cb
    param["role_data"] = self.data.role
    self.role_icon1 = RoleIcon(self.headObj)
    self.role_icon1:SetData(param)
    local sceneCfg = Config.db_scene[self.data.scene_id]
    local sceneName = sceneCfg.name
    if not sceneCfg then
        sceneName = "Unknown place"
    end
    local str = string.format("Your guild mate <color=#4DA4FF>%s</color> is <color=#4EB72E>%s</color>\n<color=#B146FE>(%s,%s)</color>applying for assistance.Go now?",
            self.data.role.name,sceneName,math.floor(self.data.x),math.floor(self.data.y))
    self.des.text = str
    self:SetToggleState(false)
end

function ReviveHelpPanel:AddEvent()
    local function call_back()
        self:Close()
        self:SetPromptInfo()
        DungeonModel:GetInstance():DestroySosIcon()
    end
    AddClickEvent(self.centerBtn.gameObject,call_back)

    local function call_back() --前往

        self:SetPromptInfo()
        local main_role = SceneManager:GetInstance():GetMainRole()
        local start_pos = main_role:GetPosition()
       -- local boo = SceneControler:GetInstance():UseFlyShoeToPos(self.data.scene_id,self.data.x,self.data.y,true)
      --  if  not boo  then
           -- OperationManager:GetInstance():TryMoveToPosition(self.data.scene_id,start_pos,{x = self.data.x,y = self.data.y})
      --  end
        local x, y = SceneManager.GetInstance():GetBlockPos(self.data.x, self.data.y)
        local sceneId = SceneManager.Instance:GetSceneId()
        if sceneId == self.data.scene_id then
          --  OperationManager:GetInstance():TryMoveToPosition(self.data.scene_id,start_pos,{x = x,y = y})
            OperationManager.GetInstance():CheckMoveToPosition(self.data.scene_id, nil, { x = self.data.x, y =self.data.y })
        elseif SceneConfigManager:GetInstance():CheckEnterScene(sceneId, true) then
            local sceneCfg = Config.db_scene[self.data.scene_id]
            if sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_CITY or sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_FIELD then
                OperationManager:GetInstance():TryMoveToPosition(self.data.scene_id,start_pos,{x = self.data.x,y = self.data.y})
            elseif sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_BOSS then
                DungeonModel.GetInstance():SetTargetPos(self.data.x, self.data.y)
                SceneControler:GetInstance():RequestSceneChange(self.data.scene_id, enum.SCENE_CHANGE.SCENE_CHANGE_BOSS,
                        { x = self.data.x, y = self.data.y }, nil, 0)
            elseif sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_ACT then
                SceneControler:GetInstance():RequestSceneChange(self.data.scene_id, enum.SCENE_CHANGE.SCENE_CHANGE_ACT,
                        { x = self.data.x, y = self.data.y}, nil, 0)
            end
        end
        DungeonModel:GetInstance():StartShowSosIcon(120)
        self:Close()
    end
    AddClickEvent(self.goBtn.gameObject,call_back)


    local function call_back()--是否忽略本次登录
        self:SetToggleState(not self.isToggle)
    end
    AddClickEvent(self.toggleBg.gameObject,call_back)
end

function ReviveHelpPanel:SetToggleState(boo)
    self.isToggle = boo
    SetVisible(self.duihao,boo)
end

function ReviveHelpPanel:SetPromptInfo()
    if self.isToggle then
        if  not DungeonModel.CheckReviveHelpPromptList[self.data.role.id] then
            DungeonModel.CheckReviveHelpPromptList[self.data.role.id] = true
        end
    end
end
    
