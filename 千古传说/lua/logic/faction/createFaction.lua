--[[
******帮派创建界面*******

	-- by quanhuan
	-- 2015/10/23
	
]]

local createFactionLayer = class("createFactionLayer",BaseLayer)

function createFactionLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.createFaction")
end

function createFactionLayer:initUI( ui )

	self.super.initUI(self, ui)


    self.Button_create = TFDirector:getChildByPath(ui, "Button_create")
    self.Button_create.logic = self
    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_close.logic = self
    self.btn_bianji = TFDirector:getChildByPath(ui, "btn_bianji")
    

    self.bg_qizhi = TFDirector:getChildByPath(ui, "bg_qizhi")
    self.img_qi = TFDirector:getChildByPath(ui, "img_qi")


    self.playernameInput = TFDirector:getChildByPath(ui, 'playernameInput')
	self.playernameInput:setCursorEnabled(true)
	self.playernameInput:setVisible(true)

    self.txtYb = TFDirector:getChildByPath(ui, "LabelBMFont_yb")
    self.txt_YbRed = TFDirector:getChildByPath(ui, "txt_YbRed")

    if MainPlayer:getSycee() < 500 then
        self.txt_YbRed:setVisible(true)
        self.txtYb:setVisible(false)
    else
        self.txt_YbRed:setVisible(false)
        self.txtYb:setVisible(true)
    end
end

function createFactionLayer:removeUI()
	self.super.removeUI(self)
end


function createFactionLayer:onShow()
    self.super.onShow(self)

    local bannerBgPath = FactionManager:getBannerBgPath(self.bannerInfo.bannerBg,self.bannerInfo.bannerBgColor)
    local bannerIconPath = FactionManager:getBannerIconPath(self.bannerInfo.bannerIcon,self.bannerInfo.bannerIconColor)
    self.bg_qizhi:setTexture(bannerBgPath)
    self.img_qi:setTexture(bannerIconPath)

end

function createFactionLayer:registerEvents()

	self.super.registerEvents(self)


	--local pos = self.playernameInputbg:getPosition()
	--添加输入账号时输入框上移逻辑
	local function onTextFieldAttachHandle(input)
        --self.playernameInputbg:setPosition(ccp(pos.x,440))
    end    
    self.playernameInput:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)
    local function onTextFieldChangedHandle(input)
		
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)
    local function onTextFieldDetachHandle(input)
        --self.playernameInputbg:setPosition(ccp(pos.x, pos.y))
        self.playernameInput:closeIME()
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle)
    self.playernameInput:setMaxLengthEnabled(true)
    self.playernameInput:setMaxLength(10)

    local function spaceAreaClick(sender)
    	--self.playernameInputbg:setPosition(ccp(pos.x, pos.y))
    	self.playernameInput:closeIME()
	end
    self.ui:setTouchEnabled(true)
    self.ui:addMEListener(TFWIDGET_CLICK, spaceAreaClick)
    ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)


    self.Button_create:addMEListener(TFWIDGET_CLICK, audioClickfun(self.createButtonClick))
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeButtonClick))
    self.btn_bianji:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onEditBtnClick))
    self.btn_bianji.logic = self

    self.bannerInfo = FactionManager:getRandomBannerInfo()
end

function createFactionLayer:removeEvents()

    self.playernameInput:removeMEListener(TFTEXTFIELD_ATTACH)
    self.playernameInput:removeMEListener(TFTEXTFIELD_TEXTCHANGE)
    self.playernameInput:removeMEListener(TFTEXTFIELD_DETACH)
    if self.ui then
        self.ui:removeMEListener(TFWIDGET_CLICK)
    end

    self.Button_create:removeMEListener(TFWIDGET_CLICK)
    self.btn_close:removeMEListener(TFWIDGET_CLICK)
    self.btn_bianji:removeMEListener(TFWIDGET_CLICK)

    self.super.removeEvents(self)
end

function createFactionLayer:dispose()
    self.super.dispose(self)
end


function createFactionLayer.createButtonClick(btn)
	
	local self = btn.logic

	local factionName = self.playernameInput:getText()
	if string.len(factionName) < 1 then
        --toastMessage("请输入帮派名称")
		toastMessage(localizable.creatFaction_input)
		return
	end


    -- --------------------------------------------------------------    
    -- local canLoop = true
    -- local loopIdx = 1
    -- while canLoop do
    --     local b = string.byte(factionName,loopIdx,loopIdx)
    --     print("loopIdx = ",loopIdx)
    --     print("b = ",b)

    --     if (b >= 48 and b <= 57) or (b >= 97 and b <= 122) then
    --         loopIdx = loopIdx + 1
    --     elseif b >= 224 and b < 240 then
    --         if b == 226 or b == 239 then
    --             toastMessage("存在特殊字符")
    --             return
    --         end
    --         loopIdx = loopIdx + 3
    --     else
    --         toastMessage("存在特殊字符")
    --         return
    --     end      
    --     if loopIdx > string.len(factionName) then
    --         canLoop = false
    --     end
    -- end
    --------------------------------------------------------------


    if MainPlayer:getSycee() < 500 then
        --toastMessage("元宝不够")
        toastMessage(localizable.common_no_yuanbao)
        return
    end

	--local msg = "是否花费500元宝创建帮派\n".."\""..factionName.."\""
    local  msg = stringUtils.format(localizable.creatFaction_create_tips,factionName)
    CommonManager:showOperateSureLayer(
        function()
            local strMsg = string.format('%d_%d_%d_%d',self.bannerInfo.bannerBg,self.bannerInfo.bannerBgColor,
                self.bannerInfo.bannerIcon,self.bannerInfo.bannerIconColor)
            FactionManager:sendMsgCreateFaction( factionName,strMsg )
        end,
        function()
            AlertManager:close()
        end,
        {
        --title = "创建帮派",
        title = localizable.creatFaction_create,
        msg = msg,
        showtype = AlertManager.BLOCK_AND_GRAY,
        }
    )

end

function createFactionLayer.closeButtonClick(btn)	
	local self = btn.logic
	AlertManager:close()	
end

function createFactionLayer.onEditBtnClick( btn )
    local self = btn.logic
    local layer  = require("lua.logic.faction.EditBannerLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    self.clickCallBack = function (bannerInfo)
        self.bannerInfo.bannerBg = bannerInfo.bannerBg
        self.bannerInfo.bannerBgColor = bannerInfo.bannerBgColor
        self.bannerInfo.bannerIcon = bannerInfo.bannerIcon
        self.bannerInfo.bannerIconColor = bannerInfo.bannerIconColor
    end
    layer:setData(self.bannerInfo,false,self.clickCallBack)
    AlertManager:show()
end
return createFactionLayer