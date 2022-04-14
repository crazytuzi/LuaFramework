UIModelManager = UIModelManager or class("UIModelManager", BaseManager)
local this = UIModelManager

function UIModelManager:ctor()
    UIModelManager.Instance = self

    self:Reset()
    --self:AddEvent()
end

function UIModelManager:Reset()

end

function UIModelManager.GetInstance()
    if UIModelManager.Instance == nil then
        UIModelManager()
    end
    return UIModelManager.Instance
end

function UIModelManager:GetTypeByResId(resId)
    local id_tbl = string.split(resId, "_")
    local type = self:GetEnumTypeByResId(id_tbl[2])
    local id
    if type == enum.MODEL_TYPE.MODEL_TYPE_MOUNT then
        id = resId
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_MONSTER then
        id = resId
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_BABY then
        id = resId
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_GOD then
        id = resId
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_NPC then
        id = resId
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_MECHA then
        id = resId
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_ARTIFACT then
        id = resId
    else
        id = string.match(resId, "%d+")
    end
    return type, id
end

--isDefault 是否播放默认状态
function UIModelManager:InitModel(type, id, modelCon, load_callback, is_auto_get_type, size_id, model_data, role_model_config, other_config)
    model_data = model_data or {}
    local size_type = size_id or 3
    if is_auto_get_type then
        type, id = self:GetTypeByResId(id)
    end
    local model
    if type == enum.MODEL_TYPE.MODEL_TYPE_FABAO then
        model = UIFabaoModel(modelCon, id, load_callback)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_MONSTER then
        model = UIMonsterModel(modelCon, id, load_callback)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_MOUNT then
        model = UIMountModel(modelCon, "model_mount_" .. id, load_callback, false)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_NPC then
        model = UINpcModel(modelCon, id, load_callback)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_PET then
		model = UIPetModel(modelCon, id, load_callback)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_ROLE then
        local role = RoleInfoModel.GetInstance():GetMainRoleData()
        local gender = role.gender
        
        local mid = id[1]
        local fashion_type = id[2]
        local cfgData = Config.db_fashion[mid .. "@" .. fashion_type]

        local roleModelId
        if gender == 1 then
            roleModelId = cfgData.man_model
        else
            roleModelId = cfgData.girl_model
        end
        if table.isempty(model_data) then
            model_data = clone(role)
            model_data.figure.fashion_head = {}
            model_data.figure.fashion_head.model = roleModelId
            model_data.figure.fashion_head.show = true
            model_data.figure.weapon = {}
            model_data.figure.weapon.model = roleModelId
            model_data.figure.weapon.show = true
        end
        local config = role_model_config or {}
        if not role_model_config then
            config.res_id = roleModelId
            config.is_show_wing = false
            --config.is_show_leftHand = false
        end
        if other_config then
            config.trans_x = other_config.trans_x or 650
            config.trans_y = other_config.trans_y or 650
        end
        model = UIRoleCamera(modelCon, nil, model_data, size_type, false, nil, config)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_WING then
        model = UIWingModel(modelCon, id, load_callback)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_WEAPON then
        model = UIWingModel(modelCon, id, load_callback, "model_weapon_", "model_weapon_r_")
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_FAIRY then
        model = UIFairyModel(modelCon, id, load_callback)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_FUSHOW then
        model = UIMountModel(modelCon, "model_hand_" .. id, load_callback)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_EQUIP then
        model = UIWingModel(modelCon, id, load_callback, "model_equip_", "model_equip_")
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_BABY then
		if size_type > 9999 then
			model = UIBabyModel(modelCon, id, load_callback, size_type)
		else
			model = UIBabyModel(modelCon, id, load_callback)
		end  
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_GOD then
        model = UIGodModel(modelCon, id, load_callback)
	elseif type == enum.MODEL_TYPE.MODEL_TYPE_BABYWING then
		model = UIWingModel(modelCon, id, load_callback,"model_child_", "model_child_")	
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_MECHA then
        model = UIGodModel(modelCon, id, load_callback)
    elseif type == enum.MODEL_TYPE.MODEL_TYPE_ARTIFACT then
        model = UIGodModel(modelCon, id, load_callback)
    end
    return model
end

function UIModelManager:GetEnumTypeByResId(res_id)
    local result
    local tag = string.lower(res_id)
    if tag == "fabao" then
        result = enum.MODEL_TYPE.MODEL_TYPE_FABAO
    elseif tag == "monster" then
        result = enum.MODEL_TYPE.MODEL_TYPE_MONSTER
    elseif tag == "mount" then
        result = enum.MODEL_TYPE.MODEL_TYPE_MOUNT
    elseif tag == "npc" then
        result = enum.MODEL_TYPE.MODEL_TYPE_NPC
    elseif tag == "pet" then
        result = enum.MODEL_TYPE.MODEL_TYPE_PET
    elseif tag == "role" then
        result = enum.MODEL_TYPE.MODEL_TYPE_ROLE
    elseif tag == "wing" then
        result = enum.MODEL_TYPE.MODEL_TYPE_WING
    elseif tag == "weapon" then
        result = enum.MODEL_TYPE.MODEL_TYPE_WEAPON
    elseif tag == "fairy" then
        result = enum.MODEL_TYPE.MODEL_TYPE_FAIRY
    elseif tag == "hand" then
        result = enum.MODEL_TYPE.MODEL_TYPE_FUSHOW
    elseif tag == "equip" then
        result = enum.MODEL_TYPE.MODEL_TYPE_EQUIP
    elseif tag == "child" then
        result = enum.MODEL_TYPE.MODEL_TYPE_BABY
    elseif tag == "soul" then
        result = enum.MODEL_TYPE.MODEL_TYPE_GOD
    elseif tag == "machiaction" then
        result = enum.MODEL_TYPE.MODEL_TYPE_MECHA
    elseif tag == "sacredware" then
        result = enum.MODEL_TYPE.MODEL_TYPE_ARTIFACT
    end
    return result
end
