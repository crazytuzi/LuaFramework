-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      资源加载控制器
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ResourcesLoad = ResourcesLoad or BaseClass()

function ResourcesLoad:__init(need_lock)
	self.res_list = {}         -- 待加载资源
	self.is_loading = false
	self.del_list = {}
	self.need_lock = need_lock
end

function ResourcesLoad:__delete()
	self.load_completed_back = nil
	if self.del_list and next(self.del_list) then
		for i, data in ipairs(self.del_list) do
			ResourcesCacheMgr:getInstance():decreaseReferenceCount(data.path, data.delete_time)
		end
	end
	self.del_list = nil
end

--==============================--
--desc:加载资源，list包含资源名，和资源类型，是图集还是散图
--time:2018-04-19 08:15:14
--@list:
--@callback:
--@return 
--==============================--
function ResourcesLoad:addAllList(list, callback)
	if list == nil or next(list) == nil then return end
	self.res_list = DeepCopy(list)
	self.load_completed_back = callback
	self.del_list = {}
	self:loadResouces()
end

--==============================--
--desc:加载单个资源
--time:2018-04-25 10:21:42
--@path:
--@type:
--@callback:
--@return 
--==============================--
function ResourcesLoad:addDownloadList(path, type, callback, delete_time)
	self.path = path
	if path ~= nil and type ~= nil then
		table.insert(self.res_list, {path = path, type = type, delete_time = delete_time})
		self.load_completed_back = callback
		self:loadResouces()
	end
end

--==============================--
--desc:循环加载资源，加载完了一个继续下一个
--time:2018-04-20 09:35:21
--@return 
--==============================--
function ResourcesLoad:loadResouces(data)
	if data and data.path and data.type then
		ResourcesCacheMgr:getInstance():increaseReferenceCount(data.path, data.type)
		-- 可能资源缓存回来之后,这个加载对象已经移除掉了,这个时候存不到待移除列表中,那么直接删掉
		if self.del_list ~= nil then
			table.insert(self.del_list, data)
		else
			ResourcesCacheMgr:getInstance():decreaseReferenceCount(data.path, data.delete_time)
			return
		end
	end
	
	if self.res_list and next(self.res_list) ~= nil then
		local data = table.remove(self.res_list, 1)
		self.is_loading = true
		-- 这里判断一下缓存的存不存在，优先判断lua层记录的存在不存在，要是存在直接引用计数加1，返回下一步
		if ResourcesCacheMgr:getInstance():checkCacheResources(data.path) then
			self:loadResouces(data)
		else
			-- 这里判断一下资源本地是否存在，不存在，则需要去下载回来再触发
			if PathTool.checkResourcesExist(data.path) then
				if data.type == ResourcesType.plist then
					self:handleLoadPlist(data)
				elseif data.type == ResourcesType.single then
					display.loadImage(data.path, function(texture)
						self:loadResouces(data)
					end)
				end
			else
				-- 这里是资源部存在，那么就需要去边玩变下了,这时候下载回来的只是图集。。。。。需要做进一步转换成需要的东西
				print(string.format("当前资源 %s 不存在，因此需要去cdn上面下载回来！", data.path))
				-- 这个时候锁屏吧，
				if self.need_lock == true then
					LoginController:getInstance():openDownLoadView(true)
				end
				PathTool.downloadResources(data, function(data)
					if data.type == ResourcesType.single then
						self:loadResouces(data)
					else
						self:handleLoadPlist(data)
					end
				end)
			end
		end
	else
		if self.load_completed_back ~= nil then
			if self.need_lock == true then
				LoginController:getInstance():openDownLoadView(false)
			end
			self.load_completed_back()
		end
	end
end

--==============================--
--desc:针对图集类资源的加载引用
--time:2018-04-25 11:38:22
--@data:
--@return 
--==============================--
function ResourcesLoad:handleLoadPlist(data)
	if data ~= nil and data.path ~= nil and data.type == ResourcesType.plist then
		local path_list = string.split(data.path, ".")
		if path_list == nil or #path_list ~= 2 then
			print("加载资源路径出错，路径为：", data.path)
			self:loadResouces()
		else
			local plist_name = string.format("%s.plist", path_list[1])
			-- 后期这里做边玩边下处理部分
			if display.isSpriteFramesWithFileLoaded(plist_name) then
				self:loadResouces(data)
			else
				display.loadSpriteFrames(plist_name, data.path, function(data_file, res_file)
					self:loadResouces(data)
				end)
			end
		end
	end
end 