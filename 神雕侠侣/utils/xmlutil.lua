

XMLUtil = {}
XMLUtil.__index = XMLUtil

function XMLUtil.LoadAttrNumber(node, name)
	local ret, nullnode, msg 
	ret, nullnode, msg = node:GetAttribute(name,nullnode)
	if msg == "" then
		return 0
	else
		return tonumber(msg)
	end
end

function XMLUtil.LoadAttrString(node, name)
	local ret, nullnode, msg 
	ret, nullnode, msg = node:GetAttribute(name,nullnode)
	return msg
end

function XMLUtil.LoadAttrBool(node, name)
	local ret, nullnode, msg 
	ret, nullnode, msg = node:GetAttribute(name,nullnode)
	if msg == "true" then
		return true
	else
		return false
	end
end

function XMLUtil.LoadSubnodeNumber(node)
	local msg = node:GetSubText()
	if msg == "" then
		return 0
	else
		return tonumber(msg)
	end
end

function XMLUtil.LoadSubnodeString(node)
	return node:GetSubText()
end

function XMLUtil.LoadSubnodeBool(node)
	local msg = node:GetSubText()
	if msg == "true" then
		return true
	else
		return false
	end
end

function XMLUtil.GetChildNodeByName(node, name)
	for i=0, node:GetChildrenCount()-1 do
		local subnode = XMLIO.CINode()
		rval = node:GetChildAt(i, subnode)

		if rval then 
			if subnode:GetName() == name then
				return subnode
			end
		end
	end
	return nil
end

function XMLUtil.LoadSubnodeVectorNumber(node, name)
	local vectable = {}
	subnode = XMLUtil.GetChildNodeByName(node, name)
	if subnode == nil then return vectable end

	for i=0, subnode:GetChildrenCount()-1 do
		local ssnode = XMLIO.CINode()
		rval = subnode:GetChildAt(i, ssnode)

		if rval then
			vectable[i] = XMLUtil.LoadSubnodeNumber(ssnode)
		end
	end
	return vectable
end

function XMLUtil.LoadSubnodeVectorString(node, name)
	local vectable = {}
	subnode = XMLUtil.GetChildNodeByName(node, name)
	if subnode == nil then return vectable end

	for i=0, subnode:GetChildrenCount()-1 do
		local ssnode = XMLIO.CINode()
		rval = subnode:GetChildAt(i, ssnode)

		if rval then
			vectable[i] = XMLUtil.LoadSubnodeString(ssnode)
		end
	end

	return vectable
end

return XMLUtil
