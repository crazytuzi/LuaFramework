--[[
    背包内天书信息页
]]

local SkyBookDetailsLayer = class("SkyBookDetailsLayer", BaseLayer)

function SkyBookDetailsLayer:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.bag.SkyBookDetails")
end

function SkyBookDetailsLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.panel_root          = TFDirector:getChildByPath(ui, 'panel_root')
    self.panel_details       = TFDirector:getChildByPath(ui, 'panel_details')
    self.panel_elements      = TFDirector:getChildByPath(ui, 'panel_elements')

	--左侧详情
	self.btn_icon	 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_Num			= TFDirector:getChildByPath(ui, 'txt_number')
	self.txt_Name 			= TFDirector:getChildByPath(ui, 'txt_name')
	--self.img_quality 		= TFDirector:getChildByPath(ui, 'img_quality')
	self.txt_description    = TFDirector:getChildByPath(ui, 'txt_description')
    self.lbl_tips           = TFDirector:getChildByPath(ui, 'lbl_tips')

    --added by wuqi
    self.txt_qianghualv     = TFDirector:getChildByPath(ui, 'txt_qianghualv')
    --self.txt_qianghualv:setVisible(false)

    self.btn_yanxi = TFDirector:getChildByPath(ui, 'btn_yanxi')
    self.btn_yanxi:setVisible(true)

    self.txt_own_word = TFDirector:getChildByPath(ui, "txt_own_word")
end

function SkyBookDetailsLayer:setHomeLayer(homeLayer)
    self.homeLayer = homeLayer
end

function SkyBookDetailsLayer:removeUI()
	self.super.removeUI(self)

	self.panel_root = nil
	self.btn_icon = nil
	self.img_icon = nil
	self.txt_Num = nil
	self.txt_Name = nil
	self.img_quality = nil
	self.txt_description = nil
	self.btn_yanxi = nil
    self.panel_details = nil
    self.panel_elements = nil
    self.lbl_tips = nil
end

function SkyBookDetailsLayer:refreshUI()
    if not self.id then
        return
    end

    local data = SkyBookManager:getItemByInstanceId(self.instanceId)
    if not data then
        return
    end

    self.txt_Name:setText(data:getConfigName())
    self.img_icon:setTexture(data:GetTextrue())
    self.btn_icon:setTextureNormal(GetColorIconByQuality(data.quality))
    --self.txt_Num:setText(SkyBookManager:getNumByInstanceId(data.instanceId))
    self.txt_description:setText(data:getConfigDetails())

    if data.level == 0 then
        self.txt_qianghualv:setVisible(false)
    else
        --self.txt_qianghualv:setText(EnumSkyBookLevelType[data.level] .. "重")
        local str = stringUtils.format(localizable.common_chong, EnumSkyBookLevelType[data.level])
        self.txt_qianghualv:setText(str)
        self.txt_qianghualv:setVisible(true)
    end

    Public:addStarImg(self.img_icon, data.tupoLevel)

    if data.config.usable == 0 then
        self.type = 0
    else
        self.type = 1
    end

    self.lbl_tips:setVisible(false)
    self.btn_yanxi:setVisible(true)
    self.txt_Num:setVisible(false)

    self.txt_own_word:setVisible(false)
end

--设置物品数据
function SkyBookDetailsLayer:setData(data)
	if data == nil  then
        self.panel_details:setVisible(false)
		return false
	end

    self.toolNum = data.num

    self.panel_details:setVisible(true)
    -- print(" SkyBookDetailsLayer data.id : ",data.id)
	self.instanceId = data.instanceId
	self:refreshUI()
end

--使用按钮点击事件处理方法
function SkyBookDetailsLayer.yanxiButtonClickHandle(sender)
    local self = sender.logic

    SkyBookManager:openTianshuMainLayer(self.instanceId, 2)
end

function SkyBookDetailsLayer:registerEvents()
    self.super.registerEvents(self)

    --按钮事件
    self.btn_yanxi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.yanxiButtonClickHandle),1)
    self.btn_yanxi.logic = self   
end

--销毁方法
function SkyBookDetailsLayer:dispose()
    self.super.dispose(self)
end

function SkyBookDetailsLayer:removeEvents()
    self.btn_yanxi:removeMEListener(TFWIDGET_CLICK)
 
    self.super.removeEvents(self)
end

return SkyBookDetailsLayer
