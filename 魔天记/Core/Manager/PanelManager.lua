require "Core.Module.Common.Panel";

PanelManager = {};
PanelManager.BASE_DEPTH = 5;-- NGUI
PanelManager.EACH_POPUP_DEPTH = 5;-- NGUI
PanelManager.RETURNTOMAINPANEL = "RETURNTOMAINPANEL"
PanelManager.UIOVERMAINPANEL = "UIOVERMAINPANEL"
PanelManager.isOverMainUI = false;      -- 当前主界面是否被覆盖
PanelManager.MainUIShow = false;        -- 是否显示主界面

local _panels = {};-- not include fix depth panel
local _allPanels = {};-- include fix depth panel
local _moduleAtlasPath = {};
local _moduleAtlas = {};
local cacheStack = {};
--panel depth规范,弹出警告50/101,loading101,错误日志250, 提审闪屏300

function PanelManager.GetPanels()
	return _panels;
end

function PanelManager.GetAllPanels()
	return _allPanels;
end

-- NGUI计算当前Panel的最高可用层级
function PanelManager.GetMaxDepth()
	local depth = PanelManager.BASE_DEPTH + table.getn(_panels) * PanelManager.EACH_POPUP_DEPTH;
 
	for i, v in ipairs(_panels) do
		if(v.depth > depth) then
			depth = v.depth
		end
	end
 
	
	return depth + PanelManager.BASE_DEPTH;
end
local insert = table.insert

function PanelManager.AddPanel(panel)
	if not panel:IsFixDepth() then
		insert(_panels, panel);
	end
	insert(_allPanels, panel);
end

function PanelManager.RemovePanel(panel)
	if not panel:IsFixDepth() then
		for i, v in ipairs(_panels) do
			if(panel == v) then
				table.remove(_panels, i);
				break;
			end
		end
	end
	
	for i, v in ipairs(_allPanels) do
		if(panel == v) then
			table.remove(_allPanels, i);
			break;
		end
	end
	
	local item = nil;
	
	for i, cache in ipairs(cacheStack) do
		if #cache > 0 then
			for n = #cache, 1, - 1 do
				item = cache[n];
				if item.panel == panel then
					table.remove(cache, n);
				end
			end
		end
	end
	
	if #cacheStack > 0 then
		for i = #cacheStack, 1, - 1 do
			if #cacheStack[i] <= 0 then
				table.remove(cacheStack, i);
			end
		end
	end
	
	--Warning("remove->" .. panel._name)
	local overNum = PanelManager.GetOverCount();
	if(overNum <= 1) then
		if panel.__cname == "MainUIPanel" then
			PanelManager.isOverMainUI = true;
		else
			if(_panels[1] and _panels[1].__cname == "MainUIPanel") then
				PanelManager.OnMainUIFocus();
			end
		end
	end
end

function PanelManager.RemoveAllPanel()
	-- Panel删除后会回调移除_allPanels里面的元素
	-- 所以采用倒序刪除
	local count = table.getCount(_allPanels)
	
	for i = count, 1, - 1 do
		if(_allPanels[i].closeNote) then
			ModuleManager.SendNotification(_allPanels[i].closeNote)
		end
	end
	
	
	--    for i, v in ipairs(_allPanels) do
	--        log(v.__cname)
	--        log(v.closeNote)
	--        if (v.__cname ~= "MainUIPanel") then
	--            if (v.closeNote) then
	--                log("_allPanels" .. table.getCount(_allPanels))
	--                ModuleManager.SendNotification(v.closeNote)
	--            end
	--        end
	--    end
end

function PanelManager.Test()
	print("======================")
	collectgarbage("collect");
	Util.ClearMemory()
	for k, v in pairs(PanelManager.tempClass) do
		if not table.contains(PanelManager.tempIngore, v) then
			--print(k,v)
			print(v);
		end
	end
	print("======================")
end

PanelManager.tempIngore = {"MainUI/UI_MainUIPanel", "UI_MessagePanel", "UI_DialogPanel"};
PanelManager.tempClass = setmetatable({}, {__mode = "k"})

-- 构造面板,1path资源路径,2panel脚本,3useMask是否加上下遮罩,4closeNote关闭消息,isDramaIU
function PanelManager.BuildPanel(path, panel, useMask, closeNote, isDramaUI)
	PanelManager._BuildPanelPre(path)
	
	useMask = useMask or false
	isDramaUI = isDramaUI or false
	-- logTrace(id .. tostring(panel ))
	local nobj = panel:New();
	nobj.closeNote = closeNote
	local luaPanel = UIUtil.GetUI(path);
	PanelManager.tempClass[nobj] = path --panel.__cname
	
	nobj:Init(luaPanel, useMask);
	_moduleAtlasPath[nobj] = path
	-- Warning(path .. "______" .. tostring(_moduleAtlasPath[panel]))
	if not isDramaUI and(DramaDirector and DramaDirector.IsRunning()) then
		-- 剧情过程不显示其他UI
		PanelManager.InsertToCache(nobj);
		return nobj;
	end
	
	PanelManager.ResetOverNum();
	
	return nobj;
end

function PanelManager.ResetOverNum()
	local overNum = PanelManager.GetOverCount();
	if(overNum > 1) then
		PanelManager.OnMainUIOver();
	end
end

-- 计算panel覆盖数量.
function PanelManager.GetOverCount()
	local num = 0;
	for i, v in ipairs(_allPanels) do
		if v:IsOverMainUI() then
			num = num + 1;
		end
	end
	return num;
end

-- 回收面板,1panel脚本,2path资源路径
function PanelManager.RecyclePanel(panel, path)
	local name = panel._name;
	UIUtil.RecycleUI(panel:GetGameObject());
	PanelManager.RecyclePanelLater(panel)
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEED, name);
end
-- 构造面板前
function PanelManager._BuildPanelPre(path)
	local mainAtals = PanelManager.GetMainAtlasName(path)
	-- Warning(tostring(path) .. "______" .. tostring(mainAtals))
	if not mainAtals then return end
	if not GameConfig.instance.useLocalAssets and not _moduleAtlas[path] then
		_moduleAtlas[path] = UIUtil.GetUIGameObject(mainAtals)
	end
end
-- 返回主纹理集名
function PanelManager.GetMainAtlasName(path)
	-- Warning(path .. "______" .. tostring(string.find(path, "/")))
	if not string.find(path, "/") then return nil end
	local modelName = string.split(path, "/") [1]
	-- =模块文件夹名=模块名
	return "ModuleAtlas/MTJ_" .. modelName .. "_Atlas"
end
-- 构造面板前
function PanelManager.RecyclePanelLater(panel)
	-- Warning(tostring(panel) .. "______" .. tostring(_moduleAtlasPath[panel]))
	local path = _moduleAtlasPath[panel]
	if not path then return end
	if _moduleAtlas[path] then
		Resourcer.Recycle(_moduleAtlas[path], false)
		_moduleAtlas[path] = nil
	end
	_moduleAtlasPath[panel] = nil
	local mainAtals = PanelManager.GetMainAtlasName(path)
	if not mainAtals then return end
	Resourcer.Recycle(mainAtals)
end




-- 隐藏所有面板 默认不包括主界面
function PanelManager.HideAllPanels(includeMain)
	-- log("-----------PanelManager.HideAllPanels-----------")
	local cache = {};
	local name = nil;
	for i, v in ipairs(_allPanels) do
		name = v._name;
		-- name = string.gsub(v._name, "%(Clone%)", "");
		local go = v:GetGameObject();
		if go.activeSelf then
			local item = {};
			item.panel = v;
			item.go = go;
			item._name = name
			if(name == "UI_MainUIPanel") then
				if(includeMain) then
					--go:SetActive(false);
					v:SetPanelLayer(false)				
				end
			else
				go:SetActive(false);
			end
			
			--            if (not includeMain and name == "UI_MainUIPanel") then
			--            else
			--                go:SetActive(false);
			--            end
			-- log(item.go.name);
			insert(cache, item);
		end
	end
	-- log("--------------------------------------------------")
	insert(cacheStack, cache);
end

function PanelManager.RevertAllPanels()
	local cache = table.remove(cacheStack);
	--    Warning("-----------PanelManager.RevertAllPanels-----------" .. tostring(cache))
	if cache then
		for i, item in ipairs(cache) do
			-- log(item.go.name);
			if(item.go) then
				if(item._name == "UI_MainUIPanel") then
					item.panel:SetPanelLayer(true)
					--item.go:SetActive(true);
				else
					item.go:SetActive(true);
				end
			else
				log("界面不存在")
			end
		end
	end
	-- log("--------------------------------------------------")
end

function PanelManager.InsertToCache(panel)
	cache = cacheStack[#cacheStack];
	if cache then
		local item = {};
		local go = panel:GetGameObject();
		item.panel = panel;
		item.go = go;
		go:SetActive(false);
		insert(cache, item);
	end
end

-- 删除所有面板
function PanelManager.DisposeAll()
	for i, v in ipairs(_allPanels) do
		local go = v:GetGameObject()
		if not IsNil(go) then Resourcer.Recycle(go, false) end
	end
end

function PanelManager.GetPanelByType(panelName)
	for k, v in ipairs(_panels) do
		if(v._name == panelName) then
			return v
		end
	end
end

function PanelManager.OnMainUIShow()
	--Warning("PanelManager.OnMainUIShow");
	PanelManager.MainUIShow = true;
end

function PanelManager.OnMainUIHide()
	--Warning("PanelManager.OnMainUIHide");
	PanelManager.MainUIShow = false;
end

function PanelManager.OnMainUIFocus()
	--Warning("PanelManager.OnMainUIFocus");
	PanelManager.isOverMainUI = false;
	SystemManager.OnMainUI();
	GuideManager.OnMainUI();
end

function PanelManager.OnMainUIOver()
	--Warning("PanelManager.OnMainUIOver");
	PanelManager.isOverMainUI = true;
end

function PanelManager.IsOnMainUI()
	return #_panels > 0 and PanelManager.MainUIShow == true and PanelManager.isOverMainUI == false;
end
