require "Core.Module.Pattern.Proxy"

EquipProxy = Proxy:New();
function EquipProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GemComp, EquipProxy._RspGemCompose);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GemAllComp, EquipProxy._RspGemAllCompose);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GemEmbed, EquipProxy._RspGemEmbed);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GemPick, EquipProxy._RspGemPick);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GemPunch, EquipProxy._RspGemPunch);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GemShengji, EquipProxy._RspGemShengji);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.NewEquipStrong, EquipProxy._RspNewEquipStrong);


    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SQGetSuitLvData, EquipProxy._SQGetSuitLvDataResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SQSuitLvDataChange, EquipProxy._SQSuitLvDataChangeResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SQZY, EquipProxy.SQZY_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SQCompose, EquipProxy.SQCompose_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SQUpStar, EquipProxy.SQUpStar_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Move_Product, EquipProxy.Dress_Equip_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EquipRefine, EquipProxy.EquipRefineResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EquipStrong, EquipProxy.EquipStrongResult);
end

function EquipProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GemComp, EquipProxy._RspGemCompose);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GemAllComp, EquipProxy._RspGemAllCompose);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GemEmbed, EquipProxy._RspGemEmbed);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GemPick, EquipProxy._RspGemPick);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GemPunch, EquipProxy._RspGemPunch);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GemShengji, EquipProxy._RspGemShengji);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.NewEquipStrong, EquipProxy._RspNewEquipStrong);


    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SQGetSuitLvData, EquipProxy._SQGetSuitLvDataResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SQSuitLvDataChange, EquipProxy._SQSuitLvDataChangeResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SQZY, EquipProxy.SQZY_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SQCompose, EquipProxy.SQCompose_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SQUpStar, EquipProxy.SQUpStar_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Move_Product, EquipProxy.Dress_Equip_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.EquipRefine, EquipProxy.EquipRefineResult);

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.EquipStrong, EquipProxy.EquipStrongResult);


end

function EquipProxy.TrySQGetSuitLvData()
    SocketClientLua.Get_ins():SendMessage(CmdType.SQGetSuitLvData, { });
end

function EquipProxy._RspNewEquipStrong(cmd, data)
    if (data.errCode == nil) then
        local plusId = NewEquipStrongManager.GetPlusId()
        local eqInfo = NewEquipStrongManager.GetEquipStrongDataByIdx(data.idx + 1)
        local suc = false
        if (data.plv > eqInfo.level) then
            suc = true
        end
        UISoundManager.PlayUISound(UISoundManager.ui_enhance)

        NewEquipStrongManager.SetOneEquipStrongData(data)
        if (plusId ~= NewEquipStrongManager.GetPlusId()) then
            PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.EquipNewStrongSuit, suc)
        end

        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.EquipNewStrong)
        MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPNEWSTRONGRESULT, suc);
        -- todo更新界面 刷新屬性
    end
end

function EquipProxy.SendNewEquipStrong(idx, lcId, hasprt)
    SocketClientLua.Get_ins():SendMessage(CmdType.NewEquipStrong, { idx = idx, lck_spId = lcId, prt = hasprt });
end

function EquipProxy._SQGetSuitLvDataResult(cmd, data)

    if (data.errCode == nil) then

        MouldingDataManager.currSuit_id = data.id;

        -- 数据发送改变，重新计算属性
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.EquipShenqi);
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end

function EquipProxy._SQSuitLvDataChangeResult(cmd, data)

    if (data.errCode == nil) then

        local old_id = MouldingDataManager.currSuit_id;

        MouldingDataManager.currSuit_id = data.id;

        -- 数据发送改变，重新计算属性
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.EquipShenqi);

        -- EquipProxy.TryShowSQSuitPanel()

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end

function EquipProxy.TryShowSQSuitPanel()

    -- MouldingDataManager.currSuit_id = 2;
    ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPSQSUITPANEL, { suit_id = MouldingDataManager.currSuit_id });

end

function EquipProxy.TryZYEq(info1, info2)
    -- CmdType.SQZY
    local id1 = info1:GetId();
    local st1 = info1:GetSt();

    local id2 = info2:GetId();
    local st2 = info2:GetSt();


    SocketClientLua.Get_ins():SendMessage(CmdType.SQZY, { id1 = id1, st1 = st1, id2 = id2, st2 = st2 });

end


--[[ C <-- 11:59:23.642, 0x0413, 13, {"id2":"102561","st2":1,"id1":"101275","st1":2}

  S <-- 11:59:23.664, 0x0413, 13, {"items":[{"st":2,"pt":"10100319","id":"101275","am":1,"idx":0,"spId":301440},{"st":1,"pt":"10100319","star":10,"id":"102561","am":1,"idx":1,"spId":301440,"quality":5}]}
]]
function EquipProxy.SQZY_Result(cmd, data)


    if (data.errCode == nil) then

        local items = data.items;
        for key, value in pairs(items) do
            local st = value.st;
            if st == ProductManager.ST_TYPE_IN_BACKPACK then
                -- in bag
                BackpackDataManager.UpDataProductBaseData(value);
            elseif st == ProductManager.ST_TYPE_IN_EQUIPBAG then
                -- in eq bag
                EquipDataManager.UpDataProductBaseData(value)
            end

        end


        MsgUtils.ShowTips("Equip/EquipProxy/label1");
        --  通知 清空 容器
        MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIP_ZY_SUCCESS);

        UISoundManager.PlayUISound(UISoundManager.path_ui_enhance);
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end


--[[ S <-- 19:28:59.803, 0x0105, 0, {"pets":[],"dress":{"a":301440,"b":0,"c":"","w":0,"h":0,"m":0},"hp":4560,"bag":[{"st":1,"pt":"10102385","id":"10789","am":2,"idx":0,"spId":500006}],"ride":[],"scene":{"fid":"","x":-107,"y":55,"z":-1889,"sid":"709999"},"skills":[{"level":1,"skill_id":201100},{"level":1,"skill_id":201004},{"level":1,"skill_id":201007},{"level":1,"skill_id":201000},{"level":1,"skill_id":201003},{"level":1,"skill_id":201006},{"level":1,"skill_id":201200},{"level":1,"skill_id":201008},{"level":1,"skill_id":201002}],"petSkills":[],"id":"10102385","vip":0,"exp":0,"equip_lv":[{"gems":"0,0,0,-1","idx":0,"slv":0,"rlv":0,"sexp":0},{"gems":"0,0,0,-1","idx":1,"slv":0,"rlv":0,"sexp":0},{"gems":"0,0,0,-1","idx":2,"slv":0,"rlv":0,"sexp":0},{"gems":"0,0,0,-1","idx":3,"slv":0,"rlv":0,"sexp":0},{"gems":"0,0,0,-1","idx":4,"slv":0,"rlv":0,"sexp":0},{"gems":"0,0,0,-1","idx":5,"slv":0,"rlv":0,"sexp":0},{"gems":"0,0,0,-1","idx":6,"slv":0,"rlv":0,"sexp":0},{"gems":"0,0,0,-1","idx":7,"slv":0,"rlv":0,"sexp":0}],"mp":2850,"level":1,"posture":{"data":[],"id":0},"kind":101000,"instReds":[],"sex":0,"mv":{"st":0,"a":0,"t":1,"paths":[],"v":13.0,"x":0,"y":0,"z":0,"id":"10102385"},"mount":{"rt":0,"id":0},"camp":1,"t":1,"money":{"gold":0,"money":14000,"bgold":0},"equip":[{"st":2,"pt":"10102385","id":"10561","am":1,"idx":0,"spId":301440,"quality":5}],"name":"袁元平","bsize":40,"wing":{"wid":0,"level":0,"id":0,"exp":0},"buff":[]}
]]
-- S <-- 19:27:33.066, 0x0411, 12, {"equip":{"st":2,"pt":"10102385","id":"10561","star":1,"am":1,"idx":0,"spId":301440,"quality":5},"idx":0}
function EquipProxy.TrySQCompose(id, kind)
    EquipProxy.sq_kind = kind;

    SocketClientLua.Get_ins():SendMessage(CmdType.SQCompose, { id = id });
end


EquipProxy.MESSAGE_EQUIP_STAR_CHANGE = "MESSAGE_EQUIP_STAR_CHANGE";

function EquipProxy.SQCompose_Result(cmd, data)


    if (data.errCode == nil) then


        local idx = data.idx;
        local suit_id = data.suit_id;
        local suit_lev = data.suit_lev;

        EquipLvDataManager.SetSuitLv(idx, suit_id, suit_lev)

    end

end

-- 12 套装升级
function EquipProxy.TrySQUpStar(idx)

    SocketClientLua.Get_ins():SendMessage(CmdType.SQUpStar, { idx = idx });
end

EquipProxy.MESSAGE_EQUIP_SUIT_UPCOMPLETE = "MESSAGE_EQUIP_SUIT_UPCOMPLETE";

function EquipProxy.SQUpStar_Result(cmd, data)


    if (data.errCode == nil) then

        MessageManager.Dispatch(EquipProxy, EquipProxy.MESSAGE_EQUIP_SUIT_UPCOMPLETE);

        UISoundManager.PlayUISound(UISoundManager.path_ui_enhance);
    end

end


function EquipProxy.TryMove_Product(p, target_index)
    EquipProxy.target_index = target_index;

    SocketClientLua.Get_ins():SendMessage(CmdType.Move_Product, p);
end

EquipProxy.MESSAGE_EQUIP_DRESSCOMPLETE = "MESSAGE_EQUIP_DRESSCOMPLETE";

function EquipProxy.Dress_Equip_Result(cmd, data)


    if (data.errCode == nil and EquipProxy.target_index ~= nil and EquipProxy.target_index > 0) then
        --  MsgUtils.ShowTips("Equip/EquipProxy/label4");
        -- EquipProxy.moveProduct_target:SetActive(false);
        -- EquipProxy.moveProduct_target = nil;

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
        MsgUtils.ShowTips("ProductTip/ProductTipProxy/label1");
        MessageManager.Dispatch(EquipProxy, EquipProxy.MESSAGE_EQUIP_DRESSCOMPLETE, EquipProxy.target_index);

        EquipProxy.target_index = nil;
    end


end


function EquipProxy.TryEquipRefine(idx)

    SocketClientLua.Get_ins():SendMessage(CmdType.EquipRefine, { idx = idx });
end


--[[0A 装备栏精炼¶
输入：
idx:装备部位 0到7
输出：
idx:装备部位 0到7
rlv：精炼等级

]]
function EquipProxy.EquipRefineResult(cmd, data)


    if (data.errCode == nil) then
        EquipLvDataManager.UpData(data);
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.EquipRefine);

        MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPREFINERESULT, data);
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
        EquipDataManager.Check_Npoint(EquipNotes.classify_2);

        UISoundManager.PlayUISound(UISoundManager.path_ui_enhance1);
    end

end


function EquipProxy.TryEquipStrong(sendData, callback)

    -- if not EquipProxy.eqStrongint then

    -- EquipProxy.eqStrongint = true;
    EquipProxy.eqStrong_callback = callback;

    EquipProxy.pare_use_item = sendData.items;

    SocketClientLua.Get_ins():SendMessage(CmdType.EquipStrong, sendData);

    -- end


end

function EquipProxy.EquipStrongResult(cmd, data)


    -- EquipProxy.eqStrongint = false;

    if (data.errCode == nil) then
        -- 因为 0x0409 返回后，
        EquipLvDataManager.UpData(data);
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.EquipStrong)
        MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_EQUIPSTRONGRESULT, data);

        if EquipProxy.eqStrong_callback ~= nil then
            EquipProxy.eqStrong_callback();
            EquipProxy.eqStrong_callback = nil;
        end

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
        if EquipProxy.needUpNPoint then
            -- 更新装备强化红点提前
            EquipDataManager.Check_Npoint(EquipNotes.classify_1);
            EquipProxy.needUpNPoint = false;
        end

    end

end

-- 宝石请求
-- 宝石镶嵌
function EquipProxy.ReqGemEmbed(equipSlot, gemSlot, gemId)
    SocketClientLua.Get_ins():SendMessage(CmdType.GemEmbed, { idx = equipSlot - 1, id = gemId, gemIdx = gemSlot - 1 });
end
-- 宝石摘取
function EquipProxy.ReqGemPick(equipSlot, gemSlot)
    SocketClientLua.Get_ins():SendMessage(CmdType.GemPick, { idx = equipSlot - 1, gemIdx = gemSlot - 1 });
end
-- 镶嵌打孔
function EquipProxy.ReqGemPunch(equipSlot, gemSlot, itemId)
    SocketClientLua.Get_ins():SendMessage(CmdType.GemPunch, { idx = equipSlot - 1, gemIdx = gemSlot - 1, id = itemId });
end
-- 装备宝石升级
function EquipProxy.ReqGemShengji(equipSlot, gemSlot)
    SocketClientLua.Get_ins():SendMessage(CmdType.GemShengji, { idx = equipSlot - 1, gemIdx = gemSlot - 1 });
end
-- 宝石合成
function EquipProxy.ReqGemCompose(gemSpId, num)
    SocketClientLua.Get_ins():SendMessage(CmdType.GemComp, { spId = gemSpId, n = num });
end
-- 宝石一键合成
function EquipProxy.ReqGemAllCompose()
    SocketClientLua.Get_ins():SendMessage(CmdType.GemAllComp, nil);
end

-- 宝石返回
function EquipProxy._RspGemEmbed(cmd, data)
    if (data.errCode == nil) then
        UISoundManager.PlayUISound(UISoundManager.equip_gem_embed);
        GemDataManager.OnResult(data, true);
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end
end

function EquipProxy._RspGemPick(cmd, data)
    if (data.errCode == nil) then
        GemDataManager.OnResult(data, true);
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end
end

function EquipProxy._RspGemPunch(cmd, data)
    if (data.errCode == nil) then
        local tmp = string.split(data.gems, ",");
        if (tmp and tonumber(tmp[4]) > -1) then
            GemDataManager.OnResult(data);
            MsgUtils.ShowTips("equip/gem/tip/punch");
        else
            MsgUtils.ShowTips("equip/gem/tip/punch2");
        end

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end
end

function EquipProxy._RspGemCompose(cmd, data)
    if (data.errCode == nil) then
        MsgUtils.ShowTips("equip/gem/tip/comp");
        UISoundManager.PlayUISound(UISoundManager.equip_gem_compose);
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end
end

function EquipProxy._RspGemAllCompose(cmd, data)
    if (data.errCode == nil) then
        if #data.l > 0 then
            MsgUtils.ShowTips("equip/gem/tip/allComp");
            UISoundManager.PlayUISound(UISoundManager.equip_gem_compose);
        else
            MsgUtils.ShowTips("equip/gem/tip/allComp2");
        end

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end
end

function EquipProxy._RspGemShengji(cmd, data)
    if (data.errCode == nil) then
        UISoundManager.PlayUISound(UISoundManager.equip_gem_embed);
        GemDataManager.OnResult(data, true);
        --[[
        if data.gemIdx then
            local ids = string.split(data.gems, ",");
            local gemId = tonumber(ids[data.gemIdx + 1]) or 0;
            if gemId > 0 then
                local cfg = ConfigManager.GetProductById(gemId);
                if cfg.lev >= GemDataManager.MAX_LEV then
                    MsgUtils.ShowTips("equip/gem/maxLev");
                end
            end
        end
        ]]
    end
end
