
require "Core.Manager.ConfigManager"

ProducTipsManager = { };
ProducTipsManager.cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT_TIPS); -- require "Core.Config.product_tips"

ProducTipsManager.CONTAINER_TYPE_IN_BAG = 1;
ProducTipsManager.CONTAINER_TYPE_IN_EQ_BAG = 2;

-- 使用 药品使用1次使用1个，有cd判断
ProducTipsManager.fun_drug_shiyong = "fun_drug_shiyong";
-- 卸下 装备在角色身上时，显示卸下
ProducTipsManager.fun_equip_xiexia = "fun_equip_xiexia";
-- 使用 打开灵药合成界面
ProducTipsManager.fun_panacea_hecheng = "fun_panacea_hecheng";
-- 使用 打开翅膀培养界面
ProducTipsManager.fun_wing_peiyang = "fun_wing_peiyang";
-- 合成 打开合成界面紫阳石标签页(不满足后面等级时，不显示合成按钮)
ProducTipsManager.fun_trump_hecheng = "fun_trump_hecheng";
-- 使用 打开法宝炼制界面
ProducTipsManager.fun_trump_lianzhi = "fun_trump_lianzhi";
-- 使用 打开神器界面
ProducTipsManager.fun_equip_shengxing = "fun_equip_shengxing";
-- 寄售 打开寄售系统的上架界面(不满足后面等级时，不显示寄售按钮;所有绑定的物品不显示寄售按钮)
ProducTipsManager.fun_product_jishou = "fun_product_jishou";
-- 合成 打开合成界面精炼材料标签页(不满足lev_req，不显示合成按钮)
ProducTipsManager.fun_equip_hecheng = "fun_equip_hecheng";
-- 穿戴 装备在角色背包时，显示穿戴
ProducTipsManager.fun_equip_chuandai = "fun_equip_chuandai";
-- 精炼 打开装备精炼界面
ProducTipsManager.fun_equip_jinglian = "fun_equip_jinglian";
-- 强化 打开装备强化界面
ProducTipsManager.fun_equip_qianghua = "fun_equip_qianghua";
-- 合成 打开宝石合成界面
ProducTipsManager.fun_jewel_hecheng = "fun_jewel_hecheng";
-- 使用 打开伙伴进阶界面
ProducTipsManager.fun_advanced_shiyong = "fun_advanced_shiyong";
-- 出售 
ProducTipsManager.fun_product_chushou = "fun_product_chushou";
-- 镶嵌 打开宝石镶嵌界面
ProducTipsManager.fun_jewel_xiangqian = "fun_jewel_xiangqian";
-- 使用 打开伙伴信息界面、资质洗练界面
ProducTipsManager.fun_aptitude_shiyong = "fun_aptitude_shiyong";
-- 使用 打开伙伴信息界面、伙伴经验药水使用界面（点击+号弹出的选择界面）
ProducTipsManager.fun_exp_shiyong = "fun_exp_shiyong";
-- 使用 直接使用
ProducTipsManager.fun_product_shiyong = "fun_product_shiyong";
-- 合成 打开合成界面丹药材料标签页(不满足后面等级时，不显示合成按钮)
ProducTipsManager.fun_materials_hecheng = "fun_materials_hecheng";

-- 使用 打开境界凝练界面
ProducTipsManager.fun_realm_ninglian = "fun_realm_ninglian";

-- 使用 打开坐骑界面
ProducTipsManager.fun_ride_jihuo = "fun_ride_jihuo";

-- 打开仙玉礼包二次确认界面，消耗的仙玉数量读取道具表fun_para的第一个参数
ProducTipsManager.fun_pay_box = "fun_pay_box";

-- （使用道具）激活坐骑成功后跳转到坐骑界面
ProducTipsManager.fun_ride_jihuo_tiaozhuan = "fun_ride_jihuo_tiaozhuan";

-- 鉴定仙器
ProducTipsManager.fun_fairy_identify = "fun_fairy_identify";

-- 对仙器进行附魔操作
ProducTipsManager.fun_fairy_enchant = "fun_fairy_enchant";
-- 对vip试用操作
ProducTipsManager.fun_vipshiyong = "fun_vipshiyong";
-- 对阵图道具操作
ProducTipsManager.fun_formation = "fun_graphic_exp";

-- 点击后打开伙伴幻化界面
ProducTipsManager.fun_partner_active = "fun_partner_active";

-- 打开挂机设置界面
ProducTipsManager.fun_set_hang = "fun_set_hang";

function ProducTipsManager.TraceFunConstName()

    local str = "";
    for key, value in pairs(ProducTipsManager.cf) do

        local tem = "-- " .. value.name .. " " .. value.des .. "\n";
        tem = tem .. "ProducTipsManager." .. value.interface .. "=\"" .. value.interface .. "\";\n";
        str = str .. tem;

    end
end


--[[
	id	功能id	在道具表（product）中配置，根据道具的不同，配置不同的功能id
	name	名称	道具tips选项上名称显示
	interface	对应界面	功能id对应的界面，需要程序定义后可使用，新加界面时需要找程序添加
	des	功能描述	程序不读
	req_lev	等级需求	填写为0时，表示读取道具表（req_lev）中字段，填写具体的数值时，表示需要达到此等级段才显示该按钮，此处的具体数据时需要跟系统功能开放表（system_unlock）中系统开放等级对应

]]

-- 过滤  所在容器类型
-- container_type   容器类型 1 背包 2 装备栏
function ProducTipsManager.GetInfoById_ct_container_type(container_type, id)

    local info = ProducTipsManager.cf[tonumber(id)];

    if info ~= nil then
        if container_type == ProducTipsManager.CONTAINER_TYPE_IN_BAG then

            -- 过滤 装备卸下对象
            if info.interface ~= ProducTipsManager.fun_equip_xiexia then
                return info;
            end
        elseif container_type == ProducTipsManager.CONTAINER_TYPE_IN_EQ_BAG then
            -- 过滤 除 穿戴 的对象
            if info.interface == ProducTipsManager.fun_equip_xiexia then
                return info;
            end
        end
    end
    return nil;
end


-- 过滤等级限制
function ProducTipsManager.GetInfoBy_ct_leve(info, product_spid)


    if info ~= nil then

        local pro_cf = ConfigManager.GetProductById(product_spid);

        if pro_cf ~= nil then

            local me = HeroController:GetInstance();
            local heroInfo = me.info;
            local my_lv = heroInfo.level;

            local lev_req = info.lev_req;
            local req_lev = pro_cf.req_lev;

            if lev_req == 0 then
                -- 读 道具表（req_lev）
                if my_lv >= req_lev then
                    -- 达到显示 条件
                    return info;
                end

            elseif lev_req > 0 then
                -- 直接读取 lev_req
                if my_lv >= lev_req then
                    -- 达到显示 条件
                    return info;
                end
            elseif lev_req == -1 then
                -- -1 不判断任何　等级要求
                return info;

            end
        end
    end
    return nil;
end


-- 判断个别特殊条件
function ProducTipsManager.GetInfoBy_special_ct(info, product_spid, isbind, pro_info)

    if info ~= nil then

        local pro_cf = ConfigManager.GetProductById(product_spid);
        local type = pro_info:GetType();
        local kind = pro_info:GetKind();

        if info.interface == ProducTipsManager.fun_product_jishou and isbind then
            -- 所有绑定的物品不显示寄售按钮
            return nil;

        elseif type == ProductManager.type_1 and(kind == EquipDataManager.KIND_XIANBING or kind == EquipDataManager.KIND_XUANBING) then

            local isjd = pro_info:IsHasFairyGroove();
            if isjd then
                -- 已经鉴定
                if info.interface == ProducTipsManager.fun_fairy_identify then
                    return nil
                end
            else
                -- 还没鉴定
                if info.interface == ProducTipsManager.fun_fairy_enchant or
                    info.interface == ProducTipsManager.fun_equip_chuandai
                    -- or info.interface == ProducTipsManager.fun_product_jishou
                then
                    return nil
                end
            end

        end

    end


    return info;
end

function ProducTipsManager.GetInfoById(container_type, id, product_spid, isbind, pro_info)

    local info = ProducTipsManager.GetInfoById_ct_container_type(container_type, id);

    info = ProducTipsManager.GetInfoBy_ct_leve(info, product_spid);
    info = ProducTipsManager.GetInfoBy_special_ct(info, product_spid, isbind, pro_info);


    return info;
end

--[[
获取符合要求的物品操作提示 代替原来的  ConfigManager.GetTipButtons(container_type, product_type);
]]
function ProducTipsManager.GetTipInfos(container_type, product_spid, isbind, pro_info)

    local pro_cf = ConfigManager.GetProductById(product_spid);
    local list = { };
    local listIndex = 1;

    if pro_cf ~= nil then
        local tips_fun = pro_cf.tips_fun;

        -- tips_fun[1] == 0  表示没有任何 操作提示
        if tips_fun[1] ~= 0 then

            local t_num = table.getn(tips_fun);
            for i = 1, t_num do
                local id = tips_fun[i];

                local p_info = ProducTipsManager.GetInfoById(container_type, id, product_spid, isbind, pro_info)
                if p_info ~= nil then
                    list[listIndex] = p_info;
                    listIndex = listIndex + 1;
                end
            end
        end
    end

    return list;
end



function ProducTipsManager.TryCloseAllTipPanel()

    ModuleManager.SendNotification(ProductTipNotes.CLOSE_EQUIPTIPPANEL);
    ModuleManager.SendNotification(ProductTipNotes.CLOSE_EQUIPCOMPARISONTIPPANEL);
    ModuleManager.SendNotification(ProductTipNotes.CLOSE_SAMPLEPRODUCTTIPPANEL);
    ModuleManager.SendNotification(ProductTipNotes.CLOSE_PRODUCTSELLPANELL);

end

-- 调用对应的方法  代替原来的 ProductTipProxy.DealPruductMenyHandler
function ProducTipsManager.CallFunById(info, productInfo)

    if info ~= nil then

        local spid = productInfo:GetSpId();
        local kind = productInfo:GetKind();
        -- 测试
        --  info.interface = ProducTipsManager.fun_realm_ninglian;

        -- log("info.interface "..info.interface);

        -- 卸下 装备在角色身上时，显示卸下
        if info.interface == ProducTipsManager.fun_equip_xiexia then

            ProductTipProxy.TryUnDress(productInfo)

            -- 使用 打开灵药合成界面
        elseif info.interface == ProducTipsManager.fun_panacea_hecheng then

            ModuleManager.SendNotification(LingYaoNotes.OPEN_LINGYAOPANEL, { selectIndex = 2 });
            ProducTipsManager.TryCloseAllTipPanel();
            -- 使用 打开翅膀培养界面
        elseif info.interface == ProducTipsManager.fun_wing_peiyang then

            ModuleManager.SendNotification(WingNotes.OPEN_WINGPANEL);
            ProducTipsManager.TryCloseAllTipPanel();
            -- 合成 打开合成界面紫阳石标签页(不满足后面等级时，不显示合成按钮)
        elseif info.interface == ProducTipsManager.fun_trump_hecheng then

            ModuleManager.SendNotification(ComposeNotes.OPEN_COMPOSE_PANEL, spid);
            ProducTipsManager.TryCloseAllTipPanel();
            -- 使用 打开法宝炼制界面
        elseif info.interface == ProducTipsManager.fun_trump_lianzhi then

            ModuleManager.SendNotification(NewTrumpNotes.OPEN_NEWTRUMPPANEL, 2)
            ProducTipsManager.TryCloseAllTipPanel();

            -- 使用 打开神器界面
        elseif info.interface == ProducTipsManager.fun_equip_shengxing then

            ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_3);
            ProducTipsManager.TryCloseAllTipPanel();
            -- 寄售 打开寄售系统的上架界面(不满足后面等级时，不显示寄售按钮;所有绑定的物品不显示寄售按钮)
        elseif info.interface == ProducTipsManager.fun_product_jishou then


            ModuleManager.SendNotification(SaleNotes.OPEN_SALEPANEL, 2);
            ModuleManager.SendNotification(SaleNotes.CHANGE_SELLPANEL, 2);
            SaleProxy.SendGetRecentPrice(productInfo.configData.id)
            SaleManager.SetCurSelectItem(productInfo)
            ModuleManager.SendNotification(SaleNotes.UPDATE_SELECT_ITEM)

            ProducTipsManager.TryCloseAllTipPanel();
            -- 使用 打开伙伴进阶界面
        elseif info.interface == ProducTipsManager.fun_advanced_shiyong then


            ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL, 2)
            ProducTipsManager.TryCloseAllTipPanel();

            -- 合成 打开合成界面精炼材料标签页(不满足lev_req，不显示合成按钮)
        elseif info.interface == ProducTipsManager.fun_equip_hecheng then

            ModuleManager.SendNotification(ComposeNotes.OPEN_COMPOSE_PANEL, spid);
            ProducTipsManager.TryCloseAllTipPanel();
            -- 穿戴 装备在角色背包时，显示穿戴
        elseif info.interface == ProducTipsManager.fun_equip_chuandai then

            ProductTipProxy.TryDress(productInfo);

            -- 精炼 打开装备精炼界面
        elseif info.interface == ProducTipsManager.fun_equip_jinglian then
            ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_2);
            ProducTipsManager.TryCloseAllTipPanel();

            -- 强化 打开装备强化界面
        elseif info.interface == ProducTipsManager.fun_equip_qianghua then

            ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_1);
            ProducTipsManager.TryCloseAllTipPanel();
            -- 合成 打开宝石合成界面
        elseif info.interface == ProducTipsManager.fun_jewel_hecheng then

            ModuleManager.SendNotification(EquipNotes.OPEN_GEMCOMPOSEPANEL);
            ProducTipsManager.TryCloseAllTipPanel();

            -- 出售
        elseif info.interface == ProducTipsManager.fun_product_chushou then

            ProductTipProxy.TrySell(productInfo);

            -- 镶嵌 打开宝石镶嵌界面
        elseif info.interface == ProducTipsManager.fun_jewel_xiangqian then

            ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_4);
            ProducTipsManager.TryCloseAllTipPanel();
            -- 使用 打开伙伴信息界面、资质洗练界面
        elseif info.interface == ProducTipsManager.fun_aptitude_shiyong then

            ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL, 1);
            -- ModuleManager.SendNotification(PetNotes.OPEN_PETRANDAPTITUDEPANEL);
            ProducTipsManager.TryCloseAllTipPanel();
            -- 使用 打开伙伴信息界面、伙伴经验药水使用界面（点击+号弹出的选择界面）

        elseif info.interface == ProducTipsManager.fun_partner_active then
            ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL, 3);
            ProducTipsManager.TryCloseAllTipPanel();

        elseif info.interface == ProducTipsManager.fun_exp_shiyong then

            ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL, 1);
            ModuleManager.SendNotification(PetNotes.OPEN_UPDATELEVELPANEL);
            ProducTipsManager.TryCloseAllTipPanel();
            -- fun_product_shiyong 使用 直接使用
            -- fun_drug_shiyong    使用 药品使用1次使用1个，有cd判断
        elseif info.interface == ProducTipsManager.fun_product_shiyong or info.interface == ProducTipsManager.fun_drug_shiyong then

            -- 使用物品

            local am = productInfo.am;
            local type = productInfo:GetType();

            if am > 1 and type ~= ProductManager.type_4 then
                ModuleManager.SendNotification(ProductTipNotes.SHOW_PRODUCTUSEPANEL, productInfo);
            else
                ProductTipProxy.TryUseProduct(productInfo, 1)
            end

            -- 合成 打开合成界面丹药材料标签页(不满足后面等级时，不显示合成按钮)
        elseif info.interface == ProducTipsManager.fun_materials_hecheng then

            ModuleManager.SendNotification(ComposeNotes.OPEN_COMPOSE_PANEL, spid);
            ProducTipsManager.TryCloseAllTipPanel();

            -- 使用 打开境界凝练界面
        elseif info.interface == ProducTipsManager.fun_realm_ninglian then
            ModuleManager.SendNotification(RealmNotes.OPEN_REALM, 2);
            ProducTipsManager.TryCloseAllTipPanel();
            -- 使用 打开坐骑界面
        elseif info.interface == ProducTipsManager.fun_ride_jihuo then
            ModuleManager.SendNotification(RideNotes.OPEN_RIDEPANEL);
            ProducTipsManager.TryCloseAllTipPanel();

        elseif info.interface == ProducTipsManager.fun_pay_box then

            ProducTipsManager.fun_pay_box_info = productInfo;
            local fun_para = productInfo.configData.fun_para;


            -- 开启仙玉，职业要求_道具id_道具数量_绑定几率，职业要求_道具id_道具数量_绑定几率，职业要求_道具id_道具数量_绑定几率
            --  ['fun_para'] = {'10','0_410010_1_100','101000_410011_1_50'},
            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                title = LanguageMgr.Get("common/notice"),
                msg = LanguageMgr.Get("ProducTipsManager/label1",{ n = fun_para[1] }),
                ok_Label = LanguageMgr.Get("common/ok"),
                cance_lLabel = LanguageMgr.Get("common/cancle"),
                hander = ProducTipsManager.SureToUseLB,
                data = nil,
                target = self
            } );

        elseif info.interface == ProducTipsManager.fun_ride_jihuo_tiaozhuan then
            local p = nil;
            if spid == 505053 then
                p = 330008;
            end
            ProductTipProxy.TryUseProduct(productInfo, 1, function()
                ProducTipsManager.TryCloseAllTipPanel();
                ModuleManager.SendNotification(BackpackNotes.CLOSE_BAG_ALL);
                ModuleManager.SendNotification(RideNotes.OPEN_RIDEPANEL, p);
            end )

        elseif info.interface == ProducTipsManager.fun_fairy_identify then

            -- http://192.168.0.8:3000/issues/8994
            local my_info = HeroController:GetInstance().info;
            local my_level = my_info.level;
            local req_lev = productInfo:GetReq_lev();

            if my_level < req_lev then

                MsgUtils.ShowTips("ProducTipsManager/label2");
                return;
            end
            -- 鉴定仙器
            WiseEquipPanelProxy.TryWiseEquip_jianding(productInfo.id,nil,productInfo:GetQuality())

        elseif info.interface == ProducTipsManager.fun_fairy_enchant then
            -- 对仙器进行附魔操作

            if kind == EquipDataManager.KIND_XIANBING then
                ModuleManager.SendNotification(WiseEquipPanelNotes.OPEN_WISEEQUIPPANEL, { tabIndex = 2, eqIndex = 1, selectEqInBag = productInfo });
            elseif kind == EquipDataManager.KIND_XUANBING then
                ModuleManager.SendNotification(WiseEquipPanelNotes.OPEN_WISEEQUIPPANEL, { tabIndex = 2, eqIndex = 2, selectEqInBag = productInfo });
            end
            ProducTipsManager.TryCloseAllTipPanel();
        elseif info.interface == ProducTipsManager.fun_vipshiyong then
            ModuleManager.SendNotification(VipTryNotes.OPEN_VIP_TRY_PANEL
            , { s = 1, id = spid })
        elseif info.interface == ProducTipsManager.fun_formation then
            ModuleManager.SendNotification(FormationNotes.OPEN_FORMATION_PANEL, { s = 1, id = spid })
--            ModuleManager.SendNotification(MainUINotes.OPEN_MYROLEPANEL
--            , { 4, spid })
            ProducTipsManager.TryCloseAllTipPanel();

        elseif info.interface == ProducTipsManager.fun_set_hang then

            ModuleManager.SendNotification(AutoFightNotes.OPEN_AUTOFIGHTPANEL);

            ProducTipsManager.TryCloseAllTipPanel();


        else
            log(" unSet info.interface " .. info.interface);

        end
    end

end

function ProducTipsManager.SureToUseLB()


    ProductTipProxy.TryUseProduct(ProducTipsManager.fun_pay_box_info, 1)
    ProducTipsManager.TryCloseAllTipPanel();

end