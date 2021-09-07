-- @author pwj
-- @date 2018年1月6日,星期六

FashionDiscountManager = FashionDiscountManager or BaseClass(BaseManager)

function FashionDiscountManager:__init()
    if FashionDiscountManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    FashionDiscountManager.Instance = self

    self:InitHandler()
    self.model = FashionDiscountModel.New()

    self.fashionData = {}
end

function FashionDiscountManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function FashionDiscountManager:InitHandler()
    self:AddNetHandler(20416,self.on20416)   --时装信息
    self:AddNetHandler(20417,self.on20417)   --购买协议
end

function FashionDiscountManager:RequestInitData()
    --登录请求数据
    self:send20416()
end

function FashionDiscountManager:send20416(data)
    --print("--------20416协议数据---------")
    Connection.Instance:send(20416, {})
end

function FashionDiscountManager:on20416(data)
    -- BaseUtils.dump(data,"On20416")
    self.fashionData = data
    self.model:InitFashionList()
end

function FashionDiscountManager:send20417(data)
    Connection.Instance:send(20417,data)
end

function FashionDiscountManager:on20417(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
