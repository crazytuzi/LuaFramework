function KPlayer.CallClientScript(szFunc, ...)
	if type(szFunc) == "number" then
		local szFuncMaped = s2c.id2func[szFunc];
		if not szFuncMaped then
			Log("[Error] CallClientScript cant mapping id to function", tostring(szFunc));
		end
		szFunc = szFuncMaped;
	end

	local bOK = false;
	if string.find(szFunc, ":") then
		local szTable, szFunc = string.match(szFunc, "^(.*):(.*)$");
		local tb = loadstring("return " .. szTable)();
		if tb and szFunc and tb[szFunc] then
			tb[szFunc](tb, ...);
			bOK = true;
		end
	else
		local func = loadstring("return " .. szFunc)();
		if func then
			func(...);
			bOK = true;
		end
	end

	if not bOK then
		Log("[Error] CallClientScript fail !!", szFunc, ...);
	end
end

function KPlayer.GetMapPlayer(nMapId)
	if me.nMapId == nMapId then
		return { me }, 1;
	end
end

function KPlayer.GetPlayerObjById(nId)
	if nId == me.dwID then
		return me;
	end
end
