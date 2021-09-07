ExchangeManager = ExchangeManager or BaseClass(BaseManager)

function ExchangeManager:__init()
    if ExchangeManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    ExchangeManager.Instance = self
    self.model = ExchangeModel.New()
    self.Gold = {
        {icon = 3, name = TI18N("金币兑换")},
        {icon = 3, name = TI18N("金币市场")},
        {icon = 15, name = TI18N("职业任务")},
    }
    self.Sliver = {
        {icon = 3, name = TI18N("银币兑换")},
        {icon = 14, name = TI18N("极寒试炼")},
        {icon = 9, name = TI18N("生活技能")},
    }
    self:InitHandler()
end

function ExchangeManager:InitHandler()
    self:AddNetHandler(9908, self.On9908)
    self:AddNetHandler(9909, self.On9909)
end

function ExchangeManager:Require9908()

end

-- 查询双倍点数结果
function ExchangeManager:On9908(dat)
    BaseUtils.dump(dat,"On990888888888888888")
    if dat.enum == 90000 then
        ExchangeManager.Instance.model:OpenPanel(2)
    elseif dat.enum == 90003 then
        ExchangeManager.Instance.model:OpenPanel(1)
    elseif dat.enum == 90002 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
    else
        TipsManager.Instance:ShowItem({itemData = DataItem.data_get[dat.enum]})
    end
end


function ExchangeManager:Require9909(id)
    self.require9909Lock = true
    Connection.Instance:send(9909,{id = id})
end

-- 查询双倍点数结果
function ExchangeManager:On9909(dat)
    BaseUtils.dump(dat,"On9909兑换结果")
    self.require9909Lock = false
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end
