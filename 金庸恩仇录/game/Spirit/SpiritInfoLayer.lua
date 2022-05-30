local data_jingyuantype_jingyuantype = require("data.data_jingyuantype_jingyuantype")
local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")

local SpiritInfoLayer = class("SpiritInfoLayer", function ()
	return require("utility.ShadeLayer").new()
end)

function SpiritInfoLayer:ctor(optType, data, listener, closeListener)
	dump(data)
	local sz = cc.size(615, 425)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("spirit/spirit_desc.ccbi", proxy, rootnode, self, sz)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.titleLabel:setString(common:getLanguageString("@zhenqixx"))
	rootnode.nameLabel:setString(data_item_item[data.resId].name)
	local star = data_item_item[data.resId].quality
	rootnode.nameLabel:setColor(QUALITY_COLOR[star])
	rootnode.spiritTypeLabel:setString(data_jingyuantype_jingyuantype[data_item_item[data.resId].pos].name)
	alignNodesOneByOne(rootnode.label_1, rootnode.spiritTypeLabel, 4)
	rootnode.spiritLevelLabel:setString(tostring(data.level or 0))
	alignNodesOneByOne(rootnode.label_2, rootnode.spiritLevelLabel, 4)
	for i = 1, star do
		rootnode[string.format("star_%d_%d", star % 2, i)]:setVisible(true)
	end
	local icon = require("game.Spirit.SpiritIcon").new({
	id = data._id,
	resId = data.resId,
	lv = data.level or 0,
	exp = data.curExp or 0,
	bShowName = false,
	bShowLv = false
	})
	
	icon:align(display.CENTER, rootnode.iconSprite:getContentSize().width / 2, rootnode.iconSprite:getContentSize().height / 2)
	rootnode.iconSprite:addChild(icon)
	
	local arr_nature = data_item_item[data.resId].arr_nature
	if arr_nature then
		if data.props == nil then
			data.props = {}
			for k, v in ipairs(arr_nature) do
				table.insert(data.props, {
				idx = v,
				val = data_item_item[data.resId].arr_value[k]
				})
			end
		end
		for k, v in ipairs(data.props) do
			local l = string.format("propNameLabel_%d", k)
			local nature = data_item_nature[v.idx]
			rootnode[l]:setString(nature.nature .. "：")
			rootnode[l]:setVisible(true)
			local str = ""
			if nature.type == 1 then
				str = str .. string.format("+%d", v.val)
			else
				str = str .. string.format("+%d%%", v.val / 100)
			end
			local valueLabel = ui.newTTFLabel({
			text = tostring(str),
			size = 28,
			font = FONTS_NAME.font_haibao,
			color = cc.c3b(223, 192, 132)
			})
			ResMgr.replaceKeyLable(valueLabel, rootnode[l], rootnode[l]:getContentSize().width, 0 )
			valueLabel:align(display.LEFT_CENTER)
		end
	else
		
		local l = string.format("propNameLabel_%d", 1)
		rootnode[l]:setString(common:getLanguageString("@zengjiajy"))
		rootnode[l]:setVisible(true)
		
		local valueLabel = ui.newTTFLabel({
		text = tostring(data_item_item[data.resId].price),
		size = 28,
		font = FONTS_NAME.font_haibao,
		color = cc.c3b(223, 192, 132)
		})
		ResMgr.replaceKeyLable(valueLabel, rootnode[l], rootnode[l]:getContentSize().width, 0 )
		valueLabel:align(display.LEFT_CENTER)
	end
	
	local function close(sender, eventName)
		self:removeSelf()
		if optType == 1 then
			listener()
		end
	end
	
	local function upgrade(sender, eventName)
		self:removeSelf()
		if optType == 1 then
			local ctrl = require("game.Spirit.SpiritCtrl")
			local idx = ctrl.getIndexByID(data._id)
			if idx > 0 then
				listener(true)
				ctrl.pushUpgradeScene(idx)
			end
		else
			if optType == 2 then
				if data_item_item[data.resId].arr_nature then
					listener()
				else
					show_tip_label(common:getLanguageString("@zhenqibksj"))
				end
			else
			end
		end
	end
	
	--返回X按钮
	rootnode.tag_close:addHandleOfControlEvent(function ()
		if closeListener then
			closeListener()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	if optType == 1 then
		common:reSetButtonState(rootnode.returnBtn, common:getLanguageString("@genghuan"))
	elseif optType == 2 then
		common:reSetButtonState(rootnode.returnBtn, common:getLanguageString("@guanbi"))
	elseif optType == 3 then
		rootnode.changeBtn:setEnabled(false)
	elseif optType == 4 then
		rootnode.returnBtn:setPositionX(sz.width / 2)
		rootnode.changeBtn:setVisible(false)
	end
	
	--关闭  亲  测 源 码 网  w w w. q  c y  m w .c o m
	rootnode.returnBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	
	--升级
	rootnode.changeBtn:addHandleOfControlEvent(upgrade, CCControlEventTouchUpInside)
	
end

return SpiritInfoLayer