--[[
UI加载器
lizhuangzhuang
2014年8月23日16:56:39
]]
_G.classlist['UILoaderManager'] = 'UILoaderManager'
_G.UILoaderManager = {};
_G.UILoaderManager.objName = 'UILoaderManager'
UILoaderManager.list = {};
UILoaderManager.groupLoaderList = {};

function UILoaderManager:Create()
end

--加载组
function UILoaderManager:LoadGroup(groupName,isLow,onFinish,onProgress)
	if isLow and self.groupLoaderList[groupName] and not self.groupLoaderList[groupName].lowPriority then
		return;
	end
	
	if self.groupLoaderList[groupName] then
		self.groupLoaderList[groupName]:stop();
		self.groupLoaderList[groupName] = nil;
	end
	local loader = _Loader.new();
	self.groupLoaderList[groupName] = loader;
	WriteLog(LogType.Normal,true,'LoadGroup'..groupName);
	loader:loadGroup(groupName);
	if isLow then
		loader.lowPriority = true;
	else
		loader.lowPriority = false;
	end
	loader:onFinish(function()
		if onFinish then
			onFinish();
		end
		self.groupLoaderList[groupName] = nil;
	end);
	
	if onProgress then
		loader:onProgress(function(p)
			if onProgress then
				onProgress(p);
			end
		end);
	end
end

function UILoaderManager:RemoveLoadGroup(groupName)
	local loader = self.groupLoaderList[groupName];
	WriteLog(LogType.Normal,true,'RemoveLoadGroup'..groupName);
	if loader then
		loader:stop();
		WriteLog(LogType.Normal,true,'111RemoveLoadGroup'..groupName);
		self.groupLoaderList[groupName] = nil;
	end
end

--加载文件
function UILoaderManager:LoadList(urllist,OnFinish,OnProgress,isLow)
	local listVO = UILoadListVO:new();
	table.push(self.list,listVO);
	listVO.list = urllist;
	listVO.OnFinish = OnFinish;
	listVO.OnProgress = OnProgress;
	listVO.isLow = isLow;
	listVO:StartLoad();
end

function UILoaderManager:RemoveLoadList(loadList)
	for i=#self.list,1,-1 do
		local vo = self.list[i];
		if vo == loadList then
			table.remove(self.list,i);
			break;
		end
	end
end

--[[
UILoadListVO
]]
_G.UILoadListVO = {};
function UILoadListVO:new()
	local obj = {};
	for k,v in pairs(UILoadListVO) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj.list = {};--资源队列
	obj.loaderlist = {};--加载队列
	obj.progresslist = {};--进度队列
	obj.loadedNum = 0;--已加载数量
	obj.totalNum = 0;--总数量
	obj.isLoading = false;--是否正在加载
	obj.OnFinish = nil;
	obj.OnProgress = nil;
	obj.isLow = false;
	return obj;
end

--开始加载
function UILoadListVO:StartLoad()
	if self.isLoading then
		print("Error:UILoadList is loading.");
		return;
	end
	self.isLoading = true;
	self.totalNum = #self.list;
	for i,url in ipairs(self.list) do
		local loader = _Loader.new();
		self.loaderlist[i] = loader;
		loader:load(url);
		if self.isLow then
			loader.lowPriority = true;
		end
		loader:onFinish(function()
			self:OnOneFinish(i);
			self.loaderlist[i] = nil;
		end);
		loader:onProgress(function(p)
			self:OnOneProgress(i,p);
		end);
	end
end

--单个加载的回调
function UILoadListVO:OnOneFinish(i)
	self.loadedNum = self.loadedNum + 1;
	if self.loadedNum == self.totalNum then
		if self.OnFinish then
			self.OnFinish();
		end
		UILoaderManager:RemoveLoadList(self);
	end
end
function UILoadListVO:OnOneProgress(i,p)
	self.progresslist[i] = p;
	if self.OnProgress then
		local percent = 0;
		for i,ip in pairs(self.progresslist) do
			percent = percent + ip/self.totalNum;
		end
		self.OnProgress(percent);
	end
end