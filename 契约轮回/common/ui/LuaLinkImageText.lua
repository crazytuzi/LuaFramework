--
-- @Author: LaoY
-- @Date:   2019-03-06 17:03:00
--

-- 兼容unity html格式 <color=#%s>%s</color>等 

--[[ 带图片格式说明
	带图片格式：		回调函数参数三个(image,login:img_role_head_1,87)
	ps:<quad name=login:img_role_head_1 size=87 width=1 />

	带帧动画 
	ps:<quad name=login:{{img_role_head_1,img_role_head_2},5,1,0.1} size=87 width=1 />
	参数解析
	{img_role_head_1,img_role_head_2} 对应的帧动画资源名字列表
	5 帧动画时间，循环填0
	1 停止后显示的帧动画显示的资源序号；对应帧动画资源名字列表序号；1表示停止播放后显示第1张图
	0.1 动画切换的时间间隔。0.1表示0.1才切换一张图
]]

--[[
	超链接 回调函数参数一个(aaaa)
	<a href=aaaa>立即前往</a>
]]
LuaLinkImageText = LuaLinkImageText or class("LuaLinkImageText")

function LuaLinkImageText:ctor(cls,linkimagetext,load_call_func,click_call_func)
	self.cls = cls
	self.linkimagetext = linkimagetext
	self.load_call_func = load_call_func
	self.click_call_func = click_call_func

	self.img_list = {}
	self.action_list = {}
	self.sprite_list = {}
	if self.linkimagetext then
		self:Init()
	end
end

function LuaLinkImageText:SetSprites(sprite_list)
	self.sprite_list = sprite_list
end

function LuaLinkImageText:dctor()
	self:clear()
	lua_resMgr:ClearClass(self)
	self.linkimagetext = nil
end

function LuaLinkImageText:Init()
	self.linkimagetext:AddLoadSpriteFun(handler(self, self.Load))
	self.linkimagetext:AddClickListener(handler(self, self.click))
end

function LuaLinkImageText:clear()
	if self.img_list then
		for img,_ in pairs(self.img_list) do
			if not IsNil(img) then
				img.sprite = nil
			end
		end
	end
	self.img_list = {}
	self.sprite_list = {}
	self:RemoveAction()
end

function LuaLinkImageText:Load(img,res)
	if self.load_call_func then
		self.load_call_func(img,res)
	else
		self.img_list[img] = self.img_list[img] or {}
		if self.img_list[img].res == res then
			return
		end
		self.img_list[img].res = res
		local abName,assetName = ResourceName(res)
		self.sprite_list[abName] = self.sprite_list[abName] or {}
		-- 动画
		if string.find(assetName,"%b{}") then
			local info = String2Table(assetName)
			local list = info[1]
			local time = info[2] or 0
			local last_sprite_index = info[3] or 1
			local delayperunit = info[4] or 0
			local loop_count = info[5] or 0
			local array = {}

			local function start_action()
				if self.action_list[img] then
					cc.ActionManager:GetInstance():removeAllActionsFromTarget(img)
					self.action_list[img] = nil
				end
				local action = cc.Animate(array,time,img,last_sprite_index,delayperunit,loop_count)
				cc.ActionManager:GetInstance():addAction(action,img)
				self.action_list[img] = action
			end
			for i=1,#list do
				local assetName = list[i]
				if self.sprite_list[abName][assetName] then
					array[i] = self.sprite_list[abName][assetName]
				else
					local function callBack(objs)
						if self.is_dctored then
							return
						end
						if not img or tostring(img) == "null" or not self.img_list[img] or self.img_list[img].res ~= res then
							return
						end
						local sprite = objs[0]
						if i == 1 then
							img.sprite = sprite
						end
						array[i] = sprite
						self.sprite_list[abName][assetName] = sprite
						if table.nums(array) >= #list then
							start_action()
						end

						SetVisible(self.linkimagetext,false)
						SetVisible(self.linkimagetext,true)
					end
					lua_resMgr:LoadSprite(self, abName, assetName,callBack)
				end
				if table.nums(array) >= #list then
					start_action()
				end
			end
		else
			local function callBack(sprite)
				if self.is_dctored then
					return
				end
				if tostring(img) == "null" or self.img_list[img].res ~= res then
					return
				end
				img.sprite = sprite
				SetVisible(self.linkimagetext,false)
				SetVisible(self.linkimagetext,true)
			end
			if string.find(abName,"icon_goods_") then
				abName = string.gsub(abName,"_image","")
			end
			lua_resMgr:SetImageTexture(self,img, abName, assetName,true,callBack)
		end
	end
end

function LuaLinkImageText:click(str)
	if self.click_call_func then
		self.click_call_func(str)
	end
end

function LuaLinkImageText:OnPause()

end

function LuaLinkImageText:OnResume()

end

function LuaLinkImageText:RemoveAction()
	for img,v in pairs(self.action_list) do
		cc.ActionManager:GetInstance():removeAllActionsFromTarget(img)
	end
	self.action_list = {}
end