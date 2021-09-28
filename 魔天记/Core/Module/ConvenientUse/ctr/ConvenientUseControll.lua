ConvenientUseControll = class("ConvenientUseControll");
ConvenientUseControll.ins = nil;

ConvenientUseControll.SHOW_TYPE_NONE = -1;

ConvenientUseControll.SHOW_TYPE_0 = 0; -- 道具

ConvenientUseControll.SHOW_TYPE_1 = 1; -- 装备位置1
ConvenientUseControll.SHOW_TYPE_2 = 2;
ConvenientUseControll.SHOW_TYPE_3 = 3;
ConvenientUseControll.SHOW_TYPE_4 = 4;
ConvenientUseControll.SHOW_TYPE_5 = 5;
ConvenientUseControll.SHOW_TYPE_6 = 6;
ConvenientUseControll.SHOW_TYPE_7 = 7;
ConvenientUseControll.SHOW_TYPE_8 = 8;
ConvenientUseControll.SHOW_TYPE_9 = 9;
ConvenientUseControll.SHOW_TYPE_10 = 10; 




-- 正在显示 穿戴、使用 窗口
ConvenientUseControll.STATE_SHOWINGTIPPANEL = 1;


--  没有 穿戴、使用 窗口  ， 只是 添加物品 提示
ConvenientUseControll.STATE_ONLYADDPRODUCT = 2;

--[[
  显示规则：
   ---- 登录 的时候 ----
   从背包获取所有符合并且战力 比装备栏 战力 高的所有 部位装备 和  所有 礼包， 并进行 优先顺序 显示

  ---- 登录 后 ----
  获得新 礼包， 只触发 礼包 提示

  获得新装备， 只触发 新装备 同部位(kind) 的 在 背包中 装备 符合穿戴 的装备  比较提示

  如果同时获得多种装备或者礼包，或者 在显示提示过程中 有多种新物品 获得， 那么就  需要 按优先顺序 显示 多种 对应物品

]]



ConvenientUseControll.MESSAGE_CONVENIENTUSE_TRY_PAUSH = "MESSAGE_CONVENIENTUSE_TRY_PAUSH";
ConvenientUseControll.MESSAGE_CONVENIENTUSE_TRY_RESTART = "MESSAGE_CONVENIENTUSE_TRY_RESTART";

ConvenientUseControll.filter_spids = { 505053, 301410, 302410, 303410, 304410, 500116 };
-- 骨蝎坐骑、4个职业的1级金色武器、脱机丹

local _sortfunc = table.sort 
function ConvenientUseControll:New()
    self = { };
    setmetatable(self, { __index = ConvenientUseControll });
    self.firstLoinHasCheck = false;

    self.kindMaxNum = 8;

    self.taskActPaneShowing = false;
    self.show_type = ConvenientUseControll.SHOW_TYPE_NONE;
    self.actstate = ConvenientUseControll.STATE_ONLYADDPRODUCT;
    self.tg_panel = nil;

    -- 选取 装备提示的 条件是 如果已经真正提示的 装备，那么就记录当前提示最大装备 战力
    self.equipFightIdxs = { };
    self.needCheckAndShow = { };

    -- 仙兵 玄兵 鉴定
    self.wiseEquipList = { };

    self:CleanData();

    MessageManager.AddListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, ConvenientUseControll.EquipChange, self);

    for i = 1, self.kindMaxNum do

        self.equipFightIdxs[i] = -1;
    end

    return self;
end

function ConvenientUseControll.GetIns()

    if ConvenientUseControll.ins == nil then
        ConvenientUseControll.ins = ConvenientUseControll:New();
    end
    return ConvenientUseControll.ins;
end

-- 获取是否是过滤物品
function ConvenientUseControll:CheckCanAddToList(spid)

    local _id = tonumber(spid);
    for key, value in pairs(ConvenientUseControll.filter_spids) do
        if _id == value then
            return false;
        end
    end

    local cf = ProductManager.GetProductById(spid);
    if cf ~= ProductManager.type_1 then
        local my_info = HeroController:GetInstance().info;
        local my_level = my_info.level;
        local req_lev = cf.req_lev;

        if my_level < req_lev then
            return false;
        end

    end

    return true;
end

function ConvenientUseControll:CleanData()

    self.ebox = { };
    -- 宝箱
    self.equipIdxs = { };

    self.addEquipIdxs = { };

    for i = 1, self.kindMaxNum do
        self.equipIdxs[i] = nil;
        self.addEquipIdxs[i] = { };
        self.needCheckAndShow[i] = false;
    end

end

function ConvenientUseControll:OpenTaskActPane()

    -- log("-----------------OpenTaskActPane----------------------");
    self.taskActPaneShowing = true;

    if self.show_type ~= ConvenientUseControll.SHOW_TYPE_NONE then
        -- 如果正在 显示的话， 那么暂停
        self:TryPaushPanel()
    end

end


function ConvenientUseControll:CloseTaskActPane()
    --  log("-----------------CloseTaskActPane----------------------");
    self.taskActPaneShowing = false;

    if self.show_type ~= ConvenientUseControll.SHOW_TYPE_NONE then
        -- 如果正在 显示的话， 那么暂停
        self:TryRemePanel()
    end

end

function ConvenientUseControll:OpenConvenientUsePanel()

    --  log("-----------------OpenConvenientUsePanel----------------------");
    self.actstate = ConvenientUseControll.STATE_SHOWINGTIPPANEL;

end

function ConvenientUseControll:CloseConvenientUsePanel()

    -- log("-----------------CloseConvenientUsePanel----------------------");
    self.actstate = ConvenientUseControll.STATE_ONLYADDPRODUCT;

    self:CheckNeedShowTip();


end

--[[
 尝试 获取 下一个 显示 对象
]]
function ConvenientUseControll:TryGetNextTip(tg_panel)

    self.tg_panel = tg_panel;
    local b = self:CheckNeedShowTip();
    self.tg_panel = nil;

    return self.hasProNeedShow;

end

--[[
提示窗口关闭的时候， 需要检测还有那些物品需要显示
]]
function ConvenientUseControll:CheckNeedShowTip()

    self.hasProNeedShow = false;
    local l_num = table.getn(self.ebox);
    if l_num > 0 then
        self:CheckType0();
        return true;
    end

    for i = 1, self.kindMaxNum do

        local b = self.needCheckAndShow[i];

        if b then
            self:CheckTypex(i);
            return true;
        end
    end


    for key, value in pairs(self.wiseEquipList) do
        if value ~= nil then

            self.hasProNeedShow = true;
            ModuleManager.SendNotification(ConvenientUseNotes.SHOW_CONVENIENTUSEPANEL, value);
            self.show_type = ConvenientUseControll.SHOW_TYPE_10;
            self.wiseEquipList[key] = nil;
            return;
        end
    end





    self.show_type = ConvenientUseControll.SHOW_TYPE_NONE;

    return false;
end


function ConvenientUseControll:GetAndRemoveTopItem(list)
    local temArr = { };
    local _len = table.getn(list);

    if _len == 0 then
        return temArr, nil;
    elseif _len < 2 then

    else
        local index = 1;
        for i = 2, _len do
            temArr[index] = list[i];
            index = index + 1;
        end
    end

    return temArr, list[1];
end




function ConvenientUseControll:CheckType0()

    -- log("------------------------CheckType0---------------------------");

    local _len = table.getn(self.ebox);
    if _len > 0 then

        self.show_type = ConvenientUseControll.SHOW_TYPE_0;
        local topItem = nil;

        self.ebox, topItem = self:GetAndRemoveTopItem(self.ebox)

        local res = BackpackDataManager.GetProductById(topItem:GetId());
        if res ~= nil then

            if self.tg_panel ~= nil then
                self.hasProNeedShow = true;
                self.tg_panel:SetData(res);
            else
                self.hasProNeedShow = true;
                ModuleManager.SendNotification(ConvenientUseNotes.SHOW_CONVENIENTUSEPANEL, res);
            end



        else
            -- 物品不存在， 可能被卖了
            self:CloseConvenientUsePanel();
        end



    else
        -- 检测 是否 还有其他需要 提示的
        self:CheckNeedShowTip();

    end


end

function ConvenientUseControll:CheckTypex(index)

    -- log("------------------------CheckTypex----- " .. index);
    local item = self.equipIdxs[index];

    -- 提示装备
    self.show_type = index;

    if item ~= nil then
        --  log("----------item ~= nil-------------------");

        -- 设置 显示 提示的 战力

        self.equipFightIdxs[self.show_type] = item:GetFight();

        local res = BackpackDataManager.GetProductById(item:GetId());
        if res ~= nil then
            -- log("---------0000000---------------------");
            if self.tg_panel ~= nil then
                self.hasProNeedShow = true;
                --  log("---------111111---------------------");
                self.tg_panel:SetData(res);
            else
                self.hasProNeedShow = true;
                -- log("---------222222---------------------");
                ModuleManager.SendNotification(ConvenientUseNotes.SHOW_CONVENIENTUSEPANEL, res);
            end

            -- 清理 提示 数据
            self.equipIdxs[self.show_type] = nil;
        else
            -- 物品不存在， 可能被卖了
            -- 清理 提示 数据
            --  log("---------3333333333333333---------------------");
            self.equipIdxs[self.show_type] = nil;
            self:CloseConvenientUsePanel();
        end


    else

        --  log("----------item == nil------------------- " .. self.show_type);
        -- 需要检查 在 物品添加队列中是否有物品

        local addList = self.addEquipIdxs[self.show_type];

        if addList ~= nil then

            local a_len = table.getn(addList);

            --  log("-----------table.getn(addList)-------------- " .. a_len);

            if a_len > 0 then
                -- 在同一个部位， 还有需要 显示的装备
                self:CheckAddEquipIdxs(self.show_type);

                -- 尝试 显示提示
                self:CheckTypex(self.show_type);

            else
                -- 添加列表没有新物品
                self.needCheckAndShow[self.show_type] = false;

                --  log("--------- needCheckAndShow == false  -00- " .. self.show_type);

                -- 检测 是否 还有其他需要 提示的
                self:CheckNeedShowTip();

            end
            -- end if

        else
            -- 添加列表没有新物品
            self.needCheckAndShow[self.show_type] = false;

            -- log("--------- needCheckAndShow == false  -11- " .. self.show_type);

            -- 检测 是否 还有其他需要 提示的
            self:CheckNeedShowTip();

        end
        -- end if


    end

end

function ConvenientUseControll:CheckAddEquipIdxs(index)

    local addList = self.addEquipIdxs[index];
    local a_len = table.getn(addList);


    local max_fight = tonumber(self.equipFightIdxs[index]);


    if max_fight == -1 then
        -- -1 的时候， 需要 从装备栏获取
        local eqbag_eq = EquipDataManager.GetProductByKind(index);
        if eqbag_eq ~= nil then

            max_fight = eqbag_eq:GetFight();
        end
    end

    for i = 1, a_len do

        local info = addList[i];

        -- 获取战力
        local eqbag_eq_f = info:GetFight();

        if eqbag_eq_f > max_fight then

            --  设置 装备
            self.equipIdxs[index] = info;
            max_fight = eqbag_eq_f;
        end

    end

    -- 清理 数据
    self.addEquipIdxs[index] = { };

end



-- 暂停
function ConvenientUseControll:TryPaushPanel()
    MessageManager.Dispatch(ConvenientUseControll, ConvenientUseControll.MESSAGE_CONVENIENTUSE_TRY_PAUSH);
end

-- 恢复提示
function ConvenientUseControll:TryRemePanel()
    MessageManager.Dispatch(ConvenientUseControll, ConvenientUseControll.MESSAGE_CONVENIENTUSE_TRY_RESTART);
end



--[[
添加物品的时候 触发

 S <-- 19:31:34.364, 0x0402, 0, {"a":[{"am":1,"st":1,"pt":"20100419","spId":302283,"idx":43,"id":"c4ad77ef-5bfc-45df-ac01-8ff0e4d9ddc6"}],"u":[]}

]]
function ConvenientUseControll:AddProductAndCheck(infoArr)


    local my_info = HeroController:GetInstance().info;
    local my_level = my_info.level;
    local my_career = my_info:GetCareer();

    local hasSomingAdd = false;

    local bbox_new_add = false;
    local eqIndexs_new_add = { };

    for i = 1, self.kindMaxNum do
        eqIndexs_new_add[i] = false;
    end



    local _len = table.getn(infoArr);
    for i = 1, _len do
        local obj = infoArr[i];
        local spId = obj.spId;

        local cf_info = ProductManager.GetProductById(spId);
        local career = cf_info.career;
        local req_lev = cf_info.req_lev;
        local kind = cf_info.kind;

        if cf_info.type == ProductManager.type_1 and(career == my_career or career == 0) and my_level >= req_lev then
            -- 装备

            if kind == EquipDataManager.KIND_XIANBING or kind == EquipDataManager.KIND_XUANBING then

                --  获取到的 仙兵一定是 未鉴定的
                local tinfo = ProductInfo:New();
                tinfo:Init(obj);

                local hasJD = tinfo:IsHasFairyGroove();
                if not hasJD then
                    table.insert(self.wiseEquipList, tinfo);
                end
                hasSomingAdd = true;

            else

                if self.addEquipIdxs[kind] ~= nil then
                    local tinfo = ProductInfo:New();
                    tinfo:Init(obj);

                    local e_len = table.getn(self.addEquipIdxs[kind]);
                    -- 添加到 装备添加队列中
                    self.addEquipIdxs[kind][e_len + 1] = tinfo;
                    hasSomingAdd = true;
                    eqIndexs_new_add[kind] = true;

                end

            end



        elseif cf_info.type == ProductManager.type_5 then

            if kind == 1 or kind == 2 or kind == 9 then
                -- 礼拜，宝箱
               
                local canAdd = self:CheckCanAddToList(spId);
                if canAdd then

                    -- 直接添加到列表就可以了
                    -- http://192.168.0.8:3000/issues/3986
                    -- 现在也需要 提示添加礼包
                    if self.actstate == ConvenientUseControll.STATE_SHOWINGTIPPANEL then

                        local tinfo = ProductInfo:New();
                        tinfo:Init(obj);
                        local b_len = table.getn(self.ebox);
                        self.ebox[b_len + 1] = tinfo;
                    end

                    hasSomingAdd = true;
                    bbox_new_add = true;
                end




            end

        end
    end



    if hasSomingAdd then

        if self.actstate == ConvenientUseControll.STATE_SHOWINGTIPPANEL then
            -- 在 提示显示的状态下, 获取到的物品 放在 添加物品列表中
            -- 需要需要 做 显示 检测 处理， 提示窗口关闭的时候会做检查

            for k = 1, self.kindMaxNum do
                local kb = eqIndexs_new_add[k];
                if kb then
                    -- 设置需要显示的只
                    self.needCheckAndShow[k] = true;

                end
            end



        elseif self.actstate == ConvenientUseControll.STATE_ONLYADDPRODUCT then
            -- 在 没有显示提示的状态下，直接从 背包获取数据

            --  log("----------------STATE_SHOWINGTIPPANEL---11111---------------");

            if bbox_new_add then
                self:GetBBoxsFormPackBag(9);
            end

            for k = 1, self.kindMaxNum do
                local kb = eqIndexs_new_add[k];
                if kb then
                    -- 如果 获得 同部位的装备 ， 而且 当时没有 显示 提示窗口的， 那么就 从背包中获取 符合 提示的 装备提示
                    self:GetEquipsFormPackBagByKind(k);
                end

                -- 需要情况 添加列表的物品
                self.addEquipIdxs[k] = { };

            end


            self:CheckNeedShowTip();
        end

    else

        -- log("-------------hasSomingAdd----false--------");

    end


end

--[[
登录坚持
]]
function ConvenientUseControll:FirstLoinCheck()

    -- log("---------------ConvenientUseControll:FirstLoinCheck--------------------");



    if not self.firstLoinHasCheck then

        self:CleanData();

        -- 优先 宝箱， 后面在 装备
        self:GetBBoxsFormPackBag(nil);
        self:GetEquipsFormPackBag();
        self:GetWiseEquipFormPackBag();

        self.firstLoinHasCheck = true;

        self:CheckNeedShowTip();
    end

end

-- 寻找 在背包中所有未鉴定的 仙兵 玄 兵
function ConvenientUseControll:GetWiseEquipFormPackBag()
    self.wiseEquipList = BackpackDataManager.GetAllUnJDWiseEquip();
end

function ConvenientUseControll:GetEquipsFormPackBag()

    for i = 1, self.kindMaxNum do
        self:GetEquipsFormPackBagByKind(i);
    end
    -- end for

end

function ConvenientUseControll:GetEquipsFormPackBagByKind(i)

    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();

    local eqs = BackpackDataManager.GetFixMyEqByTypeAndKind(ProductManager.type_1, i, my_career);

    local eqbag_eq = EquipDataManager.GetProductByKind(i);

    local eqbag_eq_f = 0;

    if eqbag_eq ~= nil then


        eqbag_eq_f = eqbag_eq:GetFight();

    end

    --  在背包列表中 比较
    local maxF_eq = nil;
    -- 最大战斗力 装备
    local maxF_value = 0;

    local eq_len = table.getn(eqs);
    for j = 1, eq_len do

        local spId = eqs[j]:GetSpId();
        local canAdd = self:CheckCanAddToList(spId);
        if canAdd then


            local eq_f = eqs[j]:GetFight();

            if eq_f > eqbag_eq_f then
                if eq_f > maxF_value then
                    maxF_eq = eqs[j];
                    maxF_value = eq_f;
                end
            end
        end

    end
    -- end for

    if maxF_eq ~= nil then

        -- 如果获取到更好的装备， 那么就添加到提示列表中
        self.equipIdxs[i] = maxF_eq:Clone();

        -- 设置 显示 提示的 战力
        self.equipFightIdxs[i] = maxF_value;

        -- 设置需要显示的只
        self.needCheckAndShow[i] = true;
        -- log("--------- needCheckAndShow == true  -- " .. i);
    else
        -- 如果没有需要提示的装备， 那么判断战力是  装备栏里面的战力
        self.equipFightIdxs[i] = -1;

    end

end


--  http://192.168.0.8:3000/issues/9828
--  kind == 9  登录不提示， 获得才提示
function ConvenientUseControll:GetBBoxsFormPackBag(ext_kind)

    local boxs1 = BackpackDataManager.GetProductsByTypes2(ProductManager.type_5, 1);
    local boxs2 = BackpackDataManager.GetProductsByTypes2(ProductManager.type_5, 2);
    local boxs3 = nil;

    if ext_kind ~= nil then

        boxs3 = BackpackDataManager.GetProductsByTypes2(ProductManager.type_5, ext_kind);
    end 

    local eb_len = table.getn(self.ebox);
    local l_num = 0;

    local spId = nil;

    if boxs1 ~= nil then
        l_num = table.getn(boxs1);
        for i = 1, l_num do
            spId = boxs1[i]:GetSpId();
            local canAdd = self:CheckCanAddToList(spId);
            if canAdd then
                eb_len = eb_len + 1;
                self.ebox[eb_len] = boxs1[i]:Clone();
            end

        end
    end
    -------------------------------------------
    if boxs2 ~= nil then
        l_num = table.getn(boxs2);
        for i = 1, l_num do
            spId = boxs2[i]:GetSpId();
            local canAdd = self:CheckCanAddToList(spId);
            if canAdd then
                eb_len = eb_len + 1;
                self.ebox[eb_len] = boxs2[i]:Clone();
            end

        end
    end

    -----------------------------------------------

      if boxs3 ~= nil then
        l_num = table.getn(boxs3);
        for i = 1, l_num do
            spId = boxs3[i]:GetSpId();
            local canAdd = self:CheckCanAddToList(spId);
            if canAdd then
                eb_len = eb_len + 1;
                self.ebox[eb_len] = boxs3[i]:Clone();
            end

        end
    end

    ------------- 宝箱需要 通过  spid 进行排序 -----------------
    l_num = table.getn(self.ebox);



    if l_num > 1 then
        _sortfunc(self.ebox, function(a, b)

            local a_id = tonumber(a:GetSpId());
            local b_id = tonumber(b:GetSpId());

            if (a_id < b_id) then
                return true
            else
                return false
            end
        end );
    end

    --  log("----------------------GetBBoxsFormPackBag-------------------------------------- "..l_num);
    --  PrintTable(self.ebox);

end

function ConvenientUseControll:EquipChange()

    for i = 1, self.kindMaxNum do
        local eqbag_eq = EquipDataManager.GetProductByKind(i);
        if eqbag_eq == nil and self.equipFightIdxs[i] ~= -1 then
            self.equipFightIdxs[i] = -1;
        end
    end

end


function ConvenientUseControll:Dispose()

    MessageManager.RemoveListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, ConvenientUseControll.EquipChange);
    ConvenientUseControll.ins = nil;
    self.tg_panel = nil;
    self.equipFightIdxs = nil;
end