--
-- @Author: chk
-- @Date:   2018-12-05 10:40:08
--
FactionPanel = FactionPanel or class("FactionPanel", WindowPanel)
local this = FactionPanel

function FactionPanel:ctor()
    self.abName = "faction"
    self.assetName = "FactionPanel"
    self.layer = "UI"

    self.panel_type = 2
    self.show_sidebar = true
    --self.use_background = true
    --self.change_scene_close = true
    self.lastIndex = 1
    self.crntIndex = 1
    self.btnTras = {}
    self.btnSelects = {}
    self.viewCls = {}
    self.viewNode = {}
    self.events = {}
    self.gEvents = {}
    self.model = FactionModel:GetInstance()

    self.roleInfoData = RoleInfoModel.GetInstance():GetMainRoleData();
    local tog_data = {
        { id = 1, text = "Guild Clash" },
        -- { id = 2, text = "Guild Defense" },
        -- { id = 3, text = FactionSerWarModel.desTab.Name,open_func = function ()
        --     return FactionSerWarModel:GetInstance():CheckIsOpen()
        -- end}
    }
    --print2(self.roleInfoData.guild,self.roleInfoData.guild,self.roleInfoData.gname)
    --print2(self.roleInfoData.guild,self.roleInfoData.guild,self.roleInfoData.gname)
    --print2(self.roleInfoData.guild,self.roleInfoData.guild,self.roleInfoData.gname)
    if self.roleInfoData.guild == "0" or self.roleInfoData.guild == 0 or self.roleInfoData.gname == "" then
        self.sidebar_data = {
            { text = ConfigLanguage.Faction.List, id = 1, img_title = "faction:faction_faction" },
            { text = ConfigLanguage.Faction.Member, id = 2, img_title = "faction:faction_faction", open_func = function()
                return FactionModel:GetInstance():CheckClickPage()
            end },
            { text = ConfigLanguage.Faction.WareHouse, id = 3, img_title = "faction:faction_faction", open_func = function()
                return FactionModel:GetInstance():CheckClickPage()
            end },
            { text = ConfigLanguage.Faction.Skill, id = 4, img_title = "faction:faction_faction", open_func = function()
                return FactionModel:GetInstance():CheckClickPage()
            end },
            { text = ConfigLanguage.Faction.Activity, id = 5, img_title = "faction:faction_faction", show_lv = 60, show_toggle = 1, toggle_data = tog_data, open_func = function()
                return FactionModel:GetInstance():CheckClickPage()
            end },

        }

    else

        self.sidebar_data = {
            { text = ConfigLanguage.Faction.Info, id = 1, img_title = "faction:faction_faction" },
            { text = ConfigLanguage.Faction.Member, id = 2, img_title = "faction:faction_faction" },
            { text = ConfigLanguage.Faction.WareHouse, id = 3, img_title = "faction:faction_faction" },
            { text = ConfigLanguage.Faction.Skill, id = 4, img_title = "faction:faction_faction" },
            { text = ConfigLanguage.Faction.Activity, id = 5, img_title = "faction:faction_faction", show_lv = 60, show_toggle = 1, toggle_data = tog_data },
        }

    end

    if self.roleInfoData.guild == "0" or self.roleInfoData.guild == 0 or self.roleInfoData.gname == "" then
        self.viewCls[1] = FactionListView
    else
        self.viewCls[1] = FactionInfoView
    end

    self.viewCls[2] = FactionMemberView
    self.viewCls[3] = FactionWareView
    self.viewCls[4] = FactionSkillView
    self.viewCls[5] = FactionActivityView
end

function FactionPanel:dctor()

    GlobalEvent:RemoveTabListener(self.gEvents)
    self.gEvents = {}

    for i, v in pairs(self.events) do
        self.model:RemoveListener(v)
    end

    for i, v in pairs(self.viewNode) do
        v:destroy()
    end
end

function FactionPanel:Open(tabIndex, toggleIndex)
    if (type(tabIndex) == "number") then
        self.crntIndex = tabIndex
    end

    if (type(toggleIndex) == "number") then
        self.default_toggle_index = toggleIndex
    end

    self.default_table_index = self.crntIndex

    FactionPanel.super.Open(self)

    self:UpdateRedDot()
end

function FactionPanel:LoadCallBack()
    self.nodes = {
        "panelContain"
    }
    self:GetChildren(self.nodes)

    self:AddEvent()


end

function FactionPanel:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.QuitSucess, handler(self, self.DealQuitSucess))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.FactionCreateSucess, handler(self, self.DealFactionCreate))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.DisbandFaction, handler(self, self.DealDisbandFaction))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.JoinSucuss, handler(self, self.JoinSucuss))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.UpdateRedDot, handler(self, self.UpdateRedDot))
    local function call_back()
        self:Close()
    end
    self.gEvents[#self.events + 1] = GlobalEvent.AddEventListener(DungeonEvent.ENTER_DUNGEON_SCENE, call_back);
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));
end

function FactionPanel:HandleSceneChange(sceneId)
    local config = Config.db_scene[sceneId]
    if not config then
        return
    end

    if config.type == 5 and
            (config.stype == enum.SCENE_STYPE.SCENE_STYPE_GUILD_WAR
                    or config.stype == enum.SCENE_STYPE.SCENE_STYPE_GUILDHOUSE
            ) then
        self:Close()
    end
end

function FactionPanel:UpdateRedDot()
    if self.model.redPoints[1] or self.model.redPoints[3] or self.model.redPoints[5] or self.model.redPoints[6] then
        self:SetIndexRedDotParam(1,true)
    else
        self:SetIndexRedDotParam(1,false)
    end
	
	
    self:SetIndexRedDotParam(4,self.model.redPoints[2])
    self:SetIndexRedDotParam(5,self.model.redPoints[4] or self.model.redPoints[6] or self.model.redPoints[7])


end

function FactionPanel:JoinSucuss()
    self:Close()
    lua_panelMgr:GetPanelOrCreate(FactionPanel):Open()
end

function FactionPanel:DealDisbandFaction()
    self:Close()
end

function FactionPanel:DealQuitSucess()
    self:Close()
end

function FactionPanel:DealFactionCreate()
    self.viewNode[1]:destroy()
    self.viewNode[1] = 0
    self.viewCls[1] = FactionInfoView
    self:SwitchCallBack(1)
end

function FactionPanel:ShowView(toggleId)

    if self.viewNode[self.lastIndex] ~= nil and type(self.viewNode[self.lastIndex]) == "table" then
        --self.viewNode[self.lastIndex]:SetVisible(false)
		if self.viewNode[self.lastIndex]then
			self.viewNode[self.lastIndex]:destroy();
		end
		self.viewNode[self.lastIndex] = nil
    end

    if type(self.viewNode[self.crntIndex]) ~= "table" then
        self.viewNode[self.crntIndex] = self.viewCls[self.crntIndex](self.panelContain, nil)
    else
        --SetVisible(self.viewNode[self.crntIndex].gameObject, true)
        self.viewNode[self.crntIndex]:SetVisible(true)
    end

    if (self.crntIndex == 5) then
        self.viewNode[self.crntIndex]:LoadSubPanel(toggleId)
    end
    self.lastIndex = self.crntIndex
end

function FactionPanel:GetRectTransform()
end

function FactionPanel:OpenCallBack()
    self:UpdateView()
end

function FactionPanel:UpdateView()
    self:SetTabIndex(self.crntIndex)
end

function FactionPanel:CloseCallBack()
    --系统开放时需要
    GlobalEvent:Brocast(EventName.OpenNextSysTipPanel)
end

function FactionPanel:SwitchCallBack(index, toggle_id, update_toggle)
    --if index >= 2 and self.model.roleData.guild == "0" then
    --	Notify.ShowText(ConfigLanguage.Faction.EnterFactionPlease)
    --	return
    --end
    self.crntIndex = index
    self:ShowView(toggle_id)

    --if (index == 5) then
    --    --if update_toggle then
    --    --	local data = {
    --    --		{id = 1, text = "公会争霸"}
    --    --	}
    --    if  self.viewNode[self.crntIndex] and self.viewNode[self.crntIndex].LoadSubPanel then
    --        self.viewNode[self.crntIndex]:LoadSubPanel(toggle_id);
    --    end
    --
    --    self:SetToggleGroup(data, toggle_id)
    --    --end
    --end
end
