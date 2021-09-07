-- --------------------------
-- 道具数据结构
-- hosr
-- --------------------------
ItemData = ItemData or BaseClass()

function ItemData:__init()
    -- 协议数据
    self.id = 0 --唯一ID
    self.base_id = 0 --基础ID
    self.bind = 0 --是否绑定 1绑定
    self.craft = 0 --品阶等级
    self.enchant = 0 --强化等级
    self.quantity = 0 --堆叠数量
    self.pos = 0 --位置
    self.step = 0 --品阶
    self.expire_type = BackpackEumn.ExpireType.None --过期类型
    self.expire_time = 0 --过期时间
    self.attr = {} --属性列表 {type,name,flag,val}
    self.extra = {} --扩展属性 {name,value,str}

    -- 配置数据
    self.name = nil --物品名字
    self.icon = nil --图标ID
    self.type = nil --物品类型
    self.quality = nil --物品品质
    self.overlap = nil --最大堆叠数
    self.use_type = nil --使用方式
    self.func = nil --作用
    self.effect_client = {} --客户端效果
    self.desc = nil --描述
    self.lev = nil --等级
    self.classes = nil --职业
    self.sex = nil --性别
    self.tips_type = {} --tips按钮参数

    -- 特殊数据
    self.need = 0 -- 需求数量
    self.super = {} -- 神器各个品质当前属性
    self.superCache = {} --神器各个品质的未保存属性
    self.currLookId = 0 -- 神器当前外观id
end

-- 协议数据更新
function ItemData:SetProto(proto, isEquip)
    for key,val in pairs(proto) do
        self[key] = val
    end
    if isEquip then
        self:SuperWeapon()
    end
end

-- 配置数据初始化
function ItemData:SetBase(base)
    for key,val in pairs(base) do
        if key ~= "id" then
            self[key] = val
        else
            self.base_id = val
        end
    end
end

-- 神器数据收集
function ItemData:SuperWeapon()
    self.super = {}
    self.superCache = {}
    for i,attr_data in ipairs(self.attr) do
        if attr_data.type == GlobalEumn.ItemAttrType.shenqi then
            self.super[attr_data.flag] = attr_data
        elseif attr_data.type == GlobalEumn.ItemAttrType.shenqiCache then
            self.superCache[attr_data.flag] = attr_data
        end
    end

    self.currLookId = 0
    for i,v in ipairs(self.extra) do
        if v.name == 9 then
            -- 神器外观
            self.currLookId = v.value
         end
    end
end