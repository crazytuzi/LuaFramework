module(..., package.seeall)

local require = require;

require("i3k_global");

local function format_value(value)
	return string.gsub("" .. value, "^%s*(.-)%s*$", "%1");
end

------------------------------------------------------
i3k_xml_node = i3k_class("i3k_xml_node");
function i3k_xml_node:ctor(name)
	self._value		= nil;
	self._name		= name;
	self._children	= { };
	self._props		= { };
end

function i3k_xml_node:GetValue()
	return self._value;
end

function i3k_xml_node:SetValue(val)
	self._value = val;
end

function i3k_xml_node:GetName()
	return self._name;
end

function i3k_xml_node:SetName(name)
	self._name = name;
end

function i3k_xml_node:GetChildren()
	return self._children;
end

function i3k_xml_node:GetChildrenNum()
	return #self._children;
end

function i3k_xml_node:AddChild(child)
	if self[child:GetName()] == nil then
		self[child:GetName()] = child;
	else
		if self[child:GetName()][1] == nil then
			local ch = self[child:GetName()];

			self[child:GetName()] = { };

			table.insert(self[child:GetName()], ch);
		end
		table.insert(self[child:GetName()], child);
	end

	table.insert(self._children, child);
end

function i3k_xml_node:GetProperties()
	return self._props;
end

function i3k_xml_node:GetPropNum()
	return #self._props;
end

function i3k_xml_node:AddProperty(name, value)
	local _name = "@" .. name
	if self[_name] then
		return false;
	end

	self[_name] = value;

	table.insert(self._props, { name = name, value = value });

	return true;
end

function i3k_xml_node:Save(stream, layer)
	local perfix1 = "";
	for k = 2, layer do
		perfix1 = perfix1 .. "\t";
	end
	local perfix2 = perfix1 .. "\t";

	stream.data = stream.data .. perfix1 .. "<" .. self._name;

	for k, v in ipairs(self._props) do
		stream.data = stream.data .. " " .. v.name .. "='" .. v.value .. "'";
	end
	stream.data = stream.data .. ">\n";

	if self._value then
		stream.data = stream.data .. perfix2 .. format_value(self._value) .. "\n";
	end

	for k, v in ipairs(self._children) do
		v:Save(stream, layer + 1);
	end

	stream.data = stream.data .. perfix1 .. "</" .. self._name .. ">\n";
end

------------------------------------------------------
i3k_xml_parser = i3k_class("i3k_xml_parser");
function i3k_xml_parser:ctor()
end

function i3k_xml_parser:ToXmlString(value)
	local _value = string.gsub(value, "&", "&amp;");
	_value = string.gsub(_value, "<", "&lt;");
	_value = string.gsub(_value, ">", "&gt;");
	_value = string.gsub(_value, "\"", "&quot;");
	_value = string.gsub(_value, "([^%w%&%;%p%\t% ])", function(c) return string.format("&#x%X;", string.byte(c)); end);

	return _value;
end

function i3k_xml_parser:FromXmlString(value)
	local _value = string.gsub(value, "&#x([%x]+)%;", function(h) return string.char(tonumber(h, 16)); end);
	_value = string.gsub(value, "&#([0-9]+)%;", function(h) return string.char(tonumber(h, 10)); end);
	_value = string.gsub(value, "&quot;", "\"");
	_value = string.gsub(value, "&apos;", "'");
	_value = string.gsub(value, "&gt;", ">");
	_value = string.gsub(value, "&lt;", "<");
	_value = string.gsub(value, "&amp;", "&");

	return _value;
end

function i3k_xml_parser:ParseArgs(node, s)
	string.gsub(s, "(%w+)=([\"'])(.-)%2", function(w, _, a) node:AddProperty(w, self:FromXmlString(a)); end);
end

function i3k_xml_parser:ParseXmlText(str)
	local top = nil;

	local stack	= { };

	local ni, c, label, xarg, empty;
	local i, j = 1, 1;
	while true do
		ni, j, c, label, xarg, empty = string.find(str, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
		if not ni then
			break;
		end

		local text = string.sub(str, i, ni - 1);
		if not string.find(text, "^%s*$") then
			if top then
				local _val = (top:GetValue() or "") .. self:FromXmlString(text);

				stack[#stack]:SetValue(format_value(_val));
			end
		end

		if empty == "/" then
			local _node = i3k_xml_node.new(label);
				self:ParseArgs(_node, xarg);

			if top then
				top:AddChild(_node);
			else
				top = _node;
			end
		elseif c == "" then
			local _node = i3k_xml_node.new(label);
				self:ParseArgs(_node, xarg);
			table.insert(stack, _node);

			top = _node
		else
			local toclose = table.remove(stack);
			if toclose:GetName() ~= label then
				i3k_log("i3k_xml_parser:ParseXmlText trying to close " .. toclose:GetName() .. " with " .. label);
			end

			top = stack[#stack];
			if top then
				top:AddChild(toclose);
			else
				top = toclose;
			end
		end

		i = j + 1;
	end

	local text = string.sub(str, i);
	if #stack > 1 then
		i3k_log("i3k_xml_parser:ParseXmlText unclosed " .. stack[#stack]:GetName());
	end

	return top;
end

function i3k_xml_parser:Load(xml)
	local fn = i3k_game_get_exe_path() .. xml;

	local f = io.open(fn, "r");
	if f == nil then
		return nil;
	end

	local t = f:read("*all");
	if t ~= nil then
		return self:ParseXmlText(t);
	end

	return nil;
end

function i3k_xml_parser:Save(root, xml)
	local fn = i3k_game_get_exe_path() .. xml;

	local f = io.open(fn, "w");
	if f == nil then
		return false;
	end

	local stream = { data = "<?xml version='1.0' encoding='UTF-8'?>\n" };
	if root then
		root:Save(stream, 1);
	end

	f:write(stream.data);

	f:close();

	return true;
end

