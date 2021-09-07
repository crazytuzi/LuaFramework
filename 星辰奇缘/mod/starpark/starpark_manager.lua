--星辰乐园管理器
--2017/3/1
--zzl

StarParkManager = StarParkManager or BaseClass(BaseManager)

function StarParkManager:__init()
    if StarParkManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    StarParkManager.Instance = self;
    self:InitHandler()
    self.model = StarParkModel.New()

    self.agendaTab = {}
end

function StarParkManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function StarParkManager:InitHandler()

end

--图标
function StarParkManager:SetIcon(data)
    MainUIManager.Instance:DelAtiveIcon(121)

    if data == nil then
    	return
    end

    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[121]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.timestamp = data.targetTime
    self.activeIconData.timeoutCallBack = data.timeoutCallBack
    self.activeIconData.clickCallBack = function()
        StarParkManager.Instance.model:OpenStarParkMainUI({data.index})
    end
    MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
end

function StarParkManager:ShowIcon()
    local data = nil
    for index,v in ipairs(self.model.leftBtnList) do
        if self.agendaTab[v.agendaId] ~= nil then
            data = {index = index, text = self.agendaTab[v.agendaId].text, targetTime = self.agendaTab[v.agendaId].time, timeoutCallBack = self.agendaTab[v.agendaId].timeoutCallBack}
            break
        end
    end

    self:SetIcon(data)
end

