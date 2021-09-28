require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.ZongMenLiLian.ZongMenLiLianNotes"

require "Core.Module.ZongMenLiLian.View.ZongMenLiLianPanel"
require "Core.Module.ZongMenLiLian.View.ZongMenLiLianDecPanel"

ZongMenLiLianMediator = Mediator:New();
function ZongMenLiLianMediator:OnRegister()

end

function ZongMenLiLianMediator:_ListNotificationInterests()

    return {
        [1] = ZongMenLiLianNotes.OPEN_ZONGMENLILIANPANEL,
        [2] = ZongMenLiLianNotes.CLOSE_ZONGMENLILIANPANEL,

        [3] = ZongMenLiLianNotes.OPEN_ZONGMENLILIANDECPANEL,
        [4] = ZongMenLiLianNotes.CLOSE_ZONGMENLILIANDECPANEL,

    };

end

function ZongMenLiLianMediator:_HandleNotification(notification)

    if notification:GetName() == ZongMenLiLianNotes.OPEN_ZONGMENLILIANPANEL then
        if (self._panel == nil) then
            self._panel = PanelManager.BuildPanel(ResID.UI_ZONGMENLILIANPANEL, ZongMenLiLianPanel,true);
        end


    elseif notification:GetName() == ZongMenLiLianNotes.CLOSE_ZONGMENLILIANPANEL then

        if (self._panel ~= nil) then
            PanelManager.RecyclePanel(self._panel, ResID.UI_ZONGMENLILIANPANEL)
            self._panel = nil
        end

--------------------------------------------------------------------------------------------
 elseif notification:GetName() == ZongMenLiLianNotes.OPEN_ZONGMENLILIANDECPANEL then
        if (self._ZongMenLiLianDecPanel == nil) then
            self._ZongMenLiLianDecPanel = PanelManager.BuildPanel(ResID.UI_ZONGMENLILIANDECPANEL, ZongMenLiLianDecPanel);
        end


    elseif notification:GetName() == ZongMenLiLianNotes.CLOSE_ZONGMENLILIANDECPANEL then

        if (self._ZongMenLiLianDecPanel ~= nil) then
            PanelManager.RecyclePanel(self._ZongMenLiLianDecPanel)
            self._ZongMenLiLianDecPanel = nil
        end


---------------------------------------------------------------------------------------------------

    end

end

function ZongMenLiLianMediator:OnRemove()

end

