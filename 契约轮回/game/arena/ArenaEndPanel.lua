---
--- Created by  Administrator
--- DateTime: 2019/5/10 11:15
---
ArenaEndPanel = ArenaEndPanel or class("ArenaEndPanel", BasePanel)
local this = ArenaEndPanel

function ArenaEndPanel:ctor(parent_node, parent_panel)

    self.abName = "arena";
    self.image_ab = "arena_image";
    self.assetName = "ArenaEndPanel"
    self.layer = "UI"
    self.isRefreshBig = false
    self.isRefreshArena = false
    self.events = {}
    self.itemicon = {}
    self.model = ArenaModel:GetInstance()
end

function ArenaEndPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.endItem then
        self.endItem:destroy();
    end

    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function ArenaEndPanel:LoadCallBack()
    self.nodes = {
        "curRank2","curRank1","iconParent","lastRank",
    }
    self:GetChildren(self.nodes)
    self.curRank1 = GetText(self.curRank1)
    self.curRank2 = GetText(self.curRank2)
    self.lastRank = GetText(self.lastRank)
    self:InitUI()
    self:AddEvent()
end

function ArenaEndPanel:Open(data)
    self.data = data
    WindowPanel.Open(self)
end

function ArenaEndPanel:InitUI()
    local data = {}
    data.isClear =  self.data.is_win
    data.IsCancelAutoSchedule = false
    data.layer = "UI"
    self.endItem = DungeonEndItem(self.transform, data);
    self.endItem:StartAutoClose(5)
    self.curRank1.text = self.data.new_rank
    self.curRank2.text = self.data.new_rank
    self.lastRank.text = self.data.old_rank

    local  scene_data = SceneManager:GetInstance():GetSceneInfo()
    if not self.model:IsArenaFight(scene_data.scene)  then
        if self.model.isOpenArenaPanel then
            ArenaController:GetInstance():RequstArenaInfo()
        end
		if self.model.isOpenArenaBagPanel  then
			ArenaController:GetInstance():RequstTopInfo()
            ArenaController:GetInstance():RequstTopRank()
		end
    end
    self:CreateIcon()

end

function ArenaEndPanel:AddEvent()
    local function call_back()
        local  scene_data = SceneManager:GetInstance():GetSceneInfo()
        if self.model:IsArenaFight(scene_data.scene) then
            SceneControler:GetInstance():RequestSceneLeave();
        end
        self:Close()
    end
    self.endItem:SetCloseCallBack(call_back);
    self.endItem:SetAutoCloseCallBack(call_back)
end

function ArenaEndPanel:CreateIcon()
    local reward
	local num
    local main_role_data = RoleInfoModel.GetInstance():GetMainRoleData()
    local cfg = Config.db_arena_challenge[main_role_data.level]
    if not cfg then
        return
    end
    if self.data.is_win then
        reward = String2Table(cfg.win)
    else
        reward = String2Table(cfg.lose)
    end
    for i = 1, #reward do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        else
            return
        end
        local param = {}
		
        param["model"] = self.model
        param["item_id"] = reward[i][1]
		param["num"] = reward[i][2] * self.data.challenge
		--if self.model.isTimes then --合并次数
			--param["num"] = reward[i][2] * self.data.challenge
		--else	
			--param["num"] = reward[i][2]
		--end
        param["can_click"] = true
        --  param["size"] = {x = 72,y = 72}
        self.itemicon[i]:SetIcon(param)
    end
end