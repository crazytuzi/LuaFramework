local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetDragonTotemTalent = class("QUIWidgetDragonTotemTalent", QUIWidget)
local QActorProp = import("....models.QActorProp")

function QUIWidgetDragonTotemTalent:ctor(options)
	local ccbFile = "ccb/Widget_Weever_talent_client.ccbi"
	local callBacks = {}
	QUIWidgetDragonTotemTalent.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetDragonTotemTalent:setInfo(config, isActivite)
	self._ccbOwner.tf_skill_title:setString(config.dragon_name)
	local props = self:getPropStr(config)
	local propDesc = ""
	for i=1,2 do
		if props[i] ~= nil then
			if propDesc == "" then
				propDesc = props[i]
			else
				propDesc = propDesc.."   "..props[i]
			end
			-- self._ccbOwner["tf_talent_desc"..i]:setString(string.format("%s（武魂之力提升至%d级）", props[i], config.condition))
		-- else
			-- self._ccbOwner["tf_talent_desc"..i]:setString("")
		end
	end
	self._ccbOwner.tf_talent_desc1:setString(propDesc)
	self._ccbOwner.tf_talent_desc2:setString(string.format("（武魂之力提升至%d级）", config.condition))
	if isActivite then
		self._ccbOwner.tf_skill_title:setColor(COLORS.k)
		self._ccbOwner.tf_talent_desc1:setColor(COLORS.j)
		self._ccbOwner.tf_talent_desc2:setColor(COLORS.j)
	else
		self._ccbOwner.tf_skill_title:setColor(COLORS.n)
		self._ccbOwner.tf_talent_desc1:setColor(COLORS.n)
		self._ccbOwner.tf_talent_desc2:setColor(COLORS.n)
	end
end

function QUIWidgetDragonTotemTalent:getPropStr(config)
	local props = {}
	for _,v in ipairs(QActorProp._uiFields) do
		if config[v.fieldName] ~= nil then
			table.insert(props, v)
		end
	end
	local propDesc = {}
	if props ~= nil and #props > 0 then
		for _,prop in ipairs(props) do
			local value = config[prop.fieldName]
			if prop.handlerFun ~= nil then
				value = prop.handlerFun(value)
			end
			table.insert(propDesc, prop.name.."+"..value)
		end
	end
	return propDesc
end

function QUIWidgetDragonTotemTalent:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetDragonTotemTalent