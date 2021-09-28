

RefineDataManager = { }
-- RefineDataManager.refine = { };
local refine_item = { };
-- RefineDataManager.hasInit = false;
local equipment_refine = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_EQUIPMENT_REFINE);

--[[
function RefineDataManager.CheckInit()

    if not RefineDataManager.hasInit then

        -- local rf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_REFINE);
        -- local rfi = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_REFINE_ITEM);

        local equipment_refine = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_EQUIPMENT_REFINE);



        for key, value in pairs(equipment_refine) do
            local kind = value.kind;
            local refine_lev = value.refine_lev;
            local career = value.career;
            local key = career .. "_" .. kind .. "_" .. refine_lev;

            -------------  转换  need_item --------------------------------
            local need_item_obj = { };
            local need_index = 1;
            local need_str = value.need_item;
            for key1, need_item in pairs(need_str) do

                local arr = string.split(need_item, '_');
                local p_id = arr[1] + 0;
                local am = arr[2] + 0;
                local pinfo = ProductInfo:New()

                pinfo:Init( { am = am, spId = p_id });

                need_item_obj[need_index] = pinfo;
                need_index = need_index + 1;

            end

            value.need_item = need_item_obj;
            ---------------------------------------
            refine_item[key] = value;
        end

        RefineDataManager.hasInit = true;
    end
end

]]
-- 获取所有装备的精炼属性累加
function RefineDataManager.GetAllRefine()

    local res = { };

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_career = heroInfo:GetCareer()

    for i = 1, 8 do
        local eq = EquipDataManager.GetProductByKind(i);
        -- {"st":2,"pt":"10100490","id":"106163","am":1,"idx":0,"spId":301000}
        if eq ~= nil then
            local spId = eq.spId;
            local product = ProductManager.GetProductById(spId);
            local quality = product.quality;
            local lev = product.lev;

            if eq.lev ~= nil then
                lev = eq.lev;
            end

            local eqlv = EquipLvDataManager.getItem(i);
            local refine_lev = eqlv.rlv;

            local att = RefineDataManager.GetRefine_item(i, my_career, refine_lev);

            if att ~= nil then

                for att_k, att_v in pairs(att) do

                    if att_k ~= "id" and
                        att_k ~= "kind" and
                        att_k ~= "career" and
                        att_k ~= "lev" and
                        att_k ~= "refine_lev" and
                        att_k ~= "need_item" and
                        att_k ~= "need_money" then

                        if att_v > 0 then
                            if res[att_k] == nil then
                                res[att_k] = 0;
                            end

                            res[att_k] = res[att_k] + att_v;
                        end
                    end
                end
            end
        end
    end

    return res;

end

--  获取 对应装备位置 的 精炼属性
-- function RefineDataManager.GetRefine(kind, quality, lev, refine_lev)
--[[
function RefineDataManager.GetRefine(kind, career, lev, refine_lev)

    RefineDataManager.CheckInit();


    local key = kind .. "_" .. quality .. "_" .. lev .. "_" .. refine_lev;
    return RefineDataManager.refine[key];



end
]]

--[[
 kind  部位
 career 职业
 refine_lev 精练等级
]]
function RefineDataManager.GetRefine_item(kind, career, refine_lev)



    local key = career .. "_" .. kind .. "_" .. refine_lev;
    if refine_item[key] == nil then

        local need_item_obj = { };
        local need_index = 1;

               
        local value =   ConfigManager.TransformConfig(equipment_refine[key]);

        if value == nil then
            return nil;
        end

        local need_str = value.need_item;
        for key1, need_item in pairs(need_str) do

            local arr = string.split(need_item, '_');
            local p_id = arr[1] + 0;
            local am = arr[2] + 0;
            local pinfo = ProductInfo:New()

            pinfo:Init( { am = am, spId = p_id });

            need_item_obj[need_index] = pinfo;
            need_index = need_index + 1;

        end

        value.need_item = need_item_obj;
        ---------------------------------------
        refine_item[key] = value;

    end

    return refine_item[key];

end





