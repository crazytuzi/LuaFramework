--[[
	文件名：BagWuxueLayer.lua
	描述：包裹主界面
	创建人：yanxingrui
    修改人：lengjiazhi
	创建时间： 2016.5.6
--]]

local BagWuxueLayer = class("BagWuxueLayer", function(params)
	return display.newLayer()
end)

function BagWuxueLayer:ctor(params)
	self.mCurTag = params.subPageType or BagType.eZhenjue
	self.mParent = params.parent

    local zhenjueStatus = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eZhenjue, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenjue)
    if self.mCurTag == BagType.eZhenjue and not zhenjueStatus then 
        self.mCurTag = BagType.ePetBag
    end 

	self.mSelectId = params and params.selectId 
    self.mDataList = {}
    self.mViewPos = params.viewPos 

	--子页面父节点
	self.mSubParentLayer = display.newLayer()
	self:addChild(self.mSubParentLayer)

    --创建分页
    self:showTabLayer()

    -- 播放音效
    MqAudio.playEffect("zhuangbei_open.mp3")
end

function BagWuxueLayer:showTabLayer()
	local tabInfo = {}

	 --判断服务器是不是开启阵决
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eZhenjue, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenjue) then
        table.insert(tabInfo,{
            text = TR("内功"),
			fontSize = 22,
        	titlePosRateY = 0.5,
            tag = BagType.eZhenjue,
            needRedDot = true,
            moduleId = ModuleSub.eBagZhenjueDebris,
        })
    end
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePet, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.ePet) then
        table.insert(tabInfo,{
            text = TR("外功"),
			fontSize = 22,
        	titlePosRateY = 0.5,
            tag = BagType.ePetBag,
            needRedDot = true,
            moduleId = ModuleSub.eBagPets,
        })
    end

    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eFashion, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eFashion) then
        table.insert(tabInfo,{
            text = TR("绝学碎片"),
            fontSize = 22,
            titlePosRateY = 0.5,
            tag = BagType.eFashionBag,
            needRedDot = true,
            moduleId = ModuleSub.eBagFashionDebris,
        })
    end

	-- 创建tablayer
    self.tablayer = ui.newTabLayer({
        btnInfos = tabInfo,
        defaultSelectTag = self.mCurTag,
        space = 10,
        btnSize = cc.size(103, 49),
        viewSize = cc.size(350, 80),
        normalImage = "c_155.png",
        lightedImage = "c_154.png",
        needLine = false,
        onSelectChange = function (selectBtnTag)
            self:addElements(selectBtnTag)
        end,
    })
    self.tablayer:setAnchorPoint(0, 0.5)
    self.tablayer:setPosition(10, 945)
    self:addChild(self.tablayer)

     -- 页面切换按钮的new标识
    for _, button in pairs(tabInfo) do
        local redDotModuleId = button.moduleId
        local tagButton = self.tablayer:getTabBtnByTag(button.tag)
        -- 添加new
        if redDotModuleId then
            local function dealNewVisible(newSprite)
                newSprite:setVisible(RedDotInfoObj:isNewValid(redDotModuleId))
            end
            ui.createAutoBubble({parent = tagButton, isNew = true, eventName = RedDotInfoObj:getNewEvents(redDotModuleId),
                refreshFunc = dealNewVisible})

            -- 添加合成小红点
            if button.needRedDot then
                local function dealRedDotVisible(redDotSprite)
                    redDotSprite:setVisible(RedDotInfoObj:isValid(redDotModuleId))
                end
                ui.createAutoBubble({parent = tagButton, eventName = RedDotInfoObj:getEvents(redDotModuleId),
                    refreshFunc = dealRedDotVisible, position = cc.p(0.9, 0.8)})
            end
        end
    end
end

function BagWuxueLayer:addElements(tag)
	--清空子节点
	self.mSubParentLayer:removeAllChildren()

	if tag == BagType.eZhenjue then
        self.mCurTag = BagType.eZhenjue
        self.hadViewNewZhenJue = true
        local zhenjueLayer = require("bag.BagZhenjueLayer"):create({selectId = self.mSelectId, viewPos = self.mViewPos, parent = self.mParent})
        self.mSubParentLayer:addChild(zhenjueLayer)
    elseif tag == BagType.ePetBag then
        self.mCurTag = BagType.ePetBag
        self.hadViewNewPet = true
        local petLayer = require("bag.BagPetLayer"):create({selectId = self.mSelectId, viewPos = self.mViewPos, parent = self.mParent})
        self.mSubParentLayer:addChild(petLayer)
    elseif tag == BagType.eFashionBag then
        self.mCurTag = BagType.eFashionBag
        local petLayer = require("bag.BagFashionLayer"):create({selectId = self.mSelectId, viewPos = self.mViewPos, parent = self.mParent})
        self.mSubParentLayer:addChild(petLayer)
    end
end

function BagWuxueLayer:onExit()
	if self.hadViewNewZhenJue then
     	ZhenjueObj:getNewIdObj():clearNewId()
        GoodsObj:getNewZhenjueDebrisIdObj():clearNewId()
        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagZhenjueDebris)
    end

    if self.hadViewNewPet then
        PetObj:getNewIdObj():clearNewId()
        GoodsObj:getNewZhenjueDebrisIdObj():clearNewId()
        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagPets)
    end
end

return BagWuxueLayer