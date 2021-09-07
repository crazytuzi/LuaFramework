-- @author hze
-- @date #2018/11/21#

IntegralExchangeManager = IntegralExchangeManager or BaseClass(BaseManager)

function IntegralExchangeManager:__init()
    if IntegralExchangeManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    IntegralExchangeManager.Instance = self

    self.model = IntegralExchangemodel.New()

    self.OnUpdateItemList = EventLib.New()
    self.OnUpdateIntegral = EventLib.New()
    self.OnUpdateQuestData = EventLib.New()

    self:InitHandler()
end

function IntegralExchangeManager:__delete()
end

function IntegralExchangeManager:RequestInitData()
    self:Send20460()
    self:Send20461()
end

function IntegralExchangeManager:InitHandler()
    self:AddNetHandler(20460, self.On20460)
    self:AddNetHandler(20461, self.On20461)
    self:AddNetHandler(20462, self.On20462)
end

function IntegralExchangeManager:OpenWindow(args)
    self.model:OpenWindow(args)
end


function IntegralExchangeManager:Send20460()
	-- print("发送20460协议")
   self:Send(20460,{})
end

function IntegralExchangeManager:On20460(data)
	-- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20460</color>"))
	self.model:LauncherData(data)
	self.OnUpdateItemList:Fire()
end

function IntegralExchangeManager:Send20461()
	-- print("发送20461协议")
   self:Send(20461,{})
end

function IntegralExchangeManager:On20461(data)
	-- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20461</color>"))
	self.model.questData = data
	self.OnUpdateQuestData:Fire()
end

function IntegralExchangeManager:Send20462(_id, _order_id, _item_id)
	-- print("发送20462协议")
   self:Send(20462,{id = _id, order_id = _order_id, item_id = _item_id})
end

function IntegralExchangeManager:On20462(data)
	-- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20462</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.OnUpdateIntegral:Fire()
end
