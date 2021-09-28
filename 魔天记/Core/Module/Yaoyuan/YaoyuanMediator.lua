require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Yaoyuan.YaoyuanNotes"

require "Core.Module.Yaoyuan.View.YaoYuanPanel"
require "Core.Module.Yaoyuan.View.ZhongZhiCangKuPanel"
require "Core.Module.Yaoyuan.View.YaoYuanJiLuPanel"
require "Core.Module.Yaoyuan.View.YaoYuanMyXianMenPanel"
require "Core.Module.Yaoyuan.View.YaoYuanDiFangXianMenPanel"
require "Core.Module.Yaoyuan.View.YaoYuanMyXianMenYaoQingPanel"
require "Core.Module.Yaoyuan.View.YaoYuanYaoQingTipPanel"

YaoyuanMediator = Mediator:New();
function YaoyuanMediator:OnRegister()

end

function YaoyuanMediator:_ListNotificationInterests()
    return {
        [1] = YaoyuanNotes.OPEN_YAOYUANROOTPANEL,
        [2] = YaoyuanNotes.CLOSE_YAOYUANROOTPANEL,

        [3] = YaoyuanNotes.OPEN_ZHONGZHICANGKUPANEL,
        [4] = YaoyuanNotes.CLOSE_ZHONGZHICANGKUPANEL,

        [5] = YaoyuanNotes.OPEN_YAOYUANJILUPANEL,
        [6] = YaoyuanNotes.CLOSE_YAOYUANJILUPANEL,

        [7] = YaoyuanNotes.OPEN_YAOYUANMYXIANMENPANEL,
        [8] = YaoyuanNotes.CLOSE_YAOYUANMYXIANMENPANEL,

        [9] = YaoyuanNotes.OPEN_YAOYUANDIFANGXIANMENPANEL,
        [10] = YaoyuanNotes.CLOSE_YAOYUANDIFANGXIANMENPANEL,


        [11] = YaoyuanNotes.OPEN_YAOYUANMYXIANMENYAOQINGPANEL,
        [12] = YaoyuanNotes.CLOSE_YAOYUANMYXIANMENYAOQINGPANEL,

        [13] = YaoyuanNotes.OPEN_YAOYUANYAOQINGTIPPANEL,
        [14] = YaoyuanNotes.CLOSE_YAOYUANYAOQINGTIPPANEL,

    };
end

function YaoyuanMediator:_HandleNotification(notification)


    if notification:GetName() == YaoyuanNotes.OPEN_YAOYUANROOTPANEL then
       
       -- ???????????? ???????? 
       local b = GuildDataManager.InGuild();

       if not b then
         
           MsgUtils.ShowTips("YaoyuanMediator/tip1");
         return;
       end 

        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_YAOYUANROOTPANEL, YaoYuanPanel,true);
        end


    elseif notification:GetName() == YaoyuanNotes.CLOSE_YAOYUANROOTPANEL then

        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_YAOYUANROOTPANEL)
            self._panel = nil
        end

        ------------------------------------------------------
    elseif notification:GetName() == YaoyuanNotes.OPEN_ZHONGZHICANGKUPANEL then
        if (self._cnagkuPanel == nil) then
            self._cnagkuPanel = PanelManager.BuildPanel(ResID.UI_ZHONGZHICANGKUPANEL, ZhongZhiCangKuPanel);
        end

        local idx = notification:GetBody();
        self._cnagkuPanel:SetSelectPlant(idx)

    elseif notification:GetName() == YaoyuanNotes.CLOSE_ZHONGZHICANGKUPANEL then

        if (self._cnagkuPanel ~= nil) then
            PanelManager.RecyclePanel(self._cnagkuPanel)
            self._cnagkuPanel = nil
        end


        -------------------------------------------------------------------------------
    elseif notification:GetName() == YaoyuanNotes.OPEN_YAOYUANJILUPANEL then
        if (self._yaoYuanJiLuPanel == nil) then
            self._yaoYuanJiLuPanel = PanelManager.BuildPanel(ResID.UI_YAOYUANJILUPANEL, YaoYuanJiLuPanel);
        end
    elseif notification:GetName() == YaoyuanNotes.CLOSE_YAOYUANJILUPANEL then

        if (self._yaoYuanJiLuPanel ~= nil) then
            PanelManager.RecyclePanel(self._yaoYuanJiLuPanel)
            self._yaoYuanJiLuPanel = nil
        end

        --------------------------------------------------------------------------------------------------------

    elseif notification:GetName() == YaoyuanNotes.OPEN_YAOYUANMYXIANMENPANEL then
        if (self._yaoYuanMyXianMenPanel == nil) then
            self._yaoYuanMyXianMenPanel = PanelManager.BuildPanel(ResID.UI_YAOYUANMYXIANMENPANEL, YaoYuanMyXianMenPanel);
        end
    elseif notification:GetName() == YaoyuanNotes.CLOSE_YAOYUANMYXIANMENPANEL then
    
        if (self._yaoYuanMyXianMenPanel ~= nil) then
          
            PanelManager.RecyclePanel(self._yaoYuanMyXianMenPanel)
            self._yaoYuanMyXianMenPanel = nil
        end

        -----------------------------------------------------------------------------------
    elseif notification:GetName() == YaoyuanNotes.OPEN_YAOYUANDIFANGXIANMENPANEL then
        if (self._yaoYuanDiFangXianMenPanel == nil) then
            self._yaoYuanDiFangXianMenPanel = PanelManager.BuildPanel(ResID.UI_YAOYUANDIFANGXIANMENPANEL, YaoYuanDiFangXianMenPanel);
        end
    elseif notification:GetName() == YaoyuanNotes.CLOSE_YAOYUANDIFANGXIANMENPANEL then

        if (self._yaoYuanDiFangXianMenPanel ~= nil) then
            PanelManager.RecyclePanel(self._yaoYuanDiFangXianMenPanel)
            self._yaoYuanDiFangXianMenPanel = nil
        end

        ------------------------------  YaoYuanMyXianMenYaoQingPanel  ----------------------------------------------------------
    elseif notification:GetName() == YaoyuanNotes.OPEN_YAOYUANMYXIANMENYAOQINGPANEL then
        if (self._yaoYuanMyXianMenYaoQingPanel == nil) then
            self._yaoYuanMyXianMenYaoQingPanel = PanelManager.BuildPanel(ResID.UI_YAOYUANMYXIANMENYAOQINGPANEL, YaoYuanMyXianMenYaoQingPanel);
        end
    elseif notification:GetName() == YaoyuanNotes.CLOSE_YAOYUANMYXIANMENYAOQINGPANEL then

        if (self._yaoYuanMyXianMenYaoQingPanel ~= nil) then
            PanelManager.RecyclePanel(self._yaoYuanMyXianMenYaoQingPanel,ResID.UI_YAOYUANMYXIANMENYAOQINGPANEL)
            self._yaoYuanMyXianMenYaoQingPanel = nil
        end


        --------------------------------------------------  YaoYuanYaoQingTipPanel   ------------------------------------------------------------------------------------------
    elseif notification:GetName() == YaoyuanNotes.OPEN_YAOYUANYAOQINGTIPPANEL then
        if (self._yaoYuanYaoQingTipPanel == nil) then
            self._yaoYuanYaoQingTipPanel = PanelManager.BuildPanel(ResID.UI_YAOYUANYAOQINGTIPPANEL, YaoYuanYaoQingTipPanel);
        end

        self._yaoYuanYaoQingTipPanel:NeedUpData();

    elseif notification:GetName() == YaoyuanNotes.CLOSE_YAOYUANYAOQINGTIPPANEL then

        if (self._yaoYuanYaoQingTipPanel ~= nil) then
            PanelManager.RecyclePanel(self._yaoYuanYaoQingTipPanel)
            self._yaoYuanYaoQingTipPanel = nil
        end

    end

end

function YaoyuanMediator:OnRemove()

end

