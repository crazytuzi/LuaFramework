
-- 绑定某个 Transform 并检测某个触发方法
ItemMoveManager = { };

ItemMoveManager.bind_name = { };
ItemMoveManager.bind_name.backBag_main_bt = "backBag_main_bt";
ItemMoveManager.bind_name.skill1 = "skill1";
ItemMoveManager.bind_name.skill2 = "skill2";
ItemMoveManager.bind_name.skill3 = "skill3";
ItemMoveManager.bind_name.skill4 = "skill4";


ItemMoveManager.interface_ids = { }
ItemMoveManager.interface_ids.getProAndMoveToBt = "getProAndMoveToBt";
ItemMoveManager.interface_ids.getNewSkillAndMoveToBt = "getNewSkillAndMoveToBt";

local cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ITEM_MOVE)


local list = { };
local cfMap = { };

function ItemMoveManager.Bind(tf, bind_name)
    list[bind_name] = tf;
end

function ItemMoveManager.GetCf(interface_id)
    local res = { };

    for key, value in pairs(cf) do
        if value.interface_id == interface_id then
            cfMap[interface_id] = value;
            table.insert(res, value);
        end
    end
    return res;
end



-- 15:15:4.359-59: S <-- cmd=0x402, data={"a":[{"am":1,"st":1,"pt":"10019407","spId":505053,"idx":19,"bind":1,"id":"af89f498-9f08-499d-913c-d44e1254d62c"}],"u":[]}
function ItemMoveManager.CheckGetProduct(spid, am, cf)
    spid = tostring(spid);
    local interface_param = cf.interface_param;
    for key, value in pairs(interface_param) do
        if value == spid then
            local bd_name = cf.bd_name;
            local tf = list[bd_name];
            ModuleManager.SendNotification(ItemMoveEffectNotes.OPEN_ITEMMOVEEFFECTPANEL, { fun = ItemMoveManager.interface_ids.getProAndMoveToBt, spid = spid, am = am, tf = tf });
            return;
        end
    end

end

function ItemMoveManager.GetNewSkillAndMoveToBtBySkillId(skill_id, cfs)

    skill_id = tostring(skill_id);
    for key, value in pairs(cfs) do
        local interface_param = value.interface_param;
        for k, v in pairs(interface_param) do
            if skill_id == v then
                return value;
            end
        end

    end
    return nil;
end 

function ItemMoveManager.CheckUnLockSkill(skill_id, cfs)

    local cf = ItemMoveManager.GetNewSkillAndMoveToBtBySkillId(skill_id, cfs);
    if cf ~= nil then
        local bd_name = cf.bd_name;
        local tf = list[bd_name];
        ModuleManager.SendNotification(ItemMoveEffectNotes.OPEN_ITEMMOVEEFFECTPANEL, { fun = ItemMoveManager.interface_ids.getNewSkillAndMoveToBt, skill_id = skill_id, tf = tf });

    else
        log("--------CheckUnLockSkill ----- skill not found ----- skill_id " .. skill_id);
    end


end

function ItemMoveManager.Check(interface_id, data)
    local cfs = ItemMoveManager.GetCf(interface_id)

    if ItemMoveManager.interface_ids.getProAndMoveToBt == interface_id then

        ItemMoveManager.CheckGetProduct(data.spId, data.am, cfs[1]);

    elseif ItemMoveManager.interface_ids.getNewSkillAndMoveToBt == interface_id then
        local skill_id = data.skill_id;
        local level = data.level;
        if level == 1 then
            ItemMoveManager.CheckUnLockSkill(skill_id, cfs)
        end
    end

end


