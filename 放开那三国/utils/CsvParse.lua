-- Filename：	CsvParse.lua
-- Author：		lichenyang
-- Date：		2011-1-8
-- Purpose：		csv 数据解析器


module("CsvParse" , package.seeall)

-- 去掉字符串左空白
local function trim_left(s)
	return string.gsub(s, "^%s+", "");
end


-- 去掉字符串右空白
local function trim_right(s)
	return string.gsub(s, "%s+$", "");
end

-- 解析一行
local function parseline(line)
	local ret = {};

	local s = line .. ",";  -- 添加逗号,保证能得到最后一个字段

	while (s ~= "") do
		--print(0,s);
		local v = "";
		local tl = true;
		local tr = true;

		while(s ~= "" and string.find(s, "^,") == nil) do
			--print(1,s);
			if(string.find(s, "^\"")) then
				local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");
				--print(2,vx,vz);
				if(vx == nil) then
					return nil;  -- 不完整的一行
				end
				-- 引号开头的不去空白
				if(v == "") then
					tl = false;
				end

				v = v..vx;
				s = vz;

				while(string.find(s, "^\"")) do
					local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");
					--print(4,vx,vz);
					if(vx == nil) then
						return nil;
					end
					v = v.."\""..vx;
					s = vz;
					--print(5,v,s);
				end

				tr = true;
			else
				local _,_,vx,vz = string.find(s, "^(.-)([,\"].*)");
				--print(6,vx,vz);
				if(vx~=nil) then
					v = v..vx;
					s = vz;
				else
					v = v..s;
					s = "";
				end
				--print(7,v,s);

				tr = false;
			end
		end

		if(tl) then v = trim_left(v); end
		if(tr) then v = trim_right(v); end

		ret[table.maxn(ret)+1] = v;
		--print(8,"ret["..table.maxn(ret).."]=".."\""..v.."\"");

		if(string.find(s, "^,")) then
			s = string.gsub(s,"^,", "");
		end

	end
	return ret;
end



--[[
	@des	:	解析csv 字符串数据
	@parm	:	csvData csv的字符串
	@ret 	:	数据table
]]
function parse( csvData )
	--把数据按回车键切换成 多行
	local csvSplitTable = string.split(csvData, "\n")
	local resultTable 	= {}

	for k,v in pairs(csvSplitTable) do
		local tempStr = string.gsub(v, string.char(22), string.char(234) .. string.char(22))
		local rowLine = parseline(tempStr)
		
		
		if(rowLine[1] ~= nil or rowLine[1] ~= "") then 
			table.insert(resultTable, rowLine)
		end
	end
	return resultTable
end



















