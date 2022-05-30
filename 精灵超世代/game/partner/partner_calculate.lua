-- --------------------------------------------------------------------
-- 伙伴中的一些数据运算
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-7-5
-- --------------------------------------------------------------------
PartnerCalculate = PartnerCalculate or BaseClass()

--是否是伙伴额外属性
function PartnerCalculate.isEquipAttr(key)
    if key == "atk2" or key == "def2" or key == "hp2" or key == "speed2" or key == "hit_rate2" or
     key == "crit_rate2" or key == "hit_magic2" or key == "dodge_magic2" or key== "crit_ratio2" then 
        return true
    end
    return false
end


--判断是否需要千分比显示,参数为数字
function PartnerCalculate.isShowPer(num)
    local value = Config.AttrData.data_id_to_key[num]
    local config = Config.AttrData.data_type[value]
    if config and config == 2 then 
        return true
    end
    return false
end
--判断是否需要千分比显示，参数为字符串
function PartnerCalculate.isShowPerByStr(value)
    local config = Config.AttrData.data_type[value]
    if config and config == 2 then 
        return true
    end
    return false
end


--判断神器是否能穿戴
function PartnerCalculate.getIsCanClothArtifact(bid)
    -- local partner_vo = PartnerController:getInstance():getModel():getPartnerByBid(bid)
    -- if not partner_vo then return false end

    -- local artifact_list = partner_vo.artifact_list or {}
    -- local list = {}
    -- for i,v in pairs(artifact_list) do
    --     list[v.artifact_pos] = v
    -- end

    -- local star = partner_vo.star or 0

    -- local other_star= Config.PartnerData.data_partner_const["assistant_shenqi"].val
    -- local main_star = Config.PartnerData.data_partner_const["main_shenqi"].val

    -- if star >=other_star and not list[1] then 
    --     return true
    -- end

    -- if star >=main_star and not list[2] then 
    --     return true
    -- end

    return false
end


--==============================--
--desc:计算战力的接口
--time:2018-06-21 01:56:53
--@attr_list:
--@return 
--==============================--
function PartnerCalculate.calculatePower(attr_list)
    local total_power = 0
    if attr_list == nil or tableLen(attr_list) == 0 then 
        return total_power
    end
    local key, value = nil, nil
    for k,v in pairs(attr_list) do
        if type(v) == "table" and #v >= 2 then
            key = v[1]
            value = v[2]
        else
            key = k
            value = v
        end
        local power_cinfig  = Config.AttrData.data_power[key]
        if power_cinfig then
            local radio = power_cinfig.power 
            value = value - power_cinfig.not_to_power 
            total_power = total_power + value*radio*0.001
        end
    end
    return math.ceil(total_power)
end
