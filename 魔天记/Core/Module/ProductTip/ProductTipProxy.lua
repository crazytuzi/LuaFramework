require "Core.Module.Pattern.Proxy"
require "net/SocketClientLua"
require "net/CmdType"
require "Core.Manager.PlayerManager";
require "Core.Manager.Item.EquipDataManager";
require "Core.Module.ProductTip.ProductTipNotes"
require "Core.Role.Controller.HeroController"

ProductTipProxy = Proxy:New();
function ProductTipProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Move_Product, ProductTipProxy.Dress_Equip_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Sell_Product, ProductTipProxy.Sell_Product_Result);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Use_Product, ProductTipProxy.Use_Product_Result);

end

function ProductTipProxy:OnRemove()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Move_Product, ProductTipProxy.Dress_Equip_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Sell_Product, ProductTipProxy.Sell_Product_Result);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Use_Product, ProductTipProxy.Use_Product_Result);




end

-- 被  ProducTipsManager.CallFunById(id)  代替
--[[
function ProductTipProxy.DealPruductMenyHandler(container_type, productInfo, btInfo)

    if btInfo.funName == ProductTipNotes.FUN_USEPRODUCT then
        -- 使用物品

        local am = productInfo.am;
        local type = productInfo:GetType();

        if am > 1 and type ~= ProductManager.type_4 then
            ModuleManager.SendNotification(ProductTipNotes.SHOW_PRODUCTUSEPANEL, productInfo);
        else
            ProductTipProxy.TryUseProduct(productInfo, 1)
        end

    elseif btInfo.funName == ProductTipNotes.FUN_DRESSEQ then
        -- 穿戴装备
        ProductTipProxy.TryDress(productInfo);
    elseif btInfo.funName == ProductTipNotes.FUN_UNDRESSEQ then
        -- 卸下装备
        ProductTipProxy.TryUnDress(productInfo);
    elseif btInfo.funName == ProductTipNotes.FUN_SELLPRUDUCT then
        -- 出售物品
        ProductTipProxy.TrySell(productInfo);
    end

end
]]

-- 穿上装备  
function ProductTipProxy.TryDress(info)

    local pid = HeroController.GetInstance().id;
    local hero_career = PlayerManager.GetPlayerInfo():GetCareer();
    local career = info:GetCareer();
    local kind = info:GetKind();

    if hero_career == career or tonumber(career) == 0 then

        local p = { };
        p.id1 = info:GetId();
        p.pt1 = pid;
        p.st1 = info:GetSt();

        -- 需要寻找对应的装备栏容器
        local kind = info:GetKind();
        local targetPro = EquipDataManager.GetProductByKind(kind);
        --

        p.id2 = nil;
        if targetPro ~= nil then
            p.id2 = targetPro:GetId();
        end

        p.pt2 = pid;

        if kind == 9 or kind == 10 then
            -- 额外装备容器
            p.st2 = ProductManager.ST_TYPE_IN_EXT_EQUIP;
            if kind == 9 then
                p.idx = EquipDataManager.ExtEquipIdx.Idx1;
            elseif kind == 10 then
                p.idx = EquipDataManager.ExtEquipIdx.Idx2;
            end

        else
            p.st2 = ProductManager.ST_TYPE_IN_EQUIPBAG;
            p.idx = kind - 1;
        end



        ProductTipProxy.broadcastTxt = LanguageMgr.Get("ProductTip/ProductTipProxy/label1");

        SocketClientLua.Get_ins():SendMessage(CmdType.Move_Product, p);

    else
        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, { title = LanguageMgr.Get("common/notice"), msg = LanguageMgr.Get("ProductTip/ProductTipProxy/label2") });
    end



end

-- 卸下装备
function ProductTipProxy.TryUnDress(info)

    local pid = HeroController.GetInstance().id;

    local p = { };
    p.id1 = info:GetId();
    p.pt1 = pid;
    p.st1 = info:GetSt();


    p.id2 = nil;
    p.pt2 = pid;
    p.st2 = ProductManager.ST_TYPE_IN_BACKPACK;

    p.idx = BackpackDataManager.GetFreeIdx();
    ProductTipProxy.broadcastTxt = LanguageMgr.Get("ProductTip/ProductTipProxy/label3");


    SocketClientLua.Get_ins():SendMessage(CmdType.Move_Product, p);

end

function ProductTipProxy.Dress_Equip_Result(cmd, data)


    if (data.errCode == nil) then
        if ProductTipProxy.broadcastTxt ~= nil then
            MsgUtils.ShowTips(nil, nil, nil, ProductTipProxy.broadcastTxt);
            ProductTipProxy.broadcastTxt = nil;
        end

        ModuleManager.SendNotification(ProductTipNotes.CLOSE_EQUIPTIPPANEL);
        ModuleManager.SendNotification(ProductTipNotes.CLOSE_SAMPLEPRODUCTTIPPANEL);
        ModuleManager.SendNotification(ProductTipNotes.CLOSE_EQUIPCOMPARISONTIPPANEL);
    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end


end


function ProductTipProxy.TrySell(info, force)

    local _type = info:GetType();
    local quality = info:GetQuality();

    --  http://192.168.0.8:3000/issues/9275
    if _type == 1 then
        -- 装备出售
        if quality > 3 and not force then
            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                title = LanguageMgr.Get("common/notice"),
                msg = LanguageMgr.Get("ProductTip/ProductTipProxy/label4"),
                ok_Label = LanguageMgr.Get("common/ok"),
                cance_lLabel = LanguageMgr.Get("common/abandon"),
                hander = ProductTipProxy.SToSell,
                data = info
            } );
        else
            ProductTipProxy.SToSell(info);
        end
        -- end if

    else
        -- 道具出售  0  1
        if quality > 3 and not force then
            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                title = LanguageMgr.Get("common/notice"),
                msg = LanguageMgr.Get("ProductTip/ProductTipProxy/label4"),
                ok_Label = LanguageMgr.Get("common/ok"),
                cance_lLabel = LanguageMgr.Get("common/abandon"),
                hander = ProductTipProxy.SellSamplePro,
                data = info
            } );
        else
            ProductTipProxy.SellSamplePro(info);

        end

    end

end


function ProductTipProxy.SellSamplePro(info)

    local am = info:GetAm();

    if am > 1 then
        ModuleManager.SendNotification(ProductTipNotes.SHOW_PRODUCTSELLPANEL, info);
    else
        ProductTipProxy.SToSell(info, nil);
    end


end

function ProductTipProxy.SToSell(info, num)

    if num == nil then
        num = info:GetAm();
    end


    SocketClientLua.Get_ins():SendMessage(CmdType.Sell_Product, { id = info:GetId(), num = num });
end

function ProductTipProxy.Sell_Product_Result(cmd, data)

    ModuleManager.SendNotification(ProductTipNotes.CLOSE_EQUIPTIPPANEL);
    ModuleManager.SendNotification(ProductTipNotes.CLOSE_SAMPLEPRODUCTTIPPANEL);
    ModuleManager.SendNotification(ProductTipNotes.CLOSE_PRODUCTSELLPANELL);

    ModuleManager.SendNotification(ProductTipNotes.CLOSE_EQUIPCOMPARISONTIPPANEL);

    MsgUtils.ShowTips("ProductTip/ProductTipProxy/label6");




end

function ProductTipProxy.TryUseProduct(productInfo, num, hander)
    -- 判断是否是灵药
    ProductTipProxy.use_handler = hander;

    local spid = productInfo:GetSpId();
    local obj = ProductManager.GetProductById(spid);
    if obj.type == ProductManager.type_6 then
        local fixMe = LingYaoDataManager.CheckIsFixMyCareer(spid)
        if not fixMe then
            MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("ProductTip/ProductTipProxy/label7"));
            return;
        end
    end
    -- 判断倍数经验buff
    local id = productInfo:GetId()
    spid = tonumber(spid)
    -- Warning(id .."_______"..tostring(spid).."_______"..tostring(num))
    if spid == 500070 or spid == 500071 or spid == 500072 then
        local hbuffs = HeroController.GetInstance():GetBuffs()
        local expbuff = nil
        -- Warning(tostring(hbuffs).. "___"..tostring(#hbuffs))
        if hbuffs then
            for i = 1, #hbuffs, 1 do
                -- Warning(tostring(hbuffs[i]) .."_"..tostring(hbuffs[i]:GetId()).."_"..tostring(i))
                if hbuffs[i]:GetId() == 218000 then
                    expbuff = hbuffs[i]
                    break
                end
            end
        end
        if expbuff then
            -- PrintTable(expbuff.info, "___", Warning)
            local lev = tonumber(productInfo:GetFunPara()[2])
            local clev = expbuff:GetLevel()
            local tips = nil
            if lev > clev then
                tips = "ProductTip/ProductTipProxy/expTips2"
            elseif lev < clev then
                tips = "ProductTip/ProductTipProxy/expTips1"
            end
            -- Warning(tostring(lev) .."_"..tostring(clev).."_"..tostring(tips))
            if tips then
                MsgUtils.ShowConfirm(self, tips, { name = expbuff:GetName() }, function()
                    ProductTipProxy._UseProduct(id, num)
                end )
                return
            end
        end
    end
    ProductTipProxy._UseProduct(id, num)
end
function ProductTipProxy._UseProduct(id, num)
    ProductTipProxy.useAm = num
    SocketClientLua.Get_ins():SendMessage(CmdType.Use_Product, { id = id, am = num })
end

function ProductTipProxy.Use_Product_Result(cmd, data)


    if (data.errCode == nil) then

        -- MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("ProductTip/ProductTipProxy/label8"));

        ModuleManager.SendNotification(ProductTipNotes.CLOSE_PRODUCTUSEPANELL);

        ModuleManager.SendNotification(ProductTipNotes.CLOSE_EQUIPTIPPANEL);

        ModuleManager.SendNotification(ProductTipNotes.CLOSE_SAMPLEPRODUCTTIPPANEL);

        BackPackCDData.CheckUseProduct(data.spId);

        -- 判断是否是灵药
        local obj = ProductManager.GetProductById(data.spId);
        if obj.type == ProductManager.type_6 then
            LingYaoDataManager.AddHasAm(data.spId, ProductTipProxy.useAm);
            PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.LingYao)
            MessageManager.Dispatch(LingYaoProxy, LingYaoProxy.MESSAGE_USE_PRO_COMPLETE);
        end

        if ProductTipProxy.use_handler ~= nil then
            ProductTipProxy.use_handler();
        end

        local spId = data.spId;
        local cf = ProductManager.GetProductById(spId);

        if cf ~= nil and cf.use_tips ~= nil and cf.use_tips ~= "" then
            MsgUtils.ShowTips(nil, nil, nil, cf.use_tips);
        end


    else

        if data.errCode == 3 then
            -- ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 3});

            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                msg = LanguageMgr.Get("common/xianyubuzu"),
                hander = function()
                    -- ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 3})
                    ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL, { code_id = 3 });
                end,
            } );


        end

    end


end
