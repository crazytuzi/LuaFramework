require "Core.Module.Pattern.Proxy"

WiseEquipPanelProxy = Proxy:New();

WiseEquipPanelProxy.test = false;

WiseEquipPanelProxy.MESSAGE_0X2001_RESULT = "MESSAGE_0X2001_RESULT";
WiseEquipPanelProxy.MESSAGE_0X2002_RESULT = "MESSAGE_0X2002_RESULT";
WiseEquipPanelProxy.MESSAGE_0X2003_RESULT = "MESSAGE_0X2003_RESULT";

WiseEquipPanelProxy.WISEEQUIPATTCHANGE = "WISEEQUIPATTCHANGE";

function WiseEquipPanelProxy:OnRegister()

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WiseEquip_jianding, WiseEquipPanelProxy.TryWiseEquip_jianding_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WiseEquip_fumo, WiseEquipPanelProxy.WiseEquip_fumo_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WiseEquip_duanzao, WiseEquipPanelProxy.WiseEquip_duanzao_Result);
end

function WiseEquipPanelProxy:OnRemove()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WiseEquip_jianding, WiseEquipPanelProxy.TryWiseEquip_jianding_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WiseEquip_fumo, WiseEquipPanelProxy.WiseEquip_fumo_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WiseEquip_duanzao, WiseEquipPanelProxy.WiseEquip_duanzao_Result);
end


--[[
01 仙兵玄兵 鉴定
输入：
id:(装备id)
输出：
id:(装备id)
fm:[{idx(位置1开始),id:附魔id（0：没有附魔)},..]

]]
function WiseEquipPanelProxy.TryWiseEquip_jianding(id, hd, quality)

    if WiseEquipPanelProxy.test then

        -- 模拟 0x0402
        local idx = 0;
        local res = BackpackDataManager.GetProductByIdx(idx);
        res.fm = { };
        res.fm[1] = { idx = 1, max_attr_lev = 50, attr_key = "hit", att_value = 123 };

        local arr = { };
        arr[1] = res;

        BackpackDataManager.UpDataProduct(arr)
        BackpackDataManager.DispatchEvent();

        WiseEquipPanelProxy.TryWiseEquip_jianding_Result(0, { })

        return;
    end

    WiseEquipPanelProxy.jiandingHd = hd;


    if quality >= 5 then

        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = LanguageMgr.Get("WiseEquipPanelProxy/label4"),
            ok_Label = LanguageMgr.Get("common/ok"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = function()
                SocketClientLua.Get_ins():SendMessage(CmdType.WiseEquip_jianding, { id = id });
            end,
            data = nil,
            target = nil
        } );


    else
        SocketClientLua.Get_ins():SendMessage(CmdType.WiseEquip_jianding, { id = id });
    end


end


function WiseEquipPanelProxy.TryWiseEquip_jianding_Result(cmd, data)

    if data.errCode == nil then

        MsgUtils.ShowTips("WiseEquipPanelProxy/label2");

       
        MessageManager.Dispatch(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2001_RESULT, data);
        MessageManager.Dispatch(WiseEquipPanelProxy, WiseEquipPanelProxy.WISEEQUIPATTCHANGE);

        if WiseEquipPanelProxy.jiandingHd ~= nil then
            local id = data.id;

            local info = BackpackDataManager.GetProductById(id);
            WiseEquipPanelProxy.jiandingHd(info);

        end

         EquipTipPanel.UpPanelInfo(data);

        UISoundManager.PlayUISound(UISoundManager.ui_compose)

    end

end 

--[[
02 仙兵玄兵 附魔
输入：
sId:背包中装备
s_idx:部位
tId:使用中的装备
t_idx:部位
输出：
sId:背包中装备
s_idx:部位
tId:使用中的装备
t_idx:部位
0402 通知


]]
function WiseEquipPanelProxy.TryWiseEquip_fumo(sId, s_idx, tId, t_idx, canSellPro)

    WiseEquipPanelProxy.canSellPro = canSellPro;
    SocketClientLua.Get_ins():SendMessage(CmdType.WiseEquip_fumo, { sId = sId, s_idx = s_idx, tId = tId, t_idx = t_idx });
end

function WiseEquipPanelProxy.WiseEquip_fumo_Result(cmd, data)

    if data.errCode == nil then

        MessageManager.Dispatch(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2002_RESULT);

        if WiseEquipPanelProxy.canSellPro ~= nil then
            --  显示可以出售 确认框
            local isfg = WiseEquipPanelProxy.canSellPro:IsHasFairyGrooveAtt();
            if not isfg then

                local price = WiseEquipPanelProxy.canSellPro:GetPrice();
                local name = WiseEquipPanelProxy.canSellPro:GetName();

                ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                    title = LanguageMgr.Get("common/notice"),
                    msg = LanguageMgr.Get("WiseEquipPanelProxy/label1",{ n = name, p = price }),
                    ok_Label = LanguageMgr.Get("common/ok"),
                    cance_lLabel = LanguageMgr.Get("common/cancle"),
                    hander = function()
                        ProductTipProxy.TrySell(WiseEquipPanelProxy.canSellPro, true);
                    end,
                    target = nil,
                    data = nil
                } );

            end

        end

        UISoundManager.PlayUISound(UISoundManager.ui_enhance1)

    end


    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.EquipFoMo)
    MessageManager.Dispatch(WiseEquipPanelProxy, WiseEquipPanelProxy.WISEEQUIPATTCHANGE);
end


function WiseEquipPanelProxy.TryWiseEquip_duanzao(idx, attr_key, spId, num)

    SocketClientLua.Get_ins():SendMessage(CmdType.WiseEquip_duanzao, { idx = idx, attr_key = attr_key, item = { spId = tonumber(spId), num = tonumber(num) } });
end

function WiseEquipPanelProxy.WiseEquip_duanzao_Result(cmd, data)

    if data.errCode == nil then


        MsgUtils.ShowTips("WiseEquipPanelProxy/label3");
        EquipLvDataManager.Set_ext_equip_lv_byIdx(data.idx, data.bl)

        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.WiseEquipDuanZao)
        MessageManager.Dispatch(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2003_RESULT, data);
        MessageManager.Dispatch(WiseEquipPanelProxy, WiseEquipPanelProxy.WISEEQUIPATTCHANGE);
    end

end