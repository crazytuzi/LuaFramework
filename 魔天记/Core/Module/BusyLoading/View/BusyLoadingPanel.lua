require "Core.Module.Common.Panel"

BusyLoadingPanel = class("BusyLoadingPanel", Panel);

BusyLoadingPanel.TYPE_FOR_GOTOSCENE = 1;

BusyLoadingPanel.ins = nil;

function BusyLoadingPanel:IsFixDepth()
    return true
end

function BusyLoadingPanel:New()
    self = { };
    setmetatable(self, { __index = BusyLoadingPanel });
    return self
end

function BusyLoadingPanel:GetUIOpenSoundName( )
    return ""
end

function BusyLoadingPanel:_Init()
    self:_InitReference();
    self:_InitListener();


end

function BusyLoadingPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txt_title = UIUtil.GetChildInComponents(txts, "txt_title");


    local sliders = UIUtil.GetComponentsInChildren(self._trsContent, "UISlider");
    self.slider_load = UIUtil.GetChildInComponents(sliders, "slider_load");
    self.slider_load.value = 0.5;

    self.enterFrameRun = EnterFrameRun:New();

    BusyLoadingPanel.ins = self;

    MessageManager.AddListener(SceneMap, SceneMap.SELF_CHP_SUB_CHANGE, BusyLoadingPanel.InterrupHandler, self);



end

function BusyLoadingPanel:_InitListener()
end


function BusyLoadingPanel:InterrupHandler(data)

    if data.st == ControllerSeverType.PLAYER then
        BusyLoadingPanel.CheckAndStopLoadingPanel();
    end

end


--[[
 {type=BusyLoadingPanel.TYPE_FOR_GOTOSCENE,tile="使用中.....",hd=MapWorldPanel.GotoSceneHandler, hd_tg = self, hd_data = data }
]]
function BusyLoadingPanel:SetData(data)

    self.data = data;
    self._txt_title.text = self.data.tile;
    self.slider_load.value = 0.01;

    self:Crean();

    self.total_num = 25 * 3;
    self.curr_num = 0;

    self.enterFrameRun:AddHandler(BusyLoadingPanel.SliderUpdataing, self, self.total_num);
    self.enterFrameRun:AddHandler(BusyLoadingPanel.SliderUpdataComplete, self, 1);

    self.enterFrameRun:Start()
end

function BusyLoadingPanel:SliderUpdataing()

    self.curr_num = self.curr_num + 1;
    local curr_pc = self.curr_num / self.total_num;
    self.slider_load.value = curr_pc;

end

function BusyLoadingPanel:SliderUpdataComplete()

    local hd = self.data.hd;
    local hd_tg = self.data.hd_tg;
    local hd_data = self.data.hd_data;

    if hd ~= nil then

        if hd_tg ~= nil then
            hd(hd_tg, hd_data);
        else
            hd(hd_data);
        end
    end

    ModuleManager.SendNotification(BusyLoadingNotes.CLOSE_BUSYLOADINGPANEL);


end


--[[
 检测并停止当前正在 想跳的场景
]]
function BusyLoadingPanel.CheckAndStopLoadingPanel()

    if BusyLoadingPanel.ins ~= nil then
        ModuleManager.SendNotification(BusyLoadingNotes.CLOSE_BUSYLOADINGPANEL);
        return true;
    end

    return false;

end

function BusyLoadingPanel:Crean()
    self.enterFrameRun:Stop();
    self.enterFrameRun:Clean()
end

function BusyLoadingPanel:_Dispose()
    self:_DisposeReference();

    self._txt_title = nil;

    self.slider_load = nil;

    self.enterFrameRun = nil;


end

function BusyLoadingPanel:_DisposeReference()

    self:Crean();
    MessageManager.RemoveListener(SceneMap, SceneMap.SELF_CHP_SUB_CHANGE, BusyLoadingPanel.InterrupHandler);

    self.enterFrameRun = nil;

    self._txt_title = nil;
    self._txtlabel = nil;


    BusyLoadingPanel.ins = nil;
end
