-- --------------------------------------------------------------------
-- 我要变强列表展开子项
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
StrongerSecItem = class("StrongerSecItem", function()
    return ccui.Widget:create()
end)

function StrongerSecItem:ctor()
	self.ctrl = StrongerController:getInstance()
	self.model = self.ctrl:getModel()
	self.role_vo = RoleController:getInstance():getRoleVo()

	self:configUI()
	self:register_event()
end

function StrongerSecItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("stronger/stronger_sec_item"))
	
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(585,118))
	--self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")
	self.main_container:setTouchEnabled(true)
	self.main_container:setSwallowTouches(false)

	self.name = self.main_container:getChildByName("name")
	self.title = self.main_container:getChildByName("title")
	self.title:setString(TI18N("当前评分/本服最高："))

	self.btn = self.main_container:getChildByName("btn")
	-- self.btn:setTitleText(TI18N("前往"))
	self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(cc.c4b(0x76,0x4a,0x15,0xff), 2)
    end
	--[[self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end--]]

	self.bar_bg = self.main_container:getChildByName("bar_bg")
	self.loadingbar = self.main_container:getChildByName("loadingbar")
    self.loadingbar:setScale9Enabled(true)
    self.light = self.loadingbar:getChildByName("light")
    self.bar_exp = self.main_container:getChildByName("bar_exp")
    --self.need = self.main_container:getChildByName("need")

    self.need = createRichLabel(20, 175, cc.p(0,0.5), cc.p(480,29))
    self.main_container:addChild(self.need)

    self.tag = self.main_container:getChildByName("tag")
    self.tag_label = self.main_container:getChildByName("tag_label")
    self.tag:setVisible(false)
    self.tag_label:setVisible(false)

    self.goods_icon = self.main_container:getChildByName("goods_icon")
end

function StrongerSecItem:register_event(  )
	self.btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data.evt_type then 
				self.ctrl:clickCallBack(self.data.evt_type)
			end
		end
	end)
end


function StrongerSecItem:setData( data )
	self.data = data
	self.name:setString(data.name)
	if data.icon then 
		local res = PathTool.getItemRes(data.icon)
		loadSpriteTexture(self.goods_icon, res, LOADTEXT_TYPE)
	end
end

function StrongerSecItem:updateData( data,max )
	--print("=====StrongerSecItem====",data,max,self.data.name)
	if data == nil or max == nil then return end
	local percent = 0
	if max == 0 then 
		max = data
	end
	if max~= 0 and data~=0 then 
		percent = data/max*100
	end
	self.bar_exp:setString(data.."/"..max)
	self.loadingbar:setPercent(percent)
	--print("=========percent======",percent,self.data.id)
	if percent == 0 or percent == 100 then
		self.light:setVisible(false)
	else
		self.light:setVisible(true)
		self.light:setPositionX(self.loadingbar:getContentSize().width*(percent/100))
	end 
	self.tag:setVisible(false)
	self.tag_label:setVisible(false)
	if max ~= 0 then
		local tag,desc = self:getTagAndDesc(percent)
		self.need:setString(desc)
		if tag == 1 then --急需
			self.tag:setVisible(true)
			self.tag_label:setVisible(true)
			self.tag_label:setString(TI18N("急需"))
			self.tag_label:enableOutline(Config.ColorData.data_color4[201], 1)
		elseif tag == 2 then --推荐
			self.tag:setVisible(true)
			self.tag_label:setVisible(true)
			self.tag_label:setString(TI18N("推荐"))
			self.tag_label:enableOutline(Config.ColorData.data_color4[200], 1)
		else
			self.tag:setVisible(false)
			self.tag_label:setVisible(false)
			self.tag_label:disableEffect(cc.LabelEffect.OUTLINE)
		end
	end
end

--获取评级标签  阵容评分/推荐评分
function StrongerSecItem:getTagAndDesc( percent )
	for k,v in pairs(Config.StrongerData.data_catalg_score) do
		if v.type == 3 then --小类评分
			if v.bigger	~= 0 then --大于等于
				if v.min ~= 0 then -- 小于
					if percent>=v.bigger and percent < v.min then 
						return v.tag,v.desc
					end
				elseif v.less ~= 0 then --小于等于
					if percent <= v.less and percent >= v.bigger then 
						return v.tag,v.desc
					end
				else
					if percent >= v.bigger then 
						return v.tag,v.desc
					end
				end
			elseif v.max~=0 then --大于
				if v.min ~= 0 then -- 小于
					if percent>v.max and percent < v.min then 
						return v.tag,v.desc
					end
				elseif v.less ~= 0 then --小于等于
					if percent <= v.less and percent > v.max then 
						return v.tag,v.desc
					end
				else
					if percent > v.max then 
						return v.tag,v.desc
					end
				end
			else --大于、大于等于都等于0
				if v.min ~= 0 then -- 小于
					if percent < v.min then 
						return v.tag,v.desc
					end
				elseif v.less ~= 0 then --小于等于
					if percent <= v.less then 
						return v.tag,v.desc
					end
				end
			end
		end
	end

	--给个默认
	return 0,""
end

function StrongerSecItem:hideBg(  )
	self.bar_bg:setVisible(false)
	self.loadingbar:setVisible(false)
	self.need:setVisible(false)
	self.bar_exp:setVisible(false)
	self.btn:setPosition(cc.p(503,60))
	self.title:setTextColor(Config.ColorData.data_color4[175])
	self.title:setPositionY(35)
	self.title:setString(self.data.desc)
end


function StrongerSecItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end