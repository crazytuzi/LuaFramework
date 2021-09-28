-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_danyao_tips = i3k_class("wnd_danyao_tips", ui.wnd_base)

--套装强化tips优化颜色 title,属性名,属性值 
--达标 
local finish = {'ffffcb40','ff0d1c15','ff80ffc2'}
--未达标
local notFinish = {'ff9a9a9a','ff141414','ffc3c3c3'}

local PROP_T = "ui/widgets/dyjct1"
local ITEM_T = "ui/widgets/dyjct2"
local GROUP_T = "ui/widgets/dyjct3"

local property = {[1] = 1,[2] = 2,[3] = 3}
local YLLevel = {"一阶","二阶", "三阶"}
local YLName = {[1] = "元力", [2] = "固守" ,[3] = "强体"}

function wnd_danyao_tips:ctor()
	self.attribute = {}
	self.attributeValue = {}
	self.attributeBg = {}
end

function wnd_danyao_tips:configure()
	local widgets = self._layout.vars
	self.title = widgets.title
	self.awardValue = widgets.awardValue
	widgets.power:setText("战力:" .. g_i3k_game_context:GetRolePower())
	widgets.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(g_i3k_game_context:GetRoleHeadIconId()))
	widgets.iconBg:setImage(g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId()))
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.content = widgets.content
	self.prop_content = widgets.prop_content
	self.curGroup = 1 --当前打开的分组
	self:initInfo()
end

function wnd_danyao_tips:initInfo()
	local temp, useCount = g_i3k_game_context:getOneTimesItemLvlForId()
	local typeToTab = {} --丹药类型 对应页签
	self.idToCfg = {}-- key :id  value：medicine_cfg
	for i, v in ipairs(i3k_db_medicine_cfg) do
		for i2, v2 in ipairs(v.items) do
			self.idToCfg[v2.id] = v2
			if not typeToTab[v2.type] then
				typeToTab[v2.type] = i
			end
		end
	end
	self.temp = {}
	self.useCount = useCount
	for i, v in ipairs(temp) do
		if not self.temp[typeToTab[i]] then
			self.temp[typeToTab[i]] = {}
		end
		table.insert(self.temp[typeToTab[i]], v)
	end
end


function wnd_danyao_tips:refresh(groupID)
	self.content:removeAllChildren()
	local temp, useCount = g_i3k_game_context:getOneTimesItemLvlForId()
	if groupID then
		self.curGroup = groupID == self.curGroup and 0 or groupID
	else
		self:setProperty()--第一次打开刷新
	end
	for i, v in ipairs(i3k_db_medicine_cfg) do
		local GROUP = require(GROUP_T)()
		GROUP.vars.btn:onClick(self, self.onGroupClick, i)
		GROUP.vars.groupName:setText(v.name)
		GROUP.vars.down:setVisible(i == self.curGroup)
		GROUP.vars.right:setVisible(i ~= self.curGroup)
		self.content:addItem(GROUP)
		if i == self.curGroup then
			self:setDanYao(i)
		end
	end
	self.content:jumpToChildWithIndex(self.curGroup)
end

function wnd_danyao_tips:onGroupClick(sender, groupID)
	self:refresh(groupID)
end

function wnd_danyao_tips:propTxtFormat(propId, value)
	if propId == 0 then return '' end
	return i3k_db_prop_id[propId].txtFormat == 1 and string.format(value - math.floor(value) > 0 and "%.2f" or "%d", value)..'%' or value
end

function wnd_danyao_tips:setDanYao(groupID)--原来丹药 分组1
	local data = g_i3k_game_context:getOneTimesItemData()
	local temp, useCount = self.temp[groupID],self.useCount
	local typeCfgs = {}
	for i0, v0 in ipairs(i3k_db_medicine_cfg) do
		for i, v in ipairs(v0.items) do
			typeCfgs[v.id] = v.type
		end
	end
	for k,v in pairs(temp) do
		local ITEM = require(ITEM_T)()
		if not v.lvlIsFull then
			ITEM.vars.loadingbar:setPercent(useCount[typeCfgs[v.item.id]]/v.item.useCount*100)
			if groupID == 1 then
				ITEM.vars.name:setText(YLName[typeCfgs[v.item.id]] .. "：" ..  YLLevel[v.item.args5])
			end
			ITEM.vars.text:setText(useCount[typeCfgs[v.item.id]] .. "/" ..v.item.useCount)
		else
			ITEM.vars.loadingbar:setPercent(100)
			if groupID == 1 then
				ITEM.vars.name:setText(YLName[k] .. "：满阶")
			end
			ITEM.vars.text:setText(v.item.useCount .. "/" ..v.item.useCount)
		end
		if groupID ~= 1 then
			ITEM.vars.name:setText(self.idToCfg[v.item.id].name)
		end
		ITEM.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.item.id))
		ITEM.vars.itemBg:onClick(self, self.clickItem, v.item.id)
		ITEM.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.item.id,i3k_game_context:IsFemaleRole()))
		self.content:addItem(ITEM)
	end
end

function wnd_danyao_tips:setProperty()
	self.prop_content:removeAllChildren()
	local counts = g_i3k_game_context.oneIimeItemsAllCount
	local allDanYao = {}
	for i, v in ipairs(i3k_db_medicine_cfg) do
		for i2, v2 in ipairs(v.items) do
			table.insert(allDanYao, v2.id)
		end
	end
	local props = {}
	local addProp =	function(id, value)
		if not props[id] then props[id] = 0 end
		props[id] = props[id] + value
	end
	for k, v in ipairs(allDanYao) do
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(v)
		if cfg.args1 ~= 0 then
			addProp(cfg.args1, cfg.args2 * (counts[v] or 0))
		end
		if cfg.args3 ~= 0 then
			addProp(cfg.args3, cfg.args4 * (counts[v] or 0))
		end
	end
	for k, v in pairs(props) do
		local PROP = require(PROP_T)()
		local prop = i3k_db_prop_id[k] 
		PROP.vars.name:setText(prop.desc)
		PROP.vars.value:setText('+'..self:propTxtFormat(k,v))
		PROP.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(prop.icon))
		self.prop_content:addItem(PROP)
	end
end

function wnd_danyao_tips:clickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_danyao_tips.new()
		wnd:create(layout)
	return wnd
end

