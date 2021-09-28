require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.MainUI.MainUINotes"
require "Core.Module.Ride.RideNotes"
require "Core.Module.FirstRechargeAward.FirstRechargeAwardNotes"
require "Core.Module.Equip.EquipNotes"
require "Core.Module.Skill.SkillNotes"
require "Core.Module.Realm.RealmNotes"
require "Core.Module.MainUI.View.AchievemenRewardPanel"
require "Core.Module.SignIn.SignInNotes"
require "Core.Module.Guild.GuildNotes"
require "Core.Module.Pet.PetNotes"
require "Core.Module.Wing.WingNotes"
require "Core.Module.VipTry.VipTryNotes"

require "Core.Module.MainUI.View.MainUIPanel";
require "Core.Module.MainUI.View.MyRolePanel";
require "Core.Module.MainUI.View.RelivePanel";
require "Core.Module.MainUI.View.RelivePanel1";
require "Core.Module.MainUI.View.RelivePanel2";

require "Core.Module.MainUI.View.TitleAttrPanel";
require "Core.Module.MainUI.View.RoleAttrPanel";
local MainSysExpandPanel = require "Core.Module.MainUI.View.MainSysExpandPanel";

require "Core.Module.Common.PlayerMsgPanel";
require "Core.Module.Common.SkillTipPanel";

local SysOpenInfoTipPanel = require "Core.Module.MainUI.View.SysOpenInfoTipPanel";

MainUIMediator = Mediator:New();
function MainUIMediator:OnRegister()

end
local notice =
{
        MainUINotes.OPEN_MAINUIPANEL,
        MainUINotes.CLOSE_MAINUIPANEL,
        MainUINotes.HIDE_MAINUIPANEL,
        MainUINotes.SHOW_MAINUIPANEL,
        MainUINotes.OPEN_MYROLEPANEL,
        MainUINotes.CLOSE_MYROLEPANEL,
        MainUINotes.UPDATE_MYROLEPANEL,
        MainUINotes.OPEN_RELIVEPANEL,
        MainUINotes.CLOSE_RELIVEPANEL,
        MainUINotes.CHANGE_ACHIEVEMENT_INDEX,
        MainUINotes.OPEN_ACHIEVEMENTREWARD,
        MainUINotes.CHANGE_TITLE_INDEX,
        MainUINotes.OPEN_TITLEATTRPANEL,
        MainUINotes.CLOSE_TITLEATTRPANEL,
        MainUINotes.OPEN_ROLEATTRPANEL,
        MainUINotes.CLOSE_ROLEATTRPANEL,
        MainUINotes.OPEN_TITLENOTICE,
        MainUINotes.OPEN_PLAYER_MSG_PANEL,
        -- TrumpNotes.CLOSE_TRUMPPANEL,
        RideNotes.CLOSE_RIDEPANEL,
        FirstRechargeAwardNotes.CLOSE_FIRSTRECHARGEAWARDPANEL,
        EquipNotes.MES_CLOSE_EQUIPMAINPANELL,
        SkillNotes.CLOSE_SKILLPANEL,
        RealmNotes.CLOSE_REALM,
        SignInNotes.CLOSE_SIGNINPANEL,        
        GuildNotes.CLOSE_GUILDPANEL,
        MainUINotes.CLOSE_TITLENOTICE,
        MainUINotes.CLOSE_ACHIEVEMENTREWARD,
        PetNotes.CLOSE_PETPANEL,
        WingNotes.CLOSE_WINGPANEL,
        VipTryNotes.USE_VIP_TRY,
        MainUINotes.OPEN_SKILL_TIP_PANEL,
        MainUINotes.CLOSE_SKILL_TIP_PANEL,

        MainUINotes.OPEN_SYSOPENTIPPANEL,
        MainUINotes.CLOSE_SYSOPENTIPPANEL,
        MainUINotes.OPEN_SYS_EXPAND_PANEL,
        MainUINotes.CLOSE_SYS_EXPAND_PANEL,
}
function MainUIMediator:_ListNotificationInterests()
    return notice
end

function MainUIMediator:_HandleNotification(notification)
    local t = notification:GetName()
    if t == MainUINotes.OPEN_MAINUIPANEL then
        if (self._mainUIPanel == nil) then
            self._mainUIPanel = PanelManager.BuildPanel(ResID.UI_MAINUIPANEL, MainUIPanel, false, MainUINotes.CLOSE_MAINUIPANEL);
            -- 第一次打开界面拉取次要数据
            SocketClientLua.Get_ins():SendMessage(CmdType.Get_MinorData, { });
            --PanelManager.OnMainUIShow()
        end
    elseif t == MainUINotes.CLOSE_MAINUIPANEL then
        if (self._mainUIPanel ~= nil) then
            PanelManager.RecyclePanel(self._mainUIPanel, ResID.UI_MAINUIPANEL)
            self._mainUIPanel = nil
            PanelManager.OnMainUIHide();
        end
    elseif t == MainUINotes.HIDE_MAINUIPANEL then
        if (self._mainUIPanel ~= nil) then
            self._mainUIPanel:SetCastSkillOperateEnable(false);
            --Warning(tostring(GameSceneManager.mapId)..tostring(GameSceneManager.mapId=="10012_06"))
            --if GameSceneManager.mapId ~= "10012_06" then
                self._mainUIPanel:SetPanelLayer(false)
            --else
               --self._mainUIPanel._gameObject:SetActive(false)
            -- end
            PanelManager.OnMainUIHide();
        end
    elseif t == MainUINotes.SHOW_MAINUIPANEL then
        if (self._mainUIPanel ~= nil) then
            --Warning(tostring(GameSceneManager.old_mapId)..tostring(GameSceneManager.old_mapId=="10012_06"))
            --if GameSceneManager.old_mapId ~= "10012_06" then
                self._mainUIPanel:SetPanelLayer(true)
            --else
            --   self._mainUIPanel._gameObject:SetActive(true)
           -- end
            self._mainUIPanel:SetCastSkillOperateEnable(true);
            self._mainUIPanel:UpdateMainUIPanel();
            PanelManager.OnMainUIShow();
        end
    elseif t == MainUINotes.OPEN_MYROLEPANEL then
        if (self._myRolePanel == nil) then
            self._myRolePanel = PanelManager.BuildPanel(ResID.UI_MYROLEPANEL, MyRolePanel, true);
            local data = notification:GetBody()
            if data then self._myRolePanel:ChangeRightPanel(data[1], data[2]) end
        end
    elseif t == MainUINotes.CLOSE_MYROLEPANEL then
        if (self._myRolePanel ~= nil) then
            PanelManager.RecyclePanel(self._myRolePanel)
            self._myRolePanel = nil
        end
        if self._mainUIPanel then 
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgRole()
            sp:_UpdateMsgMenu()
        end
    elseif t == MainUINotes.UPDATE_MYROLEPANEL then
        if (self._myRolePanel ~= nil) then
            self._myRolePanel:UpdateRolePanel()
        end
    elseif t == MainUINotes.OPEN_RELIVEPANEL then
        local data = notification:GetBody()
        if (self._relivePanel == nil) then

            self._reliveConfig = data[2]
            if (self._reliveConfig.id == 0) then
                self._relivePanel = PanelManager.BuildPanel(ResID.UI_RELIVEPANEL0, RelivePanel, false, MainUINotes.CLOSE_RELIVEPANEL);
            elseif self._reliveConfig.id == 1 then
                self._relivePanel = PanelManager.BuildPanel(ResID.UI_RELIVEPANEL1, RelivePanel1, false, MainUINotes.CLOSE_RELIVEPANEL);
            elseif self._reliveConfig.id == 2 or self._reliveConfig.id == 3 then
                self._relivePanel = PanelManager.BuildPanel(ResID.UI_RELIVEPANEL2, RelivePanel2, false, MainUINotes.CLOSE_RELIVEPANEL);
            elseif self._reliveConfig.id == 4 then
                local id = GameSceneManager.GetId();
                local mapCfg = ConfigManager.GetMapById(id);
                if VIPManager.GetSelfVIPLevel() < mapCfg.vip_level then
                    local kn = data[1].kn;
                    local str = kn and LanguageMgr.Get("WildBossVip/relive", {kn = kn, vip = mapCfg.vip_level}) or LanguageMgr.Get("RelivePanel/reliveNotice3")
                    MsgUtils.PopPanel(nil, nil, nil, str, nil, function() MainUIProxy.SendRelive(0) end, 10);
                else
                    self._relivePanel = PanelManager.BuildPanel(ResID.UI_RELIVEPANEL0, RelivePanel, false, MainUINotes.CLOSE_RELIVEPANEL);
                end
            end
        end

        if (self._relivePanel) then
            self._relivePanel:UpdateRelivePanel(data[1], data[2])
        end
    elseif t == MainUINotes.CLOSE_RELIVEPANEL then

        if (self._relivePanel ~= nil) then
            if (self._reliveConfig.id == 0) then
                PanelManager.RecyclePanel(self._relivePanel, ResID.UI_RELIVEPANEL0)
            elseif self._reliveConfig.id == 1 then
                PanelManager.RecyclePanel(self._relivePanel, ResID.UI_RELIVEPANEL1)
            elseif self._reliveConfig.id == 2 or self._reliveConfig.id == 3 then
                PanelManager.RecyclePanel(self._relivePanel, ResID.UI_RELIVEPANEL2)
            elseif self._reliveConfig.id == 4 then
                PanelManager.RecyclePanel(self._relivePanel, ResID.UI_RELIVEPANEL0)
            end
            self._relivePanel = nil
        end
        self._reliveConfig = nil
    elseif t == MainUINotes.CHANGE_ACHIEVEMENT_INDEX then
        if (self._myRolePanel ~= nil) then
            self._myRolePanel:UpdateAchievementSelect(notification:GetBody())
        end
     elseif t == MainUINotes.OPEN_ACHIEVEMENTREWARD then
        if (self._achievementRewadPanel == nil) then
            self._achievementRewadPanel = PanelManager.BuildPanel(ResID.UI_ACHIEVEMENREWARDPANEL, AchievemenRewardPanel,false,MainUINotes.CLOSE_ACHIEVEMENTREWARD);
        end
        self._achievementRewadPanel:UpdatePanel(notification:GetBody())
    elseif t == MainUINotes.CLOSE_ACHIEVEMENTREWARD then
        if (self._achievementRewadPanel ~= nil) then
            PanelManager.RecyclePanel(self._achievementRewadPanel, ResID.UI_ACHIEVEMENREWARDPANEL)
            self._achievementRewadPanel = nil
        end
    elseif t == MainUINotes.CHANGE_TITLE_INDEX then
        if (self._mainUIPanel ~= nil) then
            self._myRolePanel:UpdateTitleSelect(notification:GetBody())
        end
    elseif t == MainUINotes.OPEN_TITLENOTICE then
        if (self._mainUIPanel ~= nil) then
            local data = notification:GetBody()
            if(self._titlePanel == nil) then
                self._titlePanel = PanelManager.BuildPanel(ResID.UI_TITLEPANEL, TitlePanel,false,MainUINotes.CLOSE_TITLENOTICE);
            end

            self._titlePanel:UpdatePanel(data[1], data[2])
        end
    elseif t == MainUINotes.CLOSE_TITLENOTICE then
         if (self._titlePanel ~= nil) then
            PanelManager.RecyclePanel(self._titlePanel, ResID.UI_TITLEPANEL)
            self._titlePanel = nil
        end
    elseif t == MainUINotes.OPEN_TITLEATTRPANEL then
        if (self._titleAttrPanel == nil) then
            self._titleAttrPanel = PanelManager.BuildPanel(ResID.UI_TITLEATTRPANEL, TitleAttrPanel);
        end

    elseif t == MainUINotes.CLOSE_TITLEATTRPANEL then
        if (self._titleAttrPanel ~= nil) then
            PanelManager.RecyclePanel(self._titleAttrPanel, ResID.UI_TITLEATTRPANEL)
            self._titleAttrPanel = nil
        end

    elseif t == MainUINotes.OPEN_ROLEATTRPANEL then
        if (self._roleAttrPanel == nil) then
            self._roleAttrPanel = PanelManager.BuildPanel(ResID.UI_ROLEATTRPANEL, RoleAttrPanel);
        end
    elseif t == MainUINotes.CLOSE_ROLEATTRPANEL then
        if (self._roleAttrPanel ~= nil) then
            PanelManager.RecyclePanel(self._roleAttrPanel, ResID.UI_ROLEATTRPANEL)
            self._roleAttrPanel = nil
        end

    elseif t == MainUINotes.OPEN_PLAYER_MSG_PANEL then
        if (self._playerMsgPanel == nil) then
            self._playerMsgPanel = PanelManager.BuildPanel(ResID.UI_PLAYERMSGPANEL, PlayerMsgPanel);
        else
            self._playerMsgPanel:Show()
        end
        local ps = notification:GetBody()
        self._playerMsgPanel:InitData(ps)
--    elseif t == TrumpNotes.CLOSE_TRUMPPANEL then
--        if self._mainUIPanel ~= nil then
--            local sp = self._mainUIPanel._sysPanelLogic
--            sp:UpdateMsgTrump()
--            sp:_UpdateMsgMenu()
--        end
    elseif t == RideNotes.CLOSE_RIDEPANEL then
        if self._mainUIPanel ~= nil then
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgRide()
            sp:_UpdateMsgMenu()
        end
    elseif t == FirstRechargeAwardNotes.CLOSE_FIRSTRECHARGEAWARDPANEL then
        if self._mainUIPanel ~= nil then
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgRecharge()
            sp:_UpdateMsgMenu()
        end
    elseif t == EquipNotes.MES_CLOSE_EQUIPMAINPANELL then
        if self._mainUIPanel ~= nil then
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgEqu()
            sp:_UpdateMsgMenu()
        end
    elseif t == SkillNotes.CLOSE_SKILLPANEL then
        if self._mainUIPanel ~= nil then
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgSkill()
            sp:_UpdateMsgMenu()
        end
    elseif t == RealmNotes.CLOSE_REALM then
        if self._mainUIPanel ~= nil then
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgRealm()
            sp:_UpdateMsgMenu()
        end
    elseif t == SignInNotes.CLOSE_SIGNINPANEL then
        if self._mainUIPanel ~= nil then
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgWelfare()
            sp:_UpdateMsgMenu()
        end
        -- elseif t == FriendNotes.CLOSE_FRIENDPANEL then
        --    if self._mainUIPanel ~= nil then self._mainUIPanel:UpdateMsgFriend() end
    elseif t == GuildNotes.CLOSE_GUILDPANEL then
        if self._mainUIPanel ~= nil then
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgAlliance()
            sp:_UpdateMsgMenu()
        end
    elseif t == PetNotes.CLOSE_PETPANEL then
        if self._mainUIPanel ~= nil then
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgPartner()
            sp:_UpdateMsgMenu()
        end
    elseif t == WingNotes.CLOSE_WINGPANEL then
        if self._mainUIPanel ~= nil then
            local sp = self._mainUIPanel._sysPanelLogic
            sp:UpdateMsgWing()
            sp:_UpdateMsgMenu()
        end
    elseif t == VipTryNotes.USE_VIP_TRY then
        if self._mainUIPanel ~= nil then
            local bd = notification:GetBody()
            self._mainUIPanel:VipTry(bd)
        end
    elseif t == MainUINotes.OPEN_SKILL_TIP_PANEL then
		if(self._skillPanel == nil) then
			self._skillPanel = PanelManager.BuildPanel(ResID.UI_SKILL_TIPS_PANEL, SkillTipPanel)
            self._skillPanel:UpdatePanel(notification:GetBody())-- { icon_id, name, desc, getDes}
		end
    elseif t == MainUINotes.CLOSE_SKILL_TIP_PANEL then
		if(self._skillPanel ~= nil) then
			PanelManager.RecyclePanel(self._skillPanel, ResID.UI_SKILL_TIPS_PANEL)
			self._skillPanel = nil
		end

        ---------------------------------

    elseif t == MainUINotes.OPEN_SYSOPENTIPPANEL then
        if (self._sysOpenInfoTipPanel == nil) then
            self._sysOpenInfoTipPanel = PanelManager.BuildPanel(ResID.UI_SYSOPENINFOTIPPANEL, SysOpenInfoTipPanel);    
        end
        local data = notification:GetBody()
        self._sysOpenInfoTipPanel:SetData(data);

    elseif t == MainUINotes.CLOSE_SYSOPENTIPPANEL then
        if (self._sysOpenInfoTipPanel ~= nil) then
            PanelManager.RecyclePanel(self._sysOpenInfoTipPanel)
            self._sysOpenInfoTipPanel = nil
        end
    elseif t == MainUINotes.OPEN_SYS_EXPAND_PANEL then
        if(self._exSysPanel == nil) then
            self._exSysPanel = PanelManager.BuildPanel(ResID.UI_SYSEXPAND_PANEL, MainSysExpandPanel)
        end
        self._exSysPanel:SetOpenParam(notification:GetBody());

    elseif t == MainUINotes.CLOSE_SYS_EXPAND_PANEL then
        if(self._exSysPanel ~= nil) then
            PanelManager.RecyclePanel(self._exSysPanel, ResID.UI_SYSEXPAND_PANEL)
            self._exSysPanel = nil
        end
    end

end

function MainUIMediator:OnRemove()
    if (self._relivePanel ~= nil) then
        PanelManager.RecyclePanel(self._relivePanel)
        self._relivePanel = nil
    end
    if (self._playerMsgPanel ~= nil) then
        PanelManager.RecyclePanel(self._playerMsgPanel)
        self._playerMsgPanel = nil
    end
	if(self._skillPanel ~= nil) then
		PanelManager.RecyclePanel(self._skillPanel, ResID.UI_SKILL_TIPS_PANEL)
		self._skillPanel = nil
	end
end

