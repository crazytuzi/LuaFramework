-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      物品结构，包含道具和装备的
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GoodsVo = GoodsVo or BaseClass(EventDispatcher)

GoodsVo.UPDATE_GOODS_ATTR = "goodsVo_update_attr"
GoodsVo.UPDATE_EQUIP_ATTR = "goodsVo_update_equip_attr"

function GoodsVo:__init(base_id)
	self.id 			    = 0				-- 物品唯一id
    self.bind    		    = 0             -- 是否绑定 0:非绑;1:绑定
    self.quantity 		    = 0 			-- 物品堆叠数量
    self.pos                = 0             -- 物品位置
    self.expire_type        = 0             -- 过期类型
    self.expire_time        = 0             -- 过期事件

    --装备用
    self.main_attr          = {}            -- 主属性
    self.enchant            = 0             -- 精炼等级
    self.attr               = {}            -- 精炼属性
    self.score              = 0             -- 评分
    self.all_score          = 0             -- 总评分
    self.extra              = {}            -- 扩展属性(神器用)   
    self.extra_attr         = {}            -- 神器重铸未保存的属性
    self.holy_eqm_attr      = {}            -- 神装的随机属性

    self.is_add             =0              --是否是增加数量，0.默认值，1.增加，2.减少

    self.quality            = 0
    self.lev                = 0

    self.gemstone_sort      = 0             -- 用于装备排序时候考虑到宝石的问题,这个直接去宝石的总等级就算了
    self.have_gemstone      = false
    self.is_gemstone_change = false         -- 宝石是否变化过,如果变化过,那么红单值需要重新计算

    self.gemstones          = {}            -- 装备中镶嵌宝石的数据{lev = 等级}
    self:setBaseId(base_id)
end

--==============================--
--desc:可以外部改表当前创建的数据对象,避免重复创建
--time:2018-07-27 09:32:35
--@base_id:
--@return 
--==============================---
function GoodsVo:setBaseId(base_id)
    base_id = base_id or 0
    self.base_id = base_id
    self.config = Config.ItemData.data_get_data(base_id)
    if self.config ~= nil then
        self.use_type = self.config.use_type or 0
        self.quality = self.config.quality or 0
        self.sub_type = self.config.sub_type or 0
        self.lev = self.config.lev
        self.sort = Config.ItemData.data_item_sort[self.config.type] or 0
        self.eqm_star = self.config.eqm_star or 0
        self.eqm_jie = self.config.eqm_jie or 0

        --神装需要字段
        if self.config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then
            self.eqm_set = self.config.eqm_set
        end
        -- 如果是家园家具，则初始化一些家具数据
        local home_unit_cfg = Config.HomeData.data_home_unit(base_id)
        if home_unit_cfg then
            self.unit_type = home_unit_cfg.type
        end
    end
end

--==============================--
--desc:设置精炼相关属性
--time:2018-07-27 09:33:36
--@enchant:
--@attr:
--@return 
--==============================--
function GoodsVo:setEnchantInfo(enchant, attr)
    self.enchant = enchant
    self.attr = attr
end

--数据赋值(对传过来的协议进行赋值)
function GoodsVo:initAttrData(data_list)
    if data_list then
        for k, v in pairs(data_list) do
            if k == "quantity" then 
                if v > self.quantity then 
                    self.is_add = 1
                elseif v < self.quantity then 
                    self.is_add = 2
                else
                    self.is_add = 0
                end 
            end
            self:setGoodsAttr(k, v)
        end
    end

    --是神器计算一次评分 --by lwc
    if self.config and self.config.type == BackPackConst.item_type.ARTIFACTCHIPS then
        self:calculateArtifactScore()
    end
end

--获取物品的相关属性
function GoodsVo:getGoodsAttr(key)
    return self[key]
end

--==============================--
--desc:获取装备的基础积分(战力)
--time:2018-07-27 09:47:23
--@return 
--==============================--
function GoodsVo:getEquipBaseScore()
    if self.config == nil or self.config.ext == nil or self.config.ext[1] == nil or self.config.ext[1][2] == nil then 
        return 0 
    end
    local base_attr = self.config.ext[1][2]
    self.score = PartnerCalculate.calculatePower(base_attr) 
    return self.score
end

--==============================--
--desc:获取装备的基础属性
--time:2018-07-27 11:04:21
--@return 
--==============================--
function GoodsVo:getEquipBaseAttr()
    if self.config == nil or self.config.ext == nil or self.config.ext[1] == nil or self.config.ext[1][2] == nil then 
        return 0 
    end
    local base_attr = self.config.ext[1][2]
    return base_attr
end

--计算符文(神器)评分..--by lwc
function GoodsVo:calculateArtifactScore()
    local const_config  = Config.PartnerArtifactData.data_artifact_const
    local score = 0
    for i,value in ipairs(self.extra) do
        if value and value.extra_k and (value.extra_k == 1 or value.extra_k == 2 or value.extra_k == 8) then
            local config = Config.SkillData.data_get_skill(value.extra_v)
            if config then
                local skill_lev = config.level or 1
                local skillstr = "skill_score_"..skill_lev
                if const_config[skillstr] and const_config[skillstr].val then 
                    score = score + const_config[skillstr].val
                end
            end
        end
    end
    self.all_score = score
end

--==============================--
--desc:外部设置总积分,因为在进阶橙装的时候有用到
--time:2018-07-27 09:54:27
--@score:
--@return 
--==============================--
function GoodsVo:setEnchantScore(score)
    local enchant_score = score
    local base_score = self:getEquipBaseScore()
    self.all_score = base_score + enchant_score
end

--设置物品的相关属性
function GoodsVo:setGoodsAttr(key, value)
    if key == "gemstones" then
        self:gemstonesList(value)
    else
        if self[key] ~= value then
            if key == "base_id" then
                self:setBaseId(value)
            end
            self[key] = value
            self:dispatchUpdateAttrByKey(key, value)
        end
    end
end

--==============================--
--desc:设置宝石属性,现在宝石不是物品了,只是一个等级的数值
--time:2018-10-20 02:56:33
--@value:
--@return 
--==============================--
function GoodsVo:gemstonesList(value)
    self.gemstones = {}
    self.have_gemstone = false
    self.is_gemstone_change = true
    self.gemstone_sort = 0
    for i,v in ipairs(value) do
        self.gemstones[i] = v
        self.gemstone_sort = self.gemstone_sort + v.lev
        if v.lev ~= 0 then
            self.have_gemstone = true
        end
    end
    table.sort(self.gemstones, function(a,b) 
        return a.lev > b.lev
    end)
    self:dispatchUpdateAttrByKey("gemstones", value)
end

--派发单个属性数据的变化
function GoodsVo:dispatchUpdateAttrByKey(key, value)
    self:Fire(GoodsVo.UPDATE_GOODS_ATTR, key, value)
end

--[[
    @desc:基于自身,针对于宝石来说,判断是否需要显示红点
    author:{author}
    time:2018-09-02 12:07:32
    @return:
]]
function GoodsVo:checkGemStone()
    if self.is_gemstone_change == true or self.gem_red_status ~= nil then
        local is_red_status = false
        if self.gemstones and tableLen(self.gemstones) > 0 then
            local role_vo = RoleController:getInstance():getRoleVo()
            local lev = role_vo and role_vo.lev or 0
            --开启等级
            local limit_lev = Config.PartnerGemstoneData.data_const["gem_open_lev"].val
            if lev >= limit_lev then
                --宝石碎片id
                local stone_chip_id = Config.PartnerGemstoneData.data_const["gem_fragments"].val    
                local stone_count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(stone_chip_id)

                local min_item = self.gemstones[#self.gemstones] or {} --最后一个肯定是最小等级的
                local min_lev = min_item.lev or 0
                local key = getNorKey(self.config.type, min_lev)
                local next_key = getNorKey(self.config.type, min_lev + 1)
                local stone_config = Config.PartnerGemstoneData.data_upgrade[key]
                local next_config = Config.PartnerGemstoneData.data_upgrade[next_key]
                -- 拥有宝石碎片 > 消耗值
                if next_config and lev >= next_config.limit_lev and stone_config and stone_count >= stone_config.expend then
                    is_red_status = true
                end
            end
        end
        self.is_gemstone_change = false
        self.gem_red_status = is_red_status
    end
    return self.gem_red_status
end