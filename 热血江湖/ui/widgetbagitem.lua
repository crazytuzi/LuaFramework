-- zengqingfeng
-- 2018/5/30
-- 道具简易小组件
-------------------------------------------------------
module(..., package.seeall)

local require = require;
 
local viewRes = "ui/widgets/zbqht2"

widgetBagItem = i3k_class("widgetBagItem")

function widgetBagItem:ctor(itemRes)
	self.view = nil 
	self.m_viewRes = itemRes
	self.m_data = nil

	-- 显示状态相关
	self.m_NumType = g_ITEM_NUM_SHOW_TYPE_OWN -- 数量显示策略
	self.m_showName = true -- 显示名字
	self.m_showEffect = false -- 环绕特效
end

function widgetBagItem:configure(info)
	self.m_data = info
end 

function widgetBagItem:initView()
	local res = self.m_viewRes or viewRes
	local itemView = require(res)()
	self:View(itemView)
	local widgets = self.view.vars 
	local info = self:Data()
	self:_updateCell(info.id, info.count, info.guids[i], info.value)
	return itemView
end 

--------------------------- 外部接口 公共方法 -------------------------- 
-- get set 
function widgetBagItem:ShowName(value) 
	if value == nil then 
		return self.m_showName -- get 
	else 
		self.m_showName = value -- set 
	end
end 

function widgetBagItem:ShowEffect(value) 
	if value == nil then 
		return self.m_showEffect -- get 
	else 
		self.m_showEffect = value -- set 
	end
end 

function widgetBagItem:NumType(value) 
	if value == nil then 
		return self.m_NumType -- get 
	else 
		self.m_NumType = value -- set 
	end
end 

function widgetBagItem:Data(value) 
	if value == nil then 
		return self.m_data -- get 
	else 
		self.m_data = value -- set 
	end
end 

function widgetBagItem:View(value) 
	if value == nil then 
		return self.view -- get 
	else 
		self.view = value -- set 
	end
end 

--------------------------- 私有方法 内部实现 --------------------------
function widgetBagItem:_updateCell(id, count, guid, value)
	local widgetVars = self:View().vars
	widgetVars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id == 0 and 106 or id))
	widgetVars.item_icon:setImage(id == 0 and g_i3k_db.i3k_db_get_icon_path(2396) or g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	
	if widgetVars.item_name then 
		if self:ShowName() then 
			widgetVars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
			widgetVars.item_name:setVisible(true)
			local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id))
			widgetVars.item_name:setTextColor(name_colour)
		else 
			widgetVars.item_name:setVisible(false)
		end
	end 
	
	if widgetVars.effect then 
		widgetVars.effect:setVisible(self:ShowEffect())
	end 
	
	self:_numShowByType(id, count)
	
	if widgetVars._naijiuBrightNode ~= nil then
		widgetVars.bt:removeChild(widgetVars._naijiuBrightNode)
	end
	
	if widgetVars.suo then 
		widgetVars.suo:setVisible(id>0)
	end
	
	if id == 0 then
		widgetVars.bt:disable()
	else
		widgetVars.bt:enable()
		if widgetVars._tipArgs == nil then
			widgetVars._tipArgs = {}
			widgetVars.bt:onClick(self, self._onTips, widgetVars._tipArgs)
		end
		widgetVars._tipArgs.args = { widgetVars = widgetVars, id = id, guid = guid }
		if not guid and g_i3k_db.i3k_db_get_bag_item_fashion_able(id) then
			widgetVars._tipArgs.func = self._onFashionTips
		elseif not guid and g_i3k_db.i3k_db_get_bag_item_metamorphosis_able(id) then
			widgetVars._tipArgs.func = self._onMetamorphosisTips
		else
			widgetVars._tipArgs.func = guid and self._onEquipTips or self._onItemTips
		end
		if guid then
			local equip = g_i3k_game_context:GetBagEquip(id, guid)
			if equip then
				local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(equip.equip_id, equip.naijiu)
				if rankIndex ~= 0 then
					widgetVars._naijiuBrightNode = require("ui/widgets/zbtx")()
					widgetVars._naijiuBrightNode.vars["an"..rankIndex]:show()
					widgetVars.bt:addChild(widgetVars._naijiuBrightNode)
				end
			end
		end
	end
end

-- 数量显示策略
function widgetBagItem:_numShowByType(id, count)
	local widgetVars = self:View().vars
	local numShowType = self:NumType()
	if guid or numShowType == g_ITEM_NUM_SHOW_TYPE_HIDE then
		widgetVars.item_count:hide()
	else
		widgetVars.item_count:show()
		local countStr = nil
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(id)
		if numShowType == g_ITEM_NUM_SHOW_TYPE_OWN then 
			countStr = canUseCount
		elseif numShowType == g_ITEM_NUM_SHOW_TYPE_NEED then 
			countStr = i3k_get_num_to_show(count)
		elseif numShowType == g_ITEM_NUM_SHOW_TYPE_COMPARE then 
			if math.abs(id) == g_BASE_ITEM_DIAMOND or math.abs(id) == g_BASE_ITEM_COIN then
				countStr = count
			else
				countStr = canUseCount.."/"..count
			end
			widgetVars.item_count:setTextColor(g_i3k_get_cond_color(canUseCount >= count))
		end 
		widgetVars.item_count:setText(countStr)
	end
end 

function widgetBagItem:_onTips(sender, args)
	if args.func then 
		args.func(self, sender, args.args)
	end 
end

function widgetBagItem:_onItemTips(sender, args)
	g_i3k_ui_mgr:OpenUI(eUIID_ItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_ItemInfo, args.id)
end

function widgetBagItem:_onEquipTips(sender, args)
	local equip = g_i3k_game_context:GetBagEquip(args.id, args.guid)
	local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip.equip_id)
	if g_i3k_game_context:isFlyEquip(equipCfg.partID) then
		g_i3k_ui_mgr:OpenUI(eUIID_FlyingEquipInfo)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipInfo, "updateBagEquipInfo", equip)
	else
	g_i3k_ui_mgr:OpenUI(eUIID_EquipTips)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTips, "updateBagEquipInfo", equip)
	end
end

function widgetBagItem:_onFashionTips(sender, args)
	local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(args.id)
	local fashionID = itemCfg.args1
	local info = g_i3k_db.i3k_db_get_fashion_cfg(fashionID)
	g_i3k_ui_mgr:OpenUI(eUIID_FashionDressTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_FashionDressTips, args.id ,true, info.getPathway, nil, info.sex, false, false)
end
function widgetBagItem:_onMetamorphosisTips(sender, args)
	g_i3k_ui_mgr:OpenUI(eUIID_MetamorphosisDressTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_MetamorphosisDressTips, args.id)
end
