
SeedBagDataManager = { };

SeedBagDataManager.farm_bag = { };

SeedBagDataManager.MESSAGE_SEEDBAG_PRODUCTS_CHANGE = "MESSAGE_SEEDBAG_PRODUCTS_CHANGE";

--[[
 S <-- 14:31:07.879, 0x0105, 0, {"instReds":[],"level":55,"vip":0,"pk":{"st":0,"m":0},"t":1,"ride":[],"wing":{"level":0,"exp":0,"wid":0,"id":341001},
 "farm_bag":[{"am":1,"st":5,"pt":"20100246","spId":356030,"idx":0,"id":"201105"}],"skill_set":"","exp":13000,"camp":1,"skills":[{"level":1,"skill_id":201100},{"level":1,"skill_id":201004},{"level":1,"skill_id":201007},{"level":1,"skill_id":201000},{"level":1,"skill_id":201003},{"level":1,"skill_id":201006},{"level":1,"skill_id":201200},{"level":1,"skill_id":201008},{"level":1,"skill_id":201002}],"hp":4560,"kind":101000,"bsize":40,"elixir":[],"equip_lv":[{"gems":"0,0,0,-1","rlv":0,"idx":0,"sexp":0,"slv":0},{"gems":"0,0,0,-1","rlv":0,"idx":1,"sexp":0,"slv":0},{"gems":"0,0,0,-1","rlv":0,"idx":2,"sexp":0,"slv":0},{"gems":"0,0,0,-1","rlv":0,"idx":3,"sexp":0,"slv":0},{"gems":"0,0,0,-1","rlv":0,"idx":4,"sexp":0,"slv":0},{"gems":"0,0,0,-1","rlv":0,"idx":5,"sexp":0,"slv":0},{"gems":"0,0,0,-1","rlv":0,"idx":6,"sexp":0,"slv":0},{"gems":"0,0,0,-1","rlv":0,"idx":7,"sexp":0,"slv":0}],"money":{"gold":923,"money":0,"bgold":0},"trump_bag":[],"mv":{"st":0,"z":0,"t":1,"v":16.0,"y":0,"a":0,"x":0,"id":"20100246"},"mp":3650,"name":"\u5D14\u82F1\u6770","petSkills":[],"mount":{"rt":0,"id":0},"talent":{"conf2":[],"idx":1,"conf1":[],"talent":1},"dress":{"w":0,"h":0,"t":0,"b":0,"m":0,"a":0,"c":""},"bag":[{"am":10,"st":1,"pt":"20100246","spId":359001,"idx":2,"bind":1,"id":"20982"},{"am":1,"st":1,"pt":"20100246","spId":301015,"idx":1,"id":"20981"},{"am":1,"st":1,"pt":"20100246","spId":301000,"idx":4,"id":"20984"},{"am":3,"st":1,"pt":"20100246","spId":358011,"idx":0,"bind":1,"id":"20980"},{"am":2,"st":1,"pt":"20100246","spId":402000,"idx":3,"bind":1,"id":"20983"}],"equip":[],"scene":{"z":-260,"fid":"","y":55,"x":-23,"sid":"709999"},"realm":{"compact_lev":0,"realm_lev":0},"pets":[],"sex":0,"trump_id":"","trump_equip":[],"id":"20100246"}

]]

function SeedBagDataManager.Init(farm_bag)

    SeedBagDataManager.farm_bag = { };

    for key, value in pairs(farm_bag) do
        SeedBagDataManager.farm_bag[value.id] = value;
    end
    MessageManager.Dispatch(SeedBagDataManager, SeedBagDataManager.MESSAGE_SEEDBAG_PRODUCTS_CHANGE);
end


function SeedBagDataManager.GetList()

    local res = { };
    local res_index = 1;

    for key, value in pairs(SeedBagDataManager.farm_bag) do

        if res[res_index] == nil then
            res[res_index] = { };
            res[res_index][1] = value;
        else
            res[res_index][2] = value;
            res_index = res_index + 1;
        end
    end
    return res;
end

--[[
 S <-- 10:30:39.709, 0x0402, 0, {"a":[],
 "u":[
 {"am":2,"st":5,"pt":"10000528","spId":356038,"idx":2,"bind":1,"id":"843ed27e-de8d-475a-93b1-047c5199a2e3"},
 {"am":2,"st":5,"pt":"10000528","spId":356037,"idx":3,"bind":1,"id":"dea71f0b-1f0a-4110-8a80-85b5ae10a58b"},
 {"am":2,"st":5,"pt":"10000528","spId":356036,"idx":4,"bind":1,"id":"32d79015-b2c8-46a5-bdfc-aebc0c06203e"},
 {"am":2,"st":5,"pt":"10000528","spId":356035,"idx":5,"bind":1,"id":"fcdf8b7d-49a5-4b31-9cad-a9fee6857075"},
 {"am":2,"st":5,"pt":"10000528","spId":356034,"idx":6,"bind":1,"id":"89d046fb-1e10-4e06-bf3f-33627d51276e"},
 {"am":2,"st":5,"pt":"10000528","spId":356033,"idx":7,"bind":1,"id":"91281f4b-d81f-44cb-9279-fde7402f502d"}]}
]]

function SeedBagDataManager.CheckProductChange(data)

    local a = data.a;
    local u = data.u;
    local m = data.m;


    if a ~= nil then
        local a_len = table.getn(a);

        if a_len > 0 then
            for i = 1, a_len do
                if ProductManager.ST_TYPE_IN_PLANT_BAG == a[i].st then
                    SeedBagDataManager.farm_bag[a[i].id] = a[i];
                end
            end

        end

    end

    if u ~= nil then
        local u_len = table.getn(u);

        if u_len > 0 then

            for i = 1, u_len do

                if ProductManager.ST_TYPE_IN_PLANT_BAG == u[i].st then
                    if u[i].am > 0 then

                        if SeedBagDataManager.farm_bag[u[i].id] == nil then
                            SeedBagDataManager.farm_bag[u[i].id] = u[i];
                        else
                            SeedBagDataManager.farm_bag[u[i].id].am = u[i].am;
                        end
                    else
                        SeedBagDataManager.farm_bag[u[i].id] = nil;
                    end
                end

            end

        end

    end

    if m ~= nil then
        local m_len = table.getn(m);

        if m_len > 0 then

            for i = 1, m_len do
                if ProductManager.ST_TYPE_IN_PLANT_BAG == m[i].st then
                    SeedBagDataManager.farm_bag[m[i].id] = nil;
                end
            end

        end

    end
    MessageManager.Dispatch(SeedBagDataManager, SeedBagDataManager.MESSAGE_SEEDBAG_PRODUCTS_CHANGE);
end