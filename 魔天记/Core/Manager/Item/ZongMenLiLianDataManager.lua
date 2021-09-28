require "Core.Manager.Item.PositionCheckManager"

ZongMenLiLianDataManager = { }

ZongMenLiLianDataManager.MESSAGE_GETZONGMENINFO_COMPLETE = "MESSAGE_GETZONGMENINFO_COMPLETE";
ZongMenLiLianDataManager.MESSAGE_ZMLL_PREINFO_CHANGE = "MESSAGE_ZMLL_PREINFO_CHANGE";

ZongMenLiLianDataManager.sampleData = nil;
ZongMenLiLianDataManager.preInfo = nil;

ZongMenLiLianDataManager.positionCheckManager = nil;
ZongMenLiLianDataManager.npc_fb_id = 0;



function ZongMenLiLianDataManager.SetSampleData(data)

    ZongMenLiLianDataManager.sampleData = data;
    MessageManager.Dispatch(ZongMenLiLianDataManager, ZongMenLiLianDataManager.MESSAGE_GETZONGMENINFO_COMPLETE);
end

--[[
13 宗门历练信息
输入：
输出：
t:当日挑战次数
a：当日活跃度
]]
function ZongMenLiLianDataManager.GetSampleData()
    return ZongMenLiLianDataManager.sampleData;
end


--[[
输出：
t:当前轮次多少次
npc：npcId
mid：map_id地图id
x：坐标
y：坐标
r：朝向

  S <-- 11:30:37.025, 0x1615, 11, {"mid":"701009","z":-6745,"t":2,"npc":132011,"x":4815,"r":174}

]]
function ZongMenLiLianDataManager.SetZongMenLiLianPreInfo(data)

    -- log("------SetZongMenLiLianPreInfo----");
    local mid = data.mid;
    if mid == nil or mid == -1  then

        if GameSceneManager.map ~= nil then
            GameSceneManager.map:DelZongMengLiLianNpc(ZongMenLiLianDataManager.preInfo);
        end

        ZongMenLiLianDataManager.preInfo = nil;

        ZongMenLiLianDataManager.StopCheckPos();

    else
        ZongMenLiLianDataManager.preInfo = data;

        ZongMenLiLianDataManager.npc_fb_id = 0;
        local npc = data.npc + 0;
        local npcf = ConfigManager.GetNpcById(npc);

        local temp = string.split(npcf.func, "#");
        local func = temp[2];

        if string.sub(func, 1, 3) == "Nav" then
            local args = string.split(func, "_");
            ZongMenLiLianDataManager.npc_fb_id = tonumber(args[2]);
        end

        if  data.f == 1 then
        -- 在副本中， 不需要 检测点
             ZongMenLiLianDataManager.StopCheckPos();
        else
            ZongMenLiLianDataManager.TryStartCheckPos(data)
        end

       


        --  log("npc----------------------------> " .. npcf.name);
    end



    MessageManager.Dispatch(ZongMenLiLianDataManager, ZongMenLiLianDataManager.MESSAGE_ZMLL_PREINFO_CHANGE);
end

function ZongMenLiLianDataManager.TryStartCheckPos(data)
    if ZongMenLiLianDataManager.positionCheckManager == nil then
        ZongMenLiLianDataManager.positionCheckManager = PositionCheckManager:New();
    end

  

    ZongMenLiLianDataManager.positionCheckManager:SetTargetPosInfo( { x = data.x, y = data.y, z = data.z, map_id = data.mid });
    -- 设置目标位置

    ZongMenLiLianDataManager.positionCheckManager:CheckR(35);
    -- 检测半径
    ZongMenLiLianDataManager.positionCheckManager:SetHitHandler( { hd = ZongMenLiLianDataManager.TgtargetHandler });
    --  设置信息
    ZongMenLiLianDataManager.positionCheckManager:Start();
end


function ZongMenLiLianDataManager.StopCheckPos()


    if ZongMenLiLianDataManager.positionCheckManager ~= nil then
        ZongMenLiLianDataManager.positionCheckManager:Dispose();
        ZongMenLiLianDataManager.positionCheckManager = nil;
    end

end


-- 队长是否 自动 进行宗门历练
ZongMenLiLianDataManager.autoFightForZMLL = false;

function ZongMenLiLianDataManager.TgtargetHandler(hd_type)

    if hd_type == PositionCheckManager.HD_TYPE_IN then

        -- 如果是队长， 需要判断 是否 中途被打断了， 如果被打断了， 收到点击，
        -- 如果是队员，就自动 向后台 发送 请求
        local isld = PartData.MeIsTeamLeader();

        if isld then

            if ZongMenLiLianDataManager.autoFightForZMLL then
                -- 自动
                -- log("  ZongMenLiLianDataManager.autoFightForZMLL == true ");
                ZongMenLiLianProxy.ZongMenLiLianGetToNPC();

            else
                -- 手动
                -- log("  ZongMenLiLianDataManager.autoFightForZMLL == false ");
                -- http://192.168.0.8:3000/issues/3641
                ZongMenLiLianProxy.ZongMenLiLianGetToNPC();
            end

        else
            ZongMenLiLianProxy.ZongMenLiLianGetToNPC();
        end


    elseif hd_type == PositionCheckManager.HD_TYPE_OUT then

    end


end

function ZongMenLiLianDataManager.GetZongMenLiLianPreInfo()
    return ZongMenLiLianDataManager.preInfo
end



ZongMenLiLianDataManager.p_max_num = 20;
--[[

     如果宗门历练副本已经结束，
     1 如果还在 宗门历练副本中， 那么需要 推出 宗门副本 后， 才能 开启下一轮
     2  如果 历练副本已经结束 的时候， 队长已经在 其他副本了， 那么就可以马上调用 开始下一轮了


  ]]
function ZongMenLiLianDataManager.CheckGoOnZongMengLiLian()


    -----------------------------------------
   
    if ZongMenLiLianProxy.zmllIsOverInfo ~= nil then

        local map_id = GameSceneManager.id;

        --  log("---------- map_id "..map_id .."  "..GameSceneManager.old_id);
        local fbCf = ConfigManager.GetMapById(map_id);
        if fbCf.type ~= InstanceDataManager.MapType.ZongMenLiLian then

            ZongMenLiLianProxy.zmllIsOverInfo = nil;

            -- 如果不在 宗门历练 副本中， 那么就可以 马上 处理数据
            local isLd = PartData.MeIsTeamLeader();
            if isLd then
                -- 1.宗门历练每日30次，每10次1轮，每轮结束队伍自动活动行程停止，需要队长重新点击开启获取活动
                --  就是  每到 10 ， 20， 30 都需要挺下来

                -- 2017 04-07 修改为 http://192.168.0.8:3000/issues/3722

                if ZongMenLiLianDataManager.preInfo ~= nil then

                    local t = ZongMenLiLianDataManager.preInfo.t;

                    if  t ~= 19  then
                       
                        ZongMenLiLianProxy.OpenZongMenLiLian();
                    end

                else
                  -- 需要获取信息
                  log("-------------------CheckGoOnZongMengLiLian error-----------------------------------");
                end

                return;
            end

        end

    end


    -- 其他队员 需要检查是否需要 寻找 npc
    -- log("-----------ZongMenLiLianProxy.CheckZongMenLiLianData--------");
    ZongMenLiLianProxy.CheckZongMenLiLianData();


    --[[
    if GameSceneManager.old_fid ~= nil then
        local fbCf = InstanceDataManager.GetMapCfById(GameSceneManager.old_fid);
        if fbCf.type == InstanceDataManager.InstanceType.type_ZongMenLiLian then

            -- 上一个场景是 宗门历练， 需要 检测 是否 需要继续
            --  log("---------- try go on  zong meng li lian ---------------------");

        end
    end
    ]]



end