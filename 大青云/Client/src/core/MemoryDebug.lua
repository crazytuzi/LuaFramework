_G.classlist['CMemoryDebug'] = 'CMemoryDebug'
_G.CMemoryDebug = {}
_G.CMemoryDebug.objName = 'CMemoryDebug'
CMemoryDebug.setObjectInfo = {};
CMemoryDebug.dwCollectgarTime = 1000
CMemoryDebug.dwDumpTime = 1000
CMemoryDebug.inited = false
function CMemoryDebug:Create() 
	--CControlBase:RegControl( self, true )
	--self:OnKeyDown(_System.KeyHome)
	self.inited = true;
	return true;
end;

-- local ks, rs = debug.logrefs()
-- local objs = {}
-- local records = {}
function CMemoryDebug:OnKeyDown( dwKeyCode )
	do return end
	if not _G.isDebug then return end
	if dwKeyCode == _System.KeyHome then
		--print('###############MemoryCount_Init###############')
		--self:MemoryCount_Init()
		self.bInit = true
		--_debug:logAlloc(1) --设置lua内存申请监控。
	end
	if dwKeyCode == _System.KeyEnd then
		if not self.bInit then return end
		--print('###############MemoryCount_Width###############')
		--local t = self:MemoryCount_Width()
		--self:MemoryPrint(t,'memorycount_width')
		--_debug:logAlloc(0)   --关闭内存申请监控
	end
	if dwKeyCode == _System.KeyDel then
		local f = _File.new()
		f:create(GetCurTime() .. '.txt','w')
		--f:write('####_G.classlist \n')
		for _, objName in pairs(_G.classlist) do
			objs[objName] = 0
			--f:write('#' .. objName .. '\n')
			local record = {}
			record.name = objName
			record.count = 0
			table.insert(records, record)
		end
		
		local ks2, rs2 = debug.logrefs()
		f:write('####object reference\n')
		for o, k in pairs(ks2) do
			--if type(o) == 'table' and o.typeid == _Mesh.typeid and ks[o] == nil then
			--	Debug(o.resname, o, k, ks2[rs2[o]])
			--end
			for _, record in pairs(records) do
				if type(o) == 'table' and o.objName == record.name and ks[o] == nil then
					--f:write('#' .. o.objName ..' '..' '.. tostring(o) ..' '..' '..tostring(k)..' '..' '..tostring(ks2[rs2[o]]) .. '\n')
					record.count = record.count + 1
				end
			end
		end
		table.sort(records, function(a, b) 
			return a.count > b.count
		end)
		
		for i, record in pairs(records) do
		
			f:write('#' .. i .. ' ' ..record.name .. ' ' .. record.count ..'\n')
		end
		f:close()
	end
	if dwKeyCode == _System.Key0 then
		_sys.messageUI = not _sys.messageUI;
	end
	if dwKeyCode == _System.Key0 + 9 then
		_sys.showUI = not _sys.showUI;
	end
end



function CMemoryDebug:Update(dwInterval)

	--if not self.inited then return end;
	--if GetCurTime() - self.dwDumpTime >= 1000 * 60 * 1 then
	--	self.dwDumpTime = GetCurTime();
		--_debug:dump()
		--_debug:dumpDiff()
		--_debug:record()
	--end

	if  GetCurTime() - self.dwCollectgarTime >= 1000 * 100 then
		--collectgarbage("collect");
		LuaGC()
		-- for i,objectInfo in pairs(self.setObjectInfo) do
		-- 	if objectInfo[1] then
		-- 		local dwCount = 0;
		-- 		for v in pairs(objectInfo[2]) do
		-- 			dwCount = dwCount + 1;
		-- 			--local dwRoleID = v:GetRoleID()
		-- 		end;
		-- 		print("@@@@@@@@@@@@@obj:("..i..")Count:",dwCount);
		-- 		-- for v in pairs(objectInfo[2]) do
		-- 		-- print(self:MemoryTrace(v))
		-- 		-- break
		-- 		-- end
		-- 	end;
		-- end;
		
		self.dwCollectgarTime = GetCurTime();
	end;
end;

function CMemoryDebug:Destroy()
	
end;

function CMemoryDebug:AddObject(szObjName,obj)
	do return end
	if not self.setObjectInfo[szObjName] then
		local sInfo = {false,{}} 
		setmetatable(sInfo[2],{__mode="k"});
		self.setObjectInfo[szObjName] = sInfo;
	end; 
	self.setObjectInfo[szObjName][2][obj] = GetCurTime();
end;

function CMemoryDebug:Show(szObjName,bIsShow)
	local bIsShow = bIsShow or true;
	if not self.setObjectInfo[szObjName] then
		local sInfo = {false,{}} 
		setmetatable(sInfo[2],{__mode="k"});
		self.setObjectInfo[szObjName] = sInfo;
	end;
	self.setObjectInfo[szObjName][1] = bIsShow;
end;


---------------------------------------------------------------------------------
function CMemoryDebug:MemoryTrace(o)
	self.MemoryTraceList = {}
	setmetatable(CMemoryDebug.MemoryTraceList,{ __mode = 'k' })
	return self:_MemoryTrace(_G,o)
end

function CMemoryDebug:_MemoryTrace(t,o)
	if t == self then return end
	if self.MemoryTraceList[t] then return end
	self.MemoryTraceList[t] = true
	
	local b
	for k,v in pairs(t) do
		if v == o then
			b = k
			break
		end
	end
	if b then
		return 'MemoryTrace # '..tostring(o)..' == '..tostring(b)
	else
		for k,v in pairs(t) do
			if type(v) == 'table' then
				local s = self:_MemoryTrace(v,o)
				if s then
					if t.toString then
						return s..' << '..tostring(k).."("..t:toString()..")"
					else
						return s..' << '..tostring(k)
					end
				end
			end
		end
	end
end
---------------------------------------------------------------------------------
CMemoryDebug.tabPrintFileCount = {}
function CMemoryDebug:MemoryPrint(t,s)
	local d = self.tabPrintFileCount[s] or 0
	d = d + 1
	self.tabPrintFileCount[s] = d
	
	local tabOrder = {}
	for k,v in pairs(t) do
		local temp = {}
		temp.o = k
		temp.d = v
		table.insert(tabOrder,temp)
	end
	table.sort(tabOrder,function(a,b) return a.d > b.d end)
	
	local f = _File.new()
	f:create(s..'_'..d..'.lua','w')
	local i,n = 1,1;
	while(n <= 50) do
		local v = tabOrder[i];
		i = i + 1;
		if (not v) or v.d == 0 then break end;
		--if (not v.o.UpdateRotByRender) and (not v.o.MNLook) and (not v.o.Npc) and (not v.o.dwMonsterId) then
			local s = self:MemoryTrace(v.o)
			if s then
				f:write('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')
				f:write(tostring(v.o)..'\t'..tostring(v.d)..' \n')
				f:write(s..' \n')
				for key,value in pairs(v.o) do
					f:write('\t'..tostring(key)..'\t'..tostring(value)..' \n')
				end
			end
			n = n + 1;
		--end
	end
	f:close()
end
---------------------------------------------------------------------------------
function CMemoryDebug:MemoryCount_Init()
	self:MemoryCount_Width()
end
---------------------------------------------------------------------------------
CMemoryDebug.MemoryCountInfo_Width = {}
setmetatable(CMemoryDebug.MemoryCountInfo_Width,{ __mode = 'k' })

function CMemoryDebug:MemoryCount_Width()
	self.MemoryCountList_Width = {}
	setmetatable(self.MemoryCountList_Width,{ __mode = 'k' })
	self.MemoryCountInterval_Width = {}
	setmetatable(self.MemoryCountInterval_Width,{ __mode = 'k' })
	
	self:_MemoryCount_Width(_G)
	return self.MemoryCountInterval_Width
end

function CMemoryDebug:_MemoryCount_Width(t)
	if t == self then return end
	if self.MemoryCountList_Width[t] then return end
	self.MemoryCountList_Width[t] = true
	
	local dwCount = 0
	for k,v in pairs(t) do
		dwCount = dwCount + 1
		if type(v) == 'table' then
			self:_MemoryCount_Width(v)
		end
	end
	local _dwCount = self.MemoryCountInfo_Width[t] or 0
	self.MemoryCountInterval_Width[t] = dwCount - _dwCount
	self.MemoryCountInfo_Width[t] = dwCount
end
---------------------------------------------------------------------------------
CMemoryDebug.MemoryCountInfo_Deep = {}
setmetatable(CMemoryDebug.MemoryCountInfo_Deep,{ __mode = 'k' })

function CMemoryDebug:MemoryCount_Deep()
	self:_MemoryCount_Deep(_G,1)
	return self.MemoryCountInfo_Deep
end

function CMemoryDebug:_MemoryCount_Deep(t,d)
	if t == self then return end
	local _d = self.MemoryCountInfo_Deep[t]
	if (not _d) or (d < _d) then
		self.MemoryCountInfo_Deep[t] = d
	else
		return
	end
	
	for k,v in pairs(t) do
		if type(v) == 'table' then
			self:_MemoryCount_Deep(v,d+1)
		end
	end
end
