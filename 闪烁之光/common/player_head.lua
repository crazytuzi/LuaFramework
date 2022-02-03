-- --------------------------------------------------------------------
-- 通用的头像处理,这里内部有做遮罩处理的
-- 圆形的头像默认尺寸是 108*108 方形的尺寸是92,92
-- @author: hfy@syg.com(必填, 创建模块的人员)
-- @editor: hfy@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

PlayerHead = PlayerHead or class("PlayerHead", function()
	return ccui.Widget:create()
end)

-- 头像类型
PlayerHead.type = {
	circle = 1, 			--圆形头像,这类头像自带遮罩
	square = 2, 			--方形头像,
	other = 3, 				--自定义头像,需要自己传参数设定资源
}

--==============================--
--desc:创建一个头像样式,
--time:2017-07-10 02:22:59
--@type:头像类型,是圆还是方,或者自定义,自定义需要自己传入头像框的尺寸和资源路径
--@offest_y:
--@size:
--@res:
--@mask_res:
--@return 
--==============================--
function PlayerHead:ctor(type, offest_y, size, res, mask_res, is_plist)
	local bgRes
	self.is_plist = true
	if is_plist ~= nil then
		self.is_plist = is_plist
	end

	if type == PlayerHead.type.square then
		self.vSize = cc.size(104,104)
		bgRes = PathTool.getNormalCell()
	elseif type == PlayerHead.type.circle then
		self.vSize = cc.size(108,108)
		bgRes = PathTool.getResFrame("common","common_1031")
		self.mask_res = PathTool.getResFrame("common", "common_1032") 
		self.is_plist = true
	elseif type == PlayerHead.type.other then
		self.vSize = size or cc.size(108, 108) 
		bgRes = res
		self.mask_res = mask_res or PathTool.getResFrame("common", "common_1032")
	end
	if bgRes == nil or bgRes == "" then
		print("==============> PlayerHead:ctor Error")
		return 
	end
	self.offest_y = offest_y or -2
	self:buildLayout(self.vSize, bgRes)
end

function PlayerHead:buildLayout(size, bgRes)
	self.head_panel = ccui.Widget:create()
	self.head_panel:setAnchorPoint(cc.p(0.5,0.5))
	self.head_panel:setContentSize(self.vSize)
	self.head_panel:setPosition(self.vSize.width/2, self.vSize.height/2)
	self.head_panel:setCascadeOpacityEnabled(true)
	self:addChild(self.head_panel)
	self:setContentSize(self.vSize)
	self:setCascadeOpacityEnabled(true)
	if self.mask_res ~= nil then
		self.mark_bg = createSprite(self.mask_res, self.vSize.width/2, self.vSize.height/2, self.head_panel, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)

		self.mask = createSprite(self.mask_res, self.vSize.width/2, self.vSize.height/2, nil, cc.p(0.5, 0.5))

		self.clipNode = cc.ClippingNode:create(self.mask)
		self.clipNode:setAnchorPoint(cc.p(0.5,0.5))
		self.clipNode:setContentSize(self.vSize)
		self.clipNode:setCascadeOpacityEnabled(true)
		self.clipNode:setPosition(self.vSize.width/2,self.vSize.height/2 + self.offest_y)
		self.clipNode:setAlphaThreshold(0)
		self.head_panel:addChild(self.clipNode,2)

		-- self.icon = createSprite(nil, self.vSize.width/2, self.vSize.height/2+2, self.clipNode, cc.p(0.5, 0.5), nil, 3)

		self.icon = ccui.ImageView:create()
		self.icon:setCascadeOpacityEnabled(true)
		self.icon:setAnchorPoint(0.5,0.5)
		self.icon:setPosition(self.vSize.width/2,self.vSize.height/2+2)
		self.clipNode:addChild(self.icon,3)
	else
		-- self.icon = createSprite(nil, self.vSize.width / 2, self.vSize.height / 2 + 2, self.head_panel, cc.p(0.5, 0.5), nil, 3)

		self.icon = ccui.ImageView:create()
		self.icon:setCascadeOpacityEnabled(true)
		self.icon:setAnchorPoint(0.5,0.5)
		self.icon:setPosition(self.vSize.width/2,self.vSize.height/2+2)
		self.head_panel:addChild(self.icon)
	end
	if bgRes and bgRes~="" then
		self:showBg(bgRes, size)
	end
end

function PlayerHead:setHeadLayerScale(scale)
	scale = scale or 1
	self.head_panel_scale = scale
	if self.head_panel then 
		self.head_panel:setScale(scale)
	end
end

--获取只有头像的层
function PlayerHead:getHeadLayer()
	return self.head_panel
end
--背景框
function PlayerHead:showBg(res, size, is_plist,offy)
	offy = offy or 0
	if not res then 
		if self.headbg then
			self.headbg:setVisible(false)
		end
		return
	end
	if type(res) == "number" then
		res = PathTool.getHeadcircle(res)
	end

	if is_plist ~= nil then 
		self.is_plist = is_plist
	end

	if not self.bgRes or self.bgRes~=res then
		if not self.headbg then
			size = size or self.vSize
			local zorder = -1
			if self.mask ~= nil then
				zorder = 3
			end
			self.headbg = createSprite(nil, self.vSize.width/4, self.vSize.height/2, self.head_panel, cc.p(0.5,0.5), nil, zorder)
			if self.is_plist == false then 
				if not self.item_load then
			        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
			            if not tolua.isnull(self.headbg) then
			                loadSpriteTexture(self.headbg, res, LOADTEXT_TYPE)
			            end
			        end, self.item_load)
			    end
				self:setHeadBgScale(100/117)
			else 
				loadSpriteTexture(self.headbg, res, LOADTEXT_TYPE_PLIST)
			end
			self.headbg:setCascadeOpacityEnabled(true)
		else
			self.headbg:setVisible(true)
			if self.is_plist == false then
				loadSpriteTexture(self.headbg, res, LOADTEXT_TYPE)
				self:setHeadBgScale(100/117)
			else 
				loadSpriteTexture(self.headbg, res, LOADTEXT_TYPE_PLIST)
				self:setHeadBgScale(1)
			end
		end
	end
	self:setHeadBgOffy(offy)

	--背景特效
	local string_find = string.find
	local _, start_pos = string_find(res, "txt_cn_headcircle_")
	local end_pos = string_find(res, ".png")
	if start_pos ~= nil and end_pos ~= nil then
		local res_id = string.sub(res, start_pos + 1, end_pos - 1 )
		local effect_id = Config.AvatarData.data_avatar_effect[tonumber(res_id)]
		if effect_id and effect_id.effect_id ~= "" then
			self:showBgEffect(true , effect_id)
		else
			self:showBgEffect(false)
		end
	else
		self:showBgEffect(false)
	end
end

function PlayerHead:showBgEffect(bool, effect_id)
    if not self.headbg then
        return
    end
    if bool == false then
        if self.bg_effect then
            self.bg_effect:clearTracks()
            self.bg_effect:removeFromParent()
            self.bg_effect = nil
        end
	else
		if effect_id.is_only_effect == 1 then
			self.headbg:setVisible(false)
		else
			self.headbg:setVisible(true)
		end
		if self.bg_effect ~= nil and self.effect_id ~= effect_id.effect_id then
			self:showBgEffect(false)
		end
        if self.bg_effect == nil then
            local x, y = 0, 0
            if effect_id.effect_pos_x == 0 then
				x = 55
            else
				x = effect_id.effect_pos_x
			end
			if effect_id.effect_pos_y == 0 then
				y = 55
            else
				y = effect_id.effect_pos_y
			end
			local zorder = -1
			if self.mask ~= nil then
				zorder = 3
			end
            self.bg_effect = createEffectSpine(effect_id.effect_id, cc.p(x, y), cc.p(0.5, 0.5), true, PlayerAction.action)
			self.head_panel:addChild(self.bg_effect, zorder)
			self.bg_effect:setScale(self.headbg_scale or 1)
			self.effect_id = effect_id.effect_id
        else
            self.bg_effect:setVisible(true)
        end
    end
end 

function PlayerHead:setHeadBgOffy(offy)
	self.headbg:setPosition(cc.p(self.vSize.width/2, self.vSize.height/2+offy))
end

function PlayerHead:setHeadBgScale(scale)
	if self.headbg then
		self.headbg:setScale(scale)
		self.headbg_scale = scale
	end
end
function PlayerHead:setEffectBgScale(scale)
	if self.bg_effect then
		self.bg_effect:setScale(scale)
	end
end

function PlayerHead:hideHeadBg()
	self.headbg:setVisible(false)
end
function PlayerHead:setHeadIconStatus(status)
	if self.icon == nil then return end

	setChildUnEnabled(status, self.icon)
end

-- 显示关闭按钮,
function PlayerHead:showClose()
	if not tolua.isnull(self.close_btn) then
	end
end

function PlayerHead:setGray(bool)
	if self.headbg then
		setChildUnEnabled(bool,self.icon)
	end
end

function PlayerHead:setSex(sex, pos)
	if sex == nil or type(sex) ~= "number" then return end
	if sex >= 2 then return end
	if self.sex_icon == nil then
		self.sex_icon = createSprite(PathTool.getResFrame("common", "common_sex"..sex), 4, 4, LOADTEXT_TYPE_PLIST) 
		self.sex_icon:setAnchorPoint(cc.p(0, 0))
		self:addChild(self.sex_icon, 1)
	else
		loadSpriteTexture(self.sex_icon, PathTool.getResFrame("common", "common_sex" .. sex), LOADTEXT_TYPE_PLIST) 
	end
	if pos ~= nil and self.sex_icon ~= nil then
		self.sex_icon:setPosition(pos)
	end 
end

--[[
    @desc:设置显示等级
    author:{author}
    time:2018-05-14 10:08:27
    --@lev:等级值
	--@pos:等级组件的位置
	--@scale:等级组件的缩放
    return
]]
function PlayerHead:setLev(lev, pos)
    if not self.txtLev then
    	if not self.levBg then
        	self.levBg = createSprite(PathTool.getResFrame("common","common_1030"), 6, 66, LOADTEXT_TYPE_PLIST)
			self.levBg:setCascadeOpacityEnabled(true)
        else
        	self.levBg:setVisible(true)
 		end
        self.levBg:setAnchorPoint(cc.p(0, 0))
        self:addChild(self.levBg,1)

		local scale = self.head_panel_scale or 1
		self.levBg:setScale(scale)

        self.txtLev = createLabel(18,Config.ColorData.data_color4[1],Config.ColorData.data_color4[152],self.levBg:getContentSize().width/2-2,self.levBg:getContentSize().height/2+1,"",self.levBg,1,cc.p(0.5,0.5))
        self.txtLev:setLocalZOrder(1)
	end
	if self.levBg then
		self.levBg:setVisible(true)
	end
    self.txtLev:setString(lev)
    if pos ~= nil and self.levBg ~= nil then
    	self.levBg:setPosition(pos)
    end
end
function PlayerHead:showLevBg(res)
	if  self.levBg then
		loadSpriteTexture(self.levBg,res,LOADTEXT_TYPE)
	end
end
function PlayerHead:setLevScale(scale)
	if  self.levBg then
		self.levBg:setScale(scale)
	end
end
--设置等级位置
function PlayerHead:setLevPositon(pos)
	if self.levBg then 
		self.levBg:setPosition(pos)
	else
		self.lev_pos = pos
	end
end
--关闭等级
function PlayerHead:closeLev()
    if self.levBg then
        self.levBg:setVisible(false)
    end
    if self.txtLev then
    	self.txtLev:setString("")
	end
end

--名字显示
function PlayerHead:setName(name, color)
end

function PlayerHead:setNamePosition(pos)
	-- if self.nameBg then
	-- 	self.nameBg:setPosition(pos)
	-- end
end

--显示描述
--desc 描述内容  
--setting 对应配置 有需求时候写
function PlayerHead:addDesc(status, desc, setting)
	if status then
		local name = desc or TI18N("待加入")
		if self.desc == nil then
			local font_size = 20
			local color = cc.c4b(0xfb,0xe4,0xc7,0xff)
			local x = self.vSize.width * 0.5
			local y = self.vSize.height * 0.5 
			self.desc = createLabel(font_size, color,nil,x, y,name ,self.head_panel,nil, cc.p(0.5,0.5))
			self.desc:setZOrder(1)
		else
			self.desc:setVisible(true)
			self.desc:setString(name)
		end
	else
		if self.desc then
			self.desc:setVisible(false)
		end
	end
end

--显示是否队长
function PlayerHead:showLeader(status, x, y)
	if status then
		if self.leader_icon == nil then
			local x = x or 80 
			local y = y or 84
			self.leader_icon = createSprite(PathTool.getResFrame("arenateam", "txt_cn_arenateam_18"), x, y, LOADTEXT_TYPE_PLIST) 
			self.leader_icon:setAnchorPoint(cc.p(0.5, 0.5))
			self:addChild(self.leader_icon, 1) 
		else
			self.leader_icon:setVisible(true)
		end
	else
		if self.leader_icon then
			self.leader_icon:setVisible(false)
		end
	end
end
--显示在线或者离线 
function PlayerHead:showOnline(status, is_online)
	if status then
		if self.online_bg == nil then
			local x = x or 74 
			local y = y or 20
			self.online_bg = createSprite(PathTool.getResFrame("mainui", "mainui_round_bg"), x, y, LOADTEXT_TYPE_PLIST) 
			self.online_bg:setScale(1.5)
			self.online_bg:setAnchorPoint(cc.p(0.5, 0.5))
			self:addChild(self.online_bg, 2) 
			self.online_text = createLabel(18, cc.c4b(0x8a,0xff,0xa3,0xff),nil,x, y,"" ,self,nil, cc.p(0.5,0.5))
			self.online_text:setZOrder(3)
		else
			self.online_bg:setVisible(true)
			self.online_text:setVisible(true)
		end
		if self.online_text then
			if is_online then
				self.online_text:setString(TI18N("在线"))
				self.online_text:setTextColor(cc.c4b(0x8a,0xff,0xa3,0xff))
			else -- f1635c 
				self.online_text:setString(TI18N("离线"))
				self.online_text:setTextColor(cc.c4b(0xf1,0x63,0x5c,0xff))
			end
		end
	else
		if self.online_bg then
			self.online_bg:setVisible(false)
			self.online_text:setVisible(false)
		end
	end
end

--[[
	设置头像,
	@res 头像资源id,只需要传递id就好了,id具体在headicon对应的资源后缀,以后自定义头像再做扩展,先不考虑
	@is_external 是否是外部资源,非headicon内的资源的话,需要注这个参数,那么 res则是完整路径
	@load_type 加载模式,默认使用碎图加载,考虑到可能是非headicon内的资源,这个就需要调用的人自己控制
	@free_res_id 自定义头像id,旧包不会处理这个字段
	@face_update_time 自定义头像id更新的时间,旧包不会处理这个字段
	@force 自定义头像是否强制下载的。比如说本地展示重置了系统的。这里还是要继续显示的
]]
function PlayerHead:setHeadRes(res, is_external, load_type, free_res_id, face_update_time, force)
	if res == nil or res == "" then return end
	if free_res_id and free_res_id ~= "" and ( force or (face_update_time and face_update_time ~= 0)) then
		TencentCos:getInstance():downLoadHeadFile(free_res_id, face_update_time, function(local_path)
			if not tolua.isnull(self.icon) then
				self:setHeadRes(local_path, true)
			end
		end)
	else
		is_external = is_external or false	
		load_type = load_type or LOADTEXT_TYPE

		self:showReturnIcon(false)--隐藏回归角标
		-- 非外部资源,资源路径重组
		if is_external == false then
			if res > 10000000 then --回归玩家头像ID默认*10000 用于显示回归标签
				local lessTime =  ReturnActionController:getInstance():getModel():getLessTime()
				if lessTime > 0 then
					self:showReturnIcon(true)--显示回归角标	
				end
				res = res/10000
			end
			res = PathTool.getHeadIcon(res)
		end	
		if tolua.isnull(self.icon) then return end

		self.icon:loadTexture(res, load_type)
		self.icon:setVisible(true)
		local icon_size = self.icon:getContentSize()
		-- 如果有遮罩的话,头像尺寸要根据遮罩去做缩放处理
		local off_scale = 1
		if self.mask ~= nil then			
			local mark_size = cc.size(90, 90)
			if self.mark_bg ~= nil then
				mark_size = self.mark_bg:getContentSize()
			end
			off_scale = mark_size.width / icon_size.width > mark_size.height / icon_size.height and mark_size.height / icon_size.height or mark_size.width / icon_size.width	
		end
		self.icon:setScale(off_scale)
		--背景特效
		if self.bg_effect then
			-- self.bg_effect:setVisible(false)
		end
	end
end

function PlayerHead:setHeadResScale(scale)
	if self.icon then
		self.icon:setScale(scale)
	end
end

--清楚头像资源
function PlayerHead:clearHead()
	self.icon:setVisible(false)
end

--清空长按计时
function PlayerHead:resetTime()
	if self.clickTimer then
		GlobalTimeTicket:getInstance():remove(self.clickTimer)
		self.clickTimer = nil
	end
end

--头像装饰框
function PlayerHead:showHeadwear(bid,zorder,scale,x,y)
	local bool = bid > 0

	if Config.HeadSurface[bid] == nil then
		return	
	end

	if not bool then
		if self.wearHead then
			if not tolua.isnull(self.wearHead) then
				self.wearHead:removeFromParent()
			end
			self.wearHead = nil
		end
		self.wearRes = nil
	else
		local zorder = zorder or 0
		local scale = scale or 1
		local x = x or -4
		local y = y or -2

		local res = PathTool.getHeadWearRes(bid)
		if not self.wearRes or self.wearRes ~= res then
			self.wearRes = res
			if not self.wearHead then
				self.wearHead = createImage(self, res, x,y, cc.p(0, 0))
				self.wearHead:setScale9Enabled(true)
				self.wearHead:loadTexture(res)
			else
				self.wearHead:loadTexture(res)
			end
			self.wearHead:setCapInsets(cc.rect(30,30,4,4))
			self.wearHead:setContentSize(cc.size(self.vSize.width+8, self.vSize.height+8))
			self.wearHead:setLocalZOrder(zorder)
			self.wearHead:setScale(scale)
		end
	end
end

function PlayerHead:addCallBack(end_call_back,is_need_longcli)
    self:setTouchEnabled(true)
    self:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.began then
			if is_need_longcli == true and self.head_data then 
				if self.clickTimer then
					GlobalTimeTicket:getInstance():remove(self.clickTimer)
					self.clickTimer = nil
				end
				if not self.clickTimer then
					self.clickTimer = GlobalTimeTicket:getInstance():add(function()
						if self.long_callback then
							self.long_callback(self.head_data)
						-- else
						-- 	CheckController:getInstance():openCheckHero(self.head_data,2)
						end
						self.is_open_tips = true
						if self.clickTimer then
							GlobalTimeTicket:getInstance():remove(self.clickTimer)
							self.clickTimer = nil
						end
					end,1)
				end
			end
        elseif event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.clickTimer then
				GlobalTimeTicket:getInstance():remove(self.clickTimer)
				self.clickTimer = nil
			end
			if self.is_open_tips == true then 
				self.is_open_tips= false
				return
			end
			if end_call_back then
                end_call_back(self)
            end
		elseif event_type == ccui.TouchEventType.moved then
			-- if self.clickTimer then
			-- 	GlobalTimeTicket:getInstance():remove(self.clickTimer)
			-- 	self.clickTimer = nil
			-- end
		elseif  event_type == ccui.TouchEventType.canceled then
			if self.clickTimer then
				GlobalTimeTicket:getInstance():remove(self.clickTimer)
				self.clickTimer = nil
			end
        end
    end)
end

--长按函数回调
function PlayerHead:longCliCallback(value)
	self.long_callback = value
end
--设置头像数据
function PlayerHead:setHeadData(data)
    self.head_data = data
end

function PlayerHead:getData()
    return self.head_data
end

-- 胜利或失败图标 0:失败 1:胜利
function PlayerHead:showBattleResultIcon( result )
	local res_path = PathTool.getResFrame("common", "txt_cn_common_90013")
	if result == 1 then
		res_path = PathTool.getResFrame("common", "txt_cn_common_90012")
	end

	if not self.result_icon then
		local scale = self.head_panel_scale or 1
		self.result_icon = createSprite(res_path, 20, self.vSize.height*scale, self, cc.p(0.5, 0.5), nil, 1)
	else
		loadSpriteTexture(self.result_icon, res_path, LOADTEXT_TYPE_PLIST)
	end
end

-- 回归图标
function PlayerHead:showReturnIcon( is_show )
	if is_show == true then
		local res_path = PathTool.getResFrame("common", "txt_cn_common_90024")
		if not self.return_icon then
			self.return_icon = createSprite(res_path, self.vSize.width/2, 5, self.head_panel, cc.p(1, 0), nil,99)
		else
			loadSpriteTexture(self.return_icon, res_path, LOADTEXT_TYPE_PLIST)
		end
		self.return_icon:setVisible(true)
	else
		if self.return_icon then
			self.return_icon:setVisible(false)
		end
	end
end

function PlayerHead:DeleteMe()
	self:showBgEffect(false)
	if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil

	if self.clickTimer then 
		GlobalTimeTicket:getInstance():remove(self.clickTimer)
		self.clickTimer = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end