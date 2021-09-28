

Login7RewardManager = { }
Login7RewardManager.hasInit = false;
Login7RewardManager.list = { };
Login7RewardManager.hasGetAward = false;

Login7RewardManager.MESSAGE_LOGIN7REWARDDATA_CHANGE = "MESSAGE_LOGIN7REWARDDATA_CHANGE";

function Login7RewardManager.ReInit()
    Login7RewardManager.hasInit = false;
end

function Login7RewardManager.CheckInit()

    if not Login7RewardManager.hasInit then

        local cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_LOGIN_REWARD);

        local t_num = table.getn(cf);
        for i = 1, t_num do

            local obj = cf[i];
            local res = { };

            res.id = obj.id;
            res.base_map = obj.base_map;

            res.canGetAward = false;
            res.hasGetAward = false;
            -------------------------
            local show_str = obj.show;
            local arr = ConfigSplit(show_str);
            local id = tonumber(arr[1]);
            local num = tonumber(arr[2]);

            res.show = ProductInfo:New();
            res.show:Init( { spId = id, am = num });
            -----------------------------------------
            res.reward = { };
            local reward_str = obj.reward;
            local reward_num = table.getn(reward_str);


            for j = 1, reward_num do
                arr = ConfigSplit(reward_str[j]);
                id = tonumber(arr[1]);
                num = tonumber(arr[2]);

                res.reward[j] = ProductInfo:New();
                res.reward[j]:Init( { spId = id, am = num });
            end
            -------------------------------------------------------------------


            Login7RewardManager.list[i] = res;

        end


        Login7RewardManager.hasInit = true;
    end




end

function Login7RewardManager.GetListDatas()

    Login7RewardManager.CheckInit();

    return Login7RewardManager.list;

end

--[[
t:累计登陆次数
f:[{id}] 奖励领取标示
]]
function Login7RewardManager.SetData(t, r)

    Login7RewardManager.CheckInit();


    Login7RewardManager.hasLogin = t;

    local l_num = table.getn(Login7RewardManager.list);

    for i = 1, l_num do
        if i <= t then
            Login7RewardManager.list[i].canGetAward = true;
        else
            Login7RewardManager.list[i].canGetAward = false;
        end

        Login7RewardManager.list[i].hasGetAward = false;
    end

    l_num = table.getn(r);
    if l_num > 0 then
        for i = 1, l_num do
            local index = r[i].id;
            if index ~= 0 then
                Login7RewardManager.list[index].hasGetAward = true;
            end

        end
        Login7RewardManager.hasGetAward = true;
    else
        Login7RewardManager.hasGetAward = false;

    end


    MessageManager.Dispatch(Login7RewardManager, Login7RewardManager.MESSAGE_LOGIN7REWARDDATA_CHANGE);



end


--[[
获取是否有领取过奖励
]]
function Login7RewardManager.GetHasGetAward()
    return Login7RewardManager.hasGetAward;
end

function Login7RewardManager.GetDataByIndex(i)
    return Login7RewardManager.list[tonumber(i)];
end

-- 是否有奖励可以领取
function Login7RewardManager.IsCanGetAward()

    local isIn = SignInManager.CheckIsShowTb(5);
    if not isIn then
        return false;
    end

    if Login7RewardManager.list ~= nil then
        local l_num = table.getn(Login7RewardManager.list);

        for i = 1, l_num do
            local b1 = Login7RewardManager.list[i].canGetAward;
            local b2 = Login7RewardManager.list[i].hasGetAward;

            if b1 and not b2 then
                return true;
            end
        end
    end

    return false;
end

--[[
 七天奖励是否全都领取了
]]
function Login7RewardManager.HasGetAllAward()

    local l_num = table.getn(Login7RewardManager.list);

    for i = 1, l_num do
        local b = Login7RewardManager.list[i].hasGetAward;
        if not b then
            return false;
        end
    end

    return true;
end

--[[
 获取第一个可以获取奖励的对象
]]
function Login7RewardManager.GetFirstCanGetArard()

    local l_num = table.getn(Login7RewardManager.list);

    for i = 1, l_num do
        local obj = Login7RewardManager.list[i];
        local b1 = obj.canGetAward;
        local b2 = obj.hasGetAward;

        if b1 and not b2 then
            return obj;
        end
    end

    return nil;
end

--[[
获取 滑动块 的 进度
i.优先按照领取奖励状态进行显示，其次按照累计登录天数进行显示
ii.领取奖励状态：
1.角色打开七日登录界面时，优先选中累计登录时间最少、并且可领取奖励的页签
iii.累计登录天数：
1.角色打开七日登录界面时，没有可领取的奖励时，根据当前天数显示界面内容
2.角色处于累计登录第1~4天时，界面内容显示第1~4天区域，并且选中当前累计登录天数
3.角色处于累计登录第5~7天时，界面内容显示第4~7天区域，并且选中当前累计登录天数

]]
function Login7RewardManager.GetScollviewV()

    local res = { };

    local l_num = table.getn(Login7RewardManager.list);

    local firstCg = Login7RewardManager.GetFirstCanGetArard();
    if firstCg ~= nil then
        local id = firstCg.id;
        if id > 4 then
            local ps = id / l_num;

            res.scv = ps;
            res.defSelect = id;
        else
            res.scv = 0;
            res.defSelect = id;
        end
    else

        if Login7RewardManager.hasLogin > 4 then
            local ps = Login7RewardManager.hasLogin / l_num;
            res.scv = ps;
            res.defSelect = Login7RewardManager.hasLogin;
            if res.defSelect > l_num then
                res.defSelect = l_num;
            end
        else
            res.scv = 0;
            res.defSelect = Login7RewardManager.hasLogin;
        end

    end



    return res;
end