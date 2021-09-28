--[[
i3k_sbean.Prop = i3k_class("Prop")
function i3k_sbean.Prop:ctor()
	--self.id:		int32	
	--self.value:		int32	
end

i3k_sbean.DBDiagram = i3k_class("DBDiagram")
function i3k_sbean.DBDiagram:ctor()
	--self.id:		int32	
	--self.part:		int32	
	--self.baseProp:		vector[Prop]	
	--self.additionProp:		vector[int32]	
	--self.padding1:		int32	
	--self.padding2:		int32	
	--self.padding3:		int32	
end

i3k_sbean.DBDiagramStrength = i3k_class("DBDiagramStrength")
function i3k_sbean.DBDiagramStrength:ctor()
	--self.partId:		int32	
	--self.level:		int32	
	--self.failTime:		int32	
    --self.changeInfo:      DBDiagramChangePartInfo 
    --self.padding1_2:      int8    
    --self.padding1_3:      int8    
    --self.padding1_4:      int8    
	--self.padding2:		int32	
end
i3k_sbean.DBDiagramChangePartInfo = i3k_class("DBDiagramChangePartInfo")
function i3k_sbean.DBDiagramChangePartInfo:ctor()
    --self.equipSkill:      int32   
    --self.propPoints:      map[int32, int32]   
end

i3k_sbean.DBPropStone = i3k_class("DBPropStone")
function i3k_sbean.DBPropStone:ctor()
	--self.stones:		vector[PropStone]	
end

i3k_sbean.PropStone = i3k_class("PropStone")
function i3k_sbean.PropStone:ctor()
	--self.propId:		int32	
	--self.quality:		int32	
end

i3k_sbean.UseStones = i3k_class("UseStones")
function i3k_sbean.UseStones:ctor()
	--self.props:		set[int32]	
end

i3k_sbean.DBDiagramChange = i3k_class("DBDiagramChange")
function i3k_sbean.DBDiagramChange:ctor()
    --self.usedChangePoint:     int32   
    --self.buyChangePointNum:       int32   
    --self.changeSkills:        map[int32, int32]   
end
]]
--八卦锻造同步
function i3k_sbean.request_eightdiagram_sync_req()
    local data = i3k_sbean.eightdiagram_sync_req.new()
    i3k_game_send_str_cmd(data, "eightdiagram_sync_res")
end

function i3k_sbean.eightdiagram_sync_res.handler(bean)
    --[[<field name="energy" type="int32"/>
	    <field name="bagDiagrams" type="map[int32, DBDiagram]"/>
	   	<field name="equipDiagrams" type="map[int32, DBDiagram]"/>
	   	<field name="partStrength" type="map[int32, DBDiagramStrength]"/>
        <field name="propStones" type="vector[DBPropStone]"/>
    ]]
    g_i3k_game_context:setEquipDiagrams(bean.equipDiagrams)
    g_i3k_game_context:setPartStrength(bean.partStrength)
    g_i3k_game_context:SetBagDiagrams(bean.bagDiagrams)
    g_i3k_game_context:SetBaguaEnergy(bean.energy)
    g_i3k_game_context:SetBaguaYilue(bean.diagramChange)--包含 已用点数、购买点数、技能

    g_i3k_ui_mgr:OpenUI(eUIID_Bagua)
    g_i3k_ui_mgr:RefreshUI(eUIID_Bagua)

    g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "setPropStones", bean.propStones)
end

--八卦强化
function i3k_sbean.request_eightdiagram_strength_req(partId, costItems)
    local data = i3k_sbean.eightdiagram_strength_req.new()
    data.partId = partId
    data.costItems = costItems
    i3k_game_send_str_cmd(data, "eightdiagram_strength_res")
end

function i3k_sbean.eightdiagram_strength_res.handler(bean, req)
    --<field name="ok" type="int32"/>
    if bean.ok == 1 then
        g_i3k_ui_mgr:PopupTipMessage("强化成功")
    elseif bean.ok == 2 then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17109))
    else
        g_i3k_ui_mgr:PopupTipMessage("强化失败")
    end

    g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "strengthResult", bean.ok)
end

--八卦分解
function i3k_sbean.request_eightdiagram_splite_req(equipIds, getItems)
    local data = i3k_sbean.eightdiagram_splite_req.new()
    data.id = equipIds
    data.getItems = getItems
    i3k_game_send_str_cmd(data, "eightdiagram_splite_res")
end

function i3k_sbean.eightdiagram_splite_res.handler(bean, req)
    --<field name="ok" type="int32"/>
    if bean.ok > 0 then
        for k, v in pairs(req.id) do
            g_i3k_game_context:DelBagDiagrams(k)
        end

        g_i3k_ui_mgr:RefreshUI(eUIID_BaguaSaleBat)
        g_i3k_ui_mgr:CloseUI(eUIID_BaguaTips)
        g_i3k_ui_mgr:CloseUI(eUIID_BaguaSplitSure)
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "showIndex", 1)  --刷新八卦背包界面
        g_i3k_ui_mgr:ShowGainItemInfo(req.getItems)
    else
        g_i3k_ui_mgr:PopupTipMessage("分解失败")
    end
end

--八卦萃取
function i3k_sbean.request_eightdiagram_extraction_req(id, costItems, getItems)
    local data = i3k_sbean.eightdiagram_extraction_req.new()
    data.id = id
    data.costItems = costItems
    data.getItems = getItems
    i3k_game_send_str_cmd(data, "eightdiagram_extraction_res")
end

function i3k_sbean.eightdiagram_extraction_res.handler(bean, req)
    --<field name="ok" type="int32"/>
    if bean.ok > 0 then
        g_i3k_game_context:DelBagDiagrams(req.id)
        for _, v in pairs(req.costItems) do
            g_i3k_game_context:UseCommonItem(v.id, v.count, "")
        end

        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "showIndex", 1)  --刷新八卦背包界面
        g_i3k_ui_mgr:CloseUI(eUIID_BaguaExtract)
        g_i3k_ui_mgr:ShowGainItemInfo(req.getItems)
    else
        g_i3k_ui_mgr:PopupTipMessage("萃取失败")
    end
end

--八卦制造

--<field name="part" type="int32"/>
--<field name="useStone" type="vector[UseStones]"/>
--<field name="sacrifice" type="int32"/>
function i3k_sbean.request_eightdiagram_create_req(part, useStone, sacrifice)
    local data = i3k_sbean.eightdiagram_create_req.new()
    data.part = part
    data.useStone = useStone
    data.sacrifice = sacrifice
    i3k_game_send_str_cmd(data, "eightdiagram_create_res")
end

function i3k_sbean.eightdiagram_create_res.handler(bean, req)
    --<field name="ok" type="int32"/>
    --<field name="diagram" type="DBDiagram"/>
    if bean.ok > 0 then
        g_i3k_ui_mgr:OpenUI(eUIID_BaguaTips)
        g_i3k_ui_mgr:RefreshUI(eUIID_BaguaTips, {equip = bean.diagram, isOut = true})

        g_i3k_game_context:AddBagDiagrams(bean.diagram)

        for i, v in ipairs(i3k_db_bagua_cfg.makeCost) do
            g_i3k_game_context:UseCommonItem(v.id, v.count)
        end
        if req.sacrifice ~= 0 then
            g_i3k_game_context:UseCommonItem(req.sacrifice, 1)
        end
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "useStone", req.useStone)
        g_i3k_ui_mgr:PopupTipMessage("恭喜您，锻造成功")
    else
        g_i3k_ui_mgr:PopupTipMessage("八卦锻造失败")
    end
end

--八卦装备
function i3k_sbean.request_eightdiagram_equip_req(id, part)
    local data = i3k_sbean.eightdiagram_equip_req.new()
    data.id = id
    data.part = part
    i3k_game_send_str_cmd(data, "eightdiagram_equip_res")
end

function i3k_sbean.eightdiagram_equip_res.handler(bean, req)
    --<field name="ok" type="int32"/>
    if bean.ok > 0 then
        local oldDiagram = g_i3k_game_context:getEquipDiagrams()[req.part]
        if oldDiagram then
            g_i3k_game_context:AddBagDiagrams(oldDiagram)
        end
        g_i3k_game_context:wearEquipDiagrams(req.id, req.part)
        g_i3k_game_context:DelBagDiagrams(req.id)

        g_i3k_game_context:refreshBaguaProp()

        g_i3k_ui_mgr:CloseUI(eUIID_BaguaTips)
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "showIndex", 1)  --刷新八卦背包界面
        g_i3k_ui_mgr:PopupTipMessage("装备八卦成功")
    else
        g_i3k_ui_mgr:PopupTipMessage("装备八卦失败")
    end
end

--八卦取消装备
function i3k_sbean.request_eightdiagram_unequip_req(partId)
    local data = i3k_sbean.eightdiagram_unequip_req.new()
    data.partId = partId
    i3k_game_send_str_cmd(data, "eightdiagram_unequip_res")
end

function i3k_sbean.eightdiagram_unequip_res.handler(bean, req)
    --<field name="ok" type="int32"/>
    if bean.ok > 0 then
        local oldDiagram = g_i3k_game_context:getEquipDiagrams()[req.partId]
        if oldDiagram then
            g_i3k_game_context:AddBagDiagrams(oldDiagram)
        end
        g_i3k_game_context:unwearEquipDiagrams(req.partId)

        g_i3k_game_context:refreshBaguaProp()

        g_i3k_ui_mgr:CloseUI(eUIID_BaguaTips)
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "unEquip")  --刷新八卦背包界面
        g_i3k_ui_mgr:PopupTipMessage("卸下八卦成功")
    else
        g_i3k_ui_mgr:PopupTipMessage("卸下八卦失败")
    end
end

--使用八卦原石
--<field name="poolId" type="int32"/>
--<field name="itemId" type="int32"/>
function i3k_sbean.request_eightdiagram_use_stonebag_req(poolId, itemId)
    local data = i3k_sbean.eightdiagram_use_stonebag_req.new()
    data.poolId = poolId
    data.itemId = itemId
    i3k_game_send_str_cmd(data, "eightdiagram_use_stonebag_res")
end

function i3k_sbean.eightdiagram_use_stonebag_res.handler(bean, req)
    --<field name="ok" type="int32"/>
    --<field name="result" type="vector[PropStone]"/>
    if bean.ok > 0 then
        g_i3k_game_context:UseCommonItem(req.itemId, 1, "")
        g_i3k_ui_mgr:CloseUI(eUIID_BaguaStoneSelect)
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "setOnePropStones", bean.result, req.poolId)
    else
        g_i3k_ui_mgr:PopupTipMessage("使用八卦原石失败")
    end
end

--登陆同步八卦锻造属性相关
function i3k_sbean.role_eightdiagram_info.handler(bean)
    g_i3k_game_context:setEquipDiagrams(bean.equipDiagrams)
    g_i3k_game_context:setPartStrength(bean.partStrength)
	g_i3k_game_context:SetBaguaYilue(bean.diagramChange)
end

--取消属性石
function i3k_sbean.request_eightdiagram_del_stonepool_req(poolId,energy)
    local data = i3k_sbean.eightdiagram_del_stonepool_req.new()
    data.poolId = poolId
    data.energy = energy
    i3k_game_send_str_cmd(data, "eightdiagram_del_stonepool_res")
end

function i3k_sbean.eightdiagram_del_stonepool_res.handler(bean, req)
    if bean.ok == 1 then
        g_i3k_ui_mgr:ShowGainItemInfo({{id = g_BASE_ITEM_BAGUA_ENERGY,count = req.energy}})
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua,"initMake")
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "setOnePropStones", {}, req.poolId)
    end
end
function i3k_sbean.sacrifaceSplit(items, gainItems)
    local data = i3k_sbean.item_splite_req.new()
    data.items = items
	data.gainItems = gainItems
    i3k_game_send_str_cmd(data, "item_splite_res")
end
function i3k_sbean.item_splite_res.handler(bean, req)
    if bean.ok > 0 then
		for k, v in pairs(req.items) do
			g_i3k_game_context:UseCommonItem(k, v, AT_USE_BAGUA_SACRIFACE)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_BaGuaSacrificeCheck)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gainItems)
    end
end
function i3k_sbean.sacrifaceCompound(suit, parts, cost, gainItems)
    local data = i3k_sbean.item_compose_req.new()
    data.suit = suit
    data.parts = parts
	data.cost = cost
	data.gainItems = gainItems
    i3k_game_send_str_cmd(data, "item_compose_res")
end
function i3k_sbean.item_compose_res.handler(bean, req)	
    if bean.ok > 0 then
		for k, v in pairs(req.cost) do
			g_i3k_game_context:UseCommonItem(k, v, AT_USE_BAGUA_SACRIFACE_COMPOUND)
		end
		g_i3k_ui_mgr:ShowGainItemInfo(req.gainItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_BaGuaSacrificeCheck)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BaGuaSacrificeCompound, "choseSuit", req.suit)
    end
end
--开启易略玩法
function i3k_sbean.unlock_Yilue()
    local bean = i3k_sbean.eightdiagram_change_open_req.new()
    i3k_game_send_str_cmd(bean, "eightdiagram_change_open_res")
end
function i3k_sbean.eightdiagram_change_open_res.handler(bean)
    if bean.ok > 0 then
        g_i3k_game_context:SetPrePower()
        g_i3k_game_context:InitYilueData()
        g_i3k_ui_mgr:CloseUI(eUIID_BaguaYilue)
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "showIndex", 4)
        g_i3k_game_context:refreshBaguaProp()
    else
        g_i3k_ui_mgr:PopupTipMessage("开启易略失败")
    end
end
--购买易略点数
function i3k_sbean.buyYiluePoint(buyNum)
    local bean = i3k_sbean.eightdiagram_change_buy_point_req.new()
    bean.buyNum = buyNum
    i3k_game_send_str_cmd(bean, "eightdiagram_change_buy_point_res")
end
function i3k_sbean.eightdiagram_change_buy_point_res.handler(bean, req)
    if bean.ok > 0 then
        for i, v in pairs(i3k_db_bagua_yilue_pointCfg[req.buyNum].buyCfg) do
            g_i3k_game_context:UseCommonItem(i, v)
        end
        if req.buyNum == #i3k_db_bagua_yilue_pointCfg then
            g_i3k_ui_mgr:CloseUI(eUIID_BaguaYilueByPoint)
        else
            g_i3k_ui_mgr:RefreshUI(eUIID_BaguaYilueByPoint, req.buyNum)
        end
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "popByPointOkMsg")
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "addByYiluePoints")
    else
        g_i3k_ui_mgr:PopupTipMessage("购买失败")
    end
end
--保存加点数
function i3k_sbean.SaveYiluePoint(partId, points)
    local bean = i3k_sbean.eightdiagram_change_update_point_req.new()
    bean.part = partId
    bean.props = points
    i3k_game_send_str_cmd(bean, "eightdiagram_change_update_point_res")
end
function i3k_sbean.eightdiagram_change_update_point_res.handler(bean, req)
    if bean.ok > 0 then
        g_i3k_game_context:SaveYilueAddPoint(req.part, req.props)
        g_i3k_game_context:refreshBaguaProp()
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "saveOtherPoint")
    else
        g_i3k_ui_mgr:PopupTipMessage("保存点数失败")
    end
end
--重置点数
function i3k_sbean.ResetAddPoint(partId)
    local bean = i3k_sbean.eightdiagram_change_reset_point_req.new()
    bean.part = partId
    i3k_game_send_str_cmd(bean, "eightdiagram_change_reset_point_res")
end
function i3k_sbean.eightdiagram_change_reset_point_res.handler(bean, req)
    if bean.ok > 0 then
        for i, v in pairs(i3k_db_bagua_cfg.yilueResetPointNeed) do
            g_i3k_game_context:UseCommonItem(i, v.count)
        end
        g_i3k_game_context:setBaguaJinengID(req.part, 0)--卸载技能
        local props = g_i3k_game_context:ResetYiluePoint(req.part)
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "SelectYilue", req.part)
        g_i3k_ui_mgr:CloseUI(eUIID_YilueResetPoint)
        g_i3k_game_context:SaveYilueAddPoint(req.part, props)
        g_i3k_game_context:refreshBaguaProp()
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18267))
    else
        g_i3k_ui_mgr:PopupTipMessage("重置点数失败")
    end
end
--八卦技能升级(包含解锁)
function i3k_sbean.BaguaSkillUplevel(id)
    local bean = i3k_sbean.eightdiagram_change_uplevel_req.new()
    bean.skillID = id
    i3k_game_send_str_cmd(bean, "eightdiagram_change_uplevel_res")
end
function i3k_sbean.eightdiagram_change_uplevel_res.handler(bean, req)
    if bean.ok > 0 then
        g_i3k_game_context:JihuoBaguaYilieSkill(req.skillID)
        local lv = g_i3k_game_context:GetBaguaYilueSkillLevel(req.skillID)
        for i, v in pairs(i3k_db_bagua_yilue_skill[req.skillID].skillJie[lv].needCfg) do
            g_i3k_game_context:UseCommonItem(i, v)
        end
        g_i3k_ui_mgr:CloseUI(eUIID_YilueSkillJihuo)
        g_i3k_ui_mgr:CloseUI(eUIID_YilueSkillShengjie)
        g_i3k_game_context:refreshBaguaProp()
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_YilueSkill, "JihuoAndUpSkill", req.skillID)
    else
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_YilueSkill, "ShowSkillJihuoMsg", req.skillID)
    end
end
--装备易略技能
function i3k_sbean.wearYilueSkill(partID, skillID)
    local bean = i3k_sbean.eightdiagram_change_equip_skill_req.new()
    bean.part = partID
    bean.skillID = skillID
    i3k_game_send_str_cmd(bean, "eightdiagram_change_equip_skill_res")
end
function i3k_sbean.eightdiagram_change_equip_skill_res.handler(bean, req)
    if bean.ok > 0 then
        g_i3k_game_context:setBaguaJinengID(req.part, req.skillID)
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "updateYilueData")
        g_i3k_ui_mgr:RefreshUI(eUIID_YilueSkill)
        g_i3k_game_context:refreshBaguaProp()
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18266))
    else
    end
end
--卸载易略技能
function i3k_sbean.unequipYilueSkill(partID)
    local bean = i3k_sbean.eightdiagram_change_unequip_skill_req.new()
    bean.part = partID
    i3k_game_send_str_cmd(bean, "eightdiagram_change_unequip_skill_res")
end
function i3k_sbean.eightdiagram_change_unequip_skill_res.handler(bean, req)
    if bean.ok > 0 then
        g_i3k_game_context:setBaguaJinengID(req.part, 0)
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "updateYilueData")
        g_i3k_ui_mgr:RefreshUI(eUIID_YilueSkill)
        g_i3k_game_context:refreshBaguaProp()
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18265))
    end
end
