FashionManager = FashionManager or BaseClass(BaseManager)

function FashionManager:__init()
    if FashionManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    FashionManager.Instance = self;
    self:InitHandler()

    self.model = FashionModel.New()
end

function FashionManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function FashionManager:InitHandler()
    self:AddNetHandler(13200,self.on13200)
    self:AddNetHandler(13201,self.on13201)
    self:AddNetHandler(13202,self.on13202)
    self:AddNetHandler(13203,self.on13203)
    self:AddNetHandler(13204,self.on13204)
    self:AddNetHandler(13205,self.on13205)
    self:AddNetHandler(13206,self.on13206)
    self:AddNetHandler(13207,self.on13207)
    self:AddNetHandler(13208,self.on13208)
end

function FashionManager:RequestInitData()
    self:request13200()
    self:request13206()
    self:request13207()
end

------------------------------------协议接收逻辑
--时装数据返回
function FashionManager:on13200(data)
    -- print("------------------------------13200返回了")
    -- BaseUtils.dump(data)
    if self.model.current_fashion_list == nil then
        self.model.current_fashion_list = {}
    end
    for i=1,#data.dress do
        local d = data.dress[i]
        --检查是否有新增的时装
        if d.dress_type == 3 and self.model.current_fashion_list[d.dress_type] ~= nil then
            local tempDic = self.model.current_fashion_list[d.dress_type]
            for j=1,#d.fashion_dress do
                local d2 = d.fashion_dress[j]
                if tempDic[d2.base_id] == nil and d2.is_wear == 0 then
                    --有新增的
                    if data.flag == 1 then
                        self.model:InitFashionOpenUI(d2)
                    end
                    break
                end
            end
        end
        --检查是否有新增的武器时装
        if d.dress_type == 1 and self.model.current_fashion_list[d.dress_type] ~= nil then
            local tempDic = self.model.current_fashion_list[d.dress_type]
            for j=1,#d.fashion_dress do
                local d2 = d.fashion_dress[j]
                if tempDic[d2.base_id] == nil and d2.is_wear == 0 then
                    --有新增的
                    self.model:InitWeaponFashionOpenUI(d2)
                    break
                end
            end
        end

        self.model.current_fashion_list[d.dress_type] = {}
        for j=1,#d.fashion_dress do
            local d2 = d.fashion_dress[j]
            d2.active = 1
            self.model.current_fashion_list[d.dress_type][d2.base_id] = d2
        end
    end

    if self.model.dyeing_fashion_list == nil then
        self.model.dyeing_fashion_list = {}
    end
    for i=1,#data.dyeing do
        local d = data.dyeing[i]
        self.model.dyeing_fashion_list[d.dyeing_type] = {}
        for j=1,#d.fashion_dyeing do
            local d2 = d.fashion_dyeing[j]
            d2.active = 1
            self.model.dyeing_fashion_list[d.dyeing_type][d2.dyeing_id] = d2
        end
    end
    self.model.collect_lev = data.collect_lev
    self.model.collect_val = data.collect_val
    self.model.classes_eqm = data.classes_eqm
    self.model.weapon = data.weapon
    self.model:InitWeaponFashion()
    self.model:update_socket()
end

--穿戴
function FashionManager:on13201(data)
    -- -- print("------------------------------13201返回了")
    self.model:CloseFashionOpenUI()
    self.model:Release_buy_btn()
    --穿戴成功了才可以更新
    for i=1,#data.dress do
        local d = data.dress[i]
        for j=1,#d.fashion_dress do
            local d2 = d.fashion_dress[j]
            if self.model.current_fashion_list[d.dress_type] == nil then
                self.model.current_fashion_list[d.dress_type] = {}
            end
            self.model.current_fashion_list[d.dress_type][d2.base_id] = d2
        end
    end
    for i=1,#data.dyeing do
        local d = data.dyeing[i]
        for j=1,#d.fashion_dyeing do
            local d2 = d.fashion_dyeing[j]
            if self.model.dyeing_fashion_list[d.dyeing_type] == nil then
                self.model.dyeing_fashion_list[d.dyeing_type] = {}
            end
            self.model.dyeing_fashion_list[d.dyeing_type][d2.dyeing_id] = d2
        end
    end
    self.model:update_socket()
end

--穿戴饰品
function FashionManager:on13202(data)
    -- -- print("------------------------------13202返回了")
    if data.falg == 1 then --成功
        self.model:CloseFashionBeltConfirmUI()
    else --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)

end

--购买饰品
function FashionManager:on13203(data)
    -- -- print("------------------------------13203返回了")
    if data.falg == 1 then --成功
        self.model:CloseFashionBeltConfirmUI()
    else --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--提升颜值等级
function FashionManager:on13204(data)
    -- -- print("------------------------------13204返回了")
    if data.falg == 1 then --成功
        self.model.collect_lev = data.collect_lev
        self.model.collect_val = data.collect_val
        self.model:OnFaceLevUpSuccess()
        -- self.model:CloseFashionFaceUI()
    else --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--穿戴武器
function FashionManager:on13205(data)
    -- print("------------------------------13205返回了")
    if data.falg == 1 then --成功
        self.model:update_socket()
    else --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--竞技场时装
function FashionManager:on13206(data)
    -- print("------------------------------13206返回了")
    self.model.arenaKingList = data.list
end

--首席时装
function FashionManager:on13207(data)
    -- print("------------------------------13207返回了")
    self.model.classesChiefList = data.list
    self.model.classesChiefList1 = data.list1
    self.model.classesChiefList2 = data.list2
end

function FashionManager:on13208(data)
    -- print("------------------------------13208返回了")
    -- print(data.base_id)

    local data_base = DataFashion.data_base[data.base_id]
    if data_base ~= nil then
        if data_base.type == 1 then
            self.model:InitWeaponFashionOpenUI({ base_id = data.base_id })
        elseif DataFashion.data_suit[data.base_id] ~= nil then
            self.model:InitFashionOpenUI({ base_id = data.base_id })
        end
    end
end

--------------------------------------协议发送逻辑
--执行请求协议
--请求获取时装数据
function FashionManager:request13200()
    -- print('---------------------------------发送13200')
    Connection.Instance:send(13200, {})
end

--请求穿戴时装
function FashionManager:request13201(_hair_dyeing, _hair_base_id, _clothes_dyeing, _clothes_base_id)
    -- -- print("-----------------------------发送13201")
    local send_data = {hair_dyeing = _hair_dyeing, hair_base_id = _hair_base_id, clothes_dyeing = _clothes_dyeing, clothes_base_id = _clothes_base_id}
    Connection.Instance:send(13201, send_data)
end

--穿戴饰品
function FashionManager:request13202(_head_ornament, _belt_ornament)
    -- -- print("------------------------------------发送13202")
    Connection.Instance:send(13202, {head_ornament=_head_ornament, belt_ornament = _belt_ornament})
end

--购买饰品
function FashionManager:request13203(_head_ornament, _head_time_id, _belt_ornament, _belt_time_id)
    -- -- print("------------------------------------发送13203")
    Connection.Instance:send(13203, {head_ornament=_head_ornament, head_time_id = _head_time_id, belt_ornament = _belt_ornament, belt_time_id = _belt_time_id})
end

--提升颜值等级
function FashionManager:request13204()
    -- print("------------------------------------发送13204")
    Connection.Instance:send(13204, {})
end

--请求穿戴武器时装
function FashionManager:request13205(weapon)
    -- print("-----------------------------发送13205, "..weapon)
    local send_data = {weapon = weapon}
    Connection.Instance:send(13205, send_data)
end

--竞技场时装
function FashionManager:request13206()
    -- print("------------------------------------发送13206")
    Connection.Instance:send(13206, {})
end

--首席时装
function FashionManager:request13207()
    -- print("-----------------------------发送13207")
    Connection.Instance:send(13207, {})
end