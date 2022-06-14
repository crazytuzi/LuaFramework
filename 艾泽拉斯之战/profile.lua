Counters = {};
Names = {};
function hook()
	local f = debug.getinfo(2, "f").func;
	if Counters[f] == nil then
		Counters[f] = 1;
		Names[f] = debug.getinfo(2, "Sn");
	else
		Counters[f] = Counters[f] + 1;
	end
end

function getname(func)
	local n = Names[func];
	if n.what == "C" then
		if n.name == nil then
			return "C function name: null";
		else
			return "C function name: "..n.name;
		end
	end
	
	local lc = string.format("source lua file: %s, line:%s", n.short_src, n.linedefined);
	if n.namewhat ~= "" then
		return string.format("%s, function name: %s", lc, n.name);
	else
		return lc;
	end
end

function isInResult(func, result)
	for k, v in ipairs(result) do
		if v.func == func then
			return true;
		end
	end
	
	return false;
end
	
function printProfileResult()
	
	print("printProfileResult");
	
	local sortResult = {};
	for func, count in pairs(Counters) do
		if isInResult(func, sortResult) == false then
			local maxFunc = func;
			local maxCount = count;
			for k, v in pairs(Counters) do
				if v > maxCount and isInResult(k, sortResult) == false then
					maxFunc = k;
					maxCount = v;
				end
			end
			
			table.insert(sortResult, {func = maxFunc, count = maxCount});
		end
	end
	
	for k, v in ipairs(sortResult) do
		if getname(v.func) and v.count then
			print("name: "..getname(v.func).." count: "..v.count);
		end
	end
	
end
