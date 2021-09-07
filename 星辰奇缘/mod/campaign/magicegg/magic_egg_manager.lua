MagicEggManager = MagicEggManager or BaseClass(BaseManager)

function MagicEggManager:__init()
    if MagicEggManager.Instance then
        return
    end
    MagicEggManager.Instance  = self
    self.model = MagicEggModel.New()

    self:InitHandler()

    self.OnUpdateLuckyDogList = EventLib.New()
    self.OnUpdateCellListEvent = EventLib.New()

    self.OnUpdateFullSubtractionRed = EventLib.New()

    self.FullSubShopTag = "FullSubShopLimit"
end

function MagicEggManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end

    if self.OnUpdateLuckyDogList ~= nil then
        self.OnUpdateLuckyDogList:DeleteMe()
        self.OnUpdateLuckyDogList = nil
    end
end

function MagicEggManager:RequestInitData()
    self:Send20404()
    self:Send20405()
end


function MagicEggManager:InitHandler()
    self:AddNetHandler(20404, self.On20404)
    self:AddNetHandler(20405, self.On20405)
    self:AddNetHandler(20456, self.On20456)
    self:AddNetHandler(20457, self.On20457)
end

function MagicEggManager:Send20404()
    --print("发送20404协议")
    self:Send(20404,{})
end

function MagicEggManager:On20404(data)
    --BaseUtils.dump(data,TI18N("<color=#FF0000>接收20404</color>"))
    self.model:SetData(data)
    self.OnUpdateLuckyDogList:Fire()
end

function MagicEggManager:Send20405()
    --print("发送20405协议")
    self:Send(20405,{})
end

function MagicEggManager:On20405(data)
    --{uint32, state, "1 领取按钮 2 孵化按钮 3 孵化（灰）"}
    self.model.achievebool = data.state
    --BaseUtils.dump(data,TI18N("<color=#FF0000>接收20405</color>"))

end

function MagicEggManager:Send20456()
    -- print("发送20456协议")
    self:Send(20456,{})
end

function MagicEggManager:On20456(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20456</color>"))
    self.model.cellInfolist = BaseUtils.copytab(data)
    self.OnUpdateCellListEvent:Fire()
    self.OnUpdateFullSubtractionRed:Fire()
end

function MagicEggManager:Send20457(proto_data)
    print("发送20457协议")
    self:Send(20457,{item_list = proto_data})
end

function MagicEggManager:On20457(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20457</color>"))
    if data.flag == 1 then
        self:Send20456()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
