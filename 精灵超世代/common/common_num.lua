-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      通用的艺术数字类
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
CommonNum = class("CommonNum", function()
	return ccui.Widget:create()
end)


function CommonNum:ctor(type, parent, num, space, ap)
	self.num_list = {}	
	self.num_pool_list = {}
	self.is_init = false
	self.type = type or 1
	self.space = space or 1
	self.is_completed = false
	self:setAnchorPoint(ap or cc.p(0.5, 0.5))
	self:setCascadeOpacityEnabled(true)
	if parent ~= nil then
		parent:addChild(self)
	end
	self:setNum(num)
end

--==============================--
--desc:设置需要显示的数字
--time:2018-05-30 02:37:02
--@num:
--@add:
--@return 
--==============================--

-- CommonNum.Record_Type = 20
--永久加载的resource对象
common_num_resources_load = nil
common_num_is_completed = false

--常驻的num 
commom_battle_num = {}
commom_battle_num[2] = true --加血 数字
commom_battle_num[4] = true --伤害 数字
commom_battle_num[7] = true --暴击伤害数字
commom_battle_num[24] = true --诅咒伤害数字
commom_battle_num[25] = true --冰冻伤害数字
commom_battle_num[27] = true --克制伤害数字

commom_battle_num[19] = true --vip数字
commom_battle_num[20] = true --战力的 


--断线重连后会清除一下res 防止资源被移除了
function CommonNumClearRes()
	if common_num_resources_load ~= nil then
		common_num_resources_load:DeleteMe()
		common_num_resources_load = nil
		common_num_is_completed = false
	end
end

function CommonNum:setNum(num, add)
	if num == nil then return end
	self.num = num
	self.addtype = add
	self.plist_file = nil
	
	if commom_battle_num[self.type] then
		self.plist_file = "battle_num"
		if common_num_is_completed == true then
			self:setOfficialNum(self.num, self.addtype)
		else
			if common_num_resources_load == nil then
				local function loadComplete()
					common_num_is_completed = true
					if not tolua.isnull(self) then
						self:setOfficialNum(self.num, self.addtype)
					end
				end 
				common_num_resources_load = ResourcesLoad.New()
				-- local res = PathTool.getPlistImgForDownLoad("num", string.format("type%s", CommonNum.Record_Type)) 
				local res = PathTool.getPlistImgForDownLoad("num", "battle_num") 
				common_num_resources_load:addDownloadList(res, ResourcesType.plist, loadComplete) 
			end
		end
	else
		self.plist_file = string.format("type%s", self.type)
		if self.is_completed == true then
			self:setOfficialNum(self.num, self.addtype)
		else
			local function loadComplete(...)
				self.is_completed = true
				if not tolua.isnull(self) then
					self:setOfficialNum(self.num, self.addtype)
				end
			end 
			if self.resources_load == nil then
				self.resources_load = ResourcesLoad.New()
				local res = PathTool.getPlistImgForDownLoad("num", string.format("type%s", self.type)) 
				self.resources_load:addDownloadList(res, ResourcesType.plist, loadComplete) 
			end
		end
	end
end

function CommonNum:setOfficialNum(num, add)
	local _getResFrame = PathTool.getResFrame 
	local _string_format = string.format
	local _table_remove = table.remove 
	local _table_insert = table.insert 

	for k, object in ipairs(self.num_list) do
		object.sp:setVisible(false)
		_table_insert(self.num_pool_list, object)
	end
	self.num_list = {}
	
	local temp_str = type(num) == "number" and tostring(num) or num
	if add ~= nil then
		if add == true then
			temp_str = "+" .. temp_str
		else
			temp_str = "-" .. temp_str
		end
	end
	local temp_len = string.len(temp_str)
	local height, _x = 0, 0
	for i = 1, temp_len do
		local char = string.sub(temp_str, i, i)
		if char == "+" then
			char = "add"
		elseif char == "-" then
			char = "sub"
		elseif char == "/" then
			char = "bias"
		elseif char == "." then
			char = "point"
		elseif char == ":" then
			char = "mao"
		elseif char == "s" then
			char = "txt_cn_step"
		elseif char == "g" then
			char = "txt_cn_go"
		end
		-- local res = _getResFrame("common", _string_format("num%s/type%s_%s", self.type, self.type, char), false, "num")
		local res = _getResFrame("num", _string_format("type%s_%s", self.type, char), false, self.plist_file)

		local object = nil
		local sp = nil
		if next(self.num_pool_list) then
			object = _table_remove(self.num_pool_list, 1)
		else
			sp = createSprite(nil, 0, 0, nil, cc.p(0, 0.5))
			object = {sp = sp, res = nil, size = nil}
			self:addChild(sp)
		end
		_table_insert(self.num_list, object)
		object.sp:setVisible(true)
		if object.res ~= res then
			object.res = res
			loadSpriteTexture(object.sp, res, LOADTEXT_TYPE_PLIST)
			object.size = object.sp:getContentSize()
		end
		if char == "point" then
			object.sp:setAnchorPoint(cc.p(0, 0))
			object.sp:setPositionY(-height / 2)
		end
		object.sp:setPositionX(_x)
		_x = _x + object.size.width + self.space
		if height <= object.size.height then
			height = object.size.height
		end
	end
	self:setContentSize(cc.size(_x, height))
	if self.call_back then
		self.call_back()
	end
end

function CommonNum:setCallBack(value)
	self.call_back = value
end

function CommonNum:DeleteMe()
	for i, object in ipairs(self.num_pool_list) do
		object.sp:removeFromParent()
	end
	self.num_pool_list = nil

	for i,object in ipairs(self.num_list) do
		object.sp:removeFromParent()
	end
	self.num_list = nil

	if self.resources_load then
		self.resources_load:DeleteMe()
	end
	self.resources_load = nil
	
	self:removeAllChildren()
	self:removeFromParent()
end 