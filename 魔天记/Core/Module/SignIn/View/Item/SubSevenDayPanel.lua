require "Core.Module.Common.UIComponent"

require "Core.Module.SignIn.View.Item.SubSevenDayItem"

SubSevenDayPanel = class("SubSevenDayPanel", UIComponent);


local _sortfunc = table.sort 

function SubSevenDayPanel:New(trs)
    self = { };
    setmetatable(self, { __index = SubSevenDayPanel });
    if (trs) then
        self:Init(trs)
    end
    return self
end


function SubSevenDayPanel:_Init()
    self._isInit = false

    self:_InitReference();
    self:_InitListener();

end

function SubSevenDayPanel:_InitReference()

  
    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, SubSevenDayItem)

    self.actTimeValueTxt = UIUtil.GetChildByName(self._transform, "UILabel", "actTimeValueTxt")

    local listData = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SERVICE_LEVELING);
    local day = listData[1].days;

    local newTime = KaiFuManager.GetKaiFuHasTime(day);
    newTime.hour = 23;
    newTime.min = 59;
    newTime.sec = 59;

    if newTime.month < 10 then
        newTime.month = "0" .. newTime.month;
    end

    if newTime.day < 10 then
        newTime.day = "0" .. newTime.day;
    end


    self.actTimeValueTxt.text = LanguageMgr.Get("SubSevenDayPanel/label1", newTime);

    self:UpdatePanel()

    MessageManager.AddListener(SignInProxy, SignInProxy.MESSAGE_GETCHONGJIINFOS_SUCCESS, SubSevenDayPanel.InfoChangeHandler, self);

    SignInProxy.GetChongJiInfos()
end



function SubSevenDayPanel:_InitListener()

end


function SubSevenDayPanel:GetInfo(list, id)
    local list_num = table.getn(list);

    for i = 1, list_num do
        if list[i].id == id then
            return list[i];
        end
    end

    return nil;
end

function SubSevenDayPanel:InfoChangeHandler(list)

     SubSevenDayItem.needTip = false;

    local listData = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SERVICE_LEVELING);
    local list_num = table.getn(listData);


    for i = 1, list_num do

        local info = self:GetInfo(list, listData[i].id);
        --  l:[(id(????id) :Int,f??Int ??????????(0?????????? 1???????????????? 2????????)]

        if info ~= nil then
            listData[i].f = info.f;

            if info.f == 0 then
                listData[i].order = 50;
            elseif info.f == 1 then
                listData[i].order = 100;
            elseif info.f == 2 then
                listData[i].order = 0;
            end

        else
            listData[i].f = 0;
            listData[i].order = 5;
        end

    end

    -- ????
    _sortfunc(listData, function(a, b) return(a.order + 10 - a.id) >(b.order + 10 - b.id) end);



    self._phalanx:Build(list_num, 1, listData);



     ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANELTIP);
end

function SubSevenDayPanel:_Dispose()

    MessageManager.RemoveListener(SignInProxy, SignInProxy.MESSAGE_GETCHONGJIINFOS_SUCCESS, SubSevenDayPanel.InfoChangeHandler);

end

function SubSevenDayPanel:_DisposeReference()


end

function SubSevenDayPanel:UpdatePanel()

end

