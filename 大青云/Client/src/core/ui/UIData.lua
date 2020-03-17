--[[
UI数据编解码
lizhuangzhuang
2014年10月13日10:24:13
]]

_G.classlist['UIData'] = 'UIData'
_G.UIData = {};
_G.UIData.objName = 'UIData'
--编码
--@param data 字段中不可有 #
--@return 返回编码后的字符串
function UIData.encode(data)
	local keyStr = "";
	local dataStr = "";
	local len = 0;
	for k,v in pairs(data) do
		len = len + 1;
	end
	if len == 0 then
		return "";
	end
	--
	local index = 0;
	for k,v in pairs(data) do
		index = index + 1;
		local vtype = type(v);
		if vtype=="number" or vtype=="string" or vtype=="boolean" then
			keyStr = keyStr .. k .."#".. vtype;
			if vtype == "boolean" then
				dataStr = dataStr .. (v and 1 or 0);
			else
				dataStr = dataStr .. v;
			end
			if index < len then
				keyStr = keyStr .. "#";
				dataStr = dataStr .. "##";
			end
		end
	end
	dataStr = keyStr .."##".. dataStr;
	return dataStr;
end

--解码
function UIData.decode(str)
	if not str then return {}; end
	if str=="" then return {}; end
	local dataArr = split(str,"##");
	if #dataArr < 2 then return {}; end
	local keyStr = table.remove(dataArr,1);
	local keyArr = split(keyStr,"#");
	--
	local data = {};
	for i=1,#dataArr do
		local key = keyArr[i*2-1];
		local vtype = keyArr[i*2];
		local v = dataArr[i];
		if vtype == "number" then
			data[key] = tonumber(v);
		elseif vtype == "boolean" then
			data[key] = v=="1" and true or false;
		else
			data[key] = v;
		end
	end
	return data;
end

--copy数据到UI Tree
function UIData.copyDataToTree(treeData, treeNodeVO, encodeFunc)
	if not encodeFunc then
		encodeFunc = UIData.encode
	end
	local copyFunc;
	copyFunc = function(data,vo)
		local uiDataStr = encodeFunc(data);
		vo:setData(uiDataStr);
		while data.nodes and #data.nodes>0 do
			local nodeData = table.remove(data.nodes,1);
			local nodeVO = vo:addNode();
			copyFunc(nodeData,nodeVO);
		end
		return;
	end
	copyFunc(treeData,treeNodeVO);
end

--clean Tree中的数据
function UIData.cleanTreeData(treeNodeVO)
	local recyleFunc;
	recyleFunc = function(vo)
		local nodesNum = vo.nodesNum;
		for i=1,nodesNum,1 do
			local nodeVO = vo:getNodeAt(i-1);
			recyleFunc(nodeVO);
		end
		vo:recyleNodes();
	end
	recyleFunc(treeNodeVO);
end