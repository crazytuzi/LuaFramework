-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      lua层的资源缓存管理
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ResourcesCacheMgr = ResourcesCacheMgr or BaseClass()

function ResourcesCacheMgr:getInstance()
	if self.instance == nil then
		self.instance = ResourcesCacheMgr.New()
	end
	return self.instance
end

function ResourcesCacheMgr:__init()
	self.resources_list = {}            -- lua层统计的资源数据
	self.wait_del_list = {}             -- 待删除的，为什么不直接用resources_list,主要是担心遍历的太多，但是待删除的肯定不是很多

	self.resources_count_list = {}
	self.step_interval  = 10			-- ui资源10秒释放
	self.battle_step_interval = 60		-- 战斗类的资源1分钟释放

	self.is_battle_path = {}			-- 是都是战斗类的资源

	self.plat_form = PLATFORM_NAME 
end

function ResourcesCacheMgr:__delete()
	if self.queue_timer ~= nil then
		GlobalTimeTicket:getInstance():remove(self.queue_timer)
		self.queue_timer = nil
	end
end

--==============================--
--desc:判断一个资源是否保存在缓存中
--time:2018-04-20 12:12:41
--@path:
--@return 
--==============================--
function ResourcesCacheMgr:checkCacheResources(path)
	if path == nil or type(path) ~= "string" then
		return false
	end
	if self.resources_list[path] then       -- 本地缓存有记录
		return true
	elseif display.getImage(path) then      -- 内存有记录
		return true
	else
		return false
	end
end

--==============================--
--desc:检查一个资源是否存在
--time:2019-02-22 09:19:13
--@path:
--@return 
--==============================--
function ResourcesCacheMgr:checkResource(path)
	local resources_data = self.resources_list[path]
	if resources_data and resources_data.count > 0 then
		return true
	end
	return false
end

--==============================--
--desc:设置加载资源计数，并且表明资源类型，是图集还是单个图片
--time:2018-04-19 08:13:16
--@path:
--@type:
--@return 
--==============================--
function ResourcesCacheMgr:increaseReferenceCount(path, type)
	local resources_data = self.resources_list[path]
	if resources_data ~= nil then
		if resources_data.count == nil then
			resources_data.count = 0
		end
		resources_data.count = resources_data.count + 1
	else
		local is_battle = self.is_battle_path[path]
		if is_battle == nil then
			local start_index, _ = string.find( path, "battle" )
			is_battle = (start_index ~= nil)
			self.is_battle_path[path] = is_battle
		end
		resources_data = {path = path, count = 1, type = type, timetick = 0, is_battle = is_battle}
		self.resources_list[path] = resources_data
	end
	-- print(string.format("资源%s加载完成，当前引用计数为:%s，资源类型为%s", path, resources_data.count, (type == ResourcesType.plist) and "图集" or "散图"))

	-- 记录需要加载的资源路径
	if self.plat_form  == "demo" or self.plat_form == "release" or self.plat_form == "release2" then 
		local temp_path = ""
		-- if type == ResourcesType.plist then
		-- 	local args = Split(path, "/")
		-- 	for i=1,#args-1 do
		-- 		if temp_path ~= "" then
		-- 			temp_path = temp_path.."/"
		-- 		end
		-- 		temp_path = temp_path..args[i]
		-- 	end
		-- 	temp_path = temp_path.."/"
		-- else
			temp_path = path
		-- end
		if self.resources_count_list[temp_path] == nil then
			self.resources_count_list[temp_path] = temp_path
		end
	end

	-- 如果带下载里面有这个数据，那么移除掉吧
	if self.wait_del_list[path] ~= nil then
		self.wait_del_list[path] = nil
	end
end

function ResourcesCacheMgr:getLoadRes()
	return self.resources_count_list
end

--==============================--
--desc:对资源计数器进行减法处理
--time:2018-04-20 02:09:53
--@path:
--@delete_time 自定义移除时间
--@type:
--@return 
--==============================--
function ResourcesCacheMgr:decreaseReferenceCount(path, delete_time)
	local resources_data = self.resources_list[path]
	if resources_data == nil or resources_data.count <= 0 then
		-- print("移除图集计数出错，该图集不存在或该图集计数为空，", path)
	else
		resources_data.count = resources_data.count - 1
		if resources_data.count == 0 then   -- 这个时候需要就把这个图集丢到待删除的列表里面，延迟15秒删除
			resources_data.timetick = os.time() -- 记录时间
			if delete_time then
				resources_data.delete_time = delete_time
			end
			-- 添加到待删除列表中去
			self.wait_del_list[resources_data.path] = resources_data
			-- 这个时候再创建计数器吧
			if self.queue_timer == nil then
				self.queue_timer = GlobalTimeTicket:getInstance():add(function()
					self:checkRemoveRes()
				end, 1)
			end
		end
		-- print(string.format("添加待删除资源 %s，该资源类型为 %s，当前引用计数为 %s，若为0，则10秒后移除!", resources_data.path, resources_data.type == ResourcesType.plist and "图集" or "散图", resources_data.count))
	end
end

--==============================--
--desc:没隔10秒监测一次。需要删除的资源
--time:2018-04-19 08:08:44
--@return 
--==============================--
function ResourcesCacheMgr:checkRemoveRes()
	if self.wait_del_list ~= nil and next(self.wait_del_list) ~= nil then
		local cur_time = os.time()
		for key, data in pairs(self.wait_del_list) do
			if data.path ~= nil then
				if data.timetick == nil then
					data.timetick = 0
				end
				if data.count == 0 then
					local can_del = false
					if data.is_battle == true then
						can_del = ((cur_time - data.timetick) >= self.battle_step_interval)
					else
						if data.delete_time then
							can_del = ((cur_time - data.timetick) >= data.delete_time)
						else
							can_del = ((cur_time - data.timetick) >= self.step_interval)
						end
						
					end
					if can_del == true then
						if data.type == ResourcesType.plist then
							local path_list = string.split(data.path, ".")
							if path_list == nil or #path_list ~= 2 then
							else
								local plist_name = string.format("%s.plist", path_list[1])
								display.removeSpriteFrames(plist_name, data.path)
							end
						elseif data.type == ResourcesType.single then
							display.removeImage(data.path)
						end
						self.resources_list[data.path] = nil        -- 清除掉缓存的记录数据
						self.wait_del_list[key] = nil
					end
				else
					self.wait_del_list[key] = nil
				end
			end
		end
	end
end

-- 移除所有的图集和散图,只有在切换账号的时候触发
function ResourcesCacheMgr:cleanAllTexture()
	if self.resources_list and next(self.resources_list) then
		for k, data in pairs(self.resources_list) do
			if data.type == ResourcesType.plist then
				local path_list = string.split(data.path, ".")
				if path_list == nil or #path_list ~= 2 then
				else
					local plist_name = string.format("%s.plist", path_list[1])
					display.removeSpriteFrames(plist_name, data.path)
				end
			else
				display.removeImage(data.path)
			end
		end

	end
end
